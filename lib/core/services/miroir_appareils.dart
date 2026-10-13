// ============================================================================
// LE MIROIR DES APPAREILS LIÉS — ce qui fait vivre Droplet Web.
// ----------------------------------------------------------------------------
// Le téléphone reste le seul à détenir l'identité du compte et les sessions
// de chiffrement avec les contacts. Droplet Web n'en a pas besoin : il
// parle au TÉLÉPHONE, par un canal chiffré qui n'est qu'à eux deux.
//
//   clé du canal = HKDF-SHA256( X25519(clé d'identité du téléphone,
//                                      clé publique du navigateur),
//                               sel « droplet-mesh », info « droplet-appareil-v1 » )
//   chiffrement  = AES-256-GCM, nonce de 12 octets, étiquette de 16 octets
//                  collée à la fin du chiffré
//
// Le canal passe par la boîte aux lettres : chaque appareil lié y a sa
// propre file, à son identifiant d'appareil (déclarée à la liaison, voir
// `AppareilsLies.lier`). Le serveur ne voit que des blobs.
//
// ── Téléphone → navigateur : des « lots » ───────────────────────────
//
//   dépôt : to = <appareil>, from = <moi>, payload = {"w":1,"c":…,"n":…}
//   clair :
//     {"v":1,
//      "profil":      {"pseudo":…, "invitation":…}         (synchro)
//      "contacts":    [{"id":peerId, "pseudo":…}],
//      "discussions": [{"id":"p:<peerId>"|"g:<groupId>", "type":"directe"|"groupe",
//                       "titre":…, "membres":[peerId…], "nonLus":n}],
//      "messages":    [{"id":…, "d":<discussion>, "a":<auteur>|"moi",
//                       "texte":…, "date":ISO-8601, "statut":"envoi"|"envoye"|"recu"|"lu"|"echec",
//                       "r":<réponse à>}]}
//
// Une synchro complète part à la liaison (et à la demande du navigateur) :
// les 40 discussions les plus récentes, leurs 80 derniers messages. Ensuite,
// chaque message nouveau ou modifié (envoyé, reçu, coches) part dans un
// petit lot, regroupé sur 350 ms.
//
// ── Navigateur → téléphone : des demandes ───────────────────────────
//
//   dépôt : to = <moi>, from = <appareil>, payload = {"l":1,"c":…,"n":…}
//   clair : {"t":"envoyer", "d":<discussion>, "id":…, "texte":…, "r":…,
//            "pseudo":…, "cle":…}       (pseudo/clé : contact trouvé par
//                                         recherche, inconnu du téléphone)
//           {"t":"synchro"}
//
//           {"t":"fichier", "d", "id", "nom", "mime", "taille", "legende",
//            "r", "i", "n", "b64"}   un fichier écrit sur le web, en n
//                                    morceaux de 700 Ko au plus (la boîte
//                                    accepte 2 Mo par dépôt)
//           {"t":"telecharger", "id"}  le navigateur veut le contenu d'un
//                                    fichier (photo, vocal, vidéo…)
//           {"t":"lu", "d"}          la discussion a été lue sur le web
//           {"t":"reaction", "id", "emoji", "retirer":[…]}
//           {"t":"modifier", "id", "texte"}
//           {"t":"supprimer", "id"}
//
//   Le téléphone répond à « telecharger » par des lots
//     {"v":1, "fichier":{"id", "i", "n", "b64"}}
//   et chaque message de fichier porte, dans ses lots ordinaires,
//     "f": {"id", "nom", "mime", "taille"}.
//   Chaque lot donne aussi le nombre de non-lus de ses discussions : lire
//   sur le téléphone efface le badge du web, et inversement.
//
// Le message écrit sur le web garde SON identifiant : il revient dans le
// lot suivant avec ses vraies coches, et le navigateur le reconnaît.
//
// ⚠️ CE QUE CE MODÈLE NE FAIT PAS (encore) : le navigateur n'envoie rien
// quand le téléphone est éteint — sa demande attend dans la boîte, et part
// au réveil du téléphone. C'est le modèle de WhatsApp Web avant 2021.
// L'étape suivante (des sessions de chiffrement propres à chaque appareil)
// rendra le navigateur autonome.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../models/mesh_message.dart';
import '../repositories/mesh_repository.dart';
import 'appareils_lies.dart';
import 'crypto_service.dart';
import 'invitation.dart';
import 'qr_code_exchange.dart';
import 'storage_service.dart';

