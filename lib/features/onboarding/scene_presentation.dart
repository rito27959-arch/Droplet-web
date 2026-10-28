// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA SCÈNE DES RÉCITS — un seul dessin, qui se transforme SOUS LE DOIGT.
//
// Les grandes présentations (l'intro de Telegram, celles d'Apple) ne
// montrent pas quatre images côte à côte : elles montrent UN objet qui
// change de forme quand on glisse, à la vitesse du doigt, et qu'on peut
// arrêter à mi-chemin. C'est ce qui donne l'impression d'un produit
// travaillé : rien ne « saute », tout se déduit de ce qu'on vient de voir.
//
// Ici, l'objet est la marque elle-même — la bulle et la goutte :
//
//   0  LA MARQUE        posée par l'ouverture, des ronds dans l'eau.
//   1  LE RELAIS        la bulle s'ouvre en un cercle pointillé ; cinq
//                       téléphones en sortent ; la goutte (votre message)
//                       saute de l'un à l'autre jusqu'au destinataire.
//   2  LE CADENAS       les téléphones rentrent ; la bulle s'épaissit et
//                       devient le corps d'un cadenas, la goutte sa
//                       serrure. L'anse se FERME à l'instant où la page
//                       s'arrête — avec un petit choc dans la main.
//   3  LA CARTE         le cadenas s'ouvre en carte hors ligne : vous au
//                       centre, vos proches autour, l'un d'eux dit « je
//                       vais bien ».
//
// ── Comment c'est fait ────────────────────────────────────────────────
//
// • Chaque page est une POSE (`_Pose`) : rayon de la bulle, épaisseur,
//   pointillés, taille et place de la goutte, anse, téléphones, proches…
//   Entre deux pages, chaque valeur est interpolée selon la position
//   EXACTE du `PageController` — pas une animation lancée au changement
//   de page : le doigt pilote.
// • Les téléphones et les proches arrivent EN CASCADE (un léger décalage
//   par objet), comme les icônes d'iOS qui se rangent.
// • Par-dessus, chaque page a son MOUVEMENT DE REPOS (les ronds, le saut
//   de la goutte, les données chiffrées qui tournent, le radar), pondéré
//   par la proximité de la page : il s'efface pendant le glissement et
//   reprend à l'arrivée.
// • « Réduire les animations » : les mouvements de repos s'arrêtent sur
//   leur image la plus parlante ; le glissement reste, puisque c'est le
//   doigt qui le fait.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_colors.dart';
import '../../shared/widgets/marque_droplet.dart';
import 'ouverture_droplet.dart';

/// Le rapport entre le côté de la scène et le rayon de la bulle au repos.
const double _kRayonSurCote = 0.17;

/// Le rayon moyen de l'anneau de la marque, en hauteurs de marque.
const double _kRayonMarque = (GeometrieMarque.rayonInterieurBulle + GeometrieMarque.rayonExterieurBulle) / 2;

/// La scène des quatre récits.
class ScenePresentation extends StatefulWidget {
  const ScenePresentation({
    super.key,
    this.controleur,
    this.pageInitiale = 0,
    this.pageFixe,
    this.tempsFixe,
  });

  /// Le contrôleur des pages : la scène suit sa position au pixel près.
  final PageController? controleur;
  final int pageInitiale;

  /// Pour les tests de rendu : une position de page imposée (0 → 3).
  @visibleForTesting
  final double? pageFixe;

  /// Pour les tests de rendu : un instant imposé des mouvements de repos.
  @visibleForTesting
  final Duration? tempsFixe;

  /// La hauteur de la marque dans une scène de [cote] points — pour que
  /// l'ouverture vienne s'y poser exactement.
  static double hauteurMarque(double cote) => cote * _kRayonSurCote / _kRayonMarque;

  @override
  State<ScenePresentation> createState() => _ScenePresentationState();
}

