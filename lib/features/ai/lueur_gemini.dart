// ============================================================================
// LA LUEUR ARC-EN-CIEL DE L'ASSISTANT — inspirée de Gemini.
// ----------------------------------------------------------------------------
// Quand on pose une question, Gemini ne montre pas trois petits points : un
// dégradé coloré s'allume, pulse et glisse tant que la réponse se prépare,
// puis s'apaise quand elle est là. Les couleurs sont celles de Google (bleu,
// rouge, jaune, vert) et de l'étoile Gemini (bleu, violet, rose).
//
// Trois pièces, utilisées par `ai_chat_screen.dart` :
//   • [LueurReflexion] — de grands halos en bas de l'écran, dont la teinte
//     tourne PROGRESSIVEMENT dans l'arc-en-ciel et qui respirent ;
//   • [BordureArcEnCiel] — le contour du champ de saisie qui tourne ;
//   • [IndicateurReflexionGemini] — l'étoile qui tourne et les barres
//     traversées d'un reflet, à la place des trois points gris.
//
// ⚠️ SOBRE PAR CONSTRUCTION.
//   • Halos en dégradés radiaux, sans flou plein écran : un flou gaussien
//     sur toute la surface coûterait bien plus que l'effet ne rapporte.
//   • Rien ne tourne une fois la réponse terminée : le minuteur s'arrête
//     quand la lueur a fini de s'éteindre (voir `lueur_gemini_test.dart`).
//   • « Réduire les animations » (accessibilité) : couleurs immobiles.
//   • Appareil modeste : deux halos au lieu de quatre, pas de halo flou
//     autour du champ.
// ============================================================================

// ⚠️ LES NEUF DURÉES DE CE FICHIER NE SONT PAS DES JETONS, ET C'EST
// DÉLIBÉRÉ.
//
// Partout ailleurs dans Droplet, une durée écrite en dur est un défaut :
// l'audit en a compté 232 pour 6 jetons, et c'est ce qui empêche une
// application de « tomber » d'un seul rythme. Ici, les durées ne règlent
// pas une transition d'interface — elles COMPOSENT une animation
// ambiante, comme les tempos d'un morceau. La rotation de 7 secondes, la
// respiration de 3,2 secondes et le retour de 1,1 seconde ne coïncident
// jamais : c'est ce décalage qui fait que la lueur ne se répète pas à
// l'œil. Les ramener à `durationStandard` et `durationAmbient` donnerait
// trois cycles synchrones, donc un clignotement.
//
// Toute nouvelle durée AJOUTÉE ICI doit relever de la même logique. Une
// transition d'interface qui atterrirait dans ce fichier, elle, prend un
// jeton comme partout.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/services/device_profile.dart';

/// Les couleurs de la lueur, dans l'ordre où elles se succèdent.
class PaletteGemini {
  PaletteGemini._();

  static const bleu = Color(0xFF4285F4);
  static const violet = Color(0xFF9B72CB);
  static const rose = Color(0xFFD96570);
  static const rouge = Color(0xFFEA4335);
  static const jaune = Color(0xFFFBBC04);
  static const vert = Color(0xFF34A853);

  static const List<Color> cycle = [bleu, violet, rose, rouge, jaune, vert];

  /// La couleur au point [t] du cycle (période 1) — passage LISSE d'une
  /// couleur à la suivante, et retour au bleu après le vert.
  static Color aPosition(double t) {
    final n = cycle.length;
    final x = ((t % 1.0) + 1.0) % 1.0 * n;
    final i = x.floor() % n;
    final f = x - x.floor();
    final lisse = f * f * (3 - 2 * f);
    return Color.lerp(cycle[i], cycle[(i + 1) % n], lisse)!;
  }
}

bool _mouvementAutorise(BuildContext context) =>
    !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

// ── Lueur de fond ────────────────────────────────────────────────────────

