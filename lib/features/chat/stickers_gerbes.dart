// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES SCÈNES PREMIUM — ce qui jaillit d'un sticker « Éclat » par-dessus la
// conversation, à son arrivée et à chaque toucher.
//
// Le sticker premium de WhatsApp étudié (« Tuft ») porte une seconde
// animation de 2048 × 2048 — QUATRE FOIS la taille du sticker — qui dure
// 4,3 s et RACONTE quelque chose : le lama à lunettes est une star, donc
// des appareils de paparazzis le mitraillent. Ce n'est pas un nuage de
// particules : c'est une petite scène liée au sticker.
//
// Les nôtres suivent la même règle :
//   • une zone de 4 × la taille du sticker, centrée sur lui ;
//   • 3,6 s ;
//   • une scène PROPRE à chaque sticker, au trait cerné comme le
//     personnage : bouquets de feu d'artifice successifs, pluie de pièces
//     d'or qui tournent sur elles-mêmes, planètes et étoiles filantes,
//     vague qui traverse, éclats de cristal…
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'stickers_personnage.dart';
import 'toile_fine.dart';

/// Les scènes premium.
enum GenreEffet { feuArtifice, arcEnCiel, coeurs, or, etincelles, onde, eclaboussure, cristal }

const Duration kDureeGerbe = Duration(milliseconds: 3600);

/// La scène qui déborde d'un sticker « Éclat ». Elle se retire d'elle-même.
class GerbePremium extends StatefulWidget {
  const GerbePremium({super.key, required this.genre, required this.centre, required this.taille, required this.surFin, this.tempsFixe});

  final GenreEffet genre;

  /// Le centre du sticker, dans le repère de la surcouche.
  final Offset centre;

  /// Le côté du sticker : la scène occupe 4 × ce côté.
  final double taille;
  final VoidCallback surFin;

  /// Pour les tests : un instant imposé (0 → 1).
  @visibleForTesting
  final double? tempsFixe;

  @override
  State<GerbePremium> createState() => _GerbePremiumState();
}

class _GerbePremiumState extends State<GerbePremium> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: kDureeGerbe)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.surFin();
    });

  @override
  void initState() {
    super.initState();
    if (widget.tempsFixe != null) {
      _c.value = widget.tempsFixe!;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PeintreScene(widget.genre, widget.centre, widget.taille * 2, _c),
      ),
    );
  }
}

class _PeintreScene extends CustomPainter {
  _PeintreScene(this.genre, this.centre, this.R, this.anim) : super(repaint: anim);

  final GenreEffet genre;
  final Offset centre;

