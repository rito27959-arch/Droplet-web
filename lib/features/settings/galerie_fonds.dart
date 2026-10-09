// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Le choix du FOND DE DISCUSSION : une galerie de vignettes (gratuits,
// puis Premium), et un aperçu plein écran où l'on fait défiler les fonds
// Premium animés, avec une vraie conversation par-dessus.
//
// ── Pourquoi une galerie et plus une liste ──────────────────────────────
//
// Un fond se choisit à l'œil. Une ligne de réglage avec un carré de
// 28 points ne montrait ni ses couleurs ni son effet derrière des bulles :
// on choisissait un NOM. Chaque vignette montre donc le fond en format
// téléphone, avec deux bulles dessus.
//
// ── Pourquoi un aperçu pour les fonds Premium ───────────────────────────
//
// Leur intérêt est le mouvement, et la vignette est fixe (voir
// `VignetteFondPremium`). L'aperçu les anime, les fait tourner comme si
// des messages partaient, et se feuillette d'un glissement — qu'on les
// possède ou non. On donne envie avant de demander de payer.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/chat_background_provider.dart';
import '../../core/providers/premium_provider.dart';
import '../../design_system/liquid_bridge.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../chat/fonds_premium.dart';
import '../chat/telegram_gradient_background.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';

/// La section « Fond de discussion » des réglages.
class SectionFondsDiscussion extends ConsumerWidget {
  const SectionFondsDiscussion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final motifs = ref.watch(chatMotifsProvider);

    return OuroListSection(
      header: l10n.stChatBgHeader,
      footer: l10n.stChatBgFooter,
      children: [
        OuroListRow(
          icon: Icons.gesture_rounded,
          iconColor: motifs ? OuroColors.accent : OuroColors.systemGray,
          title: l10n.stChatPatterns,
          subtitle: l10n.stChatPatternsSubtitle,
          showChevron: false,
          trailing: LiquidGlassSwitch(
            value: motifs,
            onChanged: (actifs) {
              OuroHaptics.light();
              ref.read(chatMotifsProvider.notifier).set(actifs);
            },
          ),
        ),
        const GalerieFonds(),
      ],
    );
  }
}

class GalerieFonds extends ConsumerWidget {
  const GalerieFonds({super.key, this.conversation});

  /// Une discussion : la galerie règle alors SON fond, et propose de
  /// revenir à celui des réglages.
  final String? conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conv = conversation;
    final global = ref.watch(chatBackgroundProvider);
    final propre = conv == null ? null : ref.watch(fondConversationProvider(conv));
    final courant = conv == null ? global : propre;
    final debloque = ref.watch(packDebloqueProvider);

