// ============================================================================
// LES ÉTATS VIDES EN AUTOCOLLANTS — comme les illustrations de WhatsApp.
// ----------------------------------------------------------------------------
// Ce que WhatsApp montre quand un écran n'a encore rien (réserver un nom de
// profil, aucune conversation…) : pas une icône grise, mais une petite
// GRAPPE D'AUTOCOLLANTS — des pastilles et des bulles de la même teinte en
// trois tons, au trait noir épais avec une ombre décalée, des pictos au
// trait dedans — et UN élément qui vit : un avion en papier qui fait sa
// boucle en laissant un fil blanc, une main qui salue, un visage qui
// flotte. On comprend l'écran avant d'avoir lu.
//
// Ici, chaque état vide a sa grappe (`SceneVide`), aux couleurs de
// l'accent choisi par la personne. Tout est dessiné en code : aucune image,
// aucun fichier à télécharger, net à toutes les tailles, et les trois tons
// suivent l'accent et le mode sombre.
//
// ── Avec Flame ───────────────────────────────────────────────────────
//
// La grappe est une petite scène Flame : chaque autocollant est un
// composant qui a sa vie propre.
//   • L'ENTRÉE : les autocollants se COLLENT l'un après l'autre (un petit
//     rebond, une rotation qui se redresse), puis leur picto apparaît.
//   • AU REPOS : chacun flotte à son rythme ; un seul geste par grappe
//     (la main qui salue, le combiné qui sonne, la loupe qui balaie…).
//   • L'AVION EN PAPIER s'incline dans ses virages, laisse un fil qui
//     s'efface, et sème trois étincelles en sortant.
//   • UN TOUCHER : les autocollants sursautent l'un après l'autre et une
//     poignée de confettis aux trois tons jaillit du doigt.
//   • Un reflet sur chaque pastille, une ombre au sol (une lueur en mode
//     sombre, où un contour noir sur fond noir ne détacherait rien).
//
// « Réduire les animations » : la grappe est posée d'emblée, immobile.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_colors.dart';
import 'marque_droplet.dart';

/// Les grappes disponibles, une par sorte d'écran vide.
enum SceneVide {
  discussions,
  recherche,
  pairs,
  diffusion,
  appels,
  statuts,
  groupe,
  carte,
  securite,
  notifications,
  importants,
  partage,
}

/// Comment un autocollant bouge.
enum _Jeu { aucun, flotte, salue, pulse, tourne, sonne }

/// Une forme de la grappe.
enum _Forme { rond, bulleGauche, bulleDroite }

/// Un autocollant : une forme, un ton, un picto, une place.
class _Piece {
  const _Piece(this.forme, this.centre, this.taille, this.ton, {this.icone, this.goutte = false, this.jeu = _Jeu.aucun, this.phase = 0});

  final _Forme forme;

  /// Dans un repère de 1 × 0,68 (la grappe est plus large que haute).
  final Offset centre;

  /// Le rayon d'un rond ; la demi-largeur d'une bulle.
  final double taille;

  /// 0 = l'accent plein, 1 = clair, 2 = très clair.
  final int ton;
  final IconData? icone;

  /// Au lieu d'un picto : la goutte de Droplet.
  final bool goutte;
  final _Jeu jeu;
  final double phase;
}

/// Ce qui s'ajoute à la grappe et la fait vivre.
enum _Extra { avion, ondes, pointilles, goutteRelais }

class _Grappe {
  const _Grappe(this.pieces, {this.extras = const []});
  final List<_Piece> pieces;
  final List<_Extra> extras;
}

const double _kHaut = 0.68;

