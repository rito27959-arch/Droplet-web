// ============================================================================
// L'ÉCRAN « APPARENCE » — celui de Telegram, remis dans les codes d'iOS.
// ----------------------------------------------------------------------------
// Telegram réunit sur une seule page tout ce qui change l'allure des
// discussions, et pose au-dessus un APERÇU EN DIRECT : deux bulles sur le
// fond choisi, qui se déforment pendant qu'on fait glisser un curseur. On
// ne règle pas un nombre, on regarde le résultat.
//
// La même page ici, dans le même ordre :
//
//   1. l'aperçu ;
//   2. la taille du texte des messages (12 → 30) ;
//   3. le thème (Automatique / Clair / Sombre) ;
//   4. la couleur d'accent ;
//   5. l'arrondi des bulles (0 → 20) ;
//   6. le fond de discussion (la galerie) ;
//   7. l'affichage de la liste des discussions (deux ou trois lignes) ;
//   8. l'icône de l'application.
//
// ⚠️ TOUT EST IMMÉDIAT. Aucun bouton « Appliquer » : chaque geste repeint
// l'app entière (voir `personnalisation_provider.dart`). Un réglage
// d'apparence qu'il faut valider est un réglage qu'on n'essaie pas.
// ============================================================================


import 'package:flutter/cupertino.dart' show CupertinoSlider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/appearance_provider.dart';
import '../../core/providers/chat_background_provider.dart';
import '../../core/providers/personnalisation_provider.dart';
import '../../core/providers/premium_provider.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/reglages_apparence.dart';
import '../../l10n/generated/app_localizations.dart';
import '../chat/fonds_premium.dart';
import '../chat/telegram_gradient_background.dart';
import 'galerie_fonds.dart';
import '../chat/motifs_droplet.dart';

