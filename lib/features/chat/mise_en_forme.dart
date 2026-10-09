// ============================================================================
// LA MISE EN FORME DU TEXTE — celle de Telegram, marqueur pour marqueur.
// ----------------------------------------------------------------------------
// Telegram écrit la mise en forme DANS le texte au moment où on la choisit
// (`**gras**`, `__italique__`, `` `code` ``, `||spoiler||`…) puis la traduit
// en « entités » avant l'envoi. Droplet garde les marqueurs tels quels : le
// message reste du texte, il traverse le mesh sans changer de format, et une
// version plus ancienne de l'app affiche au pire deux astérisques — jamais
// un message vide ou illisible.
//
// Les sept styles de Telegram, avec ses marqueurs :
//
//     **gras**   __italique__   ~~barré~~   ++souligné++
//     `code`     ```bloc```     ||spoiler||   [texte](lien)
//
// ── Ce qui se lit, et ce qui s'écrit ────────────────────────────────────
//
// LIRE un message mis en forme est gratuit, pour tout le monde. On ne va
// pas cacher le message de quelqu'un parce que le lecteur n'a pas payé.
// C'est ÉCRIRE la mise en forme qui appartient au pack (voir
// `BarreMiseEnForme`), comme chez Telegram où la traduction et la
// transcription sont réservées, mais où le résultat reste lisible par tous.
//
// ── Le spoiler ──────────────────────────────────────────────────────────
//
// Chez Telegram, le texte masqué est couvert d'une poussière animée qui
// se disperse quand on le touche. Ici la couverture est un voile de points
// qui scintillent, et l'appui la dissout — même principe, même geste.
// ============================================================================

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import '../navigateur/navigateur_integre.dart';

part 'controleur_mise_en_forme.dart';
part 'texte_mis_en_forme.dart';

/// Un style que l'on peut appliquer à une sélection.
enum Formatage { gras, italique, souligne, barre, code, bloc, spoiler, lien, mention }

/// Les mentions de la discussion ouverte.
///
/// Le texte d'un message ne dit pas qui est mentionnable : c'est l'écran de
/// discussion qui dépose ici les pseudos du groupe, le temps qu'il reste
/// ouvert. Sans cette liste, « @mr Edz » ne serait surligné que jusqu'à
/// l'espace — la moitié du nom.
class Mentions {
  Mentions._();

  static List<String> pseudos = const [];

  /// La mention qui s'adresse à tout le groupe.
  static const String tous = 'tous';

  /// Ce message me concerne-t-il personnellement ?
  static bool concerne(String texte, String monPseudo) {
    final bas = texte.toLowerCase();
    return bas.contains('@$tous') ||
        (monPseudo.isNotEmpty && bas.contains('@${monPseudo.toLowerCase()}'));
  }
}

/// Les marqueurs de chaque style : ce qui encadre le texte.
const Map<Formatage, (String, String)> kMarqueurs = {
  Formatage.gras: ('**', '**'),
  Formatage.italique: ('__', '__'),
  Formatage.souligne: ('++', '++'),
  Formatage.barre: ('~~', '~~'),
  Formatage.code: ('`', '`'),
  Formatage.bloc: ('```', '```'),
  Formatage.spoiler: ('||', '||'),
};

class MiseEnForme {
  MiseEnForme._();

  /// Applique [style] à la sélection de [valeur].
  ///
  /// Si la sélection porte DÉJÀ ce style, les marqueurs sont retirés :
  /// le même bouton met en gras et enlève le gras, comme partout ailleurs.
  /// Sans sélection, les marqueurs sont posés et le curseur placé entre
  /// les deux — on peut donc taper directement en gras.
  static TextEditingValue appliquer(TextEditingValue valeur, Formatage style) {
    final (ouvre, ferme) = kMarqueurs[style] ?? ('', '');
    final texte = valeur.text;
    var debut = valeur.selection.start;
    var fin = valeur.selection.end;
    if (debut < 0 || fin < 0) {
      debut = fin = texte.length;
    }

    // Déjà mis en forme ? On enlève.
    final avant = texte.substring(0, debut);
    final apres = texte.substring(fin);
    if (avant.endsWith(ouvre) && apres.startsWith(ferme)) {
      final nouveau = avant.substring(0, avant.length - ouvre.length) +
          texte.substring(debut, fin) +
          apres.substring(ferme.length);
      return TextEditingValue(
        text: nouveau,
        selection: TextSelection(
          baseOffset: debut - ouvre.length,
          extentOffset: fin - ouvre.length,
        ),
      );
    }

    final milieu = texte.substring(debut, fin);
    final nouveau = '$avant$ouvre$milieu$ferme$apres';
    return TextEditingValue(
      text: nouveau,
      selection: milieu.isEmpty
          ? TextSelection.collapsed(offset: debut + ouvre.length)
          : TextSelection(
              baseOffset: debut + ouvre.length,
              extentOffset: fin + ouvre.length,
            ),
    );
  }

