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

import 'canal_telephone.dart';

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

/// Le transport du compte lié : la file de ce navigateur dans la boîte aux
/// lettres, et le canal chiffré avec le téléphone (`canal_telephone.dart`).
///
/// • Il relève la file en continu (attente longue de 20 s) : les lots du
///   téléphone — discussions, messages, coches — passent à [onLot].
/// • Un message écrit ici part au téléphone, qui l'envoie au contact avec
///   ses propres clés, puis le renvoie avec ses vraies coches.
/// • Au premier démarrage, il demande une synchro complète.
class TransportDroplet implements Transport {
  TransportDroplet({required this.canal, required this.verifier, required this.annuaire});

  /// L'adresse de l'annuaire (recherche par pseudo).
  final String annuaire;

  final CanalTelephone canal;

  /// Interroge l'annuaire : vrai si le navigateur est toujours lié.
  final Future<bool> Function() verifier;

  /// Vrai quand ce navigateur n'a encore rien reçu : il demande tout au
  /// téléphone en se connectant.
  bool Function() aBesoinDeSynchro = () => false;

  /// Les lots reçus du téléphone (branché par le dépôt).
  void Function(Map<String, dynamic> lot)? onLot;

  /// Le téléphone a refusé ce navigateur (déconnecté) : on revient au code.
  void Function()? onRefuse;

  /// Les contacts trouvés par recherche, que le téléphone ne connaît pas
  /// encore : leur pseudo et leur clé partent avec le premier message.
  final Map<String, ResultatRecherche> inconnus = {};

  final _recus = StreamController<Paquet>.broadcast();
  final _etat = ValueNotifier(EtatConnexion.connexion);
  Timer? _battement;
  bool _actif = false;

  @override
  Stream<Paquet> get recus => _recus.stream;

  @override
  ValueListenable<EtatConnexion> get etat => _etat;

  @override
  Future<void> connecter() async {
    if (_actif) return;
    _actif = true;
    _battement ??= Timer.periodic(const Duration(seconds: 60), (_) => unawaited(verifier()));
    if (aBesoinDeSynchro()) {
      unawaited(canal.demander({'t': 'synchro'}).then((_) {}, onError: (_) {}));
    }
    unawaited(_boucle());
  }

  Future<void> _boucle() async {
    var attente = 2;
    while (_actif) {
      try {
        final lots = await canal.relever();
        _etat.value = EtatConnexion.connecte;
        attente = 2;
        for (final l in lots) {
          onLot?.call(l);
        }
      } on AppareilRefuse {
        _actif = false;
        onRefuse?.call();
        return;
      } catch (_) {
        _etat.value = EtatConnexion.horsLigne;
        await Future<void>.delayed(Duration(seconds: attente));
        attente = (attente * 2).clamp(2, 30);
      }
    }
  }

  void arreter() {
    _actif = false;
    _battement?.cancel();
  }

  @override
  Future<void> envoyer(Paquet paquet, {required List<String> destinataires}) async {
    // Le téléphone gère pour l'instant les messages écrits ; les réactions,
    // modifications et « en train d'écrire » viendront avec lui.
    if (paquet.type != TypePaquet.message) return;
    final d = paquet.discussionId;
    if (!d.startsWith('p:') && !d.startsWith('g:')) {
      throw StateError('Discussion inconnue du téléphone');
    }
    final m = paquet.donnees;
    final inconnu = d.startsWith('p:') ? inconnus[d.substring(2)] : null;
    await canal.demander({
      't': 'envoyer',
      'd': d,
      'id': m['id'],
      'texte': m['texte'] ?? '',
      if (m['reponseA'] != null) 'r': m['reponseA'],
      if (inconnu != null) 'pseudo': inconnu.pseudo,
      if (inconnu?.cle != null) 'cle': inconnu!.cle,
    });
  }
}
