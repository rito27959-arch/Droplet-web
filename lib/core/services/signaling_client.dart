// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Client WebSocket pour le signaling WebRTC.
//
// Se connecte au DropletServer (Railway) pour relayer les offres SDP,
// réponses et candidats ICE pendant les appels audio/vidéo.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'appel_outils.dart';
import 'etat_internet.dart';
import 'package:web_socket_channel/io.dart';

/// Événement de signaling reçu du serveur.
sealed class SignalingEvent {
  const SignalingEvent();
}

class PeerJoinedEvent extends SignalingEvent {
  const PeerJoinedEvent(this.peerId);
  final String peerId;
}

class PeerLeftEvent extends SignalingEvent {
  const PeerLeftEvent(this.peerId);
  final String peerId;
}

/// Quelqu'un vient d'ENTRER dans la salle, après moi.
///
/// ⚠️ À NE PAS CONFONDRE AVEC [PeerJoinedEvent], et surtout à ne pas
/// traiter comme lui. `PeerJoinedEvent` dit « cette personne était DÉJÀ là
/// quand je suis arrivé » : c'est ce qui déclenche mon offre vers elle.
/// La règle qui évite deux offres croisées sans aucune coordination, c'est
/// que L'ARRIVANT APPELLE LES PRÉSENTS. Si on ouvrait aussi une connexion
/// sur cet événement-ci, les deux côtés s'appelleraient en même temps et
/// la mise en relation échouerait. Il ne sert donc qu'à tenir la liste des
/// présents à jour à l'écran.
class PairEntreEvent extends SignalingEvent {
  const PairEntreEvent(this.peerId);
  final String peerId;
}

/// Le salon est plein : le serveur a refusé l'entrée.
///
/// Sans cet événement, on restait dans un salon qu'on n'avait pas rejoint,
/// à attendre un son qui n'arriverait jamais.
class SalonPleinEvent extends SignalingEvent {
  const SalonPleinEvent(this.maximum);
  final int maximum;
}

class OfferEvent extends SignalingEvent {
  const OfferEvent(this.fromPeerId, this.sdp, {this.video = false});
  final String fromPeerId;
  final String sdp;

  /// L'appelant propose un appel VIDÉO (sinon : vocal).
  final bool video;
}

class AnswerEvent extends SignalingEvent {
  const AnswerEvent(this.fromPeerId, this.sdp);
  final String fromPeerId;
  final String sdp;
}

class IceCandidateEvent extends SignalingEvent {
  const IceCandidateEvent(this.fromPeerId, this.candidat);
  final String fromPeerId;

  /// Candidat COMPLET (`sdpMid`, `sdpMLineIndex`) — voir `CandidatIce`.
  final CandidatIce candidat;

  String get candidate => candidat.candidate;
}

/// Contrôle d'appel : `bye` (l'autre a raccroché ou refusé), `cam-on`,
/// `cam-off` (l'autre allume ou coupe sa caméra).
class ControleAppelEvent extends SignalingEvent {
  const ControleAppelEvent(this.fromPeerId, this.ctrl);
  final String fromPeerId;
  final String ctrl;
}

/// Client de signaling WebRTC.
class SignalingClient {
  SignalingClient({required this.serverUrl});

  final String serverUrl;
  WebSocketChannel? _channel;
  String? _roomId;
  String? _peerId;

  final _eventCtrl = StreamController<SignalingEvent>.broadcast();
  Stream<SignalingEvent> get events => _eventCtrl.stream;

  bool get isConnected => _channel != null;

  /// Derniers serveurs ICE obtenus (relais Cloudflare valables 24 h), partagés
  /// par tous les clients de l'app.
  static List<Map<String, dynamic>>? _derniersServeursIce;
  static DateTime? _dateServeursIce;

  /// Appelé quand la connexion tombe d'elle-même (pas sur `leaveRoom`) —
  /// pour se reconnecter tout de suite plutôt qu'au prochain contrôle.
  void Function()? onFermeture;

