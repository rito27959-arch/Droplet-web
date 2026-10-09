// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE MESSAGE VIDÉO ROND — celui qu'on enregistre en maintenant le même
// bouton que le vocal, après l'avoir fait basculer en caméra d'un appui
// court.
//
// ── POURQUOI UN ROND, ET PAS UNE VIDÉO ORDINAIRE ──────────────────────
//
// Parce que ce n'est pas le même objet. Une vidéo qu'on envoie, on l'a
// tournée, regardée, peut-être recadrée ; elle a un début et une fin
// choisis. Un message vidéo rond, c'est un vocal avec un visage : on le
// fait en une prise, sans cadrage, et on ne le regarde pas avant de
// l'envoyer. La forme ronde dit exactement cela — il n'y a pas de cadre,
// donc rien à cadrer.
//
// ── ⚠️ LE FICHIER N'EST PAS CARRÉ, L'AFFICHAGE L'EST ──────────────────
//
// Telegram encode un vrai carré de 384×384 : il a son propre encodeur
// OpenGL qui recadre pendant la capture. Droplet n'en a pas, et en écrire
// un pour obtenir un fichier carré là où un cercle à l'affichage donne
// exactement la même image ne se justifie pas.
//
// Ce que ça coûte vraiment : les pixels hors du cercle sont encodés pour
// rien — environ 27 % du débit sur une source 4:3. C'est pour cela que la
// capture se fait en `medium` et non en `high`, et que le fichier repasse
// par la compression avant de partir sur le maillage. Ce que ça ne coûte
// pas : une seule ligne de rendu, parce que l'image AFFICHÉE est
// identique au pixel près.
//
// ── LES VALEURS, RELEVÉES CHEZ TELEGRAM ───────────────────────────────
//
//   • côté 384 (MessagesController.java:1635)
//   • débit vidéo 1000 kb/s (MessagesController.java:1636)
//   • débit audio 64 kb/s (MessagesController.java:1637)
//   • coupure à 59,5 s (ChatActivityEnterView.java:14350-14355)
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:video_player/video_player.dart';

import '../../design_system/ouro_colors.dart';

/// Le côté de la vidéo ronde, une fois compressée.
const int kCoteVideoRonde = 384;

/// Le débit visé, image et son réunis.
const int kDebitVideoRonde = (1000 + 64) * 1024;

/// La durée maximale.
///
/// ⚠️ ON COUPE À 59,5 ET NON À 60. Laisser filer jusqu'à la seconde ronde
/// produit régulièrement un fichier de 60,2 s qui se fait rejeter par le
/// contrôle de durée côté réception — et l'utilisateur perd une minute
/// d'enregistrement sans comprendre pourquoi.
const Duration kDureeMaxVideoRonde = Duration(milliseconds: 59500);

/// Le `type` porté par le message, pour que la bulle sache qu'elle doit
/// être ronde. La colonne est un texte libre : aucune migration.
const String kTypeVideoRonde = 'video_rond';

/// Combien de temps on laisse à l'encodeur avant d'arrêter.
///
/// ⚠️ CE DÉLAI N'EST PAS UNE PRÉCAUTION THÉORIQUE. Un appui très bref
/// arrive avant la première image encodée : Android referme alors un
/// fichier vide en signalant `ERROR_NO_VALID_DATA`. Plutôt que de refuser
/// la prise, on attend le peu qui manque — l'utilisateur obtient un clip
/// très court, ce qu'il demandait, au lieu d'un message d'erreur. La
/// leçon vient du compositeur de statuts, où le cas s'est réellement
/// produit.
const Duration _dureeMinimale = Duration(milliseconds: 400);

/// Possède la caméra pendant un enregistrement rond.
///
/// ⚠️ SÉPARÉ DU WIDGET D'APERÇU, ET C'EST VOULU. La caméra survit à des
/// reconstructions d'arbre — on glisse le doigt, l'état change dix fois
/// par seconde — et un `CameraController` recréé en cours
/// d'enregistrement perd le fichier. Le contrôleur vit donc dans l'écran,
/// pas dans le widget qui l'affiche.
class CameraRonde extends ChangeNotifier {
  CameraController? _camera;
  List<CameraDescription> _appareils = const [];
  DateTime? _debut;
  Timer? _coupure;
  bool _enregistre = false;
  bool _frontale = true;

  CameraController? get camera => _camera;
  bool get prete => _camera?.value.isInitialized ?? false;
  bool get enregistre => _enregistre;
  DateTime? get debut => _debut;

