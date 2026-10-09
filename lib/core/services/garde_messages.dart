// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA GARDE : qui détient un message tant qu'il n'est pas arrivé.
//
// ── LE DÉFAUT QU'IL CORRIGE ───────────────────────────────────────────
//
// Droplet avait déjà une file de renvoi, `PremiumMessageQueue`. Elle est
// bonne — priorités, recul exponentiel, contrôle de congestion — mais
// elle a deux propriétés qui, ensemble, font perdre des messages :
//
//   1. ELLE VIT EN MÉMOIRE. Un `SplayTreeSet`, des `Map`, des `Timer`.
//      L'application fermée, le téléphone redémarré, le système qui
//      réclame de la place : tout ce qui n'était pas parti n'existe plus.
//
//   2. ELLE ABANDONNE. Cinq tentatives, trente secondes de délai par
//      défaut, puis `_onFinalFailure`. Or trente secondes, dans un
//      maillage, ce n'est rien : c'est le temps de sortir d'une pièce.
//
// Un message écrit à quelqu'un qui n'est pas là au bon moment n'a donc
// AUCUN mécanisme qui le repropose plus tard. Ce n'est pas un défaut de
// routage : la diffusion maximise déjà le taux de livraison. C'est qu'il
// manque quelqu'un pour TENIR le message pendant l'absence.
//
// ⚠️ ET LA SYNCHRONISATION DIFFÉRENTIELLE NE COMBLE PAS CE TROU.
// `_envoyerOffreDeSynchro()` ne propose que les STATUTS
// (`getActiveStatuses`). Les messages n'ont jamais eu de rattrapage.
//
// ── CE QUE FAIT CE FICHIER ────────────────────────────────────────────
//
// Une table, sur disque, d'une ligne par COUPLE (message, destinataire) —
// et c'est le couple qui compte : un message de groupe est livré à Awa et
// pas à Karim, et seule la ligne de Karim doit survivre.
//
// Elle est reprise du Bramble Sync Protocol de Briar, qui tient par
// message partagé et par pair : vu, acquitté, demandé, compteur d'envois,
// horodatage d'envoi, latence attendue. C'est la spécification qui est
// empruntée, pas le code : les specs Bramble sont sous CC BY-SA 4.0,
// alors que le code de Briar est en GPLv3 — le reprendre imposerait de
// publier Droplet et poserait le problème de l'App Store. La distinction
// n'est pas une subtilité juridique, c'est ce qui rend cet emprunt
// possible.
//
// ── ⚠️ LA SEULE RÈGLE QUI COMPTE VRAIMENT ─────────────────────────────
//
// ON N'ABANDONNE PAS AVANT [ttl]. Le recul exponentiel espace les
// tentatives — il ne les arrête pas. Un message reste sous garde sept
// jours, et repart à chaque fois que son destinataire réapparaît, même
// une semaine plus tard, même après un redémarrage du téléphone.
//
// Le coût est connu et borné : quelques centaines d'octets par message en
// attente, et des doublons possibles. Les doublons sont gratuits, parce
// que le récepteur déduplique déjà sur l'identifiant (`SeenMessageIds`).
// C'est le marché que fait le mode « eager » de Bramble, décrit par ses
// auteurs comme adapté aux transports peu fiables : on renvoie sans
// attendre, on gaspille un peu de bande passante, et « parfois ça
// n'arrive pas » devient « ça arrive, éventuellement deux fois ».
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Une remise à faire : ce message, vers ce pair.
class RemiseDue {
  const RemiseDue({
    required this.messageId,
    required this.pairId,
    required this.envois,
    required this.corps,
  });

  final String messageId;
  final String pairId;

  /// Combien de fois on a déjà essayé. Sert à l'appelant s'il veut
  /// changer de transport au bout de quelques échecs.
  final int envois;

