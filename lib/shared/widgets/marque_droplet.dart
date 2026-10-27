// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA MARQUE DE DROPLET, DESSINÉE EN CODE : la bulle de discussion et la
// goutte qu'elle contient — le logo, sans le carré bleu de l'icône.
//
// ── Pourquoi la dessiner plutôt qu'afficher l'image ───────────────────
//
// 1. La NETTETÉ. Une image de 1024 px réduite à 112 points reste nette,
//    mais une image agrandie (ou animée en échelle) s'adoucit. Un chemin
//    vectoriel est net à toutes les tailles et à toutes les étapes d'une
//    animation.
// 2. Les DEUX PIÈCES BOUGENT SÉPARÉMENT. L'ouverture de l'app fait
//    s'écraser la goutte et répondre la bulle (`ouverture_droplet.dart`) :
//    il faut pouvoir les transformer chacune de son côté.
// 3. La COULEUR suit le mode clair/sombre sans fichier supplémentaire.
//
// ── D'où viennent ces nombres ─────────────────────────────────────────
//
// Ils ont été obtenus en VECTORISANT `assets/icon/droplet_mark.png`
// (le logo officiel, 1024 × 1024) avec potrace, puis en comparant le
// tracé rendu à l'image d'origine : 99,5 % de pixels communs, l'écart
// restant étant l'anticrénelage du bord. On ne les retouche pas à la
// main : on revectorise l'image si le logo change.
//
// Repère : l'origine est au CENTRE de la boîte englobante du logo, et
// l'unité est sa HAUTEUR. La marque dessinée à la taille `h` occupe donc
// h × 0,967 h (le logo est presque carré), centrée sur le point donné.
// C'est le même repère que l'icône de l'écran de lancement natif
// (`drawable/marque_lancement.xml`), ce qui permet à Flutter de reprendre
// l'image du système au pixel près.
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Géométrie de la marque, dans son repère unité (voir en tête).
abstract final class GeometrieMarque {
  /// Le centre du cercle de la bulle (sa queue mise à part).
  static const Offset centreBulle = Offset(0, -0.0165);

  /// Le rayon intérieur de la bulle : là où l'onde de la goutte la touche.
  static const double rayonInterieurBulle = 0.4113;

  /// Le rayon extérieur de la bulle.
  static const double rayonExterieurBulle = 0.4835;

  /// Le centre du « ventre » de la goutte — d'où part l'onde.
  static const Offset ventreGoutte = Offset(0, 0.095);

  /// Le rayon du ventre de la goutte.
  static const double rayonVentre = 0.196;

  /// Le point le plus bas de la goutte : elle s'y appuie quand elle
  /// s'écrase, comme une vraie goutte posée sur une surface.
  static const Offset baseGoutte = Offset(0, 0.291);

  /// Largeur / hauteur de la marque.
  static const double rapport = 0.967;

  static Path? _bulleUnite;
  static Path? _goutteUnite;

  /// La bulle (anneau et queue), règle pair-impair : l'anneau est creux.
  static Path get bulle => _bulleUnite ??= _construire(_bulle)..fillType = PathFillType.evenOdd;

  /// La goutte.
  static Path get goutte => _goutteUnite ??= _construire(_goutte);

  static Path _construire(List<double> d) {
    final p = Path();
    var i = 0;
    while (i < d.length) {
      switch (d[i].toInt()) {
        case 0:
          p.moveTo(d[i + 1], d[i + 2]);
          i += 3;
        case 1:
          p.lineTo(d[i + 1], d[i + 2]);
          i += 3;
        case 2:
          p.cubicTo(d[i + 1], d[i + 2], d[i + 3], d[i + 4], d[i + 5], d[i + 6]);
          i += 7;
        default:
          p.close();
          i += 1;
      }
    }
    return p;
  }