class _ScenePresentationState extends State<ScenePresentation> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tic);
  final ValueNotifier<double> _temps = ValueNotifier(0);
  bool _reduit = false;

  /// Vrai quand l'anse du cadenas s'est fermée — pour ne donner le petit
  /// choc qu'une fois par arrivée sur la page.
  bool _cadenasFerme = false;

  @override
  void initState() {
    super.initState();
    widget.controleur?.addListener(_suivreCadenas);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.tempsFixe != null) {
      _temps.value = widget.tempsFixe!.inMicroseconds / 1e6;
    } else if (_reduit) {
      _ticker.stop();
      _temps.value = 0;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant ScenePresentation old) {
    super.didUpdateWidget(old);
    if (old.controleur != widget.controleur) {
      old.controleur?.removeListener(_suivreCadenas);
      widget.controleur?.addListener(_suivreCadenas);
    }
  }

  void _tic(Duration d) => _temps.value = d.inMicroseconds / 1e6;

  double get _page {
    if (widget.pageFixe != null) return widget.pageFixe!;
    final c = widget.controleur;
    if (c != null && c.hasClients && c.position.haveDimensions) return c.page ?? widget.pageInitiale.toDouble();
    return widget.pageInitiale.toDouble();
  }

  void _suivreCadenas() {
    final ecart = (_page - 2).abs();
    if (!_cadenasFerme && ecart < 0.015) {
      _cadenasFerme = true;
      HapticFeedback.mediumImpact();
    } else if (_cadenasFerme && ecart > 0.3) {
      _cadenasFerme = false;
    }
  }

  @override
  void dispose() {
    widget.controleur?.removeListener(_suivreCadenas);
    _ticker.dispose();
    _temps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, contraintes) {
      final taille = contraintes.biggest;
      final cote = math.min(taille.width, taille.height);
      final hMarque = ScenePresentation.hauteurMarque(cote);
      final centre = Offset(taille.width / 2, taille.height / 2);
      // Le centre de la BOÎTE de la marque, légèrement sous celui de la
      // bulle (la queue dépasse en bas).
      final centreBoite = centre - GeometrieMarque.centreBulle * hMarque;
      return Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: ValueListenableBuilder<bool>(
                valueListenable: OuvertureDroplet.active,
                builder: (context, ouverture, _) => CustomPaint(
                  painter: _PeintreScene(
                    page: () => _page,
                    temps: _temps,
                    repaint: Listenable.merge([_temps, ?widget.controleur]),
                    masquerMarque: ouverture,
                    sombre: sombre,
                    couleurs: _Couleurs(
                      accent: OuroColors.accent,
                      neutre: OuroColors.tertiaryLabel,
                      coque: OuroColors.secondaryLabel,
                      ecran: OuroColors.secondarySystemBackground,
                      fond: OuroColors.systemBackground,
                      trait: OuroColors.label,
                      succes: OuroColors.systemGreen,
                      lueurs: [OuroColors.accent, OuroColors.systemTeal, OuroColors.systemIndigo, OuroColors.systemGreen],
                      proches: [
                        OuroColors.systemIndigo,
                        OuroColors.systemGreen,
                        OuroColors.systemOrange,
                        OuroColors.systemPink,
                        OuroColors.systemTeal,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // La cible de l'ouverture : invisible, elle ne sert qu'à dire à
          // l'ouverture où poser la marque — c'est la scène qui la dessine
          // ensuite, au même pixel.
          Positioned(
            left: centreBoite.dx - hMarque * GeometrieMarque.rapport / 2,
            top: centreBoite.dy - hMarque / 2,
            child: IgnorePointer(
              child: CibleOuverture(hauteur: hMarque, couleur: OuroColors.accent, dessiner: false),
            ),
          ),
        ],
      );
    });
  }
}

class _Couleurs {
  const _Couleurs({
    required this.accent,
    required this.neutre,
    required this.coque,
    required this.ecran,
    required this.fond,
    required this.trait,
    required this.succes,
    required this.lueurs,
    required this.proches,
  });
  final Color accent, neutre, coque, ecran, fond, trait, succes;
  final List<Color> lueurs;
  final List<Color> proches;
}

// ─────────────────────────────────────────────────────────────
//  LES POSES
// ─────────────────────────────────────────────────────────────

/// L'état de la scène sur une page, en rayons de marque (`R`).
class _Pose {
  const _Pose({
    required this.rayon,
    required this.epaisseur,
    this.pointilles = 0,
    this.opaciteAnneau = 1,
    this.neutre = 0,
    this.remplissage = 0,
    this.queue = 0,
    this.goutteY = 0,
    required this.goutteH,
    this.anse = 0,
    this.telephones = 0,
    this.proches = 0,
    this.carte = 0,
  });

  final double rayon, epaisseur, pointilles, opaciteAnneau, neutre, remplissage, queue;
  final double goutteY, goutteH, anse, telephones, proches, carte;
}

