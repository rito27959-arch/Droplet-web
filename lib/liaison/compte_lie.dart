// LE COMPTE LIÉ — ce que le navigateur apprend quand le téléphone le lie.
//
// Le téléphone dépose sur l'annuaire une enveloppe chiffrée pour CE
// navigateur seul (voir `appareils_lies.dart` dans l'app) :
//
//   {"v":1, "cleTel":"…", "nonce":"…", "chiffre":"…"}
//
// La clé : HKDF-SHA256(X25519(clé privée du navigateur, cleTel),
// info « droplet-lien-v1 », sel « droplet-mesh »), AES-256-GCM, les 16
// derniers octets de `chiffre` étant l'étiquette. Le même calcul que le
// téléphone, de l'autre côté.
//
// Une fois ouverte, l'enveloppe donne l'identité du compte (identifiant,
// pseudo) et l'identifiant attribué à ce navigateur. On la garde dans le
// navigateur ; à chaque ouverture, on demande à l'annuaire si l'appareil
// est toujours lié (le téléphone peut le déconnecter à tout moment).
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:cryptography/cryptography.dart';
import 'package:web/web.dart' as web;

import '../donnees/canal_telephone.dart';
import 'invitation_liaison.dart';

/// L'annuaire Droplet (les routes /liaison et /appareils).
const String kAnnuaire = 'https://droplet-directory-production.up.railway.app';

/// La boîte aux lettres Droplet, si l'enveloppe n'en donne pas.
const String kBoite = 'https://droplet-mailbox-production.up.railway.app';

class CompteLie {
  const CompteLie({
    required this.peerId,
    required this.pseudo,
    required this.appareil,
    required this.nomAppareil,
    required this.lieLe,
    required this.graine,
    required this.cleTelephone,
    this.annuaire = kAnnuaire,
    this.boite = kBoite,
    this.invitation,
  });

  final String peerId;
  final String pseudo;
  final String appareil;
  final String nomAppareil;
  final DateTime lieLe;

  /// La clé privée X25519 de ce navigateur (base64url). Elle ne quitte
  /// jamais le navigateur : c'est elle qui signe ses requêtes et ouvre le
  /// canal avec le téléphone.
  final String graine;

  /// La clé publique X25519 du téléphone (base64url).
  final String cleTelephone;

  final String annuaire;
  final String boite;

  /// Le lien d'invitation du compte (« Inviter par un lien »).
  final String? invitation;

  static const _cle = 'droplet-web:compte';

  Map<String, dynamic> toJson() => {
        'peerId': peerId,
        'pseudo': pseudo,
        'appareil': appareil,
        'nom': nomAppareil,
        'lieLe': lieLe.toIso8601String(),
        'graine': graine,
        'cleTel': cleTelephone,
        'annuaire': annuaire,
        'boite': boite,
        'invitation': invitation,
      };

  factory CompteLie.fromJson(Map<String, dynamic> j) => CompteLie(
        peerId: j['peerId'] as String,
        pseudo: j['pseudo'] as String? ?? '',
        appareil: j['appareil'] as String,
        nomAppareil: j['nom'] as String? ?? 'Droplet Web',
        lieLe: DateTime.tryParse(j['lieLe'] as String? ?? '') ?? DateTime.now(),
        graine: j['graine'] as String,
        cleTelephone: j['cleTel'] as String,
        annuaire: j['annuaire'] as String? ?? kAnnuaire,
        boite: j['boite'] as String? ?? kBoite,
        invitation: j['invitation'] as String?,
      );

  /// Le compte gardé par ce navigateur, s'il y en a un. Un compte lié
  /// avant l'arrivée des messages (sans clé gardée) est oublié : il faut
  /// relier le navigateur, une fois.
  static CompteLie? charge() {
    try {
      final brut = web.window.localStorage.getItem(_cle) ?? web.window.sessionStorage.getItem(_cle);
      if (brut == null) return null;
      return CompteLie.fromJson((jsonDecode(brut) as Map).cast<String, dynamic>());
    } catch (_) {
      oublier();
      return null;
    }
  }

  void enregistrer({required bool durable}) {
    // « Rester connecté » décoché : la session s'efface avec l'onglet.
    final stockage = durable ? web.window.localStorage : web.window.sessionStorage;
    try {
      stockage.setItem(_cle, jsonEncode(toJson()));
    } catch (_) {}
  }

