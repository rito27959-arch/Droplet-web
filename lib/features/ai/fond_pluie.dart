// ============================================================================
// LA PLUIE SUR LA VITRE — le fond de l'accueil de l'assistant, en shader.
// ----------------------------------------------------------------------------
// Voir `shaders/pluie_vitre.frag` : une fenêtre embuée, un soir de pluie, la
// ville en lumières floues derrière, des gouttes qui glissent et laissent des
// traînées nettes. C'est le fond plein écran de l'accueil, choisi parmi six
// idées : il dit « Droplet » (la pluie EST la goutte) sans dessiner une
// goutte avec des yeux.
//
// Ce qui le fait vivre :
//   • le doigt essuie la buée là où il glisse (le Listener lit les
//     mouvements sans prendre les gestes : les boutons dessus marchent) ;
//   • quand on garde le doigt sur « Maintenez appuyé pour parler », la
//     vitre vibre avec la voix (état écoute, niveau du micro) ;
//   • pendant la transcription, la pluie redouble (réflexion).
//
// Repli sans shader (vieil appareil, effets allégés) : le ciel en dégradé,
// sans pluie. « Réduire les animations » : une image fixe.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/device_profile.dart';
import '../../design_system/ouro_colors.dart';
import 'orbe_droplet.dart' show EtatOrbe;

class FondPluie extends StatefulWidget {
  const FondPluie({super.key, this.etat = EtatOrbe.repos, this.niveau = 0, this.child});

  final EtatOrbe etat;
  final double niveau;

  /// Ce qui se pose par-dessus (l'accueil). Les gestes lui reviennent.
  final Widget? child;

  static Future<void> charger() => _chargement ??= ui.FragmentProgram.fromAsset('shaders/pluie_vitre.frag')
      .then((p) => _programme = p)
      .catchError((Object _) => null);

  static ui.FragmentProgram? _programme;
  static Future<void>? _chargement;

  @override
  State<FondPluie> createState() => _FondPluieState();
}

class _FondPluieState extends State<FondPluie> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tic);
  final ValueNotifier<double> _temps = ValueNotifier(20.0);
  Duration _dernier = Duration.zero;
  double _mode = 0;
  double _niveau = 0;

  /// Le doigt, en points logiques, et la force de l'essuyage (retombe seule
  /// en ~1,5 s quand le doigt quitte la vitre).
  Offset _doigt = const Offset(-9999, -9999);
  double _essuie = 0;
  bool _pose = false;

  @override
  void initState() {
    super.initState();
    if (FondPluie._programme == null) {
      FondPluie.charger().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _dernier = Duration.zero;
      _ticker.start();
    }
  }

  void _tic(Duration d) {
    final dt = _dernier == Duration.zero ? 0.016 : ((d - _dernier).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _dernier = d;
    _mode += (widget.etat.index - _mode) * (1 - math.exp(-dt * 6));
    final v = widget.niveau.clamp(0.0, 1.0);
    _niveau += (v - _niveau) * (1 - math.exp(-dt * (v > _niveau ? 16 : 5)));
    _essuie = _pose ? math.min(1, _essuie + dt * 8) : math.max(0, _essuie - dt * 0.7);
    _temps.value += dt;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _temps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programme = DeviceProfile.effetsAlleges.value ? null : FondPluie._programme;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _pose = true;
        _doigt = e.localPosition;
      },
      onPointerMove: (e) => _doigt = e.localPosition,
      onPointerUp: (_) => _pose = false,
      onPointerCancel: (_) => _pose = false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: programme == null
                  ? _PeintreRepli(OuroColors.isDark, OuroColors.accent)
                  : _PeintrePluie(this, programme, OuroColors.accent, OuroColors.isDark),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _PeintrePluie extends CustomPainter {
  _PeintrePluie(this.s, this.programme, this.couleur, this.sombre) : super(repaint: s._temps);

  final _FondPluieState s;
  final ui.FragmentProgram programme;
  final Color couleur;
  final bool sombre;

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final shader = programme.fragmentShader()
      ..setFloat(0, size.width * ratio)
      ..setFloat(1, size.height * ratio)
      ..setFloat(2, s._temps.value)
      ..setFloat(3, s._niveau)
      ..setFloat(4, s._mode)
      ..setFloat(5, couleur.r)
      ..setFloat(6, couleur.g)
      ..setFloat(7, couleur.b)
      ..setFloat(8, sombre ? 1 : 0)
      ..setFloat(9, s._doigt.dx * ratio)
      ..setFloat(10, s._doigt.dy * ratio)
      ..setFloat(11, s._essuie);
    canvas.save();
    canvas.scale(1 / ratio);
    canvas.drawRect(Offset.zero & (size * ratio), Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintrePluie old) => old.couleur != couleur || old.sombre != sombre || old.programme != programme;
}

/// Sans shader : le ciel du soir (ou de la nuit), sans pluie.
class _PeintreRepli extends CustomPainter {
  _PeintreRepli(this.sombre, this.couleur);

  final bool sombre;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sombre
              ? [const Color(0xFF05080F), Color.lerp(const Color(0xFF0F1220), couleur, 0.12)!]
              : [const Color(0xFF94A3BC), Color.lerp(const Color(0xFFCCCCD6), couleur, 0.10)!],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(_PeintreRepli old) => old.sombre != sombre || old.couleur != couleur;
}
