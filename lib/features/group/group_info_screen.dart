// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran « Infos du groupe » — celui qu'on ouvre en touchant le nom d'un
// groupe. Ce fichier ne contient que les ACTIONS (renommer, photo,
// description, ajouter, retirer, rôles, demandes d'adhésion, appel,
// quitter) ; le dessin est dans `vue_infos_groupe.dart`, les permissions
// dans `reglages_groupe.dart`, et leur écran dans
// `parametres_groupe_screen.dart`.
//
// Toutes les actions sont de vraies fonctions de `mesh_repository.dart` :
// un changement local part ensuite aux autres membres par le maillage.
// ============================================================================

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/services/etat_internet.dart';
import 'reglages_groupe.dart';
import 'parametres_groupe_screen.dart';
import 'vue_infos_groupe.dart';
import '../../core/services/nom_pair.dart';
import '../../design_system/ouro_haptics.dart';
import 'invitation_groupe_screen.dart';
import 'stockage_groupe_screen.dart';
import '../notifications/notifs_conversation_screen.dart' show LigneNotifsConversation;
import '../../core/services/avatar_service.dart';
import '../../shared/widgets/afficher_toast.dart';

/// Page « Infos du groupe » : membres, administration, renommage.
class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.groupId});

  final String groupId;

  /// Ouvre une petite fenêtre pour taper un nouveau nom de groupe.
  /// Ecrire la description : elle part aussitot vers les autres membres.
  Future<void> _modifierDescription(
    BuildContext context,
    WidgetRef ref,
    ReglagesGroupe reglages,
  ) async {
    final l10n = AppLocalizations.of(context);
    final texte = await ouroPrompt(
      context,
      title: l10n.giDescription,
      initialValue: reglages.description,
      placeholder: l10n.giDescriptionHint,
      maxLength: 200,
    );
    if (texte == null || texte == reglages.description) return;
    ReglagesGroupes.definir(groupId, reglages.copier(description: texte));
    unawaited(ref.read(meshRepositoryProvider).diffuserReglagesGroupe(groupId));
  }

  /// Changer la photo du groupe.
  ///
  /// L'image est réduite comme les avatars personnels, enregistrée sur ce
  /// téléphone, puis le manifeste repart aux membres. Tant que l'image
  /// elle-même ne circule pas, les autres gardent l'avatar à initiales :
  /// c'est dit à l'écran plutôt que caché.
  Future<void> _changerPhoto(
    BuildContext context,
    WidgetRef ref,
    GroupInfo group,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Le même sélecteur que partout ailleurs dans l'app : pas de
    // dépendance de plus pour choisir une image.
    final resultat = await FilePicker.platform.pickFiles(type: FileType.image);
    final choisi = resultat?.files.single;
    if (choisi?.path == null) return;
    final octets = await File(choisi!.path!).readAsBytes();
    final chemin = await AvatarService.enregistrer(octets);
    if (chemin == null) {
      if (context.mounted) {
        afficherToast(context, l10n.giPhotoFailed, type: DropletToastType.error);
      }
      return;
    }
    await StorageService.upsertGroup(
      id: group.id,
      name: group.name,
      avatarUrl: chemin,
      createdBy: group.createdBy,
      createdAt: group.createdAt,
      updatedAt: DateTime.now(),
    );
    unawaited(ref.read(meshRepositoryProvider).diffuserReglagesGroupe(group.id));
    if (context.mounted) {
      OuroHaptics.light();
      afficherToast(context, l10n.giPhotoChanged);
    }
  }

  /// Le stockage du groupe : ce qui a été envoyé, par qui, et le poids.
  void _ouvrirStockage(BuildContext context, GroupInfo group) {
    OuroHaptics.selection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockageGroupeScreen(groupId: group.id, nom: group.name),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, String currentName) async {
    final l10n = AppLocalizations.of(context);
    final name = await ouroPrompt(
      context,
      title: l10n.giRenameGroup,
      initialValue: currentName,
      placeholder: l10n.gcGroupName,
      maxLength: 40,
    );
    if (name == null || name.isEmpty || name == currentName) return;
    try {
      await ref.read(meshRepositoryProvider).renameGroup(groupId: groupId, name: name);
    } catch (e) {
      if (!context.mounted) return;
      ref.read(toastProvider.notifier).show(l10n.giRenameFailed, type: DropletToastType.error);
    }
  }

  /// Propose la liste des pairs pas encore membres (connectés ou déjà
  /// rencontrés), et ajoute celui choisi au groupe (réservé aux
  /// administrateurs).
  Future<void> _addMember(BuildContext context, WidgetRef ref, GroupInfo group) async {
    final l10n = AppLocalizations.of(context);
    final peers = ref.read(meshPeerListProvider);
    final known = StorageService.getKnownPeers();
    final memberIds = group.activeMembers.map((m) => m.peerId).toSet();
    final byId = <String, String>{}; // peerId -> pseudo
    for (final p in peers) {
      if (!memberIds.contains(p.peerId)) byId[p.peerId] = p.pseudo;
    }
    for (final p in known) {
      if (!memberIds.contains(p.peerId)) byId.putIfAbsent(p.peerId, () => p.pseudo);
    }

    if (byId.isEmpty) {
      ref.read(toastProvider.notifier).show(l10n.giNoPeerToAdd, type: DropletToastType.warning);
      return;
    }

    // ⚠️ La seule feuille de l'app restée en Material : coins carrés,
    // fond opaque, pas de poignée. Toutes les autres sont des
    // `FrostedSheet` — coins largement arrondis, matériau translucide et
    // la petite barre grise de 36×5 qu'iOS pose en haut de ses feuilles
    // pour dire « ça se tire ».
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FrostedSheet(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.screenMargin,
          0,
          DesignTokens.screenMargin,
          DesignTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.space2),
              child: Text(
                l10n.giAddMemberHeader,
                style: OuroTypography.sectionHeader.copyWith(
                  color: OuroColors.secondaryLabel,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: byId.entries
                    .map((e) => OuroListRow(
                          leading: PeerAvatar(pseudo: e.value, radius: 16),
                          title: e.value,
                          onTap: () => context.pop(e.key),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    HapticFeedback.mediumImpact();
    try {
      await ref.read(meshRepositoryProvider).addGroupMember(groupId: groupId, peerId: selected);
    } catch (e) {
      if (!context.mounted) return;
      ref.read(toastProvider.notifier).show(AppLocalizations.of(context).giAddMemberFailed, type: DropletToastType.error);
    }
  }

  /// Demande confirmation puis retire un membre du groupe (réservé aux
  /// administrateurs) — il ne pourra plus lire les futurs messages.
  Future<void> _removeMember(BuildContext context, WidgetRef ref, String peerId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ouroConfirm(
      context,
      title: l10n.giRemoveMemberTitle,
      message: l10n.giRemoveMemberBody,
      confirmLabel: l10n.giRemove,
      destructive: true,
    );
    if (confirmed != true) return;
    HapticFeedback.mediumImpact();
    try {
      await ref.read(meshRepositoryProvider).removeGroupMember(groupId: groupId, peerId: peerId);
    } catch (e) {
      if (!context.mounted) return;
      ref.read(toastProvider.notifier).show(AppLocalizations.of(context).giRemoveMemberFailed, type: DropletToastType.error);
    }
  }

  /// Demande confirmation puis me fait quitter le groupe moi-même.
  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ouroConfirm(
      context,
      title: l10n.giLeaveGroupTitle,
      message: l10n.giLeaveGroupBody,
      confirmLabel: l10n.giLeave,
      destructive: true,
    );
    if (confirmed != true) return;
    HapticFeedback.heavyImpact();
    await ref.read(meshRepositoryProvider).leaveGroup(groupId);
    if (!context.mounted) return;
    context.go('/chats');
  }

  /// Démarre un appel de groupe avec les membres actuellement joignables
  /// en Wi-Fi local (max 3 autres personnes, voir la limite de
  /// `group_webrtc_call_service.dart`).
  Future<void> _startGroupCall(
    BuildContext context,
    WidgetRef ref,
    GroupInfo group,
    String myId,
    String Function(String peerId) pseudoFor,
  ) async {
    final callNotifier = ref.read(callProvider.notifier);
    final autres = group.activeMembers.map((m) => m.peerId).where((id) => id != myId).toList();
    final enWifiDirect = autres.where(callNotifier.canCallPeer).toList();
    // ⚠️ SANS INTERNET, SEULS LES VOISINS EN WI-FI DIRECT ÉTAIENT APPELABLES :
    // un groupe à distance restait « personne de joignable ». Dès qu'un membre
    // n'est pas à portée, l'appel passe par Internet pour tout le monde.
    final parInternet = enWifiDirect.length < autres.length && EtatInternet.disponible();
    final reachable = parInternet ? autres : enWifiDirect;

    if (reachable.isEmpty) {
      ref.read(toastProvider.notifier).show(
            AppLocalizations.of(context).giNoOneReachable,
            type: DropletToastType.warning,
          );
      return;
    }
    if (reachable.length + 1 > 4) {
      ref.read(toastProvider.notifier).show(
            AppLocalizations.of(context).giMax4Participants,
            type: DropletToastType.warning,
          );
    }
    final members = reachable.take(3).toList();

    await ref.read(groupCallProvider.notifier).startGroupCall(
          groupId: group.id,
          groupName: group.name,
          memberPeerIds: members,
          pseudoFor: pseudoFor,
          parInternet: parInternet,
        );
    if (!context.mounted) return;
    context.go('/group-call');
  }

  /// Toucher un membre, comme WhatsApp : écrire, appeler, voir ses infos —
  /// et pour un administrateur, changer son rôle ou le retirer.
  Future<void> _ficheMembre(BuildContext context, WidgetRef ref, GroupInfo group, String moi, GroupMemberRecord m, String nom) async {
    final l10n = AppLocalizations.of(context);
    final admin = group.isAdmin(moi);
    final choix = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(nom),
        actions: [
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(ctx, 'ecrire'), child: Text(l10n.vgMessage(nom))),
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(ctx, 'appeler'), child: Text(l10n.vgCallMember(nom))),
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(ctx, 'infos'), child: Text(l10n.vgViewInfo)),
          if (admin)
            CupertinoActionSheetAction(onPressed: () => Navigator.pop(ctx, 'admin'), child: Text(m.isAdmin ? l10n.giRemoveAdmin : l10n.giMakeAdmin)),
          if (admin)
            CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Navigator.pop(ctx, 'retirer'), child: Text(l10n.vgRemoveFromGroup(nom))),
        ],
        cancelButton: CupertinoActionSheetAction(isDefaultAction: true, onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
      ),
    );
    if (!context.mounted) return;
    switch (choix) {
      case 'ecrire':
        context.push('/chat/${m.peerId}');
      case 'appeler':
        context.push('/call/${m.peerId}');
      case 'infos':
        context.push('/chat/${m.peerId}/info');
      case 'admin':
        HapticFeedback.selectionClick();
        await ref.read(meshRepositoryProvider).changerRoleMembre(groupId: groupId, peerId: m.peerId, admin: !m.isAdmin);
      case 'retirer':
        await _removeMember(context, ref, m.peerId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupInfoProvider(groupId));
    final myId = ref.watch(meshRepositoryProvider).myId;
    final peers = ref.watch(meshPeerListProvider);
    final l10n = AppLocalizations.of(context);

    if (group == null) {
      return Scaffold(
        backgroundColor: OuroColors.systemGroupedBackground,
        body: Center(child: Text(l10n.giGroupNotFound, style: TextStyle(color: OuroColors.textTertiary))),
      );
    }

    String pseudoFor(String peerId) {
      for (final p in peers) {
        if (p.peerId == peerId) return p.pseudo;
      }
      if (peerId == myId) return StorageService.currentUser?.pseudo ?? l10n.vgYou;
      return nomDuPair(peerId, [StorageService.getPeerRecord(peerId)?.pseudo]);
    }

    bool onlineFor(String peerId) => peers.any((p) => p.peerId == peerId);

    return ListenableBuilder(
      listenable: Listenable.merge([ReglagesGroupes.revision, DemandesAdhesion.revision]),
      builder: (context, _) {
        final reglages = ReglagesGroupes.de(groupId);
        final infos = reglages.peutModifierInfos(group, myId);
        void refuse() => afficherToast(context, l10n.vgOnlyAdminsEdit, type: DropletToastType.warning);
        return VueInfosGroupe(
          retour: OuroBackButton(fallback: '/group/$groupId'),
          donnees: DonneesInfosGroupe(
            groupe: group,
            moi: myId,
            reglages: reglages,
            nom: pseudoFor,
            enLigne: onlineFor,
            photoMembre: (id) => id == myId ? AvatarService.chemin(StorageService.currentUser?.avatarUrl) : AvatarService.cheminPair(id),
            demandes: DemandesAdhesion.pour(groupId),
          ),
          ligneNotifs: LigneNotifsConversation(conversationId: groupId, nom: group.name, groupe: true),
          actions: ActionsInfosGroupe(
            changerPhoto: () => infos ? _changerPhoto(context, ref, group) : refuse(),
            renommer: () => infos ? _rename(context, ref, group.name) : refuse(),
            modifierDescription: () => infos ? _modifierDescription(context, ref, reglages) : refuse(),
            appeler: () => _startGroupCall(context, ref, group, myId, pseudoFor),
            ajouter: () => _addMember(context, ref, group),
            inviter: () => ouvrirCodeGroupe(context, groupId: groupId, nom: group.name, moi: myId),
            medias: () => _ouvrirStockage(context, group),
            importants: () => context.push('/starred'),
            parametres: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(builder: (_) => ParametresGroupeScreen(groupId: groupId)),
            ),
            membre: (m) => _ficheMembre(context, ref, group, myId, m, pseudoFor(m.peerId)),
            accepterDemande: (d) async {
              HapticFeedback.mediumImpact();
              try {
                await ref.read(meshRepositoryProvider).addGroupMember(groupId: groupId, peerId: d.peerId);
              } catch (_) {
                if (context.mounted) afficherToast(context, l10n.giAddMemberFailed, type: DropletToastType.error);
              }
            },
            refuserDemande: (d) {
              HapticFeedback.selectionClick();
              ref.read(meshRepositoryProvider).refuserDemandeAdhesion(groupId: groupId, peerId: d.peerId);
            },
            quitter: () => _leave(context, ref),
          ),
        );
      },
    );
  }
}

