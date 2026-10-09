// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran « Nouveau message » : à qui veut-on écrire ?
//
// CE QUI A CHANGÉ : deux des trois raccourcis du haut ne faisaient
// RIEN (« Diffusion » et « Scanner QR » étaient des boutons vides,
// `onTap: () {}`). Un bouton qui ne réagit pas est pire qu'un bouton
// absent : on croit avoir mal appuyé, on recommence, et on finit par se
// demander si l'app est cassée. « Scanner QR » est maintenant branché
// sur le vrai scanner, et « Diffusion » a été retiré tant que la
// fonction n'existe pas.
//
// L'écran adopte par ailleurs la présentation du reste de l'app :
// grand titre repliable, liste groupée, mode clair comme sombre.
// ============================================================================

import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/models/mesh_message.dart';
import '../../core/services/mesh_transport_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import 'qr_scan_screen.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/services/avatar_service.dart';
import '../group/traitement_invitation.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Fermer sans jamais rester bloqué : s'il n'y a rien derrière cette page
  /// (ouverte en remplaçant la navigation), on revient à l'accueil.
  void _fermer() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/chats');
    }
  }

  /// Ouvre une conversation À LA PLACE de cette page : le retour ramène à
  /// l'accueil, pas à « Nouveau message ».
  void _ouvrir(String route) {
    OuroHaptics.selection();
    if (context.canPop()) {
      context.pushReplacement(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final peers = ref.watch(meshPeerListProvider);
    bool correspond(String nom) => _query.isEmpty || nom.toLowerCase().contains(_query);
    final filtered = peers.where((p) => correspond(p.pseudo)).toList();
    // ⚠️ PAS SEULEMENT LES GENS À PORTÉE. La page ne montrait que le mesh :
    // loin de tout le monde, elle était vide — même avec des contacts
    // joignables par Internet.
    final aPortee = {for (final p in peers) p.peerId};
    final moi = ref.read(meshRepositoryProvider).myId;
    final contacts = StorageService.getKnownPeers()
        .where((c) => c.peerId != moi && !aPortee.contains(c.peerId) && correspond(c.pseudo))
        .toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (sorti, _) {
        if (!sorti) context.go('/chats');
      },
      child: IosMagnifierOverlay(
      child: OuroLargeTitleScaffold(
      title: l10n.nmTitle,
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: OuroBarButton(
        icon: Icons.close_rounded,
        tooltip: l10n.actionClose,
        onPressed: _fermer,
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.screenMargin,
              0,
              DesignTokens.screenMargin,
              DesignTokens.space4,
            ),
            child: OuroCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  style: OuroTypography.body.copyWith(color: OuroColors.label),
                  cursorColor: OuroColors.accent,
                  magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.actionSearch,
                    hintStyle: OuroTypography.body
                        .copyWith(color: OuroColors.tertiaryLabel),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: OuroColors.tertiaryLabel,
                      size: DesignTokens.iconMd,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 34),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Raccourcis ────────────────────────────────────────────────
        // Deux entrées, toutes deux fonctionnelles. Elles disparaissent
        // dès qu'on tape une recherche : à ce moment-là, on cherche une
        // personne, pas une action.
        if (_query.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                0,
                DesignTokens.screenMargin,
                DesignTokens.space5,
              ),
              child: OuroListSection(
                children: [
                  OuroListRow(
                    icon: Icons.group_add_rounded,
                    iconColor: OuroColors.systemGreen,
                    title: l10n.nmNewGroup,
                    onTap: () => _ouvrir('/group/create'),
                  ),
                  OuroListRow(
                    icon: Icons.person_search_rounded,
                    iconColor: OuroColors.systemIndigo,
                    title: l10n.nmFindByPseudo,
                    onTap: () {
                      OuroHaptics.selection();
                      context.push('/discover');
                    },
                  ),
                  OuroListRow(
                    icon: Icons.person_add_alt_1_rounded,
                    iconColor: OuroColors.systemPink,
                    title: l10n.chatsInvitePerson,
                    onTap: () {
                      OuroHaptics.selection();
                      context.push('/inviter');
                    },
                  ),
                  OuroListRow(
                    icon: Icons.qr_code_scanner_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.nmScanCode,
                    subtitle: l10n.nmVerifyContactIdentity,
                    onTap: () async {
                      OuroHaptics.selection();
                      final brut = await Navigator.of(context).push<String>(
                        // Le scanner est un cran plus profond que la
                        // liste : il glisse depuis la droite, et le geste
                        // de retour au bord gauche le referme.
                        CupertinoPageRoute<String>(
                          builder: (_) => const QrScanScreen(),
                        ),
                      );
                      // Un code de groupe n'ouvre pas une discussion : il
                      // envoie une demande à qui l'a montré.
                      if (brut != null && context.mounted) {
                        await traiterInvitationGroupe(context, ref, brut);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

        if (filtered.isEmpty && contacts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: EmptyState(
                emoji: _query.isEmpty
                    ? Scenes.rechercheDePairs
                    : Scenes.aucunResultat,
                icon: _query.isEmpty
                    ? Icons.wifi_tethering_rounded
                    : Icons.person_search_rounded,
                title: _query.isEmpty
                    ? l10n.nmNoOneInRange
                    : l10n.nmNoResult,
                subtitle: _query.isEmpty
                    ? l10n.nmPeopleWillAppearHere
                    : null,
              ),
            ),
          )
        else ...[
          if (filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin,
                  0,
                  DesignTokens.screenMargin,
                  DesignTokens.space5,
                ),
                child: OuroListSection(
                  header: l10n.nmInRange,
                  separatorInset: 68,
                  children: [
                    for (final p in filtered)
                      _PeerPickRow(peer: p, onTap: () => _ouvrir('/chat/${p.peerId}')),
                  ],
                ),
              ),
            ),
          if (contacts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin,
                  0,
                  DesignTokens.screenMargin,
                  DesignTokens.space6,
                ),
                child: OuroListSection(
                  header: l10n.nmContacts,
                  separatorInset: 68,
                  children: [
                    for (final c in contacts)
                      _ContactPickRow(contact: c, onTap: () => _ouvrir('/chat/${c.peerId}')),
                  ],
                ),
              ),
            ),
        ],
      ],
      ),
    ),
    );
  }
}

