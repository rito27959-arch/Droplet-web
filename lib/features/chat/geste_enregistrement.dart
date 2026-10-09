// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE GESTE D'ENREGISTREMENT, RÉDUIT À SA LOGIQUE — ce qui se passe entre le
// moment où le doigt se pose sur le micro et celui où le message part, est
// annulé, ou se verrouille en mains libres.
//
// ── POURQUOI CE FICHIER EXISTE SÉPARÉMENT ─────────────────────────────
//
// Parce que c'est la partie qu'on peut PROUVER. Un cercle qui grossit, on
// le regarde ; une machine à états, on la rejoue. Tout ce qui est ici est
// sans Flutter, sans widget, sans horloge : on lui donne des évènements,
// elle rend un état. Les trois quarts des défauts d'un geste de ce type
// sont des défauts d'enchaînement — « j'ai glissé puis relâché et il a
// quand même envoyé » — et ils se trouvent en rejouant, pas en regardant.
//
// ── D'OÙ VIENNENT LES NOMBRES ─────────────────────────────────────────
//
// Du code source de Telegram pour Android (`ChatActivityEnterView.java`),
// lu et mesuré, pas approximé. Chaque constante porte en commentaire la
// ligne d'origine. Rien n'est recopié : c'est du Java qui dessine sur un
// `Canvas`, il n'y a pas une ligne transposable. Ce qui est repris, ce
// sont les SEUILS et l'ORDRE des transitions — c'est là qu'est la
// sensation, pas dans la syntaxe.
//
// ── ⚠️ TROIS SEUILS D'ANNULATION DIFFÉRENTS, ET C'EST VOULU ───────────
//
// C'est le détail le plus contre-intuitif de tout le dispositif, et celui
// qu'on casse en « simplifiant » :
//
//   • EN GLISSANT, il faut aller jusqu'au BOUT (progression 0) pour que
//     ça s'annule tout seul, doigt toujours posé ;
//   • EN RELÂCHANT, il suffit d'être sous 0,45 ;
//   • SI LE SYSTÈME INTERROMPT le geste (appel entrant, notification qui
//     vole le toucher), on annule sous 0,70 — et au-dessus on VERROUILLE
//     au lieu d'annuler.
//
// La raison est la même dans les trois cas : ne jamais perdre un
// enregistrement par accident. Glisser à moitié puis relâcher, c'est une
// hésitation — on annule. Glisser à moitié et se faire interrompre, ce
// n'est pas une décision — on garde, en verrouillant.
// ============================================================================

import 'dart:math' as math;

/// Où en est le geste.
enum EtatGeste {
  /// Rien en cours.
  repos,

  /// Le doigt est posé, mais les 150 ms ne sont pas écoulées : on ne sait
  /// pas encore si c'est un appui court (bascule micro/caméra) ou un
  /// maintien (enregistrement).
  attente,

  /// Le doigt est posé et le micro tourne.
  enregistre,

  /// Le doigt est relevé, le micro tourne toujours.
  verrouille,
}

/// Ce que le geste a décidé, une fois terminé.
enum IssueGeste {
  /// Rien de décidé : le geste continue.
  aucune,

  /// Envoyer ce qui a été enregistré.
  envoyer,

  /// Jeter l'enregistrement.
  annuler,

  /// Le doigt s'est relevé, le micro continue sans lui.
  verrouiller,

  /// Appui trop court : on bascule entre micro et caméra.
  basculerMode,
}

/// Le geste d'enregistrement, en logique pure.
///
/// L'appelant lui donne les évènements bruts (`doigtPose`, `doigtBouge`,
/// `doigtLeve`, `interrompu`, `delaiEcoule`) et lit l'état après chaque
/// appel. Aucune horloge ici : c'est l'appelant qui arme le minuteur des
/// 150 ms et appelle `delaiEcoule()`. Une machine à états qui tient sa
/// propre horloge ne se rejoue pas.
class GesteEnregistrement {
  GesteEnregistrement({required this.largeurEcran, this.videoPossible = true});

  // ── LES SEUILS, TELS QUE MESURÉS ──────────────────────────────────

  /// Combien de temps le doigt doit rester posé avant que ça enregistre.
  ///
  /// ⚠️ CE DÉLAI N'EXISTE QUE SI LA VIDÉO EST POSSIBLE. C'est le seul
  /// moyen de distinguer « j'appuie pour enregistrer » de « je tape pour
  /// passer en caméra » : sans mode vidéo, il n'y a rien à distinguer, et
  /// imposer 150 ms d'attente avant de capter la voix ne ferait que
  /// manger le début des messages. (CAEV.java:3059-3064)
  static const Duration delaiBascule = Duration(milliseconds: 150);

