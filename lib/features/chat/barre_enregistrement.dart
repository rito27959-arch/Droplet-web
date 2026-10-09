// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA RANGÉE QUI REMPLACE LE CHAMP DE SAISIE PENDANT QU'ON ENREGISTRE — le
// chrono, l'invite « glisser pour annuler », et les pastilles de verre
// (« vue unique », « retourner la caméra ») posées au-dessus du cadenas.
//
// ── CE QUI SE JOUE ICI, ET QUI N'EST PAS DÉCORATIF ────────────────────
//
// Pendant un enregistrement, l'utilisateur ne regarde rien : il parle. Ce
// qui doit lui parvenir du coin de l'œil, c'est QUE ÇA TOURNE et COMMENT
// EN SORTIR. D'où trois choses, et trois seulement : un chrono qui avance
// visiblement, une direction pour annuler, un moyen de lâcher le doigt.
//
// ── LES MESURES ───────────────────────────────────────────────────────
//
// Relevées dans le code source de Telegram pour Android
// (`ChatActivityEnterView.java` : `TimerView` l.14274, `SlideTextView`
// l.13987, la pastille « once » l.1682-1693). Chaque constante porte sa
// ligne d'origine. Rien n'est recopié — c'est du Java qui peint sur un
// `Canvas`, il n'y a pas une ligne transposable.
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';

// ══ LE CHRONO ═══════════════════════════════════════════════════════════

/// Le temps écoulé, au centième de seconde, dont chaque chiffre est
/// REMPLACÉ et non réécrit.
///
/// ⚠️ POURQUOI REMPLACER CHIFFRE PAR CHIFFRE PLUTÔT QUE REDESSINER LE
/// TOUT. Les centièmes défilent à cent changements par seconde. Redessiner
/// la chaîne entière fait vibrer AUSSI les minutes et les secondes, qui
/// elles ne bougent pas : l'ensemble tremble, et le regard y revient sans
/// cesse alors qu'il n'a rien à y lire. En ne remplaçant que ce qui change,
/// les centièmes s'agitent dans leur coin et le reste tient en place.
class ChronoEnregistrement extends StatefulWidget {
  const ChronoEnregistrement({
    super.key,
    required this.debut,
    this.enPause = false,
    this.couleur,
  });

  /// L'instant de départ. Le chrono se calcule par différence : il ne
  /// compte pas les images, et ne dérive donc pas.
  final DateTime debut;

  final bool enPause;
  final Color? couleur;

  /// Le glissement vertical d'un chiffre remplacé. (CAEV.java:14295)
  static const double distanceRemplacement = 15;

  /// La durée du remplacement. (CAEV.java:14439)
  static const Duration dureeRemplacement = Duration(milliseconds: 116);

  @override
  State<ChronoEnregistrement> createState() => _ChronoEnregistrementState();
}

class _ChronoEnregistrementState extends State<ChronoEnregistrement> {
  Timer? _horloge;
  String _texte = '0:00,00';

  @override
  void initState() {
    super.initState();
    // ⚠️ 1/60 DE SECONDE, PAS 1/100. Afficher des centièmes ne veut pas
    // dire les calculer cent fois par seconde : l'écran n'en montre que
    // soixante, et les vingt relevés de trop sont vingt reconstructions
    // de texte jetées. Deux centièmes consécutifs sautent parfois — on ne
    // les aurait pas vus.
    _horloge = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || widget.enPause) return;
      final t = _format(DateTime.now().difference(widget.debut));
      if (t != _texte) setState(() => _texte = t);
    });
  }

  @override
  void dispose() {
    _horloge?.cancel();
    super.dispose();
  }

  static String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    final c = (d.inMilliseconds ~/ 10) % 100;
    return '$m:${s.toString().padLeft(2, '0')},${c.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final style = OuroTypography.subheadline.copyWith(
      color: widget.couleur ?? OuroColors.label,
      fontWeight: FontWeight.w600,
      // ⚠️ CHIFFRES À CHASSE FIXE. Sans ça, un « 1 » est plus étroit qu'un
      // « 8 » et toute la ligne se décale à chaque centième : le chrono
      // gigote latéralement, ce qui est exactement ce qu'on cherchait à
      // éviter en ne remplaçant que les chiffres qui changent.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _texte.length; i++)
          _Chiffre(
            key: ValueKey(i),
            caractere: _texte[i],
            style: style,
          ),
      ],
    );
  }
}

/// Un caractère du chrono, qui glisse vers le haut quand il change.
class _Chiffre extends StatelessWidget {
  const _Chiffre({super.key, required this.caractere, required this.style});

