// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA CÉLÉBRATION DE LA FIN DE L'ACCUEIL — « Bienvenue, Awa ».
//
// Le seul moment de fête de tout l'accueil, et il ne dure qu'une seconde
// et demie : deux ronds dans l'eau partent de l'avatar, et une douzaine
// de gouttes de la marque en jaillissent, retombent et s'évanouissent —
// la goutte de l'ouverture, qui a trouvé sa place, éclabousse.
//
// Les récits, eux, sont dessinés par `scene_presentation.dart`.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';
import '../../shared/widgets/marque_droplet.dart';

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Un rond dans l'eau : un cercle qui s'élargit en s'effaçant.
void _rond(Canvas canvas, Offset c, double r0, double r1, double p, Color couleur, {double epaisseur = 2, double alpha = 0.5}) {
  if (p <= 0 || p >= 1) return;
  final r = r0 + (r1 - r0) * Curves.easeOutCubic.transform(p);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur * (1 - 0.5 * p)
      ..color = couleur.withValues(alpha: couleur.a * alpha * math.pow(1 - p, 1.4).toDouble()),
  );
}

// ── LA FIN : vous êtes prêt ──────────────────────────────────────────

/// Deux ronds dans l'eau et une gerbe de gouttes autour de l'avatar, une
/// seule fois : le compte vient de naître.
class OndesArrivee extends StatefulWidget {
  const OndesArrivee({super.key, required this.rayon});

  final double rayon;

  @override
  State<OndesArrivee> createState() => _OndesArriveeState();
}

class _OndesArriveeState extends State<OndesArrivee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
      _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _PeintreOndes(_c.value, widget.rayon, OuroColors.accent)),
      ),
    );
  }
}

class _PeintreOndes extends CustomPainter {
  _PeintreOndes(this.t, this.r, this.couleur);
  final double t, r;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final loin = math.min(size.width, size.height) / 2;
    _rond(canvas, c, r, loin, _seg(t, 0.05, 0.75), couleur, epaisseur: 2, alpha: 0.5);
    _rond(canvas, c, r, loin, _seg(t, 0.3, 1.0), couleur, epaisseur: 2, alpha: 0.35);

    // Les gouttes qui jaillissent : chacune part du bord de l'avatar, vole
    // vers l'extérieur en ralentissant, la pointe tournée vers d'où elle
    // vient, retombe un peu (la pesanteur), rapetisse et s'efface.
    final vol = _seg(t, 0.08, 0.95);
    if (vol <= 0 || vol >= 1) return;
    for (var k = 0; k < 12; k++) {
      // Un désordre fixe : mêmes angles et mêmes élans à chaque fois.
      final hasard = math.sin(k * 12.9898) * 43758.5453;
      final x = hasard - hasard.floorToDouble();
      final angle = -math.pi / 2 + k * 2 * math.pi / 12 + (x - 0.5) * 0.42;
      final elan = r * (0.95 + 0.75 * x);
      final dir = Offset(math.cos(angle), math.sin(angle));
      final q = Curves.easeOutCubic.transform(vol);
      final pos = c + dir * (r + 6 + elan * q) + Offset(0, r * 0.55 * vol * vol);
      final taille = (7.0 + 6 * x) * (1 - 0.55 * vol);
      final alpha = 1 - Curves.easeIn.transform(_seg(vol, 0.45, 1));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle - math.pi / 2);
      canvas.scale(taille / 0.565);
      canvas.translate(0, -0.0095);
      final teinte = k.isEven ? couleur : Color.lerp(couleur, Colors.white, 0.35)!;
      canvas.drawPath(
        GeometrieMarque.goutte,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(-0.12, -0.2),
            const Offset(0.16, 0.29),
            [teinte.withValues(alpha: alpha), teinte.withValues(alpha: alpha * 0.8)],
          ),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PeintreOndes o) => o.t != t;
}