  /// ⚠️ LE PAQUET EXACT, TEL QU'IL DEVAIT PARTIR — pas de quoi le
  /// reconstruire.
  ///
  /// C'est la décision la plus importante de ce fichier. Reconstruire le
  /// paquet à partir du message rangé en base obligerait à REFAIRE le
  /// chiffrement, des jours plus tard, avec un état cryptographique qui
  /// a pu changer entre-temps ; et un paquet mal reconstruit ne se voit
  /// pas — il part, et le destinataire ne le déchiffre pas. On garde donc
  /// les octets d'origine et on les réémet tels quels. Réémettre un
  /// chiffré identique est une retransmission, pas un nouveau
  /// chiffrement : c'est exactement ce que fait n'importe quelle couche
  /// de transport fiable, et ça ne réutilise aucun nonce.
  final List<int> corps;

  @override
  String toString() =>
      'RemiseDue($messageId → $pairId, $envois envois, ${corps.length} o)';
}

/// Le registre des messages confiés, sur disque.
class GardeMessages {
  GardeMessages._(this._db, {math.Random? alea})
      : _alea = alea ?? math.Random();

  final Database _db;
  final math.Random _alea;

  // ── Les constantes de temporisation ──────────────────────────────

  /// Premier délai avant un nouvel essai.
  static const Duration reculBase = Duration(seconds: 2);

  /// ⚠️ LE PLAFOND N'EST PAS UN ABANDON. Au-delà, on continue d'essayer
  /// toutes les cinq minutes — indéfiniment, jusqu'au [ttl]. C'est toute
  /// la différence avec la file en mémoire, qui déclarait forfait.
  static const Duration reculMax = Duration(minutes: 5);

  /// Dispersion appliquée au délai, comme pour le Wi-Fi Direct : deux
  /// téléphones qui échouent ensemble ne doivent pas repartir ensemble.
  static const double gigue = 0.25;

  /// Combien de temps un message reste sous garde. Au-delà, le
  /// destinataire n'est raisonnablement plus joignable par ce chemin et
  /// la ligne est effacée pour ne pas faire grossir la base sans fin.
  static const Duration ttl = Duration(days: 7);

  /// Une ligne acquittée est gardée un peu : un ACK peut arriver en
  /// double, et une ligne déjà effacée serait reconfiée par erreur.
  static const Duration retentionAcquittee = Duration(hours: 6);

  /// Combien de remises on sort d'un coup. Sans borne, la reconnexion
  /// d'un pair absent une semaine viderait toute la base dans le lien
  /// d'un seul coup, et le Bluetooth s'écroulerait.
  static const int lotMax = 40;

  /// Au-delà, on ne prend pas le corps en garde : c'est un transfert de
  /// fichier, qui a déjà sa propre reprise.
  static const int tailleMaxCorps = 16 * 1024;

  static Future<GardeMessages> ouvrir({String? chemin}) async {
    final dossier = chemin ?? (await getApplicationDocumentsDirectory()).path;
    final db = sqlite3.open(p.join(dossier, 'garde.db'));
    final garde = GardeMessages._(db);
    garde._creerSchema();
    return garde;
  }

  /// Pour les tests : une garde en mémoire, avec un hasard reproductible.
  factory GardeMessages.enMemoire({math.Random? alea}) {
    final garde = GardeMessages._(sqlite3.openInMemory(), alea: alea);
    garde._creerSchema();
    return garde;
  }

