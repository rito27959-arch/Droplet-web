// ============================================================================
// LA MASCOTTE DE L'ASSISTANT — une goutte de verre bleu qui vit.
// ----------------------------------------------------------------------------
// L'accueil de l'assistant suit la grammaire de Kimi : une petite créature
// au centre, qui flotte, regarde à gauche puis à droite, cligne des yeux —
// l'écran a l'air habité avant même qu'on écrive.
//
// La créature est à Droplet, pas une copie : une GOUTTE (pointe en haut),
// en verre bleu de la couleur d'accent, avec deux yeux blancs ronds et leurs
// pupilles qui se déplacent. Un appui la fait rebondir et cligner.
//
// Tout est calculé à partir d'une seule horloge (un `Ticker`) : rien ne
// s'accumule. « Réduire les animations » → la goutte reste immobile, les
// yeux au centre.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';

class MascotteAssistant extends StatefulWidget {
  const MascotteAssistant({super.key, this.taille = 96});

  final double taille;

  @override
  State<MascotteAssistant> createState() => _MascotteAssistantState();
}

class _MascotteAssistantState extends State<MascotteAssistant> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((d) => _temps.value = d.inMicroseconds / 1e6);
  final ValueNotifier<double> _temps = ValueNotifier(0);
  double _rebond = -10;
  bool _fige = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fige = MediaQuery.disableAnimationsOf(context);
    if (_fige) {
      _ticker.stop();
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
    final t = widget.taille;
    return Semantics(
      image: true,
      label: 'Droplet',
      child: GestureDetector(
        onTap: () {
          if (_fige) return;
          OuroHaptics.light();
          _rebond = _temps.value;
        },
        child: SizedBox(
          width: t,
          height: t * 1.25,
          child: CustomPaint(
            painter: _PeintreMascotte(
              temps: _temps,
              rebond: () => _rebond,
              accent: OuroColors.accent,
              sombre: OuroColors.isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeintreMascotte extends CustomPainter {
  _PeintreMascotte({required this.temps, required this.rebond, required this.accent, required this.sombre})
      : super(repaint: temps);

  final ValueNotifier<double> temps;
  final double Function() rebond;
  final Color accent;
  final bool sombre;

  /// Où regardent les yeux (−1 gauche, +1 droite) : un cycle de 7 s —
  /// au centre, à gauche, au centre, à droite — avec des glissements doux.
  static double _regard(double t) {
    const cles = [(0.0, 0.0), (1.4, 0.0), (1.8, -1.0), (3.0, -1.0), (3.4, 0.0), (4.6, 0.0), (5.0, 1.0), (6.2, 1.0), (6.6, 0.0), (7.0, 0.0)];
    final x = t % 7.0;
    for (var i = 1; i < cles.length; i++) {
      final (t1, v1) = cles[i];
      final (t0, v0) = cles[i - 1];
      if (x <= t1) {
        final f = ((x - t0) / (t1 - t0)).clamp(0.0, 1.0);
        final g = f * f * (3 - 2 * f);
        return v0 + (v1 - v0) * g;
      }
    }
    return 0;
  }

  /// L'ouverture des paupières (1 ouvert, ~0 fermé) : un clignement toutes
  /// les 3,6 s, parfois double, et un au rebond.
  static double _paupiere(double t, double depuisRebond) {
    double clin(double x) => x < 0 || x > 0.16 ? 1 : 1 - math.sin(x / 0.16 * math.pi) * 0.92;
    final x = t % 3.6;
    var o = clin(x - 3.3);
    if ((t / 3.6).floor() % 3 == 2) o = math.min(o, clin(x - 3.5 + 0.2));
    if (depuisRebond >= 0) o = math.min(o, clin(depuisRebond - 0.05));
    return o;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = temps.value;
    final dr = t - rebond();
    final rebondit = dr >= 0 && dr < 1.0;
    final amorti = rebondit ? math.sin(dr * 16) * math.exp(-dr * 5) : 0.0;

    final w = size.width;
    final cx = w / 2;
    final flotte = math.sin(t * 1.6) * w * 0.035 - (rebondit ? math.max(0.0, amorti) * w * 0.12 : 0);
    final r = w * 0.40;
    final cy = size.height * 0.60 + flotte;

    // L'ombre au sol, qui rétrécit quand la goutte monte.
    final ombreL = r * 1.5 * (1 - flotte.abs() / (w * 0.5));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height * 0.60 + r + w * 0.07), width: ombreL, height: r * 0.22),
      Paint()
        ..color = accent.withValues(alpha: sombre ? 0.28 : 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.04),
    );

    canvas.save();
    canvas.translate(cx, cy);
    // Respiration, et l'écrasement du rebond.
    final souffle = 1 + math.sin(t * 2.1) * 0.012;
    canvas.scale(souffle * (1 + amorti * 0.10), souffle * (1 - amorti * 0.10));

    // La goutte : un cercle prolongé d'une pointe en haut.
    final corps = Path()
      ..moveTo(0, -r * 1.55)
      ..cubicTo(r * 0.28, -r * 1.12, r, -r * 0.55, r, 0)
      ..arcToPoint(Offset(-r, 0), radius: Radius.circular(r))
      ..cubicTo(-r, -r * 0.55, -r * 0.28, -r * 1.12, 0, -r * 1.55)
      ..close();
    final cadre = Rect.fromLTRB(-r, -r * 1.55, r, r);
    final clair = Color.lerp(accent, Colors.white, 0.45)!;
    final fonce = Color.lerp(accent, Colors.black, 0.30)!;
    canvas.drawPath(
      corps,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.15),
          radius: 0.95,
          colors: [clair, accent, fonce],
          stops: const [0, 0.55, 1],
        ).createShader(cadre),
    );
    // Le liseré et les reflets du verre.
    canvas.drawPath(
      corps,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = Colors.white.withValues(alpha: 0.30),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r * 0.52, -r * 0.30), width: r * 0.22, height: r * 0.48),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawCircle(Offset(-r * 0.30, -r * 0.82), r * 0.07, Paint()..color = Colors.white.withValues(alpha: 0.55));

    // Les yeux : deux ronds blancs, et des pupilles qui regardent.
    final regard = _regard(t);
    final ouverture = _paupiere(t, rebondit ? dr : -1);
    final ecart = r * 0.36, oy = r * 0.05, rayonOeil = r * 0.20;
    for (final s in [-1.0, 1.0]) {
      final centre = Offset(s * ecart + regard * r * 0.06, oy);
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.scale(1, ouverture.clamp(0.08, 1.0));
      canvas.drawCircle(Offset.zero, rayonOeil, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(regard * rayonOeil * 0.42, rayonOeil * 0.10),
        rayonOeil * 0.52,
        Paint()..color = const Color(0xFF0B2545),
      );
      canvas.drawCircle(
        Offset(regard * rayonOeil * 0.42 - rayonOeil * 0.18, -rayonOeil * 0.12),
        rayonOeil * 0.16,
        Paint()..color = Colors.white,
      );
      canvas.restore();
    }
    // Les joues.
    final joue = Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: sombre ? 0.35 : 0.45);
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s * r * 0.62 + regard * r * 0.04, r * 0.32), width: r * 0.24, height: r * 0.13),
        joue,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreMascotte old) => old.accent != accent || old.sombre != sombre;
}

