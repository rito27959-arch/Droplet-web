// ============================================================================
// LA RÉPONSE D'UNE IA, MISE EN PAGE COMME CHEZ ChatGPT, Claude ET Gemini.
// ----------------------------------------------------------------------------
// Un modèle de langage écrit en Markdown : `**gras**`, `# Titre`, `- liste`,
// ```code```, `| tableau |`. Affiché tel quel, ça donne un mur d'astérisques
// et de dièses. Les grandes apps d'IA ne montrent JAMAIS ces signes : elles
// les transforment en mise en page. C'est ce que fait ce fichier, sans
// dépendance : titres, paragraphes, gras, italique, barré, code en ligne,
// blocs de code (avec leur langage et un bouton Copier), listes à puces,
// numérotées et à cocher (imbriquées), citations, séparateurs, tableaux et
// liens.
//
// ⚠️ LA RÉPONSE ARRIVE PAR MORCEAUX. L'analyse est refaite à chaque jeton et
// tolère l'inachevé : un bloc de code ouvert et pas encore fermé s'affiche
// déjà comme du code, au lieu de montrer trois accents graves.
// ============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../navigateur/navigateur_integre.dart';

class RenduMarkdown extends StatefulWidget {
  const RenduMarkdown({super.key, required this.texte, required this.style});

  final String texte;

  /// Le style du corps de texte ; les titres, le code et les citations en
  /// dérivent.
  final TextStyle style;

  @override
  State<RenduMarkdown> createState() => _RenduMarkdownState();
}

/// ⚠️ CE WIDGET ÉTAIT SANS ÉTAT, ET C'ÉTAIT UNE FUITE.
///
/// Chaque lien fabriquait un `TapGestureRecognizer` dans `build`, et
/// personne ne le libérait jamais. Sur un écran ordinaire ça passerait
/// inaperçu ; ici la réponse du modèle ARRIVE JETON PAR JETON, donc
/// `build` est rappelé des centaines de fois par message. Autant de
/// reconnaisseurs abandonnés, pour une réponse qui contient deux liens.
///
/// Ils sont désormais gardés dans un cache indexé par adresse — même lien,
/// même reconnaisseur — et libérés à la fermeture.
class _RenduMarkdownState extends State<RenduMarkdown> {
  final Map<String, TapGestureRecognizer> _liens = {};

  TapGestureRecognizer _reconnaisseur(String adresse) {
    return _liens.putIfAbsent(
      adresse,
      () => TapGestureRecognizer()
        ..onTap = () => ouvrirLienDansApp(context, adresse),
    );
  }

  @override
  void dispose() {
    for (final r in _liens.values) {
      r.dispose();
    }
    super.dispose();
  }

  String get texte => widget.texte;
  TextStyle get style => widget.style;