    void choisirGratuit(String? cle) {
      if (cle == courant) return;
      OuroHaptics.selection();
      appliquerFond(ref, cle, conversation: conv);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: LayoutBuilder(
        builder: (context, contraintes) {
          const colonnes = 3;
          const ecart = 10.0;
          final largeur =
              (contraintes.maxWidth - ecart * (colonnes - 1)) / colonnes;

          Widget grille(List<Widget> tuiles) => Wrap(
                spacing: ecart,
                runSpacing: ecart + 4,
                children: [
                  for (final t in tuiles) SizedBox(width: largeur, child: t),
                ],
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Titre(l10n.stBgFree),
              grille([
                if (conv != null)
                  _Tuile(
                    nom: l10n.stBgDefault,
                    choisi: courant == null,
                    onTap: () => choisirGratuit(null),
                    fond: _apercuDe(global, context),
                  ),
                for (final entree in TelegramGradientPalettes.etiquettes.entries)
                  _Tuile(
                    nom: entree.value,
                    choisi: entree.key == courant,
                    onTap: () => choisirGratuit(entree.key),
                    fond: Builder(
                      builder: (context) => TelegramGradientBackground(
                        tick: 0,
                        couleurs: TelegramGradientPalettes.pour(
                          entree.key,
                          sombre: Theme.of(context).brightness == Brightness.dark,
                        )!,
                      ),
                    ),
                  ),
                _Tuile(
                  nom: l10n.stBgNone,
                  choisi: courant == kFondAucun,
                  onTap: () => choisirGratuit(kFondAucun),
                  fond: ColoredBox(color: OuroColors.systemBackground),
                ),
              ]),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Titre(l10n.stBgPremium),
                  const Spacer(),
                  if (!debloque)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Icon(Icons.auto_awesome_rounded,
                          size: 16, color: OuroColors.accent),
                    ),
                ],
              ),
              grille([
                for (var i = 0; i < FondsPremium.tous.length; i++)
                  _Tuile(
                    nom: FondsPremium.tous[i].nom,
                    choisi: FondsPremium.tous[i].cle == courant && debloque,
                    verrouille: !debloque,
                    anime: true,
                    onTap: () {
                      OuroHaptics.selection();
                      Navigator.of(context).push(
                        PageRouteBuilder<void>(
                          transitionDuration: const Duration(milliseconds: 420),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          pageBuilder: (_, _, _) =>
                              ApercuFondsPremium(depart: i, conversation: conv),
                          transitionsBuilder: (_, animation, _, enfant) {
                            final courbe = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            );
                            return FadeTransition(
                              opacity: courbe,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.94, end: 1.0).animate(courbe),
                                child: enfant,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    fond: VignetteFondPremium(fond: FondsPremium.tous[i]),
                  ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

/// Le nom affiché d'un fond.
String nomDuFond(String cle, AppLocalizations l10n) {
  if (cle == kFondAucun) return l10n.stBgNone;
  return FondsPremium.trouver(cle)?.nom ??
      TelegramGradientPalettes.etiquettes[cle] ??
      cle;
}

/// La feuille « Fond de cette discussion ».
Future<void> ouvrirFondsDeDiscussion(BuildContext context, String conversation) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: OuroColors.systemGroupedBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (ctx, defilement) => ListView(
        controller: defilement,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: OuroColors.tertiaryLabel,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Text(
              AppLocalizations.of(ctx).stBgThisChat,
              style: OuroTypography.title3.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          GalerieFonds(conversation: conversation),
          SizedBox(height: MediaQuery.paddingOf(ctx).bottom + 12),
        ],
      ),
    ),
  );
}

/// Applique un fond : aux réglages, ou à une seule discussion.
void appliquerFond(WidgetRef ref, String? cle, {String? conversation}) {
  if (conversation != null) {
    ref.read(fondConversationProvider(conversation).notifier).set(cle);
  } else if (cle != null) {
    ref.read(chatBackgroundProvider.notifier).set(cle);
  }
}

/// La vignette d'un fond quelconque (gratuit, premium ou aucun).
Widget _apercuDe(String cle, BuildContext context) {
  final premium = FondsPremium.trouver(cle);
  if (premium != null) return VignetteFondPremium(fond: premium);
  final sombre = Theme.of(context).brightness == Brightness.dark;
  final couleurs = TelegramGradientPalettes.pour(cle, sombre: sombre);
  if (couleurs == null) return ColoredBox(color: OuroColors.systemBackground);
  return TelegramGradientBackground(tick: 0, couleurs: couleurs);
}

class _Titre extends StatelessWidget {
  const _Titre(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        texte,
        style: OuroTypography.footnote.copyWith(
          fontWeight: FontWeight.w600,
          color: OuroColors.secondaryLabel,
        ),
      ),
    );
  }
}

/// Une vignette : le fond au format téléphone, deux bulles, le nom.
class _Tuile extends StatefulWidget {
  const _Tuile({
    required this.nom,
    required this.choisi,
    required this.onTap,
    required this.fond,
    this.verrouille = false,
    this.anime = false,
  });

  final String nom;
  final bool choisi;
  final bool verrouille;
  final bool anime;
  final VoidCallback onTap;
  final Widget fond;

  @override
  State<_Tuile> createState() => _TuileState();
}

class _TuileState extends State<_Tuile> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      selected: widget.choisi,
      label: widget.nom,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _appui = true),
        onTapCancel: () => setState(() => _appui = false),
        onTapUp: (_) => setState(() => _appui = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _appui ? 0.95 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.choisi ? OuroColors.accent : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 0.6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        IgnorePointer(child: widget.fond),
                        // Deux bulles : on juge un fond derrière une
                        // conversation, pas tout seul.
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 16, 7, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _MiniBulle(
                                largeur: 0.62,
                                couleur: sombre
                                    ? const Color(0xFF1C1C1E)
                                    : Colors.white,
                                aGauche: true,
                              ),
                              const SizedBox(height: 5),
                              _MiniBulle(
                                largeur: 0.5,
                                couleur: OuroColors.bubbleOutgoing,
                                aGauche: false,
                              ),
                            ],
                          ),
                        ),
                        if (widget.anime)
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: _Pastille(
                              icone: widget.verrouille
                                  ? Icons.lock_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                        if (widget.choisi)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: OuroColors.accentRempli,
                              ),
                              child: Icon(Icons.check_rounded,
                                  size: 14, color: OuroColors.texteSurAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.nom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.caption1.copyWith(
                  fontWeight: widget.choisi ? FontWeight.w700 : FontWeight.w500,
                  color: widget.choisi ? OuroColors.accent : OuroColors.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBulle extends StatelessWidget {
  const _MiniBulle({
    required this.largeur,
    required this.couleur,
    required this.aGauche,
  });

  final double largeur;
  final Color couleur;
  final bool aGauche;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: aGauche ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: largeur,
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.icone});

  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.35),
      ),
      child: Icon(icone, size: 12, color: Colors.white),
    );
  }
}

