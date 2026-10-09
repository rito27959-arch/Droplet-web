// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Si `mesh_transport_service.dart` est le chef d'orchestre qui fait
// VOYAGER les paquets de données entre les téléphones (par Bluetooth,
// Wi-Fi, ou Nearby), CE fichier est le CERVEAU qui décide QUOI mettre
// dans ces paquets et QUOI FAIRE de ce qu'on reçoit. C'est ici que
// vivent toutes les vraies fonctionnalités de Droplet : envoyer un
// message, publier un statut, créer un groupe, envoyer un fichier,
// signaler qu'on est en sécurité en cas de catastrophe, etc.
//
// Quelques idées importantes à comprendre pour tout le fichier :
//
//   - « Relayer un message » : comme dans le jeu du téléphone arabe (ou
//     une chaîne de personnes qui se passent un seau d'eau), un message
//     ne va pas directement de A à B s'ils ne sont pas côte à côte — il
//     passe de téléphone en téléphone jusqu'à atteindre sa destination
//     (ou jusqu'à épuiser son « nombre de sauts » autorisés, pour ne pas
//     tourner en rond éternellement).
//   - « Message dirigé » (chat privé) : même si un message chiffré pour
//     UNE personne passe par plusieurs autres téléphones en chemin (comme
//     une lettre scellée qui transite par plusieurs bureaux de poste),
//     seul le vrai destinataire peut l'ouvrir et le lire — les autres se
//     contentent de la faire suivre sans pouvoir l'ouvrir.
//   - « Diffusion » (broadcast) : à l'inverse, certaines choses (un
//     statut, un message d'urgence) sont volontairement publiques et
//     doivent atteindre TOUT LE MONDE sur le réseau.
//   - « Sender-key » de groupe : chaque membre d'un groupe a sa propre
//     « chaîne » de clés secrètes qui avance à chaque message envoyé
//     (comme un cadenas à combinaison qui change de code après chaque
//     utilisation) — cela permet à tous les autres membres de suivre et
//     déchiffrer, tout en gardant les anciens messages illisibles pour
//     quelqu'un qui rejoindrait le groupe plus tard.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import '../models/mesh_message.dart';
import '../models/status_media.dart';
import '../sync/sync_negotiation.dart';
import '../network/premium_message_queue.dart';
import '../services/crypto_service.dart';
import '../providers/locale_provider.dart';
import '../services/annonces_droplet.dart';
import '../services/garde_messages.dart';
import '../services/media_service.dart';
import '../services/storage_service.dart';
import '../config/server_config.dart';
import '../services/mesh_transport_service.dart';
import '../services/ble_mesh_protocol.dart';
import '../services/call_signaling_service.dart';
import '../services/notification_service.dart';
import '../services/journal_notifs.dart';
import '../../features/nexus_connection/nexus_event.dart';
import '../services/fichier_morcele.dart';
import '../services/avatar_service.dart';
import '../services/contacts.dart';
import '../services/appel_outils.dart';
import '../services/signal/signal_service.dart';
import '../services/presence_internet.dart';
import '../../features/group/reglages_groupe.dart';
import '../../features/group/invitation_groupe.dart';
import '../../features/call/salon_vocal.dart';

/// Un message en attente de relais — mis de côté quand on n'a
/// temporairement aucun pair connecté à qui le transmettre.
class _PendingRelay {
  final String id;
  final Uint8List payload;
  _PendingRelay(this.id, this.payload);
}

/// Repository mesh pour Droplet (messagerie + appels 1:1 hors ligne).
///
/// ## Chat dirigé (WhatsApp-like)
/// Chaque message peut cibler un pair précis via [targetId] (wire `t`).
/// - [targetId] null → diffusion mesh (tout le monde)
/// - [targetId] défini → seul le destinataire affiche le message, les autres
///   pairs se contentent de le relayer (store-and-forward) jusqu'à épuisement
///   du TTL (hopCount).
///
/// ## Batterie
/// - ACK batching (regroupe les ACK)
/// - Pas de relay BLE si batterie < 15%
/// - Flush d'outbox différé en background
class MeshRepository {
  /// Par défaut, le vrai service de transport — mais il peut être
  /// remplacé, et c'est ce qui permet de faire tourner un NŒUD COMPLET
  /// de Droplet dans un test : la même logique de messages, d'accusés,
  /// de déduplication et de relais, mais posée sur des transports
  /// simulés au lieu de vraies radios.
  ///
  /// Sans ce point d'injection, mesurer un taux de livraison ou une
  /// latence à vingt nœuds supposait vingt téléphones.
  MeshRepository({MeshTransportService? transport})
      : _transport = transport ?? MeshTransportService();

  final MeshTransportService _transport;
  bool _initialized = false;

  // ── File fiable (retry + backoff exponentiel) ─────────────────────────────
  //
  // Chaque envoi important (message, fichier, statut, check-in sécurité,
  // contrôle de groupe) passe par cette file : en cas d'échec transitoire
  // (transport instable, pair qui bouge), le message est RÉESSAYÉ avec un
  // backoff exponentiel + jitter au lieu d'être perdu — c'est ce qui rend
  // la messagerie fiable « comme sur Internet » même sur un mesh physique
  // capricieux (BLE/Wi-Fi/Nearby). Quand aucun pair n'est joignable, le
  // message reste dans la file (store-and-forward) jusqu'à ce qu'un chemin
  // s'ouvre, jusqu'à épuisement du budget de tentatives.
  PremiumMessageQueue? _queue;
  final Map<String, Completer<void>> _sendOutcomes = {};

  // ── LA GARDE ────────────────────────────────────────────────────────
  //
  // ⚠️ POURQUOI UNE SECONDE COUCHE ALORS QU'IL Y A DÉJÀ UNE FILE FIABLE.
  //
  // `PremiumMessageQueue` est bonne, mais elle a deux propriétés qui,
  // ensemble, perdent des messages :
  //
  //   • Elle vit en MÉMOIRE. L'application fermée, tout ce qui n'était
  //     pas parti n'existe plus.
  //   • Elle ABANDONNE. Six tentatives, recul `2^n × 100 ms` : le calcul
  //     a été rejoué, l'abandon définitif tombe entre 6,4 et 7,7
  //     secondes. Un destinataire absent plus de SEPT SECONDES ne reçoit
  //     jamais le message, et plus rien ne le repropose ensuite.
  //
  // La garde, elle, est sur disque et n'abandonne pas avant sept jours.
  // Elle ne remplace pas la file : la file fait la course de vitesse, la
  // garde fait la course de fond.
  GardeMessages? _garde;
  Timer? _battementGarde;

  /// ⚠️ LE BATTEMENT NE SERT PAS QU'À LA RECONNEXION. Un message créé
  /// PENDANT une session vivante mais instable n'a rien qui le repropose
  /// si le rattrapage n'a lieu qu'à l'ouverture de la session. C'est
  /// exactement la classe de bogue « on était tous les deux là, et il
  /// n'est pas arrivé ».
  static const Duration _periodeGarde = Duration(seconds: 20);

  PremiumMessageQueue get _reliableQueue => _queue ??= (PremiumMessageQueue(
        maxRetries: 6,
        defaultTimeout: const Duration(seconds: 30),
        onSend: _reliableOnSend,
        onDelivered: (messageId) => _completeSend(messageId, success: true),
        onFailed: (messageId, reason) => _completeSend(messageId, success: false, reason: reason),
        getCongestionWindow: (peerId) => _transport.protocol.getCongestionWindow(peerId),
        debugLog: debugPrint,
      )..start());

  /// Transmet réellement un paquet sur le mesh. « Succès » = le paquet a
  /// été accepté par AU MOINS un pair connecté (il est sur le fil — les
  /// relais le feront suivre vers la destination). S'il n'y a aucun pair
  /// joignable, retourne false → la file réessaiera plus tard.
  ///
  /// Routage adaptatif : un message dirigé (targetId ≠ broadcast) passe
  /// d'abord par un envoi CIBLÉ (direct ou via le prochain saut connu du
  /// protocole v2) au lieu de la diffusion massive ; on ne retombe sur le
  /// flooding classique que si aucune route n'existe (découverte).
  Future<bool> _reliableOnSend(SendTask task) async {
    final interestGroups = task.context is Set<String>
        ? (task.context as Set<String>).cast<String>()
        : null;

    final payload = Uint8List.fromList(task.payload);
    final type = payload.length > 1 ? payload[1] : 0x00;
    final activePeers = _transport.activePeerCount;

    debugPrint('[MeshRepo] _reliableOnSend msg=${task.messageId} '
        'target=${task.targetId} type=0x${type.toRadixString(16)} '
        'size=${payload.length}o activePeers=$activePeers '
        'groups=$interestGroups');

    if (task.targetId != 'broadcast') {
      try {
        final routed = await _transport.sendViaRoute(
          task.targetId, payload, type: type, priority: task.priority.value);
        if (routed) {
          debugPrint('[MeshRepo] routage OK vers ${task.targetId}');
          return true;
        }
      } catch (e) {
        debugPrint('[MeshRepo] routage vers ${task.targetId} échoué: $e');
      }
    }

    try {
      final result = await _transport.broadcastToConnectedPeers(
        payload,
        interestGroups: interestGroups,
        type: type,
      );
      debugPrint('[MeshRepo] diffusion ${result ? "OK" : "ÉCHEC"} '
          'msg=${task.messageId}');
      return result;
    } catch (e) {
      debugPrint('[MeshRepo] diffusion exception: $e');
      return false;
    }
  }

  /// Enfile [data] dans la file fiable et attend son issue : le Future se
  /// résout quand le message est sur le fil, ou lève une exception après
  /// épuisement des tentatives (ou timeout). Retourne l'ID utilisé.
  Future<String> _enqueueReliable({
    required String messageId,
    required String targetId,
    required Uint8List data,
    MessagePriority priority = MessagePriority.normal,
    Set<String>? interestGroups,
    Duration? timeout,
  }) async {
    final completer = Completer<void>();
    _sendOutcomes[messageId] = completer;
    // Confier AVANT d'enfiler : si l'application est tuée entre les deux,
    // mieux vaut une ligne de garde en trop qu'un message perdu. Elle ne
    // coûte rien — le premier ACK l'efface.
    //
    // ⚠️ LIMITE CONNUE, ET BORNÉE. Pour un message de groupe, `targetId`
    // vaut l'identifiant du GROUPE et non celui d'un pair. La ligne de
    // garde correspondante ne sera donc jamais due (aucun pair joignable
    // ne porte cet identifiant) ni acquittée, et elle vivra jusqu'à la
    // purge des sept jours. Le coût est réel mais petit — environ 380
    // octets par message de groupe non acquitté — et la garde des
    // messages 1:1, qui est le cas qui posait problème, fonctionne. Le
    // correctif propre est de passer ici la liste des MEMBRES du groupe ;
    // il demande de toucher le site d'appel de l'envoi de groupe, ce qui
    // est un changement à faire et à compiler séparément.
    _garde?.confier(messageId: messageId, pairs: [targetId], corps: data);
    _reliableQueue.enqueue(
      messageId: messageId,
      targetId: targetId,
      payload: data,
      priority: priority,
      context: interestGroups,
    );
    try {
      // ⚠️ LE TIMEOUT DOIT COUVRIR LE BUDGET COMPLET DES RETRIES.
      //
      // La file fait 6 tentatives avec backoff exponentiel (100ms → 3.2s)
      // et un timeout de 30s par tentative. Le timeout total est donc
      // d'environ 6 × 30s + backoff ≈ 186s. Si le timeout ici est
      // inférieur, le Completer se résout avant que la file ait fini
      // ses retries, et le message est marqué « échoué » alors qu'un
      // envoi ultérieur pourrait réussir.
      await completer.future.timeout(
          timeout ?? const Duration(seconds: 180));
    } on TimeoutException {
      _completeSend(messageId);
      _reliableQueue.cancel(messageId);
      throw StateError('Délai dépassé pour l\'envoi du message $messageId');
    }
    return messageId;
  }

  void _completeSend(String messageId, {bool success = true, String? reason}) {
    final completer = _sendOutcomes.remove(messageId);
    if (completer == null || completer.isCompleted) {
      if (completer == null) {
        debugPrint('[MeshRepo] _completeSend $messageId: deja retire (null)');
      }
      return;
    }
    if (success) {
      debugPrint('[MeshRepo] _completeSend $messageId: SUCCES');
      completer.complete();
    } else {
      debugPrint('[MeshRepo] _completeSend $messageId: ECHEC ($reason)');
      completer.completeError(
        StateError(reason ?? 'Échec de l\'envoi du message $messageId'),
      );
    }
  }

  Set<String> _seenMessageIds = {};
  final Map<String, DateTime> _appMessageIds = {};
  final Map<String, int> _ackCounts = {};
  static const Duration _seenIdMaxAge = Duration(days: 7);

  String _myId = '';
  String _myPseudo = '';
  String? _myPublicKey;

  /// Émet l'ID d'un pair dont la clé publique vient d'être établie
  /// (échange de clés terminé — le chiffrement de bout en bout est
  /// désormais possible avec ce pair).
  final _peerKeyReadyCtrl = StreamController<String>.broadcast();
  Stream<String> get peerKeyReadyEvents => _peerKeyReadyCtrl.stream;

  /// Émet l'ID d'un groupe dont l'état local (métadonnées, membres) vient
  /// de changer — création, ajout/retrait de membre, renommage, synchro
  /// reçue d'un autre membre.
  final _groupsChangedCtrl = StreamController<String>.broadcast();
  Stream<String> get groupsChangedEvents => _groupsChangedCtrl.stream;

  /// Émet les événements Nexus reçus d'un pair distant.
  // Avec l'appareil qui l'envoie : Nexus ne se joue qu'une fois par appareil.
  final _nexusEventCtrl =
      StreamController<({String peerId, NexusEvent event})>.broadcast();
  Stream<({String peerId, NexusEvent event})> get nexusEvents => _nexusEventCtrl.stream;

  // ── Paquets mesh transportés par Internet ─────────────────────────────
  //
  // ⚠️ GROUPES, STATUTS, CLÉS DE GROUPE… NE PASSAIENT QUE PAR LE MESH. Sans
  // voisin, un message de groupe restait « en attente » et un statut
  // n'atteignait personne, même avec Internet. Plutôt que de réécrire chaque
  // fonctionnalité pour la boîte aux lettres, on y dépose LE MÊME paquet que
  // celui envoyé au mesh, chiffré pour le destinataire (`MeshNotifier
  // ._deposerPaquet`). À la réception, il repasse par
  // [_handleIncomingMessage] : mêmes dédoublonnages, mêmes vérifications,
  // même déchiffrement de groupe.

  // ── Invitations aux appels de groupe par Internet ────────────────────
  final _groupCallInviteCtrl =
      StreamController<({String groupId, String fromPeerId, List<String> participants})>.broadcast();

  /// Un membre d'un groupe m'invite à le rejoindre dans la salle d'appel du
  /// groupe (voir `AppelGroupeInternet`).
  Stream<({String groupId, String fromPeerId, List<String> participants})> get groupCallInvites =>
      _groupCallInviteCtrl.stream;

  /// Dépose un paquet dans la boîte aux lettres d'un pair — posé par
  /// `MeshNotifier`, qui détient le client de boîte aux lettres.
  Future<bool> Function(String peerId, Uint8List paquet)? deposerPaquetEnLigne;

  bool _joignableEnMesh(String peerId) =>
      _transport.connectedPeers.any((p) => p.peerId == peerId && !p.reconnecting);

  /// Double [paquet] par Internet vers ceux de [destinataires] que le mesh ne
  /// joint pas et dont la clé est connue. Renvoie le nombre de dépôts réussis.
  Future<int> _doublerParInternet(Iterable<String> destinataires, Uint8List paquet) async {
    final deposer = deposerPaquetEnLigne;
    if (deposer == null) return 0;
    final cibles = destinataires
        .where((id) => id.isNotEmpty && id != _myId && !_joignableEnMesh(id) && clePubliqueConnue(id))
        .toSet();
    if (cibles.isEmpty) return 0;
    final resultats = await Future.wait(cibles.map((id) => deposer(id, paquet).catchError((Object e) {
          debugPrint('[MeshRepo] paquet non déposé pour $id: $e');
          return false;
        })));
    return resultats.where((ok) => ok).length;
  }

  /// Les destinataires d'un envoi visant [id] : les membres actifs si c'est
  /// un groupe, sinon le pair lui-même.
  Iterable<String> _destinatairesDe(String id) {
    final groupe = StorageService.getGroup(id);
    if (groupe == null) return [id];
    return groupe.activeMembers.map((m) => m.peerId);
  }

  /// Les contacts qui reçoivent mes statuts par Internet (règle « Mes contacts »).
  Iterable<String> _contactsPourStatut() {
    final messages = StorageService.getMessages();
    return StorageService.getKnownPeers()
        .map((p) => p.peerId)
        .where((id) => estUnContact(messages, _myId, id))
        .where((id) => !StorageService.isContactBlocked(id));
  }

  /// Un paquet mesh arrivé par la boîte aux lettres, déjà déchiffré
  /// (base64). Traité exactement comme s'il venait d'un voisin.
  Future<void> recevoirPaquetEnLigne(String expediteur, String paquetB64, {required String idDepot}) async {
    final Uint8List octets;
    try {
      octets = base64Decode(paquetB64);
    } catch (_) {
      return;
    }
    if (octets.length < 2) return;
    // Ce paquet est arrivé par Internet : c'est la seule preuve honnête
    // qu'on ait que ce téléphone a parlé en ligne, et elle ne se mélange
    // jamais avec un croisement par le maillage.
    PresenceInternet.signe(expediteur);
    await _handleIncomingMessage(
      MeshIncomingData(messageId: 'mb-$idDepot', peerId: expediteur, data: octets),
    );
  }

  /// Émet les modifications de message reçues d'un pair distant.
  /// Payload: (messageId, newContent).
  ///
  /// ⚠️ [senderId] VOYAGE AVEC LA MODIFICATION. Sans lui, le récepteur
  /// appliquait n'importe quelle modification à n'importe quel message
  /// dont il connaissait l'identifiant : un tiers pouvait réécrire les
  /// messages d'un autre. `MeshNotifier.applyRemoteEdit` vérifie
  /// désormais que l'émetteur est bien l'auteur.
  final _editCtrl = StreamController<
      ({String messageId, String newContent, String senderId})>.broadcast();
  Stream<({String messageId, String newContent, String senderId})>
      get editEvents => _editCtrl.stream;

  /// Émet les épinglages reçus : quel message, épinglé ou non, par qui,
  /// dans quel groupe (`null` en 1:1). Voir `epingles.dart`.
  final _epingleCtrl = StreamController<
      ({String messageId, bool epingle, String senderId, String? groupId})>.broadcast();
  Stream<({String messageId, bool epingle, String senderId, String? groupId})>
      get epingleEvents => _epingleCtrl.stream;

  /// Émet chaque message affichable déchiffré et persisté (1:1, diffusion,
  /// groupe, fichier) — source unique pour l'UI (`MeshNotifier`), qui ne
  /// décode plus le flux brut elle-même. Évite qu'un déchiffrement ou un
  /// ratchet (groupe) ne s'exécute deux fois indépendamment.
  final _newMessageCtrl = StreamController<MeshMessage>.broadcast();
  Stream<MeshMessage> get newMessageEvents => _newMessageCtrl.stream;

  /// Progression d'un fichier en cours d'ENVOI (`envoi: true`) ou de
  /// RÉCEPTION (`envoi: false`), de 0 à 1. Voir `fichier_morcele.dart`.
  final _fileProgressCtrl =
      StreamController<({String fileId, double progression, bool envoi})>.broadcast();
  Stream<({String fileId, double progression, bool envoi})> get fileProgressEvents =>
      _fileProgressCtrl.stream;

  /// Progression d'un transfert mené HORS de ce dépôt — les photos et vidéos
  /// envoyées par Internet en morceaux (voir `fichier_en_ligne.dart`).
  void publierProgression(String fileId, double progression, {required bool envoi}) =>
      _fileProgressCtrl.add((fileId: fileId, progression: progression, envoi: envoi));

  /// Un pair vient de transmettre (ou de retirer) sa photo de profil.
  final _peerAvatarCtrl = StreamController<String>.broadcast();
  Stream<String> get peerAvatarEvents => _peerAvatarCtrl.stream;

  /// Fichiers en cours de réassemblage, et la méta du premier morceau reçu.
  final Map<String, AssemblageFichier> _assemblages = {};
  final Map<String, Map<String, dynamic>> _assemblagesMeta = {};

  /// Fichiers morcelés déjà reconstitués : un morceau retardataire ou
  /// dupliqué ne doit pas relancer un réassemblage.
  final Map<String, DateTime> _fichiersTermines = {};

  /// Dernière demande de photo par pair — pas une à chaque « hello ».
  final Map<String, DateTime> _avatarsDemandes = {};

  /// Réémet dans [newMessageEvents] un message arrivé par un canal qui NE
  /// passe PAS par `_handleIncomingMessage` — aujourd'hui, la mailbox
  /// (relais Tor, message venu de loin).
  ///
  /// ⚠️ SANS ÇA, UN MESSAGE REÇU PAR TOR NE DÉCLENCHAIT NI NOTIFICATION
  /// NI SON. Il s'ajoutait bien à la conversation (le sondeur de mailbox
  /// mettait l'état à jour lui-même), mais tout ce qui prévient
  /// l'utilisateur — `NotificationService.showNewMessage` avec son
  /// action « Répondre », la tonalité de `SoundService` — écoute
  /// `newMessageEvents`, et lui seul. Le maillage direct passait par là ;
  /// la mailbox, non.
  void announceIncoming(MeshMessage msg) {
    if (msg.senderId == _myId) return;
    _newMessageCtrl.add(msg);
  }

  Stream<ConnectedPeer>? get peerEvents => _transport.peerEvents;
  Stream<MeshIncomingData>? get incomingData => _transport.incomingData;

  /// Émet la première fois qu'un pair se connecte dans cette session.
  ///
  /// Utilisé par le Nexus pour déclencher l'animation de connexion.
  /// Les pairs déjà connus avant le lancement de l'app ne déclenchent
  /// rien — on ne veut pas revoir l'animation à chaque redémarrage.
  final _firstPeerCtrl = StreamController<ConnectedPeer>.broadcast();
  Stream<ConnectedPeer> get firstPeerConnection => _firstPeerCtrl.stream;
  final Set<String> _connectedThisSession = {};

  /// Pair premier né de la session, en attente que le dashboard s'abonne.
  /// Le broadcast stream perd les événements émis avant le premier
  /// auditeur — si le mesh trouve un pair pendant que le dashboard
  /// n'a pas encore initialisé son écoute, `_firstPeerCtrl.add()` tombe
  /// dans le vide. On le sauvegarde ici pour le rejouer dès l'abonnement.
  ConnectedPeer? _pendingFirstPeer;
  MeshTransportService get transport => _transport;

  /// Récupère et consomme le premier pair connecté s'il a été détecté
  /// avant l'abonnement du dashboard au stream broadcast.
  /// Retourne null s'il n'y en a pas (le dashboard s'est abonné à temps).
  ConnectedPeer? consumePendingFirstPeer() {
    final p = _pendingFirstPeer;
    _pendingFirstPeer = null;
    return p;
  }

  String get myId => _myId;
  String get myPseudo => _myPseudo;

  int get connectedPeers => _transport.connectedPeerCount;
  int get blePeerCount => _transport.blePeerCount;
  int get wifiPeerCount => _transport.wifiPeerCount;
  List<ConnectedPeer> get peerList => _transport.connectedPeers;
  int get peersEverSeen => _transport.peersEverSeen;

  // ── Accusés de GROUPE : qui a reçu, qui a lu ─────────────────────────
  //
  // Dans un groupe, « distribué » et « lu » veulent dire « par TOUS les
  // membres », comme WhatsApp. On retient donc, pour chaque message de
  // groupe envoyé, l'ensemble des membres qui l'ont reçu et l'ensemble de
  // ceux qui l'ont lu. Les accusés de saut du mesh (ACK de voisin) ne comptent
  // pas : un voisin qui relaie n'est pas forcément un membre.
  final Map<String, Set<String>> _recusGroupe = {};
  final Map<String, Set<String>> _lusGroupe = {};
  final Map<String, String?> _groupeParMessage = {};

  String? _groupeDuMessage(String messageId) => _groupeParMessage.putIfAbsent(
        messageId,
        () => StorageService.getMessages().where((m) => m.id == messageId).firstOrNull?.groupId,
      );

  /// Les membres qui doivent recevoir un message de groupe : tous, sauf moi.
  int _destinatairesGroupe(String groupId) =>
      StorageService.getGroup(groupId)?.activeMembers.where((m) => m.peerId != _myId).length ?? 0;

  /// Nombre d'accusés de réception : pour un message de groupe, le nombre de
  /// MEMBRES qui l'ont reçu.
  int getAckCount(String messageId) {
    final recus = _recusGroupe[messageId];
    if (recus != null) return recus.length;
    if (_groupeDuMessage(messageId) != null) return 0;
    return _ackCounts[messageId] ?? 0;
  }

  void _noterRecu(String messageId, String deQui) {
    if (_groupeDuMessage(messageId) == null) {
      _ackCounts[messageId] = (_ackCounts[messageId] ?? 0) + 1;
      _ackCtrl.add(messageId);
      return;
    }
    if (deQui.isNotEmpty && (_recusGroupe[messageId] ??= {}).add(deQui)) {
      _ackCtrl.add(messageId);
    }
  }

