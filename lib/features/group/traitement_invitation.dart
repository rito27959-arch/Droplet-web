// ============================================================================
// CE QU'ON FAIT D'UN CODE DE GROUPE SCANNÉ
// ----------------------------------------------------------------------------
// Le code ne fait entrer personne : il déclenche une demande à
// l'administrateur qui l'a montré. Son appareil vérifie le jeton et ajoute
// le membre, ou ne fait rien. On le dit franchement à l'écran, pour que
// l'attente ne passe pas pour une panne.
// ============================================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/afficher_toast.dart';
import 'invitation_groupe.dart';

/// Rend `true` si le code était une invitation de groupe (traitée ou
/// refusée), `false` si c'était autre chose.
Future<bool> traiterInvitationGroupe(
  BuildContext context,
  WidgetRef ref,
  String brut,
) async {
  final invitation = InvitationGroupe.lire(brut);
  if (invitation == null) return false;

  final l10n = AppLocalizations.of(context);
  if (invitation.expiree) {
    afficherToast(context, l10n.giQrExpired, type: DropletToastType.warning);
    return true;
  }

  final repo = ref.read(meshRepositoryProvider);
  if (invitation.hote == repo.myId) return true;

  // Déjà dedans : inutile de demander quoi que ce soit.
  final groupe = StorageService.getGroup(invitation.groupId);
  if (groupe != null && groupe.isActiveMember(repo.myId)) {
    afficherToast(context, l10n.giQrAlreadyMember);
    return true;
  }

  // Sans la clé de celui qui invite, rien ne peut partir chiffré. On le dit
  // plutôt que de laisser croire que la demande est en route.
  if (!repo.clePubliqueConnue(invitation.hote)) {
    afficherToast(
      context,
      l10n.giQrNeedContact,
      type: DropletToastType.warning,
    );
    return true;
  }

  try {
    await repo.demanderRejoindreGroupe(
      hote: invitation.hote,
      groupId: invitation.groupId,
      jeton: invitation.jeton,
    );
    if (context.mounted) {
      afficherToast(context, l10n.giQrRequestSent(invitation.nom));
    }
  } catch (_) {
    if (context.mounted) {
      afficherToast(
        context,
        l10n.giQrRequestFailed,
        type: DropletToastType.error,
      );
    }
  }
  return true;
}
