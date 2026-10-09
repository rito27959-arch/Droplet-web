// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Transport Tor pour Droplet.
//
// Utilise le proxy SOCKS5 local (géré par TorService) pour connecter
// des pairs via le réseau Tor. Chaque appareil peut fonctionner comme
// un hidden service (.onion).
//
// Intègre aussi les clients directory et mailbox pour :
// - S'enregistrer dans l'annuaire .onion au démarrage
// - Chercher des contacts par pseudo
// - Stocker/récupérer des messages dans la mailbox .onion
//
// Ne remplace PAS les transports mesh — les complète pour contacts distants.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tor/socks_socket.dart';

import 'ble_mesh_protocol.dart';
import 'mesh_transport.dart';
import 'tor_service.dart';
import 'tor_http_client.dart';
import 'package:http/http.dart' as http;

import 'crypto_service.dart';
import 'onion_service.dart';
import 'qr_code_exchange.dart';
import 'directory_client.dart';
import 'mailbox_client.dart';
import 'push_notification_service.dart';
import 'storage_service.dart';
import '../models/mesh_message.dart';

/// Transport Tor pour Droplet.
class TorTransport implements MeshTransport {
  final TorService _torService;

  bool _isRunning = false;
  String _myId = '';
  String _myPseudo = '';
  OnionIdentity? _myIdentity;

  /// Pairs connectés : peerId → onion address.
  final Map<String, String> _peerOnionAddresses = {};

  final Map<String, _TorPeerConnection> _connections = {};

  /// Client directory .onion — pour chercher/être trouvé par pseudo.
  DirectoryClient? _directoryClient;

  /// Client mailbox .onion — pour stocker/récupérer des messages async.
  MailboxClient? _mailboxClient;

  /// URL du serveur directory (à configurer avant start).
  String? directoryUrl;

  /// URL du serveur mailbox (à configurer avant start).
  String? mailboxUrl;

  /// Contacts trouvés dans l'annuaire (cache mémoire).
  final List<DirectoryContact> _directoryCache = [];

  final _peerEventsCtrl = StreamController<MeshPeerEvent>.broadcast();
  final _incomingDataCtrl = StreamController<MeshIncomingData>.broadcast();
  final _metrics = TransportMetrics();

  @override
  String get name => 'tor';

  @override
  bool get isRunning => _isRunning;

  @override
  TransportState get state {
    if (!_isRunning) return TransportState.stopped;
    if (!_torService.isConnected) return TransportState.unavailable;
    if (_connections.isEmpty) return TransportState.searching;
    return TransportState.active;
  }

  @override
  TransportCapabilities get capabilities => const TransportCapabilities(
        maxPayloadBytes: 65536,
        maxContentType: 0xFF,
        portePhotosEtFichiers: true,
        porteVoixEnDirect: false,
        coutEnergetique: 0.6,
      );

  @override
  TransportMetrics get metrics => _metrics;

  @override
  Stream<MeshPeerEvent> get peerEvents => _peerEventsCtrl.stream;

  @override
  Stream<MeshIncomingData> get incomingData => _incomingDataCtrl.stream;

  /// Contacts trouvés dans l'annuaire (dernière recherche).
  List<DirectoryContact> get directoryCache => List.unmodifiable(_directoryCache);

  /// Vrai si le client directory est initialisé et prêt.
  bool get isDirectoryReady => _directoryClient != null;

  /// Vrai si le client mailbox est initialisé et prêt.
  bool get isMailboxReady => _mailboxClient != null;

  /// Abonnement à l'état RÉEL de Tor — voir la note dans [start].
  StreamSubscription<TorServiceState>? _torStateSub;

  /// Vrai une fois l'inscription à l'annuaire réussie — évite de la
  /// répéter à chaque fois que [_onTorStateChanged] revoit `connected`.
  bool _registeredInDirectory = false;

  TorTransport(this._torService);