final Map<SceneVide, _Grappe> _grappes = {
  SceneVide.discussions: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.3, 0.44), 0.13, 2, icone: Icons.person_outline_rounded, jeu: _Jeu.flotte, phase: 1.2),
    _Piece(_Forme.rond, Offset(0.5, 0.34), 0.165, 0, goutte: true),
    _Piece(_Forme.rond, Offset(0.66, 0.16), 0.085, 1, icone: Icons.sentiment_satisfied_alt_outlined, jeu: _Jeu.flotte),
    _Piece(_Forme.bulleDroite, Offset(0.7, 0.47), 0.1, 0, icone: Icons.waving_hand_outlined, jeu: _Jeu.salue),
  ], extras: [_Extra.avion]),
  SceneVide.recherche: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.3, 0.46), 0.11, 2, icone: Icons.question_mark_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.165, 0, icone: Icons.search_rounded, jeu: _Jeu.salue),
    _Piece(_Forme.rond, Offset(0.7, 0.44), 0.09, 1, icone: Icons.person_outline_rounded, jeu: _Jeu.flotte, phase: 2),
  ]),
  SceneVide.pairs: const _Grappe([
    _Piece(_Forme.rond, Offset(0.24, 0.42), 0.085, 2, icone: Icons.smartphone_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.32), 0.15, 0, icone: Icons.bluetooth_rounded),
    _Piece(_Forme.rond, Offset(0.76, 0.42), 0.085, 1, icone: Icons.smartphone_rounded, jeu: _Jeu.flotte, phase: 1.6),
  ], extras: [_Extra.ondes, _Extra.goutteRelais]),
  SceneVide.diffusion: const _Grappe([
    _Piece(_Forme.rond, Offset(0.5, 0.34), 0.16, 0, icone: Icons.campaign_outlined, jeu: _Jeu.sonne),
    _Piece(_Forme.bulleGauche, Offset(0.27, 0.48), 0.09, 2, icone: Icons.smartphone_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.bulleDroite, Offset(0.73, 0.48), 0.09, 1, icone: Icons.smartphone_rounded, jeu: _Jeu.flotte, phase: 1.4),
  ], extras: [_Extra.ondes]),
  SceneVide.appels: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.47), 0.11, 2, icone: Icons.graphic_eq_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.16, 0, icone: Icons.call_rounded, jeu: _Jeu.sonne),
    _Piece(_Forme.rond, Offset(0.71, 0.18), 0.08, 1, icone: Icons.videocam_outlined, jeu: _Jeu.flotte, phase: 1.1),
  ], extras: [_Extra.ondes]),
  SceneVide.statuts: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.47), 0.1, 2, icone: Icons.favorite_border_rounded, jeu: _Jeu.pulse),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.155, 0, icone: Icons.photo_camera_outlined),
    _Piece(_Forme.rond, Offset(0.71, 0.17), 0.08, 1, icone: Icons.auto_awesome_outlined, jeu: _Jeu.tourne),
  ], extras: [_Extra.pointilles]),
  SceneVide.groupe: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.28, 0.46), 0.11, 2, icone: Icons.sentiment_satisfied_alt_outlined, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.165, 0, icone: Icons.groups_outlined),
    _Piece(_Forme.rond, Offset(0.7, 0.16), 0.075, 1, icone: Icons.add_rounded, jeu: _Jeu.pulse),
    _Piece(_Forme.bulleDroite, Offset(0.72, 0.47), 0.095, 0, icone: Icons.waving_hand_outlined, jeu: _Jeu.salue),
  ], extras: [_Extra.avion]),
  SceneVide.carte: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.46), 0.11, 2, icone: Icons.map_outlined, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.32), 0.155, 0, icone: Icons.place_outlined, jeu: _Jeu.flotte, phase: 0.6),
    _Piece(_Forme.rond, Offset(0.71, 0.45), 0.08, 1, icone: Icons.wifi_off_rounded),
  ], extras: [_Extra.ondes]),
  SceneVide.securite: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.46), 0.1, 2, icone: Icons.vpn_key_outlined, jeu: _Jeu.salue),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.16, 0, icone: Icons.shield_outlined, jeu: _Jeu.pulse),
    _Piece(_Forme.rond, Offset(0.71, 0.17), 0.08, 1, icone: Icons.check_rounded, jeu: _Jeu.flotte),
  ]),
  SceneVide.notifications: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.46), 0.1, 2, icone: Icons.alternate_email_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.16, 0, icone: Icons.notifications_none_rounded, jeu: _Jeu.sonne),
    _Piece(_Forme.rond, Offset(0.71, 0.17), 0.08, 1, icone: Icons.check_rounded, jeu: _Jeu.flotte, phase: 1.3),
  ]),
  SceneVide.importants: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.29, 0.46), 0.11, 2, icone: Icons.chat_bubble_outline_rounded, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.5, 0.33), 0.16, 0, icone: Icons.star_border_rounded, jeu: _Jeu.pulse),
    _Piece(_Forme.rond, Offset(0.71, 0.17), 0.08, 1, icone: Icons.bookmark_border_rounded, jeu: _Jeu.flotte, phase: 0.9),
  ]),
  SceneVide.partage: const _Grappe([
    _Piece(_Forme.bulleGauche, Offset(0.3, 0.45), 0.12, 2, icone: Icons.photo_outlined, jeu: _Jeu.flotte),
    _Piece(_Forme.rond, Offset(0.52, 0.33), 0.155, 0, goutte: true),
    _Piece(_Forme.bulleDroite, Offset(0.71, 0.46), 0.095, 1, icone: Icons.chat_bubble_outline_rounded, jeu: _Jeu.flotte, phase: 1.5),
  ], extras: [_Extra.avion]),
};

