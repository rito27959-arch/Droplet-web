// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE FOND DE DISCUSSION QUI BOUGE À CHAQUE MESSAGE ENVOYÉ — l'effet le
// plus reconnaissable de Telegram, reproduit ici à partir de l'algorithme
// qu'ils décrivent.
//
// ── Comment ça marche vraiment ────────────────────────────────────────
//
// Ce n'est PAS une image, ni une vidéo, ni un dégradé linéaire. C'est un
// « dégradé libre » calculé point par point :
//
//   • Quatre COULEURS, chacune avec un CENTRE quelque part sur l'écran.
//   • Chaque pixel prend un mélange des quatre, pondéré par sa distance
//     à chacun des centres — plus un centre est proche, plus il pèse.
//     C'est une pondération par l'inverse de la distance.
//   • Les quatre centres occupent quatre des HUIT positions réparties
//     autour de l'écran. À chaque message envoyé, tous les centres
//     avancent d'un cran, dans le sens inverse des aiguilles d'une
//     montre.
//
// Le résultat : le fond ne défile pas en boucle comme un économiseur
// d'écran. Il RÉAGIT. Envoyer un message fait doucement tourner les
// couleurs, et l'œil fait le lien entre son geste et le mouvement.
//
// ── ⚠️ Pourquoi une petite image, et pas un dessin plein écran ────────
//
// La pondération par distance demande, pour CHAQUE pixel, quatre racines
// carrées et un mélange de couleurs. En plein écran — disons 1080×2400,
// soit 2,6 millions de pixels — ce serait deux millions et demi de fois
// ce calcul, à chaque image de l'animation. Impensable sur un téléphone,
// et c'est exactement le genre de chose qui vide une batterie.
//
// On calcule donc le dégradé sur une image MINUSCULE (32×32 pixels, soit
// mille fois moins de travail), qu'on étire ensuite à la taille de
// l'écran avec un lissage. Comme un dégradé n'a par nature aucun détail
// fin, l'agrandissement ne se voit pas — c'est le même compromis que
// celui retenu par Telegram.
//
// Et le calcul n'a lieu QUE pendant les quelques centaines de
// millisecondes où les centres se déplacent. Au repos, l'image calculée
// est simplement réaffichée : coût nul.
// ============================================================================

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Les huit positions que peuvent occuper les centres de couleur.
///
/// Elles sont exprimées en fraction de l'écran (0 = bord gauche/haut,
/// 1 = bord droit/bas) et disposées en anneau, un peu écrasé
/// verticalement pour convenir à un écran de téléphone. Les valeurs
/// débordent volontairement un peu des bords : un centre de couleur posé
/// exactement dans le coin donne un dégradé qui « colle » au bord au
/// lieu de s'en échapper.
const List<Offset> _positions = [
  Offset(0.35, 0.25),
  Offset(0.72, 0.16),
  Offset(0.92, 0.42),
  Offset(0.82, 0.75),
  Offset(0.65, 0.91),
  Offset(0.28, 0.84),
  Offset(0.08, 0.58),
  Offset(0.18, 0.31),
];

/// Le fond animé d'une conversation.
///
/// [tick] est un compteur : à chaque fois qu'il augmente, les centres de
/// couleur avancent d'un cran. L'écran de discussion l'incrémente à
/// chaque message envoyé.
class TelegramGradientBackground extends StatefulWidget {
  const TelegramGradientBackground({
    super.key,
    required this.tick,
    required this.couleurs,
  });

  /// Le nombre de pas déjà effectués. Augmenter cette valeur déclenche la
  /// rotation.
  final int tick;

  /// Les quatre couleurs du dégradé.
  final List<Color> couleurs;

  @override
  State<TelegramGradientBackground> createState() =>
      _TelegramGradientBackgroundState();
}

