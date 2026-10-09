// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ASSISTANT EN LIGNE — le pendant distant de `ai_assistant_service.dart`,
// qui lui tourne entièrement sur le téléphone.
//
// ── POURQUOI LES DEUX, ET PAS UN SEUL ─────────────────────────────────
//
// Gemma 3 1B tient dans la poche et répond sans réseau : c'est ce qui
// fait que l'assistant de Droplet existe encore en zone blanche. Mais un
// modèle d'un milliard de paramètres ne raisonne pas comme un modèle de
// cent vingt. Les deux ne se remplacent pas, ils se complètent, et c'est
// la personne qui choisit — jamais l'application dans son dos.
//
// ⚠️ LE LOCAL RESTE LE DÉFAUT. Un message envoyé en ligne quitte le
// téléphone ; un message envoyé au modèle local n'en sort jamais. Cette
// différence est trop importante pour être décidée par une heuristique de
// qualité de réseau. Droplet ne bascule donc JAMAIS tout seul : il
// propose, après coup, quand une réponse locale a échoué ou a été jugée
// insuffisante par la personne elle-même.
//
// ── LE MODÈLE : GPT-OSS 120B SUR GROQ ─────────────────────────────────
//
// `openai/gpt-oss-120b` est un modèle à poids ouverts (licence Apache
// 2.0), servi par Groq sur ses accélérateurs. Deux raisons de l'avoir
// choisi plutôt qu'un modèle propriétaire :
//
//   • LA VITESSE. Groq sert ce modèle à plusieurs centaines de jetons par
//     seconde. Une réponse qui s'écrit plus vite qu'on ne lit change la
//     sensation d'un assistant bien plus que quelques points de score.
//   • LES POIDS SONT OUVERTS. Le jour où Groq ferme, augmente ses prix ou
//     change ses conditions, le même modèle tourne ailleurs — chez un
//     autre hébergeur, ou sur une machine à soi. Aucun autre fournisseur
//     ne peut couper l'assistant de Droplet du jour au lendemain.
//
// L'API de Groq est compatible avec celle d'OpenAI. Changer d'hébergeur
// revient donc à changer [kGroqUrl] et la clé — le reste du fichier ne
// bouge pas.
//
// ── D'OÙ VIENT LA CLÉ ─────────────────────────────────────────────────
//
// Deux chemins, par ordre de préférence à l'exécution :
//
//   1. LA CLÉ DE LA PERSONNE, si elle en a mis une dans les réglages.
//      Elle dort dans le trousseau du système (`flutter_secure_storage`),
//      pas dans les préférences en clair. Aucun quota, aucun relais :
//      le téléphone parle directement à Groq.
//   2. LE RELAIS DE DROPLET, avec un quota quotidien. La clé ne quitte
//      jamais le serveur ; le téléphone ne la voit pas.
//
// ⚠️ LE RELAIS N'EXISTE PAS ENCORE — [kRelaisIaUrl] EST VIDE. Tant qu'il
// l'est, l'assistant en ligne exige une clé personnelle et le dit
// clairement au lieu d'échouer avec une erreur réseau incompréhensible.
// Ce que le serveur doit faire est décrit au-dessus de la constante.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Le modèle par défaut, quand l'appelant n'en impose pas.
///
/// ⚠️ LA VRAIE TABLE EST DANS `agents_groq.dart`. Cette constante ne
/// subsiste que pour l'écran de réglages, qui teste la clé avant qu'aucun
/// agent ne soit en jeu.
const String kGroqModele = 'openai/gpt-oss-120b';

/// Le point d'entrée de Groq, compatible OpenAI.
const String kGroqUrl = 'https://api.groq.com/openai/v1/chat/completions';