/// La grappe d'autocollants d'un état vide, animée avec Flame.
class AutocollantsVides extends StatefulWidget {
  const AutocollantsVides({super.key, required this.scene, this.largeur = 200, this.tempsFixe});

  final SceneVide scene;
  final double largeur;

  /// Pour les tests de rendu : un instant imposé du repos, en secondes
  /// (l'entrée est alors déjà jouée).
  @visibleForTesting
  final double? tempsFixe;

  @override
  State<AutocollantsVides> createState() => _AutocollantsVidesState();
}

class _AutocollantsVidesState extends State<AutocollantsVides> {
  late final JeuGrappe _jeu = JeuGrappe(grappe: _grappes[widget.scene]!);

  @override
  Widget build(BuildContext context) {
    _jeu
      ..accent = OuroColors.accent
      ..sombre = Theme.of(context).brightness == Brightness.dark
      ..reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ..tempsFixe = widget.tempsFixe;
    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          if (_jeu.reduit) return;
          HapticFeedback.lightImpact();
          _jeu.toucher(d.localPosition);
        },
        child: SizedBox(
          width: widget.largeur,
          height: widget.largeur * _kHaut,
          child: RepaintBoundary(child: GameWidget<JeuGrappe>(game: _jeu)),
        ),
      ),
    );
  }
}

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// L'encre des contours : un presque-noir, comme chez WhatsApp.
const Color _encre = Color(0xFF111418);

class JeuGrappe extends FlameGame {
  JeuGrappe({required this.grappe});

  final _Grappe grappe;
  Color accent = const Color(0xFF0A84FF);
  bool sombre = false;
  bool reduit = false;
  double? tempsFixe;

  double _temps = 0;

  /// Le temps de la scène, en secondes. Posée et immobile en « Réduire
  /// les animations » ; l'entrée déjà jouée dans les tests.
  double get t => tempsFixe != null ? tempsFixe! + 1.6 : (reduit ? 1.6 : _temps);

  double get u => size.x;

  Color ton(int t) => switch (t) {
        0 => accent,
        1 => Color.lerp(accent, Colors.white, 0.45)!,
        _ => Color.lerp(accent, Colors.white, 0.84)!,
      };

