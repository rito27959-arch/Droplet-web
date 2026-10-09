// ============================================================================
// LA DÉSINTÉGRATION — un message supprimé part en poussière, comme Telegram.
// ----------------------------------------------------------------------------
// Reprise, valeur pour valeur, de l'effet « Thanos » de Telegram Android
// (`ThanosEffect.java` et `thanos_vertex.glsl`, dépôt DrKLO/Telegram) :
//
//   • la bulle est photographiée à la résolution de l'écran, puis découpée
//     en une grille de grains d'environ un pixel physique (plafonnée selon
//     la puissance du téléphone) ;
//   • chaque grain part dans une direction AU HASARD, à 26–52 dp/s ;
//   • une poussée latérale de 19 dp/s² l'écarte pendant les 0,35 premières
//     unités de temps, et une « gravité » de 65 dp/s² l'emporte VERS LE HAUT ;
//   • les grains se mettent en mouvement en VAGUE, de gauche à droite : un
//     grain à la position horizontale u démarre à l'instant 0,6·u − 0,1 et
//     atteint sa pleine vitesse en 0,2 ;
//   • chaque grain vit entre 0,61 et 1,30 unité, s'use 1,2 fois plus vite
//     que le temps, et s'efface pendant ses 0,55 dernières unités ;
//   • le temps de l'effet s'écoule 1,15 fois plus vite que l'horloge.
//
// La bulle d'origine disparaît dès la première image : ce qui s'envole n'est
// que sa photo, posée par-dessus tout le reste. Telegram le fait en OpenGL ;
// ici la simulation tourne sur le processeur (quelques dizaines de milliers
// de grains, quelques additions chacun) et le dessin part en un seul appel
// `drawRawAtlas` : la photo sert d'atlas, chaque grain en montre sa case.
// ============================================================================

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/device_profile.dart';

class Dissolution {
  Dissolution._();

  // ── Constantes de Telegram ──────────────────────────────────────────
  static const double echelleTemps = 1.15;
  static const double dureeEffetPousse = 0.35;
  static const double decalageVague = 0.6;
  static const double poussee = 19.0;
  static const double gravite = -65.0;
  static const double vitesseBase = 260.0;
  static const double usure = 1.2;
  static const double fonduVie = 0.55;

  /// Au-delà, l'effet est forcément fini (vague 0,6 + vie max 1,30/1,2).
  static const double tempsMax = 2.0;

  /// Le plafond de grains pour UNE bulle, selon l'appareil — les mêmes
  /// paliers que Telegram, divisés par deux : la simulation tourne ici sur
  /// le processeur, pas sur la carte graphique.
  static int get grainsMax => switch (DeviceProfile.tier) {
        DeviceTier.modeste => 12000,
        DeviceTier.moyen => 30000,
        DeviceTier.confortable => 60000,
      };

  /// Photographie la bulle sous [cle] et lance sa désintégration par-dessus
  /// l'écran. Rend la main dès que la poussière est posée : l'appelant peut
  /// retirer la vraie bulle aussitôt. [part] répartit le plafond de grains
  /// quand plusieurs bulles partent ensemble.
  static Future<bool> jouer(BuildContext context, GlobalKey cle, {double part = 1}) async {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return false;
    final objet = cle.currentContext?.findRenderObject();
    if (objet is! RenderRepaintBoundary || !objet.attached || !objet.hasSize) return false;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return false;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final origine = objet.localToGlobal(Offset.zero);
    final taille = objet.size;
    final ui.Image image;
    try {
      image = await objet.toImage(pixelRatio: dpr);
    } catch (_) {
      return false;
    }
    if (image.width == 0 || image.height == 0) {
      image.dispose();
      return false;
    }
    // La ligne de la liste occupe toute la largeur ; seule la bulle compte.
    // Telegram travaille lui aussi sur les bords de la bulle, pas de la
    // cellule : la vague part du bord gauche de la BULLE.
    final cadre = await _cadreVisible(image);
    if (cadre == null) {
      image.dispose();
      return false;
    }
    final grille = GrillePoussiere.calculer(
      largeur: cadre.width.round(),
      hauteur: cadre.height.round(),
      dpr: dpr,
      plafond: (grainsMax * part).round(),
    );
    final poussiere = Poussiere(
      grille: grille,
      dpr: dpr,
      hasard: math.Random(),
      coin: cadre.topLeft,
    );

    if (!overlay.mounted) {
      image.dispose();
      return false;
    }
    late OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: _CouchePoussiere(
          image: image,
          poussiere: poussiere,
          origine: origine,
          taille: taille,
          dpr: dpr,
          surFin: () {
            entree.remove();
            image.dispose();
          },
        ),
      ),
    );
    overlay.insert(entree);
    return true;
  }
}

