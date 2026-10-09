// LE NAVIGATEUR — tout ce que Droplet Web demande à la page web.
//
// Ce que l'app fait avec les API du téléphone, la version web le fait avec
// celles du navigateur, réunies ici pour que les écrans n'en sachent rien :
//
//   • choisir des fichiers (photos, documents) et les lire ;
//   • glisser-déposer et coller des fichiers dans une discussion ;
//   • enregistrer un vocal au micro, avec son onde ;
//   • lire un son, un vocal ;
//   • afficher une notification du système ;
//   • télécharger une pièce jointe ;
//   • montrer la caméra pendant un appel vidéo ;
//   • le titre de l'onglet, avec le nombre de messages non lus.
import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../donnees/modeles.dart';

class Navigateur {
  Navigateur._();

  // ══ FICHIERS ══════════════════════════════════════════════════════════

  /// Ouvre le sélecteur de fichiers du système. [accepter] suit la syntaxe
  /// HTML (`image/*`, `.pdf`…). Rend les pièces lues, prêtes à envoyer.
  static Future<List<PieceJointe>> choisirFichiers({String accepter = '*/*', bool plusieurs = true}) {
    final fini = Completer<List<PieceJointe>>();
    final champ = web.document.createElement('input') as web.HTMLInputElement
      ..type = 'file'
      ..accept = accepter
      ..multiple = plusieurs;
    champ.addEventListener(
      'change',
      ((web.Event _) {
        final liste = champ.files;
        if (liste == null) {
          fini.complete(const []);
        } else {
          lireListe(liste).then(fini.complete);
        }
      }).toJS,
    );
    // Annulation : le navigateur prévient (Chrome, Firefox récents).
    champ.addEventListener(
      'cancel',
      ((web.Event _) {
        if (!fini.isCompleted) fini.complete(const []);
      }).toJS,
    );
    champ.click();
    return fini.future;
  }

  static Future<List<PieceJointe>> lireListe(web.FileList liste) async {
    final pieces = <PieceJointe>[];
    for (var i = 0; i < liste.length; i++) {
      final f = liste.item(i);
      if (f != null) pieces.add(await lireFichier(f));
    }
    return pieces;
  }

  static Future<PieceJointe> lireFichier(web.File f) async {
    final url = await _lireDataUrl(f);
    int? largeur, hauteur;
    if (f.type.startsWith('image/')) {
      final taille = await tailleImage(url);
      largeur = taille?.$1;
      hauteur = taille?.$2;
    }
    return PieceJointe(
      nom: f.name,
      mime: f.type.isEmpty ? 'application/octet-stream' : f.type,
      taille: f.size,
      url: url,
      largeur: largeur,
      hauteur: hauteur,
    );
  }

  static Future<String> _lireDataUrl(web.Blob blob) {
    final fini = Completer<String>();
    final lecteur = web.FileReader();
    lecteur.addEventListener(
      'load',
      ((web.Event _) => fini.complete((lecteur.result.dartify() as String?) ?? '')).toJS,
    );
    lecteur.addEventListener(
      'error',
      ((web.Event _) => fini.complete('')).toJS,
    );
    lecteur.readAsDataURL(blob);
    return fini.future;
  }

  static Future<(int, int)?> tailleImage(String url) {
    final fini = Completer<(int, int)?>();
    final image = web.HTMLImageElement();
    image.addEventListener(
      'load',
      ((web.Event _) => fini.complete((image.naturalWidth, image.naturalHeight))).toJS,
    );
    image.addEventListener('error', ((web.Event _) => fini.complete(null)).toJS);
    image.src = url;
    return fini.future;
  }

  /// Télécharge une pièce jointe sous son nom.
  static void telecharger(PieceJointe p) {
    final lien = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = p.url
      ..download = p.nom;
    web.document.body?.append(lien);
    lien.click();
    lien.remove();
  }

  /// Ouvre une adresse dans un nouvel onglet.
  static void ouvrir(String adresse) => web.window.open(adresse, '_blank');

  // ══ GLISSER-DÉPOSER ET COLLER ═════════════════════════════════════════

  static final _deposes = StreamController<List<PieceJointe>>.broadcast();
  static final survolDepot = ValueNotifier<bool>(false);
  static bool _ecoute = false;

  /// Les fichiers lâchés sur la page ou collés (Ctrl+V d'une capture).
  static Stream<List<PieceJointe>> get deposes {
    if (!_ecoute) _ecouter();
    return _deposes.stream;
  }

