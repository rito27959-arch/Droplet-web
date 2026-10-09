// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'onglet APPELS — la liste de qui on a appelé, qui nous a appelé, et
// qui on a raté.
//
// CE QUI A CHANGÉ : cet écran affichait un historique ENTIÈREMENT
// INVENTÉ. Il prenait la liste des pairs actuellement connectés et
// fabriquait une ligne d'appel pour chacun, avec une heure calculée à
// partir de sa position dans la liste (« il y a 3h », « il y a 6h »,
// « il y a 9h »…) et un sens d'appel décidé par la parité de l'indice.
// Aucun de ces appels n'avait eu lieu. Pire : la liste changeait à
// chaque fois que quelqu'un se connectait ou se déconnectait.
//
// Droplet enregistre désormais réellement ses appels (voir
// `CallLogEntry`, écrit par `CallNotifier` à la fin de chaque appel), et
// cet écran ne montre que ça. Quand il n'y a rien, il le dit.
//
// Le reste est un alignement sur le design du reste de l'app : grand
// titre repliable, listes groupées, couleurs qui suivent le mode clair
// ou sombre.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/services/avatar_service.dart';
import '../../shared/widgets/glissement_actions.dart';

/// Les deux filtres de la liste, comme dans Téléphone sur iOS.
enum _CallFilter { all, missed }

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  _CallFilter _filter = _CallFilter.all;

  @override
  Widget build(BuildContext context) {
    // Observé pour redessiner la liste quand un appel se termine : le
    // journal est écrit à ce moment-là.
    ref.watch(callProvider);
    final l10n = AppLocalizations.of(context);

    final all = StorageService.getCallLogs();
    final missedCount = all.where((c) => c.isMissedIncoming).length;
    final entries =
        _filter == _CallFilter.missed ? all.where((c) => c.isMissedIncoming).toList() : all;

    // Trois appels manqués du même contact le même jour, c'est UNE ligne
    // avec « (3) » — pas trois lignes identiques qui poussent le reste de
    // l'historique hors de l'écran. C'est ce que fait Téléphone sur iOS,
    // et ni WhatsApp ni Telegram ne le font.
    final groupes = <({CallLogEntry entree, int nombre})>[];
    for (final e in entries) {
      final avant = groupes.isEmpty ? null : groupes.last;
      final memeJour = avant != null &&
          avant.entree.startedAt.year == e.startedAt.year &&
          avant.entree.startedAt.month == e.startedAt.month &&
          avant.entree.startedAt.day == e.startedAt.day;
      if (avant != null &&
          memeJour &&
          avant.entree.peerId == e.peerId &&
          avant.entree.isMissedIncoming == e.isMissedIncoming) {
        groupes[groupes.length - 1] =
            (entree: avant.entree, nombre: avant.nombre + 1);
      } else {
        groupes.add((entree: e, nombre: 1));
      }
    }

    return OuroLargeTitleScaffold(
      title: l10n.callsTitle,
      subtitle: missedCount > 0 ? l10n.callsMissedCount(missedCount) : null,
      backgroundColor: OuroColors.systemGroupedBackground,
      actions: [
        OuroBarButton(
          icon: Icons.add_ic_call_rounded,
          tooltip: l10n.callsNew,
          onPressed: () {
            OuroHaptics.selection();
            // `push` et non `go` : `go` remplaçait toute la navigation, et la
            // page « Nouveau message » n'avait plus rien derrière elle — on ne
            // pouvait plus en sortir sans redémarrer l'application.
            context.push('/new-message');
          },
        ),
      ],
      slivers: [
        // ── Filtre Tous / Manqués ─────────────────────────────────────
        // Un vrai segmenté iOS plutôt que deux pastilles arrondies : le
        // segmenté dit visuellement « ce sont deux vues de la MÊME
        // liste », là où deux pastilles séparées ressemblent à deux
        // boutons indépendants.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.screenMargin,
              0,
              DesignTokens.screenMargin,
              DesignTokens.space4,
            ),
            child: _Segmented(
              selected: _filter,
              onChanged: (f) {
                OuroHaptics.selection();
                setState(() => _filter = f);
              },
            ),
          ),
        ),

        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: EmptyState(
                emoji: Scenes.aucunAppel,
                icon: Icons.phone_rounded,
                title: _filter == _CallFilter.missed
                    ? l10n.callsNoneMissed
                    : l10n.callsNone,
                subtitle: _filter == _CallFilter.missed
                    ? l10n.callsMissedEmptyBody
                    : l10n.callsEmptyBody,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                0,
                DesignTokens.screenMargin,
                DesignTokens.space6,
              ),
              child: OuroListSection(
                separatorInset: 68,
                footer: l10n.callsRetained200,
                children: [
                  for (final g in groupes)
                    _CallRow(
                      entry: g.entree,
                      nombre: g.nombre,
                      onSupprime: () => setState(() {}),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEGMENTÉ
// ─────────────────────────────────────────────────────────────

class _Segmented extends StatelessWidget {
  const _Segmented({required this.selected, required this.onChanged});

  final _CallFilter selected;
  final ValueChanged<_CallFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: OuroColors.tertiarySystemFill,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          _segment(context, _CallFilter.all, l10n.callsAll),
          _segment(context, _CallFilter.missed, l10n.callsMissed),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, _CallFilter filter, String label) {
    final active = filter == selected;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(filter),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          curve: DesignTokens.curveStandard,
          decoration: BoxDecoration(
            // La pastille active est une surface claire posée dans le
            // creux gris, comme sur iOS — pas un aplat de couleur vive.
            color: active
                ? OuroColors.secondarySystemGroupedBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: OuroTypography.footnote.copyWith(
              color: active ? OuroColors.label : OuroColors.secondaryLabel,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  UNE LIGNE D'APPEL
// ─────────────────────────────────────────────────────────────

class _CallRow extends StatefulWidget {
  const _CallRow({
    required this.entry,
    required this.onSupprime,
    this.nombre = 1,
  });

  final CallLogEntry entry;

  /// Prévient l'écran qu'une ligne a disparu, pour qu'il se redessine.
  final VoidCallback onSupprime;

  /// Combien d'appels d'affilée du même contact, ce jour-là.
  final int nombre;

  @override
  State<_CallRow> createState() => _CallRowState();
}

class _CallRowState extends State<_CallRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final missed = e.isMissedIncoming;

    return GlissementActions(
      fin: [
        ActionGlissee(
          icone: Icons.delete_outline_rounded,
          libelle: AppLocalizations.of(context).actionDelete,
          couleur: OuroColors.systemRed,
          onTap: () async {
            OuroHaptics.light();
            await StorageService.supprimerAppel(e.id);
            widget.onSupprime();
          },
        ),
      ],
      child: GestureDetector(
      // Taper la ligne ouvre la conversation ; le bouton téléphone à
      // droite rappelle. C'est la répartition de Téléphone sur iOS, et
      // elle évite de déclencher un appel par accident.
      onTap: () {
        OuroHaptics.selection();
        context.push('/chat/${e.peerId}');
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        color: _pressed
            ? OuroColors.systemFill
            : OuroColors.secondarySystemGroupedBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space4,
          vertical: DesignTokens.space3,
        ),
        child: Row(
          children: [
            PeerAvatar(pseudo: e.peerPseudo, radius: 20, imagePath: AvatarService.cheminPair(e.peerId)),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre > 1
                        ? '${e.peerPseudo}  (${widget.nombre})'
                        : e.peerPseudo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(
                      // Un appel manqué s'écrit en rouge, comme partout
                      // ailleurs — c'est la seule information de cet
                      // écran qui demande une action.
                      color: missed ? OuroColors.systemRed : OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        _iconFor(e),
                        size: 13,
                        color: missed
                            ? OuroColors.systemRed
                            : OuroColors.tertiaryLabel,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _detailFor(context, e),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.footnote
                              .copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space2),
            // Largeur fixe : « 16:45 », « hier » et « 22/09 » se calent
            // tous au même bord, sinon la colonne danse d'une ligne à
            // l'autre.
            SizedBox(
              width: 58,
              child: Text(
                _timeFor(context, e.startedAt),
                textAlign: TextAlign.end,
                maxLines: 1,
                style: OuroTypography.footnote
                    .copyWith(color: OuroColors.tertiaryLabel),
              ),
            ),
            const SizedBox(width: DesignTokens.space2),
            // Zone de rappel : 44 points de côté, le minimum en dessous
            // duquel une cible devient difficile à viser au pouce.
            // Le ⓘ d'iOS : le bouton vert rappelle, le « i » raconte —
            // ici il ouvre la discussion, où l'on retrouve le contact.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                OuroHaptics.selection();
                context.push('/chat/${e.peerId}');
              },
              child: SizedBox(
                width: 32,
                height: 44,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: OuroColors.accent,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                OuroHaptics.light();
                context.go('/call/${e.peerId}');
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.phone_rounded,
                  size: 20,
                  color: OuroColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  IconData _iconFor(CallLogEntry e) {
    if (e.outcome == CallOutcome.failed) return Icons.error_outline_rounded;
    if (e.outcome == CallOutcome.missed) {
      return e.direction == CallDirection.incoming
          ? Icons.call_missed_rounded
          : Icons.call_missed_outgoing_rounded;
    }
    return e.direction == CallDirection.incoming
        ? Icons.call_received_rounded
        : Icons.call_made_rounded;
  }

  String _detailFor(BuildContext context, CallLogEntry e) {
    final l10n = AppLocalizations.of(context);
    switch (e.outcome) {
      case CallOutcome.answered:
        final d = e.duration;
        final m = d.inMinutes;
        final s = d.inSeconds % 60;
        final length = m > 0 ? l10n.callsMinSec(m, s) : l10n.callsSecOnly(s);
        return e.direction == CallDirection.incoming
            ? '${l10n.callsIncoming} · $length'
            : '${l10n.callsOutgoing} · $length';
      case CallOutcome.missed:
        // Un appel sortant sans réponse dit aussi qu'il était sortant :
        // sinon neuf lignes affichent le même mot et la flèche reste le
        // seul indice.
        return e.direction == CallDirection.incoming
            ? l10n.callsMissedLabel
            : '${l10n.callsOutgoing} · ${l10n.callsNoAnswer}';
      case CallOutcome.failed:
        return l10n.callsConnectionFailed;
    }
  }

  /// « 14:32 » pour aujourd'hui, « hier », puis la date. Même logique que
  /// la liste des discussions, pour que les deux se lisent pareil.
  String _timeFor(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (sameDay) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == dt.year &&
        yesterday.month == dt.month &&
        yesterday.day == dt.day) {
      return AppLocalizations.of(context).callsYesterday;
    }
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}';
  }
}
