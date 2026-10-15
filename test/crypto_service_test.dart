// Verrouille les optimisations de CryptoService et MESURE leur effet.
//
// Ce que ce fichier garantit :
//   - un message chiffré par la nouvelle version se déchiffre, octet pour
//     octet, y compris une « photo » de 5 Mo ;
//   - le code de sécurité calculé dans un isolate est IDENTIQUE à celui de
//     l'ancienne boucle (sinon deux téléphones de versions différentes
//     afficheraient des codes différents et la vérification échouerait) ;
//   - le format du chiffré n'a pas bougé : texte chiffré puis tag de 16 octets.
//
// Les durées affichées (lignes « MESURE ») sont celles du Dart pur, sur la
// machine qui lance les tests. Le gain du chiffrement natif
// (cryptography_flutter) ne se mesure que sur un vrai téléphone.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:droplet/core/services/crypto_service.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _aleatoire(int n, int graine) {
  final r = Random(graine);
  return Uint8List.fromList(List.generate(n, (_) => r.nextInt(256)));
}

/// L'ancienne boucle du code de sécurité, telle qu'elle était avant.
Future<List<int>> _ancienPetrissage(String texte, int tours) async {
  List<int> m = utf8.encode(texte);
  final sha = Sha256();
  for (var i = 0; i < tours; i++) {
    m = (await sha.hash(m)).bytes;
  }
  return m;
}

int _ms(Stopwatch s) => s.elapsedMilliseconds;

void main() {
  test('aller-retour AES-GCM, de 0 octet à 5 Mo', () async {
    final cle = SecretKey(_aleatoire(32, 1));
    for (final taille in [0, 1, 16, 1000, 64 * 1024, 5 * 1024 * 1024]) {
      final clair = _aleatoire(taille, taille);
      final (chiffre, nonce) = await CryptoService.encryptBytes(cle, clair);
      expect(chiffre.length, taille + 16, reason: 'texte chiffré + tag de 16 octets');
      expect(nonce.length, 12);
      final retour = await CryptoService.decryptBytes(cle, chiffre, nonce);
      expect(retour, isNotNull);
      expect(retour, equals(clair));
    }
  });

  test('un octet modifié en route est rejeté', () async {
    final cle = SecretKey(_aleatoire(32, 2));
    final (chiffre, nonce) = await CryptoService.encryptBytes(cle, _aleatoire(500, 3));
    chiffre[42] ^= 1;
    expect(await CryptoService.decryptBytes(cle, chiffre, nonce), isNull);
  });

  test('compatibilité : le nouveau code déchiffre un message de l\'ancien format', () async {
    final cle = SecretKey(_aleatoire(32, 4));
    final clair = _aleatoire(3000, 5);
    final aes = AesGcm.with256bits();
    final nonce = aes.newNonce();
    final box = await aes.encrypt(clair, secretKey: cle, nonce: nonce);
    final ancien = Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);
    expect(await CryptoService.decryptBytes(cle, ancien, Uint8List.fromList(nonce)), equals(clair));
  });

  test('code de sécurité : isolate == ancienne boucle', () async {
    const texte = 'abc:clePubliqueA|xyz:clePubliqueB';
    final ancien = await _ancienPetrissage(texte, 5000);
    final nouveau = CryptoService.petrirCodeSecurite(texte, 5000);
    expect(nouveau, equals(ancien));

    final code = await CryptoService.computeSafetyNumber(
      myId: 'abc', myPublicKey: 'clePubliqueA', peerId: 'xyz', peerPublicKey: 'clePubliqueB');
    final codeInverse = await CryptoService.computeSafetyNumber(
      myId: 'xyz', myPublicKey: 'clePubliqueB', peerId: 'abc', peerPublicKey: 'clePubliqueA');
    expect(code, codeInverse, reason: 'les deux téléphones doivent afficher le même code');
    expect(code.split(' ').length, 12);
  });

  test('MESURES (Dart pur)', () async {
    final cle = SecretKey(_aleatoire(32, 6));
    final photo = _aleatoire(5 * 1024 * 1024, 7);
    final aes = AesGcm.with256bits();
    final box = await aes.encrypt(photo, secretKey: cle);

    // 1. Assemblage du résultat de chiffrement (5 Mo)
    var s = Stopwatch()..start();
    for (var i = 0; i < 5; i++) {
      Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);
    }
    final avant = _ms(s) / 5;
    s = Stopwatch()..start();
    for (var i = 0; i < 5; i++) {
      Uint8List(box.cipherText.length + 16)
        ..setRange(0, box.cipherText.length, box.cipherText)
        ..setRange(box.cipherText.length, box.cipherText.length + 16, box.mac.bytes);
    }
    final apres = _ms(s) / 5;
    // ignore: avoid_print
    print('MESURE assemblage 5 Mo : avant ${avant.toStringAsFixed(1)} ms → après ${apres.toStringAsFixed(1)} ms');

    // 2. Chiffrement complet d'une photo de 5 Mo (Dart pur, sans le natif)
    s = Stopwatch()..start();
    await CryptoService.encryptBytes(cle, photo);
    // ignore: avoid_print
    print('MESURE chiffrement 5 Mo en Dart pur : ${_ms(s)} ms (c\'est ce que le natif remplace)');

    // 3. Code de sécurité : temps de calcul, et temps où le fil principal est bloqué
    const texte = 'abc:clePubliqueA|xyz:clePubliqueB';
    s = Stopwatch()..start();
    await _ancienPetrissage(texte, 5000);
    final ancienMs = _ms(s);
    s = Stopwatch()..start();
    await CryptoService.computeSafetyNumber(
      myId: 'abc', myPublicKey: 'clePubliqueA', peerId: 'xyz', peerPublicKey: 'clePubliqueB');
    // ignore: avoid_print
    print('MESURE code de sécurité : ancienne boucle $ancienMs ms sur le fil principal → '
        'nouvelle ${_ms(s)} ms au total, calculée hors du fil principal');

    // 4. PBKDF2 300 000 itérations (sauvegarde) en Dart pur
    s = Stopwatch()..start();
    await CryptoService.deriveBackupKey('motdepasse', _aleatoire(16, 8));
    // ignore: avoid_print
    print('MESURE PBKDF2 300 000 itérations en Dart pur : ${_ms(s)} ms (natif sur Android, arrière-plan sur iOS)');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