  void _creerSchema() {
    _db.execute('PRAGMA journal_mode=WAL');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS garde (
        message_id   TEXT    NOT NULL,
        pair_id      TEXT    NOT NULL,
        confie_a     INTEGER NOT NULL,
        envois       INTEGER NOT NULL DEFAULT 0,
        dernier_envoi INTEGER,
        prochaine_a  INTEGER NOT NULL,
        acquitte_a   INTEGER,
        corps        BLOB    NOT NULL,
        PRIMARY KEY (message_id, pair_id)
      )
    ''');
    // ⚠️ L'INDEX N'EST PAS UN LUXE. La requête « qu'est-ce qui est dû ? »
    // tourne à chaque battement et à chaque reconnexion. Sans lui, c'est
    // un parcours complet de la table à chaque fois, sur un téléphone,
    // pendant que la radio travaille.
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_garde_du '
      'ON garde(acquitte_a, prochaine_a)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_garde_pair ON garde(pair_id)',
    );
  }

  // ── Confier ──────────────────────────────────────────────────────

  /// Prend en garde [messageId] pour chacun de [pairs].
  ///
  /// La première tentative est due TOUT DE SUITE : l'envoi normal a lieu
  /// par ailleurs, et si celui-ci réussit l'ACK effacera la ligne avant
  /// qu'elle ne serve. Confier ne coûte donc rien quand tout va bien.
  ///
  /// ⚠️ `ON CONFLICT DO NOTHING` : reconfier un message déjà sous garde
  /// ne doit pas remettre son compteur d'envois à zéro, sinon un pair
  /// injoignable serait harcelé toutes les deux secondes à vie.
  void confier({
    required String messageId,
    required Iterable<String> pairs,
    required Uint8List corps,
    DateTime? maintenant,
  }) {
    // ⚠️ ON NE GARDE PAS LES GROS PAQUETS. Un transfert de fichier passe
    // déjà par son propre magasin, avec son propre découpage et sa propre
    // reprise ; en garder une copie ici doublerait l'occupation disque
    // pour rien. Seule l'annonce, petite, mérite la garde.
    if (corps.length > tailleMaxCorps) return;
    final t = (maintenant ?? DateTime.now()).millisecondsSinceEpoch;
    final st = _db.prepare(
      'INSERT INTO garde '
      '(message_id, pair_id, confie_a, envois, prochaine_a, corps) '
      'VALUES (?, ?, ?, 0, ?, ?) '
      'ON CONFLICT(message_id, pair_id) DO NOTHING',
    );
    try {
      _db.execute('BEGIN');
      for (final pair in pairs) {
        if (pair.isEmpty || pair == 'broadcast') continue;
        st.execute([messageId, pair, t, t, corps]);
      }
      _db.execute('COMMIT');
    } on Object {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      st.dispose();
    }
  }

  // ── Ce qui est dû ────────────────────────────────────────────────

  /// Les remises à faire maintenant, les plus anciennes d'abord.
  ///
  /// [pairsJoignables] restreint aux pairs actuellement en vue : inutile
  /// de sortir des lignes pour quelqu'un qui n'est pas là, et les sortir
  /// ferait grimper leur compteur d'envois pour rien.
  List<RemiseDue> dues({
    required Set<String> pairsJoignables,
    DateTime? maintenant,
    int limite = lotMax,
  }) {
    if (pairsJoignables.isEmpty) return const [];
    final t = (maintenant ?? DateTime.now()).millisecondsSinceEpoch;
    // On filtre les pairs en Dart plutôt qu'avec un `IN (?, ?, …)`
    // construit à la main : une liste de pairs interpolée dans du SQL est
    // exactement la forme qui finit par laisser passer une injection le
    // jour où un identifiant vient du réseau.
    final lignes = _db.select(
      'SELECT message_id, pair_id, envois, corps FROM garde '
      'WHERE acquitte_a IS NULL AND prochaine_a <= ? '
      'ORDER BY prochaine_a ASC LIMIT ?',
      [t, limite * 4],
    );
    final sortie = <RemiseDue>[];
    for (final l in lignes) {
      final pair = l['pair_id'] as String;
      if (!pairsJoignables.contains(pair)) continue;
      sortie.add(RemiseDue(
        messageId: l['message_id'] as String,
        pairId: pair,
        envois: l['envois'] as int,
        corps: l['corps'] as Uint8List,
      ));
      if (sortie.length >= limite) break;
    }
    return sortie;
  }

  // ── Noter ────────────────────────────────────────────────────────

  /// Un envoi vient de partir : on compte, et on repousse le suivant.
  void noterEnvoi({
    required String messageId,
    required String pairId,
    DateTime? maintenant,
  }) {
    final t = (maintenant ?? DateTime.now()).millisecondsSinceEpoch;
    final r = _db.select(
      'SELECT envois FROM garde WHERE message_id = ? AND pair_id = ?',
      [messageId, pairId],
    );
    if (r.isEmpty) return;
    final envois = (r.first['envois'] as int) + 1;
    _db.execute(
      'UPDATE garde SET envois = ?, dernier_envoi = ?, prochaine_a = ? '
      'WHERE message_id = ? AND pair_id = ?',
      [envois, t, t + delai(envois).inMilliseconds, messageId, pairId],
    );
  }

  /// Le délai avant la tentative numéro [envois] + 1.
  ///
  /// ⚠️ L'EXPOSANT EST BORNÉ AVANT LE DÉCALAGE. `1 << 40` déborde
  /// l'entier et rend un délai négatif — c'est-à-dire un message renvoyé
  /// en boucle aussi vite que la radio le permet. Le défaut ne se voit
  /// qu'après plusieurs jours de garde, ce qui est exactement le moment
  /// où personne ne regarde.
  Duration delai(int envois) {
    final exposant = (envois - 1).clamp(0, 16);
    final base = (reculBase.inMilliseconds * (1 << exposant))
        .clamp(reculBase.inMilliseconds, reculMax.inMilliseconds);
    final facteur = 1 + (_alea.nextDouble() * 2 - 1) * gigue;
    return Duration(milliseconds: (base * facteur).round());
  }

  /// Le destinataire a confirmé. C'est ce qui sort le message de la garde.
  ///
  /// Sans [pairId], acquitte pour tous les pairs — le cas d'un message
  /// dont on apprend par un autre chemin qu'il est arrivé.
  void acquitter({
    required String messageId,
    String? pairId,
    DateTime? maintenant,
  }) {
    final t = (maintenant ?? DateTime.now()).millisecondsSinceEpoch;
    if (pairId == null) {
      _db.execute(
        'UPDATE garde SET acquitte_a = ? '
        'WHERE message_id = ? AND acquitte_a IS NULL',
        [t, messageId],
      );
    } else {
      _db.execute(
        'UPDATE garde SET acquitte_a = ? '
        'WHERE message_id = ? AND pair_id = ? AND acquitte_a IS NULL',
        [t, messageId, pairId],
      );
    }
  }

  /// Le message est annulé ou supprimé : plus rien à garder.
  void oublier(String messageId) {
    _db.execute('DELETE FROM garde WHERE message_id = ?', [messageId]);
  }

  // ── Entretien ────────────────────────────────────────────────────

  /// Efface ce qui n'a plus de raison d'être. À appeler de temps en
  /// temps, pas à chaque battement.
  int purger({DateTime? maintenant}) {
    final t = (maintenant ?? DateTime.now()).millisecondsSinceEpoch;
    _db.execute(
      'DELETE FROM garde WHERE acquitte_a IS NOT NULL AND acquitte_a < ?',
      [t - retentionAcquittee.inMilliseconds],
    );
    final apresAcquittes = _db.updatedRows;
    _db.execute(
      'DELETE FROM garde WHERE confie_a < ?',
      [t - ttl.inMilliseconds],
    );
    return apresAcquittes + _db.updatedRows;
  }

  // ── Diagnostic ───────────────────────────────────────────────────
  //
  // ⚠️ CES COMPTEURS SONT LA SEULE SOURCE DE VÉRITÉ DISPONIBLE. Aucune
  // mesure publique n'existe sur la fiabilité d'un maillage de
  // téléphones ; celle de Droplet ne se connaîtra qu'en la mesurant.

  /// Combien de remises attendent encore.
  int get enAttente => _db
      .select('SELECT COUNT(*) AS n FROM garde WHERE acquitte_a IS NULL')
      .first['n'] as int;

  /// Combien attendent pour ce pair précis.
  int enAttentePour(String pairId) => _db.select(
        'SELECT COUNT(*) AS n FROM garde '
        'WHERE pair_id = ? AND acquitte_a IS NULL',
        [pairId],
      ).first['n'] as int;

  /// Le délai entre la prise en garde et l'acquittement, en millisecondes,
  /// pour les remises abouties depuis [depuis]. C'est la latence de
  /// livraison réellement observée — pas celle du lien radio.
  List<int> latencesObservees({Duration depuis = const Duration(days: 1)}) {
    final t = DateTime.now().subtract(depuis).millisecondsSinceEpoch;
    return _db
        .select(
          'SELECT acquitte_a - confie_a AS d FROM garde '
          'WHERE acquitte_a IS NOT NULL AND acquitte_a >= ?',
          [t],
        )
        .map((l) => l['d'] as int)
        .toList();
  }

  void fermer() => _db.dispose();
}
