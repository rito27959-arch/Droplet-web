// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Ce fichier fait le lien entre le « cerveau » du mesh
// (`mesh_repository.dart`, qui gère le vrai réseau) et tout ce que
// l'utilisateur VOIT à l'écran (la liste des conversations, les bulles
// de messages, l'écran d'appel...). C'est ce qu'on appelle des
// « providers Riverpod » — des petites boîtes qui contiennent un
// morceau d'état de l'app (par exemple « la liste des messages » ou
// « est-ce qu'un appel est en cours ? ») et qui préviennent
// AUTOMATIQUEMENT tous les écrans concernés dès que ce morceau change.
//
// Analogie : imagine un tableau d'affichage électronique dans une gare.
// Le repository, c'est le train qui arrive avec de nouvelles infos ; ce
// fichier, c'est le tableau d'affichage qui se met à jour tout seul dès
// que le train est là — et chaque écran de l'app (la liste des
// conversations, la bulle d'un message, l'icône « en train d'écrire »)
// regarde ce tableau au lieu d'aller lui-même demander au train.
//
// Le fichier est organisé en grandes sections, séparées par des
// commentaires en bandeau (════) : le petit système de « toast »
// (messages qui apparaissent brièvement en bas de l'écran), les
// messages/fichiers envoyés, les appels individuels, les appels de
// groupe, la liste des pairs connectés, et la construction de la liste
// des conversations affichées à l'écran d'accueil.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mesh_message.dart';
import '../models/voice_note_meta.dart';
import '../../features/chat/mise_en_forme.dart';
import '../../features/chat/location_message.dart';
import '../../features/chat/poll_message.dart';
import '../services/nom_pair.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/mesh_transport_service.dart';
import '../services/ble_mesh_protocol.dart';
import '../services/call_signaling_service.dart';
import '../services/webrtc_call_service.dart';
import '../services/call_ringer_service.dart';
import '../services/group_webrtc_call_service.dart';
import '../services/appel_systeme.dart';
import '../services/notification_service.dart';
import '../services/fichier_en_ligne.dart';
import 'package:path_provider/path_provider.dart';
import '../services/push_notification_service.dart';
import '../services/call_service.dart' as remote_call;
import '../services/signaling_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../repositories/mesh_repository.dart';
import 'tor_providers.dart';
import '../../features/chat/animated_sticker.dart';
import '../services/accuses_en_ligne.dart';
import '../services/etat_connexion.dart';
import '../services/etat_internet.dart';
import '../services/epingles.dart';
import '../services/media_service.dart';
import '../services/sauvegarde_en_ligne.dart';
import '../services/signal/signal_service.dart';
import '../services/appel_groupe_internet.dart';
import '../../features/call/salon_vocal.dart';
import '../config/server_config.dart';
import '../models/apercu_systeme.dart';
import '../../features/chat/messages_ephemeres.dart';

/// Description lisible d'un contenu de message pour les previews.
///
/// Les stickers animés ne doivent PAS afficher leur référence technique
/// (🎞tgs:fetes/confettis) dans la liste des conversations — on affiche
/// un label lisible à la place.
/// Un lien s'annonce par son domaine : une URL brute sur deux lignes ne dit
/// rien et casse le rythme de la liste.
String _apercuLien(String texte) {
  final m = RegExp(r'https?://([^/\s]+)').firstMatch(texte);
  if (m == null) return texte;
  final hote = m.group(1)!.replaceFirst('www.', '');
  return texte.trim() == m.group(0) ? '🔗 $hote' : texte;
}

String _describeForPreview(MeshMessage last) {
  if (last.type == 'appel') {
    return last.content.contains('"video":true')
        ? ApercuSysteme.appelVideoManque
        : ApercuSysteme.appelManque;
  }
  if (last.type == 'file') {
    // Le vocal garde sa durée ; le reste est dit par ce que c'est.
    if (VoiceNoteMeta.isVoiceNote(last.fileName)) {
      return VoiceNoteMeta.describeAttachment(last.fileName);
    }
    return ApercuSysteme.pourFichier(last.fileName);
  }
  if (AnimatedStickerCatalog.estUneReference(last.content)) {
    return '🎞 ${AnimatedStickerCatalog.nomLisible(last.content)}';
  }
  final pollDescribed = PollMessage.describe(last.content);
  if (pollDescribed != last.content) return pollDescribed;
  // Un aperçu ne porte pas de style : on retire les marqueurs plutôt que
  // d'afficher « **Salut** » dans la liste des discussions.
  return _apercuLien(MiseEnForme.sansMarqueurs(
    LocationMessage.describe(Ephemeres.sansMarque(last.content)),
  ));
}

// ── Toast minimal (remplace mesh_toast de l'app éducative) ─────────────────
//
// Un « toast », c'est ce petit message qui apparaît brièvement en bas de
// l'écran (« Message envoyé », « Erreur »...) puis disparaît tout seul
// après 3 secondes — comme une petite pastille de pain qui saute hors du
// grille-pain puis qu'on range.

enum DropletToastType { info, success, warning, error }

class DropletToast {
  final String message;
  final DropletToastType type;
  const DropletToast(this.message, {this.type = DropletToastType.info});
}

final toastProvider = StateNotifierProvider<ToastNotifier, DropletToast?>((ref) {
  return ToastNotifier();
});

class ToastNotifier extends StateNotifier<DropletToast?> {
  ToastNotifier() : super(null);
  Timer? _timer;

