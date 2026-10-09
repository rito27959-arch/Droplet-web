// ============================================================================
// LE BOUTON-ICÔNE D'iOS — celui des barres de navigation.
// ----------------------------------------------------------------------------
// Sur iPhone, un bouton-icône ne fait ni cercle gris ni ondulation : il
// s'estompe sous le doigt (40 % d'opacité, sans délai) et revient en 0,2 s au
// lâcher, comme UIKit et Telegram. Un tap très bref laisse quand même ce
// petit éclair, sinon l'appui ne se voit pas. La cible fait 44 pt, le minimum
// d'Apple, même quand l'icône est plus petite.
//
// Il remplace `IconButton` dans toute l'app avec les mêmes paramètres :
//   • `style` est lu pour sa couleur de fond, sa forme et sa couleur d'icône ;
//   • `visualDensity` resserre la cible, comme le faisait Material ;
//   • `tooltip` devient l'étiquette VoiceOver — les bulles d'aide au survol
//     n'existent pas sur iPhone.
// ============================================================================

import 'package:flutter/material.dart';

class OuroIconButton extends StatefulWidget {
  const OuroIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.style,
    this.visualDensity,
    this.iconSize,
    this.color,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final ButtonStyle? style;
  final VisualDensity? visualDensity;
  final double? iconSize;
  final Color? color;

  @override
  State<OuroIconButton> createState() => _OuroIconButtonState();
}

class _OuroIconButtonState extends State<OuroIconButton> {
  bool _appui = false;

  void _poser(bool valeur) {
    if (_appui != valeur && mounted) setState(() => _appui = valeur);
  }

  void _lacher() {
    _poser(true);
    Future.delayed(const Duration(milliseconds: 60), () => _poser(false));
  }

  @override
  Widget build(BuildContext context) {
    final actif = widget.onPressed != null;
    const etats = <WidgetState>{};
    final fond = widget.style?.backgroundColor?.resolve(etats);
    final premierPlan =
        widget.style?.foregroundColor?.resolve(etats) ?? widget.color;
    final forme = widget.style?.shape?.resolve(etats);
    final densite = widget.visualDensity ?? VisualDensity.standard;
    final cote = (44 + 4 * densite.horizontal).clamp(32.0, 44.0).toDouble();

    Widget icone = IconTheme.merge(
      data: IconThemeData(color: premierPlan, size: widget.iconSize),
      child: widget.icon,
    );
    if (fond != null) {
      icone = DecoratedBox(
        decoration: ShapeDecoration(
          color: fond,
          shape: forme ?? const CircleBorder(),
        ),
        child: SizedBox(
          width: cote - 4,
          height: cote - 4,
          child: Center(child: icone),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: actif,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: actif ? (_) => _poser(true) : null,
        onTapUp: actif ? (_) => _lacher() : null,
        onTapCancel: actif ? () => _poser(false) : null,
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          opacity: !actif ? 0.35 : (_appui ? 0.4 : 1.0),
          // Sans délai à l'appui, 0,2 s au lâcher.
          duration: _appui ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: SizedBox(
            width: cote,
            height: cote,
            child: Center(child: icone),
          ),
        ),
      ),
    );
  }
}
