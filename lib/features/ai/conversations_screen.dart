// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA LISTE DES CONVERSATIONS DE L'ASSISTANT — épinglées d'abord, puis les
// plus récentes, avec la recherche dans tout l'historique.
//
// ── CE QU'ON A COPIÉ, ET CE QU'ON A REFUSÉ DE COPIER ──────────────────
//
// COPIÉ de Claude iOS : l'appui long sur une ligne pour renommer,
// épingler ou supprimer — pas de bouton « modifier » en haut qui fait
// entrer dans un mode. Copié aussi la recherche qui cherche DANS les
// messages, pas seulement dans les titres : personne ne se souvient du
// titre d'une conversation, tout le monde se souvient d'un mot qu'on y a
// écrit.
//
// ⚠️ REFUSÉ : le menu qui s'ouvre sur l'appui long AVANT que le doigt ne
// bouge. C'est ce que fait Claude, et ça empêche de sélectionner du
// texte — un défaut signalé par ses propres utilisateurs. Ici le menu
// n'existe que sur les LIGNES de la liste, où il n'y a rien à
// sélectionner ; dans une conversation, l'appui long laisse le texte
// tranquille.
//
// ── LE TITRE VIDE ─────────────────────────────────────────────────────
//
// Une conversation qui vient de naître n'a pas de titre : l'assistant
// n'a encore rien lu. Plutôt que d'afficher « Nouvelle conversation »
// dix fois de suite — ce qui rend la liste illisible exactement quand
// elle se remplit — on affiche la PREMIÈRE QUESTION posée. C'est ce que
// la personne reconnaîtra, et ça ne coûte aucun appel de modèle.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class ConversationsIaScreen extends StatefulWidget {
  const ConversationsIaScreen({
    super.key,
    required this.store,
    required this.onOuvrir,
    required this.onNouvelle,
  });

  final ConversationsIaStore store;

  /// Ouvre une conversation. Le second argument vise un message précis,
  /// quand on arrive depuis un résultat de recherche.
  final void Function(String conversationId, {String? messageId}) onOuvrir;
  final void Function(String conversationId) onNouvelle;

  @override
  State<ConversationsIaScreen> createState() => _ConversationsIaScreenState();
}

class _ConversationsIaScreenState extends State<ConversationsIaScreen> {
  final _recherche = TextEditingController();
  StreamSubscription<void>? _abonnement;

  List<ConversationIa> _liste = const [];
  List<ResultatRecherche> _resultats = const [];
  String _filtre = '';

  @override
  void initState() {
    super.initState();
    _recharger();
    _abonnement = widget.store.changements.listen((_) {
      if (mounted) _recharger();
    });
    _recherche.addListener(() {
      final t = _recherche.text.trim();
      if (t == _filtre) return;
      setState(() => _filtre = t);
      _recharger();
    });
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    _recherche.dispose();
    super.dispose();
  }

  void _recharger() {
    setState(() {
      _liste = widget.store.conversations();
      _resultats = _filtre.isEmpty
          ? const []
          : widget.store.chercher(_filtre);
    });
  }

  // ── Actions sur une ligne ─────────────────────────────────────────────

