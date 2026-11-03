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
// « Réduire les animations » : la grappe est figée sur sa plus belle image.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

/// La grappe d'autocollants d'un état vide, animée.
class AutocollantsVides extends StatefulWidget {
  const AutocollantsVides({super.key, required this.scene, this.largeur = 200, this.tempsFixe});

  final SceneVide scene;
  final double largeur;

  /// Pour les tests de rendu : un instant imposé, en secondes.
  @visibleForTesting
  final double? tempsFixe;

  @override
  State<AutocollantsVides> createState() => _AutocollantsVidesState();
}

class _AutocollantsVidesState extends State<AutocollantsVides> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((d) => _temps.value = d.inMicroseconds / 1e6);
  final ValueNotifier<double> _temps = ValueNotifier(0.8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.tempsFixe != null) {
      _temps.value = widget.tempsFixe!;
    } else if (reduit) {
      _ticker.stop();
      _temps.value = 0.8;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _temps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(widget.largeur, widget.largeur * _kHaut),
          painter: _PeintreGrappe(
            grappe: _grappes[widget.scene]!,
            temps: _temps,
            accent: OuroColors.accent,
            sombre: sombre,
          ),
        ),
      ),
    );
  }
}

class _PeintreGrappe extends CustomPainter {
  _PeintreGrappe({required this.grappe, required this.temps, required this.accent, required this.sombre})
      : super(repaint: temps);

  final _Grappe grappe;
  final ValueNotifier<double> temps;
  final Color accent;
  final bool sombre;

  // L'encre des contours : un presque-noir, comme les autocollants de
  // WhatsApp, dans les deux modes (sur fond sombre, elle se fond dans
  // l'ombre et c'est le liseré clair des formes qui découpe).
  static const Color _encre = Color(0xFF111418);

  Color _ton(int t) => switch (t) {
        0 => accent,
        1 => Color.lerp(accent, Colors.white, 0.45)!,
        _ => Color.lerp(accent, Colors.white, 0.84)!,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final t = temps.value;
    final u = size.width;
    canvas.save();

    // Derrière : les ondes, les pointillés.
    for (final e in grappe.extras) {
      if (e == _Extra.ondes) _ondes(canvas, u, t);
      if (e == _Extra.pointilles) _pointilles(canvas, u, t);
    }

    // L'avion passe DERRIÈRE la grappe sur la moitié de sa boucle.
    final avion = grappe.extras.contains(_Extra.avion);
    if (avion) _avion(canvas, u, t, derriere: true);

    for (final p in grappe.pieces) {
      _piece(canvas, u, p, t);
    }

    if (grappe.extras.contains(_Extra.goutteRelais)) _goutteRelais(canvas, u, t);
    if (avion) _avion(canvas, u, t, derriere: false);
    canvas.restore();
  }

  // ── Une pièce ─────────────────────────────────────────────────────

