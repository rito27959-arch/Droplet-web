// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE CENTRE DE NOTIFICATIONS — tout ce qui s'est passé et que la liste des
// conversations ne dit pas : qui vous a mentionné, qui a réagi à vos
// messages, qui a essayé d'appeler, ce que Droplet a annoncé.
//
// ── LA MISE EN PAGE D'iOS ───────────────────────────────────────────────
//
//   • PAR JOUR — « Aujourd'hui », « Hier », puis la date. On cherche
//     « ce truc de mardi », pas « la 14e notification ».
//   • EN PILES PAR CONVERSATION — cinq réactions du même groupe forment
//     une seule carte, avec deux autres qui dépassent dessous. Un toucher
//     déplie la pile. C'est ce qui empêche un groupe bavard d'enterrer
//     l'appel manqué de sa mère.
//   • BALAYER POUR EFFACER — une carte à la fois, ou tout d'un coup en
//     haut à droite.
//
// ── ⚠️ LE POINT « NON LU » SURVIT À L'OUVERTURE ─────────────────────────
//
// Tout est marqué lu dès l'ouverture de l'écran (sinon la pastille de la
// cloche ne s'éteindrait jamais). Mais les points bleus restent affichés
// jusqu'à ce qu'on quitte l'écran : on les note à l'arrivée. Les effacer
// d'un coup rendrait illisible la seule chose qu'on venait chercher —
// « qu'est-ce qui est nouveau ? ».
// ============================================================================

import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/services/avatar_service.dart';
import '../../core/services/journal_notifs.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/avatar_officiel.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';

class CentreNotifsScreen extends StatefulWidget {
  const CentreNotifsScreen({super.key});

  @override
  State<CentreNotifsScreen> createState() => _CentreNotifsScreenState();
}

class _CentreNotifsScreenState extends State<CentreNotifsScreen> {
  final JournalNotifs _journal = JournalNotifs.instance;

  /// Ce qui était nouveau en arrivant (voir l'en-tête).
  late final Set<String> _nouvelles = {
    for (final e in _journal.entrees)
      if (!e.lu) e.id,
  };

