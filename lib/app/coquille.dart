// LA COQUILLE DE DROPLET WEB — la disposition de WhatsApp Web, la finition
// d'iOS.
//
//   ┌────┬───────────────┬──────────────────────────────┬─────────────┐
//   │rail│  la colonne   │        la discussion         │  les infos  │
//   │    │  de l'onglet  │  (ou l'accueil de l'onglet)  │ (facultatif)│
//   └────┴───────────────┴──────────────────────────────┴─────────────┘
//
//   • Le RAIL reprend les onglets de l'app : Discussions (le logo de
//     Droplet, gris au repos, en couleur actif), Actus, Appels, Réglages et
//     la photo de profil.
//   • Chaque onglet a SA PILE de panneaux dans la colonne de gauche, comme
//     les onglets d'iPhone : on peut ouvrir les archives, passer aux
//     appels, revenir — les archives sont toujours là.
//   • La discussion ouverte reste à droite quel que soit l'onglet.
//   • Sous 900 points de large, une seule colonne à la fois et la barre
//     d'onglets en bas, comme sur iPhone.
//
// Les raccourcis clavier sont ceux de WhatsApp Web (Ctrl+Alt+N…).
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/modeles.dart';
import '../donnees/transport.dart';
import '../fond/goutte.dart';
import '../web/navigateur.dart';
import 'actus.dart';
import 'appels.dart';
import 'composants.dart';
import 'liste_discussions.dart';
import 'nouvelle_discussion.dart';
import 'panneau_infos.dart';
import 'portee.dart';
import 'reglages.dart';
import 'vue_discussion.dart';

/// La matière de la barre latérale (rail et colonne) sur grand écran : le
/// gris de la barre latérale du Mac, la discussion restant sur le blanc
/// (ou le noir) pur. Sur téléphone, la liste est sur le fond de liste
/// d'iOS.
Color fondBarreLaterale(BuildContext context) {
  final large = MediaQuery.sizeOf(context).width >= 900;
  if (!large) return OuroColors.secondarySystemGroupedBackground;
  return OuroColors.isDark ? const Color(0xFF161618) : const Color(0xFFF4F4F7);
}

/// Pousser un panneau dans la colonne de gauche de l'onglet actif.
void pousserPanneau(BuildContext context, Widget panneau) {
  // Déjà dans le détail de droite (Réglages sur grand écran) : la page
  // suivante s'y empile, pas dans la colonne de gauche.
  if (DetailDroit.dedans(context)) {
    Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => DetailDroit.centre(panneau)));
    return;
  }
  context.lire.ui.cleGauche.currentState?.push(CupertinoPageRoute<void>(builder: (_) => panneau));
}

/// Ouvre une page des Réglages : à droite et en grand sur un grand écran
/// (la section reste surlignée à gauche), sinon dans la colonne, comme sur
/// iPhone.
void ouvrirReglage(BuildContext context, String section, Widget panneau) {
  final ui = context.lire.ui;
  final detail = ui.cleDetail.currentState;
  if (MediaQuery.sizeOf(context).width >= 900 && detail != null) {
    if (ui.section == section) return;
    ui.section = section;
    ui.rafraichir();
    detail.pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => DetailDroit.centre(panneau),
        transitionsBuilder: (_, a, __, enfant) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween(begin: const Offset(0.012, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: kSortie)),
            child: enfant,
          ),
        ),
      ),
      (_) => false,
    );
    return;
  }
  pousserPanneau(context, panneau);
}

/// Le détail de droite des Réglages : une page y est « à la racine » (grand
/// titre, sans chevron de retour), le contenu centré sur une largeur lisible.
class DetailDroit extends InheritedWidget {
  const DetailDroit({super.key, required super.child});

  static bool dedans(BuildContext context) => context.getInheritedWidgetOfExactType<DetailDroit>() != null;

  /// Une page du détail, sur une largeur lisible (720 px), comme Réglages
  /// sur un grand iPad : pas de lignes de 1 000 px de large.
  static Widget centre(Widget page) => ColoredBox(
        color: OuroColors.secondarySystemGroupedBackground,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Defilement(child: page)),
        ),
      );

  @override
  bool updateShouldNotify(DetailDroit oldWidget) => false;
}