  final String caractere;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    // ⚠️ `ClipRect` AUTOUR DE CHAQUE CHIFFRE — c'était le « 7 » et le « 8 »
    // fantômes qu'on voyait flotter au-dessus et au-dessous du chrono sur
    // la capture. Le `clipBehavior` du `Stack` ci-dessous ne suffit PAS :
    // il ne découpe que ce qui déborde à la MISE EN PAGE, or le chiffre
    // sortant déborde par une TRANSLATION de peinture (`SlideTransition`),
    // que le `Stack` ne voit pas. Seul un `ClipRect` découpe la peinture.
    // Telegram fait pareil : son `TimerView` découpe le canevas à sa
    // propre hauteur avant de dessiner les chiffres qui défilent.
    return ClipRect(
      child: AnimatedSwitcher(
      duration: ChronoEnregistrement.dureeRemplacement,
      // ⚠️ `layoutBuilder` PERSONNALISÉ. Celui par défaut empile l'ancien
      // et le nouveau dans un `Stack` centré qui prend la taille du plus
      // grand : pendant les 116 ms, la largeur du chiffre varie, et la
      // ligne entière respire. Ici le sortant est posé SANS compter dans
      // la mesure.
      layoutBuilder: (actuel, anciens) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          ...anciens.map((e) => Positioned.fill(child: Center(child: e))),
          if (actuel != null) actuel,
        ],
      ),
      transitionBuilder: (enfant, animation) {
        final sortant = animation.status == AnimationStatus.reverse;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            // Le nouveau monte depuis le bas, l'ancien continue vers le
            // haut : les deux vont dans le même sens, comme les rouleaux
            // d'un compteur mécanique.
            position: Tween<Offset>(
              begin: Offset(0, sortant ? -0.6 : 0.6),
              end: Offset.zero,
            ).animate(animation),
            child: enfant,
          ),
        );
      },
      child: Text(caractere, key: ValueKey(caractere), style: style),
      ),
    );
  }
}

// ══ GLISSER POUR ANNULER ════════════════════════════════════════════════

/// L'invite « ‹ Glisser pour annuler », qui suit le doigt et s'efface à
/// mesure qu'on approche du seuil — remplacée, une fois verrouillé, par un
/// vrai bouton ANNULER.
///
/// ⚠️ LE CHEVRON OSCILLE, ET SEULEMENT QUAND ON N'A PAS ENCORE BOUGÉ.
/// C'est le détail qui fait la différence entre « on m'indique une
/// direction » et « on m'a écrit une phrase ». Dès que le doigt part
/// vraiment, l'oscillation s'arrête : elle a fait son travail, et
/// continuer à s'agiter pendant que l'utilisateur agit devient du bruit.
/// (CAEV.java:14186-14196)
class GlisserPourAnnuler extends StatefulWidget {
  const GlisserPourAnnuler({
    super.key,
    required this.progression,
    required this.verrouille,
    required this.texte,
    required this.texteAnnuler,
    required this.onAnnuler,
  });

  /// 1 = rien de glissé, 0 = seuil d'annulation atteint.
  final double progression;

  final bool verrouille;
  final String texte;
  final String texteAnnuler;
  final VoidCallback onAnnuler;

  /// Amplitude de l'oscillation. (CAEV.java:14186)
  static const double amplitudeOscillation = 6;

  /// 3 points toutes les 250 ms → une aller-retour complet en ~1 s.
  /// (CAEV.java:14195)
  static const Duration periodeOscillation = Duration(milliseconds: 1000);

  /// Au-delà de cette progression, le chevron oscille ; en dessous, le
  /// doigt a visiblement démarré. (CAEV.java:14188)
  static const double seuilOscillation = 0.8;

  @override
  State<GlisserPourAnnuler> createState() => _GlisserPourAnnulerState();
}

