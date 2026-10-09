// ============================================================================
// LES OUTILS DE L'ÉDITEUR PHOTO — rail, filtres, réglages, textes, export.
// ----------------------------------------------------------------------------
// Pensés comme ceux des éditeurs de référence (CapCut, Photos d'iOS) :
//
//   • un RAIL d'outils étiquetés en bas, qu'on reconnaît sans deviner ;
//   • des FILTRES en vignettes vivantes — chacune montre VOTRE photo —, et
//     une intensité réglable ;
//   • des RÉGLAGES sur une RÈGLE graduée : un cran se sent sous le doigt tous
//     les dix points, et zéro « aimante » la valeur pour y revenir sans
//     viser ; un double tap remet à zéro ;
//   • des TEXTES qu'on déplace, agrandit et tourne à deux doigts, qu'on
//     retouche d'un tap ;
//   • un EXPORT à la résolution de la photo (jusqu'à 3 072 px de côté), pas à
//     celle de l'écran : ce qu'on voit est ce qui part, en net.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import 'filtres_photo.dart';

// ─────────────────────────────────────────────────────────────
//  LE RAIL D'OUTILS
// ─────────────────────────────────────────────────────────────

class OutilRail {
  const OutilRail({required this.icone, required this.libelle, required this.surTap, this.actif = false});

  final IconData icone;
  final String libelle;
  final VoidCallback surTap;
  final bool actif;
}

class RailOutils extends StatelessWidget {
  const RailOutils({super.key, required this.outils});

  final List<OutilRail> outils;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: outils.length,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (context, i) => _BoutonRail(outil: outils[i]),
      ),
    );
  }
}

class _BoutonRail extends StatefulWidget {
  const _BoutonRail({required this.outil});

  final OutilRail outil;

  @override
  State<_BoutonRail> createState() => _BoutonRailState();
}