  // Les tracés, issus de la vectorisation : 0 = déplacer (x, y),
  // 1 = ligne (x, y), 2 = courbe de Bézier (x1, y1, x2, y2, x, y), 3 = fermer.
  static const List<double> _bulle = [
    0, -0.4023, 0.4912, 2, -0.3921, 0.488, -0.3785, 0.4839, -0.3721, 0.4819, 2, -0.3656,
    0.4799, -0.3511, 0.4754, -0.3399, 0.4718, 2, -0.3286, 0.4682, -0.3064, 0.4611, -0.2904,
    0.456, 2, -0.2745, 0.451, -0.255, 0.4448, -0.2473, 0.4423, 1, -0.2331, 0.4376, 1,
    -0.2182, 0.4451, 2, -0.1638, 0.4722, -0.1102, 0.4881, -0.051, 0.4947, 2, -0.0194,
    0.4982, 0.0351, 0.497, 0.0667, 0.4922, 2, 0.2016, 0.4716, 0.3232, 0.3929, 0.3992,
    0.2771, 2, 0.4519, 0.1966, 0.4791, 0.1096, 0.4815, 0.0133, 2, 0.4836, -0.0727, 0.4667,
    -0.1479, 0.4281, -0.2245, 2, 0.3714, -0.3371, 0.2673, -0.4268, 0.1495, -0.4646, 2,
    0.0409, -0.4994, -0.0708, -0.4964, -0.175, -0.4557, 2, -0.2605, -0.4222, -0.3335,
    -0.3653, -0.3895, -0.2881, 2, -0.4374, -0.2223, -0.4691, -0.1408, -0.4798, -0.0565, 2,
    -0.4831, -0.0302, -0.4836, 0.0298, -0.4807, 0.0526, 2, -0.4717, 0.122, -0.4565, 0.1719,
    -0.4261, 0.2317, 2, -0.4205, 0.2426, -0.416, 0.2527, -0.416, 0.2541, 2, -0.416, 0.2567,
    -0.4189, 0.2687, -0.4434, 0.3689, 2, -0.4604, 0.4383, -0.4647, 0.4568, -0.4647, 0.4601,
    2, -0.4647, 0.4662, -0.459, 0.4801, -0.4545, 0.4852, 2, -0.443, 0.4983, -0.4301, 0.4998,
    -0.4023, 0.4912, 3, 0, -0.0228, 0.4206, 2, -0.0262, 0.4202, -0.0367, 0.4192, -0.0461,
    0.4183, 2, -0.0906, 0.414, -0.1396, 0.399, -0.1837, 0.3763, 2, -0.1945, 0.3707, -0.2061,
    0.3647, -0.2096, 0.3629, 2, -0.214, 0.3606, -0.2189, 0.3596, -0.2261, 0.3596, 2,
    -0.2349, 0.3596, -0.245, 0.3623, -0.303, 0.381, 2, -0.3397, 0.3928, -0.3709, 0.4029,
    -0.3724, 0.4035, 2, -0.3773, 0.4054, -0.3785, 0.4111, -0.3467, 0.2818, 2, -0.336,
    0.2382, -0.336, 0.2382, -0.3537, 0.2054, 2, -0.3743, 0.1673, -0.3855, 0.1385, -0.3955,
    0.0981, 2, -0.4048, 0.0605, -0.4072, 0.0365, -0.4061, -0.009, 2, -0.4052, -0.0502,
    -0.4031, -0.0683, -0.3955, -0.0983, 2, -0.385, -0.1401, -0.3699, -0.1772, -0.3483,
    -0.2137, 2, -0.3203, -0.2612, -0.2765, -0.308, -0.23, -0.3402, 2, -0.1806, -0.3744,
    -0.118, -0.3989, -0.0573, -0.4077, 2, -0.0349, -0.4109, 0.0388, -0.4104, 0.0604,
    -0.4068, 2, 0.1459, -0.3927, 0.2199, -0.3556, 0.2812, -0.2963, 2, 0.3292, -0.2498,
    0.3614, -0.1992, 0.3832, -0.136, 2, 0.4165, -0.0393, 0.4139, 0.0652, 0.3757, 0.1593, 2,
    0.336, 0.2573, 0.2672, 0.3332, 0.1769, 0.3786, 2, 0.1389, 0.3977, 0.0882, 0.4132,
    0.0473, 0.4183, 2, 0.0328, 0.4201, -0.0128, 0.4216, -0.0228, 0.4206, 3
  ];
  static const List<double> _goutte = [
    0, 0.0375, 0.2874, 2, 0.0784, 0.2785, 0.1112, 0.2603, 0.1394, 0.2309, 2, 0.1669, 0.2023,
    0.1863, 0.1634, 0.1933, 0.1232, 2, 0.1959, 0.1083, 0.1959, 0.0713, 0.1933, 0.0549, 2,
    0.1886, 0.0256, 0.1749, -0.0084, 0.1546, -0.0408, 2, 0.1487, -0.0503, 0.1315, -0.0754,
    0.1164, -0.0965, 2, 0.0775, -0.1509, 0.0628, -0.1734, 0.0369, -0.2174, 2, 0.0276,
    -0.2333, 0.0126, -0.2611, 0.0126, -0.2626, 2, 0.0126, -0.2647, 0.0059, -0.2703, 0.002,
    -0.2715, 2, -0.0036, -0.2732, -0.0102, -0.2686, -0.0149, -0.2595, 2, -0.0214, -0.2471,
    -0.0418, -0.2106, -0.0507, -0.1954, 2, -0.0593, -0.1809, -0.1044, -0.113, -0.1279,
    -0.0793, 2, -0.1644, -0.0267, -0.1771, -0.0036, -0.1869, 0.029, 2, -0.1935, 0.0509,
    -0.1954, 0.0647, -0.1952, 0.0911, 2, -0.1951, 0.1174, -0.1936, 0.1279, -0.1866, 0.1507,
    2, -0.1768, 0.1827, -0.1613, 0.2084, -0.1366, 0.2333, 2, -0.107, 0.2633, -0.0732, 0.281,
    -0.0306, 0.2888, 2, -0.0148, 0.2917, 0.0212, 0.291, 0.0375, 0.2874, 3
  ];
}

