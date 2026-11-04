// ============================================================================
// QUAND L'AVION EN PAPIER S'ENVOLE — et comment il est chargé.
// ----------------------------------------------------------------------------
// ⚠️ UNE FOIS SUR PLUSIEURS, JAMAIS À CHAQUE MESSAGE. Un effet répété à
// chaque envoi devient une gêne au dixième. La même règle que l'app :
//   • le premier message du jour dans une discussion,
//   • ou un long message (plus de 140 caractères),
//   • ou dix minutes depuis le dernier avion ;
//   • et jamais deux avions à moins de 25 secondes.
// « Réduire les animations » (système) : jamais.
//
// Flame n'est chargé qu'au premier avion (`deferred`) : le premier
// chargement de Droplet Web n'en paie pas le poids.
// ============================================================================

import 'package:flutter/widgets.dart';

import 'avion_web.dart' deferred as avion;

class LanceurAvion {
  LanceurAvion._();

  static DateTime? _dernier;
  static final Map<String, DateTime> _jourParDiscussion = {};

  static bool _choisir(String discussionId, String texte) {
    final maintenant = DateTime.now();
    final dernier = _dernier;
    if (dernier != null && maintenant.difference(dernier) < const Duration(seconds: 25)) return false;
    final jour = _jourParDiscussion[discussionId];
    final premierDuJour = jour == null || jour.day != maintenant.day || jour.month != maintenant.month || jour.year != maintenant.year;
    _jourParDiscussion[discussionId] = maintenant;
    return premierDuJour ||
        texte.length > 140 ||
        dernier == null ||
        maintenant.difference(dernier) >= const Duration(minutes: 10);
  }

  /// Fait voler l'avion de [depart] à [arrivee] (coordonnées de l'écran),
  /// si la règle le permet.
  static Future<void> peutEtre(
    BuildContext context, {
    required String discussionId,
    required String texte,
    required Offset depart,
    required Offset arrivee,
    required Color accent,
    required bool sombre,
  }) async {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    if (!_choisir(discussionId, texte)) return;
    _dernier = DateTime.now();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    try {
      await avion.loadLibrary();
    } catch (_) {
      return; // hors ligne au premier avion : tant pis, le message est parti
    }
    late final OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => avion.sceneAvion(
        depart: depart,
        arrivee: arrivee,
        accent: accent,
        sombre: sombre,
        surFin: () => entree.remove(),
      ),
    );
    overlay.insert(entree);
  }
}
