// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES ARTÉFACTS — ce que l'assistant PRODUIT, sorti du fil de la
// conversation et gardé à part.
//
// ── POURQUOI SORTIR LE CONTENU LONG DU FIL ────────────────────────────
//
// C'est l'idée qu'Anthropic a introduite et que tout le monde a copiée
// depuis : une page web de deux cents lignes, un tableau de données, un
// script — collés dans une bulle, ils noient les vingt messages
// précédents et il faut faire défiler une minute pour retrouver ce qu'on
// disait avant. Sortis dans leur propre surface, ils sont consultables,
// modifiables, partageables, et le fil reste lisible.
//
// ⚠️ LE SEUIL COMPTE AUTANT QUE L'IDÉE. Un artéfact pour trois lignes de
// code serait pire que pas d'artéfact du tout : on obligerait à ouvrir un
// écran pour lire ce qui tenait sous les yeux. Voir [meriteArtefact].
//
// ── LES VERSIONS ──────────────────────────────────────────────────────
//
// Demander « rends-le plus court » ne remplace pas l'artéfact, il en
// crée une version. On garde les précédentes : c'est la seule façon de
// revenir en arrière quand la modification a tout gâché, et c'est aussi
// ce qui permet de comparer. Claude le fait, et c'est sa fonctionnalité
// la plus utilisée après le texte lui-même.
//
// ── OÙ ÇA VIT ─────────────────────────────────────────────────────────
//
// Dans la même base que les conversations (`assistant_ia.db`), pour la
// raison expliquée là-bas : aucun lien avec le schéma du mesh, donc
// aucune raison d'imposer une migration à toute l'application.
// ============================================================================

import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Ce qu'un artéfact contient — ce qui décide comment on l'affiche.
enum GenreArtefact {
  /// Une page complète, qu'on peut afficher pour de vrai.
  page,

  /// Du code dans un langage quelconque.
  code,

  /// Du texte long : un document, un article, une note.
  document,

  /// Un diagramme décrit en texte (Mermaid, DOT).
  schema,

  /// Des données tabulaires.
  donnees,
}

GenreArtefact genreDepuis(String s) => switch (s) {
      'page' => GenreArtefact.page,
      'code' => GenreArtefact.code,
      'schema' => GenreArtefact.schema,
      'donnees' => GenreArtefact.donnees,
      _ => GenreArtefact.document,
    };

/// Un artéfact, dans sa version courante.
class Artefact {
  const Artefact({
    required this.id,
    required this.conversationId,
    required this.titre,
    required this.genre,
    required this.langage,
    required this.contenu,
    required this.version,
    required this.nbVersions,
    required this.creeLe,
    required this.majLe,
  });

  final String id;
  final String conversationId;
  final String titre;
  final GenreArtefact genre;

  /// `dart`, `python`, `html`… Vide quand ça n'a pas de sens.
  final String langage;
  final String contenu;

  /// Le numéro de la version affichée, à partir de 1.
  final int version;
  final int nbVersions;
  final DateTime creeLe;
  final DateTime majLe;
}

/// Est-ce que ça mérite de sortir du fil ?
///
/// ⚠️ TROIS RÈGLES, PAS UNE. Un seuil de longueur seul sortirait un
/// paragraphe un peu bavard ; un critère de langage seul sortirait un
/// `print("bonjour")`. Il faut que ce soit ASSEZ LONG pour gêner dans le
/// fil, ET structuré au point qu'on veuille le relire ou le reprendre.
///
/// Les nombres viennent de l'usage, pas d'une théorie : quinze lignes,
/// c'est le moment où une bulle commence à occuper tout l'écran d'un
/// téléphone ; six cents caractères, c'est un paragraphe long. Une page
/// web sort toujours, même courte, parce qu'on veut la VOIR, pas la lire.
bool meriteArtefact({
  required String contenu,
  required GenreArtefact genre,
}) {
  if (genre == GenreArtefact.page || genre == GenreArtefact.schema) {
    return true;
  }
  final lignes = '\n'.allMatches(contenu).length + 1;
  if (genre == GenreArtefact.code) return lignes >= 15;
  if (genre == GenreArtefact.donnees) return lignes >= 8;
  return contenu.length >= 600 && lignes >= 12;
}

