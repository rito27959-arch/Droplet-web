// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES NOTIFICATIONS D'UNE CONVERSATION — sourdine, livraison discrète,
// aperçu, mentions seulement.
//
// ── ⚠️ ON MONTRE LE RÉSULTAT, PAS SEULEMENT LES INTERRUPTEURS ────────────
//
// En haut de l'écran, une notification d'exemple — celle que cette
// conversation produira VRAIMENT avec les réglages choisis. On coupe
// l'aperçu : le texte devient « Nouveau message » sous ses yeux. On met en
// sourdine : la carte pâlit et une cloche barrée apparaît.
//
// C'est ce qui manque à presque tous les écrans de réglages de
// notifications : quatre interrupteurs dont personne ne sait vraiment ce
// qu'ils changent. Ici, on le voit avant de quitter l'écran.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/avatar_service.dart';
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
import '../../shared/widgets/avatar_groupe.dart';
import '../../shared/widgets/peer_avatar.dart';

/// Les durées de sourdine proposées — celles de WhatsApp et d'iMessage.
/// `null` = toujours.
const List<Duration?> kDureesSourdine = [
  Duration(hours: 1),
  Duration(hours: 8),
  Duration(days: 7),
  null,
];

String libelleDureeSourdine(AppLocalizations l10n, Duration? d) =>
    switch (d?.inHours) {
      null => l10n.ncMuteAlways,
      1 => l10n.ncMute1h,
      8 => l10n.ncMute8h,
      _ => l10n.ncMute1w,
    };

/// « jusqu'à 18:30 », « jusqu'à mardi 18:30 »…
String libelleFinSourdine(AppLocalizations l10n, String langue, DateTime fin) {
  final maintenant = DateTime.now();
  final memeJour = fin.year == maintenant.year &&
      fin.month == maintenant.month &&
      fin.day == maintenant.day;
  final heure = DateFormat.Hm(langue).format(fin);
  return l10n.ncMutedUntil(
    memeJour ? heure : '${DateFormat.EEEE(langue).format(fin)} $heure',
  );
}

class NotifsConversationScreen extends StatefulWidget {
  const NotifsConversationScreen({
    super.key,
    required this.conversationId,
    required this.nom,
    this.groupe = false,
  });

  final String conversationId;
  final String nom;
  final bool groupe;

  @override
  State<NotifsConversationScreen> createState() =>
      _NotifsConversationScreenState();
}

class _NotifsConversationScreenState extends State<NotifsConversationScreen> {
  late ReglagesConversation _r = ReglagesNotifs.pour(widget.conversationId);

  /// La sourdine choisie — pour la coche. Une sourdine temporaire déjà
  /// en cours ne correspond à aucune ligne : on ne coche rien plutôt que
  /// de prétendre qu'elle est « d'une heure » alors qu'il en reste vingt
  /// minutes.
  Duration? _dureeChoisie;
  bool _dureeConnue = false;

  void _relire() => setState(() => _r = ReglagesNotifs.pour(widget.conversationId));

  Future<void> _sourdine(Duration? duree, {required bool activer}) async {
    OuroHaptics.selection();
    if (!activer) {
      await ReglagesNotifs.leverSourdine(widget.conversationId);
      _dureeConnue = false;
    } else {
      await ReglagesNotifs.mettreEnSourdine(widget.conversationId, duree: duree);
      _dureeChoisie = duree;
      _dureeConnue = true;
    }
    _relire();
  }

  Future<void> _apercu(ApercuNotif a) async {
    OuroHaptics.selection();
    await ReglagesNotifs.definirApercu(widget.conversationId, a);
    _relire();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).toLanguageTag();
    final maintenant = DateTime.now();
    final enSourdine = _r.enSourdine(maintenant);
    final general = ReglagesNotifs.apercuGeneral;

    String? finSourdine;
    if (_r.sourdineJusqua != null && enSourdine) {
      finSourdine = libelleFinSourdine(l10n, langue, _r.sourdineJusqua!);
    }

