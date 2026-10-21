// LES APPELS PAR INTERNET DEPUIS LE NAVIGATEUR — comme WhatsApp Web.
//
// Le téléphone attend ses appels dans une « boîte d'appels » du serveur
// d'appels : la salle `inbox_<son identifiant>`. Celui qui veut le joindre y
// entre et y dépose son offre WebRTC ; le serveur la relaie à tous ceux qui
// sont dans la salle.
//
// Droplet Web s'assied dans la MÊME salle, sous son propre identifiant
// d'appareil (signé avec SA clé, que le téléphone a déclarée en le liant), et
// avec `ecoute: true` : il n'est pas un appel, le serveur ne réveille
// personne. Une offre arrive : ça sonne ici ET sur le téléphone. Le premier
// qui décroche répond au nom du compte ; l'autre voit passer cette réponse et
// cesse de sonner (voir `CallService` dans l'app).
//
// Appeler depuis le navigateur, c'est l'inverse : entrer dans la boîte
// d'appels du contact et y déposer une offre au nom du compte. Chez le
// contact, rien ne change : c'est « vous » qui appelez.
//
// Le son et l'image vont directement d'un navigateur à l'autre appareil
// (DTLS-SRTP, chiffrés de bout en bout par WebRTC), par un relais TURN quand
// les réseaux ne se voient pas. Le serveur ne voit passer que la mise en
// relation.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'canal_telephone.dart';

/// Le serveur d'appels (signalisation + identifiants de relais).
const String kServeurAppels = 'https://droplet-server-production.up.railway.app';

enum PhaseAppel {
  /// Rien en cours.
  aucune,

  /// Un contact appelle : ça sonne.
  sonne,

  /// J'appelle : ça sonne chez lui.
  appel,

  /// Décroché, la liaison se monte.
  connexion,

  /// En communication.
  enCours,

  /// Terminé (l'écran affiche la raison un instant).
  fin,
}

enum FinAppel { raccroche, refuse, pasDeReponse, echec, telephone, microRefuse, occupe }

/// Une salle de signalisation : un WebSocket, une entrée signée.
class _Salle {
  _Salle(this.salle, this.canal, {required this.ecoute});

  final String salle;
  final CanalTelephone canal;
  final bool ecoute;
  web.WebSocket? _ws;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  void Function()? surFermeture;

  Stream<Map<String, dynamic>> get messages => _messages.stream;
  bool get ouverte => _ws?.readyState == 1;

  Future<bool> ouvrir() async {
    final base = Uri.parse(kServeurAppels);
    final url = base.replace(scheme: 'wss', path: '/ws/${Uri.encodeComponent(salle)}').toString();
    final pret = Completer<bool>();
    final ws = web.WebSocket(url);
    _ws = ws;
    ws.onopen = ((web.Event _) {
      if (!pret.isCompleted) pret.complete(true);
    }).toJS;
    ws.onerror = ((web.Event _) {
      if (!pret.isCompleted) pret.complete(false);
    }).toJS;
    ws.onclose = ((web.Event _) {
      if (!pret.isCompleted) pret.complete(false);
      if (identical(_ws, ws)) {
        _ws = null;
        surFermeture?.call();
      }
    }).toJS;
    ws.onmessage = ((web.MessageEvent e) {
      try {
        final d = e.data;
        if (d != null && d.isA<JSString>()) {
          final m = jsonDecode((d as JSString).toDart);
          if (m is Map) _messages.add(m.cast<String, dynamic>());
        }
      } catch (_) {}
    }).toJS;
    final ok = await pret.future.timeout(const Duration(seconds: 30), onTimeout: () => false);
    if (!ok) {
      fermer();
      return false;
    }
    final p = await canal.preuveSalle(salle);
    envoyer({
      'type': 'join',
      'peerId': canal.appareil,
      'ts': p.ts,
      'nonce': p.nonce,
      'sig': p.sig,
      // Le compte au nom duquel ce navigateur parle : le serveur le fait
      // confirmer par l'annuaire, puis refuse tout « from » non prouvé.
      'compte': canal.peerId,
      if (ecoute) 'ecoute': true,
    });
    return true;
  }

  void envoyer(Map<String, dynamic> m) {
    final ws = _ws;
    if (ws == null || ws.readyState != 1) return;
    ws.send(jsonEncode(m).toJS);
  }

