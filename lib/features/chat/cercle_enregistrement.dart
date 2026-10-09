// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE CERCLE QUI GROSSIT AVEC LA VOIX, ET LE CADENAS AU-DESSUS — la partie
// visible de l'enregistrement maintenu.
//
// ── LES TROIS COUCHES, DE L'ARRIÈRE VERS L'AVANT ──────────────────────
//
//   1. DEUX GOUTTES organiques, translucides, qui ondulent autour du
//      cercle. Ce ne sont pas des cercles flous : ce sont des formes à
//      11 et 12 points, dont chaque point part vers un rayon tiré au sort
//      puis recommence. C'est ce qui donne le mouvement « vivant », qu'un
//      simple cercle qui pulse n'imite pas.
//   2. LE CERCLE PLEIN, dont le rayon suit le niveau du micro : 41 points
//      au silence, 71 à pleine voix.
//   3. L'ICÔNE au centre — micro, caméra, ou flèche d'envoi.
//
// ── ⚠️ POURQUOI LES GOUTTES NE SONT PAS UN DÉTAIL DÉCORATIF ───────────
//
// Elles sont la seule chose qui bouge quand on se tait. Le cercle, lui,
// se fige au rayon minimal : sans les gouttes, un silence de deux
// secondes donne une interface parfaitement immobile, et on se demande si
// ça enregistre encore. Elles ondulent indépendamment de la voix — c'est
// leur rôle.
//
// ── ⚠️ CE FICHIER NE DESSINE QUE. ─────────────────────────────────────
//
// Il ne décide de rien : ni quand l'enregistrement commence, ni s'il faut
// annuler. Tout cela est dans `geste_enregistrement.dart`, où ça se
// rejoue. Mélanger les deux rendrait la décision invérifiable.
//
// Les mesures viennent du code source de Telegram pour Android
// (`ChatActivityEnterView.java`, `BlobDrawable.java`), relevées ligne par
// ligne. Rien n'est recopié : le Java dessine sur un `Canvas` Android,
// aucune ligne n'est transposable telle quelle.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import 'geste_enregistrement.dart';

// ══ LA GOUTTE ═══════════════════════════════════════════════════════════

/// Une forme organique fermée à [n] points, qui ondule en continu.
///
/// Chaque point a un rayon courant et un rayon suivant, tirés au sort
/// entre [rayonMin] et [rayonMax] ; il avance de l'un vers l'autre à sa
/// propre vitesse, et quand il arrive, on lui tire une nouvelle
/// destination. Les points n'étant jamais synchronisés, la forme ne
/// repasse jamais deux fois par le même état.
///
/// ⚠️ LE CONTOUR EST EN COURBES DE BÉZIER, PAS EN SEGMENTS. Relier douze
/// points à la règle donnerait un polygone qui scintille à chaque
/// recalcul. La longueur des poignées vaut `(4/3)·tan(π/2N)` fois le
/// rayon — la valeur qui fait passer une Bézier cubique exactement par un
/// arc de cercle quand tous les rayons sont égaux. C'est ce qui garantit
/// qu'au repos la goutte est un cercle parfait, et non un presque-cercle.
class Goutte {
  Goutte(this.n, {required this.rayonMin, required this.rayonMax, int? graine})
      : _hasard = math.Random(graine),
        _l = (4.0 / 3.0) * math.tan(math.pi / (2 * n)),
        _rayon = List.filled(n, 0),
        _angle = List.filled(n, 0),
        _rayonSuivant = List.filled(n, 0),
        _angleSuivant = List.filled(n, 0),
        _avance = List.filled(n, 0),
        _vitesse = List.filled(n, 0) {
    regenerer();
  }

  /// Combien de points. Telegram en met 11 pour la petite goutte et 12
  /// pour la grande : des nombres premiers entre eux, pour que les deux
  /// formes ne retombent jamais en phase. (CAEV.java:1999-2000)
  final int n;