class ArtefactsStore {
  ArtefactsStore._(this._db);

  final Database _db;
  static ArtefactsStore? _instance;

  final _changements = StreamController<void>.broadcast();
  Stream<void> get changements => _changements.stream;

  static Future<ArtefactsStore> ouvrir() async {
    if (_instance != null) return _instance!;
    final dossier = await getApplicationDocumentsDirectory();
    final db = sqlite3.open(p.join(dossier.path, 'assistant_ia.db'));
    db.execute('PRAGMA journal_mode=WAL');
    _creerTables(db);
    return _instance = ArtefactsStore._(db);
  }

  static void _creerTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS artefacts (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        titre TEXT NOT NULL,
        genre TEXT NOT NULL,
        langage TEXT NOT NULL DEFAULT '',
        cree_le INTEGER NOT NULL,
        maj_le INTEGER NOT NULL
      )
    ''');
    // Les versions dans leur propre table : une ligne par état successif.
    // Écraser la colonne `contenu` d'un artéfact aurait été plus simple
    // et aurait rendu tout retour en arrière impossible.
    db.execute('''
      CREATE TABLE IF NOT EXISTS artefact_versions (
        id TEXT PRIMARY KEY,
        artefact_id TEXT NOT NULL
          REFERENCES artefacts(id) ON DELETE CASCADE,
        numero INTEGER NOT NULL,
        contenu TEXT NOT NULL,
        cree_le INTEGER NOT NULL
      )
    ''');
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_art_conv '
      'ON artefacts(conversation_id, maj_le)',
    );
    db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_art_ver '
      'ON artefact_versions(artefact_id, numero)',
    );
  }

  // ── Écriture ──────────────────────────────────────────────────────────

  /// Crée un artéfact avec sa première version.
  String creer({
    required String conversationId,
    required String titre,
    required GenreArtefact genre,
    required String contenu,
    String langage = '',
  }) {
    final id = _id();
    final t = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      'INSERT INTO artefacts (id, conversation_id, titre, genre, langage, '
      'cree_le, maj_le) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, conversationId, titre, genre.name, langage, t, t],
    );
    _db.execute(
      'INSERT INTO artefact_versions (id, artefact_id, numero, contenu, '
      'cree_le) VALUES (?, ?, 1, ?, ?)',
      [_id(), id, contenu, t],
    );
    _changements.add(null);
    return id;
  }

  /// Ajoute une version. Rend son numéro.
  int ajouterVersion(String artefactId, String contenu) {
    final r = _db.select(
      'SELECT COALESCE(MAX(numero), 0) AS n FROM artefact_versions '
      'WHERE artefact_id = ?',
      [artefactId],
    );
    final numero = (r.first['n'] as int) + 1;
    final t = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      'INSERT INTO artefact_versions (id, artefact_id, numero, contenu, '
      'cree_le) VALUES (?, ?, ?, ?, ?)',
      [_id(), artefactId, numero, contenu, t],
    );
    _db.execute('UPDATE artefacts SET maj_le = ? WHERE id = ?', [
      t,
      artefactId,
    ]);
    _changements.add(null);
    return numero;
  }

  void renommer(String artefactId, String titre) {
    _db.execute('UPDATE artefacts SET titre = ? WHERE id = ?', [
      titre.trim(),
      artefactId,
    ]);
    _changements.add(null);
  }

  void supprimer(String artefactId) {
    // ⚠️ `foreign_keys` N'EST PAS ACTIVÉ SUR CETTE CONNEXION quand elle
    // est ouverte séparément de celle des conversations. On efface donc
    // les versions explicitement au lieu de compter sur la cascade — une
    // cascade qu'on croit active et qui ne l'est pas laisse des orphelins
    // que personne ne voit avant que la base ait doublé de taille.
    _db.execute(
      'DELETE FROM artefact_versions WHERE artefact_id = ?',
      [artefactId],
    );
    _db.execute('DELETE FROM artefacts WHERE id = ?', [artefactId]);
    _changements.add(null);
  }

  // ── Lecture ───────────────────────────────────────────────────────────

  /// Tous les artéfacts, les plus récents d'abord.
  List<Artefact> tous({String? conversationId}) {
    final r = conversationId == null
        ? _db.select('SELECT * FROM artefacts ORDER BY maj_le DESC')
        : _db.select(
            'SELECT * FROM artefacts WHERE conversation_id = ? '
            'ORDER BY maj_le DESC',
            [conversationId],
          );
    return [for (final l in r) _charger(l, null)!];
  }

  /// Un artéfact dans une version donnée, ou la dernière si [version]
  /// est nul.
  Artefact? lire(String artefactId, {int? version}) {
    final r = _db.select('SELECT * FROM artefacts WHERE id = ?', [artefactId]);
    if (r.isEmpty) return null;
    return _charger(r.first, version);
  }

  Artefact? _charger(Row l, int? version) {
    final id = l['id'] as String;
    final versions = _db.select(
      'SELECT numero, contenu FROM artefact_versions WHERE artefact_id = ? '
      'ORDER BY numero',
      [id],
    );
    if (versions.isEmpty) return null;
    final choisie = version == null
        ? versions.last
        : versions.firstWhere(
            (v) => v['numero'] == version,
            orElse: () => versions.last,
          );
    return Artefact(
      id: id,
      conversationId: l['conversation_id'] as String,
      titre: l['titre'] as String,
      genre: genreDepuis(l['genre'] as String),
      langage: l['langage'] as String? ?? '',
      contenu: choisie['contenu'] as String,
      version: choisie['numero'] as int,
      nbVersions: versions.length,
      creeLe: DateTime.fromMillisecondsSinceEpoch(l['cree_le'] as int),
      majLe: DateTime.fromMillisecondsSinceEpoch(l['maj_le'] as int),
    );
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

// ══ RECONNAÎTRE UN ARTÉFACT DANS UNE RÉPONSE ════════════════════════════

/// Un bloc de code repéré dans du Markdown.
class BlocDetecte {
  const BlocDetecte({
    required this.langage,
    required this.contenu,
    required this.debut,
    required this.fin,
  });

  final String langage;
  final String contenu;

  /// Les bornes dans le texte d'origine, pour pouvoir le retirer.
  final int debut;
  final int fin;

  GenreArtefact get genre => switch (langage.toLowerCase()) {
        'html' || 'svg' => GenreArtefact.page,
        'mermaid' || 'dot' || 'graphviz' => GenreArtefact.schema,
        'csv' || 'tsv' => GenreArtefact.donnees,
        '' => GenreArtefact.document,
        _ => GenreArtefact.code,
      };
}

/// Trouve les blocs clôturés d'une réponse.
///
/// ⚠️ ON N'ACCEPTE QUE LES BLOCS FERMÉS. Pendant que la réponse s'écrit,
/// le dernier bloc n'a pas encore sa clôture : le sortir tout de suite
/// créerait un artéfact qui grandit sous les yeux puis se dédouble quand
/// le vrai arrive. On attend la fermeture.
List<BlocDetecte> detecterBlocs(String markdown) {
  final motif = RegExp(
    r'^```([\w+-]*)[ \t]*\r?\n(.*?)^```[ \t]*$',
    multiLine: true,
    dotAll: true,
  );
  return [
    for (final m in motif.allMatches(markdown))
      BlocDetecte(
        langage: m[1] ?? '',
        contenu: (m[2] ?? '').trimRight(),
        debut: m.start,
        fin: m.end,
      ),
  ];
}

/// Un titre lisible pour un bloc, faute de mieux.
String titrePour(BlocDetecte bloc, String contexte) {
  // La dernière phrase avant le bloc est presque toujours ce que la
  // personne a demandé : « voici le script qui… ». C'est un meilleur
  // titre que « Code » répété six fois dans la liste.
  final avant = contexte.substring(0, bloc.debut).trimRight();
  final lignes = avant.split('\n').reversed;
  for (final l in lignes) {
    final t = l.replaceAll(RegExp(r'^#{1,6}\s+|[*_`:]'), '').trim();
    if (t.length >= 4 && t.length <= 70) return t;
  }
  return bloc.langage.isEmpty ? 'Document' : bloc.langage.toUpperCase();
}
