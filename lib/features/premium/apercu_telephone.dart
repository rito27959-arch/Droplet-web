// ============================================================================
// L'APERÇU D'UNE FONCTION — LE TÉLÉPHONE DE TELEGRAM, À L'IDENTIQUE.
// ----------------------------------------------------------------------------
// Source : `VideoScreenPreview.java` et `PremiumAppIconsPreviewView.java`
// (Telegram Android). Leur page d'aperçu, c'est toujours la même scène :
//
//   • un FOND EN DÉGRADÉ multicolore qui glisse lentement ;
//   • des ÉTOILES qui flottent autour, mais jamais sur le téléphone : un
//     rectangle d'exclusion les tient à distance (`excludeRect`) ;
//   • un TÉLÉPHONE dessiné, pas photographié — deux rectangles arrondis
//     (cadre noir, puis liseré), de rayon 6,7 % de la largeur exactement
//     (`roundRadius = size * 0.0671f`) ;
//   • et DANS l'écran, une petite vidéo qui montre la fonction en train de
//     servir, en boucle.
//
// Droplet remplace la vidéo par la VRAIE interface, jouée en direct : le
// fond animé est le vrai shader, les bulles sont les vraies bulles, les
// icônes sont les vraies icônes de l'application. Rien n'est filmé, donc
// rien ne peut mentir sur ce qu'on recevra — et il n'y a pas un mégaoctet
// de vidéo à embarquer.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/droplet_logo.dart';
import '../chat/fonds_premium.dart';
import '../chat/telegram_gradient_background.dart';
import '../chat/mise_en_forme.dart';

/// Les dimensions d'un téléphone récent, en points : la démonstration est
/// construite là-dedans, puis réduite dans le cadre.
const double kLargeurEcranDemo = 360;
const double kHauteurEcranDemo = 772;

/// Les quatre couleurs du dégradé premium de Telegram.
const List<Color> kFondPremium = [
  Color(0xFF6C51FF),
  Color(0xFFB44BF0),
  Color(0xFFF2586B),
  Color(0xFFFFA932),
];

/// La scène complète : dégradé, étoiles, téléphone.
///
/// ── LES DEUX COMPORTEMENTS DE TELEGRAM ──────────────────────────────
///
/// 1. LA DÉMONSTRATION NE JOUE QUE SUR LA PAGE REGARDÉE, et elle REPART
///    DU DÉBUT à chaque fois qu'on arrive dessus (`VideoScreenPreview`
///    remet sa vidéo à zéro dans `setVisible`). On ne tombe donc jamais
///    au milieu d'une démonstration commencée pendant qu'on lisait
///    ailleurs — et rien ne tourne dans les pages voisines.
/// 2. PENDANT LE GLISSEMENT, LA SCÈNE SE DÉCOMPOSE : le téléphone suit
///    le doigt moins vite que la page, le fond encore moins, les étoiles
///    plus vite. Les trois plans se décalent — c'est la profondeur de
///    Telegram (`setOffset`), et c'est ce qui donne l'impression de
///    regarder à travers la page plutôt que de la faire défiler.
class ApercuTelephone extends StatelessWidget {
  const ApercuTelephone({
    super.key,
    required this.ecran,
    this.decale = 0,
    this.actif = true,
    this.glissement = 0,
  });

  /// Ce que montre l'écran du téléphone.
  final Widget ecran;

  /// Décale le dégradé et les étoiles, pour que deux pages voisines ne
  /// soient jamais identiques.
  final double decale;

  /// Cette page est-elle celle qu'on regarde ?
  final bool actif;

  /// La position de la page par rapport au centre : 0 au centre, −1 à
  /// gauche, +1 à droite.
  final double glissement;

  @override
  Widget build(BuildContext context) {
    final g = glissement.clamp(-1.0, 1.0);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(g * 26, 0),
            child: FondDegradePremium(decale: decale, actif: actif),
          ),
          Transform.translate(
            offset: Offset(-g * 70, 0),
            child: EtoilesPremium(actif: actif),
          ),
          Transform.translate(
            offset: Offset(-g * 42, 0),
            child: Transform.scale(
              scale: 1 - g.abs() * 0.12,
              child: Center(
                child: CadreTelephone(
                  child: TickerMode(enabled: actif, child: ecran),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le dégradé qui glisse, repris de `PremiumGradient.PremiumGradientTools` :
/// les quatre couleurs, et une matrice qu'on décale doucement.
class FondDegradePremium extends StatefulWidget {
  const FondDegradePremium({super.key, this.decale = 0, this.actif = true});

  final double decale;
  final bool actif;

  @override
  State<FondDegradePremium> createState() => _FondDegradePremiumState();
}

class _FondDegradePremiumState extends State<FondDegradePremium>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..bouclerSiAmbiant();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _PeintreDegrade(_c.value + widget.decale),
      ),
    );
  }
}

class _PeintreDegrade extends CustomPainter {
  _PeintreDegrade(this.avance);

