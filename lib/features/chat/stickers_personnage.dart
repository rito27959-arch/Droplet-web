// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE PERSONNAGE DES STICKERS — la goutte de Droplet, ARTICULÉE.
//
// ── Ce que la comparaison avec WhatsApp a montré ──────────────────────
//
// Le sticker premium « Tuft » de WhatsApp (un lama à lunettes) est animé
// comme un personnage de dessin animé : 30 calques, des contrôleurs pour
// la tête, les sourcils, les yeux, les pupilles. Il TOURNE LA TÊTE de
// trois quarts, ses sourcils jouent, ses lunettes bougent à part. Le
// dessin est franc : un contour noir épais, des aplats.
//
// La première version de nos stickers bougeait la goutte d'un bloc
// (rebond, inclinaison, écrasement). Elle n'avait pas de JEU.
//
// ── Ce qu'est ce fichier ──────────────────────────────────────────────
//
// • UNE MARIONNETTE (`Pose`) : rotation de la tête (−1 → 1, trois quarts
//   gauche → droite), inclinaison, écrasement-étirement, saut, regard
//   (pupilles indépendantes), sourcils gauche/droit (hauteur) et leur
//   froncement, paupières, clin d'œil, yeux rieurs, taille des yeux,
//   bouche (neuf formes) et son ouverture, deux bras, joues.
// • LA TÊTE QUI TOURNE est simulée comme le font les animateurs 2D : le
//   visage glisse vers le bord, l'œil du côté où l'on tourne se
//   raccourcit et se rapproche du bord, la bouche se resserre — et tout
//   le visage est découpé par la silhouette, donc il « passe derrière ».
// • DES IMAGES CLÉS (`animer`) : chaque sticker est une suite de poses
//   tenues et de transitions amorties — anticipation, action, maintien,
//   retour —, exactement la méthode d'un animateur.
// • LE STYLE : contour bleu nuit épais, aplat bleu Droplet, une ombre
//   nette (cel shading) en bas à droite, un reflet net en haut à gauche.
//   C'est ce qui donne une identité qu'on reconnaît du premier coup
//   d'œil, là où un dégradé brillant fait « emoji 3D » générique.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../shared/widgets/marque_droplet.dart';

// ─────────────────────────────────────────────────────────────
//  LA PALETTE
// ─────────────────────────────────────────────────────────────

const Color kEncre = Color(0xFF0B1E3B);
const Color _bleu = Color(0xFF2F86FF);
const Color _bleuClair = Color(0xFF63B2FF);
const Color _bleuOmbre = Color(0xFF1555CF);
const Color _joue = Color(0xFFFF7EA6);
const Color _langue = Color(0xFFFF5F86);
const Color kOr = Color(0xFFFFC23D);
const Color kVert = Color(0xFF30D158);
const Color kRose = Color(0xFFFF3B6B);

double seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double bosse(double t, double a, double b) => math.sin(math.pi * seg(t, a, b));
double lerpD(double a, double b, double t) => a + (b - a) * t;

// ─────────────────────────────────────────────────────────────
//  LA MARIONNETTE
// ─────────────────────────────────────────────────────────────

enum Bouche { sourire, rire, o, moue, ondulee, bisou, plat, malin, dents }

/// Les angles de repos des bras (bas-gauche, bas-droite).
const double kBrasG = math.pi * 0.66;
const double kBrasD = math.pi * 0.34;

@immutable
class Pose {
  const Pose({
    this.tourne = 0,
    this.incline = 0,
    this.ecrase = 0,
    this.saut = 0,
    this.rx = 0,
    this.ry = 0,
    this.sg = 0,
    this.sd = 0,
    this.fronce = 0,
    this.paupiere = 0,
    this.clin = 0,
    this.heureux = 0,
    this.oeil = 1,
    this.bouche = Bouche.sourire,
    this.ouv = 0,
    this.brasG = kBrasG,
    this.brasD = kBrasD,
    this.bras = 1,
    this.joues = 0.5,
  });

  /// −1 (trois quarts vers la gauche) → 1 (vers la droite).
  final double tourne;

  /// En radians, autour de la base.
  final double incline;

  /// > 0 écrasé, < 0 étiré.
  final double ecrase;

  /// Hauteur au-dessus du sol, en fraction du sticker.
  final double saut;

  /// Le regard, −1 → 1 sur chaque axe.
  final double rx, ry;

  /// Hauteur des sourcils gauche et droit, −1 → 1.
  final double sg, sd;

  /// Froncement : > 0 colère (bouts intérieurs bas), < 0 inquiétude.
  final double fronce;

  /// Paupières (0 ouvertes → 1 fermées) ; [clin] ferme l'œil droit seul.
  final double paupiere, clin;

  /// 1 : yeux rieurs « ^ ^ ».
  final double heureux;

  /// Taille des yeux.
  final double oeil;

  final Bouche bouche;
  final double ouv;

  /// Angles des bras (radians, y vers le bas) et leur présence.
  final double brasG, brasD, bras;

  final double joues;

  Pose c({
    double? tourne,
    double? incline,
    double? ecrase,
    double? saut,
    double? rx,
    double? ry,
    double? sg,
    double? sd,
    double? fronce,
    double? paupiere,
    double? clin,
    double? heureux,
    double? oeil,
    Bouche? bouche,
    double? ouv,
    double? brasG,
    double? brasD,
    double? bras,
    double? joues,
  }) =>
      Pose(
        tourne: tourne ?? this.tourne,
        incline: incline ?? this.incline,
        ecrase: ecrase ?? this.ecrase,
        saut: saut ?? this.saut,
        rx: rx ?? this.rx,
        ry: ry ?? this.ry,
        sg: sg ?? this.sg,
        sd: sd ?? this.sd,
        fronce: fronce ?? this.fronce,
        paupiere: paupiere ?? this.paupiere,
        clin: clin ?? this.clin,
        heureux: heureux ?? this.heureux,
        oeil: oeil ?? this.oeil,
        bouche: bouche ?? this.bouche,
        ouv: ouv ?? this.ouv,
        brasG: brasG ?? this.brasG,
        brasD: brasD ?? this.brasD,
        bras: bras ?? this.bras,
        joues: joues ?? this.joues,
      );

  static Pose lerp(Pose a, Pose b, double t) => Pose(
        tourne: lerpD(a.tourne, b.tourne, t),
        incline: lerpD(a.incline, b.incline, t),
        ecrase: lerpD(a.ecrase, b.ecrase, t),
        saut: lerpD(a.saut, b.saut, t),
        rx: lerpD(a.rx, b.rx, t),
        ry: lerpD(a.ry, b.ry, t),
        sg: lerpD(a.sg, b.sg, t),
        sd: lerpD(a.sd, b.sd, t),
        fronce: lerpD(a.fronce, b.fronce, t),
        paupiere: lerpD(a.paupiere, b.paupiere, t),
        clin: lerpD(a.clin, b.clin, t),
        heureux: lerpD(a.heureux, b.heureux, t),
        oeil: lerpD(a.oeil, b.oeil, t),
        // La bouche change de forme au milieu de la transition, quand
        // elle est la moins ouverte des deux.
        bouche: t < 0.5 ? a.bouche : b.bouche,
        ouv: lerpD(a.ouv, b.ouv, t),
        brasG: lerpD(a.brasG, b.brasG, t),
        brasD: lerpD(a.brasD, b.brasD, t),
        bras: lerpD(a.bras, b.bras, t),
        joues: lerpD(a.joues, b.joues, t),
      );
}

const Pose kRepos = Pose();

/// Une image clé : l'instant (0 → 1 dans la boucle) et la pose. La
/// courbe donnée est celle qui MÈNE à cette pose.
class Cle {
  const Cle(this.t, this.pose, [this.courbe = Curves.easeInOutCubic]);
  final double t;
  final Pose pose;
  final Curve courbe;
}

/// La pose à l'instant [u] (0 → 1) d'une suite d'images clés. La
/// première doit être à 0 et la dernière à 1 (en général la même pose).
Pose animer(double u, List<Cle> cles) {
  for (var i = 0; i < cles.length - 1; i++) {
    final a = cles[i], b = cles[i + 1];
    if (u >= a.t && u <= b.t) {
      final e = b.courbe.transform(b.t == a.t ? 1 : (u - a.t) / (b.t - a.t));
      return Pose.lerp(a.pose, b.pose, e);
    }
  }
  return cles.last.pose;
}

/// Un clignement d'yeux naturel : rapide, de temps en temps.
double clignement(double s, {double periode = 3.3, double decal = 0}) {
  final u = ((s + decal) % periode) / periode;
  return bosse(u, 0.93, 0.985);
}

// ─────────────────────────────────────────────────────────────
//  LE DESSIN DE LA GOUTTE
// ─────────────────────────────────────────────────────────────

/// Le style du corps.
class MatiereGoutte {
  const MatiereGoutte.bleue({this.teinte})
      : irisee = false,
        phase = 0;
  const MatiereGoutte.irisee(this.phase)
      : irisee = true,
        teinte = null;

