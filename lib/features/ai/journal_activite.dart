// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CE QUE L'ASSISTANT EST EN TRAIN DE FAIRE — montré pendant qu'il le fait,
// et relisible après coup.
//
// ── POURQUOI ÇA COMPTE PLUS QU'IL N'Y PARAÎT ──────────────────────────
//
// Dès qu'un assistant cherche sur le web, lit un fichier ou en produit
// un, il se passe plusieurs secondes pendant lesquelles l'écran ne montre
// rien. Ces secondes-là décident si la réponse sera crue : une réponse
// qui tombe d'un coup se discute, une réponse dont on a vu les étapes se
// vérifie. Toutes les grandes applications affichent donc ce déroulé.
//
// ── CE QUE LES AUTRES FONT MAL, ET QU'ON NE REFAIT PAS ────────────────
//
// Chez elles, le déroulé est ÉPHÉMÈRE : il s'efface une fois la réponse
// écrite. Trois jours plus tard, on relit « le marché pèse 4,2 milliards »
// sans plus aucun moyen de savoir d'où sort le chiffre. Ici les étapes
// sont enregistrées avec le message (`etapes` dans
// `conversations_ia_store.dart`) et se rouvrent indéfiniment.
//
// Deuxième différence : une étape qui ÉCHOUE reste affichée, barrée. Une
// recherche sans résultat explique une réponse vague bien mieux qu'une
// réponse vague toute seule.
//
// ── LA FORME ──────────────────────────────────────────────────────────
//
// Un repli, fermé par défaut une fois la réponse terminée, ouvert pendant
// qu'elle s'écrit. Une ligne par étape, avec un filet vertical qui les
// relie — c'est ce filet qui fait lire l'ensemble comme une suite et non
// comme une liste de puces.
// ============================================================================

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Le déroulé des étapes, sous une réponse.
class JournalActivite extends StatefulWidget {
  const JournalActivite({
    super.key,
    required this.etapes,
    this.enCours = false,
    this.etapeEnCours,
  });

  final List<EtapeActivite> etapes;

  /// Vrai tant que l'assistant travaille : le repli s'ouvre tout seul et
  /// la dernière ligne pulse.
  final bool enCours;

  /// Ce qu'il fait à l'instant, pas encore terminé — affiché en queue.
  final String? etapeEnCours;

  @override
  State<JournalActivite> createState() => _JournalActiviteState();
}

class _JournalActiviteState extends State<JournalActivite> {
  /// `null` = on suit l'état du travail ; sinon la personne a décidé.
  ///
  /// ⚠️ TROIS ÉTATS, PAS DEUX. Avec un simple booléen, le repli se
  /// refermait sous les doigts de quelqu'un qui venait de l'ouvrir, à la
  /// seconde où la réponse se terminait.
  bool? _choix;

  bool get _ouvert => _choix ?? widget.enCours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.etapes.isEmpty && widget.etapeEnCours == null) {
      return const SizedBox.shrink();
    }
    final n = widget.etapes.length;

    // ⚠️ UNE LIGNE DANS LE FIL, PAS UNE CARTE. Une carte grise au milieu
    // des messages attire l'œil plus que la réponse elle-même, alors
    // qu'elle n'est qu'un accessoire. Les grandes applications posent
    // cette information à plat, en gris, à la taille du texte courant :
    // on la voit si on la cherche, on l'oublie sinon.
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.space1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: _ouvert,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                OuroHaptics.selection();
                setState(() => _choix = !_ouvert);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    _Pastille(enCours: widget.enCours),
                    const SizedBox(width: DesignTokens.space2),
                    Expanded(
                      child: Text(
                        widget.enCours
                            ? (widget.etapeEnCours ?? l10n.jaWorking)
                            : l10n.jaSteps(n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.subheadline.copyWith(
                          color: OuroColors.secondaryLabel,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _ouvert ? 0.25 : 0,
                      duration: DesignTokens.durationFast,
                      curve: DesignTokens.curveEnter,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: DesignTokens.iconSm + 2,
                        color: OuroColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                2,
                DesignTokens.space1,
                0,
                DesignTokens.space3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < n; i++)
                    _LigneEtape(
                      etape: widget.etapes[i],
                      premiere: i == 0,
                      derniere: i == n - 1 && widget.etapeEnCours == null,
                    ),
                  if (widget.etapeEnCours != null)
                    _LigneEtape(
                      etape: EtapeActivite(
                        outil: '',
                        resume: widget.etapeEnCours!,
                      ),
                      premiere: n == 0,
                      derniere: true,
                      enCours: true,
                    ),
                ],
              ),
            ),
            crossFadeState: _ouvert
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: DesignTokens.durationFast,
            sizeCurve: DesignTokens.curveEnter,
          ),
        ],
      ),
    );
  }
}

