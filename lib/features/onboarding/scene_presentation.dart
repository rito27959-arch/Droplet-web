// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA SCÈNE DES RÉCITS — un seul dessin, qui se transforme SOUS LE DOIGT.
//
// Les grandes présentations (l'intro de Telegram, celles d'Apple) ne
// montrent pas quatre images côte à côte : elles montrent UN objet qui
// change de forme quand on glisse, à la vitesse du doigt, et qu'on peut
// arrêter à mi-chemin. C'est ce qui donne l'impression d'un produit
// travaillé : rien ne « saute », tout se déduit de ce qu'on vient de voir.
//
// Ici, l'objet est la marque elle-même — la bulle et la goutte :
//
//   0  LA MARQUE        posée par l'ouverture, des ronds dans l'eau.
//   1  LE RELAIS        la bulle s'ouvre en un cercle pointillé ; cinq
//                       téléphones en sortent ; la goutte (votre message)
//                       saute de l'un à l'autre jusqu'au destinataire.
//   2  LE CADENAS       les téléphones rentrent ; la bulle s'épaissit et
//                       devient le corps d'un cadenas, la goutte sa
//                       serrure. L'anse se FERME à l'instant où la page
//                       s'arrête — avec un petit choc dans la main.
//   3  LA CARTE         le cadenas s'ouvre en carte hors ligne : vous au
//                       centre, vos proches autour, l'un d'eux dit « je
//                       vais bien ».
//
// ── Comment c'est fait — avec Flame ──────────────────────────────────
//
// La scène est un jeu Flame (`JeuPresentation`) : chaque couche est un
// composant à part (la lueur et la carte, les mouvements de fond, les
// téléphones, les proches, la marque, le relais, les particules), dans
// son ordre d'affichage. Les ÉVÉNEMENTS de la scène lâchent de vraies
// particules : des éclaboussures quand la goutte arrive sur un téléphone,
// une gerbe d'étincelles quand le cadenas se ferme, des confettis verts
// quand un proche dit « je vais bien ». Sur la première page, la goutte
// TOURNE sur elle-même, comme à la fin de l'ouverture au feutre.
//
// • Chaque page est une POSE (`_Pose`) : rayon de la bulle, épaisseur,
//   pointillés, taille et place de la goutte, anse, téléphones, proches…
//   Entre deux pages, chaque valeur est interpolée selon la position
//   EXACTE du `PageController` — pas une animation lancée au changement
//   de page : le doigt pilote.
// • Les téléphones et les proches arrivent EN CASCADE (un léger décalage
//   par objet), comme les icônes d'iOS qui se rangent.
// • Par-dessus, chaque page a son MOUVEMENT DE REPOS (les ronds, le saut
//   de la goutte, les données chiffrées qui tournent, le radar), pondéré
//   par la proximité de la page : il s'efface pendant le glissement et
//   reprend à l'arrivée.
// • « Réduire les animations » : les mouvements de repos s'arrêtent sur
//   leur image la plus parlante ; le glissement reste, puisque c'est le
//   doigt qui le fait.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_colors.dart';
import '../../shared/widgets/marque_droplet.dart';
import 'ouverture_droplet.dart';

/// Le rapport entre le côté de la scène et le rayon de la bulle au repos.
const double _kRayonSurCote = 0.17;

/// Le rayon moyen de l'anneau de la marque, en hauteurs de marque.
const double _kRayonMarque = (GeometrieMarque.rayonInterieurBulle + GeometrieMarque.rayonExterieurBulle) / 2;

/// La scène des quatre récits.
class ScenePresentation extends StatefulWidget {
  const ScenePresentation({
    super.key,
    this.controleur,
    this.pageInitiale = 0,
    this.pageFixe,
    this.tempsFixe,
  });

  /// Le contrôleur des pages : la scène suit sa position au pixel près.
  final PageController? controleur;
  final int pageInitiale;

  /// Pour les tests de rendu : une position de page imposée (0 → 3).
  @visibleForTesting
  final double? pageFixe;

  /// Pour les tests de rendu : un instant imposé des mouvements de repos.
  @visibleForTesting
  final Duration? tempsFixe;

  /// La hauteur de la marque dans une scène de [cote] points — pour que
  /// l'ouverture vienne s'y poser exactement.
  static double hauteurMarque(double cote) => cote * _kRayonSurCote / _kRayonMarque;

  @override
  State<ScenePresentation> createState() => _ScenePresentationState();
}

class _ScenePresentationState extends State<ScenePresentation> {
  late final JeuPresentation _jeu = JeuPresentation(page: () => _page);
  bool _reduit = false;

  /// Vrai quand l'anse du cadenas s'est fermée — pour ne donner le petit
  /// choc (et la gerbe d'étincelles) qu'une fois par arrivée sur la page.
  bool _cadenasFerme = false;

