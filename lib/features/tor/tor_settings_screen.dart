// ============================================================================
// TOR SETTINGS — iOS-native design
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/tor_service.dart';
import '../../core/providers/tor_providers.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_spinner.dart';
import '../../shared/widgets/afficher_toast.dart';
import '../../design_system/ouro_retour_ios.dart';

class TorSettingsScreen extends ConsumerStatefulWidget {
  const TorSettingsScreen({super.key});

  @override
  ConsumerState<TorSettingsScreen> createState() => _TorSettingsScreenState();
}

class _TorSettingsScreenState extends ConsumerState<TorSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _generatingAddress = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..bouclerSiAmbiant(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleTor(bool enabled) async {
    final torService = ref.read(torServiceProvider);
    setState(() => _generatingAddress = true);
    HapticFeedback.mediumImpact();

    try {
      if (enabled) {
        await torService.start();
        // ⚠️ `start()` NE LÈVE PAS : il rattrape tout et bascule l'état en
        // `error`. Sans cette relecture, un échec de connexion était donc
        // parfaitement silencieux — l'interrupteur retombait, aucun
        // message, et l'utilisateur n'avait aucun moyen de savoir que le
        // réseau bloquait Tor. C'est le pendant du bandeau vert mensonger
        // corrigé dans `tor_service.dart`.
        if (torService.state == TorServiceState.error && mounted) {
          afficherToast(context, torService.lastError ??
                    AppLocalizations.of(context).torInactiveTitle, type: DropletToastType.error);
        }
      } else {
        await torService.stop();
      }
    } catch (e) {
      if (mounted) {
        afficherToast(context, AppLocalizations.of(context).torError('$e'), type: DropletToastType.error);
      }
    } finally {
      if (mounted) setState(() => _generatingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final torState = ref.watch(torStateProvider);
    final isConnected = torState.valueOrNull == TorServiceState.connected;
    final isConnecting = torState.valueOrNull == TorServiceState.connecting;
    final enErreur = torState.valueOrNull == TorServiceState.error;
    final isActive = isConnected || isConnecting;

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // ── Navigation bar iOS ────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    OuroIconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Tor',
                style: OuroTypography.largeTitle.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // ── Hero card minimaliste ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _MinimalHeroCard(
                isConnected: isConnected,
                isConnecting: isConnecting,
                pulseAnimation: _pulseController,
                l10n: l10n,
              ),
            ),
          ),

          // ── Toggle principal ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _iOSGroupedList(
                children: [
                  _iOSToggleRow(
                    icon: Icons.shield_rounded,
                    iconColor: isConnected ? Colors.green : OuroColors.systemGray,
                    title: l10n.torEnable,
                    subtitle: isActive ? l10n.torProtected : l10n.torDisabled,
                    value: isActive,
                    onChanged: _generatingAddress ? null : _toggleTor,
                    trailing: _generatingAddress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: OuroSpinner(radius: 10),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // ── Statut détaillé ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _iOSGroupedList(
                header: l10n.torStateHeader,
                children: [
                  // ⚠️ L'ÉCHEC A SON PROPRE AFFICHAGE. Avant, `error` et
                  // `stopped` se confondaient en un même « Inactif » : une
                  // connexion refusée par le réseau ressemblait exactement
                  // à un Tor jamais allumé, et la raison n'apparaissait
                  // nulle part.
                  _iOSInfoRow(
                    icon: enErreur
                        ? Icons.error_outline_rounded
                        : Icons.wifi_rounded,
                    iconColor: isConnected
                        ? Colors.green
                        : enErreur
                            ? OuroColors.systemRed
                            : Colors.amber,
                    title: l10n.torCircuit,
                    value: isConnected
                        ? l10n.torActive
                        : isConnecting
                            ? l10n.torInProgress
                            : enErreur
                                ? l10n.torFailed
                                : l10n.torInactive,
                  ),
                  if (enErreur &&
                      (ref.read(torServiceProvider).lastError ?? '').isNotEmpty)
                    _iOSInfoRow(
                      icon: Icons.info_outline_rounded,
                      iconColor: OuroColors.systemRed,
                      title: l10n.torReason,
                      value: ref.read(torServiceProvider).lastError!,
                    ),
                  _iOSInfoRow(
                    icon: Icons.lock_outline_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.torEncryption,
                    value: 'AES-256',
                  ),
                  _iOSInfoRow(
                    icon: Icons.speed_rounded,
                    iconColor: OuroColors.systemGray,
                    title: l10n.torLatency,
                    value: isConnected ? '10-30s' : '—',
                  ),
                ],
              ),
            ),
          ),

          // ── Actions contacts ──────────────────────────────────────
          if (isConnected)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _iOSGroupedList(
                  header: l10n.torContactsHeader,
                  footer: l10n.torScanQrFooter,
                  children: [
                    _iOSActionRow(
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.torScanQrCode,
                      onTap: () => context.push('/tor/scan'),
                    ),
                    _iOSActionRow(
                      icon: Icons.qr_code_2_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.torMyQrCode,
                      onTap: () => context.push('/tor/qr'),
                    ),
                    // Troisième façon de trouver quelqu'un — pas de QR
                    // code à échanger en direct, juste son pseudo. C'est
                    // le même annuaire que `DiscoverScreen` interroge
                    // déjà (`repo.transport.searchDirectory`) ; il ne lui
                    // manquait qu'un chemin pour y arriver depuis l'app.
                    _iOSActionRow(
                      icon: Icons.person_search_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.torSearchDirectory,
                      onTap: () => context.push('/discover'),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

          // ── Informations ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: _iOSGroupedList(
                header: l10n.torInformationHeader,
                children: [
                  _iOSInfoRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: OuroColors.systemGray,
                    title: l10n.torVersion,
                    value: 'Tor Arti (Rust)',
                  ),
                  _iOSActionRow(
                    icon: Icons.help_outline_rounded,
                    iconColor: OuroColors.systemGray,
                    title: l10n.torHowItWorks,
                    onTap: _showHowItWorks,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorks() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HowItWorksSheet(),
    );
  }
}

// ============================================================================
// MINIMAL HERO CARD — style iOS 26
// ============================================================================

class _MinimalHeroCard extends StatelessWidget {
  const _MinimalHeroCard({
    required this.isConnected,
    required this.isConnecting,
    required this.pulseAnimation,
    required this.l10n,
  });

  final bool isConnected;
  final bool isConnecting;
  final Animation<double> pulseAnimation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isActive = isConnected || isConnecting;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Bouclier animé
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, _) {
              final glow = isActive ? pulseAnimation.value * 0.3 : 0.0;
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? Colors.green.withValues(alpha: 0.15)
                      : isConnecting
                          ? Colors.amber.withValues(alpha: 0.15)
                          : OuroColors.systemGray5,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: (isConnected ? Colors.green : Colors.amber)
                                .withValues(alpha: glow),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isConnected
                      ? Icons.shield_rounded
                      : isConnecting
                          ? Icons.sync_rounded
                          : Icons.shield_outlined,
                  size: 28,
                  color: isConnected
                      ? Colors.green
                      : isConnecting
                          ? Colors.amber
                          : OuroColors.systemGray,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? l10n.torProtected
                      : isConnecting
                          ? l10n.torConnecting
                          : l10n.torInactiveTitle,
                  style: OuroTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected
                      ? l10n.torDataThroughTor
                      : isConnecting
                          ? l10n.torEstablishingCircuit
                          : l10n.torActivateToProtect,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}

// ============================================================================
// iOS-STYLE COMPONENTS
// ============================================================================

Widget _iOSGroupedList({
  String? header,
  String? footer,
  required List<Widget> children,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (header != null)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            header.toUpperCase(),
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
      Container(
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
      if (footer != null)
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Text(
            footer,
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.tertiaryLabel,
            ),
          ),
        ),
    ],
  );
}

