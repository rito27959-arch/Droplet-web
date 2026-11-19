// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES COMPÉTENCES DE L'ASSISTANT — les cartes de l'accueil, à la manière de
// Kimi.
//
// ── CE QUE KIMI FAIT, ET POURQUOI ON LE REPREND ───────────────────────
//
// L'écran d'accueil de Kimi (Moonshot AI) ne se contente pas de « Posez une
// question » : sous la salutation, il montre CE QUE L'ASSISTANT SAIT
// PRODUIRE — Diapositives, Sites web, Documents, Feuilles, Recherche
// approfondie — en cartes qu'on touche. Quelqu'un qui ne savait pas qu'on
// pouvait demander une présentation le découvre en ouvrant l'écran, au lieu
// de le deviner.
//
// Ici, chaque carte correspond à un vrai outil de Droplet, et à rien
// d'autre (une carte qui promet ce que le moteur ne sait pas faire est pire
// qu'une carte absente) :
//   • Diapositives  → `produire_fichier` en .pptx ;
//   • Document      → `produire_fichier` en .docx ou .pdf ;
//   • Site web      → `creer_projet` (un artéfact qu'on ouvre et qu'on lit) ;
//   • Recherche web → l'agent `recherche` (browser_search) ;
//   • Calcul        → l'agent `calcul` (code_interpreter) ;
//   • Code          → l'agent `code`.
//
// Toucher une carte ÉCRIT LE DÉBUT DE LA DEMANDE dans le champ, curseur à
// la fin : on complète le sujet et on envoie. C'est le geste de Kimi — la
// carte arme le mode, la personne dit le sujet. Comme ces outils tournent
// en ligne, la carte passe aussi le moteur sur « En ligne » (et mène à la
// clé s'il n'y en a pas, comme la pastille du moteur).
//
// Les textes sont ici, dans les 10 langues de l'app, plutôt que dans les
// fichiers ARB : ils ne servent qu'à cet écran.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';

enum Competence { diapositives, document, siteWeb, recherche, calcul, code }

class _Texte {
  const _Texte(this.titre, this.detail, this.debut);

  /// Le nom de la carte.
  final String titre;

  /// Ce qu'elle produit, en quelques mots.
  final String detail;

  /// Le début de la demande écrit dans le champ.
  final String debut;
}

extension CompetenceVisuel on Competence {
  IconData get icone => switch (this) {
        Competence.diapositives => Icons.slideshow_rounded,
        Competence.document => Icons.description_rounded,
        Competence.siteWeb => Icons.language_rounded,
        Competence.recherche => Icons.travel_explore_rounded,
        Competence.calcul => Icons.insights_rounded,
        Competence.code => Icons.code_rounded,
      };

  /// La couleur de la tuile — une famille par carte, comme les icônes des
  /// Réglages d'iOS : on retrouve la carte à sa couleur.
  Color get couleur => switch (this) {
        Competence.diapositives => const Color(0xFFFF9500),
        Competence.document => const Color(0xFF007AFF),
        Competence.siteWeb => const Color(0xFF5856D6),
        Competence.recherche => const Color(0xFF34C759),
        Competence.calcul => const Color(0xFFFF2D55),
        Competence.code => const Color(0xFF636366),
      };

  String titre(String langue) => _textes(langue)[index].titre;
  String detail(String langue) => _textes(langue)[index].detail;
  String debut(String langue) => _textes(langue)[index].debut;
}

/// Le titre de la rangée de cartes.
String titreCompetences(String langue) => switch (langue.split('_').first) {
      'en' => 'What I can make',
      'de' => 'Was ich erstellen kann',
      'es' => 'Lo que puedo crear',
      'it' => 'Cosa posso creare',
      'pt' => 'O que posso criar',
      'ru' => 'Что я умею создавать',
      'zh' => '我能为你做',
      'ar' => 'ما يمكنني إنشاؤه',
      'hi' => 'मैं क्या बना सकता हूँ',
      _ => 'Ce que je sais faire',
    };

