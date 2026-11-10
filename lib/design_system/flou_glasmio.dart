// ============================================================================
// LE FLOU DE DÉFILEMENT DE GLASMIO, dans les écrans Flutter.
// ----------------------------------------------------------------------------
// Les écrans natifs Glasmio ont, sous leur barre du haut, un FLOU PROGRESSIF
// qui apparaît à mesure qu'on fait défiler : plein en haut, il s'éteint vers
// le bas de la barre, sans teinte ; et le contenu qui passe dessous s'estompe
// (25 % en haut, 100 % au bas de la barre).
//
// Les écrans Flutter ne peuvent pas utiliser le composant natif (le verre de
// Glasmio ne voit pas les pixels de Flutter). Ce fichier PORTE donc le même
// algorithme et les mêmes réglages que Glasmio 0.1.2 :
//   • `progressiveBlurBackdrop` : rayon maximal 10 dp, pleine intensité
//     jusqu'à 42 % de la hauteur, nulle en bas (shaders/
//     flou_progressif_glasmio.frag, flou gaussien séparable à rayon variable) ;
//   • hauteur : barre d'état + 62 dp, + 34 dp de fondu ;
//   • `scrollEdgeContentFade` : estompe 1 − 0,75 × progression → 1.
//
// Sans shaders de filtre (moteur Skia, vieux téléphones), un flou en bandes
// superposées donne une progression approchée.
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/services/device_profile.dart';

class FlouGlasmio {
  FlouGlasmio._();

  static ui.FragmentProgram? _programme;
  static Future<void>? _chargement;

  /// Charge le shader une fois (au démarrage, en tâche de fond).
  static Future<void> charger() => _chargement ??= ui.FragmentProgram.fromAsset('shaders/flou_progressif_glasmio.frag')
      .then((p) => _programme = p)
      .catchError((Object _) => null);

  /// Hauteur de la zone floutée : barre d'état + 62 dp + 34 dp de fondu.
  static double hauteur(double barreEtat) => barreEtat + 62 + 34;

  static bool get _shadersFiltres {
    try {
      return ui.ImageFilter.isShaderFilterSupported;
    } catch (_) {
      return false;
    }
  }

  static ui.ImageFilter? filtre(Size taille, double ratio) {
    final p = _programme;
    if (p == null || !_shadersFiltres) return null;
    ui.FragmentShader passe(double vertical) => p.fragmentShader()
      ..setFloat(0, taille.width * ratio)
      ..setFloat(1, taille.height * ratio)
      ..setFloat(2, vertical)
      ..setFloat(3, 10 * ratio)
      ..setFloat(4, 0.42)
      ..setFloat(5, 1.0);
    return ui.ImageFilter.compose(
      outer: ui.ImageFilter.shader(passe(1)),
      inner: ui.ImageFilter.shader(passe(0)),
    );
  }
}

/// Le flou progressif sous une barre du haut. [progression] : 0 au repos
/// (rien), 1 quand le contenu est passé sous la barre.
class FlouDefilementGlasmio extends StatelessWidget {
  const FlouDefilementGlasmio({super.key, required this.progression, this.hauteur});

  final double progression;
  final double? hauteur;

  @override
  Widget build(BuildContext context) {
    final p = progression.clamp(0.0, 1.0);
    if (p <= 0 || DeviceProfile.effetsAlleges.value) return const SizedBox.shrink();
    final h = hauteur ?? FlouGlasmio.hauteur(MediaQuery.paddingOf(context).top);
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return IgnorePointer(
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Opacity(
          opacity: p,
          child: LayoutBuilder(
            builder: (context, c) {
              final filtre = FlouGlasmio.filtre(Size(c.maxWidth, h), ratio);
              if (filtre != null) {
                return ClipRect(child: BackdropFilter(filter: filtre, child: const SizedBox.expand()));
              }
              // Repli : quatre bandes de flou qui se superposent en haut.
              return Stack(
                children: [
                  for (final f in const [1.0, 0.75, 0.55, 0.42])
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: h * f,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// L'estompe du contenu sous la barre (`scrollEdgeContentFade` de Glasmio).
class EstompeDefilementGlasmio extends StatelessWidget {
  const EstompeDefilementGlasmio({
    super.key,
    required this.progression,
    required this.haut,
    required this.bas,
    required this.child,
  });

  final double progression;

  /// Début (barre d'état) et fin (bas de la barre) de l'estompe.
  final double haut;
  final double bas;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ⚠️ TOUJOURS LE MÊME ARBRE, même à 0 : ôter puis remettre le masque
    // recréerait la liste en dessous et lui ferait perdre sa position.
    // Seul le mode « effets allégés » s'en passe (réglage de la session).
    if (DeviceProfile.effetsAlleges.value) return child;
    final p = progression.clamp(0.0, 1.0);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [(haut / r.height).clamp(0.0, 1.0), (bas / r.height).clamp(0.0, 1.0)],
        colors: [Colors.white.withValues(alpha: 1 - 0.75 * p), Colors.white],
      ).createShader(r),
      child: child,
    );
  }
}
