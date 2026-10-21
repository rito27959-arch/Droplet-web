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
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  // -- L'horloge -------------------------------------------------------------
  //
  // Les serveurs refusent une signature datée de plus de 5 minutes d'écart
  // (sinon une requête interceptée pourrait être rejouée plus tard). Un
  // téléphone dont l'horloge est réglée à la main, ou qui a dérivé, voyait
  // donc TOUT refusé : plus un message, plus un appel par Internet, sans
  // un mot d'explication. On lit l'heure des serveurs dans chaque réponse
  // et on signe avec elle : l'horloge du téléphone n'a plus d'importance.

  /// Écart serveur − téléphone, en secondes.
  static int decalage = 0;

  /// La dernière raison de refus donnée par un serveur (`heure`,
  /// `signature`, `inconnu`, `requise`…), null quand tout passe.
  static final ValueNotifier<String?> dernierRefus = ValueNotifier<String?>(null);

  /// L'heure, en secondes, telle que les serveurs la voient.
  static int heureServeur() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + decalage;

  /// Recale l'horloge sur une réponse d'un serveur Droplet, et note la
  /// raison d'un éventuel refus.
  static void noter(http.BaseResponse r) {
    final local = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    int? distant = int.tryParse(r.headers['x-droplet-heure'] ?? '');
    if (distant == null) {
      final date = r.headers['date'];
      if (date != null) {
        try {
          distant = HttpDateLecture.lire(date).millisecondsSinceEpoch ~/ 1000;
        } catch (_) {}
      }
    }
    if (distant != null) {
      final ecart = distant - local;
      // En deçà de 30 s, le bruit du réseau ; inutile de bouger.
      if ((ecart - decalage).abs() > 30) {
        decalage = ecart;
        debugPrint('[Signature] horloge recalée : ${ecart}s d\'écart avec les serveurs');
      }
    }
    if (r.statusCode == 401) {
      final raison = r.headers['x-droplet-raison'] ?? 'inconnue';
      dernierRefus.value = raison;
      debugPrint('[Signature] refusée par ${r.request?.url.host} : $raison');
    } else if (r.statusCode < 400) {
      dernierRefus.value = null;
    }
  }

  /// Envoie une requête signée ; si le serveur la refuse pour une question
  /// d'heure, recale l'horloge et la renvoie une fois, signée à nouveau
  /// (une signature ne sert qu'une fois : on ne peut pas renvoyer l'ancienne).
  static Future<http.Response> envoyer({
    required String peerId,
    required String methode,
    required Uri adresse,
    List<int> corps = const [],
    required Future<http.Response> Function(Map<String, String> entetes) requete,
  }) async {
    Future<http.Response> une() async {
      final r = await requete(await entetes(peerId: peerId, methode: methode, adresse: adresse, corps: corps));
      noter(r);
      return r;
    }

    final avant = decalage;
    final r = await une();
    if (r.statusCode == 401 && (r.headers['x-droplet-raison'] == 'heure' || decalage != avant)) {
      return une();
    }
    return r;
  }

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
      final ts = '${heureServeur()}';
      final nonce = base64Url.encode(List<int>.generate(16, (_) => _hasard.nextInt(256))).replaceAll('=', '');
      final canon = '${methode.toUpperCase()}\n$chemin\n$ts\n$nonce\n${c.sha256.convert(corps)}';
      final sig = base64Url.encode(c.Hmac(c.sha256, k).convert(utf8.encode(canon)).bytes).replaceAll('=', '');
      return (ts: ts, nonce: nonce, sig: sig);
    } catch (_) {
      return null;
    }
  }
}

/// Lecture d'une date HTTP (« Tue, 20 Oct 2026 08:05:57 GMT »), sans
/// dépendre de `dart:io` (le même code sert sur le web).
class HttpDateLecture {
  static const _mois = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static DateTime lire(String s) {
    final m = RegExp(r'(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})').firstMatch(s);
    if (m == null) throw FormatException(s);
    final mois = _mois.indexOf(m.group(2)!) + 1;
    if (mois == 0) throw FormatException(s);
    return DateTime.utc(int.parse(m.group(3)!), mois, int.parse(m.group(1)!),
        int.parse(m.group(4)!), int.parse(m.group(5)!), int.parse(m.group(6)!));
  }
}