/// ⚠️ VIDE AUJOURD'HUI — AUCUN RELAIS N'EST DÉPLOYÉ.
///
/// Le jour où il le sera, il doit faire exactement trois choses, et rien
/// de plus :
///
///   1. Recevoir le même corps de requête que Groq attend, y ajouter la
///      clé côté serveur, et transmettre le flux tel quel.
///   2. Compter les requêtes par installation (l'en-tête
///      `X-Droplet-Install`, un identifiant aléatoire qui ne dit rien de
///      la personne) et répondre **429** avec un corps
///      `{"erreur":"quota","reinitialisation":"<ISO 8601>"}` au-delà du
///      quota quotidien.
///   3. NE RIEN JOURNALISER DU CONTENU. Ni les messages, ni les réponses.
///      Le seul chiffre conservé est un compteur par installation.
///
/// ⚠️ ET LA POLITIQUE DE CONFIDENTIALITÉ DOIT SUIVRE. `ServeurDroplet`
/// dans `contact_config.dart` devra gagner une entrée `assistantEnLigne`,
/// et l'écran des données devra dire ce qui transite. Un relais ajouté
/// sans cette ligne fait mentir la politique par omission.
const String kRelaisIaUrl = '';

/// Le quota quotidien accordé quand on passe par le relais de Droplet.
/// Sans objet tant que [kRelaisIaUrl] est vide.
const int kQuotaRelaisParJour = 20;

/// Clé du trousseau où dort la clé API personnelle.
const String _kCleTrousseau = 'droplet_cle_groq';

// ══ CE QUI CIRCULE ══════════════════════════════════════════════════════

/// Un message de la conversation, au format que l'API attend.
@immutable
class MessageIa {
  const MessageIa({
    required this.role,
    required this.contenu,
    this.nomOutil,
    this.idAppel,
    this.appels,
  });

  /// `system`, `user`, `assistant` ou `tool`.
  final String role;
  final String contenu;

  /// Renseignés uniquement pour un message de rôle `tool` : de quel outil
  /// vient le résultat, et à quel appel il répond.
  final String? nomOutil;
  final String? idAppel;

  /// Renseigné uniquement pour un `assistant` qui demande des outils.
  final List<AppelOutil>? appels;

  Map<String, dynamic> versJson() => {
        'role': role,
        if (role != 'assistant' || appels == null) 'content': contenu,
        if (role == 'assistant' && appels != null) 'content': contenu,
        if (nomOutil != null) 'name': nomOutil,
        if (idAppel != null) 'tool_call_id': idAppel,
        if (appels != null)
          'tool_calls': [
            for (final a in appels!)
              {
                'id': a.id,
                'type': 'function',
                'function': {'name': a.nom, 'arguments': a.argumentsBruts},
              },
          ],
      };
}

/// Un outil que le modèle a décidé d'appeler.
@immutable
class AppelOutil {
  const AppelOutil({
    required this.id,
    required this.nom,
    required this.argumentsBruts,
  });

  final String id;
  final String nom;

  /// Les arguments tels que le modèle les a écrits — du JSON, mais pas
  /// forcément du JSON valide. C'est à l'appelant de le décoder et de
  /// survivre à un échec de décodage.
  final String argumentsBruts;

  Map<String, dynamic> arguments() {
    try {
      final v = jsonDecode(argumentsBruts);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } on FormatException {
      // Un modèle peut tronquer son JSON. Mieux vaut un outil appelé sans
      // argument qu'une réponse qui s'arrête sur une exception.
      return <String, dynamic>{};
    }
  }
}

/// Ce que le flux fait remonter, morceau par morceau.
sealed class MorceauIa {
  const MorceauIa();
}

/// Du texte à afficher, à concaténer au fur et à mesure.
class MorceauTexte extends MorceauIa {
  const MorceauTexte(this.texte);
  final String texte;
}

/// Un fragment du raisonnement, quand le modèle en expose un. Affiché
/// dans le repli « Réflexion », jamais mêlé à la réponse.
class MorceauReflexion extends MorceauIa {
  const MorceauReflexion(this.texte);
  final String texte;
}

/// Le modèle demande des outils. Le flux s'arrête là : c'est à
/// l'appelant de les exécuter et de relancer avec les résultats.
class MorceauOutils extends MorceauIa {
  const MorceauOutils(this.appels);
  final List<AppelOutil> appels;
}

