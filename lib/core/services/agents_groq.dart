// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES AGENTS — quel modèle pour quel travail, et qui donne la relève à qui.
//
// ── POURQUOI PLUSIEURS MODÈLES PLUTÔT QU'UN SEUL ──────────────────────
//
// Pas pour faire nombre. Les modèles servis par Groq n'ont pas les mêmes
// LIMITES PHYSIQUES, et c'est ça qui décide :
//
//   • `minimax-m2.7` accepte 196 000 jetons en entrée et en rend 131 000.
//     C'est le SEUL qui puisse lire un livre ou écrire un document entier
//     d'une traite. `gpt-oss-120b` plafonne à 65 000 en sortie : au-delà,
//     il coupe au milieu d'une phrase.
//   • `gpt-oss-120b` est le SEUL à avoir la recherche web et l'exécution
//     de code côté serveur. Aucun autre ne peut chercher ni calculer.
//   • `llama-3.1-8b-instant` répond en une fraction du temps des autres.
//     Pour reformuler une phrase, attendre un modèle de 120 milliards de
//     paramètres est du gaspillage — de temps et d'argent.
//
// Un seul modèle pour tout, c'est soit payer le plus gros pour des tâches
// triviales, soit se cogner au plafond du plus petit sur les grosses.
//
// ── ⚠️ CE QUE GROQ NE SAIT PLUS FAIRE ─────────────────────────────────
//
// AUCUN MODÈLE DE VISION. Llama 4 Scout et Maverick, les seuls qui
// lisaient une image, ont été retirés (17 juillet 2026 et 9 mars 2026).
// `groq/compound`, le système agentique maison, l'a été le 21 septembre
// 2026. Concrètement : l'assistant en ligne ne peut PAS regarder une
// photo. Il peut en PRODUIRE (un schéma, un graphique rendus en image) et
// lire un document texte, pas décrire une photographie.
//
// Ce fichier ne prétend donc à aucun agent « vision ». Le jour où Groq en
// resservira un, il prendra sa place ici et [Agent.vision] cessera d'être
// un commentaire.
//
// ── LA RELÈVE ─────────────────────────────────────────────────────────
//
// Un seul modèle parle à la personne : le CHEF. Il a un outil de plus que
// les autres — `deleguer` — qui exécute une consigne avec le modèle le
// mieux placé et lui rend le résultat. La personne ne voit jamais la
// bascule : elle voit une étape de plus dans le journal d'activité.
//
// ⚠️ ET LE CHEF NE DÉLÈGUE PAS CE QU'IL SAIT FAIRE. Une question courte
// à laquelle il peut répondre part en une phrase ; déléguer coûterait un
// aller-retour complet pour un résultat identique. La consigne du chef
// le dit explicitement, parce qu'un modèle à qui l'on donne un outil a
// tendance à s'en servir.
// ============================================================================

import 'package:flutter/foundation.dart';

/// Ce qu'un agent sait faire de mieux que les autres.
enum Agent {
  /// Le chef : il parle, il raisonne, il appelle les outils, il délègue.
  chef,

  /// Chercher sur le web, avec les citations.
  recherche,

  /// Exécuter du code pour calculer vraiment.
  calcul,

  /// Écrire long : un rapport, un chapitre, un document complet.
  redaction,

  /// Lire long : un contrat, un journal, un gros fichier joint.
  lecture,

  /// Répondre vite : reformuler, corriger, résumer trois lignes.
  rapide,

  /// Écrire du code.
  code,

  /// Traduire, et tout ce qui touche à plusieurs langues.
  traduction,

  /// Relire et resserrer ce qu'un autre a écrit.
  relecture,

  /// Repérer une tentative de détournement dans un texte reçu.
  garde,

  // ⚠️ PAS D'AGENT `vision`. Groq n'a plus de modèle capable de lire une
  // image depuis juillet 2026 (voir l'en-tête). Déclarer l'agent sans le
  // modèle donnerait un rôle qui échoue à chaque appel.
}

/// Ce qu'on sait d'un agent : son modèle, ses limites, et ce pour quoi
/// on le choisit.
@immutable
class FicheAgent {
  const FicheAgent({
    required this.agent,
    required this.modele,
    required this.role,
    required this.pourquoi,
    required this.contexte,
    required this.sortieMax,
    this.outilsIntegres = false,
    this.temperature = 0.7,
    this.effort = 'medium',
  });

