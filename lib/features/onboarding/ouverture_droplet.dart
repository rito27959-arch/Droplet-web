// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'OUVERTURE DE DROPLET : les quelques dixièmes de seconde entre l'appui
// sur l'icône et le premier écran.
//
// ── L'idée, une seule ─────────────────────────────────────────────────
//
// « La goutte touche, l'onde ouvre. » Le logo est une goutte dans une
// bulle de discussion : tout le mouvement en découle, comme le ferait
// de l'eau.
//
//   1. La goutte s'appuie sur sa base (elle s'écrase de 7 %) puis se
//      relâche — avec l'oscillation amortie d'un liquide, pas le rebond
//      d'une balle.
//   2. Ce relâchement émet une ONDE, un fin cercle qui s'élargit en
//      ralentissant et s'efface, comme un rond dans l'eau.
//   3. L'onde atteint la paroi de la bulle, qui se tend : elle gonfle de
//      3 % et revient, comme une membrane.
//   4. L'onde, rendue par la paroi, continue vers l'extérieur et c'est
//      ELLE qui ouvre l'app : un cercle qui grandit depuis la bulle et
//      découvre l'écran des discussions, en accélérant pour s'écarter du
//      chemin.
//
// Au tout premier lancement, l'étape 4 change : le nom « Droplet »
// apparaît sous la marque, puis la marque GLISSE jusqu'à sa place dans
// l'écran de bienvenue pendant que le fond s'efface. L'objet que l'on
// vient de voir est celui qu'on retrouve : aucune image n'en remplace
// une autre.
//
// ── Les règles tenues ─────────────────────────────────────────────────
//
// • CONTINUITÉ AVEC LE SYSTÈME. L'écran de lancement natif (Android 12+,
//   les plus anciens et iOS) montre la MÊME marque, à la MÊME taille
//   (112 points), au MÊME endroit (le centre exact de l'écran), sur le
//   même fond. La première image de Flutter est identique au pixel près
//   et le mouvement ne commence qu'ensuite.
// • LE FOND SUIT LE TÉLÉPHONE, PAS L'APP. L'écran natif ne peut pas
//   connaître le thème choisi dans Droplet ; l'ouverture reprend donc le
//   fond du système, et c'est l'onde qui fait passer au thème de l'app.
// • RIEN QUI FASSE ATTENDRE. 0,9 s jusqu'aux discussions, dont 0,4 s
//   pendant lesquelles elles sont déjà en train d'apparaître. Si l'app
//   n'est pas prête, la goutte respire (une onde toutes les 1,5 s) et,
//   au-delà de 1,6 s d'attente, une ligne discrète dit ce qui se passe.
// • RÉDUIRE LES ANIMATIONS : ni écrasement, ni onde, ni glissement — un
//   simple fondu dès que l'app est prête.
// • UNE SEULE FOIS PAR LANCEMENT À FROID. Revenir dans l'app ne rejoue
//   rien : l'écran est déjà là.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../design_system/droplet_design.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/marque_droplet.dart';

/// La hauteur de la marque dans l'ouverture — la même que celle de
/// l'écran de lancement natif (`drawable/marque_lancement.xml`, iOS
/// `LaunchImage`). Ne pas la changer sans changer les deux.
const double kHauteurMarqueOuverture = 112;

/// Où la marque doit se poser à la fin d'une ouverture vers l'accueil.
@immutable
class CibleMarque {
  const CibleMarque(this.rect, this.couleur);

  /// La boîte de la marque, en coordonnées globales.
  final Rect rect;

  /// Sa couleur à l'arrivée (l'accent de l'app, qui peut différer de
  /// celle de l'écran natif si le thème de l'app n'est pas celui du
  /// téléphone).
  final Color couleur;
}

class OuvertureDroplet extends StatefulWidget {
  const OuvertureDroplet({super.key, required this.versAccueil, required this.child});

  /// Vrai si le premier écran est l'écran de bienvenue : la marque y
  /// rejoint sa place au lieu de s'ouvrir sur les discussions.
  final bool versAccueil;

  /// L'application, qui se construit dessous dès la première image.
  final Widget child;

  /// Vrai tant que l'ouverture couvre l'écran. L'écran de bienvenue
  /// attend qu'elle soit finie pour faire entrer ses textes.
  static final ValueNotifier<bool> active = ValueNotifier<bool>(false);