typedef EnvoiDepuisAppareil = Future<void> Function(String cible, String texte, {String? id, String? reponseA});

/// Un fichier écrit sur le web, à envoyer depuis le téléphone.
typedef FichierDepuisAppareil = Future<void> Function({
  String? cible,
  String? groupe,
  required String id,
  required String nom,
  required String mime,
  required Uint8List octets,
  String? legende,
  String? reponseA,
});

/// Ce que le web peut faire d'autre, et que le téléphone refait à
/// l'identique (lectures, réactions, modifications, suppressions).
class ActionsMiroir {
  const ActionsMiroir({required this.lire, required this.lireGroupe, required this.reagir, required this.modifier, required this.supprimer});

  final Future<void> Function(String peerId) lire;
  final Future<void> Function(String groupId) lireGroupe;
  final void Function(String messageId, String emoji) reagir;
  final void Function(String messageId, String texte) modifier;
  final void Function(String messageId) supprimer;
}

/// Un fichier qui arrive du web morceau par morceau.
class _Assemblage {
  _Assemblage(this.n) : morceaux = List<Uint8List?>.filled(n, null);
  final int n;
  final List<Uint8List?> morceaux;
  final DateTime debut = DateTime.now();
  Map<String, dynamic> entete = const {};
  bool get complet => morceaux.every((m) => m != null);
}

class MiroirAppareils {
  MiroirAppareils(this._repo, {required this.envoyer, required this.envoyerGroupe, required this.envoyerFichier, required this.actions}) {
    actuel = this;
  }

  /// L'instance vivante (une seule : celle du `MeshNotifier`).
  static MiroirAppareils? actuel;

  final MeshRepository _repo;
  final EnvoiDepuisAppareil envoyer;
  final EnvoiDepuisAppareil envoyerGroupe;
  final FichierDepuisAppareil envoyerFichier;
  final ActionsMiroir actions;

  /// Les morceaux d'un fichier : 700 Ko d'octets, soit ~1,3 Mo une fois
  /// encodés et chiffrés — sous les 2 Mo d'un dépôt.
  static const tailleMorceau = 700 * 1024;

  /// Au-delà, un fichier ne passe pas par Internet (`FichierEnLigne`).
  static const maxFichier = 16 * 1024 * 1024;

  final Map<String, _Assemblage> _assemblages = {};

  static const _maxDiscussions = 40;
  static const _maxParDiscussion = 80;
  static const _maxParLot = 300;

  final Map<String, String> _empreintes = {};
  final Map<String, SecretKey> _cles = {};
  bool _amorce = false;
  Timer? _minuteur;
  List<MeshMessage> _dernier = const [];

  // ── Ce que le téléphone envoie ─────────────────────────────────────

  /// Appelé à chaque changement de la liste des messages.
  void surMessages(List<MeshMessage> tous) {
    _dernier = tous;
    if (AppareilsLies.liste().every((a) => a.cle == null)) {
      _amorce = false;
      return;
    }
    if (!_amorce) {
      // Premier passage : ce qui existe déjà a été synchronisé à la
      // liaison. On ne renvoie que ce qui changera désormais.
      for (final m in tous) {
        _empreintes[m.id] = _empreinte(m);
      }
      _amorce = true;
      return;
    }
    _minuteur?.cancel();
    _minuteur = Timer(const Duration(milliseconds: 350), () => unawaited(_pousserChangements()));
  }

