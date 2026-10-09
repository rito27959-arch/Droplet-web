// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Client pour le serveur directory .onion.
//
// Permet d'enregistrer cet appareil, de chercher des contacts, et de
// se désinscrire de l'annuaire.
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'etat_internet.dart';
import 'package:http/http.dart' as http;

/// Entrée d'un contact dans l'annuaire.
class DirectoryContact {
  const DirectoryContact({
    required this.peerId,
    required this.pseudo,
    required this.onionAddress,
    required this.publicKey,
  });

  final String peerId;
  final String pseudo;
  final String onionAddress;
  final String publicKey;

  factory DirectoryContact.fromJson(Map<String, dynamic> json) {
    return DirectoryContact(
      peerId: json['peerId'] as String,
      pseudo: json['pseudo'] as String,
      onionAddress: json['onion'] as String,
      publicKey: json['publicKey'] as String,
    );
  }
}

/// Client pour le serveur directory.
///
/// Peut fonctionner directement (serveur classique) ou via Tor (serveur .onion).
class DirectoryClient {
  DirectoryClient({required this.serverUrl, http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  /// URL du serveur (ex: http://xyz.onion:8080 ou https://droplet-directory.up.railway.app).
  final String serverUrl;

  /// Client HTTP sous-jacent — peut être un TorHttpClient ou un client direct.
  final http.Client _client;

  /// Dépose l'enveloppe de liaison sur le canal qu'affiche le code QR de
  /// Droplet Web. Le navigateur, qui attend sur ce canal, la relève et la
  /// déchiffre : il connaît alors notre identité et devient un appareil
  /// associé. L'annuaire ne voit qu'un blob chiffré.
  Future<bool> publierLiaison({required String canal, required Map<String, dynamic> enveloppe}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$serverUrl/liaison/${Uri.encodeComponent(canal)}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(enveloppe),
          )
          .timeout(const Duration(seconds: 12));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Annuaire : liaison impossible ($e)');
      return false;
    }
  }

  /// Retire un appareil associé : l'annuaire cesse de le servir et la
  /// boîte aux lettres supprime sa file.
  Future<bool> revoquerAppareil({required String peerId, required String appareilId}) async {
    try {
      final response = await _client
          .delete(Uri.parse('$serverUrl/appareils/${Uri.encodeComponent(peerId)}/${Uri.encodeComponent(appareilId)}'))
          .timeout(const Duration(seconds: 12));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Annuaire : révocation impossible ($e)');
      return false;
    }
  }

  /// Enregistre cet appareil dans l'annuaire.
  ///
  /// [fcmToken] est optionnel : un appareil sans Firebase (ou qui n'a
  /// pas encore obtenu de jeton) s'enregistre quand même — il restera
  /// joignable par sondage de la mailbox, juste pas réveillable par
  /// notification push. Voir `push_notification_service.dart`.
  Future<bool> register({
    required String peerId,
    required String pseudo,
    required String onionAddress,
    required String publicKey,
    String? fcmToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$serverUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'peerId': peerId,
          'pseudo': pseudo,
          'onion': onionAddress,
          'publicKey': publicKey,
          if (fcmToken != null) 'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        // Une vraie réponse de l'annuaire prouve qu'Internet marche.
        EtatInternet.signalerReussite();
        debugPrint('[Directory] Enregistré: $pseudo');
        return true;
      }

      debugPrint('[Directory] Erreur enregistrement: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[Directory] Erreur enregistrement: $e');
      return false;
    }
  }

  /// Se désinscrit de l'annuaire.
  /// Le battement de présence : « j'étais joignable à l'instant ».
  ///
  /// Un seul appel, quelques octets, et le serveur note l'heure. Il ne
  /// transporte aucun contenu : la seule chose qu'il dit, c'est qu'un
  /// identifiant était en ligne. Si le serveur ne connaît pas encore
  /// `/presence`, l'appel échoue en silence et l'app continue comme avant.
  Future<bool> battement(String peerId) async {
    try {
      final response = await _client.post(
        Uri.parse('$serverUrl/presence'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peerId': peerId}),
      );
      if (response.statusCode == 200) {
        EtatInternet.signalerReussite();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// L'heure du dernier battement de chacun de ces pairs.
  ///
  /// Les identifiants demandés partent en clair vers l'annuaire : c'est le
  /// prix de la présence, et c'est pourquoi elle ne part qu'au premier plan
  /// et seulement si le mode en ligne est accepté.
  Future<Map<String, DateTime>> presences(List<String> peerIds) async {
    if (peerIds.isEmpty) return const {};
    try {
      final response = await _client.get(
        Uri.parse('$serverUrl/presence?ids=${peerIds.take(40).join(',')}'),
      );
      if (response.statusCode != 200) return const {};
      final brut = jsonDecode(response.body);
      if (brut is! Map) return const {};
      final sortie = <String, DateTime>{};
      brut.forEach((cle, valeur) {
        if (cle is String && valeur is num) {
          sortie[cle] = DateTime.fromMillisecondsSinceEpoch(valeur.toInt());
        }
      });
      EtatInternet.signalerReussite();
      return sortie;
    } catch (_) {
      return const {};
    }
  }

  Future<bool> unregister(String peerId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$serverUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peerId': peerId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[Directory] Erreur désinscription: $e');
      return false;
    }
  }

  /// Cherche des contacts par pseudo.
  Future<List<DirectoryContact>> search(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$serverUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        // Une vraie réponse de l'annuaire prouve qu'Internet marche.
        EtatInternet.signalerReussite();
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>;
        return results
            .map((e) => DirectoryContact.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[Directory] Erreur recherche: $e');
      return [];
    }
  }

  /// Signale un contact au serveur annuaire.
  ///
  /// ⚠️ CE QUI PART, ET CE QUI NE PART JAMAIS. [peerId] désigne la
  /// personne signalée (un identifiant technique, pas son pseudo) et
  /// [reason] un code court parmi une liste fermée (voir
  /// `_MotifsSignalement` dans `chat_info_screen.dart`) — jamais de
  /// texte libre, jamais un seul message de la conversation. Le serveur
  /// n'a de toute façon jamais eu accès au contenu chiffré de bout en
  /// bout : ce signalement est la seule information qu'il PEUT recevoir
  /// à ce sujet, pas un choix de pudeur qu'on pourrait élargir plus
  /// tard.
  Future<bool> report({required String peerId, required String reason}) async {
    try {
      final response = await _client.post(
        Uri.parse('$serverUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peerId': peerId, 'reason': reason}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[Directory] Erreur signalement: $e');
      return false;
    }
  }

  /// Health check.
  Future<bool> isHealthy() async {
    try {
      final response = await _client.get(Uri.parse('$serverUrl/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Ferme le client HTTP sous-jacent.
  void close() {
    _client.close();
  }
}