class _TelegramGradientBackgroundState extends State<TelegramGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  /// La résolution de calcul. 32×32 suffit largement — voir la note en
  /// tête de fichier.
  static const int _resolution = 32;

  /// L'image calculée, réutilisée telle quelle tant que rien ne bouge.
  ui.Image? _image;

  /// Le pas courant : quel décalage appliquer dans la liste des huit
  /// positions.
  int _pas = 0;

  /// Le calcul d'image est asynchrone ; ce drapeau évite d'en lancer un
  /// second avant que le premier n'ait rendu son résultat.
  bool _calculEnCours = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      // La durée d'un pas. Assez lent pour qu'on voie le mouvement,
      // assez court pour que deux messages envoyés coup sur coup ne
      // fassent pas la queue.
      duration: const Duration(milliseconds: 500),
    )..addListener(_rafraichir);
    _pas = widget.tick;
    _ctrl.value = 1;
    _recalculer();
  }

  @override
  void didUpdateWidget(TelegramGradientBackground old) {
    super.didUpdateWidget(old);
    if (widget.tick != old.tick) {
      _pas = widget.tick;
      // `forward(from: 0)` et non `forward()` : un second message envoyé
      // pendant que le fond bouge encore doit REPARTIR du début vers la
      // nouvelle position, pas reprendre là où il en était.
      _ctrl.forward(from: 0);
    } else if (widget.couleurs != old.couleurs) {
      _recalculer();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _image?.dispose();
    super.dispose();
  }

  /// Appelé à chaque changement de valeur du contrôleur.
  ///
  /// Sans condition sur `isAnimating` : à la toute dernière image, le
  /// contrôleur s'est déjà arrêté quand il prévient ses auditeurs. Tester
  /// `isAnimating` ferait donc sauter cette image-là, et le dégradé
  /// s'immobiliserait un cheveu avant sa position d'arrivée — décalage
  /// qui s'accumulerait message après message.
  void _rafraichir() => _recalculer();

  /// Fabrique l'image du dégradé pour l'état courant de l'animation.
  Future<void> _recalculer() async {
    if (_calculEnCours || !mounted) return;
    _calculEnCours = true;

    final t = Curves.easeInOut.transform(_ctrl.value.clamp(0.0, 1.0));
    final octets = _peindre(t);

    // `decodeImageFromPixels` évite l'encodage/décodage PNG : on donne
    // directement les octets bruts au moteur graphique.
    ui.decodeImageFromPixels(
      octets,
      _resolution,
      _resolution,
      ui.PixelFormat.rgba8888,
      (image) {
        _calculEnCours = false;
        if (!mounted) {
          image.dispose();
          return;
        }
        setState(() {
          _image?.dispose();
          _image = image;
        });
      },
    );
  }

  /// Le cœur du dégradé libre : pour chaque pixel, un mélange des quatre
  /// couleurs pondéré par l'inverse de la distance à leur centre.
  Uint8List _peindre(double t) {
    final couleurs = widget.couleurs;
    final n = couleurs.length;

    // Position de chaque centre : entre là où il était au pas précédent
    // et là où il va. Les centres sont répartis régulièrement dans
    // l'anneau des huit positions, et avancent tous ensemble.
    final centres = <Offset>[];
    for (var i = 0; i < n; i++) {
      final ecart = _positions.length ~/ n; // 2 pour quatre couleurs
      final depuis = _positions[((_pas - 1) + i * ecart) % _positions.length];
      final vers = _positions[(_pas + i * ecart) % _positions.length];
      centres.add(Offset.lerp(depuis, vers, t)!);
    }

    final octets = Uint8List(_resolution * _resolution * 4);
    var k = 0;
    for (var y = 0; y < _resolution; y++) {
      final py = (y + 0.5) / _resolution;
      for (var x = 0; x < _resolution; x++) {
        final px = (x + 0.5) / _resolution;

        double r = 0, g = 0, b = 0, sommePoids = 0;
        for (var i = 0; i < n; i++) {
          final dx = px - centres[i].dx;
          final dy = py - centres[i].dy;
          // Distance au carré. On reste au carré plutôt que de prendre
          // la racine : cela accentue la décroissance, ce qui donne des
          // taches de couleur plus franches — c'est ce qui distingue
          // l'aspect « Telegram » d'un dégradé mou et uniforme.
          //
          // Le petit terme ajouté évite la division par zéro quand un
          // pixel tombe pile sur un centre.
          final poids = 1.0 / (dx * dx + dy * dy + 0.0012);
          final c = couleurs[i];
          r += c.r * poids;
          g += c.g * poids;
          b += c.b * poids;
          sommePoids += poids;
        }

        octets[k++] = ((r / sommePoids) * 255).round().clamp(0, 255);
        octets[k++] = ((g / sommePoids) * 255).round().clamp(0, 255);
        octets[k++] = ((b / sommePoids) * 255).round().clamp(0, 255);
        octets[k++] = 255;
      }
    }
    return octets;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) {
      // Le temps du tout premier calcul, un aplat de la première couleur
      // plutôt qu'un trou blanc.
      return ColoredBox(color: widget.couleurs.first);
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _EtirementPainter(image),
      ),
    );
  }
}

