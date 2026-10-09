// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Des cœurs qui flottent vers le haut depuis le bas de l'écran — comme
// les likes en direct sur une diffusion. Chaque cœur porte le pseudo de
// la personne qui a aimé le statut, et apparaît avec un léger délai
// décalé pour créer un effet de cascade naturel.
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../design_system/ouro_motion.dart';

/// Overlay de cœurs flottants pour les statuts — chaque cœur représente
/// un like reçu, avec le pseudo de l'auteur.
class FloatingHeartsOverlay extends StatefulWidget {
  const FloatingHeartsOverlay({
    super.key,
    required this.hearts,
  });

  /// Liste des pseudos qui ont aimé le statut.
  final List<String> hearts;

  @override
  State<FloatingHeartsOverlay> createState() => _FloatingHeartsOverlayState();
}

class _FloatingHeartsOverlayState extends State<FloatingHeartsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..bouclerSiAmbiant();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hearts.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          children: List.generate(widget.hearts.length, (i) {
            final pseudo = widget.hearts[i];
            // Chaque cœur a sa propre trajectoire décalée
            final delay = i * 0.35;
            final t = (_ctrl.value - delay) % 1.0;
            if (t < 0) return const SizedBox.shrink();

            final x = 30.0 + (i * 37.0) % (MediaQuery.of(context).size.width - 60);
            final startY = MediaQuery.of(context).size.height * 0.85;
            final endY = -60.0;
            final y = startY + (endY - startY) * t;

            final opacity = t < 0.1
                ? t / 0.1
                : t > 0.7
                    ? (1 - t) / 0.3
                    : 1.0;

            final scale = 0.7 + 0.3 * sin(t * pi);

            return Positioned(
              left: x + sin(t * pi * 2) * 15,
              bottom: -y,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D55).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('❤️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          pseudo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
