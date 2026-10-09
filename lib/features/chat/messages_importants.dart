// ============================================================================
// LES MESSAGES IMPORTANTS — une étoile pour retrouver, plus tard.
// ----------------------------------------------------------------------------
// Tout est local : marquer un message ne prévient personne et ne sort pas du
// téléphone. On garde une copie du message au moment où on l'étoile, pour
// que la liste reste lisible même si la discussion a été vidée depuis.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/services/storage_service.dart';

/// Ce qu'on retient d'un message étoilé.
class MessageImportant {
  const MessageImportant({
    required this.id,
    required this.contenu,
    required this.type,
    required this.horodatage,
    required this.deMoi,
    this.auteur,
    this.peerId,
    this.groupId,
    this.nomFichier,
  });

  final String id;
  final String contenu;
  final String type;
  final int horodatage;
  final bool deMoi;
  final String? auteur;
  final String? peerId;
  final String? groupId;
  final String? nomFichier;

  DateTime get quand => DateTime.fromMillisecondsSinceEpoch(horodatage);

  /// Où retourner quand on touche la ligne.
  String get route => groupId != null ? '/group/$groupId' : '/chat/$peerId';

  Map<String, Object?> versJson() => {
        'id': id,
        'c': contenu,
        't': type,
        'h': horodatage,
        'm': deMoi,
        'a': auteur,
        'p': peerId,
        'g': groupId,
        'f': nomFichier,
      };

  static MessageImportant? depuisJson(Object? brut) {
    if (brut is! Map) return null;
    final id = brut['id'];
    if (id is! String) return null;
    return MessageImportant(
      id: id,
      contenu: brut['c'] as String? ?? '',
      type: brut['t'] as String? ?? 'text',
      horodatage: (brut['h'] as num?)?.toInt() ?? 0,
      deMoi: brut['m'] == true,
      auteur: brut['a'] as String?,
      peerId: brut['p'] as String?,
      groupId: brut['g'] as String?,
      nomFichier: brut['f'] as String?,
    );
  }
}

class MessagesImportants {
  MessagesImportants._();

  static const String _cle = 'messages_importants';

  /// Change à chaque étoile posée ou retirée : les bulles et la liste se
  /// redessinent.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static List<MessageImportant>? _cache;

  static List<MessageImportant> tous() {
    final deja = _cache;
    if (deja != null) return deja;
    final liste = <MessageImportant>[];
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        for (final e in jsonDecode(brut) as List) {
          final m = MessageImportant.depuisJson(e);
          if (m != null) liste.add(m);
        }
      } catch (_) {
        // Un stockage abîmé ne doit pas empêcher d'ouvrir l'écran.
      }
    }
    liste.sort((a, b) => b.horodatage.compareTo(a.horodatage));
    return _cache = liste;
  }

  static bool estImportant(String id) => tous().any((m) => m.id == id);

  static void _ecrire(List<MessageImportant> liste) {
    _cache = liste;
    unawaited(
      StorageService.setString(
        _cle,
        jsonEncode([for (final m in liste) m.versJson()]),
      ),
    );
    revision.value++;
  }

  /// Pose ou retire l'étoile. Rend `true` si le message est désormais
  /// important.
  static bool basculer(MessageImportant message) {
    final liste = [...tous()];
    final avant = liste.length;
    liste.removeWhere((m) => m.id == message.id);
    if (liste.length != avant) {
      _ecrire(liste);
      return false;
    }
    liste.insert(0, message);
    liste.sort((a, b) => b.horodatage.compareTo(a.horodatage));
    _ecrire(liste);
    return true;
  }

  static void retirer(String id) {
    final liste = [...tous()]..removeWhere((m) => m.id == id);
    _ecrire(liste);
  }

  static void toutRetirer() => _ecrire(const []);
}
