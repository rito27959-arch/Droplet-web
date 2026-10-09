// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE MOTEUR DE MOUVEMENT DE DROPLET — l'autorité unique sur « comment les
// choses bougent ». Un seul endroit décide de la physique, de la
// désactivation d'accessibilité et du budget appareil ; tout le reste de
// l'application se contente de DEMANDER.
//
// ── LE PROBLÈME QU'IL RÉSOUT ──────────────────────────────────────────
//
// Avant ce fichier, l'application avait CINQ systèmes de mouvement
// concurrents et incompatibles :
//
//   1. Les courbes de `DesignTokens` (`curveStandard`, `curveEnter`…)
//   2. Les ressorts `motor` — dans 3 fichiers sur 161
//   3. `flutter_animate` — dans 47 fichiers
//   4. Des `AnimationController` bruts — dans 55 fichiers
//   5. `NexusController`, qui est déjà un vrai moteur, mais enfermé dans
//      un seul rituel de huit secondes
//
// Aucun ne savait ce que faisaient les autres. Résultat : deux gestes
// voisins à l'écran ne partageaient aucune physique, et rien ne pouvait
// être changé globalement.
//
// ── ⚠️ LE DÉFAUT LE PLUS GRAVE QUE CE FICHIER CORRIGE ─────────────────
//
// **« Réduire les animations » n'était honoré NULLE PART.**
//
// Sur 161 fichiers, `MediaQuery.disableAnimations` était lu une seule
// fois, dans `premium_screen.dart`. Un utilisateur qui active ce réglage
// iOS — parce que le mouvement lui donne la nausée, déclenche des
// migraines ou des crises vestibulaires — voyait Droplet continuer à
// faire voler, rebondir et onduler absolument tout.
//
// Ce n'est pas un défaut de finition, c'est un défaut d'accessibilité :
// iOS respecte ce réglage dans TOUT le système, sans exception. C'est
// précisément le genre d'écart qui interdit la note de 10, quelle que
// soit la beauté du reste.
//
// En passant par le moteur, un widget l'obtient GRATUITEMENT : il n'a
// rien à savoir du réglage, il demande `motion.entrance` et reçoit
// `NoMotion()` si l'utilisateur a demandé le calme.
//
// ── POURQUOI DES RESSORTS ET PAS DES COURBES ──────────────────────────
//
// Ce n'est pas une question de goût, c'est une question d'INTERRUPTION.
//
// Une courbe (`easeOutCubic` et consorts) est une fonction du temps :
// elle part de 0, arrive à 1, et n'a aucune mémoire. Si l'utilisateur
// touche l'écran au milieu, la seule chose que le code puisse faire est
// de repartir d'une nouvelle courbe — le mouvement CASSE et repart, et
// l'œil le voit.
//
// Un ressort est une fonction de l'ÉTAT : position + vitesse. Interrompu,
// il conserve sa vitesse et se redirige. C'est pour ça qu'une feuille
// iOS qu'on rattrape en plein vol suit le doigt sans à-coup, et c'est
// exactement ce que Droplet ne savait pas faire.
//
// ⚠️ `DesignTokens` prétendait le contraire : `curveSpring`, `curveBounce`
// et `curveEmphasis` y sont TOUS les trois des alias de `curveEnter`,
// c'est-à-dire d'un simple `easeOutCubic`. Le vocabulaire annonçait une
// physique que le code n'avait pas. Ces alias restent en place pour ne
// rien casser, mais tout code nouveau doit passer par ici.
//
// ── LE VOCABULAIRE EST NOMMÉ PAR INTENTION ────────────────────────────
//
// Comme `OuroHaptics`, on ne nomme pas par la force (« ressort à 0.3 de
// rebond ») mais par ce que le mouvement VEUT DIRE. Un développeur qui
// écrit un bouton ne devrait pas avoir à choisir un coefficient
// d'amortissement ; il devrait dire « ceci est une pression ».
//
// Les valeurs sont celles de SwiftUI, via `motor` — pas des imitations à
// l'œil, les réglages réels d'Apple.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

