// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Sélecteur d'audience pour les statuts — control qui peut voir un statut.
//
// Trois options :
// - Tous mes contacts (défaut)
// - Sauf... (exclure des contacts spécifiques)
// - Uniquement... (inclure uniquement des contacts spécifiques)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mesh_message.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Niveaux de visibilité d'un statut.
enum StatusVisibility {
  /// Tous les contacts peuvent voir le statut.
  all,

  /// Tous les contacts SAUF ceux sélectionnés.
  except,

  /// Seuls les contacts sélectionnés peuvent voir le statut.
  only,
}

/// Données de sélection d'audience.
class AudienceSelection {
  const AudienceSelection({
    this.visibility = StatusVisibility.all,
    this.selectedPeerIds = const [],
  });

  final StatusVisibility visibility;
  final List<String> selectedPeerIds;

  bool get isDefault => visibility == StatusVisibility.all;

  AudienceSelection copyWith({
    StatusVisibility? visibility,
    List<String>? selectedPeerIds,
  }) {
    return AudienceSelection(
      visibility: visibility ?? this.visibility,
      selectedPeerIds: selectedPeerIds ?? this.selectedPeerIds,
    );
  }
}

/// Ouvre le sélecteur d'audience et retourne la sélection.
Future<AudienceSelection?> showAudienceSelector(
  BuildContext context, {
  AudienceSelection? current,
}) {
  return showModalBottomSheet<AudienceSelection>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AudienceSelectorSheet(current: current),
  );
}

class _AudienceSelectorSheet extends ConsumerStatefulWidget {
  const _AudienceSelectorSheet({this.current});

  final AudienceSelection? current;

  @override
  ConsumerState<_AudienceSelectorSheet> createState() =>
      _AudienceSelectorSheetState();
}

class _AudienceSelectorSheetState
    extends ConsumerState<_AudienceSelectorSheet> {
  late StatusVisibility _visibility;
  late Set<String> _selectedPeers;

  @override
  void initState() {
    super.initState();
    _visibility = widget.current?.visibility ?? StatusVisibility.all;
    _selectedPeers = Set.from(widget.current?.selectedPeerIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allPeers = StorageService.getKnownPeers();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Poignée
          Container(
            width: 36,
            height: 5,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: OuroColors.tertiaryLabel,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.asWhoCanSee,
                    style: OuroTypography.title3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OuroIconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Options de visibilité
          _VisibilityOption(
            icon: Icons.people_rounded,
            title: l10n.asAllContacts,
            subtitle: l10n.asContactsCount(allPeers.length),
            selected: _visibility == StatusVisibility.all,
            onTap: () => setState(() {
              _visibility = StatusVisibility.all;
              _selectedPeers.clear();
            }),
          ),
          _VisibilityOption(
            icon: Icons.people_outline_rounded,
            title: l10n.asExceptOption,
            subtitle: _visibility == StatusVisibility.except
                ? l10n.asExcludedCount(_selectedPeers.length)
                : l10n.asExcludeContacts,
            selected: _visibility == StatusVisibility.except,
            onTap: () => setState(() {
              _visibility = StatusVisibility.except;
            }),
          ),
          _VisibilityOption(
            icon: Icons.person_add_rounded,
            title: l10n.asOnlyOption,
            subtitle: _visibility == StatusVisibility.only
                ? l10n.asContactsCount(_selectedPeers.length)
                : l10n.asShareWithSpecific,
            selected: _visibility == StatusVisibility.only,
            onTap: () => setState(() {
              _visibility = StatusVisibility.only;
            }),
          ),

          // Liste des contacts (si Except ou Uniquement)
          if (_visibility != StatusVisibility.all) ...[
            const Divider(height: 1),
            Expanded(
              child: allPeers.isEmpty
                  ? Center(
                      child: Text(
                        l10n.asNoContactsAvailable,
                        style: OuroTypography.subheadline.copyWith(
                          color: OuroColors.secondaryLabel,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: allPeers.length,
                      itemBuilder: (_, i) {
                        final peer = allPeers[i];
                        final selected = _selectedPeers.contains(peer.peerId);
                        return _PeerRow(
                          peer: peer,
                          selected: selected,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedPeers.remove(peer.peerId);
                              } else {
                                _selectedPeers.add(peer.peerId);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],

          // Bouton Confirmer
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OuroRetourIos(child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(
                    context,
                    AudienceSelection(
                      visibility: _visibility,
                      selectedPeerIds: _selectedPeers.toList(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(overlayColor: Colors.transparent, 
                  backgroundColor: OuroColors.accentRempli,
                  foregroundColor: OuroColors.texteSurAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  ),
                ),
                child: Text(
                  l10n.asConfirm,
                  style: OuroTypography.body.copyWith(
                    color: OuroColors.texteSurAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? OuroColors.accent : OuroColors.secondaryLabel,
      ),
      title: Text(
        title,
        style: OuroTypography.body.copyWith(
          color: selected ? OuroColors.accent : OuroColors.label,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: OuroTypography.caption1.copyWith(
          color: OuroColors.secondaryLabel,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: OuroColors.accent)
          : Icon(Icons.circle_outlined, color: OuroColors.tertiaryLabel),
      onTap: onTap,
    );
  }
}

class _PeerRow extends StatelessWidget {
  const _PeerRow({
    required this.peer,
    required this.selected,
    required this.onTap,
  });

  final PeerRecord peer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PeerAvatar(
        pseudo: peer.pseudo,
        radius: 20,
      ),
      title: Text(
        peer.pseudo,
        style: OuroTypography.body.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? OuroColors.accent : OuroColors.tertiaryLabel,
      ),
      onTap: onTap,
    );
  }
}