  final bool irisee;
  final double phase;

  /// Une couleur vers laquelle tirer le bleu (la colère rougit).
  final Color? teinte;
}

/// Dessine la goutte dans la pose [p], la base posée en [base] (unités du
/// sticker), haute de [hauteur]. [tete] dessine un accessoire dans le
/// repère de la marque (chapeau, couronne), [main] un objet tenu.
void dessinerGoutte(
  Canvas c,
  Pose p, {
  MatiereGoutte matiere = const MatiereGoutte.bleue(),
  double hauteur = 0.6,
  Offset base = const Offset(0.5, 0.87),
  bool sombre = false,
  bool yeuxCoeur = false,
  double battement = 1,
  void Function(Canvas c)? tete,
  void Function(Canvas c)? devant,
}) {
  final k = hauteur / 0.565;
  final sx = 1 + p.ecrase * 0.7, sy = 1 - p.ecrase;

  // L'ombre portée, qui rétrécit quand on saute.
  final o = (1 - (p.saut * 3).clamp(0.0, 0.6));
  c.drawOval(
    Rect.fromCenter(center: base + const Offset(0, 0.012), width: hauteur * 0.6 * sx * o, height: hauteur * 0.085 * o),
    Paint()
      ..color = Colors.black.withValues(alpha: (sombre ? 0.34 : 0.13) * o)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, hauteur * 0.02),
  );

  c.save();
  c.translate(base.dx, base.dy - p.saut);
  c.rotate(p.incline);
  c.scale(sx * k, sy * k);
  c.translate(0, -0.291);

  final corps = GeometrieMarque.goutte;

  // ── Les bras du côté caché passent DERRIÈRE le corps quand la tête
  // tourne fort : ici, aucun ne disparaît, on les dessine devant.

  // ── Le corps.
  if (matiere.irisee) {
    final rot = Matrix4.translationValues(0, 0.06, 0)
      ..multiply(Matrix4.rotationZ(matiere.phase * 1.2))
      ..multiply(Matrix4.translationValues(0, -0.06, 0));
    c.drawPath(
      corps,
      Paint()
        ..shader = ui.Gradient.sweep(
          const Offset(0, 0.06),
          const [Color(0xFF7B61FF), Color(0xFF2FB8FF), Color(0xFF39E6C4), Color(0xFFFF6FD8), Color(0xFF7B61FF)],
          const [0.0, 0.25, 0.5, 0.75, 1.0],
          TileMode.clamp,
          0,
          2 * math.pi,
          rot.storage,
        ),
    );
  } else {
    final haut = matiere.teinte == null ? _bleuClair : Color.lerp(_bleuClair, matiere.teinte, 0.7)!;
    final milieu = matiere.teinte == null ? _bleu : Color.lerp(_bleu, matiere.teinte, 0.75)!;
    c.drawPath(corps, Paint()..shader = ui.Gradient.linear(const Offset(0, -0.27), const Offset(0, 0.1), [haut, milieu]));
  }
  // L'ombre nette, en bas à droite : le corps moins lui-même décalé vers
  // la lumière (en haut à gauche).
  final ombre = Path.combine(PathOperation.difference, corps, corps.shift(const Offset(-0.05, -0.045)));
  c.drawPath(
    ombre,
    Paint()..color = (matiere.irisee ? const Color(0xFF1A1050) : (matiere.teinte == null ? _bleuOmbre : Color.lerp(_bleuOmbre, matiere.teinte, 0.6)!)).withValues(alpha: matiere.irisee ? 0.35 : 0.6),
  );
  // Le reflet net, en haut à gauche.
  c.save();
  c.translate(-0.095, -0.03);
  c.rotate(0.35);
  c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 0.045, height: 0.13), const Radius.circular(0.03)), Paint()..color = Colors.white.withValues(alpha: 0.85));
  c.restore();
  c.drawCircle(const Offset(-0.07, -0.125), 0.016, Paint()..color = Colors.white.withValues(alpha: 0.85));

  // ── Le visage, découpé par la silhouette : quand la tête tourne, il
  // « passe derrière » le bord.
  c.save();
  c.clipPath(corps);
  _visage(c, p, yeuxCoeur: yeuxCoeur, battement: battement);
  c.restore();

  // ── Le contour.
  c.drawPath(corps, _plume(0.024));

  tete?.call(c);

  // ── Les bras.
  if (p.bras > 0.01) {
    _bras(c, -1, p.brasG, p.bras, matiere);
    _bras(c, 1, p.brasD, p.bras, matiere);
  }
  devant?.call(c);
  c.restore();
}

Paint _plume(double ep, [Color couleur = kEncre]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = ep
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..color = couleur;

/// Un trait épais et arrondi, cerné.
void _traitCerne(Canvas c, Path p, double ep, Color couleur) {
  c.drawPath(p, _plume(ep + 0.022));
  c.drawPath(p, _plume(ep, couleur));
}

void _bras(Canvas c, double cote, double angle, double presence, MatiereGoutte m) {
  final epaule = Offset(cote * 0.165, 0.15);
  final l = 0.15 * presence;
  final coude = epaule + Offset(math.cos(angle), math.sin(angle)) * l * 0.55;
  final main = coude + Offset(math.cos(angle - cote * 0.3), math.sin(angle - cote * 0.3)) * l * 0.5;
  final chemin = Path()
    ..moveTo(epaule.dx, epaule.dy)
    ..quadraticBezierTo(coude.dx, coude.dy, main.dx, main.dy);
  final couleur = m.irisee ? const Color(0xFF6E8BFF) : (m.teinte == null ? _bleu : Color.lerp(_bleu, m.teinte, 0.7)!);
  _traitCerne(c, chemin, 0.034, couleur);
  c.drawCircle(main, 0.034 * presence + 0.011, Paint()..color = kEncre);
  c.drawCircle(main, 0.034 * presence, Paint()..color = couleur);
}

const double _yYeux = 0.055;
const double _ecartYeux = 0.074;

void _visage(Canvas c, Pose p, {required bool yeuxCoeur, required double battement}) {
  final t = p.tourne.clamp(-1.0, 1.0);
  final fx = 0.085 * t;

  for (final cote in [-1.0, 1.0]) {
    // L'œil du côté où l'on tourne se raccourcit et file vers le bord.
    final raccourci = 1 - 0.45 * math.max(0, cote * t);
    final x = fx + cote * _ecartYeux * (1 - 0.18 * t.abs()) + cote * 0.012 * math.max(0, cote * t);
    final centre = Offset(x, _yYeux - 0.006 * p.ry.abs());
    final ferme = cote > 0 ? math.max(p.paupiere, p.clin) : p.paupiere;

    // Les sourcils.
    final lever = cote < 0 ? p.sg : p.sd;
    final ySourcil = centre.dy - 0.075 * p.oeil - 0.03 * lever;
    final interieur = Offset(centre.dx - cote * 0.03 * raccourci, ySourcil + 0.022 * p.fronce);
    final exterieur = Offset(centre.dx + cote * 0.035 * raccourci, ySourcil - 0.006 * p.fronce);
    c.drawPath(
      Path()
        ..moveTo(interieur.dx, interieur.dy)
        ..quadraticBezierTo((interieur.dx + exterieur.dx) / 2, math.min(interieur.dy, exterieur.dy) - 0.012, exterieur.dx, exterieur.dy),
      _plume(0.017),
    );

    // Les joues.
    if (p.joues > 0) {
      c.drawOval(
        Rect.fromCenter(center: Offset(x + cote * 0.052 * raccourci, 0.118), width: 0.058 * raccourci, height: 0.032),
        Paint()..color = _joue.withValues(alpha: p.joues * 0.75),
      );
    }

    if (yeuxCoeur) {
      _coeurForme(c, centre, 0.09 * battement, Offset(raccourci, 1), kRose, contour: true);
      continue;
    }
    if (p.heureux > 0.5) {
      final a = Path()
        ..moveTo(centre.dx - 0.032 * raccourci, centre.dy + 0.014)
        ..quadraticBezierTo(centre.dx, centre.dy - 0.034, centre.dx + 0.032 * raccourci, centre.dy + 0.014);
      c.drawPath(a, _plume(0.018));
      continue;
    }
    // L'œil : blanc cerné, pupille, éclat, paupière.
    c.save();
    c.translate(centre.dx, centre.dy);
    c.scale(raccourci * p.oeil, p.oeil);
    final blanc = Rect.fromCenter(center: Offset.zero, width: 0.066, height: 0.086);
    c.drawOval(blanc, Paint()..color = Colors.white);
    c.save();
    c.clipPath(Path()..addOval(blanc));
    final pupille = Offset(p.rx * 0.016 + t * 0.008, p.ry * 0.02 + 0.004);
    c.drawCircle(pupille, 0.025, Paint()..color = kEncre);
    c.drawCircle(pupille + const Offset(0.009, -0.009), 0.0085, Paint()..color = Colors.white);
    if (ferme > 0.01) {
      final h = 0.086 * ferme;
      c.drawRect(Rect.fromLTWH(-0.05, -0.043, 0.1, h), Paint()..color = _bleu);
      c.drawLine(Offset(-0.05, -0.043 + h), Offset(0.05, -0.043 + h), _plume(0.011));
    }
    c.restore();
    c.drawOval(blanc, _plume(0.009));
    c.restore();
  }

  // La bouche.
  c.save();
  c.translate(fx * 1.15, 0.138);
  c.scale(1 - 0.32 * t.abs(), 1);
  _bouche(c, p.bouche, p.ouv);
  c.restore();
}

void _bouche(Canvas c, Bouche b, double ouv) {
  switch (b) {
    case Bouche.sourire:
      if (ouv < 0.05) {
        c.drawPath(Path()
          ..moveTo(-0.045, -0.006)
          ..quadraticBezierTo(0, 0.036, 0.045, -0.006), _plume(0.015));
        return;
      }
      _boucheOuverte(c, 0.05, 0.065 * ouv, dentsHaut: false);
    case Bouche.rire:
      _boucheOuverte(c, 0.07, 0.03 + 0.06 * ouv, dentsHaut: true);
    case Bouche.dents:
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 0.008), width: 0.1, height: 0.03 + 0.02 * ouv), const Radius.circular(0.012));
      c.drawRRect(r, Paint()..color = Colors.white);
      c.drawLine(Offset(-0.05, 0.008), Offset(0.05, 0.008), _plume(0.006));
      for (final x in [-0.025, 0.0, 0.025]) {
        c.drawLine(Offset(x, -0.005), Offset(x, 0.021), _plume(0.005));
      }
      c.drawRRect(r, _plume(0.011));
    case Bouche.o:
      final rect = Rect.fromCenter(center: const Offset(0, 0.012), width: 0.03 + 0.025 * ouv, height: 0.03 + 0.055 * ouv);
      c.drawOval(rect, Paint()..color = kEncre);
      c.save();
      c.clipPath(Path()..addOval(rect));
      c.drawOval(Rect.fromCenter(center: Offset(0, rect.bottom), width: rect.width * 0.8, height: rect.height * 0.6), Paint()..color = _langue);
      c.restore();
    case Bouche.moue:
      c.drawPath(Path()
        ..moveTo(-0.04, 0.02)
        ..quadraticBezierTo(0, -0.018 - 0.01 * ouv, 0.04, 0.02), _plume(0.015));
    case Bouche.ondulee:
      final p = Path()..moveTo(-0.045, 0.006);
      for (var k = 1; k <= 8; k++) {
        p.lineTo(-0.045 + k * 0.01125, 0.006 + (k.isOdd ? -1 : 1) * 0.007 * (0.6 + 0.4 * ouv));
      }
      c.drawPath(p, _plume(0.013));
    case Bouche.bisou:
      final p = Path()
        ..moveTo(-0.012, -0.022)
        ..quadraticBezierTo(0.03, -0.02, 0.004, 0.0)
        ..quadraticBezierTo(0.03, 0.02, -0.012, 0.022);
      c.drawPath(p, _plume(0.015));
    case Bouche.plat:
      c.drawLine(const Offset(-0.035, 0.006), const Offset(0.035, 0.004), _plume(0.015));
    case Bouche.malin:
      c.drawPath(Path()
        ..moveTo(-0.04, 0.012)
        ..quadraticBezierTo(0.01, 0.028, 0.045, -0.014), _plume(0.015));
  }
}

