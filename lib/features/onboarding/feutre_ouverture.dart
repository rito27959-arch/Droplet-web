// ============================================================================
// L'OUVERTURE AU FEUTRE — dessinée avec Flame.
// ----------------------------------------------------------------------------
// Un dessinateur qui signe : le feutre entre par le bord de l'écran, se
// chauffe la main en quelques zigzags, trace l'anneau de la bulle d'un seul
// geste, sa queue, puis le contour de la goutte, la colorie à grands
// hachures, lève la main et remonte hors de l'écran. La goutte, elle,
// se met à TOURNER sur elle-même et ne s'arrête plus tant que l'ouverture
// est là.
//
// ── La continuité avec l'écran natif ─────────────────────────────────
//
// La toute première image reste celle du système (la bulle, au même
// pixel). Elle pâlit en une esquisse au crayon (12 %) sur laquelle le
// feutre repasse : on ne voit jamais un écran vide, on voit un dessinateur
// encrer son croquis.
//
// ── Pourquoi Flame ───────────────────────────────────────────────────
//
// Une scène faite de pièces indépendantes (le feutre, l'encre, la goutte,
// les éclaboussures), chacune avec sa propre mise à jour et son propre
// ordre d'affichage, et un vrai système de particules : c'est exactement ce
// que Flame organise. Le temps, lui, vient de l'ouverture (`temps`, en
// millisecondes) : le dessin reste synchrone avec la suite — et image par
// image identique dans les tests de rendu.
//
// ── La fin, au pixel près ────────────────────────────────────────────
//
// Encrée, la marque est redessinée par `PeintreMarque` lui-même : quand
// l'ouverture reprend la main (l'onde qui ouvre l'app, ou le glissement
// vers l'accueil), l'image ne change pas d'un pixel. Avant, [poser]
// ramène la goutte de face, sans à-coup.
// ============================================================================

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/widgets.dart';

import '../../shared/widgets/marque_droplet.dart';

// ── LE RYTHME (millisecondes depuis la première image) ───────────────
const double kFeutreEsquisse = 140; // la bulle native pâlit en croquis
const double _tEntree = 60; // le feutre entre…
const double _tAnneau = 380; // … zigzague jusqu'ici, puis trace l'anneau
const double _tQueue = 860;
const double _tLeve = 1000; // main levée, vers le haut de la goutte
const double _tGoutte = 1080;
const double _tHachures = 1300;
const double _tEncre = 1380; // l'encre devient la marque exacte
const double _tSortie = 1420; // le feutre remonte et sort
const double kFeutreFini = 1700; // plus de feutre à l'écran
const double _tTourne = 1480; // la goutte commence à tourner

/// Les tours de la goutte, par seconde, une fois lancée.
const double _toursParSeconde = 0.55;

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Un morceau du geste : un chemin parcouru entre [t0] et [t1] (ms).
class _Morceau {
  _Morceau(this.chemin, this.t0, this.t1, {this.encre = true, this.largeur = 5, this.fugace = false, this.courbe = Curves.easeInOutSine})
      : metrique = chemin.computeMetrics().first;

  final Path chemin;
  final ui.PathMetric metrique;
  final double t0, t1;

  /// Faux : la main est levée, le feutre se déplace sans écrire.
  final bool encre;
  final double largeur;

  /// Vrai pour les zigzags d'échauffement : leur encre s'évapore.
  final bool fugace;
  final Curve courbe;

  double avance(double t) => courbe.transform(_seg(t, t0, t1));

  Offset point(double t) {
    final p = metrique.getTangentForOffset(metrique.length * avance(t).clamp(0.0, 1.0));
    return p?.position ?? Offset.zero;
  }
}

class JeuFeutreOuverture extends FlameGame {
  JeuFeutreOuverture({
    required this.temps,
    required this.fond,
    required this.couleur,
    required this.sombre,
    this.hauteurMarque = 112,
  });

  /// L'horloge de l'ouverture, en millisecondes.
  final double Function() temps;
  final Color fond;
  final Color couleur;
  final bool sombre;
  final double hauteurMarque;

