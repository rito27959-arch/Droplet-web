// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA COUCHE VISUELLE DE NEXUS — remplace `nexus_shader.dart` (fragment
// shader GLSL compilé sur GPU) et `nexus_particles.dart` (80 particules
// floutées, deux `MaskFilter.blur` chacune, à 60 images/seconde).
//
// ── POURQUOI CE REMPLACEMENT ────────────────────────────────────────────
//
// Les deux fichiers remplacés faisaient planter le téléphone sur le
// terrain, malgré plusieurs rounds de correctifs défensifs déjà tentés
// (détection d'appareil via `DeviceProfile.sansShader`, filet de
// sécurité `onShaderIndisponible`, `tryParse` contre les seeds
// malformées…). Le problème n'était pas un bug isolé à corriger : c'est
// la COMBINAISON d'un shader fragment plein écran (compilation GLSL au
// premier lancement — point de défaillance connu sur les pilotes GPU
// Android bas et moyen de gamme) ET d'un système de particules qui
// dessinait jusqu'à 160 cercles floutés par image, PAR-DESSUS ce
// shader, pendant les huit secondes de la séquence. Sur un appareil
// modeste, c'est assez pour geler le rendu ou faire planter le
// pipeline graphique — un échec qu'aucun correctif Dart ne peut
// prévenir, puisqu'il se produit dans le pilote GPU lui-même.
//
// Ce fichier fait tout le travail visuel avec des primitives Canvas
// ordinaires (cercles, dégradés radiaux natifs Flutter — PAS de
// `FragmentProgram`, PAS de `MaskFilter.blur` en boucle) : le genre de
// dessin que Skia/Impeller exécute des millions de fois par jour dans
// n'importe quelle app Flutter, sans surprise possible. L'effet visuel
// s'inspire du « radar AirDrop » d'iOS : des anneaux qui pulsent vers
// l'extérieur depuis un point central, et deux points lumineux (les
// deux appareils) qui convergent l'un vers l'autre puis se rejoignent.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'nexus_event.dart';

/// Peint la séquence Nexus : anneaux pulsés façon radar + deux points
/// lumineux qui convergent, façon AirDrop.
///
/// Coût par image : quelques `drawCircle` et un dégradé radial — rien
/// qui ne s'exécute déjà des milliers de fois par seconde dans
/// n'importe quelle app Flutter.
class NexusPulsePainter extends CustomPainter {
  NexusPulsePainter({
    required this.phase,
    required this.phaseProgress,
    required this.overallProgress,
    required this.colorSignature,
    required this.intensity,
    required this.time,
    required this.seed,
  });

  final NexusPhase phase;
  final double phaseProgress;
  final double overallProgress;
  final int colorSignature;
  final double intensity;

  /// Horloge de la séquence, en secondes — voir
  /// `NexusControllerState.elapsedSeconds`. Jamais `DateTime.now()` :
  /// les deux appareils doivent voir la même chose au même moment.
  final double time;

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final color = Color(colorSignature);

    _paintGlow(canvas, center, size, color);
    _paintRadarRings(canvas, center, size, color);
    _paintConvergingDevices(canvas, center, size, color);
  }

  /// Lueur douce derrière tout le reste — un dégradé radial NATIF
  /// Flutter (`RadialGradient.createShader`), pas un fragment shader
  /// personnalisé : c'est un `Shader` que Skia/Impeller savent produire
  /// sans jamais compiler la moindre ligne de GLSL.
  void _paintGlow(Canvas canvas, Offset center, Size size, Color color) {
    final radius = size.shortestSide * 0.45;
    final glow = RadialGradient(
      colors: [
        color.withValues(alpha: 0.22 * intensity),
        color.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, Paint()..shader = glow);
  }

  /// Anneaux qui pulsent vers l'extérieur en boucle, façon écran de
  /// recherche AirDrop — trois anneaux décalés dans le temps pour un
  /// mouvement continu plutôt que saccadé.
  void _paintRadarRings(Canvas canvas, Offset center, Size size, Color color) {
    // Visible dès la naissance de la goutte, jusqu'à la fin de la
    // synchronisation — pas pendant l'éveil (rien à montrer encore) ni
    // pendant l'identité (place faite au réseau mesh de
    // `_IdentityContent`).
    final visible = phase == NexusPhase.dropletBirth ||
        phase == NexusPhase.connectionWave ||
        phase == NexusPhase.dualSync;
    if (!visible) return;

    final maxRadius = size.shortestSide * 0.38;
    const ringCount = 3;
    for (var i = 0; i < ringCount; i++) {
      final ringPhase = (time * 0.45 + i / ringCount) % 1.0;
      final radius = ringPhase * maxRadius;
      if (radius <= 1) continue;
      final opacity = (1.0 - ringPhase) * intensity * 0.5;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  /// Deux points lumineux — « mon appareil » et « le sien » — qui
  /// glissent l'un vers l'autre pendant la naissance et la connexion,
  /// puis se rejoignent au centre pendant la synchronisation. C'est le
  /// même langage visuel que le radar AirDrop d'iOS au moment où deux
  /// appareils se trouvent.
  void _paintConvergingDevices(
    Canvas canvas,
    Offset center,
    Size size,
    Color color,
  ) {
    if (phase == NexusPhase.idle || phase == NexusPhase.awakening) return;

    // Progression de la convergence : 0 = écartés, 1 = réunis au
    // centre. Traverse `dropletBirth` puis `connectionWave` ; déjà
    // réunis dès `dualSync`.
    final double convergence;
    switch (phase) {
      case NexusPhase.dropletBirth:
        convergence = Curves.easeOut.transform(phaseProgress) * 0.5;
      case NexusPhase.connectionWave:
        convergence = 0.5 + Curves.easeOut.transform(phaseProgress) * 0.5;
      default:
        convergence = 1.0;
    }

    final spread = size.shortestSide * 0.22 * (1.0 - convergence);
    final wobble = math.sin(time * 3.0) * 2.0 * (1.0 - convergence);
    final left = center.translate(-spread, wobble);
    final right = center.translate(spread, -wobble);

    final dotPaint = Paint()..color = color.withValues(alpha: intensity);
    // Une fois réunis, un seul point brillant plutôt que deux points
    // superposés — plus net que de laisser deux disques identiques se
    // chevaucher exactement.
    if (convergence > 0.96) {
      canvas.drawCircle(center, 5.0 * intensity, dotPaint);
      // Petit éclat au moment précis de la rencontre.
      final burst = (1.0 - (convergence - 0.96) / 0.04).clamp(0.0, 1.0);
      if (burst > 0) {
        canvas.drawCircle(
          center,
          14.0 * burst,
          Paint()..color = Colors.white.withValues(alpha: burst * 0.6 * intensity),
        );
      }
    } else {
      canvas.drawCircle(left, 4.0 * intensity, dotPaint);
      canvas.drawCircle(right, 4.0 * intensity, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NexusPulsePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.intensity != intensity ||
        oldDelegate.phase != phase ||
        oldDelegate.phaseProgress != phaseProgress ||
        oldDelegate.colorSignature != colorSignature;
  }
}