  /// Vrai si la marque a glissé jusqu'à l'écran de bienvenue : celui-ci
  /// l'affiche alors directement, sans la faire apparaître une seconde
  /// fois.
  static bool aRejointLAccueil = false;

  /// La place de la marque dans l'écran de bienvenue (voir
  /// [CibleOuverture]).
  static final ValueNotifier<CibleMarque?> cible = ValueNotifier<CibleMarque?>(null);

  static bool _jouee = false;

  /// Retient l'ouverture tant qu'un écran n'a pas ce qu'il lui faut pour
  /// s'afficher (une liste à charger, par exemple) : la goutte « respire »
  /// au lieu d'ouvrir sur un écran vide. Chaque [retenir] appelle un
  /// [liberer]. L'ouverture ne s'éternise jamais au-delà de 8 s.
  static void retenir() => _retenues.value++;
  static void liberer() {
    if (_retenues.value > 0) _retenues.value--;
  }

  static final ValueNotifier<int> _retenues = ValueNotifier<int>(0);

  @override
  State<OuvertureDroplet> createState() => _OuvertureDropletState();
}

enum _Phase { entree, attente, revelation, passage, fondu, finie }

// ── LE RYTHME (millisecondes depuis la première image) ───────────────
//
// Chaque valeur a été ajustée image par image (voir
// `test/ouverture_rendu_test.dart`, qui rend la séquence au ralenti).
// L'entrée : la goutte tombe dans la bulle.
const double _tChute = 90; // la première image (la bulle seule) reste celle du système
const double _tPose = 430; // 340 ms de chute : la goutte touche le fond
const double _dOnde = 210; // l'onde va de la goutte à la paroi
const double _tRevelation = 780; // la bulle s'ouvre sur l'app
// La « respiration » d'une attente longue (un appui, une onde).
const double _tAppui = 60;
const double _tRelache = 210;
const double _tImpact = 470;
const double _dRevelation = 440;
const double _tNom = 520; // le nom s'écrit
const double _tPassage = 1400; // premier lancement : la marque rejoint l'accueil
const double _dPassage = 520;
const double _cycleAttente = 1500;
const double _legendeApres = 1600;
const double _dFondu = 220; // « Réduire les animations »

class _OuvertureDropletState extends State<OuvertureDroplet> with SingleTickerProviderStateMixin {
  late final bool _jouer;
  Ticker? _ticker;
  final ValueNotifier<double> _t = ValueNotifier<double>(0);
  _Phase _phase = _Phase.entree;
  bool _premieresImages = false;
  bool get _pret => _premieresImages && OuvertureDroplet._retenues.value == 0;
  double _debutAttente = 0;
  double _debutSortie = 0;
  bool _reduit = false;

  /// Délai maximal d'attente : au-delà, on ouvre quoi qu'il arrive. Un
  /// écran de démarrage ne doit jamais pouvoir enfermer quelqu'un.
  static const double _attenteMax = 8000;