  double get t => temps();

  Offset get centre => Offset(size.x / 2, size.y / 2);

  /// L'angle de la goutte qui tourne (radians, autour de son axe vertical).
  double angleGoutte = 0;
  double _vitesse = 0;
  double? _cibleAngle;
  double _departPose = 0;
  double _angleDepart = 0;

  /// Vrai une fois la goutte revenue de face après [poser].
  bool get posee => _cibleAngle != null && angleGoutte == _cibleAngle;

  /// Ramène la goutte de face (au tour complet suivant), pour rendre la
  /// main à l'ouverture sans saut.
  void poser() {
    if (_cibleAngle != null) return;
    // Le tour complet suivant : la goutte finit le sien, elle ne repart
    // jamais en arrière.
    const tour = 2 * math.pi;
    _cibleAngle = (angleGoutte / tour).ceil() * tour;
    _departPose = t;
    _angleDepart = angleGoutte;
  }

  List<_Morceau> _geste = const [];

  // ⚠️ TRANSPARENT : le fond est peint par l'encre (premier composant).
  // Un fond de jeu opaque se peint dès la toute première image, AVANT le
  // chargement des composants — l'écran natif était alors remplacé par une
  // image vide, le temps d'une image.
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    add(_Encre(priority: 1));
    add(_GoutteTournante(priority: 2));
    add(_Feutre(priority: 4));
  }

  @override
  void onGameResize(Vector2 taille) {
    super.onGameResize(taille);
    _geste = _construireGeste();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final maintenant = t;
    // La goutte : immobile, puis elle prend sa vitesse en 400 ms.
    if (_cibleAngle != null) {
      final p = Curves.easeOutCubic.transform(_seg(maintenant, _departPose, _departPose + 320));
      angleGoutte = p >= 1 ? _cibleAngle! : _angleDepart + (_cibleAngle! - _angleDepart) * p;
    } else if (maintenant >= _tTourne) {
      final cible = 2 * math.pi * _toursParSeconde;
      _vitesse = cible * Curves.easeOutCubic.transform(_seg(maintenant, _tTourne, _tTourne + 420));
      angleGoutte += _vitesse * dt;
    }
  }

  // ── Le geste, en pixels ──────────────────────────────────────────────

  double get h => hauteurMarque;
  Offset get centreBulle => centre + GeometrieMarque.centreBulle * h;
  double get rayonMilieu => (GeometrieMarque.rayonInterieurBulle + GeometrieMarque.rayonExterieurBulle) / 2 * h;
  double get epaisseurAnneau => (GeometrieMarque.rayonExterieurBulle - GeometrieMarque.rayonInterieurBulle) * h;

  /// Où commence l'anneau : là où naît la queue, en bas à gauche.
  static const double _angleDepartAnneau = math.pi * 0.70;

  Offset _surAnneau(double angle) => centreBulle + Offset(math.cos(angle), math.sin(angle)) * rayonMilieu;

  List<_Morceau> _construireGeste() {
    final s = size;
    if (s.x <= 0 || s.y <= 0) return const [];
    final depart = _surAnneau(_angleDepartAnneau);

    // A — l'entrée par le bord gauche, en zigzags qui se resserrent :
    // la main qui essaie le feutre avant de signer. Des pointes arrondies
    // (une courbe par aller), de plus en plus courtes à l'approche.
    final entree = Offset(-40, s.y * 0.2);
    final zig = Path()..moveTo(entree.dx, entree.dy);
    const n = 11;
    final dir = (depart - entree);
    final normale = Offset(-dir.dy, dir.dx) / dir.distance;
    var avant = entree;
    for (var k = 1; k <= n; k++) {
      final q = k / n;
      final base = Offset.lerp(entree, depart, Curves.easeOutSine.transform(q))!;
      final ampl = math.pow(1 - q, 0.8) * 34;
      final pointe = base + normale * (ampl * (k.isOdd ? 1 : -1));
      final milieu = Offset.lerp(avant, pointe, 0.5)! + normale * (ampl * 0.35 * (k.isOdd ? 1 : -1));
      zig.quadraticBezierTo(milieu.dx, milieu.dy, pointe.dx, pointe.dy);
      avant = pointe;
    }
    zig.lineTo(depart.dx, depart.dy);

    // B — l'anneau, d'un seul geste, dans le sens des aiguilles.
    final anneau = Path()..moveTo(depart.dx, depart.dy);
    const pas = 72;
    for (var k = 1; k <= pas; k++) {
      final p = _surAnneau(_angleDepartAnneau + k / pas * 2 * math.pi);
      anneau.lineTo(p.dx, p.dy);
    }

    // C — la queue : un aller-retour jusqu'à sa pointe.
    final pointe = centre + const Offset(-0.448, 0.482) * h;
    final retour = _surAnneau(_angleDepartAnneau - 0.32);
    final queue = Path()
      ..moveTo(depart.dx, depart.dy)
      ..quadraticBezierTo(pointe.dx + 6, pointe.dy - 10, pointe.dx, pointe.dy)
      ..quadraticBezierTo(pointe.dx + 10, pointe.dy - 4, retour.dx, retour.dy);

    // D — main levée jusqu'au sommet de la goutte, puis son contour.
    final contour = GeometrieMarque.goutte.transform(_matriceMarque());
    final m = contour.computeMetrics().first;
    // Le contour commence à droite de la pointe : on part de la pointe.
    final sommet = centre + const Offset(0.002, -0.2715) * h;
    final leve = Path()
      ..moveTo(retour.dx, retour.dy)
      ..quadraticBezierTo(centre.dx - 0.3 * h, centre.dy - 0.5 * h, sommet.dx, sommet.dy);
    final goutte = Path()..moveTo(sommet.dx, sommet.dy);
    // Du sommet, vers la gauche, en tournant : le geste naturel d'une goutte.
    final debut = _offsetLePlusProche(m, sommet);
    const pasG = 60;
    for (var k = 1; k <= pasG; k++) {
      final d = (debut + m.length * k / pasG) % m.length;
      final p = m.getTangentForOffset(d)!.position;
      goutte.lineTo(p.dx, p.dy);
    }

    // E — les hachures, qui remplissent la goutte en zigzag serré.
    final ventre = centre + GeometrieMarque.ventreGoutte * h;
    final hach = Path()..moveTo(sommet.dx, sommet.dy + 6);
    const lignes = 9;
    for (var k = 0; k <= lignes; k++) {
      final y = sommet.dy + 10 + (k / lignes) * (0.54 * h);
      final demi = _demiLargeurGoutte(y);
      hach.lineTo(ventre.dx + (k.isEven ? -demi : demi), y);
    }

    // F — la sortie, vers le haut et la droite.
    final sortie = Path()
      ..moveTo(ventre.dx, ventre.dy + 0.12 * h)
      ..cubicTo(centre.dx + 0.3 * h, centre.dy - 0.2 * h, s.x * 0.8, s.y * 0.22, s.x + 60, -60);
    final finHach = Offset(ventre.dx, ventre.dy + 0.12 * h);
    final versSortie = Path()
      ..moveTo(ventre.dx + _demiLargeurGoutte(sommet.dy + 10 + 0.54 * h), sommet.dy + 10 + 0.54 * h)
      ..lineTo(finHach.dx, finHach.dy);

    return [
      _Morceau(zig, _tEntree, _tAnneau, largeur: 3.6, fugace: true, courbe: Curves.easeOutQuad),
      _Morceau(anneau, _tAnneau, _tQueue, largeur: epaisseurAnneau, courbe: Curves.easeInOutCubic),
      _Morceau(queue, _tQueue, _tLeve, largeur: epaisseurAnneau * 0.9),
      _Morceau(leve, _tLeve, _tGoutte, encre: false),
      _Morceau(goutte, _tGoutte, _tHachures, largeur: 3.2, courbe: Curves.easeInOutCubic),
      _Morceau(hach, _tHachures, _tEncre, largeur: 7, courbe: Curves.linear),
      _Morceau(versSortie, _tEncre, _tSortie, encre: false, courbe: Curves.linear),
      _Morceau(sortie, _tSortie, kFeutreFini, encre: false, courbe: Curves.easeInCubic),
    ];
  }

  Float64List _matriceMarque() {
    final c = centre;
    return Float64List.fromList([h, 0, 0, 0, 0, h, 0, 0, 0, 0, 1, 0, c.dx, c.dy, 0, 1]);
  }

  double _offsetLePlusProche(ui.PathMetric m, Offset p) {
    var meilleur = 0.0, ecart = double.infinity;
    for (var k = 0; k < 200; k++) {
      final d = m.length * k / 200;
      final q = m.getTangentForOffset(d)!.position;
      final e = (q - p).distanceSquared;
      if (e < ecart) {
        ecart = e;
        meilleur = d;
      }
    }
    return meilleur;
  }

  /// La demi-largeur (un peu rentrée) de la goutte à la hauteur [y].
  double _demiLargeurGoutte(double y) {
    final u = ((y - centre.dy) / h); // -0.27 (pointe) → 0.29 (base)
    final v = ((u + 0.27) / 0.56).clamp(0.0, 1.0);
    // Pointue en haut, ronde en bas.
    final forme = v < 0.62 ? math.pow(v / 0.62, 0.9).toDouble() : math.sqrt(1 - math.pow((v - 0.62) / 0.38, 2) * 0.9);
    return 0.17 * h * forme;
  }

  /// Le morceau en cours à l'instant [t] (ou null : avant/après le geste).
  _Morceau? enCours(double t) {
    for (final m in _geste) {
      if (t >= m.t0 && t < m.t1) return m;
    }
    return null;
  }

  // ── Les éclaboussures d'encre ────────────────────────────────────────

  final math.Random _hasard = math.Random(7);

  void eclabousser(Offset ou, {int nombre = 7, double force = 1}) {
    add(ParticleSystemComponent(
      priority: 3,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: nombre,
        lifespan: 0.42,
        generator: (i) {
          final a = _hasard.nextDouble() * 2 * math.pi;
          final v = (40 + _hasard.nextDouble() * 120) * force;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v - 60 * force),
            acceleration: Vector2(0, 520),
            child: _GouttelettEncre(rayon: 1.0 + _hasard.nextDouble() * 1.6 * force, couleur: couleur),
          );
        },
      ),
    ));
  }
}

