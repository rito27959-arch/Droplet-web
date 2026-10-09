// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran plein écran pour REGARDER les statuts de quelqu'un — comme les
// Stories d'Instagram ou les Statuts de WhatsApp : une barre de
// progression par statut en haut, avance automatique, tap à gauche pour
// revenir, tap à droite pour passer, glissement vers le bas pour fermer.
//
// Il affiche maintenant tout ce qu'un statut peut porter : du texte sur
// fond coloré, une photo, une vidéo, un message vocal, et la chanson qui
// l'accompagne éventuellement.
//
// ── Trois choses qui ne vont pas de soi ────────────────────────────────
//
// 1. LA DURÉE D'AFFICHAGE N'EST PAS FIXE. Cinq secondes pour du texte ou
//    une photo, mais la durée réelle pour une vidéo ou un vocal : couper
//    quelqu'un au milieu d'une phrase serait absurde.
//
// 2. LE MÉDIA PEUT NE PAS ÊTRE ENCORE ARRIVÉ. L'annonce d'un statut pèse
//    quelques centaines d'octets, une photo des centaines de milliers :
//    sur un réseau Bluetooth, la première arrive largement avant la
//    seconde. L'écran affiche donc un cadre en attente, et se remplit
//    dès que le fichier est là — la barre de progression, elle, reste en
//    pause tant qu'il n'y a rien à voir.
//
// 3. LES « J'AIME » ET COMMENTAIRES NE PARTENT QU'À L'AUTEUR. Sur un
//    maillage, un compteur public supposerait que tous les téléphones
//    tombent d'accord sur un même nombre, ce qui est impossible à
//    garantir quand chacun ne voit qu'une poignée de voisins. Une seule
//    personne tient donc le compte : celle que ça intéresse. C'est aussi
//    exactement ce que fait WhatsApp.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';

import 'ordre_statuts.dart';
import 'status_pager_screen.dart';
import '../../core/models/mesh_message.dart';
import '../../core/models/status_media.dart';
import '../../core/models/voice_note_meta.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/story_progress_bar.dart';
import '../chat/voice_note.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import '../../shared/widgets/floating_hearts_overlay.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../../core/services/avatar_service.dart';

class StatusViewerScreen extends ConsumerStatefulWidget {
  /// L'ordre des contacts figé à l'ouverture du lecteur : sans lui, un
  /// contact qu'on vient de finir passerait en « déjà vus » et « le suivant »
  /// sauterait par-dessus des contacts pas encore regardés.
  static List<String>? ordreDeSeance;

  /// D'où arrive le prochain lecteur : 1 depuis la droite, −1 depuis la
  /// gauche, 0 sans glissé (ouverture depuis l'onglet).
  static int sensArrivee = 0;

  /// L'écran d'où le lecteur a été ouvert, pour y revenir en le fermant.
  static String? origine;

  const StatusViewerScreen({
    super.key,
    required this.authorId,
    this.actif = true,
    this.onContactVoisin,
  });
  final String authorId;

  /// La page est au premier plan du lecteur : elle seule lit et avance.
  final bool actif;

  /// Demande le contact voisin au lecteur en pages ; `false` s'il n'y en a
  /// pas. Absent : l'ancien passage d'un contact à l'autre par la route.
  final bool Function(int sens)? onContactVoisin;

  @override
  ConsumerState<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends ConsumerState<StatusViewerScreen>
    with TickerProviderStateMixin {
  /// Durée d'affichage d'un statut sans média — celle de toutes les
  /// applications de stories, et elle n'a pas été choisie au hasard :
  /// c'est à peu près le temps de lire une phrase courte.
  static const _textDuration = Duration(seconds: 5);
  static const _photoDuration = Duration(seconds: 6);

  late final List<MeshStatusRecord> _statuses;
  late final AnimationController _progress;
  int _index = 0;

  final Set<String> _seenSentFor = {};
  StreamSubscription<String>? _statusSeenSub;
  StreamSubscription<String>? _mediaSub;
  StreamSubscription<StatusFeedback>? _feedbackSub;
  int _revision = 0;

  /// Le lecteur du média principal (vocal) et celui de la musique
  /// d'accompagnement — deux lecteurs distincts, puisqu'ils peuvent
  /// jouer en même temps.
  AudioPlayer? _voicePlayer;
  AudioPlayer? _musicPlayer;
  VideoPlayerController? _video;

  StreamSubscription<Duration>? _voicePosSub;
  Duration? _voiceTotal;
  double _voiceProgress = 0;

  /// Vrai quand la progression est suspendue : le doigt est maintenu
  /// appuyé, une feuille est ouverte, ou le média n'est pas encore
  /// arrivé.
  bool _held = false;

  /// Le chemin local du média affiché, résolu UNE fois à la préparation.
  ///
  /// Il était auparavant redemandé depuis `build` via un `FutureBuilder`,
  /// donc relancé à chaque redessin — c'est-à-dire soixante fois par
  /// seconde pendant que la barre de progression avance. L'image
  /// clignotait à chaque nouvelle résolution, et le disque était
  /// interrogé pour rien.
  String? _mediaPath;

  /// Numéro de la préparation en cours.
  ///
  /// Enchaîner les taps lance plusieurs préparations à la fois, et
  /// chacune comporte des `await`. Sans ce compteur, une préparation
  /// ancienne pouvait reprendre la main APRÈS une plus récente et
  /// installer sa vidéo par-dessus : on se retrouvait avec le son d'un
  /// statut et l'image d'un autre.
  int _generation = 0;

  bool _liking = false;

  // ── Gestes de WhatsApp ────────────────────────────────────────────────

  /// Le doigt est maintenu : l'interface s'efface pour laisser voir le
  /// statut en entier.
  bool _doigtPose = false;

  /// Le champ de réponse a le focus : les réactions rapides s'affichent.
  bool _repondEnCours = false;

  /// Le glissé vers le bas, en points. Une `ValueNotifier` et non un
  /// `setState` : pendant le geste, seul le calque de transformation se
  /// redessine — pas la vidéo, pas l'en-tête, pas la barre de réponse.
  final ValueNotifier<double> _glisse = ValueNotifier<double>(0);

  /// Le cumul d'un glissé vers le haut (répondre, voir les vues).
  double _montee = 0;

  /// Le cumul d'un glissé horizontal (contact voisin).
  double _horizontal = 0;

  /// Le ressort du retour en place, qui repart avec la vitesse du doigt.
  late final AnimationController _ressort = AnimationController.unbounded(vsync: this)
    ..addListener(() => _glisse.value = math.max(0, _ressort.value));
  static final SpringDescription _ressortIos =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 0.88);

