// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE DÉPOUILLEMENT D'UN SONDAGE : qui a voté pour quoi, fusionné à partir
// des votes reçus de tous les appareils qui ont participé.
//
// ── POURQUOI CE N'EST PAS LE MÊME MÉCANISME QUE LES RÉACTIONS ──────────
//
// `toggleReaction` (dans `mesh_provider.dart`) met à jour l'état LOCAL
// immédiatement, et prévient le pair séparément pour qu'il joue un effet
// visuel — mais ne fusionne jamais ce que le pair ajoute de son côté dans
// une liste partagée. Suffisant pour un emoji éphémère ; insuffisant pour
// un sondage, où le compte des voix doit être IDENTIQUE sur tous les
// appareils qui l'ont reçu, y compris après un redémarrage.
//
// ── LA STRUCTURE ────────────────────────────────────────────────────────
//
// Un seul dictionnaire : sondage → { votant → option choisie }. Chaque
// votant n'apparaît qu'une fois par sondage — voter à nouveau REMPLACE le
// choix précédent, exactement comme WhatsApp et Telegram (on peut changer
// d'avis, la voix précédente ne compte plus).
//
// ⚠️ AUCUNE PREUVE CRYPTOGRAPHIQUE QU'UN VOTANT N'A VOTÉ QU'UNE FOIS.
// Un appareil compromis pourrait forger plusieurs identités de votant. Ce
// n'est pas différent de ce que permettrait n'importe quel sondage de
// groupe décentralisé sans serveur central faisant autorité — le
// compromis assumé de toute l'architecture mesh de Droplet.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/mesh_repository.dart';
import '../services/storage_service.dart';
import 'mesh_provider.dart';

const String _pollVotesKey = 'poll_votes';

/// Sondage → { votant → index de l'option choisie }.
typedef PollTally = Map<String, Map<String, int>>;

/// L'état de dépouillement de tous les sondages connus de cet appareil.
final pollVotesProvider = StateNotifierProvider<PollVotesNotifier, PollTally>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return PollVotesNotifier(repo);
});

class PollVotesNotifier extends StateNotifier<PollTally> {
  PollVotesNotifier(this._repo) : super(_load()) {
    _sub = _repo.pollVoteEvents.listen((evt) {
      // Un vote plus tard REMPLACE le précédent pour ce même votant —
      // voir la note en tête de fichier.
      final pollVotes = Map<String, int>.from(state[evt.pollId] ?? {});
      pollVotes[evt.voterId] = evt.optionIndex;
      state = {...state, evt.pollId: pollVotes};
      unawaited(_persist());
    });
  }

  final MeshRepository _repo;
  late final StreamSubscription<({String pollId, String voterId, int optionIndex})> _sub;

  static PollTally _load() {
    final raw = StorageService.getString(_pollVotesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((pollId, votes) => MapEntry(
            pollId,
            (votes as Map<String, dynamic>).map(
              (voterId, option) => MapEntry(voterId, option as int),
            ),
          ));
    } catch (_) {
      // Un blob corrompu ne doit pas empêcher l'app de démarrer — au pire
      // les sondages repartent de zéro localement ; les votes des pairs
      // reviendront au prochain contact.
      return {};
    }
  }

  Future<void> _persist() async {
    await StorageService.setString(_pollVotesKey, jsonEncode(state));
  }

  /// Vote pour [optionIndex] dans le sondage [pollMessageId], au sein
  /// d'une conversation 1:1 avec [peerId] — ou de groupe si [groupId] est
  /// fourni à la place.
  ///
  /// Voter une seconde fois pour une option DIFFÉRENTE change le vote ;
  /// voter pour la MÊME option ne fait rien (pas de « dé-vote » — un
  /// sondage n'est pas une réaction, s'abstenir n'est pas une option
  /// qu'on choisit puis retire).
  Future<void> vote({
    required String pollMessageId,
    required int optionIndex,
    String? peerId,
    String? groupId,
  }) async {
    if (state[pollMessageId]?[_repo.myId] == optionIndex) return;
    if (groupId != null) {
      await _repo.sendGroupPollVote(
        groupId: groupId,
        pollMessageId: pollMessageId,
        optionIndex: optionIndex,
      );
    } else if (peerId != null) {
      await _repo.sendPollVote(
        targetId: peerId,
        pollMessageId: pollMessageId,
        optionIndex: optionIndex,
      );
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Le compte des voix par option, dans l'ordre des options du sondage.
List<int> pollTally(PollTally votes, String pollMessageId, int optionCount) {
  final counts = List<int>.filled(optionCount, 0);
  final pollVotes = votes[pollMessageId];
  if (pollVotes == null) return counts;
  for (final option in pollVotes.values) {
    if (option >= 0 && option < optionCount) counts[option]++;
  }
  return counts;
}

/// L'option choisie par [voterId] dans ce sondage, ou `null` s'il n'a pas
/// voté.
int? pollVoteOf(PollTally votes, String pollMessageId, String voterId) {
  return votes[pollMessageId]?[voterId];
}