  /// Y a-t-il une caméra sur cet appareil ?
  ///
  /// C'est ce qui décide si la bascule micro ↔ caméra existe. Sur un
  /// appareil sans caméra, proposer le geste serait proposer une porte
  /// peinte sur un mur.
  Future<bool> disponible() async {
    try {
      if (_appareils.isEmpty) _appareils = await availableCameras();
      return _appareils.isNotEmpty;
    } catch (e) {
      debugPrint('[Vidéo ronde] caméras illisibles: $e');
      return false;
    }
  }

  /// Allume la caméra sans enregistrer : c'est ce qui se passe dès que le
  /// bouton bascule en mode caméra, pour que l'aperçu soit déjà là quand
  /// le doigt se pose.
  ///
  /// ⚠️ ALLUMER PREND DU TEMPS — souvent 300 à 600 ms. L'allumer au
  /// moment de la pose du doigt ferait manquer la première seconde, qui
  /// est précisément celle où l'on dit bonjour.
  Future<void> preparer() async {
    if (_camera != null) return;
    if (!await disponible()) return;
    try {
      final choisie = _appareils.firstWhere(
        (c) =>
            c.lensDirection ==
            (_frontale ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => _appareils.first,
      );
      final c = CameraController(
        choisie,
        // ⚠️ `medium` ET NON `high`. La cible est un cercle de 384 points ;
        // capturer en 1080p pour le réduire ensuite ne change rien à
        // l'image finale, chauffe le téléphone et remplit le disque d'un
        // fichier intermédiaire dix fois trop gros.
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await c.initialize();
      _camera = c;
      notifyListeners();
    } catch (e) {
      debugPrint('[Vidéo ronde] ouverture impossible: $e');
    }
  }

  /// Retourne la caméra. L'aperçu se rallume de lui-même.
  ///
  /// ⚠️ PENDANT UNE PRISE, ON CHANGE D'OBJECTIF SANS ÉTEINDRE. Éteindre
  /// la caméra arrêterait l'enregistrement et perdrait tout ce qui a été
  /// filmé. `setDescription` bascule l'objectif à chaud, dans le même
  /// fichier — c'est ce que fait Telegram, dont le bouton reste actif
  /// pendant la prise. Si la plateforme refuse, on garde l'objectif
  /// actuel : mieux vaut ne pas se retourner que perdre la vidéo.
  Future<void> retourner() async {
    final c = _camera;
    if (_enregistre && c != null) {
      final cible = _appareils.where((a) =>
          a.lensDirection ==
          (_frontale ? CameraLensDirection.back : CameraLensDirection.front));
      if (cible.isEmpty) return;
      try {
        await c.setDescription(cible.first);
        _frontale = !_frontale;
        notifyListeners();
      } catch (e) {
        debugPrint('[Vidéo ronde] retournement refusé pendant la prise: $e');
      }
      return;
    }
    _frontale = !_frontale;
    await eteindre();
    await preparer();
  }

  Future<void> demarrer() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized || _enregistre) return;
    try {
      await c.startVideoRecording();
      _enregistre = true;
      _debut = DateTime.now();
      // La coupure est armée ici, pas surveillée par l'interface : un
      // écran qui se fige n'arrêterait pas l'enregistrement, et le
      // fichier grossirait sans limite.
      _coupure = Timer(kDureeMaxVideoRonde, () {
        if (_enregistre) auTempsMax?.call();
      });
      notifyListeners();
    } catch (e) {
      debugPrint('[Vidéo ronde] démarrage impossible: $e');
    }
  }

  /// Appelé quand la durée maximale est atteinte. L'écran y branche son
  /// envoi : la vidéo part, exactement comme si le doigt s'était levé.
  VoidCallback? auTempsMax;

  /// Arrête et rend le fichier, ou `null` si [garder] est faux.
  Future<File?> arreter({required bool garder}) async {
    final c = _camera;
    _coupure?.cancel();
    if (c == null || !_enregistre) return null;

    final debut = _debut;
    if (debut != null) {
      final ecoule = DateTime.now().difference(debut);
      if (ecoule < _dureeMinimale) {
        await Future<void>.delayed(_dureeMinimale - ecoule);
      }
    }

    XFile? fichier;
    try {
      fichier = await c.stopVideoRecording();
    } catch (e) {
      debugPrint('[Vidéo ronde] arrêt impossible: $e');
    }
    _enregistre = false;
    _debut = null;
    notifyListeners();

    if (fichier == null) return null;
    if (!garder) {
      // ⚠️ ON EFFACE TOUT DE SUITE. Un enregistrement annulé qui reste sur
      // le disque est une vidéo de quelqu'un, prise sans qu'il l'ait
      // voulu, dans un dossier que personne n'ira vider.
      try {
        await File(fichier.path).delete();
      } catch (_) {}
      return null;
    }
    return File(fichier.path);
  }