  void fermer() {
    final ws = _ws;
    _ws = null;
    try {
      ws?.send(jsonEncode({'type': 'leave'}).toJS);
    } catch (_) {}
    try {
      ws?.close();
    } catch (_) {}
  }
}

/// Une vue `<video>` pour Flutter (`HtmlElementView`).
///
/// ⚠️ UN ÉLÉMENT NEUF À CHAQUE AFFICHAGE. Un `<video>` retiré de la page est
/// mis en pause par le navigateur ; réinséré (deuxième appel, écran rouvert),
/// il restait noir. Chaque vue reçoit donc son propre élément, branché sur le
/// flux du moment, et tous suivent les changements de flux.
class VueFlux {
  VueFlux({required this.miroir, required this.muet}) : typeVue = 'droplet-flux-${_n++}' {
    ui_web.platformViewRegistry.registerViewFactory(typeVue, (int _) {
      final v = web.HTMLVideoElement()
        ..autoplay = true
        ..muted = muet
        ..playsInline = true;
      v.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'cover'
        ..backgroundColor = 'transparent'
        ..borderRadius = 'inherit';
      if (miroir) v.style.transform = 'scaleX(-1)';
      _elements.removeWhere((e) => !e.isConnected);
      _elements.add(v);
      _brancher(v);
      return v;
    });
  }

  final String typeVue;
  final bool miroir;
  final bool muet;
  static int _n = 0;
  final List<web.HTMLVideoElement> _elements = [];
  web.MediaStream? _flux;

  void _brancher(web.HTMLVideoElement v) {
    v.srcObject = _flux;
    if (_flux != null) unawaited(v.play().toDart.then((_) {}, onError: (_) {}));
  }

  void afficher(web.MediaStream? flux) {
    _flux = flux;
    for (final v in _elements) {
      _brancher(v);
    }
  }
}

/// Les appels par Internet de ce navigateur.
class AppelsReseau extends ChangeNotifier {
  AppelsReseau({required this.canal});

  final CanalTelephone canal;

  String get _compte => canal.peerId;

  // ── État visible ───────────────────────────────────────────────────

  PhaseAppel phase = PhaseAppel.aucune;

  /// Le contact (identifiant) de l'appel en cours.
  String? contact;
  bool entrant = false;

  /// Appel vidéo (proposé ou en cours).
  bool video = false;
  DateTime? debut;
  FinAppel? fin;
  bool micro = true;
  bool camera = true;
  bool videoDistante = false;
  bool reconnexion = false;

  /// Appelé à la fin de chaque appel, pour le journal.
  void Function(String contact, {required bool entrant, required bool video, required int duree, required bool manque})? auJournal;

  /// Appelé quand un appel entrant commence à sonner.
  void Function(String contact, bool video)? auSonne;

  final VueFlux vueLocale = VueFlux(miroir: true, muet: true);
  final VueFlux vueDistante = VueFlux(miroir: false, muet: false);

  // ── Machinerie ─────────────────────────────────────────────────────

  _Salle? _boite;
  _Salle? _sortante;
  int _essais = 0;
  Timer? _reconnexionBoite;
  bool _actif = false;

  web.RTCPeerConnection? _pc;
  web.MediaStream? _local;
  String? _offreEnAttente;
  String? _offreAppliquee;
  bool _distantePosee = false;
  final List<Map<String, dynamic>> _candidatsEnAttente = [];
  Timer? _renvoi;
  Timer? _delai;
  Timer? _sonnerie;
  List<Map<String, dynamic>>? _serveursIce;
  DateTime? _dateServeursIce;

  /// Entrer, pour de bon, dans la boîte d'appels du téléphone.
  ///
  /// ⚠️ SEULEMENT SI LE SERVEUR SAIT « ÉCOUTER ». Un serveur d'appels plus
  /// ancien prend l'entrée du navigateur dans la boîte du téléphone pour un
  /// appel, et réveille le téléphone (« Quelqu'un essaie de vous joindre ») à
  /// chaque connexion. On le lui demande d'abord (`/health`), et on réessaie
  /// toutes les 10 minutes : l'écoute s'allume d'elle-même une fois le
  /// serveur à jour. Appeler, lui, marche dans tous les cas.
  void demarrer() {
    if (_actif) return;
    _actif = true;
    unawaited(_attendreServeurQuiEcoute());
  }