  double rayonMin;
  double rayonMax;

  final math.Random _hasard;
  final double _l;
  final List<double> _rayon;
  final List<double> _angle;
  final List<double> _rayonSuivant;
  final List<double> _angleSuivant;
  final List<double> _avance;
  final List<double> _vitesse;

  /// (BlobDrawable.java:15-17)
  static const double vitesseMax = 8.2;
  static const double vitesseMin = 0.8;

  void _tirer(List<double> rayons, List<double> angles, int i) {
    final ecartAngle = 360.0 / n * 0.05;
    final ecartRayon = rayonMax - rayonMin;
    rayons[i] = rayonMin + _hasard.nextDouble() * ecartRayon;
    angles[i] = 360.0 / n * i + _hasard.nextDouble() * ecartAngle;
    _vitesse[i] = 0.017 + 0.003 * _hasard.nextDouble();
  }

  void regenerer() {
    for (var i = 0; i < n; i++) {
      _tirer(_rayon, _angle, i);
      _tirer(_rayonSuivant, _angleSuivant, i);
      _avance[i] = 0;
    }
  }

  /// Fait avancer la forme d'une image.
  ///
  /// [amplitude] accélère tout le monde : plus on parle, plus ça remue.
  /// [facteurVitesse] vaut 1,01 pour la petite goutte et 1,02 pour la
  /// grande — un écart minuscule, qui suffit à les désynchroniser
  /// durablement. (CAEV.java:2319-2321)
  void avancer(double amplitude, double facteurVitesse) {
    for (var i = 0; i < n; i++) {
      _avance[i] +=
          _vitesse[i] * vitesseMin + amplitude * _vitesse[i] * vitesseMax * facteurVitesse;
      if (_avance[i] >= 1) {
        _avance[i] = 0;
        _rayon[i] = _rayonSuivant[i];
        _angle[i] = _angleSuivant[i];
        _tirer(_rayonSuivant, _angleSuivant, i);
      }
    }
  }

  static Offset _tourner(Offset p, Offset centre, double degres) {
    final r = degres * math.pi / 180;
    final c = math.cos(r), s = math.sin(r);
    final dx = p.dx - centre.dx, dy = p.dy - centre.dy;
    return Offset(centre.dx + dx * c - dy * s, centre.dy + dx * s + dy * c);
  }

  Path chemin(Offset centre) {
    final chemin = Path();
    for (var i = 0; i < n; i++) {
      final suivant = i + 1 < n ? i + 1 : 0;
      final a = _avance[i], b = _avance[suivant];
      final r1 = _rayon[i] * (1 - a) + _rayonSuivant[i] * a;
      final r2 = _rayon[suivant] * (1 - b) + _rayonSuivant[suivant] * b;
      final angle1 = _angle[i] * (1 - a) + _angleSuivant[i] * a;
      final angle2 = _angle[suivant] * (1 - b) + _angleSuivant[suivant] * b;

      // La poignée est calculée sur la MOYENNE des deux rayons : prendre
      // l'un ou l'autre ferait boiter le contour d'un point sur deux.
      final l = _l * (math.min(r1, r2) + (math.max(r1, r2) - math.min(r1, r2)) / 2);

      final depart = _tourner(Offset(centre.dx, centre.dy - r1), centre, angle1);
      final departPoignee =
          _tourner(Offset(centre.dx + l, centre.dy - r1), centre, angle1);
      final arrivee = _tourner(Offset(centre.dx, centre.dy - r2), centre, angle2);
      final arriveePoignee =
          _tourner(Offset(centre.dx - l, centre.dy - r2), centre, angle2);

      if (i == 0) chemin.moveTo(depart.dx, depart.dy);
      chemin.cubicTo(departPoignee.dx, departPoignee.dy, arriveePoignee.dx,
          arriveePoignee.dy, arrivee.dx, arrivee.dy);
    }
    chemin.close();
    return chemin;
  }
}

