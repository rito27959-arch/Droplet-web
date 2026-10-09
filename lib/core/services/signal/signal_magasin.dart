// ============================================================================
// LE MAGASIN DE CLÉS SIGNAL — ce que le protocole doit retenir entre deux
// messages.
// ----------------------------------------------------------------------------
// Le protocole Signal fait avancer ses clés à chaque message : l'état d'une
// conversation (la « session ») change à chaque envoi et à chaque réception,
// et doit survivre à la fermeture de l'application. On range ici :
//   • les SESSIONS, une par personne ;
//   • les PRÉ-CLÉS à usage unique et SIGNÉES, dont les moitiés publiques sont
//     publiées pour permettre à quelqu'un de nous écrire en notre absence ;
//   • les IDENTITÉS des autres (clés publiques), pour repérer un changement.
//
// Rangement : la base de l'application (clé → valeur), comme les clés de
// groupe existantes. La clé d'identité elle-même n'est jamais stockée ici :
// elle est RE-DÉRIVÉE à chaque démarrage de la clé d'identité du téléphone,
// qui vit dans le coffre sécurisé d'Android (voir `SignalService`).
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../storage_service.dart';

/// Lecture et écriture clé → valeur (la base de l'application), remplaçable
/// par une mémoire dans les tests.
class StockageCleValeur {
  const StockageCleValeur();

  String? lire(String cle) => StorageService.getString(cle);
  Future<void> ecrire(String cle, String valeur) => StorageService.setString(cle, valeur);
  Future<void> effacer(String cle) => StorageService.remove(cle);
}

class MagasinSignal extends SignalProtocolStore {
  MagasinSignal({
    required this.identite,
    required this.registrationId,
    this.stockage = const StockageCleValeur(),
    this.identiteVerifiee,
    this.surIdentiteChangee,
  });

  final IdentityKeyPair identite;
  final int registrationId;
  final StockageCleValeur stockage;

  /// Le code de sécurité de cette personne a-t-il été vérifié ? Une identité
  /// VÉRIFIÉE qui change est refusée : c'est une alerte, pas une mise à jour.
  final bool Function(String peerId)? identiteVerifiee;

  /// Prévenu quand l'identité d'une personne change (réinstallation…).
  final void Function(String peerId)? surIdentiteChangee;

  static const _prefixe = 'sig.';

  String _cleSession(SignalProtocolAddress a) => '${_prefixe}s.${a.getName()}.${a.getDeviceId()}';
  String _cleIdentite(String nom) => '${_prefixe}id.$nom';
  String _clePreCle(int id) => '${_prefixe}pk.$id';
  String _cleSignee(int id) => '${_prefixe}spk.$id';
  static const _cleIdsSignees = '${_prefixe}spk.ids';

  Uint8List? _octets(String cle) {
    final valeur = stockage.lire(cle);
    if (valeur == null || valeur.isEmpty) return null;
    try {
      return base64Decode(valeur);
    } catch (_) {
      return null;
    }
  }

  // ── Identités ────────────────────────────────────────────────────────

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async => identite;

  @override
  Future<int> getLocalRegistrationId() async => registrationId;

  @override
  Future<IdentityKey?> getIdentity(SignalProtocolAddress address) async {
    final octets = _octets(_cleIdentite(address.getName()));
    return octets == null ? null : IdentityKey.fromBytes(octets, 0);
  }

  @override
  Future<bool> saveIdentity(SignalProtocolAddress address, IdentityKey? identityKey) async {
    if (identityKey == null) return false;
    final nom = address.getName();
    final nouvelle = base64Encode(identityKey.serialize());
    final ancienne = stockage.lire(_cleIdentite(nom));
    if (ancienne == nouvelle) return false;
    await stockage.ecrire(_cleIdentite(nom), nouvelle);
    if (ancienne != null) surIdentiteChangee?.call(nom);
    return true;
  }

