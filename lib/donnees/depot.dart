// LE DÉPÔT — la mémoire de Droplet Web.
//
// Tout ce que l'interface affiche vient d'ici, et tout ce qu'elle fait passe
// par ici : envoyer, répondre, réagir, modifier, supprimer, épingler,
// archiver, créer un groupe, publier un statut… Le dépôt garde l'état,
// l'enregistre dans le navigateur, et confie au `Transport` ce qui doit
// partir. Les écrans écoutent ses changements (`ChangeNotifier`).
//
// Brancher les serveurs = remplacer `TransportDemo` par le vrai transport.
// Rien ici n'a besoin de changer.
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../web/navigateur.dart' show urlBlob, tailleImageDe;
import 'modeles.dart';
import 'transport.dart';

class Depot extends ChangeNotifier {
  Depot({required this.transport, required this.langue, this.demo = false});

  final Transport transport;
  final String langue;

  /// Vrai en démonstration : des discussions d'exemple au premier lancement,
  /// et un stockage séparé, pour ne jamais mélanger démo et vraies données.
  final bool demo;

  Profil profil = Profil();
  ReglagesWeb reglages = ReglagesWeb();
  final Map<String, Contact> contacts = {};
  final Map<String, Discussion> discussions = {};
  final Map<String, List<Message>> _messages = {};
  final List<Statut> statuts = [];
  final List<Appel> appels = [];

  /// Qui est en train d'écrire, par discussion.
  final Map<String, Set<String>> enTrainDecrire = {};

  /// La discussion ouverte : ses messages arrivent déjà lus.
  String? discussionOuverte;

  /// Le lien d'invitation du compte, donné par le téléphone.
  String? invitation;

  /// Vrai dès que le téléphone a envoyé quelque chose : tant que ce n'est
  /// pas le cas, un bandeau explique qu'il faut l'avoir à portée.
  bool telephoneVu = false;

  StreamSubscription<Paquet>? _abonnement;
  Timer? _sauvegarde;
  Timer? _menage;
  final _hasard = Random();

  String get _cle => demo ? 'droplet-web:demo:v1' : 'droplet-web:v1';

  // ══ DÉMARRAGE ════════════════════════════════════════════════════════

  Future<void> demarrer() async {
    _charger();
    if (demo && discussions.isEmpty) _semerDemo();
    _abonnement = transport.recus.listen(_recevoir);
    unawaited(transport.connecter());
    // Les messages éphémères expirés disparaissent d'eux-mêmes.
    _menage = Timer.periodic(const Duration(seconds: 15), (_) => _nettoyerEphemeres());
    notifyListeners();
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    _sauvegarde?.cancel();
    _menage?.cancel();
    super.dispose();
  }

  // ══ LECTURE ══════════════════════════════════════════════════════════

  List<Message> messages(String discussionId) => _messages[discussionId] ?? const [];