void _boucheOuverte(Canvas c, double l, double h, {required bool dentsHaut}) {
  final p = Path()
    ..moveTo(-l, -0.008)
    ..quadraticBezierTo(0, 0.004, l, -0.008)
    ..quadraticBezierTo(l * 0.85, h, 0, h)
    ..quadraticBezierTo(-l * 0.85, h, -l, -0.008)
    ..close();
  c.drawPath(p, Paint()..color = kEncre);
  c.save();
  c.clipPath(p);
  c.drawOval(Rect.fromCenter(center: Offset(0, h * 1.02), width: l * 1.3, height: h * 0.95), Paint()..color = _langue);
  if (dentsHaut) {
    c.drawRect(Rect.fromLTWH(-l, -0.02, l * 2, 0.02 + h * 0.18), Paint()..color = Colors.white);
  }
  c.restore();
  c.drawPath(p, _plume(0.012));
}

// ─────────────────────────────────────────────────────────────
//  LES ACCESSOIRES (unités du sticker, sauf mention)
// ─────────────────────────────────────────────────────────────

void _coeurForme(Canvas c, Offset centre, double taille, Offset echelle, Color couleur, {double alpha = 1, double angle = 0, bool contour = true}) {
  if (taille <= 0 || alpha <= 0) return;
  c.save();
  c.translate(centre.dx, centre.dy);
  c.rotate(angle);
  c.scale(taille * echelle.dx, taille * echelle.dy);
  final p = Path()
    ..moveTo(0, 0.38)
    ..cubicTo(-0.6, 0.0, -0.52, -0.52, 0, -0.22)
    ..cubicTo(0.52, -0.52, 0.6, 0.0, 0, 0.38)
    ..close();
  c.drawPath(p, Paint()..color = couleur.withValues(alpha: alpha));
  c.drawCircle(const Offset(-0.18, -0.18), 0.08, Paint()..color = Colors.white.withValues(alpha: 0.7 * alpha));
  if (contour) c.drawPath(p, _plume(0.09, kEncre.withValues(alpha: alpha)));
  c.restore();
}

void coeur(Canvas c, Offset centre, double taille, {Color couleur = kRose, double alpha = 1, double angle = 0}) =>
    _coeurForme(c, centre, taille, const Offset(1, 1), couleur, alpha: alpha, angle: angle);

void etoile(Canvas c, Offset centre, double r, Color couleur, {double alpha = 1, double angle = 0, bool contour = true}) {
  if (r <= 0 || alpha <= 0) return;
  final p = Path();
  for (var k = 0; k < 8; k++) {
    final a = angle + k * math.pi / 4 - math.pi / 2;
    final rr = k.isEven ? r : r * 0.36;
    final q = centre + Offset(math.cos(a), math.sin(a)) * rr;
    if (k == 0) {
      p.moveTo(q.dx, q.dy);
    } else {
      p.lineTo(q.dx, q.dy);
    }
  }
  p.close();
  c.drawPath(p, Paint()..color = couleur.withValues(alpha: alpha));
  if (contour) c.drawPath(p, _plume(r * 0.16, kEncre.withValues(alpha: alpha)));
}

void gouttelette(Canvas c, Offset centre, double h, Color couleur, {double angle = 0, double alpha = 1, bool contour = true}) {
  if (h <= 0 || alpha <= 0) return;
  c.save();
  c.translate(centre.dx, centre.dy);
  c.rotate(angle);
  c.scale(h / 0.565);
  c.translate(0, -0.0095);
  c.drawPath(GeometrieMarque.goutte, Paint()..color = couleur.withValues(alpha: couleur.a * alpha));
  if (contour) c.drawPath(GeometrieMarque.goutte, _plume(0.05, kEncre.withValues(alpha: alpha)));
  c.restore();
}

void pastilleCoche(Canvas c, Offset centre, double r) {
  if (r <= 0) return;
  c.drawCircle(centre, r + r * 0.14, Paint()..color = kEncre);
  c.drawCircle(centre, r, Paint()..color = kVert);
  final k = r / 0.075;
  c.drawPath(
    Path()
      ..moveTo(centre.dx - 0.032 * k, centre.dy + 0.002 * k)
      ..lineTo(centre.dx - 0.008 * k, centre.dy + 0.026 * k)
      ..lineTo(centre.dx + 0.036 * k, centre.dy - 0.022 * k),
    _plume(0.017 * k, Colors.white),
  );
}

void _traits(Canvas c, Offset centre, double r0, double r1, List<double> angles, Color couleur, double alpha, double ep) {
  if (alpha <= 0) return;
  for (final a in angles) {
    final d = Offset(math.cos(a), math.sin(a));
    c.drawLine(centre + d * r0, centre + d * r1, _plume(ep, couleur.withValues(alpha: alpha)));
  }
}

// ─────────────────────────────────────────────────────────────
//  LES STICKERS
// ─────────────────────────────────────────────────────────────

