// LE CANAL AVEC LE TÉLÉPHONE — comment Droplet Web reçoit et envoie.
//
// Le téléphone garde l'identité du compte et les sessions de chiffrement
// avec les contacts. Le navigateur, lui, parle au TÉLÉPHONE, par un canal
// chiffré qui n'est qu'à eux deux (voir `miroir_appareils.dart` dans l'app) :
//
//   clé du canal = HKDF-SHA256( X25519(clé privée du navigateur,
//                                      clé publique du téléphone),
//                               sel « droplet-mesh », info « droplet-appareil-v1 » )
//   AES-256-GCM, nonce de 12 octets, étiquette de 16 octets en fin de chiffré.
//
// Le canal passe par la boîte aux lettres Droplet. Le navigateur y a sa
// propre file, à son identifiant d'appareil ; le téléphone l'a déclarée en
// le liant, avec la clé publique du navigateur. Chaque requête est SIGNÉE
// avec la clé du navigateur (même protocole que l'app, voir `securite.dart`
// côté serveur) : personne d'autre ne peut relever cette file ni écrire en
// son nom.
//
//   relever  : GET    /messages/<appareil>?attendre=20   (attente longue)
//   acquitter: DELETE /messages/<appareil>/<id>
//   demander : POST   /messages  {from: <appareil>, to: <téléphone>,
//                                 payload: {"l":1,"c":…,"n":…}}
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:web/web.dart' as web;

/// La clé publique X25519 des serveurs Droplet (la même que dans l'app).
const String kCleServeur = 'neYh3XycaSQiYriTFKq0auqa6gdcvfVkhfP0Ocg9unI=';

List<int> _b64(String s) {
  final t = s.replaceAll('-', '+').replaceAll('_', '/');
  return base64.decode(base64.normalize(t));
}

String _b64url(List<int> o) => base64Url.encode(o).replaceAll('=', '');

class ReponseHttp {
  ReponseHttp(this.statut, this.corps);
  final int statut;
  final String corps;
  bool get ok => statut >= 200 && statut < 300;
}

/// Une requête HTTP depuis le navigateur.
Future<ReponseHttp> requete(String methode, String url, {Map<String, String> entetes = const {}, String? corps, Duration delai = const Duration(seconds: 30)}) async {
  final h = web.Headers();
  entetes.forEach(h.append);
  final init = web.RequestInit(method: methode, headers: h, cache: 'no-store');
  if (corps != null) init.body = corps.toJS;
  final r = await web.window.fetch(url.toJS, init).toDart.timeout(delai);
  return ReponseHttp(r.status, (await r.text().toDart).toDart);
}

class CanalTelephone {
  CanalTelephone({
    required this.appareil,
    required this.peerId,
    required this.graine,
    required this.cleTelephone,
    required this.boite,
  });

  /// L'identifiant de ce navigateur (sa file dans la boîte).
  final String appareil;

  /// L'identifiant du compte (le téléphone).
  final String peerId;

  /// La clé privée X25519 de ce navigateur (32 octets).
  final List<int> graine;

  /// La clé publique X25519 du téléphone.
  final List<int> cleTelephone;

  /// L'adresse de la boîte aux lettres.
  final String boite;

  final _hasard = Random.secure();
  SimpleKeyPair? _paire;
  List<int>? _cleAuth;
  SecretKey? _cleCanal;

  Future<SimpleKeyPair> _moi() async => _paire ??= await X25519().newKeyPairFromSeed(graine);