  @override
  Future<void> start(String myId, String myPseudo) async {
    if (_isRunning) return;
    _myId = myId;
    _myPseudo = myPseudo;
    _isRunning = true;

    // Charger l'identité Tor.
    //
    // ⚠️ SANS ATTENDRE QUE TOR SOIT ACTIVÉ. `_torService.identity` n'est
    // renseignée que par `TorService.start()` — c'est-à-dire seulement si
    // l'utilisateur allume Tor. Or `_registerInDirectory()` exige une
    // identité : sans elle, un appareil qui n'active jamais Tor ne
    // s'inscrivait jamais dans l'annuaire, donc restait introuvable par
    // pseudo et non réveillable par push — alors même que l'annuaire se
    // joint désormais en liaison directe. L'identité est une paire de clés
    // lue ou générée LOCALEMENT : aucun réseau, aucune raison d'attendre Tor.
    _myIdentity = _torService.identity;
    if (_myIdentity == null) {
      try {
        // 6 s, pas plus : `MeshTransportService._startTransport` coupe
        // `start()` à 8 s et programmerait une reprise inutile.
        _myIdentity = await OnionService.ensureIdentity()
            .timeout(const Duration(seconds: 6));
      } catch (e) {
        debugPrint('[TorTransport] Identité locale indisponible: $e');
      }
    }
    if (_myIdentity != null) {
      debugPrint('[TorTransport] Démarré — .onion: ${_myIdentity!.shortOnion}');
    } else {
      debugPrint('[TorTransport] Démarré — pas encore d\'identité .onion');
    }

    // Restaurer les adresses onion des pairs connus depuis le storage.
    _loadKnownPeerOnionAddresses();

    // Tentative immédiate — utile si Tor était déjà connecté avant cet
    // appel (l'utilisateur l'avait déjà activé plus tôt dans la session).
    _initHttpClients();
    _registerInDirectory();
    // L'annuaire garde les inscriptions en mémoire : un redéploiement les
    // efface. Sans réinscription régulière, l'appareil restait introuvable
    // (et non réveillable par notification) jusqu'au prochain lancement.
    _reinscription?.cancel();
    _reinscription = Timer.periodic(const Duration(minutes: 10), (_) {
      if (!_isRunning) return;
      if (_directoryClient == null) _initHttpClients();
      _registerInDirectory();
    });

    // ⚠️ LE VRAI DÉCLENCHEUR — ET POURQUOI LES DEUX LIGNES CI-DESSUS NE
    // SUFFISENT PRESQUE JAMAIS SEULES DANS LA VRAIE VIE.
    //
    // `start()` tourne au lancement de l'app, en même temps que tout le
    // reste du maillage. Tor, lui, ne démarre que lorsque la personne
    // l'active EXPLICITEMENT depuis les réglages — un geste qui arrive
    // presque toujours plus tard, jamais avant. `_torService.proxyPort`
    // vaut donc -1 au moment de cet appel dans la quasi-totalité des
    // lancements réels, `_initHttpClients` renonce aussitôt (« Tor non
    // prêt, clients HTTP retardés »), et rien ne revenait jamais
    // réessayer ensuite.
    //
    // Conséquence concrète : personne n'était jamais inscrit dans
    // l'annuaire, et « rechercher un pseudo » ne pouvait renvoyer
    // qu'une liste vide — silencieusement, pour toujours, quel que soit
    // le nombre de fois où Tor était activé depuis les réglages.
    //
    // On s'abonne donc au flux d'état RÉEL de Tor ([TorService.stateStream],
    // qui n'émet `connected` qu'une fois le circuit effectivement établi
    // — voir `TorService.start`), et on referait le travail (identité,
    // clients HTTP, inscription) exactement au bon moment, quel que soit
    // l'écran depuis lequel Tor a été activé.
    _torStateSub?.cancel();
    _torStateSub = _torService.stateStream.listen(_onTorStateChanged);

    // ⚠️ LE JETON PUSH ARRIVE MAINTENANT APRÈS COUP — IL FAUT L'ATTRAPER.
    //
    // Il était auparavant obtenu avant `runApp()`, donc toujours présent
    // au moment de s'inscrire ici. Depuis qu'il ne bloque plus le
    // démarrage (voir `PushNotificationService.init`), il peut très bien
    // arriver APRÈS cette inscription — et sur un premier lancement hors
    // ligne, il arrive forcément après. Sans ce rappel, l'annuaire
    // gardait `fcmToken: null` pour toute la session : l'appareil restait
    // joignable par sondage de la mailbox, mais plus jamais réveillable
    // par push, en silence. `onTokenChanged` n'avait jusqu'ici AUCUN
    // consommateur — c'était un fil laissé pendant.
    PushNotificationService.onTokenChanged = (_) {
      if (!_isRunning) return;
      debugPrint('[TorTransport] Jeton push arrivé — réinscription annuaire');
      _registerInDirectory();
    };
  }