  void _piece(Canvas canvas, double u, _Piece p, double t) {
    final s = t + p.phase;
    var dy = 0.0, angle = 0.0, echelle = 1.0;
    switch (p.jeu) {
      case _Jeu.flotte:
        dy = math.sin(s * 2.1) * 0.012;
      case _Jeu.salue:
        // Trois balancements, puis une pause : un geste, pas une vibration.
        final c = (s % 2.6) / 2.6;
        angle = c < 0.5 ? 0.22 * math.sin(c / 0.5 * 3 * 2 * math.pi) * (1 - c / 0.5 * 0.4) : 0;
      case _Jeu.pulse:
        echelle = 1 + 0.06 * math.pow(math.sin(s * 2.4).abs(), 3).toDouble();
      case _Jeu.tourne:
        angle = s * 0.9;
      case _Jeu.sonne:
        final c = (s % 2.2) / 2.2;
        angle = c < 0.35 ? 0.16 * math.sin(c / 0.35 * 5 * 2 * math.pi) : 0;
      case _Jeu.aucun:
        break;
    }
    final centre = Offset(p.centre.dx * u, (p.centre.dy + dy) * u);
    final r = p.taille * u;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(echelle);
    final chemin = _chemin(p.forme, r);
    final trait = math.max(1.6, u * 0.0105);
    // L'ombre décalée, puis la forme, puis le contour.
    canvas.drawPath(chemin.shift(Offset(trait * 1.2, trait * 1.4)), Paint()..color = _encre);
    canvas.drawPath(chemin, Paint()..color = _ton(p.ton));
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trait
        ..strokeJoin = StrokeJoin.round
        ..color = _encre,
    );
    // Le picto, qui seul tourne ou salue (la pastille reste posée).
    canvas.rotate(angle);
    final decale = p.forme == _Forme.rond ? Offset.zero : Offset(0, -r * 0.08);
    if (p.goutte) {
      _goutte(canvas, r * 1.15, decale);
    } else if (p.icone != null) {
      _icone(canvas, p.icone!, r * 1.05, decale, p.ton == 0 ? Colors.white : _encre);
    }
    canvas.restore();
  }

  Path _chemin(_Forme f, double r) {
    switch (f) {
      case _Forme.rond:
        return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
      case _Forme.bulleGauche:
      case _Forme.bulleDroite:
        // Une bulle de discussion ronde, queue en bas du côté extérieur.
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

  void _icone(Canvas canvas, IconData icone, double taille, Offset decale, Color couleur) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icone.codePoint),
        style: TextStyle(
          fontFamily: icone.fontFamily,
          package: icone.fontPackage,
          fontSize: taille,
          height: 1,
          color: couleur,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, decale - Offset(tp.width / 2, tp.height / 2));
    tp.dispose();
  }

  void _goutte(Canvas canvas, double taille, Offset decale) {
    canvas.save();
    canvas.translate(decale.dx, decale.dy + taille * 0.02);
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

  // ── Les extras ────────────────────────────────────────────────────

  /// L'avion en papier : une boucle de 3,2 s qui entre par le bas à gauche,
  /// passe derrière la grappe, en ressort en haut et file à droite, avec
  /// son fil blanc. Puis une courte pause.
  void _avion(Canvas canvas, double u, double t, {required bool derriere}) {
    const periode = 3.4;
    final c = (t % periode) / periode;
    if (c > 0.82) return;
    final q = c / 0.82;
    Offset pos(double q) {
      // Une courbe en boucle, définie par morceaux de Bézier.
      final a = const Offset(0.06, 0.6), b = const Offset(-0.02, 0.18), cc = const Offset(0.3, 0.02), d = const Offset(0.62, 0.0);
      final e = const Offset(0.86, -0.03), f = const Offset(1.1, -0.2);
      if (q < 0.55) {
        final k = q / 0.55, v = 1 - k;
        return a * (v * v * v) + b * (3 * v * v * k) + cc * (3 * v * k * k) + d * (k * k * k);
      }
      final k = (q - 0.55) / 0.45, v = 1 - k;
      return d * (v * v) + e * (2 * v * k) + f * (k * k);
    }

    // Derrière la grappe tant qu'il monte dans son ombre, devant ensuite.
    final devant = q > 0.35;
    if (derriere == devant) return;

    // Le fil : les 40 % de trajet précédents, qui s'effacent.
    final fil = Path();
    const pas = 26;
    for (var k = 0; k <= pas; k++) {
      final qq = (q - 0.4 + 0.4 * k / pas).clamp(0.0, 1.0);
      final p = pos(qq) * u;
      if (k == 0) {
        fil.moveTo(p.dx, p.dy);
      } else {
        fil.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      fil,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, u * 0.007)
        ..strokeCap = StrokeCap.round
        ..color = (sombre ? Colors.white : _encre).withValues(alpha: 0.85),
    );

    final p = pos(q) * u;
    final p2 = pos(math.min(1, q + 0.01)) * u;
    final cap = math.atan2(p2.dy - p.dy, p2.dx - p.dx);
    final e = u * 0.075;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(cap);
    final aile = Path()
      ..moveTo(e, 0)
      ..lineTo(-e * 0.7, -e * 0.62)
      ..lineTo(-e * 0.35, 0)
      ..lineTo(-e * 0.7, e * 0.62)
      ..close();
    canvas.drawPath(aile, Paint()..color = Colors.white);
    canvas.drawPath(
      aile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, u * 0.008)
        ..strokeJoin = StrokeJoin.round
        ..color = _encre,
    );
    canvas.drawLine(Offset(e, 0), Offset(-e * 0.35, 0), Paint()..strokeWidth = math.max(1, u * 0.006)..color = _encre);
    canvas.restore();
  }

  /// Des ondes qui partent de la pièce centrale (appels, réseau, carte).
  void _ondes(Canvas canvas, double u, double t) {
    final centre = grappe.pieces.firstWhere((p) => p.ton == 0).centre * u;
    final r0 = grappe.pieces.firstWhere((p) => p.ton == 0).taille * u;
    for (var k = 0; k < 2; k++) {
      final c = ((t / 2.4) + k * 0.5) % 1.0;
      canvas.drawCircle(
        centre,
        r0 + c * u * 0.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, u * 0.008) * (1 - c * 0.5)
          ..color = accent.withValues(alpha: 0.5 * math.pow(1 - c, 1.5).toDouble()),
      );
    }
  }

  /// Un anneau pointillé qui tourne autour de la pièce centrale (statuts).
  void _pointilles(Canvas canvas, double u, double t) {
    final p = grappe.pieces.firstWhere((p) => p.ton == 0);
    final centre = p.centre * u;
    final r = p.taille * u * 1.32;
    const n = 18;
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, u * 0.011)
      ..strokeCap = StrokeCap.round
      ..color = accent;
    for (var k = 0; k < n; k++) {
      final a = t * 0.5 + k * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: centre, radius: r), a, 2 * math.pi / n * 0.55, false, pinceau);
    }
  }

  /// Une goutte qui saute d'un téléphone à l'autre (réseau).
  void _goutteRelais(Canvas canvas, double u, double t) {
    final g = grappe.pieces.first.centre * u;
    final d = grappe.pieces.last.centre * u;
    final c = (t % 1.8) / 1.8;
    final aller = ((t ~/ 1.8) % 2) == 0;
    final q = Curves.easeInOutSine.transform(c);
    final de = aller ? g : d, vers = aller ? d : g;
    final pos = Offset.lerp(de, vers, q)! - Offset(0, math.sin(math.pi * q) * u * 0.26);
    final h = u * 0.06;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(h / 0.565);
    canvas.drawPath(GeometrieMarque.goutte, Paint()..color = accent);
    canvas.drawPath(GeometrieMarque.goutte, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.035..color = _encre);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreGrappe o) => o.grappe != grappe || o.accent != accent || o.sombre != sombre;
}