class ApparenceScreen extends ConsumerWidget {
  const ApparenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final perso = ref.watch(personnalisationProvider);
    final notifier = ref.read(personnalisationProvider.notifier);

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      appBar: AppBar(title: Text(l10n.sectionAppearance)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          const _ApercuApparence(),
          const SizedBox(height: DesignTokens.space5),

          _Curseur(
            titre: l10n.stTextSize,
            repereTexte: true,
            valeur: perso.tailleTexte,
            min: ReglagesApparence.tailleTexteMin,
            max: ReglagesApparence.tailleTexteMax,
            onChanged: (v) => notifier.modifier(perso.copyWith(tailleTexte: v)),
          ),
          const SizedBox(height: DesignTokens.space5),

          _SectionMotifs(
            choisi: perso.packMotifs,
            onChoisir: (i) => notifier.modifier(perso.copyWith(packMotifs: i)),
          ),
          const SizedBox(height: DesignTokens.space5),

          const _SectionTheme(),
          const SizedBox(height: DesignTokens.space5),

          const SizedBox(height: DesignTokens.space5),

          _SectionAccent(
            choisi: perso.accent,
            onChoisir: (cle) => notifier.modifier(perso.copyWith(accent: cle)),
          ),
          const SizedBox(height: DesignTokens.space5),

          _Curseur(
            titre: l10n.stBubbleCorners,
            valeur: perso.rayonBulles,
            min: ReglagesApparence.rayonMin,
            max: ReglagesApparence.rayonMax,
            onChanged: (v) => notifier.modifier(perso.copyWith(rayonBulles: v)),
          ),
          const SizedBox(height: DesignTokens.space5),

          const SectionFondsDiscussion(),
          const SizedBox(height: DesignTokens.space5),

          _SectionLignes(
            lignes: perso.lignesListe,
            onChoisir: (n) => notifier.modifier(perso.copyWith(lignesListe: n)),
          ),
          const SizedBox(height: DesignTokens.space5),

          OuroListSection(
            header: l10n.stIconHeader,
            children: [
              OuroListRow(
                icon: Icons.apps_rounded,
                iconColor: OuroColors.systemPink,
                title: l10n.stAppIcon,
                subtitle: l10n.stVariants13,
                onTap: () => context.push('/settings/icon'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space5),

          OuroListSection(
            children: [
              OuroListRow(
                icon: Icons.restart_alt_rounded,
                iconColor: OuroColors.systemGray,
                title: l10n.stResetAppearance,
                showChevron: false,
                onTap: () {
                  OuroHaptics.medium();
                  notifier.reinitialiser();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// L'aperçu : le fond réel, deux bulles, la taille et l'arrondi du moment.
class _ApercuApparence extends ConsumerWidget {
  const _ApercuApparence();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fond = ref.watch(chatBackgroundProvider);
    final debloque = ref.watch(packDebloqueProvider);
    // Écouté pour que l'aperçu se redessine à chaque glissement.
    ref.watch(personnalisationProvider);
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final premium = FondsPremium.trouver(fond);
    final couleurs = TelegramGradientPalettes.pour(fond, sombre: sombre);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 186,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (premium != null && debloque)
                VignetteFondPremium(fond: premium)
              else if (couleurs != null)
                TelegramGradientBackground(tick: 0, couleurs: couleurs)
              else
                ColoredBox(color: OuroColors.systemBackground),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BulleApercu(texte: l10n.stPreviewIncoming, mine: false),
                    const SizedBox(height: 8),
                    _BulleApercu(texte: l10n.stPreviewOutgoing, mine: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulleApercu extends StatelessWidget {
  const _BulleApercu({required this.texte, required this.mine});

  final String texte;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final rayon = ReglagesApparence.rayonBulles;
    final queue = ReglagesApparence.rayonQueue;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.62,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: mine
              ? OuroColors.bubbleOutgoing
              : OuroColors.secondarySystemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(rayon),
            topRight: Radius.circular(rayon),
            bottomLeft: Radius.circular(mine ? rayon : queue),
            bottomRight: Radius.circular(mine ? queue : rayon),
          ),
        ),
        child: Text(
          texte,
          style: TextStyle(
            color: mine ? Colors.white : OuroColors.label,
            fontSize: ReglagesApparence.tailleTexte,
            height: ReglagesApparence.interligne,
          ),
        ),
      ),
    );
  }
}

/// Un curseur de réglage, en style iOS.
///
/// ⚠️ PAS LE CURSEUR DE MATERIAL. Celui-ci affichait un gros pastillon et
/// une graduation en pointillés — un vocabulaire Android au milieu d'une
/// page qui suit les réglages d'iOS. `CupertinoSlider` donne la bonne
/// pastille et la bonne piste ; les crans restent, mais ne se voient plus.
class _Curseur extends StatelessWidget {
  const _Curseur({
    required this.titre,
    required this.valeur,
    required this.min,
    required this.max,
    required this.onChanged,
    this.repereTexte = false,
  });

  final String titre;
  final double valeur;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  /// Les deux « A » d'iOS, de part et d'autre de la piste.
  final bool repereTexte;

  @override
  Widget build(BuildContext context) {
    return OuroListSection(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Row(
            children: [
              Text(titre, style: OuroTypography.body),
              const Spacer(),
              Text(
                valeur.round().toString(),
                style: OuroTypography.body.copyWith(
                  color: OuroColors.secondaryLabel,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
          child: Row(
            children: [
              if (repereTexte) ...[
                Text('A', style: TextStyle(fontSize: 13, color: OuroColors.secondaryLabel)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: CupertinoSlider(
                  value: valeur.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: (max - min).round(),
                  activeColor: OuroColors.accent,
                  onChanged: (v) {
                    if (v.round() != valeur.round()) OuroHaptics.selection();
                    onChanged(v.roundToDouble());
                  },
                ),
              ),
              if (repereTexte) ...[
                const SizedBox(width: 10),
                Text('A', style: TextStyle(fontSize: 21, color: OuroColors.secondaryLabel)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTheme extends ConsumerWidget {
  const _SectionTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(appearanceProvider);
    final libelles = {
      AppearanceMode.system: l10n.appearanceAuto,
      AppearanceMode.light: l10n.appearanceLight,
      AppearanceMode.dark: l10n.appearanceDark,
    };
    return OuroListSection(
      header: l10n.sectionAppearance,
      footer: l10n.appearanceFooter,
      children: [
        for (final entree in libelles.entries)
          OuroListRow(
            title: entree.value,
            showChevron: false,
            trailing: entree.key == mode
                ? Icon(Icons.check_rounded, size: 20, color: OuroColors.accent)
                : const SizedBox(width: 20),
            onTap: () {
              OuroHaptics.selection();
              ref.read(appearanceProvider.notifier).set(entree.key);
            },
          ),
      ],
    );
  }
}

class _SectionAccent extends StatelessWidget {
  const _SectionAccent({required this.choisi, required this.onChoisir});

  final String choisi;
  final ValueChanged<String> onChoisir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return OuroListSection(
      header: l10n.stAccentHeader,
      footer: l10n.stAccentFooter,
      children: [
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ReglagesApparence.accents.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final accent = ReglagesApparence.accents[i];
              final actif = accent.cle == choisi;
              return GestureDetector(
                onTap: () {
                  if (actif) return;
                  OuroHaptics.selection();
                  onChoisir(accent.cle);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.pour(sombre: sombre),
                    border: Border.all(
                      color: actif
                          ? OuroColors.label
                          : Colors.black.withValues(alpha: 0.08),
                      width: actif ? 2.5 : 0.5,
                    ),
                  ),
                  child: actif
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionLignes extends StatelessWidget {
  const _SectionLignes({required this.lignes, required this.onChoisir});

  final int lignes;
  final ValueChanged<int> onChoisir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListSection(
      header: l10n.stChatListHeader,
      children: [
        for (final n in [2, 3])
          OuroListRow(
            title: n == 2 ? l10n.stChatListTwoLines : l10n.stChatListThreeLines,
            showChevron: false,
            trailing: n == lignes
                ? Icon(Icons.check_rounded, size: 20, color: OuroColors.accent)
                : const SizedBox(width: 20),
            onTap: () {
              if (n == lignes) return;
              OuroHaptics.selection();
              onChoisir(n);
            },
          ),
      ],
    );
  }
}

/// Le choix du papier peint des discussions, façon Telegram.
///
/// Chaque vignette est une petite discussion : le vrai fond, une bulle
/// reçue, une bulle envoyée en dégradé d'accent. L'emblème en bas à gauche
/// est un dessin PRIS DANS LE PACK — pas une icône générique.
///
/// La sélection se voit à trois choses : l'anneau d'accent, la pastille
/// cochée qui apparaît en ressort, et la vignette qui grandit d'un cheveu.
/// L'appui enfonce la carte, comme une touche iOS.
class _SectionMotifs extends StatelessWidget {
  const _SectionMotifs({required this.choisi, required this.onChoisir});

  final int choisi;
  final ValueChanged<int> onChoisir;

  static const List<PackMotifs> _packs = PackMotifs.values;

  static String _libelle(AppLocalizations l10n, PackMotifs pack) => switch (pack) {
        PackMotifs.jeux => l10n.apPatternGames,
        PackMotifs.maison => l10n.apPatternHome,
        PackMotifs.jardin => l10n.apPatternGarden,
        PackMotifs.droplet => l10n.apPatternDroplet,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListSection(
      header: l10n.apPatternsHeader,
      footer: l10n.apPatternsFooter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
          child: SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _packs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _CarteMotifs(
                pack: _packs[i],
                libelle: _libelle(l10n, _packs[i]),
                choisi: i == choisi,
                onTap: () => onChoisir(i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarteMotifs extends StatefulWidget {
  const _CarteMotifs({
    required this.pack,
    required this.libelle,
    required this.choisi,
    required this.onTap,
  });

  final PackMotifs pack;
  final String libelle;
  final bool choisi;
  final VoidCallback onTap;

  @override
  State<_CarteMotifs> createState() => _CarteMotifsState();
}

class _CarteMotifsState extends State<_CarteMotifs> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final accent = OuroColors.accent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      onTap: () {
        OuroHaptics.selection();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _appui ? 0.955 : (widget.choisi ? 1.02 : 1),
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 96,
              height: 124,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: widget.choisi ? accent : OuroColors.separator,
                  width: widget.choisi ? 2.5 : 1,
                ),
                boxShadow: widget.choisi
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: sombre
                          ? OuroColors.systemGroupedBackground
                          : OuroColors.secondarySystemGroupedBackground,
                    ),
                    CalqueMotifsDroplet(
                      pack: widget.pack,
                      couleur: MotifsDroplet.couleur(sombre: sombre),
                    ),
                    // Deux bulles : on juge un fond avec ce qui se pose
                    // dessus, jamais tout seul.
                    Align(
                      alignment: const Alignment(-0.85, -0.45),
                      child: Container(
                        width: 44,
                        height: 17,
                        decoration: BoxDecoration(
                          color: OuroColors.tertiarySystemFill,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.85, 0.05),
                      child: Container(
                        width: 52,
                        height: 17,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent,
                              Color.lerp(accent, Colors.black, 0.22)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    // L'emblème du pack : son premier dessin, peint.
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CustomPaint(
                          painter: _EmblemePack(
                            pack: widget.pack,
                            couleur: OuroColors.label.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                    // La coche, qui arrive en ressort.
                    Positioned(
                      right: 6,
                      top: 6,
                      child: AnimatedScale(
                        scale: widget.choisi ? 1 : 0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.elasticOut,
                        child: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: OuroTypography.footnote.copyWith(
                color: widget.choisi ? OuroColors.accent : OuroColors.secondaryLabel,
                fontWeight: widget.choisi ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(widget.libelle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le premier dessin du pack, tracé dans un carré : chaque pack se
/// reconnaît à son emblème.
class _EmblemePack extends CustomPainter {
  const _EmblemePack({required this.pack, required this.couleur});

  final PackMotifs pack;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final chemin = MotifsDroplet.tracesDe(pack).first();
    final echelle = size.width / 24;
    canvas.save();
    canvas.scale(echelle);
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 / echelle
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..color = couleur,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmblemePack ancien) =>
      ancien.pack != pack || ancien.couleur != couleur;
}