  void _noterLecture(String messageId, String? deQui) {
    final groupe = _groupeDuMessage(messageId);
    if (groupe == null || deQui == null || deQui.isEmpty) {
      _readCtrl.add(messageId);
      return;
    }
    // Lu implique reçu.
    if ((_recusGroupe[messageId] ??= {}).add(deQui)) _ackCtrl.add(messageId);
    final lus = _lusGroupe[messageId] ??= {};
    if (!lus.add(deQui)) return;
    // Bleu seulement quand tout le groupe a lu.
    if (lus.length >= _destinatairesGroupe(groupe)) _readCtrl.add(messageId);
  }

  final _ackCtrl = StreamController<String>.broadcast();
  Stream<String> get ackEvents => _ackCtrl.stream;

  /// Signaux de frappe reçus (émet l'ID du pair qui tape).
  final _typingCtrl = StreamController<String>.broadcast();
  Stream<String> get typingEvents => _typingCtrl.stream;

  /// « En train d'écrire » reçu par Internet (boîte d'appels) : même effet
  /// qu'un signal du mesh.
  void signalerFrappeEnLigne(String peerId, {String? groupId}) {
    if (peerId.isEmpty || peerId == _myId) return;
    if (groupId != null) {
      if (StorageService.getGroup(groupId)?.isActiveMember(_myId) ?? false) {
        _frappeGroupeCtrl.add((groupId: groupId, peerId: peerId));
      }
      return;
    }
    _typingCtrl.add(peerId);
  }

  /// « En train d'écrire » dans un GROUPE : qui, et dans quel groupe.
  final _frappeGroupeCtrl = StreamController<({String groupId, String peerId})>.broadcast();
  Stream<({String groupId, String peerId})> get frappeGroupeEvents => _frappeGroupeCtrl.stream;

  /// Les membres qui ont lu / reçu un de mes messages de groupe (depuis le
  /// lancement de l'application).
  Set<String> lecteursGroupe(String messageId) => {...?_lusGroupe[messageId]};
  Set<String> recepteursGroupe(String messageId) => {...?_recusGroupe[messageId]};

  /// Accusés de lecture reçus (émet l'ID du message lu).
  final _readCtrl = StreamController<String>.broadcast();
  Stream<String> get readEvents => _readCtrl.stream;

  /// Réactions reçues (émet (messageId, emoji)).
  final _reactionCtrl = StreamController<({String messageId, String emoji})>.broadcast();
  Stream<({String messageId, String emoji})> get reactionEvents => _reactionCtrl.stream;

  /// Les mêmes réactions, avec QUI a réagi.
  ///
  /// ⚠️ UN SECOND FLUX PLUTÔT QU'UN CHAMP DE PLUS DANS LE PREMIER. Le
  /// premier est écouté à plusieurs endroits qui déstructurent ses deux
  /// champs ; y ajouter l'auteur les obligerait tous à changer pour une
  /// information dont seul le centre de notifications a besoin.
  final _reactionAuteurCtrl = StreamController<
      ({String messageId, String emoji, String? auteurId})>.broadcast();
  Stream<({String messageId, String emoji, String? auteurId})>
      get reactionAuteurEvents => _reactionAuteurCtrl.stream;

  /// Votes de sondage reçus (émet l'ID du sondage, l'index choisi et
  /// l'auteur du vote).
  ///
  /// ⚠️ CONTRAIREMENT À `reactionEvents`, CET ÉVÉNEMENT EST PERSISTÉ.
  /// Une réaction reçue ne fait que jouer un effet visuel côté
  /// destinataire (voir `chat_screen.dart`) sans jamais mettre à jour la
  /// liste stockée des réactions de l'AUTRE côté de la conversation —
  /// un choix suffisant pour un emoji éphémère, mais pas pour un
  /// sondage : le compte des voix doit être identique sur tous les
  /// appareils qui l'ont reçu. `pollVotesProvider` s'abonne à ce flux et
  /// fusionne chaque vote dans un tally persisté.
  final _pollVoteCtrl =
      StreamController<({String pollId, String voterId, int optionIndex})>.broadcast();
  Stream<({String pollId, String voterId, int optionIndex})> get pollVoteEvents =>
      _pollVoteCtrl.stream;

  /// Check-in "je suis en sécurité" reçus (mode urgence/catastrophe).
  final _safetyCheckinCtrl = StreamController<SafetyCheckinRecord>.broadcast();
  Stream<SafetyCheckinRecord> get safetyCheckinEvents => _safetyCheckinCtrl.stream;

  /// Statuts éphémères reçus.
  final _statusCtrl = StreamController<MeshStatusRecord>.broadcast();
  Stream<MeshStatusRecord> get statusEvents => _statusCtrl.stream;

  /// Accusé de vue reçu pour un de MES statuts (émet le statusId concerné).
  final _statusSeenCtrl = StreamController<String>.broadcast();
  Stream<String> get statusSeenEvents => _statusSeenCtrl.stream;

  /// Un média de statut vient d'arriver en entier (émet son fileId).
  ///
  /// L'annonce d'un statut et son média voyagent séparément, et la
  /// première arrive presque toujours en premier — elle ne pèse que
  /// quelques centaines d'octets là où une photo en pèse des centaines
  /// de milliers. La visionneuse affiche donc d'abord un cadre vide, et
  /// c'est ce signal qui lui dit que l'image est enfin là.
  final _statusMediaCtrl = StreamController<String>.broadcast();
  Stream<String> get statusMediaEvents => _statusMediaCtrl.stream;

  /// « J'aime » ou commentaire reçu sur l'un de MES statuts.
  final _statusFeedbackCtrl = StreamController<StatusFeedback>.broadcast();
  Stream<StatusFeedback> get statusFeedbackEvents => _statusFeedbackCtrl.stream;

  /// ⚠️ AJOUTÉ — filet de sécurité pour les diffusions qui échouent
  /// définitivement.
  ///
  /// `sendStatus` et `sendSafetyCheckin` passent par `_enqueueReliable`,
  /// qui — après épuisement de son budget de tentatives (six essais sur
  /// ~180 s) — se termine par une `Future` en erreur (`StateError`), pas
  /// par un simple retour `false`. Contrairement à `sendMessage`/`sendFile`
  /// (gérés côté `mesh_provider.dart` avec un `try/catch` qui marque le
  /// message `failed` et prévient l'utilisateur), ces deux fonctions
  /// n'attrapaient rien : une diffusion de statut, ou pire, un CHECK-IN
  /// DE SÉCURITÉ qui échoue à joindre le moindre pair pendant trois
  /// minutes, levait une exception que rien, dans ce paquet, ne
  /// garantissait de rattraper.
  ///
  /// Ce flux est un filet de sécurité additif : il ne remplace pas la
  /// gestion d'erreur que l'écran appelant peut déjà faire (l'exception
  /// continue d'être relancée, `await` la verra toujours) — il donne en
  /// PLUS un point d'écoute fiable, au niveau du dépôt, pour qu'une
  /// notification de secours (`NotificationService.showSendFailed`, déjà
  /// prévue pour ce cas précis) puisse être déclenchée même si l'écran
  /// d'origine ne s'attendait pas à cet échec.
  final _criticalSendFailureCtrl = StreamController<({String kind, String messageId, String reason})>.broadcast();
  Stream<({String kind, String messageId, String reason})> get criticalSendFailureEvents =>
      _criticalSendFailureCtrl.stream;

  /// Purge les IDs de messages vus depuis trop longtemps.
  Timer? _pruneTimer;

  /// Le minuteur des annonces de routes — voir `_annoncerRoutes`.
  Timer? _routeTimer;