// ══ L'ÉTAT DESSINÉ ══════════════════════════════════════════════════════

/// Tout ce dont le peintre a besoin, rassemblé pour qu'il n'aille rien
/// chercher ailleurs.
@immutable
class EtatCercle {
  const EtatCercle({
    required this.amplitude,
    required this.entree,
    required this.progressionAnnulation,
    required this.progressionVerrou,
    required this.verrouille,
    required this.versEnvoi,
    required this.modeVideo,
    required this.respiration,
  });

  /// 0 → 1, le niveau du micro, déjà lissé.
  final double amplitude;

  /// 0 → 1, l'apparition du cercle.
  final double entree;

  /// 1 → 0 vers l'annulation.
  final double progressionAnnulation;

  /// 0 → 1, la fermeture du cadenas.
  final double progressionVerrou;

  final bool verrouille;

  /// 0 → 1 : le micro devient flèche d'envoi, en 150 ms.
  /// (CAEV.java:2280)
  final double versEnvoi;

  final bool modeVideo;

  /// 0 → 1 → 0, lentement : le battement de fond, qui ne dépend ni du
  /// micro ni du doigt. (CAEV.java:2297-2309)
  final double respiration;
}

// ══ LE PEINTRE ══════════════════════════════════════════════════════════

class PeintreCercleEnregistrement extends CustomPainter {
  PeintreCercleEnregistrement({
    required this.etat,
    required this.petiteGoutte,
    required this.grandeGoutte,
    required this.accent,
    required this.encre,
  });

  final EtatCercle etat;
  final Goutte petiteGoutte;
  final Goutte grandeGoutte;
  final Color accent;

  /// La couleur de l'icône au centre. Vient du système de contraste, pas
  /// d'un blanc en dur : sur un accent clair, un micro blanc disparaît.
  final Color encre;

  /// Les opacités des deux gouttes. (WaveDrawable.java:32-33)
  static const double _opaciteGrande = 0.30;
  static const double _opacitePetite = 0.15;

  @override
  void paint(Canvas toile, Size taille) {
    if (etat.entree <= 0) return;

    final centre = Offset(taille.width / 2, taille.height / 2);

    final sc = echelleEntreeCercle(etat.entree.clamp(0.0, 1.0));
    final scGlissement = echelleGlissement(etat.progressionAnnulation);
    final rayon = rayonCercleMicro(etat.amplitude) * sc * scGlissement;

    // ⚠️ LES GOUTTES S'EFFACENT PLUS VITE QUE LE CERCLE pendant
    // l'annulation. Elles sont normalisées sur les 30 % de course qui
    // précèdent le seuil d'interruption : passé ce point, elles ont
    // disparu et il ne reste que le cercle qui s'en va. Garder des ondes
    // autour d'un enregistrement qu'on est en train de jeter donne un
    // signal exactement contraire à ce qui se passe. (CAEV.java:2327)
    final vieGouttes =
        (etat.progressionAnnulation / 0.7).clamp(0.0, 1.0) * sc;

    if (vieGouttes > 0.01) {
      // Les bornes des gouttes respirent avec l'amplitude.
      // (CAEV.java:2312-2316)
      petiteGoutte
        ..rayonMin = 47
        ..rayonMax = 47 + 15 * 0.6;
      grandeGoutte
        ..rayonMin = 50
        ..rayonMax = 50 + 12 * 0.6;

      // (CAEV.java:2339-2343) — SCALE_BIG_MIN / SCALE_SMALL_MIN
      final echelleGrande = vieGouttes * (0.878 + 1.4 * etat.amplitude);
      final echellePetite = vieGouttes * (0.926 + 1.4 * etat.amplitude);

      _peindreGoutte(toile, centre, grandeGoutte, echelleGrande,
          accent.withValues(alpha: _opaciteGrande));
      _peindreGoutte(toile, centre, petiteGoutte, echellePetite,
          accent.withValues(alpha: _opacitePetite));
    }

    // Le cercle plein.
    toile.drawCircle(centre, rayon, Paint()..color = accent);

    _peindreIcone(toile, centre, rayon);
  }