  Future<void> eteindre() async {
    _coupure?.cancel();
    final c = _camera;
    _camera = null;
    _enregistre = false;
    _debut = null;
    notifyListeners();
    try {
      await c?.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    _coupure?.cancel();
    unawaited(_camera?.dispose());
    super.dispose();
  }
}

/// L'aperçu circulaire, à la place du cercle de micro.
class ApercuVideoRond extends StatelessWidget {
  const ApercuVideoRond({
    super.key,
    required this.camera,
    required this.diametre,
  });

  final CameraController? camera;
  final double diametre;

  @override
  Widget build(BuildContext context) {
    final c = camera;
    return SizedBox.square(
      dimension: diametre,
      child: ClipOval(
        child: ColoredBox(
          color: OuroColors.tertiarySystemFill,
          child: c == null || !c.value.isInitialized
              ? const SizedBox.shrink()
              // ⚠️ `cover` DANS UN `FittedBox`, PAS `CameraPreview` NU.
              // L'aperçu arrive en 4:3 ; posé tel quel dans un disque, il
              // s'écraserait en ovale et les visages s'élargiraient. Ici
              // on prend le carré central de l'image, ce que fera aussi
              // le lecteur — donc ce qu'on voit en enregistrant est
              // exactement ce que verra le destinataire.
              : FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: c.value.previewSize?.height ?? diametre,
                    height: c.value.previewSize?.width ?? diametre,
                    child: CameraPreview(c),
                  ),
                ),
        ),
      ),
    );
  }
}

/// L'aperçu PENDANT LA PRISE : le grand disque au milieu de l'écran, et
/// l'anneau blanc qui fait le tour à mesure que la minute s'écoule.
///
/// ⚠️ GRAND ET CENTRÉ, PAS ANCRÉ SUR LE MICRO. C'était la différence la
/// plus visible avec Telegram : notre aperçu faisait 142 points, posé sur
/// le bouton, sous le pouce. Telegram le pose au CENTRE de l'écran, à la
/// largeur de l'écran moins 28 points (`AndroidUtilities`, l.2800 :
/// `roundPlayingMessageSize = min(largeur, hauteur) - dp(28)`) — on se
/// voit comme dans un miroir, et c'est bien le but : on se cadre.
///
/// L'ENTRÉE (`InstantCameraView.startAnimation`, l.869-929) : 180 ms,
/// décélération, le disque part d'un dixième de sa taille, transparent,
/// décalé d'une demi-hauteur vers le bas — il « monte » depuis le bouton.
///
/// L'ANNEAU (`onDraw`, l.612-629) : trait blanc de 3, arrondi, posé à 8
/// points AUTOUR du disque, départ à midi, une minute pour un tour.
class ApercuVideoRondEnregistrement extends StatefulWidget {
  const ApercuVideoRondEnregistrement({
    super.key,
    required this.camera,
    required this.debut,
    required this.diametre,
  });

  final CameraController? camera;

  /// Le départ de la prise ; nul tant qu'elle n'a pas commencé.
  final DateTime? debut;

  final double diametre;

  /// (InstantCameraView.java:928)
  static const Duration dureeEntree = Duration(milliseconds: 180);

  /// L'écart entre le disque et son anneau. (InstantCameraView.java:615)
  static const double ecartAnneau = 8;

  /// (InstantCameraView.java:286)
  static const double epaisseurAnneau = 3;

  @override
  State<ApercuVideoRondEnregistrement> createState() =>
      _ApercuVideoRondEnregistrementState();
}