  @override
  void initState() {
    super.initState();
    widget.controleur?.addListener(_suivreCadenas);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(covariant ScenePresentation old) {
    super.didUpdateWidget(old);
    if (old.controleur != widget.controleur) {
      old.controleur?.removeListener(_suivreCadenas);
      widget.controleur?.addListener(_suivreCadenas);
    }
  }

  double get _page {
    if (widget.pageFixe != null) return widget.pageFixe!;
    final c = widget.controleur;
    if (c != null && c.hasClients && c.position.haveDimensions) return c.page ?? widget.pageInitiale.toDouble();
    return widget.pageInitiale.toDouble();
  }

  void _suivreCadenas() {
    final ecart = (_page - 2).abs();
    if (!_cadenasFerme && ecart < 0.015) {
      _cadenasFerme = true;
      HapticFeedback.mediumImpact();
      _jeu.cadenasFerme();
    } else if (_cadenasFerme && ecart > 0.3) {
      _cadenasFerme = false;
    }
  }

  @override
  void dispose() {
    widget.controleur?.removeListener(_suivreCadenas);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    // Les réglages du jeu suivent le thème et les tests à chaque
    // reconstruction ; le jeu lui-même n'est jamais recréé.
    _jeu
      ..sombre = sombre
      ..tempsFixe = widget.tempsFixe == null ? null : widget.tempsFixe!.inMicroseconds / 1e6
      ..reduit = _reduit
      ..couleurs = _Couleurs(
        accent: OuroColors.accent,
        neutre: OuroColors.tertiaryLabel,
        coque: OuroColors.secondaryLabel,
        ecran: OuroColors.secondarySystemBackground,
        fond: OuroColors.systemBackground,
        trait: OuroColors.label,
        succes: OuroColors.systemGreen,
        lueurs: [OuroColors.accent, OuroColors.systemTeal, OuroColors.systemIndigo, OuroColors.systemGreen],
        proches: [
          OuroColors.systemIndigo,
          OuroColors.systemGreen,
          OuroColors.systemOrange,
          OuroColors.systemPink,
          OuroColors.systemTeal,
        ],
      );
    return LayoutBuilder(builder: (context, contraintes) {
      final taille = contraintes.biggest;
      final cote = math.min(taille.width, taille.height);
      final hMarque = ScenePresentation.hauteurMarque(cote);
      final centre = Offset(taille.width / 2, taille.height / 2);
      // Le centre de la BOÎTE de la marque, légèrement sous celui de la
      // bulle (la queue dépasse en bas).
      final centreBoite = centre - GeometrieMarque.centreBulle * hMarque;
      return Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: ValueListenableBuilder<bool>(
                valueListenable: OuvertureDroplet.active,
                builder: (context, ouverture, _) {
                  _jeu.masquerMarque = ouverture;
                  return GameWidget<JeuPresentation>(game: _jeu);
                },
              ),
            ),
          ),
          // La cible de l'ouverture : invisible, elle ne sert qu'à dire à
          // l'ouverture où poser la marque — c'est la scène qui la dessine
          // ensuite, au même pixel.
          Positioned(
            left: centreBoite.dx - hMarque * GeometrieMarque.rapport / 2,
            top: centreBoite.dy - hMarque / 2,
            child: IgnorePointer(
              child: CibleOuverture(hauteur: hMarque, couleur: OuroColors.accent, dessiner: false),
            ),
          ),
        ],
      );
    });
  }
}

class _Couleurs {
  const _Couleurs({
    required this.accent,
    required this.neutre,
    required this.coque,
    required this.ecran,
    required this.fond,
    required this.trait,
    required this.succes,
    required this.lueurs,
    required this.proches,
  });
  final Color accent, neutre, coque, ecran, fond, trait, succes;
  final List<Color> lueurs;
  final List<Color> proches;
}

// ─────────────────────────────────────────────────────────────
//  LES POSES
// ─────────────────────────────────────────────────────────────

/// L'état de la scène sur une page, en rayons de marque (`R`).
class _Pose {
  const _Pose({
    required this.rayon,
    required this.epaisseur,
    this.pointilles = 0,
    this.opaciteAnneau = 1,
    this.neutre = 0,
    this.remplissage = 0,
    this.queue = 0,
    this.goutteY = 0,
    required this.goutteH,
    this.anse = 0,
    this.telephones = 0,
    this.proches = 0,
    this.carte = 0,
  });

  final double rayon, epaisseur, pointilles, opaciteAnneau, neutre, remplissage, queue;
  final double goutteY, goutteH, anse, telephones, proches, carte;
}

/// La goutte de la marque, haute de 0,565 marque — soit 1,263 R.
const double _kGoutteMarque = 0.565 / _kRayonMarque;

final List<_Pose> _poses = [
  // 0 — la marque, exactement.
  _Pose(
    rayon: 1,
    epaisseur: (GeometrieMarque.rayonExterieurBulle - GeometrieMarque.rayonInterieurBulle) / _kRayonMarque,
    queue: 1,
    // Le centre de la goutte est 0,026 marque sous celui de la bulle.
    goutteY: (0.0095 - GeometrieMarque.centreBulle.dy) / _kRayonMarque,
    goutteH: _kGoutteMarque,
  ),
  // 1 — le relais.
  _Pose(rayon: 2.25, epaisseur: 0.032, pointilles: 0.6, opaciteAnneau: 0.6, neutre: 1, goutteH: 0.62, telephones: 1),
  // 2 — le cadenas.
  _Pose(rayon: 0.95, epaisseur: 0.27, remplissage: 0.12, goutteY: 0.1, goutteH: 0.7, anse: 1),
  // 3 — la carte.
  _Pose(rayon: 0.8, epaisseur: 0.035, opaciteAnneau: 0.7, remplissage: 0.12, goutteH: 0.56, proches: 1, carte: 1),
];

