// ============================================================================
// LES RÉGLAGES D'APPARENCE — ce que Telegram laisse régler, Droplet aussi.
// ----------------------------------------------------------------------------
// Repris de l'écran « Apparence » de Telegram Android (`ThemeActivity`) :
//
//   • la TAILLE DU TEXTE des messages, de 12 à 30 points ;
//   • l'ARRONDI DES BULLES, de 0 (carré) à 20 points ;
//   • la COULEUR D'ACCENT, qui colore mes bulles, les boutons, les liens ;
//   • l'affichage de la LISTE DES DISCUSSIONS, sur deux ou trois lignes.
//
// Comme `OuroColors`, ces valeurs sont lues en statique par les écrans.
// `DropletApp` les pose à chaque construction, avant tout affichage (voir
// `personnalisation_provider.dart`).
// ============================================================================

import 'package:flutter/material.dart';

import 'droplet_design.dart';

/// Une couleur d'accent, en version claire et sombre.
class Accent {
  const Accent(this.cle, this.clair, this.sombre);

  final String cle;
  final Color clair;
  final Color sombre;

  Color pour({required bool sombre}) => sombre ? this.sombre : clair;
}

class ReglagesApparence {
  ReglagesApparence._();

  // ── Bornes et valeurs par défaut ────────────────────────────────────
  static const double tailleTexteMin = 12;
  static const double tailleTexteMax = 30;
  static const double tailleTexteDefaut = 15;

  static const double rayonMin = 0;
  static const double rayonMax = 20;
  static const double rayonDefaut = 19;

  /// Les accents proposés : ceux de toute la famille Droplet, dans le même
  /// ordre que sur le site et dans Droplet Drop (Droplet Design). Le BLEU
  /// ouvre la liste : c'est la couleur du logo (la bulle et sa goutte), donc
  /// celle qu'on voit sans rien choisir. Les versions sombres sont celles
  /// d'iOS.
  static final List<Accent> accents = [
    for (final a in DDAccents.liste) Accent(a.cle, a.clair, a.sombre),
  ];

  // ── L'état courant ──────────────────────────────────────────────────
  static double tailleTexte = tailleTexteDefaut;
  static double rayonBulles = rayonDefaut;
  static Accent accent = accentParCle(DDAccents.defaut);
  static int lignesListe = 3;

  /// Le jeu de motifs du fond des discussions (index de `PackMotifs`).
  static int packMotifs = 0;

  /// La hauteur de ligne du texte des bulles, pour la taille courante.
  static const double interligne = 1.3;

  /// Le rayon du coin « de l'auteur » : jamais plus rond que le reste.
  static double get rayonQueue => rayonBulles < 6 ? rayonBulles : 6;

  static Accent accentParCle(String? cle) =>
      accents.firstWhere((a) => a.cle == cle, orElse: () => accents.first);
}
