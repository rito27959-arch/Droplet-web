// ============================================================================
// « OUVERT » — les vues uniques que j'ai envoyées et que l'autre a ouvertes.
// ----------------------------------------------------------------------------
// Comme WhatsApp : tant que l'autre n'a pas ouvert la photo, la bulle de
// l'expéditeur affiche « Photo » avec la pastille « 1 » pleine ; dès qu'il
// l'ouvre, elle passe à « Ouvert ».
//
// L'avis voyage dans un accusé de lecture ordinaire (`k: read`) dont le
// contenu est `vu1:<id du message>`. Un ancien Droplet le prend pour un
// accusé de lecture d'un message qu'il ne connaît pas, et l'ignore : rien
// de nouveau à comprendre pour lui, rien de cassé.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class VuesUniquesOuvertes {
  VuesUniquesOuvertes._();

  /// Préfixe de l'accusé « vue unique ouverte ».
  static const String prefixe = 'vu1:';

  static const String _cle = 'vues_uniques_ouvertes_chez_lautre';

  /// Change quand l'autre ouvre une vue unique : les bulles se redessinent.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Set<String>? _cache;

  static Set<String> _ids() {
    final deja = _cache;
    if (deja != null) return deja;
    final ids = <String>{};
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        ids.addAll((jsonDecode(brut) as List).whereType<String>());
      } catch (_) {}
    }
    return _cache = ids;
  }

  /// L'autre a-t-il ouvert cette vue unique (que j'ai envoyée) ?
  static bool contient(String idMessage) => _ids().contains(idMessage);

  /// Un accusé reçu : `vu1:<id>` → l'id, sinon null.
  static String? idDepuisAccuse(String contenu) =>
      contenu.startsWith(prefixe) && contenu.length > prefixe.length
          ? contenu.substring(prefixe.length)
          : null;

  static void noter(String idMessage) {
    final ids = _ids();
    if (!ids.add(idMessage)) return;
    // On ne garde que les 500 derniers : c'est un affichage, pas un registre.
    if (ids.length > 500) {
      final garde = ids.toList().sublist(ids.length - 500);
      ids
        ..clear()
        ..addAll(garde);
    }
    unawaited(StorageService.setString(_cle, jsonEncode(ids.toList())));
    revision.value++;
  }
}
