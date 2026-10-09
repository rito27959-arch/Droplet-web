// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Les fonds de discussion PREMIUM : huit fonds multicolores et animés,
// tous dessinés par UN SEUL shader (`shaders/fond_prisme.frag`).
//
// ── Pourquoi un seul shader ─────────────────────────────────────────────
//
// Les cinq anciens fonds avaient chacun leur shader, et chacun sa propre
// idée de ce qu'est un fond « premium » : bruit fractal, ciel étoilé,
// lave… Résultat : des images sombres et boueuses qui se ressemblaient
// entre elles, et ressemblaient aux dégradés gratuits.
//
// Ici, un fond = cinq couleurs vives + une base + une des quatre
// mises en scène du shader (lueur, maille, soie, prisme). Chaque fond a
// SA palette sombre et SA palette claire : un jaune assombri vire à
// l'olive, un pastel assombri vire au gris — les palettes sombres
// évitent donc ces teintes au lieu de les subir.
//
// ── Ce qui le rend vivant ───────────────────────────────────────────────
//
//   • Le fond dérive lentement (30 images/s, pas plus : c'est un fond).
//   • À chaque message envoyé, les couleurs tournent d'un cran, avec un
//     ressort — le même principe que les dégradés gratuits.
//   • « Réduire les animations » fige le temps ; le cran à l'envoi reste,
//     car c'est une réponse au geste, pas un mouvement d'ambiance.
//
// ⚠️ SUR UN APPAREIL SANS SHADER (`DeviceProfile.sansShader`), le même
// fond est peint une fois, en halos radiaux fixes : les mêmes couleurs,
// sans le coût d'un calcul par pixel à chaque image.
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/device_profile.dart';
import '../../design_system/ouro_motion.dart';

/// Les quatre mises en scène du shader (valeur de `uStyle`).
enum StyleFond { lueur, maille, soie, prisme }

/// Un fond premium.
class FondPremium {
  const FondPremium({
    required this.cle,
    required this.nom,
    required this.style,
    required this.couleursClaires,
    required this.couleursSombres,
    required this.baseClaire,
    required this.baseSombre,
  });

  /// La clé enregistrée dans les réglages.
  final String cle;

  /// Le nom affiché. Un nom propre, comme une couleur de téléphone :
  /// il ne se traduit pas.
  final String nom;

  final StyleFond style;

  /// Cinq couleurs, dans l'ordre où elles se suivent.
  final List<Color> couleursClaires;
  final List<Color> couleursSombres;

  final Color baseClaire;
  final Color baseSombre;

  List<Color> couleurs({required bool sombre}) =>
      sombre ? couleursSombres : couleursClaires;

  Color base({required bool sombre}) => sombre ? baseSombre : baseClaire;
}

class FondsPremium {
  FondsPremium._();