/// Dessine le sticker [cle] (« lot/id ») à l'instant [s] (secondes) sur
/// une toile de 1 × 1. [boing] (0 → 1) est le rebond d'un toucher.
void dessinerSticker(Canvas c, String cle, double s, {required bool sombre, double boing = 0}) {
  final rebond = boing <= 0 || boing >= 1 ? 0.0 : math.exp(-5.5 * boing) * math.cos(boing * math.pi * 5);
  Pose touche(Pose p) => rebond == 0 ? p : p.c(ecrase: p.ecrase + 0.2 * rebond, oeil: p.oeil * (1 + 0.15 * rebond.abs()));
  final encre = sombre ? Colors.white : kEncre;

  switch (cle) {
    // ═════════════ LOT « GOUTTE » ═════════════
    case 'goutte/salut':
      final u = (s % 2.8) / 2.8;
      var p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire)),
        // Anticipation : on se tasse, le bras descend.
        Cle(0.1, Pose(ecrase: 0.08, brasD: math.pi * 0.45, paupiere: 0.2)),
        // L'action : la tête se tourne vers la main levée, sourcils hauts.
        Cle(0.2, Pose(ecrase: -0.05, tourne: 0.35, rx: 0.3, sg: 0.8, sd: 1, brasD: -math.pi * 0.3, bouche: Bouche.rire, ouv: 0.55, joues: 0.8), Curves.easeOutBack),
        Cle(0.72, Pose(tourne: 0.35, rx: 0.3, sg: 0.8, sd: 1, brasD: -math.pi * 0.3, bouche: Bouche.rire, ouv: 0.55, joues: 0.8)),
        // Le clin d'œil complice, à la fin.
        Cle(0.8, Pose(tourne: -0.2, rx: -0.2, sd: 0.6, sg: -0.2, clin: 1, bouche: Bouche.malin, joues: 0.8, brasD: math.pi * 0.2)),
        Cle(0.9, Pose(tourne: -0.2, rx: -0.2, sd: 0.6, sg: -0.2, clin: 1, bouche: Bouche.malin, joues: 0.8, brasD: math.pi * 0.2)),
        Cle(1.0, Pose(bouche: Bouche.sourire)),
      ]);
      // Le salut : trois balancements de la main pendant le maintien.
      final balance = 0.5 * math.sin((u - 0.2) / 0.52 * 3 * 2 * math.pi) * bosse(u, 0.2, 0.72);
      p = p.c(brasD: p.brasD + balance, paupiere: math.max(p.paupiere, clignement(s)));
      dessinerGoutte(c, touche(p), sombre: sombre);
      _traits(c, const Offset(0.83, 0.33), 0.06, 0.1, [-1.2, -0.85, -0.5], const Color(0xFF2F86FF), bosse(u, 0.22, 0.7), 0.014);

    case 'goutte/rire':
      final u = (s % 2.0) / 2.0;
      var p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire, ouv: 0.2)),
        Cle(0.12, Pose(ecrase: 0.12, paupiere: 0.4, bouche: Bouche.sourire, ouv: 0.3, sg: -0.3, sd: -0.3)),
        // L'éclat de rire : tête en arrière, tournée, yeux rieurs.
        Cle(0.24, Pose(ecrase: -0.06, incline: -0.22, tourne: -0.3, heureux: 1, bouche: Bouche.rire, ouv: 1, sg: 1, sd: 1, joues: 1, brasG: math.pi * 0.95, brasD: math.pi * 0.05), Curves.easeOutBack),
        Cle(0.78, Pose(incline: -0.22, tourne: -0.3, heureux: 1, bouche: Bouche.rire, ouv: 1, sg: 1, sd: 1, joues: 1, brasG: math.pi * 0.95, brasD: math.pi * 0.05)),
        Cle(1.0, Pose(bouche: Bouche.sourire, ouv: 0.2)),
      ]);
      // Les secousses du rire.
      final hoquet = bosse(u, 0.24, 0.78) * math.sin(u * 2 * math.pi * 9).abs();
      p = p.c(saut: 0.035 * hoquet, ecrase: p.ecrase + 0.05 * hoquet, ouv: p.ouv - 0.25 * hoquet);
      dessinerGoutte(c, touche(p), sombre: sombre);
      // Les larmes de joie.
      final f = bosse(u, 0.25, 0.8);
      for (final cote in [-1.0, 1.0]) {
        for (var k = 0; k < 2; k++) {
          final q = ((u * 3 + k * 0.5) % 1.0);
          gouttelette(c, Offset(0.5 + cote * (0.13 + 0.2 * q), 0.42 - 0.12 * q + 0.3 * q * q), 0.05 * (1 - q * 0.4), const Color(0xFFBFE6FF), angle: cote * (1 + q), alpha: f * (1 - q));
        }
      }

    case 'goutte/coeur':
      final u = (s % 2.6) / 2.6;
      // Il se balance, rêveur, d'un côté à l'autre.
      final balance = math.sin(u * 2 * math.pi);
      final p = Pose(tourne: 0.35 * balance, incline: 0.1 * balance, joues: 1, bouche: Bouche.sourire, ouv: 0.25, sg: 0.6, sd: 0.6);
      final bat = 1 + 0.2 * bosse(u * 2 % 1, 0, 0.14) + 0.12 * bosse(u * 2 % 1, 0.18, 0.3);
      dessinerGoutte(c, touche(p), sombre: sombre, yeuxCoeur: true, battement: bat);
      for (var k = 0; k < 4; k++) {
        final q = ((u + k / 4) % 1.0);
        coeur(c, Offset(0.5 + (k - 1.5) * 0.18 + 0.04 * math.sin(q * 9 + k), 0.4 - 0.34 * q), 0.07 * (0.5 + 0.5 * q), alpha: bosse(q, 0, 1), angle: 0.25 * math.sin(q * 6 + k));
      }

    case 'goutte/merci':
      final u = (s % 2.8) / 2.8;
      final p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire)),
        Cle(0.12, Pose(ecrase: -0.04, sg: 0.6, sd: 0.6, brasG: math.pi * 0.3, brasD: math.pi * 0.7, bouche: Bouche.sourire, ouv: 0.2)),
        // La révérence, mains jointes, yeux fermés.
        Cle(0.32, Pose(incline: 0.45, ecrase: 0.06, paupiere: 1, heureux: 1, brasG: math.pi * 0.25, brasD: math.pi * 0.75, joues: 1, bouche: Bouche.sourire, sg: 0.3, sd: 0.3)),
        Cle(0.62, Pose(incline: 0.45, ecrase: 0.06, paupiere: 1, heureux: 1, brasG: math.pi * 0.25, brasD: math.pi * 0.75, joues: 1, bouche: Bouche.sourire, sg: 0.3, sd: 0.3)),
        Cle(0.82, Pose(tourne: 0.2, bouche: Bouche.rire, ouv: 0.4, sg: 0.5, sd: 0.5, joues: 0.8), Curves.easeOutBack),
        Cle(1.0, Pose(bouche: Bouche.sourire)),
      ]);
      dessinerGoutte(c, touche(p.c(paupiere: math.max(p.paupiere, clignement(s)))), sombre: sombre);
      final e = bosse(u, 0.3, 0.66);
      etoile(c, const Offset(0.78, 0.3), 0.055 * e, kOr, alpha: e, angle: u * 3);
      etoile(c, const Offset(0.2, 0.36), 0.04 * e, kOr, alpha: e, angle: -u * 3);
      etoile(c, const Offset(0.86, 0.48), 0.03 * e, kOr, alpha: e, angle: u * 2);

    case 'goutte/ok':
      final u = (s % 2.6) / 2.6;
      final p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire)),
        Cle(0.15, Pose(tourne: -0.45, rx: -0.6, incline: -0.06, ecrase: 0.05, brasD: math.pi * 0.5)),
        // L'air sûr de soi : trois quarts, un sourcil levé, clin d'œil,
        // sourire en coin, la main qui brandit la coche.
        Cle(0.3, Pose(tourne: -0.45, rx: -0.8, incline: -0.08, sd: 1, sg: -0.4, clin: 1, bouche: Bouche.malin, joues: 0.7, brasD: -math.pi * 0.2), Curves.easeOutBack),
        Cle(0.8, Pose(tourne: -0.45, rx: -0.8, incline: -0.08, sd: 1, sg: -0.4, clin: 1, bouche: Bouche.malin, joues: 0.7, brasD: -math.pi * 0.2)),
        Cle(1.0, Pose(bouche: Bouche.sourire)),
      ]);
      dessinerGoutte(c, touche(p), sombre: sombre);
      final pop = Curves.elasticOut.transform(seg(u, 0.25, 0.6)) * (1 - seg(u, 0.85, 0.95));
      pastilleCoche(c, const Offset(0.8, 0.32), 0.075 * pop);

    case 'goutte/triste':
      final u = (s % 3.2) / 3.2;
      final soupir = math.sin(u * 2 * math.pi);
      final p = Pose(tourne: -0.18, ry: 0.7, rx: -0.2, fronce: -1, sg: 0.5, sd: 0.5, bouche: Bouche.ondulee, ouv: 0.5 + 0.5 * soupir, ecrase: 0.07 + 0.03 * soupir, incline: -0.05, joues: 0.3, oeil: 1.1, paupiere: 0.25, brasG: math.pi * 0.62, brasD: math.pi * 0.38);
      final flaque = 0.1 + 0.06 * seg(u, 0.6, 0.72);
      c.drawOval(Rect.fromCenter(center: const Offset(0.6, 0.89), width: flaque * 1.5, height: flaque * 0.28), Paint()..color = const Color(0xFF8FD0FF));
      c.drawOval(Rect.fromCenter(center: const Offset(0.6, 0.89), width: flaque * 1.5, height: flaque * 0.28), _plume(0.006));
      dessinerGoutte(c, touche(p), sombre: sombre);
      final l = seg(u, 0.1, 0.62);
      gouttelette(c, Offset(0.58, 0.5 + 0.33 * Curves.easeIn.transform(l)), 0.035 + 0.02 * seg(l, 0, 0.3), const Color(0xFFCDEBFF), alpha: 1 - seg(u, 0.6, 0.64));

    case 'goutte/colere':
      final u = (s % 2.2) / 2.2;
      var p = animer(u, const [
        Cle(0.0, Pose(fronce: 0.4, bouche: Bouche.plat)),
        Cle(0.15, Pose(ecrase: 0.12, fronce: 0.8, paupiere: 0.35, bouche: Bouche.moue, ouv: 0.5, brasG: math.pi * 0.5, brasD: math.pi * 0.5)),
        // Il gonfle, rougit, serre les dents, poings en l'air.
        Cle(0.3, Pose(ecrase: -0.06, fronce: 1, paupiere: 0.3, bouche: Bouche.dents, ouv: 0.6, tourne: 0.15, brasG: -math.pi * 0.8, brasD: -math.pi * 0.2, sg: -0.5, sd: -0.5, joues: 0), Curves.easeOutBack),
        Cle(0.85, Pose(ecrase: -0.06, fronce: 1, paupiere: 0.3, bouche: Bouche.dents, ouv: 0.6, tourne: 0.15, brasG: -math.pi * 0.8, brasD: -math.pi * 0.2, sg: -0.5, sd: -0.5, joues: 0)),
        Cle(1.0, Pose(fronce: 0.4, bouche: Bouche.plat)),
      ]);
      final fureur = bosse(u, 0.22, 0.95);
      final tremble = 0.012 * fureur * math.sin(s * 70);
      p = p.c(brasG: p.brasG + 0.25 * math.sin(s * 20) * fureur, brasD: p.brasD - 0.25 * math.sin(s * 20) * fureur);
      c.save();
      c.translate(tremble, 0);
      dessinerGoutte(c, touche(p), sombre: sombre, matiere: MatiereGoutte.bleue(teinte: Color.lerp(const Color(0xFF7A5CFF), const Color(0xFFFF3B30), fureur)));
      c.restore();
      for (var k = 0; k < 4; k++) {
        final q = ((u * 1.6 + k / 4) % 1.0);
        final cote = k.isEven ? -1.0 : 1.0;
        final cen = Offset(0.5 + cote * (0.07 + 0.13 * q), 0.25 - 0.17 * q);
        final r = 0.028 + 0.04 * q;
        final a = 0.8 * (1 - q) * fureur;
        c.drawCircle(cen, r, Paint()..color = (sombre ? const Color(0xFFE5E5EA) : Colors.white).withValues(alpha: a));
        c.drawCircle(cen, r, _plume(0.008, kEncre.withValues(alpha: a * 0.6)));
      }

    case 'goutte/dodo':
      final u = (s % 3.4) / 3.4;
      final souffle = math.sin(u * 2 * math.pi);
      var p = animer(u, const [
        Cle(0.0, Pose(incline: -0.3, tourne: -0.25, paupiere: 1, bouche: Bouche.o, ouv: 0.2, bras: 0.6, brasG: math.pi * 0.7, brasD: math.pi * 0.3, joues: 0.4)),
        Cle(0.55, Pose(incline: -0.42, tourne: -0.25, paupiere: 1, bouche: Bouche.o, ouv: 0.2, bras: 0.6, brasG: math.pi * 0.7, brasD: math.pi * 0.3, joues: 0.4)),
        // Le sursaut : la tête tombe, se relève d'un coup, un œil s'ouvre…
        Cle(0.62, Pose(incline: -0.05, tourne: 0.1, paupiere: 0.55, sg: 0.5, bouche: Bouche.plat, bras: 0.6, brasG: math.pi * 0.7, brasD: math.pi * 0.3, joues: 0.4), Curves.easeOutBack),
        Cle(0.75, Pose(incline: -0.05, tourne: 0.1, paupiere: 0.6, sg: 0.5, bouche: Bouche.plat, bras: 0.6, brasG: math.pi * 0.7, brasD: math.pi * 0.3, joues: 0.4)),
        // … et se rendort.
        Cle(1.0, Pose(incline: -0.3, tourne: -0.25, paupiere: 1, bouche: Bouche.o, ouv: 0.2, bras: 0.6, brasG: math.pi * 0.7, brasD: math.pi * 0.3, joues: 0.4)),
      ]);
      p = p.c(ecrase: 0.04 * souffle);
      dessinerGoutte(c, touche(p), sombre: sombre);
      final dort = 1 - bosse(u, 0.56, 0.85);
      final b = (0.02 + 0.035 * (0.5 + 0.5 * souffle)) * dort;
      if (b > 0.004) {
        c.drawCircle(const Offset(0.47, 0.66), b, Paint()..color = Colors.white.withValues(alpha: 0.75));
        c.drawCircle(const Offset(0.47, 0.66), b, _plume(0.005, kEncre.withValues(alpha: 0.4)));
      }
      for (var k = 0; k < 3; k++) {
        final q = ((u * 1.2 + k / 3) % 1.0);
        final cen = Offset(0.7 + 0.12 * q, 0.38 - 0.28 * q);
        final t = 0.035 + 0.04 * q;
        c.drawPath(
          Path()
            ..moveTo(cen.dx - t / 2, cen.dy - t / 2)
            ..lineTo(cen.dx + t / 2, cen.dy - t / 2)
            ..lineTo(cen.dx - t / 2, cen.dy + t / 2)
            ..lineTo(cen.dx + t / 2, cen.dy + t / 2),
          _plume(0.014, encre.withValues(alpha: bosse(q, 0, 1) * dort)),
        );
      }

    case 'goutte/wow':
      final u = (s % 2.4) / 2.4;
      final p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire)),
        Cle(0.14, Pose(ecrase: 0.14, paupiere: 0.5, sg: -0.6, sd: -0.6, bouche: Bouche.plat)),
        // Il s'étire d'un coup : grands yeux, sourcils au plafond, mains
        // aux joues.
        Cle(0.26, Pose(ecrase: -0.18, saut: 0.03, oeil: 1.4, sg: 1.2, sd: 1.2, bouche: Bouche.o, ouv: 1, brasG: -math.pi * 0.62, brasD: -math.pi * 0.38, joues: 0.3), Curves.easeOutBack),
        Cle(0.72, Pose(ecrase: -0.15, saut: 0.02, oeil: 1.4, sg: 1.2, sd: 1.2, bouche: Bouche.o, ouv: 0.85, brasG: -math.pi * 0.62, brasD: -math.pi * 0.38, joues: 0.3, tourne: 0.12)),
        Cle(1.0, Pose(bouche: Bouche.sourire)),
      ]);
      dessinerGoutte(c, touche(p), sombre: sombre);
      final e = bosse(u, 0.24, 0.76);
      _traits(c, const Offset(0.5, 0.4), 0.3, 0.38, [for (var k = 0; k < 5; k++) -math.pi / 2 + (k - 2) * 0.45], kOr, e, 0.018);

    case 'goutte/fete':
      final u = (s % 2.0) / 2.0;
      // La danse, sur deux temps : tête et bras alternent.
      final temps = math.sin(u * 4 * math.pi);
      final p = Pose(tourne: 0.4 * temps, incline: 0.14 * temps, saut: 0.035 * temps.abs(), heureux: 1, bouche: Bouche.rire, ouv: 0.8, joues: 1, sg: 0.7, sd: 0.7, brasG: -math.pi * 0.75 + 0.35 * temps, brasD: -math.pi * 0.25 + 0.35 * temps);
      dessinerGoutte(c, touche(p), sombre: sombre, tete: (c) {
        c.save();
        c.translate(0.02 * temps, 0);
        final chapeau = Path()
          ..moveTo(-0.075, -0.175)
          ..lineTo(0.0, -0.39)
          ..lineTo(0.075, -0.175)
          ..close();
        c.drawPath(chapeau, Paint()..shader = ui.Gradient.linear(const Offset(-0.07, -0.2), const Offset(0.07, -0.3), [const Color(0xFFFF5E9C), const Color(0xFFFFB13D)]));
        for (var k = 0; k < 3; k++) {
          c.drawCircle(Offset(-0.03 + k * 0.03, -0.22 - k * 0.045), 0.012, Paint()..color = Colors.white);
        }
        c.drawPath(chapeau, _plume(0.016));
        c.drawCircle(const Offset(0, -0.395), 0.025, Paint()..color = const Color(0xFFFFE14D));
        c.drawCircle(const Offset(0, -0.395), 0.025, _plume(0.012));
        c.restore();
      });
      const couleurs = [Color(0xFFFF5E9C), Color(0xFFFFC23D), Color(0xFF30D158), Color(0xFF5E5CE6), Color(0xFF2FB8FF)];
      for (var k = 0; k < 16; k++) {
        final q = ((s * 0.45 + k * 0.137) % 1.0);
        final x = 0.06 + ((k * 0.61803) % 1.0) * 0.88 + 0.03 * math.sin(q * 9 + k);
        c.save();
        c.translate(x, -0.05 + q);
        c.rotate(q * 12 + k);
        final r = Rect.fromCenter(center: Offset.zero, width: 0.03, height: 0.016 * (0.3 + 0.7 * math.cos(q * 20 + k).abs()));
        c.drawRect(r, Paint()..color = couleurs[k % couleurs.length].withValues(alpha: 1 - seg(q, 0.85, 1)));
        c.restore();
      }

    case 'goutte/bisou':
      final u = (s % 2.6) / 2.6;
      final p = animer(u, const [
        Cle(0.0, Pose(bouche: Bouche.sourire, joues: 0.8)),
        Cle(0.15, Pose(tourne: 0.4, incline: -0.12, paupiere: 1, bouche: Bouche.bisou, joues: 1, sg: 0.4, sd: 0.4, ecrase: 0.04)),
        // Le baiser envoyé : élan vers l'avant, main qui part de la bouche.
        Cle(0.3, Pose(tourne: 0.4, incline: -0.2, paupiere: 1, bouche: Bouche.bisou, joues: 1, sg: 0.4, sd: 0.4, ecrase: -0.05, brasD: -math.pi * 0.05), Curves.easeOutBack),
        Cle(0.55, Pose(tourne: 0.3, incline: -0.1, paupiere: 0, clin: 1, bouche: Bouche.sourire, ouv: 0.2, joues: 1, sd: 0.6, brasD: math.pi * 0.1)),
        Cle(1.0, Pose(bouche: Bouche.sourire, joues: 0.8)),
      ]);
      dessinerGoutte(c, touche(p), sombre: sombre);
      final v = seg(u, 0.3, 1.0);
      if (v > 0 && v < 1) {
        coeur(c, Offset(0.62 + 0.26 * v, 0.6 - 0.4 * Curves.easeOut.transform(v)), 0.06 + 0.08 * Curves.easeOutBack.transform(seg(v, 0, 0.3)), alpha: 1 - seg(v, 0.75, 1), angle: 0.25);
      }

    case 'goutte/pense':
      final u = (s % 3.0) / 3.0;
      final p = animer(u, const [
        Cle(0.0, Pose(tourne: 0.3, rx: 0.8, ry: -0.8, sg: 1, sd: -0.2, bouche: Bouche.malin, brasD: -math.pi * 0.62, joues: 0.3)),
        Cle(0.45, Pose(tourne: 0.3, rx: 0.8, ry: -0.8, sg: 1, sd: -0.2, bouche: Bouche.malin, brasD: -math.pi * 0.62, joues: 0.3, incline: 0.08)),
        // Il change de côté : il cherche ailleurs.
        Cle(0.55, Pose(tourne: -0.3, rx: -0.8, ry: -0.7, sg: -0.2, sd: 1, bouche: Bouche.plat, brasD: -math.pi * 0.62, joues: 0.3, incline: -0.05)),
        Cle(0.9, Pose(tourne: -0.3, rx: -0.8, ry: -0.7, sg: -0.2, sd: 1, bouche: Bouche.plat, brasD: -math.pi * 0.62, joues: 0.3, incline: -0.05)),
        Cle(1.0, Pose(tourne: 0.3, rx: 0.8, ry: -0.8, sg: 1, sd: -0.2, bouche: Bouche.malin, brasD: -math.pi * 0.62, joues: 0.3)),
      ]);
      dessinerGoutte(c, touche(p.c(paupiere: clignement(s, periode: 2.7))), sombre: sombre);
      final ap = Curves.easeOutBack.transform(seg(u, 0.0, 0.12));
      final fond = sombre ? const Color(0xFF3A3A3C) : Colors.white;
      for (final (o, r) in [(const Offset(0.68, 0.36), 0.022), (const Offset(0.73, 0.28), 0.032)]) {
        c.drawCircle(o, r * ap, Paint()..color = fond);
        c.drawCircle(o, r * ap, _plume(0.008));
      }
      final bulle = RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0.79, 0.15), width: 0.3 * ap, height: 0.16 * ap), const Radius.circular(0.08));
      c.drawRRect(bulle, Paint()..color = fond);
      c.drawRRect(bulle, _plume(0.01));
      for (var k = 0; k < 3; k++) {
        final allume = bosse(((u * 2) - k * 0.18) % 1.0, 0, 0.4);
        c.drawCircle(Offset(0.73 + k * 0.06, 0.15 - 0.012 * allume), 0.018 * ap, Paint()..color = encre.withValues(alpha: 0.3 + 0.7 * allume));
      }

    // ═════════════ LOT « ÉCLAT » (premium) ═════════════
    case 'eclat/feu':
      final u = (s % 2.8) / 2.8;
      final monte = Curves.easeOutCubic.transform(seg(u, 0.05, 0.3));
      final explose = seg(u, 0.3, 0.85);
      final retour = Curves.easeOutBack.transform(seg(u, 0.82, 1.0));
      _halo(c, const Offset(0.5, 0.3), 0.42, const Color(0xFFFFB13D), 0.4 * bosse(u, 0.28, 0.65));
      if (u < 0.3 || u > 0.82) {
        final p = u < 0.3
            ? Pose(saut: 0.32 * monte, ecrase: u < 0.05 ? 0.12 * seg(u, 0, 0.05) : -0.15 * (1 - monte), ry: -1, sg: 1, sd: 1, bouche: Bouche.rire, ouv: 0.7, brasG: -math.pi * 0.7, brasD: -math.pi * 0.3)
            : Pose(ecrase: 0.15 * (1 - retour), heureux: 1, bouche: Bouche.rire, ouv: 0.6, joues: 1);
        dessinerGoutte(c, touche(p), sombre: sombre, matiere: MatiereGoutte.irisee(s), hauteur: 0.6 * (u > 0.82 ? retour.clamp(0.05, 1.2) : 1 - 0.35 * monte));
      }
      if (explose > 0 && explose < 1) {
        const couleurs = [Color(0xFFFFC23D), Color(0xFFFF5E9C), Color(0xFF2FB8FF), Color(0xFF39E6C4), Color(0xFFB57CFF)];
        const centre = Offset(0.5, 0.3);
        for (var k = 0; k < 16; k++) {
          final a = k * 2 * math.pi / 16 + 0.2;
          final d = 0.36 * Curves.easeOutCubic.transform(explose);
          final pos = centre + Offset(math.cos(a), math.sin(a)) * d + Offset(0, 0.1 * explose * explose);
          c.drawLine(centre + Offset(math.cos(a), math.sin(a)) * d * 0.5, pos, _plume(0.007, couleurs[k % couleurs.length].withValues(alpha: 0.6 * (1 - explose))));
          gouttelette(c, pos, 0.06 * (1 - 0.5 * explose), couleurs[k % couleurs.length], angle: a - math.pi / 2, alpha: 1 - seg(explose, 0.6, 1));
        }
      }

    case 'eclat/prisme':
      final u = (s % 3.0) / 3.0;
      const bandes = [Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFFFFD60A), Color(0xFF30D158), Color(0xFF0A84FF), Color(0xFFBF5AF2)];
      final deploie = Curves.easeOutCubic.transform(seg(u, 0.05, 0.45)) * (1 - Curves.easeIn.transform(seg(u, 0.88, 1.0)));
      c.drawArc(Rect.fromCircle(center: const Offset(0.5, 0.8), radius: 0.445), math.pi, math.pi * deploie, false, _plume(0.012));
      for (var k = 0; k < bandes.length; k++) {
        c.drawArc(Rect.fromCircle(center: const Offset(0.5, 0.8), radius: 0.42 - k * 0.035), math.pi, math.pi * deploie, false, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.036
          ..color = bandes[k]);
      }
      // Il suit l'arc des yeux, de gauche à droite.
      final suit = -1 + 2 * deploie;
      final p = Pose(tourne: 0.4 * suit, rx: suit, ry: -0.6, sg: 0.8, sd: 0.8, bouche: Bouche.o, ouv: 0.5 * deploie + 0.2, joues: 0.8, brasG: -math.pi * 0.7, brasD: -math.pi * 0.3, bras: deploie.clamp(0.3, 1.0));
      dessinerGoutte(c, touche(p.c(paupiere: clignement(s))), sombre: sombre, matiere: MatiereGoutte.irisee(s), hauteur: 0.5);
      for (var k = 0; k < 4; k++) {
        final q = ((u * 1.5 + k / 4) % 1.0);
        etoile(c, Offset(0.13 + k * 0.25, 0.2 + 0.06 * math.sin(k * 2.0)), 0.04 * bosse(q, 0, 1), Colors.white, alpha: bosse(q, 0, 1));
      }

    case 'eclat/coeur':
      _coeurLiquide(c, s, touche);

    case 'eclat/couronne':
      final u = (s % 2.8) / 2.8;
      _halo(c, const Offset(0.5, 0.5), 0.46, kOr, 0.3);
      final p = animer(u, const [
        Cle(0.0, Pose(incline: -0.08, tourne: 0.35, paupiere: 0.45, rx: 0.5, sd: 0.8, sg: 0.2, bouche: Bouche.malin, joues: 0.6, brasD: -math.pi * 0.45)),
        // Il ajuste sa couronne, menton levé, l'air supérieur…
        Cle(0.4, Pose(incline: -0.14, tourne: 0.35, paupiere: 0.5, rx: 0.5, sd: 1, sg: 0.2, bouche: Bouche.malin, joues: 0.6, brasD: -math.pi * 0.5)),
        // … puis regarde de l'autre côté, sûr de lui.
        Cle(0.55, Pose(incline: -0.1, tourne: -0.35, paupiere: 0.45, rx: -0.6, sg: 0.9, sd: 0.1, bouche: Bouche.sourire, joues: 0.7, brasD: math.pi * 0.3, brasG: math.pi * 0.85)),
        Cle(0.9, Pose(incline: -0.1, tourne: -0.35, paupiere: 0.45, rx: -0.6, sg: 0.9, sd: 0.1, bouche: Bouche.sourire, joues: 0.7, brasD: math.pi * 0.3, brasG: math.pi * 0.85)),
        Cle(1.0, Pose(incline: -0.08, tourne: 0.35, paupiere: 0.45, rx: 0.5, sd: 0.8, sg: 0.2, bouche: Bouche.malin, joues: 0.6, brasD: -math.pi * 0.45)),
      ]);
      dessinerGoutte(c, touche(p), sombre: sombre, matiere: MatiereGoutte.irisee(s), tete: (c) {
        c.save();
        c.translate(0.02 * p.tourne, -0.215);
        c.rotate(0.12 * p.tourne);
        final cour = Path()
          ..moveTo(-0.115, 0.0)
          ..lineTo(-0.13, -0.12)
          ..lineTo(-0.065, -0.055)
          ..lineTo(0.0, -0.15)
          ..lineTo(0.065, -0.055)
          ..lineTo(0.13, -0.12)
          ..lineTo(0.115, 0.0)
          ..close();
        c.drawPath(cour, Paint()..shader = ui.Gradient.linear(const Offset(0, -0.15), const Offset(0, 0), [const Color(0xFFFFE58A), const Color(0xFFE59A00)]));
        c.drawPath(cour, _plume(0.016));
        c.drawCircle(const Offset(0, -0.035), 0.02, Paint()..color = kRose);
        c.drawCircle(const Offset(0, -0.035), 0.02, _plume(0.01));
        c.restore();
      });
      for (var k = 0; k < 5; k++) {
        final a = s * 1.4 + k * 2 * math.pi / 5;
        final devant = math.sin(a) > 0;
        etoile(c, const Offset(0.5, 0.5) + Offset(math.cos(a) * 0.4, math.sin(a) * 0.14 - 0.06), devant ? 0.042 : 0.026, kOr, alpha: devant ? 1 : 0.6, angle: a);
      }

    case 'eclat/fusee':
      final u = (s % 2.6) / 2.6;
      final feu = seg(u, 0.0, 0.25);
      final vol = Curves.easeInCubic.transform(seg(u, 0.25, 0.6));
      final retour = Curves.easeOutCubic.transform(seg(u, 0.6, 1.0));
      final y = u < 0.6 ? -0.95 * vol : 0.95 * (1 - retour);
      final tremble = u < 0.25 ? 0.01 * math.sin(s * 80) * feu : 0.0;
      c.save();
      c.translate(tremble, y);
      final f = u < 0.6 ? (0.3 + 0.7 * math.max(feu, vol)) : 0.4 * retour;
      final flamme = Path()
        ..moveTo(0.42, 0.85)
        ..quadraticBezierTo(0.5, 0.85 + 0.32 * f * (1 + 0.15 * math.sin(s * 50)), 0.58, 0.85)
        ..close();
      c.drawPath(flamme, Paint()..shader = ui.Gradient.linear(const Offset(0.5, 0.85), Offset(0.5, 0.85 + 0.32 * f), [const Color(0xFFFFF0A0), const Color(0xFFFF6A00), const Color(0x00FF2D00)], const [0, 0.5, 1]));
      final p = u < 0.25
          ? Pose(ecrase: 0.1 * feu, paupiere: 0.4, fronce: 0.6, bouche: Bouche.dents, ouv: 0.4, brasG: math.pi * 0.85, brasD: math.pi * 0.15)
          : Pose(ecrase: -0.12, ry: -1, sg: 1, sd: 1, bouche: Bouche.rire, ouv: 0.9, brasG: -math.pi * 0.85, brasD: -math.pi * 0.15, tourne: 0.15);
      dessinerGoutte(c, touche(p), sombre: sombre, matiere: MatiereGoutte.irisee(s));
      c.restore();
      if (vol > 0.1 && u < 0.6) {
        for (var k = 0; k < 4; k++) {
          final x = 0.3 + k * 0.13;
          c.drawLine(Offset(x, 0.5 + y + 0.2), Offset(x, 0.5 + y + 0.2 + 0.25 * vol), _plume(0.012, encre.withValues(alpha: 0.4 * vol)));
        }
      }

    case 'eclat/nova':
      final u = (s % 2.4) / 2.4;
      final charge = Curves.easeIn.transform(seg(u, 0.0, 0.4));
      final eclat = seg(u, 0.4, 0.92);
      _halo(c, const Offset(0.5, 0.55), 0.5, const Color(0xFF8E7BFF), 0.3 + 0.5 * charge * (1 - eclat));
      for (var k = 0; k < 3; k++) {
        final q = seg(eclat, k * 0.12, 0.7 + k * 0.1);
        if (q <= 0 || q >= 1) continue;
        c.drawCircle(const Offset(0.5, 0.55), 0.2 + 0.32 * Curves.easeOutCubic.transform(q), _plume(0.022 * (1 - q), Color.lerp(Colors.white, const Color(0xFF8E7BFF), k / 3)!.withValues(alpha: 1 - q)));
      }
      final p = u < 0.4
          ? Pose(ecrase: 0.12 * charge, paupiere: 1, fronce: 0.5 * charge, bouche: Bouche.dents, ouv: 0.3, brasG: math.pi * 0.45, brasD: math.pi * 0.55)
          : Pose(ecrase: -0.1 * (1 - eclat), oeil: 1.25, sg: 1, sd: 1, bouche: Bouche.rire, ouv: 0.9, joues: 1, brasG: -math.pi * 0.8, brasD: -math.pi * 0.2, tourne: 0.2 * math.sin(eclat * 6));
      dessinerGoutte(c, touche(p), sombre: sombre, matiere: MatiereGoutte.irisee(s));
      _traits(c, const Offset(0.5, 0.55), 0.34, 0.34 + 0.12 * bosse(u, 0.4, 0.75), [for (var k = 0; k < 12; k++) k * math.pi / 6 + u], Colors.white, bosse(u, 0.4, 0.75), 0.013);

    case 'eclat/vague':
      final u = (s % 2.6) / 2.6;
      double houle(double x) => 0.8 + 0.05 * math.sin((x * 2.4 - u * 2) * 2 * math.pi);
      final crete = Path()..moveTo(0, 1);
      for (var k = 0; k <= 40; k++) {
        crete.lineTo(k / 40, houle(k / 40));
      }
      crete
        ..lineTo(1, 1)
        ..close();
      c.drawPath(crete, Paint()..shader = ui.Gradient.linear(const Offset(0, 0.72), const Offset(0, 1), [const Color(0xFF39E6C4), const Color(0xFF0A5BD8)]));
      final ligne = Path()..moveTo(0, houle(0));
      for (var k = 1; k <= 40; k++) {
        ligne.lineTo(k / 40, houle(k / 40));
      }
      c.drawPath(ligne, _plume(0.012));
      for (var k = 0; k < 8; k++) {
        final x = ((k / 8 + u * 0.5) % 1.0);
        c.drawCircle(Offset(x, houle(x) - 0.006), 0.013, Paint()..color = Colors.white);
      }
      const xg = 0.5;
      final pente = (houle(xg + 0.01) - houle(xg - 0.01)) / 0.02;
      final balance = math.sin(u * 2 * math.pi * 2);
      final p = Pose(incline: math.atan(pente) * 0.8, tourne: 0.4, rx: 0.7, bouche: Bouche.rire, ouv: 0.8, joues: 0.9, sg: 0.8, sd: 0.8, brasG: math.pi * 0.95 + 0.2 * balance, brasD: -0.15 - 0.2 * balance);
      dessinerGoutte(c, touche(p.c(paupiere: clignement(s))), sombre: sombre, matiere: MatiereGoutte.irisee(s), hauteur: 0.5, base: Offset(xg, houle(xg) - 0.004));
      for (var k = 0; k < 5; k++) {
        final q = ((u * 2 + k / 5) % 1.0);
        gouttelette(c, Offset(0.32 - 0.16 * q + k * 0.02, 0.74 - 0.26 * q + 0.36 * q * q), 0.032, const Color(0xFFBFF6FF), angle: -0.8, alpha: 1 - q);
      }

    case 'eclat/cristal':
      _cristal(c, s, encre);
  }
}