  static void _ecouter() {
    _ecoute = true;
    var profondeur = 0;
    bool avecFichiers(web.DragEvent e) {
      final types = e.dataTransfer?.types.toDart ?? const [];
      return types.any((t) => t.toDart == 'Files');
    }

    web.document.addEventListener(
      'dragenter',
      ((web.DragEvent e) {
        if (!avecFichiers(e)) return;
        e.preventDefault();
        profondeur++;
        survolDepot.value = true;
      }).toJS,
    );
    web.document.addEventListener(
      'dragover',
      ((web.DragEvent e) {
        if (avecFichiers(e)) e.preventDefault();
      }).toJS,
    );
    web.document.addEventListener(
      'dragleave',
      ((web.DragEvent e) {
        profondeur = max(0, profondeur - 1);
        if (profondeur == 0) survolDepot.value = false;
      }).toJS,
    );
    web.document.addEventListener(
      'drop',
      ((web.DragEvent e) {
        e.preventDefault();
        profondeur = 0;
        survolDepot.value = false;
        final liste = e.dataTransfer?.files;
        if (liste == null || liste.length == 0) return;
        lireListe(liste).then(_deposes.add);
      }).toJS,
    );
    web.document.addEventListener(
      'paste',
      ((web.ClipboardEvent e) {
        final liste = e.clipboardData?.files;
        if (liste == null || liste.length == 0) return;
        lireListe(liste).then(_deposes.add);
      }).toJS,
    );
  }

  // ══ ONGLET ═════════════════════════════════════════════════════════════

  /// « (3) Droplet Web » : le nombre de non-lus dans le titre de l'onglet,
  /// comme WhatsApp Web.
  static void titre(int nonLus) {
    web.document.title = nonLus > 0 ? '($nonLus) Droplet Web' : 'Droplet Web';
  }

  static String get nomAppareil {
    final ua = web.window.navigator.userAgent;
    final navigateur = ua.contains('Edg/')
        ? 'Edge'
        : ua.contains('Firefox/')
            ? 'Firefox'
            : ua.contains('Chrome/')
                ? 'Chrome'
                : ua.contains('Safari/')
                    ? 'Safari'
                    : 'Navigateur';
    final systeme = ua.contains('Mac OS')
        ? 'macOS'
        : ua.contains('Windows')
            ? 'Windows'
            : ua.contains('Android')
                ? 'Android'
                : ua.contains('Linux')
                    ? 'Linux'
                    : ua.contains('CrOS')
                        ? 'ChromeOS'
                        : '';
    return systeme.isEmpty ? navigateur : '$navigateur · $systeme';
  }

  static bool get estMac => web.window.navigator.userAgent.contains('Mac OS');

  // ══ NOTIFICATIONS ET SONS ══════════════════════════════════════════════

  static String get permissionNotifications {
    try {
      return web.Notification.permission;
    } catch (_) {
      return 'unsupported';
    }
  }

  static Future<bool> demanderNotifications() async {
    try {
      final r = await web.Notification.requestPermission().toDart;
      return r.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  /// Une notification du système, seulement si l'onglet n'est pas visible.
  static void notifier(String titre, String corps, {VoidCallback? auClic}) {
    if (permissionNotifications != 'granted') return;
    if (web.document.visibilityState == 'visible' && web.document.hasFocus()) return;
    try {
      final n = web.Notification(
        titre,
        web.NotificationOptions(body: corps, icon: 'favicon.svg', silent: true),
      );
      n.addEventListener(
        'click',
        ((web.Event _) {
          web.window.focus();
          auClic?.call();
          n.close();
        }).toJS,
      );
    } catch (_) {}
  }

  static web.AudioContext? _audio;

  /// Le petit « ploc » d'un message reçu : deux notes douces, synthétisées
  /// (aucun fichier son à charger).
  static void ploc({bool envoi = false}) {
    try {
      final ctx = _audio ??= web.AudioContext();
      final t = ctx.currentTime;
      for (final (i, f) in (envoi ? const [660.0, 990.0] : const [880.0, 1320.0]).indexed) {
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.value = f;
        final debut = t + i * 0.07;
        gain.gain.setValueAtTime(0.0001, debut);
        gain.gain.exponentialRampToValueAtTime(envoi ? 0.05 : 0.09, debut + 0.015);
        gain.gain.exponentialRampToValueAtTime(0.0001, debut + 0.22);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(debut);
        osc.stop(debut + 0.25);
      }
    } catch (_) {}
  }

  // ══ VOCAUX ═════════════════════════════════════════════════════════════

  static Future<Enregistreur?> enregistrer() async {
    try {
      final flux = await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart;
      return Enregistreur._(flux);
    } catch (e) {
      debugPrint('Droplet Web : micro indisponible ($e)');
      return null;
    }
  }

  // ══ CAMÉRA ═════════════════════════════════════════════════════════════

  static int _vues = 0;

  /// Ouvre la caméra (et le micro) pour un appel. Rend le type de vue à
  /// donner à `HtmlElementView`, et de quoi tout couper.
  static Future<Camera?> camera({required bool video}) async {
    try {
      final flux = await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS, video: video.toJS))
          .toDart;
      final type = 'droplet-camera-${_vues++}';
      final element = web.document.createElement('video') as web.HTMLVideoElement
        ..autoplay = true
        ..muted = true
        ..srcObject = flux;
      element.setAttribute('playsinline', 'true');
      element.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'cover'
        ..transform = 'scaleX(-1)'
        ..borderRadius = 'inherit';
      ui_web.platformViewRegistry.registerViewFactory(type, (int _) => element);
      return Camera._(flux, type);
    } catch (e) {
      debugPrint('Droplet Web : caméra indisponible ($e)');
      return null;
    }
  }
}

