// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES STICKERS DE DROPLET — « Goutte » (gratuit) et « Éclat » (premium).
//
// ── Ce que font les autres ────────────────────────────────────────────
//
// • WHATSAPP : des images WebP de 512 × 512, 500 ko au plus pour un
//   sticker animé. Une image : elle a une taille, elle pixellise si on
//   l'agrandit, et chaque envoi transporte le fichier.
// • TELEGRAM : des animations Lottie (`.tgs`), 512 × 512, 60 images/s,
//   3 s au plus, en boucle. Les stickers « Premium » portent en plus une
//   SECONDE animation, plus grande que le sticker, jouée par-dessus la
//   conversation la première fois qu'il apparaît (core.telegram.org/api/
//   stickers). C'est la référence du genre.
//
// ── Ce que font ceux de Droplet, et que les autres ne font pas ────────
//
// • ILS SONT DESSINÉS EN DIRECT, pas lus dans un fichier : nets à toutes
//   les tailles, à la cadence de l'écran (120 Hz s'il le permet), aux
//   couleurs du thème pour leurs ombres et reflets.
// • ILS NE PÈSENT RIEN SUR LE RÉSEAU : le message ne transporte que leur
//   nom (`🎞tgs:goutte/salut`, une trentaine d'octets). Ils passent donc
//   de téléphone en téléphone par Bluetooth aussi vite qu'un « ok » —
//   impossible avec 500 ko de WebP.
// • ILS RÉAGISSENT AU DOIGT : un toucher dans la conversation et la
//   goutte s'écrase et rebondit comme un liquide (ressort amorti), en
//   plus de son animation — chez les autres, toucher rejoue le film.
// • LES « ÉCLAT » (premium) ont une matière irisée qui tourne, et une
//   GERBE qui déborde du sticker par-dessus la conversation à son
//   arrivée (et à chaque toucher) : feu d'artifice, cœurs, étincelles
//   d'or, onde de choc… Tout le monde la voit ; seuls les comptes
//   premium peuvent les envoyer — la règle de Telegram.
//
// ── Le personnage ─────────────────────────────────────────────────────
//
// C'est LA goutte du logo, au tracé près (`GeometrieMarque.goutte`), à
// qui on a donné un visage. Chaque sticker est une petite scène écrite
// en code : une boucle de 2 à 3 s, avec un temps fort et un repos, les
// principes de l'animation de dessin animé (anticipation, écrasement-
// étirement, amorti, décalage des éléments secondaires).
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/services/premium_service.dart';
import '../../shared/widgets/marque_droplet.dart';
import 'animated_sticker.dart' show kStickerPrefix;

// ─────────────────────────────────────────────────────────────
//  LE CATALOGUE
// ─────────────────────────────────────────────────────────────

/// Les gerbes premium.
enum GenreEffet { feuArtifice, arcEnCiel, coeurs, or, etincelles, onde, eclaboussure, cristal }

@immutable
class StickerDroplet {
  const StickerDroplet(this.lot, this.id, this.nom, {this.effet});

  final String lot;
  final String id;

  /// Son nom lisible (accessibilité, repli sur les vieilles versions).
  final String nom;

  /// La gerbe jouée par-dessus la conversation — seulement les premium.
  final GenreEffet? effet;

  bool get premium => effet != null;

  String get reference => '$kStickerPrefix$lot/$id';
}

class StickersDroplet {
  StickersDroplet._();

  static const String lotGratuit = 'goutte';
  static const String lotPremium = 'eclat';

  static const List<StickerDroplet> gratuits = [
    StickerDroplet(lotGratuit, 'salut', 'Salut'),
    StickerDroplet(lotGratuit, 'rire', 'Mort de rire'),
    StickerDroplet(lotGratuit, 'coeur', 'Amoureux'),
    StickerDroplet(lotGratuit, 'merci', 'Merci'),
    StickerDroplet(lotGratuit, 'ok', "D'accord"),
    StickerDroplet(lotGratuit, 'triste', 'Triste'),
    StickerDroplet(lotGratuit, 'colere', 'En colère'),
    StickerDroplet(lotGratuit, 'dodo', 'Dodo'),
    StickerDroplet(lotGratuit, 'wow', 'Waouh'),
    StickerDroplet(lotGratuit, 'fete', 'La fête'),
    StickerDroplet(lotGratuit, 'bisou', 'Bisou'),
    StickerDroplet(lotGratuit, 'pense', 'Je réfléchis'),
  ];

  static const List<StickerDroplet> premiums = [
    StickerDroplet(lotPremium, 'feu', "Feu d'artifice", effet: GenreEffet.feuArtifice),
    StickerDroplet(lotPremium, 'prisme', 'Arc-en-ciel', effet: GenreEffet.arcEnCiel),
    StickerDroplet(lotPremium, 'coeur', 'Cœur liquide', effet: GenreEffet.coeurs),
    StickerDroplet(lotPremium, 'couronne', 'Couronne', effet: GenreEffet.or),
    StickerDroplet(lotPremium, 'fusee', 'Fusée', effet: GenreEffet.etincelles),
    StickerDroplet(lotPremium, 'nova', 'Supernova', effet: GenreEffet.onde),
    StickerDroplet(lotPremium, 'vague', 'Vague', effet: GenreEffet.eclaboussure),
    StickerDroplet(lotPremium, 'cristal', 'Cristal', effet: GenreEffet.cristal),
  ];

  static StickerDroplet? resoudre(String reference) {
    final r = reference.trim();
    if (!r.startsWith(kStickerPrefix)) return null;
    final chemin = r.substring(kStickerPrefix.length);
    for (final s in [...gratuits, ...premiums]) {
      if ('${s.lot}/${s.id}' == chemin) return s;
    }
    return null;
  }

  /// Cet appareil peut-il ENVOYER ce sticker ?
  static bool envoyable(StickerDroplet s) => !s.premium || PremiumService.niveau.donneAccesAuPack;
}

// ─────────────────────────────────────────────────────────────
//  LA VUE
// ─────────────────────────────────────────────────────────────

/// Un sticker Droplet, vivant.
class VueStickerDroplet extends StatefulWidget {
  const VueStickerDroplet({
    super.key,
    required this.sticker,
    required this.taille,
    this.interactif = false,
    this.cleEffet,
    this.tempsFixe,
  });

  final StickerDroplet sticker;
  final double taille;

  /// Dans la conversation : un toucher le fait réagir (et rejoue la gerbe
  /// d'un premium).
  final bool interactif;

  /// L'identifiant du message : la gerbe premium ne se joue d'elle-même
  /// qu'UNE fois par message et par session, comme chez Telegram.
  final String? cleEffet;

  /// Pour les tests de rendu : un instant imposé, en secondes.
  @visibleForTesting
  final double? tempsFixe;

  @override
  State<VueStickerDroplet> createState() => _VueStickerDropletState();
}

class _VueStickerDropletState extends State<VueStickerDroplet> with TickerProviderStateMixin {
  static final Set<String> _gerbesJouees = {};

  late final Ticker _ticker = createTicker((d) => _temps.value = d.inMicroseconds / 1e6);
  final ValueNotifier<double> _temps = ValueNotifier(0);

