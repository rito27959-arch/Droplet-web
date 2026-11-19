// LA SCÈNE DE L'ACCUEIL — « la ville la nuit ».
//
// Ce qu'on voit quand aucune discussion n'est ouverte : une petite rue
// dessinée au crépuscule (en sombre : en pleine nuit). Maisons à toit de
// tôle, immeubles à balcons, un étal de marché, un palmier, un manguier,
// des lampadaires, et une moto-taxi qui passe de temps en temps.
//
// Le principe de Droplet, sans un mot de technique : un message saute de
// fenêtre en fenêtre, de voisin en voisin, et chaque fenêtre s'allume à son
// passage, jusqu'à la dernière maison, celle où brille cet ordinateur.
// Pas d'antenne dans le décor : c'est voulu.
//
// Elle vit avec l'état réel de la liaison :
//   connecté   → la fenêtre de l'ordinateur brille de la couleur d'accent ;
//   connexion  → les messages s'arrêtent chez le voisin, la fenêtre clignote ;
//   hors ligne → plus de messages, la fenêtre de l'ordinateur est éteinte.
//
// Souris : le ciel et les toits du fond glissent un peu (parallaxe), la
// fenêtre survolée s'éclaire. Clic sur une fenêtre : un message part de là.
//
// Dessin natif (CustomPainter) : tout est calculé à partir de l'horloge,
// rien ne s'accumule. « Réduire les animations » → une image fixe.
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../donnees/transport.dart' show EtatConnexion;

/// La taille logique de la scène ; elle est mise à l'échelle de la place.
const double _l = 560, _h = 300;
const double _sol = 250;

enum _Toit { tole, plat, aucun }

class _Batiment {
  const _Batiment(this.x, this.largeur, this.hauteur, this.toit, this.couleur, this.fenetres);
  final double x, largeur, hauteur;
  final _Toit toit;
  final int couleur;
  final List<Rect> fenetres;
  double get haut => _sol - hauteur;
}

Rect _f(double x, double y, [double w = 14, double h = 16]) => Rect.fromLTWH(x, y, w, h);

final List<_Batiment> _batiments = [
  _Batiment(10, 72, 66, _Toit.tole, 0, [_f(22, 200), _f(54, 200)]),
  _Batiment(94, 84, 122, _Toit.plat, 1, [
    for (final y in [142.0, 174.0, 206.0]) ...[_f(108, y), _f(152, y)],
  ]),
  // L'étal du marché : pas de fenêtre.
  const _Batiment(192, 58, 34, _Toit.aucun, 2, []),
  _Batiment(262, 72, 88, _Toit.tole, 0, [_f(276, 196), _f(306, 196)]),
  _Batiment(364, 96, 142, _Toit.plat, 1, [
    for (final y in [122.0, 156.0, 190.0]) ...[_f(376, y), _f(405, y), _f(434, y)],
  ]),
  // La dernière maison : la grande fenêtre de cet ordinateur.
  _Batiment(482, 70, 98, _Toit.tole, 3, [_f(496, 180, 42, 30)]),
];

/// Toutes les fenêtres, dans l'ordre de la rue. La dernière est l'ordinateur.
final List<Rect> _fenetres = [for (final b in _batiments) ...b.fenetres];
final int _ordi = _fenetres.length - 1;

/// Le bâtiment de chaque fenêtre.
final List<int> _batimentDe = [
  for (var i = 0; i < _batiments.length; i++)
    for (var k = 0; k < _batiments[i].fenetres.length; k++) i,
];

/// Les fenêtres où quelqu'un est déjà chez soi (allumées doucement).
const Set<int> _habitees = {1, 3, 6, 9, 12, 15};

/// Les messages qui passent tout seuls : (fenêtres, décalage en s).
const List<(List<int>, double)> _rondes = [
  ([0, 2, 7, 10, 18], 0.0),
  ([1, 4, 8, 13], 1.9),
  ([6, 9, 16], 3.7),
  ([3, 11, 17], 5.3),
];

const double _saut = 0.85; // secondes par saut de fenêtre en fenêtre
const double _periode = 7.5;

class SceneAccueil extends StatefulWidget {
  const SceneAccueil({
    super.key,
    required this.etat,
    required this.accent,
    required this.encre,
    required this.carte,
    required this.sombre,
  });

  final EtatConnexion etat;