  @override
  Widget build(BuildContext context) {
    final blocs = _analyser(texte);
    final enfants = <Widget>[];
    for (var i = 0; i < blocs.length; i++) {
      final bloc = blocs[i];
      final espace = i == 0 ? 0.0 : (bloc is _Titre ? 16.0 : 10.0);
      enfants.add(Padding(
        padding: EdgeInsets.only(top: espace),
        child: _rendre(context, bloc),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: enfants,
    );
  }

  // ── Les blocs ─────────────────────────────────────────────────────────

  Widget _rendre(BuildContext context, _Bloc bloc) {
    if (bloc is _Titre) {
      final echelle = switch (bloc.niveau) { 1 => 1.42, 2 => 1.26, 3 => 1.13, _ => 1.0 };
      final taille = (style.fontSize ?? 16) * echelle;
      return Text.rich(
        TextSpan(children: _enLigne(bloc.texte, style.copyWith(
          fontSize: taille,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ))),
      );
    }
    if (bloc is _Paragraphe) {
      return Text.rich(TextSpan(children: _enLigne(bloc.texte, style)));
    }
    if (bloc is _Liste) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final element in bloc.elements)
            Padding(
              padding: EdgeInsets.only(left: element.niveau * 18.0, top: 3, bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: element.ordonnee ? 26 : 18,
                    child: _marque(element),
                  ),
                  Expanded(
                    child: Text.rich(TextSpan(children: _enLigne(element.texte, style))),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    if (bloc is _Code) {
      return _BlocDeCode(code: bloc.code, langue: bloc.langue, style: style);
    }
    if (bloc is _Citation) {
      // ⚠️ UNE CITATION PEUT CONTENIR N'IMPORTE QUOI. Son contenu était
      // traité comme une seule ligne de texte : une liste ou un titre
      // cités s'affichaient avec leurs tirets et leurs dièses en clair.
      // On le réanalyse donc comme un document à part entière.
      final dedans = _analyser(bloc.texte);
      return Container(
        padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: (style.color ?? OuroColors.label).withValues(alpha: 0.28),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var j = 0; j < dedans.length; j++)
              Padding(
                padding: EdgeInsets.only(top: j == 0 ? 0 : 8),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: OuroColors.secondaryLabel),
                  child: _rendre(context, dedans[j]),
                ),
              ),
          ],
        ),
      );
    }
    if (bloc is _Separateur) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(height: 0.8, color: OuroColors.separator),
      );
    }
    if (bloc is _Tableau) {
      return _TableauMarkdown(tableau: bloc, style: style, enLigne: _enLigne);
    }
    return const SizedBox.shrink();
  }

  Widget _marque(_Element element) {
    final couleur = style.color ?? OuroColors.label;
    if (element.coche != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          element.coche! ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: (style.fontSize ?? 16) + 1,
          color: element.coche! ? OuroColors.accent : couleur.withValues(alpha: 0.6),
        ),
      );
    }
    if (element.ordonnee) {
      return Text(
        element.marque,
        style: style.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: couleur.withValues(alpha: 0.75),
        ),
      );
    }
    const puces = ['•', '◦', '▪'];
    return Text(
      puces[element.niveau.clamp(0, 2)],
      style: style.copyWith(color: couleur.withValues(alpha: 0.75)),
    );
  }

  // ── Le texte en ligne ─────────────────────────────────────────────────

  /// ⚠️ L'ÉCHAPPEMENT EST EN PREMIER, ET CE N'EST PAS UN HASARD.
  ///
  /// L'analyse va de gauche à droite : une barre oblique inverse rencontrée
  /// avant un astérisque gagne donc sur toutes les autres règles. Sans ça,
  /// un modèle qui écrit « 2 \* 3 » affichait la barre, et « \_mot\_ »
  /// passait carrément en italique — l'exact contraire de ce que
  /// l'échappement demande.
  static final RegExp _motif = RegExp(
    r'\\([\\`*_{}\[\]()#+\-.!~>|])'                            // 1 échappement
    r'|(`+)(.+?)\2'                                            // 2-3 code
    r'|\*\*\*(?=\S)(.+?)(?<=\S)\*\*\*'                        // 4 gras italique
    r'|\*\*(?=\S)(.+?)(?<=\S)\*\*'                            // 5 gras
    r'|__(?=\S)(.+?)(?<=\S)__'                                // 6 gras
    r'|\*(?=[^\s*])(.+?)(?<=[^\s*])\*'                        // 7 italique
    r'|(?<![A-Za-z0-9])_(?=[^\s_])(.+?)(?<=[^\s_])_(?![A-Za-z0-9])' // 8 italique
    r'|~~(?=\S)(.+?)(?<=\S)~~'                                // 9 barré
    r'|\[([^\]]+)\]\(([^)\s]+)\)'                             // 10-11 lien
    // ⚠️ LES PARENTHÈSES ÉQUILIBRÉES FONT PARTIE DE L'ADRESSE. L'ancienne
    // règle s'arrêtait à la première parenthèse : un lien Wikipédia comme
    // « …/Dart_(langage) » était coupé en deux, et la moitié restante
    // s'affichait comme du texte. On accepte donc les paires équilibrées,
    // puis on retire la ponctuation finale qui appartient à la phrase.
    // ⚠️ `$` ET NON `\$`. Une chaîne brute Dart (`r'…'`) n'interprète
    // rien : la barre serait restée dans l'expression et `$` aurait
    // désigné un dollar littéral au lieu de la fin du texte. Résultat
    // mesuré : une adresse en fin de phrase n'était plus reconnue du tout.
    r'|(https?://[^\s<>]*?(?:\([^\s<>()]*\)[^\s<>]*?)*)(?=[.,;:!?)\]]*(?:\s|$))',
  );

  List<InlineSpan> _enLigne(String texte, TextStyle base) {
    final spans = <InlineSpan>[];
    var curseur = 0;
    for (final m in _motif.allMatches(texte)) {
      if (m.start > curseur) {
        spans.add(TextSpan(text: texte.substring(curseur, m.start), style: base));
      }
      if (m.group(1) != null) {
        // Échappé : on écrit le caractère, et la barre disparaît.
        spans.add(TextSpan(text: m.group(1), style: base));
      } else if (m.group(3) != null) {
        spans.add(TextSpan(
          text: m.group(3),
          style: base.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['SF Mono', 'Menlo', 'Roboto Mono', 'Courier'],
            fontSize: (base.fontSize ?? 16) * 0.9,
            backgroundColor: (base.color ?? OuroColors.label).withValues(alpha: 0.10),
          ),
        ));
      } else if (m.group(4) != null) {
        spans.addAll(_enLigne(m.group(4)!,
            base.copyWith(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)));
      } else if (m.group(5) != null || m.group(6) != null) {
        spans.addAll(_enLigne(m.group(5) ?? m.group(6)!,
            base.copyWith(fontWeight: FontWeight.w700)));
      } else if (m.group(7) != null || m.group(8) != null) {
        spans.addAll(_enLigne(m.group(7) ?? m.group(8)!,
            base.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(9) != null) {
        spans.addAll(_enLigne(m.group(9)!,
            base.copyWith(decoration: TextDecoration.lineThrough)));
      } else if (m.group(10) != null) {
        // ⚠️ LE TEXTE D'UN LIEN SE MET EN FORME LUI AUSSI. Il était posé
        // tel quel : « [**la doc**](…) » affichait les astérisques au
        // milieu du lien. On l'analyse donc comme n'importe quel texte,
        // puis on rend chaque morceau touchable.
        spans.addAll(_liable(
          _enLigne(m.group(10)!, base.copyWith(color: OuroColors.accent)),
          m.group(11)!,
        ));
      } else if (m.group(12) != null) {
        final adresse = m.group(12)!;
        spans.addAll(_liable(
          [TextSpan(text: adresse, style: base.copyWith(color: OuroColors.accent))],
          adresse,
        ));
      }
      curseur = m.end;
    }
    if (curseur < texte.length) {
      spans.add(TextSpan(text: texte.substring(curseur), style: base));
    }
    return spans;
  }

  /// Rend touchable chaque morceau de texte d'un lien.
  ///
  /// ⚠️ UN RECONNAISSEUR POSÉ SUR UN PARENT NE DESCEND PAS À SES ENFANTS
  /// dans Flutter : il ne vaut que pour le `text` du span lui-même. Il
  /// faut donc l'attacher feuille par feuille, sinon un lien dont le
  /// texte est en gras n'est plus touchable du tout.
  List<InlineSpan> _liable(List<InlineSpan> morceaux, String adresse) {
    final r = _reconnaisseur(adresse);
    return [
      for (final s in morceaux)
        if (s is TextSpan && s.text != null)
          TextSpan(text: s.text, style: s.style, recognizer: r)
        else if (s is TextSpan)
          TextSpan(children: _liable(s.children ?? const [], adresse), style: s.style)
        else
          s,
    ];
  }
}