void _halo(Canvas c, Offset centre, double r, Color couleur, double alpha) {
  if (alpha <= 0) return;
  c.drawCircle(centre, r, Paint()..shader = ui.Gradient.radial(centre, r, [couleur.withValues(alpha: alpha.clamp(0.0, 1.0)), couleur.withValues(alpha: 0)]));
}

// ── Le cœur liquide : la goutte se change en cœur qui bat.

List<Offset>? _contourGoutte;
List<Offset>? _contourCoeur;

double _aire(List<Offset> pts) {
  var a = 0.0;
  for (var k = 0; k < pts.length; k++) {
    final p = pts[k], q = pts[(k + 1) % pts.length];
    a += p.dx * q.dy - q.dx * p.dy;
  }
  return a / 2;
}

Path _morphe(double m) {
  const n = 72;
  final coeurPts = _contourCoeur ??= [
    for (var k = 0; k < n; k++)
      () {
        final t = math.pi * 2 * k / n;
        final hx = 16 * math.pow(math.sin(t), 3).toDouble();
        final hy = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t));
        return Offset(hx, hy + 2) / 34;
      }(),
  ];
  final gouttePts = _contourGoutte ??= () {
    final metrique = GeometrieMarque.goutte.computeMetrics().first;
    var debut = 0.0;
    var plusHaut = double.infinity;
    for (var k = 0; k < 400; k++) {
      final d = metrique.length * k / 400;
      final y = metrique.getTangentForOffset(d)!.position.dy;
      if (y < plusHaut) {
        plusHaut = y;
        debut = d;
      }
    }
    var pts = [
      for (var k = 0; k < n; k++) (metrique.getTangentForOffset((debut + metrique.length * k / n) % metrique.length)!.position - const Offset(0, 0.0095)) / 0.565,
    ];
    if (_aire(pts).sign != _aire(coeurPts).sign) pts = [pts.first, ...pts.skip(1).toList().reversed];
    return pts;
  }();
  final p = Path();
  for (var k = 0; k < n; k++) {
    final q = Offset.lerp(gouttePts[k], coeurPts[k], m)!;
    if (k == 0) {
      p.moveTo(q.dx, q.dy);
    } else {
      p.lineTo(q.dx, q.dy);
    }
  }
  return p..close();
}