  /// Pose un lien sur la sélection : `[texte](adresse)`.
  static TextEditingValue appliquerLien(TextEditingValue valeur, String adresse) {
    final texte = valeur.text;
    final debut = valeur.selection.start < 0 ? texte.length : valeur.selection.start;
    final fin = valeur.selection.end < 0 ? texte.length : valeur.selection.end;
    final milieu = texte.substring(debut, fin);
    final libelle = milieu.isEmpty ? adresse : milieu;
    final nouveau =
        '${texte.substring(0, debut)}[$libelle]($adresse)${texte.substring(fin)}';
    return TextEditingValue(
      text: nouveau,
      selection: TextSelection.collapsed(
        offset: debut + libelle.length + adresse.length + 4,
      ),
    );
  }

  /// Le même texte, mais dont seuls les [caracteres] premiers caractères
  /// VISIBLES sont gardés — marqueurs refermés.
  ///
  /// Sert aux démonstrations où l'on voit le message s'écrire : tronquer
  /// la chaîne brute laisserait apparaître des `**` orphelins, ce qui
  /// donnerait à lire exactement ce que la mise en forme doit cacher.
  static String partiel(String texte, int caracteres) {
    if (caracteres <= 0) return '';
    final tampon = StringBuffer();
    var restant = caracteres;
    for (final m in _analyser(texte)) {
      if (restant <= 0) break;
      final morceau =
          m.texte.length <= restant ? m.texte : m.texte.substring(0, restant);
      restant -= morceau.length;
      if (m.style == Formatage.lien) {
        tampon.write('[$morceau](${m.lien})');
      } else {
        final (ouvre, ferme) = kMarqueurs[m.style] ?? ('', '');
        tampon.write('$ouvre$morceau$ferme');
      }
    }
    return tampon.toString();
  }

  /// Le nombre de caractères visibles, marqueurs exclus.
  static int longueurVisible(String texte) => sansMarqueurs(texte).length;

  /// Vrai si [texte] porte au moins une marque de mise en forme.
  static bool contientDuStyle(String texte) => _regex.hasMatch(texte);

  /// Le texte débarrassé de ses marqueurs — pour les aperçus de la liste
  /// des discussions et les notifications, où l'on ne montre pas de style.
  static String sansMarqueurs(String texte) {
    final morceaux = _analyser(texte);
    final tampon = StringBuffer();
    for (final m in morceaux) {
      tampon.write(m.texte);
    }
    return tampon.toString();
  }

  // ── L'ANALYSE ─────────────────────────────────────────────────────
  //
  // Un seul passage, et le plus long marqueur d'abord (``` avant `, **
  // avant *) : sinon un bloc de code serait lu comme trois codes vides.
  static final RegExp _regex = RegExp(
    r'```([\s\S]+?)```'
    r'|`([^`\n]+?)`'
    r'|\*\*([\s\S]+?)\*\*'
    r'|__([\s\S]+?)__'
    r'|\+\+([\s\S]+?)\+\+'
    r'|~~([\s\S]+?)~~'
    r'|\|\|([\s\S]+?)\|\|'
    r'|\[([^\]\n]+?)\]\((\S+?)\)',
  );

  static final RegExp _motMention = RegExp(r'@([\p{L}\p{N}_.\-]{1,24})', unicode: true);

