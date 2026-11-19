// LES FONDS DESSINÉS — les mêmes petits dessins au trait que l'app
// (Glasmio) : des illustrations « doodle » avec visages et détails, serrées
// comme le papier peint de Telegram, séparées par de petits motifs.
//
// Les dessins arrivent en tracés SVG (`doodle.g.dart`, généré, identique à
// celui de l'app). La tuile de 400 points est dessinée une fois par densité
// d'écran en image, puis répétée par un shader : le fond ne coûte rien au
// défilement. Le trait garde la même épaisseur partout, quelle que soit la
// taille du dessin : c'est ce qui donne l'air d'une seule main.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

part 'doodle.g.dart';

const _blanc = Color(0xFFFFFFFF);
const double _trait = 1.7, _traitFin = 1.25;
const int _petits = 9;

final Map<String, List<(List<Path>, List<Path>, List<Path>)>> _dessins = {};
final Map<String, Future<ui.Image>> _images = {};

List<(List<Path>, List<Path>, List<Path>)> _dessinsDe(String pack) => _dessins.putIfAbsent(
      pack,
      () => [
        for (final d in _dessinsDoodle[pack]!)
          (
            [for (final t in d[0]) cheminSvg(t)],
            [for (final t in d[1]) cheminSvg(t)],
            [for (final t in d[2]) cheminSvg(t)],
          ),
      ],
    );

/// Les packs disponibles, dans l'ordre de l'app.
List<String> get packsDoodle => _dessinsDoodle.keys.toList();

/// L'image de la tuile (dessins blancs sur transparent) pour une densité.
Future<ui.Image> imageDoodle(double densite, String pack) {
  return _images.putIfAbsent('$densite:$pack', () {
    final cote = (_tuileDoodle * densite).round();
    final enregistreur = ui.PictureRecorder();
    final canvas = Canvas(enregistreur)
      ..clipRect(Rect.fromLTWH(0, 0, cote.toDouble(), cote.toDouble()))
      ..scale(densite);
    final dessins = _dessinsDe(pack);
    final nGrands = dessins.length - _petits;
    final trait = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _blanc;
    final plein = Paint()..color = _blanc;
    final p = _placementsDoodle[pack]!;
    for (var k = 0; k + 4 < p.length; k += 5) {
      final i = p[k].toInt();
      final echelle = p[k + 3];
      canvas
        ..save()
        ..translate(p[k + 1], p[k + 2])
        ..rotate(p[k + 4])
        ..scale(echelle)
        ..translate(-32, -32);
      trait.strokeWidth = (i < nGrands ? _trait : _traitFin) / echelle;
      final (traits, pleins, pointilles) = dessins[i];
      for (final c in traits) {
        canvas.drawPath(c, trait);
      }
      for (final c in pleins) {
        canvas.drawPath(c, plein);
      }
      for (final c in pointilles) {
        canvas.drawPath(_pointille(c, 1 / echelle, 5 / echelle), trait);
      }
      canvas.restore();
    }
    return enregistreur.endRecording().toImage(cote, cote);
  });
}

Path _pointille(Path source, double plein, double vide) {
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + plein, m.length)), Offset.zero);
      d += plein + vide;
    }
  }
  return out;
}

/// Le calque des dessins, teinté d'une seule couleur, répété sans raccord.
class CalqueDoodle extends StatefulWidget {
  const CalqueDoodle({super.key, required this.couleur, this.pack = 'droplet'});

  final Color couleur;
  final String pack;

  @override
  State<CalqueDoodle> createState() => _CalqueDoodleState();
}

class _CalqueDoodleState extends State<CalqueDoodle> {
  ui.Image? _image;
  String? _cle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _charger();
  }

  @override
  void didUpdateWidget(CalqueDoodle ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.pack != widget.pack) _charger();
  }

  void _charger() {
    final densite = MediaQuery.devicePixelRatioOf(context);
    final cle = '$densite:${widget.pack}';
    if (cle == _cle) return;
    _cle = cle;
    imageDoodle(densite, widget.pack).then((image) {
      if (mounted && _cle == cle) setState(() => _image = image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final densite = MediaQuery.devicePixelRatioOf(context);
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: image == null ? 0 : 1,
        duration: const Duration(milliseconds: 350),
        child: image == null
            ? const SizedBox.expand()
            : RepaintBoundary(
                child: CustomPaint(size: Size.infinite, painter: _PeintreDoodle(image, densite, widget.couleur)),
              ),
      ),
    );
  }
}