void _coeurLiquide(Canvas c, double s, Pose Function(Pose) touche) {
  final u = (s % 2.4) / 2.4;
  final m = Curves.easeInOutCubic.transform(seg(u, 0.05, 0.3)) * (1 - Curves.easeInOutCubic.transform(seg(u, 0.78, 0.98)));
  final bat = 1 + 0.12 * bosse(u, 0.35, 0.45) + 0.08 * bosse(u, 0.5, 0.6);
  final r = touche(kRepos).ecrase;
  _halo(c, const Offset(0.5, 0.55), 0.48, kRose, 0.45 * m);
  final contour = _morphe(m);
  c.save();
  c.translate(0.5, 0.55);
  c.scale(0.62 * bat * (1 + 0.7 * r), 0.62 * bat * (1 - r));
  c.drawPath(contour, Paint()
    ..shader = ui.Gradient.linear(const Offset(-0.3, -0.4), const Offset(0.3, 0.4), [
      Color.lerp(_bleuClair, const Color(0xFFFF7AA2), m)!,
      Color.lerp(_bleu, const Color(0xFFE0144C), m)!,
    ]));
  final ombre = Path.combine(PathOperation.difference, contour, contour.shift(const Offset(-0.08, -0.07)));
  c.drawPath(ombre, Paint()..color = Color.lerp(_bleuOmbre, const Color(0xFFA00A35), m)!.withValues(alpha: 0.55));
  c.save();
  c.translate(-0.17 - 0.05 * m, -0.07 - 0.1 * m);
  c.rotate(0.4);
  c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 0.07, height: 0.2), const Radius.circular(0.04)), Paint()..color = Colors.white.withValues(alpha: 0.85));
  c.restore();
  c.drawPath(contour, _plume(0.04));
  for (final cote in [-1.0, 1.0]) {
    final x = cote * 0.12;
    c.drawPath(Path()
      ..moveTo(x - 0.05, 0.08)
      ..quadraticBezierTo(x, 0.02, x + 0.05, 0.08), _plume(0.03));
    c.drawOval(Rect.fromCenter(center: Offset(cote * 0.2, 0.16), width: 0.09, height: 0.05), Paint()..color = _joue.withValues(alpha: 0.7));
  }
  c.drawPath(Path()
    ..moveTo(-0.05, 0.19)
    ..quadraticBezierTo(0, 0.25, 0.05, 0.19), _plume(0.026));
  c.restore();
  final e = seg(u, 0.35, 0.68);
  if (e > 0 && e < 1) {
    for (var k = 0; k < 8; k++) {
      final a = -math.pi / 2 + (k - 3.5) * 0.4;
      gouttelette(c, const Offset(0.5, 0.5) + Offset(math.cos(a), math.sin(a)) * (0.3 + 0.13 * e), 0.045 * (1 - e), const Color(0xFFFF4F7B), angle: a + math.pi / 2, alpha: 1 - e);
    }
  }
}

