// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES NOTIFICATIONS DE TOUT DROPLET — Concentration, bannières, aperçus, et
// la liste de ce qui est en sourdine.
//
// ── ⚠️ CONCENTRATION N'EST PAS « DÉSACTIVER LES NOTIFICATIONS » ─────────
//
// Désactiver, c'est un interrupteur qu'on oublie de remettre, et une
// semaine sans nouvelles de personne. Concentration a TOUJOURS une fin :
// une heure, ce soir, demain matin. On ne peut pas l'activer « pour
// toujours », exprès. Et elle laisse passer les appels — quelqu'un qui
// appelle en plein silence, c'est rarement pour rien.
//
// ── ⚠️ LA LISTE DES SOURDINES ───────────────────────────────────────────
//
// C'est la question que personne ne sait résoudre ailleurs : « pourquoi
// je ne reçois plus rien de ce groupe ? ». La réponse est ici, avec
// l'heure de fin de chaque sourdine et un toucher pour la lever.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/services/journal_notifs.dart';
import '../../core/services/notifs_conversation.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/liquid_bridge.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'notifs_conversation_screen.dart';

class ReglagesNotifsScreen extends StatefulWidget {
  const ReglagesNotifsScreen({super.key});

  @override
  State<ReglagesNotifsScreen> createState() => _ReglagesNotifsScreenState();
}

class _ReglagesNotifsScreenState extends State<ReglagesNotifsScreen> {
  /// Les trois fins de Concentration proposées — celles d'iOS.
  List<({String libelle, DateTime fin})> _fins(AppLocalizations l10n) {
    final t = DateTime.now();
    final ceSoir = DateTime(t.year, t.month, t.day, 19);
    final demainMatin = DateTime(t.year, t.month, t.day + 1, 8);
    return [
      (libelle: l10n.rnFocus1h, fin: t.add(const Duration(hours: 1))),
      // « Ce soir » n'a de sens qu'avant 19 h ; après, il deviendrait
      // « dans le passé ». On ne le propose alors pas.
      if (ceSoir.isAfter(t.add(const Duration(minutes: 30))))
        (libelle: l10n.rnFocusEvening, fin: ceSoir),
      (libelle: l10n.rnFocusTomorrow, fin: demainMatin),
    ];
  }

  Future<void> _concentration(DateTime? fin) async {
    OuroHaptics.medium();
    await ReglagesNotifs.definirConcentration(fin);
    if (mounted) setState(() {});
  }