  /// Les raisons de suspendre la lecture. Chacune est levée par qui l'a
  /// posée : lâcher l'écran ne relance plus un statut pendant qu'on tape
  /// une réponse ou qu'une feuille est ouverte.
  final Set<String> _retenues = <String>{};

  Timer? _minuteurVoile;

  /// L'émoji d'une réaction qui s'envole, le temps de son animation.
  String? _emojiEnvole;

  int _sens = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.actif) _retenues.add('inactif');
    _statuses = StorageService.getActiveStatuses()
        .where((s) => s.authorId == widget.authorId && !StorageService.isContactBlocked(s.authorId))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _sens = StatusViewerScreen.sensArrivee;
    StatusViewerScreen.sensArrivee = 0;
    final monId = ref.read(meshRepositoryProvider).myId;
    final ordre = StatusViewerScreen.ordreDeSeance;
    if (widget.authorId != monId &&
        (ordre == null || !ordre.contains(widget.authorId))) {
      StatusViewerScreen.ordreDeSeance = ordreDesContacts(monId);
    }

    _progress = AnimationController(vsync: this, duration: _textDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      });

    final repo = ref.read(meshRepositoryProvider);

    _statusSeenSub = repo.statusSeenEvents.listen((statusId) {
      if (!mounted) return;
      if (_statuses.any((s) => s.id == statusId)) setState(() => _revision++);
    });
    _feedbackSub = repo.statusFeedbackEvents.listen((f) {
      if (!mounted) return;
      if (_statuses.any((s) => s.id == f.statusId)) setState(() => _revision++);
    });
    // Le média du statut affiché vient peut-être d'arriver : on relance
    // alors sa préparation, sans quoi l'écran resterait sur son cadre
    // d'attente jusqu'au statut suivant.
    _mediaSub = repo.statusMediaEvents.listen((fileId) {
      if (!mounted || _statuses.isEmpty) return;
      final media = StorageService.getStatusMedia(_statuses[_index].id);
      if (media.fileId == fileId || media.musicFileId == fileId) {
        _prepareCurrent();
      }
    });

    if (_statuses.isNotEmpty) {
      _prepareCurrent();
      _markSeenIfNeeded();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _ressort.dispose();
    _glisse.dispose();
    _minuteurVoile?.cancel();
    _statusSeenSub?.cancel();
    _mediaSub?.cancel();
    _feedbackSub?.cancel();
    _teardownPlayers();
    super.dispose();
  }

  void _teardownPlayers() {
    _voicePosSub?.cancel();
    _voicePosSub = null;
    _voicePlayer?.dispose();
    _voicePlayer = null;
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _video?.dispose();
    _video = null;
  }

  // ─────────────────────────────────────────────────────────────
  //  PRÉPARATION D'UN STATUT
  // ─────────────────────────────────────────────────────────────

  MeshStatusRecord get _current => _statuses[_index];
  StatusMedia get _media => StorageService.getStatusMedia(_current.id);

  /// Chemin local du fichier, ou `null` s'il n'est pas encore arrivé.
  Future<String?> _pathOf(String? fileId, String? fileName) {
    if (fileId == null || fileName == null) return Future.value(null);
    return StorageService.getSharedFilePath(fileId, fileName);
  }

  /// Met en place tout ce qu'il faut pour le statut courant : lecteurs,
  /// durée d'affichage, démarrage de la barre.
  Future<void> _prepareCurrent() async {
    final generation = ++_generation;
    _teardownPlayers();
    _voiceTotal = null;
    _voiceProgress = 0;
    _mediaPath = null;

    final status = _current;
    final media = StorageService.getStatusMedia(status.id);

    // La musique démarre en premier et tourne en boucle : elle
    // accompagne, elle ne rythme pas.
    if (media.hasMusic) {
      final path = await _pathOf(media.musicFileId, media.musicFileName);
      if (generation != _generation) return;
      if (path != null && mounted) {
        _musicPlayer = AudioPlayer();
        await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer!.setVolume(media.kind == StatusMediaKind.voice
            // Sous une voix, la musique doit rester très en retrait,
            // sinon on n'entend plus ce qui est dit.
            ? 0.18
            : 0.55);
        // ⚠️ Protégé : une musique de statut tronquée en cours de
        // transfert ferait autrement remonter une exception non
        // rattrapée jusqu'à la racine de l'application.
        unawaited(_musicPlayer!.play(DeviceFileSource(path)).catchError(
            (e) => debugPrint('[Statut] musique illisible: $e')));
      }
    }

    Duration segment = _textDuration;

    switch (media.kind) {
      case StatusMediaKind.none:
        segment = _textDuration;

      case StatusMediaKind.photo:
        final path = await _pathOf(media.fileId, media.fileName);
        if (generation != _generation) return;
        if (path == null) {
          _waitForMedia();
          return;
        }
        _mediaPath = path;
        segment = _photoDuration;

      case StatusMediaKind.video:
        final path = await _pathOf(media.fileId, media.fileName);
        if (generation != _generation) return;
        if (path == null) {
          _waitForMedia();
          return;
        }
        _mediaPath = path;
        final controller = VideoPlayerController.file(File(path));
        _video = controller;
        try {
          await controller.initialize();
          if (!mounted) return;
          // La préparation a été doublée pendant l'initialisation : ce
          // lecteur-ci n'a plus lieu d'être, et c'est le plus récent qui
          // a déjà pris sa place.
          if (generation != _generation) {
            await controller.dispose();
            return;
          }
          await controller.setLooping(false);
          // La vidéo porte son propre son : la musique s'efface devant.
          await _musicPlayer?.setVolume(0.12);
          unawaited(controller.play());
          segment = controller.value.duration;
        } catch (_) {
          segment = _photoDuration;
        }

      case StatusMediaKind.voice:
        final path = await _pathOf(media.fileId, media.fileName);
        if (generation != _generation) return;
        if (path == null) {
          _waitForMedia();
          return;
        }
        _mediaPath = path;
        final player = AudioPlayer();
        _voicePlayer = player;
        _voicePosSub = player.onPositionChanged.listen((pos) {
          final total = _voiceTotal;
          if (!mounted || total == null || total.inMilliseconds == 0) return;
          setState(() {
            _voiceProgress =
                (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
          });
        });
        unawaited(player.play(DeviceFileSource(path)).catchError((e) {
          debugPrint('[Statut] vocal illisible: $e');
          // Le statut reste affiché, mais sans attendre une lecture qui
          // n'arrivera jamais : on laisse la barre repartir.
          if (mounted) _progress.forward();
        }));
        segment = media.durationMs != null
            ? Duration(milliseconds: media.durationMs!)
            : _textDuration;
        _voiceTotal = segment;
    }

    if (!mounted || generation != _generation) return;
    // Un garde-fou : une vidéo corrompue peut annoncer une durée nulle,
    // ce qui ferait défiler tous les statuts en un clin d'œil.
    if (segment.inMilliseconds < 800) segment = _textDuration;

    _progress
      ..duration = segment
      ..reset();
    // Une page qui n'est pas au premier plan — ou une retenue posée (une
    // feuille ouverte, une réponse en cours) — prépare son média : la
    // première image est prête quand on glisse vers elle. Mais elle attend
    // son tour pour lire et avancer.
    if (_retenues.isNotEmpty) {
      _video?.pause();
      _voicePlayer?.pause();
      _musicPlayer?.pause();
      setState(() => _held = true);
      return;
    }
    setState(() => _held = false);
    _progress.forward();
  }

  @override
  void didUpdateWidget(StatusViewerScreen ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.actif != widget.actif) {
      _retenir('inactif', !widget.actif);
      if (widget.actif) _markSeenIfNeeded();
    }
  }

  /// Le fichier n'est pas encore arrivé : on suspend la progression et on
  /// attend le signal du dépôt (voir `statusMediaEvents`).
  void _waitForMedia() {
    if (!mounted) return;
    _progress.stop();
    setState(() => _held = true);
  }

  void _markSeenIfNeeded() {
    if (_statuses.isEmpty || _retenues.contains('inactif')) return;
    final status = _current;
    final myId = ref.read(meshRepositoryProvider).myId;
    if (status.authorId == myId) return;
    // L'anneau de la carte passe au gris, ici et dans l'onglet Actualités.
    StatutsVus.marquer(status.id);
    if (!_seenSentFor.add(status.id)) return;
    unawaited(ref.read(meshRepositoryProvider).sendStatusSeen(
          authorId: status.authorId,
          statusId: status.id,
        ));
  }

  // ─────────────────────────────────────────────────────────────
  //  NAVIGATION
  // ─────────────────────────────────────────────────────────────

  void _advance() {
    if (_index >= _statuses.length - 1) {
      // Comme WhatsApp : on enchaîne sur le contact suivant au lieu de
      // fermer.
      _contactVoisin(1);
      return;
    }
    setState(() => _index++);
    _prepareCurrent();
    _markSeenIfNeeded();
  }

  void _rewind() {
    if (_index <= 0) {
      _contactVoisin(-1);
      return;
    }
    setState(() => _index--);
    _prepareCurrent();
    _markSeenIfNeeded();
  }

  /// Maintenir le doigt met tout en pause — le geste attendu de toutes
  /// les stories quand on veut prendre le temps de lire.
  void _appliquerRetenue(bool held) {
    if (_held == held) return;
    setState(() => _held = held);
    if (held) {
      _progress.stop();
      _video?.pause();
      _voicePlayer?.pause();
      _musicPlayer?.pause();
    } else {
      _progress.forward();
      _video?.play();
      _voicePlayer?.resume();
      _musicPlayer?.resume();
    }
  }

  void _close() {
    StatusViewerScreen.ordreDeSeance = null;
    // Comme WhatsApp : on revient là d'où l'on est parti (l'onglet
    // Actualités), et non plus systématiquement aux Discussions.
    final retour = StatusViewerScreen.origine ?? '/chats';
    StatusViewerScreen.origine = null;
    // Posé par-dessus les onglets : on dépile, et la liste réapparaît.
    if (mounted) fermerLecteurStatuts(context, retour);
  }

  /// Le contact suivant (1) ou précédent (−1) dans l'ordre de la séance.
  /// Au bout de la liste : on ferme (vers l'avant) ou on reprend le premier
  /// statut (vers l'arrière).
  void _contactVoisin(int sens) {
    final voisin = widget.onContactVoisin;
    if (voisin != null) {
      if (!voisin(sens)) {
        if (sens > 0) {
          _close();
        } else {
          _prepareCurrent();
        }
      }
      return;
    }
    final ordre = StatusViewerScreen.ordreDeSeance ?? const <String>[];
    final i = ordre.indexOf(widget.authorId);
    final j = i + sens;
    if (i < 0 || j < 0 || j >= ordre.length) {
      if (sens > 0) {
        _close();
      } else {
        _prepareCurrent();
      }
      return;
    }
    OuroHaptics.selection();
    StatusViewerScreen.sensArrivee = sens;
    context.go('/status/${ordre[j]}');
  }

  void _retenir(String raison, bool actif) {
    if (!mounted) return;
    if (actif) {
      _retenues.add(raison);
    } else {
      _retenues.remove(raison);
    }
    _appliquerRetenue(_retenues.isNotEmpty);
  }

  void _hold(bool held) => _retenir('general', held);

  // ── La pause au contact, comme WhatsApp ─────────────────────────────────
  //
  // Elle attendait l'appui long de Flutter (500 ms) : la barre continuait
  // d'avancer sous le doigt, et un statut pouvait se terminer pendant qu'on
  // le retenait.

  void _toucher() {
    if (!mounted) return;
    _retenir('doigt', true);
    _minuteurVoile?.cancel();
    if (_repondEnCours) return;
    // L'interface ne s'efface qu'après un vrai maintien : un simple tap
    // pour passer au suivant ne doit pas la faire clignoter.
    _minuteurVoile = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _doigtPose = true);
    });
  }

  void _lacher() {
    if (!mounted) return;
    _minuteurVoile?.cancel();
    if (_doigtPose) setState(() => _doigtPose = false);
    _retenir('doigt', false);
  }

  void _surFocusReponse(bool focus) {
    setState(() => _repondEnCours = focus);
    _retenir('reponse', focus);
  }

  /// Une réaction rapide : l'émoji s'envole au centre de l'écran, et part
  /// dans la discussion comme une réponse au statut — sans toast.
  Future<void> _reagir(String emoji) async {
    OuroHaptics.medium();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _emojiEnvole = emoji);
    Future.delayed(const Duration(milliseconds: 1150), () {
      if (mounted && _emojiEnvole == emoji) setState(() => _emojiEnvole = null);
    });
    await _sendComment(emoji, silencieux: true);
  }

  // ── Le glissé vers le bas : l'écran suit le doigt, puis ressort ─────────

  void _debutGlisse(DragStartDetails _) {
    _ressort.stop();
    _montee = 0;
  }

  void _majGlisse(DragUpdateDetails d) {
    final dy = d.delta.dy;
    final actuel = _glisse.value;
    if (actuel > 0 || (dy > 0 && _montee >= 0)) {
      if (actuel == 0) _retenir('glisse', true);
      _glisse.value = math.max(0, actuel + dy);
    } else {
      _montee += dy;
    }
  }

  void _finGlisse(DragEndDetails d) {
    final vitesse = d.primaryVelocity ?? 0;
    final actuel = _glisse.value;
    if (actuel > 0) {
      if (actuel > 140 || vitesse > 900) {
        _close();
        return;
      }
      _ressort.value = actuel;
      _ressort
          .animateWith(SpringSimulation(_ressortIos, actuel, 0, vitesse))
          .whenCompleteOrCancel(() => _retenir('glisse', false));
      return;
    }
    if (vitesse < -200 || _montee < -80) {
      if (_current.authorId == ref.read(meshRepositoryProvider).myId) {
        _pauseFor(() => _showFeedbackSheet(_current));
      } else {
        _cleReponse.currentState?.ouvrir();
      }
    }
    _montee = 0;
  }

  // ── Le glissé horizontal : le contact voisin ────────────────────────────

  void _majHorizontal(DragUpdateDetails d) => _horizontal += d.delta.dx;

  void _finHorizontal(DragEndDetails d) {
    final vitesse = d.primaryVelocity ?? 0;
    // Un glissé lent compte aussi, dès qu'il dépasse un cinquième d'écran.
    final seuil = MediaQuery.sizeOf(context).width * 0.22;
    final vers = (vitesse < -250 || _horizontal < -seuil)
        ? 1
        : (vitesse > 250 || _horizontal > seuil)
            ? -1
            : 0;
    _horizontal = 0;
    if (vers == 0) return;
    // En arabe, « suivant » est à gauche.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    _contactVoisin(rtl ? -vers : vers);
  }

  /// L'habillage de l'écran : l'arrivée glissée depuis le contact voisin, et
  /// le glissé vers le bas qui réduit et arrondit tout l'écran.
  ///
  /// ⚠️ LA STRUCTURE NE CHANGE JAMAIS. Insérer les transformations au début
  /// du geste changeait le parent du Scaffold : Flutter reconstruisait tout
  /// le lecteur depuis zéro (vidéo, en-tête, animations), et l'arrivée
  /// glissée se rejouait en plein geste. Au repos, les transformations
  /// valent l'identité — elles ne coûtent rien.
  Widget _habillage(Widget enfant) {
    final taille = MediaQuery.sizeOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final sens = rtl ? -_sens : _sens;
    return ValueListenableBuilder<double>(
        valueListenable: _glisse,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: sens == 0 ? 0 : 1, end: 0),
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
          child: enfant,
          builder: (context, v, child) => Transform.translate(
            offset: Offset(sens * v * taille.width * 0.3, 0),
            child: Transform.scale(scale: 1 - 0.06 * v, child: child),
          ),
        ),
        builder: (context, dy, child) {
          final t = (dy / taille.height).clamp(0.0, 1.0).toDouble();
          final arrondi = (t * 5).clamp(0.0, 1.0).toDouble();
          // Le noir s'efface avec le geste : la liste réapparaît derrière le
          // statut qui rétrécit, comme chez WhatsApp.
          return ColoredBox(
            color: Colors.black.withValues(alpha: (1 - 1.8 * t).clamp(0.0, 1.0).toDouble()),
            child: Transform.translate(
              offset: Offset(0, dy * 0.85),
              child: Transform.scale(
                scale: 1 - 0.2 * t,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30 * arrondi),
                  clipBehavior: dy == 0 ? Clip.none : Clip.antiAlias,
                  child: child,
                ),
              ),
            ),
          );
        },
    );
  }

  /// Suspend l'écran le temps d'une feuille (spectateurs, commentaires),
  /// puis reprend là où on en était.
  Future<void> _pauseFor(Future<void> Function() action) async {
    _retenir('feuille', true);
    await action();
    if (mounted) _retenir('feuille', false);
  }

  // ─────────────────────────────────────────────────────────────
  //  RÉACTIONS
  // ─────────────────────────────────────────────────────────────

  bool get _iLiked {
    final myId = ref.read(meshRepositoryProvider).myId;
    return StorageService.getStatusFeedback(_current.id)
        .any((f) => f.isLike && f.authorId == myId);
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() => _liking = true);

    final repo = ref.read(meshRepositoryProvider);
    final status = _current;
    final liked = _iLiked;

    // On enregistre AUSSI chez soi, en plus d'envoyer à l'auteur : sans
    // cela, le cœur retomberait à sa position d'avant dès que l'écran se
    // redessine, puisque seul l'auteur conserve la trace du « j'aime ».
    if (liked) {
      await StorageService.removeStatusLike(status.id, repo.myId);
    } else {
      await StorageService.addStatusFeedback(StatusFeedback(
        statusId: status.id,
        authorId: repo.myId,
        authorPseudo: StorageService.currentUser?.pseudo ?? 'Moi',
        createdAt: DateTime.now(),
        emoji: '❤️',
      ));
      OuroHaptics.medium();
    }

    unawaited(repo.sendStatusFeedback(
      authorId: status.authorId,
      statusId: status.id,
      emoji: liked ? null : '❤️',
      remove: liked,
    ).then<void>((_) {}, onError: (Object e) {
      debugPrint('[Statut] réaction non envoyée: $e');
    }));

    if (mounted) setState(() => _liking = false);
  }

  final GlobalKey<_ReplyBarState> _cleReponse = GlobalKey<_ReplyBarState>();

  /// ⚠️ LA RÉPONSE PART DANS LA DISCUSSION, COMME CHEZ WHATSAPP. Elle
  /// n'existait que dans une liste cachée sous le statut : ni l'un ni
  /// l'autre ne la retrouvait dans la conversation. C'est désormais un vrai
  /// message, qui cite le statut (`statut:<id>`).
  Future<void> _sendComment(String text, {bool silencieux = false}) async {
    if (text.trim().isEmpty) return;
    final status = _current;
    await ref.read(meshMessagesProvider.notifier).sendMessage(
          StorageService.currentUser?.pseudo ?? 'Moi',
          text.trim(),
          targetId: status.authorId,
          replyToId: 'statut:${status.id}',
        );

    if (!mounted) return;
    OuroHaptics.success();
    if (!silencieux) {
      ref.read(toastProvider.notifier).show(
            AppLocalizations.of(context).svReplySent(status.authorPseudo),
            type: DropletToastType.success,
          );
    }
    setState(() => _revision++);
  }

  // ─────────────────────────────────────────────────────────────
  //  AFFICHAGE
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_statuses.isEmpty) {
      final l10n = AppLocalizations.of(context);
      // Ce cas-ci n'est PAS la visionneuse : c'est un écran d'erreur
      // classique, il suit donc le mode clair/sombre comme le reste.
      return Scaffold(
        backgroundColor: OuroColors.systemBackground,
        body: IosMagnifierOverlay(
          child: EmptyState(
            emoji: Scenes.aucunStatut,
            icon: Icons.timer_off_rounded,
            title: l10n.svExpired,
            action: OuroRetourIos(child: TextButton(onPressed: _close, child: Text(l10n.actionClose))),
          ),
        ),
      );
    }

    final status = _current;
    final media = _media;
    final mine = status.authorId == ref.watch(meshRepositoryProvider).myId;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onVerticalDragStart: _debutGlisse,
        onVerticalDragUpdate: _majGlisse,
        onVerticalDragEnd: _finGlisse,
        // Glissé horizontal : le contact voisin, comme chez WhatsApp.
        // Dans le lecteur en pages, c'est lui qui suit le doigt entre contacts.
        onHorizontalDragStart: widget.onContactVoisin == null ? (_) => _horizontal = 0 : null,
        onHorizontalDragUpdate: widget.onContactVoisin == null ? _majHorizontal : null,
        onHorizontalDragEnd: widget.onContactVoisin == null ? _finHorizontal : null,
        child: _habillage(Scaffold(
          backgroundColor: media.backgroundColor != null
              ? Color(media.backgroundColor!)
              : OuroColors.callBackground,
          body: IosMagnifierOverlay(
            child: Stack(
            fit: StackFit.expand,
            children: [
              _canvas(status, media),

              // Zones de tap : tiers gauche = précédent, reste = suivant.
              // Le maintien met en pause, comme dans toutes les stories.
              Positioned.fill(
                top: 90,
                bottom: 110,
                child: Listener(
                  onPointerDown: (_) => _toucher(),
                  onPointerUp: (_) => _lacher(),
                  onPointerCancel: (_) => _lacher(),
                  child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _rewind,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _advance,
                      ),
                    ),
                  ],
                ),
                ),
              ),

              // Cœur géant au centre quand on double-tape
              if (_emojiEnvole != null)
                IgnorePointer(
                  child: Center(
                    child: Text(
                      _emojiEnvole!,
                      style: const TextStyle(fontSize: 96),
                    )
                        .animate(key: ValueKey(_emojiEnvole))
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1, 1),
                          duration: 380.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 120.ms)
                        .then(delay: 260.ms)
                        .moveY(end: -170, duration: 460.ms, curve: Curves.easeInCubic)
                        .fadeOut(duration: 460.ms),
                  ),
                ),

              AnimatedOpacity(
                opacity: _doigtPose ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                child: SafeArea(child: _header(context, status, media)),
              ),

              // Cœurs flottants quand c'est mon statut et qu'il y a des likes
              if (mine)
                Positioned.fill(
                  child: IgnorePointer(
                    child: FloatingHeartsOverlay(
                      hearts: StorageService.getStatusFeedback(status.id)
                          .where((f) => f.isLike)
                          .map((f) => f.authorPseudo)
                          .toList(),
                    ),
                  ),
                ),

              AnimatedOpacity(
                opacity: _doigtPose ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: mine
                      ? _MyStatusFooter(
                          key: ValueKey('${status.id}-$_revision'),
                          status: status,
                          onTap: () => _pauseFor(() => _showFeedbackSheet(status)),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_repondEnCours)
                              _ReactionsRapides(onChoisir: _reagir),
                            _ReplyBar(
                          key: _cleReponse,
                          liked: _iLiked,
                          onLike: _toggleLike,
                          onSend: _sendComment,
                          onFocus: _surFocusReponse,
                        ),
                          ],
                        ),
                ),
              ),
              ),
            ],
            ),
          ),
        )),
      ),
    );
  }

  // ── La toile ─────────────────────────────────────────────────────

  Widget _canvas(MeshStatusRecord status, StatusMedia media) {
    final caption = status.content.trim();

    return switch (media.kind) {
      StatusMediaKind.none => _textCanvas(status),
      StatusMediaKind.photo => _fileCanvas(
          (path) => Center(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 48,
              ),
            ),
          ),
          caption,
        ),
      StatusMediaKind.video => _fileCanvas(
          (_) {
            final v = _video;
            if (v == null || !v.value.isInitialized) return _loading(context);
            return Center(
              child: AspectRatio(
                aspectRatio: v.value.aspectRatio,
                child: VideoPlayer(v),
              ),
            );
          },
          caption,
        ),
      StatusMediaKind.voice => _voiceCanvas(status, media),
    };
  }

  Widget _textCanvas(MeshStatusRecord status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          status.content,
          key: ValueKey(status.id),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            // Un texte court mérite d'occuper l'écran ; un texte long doit
            // rester lisible. La taille suit donc la longueur.
            fontSize: status.content.length > 80 ? 22 : 30,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        )
            .animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .scaleXY(begin: 0.94, curve: DesignTokens.curveEnter),
      ),
    );
  }

  /// Enveloppe commune aux médias qui viennent d'un fichier : elle gère
  /// le cas où celui-ci n'est pas encore arrivé, et pose la légende
  /// par-dessus.
  Widget _fileCanvas(
    Widget Function(String path) builder,
    String caption,
  ) {
    final path = _mediaPath;
    return Builder(
      builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (path == null) _loading(context) else builder(path),
            if (caption.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 130,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    // Un voile sombre derrière la légende : sans lui, un
                    // texte blanc posé sur une photo claire disparaît.
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  ),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _voiceCanvas(MeshStatusRecord status, StatusMedia media) {
    final meta = VoiceNoteMeta.tryParse(media.waveform);
    final caption = status.content.trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PeerAvatar(
              pseudo: status.authorPseudo,
              radius: 38,
              // ⚠️ SANS `imagePath`, ON RETOMBE TOUJOURS SUR L'INITIALE.
              // `PeerAvatar` ne va PAS chercher la photo tout seul : il
              // affiche ce qu'on lui donne. Le chemin se demande à
              // `AvatarService`, et c'est ce que faisait déjà la liste
              // « Reçus » — d'où une photo là, et une lettre ici.
              imagePath: AvatarService.cheminPair(status.authorId),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 56,
              child: VoiceWaveform(
                waveform: meta?.waveform ?? const [],
                progress: _voiceProgress,
                activeColor: Colors.white,
                inactiveColor: Colors.white.withValues(alpha: 0.28),
                height: 56,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _fmtDuration(Duration(milliseconds: media.durationMs ?? 0)),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: OuroSpinner(color: Colors.white54, radius: 9),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.svReceiving,
            style: OuroTypography.footnote.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.svReceivingBody,
            style: OuroTypography.caption1.copyWith(color: Colors.white30),
          ),
        ],
      ),
    );
  }

  // ── L'en-tête ────────────────────────────────────────────────────

  Widget _header(BuildContext context, MeshStatusRecord status, StatusMedia media) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: l10n.svProgressLabel,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => StoryProgressBar(
                count: _statuses.length,
                currentIndex: _index,
                progress: _progress.value,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PeerAvatar(
                pseudo: status.authorPseudo,
                radius: 18,
                imagePath: AvatarService.cheminPair(status.authorId),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.authorPseudo,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    Text(_timeAgo(l10n, status.createdAt),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              if (_held)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.pause_rounded,
                      color: Colors.white54, size: 20),
                ),
              Semantics(
                button: true,
                label: l10n.actionClose,
                child: OuroIconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: _close,
                ),
              ),
            ],
          ),
          // La pastille de la musique, sous l'auteur : c'est là qu'on la
          // cherche, et elle dit à la fois qu'il y a du son et lequel.
          if (media.hasMusic) ...[
            const SizedBox(height: 8),
            _MusicChip(title: media.musicTitle ?? l10n.svDefaultMusicTitle),
          ],
        ],
      ),
    );
  }

  Future<void> _showFeedbackSheet(MeshStatusRecord status) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FeedbackSheet(status: status),
    );
  }

  static String _fmtDuration(Duration d) {
    final sec = d.inSeconds.clamp(0, 3599);
    return '${sec ~/ 60}:${(sec % 60).toString().padLeft(2, '0')}';
  }

  static String _timeAgo(AppLocalizations l10n, DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return l10n.svJustNow;
    if (diff.inMinutes < 60) return l10n.svMinutesAgo(diff.inMinutes);
    return l10n.svHoursAgo(diff.inHours);
  }
}