  void show(String msg, {DropletToastType type = DropletToastType.info}) {
    _timer?.cancel();
    state = DropletToast(msg, type: type);
    _timer = Timer(const Duration(seconds: 3), () => state = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ── Providers mesh ─────────────────────────────────────────────────────────

/// La seule instance du repository mesh pour toute l'app — tout le monde
/// (liste de conversations, écran de chat, écran d'appel...) regarde
/// vers CE MÊME repository, jamais une copie.
final meshRepositoryProvider = Provider<MeshRepository>((ref) {
  // ⚠️ LE SERVICE TOR DOIT ÊTRE TRANSMIS ICI — SANS LUI, TOUT LE EN-LIGNE
  // ÉTAIT MORT, MÊME AVEC TOR CONNECTÉ.
  //
  // Ce fournisseur construisait `MeshRepository()` nu, donc
  // `MeshTransportService()` sans `torService`, donc `_torTransport = null`
  // pour toute la vie de l'application. Constaté sur un Pixel 6 Pro : le
  // circuit Tor s'établissait en 3 secondes, et 7 secondes plus tard la
  // recherche par pseudo répondait « Tor non disponible pour la recherche »,
  // la boîte aux lettres « Tor non disponible pour la mailbox ». L'appareil
  // ne s'inscrivait jamais dans l'annuaire, aucun message ne transitait en
  // ligne. Le Tor allumé depuis les réglages était une instance que personne
  // d'autre n'utilisait.
  //
  // C'est la MÊME instance que `torServiceProvider` qui doit circuler :
  // l'écran de réglages l'allume, le transport en écoute l'état.
  final torService = ref.watch(torServiceProvider);
  final repo = MeshRepository(
    transport: MeshTransportService(torService: torService),
  );
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// Progression des fichiers en cours d'envoi ou de réception, par
/// identifiant de fichier (0 à 1). Une entrée disparaît dès que le fichier
/// est complet : la bulle affiche alors le vrai média.
final fileProgressProvider = StateNotifierProvider<FileProgressNotifier,
    Map<String, ({double progression, bool envoi})>>((ref) {
  return FileProgressNotifier(ref.watch(meshRepositoryProvider));
});

class FileProgressNotifier
    extends StateNotifier<Map<String, ({double progression, bool envoi})>> {
  FileProgressNotifier(MeshRepository repo) : super(const {}) {
    _sub = repo.fileProgressEvents.listen((e) {
      if (e.progression >= 1) {
        if (!state.containsKey(e.fileId)) return;
        state = {...state}..remove(e.fileId);
      } else {
        state = {...state, e.fileId: (progression: e.progression, envoi: e.envoi)};
      }
    });
  }

  late final StreamSubscription<({String fileId, double progression, bool envoi})> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Augmente à chaque photo de profil reçue ou retirée : les écrans qui
/// affichent des avatars l'observent pour se redessiner.
final peerAvatarRevisionProvider =
    StateNotifierProvider<PeerAvatarRevisionNotifier, int>((ref) {
  return PeerAvatarRevisionNotifier(ref.watch(meshRepositoryProvider));
});

class PeerAvatarRevisionNotifier extends StateNotifier<int> {
  PeerAvatarRevisionNotifier(MeshRepository repo) : super(0) {
    _sub = repo.peerAvatarEvents.listen((_) => state++);
  }

  late final StreamSubscription<String> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final meshMessagesProvider =
    StateNotifierProvider<MeshNotifier, List<MeshMessage>>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  void showToast(String msg, {DropletToastType type = DropletToastType.info}) {
    ref.read(toastProvider.notifier).show(msg, type: type);
  }
  return MeshNotifier(repo, showToast);
});

final meshStatsProvider = Provider<MeshStats>((ref) {
  final peers = ref.watch(meshPeerListProvider);
  return _buildRealStats(peers: peers);
});

/// Calcule les statistiques affichées sur l'écran de contribution
/// (combien de données distribuées, combien de fichiers relayés, etc.).
MeshStats _buildRealStats({List<ConnectedPeer> peers = const []}) {
  final messages = StorageService.getMessages();
  final relayedFiles = messages.where((m) => m.type == 'file').length;
  final totalMessages = messages.length;
  final estimatedGb = totalMessages * 0.001;
  final uniqueAuthors = messages.map((m) => m.authorPseudo).toSet().length;
  final bleCount = peers.where((p) => p.transports.contains(TransportKind.ble)).length;
  final wifiCount = peers.where((p) => p.transports.contains(TransportKind.localWifi)).length;
  final nativeCount = peers.where((p) => p.transports.contains(TransportKind.nativeP2P)).length;

  return MeshStats(
    distributedGb: double.parse(estimatedGb.toStringAsFixed(2)),
    relayedFiles: relayedFiles,
    helpedPeers: uniqueAuthors,
    totalPeers: peers.length,
    blePeers: bleCount,
    wifiPeers: wifiCount,
    nativePeers: nativeCount,
  );
}

/// Santé en temps réel du mesh (multi‑transport, fiabilité, ACK).
final meshHealthProvider = StreamProvider<MeshHealth>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return repo.transport.healthEvents;
});

/// ACK d'un message spécifique.
final messageAckProvider = Provider.family<int, String>((ref, messageId) {
  final repo = ref.watch(meshRepositoryProvider);
  return repo.getAckCount(messageId);
});

/// Le gardien de TOUS les messages affichés dans l'app : envoie les
/// nouveaux messages/fichiers, suit leur statut (en cours, envoyé,
/// échoué), gère la « boîte d'attente » (outbox) pour les messages
/// tapés quand personne n'est connecté, et écoute tout ce qui arrive du
/// repository pour mettre à jour l'écran automatiquement.
class MeshNotifier extends StateNotifier<List<MeshMessage>> {
  final MeshRepository _repo;
  final void Function(String, {DropletToastType type}) _showToast;
  StreamSubscription<void>? _peerSub;
  StreamSubscription<String>? _ackSub;
  StreamSubscription<String>? _readSub;
  StreamSubscription<({String messageId, String emoji})>? _reactionSub;
  StreamSubscription<({String messageId, String newContent, String senderId})>? _editSub;
  StreamSubscription<
      ({String messageId, bool epingle, String senderId, String? groupId})>? _epingleSub;
  StreamSubscription<MeshMessage>? _newMessageSub;
  StreamSubscription<MeshMessage>? _appelsSub;
  StreamSubscription<String>? _repairedSub;
  Timer? _readDelayTimer;
  Timer? _mailboxPollTimer;

  /// Événements de réaction entrants (pour déclencher l'overlay côté UI).
  final _reactionEventCtrl = StreamController<({String messageId, String emoji})>.broadcast();
  Stream<({String messageId, String emoji})> get reactionEvents => _reactionEventCtrl.stream;

  /// Messages en attente d'envoi (0 pair connecté au moment du tap).
  final List<_OutboxEntry> _outbox = [];

  /// Génération de l'outbox — incémentée à chaque ajout. Permet de
  /// détecter si de nouveaux messages sont arrivés pendant qu'on vidait
  /// la file, et de relancer un flush si nécessaire.
  int _outboxGeneration = 0;

  /// Ajoute une entrée à l'outbox et incrémente la génération.
  void _addToOutbox(_OutboxEntry entry) {
    _outbox.add(entry);
    _outboxGeneration++;
  }

  MeshNotifier(this._repo, this._showToast) : super(StorageService.getMessages()) {
    _peerSub = _repo.peerEvents?.listen((_) => _flushOutbox());
    _ackSub = _repo.ackEvents.listen((messageId) {
      // Haptique de livraison : vibrer légèrement quand un message arrive
      // à destination. iMessage ne fait rien — on fait mieux.
      HapticFeedback.lightImpact();
      state = state.map((m) {
        if (m.id != messageId) return m;
        return m.copyWith(deliveryCount: _repo.getAckCount(messageId));
      }).toList();
    });
    _readSub = _repo.readEvents.listen((messageId) {
      HapticFeedback.mediumImpact();
      final now = DateTime.now();
      state = state.map((m) {
        if (m.id != messageId || m.readAt != null) return m;
        return m.copyWith(readAt: now);
      }).toList();
      unawaited(StorageService.updateMessageReadAt(messageId, now));
      // Messages éphémères : marquer la première lecture et démarrer le
      // timer de disparition.
      final msg = state.where((m) => m.id == messageId).firstOrNull;
      if (msg != null) _markFirstRead(msg);
    });
    _reactionSub = _repo.reactionEvents.listen((evt) {
      _reactionEventCtrl.add(evt);
    });
    _editSub = _repo.editEvents.listen((evt) {
      applyRemoteEdit(evt.messageId, evt.newContent, auteur: evt.senderId);
    });
    _epingleSub = _repo.epingleEvents.listen(_appliquerEpingleRecu);
    // Un appel manqué rejoint la conversation de la personne.
    _appelsSub = _repo.appelsDiscussionEvents.listen((appel) {
      if (state.any((m) => m.id == appel.id)) return;
      state = [...state, appel];
    });
    _newMessageSub = _repo.newMessageEvents.listen((msg) {
      if (state.any((m) => m.id == msg.id)) return;
      state = [...state, msg];
      _accuserReceptionEnLigne(msg);
    });

    // Un message reçu avant la clé de son auteur s'affiche « illisible » ;
    // dès que la clé arrive, le dépôt le répare et prévient ici, pour que
    // la bulle déjà à l'écran se remplace toute seule par le vrai texte.
    _repairedSub = _repo.repairedMessageEvents.listen((messageId) {
      final repaired = StorageService.getMessages()
          .where((m) => m.id == messageId)
          .firstOrNull;
      if (repaired == null) return;
      state = [
        for (final m in state) m.id == messageId ? repaired : m,
      ];
    });

    _loadOutbox();
    _startEphemeralChecker();
  }

  /// Charge la file d'attente persistée au démarrage — les messages
  /// qu'on n'avait pas réussi à envoyer avant la dernière fermeture de
  /// l'app, pour réessayer.
  void _loadOutbox() {
    final stored = StorageService.getOutbox();
    for (final entry in stored) {
      final kind = entry['kind'] as String?;
      if (kind == 'text') {
        _addToOutbox(_OutboxEntry(
          messageId: entry['id'] as String,
          kind: _OutboxKind.text,
          targetId: entry['targetId'] as String?,
          groupId: entry['groupId'] as String?,
        ));
      } else if (kind == 'file') {
        _addToOutbox(_OutboxEntry(
          messageId: entry['id'] as String,
          kind: _OutboxKind.file,
          targetId: entry['targetId'] as String?,
          groupId: entry['groupId'] as String?,
        ));
      }
    }
    if (_outbox.isNotEmpty) {
      debugPrint('[MeshNotifier] ${_outbox.length} messages en attente chargés');
      // Sans condition sur les pairs mesh : `_flushOutbox` sait ce qui peut
      // repartir en ligne et ce qui doit attendre une rencontre.
      _flushOutbox();
    }
  }

  // ── UNDO SEND ───────────────────────────────────────────────────
  //
  // iMessage permet d'annuler l'envoi dans les 2 premières secondes.
  // On fait pareil : le message reste dans un état « annulable » pendant
  // 2 secondes après l'envoi. Passé ce délai, il est trop tard.

  /// IDs des messages récemment envoyés et encore annulables.
  final Set<String> _undoableMessages = {};

  /// Vérifie si un message peut encore être annulé.
  bool canUndoSend(String messageId) => _undoableMessages.contains(messageId);

  /// Annule l'envoi d'un message : le supprime de l'état et de la base.
  /// Renvoie `true` si l'annulation a réussi.
  bool undoSend(String messageId) {
    if (!_undoableMessages.remove(messageId)) return false;
    state = state.where((m) => m.id != messageId).toList();
    unawaited(StorageService.deleteMessage(messageId));
    return true;
  }

  /// Enregistre un message comme annulable pendant 2 secondes.
  void _registerUndoable(String messageId) {
    _undoableMessages.add(messageId);
    Timer(const Duration(seconds: 2), () {
      _undoableMessages.remove(messageId);
    });
  }

  // ── MESSAGES ÉPHÉMÈRES ────────────────────────────────────────
  //
  // Quand un message a un `expiresInSeconds` défini et que le
  // destinataire le lit pour la première fois, un timer démarre.
  // Le message est supprimé quand le timer atteint la durée définie.
  // Un timer périodique vérifie les messages expirés toutes les 5 secondes.

  Timer? _ephemeralCheckTimer;

  /// Démarre le vérificateur périodique des messages éphémères.
  void _startEphemeralChecker() {
    _ephemeralCheckTimer?.cancel();
    _ephemeralCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _purgeExpiredMessages(),
    );
    _startMailboxPolling();
  }

  // ── MAILBOX .ONION ─────────────────────────────────────────────

  /// Démarre le polling de la mailbox .onion toutes les 30 secondes.
  void _startMailboxPolling({bool immediat = false}) {
    _mailboxPollTimer?.cancel();
    _repo.deposerPaquetEnLigne ??= _deposerPaquet;
    // Un push « nouveau message » reçu app ouverte déclenche une relève
    // immédiate : le message s'affiche en une seconde, pas en quatre.
    PushNotificationService.onReveilPremierPlan = () {
      if (mounted) _startMailboxPolling(immediat: true);
    };
    // ⚠️ RYTHME ADAPTATIF (voir `intervalleReleve`) : 4 s quand l'app est à
    // l'écran, 30 s sinon. Avec un minuteur fixe à 30 s, un message en ligne
    // arrivait avec jusqu'à une demi-minute de retard sous les yeux de
    // l'utilisateur. Le minuteur se replanifie après chaque relève : jamais
    // deux relèves en même temps, même si le réseau est lent.
    _mailboxPollTimer = Timer(
      immediat
          ? Duration.zero
          : intervalleReleve(premierPlan: NotificationService.isAppForeground),
      () async {
        if (!_releveEnCours) {
          _releveEnCours = true;
          try {
            await _pollMailbox();
            // ⚠️ LA FILE D'ATTENTE SE RELANCE AUSSI ICI. Elle ne repartait que
            // sur un événement de pair MESH : un message pour un contact
            // joignable seulement en ligne restait « en attente » pour
            // toujours. La relève est le rythme naturel du en-ligne.
            _flushOutbox();
            // La sauvegarde quotidienne en ligne suit le même rythme.
            unawaited(SauvegardeEnLigne.siNecessaire());
            // Paquet de clés Signal publié, réserve de pré-clés rechargée.
            final signal = SignalService.instance;
            if (signal != null) unawaited(signal.publierSiNecessaire());
            // Les accusés qui n'avaient pas pu partir repartent ici.
            unawaited(_renvoyerAccusesEnAttente());
          } finally {
            _releveEnCours = false;
          }
        }
        if (mounted) _startMailboxPolling();
      },
    );
  }

  /// Dépose un paquet mesh (groupe, statut, clé de groupe…) dans la boîte
  /// aux lettres de [peerId], chiffré pour lui — marqué `pk: 1`. Voir
  /// `MeshRepository.deposerPaquetEnLigne`.
  Future<bool> _deposerPaquet(String peerId, Uint8List paquet) async {
    if (paquet.length > FichierEnLigne.maximum || !_repo.clePubliqueConnue(peerId)) {
      return false;
    }
    final chiffre = await _repo.encryptForMailbox(peerId, base64Encode(paquet));
    if (chiffre == null) return false;
    final (cipherText, nonce) = chiffre;
    final depot = await _repo.transport.storeMailboxMessage(
      toPeerId: peerId,
      encryptedPayload: jsonEncode({
        'c': cipherText,
        'n': nonce,
        'k': await CryptoService.ensureIdentityKeyPair(),
        'pk': 1,
      }),
    );
    return depot != null;
  }

  /// Vrai pendant une relève : empêche deux relèves simultanées.
  bool _releveEnCours = false;

  /// Récupère les messages en attente dans la mailbox .onion.
  ///
  /// ⚠️ LA CHARGE EST TOUJOURS CHIFFRÉE ICI — voir [_tryMailboxSend]. Le
  /// serveur mailbox ne voit et ne stocke jamais qu'un texte chiffré ; ce
  /// qu'il rend est déballé (JSON `{c, n}`) puis déchiffré avec la même clé
  /// partagée qu'un message mesh direct, via [MeshRepository.resolveIncomingContent].
  Future<void> _pollMailbox() async {
    try {
      final messages = await _repo.transport.fetchMailboxMessages();
      // Messages reçus pendant cette relève, par expéditeur : un seul accusé
      // « distribué » part ensuite vers chacun.
      final livres = <String, List<String>>{};
      for (final mbMsg in messages) {
        final raw = mbMsg.encryptedPayload;
        if (raw.isEmpty) continue;

        final existing = state.any((m) => m.id == mbMsg.id);
        if (existing) {
          await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
          continue;
        }

        Map<String, dynamic>? parsed;
        try {
          parsed = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          // Charge illisible (pas notre format JSON) — on l'ignore plutôt
          // que de risquer d'afficher du chiffré brut comme s'il
          // s'agissait d'un vrai message.
        }
        final cipherText = parsed?['c'] as String?;
        final nonce = parsed?['n'] as String?;
        if (cipherText == null || nonce == null) {
          await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
          continue;
        }

        // ⚠️ APPRENDRE LA CLÉ DE L'EXPÉDITEUR AVANT DE DÉCHIFFRER. Le dépôt
        // est acquitté plus bas même s'il reste illisible : c'est donc
        // MAINTENANT ou jamais. Sans ça, un premier message d'une personne
        // qui nous a trouvés par pseudo était perdu. Voir
        // `MeshRepository.apprendreCleMailbox` pour les garde-fous.
        final cleExpediteur = parsed?['k'] as String?;
        if (cleExpediteur != null && cleExpediteur.isNotEmpty) {
          _repo.apprendreCleMailbox(mbMsg.fromPeerId, cleExpediteur);
        }

        // ── Un ACCUSÉ (« distribué » ou « lu »), pas un message ────────────
        if (parsed?['rc'] == 1) {
          final clair = await _repo.dechiffrerDepuisMailbox(
              mbMsg.fromPeerId, cipherText, nonce);
          final accuse = clair == null ? null : AccuseEnLigne.decoder(clair);
          if (accuse != null) {
            for (final id in accuse.identifiants) {
              _repo.enregistrerAccuseEnLigne(id,
                  lu: accuse.type == TypeAccuse.lu, de: mbMsg.fromPeerId);
            }
          }
          await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
          continue;
        }

        // ── Un PAQUET MESH arrivé par Internet (groupe, statut, clé…) ──
        if (parsed?['pk'] == 1) {
          final clair = await _repo.dechiffrerDepuisMailbox(
              mbMsg.fromPeerId, cipherText, nonce);
          if (clair == null && !_repo.clePubliqueConnue(mbMsg.fromPeerId)) {
            // Clé de l'expéditeur pas encore connue : on retentera.
            continue;
          }
          if (clair != null) {
            try {
              await _repo.recevoirPaquetEnLigne(mbMsg.fromPeerId, clair, idDepot: mbMsg.id);
            } catch (e) {
              debugPrint('[MeshNotifier] paquet en ligne illisible: $e');
            }
          }
          await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
          continue;
        }

        // L'identifiant du message CHEZ L'EXPÉDITEUR (`m`) : c'est lui que
        // désigneront nos accusés. Les dépôts d'anciennes versions n'en ont
        // pas — on retombe alors sur l'identifiant du serveur.
        final idMessage = (parsed?['m'] as String?)?.isNotEmpty == true
            ? parsed!['m'] as String
            : mbMsg.id;
        if (state.any((m) => m.id == idMessage)) {
          await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
          continue;
        }

        // `f: 1` marque un fichier (voir `_tryMailboxSendFile`) : `c`/`n`
        // y sont des octets chiffrés encodés en base64, pas un texte.
        final estUnFichier = parsed?['f'] == 1;

        // Le vrai pseudo de l'expéditeur s'il est connu — sinon la
        // notification afficherait un identifiant technique illisible
        // comme titre. Le maillage direct fait la même résolution.
        final authorPseudo =
            StorageService.getPeerRecord(mbMsg.fromPeerId)?.pseudo ??
                mbMsg.fromPeerId;

        MeshMessage msg;
        if (parsed?['f'] == 2) {
          // Un MORCEAU de photo ou de vidéo envoyée par Internet.
          final complet = await _recevoirMorceauEnLigne(
            idDepot: mbMsg.id,
            expediteur: mbMsg.fromPeerId,
            horodatage: mbMsg.timestamp,
            parsed: parsed!,
            cipherText: cipherText,
            nonce: nonce,
            idMessage: idMessage,
            authorPseudo: authorPseudo,
          );
          if (complet == null) continue;
          msg = complet;
        } else if (estUnFichier) {
          Uint8List? fileBytes;
          try {
            fileBytes = await _repo.resolveIncomingFileBytes(
              senderId: mbMsg.fromPeerId,
              cipher: base64Decode(cipherText),
              nonce: base64Decode(nonce),
            );
          } catch (_) {
            fileBytes = null;
          }
          final envelope =
              fileBytes != null ? MeshRepository.decodeFileEnvelope(fileBytes) : null;
          if (envelope == null) {
            // Déchiffrement impossible pour l'instant (clé publique pas
            // encore connue, par exemple) — on laisse le message dans la
            // mailbox : `resolveIncomingFileBytes` retentera activement de
            // récupérer la clé à la prochaine tentative.
            continue;
          }
          final (fileName, mimeBrut, bytes) = envelope;
          final (mimeType, legende) = MeshRepository.separerLegende(mimeBrut);
          final fileId = parsed?['id'] as String? ?? mbMsg.id;
          await StorageService.saveSharedFile(
              fileId: fileId, fileName: fileName, bytes: bytes);
          msg = MeshMessage(
            id: idMessage,
            authorPseudo: authorPseudo,
            content: legende ?? fileName,
            type: 'file',
            timestamp: mbMsg.timestamp,
            senderId: mbMsg.fromPeerId,
            targetId: _repo.myId,
            fileId: fileId,
            fileName: fileName,
            fileSize: bytes.length,
            fileMimeType: mimeType,
            hopCount: 0,
            status: MessageStatus.sent,
          );
        } else {
          final content = await _repo.resolveIncomingContent(
            senderId: mbMsg.fromPeerId,
            content: cipherText,
            encrypted: true,
            nonce: nonce,
          );
          // Le même message Signal, déjà reçu par le mesh.
          if (content == MeshRepository.kDoublonSignal) {
            await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
            continue;
          }

          msg = MeshMessage(
            id: idMessage,
            authorPseudo: authorPseudo,
            content: content,
            replyToId: parsed?['r'] as String?,
            type: 'text',
            timestamp: mbMsg.timestamp,
            senderId: mbMsg.fromPeerId,
            targetId: _repo.myId,
            hopCount: 0,
            status: MessageStatus.sent,
          );
        }

        await StorageService.saveMessage(msg);
        state = [...state, msg];
        // ⚠️ Sans cette ligne, un message reçu par Tor n'affichait
        // aucune notification et ne jouait aucun son — seul le maillage
        // direct passait par `newMessageEvents`. La garde `id` dans le
        // listener (`_newMessageSub`) évite tout doublon dans l'état.
        _repo.announceIncoming(msg);
        (livres[mbMsg.fromPeerId] ??= []).add(idMessage);

        await _repo.transport.acknowledgeMailboxMessage(mbMsg.id);
      }

      // « Distribué » : un accusé par expéditeur, pour tout ce qu'on vient
      // de recevoir de lui.
      for (final entree in livres.entries) {
        unawaited(_deposerAccuse(entree.key, TypeAccuse.livre, entree.value));
      }
    } catch (e) {
      debugPrint('[MeshNotifier] Erreur polling mailbox: $e');
    }
  }

  /// Tente d'envoyer un message via la mailbox .onion.
  ///
  /// ⚠️ LE CONTENU EST TOUJOURS CHIFFRÉ AVANT DE PARTIR. La mailbox est un
  /// serveur tiers (Railway, hors de notre contrôle) : y déposer du texte
  /// en clair reviendrait à confier la conversation à un inconnu. On
  /// chiffre donc avec la même clé partagée qu'un envoi mesh direct
  /// ([MeshRepository.encryptForMailbox]), et on empaquette chiffré+nonce
  /// dans une seule chaîne JSON puisque le serveur mailbox n'a qu'un champ
  /// texte unique. Sans clé publique connue du destinataire, on renonce
  /// plutôt que d'envoyer en clair — voir [MeshRepository.encryptForMailbox].
  ///
  /// Retourne `true` si le message a été déposé avec succès.
  Future<bool> _tryMailboxSend(
    String targetId,
    String content,
    String messageId,
    String type, {
    String? replyToId,
  }) async {
    try {
      final encrypted = await _repo.encryptForMailbox(targetId, content);
      if (encrypted == null) {
        debugPrint('[MeshNotifier] mailbox : chiffrement impossible pour '
            '$targetId (clé inconnue ?) — dépôt abandonné');
        return false;
      }
      final (cipherText, nonce) = encrypted;
      final result = await _repo.transport.storeMailboxMessage(
        toPeerId: targetId,
        // `k` : MA clé X25519. Sans elle, un destinataire qui ne m'a jamais
        // croisé ni cherché ne peut PAS déchiffrer ce message — il n'a
        // aucun moyen hors ligne d'obtenir ma clé (le « hello » de secours
        // voyage en mesh et ne l'atteint pas). Voir `_pollMailbox`.
        encryptedPayload: jsonEncode({
          'c': cipherText,
          'n': nonce,
          'k': await CryptoService.ensureIdentityKeyPair(),
          // Mon identifiant du message : le destinataire le reprend, et ses
          // accusés « distribué » / « lu » pourront le désigner.
          'm': messageId,
          // Le message auquel celui-ci répond (dont un statut, `statut:<id>`) :
          // la citation arrive avec lui.
          'r': ?replyToId,
        }),
      );
      return result != null;
    } catch (e) {
      debugPrint('[MeshNotifier] Erreur mailbox send: $e');
      return false;
    }
  }

  /// Tente d'envoyer un petit fichier (message vocal, document, image
  /// compressée) via la mailbox .onion — même principe que
  /// [_tryMailboxSend], pour des octets plutôt qu'un texte.
  ///
  /// ⚠️ PLAFONNÉ VOLONTAIREMENT — voir
  /// `MeshRepository.kMailboxMaxFileBytes`. L'APPELANT DOIT AVOIR DÉJÀ
  /// VÉRIFIÉ LA TAILLE avant d'appeler cette méthode : elle ne la
  /// revérifie pas elle-même.
  Future<bool> _tryMailboxSendFile(
    String targetId,
    String fileName,
    String mimeType,
    Uint8List bytes,
    String fileId,
  ) async {
    try {
      final envelope = MeshRepository.encodeFileEnvelope(
        fileName: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
      final encrypted = await _repo.encryptFileForMailbox(targetId, envelope);
      if (encrypted == null) return false;
      final (cipherB64, nonceB64) = encrypted;
      final result = await _repo.transport.storeMailboxMessage(
        toPeerId: targetId,
        // `f: 1` distingue ce dépôt d'un message texte ordinaire — voir
        // `_pollMailbox`, qui route sur ce marqueur à la réception.
        encryptedPayload: jsonEncode({
          'c': cipherB64,
          'n': nonceB64,
          'f': 1,
          'id': fileId,
          'm': fileId,
          // Ma clé X25519 — même raison que pour un message texte.
          'k': await CryptoService.ensureIdentityKeyPair(),
        }),
      );
      return result != null;
    } catch (e) {
      debugPrint('[MeshNotifier] Erreur mailbox send fichier: $e');
      return false;
    }
  }

  /// Envoie un fichier par Internet : en un dépôt jusqu'à 256 Kio, en
  /// morceaux au-delà (photos, vidéos — voir `fichier_en_ligne.dart`).
  Future<bool> _envoyerFichierEnLigne(
    String targetId,
    String fileName,
    String mimeType,
    Uint8List bytes,
    String fileId,
  ) {
    if (bytes.length <= MeshRepository.kMailboxMaxFileBytes) {
      return _tryMailboxSendFile(targetId, fileName, mimeType, bytes, fileId);
    }
    return _tryMailboxSendFileMorcele(targetId, fileName, mimeType, bytes, fileId);
  }

  /// Dépose l'enveloppe du fichier en morceaux chiffrés un à un (`f: 2`,
  /// index `i` sur `t`). Chaque dépôt réussi fait avancer la barre de
  /// progression de l'envoi.
  Future<bool> _tryMailboxSendFileMorcele(
    String targetId,
    String fileName,
    String mimeType,
    Uint8List bytes,
    String fileId,
  ) async {
    try {
      final envelope = MeshRepository.encodeFileEnvelope(
        fileName: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
      final morceaux = FichierEnLigne.decouper(envelope);
      final cle = await CryptoService.ensureIdentityKeyPair();
      _repo.publierProgression(fileId, 0, envoi: true);
      for (var i = 0; i < morceaux.length; i++) {
        if (_repo.envoiAnnule(fileId)) return false;
        final chiffre = await _repo.encryptFileForMailbox(targetId, morceaux[i]);
        if (chiffre == null) return false;
        final (cipherB64, nonceB64) = chiffre;
        final depot = await _repo.transport.storeMailboxMessage(
          toPeerId: targetId,
          encryptedPayload: jsonEncode({
            'c': cipherB64,
            'n': nonceB64,
            'f': 2,
            'id': fileId,
            'm': fileId,
            'i': i,
            't': morceaux.length,
            'k': cle,
          }),
        );
        if (depot == null) return false;
        _repo.publierProgression(fileId, (i + 1) / morceaux.length, envoi: true);
      }
      return true;
    } catch (e) {
      debugPrint('[MeshNotifier] Erreur envoi en morceaux vers $targetId: $e');
      return false;
    }
  }

  AssemblageEnLigne? _assemblageEnLigne;

  Future<AssemblageEnLigne> _assemblage() async {
    final docs = await getApplicationDocumentsDirectory();
    return _assemblageEnLigne ??=
        AssemblageEnLigne(Directory('${docs.path}/morceaux_en_ligne'));
  }

  /// Reçoit UN morceau d'un fichier envoyé par Internet. Renvoie le message
  /// fichier une fois TOUS les morceaux reçus, sinon `null`.
  ///
  /// Acquittement : un morceau enregistré sur le disque est acquitté ici ; le
  /// DERNIER ne l'est pas — le flux normal de la relève l'acquitte après avoir
  /// enregistré le message. Un morceau encore illisible (clé de l'expéditeur
  /// inconnue) reste dans la boîte pour la relève suivante.
  Future<MeshMessage?> _recevoirMorceauEnLigne({
    required String idDepot,
    required String expediteur,
    required DateTime horodatage,
    required Map<String, dynamic> parsed,
    required String cipherText,
    required String nonce,
    required String idMessage,
    required String authorPseudo,
  }) async {
    final fichierId = parsed['id'] as String? ?? '';
    final index = (parsed['i'] as num?)?.toInt() ?? -1;
    final total = (parsed['t'] as num?)?.toInt() ?? 0;
    // Dossier propre à l'expéditeur : un pair ne peut pas mêler ses morceaux
    // à ceux d'un autre en réutilisant le même identifiant.
    final cleAssemblage = '${expediteur}_$fichierId';
    if (!AssemblageEnLigne.valide(cleAssemblage, index, total)) {
      await _repo.transport.acknowledgeMailboxMessage(idDepot);
      return null;
    }
    Uint8List? octets;
    try {
      octets = await _repo.resolveIncomingFileBytes(
        senderId: expediteur,
        cipher: base64Decode(cipherText),
        nonce: base64Decode(nonce),
      );
    } catch (_) {
      octets = null;
    }
    if (octets == null) return null;

    final assemblage = await _assemblage();
    final progression = await assemblage.ajouter(cleAssemblage, index, total, octets);
    _repo.publierProgression(fichierId, progression, envoi: false);
    final complet = await assemblage.assembler(cleAssemblage, total);
    if (complet == null) {
      await _repo.transport.acknowledgeMailboxMessage(idDepot);
      return null;
    }
    final enveloppe = MeshRepository.decodeFileEnvelope(complet);
    if (enveloppe == null) {
      await _repo.transport.acknowledgeMailboxMessage(idDepot);
      return null;
    }
    final (fileName, mimeBrut, bytes) = enveloppe;
    final (mimeType, legende) = MeshRepository.separerLegende(mimeBrut);
    await StorageService.saveSharedFile(
        fileId: fichierId, fileName: fileName, bytes: bytes);
    return MeshMessage(
      id: idMessage,
      authorPseudo: authorPseudo,
      content: legende ?? fileName,
      type: 'file',
      timestamp: horodatage,
      senderId: expediteur,
      targetId: _repo.myId,
      fileId: fichierId,
      fileName: fileName,
      fileSize: bytes.length,
      fileMimeType: mimeType,
      hopCount: 0,
      status: MessageStatus.sent,
    );
  }

  /// Dépose un accusé « distribué » ou « lu » pour [ids] dans la boîte aux
  /// lettres de [peerId] — chiffré comme un message, marqué `rc: 1`, et
  /// jamais lui-même accusé (pas de boucle).
  Future<void> _deposerAccuse(String peerId, TypeAccuse type, List<String> ids) async {
    if (ids.isEmpty) return;
    if (!await _tenterAccuse(peerId, type, ids)) _memoriserAccuses(peerId, type, ids);
  }

  Future<bool> _tenterAccuse(String peerId, TypeAccuse type, List<String> ids) async {
    if (ids.isEmpty) return true;
    // Sans la clé du destinataire, l'accusé ne peut pas être chiffré : on le
    // garde pour plus tard plutôt que de le perdre.
    if (!_repo.clePubliqueConnue(peerId)) return false;
    try {
      final chiffre = await _repo.encryptForMailbox(
          peerId, AccuseEnLigne(type, ids).encoder());
      if (chiffre == null) return false;
      final (cipherText, nonce) = chiffre;
      final depot = await _repo.transport.storeMailboxMessage(
        toPeerId: peerId,
        encryptedPayload: jsonEncode({
          'c': cipherText,
          'n': nonce,
          'k': await CryptoService.ensureIdentityKeyPair(),
          'rc': 1,
        }),
      );
      return depot != null;
    } catch (e) {
      debugPrint('[MeshNotifier] accusé en ligne vers $peerId non déposé: $e');
      return false;
    }
  }

  /// ⚠️ UN ACCUSÉ RATÉ ÉTAIT PERDU POUR TOUJOURS. Internet coupé à cet instant,
  /// ou clé de l'expéditeur pas encore connue, et l'autre restait avec une
  /// seule coche pour un message pourtant lu. On les garde, et la relève les
  /// renvoie.
  final List<({String peerId, TypeAccuse type, String messageId})> _accusesEnAttente = [];
  static const int _maxAccusesEnAttente = 200;

  void _memoriserAccuses(String peerId, TypeAccuse type, List<String> ids) {
    for (final id in ids) {
      final deja = _accusesEnAttente
          .any((a) => a.peerId == peerId && a.type == type && a.messageId == id);
      if (!deja) _accusesEnAttente.add((peerId: peerId, type: type, messageId: id));
    }
    if (_accusesEnAttente.length > _maxAccusesEnAttente) {
      _accusesEnAttente.removeRange(0, _accusesEnAttente.length - _maxAccusesEnAttente);
    }
  }

  Future<void> _renvoyerAccusesEnAttente() async {
    if (_accusesEnAttente.isEmpty || !EtatInternet.disponible()) return;
    final aRenvoyer = List.of(_accusesEnAttente);
    _accusesEnAttente.clear();
    final parDestinataire = <String, List<String>>{};
    for (final accuse in aRenvoyer) {
      (parDestinataire['${accuse.type.name}|${accuse.peerId}'] ??= []).add(accuse.messageId);
    }
    for (final entree in parDestinataire.entries) {
      final separation = entree.key.indexOf('|');
      final type = TypeAccuse.values.firstWhere((t) => t.name == entree.key.substring(0, separation));
      final peerId = entree.key.substring(separation + 1);
      if (!await _tenterAccuse(peerId, type, entree.value)) {
        _memoriserAccuses(peerId, type, entree.value);
      }
    }
  }

  /// « Distribué » par Internet pour un message arrivé par le MESH dont
  /// l'expéditeur n'est plus à portée : sans ça, quelqu'un qui s'éloigne juste
  /// après avoir écrit ne voit jamais sa deuxième coche.
  void _accuserReceptionEnLigne(MeshMessage message) {
    final expediteur = message.senderId;
    if (expediteur == null || expediteur == _repo.myId) return;
    if (message.groupId != null) {
      // GROUPE : chaque membre prévient l'AUTEUR seul — par le mesh s'il est
      // à portée, sinon par Internet. L'auteur voit ses deux coches quand
      // TOUS les membres ont reçu (voir `MeshRepository.getAckCount`).
      if (_joignableEnMesh(expediteur)) {
        unawaited(_repo.sendRecu(originalSenderId: expediteur, messageId: message.id));
      } else if (EtatInternet.disponible()) {
        unawaited(_deposerAccuse(expediteur, TypeAccuse.livre, [message.id]));
      }
      return;
    }
    if (_joignableEnMesh(expediteur)) return;
    unawaited(_deposerAccuse(expediteur, TypeAccuse.livre, [message.id]));
  }

  /// Marque un message comme « première lecture » et planifie sa suppression.
  void _markFirstRead(MeshMessage message) {
    if (message.expiresInSeconds == null || message.firstReadAt != null) return;
    if (message.senderId == _repo.myId) return;
    final now = DateTime.now();
    state = state.map((m) {
      if (m.id != message.id) return m;
      return m.copyWith(firstReadAt: now);
    }).toList();
    unawaited(StorageService.updateMessageFirstReadAt(message.id, now));
  }

  /// Supprime tous les messages éphémères dont le délai est écoulé.
  void _purgeExpiredMessages() {
    final now = DateTime.now();
    final toDelete = <String>[];
    for (final m in state) {
      if (m.expiresInSeconds == null || m.firstReadAt == null) continue;
      final elapsed = now.difference(m.firstReadAt!).inSeconds;
      if (elapsed >= m.expiresInSeconds!) {
        toDelete.add(m.id);
      }
    }
    if (toDelete.isEmpty) return;
    state = state.where((m) => !toDelete.contains(m.id)).toList();
    for (final id in toDelete) {
      unawaited(StorageService.deleteMessage(id));
    }
  }

  // ── MESSAGE EDITING ─────────────────────────────────────────────
  //
  // iMessage permet de modifier un message après envoi. On fait pareil :
  // seul l'expéditeur peut modifier, et le badge « modifié » apparaît
  // dans la bulle.

  /// Modifie le contenu d'un message. Seul l'auteur peut le faire.
  /// Le badge « modifié » est affiché dans la bulle.
  /// La modification est envoyée à tous les pairs connectés via le mesh.
  void editMessage(String messageId, String newContent) {
    state = state.map((m) {
      if (m.id != messageId) return m;
      if (m.senderId != _repo.myId) return m;
      return m.copyWith(
        content: newContent,
        editedAt: DateTime.now(),
      );
    }).toList();
    // Persister en base.
    final msg = state.where((m) => m.id == messageId).firstOrNull;
    if (msg != null) {
      unawaited(StorageService.saveMessage(msg));
    }
    // Envoyer la modification aux pairs via le mesh.
    if (msg?.groupId != null) {
      unawaited(_repo.sendGroupEditMessage(
        groupId: msg!.groupId!,
        messageId: messageId,
        newContent: newContent,
      ).catchError((e) => debugPrint('[MeshNotifier] échec envoi édit groupe: $e')));
    } else {
      final targetId = msg?.targetId;
      unawaited(_repo.sendEditMessage(
        messageId: messageId,
        newContent: newContent,
        targetId: targetId,
      ).catchError((e) => debugPrint('[MeshNotifier] échec envoi édit: $e')));
    }
  }

  /// Applique une modification reçue d'un pair distant.
  ///
  /// ⚠️ SEUL L'AUTEUR PEUT MODIFIER. Cette vérification manquait : il
  /// suffisait de connaître l'identifiant d'un message pour en réécrire
  /// le texte chez tous ceux qui l'avaient reçu.
  void applyRemoteEdit(String messageId, String newContent, {required String auteur}) {
    state = state.map((m) {
      if (m.id != messageId) return m;
      if (m.senderId != auteur) return m;
      return m.copyWith(
        content: newContent,
        editedAt: DateTime.now(),
      );
    }).toList();
    final msg = state.where((m) => m.id == messageId).firstOrNull;
    if (msg != null) {
      unawaited(StorageService.saveMessage(msg));
    }
  }

  // ── MESSAGES ÉPINGLÉS ───────────────────────────────────────────
  //
  // Voir `epingles.dart`. La conversation d'un message : son groupe, ou
  // l'autre personne en 1:1.

  String? _conversationDe(MeshMessage m) {
    if (m.groupId != null) return m.groupId;
    if (m.targetId == null) return null; // diffusion : pas d'épingle
    return m.senderId == _repo.myId ? m.targetId : m.senderId;
  }

  /// Épingle ou désépingle [messageId], ici et chez les autres.
  Future<void> epingler(String messageId, {required bool epingle}) async {
    final msg = state.where((m) => m.id == messageId).firstOrNull;
    if (msg == null) return;
    final conversation = _conversationDe(msg);
    if (conversation == null) return;
    final change = await Epingles.appliquer(conversation, messageId, epingle: epingle);
    if (!change) return;
    unawaited(_repo
        .envoyerEpingle(
          messageId: messageId,
          epingle: epingle,
          targetId: msg.groupId == null ? conversation : null,
          groupId: msg.groupId,
        )
        .catchError((Object e) => debugPrint('[MeshNotifier] épingle non envoyée: $e')));
  }

  /// Un épinglage reçu. N'est appliqué que si le message appartient bien
  /// à la conversation d'où vient l'ordre — un tiers ne doit pas pouvoir
  /// épingler quoi que ce soit dans une discussion qui n'est pas la sienne.
  void _appliquerEpingleRecu(
      ({String messageId, bool epingle, String senderId, String? groupId}) e) {
    final msg = state.where((m) => m.id == e.messageId).firstOrNull;
    if (msg == null) return;
    final conversation = _conversationDe(msg);
    if (conversation == null) return;
    final attendu = e.groupId ?? e.senderId;
    if (conversation != attendu) return;
    unawaited(Epingles.appliquer(conversation, e.messageId, epingle: e.epingle));
  }

  /// Envoie un message texte (1:1 ou diffusion). Le message apparaît
  /// TOUT DE SUITE à l'écran avec un statut « en cours d'envoi », même
  /// avant que l'envoi réel ne soit confirmé — l'utilisateur n'attend
  /// jamais devant un écran vide.
  Future<void> sendMessage(String pseudo, String content,
      {String type = 'text', String? imageUrl, String? audioUrl, String? replyToId, String? targetId, String? effect, String? threadId, String? forwardedFrom}) async {
    // On ne peut pas écrire à un contact qu'on a bloqué.
    if (targetId != null && StorageService.isContactBlocked(targetId)) return;
    // Messages éphémères : si la conversation a un timer, l'appliquer.
    final ephemeralTimer = targetId != null
        ? StorageService.getEphemeralTimer(targetId)
        : 0;
    final msg = MeshMessage(
      id: BleMeshProtocol.generateMessageId(),
      authorPseudo: pseudo,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      senderId: _repo.myId,
      targetId: targetId,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      hopCount: MeshRepository.kDefaultHopCount,
      replyToId: replyToId,
      status: MessageStatus.sending,
      effect: effect,
      expiresInSeconds: ephemeralTimer > 0 ? ephemeralTimer : null,
      threadId: threadId,
      forwardedFrom: forwardedFrom,
    );

    await StorageService.saveMessage(msg);
    state = [...state, msg];

    // ⚠️ POURQUOI ON NE SE FIE PAS À `connectedPeerCount > 0` SEUL.
    //
    // Avant ce garde-fou, avoir NE SERAIT-CE QU'UN pair BLE/Wi-Fi à
    // portée — même sans aucun rapport avec le destinataire visé —
    // suffisait à tenter le chemin mesh direct pour n'importe quel
    // contact, y compris un contact Tor jamais rencontré physiquement
    // (trouvé par QR code ou par l'annuaire). Ce chemin ne pouvait
    // jamais aboutir pour lui : `sendMessage` ne lève pas d'exception
    // tant que la clé publique est connue, elle se contente de mettre le
    // paquet en file — la mailbox .onion, seul chemin qui fonctionne
    // réellement pour ce genre de contact, n'était donc jamais essayée.
    final peerRecord = targetId != null ? StorageService.getPeerRecord(targetId) : null;
    // ⚠️ MESH OU INTERNET D'ABORD ? Un contact du mesh hors de portée partait
    // dans la file du mesh, où il pouvait attendre des heures alors
    // qu'Internet marchait et que sa clé était connue. On passe désormais par
    // la boîte aux lettres quand le mesh ne peut pas le joindre — voir
    // `envoyerParInternetDAbord`.
    final tryDirectMesh = targetId == null
        ? _repo.transport.connectedPeerCount > 0
        : !envoyerParInternetDAbord(
            contactEnLigneSeul: isTorOnlyPeer(peerRecord),
            joignableEnMesh: _joignableEnMesh(targetId),
            internet: EtatInternet.disponible(),
            cleConnue: _repo.clePubliqueConnue(targetId),
            pairsMesh: _repo.transport.connectedPeerCount,
          );
    // Trace de décision : sans elle, un message resté « en attente » ne
    // disait jamais POURQUOI il n'était pas passé par la boîte aux lettres.
    debugPrint('[MeshNotifier] envoi ${msg.id} → $targetId : '
        '${tryDirectMesh ? "mesh direct" : "boîte aux lettres"} '
        '(contact en ligne=${isTorOnlyPeer(peerRecord)}, '
        'pairs mesh=${_repo.transport.connectedPeerCount})');

    if (tryDirectMesh) {
      try {
        await _repo.sendMessage(
          authorPseudo: pseudo,
          content: content,
          type: type,
          imageUrl: imageUrl,
          audioUrl: audioUrl,
          replyToId: replyToId,
          messageId: msg.id,
          targetId: targetId,
          effect: effect,
        );
        _setStatus(msg.id, MessageStatus.sent);
        _registerUndoable(msg.id);
      } catch (_) {
        _setStatus(msg.id, MessageStatus.failed);
        _showToast('Échec de l\'envoi du message', type: DropletToastType.error);
        final conv = targetId ?? 'broadcast';
        unawaited(NotificationService.showSendFailed(
          conversationId: conv,
          routePath: '/chat/$conv',
        ));
      }
    } else {
      // Essayer la mailbox .onion si le peer a une adresse onion connue.
      if (targetId != null) {
        final mailboxSent = await _tryMailboxSend(targetId, msg.content, msg.id, msg.type, replyToId: msg.replyToId);
        if (mailboxSent) {
          _setStatus(msg.id, MessageStatus.sent);
          _registerUndoable(msg.id);
          return;
        }
      }
      _setStatus(msg.id, MessageStatus.pending);
      _addToOutbox(_OutboxEntry(messageId: msg.id, kind: _OutboxKind.text, targetId: targetId));
      unawaited(StorageService.saveOutbox({
        'id': msg.id, 'kind': 'text', 'targetId': targetId,
      }));
    }
  }

  /// Envoie un message dans un groupe (chiffré avec ma sender-key).
  Future<void> sendGroupMessage(String pseudo, String content, {
    required String groupId,
    String? replyToId,
    String? effect,
    String? threadId,
  }) async {
    final msg = MeshMessage(
      id: BleMeshProtocol.generateMessageId(),
      authorPseudo: pseudo,
      content: content,
      type: 'text',
      timestamp: DateTime.now(),
      senderId: _repo.myId,
      groupId: groupId,
      hopCount: MeshRepository.kDefaultHopCount,
      replyToId: replyToId,
      status: MessageStatus.sending,
      effect: effect,
      threadId: threadId,
    );

    await StorageService.saveMessage(msg);
    state = [...state, msg];

    // Sans voisin mesh, un groupe passe désormais par Internet.
    if (_repo.transport.connectedPeerCount > 0 || EtatInternet.disponible()) {
      try {
        await _repo.sendGroupMessage(
          groupId: groupId,
          content: content,
          replyToId: replyToId,
          messageId: msg.id,
          effect: effect,
        );
        _setStatus(msg.id, MessageStatus.sent);
      } catch (_) {
        _setStatus(msg.id, MessageStatus.failed);
        _showToast('Échec de l\'envoi du message', type: DropletToastType.error);
        unawaited(NotificationService.showSendFailed(
          conversationId: groupId,
          routePath: '/group/$groupId',
        ));
      }
    } else {
      _setStatus(msg.id, MessageStatus.pending);
      _addToOutbox(_OutboxEntry(messageId: msg.id, kind: _OutboxKind.text, groupId: groupId));
      unawaited(StorageService.saveOutbox({
        'id': msg.id, 'kind': 'text', 'groupId': groupId,
      }));
    }
  }

  /// TRANSFÈRE des messages vers d'autres conversations.
  ///
  /// Chaque message part comme un message neuf — le mesh comme la boîte aux
  /// lettres ne savent pas « faire suivre » quelque chose de déjà envoyé, et
  /// l'expéditeur n'est plus l'auteur d'origine. C'est pour cela que le nom
  /// de cet auteur voyage à part (`forwardedFrom`) : le destinataire voit
  /// « Transféré », sans qu'on lui mente sur qui lui écrit.
  ///
  /// Les photos, vidéos et documents repartent avec leurs octets : rien
  /// n'oblige le nouveau destinataire à avoir croisé l'expéditeur d'origine.
  Future<int> transfererMessages({
    required String pseudo,
    required List<MeshMessage> messages,
    List<String> contacts = const [],
    List<String> groupes = const [],
  }) async {
    var envoyes = 0;
    // Dans l'ordre où ils ont été écrits : un fil transféré reste lisible.
    final aTransferer = [...messages]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (final m in aTransferer) {
      final auteur = m.forwardedFrom ?? m.authorPseudo;
      Uint8List? octets;
      if (m.type == 'file') {
        final chemin = await StorageService.getSharedFilePath(m.fileId ?? '', m.fileName ?? '');
        if (chemin == null) continue;
        try {
          octets = await File(chemin).readAsBytes();
        } catch (_) {
          continue;
        }
      }
      for (final cible in [...contacts, ...groupes]) {
        final groupe = groupes.contains(cible);
        if (m.type == 'file' && octets != null) {
          await sendFile(
            pseudo: pseudo,
            fileName: m.fileName ?? 'fichier',
            bytes: octets,
            mimeType: m.fileMimeType ?? '',
            targetId: groupe ? null : cible,
            groupId: groupe ? cible : null,
            legende: m.content == m.fileName ? null : m.content,
          );
        } else if (groupe) {
          await sendGroupMessage(pseudo, m.content, groupId: cible);
        } else {
          await sendMessage(pseudo, m.content, targetId: cible, forwardedFrom: auteur);
        }
        envoyes++;
      }
    }
    return envoyes;
  }

  // ── LA BULLE QUI APPARAÎT TOUT DE SUITE ───────────────────────────────
  //
  // Réencoder une vidéo prend plusieurs secondes. Il n'y avait pendant ce
  // temps qu'un petit message en bas de l'écran, et rien dans la
  // conversation. Comme WhatsApp : la bulle est là dès l'envoi, avec
  // l'avancement de la préparation, puis celui de l'envoi — et une croix
  // pour tout annuler.

  String? _idEnPreparation;

  String ajouterBullePreparation({
    required String pseudo,
    required String fileName,
    required String mimeType,
    String? targetId,
    String? groupId,
    int taille = 0,
  }) {
    final id = const Uuid().v4();
    _idEnPreparation = id;
    state = [
      ...state,
      MeshMessage(
        id: id,
        authorPseudo: pseudo,
        content: fileName,
        type: 'file',
        timestamp: DateTime.now(),
        senderId: _repo.myId,
        targetId: targetId,
        groupId: groupId,
        fileId: id,
        fileName: fileName,
        fileSize: taille,
        fileMimeType: mimeType,
        hopCount: MeshRepository.kDefaultHopCount,
        status: MessageStatus.sending,
      ),
    ];
    _repo.publierProgression(id, 0, envoi: true);
    return id;
  }

  void mettreAJourPreparation(String id, double progression) {
    if (_repo.envoiAnnule(id)) return;
    _repo.publierProgression(id, progression.clamp(0.0, 0.99), envoi: true);
  }

  bool envoiAnnule(String id) => _repo.envoiAnnule(id);

  /// La croix de la bulle : préparation arrêtée, morceaux restants retenus,
  /// bulle retirée.
  void annulerEnvoi(String id) {
    _repo.annulerEnvoi(id);
    if (_idEnPreparation == id) {
      _idEnPreparation = null;
      unawaited(MediaService.annulerCompression());
    }
    HapticFeedback.lightImpact();
    state = state.where((m) => m.id != id).toList();
    unawaited(StorageService.deleteMessage(id));
    _repo.publierProgression(id, 1, envoi: true);
  }

  /// Envoie un fichier (photo, document, message vocal) — même logique
  /// « apparaît tout de suite, statut mis à jour ensuite » que
  /// [sendMessage].
  Future<void> sendFile({
    required String pseudo,
    required String fileName,
    required Uint8List bytes,
    String mimeType = '',
    String? targetId,
    String? groupId,
    String? replyToId,
    /// Le texte écrit sous la photo dans l'écran d'aperçu. Voyage avec le
    /// fichier (voir `MeshRepository.mimeAvecLegende`).
    String? legende,
    /// L'identifiant de la bulle « préparation » déjà affichée
    /// (voir [ajouterBullePreparation]) : elle devient le vrai message.
    String? idPrepare,
  }) async {
    if (idPrepare != null && _repo.envoiAnnule(idPrepare)) return;
    if (idPrepare == _idEnPreparation) _idEnPreparation = null;
    final fileId = idPrepare ?? const Uuid().v4();
    final int hopCount = MeshRepository.kDefaultHopCount;
    final texteLegende = legende?.trim();
    final avecLegende = texteLegende != null && texteLegende.isNotEmpty;
    final mimeTransporte = MeshRepository.mimeAvecLegende(mimeType, texteLegende);

    final msg = MeshMessage(
      id: fileId,
      authorPseudo: pseudo,
      // La légende prend la place du nom de fichier : c'est elle qui s'affiche
      // sous la photo, et dans l'aperçu d'une notification.
      content: avecLegende ? texteLegende : fileName,
      type: 'file',
      timestamp: DateTime.now(),
      senderId: _repo.myId,
      targetId: targetId,
      groupId: groupId,
      fileId: fileId,
      fileName: fileName,
      fileSize: bytes.length,
      fileMimeType: mimeType,
      replyToId: replyToId,
      hopCount: hopCount,
      status: MessageStatus.sending,
    );

    await StorageService.saveMessage(msg);
    state = state.any((m) => m.id == fileId)
        ? [for (final m in state) m.id == fileId ? msg : m]
        : [...state, msg];
    await StorageService.saveSharedFile(fileId: fileId, fileName: fileName, bytes: bytes);

    // ⚠️ UN CONTACT TOR-ONLY NE PASSE JAMAIS PAR LE MESH DIRECT — voir
    // la même remarque dans `sendMessage` ci-dessus. Ici, la différence
    // ne s'arrête pas à CHOISIR un autre chemin : la mailbox ne peut
    // porter qu'un fichier de taille raisonnable (voir
    // `MeshRepository.kMailboxMaxFileBytes`), donc un fichier trop gros
    // échoue tout de suite, PROPREMENT — jamais un « en attente » qui ne
    // se résoudra jamais puisque ce pair ne passera jamais à portée.
    final peerRecord = targetId != null ? StorageService.getPeerRecord(targetId) : null;
    final isTorContact = isTorOnlyPeer(peerRecord);
    // Même règle que pour un texte : hors de portée du mesh mais joignable en
    // ligne, le fichier part par Internet (en morceaux si besoin).
    final parInternet = targetId != null &&
        groupId == null &&
        !isTorContact &&
        !_joignableEnMesh(targetId) &&
        EtatInternet.disponible() &&
        _repo.clePubliqueConnue(targetId);
    // Groupe : les membres hors mesh reçoivent le fichier par Internet
    // (`MeshRepository.sendFile`), même sans aucun voisin.
    final groupeParInternet = groupId != null && EtatInternet.disponible();
    final tryDirectMesh = groupeParInternet ||
        (!isTorContact && !parInternet && _repo.transport.connectedPeerCount > 0);

    if (tryDirectMesh) {
      try {
        await _repo.sendFile(
          fileName: fileName,
          bytes: bytes,
          mimeType: mimeTransporte,
          targetId: targetId,
          groupId: groupId,
          fileId: fileId,
          replyToId: replyToId,
        );
        _setStatus(msg.id, MessageStatus.sent);
      } catch (_) {
        _setStatus(msg.id, MessageStatus.failed);
        _showToast('Échec de l\'envoi du fichier', type: DropletToastType.error);
        final conv = groupId ?? targetId ?? 'broadcast';
        unawaited(NotificationService.showSendFailed(
          conversationId: conv,
          routePath: groupId != null ? '/group/$conv' : '/chat/$conv',
        ));
      }
    } else if ((isTorContact || parInternet) && targetId != null) {
      if (bytes.length > FichierEnLigne.maximum) {
        _setStatus(msg.id, MessageStatus.failed);
        _showToast(
          'Ce fichier est trop volumineux pour être envoyé par Internet (limite : '
          '${FichierEnLigne.maximum ~/ (1024 * 1024)} Mo).',
          type: DropletToastType.error,
        );
      } else {
        final mailboxSent = await _envoyerFichierEnLigne(
          targetId, fileName, mimeTransporte, bytes, fileId,
        );
        if (mailboxSent) {
          _setStatus(msg.id, MessageStatus.sent);
        } else {
          _setStatus(msg.id, MessageStatus.failed);
          _showToast(
            'Échec de l\'envoi du fichier via Tor',
            type: DropletToastType.error,
          );
        }
      }
    } else {
      _setStatus(msg.id, MessageStatus.pending);
      _addToOutbox(_OutboxEntry(messageId: fileId, kind: _OutboxKind.file, targetId: targetId, groupId: groupId));
      unawaited(StorageService.saveOutbox({
        'id': fileId, 'kind': 'file', 'targetId': targetId, 'groupId': groupId,
      }));
    }
  }

  /// Supprime un message localement (DB + état) — n'affecte que cet
  /// appareil, ne rappelle pas le message chez les destinataires.
  void deleteMessage(String messageId) {
    state = state.where((msg) => msg.id != messageId).toList();
    unawaited(StorageService.deleteMessage(messageId));
  }

  /// Efface une discussion de CE téléphone.
  ///
  /// Les messages restent chez les autres : sans serveur, personne ne peut
  /// effacer ce qui est déjà arrivé ailleurs. Le groupe, lui, n'est pas
  /// quitté — on vide l'historique, on ne s'en va pas.
  void supprimerConversation({String? peerId, String? groupId}) {
    bool vise(MeshMessage m) => groupId != null
        ? m.groupId == groupId
        : m.groupId == null &&
              (m.senderId == peerId || m.targetId == peerId);
    final effaces = <String>{for (final m in state) if (vise(m)) m.id};
    if (effaces.isEmpty) return;
    state = state.where((m) => !effaces.contains(m.id)).toList();
    for (final id in effaces) {
      unawaited(StorageService.deleteMessage(id));
    }
  }

  void toggleReaction(String messageId, String reaction) {
    state = state.map((msg) {
      if (msg.id != messageId) return msg;
      final reactions = List<String>.from(msg.reactions);
      if (reactions.contains(reaction)) {
        reactions.remove(reaction);
      } else {
        reactions.add(reaction);
      }
      // Persister en base.
      unawaited(StorageService.updateMessageReactions(messageId, reactions));
      // Diffuser au pair via le mesh.
      final peerId = msg.groupId ?? msg.targetId ?? msg.senderId;
      if (peerId != null && peerId != _repo.myId) {
        unawaited(_repo.sendReaction(
          targetId: peerId,
          messageId: messageId,
          emoji: reaction,
        ));
      }
      return msg.copyWith(reactions: reactions);
    }).toList();
  }

  /// Conversation de GROUPE ouverte : ses messages reçus deviennent lus, et
  /// chaque auteur en est prévenu — par le mesh, et par Internet s'il n'est pas
  /// à portée. Il verra ses coches bleues quand tous les membres auront lu.
  Future<void> envoyerLecturesGroupe(String groupId) async {
    final maintenant = DateTime.now();
    final aPrevenir = <({String auteur, String messageId})>[];
    final misAJour = state.map((m) {
      if (m.groupId != groupId || m.senderId == _repo.myId || m.readAt != null) return m;
      final auteur = m.senderId;
      if (auteur != null) aPrevenir.add((auteur: auteur, messageId: m.id));
      return m.copyWith(readAt: maintenant);
    }).toList();
    if (aPrevenir.isEmpty) return;
    state = misAJour;
    final parInternet = <String, List<String>>{};
    for (final p in aPrevenir) {
      unawaited(StorageService.updateMessageReadAt(p.messageId, maintenant));
      unawaited(_repo.sendRead(originalSenderId: p.auteur, messageId: p.messageId));
      if (!_joignableEnMesh(p.auteur) && EtatInternet.disponible()) {
        (parInternet[p.auteur] ??= []).add(p.messageId);
      }
    }
    for (final e in parInternet.entries) {
      unawaited(_deposerAccuse(e.key, TypeAccuse.lu, e.value));
    }
  }

  /// Marque localement comme lu tous les messages entrants d'une conversation
  /// et diffuse les accusés de lecture à leurs émetteurs respectifs.
  Future<void> sendReadReceipts(String? peerId) async {
    if (peerId != null && StorageService.isContactBlocked(peerId)) return;
    final now = DateTime.now();
    var changed = false;
    final pending = <({String senderId, String messageId})>[];
    final updated = state.map((m) {
      if (m.groupId != null) return m;
      final other = m.senderId == _repo.myId ? m.targetId : m.senderId;
      final inConv = peerId == null ? m.targetId == null : other == peerId;
      if (!inConv || m.senderId == _repo.myId || m.readAt != null) return m;
      changed = true;
      final sender = m.senderId;
      if (sender != null) pending.add((senderId: sender, messageId: m.id));
      return m.copyWith(readAt: now);
    }).toList();
    if (changed) {
      state = updated;
      for (final m in updated) {
        if (m.readAt == now && m.senderId != _repo.myId) {
          unawaited(StorageService.updateMessageReadAt(m.id, now));
        }
      }
      for (final p in pending) {
        unawaited(_repo.sendRead(
          originalSenderId: p.senderId,
          messageId: p.messageId,
        ));
      }
      // « Lu » EN LIGNE : `sendRead` ne part que vers les voisins mesh. Pour
      // un contact joignable seulement par Internet (ou sans aucun voisin),
      // l'accusé passe aussi par la boîte aux lettres, un seul par contact.
      final sansPair = _repo.transport.connectedPeerCount == 0;
      final parContact = <String, List<String>>{};
      for (final p in pending) {
        // Dès que le mesh ne joint pas l'expéditeur, le « lu » passe par
        // Internet — pas seulement pour les contacts « en ligne ».
        if (_contactEnLigne(p.senderId) || sansPair || !_joignableEnMesh(p.senderId)) {
          (parContact[p.senderId] ??= []).add(p.messageId);
        }
      }
      for (final e in parContact.entries) {
        unawaited(_deposerAccuse(e.key, TypeAccuse.lu, e.value));
      }
    }
  }

  /// Dès qu'un pair se reconnecte, tente d'envoyer tout ce qui attendait
  /// dans la « boîte d'attente ».
  ///
  /// Utilise un compteur de génération pour détecter si de nouveaux
  /// messages sont arrivés pendant le vidage. Si c'est le cas, un
  /// deuxième flush est programmé automatiquement — on ne perd jamais
  /// un message ajouté entre le `clear()` et la fin des envois.
  /// Une entrée peut-elle partir par la boîte aux lettres ? Seulement une
  /// conversation à deux (la mailbox n'a pas de notion de groupe).
  bool _eligibleMailbox(_OutboxEntry e) =>
      (e.groupId == null && e.targetId != null) ||
      (e.groupId != null && EtatInternet.disponible());

  /// Le destinataire n'est-il joignable qu'en ligne (contact trouvé par
  /// pseudo, QR code, ou venu de la boîte aux lettres) ?
  /// Le mesh peut-il joindre ce contact maintenant (direct ou par relais) ?
  bool _joignableEnMesh(String targetId) =>
      _repo.peerList.any((p) => p.peerId == targetId && !p.reconnecting);

  bool _contactEnLigne(String? targetId) =>
      targetId != null && isTorOnlyPeer(StorageService.getPeerRecord(targetId));

  void _flushOutbox() {
    if (_outbox.isEmpty) return;

    // ⚠️ PLUS D'ABANDON QUAND AUCUN PAIR MESH N'EST À PORTÉE. L'ancienne
    // garde `if (connectedPeerCount == 0) return;` bloquait aussi les
    // messages destinés à un contact EN LIGNE, que la boîte aux lettres
    // peut livrer sans le moindre voisin. Sans pair, on ne renvoie que ce
    // qui peut passer en ligne ; le reste attend une rencontre.
    final sansPair = _repo.transport.connectedPeerCount == 0;
    final gen = _outboxGeneration;
    final toFlush = sansPair
        ? _outbox.where(_eligibleMailbox).toList()
        : List<_OutboxEntry>.from(_outbox);
    if (toFlush.isEmpty) return;
    _outbox.removeWhere(toFlush.contains);

    // Le toast n'annonce qu'un vrai départ par le maillage : une relance en
    // ligne toutes les 30 s ne doit pas faire clignoter l'écran — le statut
    // du message suffit à dire quand il est parti.
    if (!sansPair) {
      _showToast('${toFlush.length} message${toFlush.length > 1 ? 's' : ''} en attente envoyé${toFlush.length > 1 ? 's' : ''}', type: DropletToastType.success);
    }

    for (final entry in toFlush) {
      _setStatus(entry.messageId, MessageStatus.sending);
      _doSendOutboxEntry(entry);
    }

    // Si de nouveaux messages ont été ajoutés pendant l'envoi, relancer.
    if (_outboxGeneration != gen && _outbox.isNotEmpty) {
      scheduleMicrotask(_flushOutbox);
    }
  }

  /// Renvoie un message dont l'envoi avait échoué.
  ///
  /// ── ⚠️ POURQUOI CETTE ACTION MANQUAIT, ET POURQUOI ELLE COMPTE ───
  ///
  /// Un message en échec affichait une icône rouge, et rien d'autre. La
  /// seule issue était de le retaper — sur un vocal ou une photo, cela
  /// voulait dire recommencer entièrement.
  ///
  /// Or l'échec ici n'est pas ce qu'il est ailleurs. Sans pair à
  /// portée, un message part en ATTENTE et se renvoie tout seul : c'est
  /// le fonctionnement normal. `failed` ne survient que lorsque l'envoi
  /// a réellement échoué malgré des appareils présents — une liaison
  /// coupée en plein transfert, un pair évincé au mauvais moment.
  /// Autrement dit : toujours une erreur passagère, toujours de celles
  /// qui réussissent au second essai.
  ///
  /// ⚠️ ON RÉUTILISE `_doSendOutboxEntry`, on ne réécrit pas l'envoi.
  /// Une seconde implémentation aurait fini par diverger de celle de la
  /// file d'attente — et un message renvoyé serait parti avec un
  /// chiffrement ou une cible légèrement différents.
  Future<void> renvoyer(String messageId) async {
    final msg = state.where((m) => m.id == messageId).firstOrNull;
    if (msg == null) return;

    final entree = _OutboxEntry(
      messageId: msg.id,
      kind: msg.type == 'file' ? _OutboxKind.file : _OutboxKind.text,
      targetId: msg.targetId,
      groupId: msg.groupId,
    );

    _setStatus(msg.id, MessageStatus.sending);

    if (_repo.transport.connectedPeerCount == 0 && !_eligibleMailbox(entree)) {
      // Plus personne à portée : on ne réessaie pas dans le vide, on
      // remet en attente. (Une conversation à deux, elle, peut repartir
      // par la boîte aux lettres : `_doSendOutboxEntry` s'en charge.) Le message repartira de lui-même à la
      // prochaine rencontre, exactement comme les autres.
      _setStatus(msg.id, MessageStatus.pending);
      _addToOutbox(entree);
      unawaited(StorageService.saveOutbox({
        'id': msg.id,
        'kind': entree.kind == _OutboxKind.file ? 'file' : 'text',
        'targetId': msg.targetId,
        'groupId': msg.groupId,
      }));
      _showToast(
        'Aucun pair à portée — le message repartira tout seul',
        type: DropletToastType.info,
      );
      return;
    }

    await _doSendOutboxEntry(entree);
  }

  Future<void> _doSendOutboxEntry(_OutboxEntry entry) async {
    try {
      final msg = state.where((m) => m.id == entry.messageId).firstOrNull;
      if (msg == null) {
        StorageService.clearOutboxEntry(entry.messageId);
        return;
      }

      // ⚠️ LA BOÎTE AUX LETTRES, QUAND C'EST LE BON CHEMIN. Ce renvoi ne
      // passait QUE par le maillage (`_repo.sendMessage`) : un contact
      // joignable seulement en ligne n'était jamais atteint, même avec des
      // voisins mesh présents, et le message restait bloqué.
      final targetId = entry.targetId;
      final sansPair = _repo.transport.connectedPeerCount == 0;
      final horsMeshEnLigne = targetId != null &&
          !_joignableEnMesh(targetId) &&
          EtatInternet.disponible();
      if (entry.groupId == null &&
          _eligibleMailbox(entry) &&
          (_contactEnLigne(targetId) || sansPair || horsMeshEnLigne)) {
        // ⚠️ SANS LA CLÉ DU DESTINATAIRE, ON N'ESSAIE MÊME PAS. Rien ne peut
        // lui être chiffré : chaque relève (toutes les 30 s) retentait
        // pourtant TOUS ses messages en attente, pour autant d'échecs certains
        // — des dizaines de tentatives inutiles, de la batterie et un journal
        // saturé (constaté sur Pixel 6 Pro). Le message reste simplement en
        // attente ; il partira dès que la clé sera apprise (hello mesh ou
        // clé jointe à un message reçu).
        if (!_repo.clePubliqueConnue(targetId!)) {
          _setStatus(entry.messageId, MessageStatus.pending);
          _outbox.add(entry);
          return;
        }
        var livre = false;
        if (entry.kind == _OutboxKind.text) {
          livre = await _tryMailboxSend(targetId, msg.content, msg.id, msg.type, replyToId: msg.replyToId);
        } else {
          final taille = msg.fileSize ?? 0;
          if (taille > 0 && taille <= FichierEnLigne.maximum) {
            final chemin = await StorageService.getSharedFilePath(
                msg.fileId ?? '', msg.fileName ?? '');
            if (chemin != null) {
              livre = await _envoyerFichierEnLigne(
                targetId,
                msg.fileName ?? '',
                msg.fileMimeType ?? '',
                await File(chemin).readAsBytes(),
                msg.fileId ?? msg.id,
              );
            }
          }
        }
        if (livre) {
          _setStatus(entry.messageId, MessageStatus.sent);
          StorageService.clearOutboxEntry(entry.messageId);
          return;
        }
        if (_contactEnLigne(targetId) || sansPair) {
          // Toujours pas livrable : on garde le message EN ATTENTE (toujours
          // persisté). Ajout direct, sans toucher à la génération, pour ne
          // pas relancer aussitôt une nouvelle tentative en boucle — la
          // prochaine relève s'en chargera.
          _setStatus(entry.messageId, MessageStatus.pending);
          _outbox.add(entry);
          return;
        }
      }

      if (entry.kind == _OutboxKind.text) {
        if (entry.groupId != null) {
          await _repo.sendGroupMessage(
            groupId: entry.groupId!,
            content: msg.content,
            replyToId: msg.replyToId,
            messageId: msg.id,
          );
        } else {
          await _repo.sendMessage(
            authorPseudo: msg.authorPseudo,
            content: msg.content,
            type: msg.type,
            imageUrl: msg.imageUrl,
            audioUrl: msg.audioUrl,
            replyToId: msg.replyToId,
            messageId: msg.id,
            targetId: entry.targetId,
          );
        }
      } else if (entry.kind == _OutboxKind.file) {
        final path = await StorageService.getSharedFilePath(msg.fileId ?? '', msg.fileName ?? '');
        if (path == null) throw StateError('Fichier introuvable localement');
        final bytes = await File(path).readAsBytes();
        await _repo.sendFile(
          fileName: msg.fileName ?? '',
          bytes: bytes,
          mimeType: msg.fileMimeType ?? '',
          targetId: entry.targetId,
          groupId: entry.groupId,
          fileId: msg.fileId,
          // Repris du message conservé : un vocal envoyé hors ligne en
          // réponse à un autre doit rester rattaché à sa question quand
          // il repart, plusieurs heures plus tard.
          replyToId: msg.replyToId,
        );
      }
      _setStatus(entry.messageId, MessageStatus.sent);
      StorageService.clearOutboxEntry(entry.messageId);
    } catch (_) {
      _setStatus(entry.messageId, MessageStatus.failed);
      _showToast('Échec d\'envoi d\'un message en attente', type: DropletToastType.error);
    }
  }

  void _setStatus(String messageId, MessageStatus status) {
    state = state.map((m) {
      if (m.id != messageId) return m;
      return m.copyWith(status: status);
    }).toList();
    StorageService.updateMessageStatus(messageId, status);
  }

  /// Planifie l'envoi des accusés de lecture après 1s (annulé si de nouveaux
  /// messages arrivent pendant ce délai). Évite de marquer lu trop tôt quand
  /// l'utilisateur ouvre brièvement une conversation.
  void scheduleReadReceipts(String? peerId) {
    _readDelayTimer?.cancel();
    _readDelayTimer = Timer(const Duration(seconds: 1), () {
      unawaited(sendReadReceipts(peerId));
    });
  }

  @override
  void dispose() {
    _peerSub?.cancel();
    _ackSub?.cancel();
    _readSub?.cancel();
    _reactionSub?.cancel();
    _editSub?.cancel();
    _epingleSub?.cancel();
    _newMessageSub?.cancel();
    _appelsSub?.cancel();
    _repairedSub?.cancel();
    _readDelayTimer?.cancel();
    _mailboxPollTimer?.cancel();
    _reactionEventCtrl.close();
    super.dispose();
  }
}

enum _OutboxKind { text, file }

/// Un message « en attente d'envoi » — mis de côté le temps qu'un pair
/// se reconnecte.
class _OutboxEntry {
  final String messageId;
  final _OutboxKind kind;
  final String? targetId;
  final String? groupId;
  const _OutboxEntry({
    required this.messageId,
    required this.kind,
    this.targetId,
    this.groupId,
  });
}

// ── Appels WebRTC (voix sur mesh) ─────────────────────────────────────────
//
// Ce notifier fait le lien entre l'écran d'appel (`call_screen.dart`) et
// les deux services techniques `CallSignalingService` (les « papiers
// d'entente ») et `WebRtcCallService` (le vrai son) — il traduit leurs
// événements internes en un état simple que l'écran peut afficher
// directement (« en train de sonner », « connecté », « raccroché »...).

final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier();
});

class CallNotifier extends StateNotifier<CallState> {
  CallSignalingService? _signaling;
  WebRtcCallService? _webrtc;
  StreamSubscription<CallEvent>? _eventSub;
  StreamSubscription<SignalingMessage>? _incomingCallSub;

  /// Appels distants SORTANTS via Railway WebSocket signaling — une
  /// connexion jetable, ouverte pour un seul appel puis détruite.
  remote_call.CallService? _remoteCallService;
  SignalingClient? _remoteSignaling;
  bool _isRemoteCall = false;

  /// La « boîte » personnelle permanente qui écoute les appels
  /// ENTRANTS via Internet — voir [_startInboxListener]. À la
  /// différence de [_remoteCallService], celle-ci reste ouverte pour
  /// toute la durée de vie de l'app : y mettre fin à un appel ne la
  /// referme jamais (voir `CallService.persistent`).
  remote_call.CallService? _inboxCallService;
  SignalingClient? _inboxSignaling;
  StreamSubscription<remote_call.CallState>? _inboxStateSub;
  StreamSubscription<void>? _inboxMediaSub;
  StreamSubscription<void>? _remoteMediaSub;
  Timer? _inboxReconnectTimer;

  /// Le service de l'appel par Internet EN COURS — la boîte permanente pour
  /// un appel reçu, la connexion jetable pour un appel émis. `null` pour un
  /// appel mesh local.
  remote_call.CallService? get _appelDistantActif {
    if (!_isRemoteCall) return null;
    return state.direction == CallDirection.incoming
        ? _inboxCallService
        : _remoteCallService;
  }

  /// Recopie dans l'état l'image envoyée et reçue de l'appel par Internet.
  void _synchroniserMedias(remote_call.CallService service) {
    if (!identical(service, _appelDistantActif) || !state.isCallActive) return;
    state = state.copyWith(
      isVideoEnabled: service.videoActive,
      isRemoteVideoActive: service.videoDistante,
      isReconnecting: service.reconnexion,
      viaRelais: service.viaRelais,
      latencyMs: service.rttMs,
    );
  }

  String? _pendingOfferSdp;

  // ── Journal d'appels ────────────────────────────────────────────────
  // De quoi transformer l'appel en cours en une ligne d'historique au
  // moment où il se termine. Ces champs sont volontairement en dehors de
  // `CallState` : ils ne concernent que la comptabilité, l'écran d'appel
  // n'a rien à en faire.

  /// Début de la sonnerie de l'appel en cours.
  DateTime? _callStartedAt;

  /// Moment où l'autre a décroché — reste nul pour un appel jamais
  /// abouti, ce qui est précisément ce qui distingue un appel manqué.
  DateTime? _callConnectedAt;

  /// Copiés au démarrage : à la fin de l'appel, `state` a déjà été remis
  /// à zéro par endroits, et on veut malgré tout savoir qui on appelait.
  String? _callPeerId;
  String? _callPeerPseudo;

  CallNotifier() : super(const CallState()) {
    // ⚠️ `addListener`, PAS UN OVERRIDE DU SETTER `state`. Intercepter
    // l'écriture de `state` marcherait aussi, mais ce setter est marqué
    // `@protected` dans `state_notifier` : le redéfinir est du bricolage
    // sur l'API interne d'un paquet, qui casse sans prévenir à la
    // prochaine montée de version. `addListener` est public, documenté,
    // et fait exactement la même chose.
    addListener(_majNotificationAppel, fireImmediately: false);

    // Le bouton « Raccrocher » de la notification système. Branché ici
    // plutôt qu'au premier appel : le service survit à la mort du moteur
    // Flutter, donc la notification peut exister avant qu'un seul appel
    // n'ait été passé dans CETTE instance de l'application.
    AppelSysteme.onRaccrocher = (_) => hangUp();
    AppelSysteme.initialiser();
  }

  // ── La notification « appel en cours » ──────────────────────────────
  //
  // ⚠️ UN SEUL ENDROIT, PAS DOUZE. L'état d'appel est modifié à trois
  // endroits pour le décrochage et à neuf pour la fin. Poser un appel de
  // notification à chacun garantissait qu'un futur chemin en oublierait
  // un — et l'oubli se voit de la pire façon : une notification d'appel
  // permanente, pour un appel raccroché depuis longtemps, qu'on ne peut
  // même pas balayer.
  //
  // En écoutant l'état une fois pour toutes, la notification le suit par
  // construction : aucun chemin futur ne peut l'oublier.

  /// Ce que la notification affiche en ce moment — pour ne la redessiner
  /// que quand quelque chose a changé. `state` est réécrit très souvent
  /// pendant un appel (niveau sonore, débit, latence).
  String? _notifAppelId;

  void _majNotificationAppel(CallState s) {
    // ⚠️ ON NE REGARDE PAS `connectionState`, seulement « l'appel
    // existe-t-il encore ». Une coupure passagère (Wi-Fi ↔ 4G) fait
    // retomber l'état en `connecting` pendant deux secondes : s'en servir
    // ici ferait disparaître puis réapparaître la notification à chaque
    // hoquet du réseau. `debutConnexion` non nul dit déjà que l'appel a
    // été décroché, et c'est la seule chose qui compte.
    final actif =
        s.isCallActive && s.peerId != null && s.debutConnexion != null;

    if (!actif) {
      final ancien = _notifAppelId;
      if (ancien != null) {
        _notifAppelId = null;
        unawaited(NotificationService.fermerAppelEnCours(ancien));
      }
      // Toujours, même sans `ancien` : voir le commentaire d'`arreter`.
      unawaited(AppelSysteme.arreter());
      return;
    }
    // Déjà affichée pour ce pair : on ne la redessine pas. Android
    // redémarrerait le chronomètre à chaque mise à jour du niveau sonore.
    if (_notifAppelId == s.peerId) return;

    // ⚠️ LE PAIR A CHANGÉ SANS PASSER PAR L'ÉTAT INACTIF — un appel en
    // attente pris à la volée. Chaque pair a sa propre notification :
    // sans cette fermeture, celle du premier resterait affichée pour
    // toujours, et elle n'est pas balayable.
    final precedent = _notifAppelId;
    if (precedent != null) {
      unawaited(NotificationService.fermerAppelEnCours(precedent));
    }
    _notifAppelId = s.peerId;
    unawaited(_poserNotification(s));
  }

  /// ⚠️ LE NATIF D'ABORD, LE DART EN REPLI — ET JAMAIS LES DEUX.
  ///
  /// Seule la notification `CallStyle` d'Android, portée par un service de
  /// type `phoneCall`, fait apparaître la PASTILLE dans la barre d'état,
  /// avec le combiné et le minuteur visibles depuis l'écran d'accueil.
  /// `flutter_local_notifications` ne sait pas la produire.
  ///
  /// Mais si la partie Kotlin n'est pas encore dans le projet, ou si
  /// Android refuse le service, on ne doit pas se retrouver sans rien :
  /// la notification Dart, elle, marche partout. Afficher les deux serait
  /// pire que les deux cas — deux notifications d'appel empilées, dont
  /// aucune ne se balaie.
  Future<void> _poserNotification(CallState s) async {
    final pseudo = s.peerPseudo ?? s.peerId!;
    final natif = await AppelSysteme.demarrer(
      pairId: s.peerId!,
      pseudo: pseudo,
      debut: s.debutConnexion!,
      video: s.isVideoEnabled,
      via: s.isRemoteCall ? 'Internet' : 'Maillage',
    );
    if (natif) return;
    await NotificationService.appelEnCours(
      peerId: s.peerId!,
      pseudo: pseudo,
      debut: s.debutConnexion!,
      viaInternet: s.isRemoteCall,
    );
  }

  bool _initialized = false;
  MeshRepository? _repo;
  String? _signalingUrl;

  /// Les « en train d'écrire » arrivés par la boîte d'appels (Internet).
  StreamSubscription<Map<String, dynamic>>? _inboxFrappeSub;

  /// Signale à [peerId], joint par Internet, qu'on est en train d'écrire.
  /// Relayé par le serveur d'appels jusqu'à sa boîte, sans la rejoindre
  /// (ce qui le ferait sonner) et sans notification.
  void envoyerFrappeEnLigne(String peerId, {String? groupId}) {
    final boite = _inboxSignaling;
    if (boite == null || !boite.isConnected) return;
    boite.envoyerBrut({'type': 'frappe', 'to': peerId, 'g': ?groupId});
  }

  /// Branche ce notifier sur le vrai transport mesh — appelé une fois au
  /// démarrage de l'app, dès qu'une identité existe.
  void init(MeshTransportService transport, {MeshRepository? repo, String? signalingUrl}) {
    if (_initialized) return;
    _initialized = true;
    _repo = repo;
    _signalingUrl = signalingUrl;
    _signaling = CallSignalingService(transport);
    _signaling!.startListening();
    _webrtc = WebRtcCallService(_signaling!);
    _incomingCallSub = _signaling!.incomingMessages.listen(_onIncomingCall);
    unawaited(_startInboxListener());
  }

  /// Rejoint, une bonne fois pour toutes, notre propre « boîte » de
  /// signalisation sur le serveur Railway — ce qui permet de RECEVOIR
  /// un appel Internet, pas seulement d'en émettre.
  ///
  /// ⚠️ POURQUOI ÉMETTRE MARCHAIT DÉJÀ ET RECEVOIR, NON.
  //
  // `_startRemoteCall` ci-dessous rejoint une salle et y dépose une
  // offre — ça n'a jamais eu besoin de personne à l'écoute à l'avance
  // puisque c'est nous qui l'ouvrons. Mais RECEVOIR suppose l'inverse :
  // il faut être DÉJÀ PRÉSENT quelque part quand l'offre arrive, sans
  // savoir à l'avance qui appellera ni quand. Cette « boîte » — une
  // salle nommée d'après notre seul identifiant, `inbox_<monId>` —
  // est ce quelque part : on y reste en permanence, et n'importe qui
  // voulant nous joindre sait exactement où déposer son offre (voir
  // `CallService.startCall`, qui vise cette même salle).
  Future<void> _startInboxListener() async {
    final signalingUrl = _signalingUrl;
    final myId = _repo?.myId;
    if (signalingUrl == null || myId == null || myId.isEmpty) return;

    _inboxSignaling = SignalingClient(serverUrl: signalingUrl);
    _inboxSignaling!.onFermeture = _reprogrammerBoite;
    _inboxCallService =
        remote_call.CallService(signalingClient: _inboxSignaling!, persistent: true);
    _inboxCallService!.init();
    _inboxStateSub?.cancel();
    _inboxStateSub = _inboxCallService!.stateStream.listen(_onInboxCallStateChanged);
    final boite = _inboxCallService!;
    _inboxMediaSub?.cancel();
    _inboxMediaSub = boite.changements.listen((_) => _synchroniserMedias(boite));
    _inboxFrappeSub?.cancel();
    _inboxFrappeSub = _inboxSignaling!.messagesBruts.listen((message) {
      if (message['type'] != 'frappe') return;
      final de = message['from'];
      final groupe = message['g'];
      if (de is String && de.isNotEmpty) {
        _repo?.signalerFrappeEnLigne(de, groupId: groupe is String ? groupe : null);
      }
    });

    try {
      await _inboxSignaling!.joinRoom('inbox_$myId', myId);
      debugPrint('[CallNotifier] Boîte d\'appels entrants rejointe (inbox_$myId)');
      // Identifiants de relais chargés d'avance : décrocher ne les attend pas.
      unawaited(_inboxSignaling!.serveursIceDuServeur());
    } catch (e) {
      debugPrint('[CallNotifier] Échec de connexion à la boîte d\'appels: $e');
    }

    // Un WebSocket qui reste ouvert des heures durant peut se couper
    // (changement de réseau, veille de l'appareil) sans que personne
    // ne le décide — `SignalingClient` ne se reconnecte pas tout
    // seul. Un simple contrôle périodique suffit à ce qu'un appel qui
    // arriverait juste après une coupure ne tombe pas dans le vide.
    _inboxReconnectTimer?.cancel();
    _inboxReconnectTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_inboxSignaling != null && !_inboxSignaling!.isConnected) {
        debugPrint('[CallNotifier] Boîte d\'appels déconnectée — reconnexion');
        unawaited(_inboxSignaling!.joinRoom('inbox_$myId', myId));
      }
    });
  }

  int _essaisBoite = 0;
  Timer? _reconnexionBoite;

  /// La boîte d'appels vient de perdre sa connexion : on la rétablit en
  /// 2 s, puis 4, 8, 15 et 30 s si le serveur reste injoignable — au lieu
  /// d'attendre le contrôle périodique de 60 s, pendant lequel tout appel
  /// entrant était perdu.
  void _reprogrammerBoite() {
    final myId = _repo?.myId;
    if (myId == null || myId.isEmpty || _inboxSignaling == null) return;
    const delais = [2, 4, 8, 15, 30];
    final delai = Duration(seconds: delais[_essaisBoite.clamp(0, delais.length - 1)]);
    _essaisBoite++;
    _reconnexionBoite?.cancel();
    _reconnexionBoite = Timer(delai, () async {
      final boite = _inboxSignaling;
      if (boite == null || boite.isConnected) return;
      if (await boite.joinRoom('inbox_$myId', myId)) {
        _essaisBoite = 0;
        debugPrint('[CallNotifier] Boîte d\'appels reconnectée');
      } else {
        _reprogrammerBoite();
      }
    });
  }

  /// Réagit aux événements de la boîte d'appels ENTRANTS permanente.
  void _onInboxCallStateChanged(remote_call.CallState s) {
    switch (s) {
      case remote_call.CallState.ringing:
        // Une offre vient d'arriver : quelqu'un nous appelle par
        // Internet. Même traitement que pour un appel local entrant
        // (voir `_onIncomingCall`), sauf que la réponse partira par
        // `_inboxCallService`, pas `_webrtc`.
        if (state.isCallActive) return; // déjà en appel — on n'écrase rien
        final peerId = _inboxCallService?.remotePeerId;
        if (peerId == null) return;
        _isRemoteCall = true;
        _beginCallLog(peerId, null, CallDirection.incoming);
        state = state.copyWith(
          isCallActive: true,
          peerId: peerId,
          direction: CallDirection.incoming,
          connectionState: CallConnectionState.connecting,
          isRemoteCall: true,
          // Avant de décrocher : « appel VIDÉO entrant » plutôt que vocal.
          isVideoEnabled: _inboxCallService?.offreVideo ?? false,
          isRemoteVideoActive: false,
        );
        if (_doitDecrocherAutomatiquement(peerId)) {
          // Déjà accepté depuis la notification : pas de seconde sonnerie.
          unawaited(answerCall());
        } else {
          CallRingerService.startIncoming();
        }
      case remote_call.CallState.connected:
        if (!_isRemoteCall || state.direction != CallDirection.incoming) return;
        CallRingerService.stop();
        _callConnectedAt ??= DateTime.now();
        state = state.copyWith(
          connectionState: CallConnectionState.connected,
          debutConnexion: _callConnectedAt,
        );
      case remote_call.CallState.disconnected:
        if (!_isRemoteCall || state.direction != CallDirection.incoming) return;
        CallRingerService.stop();
        _finishCallLog(null);
        _isRemoteCall = false;
        state = const CallState();
      case remote_call.CallState.idle:
      case remote_call.CallState.calling:
        break;
    }
  }

  void _onIncomingCall(SignalingMessage msg) {
    // ⚠️ Un contact bloqué ne peut pas nous appeler : son appel sonne dans
    // le vide de son côté et ne sonne jamais ici, comme chez WhatsApp.
    if (StorageService.isContactBlocked(msg.peerId)) return;
    // Ce callback est un `onData` de Stream.listen, actif en permanence dès
    // le lancement de l'app (init() est appelé à l'onboarding). Une
    // exception synchrone ici (cast raté sur des données malformées venant
    // d'un pair) ne serait rattrapée par personne et ferait planter l'app à
    // chaque réception d'un message de signalisation — d'où le try/catch.
    try {
      debugPrint('[CallNotifier] _onIncomingCall type=0x${msg.type.toRadixString(16)} peer=${msg.peerId} sdpPresent=${msg.data.containsKey('sdp')}');
      // Une offre porteuse d'une liste de participants est une invitation à
      // un appel de groupe — gérée séparément par GroupCallNotifier, jamais
      // comme un appel 1:1 entrant.
      if (msg.data['participants'] != null) return;
      if (msg.type == kCallOffer) {
        final sdp = msg.data['sdp'] as String?;
        if (sdp == null) return;
        _pendingOfferSdp = sdp;
        _beginCallLog(msg.peerId, null, CallDirection.incoming);
        state = state.copyWith(
          isCallActive: true,
          peerId: msg.peerId,
          direction: CallDirection.incoming,
          connectionState: CallConnectionState.connecting,
        );
        CallRingerService.startIncoming();
      }
    } catch (e) {
      debugPrint('[CallNotifier] message de signalisation invalide ignoré: $e');
    }
  }

  /// Démarre un appel SORTANT vers [peerId] — fait sonner la tonalité de
  /// rappel et lance la négociation WebRTC.
  ///
  /// Si le peer est local (WiFi/NativeP2P), utilise le signaling mesh.
  /// Sinon, utilise le signaling Railway (WebSocket distant).
  Future<void> startCall(String peerId, String peerPseudo, {bool video = false}) async {
    _beginCallLog(peerId, peerPseudo, CallDirection.outgoing);
    state = state.copyWith(
      isCallActive: true,
      peerId: peerId,
      peerPseudo: peerPseudo,
      direction: CallDirection.outgoing,
      connectionState: CallConnectionState.connecting,
    );

    final isLocal = _signaling != null && _signaling!.canCallPeer(peerId);
    _isRemoteCall = !isLocal;
    state = state.copyWith(isRemoteCall: _isRemoteCall);

    if (isLocal) {
      await _startLocalCall(peerId);
    } else {
      await _startRemoteCall(peerId, video: video);
    }
  }

  /// Appel local via le mesh transport (WiFi/NativeP2P).
  Future<void> _startLocalCall(String peerId) async {
    if (_signaling == null || _webrtc == null) return;
    CallRingerService.startOutgoing();

    try {
      _eventSub?.cancel();
      _eventSub = _webrtc!.events.listen(_onWebrtcEvent);
      await _webrtc!.startCall(peerId);
    } catch (e) {
      CallRingerService.stop();
      _finishCallLog(CallOutcome.failed);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.failed,
      );
    }
  }

  /// Appel distant via le serveur Railway (WebSocket signaling + WebRTC).
  Future<void> _startRemoteCall(String peerId, {bool video = false}) async {
    CallRingerService.startOutgoing();
    state = state.copyWith(isVideoEnabled: video, isSpeakerOn: video);

    try {
      final signalingUrl = _getSignalingUrl();
      if (signalingUrl == null) {
        debugPrint('[CallNotifier] URL signaling non configurée');
        CallRingerService.stop();
        _finishCallLog(CallOutcome.failed);
        state = state.copyWith(
          isCallActive: false,
        effacerDebut: true,
          connectionState: CallConnectionState.failed,
        );
        return;
      }

      _remoteSignaling = SignalingClient(serverUrl: signalingUrl);
      _remoteCallService = remote_call.CallService(signalingClient: _remoteSignaling!);
      _remoteCallService!.init();
      final sortant = _remoteCallService!;
      _remoteMediaSub?.cancel();
      _remoteMediaSub = sortant.changements.listen((_) => _synchroniserMedias(sortant));

      _remoteCallService!.stateStream.listen((s) {
        if (s == remote_call.CallState.connected) {
          CallRingerService.stop();
          _callConnectedAt ??= DateTime.now();
          state = state.copyWith(
          connectionState: CallConnectionState.connected,
          debutConnexion: _callConnectedAt,
        );
        } else if (s == remote_call.CallState.disconnected) {
          CallRingerService.stop();
          _finishCallLog(null);
          state = state.copyWith(
            isCallActive: false,
        effacerDebut: true,
            connectionState: CallConnectionState.disconnected,
          );
        }
      });

      final myId = _repo?.myId ?? '';
      await _remoteCallService!.startCall(myId, peerId, video: video);
      debugPrint('[CallNotifier] Appel distant lancé vers $peerId');
    } catch (e) {
      debugPrint('[CallNotifier] Erreur appel distant: $e');
      CallRingerService.stop();
      _finishCallLog(CallOutcome.failed);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.failed,
      );
    }
  }

  String? _getSignalingUrl() {
    return _signalingUrl;
  }

  /// Décroche l'appel ENTRANT en cours de sonnerie.
  // ── DÉCROCHER DEPUIS LA NOTIFICATION, APPLICATION FERMÉE ──────────────
  //
  // « Décrocher » ouvre l'application, qui doit d'abord démarrer puis
  // recevoir l'offre (renvoyée toutes les 3 s par l'appelant). Il fallait
  // ensuite ATTENDRE que ça sonne dans l'application et décrocher une
  // seconde fois. Le choix est maintenant retenu une minute : l'appel est
  // pris dès qu'il arrive.
  final Map<String, DateTime> _decrocherDesReception = {};

  void accepterDesQueLAppelArrive(String peerId) {
    if (state.isCallActive &&
        state.peerId == peerId &&
        state.direction == CallDirection.incoming) {
      unawaited(answerCall());
      return;
    }
    _decrocherDesReception[peerId] = DateTime.now().add(const Duration(minutes: 1));
  }

  bool _doitDecrocherAutomatiquement(String peerId) {
    final limite = _decrocherDesReception.remove(peerId);
    return limite != null && DateTime.now().isBefore(limite);
  }

  Future<void> answerCall() async {
    // ⚠️ UN SEUL DÉCROCHÉ. Tant que la liaison s'établit, un second appui
    // relançait toute la préparation (micro, connexion, réponse).
    if (state.decroche) return;
    if (_isRemoteCall) {
      await _answerRemoteCall();
      return;
    }
    if (_signaling == null || _webrtc == null) return;
    final peerId = state.peerId;
    final sdp = _pendingOfferSdp;
    if (peerId == null || sdp == null) return;

    CallRingerService.stop();
    state = state.copyWith(
      isCallActive: true,
      connectionState: CallConnectionState.connecting,
      decroche: true,
    );

    try {
      _eventSub?.cancel();
      _eventSub = _webrtc!.events.listen(_onWebrtcEvent);
      await _webrtc!.answerCall(peerId, sdp);
    } catch (e) {
      _finishCallLog(CallOutcome.failed);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.failed,
      );
    }
  }

  Future<void> _answerRemoteCall() async {
    // Un appel ENTRANT par Internet n'a jamais transité par
    // `_remoteCallService` (réservé aux appels SORTANTS, une connexion
    // jetable créée dans `_startRemoteCall`) — il est arrivé sur la
    // boîte personnelle permanente, `_inboxCallService`. Décrocher doit
    // donc répondre depuis la bonne connexion.
    final service = state.direction == CallDirection.incoming
        ? _inboxCallService
        : _remoteCallService;
    if (service == null) return;
    CallRingerService.stop();
    state = state.copyWith(
      isCallActive: true,
      connectionState: CallConnectionState.connecting,
      decroche: true,
    );
    try {
      final myId = _repo?.myId ?? '';
      final peerId = state.peerId ?? '';
      await service.answerCall(myId, peerId);
      state = state.copyWith(
        isSpeakerOn: service.videoActive,
        isVideoEnabled: service.videoActive,
        isRemoteVideoActive: service.videoDistante,
      );
    } catch (e) {
      _finishCallLog(CallOutcome.failed);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.failed,
      );
    }
  }

  RTCVideoRenderer? get remoteRenderer =>
      _isRemoteCall ? _appelDistantActif?.remoteRenderer : _webrtc?.remoteRenderer;
  RTCVideoRenderer? get localRenderer =>
      _isRemoteCall ? _appelDistantActif?.localRenderer : _webrtc?.localRenderer;

  /// Caméra avant ↔ arrière (appel par Internet).
  Future<void> switchCamera() async {
    await _appelDistantActif?.switchCamera();
  }

  /// Traduit chaque événement technique de WebRTC en un changement
  /// d'état compréhensible pour l'écran d'appel.
  void _onWebrtcEvent(CallEvent event) {
    if (event is CallConnecting) {
      state = state.copyWith(connectionState: CallConnectionState.connecting);
    } else if (event is CallConnected) {
      CallRingerService.stop();
      _callConnectedAt ??= DateTime.now();
      state = state.copyWith(
          connectionState: CallConnectionState.connected,
          debutConnexion: _callConnectedAt,
        );
    } else if (event is CallFailed) {
      CallRingerService.stop();
      _finishCallLog(CallOutcome.failed);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.failed,
      );
    } else if (event is CallDisconnected) {
      CallRingerService.stop();
      _finishCallLog(null);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.disconnected,
      );
    } else if (event is CallRemoteHangUp) {
      CallRingerService.stop();
      _finishCallLog(null);
      state = state.copyWith(
        isCallActive: false,
        effacerDebut: true,
        connectionState: CallConnectionState.disconnected,
      );
    } else if (event is CallStatsUpdated) {
      state = state.copyWith(
        latencyMs: event.latencyMs > 0 ? event.latencyMs : state.latencyMs,
        bitrateKbps: event.bitrateKbps > 0 ? event.bitrateKbps : state.bitrateKbps,
        audioLevel: event.audioLevel,
      );
    } else if (event is VideoAdded) {
      state = state.copyWith(
        isRemoteVideoActive: true,
        isVideoEnabled: true,
      );
    } else if (event is VideoRemoved) {
      state = state.copyWith(isRemoteVideoActive: false);
    }
  }

  void toggleMute() {
    final distant = _appelDistantActif;
    if (distant != null) {
      unawaited(distant.toggleMicrophone());
      state = state.copyWith(isMuted: !state.isMuted);
      return;
    }
    if (_webrtc == null) return;
    final wasMuted = state.isMuted;
    _webrtc!.toggleMute();
    state = state.copyWith(isMuted: !wasMuted);
  }

  void toggleSpeaker() {
    final distant = _appelDistantActif;
    if (distant != null) {
      final actif = !state.isSpeakerOn;
      unawaited(distant.setSpeaker(actif).catchError((e) => debugPrint('[Call] haut-parleur: $e')));
      state = state.copyWith(isSpeakerOn: actif);
      return;
    }
    if (_webrtc == null) return;
    _webrtc!.toggleSpeaker();
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  void toggleVideo() {
    final distant = _appelDistantActif;
    if (distant != null) {
      // L'état suit le service (`changements`) : une permission caméra
      // refusée ne doit pas afficher une caméra « allumée ».
      unawaited(distant.toggleCamera().catchError((e) {
        debugPrint('[Call] caméra: $e');
      }));
      return;
    }
    if (_webrtc == null) return;
    _webrtc!.toggleVideo();
    state = state.copyWith(isVideoEnabled: !state.isVideoEnabled);
  }

  void hangUp() {
    CallRingerService.stop();
    _finishCallLog(null);
    if (_isRemoteCall) {
      if (state.direction == CallDirection.incoming) {
        // La boîte personnelle (`_inboxCallService`) ne se détruit
        // JAMAIS ici — `CallService.persistent` fait déjà en sorte que
        // `endCall()` n'y quitte pas la salle. La détruire nous
        // rendrait injoignable pour tout appel suivant.
        unawaited(_inboxCallService?.endCall());
      } else {
        unawaited(_remoteCallService?.endCall());
        _remoteCallService = null;
        _remoteSignaling?.dispose();
        _remoteSignaling = null;
      }
      _isRemoteCall = false;
    } else if (_webrtc != null) {
      unawaited(_webrtc!.hangUp().catchError((e) => debugPrint('[Call] échec hangUp: $e')));
    }
    _eventSub?.cancel();
    state = const CallState();
  }

  // ── Journalisation ──────────────────────────────────────────────────

  /// Note le début d'un appel. Rien n'est écrit sur le disque à ce
  /// stade : on ne sait pas encore comment il va se terminer, et un appel
  /// en cours n'a pas sa place dans un historique.
  void _beginCallLog(String peerId, String? pseudo, CallDirection direction) {
    _callStartedAt = DateTime.now();
    _callConnectedAt = null;
    _callPeerId = peerId;
    _callPeerPseudo = pseudo;
    _callDirection = direction;
  }

  CallDirection _callDirection = CallDirection.outgoing;

  /// Écrit l'appel qui vient de se terminer dans le journal.
  ///
  /// [forcedOutcome] sert aux échecs explicites ; sinon le résultat se
  /// déduit tout seul : si l'appel a été décroché à un moment, c'est un
  /// appel abouti, sinon c'est un appel manqué.
  ///
  /// Écriture asynchrone non attendue : raccrocher doit être instantané,
  /// et un échec d'écriture du journal ne doit jamais empêcher de
  /// raccrocher.
  void _finishCallLog(CallOutcome? forcedOutcome) {
    final startedAt = _callStartedAt;
    final peerId = _callPeerId;
    // Appelé deux fois de suite (raccrochage local puis événement
    // « déconnecté » de WebRTC) : le premier appel remet ces champs à
    // zéro, le second n'a donc plus rien à écrire. Sans cette garde, un
    // seul appel apparaîtrait deux fois dans l'historique.
    if (startedAt == null || peerId == null) return;
    _callStartedAt = null;
    _callPeerId = null;

    final connectedAt = _callConnectedAt;
    final outcome = forcedOutcome ??
        (connectedAt != null ? CallOutcome.answered : CallOutcome.missed);

    final entry = CallLogEntry(
      id: '${startedAt.microsecondsSinceEpoch}-$peerId',
      peerId: peerId,
      // Pour un appel entrant, personne ne nous a donné de pseudo : on le
      // retrouve dans la fiche du pair, sinon dans l'état de l'appel.
      // « Inconnu » ne distinguait rien : deux appels manqués de deux
      // personnes différentes s'affichaient à l'identique, et on ne
      // pouvait pas savoir qui rappeler. Un identifiant abrégé, lui,
      // reste stable d'un appel à l'autre — on reconnaît « Pair
      // 3f7a1c92 » même sans savoir qui c'est.
      peerPseudo: nomDuPair(peerId, [
        _callPeerPseudo,
        StorageService.getPeerRecord(peerId)?.pseudo,
        state.peerPseudo,
      ]),
      direction: _callDirection,
      outcome: outcome,
      startedAt: startedAt,
      duration: connectedAt != null
          ? DateTime.now().difference(connectedAt)
          : Duration.zero,
    );

    unawaited(StorageService.addCallLog(entry)
        .catchError((e) => debugPrint('[Call] échec journal: $e')));
    // Appel reçu sans réponse : il apparaît aussi dans la discussion.
    if (_callDirection == CallDirection.incoming && outcome == CallOutcome.missed) {
      _repo?.noterAppelDansDiscussion(
        peerId: peerId,
        video: state.isVideoEnabled,
        quand: startedAt,
      );
    }
  }

  bool canCallPeer(String peerId) {
    return _signaling?.canCallPeer(peerId) ?? false;
  }

  @override
  void dispose() {
    CallRingerService.stop();
    _eventSub?.cancel();
    _incomingCallSub?.cancel();
    _webrtc?.dispose();
    _signaling?.dispose();
    _inboxReconnectTimer?.cancel();
    _reconnexionBoite?.cancel();
    _inboxStateSub?.cancel();
    _inboxMediaSub?.cancel();
    _remoteMediaSub?.cancel();
    _inboxCallService?.dispose();
    _inboxSignaling?.dispose();
    super.dispose();
  }
}

