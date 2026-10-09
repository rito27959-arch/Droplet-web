// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA BARRE DE FILTRES DE LA LISTE DES CONVERSATIONS — « Toutes / Non lues
// / Groupes / Favoris ».
//
// C'est le seul vrai apport de hiérarchie que WhatsApp a ajouté à son
// écran d'accueil iOS ces dernières années, et il mérite d'être copié
// pour une raison précise : IL RETIRE PLUS QU'IL N'AJOUTE.
//
// ── LE PROBLÈME QU'IL RÉSOUT ──────────────────────────────────────────
//
// Une liste de conversations mélange trois choses qui n'ont pas la même
// urgence : ce qui attend une réponse, ce qu'on garde sous la main, et
// tout le reste. La réponse habituelle est d'empiler des en-têtes de
// section — « ÉPINGLÉES », « DISCUSSIONS » — qui occupent une ligne
// chacun, poussent le contenu vers le bas, et ne servent qu'à ÉTIQUETER
// ce que la position dans la liste dit déjà.
//
// Un filtre fait l'inverse : il ne nomme rien, il ENLÈVE. Quand on
// choisit « Non lues », les vingt conversations déjà traitées
// disparaissent au lieu d'être surmontées d'un titre. L'écran se
// simplifie au lieu de se documenter.
//
// ── ⚠️ CE QUI FAIT QUE ÇA SE SENT NATIF, ET QUI EST PRESQUE TOUJOURS
//    RATÉ DANS LES COPIES ───────────────────────────────────────────────
//
// L'indicateur de sélection est UN SEUL OBJET QUI SE DÉPLACE.
//
// La façon naïve d'écrire ce composant est de donner à chaque pastille
// un fond conditionnel : `color: estSelectionne ? accent : transparent`.
// Ça marche, ça a l'air correct sur une capture d'écran — et c'est faux
// en mouvement. Au changement de filtre, un fond s'éteint ici et un
// autre s'allume là : deux événements sans rapport. L'œil ne voit pas un
// objet se déplacer, il voit deux clignotements.
//
// Apple ne fait jamais ça. Dans un `UISegmentedControl`, la pastille est
// une vue unique qui GLISSE d'un segment à l'autre — et c'est
// exactement le même principe de continuité que la bulle qui vole dans
// `send_flight_animation.dart` : l'objet à l'écran est le même du début
// à la fin, il ne fait que changer de place.
//
// D'où le `Stack` : une pastille positionnée en absolu, animée par un
// ressort, sous une rangée d'étiquettes qui ne portent aucun fond.
//
// ── ⚠️ POURQUOI LES LARGEURS SONT MESURÉES ET NON DEVINÉES ────────────
//
// Les libellés n'ont pas la même longueur, et leur longueur change avec
// la langue et avec la taille de police choisie par l'utilisateur. Une
// largeur fixe casse dès qu'on passe en Dynamic Type XXL — le texte
// déborde de sa pastille, ce qui est précisément le genre de défaut
// qu'on ne voit jamais en développement et toujours chez l'utilisateur.
//
// On mesure donc chaque libellé avec le style RÉEL, à l'échelle de
// texte RÉELLE, via un `TextPainter`. Quatre mesures par construction :
// c'est négligeable, et c'est ce qui rend le composant correct à toutes
// les tailles.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Les filtres proposés au-dessus de la liste.
enum FiltreChats {
  toutes,
  // Ce qui distingue Droplet : les discussions joignables ICI, sans
  // Internet — les contacts qu'un appareil à portée relie en ce moment.
  proches,
  nonLues,
  groupes,
  epinglees;

  /// Le texte affiché dans la pastille.
  ///
  /// ⚠️ CE N'EST PLUS UN CHAMP CONST. `AppLocalizations` a besoin d'un
  /// contexte, qu'une valeur d'énumération construite à la compilation
  /// ne peut pas porter — d'où la méthode plutôt qu'un champ, résolue
  /// au moment de l'affichage.
  String libelleFor(AppLocalizations l10n) => switch (this) {
        FiltreChats.toutes => l10n.chatsFilterAll,
        FiltreChats.proches => l10n.chatsFilterNearby,
        FiltreChats.nonLues => l10n.chatsFilterUnread,
        FiltreChats.groupes => l10n.chatsFilterGroups,
        FiltreChats.epinglees => l10n.chatsFilterPinned,
      };
}

