// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES ILLUSTRATIONS DE L'ACCUEIL — une par idée, toutes dessinées en code
// dans le même langage que la marque : le bleu de Droplet, les gris du
// système, et LA GOUTTE comme personnage. Dans l'ouverture, elle tombe
// dans la bulle ; ici, c'est elle qui voyage de téléphone en téléphone,
// elle qui se chiffre, elle qui dit « je vais bien ».
//
// ── Les règles tenues ─────────────────────────────────────────────────
//
// • UNE SEULE IDÉE PAR DESSIN, lisible en une seconde, sans texte (rien à
//   traduire, rien à lire deux fois).
// • DES BOUCLES LENTES (3 à 4 s) qui se TERMINENT par un temps de repos :
//   l'œil comprend le geste, puis regarde le texte.
// • AUCUN MOUVEMENT HORS DE L'ÉCRAN VISIBLE. Chaque illustration ne
//   s'anime que si sa page est affichée (`actif`) : une page voisine,
//   à moitié visible pendant un glissement, reste immobile.
// • « RÉDUIRE LES ANIMATIONS » : chaque dessin s'arrête sur son image la
//   plus parlante (`_imageFixe`), au lieu de disparaître.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';
import '../../shared/widgets/marque_droplet.dart';
import 'ouverture_droplet.dart';

/// Une illustration animée en boucle : le moteur commun.
abstract class _Boucle extends StatefulWidget {
  const _Boucle({super.key, required this.actif});

  /// Vrai si la page est affichée : sinon, l'illustration ne bouge pas.
  final bool actif;

  Duration get periode;

  /// L'image montrée quand les animations sont réduites (0 → 1).
  double get imageFixe;

  CustomPainter peintre(BuildContext context, double t);

  @override
  State<_Boucle> createState() => _BoucleState();
}

class _BoucleState extends State<_Boucle> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.periode);
  bool _reduit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _regler();
  }

  @override
  void didUpdateWidget(covariant _Boucle old) {
    super.didUpdateWidget(old);
    if (old.actif != widget.actif) _regler();
  }

  void _regler() {
    if (_reduit) {
      _c.stop();
      _c.value = widget.imageFixe;
    } else if (widget.actif) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
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
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: widget.peintre(context, _c.value)),
      ),
    );
  }
}

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Un rond dans l'eau : un cercle qui s'élargit en s'effaçant.
void _rond(Canvas canvas, Offset c, double r0, double r1, double p, Color couleur, {double epaisseur = 2, double alpha = 0.5}) {
  if (p <= 0 || p >= 1) return;
  final r = r0 + (r1 - r0) * Curves.easeOutCubic.transform(p);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur * (1 - 0.5 * p)
      ..color = couleur.withValues(alpha: couleur.a * alpha * math.pow(1 - p, 1.4).toDouble()),
  );
}

/// La goutte de la marque, seule, centrée sur [c], haute de [h].
void _goutte(Canvas canvas, Offset c, double h, Color couleur, {double etirement = 0}) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(h / 0.565 * (1 - etirement * 0.4), h / 0.565 * (1 + etirement));
  // La goutte occupe y ∈ [-0.273, 0.292] dans le repère de la marque :
  // on la recentre sur son milieu.
  canvas.translate(0, -0.0095);
  canvas.drawPath(GeometrieMarque.goutte, Paint()..color = couleur..isAntiAlias = true);
  canvas.restore();
}

// ── 1. LA MARQUE ─────────────────────────────────────────────────────

/// La marque de Droplet, posée par l'ouverture, avec de lents ronds dans
/// l'eau autour d'elle — la même onde que celle de l'ouverture, au repos.
class HeroMarque extends StatelessWidget {
  const HeroMarque({super.key, required this.actif, this.hauteur = 100});

  final bool actif;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: OuvertureDroplet.active,
            // Les ronds n'apparaissent qu'une fois la marque posée.
            builder: (context, ouverture, _) => _Ronds(actif: actif && !ouverture, hauteur: hauteur),
          ),
        ),
        CibleOuverture(hauteur: hauteur, couleur: OuroColors.accent),
      ],
    );
  }
}

class _Ronds extends _Boucle {
  const _Ronds({required super.actif, required this.hauteur});
  final double hauteur;

  @override
  Duration get periode => const Duration(milliseconds: 3200);

  @override
  double get imageFixe => 0;

