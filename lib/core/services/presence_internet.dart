// ============================================================================
// LA PRÉSENCE PAR INTERNET — qui est joignable MAINTENANT, hors du maillage.
// ----------------------------------------------------------------------------
// Jusqu'ici, « vu à 14 h 03 » voulait dire : croisé par le maillage à 14 h 03.
// Utile en festival, inutile pour savoir si quelqu'un, à l'autre bout du
// pays, peut recevoir mon message tout de suite.
//
// Ici, on note l'heure du dernier signe reçu PAR INTERNET : un paquet relevé
// dans la boîte aux lettres, une réponse arrivée par Tor. C'est la seule
// preuve honnête qu'on ait sans serveur de présence : ça ne dit pas « il
// regarde son écran », ça dit « son téléphone a parlé par Internet à telle
// heure ». Les deux sources restent séparées — on ne mélange jamais un
// croisement physique avec une trace en ligne.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class PresenceInternet {
  PresenceInternet._();

  /// En deçà, on dit « en ligne ». Au-delà, on dit depuis quand.
  static const Duration fraicheur = Duration(minutes: 5);

  static const String _cle = 'presence_internet';

  /// Change à chaque signe reçu : les en-têtes et la liste se redessinent.
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

  /// Un signe de vie est arrivé par Internet de la part de ce pair.
  static void signe(String peerId, {DateTime? quand}) {
    if (peerId.isEmpty) return;
    final t = (quand ?? DateTime.now()).millisecondsSinceEpoch;
    final map = {..._tous()};
    // Un dépôt retardataire ne doit pas rajeunir une présence plus récente.
    if ((map[peerId] ?? 0) >= t) return;
    map[peerId] = t;
    _cache = map;
    unawaited(StorageService.setString(_cle, jsonEncode(map)));
    revision.value++;
  }

  /// Même chose, dans l'ordre attendu par `Map.forEach`.
  static void signe2(String peerId, DateTime quand) =>
      signe(peerId, quand: quand);

  /// Le dernier signe reçu par Internet, s'il y en a eu un.
  static DateTime? dernierSigne(String peerId) {
    final t = _tous()[peerId];
    return t == null ? null : DateTime.fromMillisecondsSinceEpoch(t);
  }

  /// Vrai si ce pair a donné signe de vie par Internet à l'instant.
  static bool enLigne(String peerId) {
    final t = dernierSigne(peerId);
    return t != null && DateTime.now().difference(t) < fraicheur;
  }

  /// Depuis combien de temps, pour l'écrire.
  static Duration? depuis(String peerId) {
    final t = dernierSigne(peerId);
    return t == null ? null : DateTime.now().difference(t);
  }

  static void oublier(String peerId) {
    final map = {..._tous()}..remove(peerId);
    _cache = map;
    unawaited(StorageService.setString(_cle, jsonEncode(map)));
    revision.value++;
  }
}
