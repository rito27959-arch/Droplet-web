// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LOCAL OU EN LIGNE — le seul réglage que Droplet laisse VISIBLE dans la
// conversation, et la raison pour laquelle il y reste.
//
// ── POURQUOI GARDER UN SÉLECTEUR ALORS QUE LES GRANDS LES SUPPRIMENT ──
//
// Le 16 septembre 2026, Anthropic a fusionné ses deux interfaces et
// supprimé le sélecteur de recherche web, avec une raison publique :
// « les clients avaient du mal à choisir le bon onglet pour la bonne
// tâche ». C'est juste, et on l'applique — Droplet ne demandera JAMAIS
// s'il faut chercher sur le web, ni quel outil employer. Il décide.
//
// ⚠️ MAIS CELUI-CI N'EST PAS UN RÉGLAGE DE QUALITÉ. Il ne dit pas
// « réponds mieux », il dit OÙ VA VOTRE MESSAGE. En local, il ne quitte
// pas le téléphone ; en ligne, il part chez un tiers. Aucune heuristique
// ne peut trancher ça à la place de quelqu'un, parce que la bonne réponse
// dépend de ce qu'il y a dans le message — et ça, seule la personne qui
// l'écrit le sait.
//
// Le jour où l'on serait tenté de basculer automatiquement « quand le
// réseau est bon », relire ce paragraphe.
//
// ── LA FORME ──────────────────────────────────────────────────────────
//
// Une pastille discrète dans le composeur, comme le sélecteur de modèle
// de Claude et de ChatGPT — pas une barre d'onglets, qui donnerait à ce
// choix plus de poids visuel qu'à la question elle-même. Un appui ouvre
// une feuille qui explique les deux en une phrase chacun : c'est la
// seule façon de rendre un choix de confidentialité réellement éclairé.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/services/ai_assistant_service.dart' show kAiModelTailleMo;
import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// La pastille « Local » / « En ligne » posée dans le composeur.
class SelecteurMoteur extends StatelessWidget {
  const SelecteurMoteur({
    super.key,
    required this.moteur,
    required this.enLigneDisponible,
    required this.onChanger,
    this.localInstalle = true,
  });

  final OrigineReponse moteur;

  /// Faux quand aucune clé n'est configurée : la pastille reste visible
  /// mais mène à l'explication, au lieu de basculer dans le vide.
  final bool enLigneDisponible;

  /// Faux quand le modèle local n'est pas encore téléchargé.
  final bool localInstalle;
  final void Function(OrigineReponse) onChanger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enLigne = moteur == OrigineReponse.enLigne;

    return Semantics(
      button: true,
      label: enLigne ? l10n.moOnline : l10n.moLocal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ouvrirFeuille(
          context,
          moteur: moteur,
          enLigneDisponible: enLigneDisponible,
          localInstalle: localInstalle,
          onChanger: onChanger,
        ),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: OuroColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enLigne
                    ? Icons.cloud_outlined
                    : Icons.smartphone_rounded,
                size: DesignTokens.iconXs + 1,
                color: enLigne
                    ? OuroColors.accent
                    : OuroColors.secondaryLabel,
              ),
              const SizedBox(width: 5),
              Text(
                enLigne ? l10n.moOnline : l10n.moLocal,
                style: OuroTypography.caption1.copyWith(
                  color: enLigne
                      ? OuroColors.accent
                      : OuroColors.secondaryLabel,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.unfold_more_rounded,
                size: DesignTokens.iconXs,
                color: OuroColors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// La feuille de choix. Exposée pour que la proposition « refaire en
  /// ligne » puisse l'ouvrir au même endroit.
  static Future<void> ouvrirFeuille(
    BuildContext context, {
    required OrigineReponse moteur,
    required bool enLigneDisponible,
    required void Function(OrigineReponse) onChanger,
    bool localInstalle = true,
  }) async {
    OuroHaptics.light();
    final choix = await showModalBottomSheet<OrigineReponse>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FeuilleMoteur(
        moteur: moteur,
        enLigneDisponible: enLigneDisponible,
        localInstalle: localInstalle,
      ),
    );
    // ⚠️ ON PRÉVIENT MÊME QUAND LE CHOIX NE CHANGE RIEN. Sans clé, la
    // personne est DÉJÀ en ligne par défaut : filtrer ici sur « c'est
    // déjà le moteur courant » rendrait la ligne muette au moment précis
    // où elle doit emmener vers l'écran de configuration. C'est à
    // l'appelant de décider s'il y a quelque chose à faire.
    if (choix != null) onChanger(choix);
  }
}

class _FeuilleMoteur extends StatelessWidget {
  const _FeuilleMoteur({
    required this.moteur,
    required this.enLigneDisponible,
    required this.localInstalle,
  });

