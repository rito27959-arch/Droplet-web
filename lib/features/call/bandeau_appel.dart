// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE BANDEAU D'APPEL EN COURS — la barre qui reste en haut de l'écran
// pendant qu'on fait autre chose, avec la durée qui court, et qui ramène
// à l'appel d'un seul appui.
//
// ── POURQUOI ÇA MANQUAIT CRUELLEMENT ──────────────────────────────────
//
// Sans lui, quitter l'écran d'appel pour aller lire un message, c'était
// perdre l'appel de vue. Rien ne disait qu'il continuait, rien ne disait
// depuis combien de temps, et surtout rien ne permettait d'y revenir : il
// fallait retrouver le contact et deviner. Un appel qu'on ne peut pas
// quitter des yeux est un appel pendant lequel on ne peut rien faire
// d'autre.
//
// ── CE QUI EST REPRIS DE WHATSAPP, ET CE QUI A ÉTÉ AJOUTÉ ─────────────
//
// La barre historique de WhatsApp ne montrait QUE la durée. Sa refonte
// (bêta 2.24.10.18, repérée par Android Police) y a ajouté un bouton
// micro et un bouton raccrocher, pour la raison exacte qu'on rencontre
// ici : sans eux, se couper le micro obligeait à rouvrir tout l'écran
// d'appel. On reprend donc la version refondue, pas l'ancienne.
//
// ── ⚠️ UNE DATE, PAS UN COMPTEUR ──────────────────────────────────────
//
// La durée se calcule en soustrayant une date figée au décrochage, jamais
// en incrémentant un compteur. Un compteur dérive : Android gèle les
// minuteurs d'une application en arrière-plan, et on revient d'un appel de
// dix minutes en lisant « 4:12 ». La soustraction, elle, est juste même
// si le téléphone a dormi.
//
// Le minuteur qui bat ici ne sert qu'à REDESSINER, pas à compter — s'il
// saute un battement, l'affichage saute une seconde puis se rattrape, au
// lieu de prendre du retard pour toujours.
//
// ── ⚠️ OÙ IL NE DOIT PAS APPARAÎTRE ───────────────────────────────────
//
// Pas sur l'écran d'appel lui-même : un bandeau « retourner à l'appel »
// posé sur l'appel serait absurde, et il mangerait la barre d'état d'un
// écran déjà dense. Le chemin courant est donc lu sur le routeur.
// ============================================================================

import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Met en forme une durée d'appel comme le fait un téléphone : `4:07`
/// sous l'heure, `1:02:33` au-delà.
///
/// Exposée pour être testable sans widget — c'est la seule partie de ce
/// fichier qui peut être fausse silencieusement.
String formaterDureeAppel(Duration d) {
  // Une durée négative n'a pas de sens, mais elle arrive : l'horloge du
  // téléphone peut reculer (synchronisation réseau) entre le décrochage
  // et l'affichage. Mieux vaut « 0:00 » qu'un « -1:-3 ».
  final s = d.isNegative ? 0 : d.inSeconds;
  final heures = s ~/ 3600;
  final minutes = (s % 3600) ~/ 60;
  final secondes = s % 60;
  final ss = secondes.toString().padLeft(2, '0');
  if (heures > 0) {
    return '$heures:${minutes.toString().padLeft(2, '0')}:$ss';
  }
  return '$minutes:$ss';
}

/// La surcouche qui pose le bandeau au-dessus de tout le reste.
class BandeauAppelOverlay extends ConsumerWidget {
  const BandeauAppelOverlay({
    super.key,
    required this.child,
    required this.routeur,
  });

  final Widget child;

  /// ⚠️ LE ROUTEUR EST PASSÉ, PAS CHERCHÉ DANS LE CONTEXTE. Cette
  /// surcouche vit AU-DESSUS du routeur (dans le `builder` de
  /// `MaterialApp.router`) : `GoRouter.of(context)` y lève une exception.
  /// C'est le même piège que celui déjà documenté sur l'appel entrant.
  final GoRouter routeur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appel = ref.watch(callProvider);

    return Stack(
      children: [
        child,
        // On redessine quand la route change, pour faire disparaître le
        // bandeau dès qu'on entre sur l'écran d'appel.
        ListenableBuilder(
          listenable: routeur.routerDelegate,
          builder: (context, _) {
            final chemin =
                routeur.routerDelegate.currentConfiguration.uri.path;
            if (!_doitApparaitre(appel, chemin)) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Bandeau(appel: appel, routeur: routeur),
            );
          },
        ),
      ],
    );
  }

  static bool _doitApparaitre(CallState appel, String chemin) {
    if (!appel.isCallActive) return false;
    // Avant le décrochage, c'est la fenêtre d'appel entrant qui parle ;
    // deux surcouches empilées diraient la même chose deux fois.
    if (appel.connectionState != CallConnectionState.connected) return false;
    if (appel.peerId == null) return false;
    return !chemin.startsWith('/call');
  }
}

