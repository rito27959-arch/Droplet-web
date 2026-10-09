// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'APPEL AUDIO OU VIDÉO PAR INTERNET (WebRTC), mis en relation par le serveur
// de signalisation. L'appel mesh local, lui, vit dans `webrtc_call_service.dart`.
//
// ── ⚠️ RÉÉCRIT : AUCUN APPEL PAR INTERNET NE POUVAIT TRANSPORTER DE SON ─────
//
// L'ancienne version accumulait des défauts qui, ensemble, rendaient l'appel
// impossible même une fois le serveur joint :
//   1. candidats ICE envoyés sans `sdpMid`/`sdpMLineIndex` (rejetés) ;
//   2. candidats arrivés avant la connexion ou la description distante perdus ;
//   3. `plan-b` + `addStream` — abandonnés par les WebRTC récents ;
//   4. « connecté » affiché avant que le moindre paquet audio ne passe ;
//   5. raccrochage à la première micro-coupure réseau ;
//   6. caméra ouverte pour un appel vocal (échec total si refusée) ;
//   7. aucun relais TURN — deux réseaux mobiles ne se joignaient jamais ;
//   8. vidéo reçue affichée nulle part.
// La logique pure qui corrige 1, 2, 5, 6 et 7 est dans `appel_outils.dart`,
// testée isolément.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'appel_outils.dart';
import 'signaling_client.dart';

/// État d'un appel par Internet.
enum CallState {
  idle,
  calling,
  ringing,
  connected,
  disconnected,
}

class CallService {
  CallService({required this.signalingClient, this.persistent = false});

  final SignalingClient signalingClient;

  /// Vrai pour la boîte d'appels ENTRANTS : terminer un appel n'y quitte pas
  /// la salle, sinon on deviendrait injoignable pour le suivant.
  final bool persistent;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool _rendusPrets = false;

  CallState _state = CallState.idle;
  String? _currentRoomId;
  String? _remotePeerId;
  String? _pendingOfferSdp;

  bool _video = false;
  bool _offreVideo = false;
  bool _descriptionDistantePosee = false;
  final FileCandidats _candidatsEnAttente = FileCandidats();
  SuiviIce _suivi = SuiviIce();
  Timer? _minuteurCoupure;
  StreamSubscription<SignalingEvent>? _abonnement;
  bool _cameraDistanteCoupee = false;
  bool _reconnexion = false;
  bool? _viaRelais;
  int _rttMs = 0;
  Timer? _minuteurStats;
  Timer? _renvoiOffre;

  /// Dernière offre distante déjà appliquée : un renvoi de la même offre
  /// (voir [_programmerRenvoiOffre]) est ignoré.
  String? _offreAppliquee;
  final _changementsCtrl = StreamController<void>.broadcast();

  final _stateCtrl = StreamController<CallState>.broadcast();
  final _remoteStreamCtrl = StreamController<MediaStream>.broadcast();

  CallState get state => _state;
  Stream<CallState> get stateStream => _stateCtrl.stream;
  Stream<MediaStream> get remoteStreamEvents => _remoteStreamCtrl.stream;
  MediaStream? get localStream => _localStream;
  MediaStream? get currentRemoteStream => _remoteStream;
  String? get remotePeerId => _remotePeerId;
  bool get isInCall => _state == CallState.connected;
  bool get isIdle => _state == CallState.idle;

  /// L'appel en cours transporte-t-il MA vidéo ?
  bool get videoActive => _video;

  /// L'appel entrant en attente est-il un appel vidéo ?
  bool get offreVideo => _offreVideo;

  /// L'autre personne envoie-t-elle réellement son image ?
  bool get videoDistante =>
      !_cameraDistanteCoupee && (_remoteStream?.getVideoTracks().isNotEmpty ?? false);

  /// Émis à chaque changement de médias (piste reçue, caméra allumée ou
  /// coupée d'un côté ou de l'autre) — l'écran d'appel s'y resynchronise.
  Stream<void> get changements => _changementsCtrl.stream;

  /// Liaison établie puis momentanément coupée (passage Wi-Fi ↔ 4G…) :
  /// l'appel tient, l'écran affiche « Reconnexion… ».
  bool get reconnexion => _reconnexion;

  /// L'appel passe-t-il par un relais TURN ? `null` tant qu'on ne sait pas.
  bool? get viaRelais => _viaRelais;

  /// Aller-retour réseau mesuré, en millisecondes (0 : inconnu).
  int get rttMs => _rttMs;

