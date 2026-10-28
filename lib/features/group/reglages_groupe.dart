// ============================================================================
// LES RÉGLAGES D'UN GROUPE — description et permissions.
// ----------------------------------------------------------------------------
// Ces réglages voyagent dans le manifeste du groupe, à côté du nom et des
// membres. Ils sont rangés à part de la base : une colonne de plus
// demanderait une migration du schéma, alors qu'un petit JSON à côté fait
// le même travail et se synchronise aussi bien.
//
// ── Les permissions, comme WhatsApp ───────────────────────────────────
//
// « Les membres peuvent : modifier les infos du groupe, envoyer des
// messages, ajouter d'autres membres » ; « Les administrateurs peuvent :
// approuver les nouveaux membres ». Les valeurs par défaut gardent le
// comportement d'avant : tout le monde modifie les infos et écrit, seuls
// les administrateurs ajoutent, pas d'approbation.
//
// Règle de fusion : le plus récent gagne — et ⚠️ SEULEMENT S'IL VIENT D'UN
// ADMINISTRATEUR (voir `MeshRepository._applyGroupSync`). Avant, n'importe
// quel membre pouvait couper la parole à tout le groupe en envoyant un
// manifeste avec « seuls les admins écrivent ».
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/models/mesh_message.dart';
import '../../core/services/storage_service.dart';

class ReglagesGroupe {
  const ReglagesGroupe({
    this.description = '',
    this.envoiAdminsSeuls = false,
    this.infosAdminsSeuls = false,
    this.ajoutAdminsSeuls = true,
    this.approbation = false,
    required this.majA,
  });

  /// Ce que le groupe raconte de lui-même. Vide par défaut.
  final String description;

  /// Seuls les administrateurs peuvent écrire.
  final bool envoiAdminsSeuls;

  /// Seuls les administrateurs peuvent changer le nom, la photo et la
  /// description.
  final bool infosAdminsSeuls;

  /// Seuls les administrateurs peuvent ajouter des membres.
  final bool ajoutAdminsSeuls;

  /// Les entrées par code QR attendent l'accord d'un administrateur.
  final bool approbation;

  /// L'heure de la dernière modification, qui tranche en cas de désaccord.
  final DateTime majA;

  ReglagesGroupe copier({
    String? description,
    bool? envoiAdminsSeuls,
    bool? infosAdminsSeuls,
    bool? ajoutAdminsSeuls,
    bool? approbation,
  }) =>
      ReglagesGroupe(
        description: description ?? this.description,
        envoiAdminsSeuls: envoiAdminsSeuls ?? this.envoiAdminsSeuls,
        infosAdminsSeuls: infosAdminsSeuls ?? this.infosAdminsSeuls,
        ajoutAdminsSeuls: ajoutAdminsSeuls ?? this.ajoutAdminsSeuls,
        approbation: approbation ?? this.approbation,
        majA: DateTime.now(),
      );

  /// [peerId] peut-il modifier le nom, la photo, la description ?
  bool peutModifierInfos(GroupInfo g, String peerId) =>
      g.isAdmin(peerId) || (g.isActiveMember(peerId) && !infosAdminsSeuls);

  /// [peerId] peut-il ajouter des membres ?
  bool peutAjouter(GroupInfo g, String peerId) =>
      g.isAdmin(peerId) || (g.isActiveMember(peerId) && !ajoutAdminsSeuls);

  /// [peerId] peut-il écrire ?
  bool peutEcrire(GroupInfo g, String peerId) =>
      g.isAdmin(peerId) || (g.isActiveMember(peerId) && !envoiAdminsSeuls);

  Map<String, Object?> versJson() => {
        'description': description,
        'envoiAdminsSeuls': envoiAdminsSeuls,
        'infosAdminsSeuls': infosAdminsSeuls,
        'ajoutAdminsSeuls': ajoutAdminsSeuls,
        'approbation': approbation,
        'majA': majA.toIso8601String(),
      };

  static ReglagesGroupe? depuisJson(Object? brut) {
    if (brut is! Map) return null;
    final maj = brut['majA'];
    return ReglagesGroupe(
      description: (brut['description'] as String?) ?? '',
      envoiAdminsSeuls: brut['envoiAdminsSeuls'] == true,
      infosAdminsSeuls: brut['infosAdminsSeuls'] == true,
      // Absent (ancien client) : le comportement d'avant, admins seuls.
      ajoutAdminsSeuls: brut['ajoutAdminsSeuls'] != false,
      approbation: brut['approbation'] == true,
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
  /// qu'on a ET si l'expéditeur est administrateur du groupe.
  static void appliquerDuSync(String groupId, Map<String, dynamic> payload, {required bool emetteurAdmin}) {
    if (!payload.containsKey('reglages')) return;
    final recu = ReglagesGroupe.depuisJson(payload['reglages']);
    if (recu == null) return;
    if (!recu.majA.isAfter(de(groupId).majA)) return;
    if (!emetteurAdmin) return;
    definir(groupId, recu);
  }
}

// ─────────────────────────────────────────────────────────────
//  LES DEMANDES D'ADHÉSION
// ─────────────────────────────────────────────────────────────

/// Une demande d'entrée reçue par code QR, en attente d'un administrateur.
@immutable
class DemandeAdhesion {
  const DemandeAdhesion({required this.groupId, required this.peerId, required this.quand});

  final String groupId;
  final String peerId;
  final DateTime quand;

  Map<String, Object?> versJson() => {'g': groupId, 'p': peerId, 't': quand.millisecondsSinceEpoch};

  static DemandeAdhesion? depuisJson(Object? b) {
    if (b is! Map) return null;
    final g = b['g'], p = b['p'], t = b['t'];
    if (g is! String || p is! String || t is! int) return null;
    return DemandeAdhesion(groupId: g, peerId: p, quand: DateTime.fromMillisecondsSinceEpoch(t));
  }
}

/// Les demandes en attente, sur CET appareil (celui qui a montré le code).
class DemandesAdhesion {
  DemandesAdhesion._();

  static const String _cle = 'demandes_adhesion';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static List<DemandeAdhesion> _toutes() {
    final brut = StorageService.getString(_cle);
    if (brut == null || brut.isEmpty) return [];
    try {
      return [
        for (final e in jsonDecode(brut) as List)
          if (DemandeAdhesion.depuisJson(e) case final d?) d,
      ];
    } catch (_) {
      return [];
    }
  }

  static void _ecrire(List<DemandeAdhesion> l) {
    unawaited(StorageService.setString(_cle, jsonEncode([for (final d in l) d.versJson()])));
    revision.value++;
  }

  static List<DemandeAdhesion> pour(String groupId) => [
        for (final d in _toutes())
          if (d.groupId == groupId) d,
      ];

  static void ajouter(String groupId, String peerId) {
    final l = _toutes().where((d) => !(d.groupId == groupId && d.peerId == peerId)).toList()
      ..add(DemandeAdhesion(groupId: groupId, peerId: peerId, quand: DateTime.now()));
    _ecrire(l);
  }

  static void retirer(String groupId, String peerId) {
    _ecrire(_toutes().where((d) => !(d.groupId == groupId && d.peerId == peerId)).toList());
  }
}
