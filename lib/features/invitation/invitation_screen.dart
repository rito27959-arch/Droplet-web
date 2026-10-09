// ============================================================================
// L'ÉCRAN D'UNE INVITATION REÇUE — ouvert par `droplet://droplet/invite?d=…`.
// ----------------------------------------------------------------------------
// On montre QUI invite avant d'ajouter quoi que ce soit : un lien peut venir
// de n'importe où, l'ajout reste un geste de la personne invitée. « Ajouter et
// écrire » fait exactement ce que fait un QR code scanné
// (`QrCodeExchange.processScannedQr`), puis ouvre la conversation.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/invitation.dart';
import '../../core/services/qr_code_exchange.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';

class InvitationScreen extends ConsumerStatefulWidget {
  const InvitationScreen({super.key, required this.donnees});

  /// Le paramètre `d` du lien.
  final String? donnees;

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen> {
  late final String? _json = InvitationDroplet.extraire(widget.donnees);
  late final QrPeerData? _pair = _json == null ? null : QrPeerData.decode(_json);
  bool _occupe = false;

  Future<void> _ajouter() async {
    final json = _json;
    final pair = _pair;
    if (json == null || pair == null || _occupe) return;
    OuroHaptics.success();
    setState(() => _occupe = true);
    await QrCodeExchange.processScannedQr(json);
    if (mounted) context.go('/chat/${pair.peerId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pair = _pair;
    final soiMeme = pair != null && pair.peerId == StorageService.currentUser?.id;

    return Scaffold(
      backgroundColor: OuroColors.systemBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemBackground,
        elevation: 0,
        leading: OuroIconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: Icon(Icons.close_rounded, color: OuroColors.label),
          onPressed: () => context.go('/chats'),
        ),
        title: Text(l10n.invTitle, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.screenMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pair == null || soiMeme) ...[
                  Icon(Icons.link_off_rounded, size: 56, color: OuroColors.tertiaryLabel),
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    soiMeme ? l10n.invSelf : l10n.invInvalid,
                    textAlign: TextAlign.center,
                    style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel),
                  ),
                ] else ...[
                  PeerAvatar(pseudo: pair.pseudo, radius: 48),
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    pair.pseudo,
                    textAlign: TextAlign.center,
                    style: OuroTypography.title2.copyWith(color: OuroColors.label, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: DesignTokens.space2),
                  Text(
                    l10n.invBody(pair.pseudo),
                    textAlign: TextAlign.center,
                    style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel),
                  ),
                  const SizedBox(height: DesignTokens.space6),
                  SizedBox(
                    width: double.infinity,
                    child: OuroRetourIos(child: FilledButton.icon(
                      onPressed: _occupe ? null : _ajouter,
                      icon: const Icon(Icons.chat_bubble_rounded),
                      label: Text(l10n.invAdd),
                      style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
                        backgroundColor: OuroColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
