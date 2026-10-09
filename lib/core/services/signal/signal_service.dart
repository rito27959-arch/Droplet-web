// ============================================================================
// LE PROTOCOLE SIGNAL DANS DROPLET — messages à deux.
// ----------------------------------------------------------------------------
// Avant : chaque paire de personnes partageait UNE clé fixe, tirée de leurs
// deux clés d'identité. Qui volait cette clé un jour pouvait relire tous les
// messages passés et futurs de la conversation.
//
// Avec Signal (le protocole de Signal et de WhatsApp) :
//   • une conversation démarre par un échange de clés (pré-clés publiées) ;
//   • les clés changent à CHAQUE message (« double ratchet ») : une clé volée
//     ne déchiffre ni les messages d'avant (confidentialité persistante), ni
//     ceux d'après une fois que la conversation a continué (auto-guérison).
//
// ── Compatibilité ─────────────────────────────────────────────────────────
//
// Un téléphone qui n'a pas encore la mise à jour ne sait pas lire Signal. On
// n'utilise donc Signal qu'avec quelqu'un qui l'a ANNONCÉ (champ `sg` de son
// « hello », ou un message Signal déjà reçu de lui) ; sinon l'ancien
// chiffrement reste utilisé. Voir `MeshRepository._encryptForPeer`.
//
// ── Identité ──────────────────────────────────────────────────────────────
//
// La clé d'identité Signal est DÉRIVÉE de la clé d'identité existante du
// téléphone (coffre sécurisé d'Android). Une restauration de sauvegarde, qui
// restaure cette clé, restaure donc aussi l'identité Signal : l'annuaire,
// qui retient la première identité publiée, continue d'accepter les
// publications. Les sessions, elles, repartent de zéro (comme sur Signal).
//
// ── Sur le fil ────────────────────────────────────────────────────────────
//
// Le texte chiffré prend la place habituelle (`c`), et le champ du nonce (`n`)
// porte `sig3` (message d'ouverture de session) ou `sig2` (message suivant).
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../../config/server_config.dart';
import '../crypto_service.dart';
import '../etat_internet.dart';
import 'signal_magasin.dart';

/// Un message chiffré par Signal, tel qu'il voyage.
class ChiffreSignal {
  const ChiffreSignal(this.contenu, this.type);

  /// Le message sérialisé, en base64.
  final String contenu;

  /// [CiphertextMessage.prekeyType] (ouverture) ou [CiphertextMessage.whisperType].
  final int type;

  static const String prefixe = 'sig';

  /// La valeur posée dans le champ `n` de l'enveloppe.
  String get marqueur => '$prefixe$type';

  /// Le type Signal porté par un champ `n`, ou `null` pour l'ancien chiffrement.
  static int? typeDepuisMarqueur(String? nonce) {
    if (nonce == null || !nonce.startsWith(prefixe)) return null;
    final type = int.tryParse(nonce.substring(prefixe.length));
    return (type == CiphertextMessage.prekeyType || type == CiphertextMessage.whisperType)
        ? type
        : null;
  }
}

class SignalService {
  SignalService._(this._monId, this.magasin, this._stockage);

  static SignalService? _instance;

  /// Le service démarré, ou `null` (pas encore d'identité, ou tests).
  static SignalService? get instance => _instance;

  @visibleForTesting
  static set instance(SignalService? service) => _instance = service;

  final String _monId;
  final MagasinSignal magasin;
  final StockageCleValeur _stockage;

  /// Remplaçable dans les tests.
  @visibleForTesting
  static http.Client Function() fabriqueClient = http.Client.new;

  /// Version annoncée dans le « hello » (`sg.v`).
  static const int version = 1;

  static const int reservePreCles = 100;
  static const int seuilRecharge = 20;
  static const Duration rotationSignee = Duration(days: 7);
  static const Duration conservationSignee = Duration(days: 30);
  static const Duration intervalleVerification = Duration(hours: 6);

  /// Appelé quand un message Signal reçu ne peut pas être déchiffré faute de
  /// session (réinstallation, restauration) : l'expéditeur doit en rouvrir une.
  void Function(String peerId)? surSessionPerdue;