  Future<void> _pousserChangements() async {
    final appareils = _appareils();
    if (appareils.isEmpty) return;
    final changes = <MeshMessage>[];
    for (final m in _dernier) {
      final e = _empreinte(m);
      if (_empreintes[m.id] != e) {
        _empreintes[m.id] = e;
        changes.add(m);
      }
    }
    if (changes.isEmpty) return;
    final lot = _lot(changes);
    if (lot == null) return;
    for (final a in appareils) {
      await _deposer(a, lot);
    }
  }

  /// Une synchro complète vers [appareil] : les discussions récentes et
  /// leurs derniers messages, en plusieurs lots si besoin.
  Future<void> synchroniser(AppareilLie appareil) async {
    if (appareil.cle == null) return;
    final moi = _repo.myId;
    final parDiscussion = <String, List<MeshMessage>>{};
    for (final m in _dernier.isEmpty ? StorageService.getMessages() : _dernier) {
      final d = _discussionDe(m, moi);
      if (d != null) (parDiscussion[d] ??= []).add(m);
    }
    final recentes = parDiscussion.entries.toList()
      ..sort((a, b) => _plusRecent(b.value).compareTo(_plusRecent(a.value)));
    final choisis = <MeshMessage>[];
    for (final e in recentes.take(_maxDiscussions)) {
      final l = [...e.value]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      choisis.addAll(l.length > _maxParDiscussion ? l.sublist(l.length - _maxParDiscussion) : l);
    }

    String? invitation;
    try {
      invitation = InvitationDroplet.lien(await QrCodeExchange.generateQrData());
    } catch (_) {}
    final profil = {'pseudo': StorageService.currentUser?.pseudo ?? '', 'invitation': ?invitation};

    if (choisis.isEmpty) {
      await _deposer(appareil, {'v': 1, 'profil': profil});
      return;
    }
    for (var i = 0; i < choisis.length; i += _maxParLot) {
      final morceau = choisis.sublist(i, (i + _maxParLot).clamp(0, choisis.length));
      final lot = _lot(morceau, nonLus: i == 0);
      if (lot == null) continue;
      if (i == 0) lot['profil'] = profil;
      await _deposer(appareil, lot);
    }
    for (final m in _dernier) {
      _empreintes[m.id] = _empreinte(m);
    }
    _amorce = true;
  }

  // ── Ce que le navigateur demande ───────────────────────────────────

  /// Une demande d'un appareil lié (`l: 1`). Rend `true` si elle a été
  /// reconnue — quoi qu'il en advienne, le dépôt peut être acquitté.
  Future<bool> recevoir(String de, Map<String, dynamic> parsed) async {
    if (parsed['l'] != 1) return false;
    final appareil = _appareils().where((a) => a.id == de).firstOrNull;
    if (appareil == null) return true; // appareil retiré, ou inconnu : ignoré
    final clair = await _dechiffrer(appareil, parsed['c'] as String?, parsed['n'] as String?);
    if (clair == null) return true;
    try {
      final j = (jsonDecode(clair) as Map).cast<String, dynamic>();
      switch (j['t']) {
        case 'synchro':
          await synchroniser(appareil);
        case 'fichier':
          await _morceauRecu(j);
        case 'telecharger':
          await _envoyerContenu(appareil, j['id'] as String? ?? '');
        case 'lu':
          final d = j['d'] as String? ?? '';
          if (d.startsWith('p:')) await actions.lire(d.substring(2));
          if (d.startsWith('g:')) await actions.lireGroupe(d.substring(2));
        case 'reaction':
          final id = j['id'] as String? ?? '';
          final m = _dernier.where((x) => x.id == id).firstOrNull;
          if (m == null) return true;
          // Le web garde une réaction par personne : il dit laquelle il
          // remplace, le téléphone la retire avant d'ajouter la nouvelle.
          for (final e in (j['retirer'] as List? ?? const []).whereType<String>()) {
            if (m.reactions.contains(e)) actions.reagir(id, e);
          }
          final emoji = j['emoji'] as String? ?? '';
          if (emoji.isNotEmpty) actions.reagir(id, emoji);
        case 'modifier':
          final texte = (j['texte'] as String? ?? '').trim();
          if (texte.isNotEmpty && texte.length <= 20000) actions.modifier(j['id'] as String? ?? '', texte);
        case 'supprimer':
          actions.supprimer(j['id'] as String? ?? '');
        case 'envoyer':
          final d = j['d'] as String? ?? '';
          final texte = (j['texte'] as String? ?? '').trim();
          final id = j['id'] as String?;
          if (texte.isEmpty || texte.length > 20000) return true;
          if (_dernier.any((m) => m.id == id)) return true; // déjà parti
          if (d.startsWith('p:')) {
            final peer = d.substring(2);
            _apprendreContact(peer, j['pseudo'] as String?, j['cle'] as String?);
            await envoyer(peer, texte, id: id, reponseA: j['r'] as String?);
          } else if (d.startsWith('g:')) {
            await envoyerGroupe(d.substring(2), texte, id: id, reponseA: j['r'] as String?);
          }
      }
    } catch (e) {
      debugPrint('[Miroir] demande illisible : $e');
    }
    return true;
  }

