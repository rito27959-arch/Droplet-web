// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CE QUE L'ASSISTANT SAIT FAIRE — la liste des outils, et leur exécution.
//
// ── DEUX FAMILLES, ET C'EST LA DISTINCTION QUI COMPTE ─────────────────
//
// 1. LES OUTILS DE GROQ, exécutés SUR LEURS SERVEURS. `browser_search`
//    (chercher sur le web, avec les citations) et `code_interpreter`
//    (exécuter du Python pour calculer vraiment). On les DÉCLARE, on ne
//    les écrit pas : Groq les exécute et renvoie la réponse finie.
//
//    ⚠️ CONSÉQUENCE À NE PAS PERDRE DE VUE : ces deux outils n'existent
//    QUE dans le mode en ligne. Un assistant local ne cherche pas sur le
//    web et n'exécute pas de Python. Ce n'est pas une régression à
//    corriger un jour, c'est la définition même du mode local.
//
// 2. LES OUTILS DE DROPLET, exécutés SUR LE TÉLÉPHONE. Lire un fichier
//    joint, en produire un. Ceux-là ne peuvent PAS partir chez Groq :
//    les fichiers sont ici. On les déclare au modèle, il demande, on
//    exécute, on renvoie le résultat, il continue.
//
// ── POURQUOI PAS DE MOTEUR DE RECHERCHE À NOUS ────────────────────────
//
// La tentation était d'appeler un moteur de recherche directement et de
// lire les pages nous-mêmes. Trois raisons de ne pas le faire : il
// faudrait une deuxième clé API (donc un deuxième compte à créer, donc
// une friction de plus), il faudrait analyser du HTML qui change sans
// prévenir, et Groq renvoie déjà les citations. On ne réécrit pas ce qui
// existe et qui est maintenu par quelqu'un d'autre.
//
// ── LE FLUX ET LES OUTILS INTÉGRÉS ────────────────────────────────────
//
// ⚠️ LA DOCUMENTATION DE GROQ MONTRE `stream: false` DANS TOUS SES
// EXEMPLES D'OUTILS INTÉGRÉS, sans dire si le flux marche. On ne parie
// pas : quand un outil intégré est armé, la requête part SANS flux, et
// c'est le journal d'activité qui occupe l'attente — ce pour quoi il a
// été écrit. Le jour où Groq documente le flux avec outils, il suffira
// de supprimer [contraintSansFlux].
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'agents_groq.dart';
import 'conversations_ia_store.dart';

// ══ LES OUTILS DE GROQ ══════════════════════════════════════════════════

/// Chercher sur le web. Exécuté chez Groq, citations comprises.
const Map<String, dynamic> kOutilRechercheWeb = {'type': 'browser_search'};

/// Exécuter du Python pour calculer. Exécuté chez Groq.
const Map<String, dynamic> kOutilCode = {'type': 'code_interpreter'};

/// Vrai dès qu'un outil intégré est dans la liste — donc pas de flux.
bool contraintSansFlux(List<Map<String, dynamic>> outils) =>
    outils.any((o) => o['type'] == 'browser_search' || o['type'] == 'code_interpreter');

// ══ LES OUTILS DE DROPLET ═══════════════════════════════════════════════

/// Le format de déclaration d'une fonction, tel que l'API l'attend.
Map<String, dynamic> _fonction(
  String nom,
  String description,
  Map<String, dynamic> proprietes,
  List<String> requis,
) =>
    {
      'type': 'function',
      'function': {
        'name': nom,
        'description': description,
        'parameters': {
          'type': 'object',
          'properties': proprietes,
          'required': requis,
        },
      },
    };

/// Lire un fichier que la personne a joint.
///
/// ⚠️ LE MODÈLE NE CHOISIT PAS LE CHEMIN, IL CHOISIT UN NUMÉRO. Si on
/// lui laissait écrire un chemin, il pourrait en inventer un — et une
/// application qui ouvre un chemin dicté par un modèle est une
/// application qui lit ce qu'on lui dit de lire. Les pièces jointes sont
/// numérotées ; tout numéro hors liste est refusé.
final Map<String, dynamic> kOutilLireJointe = _fonction(
  'lire_piece_jointe',
  'Lit le contenu d’une pièce jointe fournie par la personne. '
      'Utiliser le numéro indiqué dans la liste des pièces jointes.',
  {
    'numero': {
      'type': 'integer',
      'description': 'Le numéro de la pièce jointe, à partir de 1.',
    },
  },
  ['numero'],
);

