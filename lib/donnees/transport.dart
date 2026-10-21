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
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'canal_telephone.dart';
import 'multi_appareils.dart';
import 'modeles.dart' show PieceJointe;

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

  /// Une demande au téléphone (contenu d'un fichier, discussion lue…).
  /// Rien en démonstration.
  Future<void> demander(Map<String, dynamic> demande) async {}

  /// Un statut publié d'ici, confié au téléphone (rien en démonstration).
  Future<void> publierStatut({required String texte, required int couleur, PieceJointe? media, String type = 'texte'}) async {}
}

/// Le réseau simulé de la démonstration.
class TransportDemo extends Transport {
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
class TransportDroplet extends Transport {
  TransportDroplet({required this.canal, required this.verifier, required this.annuaire})
      : multi = MultiAppareils(canal: canal, annuaire: annuaire) {
    canal.autres = multi.recevoir;
  }

  /// Recevoir et envoyer sans le téléphone (voir `multi_appareils.dart`).
  final MultiAppareils multi;

  /// Les messages partis directement chez le contact (sans le téléphone) :
  /// leur coche « envoyé » ne dépend plus du téléphone.
  final Set<String> envoyesDirect = {};

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
  Future<void> demander(Map<String, dynamic> demande) => canal.demander(demande);

  /// Les morceaux d'un fichier envoyé au téléphone : 700 Ko d'octets, soit
  /// ~1,3 Mo une fois encodés et chiffrés (la boîte accepte 2 Mo).
  static const tailleMorceau = 700 * 1024;

  /// Au-delà, le téléphone ne pourrait pas l'envoyer par Internet.
  static const maxFichier = 16 * 1024 * 1024;

  /// La progression des fichiers qui partent (identifiant → 0..1).
  final progression = ValueNotifier<Map<String, double>>({});

