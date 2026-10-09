// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES ANNONCES DU COMPTE OFFICIEL — comment on les lit, comment on vérifie
// qu'elles sont authentiques, et comment elles deviennent des messages dans
// la conversation « Droplet ».
//
// ── LES DEUX CHEMINS D'ARRIVÉE ────────────────────────────────────────
//
//   1. PAR INTERNET, quand il y en a : un seul fichier signé, récupéré sur
//      le serveur, au plus une fois toutes les douze heures.
//   2. PAR LE MAILLAGE, sinon : une annonce se propage de téléphone en
//      téléphone comme un statut. Un appareil qui n'a jamais vu Internet
//      reçoit la nouveauté de son voisin de table.
//
// Le second chemin n'est pas un pis-aller. Pour une application dont tout
// l'argument est de fonctionner hors ligne, le compte officiel qui arrive
// hors ligne n'est pas un détail d'implémentation : c'est la démonstration.
//
// ── ⚠️ CE QUI EST SIGNÉ : UN TEXTE CANONIQUE, PAS LE FICHIER JSON ─────
//
// Deux bibliothèques JSON n'écrivent pas les mêmes octets pour le même
// contenu — ordre des clés, espaces, échappement d'Unicode. Signer « le
// fichier » ferait échouer la vérification au moindre reformatage, chez
// tout le monde, sans explication.
//
// On signe donc une chaîne reconstruite champ par champ, dans un ordre
// fixe, que Python et Dart savent rebâtir à l'identique :
//
//     id \n version \n date \n versionMini \n lien \n
//     puis, par langue triée : langue \n titre \n corps \n
//
// ⚠️ `_plat()` N'EST PAS UNE COQUETTERIE D'ÉCHAPPEMENT. Sans lui, un corps
// d'annonce contenant un retour à la ligne décalerait tous les champs
// suivants : deux annonces différentes pourraient produire le même texte à
// signer, et une signature valide pour l'une vaudrait pour l'autre. C'est
// l'attaque classique contre ce genre de format, et elle est gratuite à
// empêcher.
//
// ⚠️ TOUTE MODIFICATION DE `_canonique` DOIT ÊTRE FAITE EN MÊME TEMPS DANS
// `outils/annonce_droplet.py`. Les deux se répondent octet pour octet ;
// désynchronisées, plus aucune annonce ne passe.
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/compte_droplet.dart';
import '../models/mesh_message.dart';
import 'storage_service.dart';
import '../protocol/droplet_mesh_protocol.dart';

/// Une annonce, telle qu'elle a été signée.
@immutable
class AnnonceDroplet {
  const AnnonceDroplet({
    required this.id,
    required this.version,
    required this.date,
    required this.versionMini,
    required this.lien,
    required this.textes,
    required this.signature,
  });

  /// Identifiant stable, choisi par l'auteur (« 2026-10-stickers »).
  ///
  /// C'est lui qui empêche une annonce d'être réaffichée, et qui neutralise
  /// le rejeu d'une vieille annonce par un relais hostile.
  final String id;

  final int version;

  /// La date d'émission, telle quelle : c'est la chaîne EXACTE qui a été
  /// signée, et elle ne doit donc jamais être reformatée avant vérification.
  final String date;

  /// Version minimale de l'application concernée, ou vide.
  final String versionMini;

  /// Un lien facultatif, ou vide.
  final String lien;

  /// langue → (titre, corps).
  final Map<String, ({String titre, String corps})> textes;

  final String signature;

  DateTime get quand => DateTime.tryParse(date)?.toLocal() ?? DateTime.now();

  /// Le texte dans la langue demandée, avec repli sur l'anglais puis sur la
  /// première disponible.
  ///
  /// ⚠️ LE REPLI N'EST PAS UN DÉTAIL. Une annonce peut être publiée avant
  /// d'être traduite partout ; sans repli, elle s'afficherait vide — ce qui
  /// est pire que de l'afficher dans une autre langue.
  ({String titre, String corps}) pour(String langue) =>
      textes[langue] ?? textes['en'] ?? textes.values.first;

  static AnnonceDroplet? depuisJson(Object? brut) {
    if (brut is! Map) return null;
    final textes = brut['textes'];
    if (textes is! Map || textes.isEmpty) return null;
    final parLangue = <String, ({String titre, String corps})>{};
    for (final e in textes.entries) {
      final v = e.value;
      if (v is! Map) continue;
      final titre = v['titre'];
      final corps = v['corps'];
      if (titre is! String || corps is! String) continue;
      parLangue['${e.key}'] = (titre: titre, corps: corps);
    }
    if (parLangue.isEmpty) return null;
    final id = brut['id'];
    final signature = brut['signature'];
    final date = brut['date'];
    if (id is! String || signature is! String || date is! String) return null;
    return AnnonceDroplet(
      id: id,
      version: (brut['version'] as num?)?.toInt() ?? 0,
      date: date,
      versionMini: '${brut['versionMini'] ?? ''}',
      lien: '${brut['lien'] ?? ''}',
      textes: parLangue,
      signature: signature,
    );
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'version': version,
        'date': date,
        'versionMini': versionMini,
        'lien': lien,
        'textes': {
          for (final e in textes.entries)
            e.key: {'titre': e.value.titre, 'corps': e.value.corps},
        },
        'signature': signature,
      };
}