  static const List<FondPremium> tous = [
    FondPremium(
      cle: 'lueur',
      nom: 'Lueur',
      style: StyleFond.lueur,
      couleursClaires: [
        Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899),
        Color(0xFFF59E0B), Color(0xFF22D3EE),
      ],
      couleursSombres: [
        Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899),
        Color(0xFFF97316), Color(0xFF06B6D4),
      ],
      baseClaire: Color(0xFFF4F6FF),
      baseSombre: Color(0xFF05060F),
    ),
    FondPremium(
      cle: 'neon',
      nom: 'Néon',
      style: StyleFond.lueur,
      couleursClaires: [
        Color(0xFFFF2BD6), Color(0xFF7B2CFF), Color(0xFF00E1FF),
        Color(0xFF00FF9C), Color(0xFFFFE14D),
      ],
      couleursSombres: [
        Color(0xFFFF2BD6), Color(0xFF7B2CFF), Color(0xFF00E1FF),
        Color(0xFF00FF9C), Color(0xFFFF2E63),
      ],
      baseClaire: Color(0xFFFBF7FF),
      baseSombre: Color(0xFF040208),
    ),
    FondPremium(
      cle: 'prisme',
      nom: 'Arc-en-ciel',
      style: StyleFond.prisme,
      couleursClaires: [
        Color(0xFFFF4D6D), Color(0xFFFFB547), Color(0xFF3DDC84),
        Color(0xFF34B6FF), Color(0xFF9B6BFF),
      ],
      couleursSombres: [
        Color(0xFFFF3B6B), Color(0xFFFF7A2F), Color(0xFF22C55E),
        Color(0xFF2F9BFF), Color(0xFF8B5CF6),
      ],
      baseClaire: Color(0xFFFFFFFF),
      baseSombre: Color(0xFF07070D),
    ),
    FondPremium(
      cle: 'holo',
      nom: 'Holographique',
      style: StyleFond.prisme,
      couleursClaires: [
        Color(0xFFFF8AD8), Color(0xFF7AA7FF), Color(0xFF5FF2C8),
        Color(0xFFFFE27A), Color(0xFFB18CFF),
      ],
      couleursSombres: [
        Color(0xFFFF5FC8), Color(0xFF5B8CFF), Color(0xFF2EE6C0),
        Color(0xFFA855F7), Color(0xFFFF4D94),
      ],
      baseClaire: Color(0xFFFFFFFF),
      baseSombre: Color(0xFF0A0A14),
    ),
    FondPremium(
      cle: 'aurore',
      nom: 'Aurore',
      style: StyleFond.soie,
      couleursClaires: [
        Color(0xFF22D3EE), Color(0xFF34D399), Color(0xFFA3E635),
        Color(0xFF818CF8), Color(0xFFC084FC),
      ],
      couleursSombres: [
        Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF22C55E),
        Color(0xFF4F46E5), Color(0xFFA855F7),
      ],
      baseClaire: Color(0xFFF2FBF8),
      baseSombre: Color(0xFF030712),
    ),
    FondPremium(
      cle: 'tropique',
      nom: 'Tropique',
      style: StyleFond.soie,
      couleursClaires: [
        Color(0xFFFF5E62), Color(0xFFFF9966), Color(0xFFFF3CAC),
        Color(0xFFFFC837), Color(0xFF8E54E9),
      ],
      couleursSombres: [
        Color(0xFFFF3D5A), Color(0xFFFF7A45), Color(0xFFE91E8C),
        Color(0xFFFF9F1C), Color(0xFF7C3AED),
      ],
      baseClaire: Color(0xFFFFF7F3),
      baseSombre: Color(0xFF0D0610),
    ),
    FondPremium(
      cle: 'nacre',
      nom: 'Nacre',
      style: StyleFond.maille,
      couleursClaires: [
        Color(0xFFFF9ECF), Color(0xFF8FA8FF), Color(0xFF5EE6F0),
        Color(0xFFFFD86B), Color(0xFFB795FF),
      ],
      couleursSombres: [
        Color(0xFFE0529C), Color(0xFF5B6CFF), Color(0xFF1FB5C9),
        Color(0xFF9D5CFF), Color(0xFFFF4DA6),
      ],
      baseClaire: Color(0xFFFFFFFF),
      baseSombre: Color(0xFF0B0B14),
    ),
    FondPremium(
      cle: 'lagon',
      nom: 'Lagon',
      style: StyleFond.maille,
      couleursClaires: [
        Color(0xFF00C6FF), Color(0xFF0052FF), Color(0xFF00E5A0),
        Color(0xFF5B2DFF), Color(0xFF00FFD0),
      ],
      couleursSombres: [
        Color(0xFF00B4FF), Color(0xFF0047FF), Color(0xFF00D68F),
        Color(0xFF5B2DFF), Color(0xFF00E0C0),
      ],
      baseClaire: Color(0xFFF0FBFF),
      baseSombre: Color(0xFF020A14),
    ),
  ];

  /// Les clés des anciens fonds, et ce qui les remplace.
  ///
  /// Quelqu'un qui avait choisi « Nébuleuse » ne doit pas se retrouver
  /// avec un fond uni après la mise à jour : il retrouve l'ambiance la
  /// plus proche. Les anciens fonds payants mènent à des fonds payants,
  /// les gratuits à des gratuits.
  static const Map<String, String> remplacements = {
    'aurora': 'aurore',
    'ocean': 'lagon',
    'nebula': 'lueur',
    'lava': 'tropique',
    'crystal': 'holo',
    'abysse': 'lagon',
    'laterite': 'tropique',
    'nebuleuse': 'lueur',
    'palmeraie': 'aurore',
    'ardoise': 'nacre',
    'crepuscule': 'lilas',
    'foret': 'lagune',
    'braise': 'corail',
  };

  static FondPremium? trouver(String cle) {
    for (final f in tous) {
      if (f.cle == cle) return f;
    }
    return null;
  }

  /// ⚠️ LA SEULE LISTE DES FONDS PAYANTS. La grille de choix, l'écran de
  /// discussion et l'aperçu la consultent tous : une seconde liste finirait
  /// par diverger, et un fond payant offert à tout le monde ne se rattrape
  /// pas.
  static bool estPremium(String cle) => trouver(cle) != null;
}