double _lerp(double a, double b, double t) => a + (b - a) * t;
double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Le décalage d'une cascade : l'objet [k] sur [n] commence un peu après
/// le précédent, et tous finissent ensemble.
double _cascade(double f, int k, int n, {double pas = 0.07}) {
  final total = pas * (n - 1);
  return Curves.easeInOutCubic.transform(((f - k * pas) / (1 - total)).clamp(0.0, 1.0));
}

// ─────────────────────────────────────────────────────────────
//  LE JEU
// ─────────────────────────────────────────────────────────────

/// Ce que toutes les couches lisent, recalculé une fois par image.
class _Instant {
  _Instant(this.p, this.t, Vector2 taille)
      : cote = math.min(taille.x, taille.y),
        c = Offset(taille.x / 2, taille.y / 2),
        i = p.floor().clamp(0, 2) {
    R = cote * _kRayonSurCote;
    f = p - i;
    e = Curves.easeInOutCubic.transform(f);
  }

  final double p, t, cote;
  final Offset c;
  final int i;
  late final double R, f, e;

  _Pose get a => _poses[i];
  _Pose get b => _poses[i + 1];
  double v(double Function(_Pose) champ) => _lerp(champ(a), champ(b), e);

  /// Le poids de chaque page : 1 posée dessus, 0 à une page de distance.
  double poids(int k) => (1 - (p - k).abs()).clamp(0.0, 1.0);
}

class JeuPresentation extends FlameGame {
  JeuPresentation({required this.page});

  final double Function() page;
  _Couleurs couleurs = const _Couleurs(
    accent: Color(0xFF0A84FF),
    neutre: Color(0xFF8E8E93),
    coque: Color(0xFF8E8E93),
    ecran: Color(0xFFF2F2F7),
    fond: Color(0xFFFFFFFF),
    trait: Color(0xFF000000),
    succes: Color(0xFF34C759),
    lueurs: [Color(0xFF0A84FF), Color(0xFF30B0C7), Color(0xFF5856D6), Color(0xFF34C759)],
    proches: [Color(0xFF5856D6), Color(0xFF34C759), Color(0xFFFF9500), Color(0xFFFF2D55), Color(0xFF30B0C7)],
  );
  bool sombre = false;
  bool masquerMarque = false;
  bool reduit = false;

  /// Pour les tests : l'instant des mouvements de repos, en secondes.
  double? tempsFixe;

  double _temps = 0;

  /// Le tour de la goutte de la page 0 (radians).
  double tourGoutte = 0;

