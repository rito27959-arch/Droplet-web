// ============================================================================
// LIER UN APPAREIL — le scanner qui relie Droplet Web à ce téléphone.
// ----------------------------------------------------------------------------
// Trois temps, sur le même écran noir, comme WhatsApp :
//
//   1. VISER. La caméra plein écran, un viseur arrondi et sa ligne qui
//      balaie ; en bas, une carte de verre qui dit où trouver le code
//      (web.dropletmesh.app). Un code qui n'est pas un code de liaison fait
//      trembler le viseur, et l'on continue de viser.
//   2. CONFIRMER. Le code reconnu, la caméra se fige derrière un voile et
//      la carte montre l'appareil (« Chrome · macOS ») : « Lier cet
//      appareil ? ». Rien n'est envoyé sans ce geste.
//   3. LIER. La carte tourne, puis la coche verte ; l'écran se referme de
//      lui-même. En cas d'échec (serveurs injoignables), la carte le dit et
//      propose de réessayer — le code du navigateur se renouvelle, il
//      suffit de viser à nouveau.
// ============================================================================

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/services/appareils_lies.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_pressable.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'logo_goutte.dart';

enum _Etape { viser, confirmer, liaison, lie, echec }

class LierAppareilScreen extends StatefulWidget {
  const LierAppareilScreen({super.key});

  @override
  State<LierAppareilScreen> createState() => _LierAppareilScreenState();
}

class _LierAppareilScreenState extends State<LierAppareilScreen> with TickerProviderStateMixin {
  final _camera = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  late final AnimationController _balayage =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
  late final AnimationController _tremblement =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  _Etape _etape = _Etape.viser;
  InvitationLien? _invitation;
  ResultatLiaison? _erreur;
  bool _mauvaisCode = false;
  bool _lampe = false;
  String? _dernierRefuse;

  @override
  void dispose() {
    _balayage.dispose();
    _tremblement.dispose();
    _camera.dispose();
    super.dispose();
  }