  Message? message(String id) {
    for (final liste in _messages.values) {
      for (final m in liste) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  Message? dernierMessage(String discussionId) {
    final l = messages(discussionId);
    for (var i = l.length - 1; i >= 0; i--) {
      if (l[i].type != TypeMessage.systeme || i == 0) return l[i];
    }
    return null;
  }

  DateTime dateActivite(Discussion d) => dernierMessage(d.id)?.date ?? d.creeeLe;

  /// Épinglées d'abord, puis la plus récente en haut — comme l'app.
  List<Discussion> discussionsTriees({bool archivees = false}) {
    final l = discussions.values.where((d) => d.archivee == archivees).toList();
    l.sort((a, b) {
      if (a.epinglee != b.epinglee) return a.epinglee ? -1 : 1;
      return dateActivite(b).compareTo(dateActivite(a));
    });
    return l;
  }

  int get nombreArchivees => discussions.values.where((d) => d.archivee).length;

  int get totalNonLus => discussions.values.where((d) => !d.archivee).fold(0, (t, d) => t + d.nonLus);

  String nom(String id) {
    if (id == kMoi) return profil.pseudo.isEmpty ? (langue == 'fr' ? 'Vous' : 'You') : profil.pseudo;
    return contacts[id]?.pseudo ?? id;
  }

  /// Le contact d'une discussion directe.
  Contact? interlocuteur(Discussion d) => d.estGroupe || d.membres.isEmpty ? null : contacts[d.membres.first];

  List<Message> importants() => [
        for (final l in _messages.values)
          for (final m in l)
            if (m.important && !m.supprime) m,
      ]..sort((a, b) => b.date.compareTo(a.date));

  List<Message> epingles(String discussionId) =>
      messages(discussionId).where((m) => m.epingle && !m.supprime).toList();

  List<Message> medias(String discussionId) => messages(discussionId)
      .where((m) => !m.supprime && (m.type == TypeMessage.image || m.type == TypeMessage.fichier))
      .toList()
      .reversed
      .toList();

  /// La recherche de la colonne de gauche : les messages qui contiennent le
  /// texte, du plus récent au plus ancien.
  List<Message> rechercher(String texte) {
    final q = texte.trim().toLowerCase();
    if (q.length < 2) return const [];
    return [
      for (final l in _messages.values)
        for (final m in l)
          if (!m.supprime && m.texte.toLowerCase().contains(q)) m,
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Statut> statutsDe(String auteurId) =>
      statuts.where((s) => s.auteurId == auteurId && !s.expire).toList()..sort((a, b) => a.date.compareTo(b.date));

  /// Les contacts qui ont publié, le plus récent d'abord.
  List<String> auteursStatuts() {
    final auteurs = <String, DateTime>{};
    for (final s in statuts.where((s) => !s.expire && s.auteurId != kMoi)) {
      final d = auteurs[s.auteurId];
      if (d == null || s.date.isAfter(d)) auteurs[s.auteurId] = s.date;
    }
    final l = auteurs.keys.toList()..sort((a, b) => auteurs[b]!.compareTo(auteurs[a]!));
    return l;
  }

  bool statutsTousVus(String auteurId) => statutsDe(auteurId).every((s) => s.vuPar.contains(kMoi));

  // ══ DISCUSSIONS ══════════════════════════════════════════════════════

  void ouvrir(String? discussionId) {
    discussionOuverte = discussionId;
    if (discussionId == null) return;
    final d = discussions[discussionId];
    if (d == null) return;
    if (d.nonLus > 0) {
      d.nonLus = 0;
      _changer();
      // Lu ici, lu sur le téléphone : il efface son badge et prévient
      // l'expéditeur (les coches bleues).
      if (!demo) unawaited(transport.demander({'t': 'lu', 'd': d.id}).then((_) {}, onError: (_) {}));
    }
  }

  // ══ LES PIÈCES RESTÉES SUR LE TÉLÉPHONE ══════════════════════════════

  /// Les pièces demandées au téléphone, en cours d'arrivée.
  final Set<String> _demandees = {};

  /// Les morceaux reçus : identifiant → (nombre attendu, morceaux).
  final Map<String, (int, List<Uint8List?>)> _morceaux = {};

  /// Vrai si le contenu de [m] est en route depuis le téléphone.
  bool enChargement(Message m) => _demandees.contains(m.id);

  /// Demande au téléphone le contenu d'une photo, d'un vocal, d'une vidéo
  /// ou d'un document. Il arrive en morceaux chiffrés (`appliquerLot`).
  void charger(Message m) {
    final p = m.piece;
    if (p == null || !p.distant || p.url.isNotEmpty || _demandees.contains(m.id) || demo) return;
    _demandees.add(m.id);
    notifyListeners();
    unawaited(transport.demander({'t': 'telecharger', 'id': m.id}).then((_) {}, onError: (_) {
      _demandees.remove(m.id);
      notifyListeners();
    }));
    // Sans réponse (téléphone éteint), on pourra redemander plus tard.
    Timer(const Duration(minutes: 2), () {
      if (_demandees.remove(m.id)) notifyListeners();
    });
  }

  void _morceauRecu(Map<String, dynamic> f) {
    final id = f['id'];
    final i = f['i'];
    final n = f['n'];
    if (id is! String || i is! int || n is! int || n <= 0 || i < 0 || i >= n || n > 64) return;
    final m = message(id);
    final p = m?.piece;
    if (m == null || p == null) return;
    final etat = _morceaux.putIfAbsent(id, () => (n, List<Uint8List?>.filled(n, null)));
    if (etat.$1 != n) return;
    try {
      etat.$2[i] = base64.decode(f['b64'] as String);
    } catch (_) {
      return;
    }
    if (etat.$2.any((x) => x == null)) return;
    _morceaux.remove(id);
    final tout = BytesBuilder(copy: false);
    for (final x in etat.$2) {
      tout.add(x!);
    }
    // Une adresse `blob:` : le contenu reste en mémoire, hors du stockage
    // limité du navigateur, le temps de la session.
    p.url = urlBlob(tout.takeBytes(), p.mime);
    _demandees.remove(id);
    if (m.type == TypeMessage.image && p.largeur == null) {
      unawaited(tailleImageDe(p.url).then((t) {
        if (t == null) return;
        p.largeur = t.$1;
        p.hauteur = t.$2;
        notifyListeners();
      }));
    }
    notifyListeners();
  }

  Discussion discussionAvec(String contactId) {
    for (final d in discussions.values) {
      if (!d.estGroupe && d.membres.length == 1 && d.membres.first == contactId) return d;
    }
    final c = contacts[contactId];
    final d = Discussion(
      // Compte lié : l'identifiant est celui que le téléphone comprend.
      id: demo ? _id('d') : 'p:$contactId',
      type: TypeDiscussion.directe,
      titre: c?.pseudo ?? contactId,
      membres: [contactId],
      couleur: c?.couleur ?? 0,
    );
    discussions[d.id] = d;
    _changer();
    return d;
  }

  Discussion creerGroupe(String titre, List<String> membres, {String description = ''}) {
    final d = Discussion(
      id: _id('g'),
      type: TypeDiscussion.groupe,
      titre: titre,
      membres: membres,
      couleur: _hasard.nextInt(palettesAvatar.length),
      description: description,
    );
    discussions[d.id] = d;
    _ajouter(Message(
      id: _id('s'),
      discussionId: d.id,
      auteurId: kMoi,
      type: TypeMessage.systeme,
      date: DateTime.now(),
      texte: 'groupe_cree',
    ));
    return d;
  }

  void epinglerDiscussion(Discussion d) {
    d.epinglee = !d.epinglee;
    _changer();
    _etatAuTelephone(d.id, 'epinglee', d.epinglee);
  }

  void archiver(Discussion d) {
    d.archivee = !d.archivee;
    if (d.archivee) d.epinglee = false;
    _changer();
    _etatAuTelephone(d.id, 'archivee', d.archivee);
  }

  void sourdine(Discussion d) {
    d.sourdine = !d.sourdine;
    _changer();
    _etatAuTelephone(d.id, 'sourdine', d.sourdine);
  }

  // ══ L'ÉTAT PARTAGÉ AVEC LE TÉLÉPHONE ═════════════════════════════════
  //
  // Comme WhatsApp : épingler, archiver, mettre en sourdine, bloquer,
  // épingler ou mettre un message en favori… se refait sur le téléphone.
  // Le changement est montré tout de suite ici, puis le téléphone renvoie
  // son état réel (`_appliquerEtat`), qui fait foi.

  /// Ce qu'on vient de changer ici et que le téléphone n'a peut-être pas
  /// encore appliqué : un instantané arrivé entre-temps ne doit pas le
  /// faire revenir en arrière une seconde (l'interrupteur qui « rebondit »).
  final Map<String, DateTime> _enAttente = {};
  bool _attend(String cle) {
    final t = _enAttente[cle];
    if (t == null) return false;
    if (DateTime.now().difference(t) < const Duration(seconds: 8)) return true;
    _enAttente.remove(cle);
    return false;
  }

  void _etatAuTelephone(String discussionId, String champ, Object valeur) {
    _enAttente['$discussionId|$champ'] = DateTime.now();
    unawaited(transport.demander({'t': 'etat', 'd': discussionId, 'champ': champ, 'valeur': valeur}));
  }

  void _etatMessageAuTelephone(String id, String champ, bool valeur) {
    _enAttente['m|$id|$champ'] = DateTime.now();
    unawaited(transport.demander({'t': 'msg_etat', 'id': id, 'champ': champ, 'valeur': valeur}));
  }

  /// Les discussions verrouillées sur le téléphone : jamais montrées ici.
  final Set<String> _verrouillees = {};
  DateTime _derniereResynchro = DateTime(0);

  /// L'instantané d'état envoyé par le téléphone (voir `miroir_appareils`).
  void _appliquerEtat(Map<String, dynamic> e) {
    final disc = (e['disc'] as Map?)?.cast<String, dynamic>() ?? const {};
    var manquante = false;
    for (final x in disc.entries) {
      final s = (x.value as Map?)?.cast<String, dynamic>();
      if (s == null) continue;
      if (s['v'] == true) {
        // Verrouillée sur le téléphone : elle disparaît du navigateur.
        _verrouillees.add(x.key);
        discussions.remove(x.key);
        _messages.remove(x.key);
        if (discussionOuverte == x.key) discussionOuverte = null;
        continue;
      }
      if (_verrouillees.remove(x.key)) manquante = true;
      final d = discussions[x.key];
      if (d == null) {
        manquante = true;
        continue;
      }
      if (!_attend('${d.id}|epinglee')) d.epinglee = s['e'] == true;
      if (!_attend('${d.id}|archivee')) d.archivee = s['a'] == true;
      if (!_attend('${d.id}|sourdine')) d.sourdine = s['s'] == true;
      if (!_attend('${d.id}|ephemere')) d.ephemereSecondes = (s['x'] as num?)?.toInt() ?? 0;
    }
    final epingles = <String>{
      for (final l in ((e['epingles'] as Map?)?.values ?? const <Object?>[]))
        if (l is List) ...l.whereType<String>(),
    };
    final importants = <String>{...((e['importants'] as List?) ?? const []).whereType<String>()};
    for (final liste in _messages.values) {
      for (final m in liste) {
        if (!_attend('m|${m.id}|epingle')) m.epingle = epingles.contains(m.id);
        if (!_attend('m|${m.id}|important')) m.important = importants.contains(m.id);
      }
    }
    final bloques = <String>{...((e['bloques'] as List?) ?? const []).whereType<String>()};
    for (final c in contacts.values) {
      if (!_attend('p:${c.id}|bloque')) c.bloque = bloques.contains(c.id);
    }
    final presence = (e['presence'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final x in presence.entries) {
      final c = contacts[x.key];
      final p = (x.value as Map?)?.cast<String, dynamic>();
      if (c == null || p == null) continue;
      c.enLigne = p['l'] == true;
      final vu = p['vu'];
      if (vu is String) c.vuA = DateTime.tryParse(vu)?.toLocal();
    }
    // Une discussion que le navigateur ne connaît pas (déverrouillée, ou
    // créée pendant qu'il était fermé) : il redemande tout, une fois par
    // minute au plus.
    if (manquante && DateTime.now().difference(_derniereResynchro) > const Duration(minutes: 1)) {
      _derniereResynchro = DateTime.now();
      unawaited(transport.demander({'t': 'synchro'}));
    }
    _changer();
  }

  /// Le téléphone a vu quelqu'un écrire.
  void _appliquerFrappe(Map<String, dynamic> f) {
    final d = f['d'];
    final a = f['a'];
    if (d is! String || a is! String || !discussions.containsKey(d)) return;
    enTrainDecrire.putIfAbsent(d, () => {}).add(a);
    notifyListeners();
    Timer(const Duration(seconds: 6), () {
      if (enTrainDecrire[d]?.remove(a) ?? false) notifyListeners();
    });
  }

  void marquerNonLue(Discussion d) {
    d.nonLus = d.nonLus > 0 ? 0 : 1;
    _changer();
  }

  void vider(Discussion d) {
    _messages[d.id] = [];
    _changer();
    unawaited(transport.demander({'t': 'discussion', 'd': d.id, 'op': 'vider'}));
  }

  void supprimerDiscussion(Discussion d) {
    discussions.remove(d.id);
    _messages.remove(d.id);
    if (discussionOuverte == d.id) discussionOuverte = null;
    _changer();
    unawaited(transport.demander({'t': 'discussion', 'd': d.id, 'op': 'supprimer'}));
  }

  /// Une opération de groupe, refaite par le téléphone (`g:` retiré).
  void _groupeAuTelephone(Discussion d, Map<String, dynamic> op) {
    if (!d.estGroupe) return;
    unawaited(transport.demander({'t': 'groupe', 'g': d.id.substring(2), ...op}));
  }

  void definirEphemere(Discussion d, int secondes) {
    d.ephemereSecondes = secondes;
    _etatAuTelephone(d.id, 'ephemere', secondes);
    _ajouter(Message(
      id: _id('s'),
      discussionId: d.id,
      auteurId: kMoi,
      type: TypeMessage.systeme,
      date: DateTime.now(),
      texte: 'ephemere:$secondes',
    ));
  }

  void renommer(Discussion d, String titre, {String? description}) {
    final change = titre != d.titre;
    final descriptionChange = description != null && description != d.description;
    d.titre = titre;
    if (description != null) d.description = description;
    if (change) _groupeAuTelephone(d, {'op': 'renommer', 'titre': titre});
    if (descriptionChange) _groupeAuTelephone(d, {'op': 'description', 'texte': description});
    if (change && d.estGroupe) {
      _systeme(d, 'renomme:$titre');
    } else {
      _changer();
    }
  }

  void retirerMembre(Discussion d, String membre) {
    d.membres = [...d.membres]..remove(membre);
    _groupeAuTelephone(d, {'op': 'retirer', 'membre': membre});
    _systeme(d, 'retire:$membre');
  }

  void ajouterMembres(Discussion d, List<String> membres) {
    final nouveaux = membres.where((m) => !d.membres.contains(m)).toList();
    d.membres = [...d.membres, ...nouveaux];
    if (nouveaux.isNotEmpty) _groupeAuTelephone(d, {'op': 'ajouter', 'membres': nouveaux});
    for (final m in nouveaux) {
      _systeme(d, 'ajoute:$m');
    }
    _changer();
  }

  void basculerAdmin(Discussion d, String membre) {
    d.admins = d.admins.contains(membre) ? ([...d.admins]..remove(membre)) : [...d.admins, membre];
    _changer();
  }

  void _systeme(Discussion d, String code) => _ajouter(Message(
        id: _id('s'),
        discussionId: d.id,
        auteurId: kMoi,
        type: TypeMessage.systeme,
        date: DateTime.now(),
        texte: code,
      ));

  void quitterGroupe(Discussion d) {
    d.quitte = true;
    _groupeAuTelephone(d, {'op': 'quitter'});
    d.admins = [...d.admins]..remove(kMoi);
    _ajouter(Message(
      id: _id('s'),
      discussionId: d.id,
      auteurId: kMoi,
      type: TypeMessage.systeme,
      date: DateTime.now(),
      texte: 'quitte',
    ));
  }

  void bloquer(Contact c) {
    c.bloque = !c.bloque;
    _changer();
    _etatAuTelephone('p:${c.id}', 'bloque', c.bloque);
  }

  void enregistrerBrouillon(Discussion d, String texte) {
    if (d.brouillon == texte) return;
    d.brouillon = texte;
    _planifierSauvegarde();
  }

  /// Un compte trouvé dans l'annuaire : il devient un contact ici, avec
  /// son vrai identifiant.
  Contact contactDistant(String peerId, String pseudo) {
    final c = contacts[peerId] ?? Contact(id: peerId, pseudo: pseudo, couleur: _couleurDe(peerId));
    contacts[peerId] = c;
    _changer();
    return c;
  }

  /// La couleur d'avatar d'un identifiant : toujours la même pour lui.
  int couleurDe(String id) => _couleurDe(id);

  int _couleurDe(String id) => id.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff) % palettesAvatar.length;

  Contact ajouterContact(String pseudo) {
    final c = Contact(id: _id('c'), pseudo: pseudo, couleur: _hasard.nextInt(palettesAvatar.length));
    contacts[c.id] = c;
    _changer();
    return c;
  }

  // ══ MESSAGES ═════════════════════════════════════════════════════════

  Message envoyerTexte(Discussion d, String texte, {String? reponseA}) {
    final m = Message(
      id: _id('m'),
      discussionId: d.id,
      auteurId: kMoi,
      type: TypeMessage.texte,
      date: DateTime.now(),
      texte: texte,
      reponseA: reponseA,
      statut: StatutMessage.envoi,
      expireLe: _expiration(d),
    );
    _partir(d, m);
    return m;
  }

  Message envoyerPiece(Discussion d, PieceJointe piece, TypeMessage type, {String legende = '', String? reponseA}) {
    final m = Message(
      id: _id('m'),
      discussionId: d.id,
      auteurId: kMoi,
      type: type,
      date: DateTime.now(),
      texte: legende,
      piece: piece,
      reponseA: reponseA,
      statut: StatutMessage.envoi,
      expireLe: _expiration(d),
    );
    _partir(d, m);
    return m;
  }

  void transferer(Message source, List<Discussion> vers) {
    for (final d in vers) {
      final m = Message(
        id: _id('m'),
        discussionId: d.id,
        auteurId: kMoi,
        type: source.type,
        date: DateTime.now(),
        texte: source.texte,
        piece: source.piece,
        transfere: true,
        statut: StatutMessage.envoi,
      );
      _partir(d, m);
    }
  }

  void modifier(Message m, String texte) {
    if (texte.trim().isEmpty || texte == m.texte) return;
    m.texte = texte;
    m.modifie = true;
    _changer();
    _diffuser(m.discussionId, TypePaquet.edition, {'id': m.id, 'texte': texte});
  }

  void supprimer(Message m, {required bool pourTous}) {
    if (pourTous) {
      m.supprime = true;
      m.texte = '';
      m.piece = null;
      m.reactions = {};
      _diffuser(m.discussionId, TypePaquet.suppression, {'id': m.id});
    } else {
      _messages[m.discussionId]?.removeWhere((x) => x.id == m.id);
    }
    _changer();
  }

  /// Une seule réaction par personne, comme l'app : la même retire, une
  /// autre remplace.
  void reagir(Message m, String emoji) {
    final avait = m.reactions.entries.where((e) => e.value.contains(kMoi)).map((e) => e.key).toList();
    final retirees = [...avait];
    for (final e in avait) {
      m.reactions[e] = [...m.reactions[e]!]..remove(kMoi);
      if (m.reactions[e]!.isEmpty) m.reactions.remove(e);
    }
    if (!avait.contains(emoji)) {
      m.reactions[emoji] = [...?m.reactions[emoji], kMoi];
    }
    _changer();
    // Le téléphone ne connaît pas « une réaction par personne » : on lui dit
    // laquelle retirer, puis laquelle ajouter (rien si c'était la même).
    _diffuser(m.discussionId, TypePaquet.reaction, {
      'id': m.id,
      'emoji': avait.contains(emoji) ? '' : emoji,
      'retirer': retirees,
    });
  }

  void epingler(Message m) {
    if (!m.epingle && epingles(m.discussionId).length >= 3) {
      epingles(m.discussionId).first.epingle = false;
    }
    m.epingle = !m.epingle;
    _changer();
    _etatMessageAuTelephone(m.id, 'epingle', m.epingle);
  }

  void marquerImportant(Message m) {
    m.important = !m.important;
    _changer();
    _etatMessageAuTelephone(m.id, 'important', m.important);
  }

  void reessayer(Message m) {
    final d = discussions[m.discussionId];
    if (d == null) return;
    m.statut = StatutMessage.envoi;
    _changer();
    _envoyerAuTransport(d, m);
  }

  final Map<String, DateTime> _frappeSignalee = {};

  /// On écrit ici : le téléphone prévient le contact (« en train
  /// d'écrire… »), au plus toutes les 2,5 s, comme l'app.
  void signalerFrappe(Discussion d) {
    final maintenant = DateTime.now();
    if (maintenant.difference(_frappeSignalee[d.id] ?? DateTime(0)) < const Duration(milliseconds: 2500)) return;
    _frappeSignalee[d.id] = maintenant;
    unawaited(transport.demander({'t': 'frappe', 'd': d.id}));
  }

  // ══ STATUTS, APPELS, PROFIL ══════════════════════════════════════════

  void publierStatut(String texte, int fond, {String? image}) {
    statuts.add(Statut(id: _id('st'), auteurId: kMoi, texte: texte, fond: fond, date: DateTime.now(), image: image));
    _changer();
    // En démonstration, les contacts passent voir.
    if (demo) {
      final s = statuts.last;
      for (final (i, c) in contacts.keys.take(3).indexed) {
        Timer(Duration(seconds: 3 + i * 4), () {
          if (!s.vuPar.contains(c)) s.vuPar.add(c);
          if (i == 0 && !s.aimePar.contains(c)) s.aimePar.add(c);
          _changer();
        });
      }
    }
  }

  void aimerStatut(Statut s) {
    s.aimePar.contains(kMoi) ? s.aimePar.remove(kMoi) : s.aimePar.add(kMoi);
    _changer();
  }

  /// Répondre à un statut : un message dans la discussion avec son auteur,
  /// qui cite le statut.
  void repondreStatut(Statut s, String texte) {
    final d = discussionAvec(s.auteurId);
    envoyerTexte(d, '« ${s.texte.isEmpty ? '📷' : s.texte} »\n$texte');
  }

  void marquerStatutVu(Statut s) {
    if (s.vuPar.contains(kMoi)) return;
    s.vuPar.add(kMoi);
    _changer();
  }

  void supprimerStatut(Statut s) {
    statuts.remove(s);
    _changer();
  }

  Appel enregistrerAppel(Discussion d, {required bool video, int duree = 0}) {
    final a = Appel(
      id: _id('a'),
      discussionId: d.id,
      video: video,
      entrant: false,
      date: DateTime.now(),
      dureeSecondes: duree,
    );
    appels.insert(0, a);
    _changer();
    return a;
  }

  void effacerAppels() {
    appels.clear();
    _changer();
  }

  void majProfil({String? pseudo, String? aPropos, String? photo, int? couleur, bool retirerPhoto = false}) {
    if (pseudo != null) profil.pseudo = pseudo;
    if (couleur != null) profil.couleur = couleur;
    if (aPropos != null) profil.aPropos = aPropos;
    if (photo != null) profil.photo = photo;
    if (retirerPhoto) profil.photo = null;
    _changer();
    // Le pseudo est celui du compte : c'est le téléphone qui l'annonce.
    if (pseudo != null && pseudo.trim().isNotEmpty) {
      unawaited(transport.demander({'t': 'profil', 'pseudo': pseudo.trim()}));
    }
  }

  void majReglages(void Function(ReglagesWeb r) changement) {
    changement(reglages);
    _changer();
  }

  /// « Se déconnecter » : ce navigateur oublie tout.
  void toutEffacer() {
    try {
      web.window.localStorage.removeItem(_cle);
    } catch (_) {}
    contacts.clear();
    discussions.clear();
    _messages.clear();
    statuts.clear();
    appels.clear();
    profil = Profil();
    reglages = ReglagesWeb();
    notifyListeners();
  }

  // ══ RÉCEPTION ════════════════════════════════════════════════════════

  void _recevoir(Paquet p) {
    final d = discussions[p.discussionId];
    if (d == null) return;
    switch (p.type) {
      case TypePaquet.message:
        enTrainDecrire[d.id]?.remove(p.auteurId);
        final m = Message(
          id: p.donnees['id'] as String,
          discussionId: d.id,
          auteurId: p.auteurId,
          type: TypeMessage.values.byName(p.donnees['type'] as String? ?? 'texte'),
          date: DateTime.now(),
          texte: p.donnees['texte'] as String? ?? '',
          expireLe: _expiration(d),
        );
        if (discussionOuverte != d.id) d.nonLus++;
        _ajouter(m);
        onMessageRecu?.call(d, m);
      case TypePaquet.accuse:
        final m = message(p.donnees['id'] as String);
        if (m == null) return;
        final s = StatutMessage.values.byName(p.donnees['statut'] as String);
        if (s.index > m.statut.index) {
          m.statut = s;
          _changer();
        }
      case TypePaquet.frappe:
        enTrainDecrire.putIfAbsent(d.id, () => {}).add(p.auteurId);
        notifyListeners();
        Timer(const Duration(seconds: 6), () {
          if (enTrainDecrire[d.id]?.remove(p.auteurId) ?? false) notifyListeners();
        });
      case TypePaquet.reaction:
        final m = message(p.donnees['id'] as String);
        if (m == null) return;
        final e = p.donnees['emoji'] as String;
        m.reactions[e] = [...?m.reactions[e], p.auteurId];
        _changer();
      case TypePaquet.edition:
        final m = message(p.donnees['id'] as String);
        if (m == null) return;
        m.texte = p.donnees['texte'] as String;
        m.modifie = true;
        _changer();
      case TypePaquet.suppression:
        final m = message(p.donnees['id'] as String);
        if (m == null) return;
        m.supprime = true;
        m.texte = '';
        m.piece = null;
        _changer();
      case TypePaquet.appel:
        break;
    }
  }

  // ══ LES LOTS DU TÉLÉPHONE ════════════════════════════════════════════

  /// Applique un lot envoyé par le téléphone (voir `miroir_appareils.dart`
  /// dans l'app) : contacts, discussions et messages, créés ou mis à jour.
  void appliquerLot(Map<String, dynamic> lot) {
    telephoneVu = true;
    final etat = lot['etat'];
    if (etat is Map) _appliquerEtat(etat.cast<String, dynamic>());
    final frappe = lot['frappe'];
    if (frappe is Map) _appliquerFrappe(frappe.cast<String, dynamic>());
    if (etat is Map || frappe is Map) {
      if (lot['messages'] == null && lot['discussions'] == null && lot['profil'] == null) return;
    }
    final f = lot['fichier'];
    if (f is Map) {
      _morceauRecu(f.cast<String, dynamic>());
      return;
    }
    final profilLot = lot['profil'];
    if (profilLot is Map) {
      final pseudo = profilLot['pseudo'];
      if (pseudo is String && pseudo.isNotEmpty) profil.pseudo = pseudo;
      final lien = profilLot['invitation'];
      if (lien is String && lien.startsWith('https://')) invitation = lien;
    }
    for (final c in (lot['contacts'] as List? ?? const [])) {
      if (c is! Map || c['id'] is! String) continue;
      final id = c['id'] as String;
      final pseudo = c['pseudo'] as String? ?? id;
      final x = contacts[id];
      if (x == null) {
        contacts[id] = Contact(id: id, pseudo: pseudo, couleur: _couleurDe(id));
      } else {
        x.pseudo = pseudo;
      }
    }
    final initial = lot.containsKey('profil');
    for (final d in (lot['discussions'] as List? ?? const [])) {
      if (d is! Map || d['id'] is! String) continue;
      final id = d['id'] as String;
      final membres = (d['membres'] as List? ?? const []).whereType<String>().toList();
      final titre = d['titre'] as String? ?? '';
      final x = discussions[id];
      if (x == null) {
        discussions[id] = Discussion(
          id: id,
          type: d['type'] == 'groupe' ? TypeDiscussion.groupe : TypeDiscussion.directe,
          titre: titre,
          membres: membres,
          couleur: _couleurDe(id),
          nonLus: (d['nonLus'] as int?) ?? 0,
          admins: (d['admins'] as List? ?? const []).whereType<String>().toList(),
          description: d['description'] as String? ?? '',
        );
      } else {
        if (titre.isNotEmpty) x.titre = titre;
        if (membres.isNotEmpty) x.membres = membres;
        if (d['admins'] is List) x.admins = (d['admins'] as List).whereType<String>().toList();
        if (d['description'] is String) x.description = d['description'] as String;
        if (d['nonLus'] is int && discussionOuverte != id) x.nonLus = d['nonLus'] as int;
      }
    }
    for (final m in (lot['messages'] as List? ?? const [])) {
      if (m is! Map || m['id'] is! String || m['d'] is! String) continue;
      final d = discussions[m['d'] as String];
      if (d == null) continue;
      final id = m['id'] as String;
      final statut = StatutMessage.values.asNameMap()[m['statut']] ?? StatutMessage.envoye;
      final existant = message(id);
      final reactions = _reactionsDu(m['reactions'], m['a'] == 'moi' ? d.membres : const [kMoi]);
      if (existant != null) {
        final texte = m['texte'] as String? ?? existant.texte;
        if (texte != existant.texte) {
          existant.texte = texte;
          existant.modifie = m['modifie'] == true || existant.modifie;
        }
        if (statut == StatutMessage.echec || statut.index > existant.statut.index) existant.statut = statut;
        existant.reactions = reactions;
        // Un fichier envoyé d'ici revient avec sa fiche : on garde notre
        // copie locale (déjà affichée).
        continue;
      }
      final auteur = m['a'] == 'moi' ? kMoi : (m['a'] as String? ?? '');
      final fiche = m['f'];
      PieceJointe? piece;
      var type = TypeMessage.texte;
      if (fiche is Map) {
        final mime = fiche['mime'] as String? ?? '';
        piece = PieceJointe(
          nom: fiche['nom'] as String? ?? 'fichier',
          mime: mime,
          taille: fiche['taille'] as int? ?? 0,
          url: '',
          distant: true,
        );
        type = mime.startsWith('image/') && !mime.contains('svg')
            ? TypeMessage.image
            : mime.startsWith('audio/')
                ? TypeMessage.vocal
                : TypeMessage.fichier;
      }
      final nouveau = Message(
        id: id,
        discussionId: d.id,
        auteurId: auteur,
        type: type,
        date: (DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now()).toLocal(),
        texte: m['texte'] as String? ?? '',
        piece: piece,
        reponseA: m['r'] as String?,
        statut: statut,
        modifie: m['modifie'] == true,
        reactions: reactions,
      );
      final liste = _messages[d.id] ??= [];
      liste.add(nouveau);
      if (liste.length > 1 && liste[liste.length - 2].date.isAfter(nouveau.date)) {
        liste.sort((a, b) => a.date.compareTo(b.date));
      }
      // Un message qui arrive en direct (pas l'historique d'une synchro).
      if (!initial && auteur != kMoi && DateTime.now().difference(nouveau.date).inMinutes < 5) {
        enTrainDecrire[d.id]?.remove(auteur);
        if (discussionOuverte != d.id) d.nonLus++;
        onMessageRecu?.call(d, nouveau);
      }
    }
    _changer();
  }

  /// Les réactions du téléphone (une liste d'émojis, sans leurs auteurs) :
  /// attribuées à l'autre côté de la discussion, pour le compte.
  static Map<String, List<String>> _reactionsDu(Object? brut, List<String> auteurs) {
    final r = <String, List<String>>{};
    if (brut is! List) return r;
    final qui = auteurs.isEmpty ? '·' : auteurs.first;
    for (final e in brut.whereType<String>()) {
      r[e] = [...?r[e], qui];
    }
    return r;
  }

  /// Prévenu à chaque message reçu (notifications du navigateur, son).
  void Function(Discussion d, Message m)? onMessageRecu;

  // ══ INTERNE ══════════════════════════════════════════════════════════

  void _partir(Discussion d, Message m) {
    if (d.archivee) d.archivee = false;
    d.brouillon = '';
    _ajouter(m);
    _envoyerAuTransport(d, m);
  }

  Future<void> _envoyerAuTransport(Discussion d, Message m) async {
    try {
      await transport.envoyer(
        Paquet(type: TypePaquet.message, discussionId: d.id, auteurId: kMoi, donnees: m.toJson()),
        destinataires: d.membres,
      );
      // En démonstration, « parti » suffit. Avec un compte lié, la coche
      // n'avance que quand le téléphone confirme l'envoi (lot suivant).
      if (demo && m.statut == StatutMessage.envoi) m.statut = StatutMessage.envoye;
    } catch (_) {
      m.statut = StatutMessage.echec;
    }
    _changer();
  }

  void _diffuser(String discussionId, TypePaquet type, Map<String, dynamic> donnees) {
    final d = discussions[discussionId];
    if (d == null) return;
    unawaited(transport.envoyer(
      Paquet(type: type, discussionId: d.id, auteurId: kMoi, donnees: donnees),
      destinataires: d.membres,
    ));
  }

  void _ajouter(Message m) {
    (_messages[m.discussionId] ??= []).add(m);
    _changer();
  }

  DateTime? _expiration(Discussion d) =>
      d.ephemereSecondes > 0 ? DateTime.now().add(Duration(seconds: d.ephemereSecondes)) : null;

  void _nettoyerEphemeres() {
    final maintenant = DateTime.now();
    var change = false;
    for (final l in _messages.values) {
      final avant = l.length;
      l.removeWhere((m) => m.expireLe != null && m.expireLe!.isBefore(maintenant));
      change |= l.length != avant;
    }
    final avant = statuts.length;
    statuts.removeWhere((s) => s.expire);
    if (change || statuts.length != avant) _changer();
  }

  String _id(String prefixe) =>
      '$prefixe${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_hasard.nextInt(1 << 20).toRadixString(36)}';

  void _changer() {
    notifyListeners();
    _planifierSauvegarde();
  }

  void _planifierSauvegarde() {
    _sauvegarde?.cancel();
    _sauvegarde = Timer(const Duration(milliseconds: 400), _enregistrer);
  }

  void _enregistrer() {
    final etat = {
      'profil': profil.toJson(),
      'reglages': reglages.toJson(),
      'contacts': contacts.values.map((c) => c.toJson()).toList(),
      'discussions': discussions.values.map((d) => d.toJson()).toList(),
      'messages': {
        for (final e in _messages.entries) e.key: e.value.map((m) => m.toJson()).toList(),
      },
      'statuts': statuts.map((s) => s.toJson()).toList(),
      'appels': appels.map((a) => a.toJson()).toList(),
      'invitation': invitation,
      'telephoneVu': telephoneVu,
    };
    try {
      web.window.localStorage.setItem(_cle, jsonEncode(etat));
    } catch (e) {
      debugPrint('Droplet Web : enregistrement impossible ($e)');
    }
  }

  void _charger() {
    try {
      final brut = web.window.localStorage.getItem(_cle);
      if (brut == null) return;
      final j = jsonDecode(brut) as Map<String, dynamic>;
      profil = Profil.fromJson((j['profil'] as Map).cast<String, dynamic>());
      reglages = ReglagesWeb.fromJson((j['reglages'] as Map).cast<String, dynamic>());
      for (final c in (j['contacts'] as List)) {
        final x = Contact.fromJson((c as Map).cast<String, dynamic>());
        contacts[x.id] = x;
      }
      for (final d in (j['discussions'] as List)) {
        final x = Discussion.fromJson((d as Map).cast<String, dynamic>());
        discussions[x.id] = x;
      }
      (j['messages'] as Map).forEach((k, v) {
        _messages[k as String] = (v as List).map((m) => Message.fromJson((m as Map).cast<String, dynamic>())).toList();
      });
      statuts.addAll((j['statuts'] as List).map((s) => Statut.fromJson((s as Map).cast<String, dynamic>())));
      appels.addAll((j['appels'] as List).map((a) => Appel.fromJson((a as Map).cast<String, dynamic>())));
      invitation = j['invitation'] as String?;
      telephoneVu = j['telephoneVu'] as bool? ?? false;
    } catch (e) {
      debugPrint('Droplet Web : lecture impossible ($e)');
    }
  }

  // ══ LA DÉMONSTRATION ═════════════════════════════════════════════════

  void _semerDemo() {
    final fr = langue == 'fr';
    final maintenant = DateTime.now();
    DateTime il(int minutes) => maintenant.subtract(Duration(minutes: minutes));

    profil = Profil(pseudo: fr ? 'Moi' : 'Me', aPropos: fr ? 'Joignable même sans réseau' : 'Reachable even offline', couleur: 0);

    Contact c(String id, String p, int couleur, {bool enLigne = false, String aPropos = ''}) =>
        contacts[id] = Contact(id: id, pseudo: p, couleur: couleur, enLigne: enLigne, aPropos: aPropos, vuA: il(12));
    c('amina', 'Amina', 0, enLigne: true, aPropos: fr ? 'Toujours au festival 🎶' : 'Still at the festival 🎶');
    c('papa', fr ? 'Papa' : 'Dad', 1, aPropos: fr ? 'Disponible' : 'Available');
    c('lina', 'Lina', 2, aPropos: '✈️');
    c('karim', 'Karim', 4, aPropos: fr ? 'Randonnée le dimanche' : 'Hiking on Sundays');
    c('maman', fr ? 'Maman' : 'Mom', 3);
    c('yao', 'Yao', 5, aPropos: fr ? 'Au travail' : 'At work');

    Discussion directe(String id, String contact, {bool epinglee = false, int nonLus = 0}) {
      final d = Discussion(
        id: id,
        type: TypeDiscussion.directe,
        titre: contacts[contact]!.pseudo,
        membres: [contact],
        couleur: contacts[contact]!.couleur,
        epinglee: epinglee,
        nonLus: nonLus,
        creeeLe: il(60 * 24 * 10),
      );
      return discussions[id] = d;
    }

    Discussion groupe(String id, String titre, List<String> membres, int couleur, String description) =>
        discussions[id] = Discussion(
          id: id,
          type: TypeDiscussion.groupe,
          titre: titre,
          membres: membres,
          couleur: couleur,
          description: description,
          creeeLe: il(60 * 24 * 30),
        );

    void m(String disc, String auteur, int ilYa, String texte,
        {StatutMessage statut = StatutMessage.lu, Map<String, List<String>>? reactions, String? reponseA, String? id, bool important = false}) {
      (_messages[disc] ??= []).add(Message(
        id: id ?? _id('m'),
        discussionId: disc,
        auteurId: auteur,
        type: TypeMessage.texte,
        date: il(ilYa),
        texte: texte,
        statut: statut,
        reactions: reactions,
        reponseA: reponseA,
        important: important,
      ));
    }

    final a = directe('d-amina', 'amina', epinglee: true, nonLus: 2);
    m(a.id, 'amina', 64, fr ? 'Tu es où ? Plus aucun réseau ici 😅' : 'Where are you? No signal at all here 😅', id: 'm-amina-1');
    m(a.id, kMoi, 63, fr ? 'Devant la grande scène. Tout est coupé, même la 4G' : 'In front of the main stage. Everything is down, even 4G');
    m(a.id, 'amina', 62, fr ? 'Ton message est passé par deux téléphones avant de m’arriver 🤯' : 'Your message hopped through two phones to reach me 🤯',
        reactions: {'😮': [kMoi]});
    m(a.id, kMoi, 61, fr ? 'C’est tout l’intérêt de Droplet' : 'That’s the whole point of Droplet', important: true);
    m(a.id, 'amina', 3, fr ? 'Je te vois, j’arrive !' : 'I can see you, coming!', reponseA: 'm-amina-1');
    m(a.id, 'amina', 2, fr ? 'Je suis à côté du stand bleu' : 'I’m next to the blue stand');

    final f = groupe('g-famille', fr ? 'Famille' : 'Family', ['papa', 'maman', 'lina'], 3,
        fr ? 'Les nouvelles de la maison' : 'News from home');
    m(f.id, 'maman', 140, fr ? 'Qui ramène le pain ?' : 'Who’s bringing bread?');
    m(f.id, kMoi, 138, fr ? 'Moi, je passe à la boulangerie' : 'Me, I’ll stop by the bakery', reactions: {'❤️': ['maman', 'papa']});
    m(f.id, 'papa', 95, fr ? 'On se retrouve chez mamie à 18 h' : 'Let’s meet at grandma’s at 6 pm');

    final p = directe('d-papa', 'papa');
    m(p.id, 'papa', 200, fr ? 'Tu as pu recharger ton téléphone ?' : 'Did you manage to charge your phone?');
    m(p.id, kMoi, 195, fr ? 'Oui, à 80 %. Je garde Droplet ouvert' : 'Yes, 80%. Keeping Droplet open');
    m(p.id, 'papa', 190, fr ? 'Bien reçu, merci 🙏' : 'Got it, thanks 🙏');

    final l = directe('d-lina', 'lina', nonLus: 1);
    m(l.id, kMoi, 60 * 26, fr ? 'Tu viens toujours samedi ?' : 'Still coming on Saturday?');
    m(l.id, 'lina', 60 * 25, fr ? 'Oui ! Je t’envoie l’adresse ce soir' : 'Yes! I’ll send you the address tonight');

    final r = groupe('g-rando', fr ? 'Club de randonnée' : 'Hiking club', ['karim', 'yao', 'lina'], 4,
        fr ? 'Sorties du dimanche. Pas de réseau là-haut : Droplet obligatoire.' : 'Sunday hikes. No signal up there: Droplet required.');
    m(r.id, kMoi, 60 * 50, fr ? 'Pas de réseau là-haut, pensez à installer Droplet avant de partir' : 'No signal up there, install Droplet before we leave');
    m(r.id, 'yao', 60 * 49, fr ? 'Fait ✅' : 'Done ✅');
    m(r.id, 'karim', 60 * 48, fr ? 'Départ 7 h au parking du col' : 'Leaving at 7 am from the pass car park');

    statuts
      ..add(Statut(id: 'st1', auteurId: 'amina', texte: fr ? 'Le festival sans réseau, mais pas sans nouvelles 🎶' : 'Festival without signal, not without news 🎶', fond: 0, date: il(50)))
      ..add(Statut(id: 'st2', auteurId: 'karim', texte: fr ? 'Sommet atteint ⛰️' : 'Summit reached ⛰️', fond: 3, date: il(180)))
      ..add(Statut(id: 'st3', auteurId: 'lina', texte: fr ? 'Bientôt les vacances ✈️' : 'Holidays soon ✈️', fond: 5, date: il(400), vuPar: [kMoi]));

    appels
      ..add(Appel(id: 'a1', discussionId: 'd-amina', video: false, entrant: true, date: il(30), dureeSecondes: 154))
      ..add(Appel(id: 'a2', discussionId: 'd-papa', video: true, entrant: false, date: il(60 * 5), dureeSecondes: 612))
      ..add(Appel(id: 'a3', discussionId: 'd-lina', video: false, entrant: true, date: il(60 * 27), manque: true))
      ..add(Appel(id: 'a4', discussionId: 'g-famille', video: true, entrant: true, date: il(60 * 50), dureeSecondes: 1320));

    _planifierSauvegarde();
  }
}

/// Les dégradés d'avatar — les mêmes teintes que l'app.
const List<List<Color>> palettesAvatar = [
  [Color(0xFFFF9F0A), Color(0xFFFF375F)],
  [Color(0xFF64D2FF), Color(0xFF0A84FF)],
  [Color(0xFFDA8FFF), Color(0xFF8E4DFF)],
  [Color(0xFF63E6BE), Color(0xFF30B0C7)],
  [Color(0xFFFFD60A), Color(0xFFFF9F0A)],
  [Color(0xFF5E5CE6), Color(0xFFBF5AF2)],
  [Color(0xFF30D158), Color(0xFF00C7BE)],
  [Color(0xFFFF6482), Color(0xFFFF2D55)],
];

/// Les fonds des statuts texte.
const List<List<Color>> fondsStatut = [
  [Color(0xFFFF375F), Color(0xFFFF9F0A)],
  [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
  [Color(0xFF30D158), Color(0xFF00C7BE)],
  [Color(0xFF1C1C1E), Color(0xFF3A3A3C)],
  [Color(0xFFBF5AF2), Color(0xFFFF375F)],
  [Color(0xFF64D2FF), Color(0xFF30B0C7)],
];
