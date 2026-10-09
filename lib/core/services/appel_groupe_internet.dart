// ============================================================================
// L'APPEL DE GROUPE PAR INTERNET — voix, jusqu'à 4 personnes.
// ----------------------------------------------------------------------------
// L'appel de groupe du mesh (`group_webrtc_call_service.dart`) exige une
// liaison Wi-Fi directe avec CHAQUE participant : à distance, personne
// n'était joignable. Ici, la mise en relation passe par le serveur d'appels :
//
//   • chaque groupe a UNE SEULE SALLE (`salon_<groupId>`), partagée par
//     l'appel de groupe et le salon vocal — deux portes, une seule pièce.
//     Sans ça, ouvrir un salon pendant qu'un appel tourne dans le même
//     groupe créait deux conversations parallèles que personne ne pouvait
//     réunir ;
//   • qui rejoint la salle reçoit la liste des présents et appelle CHACUN
//     d'eux ; les présents répondent. Un seul sens par paire : jamais deux
//     offres croisées, sans coordination ;
//   • le serveur relaie chaque message à toute la salle : chacun ne garde que
//     ceux qui lui sont adressés (`to`) ;
//   • relais Cloudflare (TURN) fournis par le serveur, comme pour l'appel 1:1.
//
// Maillage complet (une connexion par paire), audio seulement. Le plafond
// dépend de la porte : quatre pour un appel de groupe (comme le mesh), huit
// pour un salon — c'est aussi la limite que le serveur fait respecter sur
// les salles `salon_`. Au-delà, le nombre de connexions grimpe au carré et
// les téléphones chauffent ; il faudrait un mélangeur côté serveur, et ce
// sera une autre histoire.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'appel_outils.dart';
import 'group_webrtc_call_service.dart';
import 'signaling_client.dart';

class AppelGroupeInternet {
  AppelGroupeInternet({
    required this.serverUrl,
    this.maximum = maxSalon,
    this.surArrivee,
    this.surDepart,
    this.surSalonPlein,
  });

  final String serverUrl;

  /// Le plafond de CETTE session.
  ///
  /// ⚠️ HUIT PAR DÉFAUT, MÊME POUR UN APPEL, et ce n'est pas un oubli.
  /// L'appel de groupe et le salon vocal partagent désormais LA MÊME
  /// SALLE : si l'un refusait de se connecter au-delà de quatre pendant
  /// que l'autre acceptait jusqu'à huit, une même pièce aurait deux règles
  /// et certains ne s'entendraient qu'à moitié. Ce qui limite un appel à
  /// quatre, c'est le nombre de personnes qu'on INVITE (voir
  /// `group_info_screen.dart`), pas ce que la salle tolère.
  final int maximum;

  /// Quelqu'un entre dans la salle, ou en sort. Sert à tenir la liste des
  /// présents à jour — la connexion audio, elle, se noue toute seule.
  final void Function(String peerId)? surArrivee;
  final void Function(String peerId)? surDepart;

  /// Le serveur a refusé l'entrée : le salon est complet.
  final void Function(int plafond)? surSalonPlein;

  /// Le nombre de personnes qu'un APPEL de groupe invite au plus — la
  /// limite de l'invitation, pas celle de la salle.
  static const int maxParticipants = 4;

  /// Le plafond d'un salon vocal, aligné sur `_maxParSalon` du serveur.
  static const int maxSalon = 8;

  /// ⚠️ UNE SEULE SALLE PAR GROUPE, et son nom commence par `salon_`.
  /// C'est ce préfixe qui dit au serveur de ne réveiller personne par
  /// notification (seules les boîtes `inbox_` le font) et de refuser une
  /// entrée au-delà de huit.
  static String salle(String groupId) => 'salon_$groupId';

  SignalingClient? _client;
  StreamSubscription<Map<String, dynamic>>? _bruts;
  StreamSubscription<SignalingEvent>? _evenements;
  MediaStream? _micro;
  String _moi = '';
  List<Map<String, dynamic>> _serveursIce = serveursIce(null);

  final Map<String, RTCPeerConnection> _connexions = {};
  final Map<String, FileCandidats> _candidatsEnAttente = {};
  final Set<String> _descriptionPosee = {};
  bool _hautParleur = true;

  final _eventCtrl = StreamController<GroupCallEvent>.broadcast();
  Stream<GroupCallEvent> get events => _eventCtrl.stream;