  final double avance;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Le dégradé de base, incliné, qui glisse d'un dixième de largeur.
    final d = math.sin(avance * math.pi * 2) * 0.1;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1 + d, -1),
          end: Alignment(1 + d, 1),
          colors: kFondPremium,
        ).createShader(rect),
    );
    // Deux halos qui tournent par-dessus : c'est ce qui empêche le
    // dégradé de paraître imprimé.
    for (var i = 0; i < 2; i++) {
      final a = avance * math.pi * 2 + i * math.pi;
      final centre = Offset(
        size.width * (0.5 + 0.35 * math.cos(a)),
        size.height * (0.5 + 0.3 * math.sin(a * 1.3)),
      );
      final rayon = size.longestSide * 0.55;
      canvas.drawCircle(
        centre,
        rayon,
        Paint()
          ..shader = RadialGradient(
            colors: [
              kFondPremium[i == 0 ? 1 : 3].withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: centre, radius: rayon)),
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreDegrade old) => old.avance != avance;
}

/// Les étoiles qui flottent autour du téléphone (`StarParticlesView`).
class EtoilesPremium extends StatefulWidget {
  const EtoilesPremium({super.key, this.nombre = 26, this.actif = true});

  final int nombre;
  final bool actif;

  @override
  State<EtoilesPremium> createState() => _EtoilesPremiumState();
}

class _EtoilesPremiumState extends State<EtoilesPremium>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..bouclerSiAmbiant();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) =>
          CustomPaint(painter: _PeintreEtoiles(_c.value, widget.nombre)),
    );
  }
}

class _PeintreEtoiles extends CustomPainter {
  _PeintreEtoiles(this.avance, this.nombre);

  final double avance;
  final int nombre;

  @override
  void paint(Canvas canvas, Size size) {
    // ⚠️ AUCUNE ÉTOILE SUR LE TÉLÉPHONE. Telegram tient les particules à
    // l'écart avec un rectangle d'exclusion ; sans lui, elles passent
    // devant l'interface qu'on est justement en train de montrer.
    final exclusion = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.62,
      height: size.height * 0.88,
    );
    final hasard = math.Random(3);
    final pinceau = Paint()..color = Colors.white;
    for (var i = 0; i < nombre; i++) {
      final base = Offset(
        hasard.nextDouble() * size.width,
        hasard.nextDouble() * size.height,
      );
      final phase = hasard.nextDouble();
      final vitesse = 0.4 + hasard.nextDouble() * 0.9;
      final t = (avance * vitesse + phase) % 1.0;
      // Elles montent doucement et reviennent en bas, sans à-coup.
      final p = Offset(
        base.dx + math.sin((t + phase) * math.pi * 2) * 10,
        (base.dy - t * size.height * 0.5) % size.height,
      );
      if (exclusion.contains(p)) continue;
      final taille = 1.0 + hasard.nextDouble() * 2.2;
      final alpha = (math.sin(t * math.pi) * 0.9).clamp(0.0, 1.0);
      pinceau.color = Colors.white.withValues(alpha: alpha * 0.85);
      _etoile(canvas, p, taille, pinceau);
    }
  }

  /// Une petite étoile à quatre branches, comme celles de Telegram.
  void _etoile(Canvas canvas, Offset centre, double rayon, Paint pinceau) {
    final chemin = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      chemin.moveTo(centre.dx, centre.dy);
      chemin.quadraticBezierTo(
        centre.dx + math.cos(a + 0.4) * rayon * 0.6,
        centre.dy + math.sin(a + 0.4) * rayon * 0.6,
        centre.dx + math.cos(a) * rayon * 2.2,
        centre.dy + math.sin(a) * rayon * 2.2,
      );
      chemin.quadraticBezierTo(
        centre.dx + math.cos(a - 0.4) * rayon * 0.6,
        centre.dy + math.sin(a - 0.4) * rayon * 0.6,
        centre.dx,
        centre.dy,
      );
    }
    canvas.drawPath(chemin, pinceau);
  }

  @override
  bool shouldRepaint(_PeintreEtoiles old) => old.avance != avance;
}