// ── Chargement du shader ───────────────────────────────────────────────────

class _Programme {
  _Programme._();

  static ui.FragmentProgram? _programme;
  static Future<ui.FragmentProgram?>? _chargement;
  static bool _echec = false;

  static ui.FragmentProgram? get pret => _programme;

  static Future<ui.FragmentProgram?> charger() {
    if (_programme != null || _echec) return Future.value(_programme);
    return _chargement ??= ui.FragmentProgram.fromAsset('shaders/fond_prisme.frag')
        .then<ui.FragmentProgram?>((p) => _programme = p)
        .catchError((Object e) {
      debugPrint('[FondsPremium] shader indisponible : $e');
      _echec = true;
      return null;
    });
  }
}

/// Précharge le shader, pour que le premier fond s'affiche sans attente.
Future<void> prechargerFondsPremium() async {
  if (DeviceProfile.sansShader) return;
  await _Programme.charger();
}

/// Règle les uniformes du shader. L'ordre suit exactement celui du
/// fichier `.frag` — un décalage d'un seul indice mélangerait tout.
void _regler(
  ui.FragmentShader shader, {
  required Size taille,
  required double temps,
  required double phase,
  required bool sombre,
  required FondPremium fond,
}) {
  var i = 0;
  shader
    ..setFloat(i++, taille.width)
    ..setFloat(i++, taille.height)
    ..setFloat(i++, temps)
    ..setFloat(i++, phase)
    ..setFloat(i++, sombre ? 1 : 0)
    ..setFloat(i++, fond.style.index.toDouble());
  for (final c in fond.couleurs(sombre: sombre)) {
    shader
      ..setFloat(i++, c.r)
      ..setFloat(i++, c.g)
      ..setFloat(i++, c.b);
  }
  final base = fond.base(sombre: sombre);
  shader
    ..setFloat(i++, base.r)
    ..setFloat(i++, base.g)
    ..setFloat(i++, base.b);
}

// ── Le fond animé d'une conversation ───────────────────────────────────────

class FondPremiumAnime extends StatefulWidget {
  const FondPremiumAnime({
    super.key,
    required this.fond,
    this.tick = 0,
    this.animer = true,
  });

  final FondPremium fond;

  /// Compteur de messages envoyés : chaque incrément fait tourner les
  /// couleurs d'un cran.
  final int tick;

  /// `false` : une image fixe (vignettes).
  final bool animer;

  @override
  State<FondPremiumAnime> createState() => _FondPremiumAnimeState();
}