/// La goutte de la marque, haute de 0,565 marque — soit 1,263 R.
const double _kGoutteMarque = 0.565 / _kRayonMarque;

final List<_Pose> _poses = [
  // 0 — la marque, exactement.
  _Pose(
    rayon: 1,
    epaisseur: (GeometrieMarque.rayonExterieurBulle - GeometrieMarque.rayonInterieurBulle) / _kRayonMarque,
    queue: 1,
    // Le centre de la goutte est 0,026 marque sous celui de la bulle.
    goutteY: (0.0095 - GeometrieMarque.centreBulle.dy) / _kRayonMarque,
    goutteH: _kGoutteMarque,
  ),
  // 1 — le relais.
  _Pose(rayon: 2.25, epaisseur: 0.032, pointilles: 0.6, opaciteAnneau: 0.6, neutre: 1, goutteH: 0.62, telephones: 1),
  // 2 — le cadenas.
  _Pose(rayon: 0.95, epaisseur: 0.27, remplissage: 0.12, goutteY: 0.1, goutteH: 0.7, anse: 1),
  // 3 — la carte.
  _Pose(rayon: 0.8, epaisseur: 0.035, opaciteAnneau: 0.7, remplissage: 0.12, goutteH: 0.56, proches: 1, carte: 1),
];

double _lerp(double a, double b, double t) => a + (b - a) * t;
double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Le décalage d'une cascade : l'objet [k] sur [n] commence un peu après
/// le précédent, et tous finissent ensemble.
double _cascade(double f, int k, int n, {double pas = 0.07}) {
  final total = pas * (n - 1);
  return Curves.easeInOutCubic.transform(((f - k * pas) / (1 - total)).clamp(0.0, 1.0));
}

// ─────────────────────────────────────────────────────────────
//  LA PEINTURE
// ─────────────────────────────────────────────────────────────

class _PeintreScene extends CustomPainter {
  _PeintreScene({
    required this.page,
    required this.temps,
    required Listenable repaint,
    required this.masquerMarque,
    required this.sombre,
    required this.couleurs,
  }) : super(repaint: repaint);

  final double Function() page;
  final ValueNotifier<double> temps;
  final bool masquerMarque;
  final bool sombre;
  final _Couleurs couleurs;

  static Path? _queueUnite;

  /// La queue de la bulle seule : la bulle de la marque moins son anneau.
  static Path get _queue => _queueUnite ??= Path.combine(
        PathOperation.difference,
        GeometrieMarque.bulle,
        Path()..addOval(Rect.fromCircle(center: GeometrieMarque.centreBulle, radius: GeometrieMarque.rayonExterieurBulle + 0.002)),
      );