class _GlisserPourAnnulerState extends State<GlisserPourAnnuler>
    with SingleTickerProviderStateMixin {
  late final AnimationController _oscillation = AnimationController(
    vsync: this,
    duration: GlisserPourAnnuler.periodeOscillation,
  )..repeat();

  @override
  void dispose() {
    _oscillation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.verrouille) {
      return TextButton(
        onPressed: widget.onAnnuler,
        child: Text(
          widget.texteAnnuler.toUpperCase(),
          style: OuroTypography.subheadline.copyWith(
            color: OuroColors.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    final p = widget.progression.clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _oscillation,
      builder: (context, _) {
        // Un va-et-vient doux, pas un aller-retour anguleux.
        final balance = p > GlisserPourAnnuler.seuilOscillation
            ? math.sin(_oscillation.value * 2 * math.pi) *
                GlisserPourAnnuler.amplitudeOscillation
            : 0.0;
        return Opacity(
          // ⚠️ L'INVITE S'EFFACE À MESURE QU'ON GLISSE, et c'est le seul
          // retour qui dit « ça marche ». Un texte qui reste à pleine
          // encre pendant qu'on tire dessus laisse croire qu'il ne se
          // passe rien.
          opacity: p,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(balance, 0),
                child: CustomPaint(
                  size: const Size(10, 16),
                  painter: _Chevron(couleur: OuroColors.secondaryLabel),
                ),
              ),
              const SizedBox(width: DesignTokens.space2),
              Text(
                widget.texte,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.subheadline.copyWith(
                  color: OuroColors.secondaryLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Le petit chevron « ‹ ». Deux segments, pas une icône : à cette taille,
/// une police d'icônes rend un trait flou d'épaisseur variable.
class _Chevron extends CustomPainter {
  const _Chevron({required this.couleur});

  final Color couleur;

  @override
  void paint(Canvas toile, Size taille) {
    final p = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      // (CAEV.java:14098)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final milieu = taille.height / 2;
    toile.drawPath(
      Path()
        ..moveTo(taille.width, milieu - 5)
        ..lineTo(taille.width - 5, milieu)
        ..lineTo(taille.width, milieu + 5),
      p,
    );
  }

  @override
  bool shouldRepaint(_Chevron vieux) => vieux.couleur != couleur;
}

// ══ LA PASTILLE « VUE UNIQUE » ══════════════════════════════════════════

// ══ LES PASTILLES DE VERRE ═════════════════════════════════════════════

/// Le disque de verre qui porte les boutons posés au-dessus du cadenas —
/// « vue unique » et « retourner la caméra ».
///
/// ⚠️ LE MÊME VERRE QUE LE CADENAS, PAS UN FOND PLEIN. Sur la capture de
/// Telegram, les trois éléments de la colonne (la flamme « 1 », la caméra,
/// le cadenas) sont taillés dans le même matériau translucide : la
/// conversation se devine au travers. Une pastille pleine au-dessus d'un
/// cadenas de verre se lirait comme un élément étranger, posé là par
/// erreur.
class PastilleVerre extends StatelessWidget {
  const PastilleVerre({
    super.key,
    required this.child,
    this.active = false,
    this.diametre = 36,
  });

  final Widget child;

  /// Allumée : remplie de l'accent, comme un interrupteur enclenché.
  final bool active;

  final double diametre;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(diametre / 2);
    return SizedBox.square(
      dimension: diametre,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: rayon,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: OuroBlurSurface(
          material: OuroMaterial.thin,
          borderRadius: rayon,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: rayon,
              color: active ? OuroColors.accentRempli : Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: OuroColors.isDark ? 0.12 : 0.45,
                ),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Retourne la caméra pendant une vidéo ronde — la pastille du milieu de
/// la colonne, sur la capture de Telegram.
class BoutonRetournerCamera extends StatelessWidget {
  const BoutonRetournerCamera({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PastilleVerre(
        child: Icon(
          Icons.cameraswitch_rounded,
          size: 19,
          color: OuroColors.label,
        ),
      ),
    );
  }
}

/// ⚠️ IL S'APPELLE `BoutonVueUnique` ET NON `PastilleVueUnique` parce que
/// ce dernier nom est DÉJÀ PRIS, dans `vue_unique.dart`, par la pastille
/// qui marque une bulle reçue. Les deux se seraient importés dans
/// `chat_screen.dart`, où ils coexistent.
///
/// Le « 1 » entouré, posé au-dessus du cadenas : le prochain vocal ne
/// pourra être écouté qu'une fois.
///
/// ⚠️ ELLE EST LÀ DÈS LE DÉBUT DE L'ENREGISTREMENT, comme sur la capture
/// de Telegram (la flamme « 1 » au-dessus du cadenas, alors que « Glisser
/// pour annuler » est encore affiché — le doigt est donc toujours posé).
/// Elle n'était montrée qu'après verrouillage : on ne découvrait alors
/// jamais qu'on pouvait rendre un vocal éphémère en cours de route.
class BoutonVueUnique extends StatelessWidget {
  const BoutonVueUnique({
    super.key,
    required this.active,
    required this.apparition,
    required this.onBascule,
  });

  final bool active;

  /// 0 → 1 : portée par l'animation de verrouillage (250 ms).
  final double apparition;

  final VoidCallback onBascule;

  /// (CAEV.java:1684) — 36 de haut, même largeur que le cadenas.
  static const double hauteur = 36;
  static const double largeur = 36;

  /// L'écart entre le haut du cadenas et le bas de la pastille.
  /// (CAEV.java:1682)
  static const double ecart = 12;

  @override
  Widget build(BuildContext context) {
    final t = apparition.clamp(0.0, 1.0);
    if (t <= 0.01) return const SizedBox.shrink();
    return Transform.scale(
      scale: t,
      child: GestureDetector(
        onTap: onBascule,
        behavior: HitTestBehavior.opaque,
        child: PastilleVerre(
          active: active,
          diametre: largeur,
          child: Text(
            '1',
            style: OuroTypography.subheadline.copyWith(
              color: active ? OuroColors.texteSurAccent : OuroColors.label,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
