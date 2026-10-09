// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'overlay Nexus — l'expérience visuelle complète qui recouvre tout
// l'écran pendant la connexion entre deux appareils.
//
// Composition en couches (de l'arrière vers l'avant) :
//
//   ┌─ 1. Fond noir avec assombrissement progressif ──────────────────────┐
//   │                                                                    │
//   │  ┌─ 2. Anneaux + points convergents (`NexusPulsePainter`) ───────┐ │
//   │  │                                                               │ │
//   │  │  ┌─ 3. Texte (Phase 5 : identité) ───────────────────────┐   │ │
//   │  │  │                                                        │   │ │
//   │  │  └────────────────────────────────────────────────────────┘   │ │
//   │  └───────────────────────────────────────────────────────────────┘ │
//   └────────────────────────────────────────────────────────────────────┘
//
// ⚠️ PLUS DE SHADER GLSL NI DE SYSTÈME DE PARTICULES ICI — voir l'en-tête
// de `nexus_pulse.dart` pour pourquoi ils ont été retirés (ils faisaient
// planter l'app sur certains appareils) et ce qui les remplace.
//
// L'overlay est une couche de `Stack` posée dans le `builder` de
// `MaterialApp` (voir `NexusHost`), pas un `OverlayEntry`. Il se
// construit automatiquement, joue l'animation, puis se détruit.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_typography.dart';
import 'nexus_controller.dart';
import 'nexus_event.dart';
import 'nexus_pulse.dart';

/// Ce qu'il faut savoir pour jouer une séquence Nexus.
@immutable
class NexusRequest {
  const NexusRequest({
    required this.seed,
    required this.colorSignature,
    this.peerName = '',
  });

  final String seed;
  final int colorSignature;
  final String peerName;
}

/// La scène Nexus : on y dépose une demande, [NexusHost] la joue.
///
/// ── POURQUOI PAS UN `OverlayEntry` ────────────────────────────────────
///
/// C'était la première des deux causes de la panne. L'ancienne version
/// faisait `Overlay.of(context).insert(entry)` depuis `NotificationBridge`
/// — un widget placé dans le `builder` de `MaterialApp.router`, donc
/// AU-DESSUS du `Navigator`. Or c'est le `Navigator` qui fournit l'unique
/// `Overlay` de l'application : en remontant l'arbre depuis ce point, il
/// n'y en a aucun. `Overlay.of` lève alors une exception, à l'intérieur
/// d'un écouteur de flux — c'est-à-dire loin de tout écran, sans rien
/// afficher nulle part. L'animation ne se lançait jamais, et le drapeau
/// « Nexus en cours » restait bloqué douze secondes.
///
/// Le reste de l'app (appel entrant, appel de groupe, notifications) ne
/// passe déjà PAS par `Overlay` : ce sont des couches de `Stack` posées
/// dans ce même `builder`. Nexus fait désormais comme eux — c'est plus
/// simple, et cela ne peut plus dépendre d'un ancêtre qui n'existe pas.
class NexusStage {
  NexusStage._();

  static final ValueNotifier<NexusRequest?> _current =
      ValueNotifier<NexusRequest?>(null);

  /// La séquence en cours, ou `null`. Observée par [NexusHost].
  static ValueListenable<NexusRequest?> get current => _current;

  /// Lance une séquence. Sans effet si une autre est déjà à l'écran.
  static void play(NexusRequest request) {
    if (_current.value != null) return;
    _current.value = request;
  }

  /// Retire la séquence de l'écran.
  static void clear() => _current.value = null;
}