// ── L'analyse en blocs ──────────────────────────────────────────────────

abstract class _Bloc {
  const _Bloc();
}

class _Titre extends _Bloc {
  const _Titre(this.niveau, this.texte);
  final int niveau;
  final String texte;
}

class _Paragraphe extends _Bloc {
  const _Paragraphe(this.texte);
  final String texte;
}

class _Element {
  const _Element({
    required this.niveau,
    required this.ordonnee,
    required this.marque,
    required this.texte,
    this.coche,
  });
  final int niveau;
  final bool ordonnee;
  final String marque;
  final String texte;
  final bool? coche;
}

class _Liste extends _Bloc {
  const _Liste(this.elements);
  final List<_Element> elements;
}

class _Code extends _Bloc {
  const _Code(this.langue, this.code);
  final String langue;
  final String code;
}

class _Citation extends _Bloc {
  const _Citation(this.texte);
  final String texte;
}

class _Separateur extends _Bloc {
  const _Separateur();
}

class _Tableau extends _Bloc {
  const _Tableau(this.entete, this.lignes);
  final List<String> entete;
  final List<List<String>> lignes;
}

final RegExp _reTitre = RegExp(r'^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$');
final RegExp _reSeparateur = RegExp(r'^\s{0,3}([-*_])(\s*\1){2,}\s*$');
final RegExp _reElement = RegExp(r'^(\s*)([-*+•]|\d{1,3}[.)])\s+(.*)$');
final RegExp _reCase = RegExp(r'^\[( |x|X)\]\s+(.*)$');
final RegExp _reLigneSeparatriceTableau =
    RegExp(r'^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$');