/// Lecture, vérification et mise en base des annonces.
class AnnoncesDroplet {
  const AnnoncesDroplet._();

  /// Aplatit un champ : plus aucun saut de ligne réel ne subsiste.
  static String _plat(String v) => v
      .replaceAll('\\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', '');

  /// Le texte exact qui a été signé. Jumeau de `canonique()` en Python.
  static String _canonique(AnnonceDroplet a) {
    final lignes = <String>[
      _plat(a.id),
      '${CompteDroplet.versionFormat}',
      _plat(a.date),
      _plat(a.versionMini),
      _plat(a.lien),
    ];
    final langues = a.textes.keys.toList()..sort();
    for (final lg in langues) {
      final t = a.textes[lg]!;
      lignes
        ..add(_plat(lg))
        ..add(_plat(t.titre))
        ..add(_plat(t.corps));
    }
    return lignes.join('\n');
  }

  /// Vrai si l'annonce vient bien du détenteur de la clé privée.
  static Future<bool> authentique(AnnonceDroplet a) async {
    // Une annonce d'un format futur n'est pas « fausse » : elle est
    // illisible. On la refuse quand même — afficher un contenu dont on ne
    // sait pas reconstruire le texte signé reviendrait à ne rien vérifier.
    if (a.version != CompteDroplet.versionFormat) return false;
    try {
      return await DropletMeshProtocol.verifySignature(
        payload: Uint8List.fromList(utf8.encode(_canonique(a))),
        signatureBytes: base64.decode(a.signature),
        publicKeyBytes: base64.decode(CompteDroplet.clePubliqueBase64),
      );
    } catch (_) {
      // Signature ou clé mal formées : au même rang qu'une signature fausse.
      return false;
    }
  }

  /// Ne garde que les annonces authentiques, de la plus récente à la plus
  /// ancienne.
  static Future<List<AnnonceDroplet>> filtrer(Iterable<Object?> bruts) async {
    final gardees = <AnnonceDroplet>[];
    var refusees = 0;
    for (final b in bruts) {
      final a = AnnonceDroplet.depuisJson(b);
      if (a == null) {
        refusees++;
        continue;
      }
      if (await authentique(a)) {
        gardees.add(a);
      } else {
        refusees++;
      }
    }
    if (refusees > 0) {
      // ⚠️ ON LE DIT, MÊME SI PERSONNE NE LIT LES JOURNAUX. Des annonces
      // refusées en masse signifient soit une clé remplacée par erreur,
      // soit quelqu'un qui essaie de parler au nom de Droplet. Les deux
      // méritent de laisser une trace.
      debugPrint('[Annonces] $refusees annonce(s) refusée(s) : signature invalide');
    }
    gardees.sort((x, y) => y.date.compareTo(x.date));
    return gardees;
  }

