// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES QUINZE EXPLICATIONS DE L'APPLICATION — ce qui est dit, où, et dans
// quel ordre.
//
// Le dessin des bulles et la mémoire du « déjà vu » sont dans
// `bulle_guide.dart`. Ici, il n'y a que le CONTENU et le DÉCOUPAGE.
//
// ── ⚠️ QUINZE EXPLICATIONS, MAIS JAMAIS QUINZE D'AFFILÉE ──────────────
//
// `bulle_guide.dart` pose une règle dans son propre en-tête : quatre
// étapes au maximum par visite, parce qu'au-delà plus personne ne lit —
// on appuie sur « suivant » jusqu'à ce que ça s'arrête. Cette règle est
// juste, et une demande de « quinze bulles » ne l'annule pas : elle
// demande seulement de les RÉPARTIR.
//
// D'où cinq visites de trois étapes, chacune attachée à l'écran qu'elle
// explique et jouée la première fois qu'on y arrive. Personne ne voit
// jamais plus de trois bulles d'un coup, et chacune parle de ce qu'on a
// sous les yeux à ce moment précis.
//
// ── ⚠️ CE QU'ON N'EXPLIQUE PAS ────────────────────────────────────────
//
// Ni le bouton « envoyer », ni la liste des conversations, ni l'icône de
// recherche. Expliquer l'évident est le plus sûr moyen de faire passer le
// reste pour de la décoration, et d'apprendre aux gens à appuyer sur
// « passer » sans lire.
//
// Chaque explication retenue répond à une question qu'on se pose VRAIMENT
// devant Droplet, et à laquelle rien dans l'écran ne répond :
//
//   • « zéro pair » — est-ce cassé ?
//   • cette icône sur ma bulle — qu'est-ce qu'elle veut dire ?
//   • un message qui met deux heures — est-ce normal ?
//   • pourquoi ce compte a-t-il une coche et pas les autres ?
//
// ── ⚠️ UNE ÉTAPE SANS CIBLE MONTÉE EST SAUTÉE, PAS AFFICHÉE ───────────
//
// C'est `Guide` qui s'en charge. Conséquence utile : une clé qu'un écran
// n'a pas encore attachée ne casse rien — l'explication attend
// simplement. On peut donc brancher les cibles au fur et à mesure sans
// jamais afficher une bulle qui désigne le vide.
// ============================================================================

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'bulle_guide.dart';

/// Les ancres que les écrans attachent à leurs widgets.
///
/// ⚠️ DES CLÉS PARTAGÉES, PAS UNE PAR ÉCRAN. Une visite guidée doit
/// pouvoir désigner un bouton qui vit dans un autre fichier que celui qui
/// lance la visite — le micro est dans la barre de saisie, la visite part
/// de l'écran de conversation. Un registre commun est la seule façon de
/// relier les deux sans se passer des clés de main en main à travers dix
/// constructeurs.
///
/// ⚠️ ET UNE SEULE INSTANCE DE CHAQUE. Deux widgets portant la même
/// `GlobalKey` à l'écran en même temps est une erreur Flutter — pas un
/// avertissement. Chaque clé ci-dessous ne doit donc être attachée qu'à
/// UN widget, et seulement sur l'écran qui la concerne.
class ClesExplications {
  const ClesExplications._();

  // L'accueil
  static final etatReseau = GlobalKey();
  static final ligneConversation = GlobalKey();
  static final compteOfficiel = GlobalKey();

  // La conversation
  static final boutonMicro = GlobalKey();
  static final boutonVueUnique = GlobalKey();
  static final boutonPieces = GlobalKey();
  static final boutonStickers = GlobalKey();
  static final indicateurRelais = GlobalKey();

  // Les réglages d'une conversation
  static final reglageEphemeres = GlobalKey();
  static final reglageVerrou = GlobalKey();
  static final codeSecurite = GlobalKey();

  // Le réseau et les statuts
  static final ongletActus = GlobalKey();
  static final fileAttente = GlobalKey();
  static final voieTransport = GlobalKey();
}