  /// Le « boing » du toucher : un ressort amorti, 0 → 1.
  late final AnimationController _boing = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.tempsFixe != null) {
      _temps.value = widget.tempsFixe!;
    } else if (reduit) {
      _ticker.stop();
      _temps.value = 1.1; // l'image la plus parlante de la plupart des boucles
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
    final cle = widget.cleEffet;
    if (cle != null && widget.sticker.premium && !reduit && _gerbesJouees.add(cle)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _gerbe());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _boing.dispose();
    _temps.dispose();
    super.dispose();
  }

  void _toucher() {
    HapticFeedback.lightImpact();
    _boing.forward(from: 0);
    if (widget.sticker.premium) _gerbe();
  }

  void _gerbe() {
    if (!mounted) return;
    final boite = context.findRenderObject();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (boite is! RenderBox || !boite.hasSize || overlay == null) return;
    final rect = boite.localToGlobal(Offset.zero) & boite.size;
    late OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: GerbePremium(
            genre: widget.sticker.effet!,
            centre: rect.center,
            taille: rect.shortestSide,
            surFin: () => entree.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entree);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final dessin = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.taille),
        painter: _PeintreSticker(
          sticker: widget.sticker,
          temps: _temps,
          boing: _boing,
          sombre: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
    return Semantics(
      label: widget.sticker.nom,
      image: true,
      child: widget.interactif ? GestureDetector(onTap: _toucher, child: dessin) : dessin,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LA PALETTE DU PERSONNAGE
// ─────────────────────────────────────────────────────────────

const Color _bleuHaut = Color(0xFF6BC0FF);
const Color _bleuBas = Color(0xFF1366F0);
const Color _encre = Color(0xFF0B1E3B);
const Color _joue = Color(0xFFFF7EA6);
const Color _langue = Color(0xFFFF5F86);
const Color _rouge = Color(0xFFFF4D4D);
const Color _vert = Color(0xFF30D158);
const Color _or = Color(0xFFFFC23D);

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double _bosse(double t, double a, double b) => math.sin(math.pi * _seg(t, a, b));

/// Un ressort amorti qui part de 1 et revient à 0 en oscillant.
double _ressort(double p) => p <= 0 || p >= 1 ? 0 : math.exp(-5.5 * p) * math.cos(p * math.pi * 5);

// ─────────────────────────────────────────────────────────────
//  LA PEINTURE
// ─────────────────────────────────────────────────────────────

class _PeintreSticker extends CustomPainter {
  _PeintreSticker({required this.sticker, required this.temps, required this.boing, required this.sombre})
      : super(repaint: Listenable.merge([temps, boing]));

  final StickerDroplet sticker;
  final ValueNotifier<double> temps;
  final AnimationController boing;
  final bool sombre;

  /// Pose du corps pour l'image en cours.
  late double _ecrase; // > 0 : écrasé ; < 0 : étiré
  late double _incline;
  late double _saut; // en fraction de la hauteur du sticker
  late double _irise;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width);
    final s = temps.value;
    final r = _ressort(boing.value);
    _ecrase = 0.22 * r;
    _incline = 0;
    _saut = 0;
    _irise = sticker.premium ? s : -1;
    switch ('${sticker.lot}/${sticker.id}') {
      case 'goutte/salut':
        _salut(canvas, s);
      case 'goutte/rire':
        _rire(canvas, s);
      case 'goutte/coeur':
        _amoureux(canvas, s);
      case 'goutte/merci':
        _merci(canvas, s);
      case 'goutte/ok':
        _ok(canvas, s);
      case 'goutte/triste':
        _triste(canvas, s);
      case 'goutte/colere':
        _colere(canvas, s);
      case 'goutte/dodo':
        _dodo(canvas, s);
      case 'goutte/wow':
        _wow(canvas, s);
      case 'goutte/fete':
        _fete(canvas, s);
      case 'goutte/bisou':
        _bisou(canvas, s);
      case 'goutte/pense':
        _pense(canvas, s);
      case 'eclat/feu':
        _feu(canvas, s);
      case 'eclat/prisme':
        _prisme(canvas, s);
      case 'eclat/coeur':
        _coeurLiquide(canvas, s);
      case 'eclat/couronne':
        _couronne(canvas, s);
      case 'eclat/fusee':
        _fusee(canvas, s);
      case 'eclat/nova':
        _nova(canvas, s);
      case 'eclat/vague':
        _vague(canvas, s);
      case 'eclat/cristal':
        _cristal(canvas, s);
    }
    canvas.restore();
  }

  // ── Le corps ────────────────────────────────────────────────────

  static const double _hCorps = 0.6;
  static const Offset _base = Offset(0.5, 0.86);

  /// Dessine l'ombre, le corps, puis appelle [visage] dans le repère de
  /// la marque (unités du tracé, base de la goutte à l'origine… décalée :
  /// le ventre est en (0, 0,095), la pointe vers (0, −0,27)).
  void _corps(Canvas c, {required void Function(Canvas) visage, Color? teinte, double hauteur = _hCorps, Offset? base, void Function(Canvas)? derriere}) {
    final b = (base ?? _base) - Offset(0, _saut);
    final k = hauteur / 0.565;
    final sx = 1 + _ecrase * 0.7, sy = 1 - _ecrase;

    // L'ombre au sol, qui rétrécit quand la goutte s'élève.
    final ombre = (1 - (_saut * 3).clamp(0.0, 0.6));
    c.drawOval(
      Rect.fromCenter(center: (base ?? _base) + const Offset(0, 0.012), width: 0.34 * sx * ombre, height: 0.05 * ombre),
      Paint()
        ..color = Colors.black.withValues(alpha: (sombre ? 0.32 : 0.14) * ombre)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.012),
    );

    c.save();
    c.translate(b.dx, b.dy);
    c.rotate(_incline);
    c.scale(sx * k, sy * k);
    c.translate(0, -0.291);
    derriere?.call(c);

    final chemin = GeometrieMarque.goutte;
    final Shader shader;
    if (_irise >= 0) {
      // L'irisé des « Éclat » : un dégradé qui tourne lentement autour du
      // ventre, sur une base bleu nuit.
      shader = ui.Gradient.sweep(
        const Offset(0, 0.06),
        const [Color(0xFF7B61FF), Color(0xFF2FB8FF), Color(0xFF39E6C4), Color(0xFFFF6FD8), Color(0xFF7B61FF)],
        null,
        TileMode.clamp,
        _irise * 1.2,
        _irise * 1.2 + 2 * math.pi,
      );
    } else {
      final h = teinte == null ? _bleuHaut : Color.lerp(_bleuHaut, teinte, 0.75)!;
      final bas = teinte == null ? _bleuBas : Color.lerp(_bleuBas, teinte, 0.8)!;
      shader = ui.Gradient.linear(const Offset(-0.1, -0.27), const Offset(0.12, 0.29), [h, bas]);
    }
    c.drawPath(chemin, Paint()..shader = shader);
    if (_irise >= 0) {
      // Un voile bleu profond sur le bas, pour que l'irisé reste précieux
      // et ne vire pas au bonbon.
      c.drawPath(
        chemin,
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, -0.1), const Offset(0, 0.3), [const Color(0x00000000), const Color(0x880A1440)]),
      );
    }
    // Le reflet : une virgule de lumière en haut à gauche, et un liseré
    // clair en bas à droite (la lumière qui traverse l'eau).
    c.drawOval(
      Rect.fromCenter(center: const Offset(-0.085, -0.0), width: 0.07, height: 0.13),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    c.drawCircle(const Offset(-0.06, -0.09), 0.018, Paint()..color = Colors.white.withValues(alpha: 0.6));
    c.save();
    c.clipPath(chemin);
    c.drawCircle(
      const Offset(0.02, 0.095),
      0.196,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.02
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    c.restore();
    visage(c);
    c.restore();
  }

  // ── Le visage (repère de la marque) ─────────────────────────────

  static const double _yYeux = 0.06;
  static const double _xYeux = 0.072;

  /// Deux yeux. [ouverture] 0 → fermés, 1 → ouverts ; [regard] décale les
  /// pupilles.
  void _yeux(Canvas c, {double ouverture = 1, Offset regard = Offset.zero, double taille = 1}) {
    for (final cote in [-1.0, 1.0]) {
      final centre = Offset(cote * _xYeux, _yYeux);
      if (ouverture < 0.12) {
        _trait(c, [centre + const Offset(-0.03, 0), centre + const Offset(0.03, 0)], 0.016);
        continue;
      }
      c.save();
      c.translate(centre.dx, centre.dy);
      c.scale(taille, ouverture * taille);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: 0.062, height: 0.078), Paint()..color = Colors.white);
      c.drawCircle(regard * 0.012 + const Offset(0, 0.004), 0.026, Paint()..color = _encre);
      c.drawCircle(regard * 0.012 + const Offset(0.009, -0.008), 0.0085, Paint()..color = Colors.white);
      c.restore();
    }
  }

  /// Des yeux en arc « ^ ^ » (rire, bonheur).
  void _yeuxHeureux(Canvas c, {double y = _yYeux}) {
    for (final cote in [-1.0, 1.0]) {
      final x = cote * _xYeux;
      final p = Path()
        ..moveTo(x - 0.032, y + 0.012)
        ..quadraticBezierTo(x, y - 0.035, x + 0.032, y + 0.012);
      c.drawPath(p, _plume(0.016));
    }
  }

  Paint _plume(double ep, [Color couleur = _encre]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = ep
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = couleur;

  void _trait(Canvas c, List<Offset> pts, double ep, [Color couleur = _encre]) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final q in pts.skip(1)) {
      p.lineTo(q.dx, q.dy);
    }
    c.drawPath(p, _plume(ep, couleur));
  }

  void _joues(Canvas c, [double alpha = 0.55]) {
    for (final cote in [-1.0, 1.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(cote * 0.122, 0.118), width: 0.06, height: 0.034),
        Paint()..color = _joue.withValues(alpha: alpha),
      );
    }
  }

  /// Une bouche souriante, plus ou moins ouverte.
  void _sourire(Canvas c, {double ouverture = 0, double largeur = 0.05, double y = 0.135}) {
    if (ouverture < 0.05) {
      final p = Path()
        ..moveTo(-largeur, y - 0.006)
        ..quadraticBezierTo(0, y + 0.04, largeur, y - 0.006);
      c.drawPath(p, _plume(0.014));
      return;
    }
    final h = 0.07 * ouverture;
    final p = Path()
      ..moveTo(-largeur, y - 0.008)
      ..quadraticBezierTo(0, y + 0.01, largeur, y - 0.008)
      ..quadraticBezierTo(largeur * 0.8, y + h, 0, y + h)
      ..quadraticBezierTo(-largeur * 0.8, y + h, -largeur, y - 0.008)
      ..close();
    c.drawPath(p, Paint()..color = _encre);
    c.save();
    c.clipPath(p);
    c.drawOval(Rect.fromCenter(center: Offset(0, y + h * 0.95), width: largeur * 1.3, height: h * 0.9), Paint()..color = _langue);
    c.restore();
  }

  /// Un bras : un trait épais et arrondi, de l'épaule vers [angle].
  void _bras(Canvas c, double cote, double angle, {double longueur = 0.12, Color? couleur}) {
    final epaule = Offset(cote * 0.175, 0.14);
    final coude = epaule + Offset(math.cos(angle), math.sin(angle)) * longueur * 0.55;
    final main = coude + Offset(math.cos(angle - cote * 0.35), math.sin(angle - cote * 0.35)) * longueur * 0.5;
    final p = Path()
      ..moveTo(epaule.dx, epaule.dy)
      ..quadraticBezierTo(coude.dx, coude.dy, main.dx, main.dy);
    c.drawPath(p, _plume(0.04, couleur ?? const Color(0xFF2A7BF4)));
    c.drawCircle(main, 0.027, Paint()..color = couleur ?? const Color(0xFF3D8BFF));
  }

  /// Une goutte d'eau libre (larme, éclaboussure), pointe vers [angle].
  void _gouttelette(Canvas c, Offset centre, double h, Color couleur, {double angle = 0, double alpha = 1}) {
    if (alpha <= 0 || h <= 0) return;
    c.save();
    c.translate(centre.dx, centre.dy);
    c.rotate(angle);
    c.scale(h / 0.565);
    c.translate(0, -0.0095);
    c.drawPath(GeometrieMarque.goutte, Paint()..color = couleur.withValues(alpha: couleur.a * alpha));
    c.restore();
  }

  void _coeur(Canvas c, Offset centre, double taille, Color couleur, {double alpha = 1, double angle = 0}) {
    if (alpha <= 0 || taille <= 0) return;
    c.save();
    c.translate(centre.dx, centre.dy);
    c.rotate(angle);
    c.scale(taille);
    final p = Path()
      ..moveTo(0, 0.35)
      ..cubicTo(-0.55, 0.0, -0.5, -0.5, 0, -0.22)
      ..cubicTo(0.5, -0.5, 0.55, 0.0, 0, 0.35)
      ..close();
    c.drawPath(p, Paint()..color = couleur.withValues(alpha: couleur.a * alpha));
    c.drawCircle(const Offset(-0.16, -0.16), 0.07, Paint()..color = Colors.white.withValues(alpha: 0.5 * alpha));
    c.restore();
  }

  void _etoile(Canvas c, Offset centre, double r, Color couleur, {double alpha = 1, double angle = 0}) {
    if (alpha <= 0 || r <= 0) return;
    final p = Path();
    for (var k = 0; k < 8; k++) {
      final a = angle + k * math.pi / 4;
      final rr = k.isEven ? r : r * 0.28;
      final q = centre + Offset(math.cos(a), math.sin(a)) * rr;
      if (k == 0) {
        p.moveTo(q.dx, q.dy);
      } else {
        p.lineTo(q.dx, q.dy);
      }
    }
    p.close();
    c.drawPath(p, Paint()..color = couleur.withValues(alpha: couleur.a * alpha));
  }

  // ═════════════════════════════════════════════════════════════
  //  LOT « GOUTTE » (gratuit)
  // ═════════════════════════════════════════════════════════════

  double _cligne(double s, {double periode = 3.1, double decal = 0}) {
    final u = ((s + decal) % periode) / periode;
    return 1 - _bosse(u, 0.92, 0.98);
  }

  void _salut(Canvas c, double s) {
    final u = (s % 2.4) / 2.4;
    _ecrase += 0.05 * math.sin(u * 4 * math.pi);
    _incline = 0.06 * math.sin(u * 2 * math.pi);
    _corps(c, visage: (c) {
      _yeux(c, ouverture: _cligne(s), regard: const Offset(0.2, -0.1));
      _joues(c);
      _sourire(c, ouverture: 0.55);
      _bras(c, -1, math.pi * 0.62);
      // Le bras qui salue : il se lève, puis balance trois fois.
      final leve = Curves.easeOutBack.transform(_seg(u, 0.0, 0.18)) * (1 - _seg(u, 0.85, 1));
      final balance = 0.45 * math.sin(u * 6 * math.pi) * leve;
      _bras(c, 1, -math.pi * 0.25 * leve + math.pi * 0.35 * (1 - leve) + balance, longueur: 0.15);
    });
    // De petits traits de mouvement près de la main.
    final m = _bosse(u, 0.15, 0.8);
    if (m > 0) {
      for (var k = 0; k < 3; k++) {
        final a = -0.9 + k * 0.35;
        final o = const Offset(0.8, 0.32);
        c.drawLine(o + Offset(math.cos(a), math.sin(a)) * 0.07, o + Offset(math.cos(a), math.sin(a)) * 0.11, _plume(0.012, _bleuBas.withValues(alpha: 0.6 * m)));
      }
    }
  }

  void _rire(Canvas c, double s) {
    final u = (s % 1.6) / 1.6;
    // Deux petits rebonds par cycle.
    final rebond = (math.sin(u * 4 * math.pi)).abs();
    _saut = 0.05 * rebond;
    _ecrase += 0.12 * (1 - rebond) - 0.04;
    _incline = 0.12 * math.sin(u * 2 * math.pi);
    _corps(c, visage: (c) {
      _yeuxHeureux(c);
      _joues(c, 0.7);
      _sourire(c, ouverture: 0.85 + 0.15 * rebond, largeur: 0.07);
      // Les larmes de joie qui jaillissent des yeux.
      for (final cote in [-1.0, 1.0]) {
        for (var k = 0; k < 2; k++) {
          final p = ((u * 2 + k * 0.5) % 1.0);
          final pos = Offset(cote * (0.11 + 0.16 * p), _yYeux + 0.01 - 0.09 * p + 0.2 * p * p);
          _gouttelette(c, pos, 0.05 * (1 - p * 0.5), const Color(0xFFBFE6FF), angle: cote * (0.8 + p), alpha: 1 - p);
        }
      }
      _bras(c, -1, math.pi * 0.85 + 0.3 * rebond);
      _bras(c, 1, math.pi * 0.15 - 0.3 * rebond);
    });
  }

  void _amoureux(Canvas c, double s) {
    final u = (s % 2.0) / 2.0;
    final bat = 1 + 0.18 * _bosse(u, 0, 0.12) + 0.12 * _bosse(u, 0.16, 0.28);
    _ecrase += -0.03 * _bosse(u, 0, 0.3);
    _incline = 0.08 * math.sin(u * 2 * math.pi);
    _corps(c, visage: (c) {
      for (final cote in [-1.0, 1.0]) {
        _coeur(c, Offset(cote * _xYeux, _yYeux), 0.085 * bat, const Color(0xFFFF3B6B));
      }
      _joues(c, 0.75);
      _sourire(c, ouverture: 0.3);
    });
    // Des cœurs qui montent en ondulant.
    for (var k = 0; k < 3; k++) {
      final p = ((u + k / 3) % 1.0);
      final x = 0.5 + (k - 1) * 0.22 + 0.04 * math.sin(p * 2 * math.pi * 1.5 + k);
      final y = 0.42 - 0.36 * p;
      _coeur(c, Offset(x, y), 0.07 * (0.6 + 0.4 * p), const Color(0xFFFF4F7B), alpha: _bosse(p, 0, 1), angle: 0.2 * math.sin(p * 6));
    }
  }

  void _merci(Canvas c, double s) {
    final u = (s % 2.6) / 2.6;
    // La révérence : on s'incline vers l'avant, on tient, on se relève.
    final penche = Curves.easeInOut.transform(_seg(u, 0.1, 0.35)) * (1 - Curves.easeInOut.transform(_seg(u, 0.65, 0.9)));
    _incline = 0.42 * penche;
    _ecrase += 0.06 * penche;
    _corps(c, visage: (c) {
      if (penche > 0.4) {
        _yeuxHeureux(c);
      } else {
        _yeux(c, ouverture: _cligne(s));
      }
      _joues(c, 0.4 + 0.4 * penche);
      _sourire(c, ouverture: 0.1);
      _bras(c, -1, math.pi * 0.35);
      _bras(c, 1, math.pi * 0.65);
    });
    // Une étincelle de gratitude au sommet de la révérence.
    final e = _bosse(u, 0.32, 0.62);
    _etoile(c, const Offset(0.78, 0.3), 0.05 * e, _or, alpha: e, angle: u * 3);
    _etoile(c, const Offset(0.86, 0.42), 0.03 * e, _or, alpha: e, angle: -u * 3);
  }

  void _ok(Canvas c, double s) {
    final u = (s % 2.4) / 2.4;
    final clin = _bosse(u, 0.35, 0.55);
    _incline = -0.05 + 0.05 * math.sin(u * 2 * math.pi);
    _corps(c, visage: (c) {
      // L'œil droit fait un clin d'œil appuyé.
      c.save();
      _yeux(c, ouverture: 1);
      c.restore();
      if (clin > 0.3) {
        c.drawCircle(const Offset(_xYeux, _yYeux), 0.042, Paint()..shader = ui.Gradient.linear(const Offset(0, 0.02), const Offset(0, 0.1), [_bleuHaut, _bleuBas]));
        final x = _xYeux;
        final p = Path()
          ..moveTo(x - 0.03, _yYeux)
          ..quadraticBezierTo(x, _yYeux + 0.022, x + 0.03, _yYeux);
        c.drawPath(p, _plume(0.015));
      }
      _joues(c);
      _sourire(c, ouverture: 0.2, largeur: 0.055);
      _bras(c, -1, math.pi * 0.7);
      _bras(c, 1, -math.pi * 0.15, longueur: 0.14);
    });
    // La coche verte que la goutte brandit.
    final pop = Curves.elasticOut.transform(_seg(u, 0.05, 0.45));
    final cen = const Offset(0.8, 0.36);
    c.drawCircle(cen, 0.075 * pop, Paint()..color = _vert);
    if (pop > 0.2) {
      final k = pop;
      _trait(c, [cen + Offset(-0.032, 0.002) * k, cen + Offset(-0.008, 0.026) * k, cen + Offset(0.036, -0.022) * k], 0.016 * k, Colors.white);
    }
  }

  void _triste(Canvas c, double s) {
    final u = (s % 3.0) / 3.0;
    _ecrase += 0.08 + 0.02 * math.sin(u * 2 * math.pi);
    // Une flaque qui grandit, à chaque larme tombée.
    final flaque = 0.12 + 0.05 * _seg(u, 0.55, 0.7);
    c.drawOval(Rect.fromCenter(center: _base + const Offset(0.1, 0.02), width: flaque * 1.4, height: flaque * 0.25), Paint()..color = const Color(0xFF8FD0FF).withValues(alpha: 0.7));
    _corps(c, visage: (c) {
      // Les sourcils relevés au centre, l'air piteux.
      for (final cote in [-1.0, 1.0]) {
        _trait(c, [Offset(cote * 0.105, _yYeux - 0.06), Offset(cote * 0.04, _yYeux - 0.075)], 0.012);
      }
      _yeux(c, ouverture: 0.9, regard: const Offset(0, 0.4), taille: 1.12);
      // La lèvre qui tremble.
      final tr = 0.004 * math.sin(s * 40);
      final p = Path()
        ..moveTo(-0.04, 0.155 + tr)
        ..quadraticBezierTo(0, 0.118, 0.04, 0.155 - tr);
      c.drawPath(p, _plume(0.014));
      // La larme : elle naît sous l'œil, grossit, coule, tombe.
      final l = _seg(u, 0.1, 0.62);
      final y = _yYeux + 0.045 + 0.22 * Curves.easeIn.transform(l);
      _gouttelette(c, Offset(_xYeux + 0.01, y), 0.03 + 0.02 * _seg(l, 0, 0.3), const Color(0xFFCDEBFF), alpha: 1 - _seg(u, 0.6, 0.64));
    });
  }

  void _colere(Canvas c, double s) {
    final u = (s % 2.0) / 2.0;
    final fureur = _bosse(u, 0.1, 0.9);
    // Il tremble de rage, plus fort au sommet.
    final tremble = 0.012 * fureur * math.sin(s * 70);
    c.save();
    c.translate(tremble, 0);
    _ecrase += 0.04 * fureur;
    _corps(c, teinte: Color.lerp(const Color(0xFF3D7BFF), _rouge, 0.3 + 0.6 * fureur), visage: (c) {
      for (final cote in [-1.0, 1.0]) {
        _trait(c, [Offset(cote * 0.115, _yYeux - 0.07), Offset(cote * 0.035, _yYeux - 0.035)], 0.016);
      }
      _yeux(c, ouverture: 0.75, taille: 0.95);
      final p = Path()
        ..moveTo(-0.045, 0.16)
        ..quadraticBezierTo(0, 0.12, 0.045, 0.16);
      c.drawPath(p, _plume(0.016));
    });
    c.restore();
    // La vapeur qui sort du sommet.
    for (var k = 0; k < 3; k++) {
      final p = ((u * 1.5 + k / 3) % 1.0);
      final cote = k.isEven ? -1.0 : 1.0;
      final cen = Offset(0.5 + cote * (0.08 + 0.12 * p), 0.24 - 0.16 * p);
      c.drawCircle(cen, 0.03 + 0.04 * p, Paint()..color = (sombre ? Colors.white : const Color(0xFFB8C2D0)).withValues(alpha: 0.6 * (1 - p) * fureur));
    }
  }

  void _dodo(Canvas c, double s) {
    final u = (s % 3.2) / 3.2;
    final souffle = math.sin(u * 2 * math.pi);
    _ecrase += 0.04 * souffle;
    _incline = -0.3;
    _corps(c, visage: (c) {
      for (final cote in [-1.0, 1.0]) {
        final x = cote * _xYeux;
        final p = Path()
          ..moveTo(x - 0.03, _yYeux)
          ..quadraticBezierTo(x, _yYeux + 0.025, x + 0.03, _yYeux);
        c.drawPath(p, _plume(0.014));
      }
      _joues(c, 0.4);
      c.drawOval(Rect.fromCenter(center: const Offset(0.0, 0.15), width: 0.03, height: 0.02 + 0.012 * (souffle + 1)), Paint()..color = _encre);
      // La bulle de sommeil, qui gonfle et dégonfle à la narine.
      final b = 0.02 + 0.03 * (0.5 + 0.5 * souffle);
      c.drawCircle(Offset(0.05 + b * 0.6, 0.14), b, Paint()..color = Colors.white.withValues(alpha: 0.65));
    });
    // Les « Z » qui montent.
    for (var k = 0; k < 3; k++) {
      final p = ((u + k / 3) % 1.0);
      final cen = Offset(0.68 + 0.12 * p, 0.38 - 0.28 * p);
      final t = 0.04 + 0.04 * p;
      _trait(c, [cen + Offset(-t / 2, -t / 2), cen + Offset(t / 2, -t / 2), cen + Offset(-t / 2, t / 2), cen + Offset(t / 2, t / 2)], 0.012, (sombre ? Colors.white : _encre).withValues(alpha: _bosse(p, 0, 1)));
    }
  }

  void _wow(Canvas c, double s) {
    final u = (s % 2.2) / 2.2;
    // Anticipation (il se tasse), puis il s'étire d'un coup, tient, revient.
    final tasse = _bosse(u, 0.0, 0.18);
    final etire = Curves.easeOutBack.transform(_seg(u, 0.15, 0.3)) * (1 - Curves.easeInOut.transform(_seg(u, 0.75, 0.95)));
    _ecrase += 0.12 * tasse - 0.16 * etire;
    _saut = 0.03 * etire;
    _corps(c, visage: (c) {
      _yeux(c, ouverture: 1, taille: 1 + 0.35 * etire);
      for (final cote in [-1.0, 1.0]) {
        _trait(c, [Offset(cote * 0.1, _yYeux - 0.07 - 0.02 * etire), Offset(cote * 0.045, _yYeux - 0.085 - 0.025 * etire)], 0.012);
      }
      c.drawOval(Rect.fromCenter(center: const Offset(0, 0.16), width: 0.05 + 0.02 * etire, height: 0.04 + 0.05 * etire), Paint()..color = _encre);
      _bras(c, -1, -math.pi * 0.75 * etire + math.pi * 0.7 * (1 - etire));
      _bras(c, 1, -math.pi * 0.25 * etire + math.pi * 0.3 * (1 - etire));
    });
    // Les traits de surprise.
    if (etire > 0.1) {
      for (var k = 0; k < 5; k++) {
        final a = -math.pi / 2 + (k - 2) * 0.42;
        final o = const Offset(0.5, 0.42);
        c.drawLine(o + Offset(math.cos(a), math.sin(a)) * (0.3 + 0.02 * etire), o + Offset(math.cos(a), math.sin(a)) * (0.36 + 0.03 * etire), _plume(0.014, _or.withValues(alpha: etire)));
      }
    }
  }

  void _fete(Canvas c, double s) {
    final u = (s % 2.0) / 2.0;
    final danse = math.sin(u * 4 * math.pi);
    _incline = 0.14 * danse;
    _saut = 0.03 * danse.abs();
    _corps(
      c,
      visage: (c) {
        _yeuxHeureux(c);
        _joues(c, 0.7);
        _sourire(c, ouverture: 0.7);
        _bras(c, -1, -math.pi * 0.75 + 0.3 * danse);
        _bras(c, 1, -math.pi * 0.25 + 0.3 * danse);
        // Le chapeau pointu, posé sur la pointe de la goutte.
        final chapeau = Path()
          ..moveTo(-0.07, -0.17)
          ..lineTo(0.0, -0.38)
          ..lineTo(0.07, -0.17)
          ..close();
        c.drawPath(chapeau, Paint()..shader = ui.Gradient.linear(const Offset(-0.07, -0.2), const Offset(0.07, -0.3), [const Color(0xFFFF5E9C), const Color(0xFFFFB13D)]));
        for (var k = 0; k < 3; k++) {
          c.drawCircle(Offset(-0.03 + k * 0.03, -0.22 - k * 0.04), 0.011, Paint()..color = Colors.white.withValues(alpha: 0.9));
        }
        c.drawCircle(const Offset(0, -0.385), 0.022, Paint()..color = const Color(0xFFFFE14D));
      },
    );
    // Les confettis qui tombent en tournoyant.
    const couleurs = [Color(0xFFFF5E9C), Color(0xFFFFC23D), Color(0xFF30D158), Color(0xFF5E5CE6), Color(0xFF2FB8FF)];
    for (var k = 0; k < 14; k++) {
      final p = ((s * 0.45 + k * 0.137) % 1.0);
      final x = 0.08 + ((k * 0.61803) % 1.0) * 0.84 + 0.03 * math.sin(p * 9 + k);
      final y = -0.05 + 1.0 * p;
      c.save();
      c.translate(x, y);
      c.rotate(p * 12 + k);
      c.drawRect(Rect.fromCenter(center: Offset.zero, width: 0.028, height: 0.014 * (0.4 + 0.6 * math.cos(p * 20 + k).abs())), Paint()..color = couleurs[k % couleurs.length].withValues(alpha: 1 - _seg(p, 0.85, 1)));
      c.restore();
    }
  }

  void _bisou(Canvas c, double s) {
    final u = (s % 2.4) / 2.4;
    final elan = _bosse(u, 0.15, 0.45);
    _incline = -0.12 * elan;
    _ecrase += -0.05 * elan;
    _corps(c, visage: (c) {
      _yeux(c, ouverture: elan > 0.3 ? 0.05 : _cligne(s));
      _joues(c, 0.8);
      // La moue du baiser.
      c.save();
      c.translate(0.012, 0.15);
      c.scale(1 + 0.3 * elan);
      final p = Path()
        ..moveTo(-0.018, -0.02)
        ..quadraticBezierTo(0.03, -0.02, 0.0, 0.0)
        ..quadraticBezierTo(0.03, 0.02, -0.018, 0.02);
      c.drawPath(p, _plume(0.014));
      c.restore();
    });
    // Le cœur envoyé, qui part de la bouche et s'envole.
    final v = _seg(u, 0.35, 1.0);
    if (v > 0 && v < 1) {
      final pos = Offset(0.58 + 0.28 * v, 0.6 - 0.38 * Curves.easeOut.transform(v));
      _coeur(c, pos, 0.07 + 0.08 * Curves.easeOutBack.transform(_seg(v, 0, 0.3)), const Color(0xFFFF3B6B), alpha: 1 - _seg(v, 0.7, 1), angle: 0.25);
    }
  }

  void _pense(Canvas c, double s) {
    final u = (s % 2.8) / 2.8;
    _incline = 0.1;
    _corps(c, visage: (c) {
      _yeux(c, ouverture: _cligne(s), regard: Offset(0.6, -0.8 + 0.3 * math.sin(u * 2 * math.pi)));
      final p = Path()
        ..moveTo(-0.03, 0.15)
        ..lineTo(0.035, 0.14);
      c.drawPath(p, _plume(0.014));
      _bras(c, 1, -math.pi * 0.85, longueur: 0.11);
      _bras(c, -1, math.pi * 0.6);
    });
    // La bulle de pensée, avec trois points qui s'allument tour à tour.
    final apparait = Curves.easeOutBack.transform(_seg(u, 0.0, 0.15));
    c.drawCircle(const Offset(0.66, 0.36), 0.025 * apparait, Paint()..color = sombre ? const Color(0xFF3A3A3C) : Colors.white);
    c.drawCircle(const Offset(0.72, 0.28), 0.035 * apparait, Paint()..color = sombre ? const Color(0xFF3A3A3C) : Colors.white);
    final bulle = RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0.78, 0.15), width: 0.3 * apparait, height: 0.16 * apparait), const Radius.circular(0.08));
    c.drawRRect(bulle, Paint()..color = sombre ? const Color(0xFF3A3A3C) : Colors.white);
    c.drawRRect(bulle, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.006
      ..color = Colors.black.withValues(alpha: 0.08));
    for (var k = 0; k < 3; k++) {
      final allume = _bosse(((u * 2) - k * 0.18) % 1.0, 0, 0.4);
      c.drawCircle(Offset(0.72 + k * 0.06, 0.15 - 0.012 * allume), 0.018 * apparait, Paint()..color = (sombre ? Colors.white : _encre).withValues(alpha: 0.35 + 0.65 * allume));
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  LOT « ÉCLAT » (premium)
  // ═════════════════════════════════════════════════════════════

  void _halo(Canvas c, Offset centre, double r, Color couleur, double alpha) {
    if (alpha <= 0) return;
    c.drawCircle(centre, r, Paint()..shader = ui.Gradient.radial(centre, r, [couleur.withValues(alpha: alpha), couleur.withValues(alpha: 0)]));
  }

  void _feu(Canvas c, double s) {
    final u = (s % 2.6) / 2.6;
    // La goutte s'élance, explose en gerbe au sommet, puis retombe dans
    // son corps : l'explosion est faite de SES gouttes.
    final monte = Curves.easeOutCubic.transform(_seg(u, 0.0, 0.3));
    final explose = _seg(u, 0.3, 0.85);
    final retour = Curves.easeOutBack.transform(_seg(u, 0.8, 1.0));
    final visible = u < 0.3 || u > 0.8;
    _halo(c, const Offset(0.5, 0.28), 0.4, const Color(0xFFFFB13D), 0.35 * _bosse(u, 0.28, 0.6));
    if (visible) {
      _saut = u < 0.3 ? 0.3 * monte : 0;
      _ecrase += u < 0.3 ? -0.12 * (1 - monte) : 0.15 * (1 - retour);
      _corps(c, hauteur: _hCorps * (u > 0.8 ? retour : 1 - 0.4 * monte), visage: (c) {
        _yeux(c, ouverture: 1, regard: const Offset(0, -1));
        _sourire(c, ouverture: 0.6);
      });
    }
    if (explose > 0 && explose < 1) {
      const couleurs = [Color(0xFFFFC23D), Color(0xFFFF5E9C), Color(0xFF2FB8FF), Color(0xFF39E6C4), Color(0xFFB57CFF)];
      final centre = const Offset(0.5, 0.28);
      for (var k = 0; k < 18; k++) {
        final a = k * 2 * math.pi / 18 + 0.2;
        final d = 0.36 * Curves.easeOutCubic.transform(explose);
        final pos = centre + Offset(math.cos(a), math.sin(a)) * d + Offset(0, 0.1 * explose * explose);
        _gouttelette(c, pos, 0.055 * (1 - 0.5 * explose), couleurs[k % couleurs.length], angle: a - math.pi / 2, alpha: 1 - _seg(explose, 0.6, 1));
        // La traînée.
        c.drawLine(centre + Offset(math.cos(a), math.sin(a)) * d * 0.55, pos, _plume(0.006, couleurs[k % couleurs.length].withValues(alpha: 0.5 * (1 - explose))));
      }
    }
  }

  void _prisme(Canvas c, double s) {
    final u = (s % 3.0) / 3.0;
    // L'arc-en-ciel se déploie de part et d'autre de la goutte, comme la
    // lumière qui la traverse.
    const bandes = [Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFFFFD60A), Color(0xFF30D158), Color(0xFF0A84FF), Color(0xFFBF5AF2)];
    final deploie = Curves.easeOutCubic.transform(_seg(u, 0.05, 0.45)) * (1 - Curves.easeIn.transform(_seg(u, 0.85, 1.0)));
    for (var k = 0; k < bandes.length; k++) {
      final r = 0.42 - k * 0.035;
      c.drawArc(
        Rect.fromCircle(center: const Offset(0.5, 0.78), radius: r),
        math.pi,
        math.pi * deploie,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.034
          ..color = bandes[k].withValues(alpha: 0.85),
      );
    }
    _saut = 0.02 * math.sin(u * 2 * math.pi);
    _corps(c, hauteur: 0.5, visage: (c) {
      _yeux(c, ouverture: _cligne(s), regard: const Offset(-0.4, -0.3));
      _joues(c, 0.6);
      _sourire(c, ouverture: 0.4);
    });
    for (var k = 0; k < 4; k++) {
      final p = ((u * 1.5 + k / 4) % 1.0);
      _etoile(c, Offset(0.15 + k * 0.23, 0.22 + 0.06 * math.sin(k * 2.0)), 0.035 * _bosse(p, 0, 1), Colors.white, alpha: _bosse(p, 0, 1));
    }
  }

  void _coeurLiquide(Canvas c, double s) {
    final u = (s % 2.4) / 2.4;
    // La goutte se change en cœur qui bat deux fois, puis redevient
    // goutte : interpolation point par point entre les deux contours.
    final m = Curves.easeInOutCubic.transform(_seg(u, 0.05, 0.3)) * (1 - Curves.easeInOutCubic.transform(_seg(u, 0.78, 0.98)));
    final bat = 1 + 0.12 * _bosse(u, 0.35, 0.45) + 0.08 * _bosse(u, 0.5, 0.6);
    _halo(c, const Offset(0.5, 0.55), 0.45, const Color(0xFFFF2D6B), 0.4 * m * (bat - 0.9) * 5);
    final contour = _morphe(m);
    c.save();
    c.translate(0.5, 0.55);
    c.scale(0.62 * bat);
    c.drawPath(
      contour,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(-0.3, -0.4), const Offset(0.3, 0.4), [
          Color.lerp(_bleuHaut, const Color(0xFFFF7AA2), m)!,
          Color.lerp(_bleuBas, const Color(0xFFE0144C), m)!,
        ]),
    );
    c.drawOval(Rect.fromCenter(center: Offset(-0.14 - 0.06 * m, -0.05 - 0.1 * m), width: 0.1, height: 0.18), Paint()..color = Colors.white.withValues(alpha: 0.45));
    // Le visage reste, attendri.
    for (final cote in [-1.0, 1.0]) {
      final x = cote * 0.12;
      final p = Path()
        ..moveTo(x - 0.05, 0.08)
        ..quadraticBezierTo(x, 0.02, x + 0.05, 0.08);
      c.drawPath(p, _plume(0.026));
    }
    c.drawOval(Rect.fromCenter(center: const Offset(0, 0.2), width: 0.08, height: 0.05), Paint()..color = _encre);
    c.restore();
    // Les éclaboussures à chaque battement.
    final e = _seg(u, 0.35, 0.65);
    if (e > 0 && e < 1) {
      for (var k = 0; k < 8; k++) {
        final a = -math.pi / 2 + (k - 3.5) * 0.4;
        final pos = const Offset(0.5, 0.5) + Offset(math.cos(a), math.sin(a)) * (0.3 + 0.12 * e);
        _gouttelette(c, pos, 0.04 * (1 - e), const Color(0xFFFF4F7B), angle: a + math.pi / 2, alpha: 1 - e);
      }
    }
  }

  static List<Offset>? _contourGoutte;
  static List<Offset>? _contourCoeur;

  static double _aire(List<Offset> pts) {
    var a = 0.0;
    for (var k = 0; k < pts.length; k++) {
      final p = pts[k], q = pts[(k + 1) % pts.length];
      a += p.dx * q.dy - q.dx * p.dy;
    }
    return a / 2;
  }

  /// Le contour, entre la goutte (0) et le cœur (1), centré sur l'origine.
  /// Les deux sont échantillonnés en 72 points, partant tous deux de leur
  /// sommet (la pointe de la goutte, le creux du cœur) et tournant dans le
  /// même sens — sinon le morphing se tordrait sur lui-même.
  Path _morphe(double m) {
    const n = 72;
    final coeur = _contourCoeur ??= [
      for (var k = 0; k < n; k++)
        () {
          final t = math.pi * 2 * k / n;
          final hx = 16 * math.pow(math.sin(t), 3).toDouble();
          final hy = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t));
          return Offset(hx, hy + 2) / 34;
        }(),
    ];
    final goutte = _contourGoutte ??= () {
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
        for (var k = 0; k < n; k++)
          (metrique.getTangentForOffset((debut + metrique.length * k / n) % metrique.length)!.position - const Offset(0, 0.0095)) / 0.565,
      ];
      if (_aire(pts).sign != _aire(coeur).sign) {
        pts = [pts.first, ...pts.skip(1).toList().reversed];
      }
      return pts;
    }();
    final p = Path();
    for (var k = 0; k < n; k++) {
      final q = Offset.lerp(goutte[k], coeur[k], m)!;
      if (k == 0) {
        p.moveTo(q.dx, q.dy);
      } else {
        p.lineTo(q.dx, q.dy);
      }
    }
    p.close();
    return p;
  }

  void _couronne(Canvas c, double s) {
    final u = (s % 2.6) / 2.6;
    _halo(c, const Offset(0.5, 0.5), 0.45, _or, 0.25);
    _incline = 0.05 * math.sin(u * 2 * math.pi);
    _corps(c, visage: (c) {
      _yeux(c, ouverture: _cligne(s), regard: const Offset(0, -0.2));
      _joues(c, 0.5);
      _sourire(c, ouverture: 0.15, largeur: 0.045);
      // La couronne d'or, posée sur la pointe, qui oscille un peu.
      c.save();
      c.translate(0, -0.2);
      c.rotate(0.08 * math.sin(u * 4 * math.pi));
      final cour = Path()
        ..moveTo(-0.11, 0.0)
        ..lineTo(-0.12, -0.11)
        ..lineTo(-0.06, -0.05)
        ..lineTo(0.0, -0.14)
        ..lineTo(0.06, -0.05)
        ..lineTo(0.12, -0.11)
        ..lineTo(0.11, 0.0)
        ..close();
      c.drawPath(cour, Paint()..shader = ui.Gradient.linear(const Offset(0, -0.14), const Offset(0, 0), [const Color(0xFFFFE58A), const Color(0xFFE59A00)]));
      c.drawCircle(const Offset(0, -0.03), 0.018, Paint()..color = const Color(0xFFFF2D6B));
      for (final x in [-0.12, 0.0, 0.12]) {
        c.drawCircle(Offset(x, x == 0 ? -0.145 : -0.115), 0.014, Paint()..color = const Color(0xFFFFF3C4));
      }
      c.restore();
    });
    // Les éclats d'or qui orbitent.
    for (var k = 0; k < 5; k++) {
      final a = s * 1.4 + k * 2 * math.pi / 5;
      final pos = const Offset(0.5, 0.5) + Offset(math.cos(a) * 0.38, math.sin(a) * 0.14 - 0.05);
      final devant = math.sin(a) > 0;
      _etoile(c, pos, devant ? 0.04 : 0.025, _or, alpha: devant ? 1 : 0.5, angle: a);
    }
  }

  void _fusee(Canvas c, double s) {
    final u = (s % 2.4) / 2.4;
    // Tremblement de mise à feu, décollage, sortie par le haut, retour par
    // le bas : une boucle continue.
    final feu = _seg(u, 0.0, 0.25);
    final vol = Curves.easeInCubic.transform(_seg(u, 0.25, 0.6));
    final retour = Curves.easeOutCubic.transform(_seg(u, 0.6, 1.0));
    final y = u < 0.6 ? -0.9 * vol : 0.9 * (1 - retour);
    final tremble = u < 0.25 ? 0.008 * math.sin(s * 80) * feu : 0.0;
    c.save();
    c.translate(tremble, y);
    // La flamme sous la goutte.
    final f = u < 0.6 ? (0.3 + 0.7 * math.max(feu, vol)) : 0.4 * retour;
    if (f > 0) {
      final flamme = Path()
        ..moveTo(0.42, 0.84)
        ..quadraticBezierTo(0.5, 0.84 + 0.3 * f * (1 + 0.15 * math.sin(s * 50)), 0.58, 0.84)
        ..close();
      c.drawPath(flamme, Paint()..shader = ui.Gradient.linear(const Offset(0.5, 0.84), Offset(0.5, 0.84 + 0.3 * f), [const Color(0xFFFFF0A0), const Color(0xFFFF6A00), const Color(0x00FF2D00)], [0, 0.5, 1]));
    }
    _corps(c, visage: (c) {
      _yeux(c, ouverture: 0.8, regard: const Offset(0, -1), taille: 1.05);
      _sourire(c, ouverture: 0.35);
    });
    c.restore();
    // Les traînées de vitesse.
    if (vol > 0.1 && u < 0.6) {
      for (var k = 0; k < 4; k++) {
        final x = 0.3 + k * 0.13;
        c.drawLine(Offset(x, 0.5 + y + 0.2), Offset(x, 0.5 + y + 0.2 + 0.25 * vol), _plume(0.01, Colors.white.withValues(alpha: 0.5 * vol)));
      }
    }
  }

  void _nova(Canvas c, double s) {
    final u = (s % 2.2) / 2.2;
    final charge = Curves.easeIn.transform(_seg(u, 0.0, 0.4));
    final eclat = _seg(u, 0.4, 0.9);
    _halo(c, const Offset(0.5, 0.55), 0.48, const Color(0xFF8E7BFF), 0.25 + 0.5 * charge * (1 - eclat));
    // Les anneaux de lumière.
    for (var k = 0; k < 3; k++) {
      final p = _seg(eclat, k * 0.12, 0.7 + k * 0.1);
      if (p <= 0 || p >= 1) continue;
      c.drawCircle(const Offset(0.5, 0.55), 0.2 + 0.32 * Curves.easeOutCubic.transform(p), _plume(0.02 * (1 - p), Color.lerp(Colors.white, const Color(0xFF8E7BFF), k / 3)!.withValues(alpha: 1 - p)));
    }
    _ecrase += -0.08 * charge * (1 - eclat) + 0.1 * _bosse(u, 0.4, 0.55);
    _corps(c, visage: (c) {
      if (charge > 0.6 && eclat < 0.3) {
        _yeuxHeureux(c);
      } else {
        _yeux(c, ouverture: 1, taille: 1 + 0.2 * eclat);
      }
      _sourire(c, ouverture: 0.3 + 0.5 * eclat);
    });
    // Des rayons, au moment de l'éclat.
    final r = _bosse(u, 0.4, 0.75);
    for (var k = 0; k < 12; k++) {
      final a = k * math.pi / 6 + u;
      c.drawLine(const Offset(0.5, 0.55) + Offset(math.cos(a), math.sin(a)) * 0.33, const Offset(0.5, 0.55) + Offset(math.cos(a), math.sin(a)) * (0.33 + 0.12 * r), _plume(0.012, Colors.white.withValues(alpha: r)));
    }
  }

  void _vague(Canvas c, double s) {
    final u = (s % 2.6) / 2.6;
    // La goutte surfe : elle monte et descend sur la crête qui défile.
    double houle(double x) => 0.78 + 0.05 * math.sin((x * 2.4 - u * 2) * 2 * math.pi);
    final crete = Path()..moveTo(0, 1);
    for (var k = 0; k <= 40; k++) {
      final x = k / 40;
      crete.lineTo(x, houle(x));
    }
    crete
      ..lineTo(1, 1)
      ..close();
    c.drawPath(crete, Paint()..shader = ui.Gradient.linear(const Offset(0, 0.7), const Offset(0, 1), [const Color(0xFF39E6C4), const Color(0xFF0A5BD8)]));
    // L'écume.
    for (var k = 0; k < 8; k++) {
      final x = ((k / 8 + u * 0.5) % 1.0);
      c.drawCircle(Offset(x, houle(x) - 0.006), 0.012, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
    final xg = 0.5;
    final pente = (houle(xg + 0.01) - houle(xg - 0.01)) / 0.02;
    _incline = math.atan(pente) * 0.8;
    _corps(c, hauteur: 0.5, base: Offset(xg, houle(xg) - 0.005), visage: (c) {
      _yeux(c, ouverture: _cligne(s), regard: const Offset(0.6, 0));
      _joues(c, 0.6);
      _sourire(c, ouverture: 0.7);
      _bras(c, -1, math.pi * 0.95 - 0.2 * math.sin(u * 6));
      _bras(c, 1, -0.1 + 0.2 * math.sin(u * 6));
    });
    // Les embruns.
    for (var k = 0; k < 5; k++) {
      final p = ((u * 2 + k / 5) % 1.0);
      _gouttelette(c, Offset(0.3 - 0.15 * p + k * 0.02, 0.72 - 0.25 * p + 0.35 * p * p), 0.03, const Color(0xFFBFF6FF), angle: -0.8, alpha: 1 - p);
    }
  }

  void _cristal(Canvas c, double s) {
    final u = (s % 3.0) / 3.0;
    _halo(c, const Offset(0.5, 0.52), 0.42, const Color(0xFF9FE8FF), 0.3);
    c.save();
    c.translate(0.5, 0.55);
    final tourne = math.cos(u * 2 * math.pi);
    c.scale(0.62 * (0.75 + 0.25 * tourne.abs()), 0.62);
    // Une goutte taillée : facettes qui captent la lumière en tournant.
    final contour = Path()
      ..moveTo(0, -0.5)
      ..lineTo(0.3, -0.05)
      ..lineTo(0.32, 0.18)
      ..lineTo(0.16, 0.42)
      ..lineTo(-0.16, 0.42)
      ..lineTo(-0.32, 0.18)
      ..lineTo(-0.3, -0.05)
      ..close();
    c.drawPath(contour, Paint()..shader = ui.Gradient.linear(const Offset(-0.3, -0.5), const Offset(0.3, 0.4), [const Color(0xFFE8FBFF), const Color(0xFF6CC8FF), const Color(0xFF2B6BFF)]));
    final facettes = [
      [const Offset(0, -0.5), const Offset(0.3, -0.05), const Offset(0, 0.05)],
      [const Offset(0, -0.5), const Offset(-0.3, -0.05), const Offset(0, 0.05)],
      [const Offset(0.3, -0.05), const Offset(0.32, 0.18), const Offset(0, 0.05)],
      [const Offset(-0.3, -0.05), const Offset(-0.32, 0.18), const Offset(0, 0.05)],
      [const Offset(0.32, 0.18), const Offset(0.16, 0.42), const Offset(0, 0.05)],
      [const Offset(-0.32, 0.18), const Offset(-0.16, 0.42), const Offset(0, 0.05)],
      [const Offset(0.16, 0.42), const Offset(-0.16, 0.42), const Offset(0, 0.05)],
    ];
    for (var k = 0; k < facettes.length; k++) {
      final lum = 0.5 + 0.5 * math.sin(u * 2 * math.pi * 2 + k * 0.9);
      final f = Path()..addPolygon(facettes[k], true);
      c.drawPath(f, Paint()..color = Colors.white.withValues(alpha: 0.08 + 0.4 * lum * lum));
      c.drawPath(f, _plume(0.006, Colors.white.withValues(alpha: 0.5)));
    }
    // Les yeux, discrets, sur la facette centrale.
    for (final cote in [-1.0, 1.0]) {
      c.drawCircle(Offset(cote * 0.08, 0.12), 0.03, Paint()..color = _encre);
      c.drawCircle(Offset(cote * 0.08 + 0.01, 0.11), 0.01, Paint()..color = Colors.white);
    }
    c.drawPath(Path()
      ..moveTo(-0.04, 0.22)
      ..quadraticBezierTo(0, 0.26, 0.04, 0.22), _plume(0.018));
    c.restore();
    // Les éclats de lumière.
    for (var k = 0; k < 4; k++) {
      final p = ((u * 2 + k * 0.27) % 1.0);
      _etoile(c, Offset(0.2 + 0.6 * ((k * 0.37) % 1.0), 0.2 + 0.55 * ((k * 0.61) % 1.0)), 0.05 * _bosse(p, 0, 0.5), Colors.white, alpha: _bosse(p, 0, 0.5), angle: p);
    }
  }

  @override
  bool shouldRepaint(_PeintreSticker o) => o.sticker != sticker || o.sombre != sombre;
}

// ─────────────────────────────────────────────────────────────
//  LA GERBE PREMIUM
// ─────────────────────────────────────────────────────────────

/// La gerbe qui déborde d'un sticker « Éclat » par-dessus la
/// conversation : 1,8 s, puis elle se retire d'elle-même.
class GerbePremium extends StatefulWidget {
  const GerbePremium({super.key, required this.genre, required this.centre, required this.taille, required this.surFin});

  final GenreEffet genre;
  final Offset centre;
  final double taille;
  final VoidCallback surFin;

  @override
  State<GerbePremium> createState() => _GerbePremiumState();
}

class _GerbePremiumState extends State<GerbePremium> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.surFin();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PeintreGerbe(widget.genre, widget.centre, widget.taille, _c),
      ),
    );
  }
}