/// Produire un fichier et le remettre à la personne.
final Map<String, dynamic> kOutilEcrireFichier = _fonction(
  'produire_fichier',
  'Produit un fichier que la personne pourra ouvrir ou partager. '
      'À utiliser dès qu’on demande un document, un tableau, une archive '
      'ou du code à garder — pas pour une réponse courte, qui va dans le '
      'texte.',
  {
    'nom': {
      'type': 'string',
      'description': 'Le nom du fichier avec son extension, par exemple '
          '« rapport.pdf », « donnees.csv », « script.py ».',
    },
    'format': {
      'type': 'string',
      'enum': ['txt', 'md', 'csv', 'json', 'html', 'code', 'pdf', 'docx',
               'pptx', 'zip'],
      'description': 'Le format à produire.',
    },
    'contenu': {
      'type': 'string',
      'description': 'Le contenu. Pour pdf, docx et pptx : du Markdown, '
          'qui sera mis en page. Pour zip : un objet JSON dont chaque clé '
          'est un chemin dans l’archive et chaque valeur son contenu.',
    },
  },
  ['nom', 'format', 'contenu'],
);

/// Confier une tâche au collègue le mieux placé.
final Map<String, dynamic> kOutilDeleguer = _fonction(
  'deleguer',
  'Confie une tâche à un collègue spécialisé et rend son résultat. '
      'À n’employer que lorsque la tâche dépasse tes propres limites — '
      'un très long document, un très long fichier à lire, du code '
      'conséquent — ou qu’une relecture par un autre apporte vraiment '
      'quelque chose.',
  {
    'collegue': {
      'type': 'string',
      'enum': [for (final a in agentsDelegables) a.name],
      'description': 'Le collègue à qui confier la tâche.',
    },
    'consigne': {
      'type': 'string',
      'description': 'La tâche, écrite comme à quelqu’un qui n’a pas '
          'suivi la conversation : tout ce qu’il lui faut pour '
          'travailler doit être dans cette consigne.',
    },
  },
  ['collegue', 'consigne'],
);

/// Produire un projet entier : plusieurs fichiers dans une archive.
///
/// ⚠️ SÉPARÉ DE `produire_fichier`, ET C'EST VOULU. Un projet n'est pas
/// un gros fichier : c'est une ARBORESCENCE, où chaque fichier a une
/// place et où le tout doit se tenir. Laisser le modèle produire un zip
/// par l'outil générique reviendrait à lui demander d'écrire du JSON
/// d'archive à la main dans un champ de texte — ce qu'il fait, mal, en
/// oubliant un fichier sur trois.
final Map<String, dynamic> kOutilProjet = _fonction(
  'creer_projet',
  'Crée un projet complet : plusieurs fichiers organisés en dossiers, '
      'remis dans une archive. À employer dès qu’on demande un site, '
      'une application, un jeu de documents, ou tout ce qui ne tient '
      'pas dans un seul fichier.',
  {
    'nom': {
      'type': 'string',
      'description': 'Le nom du projet, qui devient celui de l’archive.',
    },
    'fichiers': {
      'type': 'array',
      'description': 'Les fichiers du projet, dans l’ordre où on les '
          'lit. Chacun doit être COMPLET : pas de « … » ni de « à '
          'compléter ».',
      'items': {
        'type': 'object',
        'properties': {
          'chemin': {
            'type': 'string',
            'description': 'Le chemin dans l’archive, dossiers compris, '
                'par exemple « src/main.dart » ou « docs/README.md ».',
          },
          'contenu': {'type': 'string'},
        },
        'required': ['chemin', 'contenu'],
      },
    },
  },
  ['nom', 'fichiers'],
);

/// Se souvenir d'un fait sur la personne, d'une conversation à l'autre.
final Map<String, dynamic> kOutilMemoriser = _fonction(
  'memoriser',
  'Retient un fait durable sur la personne (son prénom, son métier, une '
      'préférence). Ne PAS retenir un détail de la conversation en cours, '
      'ni quoi que ce soit de sensible.',
  {
    'fait': {
      'type': 'string',
      'description': 'Le fait, en une phrase à la troisième personne.',
    },
  },
  ['fait'],
);

