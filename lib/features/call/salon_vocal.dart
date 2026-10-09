// ============================================================================
// LE SALON VOCAL D'UN GROUPE — on entre et on sort, ça ne sonne chez personne.
// ----------------------------------------------------------------------------
// Un appel de groupe fait sonner vingt téléphones pour trois personnes qui
// veulent parler. Un salon, non : il s'ouvre, un bandeau apparaît en bas de
// la discussion, et chacun entre quand il est disponible. C'est ce que font
// WhatsApp, Telegram et Discord, et c'est ce qui manquait ici.
//
// Ce qui circule : trois annonces minuscules — ouvert, j'entre, je sors —
// plus les réactions. Aucun son ne passe par là : la voix emprunte le
// chemin habituel des appels, par le serveur, quand Internet est là.
//
// Choix assumé : sans Internet, pas de salon. Le maillage sait porter un
// message qui attend ; il ne sait pas porter vingt voix en même temps.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Un salon ouvert dans un groupe, tel qu'on le connaît sur ce téléphone.
class SalonVocal {
  const SalonVocal({
    required this.groupId,
    required this.ouvertPar,
    required this.depuis,
    required this.participants,
  });

  final String groupId;
  final String ouvertPar;
  final DateTime depuis;

  /// Les identifiants présents, l'ouvreur compris.
  final Set<String> participants;

  SalonVocal avec(String peerId) =>
      SalonVocal(
        groupId: groupId,
        ouvertPar: ouvertPar,
        depuis: depuis,
        participants: {...participants, peerId},
      );

  SalonVocal sans(String peerId) => SalonVocal(
        groupId: groupId,
        ouvertPar: ouvertPar,
        depuis: depuis,
        participants: {...participants}..remove(peerId),
      );

  Duration get duree => DateTime.now().difference(depuis);
}

/// Une réaction envoyée pendant un salon : elle monte et s'efface.
class ReactionSalon {
  const ReactionSalon({
    required this.groupId,
    required this.auteur,
    required this.emoji,
    required this.quand,
  });

  final String groupId;
  final String auteur;
  final String emoji;
  final DateTime quand;
}

class SalonsVocaux {
  SalonsVocaux._();

  /// Un salon sans personne dedans depuis ce délai est considéré fermé :
  /// sans serveur d'état, c'est le seul moyen de ne pas garder un bandeau
  /// fantôme après un téléphone éteint brutalement.
  static const Duration oubli = Duration(minutes: 30);

  /// Change à chaque ouverture, entrée ou sortie.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Les réactions récentes, à faire monter à l'écran.
  static final ValueNotifier<List<ReactionSalon>> reactions =
      ValueNotifier<List<ReactionSalon>>(const []);

  static final Map<String, SalonVocal> _salons = {};

  static SalonVocal? de(String groupId) {
    final s = _salons[groupId];
    if (s == null) return null;
    if (s.participants.isEmpty ||
        DateTime.now().difference(s.depuis) > const Duration(hours: 12)) {
      _salons.remove(groupId);
      return null;
    }
    return s;
  }

  static void ouvrir({
    required String groupId,
    required String par,
    DateTime? quand,
  }) {
    _salons[groupId] = SalonVocal(
      groupId: groupId,
      ouvertPar: par,
      depuis: quand ?? DateTime.now(),
      participants: {par},
    );
    revision.value++;
  }

  static void entrer(String groupId, String peerId) {
    final s = _salons[groupId];
    // Une entrée sur un salon qu'on ne connaît pas encore l'ouvre : on a
    // pu manquer l'annonce, ça ne doit pas rendre le salon invisible.
    _salons[groupId] = s == null
        ? SalonVocal(
            groupId: groupId,
            ouvertPar: peerId,
            depuis: DateTime.now(),
            participants: {peerId},
          )
        : s.avec(peerId);
    revision.value++;
  }

  static void sortir(String groupId, String peerId) {
    final s = _salons[groupId];
    if (s == null) return;
    final apres = s.sans(peerId);
    if (apres.participants.isEmpty) {
      _salons.remove(groupId);
    } else {
      _salons[groupId] = apres;
    }
    revision.value++;
  }

  static void fermer(String groupId) {
    _salons.remove(groupId);
    revision.value++;
  }

  /// Une réaction arrive : on la garde le temps qu'elle monte à l'écran.
  static void reagir({
    required String groupId,
    required String auteur,
    required String emoji,
  }) {
    final maintenant = DateTime.now();
    final gardees = [
      for (final r in reactions.value)
        if (maintenant.difference(r.quand) < const Duration(seconds: 4)) r,
      ReactionSalon(
        groupId: groupId,
        auteur: auteur,
        emoji: emoji,
        quand: maintenant,
      ),
    ];
    reactions.value = gardees;
    // Le ménage, pour que la liste ne gonfle pas si personne ne regarde.
    Timer(const Duration(seconds: 5), () {
      final t = DateTime.now();
      reactions.value = [
        for (final r in reactions.value)
          if (t.difference(r.quand) < const Duration(seconds: 4)) r,
      ];
    });
  }

  /// Les emoji proposés pendant un salon — ceux qui disent quelque chose
  /// sans couper la parole.
  static const List<String> emojis = ['👍', '❤️', '😂', '👏', '🎉', '🤔'];
}
