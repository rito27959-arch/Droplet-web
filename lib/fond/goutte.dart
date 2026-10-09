// LE LOGO DE DROPLET — la bulle et sa goutte, dessinées plutôt
// qu'importées : elles prennent n'importe quelle couleur et restent nettes à
// toutes les tailles.
//
// Comme WhatsApp avec sa bulle : en COULEUR DU THÈME quand il est actif
// (l'onglet Discussions sélectionné, la marque, le code QR), en GRIS quand
// il ne l'est pas. Le même tracé que l'icône de l'app et que le site
// (viewBox 64 × 64) : un anneau qui finit en pointe en bas à gauche, et la
// goutte au centre.
import 'package:flutter/widgets.dart';

class Goutte extends StatelessWidget {
  const Goutte({super.key, this.taille = 28, required this.couleur});

  final double taille;
  final Color couleur;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: taille,
        child: CustomPaint(painter: _PeintreLogo(couleur)),
      );
}

class _PeintreLogo extends CustomPainter {
  _PeintreLogo(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    // La bulle : M26.16 48.79 A20 20 0 1 0 15.68 40 L12.5 52.5 Z
    final bulle = Path()
      ..moveTo(26.16, 48.79)
      ..arcToPoint(
        const Offset(15.68, 40),
        radius: const Radius.circular(20),
        largeArc: true,
        clockwise: false,
      )
      ..lineTo(12.5, 52.5)
      ..close();
    canvas.drawPath(
      bulle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.2
        ..strokeJoin = StrokeJoin.round
        ..color = couleur,
    );
    // La goutte : M33 17.5 C37.2 23 41.3 27 41.3 32.4 a8.3 8.3 0 0 1 -16.6 0
    //             C24.7 27 28.8 23 33 17.5 Z
    final goutte = Path()
      ..moveTo(33, 17.5)
      ..cubicTo(37.2, 23, 41.3, 27, 41.3, 32.4)
      ..arcToPoint(const Offset(24.7, 32.4), radius: const Radius.circular(8.3))
      ..cubicTo(24.7, 27, 28.8, 23, 33, 17.5)
      ..close();
    canvas.drawPath(goutte, Paint()..color = couleur);
  }

  @override
  bool shouldRepaint(_PeintreLogo ancien) => ancien.couleur != couleur;
}