// ── L'aperçu plein écran ───────────────────────────────────────────────────

class ApercuFondsPremium extends ConsumerStatefulWidget {
  const ApercuFondsPremium({super.key, this.depart = 0, this.conversation});

  final int depart;

  /// Si présent, « Utiliser ce fond » ne vaut que pour cette discussion.
  final String? conversation;

  @override
  ConsumerState<ApercuFondsPremium> createState() => _ApercuFondsPremiumState();
}

class _ApercuFondsPremiumState extends ConsumerState<ApercuFondsPremium> {
  late final PageController _pages = PageController(initialPage: widget.depart);
  late int _index = widget.depart;
  int _tick = 0;
  Timer? _demo;

  @override
  void initState() {
    super.initState();
    // Comme si des messages partaient : on voit les couleurs tourner.
    _demo = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _demo?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final debloque = ref.watch(packDebloqueProvider);
    final conv = widget.conversation;
    final courant = conv == null
        ? ref.watch(chatBackgroundProvider)
        : ref.watch(fondConversationProvider(conv));
    final fond = FondsPremium.tous[_index];
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final dejaChoisi = debloque && courant == fond.cle;
    final texteSurFond = sombre ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: FondsPremium.tous.length,
            onPageChanged: (i) {
              OuroHaptics.selection();
              setState(() => _index = i);
            },
            itemBuilder: (_, i) =>
                FondPremiumAnime(fond: FondsPremium.tous[i], tick: _tick),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                  child: Row(
                    children: [
                      OuroIconButton(
                        icon: Icon(Icons.close_rounded, color: texteSurFond),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            fond.nom,
                            key: ValueKey(fond.cle),
                            style: OuroTypography.headline.copyWith(color: texteSurFond),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _BulleApercu(
                          texte: l10n.stBgPreviewIncoming,
                          sortante: false,
                          sombre: sombre,
                        ),
                        const SizedBox(height: 8),
                        _BulleApercu(
                          texte: l10n.stBgPreviewOutgoing,
                          sortante: true,
                          sombre: sombre,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _Points(nombre: FondsPremium.tous.length, actif: _index, couleur: texteSurFond),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.stBgPreviewHint,
                    textAlign: TextAlign.center,
                    style: OuroTypography.footnote.copyWith(
                      color: texteSurFond.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OuroRetourIos(child: FilledButton.icon(
                      style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
                        backgroundColor: sombre ? Colors.white : Colors.black,
                        foregroundColor: sombre ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: OuroTypography.headline,
                      ),
                      icon: Icon(
                        !debloque
                            ? Icons.auto_awesome_rounded
                            : dejaChoisi
                            ? Icons.check_rounded
                            : Icons.wallpaper_rounded,
                      ),
                      label: Text(
                        !debloque
                            ? l10n.stBgUnlock
                            : dejaChoisi
                            ? l10n.stBgApplied
                            : l10n.stBgApply,
                      ),
                      onPressed: dejaChoisi
                          ? null
                          : () {
                              if (!debloque) {
                                OuroHaptics.selection();
                                context.push('/premium');
                                return;
                              }
                              OuroHaptics.success();
                              appliquerFond(
                                ref,
                                fond.cle,
                                conversation: widget.conversation,
                              );
                              Navigator.of(context).pop();
                            },
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulleApercu extends StatelessWidget {
  const _BulleApercu({
    required this.texte,
    required this.sortante,
    required this.sombre,
  });

  final String texte;
  final bool sortante;
  final bool sombre;

  @override
  Widget build(BuildContext context) {
    final fond = sortante
        ? OuroColors.bubbleOutgoing
        : (sombre ? const Color(0xFF1C1C1E) : Colors.white);
    final encre = sortante || sombre ? Colors.white : Colors.black;
    return Align(
      alignment: sortante ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: fond,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(sortante ? 18 : 5),
              bottomRight: Radius.circular(sortante ? 5 : 18),
            ),
          ),
          child: Text(texte, style: OuroTypography.body.copyWith(color: encre)),
        ),
      ),
    );
  }
}

class _Points extends StatelessWidget {
  const _Points({required this.nombre, required this.actif, required this.couleur});

  final int nombre;
  final int actif;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < nombre; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == actif ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: i == actif ? 0.9 : 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