  /// Rejoint la salle du groupe et appelle les participants déjà présents.
  Future<void> rejoindre({required String moi, required String groupId}) async {
    _moi = moi;
    if (!(await Permission.microphone.request()).isGranted) {
      throw StateError('Permission micro refusée');
    }
    _micro = await navigator.mediaDevices.getUserMedia(contraintesMedia(video: false));
    unawaited(Helper.setSpeakerphoneOn(_hautParleur).catchError((_) {}));

    final client = SignalingClient(serverUrl: serverUrl);
    _client = client;
    _serveursIce = await client.serveursIceDuServeur();
    _bruts = client.messagesBruts.listen(_surMessage);
    // La liste des présents arrive en réponse à notre entrée dans la salle :
    // c'est au nouvel arrivant d'appeler chacun d'eux.
    _evenements = client.events.listen((evenement) {
      switch (evenement) {
        // Ceux qui étaient DÉJÀ là quand je suis arrivé : c'est à moi de
        // les appeler. Un seul sens par paire, sans coordination.
        case PeerJoinedEvent(:final peerId) when peerId != _moi:
          // ⚠️ MOI + LES PRÉSENTS + CELUI-CI. La version précédente
          // comparait `connexions + 1` au plafond et s'arrêtait donc une
          // personne trop tôt : un salon annoncé à huit n'en tenait que
          // sept.
          if (_connexions.length + 2 > maximum) return;
          surArrivee?.call(peerId);
          unawaited(_connecter(peerId, initiateur: true).catchError((Object e) {
            debugPrint('[AppelGroupe] connexion vers $peerId impossible: $e');
          }));
        // Quelqu'un entre APRÈS moi : c'est lui qui appelle (voir
        // `PairEntreEvent`). Ici on met seulement la liste à jour.
        case PairEntreEvent(:final peerId):
          surArrivee?.call(peerId);
        // ⚠️ SEULEMENT SI ON LE CONNAISSAIT. Un départ annoncé pour
        // quelqu'un avec qui on n'avait aucune connexion faisait remonter
        // une déconnexion fantôme, et le fournisseur raccrochait un salon
        // où l'on venait d'entrer seul.
        case PeerLeftEvent(:final peerId):
          surDepart?.call(peerId);
          if (_connexions.containsKey(peerId)) {
            unawaited(_retirer(peerId, prevenir: false));
          }
        // ⚠️ LE REFUS ARRIVE APRÈS COUP, et c'est pour ça qu'il passe par
        // un rappel plutôt que par le résultat de `rejoindre`. Le serveur
        // ne répond au `join` qu'une fois la connexion ouverte : attendre
        // sa réponse aurait retardé TOUS les appels, pleins ou non, pour
        // le seul cas rare où la porte est fermée.
        case SalonPleinEvent(maximum: final plafond):
          debugPrint('[AppelGroupe] salon plein ($plafond)');
          surSalonPlein?.call(plafond);
        default:
          break;
      }
    });
    if (!await client.joinRoom(salle(groupId), moi)) {
      await quitter();
      throw StateError('Serveur d\'appels injoignable');
    }
  }

  void _envoyer(String pair, Map<String, dynamic> message) {
    _client?.envoyerBrut({...message, 'from': _moi, 'to': pair});
  }

  Future<void> _connecter(String pair, {required bool initiateur, String? offre}) async {
    if (_connexions.containsKey(pair)) return;
    final micro = _micro;
    if (micro == null) return;
    _eventCtrl.add(GroupCallParticipantConnecting(pair));

    final pc = await createPeerConnection({
      'iceServers': _serveursIce,
      'sdpSemantics': 'unified-plan',
    });
    _connexions[pair] = pc;

    pc.onIceCandidate = (candidat) {
      final texte = candidat.candidate;
      if (texte == null || texte.isEmpty) return;
      _envoyer(pair, {
        'type': 'ice-candidate',
        ...CandidatIce(texte, sdpMid: candidat.sdpMid, sdpMLineIndex: candidat.sdpMLineIndex).versJson(),
      });
    };
    pc.onIceConnectionState = (etat) {
      switch (etat) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          _eventCtrl.add(GroupCallParticipantConnected(pair));
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          _eventCtrl.add(GroupCallParticipantFailed(pair));
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          _eventCtrl.add(GroupCallParticipantDisconnected(pair));
        default:
          // `Disconnected` est souvent passager (Wi-Fi ↔ 4G) : on attend.
          break;
      }
    };
    for (final piste in micro.getAudioTracks()) {
      await pc.addTrack(piste, micro);
    }