  /// Un morceau d'un fichier écrit sur le web. Le dernier arrivé, le
  /// téléphone envoie le fichier comme s'il avait été choisi ici : même
  /// identifiant, même légende, même réponse.
  Future<void> _morceauRecu(Map<String, dynamic> j) async {
    final id = j['id'] as String? ?? '';
    final n = j['n'] as int? ?? 0;
    final i = j['i'] as int? ?? -1;
    final taille = j['taille'] as int? ?? 0;
    if (id.isEmpty || n <= 0 || i < 0 || i >= n || taille > maxFichier || n > maxFichier ~/ tailleMorceau + 2) return;
    if (_dernier.any((m) => m.id == id)) return; // déjà parti
    // Les assemblages abandonnés (navigateur fermé en cours d'envoi) ne
    // restent pas en mémoire.
    _assemblages.removeWhere((_, a) => DateTime.now().difference(a.debut) > const Duration(minutes: 15));
    final a = _assemblages.putIfAbsent(id, () => _Assemblage(n));
    if (a.n != n) return;
    try {
      a.morceaux[i] = base64Decode(j['b64'] as String? ?? '');
    } catch (_) {
      return;
    }
    if (i == 0 || a.entete.isEmpty) a.entete = j;
    if (!a.complet) return;
    _assemblages.remove(id);
    final octets = BytesBuilder(copy: false);
    for (final m in a.morceaux) {
      octets.add(m!);
    }
    final e = a.entete;
    final d = e['d'] as String? ?? '';
    if (d.startsWith('p:')) _apprendreContact(d.substring(2), e['pseudo'] as String?, e['cle'] as String?);
    final legende = (e['legende'] as String? ?? '').trim();
    await envoyerFichier(
      cible: d.startsWith('p:') ? d.substring(2) : null,
      groupe: d.startsWith('g:') ? d.substring(2) : null,
      id: id,
      nom: (e['nom'] as String? ?? 'fichier').replaceAll(RegExp(r'[/\\]'), '_'),
      mime: e['mime'] as String? ?? 'application/octet-stream',
      octets: octets.takeBytes(),
      legende: legende.isEmpty ? null : legende,
      reponseA: e['r'] as String?,
    );
  }

  /// Le contenu d'un fichier, demandé par le web : lu sur le disque du
  /// téléphone, envoyé en morceaux chiffrés dans la file de ce navigateur.
  Future<void> _envoyerContenu(AppareilLie appareil, String id) async {
    final m = _dernier.where((x) => x.id == id || x.fileId == id).firstOrNull;
    if (m == null || m.fileName == null) return;
    final chemin = await StorageService.getSharedFilePath(m.fileId ?? m.id, m.fileName!);
    if (chemin == null) return;
    final octets = await File(chemin).readAsBytes();
    if (octets.length > maxFichier) return;
    final n = (octets.length / tailleMorceau).ceil().clamp(1, 1 << 20);
    for (var i = 0; i < n; i++) {
      final fin = ((i + 1) * tailleMorceau).clamp(0, octets.length);
      await _deposer(appareil, {
        'v': 1,
        'fichier': {'id': id, 'i': i, 'n': n, 'b64': base64Encode(octets.sublist(i * tailleMorceau, fin))},
      });
    }
  }