  /// Récupère le lot d'annonces sur le serveur.
  ///
  /// [client] est injecté pour que l'appelant choisisse le chemin : le
  /// client Tor quand il tourne, un client ordinaire sinon.
  static Future<List<AnnonceDroplet>> telecharger({
    required http.Client client,
    required String base,
  }) async {
    final uri = Uri.parse('$base${CompteDroplet.cheminAnnonces}');
    final r = await client.get(uri).timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      debugPrint('[Annonces] serveur: ${r.statusCode}');
      return const [];
    }
    final brut = json.decode(utf8.decode(r.bodyBytes));
    if (brut is! List) return const [];
    return filtrer(brut);
  }

  // ══ CE QU'ON GARDE, ET POURQUOI ═════════════════════════════════

  /// Comment fabriquer le client HTTP.
  ///
  /// ⚠️ INJECTÉ PLUTÔT QUE CHOISI ICI — même principe que
  /// `sauvegarde_en_ligne.dart`. Quand Tor tourne, l'application remplace
  /// cette fabrique par celle qui passe par le proxy : ce fichier n'a pas
  /// à savoir si l'anonymat est en route, et un test n'a pas à ouvrir de
  /// connexion réelle.
  static http.Client Function() fabriqueClient = http.Client.new;

  /// Prévenu à chaque annonce NOUVELLE — par Internet comme par un
  /// voisin. Branché par `main.dart` vers le centre de notifications.
  ///
  /// ⚠️ UN SIMPLE RAPPEL, PAS UN FLUX. Ce fichier ne doit rien savoir de
  /// l'interface : il vérifie des signatures et range des annonces.
  static void Function(List<AnnonceDroplet> nouvelles)? surNouvelles;

  static const String _cleConnues = 'annonces:connues';
  static const String _cleDerniereVerif = 'annonces:derniere_verif';

  /// Les annonces authentiques déjà reçues, de la plus récente à la plus
  /// ancienne.
  ///
  /// ⚠️ ON GARDE L'ANNONCE SIGNÉE ENTIÈRE, pas seulement son texte. C'est
  /// ce qui permet de la RELAYER à un voisin : un texte seul ne se
  /// vérifie pas, et un relais qui transmettrait du texte nu transformerait
  /// chaque téléphone en source de faux.
  static List<AnnonceDroplet> connues() {
    final brut = StorageService.getString(_cleConnues);
    if (brut == null || brut.isEmpty) return const [];
    try {
      final lot = json.decode(brut);
      if (lot is! List) return const [];
      return lot
          .map(AnnonceDroplet.depuisJson)
          .whereType<AnnonceDroplet>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Les identifiants connus — ce qu'on propose à un voisin.
  static Set<String> identifiantsConnus() =>
      connues().map((a) => a.id).toSet();

  /// Enregistre des annonces (déjà vérifiées), crée les messages manquants,
  /// et renvoie celles qui étaient nouvelles.
  ///
  /// ⚠️ LA VÉRIFICATION N'EST PAS REFAITE ICI. Elle a lieu dans [filtrer],
  /// à l'entrée — que l'annonce vienne du serveur ou d'un voisin. La
  /// refaire coûterait une signature Ed25519 par annonce à chaque
  /// démarrage, pour re-vérifier ce qu'on a soi-même écrit sur son propre
  /// disque. En revanche, **rien n'entre ici sans être passé par
  /// [filtrer]** : c'est la seule porte.
  static Future<List<AnnonceDroplet>> enregistrer(
    List<AnnonceDroplet> annonces, {
    required String langue,
  }) async {
    if (annonces.isEmpty) return const [];
    final dejaLa = identifiantsConnus();
    final nouvelles = annonces.where((a) => !dejaLa.contains(a.id)).toList();
    if (nouvelles.isEmpty) return const [];

    final tout = [...connues(), ...nouvelles]
      ..sort((x, y) => y.date.compareTo(x.date));
    // Au-delà, les plus anciennes cessent d'être proposées aux voisins :
    // quelqu'un qui installe Droplet aujourd'hui n'a pas besoin de recevoir
    // les nouveautés d'il y a trois ans par Bluetooth.
    final gardees = tout.take(CompteDroplet.relaisMax).toList();
    await StorageService.setString(
      _cleConnues,
      json.encode([for (final a in gardees) a.versJson()]),
    );

    for (final a in nouvelles) {
      await StorageService.saveMessage(versMessage(a, langue));
    }

    // ⚠️ ON ÉPINGLE À LA PREMIÈRE ANNONCE SEULEMENT. Réépingler à chaque
    // fois annulerait le geste de quelqu'un qui a volontairement
    // désépinglé — et un compte officiel qui remonte tout seul en haut de
    // la liste après qu'on l'a rangé est exactement le genre de chose qui
    // fait désinstaller.
    if (dejaLa.isEmpty) {
      await StorageService.setConversationPinned(CompteDroplet.id, true);
    }
    surNouvelles?.call(nouvelles);
    return nouvelles;
  }

  // ══ LA VOIE INTERNET ════════════════════════════════════════════

  /// Va voir le serveur, au plus une fois toutes les douze heures.
  ///
  /// ⚠️ LE FREIN EST ICI, PAS CHEZ L'APPELANT. Cette méthode est appelée
  /// au démarrage et à chaque retour de connexion : sans frein, un
  /// téléphone dont le réseau clignote interrogerait le serveur vingt fois
  /// par heure — et dessinerait, requête après requête, une carte des
  /// heures auxquelles son porteur ouvre l'application.
  ///
  /// [forcer] contourne le frein : c'est le geste « tirer pour
  /// rafraîchir », qui est une demande explicite.
  static Future<List<AnnonceDroplet>> synchroniser({
    required String base,
    required String langue,
    http.Client? client,
    bool forcer = false,
  }) async {
    if (!forcer) {
      final derniere = int.tryParse(
        StorageService.getString(_cleDerniereVerif) ?? '',
      );
      if (derniere != null) {
        final ecoule = DateTime.now().millisecondsSinceEpoch - derniere;
        if (ecoule < CompteDroplet.intervalleVerification.inMilliseconds) {
          return const [];
        }
      }
    }
    try {
      final c = client ?? fabriqueClient();
      final lot = await telecharger(client: c, base: base);
      // ⚠️ ON NOTE L'HEURE MÊME SI LE LOT EST VIDE. Un serveur joignable
      // qui n'a rien de neuf est une vérification RÉUSSIE ; ne pas la
      // noter ferait réinterroger au prochain démarrage, et au suivant.
      await StorageService.setString(
        _cleDerniereVerif,
        '${DateTime.now().millisecondsSinceEpoch}',
      );
      return enregistrer(lot, langue: langue);
    } catch (e) {
      // Pas de réseau, serveur muet : on ne note RIEN, pour réessayer à la
      // prochaine occasion. C'est la différence entre « rien de neuf » et
      // « je n'ai pas pu regarder ».
      debugPrint('[Annonces] synchro impossible: $e');
      return const [];
    }
  }

  // ══ LA VOIE DU MAILLAGE ═════════════════════════════════════════

  /// Ce qu'on propose à un voisin qu'on vient de rencontrer : des
  /// identifiants, rien d'autre.
  ///
  /// ⚠️ ON PROPOSE, ON N'ENVOIE PAS. Une annonce pèse quelques kilooctets
  /// en dix langues ; douze annonces envoyées d'office à chaque rencontre,
  /// c'est une minute de Bluetooth à chaque fois qu'on croise quelqu'un,
  /// pour des annonces qu'il a déjà. Les identifiants tiennent en quelques
  /// dizaines d'octets, et il ne réclame que ce qui lui manque.
  static String offre() => json.encode({
        'k': 'annonce_offre',
        'ids': identifiantsConnus().toList(),
      });

  /// Ce qu'un voisin répond : les identifiants qui lui manquent.
  static String? demande(Object? offreRecue) {
    if (offreRecue is! Map) return null;
    final ids = offreRecue['ids'];
    if (ids is! List) return null;
    final miens = identifiantsConnus();
    final manquants = ids
        .map((e) => '$e')
        .where((id) => id.isNotEmpty && !miens.contains(id))
        .toList();
    if (manquants.isEmpty) return null;
    return json.encode({'k': 'annonce_dem', 'ids': manquants});
  }

  /// Les annonces à envoyer en réponse à une demande.
  static List<String> repondre(Object? demandeRecue) {
    if (demandeRecue is! Map) return const [];
    final ids = demandeRecue['ids'];
    if (ids is! List) return const [];
    final voulus = ids.map((e) => '$e').toSet();
    return [
      for (final a in connues())
        if (voulus.contains(a.id))
          json.encode({'k': 'annonce', 'a': a.versJson()}),
    ];
  }

  /// Une annonce reçue d'un voisin.
  ///
  /// ⚠️ ELLE PASSE PAR LA MÊME PORTE QUE CELLES DU SERVEUR. Un voisin
  /// n'est pas une source de confiance — c'est tout l'intérêt du dispositif.
  /// La signature est vérifiée ici exactement comme ailleurs, et une
  /// annonce qui ne la passe pas est jetée sans être montrée.
  static Future<List<AnnonceDroplet>> recevoir(
    Object? recue, {
    required String langue,
  }) async {
    if (recue is! Map) return const [];
    final gardees = await filtrer([recue['a']]);
    return enregistrer(gardees, langue: langue);
  }

  /// Transforme une annonce en message, pour qu'elle apparaisse dans la
  /// conversation comme n'importe quel autre.
  ///
  /// ⚠️ L'IDENTIFIANT DU MESSAGE EST CELUI DE L'ANNONCE. La table rejette
  /// les doublons (`insertOrIgnore`) : la même annonce reçue par Internet
  /// PUIS par un voisin Bluetooth n'apparaît qu'une fois, sans qu'aucun des
  /// deux chemins ait à savoir que l'autre existe.
  static MeshMessage versMessage(AnnonceDroplet a, String langue) {
    final t = a.pour(langue);
    final corps = t.corps.trim().isEmpty ? t.titre : '**${t.titre}**\n\n${t.corps}';
    return MeshMessage(
      id: 'annonce:${a.id}',
      authorPseudo: CompteDroplet.pseudo,
      content: a.lien.isEmpty ? corps : '$corps\n\n${a.lien}',
      senderId: CompteDroplet.id,
      // ⚠️ `targetId` NUL, ET C'EST CORRECT. La liste regroupe par
      // `senderId == moi ? targetId : senderId` : l'expéditeur n'étant pas
      // moi, c'est lui qui nomme la conversation. Un `targetId` égal à mon
      // identifiant ne changerait rien ici, et ferait fuiter dans le
      // message relayé à qui il a été remis.
      targetId: null,
      type: CompteDroplet.typeMessage,
      timestamp: a.quand,
      status: MessageStatus.sent,
    );
  }
}