/// Ce qui peut bouger dans la marque.
@immutable
class PoseMarque {
  const PoseMarque({
    this.ecrasement = 0,
    this.gonflement = 0,
    this.echelle = 1,
    this.opacite = 1,
  });

  /// L'écrasement de la goutte : 0 au repos, positif quand elle s'aplatit
  /// sur sa base (0,08 = 8 % plus basse), négatif quand elle s'étire. Sa
  /// largeur varie en sens inverse, à volume à peu près constant — c'est
  /// ce qui la fait lire comme un liquide, et non comme une image qu'on
  /// déforme.
  final double ecrasement;

  /// Le gonflement de la bulle : 0 au repos, 0,03 = 3 % plus grande. La
  /// bulle répond à l'onde comme une membrane tendue.
  final double gonflement;

  /// L'échelle de l'ensemble.
  final double echelle;

  final double opacite;

  static const repos = PoseMarque();

  @override
  bool operator ==(Object other) =>
      other is PoseMarque &&
      other.ecrasement == ecrasement &&
      other.gonflement == gonflement &&
      other.echelle == echelle &&
      other.opacite == opacite;

  @override
  int get hashCode => Object.hash(ecrasement, gonflement, echelle, opacite);
}

/// Peint la marque centrée sur [centre], à la hauteur [hauteur].
class PeintreMarque extends CustomPainter {
  PeintreMarque({
    required this.couleur,
    required this.hauteur,
    this.pose = PoseMarque.repos,
    this.centre,
    super.repaint,
  });

  final Color couleur;
  final double hauteur;
  final PoseMarque pose;

  /// Le centre de la marque ; par défaut le centre de la toile.
  final Offset? centre;

  @override
  void paint(Canvas canvas, Size size) {
    if (pose.opacite <= 0) return;
    peindre(canvas, centre ?? size.center(Offset.zero), hauteur, couleur, pose);
  }

  /// Le dessin lui-même, réutilisable depuis un autre peintre.
  static void peindre(Canvas canvas, Offset centre, double hauteur, Color couleur, PoseMarque pose) {
    if (pose.opacite <= 0 || hauteur <= 0) return;
    final h = hauteur * pose.echelle;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(h);

    final alpha = (couleur.a * pose.opacite).clamp(0.0, 1.0);
    final plein = couleur.withValues(alpha: alpha);

    // ── La bulle, qui gonfle autour du centre de son cercle.
    canvas.save();
    if (pose.gonflement != 0) {
      const c = GeometrieMarque.centreBulle;
      canvas.translate(c.dx, c.dy);
      canvas.scale(1 + pose.gonflement);
      canvas.translate(-c.dx, -c.dy);
    }
    canvas.drawPath(GeometrieMarque.bulle, Paint()..color = plein..isAntiAlias = true);
    canvas.restore();

    // ── La goutte, qui s'écrase sur sa base. La hauteur perd
    // `ecrasement`, la largeur en regagne 60 % : un liquide ne perd pas de
    // volume, mais une goutte retenue par sa tension de surface ne
    // s'étale pas non plus librement.
    canvas.save();
    if (pose.ecrasement != 0) {
      const b = GeometrieMarque.baseGoutte;
      canvas.translate(b.dx, b.dy);
      canvas.scale(1 + pose.ecrasement * 0.6, 1 - pose.ecrasement);
      canvas.translate(-b.dx, -b.dy);
    }
    // Le logo d'origine éclaircit très légèrement le bas de la goutte, côté
    // droit : c'est ce qui lui donne du volume. Même dégradé ici.
    final goutte = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(
        const Offset(-0.12, -0.2),
        const Offset(0.16, 0.29),
        [plein, couleur.withValues(alpha: alpha * 0.84)],
      );
    canvas.drawPath(GeometrieMarque.goutte, goutte);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(PeintreMarque old) =>
      old.couleur != couleur || old.hauteur != hauteur || old.pose != pose || old.centre != centre;
}

/// La marque de Droplet, immobile, dans une boîte à ses proportions.
class MarqueDroplet extends StatelessWidget {
  const MarqueDroplet({super.key, required this.hauteur, required this.couleur, this.pose = PoseMarque.repos});

  final double hauteur;
  final Color couleur;
  final PoseMarque pose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Droplet',
      image: true,
      child: SizedBox(
        width: hauteur * GeometrieMarque.rapport,
        height: hauteur,
        child: CustomPaint(painter: PeintreMarque(couleur: couleur, hauteur: hauteur, pose: pose)),
      ),
    );
  }
}