List<String> _cellules(String ligne) {
  var l = ligne.trim();
  if (l.startsWith('|')) l = l.substring(1);
  if (l.endsWith('|')) l = l.substring(0, l.length - 1);
  return l.split('|').map((c) => c.trim()).toList();
}

bool _debutDeBloc(String ligne) {
  final t = ligne.trimLeft();
  return t.startsWith('```') ||
      t.startsWith('>') ||
      _reTitre.hasMatch(ligne) ||
      _reSeparateur.hasMatch(ligne) ||
      _reElement.hasMatch(ligne);
}

/// Transforme des retraits en NIVEAUX, quel que soit le pas employé.
///
/// ⚠️ LE PAS ÉTAIT SUPPOSÉ ÊTRE DE DEUX ESPACES. La règle divisait le
/// retrait par deux : un modèle qui indente de quatre espaces — ce que
/// font la plupart — voyait son premier niveau d'imbrication compté comme
/// le deuxième, et la liste partait deux fois trop loin vers la droite.
///
/// On ne devine plus le pas : on relève les retraits réellement présents
/// dans CE bloc, on les trie, et le rang de chacun donne son niveau. Deux
/// espaces, quatre espaces, une tabulation ou un mélange des trois
/// donnent le même résultat — celui qu'on voit dans le texte source.
List<_Element> _nivelerListe(List<_Element> bruts) {
  final retraits = bruts.map((e) => e.niveau).toSet().toList()..sort();
  return [
    for (final e in bruts)
      _Element(
        niveau: retraits.indexOf(e.niveau).clamp(0, 3),
        ordonnee: e.ordonnee,
        marque: e.marque,
        texte: e.texte,
        coche: e.coche,
      ),
  ];
}

