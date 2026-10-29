// ============================================================================
// LE FLOU, SEULEMENT LÀ OÙ LE TÉLÉPHONE PEUT SE LE PERMETTRE.
// ----------------------------------------------------------------------------
// `BackdropFilter` est l'effet le plus cher de toute l'interface : à
// chaque image, le processeur graphique relit TOUT ce qui se trouve
// derrière la surface, le floute, puis le recompose. Pendant qu'une
// conversation défile sous la barre du haut et sous la barre de saisie,
// c'est deux flous pleine largeur, soixante fois par seconde.
//
// Un téléphone haut de gamme ne le remarque pas. Un téléphone d'entrée de
// gamme (Mali-G52, PowerVR, Adreno 6xx d'entrée…) y passe l'essentiel de
// son temps d'image : c'est LA cause des saccades au défilement que
// WhatsApp n'a pas — WhatsApp n'a pas de verre sur Android.
//
// `Flou` s'emploie exactement comme `BackdropFilter`. Quand l'appareil est
// en « effets allégés » (voir `DeviceProfile.effetsAlleges`), il ne floute
// plus rien : il pose à la place un fond plein et légèrement translucide
// SOUS le contenu — le même verre, dépoli d'avance, comme le réglage
// « Réduire la transparence » d'iOS. Les formes restent justes, parce
// que, comme le `BackdropFilter`, il vit sous le découpage de son parent
// (`ClipRRect`, `ClipOval`…).
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/services/device_profile.dart';
import 'ouro_colors.dart';

class Flou extends StatelessWidget {
  const Flou({
    super.key,
    required this.filter,
    this.child,
    this.blendMode = BlendMode.srcOver,
    this.enabled = true,
    this.repli,
  });

  final ui.ImageFilter filter;
  final Widget? child;
  final BlendMode blendMode;
  final bool enabled;

  /// Le fond posé à la place du flou, en effets allégés. Par défaut : le
  /// fond de l'écran à 55 %, qui s'ajoute à la teinte propre du verre.
  /// Les écrans toujours sombres (appel, visionneuse) passent un voile
  /// noir.
  final Color? repli;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DeviceProfile.effetsAlleges,
      child: child,
      builder: (context, alleges, enfant) {
        if (!alleges) {
          return BackdropFilter(
            filter: filter,
            blendMode: blendMode,
            enabled: enabled,
            child: enfant,
          );
        }
        final fond = repli ?? OuroColors.systemBackground.withValues(alpha: 0.55);
        return ColoredBox(color: fond, child: enfant ?? const SizedBox.expand());
      },
    );
  }
}