  late _Instant instant;
  final _Dessin dessin = _Dessin();

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    instant = _Instant(0, 0, size);
    addAll([
      _Fond(priority: 0),
      _Telephones(priority: 1),
      _Proches(priority: 2),
      _Marque(priority: 3),
      _Relais(priority: 4),
    ]);
  }

  double get t => tempsFixe ?? (reduit ? 0 : _temps);

  @override
  void update(double dt) {
    if (!reduit && tempsFixe == null) _temps += dt;
    // La goutte de la page 0 tourne doucement, un demi-tour par seconde,
    // comme à la fin de l'ouverture — sauf « Réduire les animations ».
    // Cachée pendant l'ouverture, elle attend de face : elle repart de là
    // où l'ouverture l'a posée, sans saut.
    if (masquerMarque) {
      tourGoutte = 0;
    } else if (!reduit && tempsFixe == null) {
      tourGoutte += dt * math.pi * 0.9;
    }
    if (tempsFixe != null) tourGoutte = tempsFixe! * math.pi * 0.9;
    dessin
      ..couleurs = couleurs
      ..sombre = sombre;
    instant = _Instant(page().clamp(0.0, 3.0), t, size);
    _evenementsRelais();
    _evenementsProches();
    super.update(dt);
  }

  // ── Les événements qui lâchent des particules ─────────────────────

  final math.Random _hasard = math.Random(3);
  int _dernierRelais = -1;
  bool _dernierCoche = false;

  void _evenementsRelais() {
    final n = instant;
    final w1 = n.poids(1);
    if (w1 < 0.6 || reduit || tempsFixe != null) return;
    final cycle = (n.t / 3.8) % 1.0;
    for (final MapEntry(key: k, value: arrivee) in _Dessin.arriveeRelais.entries) {
      if (cycle >= arrivee && cycle < arrivee + 0.05 && _dernierRelais != k) {
        _dernierRelais = k;
        eclabousser(dessin.placeTel(n.c, n.R, k, 1), couleurs.accent, nombre: 10);
      }
    }
    if (cycle < 0.05) _dernierRelais = -1;
  }

  void _evenementsProches() {
    final n = instant;
    final w3 = n.poids(3);
    if (w3 < 0.6 || reduit || tempsFixe != null) return;
    final cycle = (n.t / 4.0) % 1.0;
    final coche = cycle >= 0.24 && cycle < 0.3;
    if (coche && !_dernierCoche) {
      final (ang, dist) = _Dessin.placesProches[1];
      final pos = n.c + Offset(math.cos(ang), math.sin(ang)) * n.R * dist;
      confettis(pos, couleurs.succes);
    }
    _dernierCoche = coche;
  }

  /// Le cadenas vient de se fermer : une gerbe d'étincelles autour de lui.
  void cadenasFerme() {
    if (reduit || !isLoaded) return;
    final n = instant;
    add(ParticleSystemComponent(
      priority: 6,
      position: Vector2(n.c.dx, n.c.dy),
      particle: Particle.generate(
        count: 22,
        lifespan: 0.8,
        generator: (i) {
          final a = i / 22 * 2 * math.pi;
          final v = 120 + _hasard.nextDouble() * 90;
          return AcceleratedParticle(
            position: Vector2(math.cos(a), math.sin(a)) * (n.R * 1.1),
            speed: Vector2(math.cos(a), math.sin(a)) * v,
            acceleration: Vector2(math.cos(a), math.sin(a)) * -160,
            child: _Etincelle(couleur: couleurs.accent),
          );
        },
      ),
    ));
  }

  void eclabousser(Offset ou, Color couleur, {int nombre = 8}) {
    add(ParticleSystemComponent(
      priority: 6,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: nombre,
        lifespan: 0.6,
        generator: (i) {
          final a = -math.pi * (0.1 + 0.8 * _hasard.nextDouble());
          final v = 60 + _hasard.nextDouble() * 110;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v),
            acceleration: Vector2(0, 420),
            child: _Gouttelette(couleur: couleur, rayon: 1.4 + _hasard.nextDouble() * 2),
          );
        },
      ),
    ));
  }

  void confettis(Offset ou, Color couleur) {
    add(ParticleSystemComponent(
      priority: 6,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: 14,
        lifespan: 0.9,
        generator: (i) {
          final a = -math.pi / 2 + (_hasard.nextDouble() - 0.5) * 1.6;
          final v = 90 + _hasard.nextDouble() * 120;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v),
            acceleration: Vector2(0, 300),
            child: _Confetti(couleur: i.isEven ? couleur : couleurs.accent, angle0: _hasard.nextDouble() * 3),
          );
        },
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────
//  LES COUCHES
// ─────────────────────────────────────────────────────────────

/// La lueur, la carte, et les mouvements de repos qui passent DERRIÈRE.
class _Fond extends Component with HasGameReference<JeuPresentation> {
  _Fond({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final n = j.instant;
    final d = j.dessin;
    final k0 = n.p.floor().clamp(0, 3), k1 = n.p.ceil().clamp(0, 3);
    final lueur = Color.lerp(j.couleurs.lueurs[k0], j.couleurs.lueurs[k1], n.e)!;
    canvas.drawCircle(
      n.c,
      n.cote * 0.62,
      Paint()
        ..shader = ui.Gradient.radial(n.c, n.cote * 0.62, [
          lueur.withValues(alpha: j.sombre ? 0.22 : 0.12),
          lueur.withValues(alpha: 0),
        ]),
    );
    final carte = n.v((q) => q.carte);
    if (carte > 0.01) d._carte(canvas, n.c, n.R, carte);
    final w0 = n.poids(0), w2 = n.poids(2), w3 = n.poids(3);
    if (!j.masquerMarque && w0 > 0) d._ronds(canvas, n.c, n.R, n.t, w0);
    if (w2 > 0) d._donneesChiffrees(canvas, n.c, n.R, n.t, w2);
    if (w3 > 0) d._radar(canvas, n.c, n.R, n.t, w3);
  }
}

/// Les téléphones (page 1), en cascade.
class _Telephones extends Component with HasGameReference<JeuPresentation> {
  _Telephones({super.priority});

  @override
  void render(Canvas canvas) {
    final n = game.instant;
    final ftel = n.i == 0 ? n.f : (n.i == 1 ? 1 - n.f : 0.0);
    if (ftel > 0) game.dessin._telephones(canvas, n.c, n.R, n.t, ftel, n.poids(1));
  }
}

/// Les proches (page 3), en cascade.
class _Proches extends Component with HasGameReference<JeuPresentation> {
  _Proches({super.priority});

  @override
  void render(Canvas canvas) {
    final n = game.instant;
    final fpro = n.i == 2 ? n.f : 0.0;
    if (fpro > 0) game.dessin._proches(canvas, n.c, n.R, n.t, fpro, n.poids(3));
  }
}

/// L'anneau (bulle, cercle pointillé, corps du cadenas), l'anse, la goutte.
class _Marque extends Component with HasGameReference<JeuPresentation> {
  _Marque({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    if (j.masquerMarque) return;
    final n = j.instant;
    final d = j.dessin;
    final c = n.c, R = n.R;
    final rayon = n.v((q) => q.rayon) * R;
    final epaisseur = math.max(1.2, n.v((q) => q.epaisseur) * R);
    final couleurAnneau = Color.lerp(j.couleurs.accent, j.couleurs.neutre, n.v((q) => q.neutre))!;
    final opaciteAnneau = n.v((q) => q.opaciteAnneau);
    final remplissage = n.v((q) => q.remplissage);
    if (remplissage > 0.001) {
      canvas.drawCircle(c, rayon, Paint()..color = j.couleurs.accent.withValues(alpha: remplissage));
    }
    final anse = n.v((q) => q.anse);
    if (anse > 0.01) {
      final fermeture = Curves.easeOutBack.transform(_seg(n.poids(2), 0.78, 1.0));
      d._anse(canvas, c, rayon, epaisseur, R, anse, fermeture);
    }
    final h = R / _kRayonMarque;
    if (n.p < 0.002) {
      // Posée sur la marque : LA marque, au tracé près — celle que
      // l'ouverture vient de déposer.
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(h);
      canvas.translate(-GeometrieMarque.centreBulle.dx, -GeometrieMarque.centreBulle.dy);
      canvas.drawPath(GeometrieMarque.bulle, Paint()..color = j.couleurs.accent);
      canvas.restore();
    } else {
      d._anneau(canvas, c, rayon, epaisseur, n.v((q) => q.pointilles), couleurAnneau.withValues(alpha: couleurAnneau.a * opaciteAnneau));
      final queue = n.i == 0 ? 1 - Curves.easeOut.transform(_seg(n.f, 0, 0.3)) : 0.0;
      if (queue > 0.01) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(h);
        canvas.translate(-GeometrieMarque.centreBulle.dx, -GeometrieMarque.centreBulle.dy);
        canvas.drawPath(_Dessin.queue, Paint()..color = j.couleurs.accent.withValues(alpha: queue));
        canvas.restore();
      }
    }
    final hg = n.v((q) => q.goutteH) * R;
    final centreGoutte = c + Offset(0, n.v((q) => q.goutteY) * R);
    final souffle = 1 + 0.035 * n.poids(3) * math.sin(n.t * 2.2);
    // Sur la page 0, la goutte tourne ; elle revient de face à mesure qu'on
    // glisse vers la page suivante.
    final w0 = n.poids(0);
    final tour = w0 <= 0 ? 0.0 : math.acos((1 - w0 + w0 * math.cos(j.tourGoutte)).clamp(-1.0, 1.0)) * (math.sin(j.tourGoutte) >= 0 ? 1 : -1);
    d._goutte(canvas, centreGoutte, hg * souffle, j.couleurs.accent, tour: tour);
  }
}

/// Le relais : la goutte qui saute de téléphone en téléphone (DEVANT).
class _Relais extends Component with HasGameReference<JeuPresentation> {
  _Relais({super.priority});

  @override
  void render(Canvas canvas) {
    final n = game.instant;
    final w1 = n.poids(1);
    if (w1 > 0) game.dessin._relais(canvas, n.c, n.R, n.t, w1);
  }
}

// ─────────────────────────────────────────────────────────────
//  LES BRIQUES DU DESSIN
// ─────────────────────────────────────────────────────────────

class _Dessin {
  late _Couleurs couleurs;
  bool sombre = false;

  static Path? _queueUnite;

  /// La queue de la bulle seule : la bulle de la marque moins son anneau.
  static Path get queue => _queueUnite ??= Path.combine(
        PathOperation.difference,
        GeometrieMarque.bulle,
        Path()..addOval(Rect.fromCircle(center: GeometrieMarque.centreBulle, radius: GeometrieMarque.rayonExterieurBulle + 0.002)),
      );

  // Les cinq téléphones, en pentagone ; les cinq proches, éparpillés.
  static final List<double> _anglesTel = [for (var k = 0; k < 5; k++) -math.pi / 2 + k * 2 * math.pi / 5];
  static const List<(double, double)> placesProches = [
    (-2.45, 1.95), // angle (radians), distance (R)
    (-0.62, 2.15),
    (0.42, 1.55),
    (2.25, 2.2),
    (1.45, 2.45),
  ];
  static const List<(double, double)> _placesProches = placesProches;

  Offset placeTel(Offset c, double R, int k, double sortie) => _placeTel(c, R, k, sortie);

  // ── Les briques ────────────────────────────────────────────────

  void _anneau(Canvas canvas, Offset c, double r, double ep, double pointilles, Color couleur) {
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ep
      ..strokeCap = pointilles > 0.05 ? StrokeCap.round : StrokeCap.butt
      ..color = couleur;
    if (pointilles < 0.02) {
      canvas.drawCircle(c, r, pinceau);
      return;
    }
    // Des tirets qui se resserrent en trait plein : 56 arcs dont le vide
    // grandit avec [pointilles].
    const n = 56;
    final pas = 2 * math.pi / n;
    final rect = Rect.fromCircle(center: c, radius: r);
    for (var k = 0; k < n; k++) {
      canvas.drawArc(rect, k * pas, pas * (1 - pointilles), false, pinceau);
    }
  }

  void _goutte(Canvas canvas, Offset centre, double h, Color couleur, {double alpha = 1, double etirement = 0, double angle = 0, double tour = 0}) {
    if (h <= 0 || alpha <= 0) return;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    if (angle != 0) canvas.rotate(angle);
    // [tour] : la goutte tourne sur son axe vertical (la même que celle de
    // l'ouverture au feutre). Sa largeur suit le cosinus ; la lumière passe
    // d'un bord à l'autre.
    final face = math.cos(tour);
    final largeur = tour == 0 ? 1.0 : math.max(0.08, face.abs());
    canvas.scale(h / 0.565 * (1 - etirement * 0.4) * largeur, h / 0.565 * (1 + etirement));
    canvas.translate(0, -0.0095);
    final a = couleur.a * alpha;
    final cote = math.sin(tour);
    canvas.drawPath(
      GeometrieMarque.goutte,
      Paint()
        ..isAntiAlias = true
        ..shader = tour == 0
            ? ui.Gradient.linear(
                const Offset(-0.12, -0.2),
                const Offset(0.16, 0.29),
                [couleur.withValues(alpha: a), couleur.withValues(alpha: a * 0.84)],
              )
            : ui.Gradient.linear(
                Offset(cote >= 0 ? -0.2 : 0.2, 0),
                Offset(cote >= 0 ? 0.2 : -0.2, 0),
                [
                  Color.lerp(couleur, Colors.white, 0.22 * cote.abs())!.withValues(alpha: a),
                  Color.lerp(couleur, Colors.black, 0.18 * cote.abs())!.withValues(alpha: a),
                ],
              ),
    );
    canvas.restore();
  }

  /// Un rond dans l'eau.
  void _rond(Canvas canvas, Offset c, double r0, double r1, double p, Color couleur, {double ep = 1.6, double alpha = 0.45}) {
    if (p <= 0 || p >= 1 || alpha <= 0) return;
    final r = r0 + (r1 - r0) * Curves.easeOutCubic.transform(p);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ep * (1 - 0.5 * p)
        ..color = couleur.withValues(alpha: couleur.a * alpha * math.pow(1 - p, 1.4).toDouble()),
    );
  }

  // Page 0 — deux ronds lents autour de la marque.
  void _ronds(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.4) % 1.0;
    final r0 = R * (GeometrieMarque.rayonExterieurBulle / _kRayonMarque) + 4;
    _rond(canvas, c, r0, R * 2.7, _seg(cycle, 0.0, 0.66), couleurs.accent, alpha: 0.42 * w);
    _rond(canvas, c, r0, R * 2.7, _seg(cycle, 0.3, 0.96), couleurs.accent, alpha: 0.30 * w);
  }

  Offset _placeTel(Offset c, double R, int k, double sortie) {
    final d = _lerp(R * 0.9, R * 2.25, sortie);
    return c + Offset(math.cos(_anglesTel[k]), math.sin(_anglesTel[k])) * d;
  }

  // Page 1 — cinq téléphones sortis de la bulle.
  void _telephones(Canvas canvas, Offset c, double R, double t, double f, double w1) {
    final cycle = (t / 3.8) % 1.0;
    for (var k = 0; k < 5; k++) {
      final s = _cascade(f, k, 5);
      if (s <= 0) continue;
      final pos = _placeTel(c, R, k, Curves.easeOutBack.transform(s).clamp(0.0, 1.15));
      final larg = R * 0.42 * s, haut = R * 0.7 * s;
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: larg, height: haut), Radius.circular(R * 0.11 * s));
      // Le téléphone qui reçoit la goutte s'éclaire un instant.
      final arrivee = _arriveeRelais[k];
      final eclat = arrivee == null ? 0.0 : w1 * (_seg(cycle, arrivee, arrivee + 0.04) * (1 - _seg(cycle, arrivee + 0.1, arrivee + 0.3)));
      canvas.drawRRect(r, Paint()..color = Color.lerp(couleurs.ecran, couleurs.accent.withValues(alpha: 0.28), eclat)!.withValues(alpha: s));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = couleurs.coque.withValues(alpha: couleurs.coque.a * 0.5 * s),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos - Offset(0, haut * 0.37), width: larg * 0.3, height: 2.6 * s), const Radius.circular(2)),
        Paint()..color = couleurs.coque.withValues(alpha: couleurs.coque.a * 0.45 * s),
      );
      if (arrivee != null) _rond(canvas, pos, R * 0.3, R * 0.85, w1 * _seg(cycle, arrivee, arrivee + 0.3), couleurs.accent, alpha: 0.55 * w1);
    }
    // Le destinataire coche : le message est arrivé.
    final coche = w1 * Curves.easeOutBack.transform(_seg(cycle, 0.8, 0.88)) * (1 - _seg(cycle, 0.96, 1.0));
    if (coche > 0.01) _coche(canvas, _placeTel(c, R, 2, 1) + Offset(0, R * 0.04), R * 0.17 * coche, couleurs.succes);
  }

  // Le trajet de la goutte : du centre au téléphone 0, puis 1, puis 2.
  static const Map<int, double> arriveeRelais = {0: 0.22, 1: 0.48, 2: 0.74};
  static const Map<int, double> _arriveeRelais = arriveeRelais;

  void _relais(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.8) % 1.0;
    Offset? ou;
    var etirement = 0.0, alpha = 1.0, angle = 0.0;
    Offset arc(Offset a, Offset b, double q, double bombe) {
      final m = (a + b) / 2;
      final n = (m - c);
      final dir = n.distance == 0 ? Offset.zero : n / n.distance;
      final ctrl = m + dir * bombe;
      final u = 1 - q;
      return a * (u * u) + ctrl * (2 * u * q) + b * (q * q);
    }

    final t0 = _placeTel(c, R, 0, 1), t1 = _placeTel(c, R, 1, 1), t2 = _placeTel(c, R, 2, 1);
    if (cycle < 0.06) {
      return;
    } else if (cycle < 0.22) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.06, 0.22));
      ou = Offset.lerp(c, t0, q);
      etirement = 0.2 * math.sin(math.pi * q);
      alpha = _seg(cycle, 0.06, 0.1);
    } else if (cycle < 0.26) {
      ou = t0;
    } else if (cycle < 0.48) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.26, 0.48));
      ou = arc(t0, t1, q, R * 0.55);
      etirement = 0.2 * math.sin(math.pi * q);
      angle = 0.5 * math.sin(math.pi * q);
    } else if (cycle < 0.52) {
      ou = t1;
    } else if (cycle < 0.74) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.52, 0.74));
      ou = arc(t1, t2, q, R * 0.55);
      etirement = 0.2 * math.sin(math.pi * q);
      angle = 0.5 * math.sin(math.pi * q);
    } else if (cycle < 0.8) {
      ou = t2;
      alpha = 1 - _seg(cycle, 0.74, 0.8);
    }
    if (ou != null) {
      _goutte(canvas, ou, R * 0.36, couleurs.accent, alpha: alpha * w, etirement: etirement, angle: angle);
    }
  }

  // Page 2 — l'anse du cadenas.
  void _anse(Canvas canvas, Offset c, double r, double ep, double R, double apparition, double fermeture) {
    final x = r * 0.56;
    final haut = c.dy - r - R * 0.78;
    final leve = R * 0.34 * (1 - fermeture) * apparition + R * 0.5 * (1 - apparition);
    final rayonArc = x;
    final chemin = Path()
      ..moveTo(c.dx - x, c.dy - r * 0.5 - leve)
      ..lineTo(c.dx - x, haut + rayonArc - leve)
      ..arcToPoint(Offset(c.dx + x, haut + rayonArc - leve), radius: Radius.circular(rayonArc))
      ..lineTo(c.dx + x, c.dy - r * 0.5 - leve);
    canvas.save();
    // L'anse disparaît DANS l'anneau : on ne la dessine qu'à l'extérieur.
    canvas.clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & const Size(1e5, 1e5)),
      Path()..addOval(Rect.fromCircle(center: c, radius: r + ep / 2 - 0.5)),
    ));
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ep * 0.82
        ..strokeCap = StrokeCap.round
        ..color = couleurs.accent.withValues(alpha: apparition),
    );
    canvas.restore();
  }

  // Page 2 — les données chiffrées : trois arcs de points qui tournent
  // lentement autour du cadenas.
  void _donneesChiffrees(Canvas canvas, Offset c, double R, double t, double w) {
    final rayon = R * 1.85;
    final pinceau = Paint()..color = couleurs.accent.withValues(alpha: 0.4 * w);
    for (var groupe = 0; groupe < 3; groupe++) {
      final base = t * 0.32 + groupe * 2 * math.pi / 3;
      for (var k = 0; k < 7; k++) {
        final ang = base + k * 0.11;
        final taille = 2.2 * w * (k == 3 ? 1.25 : 1);
        canvas.drawCircle(c + Offset(math.cos(ang), math.sin(ang)) * rayon, taille, pinceau);
      }
    }
    // Un deuxième cercle, plus lent, à contresens.
    final p2 = Paint()..color = couleurs.accent.withValues(alpha: 0.22 * w);
    for (var groupe = 0; groupe < 4; groupe++) {
      final base = -t * 0.18 + groupe * math.pi / 2;
      for (var k = 0; k < 5; k++) {
        final ang = base + k * 0.09;
        canvas.drawCircle(c + Offset(math.cos(ang), math.sin(ang)) * R * 2.45, 1.8 * w, p2);
      }
    }
  }

  // Page 3 — les rues de la carte, effacées vers les bords.
  void _carte(Canvas canvas, Offset c, double R, double a) {
    final rayon = R * 2.85;
    final zone = Rect.fromCircle(center: c, radius: rayon);
    canvas.saveLayer(zone, Paint());
    final rue = Paint()
      ..color = couleurs.trait.withValues(alpha: (sombre ? 0.07 : 0.045) * a)
      ..strokeWidth = R * 0.16
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.32);
    for (final y in [-1.6, 0.9, 2.3]) {
      canvas.drawLine(Offset(-rayon, y * R), Offset(rayon, y * R + R * 0.25), rue);
    }
    rue.strokeWidth = R * 0.1;
    for (final x in [-1.8, 0.55, 2.0]) {
      canvas.drawLine(Offset(x * R, -rayon), Offset(x * R + R * 0.35, rayon), rue);
    }
    // Un parc.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(R * 0.9, R * 0.15, R * 0.85, R * 0.75), Radius.circular(R * 0.16)),
      Paint()..color = couleurs.succes.withValues(alpha: (sombre ? 0.13 : 0.1) * a),
    );
    canvas.restore();
    // Le fondu vers les bords.
    canvas.drawRect(
      zone,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.radial(c, rayon, [Colors.white, Colors.white, Colors.white.withValues(alpha: 0)], [0, 0.55, 1]),
    );
    canvas.restore();
  }

  // Page 3 — le radar : vous émettez, sans antenne.
  void _radar(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.2) % 1.0;
    _rond(canvas, c, R * 0.85, R * 2.8, _seg(cycle, 0, 0.7), couleurs.accent, ep: 1.8, alpha: 0.5 * w);
    _rond(canvas, c, R * 0.85, R * 2.8, _seg(cycle, 0.4, 1.0), couleurs.accent, ep: 1.8, alpha: 0.36 * w);
  }

  // Page 3 — vos proches, sortis de vous en cascade.
  void _proches(Canvas canvas, Offset c, double R, double t, double f, double w3) {
    final cycle = (t / 4.0) % 1.0;
    for (var k = 0; k < _placesProches.length; k++) {
      final s = _cascade(f, k, _placesProches.length, pas: 0.08);
      if (s <= 0) continue;
      final (ang, dist) = _placesProches[k];
      final sortie = Curves.easeOutBack.transform(s).clamp(0.0, 1.12);
      // Une petite dérive : ils sont vivants, pas épinglés.
      final derive = Offset(math.sin(t * 0.7 + k * 1.7), math.cos(t * 0.6 + k)) * R * 0.04 * w3;
      final pos = c + Offset(math.cos(ang), math.sin(ang)) * R * dist * sortie + derive;
      final rayon = R * 0.2 * s;
      canvas.drawCircle(pos, rayon + 3, Paint()..color = couleurs.fond.withValues(alpha: s));
      canvas.drawCircle(pos, rayon, Paint()..color = couleurs.proches[k].withValues(alpha: s));
      // Le proche n°1 dit « je vais bien » : une onde verte, puis une coche.
      if (k == 1) {
        _rond(canvas, pos, rayon, R * 1.1, w3 * _seg(cycle, 0.2, 0.62), couleurs.succes, alpha: 0.6 * w3);
        final coche = w3 * Curves.easeOutBack.transform(_seg(cycle, 0.24, 0.36)) * (1 - Curves.easeIn.transform(_seg(cycle, 0.9, 1.0)));
        if (coche > 0.01) {
          final centre = pos + Offset(rayon * 0.85, -rayon * 1.35);
          canvas.drawCircle(centre, R * 0.17 * coche + 2.5, Paint()..color = couleurs.fond);
          _coche(canvas, centre, R * 0.17 * coche, couleurs.succes);
        }
      }
    }
  }

  void _coche(Canvas canvas, Offset c, double r, Color couleur) {
    canvas.drawCircle(c, r, Paint()..color = couleur);
    final s = r / 11;
    final p = Path()
      ..moveTo(c.dx - 4.6 * s, c.dy + 0.2 * s)
      ..lineTo(c.dx - 1.3 * s, c.dy + 3.5 * s)
      ..lineTo(c.dx + 4.9 * s, c.dy - 3.3 * s);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

}