  void _detecte(BarcodeCapture capture) {
    if (_etape != _Etape.viser) return;
    final brut = capture.barcodes.firstOrNull?.rawValue;
    if (brut == null || brut.isEmpty) return;
    final inv = InvitationLien.lire(brut);
    if (inv == null) {
      // Un autre code : on le signale une fois, sans quitter le viseur.
      if (brut == _dernierRefuse) return;
      _dernierRefuse = brut;
      OuroHaptics.error();
      _tremblement.forward(from: 0);
      setState(() => _mauvaisCode = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _mauvaisCode = false);
      });
      return;
    }
    OuroHaptics.medium();
    _camera.stop();
    setState(() {
      _invitation = inv;
      _etape = _Etape.confirmer;
    });
  }

  Future<void> _lier() async {
    final inv = _invitation;
    if (inv == null) return;
    setState(() => _etape = _Etape.liaison);
    final r = await AppareilsLies.lier(inv);
    if (!mounted) return;
    if (r == ResultatLiaison.lie) {
      OuroHaptics.success();
      setState(() => _etape = _Etape.lie);
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.of(context).pop(true);
    } else {
      OuroHaptics.error();
      setState(() {
        _erreur = r;
        _etape = _Etape.echec;
      });
    }
  }

  void _reprendre() {
    _dernierRefuse = null;
    setState(() {
      _invitation = null;
      _erreur = null;
      _etape = _Etape.viser;
    });
    _camera.start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fige = _etape != _Etape.viser;
    final couleurCadre = _mauvaisCode ? OuroColors.systemOrange : (fige ? OuroColors.successGreen : Colors.white);
    final cote = min(MediaQuery.sizeOf(context).width * 0.68, 280.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _camera, onDetect: _detecte),

          // Le voile : il assombrit tout sauf le viseur, puis tout quand
          // le code est reconnu.
          IgnorePointer(
            child: AnimatedContainer(
              duration: DesignTokens.durationStandard,
              color: Colors.black.withValues(alpha: fige ? 0.55 : 0),
              child: fige
                  ? BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: const SizedBox.expand())
                  : CustomPaint(painter: _Voile(cote: cote), size: Size.infinite),
            ),
          ),

          // Le viseur.
          IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _tremblement,
                builder: (context, enfant) => Transform.translate(
                  offset: Offset(sin(_tremblement.value * pi * 6) * 10 * (1 - _tremblement.value), 0),
                  child: enfant,
                ),
                child: AnimatedOpacity(
                  duration: DesignTokens.durationFast,
                  opacity: fige ? 0 : 1,
                  child: SizedBox.square(
                    dimension: cote,
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: _Coins(couleur: couleurCadre))),
                        AnimatedBuilder(
                          animation: _balayage,
                          builder: (context, _) => Positioned(
                            top: 14 + _balayage.value * (cote - 28),
                            left: 18,
                            right: 18,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: LinearGradient(colors: [
                                  OuroColors.accent.withValues(alpha: 0),
                                  OuroColors.accent,
                                  OuroColors.accent.withValues(alpha: 0),
                                ]),
                                boxShadow: [BoxShadow(color: OuroColors.accent.withValues(alpha: 0.7), blurRadius: 8)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // La barre du haut : fermer, titre, lampe.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2),
              child: Row(
                children: [
                  _BoutonRond(
                    icone: Icons.close_rounded,
                    semantique: l10n.actionClose,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  Expanded(
                    child: Text(
                      l10n.adScanTitle,
                      textAlign: TextAlign.center,
                      style: OuroTypography.headline.copyWith(color: Colors.white),
                    ),
                  ),
                  _BoutonRond(
                    icone: _lampe ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                    semantique: l10n.adTorch,
                    actif: _lampe,
                    onTap: fige
                        ? null
                        : () {
                            _camera.toggleTorch();
                            setState(() => _lampe = !_lampe);
                          },
                  ),
                ],
              ),
            ),
          ),

          // La carte du bas.
          Positioned(
            left: DesignTokens.screenMargin,
            right: DesignTokens.screenMargin,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.space4),
                child: AnimatedSwitcher(
                  duration: DesignTokens.durationStandard,
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (enfant, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(a),
                      child: enfant,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_etape),
                    child: _Carte(child: _contenuCarte(l10n)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenuCarte(AppLocalizations l10n) {
    final nom = _invitation?.nom ?? 'Droplet Web';
    switch (_etape) {
      case _Etape.viser:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const _Etapes(),
                const SizedBox(width: DesignTokens.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.adScanHint, style: OuroTypography.subheadline.copyWith(color: Colors.white, height: 1.35)),
                      const SizedBox(height: DesignTokens.space1),
                      Text('web.dropletmesh.app', style: OuroTypography.headline.copyWith(color: OuroColors.accent)),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: DesignTokens.durationFast,
              child: _mauvaisCode
                  ? Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.space3),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: OuroColors.systemOrange),
                          const SizedBox(width: DesignTokens.space2),
                          Expanded(
                            child: Text(l10n.adNotDroplet, style: OuroTypography.footnote.copyWith(color: OuroColors.systemOrange)),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: DesignTokens.space3),
            Row(
              children: [
                Icon(Icons.lock_rounded, size: 13, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: DesignTokens.space1),
                Expanded(
                  child: Text(
                    l10n.adSecurity,
                    style: OuroTypography.caption1.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ],
        );
      case _Etape.confirmer:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Appareil(),
            const SizedBox(height: DesignTokens.space3),
            Text(nom, textAlign: TextAlign.center, style: OuroTypography.title3.copyWith(color: Colors.white)),
            const SizedBox(height: DesignTokens.space2),
            Text(l10n.adConfirmTitle, textAlign: TextAlign.center, style: OuroTypography.headline.copyWith(color: Colors.white)),
            const SizedBox(height: DesignTokens.space1),
            Text(
              l10n.adConfirmBody,
              textAlign: TextAlign.center,
              style: OuroTypography.subheadline.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: DesignTokens.space5),
            _BoutonPlein(texte: l10n.adConfirm, onTap: _lier),
            const SizedBox(height: DesignTokens.space2),
            _BoutonTexte(texte: l10n.actionCancel, onTap: _reprendre),
          ],
        );
      case _Etape.liaison:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DesignTokens.space3),
            const OuroSpinner(color: Colors.white, radius: 14),
            const SizedBox(height: DesignTokens.space4),
            Text(l10n.adLinking, style: OuroTypography.headline.copyWith(color: Colors.white)),
            const SizedBox(height: DesignTokens.space1),
            Text(nom, style: OuroTypography.subheadline.copyWith(color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: DesignTokens.space3),
          ],
        );
      case _Etape.lie:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DesignTokens.space2),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutBack,
              builder: (context, v, _) => Transform.scale(
                scale: v,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: OuroColors.successGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(l10n.adLinked, style: OuroTypography.title3.copyWith(color: Colors.white)),
            const SizedBox(height: DesignTokens.space1),
            Text(nom, style: OuroTypography.subheadline.copyWith(color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: DesignTokens.space2),
          ],
        );
      case _Etape.echec:
        final message = switch (_erreur) {
          ResultatLiaison.limiteAtteinte => l10n.adLimit,
          ResultatLiaison.sansIdentite => l10n.adNoIdentity,
          ResultatLiaison.codeInvalide => l10n.adNotDroplet,
          _ => l10n.adServerDown,
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: OuroColors.systemOrange),
            const SizedBox(height: DesignTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: OuroTypography.subheadline.copyWith(color: Colors.white, height: 1.35),
            ),
            const SizedBox(height: DesignTokens.space5),
            _BoutonPlein(texte: l10n.actionRetry, onTap: _reprendre),
            const SizedBox(height: DesignTokens.space2),
            _BoutonTexte(texte: l10n.actionClose, onTap: () => Navigator.of(context).pop(false)),
          ],
        );
    }
  }
}

