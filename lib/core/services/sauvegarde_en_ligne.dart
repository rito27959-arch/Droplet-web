// ============================================================================
// SAUVEGARDE AUTOMATIQUE EN LIGNE — et restauration sur un nouveau téléphone.
// ----------------------------------------------------------------------------
// Le même coffre que l'export manuel (`BackupService` : identité, contacts,
// groupes, clés de groupe, historique), chiffré sur le téléphone avec le mot
// de passe, puis déposé chaque jour sur l'annuaire Droplet — qui garde les
// sauvegardes sur son disque sans pouvoir les lire (voir
// `droplet_directory/lib/sauvegardes.dart`).
//
// ── Retrouver sa sauvegarde sans rien d'autre que pseudo et mot de passe ──
//
// Sur un téléphone neuf, on n'a ni identifiant ni clé : seulement ce dont on
// se souvient. L'IDENTIFIANT de la sauvegarde et son JETON d'accès sont donc
// dérivés du pseudo et du mot de passe, avec PBKDF2 (lent exprès) et deux sels
// distincts. Le serveur ne voit ni le pseudo ni le mot de passe, et le jeton
// ne sert pas à déchiffrer.
//
// Ne sont PAS sauvegardés : les photos, vidéos et fichiers reçus (seulement
// l'historique des messages), comme pour l'export manuel.
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/server_config.dart';
import 'backup_service.dart';
import 'crypto_service.dart';
import 'etat_internet.dart';
import 'storage_service.dart';

/// Trop d'essais de mot de passe : le serveur bloque pendant une heure.
class SauvegardeTropDEssais implements Exception {
  const SauvegardeTropDEssais();
}

class SauvegardeEnLigne {
  SauvegardeEnLigne._();

  static const _stockageSecurise = FlutterSecureStorage();
  static const _cleMotDePasse = 'sauvegarde_en_ligne_mdp';
  static const cleActive = 'sauvegarde_en_ligne_active';
  static const cleDerniere = 'sauvegarde_en_ligne_derniere';

  /// Une sauvegarde par jour au plus.
  static const intervalle = Duration(hours: 24);

  static const int _iterations = 200000;

  /// Remplaçable dans les tests.
  @visibleForTesting
  static http.Client Function() fabriqueClient = http.Client.new;

  static bool _enCours = false;

  static bool get active => StorageService.getString(cleActive) == 'on';

  static DateTime? get derniere =>
      DateTime.tryParse(StorageService.getString(cleDerniere) ?? '');

  /// L'identifiant de la sauvegarde et son jeton d'accès, dérivés du pseudo
  /// (sans casse ni espaces autour) et du mot de passe.
  static Future<({String id, String jeton})> identifiants({
    required String pseudo,
    required String motDePasse,
    int iterations = _iterations,
  }) async {
    final base = pseudo.trim().toLowerCase();
    Future<String> deriver(String usage) async {
      final cle = await CryptoService.deriveBackupKey(
        motDePasse,
        Uint8List.fromList(utf8.encode('droplet-sauvegarde-$usage|$base')),
        iterations: iterations,
      );
      final octets = await cle.extractBytes();
      return octets.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }

    return (id: await deriver('id'), jeton: await deriver('acces'));
  }

  static Uri _adresse(String id) => Uri.parse('$kDirectoryUrl/sauvegarde/$id');

  /// Active la sauvegarde quotidienne avec [motDePasse] (gardé dans le
  /// stockage sécurisé du téléphone) et sauvegarde tout de suite.
  static Future<bool> activer(String motDePasse) async {
    await _stockageSecurise.write(key: _cleMotDePasse, value: motDePasse);
    await StorageService.setString(cleActive, 'on');
    return sauvegarderMaintenant();
  }

  static Future<void> desactiver() async {
    await StorageService.setString(cleActive, 'off');
    await _stockageSecurise.delete(key: _cleMotDePasse);
  }

  /// Chiffre et dépose la sauvegarde. `false` si impossible pour l'instant.
  static Future<bool> sauvegarderMaintenant() async {
    if (_enCours) return false;
    final utilisateur = StorageService.currentUser;
    final motDePasse = await _stockageSecurise.read(key: _cleMotDePasse);
    if (utilisateur == null || motDePasse == null || motDePasse.isEmpty) return false;
    _enCours = true;
    final client = fabriqueClient();
    try {
      final ids = await identifiants(pseudo: utilisateur.pseudo, motDePasse: motDePasse);
      final enveloppe = await BackupService.creerEnveloppe(
        password: motDePasse,
        includeMessages: true,
      );
      final reponse = await client
          .put(
            _adresse(ids.id),
            headers: {'content-type': 'application/json', 'x-jeton-sauvegarde': ids.jeton},
            body: enveloppe,
          )
          .timeout(const Duration(minutes: 2));
      if (reponse.statusCode != 200) {
        debugPrint('[Sauvegarde] refusée par le serveur (${reponse.statusCode})');
        return false;
      }
      await StorageService.setString(cleDerniere, DateTime.now().toIso8601String());
      debugPrint('[Sauvegarde] en ligne effectuée (${enveloppe.length} octets)');
      return true;
    } catch (e) {
      debugPrint('[Sauvegarde] en ligne impossible: $e');
      return false;
    } finally {
      client.close();
      _enCours = false;
    }
  }

  /// À appeler régulièrement : sauvegarde si c'est activé, qu'Internet
  /// marche et que la dernière date de plus de [intervalle].
  static Future<void> siNecessaire() async {
    if (!active || _enCours || !EtatInternet.disponible()) return;
    final precedente = derniere;
    if (precedente != null && DateTime.now().difference(precedente) < intervalle) return;
    await sauvegarderMaintenant();
  }

  /// Télécharge et déchiffre la sauvegarde de [pseudo]. `null` s'il n'y en a
  /// pas (ou si le mot de passe ne correspond pas — le serveur ne distingue
  /// pas les deux, exprès).
  static Future<BackupContents?> telecharger({
    required String pseudo,
    required String motDePasse,
  }) async {
    final ids = await identifiants(pseudo: pseudo, motDePasse: motDePasse);
    final client = fabriqueClient();
    try {
      final reponse = await client
          .get(_adresse(ids.id), headers: {'x-jeton-sauvegarde': ids.jeton})
          .timeout(const Duration(minutes: 2));
      if (reponse.statusCode == 404) return null;
      if (reponse.statusCode == 429) throw const SauvegardeTropDEssais();
      if (reponse.statusCode != 200) {
        throw StateError('Serveur de sauvegarde : ${reponse.statusCode}');
      }
      return BackupService.lireEnveloppe(reponse.body, password: motDePasse);
    } finally {
      client.close();
    }
  }
}
