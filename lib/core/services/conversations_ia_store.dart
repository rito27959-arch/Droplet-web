// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES CONVERSATIONS DE L'ASSISTANT — plusieurs fils, gardés, retrouvables.
//
// Jusqu'ici l'assistant n'avait qu'UN fil, sans nom et sans fin. C'est
// tenable pour un jouet ; ça ne l'est plus dès qu'on s'en sert vraiment.
// Toutes les grandes applications d'assistant ont la même base : une
// liste de conversations, un titre par conversation, la possibilité d'en
// épingler quelques-unes et de chercher dans tout l'historique.
//
// ── POURQUOI DU SQL ÉCRIT À LA MAIN, ET PAS UNE TABLE DRIFT ───────────
//
// ⚠️ CHOIX DÉLIBÉRÉ, PAS UN RACCOURCI. Les tables de `app_database.dart`
// passent par `build_runner` : ajouter une table oblige à régénérer
// `app_database.g.dart`, à monter `schemaVersion` et à écrire une
// migration. Ces conversations n'ont AUCUN lien avec le reste du schéma
// (ni clé étrangère, ni jointure avec les messages du mesh) : les faire
// entrer dans le classeur principal ferait payer une migration à toute
// l'application pour un tableau qui ne parle qu'à l'assistant.
//
// Elles vivent donc dans leur propre fichier SQLite, créé au premier
// lancement par `CREATE TABLE IF NOT EXISTS`. Conséquence assumée : pas
// de vérification de type à la compilation sur ces requêtes. C'est pour
// cela que TOUTES les requêtes sont dans ce fichier et nulle part
// ailleurs — un seul endroit à relire.
//
// ── LA RECHERCHE ──────────────────────────────────────────────────────
//
// FTS5 (la recherche plein texte de SQLite) serait plus élégant, mais il
// n'est pas garanti présent dans toutes les compilations de `sqlite3` que
// les téléphones embarquent, et une fonctionnalité qui marche sur un
// appareil sur deux est pire qu'une fonctionnalité simple. On s'en tient
// donc à `LIKE` sur un texte aplati (sans accents, en minuscules),
// calculé à l'écriture et rangé dans sa propre colonne : chercher
// « decharge » trouve « décharge », et la recherche reste instantanée
// jusqu'à plusieurs milliers de messages.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// D'où vient une réponse — et donc si le message a quitté le téléphone.
///
/// ⚠️ ENREGISTRÉ PAR MESSAGE, PAS PAR CONVERSATION. Une même conversation
/// peut mélanger les deux (on commence hors ligne, on refait une réponse
/// en ligne). Sans cette colonne, impossible de dire après coup ce qui
/// est sorti et ce qui ne l'est pas — or c'est exactement la question que
/// quelqu'un se pose en relisant.
enum OrigineReponse { local, enLigne }

/// Une conversation dans la liste.
class ConversationIa {
  const ConversationIa({
    required this.id,
    required this.titre,
    required this.creeLe,
    required this.majLe,
    required this.epinglee,
    required this.nbMessages,
    this.apercu = '',
  });

  final String id;

  /// Le titre affiché. Vide tant que l'assistant n'a pas encore résumé
  /// le premier échange — l'écran affiche alors [apercu] à la place.
  final String titre;
  final DateTime creeLe;
  final DateTime majLe;
  final bool epinglee;
  final int nbMessages;

  /// Le début du dernier message, pour la deuxième ligne de la liste.
  final String apercu;
}

/// Un message dans une conversation.
class MessageStocke {
  const MessageStocke({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.contenu,
    required this.creeLe,
    required this.origine,
    this.reflexion,
    this.piecesJointes = const [],
    this.etapes = const [],
    this.chapitre = false,
  });

  final String id;
  final String conversationId;

  /// `user` ou `assistant`.
  final String role;
  final String contenu;
  final DateTime creeLe;
  final OrigineReponse origine;

  /// Le raisonnement replié, quand le modèle en a produit un.
  final String? reflexion;

  /// Chemins des fichiers joints par la personne, ou produits par
  /// l'assistant.
  final List<String> piecesJointes;

  /// Ce que l'assistant a FAIT pour répondre — une entrée par outil
  /// appelé, dans l'ordre. C'est ce que l'écran déroule sous la réponse.
  final List<EtapeActivite> etapes;

  /// Marqué comme chapitre, pour naviguer dans une longue conversation.
  final bool chapitre;
}