  static const _cleSuivante = 'sig.pk.suivant';
  static const _cleSigneeActive = 'sig.spk.active';
  static const _cleSigneeDate = 'sig.spk.date';
  static const _clePublication = 'sig.publication';
  String _cleCompatible(String peerId) => 'sig.ok.$peerId';
  String _clePaquetMesh(String peerId) => 'sig.paquet.$peerId';

  final Map<String, Future<void>> _verrous = {};

  // ── Démarrage ────────────────────────────────────────────────────────

  static Future<SignalService?> demarrer(
    String monId, {
    StockageCleValeur stockage = const StockageCleValeur(),
    bool Function(String peerId)? identiteVerifiee,
    void Function(String peerId)? surIdentiteChangee,
    List<int>? graine,
  }) async {
    final List<int> octets;
    if (graine != null) {
      octets = graine;
    } else {
      final stockee = await CryptoService.exportPrivateKeySeed();
      if (stockee == null) return null;
      octets = base64Decode(stockee);
    }
    final derivee = await deriverIdentite(octets);
    final magasin = MagasinSignal(
      identite: derivee.identite,
      registrationId: derivee.registrationId,
      stockage: stockage,
      identiteVerifiee: identiteVerifiee,
      surIdentiteChangee: surIdentiteChangee,
    );
    final service = SignalService._(monId, magasin, stockage);
    await service._assurerSigneeLocale();
    return _instance = service;
  }

  /// L'identité Signal et le numéro d'enregistrement, dérivés de la graine
  /// d'identité du téléphone — toujours les mêmes pour la même graine.
  static Future<({IdentityKeyPair identite, int registrationId})> deriverIdentite(
      List<int> graine) async {
    final cle = await Hkdf(hmac: Hmac.sha256(), outputLength: 64).deriveKey(
      secretKey: SecretKey(graine),
      info: utf8.encode('droplet-signal-identite-v1'),
      nonce: utf8.encode('droplet'),
    );
    final octets = await cle.extractBytes();
    final privee = Uint8List.fromList(octets.sublist(0, 32));
    // Clé Curve25519 normalisée (« clamping »), comme la génère le protocole.
    privee[0] &= 248;
    privee[31] &= 127;
    privee[31] |= 64;
    final registrationId = ((octets[32] << 8) | octets[33]) % 16380 + 1;
    return (
      identite: generateIdentityKeyPairFromPrivate(privee),
      registrationId: registrationId,
    );
  }

  /// Une opération à la fois par personne : deux messages chiffrés en même
  /// temps utiliseraient le même état de session et l'un des deux serait
  /// illisible.
  Future<T> _exclusif<T>(String cle, Future<T> Function() operation) {
    final precedente = _verrous[cle] ?? Future<void>.value();
    final resultat = precedente.then((_) => operation());
    final fin = resultat.then<void>((_) {}, onError: (_) {});
    _verrous[cle] = fin;
    unawaited(fin.then((_) {
      if (identical(_verrous[cle], fin)) _verrous.remove(cle);
    }));
    return resultat;
  }

  // ── Pré-clés ─────────────────────────────────────────────────────────

  Future<void> _assurerSigneeLocale() async {
    final active = int.tryParse(_stockage.lire(_cleSigneeActive) ?? '');
    final date = DateTime.tryParse(_stockage.lire(_cleSigneeDate) ?? '');
    final maintenant = DateTime.now();
    final valide = active != null &&
        date != null &&
        maintenant.difference(date) < rotationSignee &&
        await magasin.containsSignedPreKey(active);
    if (valide) return;

    final id = ((active ?? 0) % 0xFFFFFE) + 1;
    await magasin.storeSignedPreKey(id, generateSignedPreKey(magasin.identite, id));
    await _stockage.ecrire(_cleSigneeActive, '$id');
    await _stockage.ecrire(_cleSigneeDate, maintenant.toIso8601String());
    // Les anciennes restent un mois : un message ouvert avec elles peut encore
    // arriver en retard.
    for (final ancienne in await magasin.loadSignedPreKeys()) {
      final age = maintenant.difference(
          DateTime.fromMillisecondsSinceEpoch(ancienne.timestamp.toInt()));
      if (ancienne.id != id && age > conservationSignee) {
        await magasin.removeSignedPreKey(ancienne.id);
      }
    }
  }