List<_Bloc> _analyser(String source) {
  final lignes = source.replaceAll('\r\n', '\n').split('\n');
  final blocs = <_Bloc>[];
  var i = 0;
  while (i < lignes.length) {
    final ligne = lignes[i];
    final t = ligne.trimLeft();

    if (t.isEmpty) {
      i++;
      continue;
    }

    // Bloc de code — y compris ouvert et pas encore fermé (réponse en cours).
    if (t.startsWith('```')) {
      final langue = t.substring(3).trim();
      final code = <String>[];
      i++;
      while (i < lignes.length && !lignes[i].trimLeft().startsWith('```')) {
        code.add(lignes[i]);
        i++;
      }
      i++; // la clôture
      blocs.add(_Code(langue, code.join('\n')));
      continue;
    }

    final titre = _reTitre.firstMatch(ligne);
    if (titre != null) {
      blocs.add(_Titre(titre.group(1)!.length, titre.group(2)!));
      i++;
      continue;
    }

    if (_reSeparateur.hasMatch(ligne)) {
      blocs.add(const _Separateur());
      i++;
      continue;
    }

    if (t.startsWith('>')) {
      final cite = <String>[];
      while (i < lignes.length && lignes[i].trimLeft().startsWith('>')) {
        cite.add(lignes[i].trimLeft().substring(1).replaceFirst(RegExp(r'^ '), ''));
        i++;
      }
      blocs.add(_Citation(cite.join('\n')));
      continue;
    }

    // Tableau : une ligne à barres suivie d'une ligne de tirets.
    if (ligne.contains('|') &&
        i + 1 < lignes.length &&
        _reLigneSeparatriceTableau.hasMatch(lignes[i + 1])) {
      final entete = _cellules(ligne);
      final corps = <List<String>>[];
      i += 2;
      while (i < lignes.length && lignes[i].contains('|') && lignes[i].trim().isNotEmpty) {
        corps.add(_cellules(lignes[i]));
        i++;
      }
      blocs.add(_Tableau(entete, corps));
      continue;
    }

    if (_reElement.hasMatch(ligne)) {
      final elements = <_Element>[];
      while (i < lignes.length) {
        final m = _reElement.firstMatch(lignes[i]);
        if (m == null) {
          // Ligne de continuation d'un élément (indentée), sinon fin de liste.
          if (elements.isNotEmpty &&
              lignes[i].trim().isNotEmpty &&
              lignes[i].startsWith('  ') &&
              !_debutDeBloc(lignes[i])) {
            final dernier = elements.removeLast();
            elements.add(_Element(
              niveau: dernier.niveau,
              ordonnee: dernier.ordonnee,
              marque: dernier.marque,
              texte: '${dernier.texte}\n${lignes[i].trim()}',
              coche: dernier.coche,
            ));
            i++;
            continue;
          }
          break;
        }
        final indentation = m.group(1)!.replaceAll('\t', '    ').length;
        final marque = m.group(2)!;
        final ordonnee = RegExp(r'^\d').hasMatch(marque);
        var contenu = m.group(3)!;
        bool? coche;
        final caseACocher = _reCase.firstMatch(contenu);
        if (!ordonnee && caseACocher != null) {
          coche = caseACocher.group(1)!.toLowerCase() == 'x';
          contenu = caseACocher.group(2)!;
        }
        elements.add(_Element(
          // Le retrait BRUT : les niveaux se calculent après coup, quand
          // on connaît tous les retraits du bloc — voir `_nivelerListe`.
          niveau: indentation,
          ordonnee: ordonnee,
          marque: ordonnee ? '${marque.substring(0, marque.length - 1)}.' : marque,
          texte: contenu,
          coche: coche,
        ));
        i++;
        // Une ligne vide entre deux éléments ne coupe pas la liste.
        if (i + 1 < lignes.length &&
            lignes[i].trim().isEmpty &&
            _reElement.hasMatch(lignes[i + 1])) {
          i++;
        }
      }
      blocs.add(_Liste(_nivelerListe(elements)));
      continue;
    }

    // Paragraphe : jusqu'à une ligne vide ou le début d'un autre bloc. Les
    // retours à la ligne simples sont gardés, comme dans une conversation.
    final paragraphe = <String>[ligne.trim()];
    i++;
    while (i < lignes.length &&
        lignes[i].trim().isNotEmpty &&
        !_debutDeBloc(lignes[i]) &&
        !(lignes[i].contains('|') &&
            i + 1 < lignes.length &&
            _reLigneSeparatriceTableau.hasMatch(lignes[i + 1]))) {
      paragraphe.add(lignes[i].trim());
      i++;
    }
    blocs.add(_Paragraphe(paragraphe.join('\n')));
  }
  return blocs;
}

// ── Le bloc de code ─────────────────────────────────────────────────────

class _BlocDeCode extends StatefulWidget {
  const _BlocDeCode({required this.code, required this.langue, required this.style});

  final String code;
  final String langue;
  final TextStyle style;

  @override
  State<_BlocDeCode> createState() => _BlocDeCodeState();
}

class _BlocDeCodeState extends State<_BlocDeCode> {
  bool _copie = false;

  /// Combien de temps « Copié » reste affiché.
  ///
  /// ⚠️ PAS UNE DURÉE D'ANIMATION : c'est le temps qu'il faut pour LIRE
  /// un mot et comprendre que le geste a marché. Deux secondes, c'est la
  /// mesure habituelle d'un message de confirmation — plus court, on
  /// doute d'avoir vu ; plus long, ça traîne.
  static const Duration _tempsDeLire = Duration(seconds: 2);

