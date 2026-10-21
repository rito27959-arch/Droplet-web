// LE MULTI-APPAREILS — Droplet Web qui reçoit et envoie, téléphone éteint.
//
// Jusqu'ici, Droplet Web passait TOUT par le téléphone : éteint, plus rien.
// Désormais, l'app de chaque contact (version multi-appareils) dépose aussi
// une copie de ses messages pour chacun de nos appareils liés, chiffrée pour
// la clé de l'appareil :
//
//   clé = HKDF-SHA256( X25519(clé privée de l'appareil, clé publique du contact),
//                      sel « droplet-mesh », info « droplet-1to1-v1 » )
//   enveloppe : {c, n, k (clé de l'expéditeur), m (identifiant), r, md: 1,
//                pour (le compte destinataire), compte (si l'expéditeur est
//                lui-même un appareil lié)}
//
// Et Droplet Web écrit LUI-MÊME aux contacts dont l'app sait le lire (`md`
// dans l'annuaire) : au nom du compte (`compte`), signé avec la clé de
// l'appareil, que l'annuaire rattache au compte (seul le téléphone peut y
// ajouter un appareil). Le téléphone en est prévenu (`envoye`) : il inscrit
// le message dans son historique dès qu'il se rallume.
//
// Les messages arrivent souvent deux fois (copie directe, puis copie du
// téléphone) : ils portent le même identifiant, le dépôt les fusionne.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'canal_telephone.dart';

typedef InfosContact = ({bool md, String? cle, String? pseudo, List<({String id, String cle})> appareils});

class MultiAppareils {
  MultiAppareils({required this.canal, required this.annuaire});

  final CanalTelephone canal;
  final String annuaire;

  final Map<String, (DateTime, InfosContact)> _infos = {};
  final Map<String, SecretKey> _cles = {};
  String? _maCle;

  static List<int> _b64(String s) => base64.decode(base64.normalize(s.replaceAll('-', '+').replaceAll('_', '/')));

  static bool memeCle(String a, String b) {
    try {
      return base64.encode(_b64(a)) == base64.encode(_b64(b));
    } catch (_) {
      return false;
    }
  }

  /// Ma clé publique d'appareil, en base64 standard (le champ `k`).
  Future<String> maCle() async {
    if (_maCle != null) return _maCle!;
    final paire = await X25519().newKeyPairFromSeed(canal.graine);
    return _maCle = base64.encode((await paire.extractPublicKey()).bytes);
  }

  /// Ce que l'annuaire dit d'un contact : son app sait-elle lire un appareil
  /// lié (`md`), sa clé, et ses propres appareils liés. Gardé 10 minutes.
  Future<InfosContact?> infos(String peerId, {bool forcer = false}) async {
    final deja = _infos[peerId];
    if (!forcer && deja != null && DateTime.now().difference(deja.$1) < const Duration(minutes: 10)) return deja.$2;
    try {
      final r = await requete('GET', '$annuaire/appareils/${Uri.encodeComponent(peerId)}/liste', delai: const Duration(seconds: 12));
      if (!r.ok) return deja?.$2;
      final j = jsonDecode(r.corps) as Map;
      final i = (
        md: j['md'] == true,
        cle: j['cle'] as String?,
        pseudo: j['pseudo'] as String?,
        appareils: [
          for (final a in (j['appareils'] as List? ?? const []))
            if (a is Map && a['id'] is String && a['cle'] is String) (id: a['id'] as String, cle: a['cle'] as String),
        ],
      );
      _infos[peerId] = (DateTime.now(), i);
      return i;
    } catch (_) {
      return deja?.$2;
    }
  }