Widget _iOSToggleRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required bool value,
  ValueChanged<bool>? onChanged,
  Widget? trailing,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: OuroTypography.body),
              Text(
                subtitle,
                style: OuroTypography.caption1.copyWith(
                  color: OuroColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          trailing
        else
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
      ],
    ),
  );
}

Widget _iOSActionRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required VoidCallback onTap,
  bool isLast = false,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: !isLast
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: OuroColors.separator,
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: OuroTypography.body),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: OuroColors.tertiaryLabel),
        ],
      ),
    ),
  );
}

Widget _iOSInfoRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: OuroTypography.body),
        ),
        Text(
          value,
          style: OuroTypography.subheadline.copyWith(
            color: OuroColors.secondaryLabel,
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// BOTTOM SHEET "COMMENT ÇA MARCHE"
// ============================================================================

class _HowItWorksSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          Container(
            width: 36,
            height: 5,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: OuroColors.tertiaryLabel,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.torHowItWorksTitle,
                  style: OuroTypography.title3.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                _HowStep(
                  icon: Icons.language_rounded,
                  color: OuroColors.accent,
                  title: l10n.torEncryptedCircuit,
                  description: l10n.torEncryptedCircuitDesc,
                ),
                _HowStep(
                  icon: Icons.visibility_off_rounded,
                  color: Colors.purple,
                  title: l10n.torHiddenIp,
                  description: l10n.torHiddenIpDesc,
                ),
                _HowStep(
                  icon: Icons.link_rounded,
                  color: Colors.green,
                  title: l10n.torMeshPreserved,
                  description: l10n.torMeshPreservedDesc,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OuroRetourIos(child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(overlayColor: Colors.transparent, 
                      backgroundColor: OuroColors.accentRempli,
                      foregroundColor: OuroColors.texteSurAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.torUnderstood),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OuroTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