// ── Appels de groupe (voix, maillage complet) ──────────────────────────────
//
// Service et état entièrement séparés de CallNotifier/WebRtcCallService
// (appels 1:1) — aucune donnée partagée, pour ne jamais risquer de
// régression sur le chemin d'appel 1:1 déjà en production.

final groupCallProvider = StateNotifierProvider<GroupCallNotifier, GroupCallState>((ref) {
  return GroupCallNotifier();
});

class GroupCallNotifier extends StateNotifier<GroupCallState> {
  CallSignalingService? _signaling;
  GroupWebrtcCallService? _webrtc;

  /// L'appel de groupe PAR INTERNET en cours (sinon, c'est celui du mesh).
  AppelGroupeInternet? _internet;
  MeshRepository? _repo;
  StreamSubscription<({String groupId, String fromPeerId, List<String> participants})>? _inviteSub;

  /// Le groupe d'une invitation reçue par Internet (`pendingInvite` n'a alors
  /// pas d'offre SDP : on rejoint la salle du groupe).
  String? _inviteGroupe;

  /// Vrai quand ce qui tourne est un SALON VOCAL et non un appel.
  ///
  /// La différence n'est pas cosmétique : dans un appel, rester seul veut
  /// dire que l'autre a raccroché, donc on raccroche aussi. Dans un salon,
  /// rester seul est normal — on vient d'ouvrir la porte et on attend.
  bool _salon = false;