/// La liste des outils à déclarer, selon le contexte.
///
/// ⚠️ ON N'ARME QUE CE QUI PEUT SERVIR. Déclarer `lire_piece_jointe`
/// quand il n'y a aucune pièce jointe pousse le modèle à l'appeler « au
/// cas où », ce qui coûte un aller-retour et produit une erreur. Chaque
/// outil déclaré est un outil que le modèle croit utile.
List<Map<String, dynamic>> outilsPour({
  required bool enLigne,
  required int nbPiecesJointes,
  bool memoireActive = true,
  bool peutDeleguer = true,
}) =>
    [
      if (enLigne) ...[kOutilRechercheWeb, kOutilCode],
      if (nbPiecesJointes > 0) kOutilLireJointe,
      kOutilEcrireFichier,
      if (enLigne) kOutilProjet,
      // ⚠️ SEUL LE CHEF DÉLÈGUE. Un collègue à qui l'on donnerait cet
      // outil pourrait déléguer à son tour, et deux modèles qui se
      // renvoient la balle consomment un quota entier sans rien rendre.
      if (enLigne && peutDeleguer) kOutilDeleguer,
      if (memoireActive) kOutilMemoriser,
    ];

// ══ L'EXÉCUTION ═════════════════════════════════════════════════════════

/// Ce qu'un outil renvoie : le texte rendu au modèle, et la ligne à
/// afficher dans le journal.
@immutable
class ResultatOutil {
  const ResultatOutil({
    required this.pourLeModele,
    required this.etape,
    this.fichierProduit,
  });

  final String pourLeModele;
  final EtapeActivite etape;

  /// Le chemin du fichier créé, quand l'outil en a créé un.
  final String? fichierProduit;
}

/// Exécute un outil de Droplet.
///
/// [piecesJointes] est la liste ordonnée des chemins que la personne a
/// joints — c'est elle qui fait autorité, pas ce que le modèle écrit.
class ExecuteurOutils {
  ExecuteurOutils({
    required this.piecesJointes,
    required this.lireFichier,
    required this.produireFichier,
    required this.memoriser,
    this.deleguer,
    this.creerProjet,
  });

  final List<String> piecesJointes;

  /// Lit un fichier local et en rend le texte. Fourni par l'appelant
  /// parce que la lecture d'un PDF ou d'une image dépend de l'écran.
  final Future<String> Function(String chemin) lireFichier;

  /// Produit un fichier et rend son chemin.
  final Future<String> Function(
    String nom,
    String format,
    String contenu,
  ) produireFichier;

  final Future<void> Function(String fait) memoriser;

  /// Exécute une consigne avec un autre agent et rend son texte.
  /// Nul quand la délégation n'est pas armée (mode local).
  final Future<String> Function(Agent agent, String consigne)? deleguer;

  /// Empaquette un projet et rend le chemin de l'archive.
  final Future<String> Function(String nom, Map<String, String> fichiers)?
      creerProjet;

  Future<ResultatOutil> executer(String nom, Map<String, dynamic> args) async {
    try {
      switch (nom) {
        case 'lire_piece_jointe':
          return await _lire(args);
        case 'produire_fichier':
          return await _produire(args);
        case 'memoriser':
          return await _memoriser(args);
        case 'deleguer':
          return await _deleguer(args);
        case 'creer_projet':
          return await _projet(args);
        default:
          // Un modèle peut inventer un nom d'outil. On le lui dit
          // plutôt que de lever une exception : il se corrige au tour
          // suivant, là où une exception tuerait la réponse.
          return ResultatOutil(
            pourLeModele: 'Outil inconnu : $nom.',
            etape: EtapeActivite(
              outil: nom,
              resume: 'Outil inconnu : $nom',
              reussi: false,
            ),
          );
      }
    } on Object catch (e) {
      return ResultatOutil(
        pourLeModele: 'L’outil a échoué : $e',
        etape: EtapeActivite(
          outil: nom,
          resume: 'Échec de $nom',
          detail: '$e',
          reussi: false,
        ),
      );
    }
  }