  Future<SecretKey> _cle(String clePublique) async {
    final c = base64.encode(_b64(clePublique));
    final deja = _cles[c];
    if (deja != null) return deja;
    final partage = await X25519().sharedSecretKey(
      keyPair: await X25519().newKeyPairFromSeed(canal.graine),
      remotePublicKey: SimplePublicKey(_b64(c), type: KeyPairType.x25519),
    );
    final k = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
      secretKey: partage,
      info: utf8.encode('droplet-1to1-v1'),
      nonce: utf8.encode('droplet-mesh'),
    );
    return _cles[c] = k;
  }

  Future<({String c, String n})> _chiffrer(String clePublique, String texte) async {
    final b = await AesGcm.with256bits().encrypt(utf8.encode(texte), secretKey: await _cle(clePublique));
    return (c: base64.encode([...b.cipherText, ...b.mac.bytes]), n: base64.encode(b.nonce));
  }

  Future<String?> _dechiffrer(String clePublique, String c, String n) async {
    final o = await _dechiffrerOctets(clePublique, c, n);
    if (o == null) return null;
    try {
      return utf8.decode(o);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _dechiffrerOctets(String clePublique, String c, String n) async {
    try {
      final o = _b64(c);
      if (o.length < 17) return null;
      final clair = await AesGcm.with256bits().decrypt(
        SecretBox(o.sublist(0, o.length - 16), nonce: _b64(n), mac: Mac(o.sublist(o.length - 16))),
        secretKey: await _cle(clePublique),
      );
      return Uint8List.fromList(clair);
    } catch (_) {
      return null;
    }
  }

  Future<({String c, String n})> _chiffrerOctets(String clePublique, List<int> octets) async {
    final b = await AesGcm.with256bits().encrypt(octets, secretKey: await _cle(clePublique));
    return (c: base64.encode([...b.cipherText, ...b.mac.bytes]), n: base64.encode(b.nonce));
  }

  // ── L'enveloppe d'un fichier (même format que l'app) ───────────────
  //   [longueur du nom sur 2 octets][nom][longueur du type sur 1 octet]
  //   [type, avec « ;lg=<légende en base64url> »][octets du fichier]

  static Uint8List enveloppe(String nom, String mime, Uint8List octets, String? legende) {
    var type = mime;
    var texte = legende?.trim() ?? '';
    // Le type tient sur 255 octets : une légende trop longue est raccourcie.
    while (texte.isNotEmpty) {
      final t = '$mime;lg=${base64Url.encode(utf8.encode(texte))}';
      if (utf8.encode(t).length <= 255) {
        type = t;
        break;
      }
      texte = texte.substring(0, texte.length - 10 < 0 ? 0 : texte.length - 10);
    }
    final n = utf8.encode(nom.length > 200 ? nom.substring(0, 200) : nom);
    final m = utf8.encode(type);
    return Uint8List.fromList([(n.length >> 8) & 0xFF, n.length & 0xFF, ...n, m.length & 0xFF, ...m, ...octets]);
  }

  static ({String nom, String mime, String? legende, Uint8List octets})? ouvrirEnveloppe(Uint8List o) {
    try {
      if (o.length < 3) return null;
      final ln = (o[0] << 8) | o[1];
      if (o.length < 3 + ln) return null;
      final nom = utf8.decode(o.sublist(2, 2 + ln));
      final lm = o[2 + ln];
      final debut = 3 + ln;
      if (o.length < debut + lm) return null;
      var mime = utf8.decode(o.sublist(debut, debut + lm));
      String? legende;
      final i = mime.indexOf(';lg=');
      if (i >= 0) {
        try {
          legende = utf8.decode(base64Url.decode(base64Url.normalize(mime.substring(i + 4)))).trim();
        } catch (_) {}
        mime = mime.substring(0, i);
      }
      return (nom: nom, mime: mime, legende: legende, octets: Uint8List.sublistView(o, debut + lm));
    } catch (_) {
      return null;
    }
  }

  /// Les morceaux de fichiers en cours d'arrivée : auteur|fichier → morceaux.
  final Map<String, (DateTime, List<Uint8List?>)> _morceaux = {};

  // ── Recevoir ───────────────────────────────────────────────────────

  /// Une copie déposée pour ce navigateur par un contact (ou par l'appareil
  /// lié d'un contact). Rend un lot au format du téléphone, ou `null`.
  Future<Map<String, dynamic>?> recevoir(String de, Map<String, dynamic> p, DateTime quand) async {
    if (p['md'] != 1 || p['pour'] != canal.peerId) return null;
    final k = p['k'] as String?;
    final c = p['c'] as String?;
    final n = p['n'] as String?;
    if (k == null || c == null || n == null) return null;
    // Un accusé « distribué » / « lu » du contact : les coches avancent ici,
    // même téléphone éteint.
    if (p['rc'] == 1) {
      final clair = await _dechiffrer(k, c, n);
      if (clair == null) return null;
      final a = jsonDecode(clair);
      if (a is! Map || a['ids'] is! List) return null;
      return {
        'v': 1,
        'accuses': {
          'statut': a['t'] == 'lu' ? 'lu' : 'recu',
          'ids': (a['ids'] as List).whereType<String>().take(500).toList(),
        },
      };
    }
    final id = p['m'] as String?;
    if (id == null || id.isEmpty) return null;
    // L'auteur : le compte au nom duquel écrit un appareil lié, sinon le
    // déposant lui-même (la boîte a vérifié sa signature).
    var auteur = de;
    final compte = p['compte'];
    if (compte is String && compte.isNotEmpty) {
      bool rattache(InfosContact? i) => i != null && i.appareils.any((a) => a.id == de && memeCle(a.cle, k));
      if (!rattache(await infos(compte)) && !rattache(await infos(compte, forcer: true))) return null;
      auteur = compte;
    }
    if (auteur == canal.peerId) return null;
    final d = 'p:$auteur';
    // Une photo, un vocal, une vidéo, un document : en morceaux.
    if (p['f'] == 2) {
      final fichier = p['id'] as String? ?? '';
      final i = (p['i'] as num?)?.toInt() ?? -1;
      final t = (p['t'] as num?)?.toInt() ?? 0;
      if (fichier.isEmpty || t <= 0 || t > 100 || i < 0 || i >= t) return null;
      final morceau = await _dechiffrerOctets(k, c, n);
      if (morceau == null) return null;
      _morceaux.removeWhere((_, v) => DateTime.now().difference(v.$1) > const Duration(minutes: 30));
      final cle = '$auteur|$fichier';
      final liste = _morceaux.putIfAbsent(cle, () => (DateTime.now(), List<Uint8List?>.filled(t, null))).$2;
      if (liste.length != t) return null;
      liste[i] = morceau;
      if (liste.any((m) => m == null)) return null;
      _morceaux.remove(cle);
      final tout = BytesBuilder(copy: false);
      for (final m in liste) {
        tout.add(m!);
      }
      final e = ouvrirEnveloppe(tout.takeBytes());
      if (e == null) return null;
      final pseudoF = (await infos(auteur))?.pseudo;
      return {
        'v': 1,
        if (pseudoF != null && pseudoF.isNotEmpty) 'contacts': [
          {'id': auteur, 'pseudo': pseudoF},
        ],
        'discussions': [
          {'id': d, 'type': 'directe', 'titre': '', 'membres': [auteur]},
        ],
        'messages': [
          {
            'id': id,
            'd': d,
            'a': auteur,
            'texte': e.legende ?? '',
            'date': quand.toUtc().toIso8601String(),
            'f': {'nom': e.nom, 'mime': e.mime, 'taille': e.octets.length},
            // Les octets, déjà là : pas besoin de les demander au téléphone.
            '_octets': e.octets,
          },
        ],
      };
    }
    final texte = await _dechiffrer(k, c, n);
    if (texte == null) return null;
    final pseudo = (await infos(auteur))?.pseudo;
    return {
      'v': 1,
      if (pseudo != null && pseudo.isNotEmpty) 'contacts': [
        {'id': auteur, 'pseudo': pseudo},
      ],
      'discussions': [
        {'id': d, 'type': 'directe', 'titre': '', 'membres': [auteur]},
      ],
      'messages': [
        {'id': id, 'd': d, 'a': auteur, 'texte': texte, 'date': quand.toUtc().toIso8601String(), 'r': ?p['r']},
      ],
    };
  }

  // ── Envoyer ────────────────────────────────────────────────────────

  /// Envoie une pièce jointe à [contact] directement, en morceaux. `false` si
  /// son app ne sait pas encore lire un appareil lié.
  Future<bool> envoyerFichier({
    required String contact,
    required String id,
    required String nom,
    required String mime,
    required Uint8List octets,
    String? legende,
    String? reponseA,
    void Function(double)? progres,
  }) async {
    final i = await infos(contact);
    final cleContact = i?.cle;
    if (i == null || !i.md || cleContact == null) return false;
    final moi = await maCle();
    final env = enveloppe(nom, mime, octets, legende);
    const taille = 192 * 1024;
    final morceaux = [for (var x = 0; x < env.length; x += taille) env.sublist(x, x + taille > env.length ? env.length : x + taille)];
    final cibles = <(String, String, String?)>[(contact, cleContact, null), for (final a in i.appareils.take(4)) (a.id, a.cle, contact)];
    var fait = 0;
    final total = morceaux.length * cibles.length;
    for (final (cible, cle, pour) in cibles) {
      for (var x = 0; x < morceaux.length; x++) {
        final ch = await _chiffrerOctets(cle, morceaux[x]);
        try {
          await canal.deposer(cible, {
            'c': ch.c,
            'n': ch.n,
            'k': moi,
            'f': 2,
            'id': id,
            'm': id,
            'i': x,
            't': morceaux.length,
            'md': 1,
            'compte': canal.peerId,
            'pour': ?pour,
            'r': ?reponseA,
          });
        } catch (e) {
          if (pour == null) rethrow; // le contact lui-même : c'est un échec
        }
        progres?.call(++fait / total);
      }
    }
    return true;
  }

  /// Écrit à [contact] directement, sans le téléphone. Rend `false` si son
  /// app ne sait pas encore lire un appareil lié (il faut alors passer par
  /// le téléphone).
  Future<bool> envoyer({required String contact, required String id, required String texte, String? reponseA}) async {
    final i = await infos(contact);
    final cleContact = i?.cle;
    if (i == null || !i.md || cleContact == null) return false;
    final moi = await maCle();
    Map<String, dynamic> enveloppe(({String c, String n}) x, {String? pour}) => {
          'c': x.c,
          'n': x.n,
          'k': moi,
          'm': id,
          'r': ?reponseA,
          'md': 1,
          'compte': canal.peerId,
          'pour': ?pour,
        };
    // Au téléphone du contact (toujours), puis à ses propres appareils liés.
    await canal.deposer(contact, enveloppe(await _chiffrer(cleContact, texte)));
    for (final a in i.appareils.take(4)) {
      try {
        await canal.deposer(a.id, enveloppe(await _chiffrer(a.cle, texte), pour: contact));
      } catch (_) {}
    }
    // Mon téléphone l'inscrira dans son historique à son retour.
    try {
      await canal.demander({
        't': 'envoye',
        'd': 'p:$contact',
        'id': id,
        'texte': texte,
        'date': DateTime.now().millisecondsSinceEpoch,
        'r': ?reponseA,
      });
    } catch (_) {}
    return true;
  }
}
