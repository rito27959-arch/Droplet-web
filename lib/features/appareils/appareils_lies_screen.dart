// ============================================================================
// RÉGLAGES → APPAREILS LIÉS — l'écran de WhatsApp « Appareils connectés ».
// ----------------------------------------------------------------------------
//   • En tête, l'idée en une image : un ordinateur et ce téléphone, reliés
//     par la goutte, et une phrase — Droplet sur l'ordinateur, même
//     téléphone éteint.
//   • Le gros bouton « Lier un appareil », qui ouvre le scanner.
//   • La liste des navigateurs liés (4 au plus), avec la date de liaison ;
//     un appui ouvre la fiche de l'appareil et « Se déconnecter ».
//   • En pied, ce que la liaison garantit : chaque appareil a ses propres
//     clés, et les messages restent chiffrés de bout en bout.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/appareils_lies.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_pressable.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'lier_appareil_screen.dart';
import 'logo_goutte.dart';

class AppareilsLiesScreen extends StatelessWidget {
  const AppareilsLiesScreen({super.key});

  Future<void> _lier(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (AppareilsLies.liste().length >= AppareilsLies.maximum) {
      await ouroConfirm(context, title: l10n.adTitle, message: l10n.adLimit, confirmLabel: l10n.actionDone);
      return;
    }
    final lie = await Navigator.of(context).push<bool>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const LierAppareilScreen()),
    );
    if (lie == true) OuroHaptics.success();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).toLanguageTag();
    return ValueListenableBuilder<int>(
      valueListenable: AppareilsLies.revision,
      builder: (context, _, _) {
        final appareils = AppareilsLies.liste();
        return OuroLargeTitleScaffold(
          title: l10n.adTitle,
          backgroundColor: OuroColors.systemGroupedBackground,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenMargin,
                  DesignTokens.space3,
                  DesignTokens.screenMargin,
                  DesignTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Illustration(),
                    const SizedBox(height: DesignTokens.space5),
                    Text(
                      l10n.adHero,
                      textAlign: TextAlign.center,
                      style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.4),
                    ),
                    const SizedBox(height: DesignTokens.space2),
                    Text(
                      'web.dropletmesh.app',
                      textAlign: TextAlign.center,
                      style: OuroTypography.headline.copyWith(color: OuroColors.accent),
                    ),
                    const SizedBox(height: DesignTokens.space6),
                    _BoutonLier(onTap: () => _lier(context)),
                    const SizedBox(height: DesignTokens.space8),
                    OuroListSection(
                      header: '${l10n.adDevices} · ${l10n.adCount(appareils.length, AppareilsLies.maximum)}',
                      footer: l10n.adFooter,
                      separatorInset: 64,
                      children: [
                        if (appareils.isEmpty)
                          OuroListRow(title: l10n.adNone, showChevron: false)
                        else
                          for (final a in appareils)
                            OuroListRow(
                              leading: _IconeAppareil(appareil: a),
                              title: a.nom,
                              subtitle: l10n.adLinkedOn(DateFormat.yMMMd(langue).add_Hm().format(a.lieLe)),
                              onTap: () => _fiche(context, a),
                            ),
                      ],
                    ),
                    if (appareils.length > 1) ...[
                      const SizedBox(height: DesignTokens.space5),
                      OuroListSection(
                        children: [
                          OuroListRow(
                            title: l10n.adLogoutAll,
                            isDestructive: true,
                            showChevron: false,
                            onTap: () async {
                              final ok = await ouroConfirm(
                                context,
                                title: l10n.adLogoutAll,
                                message: l10n.adLogoutAllBody,
                                confirmLabel: l10n.adLogout,
                                destructive: true,
                              );
                              if (ok == true) await AppareilsLies.toutDeconnecter();
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fiche(BuildContext context, AppareilLie a) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ouroConfirm(
      context,
      title: l10n.adLogoutTitle(a.nom),
      message: l10n.adLogoutBody,
      confirmLabel: l10n.adLogout,
      destructive: true,
    );
    if (ok == true) await AppareilsLies.deconnecter(a);
  }
}

/// Un ordinateur et ce téléphone, reliés par la goutte en couleur.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final gris = OuroColors.tertiaryLabel;
    return Center(
      child: SizedBox(
        width: 230,
        height: 136,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 0, child: Icon(Icons.laptop_mac_rounded, size: 124, color: gris.withValues(alpha: 0.55))),
            Positioned(right: 10, bottom: 8, child: Icon(Icons.smartphone_rounded, size: 68, color: gris.withValues(alpha: 0.55))),
            Positioned(
              top: 0,
              right: 50,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: OuroColors.secondarySystemGroupedBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: OuroColors.accent.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                alignment: Alignment.center,
                child: LogoGoutte(taille: 34, couleur: OuroColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonLier extends StatelessWidget {
  const _BoutonLier({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroPressable(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: OuroColors.accentRempli,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          boxShadow: [
            BoxShadow(color: OuroColors.accent.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: OuroColors.texteSurAccent, size: 22),
            const SizedBox(width: DesignTokens.space2),
            Text(l10n.adLink, style: OuroTypography.headline.copyWith(color: OuroColors.texteSurAccent)),
          ],
        ),
      ),
    );
  }
}

class _IconeAppareil extends StatelessWidget {
  const _IconeAppareil({required this.appareil});

  final AppareilLie appareil;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: OuroColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Icon(
        appareil.estMac ? Icons.laptop_mac_rounded : Icons.laptop_windows_rounded,
        color: OuroColors.accent,
        size: 21,
      ),
    );
  }
}
