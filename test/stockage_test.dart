// Le stockage de Droplet Web, vérifié dans un vrai navigateur
// (`flutter test --platform chrome`) : IndexedDB n'existe pas ailleurs.
@TestOn('browser')
library;

import 'dart:convert';

import 'package:droplet_web/donnees/modeles.dart';
import 'package:droplet_web/donnees/stockage_idb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IndexedDB : écrit, relit, ne réécrit que ce qui change, retire', () async {
    final s = StockageIdb('droplet-web-test-${DateTime.now().microsecondsSinceEpoch}');
    expect(await s.ouvrir(), isTrue);
    expect(await s.toutLire(), isEmpty);

    expect(await s.synchroniser({'meta': '{"a":1}', 'm:x': '[1]', 'm:y': '[2]'}), 3);
    // Rien n'a changé : rien n'est écrit.
    expect(await s.synchroniser({'meta': '{"a":1}', 'm:x': '[1]', 'm:y': '[2]'}), 0);
    // Une seule discussion change, une autre disparaît : deux opérations.
    expect(await s.synchroniser({'meta': '{"a":1}', 'm:x': '[1,3]'}), 2);

    final relu = StockageIdb(s.nomBase);
    expect(await relu.ouvrir(), isTrue);
    expect(await relu.toutLire(), {'meta': '{"a":1}', 'm:x': '[1,3]'});

    await relu.effacer();
    expect(await relu.toutLire(), isEmpty);
  });

  test('Un message survit à l’aller-retour JSON', () {
    final m = Message(
      id: 'm1',
      discussionId: 'd1',
      auteurId: 'moi',
      type: TypeMessage.texte,
      date: DateTime(2026, 11, 4, 9, 30),
      texte: 'Bonjour 👋 — « guillemets »',
      reactions: {'❤️': ['amina']},
    );
    final relu = Message.fromJson(jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>);
    expect(relu.id, m.id);
    expect(relu.texte, m.texte);
    expect(relu.date, m.date);
    expect(relu.reactions, m.reactions);
  });
}
