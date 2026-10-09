// ============================================================================
// LES APPAREILS LIÉS — Droplet Web (et demain d'autres ordinateurs).
// ----------------------------------------------------------------------------
// Le téléphone reste l'appareil principal : c'est lui qui détient l'identité
// du compte. Lier un navigateur, c'est :
//
//   1. SCANNER le code QR que montre web.dropletmesh.app. Il contient la clé
//      publique X25519 du navigateur, un canal de rendez-vous (16 octets
//      aléatoires) et le nom de l'appareil (« Chrome · macOS ») :
//
//        {"type":"droplet_lien","v":1,"canal":"…","cle":"…","nom":"…"}
//
//   2. CHIFFRER pour ce navigateur seul une enveloppe qui dit qui nous
//      sommes (identifiant, pseudo, clé publique, identifiant d'appareil
//      attribué) : clé = HKDF(X25519(ma clé privée, sa clé publique),
//      « droplet-lien-v1 »), AES-256-GCM.
//
//   3. DÉPOSER l'enveloppe sur le canal, via l'annuaire
//      (POST /liaison/{canal}). Le navigateur attend sur ce canal, la relève,
//      refait le même calcul avec SA clé privée et NOTRE clé publique (jointe
//      en clair dans l'enveloppe), et déchiffre. L'annuaire ne voit qu'un
//      blob opaque.
//
//   4. RETENIR l'appareil ici, pour pouvoir le déconnecter plus tard
//      (DELETE /appareils/{moi}/{appareil}).
//
// Le code QR change toutes les 60 secondes côté navigateur : une photo du
// code ne sert plus à rien une minute plus tard. Et rien n'est retenu tant
// que l'annuaire n'a pas accepté l'enveloppe.
// ============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../config/server_config.dart';
import 'crypto_service.dart';
import 'directory_client.dart';
import 'storage_service.dart';

/// Ce que porte le code QR de Droplet Web.
class InvitationLien {
  const InvitationLien({required this.canal, required this.cle, required this.nom});

  final String canal;
  final List<int> cle;
  final String nom;

  /// Lit un code scanné. Rend null si ce n'est pas un code de liaison
  /// valide (un code de contact, une adresse, un code abîmé…).
  static InvitationLien? lire(String brut) {
    try {
      final j = jsonDecode(brut);
      if (j is! Map || j['type'] != 'droplet_lien' || j['v'] != 1) return null;
      final cle = _b64(j['cle'] as String);
      final canal = j['canal'] as String;
      if (cle.length != 32 || _b64(canal).length != 16) return null;
      final nom = (j['nom'] as String? ?? '').trim();
      return InvitationLien(canal: canal, cle: cle, nom: nom.isEmpty ? 'Droplet Web' : nom);
    } catch (_) {
      return null;
    }
  }

  static List<int> _b64(String s) => base64Url.decode(base64Url.normalize(s));
}

class AppareilLie {
  const AppareilLie({
    required this.id,
    required this.nom,
    required this.lieLe,
    this.dernierAcces,
  });

  final String id;
  final String nom;
  final DateTime lieLe;
  final DateTime? dernierAcces;

  /// Une icône selon le nom (« Safari · macOS », « Edge · Windows »…).
  bool get estMac => nom.contains('macOS');

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'lieLe': lieLe.toIso8601String(),
        'dernierAcces': dernierAcces?.toIso8601String(),
      };

  factory AppareilLie.fromJson(Map<String, dynamic> j) => AppareilLie(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? 'Droplet Web',
        lieLe: DateTime.tryParse(j['lieLe'] as String? ?? '') ?? DateTime.now(),
        dernierAcces: j['dernierAcces'] == null ? null : DateTime.tryParse(j['dernierAcces'] as String),
      );
}

enum ResultatLiaison { lie, codeInvalide, sansIdentite, serveurInjoignable, limiteAtteinte }

class AppareilsLies {
  AppareilsLies._();

  static const _cle = 'appareils_lies_v1';

  /// Comme WhatsApp : quatre appareils associés au plus.
  static const int maximum = 4;

  /// Change à chaque liaison ou déconnexion : les écrans s'y abonnent.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static List<AppareilLie> liste() {
    final brut = StorageService.getString(_cle);
    if (brut == null || brut.isEmpty) return const [];
    try {
      return (jsonDecode(brut) as List)
          .map((e) => AppareilLie.fromJson((e as Map).cast<String, dynamic>()))
          .toList()
        ..sort((a, b) => b.lieLe.compareTo(a.lieLe));
    } catch (_) {
      return const [];
    }
  }

  static Future<void> _enregistrer(List<AppareilLie> l) async {
    await StorageService.setString(_cle, jsonEncode(l.map((a) => a.toJson()).toList()));
    revision.value++;
  }

  static DirectoryClient get _annuaire => DirectoryClient(serverUrl: kDirectoryUrl);

  /// Lier le navigateur qui affiche [invitation].
  static Future<ResultatLiaison> lier(InvitationLien invitation) async {
    if (liste().length >= maximum) return ResultatLiaison.limiteAtteinte;
    final moi = StorageService.currentUser;
    if (moi == null) return ResultatLiaison.sansIdentite;
    final maCle = await CryptoService.ensureIdentityKeyPair();
    final cle = await CryptoService.cleLiaison(invitation.cle);
    if (cle == null) return ResultatLiaison.sansIdentite;

    final hasard = Random.secure();
    final appareilId = base64Url.encode(List<int>.generate(9, (_) => hasard.nextInt(256)));
    final lieLe = DateTime.now().toUtc();
    final contenu = utf8.encode(jsonEncode({
      'peerId': moi.id,
      'pseudo': moi.pseudo,
      'appareil': appareilId,
      'nom': invitation.nom,
      'lieLe': lieLe.toIso8601String(),
      'annuaire': kDirectoryUrl,
      'boite': kMailboxUrl,
    }));
    final aes = AesGcm.with256bits();
    final boite = await aes.encrypt(contenu, secretKey: cle);
    final enveloppe = {
      'v': 1,
      // Notre clé publique, en clair : le navigateur en a besoin pour
      // calculer la même clé de son côté.
      'cleTel': base64Url.encode(base64Decode(maCle)).replaceAll('=', ''),
      'nonce': base64Url.encode(boite.nonce).replaceAll('=', ''),
      'chiffre': base64Url.encode([...boite.cipherText, ...boite.mac.bytes]).replaceAll('=', ''),
    };

    final ok = await _annuaire.publierLiaison(canal: invitation.canal, enveloppe: enveloppe);
    if (!ok) return ResultatLiaison.serveurInjoignable;

    await _enregistrer([
      ...liste(),
      AppareilLie(id: appareilId, nom: invitation.nom, lieLe: lieLe.toLocal(), dernierAcces: DateTime.now()),
    ]);
    return ResultatLiaison.lie;
  }

  /// Déconnecter un appareil. Il disparaît d'ici dans tous les cas ; si
  /// l'annuaire n'est pas joignable, la révocation repartira à la
  /// prochaine liaison réussie.
  static Future<bool> deconnecter(AppareilLie a) async {
    final moi = StorageService.currentUser;
    final ok = moi != null && await _annuaire.revoquerAppareil(peerId: moi.id, appareilId: a.id);
    await _enregistrer(liste().where((x) => x.id != a.id).toList());
    return ok;
  }

  static Future<void> toutDeconnecter() async {
    for (final a in liste()) {
      await deconnecter(a);
    }
  }
}