  static void oublier() {
    try {
      web.window.localStorage.removeItem(_cle);
      web.window.sessionStorage.removeItem(_cle);
    } catch (_) {}
  }

  /// Le canal chiffré avec le téléphone, par la boîte aux lettres.
  CanalTelephone canal() => CanalTelephone(
        appareil: appareil,
        peerId: peerId,
        graine: base64Url.decode(base64Url.normalize(graine)),
        cleTelephone: base64Url.decode(base64Url.normalize(cleTelephone)),
        boite: boite,
      );

  /// L'annuaire dit-il encore que ce navigateur est lié ? `null` si on ne
  /// peut pas le savoir (hors ligne) : on ne déconnecte pas pour si peu.
  Future<bool?> toujoursLie() async {
    try {
      final r = await web.window
          .fetch('$annuaire/appareils/${Uri.encodeComponent(peerId)}/${Uri.encodeComponent(appareil)}/etat'.toJS)
          .toDart;
      if (!r.ok) return null;
      final j = jsonDecode((await r.text().toDart).toDart) as Map;
      return j['lie'] as bool?;
    } catch (_) {
      return null;
    }
  }
}

/// Attend, sur le canal du code QR affiché, l'enveloppe du téléphone.
class AttenteLiaison {
  AttenteLiaison(this.invitation, {required this.onLie});

  final InvitationLiaison invitation;
  final void Function(CompteLie compte) onLie;
  Timer? _minuteur;
  bool _enCours = false;
  bool _fini = false;

  void demarrer() {
    _minuteur = Timer.periodic(const Duration(seconds: 2), (_) => _relever());
  }

  void arreter() {
    _fini = true;
    _minuteur?.cancel();
  }

  Future<void> _relever() async {
    if (_enCours || _fini) return;
    _enCours = true;
    try {
      final r = await web.window.fetch('$kAnnuaire/liaison/${invitation.canal}'.toJS).toDart;
      if (r.status == 200) {
        final enveloppe = (jsonDecode((await r.text().toDart).toDart) as Map).cast<String, dynamic>();
        final compte = await _ouvrir(enveloppe);
        if (compte != null && !_fini) {
          arreter();
          onLie(compte);
        }
      }
    } catch (_) {
      // Hors ligne, annuaire endormi : on réessaie au tour suivant.
    } finally {
      _enCours = false;
    }
  }

  Future<CompteLie?> _ouvrir(Map<String, dynamic> e) async {
    if (e['v'] != 1) return null;
    List<int> b64(String s) => base64Url.decode(base64Url.normalize(s));
    final cleTel = b64(e['cleTel'] as String);
    final nonce = b64(e['nonce'] as String);
    final chiffre = b64(e['chiffre'] as String);
    if (cleTel.length != 32 || chiffre.length < 17) return null;

    final secret = await X25519().sharedSecretKey(
      keyPair: invitation.cles,
      remotePublicKey: SimplePublicKey(cleTel, type: KeyPairType.x25519),
    );
    final cle = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
      secretKey: secret,
      info: utf8.encode('droplet-lien-v1'),
      nonce: utf8.encode('droplet-mesh'),
    );
    final clair = await AesGcm.with256bits().decrypt(
      SecretBox(
        chiffre.sublist(0, chiffre.length - 16),
        nonce: nonce,
        mac: Mac(chiffre.sublist(chiffre.length - 16)),
      ),
      secretKey: cle,
    );
    final j = (jsonDecode(utf8.decode(clair)) as Map).cast<String, dynamic>();
    String adresse(Object? a, String defaut) => a is String && a.startsWith('https://') ? a : defaut;
    return CompteLie(
      peerId: j['peerId'] as String,
      pseudo: j['pseudo'] as String? ?? '',
      appareil: j['appareil'] as String,
      nomAppareil: j['nom'] as String? ?? invitation.nomAppareil,
      lieLe: DateTime.tryParse(j['lieLe'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      graine: base64Url.encode(await invitation.cles.extractPrivateKeyBytes()).replaceAll('=', ''),
      cleTelephone: base64Url.encode(cleTel).replaceAll('=', ''),
      annuaire: adresse(j['annuaire'], kAnnuaire),
      boite: adresse(j['boite'], kBoite),
      invitation: j['invitation'] as String?,
    );
  }
}