  /// Toutes les 6 heures, on fait le ménage dans la mémoire des messages
  /// « déjà vus » — sinon cette liste grossirait indéfiniment et
  /// ralentirait l'app avec le temps (voir [_pruneSeenIds]).
  void _startPruneTimer() {
    _pruneTimer?.cancel();
    _pruneTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _pruneSeenIds();
      unawaited(StorageService.pruneExpiredStatuses());
    });

    // ⚠️ LA CADENCE EST UN COMPROMIS, PAS UN CHIFFRE ROND.
    //
    // Trop rapide, on réveille toutes les radios à portée pour répéter
    // des informations qui n'ont pas bougé — sur une app dont l'autonomie
    // est un argument, c'est inacceptable. Trop lente, une route apprise
    // reste périmée après le départ d'un relais, et des messages partent
    // vers un chemin qui n'existe plus.
    //
    // Quarante-cinq secondes : de l'ordre du délai de grâce accordé à un
    // pair qui disparaît, pour que les deux notions vieillissent au même
    // rythme.
    _routeTimer?.cancel();
    _routeTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(_annoncerRoutes().catchError(
          (e) => debugPrint('[MeshRepo] annonce de routes: $e')));
    });
  }

  Future<void> _pruneSeenIds() async {
    await StorageService.pruneSeenMessageIds(maxAge: _seenIdMaxAge);
    _seenMessageIds = StorageService.getSeenMessageIds();

    final cutoff = DateTime.now().subtract(_seenIdMaxAge);
    _appMessageIds.removeWhere((_, seenAt) => seenAt.isBefore(cutoff));

    debugPrint('[MeshRepo] purge IDs vus: ${_seenMessageIds.length} restants, ${_appMessageIds.length} app-ids');
  }

  /// Démarre tout le système : prépare mon identité, allume le transport
  /// mesh (Bluetooth/Wi-Fi/Nearby), et se met à l'écoute de tout ce qui
  /// arrive.
  Future<void> init(String myId, String myPseudo, {
    Set<String>? interestGroups,
  }) async {
    // `_initialized` doit être posé de façon SYNCHRONE avant le premier
    // `await` : sinon, deux appels rapprochés à init() (ex. MeshBootstrap
    // au démarrage + un flux de restauration de sauvegarde juste après)
    // passent tous les deux le test `if (_initialized) return;` avant que
    // le premier ait eu la main pour le positionner, et démarrent chacun
    // leur propre transport mesh en parallèle — doubles binds de socket,
    // doubles abonnements à incomingData/peerEvents (chaque message reçu
    // alors traité deux fois), état corrompu. Observé et reproduit : deux
    // lignes "[MeshRepo] init() id=..." consécutives dès le lancement.
    if (_initialized) return;
    _initialized = true;
    _myId = myId;
    _myPseudo = myPseudo;
    _myPublicKey = await CryptoService.ensureIdentityKeyPair();
    // Protocole Signal : identité dérivée de la clé d'identité, pré-clé
    // signée prête. Sans lui (échec improbable), l'ancien chiffrement reste.
    try {
      final signal = await SignalService.demarrer(
        myId,
        identiteVerifiee: (id) => StorageService.getPeerRecord(id)?.verified ?? false,
      );
      signal?.surSessionPerdue = _demanderNouvelleSession;
    } catch (e) {
      debugPrint('[MeshRepo] Signal indisponible: $e');
    }

    debugPrint('[MeshRepo] init() id=$myId pseudo=$myPseudo groups=$interestGroups');

    _seenMessageIds = StorageService.getSeenMessageIds();
    // Les messages reçus lors d'une session précédente dont on n'avait
    // pas encore la clé. Rechargés AVANT de démarrer le mesh : le
    // premier « hello » venu peut alors les réparer immédiatement.
    _loadPendingDecryptions();

    // Configurer les serveurs Tor (directory + mailbox) AVANT startMesh.
    _transport.configureTorServers(
      directoryUrl: kDirectoryUrl,
      mailboxUrl: kMailboxUrl,
    );

    await _transport.startMesh(
      myId,
      myPseudo,
      interestGroups: interestGroups,
    );

    _transport.incomingData.listen((data) {
      _handleIncomingMessage(data).catchError((e) {
        debugPrint('[MeshRepo] erreur traitement message entrant: $e');
      });
    });

    _transport.peerEvents.listen((peer) {
      try {
        // Adapter le nombre de sauts à la densité du mesh.
        MeshRepository.updateAdaptiveHopCount(_transport.connectedPeerCount);
        if (_transport.connectedPeerCount > 0) flushPendingRelays();
        // Première connexion dans cette session → signal Nexus.
        if (_connectedThisSession.add(peer.peerId)) {
          _firstPeerCtrl.add(peer);
          _pendingFirstPeer = peer;
        }
        if (peer.publicKey == null) {
          // Fire-and-forget : un pair qui se déconnecte pendant l'envoi ne
          // doit jamais faire remonter une exception non rattrapée.
          //
          // Hello en DIFFUSION (pas de targetId) : un pair découvert par
          // NativeP2P est identifié par son ID transport (ex. adresse MAC),
          // pas par son ID Droplet. Un hello ciblé sur cet ID transport
          // serait ignoré par le destinataire (targetId ≠ son ID Droplet) —
          // l'échange de clés ne se ferait JAMAIS, et le premier message
          // chiffré échouerait. Diffusé, tout voisin direct le traite.
          unawaited(sendHello()
              .catchError((e) => debugPrint('[MeshRepo] échec hello (diffusion): $e')));
          // Un pair fraîchement rencontré n'a jamais vu mon statut ou mon
          // dernier check-in de sécurité si je les ai diffusés alors que
          // j'étais seul (0 pair connecté) — `sendStatus`/`sendSafetyCheckin`
          // n'envoient qu'une seule fois, sans réessai. On les regossipe donc
          // à chaque nouvelle rencontre plutôt que de les considérer perdus.
          unawaited(_gossipAnnouncementsOnNewPeer()
            .catchError((e) => debugPrint('[MeshRepo] échec regossip vers ${peer.peerId}: $e')));
          // Un nouveau voisin ne sait rien de ce que je sais joindre.
          unawaited(_annoncerRoutes().catchError(
              (e) => debugPrint('[MeshRepo] échec annonce de routes: $e')));
        }
      } catch (e) {
        debugPrint('[MeshRepo] erreur traitement événement pair: $e');
      }
    });

    _demarrerGarde();
    _loadPendingRelays();
    _startPruneTimer();

    debugPrint('[MeshRepo] init() completed, peers=${_transport.connectedPeerCount}');
  }

  Future<void> dispose() async {
    _pruneTimer?.cancel();
    _routeTimer?.cancel();
    _routeTimer = null;
    _battementGarde?.cancel();
    _battementGarde = null;
    // ⚠️ ON FERME LA BASE, mais on ne l'efface pas : tout l'intérêt de la
    // garde est précisément de survivre à cet arrêt.
    _garde?.fermer();
    _garde = null;
    // Les accusés en attente sont abandonnés avec leurs minuteurs : sans
    // cela, un minuteur survivait à l'arrêt du mesh et tentait un envoi
    // sur un transport déjà refermé.
    for (final t in _ackBatchTimers.values) {
      t.cancel();
    }
    _ackBatchTimers.clear();
    _ackBatches.clear();
    _queue?.stop();
    _queue = null;
    _sendOutcomes.clear();
    await _transport.stopMesh();
    _initialized = false;
  }

  // ── Accusés de réception (ACK) groupés ──────────────────────────────────
  //
  // Plutôt que de renvoyer un petit accusé « bien reçu » immédiatement
  // pour chaque message (ce qui userait la batterie pour rien si
  // plusieurs messages arrivent d'affilée), on les regroupe pendant 2
  // secondes et on envoie un seul paquet qui dit « j'ai bien reçu ces 5
  // messages-là » — comme accuser réception d'un paquet de lettres d'un
  // coup plutôt qu'une par une.

  /// ⚠️ UN LOT PAR EXPÉDITEUR, PAS UN LOT GLOBAL.
  ///
  /// La version précédente gardait UNE seule liste et UN seul minuteur,
  /// avec le destinataire capturé au moment où le minuteur démarrait.
  /// Conséquence, dès que deux personnes écrivaient dans la même fenêtre
  /// de deux secondes — ce qui est le cas ordinaire dans un groupe :
  ///
  ///   • tous les accusés partaient vers le PREMIER expéditeur, y compris
  ///     ceux qui concernaient les messages du second ;
  ///   • le second n'en recevait aucun : ses messages restaient
  ///     éternellement affichés « envoyé » alors qu'ils étaient bien
  ///     arrivés ;
  ///   • le premier recevait des accusés portant des identifiants de
  ///     messages qu'il n'avait jamais envoyés.
  ///
  /// Autrement dit, l'application affichait des états de livraison faux
  /// dans les deux sens. Chaque expéditeur a donc désormais son propre
  /// lot et son propre minuteur.
  final Map<String, List<String>> _ackBatches = {};
  final Map<String, Timer> _ackBatchTimers = {};

  void _sendAck(String targetPeerId, String originalMessageId) {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(targetPeerId)) return;
    (_ackBatches[targetPeerId] ??= []).add(originalMessageId);
    _ackBatchTimers[targetPeerId] ??= Timer(
      const Duration(milliseconds: 200),
      () => _flushAckBatch(targetPeerId),
    );
  }

  void _flushAckBatch(String targetPeerId) {
    final lot = _ackBatches.remove(targetPeerId);
    _ackBatchTimers.remove(targetPeerId)?.cancel();
    if (lot == null || lot.isEmpty) return;
    final batchPayload = utf8.encode(lot.join(','));
    final packet = Uint8List(2 + batchPayload.length);
    packet[0] = 0;
    packet[1] = kAckType;
    packet.setRange(2, packet.length, batchPayload);
    // Fire-and-forget : le pair a pu se déconnecter entre l'ACK et ce flush
    // 2s plus tard — un échec de tous les transports ne doit jamais
    // remonter comme exception non rattrapée dans ce callback de Timer.
    unawaited(() async {
      try {
        final ok = await _transport.sendToPeer(targetPeerId, packet);
        if (!ok) {
          debugPrint('[MeshRepo] lot d\'ACK non parti vers $targetPeerId');
        }
      } catch (e) {
        debugPrint('[MeshRepo] échec envoi ACK batch à $targetPeerId: $e');
      }
    }());
  }

  // ── Messages entrants ────────────────────────────────────────────────────

  /// Résout la clé publique connue d'un pair (connecté ou persistée). Si
  /// elle est absente, relance une annonce de clé et attend brièvement
  /// [timeout] qu'elle arrive avant d'abandonner.
  Future<String?> _resolvePeerPublicKey(String peerId, {Duration timeout = const Duration(milliseconds: 500)}) async {
    String? key = _peerPublicKeyFromCaches(peerId);
    if (key != null) return key;

    unawaited(sendHello(targetId: peerId)
        .catchError((e) => debugPrint('[MeshRepo] échec hello vers $peerId: $e')));

    final completer = Completer<void>();
    final sub = peerKeyReadyEvents.listen((readyId) {
      if (readyId == peerId && !completer.isCompleted) completer.complete();
    });
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    timer.cancel();
    await sub.cancel();

    return _peerPublicKeyFromCaches(peerId);
  }

  /// Déchiffre `content` si `encrypted` est vrai (voir enveloppe wire `e`/`n`),
  /// en utilisant la clé publique connue de [senderId]. Retourne un message
  /// de substitution si le déchiffrement échoue (clé inconnue, tag invalide).
  /// Exposé publiquement car `MeshNotifier` (état UI en mémoire) et
  /// `MeshRepository` (persistance) décodent chacun l'enveloppe reçue.
  Future<String> resolveIncomingContent({
    required String? senderId,
    required String content,
    required bool encrypted,
    required String? nonce,
    String? targetId,
  }) async {
    if (!encrypted || senderId == null || nonce == null) return content;

    final typeSignal = ChiffreSignal.typeDepuisMarqueur(nonce);
    if (typeSignal != null) {
      // ⚠️ UN MESSAGE QUI NE M'EST PAS DESTINÉ N'EST JAMAIS DÉCHIFFRÉ : je ne
      // fais que le relayer. Essayer ferait croire à une session perdue avec
      // son auteur, et lui ferait rouvrir une session pour rien.
      if (targetId != null && targetId != _myId) return content;
      final signal = SignalService.instance;
      if (signal == null) return kUnreadableMessage;
      var doublon = false;
      final clair = await signal.dechiffrerTexte(senderId, content, typeSignal,
          siDoublon: () => doublon = true);
      if (doublon) return kDoublonSignal;
      return clair ?? kUnreadableMessage;
    }

    var peerPublicKey = _peerPublicKeyFromCaches(senderId);

    // ⚠️ Le repli qui manquait, et qui explique le fameux « message
    // illisible ».
    //
    // Le chemin d'ENVOI, lui, savait déjà réclamer la clé publique du
    // pair et l'attendre (`_resolvePeerPublicKey` envoie un « hello » et
    // patiente deux secondes). Le chemin de RÉCEPTION, non : il se
    // contentait de regarder dans son cache et, si la clé n'y était pas
    // encore, déclarait le message définitivement illisible.
    //
    // Or c'est un cas parfaitement ordinaire : un message relayé par un
    // tiers arrive souvent AVANT qu'on ait échangé quoi que ce soit avec
    // son auteur, qu'on n'a peut-être même jamais croisé directement.
    // Le texte de substitution était alors ENREGISTRÉ à la place du vrai
    // message — donc perdu pour de bon, même une fois la clé reçue une
    // seconde plus tard.
    peerPublicKey ??= await _resolvePeerPublicKey(senderId);

    final sharedKey =
        await CryptoService.sharedKeyWithPeer(senderId, peerPublicKey);
    final decrypted = sharedKey != null
        ? await CryptoService.decrypt(sharedKey, content, nonce)
        : null;
    if (decrypted != null) return decrypted;

    // Toujours rien : on garde le message chiffré de côté et on
    // réessaiera dès que la clé de cet auteur arrivera (voir
    // `_retryPendingDecryptions`). Le message reste affiché comme
    // illisible en attendant, mais il n'est plus perdu.
    _pendingDecryptions.add((
      senderId: senderId,
      cipherText: content,
      nonce: nonce,
    ));
    if (_pendingDecryptions.length > 200) _pendingDecryptions.removeAt(0);
    unawaited(_savePendingDecryptions());

    return kUnreadableMessage;
  }

  /// Le texte affiché à la place d'un message qu'on n'arrive pas encore à
  /// déchiffrer. Exposé pour que la reprise puisse le reconnaître.
  /// Renvoyé par [resolveIncomingContent] pour une COPIE d'un message
  /// Signal déjà reçu par un autre chemin (mesh et Internet) : à ignorer.
  static const String kDoublonSignal = '\u0000doublon-signal';

  static const String kUnreadableMessage =
      '🔒 Message illisible (clé de chiffrement manquante)';

  /// Messages reçus chiffrés dont la clé n'était pas encore connue.
  final List<({String senderId, String cipherText, String nonce})>
      _pendingDecryptions = [];

  /// Où cette liste survit à la fermeture de l'application.
  static const String _pendingDecryptionsKey = 'pending_decryptions';

  /// ⚠️ POURQUOI CETTE LISTE DOIT SURVIVRE À UN REDÉMARRAGE.
  ///
  /// Le texte de substitution (« 🔒 Message illisible ») est ce qui est
  /// ENREGISTRÉ à la place du message, en attendant la clé. Le vrai
  /// contenu, lui, n'existe plus que sous forme chiffrée, ici, en
  /// mémoire vive.
  ///
  /// Tant que l'app restait ouverte, la reprise fonctionnait. Mais si
  /// elle se fermait avant que la clé n'arrive — ce qui, dans une app
  /// mesh, est le cas le plus fréquent : on reçoit un message relayé par
  /// un tiers, on range son téléphone, et on ne croise l'auteur que le
  /// lendemain — le chiffré disparaissait avec le processus. Le message
  /// restait alors barré d'un cadenas POUR TOUJOURS, alors que tout ce
  /// qui manquait était une clé qui finissait par arriver.
  ///
  /// Ce n'était donc pas un affichage désagréable : c'était une PERTE DE
  /// DONNÉES définitive, et silencieuse.
  ///
  /// Conserver ces octets sur le disque n'affaiblit rien : ils sont déjà
  /// chiffrés, et sans la clé du pair ils ne disent rien de plus à qui
  /// lirait le stockage qu'ils n'en disaient sur le réseau.
  Future<void> _savePendingDecryptions() async {
    try {
      await StorageService.setString(
        _pendingDecryptionsKey,
        jsonEncode([
          for (final p in _pendingDecryptions)
            {'s': p.senderId, 'c': p.cipherText, 'n': p.nonce}
        ]),
      );
    } catch (e) {
      debugPrint('[MeshRepo] sauvegarde des messages en attente échouée: $e');
    }
  }

  /// Relit la liste au démarrage.
  void _loadPendingDecryptions() {
    try {
      final brut = StorageService.getString(_pendingDecryptionsKey);
      if (brut == null || brut.isEmpty) return;
      for (final e in jsonDecode(brut) as List) {
        final m = e as Map<String, dynamic>;
        final s = m['s'], c = m['c'], n = m['n'];
        if (s is! String || c is! String || n is! String) continue;
        _pendingDecryptions.add((senderId: s, cipherText: c, nonce: n));
      }
      debugPrint('[MeshRepo] ${_pendingDecryptions.length} message(s) en '
          'attente de clé rechargé(s)');
    } catch (e) {
      debugPrint('[MeshRepo] relecture des messages en attente échouée: $e');
    }
  }

  /// Rejoue le déchiffrement des messages mis de côté, maintenant que la
  /// clé publique de [peerId] est connue.
  ///
  /// Appelé à chaque « hello » reçu. Sans cette reprise, un message
  /// arrivé une seconde trop tôt resterait barré d'un cadenas pour
  /// toujours, alors que tout ce qu'il manquait était une clé qui est
  /// arrivée juste après.
  Future<void> _retryPendingDecryptions(String peerId) async {
    if (_pendingDecryptions.isEmpty) return;
    final mine =
        _pendingDecryptions.where((p) => p.senderId == peerId).toList();
    if (mine.isEmpty) return;
    _pendingDecryptions.removeWhere((p) => p.senderId == peerId);

    final peerPublicKey = _peerPublicKeyFromCaches(peerId);
    final sharedKey =
        await CryptoService.sharedKeyWithPeer(peerId, peerPublicKey);
    if (sharedKey == null) {
      // La clé n'est toujours pas exploitable : on remet les chiffrés en
      // attente plutôt que de les jeter. Les avoir retirés de la liste
      // avant d'essayer évite qu'un second « hello » arrivé pendant le
      // déchiffrement ne traite les mêmes messages en double ; encore
      // faut-il les rendre si l'essai n'aboutit pas.
      _pendingDecryptions.addAll(mine);
      return;
    }

    for (final entry in mine) {
      final clear = await CryptoService.decrypt(
          sharedKey, entry.cipherText, entry.nonce);
      if (clear == null) continue;
      // On retrouve le message à réparer par son texte de substitution et
      // son auteur : l'identifiant applicatif n'est pas conservé ici, et
      // deux messages illisibles du même auteur se valent de toute façon
      // — le premier réparé prend la première place libre.
      final broken = StorageService.getMessages()
          .where((m) => m.senderId == peerId && m.content == kUnreadableMessage)
          .firstOrNull;
      if (broken == null) continue;
      await StorageService.saveMessage(broken.copyWith(content: clear));
      _repairedMessagesCtrl.add(broken.id);
    }
    // La liste sur le disque doit refléter ce qui vient d'être réparé,
    // sans quoi les mêmes chiffrés reviendraient au prochain démarrage.
    await _savePendingDecryptions();
  }

  /// Prévient l'interface qu'un message illisible vient d'être réparé.
  final _repairedMessagesCtrl = StreamController<String>.broadcast();
  Stream<String> get repairedMessageEvents => _repairedMessagesCtrl.stream;

  /// Chiffre [plaintext] pour [targetId] avec la clé partagée dérivée de sa
  /// clé publique X25519 (attend brièvement l'échange de clés si besoin).
  /// Lève une exception si la clé publique reste introuvable — pas de repli
  /// silencieux en clair pour un contenu destiné à un pair précis.
  Future<(String content, String? nonce, bool encrypted)> _encryptForPeer(
    String targetId,
    String plaintext,
  ) async {
    // Signal d'abord, avec qui le lit ; l'ancien chiffrement sinon.
    final signal = SignalService.instance;
    if (signal != null) {
      final chiffre = await signal.chiffrerTexte(targetId, plaintext);
      if (chiffre != null) return (chiffre.contenu, chiffre.marqueur, true);
      // Peut-être un contact en ligne qui a publié ses clés : le message
      // suivant en profitera.
      unawaited(signal.decouvrirEnLigne(targetId));
    }
    final peerPublicKey = await _resolvePeerPublicKey(targetId);
    final sharedKey = await CryptoService.sharedKeyWithPeer(targetId, peerPublicKey);
    if (sharedKey == null) {
      throw StateError(
        'Clé publique de $targetId inconnue — chiffrement impossible pour le moment',
      );
    }
    final (cipherText, nonce) = await CryptoService.encrypt(sharedKey, plaintext);
    return (cipherText, nonce, true);
  }

  /// Chiffre [plaintext] pour un dépôt dans la mailbox .onion d'un pair
  /// distant — même chiffrement de bout en bout que pour un envoi mesh
  /// direct (voir [_encryptForPeer]).
  ///
  /// ⚠️ POURQUOI CETTE MÉTHODE EXISTE ALORS QUE [_encryptForPeer] EXISTE
  /// DÉJÀ. Le serveur mailbox est un tiers non fiable (Railway, hors de
  /// notre contrôle) : c'est précisément le genre de destination pour
  /// laquelle le chiffrement de bout en bout compte le plus. Avant cette
  /// méthode, `MeshNotifier._tryMailboxSend` déposait le contenu EN CLAIR
  /// — la clé de chiffrement n'était jamais sollicitée sur ce chemin. Cette
  /// fonction publique est le seul point d'entrée que `MeshNotifier` doit
  /// utiliser pour la mailbox, justement pour qu'un texte en clair n'y
  /// reparte plus jamais.
  ///
  /// Retourne `null` si la clé publique du destinataire reste introuvable
  /// (jamais rencontré, aucun échange de clé possible) — dans ce cas
  /// l'appelant doit renoncer au dépôt plutôt que d'envoyer en clair.
  Future<(String cipherText, String nonce)?> encryptForMailbox(
    String targetId,
    String plaintext,
  ) async {
    try {
      final (cipherText, nonce, encrypted) =
          await _encryptForPeer(targetId, plaintext);
      if (!encrypted || nonce == null) return null;
      return (cipherText, nonce);
    } catch (e) {
      // L'erreur était avalée sans trace : un dépôt mailbox abandonné pour
      // clé inconnue était impossible à distinguer d'un envoi jamais tenté.
      debugPrint('[MeshRepo] encryptForMailbox($targetId) : $e');
      return null;
    }
  }

  /// Taille maximale d'un fichier acceptée sur le chemin mailbox .onion,
  /// en octets.
  ///
  /// ⚠️ CETTE LIMITE N'A RIEN D'ARBITRAIRE — ELLE PROTÈGE UN SERVEUR
  /// PARTAGÉ, EN MÉMOIRE, SANS BASE DE DONNÉES.
  ///
  /// `droplet_mailbox/lib/server.dart` garde chaque message dans une
  /// simple `Map` en RAM tant que son destinataire ne l'a pas récupéré
  /// (jusqu'à 7 jours) — rien n'est jamais écrit sur disque. Y laisser
  /// transiter des photos ou des vidéos sans limite gonflerait cette
  /// mémoire pour TOUT LE MONDE qui partage ce même serveur Railway, au
  /// premier envoi resté en attente. 256 Kio laisse passer un message
  /// vocal ou un petit fichier (un document, une image très compressée)
  /// sans mettre en péril le service pour les autres.
  static const int kMailboxMaxFileBytes = 256 * 1024;

  /// Chiffre un petit fichier pour un dépôt dans la mailbox .onion — même
  /// principe que [encryptForMailbox], pour des octets plutôt qu'un texte.
  /// Renvoie `null` si la clé publique du destinataire reste introuvable.
  Future<(String cipherB64, String nonceB64)?> encryptFileForMailbox(
    String targetId,
    Uint8List plainBytes,
  ) async {
    try {
      final (cipher, nonce) = await _encryptBytesForPeer(targetId, plainBytes);
      return (base64Encode(cipher), base64Encode(nonce));
    } catch (_) {
      return null;
    }
  }

  /// Déchiffre un fichier reçu par la mailbox .onion — symétrique de
  /// [encryptFileForMailbox].
  ///
  /// Même repli que [resolveIncomingContent] : si la clé publique de
  /// l'expéditeur n'est pas encore en cache, on la redemande activement
  /// plutôt que de déclarer le fichier définitivement illisible pour un
  /// simple problème de timing.
  Future<Uint8List?> resolveIncomingFileBytes({
    required String senderId,
    required Uint8List cipher,
    required Uint8List nonce,
  }) async {
    try {
      final typeSignal = _typeSignalOctets(nonce);
      if (typeSignal != null) {
        return await _dechiffrerOctetsSignal(senderId, cipher, typeSignal);
      }
      var peerPublicKey = _peerPublicKeyFromCaches(senderId);
      peerPublicKey ??= await _resolvePeerPublicKey(senderId);
      final sharedKey =
          await CryptoService.sharedKeyWithPeer(senderId, peerPublicKey);
      if (sharedKey == null) return null;
      return await CryptoService.decryptBytes(sharedKey, cipher, nonce);
    } catch (_) {
      return null;
    }
  }

  /// Un accusé reçu EN LIGNE (boîte aux lettres) : même effet qu'un accusé
  /// mesh — compteur de livraison et flux `ackEvents`, ou flux `readEvents`
  /// pour une lecture. L'interface ne fait aucune différence.
  void enregistrerAccuseEnLigne(String messageId, {required bool lu, String? de}) {
    if (messageId.isEmpty) return;
    if (lu) {
      _noterLecture(messageId, de);
    } else {
      _noterRecu(messageId, de ?? '');
    }
  }

  /// Déchiffre une charge de boîte aux lettres SANS effet de bord.
  ///
  /// ⚠️ PAS `resolveIncomingContent` pour un accusé : en cas d'échec, celle-ci
  /// met la charge en file de « déchiffrement en attente » pour réparer un
  /// MESSAGE affiché plus tard — or un accusé n'est jamais affiché. Ici, un
  /// échec renvoie simplement `null`.
  Future<String?> dechiffrerDepuisMailbox(
    String senderId,
    String cipherText,
    String nonce,
  ) async {
    try {
      final typeSignal = ChiffreSignal.typeDepuisMarqueur(nonce);
      if (typeSignal != null) {
        return await SignalService.instance?.dechiffrerTexte(senderId, cipherText, typeSignal);
      }
      final cle = await CryptoService.sharedKeyWithPeer(
          senderId, _peerPublicKeyFromCaches(senderId));
      if (cle == null) return null;
      return await CryptoService.decrypt(cle, cipherText, nonce);
    } catch (_) {
      return null;
    }
  }

  /// La clé publique de ce pair est-elle connue ? Sans elle, rien ne peut
  /// lui être chiffré — donc rien ne peut partir par la boîte aux lettres.
  bool clePubliqueConnue(String peerId) => _peerPublicKeyFromCaches(peerId) != null;

  String? _peerPublicKeyFromCaches(String peerId) {
    for (final peer in _transport.connectedPeers) {
      if (peer.peerId == peerId && peer.publicKey != null) return peer.publicKey;
    }
    for (final peer in StorageService.getKnownPeers()) {
      if (peer.peerId == peerId && peer.publicKey != null) return peer.publicKey;
    }
    return null;
  }

  /// LE cœur du fichier : chaque fois qu'un paquet de données arrive de
  /// n'importe quel transport (Bluetooth/Wi-Fi/Nearby), il passe par ici.
  /// Cette fonction regarde ce que c'est (un message ? un accusé de
  /// réception ? un fichier ? un signal de frappe ? un statut ?) et
  /// l'aiguille vers le bon traitement — comme un employé de tri postal
  /// qui ouvre chaque enveloppe pour voir dans quel casier la ranger.
  Future<void> _handleIncomingMessage(MeshIncomingData data) async {
    if (_seenMessageIds.contains(data.messageId)) return;
    _seenMessageIds.add(data.messageId);
    StorageService.addSeenMessageId(data.messageId);

    if (data.data.length < 2) return;
    final int hopCount = data.data[0];
    final int msgType = data.data[1];

    if (msgType == kAckType) {
      _handleAck(data);
      return;
    }

    if (msgType == kRouteAnnounceType) {
      _recevoirRoutes(data);
      return;
    }

    // ── Synchronisation différentielle des statuts ──────────────────
    //
    // Ces deux échanges ne sont JAMAIS relayés : ils ne concernent que
    // les deux appareils qui viennent de se rencontrer. Une offre
    // relayée à travers le mesh proposerait à des inconnus des statuts
    // qu'on ne leur enverra pas, et déclencherait une avalanche de
    // demandes sans destinataire.
    if (msgType == kSyncOfferType) {
      unawaited(_handleSyncOffer(data).catchError(
          (e) => debugPrint('[MeshRepo] offre de synchro: $e')));
      return;
    }
    if (msgType == kSyncRequestType) {
      unawaited(_handleSyncRequest(data).catchError(
          (e) => debugPrint('[MeshRepo] demande de synchro: $e')));
      return;
    }

    if (msgType == kNexusEventType) {
      try {
        final json = jsonDecode(utf8.decode(data.data.sublist(2)))
            as Map<String, dynamic>;
        final event = NexusEvent.fromJson(json);
        _nexusEventCtrl.add((peerId: data.peerId, event: event));
        debugPrint('[MeshRepo] Nexus reçu: seed=${event.seed.substring(0, 8)}...');
      } catch (e) {
        debugPrint('[MeshRepo] erreur parsing Nexus: $e');
      }
      return;
    }

    if (msgType >= kCallOffer && msgType <= kCallHangUp) return;

    if (msgType == kFileTransferType) {
      await _handleFileTransfer(data, hopCount);
      return;
    }

    if (msgType == kFileChunkType) {
      await _handleFileChunk(data, hopCount);
      return;
    }

    if (msgType != kTextMessageType) return;
    if (data.data.length < 3) return;
    final Uint8List contentBytes = data.data.sublist(2);

    try {
      final raw = utf8.decode(contentBytes);
      String content;
      String? replyToId;
      String? senderId;
      String? appMsgId;
      String? targetId;
      String? groupId;
      String? kind;
      int? groupCounter;
      String? nonce;
      String? effect;
      // Empreinte de photo de profil annoncée dans un « hello » (`av`).
      String? avatarHash;
      // Paquet de clés Signal annoncé dans un « hello » (`sg`).
      Map<String, dynamic>? paquetSignal;
      // L'auteur d'origine d'un message transféré (`fw`).
      String? transfereDe;
      // Index de l'option choisie — uniquement pour `kind == 'poll_vote'`
      // (champ `o`, pour ne pas se confondre avec `appMsgId` qui porte
      // déjà l'ID du sondage voté sous le nom `m`, comme le fait
      // `reaction` avec l'ID du message réagi).
      int? pollOption;
      // Le trajet signé par les relais successifs (champ `p`).
      List<String>? chemin;
      try {
        final parsed = json.decode(raw) as Map<String, dynamic>;
        chemin = (parsed['p'] as List?)?.cast<String>();
        content = parsed['c'] as String? ?? raw;
        replyToId = parsed['r'] as String?;
        senderId = parsed['s'] as String?;
        appMsgId = parsed['m'] as String?;
        targetId = parsed['t'] as String?;
        groupId = parsed['g'] as String?;
        kind = parsed['k'] as String?;
        groupCounter = parsed['ctr'] as int?;
        nonce = parsed['n'] as String?;
        effect = parsed['ef'] as String?;
        pollOption = parsed['o'] as int?;
        avatarHash = parsed['av'] as String?;
        transfereDe = parsed['fw'] as String?;
        final sg = parsed['sg'];
        if (sg is Map) paquetSignal = Map<String, dynamic>.from(sg);

        // Les messages de groupe sont déchiffrés via leur sender-key
        // (voir _handleGroupContent), pas via le secret partagé 1:1.
        if (groupId == null) {
          content = await resolveIncomingContent(
            senderId: senderId,
            content: content,
            encrypted: parsed['e'] as bool? ?? false,
            nonce: nonce,
            targetId: targetId,
          );
        }
      } catch (_) {
        content = raw;
      }

      // Copie d'un message Signal déjà reçu par un autre chemin.
      if (content == kDoublonSignal) return;

      // ⚠️ BLOQUÉ, POUR DE VRAI. Le blocage était enregistré mais vérifié
      // nulle part : un contact bloqué écrivait, et ses accusés, réactions,
      // frappe et statuts arrivaient comme avant. Ici, rien de ce qu'il NOUS
      // adresse n'est consommé — ni message, ni accusé, ni réaction, ni
      // frappe, ni photo, ni statut, ni demande de notre photo.
      //
      // Deux exceptions, comme WhatsApp : ce qui arrive dans un GROUPE (ses
      // messages y restent lisibles, et les clés de groupe doivent passer
      // pour que le groupe fonctionne), et le RELAIS : ce qui est destiné à
      // d'autres continue de transiter par nous, sans être lu. Le maillage
      // ne dépend pas de nos blocages.
      if (senderId != null &&
          senderId != _myId &&
          groupId == null &&
          !_typesDeGroupe.contains(kind) &&
          (targetId == null || targetId == _myId) &&
          StorageService.isContactBlocked(senderId)) {
        if (targetId == null) {
          _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        }
        return;
      }

      if (groupId != null && kind == null) {
        await _handleGroupContent(
          data: data,
          hopCount: hopCount,
          groupId: groupId,
          senderId: senderId,
          appMsgId: appMsgId,
          cipherText: content,
          nonce: nonce,
          counter: groupCounter,
          replyToId: replyToId,
          effect: effect,
        );
        return;
      }

      if (kind == 'group_sync' || kind == 'group_sender_key') {
        if (senderId != null && senderId != _myId && targetId == _myId) {
          final payload = jsonDecode(content) as Map<String, dynamic>;
          if (kind == 'group_sync') {
            await _applyGroupSync(senderId, payload);
          } else {
            await _applyIncomingSenderKey(payload);
          }
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Quelqu'un a scanné le code d'un groupe que j'administre.
      if (kind == 'group_join_request') {
        if (senderId != null && senderId != _myId && targetId == _myId) {
          try {
            final payload = jsonDecode(content) as Map<String, dynamic>;
            final groupId = payload['groupId'] as String?;
            final jeton = payload['jeton'] as String?;
            final groupe = groupId == null ? null : StorageService.getGroup(groupId);
            // Trois conditions, et aucune réponse en cas d'échec : un
            // jeton refusé ne doit rien apprendre à qui l'essaie.
            if (groupId != null &&
                jeton != null &&
                groupe != null &&
                groupe.isAdmin(_myId) &&
                !groupe.isActiveMember(senderId) &&
                !StorageService.isContactBlocked(senderId) &&
                JetonsInvitation.accepter(groupId, jeton)) {
              await addGroupMember(groupId: groupId, peerId: senderId);
            }
          } catch (e) {
            debugPrint('[MeshRepo] demande d entree illisible: $e');
          }
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Le salon vocal d'un groupe : ouvert, entrée, sortie, réaction.
      if (kind == 'group_voice_room') {
        if (senderId != null && senderId != _myId) {
          try {
            final payload = jsonDecode(content) as Map<String, dynamic>;
            final groupe = payload['g'] as String?;
            final action = payload['a'] as String?;
            if (groupe != null &&
                action != null &&
                StorageService.getGroup(groupe)?.isActiveMember(senderId) == true &&
                !StorageService.isContactBlocked(senderId)) {
              switch (action) {
                case 'ouvrir':
                  SalonsVocaux.ouvrir(groupId: groupe, par: senderId);
                case 'entrer':
                  SalonsVocaux.entrer(groupe, senderId);
                case 'sortir':
                  SalonsVocaux.sortir(groupe, senderId);
                case 'reagir':
                  final emoji = payload['e'] as String?;
                  if (emoji != null && emoji.length <= 8) {
                    SalonsVocaux.reagir(
                      groupId: groupe,
                      auteur: senderId,
                      emoji: emoji,
                    );
                  }
              }
            }
          } catch (e) {
            debugPrint('[MeshRepo] annonce de salon illisible : $e');
          }
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      if (kind == 'group_call_invite') {
        if (senderId != null && senderId != _myId && targetId == _myId) {
          try {
            final payload = jsonDecode(content) as Map<String, dynamic>;
            final groupe = payload['g'] as String?;
            final participants = (payload['p'] as List?)?.whereType<String>().toList();
            // ⚠️ SEUL UN MEMBRE DU GROUPE PEUT FAIRE SONNER, et seulement pour
            // un appel récent (une invitation passée par la boîte aux lettres
            // peut arriver bien après la fin de l'appel).
            if (groupe != null &&
                participants != null &&
                StorageService.getGroup(groupe)?.isActiveMember(senderId) == true &&
                invitationRecente(payload['ts'] as String?)) {
              _groupCallInviteCtrl.add((groupId: groupe, fromPeerId: senderId, participants: participants));
            }
          } catch (e) {
            debugPrint('[MeshRepo] invitation d\'appel de groupe illisible: $e');
          }
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Nouvelle session Signal demandée : l'avoir déchiffrée (message
      // d'ouverture) a déjà remplacé l'ancienne. Rien d'autre à faire.
      if (kind == 'sgreset') {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Signal de frappe : on ne stocke rien, on le relaie pour le multi-hop
      // et on prévient l'UI (jamais nos propres signaux).
      if (kind == 'typing') {
        if (groupId != null) {
          // Dans un groupe : jamais pris pour une frappe en tête-à-tête.
          if (senderId != null && senderId != _myId) {
            signalerFrappeEnLigne(senderId, groupId: groupId);
          }
        } else if (senderId != _myId && (targetId == null || targetId == _myId)) {
          _typingCtrl.add(senderId ?? data.peerId);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Échange de clés : `c` porte la clé publique X25519 de l'émetteur.
      // Toujours traité si on est concerné (broadcast ou ciblé), puis relayé
      // pour atteindre l'émetteur si nous ne sommes pas voisins directs.
      if (kind == 'hello') {
        if (senderId != null && senderId != _myId &&
            (targetId == null || targetId == _myId)) {
          final signal = SignalService.instance;
          if (signal != null && paquetSignal != null) {
            unawaited(signal.retenirPaquet(senderId, paquetSignal));
          }
          _handleHello(senderId, content,
              viaPeerId: data.peerId, hopCount: hopCount, avatarHash: avatarHash);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Demande de photo de profil : on n'y répond que pour un contact.
      if (kind == 'avreq') {
        if (senderId != null && senderId != _myId && targetId == _myId) {
          unawaited(_envoyerMonAvatarA(senderId).then<void>((_) {}, onError: (Object e) {
      debugPrint('[MeshRepo] photo de profil non envoyée: $e');
    }));
        } else if (targetId != null && targetId != _myId) {
          _relayOrDefer(data.messageId, data.data, hopCount,
              excludePeerId: data.peerId, targetId: targetId);
        }
        return;
      }

      // Accusé de RÉCEPTION d'un message de groupe : `c` porte son ID. Le
      // membre qui l'a reçu prévient l'auteur (voir `MeshNotifier`).
      if (kind == 'recu') {
        if (senderId != null && senderId != _myId && content.isNotEmpty &&
            (targetId == null || targetId == _myId)) {
          _noterRecu(content, senderId);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Accusé de lecture : `c` porte l'ID du message lu. On prévient l'UI
      // (jamais pour nos propres messages) puis on relaie pour le multi-hop.
      if (kind == 'read') {
        final readMsgId = content;
        if (senderId != _myId && readMsgId.isNotEmpty &&
            (targetId == null || targetId == _myId)) {
          _noterLecture(readMsgId, senderId);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Réaction emoji : `c` porte l'ID du message, `m` l'emoji.
      if (kind == 'reaction') {
        final reactMsgId = content;
        final emoji = appMsgId ?? ''; // 'm' est déjà parsé dans appMsgId
        if (senderId != _myId && reactMsgId.isNotEmpty && emoji.isNotEmpty &&
            (targetId == null || targetId == _myId)) {
          _reactionCtrl.add((messageId: reactMsgId, emoji: emoji));
          _reactionAuteurCtrl.add(
              (messageId: reactMsgId, emoji: emoji, auteurId: senderId));
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Vote de sondage : `c` porte l'ID du sondage, `s` l'auteur du vote,
      // `o` l'index de l'option choisie.
      //
      // ⚠️ ACCEPTÉ AUSSI VENANT DE `_myId` — CONTRAIREMENT À `reaction`.
      // Un vote émis par CE téléphone repasse par ce même chemin de
      // réception dès qu'il est relayé en écho par un pair proche
      // (broadcast local) : c'est ce qui permet à `pollVotesProvider` de
      // n'avoir qu'UN SEUL point d'entrée pour appliquer un vote, qu'il
      // vienne de soi ou d'un pair — au lieu de dupliquer la logique de
      // fusion entre « mon vote local » et « un vote reçu ».
      if (kind == 'poll_vote') {
        final voterId = senderId ?? '';
        // Message 1:1 : déjà déchiffré plus haut par `resolveIncomingContent`
        // (elle tourne pour tout message dont `groupId == null`, quel que
        // soit `kind`). Message de groupe : encore chiffré à ce stade — la
        // sender-key du groupe n'est déchiffrée qu'ICI, comme pour `edit`.
        var pollId = content;
        if (groupId != null && senderId != null && nonce != null && groupCounter != null) {
          final group = StorageService.getGroup(groupId);
          if (group != null && group.isActiveMember(_myId)) {
            pollId = await _decryptGroupContent(
                groupId, senderId, content, nonce, groupCounter);
          }
        }
        if (pollId.isNotEmpty && voterId.isNotEmpty && pollOption != null &&
            (targetId == null || targetId == _myId)) {
          _pollVoteCtrl.add((
            pollId: pollId,
            voterId: voterId,
            optionIndex: pollOption,
          ));
        }
        if (senderId != _myId) {
          _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        }
        return;
      }

      // Modification de message : `m` porte l'ID du message, `c` le
      // nouveau contenu. Relayé pour le multi-hop.
      if (kind == 'edit') {
        final editMsgId = appMsgId ?? '';
        if (senderId != null && editMsgId.isNotEmpty &&
            (targetId == null || targetId == _myId)) {
          String newContent = content;
          // Les messages de groupe sont chiffrés avec la sender-key du groupe.
          if (groupId != null && nonce != null && groupCounter != null) {
            final group = StorageService.getGroup(groupId);
            if (group != null && group.isActiveMember(_myId)) {
              newContent = await _decryptGroupContent(
                  groupId, senderId, content, nonce, groupCounter);
            }
          }
          _editCtrl.add((
            messageId: editMsgId,
            newContent: newContent,
            senderId: senderId,
          ));
          debugPrint('[MeshRepo] édit reçu: $editMsgId');
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Épinglage : `m` porte l'ID du message, `c` « 1 » ou « 0 »,
      // chiffré comme une modification — savoir CE QU'on épingle dans une
      // conversation en dit autant que le message lui-même.
      if (kind == 'pin') {
        final pinMsgId = appMsgId ?? '';
        if (senderId != null && senderId != _myId && pinMsgId.isNotEmpty &&
            (targetId == null || targetId == _myId)) {
          String valeur = content;
          var lisible = groupId == null;
          if (groupId != null && nonce != null && groupCounter != null) {
            final group = StorageService.getGroup(groupId);
            if (group != null && group.isActiveMember(_myId)) {
              valeur = await _decryptGroupContent(
                  groupId, senderId, content, nonce, groupCounter);
              lisible = true;
            }
          }
          if (lisible && (valeur == '1' || valeur == '0')) {
            _epingleCtrl.add((
              messageId: pinMsgId,
              epingle: valeur == '1',
              senderId: senderId,
              groupId: groupId,
            ));
          }
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Accusé de vue d'un statut : `c` porte {statusId, ts}, ciblé vers
      // l'auteur du statut (comme une réaction), jamais diffusé largement.
      if (kind == 'status_feedback') {
        if (senderId != null && senderId != _myId && targetId == _myId) {
          _handleStatusFeedback(senderId, content);
        }
        _relayOrDefer(data.messageId, data.data, hopCount,
            excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      if (kind == 'status_seen') {
        if (senderId != null && senderId != _myId &&
            (targetId == null || targetId == _myId)) {
          _handleStatusSeen(senderId, content);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // Check-in de sécurité : statut public, diffusé à tout le mesh.
      if (kind == 'safety_checkin') {
        if (senderId != null && senderId != _myId) {
          _handleSafetyCheckin(senderId, content);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      // ══ LES ANNONCES DU COMPTE OFFICIEL ════════════════════════
      //
      // Trois temps : je PROPOSE mes identifiants, le voisin RÉCLAME ce
      // qui lui manque, je lui ENVOIE cela seul.
      //
      // ⚠️ ON NE RELAIE PAS CES TROIS-LÀ (`_relayOrDefer` n'est pas
      // appelé). Une négociation est une conversation entre DEUX
      // appareils : relayer une offre à tout le voisinage ferait réclamer
      // à des gens qui ne me parlaient pas, et relayer une réponse
      // enverrait des annonces à qui ne les a pas demandées. La
      // propagation se fait de proche en proche, par répétition de
      // l'échange — pas par diffusion.
      if (kind == 'annonce_offre') {
        final reponse = AnnoncesDroplet.demande(json.decode(content));
        if (reponse != null) await _envoyerBrutAuPair(data.peerId, reponse);
        return;
      }
      if (kind == 'annonce_dem') {
        for (final paquet in AnnoncesDroplet.repondre(json.decode(content))) {
          await _envoyerBrutAuPair(data.peerId, paquet);
        }
        return;
      }
      if (kind == 'annonce') {
        // ⚠️ LA SIGNATURE EST VÉRIFIÉE DANS `recevoir`, PAS ICI. Un voisin
        // n'est pas une source de confiance — c'est tout l'intérêt du
        // dispositif. Une annonce qui ne passe pas la vérification est
        // jetée sans jamais être montrée.
        final nouvelles = await AnnoncesDroplet.recevoir(
          json.decode(content),
          langue: _langueAnnonces(),
        );
        for (final a in nouvelles) {
          debugPrint('[Annonces] reçue par le maillage : ${a.id}');
        }
        return;
      }

      // Statut éphémère : public, diffusé à tout le mesh.
      if (kind == 'status') {
        if (senderId != null && senderId != _myId && (targetId == null || targetId == _myId)) {
          _handleStatus(senderId, content, appMsgId);
        }
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      if (appMsgId != null) {
        if (_appMessageIds.containsKey(appMsgId)) return;
        _appMessageIds[appMsgId] = DateTime.now();
      }

      if (senderId == _myId) return;

      // Chat dirigé : si ce message ne m'est pas destiné, on ne fait que le
      // relayer (store-and-forward) sans l'afficher.
      if (targetId != null && targetId != _myId) {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      String authorPseudo = data.peerId;
      if (senderId != null) {
        try {
          final peer = _transport.connectedPeers.firstWhere(
            (p) => p.peerId == senderId,
          );
          authorPseudo = peer.pseudo;
        } catch (_) {
          authorPseudo = senderId;
        }
      } else {
        try {
          final peer = _transport.connectedPeers.firstWhere(
            (p) => p.peerId == data.peerId,
          );
          authorPseudo = peer.pseudo;
        } catch (_) {}
      }

      final msg = MeshMessage(
        id: appMsgId ?? data.messageId,
        authorPseudo: authorPseudo,
        content: content,
        type: 'mesh',
        timestamp: DateTime.now(),
        senderId: senderId,
        targetId: targetId,
        hopCount: hopCount,
        replyToId: replyToId,
        effect: effect,
        forwardedFrom: transfereDe,
        routeInfo: (chemin == null || chemin.isEmpty)
            ? null
            : chemin.join(' → '),
      );
      StorageService.saveMessage(msg);
      _newMessageCtrl.add(msg);

      if (senderId != null && senderId != _myId) {
        _sendAck(senderId, appMsgId ?? data.messageId);
      }
    } catch (e) { debugPrint('[MeshRepo] $e'); }

    // Relais final : on arrive ici pour un message de diffusion (targetId
    // null) ou qui m'était adressé (targetId == _myId). Dans les deux cas
    // le routage ciblé n'a pas de sens (la cible est moi-même), donc on
    // relaie en diffusion pour la propagation.
    _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LA GARDE : ce qui tient les messages pendant une absence
  // ═══════════════════════════════════════════════════════════════════

  void _demarrerGarde() {
    unawaited(() async {
      try {
        _garde = await GardeMessages.ouvrir();
        debugPrint('[MeshRepo] garde ouverte, '
            '${_garde!.enAttente} remise(s) en attente');
        // Une purge à l'ouverture, et une seule : c'est le seul moment
        // où l'on est sûr que personne n'attend le résultat.
        _garde!.purger();
      } catch (e) {
        // ⚠️ LA GARDE NE DOIT JAMAIS EMPÊCHER L'APP DE DÉMARRER. Si son
        // fichier est illisible, on continue sans elle : on retombe sur
        // le comportement d'avant, qui n'est pas bon mais qui marche.
        debugPrint('[MeshRepo] garde indisponible, on continue sans: $e');
        _garde = null;
      }
    }());
    _battementGarde?.cancel();
    _battementGarde = Timer.periodic(_periodeGarde, (_) => _remettreDues());
  }

  /// Renvoie ce qui est dû aux pairs actuellement joignables.
  ///
  /// ⚠️ ON RÉÉMET LES OCTETS D'ORIGINE, sans rien reconstruire. Refaire
  /// le chiffrement des jours plus tard, avec un état cryptographique qui
  /// a pu changer, donnerait un paquet que le destinataire ne saurait pas
  /// ouvrir — et l'échec serait silencieux.
  void _remettreDues() {
    final garde = _garde;
    if (garde == null) return;
    final joignables =
        _transport.connectedPeers.map((p) => p.peerId).toSet();
    if (joignables.isEmpty) return;

    final dues = garde.dues(pairsJoignables: joignables);
    if (dues.isEmpty) return;
    debugPrint('[MeshRepo] garde : ${dues.length} remise(s) à refaire');

    for (final remise in dues) {
      // Le compteur monte AVANT l'envoi, et pas après : un envoi qui
      // n'aboutit jamais (le pair disparaît pendant l'écriture) laisserait
      // sinon la ligne due en permanence, et la remise repartirait à
      // chaque battement sans jamais reculer.
      garde.noterEnvoi(messageId: remise.messageId, pairId: remise.pairId);
      unawaited(() async {
        try {
          await _transport.sendToPeer(
            remise.pairId,
            Uint8List.fromList(remise.corps),
          );
        } catch (e) {
          debugPrint('[MeshRepo] garde : remise ${remise.messageId} '
              'vers ${remise.pairId} échouée: $e');
        }
      }());
    }
  }

  void _handleAck(MeshIncomingData data) {
    try {
      final ackPayload = utf8.decode(data.data.sublist(2));
      final ids = ackPayload.split(',');
      for (final ackedMsgId in ids) {
        // ⚠️ ON ACQUITTE POUR CE PAIR-LÀ, PAS POUR TOUS. Un message de
        // groupe reçu par Awa n'a pas été reçu par Karim ; effacer les
        // deux lignes ferait disparaître le message pour Karim sans que
        // rien ne le signale.
        _garde?.acquitter(messageId: ackedMsgId, pairId: data.peerId);
        final current = _ackCounts[ackedMsgId] ?? 0;
        _ackCounts[ackedMsgId] = current + 1;
        _transport.incrementAck();
        _ackCtrl.add(ackedMsgId);
        // Un message encore en attente de retry est confirmé reçu → arrête
        // de réessayer (le pair l'a bien eu).
        _reliableQueue.acknowledge(ackedMsgId);
      }
      debugPrint('[MeshRepo] ACK batch reçu: ${ids.length} messages');
    } catch (e) {
      debugPrint('[MeshRepo] Erreur traitement ACK: $e');
    }
  }

  // ── ANNONCE DE ROUTES (multi-saut) ──────────────────────────────────
  //
  // ⚠️ CE QUI MANQUAIT POUR QUE LE MULTI-SAUT SOIT AUTRE CHOSE QU'UNE
  // INONDATION.
  //
  // La table de routage n'était alimentée qu'avec des voisins DIRECTS
  // (`updateRoutingTable(p, p, 1, …)`). Personne n'apprenait jamais qu'un
  // pair hors de portée était joignable À TRAVERS un autre. Résultat :
  // `sendViaRoute` ne trouvait rien pour un destinataire lointain, et
  // l'appelant retombait sur la diffusion — le message partait vers TOUS
  // les voisins, à charge pour eux de le refaire suivre jusqu'à
  // épuisement du compteur de sauts.
  //
  // Ça fonctionnait, mais tout le calcul de métrique composite et le
  // Bellman-Ford de `getRoute` étaient inertes : ils ne pouvaient trouver
  // que des entrées à un saut.
  //
  // Ici, chaque appareil dit périodiquement à ses voisins CE QU'IL SAIT
  // JOINDRE. Le voisin en déduit « pour atteindre C, passe par B, deux
  // sauts » — et le message ne suit plus qu'un chemin.

  /// Combien de destinations au maximum dans une annonce.
  ///
  /// ⚠️ Ce plafond n'est pas cosmétique : une annonce voyage aussi par
  /// Bluetooth, où Droplet dispose de dix-neuf octets utiles par écriture
  /// et refuse tout paquet au-delà de 512. Douze destinations tiennent
  /// largement dedans ; une table entière, non.
  static const int _maxRoutesAnnoncees = 12;

  /// Dit aux voisins ce que je sais joindre.
  Future<void> _annoncerRoutes() async {
    if (!_initialized) return;
    final protocole = _transport.networkManager.protocol;

    // Ce que j'annonce : mes voisins directs (un saut) et les routes que
    // j'ai moi-même apprises. On n'annonce PAS le destinataire à
    // lui-même, ni moi — chacun sait déjà comment s'atteindre.
    final destinations = <String, int>{};
    for (final p in _transport.connectedPeers) {
      if (p.reconnecting) continue; // rien ne passe par un lien tombé
      destinations[p.peerId] = 1;
    }
    for (final entree in protocole.snapshotRoutes()) {
      final actuel = destinations[entree.destination];
      if (actuel == null || entree.hopCount < actuel) {
        destinations[entree.destination] = entree.hopCount;
      }
    }
    destinations.remove(_myId);
    if (destinations.isEmpty) return;

    // Les plus proches d'abord : si le plafond tronque, on garde les
    // routes les plus utiles.
    final triees = destinations.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final charge = jsonEncode({
      's': _myId,
      'r': [
        for (final e in triees.take(_maxRoutesAnnoncees))
          {'d': e.key, 'h': e.value},
      ],
    });

    final octets = utf8.encode(charge);
    final paquet = Uint8List(2 + octets.length);
    paquet[0] = 1; // ⚠️ TTL À UN : une annonce ne se relaie JAMAIS.
    // Chaque appareil réannonce ce qu'il a appris, à sa propre cadence.
    // Laisser une annonce se propager telle quelle ferait circuler des
    // distances fausses — le compteur de sauts serait celui de
    // l'émetteur d'origine, pas celui du relais.
    paquet[1] = kRouteAnnounceType;
    paquet.setRange(2, paquet.length, octets);

    await _transport.broadcastToConnectedPeers(paquet);
  }

  /// Apprend les routes annoncées par un voisin.
  void _recevoirRoutes(MeshIncomingData data) {
    try {
      final json = jsonDecode(utf8.decode(data.data.sublist(2)));
      if (json is! Map) return;
      final voisin = json['s'] as String?;
      final routes = json['r'];
      if (voisin == null || voisin == _myId || routes is! List) return;

      final protocole = _transport.networkManager.protocol;
      final metriqueVoisin = protocole.computeLinkMetric(voisin);

      for (final entree in routes) {
        if (entree is! Map) continue;
        final dest = entree['d'] as String?;
        final sauts = entree['h'];
        if (dest == null || sauts is! int) continue;
        // Une route vers moi-même n'a aucun sens, et une route vers le
        // voisin lui-même est déjà connue en direct.
        if (dest == _myId || dest == voisin) continue;
        // Au-delà du TTL, le message n'arriverait pas de toute façon :
        // annoncer une telle route ne ferait qu'encombrer la table.
        if (sauts + 1 >= kDefaultHopCount) continue;

        // La métrique s'ADDITIONNE le long du chemin : passer par un
        // voisin médiocre pour atteindre quelqu'un de proche peut coûter
        // plus cher qu'un détour par un bon lien.
        protocole.updateRoutingTable(
          dest,
          voisin,
          sauts + 1,
          metriqueVoisin * (sauts + 1),
        );
      }
    } catch (e) {
      debugPrint('[MeshRepo] annonce de routes illisible: $e');
    }
  }

  /// Ajoute mon empreinte au chemin porté par l'enveloppe.
  ///
  /// Renvoie le paquet inchangé si l'enveloppe n'est pas du JSON — un
  /// transfert de fichier, par exemple, dont l'en-tête n'est pas un
  /// objet : le relais doit continuer de fonctionner, quitte à ne pas
  /// enregistrer le chemin.
  Uint8List _signerLePassage(Uint8List paquet) {
    try {
      final enveloppe = jsonDecode(utf8.decode(paquet.sublist(2)));
      if (enveloppe is! Map<String, dynamic>) return paquet;

      final chemin = (enveloppe['p'] as List?)?.cast<String>() ?? <String>[];
      final moi = _myId.length > 8 ? _myId.substring(0, 8) : _myId;
      // Un message peut repasser par ici quand plusieurs chemins se
      // rejoignent : on ne se compte pas deux fois.
      if (chemin.contains(moi)) return paquet;
      // Borné par le TTL de toute façon ; la garde évite qu'une
      // enveloppe forgée fasse enfler le paquet.
      if (chemin.length >= kDefaultHopCount) return paquet;
      enveloppe['p'] = [...chemin, moi];

      final octets = utf8.encode(jsonEncode(enveloppe));
      final neuf = Uint8List(2 + octets.length);
      neuf[0] = paquet[0];
      neuf[1] = paquet[1];
      neuf.setRange(2, neuf.length, octets);
      return neuf;
    } catch (_) {
      return paquet;
    }
  }

  List<MeshMessage> getMessages() => StorageService.getMessages();

  final List<_PendingRelay> _pendingRelays = [];
  static const int _pendingRelaysCap = 256;

  /// Génération des relais en attente — incémentée à chaque ajout.
  int _pendingRelayGeneration = 0;

  /// Rate-limit des réponses hello : un carnet par émetteur (borné) pour
  /// éviter de répondre sans arrêt, + un plafond global de réponses par
  /// fenêtre. Sans cela, une découverte de masse (ou un appareil en boucle)
  /// déclencherait une rafale de hello broadcast de notre part.
  final Map<String, DateTime> _helloReplyCooldown = {};
  static const Duration _helloReplyPerSenderGap = Duration(seconds: 30);
  int _helloRepliesInWindow = 0;
  DateTime _helloReplyWindowStart = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _helloRepliesMaxPerWindow = 8;
  static const Duration _helloReplyWindow = Duration(seconds: 5);

  /// Nombre de sauts par défaut dans un paquet. Le premier octet de
  /// chaque message porte ce compteur, décrémenté à chaque relais. À
  /// zéro, le message est jeté — c'est le garde-fou contre les
  /// boucles infinies.
  ///
  /// ⚠️ ADAPTATIF : la valeur est calculée dynamiquement selon la
  /// densité du mesh (nombre de pairs connectés). Plus le réseau est
  /// dense, plus on autorise de sauts pour atteindre des pairs éloignés.
  static int get kDefaultHopCount => _adaptiveHopCount;
  static int _adaptiveHopCount = 5;

  /// Met à jour le nombre de sauts adaptatif selon la densité du mesh.
  static void updateAdaptiveHopCount(int connectedPeerCount) {
    if (connectedPeerCount <= 2) {
      _adaptiveHopCount = 3;
    } else if (connectedPeerCount <= 5) {
      _adaptiveHopCount = 5;
    } else {
      _adaptiveHopCount = 7;
    }
  }

  /// Envoie un message texte — soit ciblé vers une personne précise
  /// ([targetId], chiffré), soit diffusé à tout le mesh en clair si
  /// aucune cible n'est donnée.
  Future<void> sendMessage({
    required String authorPseudo,
    required String content,
    String type = 'text',
    String? imageUrl,
    String? audioUrl,
    String? replyToId,
    String? messageId,
    String? targetId,
    Set<String>? interestGroups,
    String? effect,
    /// L'auteur d'origine, quand ce message en transfère un autre : le
    /// destinataire l'affiche « Transféré », sans qu'on lui mente sur qui
    /// vient de lui écrire.
    String? forwardedFrom,
  }) async {
    final (wireContent, nonce, encrypted) = targetId != null
        ? await _encryptForPeer(targetId, content)
        : (content, null, false);

    final jsonMap = <String, dynamic>{
      'c': wireContent,
      's': _myId,
    };
    if (encrypted) {
      jsonMap['e'] = true;
      jsonMap['n'] = nonce;
    }
    if (replyToId != null) jsonMap['r'] = replyToId;
    if (messageId != null) jsonMap['m'] = messageId;
    if (targetId != null) jsonMap['t'] = targetId;
    if (effect != null) jsonMap['ef'] = effect;
    if (forwardedFrom != null) jsonMap['fw'] = forwardedFrom;
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    await _enqueueReliable(
      messageId: messageId ?? 'm-${DateTime.now().microsecondsSinceEpoch}',
      targetId: targetId ?? 'broadcast',
      data: data,
      priority: targetId != null ? MessagePriority.high : MessagePriority.normal,
      interestGroups: interestGroups,
    );
  }

  /// Annonce ma clé publique X25519 à [targetId] (ou à tout le voisinage
  /// direct si null), pour permettre au destinataire de dériver le secret
  /// partagé du chiffrement de bout en bout.
  ///
  /// ⚠️ ENVOI DIRECT : le hello contourne la file fiable (`_enqueueReliable`)
  /// pour minimiser la latence d'échange de clés. La clé est le verrou du
  /// chiffrement — chaque milliseconde de retard est un message en attente
  /// de déchiffrement. On envoie via `broadcastToConnectedPeers` (ou
  /// `sendViaRoute` si ciblé) sans retry ni backoff : si ça rate, le
  /// prochain `_resolvePeerPublicKey` relancera un hello.
  Future<void> sendHello({String? targetId}) async {
    // Contact bloqué : rien ne part vers lui.
    if (targetId != null && StorageService.isContactBlocked(targetId)) return;
    final publicKey = _myPublicKey;
    if (publicKey == null) return;
    final jsonMap = <String, dynamic>{
      'c': publicKey,
      's': _myId,
      'k': 'hello',
    };
    // L'empreinte de ma photo (16 caractères) : un pair qui ne la connaît
    // pas me la demandera (`avreq`). Absente = je n'ai pas de photo.
    final monAvatar = AvatarService.monEmpreinte();
    if (monAvatar != null) jsonMap['av'] = monAvatar;
    // Mon paquet de clés Signal : qui le reçoit sait que je lis Signal.
    try {
      final paquet = await SignalService.instance?.paquetLocal();
      if (paquet != null) jsonMap['sg'] = paquet;
    } catch (_) {}
    if (targetId != null) jsonMap['t'] = targetId;
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);

    try {
      if (targetId != null) {
        final ok = await _transport.sendViaRoute(targetId, data, type: kTextMessageType, priority: 0);
        if (!ok) {
          // Fallback : diffusion si le routage direct échoue
          await _transport.broadcastToConnectedPeers(data, type: kTextMessageType);
        }
      } else {
        await _transport.broadcastToConnectedPeers(data, type: kTextMessageType);
      }
    } catch (e) {
      debugPrint('[MeshRepo] échec hello direct: $e');
    }
  }

  /// Enregistre la clé publique X25519 d'un pair et fait le nécessaire pour
  /// que l'identité de ce pair soit cohérente sur tout le système :
  ///
  /// 1. **Apprentissage du mapping ID transport → ID Droplet** : un hello
  ///    DIRECT (aucun relais, `hopCount == kDefaultHopCount`) reçu d'un pair
  ///    encore identifié par son ID transport (ex. adresse MAC NativeP2P)
  ///    révèle la correspondance entre cet ID et son vrai ID Droplet
  ///    (`senderId`). On l'enregistre pour que `sendToPeer`, `canCallPeer`
  ///    et le routage fonctionnent avec l'ID Droplet — sinon les messages
  ///    et les appels vers un pair « MAC-identifié » échouent silencieusement.
  ///    (Restreint au trafic direct : un hello RELAYÉ porterait l'ID du
  ///    voisin immédiat, pas celui de l'émetteur original — mauvais mapping.)
  /// 2. **Réponse de clé** : si la clé de ce pair nous était inconnue, on lui
  ///    renvoie la nôtre — l'échange de clés devient BIDIRECTIONNEL même
  ///    quand la découverte n'a eu lieu que d'un seul côté. Sans cela,
  ///    `_resolvePeerPublicKey` attendrait 2 s et échouerait (premier
  ///    message chiffré perdu).
  /// Apprend la clé X25519 d'un expéditeur à partir d'une enveloppe de
  /// boîte aux lettres (champ `k`, voir `MeshNotifier._tryMailboxSend`).
  ///
  /// ⚠️ POURQUOI C'EST NÉCESSAIRE. Un message déposé en ligne par quelqu'un
  /// qu'on n'a jamais croisé ni cherché était indéchiffrable : la clé de
  /// l'expéditeur n'était connue que via un « hello » mesh, qui ne franchit
  /// pas Internet. `_pollMailbox` enregistrait alors le texte de
  /// substitution et ACQUITTAIT le dépôt — le message était perdu pour de
  /// bon. L'expéditeur joint donc sa clé, et on l'apprend ici AVANT de
  /// déchiffrer.
  ///
  /// ⚠️ CONFIANCE AU PREMIER CONTACT, JAMAIS AU-DESSUS D'UNE VÉRIFICATION.
  /// La boîte aux lettres est un serveur tiers : il pourrait substituer sa
  /// propre clé. On adopte donc la clé reçue quand on n'en connaît aucune,
  /// ou quand la fiche n'a pas été vérifiée (cas des anciennes fiches
  /// créées avec la clé onion Ed25519, qui ne marchaient de toute façon
  /// pas). Une fiche VÉRIFIÉE par numéro de sécurité n'est jamais écrasée :
  /// un changement de clé y reste une alerte, pas une mise à jour
  /// silencieuse.
  ///
  /// Délègue à [_handleHello] : même mise à jour, même invalidation de la
  /// clé partagée en cache, même reprise des déchiffrements en attente
  /// qu'une clé reçue en mesh — un seul chemin pour « apprendre une clé ».
  void apprendreCleMailbox(String senderId, String cleB64, {String? avatarHash}) {
    if (senderId.isEmpty || senderId == _myId) return;
    try {
      if (base64Decode(cleB64).length != 32) return;
    } catch (_) {
      return; // pas du base64 : charge douteuse, on n'apprend rien
    }

    final connue = _peerPublicKeyFromCaches(senderId);
    if (connue == cleB64) return;

    final fiches =
        StorageService.getKnownPeers().where((p) => p.peerId == senderId);
    final fiche = fiches.isNotEmpty ? fiches.first : null;
    if (connue != null && fiche != null && fiche.verified) {
      debugPrint('[MeshRepo] ⚠️ clé mailbox différente pour un contact '
          'VÉRIFIÉ ($senderId) — ignorée');
      return;
    }

    _handleHello(
      senderId,
      cleB64,
      transportsSiNouveau: const ['tor'],
      avatarHash: avatarHash,
      // La mailbox ne transporte pas l'empreinte : son silence ne veut pas
      // dire « ce pair a retiré sa photo ».
      annonceAvatarComplete: avatarHash != null,
    );
  }

  /// Compare l'empreinte de photo annoncée par un pair à celle qu'on détient
  /// et demande la photo si elle a changé (au plus une fois toutes les
  /// 10 minutes par pair). Un pair qui n'annonce plus rien a retiré sa photo.
  void _synchroniserAvatar(String peerId, String? empreinte,
      {bool annonceComplete = true}) {
    final connue = AvatarService.empreintePair(peerId);
    if (empreinte == null) {
      // ⚠️ UNE ANNONCE MUETTE N'EST PAS UN RETRAIT DE PHOTO.
      //
      // Le « hello » appris par la boîte aux lettres .onion ne transporte
      // pas l'empreinte : il n'a rien à dire sur la photo. L'effacer ici
      // faisait disparaître la photo de profil d'un contact dès qu'il
      // passait par Internet — le bug « la photo part avec Internet ».
      // Dans ce cas on ne supprime rien, et si on n'a aucune photo, on la
      // demande (la demande sait maintenant franchir Internet).
      if (!annonceComplete) {
        if (connue == null) _demanderAvatar(peerId);
        return;
      }
      if (connue != null) {
        unawaited(AvatarService.supprimerPair(peerId).then((_) => _peerAvatarCtrl.add(peerId)));
      }
      return;
    }
    if (empreinte == connue) return;
    _demanderAvatar(peerId);
  }

  /// Demande sa photo à [peerId] — au plus une fois toutes les dix minutes.
  ///
  /// Par le mesh d'abord ; si le mesh ne le joint pas, par la boîte aux
  /// lettres .onion, comme tout le reste (voir [_doublerParInternet]). Sans
  /// ce second chemin, un contact joint uniquement par Internet ne recevait
  /// jamais la demande, donc n'envoyait jamais sa photo.
  void _demanderAvatar(String peerId) {
    final derniere = _avatarsDemandes[peerId];
    if (derniere != null &&
        DateTime.now().difference(derniere) < const Duration(minutes: 10)) {
      return;
    }
    _avatarsDemandes[peerId] = DateTime.now();
    final demande = utf8.encode(json.encode({'k': 'avreq', 's': _myId, 't': peerId, 'c': ''}));
    final paquet = Uint8List(2 + demande.length);
    paquet[0] = kDefaultHopCount;
    paquet[1] = kTextMessageType;
    paquet.setRange(2, paquet.length, demande);
    unawaited(() async {
      var envoye = false;
      try {
        envoye = await _transport
            .sendViaRoute(peerId, paquet, type: kTextMessageType, priority: 1);
      } catch (e) {
        debugPrint('[MeshRepo] demande de photo à $peerId impossible: $e');
      }
      if (!envoye) await _doublerParInternet([peerId], paquet);
    }());
  }

  /// Ma photo vient de changer : je la pousse à mes contacts que le mesh ne
  /// joint pas. Ceux que le mesh joint la découvriront au prochain
  /// « hello », qui porte son empreinte.
  Future<void> diffuserMaPhotoAuxContacts() async {
    if (AvatarService.mesOctets() == null) return;
    for (final peerId in _contactsPourStatut().toList()) {
      if (peerId == _myId || _joignableEnMesh(peerId)) continue;
      await _envoyerMonAvatarA(peerId);
    }
  }

  void _handleHello(String senderId, String publicKeyB64,
      {String? viaPeerId,
      int hopCount = 0,
      List<String>? transportsSiNouveau,
      String? avatarHash,
      bool annonceAvatarComplete = true}) {
    _synchroniserAvatar(senderId, avatarHash,
        annonceComplete: annonceAvatarComplete);
    CryptoService.invalidateSharedKey(senderId);

    final wasUnknown = _peerPublicKeyFromCaches(senderId) == null;

    _transport.updatePeerPublicKey(senderId, publicKeyB64);

    if (viaPeerId != null &&
        viaPeerId != senderId &&
        hopCount == kDefaultHopCount) {
      _transport.registerPeerIdMapping(senderId, viaPeerId);
    }

    final existing = StorageService.getKnownPeers().where((p) => p.peerId == senderId);
    final record = existing.isNotEmpty
        ? existing.first.copyWith(publicKey: publicKeyB64)
        : PeerRecord(
            peerId: senderId,
            pseudo: senderId,
            lastSeen: DateTime.now(),
            publicKey: publicKeyB64,
            // Une fiche créée depuis la boîte aux lettres est un contact EN
            // LIGNE : sans `['tor']`, `isTorOnlyPeer` la voyait comme un pair
            // mesh hors de portée — bouton d'appel grisé « Hors de portée »
            // alors que l'appel par Internet est possible.
            transports: transportsSiNouveau ?? const [],
          );
    StorageService.upsertPeer(record);

    _peerKeyReadyCtrl.add(senderId);
    debugPrint('[MeshRepo] clé publique reçue de $senderId');

    // La clé vient d'arriver : on rejoue le déchiffrement des messages de
    // ce pair reçus trop tôt, plutôt que de les laisser barrés d'un
    // cadenas pour toujours.
    unawaited(_retryPendingDecryptions(senderId).catchError(
        (e) => debugPrint('[MeshRepo] reprise déchiffrement: $e')));

    // Première rencontre → répondre avec notre clé pour compléter l'échange.
    if (wasUnknown && _allowHelloReply(senderId)) {
      unawaited(sendHello()
          .catchError((e) => debugPrint('[MeshRepo] échec réponse hello à $senderId: $e')));
    }
  }

  /// Peut-on répondre à ce hello ? Deux conditions : on n'a pas déjà répondu
  /// à CE pair dans les 30 dernières secondes (carnet borné), et on n'a pas
  /// dépassé le plafond global de réponses (8 par 5 s) — sinon une rafale
  /// de découverte déclencherait une rafale de broadcast chez nous.
  bool _allowHelloReply(String senderId) {
    final now = DateTime.now();

    // Plafond global (fenêtre glissante).
    if (now.difference(_helloReplyWindowStart) >= _helloReplyWindow) {
      _helloReplyWindowStart = now;
      _helloRepliesInWindow = 0;
    }
    if (_helloRepliesInWindow >= _helloRepliesMaxPerWindow) {
      return false;
    }

    // Carnet par émetteur, borné (oubli des plus anciens).
    if (_helloReplyCooldown.length > 512) {
      _helloReplyCooldown.remove(_helloReplyCooldown.keys.first);
    }
    final last = _helloReplyCooldown[senderId];
    if (last != null && now.difference(last) < _helloReplyPerSenderGap) {
      return false;
    }

    _helloReplyCooldown[senderId] = now;
    _helloRepliesInWindow++;
    return true;
  }

  /// Envoie une opération de contrôle de groupe (manifeste, sender-key) à
  /// [targetPeerId], toujours chiffrée en 1:1 comme un message dirigé
  /// classique — ce canal transporte potentiellement du matériel secret
  /// (clé de groupe).
  /// Invite les autres participants à un appel de groupe par Internet —
  /// chiffré pour chacun, par le mesh ou par Internet selon le membre.
  Future<void> envoyerInvitationAppelGroupe({
    required String groupId,
    required List<String> participants,
  }) async {
    final payload = <String, dynamic>{
      'g': groupId,
      'p': participants,
      'ts': DateTime.now().toUtc().toIso8601String(),
    };
    for (final membre in participants) {
      if (membre == _myId) continue;
      unawaited(_sendEncryptedControl(membre, 'group_call_invite', payload).then<void>((_) {}, onError: (Object e) {
        debugPrint('[MeshRepo] invitation d\'appel non envoyée à $membre: $e');
      }));
    }
  }

  Future<void> _sendEncryptedControl(String targetPeerId, String kind, Map<String, dynamic> payload) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(targetPeerId)) return;
    final (wireContent, nonce, encrypted) = await _encryptForPeer(targetPeerId, json.encode(payload));
    final jsonMap = <String, dynamic>{
      'c': wireContent,
      's': _myId,
      'k': kind,
      't': targetPeerId,
    };
    if (encrypted) {
      jsonMap['e'] = true;
      jsonMap['n'] = nonce;
    }
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    // Clé de groupe, synchronisation… : par Internet si le mesh ne joint pas.
    if (encrypted && !_joignableEnMesh(targetPeerId)) {
      if (await _doublerParInternet([targetPeerId], data) > 0) return;
    }
    await _enqueueReliable(
      messageId: 'ctrl-$kind-${DateTime.now().microsecondsSinceEpoch}',
      targetId: targetPeerId,
      data: data,
      priority: MessagePriority.critical,
    );
  }

  /// Diffuse un signal de frappe léger (ne persiste pas) — le petit
  /// « ... en train d'écrire » qu'on voit apparaître chez l'autre.
  Future<void> sendTyping({String? targetId, String? groupId}) async {
    if (groupId == null && targetId != null && StorageService.isContactBlocked(targetId)) return;
    final jsonMap = <String, dynamic>{
      'c': '',
      's': _myId,
      'k': 'typing',
    };
    if (targetId != null) jsonMap['t'] = targetId;
    if (groupId != null) jsonMap['g'] = groupId;
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse un accusé de lecture pour [messageId] vers son émetteur
  /// [originalSenderId] (ne persiste pas, relayé pour le multi-hop).
  Future<void> sendRead({
    required String originalSenderId,
    required String messageId,
  }) async {
    if (StorageService.isContactBlocked(originalSenderId)) return;
    final jsonMap = <String, dynamic>{
      'c': messageId,
      's': _myId,
      'k': 'read',
      't': originalSenderId,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Prévient l'auteur d'un message de GROUPE qu'on l'a reçu (relayé pour le
  /// multi-hop, rien n'est stocké) — l'équivalent de [sendRead] pour
  /// « distribué ».
  Future<void> sendRecu({
    required String originalSenderId,
    required String messageId,
  }) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(originalSenderId)) return;
    final jsonMap = <String, dynamic>{
      'c': messageId,
      's': _myId,
      'k': 'recu',
      't': originalSenderId,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse un vote de sondage 1:1 vers [targetId]. Le champ `c` porte
  /// l'ID du sondage voté (chiffré comme un message ordinaire), `o`
  /// l'index de l'option choisie.
  ///
  /// ⚠️ CHIFFRÉ — CONTRAIREMENT À `sendReaction`. Un emoji éphémère
  /// n'avait pas besoin de cette protection ; savoir POUR QUELLE OPTION
  /// quelqu'un a voté est exactement le genre d'information que le
  /// chiffrement de bout en bout de Droplet promet de protéger. Mêmes
  /// garanties qu'une modification de message 1:1 (`sendEditMessage`).
  ///
  /// Émet aussi localement dans `pollVoteEvents` : c'est ce flux, et lui
  /// seul, que lit `pollVotesProvider` — que le vote vienne d'ici ou d'un
  /// pair, un seul chemin de fusion.
  Future<void> sendPollVote({
    required String targetId,
    required String pollMessageId,
    required int optionIndex,
  }) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(targetId)) return;
    final (wireContent, nonce, encrypted) = await _encryptForPeer(targetId, pollMessageId);
    final jsonMap = <String, dynamic>{
      'c': wireContent,
      's': _myId,
      'o': optionIndex,
      'k': 'poll_vote',
      't': targetId,
    };
    if (encrypted) {
      jsonMap['e'] = true;
      jsonMap['n'] = nonce;
    }
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    _pollVoteCtrl.add((pollId: pollMessageId, voterId: _myId, optionIndex: optionIndex));
    unawaited(_doublerParInternet(_destinatairesDe(targetId), data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse un vote de sondage de GROUPE. Le contenu (l'ID du sondage)
  /// est chiffré avec la sender-key du groupe, comme `sendGroupEditMessage`.
  Future<void> sendGroupPollVote({
    required String groupId,
    required String pollMessageId,
    required int optionIndex,
  }) async {
    final (messageKey, newCounter) = await _advanceMySenderKey(groupId);
    final (cipherText, nonce) = await CryptoService.encrypt(messageKey, pollMessageId);
    final jsonMap = <String, dynamic>{
      'c': cipherText,
      's': _myId,
      'g': groupId,
      'o': optionIndex,
      'k': 'poll_vote',
      'n': nonce,
      'ctr': newCounter,
      'e': true,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    _pollVoteCtrl.add((pollId: pollMessageId, voterId: _myId, optionIndex: optionIndex));
    unawaited(_doublerParInternet(_destinatairesDe(groupId), data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse une réaction emoji vers [targetId]. Le champ `c` porte l'ID du
  /// message réagi, `m` l'emoji. Jamais persisté, relayé pour le multi-hop.
  Future<void> sendReaction({
    required String targetId,
    required String messageId,
    required String emoji,
  }) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(targetId)) return;
    final jsonMap = <String, dynamic>{
      'c': messageId,
      's': _myId,
      'm': emoji,
      'k': 'reaction',
      't': targetId,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    // Par Internet aussi : le mesh ne joint peut-être pas le destinataire.
    unawaited(_doublerParInternet(_destinatairesDe(targetId), data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse une modification de message vers tous les pairs connectés.
  /// Le champ `c` porte le nouveau contenu, `m` l'ID du message modifié.
  /// Relayé pour le multi-hop comme un message normal.
  Future<void> sendEditMessage({
    required String messageId,
    required String newContent,
    String? targetId,
  }) async {
    // Contact bloqué : rien ne part vers lui.
    if (targetId != null && StorageService.isContactBlocked(targetId)) return;
    final (wireContent, nonce, encrypted) = targetId != null
        ? await _encryptForPeer(targetId, newContent)
        : (newContent, null, false);
    final jsonMap = <String, dynamic>{
      'c': wireContent,
      's': _myId,
      'm': messageId,
      'k': 'edit',
    };
    if (encrypted) {
      jsonMap['e'] = true;
      jsonMap['n'] = nonce;
    }
    if (targetId != null) jsonMap['t'] = targetId;
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    if (targetId != null) unawaited(_doublerParInternet([targetId], data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Épingle (ou désépingle) [messageId] chez l'autre — en 1:1 vers
  /// [targetId], en groupe vers [groupId]. Même enveloppe qu'une
  /// modification de message : `m` l'identifiant, `c` « 1 » ou « 0 »
  /// chiffré.
  Future<void> envoyerEpingle({
    required String messageId,
    required bool epingle,
    String? targetId,
    String? groupId,
  }) async {
    final valeur = epingle ? '1' : '0';
    final Map<String, dynamic> jsonMap;
    if (groupId != null) {
      final (messageKey, newCounter) = await _advanceMySenderKey(groupId);
      final (cipherText, nonce) = await CryptoService.encrypt(messageKey, valeur);
      jsonMap = <String, dynamic>{
        'c': cipherText,
        's': _myId,
        'g': groupId,
        'm': messageId,
        'k': 'pin',
        'n': nonce,
        'ctr': newCounter,
        'e': true,
      };
    } else {
      if (targetId == null || StorageService.isContactBlocked(targetId)) return;
      final (wireContent, nonce, encrypted) =
          await _encryptForPeer(targetId, valeur);
      jsonMap = <String, dynamic>{
        'c': wireContent,
        's': _myId,
        'm': messageId,
        'k': 'pin',
        't': targetId,
      };
      if (encrypted) {
        jsonMap['e'] = true;
        jsonMap['n'] = nonce;
      }
    }
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    unawaited(_doublerParInternet(_destinatairesDe(groupId ?? targetId!), data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse une modification de message de groupe. Le contenu est chiffré
  /// avec la sender-key du groupe, comme un message de groupe ordinaire.
  Future<void> sendGroupEditMessage({
    required String groupId,
    required String messageId,
    required String newContent,
  }) async {
    final (messageKey, newCounter) = await _advanceMySenderKey(groupId);
    final (cipherText, nonce) = await CryptoService.encrypt(messageKey, newContent);
    final jsonMap = <String, dynamic>{
      'c': cipherText,
      's': _myId,
      'g': groupId,
      'm': messageId,
      'k': 'edit',
      'n': nonce,
      'ctr': newCounter,
      'e': true,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    unawaited(_doublerParInternet(_destinatairesDe(groupId), data));
    await _transport.broadcastToConnectedPeers(data);
  }

  /// Diffuse un check-in "je suis en sécurité" à tout le mesh (mode
  /// urgence/catastrophe) — statut public par nature, comme la diffusion
  /// mesh totale existante. [lat]/[lon] sont arrondis à 2 décimales
  /// (~1 km) avant envoi si fournis : jamais la position exacte.
  /// Mon dernier check-in envoyé — reconservé pour le regossiper aux pairs
  /// rencontrés après coup (voir `_gossipAnnouncementsOnNewPeer`), puisque
  /// l'envoi initial ne touche que les pairs connectés à cet instant précis.
  ({DateTime ts, double? lat, double? lon})? _myLastCheckin;
  static const Duration _checkinGossipWindow = Duration(hours: 24);

  Future<void> sendSafetyCheckin({double? lat, double? lon}) async {
    final now = DateTime.now();
    _myLastCheckin = (ts: now, lat: lat, lon: lon);
    final payload = <String, dynamic>{
      'status': 'safe',
      'ts': now.toIso8601String(),
      if (lat != null) 'lat': (lat * 100).round() / 100,
      if (lon != null) 'lon': (lon * 100).round() / 100,
    };
    final jsonMap = <String, dynamic>{
      'c': json.encode(payload),
      's': _myId,
      'k': 'safety_checkin',
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    final checkinId = 'checkin-${DateTime.now().microsecondsSinceEpoch}';
    try {
      await _enqueueReliable(
        messageId: checkinId,
        targetId: 'broadcast',
        data: data,
        priority: MessagePriority.critical,
      );
    } catch (e) {
      // C'est ici, précisément, que le silence serait le plus dangereux :
      // un check-in « je suis en sécurité » qui échoue sans que personne
      // ne le sache est pire que l'absence de fonctionnalité elle-même.
      _criticalSendFailureCtrl.add((kind: 'safety_checkin', messageId: checkinId, reason: e.toString()));
      rethrow;
    }
  }

  /// Rediffuse manuellement mes annonces (statut, check-in) aux pairs
  /// actuellement à portée.
  ///
  /// Déclenché par le geste « tirer pour rafraîchir » de l'onglet Actus :
  /// le regossip automatique ne se produit qu'à la rencontre d'un
  /// NOUVEAU pair, alors qu'on veut aussi pouvoir insister volontairement
  /// vers ceux déjà connectés (typiquement quand on doute que le message
  /// soit bien passé).
  Future<void> regossipAnnouncements() => _gossipAnnouncementsOnNewPeer();

  /// Envoie un événement Nexus à un pair pour synchroniser l'animation
  /// de connexion. Le payload est en clair (non chiffré) : il ne contient
  /// qu'une seed aléatoire et une couleur, aucun secret.
  Future<void> sendNexusEvent(String targetPeerId, NexusEvent event) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(targetPeerId)) return;
    final jsonPayload = utf8.encode(json.encode(event.toJson()));
    final data = Uint8List(2 + jsonPayload.length);
    data[0] = kDefaultHopCount;
    data[1] = kNexusEventType;
    data.setRange(2, data.length, jsonPayload);
    try {
      await _transport.sendToPeer(targetPeerId, data);
    } catch (e) {
      debugPrint('[MeshRepo] échec envoi Nexus vers $targetPeerId: $e');
    }
  }

  /// Regossipe mon statut actif et mon dernier check-in de sécurité à
  /// chaque nouvelle rencontre de pair — `sendStatus`/`sendSafetyCheckin`
  /// ne diffusent qu'une fois, aux pairs connectés à l'instant T ; sans ce
  /// regossip, publier en étant seul (0 pair) perdait silencieusement
  /// l'annonce pour de bon.
  Future<void> _gossipAnnouncementsOnNewPeer() async {
    // ── Les statuts : on PROPOSE, on ne rediffuse plus ──────────────
    //
    // L'ancienne version renvoyait MON statut, et lui seul, à chaque
    // rencontre. Deux défauts, dont le second est le plus grave :
    //
    //   1. Elle le renvoyait même à quelqu'un qui l'avait déjà.
    //   2. Elle ne transmettait JAMAIS les statuts des autres. Un statut
    //      n'atteignait donc que les gens que son auteur croisait en
    //      personne — alors qu'il est censé circuler « sur tout le
    //      mesh ». Le relais de proche en proche, qui est la raison
    //      d'être de Droplet, ne s'appliquait pas aux statuts.
    //
    // On propose désormais TOUT ce qu'on connaît, le sien et celui des
    // autres, sous forme d'identifiants. Le pair réclame ce qui lui
    // manque, et rien d'autre. Les statuts se propagent enfin de proche
    // en proche, et le coût reste proportionnel à ce qui manque
    // vraiment, non à ce qu'on possède.
    await _envoyerOffreDeSynchro();

    // ── Les annonces du compte officiel ─────────────────────────────
    //
    // Même principe que les statuts : on propose des identifiants, pas du
    // contenu. C'est ce qui fait qu'une nouveauté atteint un téléphone qui
    // n'a jamais vu Internet — par son voisin de table.
    await _proposerAnnonces();

    // ── Le check-in de sécurité : rediffusé tel quel ────────────────
    //
    // Volontairement laissé à l'identique. Il n'a pas d'identifiant
    // stable et n'est pas conservé dans un magasin qu'on puisse
    // comparer : il n'y a donc rien à négocier. Il est minuscule, borné
    // à une fenêtre de temps courte, et c'est le message le plus
    // critique de l'app — le rediffuser sans condition est ici la
    // bonne décision, pas une négligence.
    final checkin = _myLastCheckin;
    if (checkin != null && DateTime.now().difference(checkin.ts) < _checkinGossipWindow) {
      final payload = <String, dynamic>{
        'status': 'safe',
        'ts': checkin.ts.toIso8601String(),
        if (checkin.lat != null) 'lat': checkin.lat,
        if (checkin.lon != null) 'lon': checkin.lon,
      };
      final jsonMap = <String, dynamic>{'c': json.encode(payload), 's': _myId, 'k': 'safety_checkin'};
      final payloadBytes = utf8.encode(json.encode(jsonMap));
      final data = Uint8List(2 + payloadBytes.length);
      data[0] = kDefaultHopCount;
      data[1] = kTextMessageType;
      data.setRange(2, data.length, payloadBytes);
      await _transport.broadcastToConnectedPeers(data);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SYNCHRONISATION DIFFÉRENTIELLE DES STATUTS
  // ═══════════════════════════════════════════════════════════════════
  //
  // Trois temps : j'offre, on me demande, j'envoie. La logique de
  // décision elle-même est ailleurs, dans `sync_negotiation.dart`, sous
  // forme de fonctions pures — ce qui permet de la mesurer sans réseau.

  /// Compteurs, pour rendre le gain MESURABLE et non seulement affirmé.
  int syncOffersSent = 0;
  int syncOfferBytes = 0;
  int syncRequestsReceived = 0;
  int syncStatusesSent = 0;

  /// Les identifiants des statuts encore valides que je connais.
  List<String> _mesStatutsConnus() =>
      StorageService.getActiveStatuses().map((s) => s.id).toList();

  Future<void> _envoyerOffreDeSynchro() async {
    final connus = _mesStatutsConnus();
    if (connus.isEmpty) return;

    final offre = SyncNegotiation.preparerOffre(mesMessages: connus);
    if (offre.messageIds.isEmpty) return;

    final corps = offre.encode();
    final data = Uint8List(2 + corps.length);
    data[0] = kDefaultHopCount;
    data[1] = kSyncOfferType;
    data.setRange(2, data.length, corps);

    syncOffersSent++;
    syncOfferBytes += data.length;
    await _transport.broadcastToConnectedPeers(data);
  }

  // ══ LES ANNONCES DU COMPTE OFFICIEL ═══════════════════════════════

  /// La langue dans laquelle ranger une annonce reçue.
  ///
  /// ⚠️ LA LANGUE DE L'APPLICATION, PAS CELLE DU SYSTÈME. Quelqu'un qui a
  /// mis Droplet en français sur un téléphone en anglais veut lire les
  /// nouveautés en français — c'est le choix qu'il a fait ici.
  ///
  /// ⚠️ ON PASSE PAR `currentAppLocale()`, PAS PAR LA CLÉ DE STOCKAGE. Une
  /// première version lisait `StorageService.getString('app_locale')` —
  /// une clé que j'avais inventée et qui n'existe nulle part : la langue
  /// serait toujours retombée sur le repli. La fonction publique, elle,
  /// gère déjà le cas « aucun choix fait » en retombant sur la langue du
  /// système.
  String _langueAnnonces() => currentAppLocale().languageCode;

  /// Propose mes identifiants d'annonces à tous les pairs connectés.
  Future<void> _proposerAnnonces() async {
    if (AnnoncesDroplet.identifiantsConnus().isEmpty) return;
    await _diffuserBrut(AnnoncesDroplet.offre());
  }

  /// Envoie un corps JSON déjà formé à UN pair.
  ///
  /// ⚠️ `paquet[0] = 1` : UN SEUL SAUT. Ces paquets sont une négociation
  /// entre deux appareils voisins ; leur donner le nombre de sauts
  /// habituel les ferait voyager à travers le maillage et déclencherait
  /// des réclamations chez des gens qui ne m'ont rien proposé.
  Future<void> _envoyerBrutAuPair(String peerId, String corps) async {
    try {
      final octets = utf8.encode(corps);
      final paquet = Uint8List(2 + octets.length);
      paquet[0] = 1;
      paquet[1] = kTextMessageType;
      paquet.setRange(2, paquet.length, octets);
      await _transport.sendToPeer(peerId, paquet);
    } catch (e) {
      debugPrint('[Annonces] envoi vers $peerId impossible: $e');
    }
  }

  Future<void> _diffuserBrut(String corps) async {
    try {
      final octets = utf8.encode(corps);
      final paquet = Uint8List(2 + octets.length);
      paquet[0] = 1;
      paquet[1] = kTextMessageType;
      paquet.setRange(2, paquet.length, octets);
      await _transport.broadcastToConnectedPeers(paquet);
    } catch (e) {
      debugPrint('[Annonces] diffusion impossible: $e');
    }
  }

  /// On me propose des statuts : je réclame ceux qui me manquent.
  Future<void> _handleSyncOffer(MeshIncomingData data) async {
    try {
      if (data.data.length < 2) return;
      final offre = SyncOffer.decode(
          Uint8List.sublistView(data.data, 2));
      final miens = _mesStatutsConnus().toSet();

      final demande = SyncNegotiation.repondreAOffre(
        offre: offre,
        mesMessages: miens,
      );
      // Rien ne manque : on ne répond RIEN. C'est le cas le plus
      // fréquent entre deux appareils qui se recroisent, et c'est là que
      // se joue l'essentiel de l'économie.
      if (demande.messageIds.isEmpty) return;

      final corps = demande.encode();
      final paquet = Uint8List(2 + corps.length);
      paquet[0] = kDefaultHopCount;
      paquet[1] = kSyncRequestType;
      paquet.setRange(2, paquet.length, corps);

      await _transport.sendToPeer(data.peerId, paquet);
    } catch (e) {
      debugPrint('[MeshRepo] offre de synchro illisible: $e');
    }
  }

  /// On me réclame des statuts : je les renvoie, et eux seuls.
  ///
  /// La réponse emprunte le format d'annonce ORDINAIRE (`k: 'status'`) :
  /// le destinataire n'a donc aucun code de réception nouveau à
  /// exécuter, c'est `_handleStatus` qui les range comme d'habitude.
  Future<void> _handleSyncRequest(MeshIncomingData data) async {
    try {
      if (data.data.length < 2) return;
      final demande = SyncRequest.decode(
          Uint8List.sublistView(data.data, 2));

      final parId = {
        for (final s in StorageService.getActiveStatuses()) s.id: s,
      };
      final aEnvoyer = SyncNegotiation.messagesAEnvoyer(
        demande: demande,
        mesMessages: parId.keys.toSet(),
      );

      syncRequestsReceived++;
      for (final id in aEnvoyer) {
        final statut = parId[id];
        if (statut == null) continue;

        final payload = <String, dynamic>{
          'id': statut.id,
          'content': statut.content,
          'createdAt': statut.createdAt.toIso8601String(),
          'expiresAt': statut.expiresAt.toIso8601String(),
          // Le média suit le statut : sans lui, le destinataire
          // recevrait une photo sans savoir qu'il y en a une.
          if (!StorageService.getStatusMedia(statut.id).isPlainText)
            'media': StorageService.getStatusMedia(statut.id).toJson(),
        };
        // ⚠️ `s` porte l'AUTEUR du statut, pas moi. C'est ce qui permet
        // au relais de fonctionner : je transmets le statut de quelqu'un
        // d'autre sans m'en attribuer la paternité.
        final jsonMap = <String, dynamic>{
          'c': json.encode(payload),
          's': statut.authorId,
          'k': 'status',
          'm': statut.id,
        };
        final bytes = utf8.encode(json.encode(jsonMap));
        final paquet = Uint8List(2 + bytes.length);
        paquet[0] = kDefaultHopCount;
        paquet[1] = kTextMessageType;
        paquet.setRange(2, paquet.length, bytes);

        syncStatusesSent++;
        await _transport.sendToPeer(data.peerId, paquet);
      }
    } catch (e) {
      debugPrint('[MeshRepo] demande de synchro illisible: $e');
    }
  }


  void _handleSafetyCheckin(String senderId, String content) {
    try {
      final payload = json.decode(content) as Map<String, dynamic>;
      String authorPseudo = senderId;
      try {
        authorPseudo = _transport.connectedPeers.firstWhere((p) => p.peerId == senderId).pseudo;
      } catch (_) {
        try {
          authorPseudo = StorageService.getKnownPeers().firstWhere((p) => p.peerId == senderId).pseudo;
        } catch (_) {}
      }
      final checkin = SafetyCheckinRecord(
        peerId: senderId,
        pseudo: authorPseudo,
        timestamp: DateTime.tryParse(payload['ts'] as String? ?? '') ?? DateTime.now(),
        lat: (payload['lat'] as num?)?.toDouble(),
        lon: (payload['lon'] as num?)?.toDouble(),
      );
      unawaited(StorageService.saveSafetyCheckin(checkin));
      _safetyCheckinCtrl.add(checkin);
    } catch (e) {
      debugPrint('[MeshRepo] check-in de sécurité invalide: $e');
    }
  }

  static const Duration _statusLifetime = Duration(hours: 24);

  /// Diffuse un statut éphémère à tout le mesh — public par nature,
  /// comme les statuts WhatsApp vus par tous les contacts.
  ///
  /// [media] peut porter une photo, une vidéo, un message vocal et une
  /// musique d'accompagnement. Les FICHIERS doivent avoir été envoyés
  /// AVANT l'appel (voir [sendStatusFile]) : cette annonce ne transporte
  /// que la légende et les identifiants qui pointent vers eux.
  /// Les contacts à qui un statut « pour tous » est envoyé par Internet.
  List<String> contactsPourStatut() => _contactsPourStatut().toList();

  /// Les types de paquets qui concernent un GROUPE : un contact bloqué y
  /// reste membre, comme chez WhatsApp.
  static const Set<String> _typesDeGroupe = {
    'group_sync',
    'group_sender_key',
    'group_call_invite',
    'group_voice_room',
    'sgreset',
  };

  /// Le jeton d'exclusion d'une personne pour un statut public : l'empreinte
  /// de « statut:personne », tronquée. Différente pour chaque statut, elle ne
  /// permet pas de suivre une personne d'un statut à l'autre.
  static String _jetonExclusion(String idStatut, String peerId) => crypto.sha256
      .convert(utf8.encode('$idStatut:$peerId'))
      .toString()
      .substring(0, 16);

  Future<void> sendStatus(
    String content, {
    StatusMedia media = StatusMedia.empty,
    /// L'audience choisie : `null` = tout le monde (diffusion). Sinon, SEULS
    /// ces contacts reçoivent le statut, chiffré pour chacun.
    List<String>? destinataires,
  }) async {
    final now = DateTime.now();
    final status = MeshStatusRecord(
      id: StorageService.generateId(),
      authorId: _myId,
      authorPseudo: _myPseudo,
      content: content,
      createdAt: now,
      expiresAt: now.add(_statusLifetime),
    );
    await StorageService.saveStatus(status);
    await StorageService.saveStatusMedia(status.id, media);

    final payload = <String, dynamic>{
      'id': status.id,
      'content': content,
      'createdAt': status.createdAt.toIso8601String(),
      'expiresAt': status.expiresAt.toIso8601String(),
      // Absent quand le statut est en texte seul : inutile d'alourdir
      // l'annonce d'un objet vide, et les versions antérieures de
      // Droplet ignorent simplement cette clé qu'elles ne connaissent
      // pas.
      if (!media.isPlainText) 'media': media.toJson(),
    };
    // ⚠️ AUDIENCE RESTREINTE : JAMAIS DIFFUSÉ À LA RONDE. Le choix « qui peut
    // voir » était fait dans le compositeur puis oublié : le statut partait
    // en clair à tout le voisinage et à tous les contacts. Il part désormais
    // chiffré et adressé à chaque personne autorisée, par le mesh ou par
    // Internet, et à personne d'autre.
    if (destinataires != null) {
      for (final pair in destinataires.toSet()) {
        if (pair == _myId || StorageService.isContactBlocked(pair)) continue;
        unawaited(_sendEncryptedControl(pair, 'status', payload).then<void>((_) {}, onError: (Object e) {
          debugPrint('[MeshRepo] statut non envoyé à $pair: $e');
        }));
      }
      return;
    }
    // ⚠️ UN STATUT « TOUT LE MONDE » EST PUBLIC : il part en clair à qui
    // passe à portée, contacts bloqués compris. On y joint, pour chaque
    // contact bloqué, un jeton (empreinte de « statut:personne ») : l'app
    // d'une personne bloquée reconnaît le sien et n'affiche pas le statut.
    // Les identités ne circulent pas en clair. Une app modifiée pourrait
    // ignorer ce jeton — c'est le prix d'un statut public ; « Mes contacts
    // sauf… » exclut, lui, par le chiffrement.
    final bloques = StorageService.getBlockedContacts();
    if (bloques.isNotEmpty) {
      payload['x'] = [for (final id in bloques) _jetonExclusion(status.id, id)];
    }
    final jsonMap = <String, dynamic>{
      'c': json.encode(payload),
      's': _myId,
      'k': 'status',
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    // Mes contacts hors de portée voient le statut par Internet.
    final statutParInternet = await _doublerParInternet(_contactsPourStatut(), data);
    if (_transport.connectedPeerCount == 0 && statutParInternet > 0) return;
    try {
      await _enqueueReliable(
        messageId: 'status-${status.id}',
        targetId: 'broadcast',
        data: data,
        priority: MessagePriority.normal,
      );
    } catch (e) {
      _criticalSendFailureCtrl.add((kind: 'status', messageId: status.id, reason: e.toString()));
      rethrow;
    }
  }

  /// Diffuse un fichier destiné à un statut (photo, vidéo, vocal,
  /// musique) et renvoie son identifiant.
  ///
  /// En clair, et c'est volontaire : un statut est PUBLIC par définition,
  /// destiné à quiconque passe à portée. Le chiffrer supposerait de
  /// connaître à l'avance la liste de ses destinataires — or on ne la
  /// connaît pas, c'est justement tout l'intérêt.
  ///
  /// ⚠️ Les images >10 Mo sont automatiquement compressées (JPEG, qualité
  /// 85, max 2048px) avant envoi — sur un mesh, la bande passante est
  /// comptée et une photo de 10 Mo prendrait des minutes à traverser.
  Future<String> sendStatusFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    /// Voir [sendStatus] : `null` = diffusion, sinon envoi chiffré à chacun.
    List<String>? destinataires,
  }) async {
    // Compression automatique des images volumineuses.
    final compressed = await MediaService.compressIfNeeded(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );

    final fileId = StorageService.generateId();
    await StorageService.saveSharedFile(
        fileId: fileId, fileName: compressed.name, bytes: compressed.bytes);
    final mime = compressed.name.endsWith('.jpg') || compressed.name.endsWith('.jpeg')
        ? 'image/jpeg'
        : mimeType;
    if (destinataires != null) {
      for (final pair in destinataires.toSet()) {
        if (pair == _myId || StorageService.isContactBlocked(pair)) continue;
        unawaited(sendFile(
          fileName: compressed.name,
          bytes: compressed.bytes,
          mimeType: mime,
          fileId: fileId,
          targetId: pair,
          forStatus: true,
          suffixeEnvoi: '-$pair',
        ).then<void>((_) {}, onError: (Object e) {
          debugPrint('[MeshRepo] média de statut non envoyé à $pair: $e');
        }));
      }
      return fileId;
    }
    await sendFile(
      fileName: compressed.name,
      bytes: compressed.bytes,
      mimeType: mime,
      fileId: fileId,
      forStatus: true,
    );
    return fileId;
  }

  /// Envoie un « j'aime » ou un commentaire à l'auteur d'un statut.
  ///
  /// Ciblé sur le seul auteur, jamais diffusé — voir [StatusFeedback]
  /// pour la raison, qui tient autant à la discrétion qu'à ce qu'un
  /// compteur public serait impossible à tenir juste sur un maillage.
  Future<void> sendStatusFeedback({
    required String authorId,
    required String statusId,
    String? emoji,
    String? text,
    bool remove = false,
  }) async {
    if (StorageService.isContactBlocked(authorId)) return;
    if (authorId == _myId) return;
    final payload = <String, dynamic>{
      'statusId': statusId,
      'ts': DateTime.now().toIso8601String(),
      'emoji': ?emoji,
      'text': ?text,
      if (remove) 'remove': true,
    };
    final jsonMap = <String, dynamic>{
      'c': json.encode(payload),
      's': _myId,
      'k': 'status_feedback',
      't': authorId,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    // Passe par la file fiable, contrairement aux accusés de vue : un
    // commentaire qu'on prend la peine d'écrire doit finir par arriver,
    // même si son destinataire est momentanément hors de portée.
    if (!_joignableEnMesh(authorId) && await _doublerParInternet([authorId], data) > 0) return;
    await _enqueueReliable(
      messageId: 'feedback-$statusId-${DateTime.now().microsecondsSinceEpoch}',
      targetId: authorId,
      data: data,
      priority: MessagePriority.normal,
    );
  }

  void _handleStatusFeedback(String senderId, String content) {
    try {
      final payload = json.decode(content) as Map<String, dynamic>;
      final statusId = payload['statusId'] as String?;
      if (statusId == null) return;

      String pseudo = senderId;
      try {
        pseudo = _transport.connectedPeers
            .firstWhere((p) => p.peerId == senderId)
            .pseudo;
      } catch (_) {
        try {
          pseudo = StorageService.getKnownPeers()
              .firstWhere((p) => p.peerId == senderId)
              .pseudo;
        } catch (_) {}
      }

      if (payload['remove'] == true) {
        unawaited(StorageService.removeStatusLike(statusId, senderId));
        return;
      }

      final feedback = StatusFeedback(
        statusId: statusId,
        authorId: senderId,
        authorPseudo: pseudo,
        createdAt:
            DateTime.tryParse(payload['ts'] as String? ?? '') ?? DateTime.now(),
        emoji: payload['emoji'] as String?,
        text: payload['text'] as String?,
      );
      unawaited(StorageService.addStatusFeedback(feedback));
      _statusFeedbackCtrl.add(feedback);

      // Notification quand quelqu'un aime ou commente notre statut
      final myStatuses = StorageService.getActiveStatuses()
          .where((s) => s.authorId == _myId);
      final isMyStatus = myStatuses.any((s) => s.id == statusId);
      if (isMyStatus) {
        // Le centre de notifications en garde la trace : un « j'aime » sur
        // un statut ne laisse aucune autre marque visible une fois la
        // notification balayée.
        unawaited(JournalNotifs.instance.ajouter(EntreeNotif(
          id: 's:$statusId:$senderId:${feedback.text == null ? 'j' : feedback.createdAt.millisecondsSinceEpoch}',
          type: feedback.text != null
              ? TypeEntreeNotif.reponseStatut
              : TypeEntreeNotif.jaimeStatut,
          conversationId: 'statut:$statusId',
          route: '/status/$_myId',
          auteur: pseudo,
          auteurId: senderId,
          texte: feedback.text ?? '',
          emoji: feedback.emoji,
          quand: feedback.createdAt,
        )));
        if (feedback.emoji != null && feedback.text == null) {
          // Like
          NotificationService.showStatusLiked(
            pseudo: pseudo,
            authorId: senderId,
            statusId: statusId,
          );
        } else if (feedback.text != null) {
          // Commentaire
          NotificationService.showStatusReply(
            pseudo: pseudo,
            authorId: senderId,
            statusId: statusId,
            preview: feedback.text!,
          );
        }
      }
    } catch (e) {
      debugPrint('[MeshRepo] retour de statut invalide: $e');
    }
  }

  /// Statuts déjà annoncés : le même arrive souvent par le mesh ET par
  /// Internet, et ne doit pas notifier deux fois.
  final Set<String> _statutsRecus = {};

  void _handleStatus(String senderId, String content, String? appMsgId) {
    if (appMsgId != null) {
      if (_appMessageIds.containsKey(appMsgId)) return;
      _appMessageIds[appMsgId] = DateTime.now();
    }
    try {
      final payload = json.decode(content) as Map<String, dynamic>;
      final idStatut = payload['id'] as String?;
      // L'auteur m'a bloqué : son statut public ne s'affiche pas chez moi.
      final exclus = payload['x'];
      if (idStatut != null && exclus is List && exclus.contains(_jetonExclusion(idStatut, _myId))) return;
      if (idStatut != null && !_statutsRecus.add(idStatut)) return;
      final expiresAt = DateTime.tryParse(payload['expiresAt'] as String? ?? '');
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) return;

      String authorPseudo = senderId;
      try {
        authorPseudo = _transport.connectedPeers.firstWhere((p) => p.peerId == senderId).pseudo;
      } catch (_) {
        try {
          authorPseudo = StorageService.getKnownPeers().firstWhere((p) => p.peerId == senderId).pseudo;
        } catch (_) {}
      }

      final status = MeshStatusRecord(
        id: payload['id'] as String? ?? appMsgId ?? StorageService.generateId(),
        authorId: senderId,
        authorPseudo: authorPseudo,
        content: payload['content'] as String? ?? '',
        createdAt: DateTime.tryParse(payload['createdAt'] as String? ?? '') ?? DateTime.now(),
        expiresAt: expiresAt,
      );
      unawaited(StorageService.saveStatus(status));

      final rawMedia = payload['media'];
      if (rawMedia is Map<String, dynamic>) {
        unawaited(StorageService.saveStatusMedia(
            status.id, StatusMedia.fromJson(rawMedia)));
      }
      _statusCtrl.add(status);
    } catch (e) {
      debugPrint('[MeshRepo] statut invalide: $e');
    }
  }

  /// Signale à l'auteur [authorId] que j'ai vu son statut [statusId] —
  /// ciblé (comme une réaction), jamais diffusé largement. C'est ce qui
  /// permet d'afficher plus tard « Vu par Untel, Unetelle » sous son
  /// propre statut.
  Future<void> sendStatusSeen({required String authorId, required String statusId}) async {
    if (StorageService.isContactBlocked(authorId)) return;
    if (authorId == _myId) return;
    final payload = <String, dynamic>{
      'statusId': statusId,
      'ts': DateTime.now().toIso8601String(),
    };
    final jsonMap = <String, dynamic>{
      'c': json.encode(payload),
      's': _myId,
      'k': 'status_seen',
      't': authorId,
    };
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    unawaited(_doublerParInternet([authorId], data));
    await _transport.broadcastToConnectedPeers(data);
  }

  void _handleStatusSeen(String senderId, String content) {
    try {
      final payload = json.decode(content) as Map<String, dynamic>;
      final statusId = payload['statusId'] as String?;
      if (statusId == null) return;
      String viewerPseudo = senderId;
      try {
        viewerPseudo = _transport.connectedPeers.firstWhere((p) => p.peerId == senderId).pseudo;
      } catch (_) {
        try {
          viewerPseudo = StorageService.getKnownPeers().firstWhere((p) => p.peerId == senderId).pseudo;
        } catch (_) {}
      }
      unawaited(StorageService.recordStatusView(
        statusId: statusId,
        viewerId: senderId,
        viewerPseudo: viewerPseudo,
        ts: DateTime.tryParse(payload['ts'] as String? ?? '') ?? DateTime.now(),
      ));
      _statusSeenCtrl.add(statusId);
    } catch (e) {
      debugPrint('[MeshRepo] accusé de vue de statut invalide: $e');
    }
  }

  // ── Relais (faire suivre un message qui ne m'était pas destiné) ────────
  //
  // Comme dans le jeu du téléphone arabe : chaque message porte un
  // « nombre de sauts » restants, qui diminue à chaque fois qu'il passe
  // par un téléphone. Ça l'empêche de tourner en rond éternellement sur
  // le réseau.

  /// Décide s'il faut relayer TOUT DE SUITE (des pairs sont connectés) ou
  /// mettre de côté pour plus tard (aucun pair connecté pour le moment).
  ///
  /// [targetId] : la destination logique du paquet (un pair, un groupe, ou
  /// null pour une diffusion publique). Elle permet au relais de choisir un
  /// chemin INTELLIGENT (next-hop connu de la table de routage) au lieu de
  /// noyer tout le voisinage.
  void _relayOrDefer(String messageId, Uint8List fullPayload, int remainingHops,
      {String? excludePeerId, String? targetId}) {
    if (remainingHops <= 1) {
      debugPrint('[MeshRepo] relais fini msg=$messageId (hops=$remainingHops)');
      return;
    }
    if (_transport.activePeerCount == 0) {
      _addPendingRelay(messageId, fullPayload);
      debugPrint('[MeshRepo] relais différé msg=$messageId (aucun pair actif)');
      return;
    }
    _relayNow(messageId, fullPayload, remainingHops,
        excludePeerId: excludePeerId, targetId: targetId);
  }

  /// Met un relais en attente (aucun pair connecté) avec une borne haute :
  /// si plus de [_pendingRelaysCap] messages attendent, on jette les plus
  /// vieux en priorité — stocker 10 000 relais en RAM + disque en attendant
  /// une reconnexion qui n'arrive peut-être pas ne servirait à rien.
  void _addPendingRelay(String messageId, Uint8List payload) {
    if (_pendingRelays.length >= _pendingRelaysCap) {
      _pendingRelays.removeAt(0);
    }
    _pendingRelays.add(_PendingRelay(messageId, Uint8List.fromList(payload)));
    _pendingRelayGeneration++;
    StorageService.savePendingRelay(messageId, payload);
  }

  /// Transmet réellement un relais au prochain saut.
  ///
  /// Routage adaptatif (protocole v2) : si le paquet est dirigé vers une
  /// destination précise et que la table de routage connaît un prochain
  /// saut (route directe ou multi-hop), on envoie UNIQUEMENT à ce pair —
  /// qui fera suivre. On ne retombe sur la diffusion au voisinage que si
  /// on ne sait pas encore où aller (découverte) ou si la route est
  /// introuvable.
  void _relayNow(String messageId, Uint8List fullPayload, int remainingHops,
      {String? excludePeerId, String? targetId}) {
    final nextHops = remainingHops - 1;
    var relayData = Uint8List.fromList(fullPayload);
    relayData[0] = nextHops;

    // ── ON SIGNE SON PASSAGE ──────────────────────────────────────
    //
    // Chaque relais ajoute son empreinte au champ `p` de l'enveloppe. Le
    // destinataire reçoit donc le trajet complet, et peut enfin
    // l'afficher — c'est ce qui manquait pour que `routeInfo` cesse
    // d'être une colonne vide.
    //
    // ⚠️ HUIT CARACTÈRES, PAS L'IDENTIFIANT ENTIER. Une empreinte
    // complète fait soixante-quatre caractères ; cinq relais en
    // ajouteraient plus de trois cents à un paquet qui doit tenir sous
    // les 512 octets du Bluetooth. Huit suffisent à distinguer deux
    // appareils à l'œil, et c'est déjà la forme abrégée qu'affiche
    // l'interface.
    relayData = _signerLePassage(relayData);

    // `broadcastToConnectedPeers` utilise Future.wait : un seul pair dont le
    // transport échoue pendant la diffusion suffit à rejeter le Future
    // entier. Fire-and-forget assumé (le relais est best-effort), donc
    // jamais laissé remonter comme exception non rattrapée.
    Future<void> relay = _relayToNextHop(
      messageId, relayData, targetId, excludePeerId);
    unawaited(relay
        .then((_) => StorageService.incrementRelayCount())
        .catchError((e) => debugPrint('[MeshRepo] échec relais msg=$messageId: $e')));
    _relayCounter++;
    debugPrint('[MeshRepo] relais #$_relayCounter msg=$messageId hops=$remainingHops→$nextHops peers=${_transport.connectedPeerCount} target=$targetId');
  }

  /// Choisit le prochain saut : route connue si [targetId] est précis, sinon
  /// diffusion au voisinage.
  Future<void> _relayToNextHop(
      String messageId, Uint8List relayData, String? targetId, String? excludePeerId) {
    if (targetId != null && targetId != 'broadcast') {
      try {
        return _transport
            .sendViaRoute(targetId, relayData)
            .then((routed) {
          if (routed) return Future<void>.value();
          // Route inconnue → on ne peut pas cibler, on diffuse.
          return _transport.broadcastToConnectedPeers(relayData,
              excludePeerId: excludePeerId);
        });
      } catch (e) {
        debugPrint('[MeshRepo] route vers $targetId impossible: $e — diffusion');
      }
    }
    return _transport.broadcastToConnectedPeers(relayData,
        excludePeerId: excludePeerId);
  }

  int _relayCounter = 0;

  /// Dès qu'un pair se reconnecte, on essaie d'envoyer tous les messages
  /// qu'on gardait de côté faute de destinataire disponible — comme
  /// vider la boîte aux lettres d'attente dès que quelqu'un repasse.
  ///
  /// Utilise un compteur de génération pour détecter si de nouveaux
  /// relais sont arrivés pendant le vidage. Si c'est le cas, un
  /// deuxième flush est programmé — on ne perd jamais un relais ajouté
  /// entre le `clear()` et la fin des envois.
  void flushPendingRelays() {
    if (_pendingRelays.isEmpty) return;
    final gen = _pendingRelayGeneration;
    final toForward = List<_PendingRelay>.from(_pendingRelays);
    _pendingRelays.clear();
    StorageService.clearPendingRelays();
    debugPrint('[MeshRepo] flush ${toForward.length} relais en attente');
    for (final pending in toForward) {
      final hops = pending.payload.isNotEmpty ? pending.payload[0] : 0;
      if (hops > 1) _relayNow(pending.id, pending.payload, hops);
    }
    // Si de nouveaux relais ont été ajoutés pendant l'envoi, relancer.
    if (_pendingRelayGeneration != gen && _pendingRelays.isNotEmpty) {
      scheduleMicrotask(flushPendingRelays);
    }
  }

  void _loadPendingRelays() {
    try {
      final stored = StorageService.getPendingRelays();
      for (final entry in stored) {
        final id = entry['id'] as String;
        final b64 = entry['payload'] as String;
        final payload = base64Decode(b64);
        _addPendingRelay(id, Uint8List.fromList(payload));
      }
      if (_pendingRelays.isNotEmpty) {
        debugPrint('[MeshRepo] ${_pendingRelays.length} relais chargés du stockage');
      }
    } catch (e) {
      debugPrint('[MeshRepo] erreur chargement relais: $e');
    }
  }

  List<MeshMessage> getMessagesByType(String type) {
    return StorageService.getMessages()
        .where((m) => m.type == type)
        .toList();
  }

  List<MeshMessage> getMessagesByAuthor(String pseudo) {
    return StorageService.getMessages()
        .where((m) => m.authorPseudo == pseudo)
        .toList();
  }

  int getMessageCount() => StorageService.getMessages().length;

  /// Fabrique les statistiques affichées sur l'écran « Réseau mesh »
  /// (nombre de pairs, fiabilité moyenne, fichiers relayés, etc.).
  MeshStats getStats() {
    final health = _transport.health;
    return MeshStats(
      distributedGb: StorageService.getMessageCount() * 0.001,
      relayedFiles: StorageService.getMessages().where((m) => m.type == 'file').length,
      helpedPeers: _transport.connectedPeerCount,
      totalPeers: _transport.connectedPeerCount,
      blePeers: _transport.blePeerCount,
      wifiPeers: _transport.wifiPeerCount,
      nativePeers: _transport.nativePeerCount,
      averageReliability: health.averageReliability,
      messagesSent: health.messagesSent,
      acksReceived: health.acksReceived,
    );
  }

  void setGatewayMode(bool enabled) {
    _transport.setRole(enabled ? PeerRole.gateway : PeerRole.leaf);
  }

  // ── Groupes de discussion (sender-keys façon Signal/WhatsApp) ───────────
  //
  // Pas de serveur de groupe : chaque mutation (création, ajout, retrait,
  // renommage) est appliquée localement puis diffusée en manifeste complet
  // ("group_sync") à chaque membre concerné, toujours via le canal 1:1 déjà
  // chiffré. La convergence entre appareils se fait par LWW sur le
  // timestamp le plus récent (ajout ou retrait) par membre — voir
  // [_applyGroupSync]. Les messages de groupe eux-mêmes sont chiffrés avec
  // la sender-key de leur auteur (ratchet HMAC, [CryptoService.ratchetForward]).
  //
  // Pour un enfant de 8 ans : imagine un club secret. Il n'y a pas de
  // chef unique qui note tout dans un grand cahier central — à la place,
  // chaque membre écrit lui-même les changements (« Untel a rejoint »,
  // « Unetelle est partie ») sur son PROPRE petit carnet, et le montre
  // aux autres. Si deux membres ont des versions différentes, celle avec
  // la date la plus récente gagne. Et chaque membre a son propre
  // « cadenas à combinaison qui change » (sa sender-key) pour signer ses
  // messages dans le club — s'il est exclu, on change tous les cadenas
  // pour qu'il ne puisse plus rien lire de nouveau.

  /// Crée un groupe et m'en nomme administrateur. Diffuse le manifeste et
  /// distribue ma sender-key à chaque membre initial.
  Future<String> createGroup({required String name, required Set<String> memberIds}) async {
    final groupId = StorageService.generateId();
    final now = DateTime.now();
    await StorageService.upsertGroup(id: groupId, name: name, createdBy: _myId, createdAt: now, updatedAt: now);
    await StorageService.upsertGroupMember(groupId: groupId, peerId: _myId, role: 'admin', addedAt: now, addedBy: _myId);
    for (final peerId in memberIds.where((id) => id != _myId)) {
      await StorageService.upsertGroupMember(groupId: groupId, peerId: peerId, role: 'member', addedAt: now, addedBy: _myId);
    }
    await _bootstrapMySenderKey(groupId);
    await _syncGroupToMembers(groupId);
    _groupsChangedCtrl.add(groupId);
    return groupId;
  }

  /// Ajoute [peerId] au groupe (réservé aux administrateurs).
  /// Demande à entrer dans un groupe, après avoir scanné son code.
  ///
  /// On ne s'ajoute jamais soi-même : on envoie une demande à
  /// l'administrateur qui a montré le code, et c'est SON appareil qui
  /// vérifie le jeton et ajoute le membre. Photographier un écran ne donne
  /// donc que le droit de demander.
  /// Annonce ce qui se passe dans un salon vocal : ouvert, j'entre, je
  /// sors, ou une réaction. Trois octets et demi, à tous les membres — la
  /// voix, elle, passe par le chemin habituel des appels.
  Future<void> annoncerSalonVocal({
    required String groupId,
    required String action,
    String? emoji,
  }) async {
    final groupe = StorageService.getGroup(groupId);
    if (groupe == null) return;
    for (final m in groupe.activeMembers) {
      if (m.peerId == _myId) continue;
      if (StorageService.isContactBlocked(m.peerId)) continue;
      unawaited(
        _sendEncryptedControl(m.peerId, 'group_voice_room', {
          'g': groupId,
          'a': action,
          if (emoji != null) 'e': emoji,
          'ts': DateTime.now().toIso8601String(),
        }).then<void>((_) {}, onError: (Object e) {
          debugPrint('[MeshRepo] annonce de salon non partie : $e');
        }),
      );
    }
  }

  Future<void> demanderRejoindreGroupe({
    required String hote,
    required String groupId,
    required String jeton,
  }) async {
    await _sendEncryptedControl(hote, 'group_join_request', {
      'groupId': groupId,
      'jeton': jeton,
    });
  }

  Future<void> addGroupMember({required String groupId, required String peerId}) async {
    final group = StorageService.getGroup(groupId);
    if (group == null || !group.isAdmin(_myId)) {
      throw StateError('Seul un administrateur peut ajouter un membre à ce groupe');
    }
    final now = DateTime.now();
    await StorageService.upsertGroupMember(groupId: groupId, peerId: peerId, role: 'member', addedAt: now, addedBy: _myId);
    await StorageService.upsertGroup(
      id: group.id, name: group.name, avatarUrl: group.avatarUrl,
      createdBy: group.createdBy, createdAt: group.createdAt, updatedAt: now,
    );
    await _syncGroupToMembers(groupId);
    _groupsChangedCtrl.add(groupId);
  }

  /// Retire [peerId] du groupe (réservé aux administrateurs). Ma sender-key
  /// est régénérée et redistribuée aux membres restants : le membre exclu
  /// ne pourra plus déchiffrer les messages futurs.
  Future<void> removeGroupMember({required String groupId, required String peerId}) async {
    final group = StorageService.getGroup(groupId);
    if (group == null || !group.isAdmin(_myId)) {
      throw StateError('Seul un administrateur peut retirer un membre de ce groupe');
    }
    await _markMemberRemoved(group, peerId);
    await StorageService.deleteGroupSenderKey(groupId, peerId);
    await _bootstrapMySenderKey(groupId); // rotation + redistribution aux membres restants
    await _syncGroupToMembers(groupId); // informe les membres restants du retrait
    _groupsChangedCtrl.add(groupId);
  }

  /// Quitte le groupe. Les membres restants apprendront mon départ via la
  /// prochaine synchro et feront tourner leur propre sender-key.
  Future<void> leaveGroup(String groupId) async {
    final group = StorageService.getGroup(groupId);
    if (group == null) return;
    await _markMemberRemoved(group, _myId);
    await StorageService.deleteGroupSenderKey(groupId, _myId);
    await _syncGroupToMembers(groupId);
    _groupsChangedCtrl.add(groupId);
  }

  Future<void> _markMemberRemoved(GroupInfo group, String peerId) async {
    final now = DateTime.now();
    final existing = group.members.where((m) => m.peerId == peerId);
    await StorageService.upsertGroupMember(
      groupId: group.id,
      peerId: peerId,
      role: existing.isNotEmpty ? existing.first.role : 'member',
      addedAt: existing.isNotEmpty ? existing.first.addedAt : now,
      removedAt: now,
      addedBy: existing.isNotEmpty ? existing.first.addedBy : _myId,
    );
    await StorageService.upsertGroup(
      id: group.id, name: group.name, avatarUrl: group.avatarUrl,
      createdBy: group.createdBy, createdAt: group.createdAt, updatedAt: now,
    );
  }

  /// Renomme le groupe (n'importe quel membre actif peut le faire, comme
  /// dans la plupart des messageries grand public).
  Future<void> renameGroup({required String groupId, required String name}) async {
    final group = StorageService.getGroup(groupId);
    if (group == null || !group.isActiveMember(_myId)) {
      throw StateError('Groupe introuvable ou vous n\'en êtes plus membre');
    }
    await StorageService.upsertGroup(
      id: group.id, name: name, avatarUrl: group.avatarUrl,
      createdBy: group.createdBy, createdAt: group.createdAt, updatedAt: DateTime.now(),
    );
    await _syncGroupToMembers(groupId);
    _groupsChangedCtrl.add(groupId);
  }

  /// Génère une nouvelle sender-key pour ce groupe et la distribue à tous
  /// les membres actifs (hors moi-même). Utilisé à la fois pour le
  /// bootstrap initial (création/adhésion) et la rotation (retrait d'un
  /// membre) — les deux cas veulent une chaîne fraîche redistribuée aux
  /// membres actuellement actifs.
  Future<void> _bootstrapMySenderKey(String groupId) async {
    final chainKey = await CryptoService.generateChainKey();
    await StorageService.upsertGroupSenderKey(
      groupId: groupId, ownerPeerId: _myId, chainKey: chainKey, counter: 0, isMine: true,
    );
    final group = StorageService.getGroup(groupId);
    if (group == null) return;
    final targets = group.activeMembers.map((m) => m.peerId).where((id) => id != _myId);
    for (final peerId in targets) {
      unawaited(_sendEncryptedControl(peerId, 'group_sender_key', {
        'groupId': groupId,
        'ownerPeerId': _myId,
        'chainKey': chainKey,
        'counter': 0,
      }).catchError((e) => debugPrint('[MeshRepo] échec distribution sender-key à $peerId: $e')));
    }
  }

  /// Diffuse le manifeste complet du groupe (métadonnées + tous les membres,
  /// y compris retirés — nécessaire pour propager les tombstones) à
  /// [onlyTo], ou à tous les membres actifs par défaut.
  /// Rediffuse le manifeste apres un changement de reglages (description,
  /// droit d'ecriture). Les membres gardent la version la plus recente.
  Future<void> diffuserReglagesGroupe(String groupId) =>
      _syncGroupToMembers(groupId);

  Future<void> _syncGroupToMembers(String groupId, {Iterable<String>? onlyTo}) async {
    final group = StorageService.getGroup(groupId);
    if (group == null) return;
    final payload = {
      'id': group.id,
      'name': group.name,
      'avatarUrl': group.avatarUrl,
      'createdBy': group.createdBy,
      'createdAt': group.createdAt.toIso8601String(),
      'updatedAt': group.updatedAt.toIso8601String(),
      // Les réglages voyagent avec le manifeste : une clé de plus, qu'un
      // ancien client ignore sans rien casser.
      'reglages': ReglagesGroupes.de(group.id).versJson(),
      'members': group.members.map((m) => {
        'peerId': m.peerId,
        'role': m.role,
        'addedAt': m.addedAt.toIso8601String(),
        'removedAt': m.removedAt?.toIso8601String(),
        'addedBy': m.addedBy,
      }).toList(),
    };
    final targets = (onlyTo ?? group.activeMembers.map((m) => m.peerId)).where((id) => id != _myId);
    for (final peerId in targets) {
      unawaited(_sendEncryptedControl(peerId, 'group_sync', payload)
          .catchError((e) => debugPrint('[MeshRepo] échec synchro groupe vers $peerId: $e')));
    }
  }

  /// Applique un manifeste de groupe reçu : convergence par LWW (le
  /// timestamp le plus récent, ajout ou retrait, l'emporte par membre).
  /// Réagit aux transitions d'appartenance : bootstrap de ma sender-key si
  /// je viens de devenir membre actif, rotation + nettoyage si un membre
  /// vient d'être retiré.
  Future<void> _applyGroupSync(String senderId, Map<String, dynamic> payload) async {
    final groupId = payload['id'] as String;
    final name = payload['name'] as String;
    final avatarUrl = payload['avatarUrl'] as String?;
    final createdBy = payload['createdBy'] as String;
    final createdAt = DateTime.parse(payload['createdAt'] as String);
    final updatedAt = DateTime.parse(payload['updatedAt'] as String);
    final incomingMembers = (payload['members'] as List).cast<Map<String, dynamic>>();

    final existingGroup = StorageService.getGroup(groupId);
    final previouslyActive = existingGroup?.activeMembers.map((m) => m.peerId).toSet() ?? <String>{};

    if (existingGroup == null || updatedAt.isAfter(existingGroup.updatedAt)) {
      await StorageService.upsertGroup(
        id: groupId, name: name, avatarUrl: avatarUrl,
        createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt,
      );
    }

    for (final m in incomingMembers) {
      final peerId = m['peerId'] as String;
      final role = m['role'] as String;
      final addedAt = DateTime.parse(m['addedAt'] as String);
      final removedAtRaw = m['removedAt'] as String?;
      final removedAt = removedAtRaw != null ? DateTime.parse(removedAtRaw) : null;
      final addedBy = m['addedBy'] as String;
      final incomingEventTime = removedAt ?? addedAt;

      GroupMemberRecord? local;
      for (final lm in StorageService.getGroupMembers(groupId)) {
        if (lm.peerId == peerId) { local = lm; break; }
      }
      final localEventTime = local == null ? null : (local.removedAt ?? local.addedAt);
      if (local == null || localEventTime == null || incomingEventTime.isAfter(localEventTime)) {
        await StorageService.upsertGroupMember(
          groupId: groupId, peerId: peerId, role: role,
          addedAt: addedAt, removedAt: removedAt, addedBy: addedBy,
        );
      }
    }

    ReglagesGroupes.appliquerDuSync(groupId, payload);

    final updatedGroup = StorageService.getGroup(groupId);
    if (updatedGroup == null) return;
    final nowActive = updatedGroup.activeMembers.map((m) => m.peerId).toSet();
    final isActiveNow = nowActive.contains(_myId);
    final wasActiveMember = previouslyActive.contains(_myId);

    if (isActiveNow && !wasActiveMember) {
      // Je viens de rejoindre (ou de recevoir le manifeste initial) : je ne
      // peux pas lire l'historique, mais je génère et distribue ma propre
      // sender-key pour les messages à venir.
      await _bootstrapMySenderKey(groupId);
    } else if (isActiveNow) {
      // Membres tout juste ajoutés par ce manifeste : je leur pousse ma
      // sender-key courante pour qu'ils puissent me déchiffrer.
      final newlyAdded = nowActive.difference(previouslyActive)..remove(_myId);
      for (final peerId in newlyAdded) {
        final mine = await StorageService.getGroupSenderKey(groupId, _myId);
        if (mine == null) continue;
        unawaited(_sendEncryptedControl(peerId, 'group_sender_key', {
          'groupId': groupId,
          'ownerPeerId': _myId,
          'chainKey': mine.chainKey,
          'counter': mine.counter,
        }).catchError((e) => debugPrint('[MeshRepo] échec envoi sender-key à $peerId: $e')));
      }
    }

    final justRemoved = previouslyActive.difference(nowActive);
    for (final peerId in justRemoved) {
      await StorageService.deleteGroupSenderKey(groupId, peerId);
    }
    if (isActiveNow && justRemoved.isNotEmpty) {
      await _bootstrapMySenderKey(groupId);
    }
  }

  /// Enregistre une sender-key reçue d'un autre membre (ou confirmation de
  /// la mienne, sans effet notable dans ce cas).
  Future<void> _applyIncomingSenderKey(Map<String, dynamic> payload) async {
    final groupId = payload['groupId'] as String;
    final ownerPeerId = payload['ownerPeerId'] as String;
    final chainKey = payload['chainKey'] as String;
    final counter = payload['counter'] as int;
    await StorageService.upsertGroupSenderKey(
      groupId: groupId, ownerPeerId: ownerPeerId, chainKey: chainKey, counter: counter,
      isMine: ownerPeerId == _myId,
    );
    debugPrint('[MeshRepo] sender-key reçue pour groupe $groupId de $ownerPeerId');
  }

  /// Avance ma sender-key d'un cran pour ce groupe et persiste le nouvel
  /// état. Un seul compteur de ratchet partagé pour tous les types de
  /// message (texte, fichier) que j'envoie dans ce groupe.
  Future<(SecretKey messageKey, int counter)> _advanceMySenderKey(String groupId) async {
    final keyState = await StorageService.getGroupSenderKey(groupId, _myId);
    if (keyState == null) {
      throw StateError('Aucune clé d\'envoi pour ce groupe — rejoignez-le avant d\'envoyer un message');
    }
    final (messageKey, nextChainKeyB64) = await CryptoService.ratchetForward(keyState.chainKey);
    final newCounter = keyState.counter + 1;
    await StorageService.upsertGroupSenderKey(
      groupId: groupId, ownerPeerId: _myId, chainKey: nextChainKeyB64, counter: newCounter, isMine: true,
    );
    return (messageKey, newCounter);
  }

  /// Envoie un message de groupe, chiffré avec ma sender-key courante
  /// (ratchet HMAC — un cran par message).
  Future<void> sendGroupMessage({
    required String groupId,
    required String content,
    String? replyToId,
    String? messageId,
    String? effect,
  }) async {
    final (messageKey, newCounter) = await _advanceMySenderKey(groupId);
    final (cipherText, nonce) = await CryptoService.encrypt(messageKey, content);
    final jsonMap = <String, dynamic>{
      'c': cipherText,
      's': _myId,
      'g': groupId,
      'n': nonce,
      'ctr': newCounter,
      'e': true,
    };
    if (replyToId != null) jsonMap['r'] = replyToId;
    if (messageId != null) jsonMap['m'] = messageId;
    if (effect != null) jsonMap['ef'] = effect;
    final payloadBytes = utf8.encode(json.encode(jsonMap));
    final data = Uint8List(2 + payloadBytes.length);
    data[0] = kDefaultHopCount;
    data[1] = kTextMessageType;
    data.setRange(2, data.length, payloadBytes);
    // Les membres que le mesh ne joint pas le reçoivent par Internet.
    final membres = StorageService.getGroup(groupId)?.activeMembers.map((m) => m.peerId) ?? const <String>[];
    final parInternet = await _doublerParInternet(membres, data);
    if (_transport.connectedPeerCount == 0) {
      if (parInternet == 0 && membres.any((id) => id != _myId)) {
        throw StateError('Aucun chemin vers les membres du groupe');
      }
      return;
    }
    await _enqueueReliable(
      messageId: messageId ?? 'g-${DateTime.now().microsecondsSinceEpoch}',
      targetId: groupId,
      data: data,
      priority: MessagePriority.high,
    );
  }

  Future<void> _handleGroupContent({
    required MeshIncomingData data,
    required int hopCount,
    required String groupId,
    required String? senderId,
    required String? appMsgId,
    required String cipherText,
    required String? nonce,
    required int? counter,
    required String? replyToId,
    String? effect,
  }) async {
    if (senderId == null || nonce == null || counter == null) {
      _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: groupId);
      return;
    }
    if (appMsgId != null) {
      if (_appMessageIds.containsKey(appMsgId)) {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: groupId);
        return;
      }
      _appMessageIds[appMsgId] = DateTime.now();
    }
    if (senderId == _myId) return;

    final group = StorageService.getGroup(groupId);
    if (group != null && group.isActiveMember(_myId)) {
      final content = await _decryptGroupContent(groupId, senderId, cipherText, nonce, counter);

      String authorPseudo = senderId;
      try {
        authorPseudo = _transport.connectedPeers.firstWhere((p) => p.peerId == senderId).pseudo;
      } catch (_) {
        try {
          authorPseudo = StorageService.getKnownPeers().firstWhere((p) => p.peerId == senderId).pseudo;
        } catch (_) {}
      }

      final msg = MeshMessage(
        id: appMsgId ?? data.messageId,
        authorPseudo: authorPseudo,
        content: content,
        type: 'mesh',
        timestamp: DateTime.now(),
        senderId: senderId,
        groupId: groupId,
        hopCount: hopCount,
        replyToId: replyToId,
        effect: effect,
      );
      StorageService.saveMessage(msg);
      _newMessageCtrl.add(msg);
    }

    _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: groupId);
  }

  /// Résout la clé de message pour déchiffrer un message de groupe : avance
  /// le ratchet de [senderId] jusqu'au [counter] reçu, avec tolérance au
  /// désordre (multi-hop) via un cache de clés "sautées"
  /// ([CryptoService.fastForward]). Retourne null si la clé de l'expéditeur
  /// est inconnue ou si le compteur ne peut être résolu.
  Future<SecretKey?> _resolveGroupMessageKey(String groupId, String senderId, int counter) async {
    final keyState = await StorageService.getGroupSenderKey(groupId, senderId);
    if (keyState == null) return null;

    if (counter == keyState.counter + 1) {
      final (msgKey, nextChain) = await CryptoService.ratchetForward(keyState.chainKey);
      await StorageService.upsertGroupSenderKey(
        groupId: groupId, ownerPeerId: senderId, chainKey: nextChain, counter: counter, isMine: false,
      );
      return msgKey;
    } else if (counter > keyState.counter + 1) {
      try {
        final result = await CryptoService.fastForward(keyState.chainKey, keyState.counter, counter);
        for (final entry in result.skipped.entries) {
          await StorageService.saveSkippedGroupKey(groupId, senderId, entry.key, entry.value);
        }
        await StorageService.upsertGroupSenderKey(
          groupId: groupId, ownerPeerId: senderId, chainKey: result.nextChainKeyB64, counter: counter, isMine: false,
        );
        return result.messageKey;
      } catch (e) {
        debugPrint('[MeshRepo] rattrapage ratchet groupe échoué: $e');
        return null;
      }
    } else {
      final skippedB64 = await StorageService.takeSkippedGroupKey(groupId, senderId, counter);
      return skippedB64 != null ? CryptoService.secretKeyFromBase64(skippedB64) : null;
    }
  }

  /// Déchiffre le contenu texte d'un message de groupe.
  Future<String> _decryptGroupContent(
    String groupId,
    String senderId,
    String cipherText,
    String nonce,
    int counter,
  ) async {
    final messageKey = await _resolveGroupMessageKey(groupId, senderId, counter);
    if (messageKey == null) {
      return '🔒 Message de groupe illisible (clé de l\'expéditeur manquante ou compteur dépassé)';
    }
    final decrypted = await CryptoService.decrypt(messageKey, cipherText, nonce);
    return decrypted ?? '🔒 Message de groupe illisible (échec du déchiffrement)';
  }

  // ── Transfert de fichiers (chiffré, 1:1 ou groupe) ──────────────────────
  //
  // Paquet : [hopCount][type][metaLen u16][meta JSON clair][nonceLen u8]
  // [nonce][cipher ou octets bruts]. `meta` ne porte que ce qui est
  // nécessaire au routage (identifiants, compteur de ratchet) ; le nom de
  // fichier, le type MIME et les octets sont chiffrés ensemble en un seul
  // bloc. Diffusion mesh totale (ni `t` ni `g`) : reste en clair, même
  // politique que le texte.


  // ── Fichiers chiffrés par Signal ─────────────────────────────────────
  //
  // Comme Signal pour les pièces jointes : chaque fichier est chiffré avec
  // une clé AES aléatoire, et seule CETTE clé (et son nonce) voyage dans un
  // message Signal. Chiffrer une vidéo entière avec le protocole serait lent
  // et ferait avancer la session d'un cran pour des méga-octets.
  //
  // Format : [longueur du message Signal, 4 octets][message Signal][fichier
  // chiffré en AES-GCM]. Le « nonce » transmis est le marqueur `sig3`/`sig2`.

  static int? _typeSignalOctets(Uint8List nonce) {
    if (nonce.length != 4) return null;
    return ChiffreSignal.typeDepuisMarqueur(String.fromCharCodes(nonce));
  }

  Future<(Uint8List cipher, Uint8List nonce)?> _chiffrerOctetsSignal(
    SignalService signal,
    String targetId,
    Uint8List plaintext,
  ) async {
    if (!signal.estCompatible(targetId)) return null;
    final cle = base64Decode(await CryptoService.generateChainKey());
    final (chiffreFichier, nonceFichier) =
        await CryptoService.encryptBytes(SecretKey(cle), plaintext);
    final porteur = await signal.chiffrer(targetId, Uint8List.fromList([...cle, ...nonceFichier]));
    if (porteur == null) return null;
    final message = base64Decode(porteur.contenu);
    final entete = ByteData(4)..setUint32(0, message.length);
    final sortie = BytesBuilder(copy: false)
      ..add(entete.buffer.asUint8List())
      ..add(message)
      ..add(chiffreFichier);
    return (sortie.toBytes(), Uint8List.fromList(porteur.marqueur.codeUnits));
  }

  Future<Uint8List?> _dechiffrerOctetsSignal(String senderId, Uint8List cipher, int type) async {
    final signal = SignalService.instance;
    if (signal == null || cipher.length < 4) return null;
    final longueur = ByteData.sublistView(cipher, 0, 4).getUint32(0);
    if (longueur == 0 || 4 + longueur > cipher.length) return null;
    final porteur = await signal.dechiffrer(
        senderId, base64Encode(cipher.sublist(4, 4 + longueur)), type);
    if (porteur == null || porteur.length != 44) return null;
    return CryptoService.decryptBytes(
      SecretKey(porteur.sublist(0, 32)),
      cipher.sublist(4 + longueur),
      porteur.sublist(32),
    );
  }

  final Map<String, DateTime> _nouvellesSessionsDemandees = {};

  /// Les appels manqués, posés dans la discussion (jamais envoyés).
  final _appelsDiscussionCtrl = StreamController<MeshMessage>.broadcast();
  Stream<MeshMessage> get appelsDiscussionEvents => _appelsDiscussionCtrl.stream;

  /// Comme WhatsApp : un appel manqué apparaît dans la conversation de la
  /// personne, avec de quoi la rappeler. Le message reste sur ce téléphone.
  void noterAppelDansDiscussion({
    required String peerId,
    required bool video,
    required DateTime quand,
  }) {
    if (peerId.isEmpty || peerId == _myId) return;
    final message = MeshMessage(
      id: 'appel-${quand.microsecondsSinceEpoch}-$peerId',
      authorPseudo: _pseudoDe(peerId),
      content: json.encode({'appel': 'manque', 'video': video}),
      type: 'appel',
      timestamp: quand,
      senderId: peerId,
      targetId: _myId,
      hopCount: 0,
      status: MessageStatus.sent,
    );
    unawaited(StorageService.saveMessage(message));
    _appelsDiscussionCtrl.add(message);
  }

  /// Les envois de fichier annulés par l'utilisateur.
  final Set<String> _envoisAnnules = {};

  void annulerEnvoi(String fileId) => _envoisAnnules.add(fileId);

  bool envoiAnnule(String fileId) => _envoisAnnules.contains(fileId);

  /// Un message Signal de [peerId] est illisible faute de session (ce
  /// téléphone a été réinstallé ou restauré) : on lui écrit avec une session
  /// NEUVE. La déchiffrer remplace chez lui l'ancienne, et ses messages
  /// suivants redeviennent lisibles.
  void _demanderNouvelleSession(String peerId) {
    final derniere = _nouvellesSessionsDemandees[peerId];
    if (derniere != null && DateTime.now().difference(derniere) < const Duration(minutes: 2)) {
      return;
    }
    _nouvellesSessionsDemandees[peerId] = DateTime.now();
    unawaited(() async {
      await SignalService.instance?.oublierSession(peerId);
      await _sendEncryptedControl(
          peerId, 'sgreset', {'ts': DateTime.now().toUtc().toIso8601String()});
    }().catchError((Object e) {
      debugPrint('[MeshRepo] nouvelle session Signal non demandée: $e');
    }));
  }

  static const int _kFileNonceMax = 32;

  Future<(Uint8List cipher, Uint8List nonce)> _encryptBytesForPeer(String targetId, Uint8List plaintext) async {
    final signal = SignalService.instance;
    if (signal != null) {
      final chiffre = await _chiffrerOctetsSignal(signal, targetId, plaintext);
      if (chiffre != null) return chiffre;
    }
    final peerPublicKey = await _resolvePeerPublicKey(targetId);
    final sharedKey = await CryptoService.sharedKeyWithPeer(targetId, peerPublicKey);
    if (sharedKey == null) {
      throw StateError('Clé publique de $targetId inconnue — chiffrement impossible pour le moment');
    }
    return CryptoService.encryptBytes(sharedKey, plaintext);
  }

  /// Encode nom + type + octets dans l'enveloppe binaire commune à TOUT
  /// envoi de fichier, quel que soit le chemin emprunté ensuite (mesh
  /// direct dans [sendFile] ci-dessous, ou mailbox .onion dans
  /// `MeshNotifier._tryMailboxSendFile`).
  ///
  /// Format : `[longueur du nom, 2 octets][nom][longueur du type, 1
  /// octet][type][octets du fichier]`.
  ///
  /// ⚠️ UNE SEULE VERSION DE CE FORMAT. Avant, cet assemblage vivait
  /// directement dans `sendFile`, et son décodage ailleurs dans ce même
  /// fichier — deux copies d'un même format binaire qui auraient fini par
  /// diverger le jour où l'une des deux aurait changé sans l'autre.
  // ── La LÉGENDE d'une photo ou d'une vidéo ────────────────────────────
  //
  // ⚠️ ELLE VOYAGE DANS LE TYPE MIME, et c'est volontaire.
  //
  // L'enveloppe d'un fichier a un format binaire figé : y ajouter un champ
  // casserait la réception sur tous les téléphones pas encore mis à jour.
  // Un type MIME, lui, accepte des paramètres depuis toujours
  // (`image/jpeg;lg=<légende en base64>`) : une version ancienne lit
  // « image/jpeg… », voit une image, et ignore le reste. La légende reste
  // chiffrée avec le fichier, puisqu'elle est DANS l'enveloppe.

  static String mimeAvecLegende(String mimeType, String? legende) {
    final texte = legende?.trim() ?? '';
    if (texte.isEmpty) return mimeType;
    return '$mimeType;lg=${base64Url.encode(utf8.encode(texte))}';
  }

  static (String mimeType, String? legende) separerLegende(String mimeType) {
    final i = mimeType.indexOf(';lg=');
    if (i < 0) return (mimeType, null);
    final propre = mimeType.substring(0, i);
    try {
      final texte = utf8.decode(base64Url.decode(mimeType.substring(i + 4))).trim();
      return (propre, texte.isEmpty ? null : texte);
    } catch (_) {
      return (propre, null);
    }
  }

  static Uint8List encodeFileEnvelope({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) {
    final nameBytes = Uint8List.fromList(utf8.encode(fileName));
    final mimeBytes = Uint8List.fromList(utf8.encode(mimeType));
    return (BytesBuilder()
          ..addByte((nameBytes.length >> 8) & 0xFF)
          ..addByte(nameBytes.length & 0xFF)
          ..add(nameBytes)
          ..addByte(mimeBytes.length & 0xFF)
          ..add(mimeBytes)
          ..add(bytes))
        .toBytes();
  }

  /// Décode l'enveloppe produite par [encodeFileEnvelope]. `null` si les
  /// octets sont trop courts pour être une enveloppe valide — un fichier
  /// tronqué ou corrompu en chemin, plutôt qu'une exception qui remonterait
  /// jusqu'à faire échouer toute la réception.
  static (String fileName, String mimeType, Uint8List bytes)?
      decodeFileEnvelope(Uint8List plain) {
    if (plain.length < 3) return null;
    final nameLen = (plain[0] << 8) | plain[1];
    if (plain.length < 2 + nameLen + 1) return null;
    final fileName = utf8.decode(plain.sublist(2, 2 + nameLen));
    final mimeLen = plain[2 + nameLen];
    final mimeStart = 2 + nameLen + 1;
    if (plain.length < mimeStart + mimeLen) return null;
    final mimeType = utf8.decode(plain.sublist(mimeStart, mimeStart + mimeLen));
    final fileBytes = plain.sublist(mimeStart + mimeLen);
    return (fileName, mimeType, fileBytes);
  }

  /// Envoie un fichier (photo, document, message vocal) — chiffré pour un
  /// destinataire 1:1 ([targetId]) ou un groupe ([groupId], via ma
  /// sender-key courante). Ni l'un ni l'autre : diffusion mesh en clair.
  Future<void> sendFile({
    required String fileName,
    required Uint8List bytes,
    String mimeType = '',
    String? targetId,
    String? groupId,
    String? fileId,
    String? replyToId,
    bool forStatus = false,
    String? avatarEmpreinte,
    /// Distingue plusieurs envois du MÊME fichier (statut adressé à
    /// plusieurs personnes) dans la file fiable.
    String suffixeEnvoi = '',
  }) async {
    // Contact bloqué : rien ne part vers lui.
    if (groupId == null && targetId != null && StorageService.isContactBlocked(targetId)) return;
    final id = fileId ?? StorageService.generateId();
    final plain = encodeFileEnvelope(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    );

    Uint8List payload;
    Uint8List nonce;
    int? counter;
    final encrypted = targetId != null || groupId != null;

    if (groupId != null) {
      final (messageKey, newCounter) = await _advanceMySenderKey(groupId);
      counter = newCounter;
      (payload, nonce) = await CryptoService.encryptBytes(messageKey, plain);
    } else if (targetId != null) {
      (payload, nonce) = await _encryptBytesForPeer(targetId, plain);
    } else {
      payload = plain;
      nonce = Uint8List(0);
    }

    final meta = <String, dynamic>{'fileId': id, 's': _myId, 'sz': bytes.length};
    if (targetId != null) meta['t'] = targetId;
    if (groupId != null) {
      meta['g'] = groupId;
      meta['ctr'] = counter;
    }
    if (encrypted) meta['e'] = true;
    // `r` = le message auquel celui-ci répond. Indispensable pour
    // répondre à un vocal par un vocal : sans ce champ, le destinataire
    // recevrait la réponse détachée de la question.
    if (replyToId != null) meta['r'] = replyToId;
    // `st` = ce fichier accompagne un statut, il ne doit PAS apparaître
    // comme une pièce jointe dans une conversation. Sans ce marqueur, la
    // photo d'un statut atterrirait aussi dans le fil « Diffusion »,
    // affichée deux fois et sortie de son contexte.
    if (forStatus) meta['st'] = true;
    // `av` = ce fichier est une PHOTO DE PROFIL (son empreinte). Le
    // destinataire la range dans ses avatars, jamais dans une conversation.
    if (avatarEmpreinte != null) meta['av'] = avatarEmpreinte;

    // ⚠️ AU-DELÀ DE 256 KIO, LE FICHIER PART EN MORCEAUX. Chaque morceau est
    // un paquet fiable ordinaire — acquitté, relayé et retenté seul — et
    // c'est son acquittement qui fait avancer la barre de progression. Voir
    // `fichier_morcele.dart`. Un morceau après l'autre : la file fiable
    // n'est pas noyée et la progression reste régulière.
    // Qui reçoit AUSSI par Internet : les membres d'un groupe, et — c'est ce
    // qui manquait — les destinataires d'un média de STATUT. Seule l'annonce
    // d'un statut partait en ligne : les contacts éloignés voyaient un statut
    // photo… sans sa photo.
    final List<String> parInternet = groupId != null
        ? _destinatairesDe(groupId).toList()
        : forStatus
            ? (targetId != null ? [targetId] : _contactsPourStatut().toList())
            : const [];

    if (FichierMorcele.doitMorceler(payload.length)) {
      final morceaux = FichierMorcele.decouper(payload);
      _fileProgressCtrl.add((fileId: id, progression: 0, envoi: true));
      var envoyes = 0;
      for (var i = 0; i < morceaux.length; i++) {
        // Annulé depuis la bulle : les morceaux restants ne partent pas.
        if (_envoisAnnules.contains(id)) return;
        final paquetMorceau = PaquetMorceau.encoder(
          sauts: kDefaultHopCount,
          type: kFileChunkType,
          meta: {
            ...meta,
            'i': i,
            'n': morceaux.length,
            'psz': payload.length,
            'nc': base64Encode(nonce),
          },
          morceau: morceaux[i],
        );
        // Fichier de groupe : chaque morceau part aussi par Internet vers les
        // membres hors mesh — et seulement par là s'il n'y a aucun voisin.
        if (parInternet.isNotEmpty) {
          await _doublerParInternet(parInternet, paquetMorceau);
          if (_transport.connectedPeerCount == 0) {
            envoyes += morceaux[i].length;
            _fileProgressCtrl.add((
              fileId: id,
              progression: payload.isEmpty ? 1 : envoyes / payload.length,
              envoi: true,
            ));
            continue;
          }
        }
        await _enqueueReliable(
          messageId: 'file-$id-$i$suffixeEnvoi',
          targetId: targetId ?? groupId ?? 'broadcast',
          data: paquetMorceau,
          priority: MessagePriority.high,
        );
        envoyes += morceaux[i].length;
        _fileProgressCtrl.add((
          fileId: id,
          progression: payload.isEmpty ? 1 : envoyes / payload.length,
          envoi: true,
        ));
      }
      return;
    }

    final metaBytes = Uint8List.fromList(utf8.encode(json.encode(meta)));
    final packet = (BytesBuilder()
          ..addByte(kDefaultHopCount)
          ..addByte(kFileTransferType)
          ..addByte((metaBytes.length >> 8) & 0xFF)
          ..addByte(metaBytes.length & 0xFF)
          ..add(metaBytes)
          ..addByte(nonce.length)
          ..add(nonce)
          ..add(payload))
        .toBytes();

    _fileProgressCtrl.add((fileId: id, progression: 0, envoi: true));
    if (parInternet.isNotEmpty) {
      await _doublerParInternet(parInternet, packet);
      if (_transport.connectedPeerCount == 0) {
        _fileProgressCtrl.add((fileId: id, progression: 1, envoi: true));
        return;
      }
    }
    await _enqueueReliable(
      messageId: 'file-$id$suffixeEnvoi',
      targetId: targetId ?? groupId ?? 'broadcast',
      data: packet,
      priority: MessagePriority.high,
    );
    _fileProgressCtrl.add((fileId: id, progression: 1, envoi: true));
  }

  /// Envoie MA photo de profil à [peerId] — seulement si c'est un contact
  /// (règle « Mes contacts », `contacts.dart`) et si j'en ai une.
  Future<void> _envoyerMonAvatarA(String peerId) async {
    // Contact bloqué : rien ne part vers lui.
    if (StorageService.isContactBlocked(peerId)) return;
    if (!estUnContact(StorageService.getMessages(), _myId, peerId)) {
      debugPrint('[MeshRepo] photo non envoyée à $peerId : pas un contact');
      return;
    }
    final octets = AvatarService.mesOctets();
    final empreinte = AvatarService.monEmpreinte();
    if (octets == null || empreinte == null) return;
    try {
      await sendFile(
        fileName: 'avatar.jpg',
        bytes: octets,
        mimeType: 'image/jpeg',
        targetId: peerId,
        avatarEmpreinte: empreinte,
      );
      debugPrint('[MeshRepo] photo de profil envoyée à $peerId');
    } catch (e) {
      debugPrint('[MeshRepo] envoi de la photo à $peerId impossible: $e');
    }
  }

  /// Reçoit un fichier : découpe le paquet (métadonnées, nonce, contenu),
  /// vérifie s'il m'est destiné, le déchiffre selon le contexte (1:1,
  /// groupe, ou en clair), et le range dans le stockage local si tout se
  /// passe bien.
  Future<void> _handleFileTransfer(MeshIncomingData data, int hopCount) async {
    try {
      final bytes = data.data;
      if (bytes.length < 5) return;
      final metaLen = (bytes[2] << 8) | bytes[3];
      if (bytes.length < 5 + metaLen) return;
      final meta = json.decode(utf8.decode(bytes.sublist(4, 4 + metaLen))) as Map<String, dynamic>;

      int offset = 4 + metaLen;
      final nonceLen = bytes[offset];
      offset += 1;
      if (nonceLen > _kFileNonceMax || bytes.length < offset + nonceLen) return;
      final nonce = bytes.sublist(offset, offset + nonceLen);
      offset += nonceLen;
      final payload = bytes.sublist(offset);

      final fileId = meta['fileId'] as String;
      final senderId = meta['s'] as String?;
      final targetId = meta['t'] as String?;
      final groupId = meta['g'] as String?;

      // Chat dirigé : si ce fichier ne m'est pas destiné, on ne fait que le
      // relayer (store-and-forward) sans le traiter.
      if (groupId == null && targetId != null && targetId != _myId) {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }
      if (groupId == null && senderId != null && StorageService.isContactBlocked(senderId)) return;

      if (_appMessageIds.containsKey(fileId)) {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: groupId ?? targetId);
        return;
      }
      _appMessageIds[fileId] = DateTime.now();

      if (senderId == _myId) {
        _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: targetId);
        return;
      }

      await _terminerFichierRecu(
        meta: meta,
        nonce: nonce,
        payload: payload,
        peerIdVoisin: data.peerId,
        hopCount: hopCount,
      );

      _relayOrDefer(data.messageId, data.data, hopCount, excludePeerId: data.peerId, targetId: groupId ?? targetId);
    } catch (e) {
      debugPrint('[MeshRepo] Erreur réception fichier: $e');
    }
  }

  /// Déchiffre, enregistre et publie un fichier REÇU EN ENTIER — arrivé en
  /// un seul paquet ou reconstitué depuis ses morceaux. Une seule
  /// implémentation, pour que les deux chemins ne puissent pas diverger.
  ///
  /// Si [remplacer] est vrai, une bulle « réception en cours » existe déjà
  /// sous l'identifiant du fichier : elle est remplacée, pas doublée.
  Future<void> _terminerFichierRecu({
    required Map<String, dynamic> meta,
    required Uint8List nonce,
    required Uint8List payload,
    required String peerIdVoisin,
    required int hopCount,
    bool remplacer = false,
  }) async {
    final fileId = meta['fileId'] as String;
    final senderId = meta['s'] as String?;
    final targetId = meta['t'] as String?;
    final groupId = meta['g'] as String?;
    final counter = meta['ctr'] as int?;
    final encrypted = meta['e'] as bool? ?? false;
    final replyToId = meta['r'] as String?;
    final forStatus = meta['st'] as bool? ?? false;
    final avatarEmpreinte = meta['av'] as String?;

    Uint8List? plainBytes;
    if (!encrypted) {
      plainBytes = payload;
    } else if (groupId != null) {
      final group = StorageService.getGroup(groupId);
      if (group != null && group.isActiveMember(_myId) && senderId != null && counter != null) {
        final key = await _resolveGroupMessageKey(groupId, senderId, counter);
        if (key != null) plainBytes = await CryptoService.decryptBytes(key, payload, nonce);
      }
    } else if (senderId != null && _typeSignalOctets(nonce) != null) {
      // Jamais pour un fichier destiné à quelqu'un d'autre (voir
      // `resolveIncomingContent`).
      if (targetId == null || targetId == _myId) {
        plainBytes = await _dechiffrerOctetsSignal(senderId, payload, _typeSignalOctets(nonce)!);
      }
    } else if (senderId != null) {
      final peerPublicKey = _peerPublicKeyFromCaches(senderId);
      final sharedKey = await CryptoService.sharedKeyWithPeer(senderId, peerPublicKey);
      if (sharedKey != null) plainBytes = await CryptoService.decryptBytes(sharedKey, payload, nonce);
    }

    final envelope = plainBytes != null ? decodeFileEnvelope(plainBytes) : null;
    if (envelope == null) {
      debugPrint('[MeshRepo] fichier $fileId indéchiffrable (clé absente ?)');
      return;
    }
    final (fileName, mimeType, fileBytes) = envelope;

    // Une photo de profil n'est PAS un message : elle rejoint les avatars,
    // et seulement si ses octets correspondent à l'empreinte annoncée par
    // l'expéditeur lui-même.
    if (avatarEmpreinte != null) {
      if (senderId != null &&
          await AvatarService.enregistrerPair(senderId, fileBytes, avatarEmpreinte)) {
        debugPrint('[MeshRepo] photo de profil reçue de $senderId');
        _peerAvatarCtrl.add(senderId);
      }
      return;
    }

    await StorageService.saveSharedFile(fileId: fileId, fileName: fileName, bytes: fileBytes);

    // Média d'un statut : on le range et on s'arrête là. C'est l'annonce du
    // statut, arrivée séparément, qui saura qu'il existe et où le trouver.
    if (forStatus) {
      debugPrint('[MeshRepo] Média de statut reçu: $fileName (${fileBytes.length} octets)');
      _statusMediaCtrl.add(fileId);
      return;
    }

    final (mimePropre, legende) = separerLegende(mimeType);
    final msg = MeshMessage(
      id: fileId,
      authorPseudo: _pseudoDe(senderId ?? peerIdVoisin),
      // La légende prend la place du nom de fichier : c'est elle qu'on lit
      // sous la photo, et dans l'aperçu d'une notification.
      content: legende ?? fileName,
      type: 'file',
      timestamp: DateTime.now(),
      senderId: senderId ?? peerIdVoisin,
      targetId: targetId,
      groupId: groupId,
      fileId: fileId,
      fileName: fileName,
      fileSize: fileBytes.length,
      fileMimeType: mimePropre,
      replyToId: replyToId,
      hopCount: hopCount,
    );
    if (remplacer) {
      await StorageService.replaceMessage(msg);
      _repairedMessagesCtrl.add(fileId);
    } else {
      StorageService.saveMessage(msg);
      _newMessageCtrl.add(msg);
    }
    _fileProgressCtrl.add((fileId: fileId, progression: 1, envoi: false));
    debugPrint('[MeshRepo] Fichier reçu: $fileName (${fileBytes.length} octets)');
  }

  /// Un MORCEAU de fichier (type `0x31`). Mêmes règles de relais que le
  /// fichier en un seul paquet. Pour nous, le morceau rejoint son
  /// réassemblage et fait avancer la progression ; le fichier est terminé
  /// dès le dernier morceau reçu, quel que soit l'ordre d'arrivée.
  Future<void> _handleFileChunk(MeshIncomingData data, int hopCount) async {
    try {
      final decode = PaquetMorceau.decoder(data.data);
      if (decode == null) return;
      final meta = decode.meta;
      final fileId = meta['fileId'] as String;
      final senderId = meta['s'] as String?;
      final targetId = meta['t'] as String?;
      final groupId = meta['g'] as String?;
      final index = meta['i'] as int;
      final total = meta['n'] as int;
      final tailleTotale = meta['psz'] as int;

      // Pas pour nous (1:1 vers quelqu'un d'autre), ou notre propre envoi
      // qui revient : on relaie seulement.
      if ((groupId == null && targetId != null && targetId != _myId) || senderId == _myId) {
        _relayOrDefer(data.messageId, data.data, hopCount,
            excludePeerId: data.peerId, targetId: groupId ?? targetId);
        return;
      }

      final now = DateTime.now();
      _assemblages.removeWhere((_, a) => now.difference(a.dernierAjout) > const Duration(minutes: 15));
      _assemblagesMeta.removeWhere((id, _) => !_assemblages.containsKey(id));
      _fichiersTermines.removeWhere((_, t) => now.difference(t) > const Duration(hours: 1));

      if (!_fichiersTermines.containsKey(fileId)) {
        final nouveau = !_assemblages.containsKey(fileId);
        final assemblage = _assemblages.putIfAbsent(
            fileId, () => AssemblageFichier(total: total, tailleTotale: tailleTotale));
        _assemblagesMeta.putIfAbsent(fileId, () => meta);

        final bulleReception = meta['av'] == null && meta['st'] != true;
        if (nouveau && bulleReception &&
            !StorageService.getMessages().any((m) => m.id == fileId)) {
          // La bulle « réception en cours », visible dès le premier morceau.
          // Sans nom ni type : ils sont dans l'enveloppe chiffrée.
          final bulle = MeshMessage(
            id: fileId,
            authorPseudo: _pseudoDe(senderId ?? data.peerId),
            content: '',
            type: 'file',
            timestamp: now,
            senderId: senderId ?? data.peerId,
            targetId: targetId,
            groupId: groupId,
            fileId: fileId,
            fileName: '',
            fileSize: tailleTotale,
            hopCount: hopCount,
          );
          await StorageService.saveMessage(bulle);
          _newMessageCtrl.add(bulle);
        }

        if (assemblage.ajouter(index, decode.morceau)) {
          _fileProgressCtrl.add((fileId: fileId, progression: assemblage.progression, envoi: false));
        }

        if (assemblage.complet) {
          final metaInitiale = _assemblagesMeta.remove(fileId) ?? meta;
          final payload = assemblage.assembler();
          _assemblages.remove(fileId);
          _fichiersTermines[fileId] = now;
          final nonce = base64Decode(metaInitiale['nc'] as String? ?? '');
          if (nonce.length <= _kFileNonceMax) {
            await _terminerFichierRecu(
              meta: metaInitiale,
              nonce: nonce,
              payload: payload,
              peerIdVoisin: data.peerId,
              hopCount: hopCount,
              remplacer: bulleReception,
            );
          }
        }
      }

      _relayOrDefer(data.messageId, data.data, hopCount,
          excludePeerId: data.peerId, targetId: groupId ?? targetId);
    } catch (e) {
      debugPrint('[MeshRepo] Erreur réception morceau: $e');
    }
  }

  /// Le pseudo connu d'un pair, sinon son identifiant.
  String _pseudoDe(String peerId) {
    for (final p in _transport.connectedPeers) {
      if (p.peerId == peerId) return p.pseudo;
    }
    return StorageService.getPeerRecord(peerId)?.pseudo ?? peerId;
  }
}