/// Le téléphone dessiné : cadre noir, liseré, écran rogné.
///
/// Le rayon vaut 6,7 % de la largeur — la valeur exacte de Telegram
/// (`roundRadius = size * 0.0671f`).
class CadreTelephone extends StatelessWidget {
  const CadreTelephone({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        // Le téléphone tient dans la hauteur, au format d'un mobile récent.
        final hauteur = contraintes.maxHeight * 0.92;
        final largeur = math.min(hauteur * 9 / 19.3, contraintes.maxWidth * 0.62);
        final rayon = largeur * 0.0671 * 2.2;
        const cadre = 5.0;
        return SizedBox(
          width: largeur,
          height: largeur * 19.3 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(rayon),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(cadre),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rayon - cadre),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ⚠️ L'ÉCRAN EST DESSINÉ EN TAILLE RÉELLE, PUIS RÉDUIT.
                  //
                  // Construire l'interface à la taille du cadre obligeait
                  // à écrire en 9 points, et le nom du contact se coupait
                  // lettre par lettre. Telegram ne fait pas autrement : il
                  // FILME un vrai téléphone et met la vidéo à l'échelle.
                  // Ici c'est la vraie interface, aux vraies dimensions,
                  // simplement vue de plus loin.
                  ColoredBox(
                    color: OuroColors.systemBackground,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: kLargeurEcranDemo,
                        height: kHauteurEcranDemo,
                        child: child,
                      ),
                    ),
                  ),
                  // L'îlot du haut : il suffit à faire lire « téléphone ».
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: largeur * 0.28,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── LES SCÉNARIOS ──────────────────────────────────────────────────────────
//
// Chaque fonction se montre en train de servir, en boucle : c'est ce que
// font les petites vidéos de Telegram. Ici ce sont les vrais composants,
// pilotés par une horloge.

/// L'ÉCRAN D'UNE VRAIE DISCUSSION, à l'échelle du téléphone.
///
/// ⚠️ PAS UN FOND NOIR AVEC UNE BULLE POSÉE DESSUS. Une fonction ne se
/// montre pas dans le vide : Telegram filme son application EN TRAIN DE
/// SERVIR — on y voit l'en-tête, le fond de discussion, l'historique, la
/// barre de saisie. C'est ce qui fait qu'on se projette : ce n'est pas une
/// démonstration, c'est quelqu'un en train d'écrire à quelqu'un.
class EcranDiscussion extends StatelessWidget {
  const EcranDiscussion({
    super.key,
    required this.messages,
    this.fond,
    this.saisie,
    this.nom = 'Amina',
    this.doigt,
  });

  /// Les bulles, du plus ancien au plus récent.
  final List<Widget> messages;

  /// Le fond de la discussion. À défaut, le dégradé Droplet.
  final Widget? fond;

  /// Ce qu'on est en train de taper, s'il y a lieu.
  final String? saisie;

  final String nom;

  /// Où poser le doigt qui agit, en fraction de l'écran. `null` : aucun.
  final Alignment? doigt;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        fond ??
            TelegramGradientBackground(
              tick: 0,
              couleurs: TelegramGradientPalettes.pour('mesh', sombre: sombre)!,
            ),
        Column(
          children: [
            _EnTete(nom: nom),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: messages,
                ),
              ),
            ),
            _BarreSaisie(texte: saisie),
          ],
        ),
        if (doigt != null) _Doigt(position: doigt!),
      ],
    );
  }
}

/// L'en-tête : retour, avatar, nom, « en ligne », appels.
class _EnTete extends StatelessWidget {
  const _EnTete({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 46, 14, 12),
      color: OuroColors.secondarySystemBackground.withValues(alpha: 0.86),
      child: Row(
        children: [
          Icon(Icons.chevron_left_rounded, size: 28, color: OuroColors.accent),
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 10, left: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kFondPremium.first, kFondPremium[2]],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              nom.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OuroColors.label,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).apOnline,
                  style: TextStyle(
                    fontSize: 12,
                    color: OuroColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.videocam_rounded, size: 22, color: OuroColors.accent),
          const SizedBox(width: 6),
          Icon(Icons.phone_rounded, size: 20, color: OuroColors.accent),
        ],
      ),
    );
  }
}

