// ============================================================================
// L'AVION EN PAPIER DE DROPLET WEB (Flame).
// ----------------------------------------------------------------------------
// Le cousin de celui de l'app mobile (`avion_envoi.dart`), taillé pour le
// bureau : le message envoyé part du bouton d'envoi plié en avion, monte en
// arc en s'inclinant dans son virage, laisse un fil pointillé qui s'efface,
// puis se pose sur la nouvelle bulle et s'y éparpille en étincelles.
//
// ⚠️ CHARGÉ À LA DEMANDE. Ce fichier (et Flame avec lui) est importé en
// `deferred` par `lanceur_avion.dart` : il ne pèse rien au premier
// chargement de la page, seulement au premier avion.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/widgets.dart' show Curves, IgnorePointer, Widget;

/// Durée du vol, en secondes.
const double kDureeVol = 0.95;

class JeuAvionWeb extends FlameGame {
  JeuAvionWeb({
    required this.depart,
    required this.arrivee,
    required this.accent,
    required this.sombre,
    required this.surFin,
  });

  final Offset depart;
  final Offset arrivee;
  final Color accent;
  final bool sombre;
  final VoidCallback surFin;

  double t = 0;
  bool _eclate = false;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    add(_Fil(priority: 0));
    add(_Avion(priority: 1));
  }

  /// Le point de la trajectoire à l'instant [q] (0 → 1) : un arc qui monte
  /// d'abord, puis redescend se poser.
  Offset pos(double q) {
    final haut = math.min(depart.dy, arrivee.dy) - 120;
    final c1 = Offset(depart.dx - 40, haut);
    final c2 = Offset(arrivee.dx + 30, haut - 30);
    final v = 1 - q;
    return depart * (v * v * v) + c1 * (3 * v * v * q) + c2 * (3 * v * q * q) + arrivee * (q * q * q);
  }

  double get q => Curves.easeInOutCubic.transform((t / kDureeVol).clamp(0.0, 1.0));

  @override
  void update(double dt) {
    t += math.min(dt, 1 / 30);
    super.update(dt);
    if (!_eclate && t >= kDureeVol) {
      _eclate = true;
      _etincelles();
    }
    if (t >= kDureeVol + 0.65) {
      pauseEngine();
      surFin();
    }
  }

  void _etincelles() {
    final hasard = math.Random();
    add(ParticleSystemComponent(
      priority: 2,
      position: Vector2(arrivee.dx, arrivee.dy),
      particle: Particle.generate(
        count: 12,
        lifespan: 0.6,
        generator: (i) {
          final a = i / 12 * 2 * math.pi + hasard.nextDouble() * 0.4;
          final v = 70 + hasard.nextDouble() * 70;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v),
            acceleration: Vector2(0, 120),
            child: _Etoile(couleur: i.isEven ? accent : (sombre ? const Color(0xFFFFFFFF) : Color.lerp(accent, const Color(0xFFFFFFFF), 0.5)!)),
          );
        },
      ),
    ));
  }
}

/// Le fil pointillé derrière l'avion, qui s'efface par la queue.
class _Fil extends Component with HasGameReference<JeuAvionWeb> {
  _Fil({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final q = j.q;
    final fondu = j.t > kDureeVol ? (1 - (j.t - kDureeVol) / 0.4).clamp(0.0, 1.0) : 1.0;
    if (fondu <= 0) return;
    final pinceau = Paint()..strokeCap = StrokeCap.round;
    const n = 26;
    for (var k = 0; k < n; k++) {
      final qq = q * k / n;
      if (q - qq > 0.55) continue;
      final p = j.pos(qq);
      final a = (1 - (q - qq) / 0.55) * 0.55 * fondu;
      pinceau.color = (j.sombre ? const Color(0xFFFFFFFF) : j.accent).withValues(alpha: a);
      canvas.drawCircle(p, 1.6, pinceau);
    }
  }
}

/// L'avion : se déplie au départ, s'incline dans son virage, se replie en
/// se posant.
class _Avion extends Component with HasGameReference<JeuAvionWeb> {
  _Avion({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    if (j.t > kDureeVol) return;
    final q = j.q;
    final p = j.pos(q);
    final p2 = j.pos(math.min(1, q + 0.02));
    final p0 = j.pos(math.max(0, q - 0.02));
    final cap = math.atan2(p2.dy - p0.dy, p2.dx - p0.dx);
    final avant = math.atan2(p.dy - p0.dy, p.dx - p0.dx);
    final virage = ((cap - avant) * 10).clamp(-0.6, 0.6);
    // Déplié au départ (0 → 1 en 0,15 s), replié à l'arrivée.
    final ouverture = Curves.easeOutBack.transform((j.t / 0.15).clamp(0.0, 1.0)) *
        (1 - Curves.easeIn.transform(((q - 0.85) / 0.15).clamp(0.0, 1.0)) * 0.6);
    final e = 21.0 * ouverture;
    if (e <= 0) return;

    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(cap);
    canvas.scale(1, 1 - virage.abs() * 0.55);
    // L'ombre portée, légère : l'avion vole AU-DESSUS de la page.
    canvas.drawPath(
      _corps(e).shift(const Offset(2, 5)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    final aileHaute = Path()
      ..moveTo(e, 0)
      ..lineTo(-e * 0.75, -e * 0.66)
      ..lineTo(-e * 0.32, 0)
      ..close();
    final aileBasse = Path()
      ..moveTo(e, 0)
      ..lineTo(-e * 0.32, 0)
      ..lineTo(-e * 0.75, e * 0.66)
      ..close();
    canvas.drawPath(aileHaute, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(aileBasse, Paint()..color = Color.lerp(const Color(0xFFFFFFFF), j.accent, 0.22)!);
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..color = j.accent;
    canvas.drawPath(aileHaute, contour);
    canvas.drawPath(aileBasse, contour);
    canvas.restore();
  }

  Path _corps(double e) => Path()
    ..moveTo(e, 0)
    ..lineTo(-e * 0.75, -e * 0.66)
    ..lineTo(-e * 0.32, 0)
    ..lineTo(-e * 0.75, e * 0.66)
    ..close();
}

class _Etoile extends Particle {
  _Etoile({required this.couleur}) : super(lifespan: 0.6);
  final Color couleur;

  @override
  void render(Canvas canvas) {
    final r = 3.4 * (1 - progress * 0.7);
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 1.7)
        ..lineTo(r * 0.35, -r * 0.35)
        ..lineTo(r * 1.7, 0)
        ..lineTo(r * 0.35, r * 0.35)
        ..lineTo(0, r * 1.7)
        ..lineTo(-r * 0.35, r * 0.35)
        ..lineTo(-r * 1.7, 0)
        ..lineTo(-r * 0.35, -r * 0.35)
        ..close(),
      Paint()..color = couleur.withValues(alpha: 1 - progress),
    );
  }
}

/// Le widget de la scène, prêt à poser dans un `OverlayEntry`.
///
/// (Une fonction plutôt que le type lui-même : un type chargé en
/// `deferred` ne peut pas servir d'annotation chez l'appelant.)
Widget sceneAvion({
  required Offset depart,
  required Offset arrivee,
  required Color accent,
  required bool sombre,
  required VoidCallback surFin,
}) =>
    IgnorePointer(
      child: GameWidget<JeuAvionWeb>(
        game: JeuAvionWeb(depart: depart, arrivee: arrivee, accent: accent, sombre: sombre, surFin: surFin),
      ),
    );
