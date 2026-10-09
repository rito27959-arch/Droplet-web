// ============================================================================
// LE TEXTE D'UNE BULLE — avec les spoilers de Telegram, au geste près.
// ----------------------------------------------------------------------------
// Chez Telegram, un spoiler n'est pas un rectangle gris : c'est une POUSSIÈRE
// de points qui scintille exactement sur les lignes du texte caché, et qui se
// DISSOUT en cercle à partir du doigt quand on y touche. Trois choses sont
// nécessaires pour faire pareil :
//
//   1. Les VRAIES lignes du texte caché. Elles viennent du paragraphe déjà
//      mis en page (`RenderParagraph.getBoxesForSelection`) : la poussière
//      épouse donc la coupe des lignes, même quand le spoiler en traverse
//      plusieurs — ce qu'un `WidgetSpan` ne sait pas faire.
//   2. Le texte caché est peint TRANSPARENT, pas remplacé : la mise en page,
//      les retours à la ligne et la hauteur de la bulle ne bougent pas d'un
//      pixel quand on révèle.
//   3. La révélation : un cercle qui s'ouvre depuis le point touché. Le texte
//      caché est peint une seconde fois, découpé par ce cercle, pendant que
//      la poussière s'écarte devant le front de l'onde.
//
// Un appui long ne révèle rien : c'est le menu du message qui s'ouvre. Seul
// un vrai appui court, posé sur la poussière, dissout le voile.
// ============================================================================

part of 'mise_en_forme.dart';

class TexteMisEnForme extends StatefulWidget {
  const TexteMisEnForme({
    super.key,
    required this.texte,
    required this.style,
    this.surLien,
    this.brut,
  });

  final String texte;
  final TextStyle style;

  /// Reçoit l'adresse d'un lien touché.
  final void Function(String lien)? surLien;

  /// Laisse l'écran traiter lui-même le texte sans style (le surlignage
  /// d'une recherche, par exemple).
  final List<InlineSpan> Function(String morceau, TextStyle style)? brut;

  @override
  State<TexteMisEnForme> createState() => _TexteMisEnFormeState();
}

