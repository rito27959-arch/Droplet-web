// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE BANDEAU DE LECTURE — la barre qui apparaît en haut de l'app quand un
// message vocal continue de jouer alors qu'on a quitté sa conversation.
//
// C'est le lecteur de Telegram et de WhatsApp : on lance le vocal d'un
// ami, on revient à la liste pour répondre à quelqu'un d'autre, et la voix
// continue ; la barre dit QUI parle, où on en est, et permet de mettre en
// pause, d'accélérer, de fermer, ou d'y revenir d'un appui.
//
// ── Les choix ─────────────────────────────────────────────────────────
//
// • LE BANDEAU POUSSE L'ÉCRAN, il ne le recouvre pas. Posé par-dessus, il
//   cacherait le titre et le bouton retour de l'écran du dessous — c'est
//   justement là qu'on a le pouce et l'œil. Il prend donc la place de la
//   barre d'état et décale tout le reste d'autant, en douceur.
// • IL DISPARAÎT DANS LA CONVERSATION D'ORIGINE : là, la bulle elle-même
//   montre la lecture ; deux lecteurs à l'écran diraient la même chose.
// • L'AVANCEMENT EST UN FIL BLEU au bas du bandeau, comme une jauge qui se
//   remplit ; à gauche, trois barres dansent tant que la voix joue.
// • TOUT SE LIT : bouton, nom, temps restant, vitesse — même en
//   accessibilité, chaque bouton a son libellé.
// ============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/lecteur_vocal.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/flou.dart';

/// La hauteur du bandeau, SOUS la barre d'état.
const double kHauteurBandeauLecture = 50;

class BandeauLecture extends StatelessWidget {
  const BandeauLecture({super.key, required this.routeur, required this.child});

  /// ⚠️ PASSÉ, PAS CHERCHÉ : ce bandeau vit au-dessus du routeur (voir
  /// `BandeauAppelOverlay`).
  final GoRouter routeur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lecteur = LecteurVocal.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([lecteur, routeur.routerDelegate]),
      builder: (context, _) {
        final piste = lecteur.piste;
        String chemin;
        try {
          chemin = routeur.routerDelegate.currentConfiguration.uri.path;
        } catch (_) {
          chemin = '';
        }
        final visible = piste != null && chemin != piste.route && !chemin.startsWith('/call') && chemin != '/' && chemin != '/onboarding';
        final media = MediaQuery.of(context);
        return Column(
          children: [
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: visible
                    ? _Barre(lecteur: lecteur, piste: piste, hautSysteme: media.padding.top, routeur: routeur)
                    : const SizedBox(width: double.infinity),
              ),
            ),
            Expanded(
              child: visible
                  // L'écran du dessous ne doit plus réserver la place de
                  // la barre d'état : le bandeau la porte déjà.
                  ? MediaQuery(
                      data: media.copyWith(
                        padding: media.padding.copyWith(top: 0),
                        viewPadding: media.viewPadding.copyWith(top: 0),
                      ),
                      child: child,
                    )
                  : child,
            ),
          ],
        );
      },
    );
  }
}

class _Barre extends StatelessWidget {
  const _Barre({required this.lecteur, required this.piste, required this.hautSysteme, required this.routeur});

  final LecteurVocal lecteur;
  final PisteVocale piste;
  final double hautSysteme;
  final GoRouter routeur;

  String _temps(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reste = (lecteur.duree ?? Duration.zero) - lecteur.position;
    final vitesse = lecteur.vitesse == 1.0 ? '1×' : (lecteur.vitesse == 1.5 ? '1,5×' : '2×');
    return Material(
      type: MaterialType.transparency,
      child: ClipRect(
        child: Flou(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.only(top: hautSysteme),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemBackground.withValues(alpha: 0.86),
              border: Border(bottom: BorderSide(color: OuroColors.separator, width: 0.5)),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: kHauteurBandeauLecture,
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      _BoutonRond(
                        libelle: lecteur.enLecture ? l10n.blPause : l10n.blPlay,
                        onTap: () {
                          OuroHaptics.light();
                          lecteur.basculer();
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (e, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: e)),
                          child: Icon(
                            lecteur.enLecture ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                            key: ValueKey(lecteur.enLecture),
                            size: 20,
                            color: OuroColors.accent,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: '${piste.titre}, ${piste.sousTitre}',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              OuroHaptics.light();
                              routeur.push(piste.route);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _Egaliseur(actif: lecteur.enLecture, couleur: OuroColors.accent),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          piste.titre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: OuroColors.label, letterSpacing: -0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    lecteur.duree == null ? piste.sousTitre : '${piste.sousTitre} · −${_temps(reste.isNegative ? Duration.zero : reste)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: OuroColors.secondaryLabel,
                                      fontFeatures: const [ui.FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l10n.blSpeed(vitesse),
                        child: GestureDetector(
                          onTap: lecteur.vitesseSuivante,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lecteur.vitesse == 1.0 ? OuroColors.tertiarySystemFill : OuroColors.accent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              vitesse,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: lecteur.vitesse == 1.0 ? OuroColors.label : OuroColors.texteSurAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _BoutonRond(
                        libelle: l10n.blClose,
                        onTap: () {
                          OuroHaptics.light();
                          lecteur.arreter();
                        },
                        child: Icon(CupertinoIcons.xmark, size: 17, color: OuroColors.secondaryLabel),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                // Le fil d'avancement, collé au bas.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LayoutBuilder(
                    builder: (context, c) => Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 2,
                        width: c.maxWidth * lecteur.progression,
                        decoration: BoxDecoration(
                          color: OuroColors.accent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(1)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.libelle, required this.onTap, required this.child});
  final String libelle;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: libelle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

/// Trois petites barres qui dansent tant que la voix joue, et se posent
/// à mi-hauteur en pause.
class _Egaliseur extends StatefulWidget {
  const _Egaliseur({required this.actif, required this.couleur});
  final bool actif;
  final Color couleur;

  @override
  State<_Egaliseur> createState() => _EgaliseurState();
}

class _EgaliseurState extends State<_Egaliseur> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _regler();
  }

  @override
  void didUpdateWidget(covariant _Egaliseur old) {
    super.didUpdateWidget(old);
    _regler();
  }

  void _regler() {
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.actif && !reduit) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => SizedBox(
        width: 13,
        height: 12,
        child: CustomPaint(painter: _PeintreEgaliseur(_c.value, widget.actif, widget.couleur)),
      ),
    );
  }
}

class _PeintreEgaliseur extends CustomPainter {
  _PeintreEgaliseur(this.t, this.actif, this.couleur);
  final double t;
  final bool actif;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = couleur
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 3; k++) {
      final phase = (t + k * 0.29) * 2 * math.pi;
      final h = actif ? 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase * (k == 1 ? 1.0 : 2.0))) : 0.4;
      final x = 1.5 + k * 5.0;
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - (size.height - 1.5) * h), p);
    }
  }

  @override
  bool shouldRepaint(_PeintreEgaliseur o) => o.t != t || o.actif != actif;
}
