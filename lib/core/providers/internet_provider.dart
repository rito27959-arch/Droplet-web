import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/etat_internet.dart';

/// Vrai tant qu'un serveur Droplet a répondu récemment (voir [EtatInternet]).
///
/// Réévalué à chaque nouvelle preuve, et toutes les 10 secondes pour que
/// l'état redevienne « sans Internet » quand les preuves cessent d'arriver.
final internetDisponibleProvider =
    StateNotifierProvider<InternetDisponibleNotifier, bool>((ref) {
  return InternetDisponibleNotifier();
});

class InternetDisponibleNotifier extends StateNotifier<bool> {
  InternetDisponibleNotifier() : super(EtatInternet.disponible()) {
    EtatInternet.derniereReussite.addListener(_reevaluer);
    _minuteur = Timer.periodic(const Duration(seconds: 10), (_) => _reevaluer());
  }

  Timer? _minuteur;

  void _reevaluer() {
    final disponible = EtatInternet.disponible();
    if (mounted && disponible != state) state = disponible;
  }

  @override
  void dispose() {
    EtatInternet.derniereReussite.removeListener(_reevaluer);
    _minuteur?.cancel();
    super.dispose();
  }
}