/// Les cinq visites.
class Explications {
  const Explications._();

  /// Les noms, pour pouvoir tout rejouer depuis les réglages.
  static const List<String> noms = [
    'accueil',
    'conversation',
    'composeur',
    'confidentialite',
    'reseau',
  ];

  /// ⚠️ TROIS ÉTAPES PAR VISITE, PAS QUATRE. Le maximum toléré est quatre ;
  /// s'arrêter à trois laisse de la marge pour en ajouter une plus tard
  /// sans avoir à en retirer une autre — et trois bulles se lisent, quatre
  /// se subissent.
  static Future<void> accueil(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Guide.lancer(
      context,
      nom: 'accueil',
      etapes: [
        EtapeGuide(
          cible: ClesExplications.etatReseau,
          titre: l10n.expAucunPairTitre,
          texte: l10n.expAucunPairTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.ligneConversation,
          titre: l10n.expApercuTitre,
          texte: l10n.expApercuTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.compteOfficiel,
          titre: l10n.expOfficielTitre,
          texte: l10n.expOfficielTexte,
        ),
      ],
    );
  }

  /// Dans la conversation : ce qui s'enregistre et ce qui se joint.
  static Future<void> composeur(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Guide.lancer(
      context,
      nom: 'composeur',
      etapes: [
        EtapeGuide(
          cible: ClesExplications.boutonMicro,
          titre: l10n.expMicroTitre,
          texte: l10n.expMicroTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.boutonMicro,
          titre: l10n.expCameraTitre,
          texte: l10n.expCameraTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.boutonPieces,
          titre: l10n.expPiecesTitre,
          texte: l10n.expPiecesTexte,
        ),
      ],
    );
  }

  /// Ce qui se lit dans une bulle, et les deux boutons qu'on ne devine pas.
  static Future<void> conversation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Guide.lancer(
      context,
      nom: 'conversation',
      etapes: [
        EtapeGuide(
          cible: ClesExplications.indicateurRelais,
          titre: l10n.expRelaisTitre,
          texte: l10n.expRelaisTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.boutonVueUnique,
          titre: l10n.expVueUniqueTitre,
          texte: l10n.expVueUniqueTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.boutonStickers,
          titre: l10n.expStickersTitre,
          texte: l10n.expStickersTexte,
        ),
      ],
    );
  }

  /// Ce qui protège une conversation.
  static Future<void> confidentialite(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Guide.lancer(
      context,
      nom: 'confidentialite',
      etapes: [
        EtapeGuide(
          cible: ClesExplications.reglageEphemeres,
          titre: l10n.expEphemeresTitre,
          texte: l10n.expEphemeresTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.reglageVerrou,
          titre: l10n.expVerrouTitre,
          texte: l10n.expVerrouTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.codeSecurite,
          titre: l10n.expCodeTitre,
          texte: l10n.expCodeTexte,
        ),
      ],
    );
  }

  /// Ce qui rend Droplet différent, et qu'aucun écran ne dit.
  static Future<void> reseau(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Guide.lancer(
      context,
      nom: 'reseau',
      etapes: [
        EtapeGuide(
          cible: ClesExplications.voieTransport,
          titre: l10n.expVoieTitre,
          texte: l10n.expVoieTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.fileAttente,
          titre: l10n.expGardeTitre,
          texte: l10n.expGardeTexte,
        ),
        EtapeGuide(
          cible: ClesExplications.ongletActus,
          titre: l10n.expStatutTitre,
          texte: l10n.expStatutTexte,
        ),
      ],
    );
  }

  /// Remet les cinq visites à zéro — à offrir dans les réglages, sous
  /// « Revoir les explications ».
  ///
  /// ⚠️ CE BOUTON N'EST PAS UN LUXE. Les visites ne se jouent qu'une fois,
  /// et quelqu'un qui a appuyé sur « passer » le premier jour n'a plus
  /// aucun moyen de retrouver ce qu'il a sauté. Sans ce bouton, « une
  /// seule fois » signifie « jamais ».
  static Future<void> toutRejouer() => Guide.toutRejouer(noms);
}
