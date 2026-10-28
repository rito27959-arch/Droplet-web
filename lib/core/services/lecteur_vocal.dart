// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE LECTEUR DES MESSAGES VOCAUX — un seul pour toute l'application.
//
// Avant, chaque conversation avait SON lecteur, détruit en même temps
// qu'elle : on lançait un vocal d'une minute, on revenait à la liste des
// discussions pour répondre à quelqu'un d'autre… et la voix se coupait.
// WhatsApp et Telegram, eux, continuent : un bandeau apparaît en haut de
// l'app (`BandeauLecture`), et hors de l'app, une notification « média »
// (`LectureVocaleService.kt`) permet de mettre en pause, d'avancer, de
// passer au suivant — même écran verrouillé.
//
// Ce fichier est ce lecteur unique. La conversation ne fait plus que lui
// demander de jouer une piste ; les bulles, le bandeau et la notification
// lisent tous le même état.
//
// ── Ce qu'il fait ─────────────────────────────────────────────────────
//
// • LECTURE / PAUSE : toucher une bulle en cours met EN PAUSE (on reprend
//   au même mot), au lieu de tout arrêter.
// • ENCHAÎNEMENT : à la fin d'un vocal reçu, le suivant non écouté de la
//   même conversation part tout seul — même si on a quitté la
//   conversation. La liste est fixée au moment où on lance la lecture.
// • VITESSE 1× → 1,5× → 2×, gardée d'un vocal à l'autre.
// • ÉCOUTÉS : la pastille « non écouté » des bulles se lit ici, pour
//   rester juste quand on revient dans la conversation.
// ============================================================================

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'storage_service.dart';

/// Un message vocal à jouer.
@immutable
class PisteVocale {
  const PisteVocale({
    required this.fileId,
    required this.fileName,
    required this.titre,
    required this.sousTitre,
    required this.route,
    this.image,
  });

  final String fileId;
  final String fileName;

  /// Qui parle : le nom de l'expéditeur (« Vous » pour ses propres vocaux).
  final String titre;

  /// Où : « Message vocal », ou le nom du groupe.
  final String sousTitre;

  /// La conversation, pour y revenir en touchant le bandeau ou la
  /// notification.
  final String route;

  /// La photo de l'expéditeur, si on l'a.
  final String? image;
}

class LecteurVocal extends ChangeNotifier {
  LecteurVocal._();

  static final LecteurVocal instance = LecteurVocal._();

  AudioPlayer? _lecteur;
  final List<StreamSubscription<Object?>> _abonnements = [];

  PisteVocale? _piste;
  bool _enLecture = false;
  Duration _position = Duration.zero;
  Duration? _duree;
  double _vitesse = 1.0;
  List<PisteVocale> _suite = const [];

  /// Les vocaux déjà écoutés pendant cette session.
  final Set<String> ecoutes = {};

  /// Appelé quand un vocal ne peut pas être lu (fichier tronqué, format
  /// inconnu) — la conversation affiche alors un message.
  void Function()? surErreur;

  PisteVocale? get piste => _piste;
  bool get enLecture => _enLecture;
  Duration get position => _position;
  Duration? get duree => _duree;
  double get vitesse => _vitesse;
  bool get aUneSuite => _suite.isNotEmpty;