/// Le rectangle des pixels non transparents de [image], ou `null`.
Future<Rect?> _cadreVisible(ui.Image image) async {
  final donnees = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (donnees == null) return null;
  final l = image.width;
  final h = image.height;
  var gauche = l, droite = -1, haut = h, bas = -1;
  // Un pixel sur deux suffit à trouver les bords d'une bulle.
  for (var y = 0; y < h; y += 2) {
    final ligne = y * l;
    for (var x = 0; x < l; x += 2) {
      if (donnees.getUint8((ligne + x) * 4 + 3) < 8) continue;
      if (x < gauche) gauche = x;
      if (x > droite) droite = x;
      if (y < haut) haut = y;
      if (y > bas) bas = y;
    }
  }
  if (droite < gauche || bas < haut) return null;
  return Rect.fromLTRB(
    math.max(0, gauche - 1).toDouble(),
    math.max(0, haut - 1).toDouble(),
    math.min(l, droite + 2).toDouble(),
    math.min(h, bas + 2).toDouble(),
  );
}

/// La découpe de la photo en grains — le calcul exact de Telegram.
class GrillePoussiere {
  const GrillePoussiere(this.colonnes, this.lignes, this.cote);

  final int colonnes;
  final int lignes;

  /// Le côté d'un grain, en pixels physiques.
  final double cote;

  int get nombre => colonnes * lignes;

  static GrillePoussiere calculer({
    required int largeur,
    required int hauteur,
    required double dpr,
    required int plafond,
  }) {
    // Telegram : un grain de 0,4 dp, jamais moins d'un pixel.
    final p = math.max(0.4 * dpr, 1.0);
    final voulu = (largeur * hauteur / (p * p)).floor().clamp(10, math.max(10, plafond));
    final ratio = largeur / hauteur;
    var lignes = math.max(1, math.sqrt(voulu / ratio).round());
    var colonnes = math.max(1, (voulu / lignes).round());
    while (colonnes * lignes < voulu) {
      if (colonnes / lignes < ratio) {
        colonnes++;
      } else {
        lignes++;
      }
    }
    final cote = math.max(largeur / colonnes, hauteur / lignes);
    return GrillePoussiere(colonnes, lignes, cote);
  }
}

/// L'état de chaque grain, dans des tableaux plats : position, vitesse,
/// temps de vie restant. Coordonnées en pixels physiques, relatives au coin
/// de la bulle.
class Poussiere {
  Poussiere({
    required this.grille,
    required this.dpr,
    required math.Random hasard,
    this.coin = Offset.zero,
  })  : x = Float32List(grille.nombre),
        y = Float32List(grille.nombre),
        vx = Float32List(grille.nombre),
        vy = Float32List(grille.nombre),
        vie = Float32List(grille.nombre),
        u = Float32List(grille.nombre) {
    final n = grille.nombre;
    for (var i = 0; i < n; i++) {
      final colonne = i % grille.colonnes;
      final ligne = i ~/ grille.colonnes;
      final uu = colonne / grille.colonnes;
      u[i] = uu;
      x[i] = coin.dx + (colonne + 0.5) * grille.cote;
      y[i] = coin.dy + (ligne + 0.5) * grille.cote;
      final direction = hasard.nextDouble() * math.pi * 2;
      final vitesse = (0.1 + hasard.nextDouble() * 0.1) * Dissolution.vitesseBase * dpr;
      vx[i] = math.cos(direction) * vitesse;
      vy[i] = math.sin(direction) * vitesse;
      vie[i] = (0.7 + hasard.nextDouble() * 0.8) / 1.15;
    }
  }

  final GrillePoussiere grille;
  final double dpr;

  /// Le coin haut-gauche de la bulle dans la photo, en pixels physiques.
  final Offset coin;
  final Float32List x;
  final Float32List y;
  final Float32List vx;
  final Float32List vy;
  final Float32List vie;
  final Float32List u;

  /// Le temps de l'effet (déjà multiplié par `echelleTemps`).
  double temps = 0;

  bool get fini => temps >= Dissolution.tempsMax;

  /// Avance la simulation de [dt] secondes d'horloge.
  ///
  /// Même ordre d'opérations que Telegram : l'horloge avance d'abord, puis
  /// le shader lit ce temps pour calculer les fractions de cette image.
  void avancer(double dt) {
    temps += dt * Dissolution.echelleTemps;
    final pas = dt * Dissolution.echelleTemps;
    final effet = temps.clamp(0.0, Dissolution.dureeEffetPousse) / Dissolution.dureeEffetPousse;
    final lateral = Dissolution.poussee * (1 - effet) * pas * dpr;
    final vertical = Dissolution.gravite * pas * dpr;
    for (var i = 0; i < x.length; i++) {
      final fraction = (0.1 + temps - u[i] * Dissolution.decalageVague).clamp(0.0, 0.2) / 0.2;
      if (fraction == 0) continue;
      x[i] += vx[i] * pas * fraction;
      y[i] += vy[i] * pas * fraction;
      vx[i] += (vx[i] > 0 ? lateral : -lateral) * fraction;
      vy[i] += vertical * fraction;
      final reste = vie[i] - Dissolution.usure * pas * fraction;
      vie[i] = reste > 0 ? reste : 0;
    }
  }

