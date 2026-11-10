// ============================================================================
// LA BARRE D'APPEL EN VERRE GLASMIO (Android 13+, version Glasmio).
// ----------------------------------------------------------------------------
// Sur les écrans d'appel (1:1 et salon), la barre de contrôle est dessinée
// par Glasmio, en natif (BarreAppelGlasmio.kt) : vrai verre qui réfracte la
// vidéo, boutons ronds de verre, le rouge pour raccrocher.
//
// La barre Flutter reste EN PLACE, invisible et sans toucher : elle garde la
// mise en page (la vignette de ma caméra se cale au-dessus d'elle) et sert
// de repli immédiat partout où Glasmio n'est pas là. On envoie au natif son
// rectangle exact, les boutons, et on reçoit les touchers.
// ============================================================================

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/services/barre_glasmio.dart' show observateurRoutesGlasmio;
import '../../core/services/pont_glasmio.dart';

class BoutonBarreAppel {
  const BoutonBarreAppel({
    required this.id,
    required this.icone,
    required this.legende,
    required this.semantique,
    required this.onTap,
    this.actif = false,
    this.destructif = false,
  });

  final String id;

  /// Clé d'icône côté natif : haut_parleur_on/off, camera_on/off,
  /// retourner, micro, micro_off, raccrocher.
  final String icone;
  final String legende;
  final String semantique;
  final VoidCallback onTap;
  final bool actif;
  final bool destructif;

  Map<String, Object?> versCarte() => {
        'id': id,
        'icone': icone,
        'legende': legende,
        'semantique': semantique,
        'actif': actif,
        'destructif': destructif,
      };
}

class BarreAppelGlasmio extends StatefulWidget {
  const BarreAppelGlasmio({
    super.key,
    required this.boutons,
    required this.visible,
    required this.repli,
  });

  final List<BoutonBarreAppel> boutons;

  /// Les contrôles sont affichés (ils s'effacent pendant une vidéo).
  final bool visible;

  /// La barre Flutter : affichée sans Glasmio, invisible avec.
  final Widget repli;

  @override
  State<BarreAppelGlasmio> createState() => _BarreAppelGlasmioState();
}

class _BarreAppelGlasmioState extends State<BarreAppelGlasmio> with WidgetsBindingObserver {
  static const _canal = MethodChannel('droplet/glasmio');
  static Future<bool>? _disponible;

  final _cle = GlobalKey();
  bool _natif = false;
  String? _derniere;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || !Platform.isAndroid) return;
    WidgetsBinding.instance.addObserver(this);
    observateurRoutesGlasmio.sommet.addListener(_planifier);
    (_disponible ??= PontGlasmio.disponible()).then((ok) {
      if (!mounted || !ok) return;
      PontGlasmio.installerRecepteur();
      PontGlasmio.surBarreAppel = _surTouche;
      setState(() => _natif = true);
    });
  }

  @override
  void didChangeMetrics() => _planifier();

  void _surTouche(String id) {
    for (final b in widget.boutons) {
      if (b.id == id) {
        // Raccrocher a déjà son retour haptique, plus marqué.
        if (!b.destructif) HapticFeedback.selectionClick();
        b.onTap();
        return;
      }
    }
  }

  void _planifier() {
    if (!_natif) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _envoyer());
  }

  void _envoyer({bool forcerCache = false}) {
    if (!_natif) return;
    var visible = !forcerCache && mounted && widget.visible;
    Rect? r;
    if (visible) {
      // Une page, une feuille ou une alerte par-dessus l'appel : la barre native s'efface.
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) visible = false;
      final boite = _cle.currentContext?.findRenderObject() as RenderBox?;
      if (boite == null || !boite.hasSize || !boite.attached) {
        visible = false;
      } else {
        r = boite.localToGlobal(Offset.zero) & boite.size;
      }
    }
    final d = jsonEncode({
      'visible': visible,
      if (r != null) ...{'x': r.left, 'y': r.top, 'l': r.width, 'h': r.height},
      'boutons': [for (final b in widget.boutons) b.versCarte()],
    });
    if (d == _derniere) return;
    _derniere = d;
    _canal.invokeMethod<void>('barre_appel', {'description': d}).catchError((_) {});
  }

  @override
  void dispose() {
    if (!kIsWeb && Platform.isAndroid) {
      WidgetsBinding.instance.removeObserver(this);
      observateurRoutesGlasmio.sommet.removeListener(_planifier);
      if (PontGlasmio.surBarreAppel == _surTouche) PontGlasmio.surBarreAppel = null;
      _envoyer(forcerCache: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barre = KeyedSubtree(key: _cle, child: widget.repli);
    if (!_natif) return barre;
    _planifier();
    // La barre Flutter garde sa place, mais ne se voit plus et ne se touche
    // plus : c'est la barre Glasmio, posée exactement dessus, qui répond.
    return ExcludeSemantics(child: IgnorePointer(child: Opacity(opacity: 0, child: barre)));
  }
}
