// ============================================================================
// LES RÉGLAGES D'UN GROUPE — description et droit d'écriture.
// ----------------------------------------------------------------------------
// Ces deux réglages voyagent dans le manifeste du groupe, à côté du nom et
// des membres. Ils sont rangés à part de la base : une colonne de plus
// demanderait une migration du schéma, alors qu'un petit JSON à côté fait
// le même travail et se synchronise aussi bien.
//
// Règle de fusion : le plus récent gagne. Chaque modification porte son
// heure, et un manifeste plus vieux n'écrase jamais un réglage plus neuf.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/services/storage_service.dart';

class ReglagesGroupe {
  const ReglagesGroupe({
    this.description = '',
    this.envoiAdminsSeuls = false,
    required this.majA,
  });

  /// Ce que le groupe raconte de lui-même. Vide par défaut.
  final String description;

  /// Quand c'est vrai, seuls les administrateurs peuvent écrire.
  final bool envoiAdminsSeuls;

  /// L'heure de la dernière modification, qui tranche en cas de désaccord.
  final DateTime majA;

  ReglagesGroupe copier({String? description, bool? envoiAdminsSeuls}) =>
      ReglagesGroupe(
        description: description ?? this.description,
        envoiAdminsSeuls: envoiAdminsSeuls ?? this.envoiAdminsSeuls,
        majA: DateTime.now(),
      );

  Map<String, Object?> versJson() => {
        'description': description,
        'envoiAdminsSeuls': envoiAdminsSeuls,
        'majA': majA.toIso8601String(),
      };

  static ReglagesGroupe? depuisJson(Object? brut) {
    if (brut is! Map) return null;
    final maj = brut['majA'];
    return ReglagesGroupe(
      description: (brut['description'] as String?) ?? '',
      envoiAdminsSeuls: brut['envoiAdminsSeuls'] == true,
      majA: maj is String
          ? (DateTime.tryParse(maj) ?? DateTime.fromMillisecondsSinceEpoch(0))
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ReglagesGroupes {
  ReglagesGroupes._();

  static const String _cle = 'reglages_groupes';

  /// Change à chaque réglage modifié ou reçu.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Map<String, ReglagesGroupe>? _cache;

  static Map<String, ReglagesGroupe> _tous() {
    final deja = _cache;
    if (deja != null) return deja;
    final map = <String, ReglagesGroupe>{};
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        (jsonDecode(brut) as Map<String, dynamic>).forEach((id, valeur) {
          final r = ReglagesGroupe.depuisJson(valeur);
          if (r != null) map[id] = r;
        });
      } catch (_) {}
    }
    return _cache = map;
  }

  static ReglagesGroupe de(String groupId) =>
      _tous()[groupId] ??
      ReglagesGroupe(majA: DateTime.fromMillisecondsSinceEpoch(0));

  static void definir(String groupId, ReglagesGroupe reglages) {
    final map = {..._tous(), groupId: reglages};
    _cache = map;
    unawaited(
      StorageService.setString(
        _cle,
        jsonEncode({for (final e in map.entries) e.key: e.value.versJson()}),
      ),
    );
    revision.value++;
  }

  /// Applique ce qui arrive dans un manifeste, si c'est plus récent que ce
  /// qu'on a.
  static void appliquerDuSync(String groupId, Map<String, dynamic> payload) {
    if (!payload.containsKey('reglages')) return;
    final recu = ReglagesGroupe.depuisJson(payload['reglages']);
    if (recu == null) return;
    if (!recu.majA.isAfter(de(groupId).majA)) return;
    definir(groupId, recu);
  }
}
