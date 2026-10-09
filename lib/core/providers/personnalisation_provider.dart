// ============================================================================
// LA PERSONNALISATION — l'état des réglages d'apparence, et sa sauvegarde.
// ----------------------------------------------------------------------------
// Les valeurs vivent dans `ReglagesApparence` (lu en statique par les
// écrans) ; ce fournisseur les charge, les enregistre, et prévient la
// racine de l'app qu'il faut repeindre.
// ============================================================================

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/reglages_apparence.dart';
import '../services/storage_service.dart';

@immutable
class Personnalisation {
  const Personnalisation({
    this.tailleTexte = ReglagesApparence.tailleTexteDefaut,
    this.rayonBulles = ReglagesApparence.rayonDefaut,
    this.accent = 'bleu',
    this.lignesListe = 3,
    this.packMotifs = 0,
  });

  final double tailleTexte;
  final double rayonBulles;
  final String accent;
  final int lignesListe;

  /// Le jeu de motifs du fond (index de `PackMotifs`).
  final int packMotifs;

  Personnalisation copyWith({
    double? tailleTexte,
    double? rayonBulles,
    String? accent,
    int? lignesListe,
    int? packMotifs,
  }) =>
      Personnalisation(
        tailleTexte: tailleTexte ?? this.tailleTexte,
        rayonBulles: rayonBulles ?? this.rayonBulles,
        accent: accent ?? this.accent,
        lignesListe: lignesListe ?? this.lignesListe,
        packMotifs: packMotifs ?? this.packMotifs,
      );

  Map<String, Object> versJson() => {
        'taille': tailleTexte,
        'rayon': rayonBulles,
        'accent': accent,
        'lignes': lignesListe,
        'motifs': packMotifs,
      };

  /// Lit un enregistrement, en bornant chaque valeur : un fichier abîmé ne
  /// doit jamais produire une bulle illisible.
  static Personnalisation depuisJson(String? brut) {
    if (brut == null || brut.isEmpty) return const Personnalisation();
    try {
      final j = jsonDecode(brut) as Map<String, dynamic>;
      return Personnalisation(
        tailleTexte: ((j['taille'] as num?)?.toDouble() ?? ReglagesApparence.tailleTexteDefaut)
            .clamp(ReglagesApparence.tailleTexteMin, ReglagesApparence.tailleTexteMax),
        rayonBulles: ((j['rayon'] as num?)?.toDouble() ?? ReglagesApparence.rayonDefaut)
            .clamp(ReglagesApparence.rayonMin, ReglagesApparence.rayonMax),
        accent: ReglagesApparence.accentParCle(j['accent'] as String?).cle,
        lignesListe: (j['lignes'] as num?)?.toInt() == 2 ? 2 : 3,
        packMotifs: ((j['motifs'] as num?)?.toInt() ?? 0).clamp(0, 3),
      );
    } catch (_) {
      return const Personnalisation();
    }
  }

  /// Pose ces valeurs là où les écrans les lisent.
  void appliquer() {
    ReglagesApparence.tailleTexte = tailleTexte;
    ReglagesApparence.rayonBulles = rayonBulles;
    ReglagesApparence.accent = ReglagesApparence.accentParCle(accent);
    ReglagesApparence.lignesListe = lignesListe;
    ReglagesApparence.packMotifs = packMotifs;
  }

  @override
  bool operator ==(Object other) =>
      other is Personnalisation &&
      other.tailleTexte == tailleTexte &&
      other.rayonBulles == rayonBulles &&
      other.accent == accent &&
      other.lignesListe == lignesListe &&
      other.packMotifs == packMotifs;

  @override
  int get hashCode => Object.hash(tailleTexte, rayonBulles, accent, lignesListe, packMotifs);
}

const String _cle = 'personnalisation';

final personnalisationProvider =
    StateNotifierProvider<PersonnalisationNotifier, Personnalisation>((ref) {
  return PersonnalisationNotifier();
});

class PersonnalisationNotifier extends StateNotifier<Personnalisation> {
  PersonnalisationNotifier()
      : super(Personnalisation.depuisJson(StorageService.getString(_cle)));

  Future<void> modifier(Personnalisation valeur) async {
    if (valeur == state) return;
    state = valeur;
    // Sans cette ligne, le choix restait dans l'état et n'arrivait jamais
    // là où les écrans le lisent.
    valeur.appliquer();
    await StorageService.setString(_cle, jsonEncode(valeur.versJson()));
  }

  Future<void> reinitialiser() => modifier(
        const Personnalisation().copyWith(accent: state.accent),
      );
}