  String _nomConversation(String id, AppLocalizations l10n) {
    final groupe = StorageService.getGroup(id);
    if (groupe != null) return groupe.name;
    final pair = StorageService.getPeerRecord(id);
    return pair?.pseudo ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).toLanguageTag();
    return ValueListenableBuilder<int>(
      valueListenable: ReglagesNotifs.revision,
      builder: (context, _, _) {
        final fin = ReglagesNotifs.concentrationJusqua;
        final instantane = ReglagesNotifs.instantane();
        final maintenant = DateTime.now();
        final enSourdine = [
          for (final id in {
            ...instantane.sourdinesPermanentes,
            ...instantane.conversations.keys,
          })
            if (instantane.pour(id).enSourdine(maintenant)) id,
        ];

        return OuroLargeTitleScaffold(
          title: l10n.ncTitle,
          backgroundColor: OuroColors.systemGroupedBackground,
          leading: const OuroBackButton(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: _CarteConcentration(
                  fin: fin,
                  langue: langue,
                  onArreter: () => _concentration(null),
                ),
              ),
            ),

            // ── CONCENTRATION ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: OuroListSection(
                header: l10n.rnFocusHeader,
                footer: l10n.rnFocusFooter,
                children: [
                  if (fin == null)
                    for (final f in _fins(l10n))
                      OuroListRow(
                        icon: Icons.nightlight_round,
                        iconColor: OuroColors.systemIndigo,
                        title: f.libelle,
                        value: DateFormat.Hm(langue).format(f.fin),
                        showChevron: false,
                        onTap: () => _concentration(f.fin),
                      )
                  else
                    OuroListRow(
                      icon: Icons.stop_circle_outlined,
                      iconColor: OuroColors.systemRed,
                      title: l10n.rnFocusStop,
                      showChevron: false,
                      onTap: () => _concentration(null),
                    ),
                  OuroListRow(
                    icon: Icons.alternate_email_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.rnFocusMentions,
                    subtitle: l10n.rnFocusMentionsSub,
                    showChevron: false,
                    trailing: LiquidGlassSwitch(
                      value: ReglagesNotifs.concentrationLaisseMentions,
                      onChanged: (v) async {
                        OuroHaptics.light();
                        await ReglagesNotifs.definirConcentrationLaisseMentions(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),

            // ── DANS L'APPLICATION ─────────────────────────────────────
            SliverToBoxAdapter(
              child: OuroListSection(
                header: l10n.rnInAppHeader,
                children: [
                  OuroListRow(
                    icon: Icons.view_day_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.rnBanners,
                    subtitle: l10n.rnBannersSub,
                    showChevron: false,
                    trailing: LiquidGlassSwitch(
                      value: ReglagesNotifs.bannieres,
                      onChanged: (v) async {
                        OuroHaptics.light();
                        await ReglagesNotifs.definirBannieres(v);
                      },
                    ),
                  ),
                  ListenableBuilder(
                    listenable: JournalNotifs.instance,
                    builder: (context, _) {
                      final n = JournalNotifs.instance.nonLues;
                      return OuroListRow(
                        icon: Icons.inbox_rounded,
                        iconColor: OuroColors.systemRed,
                        title: l10n.cnTitle,
                        value: n > 0 ? '$n' : null,
                        onTap: () => context.push('/notifications'),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),

            // ── APERÇUS ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: OuroListSection(
                header: l10n.ncPreviewHeader,
                footer: l10n.rnPreviewFooter,
                children: [
                  OuroListRow(
                    icon: Icons.visibility_rounded,
                    iconColor: OuroColors.systemGray,
                    title: l10n.rnPreview,
                    showChevron: false,
                    trailing: LiquidGlassSwitch(
                      value: ReglagesNotifs.apercuGeneral,
                      onChanged: (v) async {
                        OuroHaptics.light();
                        await ReglagesNotifs.definirApercuGeneral(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),

            // ── EN SOURDINE ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: OuroListSection(
                header: l10n.rnMutedHeader,
                footer: enSourdine.isEmpty ? l10n.rnMutedEmpty : null,
                children: [
                  for (final id in enSourdine)
                    Builder(builder: (context) {
                      final r = instantane.pour(id);
                      final groupe = StorageService.getGroup(id) != null;
                      final nom = _nomConversation(id, l10n);
                      return OuroListRow(
                        icon: Icons.notifications_off_rounded,
                        iconColor: OuroColors.systemGray,
                        title: nom,
                        subtitle: r.sourdineJusqua != null
                            ? libelleFinSourdine(l10n, langue, r.sourdineJusqua!)
                            : l10n.ncMuteAlways,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NotifsConversationScreen(
                              conversationId: id,
                              nom: nom,
                              groupe: groupe,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            if (Platform.isAndroid) ...[
              const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),
              SliverToBoxAdapter(
                child: OuroListSection(
                  footer: l10n.rnSystemFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.settings_applications_rounded,
                      iconColor: OuroColors.systemGray,
                      title: l10n.rnSystem,
                      onTap: () => unawaited(NotifsConversation.ouvrirReglagesBulles()),
                    ),
                  ],
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }
}

/// La grande carte du haut : l'état de Concentration, d'un coup d'œil.
class _CarteConcentration extends StatelessWidget {
  const _CarteConcentration({
    required this.fin,
    required this.langue,
    required this.onArreter,
  });

  final DateTime? fin;
  final String langue;
  final VoidCallback onArreter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = fin != null;
    final couleur = OuroColors.systemIndigo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: active
            ? couleur.withValues(alpha: OuroColors.isDark ? 0.32 : 0.14)
            : OuroColors.secondarySystemGroupedBackground,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? couleur : OuroColors.tertiarySystemFill,
            ),
            child: Icon(
              active ? Icons.nightlight_round : Icons.notifications_active_rounded,
              color: active ? Colors.white : OuroColors.secondaryLabel,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? l10n.rnFocusOn : l10n.rnFocusOff,
                  style: OuroTypography.headline.copyWith(color: OuroColors.label),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? l10n.rnFocusUntil(DateFormat.Hm(langue).format(fin!))
                      : l10n.rnFocusOffSub,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Semantics(
              button: true,
              label: l10n.rnFocusStop,
              child: GestureDetector(
                onTap: onArreter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: couleur,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.rnFocusStopShort,
                    style: OuroTypography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