/// Une personne qu'on peut choisir comme destinataire.
class _PeerPickRow extends StatefulWidget {
  const _PeerPickRow({required this.peer, required this.onTap});

  final ConnectedPeer peer;
  final VoidCallback onTap;

  @override
  State<_PeerPickRow> createState() => _PeerPickRowState();
}

class _PeerPickRowState extends State<_PeerPickRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.peer;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        color: _pressed
            ? OuroColors.systemFill
            : OuroColors.secondarySystemGroupedBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space4,
          vertical: DesignTokens.space3,
        ),
        child: Row(
          children: [
            PeerAvatar(pseudo: p.pseudo, radius: 20, online: true, imagePath: AvatarService.cheminPair(p.peerId)),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.pseudo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.hopCount == 0
                        ? l10n.nmDirectConnection
                        : l10n.nmViaRelays(p.hopCount),
                    style: OuroTypography.footnote
                        .copyWith(color: OuroColors.secondaryLabel),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: OuroColors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Un contact qui n'est pas à portée : joignable par Internet, ou en
/// attente de le recroiser.
class _ContactPickRow extends StatelessWidget {
  const _ContactPickRow({required this.contact, required this.onTap});

  final PeerRecord contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enLigne = isTorOnlyPeer(contact);
    return Material(
      color: OuroColors.secondarySystemGroupedBackground,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space4,
            vertical: DesignTokens.space3,
          ),
          child: Row(
            children: [
              PeerAvatar(
                pseudo: contact.pseudo,
                radius: 20,
                imagePath: AvatarService.cheminPair(contact.peerId),
              ),
              const SizedBox(width: DesignTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.pseudo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.body.copyWith(
                        color: OuroColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          enLigne ? Icons.public_rounded : Icons.wifi_tethering_off_rounded,
                          size: 13,
                          color: OuroColors.secondaryLabel,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          enLigne ? l10n.nmViaInternet : l10n.nmOutOfRange,
                          style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: OuroColors.tertiaryLabel),
            ],
          ),
        ),
      ),
    );
  }
}
