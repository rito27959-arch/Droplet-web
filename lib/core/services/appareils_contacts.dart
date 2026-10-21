// ============================================================================
// LES APPAREILS LIÉS DE MES CONTACTS — le multi-appareils.
// ----------------------------------------------------------------------------
// Un contact peut avoir lié Droplet Web à son téléphone. Pour que Droplet Web
// reçoive mes messages MÊME TÉLÉPHONE ÉTEINT, je dépose, en plus du message
// pour son téléphone, une copie chiffrée pour chacun de ses appareils :
//
//   clé = HKDF-SHA256( X25519(ma clé privée, clé publique de l'appareil),
//                      sel « droplet-mesh », info « droplet-1to1-v1 » )
//
// — exactement le chiffrement 1:1 historique, avec la clé de l'appareil au
// lieu de celle du téléphone. L'annuaire publie la liste des appareils d'un
// compte (`/appareils/<id>/liste`) ; seul le téléphone du compte peut y
// ajouter un appareil (requête signée par lui).
//
// Dans l'autre sens, Droplet Web peut m'écrire au nom de son compte : le
// dépôt vient de l'identifiant de l'appareil et porte `compte`. Je vérifie
// que cet appareil, avec CETTE clé, figure bien dans la liste du compte
// avant de croire que le message vient de lui.
// ============================================================================

import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'crypto_service.dart';
import 'tor_transport.dart';

typedef ListeAppareils = ({bool md, List<({String id, String cle})> appareils});

class AppareilsContacts {
  AppareilsContacts._();

  static final Map<String, (DateTime, ListeAppareils)> _cache = {};
  static const _duree = Duration(minutes: 10);

  /// Les appareils liés de [peerId] (gardés 10 minutes). [forcer] : redemander
  /// à l'annuaire, par exemple quand un appareil inconnu se présente.
  static Future<ListeAppareils?> de(String peerId, {bool forcer = false}) async {
    final deja = _cache[peerId];
    if (!forcer && deja != null && DateTime.now().difference(deja.$1) < _duree) return deja.$2;
    final annuaire = TorTransport.annuaireCourant;
    if (annuaire == null) return deja?.$2;
    final r = await annuaire.appareilsDe(peerId);
    if (r == null) return deja?.$2;
    _cache[peerId] = (DateTime.now(), r);
    if (_cache.length > 2000) _cache.remove(_cache.keys.first);
    return r;
  }

  /// Une clé publique en base64 standard, quelle que soit sa forme (l'annuaire
  /// garde celle de Droplet Web en base64url).
  static String base64Standard(String cle) =>
      base64.encode(base64.decode(base64.normalize(cle.replaceAll('-', '+').replaceAll('_', '/'))));

  static bool memeCle(String a, String b) {
    try {
      return base64Standard(a) == base64Standard(b);
    } catch (_) {
      return false;
    }
  }

  /// La clé partagée avec un appareil lié (son identifiant, sa clé publique).
  static Future<SecretKey?> clePour(String appareil, String clePublique) =>
      CryptoService.sharedKeyWithPeer('appareil:$appareil', base64Standard(clePublique));

  /// [appareil] est-il bien un appareil lié de [compte], avec [cle] ?
  static Future<bool> appartient(String compte, String appareil, String cle) async {
    bool dans(ListeAppareils? l) => l != null && l.appareils.any((a) => a.id == appareil && memeCle(a.cle, cle));
    if (dans(await de(compte))) return true;
    // Appareil lié il y a moins de 10 minutes : la liste en cache l'ignore.
    return dans(await de(compte, forcer: true));
  }
}