  /// Réagit au moment où Tor devient réellement prêt — voir la note dans
  /// [start].
  ///
  /// ⚠️ RÉAGIT AUSSI À LA PERTE DU CIRCUIT. `TorService` surveille
  /// désormais la santé du proxy et repasse en `error` quand il tombe
  /// (veille prolongée, changement de réseau). Sans le cas ci-dessous,
  /// `_registeredInDirectory` restait à `true` pour le reste de la
  /// session : à la reconnexion, l'appareil ne se réinscrivait pas dans
  /// l'annuaire et redevenait introuvable par pseudo, en silence.
  void _onTorStateChanged(TorServiceState state) {
    if (state != TorServiceState.connected) {
      if (_registeredInDirectory) {
        debugPrint('[TorTransport] Tor perdu — inscription annuaire à refaire');
      }
      _registeredInDirectory = false;
      // ⚠️ ON REBASCULE EN LIAISON DIRECTE plutôt que de rester sans
      // clients. Perdre Tor ne doit pas couper la messagerie en ligne :
      // le proxy SOCKS vient de disparaître, donc les clients qui le
      // visaient sont morts et il faut les refaire.
      _initHttpClients();
      if (_directoryClient != null) _registerInDirectory();
      return;
    }
    // L'identité peut, elle aussi, ne pas avoir existé encore au moment
    // de `start()` (elle est générée pendant `TorService.start()`).
    _myIdentity ??= _torService.identity;
    _initHttpClients();
    if (!_registeredInDirectory) {
      _registerInDirectory();
    }
  }

  /// Restaure les adresses .onion des pairs connus depuis PeerRecord.
  void _loadKnownPeerOnionAddresses() {
    final knownPeers = StorageService.getKnownPeers();
    var loaded = 0;
    for (final peer in knownPeers) {
      if (peer.onionAddress != null && peer.onionAddress!.isNotEmpty) {
        _peerOnionAddresses[peer.peerId] = peer.onionAddress!;
        loaded++;
      }
    }
    if (loaded > 0) {
      debugPrint('[TorTransport] $loaded adresse(s) onion restaurée(s) depuis le storage');
    }
  }

  /// Initialise les clients HTTP directory et mailbox via le proxy SOCKS5.
  /// Le client HTTP en service, gardé pour être fermé proprement quand on
  /// bascule entre Tor et liaison directe.
  http.Client? _httpCourant;
  Timer? _reinscription;

  /// Vrai si l'annuaire et la mailbox passent actuellement par Tor.
  bool get passeParTor => _viaTor;
  bool _viaTor = false;

  /// Clé de réglage : refuser la liaison directe si Tor n'est pas
  /// disponible. Voir [_initHttpClients].
  static const cleExigerTor = 'reseau_exiger_tor';

  /// L'utilisateur exige-t-il Tor pour les services en ligne ?
  /// Faux par défaut : sinon une panne de Tor coupe toute la messagerie
  /// en ligne, ce qui est bien pire que d'exposer une adresse IP à un
  /// serveur qui ne voit de toute façon que du chiffré.
  static bool get exigerTor =>
      StorageService.getString(cleExigerTor) == 'on';

  static Future<void> definirExigerTor(bool on) =>
      StorageService.setString(cleExigerTor, on ? 'on' : 'off');

