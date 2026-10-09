// ============================================================================
// LES MOTIFS DU FOND DE DISCUSSION — des petits dessins au trait posés
// par-dessus le dégradé, comme le papier peint à motifs de Telegram, mais
// avec l'univers de Droplet : gouttes, maillage, ondes radio, antennes relais,
// Bluetooth, oignon Tor, cadenas, talkie-walkie, tente de festival, zone
// blanche en montagne…
//
// ── Comment c'est dessiné ─────────────────────────────────────────────────
//
// Chaque motif est un tracé vectoriel dans une boîte de 24 × 24 (la grille
// des icônes). Ils sont disposés une fois pour toutes dans une TUILE carrée —
// une grille légèrement bousculée, chaque dessin tourné et dimensionné par un
// tirage déterministe — puis la tuile est rendue en image et répétée sur tout
// l'écran par un shader.
//
// ⚠️ UNE SEULE IMAGE, CALCULÉE UNE FOIS. Redessiner des centaines de tracés
// à chaque image du défilement coûterait de la batterie pour un décor. Ici,
// le coût d'affichage est celui d'un rectangle rempli.
//
// ⚠️ AUCUN DESSIN NE DÉBORDE DE SA CASE (voir `motifs_droplet_test.dart`) :
// c'est ce qui rend la répétition invisible — un dessin coupé au bord de la
// tuile ne retrouverait jamais sa moitié de l'autre côté.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Un dessin posé dans la tuile.
class PlacementMotif {
  const PlacementMotif({
    required this.motif,
    required this.centre,
    required this.taille,
    required this.rotation,
    this.pack = PackMotifs.droplet,
  });

  /// Index dans [MotifsDroplet.traces], puis dans les petits dessins.
  final int motif;
  final Offset centre;

  /// Côté de la boîte 24 × 24 une fois agrandie, en pixels logiques.
  final double taille;
  final double rotation;

  /// Le jeu de motifs auquel appartient ce dessin.
  final PackMotifs pack;

  /// Le tracé placé dans la tuile.
  Path chemin() {
    final echelle = taille / 24;
    final m = Matrix4.identity()
      ..translateByDouble(centre.dx, centre.dy, 0, 1)
      ..rotateZ(rotation)
      ..scaleByDouble(echelle, echelle, 1, 1)
      ..translateByDouble(-12, -12, 0, 1);
    return MotifsDroplet._traceDe(motif, pack)().transform(m.storage);
  }
}

class MotifsDroplet {
  MotifsDroplet._();

  /// Côté d'une case de la grille, en pixels logiques.
  static const double caseTaille = 64;

  /// Cases par côté de la tuile.
  static const int cases = 6;

  static double get tuileTaille => caseTaille * cases;

  /// Épaisseur du trait, en pixels logiques.
  static const double trait = 1.75;

  /// Les petits dessins de remplissage sont tracés plus fin : deux graisses
  /// donnent au fond la profondeur d'un vrai dessin, là où une seule donne
  /// une grille d'icônes.
  static const double traitFin = 1.35;

  static const double _degre = math.pi / 180;

  /// Les dessins, chacun dans une boîte de 24 × 24.
  /// Les jeux de motifs proposés dans Apparence. Chaque pack a son univers
  /// et le MÊME soin : trois à cinq traits, une masse équilibrée dans une
  /// boîte de 24, deux graisses au tracé. On change de papier peint, pas de
  /// qualité.

  static final List<Path Function()> tracesJeux = [
    _jManette,
    _jDe,
    _jFusee,
    _jEclair,
    _jCoeur,
    _jBouclier,
    _jEpee,
    _jTrophee,
    _jBombe,
    _jInvader,
    _jBorne,
    _jCasque,
    _jPower,
  ];

  static final List<Path Function()> tracesMaison = [
    _hMaison,
    _hTasse,
    _hPlante,
    _hLivre,
    _hLampe,
    _hHorloge,
    _hFauteuil,
    _hAmpoule,
    _hChat,
    _hFenetre,
    _hTheiere,
    _hBougie,
    _hPelote,
  ];

  static final List<Path Function()> tracesJardin = [
    _gFleur,
    _gChampignon,
    _gPapillon,
    _gArbre,
    _gSoleil,
    _gEscargot,
    _gAbeille,
    _gHerbe,
    _gCoquillage,
    _gOiseau,
    _gLune,
    _gNuage,
  ];

  static final List<Path Function()> traces = [
    _goutte,
    _ondes,
    _maillage,
    _avion,
    _bulle,
    _antenne,
    _boussole,
    _vagues,
    _cle,
    _cadenas,
    _montagne,
    _talkie,
    _feuille,
    _tente,
    _enveloppe,
    _horsLigne,
    _bateau,
    _phare,
    _satellite,
    _constellation,
    _oignon,
    _bluetooth,
  ];

  /// Petits dessins de remplissage, pour aérer entre les grands.
  static final List<Path Function()> _petits = [_point, _croix, _petiteGoutte, _etincelle];

  /// Les tracés d'un pack.
  static List<Path Function()> tracesDe(PackMotifs pack) => switch (pack) {
        PackMotifs.droplet => traces,
        PackMotifs.jeux => tracesJeux,
        PackMotifs.maison => tracesMaison,
        PackMotifs.jardin => tracesJardin,
      };

  static int get nombreDeMotifs => traces.length + _petits.length;

  /// La disposition de la tuile — déterministe : même fond à chaque ouverture.
  static List<PlacementMotif> disposition([PackMotifs pack = PackMotifs.droplet]) {
    // Une graine par pack : deux papiers peints ne tombent jamais pareil.
    final hasard = math.Random(0xD7091E7 + pack.index * 7919);
    final ordre = List<int>.generate(tracesDe(pack).length, (i) => i)..shuffle(hasard);
    final placements = <PlacementMotif>[];
    var suivant = 0;
    for (var ligne = 0; ligne < cases; ligne++) {
      for (var colonne = 0; colonne < cases; colonne++) {
        // Une case sur huit reste vide : le fond respire, et l'œil ne
        // retrouve plus la grille.
        if (hasard.nextDouble() < 0.13) continue;
        final petit = hasard.nextDouble() < 0.24;
        final taille = petit ? 10 + hasard.nextDouble() * 5 : 22 + hasard.nextDouble() * 10;
        final rotation = (hasard.nextDouble() - 0.5) * 0.9;
        // Demi-encombrement maximal d'une boîte tournée, trait compris : le
        // dessin reste dans sa case quel que soit le décalage tiré.
        final demi = taille / 2 * math.sqrt2 + trait;
        final jeu = (caseTaille / 2 - demi).clamp(0.0, caseTaille / 2);
        final centre = Offset(
          (colonne + 0.5) * caseTaille + (hasard.nextDouble() * 2 - 1) * jeu,
          (ligne + 0.5) * caseTaille + (hasard.nextDouble() * 2 - 1) * jeu,
        );
        final int motif;
        if (petit) {
          motif = tracesDe(pack).length + hasard.nextInt(_petits.length);
        } else {
          motif = ordre[suivant % ordre.length];
          suivant++;
        }
        placements.add(PlacementMotif(
          pack: pack,
          motif: motif,
          centre: centre,
          taille: taille,
          rotation: rotation,
        ));
      }
    }
    return placements;
  }