/// Les halos colorés qui s'allument pendant que l'assistant réfléchit.
class LueurReflexion extends StatefulWidget {
  const LueurReflexion({super.key, required this.active});

  /// Vrai du moment où la question part jusqu'à la fin de la réponse.
  final bool active;

  @override
  State<LueurReflexion> createState() => _LueurReflexionState();
}

class _LueurReflexionState extends State<LueurReflexion>
    with TickerProviderStateMixin {
  late final AnimationController _temps = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );
  late final AnimationController _intensite = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    reverseDuration: const Duration(milliseconds: 1100),
  );
  bool _mouvement = true;

  @override
  void initState() {
    super.initState();
    _intensite.addStatusListener((statut) {
      // Éteinte : plus aucune image calculée.
      if (statut == AnimationStatus.dismissed) _temps.stop();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mouvement = _mouvementAutorise(context);
    if (!_mouvement) _temps.stop();
    if (widget.active) _allumer();
  }

  @override
  void didUpdateWidget(LueurReflexion ancien) {
    super.didUpdateWidget(ancien);
    if (widget.active == ancien.active) return;
    widget.active ? _allumer() : _intensite.reverse();
  }

  void _allumer() {
    if (_mouvement && !_temps.isAnimating) _temps.repeat();
    _intensite.forward();
  }

  @override
  void dispose() {
    _temps.dispose();
    _intensite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PeintreLueur(
            temps: _temps,
            intensite: _intensite,
            sombre: Theme.of(context).brightness == Brightness.dark,
            halos: DeviceProfile.menager ? 2 : 4,
          ),
        ),
      ),
    );
  }
}

class _PeintreLueur extends CustomPainter {
  _PeintreLueur({
    required this.temps,
    required this.intensite,
    required this.sombre,
    required this.halos,
  }) : super(repaint: Listenable.merge([temps, intensite]));

  final Animation<double> temps;
  final Animation<double> intensite;
  final bool sombre;
  final int halos;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Curves.easeOut.transform(intensite.value);
    if (a <= 0.001 || size.isEmpty) return;
    final t = temps.value;
    final w = size.width;
    final h = size.height;
    // Respiration : trois pulsations par cycle de couleurs (~2,3 s). Les
    // multiplicateurs de `t` sont ENTIERS : aucune saccade quand le cycle
    // reboucle.
    final respiration = 0.78 + 0.22 * (0.5 + 0.5 * math.sin(2 * math.pi * 3 * t));
    final pinceau = Paint();
    for (var k = 0; k < halos; k++) {
      final phase = k / halos;
      final couleur = PaletteGemini.aPosition(t + phase);
      final centre = Offset(
        w * (0.5 + 0.45 * math.sin(2 * math.pi * (t + phase * 1.7))),
        h * (0.92 - 0.08 * math.cos(2 * math.pi * (2 * t + phase))),
      );
      final rayon = w * (0.72 + 0.14 * math.sin(2 * math.pi * (2 * t + phase * 1.3)));
      final opacite = (sombre ? 0.46 : 0.32) * a * respiration;
      pinceau.shader = RadialGradient(
        colors: [
          couleur.withValues(alpha: opacite),
          couleur.withValues(alpha: opacite * 0.35),
          couleur.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: centre, radius: rayon));
      canvas.drawCircle(centre, rayon, pinceau);
    }
    // Un liseré lumineux tout en bas, comme la lueur de Gemini sur Android.
    final bas = Rect.fromLTWH(0, h - 90, w, 90);
    pinceau.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        PaletteGemini.aPosition(t + 0.5).withValues(alpha: (sombre ? 0.35 : 0.22) * a * respiration),
        PaletteGemini.aPosition(t + 0.5).withValues(alpha: 0),
      ],
    ).createShader(bas);
    canvas.drawRect(bas, pinceau);
  }

  @override
  bool shouldRepaint(_PeintreLueur ancien) =>
      ancien.sombre != sombre || ancien.halos != halos;
}