class _TexteMisEnFormeState extends State<TexteMisEnForme>
    with TickerProviderStateMixin {
  final GlobalKey _cleTexte = GlobalKey();

  /// L'horloge de la poussière. Très longue : elle n'est pas censée boucler
  /// sous les yeux de quelqu'un.
  late final AnimationController _poussiere = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 600),
  )..bouclerSiAmbiant();

  late final AnimationController _revelation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..addStatusListener((statut) {
      if (statut == AnimationStatus.completed && mounted) {
        setState(() => _revele = true);
        _poussiere.stop();
      }
    });

  bool _revele = false;
  Offset? _centre;
  double _rayonMax = 0;

  Offset? _appui;
  DateTime _appuiA = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _poussiere.dispose();
    _revelation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaut = DefaultTextStyle.of(context);
    final base = defaut.style.merge(widget.style);
    final rendu = _rendre(base, masquer: !_revele);
    final paragraphe =
        _paragraphe(context, defaut, base, rendu.visibles, cle: _cleTexte);

    if (rendu.plages.isEmpty || _revele) return paragraphe;

    final couleur = base.color ?? OuroColors.label;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (evenement) {
        _appui = evenement.localPosition;
        _appuiA = DateTime.now();
      },
      onPointerUp: (evenement) =>
          _relacher(evenement.localPosition, rendu.plages),
      onPointerCancel: (_) => _appui = null,
      child: Stack(
        children: [
          CustomPaint(
            foregroundPainter: _VoileSpoiler(
              temps: _poussiere,
              revelation: _revelation,
              rayonMax: _rayonMax,
              centre: _centre,
              couleur: couleur,
              boites: () => _boites(rendu.plages),
            ),
            child: paragraphe,
          ),
          // Le texte caché, découpé par le cercle qui s'ouvre.
          if (_centre != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _revelation,
                  builder: (context, _) => ClipPath(
                    clipper: _Cercle(
                      centre: _centre!,
                      rayon: Curves.easeOutCubic.transform(_revelation.value) *
                          _rayonMax,
                    ),
                    child: _paragraphe(context, defaut, base, rendu.masques),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── La mise en page ───────────────────────────────────────────────────

  Widget _paragraphe(
    BuildContext context,
    DefaultTextStyle defaut,
    TextStyle base,
    List<InlineSpan> enfants, {
    Key? cle,
  }) {
    return RichText(
      key: cle,
      text: TextSpan(style: base, children: enfants),
      textAlign: defaut.textAlign ?? TextAlign.start,
      textDirection: Directionality.maybeOf(context),
      softWrap: defaut.softWrap,
      overflow: defaut.overflow,
      maxLines: defaut.maxLines,
      textScaler: MediaQuery.textScalerOf(context),
      textWidthBasis: defaut.textWidthBasis,
      textHeightBehavior:
          defaut.textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
    );
  }

  /// Deux versions du même paragraphe : celle qu'on voit, et celle qui ne
  /// contient que les spoilers (pour la révélation). Mêmes caractères, mêmes
  /// styles : la coupe des lignes est identique dans les deux.
  _Rendu _rendre(TextStyle base, {required bool masquer}) {
    const transparent = Color(0x00000000);
    final invisible = base.copyWith(color: transparent);
    final visibles = <InlineSpan>[];
    final masques = <InlineSpan>[];
    final plages = <TextRange>[];
    var offset = 0;

    for (final m in MiseEnForme._analyser(widget.texte)) {
      final styleMorceau = MiseEnForme._style(m.style, base);
      switch (m.style) {
        case Formatage.spoiler:
          plages.add(TextRange(start: offset, end: offset + m.texte.length));
          visibles.add(TextSpan(
            text: m.texte,
            style: masquer ? styleMorceau.copyWith(color: transparent) : styleMorceau,
          ));
          masques.add(TextSpan(text: m.texte, style: styleMorceau));
          offset += m.texte.length;
        case Formatage.bloc:
          visibles.add(WidgetSpan(
            child: _BlocCode(texte: m.texte, style: styleMorceau),
          ));
          masques.add(WidgetSpan(
            child: Opacity(
              opacity: 0,
              child: _BlocCode(texte: m.texte, style: styleMorceau),
            ),
          ));
          offset += 1;
        case Formatage.lien:
          visibles.add(TextSpan(
            text: m.texte,
            style: styleMorceau,
            // Sans gestionnaire fourni, le lien s'ouvre DANS l'app, comme
            // chez Telegram (voir `navigateur_integre.dart`).
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final surLien = widget.surLien;
                if (surLien != null) {
                  surLien(m.lien!);
                } else {
                  ouvrirLienDansApp(context, m.lien!);
                }
              },
          ));
          masques.add(TextSpan(text: m.texte, style: invisible));
          offset += m.texte.length;
        case null:
          if (widget.brut != null) {
            visibles.addAll(widget.brut!(m.texte, base));
          } else {
            visibles.add(TextSpan(text: m.texte, style: base));
          }
          masques.add(TextSpan(text: m.texte, style: invisible));
          offset += m.texte.length;
        default:
          visibles.add(TextSpan(text: m.texte, style: styleMorceau));
          masques.add(TextSpan(
            text: m.texte,
            style: styleMorceau.copyWith(color: transparent),
          ));
          offset += m.texte.length;
      }
    }
    return _Rendu(visibles, masques, plages);
  }

  /// Les rectangles des lignes cachées, dans le repère du paragraphe.
  List<Rect> _boites(List<TextRange> plages) {
    final rendu = _cleTexte.currentContext?.findRenderObject();
    if (rendu is! RenderParagraph || !rendu.hasSize) return const <Rect>[];
    final boites = <Rect>[];
    for (final plage in plages) {
      for (final boite in rendu.getBoxesForSelection(
        TextSelection(baseOffset: plage.start, extentOffset: plage.end),
      )) {
        final rect = boite.toRect();
        if (rect.width > 0.5 && rect.height > 0.5) boites.add(rect.inflate(1));
      }
    }
    return boites;
  }

  // ── Le geste ──────────────────────────────────────────────────────────

  void _relacher(Offset position, List<TextRange> plages) {
    final depart = _appui;
    _appui = null;
    if (depart == null || _revele) return;
    // Un glissement (on fait défiler) ou un appui long (menu du message) ne
    // révèle rien.
    if ((position - depart).distance > 12) return;
    if (DateTime.now().difference(_appuiA) >
        const Duration(milliseconds: 320)) {
      return;
    }
    final boites = _boites(plages);
    if (!boites.any((b) => b.inflate(6).contains(position))) return;

    var rayon = 0.0;
    for (final b in boites) {
      for (final coin in [b.topLeft, b.topRight, b.bottomLeft, b.bottomRight]) {
        final d = (coin - position).distance;
        if (d > rayon) rayon = d;
      }
    }
    HapticFeedback.selectionClick();
    setState(() {
      _centre = position;
      _rayonMax = rayon + 18;
    });
    _revelation.forward(from: 0);
  }
}

class _Rendu {
  const _Rendu(this.visibles, this.masques, this.plages);

  final List<InlineSpan> visibles;
  final List<InlineSpan> masques;
  final List<TextRange> plages;
}

/// Le cercle de révélation.
class _Cercle extends CustomClipper<Path> {
  const _Cercle({required this.centre, required this.rayon});

  final Offset centre;
  final double rayon;

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: centre, radius: rayon));

  @override
  bool shouldReclip(_Cercle ancien) =>
      ancien.centre != centre || ancien.rayon != rayon;
}