/// La réponse est complète.
class MorceauFin extends MorceauIa {
  const MorceauFin({this.jetonsEntree, this.jetonsSortie});
  final int? jetonsEntree;
  final int? jetonsSortie;
}

/// Pourquoi ça n'a pas marché — une cause nommée, pas un message brut.
enum CauseEchecIa {
  /// Aucune clé : ni personnelle, ni relais déployé.
  pasDeCle,

  /// La clé a été refusée (401/403).
  cleRefusee,

  /// Quota du relais épuisé (429 avec `erreur: quota`).
  quotaEpuise,

  /// Trop de requêtes trop vite (429 de Groq).
  tropRapide,

  /// Panne côté serveur (5xx).
  serveur,

  /// Pas de réseau, DNS, TLS, coupure en cours de flux.
  reseau,

  /// La personne a appuyé sur stop. Pas une erreur, mais ça termine le flux.
  annule,
}

class EchecIa implements Exception {
  const EchecIa(this.cause, {this.detail, this.reinitialisation});
  final CauseEchecIa cause;

  /// Le texte brut renvoyé par le serveur, pour le journal — jamais
  /// montré tel quel à la personne.
  final String? detail;

  /// Quand le quota repart, si le serveur l'a dit.
  final DateTime? reinitialisation;

  @override
  String toString() => 'EchecIa($cause, $detail)';
}

// ══ LE SERVICE ══════════════════════════════════════════════════════════

class GroqService {
  GroqService({http.Client? client, FlutterSecureStorage? trousseau})
      : _client = client ?? http.Client(),
        _trousseau = trousseau ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _trousseau;

  /// La requête en cours, pour pouvoir l'interrompre.
  http.Client? _enCours;

  // ── La clé ────────────────────────────────────────────────────────────

  /// La clé personnelle, ou `null` si la personne n'en a pas mis.
  Future<String?> clePersonnelle() async {
    final v = await _trousseau.read(key: _kCleTrousseau);
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }

  /// Enregistre (ou efface, avec `null`) la clé personnelle.
  Future<void> definirCle(String? cle) async {
    if (cle == null || cle.trim().isEmpty) {
      await _trousseau.delete(key: _kCleTrousseau);
    } else {
      await _trousseau.write(key: _kCleTrousseau, value: cle.trim());
    }
  }

  /// L'assistant en ligne est-il utilisable du tout sur cet appareil ?
  Future<bool> disponible() async =>
      (await clePersonnelle()) != null || kRelaisIaUrl.isNotEmpty;

  // ── Le flux ───────────────────────────────────────────────────────────

  /// Envoie [messages] et rend la réponse morceau par morceau.
  ///
  /// [outils] est la liste des outils proposés au modèle, au format
  /// JSON Schema d'OpenAI. Laisser vide pour une réponse en texte seul.
  ///
  /// Le flux se termine par un [MorceauFin] ou un [MorceauOutils] ; toute
  /// autre fin est une [EchecIa].
  Stream<MorceauIa> repondre({
    required List<MessageIa> messages,
    List<Map<String, dynamic>> outils = const [],
    double temperature = 0.7,
    int maxJetons = 4096,
    String effort = 'medium',
    bool flux = true,
    String? modele,
  }) async* {
    final cle = await clePersonnelle();
    final directe = cle != null;
    if (!directe && kRelaisIaUrl.isEmpty) {
      throw const EchecIa(CauseEchecIa.pasDeCle);
    }

    final corps = <String, dynamic>{
      // ⚠️ LE MODÈLE VIENT DE L'APPELANT. `kGroqModele` n'est plus qu'un
      // défaut : c'est `agents_groq.dart` qui décide lequel répond, et
      // c'est la seule table où un identifiant de modèle est écrit.
      'model': modele ?? kGroqModele,
      'messages': [for (final m in messages) m.versJson()],
      'temperature': temperature,
      'max_completion_tokens': maxJetons,
      'stream': flux,
      // gpt-oss expose son effort de raisonnement. `medium` est le
      // compromis par défaut ; `low` pour une réponse immédiate, `high`
      // quand la personne demande à réfléchir.
      'reasoning_effort': effort,
      if (outils.isNotEmpty) ...{
        'tools': outils,
        'tool_choice': 'auto',
      },
    };

    final requete = http.Request(
      'POST',
      Uri.parse(directe ? kGroqUrl : kRelaisIaUrl),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        if (directe) 'Authorization': 'Bearer $cle',
      })
      ..body = jsonEncode(corps);

