// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE SONDAGE dans une conversation : comment sa question et ses options
// voyagent, et la bulle interactive qui s'affiche à l'arrivée.
//
// ── POURQUOI UN SONDAGE EST UN SIMPLE MESSAGE TEXTE ───────────────────
//
// Exactement le même principe que `location_message.dart`, et pour les
// mêmes raisons. La question et les options sont encodées ainsi, et
// envoyées par le canal des messages ordinaires :
//
//     📊poll:{"q":"Pizza ce soir ?","o":["Oui","Non","Peu importe"]}
//
// En empruntant le canal des messages, le sondage lui-même hérite du
// chiffrement de bout en bout, de la file d'attente qui réessaie tant
// que ce n'est pas passé, de l'accusé de réception, du relais par les
// téléphones intermédiaires, et de la conservation hors ligne. Un
// appareil équipé d'une version antérieure de Droplet affiche au pire
// une ligne de texte brute — compréhensible, jamais un message perdu.
//
// ── ⚠️ LES VOTES, EUX, NE SONT PAS DANS CE MESSAGE ────────────────────
//
// Un sondage change après son envoi : d'autres personnes votent, à des
// moments différents, parfois hors ligne. Le contenu d'un `MeshMessage`
// déjà envoyé et potentiellement déjà relayé par trois téléphones ne
// peut pas être réécrit après coup — ce serait décorréler ce que
// chaque appareil du réseau a vu.
//
// Les votes voyagent donc à part, comme les réactions et les accusés de
// lecture : une petite enveloppe réseau dédiée (`kind: 'poll_vote'` dans
// `mesh_repository.dart`), stockée séparément et fusionnée dans
// `pollVotesProvider`. Ce fichier ne s'occupe QUE de la question et des
// options — le PLAN du sondage, pas son résultat.
// ============================================================================

import 'dart:convert';

/// Encode et décode un sondage partagé dans une conversation.
class PollMessage {
  const PollMessage({required this.question, required this.options, this.fin});

  final String question;
  final List<String> options;

  /// La date de fin, quand l'auteur en a mis une.
  final DateTime? fin;

  /// Après cette date on ne vote plus : on regarde le résultat.
  bool get termine => fin != null && DateTime.now().isAfter(fin!);

  static const String _prefix = '📊poll:';

  /// Le texte à envoyer.
  static String encode(String question, List<String> options, {DateTime? fin}) {
    // La clé « f » est facultative : un client qui ne la connaît pas voit
    // simplement un sondage sans date de fin, jamais un message cassé.
    final payload = jsonEncode({
      'q': question,
      'o': options,
      if (fin != null) 'f': fin.millisecondsSinceEpoch,
    });
    return '$_prefix$payload';
  }

  /// Relit un sondage depuis le texte d'un message, ou `null` si ce
  /// message n'en est pas un.
  static PollMessage? tryParse(String content) {
    final text = content.trim();
    if (!text.startsWith(_prefix)) return null;
    try {
      final json = jsonDecode(text.substring(_prefix.length));
      if (json is! Map) return null;
      final question = json['q'];
      final options = json['o'];
      if (question is! String || options is! List) return null;
      final parsed = options.whereType<String>().toList();
      // Un sondage à une seule option (ou moins) ne veut rien dire — un
      // message abîmé vaut mieux affiché en texte brut que comme un
      // sondage cassé qu'on ne peut pas remplir.
      if (parsed.length < 2) return null;
      final f = json['f'];
      return PollMessage(
        question: question,
        options: parsed,
        fin: f is int ? DateTime.fromMillisecondsSinceEpoch(f) : null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Ce qu'on écrit dans les aperçus (liste des conversations,
  /// notifications) à la place du texte brut encodé.
  static String describe(String content) {
    final poll = tryParse(content);
    return poll == null ? content : '📊 Sondage : ${poll.question}';
  }
}
