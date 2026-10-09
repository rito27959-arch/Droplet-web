// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE TIROIR DE L'ASSISTANT — la colonne qui glisse depuis la gauche, avec
// le nom en haut, les destinations, les conversations épinglées, les
// récentes, et le bouton « Nouvelle session » en bas.
//
// ── POURQUOI UN TIROIR ET PAS UN ÉCRAN ────────────────────────────────
//
// Une liste de conversations sur son propre écran oblige à quitter celle
// qu'on lit pour en ouvrir une autre — et à y revenir par le bouton
// retour. Le tiroir garde la conversation derrière lui : on glisse, on
// choisit, on est ailleurs, sans jamais avoir « reculé ». C'est ce que
// font Claude, ChatGPT et Gemini, et c'est la seule forme qui tienne
// quand on passe son temps à sauter d'un fil à l'autre.
//
// `conversations_screen.dart` reste pour la recherche plein écran, où
// l'on a besoin de toute la hauteur.
//
// ── ⚠️ AUCUN BOUTON MORT ──────────────────────────────────────────────
//
// Le tiroir de Claude propose Projets, Code, Artéfacts et Tâches
// planifiées. Droplet n'a que les Artéfacts, la Mémoire et l'Aide — et
// c'est tout ce qui est affiché. Une rangée qui ouvre un écran « bientôt
// disponible » coûte plus cher qu'elle ne rapporte : c'est le signal
// exact qui fait dire d'une application qu'elle est amateur. Le jour où
// les projets existent, la rangée apparaîtra.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Où le tiroir peut emmener, en dehors d'une conversation.
enum DestinationAssistant { artefacts, memoire, reglages, aide, recherche }

class AssistantTiroir extends StatefulWidget {
  const AssistantTiroir({
    super.key,
    required this.store,
    required this.conversationCourante,
    required this.onOuvrir,
    required this.onNouvelle,
    required this.onDestination,
    required this.onMenuConversation,
    this.initiale = '?',
  });

  final ConversationsIaStore store;
  final String? conversationCourante;
  final void Function(String conversationId) onOuvrir;
  final VoidCallback onNouvelle;
  final void Function(DestinationAssistant) onDestination;
  final void Function(ConversationIa) onMenuConversation;

  /// La première lettre du pseudo, dans la pastille du bas.
  final String initiale;

  @override
  State<AssistantTiroir> createState() => _AssistantTiroirState();
}

class _AssistantTiroirState extends State<AssistantTiroir> {
  StreamSubscription<void>? _abonnement;
  List<ConversationIa> _liste = const [];