/// L'autorité unique sur le mouvement.
///
/// Posé une fois à la racine par [OuroMotionScope], lu partout par
/// [OuroMotion.of].
@immutable
class OuroMotion {
  const OuroMotion({required this.reduceMotion, required this.degraded});

  /// L'utilisateur a demandé moins de mouvement.
  ///
  /// Vrai si « Réduire les animations » est actif dans les réglages
  /// d'accessibilité du système. Quand c'est le cas, toute intention
  /// renvoie [NoMotion] et toute durée devient nulle : les états
  /// changent, mais ils ne VOYAGENT plus.
  ///
  /// ⚠️ On ne supprime pas les transitions, on les rend instantanées.
  /// La différence compte : un élément qui apparaît là où il doit être
  /// reste compréhensible ; un élément qu'on ne dessine plus du tout
  /// casse la mise en page.
  final bool reduceMotion;

  /// L'appareil est en difficulté : pas de shader, ou stress thermique.
  ///
  /// Même source de vérité que `ouroGlassDegraded`. Le mouvement se
  /// simplifie avant que la cadence ne tombe — un ressort qui met
  /// 500 ms à se poser coûte 30 images de plus qu'un qui met 200 ms.
  final bool degraded;

  /// Lecture depuis n'importe où dans l'arbre.
  ///
  /// Ne lance jamais : hors d'un [OuroMotionScope] — dans un test de
  /// widget isolé, par exemple — on retombe sur la lecture directe du
  /// `MediaQuery`, ce qui garde l'accessibilité correcte même sans le
  /// scope.
  static OuroMotion of(BuildContext context) {
    final herite = context
        .dependOnInheritedWidgetOfExactType<_OuroMotionScope>();
    if (herite != null) return herite.motion;
    return OuroMotion(
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
      degraded: false,
    );
  }

  // ── LE VOCABULAIRE ───────────────────────────────────────────────────

  /// **Une pression.** Le retour immédiat sous le doigt.
  ///
  /// Le plus rapide du vocabulaire (150 ms) : au-delà, le bouton semble
  /// répondre en retard, et c'est le défaut le plus perceptible d'une
  /// interface tactile.
  Motion get press => _spring(const CupertinoMotion.interactive());

  /// **Un changement d'état ordinaire.** Le défaut, quand rien
  /// d'autre ne s'applique.
  Motion get standard => _spring(const CupertinoMotion.smooth());

  /// **Une arrivée.** Quelque chose entre en scène et doit se faire
  /// remarquer sans être bruyant.
  Motion get entrance => _spring(const CupertinoMotion.snappy());

  /// **Un moment.** Réservé aux instants qui comptent — une connexion
  /// établie, un message qui se pose. Le seul qui rebondit franchement.
  ///
  /// ⚠️ À utiliser avec parcimonie. Le rebond est ce qui distingue une
  /// interface vivante d'une interface bavarde ; s'il est partout, il ne
  /// signifie plus rien.
  Motion get playful => _spring(const CupertinoMotion.bouncy());

  /// **Une surface qui monte.** Feuilles, panneaux, menus contextuels.
  ///
  /// Plus lent que le reste parce que l'objet est GRAND : à vitesse
  /// égale, une grande surface paraît se précipiter.
  Motion get sheet => _spring(
    const CupertinoMotion.smooth(duration: Duration(milliseconds: 550)),
  );

  /// **Un glissement suivi au doigt.** Le geste est piloté par la main,
  /// le ressort ne sert qu'à finir le mouvement après le relâchement.
  Motion get followThrough => _spring(
    const CupertinoMotion.interactive(duration: Duration(milliseconds: 220)),
  );

  // ── LES ADAPTATEURS POUR LE CODE EXISTANT ────────────────────────────

  /// Passe une durée au filtre du moteur.
  ///
  /// Le pont pour les dizaines d'`AnimatedContainer`, `AnimatedOpacity` et
  /// `AnimationController` déjà écrits : remplacer
  /// `duration: DesignTokens.durationFast` par
  /// `duration: motion.duree(DesignTokens.durationFast)` suffit à leur
  /// donner l'accessibilité, sans les réécrire en ressorts.
  Duration duree(Duration valeur) {
    if (reduceMotion) return Duration.zero;
    if (degraded) return valeur * 0.7;
    return valeur;
  }