  final List<_PieceComp> _pieces = [];

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    add(_Sol(priority: 0));
    if (grappe.extras.contains(_Extra.ondes)) add(_Ondes(priority: 1));
    if (grappe.extras.contains(_Extra.pointilles)) add(_Pointilles(priority: 1));
    final avion = grappe.extras.contains(_Extra.avion);
    if (avion) add(_Avion(derriere: true, priority: 2));
    for (var k = 0; k < grappe.pieces.length; k++) {
      final c = _PieceComp(grappe.pieces[k], k, priority: 3 + k);
      _pieces.add(c);
      add(c);
    }
    if (grappe.extras.contains(_Extra.goutteRelais)) add(_GoutteRelais(priority: 20));
    if (avion) add(_Avion(derriere: false, priority: 21));
  }

  @override
  void update(double dt) {
    if (!reduit && tempsFixe == null) _temps += math.min(dt, 1 / 20);
    super.update(dt);
  }

  // ── Le toucher ─────────────────────────────────────────────────────

  final math.Random _hasard = math.Random();

  void toucher(Offset ou) {
    for (final p in _pieces) {
      p.sursaut(t + p.index * 0.06);
    }
    add(ParticleSystemComponent(
      priority: 30,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: 14,
        lifespan: 0.8,
        generator: (i) {
          final a = -math.pi / 2 + (_hasard.nextDouble() - 0.5) * 2.4;
          final v = 90 + _hasard.nextDouble() * 120;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v),
            acceleration: Vector2(0, 380),
            child: i % 3 == 0 ? _Etincelle(couleur: ton(0)) : _Confetti(couleur: ton(i % 3), angle0: _hasard.nextDouble() * 3),
          );
        },
      ),
    ));
  }

  /// Trois étincelles, là où l'avion quitte la scène.
  void etincelles(Offset ou) {
    if (reduit || tempsFixe != null) return;
    add(ParticleSystemComponent(
      priority: 30,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: 3,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          speed: Vector2(-30 + _hasard.nextDouble() * 60, -20 - _hasard.nextDouble() * 40),
          child: _Etincelle(couleur: sombre ? Colors.white : ton(0)),
        ),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────
//  LE SOL : l'ombre portée (ou la lueur, en sombre)
// ─────────────────────────────────────────────────────────────

class _Sol extends Component with HasGameReference<JeuGrappe> {
  _Sol({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final u = j.u;
    final apparition = Curves.easeOut.transform(_seg(j.t, 0, 0.5));
    if (j.sombre) {
      final c = Offset(u * 0.5, u * 0.34);
      canvas.drawCircle(
        c,
        u * 0.42,
        Paint()
          ..shader = ui.Gradient.radial(c, u * 0.42, [
            j.accent.withValues(alpha: 0.26 * apparition),
            j.accent.withValues(alpha: 0),
          ]),
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(u * 0.5, u * 0.62), width: u * 0.62, height: u * 0.07),
        Paint()
          ..color = _encre.withValues(alpha: 0.08 * apparition)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.02),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  UN AUTOCOLLANT
// ─────────────────────────────────────────────────────────────

class _PieceComp extends Component with HasGameReference<JeuGrappe> {
  _PieceComp(this.p, this.index, {super.priority});

  final _Piece p;
  final int index;
  double? _sursaut;

  void sursaut(double depuis) => _sursaut = depuis;

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t;
    final u = j.u;

    // L'entrée : collé avec un rebond, la rotation se redresse.
    final t0 = 0.08 + index * 0.09;
    final e = _seg(t, t0, t0 + 0.5);
    if (e <= 0) return;
    final pose = Curves.easeOutBack.transform(e);
    final picto = Curves.easeOutBack.transform(_seg(t, t0 + 0.14, t0 + 0.5));

    final s = t + p.phase;
    var dy = math.sin(s * 1.7 + index) * 0.004;
    var angle = (1 - Curves.easeOut.transform(e)) * (index.isEven ? -0.3 : 0.3);
    var anglePicto = 0.0, echelle = pose;
    switch (p.jeu) {
      case _Jeu.flotte:
        dy += math.sin(s * 2.1) * 0.012;
      case _Jeu.salue:
        final c = (s % 2.6) / 2.6;
        anglePicto = c < 0.5 ? 0.24 * math.sin(c / 0.5 * 3 * 2 * math.pi) * (1 - c / 0.5 * 0.4) : 0;
      case _Jeu.pulse:
        echelle *= 1 + 0.06 * math.pow(math.sin(s * 2.4).abs(), 3).toDouble();
      case _Jeu.tourne:
        anglePicto = s * 0.9;
      case _Jeu.sonne:
        final c = (s % 2.2) / 2.2;
        anglePicto = c < 0.35 ? 0.18 * math.sin(c / 0.35 * 5 * 2 * math.pi) : 0;
      case _Jeu.aucun:
        break;
    }
    // Le sursaut d'un toucher : un ressort amorti, en écrasement et en
    // rotation.
    final sur = _sursaut;
    if (sur != null) {
      final d = t - sur;
      if (d > 0 && d < 1.2) {
        final ressort = math.exp(-5 * d) * math.sin(d * 22);
        echelle *= 1 + 0.12 * ressort;
        angle += 0.12 * ressort;
      }
    }

    const milieu = Offset(0.5, 0.34);
    final place = milieu + (p.centre - milieu) * 0.9;
    final centre = Offset(place.dx * u, (place.dy + dy) * u);
    final r = p.taille * u * 1.14;
    final trait = math.max(1.6, u * 0.0105);

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(angle);
    canvas.scale(echelle);
    final chemin = _chemin(p.forme, r);
    canvas.drawPath(chemin.shift(Offset(trait * 1.2, trait * 1.4)), Paint()..color = _encre);
    canvas.drawPath(chemin, Paint()..color = j.ton(p.ton));
    // Le reflet : un croissant clair en haut à gauche, dans la forme.
    canvas.save();
    canvas.clipPath(chemin);
    canvas.drawCircle(
      Offset(-r * 0.35, -r * 0.42),
      r * 0.7,
      Paint()
        ..shader = ui.Gradient.radial(Offset(-r * 0.35, -r * 0.42), r * 0.7, [
          Colors.white.withValues(alpha: p.ton == 0 ? 0.28 : 0.45),
          Colors.white.withValues(alpha: 0),
        ]),
    );
    canvas.restore();
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trait
        ..strokeJoin = StrokeJoin.round
        ..color = _encre,
    );
    // Le picto, qui seul tourne ou salue.
    if (picto > 0) {
      final decale = switch (p.forme) {
        _Forme.rond => Offset.zero,
        _Forme.bulleGauche => Offset(-r * 0.3, -r * 0.08),
        _Forme.bulleDroite => Offset(r * 0.3, -r * 0.08),
      };
      canvas.save();
      canvas.translate(decale.dx, decale.dy);
      canvas.rotate(anglePicto);
      canvas.scale(picto);
      if (p.goutte) {
        _goutte(canvas, r * 1.15);
      } else if (p.icone != null) {
        _icone(canvas, p.icone!, r * 1.05, p.ton == 0 ? Colors.white : _encre);
      }
      canvas.restore();
    }
    canvas.restore();
  }
}

Path _chemin(_Forme f, double r) {
  switch (f) {
    case _Forme.rond:
      return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
    case _Forme.bulleGauche:
    case _Forme.bulleDroite:
      final g = f == _Forme.bulleGauche ? -1.0 : 1.0;
      final h = r * 0.82;
      final corps = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: r * 2, height: h * 2), Radius.circular(h)));
      final queue = Path()
        ..moveTo(g * r * 0.35, h * 0.6)
        ..quadraticBezierTo(g * r * 0.95, h * 1.25, g * r * 1.05, h * 1.32)
        ..quadraticBezierTo(g * r * 0.55, h * 1.2, g * r * 0.05, h * 0.85)
        ..close();
      return Path.combine(PathOperation.union, corps, queue);
  }
}