  static Path Function() _traceDe(int index, [PackMotifs pack = PackMotifs.droplet]) =>
      index < tracesDe(pack).length
          ? tracesDe(pack)[index]
          : _petits[index - tracesDe(pack).length];

  /// Tous les tracés de la tuile, en un seul chemin.
  static Path tuile() {
    final tout = Path();
    for (final p in disposition()) {
      tout.addPath(p.chemin(), Offset.zero);
    }
    return tout;
  }

  /// Les grands dessins, ou les petits : ils ne se tracent pas à la même
  /// graisse.
  static Path tuileDe({required bool grands, PackMotifs pack = PackMotifs.droplet}) {
    final tout = Path();
    for (final p in disposition(pack)) {
      if ((p.motif < tracesDe(pack).length) != grands) continue;
      tout.addPath(p.chemin(), Offset.zero);
    }
    return tout;
  }

  static final Map<String, Future<ui.Image>> _images = {};

  /// L'image de la tuile (motifs blancs sur transparent) pour cette densité
  /// d'écran — calculée une fois par densité.
  static Future<ui.Image> image(double densite, [PackMotifs pack = PackMotifs.droplet]) {
    // ⚠️ LES DOLLARS NE SONT PAS ÉCHAPPÉS. Avec `\$`, la clé valait
    // littéralement « $densite:${pack.index} » pour TOUTES les densités
    // et TOUS les packs : le premier motif rendu était ensuite servi à
    // tout le monde, flou sur un écran plus dense et jamais changé quand
    // on changeait de pack. Le cache marchait — il cachait la mauvaise
    // chose.
    return _images.putIfAbsent('$densite:${pack.index}', () {
      final cote = (tuileTaille * densite).round();
      final enregistreur = ui.PictureRecorder();
      final canvas = Canvas(enregistreur)..scale(densite);
      Paint plume(double epaisseur) => Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = epaisseur
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..color = Colors.white;
      canvas
        ..drawPath(tuileDe(grands: true, pack: pack), plume(trait))
        ..drawPath(tuileDe(grands: false, pack: pack), plume(traitFin));
      return enregistreur.endRecording().toImage(cote, cote);
    });
  }

  /// Couleur des motifs : discrète, pour ne jamais gêner la lecture.
  static Color couleur({required bool sombre}) => sombre
      // Un tiers plus discret qu'avant : le motif accompagne les bulles,
      // il ne leur dispute pas le regard.
      // ⚠️ ENCORE PLUS BAS, mesuré sur une capture : à 7 %, cadenas,
      // avions et ondes se lisaient ENTRE les bulles et attiraient l'œil
      // à chaque espace. WhatsApp garde son papier peint autour de 5 % ;
      // au-dessous de 4 %, il ne se devine plus.
      ? Colors.white.withValues(alpha: 0.042)
      : const Color(0xFF123F5C).withValues(alpha: 0.048);

  // ── Les dessins ──────────────────────────────────────────────────────

  // ── Pack « JEUX » ───────────────────────────────────────────────

  static Path _jManette() => Path()
    ..addRRect(RRect.fromLTRBR(2.6, 8.4, 21.4, 17.6, const Radius.circular(4.2)))
    ..moveTo(8, 11)
    ..lineTo(8, 15)
    ..moveTo(6, 13)
    ..lineTo(10, 13)
    ..addOval(Rect.fromCircle(center: const Offset(16.2, 11.9), radius: 1.05))
    ..addOval(Rect.fromCircle(center: const Offset(18.6, 14.1), radius: 1.05))
    ..addOval(Rect.fromCircle(center: const Offset(13.9, 14.1), radius: 1.05));