// ─────────────────────────────────────────────────────────────
//  LA PASTILLE DE MUSIQUE
// ─────────────────────────────────────────────────────────────

class _MusicChip extends StatelessWidget {
  const _MusicChip({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note_rounded, color: Colors.white, size: 15)
              .animate(onPlay: (c) => c.bouclerSiAmbiant(reverse: true))
              .scaleXY(
                begin: 1,
                end: 1.18,
                duration: 620.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RÉPONDRE À UN STATUT
// ─────────────────────────────────────────────────────────────

/// La barre du bas sur le statut de quelqu'un d'autre : un cœur, et un
/// champ pour répondre.
class _ReplyBar extends StatefulWidget {
  const _ReplyBar({
    super.key,
    required this.liked,
    required this.onLike,
    required this.onSend,
    required this.onFocus,
  });

  final bool liked;
  final VoidCallback onLike;
  final Future<void> Function(String text) onSend;

  /// Prévient l'écran qu'on écrit : il met la progression en pause, sinon
  /// le statut défilerait pendant qu'on tape sa réponse.
  final void Function(bool) onFocus;

  @override
  State<_ReplyBar> createState() => _ReplyBarState();
}

/// La barre du bas sur le statut de quelqu'un d'autre, comme WhatsApp : une
/// pilule « Répondre » (et le cœur) ; ouverte, une rangée d'emojis qui
/// partent d'un appui et le champ de texte.
class _ReplyBarState extends State<_ReplyBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;
  bool _ouverte = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      widget.onFocus(_focus.hasFocus);
      if (!_focus.hasFocus && _controller.text.trim().isEmpty) {
        setState(() => _ouverte = false);
      }
    });
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Ouvre la réponse (appui sur la pilule, ou glissement vers le haut).
  void ouvrir() {
    OuroHaptics.light();
    setState(() => _ouverte = true);
    _focus.requestFocus();
  }