  void _peindreGoutte(
      Canvas toile, Offset centre, Goutte goutte, double echelle, Color couleur) {
    if (echelle <= 0) return;
    toile
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(echelle)
      ..translate(-centre.dx, -centre.dy)
      ..drawPath(goutte.chemin(centre), Paint()..color = couleur)
      ..restore();
  }

  /// Le micro (ou la caméra) et la flèche d'envoi, l'un grandissant
  /// pendant que l'autre rétrécit, autour du même centre.
  ///
  /// ⚠️ CE N'EST PAS UN FONDU SIMPLE. Les deux icônes changent AUSSI
  /// d'échelle, en sens inverse : la flèche naît d'un point, le micro
  /// s'éteint vers un point. Un fondu seul donnerait deux icônes
  /// superposées à mi-course, ce qui se lit comme un défaut d'affichage.
  /// (CAEV.java:2444-2473)
  void _peindreIcone(Canvas toile, Offset centre, double rayon) {
    final t = etat.versEnvoi.clamp(0.0, 1.0);
    final taille = math.min(24.0, rayon * 0.6);

    if (t < 1) {
      _glyphe(
        toile,
        centre,
        etat.modeVideo ? Icons.videocam_rounded : Icons.mic_rounded,
        taille * (1 - t),
        encre.withValues(alpha: 1 - t),
      );
    }
    if (t > 0) {
      _glyphe(toile, centre, Icons.arrow_upward_rounded, taille * t,
          encre.withValues(alpha: t));
    }
  }

  void _glyphe(
      Canvas toile, Offset centre, IconData icone, double taille, Color couleur) {
    if (taille <= 0.5) return;
    final peintre = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icone.codePoint),
        style: TextStyle(
          fontSize: taille,
          fontFamily: icone.fontFamily,
          package: icone.fontPackage,
          color: couleur,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    peintre.paint(
      toile,
      centre - Offset(peintre.width / 2, peintre.height / 2),
    );
  }

  @override
  bool shouldRepaint(PeintreCercleEnregistrement vieux) => true;
}

// ══ LE CADENAS ══════════════════════════════════════════════════════════

/// Le cadenas qui monte au-dessus du micro : il se ferme à mesure qu'on
/// glisse vers le haut, puis devient un bouton pause.
///
/// ── ⚠️ DU VERRE, PAS UN PAVÉ ─────────────────────────────────────────
///
/// La première version posait le cadenas sur `secondarySystemBackground`,
/// une teinte OPAQUE : sur un fond de conversation coloré, ça donnait un
/// pavé noir collé au-dessus du micro. Telegram dessine ce fond avec un
/// `BlurredBackgroundDrawable` (ChatActivityEnterView.java:1729-1732) : le
/// contenu de la conversation transparaît, flouté. C'est ce qui fait que
/// le cadenas paraît POSÉ sur la conversation au lieu d'y être découpé.
///
/// ── LA GÉOMÉTRIE, TELLE QUE RELEVÉE ──────────────────────────────────
///
///   • capsule 36 de large, 36 + 14 × ouverture de haut — 50 ouverte,
///     36 fermée (CAEV:1416, 1427) ;
///   • arceau : demi-cercle de rayon 4, trait 1,7 (CAEV:1251, 1613-1626) ;
///   • la jambe GAUCHE de l'arceau ne touche pas le corps tant que c'est
///     ouvert, et respire ; la droite reste plantée (CAEV:1620-1624) ;
///   • rotation jusqu'à 9° pendant la montée (CAEV:1431) ;
///   • le trou de serrure : un point de rayon 2 (CAEV:1673).
///
/// ── ⚠️ LE CHEVRON EST LA MOITIÉ DE L'EXPLICATION ─────────────────────
///
/// Un cadenas seul dit « on peut verrouiller ». Le chevron qui respire
/// dessous dit COMMENT : vers le haut. Sans lui, la plupart des gens ne
/// découvrent jamais le geste. Il s'efface à mesure que le cadenas se
/// ferme — une fois qu'on monte, l'indication a fait son travail.
class VerrouEnregistrement extends StatefulWidget {
  const VerrouEnregistrement({
    super.key,
    required this.fermeture,
    required this.verrouille,
  });