  @override
  CustomPainter peintre(BuildContext context, double t) => _PeintreRonds(t, hauteur, OuroColors.accent);
}

class _PeintreRonds extends CustomPainter {
  _PeintreRonds(this.t, this.h, this.couleur);
  final double t;
  final double h;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero) + GeometrieMarque.centreBulle * h;
    final r0 = GeometrieMarque.rayonExterieurBulle * h + 4;
    final r1 = math.min(size.width, size.height) / 2;
    // Deux ronds par cycle, décalés : jamais plus de deux à l'écran.
    _rond(canvas, c, r0, r1, _seg(t, 0.0, 0.62), couleur, epaisseur: 1.6, alpha: 0.42);
    _rond(canvas, c, r0, r1, _seg(t, 0.28, 0.9), couleur, epaisseur: 1.6, alpha: 0.32);
  }

  @override
  bool shouldRepaint(_PeintreRonds o) => o.t != t || o.couleur != couleur;
}

// ── 2. DE TÉLÉPHONE EN TÉLÉPHONE ─────────────────────────────────────

/// Trois téléphones ; la goutte (le message) part du premier, saute au
/// deuxième, puis au troisième, où elle arrive.
class IllustrationRelais extends _Boucle {
  const IllustrationRelais({super.key, required super.actif});

  @override
  Duration get periode => const Duration(milliseconds: 3600);

  @override
  double get imageFixe => 0.66;

  @override
  CustomPainter peintre(BuildContext context, double t) => _PeintreRelais(
        t,
        accent: OuroColors.accent,
        trait: OuroColors.tertiaryLabel,
        coque: OuroColors.secondaryLabel,
        ecran: OuroColors.secondarySystemBackground,
        succes: OuroColors.systemGreen,
      );
}

class _PeintreRelais extends CustomPainter {
  _PeintreRelais(this.t, {required this.accent, required this.trait, required this.coque, required this.ecran, required this.succes});
  final double t;
  final Color accent, trait, coque, ecran, succes;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tel = Size(w * 0.15, w * 0.27);
    final pos = [Offset(w * 0.16, h * 0.64), Offset(w * 0.5, h * 0.38), Offset(w * 0.84, h * 0.64)];

