// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Hidden service personnel pour Droplet.
//
// Génère une paire de clés Ed25519 et dérive l'adresse .onion v3 qui en
// résulte. Cette adresse identifie cet appareil sur le réseau Tor — c'est
// l'équivalent d'une adresse postale pour les hidden services.
//
// ── Comment ça marche ? ─────────────────────────────────────────────
//
// 1. On génère une clé Ed25519 (32 bytes) — c'est l'identité Tor.
// 2. On dérive l'adresse .onion v3 en 56 caractères :
//    - SHA3-256(clé_publique) → 32 bytes
//    - Premiers 10 bytes → encodés en base32
//    - Ajout de ".onion"
// 3. Cette adresse est stable : même clé = même adresse, toujours.
//
// ── Sécurité ────────────────────────────────────────────────────────
//
// La clé privée est stockée dans FlutterSecureStorage (Keychain/Keystore),
// jamais en SQLite ni en clair. La clé publique et l'adresse .onion sont
// dérivées et peuvent être partagées librement.
// ============================================================================

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha3.dart';

/// Taille d'une clé Ed25519 en octets.
const int _kEd25519KeySize = 32;

/// Nombre d'octets de checksum utilisés dans la dérivation v3.
const int _kChecksumSize = 2;

/// Version du hidden service Tor v3.
const int _kOnionVersion = 0x03;

/// Alphabet base32 utilisé pour les adresses .onion (RFC 4648).
const String _kBase32Alphabet = 'abcdefghijklmnopqrstuvwxyz234567';

/// Service de hidden service Tor pour Droplet.
///
/// Gère la génération et le stockage de la paire de clés Ed25519 utilisée
/// comme identité sur le réseau Tor, et dérive l'adresse .onion v3 associée.
class OnionService {
  static const _secureStorage = FlutterSecureStorage();
  static const _privateKeyKey = 'onion_ed25519_private';
  static const _publicKeyKey = 'onion_ed25519_public';
  static const _onionAddressKey = 'onion_address';

  static final _ed25519 = Ed25519();

  // ── Génération de clés ───────────────────────────────────────────

  /// Génère (ou restaure) la paire de clés et retourne l'adresse .onion.
  ///
  /// Si une clé existe déjà, la restaure. Sinon, en génère une nouvelle.
  /// L'adresse .onion est déterministe : même clé = même adresse.
  static Future<OnionIdentity> ensureIdentity() async {
    // Vérifier si on a déjà une clé.
    final existingPriv = await _secureStorage.read(key: _privateKeyKey);
    if (existingPriv != null) {
      final pubB64 = await _secureStorage.read(key: _publicKeyKey);
      final onionAddr = await _secureStorage.read(key: _onionAddressKey);
      if (pubB64 != null && onionAddr != null) {
        return OnionIdentity(
          privateKeyBytes: base64Decode(existingPriv),
          publicKeyBytes: base64Decode(pubB64),
          onionAddress: onionAddr,
        );
      }
    }

    // Générer une nouvelle paire de clés.
    return generateIdentity();
  }

  /// Génère une nouvelle paire de clés Ed25519 et dérive l'adresse .onion.
  static Future<OnionIdentity> generateIdentity() async {
    final keyPair = await _ed25519.newKeyPair();
    final privateKeyBytes = Uint8List.fromList(await keyPair.extractPrivateKeyBytes());
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = Uint8List.fromList(publicKey.bytes);

    // Dériver l'adresse .onion v3.
    final onionAddress = _deriveOnionAddress(publicKeyBytes);

    // Stocker de manière sécurisée.
    await _secureStorage.write(
      key: _privateKeyKey,
      value: base64Encode(privateKeyBytes),
    );
    await _secureStorage.write(
      key: _publicKeyKey,
      value: base64Encode(publicKeyBytes),
    );
    await _secureStorage.write(
      key: _onionAddressKey,
      value: onionAddress,
    );

    debugPrint('[OnionService] Identité générée: ${onionAddress.substring(0, 12)}…');

    return OnionIdentity(
      privateKeyBytes: privateKeyBytes,
      publicKeyBytes: publicKeyBytes,
      onionAddress: onionAddress,
    );
  }

  /// Charge l'identité existante sans en générer de nouvelle.
  static Future<OnionIdentity?> loadIdentity() async {
    final privB64 = await _secureStorage.read(key: _privateKeyKey);
    final pubB64 = await _secureStorage.read(key: _publicKeyKey);
    final onionAddr = await _secureStorage.read(key: _onionAddressKey);

    if (privB64 == null || pubB64 == null || onionAddr == null) {
      return null;
    }

    return OnionIdentity(
      privateKeyBytes: base64Decode(privB64),
      publicKeyBytes: base64Decode(pubB64),
      onionAddress: onionAddr,
    );
  }

  /// Supprime l'identité Tor (réinitialisation complète).
  static Future<void> clearIdentity() async {
    await _secureStorage.delete(key: _privateKeyKey);
    await _secureStorage.delete(key: _publicKeyKey);
    await _secureStorage.delete(key: _onionAddressKey);
  }