  /// La course de glissement vers la gauche, plafonnée.
  /// `min(largeur × 0.35, 140dp)` — (CAEV.java:3183-3186)
  static const double courseMax = 140;
  static const double partEcran = 0.35;

  /// Sous ce seuil, le relâchement annule. (CAEV.java:3097)
  static const double seuilRelache = 0.45;

  /// Sous ce seuil, une interruption système annule ; au-dessus, elle
  /// verrouille. (CAEV.java:3069-3084)
  static const double seuilInterruption = 0.70;

  /// Montée nécessaire pour verrouiller. (CAEV.java:2148)
  static const double distanceVerrou = 57;

  final double largeurEcran;

  /// Faux quand la caméra n'est pas disponible : plus de délai, plus de
  /// bascule.
  final bool videoPossible;

  EtatGeste etat = EtatGeste.repos;

  /// Position d'ancrage horizontale.
  ///
  /// ⚠️ POSÉE AU PREMIER MOUVEMENT, PAS À LA POSE DU DOIGT. Un doigt qui
  /// se pose n'est jamais parfaitement immobile : ancrer à la pose ferait
  /// démarrer le glissement avec quelques points d'avance, et le texte
  /// « glisser pour annuler » bougerait tout seul avant qu'on ait voulu
  /// quoi que ce soit. (CAEV.java:3181)
  double? _ancreX;

  /// Même principe pour la verticale. (CAEV.java:2140-2142)
  double? _ancreY;

  /// 1 = rien de glissé, 0 = annulation atteinte.
  double progressionAnnulation = 1;

  /// 0 = verrou ouvert, 1 = verrou fermé.
  double progressionVerrou = 0;

  /// Vrai dès qu'on est passé en mode vidéo ronde.
  bool modeVideo = false;

  /// La course réelle, qui dépend de la largeur de l'écran.
  double get course => math.min(largeurEcran * partEcran, courseMax);

  /// Le décalage à appliquer au texte « glisser pour annuler ».
  /// (CAEV.java:1959)
  double get decalageTexte => -course * (1 - progressionAnnulation);

  // ── LES ÉVÈNEMENTS ────────────────────────────────────────────────

  /// Le doigt se pose. Renvoie `true` si l'appelant doit armer le
  /// minuteur des 150 ms ; `false` si l'enregistrement démarre tout de
  /// suite.
  bool doigtPose() {
    _ancreX = null;
    _ancreY = null;
    progressionAnnulation = 1;
    progressionVerrou = 0;
    if (videoPossible) {
      etat = EtatGeste.attente;
      return true;
    }
    etat = EtatGeste.enregistre;
    return false;
  }

  /// Les 150 ms sont passées sans que le doigt se lève : on enregistre.
  void delaiEcoule() {
    if (etat != EtatGeste.attente) return;
    etat = EtatGeste.enregistre;
  }

  /// Le doigt bouge. [x] et [y] sont en points, dans le repère de
  /// l'écran, y croissant vers le bas.
  IssueGeste doigtBouge(double x, double y) {
    if (etat != EtatGeste.enregistre) return IssueGeste.aucune;

    _ancreX ??= x;
    _ancreY ??= y;

    // ── L'horizontale : vers l'annulation ──
    final dist = x - _ancreX!;
    progressionAnnulation = (1 + dist / course).clamp(0.0, 1.0);

    // ⚠️ L'ANNULATION EN COURS DE GLISSEMENT DEMANDE D'ALLER AU BOUT.
    // Pas 0,45, pas 0,7 : zéro. Tant que le doigt est posé, la décision
    // n'est pas prise — on peut encore revenir vers la droite et envoyer.
    if (progressionAnnulation <= 0) {
      etat = EtatGeste.repos;
      return IssueGeste.annuler;
    }

    // ── La verticale : vers le verrou ──
    //
    // ⚠️ LE VERROU EST REFUSÉ SI L'ON A DÉJÀ GLISSÉ À GAUCHE. Sans cette
    // garde, un geste en diagonale — qui arrive tout le temps, le pouce
    // décrit un arc — verrouillerait un enregistrement qu'on était en
    // train d'annuler. (CAEV.java:2145)
    if (progressionAnnulation >= seuilInterruption) {
      final montee = (_ancreY! - y).clamp(0.0, distanceVerrou);
      progressionVerrou = montee / distanceVerrou;
      if (montee >= distanceVerrou) {
        etat = EtatGeste.verrouille;
        progressionAnnulation = 1;
        return IssueGeste.verrouiller;
      }
    }
    return IssueGeste.aucune;
  }

