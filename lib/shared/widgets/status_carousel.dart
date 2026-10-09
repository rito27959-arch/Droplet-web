// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Le carousel horizontal de statuts en haut de la liste des conversations,
// comme dans WhatsApp : un anneau coloré autour de chaque avatar qui a
// un statut actif, avec "Mon statut" toujours en premier. Un tap ouvre
// le visionneuse de statut.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/avatar_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../features/status/status_pager_screen.dart';

/// Carousel horizontal de statuts — affiché en haut de la liste des
/// conversations, seulement quand il y a au moins un statut actif.
class StatusCarousel extends ConsumerWidget {
  const StatusCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(meshRepositoryProvider).myId;
    final allStatuses = StorageService.getActiveStatuses()
        .where((s) => !StorageService.isContactBlocked(s.authorId))
        .toList();
    if (allStatuses.isEmpty) return const SizedBox.shrink();

    // Grouper par auteur
    final byAuthor = <String, List<MeshStatusRecord>>{};
    for (final s in allStatuses) {
      byAuthor.putIfAbsent(s.authorId, () => []).add(s);
    }

    // Trier : moi en premier, puis par date du statut le plus récent
    final authors = byAuthor.keys.toList()
      ..sort((a, b) {
        if (a == myId) return -1;
        if (b == myId) return 1;
        final aLatest = byAuthor[a]!.last.createdAt;
        final bLatest = byAuthor[b]!.last.createdAt;
        return bLatest.compareTo(aLatest);
      });

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.screenMargin - 4,
        ),
        itemCount: authors.length,
        itemBuilder: (context, index) {
          final authorId = authors[index];
          final statuses = byAuthor[authorId]!;
          final pseudo = statuses.first.authorPseudo;
          final isMe = authorId == myId;
          final hasUnviewed = statuses.any((s) =>
              s.authorId != myId &&
              !StorageService.getStatusViewers(s.id)
                  .any((v) => v.viewerId == myId));

          return GestureDetector(
            onTap: () {
              OuroHaptics.selection();
              StatusPagerScreen.rectCarte = null;
              context.push('/status/$authorId');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Anneau de statut + avatar
                  _StatusRing(
                    published: true,
                    hasUnviewed: hasUnviewed,
                    child: PeerAvatar(
                      pseudo: pseudo,
                      radius: 24,
                      imagePath: isMe
                          ? StorageService.currentUser?.avatarUrl != null
                              ? AvatarService.chemin(
                                  StorageService.currentUser!.avatarUrl)
                              : null
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nom tronqué
                  SizedBox(
                    width: 64,
                    child: Text(
                      isMe ? 'Moi' : pseudo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: OuroTypography.caption2.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// L'anneau coloré autour de l'avatar — vert si non vu, gris si vu.
class _StatusRing extends StatelessWidget {
  const _StatusRing({
    required this.published,
    required this.hasUnviewed,
    required this.child,
  });

  final bool published;
  final bool hasUnviewed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!published) return child;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnviewed
            ? const LinearGradient(
                colors: [
                  Color(0xFF25D366),
                  Color(0xFF128C7E),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : LinearGradient(
                colors: [
                  OuroColors.systemGray4,
                  OuroColors.systemGray5,
                ],
              ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: OuroColors.systemBackground,
        ),
        child: child,
      ),
    );
  }
}