  // Les cinq téléphones, en pentagone ; les cinq proches, éparpillés.
  static final List<double> _anglesTel = [for (var k = 0; k < 5; k++) -math.pi / 2 + k * 2 * math.pi / 5];
  static const List<(double, double)> _placesProches = [
    (-2.45, 1.95), // angle (radians), distance (R)
    (-0.62, 2.15),
    (0.42, 1.55),
    (2.25, 2.2),
    (1.45, 2.45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = page().clamp(0.0, 3.0);
    final t = temps.value;
    final cote = math.min(size.width, size.height);
    final R = cote * _kRayonSurCote;
    final c = Offset(size.width / 2, size.height / 2);

    final i = p.floor().clamp(0, 2);
    final f = p - i;
    final e = Curves.easeInOutCubic.transform(f);
    final a = _poses[i], b = _poses[i + 1];
    double v(double Function(_Pose) champ) => _lerp(champ(a), champ(b), e);

    // Le poids de chaque page : 1 posée dessus, 0 à une page de distance.
    double poids(int k) => (1 - (p - k).abs()).clamp(0.0, 1.0);

    // ── La lueur de fond, dont la teinte suit la page.
    final k0 = p.floor().clamp(0, 3), k1 = p.ceil().clamp(0, 3);
    final lueur = Color.lerp(couleurs.lueurs[k0], couleurs.lueurs[k1], e)!;
    canvas.drawCircle(
      c,
      cote * 0.62,
      Paint()
        ..shader = ui.Gradient.radial(c, cote * 0.62, [
          lueur.withValues(alpha: sombre ? 0.22 : 0.12),
          lueur.withValues(alpha: 0),
        ]),
    );

    // ── La carte (page 3) : des rues effacées vers les bords.
    final carte = v((q) => q.carte);
    if (carte > 0.01) _carte(canvas, c, R, carte);

    // ── Les mouvements de repos qui passent DERRIÈRE la marque.
    final w0 = poids(0), w2 = poids(2), w3 = poids(3);
    if (!masquerMarque && w0 > 0) _ronds(canvas, c, R, t, w0);
    if (w2 > 0) _donneesChiffrees(canvas, c, R, t, w2);
    if (w3 > 0) _radar(canvas, c, R, t, w3);

    // ── Les téléphones (page 1), en cascade.
    final ftel = i == 0 ? f : (i == 1 ? 1 - f : 0.0);
    if (ftel > 0) _telephones(canvas, c, R, t, ftel, poids(1));

    // ── Les proches (page 3), en cascade.
    final fpro = i == 2 ? f : 0.0;
    if (fpro > 0) _proches(canvas, c, R, t, fpro, w3);

    if (masquerMarque) return;

    // ── L'anneau : la bulle, le cercle pointillé, le corps du cadenas…
    final rayon = v((q) => q.rayon) * R;
    final epaisseur = math.max(1.2, v((q) => q.epaisseur) * R);
    final couleurAnneau = Color.lerp(couleurs.accent, couleurs.neutre, v((q) => q.neutre))!;
    final opaciteAnneau = v((q) => q.opaciteAnneau);
    final remplissage = v((q) => q.remplissage);
    if (remplissage > 0.001) {
      canvas.drawCircle(c, rayon, Paint()..color = couleurs.accent.withValues(alpha: remplissage));
    }

    // L'anse du cadenas, derrière l'anneau : elle se ferme quand la page
    // s'arrête.
    final anse = v((q) => q.anse);
    if (anse > 0.01) {
      final fermeture = Curves.easeOutBack.transform(_seg(w2, 0.78, 1.0));
      _anse(canvas, c, rayon, epaisseur, R, anse, fermeture);
    }

    final h = R / _kRayonMarque;
    if (p < 0.002) {
      // Posée sur la marque : on dessine LA marque, au tracé près — celle
      // que l'ouverture vient de déposer.
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(h);
      canvas.translate(-GeometrieMarque.centreBulle.dx, -GeometrieMarque.centreBulle.dy);
      canvas.drawPath(GeometrieMarque.bulle, Paint()..color = couleurs.accent);
      canvas.restore();
    } else {
      _anneau(canvas, c, rayon, epaisseur, v((q) => q.pointilles), couleurAnneau.withValues(alpha: couleurAnneau.a * opaciteAnneau));
      // La queue de la bulle s'efface dès les premiers millimètres du
      // glissement, sans changer de taille : elle ne se transforme pas,
      // elle se retire.
      final queue = i == 0 ? 1 - Curves.easeOut.transform(_seg(f, 0, 0.3)) : 0.0;
      if (queue > 0.01) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(h);
        canvas.translate(-GeometrieMarque.centreBulle.dx, -GeometrieMarque.centreBulle.dy);
        canvas.drawPath(_queue, Paint()..color = couleurs.accent.withValues(alpha: queue));
        canvas.restore();
      }
    }

    // ── La goutte : le message, la serrure, vous.
    final hg = v((q) => q.goutteH) * R;
    final centreGoutte = c + Offset(0, v((q) => q.goutteY) * R);
    // Sur la page 3, une respiration très lente : « vous êtes ici ».
    final souffle = 1 + 0.035 * w3 * math.sin(t * 2.2);
    _goutte(canvas, centreGoutte, hg * souffle, couleurs.accent);

    // ── Les mouvements de repos qui passent DEVANT.
    if (poids(1) > 0) _relais(canvas, c, R, t, poids(1));
  }

  // ── Les briques ────────────────────────────────────────────────

  void _anneau(Canvas canvas, Offset c, double r, double ep, double pointilles, Color couleur) {
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ep
      ..strokeCap = pointilles > 0.05 ? StrokeCap.round : StrokeCap.butt
      ..color = couleur;
    if (pointilles < 0.02) {
      canvas.drawCircle(c, r, pinceau);
      return;
    }
    // Des tirets qui se resserrent en trait plein : 56 arcs dont le vide
    // grandit avec [pointilles].
    const n = 56;
    final pas = 2 * math.pi / n;
    final rect = Rect.fromCircle(center: c, radius: r);
    for (var k = 0; k < n; k++) {
      canvas.drawArc(rect, k * pas, pas * (1 - pointilles), false, pinceau);
    }
  }