  /// L'opacité d'un grain.
  double opacite(int i) => (vie[i].clamp(0.0, Dissolution.fonduVie)) / Dissolution.fonduVie;
}

class _CouchePoussiere extends StatefulWidget {
  const _CouchePoussiere({
    required this.image,
    required this.poussiere,
    required this.origine,
    required this.taille,
    required this.dpr,
    required this.surFin,
  });

  final ui.Image image;
  final Poussiere poussiere;
  final Offset origine;
  final Size taille;
  final double dpr;
  final VoidCallback surFin;

  @override
  State<_CouchePoussiere> createState() => _CouchePoussiereState();
}

class _CouchePoussiereState extends State<_CouchePoussiere>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _image = ValueNotifier(0);
  Duration _precedent = Duration.zero;
  bool _termine = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_battement)..start();
  }

  void _battement(Duration ecoule) {
    // Un saut d'horloge (application en pause) ne doit pas téléporter les
    // grains : on borne le pas à 50 ms (une image à 20 i/s).
    final dt = math.min((ecoule - _precedent).inMicroseconds / 1e6, 1 / 20);
    _precedent = ecoule;
    widget.poussiere.avancer(dt);
    _image.value++;
    if (widget.poussiere.fini && !_termine) {
      _termine = true;
      _ticker.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.surFin());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.origine.dx,
          top: widget.origine.dy,
          width: widget.taille.width,
          height: widget.taille.height,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _PeintrePoussiere(
                image: widget.image,
                poussiere: widget.poussiere,
                dpr: widget.dpr,
                repeindre: _image,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeintrePoussiere extends CustomPainter {
  _PeintrePoussiere({
    required this.image,
    required this.poussiere,
    required this.dpr,
    required Listenable repeindre,
  })  : _transfos = Float32List(poussiere.grille.nombre * 4),
        _sources = Float32List(poussiere.grille.nombre * 4),
        _cases = Float32List(poussiere.grille.nombre * 4),
        _couleurs = Int32List(poussiere.grille.nombre),
        super(repaint: repeindre) {
    final g = poussiere.grille;
    for (var i = 0; i < g.nombre; i++) {
      final colonne = i % g.colonnes;
      final ligne = i ~/ g.colonnes;
      final k = i * 4;
      final c = poussiere.coin;
      _sources[k] = c.dx + colonne * g.cote;
      _sources[k + 1] = c.dy + ligne * g.cote;
      _sources[k + 2] = c.dx + (colonne + 1) * g.cote;
      _sources[k + 3] = c.dy + (ligne + 1) * g.cote;
    }
  }

  final ui.Image image;
  final Poussiere poussiere;
  final double dpr;
  final Float32List _transfos;
  final Float32List _sources;
  final Float32List _cases;
  final Int32List _couleurs;
  final Paint _pinceau = Paint()..filterQuality = FilterQuality.none;

  @override
  void paint(Canvas canvas, Size size) {
    final p = poussiere;
    final demi = p.grille.cote / 2;
    // Les grains éteints sont sautés : transformations, cases et couleurs
    // sont tassées ensemble, dans le même ordre.
    var visibles = 0;
    for (var i = 0; i < p.x.length; i++) {
      final a = p.opacite(i);
      if (a <= 0) continue;
      final k = visibles * 4;
      final s = i * 4;
      // RSTransform : échelle 1, sans rotation, coin haut-gauche du grain.
      _transfos[k] = 1;
      _transfos[k + 1] = 0;
      _transfos[k + 2] = p.x[i] - demi;
      _transfos[k + 3] = p.y[i] - demi;
      _cases[k] = _sources[s];
      _cases[k + 1] = _sources[s + 1];
      _cases[k + 2] = _sources[s + 2];
      _cases[k + 3] = _sources[s + 3];
      _couleurs[visibles] = ((a * 255).round() << 24) | 0x00FFFFFF;
      visibles++;
    }
    if (visibles == 0) return;
    canvas.save();
    canvas.scale(1 / dpr);
    canvas.drawRawAtlas(
      image,
      Float32List.sublistView(_transfos, 0, visibles * 4),
      Float32List.sublistView(_cases, 0, visibles * 4),
      Int32List.sublistView(_couleurs, 0, visibles),
      BlendMode.modulate,
      null,
      _pinceau,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintrePoussiere old) => false;
}