// ── Les pièces de l'écran ─────────────────────────────────────────────

/// La carte de verre sombre du bas.
class _Carte extends StatelessWidget {
  const _Carte({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSheet),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.space5),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSheet),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.6),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Le petit schéma de gauche : ordinateur → goutte.
class _Etapes extends StatelessWidget {
  const _Etapes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.laptop_mac_rounded, color: Colors.white, size: 34),
          Positioned(top: 15, child: LogoGoutte(taille: 14, couleur: OuroColors.accent)),
        ],
      ),
    );
  }
}

/// L'appareil reconnu, en grand.
class _Appareil extends StatelessWidget {
  const _Appareil();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutBack,
      builder: (context, v, enfant) => Transform.scale(scale: v, child: enfant),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: OuroColors.accent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.laptop_mac_rounded, color: OuroColors.accent, size: 40),
            Positioned(top: 25, child: LogoGoutte(taille: 13, couleur: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _BoutonPlein extends StatelessWidget {
  const _BoutonPlein({required this.texte, required this.onTap});

  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OuroPressable(
        onTap: onTap,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: OuroColors.accentRempli,
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
          alignment: Alignment.center,
          child: Text(texte, style: OuroTypography.headline.copyWith(color: OuroColors.texteSurAccent)),
        ),
      );
}

class _BoutonTexte extends StatelessWidget {
  const _BoutonTexte({required this.texte, required this.onTap});

  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OuroPressable(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Center(child: Text(texte, style: OuroTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.85)))),
        ),
      );
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.icone, required this.onTap, required this.semantique, this.actif = false});

  final IconData icone;
  final VoidCallback? onTap;
  final String semantique;
  final bool actif;

  @override
  Widget build(BuildContext context) => OuroPressable(
        onTap: onTap,
        semantique: semantique,
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.all(DesignTokens.space1),
          decoration: BoxDecoration(
            color: actif ? Colors.white : Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: actif ? Colors.black : Colors.white, size: 22),
        ),
      );
}

/// Le voile sombre autour du viseur (un rectangle arrondi découpé).
class _Voile extends CustomPainter {
  _Voile({required this.cote});

  final double cote;

  @override
  void paint(Canvas canvas, Size size) {
    final trou = RRect.fromRectAndRadius(
      Rect.fromCenter(center: size.center(Offset.zero), width: cote, height: cote),
      const Radius.circular(28),
    );
    final chemin = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(trou);
    canvas.drawPath(chemin, Paint()..color = Colors.black.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_Voile ancien) => ancien.cote != cote;
}

/// Les quatre coins arrondis du viseur, comme l'appareil photo d'iOS.
class _Coins extends CustomPainter {
  _Coins({required this.couleur});

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0;
    const r = 28.0;
    final p = Paint()
      ..color = couleur
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // Haut gauche, haut droit, bas droit, bas gauche.
    canvas.drawPath(
      Path()
        ..moveTo(0, l + r)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(r + l, 0),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - r - l, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
        ..lineTo(w, r + l),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h - r - l)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
        ..lineTo(w - r - l, h),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r + l, h)
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
        ..lineTo(0, h - r - l),
      p,
    );
  }

  @override
  bool shouldRepaint(_Coins ancien) => ancien.couleur != couleur;
}