/// Le point de tête : il respire tant que ça travaille, il se fige après.
class _Pastille extends StatefulWidget {
  const _Pastille({required this.enCours});
  final bool enCours;

  @override
  State<_Pastille> createState() => _PastilleState();
}

class _PastilleState extends State<_Pastille>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: DesignTokens.durationAmbient,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enCours) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _Pastille ancien) {
    super.didUpdateWidget(ancien);
    if (widget.enCours && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.enCours && _c.isAnimating) {
      _c.stop();
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ RESPECTE « RÉDUIRE LES ANIMATIONS ». Un point qui pulse sans fin
    // est exactement ce que ce réglage existe pour éteindre.
    final calme = MediaQuery.disableAnimationsOf(context);
    if (calme || !widget.enCours) {
      return Icon(
        widget.enCours
            ? Icons.more_horiz_rounded
            : Icons.check_circle_rounded,
        size: DesignTokens.iconSm,
        color: widget.enCours
            ? OuroColors.secondaryLabel
            : OuroColors.presenceMaintenant,
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.45 + 0.55 * _c.value,
        child: Icon(
          Icons.auto_awesome_rounded,
          size: DesignTokens.iconSm,
          color: OuroColors.accent,
        ),
      ),
    );
  }
}

/// Une étape : le filet, le point, le résumé, et son détail repliable.
class _LigneEtape extends StatefulWidget {
  const _LigneEtape({
    required this.etape,
    required this.premiere,
    required this.derniere,
    this.enCours = false,
  });

  final EtapeActivite etape;
  final bool premiere;
  final bool derniere;
  final bool enCours;

  @override
  State<_LigneEtape> createState() => _LigneEtapeState();
}

class _LigneEtapeState extends State<_LigneEtape> {
  bool _detailOuvert = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.etape;
    final aDetail = (e.detail ?? '').trim().isNotEmpty;
    final couleur = widget.enCours
        ? OuroColors.secondaryLabel
        : e.reussi
            ? OuroColors.label
            : OuroColors.systemRed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La gouttière : filet au-dessus, point, filet en dessous.
          SizedBox(
            width: 14,
            child: Column(
              children: [
                SizedBox(
                  height: 9,
                  child: widget.premiere
                      ? null
                      : Center(child: _Filet(hauteur: 9)),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.reussi
                        ? (widget.enCours
                            ? OuroColors.tertiaryLabel
                            : OuroColors.accent)
                        : OuroColors.systemRed,
                  ),
                ),
                if (!widget.derniere)
                  const Expanded(child: Center(child: _Filet())),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.space2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.space2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: aDetail
                        ? () {
                            OuroHaptics.selection();
                            setState(() => _detailOuvert = !_detailOuvert);
                          }
                        : null,
                    onLongPress: aDetail
                        ? () {
                            OuroHaptics.light();
                            Clipboard.setData(
                              ClipboardData(text: e.detail ?? ''),
                            );
                          }
                        : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            e.resume,
                            style: OuroTypography.footnote.copyWith(
                              color: couleur,
                              height: 1.35,
                              decoration: e.reussi
                                  ? null
                                  : TextDecoration.lineThrough,
                              decorationColor: OuroColors.systemRed,
                            ),
                          ),
                        ),
                        if (aDetail) ...[
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              _detailOuvert
                                  ? Icons.unfold_less_rounded
                                  : Icons.unfold_more_rounded,
                              size: DesignTokens.iconXs,
                              color: OuroColors.tertiaryLabel,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (aDetail && _detailOuvert)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(DesignTokens.space2),
                      decoration: BoxDecoration(
                        color: OuroColors.secondarySystemGroupedBackground,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSm,
                        ),
                      ),
                      child: Text(
                        e.detail!,
                        style: OuroTypography.caption1.copyWith(
                          color: OuroColors.secondaryLabel,
                          height: 1.4,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le trait qui relie deux étapes.
class _Filet extends StatelessWidget {
  const _Filet({this.hauteur});
  final double? hauteur;

  @override
  Widget build(BuildContext context) => Container(
        width: 1.5,
        height: hauteur,
        color: OuroColors.separator,
      );
}
