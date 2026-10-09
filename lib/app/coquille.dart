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

/// Pousser un panneau dans la colonne de gauche de l'onglet actif.
void pousserPanneau(BuildContext context, Widget panneau) {
  context.lire.ui.cleGauche.currentState?.push(CupertinoPageRoute<void>(builder: (_) => panneau));
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
    final ouverte = depot.discussionOuverte == null ? null : depot.discussions[depot.discussionOuverte];
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
    } else {
      droite = _Accueil(onglet: ui.onglet);
    }

    final corps = large
        ? Row(
            children: [
              _Rail(onDeconnexion: widget.onDeconnexion),
              SizedBox(width: colonne, child: ColoredBox(color: OuroColors.secondarySystemGroupedBackground, child: gauche)),
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
        : Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(child: ColoredBox(color: OuroColors.secondarySystemGroupedBackground, child: gauche)),
                    const _BarreOnglets(),
                  ],
                ),
              ),
              if (ouverte != null) Positioned.fill(child: droite),
            ],
          );

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: _Raccourcis(
        onDeconnexion: widget.onDeconnexion,
        child: Column(
          children: [
            if (depot.demo) _BandeauDemo(onQuitter: widget.onDeconnexion),
            Expanded(child: corps),
          ],
        ),
      ),
    );
  }

  Widget _racine(Onglet o) => switch (o) {
        Onglet.discussions => const ListeDiscussions(),
        Onglet.actus => const ColonneActus(),
        Onglet.appels => const ColonneAppels(),
        Onglet.reglages => ColonneReglages(onDeconnexion: widget.onDeconnexion),
      };
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
    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: OuroColors.systemGroupedBackground,
        border: Border(right: BorderSide(color: OuroColors.separator, width: 0.5)),
      ),
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
  const Pastille({super.key, required this.compte, this.rouge = false, this.grise = false});

  final int compte;
  final bool rouge;
  final bool grise;

  @override
  Widget build(BuildContext context) {
    final fond = grise ? OuroColors.systemGray : (rouge ? OuroColors.systemRed : OuroColors.accentRempli);
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
          color: OuroColors.texteSurRemplissage(fond),
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
          const SizedBox(height: 28),
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

/// Un ordinateur et un téléphone, reliés par la goutte : l'idée de
/// l'appareil associé en une image. L'icône change avec l'onglet.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.onglet});

  final Onglet onglet;

  @override
  Widget build(BuildContext context) {
    final gris = OuroColors.tertiaryLabel;
    final pastille = switch (onglet) {
      Onglet.discussions => null,
      Onglet.actus => Icons.podcasts_rounded,
      Onglet.appels => Icons.phone_rounded,
      Onglet.reglages => Icons.settings_rounded,
    };
    return SizedBox(
      width: 240,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 4, child: Icon(Icons.laptop_mac_rounded, size: 128, color: gris.withValues(alpha: 0.6))),
          Positioned(right: 12, bottom: 10, child: Icon(Icons.smartphone_rounded, size: 70, color: gris.withValues(alpha: 0.6))),
          Positioned(
            top: 0,
            right: 54,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: OuroColors.secondarySystemGroupedBackground,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              alignment: Alignment.center,
              // Le logo en gris : rien n'est encore ouvert.
              child: pastille == null
                  ? Goutte(taille: 34, couleur: gris)
                  : Icon(pastille, size: 26, color: gris),
            ),
          ),
        ],
      ),
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