  /// De quoi nommer quelqu'un qui entre dans le salon après nous : au
  /// moment où il arrive, on n'a que son identifiant.
  String Function(String peerId)? _pseudoDe;
  StreamSubscription<GroupCallEvent>? _eventSub;
  StreamSubscription<SignalingMessage>? _incomingSub;
  String _myId = '';
  bool _initialized = false;

  GroupCallNotifier() : super(const GroupCallState());

  /// Invitation à un appel de groupe reçue, en attente d'acceptation/refus.
  ({String fromPeerId, String sdp, List<String> participants})? pendingInvite;

  void init(MeshTransportService transport, String myId, {MeshRepository? repo}) {
    if (repo != null && _inviteSub == null) {
      _repo = repo;
      _inviteSub = repo.groupCallInvites.listen(_surInvitationInternet);
    }
    _myId = myId;
    if (_initialized) return;
    _initialized = true;
    _signaling = CallSignalingService(transport);
    _signaling!.startListening();
    _webrtc = GroupWebrtcCallService(_signaling!);
    _incomingSub = _signaling!.incomingMessages.listen(_onIncomingOffer);
  }

  void _onIncomingOffer(SignalingMessage msg) {
    // Même raison qu'au-dessus : listener permanent sans protection en
    // amont. `.cast<String>()` est paresseux — une exception ne surviendrait
    // qu'au moment d'itérer la liste (ex. dans acceptInvite), potentiellement
    // hors de tout try/catch ; on matérialise donc la liste ici, sous try.
    try {
      if (msg.type != kCallOffer) return;
      final rawParticipants = msg.data['participants'] as List?;
      if (rawParticipants == null) return; // offre 1:1 classique, pas pour nous
      final participants = rawParticipants.map((e) => e as String).toList();
      if (state.isActive || pendingInvite != null) return; // déjà occupé
      final sdp = msg.data['sdp'] as String?;
      if (sdp == null) return;
      pendingInvite = (fromPeerId: msg.peerId, sdp: sdp, participants: participants);
      CallRingerService.startIncoming();
      // Ré-émet l'état courant pour notifier les auditeurs Riverpod qu'une
      // invitation est disponible (pendingInvite n'est pas dans CallState).
      state = state.copyWith();
    } catch (e) {
      debugPrint('[GroupCallNotifier] message de signalisation invalide ignoré: $e');
    }
  }