void _icone(Canvas canvas, IconData icone, double taille, Color couleur) {
  final tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icone.codePoint),
      style: TextStyle(fontFamily: icone.fontFamily, package: icone.fontPackage, fontSize: taille, height: 1, color: couleur),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  tp.dispose();
}

void _goutte(Canvas canvas, double taille) {
  canvas.save();
  canvas.translate(0, taille * 0.02);
  canvas.scale(taille / 0.565 * 0.62);
  canvas.drawPath(GeometrieMarque.goutte, Paint()..color = Colors.white);
  canvas.drawPath(
    GeometrieMarque.goutte,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.022
      ..color = _encre,
  );
  canvas.restore();
}

// ─────────────────────────────────────────────────────────────
//  L'AVION EN PAPIER
// ─────────────────────────────────────────────────────────────

const double _periodeAvion = 3.4;

Offset _posAvion(double q) {
  const a = Offset(0.06, 0.62), b = Offset(-0.03, 0.16), c = Offset(0.3, 0.0), d = Offset(0.62, -0.01);
  const e = Offset(0.86, -0.04), f = Offset(1.12, -0.22);
  if (q < 0.55) {
    final k = q / 0.55, v = 1 - k;
    return a * (v * v * v) + b * (3 * v * v * k) + c * (3 * v * k * k) + d * (k * k * k);
  }
  final k = (q - 0.55) / 0.45, v = 1 - k;
  return d * (v * v) + e * (2 * v * k) + f * (k * k);
}

