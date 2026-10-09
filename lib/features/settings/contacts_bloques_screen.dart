// ============================================================================
// RÉGLAGES → CONTACTS BLOQUÉS — comme chez WhatsApp.
// ----------------------------------------------------------------------------
// La liste, un appui pour débloquer (avec confirmation), et en pied de liste
// ce que le blocage fait vraiment — y compris ce qu'il ne fait pas : le
// maillage continue de relayer les messages d'un contact bloqué destinés à
// d'autres, sans pouvoir les lire.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/blocage.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../core/services/avatar_service.dart';

class ContactsBloquesScreen extends StatelessWidget {
  const ContactsBloquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: StorageService.revisionBlocage,
      builder: (context, _, _) {
        final ids = StorageService.getBlockedContacts().toList()
          ..sort((a, b) => nomDuContact(a).toLowerCase().compareTo(nomDuContact(b).toLowerCase()));
        return OuroLargeTitleScaffold(
          title: l10n.blkListTitle,
          backgroundColor: OuroColors.systemGroupedBackground,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin,
                  DesignTokens.space3,
                  DesignTokens.screenMargin,
                  DesignTokens.space6,
                ),
                child: OuroListSection(
                  footer: l10n.blkFooter,
                  separatorInset: 60,
                  children: [
                    if (ids.isEmpty)
                      OuroListRow(title: l10n.blkNone, showChevron: false)
                    else
                      for (final id in ids)
                        OuroListRow(
                          leading: PeerAvatar(
                            pseudo: nomDuContact(id),
                            radius: 16,
                            imagePath: AvatarService.cheminPair(id),
                          ),
                          title: nomDuContact(id),
                          trailing: Text(
                            l10n.blkUnblock,
                            style: OuroTypography.body.copyWith(color: OuroColors.accent),
                          ),
                          showChevron: false,
                          onTap: () => proposerDeblocage(context, id),
                        ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