class _BoutonRailState extends State<_BoutonRail> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.outil;
    final couleur = o.actif ? OuroColors.accent : Colors.white;
    return Semantics(
      button: true,
      selected: o.actif,
      label: o.libelle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _appui = true),
        onTapUp: (_) => setState(() => _appui = false),
        onTapCancel: () => setState(() => _appui = false),
        onTap: () {
          HapticFeedback.selectionClick();
          o.surTap();
        },
        child: AnimatedOpacity(
          opacity: _appui ? 0.45 : 1,
          duration: Duration(milliseconds: _appui ? 0 : 180),
          child: SizedBox(
            width: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: o.actif ? OuroColors.accent.withValues(alpha: 0.18) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(o.icone, color: couleur, size: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  o.libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: couleur.withValues(alpha: o.actif ? 1 : 0.85),
                    fontSize: 11,
                    fontWeight: o.actif ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LA RÈGLE GRADUÉE
// ─────────────────────────────────────────────────────────────

class RegleReglage extends StatefulWidget {
  const RegleReglage({
    super.key,
    required this.valeur,
    required this.surChangement,
    this.surDebut,
    this.min = -1,
    this.max = 1,
  });

  final double valeur;
  final ValueChanged<double> surChangement;
  final VoidCallback? surDebut;
  final double min;
  final double max;

  @override
  State<RegleReglage> createState() => _RegleReglageState();
}

class _RegleReglageState extends State<RegleReglage> {
  late int _cran = (widget.valeur * 10).round();

  void _changer(double brute) {
    var v = brute.clamp(widget.min, widget.max).toDouble();
    // Zéro « aimante » : on y revient sans avoir à viser.
    if (widget.min < 0 && v.abs() < 0.025) v = 0;
    final cran = (v * 10).round();
    if (cran != _cran) {
      if (cran == 0 && widget.min < 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
      _cran = cran;
    }
    widget.surChangement(v);
  }

  @override
  Widget build(BuildContext context) {
    final affichee = (widget.valeur * 100).round();
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = contraintes.maxWidth;
        final plage = widget.max - widget.min;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => widget.surDebut?.call(),
          onHorizontalDragUpdate: (d) => _changer(widget.valeur + d.delta.dx / (largeur * 0.8) * plage),
          onDoubleTap: () {
            widget.surDebut?.call();
            _changer(widget.min < 0 ? 0 : widget.max);
          },
          child: SizedBox(
            height: 58,
            child: Column(
              children: [
                Text(
                  widget.min < 0 && affichee > 0 ? '+$affichee' : '$affichee',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: CustomPaint(
                    size: Size(largeur, 30),
                    painter: _PeintreRegle(
                      valeur: widget.valeur,
                      min: widget.min,
                      max: widget.max,
                      accent: OuroColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeintreRegle extends CustomPainter {
  _PeintreRegle({required this.valeur, required this.min, required this.max, required this.accent});

  final double valeur;
  final double min;
  final double max;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.width / 2;
    final plage = max - min;
    final pas = size.width * 0.8 / (plage / 0.05);
    final trait = Paint()..strokeCap = StrokeCap.round;
    for (var t = min; t <= max + 1e-9; t += 0.05) {
      final x = centre + (t - valeur) / 0.05 * pas;
      if (x < -2 || x > size.width + 2) continue;
      final majeur = ((t * 100).round() % 25) == 0;
      final distance = ((x - centre).abs() / centre).clamp(0.0, 1.0);
      trait
        ..color = Colors.white.withValues(alpha: (majeur ? 0.7 : 0.35) * (1 - distance * 0.7))
        ..strokeWidth = majeur ? 1.6 : 1;
      final h = majeur ? 14.0 : 8.0;
      canvas.drawLine(Offset(x, size.height / 2 - h / 2), Offset(x, size.height / 2 + h / 2), trait);
    }
    // Le repère de zéro, puis l'aiguille.
    if (min < 0) {
      final xZero = centre + (0 - valeur) / 0.05 * pas;
      canvas.drawCircle(Offset(xZero, size.height / 2 + 12), 2, Paint()..color = Colors.white70);
    }
    canvas.drawLine(
      Offset(centre, size.height / 2 - 12),
      Offset(centre, size.height / 2 + 12),
      Paint()
        ..color = accent
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PeintreRegle ancien) => ancien.valeur != valeur || ancien.accent != accent;
}

// ─────────────────────────────────────────────────────────────
//  LES FILTRES
// ─────────────────────────────────────────────────────────────

class BandeFiltres extends StatelessWidget {
  const BandeFiltres({
    super.key,
    required this.image,
    required this.actif,
    required this.intensite,
    required this.surFiltre,
    required this.surIntensite,
    required this.surDebutIntensite,
  });

  /// L'image de la photo, en petit (vignettes).
  final ImageProvider image;
  final FiltrePhoto actif;
  final double intensite;
  final ValueChanged<FiltrePhoto> surFiltre;
  final ValueChanged<double> surIntensite;
  final VoidCallback surDebutIntensite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: actif.original
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 6),
                  child: RegleReglage(
                    valeur: intensite,
                    min: 0,
                    max: 1,
                    surDebut: surDebutIntensite,
                    surChangement: surIntensite,
                  ),
                ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtresPhoto.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final f = filtresPhoto[i];
              final choisi = f.id == actif.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  surFiltre(f);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 62,
                      height: 62,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: choisi ? OuroColors.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(f.matrice),
                          child: Image(image: image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f.original ? l10n.edOriginal : f.nom,
                      style: TextStyle(
                        color: choisi ? OuroColors.accent : Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: choisi ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES RÉGLAGES
// ─────────────────────────────────────────────────────────────

class PanneauReglages extends StatelessWidget {
  const PanneauReglages({
    super.key,
    required this.reglages,
    required this.actif,
    required this.surChoix,
    required this.surValeur,
    required this.surDebut,
  });

  final Map<Reglage, double> reglages;
  final Reglage actif;
  final ValueChanged<Reglage> surChoix;
  final void Function(Reglage reglage, double valeur) surValeur;
  final VoidCallback surDebut;

  static IconData icone(Reglage r) => switch (r) {
        Reglage.luminosite => Icons.wb_sunny_outlined,
        Reglage.contraste => Icons.contrast_rounded,
        Reglage.saturation => Icons.water_drop_outlined,
        Reglage.chaleur => Icons.thermostat_rounded,
        Reglage.vignette => Icons.vignette_outlined,
      };

  static String libelle(AppLocalizations l10n, Reglage r) => switch (r) {
        Reglage.luminosite => l10n.edBrightness,
        Reglage.contraste => l10n.edContrast,
        Reglage.saturation => l10n.edSaturation,
        Reglage.chaleur => l10n.edWarmth,
        Reglage.vignette => l10n.edVignette,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vignette = actif == Reglage.vignette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: RegleReglage(
            key: ValueKey(actif),
            valeur: reglages[actif] ?? 0,
            min: vignette ? 0 : -1,
            max: 1,
            surDebut: surDebut,
            surChangement: (v) => surValeur(actif, v),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 58,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final r in Reglage.values)
                _PastilleReglage(
                  icone: icone(r),
                  libelle: libelle(l10n, r),
                  choisi: r == actif,
                  modifie: (reglages[r] ?? 0) != 0,
                  surTap: () => surChoix(r),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastilleReglage extends StatelessWidget {
  const _PastilleReglage({
    required this.icone,
    required this.libelle,
    required this.choisi,
    required this.modifie,
    required this.surTap,
  });

  final IconData icone;
  final String libelle;
  final bool choisi;
  final bool modifie;
  final VoidCallback surTap;

  @override
  Widget build(BuildContext context) {
    final couleur = choisi ? OuroColors.accent : Colors.white.withValues(alpha: 0.85);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        surTap();
      },
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icone, color: couleur, size: 22),
                // Un point signale un réglage déjà modifié.
                if (modifie)
                  Positioned(
                    right: -5,
                    top: -2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: OuroColors.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: couleur, fontSize: 11, fontWeight: choisi ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le voile de vignette, identique à l'écran et à l'export.
RadialGradient degradeVignette(double force) => RadialGradient(
      radius: 0.85,
      stops: const [0.55, 1],
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.62 * force)],
    );

// ─────────────────────────────────────────────────────────────
//  LES TEXTES
// ─────────────────────────────────────────────────────────────

class CalqueTexte {
  CalqueTexte({
    required this.id,
    required this.texte,
    required this.couleur,
    this.fond = false,
    this.style = 0,
    this.position = const Offset(0.5, 0.5),
    this.echelle = 1,
    this.rotation = 0,
  });

  /// La taille du texte à l'écran, avant mise à l'échelle.
  static const double tailleBase = 30;

  final int id;
  String texte;
  Color couleur;
  bool fond;
  int style;

  /// Le centre du texte, en fraction de l'image (0,5 ; 0,5 = au milieu).
  Offset position;
  double echelle;
  double rotation;

  CalqueTexte copie() => CalqueTexte(
        id: id,
        texte: texte,
        couleur: couleur,
        fond: fond,
        style: style,
        position: position,
        echelle: echelle,
        rotation: rotation,
      );

  /// La couleur du texte posé sur un fond de sa couleur.
  Color get couleurSurFond => couleur.computeLuminance() > 0.55 ? Colors.black : Colors.white;

  TextStyle styleTexte(double taille) {
    final base = switch (style) {
      1 => TextStyle(fontSize: taille, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, height: 1.15),
      2 => TextStyle(fontSize: taille * 0.82, fontWeight: FontWeight.w700, letterSpacing: taille * 0.08, height: 1.2),
      _ => TextStyle(fontSize: taille, fontWeight: FontWeight.w800, height: 1.12),
    };
    return base.copyWith(
      color: fond ? couleurSurFond : couleur,
      shadows: fond ? null : const [Shadow(blurRadius: 8, color: Color(0x73000000))],
    );
  }

  String get texteAffiche => style == 2 ? texte.toUpperCase() : texte;
}

/// Les textes posés sur la photo, qu'on déplace, agrandit et tourne à deux
/// doigts, et qu'on retouche d'un tap.
class CoucheTextes extends StatelessWidget {
  const CoucheTextes({
    super.key,
    required this.calques,
    required this.rectImage,
    required this.surTap,
    required this.surDebutGeste,
    required this.surChangement,
  });

  final List<CalqueTexte> calques;
  final Rect rectImage;
  final ValueChanged<CalqueTexte> surTap;
  final VoidCallback surDebutGeste;
  final VoidCallback surChangement;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final c in calques)
          _CalqueInteractif(
            key: ValueKey(c.id),
            calque: c,
            rectImage: rectImage,
            surTap: () => surTap(c),
            surDebutGeste: surDebutGeste,
            surChangement: surChangement,
          ),
      ],
    );
  }
}

class _CalqueInteractif extends StatefulWidget {
  const _CalqueInteractif({
    super.key,
    required this.calque,
    required this.rectImage,
    required this.surTap,
    required this.surDebutGeste,
    required this.surChangement,
  });

  final CalqueTexte calque;
  final Rect rectImage;
  final VoidCallback surTap;
  final VoidCallback surDebutGeste;
  final VoidCallback surChangement;

  @override
  State<_CalqueInteractif> createState() => _CalqueInteractifState();
}

class _CalqueInteractifState extends State<_CalqueInteractif> {
  double _echelleDepart = 1;
  double _rotationDepart = 0;

  @override
  Widget build(BuildContext context) {
    final c = widget.calque;
    final r = widget.rectImage;
    final centre = Offset(r.left + c.position.dx * r.width, r.top + c.position.dy * r.height);
    return Positioned(
      left: centre.dx,
      top: centre.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.surTap,
          onScaleStart: (_) {
            _echelleDepart = c.echelle;
            _rotationDepart = c.rotation;
            widget.surDebutGeste();
          },
          onScaleUpdate: (d) {
            c
              ..position = Offset(
                (c.position.dx + d.focalPointDelta.dx / r.width).clamp(0.0, 1.0),
                (c.position.dy + d.focalPointDelta.dy / r.height).clamp(0.0, 1.0),
              )
              ..echelle = (_echelleDepart * d.scale).clamp(0.35, 6.0)
              ..rotation = _rotationDepart + d.rotation;
            widget.surChangement();
          },
          child: Transform.rotate(
            angle: c.rotation,
            child: Transform.scale(
              scale: c.echelle,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.width * 0.9),
                child: RenduCalque(calque: c, taille: CalqueTexte.tailleBase),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RenduCalque extends StatelessWidget {
  const RenduCalque({super.key, required this.calque, required this.taille});

  final CalqueTexte calque;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final texte = Text(
      calque.texteAffiche,
      textAlign: TextAlign.center,
      style: calque.styleTexte(taille),
    );
    if (!calque.fond) return texte;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: taille * 0.4, vertical: taille * 0.18),
      decoration: BoxDecoration(
        color: calque.couleur,
        borderRadius: BorderRadius.circular(taille * 0.34),
      ),
      child: texte,
    );
  }
}

/// Le résultat de la saisie d'un texte.
class ResultatTexte {
  const ResultatTexte(this.calque, {this.supprime = false});

  final CalqueTexte calque;
  final bool supprime;
}

const List<Color> couleursTexte = [
  Colors.white,
  Colors.black,
  Color(0xFFFF4D6D),
  Color(0xFFFF9F43),
  Color(0xFFFFD43B),
  Color(0xFF51CF66),
  Color(0xFF4DABF7),
  Color(0xFF9775FA),
];

/// La saisie d'un texte, en plein écran sur la photo assombrie.
Future<ResultatTexte?> saisirTexte(BuildContext context, {CalqueTexte? existant, required int nouvelId}) {
  return showGeneralDialog<ResultatTexte>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, _) => _SaisieTexte(existant: existant, nouvelId: nouvelId),
    transitionBuilder: (context, animation, _, enfant) => FadeTransition(opacity: animation, child: enfant),
  );
}

class _SaisieTexte extends StatefulWidget {
  const _SaisieTexte({required this.existant, required this.nouvelId});

  final CalqueTexte? existant;
  final int nouvelId;

  @override
  State<_SaisieTexte> createState() => _SaisieTexteState();
}

class _SaisieTexteState extends State<_SaisieTexte> {
  late final CalqueTexte _calque = widget.existant?.copie() ??
      CalqueTexte(id: widget.nouvelId, texte: '', couleur: Colors.white);
  late final TextEditingController _champ = TextEditingController(text: _calque.texte);

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  void _valider() {
    _calque.texte = _champ.text;
    Navigator.of(context).pop(ResultatTexte(_calque, supprime: _champ.text.trim().isEmpty));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                if (widget.existant != null)
                  TextButton(
                    style: TextButton.styleFrom(overlayColor: Colors.transparent),
                    onPressed: () => Navigator.of(context).pop(ResultatTexte(_calque, supprime: true)),
                    child: Text(l10n.edDelete, style: TextStyle(color: OuroColors.systemRed, fontWeight: FontWeight.w600)),
                  ),
                const Spacer(),
                OuroIconButton(
                  tooltip: l10n.edStyle,
                  onPressed: () => setState(() => _calque.style = (_calque.style + 1) % 3),
                  icon: const Icon(Icons.text_format_rounded, color: Colors.white, size: 28),
                ),
                OuroIconButton(
                  tooltip: l10n.edBackground,
                  onPressed: () => setState(() => _calque.fond = !_calque.fond),
                  icon: Icon(
                    _calque.fond ? Icons.format_color_fill_rounded : Icons.format_color_text_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(overlayColor: Colors.transparent),
                  onPressed: _valider,
                  child: Text(l10n.edDone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicWidth(
                    child: Container(
                      padding: _calque.fond
                          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                          : EdgeInsets.zero,
                      decoration: _calque.fond
                          ? BoxDecoration(color: _calque.couleur, borderRadius: BorderRadius.circular(10))
                          : null,
                      child: TextField(
                        controller: _champ,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        cursorColor: _calque.fond ? _calque.couleurSurFond : _calque.couleur,
                        style: _calque.styleTexte(CalqueTexte.tailleBase),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.edTextHint,
                          hintStyle: _calque
                              .styleTexte(CalqueTexte.tailleBase)
                              .copyWith(color: Colors.white.withValues(alpha: 0.45), shadows: const []),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in couleursTexte)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _calque.couleur = c);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _calque.couleur == c ? Colors.white : Colors.white38,
                            width: _calque.couleur == c ? 3 : 1.5,
                          ),
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

// ─────────────────────────────────────────────────────────────
//  L'EXPORT
// ─────────────────────────────────────────────────────────────

/// Compose la photo retouchée à sa propre résolution (plafonnée à 3 072 px
/// de côté) : filtre et réglages, vignette, puis textes, placés et mis à
/// l'échelle comme à l'écran.
Future<ui.Image> composerRetouche({
  required ui.Image source,
  required Matrice matrice,
  required double vignette,
  required List<CalqueTexte> textes,
  required double largeurAffichee,
  TextDirection direction = TextDirection.ltr,
}) async {
  final reduction = math.min(1.0, 3072 / math.max(source.width, source.height));
  final w = (source.width * reduction).roundToDouble();
  final h = (source.height * reduction).roundToDouble();
  final cadre = Rect.fromLTWH(0, 0, w, h);
  final enregistreur = ui.PictureRecorder();
  final toile = Canvas(enregistreur, cadre);

  toile.drawImageRect(
    source,
    Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
    cadre,
    Paint()
      ..colorFilter = ColorFilter.matrix(matrice)
      ..filterQuality = FilterQuality.high,
  );
  if (vignette > 0) {
    toile.drawRect(cadre, Paint()..shader = degradeVignette(vignette).createShader(cadre));
  }

  // Un point à l'écran vaut `facteur` pixels dans l'image exportée.
  final facteur = w / (largeurAffichee <= 0 ? w : largeurAffichee);
  for (final c in textes) {
    final taille = CalqueTexte.tailleBase * facteur;
    final peintre = TextPainter(
      text: TextSpan(text: c.texteAffiche, style: c.styleTexte(taille)),
      textAlign: TextAlign.center,
      textDirection: direction,
    )..layout(maxWidth: w * 0.9);
    toile
      ..save()
      ..translate(c.position.dx * w, c.position.dy * h)
      ..rotate(c.rotation)
      ..scale(c.echelle);
    if (c.fond) {
      final px = taille * 0.4;
      final py = taille * 0.18;
      toile.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: peintre.width + px * 2, height: peintre.height + py * 2),
          Radius.circular(taille * 0.34),
        ),
        Paint()..color = c.couleur,
      );
    }
    peintre.paint(toile, Offset(-peintre.width / 2, -peintre.height / 2));
    toile.restore();
    peintre.dispose();
  }

  final image = await enregistreur.endRecording().toImage(w.round(), h.round());
  return image;
}
