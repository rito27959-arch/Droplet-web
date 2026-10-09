// ============================================================================
// L'AIDE — celle des grandes applications, sauf qu'elle marche hors ligne.
// ----------------------------------------------------------------------------
// WhatsApp, Telegram et Signal ont tous la même rangée « Aide » dans leurs
// réglages, et elle ouvre toujours la même chose : UN SITE WEB. Centre
// d'aide, FAQ, formulaire de contact — tout est en ligne.
//
// ⚠️ POUR DROPLET, CE SERAIT ABSURDE. Droplet est fait pour marcher quand il
// n'y a pas de réseau : coupure, zone blanche, forfait épuisé. Une aide qui
// exige Internet serait muette exactement au moment où quelqu'un se demande
// pourquoi son message ne part pas. Les réponses sont donc DANS
// l'application, écrites en dur, et la recherche fonctionne sans rien
// demander à personne.
//
// La forme est celle d'iOS : une liste groupée, une question par ligne, qui
// se déplie sur place. Pas de navigation vers une page par question — sept
// allers-retours pour lire sept réponses, c'est ce qui rend les centres
// d'aide pénibles.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Une question et sa réponse.
class QuestionAide {
  const QuestionAide(this.question, this.reponse);
  final String question;
  final String reponse;
}

List<QuestionAide> questionsAide(AppLocalizations l) => [
      QuestionAide(l.hlpQOffline, l.hlpAOffline),
      QuestionAide(l.hlpQCrypto, l.hlpACrypto),
      QuestionAide(l.hlpQNoAccount, l.hlpANoAccount),
      QuestionAide(l.hlpQPending, l.hlpAPending),
      QuestionAide(l.hlpQAddSomeone, l.hlpAAddSomeone),
      QuestionAide(l.hlpQUninstall, l.hlpAUninstall),
      QuestionAide(l.hlpQBattery, l.hlpABattery),
      QuestionAide(l.hlpQReport, l.hlpAReport),
    ];

class AideScreen extends StatefulWidget {
  const AideScreen({super.key});

  @override
  State<AideScreen> createState() => _AideScreenState();
}

class _AideScreenState extends State<AideScreen> {
  final _recherche = TextEditingController();
  final Set<int> _ouvertes = {};
  String _filtre = '';

  @override
  void initState() {
    super.initState();
    _recherche.addListener(() {
      final t = _recherche.text.trim().toLowerCase();
      if (t == _filtre) return;
      // Chercher rouvre tout : on veut voir les réponses qui contiennent
      // le mot, pas une liste de titres à déplier un par un.
      setState(() {
        _filtre = t;
        _ouvertes.clear();
      });
    });
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  /// Sans accents et en minuscules : chercher « decharge » doit trouver
  /// « décharge », sinon la recherche ne sert qu'à ceux qui tapent les
  /// accents.
  static String _aplati(String s) {
    const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
    const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
    final b = StringBuffer();
    for (final c in s.toLowerCase().runes) {
      final ch = String.fromCharCode(c);
      final i = avec.indexOf(ch);
      b.write(i >= 0 ? sans[i] : ch);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final toutes = questionsAide(l10n);
    final f = _aplati(_filtre);
    final visibles = <int>[
      for (var i = 0; i < toutes.length; i++)
        if (f.isEmpty ||
            _aplati(toutes[i].question).contains(f) ||
            _aplati(toutes[i].reponse).contains(f))
          i,
    ];

    return OuroLargeTitleScaffold(
      title: l10n.hlpHelpTitle,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.screenMargin,
              0,
              DesignTokens.screenMargin,
              DesignTokens.space4,
            ),
            child: _Recherche(controller: _recherche),
          ),
        ),
        if (visibles.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40, color: OuroColors.tertiaryLabel),
                  const SizedBox(height: DesignTokens.space3),
                  Text(
                    l10n.hlpNoResult,
                    textAlign: TextAlign.center,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.secondaryLabel,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.screenMargin,
              ),
              child: OuroListSection(
                separatorInset: DesignTokens.screenMargin,
                children: [
                  for (final i in visibles)
                    _Question(
                      question: toutes[i].question,
                      reponse: toutes[i].reponse,
                      ouverte: _ouvertes.contains(i) || f.isNotEmpty,
                      onBascule: () {
                        OuroHaptics.selection();
                        setState(() {
                          if (!_ouvertes.remove(i)) _ouvertes.add(i);
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        // La sortie de secours : quand la réponse n'y est pas, on ne laisse
        // pas la personne dans une impasse.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.screenMargin,
              DesignTokens.space6,
              DesignTokens.screenMargin,
              DesignTokens.space8,
            ),
            child: OuroListSection(
              footer: l10n.hlpStillStuckFooter,
              children: [
                OuroListRow(
                  icon: Icons.support_agent_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.hlpContact,
                  onTap: () => context.push('/aide/contact'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Le champ de recherche, à la forme iOS : une capsule grise, la loupe
/// dedans, et une croix qui n'apparaît qu'une fois qu'on a tapé.
class _Recherche extends StatelessWidget {
  const _Recherche({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, valeur, _) => Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: OuroColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                size: 17, color: OuroColors.secondaryLabel),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                style: OuroTypography.body.copyWith(color: OuroColors.label),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: l10n.hlpSearchHint,
                  hintStyle: OuroTypography.body
                      .copyWith(color: OuroColors.tertiaryLabel),
                ),
              ),
            ),
            if (valeur.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  OuroHaptics.selection();
                  controller.clear();
                },
                child: Icon(Icons.cancel_rounded,
                    size: 17, color: OuroColors.tertiaryLabel),
              ),
          ],
        ),
      ),
    );
  }
}

/// Une question qui se déplie sur place — le chevron tourne, la réponse
/// glisse. Jamais une page de plus pour trois lignes de texte.
class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.reponse,
    required this.ouverte,
    required this.onBascule,
  });

  final String question;
  final String reponse;
  final bool ouverte;
  final VoidCallback onBascule;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBascule,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.screenMargin,
          12,
          DesignTokens.screenMargin,
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: ouverte ? 0.25 : 0,
                  duration: DesignTokens.durationFast,
                  curve: DesignTokens.curveEnter,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: DesignTokens.iconLg,
                    color: OuroColors.tertiaryLabel,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8, right: 24),
                child: Text(
                  reponse,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.45,
                  ),
                ),
              ),
              crossFadeState: ouverte
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: DesignTokens.durationFast,
              sizeCurve: DesignTokens.curveEnter,
            ),
          ],
        ),
      ),
    );
  }
}