/// La barre de saisie, avec son texte en cours de frappe.
class _BarreSaisie extends StatelessWidget {
  const _BarreSaisie({this.texte});

  final String? texte;

  @override
  Widget build(BuildContext context) {
    final ecrit = (texte ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 22),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: OuroColors.secondarySystemBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ecrit ? texte! : AppLocalizations.of(context).apMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: ecrit ? OuroColors.label : OuroColors.tertiaryLabel,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: OuroColors.accentRempli,
            ),
            child: Icon(
              ecrit ? Icons.send_rounded : Icons.mic_rounded,
              size: 22,
              color: OuroColors.texteSurAccent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Le doigt : un rond clair, comme sur les captures d'écran d'Apple.
class _Doigt extends StatelessWidget {
  const _Doigt({required this.position});

  final Alignment position;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: position,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

/// Une bulle de conversation, à l'échelle du téléphone.
/// Une bulle de conversation, à l'échelle du téléphone.
class _Bulle extends StatelessWidget {
  const _Bulle({
    required this.enfant,
    this.mine = false,
    this.apparition = 1,
  });

  final Widget enfant;
  final bool mine;
  final double apparition;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: apparition.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - apparition.clamp(0.0, 1.0))),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 258),
            decoration: BoxDecoration(
              color: mine
                  ? OuroColors.accent
                  : OuroColors.secondarySystemBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(19),
                topRight: const Radius.circular(19),
                bottomLeft: Radius.circular(mine ? 19 : 6),
                bottomRight: Radius.circular(mine ? 6 : 19),
              ),
            ),
            // `merge` et non un style neuf : la police de l'app doit
            // rester, sinon l'aperçu ne ressemble plus à l'app.
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                color: mine ? Colors.white : OuroColors.label,
              ),
              child: enfant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Une horloge en boucle, partagée par tous les scénarios.
class _Boucle extends StatefulWidget {
  const _Boucle({required this.duree, required this.builder});

  final Duration duree;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<_Boucle> createState() => _BoucleState();
}

class _BoucleState extends State<_Boucle> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duree)
        ..bouclerSiAmbiant();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠️ REPART DU DÉBUT. `TickerMode` suspend l'horloge des pages qu'on
    // ne regarde pas ; quand celle-ci revient, la démonstration doit
    // reprendre à sa première image, pas là où elle s'était arrêtée il y
    // a trois pages — sinon on arrive au milieu d'un geste.
    if (TickerMode.getValuesNotifier(context).value.enabled) {
      _c.value = 0;
      _c.bouclerSiAmbiant();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => widget.builder(context, _c.value),
      );
}

