// LE TEXTE D'UNE BULLE — la mise en forme de l'app, et les liens.
//
//   *gras*   _italique_   ~barré~   ```code```   (comme l'app et WhatsApp)
//   https://… et www.… deviennent des liens qui s'ouvrent dans un onglet.
//
// Le mot cherché dans la discussion ressort sur fond jaune, comme dans
// Safari.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../design_system/ouro_typography.dart';
import '../web/navigateur.dart';

final RegExp _lien = RegExp(r'((https?://|www\.)[^\s<>"]+[^\s<>".,;:!?)\]])', caseSensitive: false);
final RegExp _forme = RegExp(r'```([\s\S]+?)```|(?<![\w*])\*([^*\n]+)\*(?![\w*])|(?<![\w/])_([^_\n]+)_(?![\w])|(?<![\w~])~([^~\n]+)~(?![\w~])');
final RegExp _emojis = RegExp(
  r'^(?:\p{Extended_Pictographic}|\p{Emoji_Modifier}|\p{Regional_Indicator}|‍|️|\s)+$',
  unicode: true,
);

/// Vrai pour un message fait de 1 à 3 émojis : affiché en grand, sans
/// bulle, comme iMessage.
bool seulementEmojis(String texte) {
  final t = texte.trim();
  if (t.isEmpty || !_emojis.hasMatch(t)) return false;
  return t.characters.where((c) => c.trim().isNotEmpty).length <= 3;
}

List<InlineSpan> texteRiche(
  String texte, {
  required TextStyle style,
  required Color couleurLien,
  String? surligne,
  Color? fondSurligne,
}) {
  final spans = <InlineSpan>[];
  var i = 0;
  for (final m in _forme.allMatches(texte)) {
    if (m.start > i) spans.addAll(_liens(texte.substring(i, m.start), style, couleurLien, surligne, fondSurligne));
    if (m.group(1) != null) {
      spans.addAll(_liens(m.group(1)!, style.copyWith(fontFamily: 'monospace', fontFamilyFallback: const ['Menlo', 'Consolas', 'monospace']), couleurLien, surligne, fondSurligne));
    } else if (m.group(2) != null) {
      spans.addAll(_liens(m.group(2)!, style.copyWith(fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700)]), couleurLien, surligne, fondSurligne));
    } else if (m.group(3) != null) {
      spans.addAll(_liens(m.group(3)!, style.copyWith(fontStyle: FontStyle.italic), couleurLien, surligne, fondSurligne));
    } else {
      spans.addAll(_liens(m.group(4)!, style.copyWith(decoration: TextDecoration.lineThrough), couleurLien, surligne, fondSurligne));
    }
    i = m.end;
  }
  if (i < texte.length) spans.addAll(_liens(texte.substring(i), style, couleurLien, surligne, fondSurligne));
  return spans;
}

List<InlineSpan> _liens(String texte, TextStyle style, Color couleur, String? surligne, Color? fond) {
  final spans = <InlineSpan>[];
  var i = 0;
  for (final m in _lien.allMatches(texte)) {
    if (m.start > i) spans.addAll(_surligner(texte.substring(i, m.start), style, surligne, fond));
    final adresse = m.group(0)!;
    spans.add(TextSpan(
      text: adresse,
      style: style.copyWith(color: couleur, decoration: TextDecoration.underline, decorationColor: couleur),
      mouseCursor: SystemMouseCursors.click,
      recognizer: TapGestureRecognizer()
        ..onTap = () => Navigateur.ouvrir(adresse.startsWith('http') ? adresse : 'https://$adresse'),
    ));
    i = m.end;
  }
  if (i < texte.length) spans.addAll(_surligner(texte.substring(i), style, surligne, fond));
  return spans;
}

List<InlineSpan> _surligner(String texte, TextStyle style, String? q, Color? fond) {
  if (q == null || q.isEmpty) return [TextSpan(text: texte, style: style)];
  final spans = <InlineSpan>[];
  final bas = texte.toLowerCase();
  var i = 0;
  while (true) {
    final j = bas.indexOf(q, i);
    if (j < 0) break;
    if (j > i) spans.add(TextSpan(text: texte.substring(i, j), style: style));
    spans.add(TextSpan(
      text: texte.substring(j, j + q.length),
      style: style.copyWith(backgroundColor: fond ?? const Color(0xFFFFD60A), color: const Color(0xFF000000)),
    ));
    i = j + q.length;
  }
  if (i < texte.length) spans.add(TextSpan(text: texte.substring(i), style: style));
  return spans;
}

/// La taille du texte des émojis seuls : 1 → très grand, 3 → grand.
double tailleEmojis(String texte) {
  final n = texte.trim().characters.where((c) => c.trim().isNotEmpty).length;
  return switch (n) { 1 => 54, 2 => 44, _ => 36 };
}

TextStyle styleEmojis(String texte) => OuroTypography.body.copyWith(fontSize: tailleEmojis(texte), height: 1.15);
