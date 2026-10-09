// ============================================================================
// « INTERNET MARCHE-T-IL EN CE MOMENT ? » — une preuve, pas une supposition.
// ----------------------------------------------------------------------------
// Avoir du Wi-Fi ou de la 4G ne prouve rien : un portail captif, un réseau
// saturé ou un DNS en panne donnent une connexion qui ne mène nulle part.
// Et `MailboxClient.fetchAll` renvoyait une liste vide aussi bien pour « boîte
// vide » que pour « serveur injoignable » — impossible d'en déduire l'état.
//
// On retient donc le MOMENT de la dernière réponse réelle d'un de nos
// serveurs (boîte aux lettres, serveur d'appels). Internet est dit disponible
// tant que cette preuve a moins de [fenetre] — plus que l'intervalle de
// relève en arrière-plan (30 s), pour ne pas clignoter entre deux relèves.
// ============================================================================

import 'package:flutter/foundation.dart';

class EtatInternet {
  EtatInternet._();

  /// Durée de validité d'une preuve.
  static const Duration fenetre = Duration(seconds: 75);

  /// Moment de la dernière réponse réussie d'un serveur Droplet.
  static final ValueNotifier<DateTime?> derniereReussite = ValueNotifier<DateTime?>(null);

  /// À appeler dès qu'un serveur a répondu normalement.
  static void signalerReussite([DateTime? quand]) {
    derniereReussite.value = quand ?? DateTime.now();
  }

  static bool disponible({DateTime? maintenant}) {
    final derniere = derniereReussite.value;
    if (derniere == null) return false;
    return (maintenant ?? DateTime.now()).difference(derniere) <= fenetre;
  }
}