/// Une étape visible du travail de l'assistant.
///
/// ⚠️ GARDÉE EN BASE, PAS SEULEMENT À L'ÉCRAN. Rouvrir une conversation
/// trois jours plus tard et ne plus voir d'où venait un chiffre, c'est
/// exactement ce qui fait douter d'une réponse. Les étapes se relisent.
class EtapeActivite {
  const EtapeActivite({
    required this.outil,
    required this.resume,
    this.detail,
    this.reussi = true,
  });

  /// Le nom de l'outil : `recherche_web`, `lire_fichier`, `ecrire_fichier`…
  final String outil;

  /// Une ligne lisible : « Recherché : météo Douala ».
  final String resume;

  /// Ce que l'outil a renvoyé, replié. Peut être long.
  final String? detail;
  final bool reussi;

  Map<String, dynamic> versJson() => {
        'outil': outil,
        'resume': resume,
        if (detail != null) 'detail': detail,
        'reussi': reussi,
      };

  static EtapeActivite depuisJson(Map<String, dynamic> j) => EtapeActivite(
        outil: j['outil'] as String? ?? '',
        resume: j['resume'] as String? ?? '',
        detail: j['detail'] as String?,
        reussi: j['reussi'] as bool? ?? true,
      );
}

class ConversationsIaStore {
  ConversationsIaStore._(this._db);

  final Database _db;
  static ConversationsIaStore? _instance;

  /// Prévient la liste quand quelque chose bouge, pour que l'écran se
  /// redessine sans qu'on ait à le lui dire depuis dix endroits.
  final _changements = StreamController<void>.broadcast();
  Stream<void> get changements => _changements.stream;

  static Future<ConversationsIaStore> ouvrir() async {
    if (_instance != null) return _instance!;
    final dossier = await getApplicationDocumentsDirectory();
    final db = sqlite3.open(p.join(dossier.path, 'assistant_ia.db'));
    db.execute('PRAGMA journal_mode=WAL');
    db.execute('PRAGMA foreign_keys=ON');
    _creerTables(db);
    return _instance = ConversationsIaStore._(db);
  }

