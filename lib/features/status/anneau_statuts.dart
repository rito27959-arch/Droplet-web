// ============================================================================
// L'ANNEAU SEGMENTÉ DES STATUTS
// ----------------------------------------------------------------------------
// Un anneau plein dit « il y a du nouveau ». Un anneau segmenté dit
// COMBIEN, et lesquels restent à voir : un arc par statut, allumé tant
// qu'on ne l'a pas regardé, éteint ensuite. On lit la progression avant
// même d'ouvrir.
//
// Deux soins qui font la différence :
//   • un seul statut donne un cercle entier, sans coupure — une coupure
//     unique ressemblerait à un défaut de tracé ;
//   • au-delà de seize, les arcs deviendraient de la poussière : on les
//     regroupe, et l'anneau reste lisible.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';

class AnneauStatuts extends StatelessWidget {
  const AnneauStatuts({
    super.key,
    required this.segments,
    required this.child,
    this.epaisseur = 2.2,
    this.ecart = 3,
    this.couleurVu,
    this.couleurNeuf,
  });

  /// Un booléen par statut, dans l'ordre : `true` = déjà vu.
  final List<bool> segments;

  final Widget child;
  final double epaisseur;

  /// L'espace entre deux arcs, en points de contour.
  final double ecart;

  final Color? couleurVu;
  final Color? couleurNeuf;

  /// Au-delà, les arcs ne se distinguent plus : on regroupe.
  static const int maxArcs = 16;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return child;
    return CustomPaint(
      painter: _PeintreAnneau(
        segments: segments,
        epaisseur: epaisseur,
        ecart: ecart,
        couleurVu: couleurVu ?? OuroColors.tertiaryLabel,
        couleurNeuf: couleurNeuf ?? OuroColors.accent,
      ),
      child: Padding(
        padding: EdgeInsets.all(epaisseur + 2),
        child: child,
      ),
    );
  }
}

class _PeintreAnneau extends CustomPainter {
  _PeintreAnneau({
    required this.segments,
    required this.epaisseur,
    required this.ecart,
    required this.couleurVu,
    required this.couleurNeuf,
  });

  final List<bool> segments;
  final double epaisseur;
  final double ecart;
  final Color couleurVu;
  final Color couleurNeuf;

  @override
  void paint(Canvas canvas, Size size) {
    final rayon = math.min(size.width, size.height) / 2 - epaisseur / 2;
    if (rayon <= 0) return;
    final boite = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: rayon,
    );
    final plume = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Un seul statut : cercle entier, pas de coupure orpheline.
    if (segments.length == 1) {
      canvas.drawCircle(
        boite.center,
        rayon,
        plume..color = segments.first ? couleurVu : couleurNeuf,
      );
      return;
    }

    // Trop de statuts pour autant d'arcs : on regroupe, et un paquet
    // compte comme vu seulement si TOUT le paquet l'est.
    final n = math.min(segments.length, AnneauStatuts.maxArcs);
    final paquets = <bool>[
      for (var i = 0; i < n; i++)
        segments
            .sublist(
              (i * segments.length / n).floor(),
              ((i + 1) * segments.length / n).ceil().clamp(1, segments.length),
            )
            .every((v) => v),
    ];

    // L'écart est donné en points de contour : converti en angle, il reste
    // constant à l'œil quelle que soit la taille de l'anneau.
    final angleEcart = (ecart / rayon).clamp(0.05, 0.5);
    final pas = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final debut = -math.pi / 2 + i * pas + angleEcart / 2;
      canvas.drawArc(
        boite,
        debut,
        pas - angleEcart,
        false,
        plume..color = paquets[i] ? couleurVu : couleurNeuf,
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreAnneau ancien) =>
      ancien.epaisseur != epaisseur ||
      ancien.ecart != ecart ||
      ancien.couleurVu != couleurVu ||
      ancien.couleurNeuf != couleurNeuf ||
      !_memeListe(ancien.segments, segments);

  static bool _memeListe(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
