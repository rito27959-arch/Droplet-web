// ============================================================================
// LA VITRINE DE DROPLET PRO — les pièces de l'écran d'achat.
// ----------------------------------------------------------------------------
// Ce que font les grands écrans « premium » d'iOS (Telegram Premium, Calm,
// Duolingo Super, les 500 paywalls étudiés par Superwall et Adapty), et que
// l'ancien écran ne faisait pas :
//
//   1. UNE SCÈNE, PAS UN FORMULAIRE. Un fond vivant (aurore lente et
//      poussière d'étoiles), un emblème qui apparaît, un nom en dégradé. On
//      entre dans un lieu, on ne remplit pas une page de réglages.
//   2. LA VALEUR AVANT LE PRIX. Ce qu'on gagne, en une phrase, puis trois
//      garanties qui rassurent (paiement unique, sans abonnement, marche
//      hors ligne) — l'argument que ni WhatsApp ni Telegram ne peuvent
//      donner.
//   3. DEUX OFFRES CÔTE À CÔTE, l'une mise en avant (« Le plus complet »),
//      le prix en grand, le choix visible d'un coup d'œil.
//   4. LES AVANTAGES EN ICÔNES DE COULEUR, sur le dégradé premium — un
//      toucher ouvre l'explication en plein écran.
//   5. UN SEUL BOUTON, TOUJOURS VISIBLE, en bas sur du verre, avec le prix
//      dedans et, dessous, ce qui se passera vraiment (aucun prélèvement
//      ensuite). Le numéro de téléphone et le code ne viennent qu'APRÈS,
//      dans une feuille : on ne demande pas un numéro avant d'avoir donné
//      envie.
//
// ⚠️ RIEN D'INVENTÉ. Pas de faux avis, pas de « 1 200 membres », pas de
// prix barré fictif, pas de compte à rebours : ce qui est affiché est vrai.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design_system/flou.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'avantages_pro.dart';
import 'fonctions_premium.dart';

// ─────────────────────────────────────────────────────────────
//  LE FOND : aurore lente + poussière d'étoiles
// ─────────────────────────────────────────────────────────────

/// Le fond de la vitrine. Trois lueurs du dégradé premium dérivent très
/// lentement en haut de l'écran, et une poussière d'étoiles monte en
/// scintillant. Rien ne clignote, rien ne passe vite : ça respire.
///
/// « Réduire les animations » : tout s'arrête, le fond reste beau.
class FondPremium extends StatefulWidget {
  const FondPremium({super.key});

  @override
  State<FondPremium> createState() => _FondPremiumState();
}

