// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CRÉER UN GROUPE — en deux temps, comme WhatsApp sur iPhone.
//
//   1. AJOUTER DES MEMBRES : une recherche, et les personnes en deux
//      listes (« à portée maintenant », « déjà rencontrées »), cochées
//      d'un toucher. Chaque personne choisie monte dans une bande en haut,
//      avec sa photo et son prénom ; la toucher la retire. « Suivant » ne
//      s'allume qu'avec au moins une personne.
//   2. NOUVEAU GROUPE : la photo (facultative), le nom (avec ce qu'il reste
//      de caractères), une description facultative, et le rappel de qui
//      sera dedans. « Créer » ne s'allume qu'avec un nom.
//
// Le passage d'une étape à l'autre glisse comme une page iOS, et revient
// en arrière sans rien perdre de ce qui a été choisi.
// ============================================================================


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_pressable.dart';
import '../../design_system/ouro_spinner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/avatar_picker_sheet.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';
import 'reglages_groupe.dart';

/// Une personne qu'on peut inviter.
class CandidatGroupe {
  const CandidatGroupe({required this.peerId, required this.pseudo, required this.enLigne, this.photo});
  final String peerId;
  final String pseudo;
  final bool enLigne;
  final String? photo;
}

/// L'écran branché sur le maillage.
class GroupCreateScreen extends ConsumerWidget {
  const GroupCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectes = ref.watch(meshPeerListProvider);
    final parId = <String, CandidatGroupe>{};
    for (final p in connectes) {
      parId[p.peerId] = CandidatGroupe(peerId: p.peerId, pseudo: p.pseudo, enLigne: true, photo: AvatarService.cheminPair(p.peerId));
    }
    for (final p in StorageService.getKnownPeers()) {
      parId.putIfAbsent(p.peerId, () => CandidatGroupe(peerId: p.peerId, pseudo: p.pseudo, enLigne: false, photo: AvatarService.cheminPair(p.peerId)));
    }
    final l10n = AppLocalizations.of(context);
    return VueCreationGroupe(
      candidats: parId.values.toList()..sort((a, b) => a.pseudo.toLowerCase().compareTo(b.pseudo.toLowerCase())),
      fermer: () => context.canPop() ? context.pop() : context.go('/chats'),
      choisirPhoto: () => choisirUnePhoto(context),
      creer: (nom, description, photo, ids) async {
        try {
          final repo = ref.read(meshRepositoryProvider);
          final groupId = await repo.createGroup(name: nom, memberIds: ids);
          if (description.isNotEmpty) {
            ReglagesGroupes.definir(groupId, ReglagesGroupes.de(groupId).copier(description: description));
          }
          if (photo != null) {
            final chemin = await AvatarService.enregistrer(photo);
            final g = StorageService.getGroup(groupId);
            if (chemin != null && g != null) {
              await StorageService.upsertGroup(
                id: g.id, name: g.name, avatarUrl: chemin,
                createdBy: g.createdBy, createdAt: g.createdAt, updatedAt: DateTime.now(),
              );
            }
          }
          if (description.isNotEmpty || photo != null) await repo.diffuserReglagesGroupe(groupId);
          if (context.mounted) context.go('/group/$groupId');
          return true;
        } catch (e) {
          ref.read(toastProvider.notifier).show(l10n.gcCreationFailed, type: DropletToastType.error);
          return false;
        }
      },
    );
  }
}

/// Le dessin et les deux étapes, sans le maillage (testable).
class VueCreationGroupe extends StatefulWidget {
  const VueCreationGroupe({
    super.key,
    required this.candidats,
    required this.creer,
    required this.fermer,
    required this.choisirPhoto,
    this.etapeInitiale = 0,
    this.selectionInitiale = const {},
    this.nomInitial = '',
  });

  final List<CandidatGroupe> candidats;
  final Future<bool> Function(String nom, String description, Uint8List? photo, Set<String> ids) creer;
  final VoidCallback fermer;
  final Future<Uint8List?> Function() choisirPhoto;

  @visibleForTesting
  final int etapeInitiale;
  @visibleForTesting
  final Set<String> selectionInitiale;
  @visibleForTesting
  final String nomInitial;

  @override
  State<VueCreationGroupe> createState() => _VueCreationGroupeState();
}

class _VueCreationGroupeState extends State<VueCreationGroupe> {
  late int _etape = widget.etapeInitiale;
  late final List<String> _choisis = [...widget.selectionInitiale];
  late final TextEditingController _nom = TextEditingController(text: widget.nomInitial);
  final TextEditingController _description = TextEditingController();
  String _requete = '';
  Uint8List? _photo;
  bool _occupe = false;
  bool _enAvant = true;

  static const int _maxNom = 40;

