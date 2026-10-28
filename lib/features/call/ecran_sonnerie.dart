// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ÉCRAN D'UN APPEL QUI SONNE — le seul. Qu'on l'ouvre depuis la
// notification ou que l'appel arrive application ouverte, c'est le même.
//
// Avant, il y en avait deux, et ils ne se ressemblaient pas : l'un affichait
// le logo Droplet ET l'avatar de l'appelant, deux grands ronds l'un sur
// l'autre ; l'autre n'avait qu'un bouton pour raccrocher, et le premier
// surgissait par-dessus quelques secondes plus tard.
//
// Le modèle est l'écran d'appel d'iOS :
//
//   • LE NOM EN HAUT, en grand : c'est la seule question qu'on se pose
//     quand ça sonne — « qui ? ». Dessous, en petit, ce que c'est (appel
//     vocal ou vidéo, par Internet ou de proche en proche) avec la marque
//     de Droplet, comme iOS écrit « Audio WhatsApp ».
//   • LE VISAGE AU CENTRE, entouré des ronds dans l'eau de Droplet — l'onde
//     de l'ouverture, qui dit ici « ça sonne ».
//   • DEUX BOUTONS EN BAS, toujours aux mêmes places : rouge à gauche pour
//     refuser, vert à droite pour répondre, nommés en dessous.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/avatar_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/marque_droplet.dart';
import '../../shared/widgets/peer_avatar.dart';

class EcranSonnerie extends StatelessWidget {
  const EcranSonnerie({
    super.key,
    required this.peerId,
    required this.pseudo,
    required this.video,
    required this.viaInternet,
    required this.onRepondre,
    required this.onRefuser,
  });

  final String peerId;
  final String pseudo;
  final bool video;
  final bool viaInternet;
  final VoidCallback onRepondre;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quoi = video ? l10n.clIncomingVideoCall : l10n.ntfIncomingCall;
    final par = viaInternet ? l10n.clViaInternet : l10n.mnMeshVoiceCall;
    final hauteur = MediaQuery.sizeOf(context).height;
    final rayon = (hauteur * 0.075).clamp(48.0, 66.0);

    return Material(
      color: OuroColors.callBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.1,
                colors: [OuroColors.callGlow, OuroColors.callBackground],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: hauteur * 0.07),
                Semantics(
                  header: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      pseudo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter Tight',
                        fontSize: 36,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: OuroColors.callLabel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MarqueDroplet(hauteur: 16, couleur: OuroColors.callSecondaryLabel),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        '$quoi · $par',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, color: OuroColors.callSecondaryLabel),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: rayon * 4.4,
                  height: rayon * 4.4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(child: _Ondes(rayon: rayon)),
                      PeerAvatar(pseudo: pseudo, radius: rayon, imagePath: AvatarService.cheminPair(peerId)),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(44, 0, 44, hauteur * 0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Bouton(
                        couleur: const Color(0xFFFF3B30),
                        icone: Icons.call_end_rounded,
                        libelle: l10n.ntfDecline,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          onRefuser();
                        },
                      ),
                      _Bouton(
                        couleur: const Color(0xFF34C759),
                        icone: video ? Icons.videocam_rounded : Icons.call_rounded,
                        libelle: l10n.ntfAnswer,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onRepondre();
                        },
                      ),
                    ],
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

class _Bouton extends StatefulWidget {
  const _Bouton({required this.couleur, required this.icone, required this.libelle, required this.onTap});

  final Color couleur;
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  State<_Bouton> createState() => _BoutonState();
}

class _BoutonState extends State<_Bouton> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.libelle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _appui = true),
        onTapCancel: () => setState(() => _appui = false),
        onTapUp: (_) => setState(() => _appui = false),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _appui ? 0.92 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.couleur),
                child: Icon(widget.icone, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 10),
            ExcludeSemantics(
              child: Text(
                widget.libelle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: OuroColors.callLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Les ronds dans l'eau autour du visage : trois, décalés, qui partent du
/// bord de l'avatar et s'effacent en s'élargissant. Immobiles si
/// « Réduire les animations » est activé.
class _Ondes extends StatefulWidget {
  const _Ondes({required this.rayon});
  final double rayon;

  @override
  State<_Ondes> createState() => _OndesState();
}

class _OndesState extends State<_Ondes> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _PeintreOndes(_c.value, widget.rayon)),
      ),
    );
  }
}

class _PeintreOndes extends CustomPainter {
  _PeintreOndes(this.t, this.r);
  final double t;
  final double r;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final loin = math.min(size.width, size.height) / 2;
    for (var k = 0; k < 3; k++) {
      final p = (t + k / 3) % 1.0;
      final rayon = r + 4 + (loin - r - 4) * Curves.easeOutCubic.transform(p);
      final alpha = 0.45 * math.pow(1 - p, 1.5).toDouble();
      canvas.drawCircle(
        c,
        rayon,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFF0A84FF).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreOndes o) => o.t != t;
}