  /// L'adresse WebSocket d'une salle, à partir de l'URL du serveur.
  ///
  /// ⚠️ LES APPELS PAR INTERNET N'ONT JAMAIS PU S'ÉTABLIR SANS ÇA.
  /// `kSignalingUrl` est une adresse `https://` (la même que pour les
  /// requêtes HTTP du serveur), et la connexion était ouverte telle quelle.
  /// Or un WebSocket Dart n'accepte que `ws://` ou `wss://` : vérifié contre
  /// le vrai serveur, `https://…/ws/…` lève « Unsupported URL scheme
  /// 'https' » tandis que `wss://…/ws/…` se connecte. Ni la salle d'appels
  /// entrants ni un appel sortant ne pouvaient donc joindre le serveur.
  static Uri urlSalle(String serverUrl, String roomId) {
    final base = Uri.parse(serverUrl);
    final schema = switch (base.scheme) {
      'https' || 'wss' => 'wss',
      'http' || 'ws' => 'ws',
      _ => throw ArgumentError.value(serverUrl, 'serverUrl', 'schéma non géré'),
    };
    final chemin = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      scheme: schema,
      path: '$chemin/ws/${Uri.encodeComponent(roomId)}',
    );
  }

  /// Rejoint une salle de signaling. Renvoie `false` si le serveur est
  /// injoignable.
  ///
  /// ⚠️ LA CONNEXION EST ATTENDUE (`ready`). `WebSocketChannel.connect`
  /// rend la main tout de suite ; sans Internet, l'échec (« Failed host
  /// lookup ») arrivait plus tard sur `ready`, que personne n'écoutait —
  /// erreur non gérée dans le journal à chaque tentative de reconnexion, et
  /// un appel sortant restait « en cours » vers un serveur jamais joint.
  Future<bool> joinRoom(String roomId, String peerId) async {
    _roomId = roomId;
    _peerId = peerId;

    try {
      try {
        await _channel?.sink.close();
      } catch (_) {}
      // ⚠️ SIGNE DE VIE TOUTES LES 15 S. Sans trafic, la connexion était
      // coupée par le serveur au bout de quelques dizaines de secondes (les
      // journaux Railway montraient la boîte d'appels quitter et rejoindre
      // sa salle en boucle) : un appel lancé dans ce trou partait dans une
      // salle vide et se perdait.
      final canal = IOWebSocketChannel.connect(
        urlSalle(serverUrl, roomId),
        pingInterval: const Duration(seconds: 15),
      );
      _channel = canal;
      try {
        // ⚠️ 30 S, PAS 10. Mesuré depuis le Cameroun : 1 à 3 s par connexion
        // TLS vers Railway, avec des pointes au-delà de 10 s. Le délai court
        // faisait échouer la boîte d'appels et les appels sortants.
        await canal.ready.timeout(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('[Signaling] Serveur injoignable: $e');
        if (identical(_channel, canal)) _channel = null;
        unawaited(canal.sink.close().catchError((_) {}));
        return false;
      }

      canal.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _handleMessage(msg);
          } catch (e) {
            debugPrint('[Signaling] Erreur parsing: $e');
          }
        },
        onDone: () {
          debugPrint('[Signaling] Connexion fermée');
          if (identical(_channel, canal)) {
            _channel = null;
            onFermeture?.call();
          }
        },
        onError: (e) {
          debugPrint('[Signaling] Erreur: $e');
          if (identical(_channel, canal)) {
            _channel = null;
            onFermeture?.call();
          }
        },
        cancelOnError: true,
      );

      // Envoyer le join.
      _send({'type': 'join', 'peerId': peerId});
      debugPrint('[Signaling] Rejoint la salle $roomId');
      EtatInternet.signalerReussite();
      return true;
    } catch (e) {
      debugPrint('[Signaling] Erreur connexion: $e');
      _channel = null;
      return false;
    }
  }

  /// Quitte la salle.
  void leaveRoom() {
    _send({'type': 'leave'});
    _channel?.sink.close();
    _channel = null;
    _roomId = null;
    _peerId = null;
  }

  /// Envoie une offre SDP à un peer.
  void sendOffer(String toPeerId, String sdp, {bool video = false}) {
    _send({
      'type': 'offer',
      'from': _peerId,
      'to': toPeerId,
      'sdp': sdp,
      // Le serveur relaie le message tel quel : ce champ ne demande aucun
      // redéploiement.
      'video': video,
    });
  }

  /// Envoie une réponse SDP à un peer.
  void sendAnswer(String toPeerId, String sdp) {
    _send({
      'type': 'answer',
      'from': _peerId,
      'to': toPeerId,
      'sdp': sdp,
    });
  }

  /// Envoie un candidat ICE à un peer.
  /// ⚠️ LE CANDIDAT COMPLET, PAS SEULEMENT SA CHAÎNE. Sans `sdpMid` ni
  /// `sdpMLineIndex`, l'autre appareil ne pouvait pas l'ajouter : aucune
  /// route réseau n'était échangée et l'appel ne transportait ni son ni image.
  void sendIceCandidate(String toPeerId, CandidatIce candidat) {
    _send({
      'type': 'ice-candidate',
      'from': _peerId,
      'to': toPeerId,
      ...candidat.versJson(),
    });
  }

  /// ⚠️ TRANSPORTÉ COMME UN `ice-candidate`. Le serveur ne relaie que
  /// `offer`, `answer` et `ice-candidate` — tels quels. Sans ce détour, un
  /// raccrochage n'arrivait jamais : la boîte d'appels du destinataire ne
  /// quitte pas la salle (elle doit rester joignable), et l'appelant restait
  /// « en communication » avec personne. Aucun redéploiement nécessaire ; un
  /// appareil pas à jour ignore le message (pas de `candidate`).
  void sendControle(String toPeerId, String ctrl) {
    _send({
      'type': 'ice-candidate',
      'from': _peerId,
      'to': toPeerId,
      'ctrl': ctrl,
    });
  }

  /// Serveurs ICE (STUN + relais TURN) fournis par le serveur d'appels
  /// (`/turn/credentials`, identifiants Cloudflare temporaires). Toujours au
  /// moins un STUN de repli, même hors ligne ou sans relais configuré.
  Future<List<Map<String, dynamic>>> serveursIceDuServeur() async {
    // ⚠️ PAS DE REQUÊTE À CHAQUE APPEL. Décrocher attendait la réponse du
    // serveur — jusqu'à 15 s sur un réseau lent — avant même de préparer la
    // connexion. Les identifiants valent 12 h : on garde les derniers 2 h.
    final enCache = _derniersServeursIce;
    final date = _dateServeursIce;
    if (enCache != null && date != null && DateTime.now().difference(date) < const Duration(hours: 2)) {
      return enCache;
    }
    try {
      final base = Uri.parse(serverUrl);
      final r = await http
          .post(base.replace(path: '${base.path.replaceAll(RegExp(r'/$'), '')}/turn/credentials'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'peerId': _peerId ?? ''}))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return _derniersServeursIce ?? serveursIce(null);
      EtatInternet.signalerReussite();
      final serveurs = serveursIce(jsonDecode(r.body));
      _derniersServeursIce = serveurs;
      _dateServeursIce = DateTime.now();
      return serveurs;
    } catch (e) {
      debugPrint('[Signaling] relais ICE indisponibles: $e');
      // Les derniers identifiants valent 24 h : mieux qu'un STUN seul, qui ne
      // traverse pas les réseaux mobiles.
      return _derniersServeursIce ?? serveursIce(null);
    }
  }

  void _send(Map<String, dynamic> msg) {
    _channel?.sink.add(jsonEncode(msg));
  }

  final _brutsCtrl = StreamController<Map<String, dynamic>>.broadcast();

  /// Tous les messages reçus, tels quels — pour les appels de groupe, dont
  /// chaque message est adressé à UN participant (`to`) dans une salle
  /// partagée.
  Stream<Map<String, dynamic>> get messagesBruts => _brutsCtrl.stream;

  /// Envoie un message tel quel (le serveur relaie `offer`, `answer` et
  /// `ice-candidate` à toute la salle).
  void envoyerBrut(Map<String, dynamic> message) => _send(message);

  void _handleMessage(Map<String, dynamic> msg) {
    if (!_brutsCtrl.isClosed) _brutsCtrl.add(msg);
    final type = msg['type'] as String?;

    switch (type) {
      case 'joined':
        final peers = msg['peers'] as List<dynamic>? ?? [];
        for (final p in peers) {
          _eventCtrl.add(PeerJoinedEvent(p as String));
        }

      case 'offer':
        final sdp = msg['sdp'] as String;
        _eventCtrl.add(OfferEvent(
          msg['from'] as String,
          sdp,
          // Un appareil pas encore à jour n'envoie pas `video` : on le déduit
          // alors de l'offre elle-même.
          video: msg['video'] as bool? ?? sdp.contains('m=video'),
        ));

      case 'answer':
        _eventCtrl.add(AnswerEvent(
          msg['from'] as String,
          msg['sdp'] as String,
        ));

      case 'ice-candidate':
        final ctrl = msg['ctrl'];
        if (ctrl is String) {
          _eventCtrl.add(ControleAppelEvent(msg['from'] as String, ctrl));
          break;
        }
        final candidat = CandidatIce.depuisMessage(msg);
        if (candidat != null) {
          _eventCtrl.add(IceCandidateEvent(msg['from'] as String, candidat));
        }

      case 'peer-joined':
        final entrant = msg['peerId'];
        if (entrant is String && entrant.isNotEmpty && entrant != _peerId) {
          _eventCtrl.add(PairEntreEvent(entrant));
        }

      case 'room-full':
        _eventCtrl.add(SalonPleinEvent(msg['max'] as int? ?? 0));

      case 'peer-left':
        _eventCtrl.add(PeerLeftEvent(msg['peerId'] as String));
    }
  }

  void dispose() {
    leaveRoom();
    _eventCtrl.close();
  }
}