  /// L'analyse complète : la mise en forme d'abord, puis les mentions dans
  /// ce qui reste sans style (une mention à l'intérieur d'un bloc de code
  /// n'en est pas une).
  static List<_Morceau> _analyser(String texte) {
    final morceaux = <_Morceau>[];
    for (final m in _analyserBrut(texte)) {
      if (m.style != null) {
        morceaux.add(m);
      } else {
        morceaux.addAll(_detacherMentions(m.texte));
      }
    }
    return morceaux;
  }

  /// Découpe un texte sans style : on cherche le pseudo connu le PLUS LONG
  /// après une arobase, et à défaut un simple mot.
  static List<_Morceau> _detacherMentions(String texte) {
    if (!texte.contains('@')) return [_Morceau(texte, null)];
    final morceaux = <_Morceau>[];
    final tampon = StringBuffer();
    var i = 0;
    while (i < texte.length) {
      if (texte[i] != '@') {
        tampon.write(texte[i]);
        i++;
        continue;
      }
      final reste = texte.substring(i + 1);
      final bas = reste.toLowerCase();
      var nom = '';
      for (final pseudo in [Mentions.tous, ...Mentions.pseudos]) {
        if (pseudo.length > nom.length && bas.startsWith(pseudo.toLowerCase())) {
          nom = reste.substring(0, pseudo.length);
        }
      }
      if (nom.isEmpty) {
        final m = _motMention.matchAsPrefix(texte, i);
        if (m != null) nom = m.group(1)!;
      }
      if (nom.isEmpty) {
        tampon.write(texte[i]);
        i++;
        continue;
      }
      if (tampon.isNotEmpty) {
        morceaux.add(_Morceau(tampon.toString(), null));
        tampon.clear();
      }
      morceaux.add(_Morceau('@$nom', Formatage.mention));
      i += 1 + nom.length;
    }
    if (tampon.isNotEmpty) morceaux.add(_Morceau(tampon.toString(), null));
    return morceaux;
  }

  static List<_Morceau> _analyserBrut(String texte) {
    final morceaux = <_Morceau>[];
    var curseur = 0;
    for (final m in _regex.allMatches(texte)) {
      if (m.start > curseur) {
        morceaux.add(_Morceau(texte.substring(curseur, m.start), null));
      }
      if (m.group(1) != null) {
        morceaux.add(_Morceau(m.group(1)!, Formatage.bloc));
      } else if (m.group(2) != null) {
        morceaux.add(_Morceau(m.group(2)!, Formatage.code));
      } else if (m.group(3) != null) {
        morceaux.add(_Morceau(m.group(3)!, Formatage.gras));
      } else if (m.group(4) != null) {
        morceaux.add(_Morceau(m.group(4)!, Formatage.italique));
      } else if (m.group(5) != null) {
        morceaux.add(_Morceau(m.group(5)!, Formatage.souligne));
      } else if (m.group(6) != null) {
        morceaux.add(_Morceau(m.group(6)!, Formatage.barre));
      } else if (m.group(7) != null) {
        morceaux.add(_Morceau(m.group(7)!, Formatage.spoiler));
      } else if (m.group(8) != null) {
        morceaux.add(_Morceau(m.group(8)!, Formatage.lien, lien: m.group(9)));
      }
      curseur = m.end;
    }
    if (curseur < texte.length) {
      morceaux.add(_Morceau(texte.substring(curseur), null));
    }
    return morceaux;
  }

