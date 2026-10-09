// ============================================================================
// PAR OÙ PASSE LA CONVERSATION ? — mesh, Internet, ou les deux.
// ----------------------------------------------------------------------------
// Logique pure, testée dans `etat_connexion_test.dart`, utilisée par l'en-tête
// de conversation, la liste des discussions et l'écran d'appel.
//
// ⚠️ L'EN-TÊTE NE CONNAISSAIT QU'UN CHEMIN À LA FOIS. Un contact du mesh qui
// s'éloignait devenait « Vu il y a 3 h » même quand Internet marchait et que
// le message partait par la boîte aux lettres ; un contact à proximité ne
// disait jamais qu'Internet était AUSSI là ; et un contact en ligne affichait
// « Via Internet » même sans aucune connexion.
// ============================================================================

/// Le chemin vers un contact, tel qu'on l'annonce sous son nom.
enum CheminPair {
  /// Liaison directe mesh, et joignable aussi par Internet.
  procheEtInternet,

  /// À travers des relais mesh, et joignable aussi par Internet.
  relaisEtInternet,

  /// Liaison directe mesh seulement.
  proche,

  /// À travers des relais mesh seulement.
  relais,

  /// Hors du mesh, joignable par Internet.
  internet,

  /// Contact en ligne, par Tor.
  tor,

  /// Lien mesh momentanément perdu, pas d'Internet pour prendre le relais.
  reconnexion,

  /// Contact joignable seulement en ligne, mais Internet est coupé.
  attenteInternet,

  /// Ni mesh ni Internet : on dit depuis quand on ne l'a pas vu.
  horsPortee,
}

CheminPair cheminVersPair({
  required bool dansMesh,
  required int sauts,
  required bool reconnexion,
  required bool internet,
  required bool contactEnLigneSeul,
  required bool cleConnue,
  bool torActif = false,
}) {
  // Par Internet, il faut la clé du destinataire pour chiffrer — sauf pour
  // un contact en ligne, dont la clé vient de l'annuaire à l'envoi.
  final joignableEnLigne = internet && (contactEnLigneSeul || cleConnue);
  if (dansMesh && !reconnexion) {
    if (sauts <= 0) {
      return joignableEnLigne ? CheminPair.procheEtInternet : CheminPair.proche;
    }
    return joignableEnLigne ? CheminPair.relaisEtInternet : CheminPair.relais;
  }
  if (joignableEnLigne) {
    return contactEnLigneSeul && torActif ? CheminPair.tor : CheminPair.internet;
  }
  if (reconnexion) return CheminPair.reconnexion;
  if (contactEnLigneSeul) return CheminPair.attenteInternet;
  return CheminPair.horsPortee;
}

/// Faut-il tenter la boîte aux lettres AVANT le mesh pour ce message ?
bool envoyerParInternetDAbord({
  required bool contactEnLigneSeul,
  required bool joignableEnMesh,
  required bool internet,
  required bool cleConnue,
  required int pairsMesh,
}) {
  if (contactEnLigneSeul) return true;
  if (joignableEnMesh) return false;
  if (internet && cleConnue) return true;
  // Comportement historique : sans aucun voisin, le mesh ne peut rien.
  return pairsMesh == 0;
}

/// L'état du réseau pour la liste des discussions.
enum EtatReseauGlobal { meshEtInternet, meshSeul, internetSeul, aucun }

EtatReseauGlobal etatReseauGlobal({required int pairs, required bool internet}) {
  if (pairs > 0) return internet ? EtatReseauGlobal.meshEtInternet : EtatReseauGlobal.meshSeul;
  return internet ? EtatReseauGlobal.internetSeul : EtatReseauGlobal.aucun;
}

/// Le chemin d'un appel en cours.
enum CheminAppel { mesh, internetDirect, internetRelais, internet }

CheminAppel cheminAppel({required bool parInternet, bool? viaRelais}) {
  if (!parInternet) return CheminAppel.mesh;
  if (viaRelais == null) return CheminAppel.internet;
  return viaRelais ? CheminAppel.internetRelais : CheminAppel.internetDirect;
}

/// Qualité d'appel en barres (0 : inconnue), d'après l'aller-retour réseau.
int barresQualite(int latenceMs) {
  if (latenceMs <= 0) return 0;
  if (latenceMs < 150) return 3;
  if (latenceMs < 400) return 2;
  return 1;
}

// ════════════════════════════════════════════════════════════════════════
//  LA FRAÎCHEUR — une seule règle de couleur pour toute l'application.
// ════════════════════════════════════════════════════════════════════════
//
// ⚠️ IL Y AVAIT DEUX VOCABULAIRES DE COULEUR, ET ILS SE CONTREDISAIENT.
//
// Dans l'en-tête de conversation, la couleur disait la FRAÎCHEUR mais était
// calculée sur le type de route : « Par Internet il y a 3 j » s'affichait en
// VERT. Sur l'accueil, la couleur disait la ROUTE — bleu pour le maillage,
// vert pour Internet — si bien qu'un contact vu il y a trois semaines par
// Internet portait, lui aussi, une pastille verte.
//
// Le vert ne veut dire qu'une chose, dans toutes les applications du monde :
// cette personne est là MAINTENANT. Employé pour autre chose, il devient un
// indicateur qu'on cesse de croire — et un indicateur qu'on ne croit plus
// vaut moins que pas d'indicateur du tout.
//
// La route, elle, est déjà dite par les MOTS (« À portée », « Par Internet »,
// « Via 2 relais ») et par l'icône. Elle n'a pas besoin d'un second canal.
//
// D'où cette règle unique, que l'en-tête ET l'accueil appellent désormais.

/// Les trois seuls états de présence qu'une couleur a le droit de dire.
enum FraicheurPair {
  /// Joignable à la seconde où l'on regarde, et c'est PROUVÉ : soit
  /// l'appareil répond au maillage, soit un signe de vie par Internet date
  /// de moins de cinq minutes.
  maintenant,

  /// Ça bouge : lien momentanément perdu, ou Internet qu'on attend.
  enCours,

  /// Du passé. Y compris « joignable par Internet » sans signe de vie
  /// récent : la route existe, mais rien ne dit que quelqu'un est au bout.
  passe,
}

/// [signeRecent] : un signe de vie par Internet de moins de cinq minutes
/// (voir `PresenceInternet.enLigne`). Il ne concerne QUE les chemins qui
/// passent par Internet — le maillage, lui, est sa propre preuve : un
/// appareil qui répond à un scan est là, point.
FraicheurPair fraicheurPair(CheminPair chemin, {required bool signeRecent}) {
  return switch (chemin) {
    CheminPair.proche ||
    CheminPair.relais ||
    CheminPair.procheEtInternet ||
    CheminPair.relaisEtInternet => FraicheurPair.maintenant,
    CheminPair.internet ||
    CheminPair.tor =>
      signeRecent ? FraicheurPair.maintenant : FraicheurPair.passe,
    CheminPair.reconnexion ||
    CheminPair.attenteInternet => FraicheurPair.enCours,
    CheminPair.horsPortee => FraicheurPair.passe,
  };
}