  // ── Validation d'adresse .onion ──────────────────────────────────

  /// Vérifie si une chaîne est une adresse .onion v3 valide.
  ///
  /// Format attendu : 56 caractères base32 (a-z, 2-7) + ".onion".
  /// Total : 62 caractères.
  static bool isValidOnionAddress(String? address) {
    if (address == null) return false;
    if (address.length != 62) return false;
    if (!address.endsWith('.onion')) return false;
    // Vérifier que les 56 premiers caractères sont base32 (RFC 4648).
    final prefix = address.substring(0, 56);
    final base32Regex = RegExp(r'^[a-z2-7]{56}$');
    return base32Regex.hasMatch(prefix);
  }

  // ── Dérivation de l'adresse .onion v3 ────────────────────────────

  /// Dérive une adresse .onion v3 (56 caractères) depuis une clé publique
  /// Ed25519 (32 bytes).
  ///
  /// Algorithme Tor v3 (sans hidden service key, simplifié) :
  /// - Version byte : 0x03
  /// - Checksum : SHA3_256(".onion" + version + pubkey) → premiers 2 bytes
  /// - Data : version (1) + pubkey (32) + checksum (2) = 35 bytes
  /// - Base32 encode → 56 caractères
  /// - Ajout ".onion"
  static String _deriveOnionAddress(Uint8List publicKey) {
    assert(publicKey.length == _kEd25519KeySize);

    // 1. Version byte.
    final versionByte = Uint8List.fromList([_kOnionVersion]);

    // 2. Checksum : SHA3_256(".onion" + version + pubkey) → 2 premiers bytes.
    final checksumInput = Uint8List.fromList([
      ...utf8.encode('.onion'),
      _kOnionVersion,
      ...publicKey,
    ]);
    final checksumHash = _computeSha3_256(checksumInput);
    final checksum = Uint8List.fromList(checksumHash.sublist(0, _kChecksumSize));

    // 3. Data à encoder : version + pubkey + checksum = 35 bytes.
    final dataToEncode = Uint8List.fromList([
      ...versionByte,
      ...publicKey,
      ...checksum,
    ]);

    // 4. Encoder en base32 → 56 caractères (35 * 8 / 5 = 56).
    final base32 = _encodeBase32(dataToEncode);

    return '$base32.onion';
  }

  /// Encode des octets en base32 (RFC 4648, lowercase).
  static String _encodeBase32(Uint8List bytes) {
    var result = '';
    var buffer = 0;
    var bitsLeft = 0;

    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        result += _kBase32Alphabet[(buffer >> (bitsLeft - 5)) & 0x1F];
        bitsLeft -= 5;
      }
    }

    if (bitsLeft > 0) {
      result += _kBase32Alphabet[(buffer << (5 - bitsLeft)) & 0x1F];
    }

    return result;
  }

  /// Hachage SHA3-256 cryptographique (utilisé pour la dérivation d'adresse).
  ///
  /// Utilise SHA3-256 du package `pointycastle` — conforme à la spec Tor v3.
  static List<int> _computeSha3_256(List<int> data) {
    final digest = SHA3Digest(256);
    final input = Uint8List.fromList(data);
    digest.update(input, 0, input.length);
    final output = Uint8List(digest.digestSize);
    digest.doFinal(output, 0);
    return output.toList();
  }
}

/// Identité Tor d'un appareil.
class OnionIdentity {
  const OnionIdentity({
    required this.privateKeyBytes,
    required this.publicKeyBytes,
    required this.onionAddress,
  });

  final Uint8List privateKeyBytes;
  final Uint8List publicKeyBytes;
  final String onionAddress;

  /// Clé publique encodée en base64.
  String get publicKeyBase64 => base64Encode(publicKeyBytes);

  /// Clé privée encodée en base64.
  String get privateKeyBase64 => base64Encode(privateKeyBytes);

  /// Adresse .onion raccourcie pour l'affichage.
  String get shortOnion {
    if (onionAddress.length < 20) return onionAddress;
    return '${onionAddress.substring(0, 12)}…${onionAddress.substring(onionAddress.length - 6)}';
  }

  /// Sérialise en JSON pour le QR code.
  Map<String, dynamic> toJson() => {
        'type': 'droplet_onion',
        'version': 1,
        'publicKey': publicKeyBase64,
        'onion': onionAddress,
      };

  /// Désérialise depuis un JSON (scanné depuis un QR code).
  static OnionIdentity? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'droplet_onion') return null;
    final pubKeyB64 = json['publicKey'] as String?;
    final onion = json['onion'] as String?;
    if (pubKeyB64 == null || onion == null) return null;

    return OnionIdentity(
      privateKeyBytes: Uint8List(0), // Pas de clé privée dans le QR
      publicKeyBytes: base64Decode(pubKeyB64),
      onionAddress: onion,
    );
  }

  /// Encode en JSON string pour le QR code.
  String encodeForQr() => jsonEncode(toJson());

  /// Décodé depuis un QR code scanné.
  static OnionIdentity? decodeFromQr(String qrData) {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