/// Ouvrir une discussion, d'où que l'on soit.
void ouvrirDiscussion(BuildContext context, String id, {String? message}) {
  final p = context.lire;
  if (p.depot.discussionOuverte != id) p.ui.nonLusOuverture = p.depot.discussions[id]?.nonLus ?? 0;
  p.depot.ouvrir(id);
  p.ui.rechercheDiscussion = false;
  p.ui.messageCible = message;
  p.ui.rafraichir();
}

class Coquille extends StatefulWidget {
  const Coquille({super.key, required this.onDeconnexion});

  /// « Se déconnecter » : retour à l'écran de liaison.
  final VoidCallback onDeconnexion;

  @override
  State<Coquille> createState() => _CoquilleState();
}

class _CoquilleState extends State<Coquille> {
  final Set<Onglet> _visites = {Onglet.discussions};

  @override
  Widget build(BuildContext context) {
    final p = Portee.of(context);
    final depot = p.depot;
    final ui = p.ui;
    _visites.add(ui.onglet);
    final largeur = MediaQuery.sizeOf(context).width;
    final large = largeur >= 900;
    // Comme Réglages ou Messages sur iPad : le détail suit la section. Une
    // discussion ne reste à droite que dans l'onglet Discussions — dans
    // Actus, Appels ou Réglages, on retrouvait la dernière discussion ouverte.
    final ouverte = depot.discussionOuverte == null || (large && ui.onglet != Onglet.discussions)
        ? null
        : depot.discussions[depot.discussionOuverte];
    final colonne = (largeur * 0.3).clamp(340.0, 440.0);

    final gauche = IndexedStack(
      index: ui.onglet.index,
      children: [
        for (final o in Onglet.values)
          _visites.contains(o)
              ? HeroControllerScope.none(
                  child: Navigator(
                    key: ui.cles[o],
                    onGenerateInitialRoutes: (_, __) => [
                      CupertinoPageRoute<void>(builder: (_) => _racine(o)),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
      ],
    );

    Widget droite;
    if (ouverte != null) {
      final infosColonne = ui.infos && largeur >= 1280;
      final infosDessus = ui.infos && !infosColonne;
      droite = Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: VueDiscussion(
                    key: ValueKey(ouverte.id),
                    discussion: ouverte,
                    onRetour: large ? null : () => depot.ouvrir(null),
                  ),
                ),
                // Sur un écran moyen, les infos glissent par-dessus la
                // discussion, depuis la droite.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: large ? 400 : largeur,
                  child: IgnorePointer(
                    ignoring: !infosDessus,
                    child: AnimatedSlide(
                      offset: infosDessus ? Offset.zero : const Offset(1.05, 0),
                      duration: const Duration(milliseconds: 380),
                      curve: kSortie,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (infosDessus)
                              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30),
                          ],
                        ),
                        child: PanneauInfos(discussion: ouverte),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: kSortie,
            width: infosColonne ? 380 : 0,
            child: infosColonne
                ? Row(
                    children: [
                      VerticalDivider(width: 0.5, thickness: 0.5, color: OuroColors.separator),
                      Expanded(child: PanneauInfos(discussion: ouverte)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    } else if (large && ui.onglet == Onglet.reglages) {
      droite = DetailDroit(
        child: ColoredBox(
          color: OuroColors.secondarySystemGroupedBackground,
          child: Navigator(
            key: ui.cleDetail,
            onGenerateInitialRoutes: (_, __) => [
              PageRouteBuilder<void>(pageBuilder: (_, __, ___) => const _Accueil(onglet: Onglet.reglages)),
            ],
            observers: [_SectionOubliee(ui)],
          ),
        ),
      );
    } else {
      droite = _Accueil(onglet: ui.onglet);
    }

    final corps = large
        ? Row(
            children: [
              _Rail(onDeconnexion: widget.onDeconnexion),
              SizedBox(width: colonne, child: ColoredBox(color: fondBarreLaterale(context), child: gauche)),
              VerticalDivider(width: 0.5, thickness: 0.5, color: OuroColors.separator),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: kSortie,
                  transitionBuilder: (enfant, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0.015, 0), end: Offset.zero).animate(a),
                      child: enfant,
                    ),
                  ),
                  child: KeyedSubtree(key: ValueKey(ouverte?.id ?? 'accueil-${ui.onglet.name}'), child: droite),
                ),
              ),
            ],
          )
        : _PileIos(
            dessous: Column(
              children: [
                Expanded(child: ColoredBox(color: OuroColors.secondarySystemGroupedBackground, child: gauche)),
                const _BarreOnglets(),
              ],
            ),
            dessus: ouverte != null ? KeyedSubtree(key: ValueKey(ouverte.id), child: droite) : null,
            onRetour: () => depot.ouvrir(null),
          );

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: _Raccourcis(
        onDeconnexion: widget.onDeconnexion,
        child: Stack(
          children: [
            Column(
              children: [
                if (depot.demo) _BandeauDemo(onQuitter: widget.onDeconnexion) else if (!depot.telephoneVu) const _BandeauSynchro(),
                Expanded(child: corps),
              ],
            ),
            // Un contact appelle : le bandeau descend par-dessus tout.
            const Positioned(top: 0, left: 0, right: 0, child: BandeauAppelEntrant()),
          ],
        ),
      ),
    );
  }

  Widget _racine(Onglet o) => Builder(
        builder: (context) => ColoredBox(color: fondBarreLaterale(context), child: Defilement(child: _colonne(o))),
      );

  Widget _colonne(Onglet o) => switch (o) {
        Onglet.discussions => const ListeDiscussions(),
        Onglet.actus => const ColonneActus(),
        Onglet.appels => const ColonneAppels(),
        Onglet.reglages => ColonneReglages(onDeconnexion: widget.onDeconnexion),
      };
}