/// Un enregistrement de vocal en cours.
class Enregistreur {
  Enregistreur._(this._flux) {
    _enregistreur = web.MediaRecorder(_flux);
    _enregistreur.addEventListener(
      'dataavailable',
      ((web.BlobEvent e) => _morceaux.add(e.data)).toJS,
    );
    _enregistreur.start();
    _debut = DateTime.now();
    try {
      final ctx = web.AudioContext();
      _ctx = ctx;
      final source = ctx.createMediaStreamSource(_flux);
      final analyseur = ctx.createAnalyser()..fftSize = 256;
      source.connect(analyseur);
      final tampon = Uint8List(analyseur.fftSize);
      final js = tampon.toJS;
      _mesure = Timer.periodic(const Duration(milliseconds: 90), (_) {
        analyseur.getByteTimeDomainData(js);
        final octets = js.toDart;
        var crete = 0.0;
        for (final o in octets) {
          crete = max(crete, (o - 128).abs() / 128);
        }
        onde.add(crete.clamp(0.04, 1.0));
        niveau.value = crete;
      });
    } catch (_) {}
  }

  final web.MediaStream _flux;
  late final web.MediaRecorder _enregistreur;
  final List<web.Blob> _morceaux = [];
  late final DateTime _debut;
  web.AudioContext? _ctx;
  Timer? _mesure;

  /// L'onde, une valeur toutes les 90 ms.
  final List<double> onde = [];
  final ValueNotifier<double> niveau = ValueNotifier(0);

  Duration get duree => DateTime.now().difference(_debut);

  /// Arrête et rend le vocal (ou rien si [annuler]).
  Future<PieceJointe?> arreter({bool annuler = false}) async {
    final fini = Completer<void>();
    _enregistreur.addEventListener('stop', ((web.Event _) => fini.complete()).toJS);
    final dureeMs = duree.inMilliseconds;
    try {
      _enregistreur.stop();
    } catch (_) {
      fini.complete();
    }
    await fini.future.timeout(const Duration(seconds: 2), onTimeout: () {});
    _mesure?.cancel();
    for (final piste in _flux.getTracks().toDart) {
      piste.stop();
    }
    try {
      _ctx?.close();
    } catch (_) {}
    if (annuler || _morceaux.isEmpty) return null;
    final mime = _enregistreur.mimeType.isEmpty ? 'audio/webm' : _enregistreur.mimeType;
    final blob = web.Blob(_morceaux.toJS, web.BlobPropertyBag(type: mime));
    final url = await Navigateur._lireDataUrl(blob);
    return PieceJointe(
      nom: 'vocal.${mime.contains('ogg') ? 'ogg' : mime.contains('mp4') ? 'm4a' : 'webm'}',
      mime: mime,
      taille: blob.size,
      url: url,
      dureeMs: dureeMs,
      onde: _reduire(onde, 48),
    );
  }

  /// L'onde ramenée à [n] barres, pour la bulle.
  static List<double> _reduire(List<double> v, int n) {
    if (v.isEmpty) return List.filled(n, 0.08);
    return List.generate(n, (i) {
      final a = (i * v.length / n).floor();
      final b = max(a + 1, ((i + 1) * v.length / n).floor());
      var m = 0.0;
      for (var k = a; k < b && k < v.length; k++) {
        m = max(m, v[k]);
      }
      return m;
    });
  }
}

/// Un vocal qu'on écoute.
class Lecteur {
  Lecteur(String url) : _audio = web.HTMLAudioElement() {
    _audio.src = url;
    _audio.addEventListener('timeupdate', ((web.Event _) => _maj()).toJS);
    _audio.addEventListener('ended', ((web.Event _) {
      enCours.value = false;
      position.value = 0;
    }).toJS);
  }

  final web.HTMLAudioElement _audio;
  final ValueNotifier<bool> enCours = ValueNotifier(false);

  /// De 0 à 1.
  final ValueNotifier<double> position = ValueNotifier(0);

  void _maj() {
    final d = _audio.duration;
    if (d.isFinite && d > 0) position.value = _audio.currentTime / d;
  }

  void basculer() {
    if (enCours.value) {
      _audio.pause();
      enCours.value = false;
    } else {
      _audio.play();
      enCours.value = true;
    }
  }

  void aller(double fraction) {
    final d = _audio.duration;
    if (d.isFinite && d > 0) _audio.currentTime = d * fraction;
  }

  set vitesse(double v) => _audio.playbackRate = v;

  void liberer() {
    _audio.pause();
    _audio.src = '';
  }
}

/// La caméra d'un appel.
class Camera {
  Camera._(this._flux, this.typeVue);

  final web.MediaStream _flux;
  final String typeVue;

  void micro(bool actif) {
    for (final p in _flux.getAudioTracks().toDart) {
      p.enabled = actif;
    }
  }

  void video(bool active) {
    for (final p in _flux.getVideoTracks().toDart) {
      p.enabled = active;
    }
  }

  bool get aVideo => _flux.getVideoTracks().toDart.isNotEmpty;

  void couper() {
    for (final p in _flux.getTracks().toDart) {
      p.stop();
    }
  }
}
