// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CE QU'ON PEUT FAIRE D'UN MESSAGE — le menu, et l'index des chapitres.
//
// ── LE MENU ───────────────────────────────────────────────────────────
//
// Repris de Claude iOS, qui a le meilleur de tous : copier, copier EN
// MARKDOWN (deux entrées distinctes — le texte brut pour un SMS, le
// Markdown pour un document), et « marquer comme chapitre ».
//
// Ajouté : modifier sa propre question. Claude le fait au web mais pas
// clairement sur mobile, et c'est le geste le plus utile qui soit quand
// on s'est mal exprimé — bien plus que de reposer la question en
// dessous, ce qui laisse deux versions dans le fil.
//
// ⚠️ MODIFIER EFFACE LA SUITE. Tout ce qui vient après répondait à
// l'ancienne question ; le garder produirait un fil qui se contredit.
// C'est dit avant, pas découvert après.
//
// ── L'INDEX DES CHAPITRES : CE QU'ANTHROPIC A OUBLIÉ ──────────────────
//
// Claude sait marquer un message comme chapitre. Mais il n'existe AUCUN
// écran pour voir les chapitres marqués ni sauter de l'un à l'autre —
// c'est une demande ouverte de leurs propres utilisateurs. Une
// fonctionnalité sans son écran de navigation ne sert à rien : on marque
// des chapitres qu'on ne peut pas retrouver.
//
// Ici l'index existe : une feuille qui liste les chapitres dans l'ordre
// et fait défiler jusqu'à celui qu'on touche. C'est trente lignes de
// code, et c'est ce qui transforme l'idée en outil.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

enum ActionMessage {
  copier,
  copierMarkdown,
  modifier,
  regenerer,
  lire,
  partager,
  chapitre,
  contexte,
}

/// Ouvre le menu d'un message et rend l'action choisie.
Future<ActionMessage?> ouvrirActionsMessage(
  BuildContext context, {
  required bool deMoi,
  required bool dejaChapitre,
  required bool lectureDisponible,
}) {
  OuroHaptics.light();
  return showModalBottomSheet<ActionMessage>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _MenuMessage(
      deMoi: deMoi,
      dejaChapitre: dejaChapitre,
      lectureDisponible: lectureDisponible,
    ),
  );
}

class _MenuMessage extends StatelessWidget {
  const _MenuMessage({
    required this.deMoi,
    required this.dejaChapitre,
    required this.lectureDisponible,
  });