    final client = http.Client();
    _enCours = client;
    http.StreamedResponse reponse;
    try {
      reponse = await client.send(requete);
    } on Object catch (e) {
      _enCours = null;
      client.close();
      throw EchecIa(CauseEchecIa.reseau, detail: '$e');
    }

    if (reponse.statusCode != 200) {
      final texte = await reponse.stream.bytesToString();
      _enCours = null;
      client.close();
      throw _lireErreur(reponse.statusCode, texte);
    }

    // ⚠️ SANS FLUX, LA RÉPONSE ARRIVE D'UN SEUL BLOC. Le corps n'est
    // alors pas du SSE mais un unique objet JSON : le décodeur ci-dessous
    // ne le verrait jamais, puisqu'il cherche des lignes « data: ».
    // C'est le chemin qu'emprunte toute requête armée d'un outil intégré
    // de Groq (voir `contraintSansFlux`).
    if (!flux) {
      final corpsBrut = await reponse.stream.bytesToString();
      _enCours = null;
      client.close();
      yield* _lireDUnBloc(corpsBrut);
      return;
    }

    // ── Le décodage du flux ──────────────────────────────────────────
    //
    // ⚠️ LES LIGNES ARRIVENT COUPÉES. Un paquet TCP peut s'arrêter au
    // milieu d'un `data: {...}` ; sans tampon, une réponse sur deux se
    // perdrait dans une exception de décodage JSON. On accumule donc
    // jusqu'au saut de ligne avant de décoder quoi que ce soit.
    final tampon = StringBuffer();
    // Les appels d'outils arrivent eux aussi par fragments, indexés.
    final outilsEnCours = <int, _OutilEnCours>{};
    int? entree;
    int? sortie;

