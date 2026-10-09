// ============================================================================
// VOS DONNÉES — ce que Droplet sait de vous, ligne par ligne.
// ----------------------------------------------------------------------------
// Apple a eu une bonne idée avec ses « étiquettes de confidentialité » : au
// lieu d'un document de six pages, un tableau qui se lit en dix secondes et
// range tout en trois cases — suivi, lié à vous, non lié à vous. Google en a
// fait autant avec sa section « Sécurité des données ».
//
// Les deux ont le même défaut : ON LES LIT DANS LE MAGASIN, PAS DANS L'APP,
// et elles sont déclaratives — l'éditeur coche ce qu'il veut. Ici, l'écran
// est DANS l'application, et il est organisé selon la seule question qui
// compte vraiment pour quelqu'un qui installe une messagerie :
//
//     est-ce que cette ligne sort de mon téléphone, oui ou non ?
//
// D'où trois sections et pas trois cases : ce qui reste, ce qui sort (avec
// le nom du serveur et ce qu'il voit), et ce qui n'existe pas du tout.
//
// ⚠️ LA TROISIÈME SECTION EST LA PLUS IMPORTANTE, et c'est celle que les
// étiquettes d'Apple ne savent pas montrer. « Aucune donnée collectée » y
// est une ligne vide ; ici, chaque chose que Droplet NE demande PAS est
// écrite noir sur blanc. Une absence qu'on énumère se vérifie ; une absence
// qu'on résume se croit sur parole.
//
// Et rien ici n'est une promesse : chaque ligne correspond à du code qu'on
// peut aller lire, et les serveurs nommés sont ceux de `contact_config.dart`,
// ni plus ni moins.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class DonneesScreen extends StatelessWidget {
  const DonneesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroLargeTitleScaffold(
      title: l10n.hlpDataTitle,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.space5),
                  child: Text(
                    l10n.hlpDataLead,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.secondaryLabel,
                      height: 1.45,
                    ),
                  ),
                ),

                // Le résumé, en trois chiffres. C'est ce qu'on lit quand on
                // n'a pas le temps de lire.
                const _Resume(),
                const SizedBox(height: DesignTokens.space6),

                // ── CE QUI RESTE ────────────────────────────────────
                _Pastille(
                  texte: l10n.hlpStays,
                  couleur: OuroColors.successGreen,
                  icone: Icons.smartphone_rounded,
                ),
                const SizedBox(height: DesignTokens.space2),
                OuroListSection(
                  header: l10n.hlpDataOnDevice,
                  children: [
                    OuroListRow(
                      icon: Icons.key_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpRowKeys,
                      subtitle: l10n.hlpRowKeysBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.chat_bubble_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpRowMessages,
                      subtitle: l10n.hlpRowMessagesBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.person_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpRowProfile,
                      subtitle: l10n.hlpRowProfileBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.tune_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpRowSettings,
                      subtitle: l10n.hlpRowSettingsBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.bug_report_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpRowLog,
                      subtitle: l10n.hlpRowLogBody,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space6),

                // ── CE QUI SORT ─────────────────────────────────────
                _Pastille(
                  texte: l10n.hlpLeaves,
                  couleur: OuroColors.warningAmber,
                  icone: Icons.cloud_outlined,
                ),
                const SizedBox(height: DesignTokens.space2),
                OuroListSection(
                  header: l10n.hlpDataServers,
                  footer: l10n.hlpDataServersFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.badge_rounded,
                      iconColor: OuroColors.warningAmber,
                      title: l10n.hlpRowDirectory,
                      subtitle: l10n.hlpRowDirectoryBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.mark_email_unread_rounded,
                      iconColor: OuroColors.warningAmber,
                      title: l10n.hlpRowMailbox,
                      subtitle: l10n.hlpRowMailboxBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.settings_input_antenna_rounded,
                      iconColor: OuroColors.warningAmber,
                      title: l10n.hlpRowSignalling,
                      subtitle: l10n.hlpRowSignallingBody,
                      showChevron: false,
                    ),
                    OuroListRow(
                      icon: Icons.swap_calls_rounded,
                      iconColor: OuroColors.warningAmber,
                      title: l10n.hlpRowRelay,
                      subtitle: l10n.hlpRowRelayBody,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space6),

                // ── CE QUI N'EXISTE PAS ─────────────────────────────
                //
                // ⚠️ ÉNUMÉRÉE, PAS RÉSUMÉE. « Aucune donnée collectée » est
                // une phrase que toutes les applications écrivent. La liste
                // des choses précises qu'on ne demande pas, elle, se
                // vérifie ligne par ligne.
                _Pastille(
                  texte: l10n.hlpNever,
                  couleur: OuroColors.secondaryLabel,
                  icone: Icons.block_rounded,
                ),
                const SizedBox(height: DesignTokens.space2),
                OuroListSection(
                  header: l10n.hlpDataNone,
                  children: [
                    for (final ligne in [
                      l10n.hlpNonePhone,
                      l10n.hlpNoneEmail,
                      l10n.hlpNoneContacts,
                      l10n.hlpNoneLocation,
                      l10n.hlpNoneAds,
                      l10n.hlpNoneAnalytics,
                    ])
                      OuroListRow(
                        leading: Icon(
                          Icons.check_circle_outline_rounded,
                          size: DesignTokens.iconLg,
                          color: OuroColors.successGreen,
                        ),
                        title: ligne,
                        showChevron: false,
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Le résumé en trois chiffres — l'idée de l'étiquette d'Apple, mais avec
/// les vrais nombres de Droplet plutôt que des cases cochées.
class _Resume extends StatelessWidget {
  const _Resume();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space4,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Chiffre(valeur: '0', legende: l10n.hlpCountTracking),
          ),
          _Filet(),
          Expanded(
            child: _Chiffre(valeur: '0', legende: l10n.hlpCountAccount),
          ),
          _Filet(),
          Expanded(
            child: _Chiffre(valeur: '4', legende: l10n.hlpCountServers),
          ),
        ],
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  const _Chiffre({required this.valeur, required this.legende});

  final String valeur;
  final String legende;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valeur,
          style: OuroTypography.title1.copyWith(
            color: OuroColors.label,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          legende,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: OuroTypography.caption1.copyWith(
            color: OuroColors.secondaryLabel,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _Filet extends StatelessWidget {
  const _Filet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space2),
      color: OuroColors.separator,
    );
  }
}

/// L'étiquette d'une section : la réponse avant la liste. On sait ce qu'on
/// va lire avant de le lire.
class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.texte,
    required this.couleur,
    required this.icone,
  });

  final String texte;
  final Color couleur;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 13, color: couleur),
            const SizedBox(width: 5),
            Text(
              texte,
              style: OuroTypography.caption1.copyWith(
                color: couleur,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
