// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// « PARAMÈTRES DU GROUPE » — qui a le droit de faire quoi, comme dans
// WhatsApp :
//
//   LES MEMBRES PEUVENT :
//     • Modifier les infos du groupe (nom, photo, description)
//     • Envoyer des messages
//     • Ajouter d'autres membres
//   LES ADMINISTRATEURS PEUVENT :
//     • Approuver les nouveaux membres
//   • Modifier les administrateurs
//
// Seuls les administrateurs touchent à ces interrupteurs ; les autres
// voient les mêmes réglages, grisés, et une phrase qui dit pourquoi.
// Chaque changement part aussitôt dans le manifeste du groupe, et n'est
// accepté par les autres membres que s'il vient d'un administrateur.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/nom_pair.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import 'reglages_groupe.dart';

/// Le dessin, sans logique (testable).
class VueParametresGroupe extends StatelessWidget {
  const VueParametresGroupe({
    super.key,
    required this.reglages,
    required this.admin,
    required this.changer,
    required this.modifierAdmins,
    this.retour,
  });

  final ReglagesGroupe reglages;

  /// Suis-je administrateur ? Sinon, tout est en lecture seule.
  final bool admin;
  final void Function(ReglagesGroupe nouveaux) changer;
  final VoidCallback modifierAdmins;
  final Widget? retour;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget interrupteur(bool valeur, ReglagesGroupe Function(bool v) appliquer) => CupertinoSwitch(
          value: valeur,
          activeTrackColor: OuroColors.systemGreen,
          onChanged: admin
              ? (v) {
                  OuroHaptics.selection();
                  changer(appliquer(v));
                }
              : null,
        );
    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemGroupedBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: retour,
        centerTitle: true,
        title: Text(l10n.vgSettings, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: OuroColors.label)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          OuroListSection(
            header: l10n.vpMembersCan,
            footer: admin ? null : l10n.vpOnlyAdminsChange,
            children: [
              OuroListRow(
                title: l10n.vpEditInfo,
                subtitle: l10n.vpEditInfoBody,
                icon: CupertinoIcons.pencil,
                iconColor: OuroColors.systemOrange,
                trailing: interrupteur(!reglages.infosAdminsSeuls, (v) => reglages.copier(infosAdminsSeuls: !v)),
              ),
              OuroListRow(
                title: l10n.vpSend,
                icon: CupertinoIcons.chat_bubble_fill,
                iconColor: OuroColors.systemGreen,
                trailing: interrupteur(!reglages.envoiAdminsSeuls, (v) => reglages.copier(envoiAdminsSeuls: !v)),
              ),
              OuroListRow(
                title: l10n.vpAdd,
                icon: CupertinoIcons.person_add_solid,
                iconColor: const Color(0xFF0A84FF),
                trailing: interrupteur(!reglages.ajoutAdminsSeuls, (v) => reglages.copier(ajoutAdminsSeuls: !v)),
              ),
            ],
          ),
          OuroListSection(
            header: l10n.vpAdminsCan,
            footer: l10n.vpApproveBody,
            children: [
              OuroListRow(
                title: l10n.vpApprove,
                icon: CupertinoIcons.checkmark_shield_fill,
                iconColor: OuroColors.systemIndigo,
                trailing: interrupteur(reglages.approbation, (v) => reglages.copier(approbation: v)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          OuroListSection(
            footer: l10n.vpAdminsFooter,
            children: [
              OuroListRow(
                title: l10n.vpEditAdmins,
                icon: CupertinoIcons.star_circle_fill,
                iconColor: OuroColors.systemYellow,
                onTap: admin ? modifierAdmins : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// L'écran branché sur le groupe.
class ParametresGroupeScreen extends ConsumerWidget {
  const ParametresGroupeScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupe = ref.watch(groupInfoProvider(groupId));
    final moi = ref.watch(meshRepositoryProvider).myId;
    if (groupe == null) return const SizedBox.shrink();
    return ValueListenableBuilder<int>(
      valueListenable: ReglagesGroupes.revision,
      builder: (context, _, _) => VueParametresGroupe(
        reglages: ReglagesGroupes.de(groupId),
        admin: groupe.isAdmin(moi),
        retour: const BackButton(),
        changer: (nouveaux) {
          ReglagesGroupes.definir(groupId, nouveaux);
          ref.read(meshRepositoryProvider).diffuserReglagesGroupe(groupId);
        },
        modifierAdmins: () => Navigator.of(context).push(
          CupertinoPageRoute<void>(builder: (_) => AdministrateursGroupeScreen(groupId: groupId)),
        ),
      ),
    );
  }
}

/// « Modifier les administrateurs » : chaque membre, une coche.
class AdministrateursGroupeScreen extends ConsumerWidget {
  const AdministrateursGroupeScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupe = ref.watch(groupInfoProvider(groupId));
    final moi = ref.watch(meshRepositoryProvider).myId;
    if (groupe == null) return const SizedBox.shrink();
    final membres = groupe.activeMembers.where((m) => m.peerId != moi).toList()
      ..sort((a, b) => _nom(a).toLowerCase().compareTo(_nom(b).toLowerCase()));
    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemGroupedBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.vpEditAdmins, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: OuroColors.label)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          OuroListSection(
            footer: l10n.vpAdminsFooter,
            separatorInset: 64,
            children: [
              for (final m in membres)
                OuroListRow(
                  title: _nom(m),
                  leading: PeerAvatar(pseudo: _nom(m), radius: 18, imagePath: AvatarService.cheminPair(m.peerId)),
                  showChevron: false,
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: m.isAdmin
                        ? Icon(CupertinoIcons.checkmark_alt_circle_fill, key: const ValueKey(1), color: OuroColors.accent, size: 24)
                        : Icon(CupertinoIcons.circle, key: const ValueKey(0), color: OuroColors.tertiaryLabel, size: 24),
                  ),
                  onTap: () {
                    OuroHaptics.selection();
                    ref.read(meshRepositoryProvider).changerRoleMembre(groupId: groupId, peerId: m.peerId, admin: !m.isAdmin);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _nom(GroupMemberRecord m) => nomDuPair(m.peerId, [StorageService.getPeerRecord(m.peerId)?.pseudo]);
}
