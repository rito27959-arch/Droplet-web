// ============================================================================
// L'INVITATION PAR QR — rejoindre un groupe en montrant un écran.
// ----------------------------------------------------------------------------
// Ce que le code porte : l'identifiant du groupe, son nom, qui invite, un
// jeton tiré au hasard et une date de péremption. AUCUNE CLÉ. Les clés du
// groupe continuent d'arriver par le chemin habituel, une fois que
// l'administrateur a accepté la demande.
//
// C'est le point important : photographier l'écran de quelqu'un ne donne
// rien d'autre que le droit de DEMANDER. C'est l'appareil de
// l'administrateur qui vérifie le jeton et ajoute le membre, et lui seul.
//
// Trois verrous : le jeton expire (24 h par défaut), il ne sert qu'un
// nombre limité de fois, et il peut être révoqué d'un geste — un nouveau
// code rend l'ancien inutile.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/services/storage_service.dart';

class InvitationGroupe {
  const InvitationGroupe({
    required this.groupId,
    required this.nom,
    required this.hote,
    required this.jeton,
    required this.expireA,
  });

  final String groupId;
  final String nom;

  /// L'administrateur qui invite : c'est à lui que part la demande.
  final String hote;

  final String jeton;
  final DateTime expireA;

  bool get expiree => DateTime.now().isAfter(expireA);

  /// Le texte porté par le QR et par le lien partagé.
  String get texte => 'droplet://groupe?d=${base64Url.encode(utf8.encode(jsonEncode({
        'g': groupId,
        'n': nom,
        'h': hote,
        'j': jeton,
        'e': expireA.millisecondsSinceEpoch,
      })))}';

  /// Relit un code scanné. `null` si ce n'est pas une invitation de groupe.
  static InvitationGroupe? lire(String brut) {
    const prefixe = 'droplet://groupe?d=';
    if (!brut.startsWith(prefixe)) return null;
    try {
      final json = jsonDecode(
        utf8.decode(base64Url.decode(brut.substring(prefixe.length))),
      ) as Map<String, dynamic>;
      return InvitationGroupe(
        groupId: json['g'] as String,
        nom: (json['n'] as String?) ?? '',
        hote: json['h'] as String,
        jeton: json['j'] as String,
        expireA: DateTime.fromMillisecondsSinceEpoch((json['e'] as num).toInt()),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Les jetons émis par CE téléphone, pour les groupes qu'il administre.
class JetonsInvitation {
  JetonsInvitation._();

  static const String _cle = 'jetons_invitation_groupe';

  /// La durée de vie d'un code. Assez pour une soirée, pas pour un mois.
  static const Duration validite = Duration(hours: 24);

  /// Combien de personnes peuvent entrer avec le même code.
  static const int usagesMax = 20;

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Map<String, Map<String, dynamic>>? _cache;

  static Map<String, Map<String, dynamic>> _tous() {
    final deja = _cache;
    if (deja != null) return deja;
    final map = <String, Map<String, dynamic>>{};
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        (jsonDecode(brut) as Map<String, dynamic>).forEach((id, v) {
          if (v is Map<String, dynamic>) map[id] = v;
        });
      } catch (_) {}
    }
    return _cache = map;
  }

  static void _ecrire(Map<String, Map<String, dynamic>> map) {
    _cache = map;
    unawaited(StorageService.setString(_cle, jsonEncode(map)));
    revision.value++;
  }

  /// Le jeton en cours pour ce groupe, ou un nouveau s'il n'y en a pas (ou
  /// s'il a expiré).
  static InvitationGroupe courant({
    required String groupId,
    required String nom,
    required String moi,
  }) {
    final existant = _tous()[groupId];
    if (existant != null) {
      final invitation = InvitationGroupe(
        groupId: groupId,
        nom: nom,
        hote: moi,
        jeton: existant['jeton'] as String,
        expireA: DateTime.fromMillisecondsSinceEpoch(
          (existant['expireA'] as num).toInt(),
        ),
      );
      if (!invitation.expiree) return invitation;
    }
    return renouveler(groupId: groupId, nom: nom, moi: moi);
  }

  /// Tire un nouveau jeton : l'ancien ne vaut plus rien à la seconde même.
  static InvitationGroupe renouveler({
    required String groupId,
    required String nom,
    required String moi,
  }) {
    final hasard = Random.secure();
    final jeton = base64Url
        .encode(List<int>.generate(18, (_) => hasard.nextInt(256)))
        .replaceAll('=', '');
    final expireA = DateTime.now().add(validite);
    _ecrire({
      ..._tous(),
      groupId: {
        'jeton': jeton,
        'expireA': expireA.millisecondsSinceEpoch,
        'usages': 0,
      },
    });
    return InvitationGroupe(
      groupId: groupId,
      nom: nom,
      hote: moi,
      jeton: jeton,
      expireA: expireA,
    );
  }

  static void revoquer(String groupId) {
    final map = {..._tous()}..remove(groupId);
    _ecrire(map);
  }

  /// Côté administrateur : ce jeton donne-t-il le droit d'entrer ?
  ///
  /// Un jeton inconnu, expiré ou trop utilisé ne dit pas pourquoi il est
  /// refusé — le demandeur n'a pas à apprendre ce qui existe.
  static bool accepter(String groupId, String jeton) {
    final entree = _tous()[groupId];
    if (entree == null) return false;
    if (entree['jeton'] != jeton) return false;
    final expireA = DateTime.fromMillisecondsSinceEpoch(
      (entree['expireA'] as num).toInt(),
    );
    if (DateTime.now().isAfter(expireA)) return false;
    final usages = (entree['usages'] as num?)?.toInt() ?? 0;
    if (usages >= usagesMax) return false;
    _ecrire({
      ..._tous(),
      groupId: {...entree, 'usages': usages + 1},
    });
    return true;
  }
}