  /// Prépare les clients annuaire et mailbox.
  ///
  /// ⚠️ CETTE MÉTHODE ABANDONNAIT DÈS QUE TOR N'ÉTAIT PAS PRÊT — ET ELLE
  /// EMPORTAIT TOUTE LA MESSAGERIE EN LIGNE AVEC ELLE.
  ///
  /// Sans Tor : pas de client annuaire (donc introuvable par pseudo, et
  /// aucun jeton push transmis), pas de client mailbox (donc aucun message
  /// envoyé ni reçu quand le destinataire est hors de portée). Autrement
  /// dit, une capacité qui n'a besoin que d'HTTPS était suspendue à une
  /// autre qui, elle, échouait.
  ///
  /// ⚠️ ET C'ÉTAIT D'AUTANT PLUS COÛTEUX QUE LE PAIR-À-PAIR TOR NE PEUT
  /// PAS FONCTIONNER. Le paquet `tor` embarqué (0.1.1) expose un client
  /// SOCKS5 et rien d'autre : aucune API de service caché. Droplet ne
  /// publie donc JAMAIS de hidden service, et l'adresse `.onion` dérivée
  /// dans `onion_service.dart` ne pointe sur rien — `connectToPeer()` ne
  /// peut aboutir dans aucun cas. Le seul chemin en ligne réellement
  /// praticable est celui-ci : annuaire + mailbox en HTTPS.
  ///
  /// ⚠️ LE REPLI EST UN CHOIX DE CONFIDENTIALITÉ, PAS UN DÉTAIL. Passer
  /// par Tor masque l'adresse IP aux serveurs ; en liaison directe, ils la
  /// voient (le CONTENU reste chiffré de bout en bout dans les deux cas).
  /// Le repli est donc le défaut — pour que la messagerie marche — mais il
  /// reste refusable via [exigerTor], et [passeParTor] permet de
  /// l'afficher honnêtement.
  void _initHttpClients() {
    final portTor = _torService.proxyPort;
    final torDispo = portTor > 0 && _torService.isConnected;

    if (!torDispo && exigerTor) {
      debugPrint('[TorTransport] Tor exigé mais indisponible — '
          'clients en ligne non initialisés');
      _fermerClients();
      return;
    }

    // Rien à changer si le mode en cours est déjà le bon.
    if (_httpCourant != null &&
        _viaTor == torDispo &&
        (directoryUrl == null || _directoryClient != null) &&
        (mailboxUrl == null || _mailboxClient != null)) {
      return;
    }

    _fermerClients();
    _viaTor = torDispo;
    _httpCourant = torDispo
        ? TorHttpClient(
            host: InternetAddress.loopbackIPv4.address,
            port: portTor,
          )
        : http.Client();

    if (directoryUrl != null) {
      _directoryClient = DirectoryClient(
        serverUrl: directoryUrl!,
        httpClient: _httpCourant,
      );
    }
    if (mailboxUrl != null) {
      _mailboxClient = MailboxClient(
        serverUrl: mailboxUrl!,
        httpClient: _httpCourant,
      );
    }
    debugPrint('[TorTransport] Clients en ligne prêts — '
        '${torDispo ? "via Tor" : "liaison directe"}');
  }

  void _fermerClients() {
    try {
      _httpCourant?.close();
    } catch (_) {}
    _httpCourant = null;
    _directoryClient = null;
    _mailboxClient = null;
    _viaTor = false;
  }

  /// S'enregistre dans l'annuaire .onion avec notre identité.
  Future<void> _registerInDirectory() async {
    if (_directoryClient == null || _myIdentity == null) return;

    // ⚠️ LA CLÉ PUBLIÉE EST LA CLÉ X25519 DE L'APPAREIL, PAS LA CLÉ ONION.
    //
    // On publiait `_myIdentity!.publicKeyBase64` : la clé Ed25519 de
    // l'identité Tor. Or tout contact trouvé dans l'annuaire est enregistré
    // avec cette clé (`discover_screen._sendMessageTo`), puis
    // `CryptoService.sharedKeyWithPeer` la lit comme une clé X25519 pour
    // chiffrer. Les deux font 32 octets : aucune erreur n'est levée, mais
    // l'émetteur et le destinataire dérivent des secrets DIFFÉRENTS. Chaque
    // message en ligne vers un contact trouvé par pseudo arrivait donc
    // indéchiffrable, en silence. `PeerRecord.publicKey` porte partout
    // ailleurs la clé X25519 (c'est ce qu'annoncent les pairs mesh) : c'est
    // celle-là que l'annuaire doit servir. L'adresse onion reste celle de
    // l'identité Tor.
    final String cleX25519;
    try {
      cleX25519 = await CryptoService.ensureIdentityKeyPair()
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[TorTransport] Clé X25519 indisponible — inscription reportée: $e');
      return;
    }

    final success = await _directoryClient!.register(
      peerId: _myId,
      pseudo: _myPseudo,
      onionAddress: _myIdentity!.onionAddress,
      publicKey: cleX25519,
      fcmToken: PushNotificationService.currentToken,
    );

    if (success) {
      _registeredInDirectory = true;
      debugPrint('[TorTransport] Enregistré dans l\'annuaire');
    } else {
      debugPrint('[TorTransport] Échec enregistrement annuaire');
    }
  }

  // ── Méthodes publiques pour l'intégration avec l'app ──────────────

  /// Cherche des contacts par pseudo dans l'annuaire .onion.
  Future<List<DirectoryContact>> searchDirectory(String query) async {
    if (_directoryClient == null && _isRunning) _initHttpClients();
    if (_directoryClient == null) {
      debugPrint('[TorTransport] Client directory non disponible');
      return [];
    }

    final results = await _directoryClient!.search(query);
    _directoryCache.clear();
    _directoryCache.addAll(results);
    return results;
  }