class _FondPremiumState extends State<FondPremium> with SingleTickerProviderStateMixin {
  late final AnimationController _temps = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  // Les étincelles : tirées une fois, regroupées autour de l'emblème —
  // denses près de lui, rares plus loin, comme chez Telegram Premium.
  final List<_Etincelle> _etincelles = () {
    final r = math.Random(11);
    return [
      for (var i = 0; i < 120; i++)
        () {
          // Distance : surtout entre 60 et 210 px du centre, quelques
          // égarées plus loin.
          final d = 55 + math.pow(r.nextDouble(), 1.6) * 230;
          return _Etincelle(
            angle: r.nextDouble() * math.pi * 2,
            distance: d.toDouble(),
            taille: 1.6 + r.nextDouble() * 3.4,
            vitesse: 0.4 + r.nextDouble() * 1.2,
            phase: r.nextDouble() * math.pi * 2,
            teinte: r.nextInt(3),
          );
        }(),
    ];
  }();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = OuroMotion.of(context).reduceMotion;
    if (reduit) {
      _temps.stop();
    } else if (!_temps.isAnimating) {
      _temps.repeat();
    }
  }

  @override
  void dispose() {
    _temps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _temps,
        builder: (context, _) => CustomPaint(
          painter: _PeintreFond(
            t: _temps.value,
            etincelles: _etincelles,
            sombre: OuroColors.isDark,
            fond: OuroColors.systemBackground,
            // Le centre de l'emblème (voir la mise en page de l'écran).
            centreY: haut + 34 + 88,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Etincelle {
  const _Etincelle({
    required this.angle,
    required this.distance,
    required this.taille,
    required this.vitesse,
    required this.phase,
    required this.teinte,
  });

  final double angle, distance, taille, vitesse, phase;
  final int teinte;
}

/// Les teintes des étincelles : violet, bleu, rose — celles de l'emblème.
const List<Color> _teintesEtincelles = [
  Color(0xFF9F8CFF),
  Color(0xFF7FA2FF),
  Color(0xFFE59BFF),
];

class _PeintreFond extends CustomPainter {
  _PeintreFond({
    required this.t,
    required this.etincelles,
    required this.sombre,
    required this.fond,
    required this.centreY,
  });

  final double t;
  final List<_Etincelle> etincelles;
  final bool sombre;
  final Color fond;
  final double centreY;

  @override
  void paint(Canvas canvas, Size taille) {
    canvas.drawRect(Offset.zero & taille, Paint()..color = fond);
    final centre = Offset(taille.width / 2, centreY);

    // Une lueur très douce derrière l'emblème — à peine là.
    final rayonLueur = taille.width * 0.75;
    canvas.drawCircle(
      centre,
      rayonLueur,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF7B5CFF).withValues(alpha: sombre ? 0.22 : 0.12),
            const Color(0xFF7B5CFF).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: rayonLueur)),
    );

    // Les étincelles à quatre branches : elles tournent très lentement
    // autour de l'emblème et scintillent chacune à son rythme.
    final a = t * math.pi * 2;
    final pinceau = Paint()..style = PaintingStyle.fill;
    for (final e in etincelles) {
      final ang = e.angle + a * 0.05 * (e.vitesse > 1 ? 1 : -1);
      final p = centre + Offset(math.cos(ang), math.sin(ang) * 0.85) * e.distance;
      if (p.dy < -10 || p.dy > taille.height * 0.6) continue;
      final scintille = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(a * 8 * e.vitesse + e.phase));
      final eloignement = (1 - (e.distance - 55) / 260).clamp(0.25, 1.0);
      final c = _teintesEtincelles[e.teinte];
      pinceau.color = c.withValues(alpha: (sombre ? 0.9 : 0.75) * scintille * eloignement);
      final l = e.taille * (0.7 + 0.3 * scintille);
      final w = l * 0.22;
      // Une étincelle « + » aux branches effilées.
      final chemin = Path()
        ..moveTo(p.dx, p.dy - l)
        ..quadraticBezierTo(p.dx + w * 0.3, p.dy - w * 0.3, p.dx + l, p.dy)
        ..quadraticBezierTo(p.dx + w * 0.3, p.dy + w * 0.3, p.dx, p.dy + l)
        ..quadraticBezierTo(p.dx - w * 0.3, p.dy + w * 0.3, p.dx - l, p.dy)
        ..quadraticBezierTo(p.dx - w * 0.3, p.dy - w * 0.3, p.dx, p.dy - l)
        ..close();
      canvas.drawPath(chemin, pinceau);
    }
  }

  @override
  bool shouldRepaint(_PeintreFond ancien) =>
      ancien.t != t || ancien.sombre != sombre || ancien.fond != fond || ancien.centreY != centreY;
}

// ─────────────────────────────────────────────────────────────
//  L'EMBLÈME
// ─────────────────────────────────────────────────────────────

/// La goutte Pro : un rond au dégradé premium, un halo, un reflet. Elle
/// arrive une fois (montée + léger rebond) puis reste tranquille — une
/// image qui bouge sans arrêt derrière un prix devient une enseigne.
class EmblemePro extends StatelessWidget {
  const EmblemePro({super.key, this.taille = 104});

  final double taille;

  /// Le dégradé de l'emblème : bleu-violet en haut, rose-violet en bas,
  /// comme l'étoile de Telegram Premium.
  static const List<Color> degrade = [Color(0xFF6E7BFF), Color(0xFF9A5CFF), Color(0xFFE05ACB)];

