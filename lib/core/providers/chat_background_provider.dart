// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Le choix du FOND DE DISCUSSION — le dégradé animé qui tourne d'un cran
// à chaque message envoyé (voir `telegram_gradient_background.dart`).
//
// Comme chez Telegram, ce n'est pas imposé : c'est un réglage. Et il
// comporte une option « Aucun », qui n'est pas là par politesse.
//
// ⚠️ POURQUOI L'OPTION « AUCUN » EST OBLIGATOIRE ICI.
//
// Le dégradé est calculé pixel par pixel, puis étiré. C'est peu coûteux,
// mais ce n'est pas gratuit — et Droplet tourne sur des téléphones
// modestes, parfois déjà en surchauffe (l'app a un détecteur d'état
// thermique pour cette raison précise). Un utilisateur qui préfère
// économiser sa batterie, ou qui trouve simplement que le mouvement le
// distrait, doit pouvoir l'éteindre. Un effet décoratif qu'on ne peut
// pas couper est un défaut, pas une fonctionnalité.
// ============================================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/fonds_premium.dart';
import '../services/device_profile.dart';
import '../services/storage_service.dart';

const String _fondKey = 'chat_background';

/// La valeur enregistrée quand l'utilisateur ne veut aucun dégradé.
const String kFondAucun = 'aucun';

/// Le fond de discussion choisi : une clé de palette, ou [kFondAucun].
final chatBackgroundProvider =
    StateNotifierProvider<ChatBackgroundNotifier, String>((ref) {
  return ChatBackgroundNotifier();
});

class ChatBackgroundNotifier extends StateNotifier<String> {
  ChatBackgroundNotifier() : super(_load());

  static String _load() {
    final choisi = StorageService.getString(_fondKey);
    // ⚠️ SUR UN APPAREIL MODESTE, LE DÉFAUT EST « AUCUN ».
    //
    // Le dégradé recalcule une image à chaque message envoyé, et occupe
    // une surface plein écran de plus. Ce n'est pas énorme — mais sur un
    // téléphone de 2 Go, l'addition de « pas énorme » est exactement ce
    // qui fait tuer l'application.
    //
    // On ne le RETIRE pas : quelqu'un qui l'a explicitement choisi le
    // garde. On se contente de ne pas l'imposer à qui n'a rien demandé.
    if (choisi != null) {
      // Un fond qui n'existe plus (ancienne version) est remplacé par
      // l'ambiance la plus proche, pas par un fond uni.
      final remplacant = FondsPremium.remplacements[choisi];
      if (remplacant != null) {
        unawaited(StorageService.setString(_fondKey, remplacant));
        return remplacant;
      }
      return choisi;
    }
    return DeviceProfile.menager ? kFondAucun : 'mesh';
  }

  Future<void> set(String cle) async {
    state = cle;
    await StorageService.setString(_fondKey, cle);
  }
}

const String _motifsKey = 'chat_motifs';

/// Les MOTIFS au trait posés par-dessus le fond de discussion (gouttes,
/// maillage, ondes radio… — voir `motifs_droplet.dart`). Activés par défaut :
/// une seule petite image, calculée une fois, répétée par le GPU.
final chatMotifsProvider =
    StateNotifierProvider<ChatMotifsNotifier, bool>((ref) {
  return ChatMotifsNotifier();
});

class ChatMotifsNotifier extends StateNotifier<bool> {
  ChatMotifsNotifier() : super(StorageService.getString(_motifsKey) != 'off');

  Future<void> set(bool actifs) async {
    state = actifs;
    await StorageService.setString(_motifsKey, actifs ? 'on' : 'off');
  }
}

// ── Le fond PROPRE À UNE DISCUSSION ─────────────────────────────────────────
//
// Comme les thèmes de discussion de Telegram : une conversation peut avoir
// son fond à elle. `null` = elle suit le fond choisi dans les réglages.
// Le réglage reste sur cet appareil.

String _cleFondConversation(String conversation) => 'chat_background:$conversation';

final fondConversationProvider =
    StateNotifierProvider.family<FondConversationNotifier, String?, String>(
  (ref, conversation) => FondConversationNotifier(conversation),
);

class FondConversationNotifier extends StateNotifier<String?> {
  FondConversationNotifier(this.conversation)
      : super(_lire(conversation));

  final String conversation;

  static String? _lire(String conversation) {
    final brut = StorageService.getString(_cleFondConversation(conversation));
    if (brut == null || brut.isEmpty) return null;
    return FondsPremium.remplacements[brut] ?? brut;
  }

  /// [cle] `null` : revenir au fond des réglages.
  Future<void> set(String? cle) async {
    state = cle;
    await StorageService.setString(_cleFondConversation(conversation), cle ?? '');
  }
}
