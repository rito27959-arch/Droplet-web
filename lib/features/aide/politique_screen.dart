// ============================================================================
// LA POLITIQUE DE CONFIDENTIALITÉ — l'écran qui la présente.
// ----------------------------------------------------------------------------
// Le texte lui-même est dans `politique_texte.dart`, avec les raisons de ce
// découpage. Cet écran ne fait que le montrer, et bien :
//
//   • LARGEUR DE LECTURE TENUE. Une politique, ça se lit vraiment. Des
//     lignes qui traversent un écran de tablette fatiguent au troisième
//     paragraphe ; la colonne est donc bornée.
//   • LE TITRE DE SECTION SE DÉTACHE du corps sans hurler — c'est ce qui
//     permet de survoler puis de revenir.
//   • LA DATE EN BAS, toujours. Une politique sans date ne veut rien dire.
//   • ET LE FAIT QU'ELLE NE SOIT QU'EN DEUX LANGUES EST ÉCRIT EN HAUT,
//     pas caché : quelqu'un qui lit Droplet en russe et tombe sur du
//     français doit comprendre en une ligne que ce n'est pas un bug.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/config/contact_config.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'politique_texte.dart';

class PolitiqueScreen extends StatefulWidget {
  const PolitiqueScreen({super.key});

  @override
  State<PolitiqueScreen> createState() => _PolitiqueScreenState();
}

class _PolitiqueScreenState extends State<PolitiqueScreen> {
  /// `null` : on suit la langue de l'application. Sinon, la personne a
  /// choisi de lire dans l'autre langue.
  String? _langueChoisie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langueApp = Localizations.localeOf(context).languageCode;
    final langue = _langueChoisie ?? (langueApp == 'en' ? 'en' : 'fr');
    final sections = politique(langue);
    final traduite = politiqueTraduite(langueApp);

    return OuroLargeTitleScaffold(
      title: l10n.hlpPrivacyTitle,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              // ⚠️ 620 POINTS AU PLUS. Au-delà, l'œil perd la ligne
              // suivante en revenant à gauche — c'est la mesure de
              // lisibilité de n'importe quel livre, et une politique est
              // le seul écran de Droplet qu'on lit vraiment de bout en
              // bout.
              constraints: const BoxConstraints(maxWidth: 620),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.screenMargin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!traduite) ...[
                      _AvisLangue(
                        texte: l10n.hlpOnlyFrEn,
                        libelleBouton: langue == 'fr'
                            ? l10n.hlpReadInEnglish
                            : l10n.hlpReadInFrench,
                        onBasculer: () => setState(
                          () => _langueChoisie = langue == 'fr' ? 'en' : 'fr',
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space5),
                    ],
                    for (final section in sections) ...[
                      Text(
                        section.titre,
                        style: OuroTypography.title3.copyWith(
                          color: OuroColors.label,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space2),
                      for (final p in section.paragraphes)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: DesignTokens.space3,
                          ),
                          child: Text(
                            p,
                            style: OuroTypography.body.copyWith(
                              color: OuroColors.secondaryLabel,
                              height: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: DesignTokens.space4),
                    ],
                    const SizedBox(height: DesignTokens.space2),
                    Text(
                      l10n.hlpUpdated(kDatePolitique),
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.tertiaryLabel,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// « Ce texte n'existe qu'en français et en anglais » — dit une fois, en
/// haut, avec le moyen de changer de langue juste à côté.
class _AvisLangue extends StatelessWidget {
  const _AvisLangue({
    required this.texte,
    required this.libelleBouton,
    required this.onBasculer,
  });

  final String texte;
  final String libelleBouton;
  final VoidCallback onBasculer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space3),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.translate_rounded,
                  size: 16, color: OuroColors.secondaryLabel),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texte,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space2),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBasculer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(
                  libelleBouton,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