/// La barre de filtres. Sans fond ni bordure : elle se pose sur le fond
/// de l'écran et ne coûte qu'une hauteur de ligne.
class ChatsFilterBar extends StatelessWidget {
  const ChatsFilterBar({
    super.key,
    required this.actif,
    required this.onChange,
    this.compteurs = const {},
  });

  /// Le filtre actuellement retenu.
  final FiltreChats actif;

  final ValueChanged<FiltreChats> onChange;

  /// Combien de conversations chaque filtre laisserait passer.
  ///
  /// ⚠️ UN FILTRE QUI NE RAMÈNERAIT RIEN N'EST PAS AFFICHÉ. Proposer
  /// « Non lues » quand tout est lu, c'est offrir un bouton dont le seul
  /// résultat possible est une liste vide — l'utilisateur l'essaie une
  /// fois, tombe sur du vide, et n'a plus confiance dans la barre. La
  /// barre se réduit donc toute seule à ce qui a un sens maintenant.
  final Map<FiltreChats, int> compteurs;

  /// Hauteur totale occupée, marges comprises. Exposée pour que l'écran
  /// puisse dimensionner son en-tête épinglé sans la deviner.
  static const double hauteur = 52;

  static const EdgeInsets _paddingPastille =
      EdgeInsets.symmetric(horizontal: 14, vertical: 7);
  static const double _ecart = 8;

  /// Les filtres réellement montrés : « Toutes » toujours, les autres
  /// seulement s'ils ramèneraient quelque chose.
  /// Le libellé montré : le nom du filtre, puis son compte, comme chez
  /// WhatsApp. « Non lues 4 » se lit d'un coup d'œil ; « Non lues » oblige
  /// à ouvrir pour savoir.
  /// ⚠️ LE COMPTE SEULEMENT SUR « NON LUES ». « Épinglées 1 », « Groupes
  /// 4 » : des chiffres qui ne demandent rien et que personne ne lit. Le
  /// nombre de non-lues, lui, est une question — « qu'est-ce qui
  /// m'attend ? » —, et c'est le seul que WhatsApp affiche sur ses
  /// filtres.
  String _libelleAvecCompte(FiltreChats f, String nom) {
    final n = compteurs[f] ?? 0;
    return f == FiltreChats.nonLues && n > 0 ? '$nom  $n' : nom;
  }

  /// ⚠️ « NON LUES » ET « GROUPES » SONT TOUJOURS LÀ. Ils n'apparaissaient
  /// qu'à partir d'une conversation concernée : la barre ne montrait que
  /// « Toutes » et « Épinglées 1 », et changeait de forme d'un jour à
  /// l'autre. Un filtre qui apparaît et disparaît ne s'apprend pas ; celui
  /// qui reste à sa place, on finit par le toucher sans regarder. Vide, il
  /// mène à un écran qui le dit.
  ///
  /// « À proximité » et « Épinglées », eux, restent conditionnels : sans
  /// personne autour ni rien d'épinglé, ils ne serviraient à rien.
  List<FiltreChats> _visibles() {
    return [
      FiltreChats.toutes,
      FiltreChats.nonLues,
      FiltreChats.groupes,
      for (final f in [FiltreChats.proches, FiltreChats.epinglees])
        if ((compteurs[f] ?? 0) > 0 || actif == f) f,
    ];
  }