List<_Texte> _textes(String langue) => switch (langue.split('_').first) {
      'en' => const [
          _Texte('Slides', 'A PowerPoint deck', 'Make a slide deck about '),
          _Texte('Document', 'Word or PDF', 'Write a document about '),
          _Texte('Website', 'A page you can open', 'Build a web page for '),
          _Texte('Web search', 'Sources, up to date', 'Search the web for '),
          _Texte('Analysis', 'Numbers and charts', 'Calculate and explain '),
          _Texte('Code', 'Write or fix code', 'Write code that '),
        ],
      'de' => const [
          _Texte('Folien', 'Eine PowerPoint-Präsentation', 'Erstelle eine Präsentation über '),
          _Texte('Dokument', 'Word oder PDF', 'Schreibe ein Dokument über '),
          _Texte('Website', 'Eine Seite zum Öffnen', 'Baue eine Webseite für '),
          _Texte('Websuche', 'Aktuelle Quellen', 'Suche im Web nach '),
          _Texte('Analyse', 'Zahlen und Diagramme', 'Berechne und erkläre '),
          _Texte('Code', 'Code schreiben oder reparieren', 'Schreibe Code, der '),
        ],
      'es' => const [
          _Texte('Diapositivas', 'Una presentación PowerPoint', 'Haz una presentación sobre '),
          _Texte('Documento', 'Word o PDF', 'Escribe un documento sobre '),
          _Texte('Sitio web', 'Una página para abrir', 'Crea una página web para '),
          _Texte('Búsqueda web', 'Fuentes actualizadas', 'Busca en la web '),
          _Texte('Análisis', 'Cifras y gráficos', 'Calcula y explica '),
          _Texte('Código', 'Escribir o corregir código', 'Escribe código que '),
        ],
      'it' => const [
          _Texte('Slide', 'Una presentazione PowerPoint', 'Crea una presentazione su '),
          _Texte('Documento', 'Word o PDF', 'Scrivi un documento su '),
          _Texte('Sito web', 'Una pagina da aprire', 'Crea una pagina web per '),
          _Texte('Ricerca web', 'Fonti aggiornate', 'Cerca sul web '),
          _Texte('Analisi', 'Numeri e grafici', 'Calcola e spiega '),
          _Texte('Codice', 'Scrivere o correggere codice', 'Scrivi codice che '),
        ],
      'pt' => const [
          _Texte('Slides', 'Uma apresentação PowerPoint', 'Crie uma apresentação sobre '),
          _Texte('Documento', 'Word ou PDF', 'Escreva um documento sobre '),
          _Texte('Site', 'Uma página para abrir', 'Crie uma página web para '),
          _Texte('Pesquisa web', 'Fontes atualizadas', 'Pesquise na web '),
          _Texte('Análise', 'Números e gráficos', 'Calcule e explique '),
          _Texte('Código', 'Escrever ou corrigir código', 'Escreva um código que '),
        ],
      'ru' => const [
          _Texte('Слайды', 'Презентация PowerPoint', 'Сделай презентацию о '),
          _Texte('Документ', 'Word или PDF', 'Напиши документ о '),
          _Texte('Сайт', 'Страница, которую можно открыть', 'Создай веб-страницу для '),
          _Texte('Поиск в сети', 'Свежие источники', 'Найди в интернете '),
          _Texte('Анализ', 'Числа и графики', 'Посчитай и объясни '),
          _Texte('Код', 'Написать или исправить код', 'Напиши код, который '),
        ],
      'zh' => const [
          _Texte('幻灯片', 'PowerPoint 演示文稿', '做一份关于以下主题的演示文稿：'),
          _Texte('文档', 'Word 或 PDF', '写一份关于以下主题的文档：'),
          _Texte('网页', '可以打开的页面', '为以下内容做一个网页：'),
          _Texte('联网搜索', '最新来源', '在网上搜索：'),
          _Texte('分析', '数字和图表', '计算并解释：'),
          _Texte('代码', '编写或修复代码', '写一段代码，用来'),
        ],
      'ar' => const [
          _Texte('شرائح', 'عرض PowerPoint', 'أنشئ عرضًا تقديميًا عن '),
          _Texte('مستند', 'Word أو PDF', 'اكتب مستندًا عن '),
          _Texte('موقع ويب', 'صفحة يمكن فتحها', 'أنشئ صفحة ويب لـ '),
          _Texte('بحث في الويب', 'مصادر حديثة', 'ابحث في الويب عن '),
          _Texte('تحليل', 'أرقام ورسوم بيانية', 'احسب واشرح '),
          _Texte('برمجة', 'كتابة الشيفرة أو إصلاحها', 'اكتب شيفرة '),
        ],
      'hi' => const [
          _Texte('स्लाइड', 'PowerPoint प्रस्तुति', 'इस विषय पर प्रस्तुति बनाओ: '),
          _Texte('दस्तावेज़', 'Word या PDF', 'इस विषय पर दस्तावेज़ लिखो: '),
          _Texte('वेबसाइट', 'खोलने लायक पेज', 'इसके लिए वेब पेज बनाओ: '),
          _Texte('वेब खोज', 'ताज़ा स्रोत', 'वेब पर खोजो: '),
          _Texte('विश्लेषण', 'आँकड़े और चार्ट', 'गणना करो और समझाओ: '),
          _Texte('कोड', 'कोड लिखें या ठीक करें', 'ऐसा कोड लिखो जो '),
        ],
      _ => const [
          _Texte('Diapositives', 'Une présentation PowerPoint', 'Fais une présentation sur '),
          _Texte('Document', 'Word ou PDF', 'Rédige un document sur '),
          _Texte('Site web', 'Une page à ouvrir', 'Crée une page web pour '),
          _Texte('Recherche web', 'Des sources à jour', 'Cherche sur le web '),
          _Texte('Analyse', 'Chiffres et graphiques', 'Calcule et explique '),
          _Texte('Code', 'Écrire ou corriger du code', 'Écris du code qui '),
        ],
    };

