// LE LOGO DE DROPLET — la bulle et sa goutte, dessinées (le même tracé
// que l'icône de l'app, le site et Droplet Web, viewBox 64 × 64) : il prend
// n'importe quelle couleur et reste net à toutes les tailles.
import 'package:flutter/widgets.dart';

class LogoGoutte extends StatelessWidget {
  const LogoGoutte({super.key, this.taille = 28, required this.couleur});

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
    final bulle = Path()
      ..moveTo(26.16, 48.79)
      ..arcToPoint(const Offset(15.68, 40), radius: const Radius.circular(20), largeArc: true, clockwise: false)
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
