// ============================================================================
// LA PASSERELLE GLASMIO — ce qui est commun à tous les écrans natifs.
// ----------------------------------------------------------------------------
// Un écran Glasmio, c'est une route Flutter normale (`/settings`, `/premium`,
// `/chat/x/info`…) dont le widget est une PASSERELLE :
//   • Android 13+ avec la couche Glasmio → elle ouvre l'écran natif par-dessus
//     elle et reste dessous, invisible ;
//   • sinon → elle affiche l'écran Flutter d'origine (`construireRepli`),
//     inchangé : aucune fonctionnalité ne dépend de Glasmio.
//
// Les allers-retours avec Flutter suivent la logique d'iOS :
//   • `allerA` / `sousEcran` : on ferme l'écran natif, on pousse la page
//     Flutter ; au retour, l'écran natif revient (sans animation), comme si
//     on n'en était jamais parti ;
//   • `feuille` : la feuille Flutter s'ouvre au-dessus de l'écran Flutter
//     d'origine, puis l'écran natif revient ;
//   • `basculerVersFlutter` : on reste dans l'écran Flutter d'origine (par
//     exemple pour payer : le parcours de paiement n'est PAS réécrit) ;
//   • retour (flèche, geste) : on quitte la route, comme d'habitude.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import 'pont_glasmio.dart';

enum EtatGlasmio { attente, natif, flutter }

abstract class EtatPasserelleGlasmio<W extends ConsumerStatefulWidget> extends ConsumerState<W> {
  EtatGlasmio _etat = EtatGlasmio.attente;

  /// Ce qu'il faut faire côté Flutter une fois l'écran natif fermé.
  Future<void> Function()? _apres;

  /// Les textes à utiliser pendant que l'écran natif est ouvert, quand la
  /// langue vient de changer (Flutter, en arrière-plan, ne s'est pas encore
  /// reconstruit).
  AppLocalizations? textesForces;

  /// Le nom de l'écran natif (pour le journal du pont).
  String get ecran;

  /// Faux quand cet écran n'a pas de version Glasmio dans ce cas précis
  /// (par exemple le canal de diffusion) : l'écran Flutter s'affiche.
  bool get natifPossible => true;

  /// L'écran Flutter d'origine.
  Widget construireRepli(BuildContext context);

  /// La description JSON de l'écran natif.
  Future<Map<String, Object?>> decrire();

  /// Un geste dans l'écran natif.
  Future<ReponseGlasmio> gerer(String id, Object? valeur);

  /// Appelés à chaque ouverture et fermeture de l'écran natif (pour
  /// s'abonner aux données qui changent toutes seules).
  void surOuvert() {}
  void surFerme() {}

  AppLocalizations get textes => textesForces ?? AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ouvrir());
  }

  @override
  void dispose() {
    if (_etat == EtatGlasmio.natif) surFerme();
    super.dispose();
  }

  Future<void> _ouvrir({bool sansAnimation = false}) async {
    if (!natifPossible || !await PontGlasmio.disponible()) {
      if (mounted) setState(() => _etat = EtatGlasmio.flutter);
      return;
    }
    if (!mounted) return;
    final ok = await PontGlasmio.ouvrir(
      ecran: ecran,
      description: await decrire(),
      gestionnaire: gerer,
      surFermeture: _surFermeture,
      sansAnimation: sansAnimation,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _etat = EtatGlasmio.flutter);
      return;
    }
    setState(() => _etat = EtatGlasmio.natif);
    surOuvert();
  }

  void _surFermeture() {
    surFerme();
    textesForces = null;
    if (!mounted) return;
    final apres = _apres;
    _apres = null;
    if (apres != null) {
      unawaited(apres());
    } else {
      quitter();
    }
  }

  /// Quitte la route, comme la flèche de retour.
  void quitter() {
    final routeur = GoRouter.of(context);
    if (routeur.canPop()) {
      routeur.pop();
    } else {
      routeur.go('/');
    }
  }

  /// Redessine l'écran natif ouvert.
  Future<void> rafraichir() async {
    if (!mounted || _etat != EtatGlasmio.natif) return;
    await PontGlasmio.mettreAJour(await decrire());
  }

  /// Ferme l'écran natif, ouvre [ouvrir] (une page Flutter) ; au retour,
  /// l'écran natif revient.
  ReponseGlasmio sousEcran(Future<void> Function() ouvrir) {
    _apres = () async {
      await ouvrir();
      if (mounted) await _ouvrir(sansAnimation: true);
    };
    return const ReponseGlasmio.fermer();
  }

  ReponseGlasmio allerA(String route) {
    final routeur = GoRouter.of(context);
    return sousEcran(() => routeur.push(route));
  }

  ReponseGlasmio pousser(Route<void> route) {
    final nav = Navigator.of(context);
    return sousEcran(() => nav.push(route));
  }

  /// Ferme l'écran natif, ouvre une feuille Flutter au-dessus de l'écran
  /// Flutter d'origine ; quand elle se ferme, l'écran natif revient.
  ReponseGlasmio feuille(Future<void> Function(BuildContext) ouvrir) {
    _apres = () async {
      if (!mounted) return;
      setState(() => _etat = EtatGlasmio.flutter);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await ouvrir(context);
      if (mounted) await _ouvrir(sansAnimation: true);
    };
    return const ReponseGlasmio.fermer();
  }

  /// Ferme l'écran natif et reste dans l'écran Flutter d'origine — puis,
  /// s'il y en a une, lance [ensuite] (une fois cet écran affiché).
  ReponseGlasmio basculerVersFlutter([Future<void> Function()? ensuite]) {
    _apres = () async {
      if (!mounted) return;
      setState(() => _etat = EtatGlasmio.flutter);
      if (ensuite != null) {
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) await ensuite();
      }
    };
    return const ReponseGlasmio.fermer();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_etat) {
      EtatGlasmio.flutter => construireRepli(context),
      // Pendant que l'écran natif est ouvert (ou s'ouvre) : RIEN. La route est
      // transparente (voir _pagePasserelle dans main.dart) : sous l'écran
      // natif, c'est la page d'où l'on vient qui reste visible — jamais une
      // page vide, blanche ou noire, aux transitions.
      _ => const SizedBox.expand(),
    };
  }
}