/// La couche qui affiche la séquence Nexus par-dessus toute l'app.
///
/// À placer dans le `builder` de `MaterialApp`, comme les autres couches
/// plein écran de Droplet.
class NexusHost extends StatelessWidget {
  const NexusHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NexusRequest?>(
      valueListenable: NexusStage.current,
      // ⚠️ TOUTE L'APPLICATION EST CE `child`. Le passer ici plutôt que de
      // le lire dans le `builder` évite de reconstruire l'arbre entier au
      // début et à la fin de chaque séquence — c'est-à-dire précisément
      // aux deux instants où l'on demande déjà beaucoup au téléphone.
      child: child,
      builder: (context, request, child) {
        return Stack(
          children: [
            child!,
            if (request != null)
              Positioned.fill(
                child: _NexusOverlayWidget(
                  // La clé garantit qu'une NOUVELLE rencontre repart d'un
                  // état neuf plutôt que de reprendre l'animation
                  // précédente au milieu.
                  key: ValueKey(request.seed),
                  seed: request.seed,
                  colorSignature: request.colorSignature,
                  peerName: request.peerName,
                  onComplete: NexusStage.clear,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Widget interne ───────────────────────────────────────────────────────────

class _NexusOverlayWidget extends StatefulWidget {
  const _NexusOverlayWidget({
    super.key,
    required this.seed,
    required this.colorSignature,
    required this.peerName,
    this.onComplete,
  });

  final String seed;
  final int colorSignature;
  final String peerName;
  final VoidCallback? onComplete;

  @override
  State<_NexusOverlayWidget> createState() => _NexusOverlayWidgetState();
}

class _NexusOverlayWidgetState extends State<_NexusOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final NexusController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NexusController(
      seed: widget.seed,
      colorSignature: widget.colorSignature,
      peerName: widget.peerName,
    )..onComplete = _terminer;
    _controller.start(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Déjà terminée ? Évite qu'un tap et la fin naturelle ne se marchent
  /// dessus.
  bool _termine = false;

  /// Écourte la séquence — l'utilisateur a tapé pour la passer.
  ///
  /// ⚠️ `stop()` et NON `dispose()` — c'est `dispose()` du `State` qui
  /// détruit le contrôleur, une seule fois. Voir `NexusController.stop`.
  void _terminer() {
    if (_termine) return;
    _termine = true;
    _controller.stop();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Material(
          type: MaterialType.transparency,
          child: _NexusContent(
            state: state,
            onDismiss: _terminer,
          ),
        );
      },
    );
  }
}

// ── Contenu principal ────────────────────────────────────────────────────────

class _NexusContent extends StatelessWidget {
  const _NexusContent({
    required this.state,
    required this.onDismiss,
  });

  final NexusControllerState state;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Couche 1 : Fond noir avec assombrissement progressif ──────
          _Background(
            phase: state.phase,
            phaseProgress: state.phaseProgress,
          ),

          // ── Couche 2 : Anneaux + points convergents ───────────────────
          //
          // Remplace l'ancien duo shader GLSL + système de particules —
          // voir l'en-tête de `nexus_pulse.dart`. Toujours affichée, sur
          // tous les appareils : plus de branche « appareil modeste »,
          // puisqu'il n'y a plus rien de coûteux à sauter.
          CustomPaint(
            painter: NexusPulsePainter(
              phase: state.phase,
              phaseProgress: state.phaseProgress,
              overallProgress: state.overallProgress,
              colorSignature: state.colorSignature,
              intensity: state.intensity,
              time: state.elapsedSeconds,
              seed: state.seed,
            ),
            size: Size.infinite,
          ),

          // ── Couche 3 : Contenu centré (goutte Phase 5) ──────────────
          if (state.phase == NexusPhase.identity)
            _IdentityContent(
              state: state,
              screenHeight: screenHeight,
            ),

          // ── Fermeture tactile ────────────────────────────────────────
          if (state.phase == NexusPhase.identity ||
              state.phase == NexusPhase.complete)
            Positioned.fill(
              child: GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fond ─────────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({
    required this.phase,
    required this.phaseProgress,
  });

  final NexusPhase phase;
  final double phaseProgress;

  @override
  Widget build(BuildContext context) {
    // ⚠️ 0.85, TOUJOURS — PLUS DE VARIANTE « SANS SHADER ».
    //
    // L'ancien code assombrissait moins (0.55) quand le shader avait
    // renoncé, pour que les particules restent lisibles sur fond moins
    // noir. Sans shader ni particules à préserver, un seul réglage
    // suffit pour tout le monde.
    const maxDarkness = 0.85;
    // Le fond passe de transparent (idle) à noir profond (awakening),
    // puis reste sombre pendant toute la séquence.
    final darkness = switch (phase) {
      NexusPhase.idle => 0.0,
      NexusPhase.awakening => phaseProgress * maxDarkness,
      // La dissolution rend l'app à l'utilisateur progressivement. Sans
      // cette ligne, l'assombrissement restait au maximum jusqu'à la
      // dernière image, puis l'écran réapparaissait d'un coup.
      NexusPhase.complete => maxDarkness * (1.0 - phaseProgress),
      _ => maxDarkness,
    };

    return Container(
      color: Colors.black.withValues(alpha: darkness),
    );
  }
}

// ── Contenu identité (Phase 5) ──────────────────────────────────────────────

class _IdentityContent extends StatelessWidget {
  const _IdentityContent({
    required this.state,
    required this.screenHeight,
  });

  final NexusControllerState state;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    // Le texte apparaît progressivement dans la phase identity.
    final fadeIn = Curves.easeOut.transform(
      state.phaseProgress.clamp(0.0, 1.0),
    );
    final color = Color(state.colorSignature);

    return Positioned(
      top: screenHeight * 0.38,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: fadeIn,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Réseau mesh dans la goutte ──────────────────────────────
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _MeshNetworkPainter(
                  color: color,
                  progress: state.phaseProgress,
                  seed: state.seed,
                ),
              ),
            ),

            SizedBox(height: DesignTokens.space6),

            // ── Texte « projeté dans la lumière » ──────────────────────
            Text(
              'Connexion établie',
              style: OuroTypography.headlineMedium.copyWith(
                color: Colors.white.withValues(alpha: fadeIn * 0.9),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: DesignTokens.space3),

            Text(
              'Réseau privé actif',
              style: OuroTypography.bodyMedium.copyWith(
                color: color.withValues(alpha: fadeIn * 0.7),
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: DesignTokens.space2),

            Text(
              'Chiffrement E2EE',
              style: OuroTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: fadeIn * 0.5),
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter du réseau mesh (Phase 5) ────────────────────────────────────────

class _MeshNetworkPainter extends CustomPainter {
  _MeshNetworkPainter({
    required this.color,
    required this.progress,
    required this.seed,
  });

  final Color color;
  final double progress;
  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rng = _seededRandom(seed);

    // 8 nœuds du réseau mesh, disposés en cercle
    const nodeCount = 8;
    final nodes = List<Offset>.generate(nodeCount, (i) {
      final angle = (i / nodeCount) * math.pi * 2 - math.pi / 2;
      final radius = size.width * 0.35 + rng.nextDouble() * 8;
      return Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    });

    // Dessiner les connexions entre nœuds
    for (var i = 0; i < nodeCount; i++) {
      for (var j = i + 1; j < nodeCount; j++) {
        // Seulement certaines connexions (pas un graphe complet)
        if ((i + j) % 3 == 0) {
          // Animation progressive : la ligne apparaît quand le progress
          // la dépasse.
          final lineProgress = (progress * nodeCount - i * 0.5)
              .clamp(0.0, 1.0);
          if (lineProgress > 0) {
            final path = Path()
              ..moveTo(nodes[i].dx, nodes[i].dy)
              ..lineTo(nodes[j].dx, nodes[j].dy);
            canvas.drawPath(
              path,
              Paint()
                ..color = color.withValues(alpha: lineProgress * 0.25)
                ..strokeWidth = 0.8
                ..style = PaintingStyle.stroke,
            );
          }
        }
      }
    }

    // Dessiner les nœuds
    for (var i = 0; i < nodeCount; i++) {
      final nodeProgress = (progress * nodeCount - i * 0.3)
          .clamp(0.0, 1.0);
      if (nodeProgress <= 0) continue;

      final paint = Paint()
        ..color = color.withValues(alpha: nodeProgress * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(nodes[i], 3.0 * nodeProgress, paint);

      // Halo
      canvas.drawCircle(
        nodes[i],
        8.0 * nodeProgress,
        Paint()
          ..color = color.withValues(alpha: nodeProgress * 0.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  static math.Random _seededRandom(String seed) {
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = ((hash << 5) - hash + seed.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return math.Random(hash);
  }

  @override
  bool shouldRepaint(covariant _MeshNetworkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
