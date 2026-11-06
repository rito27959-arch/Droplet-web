// ============================================================================
// LE BOUTON « NOUVELLE DISCUSSION » — l'accès rapide aux contacts.
// ----------------------------------------------------------------------------
// WhatsApp met ce bouton en bas à droite, sous le pouce : c'est le geste le
// plus fréquent de l'écran, il doit être le plus facile à atteindre. Le
// « + » d'en haut reste pour le reste (groupe, invitation, assistant).
//
// Comment il reste élégant au lieu de gâcher l'écran :
//   • PETIT ET ROND : 54 points, pas une grosse pastille carrée ;
//   • LA MATIÈRE DES SURFACES : couleur d'accent avec un reflet en haut,
//     un liseré clair d'un demi-point, la double ombre flottante discrète ;
//   • IL S'EFFACE QUAND ON LIT : il glisse vers le bas et disparaît pendant
//     qu'on fait défiler la liste vers le bas, revient dès qu'on remonte —
//     et se cache aussi pendant la saisie au clavier ;
//   • IL RÉPOND AU DOIGT : il s'enfonce un peu sous la pression (ressort),
//     petit retour haptique ; un appui long ouvre le menu complet.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_surfaces.dart';

class BoutonNouvelleDiscussion extends StatefulWidget {
  const BoutonNouvelleDiscussion({
    super.key,
    required this.visible,
    required this.onTap,
    required this.etiquette,
    this.onLongPress,
  });

  /// Faux pendant un défilement vers le bas ou la saisie : il s'efface.
  final bool visible;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String etiquette;

  static const double taille = 54;

  @override
  State<BoutonNouvelleDiscussion> createState() => _BoutonNouvelleDiscussionState();
}

class _BoutonNouvelleDiscussionState extends State<BoutonNouvelleDiscussion> {
  bool _appuye = false;

  @override
  Widget build(BuildContext context) {
    final reduit = OuroMotion.of(context).reduceMotion;
    final accent = OuroColors.accentRempli;
    final duree = reduit ? Duration.zero : const Duration(milliseconds: 280);
    final rond = Container(
      width: BoutonNouvelleDiscussion.taille,
      height: BoutonNouvelleDiscussion.taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: OuroSurfaces.pastilleActive(accent),
        boxShadow: [
          ...OuroSurfaces.ombreFlottante,
          // Un soupçon de halo de sa couleur : il semble éclairé.
          BoxShadow(
            color: accent.withValues(alpha: OuroColors.isDark ? 0.28 : 0.18),
            blurRadius: 18,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 0.6),
      ),
      child: Icon(Icons.maps_ugc_rounded, color: OuroColors.texteSurAccent, size: 25),
    );

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedSlide(
        offset: widget.visible ? Offset.zero : const Offset(0, 0.6),
        duration: duree,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: widget.visible ? 1 : 0,
          duration: duree,
          child: AnimatedScale(
            scale: !widget.visible ? 0.85 : (_appuye ? 0.92 : 1),
            duration: reduit ? Duration.zero : const Duration(milliseconds: 180),
            curve: _appuye ? Curves.easeOut : Curves.elasticOut,
            child: Semantics(
              button: true,
              label: widget.etiquette,
              child: Tooltip(
                message: widget.etiquette,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _appuye = true),
                  onTapCancel: () => setState(() => _appuye = false),
                  onTapUp: (_) => setState(() => _appuye = false),
                  onTap: () {
                    OuroHaptics.light();
                    widget.onTap();
                  },
                  onLongPress: widget.onLongPress == null
                      ? null
                      : () {
                          setState(() => _appuye = false);
                          OuroHaptics.medium();
                          widget.onLongPress!();
                        },
                  child: rond,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