  Future<void> startGroupCall({
    required String groupId,
    required String groupName,
    required List<String> memberPeerIds,
    required String Function(String peerId) pseudoFor,
    bool parInternet = false,
  }) async {
    if (parInternet) {
      await _demarrerParInternet(
        groupId: groupId,
        groupName: groupName,
        memberPeerIds: memberPeerIds,
        pseudoFor: pseudoFor,
      );
      return;
    }
    if (_webrtc == null) return;
    _salon = false;
    _pseudoDe = pseudoFor;
    state = GroupCallState(
      isActive: true,
      groupId: groupId,
      groupName: groupName,
      participants: memberPeerIds.map((id) => GroupCallParticipant(peerId: id, pseudo: pseudoFor(id))).toList(),
    );
    CallRingerService.startOutgoing();
    _eventSub?.cancel();
    _eventSub = _webrtc!.events.listen(_onEvent);
    try {
      await _webrtc!.startGroupCall(myId: _myId, memberPeerIds: memberPeerIds);
    } catch (e) {
      debugPrint('[GroupCall] échec démarrage: $e');
      CallRingerService.stop();
      state = const GroupCallState();
    }
  }

  Future<void> acceptInvite({required String Function(String peerId) pseudoFor}) async {
    if (_inviteGroupe != null) {
      await _accepterParInternet(pseudoFor);
      return;
    }
    final invite = pendingInvite;
    if (invite == null || _webrtc == null) return;
    pendingInvite = null;
    CallRingerService.stop();

    final otherIds = invite.participants.where((id) => id != _myId).toSet()..add(invite.fromPeerId);
    _salon = false;
    _pseudoDe = pseudoFor;
    state = GroupCallState(
      isActive: true,
      participants: otherIds.map((id) => GroupCallParticipant(peerId: id, pseudo: pseudoFor(id))).toList(),
    );
    _eventSub?.cancel();
    _eventSub = _webrtc!.events.listen(_onEvent);
    try {
      await _webrtc!.joinGroupCall(
        myId: _myId,
        fromPeerId: invite.fromPeerId,
        offerSdp: invite.sdp,
        allParticipants: invite.participants,
      );
    } catch (e) {
      debugPrint('[GroupCall] échec adhésion: $e');
      state = const GroupCallState();
    }
  }

