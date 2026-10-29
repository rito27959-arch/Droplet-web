// ============================================================================
// L'ENVOI EN AVION EN PAPIER — avec Flame.
// ----------------------------------------------------------------------------
// De temps en temps (pas à chaque message : voir `AvionEnvoi.choisir`),
// l'envoi devient une petite scène :
//
//   1. LE BOUTON SE PLIE. Le rond du bouton d'envoi s'ouvre en feuille,
//      qui se plie en avion en papier sous nos yeux.
//   2. LE HÉROS APPARAÎT, EN GRAND, en haut de l'écran, comme les stickers
//      géants de WhatsApp :
//        • pour un texte, Plic, la goutte de Droplet, qui salue ;
//        • pour un sticker, le sticker lui-même, en grand, qui joue.
//   3. L'AVION MONTE jusqu'au héros en laissant un fil d'encre, fait une
//      boucle autour de lui (le héros le relance), puis PIQUE vers la
//      conversation.
//   4. IL SE POSE et SE DÉPLIE en bulle : la feuille prend la forme exacte
//      de la vraie bulle, sa couleur, puis la vraie bulle apparaît à sa
//      place — on ne voit jamais deux messages.
//
// Pour un sticker, pas d'avion : c'est le sticker qui grandit depuis le
// bouton, joue en grand au milieu de l'écran, puis rejoint sa place.
//
// ── Les garde-fous ───────────────────────────────────────────────────
//
// • La vraie bulle est mesurée À CHAQUE IMAGE (`cible`) : si la liste
//   défile pendant le vol, l'avion suit. Si elle n'apparaît jamais, l'avion
//   se pose au-dessus de la barre de saisie et s'efface ; `surFin` rend
//   toujours la bulle visible.
// • Rien ne capte le doigt : la scène est posée dans l'Overlay, sous un
//   `IgnorePointer`. On peut continuer à écrire pendant le vol.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import 'stickers_personnage.dart';

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Le déroulé (millisecondes).
const double _dPliage = 240;
const double _tHeros = 110;
const double _tMontee = 220;
const double _tBoucle = 860;
const double _tPique = 1160;
const double _tPose = 1560;
const double _tDeplie = 1560;
const double _tRevele = 1650;
const double _tFin = 1950;

class AvionEnvoi {
  AvionEnvoi._();

  static const String _cleDernier = 'avion_dernier';
  static const String _clePrefixeJour = 'avion_jour_';
  static bool _enVol = false;

  /// Faut-il un avion pour ce message ? « Une fois sur plusieurs » :
  ///   • le premier message de la journée dans cette conversation ;
  ///   • ou un message long (plus de 140 caractères) ;
  ///   • ou dix minutes sans avion ;
  /// et jamais deux avions à moins de 25 secondes d'écart.
  static bool choisir({required String conversation, required String texte}) {
    if (_enVol) return false;
    final maintenant = DateTime.now();
    final dernier = int.tryParse(StorageService.getString(_cleDernier) ?? '') ?? 0;
    final ecart = maintenant.millisecondsSinceEpoch - dernier;
    if (ecart < 25000) return false;
    final jour = '${maintenant.year}${maintenant.month.toString().padLeft(2, '0')}${maintenant.day.toString().padLeft(2, '0')}';
    final premierDuJour = StorageService.getString('$_clePrefixeJour$conversation') != jour;
    return premierDuJour || texte.length > 140 || ecart > 10 * 60 * 1000;
  }

  static void _retenir(String conversation) {
    final maintenant = DateTime.now();
    final jour = '${maintenant.year}${maintenant.month.toString().padLeft(2, '0')}${maintenant.day.toString().padLeft(2, '0')}';
    StorageService.setString(_cleDernier, '${maintenant.millisecondsSinceEpoch}');
    StorageService.setString('$_clePrefixeJour$conversation', jour);
  }

