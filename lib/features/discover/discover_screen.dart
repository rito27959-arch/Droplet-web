import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/providers/tor_providers.dart';
import '../../core/services/directory_client.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/mesh_message.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/ouro_spinner.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  List<DirectoryContact> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final q = query.trim();
    if (q.length < 2) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final repo = ref.read(meshRepositoryProvider);
      final results = await repo.transport.searchDirectory(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
    }
  }

  void _sendMessageTo(DirectoryContact contact) {
    OuroHaptics.selection();

    StorageService.upsertPeer(PeerRecord(
      peerId: contact.peerId,
      pseudo: contact.pseudo,
      role: 'leaf',
      transports: ['tor'],
      platform: 'unknown',
      interestGroups: [],
      reliability: 1.0,
      lastSeen: DateTime.now(),
      totalMessagesExchanged: 0,
      publicKey: contact.publicKey,
      onionAddress: contact.onionAddress,
      verified: false,
    ));

    context.go('/chat/${contact.peerId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final torConnected = ref.watch(torConnectedProvider);

    return IosMagnifierOverlay(
      child: OuroLargeTitleScaffold(
        title: l10n.dvTitle,
        backgroundColor: OuroColors.systemGroupedBackground,
        leading: OuroBarButton(
          icon: Icons.close_rounded,
          tooltip: l10n.dvClose,
          onPressed: () => context.pop(),
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
                    autofocus: true,
                    style: OuroTypography.body.copyWith(color: OuroColors.label),
                    cursorColor: OuroColors.accent,
                    magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.dvSearchHint,
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

          if (!torConnected)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.screenMargin),
                child: OuroCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: OuroColors.systemOrange, size: 20),
                      const SizedBox(width: DesignTokens.space3),
                      Expanded(
                        child: Text(
                          l10n.dvEnableTorToSearch,
                          style: OuroTypography.footnote
                              .copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_isSearching)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OuroSpinner(color: OuroColors.accent),
                    const SizedBox(height: DesignTokens.space3),
                    Text(
                      l10n.dvSearching,
                      style: OuroTypography.footnote
                          .copyWith(color: OuroColors.tertiaryLabel),
                    ),
                  ],
                ),
              ),
            )
          else if (_hasSearched && !_isSearching && _results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: EmptyState(
                  icon: Icons.person_search_rounded,
                  title: l10n.dvNoResults,
                  subtitle: l10n.dvNoUserFound,
                ),
              ),
            )
          else if (_results.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin,
                  0,
                  DesignTokens.screenMargin,
                  DesignTokens.space6,
                ),
                child: OuroListSection(
                  header: l10n.dvResultsCount(_results.length),
                  separatorInset: 68,
                  children: [
                    for (final (i, contact) in _results.indexed)
                      _DirectoryContactRow(
                        contact: contact,
                        sendLabel: l10n.dvSend,
                        onSendMessage: () => _sendMessageTo(contact),
                      )
                          // Une légère cascade plutôt qu'un bloc qui
                          // apparaît d'un coup — chaque résultat se
                          // pose l'instant d'après le précédent, comme
                          // la grille de participants d'un appel de
                          // groupe (voir `group_call_screen.dart`).
                          .animate()
                          .fadeIn(
                            delay: (i * 40).ms,
                            duration: 260.ms,
                            curve: Curves.easeOut,
                          )
                          .slideY(begin: 0.08, curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DirectoryContactRow extends StatefulWidget {
  const _DirectoryContactRow({
    required this.contact,
    required this.sendLabel,
    required this.onSendMessage,
  });

  final DirectoryContact contact;
  final String sendLabel;
  final VoidCallback onSendMessage;

  @override
  State<_DirectoryContactRow> createState() => _DirectoryContactRowState();
}

class _DirectoryContactRowState extends State<_DirectoryContactRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;

    return GestureDetector(
      onTap: widget.onSendMessage,
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
            PeerAvatar(pseudo: c.pseudo, radius: 20, online: true),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.pseudo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Camouflé : l'adresse .onion ne mène à rien (aucun
                    // service caché) — le contact est joint par Internet.
                    AppLocalizations.of(context).chViaInternet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.footnote
                        .copyWith(color: OuroColors.tertiaryLabel),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space3,
                  vertical: DesignTokens.space1),
              decoration: BoxDecoration(
                color: OuroColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Text(
                widget.sendLabel,
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
