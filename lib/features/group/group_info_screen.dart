// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est l'écran « Infos du groupe » — celui qu'on ouvre en tapant sur le
// nom d'un groupe. On y voit son nom (modifiable), la liste de tous ses
// membres avec une étoile « Administrateur » pour ceux qui gèrent le
// groupe, et selon qu'on est soi-même administrateur ou pas, la
// possibilité d'ajouter/retirer des membres. Il y a aussi un bouton pour
// démarrer un appel de groupe, et un bouton rouge tout en bas pour
// quitter le groupe.
//
// Toutes les actions ici (renommer, ajouter, retirer, quitter) sont de
// vraies fonctions de `mesh_repository.dart` — voir ce fichier pour
// comprendre comment un simple changement local se propage ensuite aux
// autres membres via le réseau mesh.
// ============================================================================

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';
import 'reglages_groupe.dart';
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

  /// Fermer ou rouvrir la parole. Le reglage voyage avec le manifeste.
  void _changerDroitEcriture(WidgetRef ref, ReglagesGroupe reglages, bool valeur) {
    OuroHaptics.selection();
    ReglagesGroupes.definir(groupId, reglages.copier(envoiAdminsSeuls: valeur));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupInfoProvider(groupId));
    final myId = ref.watch(meshRepositoryProvider).myId;
    final peers = ref.watch(meshPeerListProvider);
    final l10n = AppLocalizations.of(context);

    if (group == null) {
      return Scaffold(
        backgroundColor: OuroColors.background,
        body: Center(child: Text(l10n.giGroupNotFound, style: TextStyle(color: OuroColors.textTertiary))),
      );
    }

    final isAdmin = group.isAdmin(myId);
    final members = group.activeMembers
      ..sort((a, b) => a.role == b.role ? a.peerId.compareTo(b.peerId) : (a.role == 'admin' ? -1 : 1));

    String pseudoFor(String peerId) {
      for (final p in peers) {
        if (p.peerId == peerId) return p.pseudo;
      }
      for (final p in StorageService.getKnownPeers()) {
        if (p.peerId == peerId) return p.pseudo;
      }
      return peerId == myId ? l10n.giMe : peerId;
    }

    bool onlineFor(String peerId) => peers.any((p) => p.peerId == peerId);

    return Scaffold(
      backgroundColor: OuroColors.background,
      appBar: AppBar(
        backgroundColor: OuroColors.background,
        elevation: 0,
        title: Text(l10n.giGroupInfo,
            style: TextStyle(color: OuroColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: OuroBackButton(fallback: '/group/$groupId'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(DesignTokens.screenMargin, 8, DesignTokens.screenMargin, DesignTokens.space8),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isAdmin ? () => _changerPhoto(context, ref, group) : null,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PeerAvatar(
                        pseudo: group.name,
                        radius: 38,
                        imagePath: group.avatarUrl,
                      ),
                      // Le badge d'appareil photo, en bas à droite : le
                      // geste s'apprend sans notice.
                      if (isAdmin)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: OuroColors.accentRempli,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: OuroColors.systemGroupedBackground,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.photo_camera_rounded,
                              size: 14,
                              color: OuroColors.texteSurAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _rename(context, ref, group.name),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(group.name,
                          style: TextStyle(color: OuroColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(width: 6),
                      Icon(Icons.edit_rounded, size: 14, color: OuroColors.textTertiary),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(l10n.giMemberCount(members.length),
                    style: TextStyle(color: OuroColors.textTertiary, fontSize: 13)),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: OuroColors.successGreen),
                    SizedBox(width: 6),
                    Text(l10n.giEncryptedMessages, style: TextStyle(fontSize: 12, color: OuroColors.successGreen)),
                  ],
                ),
                const SizedBox(height: 16),
                OuroRetourIos(child: OutlinedButton.icon(
                  onPressed: () => _startGroupCall(context, ref, group, myId, pseudoFor),
                  style: OutlinedButton.styleFrom(overlayColor: Colors.transparent, 
                    foregroundColor: OuroColors.meshBlue,
                    side: BorderSide(color: OuroColors.meshBlue),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: Text(l10n.giGroupCall),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sourdine, mentions seulement, aperçu — pour ce groupe.
          LigneNotifsConversation(
            conversationId: groupId,
            nom: group.name,
            groupe: true,
          ),
          const SizedBox(height: 12),

          // Ce que le groupe raconte de lui-meme : les administrateurs
          // l'ecrivent, tout le monde le lit.
          ValueListenableBuilder<int>(
            valueListenable: ReglagesGroupes.revision,
            builder: (context, _, _) {
              final reglages = ReglagesGroupes.de(groupId);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CarteGroupe(
                    onTap: isAdmin
                        ? () => _modifierDescription(context, ref, reglages)
                        : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded, size: 19, color: OuroColors.textTertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.giDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: OuroColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                reglages.description.isEmpty
                                    ? (isAdmin ? l10n.giDescriptionAdd : l10n.giDescriptionNone)
                                    : reglages.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: reglages.description.isEmpty
                                      ? OuroColors.textTertiary
                                      : OuroColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.edit_rounded, size: 14, color: OuroColors.textTertiary),
                        ],
                      ],
                    ),
                  ),

                  // Qui peut ecrire. Le reglage voyage avec le manifeste :
                  // tous les membres l'apprennent, pas seulement celui qui
                  // l'a pose.
                  if (isAdmin || reglages.envoiAdminsSeuls) ...[
                    const SizedBox(height: 8),
                    _CarteGroupe(
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 19, color: OuroColors.textTertiary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.giOnlyAdminsSend,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OuroColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.giOnlyAdminsSendBody,
                                  style: TextStyle(fontSize: 12, color: OuroColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          if (isAdmin)
                            Switch.adaptive(
                              value: reglages.envoiAdminsSeuls,
                              onChanged: (v) => _changerDroitEcriture(ref, reglages, v),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 8),
          _CarteGroupe(
            onTap: () => _ouvrirStockage(context, group),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 19, color: OuroColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.sgTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OuroColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: OuroColors.textTertiary),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Text(l10n.gcMembers, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: OuroColors.textSecondary)),
              const Spacer(),
              if (isAdmin)
                OuroRetourIos(child: TextButton.icon(
                  onPressed: () => ouvrirCodeGroupe(
                    context,
                    groupId: groupId,
                    nom: group.name,
                    moi: myId,
                  ),
                  icon: Icon(Icons.qr_code_rounded, size: 18, color: OuroColors.meshBlueBright),
                  label: Text(l10n.giQrInvite, style: TextStyle(color: OuroColors.meshBlueBright)),
                )),
              if (isAdmin)
                OuroRetourIos(child: TextButton.icon(
                  onPressed: () => _addMember(context, ref, group),
                  icon: Icon(Icons.person_add_alt_1_rounded, size: 18, color: OuroColors.meshBlueBright),
                  label: Text(l10n.giAdd, style: TextStyle(color: OuroColors.meshBlueBright)),
                )),
            ],
          ),
          // Beaucoup de monde : on cherche plutôt que de faire défiler.
          _MembresFiltres(
            membres: members,
            pseudoDe: pseudoFor,
            hint: l10n.giSearchMembers,
            ligne: (m) {
              final i = members.indexOf(m);

            final pseudo = pseudoFor(m.peerId);
              return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: OuroColors.glassBg,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(color: OuroColors.glassBorder),
              ),
              child: ListTile(
                leading: PeerAvatar(
                  pseudo: pseudo,
                  radius: 20,
                  online: onlineFor(m.peerId),
                  imagePath: AvatarService.cheminPair(m.peerId),
                ),
                title: Text(m.peerId == myId ? '$pseudo (${l10n.giMe})' : pseudo,
                    style: TextStyle(color: OuroColors.textPrimary, fontWeight: FontWeight.w600)),
                subtitle: m.isAdmin
                    ? Text(l10n.giAdministrator, style: TextStyle(fontSize: 12, color: OuroColors.meshBlueBright))
                    : null,
                trailing: isAdmin && m.peerId != myId
                    ? OuroIconButton(
                        icon: Icon(Icons.remove_circle_outline_rounded, color: OuroColors.errorRed),
                        onPressed: () => _removeMember(context, ref, m.peerId),
                      )
                    : null,
              ),
            )
                .animate()
                .fadeIn(delay: (i * 40).ms, duration: DesignTokens.durationFast)
                .slideX(begin: 0.06);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OuroRetourIos(child: OutlinedButton.icon(
              onPressed: () => _leave(context, ref),
              style: OutlinedButton.styleFrom(overlayColor: Colors.transparent, 
                foregroundColor: OuroColors.errorRed,
                side: BorderSide(color: OuroColors.errorRed),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.giLeaveGroup),
            )),
          ),
        ],
      ),
    );
  }
}

