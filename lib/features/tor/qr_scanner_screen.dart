import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/services/qr_code_exchange.dart';
import '../../core/providers/tor_providers.dart';
import '../../core/providers/mesh_provider.dart' show toastProvider, DropletToastType;
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../../core/services/avatar_service.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _processed = false;
  QrPeerData? _scannedPeer;

  // Anti-spam pour le retour « code invalide » : `onDetect` se déclenche
  // à chaque image de la caméra où un code-barres traîne dans le cadre,
  // pas une seule fois — sans ce garde-fou, pointer la caméra vers un
  // QR code de supermarché déclencherait un toast plusieurs fois par
  // seconde.
  DateTime? _dernierRetourInvalide;

  // ── Lamination effect ──
  late AnimationController _scanLineController;
  late AnimationController _successController;
  late AnimationController _successHideController;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..bouclerSiAmbiant();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Le gros rond vert n'a besoin d'exister QUE le temps de faire
    // comprendre « c'est bon » — ensuite, la carte du pair en bas de
    // l'écran porte elle-même son propre repère de succès (voir
    // `_buildSuccessPanel`), et le laisser posé indéfiniment au centre
    // d'un écran devenu noir n'ajoute plus rien, seulement de
    // l'attention qu'il vole à la carte.
    _successHideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _successScale = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _successOpacity = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _successController.dispose();
    _successHideController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processed) return;

    var unCodeVu = false;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      unCodeVu = true;
      if (!QrCodeExchange.isDropletOnionQr(raw)) continue;

      final peerData = QrPeerData.decode(raw);
      if (peerData == null) continue;

      _processed = true;
      _scannerController?.stop();
      QrCodeExchange.processScannedQr(raw);

      HapticFeedback.heavyImpact();
      setState(() => _scannedPeer = peerData);
      _scanLineController.stop();
      _successController.forward().whenComplete(() {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) _successHideController.forward();
        });
      });
      // Un code valide met fin à la détection tout de suite : pas de
      // retour « invalide » à ajouter par-dessus une réussite.
      return;
    }

    // Un code-barres était bien dans le cadre, mais ce n'est pas un code
    // Droplet (un QR de site web, un ticket de caisse...) : dire pourquoi
    // rien ne se passe, plutôt que laisser deviner si la caméra a même vu
    // quelque chose.
    if (unCodeVu) _signalerCodeInvalide();
  }

  void _signalerCodeInvalide() {
    final maintenant = DateTime.now();
    if (_dernierRetourInvalide != null &&
        maintenant.difference(_dernierRetourInvalide!) <
            const Duration(seconds: 2)) {
      return;
    }
    _dernierRetourInvalide = maintenant;
    HapticFeedback.lightImpact();
    ref.read(toastProvider.notifier).show(
          AppLocalizations.of(context).qrInvalidCode,
          type: DropletToastType.warning,
        );
  }

  void _confirmAdd() {
    if (_scannedPeer == null) return;
    if (mounted) context.go('/chat/${_scannedPeer!.peerId}');
  }

  void _scanAgain() {
    setState(() {
      _processed = false;
      _scannedPeer = null;
    });
    _successController.reset();
    _successHideController.reset();
    _scanLineController.bouclerSiAmbiant();
    _scannerController?.start();
  }

  @override
  Widget build(BuildContext context) {
    final torConnected = ref.watch(torConnectedProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera ───────────────────────────────────────────
          if (_scannerController != null && !_processed)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
            ),

          // ── Fond noir plein une fois le code traité ─────────────
          //
          // ⚠️ SANS LUI, LA DERNIÈRE IMAGE DE LA CAMÉRA REVIENT.
          //
          // La caméra est arrêtée (`_scannerController?.stop()`), pas
          // masquée : son dernier cliché reste affiché en dessous. Sans
          // ce fond opaque, faire s'estomper le grand rond vert (voir
          // `_buildSuccessOverlay`) laisserait réapparaître cette image
          // figée derrière la carte du pair — un artefact que personne
          // ne devrait jamais voir.
          if (_processed) const ColoredBox(color: Colors.black),

          // ── Lamination scan overlay ──────────────────────────
          if (!_processed) _buildScanOverlay(),

          // ── Success overlay ──────────────────────────────────
          if (_processed && _scannedPeer != null) _buildSuccessOverlay(),

          // ── Top bar (blur glass) ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    OuroIconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.torScanQrCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _scannedPeer != null
                ? _buildSuccessPanel()
                : _buildScanningPanel(torConnected),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LAMINATION SCAN OVERLAY — animated scan line + corner brackets
  // ============================================================================

  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanLineController,
      builder: (context, _) {
        return CustomPaint(
          painter: _LaminationPainter(
            progress: _scanLineController.value,
            color: OuroColors.accent,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  // ============================================================================
  // SUCCESS OVERLAY — checkmark + radial glow
  // ============================================================================

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: Listenable.merge([_successController, _successHideController]),
      builder: (context, _) {
        // Combine l'apparition (elastique, voir `_successScale`) et la
        // disparition (linéaire, voir `_successHideController`) — les deux
        // ne jouent jamais en même temps, donc leur produit se comporte
        // comme l'une puis l'autre sans code séparé pour chaque moitié.
        final effacement = 1 - _successHideController.value;
        final opacite = _successOpacity.value * effacement;
        if (opacite <= 0) return const SizedBox.shrink();
        return Center(
          child: Opacity(
            opacity: opacite,
            child: Transform.scale(
              scale: _successScale.value * (0.85 + 0.15 * effacement),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5 * opacite),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // SCANNING PANEL — glassmorphism bottom
  // ============================================================================

  Widget _buildScanningPanel(bool torConnected) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.85),
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tor warning
          if (!torConnected)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: OuroColors.systemRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: OuroColors.systemRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.qrTorNotActive,
                      style: OuroTypography.subheadline.copyWith(color: OuroColors.systemRed),
                    ),
                  ),
                ],
              ),
            ),

          Text(
            l10n.qrScanContactCode,
            style: OuroTypography.title3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.qrCodeFromContactScreen,
            style: OuroTypography.subheadline.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ============================================================================
  // SUCCESS PANEL — glassmorphism with peer info
  // ============================================================================

  Widget _buildSuccessPanel() {
    final l10n = AppLocalizations.of(context);
    final peer = _scannedPeer!;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.9),
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Un mot avant la carte : elle seule ne dit pas ENCORE que
          // c'est du succès qu'il s'agit (un pochoir vert au centre de
          // l'écran vient de le montrer, mais il s'efface). Nommer
          // l'événement en toutes lettres évite de faire deviner.
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.qrPeerAdded,
              style: OuroTypography.title3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),

          // Peer card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Le même avatar que partout ailleurs dans l'app —
                // avant, un simple rond de couleur avec une initiale,
                // seul endroit de Droplet à ne pas utiliser `PeerAvatar`.
                // Un pair qui vient d'être ajouté mérite de se présenter
                // avec le même visage qu'il aura ensuite dans la liste
                // de discussions, pas un autre.
                PeerAvatar(
            pseudo: peer.pseudo,
            radius: 24,
            imagePath: AvatarService.cheminPair(peer.peerId),
          ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.pseudo,
                        style: OuroTypography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        // Camouflé : voir `discover_screen.dart`.
                        AppLocalizations.of(context).chViaInternet,
                        style: OuroTypography.caption1.copyWith(
                          color: OuroColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 12),
          Text(
            l10n.qrReadyToChatWith(peer.pseudo),
            textAlign: TextAlign.center,
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OuroRetourIos(child: OutlinedButton(
                  onPressed: _scanAgain,
                  style: OutlinedButton.styleFrom(overlayColor: Colors.transparent, 
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.qrScanAnother),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OuroRetourIos(child: FilledButton(
                  onPressed: _confirmAdd,
                  style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
                    backgroundColor: OuroColors.accentRempli,
                    foregroundColor: OuroColors.texteSurAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.qrChat),
                )),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

// ============================================================================
// LAMINATION PAINTER — animated scan line + corner brackets
// ============================================================================

class _LaminationPainter extends CustomPainter {
  _LaminationPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scanSize = size.width * 0.68;
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanSize,
      height: scanSize,
    );

    // ── Semi-transparent dim outside scan area ──
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20))),
      ),
      dimPaint,
    );

    // ── Scan line (laminated light bar) ──
    final lineY = scanRect.top + scanRect.height * progress;
    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.6),
          color,
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(scanRect.left, lineY - 1.5, scanRect.width, 3));

    canvas.drawRect(
      Rect.fromLTWH(scanRect.left, lineY - 1.5, scanRect.width, 3),
      linePaint,
    );

    // ── Glow trail ──
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(scanRect.left, lineY - 40, scanRect.width, 40));

    canvas.drawRect(
      Rect.fromLTWH(scanRect.left, lineY - 40, scanRect.width, 40),
      glowPaint,
    );

    // ── Corner brackets ──
    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLen = scanSize * 0.12;

    // Top-left
    _drawCorner(canvas, scanRect.topLeft, cornerLen, true, true, bracketPaint);
    // Top-right
    _drawCorner(canvas, scanRect.topRight, cornerLen, false, true, bracketPaint);
    // Bottom-left
    _drawCorner(canvas, scanRect.bottomLeft, cornerLen, true, false, bracketPaint);
    // Bottom-right
    _drawCorner(canvas, scanRect.bottomRight, cornerLen, false, false, bracketPaint);
  }

  void _drawCorner(
    Canvas canvas,
    Offset point,
    double len,
    bool isLeft,
    bool isTop,
    Paint paint,
  ) {
    final dx = isLeft ? len : -len;
    final dy = isTop ? len : -len;

    canvas.drawLine(point, point.translate(dx, 0), paint);
    canvas.drawLine(point, point.translate(0, dy), paint);
  }

  @override
  bool shouldRepaint(_LaminationPainter old) => old.progress != progress;
}
