// ============================================================================
// LE COMPTEUR QUI ROULE — celui de Telegram.
// ----------------------------------------------------------------------------
// Quand un nombre change (non-lus, vues…), seuls les chiffres qui changent
// bougent. L'ancien s'en va de 60 % de sa hauteur en rétrécissant à 30 % et
// en s'effaçant ; le nouveau arrive du côté opposé en grandissant. Un chiffre
// qui apparaît (9 → 10) grandit depuis 10 %, un chiffre qui disparaît
// rétrécit jusqu'à 10 %. Le tout en 0,2 s, courbe easeInOut.
//
// Ces valeurs sont celles du code source ouvert de Telegram iOS
// (AnimatedCountLabelNode.swift). Seules les VALEURS sont reprises : le code
// est écrit ici, le leur est sous licence GPL.
//
// Les chiffres sont alignés par la droite (le chiffre des unités roule, le
// nouveau chiffre des dizaines apparaît à gauche) et en chasse fixe, pour que
// la pastille ne tremble pas en largeur.
// ============================================================================

import 'package:flutter/material.dart';

class OuroCompteur extends StatefulWidget {
  const OuroCompteur({
    super.key,
    required this.valeur,
    required this.style,
    this.max,
  });

  final int valeur;
  final TextStyle style;

  /// Au-delà, on affiche « 99+ » (si `max` vaut 99).
  final int? max;

  @override
  State<OuroCompteur> createState() => _OuroCompteurState();
}

class _OuroCompteurState extends State<OuroCompteur>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  String _ancien = '';
  bool _monte = true;

  String _texte(int v) {
    final m = widget.max;
    return m != null && v > m ? '$m+' : '$v';
  }

  @override
  void didUpdateWidget(OuroCompteur ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.valeur != widget.valeur &&
        _texte(ancien.valeur) != _texte(widget.valeur)) {
      _ancien = _texte(ancien.valeur);
      _monte = widget.valeur > ancien.valeur;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nouveau = _texte(widget.valeur);
    final style = widget.style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Semantics(
      label: nouveau,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          if (!_ctrl.isAnimating || MediaQuery.disableAnimationsOf(context)) {
            return Text(nouveau, style: style);
          }
          final t = Curves.easeInOut.transform(_ctrl.value);
          final n = _ancien.length > nouveau.length ? _ancien.length : nouveau.length;
          final a = _ancien.padLeft(n);
          final b = nouveau.padLeft(n);
          final hauteur = (style.fontSize ?? 14) * (style.height ?? 1.2);
          // Quand le nombre monte, l'ancien chiffre part vers le haut et le
          // nouveau arrive d'en bas — comme un compteur mécanique.
          final decalage = hauteur * 0.6 * (_monte ? -1 : 1);
          return Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              for (var i = 0; i < n; i++) _case(a[i], b[i], t, decalage, style),
            ],
          );
        },
      ),
    );
  }

  Widget _case(String ancien, String nouveau, double t, double decalage, TextStyle style) {
    if (ancien == nouveau) {
      return ancien == ' ' ? const SizedBox.shrink() : Text(nouveau, style: style);
    }
    final apparait = ancien == ' ';
    final disparait = nouveau == ' ';
    return Align(
      // Un chiffre qui apparaît ou disparaît fait varier la largeur en douceur.
      widthFactor: apparait ? t : (disparait ? 1 - t : 1),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (!disparait)
            Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, apparait ? 0 : -decalage * (1 - t)),
                child: Transform.scale(
                  scale: apparait ? 0.1 + 0.9 * t : 0.3 + 0.7 * t,
                  child: Text(nouveau, style: style),
                ),
              ),
            ),
          if (!apparait)
            Opacity(
              opacity: 1 - t,
              child: Transform.translate(
                offset: Offset(0, disparait ? 0 : decalage * t),
                child: Transform.scale(
                  scale: disparait ? 1 - 0.9 * t : 1 - 0.7 * t,
                  child: Text(ancien, style: style),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