  /// Signale un contact à l'annuaire — voir la doc de
  /// [DirectoryClient.report] pour ce qui part vraiment (un identifiant
  /// technique + un motif choisi dans une liste fermée, jamais un
  /// message).
  Future<bool> reportContact(String peerId, String reason) async {
    if (_directoryClient == null) {
      debugPrint('[TorTransport] Client directory non disponible');
      return false;
    }
    return _directoryClient!.report(peerId: peerId, reason: reason);
  }

  /// Dépose un message chiffré dans la mailbox d'un contact distant.
  Future<String?> storeMailboxMessage({
    required String toPeerId,
    required String encryptedPayload,
  }) async {
    if (_mailboxClient == null && _isRunning) _initHttpClients();
    if (_mailboxClient == null) {
      debugPrint('[TorTransport] Client mailbox non disponible '
          '(adresse=${mailboxUrl != null}, exigerTor=$exigerTor, '
          'tor=${_torService.isConnected}, actif=$_isRunning)');
      return null;
    }

    return _mailboxClient!.store(
      fromPeerId: _myId,
      toPeerId: toPeerId,
      encryptedPayload: encryptedPayload,
    );
  }

  /// Récupère tous les messages en attente dans notre mailbox.
  Future<List<MailboxMessage>> fetchMailboxMessages() async {
    if (_mailboxClient == null && _isRunning) _initHttpClients();
    if (_mailboxClient == null) {
      debugPrint('[TorTransport] Client mailbox non disponible '
          '(adresse=${mailboxUrl != null}, exigerTor=$exigerTor, '
          'tor=${_torService.isConnected}, actif=$_isRunning)');
      return [];
    }

    return _mailboxClient!.fetchAll(_myId);
  }

  /// Supprime un message après l'avoir traité.
  Future<bool> acknowledgeMailboxMessage(String messageId) async {
    if (_mailboxClient == null && _isRunning) _initHttpClients();
    if (_mailboxClient == null) return false;
    return _mailboxClient!.acknowledge(_myId, messageId);
  }

  @override
  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;
    _torStateSub?.cancel();
    _torStateSub = null;
    _registeredInDirectory = false;

    // Se désinscrire de l'annuaire.
    await _unregisterFromDirectory();

    for (final conn in _connections.values) {
      await conn.close();
    }
    _connections.clear();
    _peerOnionAddresses.clear();

    _reinscription?.cancel();
    _reinscription = null;
    // ⚠️ `_fermerClients`, PAS SEULEMENT `_mailboxClient = null`. L'ancien
    // arrêt effaçait les clients mais gardait `_httpCourant` : au redémarrage,
    // `_initHttpClients` concluait « rien à changer » et ne les recréait
    // JAMAIS. Constaté sur Pixel 6 Pro : « Client mailbox non disponible »
    // toutes les 4 secondes, aucun message relevé ni envoyé en ligne.
    _fermerClients();