  void declineInvite() {
    if (_inviteGroupe != null) {
      _inviteGroupe = null;
      pendingInvite = null;
      CallRingerService.stop();
      state = state.copyWith();
      return;
    }
    final invite = pendingInvite;
    pendingInvite = null;
    CallRingerService.stop();
    if (invite != null) {
      unawaited(_signaling?.sendHangUp(invite.fromPeerId));
    }
    state = state.copyWith();
  }

  Future<void> _demarrerParInternet({
    required String groupId,
    required String groupName,
    required List<String> memberPeerIds,
    required String Function(String peerId) pseudoFor,
  }) async {
    state = GroupCallState(
      isActive: true,
      groupId: groupId,
      groupName: groupName,
      participants: memberPeerIds.map((id) => GroupCallParticipant(peerId: id, pseudo: pseudoFor(id))).toList(),
    );
    CallRingerService.startOutgoing();
    _salon = false;
    // De quoi nommer quelqu'un qui entrerait par la porte du salon : la
    // salle est la même, on peut voir arriver une personne qu'on n'avait
    // pas invitée.
    _pseudoDe = pseudoFor;
    final service = AppelGroupeInternet(
      serverUrl: kSignalingUrl,
      surArrivee: (pair) => SalonsVocaux.entrer(groupId, pair),
      surDepart: (pair) => SalonsVocaux.sortir(groupId, pair),
    );
    _internet = service;
    _eventSub?.cancel();
    _eventSub = service.events.listen(_onEvent);
    try {
      await service.rejoindre(moi: _myId, groupId: groupId);
      await _repo?.envoyerInvitationAppelGroupe(
        groupId: groupId,
        participants: [_myId, ...memberPeerIds],
      );
    } catch (e) {
      debugPrint('[GroupCall] appel de groupe par Internet impossible: $e');
      CallRingerService.stop();
      if (identical(_internet, service)) _internet = null;
      unawaited(service.quitter().catchError((_) {}));
      state = const GroupCallState();
    }
  }