    // Les sauts, en pointillés : le chemin que prendra la goutte, d'un
    // écran à l'autre, en passant AU-DESSUS des téléphones.
    final points = Paint()..color = trait.withValues(alpha: trait.a * 0.7);
    for (final (a, b) in [(pos[0], pos[1]), (pos[1], pos[2])]) {
      final m = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - h * 0.3);
      for (var k = 1; k < 26; k++) {
        final p = k / 26;
        final u = 1 - p;
        final q = a * (u * u) + m * (2 * u * p) + b * (p * p);
        // Pas de points sur les téléphones eux-mêmes.
        final dedans = [a, b].any((c) => (q.dx - c.dx).abs() < tel.width / 2 + 3 && (q.dy - c.dy).abs() < tel.height / 2 + 3);
        if (!dedans) canvas.drawCircle(q, 1.4, points);
      }
    }

    // Les téléphones. Celui qui reçoit la goutte s'éclaire un instant.
    final arrivees = [0.0, 0.40, 0.72];
    for (var i = 0; i < 3; i++) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: pos[i], width: tel.width, height: tel.height), Radius.circular(tel.width * 0.22));
      final eclat = i == 0 ? 0.0 : (_seg(t, arrivees[i], arrivees[i] + 0.06) * (1 - _seg(t, arrivees[i] + 0.12, arrivees[i] + 0.3)));
      canvas.drawRRect(r, Paint()..color = Color.lerp(ecran, accent.withValues(alpha: 0.18), eclat)!);
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = coque.withValues(alpha: coque.a * 0.55),
      );
      // L'encoche du haut.
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos[i] - Offset(0, tel.height * 0.38), width: tel.width * 0.32, height: 3.5), const Radius.circular(2)),
        Paint()..color = coque.withValues(alpha: coque.a * 0.45),
      );
      // Un rond dans l'eau à chaque arrivée.
      if (i > 0) _rond(canvas, pos[i], tel.width * 0.4, tel.width * 1.15, _seg(t, arrivees[i], arrivees[i] + 0.3), accent, alpha: 0.6);
    }

    // Le dernier téléphone affiche une coche : le message est arrivé.
    final coche = Curves.easeOutBack.transform(_seg(t, 0.76, 0.86)) * (1 - _seg(t, 0.94, 1.0));
    if (coche > 0) {
      final c = pos[2] + Offset(0, tel.height * 0.06);
      canvas.drawCircle(c, 11 * coche, Paint()..color = succes);
      final p = Path()
        ..moveTo(c.dx - 4.5 * coche, c.dy + 0.2 * coche)
        ..lineTo(c.dx - 1.2 * coche, c.dy + 3.4 * coche)
        ..lineTo(c.dx + 4.8 * coche, c.dy - 3.2 * coche);
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      );
    }

    // La goutte : posée sur le premier écran, elle saute deux fois, en
    // arc, comme lancée d'un téléphone à l'autre.
    Offset saut(Offset a, Offset b, double p) {
      final m = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - h * 0.3);
      final u = 1 - p;
      return a * (u * u) + m * (2 * u * p) + b * (p * p);
    }

    final hg = tel.width * 0.42;
    Offset? ou;
    var etirement = 0.0;
    var alpha = 1.0;
    if (t < 0.12) {
      ou = pos[0];
      alpha = _seg(t, 0.02, 0.1);
    } else if (t < 0.40) {
      final p = Curves.easeInOutCubic.transform(_seg(t, 0.12, 0.40));
      ou = saut(pos[0], pos[1], p);
      etirement = 0.18 * math.sin(math.pi * p);
    } else if (t < 0.44) {
      ou = pos[1];
    } else if (t < 0.72) {
      final p = Curves.easeInOutCubic.transform(_seg(t, 0.44, 0.72));
      ou = saut(pos[1], pos[2], p);
      etirement = 0.18 * math.sin(math.pi * p);
    } else if (t < 0.76) {
      ou = pos[2];
      alpha = 1 - _seg(t, 0.72, 0.76);
    }
    if (ou != null && alpha > 0) {
      _goutte(canvas, ou, hg, accent.withValues(alpha: accent.a * alpha), etirement: etirement);
    }
  }

  @override
  bool shouldRepaint(_PeintreRelais o) => o.t != t || o.accent != accent || o.ecran != ecran;
}

// ── 3. RIEN QUE VOUS DEUX ────────────────────────────────────────────

/// Une bulle de message ; un cadenas se ferme, et le texte devient
/// illisible — sauf pour les deux personnes de la conversation, que
/// représentent les deux pastilles qui restent nettes.
class IllustrationChiffrement extends _Boucle {
  const IllustrationChiffrement({super.key, required super.actif});

  @override
  Duration get periode => const Duration(milliseconds: 4000);

  @override
  double get imageFixe => 0.6;

  @override
  CustomPainter peintre(BuildContext context, double t) => _PeintreChiffrement(
        t,
        accent: OuroColors.accent,
        fond: OuroColors.systemBackground,
        ombre: OuroColors.label,
      );
}

class _PeintreChiffrement extends CustomPainter {
  _PeintreChiffrement(this.t, {required this.accent, required this.fond, required this.ombre});
  final double t;
  final Color accent, fond, ombre;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bulle = Rect.fromCenter(center: Offset(w * 0.47, h * 0.46), width: w * 0.66, height: h * 0.46);
    final rr = RRect.fromRectAndRadius(bulle, Radius.circular(bulle.height * 0.3));

    // La bulle, avec sa queue en bas à gauche — celle du logo.
    final chemin = Path()
      ..addRRect(rr)
      ..moveTo(bulle.left + bulle.width * 0.12, bulle.bottom - 6)
      ..lineTo(bulle.left + bulle.width * 0.02, bulle.bottom + bulle.height * 0.2)
      ..lineTo(bulle.left + bulle.width * 0.3, bulle.bottom - 4)
      ..close();
    canvas.drawShadow(chemin, ombre.withValues(alpha: 0.35), 10, false);
    canvas.drawPath(chemin, Paint()..color = accent);

