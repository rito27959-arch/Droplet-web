// ============================================================================
// LE DÉGRADÉ DU PACK, ET SON BOUTON.
// ----------------------------------------------------------------------------
// Telegram ne vend pas Premium avec une liste à puces : il en fait une
// vitrine (`PremiumPreviewFragment`, `PremiumFeatureCell`), et le fil qui
// la tient est UN SEUL LONG DÉGRADÉ DÉCOUPÉ. Chaque ligne prend sa teinte
// à sa place dans la liste, si bien que l'ensemble se lit comme une seule
// pièce — et ça ne coûte rien à dessiner.
//
// ⚠️ CE FICHIER CONTENAIT AUSSI UN SECOND CATALOGUE DE FONCTIONS, avec sa
// propre liste et sa propre feuille d'aperçu. L'écran Pro affichait donc
// DEUX FOIS les mêmes six fonctions, sous deux noms différents. Tout ça a
// été fondu dans `avantages_pro.dart`, seul catalogue désormais. Ne
// restent ici que les deux pièces vraiment partagées : le dégradé et le
// bouton d'achat.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';

/// Le dégradé de Telegram, du violet au orange, parcouru par la liste.
const List<Color> kDegradePremium = [
  Color(0xFF6C51FF),
  Color(0xFF8E4FFF),
  Color(0xFFB44BF0),
  Color(0xFFE151B0),
  Color(0xFFF2586B),
  Color(0xFFF97C3C),
  Color(0xFFFFA932),
];

/// La couleur d'une ligne, selon sa place : la liste parcourt le dégradé.
Color couleurFonction(int index, int total) {
  if (total <= 1) return kDegradePremium.first;
  final t = index / (total - 1) * (kDegradePremium.length - 1);
  final i = t.floor().clamp(0, kDegradePremium.length - 2);
  return Color.lerp(kDegradePremium[i], kDegradePremium[i + 1], t - i)!;
}

/// Le bouton du pack : dégradé animé et reflet qui passe, comme celui de
/// Telegram (`PremiumButtonView`).
class BoutonPremium extends StatefulWidget {
  const BoutonPremium({super.key, required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  State<BoutonPremium> createState() => _BoutonPremiumState();
}

class _BoutonPremiumState extends State<BoutonPremium>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reflet = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _reflet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        OuroHaptics.medium();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _reflet,
        builder: (context, _) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C51FF), Color(0xFFE151B0), Color(0xFFFFA932)],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Le reflet traverse le bouton, puis attend : c'est
                // l'attente qui l'empêche de devenir une enseigne.
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: 0.3,
                    alignment: Alignment(
                      -1.6 + 3.2 * Curves.easeInOut.transform(
                        ((_reflet.value - 0.55) / 0.45).clamp(0.0, 1.0),
                      ),
                      0,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.libelle,
                  style: OuroTypography.headline.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
