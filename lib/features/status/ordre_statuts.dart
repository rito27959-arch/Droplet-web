// ============================================================================
// L'ORDRE DES STATUTS, ET CEUX QU'ON A DÉJÀ VUS — comme WhatsApp.
// ----------------------------------------------------------------------------
// Partagé par l'onglet Actualités (le carrousel) et le lecteur (qui enchaîne
// d'un contact au suivant) : les deux doivent voir le même ordre, sinon « le
// suivant » dans le lecteur ne serait pas la carte d'à côté.
//
//   • D'abord les contacts qui ont du NOUVEAU, le plus récent en tête ;
//   • ensuite ceux qu'on a déjà tout vus.
//
// « Vu » est une information LOCALE : l'accusé envoyé à l'auteur
// (`sendStatusSeen`) lui dit qui a regardé, mais ne disait rien à notre
// propre écran — l'anneau restait coloré pour toujours.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/models/mesh_message.dart';
import 'status_viewer_screen.dart';
import '../../core/services/storage_service.dart';

class StatutsVus {
  StatutsVus._();

  static const String _cle = 'statuts_vus';

  /// Change à chaque statut vu : le carrousel se redessine aussitôt.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static Set<String>? _cache;

  static Set<String> _charger() {
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

  static bool estVu(String idStatut) => _charger().contains(idStatut);

  /// Un contact est « vu » quand TOUS ses statuts encore actifs l'ont été.
  static bool contactVu(Iterable<MeshStatusRecord> statuts) =>
      statuts.every((s) => estVu(s.id));

  static void marquer(String idStatut) {
    final ids = _charger();
    if (!ids.add(idStatut)) return;
    // Seuls les statuts encore actifs comptent : la liste ne grossit jamais.
    final actifs = StorageService.getActiveStatuses().map((s) => s.id).toSet();
    ids.removeWhere((id) => !actifs.contains(id));
    unawaited(StorageService.setString(_cle, jsonEncode(ids.toList())));
    // Hors de la construction en cours : prévenir un écran pendant qu'un
    // autre se construit est interdit par Flutter.
    scheduleMicrotask(() => revision.value++);
  }
}

/// Les statuts actifs de chaque contact (sauf les miens), du plus ancien au
/// plus récent — l'ordre de lecture.
Map<String, List<MeshStatusRecord>> statutsParContact(String monId) {
  final parContact = <String, List<MeshStatusRecord>>{};
  for (final s in StorageService.getActiveStatuses()) {
    if (s.authorId == monId || StorageService.isContactBlocked(s.authorId)) continue;
    parContact.putIfAbsent(s.authorId, () => []).add(s);
  }
  for (final liste in parContact.values) {
    liste.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
  return parContact;
}

/// Les contacts, dans l'ordre de WhatsApp.
List<String> ordreDesContacts(String monId) {
  final parContact = statutsParContact(monId);
  final contacts = parContact.keys.toList()
    ..sort((a, b) {
      final vuA = StatutsVus.contactVu(parContact[a]!);
      final vuB = StatutsVus.contactVu(parContact[b]!);
      if (vuA != vuB) return vuA ? 1 : -1;
      return parContact[b]!.last.createdAt.compareTo(parContact[a]!.last.createdAt);
    });
  return contacts;
}


/// Une ouverture depuis l'onglet commence une nouvelle séance de lecture,
/// et note l'écran où revenir.
void statutsSeanceReinitialiser({String? origine}) {
  StatusViewerScreen.ordreDeSeance = null;
  StatusViewerScreen.sensArrivee = 0;
  StatusViewerScreen.origine = origine;
}