/// La carte des reglages du groupe : meme verre que les lignes de membres.
class _CarteGroupe extends StatelessWidget {
  const _CarteGroupe({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: OuroColors.glassBg,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder),
        ),
        child: child,
      ),
    );
  }
}

/// La liste des membres, avec un champ de recherche dès qu'ils sont
/// nombreux. En dessous de huit, chercher n'a pas de sens : on voit tout.
class _MembresFiltres extends StatefulWidget {
  const _MembresFiltres({
    required this.membres,
    required this.pseudoDe,
    required this.ligne,
    required this.hint,
  });

  final List<GroupMemberRecord> membres;
  final String Function(String peerId) pseudoDe;
  final Widget Function(GroupMemberRecord membre) ligne;
  final String hint;

  @override
  State<_MembresFiltres> createState() => _MembresFiltresState();
}

class _MembresFiltresState extends State<_MembresFiltres> {
  final TextEditingController _recherche = TextEditingController();
  String _requete = '';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final montrerRecherche = widget.membres.length > 8;
    final filtres = _requete.isEmpty
        ? widget.membres
        : [
            for (final m in widget.membres)
              if (widget.pseudoDe(m.peerId).toLowerCase().contains(_requete)) m,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (montrerRecherche)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: OuroColors.glassBg,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(color: OuroColors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: OuroColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _recherche,
                      onChanged: (v) => setState(() => _requete = v.trim().toLowerCase()),
                      style: TextStyle(color: OuroColors.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: TextStyle(color: OuroColors.textTertiary, fontSize: 15),
                      ),
                    ),
                  ),
                  if (_requete.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _recherche.clear();
                        setState(() => _requete = '');
                      },
                      child: Icon(Icons.close_rounded, size: 17, color: OuroColors.textTertiary),
                    ),
                ],
              ),
            ),
          ),
        for (final m in filtres) widget.ligne(m),
      ],
    );
  }
}