  /// Lance la scène. [depart] : le centre du bouton d'envoi (écran).
  /// [cible] : la vraie bulle, mesurée à la demande (null tant qu'elle
  /// n'est pas là). [revelation] passe de 0 à 1 quand la vraie bulle doit
  /// apparaître. [sticker] : la clé « lot/id » d'un sticker Droplet, ou
  /// null pour un texte (le héros est alors Plic).
  static bool jouer({
    required BuildContext context,
    required String conversation,
    required Offset depart,
    required Rect? Function() cible,
    required ValueNotifier<double> revelation,
    required Color couleur,
    required Color papier,
    required bool sombre,
    String? sticker,
    required VoidCallback surFin,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return false;
    _enVol = true;
    _retenir(conversation);
    late final OverlayEntry entree;
    var fini = false;
    void finir() {
      if (fini) return;
      fini = true;
      _enVol = false;
      revelation.value = 1;
      entree.remove();
      surFin();
    }

    final jeu = JeuAvionEnvoi(
      depart: depart,
      cible: cible,
      revelation: revelation,
      couleur: couleur,
      papier: papier,
      sombre: sombre,
      sticker: sticker,
      surFin: () => WidgetsBinding.instance.addPostFrameCallback((_) => finir()),
    );
    entree = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(child: GameWidget<JeuAvionEnvoi>(game: jeu)),
      ),
    );
    overlay.insert(entree);
    // Filet : quoi qu'il arrive au jeu, la bulle réapparaît.
    Future<void>.delayed(const Duration(milliseconds: 3200), finir);
    return true;
  }
}

class JeuAvionEnvoi extends FlameGame {
  JeuAvionEnvoi({
    required this.depart,
    required this.cible,
    required this.revelation,
    required this.couleur,
    required this.papier,
    required this.sombre,
    required this.sticker,
    required this.surFin,
  });

  final Offset depart;
  final Rect? Function() cible;
  final ValueNotifier<double> revelation;
  final Color couleur;
  final Color papier;
  final bool sombre;
  final String? sticker;
  final VoidCallback surFin;

  /// Le temps de la scène, en millisecondes.
  double t = 0;
  bool _fini = false;
  bool _poseFaite = false;

  /// Le dernier endroit connu de la bulle (elle peut défiler).
  Rect? bulle;

  bool get modeSticker => sticker != null;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    add(_Fil(priority: 1));
    add(_Heros(priority: 2));
    add(_Avion(priority: 3));
  }

  @override
  void update(double dt) {
    // Un pas d'au plus 1/30 s : après un à-coup (clavier, liste), l'avion
    // ne saute pas une partie du trajet.
    t += math.min(dt, 1 / 30) * 1000;
    final r = cible();
    if (r != null) bulle = r;
    super.update(dt);
    if (!_poseFaite && t >= _tPose) {
      _poseFaite = true;
      final ou = repli;
      eclater(ou.center, couleur);
    }
    revelation.value = Curves.easeOutCubic.transform(_seg(t, _tRevele, _tRevele + 230));
    if (!_fini && t >= _tFin) {
      _fini = true;
      surFin();
    }
  }

  /// Le héros : en haut, au centre, en grand.
  Offset get placeHeros => Offset(size.x / 2, size.y * (modeSticker ? 0.38 : 0.26));
  double get tailleHeros => math.min(size.x * (modeSticker ? 0.62 : 0.5), 240);

  /// Où se poser : la bulle, ou à défaut au-dessus du bouton.
  Rect get repli => bulle ?? Rect.fromCenter(center: depart + const Offset(-90, -70), width: 120, height: 40);

  // ── Les particules ─────────────────────────────────────────────────

  final math.Random _hasard = math.Random();

  /// À l'atterrissage : des gouttelettes et des confettis de papier.
  void eclater(Offset ou, Color teinte) {
    add(ParticleSystemComponent(
      priority: 4,
      position: Vector2(ou.dx, ou.dy),
      particle: Particle.generate(
        count: 18,
        lifespan: 0.7,
        generator: (i) {
          final a = -math.pi * _hasard.nextDouble();
          final v = 90 + _hasard.nextDouble() * 180;
          final confetti = i.isEven;
          return AcceleratedParticle(
            speed: Vector2(math.cos(a) * v, math.sin(a) * v),
            acceleration: Vector2(0, 480),
            child: confetti
                ? _Confetti(couleur: i % 4 == 0 ? teinte : papier, angle0: _hasard.nextDouble() * math.pi)
                : _Gouttelette(couleur: teinte, rayon: 1.6 + _hasard.nextDouble() * 2.4),
          );
        },
      ),
    ));
  }

  /// Une étincelle de temps en temps, dans le sillage.
  void etincelle(Offset ou) {
    add(ParticleSystemComponent(
      priority: 1,
      position: Vector2(ou.dx, ou.dy),
      particle: AcceleratedParticle(
        lifespan: 0.45,
        speed: Vector2((_hasard.nextDouble() - 0.5) * 40, 20 + _hasard.nextDouble() * 30),
        child: _Etincelle(couleur: couleur),
      ),
    ));
  }

  // ── Le trajet ──────────────────────────────────────────────────────

  /// La position et le cap de l'avion à l'instant [t].
  (Offset, double) trajet(double t) {
    final h = placeHeros;
    final main = h + Offset(tailleHeros * 0.36, tailleHeros * 0.05);
    if (t < _tMontee) return (depart, -math.pi / 4);
    if (t < _tBoucle) {
      // La montée, en S : d'abord vers la gauche, puis vers la main du héros.
      final p = Curves.easeInOutSine.transform(_seg(t, _tMontee, _tBoucle));
      final c1 = depart + Offset(-size.x * 0.55, -size.y * 0.12);
      final c2 = main + Offset(size.x * 0.05, size.y * 0.32);
      return _bezier(depart, c1, c2, main, p);
    }
    if (t < _tPique) {
      // La boucle autour du héros : il relance l'avion.
      final p = Curves.easeInOutSine.transform(_seg(t, _tBoucle, _tPique));
      final r = tailleHeros * 0.62;
      final a0 = math.atan2(main.dy - h.dy, main.dx - h.dx);
      final a = a0 - p * 2 * math.pi;
      final rayon = r * (0.6 + 0.4 * math.sin(math.pi * p)) + (main - h).distance * (1 - math.sin(math.pi * p));
      final pos = h + Offset(math.cos(a), math.sin(a)) * rayon;
      return (pos, a - math.pi / 2);
    }
    // Le piqué vers la bulle, qui finit en glissade.
    final arrivee = Offset(repli.left + 18, repli.center.dy);
    final p = Curves.easeInOutCubic.transform(_seg(t, _tPique, _tPose));
    final c1 = main + Offset(size.x * 0.35, size.y * 0.05);
    final c2 = arrivee + Offset(-size.x * 0.25, -size.y * 0.2);
    final (pos, cap) = _bezier(main, c1, c2, arrivee, p);
    // En se posant, il redresse le nez.
    final redresse = _seg(t, _tPose - 140, _tPose);
    return (pos, cap * (1 - redresse));
  }

  (Offset, double) _bezier(Offset a, Offset b, Offset c, Offset d, double p) {
    final u = 1 - p;
    final pos = a * (u * u * u) + b * (3 * u * u * p) + c * (3 * u * p * p) + d * (p * p * p);
    final der = (b - a) * (3 * u * u) + (c - b) * (6 * u * p) + (d - c) * (3 * p * p);
    return (pos, math.atan2(der.dy, der.dx));
  }
}