  Future<void> _send([String? texte]) async {
    final text = texte ?? _controller.text;
    _controller.clear();
    _focus.unfocus();
    setState(() => _ouverte = false);
    await widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bas = MediaQuery.viewInsetsOf(context).bottom;

    if (!_ouverte) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: ouvrir,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 22)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 2, end: -2, duration: 900.ms, curve: Curves.easeInOut),
                    Container(
                      height: 44,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        l10n.svReply,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Semantics(
                button: true,
                label: widget.liked
                    ? l10n.svUnlikeStatus
                    : l10n.svLikeStatus,
                child: _RoundAction(
                  icon: widget.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  background: Colors.black.withValues(alpha: 0.32),
                  foreground: widget.liked ? OuroColors.systemRed : Colors.white,
                  onTap: widget.onLike,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: bas + 12, top: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xCC000000)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ⚠️ PAS DE RANGÉE D'EMOJI ICI. Il y en avait une, et
          // `_ReactionsRapides` en affichait une seconde juste au-dessus
          // au même moment : deux palettes empilées, avec les mêmes
          // émojis dans un ordre différent. Une seule reste, celle du
          // verre dépoli — c'est la forme d'iOS, et c'est elle qui a
          // l'animation d'arrivée.
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.svReplyHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: _hasText ? 1 : 0.85,
                duration: const Duration(milliseconds: 160),
                child: Semantics(
                  button: true,
                  label: l10n.svSendReply,
                  child: _RoundAction(
                    icon: Icons.send_rounded,
                    background: _hasText ? OuroColors.accent : Colors.white24,
                    onTap: _hasText ? _send : () {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.background,
    required this.onTap,
    this.foreground = Colors.white,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        child: Icon(icon, color: foreground, size: 23),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MES PROPRES STATUTS
// ─────────────────────────────────────────────────────────────

/// Le bas de MON statut, comme WhatsApp : un œil et le nombre de vues,
/// centrés, sous une petite flèche. La longue barre « vues · j'aime ·
/// réponses » a disparu : les réponses sont dans les discussions, et le
/// détail de qui a vu (et aimé) s'ouvre d'un appui ou d'un glissement.
class _MyStatusFooter extends StatelessWidget {
  const _MyStatusFooter({super.key, required this.status, required this.onTap});

  final MeshStatusRecord status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vues = StorageService.getStatusViewers(status.id).length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 6, 40, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 22)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 2, end: -2, duration: 900.ms, curve: Curves.easeInOut),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$vues',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: DesignTokens.durationNormal);
  }
}

/// La feuille qui remonte du bas et détaille qui a vu, qui a aimé et qui
/// a répondu à MON statut.
class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet({required this.status});
  final MeshStatusRecord status;

  static String _timeAgo(AppLocalizations l10n, DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return l10n.svJustNow;
    if (diff.inMinutes < 60) return l10n.svMinutesAgo(diff.inMinutes);
    return l10n.svHoursAgo(diff.inHours);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vues = StorageService.getStatusViewers(status.id);
    final aime = {
      for (final f in StorageService.getStatusFeedback(status.id))
        if (f.isLike) f.authorId,
    };

    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.svSeenBy(vues.length),
                  style: OuroTypography.title3.copyWith(color: OuroColors.label)),
              const SizedBox(height: DesignTokens.space4),
              Flexible(
                child: vues.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            l10n.svNoViewsYet,
                            textAlign: TextAlign.center,
                            style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel),
                          ),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final v in vues)
                            _row(
                              pseudo: v.viewerPseudo,
                              peerId: v.viewerId,
                              trailing: _timeAgo(l10n, v.viewedAt),
                              aime: aime.contains(v.viewerId),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({
    required String pseudo,
    String? subtitle,
    required String trailing,
    bool aime = false,
    String? peerId,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PeerAvatar(
            pseudo: pseudo,
            radius: 17,
            imagePath: AvatarService.cheminPair(peerId),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pseudo,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    )),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.footnote
                          .copyWith(color: OuroColors.secondaryLabel)),
              ],
            ),
          ),
          if (aime) ...[
            Icon(Icons.favorite_rounded, color: OuroColors.systemRed, size: 18),
            const SizedBox(width: 8),
          ],
          const SizedBox(width: 8),
          Text(trailing,
              style: OuroTypography.caption1
                  .copyWith(color: OuroColors.tertiaryLabel)),
        ],
      ),
    );
  }
}