  Future<void> _menu(ConversationIa c) async {
    final l10n = AppLocalizations.of(context);
    OuroHaptics.light();
    final choix = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuConversation(epinglee: c.epinglee),
    );
    if (!mounted || choix == null) return;
    switch (choix) {
      case 'epingler':
        widget.store.epingler(c.id, epinglee: !c.epinglee);
      case 'renommer':
        final titre = await _demanderTitre(c);
        if (titre != null) widget.store.renommer(c.id, titre);
      case 'supprimer':
        final sur = await _confirmerSuppression(l10n);
        if (sur) widget.store.supprimerConversation(c.id);
    }
  }

  Future<String?> _demanderTitre(ConversationIa c) async {
    final l10n = AppLocalizations.of(context);
    final champ = TextEditingController(
      text: c.titre.isEmpty ? _libelle(c, l10n) : c.titre,
    );
    final titre = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OuroColors.secondarySystemGroupedBackground,
        title: Text(l10n.cvRename, style: OuroTypography.headline),
        content: TextField(
          controller: champ,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          style: OuroTypography.body.copyWith(color: OuroColors.label),
          decoration: InputDecoration(
            counterText: '',
            hintText: l10n.cvRenameHint,
            hintStyle: OuroTypography.body.copyWith(
              color: OuroColors.tertiaryLabel,
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, champ.text),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    champ.dispose();
    final t = titre?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  Future<bool> _confirmerSuppression(AppLocalizations l10n) async {
    // ⚠️ ON DEMANDE. Une conversation supprimée ne revient pas : il n'y a
    // pas de corbeille, et il n'y en aura pas — un assistant local ne
    // garde rien ailleurs d'où le récupérer.
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OuroColors.secondarySystemGroupedBackground,
        title: Text(l10n.cvDeleteTitle, style: OuroTypography.headline),
        content: Text(
          l10n.cvDeleteBody,
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
            child: Text(
              l10n.actionDelete,
              style: TextStyle(color: OuroColors.systemRed),
            ),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  // ── Affichage ─────────────────────────────────────────────────────────

  static String _libelle(ConversationIa c, AppLocalizations l10n) {
    if (c.titre.isNotEmpty) return c.titre;
    if (c.apercu.isNotEmpty) {
      return c.apercu.length <= 48
          ? c.apercu
          : '${c.apercu.substring(0, 48)}…';
    }
    return l10n.cvUntitled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enRecherche = _filtre.isNotEmpty;

    return OuroLargeTitleScaffold(
      title: l10n.cvTitle,
      leading: const OuroBackButton(),
      actions: [
        OuroBarButton(
          icon: Icons.add_circle_outline_rounded,
          tooltip: l10n.cvNew,
          onPressed: () {
            OuroHaptics.light();
            widget.onNouvelle(widget.store.creerConversation());
          },
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.screenMargin,
              0,
              DesignTokens.screenMargin,
              DesignTokens.space4,
            ),
            child: _ChampRecherche(controller: _recherche),
          ),
        ),
        if (enRecherche)
          ..._sliversRecherche(l10n)
        else
          ..._sliversListe(l10n),
        const SliverToBoxAdapter(
          child: SizedBox(height: DesignTokens.space16),
        ),
      ],
    );
  }

  List<Widget> _sliversListe(AppLocalizations l10n) {
    if (_liste.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _Vide(
            icone: Icons.forum_outlined,
            texte: l10n.cvEmpty,
          ),
        ),
      ];
    }
    final epinglees = [for (final c in _liste) if (c.epinglee) c];
    final autres = [for (final c in _liste) if (!c.epinglee) c];

    return [
      if (epinglees.isNotEmpty)
        SliverToBoxAdapter(
          child: _Section(
            titre: l10n.cvPinned,
            enfants: [for (final c in epinglees) _ligne(c, l10n)],
          ),
        ),
      if (autres.isNotEmpty)
        SliverToBoxAdapter(
          child: _Section(
            titre: epinglees.isEmpty ? null : l10n.cvRecent,
            enfants: [for (final c in autres) _ligne(c, l10n)],
          ),
        ),
    ];
  }

  Widget _ligne(ConversationIa c, AppLocalizations l10n) => _LigneConversation(
        titre: _libelle(c, l10n),
        apercu: c.apercu,
        date: c.majLe,
        epinglee: c.epinglee,
        onTap: () {
          OuroHaptics.selection();
          widget.onOuvrir(c.id);
        },
        onLongPress: () => _menu(c),
      );

  List<Widget> _sliversRecherche(AppLocalizations l10n) {
    if (_resultats.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _Vide(
            icone: Icons.search_off_rounded,
            texte: l10n.cvNoResult(_filtre),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            left: DesignTokens.screenMargin,
            bottom: DesignTokens.space2,
          ),
          child: Text(
            l10n.cvResults(_resultats.length),
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: _Section(
          enfants: [
            for (final r in _resultats)
              _LigneConversation(
                titre: _libelle(r.conversation, l10n),
                apercu: r.extrait,
                date: r.date,
                epinglee: false,
                onTap: () {
                  OuroHaptics.selection();
                  widget.onOuvrir(
                    r.conversation.id,
                    messageId: r.messageId,
                  );
                },
                onLongPress: () => _menu(r.conversation),
              ),
          ],
        ),
      ),
    ];
  }
}

