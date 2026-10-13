// ============================================================================
// LA SIGNATURE DES REQUÊTES — prouver aux serveurs Droplet que c'est bien
// moi, sans jamais leur donner ma clé.
// ----------------------------------------------------------------------------
// Le téléphone et les serveurs calculent le même secret à partir de nos
// deux clés X25519 (la mienne privée + leur publique d'un côté, leur privée
// + ma publique de l'autre). Chaque requête sensible porte alors :
//
//   X-Droplet-Id     mon identifiant
//   X-Droplet-Ts     l'heure, en secondes
//   X-Droplet-Nonce  16 octets aléatoires, neufs à chaque requête
//   X-Droplet-Sig    HMAC-SHA256(secret, MÉTHODE \n chemin \n heure \n nonce
//                                       \n sha256-hex(corps))
//
// Ce que ça empêche : que quelqu'un relève ou efface mes messages en
// attente, s'inscrive à ma place dans l'annuaire, entre dans ma boîte
// d'appel pour intercepter mes appels, ou dépose des messages en mon nom.
// Dès la première requête signée, les serveurs refusent pour toujours toute
// requête NON signée à mon nom.
//
// La clé publique des serveurs est écrite ici, en dur : un faux serveur ne
// peut pas se faire passer pour le vrai.
// ============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as c;

import 'crypto_service.dart';

/// La clé publique X25519 des serveurs Droplet (annuaire, boîte, appels).
const String kCleServeur = 'neYh3XycaSQiYriTFKq0auqa6gdcvfVkhfP0Ocg9unI=';

class SignatureServeur {
  SignatureServeur._();

  static List<int>? _secret;
  static int _revision = -1;
  static final _hasard = Random.secure();

  static Future<List<int>?> _cle() async {
    if (_revision != CryptoService.revisionIdentite) {
      _secret = null;
      _revision = CryptoService.revisionIdentite;
    }
    return _secret ??= await CryptoService.cleAuthServeur(base64Decode(kCleServeur));
  }

  /// À appeler si l'identité change (restauration d'une sauvegarde).
  static void oublier() => _secret = null;

  /// Les en-têtes à joindre à une requête HTTP. Vide si l'identité n'est
  /// pas encore prête : la requête part alors sans signature, comme avant.
  static Future<Map<String, String>> entetes({
    required String peerId,
    required String methode,
    required Uri adresse,
    List<int> corps = const [],
  }) async {
    final s = await signer(peerId: peerId, methode: methode, chemin: adresse.path, corps: corps);
    if (s == null) return const {};
    return {
      'x-droplet-id': peerId,
      'x-droplet-ts': s.ts,
      'x-droplet-nonce': s.nonce,
      'x-droplet-sig': s.sig,
    };
  }

  /// La signature seule (pour le message `join` du serveur d'appels).
  static Future<({String ts, String nonce, String sig})?> signer({
    required String peerId,
    required String methode,
    required String chemin,
    List<int> corps = const [],
  }) async {
    try {
      final k = await _cle();
      if (k == null || peerId.isEmpty) return null;
      final ts = '${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}';
      final nonce = base64Url.encode(List<int>.generate(16, (_) => _hasard.nextInt(256))).replaceAll('=', '');
      final canon = '${methode.toUpperCase()}\n$chemin\n$ts\n$nonce\n${c.sha256.convert(corps)}';
      final sig = base64Url.encode(c.Hmac(c.sha256, k).convert(utf8.encode(canon)).bytes).replaceAll('=', '');
      return (ts: ts, nonce: nonce, sig: sig);
    } catch (_) {
      return null;
    }
  }
}
