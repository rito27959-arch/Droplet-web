// LA SCÈNE DE L'ACCUEIL — ce qu'on voit quand aucune discussion n'est ouverte.
//
// WhatsApp Web montre une seule illustration calme ; Droplet raconte son
// principe sans un mot de technique : des téléphones dessinés au trait
// (le même style que les fonds de discussion), reliés entre eux, et de
// petites gouttes qui sautent de l'un à l'autre jusqu'à votre téléphone,
// puis jusqu'à cet ordinateur. Au centre, la goutte de Droplet, en verre,
// qui vous suit des yeux.
//
// Elle vit avec l'état réel de la liaison :
//   connecté   → le lien téléphone ↔ ordinateur est plein, les gouttes arrivent ;
//   connexion  → le lien est en pointillés qui défilent, les gouttes
//                s'arrêtent à votre téléphone ;
//   hors ligne → les liens pâlissent, votre téléphone dort, plus de gouttes.
//
// Souris : les téléphones s'écartent doucement du pointeur. Clic sur un
// téléphone : une goutte part de lui. Clic sur la grande goutte : elle
// rebondit.
//
// Dessin natif (CustomPainter), pas de moteur de jeu : une quinzaine
// d'objets, rien à simuler. Tout est calculé à partir de l'horloge.
// « Réduire les animations » → une image fixe.
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../donnees/transport.dart' show EtatConnexion;

/// La taille logique de la scène ; elle est mise à l'échelle de la place.
const double _l = 520, _h = 300;

/// Les téléphones du maillage (0 à 4), votre téléphone (5), l'ordinateur (6).
const List<Offset> _noeuds = [
  Offset(70, 92),
  Offset(178, 38),
  Offset(346, 34),
  Offset(454, 96),
  Offset(84, 232),
  Offset(300, 252),
  Offset(448, 236),
];
const int _vous = 5, _ordi = 6;

/// La profondeur de chaque nœud pour la parallaxe (1 = au premier plan).
const List<double> _profondeur = [0.55, 0.8, 0.6, 0.9, 1.0, 0.75, 0.5];

/// Les liens du maillage (sans celui vers l'ordinateur, dessiné à part).
const List<(int, int)> _liens = [(0, 1), (1, 2), (2, 3), (0, 4), (4, 5), (3, 5), (1, 5)];

/// Les voisins de chaque nœud, pour trouver un chemin jusqu'à vous.
final Map<int, List<int>> _voisins = () {
  final v = <int, List<int>>{};
  for (final (a, b) in _liens) {
    (v[a] ??= []).add(b);
    (v[b] ??= []).add(a);
  }
  return v;
}();

/// Les trajets des gouttes qui tournent toutes seules : (chemin, décalage).
const List<(List<int>, double)> _rondes = [
  ([2, 3, 5], 0.0),
  ([0, 4, 5], 2.1),
  ([1, 5], 3.9),
];

