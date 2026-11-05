// ============================================================================
// LE SYSTÈME DE SURFACES — six matières, du fond vers l'avant.
// ----------------------------------------------------------------------------
// Une interface « premium » ne tient pas à ses couleurs mais à ses PLANS :
// l'œil doit sentir ce qui est posé sur quoi. Droplet en a six, toujours
// les mêmes, du plus profond au plus proche :
//
//   1. LE FOND        — noir profond. Il ne porte rien, il fait reculer.
//   2. LA LUEUR       — en haut de l'écran, un rouge à peine là, qui se
//                       fond dans le noir. Elle donne une source de lumière
//                       à la page, sans jamais teinter une ligne.
//   3. LE VERRE       — la recherche : translucide, floutée, avec un liseré
//                       plus clair en haut (la lumière vient d'au-dessus).
//   4. LES PASTILLES  — les filtres : sombres et mates au repos ; la
//                       pastille choisie, elle, s'allume (couleur pleine,
//                       reflet en haut, halo très doux).
//   5. LA NAVIGATION  — verre dépoli (voir `ouro_glass.dart`).
//   6. LE FLOTTANT    — boutons et bandeaux posés au-dessus de tout : une
//                       ombre proche et nette + une ombre large et diffuse.
//                       Jamais plus : une ombre lourde fait « autocollant ».
//
// ⚠️ TOUT PASSE PAR ICI. Un écran qui invente sa propre ombre ou son propre
// gris casse la profondeur de tous les autres : c'est la cohérence entre
// écrans qui fait la qualité perçue, pas la beauté d'un écran isolé.
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'flou.dart';
import 'ouro_colors.dart';

class OuroSurfaces {
  OuroSurfaces._();

  static bool get _sombre => OuroColors.isDark;

  // ── 1. LE FOND ────────────────────────────────────────────────────────
  /// Noir profond en sombre (le même que `systemBackground`, pour que les
  /// lignes de conversation, opaques, se fondent dans la page sans
  /// laisser voir leur bord).
  static Color get fond => OuroColors.systemBackground;

  // ── 2. LA LUEUR ───────────────────────────────────────────────────────
  /// Le rouge de la lueur du haut — un rouge rosé, chaud, jamais sang.
  static const Color rougeLueur = Color(0xFFE8344E);

  /// Hauteur sur laquelle la lueur s'éteint.
  static const double hauteurLueur = 340;

  /// Le dégradé : trois arrêts, pour qu'il s'éteigne en douceur au lieu
  /// de dessiner une limite.
  static LinearGradient get lueur {
    final a = _sombre ? 0.17 : 0.075;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0, 0.45, 1],
      colors: [
        rougeLueur.withValues(alpha: a),
        rougeLueur.withValues(alpha: a * 0.35),
        rougeLueur.withValues(alpha: 0),
      ],
    );
  }

  // ── 3. LE VERRE ───────────────────────────────────────────────────────
  static Color get verre =>
      _sombre ? Colors.white.withValues(alpha: 0.075) : Colors.black.withValues(alpha: 0.045);

  /// Liseré du verre : plus clair en haut qu'en bas.
  static Color get lisereHaut =>
      _sombre ? Colors.white.withValues(alpha: 0.13) : Colors.white.withValues(alpha: 0.7);
  static Color get lisereBas =>
      _sombre ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.05);

  static const double flouVerre = 18;

  // ── 4. LES PASTILLES (filtres) ────────────────────────────────────────
  static Color get pastille =>
      _sombre ? Colors.white.withValues(alpha: 0.055) : Colors.black.withValues(alpha: 0.04);
  static Color get bordPastille =>
      _sombre ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05);

  /// La pastille choisie : la couleur de l'utilisateur, allumée — un reflet
  /// en haut (plus clair) et un halo de la même couleur, très doux.
  static Gradient pastilleActive(Color c) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(c, Colors.white, 0.16)!, c],
      );

  static List<BoxShadow> haloActif(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: _sombre ? 0.55 : 0.30),
          blurRadius: 18,
          spreadRadius: -2,
          offset: const Offset(0, 3),
        ),
      ];

  // ── 6. LE FLOTTANT ────────────────────────────────────────────────────
  /// Deux ombres, comme un objet réel : une proche qui le pose, une large
  /// qui le décolle. Très discrètes — on doit sentir la hauteur, pas voir
  /// l'ombre.
  static List<BoxShadow> get ombreFlottante => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _sombre ? 0.38 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _sombre ? 0.30 : 0.05),
          blurRadius: 24,
          spreadRadius: -6,
          offset: const Offset(0, 9),
        ),
      ];
}

/// Le fond d'un écran : le noir profond, et la lueur rouge en haut.
///
/// ⚠️ LA LUEUR NE TEINTE JAMAIS UNE LIGNE. Elle vit sous l'en-tête, la
/// recherche et les filtres ; les conversations gardent leur fond.
class FondAvecLueur extends StatelessWidget {
  const FondAvecLueur({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: OuroSurfaces.fond),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: OuroSurfaces.hauteurLueur,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: OuroSurfaces.lueur),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Une surface de verre : flou du fond, voile translucide, liseré éclairé
/// par le haut. En « effets allégés », `Flou` remplace le flou par un voile
/// plein (pas de saccade sur les petits téléphones).
class SurfaceVerre extends StatelessWidget {
  const SurfaceVerre({
    super.key,
    required this.child,
    this.rayon = 12,
    this.hauteur,
  });

  final Widget child;
  final double rayon;
  final double? hauteur;

  @override
  Widget build(BuildContext context) {
    final forme = BorderRadius.circular(rayon);
    return SizedBox(
      height: hauteur,
      child: ClipRRect(
        borderRadius: forme,
        child: Flou(
          filter: ui.ImageFilter.blur(
            sigmaX: OuroSurfaces.flouVerre,
            sigmaY: OuroSurfaces.flouVerre,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: OuroSurfaces.verre),
            // Un reflet en haut du verre : la lumière vient d'au-dessus.
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: OuroColors.isDark ? 0.035 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
              child: CustomPaint(
                foregroundPainter: _Lisere(rayon: rayon),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Le liseré du verre : un trait d'un demi-pixel, clair en haut, presque
/// éteint en bas.
class _Lisere extends CustomPainter {
  _Lisere({required this.rayon});

  final double rayon;

  @override
  void paint(Canvas canvas, Size taille) {
    final r = RRect.fromRectAndRadius(
      (Offset.zero & taille).deflate(0.5),
      Radius.circular(rayon),
    );
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [OuroSurfaces.lisereHaut, OuroSurfaces.lisereBas],
      ).createShader(Offset.zero & taille);
    canvas.drawRRect(r, pinceau);
  }

  @override
  bool shouldRepaint(_Lisere ancien) => ancien.rayon != rayon;
}