  void init() {
    _abonnement ??= signalingClient.events.listen(_onSignalingEvent);
  }

  Future<void> _initialiserRendus() async {
    if (_rendusPrets) return;
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _rendusPrets = true;
  }

  /// Micro (et caméra si [video]) : sans permission, `getUserMedia` échoue
  /// sans explication. On demande AVANT, et on dit clairement ce qui manque.
  Future<void> _exigerPermissions({required bool video}) async {
    final micro = await Permission.microphone.request();
    if (!micro.isGranted) {
      throw StateError('Permission micro refusée');
    }
    if (video) {
      final camera = await Permission.camera.request();
      if (!camera.isGranted) throw StateError('Permission caméra refusée');
    }
  }

  /// Appelle [remotePeerId] — en vidéo si [video].
  Future<void> startCall(String myPeerId, String remotePeerId, {bool video = false}) async {
    if (_state != CallState.idle) {
      debugPrint('[CallService] Déjà en appel');
      return;
    }
    _remotePeerId = remotePeerId;
    _video = video;
    _setState(CallState.calling);
    try {
      await _exigerPermissions(video: video);
      await _initialiserRendus();
      // La boîte d'appels PERSONNELLE du destinataire, qu'il écoute en continu.
      _currentRoomId = 'inbox_$remotePeerId';
      // Une seconde tentative avant d'abandonner : sur un réseau lent, la
      // première connexion échoue parfois sur une simple pointe de latence.
      if (!await signalingClient.joinRoom(_currentRoomId!, myPeerId) &&
          !await signalingClient.joinRoom(_currentRoomId!, myPeerId)) {
        throw StateError('Serveur d\'appels injoignable');
      }
      await _createPeerConnection();
      await _ajouterMedias(video: video);
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      // L'offre part avec ses chemins réseau (relais compris) : renvoyée
      // plus tard, elle suffit à elle seule — les candidats envoyés un par
      // un pendant que l'autre n'écoutait pas encore sont perdus.
      await _attendreCollecte();
      final locale = await _peerConnection?.getLocalDescription();
      final sdp = locale?.sdp ?? offer.sdp ?? '';
      signalingClient.sendOffer(remotePeerId, sdp, video: video);
      _programmerRenvoiOffre(remotePeerId, sdp, video);
      debugPrint('[CallService] Offre ${video ? "vidéo" : "vocale"} envoyée vers $remotePeerId');
    } catch (e) {
      debugPrint('[CallService] Appel impossible: $e');
      await endCall();
      rethrow;
    }
  }

