// ============================================================================
// L'ANIMATION D'ENVOI — complète, réduite, ou pas d'animation du tout.
// ----------------------------------------------------------------------------
// Plic, la goutte messagère, vient saluer chaque message envoyé. Certains
// adorent, d'autres envoient cent messages par heure et n'en veulent pas :
// le choix se fait dans Apparence (voir `section_animation_envoi.dart`), avec
// un aperçu qui joue vraiment l'animation, comme les réglages d'iOS.
//
// ⚠️ Le réglage « Réduire les animations » du téléphone l'emporte : même en
// « Complète », la mascotte passe alors en version réduite (des fondus, rien
// d'autre). C'est `MascotteEnvoi` qui applique cette règle.
//
// Le choix est conservé d'un lancement à l'autre dans le magasin clé/valeur
// de `storage_service.dart`, comme le mode sombre.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// Les trois réglages possibles.
enum ModeAnimationEnvoi {
  /// Plic emporte le message, se téléporte et salue. Le défaut.
  complete,

  /// Un fondu, sans déplacement ni particules.
  reduite,

  /// Rien après l'envoi.
  desactivee;
}

const String _cleAnimationEnvoi = 'animation_envoi';

/// Le mode choisi, persisté entre deux lancements.
final animationEnvoiProvider =
    StateNotifierProvider<AnimationEnvoiNotifier, ModeAnimationEnvoi>((ref) {
  return AnimationEnvoiNotifier();
});

class AnimationEnvoiNotifier extends StateNotifier<ModeAnimationEnvoi> {
  AnimationEnvoiNotifier() : super(_charger());

  static ModeAnimationEnvoi _charger() {
    final brut = StorageService.getString(_cleAnimationEnvoi);
    return ModeAnimationEnvoi.values.firstWhere(
      (m) => m.name == brut,
      orElse: () => ModeAnimationEnvoi.complete,
    );
  }

  Future<void> choisir(ModeAnimationEnvoi mode) async {
    state = mode;
    await StorageService.setString(_cleAnimationEnvoi, mode.name);
  }
}
