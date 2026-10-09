// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES BROUILLONS — ce qu'on avait commencé à écrire avant de quitter une
// conversation.
//
// On tape une réponse, un appel arrive, on revient : le texte avait
// disparu. C'est l'une des petites pertes qu'on pardonne le moins à une
// messagerie, parce qu'elle punit exactement le geste qu'on fait le plus —
// passer d'une discussion à l'autre.
//
// Le brouillon est gardé, remis dans le champ au retour, et la liste des
// discussions l'affiche en rouge — « Brouillon : On se voit à… » — comme
// Telegram, pour qu'une réponse commencée ne soit jamais oubliée.
// ============================================================================

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class Brouillons {
  Brouillons._();

  static const String _prefixe = 'brouillon:';

  /// Incrémenté à chaque changement : la liste se redessine.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static String? lire(String conversation) {
    try {
      final t = StorageService.getString('$_prefixe$conversation');
      return (t == null || t.trim().isEmpty) ? null : t;
    } catch (_) {
      return null;
    }
  }

  /// Écrit le brouillon — ou l'efface s'il est vide.
  static Future<void> ecrire(String conversation, String texte) async {
    final avant = lire(conversation);
    final net = texte.trim().isEmpty ? null : texte;
    if (avant == net) return;
    try {
      if (net == null) {
        await StorageService.remove('$_prefixe$conversation');
      } else {
        await StorageService.setString('$_prefixe$conversation', net);
      }
    } catch (_) {
      return;
    }
    revision.value++;
  }
}