  @override
  void initState() {
    super.initState();
    _jouer = !OuvertureDroplet._jouee;
    OuvertureDroplet._jouee = true;
    if (!_jouer) return;
    OuvertureDroplet.active.value = true;
    // « Prête » = l'application a construit et dessiné sa première image
    // dessous, et une deuxième (celle où les images et polices chargées
    // pendant la première sont en place).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _premieresImages = true);
    });
    _ticker = createTicker(_tic)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  void _tic(Duration ecoule) {
    final t = ecoule.inMicroseconds / 1000.0;
    _t.value = t;
    switch (_phase) {
      case _Phase.entree:
        if (_reduit) {
          final minimum = widget.versAccueil ? 650.0 : 200.0;
          if ((_pret && t >= minimum) || t > _attenteMax) _sortir(t, _Phase.fondu);
          return;
        }
        final echeance = widget.versAccueil ? _tPassage : _tRevelation;
        if (t >= echeance) {
          if (_pret) {
            _sortir(t, _sortieNormale());
          } else {
            _phase = _Phase.attente;
            _debutAttente = t;
            setState(() {});
          }
        }
      case _Phase.attente:
        if (_pret || t - _debutAttente > _attenteMax) _sortir(t, _sortieNormale());
      case _Phase.revelation:
        if (t - _debutSortie >= _dRevelation) _finir();
      case _Phase.passage:
        if (t - _debutSortie >= _dPassage) _finir();
      case _Phase.fondu:
        if (t - _debutSortie >= _dFondu) _finir();
      case _Phase.finie:
        break;
    }
  }

  _Phase _sortieNormale() {
    if (_reduit) return _Phase.fondu;
    // Vers l'accueil, la marque glisse à sa place — si cette place est
    // connue. Sinon (mise en page pas encore faite, écran inattendu), on
    // ouvre comme d'habitude plutôt que de viser au hasard.
    if (widget.versAccueil && OuvertureDroplet.cible.value != null) return _Phase.passage;
    return _Phase.revelation;
  }

  void _sortir(double t, _Phase phase) {
    _debutSortie = t;
    if (phase == _Phase.passage) OuvertureDroplet.aRejointLAccueil = true;
    setState(() => _phase = phase);
  }

  void _finir() {
    _ticker?.stop();
    setState(() => _phase = _Phase.finie);
    OuvertureDroplet.active.value = false;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _t.dispose();
    if (_jouer && _phase != _Phase.finie) OuvertureDroplet.active.value = false;
    super.dispose();
  }

  // ── Ce que chaque phase fait de l'application dessous ──────────────

  /// L'app arrive très légèrement plus grande et se pose à sa taille
  /// pendant que l'onde l'ouvre : on entre DANS l'écran.
  double _echelleApp(double t) {
    if (_phase == _Phase.revelation) {
      final p = _seg(t, _debutSortie, _debutSortie + _dRevelation);
      return 1.035 - 0.035 * Curves.easeOutCubic.transform(p);
    }
    if (_phase == _Phase.entree || _phase == _Phase.attente) {
      return (widget.versAccueil || _reduit) ? 1 : 1.035;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ LA STRUCTURE NE CHANGE JAMAIS ENTRE LES PHASES. Retirer le
    // `Transform` ou l'`ExcludeSemantics` à la fin démonterait toute
    // l'application (et son état) au moment précis où elle apparaît.
    final fini = !_jouer || _phase == _Phase.finie;
    final app = ExcludeSemantics(
      excluding: !fini,
      child: _jouer
          ? AnimatedBuilder(
              animation: _t,
              builder: (context, enfant) {
                final e = fini ? 1.0 : _echelleApp(_t.value);
                return Transform.scale(scale: e, child: enfant);
              },
              child: widget.child,
            )
          : widget.child,
    );
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        Positioned.fill(child: app),
        if (!fini) Positioned.fill(child: _scene(context)),
      ],
    );
  }

  Widget _scene(BuildContext context) {
    final sombre = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final fond = sombre ? DDSombre.fond : DDClair.fond;
    final marque = (sombre ? DDAccents.parCle('bleu').sombre : DDAccents.parCle('bleu').clair);
    final texte = sombre ? DDSombre.texte : DDClair.texte;
    final texte2 = sombre ? DDSombre.texte2 : DDClair.texte2;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: 'Droplet',
      liveRegion: _phase == _Phase.attente,
      // Pas de toucher pendant l'ouverture : un doigt posé un peu tôt ne
      // doit pas déclencher un bouton invisible sous l'onde.
      child: AbsorbPointer(
        child: LayoutBuilder(
          builder: (context, c) {
            final taille = Size(c.maxWidth, c.maxHeight);
            final centre = taille.center(Offset.zero);
            return AnimatedBuilder(
              animation: _t,
              builder: (context, _) {
                final t = _t.value;
                final etat = _etat(t, taille, centre, fond, marque);
                return Stack(
                  textDirection: TextDirection.ltr,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: _PeintreOuverture(etat)),
                      ),
                    ),
                    // Le nom, sous la marque — au premier lancement, et
                    // pendant une attente (il dit alors QUI se prépare).
                    if (etat.nom > 0 && etat.revele > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: centre.dy + kHauteurMarqueOuverture / 2 + 22 + 6 * (1 - Curves.easeOutCubic.transform(etat.revele)),
                        child: Opacity(
                          opacity: etat.nom * etat.opaciteScene,
                          child: _NomRevele(
                            progression: etat.revele,
                            style: TextStyle(
                              fontFamily: 'Inter Tight',
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              height: 1.1,
                              letterSpacing: -0.6,
                              color: texte,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    if (etat.legende > 0)
                      Positioned(
                        left: 24,
                        right: 24,
                        top: centre.dy + kHauteurMarqueOuverture / 2 + 22 + 44,
                        child: Opacity(
                          opacity: etat.legende * etat.opaciteScene,
                          child: Text(
                            l10n.splashPreparing,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              height: 1.3,
                              color: texte2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Tout ce qui se dessine à l'instant [t].
  _Etat _etat(double t, Size taille, Offset centre, Color fond, Color couleur) {
    const h = kHauteurMarqueOuverture;
    var pose = PoseMarque.repos;
    var centreMarque = centre;
    var hauteur = h;
    var couleurMarque = couleur;
    var opaciteScene = 1.0;
    double? rayonTrou;
    var voile = 0.0;
    var onde = _Onde.aucune;
    var nom = 0.0;
    var revele = 0.0;
    var legende = 0.0;

    if (_reduit) {
      // Sans mouvement : la goutte apparaît dans la bulle en fondu.
      pose = PoseMarque(opaciteGoutte: _seg(t, 60, 260));
      if (widget.versAccueil) {
        nom = 1;
        revele = 1;
      }
      if (_phase == _Phase.fondu) {
        opaciteScene = 1 - _seg(t, _debutSortie, _debutSortie + _dFondu);
      }
      return _Etat(
        fond: fond,
        couleur: couleurMarque,
        centre: centreMarque,
        hauteur: hauteur,
        pose: pose,
        onde: onde,
        rayonTrou: null,
        voile: 0,
        opaciteScene: opaciteScene,
        nom: nom,
        revele: revele,
        legende: 0,
      );
    }

    // ── 1 à 3 : la goutte tombe dans la bulle, l'onde, la paroi.
    final e = _chute(t);
    pose = PoseMarque(
      ecrasement: e.ecrasement,
      gonflement: e.gonflement,
      decalageGoutte: e.decalage,
      opaciteGoutte: e.opaciteGoutte,
    );
    onde = e.onde;
    final eclaboussure = t >= _tPose ? t - _tPose : -1.0;

    // Une attente prolongée : la goutte respire, une onde toutes les
    // 1,5 s. Chaque cycle S'AJOUTE au mouvement en cours au lieu de le
    // remplacer (la paroi oscille encore de la première onde quand le
    // premier cycle commence) : aucune discontinuité. Une fois la sortie
    // lancée, plus aucun cycle ne commence, mais le dernier va à son
    // terme.
    if (_debutAttente > 0) {
      final fin = _phase == _Phase.attente ? t : _debutSortie;
      final k = ((fin - _debutAttente) / _cycleAttente).floor();
      final g = _geste(t - (_debutAttente + k * _cycleAttente), debut: 40, amplitude: 0.05);
      pose = PoseMarque(
        ecrasement: pose.ecrasement + g.ecrasement,
        gonflement: pose.gonflement + g.gonflement,
        decalageGoutte: pose.decalageGoutte,
        opaciteGoutte: pose.opaciteGoutte,
      );
      if (g.onde.opacite > 0) onde = g.onde;
      revele = _seg(fin - _debutAttente, 600, 1020);
      legende = _seg(fin - _debutAttente, _legendeApres, _legendeApres + 300);
    }

    // Le nom, au premier lancement.
    if (widget.versAccueil) {
      revele = math.max(revele, _seg(t, _tNom, _tNom + 420));
    }
    nom = revele > 0 ? 1 : 0;

    // ── 4a : on entre dans la bulle.
    //
    // La bulle, tendue par l'onde, s'agrandit — toute la marque avec elle,
    // autour du centre de son cercle — et son intérieur devient la
    // fenêtre par laquelle on voit l'app : on « entre » dans la
    // conversation. Lente au départ (elle prolonge le gonflement de la
    // paroi), elle accélère pour s'écarter du chemin. La goutte s'efface
    // la première, puis l'anneau, avant d'être assez grand pour devenir
    // une bande de couleur ; l'intérieur de la bulle se dissout en même
    // temps, pour que l'app n'y apparaisse pas d'un coup.
    if (_phase == _Phase.revelation) {
      final p = _seg(t, _debutSortie, _debutSortie + _dRevelation);
      final cB = centre + GeometrieMarque.centreBulle * h;
      final loin = [
        Offset.zero,
        Offset(taille.width, 0),
        Offset(0, taille.height),
        Offset(taille.width, taille.height),
      ].map((coin) => (coin - cB).distance).reduce(math.max);
      final rInt = GeometrieMarque.rayonInterieurBulle * h * (1 + pose.gonflement);
      final kMax = (loin + 4) / rInt;
      final k = 1 + (kMax - 1) * Curves.easeInCubic.transform(p);
      rayonTrou = rInt * k;
      voile = 1 - Curves.easeInOutSine.transform(_seg(p, 0, 0.4));
      centreMarque = cB + (centre - cB) * k;
      pose = PoseMarque(
        ecrasement: pose.ecrasement,
        gonflement: pose.gonflement,
        echelle: k,
        decalageGoutte: pose.decalageGoutte,
        opacite: 1 - Curves.easeInCubic.transform(_seg(k, 1, 2.6)),
        opaciteGoutte: pose.opaciteGoutte * (1 - _seg(k, 1, 1.45)),
      );
      final q = _seg(t, _debutSortie, _debutSortie + 160);
      nom *= 1 - q;
      legende *= 1 - q;
    }

    // ── 4b : la marque rejoint l'accueil.
    if (_phase == _Phase.passage) {
      final cible = OuvertureDroplet.cible.value;
      final p = _seg(t, _debutSortie, _debutSortie + _dPassage);
      final m = Curves.easeInOutCubic.transform(p);
      if (cible != null) {
        centreMarque = Offset.lerp(centre, cible.rect.center, m)!;
        hauteur = h + (cible.rect.height - h) * m;
        couleurMarque = Color.lerp(couleur, cible.couleur, m)!;
      }
      opaciteScene = 1;
      // Le fond s'efface un peu plus vite que la marque ne voyage : on
      // voit l'accueil se former autour d'elle avant qu'elle n'arrive.
      final fondu = Curves.easeOutCubic.transform(_seg(t, _debutSortie + 40, _debutSortie + 420));
      nom *= 1 - _seg(t, _debutSortie, _debutSortie + 160);
      legende *= 1 - _seg(t, _debutSortie, _debutSortie + 160);
      return _Etat(
        fond: fond.withValues(alpha: 1 - fondu),
        couleur: couleurMarque,
        centre: centreMarque,
        hauteur: hauteur,
        pose: PoseMarque(gonflement: pose.gonflement * (1 - m), ecrasement: pose.ecrasement * (1 - m)),
        onde: _Onde.aucune,
        rayonTrou: null,
        voile: 0,
        opaciteScene: 1,
        nom: nom,
        revele: revele,
        legende: legende,
        eclaboussure: -1,
      );
    }

    if (_phase == _Phase.fondu) {
      opaciteScene = 1 - _seg(t, _debutSortie, _debutSortie + _dFondu);
    }

    return _Etat(
      fond: fond,
      couleur: couleurMarque,
      centre: centreMarque,
      hauteur: hauteur,
      pose: pose,
      onde: onde,
      rayonTrou: rayonTrou,
      voile: voile,
      opaciteScene: opaciteScene,
      nom: nom,
      revele: revele,
      legende: legende,
      eclaboussure: _phase == _Phase.revelation ? -1 : eclaboussure,
    );
  }
}

/// Le nom, révélé de gauche à droite par un bord adouci — lettre après
/// lettre, comme écrit d'un geste, sans casser l'approche (le crénage)
/// d'Inter Tight, ce que ferait une animation lettre par lettre.
class _NomRevele extends StatelessWidget {
  const _NomRevele({required this.progression, required this.style});

  final double progression;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    // Le bord parcourt le mot en ralentissant sur la fin ; sa douceur
    // (35 % de la largeur) fait apparaître chaque lettre en fondu plutôt
    // que coupée net.
    const douceur = 0.35;
    final x = -douceur + (1 + douceur) * Curves.easeOutCubic.transform(progression);
    final texte = Text('Droplet', textAlign: TextAlign.center, style: style);
    if (progression >= 1) return texte;
    return Center(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => LinearGradient(
          colors: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          stops: [x.clamp(0.0, 1.0), (x + douceur).clamp(0.0, 1.0)],
        ).createShader(r),
        child: texte,
      ),
    );
  }
}

// ── LE GESTE : appui, relâchement, onde, réponse de la paroi ─────────

class _Geste {
  const _Geste(this.ecrasement, this.gonflement, this.onde);
  final double ecrasement;
  final double gonflement;
  final _Onde onde;
}

// ── LA CHUTE : la goutte tombe dans la bulle ─────────────────────────

class _Chute {
  const _Chute(this.decalage, this.ecrasement, this.gonflement, this.opaciteGoutte, this.onde);
  final double decalage;
  final double ecrasement;
  final double gonflement;
  final double opaciteGoutte;
  final _Onde onde;
}

/// D'où part la goutte : au-dessus de la bulle (unités de marque).
const double _hauteurChute = -0.95;

_Chute _chute(double t) {
  // Avant la chute : la bulle seule, comme l'écran de lancement natif.
  if (t < _tChute) return const _Chute(_hauteurChute, 0, 0, 0, _Onde.aucune);

  // La chute : position en t² (la pesanteur), donc vitesse maximale à
  // l'impact. La goutte s'étire en tombant, comme une vraie goutte de
  // pluie, et naît en un instant au-dessus de la bulle.
  if (t < _tPose) {
    final p = _seg(t, _tChute, _tPose);
    return _Chute(
      _hauteurChute * (1 - p * p),
      -0.14 * p * p,
      0,
      Curves.easeOut.transform(_seg(p, 0, 0.22)),
      _Onde.aucune,
    );
  }

  // L'impact : la vitesse se change en écrasement (une impulsion, qui part
  // de zéro AVEC une vitesse), pendant que l'étirement de la chute se
  // relâche. Une vraie goutte : elle s'aplatit franchement, remonte en
  // s'étirant, oscille deux fois et se pose.
  final tau = (t - _tPose) / 1000;
  final ecrasement = 0.24 * _impulsion(tau, periode: 0.26, amortissement: 0.36) -
      0.14 * _relache(tau, periode: 0.26, amortissement: 0.36);

  // L'onde part de l'impact et touche la paroi…
  var onde = _Onde.aucune;
  final tParoi = _tPose + _dOnde;
  if (t <= tParoi) {
    final p = _seg(t, _tPose, tParoi);
    onde = _Onde(
      rayon: GeometrieMarque.rayonVentre + (GeometrieMarque.rayonInterieurBulle - 0.018 - GeometrieMarque.rayonVentre) * Curves.easeOutCubic.transform(p),
      epaisseur: 0.034 - 0.018 * p,
      opacite: 0.5 * math.min(1, p * 7) * math.pow(1 - p, 1.3).toDouble(),
    );
  }
  // … qui se tend sous le choc.
  final gonflement = t >= tParoi ? 0.045 * _impulsion((t - tParoi) / 1000, periode: 0.30, amortissement: 0.38) : 0.0;
  return _Chute(0, ecrasement, gonflement, 1, onde);
}

// L'éclaboussure.
class _Gouttelette {
  const _Gouttelette(this.x, this.y, this.vx, this.vy, this.r);
  final double x, y, vx, vy, r;
}

const _gouttelettes = [
  _Gouttelette(-0.12, 0.25, -0.55, -1.10, 0.032),
  _Gouttelette(0.13, 0.25, 0.62, -1.25, 0.027),
  _Gouttelette(0.02, 0.21, 0.12, -1.50, 0.021),
];
const double _gravite = 7.5; // unités de marque par seconde²
const double _vieGouttelette = 360;

/// Le geste complet, à l'instant [t] (ms), commencé à [debut].
_Geste _geste(double t, {required double debut, required double amplitude}) {
  final tAppui = debut + _tAppui;
  final tRelache = debut + _tRelache;
  final tImpact = debut + _tImpact;

  // L'appui : la goutte descend sur sa base, sans à-coup ni au départ ni
  // à l'arrivée.
  var ecrasement = 0.0;
  if (t >= tAppui && t < tRelache) {
    ecrasement = amplitude * Curves.easeInOutSine.transform(_seg(t, tAppui, tRelache));
  } else if (t >= tRelache) {
    // Le relâchement : oscillateur amorti lâché SANS vitesse initiale —
    // la goutte remonte, s'étire d'un rien (un cinquième de l'appui) et
    // se pose. C'est la tension de surface qui ramène, pas un ressort.
    ecrasement = amplitude * _relache((t - tRelache) / 1000, periode: 0.26, amortissement: 0.45);
  }

  // L'onde : part du ventre de la goutte au relâchement, ralentit en
  // s'élargissant, s'efface en touchant la paroi.
  var onde = _Onde.aucune;
  if (t >= tRelache && t <= tImpact) {
    final p = _seg(t, tRelache, tImpact);
    onde = _Onde(
      rayon: GeometrieMarque.rayonVentre + (GeometrieMarque.rayonInterieurBulle - 0.018 - GeometrieMarque.rayonVentre) * Curves.easeOutCubic.transform(p),
      epaisseur: 0.030 - 0.016 * p,
      opacite: 0.42 * math.min(1, p * 7) * math.pow(1 - p, 1.3).toDouble(),
    );
  }

  // La paroi reçoit l'onde : une impulsion, donc elle part de zéro AVEC
  // une vitesse (et non d'un écart), gonfle de 3 % au plus et revient.
  var gonflement = 0.0;
  if (t >= tImpact) {
    gonflement = 0.03 * (amplitude / 0.075) * _impulsion((t - tImpact) / 1000, periode: 0.32, amortissement: 0.42);
  }
  return _Geste(ecrasement, gonflement, onde);
}

/// Oscillateur sous-amorti lâché d'un écart de 1, vitesse nulle.
double _relache(double s, {required double periode, required double amortissement}) {
  final wd = 2 * math.pi / periode;
  final wn = wd / math.sqrt(1 - amortissement * amortissement);
  final a = amortissement * wn;
  return math.exp(-a * s) * (math.cos(wd * s) + (a / wd) * math.sin(wd * s));
}

/// Réponse à une impulsion, normalisée pour que son premier maximum vaille 1.
double _impulsion(double s, {required double periode, required double amortissement}) {
  final wd = 2 * math.pi / periode;
  final wn = wd / math.sqrt(1 - amortissement * amortissement);
  final a = amortissement * wn;
  final tMax = math.atan(wd / a) / wd;
  final max = math.exp(-a * tMax) * math.sin(wd * tMax);
  return math.exp(-a * s) * math.sin(wd * s) / max;
}

double _seg(double t, double a, double b) => b <= a ? (t >= b ? 1 : 0) : ((t - a) / (b - a)).clamp(0.0, 1.0);

// ── LE DESSIN ────────────────────────────────────────────────────────

@immutable
class _Onde {
  const _Onde({required this.rayon, required this.epaisseur, required this.opacite});
  static const aucune = _Onde(rayon: 0, epaisseur: 0, opacite: 0);

  /// En unités de marque (sa hauteur), autour du centre de la bulle.
  final double rayon;
  final double epaisseur;
  final double opacite;
}

@immutable
class _Etat {
  const _Etat({
    required this.fond,
    required this.couleur,
    required this.centre,
    required this.hauteur,
    required this.pose,
    required this.onde,
    required this.rayonTrou,
    required this.voile,
    required this.opaciteScene,
    required this.nom,
    this.revele = 1,
    this.eclaboussure = -1,
    required this.legende,
  });

  final Color fond;
  final Color couleur;
  final Offset centre;
  final double hauteur;
  final PoseMarque pose;
  final _Onde onde;

  /// Le rayon de l'ouverture (en pixels), ou rien.
  final double? rayonTrou;

  /// L'opacité du fond À L'INTÉRIEUR de l'ouverture : il s'y dissout
  /// pendant que la bulle s'agrandit.
  final double voile;
  final double opaciteScene;
  /// L'opacité du nom (1 une fois là ; baisse quand on quitte l'ouverture).
  final double nom;

  /// Où en est sa RÉVÉLATION, de gauche à droite (0 → 1).
  final double revele;
  final double legende;

  /// Millisecondes depuis que la goutte a touché le fond (négatif : pas
  /// d'éclaboussure à dessiner).
  final double eclaboussure;
}

class _PeintreOuverture extends CustomPainter {
  _PeintreOuverture(this.e);
  final _Etat e;

  @override
  void paint(Canvas canvas, Size size) {
    final o = e.opaciteScene;
    if (o <= 0) return;
    final fond = e.fond.withValues(alpha: e.fond.a * o);
    final h = e.hauteur;
    // Le centre du cercle de la bulle, à l'échelle courante de la marque.
    final centreBulle = e.centre + GeometrieMarque.centreBulle * h * e.pose.echelle;

    // Le fond, percé par l'onde qui ouvre l'app.
    final trou = e.rayonTrou;
    if (trou == null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = fond);
    } else {
      final chemin = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addOval(Rect.fromCircle(center: centreBulle, radius: trou));
      canvas.drawPath(chemin, Paint()..color = fond);
      if (e.voile > 0) {
        canvas.drawCircle(centreBulle, trou, Paint()..color = fond.withValues(alpha: fond.a * e.voile));
      }
    }

    // L'onde, à l'intérieur de la bulle.
    if (e.onde.opacite > 0) {
      canvas.drawCircle(
        centreBulle,
        e.onde.rayon * h,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = e.onde.epaisseur * h
          ..color = e.couleur.withValues(alpha: e.onde.opacite * o),
      );
    }

    // La marque.
    final pose = PoseMarque(
      ecrasement: e.pose.ecrasement,
      gonflement: e.pose.gonflement,
      echelle: e.pose.echelle,
      opacite: e.pose.opacite * o,
      opaciteGoutte: e.pose.opaciteGoutte,
      decalageGoutte: e.pose.decalageGoutte,
    );
    PeintreMarque.peindre(canvas, e.centre, h, e.couleur, pose);

    // L'éclaboussure : trois gouttelettes chassées par l'impact, qui
    // montent, retombent sous leur poids et s'évaporent.
    if (e.eclaboussure >= 0 && e.eclaboussure < _vieGouttelette) {
      final s = e.eclaboussure / 1000;
      for (final g in _gouttelettes) {
        final x = g.x + g.vx * s;
        final y = g.y + g.vy * s + 0.5 * _gravite * s * s;
        final vie = e.eclaboussure / _vieGouttelette;
        final a = vie < 0.55 ? 1.0 : 1 - (vie - 0.55) / 0.45;
        canvas.drawCircle(
          e.centre + Offset(x, y) * h,
          g.r * h * (1 - 0.35 * vie),
          Paint()..color = e.couleur.withValues(alpha: e.couleur.a * a * o),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PeintreOuverture old) => true;
}

// ── LA PLACE DE LA MARQUE DANS L'ÉCRAN DE BIENVENUE ──────────────────

/// Pose la marque dans l'écran de bienvenue ET déclare sa place à
/// l'ouverture, pour qu'elle y glisse. Tant que l'ouverture est en cours,
/// la marque d'ici reste invisible : c'est celle de l'ouverture qui
/// voyage, et les deux ne doivent jamais se voir en même temps.
class CibleOuverture extends StatefulWidget {
  const CibleOuverture({super.key, required this.hauteur, required this.couleur});

  final double hauteur;
  final Color couleur;

  @override
  State<CibleOuverture> createState() => _CibleOuvertureState();
}

class _CibleOuvertureState extends State<CibleOuverture> {
  @override
  void initState() {
    super.initState();
    OuvertureDroplet.active.addListener(_changement);
  }

  void _changement() {
    if (mounted) setState(() {});
  }

  void _declarer() {
    if (!mounted || !OuvertureDroplet.active.value) return;
    final boite = context.findRenderObject() as RenderBox?;
    if (boite == null || !boite.hasSize) return;
    final rect = boite.localToGlobal(Offset.zero) & boite.size;
    OuvertureDroplet.cible.value = CibleMarque(rect, widget.couleur);
  }

  @override
  void dispose() {
    OuvertureDroplet.active.removeListener(_changement);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = OuvertureDroplet.active.value;
    if (active) WidgetsBinding.instance.addPostFrameCallback((_) => _declarer());
    return Opacity(
      opacity: active ? 0 : 1,
      child: MarqueDroplet(hauteur: widget.hauteur, couleur: widget.couleur),
    );
  }
}

/// Fait entrer [enfant] une fois l'ouverture finie (immédiatement s'il
/// n'y en a pas). Le contenu est mis en page dès le début — invisible —
/// pour que la place de la marque soit déjà la bonne pendant qu'elle
/// voyage.
class ApresOuverture extends StatelessWidget {
  const ApresOuverture({super.key, required this.builder});

  /// Construit le contenu ; il est RECONSTRUIT (remonté) à la fin de
  /// l'ouverture, ce qui rejoue ses animations d'entrée à ce moment-là.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OuvertureDroplet.active,
      builder: (context, active, _) => active
          ? Opacity(opacity: 0, child: KeyedSubtree(key: const ValueKey('attente'), child: builder(context)))
          : KeyedSubtree(key: const ValueKey('entree'), child: builder(context)),
    );
  }
}

/// Pour les tests : rejouer l'ouverture.
@visibleForTesting
void reinitialiserOuverture() {
  OuvertureDroplet._jouee = false;
  OuvertureDroplet.aRejointLAccueil = false;
  OuvertureDroplet.cible.value = null;
  OuvertureDroplet.active.value = false;
  OuvertureDroplet._retenues.value = 0;
}