    if (initiateur) {
      final description = await pc.createOffer();
      await pc.setLocalDescription(description);
      _envoyer(pair, {'type': 'offer', 'sdp': description.sdp ?? ''});
    } else {
      await pc.setRemoteDescription(RTCSessionDescription(offre ?? '', 'offer'));
      await _descriptionEstPosee(pair);
      final reponse = await pc.createAnswer();
      await pc.setLocalDescription(reponse);
      _envoyer(pair, {'type': 'answer', 'sdp': reponse.sdp ?? ''});
    }
  }

  Future<void> _descriptionEstPosee(String pair) async {
    _descriptionPosee.add(pair);
    final pc = _connexions[pair];
    for (final c in _candidatsEnAttente.remove(pair)?.vider() ?? const <CandidatIce>[]) {
      try {
        await pc?.addCandidate(RTCIceCandidate(c.candidate, c.sdpMid, c.sdpMLineIndex));
      } catch (_) {}
    }
  }

  void _surMessage(Map<String, dynamic> message) {
    // La salle est partagée : seuls les messages adressés à MOI me concernent.
    if (message['to'] != _moi) return;
    final de = message['from'];
    if (de is! String || de.isEmpty || de == _moi) return;
    try {
      switch (message['type']) {
        case 'offer':
          final sdp = message['sdp'];
          if (sdp is String && !_connexions.containsKey(de)) {
            unawaited(_connecter(de, initiateur: false, offre: sdp).catchError((Object e) {
              debugPrint('[AppelGroupe] réponse à $de impossible: $e');
            }));
          }
        case 'answer':
          final sdp = message['sdp'];
          final pc = _connexions[de];
          if (sdp is String && pc != null) {
            unawaited(pc
                .setRemoteDescription(RTCSessionDescription(sdp, 'answer'))
                .then((_) => _descriptionEstPosee(de))
                .catchError((Object e) => debugPrint('[AppelGroupe] réponse de $de refusée: $e')));
          }
        case 'ice-candidate':
          if (message['ctrl'] == 'bye') {
            unawaited(_retirer(de, prevenir: false));
            return;
          }
          final candidat = CandidatIce.depuisMessage(message);
          if (candidat == null) return;
          final pc = _connexions[de];
          if (pc == null || !_descriptionPosee.contains(de)) {
            (_candidatsEnAttente[de] ??= FileCandidats()).ajouter(candidat);
          } else {
            unawaited(pc
                .addCandidate(RTCIceCandidate(candidat.candidate, candidat.sdpMid, candidat.sdpMLineIndex))
                .catchError((_) {}));
          }
      }
    } catch (e) {
      debugPrint('[AppelGroupe] message ignoré ($de): $e');
    }
  }

  void basculerMicro() {
    for (final piste in _micro?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      piste.enabled = !piste.enabled;
    }
  }

  Future<void> basculerHautParleur() async {
    _hautParleur = !_hautParleur;
    await Helper.setSpeakerphoneOn(_hautParleur);
  }

  Future<void> retirer(String pair) => _retirer(pair, prevenir: true);

  Future<void> _retirer(String pair, {required bool prevenir}) async {
    if (prevenir) _envoyer(pair, {'type': 'ice-candidate', 'ctrl': 'bye'});
    final pc = _connexions.remove(pair);
    _descriptionPosee.remove(pair);
    _candidatsEnAttente.remove(pair);
    try {
      await pc?.close();
    } catch (_) {}
    if (!_eventCtrl.isClosed) _eventCtrl.add(GroupCallParticipantDisconnected(pair));
  }

  /// Quitte l'appel : prévient chacun, ferme les connexions et le micro.
  Future<void> quitter() async {
    for (final pair in _connexions.keys.toList()) {
      _envoyer(pair, {'type': 'ice-candidate', 'ctrl': 'bye'});
      try {
        await _connexions.remove(pair)?.close();
      } catch (_) {}
    }
    _descriptionPosee.clear();
    _candidatsEnAttente.clear();
    await _bruts?.cancel();
    await _evenements?.cancel();
    final client = _client;
    _client = null;
    if (client != null) {
      client.leaveRoom();
      client.dispose();
    }
    for (final piste in _micro?.getTracks() ?? const <MediaStreamTrack>[]) {
      try {
        await piste.stop();
      } catch (_) {}
    }
    _micro = null;
  }
}