// ══ MORCEAUX ════════════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  const _Section({this.titre, required this.enfants});
  final String? titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titre != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin + 4,
                  0,
                  DesignTokens.screenMargin,
                  6,
                ),
                child: Text(
                  titre!.toUpperCase(),
                  style: OuroTypography.caption1.copyWith(
                    color: OuroColors.secondaryLabel,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.screenMargin,
              ),
              child: OuroListSection(
                separatorInset: DesignTokens.screenMargin + 30,
                children: enfants,
              ),
            ),
          ],
        ),
      );
}

class _LigneConversation extends StatelessWidget {
  const _LigneConversation({
    required this.titre,
    required this.apercu,
    required this.date,
    required this.epinglee,
    required this.onTap,
    required this.onLongPress,
  });

  final String titre;
  final String apercu;
  final DateTime date;
  final bool epinglee;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.screenMargin,
          vertical: 11,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                epinglee
                    ? Icons.push_pin_rounded
                    : Icons.chat_bubble_outline_rounded,
                size: DesignTokens.iconSm,
                color: epinglee
                    ? OuroColors.accent
                    : OuroColors.tertiaryLabel,
              ),
            ),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.body.copyWith(
                            color: OuroColors.label,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space2),
                      Text(
                        _quand(context, date),
                        style: OuroTypography.caption1.copyWith(
                          color: OuroColors.tertiaryLabel,
                        ),
                      ),
                    ],
                  ),
                  if (apercu.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      apercu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// L'heure aujourd'hui, le jour cette semaine, la date au-delà — la
  /// règle de toutes les listes de messagerie, parce qu'elle donne
  /// l'information utile dans le moins de caractères possible.
  static String _quand(BuildContext context, DateTime d) {
    final l10n = AppLocalizations.of(context);
    final maintenant = DateTime.now();
    final jours = DateTime(maintenant.year, maintenant.month, maintenant.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (jours == 0) {
      return MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(d),
        alwaysUse24HourFormat:
            MediaQuery.alwaysUse24HourFormatOf(context),
      );
    }
    if (jours == 1) return l10n.cvYesterday;
    if (jours < 7) {
      return MaterialLocalizations.of(context).narrowWeekdays[d.weekday % 7];
    }
    return MaterialLocalizations.of(context).formatShortDate(d);
  }
}

class _ChampRecherche extends StatelessWidget {
  const _ChampRecherche({required this.controller});
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
            Icon(
              Icons.search_rounded,
              size: 17,
              color: OuroColors.secondaryLabel,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                style: OuroTypography.body.copyWith(color: OuroColors.label),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: l10n.cvSearchHint,
                  hintStyle: OuroTypography.body.copyWith(
                    color: OuroColors.tertiaryLabel,
                  ),
                ),
              ),
            ),
            if (valeur.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  OuroHaptics.selection();
                  controller.clear();
                },
                child: Icon(
                  Icons.cancel_rounded,
                  size: 17,
                  color: OuroColors.tertiaryLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuConversation extends StatelessWidget {
  const _MenuConversation({required this.epinglee});
  final bool epinglee;

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
                  icon: epinglee
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                  iconColor: OuroColors.accent,
                  title: epinglee ? l10n.cvUnpin : l10n.cvPin,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, 'epingler'),
                ),
                OuroListRow(
                  icon: Icons.drive_file_rename_outline_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.cvRename,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, 'renommer'),
                ),
                OuroListRow(
                  icon: Icons.delete_outline_rounded,
                  iconColor: OuroColors.systemRed,
                  title: l10n.actionDelete,
                  isDestructive: true,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, 'supprimer'),
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

class _Vide extends StatelessWidget {
  const _Vide({required this.icone, required this.texte});
  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(40, 48, 40, 24),
        child: Column(
          children: [
            Icon(icone, size: 40, color: OuroColors.tertiaryLabel),
            const SizedBox(height: DesignTokens.space3),
            Text(
              texte,
              textAlign: TextAlign.center,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}