/// La poussière : des points qui naissent, dérivent, s'éteignent, et se
/// rallument ailleurs — et qui s'écartent devant le cercle de révélation.
class _VoileSpoiler extends CustomPainter {
  _VoileSpoiler({
    required this.temps,
    required this.revelation,
    required this.rayonMax,
    required this.centre,
    required this.couleur,
    required this.boites,
  }) : super(repaint: Listenable.merge([temps, revelation]));

  final Animation<double> temps;
  final Animation<double> revelation;
  final double rayonMax;
  final Offset? centre;
  final Color couleur;
  final List<Rect> Function() boites;

  /// La durée du contrôleur, en secondes — pour lire `temps` en secondes.
  static const double _horloge = 600;

  /// La vie d'un point, en secondes.
  static const double _vie = 1.15;

  /// Les graines de chaque boîte, gardées d'une image à l'autre.
  final Map<int, Float32List> _graines = {};

  @override
  void paint(Canvas canvas, Size size) {
    final rects = boites();
    if (rects.isEmpty) return;

    final t = temps.value * _horloge;
    final avance = revelation.value == 0
        ? 0.0
        : Curves.easeOutCubic.transform(revelation.value);
    final rayon = avance * rayonMax;
    final foyer = centre;

    final seaux = [<double>[], <double>[], <double>[]];

    for (final r in rects) {
      final g = _pourBoite(r);
      final n = g.length ~/ 5;
      for (var i = 0; i < n; i++) {
        final phase = g[i * 5 + 4];
        final horloge = t / _vie + phase;
        final vie = horloge - horloge.floorToDouble();
        final cycle = horloge.floor();

        // À chaque cycle, le point renaît ailleurs : c'est ce scintillement
        // qui donne la poussière, plutôt qu'une trame qui glisse.
        final ax = _bruit(i + r.left.round() * 31, cycle);
        final ay = _bruit(i + r.top.round() * 17, cycle + 7919);
        final angle = g[i * 5 + 2];
        final parcours = g[i * 5 + 3] * _vie * vie;

        var x = r.left + ax * r.width + math.cos(angle) * parcours;
        var y = r.top + ay * r.height + math.sin(angle) * parcours;
        if (x < r.left) {
          x += r.width;
        } else if (x > r.right) {
          x -= r.width;
        }
        if (y < r.top) {
          y += r.height;
        } else if (y > r.bottom) {
          y -= r.height;
        }

        var alpha = math.sin(vie * math.pi);
        if (rayon > 0 && foyer != null) {
          final vers = Offset(x, y) - foyer;
          final d = vers.distance;
          if (d < rayon - 6) continue; // déjà dissous
          if (d < rayon + 12) {
            // Le front de l'onde pousse la poussière et l'avive.
            final k = 1 - ((d - rayon + 6) / 18).clamp(0.0, 1.0);
            final direction = d == 0 ? const Offset(0, -1) : vers / d;
            x += direction.dx * 8 * k;
            y += direction.dy * 8 * k;
            alpha = (alpha + 0.45 * k).clamp(0.0, 1.0);
          }
        }

        final seau = alpha < 0.34 ? 0 : (alpha < 0.68 ? 1 : 2);
        seaux[seau].add(x);
        seaux[seau].add(y);
      }
    }

    const opacites = [0.16, 0.40, 0.70];
    final pinceau = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;
    for (var s = 0; s < 3; s++) {
      if (seaux[s].isEmpty) continue;
      pinceau.color =
          couleur.withValues(alpha: opacites[s] * (1 - avance * 0.5));
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(seaux[s]),
        pinceau,
      );
    }
  }

  Float32List _pourBoite(Rect r) {
    final cle = Object.hash(
      r.left.round(),
      r.top.round(),
      r.width.round(),
      r.height.round(),
    );
    return _graines.putIfAbsent(cle, () {
      final nombre = (r.width * r.height / 5.5).clamp(8, 480).toInt();
      final hasard = math.Random(cle);
      final g = Float32List(nombre * 5);
      for (var i = 0; i < nombre; i++) {
        g[i * 5] = hasard.nextDouble();
        g[i * 5 + 1] = hasard.nextDouble();
        g[i * 5 + 2] = hasard.nextDouble() * math.pi * 2;
        g[i * 5 + 3] = 2 + hasard.nextDouble() * 5; // points par seconde
        g[i * 5 + 4] = hasard.nextDouble();
      }
      return g;
    });
  }

  /// Un bruit déterministe et bon marché : deux entiers, un nombre entre 0 et 1.
  static double _bruit(int a, int b) {
    var x = (a * 73856093) ^ (b * 19349663);
    x = (x ^ (x >> 13)) * 1274126177;
    x = x ^ (x >> 16);
    return (x & 0x3FFFFF) / 0x3FFFFF;
  }

  @override
  bool shouldRepaint(_VoileSpoiler ancien) =>
      ancien.centre != centre ||
      ancien.rayonMax != rayonMax ||
      ancien.couleur != couleur;
}