  /// Décroche l'appel entrant en attente.
  Future<void> answerCall(String myPeerId, String remotePeerId) async {
    final offerSdp = _pendingOfferSdp;
    if (_state != CallState.ringing || offerSdp == null) {
      debugPrint('[CallService] Pas d\'appel en attente');
      return;
    }
    _remotePeerId = remotePeerId;
    _video = _offreVideo;
    try {
      await _exigerPermissions(video: _video);
      await _initialiserRendus();
      await _createPeerConnection();
      await _ajouterMedias(video: _video);
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(offerSdp, 'offer'));
      await _descriptionDistanteEstPosee();
      _pendingOfferSdp = null;
      _offreAppliquee = offerSdp;
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      // L'appelant écoute déjà : les chemins trouvés ensuite lui arrivent un
      // par un. Attendre la collecte complète retardait la réponse de 3 s.
      await _attendreCollecte(max: const Duration(milliseconds: 900));
      final locale = await _peerConnection?.getLocalDescription();
      signalingClient.sendAnswer(remotePeerId, locale?.sdp ?? answer.sdp ?? '');
      // PAS de `connected` ici : il viendra de la liaison ICE (voir `SuiviIce`).
      debugPrint('[CallService] Réponse envoyée vers $remotePeerId');
    } catch (e) {
      debugPrint('[CallService] Réponse impossible: $e');
      await endCall();
      rethrow;
    }
  }

  /// Termine l'appel. [prevenir] : envoyer `bye` à l'autre — faux quand
  /// c'est LUI qui vient de raccrocher.
  Future<void> endCall({bool prevenir = true}) async {
    final remote = _remotePeerId;
    if (prevenir && remote != null && _state != CallState.idle) {
      try {
        signalingClient.sendControle(remote, 'bye');
      } catch (_) {}
    }
    _minuteurStats?.cancel();
    _minuteurStats = null;
    _renvoiOffre?.cancel();
    _renvoiOffre = null;
    _offreAppliquee = null;
    _minuteurCoupure?.cancel();
    _minuteurCoupure = null;
    try {
      await _peerConnection?.close();
    } catch (_) {}
    _peerConnection = null;
    for (final t in _localStream?.getTracks() ?? const <MediaStreamTrack>[]) {
      try {
        await t.stop();
      } catch (_) {}
    }
    try {
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _remoteStream = null;
    if (_rendusPrets) {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    }
    if (!persistent) signalingClient.leaveRoom();
    _currentRoomId = null;
    _remotePeerId = null;
    _pendingOfferSdp = null;
    _descriptionDistantePosee = false;
    _candidatsEnAttente.vider();
    _suivi = SuiviIce();
    _video = false;
    _offreVideo = false;
    _reconnexion = false;
    _viaRelais = null;
    _rttMs = 0;
    _cameraDistanteCoupee = false;
    if (!_changementsCtrl.isClosed) _changementsCtrl.add(null);
    if (_state != CallState.idle) {
      _setState(CallState.disconnected);
      _setState(CallState.idle);
    }
  }

  Future<void> toggleMicrophone() async {
    for (final t in _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      t.enabled = !t.enabled;
    }
  }

  /// Coupe ou rallume la caméra. Dans un appel vocal, la première activation
  /// ajoute une piste vidéo et RENÉGOCIE l'appel (nouvelle offre) — l'autre
  /// appareil y répond automatiquement (voir `_handleOffer`).
  Future<void> toggleCamera() async {
    final pc = _peerConnection;
    final flux = _localStream;
    if (pc == null || flux == null) return;
    final pistes = flux.getVideoTracks();
    if (pistes.isNotEmpty) {
      final allumer = !pistes.first.enabled;
      for (final t in pistes) {
        t.enabled = allumer;
      }
      _video = allumer;
      final remote = _remotePeerId;
      if (remote != null) signalingClient.sendControle(remote, allumer ? 'cam-on' : 'cam-off');
      _changementsCtrl.add(null);
      return;
    }
    await _exigerPermissions(video: true);
    final camera = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': contraintesMedia(video: true)['video'],
    });
    for (final t in camera.getVideoTracks()) {
      await flux.addTrack(t);
      await pc.addTrack(t, flux);
    }
    localRenderer.srcObject = flux;
    _video = true;
    final remote = _remotePeerId;
    if (remote != null) {
      final offre = await pc.createOffer();
      await pc.setLocalDescription(offre);
      signalingClient.sendOffer(remote, offre.sdp ?? '', video: true);
      signalingClient.sendControle(remote, 'cam-on');
    }
    _changementsCtrl.add(null);
  }

  Future<void> switchCamera() async {
    final piste = _localStream?.getVideoTracks().firstOrNull;
    if (piste != null) await Helper.switchCamera(piste);
  }

  Future<void> setSpeaker(bool actif) => Helper.setSpeakerphoneOn(actif);

  // ── Connexion ─────────────────────────────────────────────────────────

  Future<void> _createPeerConnection() async {
    final serveurs = await signalingClient.serveursIceDuServeur();
    final aUnRelais = serveurs.any((s) => (s['urls'] as List).any((u) => '$u'.startsWith('turn')));
    debugPrint('[CallService] ${serveurs.length} serveur(s) ICE — relais TURN : ${aUnRelais ? "oui" : "non"}');
    _peerConnection = await createPeerConnection({
      'iceServers': serveurs,
      'sdpSemantics': 'unified-plan',
    });
    final pc = _peerConnection!;

    pc.onIceCandidate = (candidate) {
      final remote = _remotePeerId;
      final chaine = candidate.candidate;
      if (remote == null || chaine == null || chaine.isEmpty) return;
      signalingClient.sendIceCandidate(
        remote,
        CandidatIce(chaine, sdpMid: candidate.sdpMid, sdpMLineIndex: candidate.sdpMLineIndex),
      );
    };

    pc.onTrack = (event) {
      final flux = event.streams.isNotEmpty ? event.streams.first : null;
      if (flux == null) return;
      _remoteStream = flux;
      remoteRenderer.srcObject = flux;
      _remoteStreamCtrl.add(flux);
      _changementsCtrl.add(null);
      debugPrint('[CallService] Piste distante reçue (${event.track.kind})');
    };

    pc.onIceConnectionState = (etat) {
      final nom = etat.toString().split('.').last.replaceFirst('RTCIceConnectionState', '').toLowerCase();
      debugPrint('[CallService] ICE : $nom');
      switch (_suivi.surEtat(nom)) {
        case EtatLiaison.etablie:
          _minuteurCoupure?.cancel();
          _minuteurCoupure = null;
          _setState(CallState.connected);
          _reconnexion = false;
          _demarrerStats();
          if (!_changementsCtrl.isClosed) _changementsCtrl.add(null);
        case EtatLiaison.coupee:
          if (_suivi.etablieUneFois && !_reconnexion) {
            _reconnexion = true;
            if (!_changementsCtrl.isClosed) _changementsCtrl.add(null);
          }
          _minuteurCoupure ??= Timer(_suivi.grace, () {
            _minuteurCoupure = null;
            if (_suivi.doitRaccrocher()) {
              debugPrint('[CallService] Coupure prolongée — fin de l\'appel');
              unawaited(endCall());
            }
          });
        case EtatLiaison.echouee:
          debugPrint('[CallService] Liaison ICE échouée — fin de l\'appel');
          unawaited(endCall());
        case EtatLiaison.enCours:
          break;
      }
    };
  }

  /// Attend la fin de la collecte des chemins réseau, au plus [max].
  Future<void> _attendreCollecte({Duration max = const Duration(seconds: 3)}) async {
    final pc = _peerConnection;
    if (pc == null) return;
    if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) return;
    final fini = Completer<void>();
    final precedent = pc.onIceGatheringState;
    pc.onIceGatheringState = (etat) {
      precedent?.call(etat);
      if (etat == RTCIceGatheringState.RTCIceGatheringStateComplete && !fini.isCompleted) {
        fini.complete();
      }
    };
    await fini.future.timeout(max, onTimeout: () {});
  }

  /// ⚠️ L'OFFRE EST RÉPÉTÉE TOUTES LES 3 S JUSQU'À LA RÉPONSE. Le serveur ne
  /// garde rien : si l'appareil appelé n'était pas dans sa salle à l'instant
  /// de l'offre (connexion en train de se rétablir, application réveillée
  /// par la notification), elle était perdue et l'appel sonnait dans le
  /// vide. Sans réponse au bout de 45 s, l'appel s'arrête.
  void _programmerRenvoiOffre(String remote, String sdp, bool video) {
    _renvoiOffre?.cancel();
    var envois = 0;
    _renvoiOffre = Timer.periodic(const Duration(seconds: 3), (minuteur) {
      final attend = _state == CallState.calling &&
          !_descriptionDistantePosee &&
          _remotePeerId == remote;
      if (!attend) {
        minuteur.cancel();
        return;
      }
      if (++envois > 15) {
        minuteur.cancel();
        debugPrint('[CallService] Pas de réponse — fin de l\'appel');
        unawaited(endCall());
        return;
      }
      signalingClient.sendOffer(remote, sdp, video: video);
    });
  }

  /// Relevé des statistiques toutes les 2 s : relais ou direct, latence.
  void _demarrerStats() {
    _minuteurStats ??= Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_lireStats()),
    );
    unawaited(_lireStats());
  }

  Future<void> _lireStats() async {
    final pc = _peerConnection;
    if (pc == null) return;
    try {
      final rapports = await pc.getStats();
      final lu = lireStatsIce([for (final r in rapports) (r.id, r.type, r.values)]);
      final relais = lu.viaRelais ?? _viaRelais;
      if (relais != _viaRelais || (lu.rttMs - _rttMs).abs() >= 20) {
        if (_viaRelais == null && relais != null) {
          debugPrint('[CallService] Chemin : ${relais ? "relais TURN" : "direct"}');
        }
        _viaRelais = relais;
        _rttMs = lu.rttMs;
        if (!_changementsCtrl.isClosed) _changementsCtrl.add(null);
      }
    } catch (_) {
      // Statistiques indisponibles : l'appel continue, l'écran reste neutre.
    }
  }

  Future<void> _ajouterMedias({required bool video}) async {
    final flux = await navigator.mediaDevices.getUserMedia(contraintesMedia(video: video));
    _localStream = flux;
    localRenderer.srcObject = flux;
    for (final t in flux.getTracks()) {
      await _peerConnection!.addTrack(t, flux);
    }
    // La vidéo s'écoute naturellement en haut-parleur ; l'audio seul, à l'oreille.
    unawaited(Helper.setSpeakerphoneOn(video).catchError((_) {}));
  }

  Future<void> _descriptionDistanteEstPosee() async {
    _descriptionDistantePosee = true;
    for (final c in _candidatsEnAttente.vider()) {
      await _ajouterCandidat(c);
    }
  }

  Future<void> _ajouterCandidat(CandidatIce c) async {
    try {
      await _peerConnection?.addCandidate(RTCIceCandidate(c.candidate, c.sdpMid, c.sdpMLineIndex));
    } catch (e) {
      debugPrint('[CallService] candidat refusé: $e');
    }
  }

  // ── Signalisation ─────────────────────────────────────────────────────

  void _onSignalingEvent(SignalingEvent event) {
    switch (event) {
      case PeerJoinedEvent(:final peerId):
        debugPrint('[CallService] Pair dans la salle: $peerId');
      case PeerLeftEvent(:final peerId):
        if (peerId == _remotePeerId) unawaited(endCall(prevenir: false));
      // Deux événements de salon vocal. Un appel 1:1 n'en a que faire,
      // mais le `switch` porte sur une classe scellée : sans ces deux
      // branches, il cesse d'être exhaustif et ne compile plus.
      case PairEntreEvent():
      case SalonPleinEvent():
        break;
      case OfferEvent(:final fromPeerId, :final sdp, :final video):
        unawaited(_handleOffer(fromPeerId, sdp, video));
      case AnswerEvent(:final fromPeerId, :final sdp):
        unawaited(_handleAnswer(fromPeerId, sdp));
      case IceCandidateEvent(:final fromPeerId, :final candidat):
        unawaited(_handleIceCandidate(fromPeerId, candidat));
      case ControleAppelEvent(:final fromPeerId, :final ctrl):
        if (fromPeerId != _remotePeerId) return;
        switch (ctrl) {
          case 'bye':
            debugPrint('[CallService] $fromPeerId a raccroché');
            unawaited(endCall(prevenir: false));
          case 'cam-on':
          case 'cam-off':
            _cameraDistanteCoupee = ctrl == 'cam-off';
            _changementsCtrl.add(null);
        }
    }
  }

  Future<void> _handleOffer(String fromPeerId, String sdp, bool video) async {
    // Renvoi d'une offre déjà traitée (l'appelant la répète tant qu'il n'a
    // pas reçu la réponse) : rien à faire.
    if (sdp == _offreAppliquee) return;
    // Renégociation en cours d'appel (l'autre vient d'allumer sa caméra) :
    // on répond tout de suite, sans refaire sonner.
    final pc = _peerConnection;
    if (pc != null && fromPeerId == _remotePeerId && _descriptionDistantePosee) {
      try {
        await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
        _offreAppliquee = sdp;
        final reponse = await pc.createAnswer();
        await pc.setLocalDescription(reponse);
        signalingClient.sendAnswer(fromPeerId, reponse.sdp ?? '');
      } catch (e) {
        debugPrint('[CallService] renégociation impossible: $e');
      }
      return;
    }
    if (_state != CallState.idle) return;
    _remotePeerId = fromPeerId;
    _pendingOfferSdp = sdp;
    _offreVideo = video;
    _cameraDistanteCoupee = !video;
    _setState(CallState.ringing);
  }

  Future<void> _handleAnswer(String fromPeerId, String sdp) async {
    final pc = _peerConnection;
    if (pc == null || fromPeerId != _remotePeerId) return;
    try {
      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      await _descriptionDistanteEstPosee();
      debugPrint('[CallService] Réponse de $fromPeerId appliquée');
    } catch (e) {
      debugPrint('[CallService] réponse refusée: $e');
    }
  }

  Future<void> _handleIceCandidate(String fromPeerId, CandidatIce c) async {
    // La salle d'un destinataire peut accueillir un second appelant : ses
    // candidats ne concernent pas l'appel en cours.
    final remote = _remotePeerId;
    if (remote != null && fromPeerId != remote) return;
    // Trop tôt (sonnerie, ou réponse pas encore appliquée) : on garde.
    if (_peerConnection == null || !_descriptionDistantePosee) {
      _candidatsEnAttente.ajouter(c);
      return;
    }
    await _ajouterCandidat(c);
  }

  void _setState(CallState newState) {
    if (_state == newState) return;
    _state = newState;
    _stateCtrl.add(newState);
  }

  void dispose() {
    unawaited(endCall());
    _abonnement?.cancel();
    if (_rendusPrets) {
      localRenderer.dispose();
      remoteRenderer.dispose();
    }
    _stateCtrl.close();
    _remoteStreamCtrl.close();
    _changementsCtrl.close();
  }
}
