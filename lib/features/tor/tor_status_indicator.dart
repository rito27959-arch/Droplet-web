// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE BANDEAU D'ÉTAT TOR — la fine bande sous la barre de navigation qui
// dit, en un coup d'œil, où en est le circuit Tor.
//
// ⚠️ CE BANDEAU A MENTI. Il affichait « Tor actif » sur la seule foi de
// `TorServiceState.connected`, que `TorService` publiait sans vérifier que
// le circuit était réellement monté. Le correctif est EN AMONT (voir
// l'en-tête de `tor_service.dart` : l'état ne vaut `connected` que si Tor
// est vraiment utilisable). Ce fichier n'a donc plus de condition à
// vérifier lui-même — et il ne doit pas en réintroduire.
//
// ⚠️ LE CLIGNOTEMENT NE CLIGNOTAIT PAS. L'`AnimationController` tournait
// bien, mais rien ne s'y abonnait : `build` n'était jamais rappelé, et
// `_blinkController.value` restait la valeur lue au dernier rebuild. Un
// `AnimatedOpacity` recevant toujours la même cible ne bouge pas. D'où
// l'`AnimatedBuilder` ci-dessous, qui est ce qui relie réellement la
// pulsation à l'écran.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/tor_providers.dart';
import '../../core/services/tor_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';

/// Bandeau d'état Tor. Masqué quand Tor est éteint — on n'occupe pas de
/// place pour dire qu'il ne se passe rien.
class TorStatusIndicator extends ConsumerStatefulWidget {
  const TorStatusIndicator({super.key});

  @override
  ConsumerState<TorStatusIndicator> createState() => _TorStatusIndicatorState();
}

class _TorStatusIndicatorState extends ConsumerState<TorStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pouls;

  @override
  void initState() {
    super.initState();
    _pouls = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..bouclerSiAmbiant(reverse: true);
  }

  @override
  void dispose() {
    _pouls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final etat = ref.watch(torStateProvider).valueOrNull;

    // `null` = pas encore d'état publié. Depuis que `TorService.stateStream`
    // rejoue l'état courant à l'abonnement, ce cas ne dure qu'une frame.
    final masque = etat == null || etat == TorServiceState.stopped;

    // ⚠️ AnimatedSize + une hauteur nulle plutôt qu'un `SizedBox.shrink()`
    // sec : le bandeau glisse à l'apparition et à la disparition au lieu
    // de faire sauter tout le contenu sous lui d'un cran.
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: masque
          ? const SizedBox(width: double.infinity, height: 0)
          : _bandeau(context, l10n, etat),
    );
  }

  Widget _bandeau(
    BuildContext context,
    AppLocalizations l10n,
    TorServiceState etat,
  ) {
    final (couleur, libelle, icone) = switch (etat) {
      TorServiceState.connecting => (
          OuroColors.systemOrange,
          l10n.torBannerConnecting,
          Icons.sync_rounded,
        ),
      TorServiceState.connected => (
          OuroColors.systemGreen,
          l10n.torBannerActive,
          Icons.shield_rounded,
        ),
      TorServiceState.error => (
          OuroColors.systemRed,
          l10n.torBannerError,
          Icons.error_outline_rounded,
        ),
      TorServiceState.stopped => (
          OuroColors.systemGray,
          l10n.torBannerOff,
          Icons.shield_outlined,
        ),
    };

    final enCours = etat == TorServiceState.connecting;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Un bandeau qui signale un problème doit mener à l'endroit qui le
        // résout, pas rester un constat.
        onTap: () => context.push('/tor'),
        child: AnimatedBuilder(
          animation: _pouls,
          builder: (context, enfant) {
            final t = Curves.easeInOut.transform(_pouls.value);
            return Opacity(
              opacity: enCours ? 0.55 + t * 0.45 : 1.0,
              child: enfant,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: couleur.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (enCours)
                  _IconeQuiTourne(icone: icone, couleur: couleur, pouls: _pouls)
                else
                  Icon(icone, size: 13, color: couleur),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    libelle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.caption1.copyWith(
                      color: couleur,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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

/// L'icône de synchronisation tourne pendant la connexion — le signal qui
/// distingue « ça travaille » de « c'est figé ».
class _IconeQuiTourne extends StatelessWidget {
  const _IconeQuiTourne({
    required this.icone,
    required this.couleur,
    required this.pouls,
  });

  final IconData icone;
  final Color couleur;
  final Animation<double> pouls;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pouls,
      builder: (context, enfant) => Transform.rotate(
        angle: pouls.value * 3.14159 * 2,
        child: enfant,
      ),
      child: Icon(icone, size: 13, color: couleur),
    );
  }
}