// ─────────────────────────────────────────────────────────────
//  LES PARTICULES
// ─────────────────────────────────────────────────────────────

class _Gouttelette extends Particle {
  _Gouttelette({required this.couleur, required this.rayon}) : super(lifespan: 0.6);
  final Color couleur;
  final double rayon;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, rayon * (1 - 0.4 * progress), Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress)));
  }
}

class _Confetti extends Particle {
  _Confetti({required this.couleur, required this.angle0}) : super(lifespan: 0.9);
  final Color couleur;
  final double angle0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(angle0 + progress * 8);
    final w = 6 * math.cos(progress * 12).abs() + 1;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: 3.5), Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress)));
    canvas.restore();
  }
}

class _Etincelle extends Particle {
  _Etincelle({required this.couleur}) : super(lifespan: 0.8);
  final Color couleur;

  @override
  void render(Canvas canvas) {
    final r = 3.4 * (1 - progress);
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 1.6)
        ..lineTo(r * 0.35, -r * 0.35)
        ..lineTo(r * 1.6, 0)
        ..lineTo(r * 0.35, r * 0.35)
        ..lineTo(0, r * 1.6)
        ..lineTo(-r * 0.35, r * 0.35)
        ..lineTo(-r * 1.6, 0)
        ..lineTo(-r * 0.35, -r * 0.35)
        ..close(),
      Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress)),
    );
  }
}