/// Étire l'image de 32×32 à la taille de l'écran, avec lissage.
class _EtirementPainter extends CustomPainter {
  _EtirementPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      // ⚠️ `FilterQuality.high` est ce qui rend l'agrandissement
      // invisible. Sans lui, on verrait les 32×32 carrés d'origine.
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_EtirementPainter old) => old.image != image;
}

/// Les palettes GRATUITES.
///
/// Quatre ambiances franchement différentes — un bleu, un vert d'eau, un
/// corail, un lilas — plutôt que quatre nuances de nuit qu'on ne savait
/// plus distinguer. Les fonds multicolores animés, eux, sont dans
/// `fonds_premium.dart`.
///
/// ⚠️ Elles restent retenues : le fond passe DERRIÈRE les bulles et le
/// texte. En sombre, chaque couleur garde une luminance sous 0,2 ; en
/// clair, au-dessus de 0,5 (voir `fond_degrade_test`).
class TelegramGradientPalettes {
  TelegramGradientPalettes._();

  /// Le fond par défaut de Droplet : les bleus de la marque.
  static const List<Color> mesh = [
    Color(0xFF0F2A5C),
    Color(0xFF1B4B8F),
    Color(0xFF0A1E45),
    Color(0xFF2A5DA8),
  ];

  static const List<Color> lagune = [
    Color(0xFF06363F),
    Color(0xFF0B5B5E),
    Color(0xFF0A2F4A),
    Color(0xFF137A6E),
  ];

  static const List<Color> corail = [
    Color(0xFF4A1530),
    Color(0xFF7A2A3A),
    Color(0xFF3A1238),
    Color(0xFF8C3B2E),
  ];

  static const List<Color> lilas = [
    Color(0xFF2A1B5E),
    Color(0xFF4B2A86),
    Color(0xFF1C1747),
    Color(0xFF6A3A9C),
  ];

  // ── Les mêmes ambiances, en clair ─────────────────────────────────
  //
  // Pas les sombres éclaircies au hasard : des pastels assez pâles pour
  // que le texte foncé reste lisible, assez colorés pour qu'on les
  // reconnaisse.

  static const List<Color> meshClair = [
    Color(0xFFD6E6FF),
    Color(0xFFBFD7FF),
    Color(0xFFE8F1FF),
    Color(0xFFC9DCFF),
  ];

  static const List<Color> laguneClair = [
    Color(0xFFCFF5EE),
    Color(0xFFB8EBE4),
    Color(0xFFE3FAF6),
    Color(0xFFBFE8F5),
  ];

  static const List<Color> corailClair = [
    Color(0xFFFFE0D6),
    Color(0xFFFFD0DC),
    Color(0xFFFFEFE8),
    Color(0xFFFFD9C2),
  ];