  @override
  Future<bool> isTrustedIdentity(
    SignalProtocolAddress address,
    IdentityKey? identityKey,
    Direction direction,
  ) async {
    if (identityKey == null) return false;
    final connue = stockage.lire(_cleIdentite(address.getName()));
    if (connue == null || connue == base64Encode(identityKey.serialize())) return true;
    // Première rencontre acceptée, changement accepté pour une personne non
    // vérifiée (comme Signal, qui prévient) ; refusé si elle était vérifiée.
    return !(identiteVerifiee?.call(address.getName()) ?? false);
  }

  // ── Pré-clés à usage unique ──────────────────────────────────────────

  @override
  Future<PreKeyRecord> loadPreKey(int preKeyId) async {
    final octets = _octets(_clePreCle(preKeyId));
    if (octets == null) throw InvalidKeyIdException('Pré-clé inconnue : $preKeyId');
    return PreKeyRecord.fromBuffer(octets);
  }

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) =>
      stockage.ecrire(_clePreCle(preKeyId), base64Encode(record.serialize()));

  @override
  Future<bool> containsPreKey(int preKeyId) async => stockage.lire(_clePreCle(preKeyId)) != null;

  @override
  Future<void> removePreKey(int preKeyId) => stockage.effacer(_clePreCle(preKeyId));

  // ── Pré-clés signées ─────────────────────────────────────────────────

  List<int> _idsSignees() {
    try {
      return (jsonDecode(stockage.lire(_cleIdsSignees) ?? '[]') as List).whereType<int>().toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SignedPreKeyRecord> loadSignedPreKey(int signedPreKeyId) async {
    final octets = _octets(_cleSignee(signedPreKeyId));
    if (octets == null) {
      throw InvalidKeyIdException('Pré-clé signée inconnue : $signedPreKeyId');
    }
    return SignedPreKeyRecord.fromSerialized(octets);
  }

  @override
  Future<List<SignedPreKeyRecord>> loadSignedPreKeys() async => [
        for (final id in _idsSignees())
          if (_octets(_cleSignee(id)) case final octets?) SignedPreKeyRecord.fromSerialized(octets),
      ];

  @override
  Future<void> storeSignedPreKey(int signedPreKeyId, SignedPreKeyRecord record) async {
    await stockage.ecrire(_cleSignee(signedPreKeyId), base64Encode(record.serialize()));
    final ids = _idsSignees();
    if (!ids.contains(signedPreKeyId)) {
      await stockage.ecrire(_cleIdsSignees, jsonEncode([...ids, signedPreKeyId]));
    }
  }

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async =>
      stockage.lire(_cleSignee(signedPreKeyId)) != null;

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) async {
    await stockage.effacer(_cleSignee(signedPreKeyId));
    await stockage.ecrire(
        _cleIdsSignees, jsonEncode(_idsSignees()..remove(signedPreKeyId)));
  }

  // ── Sessions ─────────────────────────────────────────────────────────

  @override
  Future<SessionRecord> loadSession(SignalProtocolAddress address) async {
    final octets = _octets(_cleSession(address));
    return octets == null ? SessionRecord() : SessionRecord.fromSerialized(octets);
  }

  @override
  Future<void> storeSession(SignalProtocolAddress address, SessionRecord record) =>
      stockage.ecrire(_cleSession(address), base64Encode(record.serialize()));

  @override
  Future<bool> containsSession(SignalProtocolAddress address) async =>
      stockage.lire(_cleSession(address)) != null;

  @override
  Future<void> deleteSession(SignalProtocolAddress address) =>
      stockage.effacer(_cleSession(address));

  /// Un seul appareil par personne dans Droplet : l'appareil 1.
  @override
  Future<List<int>> getSubDeviceSessions(String name) async => const [];

  @override
  Future<void> deleteAllSessions(String name) =>
      deleteSession(SignalProtocolAddress(name, 1));
}