class _PeintreDoodle extends CustomPainter {
  _PeintreDoodle(this.image, this.densite, this.couleur);

  final ui.Image image;
  final double densite;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final echelle = Matrix4.diagonal3Values(1 / densite, 1 / densite, 1);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(image, TileMode.repeated, TileMode.repeated, echelle.storage)
        ..colorFilter = ColorFilter.mode(couleur, BlendMode.srcIn)
        ..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_PeintreDoodle a) => a.image != image || a.couleur != couleur || a.densite != densite;
}

// ── Lecture des tracés SVG (« path data ») ─────────────────────────────
// M L H V C S Q T A Z, absolus et relatifs, commandes implicites répétées.

/// Un [Path] à partir d'un attribut `d` SVG.
Path cheminSvg(String d) {
  final chemin = Path();
  final jetons = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  var i = 0;
  var x = 0.0, y = 0.0, debutX = 0.0, debutY = 0.0;
  var ctrlX = 0.0, ctrlY = 0.0; // dernier point de contrôle (S, T)
  var cmd = 'M';
  var precedente = '';
  bool estNombre(int k) => k < jetons.length && !RegExp(r'^[A-Za-z]$').hasMatch(jetons[k]);
  double n() => double.parse(jetons[i++]);
  while (i < jetons.length) {
    if (!estNombre(i)) {
      cmd = jetons[i++];
    } else if (cmd == 'M') {
      cmd = 'L';
    } else if (cmd == 'm') {
      cmd = 'l';
    }
    final rel = cmd == cmd.toLowerCase();
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + n();
        y = oy + n();
        chemin.moveTo(x, y);
        debutX = x;
        debutY = y;
      case 'L':
        x = ox + n();
        y = oy + n();
        chemin.lineTo(x, y);
      case 'H':
        x = (rel ? x : 0) + n();
        chemin.lineTo(x, y);
      case 'V':
        y = (rel ? y : 0) + n();
        chemin.lineTo(x, y);
      case 'C':
        final x1 = ox + n(), y1 = oy + n(), x2 = ox + n(), y2 = oy + n();
        x = ox + n();
        y = oy + n();
        chemin.cubicTo(x1, y1, x2, y2, x, y);
        ctrlX = x2;
        ctrlY = y2;
      case 'S':
        final p = precedente.toUpperCase();
        final x1 = (p == 'C' || p == 'S') ? 2 * x - ctrlX : x;
        final y1 = (p == 'C' || p == 'S') ? 2 * y - ctrlY : y;
        final x2 = ox + n(), y2 = oy + n();
        x = ox + n();
        y = oy + n();
        chemin.cubicTo(x1, y1, x2, y2, x, y);
        ctrlX = x2;
        ctrlY = y2;
      case 'Q':
        final x1 = ox + n(), y1 = oy + n();
        x = ox + n();
        y = oy + n();
        chemin.quadraticBezierTo(x1, y1, x, y);
        ctrlX = x1;
        ctrlY = y1;
      case 'T':
        final p = precedente.toUpperCase();
        final x1 = (p == 'Q' || p == 'T') ? 2 * x - ctrlX : x;
        final y1 = (p == 'Q' || p == 'T') ? 2 * y - ctrlY : y;
        x = ox + n();
        y = oy + n();
        chemin.quadraticBezierTo(x1, y1, x, y);
        ctrlX = x1;
        ctrlY = y1;
      case 'A':
        final rx = n(), ry = n(), angle = n();
        final grand = n() != 0, horaire = n() != 0;
        x = ox + n();
        y = oy + n();
        chemin.arcToPoint(Offset(x, y),
            radius: Radius.elliptical(rx, ry), rotation: angle, largeArc: grand, clockwise: horaire);
      case 'Z':
        chemin.close();
        x = debutX;
        y = debutY;
    }
    precedente = cmd;
  }
  return chemin;
}