class _FondPremiumAnimeState extends State<FondPremiumAnime>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final ValueNotifier<double> _temps = ValueNotifier(0);
  late final AnimationController _cran;
  ui.FragmentShader? _shader;
  double _phaseDepart = 0;
  double _phaseArrivee = 0;
  Duration _derniere = Duration.zero;

  /// Un décalage de départ propre à chaque fond : deux fonds du même
  /// style ne démarrent pas sur la même image.
  late final double _origine = (widget.fond.cle.hashCode % 97).toDouble() + 6;

  static const _intervalle = Duration(milliseconds: 33);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _temps.value = _origine;
    _phaseDepart = _phaseArrivee = widget.tick.toDouble();
    _cran = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (!DeviceProfile.sansShader) _preparer();
  }

  Future<void> _preparer() async {
    final programme = _Programme.pret ?? await _Programme.charger();
    if (!mounted || programme == null) return;
    setState(() => _shader = programme.fragmentShader());
    if (widget.animer) {
      _ticker = createTicker(_battement)..start();
    }
  }

  void _battement(Duration ecoule) {
    if (ecoule - _derniere < _intervalle) return;
    final pas = ecoule - _derniere;
    _derniere = ecoule;
    // « Réduire les animations », ou téléphone qui chauffe : le temps
    // s'arrête, le fond reste sur sa dernière image.
    if (!OuroMotion.ambiantAutoriseGlobal) return;
    _temps.value += pas.inMicroseconds / 1e6;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ticker = _ticker;
    if (ticker == null) return;
    if (state == AppLifecycleState.resumed) {
      if (!ticker.isActive) {
        _derniere = Duration.zero;
        ticker.start();
      }
    } else if (ticker.isActive) {
      ticker.stop();
    }
  }

  @override
  void didUpdateWidget(FondPremiumAnime old) {
    super.didUpdateWidget(old);
    if (widget.tick != old.tick) {
      _phaseDepart = _phase;
      _phaseArrivee = widget.tick.toDouble();
      _cran.forward(from: 0);
    }
  }

  double get _phase {
    final t = Curves.easeOutBack.transform(_cran.value);
    return _phaseDepart + (_phaseArrivee - _phaseDepart) * t;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _cran.dispose();
    _temps.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final shader = _shader;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: shader == null
            ? _HalosPainter(widget.fond, sombre)
            : _ShaderPainter(
                shader: shader,
                fond: widget.fond,
                sombre: sombre,
                temps: _temps,
                phase: () => _phase,
                repaint: Listenable.merge([_temps, _cran]),
              ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.fond,
    required this.sombre,
    required this.temps,
    required this.phase,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final ui.FragmentShader shader;
  final FondPremium fond;
  final bool sombre;
  final ValueNotifier<double> temps;
  final double Function() phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _regler(shader, taille: size, temps: temps.value, phase: phase(), sombre: sombre, fond: fond);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderPainter old) =>
      old.shader != shader || old.fond != fond || old.sombre != sombre;
}

/// Le repli sans shader : la base, puis un halo par couleur.
class _HalosPainter extends CustomPainter {
  _HalosPainter(this.fond, this.sombre);

  final FondPremium fond;
  final bool sombre;

  static const _positions = [
    Offset(0.15, 0.85), Offset(0.85, 0.95), Offset(0.9, 0.35),
    Offset(0.1, 0.4), Offset(0.55, 0.65),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fond.base(sombre: sombre));
    final couleurs = fond.couleurs(sombre: sombre);
    for (var i = 0; i < couleurs.length; i++) {
      var c = couleurs[i];
      c = sombre
          ? Color.lerp(Colors.black, c, 0.75)!
          : Color.lerp(c, Colors.white, 0.4)!;
      final p = _positions[i];
      final centre = Offset(p.dx * size.width, p.dy * size.height);
      final rayon = size.longestSide * 0.55;
      canvas.drawCircle(
        centre,
        rayon,
        Paint()
          ..shader = ui.Gradient.radial(centre, rayon, [
            c.withValues(alpha: 0.9),
            c.withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(_HalosPainter old) => old.fond != fond || old.sombre != sombre;
}

/// Une vignette FIXE d'un fond premium, pour la grille de choix.
///
/// Huit fonds animés en même temps dans une grille coûteraient huit
/// shaders plein régime pour une page de réglages : la vignette est
/// peinte une fois, et le mouvement se découvre dans l'aperçu.
class VignetteFondPremium extends StatelessWidget {
  const VignetteFondPremium({super.key, required this.fond});

  final FondPremium fond;

  @override
  Widget build(BuildContext context) =>
      FondPremiumAnime(fond: fond, animer: false);
}