/// La grille des cartes de compétences : deux colonnes, trois rangées.
class GrilleCompetences extends StatelessWidget {
  const GrilleCompetences({super.key, required this.langue, required this.onChoisir});

  final String langue;
  final void Function(Competence) onChoisir;

  @override
  Widget build(BuildContext context) {
    final calme = MediaQuery.disableAnimationsOf(context);
    final cartes = [
      for (final c in Competence.values) _Carte(competence: c, langue: langue, onTap: () => onChoisir(c)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: DesignTokens.space2),
          child: Text(
            titreCompetences(langue),
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (var r = 0; r < cartes.length; r += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space2),
            child: Row(
              children: [
                Expanded(child: _anime(cartes[r], r, calme)),
                const SizedBox(width: DesignTokens.space2),
                Expanded(child: r + 1 < cartes.length ? _anime(cartes[r + 1], r + 1, calme) : const SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  /// Les cartes arrivent l'une après l'autre, une seule fois.
  Widget _anime(Widget w, int i, bool calme) => calme
      ? w
      : w
          .animate()
          .fadeIn(duration: 260.ms, delay: (120 + 45 * i).ms)
          .slideY(begin: 0.12, curve: DesignTokens.curveEnter, duration: 320.ms, delay: (120 + 45 * i).ms);
}

class _Carte extends StatefulWidget {
  const _Carte({required this.competence, required this.langue, required this.onTap});

  final Competence competence;
  final String langue;
  final VoidCallback onTap;

  @override
  State<_Carte> createState() => _CarteState();
}

class _CarteState extends State<_Carte> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.competence;
    return Semantics(
      button: true,
      label: '${c.titre(widget.langue)}. ${c.detail(widget.langue)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _appui = true),
        onTapCancel: () => setState(() => _appui = false),
        onTapUp: (_) => setState(() => _appui = false),
        onTap: () {
          OuroHaptics.selection();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _appui ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: OuroColors.separator.withValues(alpha: 0.6), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(c.couleur, Colors.white, 0.12)!, c.couleur],
                    ),
                  ),
                  child: Icon(c.icone, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.titre(widget.langue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.subheadline.copyWith(
                          color: OuroColors.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        c.detail(widget.langue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
