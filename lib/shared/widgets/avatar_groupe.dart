// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE VISAGE D'UN GROUPE QUI N'A PAS DE PHOTO — deux membres côte à côte,
// plutôt qu'une icône de bonshommes identique pour tous les groupes.
//
// ── ⚠️ POURQUOI PAS SIMPLEMENT UNE ICÔNE DE GROUPE ────────────────────
//
// Parce qu'elle ne distingue rien. Dans une liste de huit conversations
// dont cinq sont des groupes, cinq lignes portent exactement le même
// dessin : l'œil ne peut plus retrouver une discussion par sa forme, il
// doit lire les noms à chaque fois. Deux visages, même minuscules,
// suffisent à rendre chaque groupe reconnaissable d'un coup d'œil — c'est
// la seule raison d'être de ce fichier.
//
// ── QUI EST MONTRÉ, ET POURQUOI CES DEUX-LÀ ───────────────────────────
//
// Les deux PREMIERS MEMBRES ACTIFS, moi exclu.
//
//   • moi exclu, parce que ma propre photo est la seule qui n'apprend
//     rien : elle est sur tous mes groupes ;
//   • les premiers, c'est-à-dire les plus anciens — un ordre STABLE. Pris
//     au hasard ou par activité récente, le visage du groupe changerait
//     d'un lancement à l'autre, et on perdrait précisément ce qu'on
//     cherchait à gagner.
//
// ── ⚠️ UN SEUL MEMBRE : UN SEUL DISQUE, PAS UN DEMI ───────────────────
//
// Un groupe à deux (moi plus une personne) n'affiche qu'un disque, plein
// cadre. Afficher un demi-cercle et un vide donnerait l'impression d'un
// chargement qui n'a pas abouti.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/models/mesh_message.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_avatar.dart';
import '../../design_system/ouro_colors.dart';
import 'peer_avatar.dart';

class AvatarGroupe extends StatelessWidget {
  const AvatarGroupe({
    super.key,
    required this.groupe,
    required this.monId,
    this.rayon = 24,
  });

  final GroupInfo? groupe;
  final String monId;
  final double rayon;

  /// Combien de visages au maximum.
  ///
  /// ⚠️ DEUX, PAS TROIS NI QUATRE. À 24 points de rayon — la taille dans
  /// la liste — un troisième visage descend chacun sous 14 points de
  /// large : on n'y distingue plus ni un trait, ni une initiale. Deux
  /// disques restent lisibles ; trois deviennent une mosaïque grise.
  static const int maxVisages = 2;

  List<String> _aMontrer() {
    final g = groupe;
    if (g == null) return const [];
    return g.members
        .where((m) => m.removedAt == null && m.peerId != monId)
        .map((m) => m.peerId)
        .take(maxVisages)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ids = _aMontrer();
    final cote = rayon * 2;

    // Aucun membre connu : on retombe sur le dessin générique, qui reste
    // préférable à un disque vide.
    if (ids.isEmpty) {
      return Container(
        width: cote,
        height: cote,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: OuroColors.accent.withValues(alpha: 0.14),
        ),
        child: Icon(
          Icons.groups_rounded,
          size: rayon,
          color: OuroColors.accent,
        ),
      );
    }

    if (ids.length == 1) {
      return PeerAvatar(
        pseudo: _pseudo(ids.first),
        radius: rayon,
        imagePath: AvatarService.cheminPair(ids.first),
      );
    }

