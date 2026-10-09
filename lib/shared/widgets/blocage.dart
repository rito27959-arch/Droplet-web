// ============================================================================
// BLOQUER POUR DE VRAI — les pièces partagées.
// ----------------------------------------------------------------------------
// Le blocage était ENREGISTRÉ mais vérifié nulle part : un contact bloqué
// pouvait encore écrire, appeler, voir les statuts et la photo. Il est
// désormais appliqué à la source (voir `mesh_repository.dart`), et ces pièces
// servent l'interface : le nom d'un contact, la proposition de débloquer, et
// le bandeau qui remplace la saisie dans une discussion bloquée.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'afficher_toast.dart';

/// Le nom connu d'un contact, ou son identifiant à défaut.
String nomDuContact(String peerId) {
  for (final p in StorageService.getKnownPeers()) {
    if (p.peerId == peerId) return p.pseudo;
  }
  return peerId;
}

/// Propose de débloquer (alerte iOS) et débloque si l'utilisateur confirme.
/// Renvoie `true` quand le contact est débloqué.
Future<bool> proposerDeblocage(
  BuildContext context,
  String peerId, {
  bool pourAppeler = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final nom = nomDuContact(peerId);
  final ok = await ouroConfirm(
    context,
    title: pourAppeler ? l10n.blkUnblockToCall(nom) : l10n.blkUnblockTitle(nom),
    confirmLabel: l10n.blkUnblock,
    cancelLabel: l10n.actionCancel,
  );
  if (ok != true || !context.mounted) return false;
  await StorageService.setContactBlocked(peerId, false);
  if (context.mounted) {
    afficherToast(context, l10n.ciContactUnblocked(nom), type: DropletToastType.success);
  }
  return true;
}

/// Le bandeau de WhatsApp à la place de la saisie : on ne peut pas écrire à
/// un contact qu'on a bloqué, et on le dit au lieu de laisser un champ muet.
class BanniereContactBloque extends StatelessWidget {
  const BanniereContactBloque({super.key, required this.peerId});

  final String peerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        border: Border(top: BorderSide(color: OuroColors.separator, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.blkYouBlocked,
                textAlign: TextAlign.center,
                style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
              ),
              OuroRetourIos(
                child: TextButton(
                  onPressed: () => proposerDeblocage(context, peerId),
                  child: Text(l10n.blkUnblock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