// ── Bordure du champ de saisie ───────────────────────────────────────────

/// Un contour arc-en-ciel qui tourne autour de [child] tant que [active].
class BordureArcEnCiel extends StatefulWidget {
  const BordureArcEnCiel({
    super.key,
    required this.active,
    required this.rayon,
    required this.child,
    this.epaisseur = 2,
  });

  final bool active;
  final double rayon;
  final double epaisseur;
  final Widget child;

  @override
  State<BordureArcEnCiel> createState() => _BordureArcEnCielState();
}

class _BordureArcEnCielState extends State<BordureArcEnCiel>
    with TickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  late final AnimationController _intensite = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 700),
  );
  bool _mouvement = true;

  @override
  void initState() {
    super.initState();
    _intensite.addStatusListener((statut) {
      if (statut == AnimationStatus.dismissed) _rotation.stop();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mouvement = _mouvementAutorise(context);
    if (!_mouvement) _rotation.stop();
    if (widget.active) _allumer();
  }

  @override
  void didUpdateWidget(BordureArcEnCiel ancien) {
    super.didUpdateWidget(ancien);
    if (widget.active == ancien.active) return;
    widget.active ? _allumer() : _intensite.reverse();
  }

  void _allumer() {
    if (_mouvement && !_rotation.isAnimating) _rotation.repeat();
    _intensite.forward();
  }

  @override
  void dispose() {
    _rotation.dispose();
    _intensite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _PeintreBordure(
        rotation: _rotation,
        intensite: _intensite,
        rayon: widget.rayon,
        epaisseur: widget.epaisseur,
        halo: !DeviceProfile.menager,
      ),
      child: widget.child,
    );
  }
}

class _PeintreBordure extends CustomPainter {
  _PeintreBordure({
    required this.rotation,
    required this.intensite,
    required this.rayon,
    required this.epaisseur,
    required this.halo,
  }) : super(repaint: Listenable.merge([rotation, intensite]));

  final Animation<double> rotation;
  final Animation<double> intensite;
  final double rayon;
  final double epaisseur;
  final bool halo;

  @override
  void paint(Canvas canvas, Size size) {
    final a = intensite.value;
    if (a <= 0.001 || size.isEmpty) return;
    final rect = Offset.zero & size;
    final contour = RRect.fromRectAndRadius(
      rect.deflate(epaisseur / 2),
      Radius.circular(rayon),
    );
    final degrade = SweepGradient(
      colors: [...PaletteGemini.cycle, PaletteGemini.cycle.first],
      transform: GradientRotation(2 * math.pi * rotation.value),
    ).createShader(rect);
    if (halo) {
      canvas.drawRRect(
        contour,
        Paint()
          ..shader = degrade
          ..style = PaintingStyle.stroke
          ..strokeWidth = epaisseur * 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = Colors.white.withValues(alpha: 0.55 * a),
      );
    }
    canvas.drawRRect(
      contour,
      Paint()
        ..shader = degrade
        ..style = PaintingStyle.stroke
        ..strokeWidth = epaisseur
        ..color = Colors.white.withValues(alpha: a),
    );
  }

  @override
  bool shouldRepaint(_PeintreBordure ancien) =>
      ancien.rayon != rayon || ancien.epaisseur != epaisseur || ancien.halo != halo;
}

// ── Étoile et barres de réflexion ────────────────────────────────────────

/// L'étoile à quatre branches, remplie d'un dégradé — qui tourne si [anime].
class EtincelleGemini extends StatefulWidget {
  const EtincelleGemini({super.key, this.taille = 22, this.anime = false});

  final double taille;
  final bool anime;

  @override
  State<EtincelleGemini> createState() => _EtincelleGeminiState();
}