// ── La pile du téléphone : la discussion glisse par-dessus la liste ────

/// Sur un écran étroit, ouvrir une discussion la fait glisser depuis la
/// droite par-dessus la liste, qui recule d'un tiers et s'assombrit — la
/// navigation de l'iPhone. On la referme par le bouton retour, la touche
/// Échap, ou en la tirant depuis le bord gauche, au doigt comme à la
/// souris ; lâchée à mi-chemin, elle revient ou part selon l'élan.
class _PileIos extends StatefulWidget {
  const _PileIos({required this.dessous, required this.dessus, required this.onRetour});

  final Widget dessous;
  final Widget? dessus;
  final VoidCallback onRetour;

  @override
  State<_PileIos> createState() => _PileIosState();
}

class _PileIosState extends State<_PileIos> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    reverseDuration: const Duration(milliseconds: 380),
  );

  /// La dernière discussion affichée : elle reste visible pendant qu'elle
  /// repart vers la droite.
  Widget? _affiche;
  bool _tire = false;

  @override
  void initState() {
    super.initState();
    _affiche = widget.dessus;
    if (widget.dessus != null) _a.value = 1;
    _a.addStatusListener((s) {
      if (s == AnimationStatus.dismissed && widget.dessus == null && mounted) setState(() => _affiche = null);
    });
  }

  @override
  void didUpdateWidget(covariant _PileIos ancien) {
    super.didUpdateWidget(ancien);
    if (widget.dessus != null) {
      _affiche = widget.dessus;
      if (ancien.dessus == null) _a.forward();
    } else if (ancien.dessus != null && !_tire) {
      // Déjà repoussée au doigt : il n'y a plus rien à animer.
      if (_a.value == 0) {
        _affiche = null;
      } else {
        _a.reverse();
      }
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  void _glisse(DragUpdateDetails d, double largeur) {
    _tire = true;
    final sens = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    _a.value = (_a.value - sens * d.delta.dx / largeur).clamp(0.0, 1.0);
  }

  void _lache(DragEndDetails d, double largeur) {
    final sens = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final elan = sens * d.velocity.pixelsPerSecond.dx / largeur;
    if (elan > 1.0 || (_a.value < 0.55 && elan > -1.0)) {
      _a.animateBack(0, duration: Duration(milliseconds: (300 * _a.value).round().clamp(120, 300)), curve: Curves.easeOut).whenComplete(() {
        _tire = false;
        widget.onRetour();
      });
    } else {
      _tire = false;
      _a.animateTo(1, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final largeur = c.maxWidth;
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return AnimatedBuilder(
        animation: _a,
        builder: (context, _) {
          // Pendant le geste, la discussion suit le doigt exactement ; seule
          // l'animation automatique prend la courbe.
          final v = _tire ? _a.value : (_a.status == AnimationStatus.reverse ? Curves.easeInOutCubic : kSortie).transform(_a.value);
          final sens = rtl ? -1.0 : 1.0;
          return Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(-sens * largeur * 0.3 * v, 0),
                  child: IgnorePointer(ignoring: _affiche != null, child: widget.dessous),
                ),
              ),
              if (_affiche != null) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Colors.black.withValues(alpha: (OuroColors.isDark ? 0.35 : 0.12) * v)),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(sens * largeur * (1 - v), 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18 * v), blurRadius: 24)],
                      ),
                      child: _affiche,
                    ),
                  ),
                ),
                // Le bord qu'on tire pour revenir.
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: rtl ? null : largeur * (1 - v),
                  right: rtl ? largeur * (1 - v) : null,
                  width: 22,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (d) => _glisse(d, largeur),
                    onHorizontalDragEnd: (d) => _lache(d, largeur),
                  ),
                ),
              ],
            ],
          );
        },
      );
    });
  }
}