  Future<ResultatOutil> _lire(Map<String, dynamic> args) async {
    final n = args['numero'];
    final i = n is int ? n - 1 : int.tryParse('$n').let((v) => v - 1) ?? -1;
    if (i < 0 || i >= piecesJointes.length) {
      return ResultatOutil(
        pourLeModele: 'Il n’y a pas de pièce jointe numéro $n. '
            'Il y en a ${piecesJointes.length}.',
        etape: EtapeActivite(
          outil: 'lire_piece_jointe',
          resume: 'Pièce jointe $n introuvable',
          reussi: false,
        ),
      );
    }
    final chemin = piecesJointes[i];
    final texte = await lireFichier(chemin);
    final nom = chemin.split(Platform.pathSeparator).last;
    // ⚠️ ON BORNE. Un PDF de 200 pages dépasserait à lui seul la fenêtre
    // de contexte et ferait échouer la requête entière, sans message
    // utile. Mieux vaut un extrait annoncé qu'un échec silencieux.
    const maximum = 60000;
    final coupe = texte.length > maximum;
    return ResultatOutil(
      pourLeModele: coupe
          ? '${texte.substring(0, maximum)}\n\n[Document tronqué : '
              '${texte.length} caractères au total.]'
          : texte,
      etape: EtapeActivite(
        outil: 'lire_piece_jointe',
        resume: coupe ? 'Lu $nom (extrait)' : 'Lu $nom',
        detail: '${texte.length} caractères',
      ),
    );
  }

  Future<ResultatOutil> _produire(Map<String, dynamic> args) async {
    final nom = '${args['nom'] ?? 'fichier'}';
    final format = '${args['format'] ?? 'txt'}';
    final contenu = '${args['contenu'] ?? ''}';
    if (contenu.trim().isEmpty) {
      return const ResultatOutil(
        pourLeModele: 'Le contenu était vide, aucun fichier créé.',
        etape: EtapeActivite(
          outil: 'produire_fichier',
          resume: 'Contenu vide, rien produit',
          reussi: false,
        ),
      );
    }
    final chemin = await produireFichier(nom, format, contenu);
    final octets = await File(chemin).length();
    return ResultatOutil(
      pourLeModele: 'Fichier « $nom » créé et remis à la personne. '
          'Ne pas recopier son contenu dans la réponse.',
      etape: EtapeActivite(
        outil: 'produire_fichier',
        resume: 'Produit $nom',
        detail: '${_taille(octets)} · $format',
      ),
      fichierProduit: chemin,
    );
  }

  Future<ResultatOutil> _deleguer(Map<String, dynamic> args) async {
    final f = deleguer;
    final nom = '${args['collegue'] ?? ''}';
    final consigne = '${args['consigne'] ?? ''}'.trim();
    if (f == null) {
      return const ResultatOutil(
        pourLeModele: 'La délégation n’est pas disponible ici. '
            'Fais-le toi-même.',
        etape: EtapeActivite(
          outil: 'deleguer',
          resume: 'Délégation indisponible',
          reussi: false,
        ),
      );
    }
    final agent = agentNomme(nom);
    if (agent == null || consigne.isEmpty) {
      return ResultatOutil(
        pourLeModele: 'Collègue inconnu : « $nom ». Les collègues sont : '
            '${agentsDelegables.map((a) => a.name).join(', ')}.',
        etape: EtapeActivite(
          outil: 'deleguer',
          resume: 'Collègue inconnu : $nom',
          reussi: false,
        ),
      );
    }
    final fiche = kAgents[agent]!;
    final texte = await f(agent, consigne);
    return ResultatOutil(
      pourLeModele: texte,
      etape: EtapeActivite(
        outil: 'deleguer',
        // Le journal nomme le RÔLE, pas le modèle : « Confié à la
        // rédaction » se comprend, « minimaxai/minimax-m2.7 » non.
        resume: 'Confié à : ${fiche.role.toLowerCase()}',
        detail: '${fiche.modele}\n\n$consigne',
      ),
    );
  }

  Future<ResultatOutil> _projet(Map<String, dynamic> args) async {
    final f = creerProjet;
    final nom = '${args['nom'] ?? 'projet'}';
    final brut = args['fichiers'];
    if (f == null || brut is! List || brut.isEmpty) {
      return const ResultatOutil(
        pourLeModele: 'Aucun fichier fourni, rien n’a été créé.',
        etape: EtapeActivite(
          outil: 'creer_projet',
          resume: 'Projet vide, rien produit',
          reussi: false,
        ),
      );
    }
    final fichiers = <String, String>{};
    for (final e in brut) {
      if (e is! Map) continue;
      final chemin = '${e['chemin'] ?? ''}'.trim();
      if (chemin.isEmpty) continue;
      fichiers[chemin] = '${e['contenu'] ?? ''}';
    }
    if (fichiers.isEmpty) {
      return const ResultatOutil(
        pourLeModele: 'Aucun chemin valide, rien n’a été créé.',
        etape: EtapeActivite(
          outil: 'creer_projet',
          resume: 'Aucun chemin valide',
          reussi: false,
        ),
      );
    }
    final chemin = await f(nom, fichiers);
    final lignes = fichiers.values
        .map((c) => '\n'.allMatches(c).length + 1)
        .fold<int>(0, (a, b) => a + b);
    return ResultatOutil(
      pourLeModele: 'Projet « $nom » créé : ${fichiers.length} fichiers, '
          'remis à la personne. Ne pas recopier leur contenu dans la '
          'réponse — dis en deux phrases ce que contient le projet.',
      etape: EtapeActivite(
        outil: 'creer_projet',
        resume: 'Projet $nom · ${fichiers.length} fichiers',
        detail: fichiers.keys.join('\n'),
      ),
      fichierProduit: chemin,
    );
  }

