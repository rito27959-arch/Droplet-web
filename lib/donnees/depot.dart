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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

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
    }
  }

  Discussion discussionAvec(String contactId) {
    for (final d in discussions.values) {
      if (!d.estGroupe && d.membres.length == 1 && d.membres.first == contactId) return d;
    }
    final c = contacts[contactId];
    final d = Discussion(
      id: _id('d'),
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
  }

  void archiver(Discussion d) {
    d.archivee = !d.archivee;
    if (d.archivee) d.epinglee = false;
    _changer();
  }

  void sourdine(Discussion d) {
    d.sourdine = !d.sourdine;
    _changer();
  }

  void marquerNonLue(Discussion d) {
    d.nonLus = d.nonLus > 0 ? 0 : 1;
    _changer();
  }

  void vider(Discussion d) {
    _messages[d.id] = [];
    _changer();
  }

  void supprimerDiscussion(Discussion d) {
    discussions.remove(d.id);
    _messages.remove(d.id);
    if (discussionOuverte == d.id) discussionOuverte = null;
    _changer();
  }

  void definirEphemere(Discussion d, int secondes) {
    d.ephemereSecondes = secondes;
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
    d.titre = titre;
    if (description != null) d.description = description;
    if (change && d.estGroupe) {
      _systeme(d, 'renomme:$titre');
    } else {
      _changer();
    }
  }

  void retirerMembre(Discussion d, String membre) {
    d.membres = [...d.membres]..remove(membre);
    _systeme(d, 'retire:$membre');
  }

  void ajouterMembres(Discussion d, List<String> membres) {
    final nouveaux = membres.where((m) => !d.membres.contains(m)).toList();
    d.membres = [...d.membres, ...nouveaux];
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
  }

  void enregistrerBrouillon(Discussion d, String texte) {
    if (d.brouillon == texte) return;
    d.brouillon = texte;
    _planifierSauvegarde();
  }

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
    for (final e in avait) {
      m.reactions[e] = [...m.reactions[e]!]..remove(kMoi);
      if (m.reactions[e]!.isEmpty) m.reactions.remove(e);
    }
    if (!avait.contains(emoji)) {
      m.reactions[emoji] = [...?m.reactions[emoji], kMoi];
    }
    _changer();
    _diffuser(m.discussionId, TypePaquet.reaction, {'id': m.id, 'emoji': emoji});
  }

  void epingler(Message m) {
    if (!m.epingle && epingles(m.discussionId).length >= 3) {
      epingles(m.discussionId).first.epingle = false;
    }
    m.epingle = !m.epingle;
    _changer();
  }

  void marquerImportant(Message m) {
    m.important = !m.important;
    _changer();
  }

  void reessayer(Message m) {
    final d = discussions[m.discussionId];
    if (d == null) return;
    m.statut = StatutMessage.envoi;
    _changer();
    _envoyerAuTransport(d, m);
  }

  void signalerFrappe(Discussion d) {
    // Le vrai transport préviendra les autres appareils ; la démo n'en a
    // pas besoin.
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
      if (m.statut == StatutMessage.envoi) m.statut = StatutMessage.envoye;
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