class _Avion extends Component with HasGameReference<JeuGrappe> {
  _Avion({required this.derriere, super.priority});

  final bool derriere;
  int _dernierTour = -1;

  /// Où en est la boucle (0 → 1), ou null pendant la pause.
  double? _q(double t) {
    final tt = t - 0.7;
    if (tt < 0) return null;
    final c = (tt % _periodeAvion) / _periodeAvion;
    return c > 0.82 ? null : c / 0.82;
  }

  @override
  void update(double dt) {
    if (derriere) return;
    final j = game;
    final tt = j.t - 0.7;
    if (tt < 0) return;
    final tour = (tt / _periodeAvion).floor();
    final q = _q(j.t);
    if (q != null && q > 0.97 && tour != _dernierTour) {
      _dernierTour = tour;
      j.etincelles(_posAvion(0.97) * j.u);
    }
  }

  @override
  void render(Canvas canvas) {
    final j = game;
    final q = _q(j.t);
    if (q == null) return;
    // Derrière la grappe tant qu'il monte dans son ombre, devant ensuite.
    if (derriere == (q > 0.35)) return;
    final u = j.u;

    // Le fil : les 40 % de trajet précédents, du transparent au plein.
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, u * 0.007)
      ..strokeCap = StrokeCap.round;
    const pas = 24;
    var avant = _posAvion((q - 0.4).clamp(0.0, 1.0)) * u;
    for (var k = 1; k <= pas; k++) {
      final qq = (q - 0.4 + 0.4 * k / pas).clamp(0.0, 1.0);
      final p = _posAvion(qq) * u;
      pinceau.color = (j.sombre ? Colors.white : _encre).withValues(alpha: 0.85 * k / pas);
      canvas.drawLine(avant, p, pinceau);
      avant = p;
    }

    final p = _posAvion(q) * u;
    final p2 = _posAvion(math.min(1, q + 0.01)) * u;
    final p0 = _posAvion(math.max(0, q - 0.01)) * u;
    final cap = math.atan2(p2.dy - p.dy, p2.dx - p.dx);
    final capAvant = math.atan2(p.dy - p0.dy, p.dx - p0.dx);
    // Il s'incline dans les virages : l'aile intérieure se resserre.
    final virage = ((cap - capAvant) * 12).clamp(-0.5, 0.5);
    final e = u * 0.078;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(cap);
    canvas.scale(1, 1 - virage.abs() * 0.5);
    final aileHaute = Path()
      ..moveTo(e, 0)
      ..lineTo(-e * 0.7, -e * 0.62)
      ..lineTo(-e * 0.35, 0)
      ..close();
    final aileBasse = Path()
      ..moveTo(e, 0)
      ..lineTo(-e * 0.35, 0)
      ..lineTo(-e * 0.7, e * 0.62)
      ..close();
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, u * 0.008)
      ..strokeJoin = StrokeJoin.round
      ..color = _encre;
    canvas.drawPath(aileHaute, Paint()..color = Colors.white);
    canvas.drawPath(aileBasse, Paint()..color = Color.lerp(Colors.white, j.accent, 0.18)!);
    canvas.drawPath(aileHaute, contour);
    canvas.drawPath(aileBasse, contour);
    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────