/// Une gouttelette d'encre qui sèche (rétrécit et pâlit) en vol.
class _GouttelettEncre extends Particle {
  _GouttelettEncre({required this.rayon, required this.couleur}) : super(lifespan: 0.42);
  final double rayon;
  final Color couleur;

  @override
  void render(Canvas canvas) {
    final p = progress;
    canvas.drawCircle(Offset.zero, rayon * (1 - 0.5 * p), Paint()..color = couleur.withValues(alpha: couleur.a * (1 - p)));
  }
}

// ─────────────────────────────────────────────────────────────
//  L'ENCRE : l'esquisse, les traits, puis la marque exacte
// ─────────────────────────────────────────────────────────────

class _Encre extends Component with HasGameReference<JeuFeutreOuverture> {
  _Encre({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t;
    final c = j.centre;
    final h = j.h;
    canvas.drawRect(Offset.zero & Size(j.size.x, j.size.y), Paint()..color = j.fond);

    // L'esquisse : la bulle native pâlit jusqu'à 12 %, puis s'efface sous
    // l'encre.
    final esquisse = 1 - 0.88 * Curves.easeOut.transform(_seg(t, 0, kFeutreEsquisse));
    final exacte = Curves.easeInOut.transform(_seg(t, _tEncre, _tEncre + 140));
    if (exacte < 1) {
      PeintreMarque.peindre(canvas, c, h, j.couleur, PoseMarque(opacite: esquisse * (1 - exacte), opaciteGoutte: 0));
    }

    // Les traits du feutre.
    if (exacte < 1) {
      for (final m in j._geste) {
        if (!m.encre || t < m.t0) continue;
        final p = m.avance(t);
        var alpha = 1.0 - exacte;
        // Les zigzags d'essai sèchent pendant que l'anneau se trace.
        if (m.fugace) alpha *= 1 - Curves.easeInOut.transform(_seg(t, _tAnneau + 40, _tAnneau + 300));
        if (alpha <= 0.01) continue;
        final trait = m.metrique.extractPath(0, m.metrique.length * p);
        canvas.drawPath(
          trait,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = m.largeur
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = j.couleur.withValues(alpha: j.couleur.a * alpha * (m.fugace ? 0.55 : 1)),
        );
      }
      // La queue se colorie pendant qu'on la trace.
      final queue = _seg(t, _tQueue + 40, _tLeve);
      if (queue > 0) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(h);
        canvas.drawPath(
          Path.combine(
            PathOperation.difference,
            GeometrieMarque.bulle,
            Path()..addOval(Rect.fromCircle(center: GeometrieMarque.centreBulle, radius: GeometrieMarque.rayonExterieurBulle - 0.004)),
          ),
          Paint()..color = j.couleur.withValues(alpha: j.couleur.a * queue * (1 - exacte)),
        );
        canvas.restore();
      }
      // La goutte se remplit sous les hachures.
      final remplie = _seg(t, _tHachures, _tEncre + 60);
      if (remplie > 0) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(h);
        canvas.drawPath(GeometrieMarque.goutte, Paint()..color = j.couleur.withValues(alpha: j.couleur.a * 0.85 * remplie * (1 - exacte)));
        canvas.restore();
      }
    }