  /// Les fragments de texte prêts à être peints.
  ///
  /// [surLien] reçoit l'adresse touchée. [recouvrement] est la couleur du
  /// voile des spoilers (celle du texte, en pratique).
  static List<InlineSpan> enSpans(
    String texte, {
    required TextStyle style,
    void Function(String lien)? surLien,
    List<InlineSpan> Function(String morceau, TextStyle style)? brut,
  }) {
    final morceaux = _analyser(texte);
    final spans = <InlineSpan>[];
    for (final m in morceaux) {
      final styleMorceau = _style(m.style, style);
      switch (m.style) {
        case Formatage.spoiler:
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Spoiler(texte: m.texte, style: styleMorceau),
          ));
        case Formatage.lien:
          spans.add(TextSpan(
            text: m.texte,
            style: styleMorceau,
            recognizer: surLien == null
                ? null
                : (TapGestureRecognizer()..onTap = () => surLien(m.lien!)),
          ));
        case Formatage.bloc:
          spans.add(WidgetSpan(
            child: _BlocCode(texte: m.texte, style: styleMorceau),
          ));
        case null:
          // Le texte sans style peut encore contenir ce que l'écran veut
          // traiter lui-même (le surlignage d'une recherche, par exemple).
          if (brut != null) {
            spans.addAll(brut(m.texte, style));
          } else {
            spans.add(TextSpan(text: m.texte, style: style));
          }
        default:
          spans.add(TextSpan(text: m.texte, style: styleMorceau));
      }
    }
    return spans;
  }

  static TextStyle _style(Formatage? style, TextStyle base) => switch (style) {
        Formatage.gras => base.copyWith(fontWeight: FontWeight.w700),
        Formatage.italique => base.copyWith(fontStyle: FontStyle.italic),
        Formatage.souligne => base.copyWith(decoration: TextDecoration.underline),
        Formatage.barre => base.copyWith(decoration: TextDecoration.lineThrough),
        Formatage.code || Formatage.bloc => base.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Courier'],
            letterSpacing: 0,
          ),
        Formatage.lien => base.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: base.color?.withValues(alpha: 0.5),
          ),
        // Une mention se lit d'un coup d'œil dans un mur de messages : la
        // couleur d'accent et un peu de gras, sans soulignement (ce n'est
        // pas un lien).
        Formatage.mention => base.copyWith(
            color: OuroColors.accent,
            fontWeight: FontWeight.w600,
          ),
        _ => base,
      };
}

class _Morceau {
  const _Morceau(this.texte, this.style, {this.lien});

  final String texte;
  final Formatage? style;
  final String? lien;
}

/// Un texte masqué, découvert d'un appui.
class Spoiler extends StatefulWidget {
  const Spoiler({super.key, required this.texte, required this.style});

  final String texte;
  final TextStyle style;

  @override
  State<Spoiler> createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> with SingleTickerProviderStateMixin {
  bool _revele = false;
  late final AnimationController _scintillement = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..bouclerSiAmbiant();

  @override
  void dispose() {
    _scintillement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texte = Text(widget.texte, style: widget.style);
    return GestureDetector(
      // `opaque` : toute la surface du voile répond, y compris entre les
      // points de poussière. Sans lui, l'appui tombait dans les trous.
      behavior: HitTestBehavior.opaque,
      onTap: _revele
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() => _revele = true);
            },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _revele
            ? texte
            : Stack(
                key: const ValueKey('cache'),
                children: [
                  Opacity(opacity: 0, child: texte),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _scintillement,
                      builder: (context, _) => CustomPaint(
                        painter: _PoussiereSpoiler(
                          avance: _scintillement.value,
                          couleur: widget.style.color ?? OuroColors.label,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Le voile de points d'un spoiler : une poussière qui scintille.
class _PoussiereSpoiler extends CustomPainter {
  _PoussiereSpoiler({required this.avance, required this.couleur});

  final double avance;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    // Un fond très léger tient le bloc ensemble quand un point s'éteint.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()..color = couleur.withValues(alpha: 0.10),
    );
    final hasard = math.Random(7);
    final nombre = (size.width * size.height / 26).clamp(12, 420).toInt();
    final pinceau = Paint();
    for (var i = 0; i < nombre; i++) {
      final x = hasard.nextDouble() * size.width;
      final y = hasard.nextDouble() * size.height;
      final phase = hasard.nextDouble();
      final vie = ((avance + phase) % 1.0);
      // Chaque point s'allume puis s'éteint, chacun à son tour.
      final alpha = (math.sin(vie * math.pi) * 0.75).clamp(0.0, 1.0);
      pinceau.color = couleur.withValues(alpha: alpha * 0.85);
      canvas.drawCircle(Offset(x, y), 0.9, pinceau);
    }
  }

  @override
  bool shouldRepaint(_PoussiereSpoiler old) =>
      old.avance != avance || old.couleur != couleur;
}

/// Un bloc de code : fond discret, coins arrondis, texte à chasse fixe.
class _BlocCode extends StatelessWidget {
  const _BlocCode({required this.texte, required this.style});

  final String texte;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final couleur = style.color ?? OuroColors.label;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texte.trim(), style: style.copyWith(fontSize: (style.fontSize ?? 15) - 1)),
    );
  }
}