    try {
      await for (final bloc
          in reponse.stream.transform(utf8.decoder)) {
        tampon.write(bloc);
        final contenu = tampon.toString();
        final lignes = contenu.split('\n');
        // La dernière ligne est peut-être incomplète : on la remet au
        // tampon et on ne traite que les précédentes.
        tampon
          ..clear()
          ..write(lignes.removeLast());

        for (final brute in lignes) {
          final ligne = brute.trim();
          if (ligne.isEmpty || !ligne.startsWith('data:')) continue;
          final charge = ligne.substring(5).trim();
          if (charge == '[DONE]') {
            if (outilsEnCours.isNotEmpty) {
              yield MorceauOutils(_figer(outilsEnCours));
            } else {
              yield MorceauFin(jetonsEntree: entree, jetonsSortie: sortie);
            }
            return;
          }

          final Map<String, dynamic> evenement;
          try {
            evenement = jsonDecode(charge) as Map<String, dynamic>;
          } on FormatException {
            // Une ligne illisible ne doit pas tuer la réponse entière.
            continue;
          }

          final usage = evenement['usage'];
          if (usage is Map) {
            entree = usage['prompt_tokens'] as int? ?? entree;
            sortie = usage['completion_tokens'] as int? ?? sortie;
          }

          final choix = evenement['choices'];
          if (choix is! List || choix.isEmpty) continue;
          final premier = choix.first as Map<String, dynamic>;
          final delta = premier['delta'];
          if (delta is Map) {
            final raison = delta['reasoning'];
            if (raison is String && raison.isNotEmpty) {
              yield MorceauReflexion(raison);
            }
            final texte = delta['content'];
            if (texte is String && texte.isNotEmpty) {
              yield MorceauTexte(texte);
            }
            final appels = delta['tool_calls'];
            if (appels is List) {
              for (final a in appels) {
                if (a is! Map) continue;
                final i = a['index'] as int? ?? 0;
                final e = outilsEnCours.putIfAbsent(i, _OutilEnCours.new);
                final id = a['id'];
                if (id is String) e.id = id;
                final f = a['function'];
                if (f is Map) {
                  final nom = f['name'];
                  if (nom is String) e.nom = nom;
                  final args = f['arguments'];
                  if (args is String) e.arguments.write(args);
                }
              }
            }
          }

          final fin = premier['finish_reason'];
          if (fin is String) {
            if (fin == 'tool_calls' && outilsEnCours.isNotEmpty) {
              yield MorceauOutils(_figer(outilsEnCours));
              return;
            }
            if (fin == 'stop' || fin == 'length') {
              yield MorceauFin(jetonsEntree: entree, jetonsSortie: sortie);
              return;
            }
          }
        }
      }
      // Le flux s'est tari sans `[DONE]` : on clôt proprement avec ce
      // qu'on a plutôt que de laisser l'écran attendre indéfiniment.
      if (outilsEnCours.isNotEmpty) {
        yield MorceauOutils(_figer(outilsEnCours));
      } else {
        yield MorceauFin(jetonsEntree: entree, jetonsSortie: sortie);
      }
    } on Object catch (e) {
      if (_enCours == null) {
        // `arreter()` a fermé le client sous nos pieds : c'est voulu.
        throw const EchecIa(CauseEchecIa.annule);
      }
      throw EchecIa(CauseEchecIa.reseau, detail: '$e');
    } finally {
      _enCours = null;
      client.close();
    }
  }

  /// La réponse rendue d'un seul bloc, quand le flux est désactivé.
  ///
  /// Rend les mêmes morceaux que le flux — texte, réflexion, outils —
  /// pour que l'appelant n'ait qu'UNE boucle à écrire, quel que soit le
  /// mode. Deux chemins de lecture divergeraient au premier changement.
  static Stream<MorceauIa> _lireDUnBloc(String corps) async* {
    final Map<String, dynamic> j;
    try {
      final v = jsonDecode(corps);
      if (v is! Map<String, dynamic>) {
        throw const EchecIa(CauseEchecIa.reseau, detail: 'réponse inattendue');
      }
      j = v;
    } on FormatException catch (e) {
      throw EchecIa(CauseEchecIa.reseau, detail: '$e');
    }

    final usage = j['usage'];
    final choix = j['choices'];
    if (choix is! List || choix.isEmpty) {
      yield const MorceauFin();
      return;
    }
    final message = (choix.first as Map<String, dynamic>)['message'];
    if (message is Map) {
      final raison = message['reasoning'];
      if (raison is String && raison.isNotEmpty) {
        yield MorceauReflexion(raison);
      }
      final texte = message['content'];
      if (texte is String && texte.isNotEmpty) yield MorceauTexte(texte);

      final appels = message['tool_calls'];
      if (appels is List && appels.isNotEmpty) {
        yield MorceauOutils([
          for (var i = 0; i < appels.length; i++)
            if (appels[i] is Map)
              AppelOutil(
                id: (appels[i] as Map)['id'] as String? ?? 'appel_$i',
                nom: (((appels[i] as Map)['function'] as Map?)?['name']
                        as String?) ??
                    '',
                argumentsBruts: (((appels[i] as Map)['function']
                        as Map?)?['arguments'] as String?) ??
                    '{}',
              ),
        ]);
        return;
      }
    }
    yield MorceauFin(
      jetonsEntree: usage is Map ? usage['prompt_tokens'] as int? : null,
      jetonsSortie: usage is Map ? usage['completion_tokens'] as int? : null,
    );
  }

  /// Transcrit un enregistrement audio.
  ///
  /// ── POURQUOI WHISPER PLUTÔT QUE LA DICTÉE DU TÉLÉPHONE ────────────
  ///
  /// La reconnaissance vocale du système est gratuite et fonctionne hors
  /// ligne — c'est elle qu'il faut pour dicter un message. Mais elle
  /// transcrit AU FIL DE LA PAROLE, sans jamais revenir en arrière : un
  /// mot mal compris au début reste faux même quand la suite de la
  /// phrase le rendait évident. Whisper entend la phrase entière avant
  /// de décider, ce qui change tout sur les noms propres, les chiffres
  /// et les langues mélangées — trois choses qu'on dit sans arrêt à un
  /// assistant.
  ///
  /// ⚠️ ELLE EXIGE DONC LE RÉSEAU. Le mode vocal n'existe pas hors
  /// ligne, et l'écran doit le dire avant qu'on appuie, pas après.
  Future<String> transcrire(
    File audio, {
    String? langue,
    String modele = 'whisper-large-v3-turbo',
  }) async {
    final cle = await clePersonnelle();
    final directe = cle != null;
    if (!directe && kRelaisIaUrl.isEmpty) {
      throw const EchecIa(CauseEchecIa.pasDeCle);
    }

    final uri = Uri.parse(
      directe
          ? 'https://api.groq.com/openai/v1/audio/transcriptions'
          : '$kRelaisIaUrl/transcriptions',
    );
    final requete = http.MultipartRequest('POST', uri)
      ..headers.addAll({if (directe) 'Authorization': 'Bearer $cle'})
      ..fields['model'] = modele
      // `text` et non `json` : on ne veut que la phrase, et le format
      // verbeux coûterait un décodage pour rien.
      ..fields['response_format'] = 'text'
      // ⚠️ LA LANGUE EST UN INDICE, PAS UNE CONTRAINTE. La donner
      // améliore nettement la transcription ; l'imposer ferait échouer
      // quelqu'un qui commence sa phrase en français et la finit en
      // anglais, ce qui est la règle ici et non l'exception.
      ..fields.addAll(langue == null ? {} : {'language': langue})
      ..files.add(await http.MultipartFile.fromPath('file', audio.path));

    try {
      final reponse = await http.Response.fromStream(await requete.send());
      if (reponse.statusCode != 200) {
        throw _lireErreur(reponse.statusCode, reponse.body);
      }
      return reponse.body.trim();
    } on EchecIa {
      rethrow;
    } on Object catch (e) {
      throw EchecIa(CauseEchecIa.reseau, detail: '$e');
    }
  }

  /// Interrompt la réponse en cours. Sans effet s'il n'y en a pas.
  void arreter() {
    final c = _enCours;
    _enCours = null;
    c?.close();
  }

  void dispose() {
    arreter();
    _client.close();
  }

  // ── Détails ───────────────────────────────────────────────────────────

  static List<AppelOutil> _figer(Map<int, _OutilEnCours> m) {
    final indices = m.keys.toList()..sort();
    return [
      for (final i in indices)
        AppelOutil(
          id: m[i]!.id ?? 'appel_$i',
          nom: m[i]!.nom ?? '',
          argumentsBruts: m[i]!.arguments.toString(),
        ),
    ];
  }

  static EchecIa _lireErreur(int code, String corps) {
    if (code == 401 || code == 403) {
      return EchecIa(CauseEchecIa.cleRefusee, detail: corps);
    }
    if (code == 429) {
      // Le relais de Droplet distingue son quota du débit de Groq ; Groq
      // ne renvoie que le second.
      try {
        final j = jsonDecode(corps);
        if (j is Map && j['erreur'] == 'quota') {
          final r = j['reinitialisation'];
          return EchecIa(
            CauseEchecIa.quotaEpuise,
            detail: corps,
            reinitialisation: r is String ? DateTime.tryParse(r) : null,
          );
        }
      } on FormatException {
        // Corps non-JSON : c'est un simple dépassement de débit.
      }
      return EchecIa(CauseEchecIa.tropRapide, detail: corps);
    }
    if (code >= 500) return EchecIa(CauseEchecIa.serveur, detail: corps);
    return EchecIa(CauseEchecIa.reseau, detail: 'HTTP $code — $corps');
  }
}

/// Un appel d'outil en train d'arriver, fragment par fragment.
class _OutilEnCours {
  String? id;
  String? nom;
  final StringBuffer arguments = StringBuffer();
}
