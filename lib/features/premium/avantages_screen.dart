// ============================================================================
// LES EXPLICATIONS DE DROPLET PRO — un avantage par page.
// ----------------------------------------------------------------------------
// Le modèle est la page Premium de Telegram, reprise pièce par pièce depuis
// la vidéo de référence. Sa structure tient en trois plans, et c'est ce
// feuilletage qui fait toute la tenue :
//
//   1. LE FOND NE BOUGE PAS D'UNE PAGE À L'AUTRE. Dégradé premium et
//      étoiles occupent tout l'écran et restent là ; ce sont eux qui
//      disent « vous êtes toujours au même endroit ».
//   2. L'EMBLÈME RESTE, ET S'INCLINE. Une grande goutte translucide, en
//      haut, qui bascule au fil des pages et dérive à contre-sens du
//      doigt. C'est l'ancre du regard : sans elle, feuilleter donnait
//      l'impression de changer d'écran à chaque glissement.
//   3. LA FEUILLE PASSE PAR-DESSUS. Un panneau arrondi qui porte l'aperçu,
//      le nom, l'explication, les points et le bouton. Il ne défile pas :
//      il est le cadre dans lequel les pages défilent.
//
// CE QUI A ÉTÉ REPRIS EN MAIN, ET POURQUOI
// ----------------------------------------------------------------------------
// • L'ancienne page montrait UNE ICÔNE DANS UN ROND, posée sur des anneaux.
//   C'était joli et ça ne montrait rien. L'application avait déjà le
//   téléphone dessiné de Telegram et six démonstrations jouées dedans
//   (`apercu_telephone.dart`) — ils n'étaient simplement jamais arrivés
//   jusqu'ici. On ne lit plus ce que fait la fonction : on la voit.
// • LE BOUTON D'ACHAT NE FAISAIT RIEN. Il était appelé avec un rappel vide.
// • Il n'y avait NI EMBLÈME NI FEUILLE : tout flottait sur un halo, et
//   chaque page semblait un écran de plus.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'apercu_telephone.dart';
import 'avantages_pro.dart';
import 'fonctions_premium.dart';

Future<void> ouvrirAvantagesPro(
  BuildContext context, {
  int depart = 0,
  required VoidCallback onAcheter,
  required String libelleAchat,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      // La page monte un peu en apparaissant, au lieu de simplement se
      // révéler : le geste iOS d'une feuille qu'on tire.
      pageBuilder: (_, animation, _) => AvantagesProScreen(
        depart: depart,
        onAcheter: onAcheter,
        libelleAchat: libelleAchat,
      ),
      transitionsBuilder: (_, animation, _, child) {
        final adouci = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: adouci,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(adouci),
            child: child,
          ),
        );
      },
    ),
  );
}

class AvantagesProScreen extends StatefulWidget {
  const AvantagesProScreen({
    super.key,
    this.depart = 0,
    required this.onAcheter,
    required this.libelleAchat,
  });

  final int depart;
  final VoidCallback onAcheter;
  final String libelleAchat;

  @override
  State<AvantagesProScreen> createState() => _AvantagesProScreenState();
}

class _AvantagesProScreenState extends State<AvantagesProScreen> {
  late final PageController _pages = PageController(initialPage: widget.depart);
  late double _position = widget.depart.toDouble();
  late int _page = widget.depart;