void _cristal(Canvas c, double s, Color encre) {
  final u = (s % 3.0) / 3.0;
  _halo(c, const Offset(0.5, 0.52), 0.44, const Color(0xFF9FE8FF), 0.35);
  c.save();
  c.translate(0.5, 0.55);
  final tourne = math.cos(u * 2 * math.pi);
  c.scale(0.62 * (0.78 + 0.22 * tourne.abs()), 0.62);
  final contour = Path()
    ..moveTo(0, -0.5)
    ..lineTo(0.3, -0.05)
    ..lineTo(0.32, 0.18)
    ..lineTo(0.16, 0.42)
    ..lineTo(-0.16, 0.42)
    ..lineTo(-0.32, 0.18)
    ..lineTo(-0.3, -0.05)
    ..close();
  c.drawPath(contour, Paint()..shader = ui.Gradient.linear(const Offset(-0.3, -0.5), const Offset(0.3, 0.4), const [Color(0xFFE8FBFF), Color(0xFF6CC8FF), Color(0xFF2B6BFF)], const [0.0, 0.5, 1.0]));
  const facettes = [
    [Offset(0, -0.5), Offset(0.3, -0.05), Offset(0, 0.05)],
    [Offset(0, -0.5), Offset(-0.3, -0.05), Offset(0, 0.05)],
    [Offset(0.3, -0.05), Offset(0.32, 0.18), Offset(0, 0.05)],
    [Offset(-0.3, -0.05), Offset(-0.32, 0.18), Offset(0, 0.05)],
    [Offset(0.32, 0.18), Offset(0.16, 0.42), Offset(0, 0.05)],
    [Offset(-0.32, 0.18), Offset(-0.16, 0.42), Offset(0, 0.05)],
    [Offset(0.16, 0.42), Offset(-0.16, 0.42), Offset(0, 0.05)],
  ];
  for (var k = 0; k < facettes.length; k++) {
    final lum = 0.5 + 0.5 * math.sin(u * 2 * math.pi * 2 + k * 0.9);
    final f = Path()..addPolygon(facettes[k], true);
    c.drawPath(f, Paint()..color = Colors.white.withValues(alpha: 0.06 + 0.42 * lum * lum));
    c.drawPath(f, _plume(0.008, kEncre.withValues(alpha: 0.35)));
  }
  c.drawPath(contour, _plume(0.035));
  // Le visage, sur la facette centrale, qui suit la rotation.
  final fx = 0.06 * math.sin(u * 2 * math.pi);
  for (final cote in [-1.0, 1.0]) {
    final o = Offset(fx + cote * 0.085, 0.13);
    c.drawOval(Rect.fromCenter(center: o, width: 0.07, height: 0.09), Paint()..color = Colors.white);
    c.drawCircle(o + Offset(fx * 0.3, 0.005), 0.028, Paint()..color = kEncre);
    c.drawCircle(o + Offset(fx * 0.3 + 0.01, -0.006), 0.009, Paint()..color = Colors.white);
    c.drawOval(Rect.fromCenter(center: o, width: 0.07, height: 0.09), _plume(0.012));
  }
  c.drawPath(Path()
    ..moveTo(fx - 0.04, 0.24)
    ..quadraticBezierTo(fx, 0.29, fx + 0.04, 0.24), _plume(0.02));
  c.restore();
  for (var k = 0; k < 4; k++) {
    final q = ((u * 2 + k * 0.27) % 1.0);
    etoile(c, Offset(0.18 + 0.64 * ((k * 0.37) % 1.0), 0.18 + 0.58 * ((k * 0.61) % 1.0)), 0.05 * bosse(q, 0, 0.5), Colors.white, alpha: bosse(q, 0, 0.5));
  }
}
