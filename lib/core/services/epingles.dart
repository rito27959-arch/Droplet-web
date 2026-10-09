// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES MESSAGES ÉPINGLÉS — l'adresse du rendez-vous, le code du portail, la
// liste des courses : ce qu'on remonte chercher dix fois dans une
// conversation, et qu'on veut retrouver d'un toucher en haut de l'écran.
//
// ── COMME WHATSAPP : TROIS AU PLUS, PARTAGÉS ───────────────────────────
//
// Épingler chez soi épingle aussi chez l'autre (ou chez tout le groupe) :
// l'information est envoyée chiffrée, comme une modification de message
// (voir `MeshRepository.envoyerEpingle`). Trois au plus : au-delà, la
// barre du haut deviendrait une liste qu'on ne lit plus. Le quatrième
// remplace le plus ancien, exactement comme WhatsApp.
//
// Le plus récent passe devant : c'est presque toujours lui qu'on cherche.
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class Epingles {
  Epingles._();

  static const String _prefixe = 'epingles:';

  /// Trois au plus, comme WhatsApp.
  static const int maximum = 3;

  /// Incrémenté à chaque changement : la barre du haut se redessine.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  /// Les messages épinglés de [conversation], LE PLUS RÉCENT EN PREMIER.
  static List<String> lire(String conversation) {
    try {
      final brut = StorageService.getString('$_prefixe$conversation');
      if (brut == null || brut.isEmpty) return const [];
      final liste = json.decode(brut);
      if (liste is! List) return const [];
      return liste.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static bool estEpingle(String conversation, String messageId) =>
      lire(conversation).contains(messageId);

  /// Épingle ou désépingle. Renvoie `false` si rien n'a changé — utile
  /// pour ne pas renvoyer sur le réseau ce qu'on vient d'en recevoir.
  static Future<bool> appliquer(
    String conversation,
    String messageId, {
    required bool epingle,
  }) async {
    final avant = lire(conversation);
    final apres = [...avant]..remove(messageId);
    if (epingle) apres.insert(0, messageId);
    while (apres.length > maximum) {
      apres.removeLast();
    }
    if (listEquals(avant, apres)) return false;
    try {
      if (apres.isEmpty) {
        await StorageService.remove('$_prefixe$conversation');
      } else {
        await StorageService.setString(
          '$_prefixe$conversation',
          json.encode(apres),
        );
      }
    } catch (_) {
      return false;
    }
    revision.value++;
    return true;
  }

  /// Un message supprimé ne reste pas épinglé : la barre pointerait vers
  /// un trou.
  static Future<void> oublier(String conversation, String messageId) =>
      appliquer(conversation, messageId, epingle: false);
}