const double _vitesse = 110; // en points logiques par seconde
const double _periode = 6.0; // une goutte par trajet toutes les 6 s

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

  /// La couleur choisie dans les réglages.
  final Color accent;

  /// Le trait des dessins (la couleur du texte).
  final Color encre;

  /// Le remplissage des téléphones.
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
  final ValueNotifier<double> _temps = ValueNotifier(1.8);
  Duration _dernier = Duration.zero;
  double _horloge = 1.8;

  /// Le pointeur en coordonnées logiques (null : hors de la scène), et sa
  /// position lissée, pour que tout glisse au lieu de sauter.
  Offset? _pointeur;
  Offset _lisse = const Offset(_l / 2, _h / 2);
  double _presence = 0;

  final List<_Envoi> _envois = [];
  double _rebond = -10;
  bool _fige = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fige = MediaQuery.disableAnimationsOf(context);
    if (_fige) {
      _ticker.stop();
      _horloge = 1.8;
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
    final k = 1 - exp(-dt * 6);
    _lisse = Offset.lerp(_lisse, cible, k)!;
    _presence += ((_pointeur == null ? 0 : 1) - _presence) * k;
    _envois.removeWhere((e) => _horloge - e.depart > 12);
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

  void _toucher(Offset p) {
    if (_fige) return;
    // La grande goutte.
    if ((p - const Offset(_l / 2, _h / 2 - 4)).distance < 52) {
      _rebond = _horloge;
      return;
    }
    // Le téléphone le plus proche du clic, sinon un au hasard.
    var choisi = -1;
    var meilleur = 40.0;
    for (var i = 0; i < 5; i++) {
      final d = (p - _noeuds[i]).distance;
      if (d < meilleur) {
        meilleur = d;
        choisi = i;
      }
    }
    if (choisi < 0) choisi = Random().nextInt(5);
    _envois.add(_Envoi(_chemin(choisi), _horloge));
    if (_envois.length > 8) _envois.removeAt(0);
  }

  /// Le plus court chemin d'un téléphone jusqu'au vôtre.
  static List<int> _chemin(int depuis) {
    final venu = <int, int>{depuis: -1};
    final file = [depuis];
    while (file.isNotEmpty) {
      final n = file.removeAt(0);
      if (n == _vous) break;
      for (final v in _voisins[n]!) {
        if (!venu.containsKey(v)) {
          venu[v] = n;
          file.add(v);
        }
      }
    }
    final chemin = <int>[];
    for (var n = _vous; n != -1; n = venu[n]!) {
      chemin.insert(0, n);
    }
    return chemin;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _l / _h,
      child: LayoutBuilder(
        builder: (context, c) {
          final taille = Size(c.maxWidth, c.maxHeight);
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (e) => _pointeur = _logique(e.localPosition, taille),
            onExit: (_) => _pointeur = null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails e) => _toucher(_logique(e.localPosition, taille)),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: taille,
                  painter: _PeintreScene(this, widget),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeintreScene extends CustomPainter {
  _PeintreScene(this.s, this.w) : super(repaint: s._temps);

  final _SceneAccueilState s;
  final SceneAccueil w;

  static const _joues = Color(0xFFFF8FA3);

  @override
  void paint(Canvas canvas, Size size) {
    final t = s._horloge;
    final e = min(size.width / _l, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _l * e) / 2, (size.height - _h * e) / 2);
    canvas.scale(e);

    final etat = w.etat;
    final horsLigne = etat == EtatConnexion.horsLigne;
    final relie = etat == EtatConnexion.connecte;

    // Les positions vivantes : un léger balancement, la parallaxe, et
    // l'écart autour du pointeur.
    const centre = Offset(_l / 2, _h / 2);
    final regard = (s._lisse - centre);
    final p = <Offset>[];
    for (var i = 0; i < _noeuds.length; i++) {
      var q = _noeuds[i] + Offset(0, sin(t * 0.9 + i * 1.7) * 2.6);
      q -= regard * (0.025 * _profondeur[i]);
      final d = q - s._lisse;
      final dist = d.distance;
      if (dist < 110 && dist > 0.1) {
        q += d / dist * (110 - dist) * 0.16 * s._presence;
      }
      p.add(q);
    }

    // ── Les liens ──
    final lien = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = (horsLigne ? w.encre : w.accent).withValues(alpha: horsLigne ? 0.12 : 0.32);
    for (final (a, b) in _liens) {
      _pointille(canvas, p[a], p[b], lien, 1.5, 6, 0);
    }
    // Votre téléphone ↔ cet ordinateur.
    final fort = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    if (relie) {
      fort.color = w.accent.withValues(alpha: 0.75);
      canvas.drawLine(p[_vous], p[_ordi], fort);
    } else if (etat == EtatConnexion.connexion) {
      fort.color = w.accent.withValues(alpha: 0.55);
      _pointille(canvas, p[_vous], p[_ordi], fort, 6, 7, -t * 18);
    } else {
      // Le lien rompu : deux bouts et un vide au milieu.
      fort.color = w.encre.withValues(alpha: 0.22);
      final a = p[_vous], b = p[_ordi];
      canvas.drawLine(a, Offset.lerp(a, b, 0.38)!, fort);
      canvas.drawLine(Offset.lerp(a, b, 0.62)!, b, fort);
    }

    // ── Les téléphones et l'ordinateur ──
    for (var i = 0; i < 5; i++) {
      _telephone(canvas, p[i], t, i, vous: false, dort: horsLigne);
    }
    _telephone(canvas, p[_vous], t, _vous, vous: true, dort: horsLigne);
    final arrivee = _arrivee(t, relie);
    _ordinateur(canvas, p[_ordi], t, arrivee, horsLigne);

    // ── La grande goutte ──
    _grandeGoutte(canvas, centre + regard * 0.03 + Offset(0, sin(t * 1.1) * 3 - 4), regard, t);

    // ── Les gouttes qui voyagent ──
    if (!horsLigne) {
      for (final (chemin, decalage) in _rondes) {
        final c = [...chemin, if (relie) _ordi];
        final phase = (t + decalage) % _periode;
        _gouttelette(canvas, [for (final n in c) p[n]], phase * _vitesse);
      }
      for (final envoi in s._envois) {
        final c = [...envoi.chemin, if (relie) _ordi];
        _gouttelette(canvas, [for (final n in c) p[n]], (t - envoi.depart) * _vitesse * 1.25, grosse: true);
      }
    }
    canvas.restore();
  }

  /// 0 → 1 → 0 pendant la demi-seconde qui suit l'arrivée d'une goutte.
  double _arrivee(double t, bool relie) {
    if (!relie) return 0;
    var a = 0.0;
    void essai(double depuis) {
      if (depuis >= 0 && depuis < 0.7) a = max(a, sin(depuis / 0.7 * pi));
    }

    for (final (chemin, decalage) in _rondes) {
      final c = [for (final n in [...chemin, _ordi]) _noeuds[n]];
      final duree = _longueur(c) / _vitesse;
      essai((t + decalage) % _periode - duree);
    }
    for (final envoi in s._envois) {
      final c = [for (final n in [...envoi.chemin, _ordi]) _noeuds[n]];
      essai(t - envoi.depart - _longueur(c) / (_vitesse * 1.25));
    }
    return a;
  }

  static double _longueur(List<Offset> c) {
    var l = 0.0;
    for (var i = 1; i < c.length; i++) {
      l += (c[i] - c[i - 1]).distance;
    }
    return l;
  }

  void _gouttelette(Canvas canvas, List<Offset> c, double parcouru, {bool grosse = false}) {
    final total = _longueur(c);
    if (parcouru < 0 || parcouru > total) return;
    var reste = parcouru;
    var pos = c.last;
    var dir = const Offset(1, 0);
    for (var i = 1; i < c.length; i++) {
      final seg = c[i] - c[i - 1];
      final l = seg.distance;
      if (reste <= l) {
        pos = c[i - 1] + seg * (reste / l);
        dir = seg / l;
        // Un petit saut au-dessus de chaque lien.
        final f = reste / l;
        pos += Offset(0, -sin(f * pi) * min(14.0, l * 0.08));
        break;
      }
      reste -= l;
    }
    // Apparition et disparition en douceur.
    final alpha = (min(parcouru, total - parcouru) / 18).clamp(0.0, 1.0);
    final r = grosse ? 6.0 : 4.6;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(atan2(dir.dy, dir.dx) + pi / 2);
    // La traîne.
    canvas.drawCircle(
      Offset(0, r * 1.9),
      r * 0.55,
      Paint()..color = w.accent.withValues(alpha: 0.25 * alpha),
    );
    // La goutte, pointe vers l'arrière.
    final g = Path()
      ..moveTo(0, r * 1.9)
      ..cubicTo(r * 0.5, r * 1.1, r, r * 0.6, r, 0)
      ..arcToPoint(Offset(-r, 0), radius: Radius.circular(r), clockwise: false)
      ..cubicTo(-r, r * 0.6, -r * 0.5, r * 1.1, 0, r * 1.9)
      ..close();
    canvas.drawPath(g, Paint()..color = w.accent.withValues(alpha: alpha));
    canvas.drawCircle(
      Offset(-r * 0.35, -r * 0.3),
      r * 0.28,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.75 * alpha),
    );
    canvas.restore();
  }

  void _pointille(Canvas canvas, Offset a, Offset b, Paint paint, double trait, double vide, double decalage) {
    final d = b - a;
    final l = d.distance;
    if (l == 0) return;
    final u = d / l;
    final pas = trait + vide;
    var x = decalage % pas;
    if (x > 0) x -= pas;
    for (; x < l; x += pas) {
      final s0 = max(0.0, x), s1 = min(l, x + trait);
      if (s1 > s0) canvas.drawLine(a + u * s0, a + u * s1, paint);
    }
  }

  /// Les yeux qui clignent : fermés 0,12 s toutes les quelques secondes.
  static double _paupiere(double t, int graine) {
    final periode = 3.6 + (graine % 3) * 1.3;
    final x = (t + graine * 0.77) % periode;
    return x < 0.12 ? 0.15 : 1;
  }

  void _visage(Canvas canvas, Offset c, double t, int graine, {required double echelle, required bool dort, Offset regard = Offset.zero, Color? encre}) {
    final ink = encre ?? w.encre;
    final trait = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * echelle
      ..strokeCap = StrokeCap.round
      ..color = ink;
    final ex = 4.6 * echelle, ey = -2.5 * echelle;
    if (dort) {
      for (final sgn in [-1.0, 1.0]) {
        final o = c + Offset(sgn * ex, ey);
        canvas.drawArc(Rect.fromCenter(center: o, width: 4 * echelle, height: 3 * echelle), 0, pi, false, trait);
      }
    } else {
      final p = _paupiere(t, graine);
      for (final sgn in [-1.0, 1.0]) {
        final o = c + Offset(sgn * ex, ey) + regard;
        canvas.drawOval(
          Rect.fromCenter(center: o, width: 2.8 * echelle, height: 3.6 * echelle * p),
          Paint()..color = ink,
        );
      }
    }
    // Les joues.
    final joue = Paint()..color = _joues.withValues(alpha: w.sombre ? 0.35 : 0.45);
    for (final sgn in [-1.0, 1.0]) {
      canvas.drawOval(Rect.fromCenter(center: c + Offset(sgn * (ex + 3.2 * echelle), 1.6 * echelle), width: 3.6 * echelle, height: 2.2 * echelle), joue);
    }
    // La bouche.
    if (dort) {
      canvas.drawLine(c + Offset(-1.6 * echelle, 2.4 * echelle), c + Offset(1.6 * echelle, 2.4 * echelle), trait);
    } else {
      canvas.drawArc(Rect.fromCenter(center: c + Offset(0, 0.8 * echelle), width: 4.4 * echelle, height: 3.6 * echelle), 0.25, pi - 0.5, false, trait);
    }
  }

  void _telephone(Canvas canvas, Offset c, double t, int i, {required bool vous, required bool dort}) {
    final corps = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 30, height: 50), const Radius.circular(8));
    // L'ombre portée, très légère.
    canvas.drawRRect(corps.shift(const Offset(0, 3)), Paint()..color = const Color(0xFF000000).withValues(alpha: w.sombre ? 0.25 : 0.06));
    canvas.drawRRect(corps, Paint()..color = w.carte);
    if (vous && !dort) {
      // Votre téléphone : l'écran teinté de l'accent, qui respire.
      final souffle = 0.5 + 0.5 * sin(t * 2.2);
      canvas.drawRRect(
        corps.deflate(3),
        Paint()..color = w.accent.withValues(alpha: 0.10 + 0.06 * souffle),
      );
    }
    canvas.drawRRect(
      corps,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = vous ? 2.2 : 1.7
        ..color = vous ? w.accent : w.encre.withValues(alpha: 0.85),
    );
    // L'écouteur.
    canvas.drawLine(
      c + const Offset(-4, -20),
      c + const Offset(4, -20),
      Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = (vous ? w.accent : w.encre).withValues(alpha: 0.7),
    );
    _visage(canvas, c + const Offset(0, -1), t, i, echelle: 1, dort: dort);
    if (vous && !dort) {
      // Une petite étincelle à quatre branches.
      final e = 0.6 + 0.4 * sin(t * 2.6);
      final o = c + const Offset(19, -26);
      final sp = Paint()
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = w.accent.withValues(alpha: e);
      canvas.drawLine(o + Offset(0, -4 * e), o + Offset(0, 4 * e), sp);
      canvas.drawLine(o + Offset(-4 * e, 0), o + Offset(4 * e, 0), sp);
    }
    if (dort) {
      // « z z » au-dessus de votre téléphone quand il est injoignable.
      if (vous) {
        final f = (t * 0.6) % 1;
        _z(canvas, c + Offset(14 + f * 6, -30 - f * 12), 5, w.encre.withValues(alpha: 0.5 * (1 - f)));
        _z(canvas, c + Offset(22 + f * 4, -42 - f * 10), 3.6, w.encre.withValues(alpha: 0.35 * (1 - f)));
      }
    }
  }

  void _z(Canvas canvas, Offset o, double s, Color c) {
    final z = Path()
      ..moveTo(o.dx - s / 2, o.dy - s / 2)
      ..lineTo(o.dx + s / 2, o.dy - s / 2)
      ..lineTo(o.dx - s / 2, o.dy + s / 2)
      ..lineTo(o.dx + s / 2, o.dy + s / 2);
    canvas.drawPath(
      z,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = c,
    );
  }

  void _ordinateur(Canvas canvas, Offset c, double t, double arrivee, bool dort) {
    final ecran = RRect.fromRectAndRadius(Rect.fromCenter(center: c + const Offset(0, -6), width: 66, height: 44), const Radius.circular(6));
    final trait = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..color = w.encre.withValues(alpha: 0.85);
    // L'onde quand une goutte arrive.
    if (arrivee > 0) {
      canvas.drawRRect(
        ecran.inflate(4 + 8 * (1 - arrivee)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = w.accent.withValues(alpha: 0.5 * arrivee),
      );
    }
    canvas.drawRRect(ecran.shift(const Offset(0, 3)), Paint()..color = const Color(0xFF000000).withValues(alpha: w.sombre ? 0.25 : 0.06));
    canvas.drawRRect(ecran, Paint()..color = w.carte);
    if (arrivee > 0) {
      canvas.drawRRect(ecran.deflate(3), Paint()..color = w.accent.withValues(alpha: 0.18 * arrivee));
    }
    canvas.drawRRect(ecran, trait);
    // Le clavier.
    final base = Path()
      ..moveTo(c.dx - 40, c.dy + 20)
      ..lineTo(c.dx + 40, c.dy + 20)
      ..lineTo(c.dx + 35, c.dy + 15)
      ..lineTo(c.dx - 35, c.dy + 15)
      ..close();
    canvas.drawPath(base, Paint()..color = w.carte);
    canvas.drawPath(base, trait);
    _visage(canvas, c + const Offset(0, -6), t, 9, echelle: 1.15, dort: dort);
  }

  void _grandeGoutte(Canvas canvas, Offset c, Offset regard, double t) {
    // Le rebond au clic : un écrasement amorti.
    final dr = t - s._rebond;
    final rebond = dr >= 0 && dr < 1.2 ? sin(dr * 14) * exp(-dr * 4.2) : 0.0;
    final souffle = 1 + sin(t * 1.3) * 0.012;
    final sx = souffle * (1 + rebond * 0.12), sy = souffle * (1 - rebond * 0.12);

    // L'ombre au sol.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 62), width: 70 * sx, height: 10),
      Paint()
        ..color = w.accent.withValues(alpha: w.sombre ? 0.22 : 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Le halo.
    canvas.drawCircle(
      c,
      78,
      Paint()
        ..shader = RadialGradient(colors: [w.accent.withValues(alpha: 0.16), w.accent.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: 78)),
    );

    canvas.save();
    canvas.translate(c.dx, c.dy + 50);
    canvas.scale(sx, sy);
    canvas.translate(0, -50);
    const r = 42.0;
    final g = Path()
      ..moveTo(0, -58)
      ..cubicTo(12, -42, r, -18, r, 10)
      ..arcToPoint(const Offset(-r, 10), radius: const Radius.circular(r))
      ..cubicTo(-r, -18, -12, -42, 0, -58)
      ..close();
    final clair = Color.lerp(w.accent, const Color(0xFFFFFFFF), 0.55)!;
    final fonce = Color.lerp(w.accent, const Color(0xFF000000), 0.28)!;
    final cadre = Rect.fromLTRB(-r, -58, r, 10 + r);
    canvas.drawPath(
      g,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.2),
          radius: 0.95,
          colors: [clair, w.accent, fonce],
          stops: const [0, 0.55, 1],
        ).createShader(cadre),
    );
    // Le reflet du verre, et le liseré.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-17, -6), width: 11, height: 22),
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55),
    );
    canvas.drawCircle(const Offset(-10, -24), 3.2, Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6));
    canvas.drawPath(
      g,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.35),
    );
    // Le visage, qui regarde le pointeur.
    final l = regard.distance;
    final yeux = l < 0.1 ? Offset.zero : regard / l * min(3.2, l * 0.03);
    _visage(canvas, const Offset(0, 16), t, 4, echelle: 2.1, dort: false, regard: yeux, encre: const Color(0xFF0B2545));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreScene old) =>
      old.w.etat != w.etat || old.w.accent != w.accent || old.w.encre != w.encre || old.w.carte != w.carte || old.w.sombre != w.sombre;
}