  final OrigineReponse moteur;
  final bool enLigneDisponible;
  final bool localInstalle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.space3),
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
                DesignTokens.space3,
              ),
              child: Text(
                l10n.moTitle,
                style: OuroTypography.title3.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _Option(
              icone: Icons.smartphone_rounded,
              titre: l10n.moLocal,
              // ⚠️ LE COÛT EST DIT AVANT LE DIALOGUE, pas seulement
              // dedans : on doit pouvoir décider de ne PAS toucher cette
              // ligne, plutôt que d'y toucher et de reculer.
              corps: localInstalle
                  ? l10n.moLocalBody
                  : l10n.moLocalToDownload(kAiModelTailleMo),
              choisie: moteur == OrigineReponse.local,
              onTap: () => Navigator.pop(context, OrigineReponse.local),
            ),
            _Option(
              icone: Icons.cloud_outlined,
              titre: l10n.moOnline,
              corps: enLigneDisponible
                  ? l10n.moOnlineBody
                  : l10n.moOnlineNoKey,
              choisie: moteur == OrigineReponse.enLigne,
              // ⚠️ LA LIGNE RESTE TOUCHABLE SANS CLÉ, et c'est tout le
              // correctif. Elle était grisée et morte, sous un texte qui
              // disait d'aller configurer ailleurs : on lisait une
              // consigne sous un bouton qui ne répondait pas. Maintenant
              // elle emmène droit à l'écran où l'on met la clé — c'est
              // `_changerMoteur` qui s'en charge, dans l'écran.
              onTap: () => Navigator.pop(context, OrigineReponse.enLigne),
            ),
            const SizedBox(height: DesignTokens.space4),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icone,
    required this.titre,
    required this.corps,
    required this.choisie,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String corps;
  final bool choisie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              OuroHaptics.selection();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space5,
          vertical: DesignTokens.space3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                icone,
                size: DesignTokens.iconLg,
                color: choisie
                    ? OuroColors.accent
                    : OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    corps,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.secondaryLabel,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (choisie) ...[
              const SizedBox(width: DesignTokens.space2),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_rounded,
                  size: DesignTokens.iconMd,
                  color: OuroColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La proposition affichée SOUS une réponse locale décevante : « refaire
/// en ligne ». C'est la seule bascule que Droplet suggère de lui-même, et
/// elle ne part jamais sans un appui.
class ProposerEnLigne extends StatelessWidget {
  const ProposerEnLigne({
    super.key,
    required this.onRefaire,
    this.raison,
  });

  final VoidCallback onRefaire;

  /// Pourquoi on propose : échec du modèle local, ou demande explicite.
  final String? raison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.space2),
      padding: const EdgeInsets.all(DesignTokens.space3),
      decoration: BoxDecoration(
        color: OuroColors.tertiarySystemFill,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: DesignTokens.iconMd,
            color: OuroColors.secondaryLabel,
          ),
          const SizedBox(width: DesignTokens.space2),
          Expanded(
            child: Text(
              raison ?? l10n.moRetryOnlineWhy,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space2),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              OuroHaptics.light();
              onRefaire();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Text(
                l10n.moRetryOnline,
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
