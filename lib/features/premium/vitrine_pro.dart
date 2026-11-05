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
    duration: const Duration(seconds: 24),
  );

  // Les étoiles : positions et vitesses tirées une fois.
  final List<_Etoile> _etoiles = () {
    final r = math.Random(7);
    return [
      for (var i = 0; i < 46; i++)
        _Etoile(
          x: r.nextDouble(),
          y: r.nextDouble(),
          rayon: 0.6 + r.nextDouble() * 1.5,
          vitesse: 0.15 + r.nextDouble() * 0.5,
          phase: r.nextDouble() * math.pi * 2,
          teinte: r.nextInt(3),
        ),
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _temps,
        builder: (context, _) => CustomPaint(
          painter: _PeintreFond(
            t: _temps.value,
            etoiles: _etoiles,
            sombre: OuroColors.isDark,
            fond: OuroColors.systemBackground,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Etoile {
  const _Etoile({
    required this.x,
    required this.y,
    required this.rayon,
    required this.vitesse,
    required this.phase,
    required this.teinte,
  });

  final double x, y, rayon, vitesse, phase;
  final int teinte;
}

class _PeintreFond extends CustomPainter {
  _PeintreFond({
    required this.t,
    required this.etoiles,
    required this.sombre,
    required this.fond,
  });

  final double t;
  final List<_Etoile> etoiles;
  final bool sombre;
  final Color fond;

  @override
  void paint(Canvas canvas, Size taille) {
    canvas.drawRect(Offset.zero & taille, Paint()..color = fond);
    final a = t * math.pi * 2;
    final force = sombre ? 0.42 : 0.22;

    // L'aurore : trois lueurs qui tournent lentement autour de leur place.
    void lueur(Color c, double cx, double cy, double r, double dephasage) {
      final centre = Offset(
        taille.width * (cx + 0.06 * math.cos(a + dephasage)),
        taille.height * (cy + 0.025 * math.sin(a * 1.3 + dephasage)),
      );
      final rayon = taille.width * r;
      canvas.drawCircle(
        centre,
        rayon,
        Paint()
          ..shader = RadialGradient(
            colors: [c.withValues(alpha: force), c.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: centre, radius: rayon)),
      );
    }

    lueur(kDegradePremium[0], 0.22, 0.10, 0.75, 0);
    lueur(kDegradePremium[1], 0.80, 0.16, 0.65, 2.1);
    lueur(kDegradePremium[2], 0.50, 0.30, 0.55, 4.2);

    // Fondu vers le fond, pour que la liste se lise sur du calme.
    final fondu = Rect.fromLTWH(0, taille.height * 0.25, taille.width, taille.height * 0.4);
    canvas.drawRect(
      fondu,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fond.withValues(alpha: 0), fond],
        ).createShader(fondu),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, taille.height * 0.65, taille.width, taille.height * 0.35),
      Paint()..color = fond,
    );

    // La poussière d'étoiles, dans le haut seulement.
    final hauteur = taille.height * 0.55;
    for (final e in etoiles) {
      final y = ((e.y - t * e.vitesse) % 1.0) * hauteur;
      final scintille = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(a * 6 * e.vitesse + e.phase));
      final effacement = (1 - y / hauteur).clamp(0.0, 1.0);
      final c = sombre ? Colors.white : kDegradePremium[e.teinte];
      canvas.drawCircle(
        Offset(e.x * taille.width, y),
        e.rayon,
        Paint()..color = c.withValues(alpha: (sombre ? 0.75 : 0.45) * scintille * effacement),
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreFond ancien) =>
      ancien.t != t || ancien.sombre != sombre || ancien.fond != fond;
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

  @override
  Widget build(BuildContext context) {
    final reduit = OuroMotion.of(context).reduceMotion;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduit ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, v, enfant) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * v, child: enfant),
      ),
      child: SizedBox(
        width: taille * 1.7,
        height: taille * 1.7,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Le halo.
            Container(
              width: taille * 1.7,
              height: taille * 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kDegradePremium[1].withValues(alpha: 0.45),
                    kDegradePremium[0].withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            // La goutte.
            Container(
              width: taille,
              height: taille,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: kDegradePremium,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kDegradePremium[1].withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Le reflet, en haut à gauche : la lumière vient d'au-dessus.
                  Positioned(
                    top: taille * 0.1,
                    left: taille * 0.16,
                    child: Container(
                      width: taille * 0.42,
                      height: taille * 0.22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(taille),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.water_drop_rounded, color: Colors.white, size: taille * 0.52),
                  Positioned(
                    right: taille * 0.2,
                    top: taille * 0.22,
                    child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: taille * 0.2),
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

/// « Droplet Pro » en dégradé, comme un nom de produit, pas un titre de
/// page.
class TitrePro extends StatelessWidget {
  const TitrePro({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(
        colors: OuroColors.isDark
            ? [Colors.white, const Color(0xFFFFD6F0), const Color(0xFFFFE2B8)]
            : kDegradePremium,
      ).createShader(r),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: OuroTypography.largeTitle.copyWith(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.05,
        ),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _CarteOffre(
              titre: l10n.pmTitle,
              prix: prixPro,
              mention: l10n.pmOnceForLife,
              choisi: proChoisi,
              vedette: l10n.pmBestValue,
              onTap: () => onChoisir(true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CarteOffre(
              titre: l10n.pmPackTitle,
              prix: prixPack,
              mention: l10n.pmOnce,
              choisi: !proChoisi,
              onTap: () => onChoisir(false),
            ),
          ),
        ],
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

class _CarteOffre extends StatelessWidget {
  const _CarteOffre({
    required this.titre,
    required this.prix,
    required this.mention,
    required this.choisi,
    required this.onTap,
    this.vedette,
  });

  final String titre;
  final int prix;
  final String mention;
  final bool choisi;
  final VoidCallback onTap;
  final String? vedette;

  @override
  Widget build(BuildContext context) {
    final sombre = OuroColors.isDark;
    final rayon = BorderRadius.circular(20);
    final carte = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      // Le liseré : le dégradé premium quand elle est choisie (padding de
      // 2 px autour de la carte intérieure), un trait discret sinon.
      padding: EdgeInsets.all(choisi ? 2 : 1),
      decoration: BoxDecoration(
        borderRadius: rayon,
        gradient: choisi ? const LinearGradient(colors: kDegradePremium) : null,
        color: choisi
            ? null
            : (sombre ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08)),
        boxShadow: choisi
            ? [
                BoxShadow(
                  color: kDegradePremium[1].withValues(alpha: sombre ? 0.35 : 0.22),
                  blurRadius: 22,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(choisi ? 18 : 19),
          color: sombre ? const Color(0xFF15131C) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.secondaryLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _Coche(choisi: choisi),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                prixLisible(prix),
                style: OuroTypography.title1.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              mention,
              style: OuroTypography.caption1.copyWith(color: OuroColors.tertiaryLabel),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: choisi,
      label: '$titre, ${prixLisible(prix)}, $mention',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          OuroHaptics.selection();
          onTap();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: carte),
            // Pour que le Stack prenne la taille de la carte.
            Opacity(opacity: 0, child: IgnorePointer(child: carte)),
            if (vedette != null)
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: kDegradePremium),
                    ),
                    child: Text(
                      vedette!.toUpperCase(),
                      style: OuroTypography.caption2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
        gradient: choisi ? const LinearGradient(colors: kDegradePremium) : null,
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
            color: sombre ? const Color(0xFF15131C) : Colors.white,
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
                    padding: const EdgeInsets.only(left: 60),
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
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.lerp(couleurAvantage(i), Colors.white, 0.18)!,
                                  couleurAvantage(i),
                                ],
                              ),
                            ),
                            child: Icon(avantages[i].icone, color: Colors.white, size: 18),
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
                child: BoutonPremium(libelle: libelle, onTap: onAcheter),
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
