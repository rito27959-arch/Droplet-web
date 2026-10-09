// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA BULLE DE SONDAGE : la question, les options, et — dès qu'on a voté —
// la barre de progression de chacune.
//
// ── POURQUOI C'EST UN `ConsumerWidget` ALORS QUE `_MessageBubble` NE
//    L'EST PAS ────────────────────────────────────────────────────────
//
// `_MessageBubble` (dans `chat_screen.dart`) est un `StatelessWidget` —
// la changer en `ConsumerWidget` pour ce seul besoin aurait un rayon
// d'effet bien plus large que les sondages. Rien n'empêche en revanche
// qu'UNE feuille de son arbre le soit : cette bulle lit elle-même
// `pollVotesProvider` pour son propre compte, exactement comme
// `LocationBubble` ou `AnimatedStickerView` sont chacun leur propre
// widget autonome plutôt que des branches conditionnelles dans
// `_MessageBubble`.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/providers/poll_provider.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import 'poll_message.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../l10n/generated/app_localizations.dart';

class PollBubble extends ConsumerWidget {
  const PollBubble({
    super.key,
    required this.message,
    required this.poll,
    required this.mine,
  });

  final MeshMessage message;
  final PollMessage poll;

  /// Sur fond accent (mes propres messages) le texte est blanc ; sur le
  /// fond neutre des messages reçus, il reprend la couleur de label
  /// normale — même convention que `LocationBubble`.
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(meshRepositoryProvider).myId;
    final votes = ref.watch(pollVotesProvider);
    final counts = pollTally(votes, message.id, poll.options.length);
    final total = counts.fold<int>(0, (a, b) => a + b);
    final monVote = pollVoteOf(votes, message.id, myId);

    final onBubble = mine ? Colors.white : OuroColors.label;
    final surBulleAttenue = onBubble.withValues(alpha: 0.65);

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.poll_rounded, size: 18, color: surBulleAttenue),
              const SizedBox(width: DesignTokens.space2),
              Expanded(
                child: Text(
                  poll.question,
                  style: OuroTypography.body.copyWith(
                    color: onBubble,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space3),
          for (var i = 0; i < poll.options.length; i++) ...[
            _OptionRow(
              texte: poll.options[i],
              voix: counts[i],
              total: total,
              choisie: monVote == i,
              onBubble: onBubble,
              onTap: poll.termine
                  ? null
                  : () {
                OuroHaptics.selection();
                ref.read(pollVotesProvider.notifier).vote(
                      pollMessageId: message.id,
                      optionIndex: i,
                      // Groupe : `message.groupId` porte l'identifiant
                      // partagé. 1:1 : le destinataire du vote est
                      // TOUJOURS L'AUTRE PARTIE de la conversation, donc
                      // celui des deux (émetteur/cible du message
                      // ORIGINAL du sondage) qui n'est pas moi — même
                      // calcul que `conversationsProvider` pour retrouver
                      // « avec qui on parle ».
                      groupId: message.groupId,
                      peerId: message.groupId != null
                          ? null
                          : (message.senderId == myId
                              ? message.targetId
                              : message.senderId),
                    );
              },
            ),
            if (i < poll.options.length - 1)
              const SizedBox(height: DesignTokens.space1),
          ],
          // Jusqu'à quand on peut voter, ou que c'est fini.
          if (poll.fin != null) ...[
            const SizedBox(height: DesignTokens.space2),
            Text(
              poll.termine
                  ? AppLocalizations.of(context).pollClosed
                  : AppLocalizations.of(context).pollEndsAt(_heureFin(context, poll.fin!)),
              style: OuroTypography.caption1.copyWith(color: surBulleAttenue),
            ),
          ],
          const SizedBox(height: DesignTokens.space1),
          Text(
            total == 0
                ? 'Aucun vote pour l\'instant'
                : '$total vote${total > 1 ? 's' : ''}',
            style: OuroTypography.caption1.copyWith(color: surBulleAttenue),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.texte,
    required this.voix,
    required this.total,
    required this.choisie,
    required this.onBubble,
    required this.onTap,
  });

  final String texte;
  final int voix;
  final int total;
  final bool choisie;
  final Color onBubble;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final motion = OuroMotion.of(context);
    final proportion = total == 0 ? 0.0 : voix / total;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Stack(
          children: [
            // ── LE FOND, PUIS LA BARRE DE PROGRESSION PAR-DESSUS ──────
            //
            // Une seule surface, jamais deux couleurs concurrentes : le
            // fond marque l'étendue de l'option, la barre — de la même
            // teinte mais plus opaque — marque sa part des voix. Le
            // texte et le compte restent lisibles au-dessus des deux,
            // qu'on ait voté ou non.
            Container(
              color: onBubble.withValues(alpha: 0.10),
              width: double.infinity,
              height: 34,
            ),
            AnimatedFractionallySizedBox(
              duration: motion.duree(DesignTokens.durationFast),
              curve: motion.courbe(Curves.easeOutCubic),
              widthFactor: proportion,
              child: Container(
                color: onBubble.withValues(alpha: choisie ? 0.28 : 0.16),
                height: 34,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2),
                child: Row(
                  children: [
                    if (choisie) ...[
                      Icon(Icons.check_circle_rounded, size: 15, color: onBubble),
                      const SizedBox(width: DesignTokens.space1),
                    ],
                    Expanded(
                      child: Text(
                        texte,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.footnote.copyWith(
                          color: onBubble,
                          fontWeight: choisie ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (total > 0)
                      Text(
                        '${(proportion * 100).round()}%',
                        style: OuroTypography.caption1.copyWith(
                          color: onBubble.withValues(alpha: 0.75),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// « 18:40 » aujourd'hui, « 24 sept. 18:40 » un autre jour — dans la langue
/// de l'app.
String _heureFin(BuildContext context, DateTime fin) {
  final langue = Localizations.localeOf(context).toLanguageTag();
  final maintenant = DateTime.now();
  final memeJour = fin.year == maintenant.year &&
      fin.month == maintenant.month &&
      fin.day == maintenant.day;
  return memeJour
      ? DateFormat.Hm(langue).format(fin)
      : '${DateFormat.MMMd(langue).format(fin)} ${DateFormat.Hm(langue).format(fin)}';
}