  @override
  Widget build(BuildContext context) {
    final reduit = OuroMotion.of(context).reduceMotion;
    final cote = taille * 1.7;
    Widget goutte(double alphaReflet) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: degrade,
          ).createShader(r),
          child: Icon(Icons.water_drop_rounded, size: cote * 0.92),
        );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduit ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, v, enfant) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * v, child: enfant),
      ),
      child: SizedBox(
        width: cote,
        height: cote,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // L'ombre colorée, floue, sous la goutte.
            Transform.translate(
              offset: Offset(0, taille * 0.06),
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Opacity(opacity: 0.55, child: goutte(0)),
              ),
            ),
            goutte(1),
            // Le reflet : un éclat clair en haut à gauche de la goutte.
            Positioned(
              left: cote * 0.33,
              top: cote * 0.42,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: cote * 0.1,
                  height: cote * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cote),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: cote * 0.27,
              top: cote * 0.16,
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: 0.95), size: taille * 0.26),
            ),
          ],
        ),
      ),
    );
  }
}

/// « Droplet Pro » en dégradé, comme un nom de produit, pas un titre de
/// page.
class TitrePro extends StatelessWidget {
  const TitrePro({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    // Comme chez Telegram : un nom net, en blanc (ou noir), sans effet —
    // c'est l'emblème et ses étincelles qui portent la magie.
    return Text(
      texte,
      textAlign: TextAlign.center,
      style: OuroTypography.largeTitle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
        color: OuroColors.label,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES GARANTIES
// ─────────────────────────────────────────────────────────────

/// Les trois garanties, en petites capsules de verre.
class GarantiesPro extends StatelessWidget {
  const GarantiesPro({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget puce(IconData i, String t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: OuroColors.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: OuroColors.isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(i, size: 14, color: OuroColors.label.withValues(alpha: 0.85)),
              const SizedBox(width: 5),
              Text(
                t,
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.label.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        puce(Icons.all_inclusive_rounded, l10n.pmTrustOnce),
        puce(Icons.event_busy_rounded, l10n.pmTrustNoSub),
        puce(Icons.wifi_off_rounded, l10n.pmTrustOffline),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES DEUX OFFRES, CÔTE À CÔTE
// ─────────────────────────────────────────────────────────────

class CartesOffresPro extends StatelessWidget {
  const CartesOffresPro({
    super.key,
    required this.proChoisi,
    required this.onChoisir,
    required this.prixPro,
    required this.prixPack,
  });

  final bool proChoisi;
  final ValueChanged<bool> onChoisir;
  final int prixPro;
  final int prixPack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Comme Telegram : UNE carte, une ligne par offre, la case ronde à
    // gauche, le prix à droite. Plus calme que deux cartes côte à côte,
    // et le choix se lit comme une liste.
    return Container(
      decoration: BoxDecoration(
        color: couleurCarteVitrine,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _LigneOffre(
            titre: l10n.pmTitle,
            badge: l10n.pmBestValue,
            mention: l10n.pmOnceForLife,
            prix: prixPro,
            choisi: proChoisi,
            onTap: () => onChoisir(true),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 58),
            child: Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
          ),
          _LigneOffre(
            titre: l10n.pmPackTitle,
            mention: l10n.pmOnce,
            prix: prixPack,
            choisi: !proChoisi,
            onTap: () => onChoisir(false),
          ),
        ],
      ),
    );
  }
}

/// Le fond des cartes de la vitrine : un gris bleuté en sombre (comme les
/// cartes de Telegram sur son fond), blanc en clair.
Color get couleurCarteVitrine =>
    OuroColors.isDark ? const Color(0xFF1C1C22) : Colors.white;

class _LigneOffre extends StatelessWidget {
  const _LigneOffre({
    required this.titre,
    required this.mention,
    required this.prix,
    required this.choisi,
    required this.onTap,
    this.badge,
  });

  final String titre;
  final String mention;
  final int prix;
  final bool choisi;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: choisi,
      label: '$titre, ${prixLisible(prix)}, $mention',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            OuroHaptics.selection();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
            child: Row(
              children: [
                _Coche(choisi: choisi),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              titre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OuroTypography.headline.copyWith(color: OuroColors.label),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(colors: EmblemePro.degrade),
                              ),
                              child: Text(
                                badge!,
                                style: OuroTypography.caption2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mention,
                        style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  prixLisible(prix),
                  style: OuroTypography.headline.copyWith(
                    color: choisi ? OuroColors.label : OuroColors.secondaryLabel,
                    fontWeight: FontWeight.w600,
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

/// Le prix lisible : « 1 000 F ».
String prixLisible(int prix) {
  final s = prix.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$b F';
}

class _Coche extends StatelessWidget {
  const _Coche({required this.choisi});

  final bool choisi;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: choisi ? const LinearGradient(colors: EmblemePro.degrade) : null,
        border: choisi ? null : Border.all(color: OuroColors.tertiaryLabel, width: 1.5),
      ),
      child: choisi ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
    );
  }
}

/// Ce que contient l'offre choisie, en trois lignes cochées — elles
/// changent en fondu quand on change d'offre.
class ContenuOffre extends StatelessWidget {
  const ContenuOffre({super.key, required this.lignes});

  final List<String> lignes;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Column(
        key: ValueKey(lignes.join()),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lignes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, size: 17, color: kDegradePremium[1]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l,
                      style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES AVANTAGES
// ─────────────────────────────────────────────────────────────

/// Les avantages, à la Telegram : une icône de couleur par ligne, prise
/// sur le dégradé premium — la liste se lit comme une seule pièce.
class ListeAvantagesVitrine extends StatelessWidget {
  const ListeAvantagesVitrine({super.key, required this.onOuvrir});

  final ValueChanged<int> onOuvrir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final avantages = avantagesPro();
    final sombre = OuroColors.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.avSectionHeader.toUpperCase(),
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: couleurCarteVitrine,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sombre ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              width: 0.8,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < avantages.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 64),
                    child: Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
                  ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      OuroHaptics.selection();
                      onOuvrir(i);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.lerp(couleurAvantage(i), Colors.white, 0.18)!,
                                  couleurAvantage(i),
                                ],
                              ),
                            ),
                            child: Icon(avantages[i].icone, color: Colors.white, size: 21),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  avantages[i].titre(l10n),
                                  style: OuroTypography.body.copyWith(
                                    color: OuroColors.label,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  avantages[i].court(l10n),
                                  style: OuroTypography.footnote.copyWith(
                                    color: OuroColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: OuroColors.tertiaryLabel, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LA BARRE D'ACHAT
// ─────────────────────────────────────────────────────────────

/// Le bouton, toujours visible, sur du verre dépoli. Le prix est DANS le
/// bouton, et dessous, en clair : ce qui se passe vraiment.
class BarreAchatPro extends StatelessWidget {
  const BarreAchatPro({
    super.key,
    required this.libelle,
    required this.precision,
    required this.onAcheter,
    required this.libelleCode,
    required this.onCode,
  });

  final String libelle;
  final String precision;
  final VoidCallback onAcheter;
  final String libelleCode;
  final VoidCallback onCode;

  @override
  Widget build(BuildContext context) {
    final sombre = OuroColors.isDark;
    final bas = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: Flou(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, math.max(bas, 12)),
          decoration: BoxDecoration(
            color: OuroColors.systemBackground.withValues(alpha: sombre ? 0.72 : 0.78),
            border: Border(
              top: BorderSide(
                color: sombre ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                width: 0.6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 54,
                width: double.infinity,
                child: BoutonPremium(libelle: libelle, onTap: onAcheter, rayon: 27),
              ),
              const SizedBox(height: 8),
              Text(
                precision,
                textAlign: TextAlign.center,
                style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
              ),
              TextButton(
                onPressed: onCode,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  libelleCode,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.label.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le bouton rond de verre (fermer), en haut à gauche.
class BoutonRondVerre extends StatelessWidget {
  const BoutonRondVerre({super.key, required this.icone, required this.onTap, required this.etiquette});

  final IconData icone;
  final VoidCallback onTap;
  final String etiquette;

  @override
  Widget build(BuildContext context) {
    final sombre = OuroColors.isDark;
    return Semantics(
      button: true,
      label: etiquette,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: Flou(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 36,
              height: 36,
              color: sombre ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
              child: Icon(icone, size: 20, color: OuroColors.label),
            ),
          ),
        ),
      ),
    );
  }
}
