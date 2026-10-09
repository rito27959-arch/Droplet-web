// LE TRANSPORT — la seule pièce qui parlera aux serveurs.
//
// Tout ce que le dépôt envoie ou reçoit passe par un `Transport` sous forme
// de `Paquet`. Deux implémentations :
//
//   • `TransportDemo` : un réseau simulé. Les messages partent, les coches
//     avancent, les contacts « écrivent » et répondent. C'est ce qui fait
//     vivre l'interface tant que les serveurs ne sont pas branchés.
//
//   • `TransportDroplet` (à écrire, étape 3 du plan) : le même contrat, mais
//     chiffré pour chaque appareil avec le protocole Signal, déposé dans la
//     boîte aux lettres, relevé par l'annuaire. Rien d'autre à changer : ni
//     le dépôt, ni les écrans.
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

enum TypePaquet { message, accuse, reaction, edition, suppression, frappe, appel }

enum EtatConnexion { connexion, connecte, horsLigne }

class Paquet {
  Paquet({
    required this.type,
    required this.discussionId,
    required this.auteurId,
    this.donnees = const {},
  });

  final TypePaquet type;
  final String discussionId;
  final String auteurId;
  final Map<String, dynamic> donnees;
}

abstract class Transport {
  /// Ce qui arrive des autres appareils.
  Stream<Paquet> get recus;

  /// L'état du lien avec le réseau, pour le bandeau « Connexion… ».
  ValueListenable<EtatConnexion> get etat;

  Future<void> connecter();

  /// Envoyer un paquet aux participants d'une discussion.
  Future<void> envoyer(Paquet paquet, {required List<String> destinataires});
}

/// Le réseau simulé de la démonstration.
class TransportDemo implements Transport {
  TransportDemo({required this.langue});

  final String langue;
  final _recus = StreamController<Paquet>.broadcast();
  final _etat = ValueNotifier(EtatConnexion.connexion);
  final _hasard = Random();

  @override
  Stream<Paquet> get recus => _recus.stream;

  @override
  ValueListenable<EtatConnexion> get etat => _etat;

  @override
  Future<void> connecter() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _etat.value = EtatConnexion.connecte;
  }

  @override
  Future<void> envoyer(Paquet paquet, {required List<String> destinataires}) async {
    await Future<void>.delayed(Duration(milliseconds: 250 + _hasard.nextInt(300)));
    if (paquet.type != TypePaquet.message || destinataires.isEmpty) return;
    final id = paquet.donnees['id'] as String;

    // Les coches : reçu, puis lu.
    _emettre(Duration(milliseconds: 500 + _hasard.nextInt(500)), Paquet(
      type: TypePaquet.accuse,
      discussionId: paquet.discussionId,
      auteurId: destinataires.first,
      donnees: {'id': id, 'statut': 'recu'},
    ));
    _emettre(Duration(milliseconds: 1600 + _hasard.nextInt(1200)), Paquet(
      type: TypePaquet.accuse,
      discussionId: paquet.discussionId,
      auteurId: destinataires.first,
      donnees: {'id': id, 'statut': 'lu'},
    ));

    // Une fois sur deux, quelqu'un répond — après avoir « écrit ».
    if (_hasard.nextBool()) {
      final qui = destinataires[_hasard.nextInt(destinataires.length)];
      final debut = Duration(milliseconds: 2400 + _hasard.nextInt(1200));
      _emettre(debut, Paquet(
        type: TypePaquet.frappe,
        discussionId: paquet.discussionId,
        auteurId: qui,
        donnees: const {'ecrit': true},
      ));
      _emettre(debut + Duration(milliseconds: 1800 + _hasard.nextInt(1500)), Paquet(
        type: TypePaquet.message,
        discussionId: paquet.discussionId,
        auteurId: qui,
        donnees: {
          'id': 'r${DateTime.now().microsecondsSinceEpoch}',
          'type': 'texte',
          'texte': _reponses[_hasard.nextInt(_reponses.length)],
        },
      ));
    }
  }

  List<String> get _reponses => langue == 'fr'
      ? const ['D’accord 👍', 'Bien reçu !', 'J’arrive dans 5 minutes', 'Super, merci 🙏', 'Ha ha 😄', 'On en parle tout à l’heure ?']
      : const ['Okay 👍', 'Got it!', 'Be there in 5 minutes', 'Great, thanks 🙏', 'Ha ha 😄', 'Talk later?'];

  void _emettre(Duration apres, Paquet p) {
    Timer(apres, () {
      if (!_recus.isClosed) _recus.add(p);
    });
  }
}