/// Une phrase qui s'écrit lettre après lettre, avec un curseur qui
/// clignote pendant l'écriture puis s'efface. Une seule fois.
class PhraseProgressive extends StatefulWidget {
  const PhraseProgressive({super.key, required this.texte, required this.style, this.delai = Duration.zero});

  final String texte;
  final TextStyle style;
  final Duration delai;

  @override
  State<PhraseProgressive> createState() => _PhraseProgressiveState();
}

class _PhraseProgressiveState extends State<PhraseProgressive> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // ~38 ms par caractère, entre 0,9 et 2,2 s.
    duration: Duration(milliseconds: (widget.texte.characters.length * 38).clamp(900, 2200)),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delai, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lettres = widget.texte.characters.toList();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final n = (Curves.easeOut.transform(_c.value) * lettres.length).round();
        final ecrit = lettres.take(n).join();
        final fini = _c.isCompleted;
        // Le reste du texte est là, invisible : la hauteur ne saute pas
        // pendant l'écriture, et le centrage reste juste.
        return Semantics(
          label: widget.texte,
          child: ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: ecrit),
                  if (!fini)
                    TextSpan(
                      text: '|',
                      style: TextStyle(color: OuroColors.accent, fontWeight: FontWeight.w300),
                    ),
                  TextSpan(text: lettres.skip(n).join(), style: const TextStyle(color: Colors.transparent)),
                ],
              ),
              textAlign: TextAlign.center,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}