  /// Passe une courbe au filtre du moteur.
  ///
  /// Sous « réduire les animations », la durée étant déjà nulle, la
  /// courbe n'a plus d'effet — on renvoie une courbe linéaire pour que
  /// rien ne dépasse si une durée non nulle traîne quelque part.
  Curve courbe(Curve valeur) => reduceMotion ? Curves.linear : valeur;

  /// Faut-il jouer les animations d'AMBIANCE — celles qui tournent en
  /// boucle sans que l'utilisateur ait rien demandé ?
  ///
  /// Gouttelettes qui pulsent, halos qui respirent, points en orbite du
  /// `MeshVisualizer`. Ce sont les premières à devoir disparaître : elles
  /// ne portent aucune information, elles consomment la batterie en
  /// permanence, et ce sont exactement celles qui déclenchent les
  /// troubles vestibulaires.
  bool get ambiantAutorise => !reduceMotion && !degraded;

  /// ⚠️ MIROIR STATIQUE DE [ambiantAutorise], ET POURQUOI IL EXISTE.
  ///
  /// Les animations d'ambiance démarrent presque toutes dans `initState()`,
  /// par un `AnimationController.repeat()`. Or `initState()` n'a pas le
  /// droit de lire un `InheritedWidget` : `OuroMotion.of(context)` y est
  /// interdit. Chaque site aurait donc dû déplacer son démarrage dans
  /// `didChangeDependencies` — une réécriture par fichier, sur 26 fichiers,
  /// pour une seule question posée à chaque fois.
  ///
  /// Ce miroir, tenu à jour par [OuroMotionScope] à la racine, permet à
  /// [BouclageAmbiant.bouclerSiAmbiant] de répondre sans contexte, donc
  /// d'être appelé là où les boucles démarrent réellement.
  ///
  /// ⚠️ LES BOUCLES SUIVENT LES CHANGEMENTS EN COURS DE SESSION. Une boucle
  /// arrêtée ne reprenait jamais : il suffisait que le téléphone chauffe au
  /// démarrage pour que les gouttes de l'accueil et des autres écrans restent
  /// figées jusqu'au prochain lancement. Chaque boucle est désormais inscrite
  /// (référence faible : aucune fuite) et relancée ou arrêtée quand
  /// l'autorisation change.
  static bool get ambiantAutoriseGlobal => _ambiant;
  static set ambiantAutoriseGlobal(bool autorise) {
    if (autorise == _ambiant) return;
    _ambiant = autorise;
    if (_relanceProgrammee) return;
    _relanceProgrammee = true;
    // Appelé pendant le build d'OuroMotionScope : relancer une animation ici
    // reconstruirait des widgets en pleine construction.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _relanceProgrammee = false;
      _appliquerATous();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  static bool _ambiant = true;
  static bool _relanceProgrammee = false;
  static final List<_BoucleAmbiante> _boucles = [];

  static void _inscrire(AnimationController controleur, void Function(AnimationController) appliquer) {
    _boucles.removeWhere((b) {
      final cible = b.cible.target;
      return cible == null || identical(cible, controleur);
    });
    _boucles.add(_BoucleAmbiante(controleur, appliquer));
  }

  static void _appliquerATous() {
    _boucles.removeWhere((b) => b.cible.target == null);
    for (final boucle in List.of(_boucles)) {
      final controleur = boucle.cible.target;
      if (controleur == null) continue;
      try {
        boucle.appliquer(controleur);
      } catch (_) {
        // Contrôleur libéré entre-temps : on l'oublie.
        _boucles.remove(boucle);
      }
    }
  }

  @visibleForTesting
  static int get bouclesInscrites => _boucles.length;

  /// Un ressort, sauf si l'utilisateur a demandé le calme.
  Motion _spring(CupertinoMotion base) {
    if (reduceMotion) return const NoMotion();
    if (!degraded) return base;
    // Appareil en difficulté : on garde la forme du mouvement mais on
    // raccourcit, et on force la fin nette (`snapToEnd`) pour ne pas
    // payer la longue traîne de convergence du ressort.
    return CupertinoMotion(
      duration: base.duration * 0.7,
      bounce: base.bounce * 0.5,
      snapToEnd: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OuroMotion &&
      other.reduceMotion == reduceMotion &&
      other.degraded == degraded;

  @override
  int get hashCode => Object.hash(reduceMotion, degraded);
}

/// Pose le moteur à la racine de l'application.
///
/// À placer une seule fois, au-dessus du `MaterialApp`/`Navigator`, pour
/// que toute l'application partage la même physique.
class OuroMotionScope extends StatelessWidget {
  const OuroMotionScope({
    super.key,
    required this.child,
    this.degraded = false,
  });

  final Widget child;

  /// Branché sur `ouroGlassDegraded(ref)` par l'appelant, qui a le `ref`.
  final bool degraded;

  @override
  Widget build(BuildContext context) {
    final motion = OuroMotion(
      // ⚠️ C'EST ICI que « Réduire les animations » entre enfin dans
      // l'application. Une seule lecture, à la racine, et les 161
      // fichiers en héritent.
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
      degraded: degraded,
    );
    // Tient le miroir statique à jour — voir [OuroMotion.ambiantAutoriseGlobal].
    OuroMotion.ambiantAutoriseGlobal = motion.ambiantAutorise;
    return _OuroMotionScope(motion: motion, child: child);
  }
}

class _OuroMotionScope extends InheritedWidget {
  const _OuroMotionScope({required this.motion, required super.child});

  final OuroMotion motion;

  @override
  bool updateShouldNotify(_OuroMotionScope old) => old.motion != motion;
}

/// Raccourci de lecture : `context.motion.entrance`.
extension OuroMotionContext on BuildContext {
  OuroMotion get motion => OuroMotion.of(this);
}

/// Démarrer une boucle d'ambiance en respectant l'accessibilité.
///
/// ⚠️ POURQUOI CETTE EXTENSION EXISTE. L'application comptait 37 boucles
/// d'animation réparties sur 26 fichiers — gouttelettes qui pulsent, halos
/// qui respirent, points en orbite, indicateurs de frappe — et UNE SEULE
/// consultait « Réduire les animations ». Les 36 autres tournaient en
/// permanence, réglage système ignoré : exactement le mouvement continu,
/// périphérique et non sollicité qui déclenche les troubles vestibulaires,
/// et qui vide la batterie sans rien apprendre à personne.
///
/// Remplacer `.repeat(...)` par `.bouclerSiAmbiant(...)` suffit à corriger
/// un site. C'est volontairement un changement d'un seul mot : une règle
/// d'accessibilité qui coûte cher à appliquer finit par ne pas l'être.
class _BoucleAmbiante {
  _BoucleAmbiante(AnimationController controleur, this.appliquer)
      : cible = WeakReference(controleur);

  final WeakReference<AnimationController> cible;
  final void Function(AnimationController) appliquer;
}

extension BouclageAmbiant on AnimationController {
  /// Lance la boucle si les animations d'ambiance sont permises, sinon la
  /// pose au repos — et la tient à jour ensuite (voir
  /// [OuroMotion.ambiantAutoriseGlobal]).
  void bouclerSiAmbiant({
    bool reverse = false,
    Duration? period,
    double repos = 1.0,
  }) {
    if (OuroMotion.ambiantAutoriseGlobal) {
      repeat(reverse: reverse, period: period);
    } else {
      stop();
      value = repos.clamp(lowerBound, upperBound);
    }
    OuroMotion._inscrire(this, (controleur) {
      if (OuroMotion.ambiantAutoriseGlobal) {
        if (!controleur.isAnimating) controleur.repeat(reverse: reverse, period: period);
      } else {
        controleur.stop();
        controleur.value = repos.clamp(controleur.lowerBound, controleur.upperBound);
      }
    });
  }
}