  /// L'avancement, entre 0 et 1.
  double get progression {
    final d = _duree;
    if (d == null || d.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
  }

  bool estActif(String? fileId) => fileId != null && _piste?.fileId == fileId;

  // ─────────────────────────────────────────────────────────────

  AudioPlayer _assurerLecteur() {
    final existant = _lecteur;
    if (existant != null) return existant;
    final p = AudioPlayer(playerId: 'vocaux');
    _abonnements
      ..add(p.onDurationChanged.listen((d) {
        _duree = d;
        notifyListeners();
        _majNotif();
      }))
      ..add(p.onPositionChanged.listen((pos) {
        _position = pos;
        notifyListeners();
      }))
      ..add(p.onPlayerComplete.listen((_) => unawaited(_fin())));
    NotifLecture.brancher(this);
    _lecteur = p;
    return p;
  }

  /// Joue [piste]. Si c'est déjà celle en cours, bascule lecture/pause.
  ///
  /// [suite] : les vocaux à enchaîner ensuite (reçus, non écoutés).
  Future<void> jouer(PisteVocale piste, {List<PisteVocale> suite = const []}) async {
    if (_piste?.fileId == piste.fileId) {
      await basculer();
      return;
    }
    final chemin = await StorageService.getSharedFilePath(piste.fileId, piste.fileName);
    if (chemin == null) {
      surErreur?.call();
      return;
    }
    await _lancer(piste, chemin, suite);
  }

  Future<void> _lancer(PisteVocale piste, String chemin, List<PisteVocale> suite) async {
    final p = _assurerLecteur();
    await p.stop();
    _piste = piste;
    _suite = List.unmodifiable(suite);
    _position = Duration.zero;
    _duree = null;
    _enLecture = true;
    ecoutes.add(piste.fileId);
    notifyListeners();
    try {
      await p.setPlaybackRate(_vitesse);
      await p.play(DeviceFileSource(chemin));
      _majNotif();
    } catch (e) {
      debugPrint('[LecteurVocal] lecture impossible: $e');
      await arreter();
      surErreur?.call();
    }
  }

  /// Lecture ⇄ pause.
  Future<void> basculer() async {
    final p = _lecteur;
    if (p == null || _piste == null) return;
    if (_enLecture) {
      await p.pause();
      _enLecture = false;
    } else {
      await p.resume();
      _enLecture = true;
    }
    notifyListeners();
    _majNotif();
  }

  Future<void> arreter() async {
    await _lecteur?.stop();
    _piste = null;
    _suite = const [];
    _enLecture = false;
    _position = Duration.zero;
    _duree = null;
    notifyListeners();
    unawaited(NotifLecture.arreter());
  }

  /// Va à [fraction] (0 → 1) du vocal en cours.
  Future<void> allerA(double fraction) async {
    final d = _duree;
    if (_lecteur == null || d == null) return;
    await allerAPosition(Duration(milliseconds: (d.inMilliseconds * fraction.clamp(0.0, 1.0)).round()));
  }

  Future<void> allerAPosition(Duration cible) async {
    final p = _lecteur;
    if (p == null) return;
    await p.seek(cible);
    _position = cible;
    notifyListeners();
    _majNotif();
  }

  /// 1× → 1,5× → 2× → 1×.
  Future<void> vitesseSuivante() async {
    _vitesse = switch (_vitesse) {
      1.0 => 1.5,
      1.5 => 2.0,
      _ => 1.0,
    };
    HapticFeedback.selectionClick();
    if (_piste != null) await _lecteur?.setPlaybackRate(_vitesse);
    notifyListeners();
    _majNotif();
  }

  /// Passe au vocal suivant de la liste, s'il y en a un.
  Future<void> suivante() async {
    while (_suite.isNotEmpty) {
      final prochaine = _suite.first;
      final reste = _suite.sublist(1);
      final chemin = await StorageService.getSharedFilePath(prochaine.fileId, prochaine.fileName);
      if (chemin != null) {
        await _lancer(prochaine, chemin, reste);
        return;
      }
      // Pas encore reçu en entier : on le saute.
      _suite = reste;
    }
    await arreter();
  }

  Future<void> _fin() async {
    if (_suite.isNotEmpty) {
      await suivante();
    } else {
      await arreter();
    }
  }

  void _majNotif() {
    final piste = _piste;
    if (piste == null) return;
    unawaited(NotifLecture.maj(
      piste: piste,
      enLecture: _enLecture,
      position: _position,
      duree: _duree ?? Duration.zero,
      vitesse: _vitesse,
      suivant: _suite.isNotEmpty,
    ));
  }
}

/// Le pont vers la notification « média » d'Android
/// (`LectureVocaleService.kt`). Sur les autres plateformes, il ne fait rien.
class NotifLecture {
  NotifLecture._();

  static const MethodChannel _canal = MethodChannel('com.droplet.droplet/lecture_vocale');
  static bool _branche = false;

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static void brancher(LecteurVocal lecteur) {
    if (_branche || !_android) return;
    _branche = true;
    _canal.setMethodCallHandler((appel) async {
      if (appel.method != 'action') return null;
      final args = Map<String, Object?>.from(appel.arguments as Map);
      switch (args['nom']) {
        case 'lecture':
          if (!lecteur.enLecture) await lecteur.basculer();
        case 'pause':
          if (lecteur.enLecture) await lecteur.basculer();
        case 'suivant':
          await lecteur.suivante();
        case 'arreter':
          await lecteur.arreter();
        case 'aller':
          final ms = args['position'];
          if (ms is num) await lecteur.allerAPosition(Duration(milliseconds: ms.toInt()));
      }
      return null;
    });
  }

  static Future<void> maj({
    required PisteVocale piste,
    required bool enLecture,
    required Duration position,
    required Duration duree,
    required double vitesse,
    required bool suivant,
  }) async {
    if (!_android) return;
    try {
      await _canal.invokeMethod<bool>('maj', {
        'titre': piste.titre,
        'sousTitre': piste.sousTitre,
        'enLecture': enLecture,
        'position': position.inMilliseconds,
        'duree': duree.inMilliseconds,
        'vitesse': vitesse,
        'route': piste.route,
        'image': piste.image,
        'suivant': suivant,
      });
    } catch (e) {
      // Pas de notification (version de l'app sans le service natif) :
      // la lecture, elle, continue.
      debugPrint('[NotifLecture] $e');
    }
  }

  static Future<void> arreter() async {
    if (!_android) return;
    try {
      await _canal.invokeMethod<bool>('arreter');
    } catch (_) {}
  }
}