  /// Les piles dépliées, par « jour|conversation ».
  final Set<String> _ouvertes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_journal.marquerToutLu());
    });
  }

  Future<void> _toutEffacer() async {
    final l10n = AppLocalizations.of(context);
    final ok = await ouroConfirm(
      context,
      title: l10n.cnClearAllTitle,
      message: l10n.cnClearAllBody,
      confirmLabel: l10n.cnClearAll,
      destructive: true,
    );
    if (ok != true) return;
    OuroHaptics.medium();
    await _journal.vider();
  }

  void _ouvrir(EntreeNotif e) {
    OuroHaptics.selection();
    if (e.route.isEmpty) return;
    context.push(e.route);
  }

  /// Les entrées, rangées par jour puis par conversation — dans l'ordre
  /// d'arrivée de la plus récente de chaque pile.
  List<({DateTime jour, List<List<EntreeNotif>> piles})> _ranger(
    List<EntreeNotif> entrees,
  ) {
    final jours = <DateTime, Map<String, List<EntreeNotif>>>{};
    for (final e in entrees) {
      final j = DateTime(e.quand.year, e.quand.month, e.quand.day);
      (jours.putIfAbsent(j, () => {})[e.conversationId] ??= []).add(e);
    }
    final ordre = jours.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final j in ordre) (jour: j, piles: jours[j]!.values.toList()),
    ];
  }

  String _titreJour(AppLocalizations l10n, String langue, DateTime jour) {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final ecart = aujourdhui.difference(jour).inDays;
    if (ecart == 0) return l10n.chToday;
    if (ecart == 1) return l10n.chYesterday;
    final texte = DateFormat.MMMMEEEEd(langue).format(jour);
    return texte.isEmpty ? texte : texte[0].toUpperCase() + texte.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).toLanguageTag();
    return ListenableBuilder(
      listenable: _journal,
      builder: (context, _) {
        final entrees = _journal.entrees;
        final jours = _ranger(entrees);
        return OuroLargeTitleScaffold(
          title: l10n.cnTitle,
          backgroundColor: OuroColors.systemGroupedBackground,
          leading: const OuroBackButton(),
          actions: [
            if (entrees.isNotEmpty)
              OuroBarButton(
                icon: Icons.clear_all_rounded,
                tooltip: l10n.cnClearAll,
                onPressed: _toutEffacer,
              ),
          ],
          slivers: [
            if (entrees.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Vide(l10n: l10n),
              )
            else
              for (final j in jours) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Text(
                      _titreJour(l10n, langue, j.jour),
                      style: OuroTypography.title3.copyWith(
                        color: OuroColors.label,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList.separated(
                    itemCount: j.piles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final pile = j.piles[i];
                      final cle = '${j.jour.millisecondsSinceEpoch}|${pile.first.conversationId}';
                      return _Pile(
                        entrees: pile,
                        ouverte: _ouvertes.contains(cle),
                        nouvelles: _nouvelles,
                        langue: langue,
                        onBascule: () {
                          OuroHaptics.selection();
                          setState(() {
                            if (!_ouvertes.remove(cle)) _ouvertes.add(cle);
                          });
                        },
                        onOuvrir: _ouvrir,
                        onSupprimer: (e) {
                          OuroHaptics.light();
                          unawaited(_journal.supprimer(e.id));
                        },
                      );
                    },
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

class _Vide extends StatelessWidget {
  const _Vide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SceneAnimee(
            emoji: Scenes.toutVaBien,
            iconeDeSecours: Icons.notifications_none_rounded,
            taille: 72,
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            l10n.cnEmptyTitle,
            textAlign: TextAlign.center,
            style: OuroTypography.title3.copyWith(
              color: OuroColors.label,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cnEmptyBody,
            textAlign: TextAlign.center,
            style: OuroTypography.subheadline.copyWith(
              color: OuroColors.secondaryLabel,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Une pile : les entrées d'une conversation sur une journée.
class _Pile extends StatelessWidget {
  const _Pile({
    required this.entrees,
    required this.ouverte,
    required this.nouvelles,
    required this.langue,
    required this.onBascule,
    required this.onOuvrir,
    required this.onSupprimer,
  });

  final List<EntreeNotif> entrees;
  final bool ouverte;
  final Set<String> nouvelles;
  final String langue;
  final VoidCallback onBascule;
  final void Function(EntreeNotif) onOuvrir;
  final void Function(EntreeNotif) onSupprimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premiere = entrees.first;

    Widget carte(EntreeNotif e, {int autres = 0, VoidCallback? onTap}) =>
        Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onSupprimer(e),
          background: _FondSuppression(libelle: l10n.cnDelete),
          child: _Carte(
            entree: e,
            nouvelle: nouvelles.contains(e.id),
            langue: langue,
            autres: autres,
            onTap: onTap ?? () => onOuvrir(e),
          ),
        );

    if (entrees.length == 1) return carte(premiere);

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ouverte
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // L'en-tête de la pile dépliée : de qui, et le moyen de la
                // replier — comme le « Afficher moins » d'iOS.
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 4, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          premiere.nomConversation ?? premiere.auteur,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.headline.copyWith(
                            color: OuroColors.label,
                          ),
                        ),
                      ),
                      _Pastille(texte: l10n.cnShowLess, onTap: onBascule),
                    ],
                  ),
                ),
                for (final (i, e) in entrees.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  carte(e),
                ],
              ],
            )
          // ── REPLIÉE : UNE CARTE, ET LE BORD DE DEUX AUTRES ─────────
          : GestureDetector(
              onTap: onBascule,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (rang, retrait) in [(2, 20.0), (1, 10.0)])
                    if (entrees.length > rang)
                      Positioned(
                        left: retrait,
                        right: retrait,
                        bottom: rang * -7.0,
                        height: 40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: OuroColors.secondarySystemGroupedBackground
                                .withValues(alpha: rang == 1 ? 0.85 : 0.6),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: OuroColors.isDark ? 0.25 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: entrees.length > 2 ? 14 : 7,
                    ),
                    child: carte(
                      premiere,
                      autres: entrees.length - 1,
                      onTap: onBascule,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({
    required this.entree,
    required this.nouvelle,
    required this.langue,
    required this.onTap,
    this.autres = 0,
  });

  final EntreeNotif entree;
  final bool nouvelle;
  final String langue;
  final VoidCallback onTap;

  /// Combien d'autres entrées la pile cache.
  final int autres;

  String _phrase(AppLocalizations l10n) => switch (entree.type) {
        TypeEntreeNotif.mention => l10n.cnMentioned,
        TypeEntreeNotif.reaction => l10n.cnReacted(entree.emoji ?? '❤️'),
        TypeEntreeNotif.appelManque => l10n.ntfMissedCall,
        TypeEntreeNotif.annonce => l10n.cnAnnouncement,
        TypeEntreeNotif.reponseStatut => l10n.cnStatusReply,
        TypeEntreeNotif.jaimeStatut => l10n.cnStatusLike,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final e = entree;
    final heure = DateFormat.Hm(langue).format(e.quand);
    final phrase = _phrase(l10n);
    final extrait = e.texte.trim();

    return Semantics(
      button: true,
      label: [
        e.auteur,
        phrase,
        if (extrait.isNotEmpty) extrait,
        heure,
      ].join(', '),
      child: Material(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VisageEntree(entree: e),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: e.auteur,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  if (e.groupe && e.nomConversation != null)
                                    TextSpan(
                                      text: ' · ${e.nomConversation}',
                                      style: TextStyle(color: OuroColors.secondaryLabel),
                                    ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OuroTypography.subheadline.copyWith(
                                color: OuroColors.label,
                              ),
                            ),
                          ),
                          if (nouvelle)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: OuroColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            heure,
                            style: OuroTypography.caption1.copyWith(
                              color: OuroColors.secondaryLabel,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phrase,
                        style: OuroTypography.subheadline.copyWith(
                          color: OuroColors.label,
                        ),
                      ),
                      if (extrait.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          // Les guillemets de la langue : « » en français,
                          // “ ” en anglais… fournis par la traduction.
                          l10n.cnQuoted(extrait),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.footnote.copyWith(
                            color: OuroColors.secondaryLabel,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (autres > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.cnMore(autres),
                          style: OuroTypography.caption1.copyWith(
                            color: OuroColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

/// L'avatar, et en pastille ce qui s'est passé.
class _VisageEntree extends StatelessWidget {
  const _VisageEntree({required this.entree});

  final EntreeNotif entree;

  @override
  Widget build(BuildContext context) {
    final e = entree;
    if (e.type == TypeEntreeNotif.annonce) {
      return const AvatarOfficiel(rayon: 19);
    }
    final visage = PeerAvatar(
      pseudo: e.auteur,
      radius: 19,
      imagePath: AvatarService.cheminPair(e.auteurId),
    );
    final Widget? badge = switch (e.type) {
      TypeEntreeNotif.reaction => Text(
          e.emoji ?? '❤️',
          style: const TextStyle(fontSize: 12, height: 1),
        ),
      TypeEntreeNotif.mention => Icon(
          Icons.alternate_email_rounded,
          size: 12,
          color: OuroColors.texteSurAccent,
        ),
      TypeEntreeNotif.appelManque => const Icon(
          Icons.call_missed_rounded,
          size: 12,
          color: Colors.white,
        ),
      TypeEntreeNotif.reponseStatut => Icon(
          Icons.reply_rounded,
          size: 12,
          color: OuroColors.texteSurAccent,
        ),
      TypeEntreeNotif.jaimeStatut => const Icon(
          Icons.favorite_rounded,
          size: 11,
          color: Colors.white,
        ),
      TypeEntreeNotif.annonce => null,
    };
    final fond = switch (e.type) {
      TypeEntreeNotif.reaction => OuroColors.secondarySystemGroupedBackground,
      TypeEntreeNotif.appelManque => OuroColors.systemRed,
      TypeEntreeNotif.jaimeStatut => OuroColors.systemPink,
      _ => OuroColors.accentRempli,
    };
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          visage,
          if (badge != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fond,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: OuroColors.secondarySystemGroupedBackground,
                    width: 2,
                  ),
                ),
                child: badge,
              ),
            ),
        ],
      ),
    );
  }
}

class _FondSuppression extends StatelessWidget {
  const _FondSuppression({required this.libelle});

  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: OuroColors.systemRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        libelle,
        style: OuroTypography.subheadline.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.texte, required this.onTap});

  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: OuroColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            texte,
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.label,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