  /// Le demi-côté de la zone de la scène.
  final double R;
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    if (t <= 0 || t >= 1) return;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    // Tout est dessiné en unités de R : (−1, −1) → (1, 1), sur une toile
    // « fine » (voir `toile_fine.dart`).
    canvas.scale(R);
    final fine = ToileFine(canvas);
    _scene(fine, t);
    fine.terminer();
    canvas.restore();
  }

  void _scene(Canvas canvas, double t) {
    // Le fondu de sortie, commun à toutes les scènes.
    final sortie = 1 - Curves.easeIn.transform(seg(t, 0.82, 1.0));
    switch (genre) {
      case GenreEffet.feuArtifice:
        _feu(canvas, t, sortie);
      case GenreEffet.arcEnCiel:
        _arc(canvas, t, sortie);
      case GenreEffet.coeurs:
        _coeurs(canvas, t, sortie);
      case GenreEffet.or:
        _or(canvas, t, sortie);
      case GenreEffet.etincelles:
        _espace(canvas, t, sortie);
      case GenreEffet.onde:
        _nova(canvas, t, sortie);
      case GenreEffet.eclaboussure:
        _vague(canvas, t, sortie);
      case GenreEffet.cristal:
        _cristaux(canvas, t, sortie);
    }
  }

  Paint _plume(double ep, Color couleur) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = ep
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = couleur;

  double _hasard(int k, [int sel = 0]) {
    final x = math.sin(k * 12.9898 + sel * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  // ── Trois bouquets successifs, chacun monté depuis le bas avec sa
  // traînée, éclatant en gouttes colorées qui retombent en scintillant.
  void _feu(Canvas c, double t, double sortie) {
    const bouquets = [(Offset(-0.5, -0.45), 0.0, 0), (Offset(0.5, -0.6), 0.16, 1), (Offset(0.05, -0.15), 0.32, 2)];
    const palettes = [
      [Color(0xFFFFC23D), Color(0xFFFF5E9C), Color(0xFFFFF0A0)],
      [Color(0xFF2FB8FF), Color(0xFF39E6C4), Colors.white],
      [Color(0xFFB57CFF), Color(0xFFFF5E9C), Color(0xFFFFC23D)],
    ];
    for (final (cible, depart, n) in bouquets) {
      final montee = seg(t, depart, depart + 0.14);
      final eclat = seg(t, depart + 0.14, depart + 0.62);
      final pal = palettes[n];
      if (montee > 0 && montee < 1) {
        final pos = Offset.lerp(Offset(cible.dx * 0.6, 1.0), cible, Curves.easeOutCubic.transform(montee))!;
        c.drawLine(Offset.lerp(pos, Offset(cible.dx * 0.6, 1.0), 0.3)!, pos, _plume(0.012, pal[0].withValues(alpha: 0.7)));
        c.drawCircle(pos, 0.022, Paint()..color = Colors.white);
      }
      if (eclat > 0 && eclat < 1) {
        // L'éclair au centre.
        final flash = bosse(eclat, 0, 0.15);
        if (flash > 0) {
          c.drawCircle(cible, 0.3, Paint()..shader = ui.Gradient.radial(cible, 0.3, [Colors.white.withValues(alpha: 0.8 * flash), Colors.white.withValues(alpha: 0)]));
        }
        for (var k = 0; k < 22; k++) {
          final a = k * 2 * math.pi / 22 + n;
          final v = 0.42 + 0.12 * _hasard(k, n);
          final d = v * Curves.easeOutCubic.transform(eclat);
          final pos = cible + Offset(math.cos(a), math.sin(a)) * d + Offset(0, 0.25 * eclat * eclat);
          final a2 = (1 - seg(eclat, 0.55, 1)) * sortie;
          c.drawLine(cible + Offset(math.cos(a), math.sin(a)) * d * 0.6 + Offset(0, 0.12 * eclat * eclat), pos, _plume(0.008, pal[k % 3].withValues(alpha: 0.5 * a2)));
          gouttelette(c, pos, 0.07 * (1 - 0.4 * eclat), pal[k % 3], angle: a - math.pi / 2, alpha: a2);
          // Le scintillement des braises qui retombent.
          if (eclat > 0.5 && (k + (t * 30).floor()) % 3 == 0) {
            etoile(c, pos + const Offset(0, 0.05), 0.03, const Color(0xFFFFE58A), alpha: a2);
          }
        }
      }
    }
  }

  // ── L'arc-en-ciel se déploie au-dessus, puis se défait en gouttes de
  // couleur qui tombent, entre des étincelles.
  void _arc(Canvas c, double t, double sortie) {
    const bandes = [Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFFFFD60A), Color(0xFF30D158), Color(0xFF0A84FF), Color(0xFFBF5AF2)];
    final d = Curves.easeOutCubic.transform(seg(t, 0.0, 0.35));
    final defait = seg(t, 0.45, 0.8);
    const centreArc = Offset(0, 0.25);
    final alphaArc = 1 - defait;
    if (alphaArc > 0) {
      c.drawArc(Rect.fromCircle(center: centreArc, radius: 0.93), math.pi, math.pi * d, false, _plume(0.025, kEncre.withValues(alpha: alphaArc)));
      for (var k = 0; k < bandes.length; k++) {
        c.drawArc(Rect.fromCircle(center: centreArc, radius: 0.88 - k * 0.075), math.pi, math.pi * d, false, _plume(0.075, bandes[k].withValues(alpha: alphaArc)));
      }
      c.drawArc(Rect.fromCircle(center: centreArc, radius: 0.88 - 5.5 * 0.075), math.pi, math.pi * d, false, _plume(0.02, kEncre.withValues(alpha: alphaArc)));
    }
    // Les gouttes de couleur.
    if (defait > 0) {
      for (var k = 0; k < 36; k++) {
        final a = math.pi + math.pi * _hasard(k);
        final bande = k % 6;
        final r = 0.88 - bande * 0.075;
        final depart = centreArc + Offset(math.cos(a), math.sin(a)) * r;
        final chute = seg(t, 0.45 + 0.15 * _hasard(k, 1), 1);
        gouttelette(c, depart + Offset(0, 1.1 * chute * chute), 0.06, bandes[bande], alpha: (chute > 0 ? 1.0 : 0.0) * sortie);
      }
    }
    for (var k = 0; k < 10; k++) {
      final p = seg(t, 0.1 + 0.06 * k, 0.4 + 0.06 * k);
      etoile(c, Offset(-0.9 + 1.8 * _hasard(k, 2), -0.9 + 1.2 * _hasard(k, 3)), 0.06 * bosse(p, 0, 1), const Color(0xFFFFE58A), alpha: bosse(p, 0, 1) * sortie);
    }
  }

  // ── Des cœurs qui montent par vagues en se balançant ; certains
  // éclatent en petits cœurs ; un anneau bat au centre.
  void _coeurs(Canvas c, double t, double sortie) {
    for (var k = 0; k < 3; k++) {
      final p = seg(t, k * 0.18, k * 0.18 + 0.4);
      if (p > 0 && p < 1) {
        c.drawCircle(Offset.zero, 0.3 + 0.6 * Curves.easeOutCubic.transform(p), _plume(0.04 * (1 - p), kRose.withValues(alpha: 0.7 * (1 - p))));
      }
    }
    for (var k = 0; k < 28; k++) {
      final depart = 0.6 * _hasard(k);
      final p = seg(t, depart, depart + 0.55);
      if (p <= 0 || p >= 1) continue;
      final x = -0.85 + 1.7 * _hasard(k, 1) + 0.08 * math.sin(p * 8 + k);
      final y = 1.0 - 2.0 * Curves.easeOut.transform(p);
      final taille = 0.07 + 0.08 * _hasard(k, 2);
      final couleur = [kRose, const Color(0xFFFF7AA2), const Color(0xFFFF4F7B), const Color(0xFFE0144C)][k % 4];
      if (k % 5 == 0 && p > 0.7) {
        // Celui-ci éclate en quatre petits cœurs.
        final e = seg(p, 0.7, 1);
        for (var j = 0; j < 4; j++) {
          final a = j * math.pi / 2 + math.pi / 4;
          coeur(c, Offset(x, y) + Offset(math.cos(a), math.sin(a)) * 0.15 * e, taille * 0.45, couleur: couleur, alpha: (1 - e) * sortie);
        }
      } else {
        coeur(c, Offset(x, y), taille * (0.6 + 0.4 * Curves.easeOutBack.transform(seg(p, 0, 0.2))), couleur: couleur, alpha: sortie * (1 - seg(p, 0.85, 1)), angle: 0.3 * math.sin(p * 6 + k));
      }
    }
  }

  // ── Une pluie de pièces d'or qui tournent sur elles-mêmes, deux
  // couronnes qui tombent en tournoyant, des éclats.
  void _or(Canvas c, double t, double sortie) {
    for (var k = 0; k < 26; k++) {
      final depart = 0.5 * _hasard(k);
      final p = seg(t, depart, depart + 0.5);
      if (p <= 0 || p >= 1) continue;
      final x = -0.9 + 1.8 * _hasard(k, 1);
      final y = -1.1 + 2.3 * p * p + 0.3 * p;
      final r = 0.06 + 0.035 * _hasard(k, 2);
      final face = math.cos(t * 16 + k * 2.0);
      c.save();
      c.translate(x, y);
      c.rotate(0.3 * (_hasard(k, 3) - 0.5));
      final rect = Rect.fromCenter(center: Offset.zero, width: 2 * r * math.max(0.12, face.abs()), height: 2 * r);
      c.drawOval(rect, Paint()..color = (face > 0 ? const Color(0xFFFFC23D) : const Color(0xFFE59A00)).withValues(alpha: sortie));
      c.drawOval(rect.deflate(r * 0.22), _plume(r * 0.12, const Color(0xFFFFE58A).withValues(alpha: sortie)));
      c.drawOval(rect, _plume(r * 0.16, kEncre.withValues(alpha: sortie)));
      c.restore();
    }
    for (var k = 0; k < 2; k++) {
      final p = seg(t, 0.15 + 0.2 * k, 0.75 + 0.2 * k);
      if (p <= 0 || p >= 1) continue;
      c.save();
      c.translate(k == 0 ? -0.5 + 0.2 * p : 0.55 - 0.2 * p, -1.0 + 2.0 * p);
      c.rotate(math.sin(p * 9) * 0.6);
      c.scale(0.16);
      final cour = Path()
        ..moveTo(-1, 0.4)
        ..lineTo(-1.1, -0.6)
        ..lineTo(-0.5, -0.05)
        ..lineTo(0, -0.8)
        ..lineTo(0.5, -0.05)
        ..lineTo(1.1, -0.6)
        ..lineTo(1, 0.4)
        ..close();
      c.drawPath(cour, Paint()..color = const Color(0xFFFFC23D).withValues(alpha: sortie));
      c.drawPath(cour, _plume(0.14, kEncre.withValues(alpha: sortie)));
      c.drawCircle(const Offset(0, 0.1), 0.16, Paint()..color = kRose.withValues(alpha: sortie));
      c.restore();
    }
    for (var k = 0; k < 12; k++) {
      final p = seg(t, 0.05 * k, 0.05 * k + 0.3);
      etoile(c, Offset(-0.85 + 1.7 * _hasard(k, 4), -0.85 + 1.7 * _hasard(k, 5)), 0.07 * bosse(p, 0, 1), kOr, alpha: bosse(p, 0, 1) * sortie);
    }
  }

  // ── L'espace : une étoile filante traverse, une planète à anneau
  // dérive, le ciel scintille, des traits de vitesse.
  void _espace(Canvas c, double t, double sortie) {
    for (var k = 0; k < 30; k++) {
      final sc = bosse((t * 2 + _hasard(k)) % 1.0, 0, 1);
      etoile(c, Offset(-0.95 + 1.9 * _hasard(k, 1), -0.95 + 1.9 * _hasard(k, 2)), 0.025 + 0.035 * sc, k.isEven ? const Color(0xFFFFE58A) : const Color(0xFFB4A7FF), alpha: (0.3 + 0.7 * sc) * sortie * seg(t, 0, 0.1));
    }
    // La planète.
    final pl = Offset(-0.55 + 0.25 * t, 0.45 - 0.15 * t);
    c.save();
    c.translate(pl.dx, pl.dy);
    c.rotate(-0.35);
    final a = sortie * seg(t, 0.05, 0.25);
    c.drawArc(Rect.fromCenter(center: Offset.zero, width: 0.5, height: 0.14), math.pi, math.pi, false, _plume(0.035, const Color(0xFFFFC23D).withValues(alpha: a)));
    c.drawCircle(Offset.zero, 0.16, Paint()..shader = ui.Gradient.linear(const Offset(-0.16, -0.16), const Offset(0.16, 0.16), [const Color(0xFFB57CFF).withValues(alpha: a), const Color(0xFF5E5CE6).withValues(alpha: a)]));
    c.drawCircle(Offset.zero, 0.16, _plume(0.02, kEncre.withValues(alpha: a)));
    c.drawArc(Rect.fromCenter(center: Offset.zero, width: 0.5, height: 0.14), 0, math.pi, false, _plume(0.035, const Color(0xFFFFC23D).withValues(alpha: a)));
    c.restore();
    // Deux étoiles filantes.
    for (var k = 0; k < 2; k++) {
      final p = Curves.easeInOut.transform(seg(t, 0.1 + 0.3 * k, 0.5 + 0.3 * k));
      if (p <= 0 || p >= 1) continue;
      final debut = Offset(1.1, -0.9 + 0.5 * k), fin = Offset(-1.1, 0.2 + 0.4 * k);
      final tete = Offset.lerp(debut, fin, p)!;
      final queue = Offset.lerp(debut, fin, math.max(0, p - 0.25))!;
      c.drawLine(queue, tete, Paint()
        ..strokeWidth = 0.035
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(queue, tete, [const Color(0x00FFC23D), const Color(0xFFFFE58A)]));
      etoile(c, tete, 0.07, const Color(0xFFFFE58A), angle: p * 6);
    }
    // Les traits de vitesse, vers le haut (la fusée vient de partir).
    final v = bosse(t, 0.0, 0.4);
    for (var k = 0; k < 7; k++) {
      final x = -0.5 + k / 6;
      c.drawLine(Offset(x, 0.2 + 0.2 * _hasard(k)), Offset(x, 0.7 + 0.2 * _hasard(k)), _plume(0.015, const Color(0xFF8E7BFF).withValues(alpha: 0.6 * v)));
    }
  }

  // ── Supernova : trois ondes de choc, des rayons qui tournent, un ciel
  // d'étoiles qui s'allume.
  void _nova(Canvas c, double t, double sortie) {
    final flash = bosse(t, 0, 0.12);
    c.drawCircle(Offset.zero, 0.6, Paint()..shader = ui.Gradient.radial(Offset.zero, 0.6, [Colors.white.withValues(alpha: 0.9 * flash), const Color(0xFF8E7BFF).withValues(alpha: 0.4 * flash), const Color(0x008E7BFF)], const [0, 0.4, 1]));
    for (var k = 0; k < 3; k++) {
      final p = seg(t, k * 0.14, 0.55 + k * 0.14);
      if (p <= 0 || p >= 1) continue;
      final r = 0.25 + 0.8 * Curves.easeOutCubic.transform(p);
      c.drawCircle(Offset.zero, r, _plume(0.06 * (1 - p), Color.lerp(Colors.white, const Color(0xFF8E7BFF), k / 2)!.withValues(alpha: (1 - p) * sortie)));
    }
    final rayons = bosse(t, 0.05, 0.7);
    for (var k = 0; k < 16; k++) {
      final a = k * math.pi / 8 + t * 1.5;
      final r0 = 0.3, r1 = 0.3 + (0.35 + 0.25 * _hasard(k)) * rayons;
      c.drawLine(Offset(math.cos(a), math.sin(a)) * r0, Offset(math.cos(a), math.sin(a)) * r1, _plume(0.022, const Color(0xFFB4A7FF).withValues(alpha: 0.9 * rayons * sortie)));
    }
    for (var k = 0; k < 20; k++) {
      final p = seg(t, 0.15 + 0.02 * k, 0.6 + 0.02 * k);
      etoile(c, Offset(-0.95 + 1.9 * _hasard(k, 6), -0.95 + 1.9 * _hasard(k, 7)), 0.05 * bosse(p, 0, 1), k.isEven ? const Color(0xFFFFE58A) : const Color(0xFFB4A7FF), alpha: bosse(p, 0, 1) * sortie);
    }
  }

  // ── Une vague traverse la zone de gauche à droite, des embruns
  // jaillissent de sa crête, des bulles remontent.
  void _vague(Canvas c, double t, double sortie) {
    final avance = Curves.easeInOut.transform(seg(t, 0.0, 0.75));
    final front = -1.4 + 2.8 * avance;
    double crete(double x) {
      final d = x - front;
      final h = math.exp(-d * d * 5) * 0.75;
      return 1.0 - 0.25 - h + 0.04 * math.sin(x * 9 + t * 12);
    }

    final eau = Path()..moveTo(-1, 1);
    for (var k = 0; k <= 60; k++) {
      final x = -1 + 2 * k / 60;
      eau.lineTo(x, crete(x));
    }
    eau
      ..lineTo(1, 1)
      ..close();
    final a = sortie;
    c.drawPath(eau, Paint()..shader = ui.Gradient.linear(const Offset(0, 0.2), const Offset(0, 1), [const Color(0xFF39E6C4).withValues(alpha: a), const Color(0xFF0A5BD8).withValues(alpha: a)]));
    final ligne = Path()..moveTo(-1, crete(-1));
    for (var k = 1; k <= 60; k++) {
      final x = -1 + 2 * k / 60;
      ligne.lineTo(x, crete(x));
    }
    c.drawPath(ligne, _plume(0.025, kEncre.withValues(alpha: a)));
    // L'écume sur la crête.
    for (var k = 0; k < 10; k++) {
      final x = front - 0.2 + 0.4 * k / 9;
      if (x < -1 || x > 1) continue;
      c.drawCircle(Offset(x, crete(x) - 0.01), 0.03, Paint()..color = Colors.white.withValues(alpha: a));
    }
    // Les embruns.
    for (var k = 0; k < 24; k++) {
      final depart = 0.1 + 0.6 * _hasard(k);
      final p = seg(t, depart, depart + 0.35);
      if (p <= 0 || p >= 1) continue;
      final x0 = -1.4 + 2.8 * Curves.easeInOut.transform(seg(depart, 0.0, 0.75));
      final pos = Offset(x0 + 0.3 * p * (_hasard(k, 1) - 0.3), crete(x0) - 0.7 * p + 0.9 * p * p);
      gouttelette(c, pos, 0.05 + 0.03 * _hasard(k, 2), const Color(0xFFBFF6FF), angle: -0.5 + _hasard(k, 3), alpha: (1 - p) * a);
    }
    for (var k = 0; k < 12; k++) {
      final p = (t * 1.5 + _hasard(k)) % 1.0;
      final pos = Offset(-0.9 + 1.8 * _hasard(k, 4) + 0.03 * math.sin(p * 10), 1.0 - 0.3 * p);
      if (pos.dy < crete(pos.dx)) continue;
      c.drawCircle(pos, 0.02 + 0.015 * _hasard(k, 5), _plume(0.008, Colors.white.withValues(alpha: 0.8 * a)));
    }
  }

  // ── Des éclats de cristal qui jaillissent en tournant, des faisceaux
  // de lumière, des reflets.
  void _cristaux(Canvas c, double t, double sortie) {
    final faisceaux = bosse(t, 0.0, 0.8);
    for (var k = 0; k < 6; k++) {
      final a = k * math.pi / 3 + t * 0.8;
      final p = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.08) * 1.2, math.sin(a - 0.08) * 1.2)
        ..lineTo(math.cos(a + 0.08) * 1.2, math.sin(a + 0.08) * 1.2)
        ..close();
      c.drawPath(p, Paint()..shader = ui.Gradient.radial(Offset.zero, 1.2, [const Color(0xFF9FE8FF).withValues(alpha: 0.45 * faisceaux * sortie), const Color(0x009FE8FF)]));
    }
    for (var k = 0; k < 18; k++) {
      final a = k * 2 * math.pi / 18 + _hasard(k) * 0.3;
      final p = Curves.easeOutCubic.transform(seg(t, 0.02 * (k % 4), 0.7));
      final pos = Offset(math.cos(a), math.sin(a)) * (0.2 + 0.7 * p * (0.7 + 0.3 * _hasard(k, 1))) + Offset(0, 0.2 * p * p);
      c.save();
      c.translate(pos.dx, pos.dy);
      c.rotate(a + t * 8 * (_hasard(k, 2) - 0.5));
      final s = 0.06 + 0.05 * _hasard(k, 3);
      final eclat = Path()
        ..moveTo(0, -s * 1.4)
        ..lineTo(s * 0.7, 0)
        ..lineTo(0, s * 1.1)
        ..lineTo(-s * 0.7, 0)
        ..close();
      c.drawPath(eclat, Paint()..color = [const Color(0xFFE8FBFF), const Color(0xFF9FE8FF), const Color(0xFF6CC8FF)][k % 3].withValues(alpha: sortie));
      c.drawLine(Offset(0, -s * 1.4), Offset(0, s * 1.1), _plume(s * 0.12, Colors.white.withValues(alpha: 0.8 * sortie)));
      c.drawPath(eclat, _plume(s * 0.18, kEncre.withValues(alpha: sortie)));
      c.restore();
    }
    for (var k = 0; k < 10; k++) {
      final p = seg(t, 0.2 + 0.05 * k, 0.45 + 0.05 * k);
      etoile(c, Offset(-0.8 + 1.6 * _hasard(k, 8), -0.8 + 1.6 * _hasard(k, 9)), 0.07 * bosse(p, 0, 1), const Color(0xFF9FE8FF), alpha: bosse(p, 0, 1) * sortie);
    }
  }

  @override
  bool shouldRepaint(_PeintreScene o) => o.genre != genre || o.centre != centre || o.R != R;
}