  final Agent agent;

  /// L'identifiant exact attendu par l'API.
  final String modele;

  /// Ce qu'on lui demande, en une ligne — c'est ce que le journal montre.
  final String role;

  /// La RAISON du choix, en termes vérifiables. Pas « il est meilleur »,
  /// mais « il est le seul à accepter 196 000 jetons ».
  final String pourquoi;

  final int contexte;
  final int sortieMax;

  /// Vrai pour le seul modèle qui porte `browser_search` et
  /// `code_interpreter`.
  final bool outilsIntegres;

  final double temperature;
  final String effort;
}

/// ⚠️ CETTE TABLE EST LA SEULE VÉRITÉ SUR LES MODÈLES. Aucun autre
/// fichier n'écrit un identifiant de modèle en dur : le jour où Groq en
/// retire un — ce qui arrive plusieurs fois par an, voir les quatre
/// retraits de 2026 — il n'y a qu'ici à changer.
const Map<Agent, FicheAgent> kAgents = {
  Agent.chef: FicheAgent(
    agent: Agent.chef,
    modele: 'openai/gpt-oss-120b',
    role: 'Répond, raisonne et distribue le travail',
    pourquoi: 'Le seul à porter la recherche web et l’exécution de code '
        'côté serveur, et le seul à exposer son raisonnement.',
    contexte: 131072,
    sortieMax: 65536,
    outilsIntegres: true,
  ),
  Agent.recherche: FicheAgent(
    agent: Agent.recherche,
    modele: 'openai/gpt-oss-120b',
    role: 'Cherche sur le web et cite ses sources',
    pourquoi: 'Seul modèle de Groq à disposer de `browser_search`.',
    contexte: 131072,
    sortieMax: 65536,
    outilsIntegres: true,
    // ⚠️ FROID POUR CHERCHER. Une recherche qui invente est pire qu'une
    // recherche vide : on ne peut pas distinguer une source inventée
    // d'une vraie sans aller voir.
    temperature: 0.2,
    effort: 'low',
  ),
  Agent.calcul: FicheAgent(
    agent: Agent.calcul,
    modele: 'openai/gpt-oss-120b',
    role: 'Calcule en exécutant du code',
    pourquoi: 'Seul modèle de Groq à disposer de `code_interpreter`.',
    contexte: 131072,
    sortieMax: 65536,
    outilsIntegres: true,
    temperature: 0.1,
  ),
  Agent.redaction: FicheAgent(
    agent: Agent.redaction,
    modele: 'minimaxai/minimax-m2.7',
    role: 'Écrit les documents longs',
    pourquoi: '131 000 jetons de sortie, contre 65 000 pour le chef : '
        'c’est le seul qui puisse rendre un rapport entier sans couper.',
    contexte: 196608,
    sortieMax: 131072,
    temperature: 0.8,
  ),
  Agent.lecture: FicheAgent(
    agent: Agent.lecture,
    modele: 'minimaxai/minimax-m2.7',
    role: 'Lit les documents longs',
    pourquoi: '196 000 jetons de contexte, la plus grande fenêtre '
        'disponible — un contrat de cent pages y tient.',
    contexte: 196608,
    sortieMax: 131072,
    temperature: 0.3,
  ),
  Agent.rapide: FicheAgent(
    agent: Agent.rapide,
    modele: 'llama-3.1-8b-instant',
    role: 'Répond du tac au tac',
    pourquoi: 'Le plus rapide du catalogue. Reformuler une phrase avec '
        'un modèle de 120 milliards de paramètres est du gaspillage.',
    contexte: 131072,
    sortieMax: 8192,
    temperature: 0.5,
  ),
  Agent.code: FicheAgent(
    agent: Agent.code,
    modele: 'qwen/qwen3.8-27b',
    role: 'Écrit et corrige du code',
    pourquoi: 'La famille Qwen est entraînée davantage sur du code que '
        'les Llama de taille comparable.',
    contexte: 131072,
    sortieMax: 16384,
    // Froid : du code créatif, c’est du code qui ne compile pas.
    temperature: 0.2,
  ),
  Agent.traduction: FicheAgent(
    agent: Agent.traduction,
    modele: 'llama-3.3-70b-versatile',
    role: 'Traduit et travaille entre plusieurs langues',
    pourquoi: 'Le meilleur compromis taille / multilinguisme du '
        'catalogue, et Droplet parle dix langues.',
    contexte: 131072,
    sortieMax: 32768,
    temperature: 0.3,
  ),
  Agent.relecture: FicheAgent(
    agent: Agent.relecture,
    modele: 'openai/gpt-oss-20b',
    role: 'Relit, resserre, vérifie la cohérence',
    pourquoi: 'Assez fin pour juger un texte, assez petit pour que la '
        'relecture ne coûte pas plus cher que l’écriture.',
    contexte: 131072,
    sortieMax: 65536,
    temperature: 0.3,
  ),
  Agent.garde: FicheAgent(
    agent: Agent.garde,
    modele: 'meta-llama/llama-prompt-guard-2-86m',
    role: 'Repère une consigne cachée dans un texte reçu',
    pourquoi: 'Entraîné pour ça et pour rien d’autre : 86 millions de '
        'paramètres, une réponse en quelques millisecondes.',
    // ⚠️ 512 JETONS SEULEMENT. On ne lui donne jamais un document
    // entier : on lui donne le début, là où une injection se place.
    contexte: 512,
    sortieMax: 512,
    temperature: 0,
  ),
};