  Future<SignedPreKeyRecord> _signeeActive() async {
    await _assurerSigneeLocale();
    return magasin.loadSignedPreKey(int.parse(_stockage.lire(_cleSigneeActive)!));
  }

  Map<String, dynamic>? _etatPublication() {
    try {
      return jsonDecode(_stockage.lire(_clePublication) ?? '') as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<int?> _restantesSurServeur(http.Client client) async {
    final reponse = await client
        .get(Uri.parse('$kDirectoryUrl/cles/$_monId/etat'))
        .timeout(const Duration(seconds: 15));
    if (reponse.statusCode == 404) return 0;
    if (reponse.statusCode != 200) return null;
    EtatInternet.signalerReussite();
    final json = jsonDecode(reponse.body) as Map<String, dynamic>;
    return json['restantes'] as int?;
  }

  /// Publie le paquet de clés sur l'annuaire quand c'est nécessaire : jamais
  /// publié, pré-clé signée renouvelée, ou réserve de pré-clés presque vide.
  Future<bool> publierSiNecessaire({bool forcer = false}) async {
    if (!EtatInternet.disponible() && !forcer) return false;
    final client = fabriqueClient();
    try {
      final signee = await _signeeActive();
      final etat = _etatPublication();
      final signeeChangee = etat == null || etat['signee'] != signee.id;
      var aGenerer = 0;
      if (etat == null) {
        aGenerer = reservePreCles;
      } else {
        final verifie = DateTime.tryParse(etat['verifie'] as String? ?? '');
        if (!forcer &&
            !signeeChangee &&
            verifie != null &&
            DateTime.now().difference(verifie) < intervalleVerification) {
          return true;
        }
        final restantes = await _restantesSurServeur(client);
        if (restantes == null) return false;
        if (restantes < seuilRecharge) aGenerer = reservePreCles - restantes;
        if (aGenerer == 0 && !signeeChangee) {
          await _noterPublication(signee.id);
          return true;
        }
      }

      final debut = int.tryParse(_stockage.lire(_cleSuivante) ?? '') ?? 1;
      final lot = aGenerer > 0 ? generatePreKeys(debut, aGenerer) : const <PreKeyRecord>[];
      for (final p in lot) {
        await magasin.storePreKey(p.id, p);
      }
      await _stockage.ecrire(_cleSuivante, '${((debut + aGenerer - 1) % 0xFFFFFE) + 1}');

      final texte = jsonEncode({
        'peerId': _monId,
        'horodatage': DateTime.now().millisecondsSinceEpoch,
        'identityKey': base64Encode(magasin.identite.getPublicKey().serialize()),
        'registrationId': magasin.registrationId,
        'signedPreKey': {
          'id': signee.id,
          'publicKey': base64Encode(signee.getKeyPair().publicKey.serialize()),
          'signature': base64Encode(signee.signature),
        },
        'preKeys': [
          for (final p in lot)
            {'id': p.id, 'publicKey': base64Encode(p.getKeyPair().publicKey.serialize())},
        ],
      });
      final signature = Curve.calculateSignature(
        magasin.identite.getPrivateKey(),
        Uint8List.fromList(utf8.encode(texte)),
      );
      final reponse = await client
          .put(
            Uri.parse('$kDirectoryUrl/cles/$_monId'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'contenu': texte, 'signature': base64Encode(signature)}),
          )
          .timeout(const Duration(seconds: 20));
      if (reponse.statusCode != 200) {
        debugPrint('[Signal] publication refusée (${reponse.statusCode}): ${reponse.body}');
        return false;
      }
      EtatInternet.signalerReussite();
      await _noterPublication(signee.id);
      debugPrint('[Signal] paquet de clés publié (${lot.length} pré-clés)');
      return true;
    } catch (e) {
      debugPrint('[Signal] publication impossible: $e');
      return false;
    } finally {
      client.close();
    }
  }

  Future<void> _noterPublication(int signeeId) => _stockage.ecrire(
        _clePublication,
        jsonEncode({'signee': signeeId, 'verifie': DateTime.now().toIso8601String()}),
      );

  // ── Paquets échangés par le mesh ─────────────────────────────────────

  /// Le paquet annoncé dans le « hello » : identité et pré-clé signée
  /// (pas de pré-clé à usage unique — Signal s'en passe très bien).
  Future<Map<String, dynamic>> paquetLocal() async {
    final signee = await _signeeActive();
    return {
      'v': version,
      'ik': base64Encode(magasin.identite.getPublicKey().serialize()),
      'rid': magasin.registrationId,
      'sid': signee.id,
      'spk': base64Encode(signee.getKeyPair().publicKey.serialize()),
      'sig': base64Encode(signee.signature),
    };
  }

  /// Retient le paquet annoncé par [peerId] : il sait lire Signal.
  Future<void> retenirPaquet(String peerId, Map<String, dynamic> paquet) async {
    if (peerId == _monId || _paquetDepuisJson(paquet) == null) return;
    await _stockage.ecrire(_clePaquetMesh(peerId), jsonEncode(paquet));
    await marquerCompatible(peerId);
  }

  bool estCompatible(String peerId) => _stockage.lire(_cleCompatible(peerId)) == '1';

  Future<void> marquerCompatible(String peerId) async {
    if (!estCompatible(peerId)) await _stockage.ecrire(_cleCompatible(peerId), '1');
  }

  final Map<String, DateTime> _decouvertes = {};

  /// Un contact trouvé par Internet n'a jamais envoyé de « hello » : on
  /// regarde à l'annuaire s'il a publié des clés Signal (au plus une fois
  /// par demi-heure par personne). Le message suivant utilisera Signal.
  Future<bool> decouvrirEnLigne(String peerId) async {
    if (peerId == _monId || estCompatible(peerId)) return true;
    if (!EtatInternet.disponible()) return false;
    final derniere = _decouvertes[peerId];
    if (derniere != null && DateTime.now().difference(derniere) < const Duration(minutes: 30)) {
      return false;
    }
    _decouvertes[peerId] = DateTime.now();
    final client = fabriqueClient();
    try {
      final reponse = await client
          .get(Uri.parse('$kDirectoryUrl/cles/$peerId/etat'))
          .timeout(const Duration(seconds: 12));
      if (reponse.statusCode != 200) return false;
      await marquerCompatible(peerId);
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  static PreKeyBundle? _paquetDepuisJson(Map<String, dynamic> j) {
    try {
      ECPublicKey cle(Object? b64) => Curve.decodePoint(base64Decode(b64! as String), 0);
      return PreKeyBundle(
        j['rid'] as int,
        1,
        null,
        null,
        j['sid'] as int,
        cle(j['spk']),
        base64Decode(j['sig'] as String),
        IdentityKey(cle(j['ik'])),
      );
    } catch (_) {
      return null;
    }
  }

  static PreKeyBundle? _paquetDepuisServeur(Map<String, dynamic> j) {
    try {
      ECPublicKey cle(Object? b64) => Curve.decodePoint(base64Decode(b64! as String), 0);
      final signee = j['signedPreKey'] as Map<String, dynamic>;
      final unique = j['preKey'] as Map<String, dynamic>?;
      return PreKeyBundle(
        j['registrationId'] as int,
        j['deviceId'] as int? ?? 1,
        unique?['id'] as int?,
        unique == null ? null : cle(unique['publicKey']),
        signee['id'] as int,
        cle(signee['publicKey']),
        base64Decode(signee['signature'] as String),
        IdentityKey(cle(j['identityKey'])),
      );
    } catch (_) {
      return null;
    }
  }

  Future<PreKeyBundle?> _paquetDeLAnnuaire(String peerId) async {
    if (!EtatInternet.disponible()) return null;
    final client = fabriqueClient();
    try {
      final reponse = await client
          .get(Uri.parse('$kDirectoryUrl/cles/$peerId'))
          .timeout(const Duration(seconds: 12));
      if (reponse.statusCode != 200) return null;
      EtatInternet.signalerReussite();
      return _paquetDepuisServeur(jsonDecode(reponse.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  // ── Sessions ─────────────────────────────────────────────────────────

  static SignalProtocolAddress _adresse(String peerId) => SignalProtocolAddress(peerId, 1);

  Future<bool> sessionOuverte(String peerId) => magasin.containsSession(_adresse(peerId));

  Future<bool> _ouvrirSession(String peerId) async {
    final adresse = _adresse(peerId);
    if (await magasin.containsSession(adresse)) return true;
    PreKeyBundle? paquet;
    final mesh = _stockage.lire(_clePaquetMesh(peerId));
    if (mesh != null) {
      try {
        paquet = _paquetDepuisJson(jsonDecode(mesh) as Map<String, dynamic>);
      } catch (_) {}
    }
    paquet ??= await _paquetDeLAnnuaire(peerId);
    if (paquet == null) return false;
    try {
      await SessionBuilder.fromSignalStore(magasin, adresse).processPreKeyBundle(paquet);
      await marquerCompatible(peerId);
      return true;
    } catch (e) {
      debugPrint('[Signal] session impossible avec $peerId: $e');
      return false;
    }
  }

  /// Oublie la session avec [peerId] : la prochaine s'ouvrira à neuf.
  Future<void> oublierSession(String peerId) =>
      _exclusif(peerId, () => magasin.deleteSession(_adresse(peerId)));

  /// Chiffre pour [peerId], ou `null` si Signal n'est pas utilisable avec lui
  /// (il ne l'a pas annoncé, ou aucune session ne peut s'ouvrir) : l'appelant
  /// garde alors l'ancien chiffrement.
  Future<ChiffreSignal?> chiffrer(String peerId, Uint8List clair) {
    if (peerId == _monId || !estCompatible(peerId)) return Future.value();
    return _exclusif(peerId, () async {
      if (!await _ouvrirSession(peerId)) return null;
      try {
        final message = await SessionCipher.fromStore(magasin, _adresse(peerId)).encrypt(clair);
        return ChiffreSignal(base64Encode(message.serialize()), message.getType());
      } catch (e) {
        debugPrint('[Signal] chiffrement impossible pour $peerId: $e');
        return null;
      }
    });
  }

  Future<ChiffreSignal?> chiffrerTexte(String peerId, String texte) =>
      chiffrer(peerId, Uint8List.fromList(utf8.encode(texte)));

  /// Déchiffre un message Signal de [peerId]. `null` si impossible — message
  /// déjà reçu (doublon), altéré, ou session inconnue ; dans ce dernier cas
  /// [surSessionPerdue] est prévenu.
  Future<Uint8List?> dechiffrer(
    String peerId,
    String contenuB64,
    int type, {
    void Function()? siDoublon,
  }) {
    return _exclusif(peerId, () async {
      final cipher = SessionCipher.fromStore(magasin, _adresse(peerId));
      try {
        final octets = base64Decode(contenuB64);
        final clair = type == CiphertextMessage.prekeyType
            ? await cipher.decrypt(PreKeySignalMessage(octets))
            : await cipher.decryptFromSignal(SignalMessage.fromSerialized(octets));
        await marquerCompatible(peerId);
        return clair;
      } on DuplicateMessageException {
        // Le même message arrivé par deux chemins (mesh et Internet).
        siDoublon?.call();
        return null;
      } catch (e) {
        debugPrint('[Signal] déchiffrement impossible ($peerId, type $type): $e');
        if (type == CiphertextMessage.whisperType) surSessionPerdue?.call(peerId);
        return null;
      }
    });
  }

  Future<String?> dechiffrerTexte(
    String peerId,
    String contenuB64,
    int type, {
    void Function()? siDoublon,
  }) async {
    final octets = await dechiffrer(peerId, contenuB64, type, siDoublon: siDoublon);
    if (octets == null) return null;
    try {
      return utf8.decode(octets);
    } catch (_) {
      return null;
    }
  }
}
