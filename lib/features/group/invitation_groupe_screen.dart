// ============================================================================
// LE CODE D'INVITATION D'UN GROUPE
// ----------------------------------------------------------------------------
// Une feuille iOS : le code au centre sur sa carte blanche, le nom du
// groupe, la durée de validité qui s'écoule, et deux gestes — partager le
// lien, ou tirer un nouveau code (l'ancien meurt à la seconde même).
//
// La phrase du bas n'est pas un détail : elle dit ce que le code donne, et
// surtout ce qu'il ne donne pas.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/afficher_toast.dart';
import 'invitation_groupe.dart';

Future<void> ouvrirCodeGroupe(
  BuildContext context, {
  required String groupId,
  required String nom,
  required String moi,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FeuilleCodeGroupe(groupId: groupId, nom: nom, moi: moi),
  );
}

class _FeuilleCodeGroupe extends StatefulWidget {
  const _FeuilleCodeGroupe({
    required this.groupId,
    required this.nom,
    required this.moi,
  });

  final String groupId;
  final String nom;
  final String moi;

  @override
  State<_FeuilleCodeGroupe> createState() => _FeuilleCodeGroupeState();
}

class _FeuilleCodeGroupeState extends State<_FeuilleCodeGroupe> {
  late InvitationGroupe _invitation = JetonsInvitation.courant(
    groupId: widget.groupId,
    nom: widget.nom,
    moi: widget.moi,
  );

  void _renouveler() {
    OuroHaptics.light();
    setState(() {
      _invitation = JetonsInvitation.renouveler(
        groupId: widget.groupId,
        nom: widget.nom,
        moi: widget.moi,
      );
    });
    afficherToast(context, AppLocalizations.of(context).giQrRenewed);
  }

  String _restant(AppLocalizations l10n) {
    final reste = _invitation.expireA.difference(DateTime.now());
    if (reste.isNegative) return l10n.giQrExpired;
    if (reste.inHours >= 1) return l10n.giQrValidHours(reste.inHours);
    return l10n.giQrValidMinutes(reste.inMinutes.clamp(1, 59));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: OuroColors.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: OuroColors.tertiaryLabel,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: OuroTypography.headline.copyWith(color: OuroColors.label),
          ),
          const SizedBox(height: 4),
          Text(
            _restant(l10n),
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 18),

          // Le code, sur sa carte blanche : un QR se lit toujours mieux sur
          // du blanc franc, même en thème sombre.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: _invitation.texte,
              size: 216,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _BoutonFeuille(
                  icone: Icons.ios_share_rounded,
                  libelle: l10n.nvShare,
                  onTap: () => Share.share(_invitation.texte),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BoutonFeuille(
                  icone: Icons.refresh_rounded,
                  libelle: l10n.giQrRenew,
                  onTap: _renouveler,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.giQrExplainer,
            textAlign: TextAlign.center,
            style: OuroTypography.caption1.copyWith(
              color: OuroColors.tertiaryLabel,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonFeuille extends StatelessWidget {
  const _BoutonFeuille({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 18, color: OuroColors.accent),
            const SizedBox(width: 8),
            Text(
              libelle,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