  static const List<Color> lilasClair = [
    Color(0xFFE9E0FF),
    Color(0xFFDCCFFF),
    Color(0xFFF3EEFF),
    Color(0xFFE6D6FA),
  ];

  // ── PALETTES ADAPTATIVES AU CONTENU ──────────────────────────────
  //
  // Utilisées quand le thème adaptatif est actif : le fond change
  // légèrement selon le type du dernier message.

  /// Fond neutre pour messages texte.
  static const List<Color> texte = mesh;

  /// Fond légèrement chaud pour les photos.
  static const List<Color> photo = [
    Color(0xFF1A1A2E),
    Color(0xFF2D1B3D),
    Color(0xFF151525),
    Color(0xFF3A2240),
  ];

  /// Fond plus profond pour les vocaux.
  static const List<Color> vocal = [
    Color(0xFF0E1A2A),
    Color(0xFF162A3A),
    Color(0xFF0A1520),
    Color(0xFF1E3545),
  ];

  /// Toutes les palettes, dans l'ordre où elles sont proposées.
  static const Map<String, List<Color>> toutes = {
    'mesh': mesh,
    'lagune': lagune,
    'corail': corail,
    'lilas': lilas,
    'adaptatif': mesh, // Le mode adaptatif utilise mesh par défaut
  };

  static const Map<String, List<Color>> toutesClaires = {
    'mesh': meshClair,
    'lagune': laguneClair,
    'corail': corailClair,
    'lilas': lilasClair,
    'adaptatif': meshClair,
  };

  static const Map<String, String> etiquettes = {
    'mesh': 'Droplet',
    'lagune': 'Lagune',
    'corail': 'Corail',
    'lilas': 'Lilas',
    'adaptatif': 'Adaptatif',
  };

  /// La palette adaptative selon le type de contenu.
  static List<Color> pourContenu(String typeContenu, {required bool sombre}) {
    return switch (typeContenu) {
      'photo' => sombre ? photo : meshClair,
      'audio' || 'voice' => sombre ? vocal : laguneClair,
      _ => sombre ? texte : meshClair,
    };
  }

  /// La palette correspondant à une clé, dans la bonne luminosité.
  ///
  /// Renvoie `null` si la clé ne correspond à aucune palette gratuite —
  /// notamment `kFondAucun`, un fond premium, ou une valeur enregistrée
  /// par une version antérieure de l'app.
  static List<Color>? pour(String cle, {required bool sombre}) =>
      (sombre ? toutes : toutesClaires)[cle];
}

/// Un carré de prévisualisation d'une palette, pour l'écran de choix.
///
/// Il montre le dégradé tel qu'il sera, sans animation : le mouvement se
/// juge dans la conversation, pas sur une vignette de quarante pixels.
class GradientPreview extends StatelessWidget {
  const GradientPreview({super.key, required this.couleurs, this.taille = 44});

  final List<Color> couleurs;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille,
      height: taille,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(painter: _PreviewPainter(couleurs)),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.couleurs);

  final List<Color> couleurs;

  @override
  void paint(Canvas canvas, Size size) {
    // Quatre halos radiaux superposés : bien plus économique qu'un vrai
    // calcul par pixel, et suffisant pour une vignette.
    canvas.drawRect(Offset.zero & size, Paint()..color = couleurs.first);
    final ecart = _positions.length ~/ couleurs.length;
    for (var i = 0; i < couleurs.length; i++) {
      final p = _positions[(i * ecart) % _positions.length];
      final centre = Offset(p.dx * size.width, p.dy * size.height);
      final rayon = size.longestSide * 0.62;
      canvas.drawCircle(
        centre,
        rayon,
        Paint()
          ..shader = ui.Gradient.radial(centre, rayon, [
            couleurs[i],
            couleurs[i].withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.couleurs != couleurs;
}
