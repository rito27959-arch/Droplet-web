// ============================================================================
// QUI A LE DROIT DE SONNER — la règle de `Instantane.decider`.
// ----------------------------------------------------------------------------
// Elle décide pour l'application ouverte ET pour l'isolate du push. Une
// erreur ici ne plante rien : un groupe en sourdine sonne, ou une mention
// se perd. Personne ne le remarque avant d'avoir manqué la question qu'on
// lui posait. Chaque cas ci-dessous verrouille une phrase de l'en-tête de
// `reglages_notifs.dart`.
// ============================================================================

import 'package:droplet/core/services/reglages_notifs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t = DateTime(2026, 10, 8, 12);
  final dansUneHeure = t.add(const Duration(hours: 1));
  final ilYAUneHeure = t.subtract(const Duration(hours: 1));

  DecisionNotif d(
    Instantane i, {
    String id = 'c',
    bool groupe = false,
    bool mentionne = false,
  }) =>
      i.decider(
        conversationId: id,
        groupe: groupe,
        mentionne: mentionne,
        maintenant: t,
      );

  test('par défaut : tout passe, avec son, aperçu et bannière', () {
    final r = d(const Instantane());
    expect(r.afficher, isTrue);
    expect(r.sonore, isTrue);
    expect(r.apercu, isTrue);
    expect(r.banniere, isTrue);
  });

  test('sourdine permanente : silence', () {
    expect(d(const Instantane(sourdinesPermanentes: {'c'})).afficher, isFalse);
  });

  test('sourdine temporaire en cours : silence ; échue : tout passe', () {
    Instantane avec(DateTime fin) => Instantane(
          conversations: {'c': ReglagesConversation(sourdineJusqua: fin)},
        );
    expect(d(avec(dansUneHeure)).afficher, isFalse);
    expect(d(avec(ilYAUneHeure)).afficher, isTrue);
  });

  test('une mention traverse la sourdine d’un GROUPE, et sonne', () {
    const i = Instantane(sourdinesPermanentes: {'g'});
    final r = d(i, id: 'g', groupe: true, mentionne: true);
    expect(r.afficher, isTrue);
    expect(r.sonore, isTrue);
  });

  test('…mais pas celle d’un tête-à-tête', () {
    const i = Instantane(sourdinesPermanentes: {'c'});
    expect(d(i, mentionne: true).afficher, isFalse);
  });

  test('mentions seulement : le reste du groupe se tait', () {
    const i = Instantane(
      conversations: {'g': ReglagesConversation(mentionsSeulement: true)},
    );
    expect(d(i, id: 'g', groupe: true).afficher, isFalse);
    expect(d(i, id: 'g', groupe: true, mentionne: true).afficher, isTrue);
  });

  test('livraison discrète : affichée, sans son ni bannière', () {
    const i = Instantane(
      conversations: {'c': ReglagesConversation(discret: true)},
    );
    final r = d(i);
    expect(r.afficher, isTrue);
    expect(r.sonore, isFalse);
    expect(r.banniere, isFalse);
  });

  test('une mention n’est jamais discrète', () {
    const i = Instantane(
      conversations: {'g': ReglagesConversation(discret: true)},
    );
    expect(d(i, id: 'g', groupe: true, mentionne: true).sonore, isTrue);
  });

  test('aperçu : la conversation l’emporte sur le réglage général', () {
    const general = Instantane(apercuGeneral: false);
    expect(d(general).apercu, isFalse);
    const toujours = Instantane(
      apercuGeneral: false,
      conversations: {'c': ReglagesConversation(apercu: ApercuNotif.toujours)},
    );
    expect(d(toujours).apercu, isTrue);
    const jamais = Instantane(
      conversations: {'c': ReglagesConversation(apercu: ApercuNotif.jamais)},
    );
    expect(d(jamais).apercu, isFalse);
  });

  test('concentration : silence, sauf les mentions si on les laisse passer', () {
    final i = Instantane(concentrationJusqua: dansUneHeure);
    expect(d(i).afficher, isFalse);
    expect(d(i, groupe: true, mentionne: true).afficher, isTrue);
    final stricte = Instantane(
      concentrationJusqua: dansUneHeure,
      concentrationLaisseMentions: false,
    );
    expect(d(stricte, groupe: true, mentionne: true).afficher, isFalse);
  });

  test('concentration échue : sans effet', () {
    expect(d(Instantane(concentrationJusqua: ilYAUneHeure)).afficher, isTrue);
  });

  test('bannières coupées : la notification reste, la bannière non', () {
    final r = d(const Instantane(bannieres: false));
    expect(r.afficher, isTrue);
    expect(r.banniere, isFalse);
  });

  test('le miroir du push rend la même décision que l’original', () {
    final original = Instantane(
      conversations: {
        'g': const ReglagesConversation(mentionsSeulement: true, discret: true),
        'c': ReglagesConversation(
          sourdineJusqua: dansUneHeure,
          apercu: ApercuNotif.jamais,
        ),
      },
      sourdinesPermanentes: const {'p'},
      apercuGeneral: false,
      bannieres: false,
      concentrationJusqua: dansUneHeure,
      concentrationLaisseMentions: false,
    );
    final copie = Instantane.depuisJson(original.versJson());
    for (final id in ['g', 'c', 'p', 'autre']) {
      for (final groupe in [false, true]) {
        for (final mentionne in [false, true]) {
          final a = d(original, id: id, groupe: groupe, mentionne: mentionne);
          final b = d(copie, id: id, groupe: groupe, mentionne: mentionne);
          expect(
            [b.afficher, b.sonore, b.apercu, b.banniere],
            [a.afficher, a.sonore, a.apercu, a.banniere],
            reason: '$id groupe=$groupe mentionne=$mentionne',
          );
        }
      }
    }
  });
}
