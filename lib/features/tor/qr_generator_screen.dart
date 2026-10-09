import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/services/qr_code_exchange.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_retour_ios.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen>
    with SingleTickerProviderStateMixin {
  String? _qrData;
  bool _loading = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  Future<void> _generateQr() async {
    try {
      final data = await QrCodeExchange.generateQrData();
      if (mounted) {
        setState(() {
          _qrData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyToClipboard() {
    if (_qrData == null) return;
    Clipboard.setData(ClipboardData(text: _qrData!));
    HapticFeedback.mediumImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = StorageService.currentUser;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // ── Navigation bar iOS ────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    OuroIconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        l10n.torMyQrCode,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Avatar card ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: OuroColors.secondarySystemGroupedBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Avatar with subtle glow
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                OuroColors.accentRempli,
                                OuroColors.accentRempli.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: OuroColors.accent.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (me?.pseudo ?? '—')[0].toUpperCase(),
                              style: OuroTypography.largeTitle.copyWith(
                                color: OuroColors.texteSurAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          me?.pseudo ?? '—',
                          style: OuroTypography.title2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.qgScanToConnect,
                          style: OuroTypography.subheadline.copyWith(
                            color: OuroColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 24),

                  // ── QR code card ─────────────────────────────
                  if (_loading)
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: OuroColors.secondarySystemGroupedBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: OuroSpinner()),
                    )
                  else if (_qrData != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 500.ms).scale(
                          begin: const Offset(0.95, 0.95),
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        ),

                  const SizedBox(height: 24),

                  // ── Copy button ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _copied
                          ? Container(
                              key: const ValueKey('copied'),
                              decoration: BoxDecoration(
                                color: OuroColors.systemGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.qgCopied,
                                  style: OuroTypography.body.copyWith(
                                    color: OuroColors.systemGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : OuroRetourIos(child: OutlinedButton.icon(
                              key: const ValueKey('copy'),
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: Text(l10n.qgCopyCode),
                              style: OutlinedButton.styleFrom(overlayColor: Colors.transparent, 
                                foregroundColor: OuroColors.accent,
                                side: BorderSide(
                                  color: OuroColors.separator,
                                  width: 0.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── How it works ─────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: OuroColors.secondarySystemGroupedBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: OuroColors.secondaryLabel,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.qgHowItWorks,
                              style: OuroTypography.subheadline.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _HowStep(
                          number: '1',
                          text: l10n.qgStep1,
                        ),
                        _HowStep(
                          number: '2',
                          text: l10n.qgStep2,
                        ),
                        _HowStep(
                          number: '3',
                          text: l10n.qgStep3,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: OuroColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: OuroTypography.caption1.copyWith(
                  color: OuroColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