  Future<List<int>> _auth() async {
    if (_cleAuth != null) return _cleAuth!;
    final partage = await X25519().sharedSecretKey(
      keyPair: await _moi(),
      remotePublicKey: SimplePublicKey(_b64(kCleServeur), type: KeyPairType.x25519),
    );
    final k = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
      secretKey: partage,
      info: utf8.encode('droplet-auth-v1'),
      nonce: utf8.encode('droplet-mesh'),
    );
    return _cleAuth = await k.extractBytes();
  }

  Future<SecretKey> _canal() async {
    if (_cleCanal != null) return _cleCanal!;
    final partage = await X25519().sharedSecretKey(
      keyPair: await _moi(),
      remotePublicKey: SimplePublicKey(cleTelephone, type: KeyPairType.x25519),
    );
    return _cleCanal = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
      secretKey: partage,
      info: utf8.encode('droplet-appareil-v1'),
      nonce: utf8.encode('droplet-mesh'),
    );
  }

  /// Les quatre en-têtes de signature pour cette requête.
  Future<Map<String, String>> _signer(String methode, String chemin, List<int> corps) async {
    final ts = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    final nonce = _b64url(List<int>.generate(16, (_) => _hasard.nextInt(256)));
    final empreinte = (await Sha256().hash(corps)).bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final canon = '${methode.toUpperCase()}\n$chemin\n$ts\n$nonce\n$empreinte';
    final mac = await Hmac.sha256().calculateMac(utf8.encode(canon), secretKey: SecretKey(await _auth()));
    return {
      'x-droplet-id': appareil,
      'x-droplet-ts': ts,
      'x-droplet-nonce': nonce,
      'x-droplet-sig': _b64url(mac.bytes),
    };
  }

  Future<ReponseHttp> _signee(String methode, String chemin, {String? corps, String requeteSuite = '', Duration delai = const Duration(seconds: 30)}) async {
    final octets = corps == null ? const <int>[] : utf8.encode(corps);
    final entetes = await _signer(methode, chemin, octets);
    if (corps != null) entetes['content-type'] = 'application/json';
    return requete(methode, '$boite$chemin$requeteSuite', entetes: entetes, corps: corps, delai: delai);
  }

  /// Relève la file (attente longue de [attendre] secondes). Rend les
  /// lots du téléphone, déjà déchiffrés, et acquitte tout ce qui a été lu.
  Future<List<Map<String, dynamic>>> relever({int attendre = 20}) async {
    final chemin = '/messages/${Uri.encodeComponent(appareil)}';
    final r = await _signee('GET', chemin, requeteSuite: '?attendre=$attendre', delai: Duration(seconds: attendre + 20));
    if (r.statut == 401) throw const AppareilRefuse();
    if (!r.ok) throw StateError('boîte : ${r.statut}');
    final j = jsonDecode(r.corps) as Map<String, dynamic>;
    final lots = <Map<String, dynamic>>[];
    for (final m in (j['messages'] as List? ?? const [])) {
      final message = (m as Map).cast<String, dynamic>();
      final id = message['id'] as String;
      try {
        if (message['from'] == peerId) {
          final p = jsonDecode(message['payload'] as String) as Map<String, dynamic>;
          if (p['w'] == 1) {
            final clair = await _dechiffrer(p['c'] as String, p['n'] as String);
            if (clair != null) lots.add((jsonDecode(clair) as Map).cast<String, dynamic>());
          }
        }
      } catch (_) {
        // Illisible : on l'acquitte quand même, il ne deviendra pas lisible.
      }
      unawaited(_signee('DELETE', '$chemin/${Uri.encodeComponent(id)}').then((_) {}, onError: (_) {}));
    }
    return lots;
  }

  /// Dépose une demande pour le téléphone.
  Future<void> demander(Map<String, dynamic> demande) async {
    final k = await _canal();
    final boiteChiffree = await AesGcm.with256bits().encrypt(utf8.encode(jsonEncode(demande)), secretKey: k);
    final corps = jsonEncode({
      'from': appareil,
      'to': peerId,
      'payload': jsonEncode({
        'l': 1,
        'c': base64.encode([...boiteChiffree.cipherText, ...boiteChiffree.mac.bytes]),
        'n': base64.encode(boiteChiffree.nonce),
      }),
    });
    final r = await _signee('POST', '/messages', corps: corps);
    if (r.statut == 401) throw const AppareilRefuse();
    if (!r.ok) throw StateError('boîte : ${r.statut}');
  }

  Future<String?> _dechiffrer(String c, String n) async {
    try {
      final octets = _b64(c);
      if (octets.length < 17) return null;
      final clair = await AesGcm.with256bits().decrypt(
        SecretBox(octets.sublist(0, octets.length - 16), nonce: _b64(n), mac: Mac(octets.sublist(octets.length - 16))),
        secretKey: await _canal(),
      );
      return utf8.decode(clair);
    } catch (_) {
      return null;
    }
  }
}

/// La boîte refuse la signature de ce navigateur : il a été déconnecté
/// (ou lié avant cette version, sans file à lui).
class AppareilRefuse implements Exception {
  const AppareilRefuse();
}

/// Un compte trouvé dans l'annuaire par son pseudo.
class ResultatRecherche {
  const ResultatRecherche({required this.peerId, required this.pseudo, this.cle});
  final String peerId;
  final String pseudo;
  final String? cle;
}

/// Cherche des comptes Droplet par pseudo (2 lettres au moins).
Future<List<ResultatRecherche>> chercherPseudo(String annuaire, String q) async {
  final r = await requete('GET', '$annuaire/search?q=${Uri.encodeQueryComponent(q)}', delai: const Duration(seconds: 12));
  if (!r.ok) return const [];
  final j = jsonDecode(r.corps) as Map<String, dynamic>;
  return [
    for (final e in (j['results'] as List? ?? const []))
      if (e is Map && e['peerId'] is String && e['pseudo'] is String)
        ResultatRecherche(peerId: e['peerId'] as String, pseudo: e['pseudo'] as String, cle: e['publicKey'] as String?),
  ];
}
