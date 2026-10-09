// ============================================================================
// CE QUE CE TEST VÉRIFIE, ET POURQUOI
// ----------------------------------------------------------------------------
// La garde tient les messages pendant l'absence d'un destinataire. Son
// intérêt tient tout entier dans une propriété : ELLE N'ABANDONNE PAS.
// Un test qui ne vérifierait que « ça s'écrit en base » passerait à côté.
//
// Les cas ci-dessous sont ceux qui ont été rejoués contre un vrai SQLite
// avant l'écriture du code. Ils sont ici pour que la propriété reste
// vraie quand quelqu'un touchera au recul exponentiel dans six mois.
// ============================================================================

import 'dart:math';
import 'dart:typed_data';

import 'package:droplet/core/services/garde_messages.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List paquet([int taille = 64]) =>
    Uint8List.fromList(List<int>.generate(taille, (i) => i % 256));

void main() {
  late GardeMessages garde;
  final t0 = DateTime(2026, 1, 1);

  setUp(() {
    // Hasard fixé : la gigue ne doit pas rendre un test intermittent.
    garde = GardeMessages.enMemoire(alea: Random(1));
  });

  tearDown(() => garde.fermer());

  test('un message confié est dû immédiatement', () {
    garde.confier(
      messageId: 'm1',
      pairs: ['awa'],
      corps: paquet(),
      maintenant: t0,
    );
    final dues = garde.dues(pairsJoignables: {'awa'}, maintenant: t0);
    expect(dues, hasLength(1));
    expect(dues.single.messageId, 'm1');
    expect(dues.single.envois, 0);
  });

  test('les octets ressortent identiques à l\'octet près', () {
    // ⚠️ LE CŒUR DE LA GARDE. On réémet le paquet d'origine plutôt que
    // de le reconstruire : s'il ressortait altéré, le destinataire ne
    // saurait pas le déchiffrer, et l'échec serait silencieux.
    final p = Uint8List.fromList([0, 0, 0, 7, 255, 128, 0, 42]);
    garde.confier(
      messageId: 'm1',
      pairs: ['awa'],
      corps: p,
      maintenant: t0,
    );
    final due = garde.dues(pairsJoignables: {'awa'}, maintenant: t0).single;
    expect(due.corps, equals(p));
  });

  test('rien n\'est dû pour un pair hors de vue', () {
    garde.confier(
      messageId: 'm1',
      pairs: ['awa'],
      corps: paquet(),
      maintenant: t0,
    );
    expect(garde.dues(pairsJoignables: {'karim'}, maintenant: t0), isEmpty);
    expect(garde.dues(pairsJoignables: const {}, maintenant: t0), isEmpty);
  });

  test('confier deux fois ne remet pas le compteur à zéro', () {
    garde.confier(
        messageId: 'm1', pairs: ['awa'], corps: paquet(), maintenant: t0);
    garde.noterEnvoi(messageId: 'm1', pairId: 'awa', maintenant: t0);
    garde.confier(
        messageId: 'm1', pairs: ['awa'], corps: paquet(), maintenant: t0);
    final tard = t0.add(const Duration(hours: 1));
    final due = garde.dues(pairsJoignables: {'awa'}, maintenant: tard).single;
    expect(due.envois, 1, reason: 'le compteur a été remis à zéro');
  });

  test('un envoi repousse la tentative suivante', () {
    garde.confier(
        messageId: 'm1', pairs: ['awa'], corps: paquet(), maintenant: t0);
    garde.noterEnvoi(messageId: 'm1', pairId: 'awa', maintenant: t0);
    expect(garde.dues(pairsJoignables: {'awa'}, maintenant: t0), isEmpty);
    final apres = t0.add(const Duration(seconds: 5));
    expect(garde.dues(pairsJoignables: {'awa'}, maintenant: apres), hasLength(1));
  });

  test('ELLE N\'ABANDONNE PAS : due encore après trois jours', () {
    // C'est LA propriété qui distingue la garde de la file en mémoire,
    // dont l'abandon définitif tombe au bout d'environ sept secondes.
    garde.confier(
        messageId: 'm1', pairs: ['awa'], corps: paquet(), maintenant: t0);
    var t = t0;
    // On simule un pair injoignable : on note les envois qui auraient eu
    // lieu, sans jamais acquitter.
    for (var i = 0; i < 200; i++) {
      t = t.add(const Duration(minutes: 20));
      for (final d in garde.dues(pairsJoignables: {'awa'}, maintenant: t)) {
        garde.noterEnvoi(
            messageId: d.messageId, pairId: d.pairId, maintenant: t);
      }
    }
    expect(t.difference(t0).inDays, greaterThanOrEqualTo(2));
    expect(
      garde.dues(pairsJoignables: {'awa'}, maintenant: t.add(const Duration(minutes: 20))),
      hasLength(1),
      reason: 'la garde a abandonné avant le TTL',
    );
  });

  test('le délai est borné et jamais négatif', () {
    // ⚠️ `1 << 40` déborde l'entier et rend un délai négatif : un message
    // renvoyé aussi vite que la radio le permet. Le défaut n'apparaît
    // qu'après plusieurs jours, quand personne ne regarde.
    for (var n = 1; n < 2000; n++) {
      final d = garde.delai(n);
      expect(d.inMilliseconds, greaterThan(0), reason: 'délai négatif à n=$n');
      expect(
        d.inMilliseconds,
        lessThanOrEqualTo(
          (GardeMessages.reculMax.inMilliseconds * 1.25).round() + 1,
        ),
        reason: 'délai au-dessus du plafond à n=$n',
      );
    }
  });

  test('acquitter un destinataire ne libère pas les autres', () {
    garde.confier(
      messageId: 'm1',
      pairs: ['awa', 'karim'],
      corps: paquet(),
      maintenant: t0,
    );
    garde.acquitter(messageId: 'm1', pairId: 'awa', maintenant: t0);
    final dues =
        garde.dues(pairsJoignables: {'awa', 'karim'}, maintenant: t0);
    expect(dues, hasLength(1));
    expect(dues.single.pairId, 'karim');
    expect(garde.enAttente, 1);
  });

  test('un gros paquet n\'est pas pris en garde', () {
    // Un transfert de fichier a déjà sa propre reprise : en garder une
    // copie doublerait l'occupation disque pour rien.
    garde.confier(
      messageId: 'gros',
      pairs: ['awa'],
      corps: paquet(GardeMessages.tailleMaxCorps + 1),
      maintenant: t0,
    );
    expect(garde.enAttente, 0);
  });

  test('la diffusion n\'est pas prise en garde', () {
    garde.confier(
      messageId: 'm1',
      pairs: ['broadcast'],
      corps: paquet(),
      maintenant: t0,
    );
    expect(garde.enAttente, 0);
  });

  test('la purge efface les acquittés anciens et les périmés', () {
    garde.confier(
        messageId: 'vieux', pairs: ['awa'], corps: paquet(), maintenant: t0);
    final tard = t0.add(const Duration(days: 8));
    garde.confier(
        messageId: 'recent', pairs: ['awa'], corps: paquet(), maintenant: tard);
    garde.confier(
        messageId: 'fait', pairs: ['karim'], corps: paquet(), maintenant: tard);
    garde.acquitter(messageId: 'fait', pairId: 'karim', maintenant: tard);

    garde.purger(maintenant: tard.add(const Duration(hours: 7)));

    expect(garde.enAttente, 1);
    expect(garde.enAttentePour('awa'), 1);
    expect(garde.enAttentePour('karim'), 0);
  });

  test('la latence observée est mesurée de la prise en garde à l\'ACK', () {
    garde.confier(
        messageId: 'm1', pairs: ['awa'], corps: paquet(), maintenant: DateTime.now());
    garde.acquitter(
      messageId: 'm1',
      pairId: 'awa',
      maintenant: DateTime.now().add(const Duration(seconds: 3)),
    );
    final l = garde.latencesObservees();
    expect(l, hasLength(1));
    expect(l.single, closeTo(3000, 1500));
  });
}