    debugPrint('[TorTransport] Arrêté');
  }

  /// Se désinscrit de l'annuaire avant l'arrêt.
  Future<void> _unregisterFromDirectory() async {
    if (_directoryClient == null) return;
    try {
      await _directoryClient!.unregister(_myId);
      debugPrint('[TorTransport] Désinscrit de l\'annuaire');
    } catch (e) {
      debugPrint('[TorTransport] Erreur désinscription: $e');
    }
  }

  /// Enregistre un pair scopé via QR code.
  void registerQrPeer(QrPeerData peerData) {
    _peerOnionAddresses[peerData.peerId] = peerData.onionAddress;
    debugPrint('[TorTransport] Peer QR enregistré: ${peerData.pseudo} '
        '(${peerData.onionAddress.substring(0, 12)}…)');

    // Persister l'adresse onion dans PeerRecord (survivre au redémarrage).
    StorageService.upsertPeer(PeerRecord(
      peerId: peerData.peerId,
      pseudo: peerData.pseudo,
      role: 'leaf',
      transports: ['tor'],
      platform: 'unknown',
      interestGroups: [],
      reliability: 1.0,
      lastSeen: DateTime.now(),
      totalMessagesExchanged: 0,
      publicKey: peerData.publicKey,
      onionAddress: peerData.onionAddress,
      verified: false,
    ));

    // Notifier la découverte.
    _metrics.pairsDecouverts++;
    _peerEventsCtrl.add(MeshPeerEvent(
      peerId: peerData.peerId,
      pseudo: peerData.pseudo,
      isConnected: false,
    ));
  }

  /// Connecte à un pair via son adresse onion.
  Future<bool> connectToPeer(String peerId, {int port = 8080}) async {
    if (!_isRunning || !_torService.isConnected) return false;
    if (_connections.containsKey(peerId)) return true;

    final onionAddress = _peerOnionAddresses[peerId];
    if (onionAddress == null) {
      debugPrint('[TorTransport] Pas d\'adresse onion pour $peerId');
      return false;
    }

    // Valider le format de l'adresse .onion avant de tenter la connexion.
    if (!OnionService.isValidOnionAddress(onionAddress)) {
      debugPrint('[TorTransport] Adresse onion invalide pour $peerId: '
          '${onionAddress.length} chars (attendu 56)');
      return false;
    }

    try {
      debugPrint('[TorTransport] Connexion à $peerId via $onionAddress:$port');

      final socks = await SOCKSSocket.create(
        proxyHost: InternetAddress.loopbackIPv4.address,
        proxyPort: _torService.proxyPort,
      );
      await socks.connect();
      await socks.connectTo(onionAddress, port);

      // Envoyer hello avec notre identité.
      final hello = jsonEncode({
        'type': 'hello',
        'id': _myId,
        'pseudo': _myPseudo,
        'onion': _myIdentity?.onionAddress,
      });
      socks.write(hello);

      // Créer la connexion persistante.
      _createPeerConnection(peerId, socks);

      _metrics.pairsConnectes++;

      _peerEventsCtrl.add(MeshPeerEvent(
        peerId: peerId,
        pseudo: '',
        isConnected: true,
      ));

      debugPrint('[TorTransport] Connecté à $peerId');
      return true;
    } catch (e) {
      debugPrint('[TorTransport] Échec connexion vers $peerId: $e');
      _metrics.echecsConnexion++;
      return false;
    }
  }

  @override
  Future<bool> sendToPeer(String peerId, Uint8List data,
      {int type = 0x01, int priority = 0}) async {
    final conn = _connections[peerId];
    if (conn == null) {
      _metrics.echecsEnvoi++;
      return false;
    }

    try {
      // Header DRLP + version + type
      final header = Uint8List.fromList([0x44, 0x52, 0x4C, 0x50, 1, type & 0xFF]);
      final lengthBytes = ByteData(4)..setUint32(0, data.length, Endian.big);

      conn.socks.write(header);
      conn.socks.write(lengthBytes.buffer.asUint8List());
      conn.socks.write(data);

      _metrics.paquetsEnvoyes++;
      _metrics.octetsEnvoyes += data.length;
      return true;
    } catch (e) {
      debugPrint('[TorTransport] Erreur envoi vers $peerId: $e');
      _metrics.echecsEnvoi++;
      return false;
    }
  }

  void _createPeerConnection(String peerId, SOCKSSocket socks) {
    final conn = _TorPeerConnection(peerId: peerId, socks: socks);
    _connections[peerId] = conn;

    socks.listen(
      (data) {
        _metrics.paquetsRecus++;
        _metrics.octetsRecus += data.length;
        _incomingDataCtrl.add(MeshIncomingData(
          messageId: '${peerId}_${DateTime.now().millisecondsSinceEpoch}',
          peerId: peerId,
          data: Uint8List.fromList(data),
        ));
      },
      onError: (e) {
        debugPrint('[TorTransport] Erreur socket $peerId: $e');
        _removePeer(peerId);
      },
      onDone: () {
        _removePeer(peerId);
      },
    );
  }

  void _removePeer(String peerId) {
    if (_connections.remove(peerId) != null) {
      _metrics.pairsConnectes--;
      _peerEventsCtrl.add(MeshPeerEvent(
        peerId: peerId,
        pseudo: '',
        isConnected: false,
      ));
    }
  }

  @override
  void dispose() {
    stop();
    _peerEventsCtrl.close();
    _incomingDataCtrl.close();
  }
}

class _TorPeerConnection {
  final String peerId;
  final SOCKSSocket socks;

  _TorPeerConnection({required this.peerId, required this.socks});

  Future<void> close() async {
    try {
      await socks.close();
    } catch (_) {}
  }
}