    // La marque exacte : l'anneau seul (la goutte est dessinée à part,
    // parce qu'elle tourne).
    if (exacte > 0) {
      PeintreMarque.peindre(canvas, c, h, j.couleur, PoseMarque(opacite: exacte, opaciteGoutte: 0));
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  LA GOUTTE QUI TOURNE
// ─────────────────────────────────────────────────────────────

class _GoutteTournante extends Component with HasGameReference<JeuFeutreOuverture> {
  _GoutteTournante({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t;
    final exacte = Curves.easeInOut.transform(_seg(t, _tEncre, _tEncre + 140));
    if (exacte <= 0) return;
    final c = j.centre;
    final h = j.h;
    final a = j.angleGoutte;
    final face = math.cos(a);
    // De face, la goutte est EXACTEMENT celle de la marque : même chemin,
    // même dégradé (`PeintreMarque`), pour que la reprise par l'ouverture
    // ne se voie pas.
    if ((face - 1).abs() < 1e-4) {
      final pose = PoseMarque(opacite: exacte, opaciteGoutte: 1);
      // Seule la goutte : la bulle est déjà dessinée par l'encre.
      canvas.save();
      canvas.clipPath(GeometrieMarque.goutte.transform(Float64List.fromList([h, 0, 0, 0, 0, h, 0, 0, 0, 0, 1, 0, c.dx, c.dy, 0, 1])));
      PeintreMarque.peindre(canvas, c, h, j.couleur, pose);
      canvas.restore();
      return;
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(h);
    // Elle tourne autour de son axe vertical : sa largeur suit le cosinus,
    // jamais tout à fait nulle (une goutte a de l'épaisseur).
    final largeur = math.max(0.2, face.abs());
    canvas.scale(largeur, 1);
    // La lumière glisse d'un bord à l'autre au fil du tour.
    final cote = math.sin(a);
    final clair = Color.lerp(j.couleur, const Color(0xFFFFFFFF), 0.22)!;
    final sombreC = Color.lerp(j.couleur, const Color(0xFF000000), 0.18)!;
    canvas.drawPath(
      GeometrieMarque.goutte,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(-0.2 * (cote >= 0 ? 1 : -1), 0),
          Offset(0.2 * (cote >= 0 ? 1 : -1), 0),
          [
            Color.lerp(j.couleur, clair, cote.abs())!.withValues(alpha: exacte),
            Color.lerp(j.couleur, sombreC, cote.abs())!.withValues(alpha: exacte),
          ],
        ),
    );
    // Un reflet, qui traverse la goutte.
    final xReflet = -0.07 * face.sign + 0.08 * cote;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(xReflet, 0.05), width: 0.05, height: 0.12),
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.28 * exacte * face.abs()),
    );
    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────
//  LE FEUTRE
// ─────────────────────────────────────────────────────────────

class _Feutre extends Component with HasGameReference<JeuFeutreOuverture> {
  _Feutre({super.priority});

  _Morceau? _precedent;

  @override
  void update(double dt) {
    final j = game;
    final m = j.enCours(j.t);
    // Le feutre se pose : une petite éclaboussure à chaque attaque d'un
    // trait, une plus forte au lever final.
    if (m != _precedent) {
      // Seulement deux fois : quand la pointe se pose pour l'anneau, et
      // quand elle quitte la goutte coloriée.
      if (m != null && m.largeur > 6 && m.t0 == _tAnneau) j.eclabousser(m.point(m.t0), nombre: 4, force: 0.6);
      if (_precedent != null && _precedent!.t1 == _tEncre) j.eclabousser(_precedent!.point(_precedent!.t1), nombre: 5, force: 0.8);
      _precedent = m;
    }
  }

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t;
    if (t < _tEntree || t >= kFeutreFini) return;
    final m = j.enCours(t);
    if (m == null) return;
    final pointe = m.point(t);
    // Levé quand il n'écrit pas : plus haut, ombre plus douce et décalée.
    final leve = m.encre ? 0.0 : 1.0;
    final inclinaison = -0.72 + 0.12 * math.sin(t / 90);
    final ombre = Offset(10 + 16 * leve, 12 + 18 * leve);
    _dessiner(canvas, pointe + ombre, inclinaison, ombre: true, flou: 3 + 5 * leve);
    _dessiner(canvas, pointe - Offset(0, 6 * leve), inclinaison);
  }

  void _dessiner(Canvas canvas, Offset pointe, double angle, {bool ombre = false, double flou = 0}) {
    final j = game;
    canvas.save();
    canvas.translate(pointe.dx, pointe.dy);
    // L'axe du feutre part de la pointe vers le haut-droite (main droite).
    canvas.rotate(angle);
    const long = 92.0, large = 17.0;
    final corps = RRect.fromRectAndRadius(Rect.fromLTWH(14, -large / 2, long, large), const Radius.circular(6));
    final cone = Path()
      ..moveTo(0, 0)
      ..lineTo(15, -large * 0.32)
      ..lineTo(15, large * 0.32)
      ..close();
    if (ombre) {
      final p = Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, flou);
      canvas.drawRRect(corps, p);
      canvas.drawPath(cone, p);
      canvas.restore();
      return;
    }
    final corpsCouleur = j.sombre ? const Color(0xFFE9ECF2) : const Color(0xFF2B2F37);
    canvas.drawRRect(
      corps,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -large / 2),
          const Offset(0, large / 2),
          [Color.lerp(corpsCouleur, const Color(0xFFFFFFFF), 0.18)!, corpsCouleur, Color.lerp(corpsCouleur, const Color(0xFF000000), 0.25)!],
          [0, 0.45, 1],
        ),
    );
    // La bague, à la couleur de l'encre, et le capuchon.
    canvas.drawRect(Rect.fromLTWH(18, -large / 2, 7, large), Paint()..color = j.couleur);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(14 + long - 22, -large / 2 - 1, 24, large + 2), const Radius.circular(7)),
      Paint()..color = j.couleur,
    );
    // La pointe, imbibée.
    canvas.drawPath(cone, Paint()..color = Color.lerp(j.couleur, const Color(0xFF000000), 0.15)!);
    canvas.drawCircle(Offset.zero, 2.2, Paint()..color = j.couleur);
    canvas.restore();
  }
}