  static Path _jDe() => Path()
    ..addRRect(RRect.fromLTRBR(4.2, 4.2, 19.8, 19.8, const Radius.circular(3.6)))
    ..addOval(Rect.fromCircle(center: const Offset(9, 9), radius: 1.1))
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 1.1))
    ..addOval(Rect.fromCircle(center: const Offset(15, 15), radius: 1.1));

  static Path _jFusee() => Path()
    ..moveTo(12, 2.6)
    ..cubicTo(15.6, 6, 17, 10.4, 17, 14.2)
    ..lineTo(17, 17.6)
    ..lineTo(7, 17.6)
    ..lineTo(7, 14.2)
    ..cubicTo(7, 10.4, 8.4, 6, 12, 2.6)
    ..close()
    ..addOval(Rect.fromCircle(center: const Offset(12, 9.4), radius: 1.9))
    ..moveTo(7, 14.6)
    ..lineTo(4, 18.4)
    ..lineTo(7, 17.8)
    ..moveTo(17, 14.6)
    ..lineTo(20, 18.4)
    ..lineTo(17, 17.8)
    ..moveTo(10.4, 19.4)
    ..cubicTo(11, 21, 13, 21, 13.6, 19.4);

  static Path _jEclair() => Path()
    ..moveTo(13.8, 2.4)
    ..lineTo(6.4, 13.2)
    ..lineTo(11.2, 13.2)
    ..lineTo(10.2, 21.6)
    ..lineTo(17.8, 10.4)
    ..lineTo(12.8, 10.4)
    ..close();

  static Path _jCoeur() => Path()
    ..moveTo(12, 20.6)
    ..cubicTo(4, 15.4, 3, 10.4, 6.2, 7.4)
    ..cubicTo(8.4, 5.3, 11, 6.2, 12, 8.4)
    ..cubicTo(13, 6.2, 15.6, 5.3, 17.8, 7.4)
    ..cubicTo(21, 10.4, 20, 15.4, 12, 20.6)
    ..close();

  static Path _jBouclier() => Path()
    ..moveTo(12, 2.8)
    ..lineTo(20.4, 6)
    ..cubicTo(20.4, 13.6, 17.2, 18.8, 12, 21.2)
    ..cubicTo(6.8, 18.8, 3.6, 13.6, 3.6, 6)
    ..close()
    ..moveTo(9.4, 11.6)
    ..lineTo(11.4, 13.8)
    ..lineTo(15.2, 9.6);

  static Path _jEpee() => Path()
    ..moveTo(18.8, 3.2)
    ..lineTo(9.6, 12.4)
    ..lineTo(11.6, 14.4)
    ..lineTo(20.8, 5.2)
    ..close()
    ..moveTo(9.6, 12.4)
    ..lineTo(6.6, 15.4)
    ..lineTo(8.6, 17.4)
    ..lineTo(11.6, 14.4)
    ..moveTo(5.2, 14)
    ..lineTo(10, 18.8)
    ..moveTo(6.6, 18.2)
    ..lineTo(3.2, 21.6);

  static Path _jTrophee() => Path()
    ..moveTo(7.6, 4.2)
    ..lineTo(16.4, 4.2)
    ..lineTo(15.8, 11)
    ..cubicTo(15.6, 13.6, 13.9, 15, 12, 15)
    ..cubicTo(10.1, 15, 8.4, 13.6, 8.2, 11)
    ..close()
    ..moveTo(7.7, 5.8)
    ..cubicTo(4.4, 6, 4.2, 10.2, 7.9, 11.2)
    ..moveTo(16.3, 5.8)
    ..cubicTo(19.6, 6, 19.8, 10.2, 16.1, 11.2)
    ..moveTo(12, 15)
    ..lineTo(12, 18.2)
    ..moveTo(8.6, 20.4)
    ..lineTo(15.4, 20.4)
    ..lineTo(14.4, 18.2)
    ..lineTo(9.6, 18.2)
    ..close();

  static Path _jBombe() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(11.2, 14.8), radius: 6.4))
    ..moveTo(15.6, 10.2)
    ..lineTo(17.8, 8)
    ..moveTo(16.6, 7.2)
    ..lineTo(19, 6.2)
    ..cubicTo(21.4, 5.2, 22, 3.2, 21, 2)
    ..moveTo(19.6, 2.6)
    ..lineTo(21.4, 3.6)
    ..moveTo(20.2, 1.6)
    ..lineTo(20.8, 3.4);

  static Path _jInvader() => Path()
    ..moveTo(6.6, 8.4)
    ..lineTo(6.6, 15.6)
    ..lineTo(9, 15.6)
    ..lineTo(9, 18)
    ..lineTo(6, 18)
    ..moveTo(17.4, 8.4)
    ..lineTo(17.4, 15.6)
    ..lineTo(15, 15.6)
    ..lineTo(15, 18)
    ..lineTo(18, 18)
    ..moveTo(6.6, 8.4)
    ..lineTo(9, 8.4)
    ..lineTo(9, 6)
    ..lineTo(15, 6)
    ..lineTo(15, 8.4)
    ..lineTo(17.4, 8.4)
    ..moveTo(6.6, 12)
    ..lineTo(17.4, 12)
    ..addOval(Rect.fromCircle(center: const Offset(10, 10), radius: 0.85))
    ..addOval(Rect.fromCircle(center: const Offset(14, 10), radius: 0.85));

  static Path _jBorne() => Path()
    ..addRRect(RRect.fromLTRBR(5, 3.2, 19, 20.8, const Radius.circular(2.6)))
    ..addRRect(RRect.fromLTRBR(7.4, 6, 16.6, 12.4, const Radius.circular(1.2)))
    ..addOval(Rect.fromCircle(center: const Offset(9.4, 16.2), radius: 1.4))
    ..moveTo(13, 16.8)
    ..lineTo(17, 16.8)
    ..moveTo(9.4, 14.8)
    ..lineTo(9.4, 13.2);

  static Path _jCasque() => Path()
    ..moveTo(4.4, 15.2)
    ..cubicTo(4.4, 8.4, 7.8, 4.6, 12, 4.6)
    ..cubicTo(16.2, 4.6, 19.6, 8.4, 19.6, 15.2)
    ..addRRect(RRect.fromLTRBR(2.8, 13.8, 6.6, 20, const Radius.circular(1.8)))
    ..addRRect(RRect.fromLTRBR(17.4, 13.8, 21.2, 20, const Radius.circular(1.8)))
    ..moveTo(19.6, 20)
    ..lineTo(19.6, 21.4)
    ..lineTo(14.6, 21.4);

  static Path _jPower() => Path()
    ..addArc(Rect.fromCircle(center: const Offset(12, 12.6), radius: 7.4), -62 * _degre, 304 * _degre)
    ..moveTo(12, 3.4)
    ..lineTo(12, 11);

  // ── Pack « MAISON » ───────────────────────────────────────────────

  static Path _hMaison() => Path()
    ..moveTo(3, 11.6)
    ..lineTo(12, 3.6)
    ..lineTo(21, 11.6)
    ..moveTo(5.4, 10)
    ..lineTo(5.4, 20.6)
    ..lineTo(18.6, 20.6)
    ..lineTo(18.6, 10)
    ..addRRect(RRect.fromLTRBR(10.2, 14.4, 13.8, 20.6, const Radius.circular(0.6)))
    ..addRRect(RRect.fromLTRBR(7, 12.2, 9.4, 14.8, const Radius.circular(0.5)));

  static Path _hTasse() => Path()
    ..moveTo(5.2, 9.6)
    ..lineTo(5.2, 17)
    ..cubicTo(5.2, 19.2, 6.9, 20.6, 9, 20.6)
    ..lineTo(13.6, 20.6)
    ..cubicTo(15.7, 20.6, 17.4, 19.2, 17.4, 17)
    ..lineTo(17.4, 9.6)
    ..close()
    ..moveTo(17.6, 11.4)
    ..cubicTo(20.8, 11.4, 21.4, 15.8, 17.6, 16.2)
    ..moveTo(8.6, 7)
    ..cubicTo(7.6, 5.6, 9.4, 4.6, 8.4, 3)
    ..moveTo(12.6, 7)
    ..cubicTo(11.6, 5.6, 13.4, 4.6, 12.4, 3);

  static Path _hPlante() => Path()
    ..moveTo(7.6, 13.6)
    ..lineTo(9, 20.8)
    ..lineTo(15, 20.8)
    ..lineTo(16.4, 13.6)
    ..close()
    ..moveTo(6.8, 13.6)
    ..lineTo(17.2, 13.6)
    ..moveTo(12, 13.2)
    ..lineTo(12, 6.6)
    ..moveTo(12, 10.2)
    ..cubicTo(8.4, 10, 7, 7.6, 7.6, 4.8)
    ..cubicTo(10.6, 5, 12, 7.2, 12, 10.2)
    ..moveTo(12, 9.2)
    ..cubicTo(15.2, 9, 16.6, 6.8, 16, 4.2)
    ..cubicTo(13.2, 4.4, 11.8, 6.4, 12, 9.2);

  static Path _hLivre() => Path()
    ..moveTo(12, 7.2)
    ..cubicTo(9.8, 5.4, 6.6, 5, 3.4, 5.6)
    ..lineTo(3.4, 17.6)
    ..cubicTo(6.6, 17, 9.8, 17.4, 12, 19.2)
    ..cubicTo(14.2, 17.4, 17.4, 17, 20.6, 17.6)
    ..lineTo(20.6, 5.6)
    ..cubicTo(17.4, 5, 14.2, 5.4, 12, 7.2)
    ..close()
    ..moveTo(12, 7.2)
    ..lineTo(12, 19.2);

  static Path _hLampe() => Path()
    ..moveTo(12, 2.4)
    ..lineTo(12, 6.2)
    ..moveTo(5.6, 13.2)
    ..lineTo(18.4, 13.2)
    ..lineTo(15.4, 6.4)
    ..lineTo(8.6, 6.4)
    ..close()
    ..moveTo(12, 13.6)
    ..lineTo(12, 19)
    ..moveTo(8.8, 21.2)
    ..cubicTo(8.8, 18.4, 15.2, 18.4, 15.2, 21.2);

  static Path _hHorloge() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 12.8), radius: 8.4))
    ..moveTo(12, 7.6)
    ..lineTo(12, 12.8)
    ..lineTo(15.6, 14.8)
    ..moveTo(9.6, 3.2)
    ..lineTo(7, 5.6)
    ..moveTo(14.4, 3.2)
    ..lineTo(17, 5.6);

  static Path _hFauteuil() => Path()
    ..addRRect(RRect.fromLTRBR(4.2, 9, 19.8, 17.6, const Radius.circular(2.6)))
    ..moveTo(7.6, 9)
    ..lineTo(7.6, 6)
    ..cubicTo(7.6, 4.4, 8.8, 3.4, 12, 3.4)
    ..cubicTo(15.2, 3.4, 16.4, 4.4, 16.4, 6)
    ..lineTo(16.4, 9)
    ..moveTo(6.6, 17.6)
    ..lineTo(6.6, 20.6)
    ..moveTo(17.4, 17.6)
    ..lineTo(17.4, 20.6)
    ..moveTo(4.2, 13)
    ..lineTo(19.8, 13);

  static Path _hAmpoule() => Path()
    ..moveTo(12, 2.8)
    ..cubicTo(7.6, 2.8, 4.8, 6.2, 4.8, 9.8)
    ..cubicTo(4.8, 13, 7.4, 14.4, 8.4, 16.6)
    ..lineTo(15.6, 16.6)
    ..cubicTo(16.6, 14.4, 19.2, 13, 19.2, 9.8)
    ..cubicTo(19.2, 6.2, 16.4, 2.8, 12, 2.8)
    ..close()
    ..moveTo(8.8, 18.4)
    ..lineTo(15.2, 18.4)
    ..moveTo(10, 20.6)
    ..lineTo(14, 20.6);

  static Path _hChat() => Path()
    ..moveTo(5.6, 10.2)
    ..lineTo(5, 4.6)
    ..lineTo(9.4, 7.4)
    ..moveTo(18.4, 10.2)
    ..lineTo(19, 4.6)
    ..lineTo(14.6, 7.4)
    ..cubicTo(5.6, 10.2, 4.2, 14.6, 5.8, 17.6)
    ..cubicTo(7.4, 20.6, 16.6, 20.6, 18.2, 17.6)
    ..cubicTo(19.8, 14.6, 18.4, 10.2, 18.4, 10.2)
    ..addOval(Rect.fromCircle(center: const Offset(9.6, 13.4), radius: 0.9))
    ..addOval(Rect.fromCircle(center: const Offset(14.4, 13.4), radius: 0.9))
    ..moveTo(12, 15.6)
    ..lineTo(12, 17)
    ..moveTo(6.8, 15.4)
    ..lineTo(9.8, 16.2)
    ..moveTo(17.2, 15.4)
    ..lineTo(14.2, 16.2);

  static Path _hFenetre() => Path()
    ..addRRect(RRect.fromLTRBR(4.6, 4.2, 19.4, 19, const Radius.circular(1.6)))
    ..moveTo(12, 4.2)
    ..lineTo(12, 19)
    ..moveTo(4.6, 11.6)
    ..lineTo(19.4, 11.6)
    ..moveTo(3.2, 21)
    ..lineTo(20.8, 21);

  static Path _hTheiere() => Path()
    ..moveTo(6.2, 11)
    ..cubicTo(6.2, 8.2, 8.6, 6.6, 12, 6.6)
    ..cubicTo(15.4, 6.6, 17.8, 8.2, 17.8, 11)
    ..cubicTo(17.8, 16.2, 15.6, 19.6, 12, 19.6)
    ..cubicTo(8.4, 19.6, 6.2, 16.2, 6.2, 11)
    ..close()
    ..moveTo(17.4, 9.8)
    ..lineTo(21.4, 7.2)
    ..lineTo(21.4, 12.4)
    ..lineTo(17.6, 11.2)
    ..moveTo(10.4, 6.4)
    ..lineTo(13.6, 6.4)
    ..moveTo(12, 6.2)
    ..lineTo(12, 4.2)
    ..addOval(Rect.fromCircle(center: const Offset(12, 3.2), radius: 1));

  static Path _hBougie() => Path()
    ..addRRect(RRect.fromLTRBR(8.6, 10, 15.4, 20.6, const Radius.circular(1.2)))
    ..moveTo(12, 9.8)
    ..cubicTo(9.4, 7.4, 10.6, 5, 12, 3.2)
    ..cubicTo(13.4, 5, 14.6, 7.4, 12, 9.8)
    ..close()
    ..moveTo(6.6, 20.8)
    ..lineTo(17.4, 20.8);

  static Path _hPelote() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(11.4, 13.6), radius: 7))
    ..moveTo(6, 10)
    ..cubicTo(10, 11.6, 13.4, 15, 15, 19)
    ..moveTo(8, 7.2)
    ..cubicTo(12.6, 9.2, 16, 12.6, 18, 17.2)
    ..moveTo(5.6, 15.6)
    ..cubicTo(9.2, 14, 12, 11.2, 13.6, 7.6)
    ..moveTo(17.6, 17.4)
    ..lineTo(21, 20.8)
    ..moveTo(19.2, 19)
    ..lineTo(21.4, 18.4);

  // ── Pack « JARDIN » ───────────────────────────────────────────────

  static Path _gFleur() => Path()
    ..moveTo(12, 7.8)
    ..cubicTo(14.2, 7, 14, 4.4, 12, 4)
    ..cubicTo(10, 4.4, 9.8, 7, 12, 7.8)
    ..moveTo(13.71, 9.04)
    ..cubicTo(15.15, 10.89, 17.56, 9.9, 17.33, 7.87)
    ..cubicTo(16.33, 6.09, 13.79, 6.7, 13.71, 9.04)
    ..moveTo(13.06, 11.06)
    ..cubicTo(11.75, 13, 13.44, 14.98, 15.29, 14.13)
    ..cubicTo(16.67, 12.63, 15.31, 10.41, 13.06, 11.06)
    ..moveTo(10.94, 11.06)
    ..cubicTo(8.69, 10.41, 7.33, 12.63, 8.71, 14.13)
    ..cubicTo(10.56, 14.98, 12.25, 13, 10.94, 11.06)
    ..moveTo(10.29, 9.04)
    ..cubicTo(10.21, 6.7, 7.67, 6.09, 6.67, 7.87)
    ..cubicTo(6.44, 9.9, 8.85, 10.89, 10.29, 9.04)
    ..addOval(Rect.fromCircle(center: const Offset(12, 9.6), radius: 1.7))
    ..moveTo(12, 15)
    ..lineTo(12, 21)
    ..moveTo(12, 17.6)
    ..cubicTo(9.6, 16.8, 8.4, 18, 8, 19.4);

  static Path _gChampignon() => Path()
    ..moveTo(3.6, 12.6)
    ..cubicTo(3.6, 7.6, 7.4, 4.4, 12, 4.4)
    ..cubicTo(16.6, 4.4, 20.4, 7.6, 20.4, 12.6)
    ..close()
    ..moveTo(9.4, 12.6)
    ..lineTo(9.4, 17.8)
    ..cubicTo(9.4, 19.8, 14.6, 19.8, 14.6, 17.8)
    ..lineTo(14.6, 12.6)
    ..addOval(Rect.fromCircle(center: const Offset(8.4, 9), radius: 1.2))
    ..addOval(Rect.fromCircle(center: const Offset(14.6, 8), radius: 1))
    ..addOval(Rect.fromCircle(center: const Offset(12.6, 11.2), radius: 0.85));

  static Path _gPapillon() => Path()
    ..moveTo(12, 6.6)
    ..lineTo(12, 18.2)
    ..moveTo(12, 8.2)
    ..cubicTo(7, 3.2, 2.6, 6.4, 4.2, 10.6)
    ..cubicTo(5.2, 13.4, 9.4, 13, 12, 11.4)
    ..moveTo(12, 11.4)
    ..cubicTo(9.4, 14.2, 4.8, 15.2, 4.6, 18.4)
    ..cubicTo(4.4, 21, 9.6, 20.6, 12, 16.2)
    ..moveTo(12, 8.2)
    ..cubicTo(17, 3.2, 21.4, 6.4, 19.8, 10.6)
    ..cubicTo(18.8, 13.4, 14.6, 13, 12, 11.4)
    ..moveTo(12, 11.4)
    ..cubicTo(14.6, 14.2, 19.2, 15.2, 19.4, 18.4)
    ..cubicTo(19.6, 21, 14.4, 20.6, 12, 16.2)
    ..moveTo(12, 6.6)
    ..lineTo(10.2, 4)
    ..moveTo(12, 6.6)
    ..lineTo(13.8, 4);

  static Path _gArbre() => Path()
    ..moveTo(12, 3)
    ..cubicTo(6.4, 5.2, 4, 10, 5.6, 13.4)
    ..cubicTo(3.6, 15.8, 5.4, 19, 9, 18.6)
    ..cubicTo(10.4, 20.6, 13.6, 20.6, 15, 18.6)
    ..cubicTo(18.6, 19, 20.4, 15.8, 18.4, 13.4)
    ..cubicTo(20, 10, 17.6, 5.2, 12, 3)
    ..close()
    ..moveTo(12, 20)
    ..lineTo(12, 12)
    ..moveTo(12, 15)
    ..lineTo(9, 12.6)
    ..moveTo(12, 13.4)
    ..lineTo(15.2, 11);

  static Path _gSoleil() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 5.2))
    ..moveTo(12, 2.2)
    ..lineTo(12, 4.6)
    ..moveTo(12, 19.4)
    ..lineTo(12, 21.8)
    ..moveTo(2.2, 12)
    ..lineTo(4.6, 12)
    ..moveTo(19.4, 12)
    ..lineTo(21.8, 12)
    ..moveTo(5.1, 5.1)
    ..lineTo(6.8, 6.8)
    ..moveTo(17.2, 17.2)
    ..lineTo(18.9, 18.9)
    ..moveTo(18.9, 5.1)
    ..lineTo(17.2, 6.8)
    ..moveTo(6.8, 17.2)
    ..lineTo(5.1, 18.9);

  static Path _gEscargot() => Path()
    ..moveTo(3.2, 18.6)
    ..cubicTo(3.2, 19.8, 4.4, 20.4, 6, 20.4)
    ..lineTo(15, 20.4)
    ..moveTo(6, 20.4)
    ..cubicTo(3, 20.4, 2.4, 17, 3.6, 14.4)
    ..cubicTo(5.6, 10, 12.8, 9.6, 14.6, 13.8)
    ..cubicTo(16, 17, 12.4, 19.4, 10.2, 17)
    ..cubicTo(8.8, 15.4, 10.6, 13, 12.4, 14.6)
    ..moveTo(15.4, 12.4)
    ..lineTo(18, 7.4)
    ..moveTo(18, 7.4)
    ..lineTo(16.6, 5)
    ..moveTo(18, 7.4)
    ..lineTo(20.8, 6.8);

  static Path _gAbeille() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 14.4), radius: 5.4))
    ..moveTo(7.4, 12)
    ..lineTo(16.6, 12)
    ..moveTo(6.8, 15.4)
    ..lineTo(17.2, 15.4)
    ..moveTo(8, 18.2)
    ..lineTo(16, 18.2)
    ..moveTo(10, 9.6)
    ..cubicTo(6, 4.6, 2.6, 7.4, 5.2, 10.4)
    ..cubicTo(6.6, 12, 8.8, 11.2, 10, 9.6)
    ..moveTo(14, 9.6)
    ..cubicTo(18, 4.6, 21.4, 7.4, 18.8, 10.4)
    ..cubicTo(17.4, 12, 15.2, 11.2, 14, 9.6);

  static Path _gHerbe() => Path()
    ..moveTo(4, 20.6)
    ..cubicTo(4.4, 15, 6, 11.4, 8.4, 9)
    ..moveTo(9, 20.6)
    ..cubicTo(9.4, 13.8, 11, 9, 13.4, 5.6)
    ..moveTo(14.4, 20.6)
    ..cubicTo(14.2, 15.6, 16, 11.8, 19.6, 9.4)
    ..moveTo(2.4, 20.8)
    ..lineTo(21.6, 20.8);

  static Path _gCoquillage() => Path()
    ..moveTo(12, 20.8)
    ..cubicTo(5.2, 20.8, 2.8, 15.4, 4.4, 10.4)
    ..cubicTo(6, 5.6, 10.2, 3.2, 12, 3.2)
    ..cubicTo(13.8, 3.2, 18, 5.6, 19.6, 10.4)
    ..cubicTo(21.2, 15.4, 18.8, 20.8, 12, 20.8)
    ..close()
    ..moveTo(12, 3.4)
    ..lineTo(12, 20.6)
    ..moveTo(12, 20.6)
    ..cubicTo(9, 17, 7.4, 11, 8.4, 5.6)
    ..moveTo(12, 20.6)
    ..cubicTo(15, 17, 16.6, 11, 15.6, 5.6);

  static Path _gOiseau() => Path()
    ..moveTo(4.2, 15.2)
    ..cubicTo(4.2, 10.6, 8, 7.6, 12.4, 7.6)
    ..cubicTo(16.8, 7.6, 19.6, 9.8, 19.6, 12.6)
    ..cubicTo(19.6, 16.6, 15.6, 19.2, 11, 19.2)
    ..cubicTo(7, 19.2, 4.2, 17.6, 4.2, 15.2)
    ..close()
    ..moveTo(8, 13)
    ..cubicTo(10.6, 15, 13.6, 15.4, 16.4, 14)
    ..addOval(Rect.fromCircle(center: const Offset(15.8, 10.8), radius: 0.85))
    ..moveTo(19.4, 11.6)
    ..lineTo(22, 10.6)
    ..lineTo(19.4, 9.6)
    ..moveTo(9.6, 19)
    ..lineTo(9, 21.4)
    ..moveTo(13.4, 18.8)
    ..lineTo(13, 21.2);

  static Path _gLune() => Path()
    ..moveTo(15.8, 3.4)
    ..cubicTo(10, 4.6, 6, 9.6, 6.6, 15.2)
    ..cubicTo(7.2, 20.2, 12, 21.8, 16.4, 20)
    ..cubicTo(11.4, 18.2, 9.2, 13, 10.6, 8.4)
    ..cubicTo(11.2, 6.4, 13.2, 4.4, 15.8, 3.4)
    ..close()
    ..moveTo(18.6, 7.2)
    ..lineTo(19.2, 9)
    ..lineTo(21, 9.6)
    ..lineTo(19.2, 10.2)
    ..lineTo(18.6, 12)
    ..lineTo(18, 10.2)
    ..lineTo(16.2, 9.6)
    ..lineTo(18, 9)
    ..close();

  static Path _gNuage() => Path()
    ..moveTo(7, 18)
    ..cubicTo(4.2, 18, 2.8, 16, 2.8, 14.2)
    ..cubicTo(2.8, 12.2, 4.4, 10.6, 6.6, 10.6)
    ..cubicTo(7, 7.6, 9.6, 5.4, 12.6, 5.6)
    ..cubicTo(15.6, 5.8, 18, 8.2, 18.2, 11.2)
    ..cubicTo(20.2, 11.6, 21.4, 13.2, 21.2, 15)
    ..cubicTo(21, 16.8, 19.4, 18, 17.6, 18)
    ..close();


  /// La goutte, et son reflet.
  static Path _goutte() => Path()
    ..moveTo(12, 2.6)
    ..cubicTo(9, 7, 5.2, 11, 5.2, 14.9)
    ..cubicTo(5.2, 18.8, 8.3, 21.8, 12, 21.8)
    ..cubicTo(15.7, 21.8, 18.8, 18.8, 18.8, 14.9)
    ..cubicTo(18.8, 11, 15, 7, 12, 2.6)
    ..close()
    ..moveTo(8.9, 14.6)
    ..cubicTo(8.7, 17.2, 9.6, 18.8, 11.4, 19.4);

  /// Les ondes qui partent d'un point.
  static Path _ondes() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 18.6), radius: 1.15))
    ..addArc(Rect.fromCircle(center: const Offset(12, 18.6), radius: 4.8), -160 * _degre, 140 * _degre)
    ..addArc(Rect.fromCircle(center: const Offset(12, 18.6), radius: 8.4), -160 * _degre, 140 * _degre)
    ..addArc(Rect.fromCircle(center: const Offset(12, 18.6), radius: 12), -160 * _degre, 140 * _degre);

  /// Le maillage : des appareils qui se tiennent la main.
  static Path _maillage() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(5.6, 7), radius: 1.7))
    ..addOval(Rect.fromCircle(center: const Offset(18.4, 5.6), radius: 1.7))
    ..addOval(Rect.fromCircle(center: const Offset(19, 17.6), radius: 1.7))
    ..addOval(Rect.fromCircle(center: const Offset(6, 18.6), radius: 1.7))
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 1.9))
    ..moveTo(6.9, 8.2)
    ..lineTo(10.4, 10.9)
    ..moveTo(17, 6.9)
    ..lineTo(13.4, 10.5)
    ..moveTo(17.8, 16.3)
    ..lineTo(13.4, 13.3)
    ..moveTo(7.2, 17.4)
    ..lineTo(10.5, 13.4)
    ..moveTo(7.3, 6.7)
    ..lineTo(16.7, 5.8)
    ..moveTo(7.6, 19)
    ..lineTo(17.4, 18.2);

  /// L'avion en papier — un message qui part.
  static Path _avion() => Path()
    ..moveTo(2.8, 12.4)
    ..lineTo(21.2, 4.2)
    ..lineTo(13, 20.6)
    ..lineTo(10.4, 13.6)
    ..close()
    ..moveTo(21.2, 4.2)
    ..lineTo(10.4, 13.6);

  /// La bulle et ses trois points.
  static Path _bulle() => Path()
    ..addRRect(RRect.fromLTRBR(3.4, 5, 20.6, 16.6, const Radius.circular(4.4)))
    ..moveTo(8.6, 16.6)
    ..lineTo(7, 21.2)
    ..lineTo(12.8, 16.6)
    ..addOval(Rect.fromCircle(center: const Offset(8.6, 10.8), radius: 0.85))
    ..addOval(Rect.fromCircle(center: const Offset(12, 10.8), radius: 0.85))
    ..addOval(Rect.fromCircle(center: const Offset(15.4, 10.8), radius: 0.85));

  /// L'antenne relais et son signal.
  static Path _antenne() => Path()
    ..moveTo(12, 21.6)
    ..lineTo(12, 10.4)
    ..moveTo(8.4, 21.6)
    ..lineTo(12, 13)
    ..lineTo(15.6, 21.6)
    ..moveTo(9.6, 17.4)
    ..lineTo(14.4, 17.4)
    ..addOval(Rect.fromCircle(center: const Offset(12, 8.2), radius: 1.25))
    ..addArc(Rect.fromCircle(center: const Offset(12, 8.2), radius: 4.4), -48 * _degre, 96 * _degre)
    ..addArc(Rect.fromCircle(center: const Offset(12, 8.2), radius: 4.4), 132 * _degre, 96 * _degre)
    ..addArc(Rect.fromCircle(center: const Offset(12, 8.2), radius: 7.2), -38 * _degre, 76 * _degre)
    ..addArc(Rect.fromCircle(center: const Offset(12, 8.2), radius: 7.2), 142 * _degre, 76 * _degre);

  /// La boussole, pour se retrouver sans réseau.
  static Path _boussole() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8.6))
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 0.85))
    ..moveTo(8.2, 15.8)
    ..lineTo(13.4, 13.4)
    ..lineTo(15.8, 8.2)
    ..lineTo(10.6, 10.6)
    ..close()
    ..moveTo(12, 1.9)
    ..lineTo(12, 3.4);

  /// Trois vagues.
  static Path _vagues() => Path()
    ..moveTo(3.2, 8.6)
    ..cubicTo(5.4, 6.4, 7.4, 10.8, 9.6, 8.6)
    ..cubicTo(11.8, 6.4, 13.8, 10.8, 16, 8.6)
    ..cubicTo(17.4, 7.2, 19, 8.4, 20.8, 8.6)
    ..moveTo(3.2, 13.4)
    ..cubicTo(5.4, 11.2, 7.4, 15.6, 9.6, 13.4)
    ..cubicTo(11.8, 11.2, 13.8, 15.6, 16, 13.4)
    ..cubicTo(17.4, 12, 19, 13.2, 20.8, 13.4)
    ..moveTo(3.2, 18.2)
    ..cubicTo(5.4, 16, 7.4, 20.4, 9.6, 18.2)
    ..cubicTo(11.8, 16, 13.8, 20.4, 16, 18.2)
    ..cubicTo(17.4, 16.8, 19, 18, 20.8, 18.2);

  /// La clé — celle du chiffrement.
  static Path _cle() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(7.8, 8.4), radius: 3.5))
    ..addOval(Rect.fromCircle(center: const Offset(7.8, 8.4), radius: 1.25))
    ..moveTo(10.3, 10.9)
    ..lineTo(19.4, 20)
    ..moveTo(15.6, 16.2)
    ..lineTo(13.6, 18.2)
    ..moveTo(17.6, 18.2)
    ..lineTo(15.8, 20);

  /// Le cadenas fermé.
  static Path _cadenas() => Path()
    ..addRRect(RRect.fromLTRBR(5.2, 11.2, 18.8, 21.2, const Radius.circular(2.8)))
    ..moveTo(8.4, 11.2)
    ..lineTo(8.4, 8.6)
    ..addArc(Rect.fromCircle(center: const Offset(12, 8.6), radius: 3.6), 180 * _degre, 180 * _degre)
    ..moveTo(15.6, 8.6)
    ..lineTo(15.6, 11.2)
    ..addOval(Rect.fromCircle(center: const Offset(12, 15.4), radius: 1.2))
    ..moveTo(12, 16.6)
    ..lineTo(12, 18.4);

  /// Les sommets, la nuit, là où il n'y a pas de réseau.
  static Path _montagne() => Path()
    ..moveTo(2.4, 19.8)
    ..lineTo(8.8, 9)
    ..lineTo(12.8, 15.6)
    ..lineTo(15.4, 11.4)
    ..lineTo(21.6, 19.8)
    ..close()
    ..moveTo(6.8, 12.4)
    ..lineTo(8.8, 9)
    ..lineTo(10.8, 12.4)
    ..addOval(Rect.fromCircle(center: const Offset(18.6, 5.6), radius: 2.1));

  /// Le talkie-walkie.
  static Path _talkie() => Path()
    ..addRRect(RRect.fromLTRBR(7.4, 7.2, 16.6, 21.4, const Radius.circular(2.2)))
    ..moveTo(14.6, 7.2)
    ..lineTo(16.8, 3.4)
    ..moveTo(9.6, 10.6)
    ..lineTo(14.4, 10.6)
    ..moveTo(9.6, 12.8)
    ..lineTo(14.4, 12.8)
    ..addOval(Rect.fromCircle(center: const Offset(12, 16.8), radius: 1.5))
    ..addArc(Rect.fromCircle(center: const Offset(16.8, 3.4), radius: 3), -96 * _degre, 80 * _degre);

  /// La feuille et ses nervures.
  static Path _feuille() => Path()
    ..moveTo(12, 21.4)
    ..cubicTo(5.6, 17.4, 4.4, 10.8, 12, 3.2)
    ..cubicTo(19.6, 10.8, 18.4, 17.4, 12, 21.4)
    ..close()
    ..moveTo(12, 20.6)
    ..lineTo(12, 7)
    ..moveTo(12, 11.6)
    ..lineTo(8.4, 9.2)
    ..moveTo(12, 15.2)
    ..lineTo(15.6, 12.8);

  /// La tente du festival.
  static Path _tente() => Path()
    ..moveTo(2.6, 20.2)
    ..lineTo(12, 4.8)
    ..lineTo(21.4, 20.2)
    ..close()
    ..moveTo(12, 20.2)
    ..lineTo(9.2, 20.2)
    ..lineTo(12, 11.6)
    ..lineTo(14.8, 20.2)
    ..close()
    ..moveTo(1.8, 20.2)
    ..lineTo(22.2, 20.2);

  /// L'enveloppe.
  static Path _enveloppe() => Path()
    ..addRRect(RRect.fromLTRBR(3.4, 6.4, 20.6, 17.6, const Radius.circular(1.8)))
    ..moveTo(3.8, 7.4)
    ..lineTo(12, 13.6)
    ..lineTo(20.2, 7.4);

  /// Le nuage barré : pas d'Internet, et alors ?
  static Path _horsLigne() => Path()
    ..moveTo(7, 18.4)
    ..cubicTo(4.2, 18.4, 2.8, 16.4, 2.8, 14.6)
    ..cubicTo(2.8, 12.6, 4.4, 11, 6.6, 11)
    ..cubicTo(7, 8, 9.6, 5.8, 12.6, 6)
    ..cubicTo(15.6, 6.2, 18, 8.6, 18.2, 11.6)
    ..cubicTo(20.2, 12, 21.4, 13.6, 21.2, 15.4)
    ..cubicTo(21, 17.2, 19.4, 18.4, 17.6, 18.4)
    ..close()
    ..moveTo(5, 5)
    ..lineTo(19.6, 19.6);

  /// Le bateau en papier.
  static Path _bateau() => Path()
    ..moveTo(3, 14.6)
    ..lineTo(21, 14.6)
    ..lineTo(16.8, 19.6)
    ..lineTo(7.2, 19.6)
    ..close()
    ..moveTo(11.4, 14)
    ..lineTo(11.4, 4.6)
    ..lineTo(19, 14)
    ..close()
    ..moveTo(10.2, 14)
    ..lineTo(10.2, 8.4)
    ..lineTo(5.6, 14)
    ..close();

  /// Le phare qui balaie la nuit.
  static Path _phare() => Path()
    ..moveTo(9, 21.2)
    ..lineTo(10.3, 10.2)
    ..lineTo(13.7, 10.2)
    ..lineTo(15, 21.2)
    ..close()
    ..addRRect(RRect.fromLTRBR(10.5, 6.4, 13.5, 10.2, const Radius.circular(0.9)))
    ..moveTo(9.8, 6.4)
    ..lineTo(12, 3.8)
    ..lineTo(14.2, 6.4)
    ..moveTo(15.8, 6.6)
    ..lineTo(20.2, 4.8)
    ..moveTo(16, 9)
    ..lineTo(20.8, 9.6)
    ..moveTo(8.2, 6.6)
    ..lineTo(3.8, 4.8)
    ..moveTo(8, 9)
    ..lineTo(3.2, 9.6)
    ..moveTo(7.6, 21.2)
    ..lineTo(16.4, 21.2);

  /// Le satellite et ses panneaux.
  static Path _satellite() => Path()
    ..addRRect(RRect.fromLTRBR(9.4, 9.8, 14.6, 15, const Radius.circular(1.2)))
    ..addRRect(RRect.fromLTRBR(2.6, 10.8, 8, 14, const Radius.circular(0.9)))
    ..addRRect(RRect.fromLTRBR(16, 10.8, 21.4, 14, const Radius.circular(0.9)))
    ..moveTo(8, 12.4)
    ..lineTo(9.4, 12.4)
    ..moveTo(14.6, 12.4)
    ..lineTo(16, 12.4)
    ..moveTo(12, 9.8)
    ..lineTo(12, 7.2)
    ..addOval(Rect.fromCircle(center: const Offset(12, 5.8), radius: 1.5))
    ..addArc(Rect.fromCircle(center: const Offset(12, 5.8), radius: 3.8), -146 * _degre, 112 * _degre);

  /// La constellation — un maillage dans le ciel.
  static Path _constellation() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(4.6, 9.6), radius: 0.9))
    ..addOval(Rect.fromCircle(center: const Offset(10.2, 4.6), radius: 0.9))
    ..addOval(Rect.fromCircle(center: const Offset(15, 10.4), radius: 0.9))
    ..addOval(Rect.fromCircle(center: const Offset(8.4, 14.2), radius: 0.9))
    ..addOval(Rect.fromCircle(center: const Offset(19.4, 17), radius: 0.9))
    ..moveTo(5.4, 9)
    ..lineTo(9.4, 5.2)
    ..moveTo(10.9, 5.4)
    ..lineTo(14.4, 9.6)
    ..moveTo(14.3, 11)
    ..lineTo(9.1, 13.7)
    ..moveTo(15.6, 11.2)
    ..lineTo(18.8, 16.2)
    ..moveTo(20, 14.6)
    ..lineTo(20, 12.2);

  /// L'oignon de Tor.
  static Path _oignon() => Path()
    ..moveTo(12, 3.4)
    ..cubicTo(12, 3.4, 20.2, 9.2, 20.2, 15)
    ..cubicTo(20.2, 19.4, 16.5, 22, 12, 22)
    ..cubicTo(7.5, 22, 3.8, 19.4, 3.8, 15)
    ..cubicTo(3.8, 9.2, 12, 3.4, 12, 3.4)
    ..close()
    ..moveTo(12, 7)
    ..cubicTo(9.4, 11, 8.8, 15.6, 9.4, 19.6)
    ..moveTo(12, 7)
    ..cubicTo(14.6, 11, 15.2, 15.6, 14.6, 19.6)
    ..moveTo(12, 3.4)
    ..cubicTo(12.8, 2.2, 14.2, 1.8, 15.6, 2.2);

  /// Le signe du Bluetooth.
  static Path _bluetooth() => Path()
    ..moveTo(7.2, 7.8)
    ..lineTo(16.8, 16.4)
    ..lineTo(12, 20.8)
    ..lineTo(12, 3.2)
    ..lineTo(16.8, 7.8)
    ..lineTo(7.2, 16.4);

  /// Un point.
  static Path _point() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 1.15));

  /// Une croix.
  static Path _croix() => Path()
    ..moveTo(9.4, 12)
    ..lineTo(14.6, 12)
    ..moveTo(12, 9.4)
    ..lineTo(12, 14.6);

  /// Une petite goutte.
  static Path _petiteGoutte() => Path()
    ..moveTo(12, 6.6)
    ..cubicTo(10.4, 9.2, 8.2, 11.4, 8.2, 13.8)
    ..cubicTo(8.2, 16.2, 9.9, 18, 12, 18)
    ..cubicTo(14.1, 18, 15.8, 16.2, 15.8, 13.8)
    ..cubicTo(15.8, 11.4, 13.6, 9.2, 12, 6.6)
    ..close();

  /// Une étincelle.
  static Path _etincelle() => Path()
    ..moveTo(12, 6.4)
    ..cubicTo(12.7, 10.4, 13.6, 11.3, 17.6, 12)
    ..cubicTo(13.6, 12.7, 12.7, 13.6, 12, 17.6)
    ..cubicTo(11.3, 13.6, 10.4, 12.7, 6.4, 12)
    ..cubicTo(10.4, 11.3, 11.3, 10.4, 12, 6.4)
    ..close();
}