// ── Le bandeau de la démonstration ──────────────────────────────────────

class _BandeauDemo extends StatelessWidget {
  const _BandeauDemo({required this.onQuitter});

  final VoidCallback onQuitter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: OuroColors.accent.withValues(alpha: OuroColors.isDark ? 0.2 : 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 15, color: OuroColors.accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.t.apercu,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.footnote.copyWith(color: OuroColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Survol(
            onTap: onQuitter,
            builder: (context, survol) => Text(
              context.t.lierTelephone,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.accent,
                fontWeight: FontWeight.w600,
                decoration: survol ? TextDecoration.underline : null,
                decorationColor: OuroColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le bandeau du compte lié, tant que les messages ne transitent pas.
class _BandeauSynchro extends StatelessWidget {
  const _BandeauSynchro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: OuroColors.systemGreen.withValues(alpha: OuroColors.isDark ? 0.18 : 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_rounded, size: 16, color: OuroColors.systemGreen),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.t.synchroBientot,
              textAlign: TextAlign.center,
              style: OuroTypography.footnote.copyWith(color: OuroColors.label),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Le rail ──────────────────────────────────────────────────────────────

class _Rail extends StatelessWidget {
  const _Rail({required this.onDeconnexion});

  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final l = context.l;
    final nonVus = depot.auteursStatuts().where((a) => !depot.statutsTousVus(a)).length;
    final manques = depot.appels.where((a) => a.manque).length;
    // Le rail et la colonne forment UNE barre latérale, comme dans les
    // apps du Mac : même matière, pas de trait entre les deux.
    return Container(
      width: 68,
      color: fondBarreLaterale(context),
      child: Column(
        children: [
          const SizedBox(height: 14),
          _BoutonRail(
            onglet: Onglet.discussions,
            libelle: l.tabChats,
            compte: depot.totalNonLus,
            logo: true,
          ),
          _BoutonRail(
            onglet: Onglet.actus,
            libelle: l.tabNews,
            icone: Icons.podcasts_outlined,
            iconeActive: Icons.podcasts_rounded,
            point: nonVus > 0,
          ),
          _BoutonRail(
            onglet: Onglet.appels,
            libelle: l.tabCalls,
            icone: Icons.phone_outlined,
            iconeActive: Icons.phone_rounded,
            compte: manques,
            rouge: true,
          ),
          const Spacer(),
          _BoutonRail(
            onglet: Onglet.reglages,
            libelle: l.settingsTitle,
            icone: Icons.settings_outlined,
            iconeActive: Icons.settings_rounded,
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: context.t.profil,
            child: Survol(
              onTap: () {
                ui.changerOnglet(Onglet.reglages);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) pousserPanneau(context, const PanneauProfil());
                });
              },
              builder: (context, survol) => AnimatedScale(
                scale: survol ? 1.06 : 1,
                duration: const Duration(milliseconds: 200),
                curve: kSortie,
                child: AvatarDroplet(
                  nom: depot.nom(kMoi),
                  couleur: depot.profil.couleur,
                  photo: depot.profil.photo,
                  taille: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BoutonRail extends StatefulWidget {
  const _BoutonRail({
    required this.onglet,
    required this.libelle,
    this.icone,
    this.iconeActive,
    this.logo = false,
    this.compte = 0,
    this.point = false,
    this.rouge = false,
  });

  final Onglet onglet;
  final String libelle;
  final IconData? icone;
  final IconData? iconeActive;

  /// Le logo de Droplet au lieu d'une icône, comme la bulle de WhatsApp.
  final bool logo;
  final int compte;
  final bool point;
  final bool rouge;

  @override
  State<_BoutonRail> createState() => _BoutonRailState();
}

class _BoutonRailState extends State<_BoutonRail> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final actif = ui.onglet == widget.onglet;
    final couleur = actif ? OuroColors.accent : OuroColors.secondaryLabel;
    final fond = actif
        ? OuroColors.accent.withValues(alpha: 0.14)
        : (_survol ? OuroColors.tertiarySystemFill : Colors.transparent);
    return Tooltip(
      message: widget.libelle,
      waitDuration: const Duration(milliseconds: 500),
      preferBelow: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _survol = true),
        onExit: (_) => setState(() => _survol = false),
        child: GestureDetector(
          onTap: () => ui.changerOnglet(widget.onglet),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: kSortie,
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(14)),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.logo
                      ? Goutte(key: ValueKey(actif), taille: 27, couleur: couleur)
                      : Icon(
                          actif ? widget.iconeActive : widget.icone,
                          key: ValueKey(actif),
                          size: 23,
                          color: couleur,
                        ),
                ),
                if (widget.compte > 0)
                  Positioned(
                    top: 3,
                    right: 1,
                    child: Pastille(compte: widget.compte, rouge: widget.rouge),
                  )
                else if (widget.point)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: OuroColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: OuroColors.systemGroupedBackground, width: 1.5),
                      ),
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

/// La pastille des non-lus.
class Pastille extends StatelessWidget {
  const Pastille({super.key, required this.compte, this.rouge = false, this.grise = false, this.inverse = false});

  final int compte;
  final bool rouge;
  final bool grise;

  /// Sur une ligne sélectionnée (fond d'accent) : pastille blanche.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final fond = inverse
        ? OuroColors.texteSurAccent
        : grise
            ? OuroColors.systemGray
            : (rouge ? OuroColors.systemRed : OuroColors.accentRempli);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minWidth: 19),
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 5.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(10)),
      child: Text(
        compte > 99 ? '99+' : '$compte',
        style: OuroTypography.caption2.copyWith(
          color: inverse ? OuroColors.accentRempli : OuroColors.texteSurRemplissage(fond),
          fontWeight: FontWeight.w700,
          fontVariations: const [FontVariation('wght', 700)],
          height: 1,
        ),
      ),
    );
  }
}

// ── La barre d'onglets (écran étroit) ─────────────────────────────────

class _BarreOnglets extends StatelessWidget {
  const _BarreOnglets();

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final l = context.l;
    Widget onglet(Onglet o, String libelle, IconData? icone, IconData? active, {int compte = 0, bool logo = false}) {
      final actif = ui.onglet == o;
      final couleur = actif ? OuroColors.accent : OuroColors.secondaryLabel;
      return Expanded(
        child: Survol(
          onTap: () => ui.changerOnglet(o),
          builder: (context, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  logo ? Goutte(taille: 26, couleur: couleur) : Icon(actif ? active : icone, size: 25, color: couleur),
                  if (compte > 0) Positioned(top: -4, right: -12, child: Pastille(compte: compte)),
                ],
              ),
              const SizedBox(height: 3),
              Text(libelle, style: OuroTypography.caption2.copyWith(color: couleur, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Verre(
      bordHaut: true,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              onglet(Onglet.discussions, l.tabChats, null, null, compte: depot.totalNonLus, logo: true),
              onglet(Onglet.actus, l.tabNews, Icons.podcasts_outlined, Icons.podcasts_rounded),
              onglet(Onglet.appels, l.tabCalls, Icons.phone_outlined, Icons.phone_rounded),
              onglet(Onglet.reglages, l.settingsTitle, Icons.settings_outlined, Icons.settings_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

// ── L'accueil (aucune discussion ouverte) ──────────────────────────────

class _Accueil extends StatelessWidget {
  const _Accueil({required this.onglet});

  final Onglet onglet;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final l = context.l;
    final etat = context.depot.transport.etat;
    final (titre, texte) = switch (onglet) {
      Onglet.discussions => (t.titre, t.videTexte),
      Onglet.actus => (l.tabNews, t.accueilActus),
      Onglet.appels => (l.tabCalls, t.accueilAppels),
      Onglet.reglages => (l.settingsTitle, t.accueilReglages),
    };
    return Container(
      color: OuroColors.systemGroupedBackground,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Illustration(onglet: onglet),
          const SizedBox(height: 14),
          Text(titre, style: OuroTypography.title1.copyWith(color: OuroColors.label)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              texte,
              textAlign: TextAlign.center,
              style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.45),
            ),
          ),
          if (onglet == Onglet.discussions) ...[
            const SizedBox(height: 32),
            const _AstucesClavier(),
          ],
          const SizedBox(height: 44),
          ValueListenableBuilder<EtatConnexion>(
            valueListenable: etat,
            builder: (context, e, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 12, color: OuroColors.tertiaryLabel),
                const SizedBox(width: 6),
                Text(t.chiffre, style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La goutte au centre d'un halo de la couleur choisie, entourée de
/// l'onde du maillage : l'accueil a la présence d'une icône d'app, pas
/// d'un pictogramme gris. L'icône change avec l'onglet.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.onglet});

  final Onglet onglet;

  @override
  Widget build(BuildContext context) {
    final accent = OuroColors.accent;
    final icone = switch (onglet) {
      Onglet.discussions => null,
      Onglet.actus => Icons.podcasts_rounded,
      Onglet.appels => Icons.phone_rounded,
      Onglet.reglages => Icons.settings_rounded,
    };
    final fonce = Color.lerp(accent, Colors.black, 0.22)!;
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Le halo.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [accent.withValues(alpha: 0.20), accent.withValues(alpha: 0)]),
            ),
          ),
          // L'onde du maillage : trois cercles qui s'effacent.
          for (final (taille, alpha) in const [(196.0, 0.10), (156.0, 0.16), (122.0, 0.24)])
            Container(
              width: taille,
              height: taille,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: alpha), width: 1),
              ),
            ),
          // L'icône, comme sur l'écran d'accueil d'un téléphone.
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent, fonce]),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.38), blurRadius: 30, offset: const Offset(0, 14)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: icone == null ? const Goutte(taille: 52, couleur: Colors.white) : Icon(icone, size: 44, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Trois raccourcis, en touches dessinées : ce que le Mac montre au
/// premier lancement, et que WhatsApp Web cache dans un menu.
class _AstucesClavier extends StatelessWidget {
  const _AstucesClavier();

  @override
  Widget build(BuildContext context) {
    final liste = listeRaccourcis(context);
    final choix = [liste[0], liste[2], liste[9]];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (action, touches) in choix)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OuroColors.separator.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(action, style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
                const SizedBox(width: 10),
                for (final k in touches.split('+'))
                  Container(
                    margin: const EdgeInsets.only(left: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 22),
                    decoration: BoxDecoration(
                      color: OuroColors.systemGroupedBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border(bottom: BorderSide(color: OuroColors.separator, width: 1.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(k, style: OuroTypography.caption1.copyWith(color: OuroColors.label, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Les raccourcis clavier ─────────────────────────────────────────────

/// Les raccourcis de WhatsApp Web, décrits aussi dans Réglages ›
/// Raccourcis clavier.
class _Raccourcis extends StatelessWidget {
  const _Raccourcis({required this.child, required this.onDeconnexion});

  final Widget child;
  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) {
    final p = context.lire;
    final depot = p.depot;
    final ui = p.ui;
    Discussion? ouverte() => depot.discussionOuverte == null ? null : depot.discussions[depot.discussionOuverte];

    void allerA(int sens) {
      final liste = depot.discussionsTriees();
      if (liste.isEmpty) return;
      final i = liste.indexWhere((d) => d.id == depot.discussionOuverte);
      final j = i < 0 ? 0 : (i + sens).clamp(0, liste.length - 1);
      ouvrirDiscussion(context, liste[j].id);
    }

    SingleActivator ca(LogicalKeyboardKey k, {bool maj = false}) =>
        SingleActivator(k, control: true, alt: true, shift: maj);

    return CallbackShortcuts(
      bindings: {
        ca(LogicalKeyboardKey.keyN): () {
          ui.changerOnglet(Onglet.discussions);
          pousserPanneau(context, const PanneauNouvelleDiscussion());
        },
        ca(LogicalKeyboardKey.keyN, maj: true): () {
          ui.changerOnglet(Onglet.discussions);
          pousserPanneau(context, const PanneauNouveauGroupe());
        },
        ca(LogicalKeyboardKey.slash): () {
          ui.changerOnglet(Onglet.discussions);
          ui.cleGauche.currentState?.popUntil((r) => r.isFirst);
          ui.focusRecherche.requestFocus();
        },
        ca(LogicalKeyboardKey.comma): () => ui.changerOnglet(Onglet.reglages),
        ca(LogicalKeyboardKey.keyP): () {
          ui.changerOnglet(Onglet.reglages);
          WidgetsBinding.instance.addPostFrameCallback((_) => pousserPanneau(context, const PanneauProfil()));
        },
        ca(LogicalKeyboardKey.keyE): () {
          final d = ouverte();
          if (d != null) depot.archiver(d);
        },
        ca(LogicalKeyboardKey.keyM, maj: true): () {
          final d = ouverte();
          if (d != null) depot.sourdine(d);
        },
        ca(LogicalKeyboardKey.keyU, maj: true): () {
          final d = ouverte();
          if (d == null) return;
          depot.ouvrir(null);
          depot.marquerNonLue(d);
        },
        ca(LogicalKeyboardKey.keyP, maj: true): () {
          final d = ouverte();
          if (d != null) depot.epinglerDiscussion(d);
        },
        ca(LogicalKeyboardKey.keyF, maj: true): () {
          if (ouverte() != null) ui.basculerRecherche(true);
        },
        ca(LogicalKeyboardKey.keyI, maj: true): () {
          if (ouverte() != null) ui.basculerInfos();
        },
        ca(LogicalKeyboardKey.bracketRight, maj: true): () => allerA(1),
        ca(LogicalKeyboardKey.bracketLeft, maj: true): () => allerA(-1),
        ca(LogicalKeyboardKey.arrowDown): () => allerA(1),
        ca(LogicalKeyboardKey.arrowUp): () => allerA(-1),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (ui.rechercheDiscussion) {
            ui.basculerRecherche(false);
          } else if (ui.infos) {
            ui.basculerInfos(false);
          } else if (ui.cleGauche.currentState?.canPop() ?? false) {
            ui.cleGauche.currentState!.pop();
          } else if (depot.discussionOuverte != null) {
            depot.ouvrir(null);
          }
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// Une liste de toutes les touches, pour Réglages › Raccourcis clavier.
List<(String, String)> listeRaccourcis(BuildContext context) {
  final t = context.t;
  final l = context.l;
  final mac = Navigateur.estMac;
  String k(String s) => touche(s, mac: mac);
  return [
    (l.chatsNew, k('Ctrl+Alt+N')),
    (l.chatsNewGroup, k('Ctrl+Alt+Maj+N')),
    (l.actionSearch, k('Ctrl+Alt+/')),
    (t.rechercherDansDiscussion, k('Ctrl+Alt+Maj+F')),
    (t.infosDiscussion, k('Ctrl+Alt+Maj+I')),
    (l.chatsArchive, k('Ctrl+Alt+E')),
    (l.chatsPin, k('Ctrl+Alt+Maj+P')),
    (l.chatsMute, k('Ctrl+Alt+Maj+M')),
    (t.marquerNonLue, k('Ctrl+Alt+Maj+U')),
    (t.discussionSuivante, k('Ctrl+Alt+↓')),
    (t.discussionPrecedente, k('Ctrl+Alt+↑')),
    (t.profil, k('Ctrl+Alt+P')),
    (l.settingsTitle, k('Ctrl+Alt+,')),
    (t.fermer, 'Esc'),
    (t.nouvelleLigne, k('Maj+Entrée').replaceAll('Entrée', t.toucheEntree)),
  ];
}


/// Revenir à l'accueil du détail (retour depuis une page) : plus de section
/// surlignée.
class _SectionOubliee extends NavigatorObserver {
  _SectionOubliee(this.ui);

  final Interface ui;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.isFirst ?? false) {
      final nav = navigator;
      if (nav != null && !nav.canPop()) {
        ui.section = null;
        ui.rafraichir();
      }
    }
  }
}