  /// ENTRER DANS LE SALON VOCAL D'UN GROUPE.
  ///
  /// C'est l'autre porte de la même pièce que [_demarrerParInternet] : la
  /// salle du serveur est la même (`salon_<groupId>`), le maillage audio est
  /// le même. Ce qui change, c'est qu'ICI ÇA NE SONNE CHEZ PERSONNE et qu'on
  /// n'attend personne en particulier — on entre, et qui veut nous rejoint.
  ///
  /// On commence donc avec une liste de participants VIDE : chaque personne
  /// y apparaît au moment où sa voix arrive, pas avant. C'est l'inverse d'un
  /// appel, qui affiche d'emblée ceux qu'on essaie de joindre.
  ///
  /// Lève une exception si le serveur est injoignable ou le salon complet :
  /// l'écran a besoin de pouvoir le dire au lieu de rester muet.
  Future<void> entrerDansSalon({
    required String groupId,
    required String groupName,
    required String Function(String peerId) pseudoFor,
    bool ouvrir = false,
  }) async {
    if (state.isActive) return;
    _salon = true;
    _pseudoDe = pseudoFor;
    state = GroupCallState(
      isActive: true,
      groupId: groupId,
      groupName: groupName,
      participants: const [],
    );
    final service = AppelGroupeInternet(
      serverUrl: kSignalingUrl,
      maximum: AppelGroupeInternet.maxSalon,
      // Quelqu'un entre : le bandeau des discussions le sait tout de
      // suite, sans attendre que la connexion audio aboutisse.
      surArrivee: (pair) => SalonsVocaux.entrer(groupId, pair),
      surDepart: (pair) => SalonsVocaux.sortir(groupId, pair),
      surSalonPlein: (plafond) {
        debugPrint('[Salon] complet ($plafond places)');
        salonComplet = plafond;
        hangUp();
      },
    );
    _internet = service;
    _eventSub?.cancel();
    _eventSub = service.events.listen(_onEvent);
    try {
      await service.rejoindre(moi: _myId, groupId: groupId);
      // ⚠️ ANNONCÉ SEULEMENT UNE FOIS DEDANS. Prévenir le groupe avant de
      // savoir si le serveur nous accepte ferait apparaître chez tout le
      // monde le bandeau d'un salon où personne n'est jamais entré.
      if (ouvrir) {
        SalonsVocaux.ouvrir(groupId: groupId, par: _myId);
      } else {
        SalonsVocaux.entrer(groupId, _myId);
      }
      unawaited(_repo?.annoncerSalonVocal(
            groupId: groupId,
            action: ouvrir ? 'ouvrir' : 'entrer',
          ) ??
          Future<void>.value());
    } catch (e) {
      debugPrint('[Salon] entrée impossible: $e');
      if (identical(_internet, service)) _internet = null;
      unawaited(service.quitter().catchError((_) {}));
      _salon = false;
      state = const GroupCallState();
      rethrow;
    }
  }

  /// Renseigné quand le serveur vient de refuser l'entrée : l'écran le lit
  /// une fois pour l'afficher, puis le remet à zéro.
  int? salonComplet;

  void _surInvitationInternet(({String groupId, String fromPeerId, List<String> participants}) invitation) {
    if (state.isActive || pendingInvite != null) return;
    _inviteGroupe = invitation.groupId;
    pendingInvite = (fromPeerId: invitation.fromPeerId, sdp: '', participants: invitation.participants);
    CallRingerService.startIncoming();
    state = state.copyWith();
  }

  Future<void> _accepterParInternet(String Function(String peerId) pseudoFor) async {
    final invitation = pendingInvite;
    final groupId = _inviteGroupe;
    pendingInvite = null;
    _inviteGroupe = null;
    CallRingerService.stop();
    if (invitation == null || groupId == null) return;
    final autres = invitation.participants.where((id) => id != _myId).toSet()..add(invitation.fromPeerId);
    state = GroupCallState(
      isActive: true,
      groupId: groupId,
      participants: autres.map((id) => GroupCallParticipant(peerId: id, pseudo: pseudoFor(id))).toList(),
    );
    _salon = false;
    _pseudoDe = pseudoFor;
    final service = AppelGroupeInternet(
      serverUrl: kSignalingUrl,
      surArrivee: (pair) => SalonsVocaux.entrer(groupId, pair),
      surDepart: (pair) => SalonsVocaux.sortir(groupId, pair),
    );
    _internet = service;
    _eventSub?.cancel();
    _eventSub = service.events.listen(_onEvent);
    try {
      await service.rejoindre(moi: _myId, groupId: groupId);
    } catch (e) {
      debugPrint('[GroupCall] impossible de rejoindre l\'appel de groupe: $e');
      if (identical(_internet, service)) _internet = null;
      state = const GroupCallState();
    }
  }

  void _onEvent(GroupCallEvent event) {
    // ⚠️ UN SALON N'A PAS DE LISTE D'INVITÉS. Dans un appel, on connaît
    // d'avance qui on essaie de joindre ; dans un salon, on découvre les
    // gens quand ils entrent. L'ancienne version se contentait de METTRE À
    // JOUR les participants déjà listés : une personne inconnue de la liste
    // se connectait, sa voix arrivait… et sa tuile n'apparaissait jamais.
    List<GroupCallParticipant> updateState(GroupCallParticipantState newState) {
      final connu = state.participants.any((p) => p.peerId == event.peerId);
      if (!connu) {
        return [
          ...state.participants,
          GroupCallParticipant(
            peerId: event.peerId,
            pseudo: _pseudoDe?.call(event.peerId) ?? event.peerId,
            state: newState,
          ),
        ];
      }
      return state.participants
          .map((p) => p.peerId == event.peerId ? p.copyWith(state: newState) : p)
          .toList();
    }

    if (event is GroupCallParticipantConnecting) {
      state = state.copyWith(participants: updateState(GroupCallParticipantState.connecting));
    } else if (event is GroupCallParticipantConnected) {
      CallRingerService.stop();
      state = state.copyWith(participants: updateState(GroupCallParticipantState.connected));
    } else if (event is GroupCallParticipantFailed) {
      state = state.copyWith(participants: updateState(GroupCallParticipantState.failed));
    } else if (event is GroupCallParticipantDisconnected) {
      final remaining = state.participants.where((p) => p.peerId != event.peerId).toList();
      // Dans un APPEL, se retrouver seul veut dire que l'autre a
      // raccroché. Dans un SALON, c'est l'état normal de celui qui vient
      // d'ouvrir la porte : on reste, et on attend.
      if (remaining.isEmpty && !_salon) {
        hangUp();
      } else {
        state = state.copyWith(participants: remaining);
      }
    }
  }

  void toggleMute() {
    _internet?.basculerMicro();
    _webrtc?.toggleMute();
    state = state.copyWith(isMuted: !state.isMuted);
  }

  Future<void> toggleSpeaker() async {
    if (_internet != null) {
      await _internet!.basculerHautParleur();
    } else {
      await _webrtc?.toggleSpeaker();
    }
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  Future<void> removeParticipant(String peerId) async {
    await _internet?.retirer(peerId);
    await _webrtc?.removeParticipant(peerId);
  }

  void hangUp() {
    CallRingerService.stop();
    // Sortir d'un salon se dit au groupe : sans ça, le bandeau des autres
    // continuait de nous compter parmi les présents.
    final salonQuitte = _salon ? state.groupId : null;
    _salon = false;
    _pseudoDe = null;
    if (salonQuitte != null) {
      SalonsVocaux.sortir(salonQuitte, _myId);
      unawaited(_repo?.annoncerSalonVocal(groupId: salonQuitte, action: 'sortir') ??
          Future<void>.value());
    }
    final internet = _internet;
    _internet = null;
    if (internet != null) {
      unawaited(internet.quitter().catchError((Object e) => debugPrint('[GroupCall] échec sortie: $e')));
    }
    if (_webrtc != null) {
      unawaited(_webrtc!.hangUpAll().catchError((e) => debugPrint('[GroupCall] échec hangUp: $e')));
    }
    _eventSub?.cancel();
    state = const GroupCallState();
  }

  @override
  void dispose() {
    CallRingerService.stop();
    _eventSub?.cancel();
    _incomingSub?.cancel();
    _inviteSub?.cancel();
    unawaited(_internet?.quitter());
    _webrtc?.dispose();
    _signaling?.dispose();
    super.dispose();
  }
}

// ── Pairs connectés ────────────────────────────────────────────────────────

/// La liste, toujours à jour, des appareils actuellement joignables sur
/// le mesh — utilisée pour afficher les petits points « en ligne » et
/// pour savoir qui on peut appeler.
final meshPeerListProvider = StateNotifierProvider<MeshPeerListNotifier, List<ConnectedPeer>>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return MeshPeerListNotifier(repo);
});

class MeshPeerListNotifier extends StateNotifier<List<ConnectedPeer>> {
  final MeshRepository _repo;
  StreamSubscription<ConnectedPeer>? _sub;

  MeshPeerListNotifier(this._repo) : super(_repo.peerList) {
    _sub = _repo.peerEvents?.listen((_) {
      state = _repo.peerList;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final connectedPeerCountProvider = Provider<int>((ref) {
  return ref.watch(meshPeerListProvider).length;
});

// ── Conversations 1:1 / groupe / diffusion (WhatsApp-like) ────────────────

enum ConversationKind { direct, group, broadcast }

/// Une ligne de la liste des conversations (écran d'accueil) — un
/// résumé : avec qui (ou quel groupe), le dernier message, quand, et
/// combien de messages non lus.
class Conversation {
  final String? peerId;
  final String? groupId;
  final ConversationKind kind;
  final String pseudo;
  final String lastMessage;
  final DateTime lastTimestamp;
  final int unreadCount;

  /// Une mention non lue m'attend dans cette discussion.
  final bool mentionne;

  final String? avatarUrl;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;

  /// Verrouillée derrière la biométrie — voir `chat_info_screen.dart`
  /// (`_toggleLock`) et `ConversationLockScreen`.
  ///
  /// ⚠️ CE CHAMP EXISTAIT DÉJÀ CÔTÉ STOCKAGE ET CÔTÉ ÉCRAN, MAIS PAS ICI.
  /// `StorageService.getLockedConversations()` était consulté pour gater
  /// l'OUVERTURE d'une conversation (biométrie avant d'accéder au fil),
  /// mais la conversation elle-même restait affichée normalement dans la
  /// liste principale — nom, aperçu du dernier message, tout visible.
  /// Quelqu'un qui regarde par-dessus l'épaule lisait le contenu sans
  /// jamais avoir besoin de déverrouiller quoi que ce soit : le
  /// verrouillage ne protégeait que la LECTURE DU FIL, pas la
  /// CONFIDENTIALITÉ DE SON EXISTENCE — ce que WhatsApp, lui, cache
  /// entièrement de la liste principale.
  final bool isLocked;

  /// Le dernier message lui-même — de quoi dessiner un aperçu riche
  /// (forme d'onde d'un vocal, vignette d'une photo) et les coches d'un
  /// message que j'ai envoyé.
  ///
  /// ⚠️ NUL POUR UNE CONVERSATION VERROUILLÉE. Son aperçu est déjà masqué
  /// (`ApercuSysteme.verrouille`) ; garder le message ici permettrait à
  /// n'importe quel écran d'en redessiner le contenu par mégarde.
  final MeshMessage? dernier;

  const Conversation({
    required this.peerId,
    this.groupId,
    required this.kind,
    required this.pseudo,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
    this.mentionne = false,
    this.avatarUrl,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isLocked = false,
    this.dernier,
  });

  bool get isBroadcast => kind == ConversationKind.broadcast;
  bool get isGroup => kind == ConversationKind.group;

  /// Clé de conversation stable, utilisée pour le watermark de lecture et
  /// le routage vers l'écran de chat.
  String get key => groupId ?? peerId ?? 'broadcast';
}

/// Horodatages de dernière lecture par conversation (watermark).
///
/// Persisté dans les settings pour rester cohérent entre redémarrages.
final conversationReadsProvider = StateNotifierProvider<ConversationReadsNotifier, Map<String, DateTime>>((ref) {
  return ConversationReadsNotifier();
});

class ConversationReadsNotifier extends StateNotifier<Map<String, DateTime>> {
  ConversationReadsNotifier() : super(_load());

  static Map<String, DateTime> _load() {
    final raw = StorageService.getString('conversation_reads');
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(
        k,
        DateTime.fromMillisecondsSinceEpoch((v as num).toInt()),
      ));
    } catch (_) {
      return {};
    }
  }

  void markRead(String peerId) {
    final now = DateTime.now();
    state = {...state, peerId: now};
    StorageService.setString(
      'conversation_reads',
      json.encode(state.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch))),
    );
  }

  @override
  void dispose() {
    StorageService.setString(
      'conversation_reads',
      json.encode(state.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch))),
    );
    super.dispose();
  }
}

/// Construit la liste des conversations à partir des messages stockés.
///
/// Trois catégories, mutuellement exclusives par message :
/// - `groupId` défini → conversation de groupe.
/// - `groupId` nul et `targetId`/`senderId` définit un correspondant →
///   conversation 1:1 (`senderId` message reçu, `targetId` message envoyé).
/// - ni l'un ni l'autre → diffusion mesh totale ("Diffusion mesh").
/// Compteur bumpé manuellement à l'archivage/désarchivage d'une conversation
/// — `StorageService.getArchivedConversations()` est un cache synchrone, pas
/// un state Riverpod, donc rien ne force [conversationsProvider] à se
/// recalculer sans ce signal explicite (même pattern que
/// `_groupsRevisionProvider` un peu plus bas).
final archivedRevisionProvider = StateProvider<int>((ref) => 0);

/// Signal de relecture quand une conversation est épinglée/désépinglée ou
/// mise en mode silencieux — même pattern que [archivedRevisionProvider].
final pinMuteRevisionProvider = StateProvider<int>((ref) => 0);