/// LES HUIT ÉMOJIS DE RÉACTION, ET IL N'Y EN A QU'UNE LISTE.
///
/// ⚠️ IL Y EN AVAIT DEUX, DANS CE MÊME FICHIER, et elles n'étaient même
/// pas dans le même ordre (😍😂😮… ici, 😂😮😍… dans la barre de réponse).
/// Deux copies d'une même chose finissent toujours par diverger — celles-ci
/// avaient déjà commencé.
const List<String> kEmojisReactionStatut = [
  '😍', '😂', '😮', '😢', '👏', '🔥', '🎉', '💯',
];

/// Les réactions rapides de WhatsApp : huit émojis au-dessus du champ de
/// réponse, sur le verre dépoli d'iOS. Un appui envoie la réaction comme une
/// réponse au statut — elle arrive dans la discussion, citée.
class _ReactionsRapides extends StatelessWidget {
  const _ReactionsRapides({required this.onChoisir});

  final ValueChanged<String> onChoisir;

  static const _emojis = kEmojisReactionStatut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x59000000),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _emojis.length; i++)
                  GestureDetector(
                    onTap: () => onChoisir(_emojis[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Text(_emojis[i], style: const TextStyle(fontSize: 28)),
                    ),
                  )
                      .animate(delay: (22 * i).ms)
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1, 1),
                        duration: 260.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 140.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