    // Les lignes de texte, qui se changent en points (le chiffré) : ligne
    // après ligne, puis reviennent.
    final chiffre = [
      Curves.easeInOut.transform(_seg(t, 0.36, 0.50)),
      Curves.easeInOut.transform(_seg(t, 0.40, 0.54)),
      Curves.easeInOut.transform(_seg(t, 0.44, 0.58)),
    ].map((x) => x * (1 - Curves.easeInOut.transform(_seg(t, 0.86, 0.98)))).toList();
    final longueurs = [0.72, 0.86, 0.5];
    final blanc = Colors.white.withValues(alpha: 0.95);
    for (var i = 0; i < 3; i++) {
      final y = bulle.top + bulle.height * (0.3 + i * 0.2);
      final x0 = bulle.left + bulle.width * 0.12;
      final lg = bulle.width * 0.76 * longueurs[i];
      final c = chiffre[i];
      if (c < 1) {
        // La ligne, qui se rétracte en points.
        final p = Paint()
          ..color = blanc.withValues(alpha: 0.95 * (1 - c))
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x0, y), Offset(x0 + lg * (1 - 0.3 * c), y), p);
      }
      if (c > 0) {
        final n = (lg / 13).floor();
        for (var k = 0; k < n; k++) {
          final apparition = _seg(c, k / n * 0.6, k / n * 0.6 + 0.4);
          canvas.drawCircle(Offset(x0 + 3.5 + k * 13, y), 3.5 * apparition, Paint()..color = blanc.withValues(alpha: 0.95 * c));
        }
      }
    }

    // Le cadenas, en pastille, qui se ferme d'un coup sec.
    final centre = Offset(bulle.right - 4, bulle.bottom - 2);
    final rayon = w * 0.11;
    final fermeture = Curves.easeIn.transform(_seg(t, 0.2, 0.32)) * (1 - Curves.easeOut.transform(_seg(t, 0.86, 0.98)));
    final rebond = _seg(t, 0.32, 0.42);
    final echelle = 1 + 0.08 * math.sin(math.pi * rebond) * (1 - rebond);
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(echelle);
    canvas.drawCircle(Offset.zero, rayon, Paint()..color = fond);
    canvas.drawCircle(
      Offset.zero,
      rayon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ombre.withValues(alpha: 0.08),
    );
    final corps = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, rayon * 0.18), width: rayon * 0.92, height: rayon * 0.72), Radius.circular(rayon * 0.16));
    canvas.drawRRect(corps, Paint()..color = accent);
    // L'anse : relevée et décalée quand le cadenas est ouvert.
    final leve = rayon * 0.28 * (1 - fermeture);
    final anse = Path()
      ..moveTo(-rayon * 0.3, -rayon * 0.16 - leve)
      ..lineTo(-rayon * 0.3, -rayon * 0.36 - leve)
      ..arcToPoint(Offset(rayon * 0.3, -rayon * 0.36 - leve), radius: Radius.circular(rayon * 0.3))
      ..lineTo(rayon * 0.3, -rayon * 0.16 - leve * (fermeture < 0.5 ? 1.8 : 1));
    canvas.drawPath(
      anse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rayon * 0.16
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
    canvas.drawCircle(Offset(0, rayon * 0.16), rayon * 0.08, Paint()..color = fond);
    canvas.restore();

    // L'éclair du verrou, au moment où il se ferme.
    _rond(canvas, centre, rayon, rayon * 1.9, _seg(t, 0.32, 0.6), accent, alpha: 0.55);
  }

  @override
  bool shouldRepaint(_PeintreChiffrement o) => o.t != t || o.accent != accent || o.fond != fond;
}

// ── 4. QUAND TOUT S'ARRÊTE ───────────────────────────────────────────

/// Une carte hors ligne ; votre position pulse au centre, et un proche
/// signale qu'il est en sécurité.
class IllustrationSecurite extends _Boucle {
  const IllustrationSecurite({super.key, required super.actif});

  @override
  Duration get periode => const Duration(milliseconds: 3800);

  @override
  double get imageFixe => 0.62;

  @override
  CustomPainter peintre(BuildContext context, double t) => _PeintreSecurite(
        t,
        accent: OuroColors.accent,
        carte: OuroColors.secondarySystemBackground,
        rue: OuroColors.systemBackground,
        trait: OuroColors.tertiaryLabel,
        succes: OuroColors.systemGreen,
        autres: [OuroColors.systemOrange, OuroColors.systemIndigo],
      );
}

class _PeintreSecurite extends CustomPainter {
  _PeintreSecurite(this.t, {required this.accent, required this.carte, required this.rue, required this.trait, required this.succes, required this.autres});
  final double t;
  final Color accent, carte, rue, trait, succes;
  final List<Color> autres;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final zone = Rect.fromCenter(center: Offset(w / 2, h / 2), width: w * 0.86, height: h * 0.8);
    final rr = RRect.fromRectAndRadius(zone, const Radius.circular(26));
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRRect(rr, Paint()..color = carte);