/// LE calcul principal derrière l'écran d'accueil : prend TOUS les
/// messages stockés et les range en « paquets » par correspondant ou par
/// groupe pour en faire une conversation, comme trier un tas de lettres
/// reçues et envoyées en une pile par destinataire.
final conversationsProvider = Provider<List<Conversation>>((ref) {
  ref.watch(archivedRevisionProvider);
  ref.watch(pinMuteRevisionProvider);
  final messages = ref.watch(meshMessagesProvider);
  final peers = ref.watch(meshPeerListProvider);
  final reads = ref.watch(conversationReadsProvider);
  final repo = ref.watch(meshRepositoryProvider);
  final myId = repo.myId;
  final archived = StorageService.getArchivedConversations();
  final pinned = StorageService.getPinnedConversations();
  final muted = StorageService.getMutedConversations();
  final locked = StorageService.getLockedConversations();
  NotificationService.setArchivedConversations(archived);

  final byPeer = <String, List<MeshMessage>>{};
  final byGroup = <String, List<MeshMessage>>{};
  final broadcast = <MeshMessage>[];

  for (final m in messages) {
    if (m.groupId != null) {
      byGroup.putIfAbsent(m.groupId!, () => []).add(m);
      continue;
    }
    final peerId = m.senderId == myId ? m.targetId : m.senderId;
    if (peerId == null) {
      broadcast.add(m);
    } else {
      byPeer.putIfAbsent(peerId, () => []).add(m);
    }
  }

  final conversations = <Conversation>[];

  for (final entry in byPeer.entries) {
    final list = entry.value
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    final lastRead = reads[entry.key];
    final unread = list.where((m) {
      // Les miens, jamais. Ceux d'un contact bloqué non plus : ils
      // n'apparaissent pas dans la discussion, donc ils ne peuvent pas
      // être « non lus ». Et un message déjà lu reste lu, même si
      // l'horodatage du dernier passage est plus ancien (cas des messages
      // arrivés pendant qu'on lisait).
      final expediteur = m.senderId;
      if (expediteur == null || expediteur == myId) return false;
      if (StorageService.isContactBlocked(expediteur)) return false;
      if (m.readAt != null) return false;
      return lastRead == null || m.timestamp.isAfter(lastRead);
    }).length;
    ConnectedPeer? peer;
    try {
      peer = peers.firstWhere((p) => p.peerId == entry.key);
    } catch (_) {}
    conversations.add(Conversation(
      peerId: entry.key,
      kind: ConversationKind.direct,
      // `last.authorPseudo` est l'auteur du DERNIER message du fil — si
      // c'est moi qui ai parlé en dernier, ce serait mon propre pseudo, pas
      // celui du correspondant. On résout explicitement le pseudo du pair
      // (`entry.key`), jamais celui du dernier message.
      //
      // Dernier repli : un message reçu de ce pair AVANT que son pseudo ne
      // soit connu (poignée de main pas encore faite, ou relais multi-hop)
      // est persisté avec `authorPseudo == senderId` — l'ID brut. Prendre le
      // premier message venu risquerait de retomber sur cet ID brut même si
      // un message *plus tardif* a bien le vrai pseudo. On cherche donc le
      // premier message dont l'auteur est réellement résolu.
      pseudo: peer?.pseudo ??
          StorageService.getPeerRecord(entry.key)?.pseudo ??
          list
              .where((m) => m.senderId == entry.key && m.authorPseudo != entry.key)
              .map((m) => m.authorPseudo)
              .firstOrNull ??
          entry.key,
      // Verrouillée : le dernier message ne s'affiche PAS, même dans les
      // écrans (comme la feuille des archives) qui gardent la conversation
      // visible avant ouverture. Cacher le contenu seulement APRÈS avoir
      // ouvert le fil serait cacher la porte, pas la pièce.
      lastMessage: locked.contains(entry.key)
          ? ApercuSysteme.verrouille
          : _describeForPreview(last),
      dernier: locked.contains(entry.key) ? null : last,
      lastTimestamp: last.timestamp,
      unreadCount: unread,
      isOnline: peer != null,
      isPinned: pinned.contains(entry.key),
      isMuted: muted.contains(entry.key),
      isLocked: locked.contains(entry.key),
    ));
  }

  for (final entry in byGroup.entries) {
    final list = entry.value
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    final lastRead = reads[entry.key];
    final unread = list.where((m) {
      // Les miens, jamais. Ceux d'un contact bloqué non plus : ils
      // n'apparaissent pas dans la discussion, donc ils ne peuvent pas
      // être « non lus ». Et un message déjà lu reste lu, même si
      // l'horodatage du dernier passage est plus ancien (cas des messages
      // arrivés pendant qu'on lisait).
      final expediteur = m.senderId;
      if (expediteur == null || expediteur == myId) return false;
      if (StorageService.isContactBlocked(expediteur)) return false;
      if (m.readAt != null) return false;
      return lastRead == null || m.timestamp.isAfter(lastRead);
    }).length;
    final group = StorageService.getGroup(entry.key);
    if (group == null || !group.isActiveMember(myId)) continue;
    // Une mention non lue passe devant un simple compte de messages.
    final monPseudo = StorageService.currentUser?.pseudo ?? '';
    final mentionne = unread > 0 &&
        list.any((m) =>
            m.senderId != myId &&
            (lastRead == null || m.timestamp.isAfter(lastRead)) &&
            Mentions.concerne(m.content, monPseudo));
    conversations.add(Conversation(
      peerId: null,
      groupId: entry.key,
      kind: ConversationKind.group,
      pseudo: group.name,
      avatarUrl: group.avatarUrl,
      mentionne: mentionne,
      // Dans un groupe, on dit toujours QUI parle : sans ça, l'aperçu
      // pourrait venir de n'importe lequel des vingt membres.
      lastMessage: locked.contains(entry.key)
          ? ApercuSysteme.verrouille
          : (last.senderId == myId || last.authorPseudo.trim().isEmpty
              ? _describeForPreview(last)
              : '~ ${last.authorPseudo}: ${_describeForPreview(last)}'),
      dernier: locked.contains(entry.key) ? null : last,
      lastTimestamp: last.timestamp,
      unreadCount: unread,
      isPinned: pinned.contains(entry.key),
      isMuted: muted.contains(entry.key),
      isLocked: locked.contains(entry.key),
    ));
  }

  // Un groupe créé ou rejoint existe TOUT DE SUITE, même si personne n'a
  // encore écrit. Avant, il fallait attendre le premier message pour le
  // voir apparaître : on créait un groupe et il n'était nulle part.
  final dejaLa = {for (final c in conversations) c.groupId};
  for (final group in StorageService.getGroups()) {
    if (dejaLa.contains(group.id) || !group.isActiveMember(myId)) continue;
    conversations.add(Conversation(
      peerId: null,
      groupId: group.id,
      kind: ConversationKind.group,
      pseudo: group.name,
      avatarUrl: group.avatarUrl,
      lastMessage: ApercuSysteme.groupeCree,
      lastTimestamp: group.createdAt,
      unreadCount: 0,
      isPinned: pinned.contains(group.id),
      isMuted: muted.contains(group.id),
    ));
  }

  if (broadcast.isNotEmpty) {
    broadcast.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = broadcast.first;
    conversations.add(Conversation(
      peerId: null,
      kind: ConversationKind.broadcast,
      pseudo: ApercuSysteme.diffusion,
      lastMessage: _describeForPreview(last),
      lastTimestamp: last.timestamp,
      unreadCount: 0,
    ));
  }

  // ⚠️ LES CONVERSATIONS VERROUILLÉES SONT RETIRÉES DE LA LISTE
  // PRINCIPALE, PAS SEULEMENT MASQUÉES DANS LEUR APERÇU.
  //
  // C'est le point qui manquait : garder la ligne visible (même avec
  // « Discussion verrouillée » à la place du message) révèle encore
  // AVEC QUI on discute, à quelle heure, et que la conversation existe.
  // WhatsApp cache la conversation ENTIÈREMENT de la liste — elle n'est
  // accessible que depuis un point d'entrée séparé, lui-même derrière
  // la biométrie (voir `_LockedChatsRow` / `_LockedChatsSheet`).
  conversations.removeWhere((c) => archived.contains(c.key) || c.isLocked);
  // Épinglés d'abord, puis par date décroissante.
  conversations.sort((a, b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    return b.lastTimestamp.compareTo(a.lastTimestamp);
  });
  return conversations;
});

/// Conversations archivées (mêmes calculs que [conversationsProvider], non
/// filtrées) — pour la feuille de désarchivage de `chats_screen.dart`.
final archivedConversationsProvider = Provider<List<Conversation>>((ref) {
  ref.watch(archivedRevisionProvider);
  final messages = ref.watch(meshMessagesProvider);
  final peers = ref.watch(meshPeerListProvider);
  final myId = ref.watch(meshRepositoryProvider).myId;
  final archived = StorageService.getArchivedConversations();
  if (archived.isEmpty) return const [];

  final byPeer = <String, List<MeshMessage>>{};
  final byGroup = <String, List<MeshMessage>>{};
  for (final m in messages) {
    if (m.groupId != null) {
      byGroup.putIfAbsent(m.groupId!, () => []).add(m);
      continue;
    }
    final peerId = m.senderId == myId ? m.targetId : m.senderId;
    if (peerId != null) byPeer.putIfAbsent(peerId, () => []).add(m);
  }

  final result = <Conversation>[];
  for (final entry in byPeer.entries) {
    if (!archived.contains(entry.key)) continue;
    final list = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    ConnectedPeer? peer;
    try {
      peer = peers.firstWhere((p) => p.peerId == entry.key);
    } catch (_) {}
    result.add(Conversation(
      peerId: entry.key,
      kind: ConversationKind.direct,
      pseudo: peer?.pseudo ?? StorageService.getPeerRecord(entry.key)?.pseudo ?? entry.key,
      lastMessage: _describeForPreview(last),
      lastTimestamp: last.timestamp,
      unreadCount: 0,
      isOnline: peer != null,
    ));
  }
  for (final entry in byGroup.entries) {
    if (!archived.contains(entry.key)) continue;
    final group = StorageService.getGroup(entry.key);
    if (group == null) continue;
    final list = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    result.add(Conversation(
      peerId: null,
      groupId: entry.key,
      kind: ConversationKind.group,
      pseudo: group.name,
      lastMessage: _describeForPreview(last),
      lastTimestamp: last.timestamp,
      unreadCount: 0,
    ));
  }
  result.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
  return result;
});

/// Conversations verrouillées (même calcul que [archivedConversationsProvider],
/// pour le même besoin : lister ce que la liste principale ne montre plus).
///
/// ⚠️ AUCUN MASQUAGE ICI. `conversationsProvider` remplace le dernier
/// message par « Discussion verrouillée » — c'est correct pour un écran
/// qu'on peut voir SANS s'être authentifié. Ce provider-ci n'est lu
/// qu'APRÈS la biométrie qui protège l'accès à cette liste elle-même
/// (voir `_LockedChatsSheet`) : à ce stade, cacher encore le contenu ne
/// protégerait rien de plus et rendrait la liste inutile.
final lockedConversationsProvider = Provider<List<Conversation>>((ref) {
  ref.watch(pinMuteRevisionProvider);
  final messages = ref.watch(meshMessagesProvider);
  final peers = ref.watch(meshPeerListProvider);
  final myId = ref.watch(meshRepositoryProvider).myId;
  final locked = StorageService.getLockedConversations();
  if (locked.isEmpty) return const [];

  final byPeer = <String, List<MeshMessage>>{};
  final byGroup = <String, List<MeshMessage>>{};
  for (final m in messages) {
    if (m.groupId != null) {
      byGroup.putIfAbsent(m.groupId!, () => []).add(m);
      continue;
    }
    final peerId = m.senderId == myId ? m.targetId : m.senderId;
    if (peerId != null) byPeer.putIfAbsent(peerId, () => []).add(m);
  }

  final result = <Conversation>[];
  for (final entry in byPeer.entries) {
    if (!locked.contains(entry.key)) continue;
    final list = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    ConnectedPeer? peer;
    try {
      peer = peers.firstWhere((p) => p.peerId == entry.key);
    } catch (_) {}
    result.add(Conversation(
      peerId: entry.key,
      kind: ConversationKind.direct,
      pseudo: peer?.pseudo ?? StorageService.getPeerRecord(entry.key)?.pseudo ?? entry.key,
      lastMessage: _describeForPreview(last),
      lastTimestamp: last.timestamp,
      unreadCount: 0,
      isOnline: peer != null,
      isLocked: true,
    ));
  }
  for (final entry in byGroup.entries) {
    if (!locked.contains(entry.key)) continue;
    final group = StorageService.getGroup(entry.key);
    if (group == null) continue;
    final list = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = list.first;
    result.add(Conversation(
      peerId: null,
      groupId: entry.key,
      kind: ConversationKind.group,
      pseudo: group.name,
      lastMessage: _describeForPreview(last),
      lastTimestamp: last.timestamp,
      unreadCount: 0,
      isLocked: true,
    ));
  }
  result.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
  return result;
});

/// Messages d'une conversation donnée (triés du plus ancien au plus récent).
final conversationMessagesProvider = Provider.family<List<MeshMessage>, String?>((ref, peerId) {
  final messages = ref.watch(meshMessagesProvider);
  final repo = ref.watch(meshRepositoryProvider);
  final myId = repo.myId;

  final filtered = messages.where((m) {
    if (m.groupId != null) return false;
    if (peerId == null) {
      // Canal diffusion : aucun ciblage.
      return m.targetId == null;
    }
    final other = m.senderId == myId ? m.targetId : m.senderId;
    return other == peerId;
  }).toList();
  filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return filtered;
});

/// Messages d'un groupe donné (triés du plus ancien au plus récent).
final groupMessagesProvider = Provider.family<List<MeshMessage>, String>((ref, groupId) {
  final messages = ref.watch(meshMessagesProvider);
  final filtered = messages.where((m) => m.groupId == groupId).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return filtered;
});

/// Groupe donné, réactif aux changements locaux (création/ajout/retrait).
final groupInfoProvider = Provider.family<GroupInfo?, String>((ref, groupId) {
  ref.watch(_groupsRevisionProvider);
  return StorageService.getGroup(groupId);
});

/// Groupes dont je suis membre actif, triés par nom.
final myGroupsProvider = Provider<List<GroupInfo>>((ref) {
  ref.watch(_groupsRevisionProvider);
  final myId = ref.watch(meshRepositoryProvider).myId;
  final groups = StorageService.getGroups().where((g) => g.isActiveMember(myId)).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return groups;
});

/// Compteur incrémenté à chaque `groupsChangedEvents` — sert uniquement à
/// invalider [groupInfoProvider]/[myGroupsProvider] (les groupes sont lus
/// depuis le cache synchrone de `StorageService`, pas depuis le state).
final _groupsRevisionProvider = StateNotifierProvider<_GroupsRevisionNotifier, int>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return _GroupsRevisionNotifier(repo);
});

class _GroupsRevisionNotifier extends StateNotifier<int> {
  final MeshRepository _repo;
  StreamSubscription<String>? _sub;

  _GroupsRevisionNotifier(this._repo) : super(0) {
    _sub = _repo.groupsChangedEvents.listen((_) => state++);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Pseudo d'un pair donné (depuis la liste connectée ou l'historique).
final peerPseudoProvider = Provider.family<String, String>((ref, peerId) {
  // ⚠️ CE PROVIDER NE RENVOIE PLUS JAMAIS L'IDENTIFIANT BRUT.
  //
  // Il terminait par `return resolved ?? peerId` : une empreinte de
  // soixante-quatre caractères hexadécimaux, affichée à la place d'un
  // nom dans le journal d'appels, la liste des pairs et les groupes.
  // C'est ce que voyait tout utilisateur ayant reçu un message par
  // relais d'un appareil jamais croisé — un cas fréquent, pas marginal.
  //
  // Et la fiche enregistrée n'était pas contrôlée : d'anciennes
  // versions y écrivaient l'identifiant en guise de pseudonyme, si bien
  // qu'un `known != null` renvoyait joyeusement l'empreinte.
  //
  // `nomDuPair` applique la même règle qu'ailleurs : un vrai nom, ou
  // « Pair 3f7a1c92 ». Voir `nom_pair.dart`.
  final vivant = ref
      .watch(meshPeerListProvider)
      .where((p) => p.peerId == peerId)
      .map((p) => p.pseudo)
      .firstOrNull;

  // Un message reçu porte le nom de son auteur — sauf s'il est arrivé
  // avant que le pseudonyme ne soit connu, auquel cas il porte
  // l'identifiant. `nomDuPair` écarte ce cas de lui-même.
  final parMessage = ref
      .watch(meshMessagesProvider)
      .where((m) => m.senderId == peerId)
      .map((m) => m.authorPseudo)
      .firstOrNull;

  return nomDuPair(peerId, [
    vivant,
    StorageService.getPeerRecord(peerId)?.pseudo,
    parMessage,
  ]);
});

// ── Indicateur de frappe ──────────────────────────────────────────────────

/// IDs des pairs qui tapent actuellement (auto-nettoyé après 3 s) — le
/// petit « ... » animé qu'on voit apparaître pendant que l'autre écrit.
/// Qui écrit, groupe par groupe (auto-nettoyé après 3 s).
final groupTypingProvider =
    StateNotifierProvider<GroupTypingNotifier, Map<String, Set<String>>>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return GroupTypingNotifier(repo.frappeGroupeEvents);
});

class GroupTypingNotifier extends StateNotifier<Map<String, Set<String>>> {
  GroupTypingNotifier(Stream<({String groupId, String peerId})> evenements) : super(const {}) {
    _abonnement = evenements.listen(_surFrappe);
  }

  StreamSubscription<({String groupId, String peerId})>? _abonnement;
  final Map<String, Timer> _minuteurs = {};

  void _surFrappe(({String groupId, String peerId}) e) {
    final cle = '${e.groupId}|${e.peerId}';
    _minuteurs[cle]?.cancel();
    state = {...state, e.groupId: {...?state[e.groupId], e.peerId}};
    _minuteurs[cle] = Timer(const Duration(seconds: 3), () {
      _minuteurs.remove(cle);
      if (!mounted) return;
      state = {...state, e.groupId: {...?state[e.groupId]}..remove(e.peerId)};
    });
  }

  @override
  void dispose() {
    for (final t in _minuteurs.values) {
      t.cancel();
    }
    _abonnement?.cancel();
    super.dispose();
  }
}

final typingPeersProvider = StateNotifierProvider<TypingNotifier, Set<String>>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return TypingNotifier(repo.typingEvents);
});

class TypingNotifier extends StateNotifier<Set<String>> {
  TypingNotifier(Stream<String> events) : super(<String>{}) {
    _sub = events.listen(_onTyping);
  }

  StreamSubscription<String>? _sub;
  final Map<String, Timer> _timers = {};

  void _onTyping(String peerId) {
    _timers[peerId]?.cancel();
    state = {...state, peerId};
    _timers[peerId] = Timer(const Duration(seconds: 3), () {
      state = {...state}..remove(peerId);
      _timers.remove(peerId);
    });
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _sub?.cancel();
    super.dispose();
  }
}