  Future<void> _copier() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copie = true);
    await Future<void>.delayed(_tempsDeLire);
    if (mounted) setState(() => _copie = false);
  }

  @override
  Widget build(BuildContext context) {
    final encre = widget.style.color ?? OuroColors.label;
    final taille = (widget.style.fontSize ?? 16) * 0.85;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: encre.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: encre.withValues(alpha: 0.10), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            decoration: BoxDecoration(
              color: encre.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DesignTokens.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.langue.isEmpty ? 'code' : widget.langue,
                    style: widget.style.copyWith(
                      fontSize: taille * 0.95,
                      color: encre.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _copier,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Icon(
                      _copie ? Icons.check_rounded : Icons.copy_rounded,
                      size: 16,
                      color: _copie ? OuroColors.accent : encre.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Text(
              widget.code,
              softWrap: false,
              style: widget.style.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['SF Mono', 'Menlo', 'Roboto Mono', 'Courier'],
                fontSize: taille,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Le tableau ──────────────────────────────────────────────────────────

class _TableauMarkdown extends StatelessWidget {
  const _TableauMarkdown({
    required this.tableau,
    required this.style,
    required this.enLigne,
  });

  final _Tableau tableau;
  final TextStyle style;
  final List<InlineSpan> Function(String texte, TextStyle base) enLigne;

  @override
  Widget build(BuildContext context) {
    final colonnes = [
      tableau.entete.length,
      ...tableau.lignes.map((l) => l.length),
    ].reduce((a, b) => a > b ? a : b);
    List<String> completer(List<String> ligne) =>
        [...ligne, for (var k = ligne.length; k < colonnes; k++) ''];
    final encre = style.color ?? OuroColors.label;
    final petit = style.copyWith(fontSize: (style.fontSize ?? 16) * 0.92);

    Widget cellule(String texte, {bool entete = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text.rich(TextSpan(
            children: enLigne(
              texte,
              entete ? petit.copyWith(fontWeight: FontWeight.w700) : petit,
            ),
          )),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(
          color: encre.withValues(alpha: 0.14),
          width: 0.8,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: encre.withValues(alpha: 0.06)),
            children: [for (final c in completer(tableau.entete)) cellule(c, entete: true)],
          ),
          for (final ligne in tableau.lignes)
            TableRow(children: [for (final c in completer(ligne)) cellule(c)]),
        ],
      ),
    );
  }
}

// ── Le texte nu, pour copier, partager et lire à voix haute ─────────────

/// La réponse sans aucun signe de mise en forme : ni astérisques, ni dièses,
/// ni barres de tableau. C'est ce qui part dans le presse-papiers, dans le
/// partage et dans la synthèse vocale — qui lirait sinon « astérisque
/// astérisque » à voix haute.
String texteBrutDepuisMarkdown(String source) {
  String enLigne(String texte) {
    var t = texte;
    for (var passe = 0; passe < 3; passe++) {
      // ⚠️ LES NUMÉROS SUIVENT `_motif`. Ajouter un groupe là-bas sans
      // toucher ici ferait disparaître du texte de ce qu'on copie, de ce
      // qu'on partage et de ce qui est lu à voix haute — sans que rien ne
      // le signale à l'écran.
      final suivant = t.replaceAllMapped(
        _RenduMarkdownState._motif,
        (m) =>
            m.group(1) ??   // le caractère échappé, sans sa barre
            m.group(3) ??   // code en ligne
            m.group(4) ??   // gras italique
            m.group(5) ??
            m.group(6) ??   // gras
            m.group(7) ??
            m.group(8) ??   // italique
            m.group(9) ??   // barré
            m.group(10) ??  // le texte du lien
            m.group(12) ??  // l'adresse nue
            '',
      );
      if (suivant == t) break;
      t = suivant;
    }
    return t;
  }

  final morceaux = <String>[];
  for (final bloc in _analyser(source)) {
    if (bloc is _Titre) {
      morceaux.add(enLigne(bloc.texte));
    } else if (bloc is _Paragraphe) {
      morceaux.add(enLigne(bloc.texte));
    } else if (bloc is _Liste) {
      morceaux.add(bloc.elements
          .map((e) => '${'  ' * e.niveau}${e.ordonnee ? e.marque : '•'} ${enLigne(e.texte)}')
          .join('\n'));
    } else if (bloc is _Code) {
      morceaux.add(bloc.code);
    } else if (bloc is _Citation) {
      morceaux.add(enLigne(bloc.texte));
    } else if (bloc is _Tableau) {
      morceaux.add([bloc.entete, ...bloc.lignes]
          .map((ligne) => ligne.map(enLigne).join(' · '))
          .join('\n'));
    }
  }
  return morceaux.join('\n\n').trim();
}