  /// Le doigt se lève.
  IssueGeste doigtLeve() {
    switch (etat) {
      case EtatGeste.attente:
        // Relâché avant les 150 ms : ce n'était pas un maintien, c'était
        // un appui. On bascule micro ↔ caméra. (CAEV.java:3110-3119)
        etat = EtatGeste.repos;
        modeVideo = !modeVideo;
        return IssueGeste.basculerMode;

      case EtatGeste.enregistre:
        etat = EtatGeste.repos;
        return progressionAnnulation < seuilRelache
            ? IssueGeste.annuler
            : IssueGeste.envoyer;

      case EtatGeste.verrouille:
        // Le doigt s'est levé AU moment du verrouillage : il ne décide
        // plus rien, le micro continue sans lui.
        return IssueGeste.aucune;

      case EtatGeste.repos:
        return IssueGeste.aucune;
    }
  }

  /// Le système reprend le toucher : appel entrant, notification tirée,
  /// geste de retour. Ce n'est PAS une décision de l'utilisateur.
  IssueGeste interrompu() {
    if (etat == EtatGeste.attente) {
      etat = EtatGeste.repos;
      return IssueGeste.aucune;
    }
    if (etat != EtatGeste.enregistre) return IssueGeste.aucune;
    if (progressionAnnulation < seuilInterruption) {
      etat = EtatGeste.repos;
      return IssueGeste.annuler;
    }
    // ⚠️ ON VERROUILLE PLUTÔT QUE DE JETER. Se faire interrompre n'est
    // pas vouloir annuler : garder l'enregistrement en mains libres est
    // la seule issue qui ne perd rien.
    etat = EtatGeste.verrouille;
    progressionAnnulation = 1;
    progressionVerrou = 1;
    return IssueGeste.verrouiller;
  }

  /// Une fois verrouillé, un appui sur le bouton envoie — immédiatement,
  /// dès la pose du doigt, sans attendre qu'il se relève.
  /// (CAEV.java:2996-3046)
  IssueGeste appuiQuandVerrouille() {
    if (etat != EtatGeste.verrouille) return IssueGeste.aucune;
    etat = EtatGeste.repos;
    return IssueGeste.envoyer;
  }

  /// L'utilisateur touche « Annuler » pendant un enregistrement
  /// verrouillé.
  IssueGeste annulationExplicite() {
    etat = EtatGeste.repos;
    return IssueGeste.annuler;
  }

  void reinitialiser() {
    etat = EtatGeste.repos;
    _ancreX = null;
    _ancreY = null;
    progressionAnnulation = 1;
    progressionVerrou = 0;
  }
}

/// Le rayon du cercle de micro, en points.
///
/// 41 points au silence, 71 à pleine voix. (CAEV.java:2002-2003, 2224)
double rayonCercleMicro(double amplitude) =>
    41 + 30 * amplitude.clamp(0.0, 1.0);

/// L'échelle d'entrée du cercle — et son petit rebond.
///
/// ⚠️ CE N'EST PAS UNE COURBE D'ASSOUPLISSEMENT ORDINAIRE. Elle monte à
/// 1, REDESCEND à 0,9, puis remonte à 1. C'est ce creux qui donne
/// l'impression que le cercle « se pose » au lieu d'apparaître, et c'est
/// exactement ce qu'on perdrait en le remplaçant par une courbe standard.
/// (CAEV.java:2194-2202)
double echelleEntreeCercle(double t) {
  if (t <= 0.5) return t / 0.5;
  if (t <= 0.75) return 1.0 - (t - 0.5) / 0.25 * 0.1;
  return 0.9 + (t - 0.75) / 0.25 * 0.1;
}

/// L'échelle liée au glissement vers l'annulation : le cercle rétrécit à
/// mesure qu'on s'éloigne. (CAEV.java:2218)
double echelleGlissement(double progressionAnnulation) =>
    0.7 + progressionAnnulation.clamp(0.0, 1.0) * 0.3;

/// La vitesse de suivi de l'amplitude : l'écart est parcouru en 375 ms,
/// quelle que soit sa taille. (CAEV.java:2073, WaveDrawable.java:20,31)
const Duration dureeSuiviAmplitude = Duration(milliseconds: 375);