    return OuroLargeTitleScaffold(
      title: l10n.ncTitle,
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            child: ApercuNotification(
              conversationId: widget.conversationId,
              nom: widget.nom,
              groupe: widget.groupe,
              reglages: _r,
              apercuGeneral: general,
            ),
          ),
        ),

        // ── SOURDINE ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: OuroListSection(
            header: l10n.ncMuteHeader,
            footer: [
              ?finSourdine,
              widget.groupe ? l10n.ncMuteFooterGroup : l10n.ncMuteFooter,
            ].join('\n'),
            children: [
              _LigneChoix(
                titre: l10n.ncMuteOff,
                choisie: !enSourdine,
                onTap: () => _sourdine(null, activer: false),
              ),
              for (final d in kDureesSourdine)
                _LigneChoix(
                  titre: libelleDureeSourdine(l10n, d),
                  choisie: enSourdine &&
                      (d == null
                          ? _r.sourdinePermanente
                          : _dureeConnue && _dureeChoisie == d),
                  onTap: () => _sourdine(d, activer: true),
                ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),

        // ── PRÉSENTATION ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: OuroListSection(
            header: l10n.ncDeliveryHeader,
            children: [
              OuroListRow(
                icon: Icons.nights_stay_rounded,
                iconColor: OuroColors.systemIndigo,
                title: l10n.ncQuiet,
                subtitle: l10n.ncQuietSub,
                showChevron: false,
                trailing: LiquidGlassSwitch(
                  value: _r.discret,
                  onChanged: (v) async {
                    OuroHaptics.light();
                    await ReglagesNotifs.definirDiscret(widget.conversationId, v);
                    _relire();
                  },
                ),
              ),
              if (widget.groupe)
                OuroListRow(
                  icon: Icons.alternate_email_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.ncMentionsOnly,
                  subtitle: l10n.ncMentionsOnlySub,
                  showChevron: false,
                  trailing: LiquidGlassSwitch(
                    value: _r.mentionsSeulement,
                    onChanged: (v) async {
                      OuroHaptics.light();
                      await ReglagesNotifs.definirMentionsSeulement(
                          widget.conversationId, v);
                      _relire();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),

        // ── APERÇU ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: OuroListSection(
            header: l10n.ncPreviewHeader,
            footer: l10n.ncPreviewFooter,
            children: [
              _LigneChoix(
                titre: l10n.ncPreviewDefault(
                  general ? l10n.ncPreviewAlways : l10n.ncPreviewNever,
                ),
                choisie: _r.apercu == ApercuNotif.herite,
                onTap: () => _apercu(ApercuNotif.herite),
              ),
              _LigneChoix(
                titre: l10n.ncPreviewAlways,
                choisie: _r.apercu == ApercuNotif.toujours,
                onTap: () => _apercu(ApercuNotif.toujours),
              ),
              _LigneChoix(
                titre: l10n.ncPreviewNever,
                choisie: _r.apercu == ApercuNotif.jamais,
                onTap: () => _apercu(ApercuNotif.jamais),
              ),
            ],
          ),
        ),

        // ── LE SYSTÈME ───────────────────────────────────────────────
        //
        // Le son et la bulle d'une conversation appartiennent à Android :
        // il les garde par conversation, et il a raison — c'est là que la
        // personne les cherchera aussi pour les autres applications. On y
        // emmène plutôt que de les imiter.
        if (Platform.isAndroid) ...[
          const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.space5)),
          SliverToBoxAdapter(
            child: OuroListSection(
              footer: l10n.ncSystemFooter,
              children: [
                OuroListRow(
                  icon: Icons.tune_rounded,
                  iconColor: OuroColors.systemGray,
                  title: l10n.ncSystemSettings,
                  onTap: () => unawaited(NotifsConversation
                      .ouvrirReglagesConversation(widget.conversationId)),
                ),
              ],
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

/// Une ligne de choix, avec la coche iOS à droite.
class _LigneChoix extends StatelessWidget {
  const _LigneChoix({
    required this.titre,
    required this.choisie,
    required this.onTap,
  });

  final String titre;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: choisie,
      child: OuroListRow(
        title: titre,
        showChevron: false,
        onTap: onTap,
        trailing: AnimatedScale(
          scale: choisie ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Icon(Icons.check_rounded, size: 21, color: OuroColors.accent),
        ),
      ),
    );
  }
}

/// La notification d'exemple, telle que les réglages la produiront.
class ApercuNotification extends StatelessWidget {
  const ApercuNotification({
    super.key,
    required this.conversationId,
    required this.nom,
    required this.groupe,
    required this.reglages,
    required this.apercuGeneral,
  });

  final String conversationId;
  final String nom;
  final bool groupe;
  final ReglagesConversation reglages;
  final bool apercuGeneral;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = reglages;
    final coupee = r.enSourdine(DateTime.now());
    final apercu = switch (r.apercu) {
      ApercuNotif.herite => apercuGeneral,
      ApercuNotif.toujours => true,
      ApercuNotif.jamais => false,
    };
    final texte = apercu ? l10n.ncSampleText : l10n.ncSampleHidden;

    final avatar = groupe
        ? AvatarGroupe(
            groupe: StorageService.getGroup(conversationId),
            monId: StorageService.currentUser?.id ?? '',
            rayon: 19,
          )
        : PeerAvatar(
            pseudo: nom,
            radius: 19,
            imagePath: AvatarService.cheminPair(conversationId),
          );

    // Ce que la carte dit d'elle-même, en une icône.
    final IconData? marque = coupee
        ? Icons.notifications_off_rounded
        : r.discret
            ? Icons.nights_stay_rounded
            : (groupe && r.mentionsSeulement)
                ? Icons.alternate_email_rounded
                : null;

    return Semantics(
      label: '${l10n.ncSampleLabel}. $nom, $texte',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: coupee ? 0.45 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          scale: coupee ? 0.97 : 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.35 : 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OuroTypography.subheadline.copyWith(
                                color: OuroColors.label,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: marque == null
                                ? const SizedBox.shrink(key: ValueKey('rien'))
                                : Padding(
                                    key: ValueKey(marque),
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      marque,
                                      size: 14,
                                      color: OuroColors.secondaryLabel,
                                    ),
                                  ),
                          ),
                          Text(
                            l10n.ntfNow,
                            style: OuroTypography.caption1.copyWith(
                              color: OuroColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          groupe ? '${l10n.ncSampleAuthor} : $texte' : texte,
                          key: ValueKey(texte),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.subheadline.copyWith(
                            color: apercu
                                ? OuroColors.label
                                : OuroColors.secondaryLabel,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La ligne qui mène à cet écran, dans la fiche d'un contact ou d'un
/// groupe. Elle dit l'état d'un coup d'œil : « Activées », « Sourdine
/// jusqu'à 18:30 », « Discrètes »…
class LigneNotifsConversation extends StatefulWidget {
  const LigneNotifsConversation({
    super.key,
    required this.conversationId,
    required this.nom,
    this.groupe = false,
  });

  final String conversationId;
  final String nom;
  final bool groupe;

  @override
  State<LigneNotifsConversation> createState() => _LigneNotifsConversationState();
}

class _LigneNotifsConversationState extends State<LigneNotifsConversation> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).toLanguageTag();
    return ValueListenableBuilder<int>(
      valueListenable: ReglagesNotifs.revision,
      builder: (context, _, _) {
        final r = ReglagesNotifs.pour(widget.conversationId);
        final maintenant = DateTime.now();
        final etat = r.enSourdine(maintenant)
            ? (r.sourdineJusqua != null
                ? libelleFinSourdine(l10n, langue, r.sourdineJusqua!)
                : l10n.ncStateMuted)
            : r.discret
                ? l10n.ncStateQuiet
                : (widget.groupe && r.mentionsSeulement)
                    ? l10n.ncStateMentions
                    : l10n.ncStateOn;
        return GestureDetector(
          onTap: () {
            OuroHaptics.selection();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NotifsConversationScreen(
                  conversationId: widget.conversationId,
                  nom: widget.nom,
                  groupe: widget.groupe,
                ),
              ),
            );
          },
          child: Semantics(
            button: true,
            label: '${l10n.ncTitle}, $etat',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OuroColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(color: OuroColors.glassBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(
                    r.enSourdine(maintenant)
                        ? Icons.notifications_off_rounded
                        : Icons.notifications_rounded,
                    color: r.enSourdine(maintenant)
                        ? OuroColors.secondaryLabel
                        : OuroColors.systemRed,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ncTitle,
                          style: TextStyle(
                            color: OuroColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          etat,
                          style: TextStyle(
                            color: OuroColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: OuroColors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