class _ApercuVideoRondEnregistrementState
    extends State<ApercuVideoRondEnregistrement>
    with TickerProviderStateMixin {
  late final AnimationController _entree = AnimationController(
    vsync: this,
    duration: ApercuVideoRondEnregistrement.dureeEntree,
  )..forward();

  /// L'anneau avance à chaque image : un minuteur à la seconde le ferait
  /// avancer par crans de six degrés, ce qui se voit.
  ///
  /// ⚠️ DÉMARRÉ DANS `initState`, PAS DANS L'INITIALISEUR. Un champ `late`
  /// n'est construit qu'à sa première lecture — et ici, la première
  /// lecture serait celle de `dispose()`. L'anneau ne tournerait jamais.
  late final Ticker _horloge = createTicker((_) {
    if (mounted) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    _horloge.start();
  }

  @override
  void dispose() {
    _horloge.dispose();
    _entree.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ `DecelerateInterpolator` d'Android = `Curves.decelerate`
    // (1 − (1 − t)²) : c'est exactement la même courbe.
    final t = Curves.decelerate.transform(_entree.value);
    final debut = widget.debut;
    // ⚠️ UN TOUR = LA DURÉE MAXIMALE RÉELLE (59,5 s), pas 60. Telegram
    // compte sur 60 000 ms ; chez nous la prise s'arrête à 59,5 s, et un
    // anneau calé sur 60 s s'arrêterait à une demi-seconde de se fermer —
    // un cercle presque complet a l'air d'un bug.
    final progression = debut == null
        ? 0.0
        : (DateTime.now().difference(debut).inMilliseconds /
                kDureeMaxVideoRonde.inMilliseconds)
            .clamp(0.0, 1.0);
    final d = widget.diametre;
    const e = ApercuVideoRondEnregistrement.ecartAnneau;

    return Transform.translate(
      offset: Offset(0, (1 - t) * MediaQuery.sizeOf(context).height / 2),
      child: Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.1 + 0.9 * t,
          child: SizedBox.square(
            dimension: d + 2 * e,
            child: CustomPaint(
              foregroundPainter: _PeintreAnneau(progression: progression),
              child: Padding(
                padding: const EdgeInsets.all(e),
                child: ApercuVideoRond(camera: widget.camera, diametre: d),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeintreAnneau extends CustomPainter {
  const _PeintreAnneau({required this.progression});

  final double progression;

  @override
  void paint(Canvas toile, Size taille) {
    if (progression <= 0) return;
    // Le trait est CENTRÉ sur le cercle à 8 points du disque, comme chez
    // Telegram : il déborde d'un point et demi de la boîte, ce qui est
    // sans conséquence (`CustomPaint` ne découpe pas).
    toile.drawArc(
      Offset.zero & taille,
      -math.pi / 2,
      2 * math.pi * progression,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = ApercuVideoRondEnregistrement.epaisseurAnneau
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PeintreAnneau vieux) => vieux.progression != progression;
}

/// La bulle de lecture : un disque qui joue en boucle.
///
/// ⚠️ ELLE DÉMARRE MUETTE ET SE JOUE TOUTE SEULE. C'est le comportement de
/// Telegram, et il est juste : ces messages arrivent par dizaines dans un
/// fil, et des dizaines de voix qui se déclenchent au défilement seraient
/// insupportables. Un toucher rend le son.
class BulleVideoRonde extends StatefulWidget {
  const BulleVideoRonde({
    super.key,
    required this.chemin,
    this.diametre = 200,
  });

  final String chemin;
  final double diametre;

  @override
  State<BulleVideoRonde> createState() => _BulleVideoRondeState();
}

class _BulleVideoRondeState extends State<BulleVideoRonde> {
  VideoPlayerController? _lecteur;
  bool _sonActif = false;

  @override
  void initState() {
    super.initState();
    _ouvrir();
  }

  Future<void> _ouvrir() async {
    try {
      final l = VideoPlayerController.file(File(widget.chemin));
      await l.initialize();
      if (!mounted) {
        await l.dispose();
        return;
      }
      await l.setVolume(0);
      await l.setLooping(true);
      await l.play();
      setState(() => _lecteur = l);
    } catch (e) {
      debugPrint('[Vidéo ronde] lecture impossible: $e');
    }
  }

  @override
  void dispose() {
    _lecteur?.dispose();
    super.dispose();
  }

  Future<void> _basculerSon() async {
    final l = _lecteur;
    if (l == null) return;
    _sonActif = !_sonActif;
    await l.setVolume(_sonActif ? 1 : 0);
    if (_sonActif) {
      // Remettre au début en allumant le son : on veut entendre le
      // message depuis son début, pas reprendre au milieu d'une phrase.
      await l.seekTo(Duration.zero);
      await l.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = _lecteur;
    return GestureDetector(
      onTap: _basculerSon,
      child: SizedBox.square(
        dimension: widget.diametre,
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: OuroColors.tertiarySystemFill),
              if (l != null && l.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: l.value.size.width,
                    height: l.value.size.height,
                    child: VideoPlayer(l),
                  ),
                ),
              if (l != null && l.value.isInitialized)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        _sonActif
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
