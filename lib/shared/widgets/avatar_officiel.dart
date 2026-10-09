// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE VISAGE DU COMPTE OFFICIEL — la goutte de Droplet dans un disque, et la
// coche qui dit que c'est bien lui.
//
// ── ⚠️ CE N'EST PAS « UN AVATAR AVEC UNE COCHE DESSUS » ───────────────
//
// La coche d'un compte officiel ne prouve rien par elle-même : n'importe
// qui peut mettre une coche dans sa photo de profil, et c'est exactement
// ce que font les faux comptes sur tous les réseaux. Ce qui fait la
// différence ici, c'est que **ce badge n'est jamais dessiné à partir de
// données reçues**. Il est posé par le code, pour un identifiant unique
// gravé dans le binaire, dont les messages portent une signature
// vérifiée.
//
// Autrement dit : un pair qui se renommerait « Droplet » et se mettrait
// une goutte en photo obtiendrait son nom et sa photo — jamais ce badge.
// C'est pourquoi le widget ne prend AUCUN paramètre d'identité : il n'y a
// rien à lui passer qui puisse le tromper.
//
// ── ⚠️ ET POURQUOI LA GOUTTE EST REDESSINÉE, PAS RÉUTILISÉE TELLE QUELLE
//
// `DropletLogo` anime, pulse et rayonne : c'est la marque telle qu'on la
// montre sur un écran d'accueil. Dans une liste de conversations, à 20
// points de rayon, une pulsation permanente est une tache qui bouge au
// coin de l'œil pendant qu'on lit autre chose. On reprend donc la FORME —
// la même courbe, au point près — sans le mouvement.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';

/// L'avatar du compte officiel : la goutte dans un disque.
class AvatarOfficiel extends StatelessWidget {
  const AvatarOfficiel({super.key, this.rayon = 24, this.avecBadge = true});

  final double rayon;

  /// La coche. Fausse dans les endroits où elle serait redondante — un
  /// en-tête de conversation qui porte déjà le nom suivi du badge, par
  /// exemple.
  final bool avecBadge;

  @override
  Widget build(BuildContext context) {
    final cote = rayon * 2;
    return SizedBox(
      width: cote,
      height: cote,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: cote,
            height: cote,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: OuroColors.brandGradient,
            ),
            child: CustomPaint(
              painter: _Goutte(couleur: OuroColors.texteSurAccent),
            ),
          ),
          if (avecBadge)
            // ⚠️ 0,42 DU RAYON, PAS 0,72. Mesuré sur un rendu aux quatre
            // tailles réelles : à 0,72, le badge mange un quart du disque
            // et mord sur la goutte — à 20 points, la coche était presque
            // aussi large que la marque qu'elle est censée certifier.
            // 0,42 est la proportion que retiennent les réseaux qui
            // affichent ce genre de badge dans une liste.
            Positioned(
              right: 0,
              bottom: 0,
              child: BadgeVerifie(taille: rayon * 0.42),
            ),
        ],
      ),
    );
  }
}

/// La goutte, en creux dans le disque.
///
/// Les coefficients sont ceux de `droplet_logo.dart` : c'est la même
/// courbe, à l'identique. ⚠️ Les recopier plutôt que d'appeler l'autre
/// peintre est un choix assumé — il est privé à son fichier, et le rendre
/// public exposerait un détail de dessin au reste de l'application. Si la
/// marque change un jour, les deux doivent changer ensemble.
class _Goutte extends CustomPainter {
  const _Goutte({required this.couleur});

  final Color couleur;

  @override
  void paint(Canvas toile, Size taille) {
    final cx = taille.width / 2;
    final cy = taille.height / 2;
    // 0,30 du côté : la goutte occupe un peu moins des deux tiers du
    // disque. Plus grande, elle touche le bord et l'ensemble paraît à
    // l'étroit ; plus petite, elle flotte.
    final r = taille.width * 0.30;

    final chemin = Path()
      ..moveTo(cx, cy - 1.55 * r)
      ..cubicTo(cx - 0.6 * r, cy - 0.95 * r, cx - r, cy - 0.6 * r, cx - r, cy - 0.1 * r)
      ..cubicTo(cx - r, cy + 0.55 * r, cx - 0.55 * r, cy + r, cx, cy + r)
      ..cubicTo(cx + 0.55 * r, cy + r, cx + r, cy + 0.55 * r, cx + r, cy - 0.1 * r)
      ..cubicTo(cx + r, cy - 0.6 * r, cx + 0.6 * r, cy - 0.95 * r, cx, cy - 1.55 * r)
      ..close();

    toile.drawPath(chemin, Paint()..color = couleur);

    // Le reflet.
    //
    // ⚠️ TRÈS LÉGER, ET HAUT. À 0,28 d'opacité et centré, il se lisait
    // comme un TROU gris au milieu de la goutte — surtout à 20 points, où
    // il occupait presque toute la surface blanche. Un reflet doit se
    // deviner, pas se voir : il est maintenant à 0,10, plus petit, et
    // posé en haut à gauche là où la lumière tombe.
    toile
      ..save()
      ..clipPath(chemin)
      ..drawCircle(
        Offset(cx - r * 0.40, cy - r * 0.55),
        r * 0.42,
        Paint()..color = OuroColors.accentRempli.withValues(alpha: 0.10),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_Goutte vieux) => vieux.couleur != couleur;
}

/// La coche de vérification.
///
/// ⚠️ DESSINÉE, PAS PRISE DANS UNE POLICE D'ICÔNES. À 14 points, les
/// icônes Material rendent un trait flou d'épaisseur variable selon la
/// densité de l'écran ; or ce badge est presque toujours petit. Deux
/// segments et un disque donnent un trait net à toutes les tailles.
class BadgeVerifie extends StatelessWidget {
  const BadgeVerifie({super.key, this.taille = 16});

  final double taille;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille,
      height: taille,
      child: CustomPaint(
        painter: _PeintreBadge(
          fond: OuroColors.accentRempli,
          encre: OuroColors.texteSurAccent,
          // Le lisere reprend le fond de l'écran : le badge paraît
          // découpé dans l'avatar plutôt que posé dessus, ce qui le
          // détache même quand l'accent et l'avatar ont la même teinte.
          lisere: OuroColors.systemBackground,
        ),
      ),
    );
  }
}

class _PeintreBadge extends CustomPainter {
  const _PeintreBadge({
    required this.fond,
    required this.encre,
    // ⚠️ `lisere` SANS ACCENT. Dart n'accepte que des lettres ASCII dans
    // un identifiant : `liseré` ne compile pas, et l'erreur renvoyée parle
    // d'un jeton inattendu, pas d'un accent.
    required this.lisere,
  });

  final Color fond;
  final Color encre;
  final Color lisere;

  @override
  void paint(Canvas toile, Size taille) {
    final c = Offset(taille.width / 2, taille.height / 2);
    final r = taille.width / 2;

    toile
      ..drawCircle(c, r, Paint()..color = lisere)
      ..drawCircle(c, r - taille.width * 0.08, Paint()..color = fond);

    final p = Paint()
      ..color = encre
      ..style = PaintingStyle.stroke
      ..strokeWidth = taille.width * 0.13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    toile.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.38, c.dy + r * 0.02)
        ..lineTo(c.dx - r * 0.08, c.dy + r * 0.32)
        ..lineTo(c.dx + r * 0.42, c.dy - r * 0.30),
      p,
    );
  }

  @override
  bool shouldRepaint(_PeintreBadge vieux) =>
      vieux.fond != fond || vieux.encre != encre || vieux.lisere != lisere;
}