/// Le modèle du chef, seul identifiant qu'on cite hors de cette table.
String get kModeleChef => kAgents[Agent.chef]!.modele;

/// L'agent désigné par son nom, ou `null` si le nom est inconnu.
///
/// ⚠️ TOLÉRANT AUX APPROXIMATIONS. Un modèle qui délègue écrit « rédaction »
/// ou « redaction » ou « writer » selon son humeur : refuser sec
/// obligerait à un aller-retour de plus pour une faute d'accent.
Agent? agentNomme(String nom) {
  final n = nom.trim().toLowerCase();
  const alias = {
    'chef': Agent.chef,
    'recherche': Agent.recherche,
    'search': Agent.recherche,
    'web': Agent.recherche,
    'calcul': Agent.calcul,
    'calculate': Agent.calcul,
    'code_interpreter': Agent.calcul,
    'redaction': Agent.redaction,
    'rédaction': Agent.redaction,
    'writer': Agent.redaction,
    'lecture': Agent.lecture,
    'reader': Agent.lecture,
    'rapide': Agent.rapide,
    'fast': Agent.rapide,
    'code': Agent.code,
    'coder': Agent.code,
    'traduction': Agent.traduction,
    'translate': Agent.traduction,
    'relecture': Agent.relecture,
    'review': Agent.relecture,
    'garde': Agent.garde,
    'guard': Agent.garde,
  };
  return alias[n] ??
      Agent.values.where((a) => a.name == n).firstOrNull;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// La liste des agents délégables, telle qu'on la donne au chef.
///
/// ⚠️ LE CHEF NE SE DÉLÈGUE PAS À LUI-MÊME, et n'a pas à choisir
/// « recherche » ou « calcul » : ces deux-là sont SES propres outils
/// intégrés. Les lui proposer comme agents distincts lui ferait faire un
/// aller-retour pour ce qu'il peut faire sur place.
List<Agent> get agentsDelegables => [
      Agent.redaction,
      Agent.lecture,
      Agent.rapide,
      Agent.code,
      Agent.traduction,
      Agent.relecture,
    ];

/// Le catalogue en texte, tel qu'il entre dans la consigne du chef.
String cataloguePourLeChef() {
  final b = StringBuffer(
    'Tu peux confier une tâche à un collègue avec l’outil `deleguer`. '
    'Les collègues disponibles :\n',
  );
  for (final a in agentsDelegables) {
    final f = kAgents[a]!;
    b.writeln('- `${a.name}` : ${f.role}. ${f.pourquoi}');
  }
  b
    ..writeln()
    ..writeln(
      '⚠️ Ne délègue PAS ce que tu sais faire toi-même. Une question '
      'courte, une explication, un avis : réponds directement. Délègue '
      'seulement quand la tâche dépasse tes limites — un document de '
      'plus de dix pages (`redaction`), un fichier joint très long '
      '(`lecture`), du code d’une certaine ampleur (`code`) — ou quand '
      'une relecture par un autre apporte vraiment quelque chose '
      '(`relecture`).',
    );
  return b.toString();
}
