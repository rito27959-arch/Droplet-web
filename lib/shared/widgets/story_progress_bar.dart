// ============================================================================
// LES BARRES DE PROGRESSION D'UN STATUT — celles de WhatsApp sur iPhone.
// ----------------------------------------------------------------------------
// Fines (2,5 pt), arrondies, espacées de 4 pt, la piste à 35 % de blanc. Une
// ombre très légère les garde lisibles sur une photo claire — sans elle, une
// barre blanche disparaît sur un ciel ou une feuille de papier.
// ============================================================================

import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.progress,
    this.activeColor = Colors.white,
    this.trackColor = const Color(0x59FFFFFF),
  });

  final int count;
  final int currentIndex;
  final double progress;
  final Color activeColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final double value = i < currentIndex
            ? 1.0
            : (i == currentIndex ? progress.clamp(0.0, 1.0).toDouble() : 0.0);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 2.5,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 3),
              ],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