class _Bandeau extends ConsumerStatefulWidget {
  const _Bandeau({required this.appel, required this.routeur});

  final CallState appel;
  final GoRouter routeur;

  @override
  ConsumerState<_Bandeau> createState() => _BandeauState();
}

class _BandeauState extends ConsumerState<_Bandeau> {
  Timer? _battement;

  @override
  void initState() {
    super.initState();
    // Une seconde : c'est la granularité affichée. Battre plus vite
    // redessinerait pour rien ; plus lentement ferait sauter des secondes.
    _battement = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _battement?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appel = widget.appel;
    final duree = appel.dureeAppel;
    final pseudo = appel.peerPseudo ?? appel.peerId ?? '';

    // Vert : la couleur universelle d'une ligne ouverte, et la seule que
    // tout le monde lit sans légende. C'est aussi celle de la présence
    // dans Droplet, donc rien de nouveau à apprendre.
    // ⚠️ L'ENCRE SE DÉCIDE AVANT LE FOND, et le fond s'assombrit ensuite
    // jusqu'à ce que le contraste passe. C'est la machinerie déjà en place
    // dans `OuroColors` : sans elle, un accent vert clair porterait un
    // texte blanc illisible, exactement le défaut relevé par l'audit.
    final fond = OuroColors.presenceMaintenant;
    final encre = OuroColors.texteSurRemplissage(fond);
    final fondLisible = OuroColors.surRemplissage(fond, encre: encre);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          button: true,
          liveRegion: true,
          // La durée est ajoutée à la phrase traduite plutôt que d'être un
          // second paramètre : elle se lit de la même façon dans toutes
          // les langues, et une clé à deux paramètres se traduit mal.
          label: duree == null
              ? l10n.baOngoing(pseudo)
              : '${l10n.baOngoing(pseudo)} ${formaterDureeAppel(duree)}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _retourner,
            child: Container(
              height: 40,
              color: fondLisible,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space2,
              ),
              child: Row(
                children: [
                  _BoutonBandeau(
                    icone: appel.isMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    libelle: appel.isMuted ? l10n.baUnmute : l10n.baMute,
                    encre: encre,
                    onTap: () {
                      OuroHaptics.light();
                      ref.read(callProvider.notifier).toggleMute();
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          // ⚠️ LE NOM PASSE APRÈS LA DURÉE EN IMPORTANCE,
                          // mais il doit être là : on peut avoir raccroché
                          // avec quelqu'un et rappelé quelqu'un d'autre
                          // sans regarder, et revenir au mauvais appel.
                          pseudo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: OuroTypography.caption2.copyWith(
                            color: encre.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          duree == null
                              ? l10n.baConnecting
                              : formaterDureeAppel(duree),
                          textAlign: TextAlign.center,
                          style: OuroTypography.footnote.copyWith(
                            color: encre,
                            fontWeight: FontWeight.w700,
                            // Les chiffres de largeur fixe : sans eux, la
                            // durée tressaute à chaque seconde parce que
                            // le « 1 » est plus étroit que le « 8 ».
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BoutonBandeau(
                    icone: Icons.call_end_rounded,
                    libelle: l10n.baHangUp,
                    encre: encre,
                    fond: OuroColors.systemRed,
                    onTap: () {
                      OuroHaptics.medium();
                      ref.read(callProvider.notifier).hangUp();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _retourner() {
    final id = widget.appel.peerId;
    if (id == null) return;
    OuroHaptics.light();
    // Même raison que pour l'appel entrant : le contexte de cette
    // surcouche ne voit pas le routeur, on passe donc par l'instance.
    widget.routeur.go('/call/$id');
  }
}

class _BoutonBandeau extends StatelessWidget {
  const _BoutonBandeau({
    required this.icone,
    required this.libelle,
    required this.encre,
    required this.onTap,
    this.fond,
  });

  final IconData icone;
  final String libelle;
  final Color encre;
  final Color? fond;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: libelle,
      child: Tooltip(
        message: libelle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // ⚠️ ON ARRÊTE L'APPUI ICI. Sans ce geste propre, un appui sur
          // le bouton remonterait au bandeau et ouvrirait l'écran d'appel
          // EN PLUS de couper le micro.
          onTap: onTap,
          child: SizedBox(
            // 44 : la cible tactile minimale d'iOS. Le bandeau fait 40 de
            // haut, donc le bouton déborde légèrement de sa boîte
            // visuelle — c'est voulu, la zone touchable compte plus que
            // le dessin.
            width: 44,
            height: 40,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fond ?? encre.withValues(alpha: 0.18),
                ),
                child: Icon(
                  icone,
                  size: DesignTokens.iconSm,
                  color: fond == null ? encre : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