  @override
  Future<void> envoyer(Paquet paquet, {required List<String> destinataires}) async {
    final d = paquet.discussionId;
    if (!d.startsWith('p:') && !d.startsWith('g:')) {
      throw StateError('Discussion inconnue du téléphone');
    }
    final m = paquet.donnees;
    switch (paquet.type) {
      case TypePaquet.reaction:
        await canal.demander({'t': 'reaction', 'id': m['id'], 'emoji': m['emoji'], 'retirer': m['retirer'] ?? const []});
        return;
      case TypePaquet.edition:
        await canal.demander({'t': 'modifier', 'id': m['id'], 'texte': m['texte']});
        return;
      case TypePaquet.suppression:
        await canal.demander({'t': 'supprimer', 'id': m['id']});
        return;
      case TypePaquet.message:
        break;
      default:
        return;
    }
    final inconnu = d.startsWith('p:') ? inconnus[d.substring(2)] : null;
    final piece = m['piece'];
    if (piece is Map && (piece['url'] as String? ?? '').isNotEmpty) {
      await _envoyerPiece(d, m, piece.cast<String, dynamic>(), inconnu);
      return;
    }
    // Le téléphone n'est plus indispensable : un contact dont l'app sait lire
    // un appareil lié reçoit le message directement, téléphone éteint ou non.
    if (d.startsWith('p:') && inconnu == null) {
      final direct = await multi
          .envoyer(contact: d.substring(2), id: m['id'] as String, texte: m['texte'] as String? ?? '', reponseA: m['reponseA'] as String?)
          .catchError((Object _) => false);
      if (direct) {
        envoyesDirect.add(m['id'] as String);
        return;
      }
    }
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

  /// Un statut : texte seul, ou photo / vidéo / vocal envoyés en morceaux
  /// (`but: statut`) — le téléphone le publie quand tout est arrivé.
  @override
  Future<void> publierStatut({required String texte, required int couleur, PieceJointe? media, String type = 'texte'}) async {
    if (media == null || media.url.isEmpty) {
      await canal.demander({'t': 'statut', 'texte': texte, 'fond': couleur});
      return;
    }
    final octets = await octetsDe(media.url);
    if (octets.isEmpty) throw StateError('Fichier illisible');
    if (octets.length > maxFichier) throw const FichierTropGros();
    final id = 'st${DateTime.now().microsecondsSinceEpoch}';
    final n = (octets.length / tailleMorceau).ceil();
    for (var i = 0; i < n; i++) {
      final fin = min((i + 1) * tailleMorceau, octets.length);
      await canal.demander({
        't': 'fichier',
        'but': 'statut',
        'id': id,
        'i': i,
        'n': n,
        'b64': base64.encode(octets.sublist(i * tailleMorceau, fin)),
        if (i == 0) ...{
          'k': type,
          'nom': media.nom,
          'mime': media.mime,
          'taille': octets.length,
          'texte': texte,
          'fond': couleur,
          if (media.dureeMs != null) 'ms': media.dureeMs,
        },
      });
      progression.value = {...progression.value, id: (i + 1) / n};
    }
    progression.value = {...progression.value}..remove(id);
  }

  /// Une photo, un vocal, une vidéo, un document : lu, découpé, et confié
  /// au téléphone morceau par morceau. Il l'envoie quand tout est arrivé.
  Future<void> _envoyerPiece(String d, Map<String, dynamic> m, Map<String, dynamic> piece, ResultatRecherche? inconnu) async {
    final octets = await octetsDe(piece['url'] as String);
    if (octets.isEmpty) throw StateError('Fichier illisible');
    if (octets.length > maxFichier) throw const FichierTropGros();
    final id = m['id'] as String;
    // Directement chez le contact quand son app sait lire un appareil lié :
    // la photo part même téléphone éteint. Le téléphone en reçoit ensuite
    // une copie pour son historique (`deja`), sans la renvoyer.
    if (d.startsWith('p:') && inconnu == null) {
      final direct = await multi
          .envoyerFichier(
            contact: d.substring(2),
            id: id,
            nom: piece['nom'] as String? ?? 'fichier',
            mime: piece['mime'] as String? ?? 'application/octet-stream',
            octets: octets,
            legende: m['texte'] as String?,
            reponseA: m['reponseA'] as String?,
            progres: (x) => progression.value = {...progression.value, id: x},
          )
          .catchError((Object _) => false);
      progression.value = {...progression.value}..remove(id);
      if (direct) {
        envoyesDirect.add(id);
        unawaited(_versTelephone(d, m, piece, octets, null, deja: true).catchError((Object _) {}));
        return;
      }
    }
    await _versTelephone(d, m, piece, octets, inconnu);
    progression.value = {...progression.value}..remove(id);
  }

  Future<void> _versTelephone(String d, Map<String, dynamic> m, Map<String, dynamic> piece, Uint8List octets, ResultatRecherche? inconnu, {bool deja = false}) async {
    final id = m['id'] as String;
    final n = (octets.length / tailleMorceau).ceil();
    for (var i = 0; i < n; i++) {
      final fin = min((i + 1) * tailleMorceau, octets.length);
      await canal.demander({
        't': 'fichier',
        'd': d,
        'id': id,
        'i': i,
        'n': n,
        'b64': base64.encode(octets.sublist(i * tailleMorceau, fin)),
        if (i == 0) ...{
          'nom': piece['nom'] ?? 'fichier',
          'mime': piece['mime'] ?? 'application/octet-stream',
          'taille': octets.length,
          'legende': m['texte'] ?? '',
          if (m['reponseA'] != null) 'r': m['reponseA'],
          if (inconnu != null) 'pseudo': inconnu.pseudo,
          if (inconnu?.cle != null) 'cle': inconnu!.cle,
          if (deja) 'deja': true,
        },
      });
      if (!deja) progression.value = {...progression.value, id: (i + 1) / n};
    }
  }
}

/// Le contenu d'une pièce, depuis son adresse `data:` ou `blob:`.
Future<Uint8List> octetsDe(String url) async {
  if (url.startsWith('data:')) {
    final virgule = url.indexOf(',');
    if (virgule < 0) return Uint8List(0);
    return base64.decode(url.substring(virgule + 1));
  }
  final r = await web.window.fetch(url.toJS).toDart;
  final tampon = await r.arrayBuffer().toDart;
  return tampon.toDart.asUint8List();
}

/// Plus de 16 Mo : le téléphone ne pourrait pas l'envoyer par Internet.
class FichierTropGros implements Exception {
  const FichierTropGros();
}