/// Le calque de motifs, à poser au-dessus du fond et sous la conversation.
/// Les jeux de motifs disponibles pour le fond des discussions.
enum PackMotifs { droplet, jeux, maison, jardin }

class CalqueMotifsDroplet extends StatefulWidget {
  const CalqueMotifsDroplet({
    super.key,
    required this.couleur,
    this.pack = PackMotifs.droplet,
  });

  final Color couleur;

  /// Le jeu de motifs choisi dans Apparence.
  final PackMotifs pack;

  @override
  State<CalqueMotifsDroplet> createState() => _CalqueMotifsDropletState();
}

class _CalqueMotifsDropletState extends State<CalqueMotifsDroplet> {
  @override
  void didUpdateWidget(covariant CalqueMotifsDroplet ancien) {
    super.didUpdateWidget(ancien);
    // Changer de pack recharge la tuile tout de suite.
    if (ancien.pack != widget.pack) didChangeDependencies();
  }

  ui.Image? _image;
  double? _densite;
  PackMotifs? _packCharge;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final densite = MediaQuery.devicePixelRatioOf(context);
    if (densite == _densite && _packCharge == widget.pack) return;
    _densite = densite;
    _packCharge = widget.pack;
    MotifsDroplet.image(densite, widget.pack).then((image) {
      if (mounted && _densite == densite) setState(() => _image = image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: image == null ? 0 : 1,
        duration: const Duration(milliseconds: 350),
        child: image == null
            ? const SizedBox.expand()
            : RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _PeintreMotifs(image, _densite ?? 1, widget.couleur),
                ),
              ),
      ),
    );
  }
}

class _PeintreMotifs extends CustomPainter {
  _PeintreMotifs(this.image, this.densite, this.couleur);

  final ui.Image image;
  final double densite;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final echelle = Matrix4.diagonal3Values(1 / densite, 1 / densite, 1);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(image, TileMode.repeated, TileMode.repeated, echelle.storage)
        ..colorFilter = ColorFilter.mode(couleur, BlendMode.srcIn)
        ..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_PeintreMotifs ancien) =>
      ancien.image != image || ancien.couleur != couleur || ancien.densite != densite;
}