  @override
  void initState() {
    super.initState();
    _liste = widget.store.conversations();
    _abonnement = widget.store.changements.listen((_) {
      if (mounted) setState(() => _liste = widget.store.conversations());
    });
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final epinglees = [for (final c in _liste) if (c.epinglee) c];
    final recentes = [for (final c in _liste) if (!c.epinglee) c];

    return Drawer(
      backgroundColor: OuroColors.systemBackground,
      // ⚠️ PAS DE COIN ARRONDI À DROITE. Le tiroir de Claude est à ras
      // bord : arrondi, il laisse voir une lichette de la conversation
      // derrière, et l'œil la lit comme un défaut d'alignement.
      shape: const RoundedRectangleBorder(),
      width: MediaQuery.sizeOf(context).width * 0.86,
      child: SafeArea(
        child: Column(
          children: [
            _EnTete(
              onRecherche: () {
                OuroHaptics.selection();
                widget.onDestination(DestinationAssistant.recherche);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: DesignTokens.space4),
                children: [
                  _Destination(
                    icone: Icons.auto_awesome_mosaic_outlined,
                    libelle: l10n.trArtifacts,
                    onTap: () =>
                        widget.onDestination(DestinationAssistant.artefacts),
                  ),
                  _Destination(
                    icone: Icons.psychology_outlined,
                    libelle: l10n.trMemory,
                    onTap: () =>
                        widget.onDestination(DestinationAssistant.memoire),
                  ),
                  _Destination(
                    icone: Icons.tune_rounded,
                    libelle: l10n.raTitle,
                    onTap: () =>
                        widget.onDestination(DestinationAssistant.reglages),
                  ),
                  _Destination(
                    icone: Icons.help_outline_rounded,
                    libelle: l10n.trHelp,
                    onTap: () =>
                        widget.onDestination(DestinationAssistant.aide),
                  ),
                  const _Filet(),
                  if (epinglees.isNotEmpty) ...[
                    _Etiquette(l10n.cvPinned),
                    for (final c in epinglees) _ligne(c, l10n),
                  ],
                  if (recentes.isNotEmpty) ...[
                    _Etiquette(l10n.cvRecent),
                    for (final c in recentes) _ligne(c, l10n),
                  ],
                  if (_liste.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                      child: Text(
                        l10n.cvEmpty,
                        style: OuroTypography.footnote.copyWith(
                          color: OuroColors.secondaryLabel,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _PiedTiroir(
              initiale: widget.initiale,
              onNouvelle: () {
                OuroHaptics.light();
                widget.onNouvelle();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligne(ConversationIa c, AppLocalizations l10n) => _LigneTiroir(
        titre: c.titre.isNotEmpty
            ? c.titre
            : (c.apercu.isNotEmpty ? c.apercu : l10n.cvUntitled),
        active: c.id == widget.conversationCourante,
        onTap: () {
          OuroHaptics.selection();
          widget.onOuvrir(c.id);
        },
        onLongPress: () => widget.onMenuConversation(c),
      );
}

// ══ L'EN-TÊTE ═══════════════════════════════════════════════════════════

class _EnTete extends StatelessWidget {
  const _EnTete({required this.onRecherche});
  final VoidCallback onRecherche;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 14),
      child: Row(
        children: [
          // Le nom, en grand et en sérif : c'est la seule signature de
          // marque du tiroir, et elle vaut mieux qu'un logo qui
          // dupliquerait l'icône de l'application.
          Expanded(
            child: Text(
              l10n.trAssistant,
              style: OuroTypography.largeTitle.copyWith(
                color: OuroColors.label,
                fontSize: 30,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.cvSearchHint,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRecherche,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.search_rounded,
                  size: DesignTokens.iconXl,
                  color: OuroColors.label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ LES RANGÉES ═════════════════════════════════════════════════════════

class _Destination extends StatelessWidget {
  const _Destination({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          OuroHaptics.selection();
          onTap();
        },
        child: Padding(
          // 17 et non 13 : mesuré sur la référence, une rangée de
          // destination fait ~57 points de haut. Plus serré, les trois
          // entrées se lisent comme un bloc au lieu de trois choix.
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          child: Row(
            children: [
              Icon(icone, size: 23, color: OuroColors.secondaryLabel),
              const SizedBox(width: 20),
              Text(
                libelle,
                style: OuroTypography.body.copyWith(
                  color: OuroColors.label,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      );
}

class _LigneTiroir extends StatelessWidget {
  const _LigneTiroir({
    required this.titre,
    required this.active,
    required this.onTap,
    required this.onLongPress,
  });

  final String titre;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            // La conversation ouverte porte un fond, pas une couleur de
            // texte : le titre doit rester lisible, c'est le fond qui
            // signale.
            color: active ? OuroColors.tertiarySystemFill : null,
            borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 19,
                color: OuroColors.secondaryLabel,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.body.copyWith(
                    color: OuroColors.label,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette(this.texte);
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
        child: Text(
          texte,
          style: OuroTypography.subheadline.copyWith(
            color: OuroColors.secondaryLabel,
          ),
        ),
      );
}

class _Filet extends StatelessWidget {
  const _Filet();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: Container(height: 0.5, color: OuroColors.separator),
      );
}

// ══ LE PIED ═════════════════════════════════════════════════════════════

class _PiedTiroir extends StatelessWidget {
  const _PiedTiroir({required this.initiale, required this.onNouvelle});

  final String initiale;
  final VoidCallback onNouvelle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: OuroColors.systemBackground,
        border: Border(
          top: BorderSide(color: OuroColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: OuroColors.accentRempli,
            ),
            child: Text(
              initiale.isEmpty ? '?' : initiale.characters.first.toUpperCase(),
              style: OuroTypography.headline.copyWith(
                color: OuroColors.texteSurAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // ⚠️ LE BOUTON EST INVERSÉ, PAS EN ACCENT. Dans le tiroir, la
          // couleur d'accent sert déjà à marquer la conversation ouverte ;
          // un bouton de la même teinte entrerait en concurrence avec
          // elle. Le contraste maximal du fond inversé le fait ressortir
          // sans ajouter de couleur.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onNouvelle,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: OuroColors.label,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: DesignTokens.iconMd,
                    color: OuroColors.systemBackground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.cvNew,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.systemBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Le vide à droite équilibre la pastille de gauche : sans lui,
          // le bouton paraît décalé.
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}
