// ============================================================================
// L'ORBE DE DROPLET — la présence de l'assistant, en shader.
// ----------------------------------------------------------------------------
// Une sphère de verre remplie d'un liquide de lumière (voir
// `shaders/orbe_droplet.frag`). Elle remplace la mascotte à l'accueil, pense
// à côté de la réponse qui s'écrit, et écoute puis parle en direct.
//
//   OrbeDroplet(taille: 120)                                   // accueil
//   OrbeDroplet(taille: 28, etat: EtatOrbe.reflexion)          // réponse
//   OrbeDroplet(taille: 200, etat: EtatOrbe.ecoute, niveau: v) // en direct
//
// Les changements d'état GLISSENT (le shader reçoit un `uMode` flottant
// lissé ici), la voix aussi : rien ne saute d'une image à l'autre.
//
// Repli : si le shader ne se charge pas (vieil appareil, effets allégés),
// une sphère en dégradé radial qui respire — moins riche, jamais vide.
// « Réduire les animations » : l'orbe s'arrête sur une image.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/device_profile.dart';
import '../../design_system/ouro_colors.dart';

enum EtatOrbe { repos, ecoute, reflexion, parole }

class OrbeDroplet extends StatefulWidget {
  const OrbeDroplet({super.key, this.taille = 120, this.etat = EtatOrbe.repos, this.niveau = 0});

  final double taille;
  final EtatOrbe etat;

  /// La voix, de 0 à 1 (le micro en écoute, la synthèse en parole).
  final double niveau;

  /// Charge le shader une fois, en tâche de fond (appelé au premier
  /// affichage ; on peut l'appeler plus tôt pour gagner une image).
  static Future<void> charger() => _chargement ??= ui.FragmentProgram.fromAsset('shaders/orbe_droplet.frag')
      .then((p) => _programme = p)
      .catchError((Object _) => null);

  static ui.FragmentProgram? _programme;
  static Future<void>? _chargement;

  @override
  State<OrbeDroplet> createState() => _OrbeDropletState();
}

class _OrbeDropletState extends State<OrbeDroplet> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tic);
  final ValueNotifier<double> _temps = ValueNotifier(2.0);
  Duration _dernier = Duration.zero;
  double _mode = 0;
  double _niveau = 0;
  bool _fige = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.etat.index.toDouble();
    if (OrbeDroplet._programme == null) {
      OrbeDroplet.charger().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fige = MediaQuery.disableAnimationsOf(context);
    if (_fige) {
      _ticker.stop();
      _mode = widget.etat.index.toDouble();
      _temps.value = 2.0;
    } else if (!_ticker.isActive) {
      _dernier = Duration.zero;
      _ticker.start();
    }
  }

  void _tic(Duration d) {
    final dt = _dernier == Duration.zero ? 0.016 : ((d - _dernier).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _dernier = d;
    // Le mode glisse en ~0,4 s, la voix suit vite à la montée et retombe
    // plus doucement (comme un vumètre).
    final cible = widget.etat.index.toDouble();
    _mode += (cible - _mode) * (1 - math.exp(-dt * 7));
    var v = widget.niveau.clamp(0.0, 1.0);
    // En parole sans niveau mesuré (la synthèse du téléphone ne le donne
    // pas) : une enveloppe de voix plausible, syllabes et respirations.
    if (widget.etat == EtatOrbe.parole && v <= 0) {
      final t = _temps.value;
      v = (0.25 + 0.55 * (math.sin(t * 7.3) * math.sin(t * 2.1)).abs() + 0.15 * math.sin(t * 13.0)).clamp(0.0, 1.0);
    }
    _niveau += (v - _niveau) * (1 - math.exp(-dt * (v > _niveau ? 18 : 6)));
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
    final programme = DeviceProfile.effetsAlleges.value ? null : OrbeDroplet._programme;
    final c = OuroColors.accent;
    return Semantics(
      image: true,
      label: 'Droplet',
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.taille,
          child: CustomPaint(
            painter: programme == null
                ? _PeintreRepli(this, c)
                : _PeintreOrbe(this, programme, c, OuroColors.isDark),
          ),
        ),
      ),
    );
  }
}

class _PeintreOrbe extends CustomPainter {
  _PeintreOrbe(this.s, this.programme, this.couleur, this.sombre) : super(repaint: s._temps);

  final _OrbeDropletState s;
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
      ..setFloat(8, sombre ? 1 : 0);
    // Le shader travaille en pixels physiques : on dessine à l'échelle
    // inverse pour que FlutterFragCoord tombe juste.
    canvas.save();
    canvas.scale(1 / ratio);
    canvas.drawRect(Offset.zero & (size * ratio), Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreOrbe old) => old.couleur != couleur || old.sombre != sombre || old.programme != programme;
}

/// Sans shader : une sphère en dégradé qui respire et gonfle avec la voix.
class _PeintreRepli extends CustomPainter {
  _PeintreRepli(this.s, this.couleur) : super(repaint: s._temps);

  final _OrbeDropletState s;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final t = s._temps.value;
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.31 * (1 + 0.02 * math.sin(t * 1.6) + 0.08 * s._niveau);
    canvas.drawCircle(
      c,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(colors: [couleur.withValues(alpha: 0.35), couleur.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: r * 1.6)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [Color.lerp(couleur, Colors.white, 0.55)!, couleur, Color.lerp(couleur, Colors.black, 0.45)!],
          stops: const [0, 0.5, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_PeintreRepli old) => old.couleur != couleur;
}