  bool ecouteDisponible = false;

  Future<void> _attendreServeurQuiEcoute() async {
    while (_actif) {
      try {
        final r = await requete('GET', '$kServeurAppels/health', delai: const Duration(seconds: 12));
        if (r.ok) {
          final f = (jsonDecode(r.corps) as Map)['fonctions'];
          if (f is List && f.contains('ecoute')) {
            ecouteDisponible = true;
            notifyListeners();
            await _ouvrirBoite();
            return;
          }
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(minutes: 10));
    }
  }

  Future<void> _ouvrirBoite() async {
    if (!_actif) return;
    final b = _Salle('inbox_$_compte', canal, ecoute: true);
    _boite = b;
    b.messages.listen((m) => _recu(m, depuisBoite: true));
    b.surFermeture = _reprogrammer;
    if (await b.ouvrir()) {
      _essais = 0;
      unawaited(_iceServeurs());
    } else {
      _reprogrammer();
    }
  }

  void _reprogrammer() {
    if (!_actif) return;
    const delais = [2, 4, 8, 15, 30];
    final d = delais[_essais.clamp(0, delais.length - 1)];
    _essais++;
    _reconnexionBoite?.cancel();
    _reconnexionBoite = Timer(Duration(seconds: d), () {
      if (_boite?.ouverte ?? false) return;
      unawaited(_ouvrirBoite());
    });
  }

  void arreter() {
    _actif = false;
    _reconnexionBoite?.cancel();
    _boite?.fermer();
    _boite = null;
    unawaited(_terminer(FinAppel.raccroche, prevenir: true));
  }

  // ── Les messages ───────────────────────────────────────────────────

  void _recu(Map<String, dynamic> m, {required bool depuisBoite}) {
    final type = m['type'];
    final de = m['from'];
    final a = m['to'];
    switch (type) {
      case 'offer':
        if (de is! String || a != _compte) return;
        final sdp = m['sdp'];
        if (sdp is! String) return;
        final proposeVideo = m['video'] is bool ? m['video'] as bool : sdp.contains('m=video');
        // Renégociation en cours d'appel (l'autre allume sa caméra).
        if (de == contact && _pc != null && _distantePosee) {
          if (sdp != _offreAppliquee) unawaited(_repondreRenegociation(sdp));
          return;
        }
        if (!depuisBoite) return;
        if (phase == PhaseAppel.sonne && de == contact) {
          _offreEnAttente = sdp; // offre renvoyée, identique ou rafraîchie
          return;
        }
        if (phase != PhaseAppel.aucune && phase != PhaseAppel.fin) return; // déjà en appel
        _sonner(de, sdp, proposeVideo);
      case 'answer':
        if (de is! String) return;
        // Le téléphone a décroché (il répond au nom du compte, comme nous).
        if (depuisBoite && de == _compte && phase == PhaseAppel.sonne) {
          unawaited(_terminer(FinAppel.telephone, prevenir: false));
          return;
        }
        if (de == contact && a == _compte && !entrant) {
          final sdp = m['sdp'];
          if (sdp is String) unawaited(_appliquerReponse(sdp));
        }
      case 'ice-candidate':
        if (de is! String) return;
        final ctrl = m['ctrl'];
        if (ctrl is String) {
          final concerne = de == contact || (depuisBoite && de == _compte && phase == PhaseAppel.sonne);
          if (!concerne) return;
          switch (ctrl) {
            case 'bye':
              unawaited(_terminer(de == _compte ? FinAppel.telephone : (phase == PhaseAppel.appel ? FinAppel.refuse : FinAppel.raccroche), prevenir: false));
            case 'cam-on':
            case 'cam-off':
              videoDistante = ctrl == 'cam-on';
              notifyListeners();
          }
          return;
        }
        if (de != contact || a != _compte) return;
        final c = {
          'candidate': m['candidate'],
          if (m['sdpMid'] != null) 'sdpMid': m['sdpMid'],
          if (m['sdpMLineIndex'] != null) 'sdpMLineIndex': m['sdpMLineIndex'],
        };
        if (c['candidate'] is! String || (c['candidate'] as String).isEmpty) return;
        if (_pc != null && _distantePosee) {
          unawaited(_ajouterCandidat(c));
        } else {
          _candidatsEnAttente.add(c);
        }
      case 'peer-left':
        final qui = m['peerId'];
        // L'appelant a quitté la boîte avant qu'on décroche.
        if (qui == contact && phase == PhaseAppel.sonne) {
          unawaited(_terminer(FinAppel.pasDeReponse, prevenir: false, manque: true));
        }
      case 'error':
        if (!depuisBoite && phase == PhaseAppel.appel) unawaited(_terminer(FinAppel.echec, prevenir: false));
    }
  }

  // ── Entrant ────────────────────────────────────────────────────────

  void _sonner(String de, String sdp, bool proposeVideo) {
    _remettreAZero();
    contact = de;
    entrant = true;
    video = proposeVideo;
    camera = proposeVideo;
    _offreEnAttente = sdp;
    phase = PhaseAppel.sonne;
    notifyListeners();
    _jouerSonnerie();
    auSonne?.call(de, proposeVideo);
    // Personne ne décroche : appel manqué au bout d'une minute.
    _delai = Timer(const Duration(seconds: 60), () {
      if (phase == PhaseAppel.sonne) unawaited(_terminer(FinAppel.pasDeReponse, prevenir: false, manque: true));
    });
  }

  /// Décrocher, en vocal ou en vidéo.
  Future<void> decrocher({bool? avecVideo}) async {
    final offre = _offreEnAttente;
    final de = contact;
    if (phase != PhaseAppel.sonne || offre == null || de == null) return;
    _arreterSonnerie();
    _delai?.cancel();
    video = avecVideo ?? video;
    camera = video;
    phase = PhaseAppel.connexion;
    notifyListeners();
    try {
      if (!await _ouvrirMedias()) {
        await _terminer(FinAppel.microRefuse, prevenir: true);
        return;
      }
      final pc = await _creerConnexion(de);
      await pc.setRemoteDescription(web.RTCSessionDescriptionInit(type: 'offer', sdp: offre)).toDart;
      _distantePosee = true;
      _offreAppliquee = offre;
      await _viderCandidats();
      await pc.setLocalDescription().toDart;
      await _attendreCollecte(const Duration(milliseconds: 900));
      final sdp = pc.localDescription?.sdp ?? '';
      // Répondu AU NOM DU COMPTE : l'appelant attend la réponse du compte.
      _boite?.envoyer({'type': 'answer', 'from': _compte, 'to': de, 'sdp': sdp});
      if (_dejaRelie) {
        _relie();
        return;
      }
      _delai = Timer(const Duration(seconds: 30), () {
        if (phase == PhaseAppel.connexion && !_dejaRelie) unawaited(_terminer(FinAppel.echec, prevenir: true));
      });
    } catch (e) {
      debugPrint('Droplet Web : décrocher impossible ($e)');
      await _terminer(FinAppel.echec, prevenir: true);
    }
  }

  /// Refuser l'appel qui sonne : il cesse aussi de sonner sur le téléphone.
  Future<void> refuser() => _terminer(FinAppel.refuse, prevenir: true, manque: false);

  // ── Sortant ────────────────────────────────────────────────────────

  /// Appeler [peerId] (l'identifiant du contact).
  Future<void> appeler(String peerId, {required bool avecVideo}) async {
    if (phase != PhaseAppel.aucune && phase != PhaseAppel.fin) return;
    _remettreAZero();
    contact = peerId;
    entrant = false;
    video = avecVideo;
    camera = avecVideo;
    phase = PhaseAppel.appel;
    notifyListeners();
    try {
      if (!await _ouvrirMedias()) {
        await _terminer(FinAppel.microRefuse, prevenir: false);
        return;
      }
      final salle = _Salle('inbox_$peerId', canal, ecoute: false);
      _sortante = salle;
      salle.messages.listen((m) => _recu(m, depuisBoite: false));
      if (!await salle.ouvrir()) {
        await _terminer(FinAppel.echec, prevenir: false);
        return;
      }
      final pc = await _creerConnexion(peerId);
      await pc.setLocalDescription().toDart;
      await _attendreCollecte(const Duration(seconds: 3));
      final sdp = pc.localDescription?.sdp ?? '';
      void deposer() => _sortante?.envoyer({'type': 'offer', 'from': _compte, 'to': peerId, 'sdp': sdp, 'video': avecVideo});
      deposer();
      // L'autre téléphone dort peut-être : le serveur le réveille, et on
      // redépose l'offre jusqu'à ce qu'il réponde.
      _renvoi = Timer.periodic(const Duration(seconds: 3), (_) {
        if (phase == PhaseAppel.appel) deposer();
      });
      _delai = Timer(const Duration(seconds: 45), () {
        if (phase == PhaseAppel.appel) unawaited(_terminer(FinAppel.pasDeReponse, prevenir: true));
      });
    } catch (e) {
      debugPrint('Droplet Web : appel impossible ($e)');
      await _terminer(FinAppel.echec, prevenir: false);
    }
  }

  Future<void> _appliquerReponse(String sdp) async {
    final pc = _pc;
    if (pc == null || _distantePosee) return;
    try {
      await pc.setRemoteDescription(web.RTCSessionDescriptionInit(type: 'answer', sdp: sdp)).toDart;
      _distantePosee = true;
      _renvoi?.cancel();
      _delai?.cancel();
      if (phase == PhaseAppel.appel) phase = PhaseAppel.connexion;
      notifyListeners();
      await _viderCandidats();
      if (_dejaRelie) {
        _relie();
        return;
      }
      _delai = Timer(const Duration(seconds: 30), () {
        if (phase == PhaseAppel.connexion && !_dejaRelie) unawaited(_terminer(FinAppel.echec, prevenir: true));
      });
    } catch (e) {
      debugPrint('Droplet Web : réponse refusée ($e)');
    }
  }

  Future<void> _repondreRenegociation(String sdp) async {
    final pc = _pc;
    final de = contact;
    if (pc == null || de == null) return;
    try {
      await pc.setRemoteDescription(web.RTCSessionDescriptionInit(type: 'offer', sdp: sdp)).toDart;
      _offreAppliquee = sdp;
      await pc.setLocalDescription().toDart;
      _salleActive?.envoyer({'type': 'answer', 'from': _compte, 'to': de, 'sdp': pc.localDescription?.sdp ?? ''});
    } catch (e) {
      debugPrint('Droplet Web : renégociation impossible ($e)');
    }
  }

  /// La salle par laquelle l'appel en cours parle à l'autre.
  _Salle? get _salleActive => entrant ? _boite : _sortante;

  // ── Pendant l'appel ────────────────────────────────────────────────

  void basculerMicro() {
    micro = !micro;
    for (final p in _local?.getAudioTracks().toDart ?? const <web.MediaStreamTrack>[]) {
      p.enabled = micro;
    }
    notifyListeners();
  }

  void basculerCamera() {
    final pistes = _local?.getVideoTracks().toDart ?? const <web.MediaStreamTrack>[];
    if (pistes.isEmpty) return;
    camera = !camera;
    for (final p in pistes) {
      p.enabled = camera;
    }
    final de = contact;
    if (de != null) _envoyerCtrl(de, camera ? 'cam-on' : 'cam-off');
    notifyListeners();
  }

  Future<void> raccrocher() => _terminer(FinAppel.raccroche, prevenir: true);

  void _envoyerCtrl(String a, String ctrl) {
    _salleActive?.envoyer({'type': 'ice-candidate', 'from': _compte, 'to': a, 'ctrl': ctrl});
  }

  bool get aVideoLocale => (_local?.getVideoTracks().toDart ?? const []).isNotEmpty;

  // ── WebRTC ─────────────────────────────────────────────────────────

  Future<bool> _ouvrirMedias() async {
    try {
      final contraintes = web.MediaStreamConstraints(
        audio: {'echoCancellation': true, 'noiseSuppression': true, 'autoGainControl': true}.jsify()!,
        video: video ? {'width': {'ideal': 1280}, 'height': {'ideal': 720}, 'facingMode': 'user'}.jsify()! : false.toJS,
      );
      _local = await web.window.navigator.mediaDevices.getUserMedia(contraintes).toDart;
    } catch (e) {
      debugPrint('Droplet Web : micro/caméra indisponibles ($e)');
      if (!video) return false;
      // Pas de caméra : on tente en vocal plutôt que d'abandonner.
      try {
        video = false;
        camera = false;
        _local = await web.window.navigator.mediaDevices.getUserMedia(web.MediaStreamConstraints(audio: true.toJS)).toDart;
      } catch (_) {
        return false;
      }
    }
    vueLocale.afficher(_local);
    notifyListeners();
    return true;
  }

  Future<web.RTCPeerConnection> _creerConnexion(String autre) async {
    final serveurs = await _iceServeurs();
    final config = {'iceServers': serveurs, 'bundlePolicy': 'max-bundle'}.jsify()! as web.RTCConfiguration;
    final pc = web.RTCPeerConnection(config);
    _pc = pc;
    final local = _local!;
    for (final p in local.getTracks().toDart) {
      (pc as JSObject).callMethod('addTrack'.toJS, p, local);
    }
    pc.onicecandidate = ((web.RTCPeerConnectionIceEvent e) {
      final c = e.candidate;
      if (c == null || c.candidate.isEmpty) return;
      _salleActive?.envoyer({
        'type': 'ice-candidate',
        'from': _compte,
        'to': autre,
        'candidate': c.candidate,
        if (c.sdpMid != null) 'sdpMid': c.sdpMid,
        if (c.sdpMLineIndex != null) 'sdpMLineIndex': c.sdpMLineIndex,
      });
    }).toJS;
    pc.ontrack = ((web.RTCTrackEvent e) {
      final flux = e.streams.toDart;
      final f = flux.isNotEmpty ? flux.first : web.MediaStream([e.track].toJS);
      vueDistante.afficher(f);
      videoDistante = f.getVideoTracks().toDart.isNotEmpty;
      notifyListeners();
    }).toJS;
    pc.oniceconnectionstatechange = ((web.Event _) {
      final etat = pc.iceConnectionState;
      switch (etat) {
        case 'connected':
        case 'completed':
          _relie();
        case 'disconnected':
          reconnexion = true;
          notifyListeners();
        case 'failed':
          unawaited(_terminer(FinAppel.echec, prevenir: true));
      }
    }).toJS;
    return pc;
  }

  /// La liaison est établie. Elle peut l'être AVANT que la réponse de
  /// l'autre ait fini d'être traitée ici : on passe alors en communication
  /// depuis « appel » aussi, sinon l'écran restait sur « Connexion… » et le
  /// délai de connexion finissait par couper un appel qui marchait.
  void _relie() {
    _delai?.cancel();
    reconnexion = false;
    if (phase == PhaseAppel.connexion || phase == PhaseAppel.appel) {
      phase = PhaseAppel.enCours;
      debut ??= DateTime.now();
      _renvoi?.cancel();
    }
    notifyListeners();
  }

  bool get _dejaRelie {
    final e = _pc?.iceConnectionState;
    return e == 'connected' || e == 'completed';
  }

  Future<void> _attendreCollecte(Duration max) async {
    final pc = _pc;
    if (pc == null) return;
    final fin = DateTime.now().add(max);
    while (pc.iceGatheringState != 'complete' && DateTime.now().isBefore(fin)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _ajouterCandidat(Map<String, dynamic> c) async {
    try {
      await _pc?.addIceCandidate(c.jsify()! as web.RTCIceCandidateInit).toDart;
    } catch (_) {}
  }

  Future<void> _viderCandidats() async {
    final tout = List.of(_candidatsEnAttente);
    _candidatsEnAttente.clear();
    for (final c in tout) {
      await _ajouterCandidat(c);
    }
  }

  /// Les serveurs ICE (STUN + relais TURN Cloudflare), gardés deux heures.
  Future<List<Map<String, dynamic>>> _iceServeurs() async {
    final deja = _serveursIce;
    if (deja != null && _dateServeursIce != null && DateTime.now().difference(_dateServeursIce!) < const Duration(hours: 2)) {
      return deja;
    }
    final liste = <Map<String, dynamic>>[];
    try {
      final r = await requete('POST', '$kServeurAppels/turn/credentials',
          entetes: {'content-type': 'application/json'}, corps: jsonEncode({'peerId': canal.appareil}), delai: const Duration(seconds: 12));
      if (r.ok) {
        final brut = (jsonDecode(r.corps) as Map)['iceServers'];
        for (final e in (brut is List ? brut : brut is Map ? [brut] : const [])) {
          if (e is! Map) continue;
          final urls = e['urls'];
          final l = (urls is String ? [urls] : urls is List ? urls : const []).whereType<String>().where((u) => !RegExp(r':53(\?|$)').hasMatch(u)).toList();
          if (l.isEmpty) continue;
          liste.add({
            'urls': l,
            if (e['username'] is String) 'username': e['username'],
            if (e['credential'] is String) 'credential': e['credential'],
          });
        }
      }
    } catch (_) {}
    if (!liste.any((s) => (s['urls'] as List).any((u) => (u as String).startsWith('stun:')))) {
      liste.insert(0, {'urls': ['stun:stun.cloudflare.com:3478', 'stun:stun.l.google.com:19302']});
    }
    if (liste.length > 1) {
      _serveursIce = liste;
      _dateServeursIce = DateTime.now();
    }
    return liste;
  }

  // ── Fin ────────────────────────────────────────────────────────────

  Future<void> _terminer(FinAppel raison, {required bool prevenir, bool manque = false}) async {
    if (phase == PhaseAppel.aucune || phase == PhaseAppel.fin) return;
    final de = contact;
    if (prevenir && de != null) {
      _envoyerCtrl(de, 'bye');
      // Refusé ici : le téléphone, qui sonne aussi, doit se taire (il voit
      // passer ce « bye » au nom du compte dans sa propre boîte).
    }
    final duree = debut == null ? 0 : DateTime.now().difference(debut!).inSeconds;
    final etaitEntrant = entrant;
    final etaitVideo = video;
    _arreterSonnerie();
    _renvoi?.cancel();
    _delai?.cancel();
    try {
      _pc?.close();
    } catch (_) {}
    _pc = null;
    for (final p in _local?.getTracks().toDart ?? const <web.MediaStreamTrack>[]) {
      p.stop();
    }
    _local = null;
    vueLocale.afficher(null);
    vueDistante.afficher(null);
    _sortante?.fermer();
    _sortante = null;
    fin = raison;
    phase = PhaseAppel.fin;
    notifyListeners();
    // Décroché sur le téléphone : l'appel se poursuit là-bas, rien à noter ici.
    if (de != null && raison != FinAppel.telephone) {
      auJournal?.call(de, entrant: etaitEntrant, video: etaitVideo, duree: duree, manque: manque);
    }
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (phase == PhaseAppel.fin) {
      phase = PhaseAppel.aucune;
      contact = null;
      notifyListeners();
    }
  }

  void _remettreAZero() {
    debut = null;
    fin = null;
    micro = true;
    videoDistante = false;
    reconnexion = false;
    _offreEnAttente = null;
    _offreAppliquee = null;
    _distantePosee = false;
    _candidatsEnAttente.clear();
  }

  // ── La sonnerie ────────────────────────────────────────────────────
  //
  // Deux notes douces toutes les trois secondes, synthétisées : aucun
  // fichier à charger. Un navigateur qui n'a encore reçu aucun clic peut
  // la refuser ; la notification et le bandeau restent.

  web.AudioContext? _audio;

  void _jouerSonnerie() {
    _arreterSonnerie();
    void sonner() {
      try {
        final ctx = _audio ??= web.AudioContext();
        final t = ctx.currentTime;
        for (final (i, f) in [(0, 880.0), (1, 660.0)]) {
          final o = ctx.createOscillator();
          final g = ctx.createGain();
          o.frequency.value = f;
          o.type = 'sine';
          final debutNote = t + i * 0.42;
          g.gain.setValueAtTime(0, debutNote);
          g.gain.linearRampToValueAtTime(0.18, debutNote + 0.03);
          g.gain.exponentialRampToValueAtTime(0.001, debutNote + 0.38);
          o.connect(g);
          g.connect(ctx.destination);
          o.start(debutNote);
          o.stop(debutNote + 0.4);
        }
      } catch (_) {}
    }

    sonner();
    _sonnerie = Timer.periodic(const Duration(seconds: 3), (_) => sonner());
  }

  void _arreterSonnerie() {
    _sonnerie?.cancel();
    _sonnerie = null;
  }

  @override
  void dispose() {
    arreter();
    super.dispose();
  }
}