// ─────────────────────────────────────────────────────────────
//  LE FIL D'ENCRE : le sillage de l'avion
// ─────────────────────────────────────────────────────────────

class _Fil extends Component with HasGameReference<JeuAvionEnvoi> {
  _Fil({super.priority});

  final List<(Offset, double)> _points = [];
  double _derniereEtincelle = 0;

  @override
  void update(double dt) {
    final j = game;
    if (j.modeSticker) return;
    final t = j.t;
    if (t >= _tMontee && t < _tPose) {
      _points.add((j.trajet(t).$1, t));
      if (t - _derniereEtincelle > 70) {
        _derniereEtincelle = t;
        j.etincelle(j.trajet(t).$1);
      }
    }
    // Le fil s'efface par la queue : il n'en reste que 380 ms.
    _points.removeWhere((p) => t - p.$2 > 380);
  }

  @override
  void render(Canvas canvas) {
    if (_points.length < 2) return;
    final t = game.t;
    for (var k = 1; k < _points.length; k++) {
      final (a, ta) = _points[k - 1];
      final (b, _) = _points[k];
      final age = ((t - ta) / 380).clamp(0.0, 1.0);
      // Des tirets : un segment sur deux, comme un pointillé à la plume.
      if (k % 3 == 0) continue;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 2.6 * (1 - age)
          ..strokeCap = StrokeCap.round
          ..color = game.couleur.withValues(alpha: 0.7 * (1 - age)),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  LE HÉROS : Plic, ou le sticker envoyé
// ─────────────────────────────────────────────────────────────

class _Heros extends Component with HasGameReference<JeuAvionEnvoi> {
  _Heros({super.priority});

  @override
  void render(Canvas canvas) {
    final j = game;
    final t = j.t;
    final sticker = j.sticker;

    late Offset centre;
    late double cote;
    double alpha = 1;
    if (sticker != null) {
      // Le sticker grandit depuis le bouton, joue au centre, puis rejoint
      // sa bulle en rapetissant.
      final arrivee = j.repli;
      if (t < _tMontee + 120) {
        final p = Curves.easeOutBack.transform(_seg(t, 0, _tMontee + 120));
        centre = Offset.lerp(j.depart, j.placeHeros, Curves.easeOutCubic.transform(_seg(t, 0, _tMontee + 120)))!;
        cote = 30 + (j.tailleHeros - 30) * p;
      } else if (t < _tPique) {
        centre = j.placeHeros + Offset(0, 6 * math.sin(t / 160));
        cote = j.tailleHeros * (1 + 0.03 * math.sin(t / 110));
      } else {
        final p = Curves.easeInOutCubic.transform(_seg(t, _tPique, _tPose));
        centre = Offset.lerp(j.placeHeros, arrivee.center, p)!;
        cote = j.tailleHeros + (arrivee.shortestSide - j.tailleHeros) * p;
        alpha = 1 - _seg(t, _tRevele, _tRevele + 200);
      }
      // L'auréole des stickers géants.
      if (t < _tPique) {
        final a = _seg(t, 0, 240) * (1 - _seg(t, _tPique - 200, _tPique));
        canvas.drawCircle(
          centre,
          cote * 0.75,
          Paint()
            ..shader = ui.Gradient.radial(centre, cote * 0.75, [
              j.couleur.withValues(alpha: 0.22 * a),
              j.couleur.withValues(alpha: 0),
            ]),
        );
      }
      _dessiner(canvas, sticker, centre, cote, t / 1000, alpha);
      return;
    }

    // Plic : il surgit d'un ressort, salue, relance l'avion, puis s'en va.
    final entree = Curves.easeOutBack.transform(_seg(t, _tHeros, _tHeros + 380));
    final sortie = Curves.easeInCubic.transform(_seg(t, _tPique + 120, _tPose + 120));
    if (entree <= 0 || sortie >= 1) return;
    centre = j.placeHeros + Offset(0, -40 * sortie + 4 * math.sin(t / 170));
    cote = j.tailleHeros * entree * (1 - 0.6 * sortie);
    alpha = 1 - sortie;
    // Au moment de la relance, il se tourne vers l'avion (la clé « rire »
    // quand il le rattrape, « salut » sinon).
    final cle = t >= _tBoucle && t < _tPique ? 'goutte/fete' : 'goutte/salut';
    canvas.drawCircle(
      centre,
      cote * 0.62,
      Paint()
        ..shader = ui.Gradient.radial(centre, cote * 0.62, [
          j.couleur.withValues(alpha: 0.18 * alpha),
          j.couleur.withValues(alpha: 0),
        ]),
    );
    _dessiner(canvas, cle, centre, cote, (t - _tHeros) / 1000 + 0.35, alpha);
  }

  void _dessiner(Canvas canvas, String cle, Offset centre, double cote, double s, double alpha) {
    if (cote <= 1 || alpha <= 0) return;
    canvas.save();
    if (alpha < 1) canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    canvas.translate(centre.dx - cote / 2, centre.dy - cote / 2);
    canvas.scale(cote);
    dessinerSticker(canvas, cle, s, sombre: game.sombre);
    if (alpha < 1) canvas.restore();
    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────
//  L'AVION : le bouton qui se plie, le vol, le dépliage en bulle
// ─────────────────────────────────────────────────────────────

class _Avion extends Component with HasGameReference<JeuAvionEnvoi> {
  _Avion({super.priority});

  // L'avion, nez vers +x, en unités (envergure ≈ 1).
  static const List<Offset> _aile = [Offset(0.62, 0), Offset(-0.42, -0.4), Offset(-0.22, 0), Offset(-0.42, 0.4)];

  @override
  void render(Canvas canvas) {
    final j = game;
    if (j.modeSticker) return;
    final t = j.t;
    if (t > _tRevele + 260) return;
    final (pos, cap) = j.trajet(t);
    const envergure = 44.0;

    // 1 — Le pliage : un rond (le bouton) qui devient feuille, puis avion.
    if (t < _dPliage) {
      final p = _seg(t, 0, _dPliage);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(cap * Curves.easeIn.transform(p));
      // Le rond du bouton s'efface en s'ouvrant…
      canvas.drawCircle(Offset.zero, 18 * (1 - p), Paint()..color = j.couleur.withValues(alpha: 1 - p));
      // … la feuille se plie : ses coins rejoignent ceux de l'avion.
      final carre = [const Offset(0.5, -0.5), const Offset(-0.5, -0.5), const Offset(-0.25, 0), const Offset(-0.5, 0.5)];
      final q = Curves.easeInOutCubic.transform(_seg(p, 0.2, 1));
      final pts = [for (var k = 0; k < 4; k++) Offset.lerp(carre[k], _aile[k], q)! * envergure * (0.5 + 0.5 * _seg(p, 0, 0.5))];
      _feuille(canvas, pts, j, opacite: _seg(p, 0, 0.3));
      canvas.restore();
      return;
    }

    // 3 — Le dépliage : l'avion devient la bulle.
    final deplie = Curves.easeInOutCubic.transform(_seg(t, _tDeplie, _tRevele + 120));
    if (deplie > 0) {
      final r = j.repli;
      final rayon = math.min(18.0, r.height / 2);
      final depuis = Rect.fromCenter(center: pos, width: envergure, height: envergure * 0.5);
      final rect = Rect.lerp(depuis, r, deplie)!;
      final fond = Color.lerp(j.papier, j.couleur, deplie)!;
      final alpha = 1 - _seg(t, _tRevele + 40, _tRevele + 260);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rayon * deplie + 4)),
        Paint()..color = fond.withValues(alpha: fond.a * alpha),
      );
      // Les plis de la feuille s'effacent à mesure qu'elle s'aplanit.
      final plis = Paint()
        ..strokeWidth = 1
        ..color = j.couleur.withValues(alpha: 0.35 * (1 - deplie) * alpha);
      canvas.drawLine(rect.centerLeft, rect.centerRight, plis);
      canvas.drawLine(rect.topCenter, rect.bottomCenter, plis);
      return;
    }

    // 2 — Le vol : l'avion, incliné dans les virages.
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(cap);
    // L'ombre portée, plus loin quand il monte haut.
    final pts = [for (final o in _aile) o * envergure];
    canvas.save();
    canvas.translate(6, 10);
    canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = const Color(0x22000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.restore();
    // Le roulis : l'aile du dessous se resserre dans les virages.
    final roulis = math.sin(t / 120) * 0.12;
    final ailes = [pts[0], pts[1] * (1 + roulis), pts[2], pts[3] * (1 - roulis)];
    _feuille(canvas, ailes, j);
    canvas.restore();
  }

  /// La feuille d'avion : deux ailes, le pli central plus sombre.
  void _feuille(Canvas canvas, List<Offset> p, JeuAvionEnvoi j, {double opacite = 1}) {
    if (opacite <= 0) return;
    final papier = j.papier.withValues(alpha: j.papier.a * opacite);
    final ombre = Color.lerp(j.papier, j.couleur, 0.35)!.withValues(alpha: opacite);
    // L'aile haute, l'aile basse (plus sombre : elle est dans l'ombre).
    canvas.drawPath(Path()..addPolygon([p[0], p[1], p[2]], true), Paint()..color = papier);
    canvas.drawPath(Path()..addPolygon([p[0], p[2], p[3]], true), Paint()..color = ombre);
    // La quille, à l'encre de Droplet.
    canvas.drawLine(
      p[0],
      p[2],
      Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = j.couleur.withValues(alpha: opacite),
    );
    // Le liseré, pour que l'avion se détache sur un fond clair comme sombre.
    canvas.drawPath(
      Path()..addPolygon(p, true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..color = j.couleur.withValues(alpha: 0.55 * opacite),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES PARTICULES
// ─────────────────────────────────────────────────────────────

class _Gouttelette extends Particle {
  _Gouttelette({required this.couleur, required this.rayon}) : super(lifespan: 0.7);
  final Color couleur;
  final double rayon;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, rayon * (1 - 0.4 * progress), Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress)));
  }
}

class _Confetti extends Particle {
  _Confetti({required this.couleur, required this.angle0}) : super(lifespan: 0.7);
  final Color couleur;
  final double angle0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(angle0 + progress * 9);
    // Un petit rectangle de papier qui tournoie (il s'amincit de profil).
    final w = 7 * math.cos(progress * 14).abs() + 1;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: 4), Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress)));
    canvas.restore();
  }
}

class _Etincelle extends Particle {
  _Etincelle({required this.couleur}) : super(lifespan: 0.45);
  final Color couleur;

  @override
  void render(Canvas canvas) {
    final r = 3.2 * (1 - progress);
    final p = Paint()..color = couleur.withValues(alpha: couleur.a * (1 - progress));
    // Une étoile à quatre branches.
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 1.6)
        ..lineTo(r * 0.35, -r * 0.35)
        ..lineTo(r * 1.6, 0)
        ..lineTo(r * 0.35, r * 0.35)
        ..lineTo(0, r * 1.6)
        ..lineTo(-r * 0.35, r * 0.35)
        ..lineTo(-r * 1.6, 0)
        ..lineTo(-r * 0.35, -r * 0.35)
        ..close(),
      p,
    );
  }
}
