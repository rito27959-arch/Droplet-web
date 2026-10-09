// ============================================================================
// PLIC — la goutte messagère qui salue le message envoyé.
// ----------------------------------------------------------------------------
// L'animation est un fichier Lottie vectoriel (`assets/lottie/droplet_send.json`,
// 256 × 256, 60 fps, 1,5 s). Elle est posée dans l'`Overlay` racine, au-dessus
// de tout, et se retire toute seule à la fin.
//
// ── Où elle se place ────────────────────────────────────────────────────
//
// Le point de DÉPÔT du fichier (là où la mascotte pose le message, à
// (198,7 ; 96,7) dans la composition) tombe sur le COIN BAS-GAUCHE de la
// nouvelle bulle. Plic surgit donc du champ de saisie, se téléporte et
// atterrit dans l'espace libre à GAUCHE de la bulle : jamais sur le texte.
//
// ── Ce qu'elle ne fait pas ──────────────────────────────────────────────
//
// • Elle ne porte pas de message : la vraie bulle vole déjà du champ à sa
//   place (voir `transition_envoi.dart`, la transition de Telegram). Le
//   calque `MESSAGE` du fichier est donc masqué — sinon on verrait deux fois
//   le même message.
// • Elle ne joue pas deux fois de suite : si une mascotte est en vol, ou si
//   la précédente date de moins de quatre secondes, on s'abstient. C'est ce
//   qui l'empêche de lasser au centième message.
// • Elle ne retarde rien : l'envoi est déjà parti, la bulle est déjà posée.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/providers/animation_envoi_provider.dart';

class MascotteEnvoi {
  MascotteEnvoi._();

  static const String fichierComplet = 'assets/lottie/droplet_send.json';
  static const String fichierReduit = 'assets/lottie/droplet_send_reduced.json';

  /// Le côté du carré, en points. 96 : Plic mesure alors ~45 pt de haut.
  static const double taille = 96;

  /// Le centre du message déposé, en unités de la composition (256 × 256).
  static const Offset _depot = Offset(198.7, 96.7);

  /// Le temps minimum entre deux passages.
  static const Duration _repos = Duration(seconds: 4);

  static OverlayEntry? _entree;
  static DateTime _dernier = DateTime.fromMillisecondsSinceEpoch(0);

  /// Les fichiers sont-ils bien dans le bundle ? `null` : on ne sait pas encore.
  static bool? _fichiersOk;

  /// Charge les deux fichiers une bonne fois (cache partagé du package) :
  /// le premier envoi ne doit pas attendre la lecture d'un JSON.
  static void prechauffer() {
    for (final fichier in const [fichierComplet, fichierReduit]) {
      unawaited(AssetLottie(fichier).load().then<void>(
        (_) => _fichiersOk ??= true,
        onError: (Object e) {
          _fichiersOk = false;
          debugPrint('[Mascotte] ⚠️ $fichier introuvable ($e).\n'
              '            Copiez le dossier assets/ à la racine du projet, '
              'ajoutez « - assets/lottie/ » sous flutter: assets: dans '
              'pubspec.yaml, puis relancez flutter pub get.');
        },
      ));
    }
  }

  /// Le coin haut-gauche de la surcouche pour une bulle donnée.
  static Offset origine(Offset coinBasGauche) {
    final o = coinBasGauche + const Offset(6, -6) - _depot * (taille / 256);
    return Offset(o.dx < 0 ? 0 : o.dx, o.dy);
  }

  /// Joue la mascotte à côté de [bulle] (en coordonnées d'écran).
  ///
  /// À appeler APRÈS l'envoi, une fois la bulle posée — jamais pendant la
  /// construction d'une image : l'insertion dans l'`Overlay` reconstruit.
  static void jouer({
    required BuildContext context,
    required Rect bulle,
    required ModeAnimationEnvoi mode,
  }) {
    if (mode == ModeAnimationEnvoi.desactivee) {
      debugPrint('[Mascotte] réglage « désactivée »');
      return;
    }
    if (_fichiersOk == false) {
      debugPrint('[Mascotte] fichiers Lottie absents du bundle — voir le '
          'message de prechauffer()');
      return;
    }
    if (_entree != null) {
      debugPrint('[Mascotte] déjà en vol');
      return;
    }
    final maintenant = DateTime.now();
    if (maintenant.difference(_dernier) < _repos) {
      debugPrint('[Mascotte] rafale : au repos jusqu\'à quatre secondes');
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final boite = overlay?.context.findRenderObject();
    if (overlay == null || boite is! RenderBox || !boite.hasSize) {
      debugPrint('[Mascotte] pas d\'Overlay racine utilisable');
      return;
    }

    // Le réglage du téléphone l'emporte sur celui de l'app.
    final reduit = mode == ModeAnimationEnvoi.reduite ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    final position = origine(boite.globalToLocal(bulle.bottomLeft));
    _dernier = maintenant;
    debugPrint('[Mascotte] lecture ${reduit ? "réduite" : "complète"} '
        'à ${position.dx.round()}, ${position.dy.round()}');

    late final OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx,
        top: position.dy,
        width: taille,
        height: taille,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: _Lecture(
              fichier: reduit ? fichierReduit : fichierComplet,
              surFin: () {
                entree.remove();
                if (identical(_entree, entree)) _entree = null;
              },
            ),
          ),
        ),
      ),
    );
    _entree = entree;
    overlay.insert(entree);
  }

  /// Retire la mascotte immédiatement (fermeture de l'écran, par exemple).
  static void arreter() {
    _entree?.remove();
    _entree = null;
  }
}

class _Lecture extends StatefulWidget {
  const _Lecture({required this.fichier, required this.surFin});

  final String fichier;
  final VoidCallback surFin;

  @override
  State<_Lecture> createState() => _LectureState();
}

class _LectureState extends State<_Lecture> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this);
  bool _fini = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener((statut) {
      if (statut == AnimationStatus.completed) _terminer();
    });
    // Filet de sécurité : si le fichier ne se charge pas, la surcouche ne
    // doit pas rester accrochée à l'écran.
    Future<void>.delayed(const Duration(seconds: 4), _terminer);
  }

  void _terminer() {
    if (_fini) return;
    _fini = true;
    widget.surFin();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.fichier,
      controller: _ctrl,
      width: MascotteEnvoi.taille,
      height: MascotteEnvoi.taille,
      fit: BoxFit.contain,
      frameRate: FrameRate.composition,
      // Pas de `renderCache` : l'animation est légère, et le cache raster
      // coûterait une trentaine de mégaoctets pour une seconde et demie.
      delegates: LottieDelegates(
        values: [
          // La vraie bulle a déjà volé : le message du fichier ferait double.
          ValueDelegate.transformOpacity(const ['MESSAGE'], value: 0),
        ],
      ),
      onLoaded: (composition) {
        _ctrl.duration = composition.duration;
        _ctrl.forward(from: 0);
      },
    );
  }
}