    // Deux visages : chacun occupe une moitié, découpée dans le disque.
    //
    // ⚠️ `ClipOval` AUTOUR DE L'ENSEMBLE, PAS AUTOUR DE CHACUN. Deux
    // disques complets posés côte à côte laissent quatre creux vides aux
    // coins et ne forment pas un rond. Ici, on assemble deux rectangles
    // pleins, puis on découpe le tout d'un seul cercle — la jointure
    // tombe pile au centre, et le contour est parfait.
    return SizedBox(
      width: cote,
      height: cote,
      child: ClipOval(
        child: Row(
          children: [
            for (var i = 0; i < ids.length; i++) ...[
              Expanded(
                child: _Moitie(
                  peerId: ids[i],
                  pseudo: _pseudo(ids[i]),
                  rayon: rayon,
                ),
              ),
              // Le trait de séparation : sans lui, deux photos sombres se
              // confondent en une seule tache.
              if (i == 0)
                SizedBox(
                  width: rayon * 0.06,
                  child: ColoredBox(color: OuroColors.systemBackground),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Le pseudo d'un membre, pour ses initiales.
  ///
  /// ⚠️ REPLI SUR L'IDENTIFIANT, PAS SUR UNE CHAÎNE VIDE. Un membre dont
  /// on n'a pas encore reçu la carte de visite — ça arrive, un groupe
  /// peut citer quelqu'un qu'on n'a jamais croisé — donnerait un disque
  /// sans lettre. Son identifiant produit au moins une initiale stable.
  String _pseudo(String peerId) =>
      StorageService.getPeerRecord(peerId)?.pseudo ?? peerId;
}

/// Une moitié : la photo si elle existe, sinon le disque d'initiales.
///
/// ⚠️ ON NE RÉUTILISE PAS `PeerAvatar` ICI. Il dessine un CERCLE complet,
/// avec sa pastille de présence et son halo : enfermé dans une moitié de
/// disque, il rendrait un cercle rogné à l'intérieur d'un autre cercle.
/// Cette moitié doit être un rectangle plein, bord à bord.
class _Moitie extends StatelessWidget {
  const _Moitie({
    required this.peerId,
    required this.pseudo,
    required this.rayon,
  });

  final String peerId;
  final String pseudo;
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final chemin = AvatarService.cheminPair(peerId);
    if (chemin != null) {
      return Image.file(
        File(chemin),
        fit: BoxFit.cover,
        // ⚠️ `cacheWidth` BORNÉ. Sans lui, Flutter décode la photo de
        // profil à sa taille d'origine — plusieurs mégaoctets — pour
        // remplir vingt points de large, et une liste de dix groupes en
        // garde dix en mémoire.
        cacheWidth: (rayon * 2).round(),
        errorBuilder: (_, _, _) => _Initiales(pseudo: pseudo, rayon: rayon),
      );
    }
    return _Initiales(pseudo: pseudo, rayon: rayon);
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.pseudo, required this.rayon});

  final String pseudo;
  final double rayon;

  /// La couleur vient du pseudo, pas du hasard : la même personne garde la
  /// même teinte d'un appareil à l'autre et d'un lancement au suivant.
  /// ⚠️ LA MÊME FORMULE QUE `PeerAvatar`, PAS UNE AUTRE. Il choisit sa
  /// teinte par `pseudo.hashCode.abs() % palette.length` ; en inventer une
  /// ici donnerait à la même personne deux couleurs différentes selon
  /// qu'on la regarde seule ou dans l'avatar d'un groupe — et toute la
  /// raison d'être d'une couleur dérivée du nom est qu'elle ne change
  /// jamais.
  Color get _fond {
    final palette = OuroColors.avatarPalette;
    if (palette.isEmpty) return OuroColors.accent;
    return palette[pseudo.hashCode.abs() % palette.length];
  }

  /// Même source que `PeerAvatar`, pour la même raison.
  String get _lettre => DegradesAvatar.initiales(pseudo);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _fond,
      child: Center(
        child: Text(
          _lettre,
          style: TextStyle(
            // La moitié fait un rayon de large : la lettre doit tenir
            // dedans avec de l'air, d'où 0,62 et non 0,8.
            fontSize: rayon * 0.62,
            fontWeight: FontWeight.w600,
            color: OuroColors.texteSurAccent,
            height: 1,
          ),
        ),
      ),
    );
  }
}
