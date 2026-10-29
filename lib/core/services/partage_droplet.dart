// ============================================================================
// DROPLET DANS LES AUTRES APPLICATIONS.
// ----------------------------------------------------------------------------
// Le côté Dart de `PartageDroplet.kt` et `FournisseurPartage.kt` :
//
//   • les packs de stickers Droplet dans WhatsApp (contrat officiel de
//     WhatsApp) et dans Telegram (import officiel de Telegram) ;
//   • un sticker seul, en WebP animé, vers n'importe quelle app ;
//   • l'application elle-même, envoyée comme un fichier — par Quick Share,
//     Bluetooth ou une messagerie — pour qu'elle se propage sans réseau.
//
// Les fichiers des stickers (WebP animés 512 × 512 pour WhatsApp, WEBM VP9
// pour Telegram) sont fabriqués à partir du dessin même des stickers (voir
// `test/stickers_export_test.dart` et `outils/stickers_export.py`) et
// rangés dans `assets/stickers_export/`.
// ============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ce que ce téléphone permet, lu une fois par ouverture d'écran.
@immutable
class EtatPartage {
  const EtatPartage({
    this.whatsapp = false,
    this.telegram = false,
    this.apkPartageable = false,
    this.goutteDansWhatsApp = false,
    this.eclatDansWhatsApp = false,
  });

  final bool whatsapp;
  final bool telegram;

  /// Faux quand l'app vient d'une boutique en « APK scindés » : le paquet
  /// seul ne s'installerait pas chez l'autre.
  final bool apkPartageable;
  final bool goutteDansWhatsApp;
  final bool eclatDansWhatsApp;

  bool dansWhatsApp(String lot) => lot == 'eclat' ? eclatDansWhatsApp : goutteDansWhatsApp;
}

class PartageDroplet {
  PartageDroplet._();

  static const MethodChannel _canal = MethodChannel('com.droplet.droplet/partage');

  static bool get _android => !kIsWeb && Platform.isAndroid;

  static Future<EtatPartage> etat() async {
    if (!_android) return const EtatPartage();
    try {
      final m = await _canal.invokeMapMethod<String, Object?>('etat') ?? const {};
      return EtatPartage(
        whatsapp: m['whatsapp'] == true,
        telegram: m['telegram'] == true,
        apkPartageable: m['apkPartageable'] == true,
        goutteDansWhatsApp: m['goutteDansWhatsApp'] == true,
        eclatDansWhatsApp: m['eclatDansWhatsApp'] == true,
      );
    } catch (e) {
      debugPrint('[Partage] état indisponible : $e');
      return const EtatPartage();
    }
  }

  /// Dit au fournisseur natif quels packs il a le droit de servir. Le pack
  /// premium n'est exporté que s'il est débloqué sur ce téléphone.
  static Future<void> debloquer({required bool premium}) async {
    if (!_android) return;
    try {
      await _canal.invokeMethod<bool>('debloquer', {
        'lots': [if (premium) 'eclat'],
      });
    } catch (_) {}
  }

  static Future<bool> ajouterWhatsApp(String lot, String nom) => _appel('ajouterWhatsApp', {'lot': lot, 'nom': nom});

  static Future<bool> importerTelegram(String lot) => _appel('importerTelegram', {'lot': lot});

  static Future<bool> partagerSticker(String lot, String id, {required String titre}) =>
      _appel('partagerSticker', {'lot': lot, 'id': id, 'titre': titre});

  /// Envoie l'APK installé. [texte] accompagne le fichier quand l'app qui
  /// le reçoit sait joindre un message (WhatsApp, Gmail…).
  static Future<bool> partagerApp({required String titre, String texte = ''}) =>
      _appel('partagerApp', {'titre': titre, 'texte': texte});

  static Future<bool> _appel(String methode, Map<String, Object?> args) async {
    if (!_android) return false;
    try {
      return await _canal.invokeMethod<bool>(methode, args) ?? false;
    } catch (e) {
      debugPrint('[Partage] $methode : $e');
      return false;
    }
  }
}