/// Fonds animés : la discussion sur le vrai fond premium, et un message
/// qui part — le fond tourne d'un cran à ce moment-là.
class ScenarioFonds extends StatelessWidget {
  const ScenarioFonds({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Boucle(
      duree: const Duration(seconds: 9),
      builder: (context, t) {
        // Le message se tape, part, puis la réponse arrive : le rythme
        // d'un vrai échange, pas d'une démonstration.
        final frappe = (t / 0.30).clamp(0.0, 1.0);
        final texte = l10n.apBgSend;
        final envoye = t > 0.34;
        final reponse = ((t - 0.55) / 0.12).clamp(0.0, 1.0);
        final tick = t > 0.34 ? 1 : 0;
        return EcranDiscussion(
          fond: FondPremiumAnime(fond: FondsPremium.tous[2], tick: tick),
          saisie: envoye
              ? null
              : texte.substring(0, (texte.length * frappe).round()),
          doigt: t > 0.30 && t < 0.36
              ? const Alignment(0.86, 0.62)
              : null,
          messages: [
            _Bulle(enfant: Text(l10n.apBgA)),
            if (envoye) _Bulle(mine: true, enfant: Text(texte)),
            if (reponse > 0)
              _Bulle(
                apparition: reponse,
                enfant: Text(l10n.apBgB),
              ),
          ],
        );
      },
    );
  }
}

/// Mise en forme : on écrit, on sélectionne, le style s'applique.
class ScenarioMiseEnForme extends StatelessWidget {
  const ScenarioMiseEnForme({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // ⚠️ LES MARQUEURS SURVIVENT À LA TRADUCTION. Chaque langue garde ses
    // `**`, `__`, `` ` `` et `||` autour de ses propres mots : c'est eux
    // que la démonstration met en forme sous les yeux.
    final texte = l10n.apFormatDemo;
    const style = TextStyle(fontSize: 15, color: Colors.white, height: 1.3);
    return _Boucle(
      duree: const Duration(seconds: 9),
      builder: (context, t) {
        final total = MiseEnForme.longueurVisible(texte);
        final frappe = (t / 0.45).clamp(0.0, 1.0);
        final ecrit = MiseEnForme.partiel(texte, (total * frappe).round());
        final envoye = t > 0.52;
        return EcranDiscussion(
          saisie: envoye ? null : MiseEnForme.sansMarqueurs(ecrit),
          doigt: t > 0.47 && t < 0.53 ? const Alignment(0.86, 0.62) : null,
          messages: [
            _Bulle(enfant: Text(l10n.apFormatQ)),
            if (envoye)
              _Bulle(
                mine: true,
                enfant: Text.rich(
                  TextSpan(
                    style: style,
                    children: MiseEnForme.enSpans(texte, style: style),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Transcription : un vocal arrive, on appuie sur « A », le texte se
/// déplie sous l'onde.
class ScenarioTranscription extends StatelessWidget {
  const ScenarioTranscription({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Boucle(
      duree: const Duration(seconds: 8),
      builder: (context, t) {
        final appui = t > 0.30 && t < 0.38;
        final ouvert = ((t - 0.36) / 0.16).clamp(0.0, 1.0);
        return EcranDiscussion(
          doigt: appui ? const Alignment(0.30, 0.30) : null,
          messages: [
            _Bulle(mine: true, enfant: Text(l10n.apVoiceQ)),
            _Bulle(
              enfant: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          size: 26, color: OuroColors.accent),
                      const SizedBox(width: 3),
                      for (var i = 0; i < 12; i++)
                        Container(
                          width: 3,
                          height: 7 + (i % 5) * 4.0,
                          margin: const EdgeInsets.symmetric(horizontal: 1.4),
                          decoration: BoxDecoration(
                            color: OuroColors.accent.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      const SizedBox(width: 5),
                      AnimatedScale(
                        scale: appui ? 0.86 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: OuroColors.label.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            ouvert > 0.5
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.text_fields_rounded,
                            size: 16,
                            color: OuroColors.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ClipRect(
                    child: Align(
                      heightFactor: ouvert,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: OuroColors.label.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(l10n.apVoiceText),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Traduction : un message arrive en anglais, on le traduit, l'original
/// reste au-dessus.
class ScenarioTraduction extends StatelessWidget {
  const ScenarioTraduction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Boucle(
      duree: const Duration(seconds: 8),
      builder: (context, t) {
        final appui = t > 0.26 && t < 0.34;
        final ouvert = ((t - 0.32) / 0.18).clamp(0.0, 1.0);
        return EcranDiscussion(
          nom: 'James',
          doigt: appui ? const Alignment(-0.25, 0.22) : null,
          messages: [
            _Bulle(mine: true, enfant: Text(l10n.apTransQ)),
            _Bulle(
              enfant: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ⚠️ LA SOURCE N'EST JAMAIS DANS LA LANGUE DE
                  // L'UTILISATEUR. Sinon l'original et sa traduction
                  // seraient le même texte, et l'aperçu ne montrerait
                  // plus rien : `apTransSource` est en anglais partout,
                  // sauf en anglais où elle passe au français.
                  Text(l10n.apTransSource),
                  ClipRect(
                    child: Align(
                      heightFactor: ouvert,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 5),
                          Container(height: 0.5, color: OuroColors.separator),
                          const SizedBox(height: 4),
                          Text(
                            l10n.apAutoTranslated,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: OuroColors.tertiaryLabel,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(l10n.apTransResult),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Autocollants : la goutte de Droplet arrive dans la discussion.
///
/// C'est le SEUL avantage qui n'avait pas d'aperçu — sa page montrait une
/// icône dans un rond pendant que les six autres montraient un téléphone.
/// L'autocollant n'est pas une image chargée : c'est le logo de l'app,
/// dessiné en direct par `DropletLogo`. Il arrive de côté, dépasse sa
/// place, revient — le rebond d'un autocollant qu'on lâche, pas
/// l'apparition d'une vignette.
class ScenarioAutocollants extends StatelessWidget {
  const ScenarioAutocollants({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Boucle(
      duree: const Duration(seconds: 7),
      builder: (context, t) {
        final appui = t > 0.22 && t < 0.30;
        final arrivee = ((t - 0.28) / 0.26).clamp(0.0, 1.0);
        // `elasticOut` dépasse puis revient : c'est ce dépassement qui
        // fait qu'on voit un objet se poser, et pas un calque s'afficher.
        final rebond = arrivee == 0 ? 0.0 : Curves.elasticOut.transform(arrivee);
        // Une fois posé, il respire à peine — assez pour qu'il ne soit
        // pas mort, pas assez pour qu'il réclame l'attention.
        final souffle = arrivee < 1
            ? 0.0
            : math.sin((t - 0.54) * math.pi * 4) * 0.02;
        return EcranDiscussion(
          doigt: appui ? const Alignment(0.62, 0.66) : null,
          messages: [
            _Bulle(enfant: Text(l10n.apStickerQ)),
            if (arrivee > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2, right: 4),
                  child: Transform.scale(
                    scale: (rebond + souffle).clamp(0.0, 1.3),
                    child: Transform.rotate(
                      angle: (1 - arrivee) * 0.55,
                      child: const DropletLogo(
                        radius: 34,
                        glow: false,
                        animate: false,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Icônes : les VRAIES icônes de Droplet, qui tournent lentement autour de
/// celle du milieu — la scène de `PremiumAppIconsPreviewView`.
class ScenarioIcones extends StatelessWidget {
  const ScenarioIcones({super.key});

  static const _fichiers = [
    'assets/icon/variants/droplet_01.png',
    'assets/icon/variants/droplet_04.png',
    'assets/icon/variants/droplet_07.png',
    'assets/icon/variants/droplet_10.png',
    'assets/icon/variants/droplet_12.png',
  ];

  @override
  Widget build(BuildContext context) {
    // ⚠️ LES TAILLES SUIVENT LA LARGEUR DE L'ÉCRAN DESSINÉ. Fixées en
    // points, elles se chevauchaient toutes dans un téléphone de cent
    // points de large — et l'aperçu ne montrait plus qu'un tas.
    return LayoutBuilder(
      builder: (context, contraintes) {
        final w = contraintes.maxWidth;
        final centre = w * 0.34;
        final petite = w * 0.21;
        return _Boucle(
          duree: const Duration(seconds: 10),
          builder: (context, t) => Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: OuroColors.systemBackground),
              Center(child: _Icone(fichier: _fichiers.first, taille: centre)),
              for (var i = 1; i < _fichiers.length; i++)
                Builder(
                  builder: (context) {
                    final a = t * math.pi * 2 + i * math.pi / 2;
                    return Align(
                      // Une orbite large et aplatie : les satellites
                      // passent au-dessus et en dessous sans jamais
                      // recouvrir l'icône du milieu.
                      alignment: Alignment(
                        math.cos(a) * 0.80,
                        math.sin(a) * 0.46,
                      ),
                      child: Transform.translate(
                        offset: Offset(0, math.sin(a * 2) * 3),
                        child: _Icone(fichier: _fichiers[i], taille: petite),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Icone extends StatelessWidget {
  const _Icone({required this.fichier, required this.taille});

  final String fichier;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(taille * 0.23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: taille * 0.22,
            offset: Offset(0, taille * 0.08),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(fichier, fit: BoxFit.cover),
    );
  }
}

/// Badge : le nom, et le badge qui s'allume.
class ScenarioBadge extends StatelessWidget {
  const ScenarioBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _Boucle(
      duree: const Duration(seconds: 5),
      builder: (context, t) {
        final eclat = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    kFondPremium.first,
                    kFondPremium.last,
                  ]),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amina',
                    style: OuroTypography.headline.copyWith(
                      color: OuroColors.label,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ShaderMask(
                    shaderCallback: (rect) => LinearGradient(
                      colors: kFondPremium,
                      transform: GradientRotation(eclat * math.pi),
                    ).createShader(rect),
                    child: const Icon(Icons.verified_rounded,
                        size: 15, color: Colors.white),
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context).apOnline,
                style: TextStyle(
                    fontSize: 10, color: OuroColors.secondaryLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}