//  LES EXTRAS : ondes, pointillés, goutte qui saute
// ─────────────────────────────────────────────────────────────

class _Ondes extends Component with HasGameReference<JeuGrappe> {
  _Ondes({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    if (j.t < 0.5) return;
    final u = j.u;
    final p = j.grappe.pieces.firstWhere((p) => p.ton == 0);
    const milieu = Offset(0.5, 0.34);
    final centre = (milieu + (p.centre - milieu) * 0.9) * u;
    final r0 = p.taille * u * 1.14;
    for (var k = 0; k < 2; k++) {
      final c = (((j.t - 0.5) / 2.4) + k * 0.5) % 1.0;
      canvas.drawCircle(
        centre,
        r0 + c * u * 0.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, u * 0.009) * (1 - c * 0.5)
          ..color = j.accent.withValues(alpha: (j.sombre ? 0.7 : 0.5) * math.pow(1 - c, 1.5).toDouble()),
      );
    }
  }
}

class _Pointilles extends Component with HasGameReference<JeuGrappe> {
  _Pointilles({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final e = Curves.easeOut.transform(_seg(j.t, 0.3, 0.8));
    if (e <= 0) return;
    final u = j.u;
    final p = j.grappe.pieces.firstWhere((p) => p.ton == 0);
    const milieu = Offset(0.5, 0.34);
    final centre = (milieu + (p.centre - milieu) * 0.9) * u;
    final r = p.taille * u * 1.14 * 1.3;
    const n = 18;
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, u * 0.011)
      ..strokeCap = StrokeCap.round
      ..color = j.accent;
    for (var k = 0; k < n; k++) {
      final a = j.t * 0.5 + k * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: centre, radius: r), a, 2 * math.pi / n * 0.55 * e, false, pinceau);
    }
  }
}

class _GoutteRelais extends Component with HasGameReference<JeuGrappe> {
  _GoutteRelais({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t - 0.6;
    if (t < 0) return;
    final u = j.u;
    const milieu = Offset(0.5, 0.34);
    Offset place(_Piece p) => (milieu + (p.centre - milieu) * 0.9) * u;
    final g = place(j.grappe.pieces.first);
    final d = place(j.grappe.pieces.last);
    final c = (t % 1.8) / 1.8;
    final aller = ((t ~/ 1.8) % 2) == 0;
    final q = Curves.easeInOutSine.transform(c);
    final de = aller ? g : d, vers = aller ? d : g;
    final pos = Offset.lerp(de, vers, q)! - Offset(0, math.sin(math.pi * q) * u * 0.26);
    final h = u * 0.06;
    // Elle s'étire en vol, s'écrase à l'arrivée.
    final etire = 1 + 0.25 * math.sin(math.pi * q);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(h / 0.565 / etire, h / 0.565 * etire);
    canvas.drawPath(GeometrieMarque.goutte, Paint()..color = j.accent);
    canvas.drawPath(GeometrieMarque.goutte, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.035..color = _encre);
    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────
//  LES PARTICULES
// ─────────────────────────────────────────────────────────────

class _Confetti extends Particle {
  _Confetti({required this.couleur, required this.angle0}) : super(lifespan: 0.8);
  final Color couleur;
  final double angle0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(angle0 + progress * 9);
    final w = 7 * math.cos(progress * 13).abs() + 1.5;
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: 4.5), const Radius.circular(1.5));
    canvas.drawRRect(r, Paint()..color = couleur.withValues(alpha: 1 - progress));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _encre.withValues(alpha: 1 - progress),
    );
    canvas.restore();
  }
}

class _Etincelle extends Particle {
  _Etincelle({required this.couleur}) : super(lifespan: 0.6);
  final Color couleur;

  @override
  void render(Canvas canvas) {
    final r = 3.6 * (1 - progress * 0.6);
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
      Paint()..color = couleur.withValues(alpha: 1 - progress),
    );
  }
}