  final bool deMoi;
  final bool dejaChapitre;
  final bool lectureDisponible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OuroListSection(
              children: [
                OuroListRow(
                  icon: Icons.copy_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.amCopy,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, ActionMessage.copier),
                ),
                OuroListRow(
                  icon: Icons.code_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.amCopyMarkdown,
                  subtitle: l10n.amCopyMarkdownHint,
                  showChevron: false,
                  onTap: () =>
                      Navigator.pop(context, ActionMessage.copierMarkdown),
                ),
                OuroListRow(
                  icon: Icons.ios_share_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.amShare,
                  showChevron: false,
                  onTap: () =>
                      Navigator.pop(context, ActionMessage.partager),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space2),
            OuroListSection(
              children: [
                if (deMoi)
                  OuroListRow(
                    icon: Icons.edit_outlined,
                    iconColor: OuroColors.accent,
                    title: l10n.amEdit,
                    subtitle: l10n.amEditHint,
                    showChevron: false,
                    onTap: () =>
                        Navigator.pop(context, ActionMessage.modifier),
                  )
                else ...[
                  OuroListRow(
                    icon: Icons.refresh_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.amRegenerate,
                    showChevron: false,
                    onTap: () =>
                        Navigator.pop(context, ActionMessage.regenerer),
                  ),
                  if (lectureDisponible)
                    OuroListRow(
                      icon: Icons.volume_up_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.amReadAloud,
                      showChevron: false,
                      onTap: () =>
                          Navigator.pop(context, ActionMessage.lire),
                    ),
                ],
                OuroListRow(
                  icon: Icons.format_quote_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.amAsContext,
                  subtitle: l10n.amAsContextHint,
                  showChevron: false,
                  onTap: () =>
                      Navigator.pop(context, ActionMessage.contexte),
                ),
                OuroListRow(
                  icon: dejaChapitre
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  iconColor: OuroColors.accent,
                  title: dejaChapitre ? l10n.amUnchapter : l10n.amChapter,
                  subtitle: dejaChapitre ? null : l10n.amChapterHint,
                  showChevron: false,
                  onTap: () =>
                      Navigator.pop(context, ActionMessage.chapitre),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space2),
            OuroListSection(
              children: [
                OuroListRow(
                  title: l10n.actionCancel,
                  showChevron: false,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// « Modifier efface la suite » — demandé avant, pas découvert après.
Future<bool> confirmerModification(BuildContext context, int aEffacer) async {
  final l10n = AppLocalizations.of(context);
  if (aEffacer <= 0) return true;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: OuroColors.secondarySystemGroupedBackground,
      title: Text(l10n.amEditTitle, style: OuroTypography.headline),
      content: Text(
        l10n.amEditBody(aEffacer),
        style: OuroTypography.subheadline.copyWith(
          color: OuroColors.secondaryLabel,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.amEditConfirm),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Copie le texte, avec le retour haptique qui dit que c'est parti.
void copier(String texte) {
  OuroHaptics.success();
  Clipboard.setData(ClipboardData(text: texte));
}

/// Enlève le balisage pour obtenir du texte que l'on peut coller
/// n'importe où — un SMS, un champ de formulaire.
///
/// ⚠️ CE N'EST PAS UN ANALYSEUR MARKDOWN, et ça n'a pas à l'être : on ne
/// cherche pas à comprendre le document, seulement à retirer les signes
/// qui n'ont aucun sens hors d'un rendu. Les blocs de code gardent leur
/// contenu et perdent leurs clôtures — c'est le code qu'on veut coller,
/// pas les trois accents graves.
String enTextePlat(String markdown) {
  var t = markdown;
  // Clôtures de blocs de code, avec leur éventuel langage.
  t = t.replaceAll(RegExp(r'^```[\w+-]*\s*$', multiLine: true), '');
  // ⚠️ LE FILET AVANT L'EMPHASE. Rejoué sur vingt cas : dans l'autre
  // ordre, `***` est lu comme une italique dont le contenu est `*`, et
  // il reste une astérisque orpheline au milieu du texte.
  t = t.replaceAll(
    RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$', multiLine: true),
    '',
  );
  // Titres : on garde le texte, on jette les dièses.
  t = t.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
  // Citations.
  t = t.replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '');
  // Puces : un tiret reste plus lisible qu'une astérisque.
  t = t.replaceAllMapped(
    RegExp(r'^(\s*)[-*+]\s+', multiLine: true),
    (m) => '${m[1]}• ',
  );
  // Liens : le libellé suffit, l'adresse reste si elle porte le sens.
  t = t.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
    (m) => m[1] == m[2] ? '${m[1]}' : '${m[1]} (${m[2]})',
  );
  // Gras. ⚠️ `__` SEULEMENT HORS D'UN MOT : sans cette borne,
  // `a__b__c` perdait ses tirets bas. Même règle que CommonMark.
  t = t.replaceAllMapped(
    RegExp(r'\*\*(?!\s)(.+?)(?<!\s)\*\*', dotAll: true),
    (m) => m[1] ?? '',
  );
  t = t.replaceAllMapped(
    RegExp(r'(?<![\w])__(?!\s)(.+?)(?<!\s)__(?![\w])', dotAll: true),
    (m) => m[1] ?? '',
  );
  // Italique. Même borne : `snake_case_nom` doit rester entier.
  t = t.replaceAllMapped(
    RegExp(r'\*(?!\s)([^*]+?)(?<!\s)\*', dotAll: true),
    (m) => m[1] ?? '',
  );
  t = t.replaceAllMapped(
    RegExp(r'(?<![\w])_(?!\s)([^_]+?)(?<!\s)_(?![\w])', dotAll: true),
    (m) => m[1] ?? '',
  );
  // Code en ligne et barré.
  t = t.replaceAllMapped(RegExp(r'`+([^`]+)`+'), (m) => m[1] ?? '');
  t = t.replaceAllMapped(
    RegExp(r'~~(.+?)~~', dotAll: true),
    (m) => m[1] ?? '',
  );
  // Trois sauts de ligne ou plus n'ont jamais de sens.
  t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return t.trim();
}

// ══ L'INDEX DES CHAPITRES ══════════════════════════════════════════════

/// Liste les chapitres marqués et rend celui qu'on touche.
Future<String?> ouvrirIndexChapitres(
  BuildContext context, {
  required List<MessageStocke> chapitres,
}) {
  OuroHaptics.light();
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _IndexChapitres(chapitres: chapitres),
  );
}

class _IndexChapitres extends StatelessWidget {
  const _IndexChapitres({required this.chapitres});
  final List<MessageStocke> chapitres;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.space3),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSheet),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space5,
                DesignTokens.space5,
                DesignTokens.space5,
                DesignTokens.space2,
              ),
              child: Text(
                l10n.amChapters,
                style: OuroTypography.title3.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (chapitres.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.space5,
                  0,
                  DesignTokens.space5,
                  DesignTokens.space6,
                ),
                child: Text(
                  l10n.amChaptersEmpty,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    bottom: DesignTokens.space4,
                  ),
                  itemCount: chapitres.length,
                  itemBuilder: (context, i) {
                    final m = chapitres[i];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        OuroHaptics.selection();
                        Navigator.pop(context, m.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space5,
                          vertical: DesignTokens.space3,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${i + 1}',
                              style: OuroTypography.footnote.copyWith(
                                color: OuroColors.tertiaryLabel,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.space3),
                            Expanded(
                              child: Text(
                                _resume(m.contenu),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: OuroTypography.subheadline.copyWith(
                                  color: OuroColors.label,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// La première ligne utile du message, sans balisage — c'est ce qui
  /// permet de reconnaître un chapitre d'un coup d'œil.
  static String _resume(String contenu) {
    final plat = enTextePlat(contenu);
    final ligne = plat
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    return ligne.length <= 90 ? ligne : '${ligne.substring(0, 90)}…';
  }
}