class _EtincelleGeminiState extends State<EtincelleGemini>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tour = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchroniser();
  }

  @override
  void didUpdateWidget(EtincelleGemini ancien) {
    super.didUpdateWidget(ancien);
    _synchroniser();
  }

  void _synchroniser() {
    final tourner = widget.anime && _mouvementAutorise(context);
    if (tourner && !_tour.isAnimating) {
      _tour.repeat();
    } else if (!tourner && _tour.isAnimating) {
      _tour.animateTo(1, duration: const Duration(milliseconds: 500), curve: Curves.easeOut)
          .then((_) => _tour.value = 0);
    }
  }

  @override
  void dispose() {
    _tour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.taille),
        painter: _PeintreEtincelle(_tour),
      ),
    );
  }
}

class _PeintreEtincelle extends CustomPainter {
  _PeintreEtincelle(this.tour) : super(repaint: tour);

  final Animation<double> tour;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(s / 2, s / 2);
    final t = tour.value;
    // Une légère pulsation pendant la rotation.
    final echelle = 1 + 0.08 * math.sin(2 * math.pi * t);
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(2 * math.pi * Curves.easeInOut.transform(t))
      ..scale(echelle)
      ..translate(-c.dx, -c.dy);
    final etoile = Path()
      ..moveTo(c.dx, 0)
      ..quadraticBezierTo(c.dx + s * 0.06, c.dy - s * 0.06, s, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.06, c.dy + s * 0.06, c.dx, s)
      ..quadraticBezierTo(c.dx - s * 0.06, c.dy + s * 0.06, 0, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.06, c.dy - s * 0.06, c.dx, 0)
      ..close();
    canvas.drawPath(
      etoile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [PaletteGemini.bleu, PaletteGemini.violet, PaletteGemini.rose],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreEtincelle ancien) => false;
}

/// L'attente d'une réponse : l'étoile qui tourne, et trois barres traversées
/// d'un reflet bleu-violet-rose.
class IndicateurReflexionGemini extends StatefulWidget {
  const IndicateurReflexionGemini({super.key});

  @override
  State<IndicateurReflexionGemini> createState() => _IndicateurReflexionGeminiState();
}

class _IndicateurReflexionGeminiState extends State<IndicateurReflexionGemini>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reflet = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mouvementAutorise(context)) {
      if (!_reflet.isAnimating) _reflet.repeat();
    } else {
      _reflet
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _reflet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0x33FFFFFF)
        : const Color(0x1A000000);
    const largeurs = [1.0, 0.86, 0.58];
    return Semantics(
      liveRegion: true,
      label: '…',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EtincelleGemini(taille: 24, anime: true),
            const SizedBox(width: 12),
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < largeurs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 6),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size(220 * largeurs[i], 12),
                          painter: _PeintreBarre(_reflet, decalage: i * 0.12, base: base),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeintreBarre extends CustomPainter {
  _PeintreBarre(this.reflet, {required this.decalage, required this.base})
      : super(repaint: reflet);

  final Animation<double> reflet;
  final double decalage;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = ((reflet.value - decalage) % 1.0 + 1.0) % 1.0;
    final barre = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    canvas.drawRRect(
      barre,
      Paint()
        ..shader = LinearGradient(
          colors: [
            base,
            PaletteGemini.bleu.withValues(alpha: 0.85),
            PaletteGemini.violet.withValues(alpha: 0.9),
            PaletteGemini.rose.withValues(alpha: 0.85),
            base,
          ],
          stops: const [0, 0.3, 0.5, 0.7, 1],
          transform: _Glissement(t * 2 - 1),
        ).createShader(rect),
    );
    // Le fond pâle de la barre, sous le reflet.
    canvas.drawRRect(barre, Paint()..color = base);
  }

  @override
  bool shouldRepaint(_PeintreBarre ancien) =>
      ancien.decalage != decalage || ancien.base != base;
}

class _Glissement extends GradientTransform {
  const _Glissement(this.fraction);

  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}