  /// Un contact trouvé sur le web par son pseudo : le téléphone apprend sa
  /// clé et son nom avant de lui écrire.
  void _apprendreContact(String peerId, String? pseudo, String? cle) {
    if (cle != null && cle.isNotEmpty) _repo.apprendreCleMailbox(peerId, cle);
    if (pseudo == null || pseudo.trim().isEmpty) return;
    final fiche = StorageService.getPeerRecord(peerId);
    if (fiche == null) {
      unawaited(StorageService.upsertPeer(PeerRecord(
        peerId: peerId,
        pseudo: pseudo.trim(),
        lastSeen: DateTime.now(),
        publicKey: cle,
        transports: const ['tor'],
      )));
    } else if (fiche.pseudo.isEmpty || fiche.pseudo == peerId) {
      unawaited(StorageService.upsertPeer(fiche.copyWith(pseudo: pseudo.trim())));
    }
  }

  // ── La mise en forme ────────────────────────────────────────────────

  Map<String, dynamic>? _lot(List<MeshMessage> messages, {bool nonLus = false}) {
    final moi = _repo.myId;
    final contacts = <String, Map<String, dynamic>>{};
    final discussions = <String, Map<String, dynamic>>{};
    final dtos = <Map<String, dynamic>>[];
    for (final m in messages) {
      final d = _discussionDe(m, moi);
      if (d == null) continue;
      final dto = _message(m, d, moi);
      if (dto == null) continue;
      dtos.add(dto);
      discussions.putIfAbsent(d, () => _discussion(d, moi, contacts));
      if (m.senderId != null && m.senderId != moi) {
        contacts.putIfAbsent(m.senderId!, () => {'id': m.senderId, 'pseudo': _pseudo(m.senderId!, m)});
      }
    }
    if (dtos.isEmpty) return null;
    // Les non-lus voyagent avec chaque lot : une discussion lue sur le
    // téléphone perd aussi son badge sur le web.
    for (final e in discussions.entries) {
      e.value['nonLus'] = _nonLus(e.key, moi);
    }
    return {
      'v': 1,
      'contacts': contacts.values.toList(),
      'discussions': discussions.values.toList(),
      'messages': dtos,
    };
  }

  static String? _discussionDe(MeshMessage m, String moi) {
    if (m.groupId != null) return 'g:${m.groupId}';
    final peer = m.senderId == moi ? m.targetId : m.senderId;
    if (peer == null || peer.isEmpty) return null; // diffusion mesh
    return 'p:$peer';
  }

  Map<String, dynamic> _discussion(String d, String moi, Map<String, Map<String, dynamic>> contacts) {
    if (d.startsWith('g:')) {
      final g = StorageService.getGroup(d.substring(2));
      final membres = (g?.members ?? const [])
          .where((x) => x.removedAt == null && x.peerId != moi)
          .map((x) => x.peerId)
          .toList();
      for (final p in membres) {
        contacts.putIfAbsent(p, () => {'id': p, 'pseudo': _pseudo(p, null)});
      }
      return {'id': d, 'type': 'groupe', 'titre': g?.name ?? 'Groupe', 'membres': membres};
    }
    final peer = d.substring(2);
    contacts.putIfAbsent(peer, () => {'id': peer, 'pseudo': _pseudo(peer, null)});
    return {'id': d, 'type': 'directe', 'titre': _pseudo(peer, null), 'membres': [peer]};
  }

  static String _pseudo(String peerId, MeshMessage? m) {
    final fiche = StorageService.getPeerRecord(peerId)?.pseudo;
    if (fiche != null && fiche.isNotEmpty && fiche != peerId) return fiche;
    if (m != null && m.senderId == peerId && m.authorPseudo.isNotEmpty && m.authorPseudo != peerId) return m.authorPseudo;
    return peerId.length > 8 ? '${peerId.substring(0, 8)}…' : peerId;
  }