  /// Mesure la largeur d'une pastille pour un libellé donné.
  ///
  /// On passe le `TextScaler` du système : c'est ce qui fait que la
  /// pastille grandit avec le Dynamic Type au lieu de rogner le texte.
  double _largeur(String libelle, TextStyle style, TextScaler echelle) {
    final peintre = TextPainter(
      text: TextSpan(text: libelle, style: style),
      textDirection: TextDirection.ltr,
      textScaler: echelle,
    )..layout();
    return peintre.width + _paddingPastille.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _visibles();

    // Un seul filtre possible = rien à choisir. On ne montre pas une
    // barre qui ne peut rien faire : c'est exactement la surcharge
    // qu'on cherche à éviter.
    if (visibles.length < 2) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final motion = OuroMotion.of(context);
    final echelle = MediaQuery.textScalerOf(context);
    final style = OuroTypography.subheadline.copyWith(
      fontWeight: FontWeight.w600,
    );

    final largeurs = [
      for (final f in visibles)
        _largeur(_libelleAvecCompte(f, f.libelleFor(l10n)), style, echelle),
    ];

    // Position et taille de la pastille : la somme des largeurs qui la
    // précèdent, écarts compris.
    final indexActif = visibles.indexOf(actif).clamp(0, visibles.length - 1);
    var decalage = 0.0;
    for (var i = 0; i < indexActif; i++) {
      decalage += largeurs[i] + _ecart;
    }

    final hauteurPastille =
        echelle.scale(OuroTypography.subheadline.fontSize ?? 15) * 1.25 +
            _paddingPastille.vertical;

    return SizedBox(
      height: hauteur,
      child: ListView(
        scrollDirection: Axis.horizontal,
        // La barre déborde en Dynamic Type XXL ou dans une langue
        // verbeuse : elle défile alors au lieu de rogner.
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.screenMargin,
        ),
        physics: const ClampingScrollPhysics(),
        children: [
          Center(
            child: SizedBox(
              height: hauteurPastille,
              width: largeurs.fold<double>(0, (t, l) => t + l) +
                  _ecart * (visibles.length - 1),
              child: Stack(
                children: [
                  // ── LA PASTILLE QUI GLISSE ───────────────────────────
                  //
                  // C'est tout l'enjeu du composant. Un seul objet, animé
                  // en position ET en largeur, parce que les libellés
                  // n'ont pas la même longueur : sans l'animation de
                  // largeur, la pastille sauterait à la bonne taille
                  // avant de se déplacer.
                  AnimatedPositioned(
                    duration: motion.duree(DesignTokens.durationFast),
                    curve: motion.courbe(Curves.easeOutCubic),
                    left: decalage,
                    top: 0,
                    bottom: 0,
                    width: largeurs[indexActif],
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // `accentRempli` + `texteSurAccent` : le blanc fixe
                        // devenait illisible sur un accent clair (menthe,
                        // jaune).
                        color: OuroColors.accentRempli,
                        borderRadius: BorderRadius.circular(hauteurPastille / 2),
                      ),
                    ),
                  ),
                  // ── LES ÉTIQUETTES ───────────────────────────────────
                  //
                  // Aucune ne porte de fond : le fond est la pastille
                  // qui passe DESSOUS. Seule la couleur du texte change,
                  // et elle est animée pour ne pas basculer sèchement
                  // pendant que la pastille est encore en route.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < visibles.length; i++) ...[
                        if (i > 0) const SizedBox(width: _ecart),
                        SizedBox(
                          width: largeurs[i],
                          child: _Etiquette(
                            libelle: _libelleAvecCompte(
                              visibles[i],
                              visibles[i].libelleFor(l10n),
                            ),
                            style: style,
                            selectionne: i == indexActif,
                            onTap: () {
                              if (visibles[i] == actif) return;
                              OuroHaptics.selection();
                              onChange(visibles[i]);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette({
    required this.libelle,
    required this.style,
    required this.selectionne,
    required this.onTap,
  });

  final String libelle;
  final TextStyle style;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final motion = OuroMotion.of(context);
    return Semantics(
      button: true,
      selected: selectionne,
      label: libelle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Non sélectionné : une capsule grise, pour qu'on voie que c'est un
        // BOUTON. Sans elle, « Épinglées » n'était qu'un mot posé à côté de
        // la pastille rouge, sans rien qui invite à le toucher.
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selectionne ? Colors.transparent : OuroColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
          child: AnimatedDefaultTextStyle(
            duration: motion.duree(DesignTokens.durationFast),
            curve: motion.courbe(Curves.easeOutCubic),
            style: style.copyWith(
              color: selectionne ? OuroColors.texteSurAccent : OuroColors.label,
            ),
            child: Text(libelle, maxLines: 1),
          ),
        ),
        ),
      ),
    );
  }
}