class _Particule {
  _Particule(this.angle, this.vitesse, this.taille, this.couleur, this.tourne, this.forme);
  final double angle, vitesse, taille, tourne;
  final Color couleur;
  final int forme; // 0 goutte, 1 cœur, 2 étoile, 3 confetti
}

class _PeintreGerbe extends CustomPainter {
  _PeintreGerbe(this.genre, this.centre, this.taille, this.anim) : super(repaint: anim) {
    final r = math.Random(genre.index * 31 + 7);
    final (couleurs, forme, n) = switch (genre) {
      GenreEffet.feuArtifice => (const [Color(0xFFFFC23D), Color(0xFFFF5E9C), Color(0xFF2FB8FF), Color(0xFF39E6C4), Color(0xFFB57CFF)], 0, 46),
      GenreEffet.arcEnCiel => (const [Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFFFFD60A), Color(0xFF30D158), Color(0xFF0A84FF), Color(0xFFBF5AF2)], 3, 50),
      GenreEffet.coeurs => (const [Color(0xFFFF2D6B), Color(0xFFFF7AA2), Color(0xFFFF4F7B)], 1, 26),
      GenreEffet.or => (const [Color(0xFFFFE58A), Color(0xFFFFC23D), Color(0xFFE59A00)], 2, 36),
      GenreEffet.etincelles => (const [Color(0xFFFFF0A0), Color(0xFFFF9F0A), Color(0xFFFF6A00)], 2, 40),
      GenreEffet.onde => (const [Color(0xFFB4A7FF), Color(0xFF8E7BFF), Colors.white], 2, 24),
      GenreEffet.eclaboussure => (const [Color(0xFF8FE3FF), Color(0xFF39E6C4), Color(0xFF2FB8FF)], 0, 40),
      GenreEffet.cristal => (const [Colors.white, Color(0xFFBFF0FF), Color(0xFF9FE8FF)], 2, 30),
    };
    for (var k = 0; k < n; k++) {
      _particules.add(_Particule(
        r.nextDouble() * 2 * math.pi,
        0.7 + r.nextDouble() * 0.9,
        0.6 + r.nextDouble() * 0.7,
        couleurs[k % couleurs.length],
        (r.nextDouble() - 0.5) * 8,
        forme,
      ));
    }
  }

  final GenreEffet genre;
  final Offset centre;
  final double taille;
  final Animation<double> anim;
  final List<_Particule> _particules = [];

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    final portee = taille * 1.6;
    final fondu = 1 - Curves.easeIn.transform(_seg(t, 0.55, 1.0));

    // L'onde de choc (supernova) et l'éclair initial, pour tous.
    final flash = _bosse(t, 0, 0.18);
    if (flash > 0) {
      canvas.drawCircle(centre, taille * (0.4 + 0.5 * t), Paint()..shader = ui.Gradient.radial(centre, taille * (0.4 + 0.5 * t), [Colors.white.withValues(alpha: 0.45 * flash), Colors.white.withValues(alpha: 0)]));
    }
    if (genre == GenreEffet.onde) {
      for (var k = 0; k < 3; k++) {
        final p = _seg(t, k * 0.12, 0.7 + k * 0.1);
        if (p <= 0 || p >= 1) continue;
        canvas.drawCircle(
          centre,
          taille * (0.4 + 1.6 * Curves.easeOutCubic.transform(p)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6 * (1 - p)
            ..color = const Color(0xFFB4A7FF).withValues(alpha: 0.8 * (1 - p)),
        );
      }
    }
    if (genre == GenreEffet.arcEnCiel) {
      // Un arc-en-ciel qui se déploie au-dessus du sticker.
      const bandes = [Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFFFFD60A), Color(0xFF30D158), Color(0xFF0A84FF), Color(0xFFBF5AF2)];
      final d = Curves.easeOutCubic.transform(_seg(t, 0.0, 0.5));
      for (var k = 0; k < bandes.length; k++) {
        canvas.drawArc(
          Rect.fromCircle(center: centre + Offset(0, taille * 0.2), radius: taille * (1.2 - k * 0.07)),
          math.pi,
          math.pi * d,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = taille * 0.065
            ..color = bandes[k].withValues(alpha: 0.75 * fondu),
        );
      }
    }

    for (final p in _particules) {
      final avance = Curves.easeOutCubic.transform(t) * p.vitesse;
      final pesanteur = genre == GenreEffet.coeurs ? -0.35 * t * t : 0.7 * t * t;
      final pos = centre + Offset(math.cos(p.angle), math.sin(p.angle)) * portee * avance + Offset(0, portee * pesanteur);
      final cote = taille * 0.09 * p.taille * (1 - 0.4 * t);
      final alpha = fondu;
      if (alpha <= 0) continue;
      final peinture = Paint()..color = p.couleur.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      switch (p.forme) {
        case 0:
          canvas.rotate(p.angle - math.pi / 2);
          canvas.scale(cote * 1.4 / 0.565);
          canvas.translate(0, -0.0095);
          canvas.drawPath(GeometrieMarque.goutte, peinture);
        case 1:
          canvas.rotate(0.3 * math.sin(t * 8 + p.tourne));
          canvas.scale(cote * 1.6);
          canvas.drawPath(
            Path()
              ..moveTo(0, 0.35)
              ..cubicTo(-0.55, 0.0, -0.5, -0.5, 0, -0.22)
              ..cubicTo(0.5, -0.5, 0.55, 0.0, 0, 0.35)
              ..close(),
            peinture,
          );
        case 2:
          canvas.rotate(p.tourne * t);
          final etoile = Path();
          for (var k = 0; k < 8; k++) {
            final a = k * math.pi / 4;
            final rr = k.isEven ? cote : cote * 0.3;
            if (k == 0) {
              etoile.moveTo(math.cos(a) * rr, math.sin(a) * rr);
            } else {
              etoile.lineTo(math.cos(a) * rr, math.sin(a) * rr);
            }
          }
          etoile.close();
          canvas.drawPath(etoile, peinture);
        default:
          canvas.rotate(p.tourne * t * 2);
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: cote * 1.2, height: cote * 0.55 * (0.3 + 0.7 * math.cos(t * 14 + p.tourne).abs())), peinture);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PeintreGerbe o) => false;
}