  int _nonLus(String d, String moi) => _dernier
      .where((m) => _discussionDe(m, moi) == d && m.senderId != moi && m.readAt == null)
      .length
      .clamp(0, 99);

  static Map<String, dynamic>? _message(MeshMessage m, String d, String moi) {
    if (m.type == 'appel' || m.type == 'call' || m.type == 'mesh' || m.type == 'warning') return null;
    var texte = m.content;
    Map<String, dynamic>? fichier;
    if (m.type == 'file') {
      // Le fichier lui-même : le web l'affiche (photo, vocal, vidéo,
      // document) et en demande le contenu quand il en a besoin.
      final legende = m.content.trim();
      texte = legende == m.fileName ? '' : legende;
      fichier = {
        'id': m.id,
        'nom': m.fileName ?? 'fichier',
        'mime': (m.fileMimeType ?? '').split(';').first,
        'taille': m.fileSize ?? 0,
      };
    }
    if (texte.trim().isEmpty && fichier == null) return null;
    final deMoi = m.senderId == moi;
    return {
      'id': m.id,
      'd': d,
      'a': deMoi ? 'moi' : (m.senderId ?? ''),
      'texte': texte,
      'date': m.timestamp.toUtc().toIso8601String(),
      'statut': !deMoi
          ? 'lu'
          : switch (m.status) {
              MessageStatus.failed => 'echec',
              MessageStatus.sending || MessageStatus.pending => 'envoi',
              MessageStatus.sent => m.readAt != null ? 'lu' : (m.deliveryCount > 0 ? 'recu' : 'envoye'),
            },
      'r': ?m.replyToId,
      if (m.editedAt != null) 'modifie': true,
      'f': ?fichier,
      if (m.reactions.isNotEmpty) 'reactions': m.reactions,
    };
  }

  static String _empreinte(MeshMessage m) =>
      '${m.status.index}|${m.deliveryCount > 0}|${m.readAt != null}|${m.content.length}|${m.content.hashCode}|${m.editedAt?.millisecondsSinceEpoch}|${m.reactions.join(',')}';

  static DateTime _plusRecent(List<MeshMessage> l) =>
      l.fold(DateTime(2000), (a, m) => m.timestamp.isAfter(a) ? m.timestamp : a);

  // ── Le chiffrement et la boîte ──────────────────────────────────────

  List<AppareilLie> _appareils() => AppareilsLies.liste().where((a) => a.cle != null).toList();

  Future<SecretKey?> _cle(AppareilLie a) async {
    final deja = _cles[a.id];
    if (deja != null) return deja;
    try {
      final k = await CryptoService.cleAppareil(base64Decode(a.cle!));
      if (k != null) _cles[a.id] = k;
      return k;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deposer(AppareilLie a, Map<String, dynamic> lot) async {
    final k = await _cle(a);
    if (k == null) return;
    try {
      final boite = await AesGcm.with256bits().encrypt(utf8.encode(jsonEncode(lot)), secretKey: k);
      await _repo.transport.storeMailboxMessage(
        toPeerId: a.id,
        encryptedPayload: jsonEncode({
          'w': 1,
          'c': base64Encode([...boite.cipherText, ...boite.mac.bytes]),
          'n': base64Encode(boite.nonce),
        }),
      );
    } catch (e) {
      debugPrint('[Miroir] dépôt vers ${a.nom} impossible : $e');
    }
  }

  Future<String?> _dechiffrer(AppareilLie a, String? c, String? n) async {
    if (c == null || n == null) return null;
    final k = await _cle(a);
    if (k == null) return null;
    try {
      final octets = base64Decode(c);
      if (octets.length < 17) return null;
      final clair = await AesGcm.with256bits().decrypt(
        SecretBox(octets.sublist(0, octets.length - 16), nonce: base64Decode(n), mac: Mac(octets.sublist(octets.length - 16))),
        secretKey: k,
      );
      return utf8.decode(clair);
    } catch (_) {
      return null;
    }
  }

  void oublierCle(String appareilId) => _cles.remove(appareilId);
}
