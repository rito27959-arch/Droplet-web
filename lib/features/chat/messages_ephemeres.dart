// ============================================================================
// LES MESSAGES ÉPHÉMÈRES — ils s'effacent des deux côtés, tout seuls.
// ----------------------------------------------------------------------------
// Sans serveur, personne ne peut aller effacer un message sur le téléphone
// d'en face après coup. La seule façon honnête : que le message PORTE
// lui-même sa date de péremption. Chaque message envoyé pendant que le
// minuteur est actif part avec une marque ; les deux téléphones la lisent et
// effacent au même moment.
//
// Conséquence assumée : changer le réglage ne touche pas aux messages déjà
// envoyés. C'est aussi ce que fait WhatsApp.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/models/mesh_message.dart';
import '../../core/services/storage_service.dart';

class Ephemeres {
  Ephemeres._();

  /// Les durées proposées, dans l'ordre de l'écran.
  static const List<Duration> durees = [
    Duration(hours: 24),
    Duration(days: 7),
    Duration(days: 90),
  ];

  static const String _cle = 'ephemeres';

  /// Change quand un minuteur est posé ou retiré.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Map<String, int>? _cache;

  static Map<String, int> _tous() {
    final deja = _cache;
    if (deja != null) return deja;
    final map = <String, int>{};
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        (jsonDecode(brut) as Map<String, dynamic>).forEach((k, v) {
          if (v is num) map[k] = v.toInt();
        });
      } catch (_) {}
    }
    return _cache = map;
  }

  /// Le minuteur d'une discussion, ou `null` s'il n'y en a pas.
  static Duration? dureeDe(String cleConversation) {
    final s = _tous()[cleConversation];
    return s == null || s <= 0 ? null : Duration(seconds: s);
  }

  static void definir(String cleConversation, Duration? duree) {
    final map = {..._tous()};
    if (duree == null) {
      map.remove(cleConversation);
    } else {
      map[cleConversation] = duree.inSeconds;
    }
    _cache = map;
    unawaited(StorageService.setString(_cle, jsonEncode(map)));
    revision.value++;
  }

  // ── La marque portée par le message ───────────────────────────────────

  static final RegExp _marque = RegExp(r'^\u0002ep(\d+)\u0002');

  /// Colle la date de péremption en tête du texte. Le caractère de contrôle
  /// ne peut pas être tapé au clavier : aucune confusion possible avec un
  /// vrai message.
  static String marquer(String texte, Duration duree) =>
      '\u0002ep${duree.inSeconds}\u0002$texte';

  /// La durée de vie d'un message, s'il en a une.
  static Duration? dureeDuMessage(String contenu) {
    final m = _marque.firstMatch(contenu);
    if (m == null) return null;
    return Duration(seconds: int.parse(m.group(1)!));
  }

  /// Le texte sans sa marque — ce que l'on montre, partout.
  static String sansMarque(String contenu) =>
      contenu.replaceFirst(_marque, '');

  /// Quand ce message doit disparaître.
  static DateTime? expiration(MeshMessage message) {
    final duree = dureeDuMessage(message.content);
    return duree == null ? null : message.timestamp.add(duree);
  }

  /// Ce qu'il reste à vivre, pour l'afficher dans la bulle.
  static Duration? restant(MeshMessage message) {
    final fin = expiration(message);
    if (fin == null) return null;
    final reste = fin.difference(DateTime.now());
    return reste.isNegative ? Duration.zero : reste;
  }

  /// Les messages dont l'heure est passée : à effacer des deux côtés.
  static List<String> perimes(List<MeshMessage> messages) => [
        for (final m in messages)
          if ((expiration(m) ?? DateTime.now().add(const Duration(days: 1)))
              .isBefore(DateTime.now()))
            m.id,
      ];
}