  /// La couleur choisie dans les réglages (la fenêtre de l'ordinateur).
  final Color accent;
  final Color encre;
  final Color carte;
  final bool sombre;

  @override
  State<SceneAccueil> createState() => _SceneAccueilState();
}

class _Envoi {
  _Envoi(this.chemin, this.depart);
  final List<int> chemin;
  final double depart;
}

class _SceneAccueilState extends State<SceneAccueil> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tic);
  final ValueNotifier<double> _temps = ValueNotifier(2.6);
  Duration _dernier = Duration.zero;
  double _horloge = 2.6;

  Offset? _pointeur;
  Offset _lisse = const Offset(_l / 2, _h / 2);
  int _survolee = -1;

  final List<_Envoi> _envois = [];
  final Random _hasard = Random(3);
  bool _fige = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fige = MediaQuery.disableAnimationsOf(context);
    if (_fige) {
      _ticker.stop();
      _horloge = 2.6;
      _temps.value = _horloge;
    } else if (!_ticker.isActive) {
      _dernier = Duration.zero;
      _ticker.start();
    }
  }

  void _tic(Duration d) {
    final dt = _dernier == Duration.zero ? 0.016 : (d - _dernier).inMicroseconds / 1e6;
    _dernier = d;
    _horloge += dt.clamp(0.0, 0.1);
    final cible = _pointeur ?? const Offset(_l / 2, _h / 2);
    _lisse = Offset.lerp(_lisse, cible, 1 - exp(-dt * 5))!;
    _envois.removeWhere((e) => _horloge - e.depart > 14);
    _temps.value = _horloge;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _temps.dispose();
    super.dispose();
  }

  Offset _logique(Offset local, Size taille) {
    final e = min(taille.width / _l, taille.height / _h);
    final ox = (taille.width - _l * e) / 2, oy = (taille.height - _h * e) / 2;
    return Offset((local.dx - ox) / e, (local.dy - oy) / e);
  }

  int _fenetreSous(Offset p) {
    for (var i = 0; i < _fenetres.length; i++) {
      if (_fenetres[i].inflate(5).contains(p)) return i;
    }
    return -1;
  }

  void _survol(Offset p) {
    _pointeur = p;
    final f = _fenetreSous(p);
    if (f != _survolee) setState(() => _survolee = f);
  }

  void _toucher(Offset p) {
    if (_fige) return;
    var depuis = _fenetreSous(p);
    if (depuis == _ordi) return;
    if (depuis < 0) depuis = _hasard.nextInt(4);
    // Une fenêtre au hasard dans chacun des bâtiments suivants, jusqu'à
    // l'ordinateur : de voisin en voisin.
    final chemin = [depuis];
    for (var b = _batimentDe[depuis] + 1; b < _batiments.length - 1; b++) {
      final fs = _batiments[b].fenetres;
      if (fs.isEmpty) continue;
      chemin.add(_fenetres.indexOf(fs[_hasard.nextInt(fs.length)]));
    }
    _envois.add(_Envoi(chemin, _horloge));
    if (_envois.length > 8) _envois.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _l / _h,
      child: LayoutBuilder(
        builder: (context, c) {
          final taille = Size(c.maxWidth, c.maxHeight);
          return MouseRegion(
            cursor: _survolee >= 0 && _survolee != _ordi ? SystemMouseCursors.click : MouseCursor.defer,
            onHover: (e) => _survol(_logique(e.localPosition, taille)),
            onExit: (_) {
              _pointeur = null;
              if (_survolee != -1) setState(() => _survolee = -1);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails e) => _toucher(_logique(e.localPosition, taille)),
              child: RepaintBoundary(
                child: CustomPaint(size: taille, painter: _PeintreVille(this, widget)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Les couleurs de la ville ──────────────────────────────────────────

class _Palette {
  const _Palette({
    required this.ciel,
    required this.lointain,
    required this.murs,
    required this.toit,
    required this.route,
    required this.vitreEteinte,
    required this.feuillage,
    required this.etoiles,
  });

  final List<Color> ciel;
  final Color lointain;
  final List<Color> murs;
  final Color toit;
  final Color route;
  final Color vitreEteinte;
  final Color feuillage;
  final double etoiles;

  /// En sombre : la nuit.
  static const nuit = _Palette(
    ciel: [Color(0xFF070B1C), Color(0xFF111A3A), Color(0xFF2A2C5E)],
    lointain: Color(0xFF1A1F44),
    murs: [Color(0xFF232849), Color(0xFF1C2140), Color(0xFF2A2547), Color(0xFF262B4F)],
    toit: Color(0xFF353A66),
    route: Color(0xFF12152A),
    vitreEteinte: Color(0xFF0E1226),
    feuillage: Color(0xFF15233A),
    etoiles: 1,
  );

  /// En clair : le crépuscule, la ville en silhouettes sur le couchant.
  static const crepuscule = _Palette(
    ciel: [Color(0xFF2E3B7A), Color(0xFF8A6BB4), Color(0xFFF4A47C)],
    lointain: Color(0xFF6B5A9A),
    murs: [Color(0xFF3B3466), Color(0xFF332D5C), Color(0xFF45376A), Color(0xFF3E3870)],
    toit: Color(0xFF4F4680),
    route: Color(0xFF2B2650),
    vitreEteinte: Color(0xFF262049),
    feuillage: Color(0xFF2C2A58),
    etoiles: 0.45,
  );
}

const _chaud = Color(0xFFFFC56B);
const _blanc = Color(0xFFFFFFFF);

Paint _halo(Offset c, double r, Color couleur, double alpha) => Paint()
  ..shader = RadialGradient(colors: [couleur.withValues(alpha: alpha), couleur.withValues(alpha: 0)])
      .createShader(Rect.fromCircle(center: c, radius: r));

class _PeintreVille extends CustomPainter {
  _PeintreVille(this.s, this.w) : super(repaint: s._temps);

  final _SceneAccueilState s;
  final SceneAccueil w;

  @override
  void paint(Canvas canvas, Size size) {
    final t = s._horloge;
    final pal = w.sombre ? _Palette.nuit : _Palette.crepuscule;
    final e = min(size.width / _l, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _l * e) / 2, (size.height - _h * e) / 2);
    canvas.scale(e);

    final cadre = RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, _l, _h), const Radius.circular(26));
    // L'ombre de la carte.
    canvas.drawRRect(
      cadre.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: w.sombre ? 0.45 : 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.save();
    canvas.clipRRect(cadre);

    final regard = s._lisse - const Offset(_l / 2, _h / 2);
    final relie = w.etat == EtatConnexion.connecte;
    final horsLigne = w.etat == EtatConnexion.horsLigne;

    _ciel(canvas, pal, t, regard);
    _lointain(canvas, pal, regard);
    _route(canvas, pal);
    _lampadaires(canvas);
    _arbres(canvas, pal, t);
    final lumiere = _lumieres(t, relie, horsLigne);
    for (var i = 0; i < _batiments.length; i++) {
      _batiment(canvas, pal, i);
    }
    _vitres(canvas, pal, t, lumiere, relie, horsLigne);
    _etal(canvas, pal);
    _moto(canvas, t);
    if (!horsLigne) _messages(canvas, t, relie);

    canvas.restore();
    // Le liseré de la carte.
    canvas.drawRRect(
      cadre,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _blanc.withValues(alpha: w.sombre ? 0.08 : 0.25),
    );
    canvas.restore();
  }

  // ── Le ciel ──

  void _ciel(Canvas canvas, _Palette pal, double t, Offset regard) {
    const r = Rect.fromLTWH(0, 0, _l, _h);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: pal.ciel,
          stops: const [0, 0.55, 0.85],
        ).createShader(r),
    );
    final d = -regard * 0.012;
    // Les étoiles : des graines fixes, chacune scintille à son rythme.
    final hasard = Random(11);
    final point = Paint();
    for (var i = 0; i < 46; i++) {
      final x = hasard.nextDouble() * _l, y = hasard.nextDouble() * 150;
      final phase = hasard.nextDouble() * 6.28, taille = 0.5 + hasard.nextDouble() * 1.1;
      final eclat = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * (0.8 + hasard.nextDouble()) + phase));
      point.color = _blanc.withValues(alpha: eclat * pal.etoiles * (1 - y / 190));
      canvas.drawCircle(Offset(x, y) + d, taille, point);
    }
    // La lune : un croissant.
    final c = const Offset(470, 52) + d * 1.4;
    canvas.drawCircle(c, 34, _halo(c, 34, _blanc, 0.18));
    final lune = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: 13)),
      Path()..addOval(Rect.fromCircle(center: c + const Offset(6, -4), radius: 11.5)),
    );
    canvas.drawPath(lune, Paint()..color = const Color(0xFFFFF1CF));
  }

  /// Les toits lointains, en silhouette, avec quelques fenêtres allumées.
  void _lointain(Canvas canvas, _Palette pal, Offset regard) {
    final d = -regard * 0.025;
    final hasard = Random(5);
    final mur = Paint()..color = pal.lointain;
    final petite = Paint();
    var x = -20.0;
    while (x < _l + 20) {
      final l = 26 + hasard.nextDouble() * 40, h = 40 + hasard.nextDouble() * 70;
      final r = Rect.fromLTWH(x, _sol - h, l, h + 4).shift(d);
      canvas.drawRect(r, mur);
      for (var k = 0; k < 4; k++) {
        if (hasard.nextDouble() < 0.4) {
          petite.color = _chaud.withValues(alpha: 0.25 + hasard.nextDouble() * 0.25);
          canvas.drawRect(
            Rect.fromLTWH(r.left + 5 + hasard.nextDouble() * (l - 12), r.top + 6 + hasard.nextDouble() * (h - 20), 3, 4),
            petite,
          );
        }
      }
      x += l + 2;
    }
  }

  void _route(Canvas canvas, _Palette pal) {
    canvas.drawRect(const Rect.fromLTWH(0, _sol, _l, _h - _sol), Paint()..color = pal.route);
    // Le trottoir.
    canvas.drawRect(const Rect.fromLTWH(0, _sol, _l, 5), Paint()..color = pal.toit.withValues(alpha: 0.8));
    // La ligne du milieu.
    final ligne = Paint()
      ..strokeWidth = 2
      ..color = _blanc.withValues(alpha: 0.18);
    for (var x = 8.0; x < _l; x += 34) {
      canvas.drawLine(Offset(x, 277), Offset(x + 16, 277), ligne);
    }
  }

  void _lampadaires(Canvas canvas) {
    for (final x in const [186.0, 350.0]) {
      final tete = Offset(x + 9, _sol - 66);
      final sol = Rect.fromCenter(center: Offset(x + 9, _sol + 14), width: 80, height: 22);
      canvas.drawOval(
        sol,
        Paint()
          ..shader = RadialGradient(colors: [_chaud.withValues(alpha: 0.22), _chaud.withValues(alpha: 0)]).createShader(sol),
      );
      canvas.drawCircle(tete, 26, _halo(tete, 26, _chaud, 0.32));
      final poteau = Paint()
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF0D1022);
      canvas.drawLine(Offset(x, _sol + 2), Offset(x, _sol - 64), poteau);
      canvas.drawArc(Rect.fromCircle(center: Offset(x + 5, _sol - 64), radius: 5), pi, pi / 2, false, poteau);
      canvas.drawCircle(tete + const Offset(0, 1), 2.6, Paint()..color = const Color(0xFFFFE3A6));
    }
  }

  void _arbres(Canvas canvas, _Palette pal, double t) {
    final tronc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = pal.feuillage;
    // Le palmier, qui ondule à peine.
    final vent = sin(t * 0.7) * 2;
    const pied = Offset(346, _sol + 2);
    final tete = Offset(340 + vent, _sol - 92);
    canvas.drawPath(
      Path()
        ..moveTo(pied.dx, pied.dy)
        ..quadraticBezierTo(352, _sol - 50, tete.dx, tete.dy),
      tronc,
    );
    final palme = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = pal.feuillage;
    for (var k = 0; k < 7; k++) {
      final a = -pi / 2 + (k - 3) * 0.55 + sin(t * 0.9 + k) * 0.05;
      final bout = tete + Offset(cos(a) * 30, sin(a) * 18 + 10 + (k - 3).abs() * 3.0);
      final milieu = tete + Offset(cos(a) * 16, sin(a) * 14 - 4);
      canvas.drawPath(
        Path()
          ..moveTo(tete.dx, tete.dy)
          ..quadraticBezierTo(milieu.dx, milieu.dy, bout.dx, bout.dy),
        palme,
      );
    }
    // Le manguier : un feuillage rond et dense.
    tronc.strokeWidth = 5;
    canvas.drawLine(const Offset(470, _sol + 2), const Offset(470, _sol - 30), tronc);
    final m = Paint()..color = pal.feuillage;
    for (final (dx, dy, r) in const [(-12.0, -40.0, 15.0), (6.0, -46.0, 17.0), (16.0, -34.0, 12.0), (-2.0, -30.0, 14.0)]) {
      canvas.drawCircle(Offset(470 + dx, _sol + dy), r, m);
    }
  }

  // ── Les bâtiments ──

  void _batiment(Canvas canvas, _Palette pal, int i) {
    final b = _batiments[i];
    if (b.toit == _Toit.aucun) return;
    final mur = Rect.fromLTWH(b.x, b.haut, b.largeur, b.hauteur + 2);
    canvas.drawRect(mur, Paint()..color = pal.murs[b.couleur]);
    final toit = Paint()..color = pal.toit;
    if (b.toit == _Toit.tole) {
      // Le toit de tôle : deux pans qui dépassent, avec leurs ondulations.
      final p = Path()
        ..moveTo(b.x - 6, b.haut + 2)
        ..lineTo(b.x + b.largeur * 0.5, b.haut - 18)
        ..lineTo(b.x + b.largeur + 6, b.haut + 2)
        ..close();
      canvas.drawPath(p, toit);
      final onde = Paint()
        ..strokeWidth = 0.8
        ..color = _blanc.withValues(alpha: 0.08);
      for (var k = 1; k < 8; k++) {
        canvas.drawLine(
          Offset(b.x + b.largeur * 0.5, b.haut - 18),
          Offset(b.x - 6 + (b.largeur + 12) * k / 8, b.haut + 2),
          onde,
        );
      }
      // La porte.
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(b.x + b.largeur / 2 - 7, _sol - 26, 14, 26),
          topLeft: const Radius.circular(7),
          topRight: const Radius.circular(7),
        ),
        Paint()..color = pal.vitreEteinte,
      );
    } else {
      // L'immeuble : un parapet, une citerne sur le toit, des balcons.
      canvas.drawRect(Rect.fromLTWH(b.x - 3, b.haut - 4, b.largeur + 6, 6), toit);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(b.x + b.largeur - 26, b.haut - 18, 16, 14), const Radius.circular(3)),
        toit,
      );
      final balcon = Paint()
        ..strokeWidth = 1.4
        ..color = _blanc.withValues(alpha: 0.12);
      for (final f in b.fenetres) {
        if (f.left == b.fenetres.first.left) {
          canvas.drawLine(Offset(b.x + 4, f.bottom + 5), Offset(b.x + b.largeur - 4, f.bottom + 5), balcon);
        }
      }
    }
  }

  void _etal(Canvas canvas, _Palette pal) {
    final b = _batiments[2];
    // Les montants et l'auvent rayé.
    final montant = Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFF0D1022);
    canvas.drawLine(Offset(b.x + 4, _sol + 2), Offset(b.x + 4, _sol - 36), montant);
    canvas.drawLine(Offset(b.x + b.largeur - 4, _sol + 2), Offset(b.x + b.largeur - 4, _sol - 36), montant);
    const n = 6;
    final pas = (b.largeur + 8) / n;
    for (var k = 0; k < n; k++) {
      final x0 = b.x - 4 + k * pas;
      final p = Path()
        ..moveTo(x0, _sol - 46)
        ..lineTo(x0 + pas, _sol - 46)
        ..lineTo(x0 + pas, _sol - 36)
        ..arcToPoint(Offset(x0, _sol - 36), radius: Radius.circular(pas / 2))
        ..close();
      canvas.drawPath(p, Paint()..color = k.isEven ? const Color(0xFFE2574C) : const Color(0xFFF3E6D0));
    }
    // L'étal, ses fruits, et la petite lampe du marchand.
    canvas.drawRect(Rect.fromLTWH(b.x, _sol - 14, b.largeur, 14), Paint()..color = pal.murs[2]);
    const fruits = [Color(0xFFF6B73C), Color(0xFFE2574C), Color(0xFF7CC36A), Color(0xFFF6B73C), Color(0xFFF28C38)];
    for (var k = 0; k < 9; k++) {
      canvas.drawCircle(Offset(b.x + 7 + k * 5.6, _sol - 16 - (k.isOdd ? 2 : 0)), 3, Paint()..color = fruits[k % fruits.length]);
    }
    final lampe = Offset(b.x + b.largeur / 2, _sol - 32);
    canvas.drawCircle(lampe, 22, _halo(lampe, 22, _chaud, 0.35));
    canvas.drawCircle(lampe, 2.2, Paint()..color = const Color(0xFFFFE3A6));
  }

  // ── Les fenêtres et la lumière ──

  /// La lumière de chaque fenêtre (0 à 1), d'après les messages passés.
  List<double> _lumieres(double t, bool relie, bool horsLigne) {
    final l = List<double>.filled(_fenetres.length, 0);
    if (horsLigne) return l;
    void passage(List<int> chemin, double depuis) {
      final c = [...chemin, if (relie) _ordi];
      for (var k = 0; k < c.length; k++) {
        final ecoule = depuis - k * _saut;
        if (ecoule < 0) continue;
        final v = ecoule < 0.12 ? ecoule / 0.12 : exp(-(ecoule - 0.12) * 0.7);
        l[c[k]] = max(l[c[k]], v);
      }
    }

    for (final (chemin, decalage) in _rondes) {
      passage(chemin, (t + decalage) % _periode);
    }
    for (final envoi in s._envois) {
      passage(envoi.chemin, t - envoi.depart);
    }
    return l;
  }

  void _vitres(Canvas canvas, _Palette pal, double t, List<double> lumiere, bool relie, bool horsLigne) {
    for (var i = 0; i < _fenetres.length; i++) {
      final f = _fenetres[i];
      if (i == _ordi) {
        _fenetreOrdi(canvas, pal, f, t, lumiere[i], relie, horsLigne);
        continue;
      }
      // Les habitants : une lumière douce qui vacille à peine (une télé…).
      final chezSoi = _habitees.contains(i) ? 0.38 + 0.06 * sin(t * 2.3 + i) : 0.0;
      final v = max(chezSoi, lumiere[i]);
      final vitre = RRect.fromRectAndRadius(f, const Radius.circular(2));
      canvas.drawRRect(vitre, Paint()..color = pal.vitreEteinte);
      if (v > 0.01) {
        canvas.drawRRect(vitre, Paint()..color = _chaud.withValues(alpha: v));
        // Le halo autour d'une fenêtre qui vient de recevoir un message.
        if (lumiere[i] > 0.05) {
          canvas.drawRRect(
            vitre.inflate(6),
            Paint()
              ..color = _chaud.withValues(alpha: 0.28 * lumiere[i])
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
        }
        // Une silhouette derrière certaines vitres.
        if (i % 3 == 0) {
          final ombre = Paint()..color = const Color(0xFF3A2410).withValues(alpha: 0.55 * v);
          canvas.drawCircle(Offset(f.center.dx + 1, f.bottom - 8), 2.6, ombre);
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(f.center.dx - 3.5, f.bottom - 5.2, 9, 5.2),
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
            ombre,
          );
        }
      }
      // Le croisillon.
      canvas.drawLine(
        Offset(f.center.dx, f.top),
        Offset(f.center.dx, f.bottom),
        Paint()
          ..strokeWidth = 1
          ..color = pal.murs[0].withValues(alpha: 0.9),
      );
      // La fenêtre survolée : un liseré, on peut cliquer.
      if (i == s._survolee) {
        canvas.drawRRect(
          vitre.inflate(2.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = _chaud.withValues(alpha: 0.9),
        );
      }
    }
  }

  /// La fenêtre de cet ordinateur : la seule dans la couleur d'accent.
  void _fenetreOrdi(Canvas canvas, _Palette pal, Rect f, double t, double arrivee, bool relie, bool horsLigne) {
    final vitre = RRect.fromRectAndRadius(f, const Radius.circular(3));
    final double fond;
    if (relie) {
      fond = 0.55 + 0.45 * arrivee;
    } else if (horsLigne) {
      fond = 0;
    } else {
      fond = 0.25 + 0.2 * (0.5 + 0.5 * sin(t * 4));
    }
    canvas.drawRRect(vitre, Paint()..color = pal.vitreEteinte);
    if (fond > 0) {
      canvas.drawRRect(
        vitre.inflate(8 + 6 * arrivee),
        Paint()
          ..color = w.accent.withValues(alpha: 0.35 * fond)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawRRect(vitre, Paint()..color = Color.lerp(w.accent, _blanc, 0.15)!.withValues(alpha: 0.75 * fond));
    }
    // L'ordinateur posé sur la table, vu de dos.
    final sombre = Paint()..color = const Color(0xFF0B0E1E).withValues(alpha: 0.85);
    canvas.drawRect(Rect.fromLTWH(f.left + 3, f.bottom - 5, f.width - 6, 2.5), sombre);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(f.center.dx - 9, f.bottom - 18, 18, 12), const Radius.circular(1.5)),
      sombre,
    );
    canvas.drawRect(Rect.fromLTWH(f.center.dx - 12, f.bottom - 6.5, 24, 1.8), sombre);
    // Le croisillon et le cadre.
    canvas.drawLine(
      Offset(f.left, f.top + 9),
      Offset(f.right, f.top + 9),
      Paint()
        ..strokeWidth = 1.2
        ..color = pal.murs[3],
    );
    canvas.drawRRect(
      vitre,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = pal.toit,
    );
  }

  // ── Les messages ──

  void _messages(Canvas canvas, double t, bool relie) {
    void trajet(List<int> chemin, double depuis) {
      final c = [...chemin, if (relie) _ordi];
      if (depuis < 0 || (depuis / _saut).floor() >= c.length - 1) return;
      // La lueur et sa traîne : quelques positions un peu plus tôt.
      for (var r = 5; r >= 0; r--) {
        final u = depuis - r * 0.035;
        if (u < 0) continue;
        final k = (u / _saut).floor();
        if (k >= c.length - 1) continue;
        final p = _position(c[k], c[k + 1], (u - k * _saut) / _saut);
        final a = 1 - r / 6;
        if (r == 0) {
          canvas.drawCircle(p, 11, _halo(p, 11, _chaud, 0.55));
          canvas.drawCircle(p, 2.8, Paint()..color = const Color(0xFFFFF4D6));
        } else {
          canvas.drawCircle(p, 1.8 * a, Paint()..color = _chaud.withValues(alpha: 0.6 * a));
        }
      }
    }

    for (final (chemin, decalage) in _rondes) {
      trajet(chemin, (t + decalage) % _periode);
    }
    for (final envoi in s._envois) {
      trajet(envoi.chemin, t - envoi.depart);
    }
  }

  /// D'une fenêtre à l'autre, en arc, comme une luciole.
  Offset _position(int a, int b, double f) {
    final p = _fenetres[a].center, q = _fenetres[b].center;
    final x = f.clamp(0.0, 1.0);
    final g = x * x * (3 - 2 * x);
    final haut = 16 + (q - p).distance * 0.18;
    return Offset.lerp(p, q, g)! + Offset(0, -sin(g * pi) * haut);
  }

  // ── La moto-taxi ──

  void _moto(Canvas canvas, double t) {
    const periode = 13.0, traversee = 5.5;
    final u = (t + 4) % periode;
    if (u > traversee) return;
    final x = -50 + (_l + 100) * (u / traversee);
    const y = 268.0;
    final saut = sin(t * 18) * 0.5;
    // Le phare.
    final faisceau = Rect.fromLTWH(x + 16, y - 16, 54, 24);
    canvas.drawPath(
      Path()
        ..moveTo(x + 16, y - 6)
        ..lineTo(x + 70, y - 16)
        ..lineTo(x + 70, y + 8)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFFF2C2).withValues(alpha: 0.4), const Color(0xFFFFF2C2).withValues(alpha: 0)],
        ).createShader(faisceau),
    );
    final noir = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF0A0C18);
    canvas.drawCircle(Offset(x - 12, y + 6), 5.5, noir);
    canvas.drawCircle(Offset(x + 12, y + 6), 5.5, noir);
    // Le corps jaune.
    final corps = Path()
      ..moveTo(x - 14, y + 2 + saut)
      ..quadraticBezierTo(x - 6, y - 6 + saut, x + 6, y - 3 + saut)
      ..lineTo(x + 14, y - 5 + saut)
      ..lineTo(x + 12, y + 3 + saut)
      ..close();
    canvas.drawPath(corps, Paint()..color = const Color(0xFFF2C230));
    // Le conducteur et son passager.
    final gens = Paint()..color = const Color(0xFF0A0C18);
    for (final (dx, h) in const [(2.0, 0.0), (-8.0, 1.5)]) {
      canvas.drawCircle(Offset(x + dx, y - 17 + h + saut), 3.2, gens);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + dx - 3, y - 13 + h + saut, 6, 10), const Radius.circular(3)),
        gens,
      );
    }
    canvas.drawCircle(Offset(x + 15, y - 5 + saut), 1.8, Paint()..color = const Color(0xFFFFF2C2));
  }

  @override
  bool shouldRepaint(_PeintreVille old) =>
      old.w.etat != w.etat || old.w.accent != w.accent || old.w.sombre != w.sombre;
}