  /// 0 = ouvert, 1 = fermé — suit le doigt, en continu.
  final double fermeture;

  /// Verrouillé : le cadenas devient pause.
  final bool verrouille;

  static const double largeur = 36;
  static const double hauteurOuverte = 50;
  static const double hauteurFermee = 36;

  @override
  State<VerrouEnregistrement> createState() => _VerrouEnregistrementState();
}

class _VerrouEnregistrementState extends State<VerrouEnregistrement>
    with TickerProviderStateMixin {
  /// La respiration : ±0,01 par image chez Telegram, soit un aller en
  /// ~1,7 s (CAEV:2297-2309). Linéaire, en va-et-vient.
  late final AnimationController _respiration = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1670),
  )..bouclerSiAmbiant(reverse: true, repos: 0);

  /// Le passage cadenas → pause, au moment du verrouillage.
  ///
  /// ⚠️ 250 ms, easeOutQuint — la valeur de `snapAnimationProgress` chez
  /// Telegram (CAEV:4670-4672). Une bascule instantanée se lirait comme un
  /// clignotement ; plus lente, comme une hésitation au moment précis où
  /// il faut confirmer que c'est acquis.
  late final AnimationController _bascule = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: widget.verrouille ? 1 : 0,
  );

  @override
  void didUpdateWidget(VerrouEnregistrement vieux) {
    super.didUpdateWidget(vieux);
    if (widget.verrouille != vieux.verrouille) {
      widget.verrouille ? _bascule.forward() : _bascule.reverse();
    }
  }

  @override
  void dispose() {
    _respiration.dispose();
    _bascule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_respiration, _bascule]),
      builder: (context, _) {
        final pause = Curves.easeOutQuint.transform(_bascule.value);
        // Verrouillé, la capsule est fermée quoi que dise le doigt — il
        // est peut-être déjà ailleurs.
        final f = math.max(widget.fermeture.clamp(0.0, 1.0), pause);
        final hauteur = VerrouEnregistrement.hauteurFermee +
            (VerrouEnregistrement.hauteurOuverte -
                    VerrouEnregistrement.hauteurFermee) *
                (1 - f);
        final rayon = BorderRadius.circular(VerrouEnregistrement.largeur / 2);

        return SizedBox(
          width: VerrouEnregistrement.largeur,
          height: hauteur,
          child: DecoratedBox(
            // L'ombre DEHORS du verre : à l'intérieur du `BackdropFilter`,
            // elle serait floutée avec le reste et disparaîtrait.
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
            // ⚠️ `OuroBlurSurface`, PAS UN `BackdropFilter` FAIT MAIN. Le
            // flou et la teinte de chaque épaisseur de verre vivent dans une
            // extension PRIVÉE de `glassmorphism.dart` : `OuroMaterial.thin
            // .blur` ne compile pas ailleurs. Et c'est voulu — la seule
            // porte vers le verre est ce widget, ce qui garantit que tout
            // le verre de l'application a la même épaisseur.
            child: OuroBlurSurface(
              material: OuroMaterial.thin,
              borderRadius: rayon,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: rayon,
                  // Le liseré : sans lui, le verre se confond avec un fond
                  // de même teinte et la capsule perd son contour.
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: OuroColors.isDark ? 0.12 : 0.45,
                    ),
                    width: 0.5,
                  ),
                ),
                child: CustomPaint(
                  painter: _PeintreCadenas(
                    fermeture: f,
                    pause: pause,
                    respiration: _respiration.value,
                    encre: OuroColors.label,
                    // Le trou de serrure « perce » le corps : une teinte
                    // proche du verre, sombre en thème sombre.
                    trou: OuroColors.isDark
                        ? Colors.black.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeintreCadenas extends CustomPainter {
  const _PeintreCadenas({
    required this.fermeture,
    required this.pause,
    required this.respiration,
    required this.encre,
    required this.trou,
  });

  final double fermeture;
  final double pause;
  final double respiration;
  final Color encre;
  final Color trou;

  @override
  void paint(Canvas toile, Size taille) {
    final cx = taille.width / 2;
    final ouvert = 1 - fermeture;

    // ── Le cadenas, qui s'efface quand la pause arrive ──
    if (pause < 1) {
      final alpha = 1 - pause;
      final trait = Paint()
        ..color = encre.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round;
      final plein = Paint()..color = encre.withValues(alpha: alpha);

      // Le corps, en haut de la capsule : sa place ne bouge pas quand la
      // capsule raccourcit, c'est le chevron dessous qui disparaît.
      final corps = Rect.fromCenter(
        center: Offset(cx, 22),
        width: 15,
        height: 12,
      );
      final centre = corps.center;

      toile
        ..save()
        // 9° au plus pendant la montée : le cadenas « bascule » vers sa
        // fermeture, il ne se contente pas de changer de dessin.
        ..translate(centre.dx, centre.dy)
        ..rotate(9 * math.pi / 180 * fermeture * (1 - pause))
        ..translate(-centre.dx, -centre.dy);

      // L'arceau. Ouvert, il flotte un peu plus haut et respire ; fermé,
      // il s'est enfoncé dans le corps.
      final souleve = 1.5 * ouvert * (1 - respiration);
      final hautArceau = corps.top - 9 - souleve;
      final rect = Rect.fromLTWH(cx - 4, hautArceau, 8, 8);
      toile.drawArc(rect, math.pi, math.pi, false, trait);
      // Jambe droite : toujours plantée dans le corps.
      toile.drawLine(
        Offset(cx + 4, hautArceau + 4),
        Offset(cx + 4, corps.top + 1),
        trait,
      );
      // ⚠️ Jambe gauche : c'est ELLE qui dit « ouvert ». Tant que le
      // cadenas n'est pas fermé, elle s'arrête avant le corps — l'écart
      // se referme à mesure qu'on monte.
      final ecart = 4.5 * ouvert * (0.6 + 0.4 * respiration);
      toile.drawLine(
        Offset(cx - 4, hautArceau + 4),
        Offset(cx - 4, corps.top + 1 - ecart),
        trait,
      );

      toile.drawRRect(
        RRect.fromRectAndRadius(corps, const Radius.circular(3)),
        plein,
      );
      // Le trou de serrure, dans la teinte du verre : il « perce » le corps.
      toile.drawCircle(centre, 1.8, Paint()..color = trou);
      toile.restore();

      // ── Le chevron ──
      //
      // Il respire de 3 points vers le haut (CAEV:1474), et s'efface à
      // mesure que le cadenas se ferme.
      //
      // ⚠️ IL DOIT AVOIR DISPARU AVANT MI-COURSE. La capsule rétrécit en
      // se fermant : passé 40 % de la course, le bas remonte jusqu'au
      // corps du cadenas, et un chevron encore visible se dessinait PAR-
      // DESSUS le corps (vu sur le rendu des cinq états).
      final visibilite = ((ouvert - 0.6) / 0.4).clamp(0.0, 1.0) * alpha;
      if (visibilite > 0.01) {
        final y = taille.height - 13 - 3 * respiration;
        toile.drawPath(
          Path()
            ..moveTo(cx - 5, y + 2.5)
            ..lineTo(cx, y - 2.5)
            ..lineTo(cx + 5, y + 2.5),
          Paint()
            ..color = encre.withValues(alpha: 0.7 * visibilite)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    // ── La pause, qui arrive en se resserrant ──
    if (pause > 0) {
      final c = Offset(cx, taille.height / 2);
      final p = Paint()..color = encre.withValues(alpha: pause);
      // Les barres naissent écartées et se resserrent : on voit le cadenas
      // SE TRANSFORMER, au lieu d'être simplement remplacé.
      final demiEcart = 3.3 + 2 * (1 - pause);
      for (final signe in const [-1.0, 1.0]) {
        toile.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(c.dx + signe * demiEcart, c.dy),
              width: 3.4,
              height: 12 * (0.7 + 0.3 * pause),
            ),
            const Radius.circular(1.5),
          ),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PeintreCadenas vieux) =>
      vieux.fermeture != fermeture ||
      vieux.pause != pause ||
      vieux.respiration != respiration ||
      vieux.encre != encre;
}

/// Le cercle et son cadenas, assemblés et animés.
///
/// L'appelant fournit l'état ; ce widget ne tient que les horloges qui
/// n'ont pas de sens ailleurs : l'ondulation des gouttes et la
/// respiration.
class CercleEnregistrement extends StatefulWidget {
  const CercleEnregistrement({
    super.key,
    required this.amplitudeCible,
    required this.releve,
    required this.entree,
    required this.progressionAnnulation,
    required this.progressionVerrou,
    required this.verrouille,
    required this.versEnvoi,
    required this.modeVideo,
  });

  /// Le dernier relevé du micro, BRUT.
  ///
  /// ⚠️ LE LISSAGE EST FAIT ICI, PAS PAR L'APPELANT — et ce n'est pas un
  /// détail d'organisation. Le micro n'est relevé que toutes les 80 ms ;
  /// lissé au rythme des relevés, le rayon avance par marches, et une
  /// mesure l'a montré : jusqu'à **10 points d'écart** avec la courbe de
  /// Telegram, sur une course totale de 30. Le cercle montait par
  /// paliers au lieu de glisser.
  ///
  /// Ce widget a déjà une horloge à 60 images par seconde pour les
  /// gouttes : c'est elle qui intègre, exactement comme chez Telegram.
  final double amplitudeCible;

  /// Le numéro du relevé.
  ///
  /// ⚠️ IL NE SERT PAS À RIEN SOUS PRÉTEXTE QUE LA VALEUR SUFFIRAIT.
  /// Telegram recalcule sa pente à CHAQUE relevé du micro, y compris
  /// quand le niveau n'a pas bougé — ce qui divise à nouveau l'écart
  /// restant par 375 ms, et donne une approche asymptotique, pas une
  /// vitesse constante. Ne recalculer que sur changement de valeur
  /// produisait une courbe mesurablement différente : jusqu'à 5 points
  /// de rayon d'écart, le cercle arrivant trop tôt et trop sec.
  ///
  /// Deux relevés de même valeur sont donc deux évènements distincts, et
  /// seul ce compteur permet de les distinguer.
  final int releve;

  final double entree;
  final double progressionAnnulation;
  final double progressionVerrou;
  final bool verrouille;
  final double versEnvoi;
  final bool modeVideo;

  /// Le côté du carré qui contient le cercle ET ses gouttes.
  ///
  /// ⚠️ 280, PAS 194 — ET CE N'EST PAS UNE MARGE DE CONFORT. Telegram
  /// donne 194 à sa vue, mais y place le centre près du bas : la goutte
  /// y déborde par en dessous, où la barre de saisie la cache. En carré
  /// centré, ce même 194 tranche la goutte NET, des quatre côtés, dès
  /// qu'on parle fort — un bord droit en plein milieu d'une forme
  /// organique, qui se lit immédiatement comme un bogue d'affichage.
  ///
  /// Le calcul : la grande goutte monte à (50 + 12 × 0,6) = 57,2 points
  /// de rayon, multipliés par (0,878 + 1,4 × 1) = 2,278 à pleine
  /// amplitude, soit **130,3 points**. Il en faut donc 261 au minimum ;
  /// 280 laisse de quoi voir l'ondulation jusqu'au bout.
  static const double cote = 280;

  @override
  State<CercleEnregistrement> createState() => _CercleEnregistrementState();
}

class _CercleEnregistrementState extends State<CercleEnregistrement>
    with SingleTickerProviderStateMixin {
  late final Ticker _horloge;
  late final Goutte _petite = Goutte(11, rayonMin: 47, rayonMax: 55);
  late final Goutte _grande = Goutte(12, rayonMin: 47, rayonMax: 55);

  double _respiration = 0;
  bool _respirationMonte = true;

  /// Le niveau lissé, intégré image par image.
  double _amplitude = 0;

  /// La pente courante, en unités par milliseconde.
  ///
  /// Recalculée à chaque nouveau relevé : l'écart restant divisé par
  /// 375 ms. C'est une vitesse CONSTANTE, pas un amortissement
  /// exponentiel — un amortissement traîne indéfiniment sur la fin et le
  /// cercle ne revient jamais tout à fait au repos entre deux mots.
  double _pente = 0;
  double _cible = 0;
  int _dernierReleve = -1;
  Duration _derniere = Duration.zero;

  @override
  void initState() {
    super.initState();
    _horloge = createTicker(_tic)..start();
  }

  @override
  void dispose() {
    _horloge.dispose();
    super.dispose();
  }

  void _tic(Duration temps) {
    if (!mounted) return;

    // Un nouveau relevé : on recalcule la pente, on ne saute pas.
    if (widget.releve != _dernierReleve) {
      _dernierReleve = widget.releve;
      _cible = widget.amplitudeCible;
      _pente = (_cible - _amplitude) / dureeSuiviAmplitude.inMilliseconds;
    }
    // ⚠️ LE TEMPS RÉEL, PAS UNE DURÉE SUPPOSÉE. Une image sautée — et il
    // y en a, pendant qu'un enregistrement démarre — laisserait le
    // cercle en retard sur le son si l'on comptait les images au lieu
    // des millisecondes.
    var dt = (temps - _derniere).inMicroseconds / 1000.0;
    _derniere = temps;
    // Première image, ou retour de veille : on ne rattrape pas d'un bond.
    if (dt <= 0 || dt > 100) dt = 1000 / 60;

    if (_amplitude != _cible) {
      _amplitude += _pente * dt;
      _amplitude = _pente > 0
          ? math.min(_amplitude, _cible)
          : math.max(_amplitude, _cible);
    }

    _petite.avancer(_amplitude, 1.01);
    _grande.avancer(_amplitude, 1.02);
    // ± 0,01 par image, en va-et-vient. (CAEV.java:2297-2309)
    if (_respirationMonte) {
      _respiration += 0.01;
      if (_respiration >= 1) _respirationMonte = false;
    } else {
      _respiration -= 0.01;
      if (_respiration <= 0) _respirationMonte = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: CercleEnregistrement.cote,
      child: CustomPaint(
        painter: PeintreCercleEnregistrement(
          etat: EtatCercle(
            amplitude: _amplitude,
            entree: widget.entree,
            progressionAnnulation: widget.progressionAnnulation,
            progressionVerrou: widget.progressionVerrou,
            verrouille: widget.verrouille,
            versEnvoi: widget.versEnvoi,
            modeVideo: widget.modeVideo,
            respiration: _respiration,
          ),
          petiteGoutte: _petite,
          grandeGoutte: _grande,
          accent: OuroColors.accentRempli,
          encre: OuroColors.texteSurAccent,
        ),
      ),
    );
  }
}
