// ============================================================================
// LES AVATARS DE DROPLET — dégradés, initiales, et l'Assistant.
// ----------------------------------------------------------------------------
// Les aplats des teintes système (orange, bleu, cyan…) faisaient générique :
// on les retrouve dans n'importe quelle app. Ici :
//
//   • huit dégradés de la famille de Droplet — violets, bleus, roses, et
//     quelques teintes chaudes ou fraîches pour distinguer les gens —,
//     adoucis pour vivre sur le noir comme sur le blanc ;
//   • un léger reflet en haut à gauche, qui donne du volume sans décor ;
//   • deux initiales quand le nom a deux mots (« mr Edz » → « ME »), une
//     seule sinon, en demi-gras ;
//   • une couleur STABLE : un hachage FNV des caractères du nom.
//     `String.hashCode` n'est pas promis identique d'une plateforme à
//     l'autre, et la couleur de quelqu'un ne doit jamais changer.
//
// L'Assistant n'est plus une étincelle — le cliché de toutes les IA — mais
// la goutte de Droplet posée sur son rond dans l'eau, sur le dégradé
// bleu-violet de la marque : c'est la voix de l'app, pas un gadget ajouté.
// Pendant qu'il répond, les ronds s'élargissent sous la goutte.
// ============================================================================

import 'package:flutter/material.dart';

class DegradesAvatar {
  DegradesAvatar._();

  static const List<List<Color>> _paires = [
    [Color(0xFF8B7CF8), Color(0xFF5B6CF0)], // iris
    [Color(0xFF5AB8F5), Color(0xFF3A7BEA)], // lagon
    [Color(0xFFCB7BE6), Color(0xFF8E5BF0)], // orchidée
    [Color(0xFFF08BA8), Color(0xFFD05C9A)], // framboise
    [Color(0xFFF7A278), Color(0xFFE06A6A)], // corail
    [Color(0xFFF6C46E), Color(0xFFE8914A)], // ambre
    [Color(0xFF5FD6BD), Color(0xFF2E9FAE)], // menthe
    [Color(0xFF9AA6BC), Color(0xFF66728A)], // ardoise
  ];

  static int _cle(String texte) {
    var h = 0x811C9DC5;
    for (final c in texte.trim().toLowerCase().codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Le dégradé propre à une personne (ou à un groupe), toujours le même.
  static LinearGradient pour(String nom) {
    final paire = _paires[_cle(nom) % _paires.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: paire,
    );
  }

  /// Le reflet posé sur les initiales : du volume, pas un effet.
  static const RadialGradient reflet = RadialGradient(
    center: Alignment(-0.55, -0.75),
    radius: 0.95,
    colors: [Color(0x2EFFFFFF), Color(0x00FFFFFF)],
  );

  /// Deux initiales si le nom a deux mots en lettres latines, une sinon.
  /// Un émoji ou une écriture non latine en tête du nom est gardé tel quel.
  static String initiales(String nom) {
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    String premier(String mot) => mot.characters.first.toUpperCase();
    final a = premier(mots.first);
    final latin = RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ]');
    if (mots.length < 2 || !latin.hasMatch(a)) return a;
    final b = premier(mots[1]);
    return latin.hasMatch(b) || RegExp(r'[0-9]').hasMatch(b) ? '$a$b' : a;
  }

  /// La taille des initiales pour un avatar de rayon donné.
  static double tailleInitiales(String initiales, double rayon) =>
      rayon * (initiales.characters.length > 1 ? 0.7 : 0.82);
}

/// L'avatar de l'Assistant : la goutte de Droplet sur son rond dans l'eau.
class AvatarAssistant extends StatefulWidget {
  const AvatarAssistant({super.key, this.taille = 48, this.actif = false});

  final double taille;

  /// L'Assistant répond : les ronds s'élargissent sous la goutte.
  final bool actif;

  @override
  State<AvatarAssistant> createState() => _AvatarAssistantState();
}

class _AvatarAssistantState extends State<AvatarAssistant>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ondes = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maj();
  }

  @override
  void didUpdateWidget(covariant AvatarAssistant ancien) {
    super.didUpdateWidget(ancien);
    _maj();
  }

  void _maj() {
    final anime = widget.actif && !MediaQuery.disableAnimationsOf(context);
    if (anime && !_ondes.isAnimating) _ondes.repeat();
    if (!anime && _ondes.isAnimating) {
      _ondes
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _ondes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      child: Container(
        width: widget.taille,
        height: widget.taille,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4C8DFF), Color(0xFF7A55F5)],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PeintreGoutte(progression: _ondes, actif: widget.actif),
          ),
        ),
      ),
    );
  }
}

class _PeintreGoutte extends CustomPainter {
  _PeintreGoutte({required this.progression, required this.actif})
      : super(repaint: progression);

  final Animation<double> progression;
  final bool actif;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Le reflet de la pastille, comme sur les autres avatars.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = DegradesAvatar.reflet.createShader(Offset.zero & size),
    );

    // Les ronds dans l'eau, sous la goutte : un seul, discret, au repos ;
    // deux qui s'élargissent pendant une réponse.
    final centreOnde = Offset(cx, h * 0.79);
    void onde(double t, double opacite) {
      canvas.drawOval(
        Rect.fromCenter(
          center: centreOnde,
          width: w * (0.26 + 0.40 * t),
          height: h * (0.07 + 0.10 * t),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.028
          ..color = Colors.white.withValues(alpha: opacite),
      );
    }

    if (actif) {
      for (var i = 0; i < 2; i++) {
        final t = (progression.value + i / 2) % 1.0;
        onde(t, (1 - t) * 0.7);
      }
    } else {
      onde(0.2, 0.38);
    }

    // La goutte.
    final goutte = Path()
      ..moveTo(cx, h * 0.17)
      ..cubicTo(cx + w * 0.07, h * 0.29, cx + w * 0.21, h * 0.41, cx + w * 0.21, h * 0.55)
      ..cubicTo(cx + w * 0.21, h * 0.67, cx + w * 0.11, h * 0.74, cx, h * 0.74)
      ..cubicTo(cx - w * 0.11, h * 0.74, cx - w * 0.21, h * 0.67, cx - w * 0.21, h * 0.55)
      ..cubicTo(cx - w * 0.21, h * 0.41, cx - w * 0.07, h * 0.29, cx, h * 0.17)
      ..close();
    canvas.drawPath(goutte, Paint()..color = Colors.white.withValues(alpha: 0.96));

    // Son reflet : un trait courbe, du bleu de la pastille, dans la goutte.
    final reflet = Path()
      ..moveTo(cx - w * 0.115, h * 0.54)
      ..quadraticBezierTo(cx - w * 0.115, h * 0.64, cx - w * 0.03, h * 0.665);
    canvas.drawPath(
      reflet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.035
        ..color = const Color(0xFF5B7CFA).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_PeintreGoutte ancien) => ancien.actif != actif;
}