    // Les rues : quelques traits larges, dans la couleur du fond.
    final rues = Paint()
      ..color = rue
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(zone.topLeft + Offset(-10, zone.height * 0.35), zone.topRight + Offset(10, zone.height * 0.18), rues);
    canvas.drawLine(zone.bottomLeft + Offset(-10, -zone.height * 0.22), zone.topRight + Offset(10, zone.height * 0.82), rues);
    canvas.drawLine(zone.topLeft + Offset(zone.width * 0.34, -10), zone.bottomLeft + Offset(zone.width * 0.42, 10), rues..strokeWidth = 8);
    canvas.drawLine(zone.topLeft + Offset(zone.width * 0.72, -10), zone.bottomLeft + Offset(zone.width * 0.8, 10), rues..strokeWidth = 7);
    // Un parc.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(zone.left + zone.width * 0.48, zone.top + zone.height * 0.42, zone.width * 0.2, zone.height * 0.2), const Radius.circular(8)),
      Paint()..color = succes.withValues(alpha: 0.18),
    );
    canvas.restore();

    // Vous, au centre : un point bleu qui émet des ondes.
    final vous = Offset(zone.left + zone.width * 0.4, zone.top + zone.height * 0.6);
    _rond(canvas, vous, 9, zone.width * 0.32, _seg(t, 0.0, 0.7), accent, alpha: 0.5);
    _rond(canvas, vous, 9, zone.width * 0.32, _seg(t, 0.35, 1.0), accent, alpha: 0.4);
    canvas.drawCircle(vous, 12, Paint()..color = Colors.white);
    canvas.drawCircle(vous, 9, Paint()..color = accent);

    // Deux proches.
    final proches = [Offset(zone.left + zone.width * 0.78, zone.top + zone.height * 0.3), Offset(zone.left + zone.width * 0.2, zone.top + zone.height * 0.24)];
    for (var i = 0; i < 2; i++) {
      final p = proches[i];
      canvas.drawCircle(p, 15, Paint()..color = Colors.white);
      canvas.drawCircle(p, 12, Paint()..color = autres[i]);
    }

    // « Je suis en sécurité » : une pastille verte surgit au-dessus du
    // premier proche, et une onde verte part de lui.
    final p = proches[0];
    final apparition = Curves.easeOutBack.transform(_seg(t, 0.42, 0.56)) * (1 - Curves.easeIn.transform(_seg(t, 0.9, 1.0)));
    _rond(canvas, p, 14, zone.width * 0.26, _seg(t, 0.42, 0.85), succes, alpha: 0.6);
    if (apparition > 0) {
      final c = p + Offset(0, -30);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(apparition);
      canvas.drawCircle(Offset.zero, 14, Paint()..color = succes);
      final coche = Path()
        ..moveTo(-5.5, 0.5)
        ..lineTo(-1.5, 4.5)
        ..lineTo(6, -4);
      canvas.drawPath(
        coche,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PeintreSecurite o) => o.t != t || o.accent != accent || o.carte != carte;
}

// ── LA FIN : vous êtes prêt ──────────────────────────────────────────

/// Deux ronds dans l'eau autour de l'avatar, une seule fois : le compte
/// vient de naître.
class OndesArrivee extends StatefulWidget {
  const OndesArrivee({super.key, required this.rayon});

  final double rayon;

  @override
  State<OndesArrivee> createState() => _OndesArriveeState();
}

class _OndesArriveeState extends State<OndesArrivee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
      _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _PeintreOndes(_c.value, widget.rayon, OuroColors.accent)),
      ),
    );
  }
}

class _PeintreOndes extends CustomPainter {
  _PeintreOndes(this.t, this.r, this.couleur);
  final double t, r;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final loin = math.min(size.width, size.height) / 2;
    _rond(canvas, c, r, loin, _seg(t, 0.05, 0.75), couleur, epaisseur: 2, alpha: 0.5);
    _rond(canvas, c, r, loin, _seg(t, 0.3, 1.0), couleur, epaisseur: 2, alpha: 0.35);
  }

  @override
  bool shouldRepaint(_PeintreOndes o) => o.t != t;
}