  @override
  void initState() {
    super.initState();
    _nom.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  CandidatGroupe? _candidat(String id) {
    for (final c in widget.candidats) {
      if (c.peerId == id) return c;
    }
    return null;
  }

  void _basculer(String id) {
    OuroHaptics.selection();
    setState(() => _choisis.contains(id) ? _choisis.remove(id) : _choisis.add(id));
  }

  void _allerA(int etape) {
    OuroHaptics.light();
    FocusScope.of(context).unfocus();
    setState(() {
      _enAvant = etape > _etape;
      _etape = etape;
    });
  }

  Future<void> _creer() async {
    final nom = _nom.text.trim();
    if (nom.isEmpty || _occupe) return;
    setState(() => _occupe = true);
    HapticFeedback.mediumImpact();
    final ok = await widget.creer(nom, _description.text.trim(), _photo, _choisis.toSet());
    if (!ok && mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final etape1 = _etape == 0;
    return _PoliceDroplet(child: Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemGroupedBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 96,
        leading: CupertinoButton(
          padding: const EdgeInsets.only(left: 16),
          alignment: Alignment.centerLeft,
          onPressed: _occupe ? null : (etape1 ? widget.fermer : () => _allerA(0)),
          child: etape1
              ? Text(l10n.actionCancel, style: TextStyle(fontSize: 17, color: OuroColors.accent))
              : Icon(CupertinoIcons.chevron_back, color: OuroColors.accent),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(etape1 ? l10n.vgAddMembers : l10n.gcNewGroup, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: OuroColors.label)),
            if (etape1)
              Text(l10n.gnCount('${_choisis.length}', '${widget.candidats.length}'), style: TextStyle(fontSize: 12, color: OuroColors.secondaryLabel)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: etape1
                ? CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: _choisis.isEmpty ? null : () => _allerA(1),
                    child: Text(l10n.gnNext, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _choisis.isEmpty ? OuroColors.tertiaryLabel : OuroColors.accent)),
                  )
                : CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: _nom.text.trim().isEmpty || _occupe ? null : _creer,
                    child: _occupe
                        ? SizedBox(width: 20, height: 20, child: OuroSpinner(radius: 9, color: OuroColors.accent))
                        : Text(l10n.gnCreate, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _nom.text.trim().isEmpty ? OuroColors.tertiaryLabel : OuroColors.accent)),
                  ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (enfant, a) {
          final entrant = enfant.key == ValueKey(_etape);
          final debut = Offset((entrant ? 1 : -0.3) * (_enAvant ? 1 : -1), 0);
          return SlideTransition(
            position: Tween(begin: debut, end: Offset.zero).animate(a),
            child: FadeTransition(opacity: a, child: enfant),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_etape),
          child: etape1 ? _membres(l10n) : _nommer(l10n),
        ),
      ),
    ));
  }

  // ── Étape 1 : les membres ────────────────────────────────────────

  Widget _membres(AppLocalizations l10n) {
    final filtres = _requete.isEmpty
        ? widget.candidats
        : [
            for (final c in widget.candidats)
              if (c.pseudo.toLowerCase().contains(_requete)) c,
          ];
    final proches = filtres.where((c) => c.enLigne).toList();
    final connus = filtres.where((c) => !c.enLigne).toList();
    if (widget.candidats.isEmpty) {
      return EmptyState(
        emoji: Scenes.aucunGroupe,
        icon: Icons.group_add_rounded,
        title: l10n.gcNoOneInRange,
        subtitle: l10n.gcGetCloserBody,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: CupertinoSearchTextField(
            placeholder: l10n.gnSearch,
            onChanged: (v) => setState(() => _requete = v.trim().toLowerCase()),
          ),
        ),
        // La bande des personnes choisies.
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: _choisis.isEmpty
              ? const SizedBox(width: double.infinity)
              : SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final id in _choisis)
                        if (_candidat(id) case final c?)
                          _Puce(key: ValueKey(id), candidat: c, onRetirer: () => _basculer(id)),
                    ],
                  ),
                ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              if (proches.isNotEmpty)
                OuroListSection(
                  header: l10n.gnNearby,
                  separatorInset: 104,
                  children: [for (final c in proches) _LigneCandidat(candidat: c, choisi: _choisis.contains(c.peerId), onTap: () => _basculer(c.peerId))],
                ),
              if (connus.isNotEmpty)
                OuroListSection(
                  header: l10n.gnKnown,
                  separatorInset: 104,
                  children: [for (final c in connus) _LigneCandidat(candidat: c, choisi: _choisis.contains(c.peerId), onTap: () => _basculer(c.peerId))],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Étape 2 : le nom ─────────────────────────────────────────────

  Widget _nommer(AppLocalizations l10n) {
    final reste = _maxNom - _nom.text.characters.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: OuroColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
          ),
          child: Row(
            children: [
              OuroPressable(
                onTap: () async {
                  final octets = await widget.choisirPhoto();
                  if (octets != null && mounted) setState(() => _photo = octets);
                },
                semantique: l10n.gnPhoto,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: OuroColors.tertiarySystemFill),
                  clipBehavior: Clip.antiAlias,
                  child: _photo != null
                      ? Image.memory(_photo!, fit: BoxFit.cover, cacheWidth: 200)
                      : Icon(CupertinoIcons.camera_fill, color: OuroColors.accent, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CupertinoTextField.borderless(
                  controller: _nom,
                  autofocus: widget.etapeInitiale == 0,
                  placeholder: l10n.gcGroupName,
                  maxLength: _maxNom,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OuroColors.label),
                  placeholderStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OuroColors.tertiaryLabel),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              Text('$reste', style: TextStyle(fontSize: 13, color: reste < 6 ? OuroColors.systemOrange : OuroColors.tertiaryLabel)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(l10n.gnNameFooter, style: TextStyle(fontSize: 13, color: OuroColors.secondaryLabel)),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: OuroColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
          ),
          child: CupertinoTextField.borderless(
            controller: _description,
            placeholder: l10n.gnDescription,
            maxLines: 4,
            minLines: 2,
            maxLength: 200,
            style: TextStyle(fontSize: 16, color: OuroColors.label),
            placeholderStyle: TextStyle(fontSize: 16, color: OuroColors.tertiaryLabel),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
          child: Text(l10n.giMemberCount(_choisis.length + 1).toUpperCase(), style: TextStyle(fontSize: 13, letterSpacing: 0.4, color: OuroColors.secondaryLabel)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 10,
          children: [
            for (final id in _choisis)
              if (_candidat(id) case final c?)
                SizedBox(
                  width: 70,
                  child: Column(
                    children: [
                      PeerAvatar(pseudo: c.pseudo, radius: 26, imagePath: c.photo),
                      const SizedBox(height: 5),
                      Text(c.pseudo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: OuroColors.secondaryLabel)),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

/// Une personne choisie, dans la bande du haut : la toucher la retire.
class _Puce extends StatelessWidget {
  const _Puce({super.key, required this.candidat, required this.onRetirer});
  final CandidatGroupe candidat;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, v, enfant) => Transform.scale(scale: v, child: enfant),
      child: GestureDetector(
        onTap: onRetirer,
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              const SizedBox(height: 6),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PeerAvatar(pseudo: candidat.pseudo, radius: 26, imagePath: candidat.photo),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.systemGray,
                        border: Border.all(color: OuroColors.systemGroupedBackground, width: 2),
                      ),
                      child: const Icon(CupertinoIcons.xmark, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(candidat.pseudo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: OuroColors.secondaryLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LigneCandidat extends StatelessWidget {
  const _LigneCandidat({required this.candidat, required this.choisi, required this.onTap});
  final CandidatGroupe candidat;
  final bool choisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListRow(
      title: candidat.pseudo,
      subtitle: candidat.enLigne ? l10n.gcConnected : l10n.gcAlreadyMet,
      showChevron: false,
      onTap: onTap,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: choisi ? OuroColors.accentRempli : Colors.transparent,
              border: Border.all(color: choisi ? OuroColors.accentRempli : OuroColors.tertiaryLabel, width: 1.5),
            ),
            child: choisi ? Icon(CupertinoIcons.checkmark, size: 14, color: OuroColors.texteSurAccent) : null,
          ),
          const SizedBox(width: 12),
          PeerAvatar(pseudo: candidat.pseudo, radius: 20, online: candidat.enLigne, imagePath: candidat.photo),
        ],
      ),
      trailing: const SizedBox.shrink(),
    );
  }
}

/// Les champs et boutons iOS (`Cupertino…`) prennent par défaut la police
/// d'Apple, absente d'Android : sans cela ils s'affichaient en Roboto au
/// milieu d'un écran en Inter. On leur donne la police de Droplet.
class _PoliceDroplet extends StatelessWidget {
  const _PoliceDroplet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = CupertinoTheme.of(context);
    const famille = TextStyle(fontFamily: 'Inter', letterSpacing: -0.2);
    return CupertinoTheme(
      data: base.copyWith(
        textTheme: base.textTheme.copyWith(
          textStyle: base.textTheme.textStyle.merge(famille),
          actionTextStyle: base.textTheme.actionTextStyle.merge(famille),
          navActionTextStyle: base.textTheme.navActionTextStyle.merge(famille),
        ),
      ),
      child: child,
    );
  }
}