  static void _creerTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY,
        titre TEXT NOT NULL DEFAULT '',
        cree_le INTEGER NOT NULL,
        maj_le INTEGER NOT NULL,
        epinglee INTEGER NOT NULL DEFAULT 0
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL
          REFERENCES conversations(id) ON DELETE CASCADE,
        role TEXT NOT NULL,
        contenu TEXT NOT NULL,
        contenu_aplati TEXT NOT NULL,
        reflexion TEXT,
        origine TEXT NOT NULL DEFAULT 'local',
        pieces_jointes TEXT NOT NULL DEFAULT '[]',
        etapes TEXT NOT NULL DEFAULT '[]',
        chapitre INTEGER NOT NULL DEFAULT 0,
        cree_le INTEGER NOT NULL
      )
    ''');
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_msg_conv '
      'ON messages(conversation_id, cree_le)',
    );
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_msg_recherche ON messages(contenu_aplati)',
    );
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_conv_tri ON conversations(epinglee, maj_le)',
    );
  }

  // ── Écriture ──────────────────────────────────────────────────────────

  String creerConversation({String titre = ''}) {
    final id = _id();
    final t = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      'INSERT INTO conversations (id, titre, cree_le, maj_le, epinglee) '
      'VALUES (?, ?, ?, ?, 0)',
      [id, titre, t, t],
    );
    _changements.add(null);
    return id;
  }

  String ajouterMessage({
    required String conversationId,
    required String role,
    required String contenu,
    OrigineReponse origine = OrigineReponse.local,
    String? reflexion,
    List<String> piecesJointes = const [],
    List<EtapeActivite> etapes = const [],
  }) {
    final id = _id();
    final t = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      'INSERT INTO messages (id, conversation_id, role, contenu, '
      'contenu_aplati, reflexion, origine, pieces_jointes, etapes, '
      'chapitre, cree_le) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?)',
      [
        id,
        conversationId,
        role,
        contenu,
        aplatir(contenu),
        reflexion,
        origine.name,
        jsonEncode(piecesJointes),
        jsonEncode([for (final e in etapes) e.versJson()]),
        t,
      ],
    );
    _db.execute('UPDATE conversations SET maj_le = ? WHERE id = ?', [
      t,
      conversationId,
    ]);
    _changements.add(null);
    return id;
  }

  /// Remplace le contenu d'un message — utilisé quand la réponse finit de
  /// s'écrire, et quand la personne modifie son propre message.
  void majMessage(
    String id, {
    String? contenu,
    String? reflexion,
    List<EtapeActivite>? etapes,
    List<String>? piecesJointes,
  }) {
    final champs = <String>[];
    final valeurs = <Object?>[];
    if (contenu != null) {
      champs..add('contenu = ?')..add('contenu_aplati = ?');
      valeurs..add(contenu)..add(aplatir(contenu));
    }
    if (reflexion != null) {
      champs.add('reflexion = ?');
      valeurs.add(reflexion);
    }
    if (etapes != null) {
      champs.add('etapes = ?');
      valeurs.add(jsonEncode([for (final e in etapes) e.versJson()]));
    }
    if (piecesJointes != null) {
      champs.add('pieces_jointes = ?');
      valeurs.add(jsonEncode(piecesJointes));
    }
    if (champs.isEmpty) return;
    valeurs.add(id);
    _db.execute(
      'UPDATE messages SET ${champs.join(', ')} WHERE id = ?',
      valeurs,
    );
    _changements.add(null);
  }

  void renommer(String conversationId, String titre) {
    _db.execute('UPDATE conversations SET titre = ? WHERE id = ?', [
      titre.trim(),
      conversationId,
    ]);
    _changements.add(null);
  }

  void epingler(String conversationId, {required bool epinglee}) {
    _db.execute('UPDATE conversations SET epinglee = ? WHERE id = ?', [
      epinglee ? 1 : 0,
      conversationId,
    ]);
    _changements.add(null);
  }

  void marquerChapitre(String messageId, {required bool chapitre}) {
    _db.execute('UPDATE messages SET chapitre = ? WHERE id = ?', [
      chapitre ? 1 : 0,
      messageId,
    ]);
    _changements.add(null);
  }

  void supprimerConversation(String id) {
    // `ON DELETE CASCADE` emporte les messages, à condition que
    // `foreign_keys` soit bien activé — ce qui est fait à l'ouverture.
    _db.execute('DELETE FROM conversations WHERE id = ?', [id]);
    _changements.add(null);
  }

  /// Supprime un message ET tout ce qui le suit dans la conversation.
  ///
  /// C'est ce que fait « modifier mon message » : la suite de l'échange
  /// répondait à l'ancienne question, la garder n'aurait aucun sens.
  void supprimerDepuis(String messageId) {
    final r = _db.select(
      'SELECT conversation_id, cree_le FROM messages WHERE id = ?',
      [messageId],
    );
    if (r.isEmpty) return;
    _db.execute(
      'DELETE FROM messages WHERE conversation_id = ? AND cree_le >= ?',
      [r.first['conversation_id'], r.first['cree_le']],
    );
    _changements.add(null);
  }

  // ── Lecture ───────────────────────────────────────────────────────────

  /// Les conversations, épinglées d'abord, puis les plus récentes.
  List<ConversationIa> conversations() {
    final r = _db.select('''
      SELECT c.id, c.titre, c.cree_le, c.maj_le, c.epinglee,
             COUNT(m.id) AS n,
             (SELECT contenu FROM messages
              WHERE conversation_id = c.id
              ORDER BY cree_le DESC LIMIT 1) AS apercu
      FROM conversations c
      LEFT JOIN messages m ON m.conversation_id = c.id
      GROUP BY c.id
      ORDER BY c.epinglee DESC, c.maj_le DESC
    ''');
    return [for (final l in r) _versConversation(l)];
  }

  List<MessageStocke> messages(String conversationId) {
    final r = _db.select(
      'SELECT * FROM messages WHERE conversation_id = ? ORDER BY cree_le',
      [conversationId],
    );
    return [for (final l in r) _versMessage(l)];
  }

  /// Les messages marqués comme chapitres — l'index d'une longue
  /// conversation.
  List<MessageStocke> chapitres(String conversationId) {
    final r = _db.select(
      'SELECT * FROM messages WHERE conversation_id = ? AND chapitre = 1 '
      'ORDER BY cree_le',
      [conversationId],
    );
    return [for (final l in r) _versMessage(l)];
  }

  /// Cherche dans tout l'historique. Rend les conversations qui
  /// contiennent [texte], la plus récente d'abord.
  List<ResultatRecherche> chercher(String texte, {int limite = 50}) {
    final t = aplatir(texte);
    if (t.isEmpty) return const [];
    final r = _db.select('''
      SELECT m.id AS mid, m.contenu, m.cree_le AS mdate, m.role,
             c.id, c.titre, c.cree_le, c.maj_le, c.epinglee,
             (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id) AS n
      FROM messages m
      JOIN conversations c ON c.id = m.conversation_id
      WHERE m.contenu_aplati LIKE ?
      ORDER BY m.cree_le DESC
      LIMIT ?
    ''', ['%$t%', limite]);
    return [
      for (final l in r)
        ResultatRecherche(
          conversation: _versConversation(l, apercuColonne: null),
          messageId: l['mid'] as String,
          extrait: _extrait(l['contenu'] as String, t),
          role: l['role'] as String,
          date: DateTime.fromMillisecondsSinceEpoch(l['mdate'] as int),
        ),
    ];
  }

  // ── Détails ───────────────────────────────────────────────────────────

  static ConversationIa _versConversation(
    Row l, {
    String? apercuColonne = 'apercu',
  }) {
    final brut = apercuColonne == null ? null : l[apercuColonne];
    return ConversationIa(
      id: l['id'] as String,
      titre: l['titre'] as String,
      creeLe: DateTime.fromMillisecondsSinceEpoch(l['cree_le'] as int),
      majLe: DateTime.fromMillisecondsSinceEpoch(l['maj_le'] as int),
      epinglee: (l['epinglee'] as int) == 1,
      nbMessages: (l['n'] as int?) ?? 0,
      apercu: brut is String
          ? brut.replaceAll(RegExp(r'\s+'), ' ').trim()
          : '',
    );
  }

  static MessageStocke _versMessage(Row l) {
    List<T> lire<T>(String colonne, T Function(dynamic) f) {
      try {
        final v = jsonDecode(l[colonne] as String? ?? '[]');
        return v is List ? [for (final e in v) f(e)] : <T>[];
      } on FormatException {
        // Une colonne JSON abîmée ne doit pas rendre un message illisible.
        return <T>[];
      }
    }

    return MessageStocke(
      id: l['id'] as String,
      conversationId: l['conversation_id'] as String,
      role: l['role'] as String,
      contenu: l['contenu'] as String,
      creeLe: DateTime.fromMillisecondsSinceEpoch(l['cree_le'] as int),
      origine: l['origine'] == 'enLigne'
          ? OrigineReponse.enLigne
          : OrigineReponse.local,
      reflexion: l['reflexion'] as String?,
      piecesJointes: lire<String>('pieces_jointes', (e) => '$e'),
      etapes: lire<EtapeActivite>(
        'etapes',
        (e) => EtapeActivite.depuisJson(e as Map<String, dynamic>),
      ),
      chapitre: (l['chapitre'] as int? ?? 0) == 1,
    );
  }

  /// Un extrait centré sur le mot trouvé, plutôt que le début du message.
  static String _extrait(String contenu, String terme, {int autour = 60}) {
    final plat = aplatir(contenu);
    final i = plat.indexOf(terme);
    if (i < 0) {
      return contenu.length <= autour * 2
          ? contenu
          : '${contenu.substring(0, autour * 2)}…';
    }
    final debut = (i - autour).clamp(0, contenu.length);
    final fin = (i + terme.length + autour).clamp(0, contenu.length);
    final morceau = contenu.substring(debut, fin).replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
    return '${debut > 0 ? '…' : ''}$morceau${fin < contenu.length ? '…' : ''}';
  }

  /// Sans accents et en minuscules, pour que la recherche trouve quel que
  /// soit le clavier de la personne.
  ///
  /// ⚠️ LA MÊME FONCTION À L'ÉCRITURE ET À LA LECTURE. Si les deux
  /// divergeaient un jour, la recherche ne trouverait plus rien et rien
  /// ne le signalerait.
  static String aplatir(String s) {
    const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
    const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
    final b = StringBuffer();
    for (final c in s.toLowerCase().runes) {
      final ch = String.fromCharCode(c);
      final i = avec.indexOf(ch);
      if (i < 0) {
        b.write(ch);
      } else if (i < sans.length) {
        b.write(sans[i]);
      } else {
        // Les ligatures n'ont pas d'équivalent à une lettre.
        b.write(ch == 'œ' ? 'oe' : 'ae');
      }
    }
    return b.toString();
  }

  static String _id() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${(DateTime.now().hashCode & 0xFFFF).toRadixString(36)}';

  void dispose() {
    _changements.close();
    _db.dispose();
    _instance = null;
  }
}

/// Une ligne de résultat de recherche.
class ResultatRecherche {
  const ResultatRecherche({
    required this.conversation,
    required this.messageId,
    required this.extrait,
    required this.role,
    required this.date,
  });

  final ConversationIa conversation;
  final String messageId;
  final String extrait;
  final String role;
  final DateTime date;
}