  @override
  void initState() {
    super.initState();
    _pages.addListener(() {
      final p = _pages.page ?? _position;
      if (p == _position) return;
      setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final avantages = avantagesPro();
    final taille = MediaQuery.sizeOf(context);
    final hautSur = MediaQuery.paddingOf(context).top;
    final basSur = MediaQuery.paddingOf(context).bottom;

    // La hauteur du bandeau : assez pour que l'emblème respire, jamais
    // assez pour manger l'aperçu.
    //
    // ⚠️ C'EST LE TÉLÉPHONE QUI PAIE CE QU'ON PREND ICI. L'aperçu occupe
    // ce qui reste une fois le bandeau, le texte, les points et le bouton
    // servis ; à 26 % de la hauteur, le mobile dessiné tombait à 153
    // points de large — une vignette. À 22 %, il en fait 172, et sur un
    // petit écran il reste lisible.
    final hEntete = (taille.height * 0.22).clamp(116.0, 190.0).toDouble();

    // La couleur du moment : celle de l'avantage regardé, mélangée avec la
    // suivante au fil du doigt — elle ne saute pas à la fin du geste.
    final gauche = couleurAvantage(
      _position.floor().clamp(0, avantages.length - 1),
    );
    final droite = couleurAvantage(
      _position.ceil().clamp(0, avantages.length - 1),
    );
    final melange = Color.lerp(
      gauche,
      droite,
      _position - _position.floorToDouble(),
    )!;

    return Scaffold(
      backgroundColor: OuroColors.systemBackground,
      body: Stack(
        children: [
          // ── PLAN 1 : le fond, qui ne change pas de page ──────────────
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            // On déborde sous la feuille : ses coins arrondis laissent
            // voir le dégradé dans les encoches, comme chez Telegram.
            height: hEntete + 60,
            child: const Stack(
              fit: StackFit.expand,
              children: [
                FondDegradePremium(),
                EtoilesPremium(),
              ],
            ),
          ),

          // ── PLAN 2 : l'emblème, qui reste et s'incline ───────────────
          Positioned(
            left: 0,
            right: 0,
            top: hautSur + 8,
            height: hEntete - hautSur - 8,
            child: _EmblemeGoutte(
              position: _position,
              total: avantages.length,
            ),
          ),

          // ── PLAN 3 : la feuille ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            top: hEntete,
            bottom: 0,
            // L'ombre portée sous le bord haut : deux points de flou qui
            // détachent la feuille du dégradé. Sans elle, la feuille est
            // collée au fond et le relief disparaît.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusSheet),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DesignTokens.radiusSheet),
              ),
              child: ColoredBox(
                color: OuroColors.systemBackground,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pages,
                        itemCount: avantages.length,
                        onPageChanged: (i) {
                          OuroHaptics.selection();
                          setState(() => _page = i);
                        },
                        itemBuilder: (context, i) {
                          final a = avantages[i];
                          // Le décalage de CETTE page par rapport au
                          // doigt : 0 au centre, ±1 au bord. C'est lui
                          // qui décompose la scène pendant le glissement.
                          final ecart = (i - _position).clamp(-1.0, 1.0);
                          return Column(
                            children: [
                              // L'aperçu touche le bord haut de la
                              // feuille : ce sont les coins de la feuille
                              // qui l'arrondissent, pas un cadre de plus.
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    a.apercu(ecart, i == _page),
                                    // ⚠️ LE VOILE N'EST PAS UN EFFET, IL
                                    // RÈGLE UN CONFLIT. Le bandeau et
                                    // l'aperçu portent chacun le dégradé
                                    // premium, en diagonales différentes :
                                    // à pleine force, ils se heurtaient au
                                    // bord de la feuille et l'œil voyait
                                    // deux fonds qui se disputent. Éclairci
                                    // d'un sixième, l'aperçu redevient ce
                                    // qu'il est chez Telegram — un panneau
                                    // posé sur le fond, pas un second fond.
                                    // Et le téléphone y ressort mieux.
                                    IgnorePointer(
                                      child: ColoredBox(
                                        color: Colors.white
                                            .withValues(alpha: 0.17),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _Texte(
                                titre: a.titre(l10n),
                                corps: a.long(l10n),
                                opacite: 1 - ecart.abs(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _Points(
                      nombre: avantages.length,
                      position: _position,
                      couleur: melange,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        DesignTokens.space5,
                        DesignTokens.space4,
                        DesignTokens.space5,
                        DesignTokens.space3 + basSur,
                      ),
                      child: SizedBox(
                        height: 52,
                        child: BoutonPremium(
                          libelle: widget.libelleAchat,
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onAcheter();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),

          // ── Revenir, sur le dégradé ─────────────────────────────────
          Positioned(
            left: 4,
            top: hautSur + 2,
            child: _RondVerre(
              icone: Icons.arrow_back_ios_new_rounded,
              semantique: l10n.actionCancel,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// L'EMBLÈME
// ============================================================================

/// La goutte de Droplet, en grand et translucide, posée sur le dégradé.
///
/// Elle bascule d'un bout à l'autre du catalogue et dérive à contre-sens du
/// doigt : deux mouvements minuscules, mais ce sont eux qui font qu'on
/// feuillette UN écran au lieu d'en enchaîner sept.
class _EmblemeGoutte extends StatelessWidget {
  const _EmblemeGoutte({required this.position, required this.total});

  final double position;
  final int total;

  @override
  Widget build(BuildContext context) {
    // De −14° à +14° sur l'ensemble du catalogue. Assez pour qu'on le
    // remarque en arrivant au bout, jamais assez pour que ça tangue.
    final avancement = total <= 1 ? 0.0 : position / (total - 1);
    final angle = (avancement - 0.5) * 0.49;
    // La dérive : l'emblème suit le doigt trois fois moins vite que la
    // feuille. C'est ce retard qui creuse la profondeur.
    final derive = -(position - position.roundToDouble()) * 22;
    return LayoutBuilder(
      builder: (context, c) {
        final cote = math.min(c.maxHeight * 0.96, 132.0);
        return Center(
          child: Transform.translate(
            offset: Offset(derive, 0),
            child: Transform.rotate(
              angle: angle,
              child: SizedBox(
                width: cote,
                height: cote,
                child: CustomPaint(painter: _PeintreEmbleme(cote: cote)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// La goutte, dessinée : la même courbe que le logo de l'app (voir
/// `droplet_logo.dart`), mais en blanc translucide — c'est un filigrane,
/// pas un logo posé sur une page.
class _PeintreEmbleme extends CustomPainter {
  const _PeintreEmbleme({required this.cote});

  final double cote;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * 0.08;
    final r = size.width * 0.33;

    final chemin = Path()
      ..moveTo(cx, cy - 1.55 * r)
      ..cubicTo(cx - 0.6 * r, cy - 0.95 * r, cx - r, cy - 0.6 * r, cx - r,
          cy - 0.1 * r)
      ..cubicTo(cx - r, cy + 0.55 * r, cx - 0.55 * r, cy + r, cx, cy + r)
      ..cubicTo(cx + 0.55 * r, cy + r, cx + r, cy + 0.55 * r, cx + r,
          cy - 0.1 * r)
      ..cubicTo(cx + r, cy - 0.6 * r, cx + 0.6 * r, cy - 0.95 * r, cx,
          cy - 1.55 * r)
      ..close();

    // Le corps : un blanc très dilué, qui laisse passer le dégradé.
    canvas.drawPath(
      chemin,
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );
    // Un liseré plus clair sur le pourtour : sans lui, la goutte se
    // dissout dans les teintes claires du dégradé.
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..isAntiAlias = true
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    // Le reflet en haut à gauche, comme sur le vrai logo.
    canvas.save();
    canvas.clipPath(chemin);
    canvas.drawCircle(
      Offset(cx - r * 0.34, cy - r * 0.48),
      r * 0.62,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.34),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(cx - r * 0.34, cy - r * 0.48),
            radius: r * 0.62,
          ),
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreEmbleme ancien) => ancien.cote != cote;
}

// ============================================================================
// LA FEUILLE
// ============================================================================

/// Le nom de l'avantage et son explication, sous l'aperçu.
class _Texte extends StatelessWidget {
  const _Texte({
    required this.titre,
    required this.corps,
    required this.opacite,
  });

  final String titre;
  final String corps;

  /// S'efface pendant le glissement : le texte de la page qu'on quitte ne
  /// doit pas se superposer à celui qui arrive.
  final double opacite;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacite.clamp(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titre,
              textAlign: TextAlign.center,
              style: OuroTypography.title3.copyWith(
                color: OuroColors.label,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            // ⚠️ BORNÉ À QUATRE LIGNES. Le bloc de texte est mesuré avant
            // que l'aperçu reçoive ce qui reste : une explication plus
            // longue que prévu — et les traductions le sont souvent —
            // rognerait le téléphone sans qu'on s'en aperçoive en
            // français.
            Text(
              corps,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Les points de pagination : celui de la page en cours s'étire, il ne
/// grossit pas — c'est la forme d'iOS. Et il s'étire EN CONTINU, au fil du
/// doigt, au lieu de sauter quand la page se cale.
class _Points extends StatelessWidget {
  const _Points({
    required this.nombre,
    required this.position,
    required this.couleur,
  });

  final int nombre;
  final double position;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < nombre; i++)
          Builder(
            builder: (context) {
              final proche = (1 - (position - i).abs()).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  height: 6,
                  width: 6 + proche * 12,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      OuroColors.quaternaryLabel,
                      couleur,
                      proche,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Un rond en verre posé sur le dégradé — le retour, en haut à gauche.
class _RondVerre extends StatefulWidget {
  const _RondVerre({
    required this.icone,
    required this.semantique,
    required this.onTap,
  });

  final IconData icone;
  final String semantique;
  final VoidCallback onTap;

  @override
  State<_RondVerre> createState() => _RondVerreState();
}

class _RondVerreState extends State<_RondVerre> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _enfonce = true),
        onTapCancel: () => setState(() => _enfonce = false),
        onTap: () {
          setState(() => _enfonce = false);
          OuroHaptics.light();
          widget.onTap();
        },
        // 44 pt de zone touchable, un rond de 34 dedans : la règle iOS.
        child: SizedBox(
          width: DesignTokens.minTouchTarget,
          height: DesignTokens.minTouchTarget,
          child: Center(
            child: AnimatedScale(
              scale: _enfonce ? 0.88 : 1,
              duration: DesignTokens.durationFast,
              curve: DesignTokens.curveEnter,
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: _enfonce ? 0.34 : 0.22),
                ),
                child: Icon(widget.icone, size: 17, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
