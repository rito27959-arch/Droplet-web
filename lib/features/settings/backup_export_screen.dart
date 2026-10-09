import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/backup_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/liquid_bridge.dart';
import '../../shared/widgets/success_seal.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import '../../core/services/sauvegarde_en_ligne.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Export d'une sauvegarde chiffrée de l'identité (clé privée, contacts,
/// groupes, et optionnellement l'historique) — seul recours en cas de perte
/// d'appareil, l'app ne dépendant d'aucun compte ni serveur.
class BackupExportScreen extends ConsumerStatefulWidget {
  const BackupExportScreen({super.key});

  @override
  ConsumerState<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends ConsumerState<BackupExportScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _includeMessages = true;
  bool _obscure = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Force approximative du mot de passe, 0..1 — critères simples (longueur,
  /// variété de caractères) juste pour rassurer visuellement l'utilisateur
  /// sur la qualité de sa protection, pas une mesure d'entropie exacte.
  double _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    var score = 0;
    if (p.length >= 8) score++;
    if (p.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return (score / 5).clamp(0.0, 1.0);
  }

  (Color, String) _strengthLabel(AppLocalizations l10n, double s) {
    if (s <= 0) return (OuroColors.textTertiary, '');
    if (s < 0.4) return (OuroColors.errorRed, l10n.beWeak);
    if (s < 0.8) return (OuroColors.warningAmber, l10n.beOkay);
    return (OuroColors.successGreen, l10n.beStrong);
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final password = _passwordCtrl.text;
    if (password.length < 8) {
      ref.read(toastProvider.notifier).show(
            l10n.bePasswordTooShort,
            type: DropletToastType.warning,
          );
      return;
    }
    if (password != _confirmCtrl.text) {
      ref.read(toastProvider.notifier).show(
            l10n.bePasswordsDontMatch,
            type: DropletToastType.warning,
          );
      return;
    }

    setState(() => _busy = true);
    try {
      final file = await BackupService.createBackup(
        password: password,
        includeMessages: _includeMessages,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.beBackupSubject,
        text: l10n.beBackupShareText,
      );
      if (!mounted) return;
      _passwordCtrl.clear();
      _confirmCtrl.clear();
      // Moment sensible (identité chiffrée exportée) : un sceau plein écran
      // rassure davantage qu'un toast passager, cohérent avec le traitement
      // de la vérification de clé de sécurité.
      unawaited(SuccessSeal.show(context,
          icon: Icons.lock_rounded,
          emoji: Scenes.sauvegardeReussie,
          message: l10n.beBackupCreated));
    } catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(l10n.beBackupFailed, type: DropletToastType.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: OuroColors.background,
      appBar: AppBar(
        backgroundColor: OuroColors.background,
        elevation: 0,
        leading: const OuroBackButton(fallback: '/settings'),
        title: Text(l10n.beBackupMyIdentity,
            style: TextStyle(color: OuroColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: OuroColors.warningAmber.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(color: OuroColors.warningAmber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: OuroColors.warningAmber, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.beWarningBody,
                    style: TextStyle(color: OuroColors.warningAmber, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideY(begin: -0.1, curve: DesignTokens.curveEmphasis)
              .animate(onPlay: (c) => c.bouclerSiAmbiant(reverse: true))
              .custom(
                duration: DesignTokens.durationBeat,
                builder: (context, value, child) => DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: DesignTokens.glow(OuroColors.warningAmber, radius: 4 + value * 6, spread: 0),
                  ),
                  child: child,
                ),
              ),
          const SizedBox(height: 24),
          Text(l10n.bePasswordProtects,
              style: TextStyle(color: OuroColors.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            style: TextStyle(color: OuroColors.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.bePassword,
              suffixIcon: OuroIconButton(
                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: OuroColors.textTertiary),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_passwordCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PasswordStrengthMeter(
              strength: _passwordStrength(_passwordCtrl.text),
              label: _strengthLabel(l10n, _passwordStrength(_passwordCtrl.text)),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            style: TextStyle(color: OuroColors.textPrimary),
            decoration: InputDecoration(labelText: l10n.beConfirmPassword),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _includeMessages,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _includeMessages = v);
            },
            activeThumbColor: OuroColors.meshBlue,
            title: Text(l10n.beIncludeMessageHistory,
                style: TextStyle(color: OuroColors.textPrimary, fontSize: 15)),
            subtitle: Text(l10n.beOtherwiseOnlyIdentity,
                style: TextStyle(color: OuroColors.textTertiary, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          LiquidGlassButton(
            onTap: _busy ? null : _export,
            child: AnimatedSwitcher(
                duration: DesignTokens.durationFast,
                child: _busy
                    ? const SizedBox(
                        key: ValueKey('busy'),
                        width: 22, height: 22,
                        child: OuroSpinner(color: Colors.white, radius: 9),
                      )
                    : Text(l10n.beCreateAndShare,
                        key: const ValueKey('idle'),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          const SizedBox(height: 36),
          _SauvegardeAutomatique(
            motDePasse: () => _passwordCtrl.text,
            confirmation: () => _confirmCtrl.text,
          ),
        ],
      ),
    );
  }
}

/// Indicateur de force du mot de passe, mis à jour en temps réel — rassure
/// sur la qualité de la protection d'une sauvegarde qui, contrairement à un
/// compte en ligne, n'a aucun mécanisme de récupération si le mot de passe
/// est trop faible et deviné/cassé plus tard.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength, required this.label});
  final double strength;
  final (Color, String) label;

  @override
  Widget build(BuildContext context) {
    final (color, text) = label;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: strength),
              duration: DesignTokens.durationNormal,
              curve: DesignTokens.curveEmphasis,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: OuroColors.glassBg,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ).animate().fadeIn(duration: DesignTokens.durationFast);
  }
}


/// La sauvegarde automatique en ligne : chaque jour, la même enveloppe
/// chiffrée est déposée sur le serveur Droplet (voir `SauvegardeEnLigne`).
class _SauvegardeAutomatique extends ConsumerStatefulWidget {
  const _SauvegardeAutomatique({required this.motDePasse, required this.confirmation});

  final String Function() motDePasse;
  final String Function() confirmation;

  @override
  ConsumerState<_SauvegardeAutomatique> createState() => _SauvegardeAutomatiqueState();
}

class _SauvegardeAutomatiqueState extends ConsumerState<_SauvegardeAutomatique> {
  bool _active = SauvegardeEnLigne.active;
  bool _occupe = false;

  String _date(DateTime d) {
    String deux(int n) => n.toString().padLeft(2, '0');
    return '${deux(d.day)}/${deux(d.month)}/${d.year} ${deux(d.hour)}:${deux(d.minute)}';
  }

  Future<void> _basculer(bool activer) async {
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastProvider.notifier);
    if (!activer) {
      HapticFeedback.selectionClick();
      await SauvegardeEnLigne.desactiver();
      if (mounted) setState(() => _active = false);
      return;
    }
    final motDePasse = widget.motDePasse();
    if (motDePasse.length < 8) {
      toast.show(l10n.bePasswordTooShort, type: DropletToastType.warning);
      return;
    }
    if (motDePasse != widget.confirmation()) {
      toast.show(l10n.bePasswordsDontMatch, type: DropletToastType.warning);
      return;
    }
    setState(() => _occupe = true);
    final reussi = await SauvegardeEnLigne.activer(motDePasse);
    if (!mounted) return;
    setState(() {
      _occupe = false;
      _active = true;
    });
    toast.show(
      reussi ? l10n.beOnlineDone : l10n.beOnlineFailed,
      type: reussi ? DropletToastType.success : DropletToastType.warning,
    );
  }

  Future<void> _maintenant() async {
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastProvider.notifier);
    setState(() => _occupe = true);
    final reussi = await SauvegardeEnLigne.sauvegarderMaintenant();
    if (!mounted) return;
    setState(() => _occupe = false);
    toast.show(
      reussi ? l10n.beOnlineDone : l10n.beOnlineFailed,
      type: reussi ? DropletToastType.success : DropletToastType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final derniere = SauvegardeEnLigne.derniere;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.beOnlineTitle,
          style: TextStyle(color: OuroColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.beOnlineBody,
          style: TextStyle(color: OuroColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _active,
          onChanged: _occupe ? null : _basculer,
          activeThumbColor: OuroColors.meshBlue,
          title: Text(l10n.beOnlineSwitch, style: TextStyle(color: OuroColors.textPrimary, fontSize: 15)),
          subtitle: Text(
            derniere == null ? l10n.beOnlineNever : l10n.beOnlineLast(_date(derniere)),
            style: TextStyle(color: OuroColors.textTertiary, fontSize: 12),
          ),
        ),
        if (_active)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OuroRetourIos(child: TextButton.icon(
              onPressed: _occupe ? null : _maintenant,
              icon: _occupe
                  ? const SizedBox(width: 16, height: 16, child: OuroSpinner(radius: 7))
                  : const Icon(Icons.cloud_upload_rounded, size: 18),
              label: Text(l10n.beOnlineNow),
            )),
          ),
      ],
    );
  }
}
