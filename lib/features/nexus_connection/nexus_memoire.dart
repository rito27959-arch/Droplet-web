// ============================================================================
// NEXUS NE SE JOUE QU'UNE FOIS PAR APPAREIL RENCONTRÉ — POUR TOUJOURS.
// ----------------------------------------------------------------------------
// L'animation célèbre la PREMIÈRE rencontre entre deux téléphones. Elle se
// rejouait pourtant à chaque reconnexion et à chaque ouverture de l'app : le
// seul verrou était un drapeau en mémoire, remis à zéro dès la fin de
// l'animation. Ce qui devait être un moment devenait une gêne.
//
// On retient donc, de façon durable, les appareils avec qui elle a déjà été
// jouée. Un appareil avec qui l'on a déjà échangé des messages compte aussi
// comme déjà rencontré : la première rencontre a eu lieu avant cette version.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/services/storage_service.dart';

class NexusMemoire {
  NexusMemoire._();

  static const cleStockage = 'nexus_pairs_deja_vus';

  static Set<String>? _cache;

  static Set<String> _pairs() {
    final cache = _cache;
    if (cache != null) return cache;
    final lus = <String>{};
    final brut = StorageService.getString(cleStockage);
    if (brut != null && brut.isNotEmpty) {
      try {
        lus.addAll((jsonDecode(brut) as List).whereType<String>());
      } catch (_) {
        // Valeur illisible : on repart d'une liste vide.
      }
    }
    return _cache = lus;
  }

  /// Faut-il jouer Nexus pour [peerId] ? Vrai UNE seule fois par appareil ;
  /// l'appareil est retenu dès cet appel, que l'animation soit jouée ou non.
  ///
  /// [dejaEnContact] : on a déjà échangé des messages avec lui — la première
  /// rencontre est passée, on ne la rejoue pas.
  static bool doitJouer(String peerId, {required bool dejaEnContact}) {
    if (peerId.isEmpty) return false;
    final pairs = _pairs();
    // Vérifié et retenu d'un seul geste, sans attente : deux signaux presque
    // simultanés (détection locale et événement reçu de l'autre téléphone)
    // ne peuvent pas passer tous les deux.
    if (!pairs.add(peerId)) return false;
    unawaited(StorageService.setString(cleStockage, jsonEncode(pairs.toList())));
    return !dejaEnContact;
  }

  @visibleForTesting
  static void oublierCache() => _cache = null;
}