  void _goutte(Canvas canvas, Offset centre, double h, Color couleur, {double alpha = 1, double etirement = 0, double angle = 0}) {
    if (h <= 0 || alpha <= 0) return;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(h / 0.565 * (1 - etirement * 0.4), h / 0.565 * (1 + etirement));
    canvas.translate(0, -0.0095);
    final a = couleur.a * alpha;
    canvas.drawPath(
      GeometrieMarque.goutte,
      Paint()
        ..isAntiAlias = true
        ..shader = ui.Gradient.linear(
          const Offset(-0.12, -0.2),
          const Offset(0.16, 0.29),
          [couleur.withValues(alpha: a), couleur.withValues(alpha: a * 0.84)],
        ),
    );
    canvas.restore();
  }

  /// Un rond dans l'eau.
  void _rond(Canvas canvas, Offset c, double r0, double r1, double p, Color couleur, {double ep = 1.6, double alpha = 0.45}) {
    if (p <= 0 || p >= 1 || alpha <= 0) return;
    final r = r0 + (r1 - r0) * Curves.easeOutCubic.transform(p);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ep * (1 - 0.5 * p)
        ..color = couleur.withValues(alpha: couleur.a * alpha * math.pow(1 - p, 1.4).toDouble()),
    );
  }

  // Page 0 — deux ronds lents autour de la marque.
  void _ronds(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.4) % 1.0;
    final r0 = R * (GeometrieMarque.rayonExterieurBulle / _kRayonMarque) + 4;
    _rond(canvas, c, r0, R * 2.7, _seg(cycle, 0.0, 0.66), couleurs.accent, alpha: 0.42 * w);
    _rond(canvas, c, r0, R * 2.7, _seg(cycle, 0.3, 0.96), couleurs.accent, alpha: 0.30 * w);
  }

  Offset _placeTel(Offset c, double R, int k, double sortie) {
    final d = _lerp(R * 0.9, R * 2.25, sortie);
    return c + Offset(math.cos(_anglesTel[k]), math.sin(_anglesTel[k])) * d;
  }

  // Page 1 — cinq téléphones sortis de la bulle.
  void _telephones(Canvas canvas, Offset c, double R, double t, double f, double w1) {
    final cycle = (t / 3.8) % 1.0;
    for (var k = 0; k < 5; k++) {
      final s = _cascade(f, k, 5);
      if (s <= 0) continue;
      final pos = _placeTel(c, R, k, Curves.easeOutBack.transform(s).clamp(0.0, 1.15));
      final larg = R * 0.42 * s, haut = R * 0.7 * s;
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: larg, height: haut), Radius.circular(R * 0.11 * s));
      // Le téléphone qui reçoit la goutte s'éclaire un instant.
      final arrivee = _arriveeRelais[k];
      final eclat = arrivee == null ? 0.0 : w1 * (_seg(cycle, arrivee, arrivee + 0.04) * (1 - _seg(cycle, arrivee + 0.1, arrivee + 0.3)));
      canvas.drawRRect(r, Paint()..color = Color.lerp(couleurs.ecran, couleurs.accent.withValues(alpha: 0.28), eclat)!.withValues(alpha: s));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = couleurs.coque.withValues(alpha: couleurs.coque.a * 0.5 * s),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos - Offset(0, haut * 0.37), width: larg * 0.3, height: 2.6 * s), const Radius.circular(2)),
        Paint()..color = couleurs.coque.withValues(alpha: couleurs.coque.a * 0.45 * s),
      );
      if (arrivee != null) _rond(canvas, pos, R * 0.3, R * 0.85, w1 * _seg(cycle, arrivee, arrivee + 0.3), couleurs.accent, alpha: 0.55 * w1);
    }
    // Le destinataire coche : le message est arrivé.
    final coche = w1 * Curves.easeOutBack.transform(_seg(cycle, 0.8, 0.88)) * (1 - _seg(cycle, 0.96, 1.0));
    if (coche > 0.01) _coche(canvas, _placeTel(c, R, 2, 1) + Offset(0, R * 0.04), R * 0.17 * coche, couleurs.succes);
  }

  // Le trajet de la goutte : du centre au téléphone 0, puis 1, puis 2.
  static const Map<int, double> _arriveeRelais = {0: 0.22, 1: 0.48, 2: 0.74};

  void _relais(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.8) % 1.0;
    Offset? ou;
    var etirement = 0.0, alpha = 1.0, angle = 0.0;
    Offset arc(Offset a, Offset b, double q, double bombe) {
      final m = (a + b) / 2;
      final n = (m - c);
      final dir = n.distance == 0 ? Offset.zero : n / n.distance;
      final ctrl = m + dir * bombe;
      final u = 1 - q;
      return a * (u * u) + ctrl * (2 * u * q) + b * (q * q);
    }

    final t0 = _placeTel(c, R, 0, 1), t1 = _placeTel(c, R, 1, 1), t2 = _placeTel(c, R, 2, 1);
    if (cycle < 0.06) {
      return;
    } else if (cycle < 0.22) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.06, 0.22));
      ou = Offset.lerp(c, t0, q);
      etirement = 0.2 * math.sin(math.pi * q);
      alpha = _seg(cycle, 0.06, 0.1);
    } else if (cycle < 0.26) {
      ou = t0;
    } else if (cycle < 0.48) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.26, 0.48));
      ou = arc(t0, t1, q, R * 0.55);
      etirement = 0.2 * math.sin(math.pi * q);
      angle = 0.5 * math.sin(math.pi * q);
    } else if (cycle < 0.52) {
      ou = t1;
    } else if (cycle < 0.74) {
      final q = Curves.easeInOutCubic.transform(_seg(cycle, 0.52, 0.74));
      ou = arc(t1, t2, q, R * 0.55);
      etirement = 0.2 * math.sin(math.pi * q);
      angle = 0.5 * math.sin(math.pi * q);
    } else if (cycle < 0.8) {
      ou = t2;
      alpha = 1 - _seg(cycle, 0.74, 0.8);
    }
    if (ou != null) {
      _goutte(canvas, ou, R * 0.36, couleurs.accent, alpha: alpha * w, etirement: etirement, angle: angle);
    }
  }

  // Page 2 — l'anse du cadenas.
  void _anse(Canvas canvas, Offset c, double r, double ep, double R, double apparition, double fermeture) {
    final x = r * 0.56;
    final haut = c.dy - r - R * 0.78;
    final leve = R * 0.34 * (1 - fermeture) * apparition + R * 0.5 * (1 - apparition);
    final rayonArc = x;
    final chemin = Path()
      ..moveTo(c.dx - x, c.dy - r * 0.5 - leve)
      ..lineTo(c.dx - x, haut + rayonArc - leve)
      ..arcToPoint(Offset(c.dx + x, haut + rayonArc - leve), radius: Radius.circular(rayonArc))
      ..lineTo(c.dx + x, c.dy - r * 0.5 - leve);
    canvas.save();
    // L'anse disparaît DANS l'anneau : on ne la dessine qu'à l'extérieur.
    canvas.clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & const Size(1e5, 1e5)),
      Path()..addOval(Rect.fromCircle(center: c, radius: r + ep / 2 - 0.5)),
    ));
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ep * 0.82
        ..strokeCap = StrokeCap.round
        ..color = couleurs.accent.withValues(alpha: apparition),
    );
    canvas.restore();
  }

  // Page 2 — les données chiffrées : trois arcs de points qui tournent
  // lentement autour du cadenas.
  void _donneesChiffrees(Canvas canvas, Offset c, double R, double t, double w) {
    final rayon = R * 1.85;
    final pinceau = Paint()..color = couleurs.accent.withValues(alpha: 0.4 * w);
    for (var groupe = 0; groupe < 3; groupe++) {
      final base = t * 0.32 + groupe * 2 * math.pi / 3;
      for (var k = 0; k < 7; k++) {
        final ang = base + k * 0.11;
        final taille = 2.2 * w * (k == 3 ? 1.25 : 1);
        canvas.drawCircle(c + Offset(math.cos(ang), math.sin(ang)) * rayon, taille, pinceau);
      }
    }
    // Un deuxième cercle, plus lent, à contresens.
    final p2 = Paint()..color = couleurs.accent.withValues(alpha: 0.22 * w);
    for (var groupe = 0; groupe < 4; groupe++) {
      final base = -t * 0.18 + groupe * math.pi / 2;
      for (var k = 0; k < 5; k++) {
        final ang = base + k * 0.09;
        canvas.drawCircle(c + Offset(math.cos(ang), math.sin(ang)) * R * 2.45, 1.8 * w, p2);
      }
    }
  }

  // Page 3 — les rues de la carte, effacées vers les bords.
  void _carte(Canvas canvas, Offset c, double R, double a) {
    final rayon = R * 2.85;
    final zone = Rect.fromCircle(center: c, radius: rayon);
    canvas.saveLayer(zone, Paint());
    final rue = Paint()
      ..color = couleurs.trait.withValues(alpha: (sombre ? 0.07 : 0.045) * a)
      ..strokeWidth = R * 0.16
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.32);
    for (final y in [-1.6, 0.9, 2.3]) {
      canvas.drawLine(Offset(-rayon, y * R), Offset(rayon, y * R + R * 0.25), rue);
    }
    rue.strokeWidth = R * 0.1;
    for (final x in [-1.8, 0.55, 2.0]) {
      canvas.drawLine(Offset(x * R, -rayon), Offset(x * R + R * 0.35, rayon), rue);
    }
    // Un parc.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(R * 0.9, R * 0.15, R * 0.85, R * 0.75), Radius.circular(R * 0.16)),
      Paint()..color = couleurs.succes.withValues(alpha: (sombre ? 0.13 : 0.1) * a),
    );
    canvas.restore();
    // Le fondu vers les bords.
    canvas.drawRect(
      zone,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.radial(c, rayon, [Colors.white, Colors.white, Colors.white.withValues(alpha: 0)], [0, 0.55, 1]),
    );
    canvas.restore();
  }

  // Page 3 — le radar : vous émettez, sans antenne.
  void _radar(Canvas canvas, Offset c, double R, double t, double w) {
    final cycle = (t / 3.2) % 1.0;
    _rond(canvas, c, R * 0.85, R * 2.8, _seg(cycle, 0, 0.7), couleurs.accent, ep: 1.8, alpha: 0.5 * w);
    _rond(canvas, c, R * 0.85, R * 2.8, _seg(cycle, 0.4, 1.0), couleurs.accent, ep: 1.8, alpha: 0.36 * w);
  }

  // Page 3 — vos proches, sortis de vous en cascade.
  void _proches(Canvas canvas, Offset c, double R, double t, double f, double w3) {
    final cycle = (t / 4.0) % 1.0;
    for (var k = 0; k < _placesProches.length; k++) {
      final s = _cascade(f, k, _placesProches.length, pas: 0.08);
      if (s <= 0) continue;
      final (ang, dist) = _placesProches[k];
      final sortie = Curves.easeOutBack.transform(s).clamp(0.0, 1.12);
      // Une petite dérive : ils sont vivants, pas épinglés.
      final derive = Offset(math.sin(t * 0.7 + k * 1.7), math.cos(t * 0.6 + k)) * R * 0.04 * w3;
      final pos = c + Offset(math.cos(ang), math.sin(ang)) * R * dist * sortie + derive;
      final rayon = R * 0.2 * s;
      canvas.drawCircle(pos, rayon + 3, Paint()..color = couleurs.fond.withValues(alpha: s));
      canvas.drawCircle(pos, rayon, Paint()..color = couleurs.proches[k].withValues(alpha: s));
      // Le proche n°1 dit « je vais bien » : une onde verte, puis une coche.
      if (k == 1) {
        _rond(canvas, pos, rayon, R * 1.1, w3 * _seg(cycle, 0.2, 0.62), couleurs.succes, alpha: 0.6 * w3);
        final coche = w3 * Curves.easeOutBack.transform(_seg(cycle, 0.24, 0.36)) * (1 - Curves.easeIn.transform(_seg(cycle, 0.9, 1.0)));
        if (coche > 0.01) {
          final centre = pos + Offset(rayon * 0.85, -rayon * 1.35);
          canvas.drawCircle(centre, R * 0.17 * coche + 2.5, Paint()..color = couleurs.fond);
          _coche(canvas, centre, R * 0.17 * coche, couleurs.succes);
        }
      }
    }
  }

  void _coche(Canvas canvas, Offset c, double r, Color couleur) {
    canvas.drawCircle(c, r, Paint()..color = couleur);
    final s = r / 11;
    final p = Path()
      ..moveTo(c.dx - 4.6 * s, c.dy + 0.2 * s)
      ..lineTo(c.dx - 1.3 * s, c.dy + 3.5 * s)
      ..lineTo(c.dx + 4.9 * s, c.dy - 3.3 * s);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_PeintreScene o) => o.masquerMarque != masquerMarque || o.sombre != sombre || o.couleurs.accent != couleurs.accent;
}