  Future<ResultatOutil> _memoriser(Map<String, dynamic> args) async {
    final fait = '${args['fait'] ?? ''}'.trim();
    if (fait.isEmpty) {
      return const ResultatOutil(
        pourLeModele: 'Rien à retenir.',
        etape: EtapeActivite(
          outil: 'memoriser',
          resume: 'Rien à retenir',
          reussi: false,
        ),
      );
    }
    await memoriser(fait);
    return ResultatOutil(
      pourLeModele: 'Retenu.',
      etape: EtapeActivite(outil: 'memoriser', resume: 'Retenu : $fait'),
    );
  }

  static String _taille(int octets) {
    if (octets < 1024) return '$octets o';
    if (octets < 1024 * 1024) return '${(octets / 1024).toStringAsFixed(0)} Ko';
    return '${(octets / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }
}

extension<T> on T? {
  R? let<R>(R Function(T) f) {
    final v = this;
    return v == null ? null : f(v);
  }
}

// ══ LES CITATIONS DE LA RECHERCHE WEB ═══════════════════════════════════

/// Une source citée par la recherche web.
@immutable
class Citation {
  const Citation({required this.titre, required this.url});
  final String titre;
  final String url;
}

/// Un texte nettoyé, et les sources qu'il citait.
@immutable
class TexteCite {
  const TexteCite(this.texte, this.citations);
  final String texte;
  final List<Citation> citations;
}

/// Sort les citations du texte et les rend à part.
///
/// ⚠️ GROQ LES INSÈRE DANS LE TEXTE, PAS DANS UN CHAMP. Elles arrivent
/// sous la forme `【…†…】` — des caractères CJK, pas des crochets ASCII.
/// Laissées telles quelles, elles s'affichent comme des rectangles au
/// milieu des phrases sur un téléphone dont la police n'a pas ces
/// glyphes. On les retire du corps et on les remet en bas, numérotées,
/// où l'on peut les toucher.
///
/// Le format n'étant pas documenté champ par champ, cette fonction est
/// TOLÉRANTE : tout ce qui ne ressemble pas à une citation est laissé
/// intact plutôt que deviné.
TexteCite extraireCitations(String texte) {
  final motif = RegExp('【([^】]*)】');
  final sources = <String, int>{};
  final citations = <Citation>[];

  final nettoye = texte.replaceAllMapped(motif, (m) {
    final brut = (m[1] ?? '').trim();
    if (brut.isEmpty) return '';
    // « titre†emplacement » ou « titre†url ». Le séparateur est U+2020.
    final parties = brut.split('†');
    final titre = parties.first.trim();
    final reste = parties.length > 1 ? parties[1].trim() : '';
    final url = reste.startsWith('http') ? reste : '';
    if (titre.isEmpty && url.isEmpty) return '';
    final cle = url.isNotEmpty ? url : titre;
    final rang = sources.putIfAbsent(cle, () {
      citations.add(Citation(titre: titre.isEmpty ? cle : titre, url: url));
      return citations.length;
    });
    return '[$rang]';
  });

  return TexteCite(nettoye, citations);
}

/// Les sources rendues en Markdown, à coller sous une réponse.
String citationsEnMarkdown(List<Citation> citations) {
  if (citations.isEmpty) return '';
  final b = StringBuffer();
  for (var i = 0; i < citations.length; i++) {
    final c = citations[i];
    b.writeln(c.url.isEmpty
        ? '${i + 1}. ${c.titre}'
        : '${i + 1}. [${c.titre}](${c.url})');
  }
  return b.toString().trimRight();
}

/// Décode les arguments d'un appel d'outil sans jamais lever.
Map<String, dynamic> argumentsSurs(String brut) {
  try {
    final v = jsonDecode(brut);
    return v is Map<String, dynamic> ? v : <String, dynamic>{};
  } on FormatException {
    return <String, dynamic>{};
  }
}
