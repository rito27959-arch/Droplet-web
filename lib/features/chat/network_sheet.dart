// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE PANNEAU « RÉSEAU DROPLET », ouvert depuis l'en-tête d'une
// conversation.
//
// ── Pourquoi il n'est PAS affiché en permanence ───────────────────────
//
// La tentation, sur une application dont le réseau maillé est l'argument
// principal, est de le montrer tout le temps : un bandeau de statistiques
// en haut du fil, des compteurs qui bougent. C'est exactement ce qu'il ne
// faut pas faire.
//
// Quelqu'un qui écrit à un ami ne veut pas savoir combien de relais sont
// disponibles — il veut envoyer son message. Poser cette information en
// permanence sous ses yeux la transforme en bruit, et fait ressembler
// l'application à un outil de diagnostic plutôt qu'à une messagerie.
//
// Elle est donc rangée UN GESTE PLUS LOIN : celui qui est curieux la
// trouve, celui qui discute ne la voit jamais. C'est le principe que le
// cahier des charges résume par « l'utilisateur normal doit pouvoir
// discuter sans comprendre la technologie ».
//
// ── ⚠️ TOUT VIENT DE COMPTEURS RÉELS ──────────────────────────────────
//
// Chaque chiffre affiché est lu dans l'état vivant du transport
// (`meshPeerListProvider`, `MeshStats`) — rien n'est estimé, rien n'est
// arrondi pour faire joli. Sur une application qui demande qu'on lui
// fasse confiance pour acheminer des messages sans serveur, un compteur
// décoratif serait pire qu'un compteur absent.
//
// Une conséquence assumée : quand il n'y a personne, le panneau le dit
// franchement au lieu d'afficher un zéro qui ressemble à une panne.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/services/mesh_transport_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/liquid_bridge.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Ouvre le panneau réseau.
///
/// [torContact] : cette conversation précise ne se joint QUE par Tor —
/// voir `isTorOnlyPeer`. Le panneau bascule alors sur un contenu entièrement
/// différent (voir [_TorNetworkSheet]) : les compteurs Bluetooth/Wi-Fi du
/// panneau habituel n'ont aucun rapport avec la façon dont on joint CE
/// contact-là, et les montrer quand même reviendrait à répondre à côté de
/// la question posée en touchant la ligne de statut.
Future<void> showNetworkSheet(
  BuildContext context, {
  bool torContact = false,
  bool torConnected = false,
  String? peerPseudo,
}) {
  OuroHaptics.selection();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => torContact
        ? _TorNetworkSheet(torConnected: torConnected, peerPseudo: peerPseudo)
        : const _NetworkSheet(),
  );
}

/// Le panneau réseau pour un contact QUE l'on joint par Tor.
///
/// ⚠️ POURQUOI IL NE PARTAGE RIEN AVEC `_NetworkSheet` CI-DESSOUS.
//
// `_NetworkSheet` répond à « combien d'appareils sont à portée, par quel
// transport ? » — une question de VOISINAGE PHYSIQUE. Pour un contact Tor,
// cette question n'a pas de sens : on ne sera jamais "à portée" de lui,
// et le mesh local peut être plein de monde sans que ça change quoi que ce
// soit à cette conversation précise. On dit donc ici la vérité qui
// s'applique réellement : le chemin est une boîte aux lettres chiffrée sur
// Tor, pas un voisinage d'appareils.
class _TorNetworkSheet extends StatelessWidget {
  const _TorNetworkSheet({required this.torConnected, this.peerPseudo});

  final bool torConnected;
  final String? peerPseudo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pseudo = peerPseudo ?? '';

    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LiquidGlassDot(
                  size: 9,
                  color: torConnected
                      ? OuroColors.systemGreen
                      : OuroColors.systemGray,
                ),
                const SizedBox(width: DesignTokens.space2),
                Text(
                  torConnected
                      ? l10n.nsTorConnectedTitle
                      : l10n.nsTorInactiveTitle,
                  style: OuroTypography.title3
                      .copyWith(color: OuroColors.label),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space2),
            Text(
              torConnected
                  ? l10n.nsTorConnectedExplain(pseudo)
                  : l10n.nsTorInactiveExplain(pseudo),
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: DesignTokens.space5),

            _InfoRow(
              icone: Icons.markunread_mailbox_rounded,
              couleur: OuroColors.systemPurple,
              titre: l10n.nsTorMailboxTitle,
              detail: l10n.nsTorMailboxDetail(pseudo),
            ),
            _InfoRow(
              icone: Icons.lock_rounded,
              couleur: OuroColors.systemGreen,
              titre: l10n.clEndToEndEncrypted,
            ),

            if (!torConnected) ...[
              const SizedBox(height: DesignTokens.space2),
              SizedBox(
                width: double.infinity,
                child: OuroRetourIos(child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/tor');
                  },
                  icon: const Icon(Icons.shield_rounded, size: 18),
                  label: Text(l10n.nsOpenTorSettings),
                  style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
                    backgroundColor: OuroColors.accentRempli,
                    foregroundColor: OuroColors.texteSurAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLg),
                    ),
                  ),
                )),
              ),
            ],
            const SizedBox(height: DesignTokens.space2),
          ],
        ),
      ),
    );
  }
}

/// Une ligne d'information qualitative (icône + titre + détail), sans
/// compteur — contrairement à `_Compteur`, qui exige toujours un chiffre.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icone,
    required this.couleur,
    required this.titre,
    this.detail,
  });

  final IconData icone;
  final Color couleur;
  final String titre;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$titre${detail != null ? '. $detail' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 19, color: couleur),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: OuroTypography.body
                        .copyWith(color: OuroColors.label),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkSheet extends ConsumerWidget {
  const _NetworkSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairs = ref.watch(meshPeerListProvider);

    // Un pair « joignable » est un pair qui a au moins un chemin ouvert.
    // Ceux en cours de reconnexion sont comptés à part : les mélanger
    // ferait annoncer des interlocuteurs à qui rien ne part.
    final joignables = pairs.where((p) => !p.reconnecting).toList();
    final enReconnexion = pairs.length - joignables.length;

    // Un relais, c'est un pair joignable DIRECTEMENT (sans intermédiaire)
    // : lui seul peut faire suivre nos messages vers plus loin.
    final relais = joignables.where((p) => p.hopCount == 0).length;

    final ble = joignables
        .where((p) => p.transports.contains(TransportKind.ble))
        .length;
    final wifi = joignables
        .where((p) =>
            p.transports.contains(TransportKind.localWifi) ||
            p.transports.contains(TransportKind.nativeP2P))
        .length;

    final actif = joignables.isNotEmpty;

    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LiquidGlassDot(
                  size: 9,
                  color: actif ? OuroColors.systemGreen : OuroColors.systemGray,
                ),
                const SizedBox(width: DesignTokens.space2),
                Text(
                  actif ? l10n.nsMeshActive : l10n.nsNoDeviceInRange,
                  style:
                      OuroTypography.title3.copyWith(color: OuroColors.label),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space2),
            Text(
              actif
                  // La phrase qui retourne la perception : ici, l'absence
                  // d'Internet n'est pas une panne, c'est le mode normal.
                  ? l10n.nsMessagesCirculate
                  : l10n.nsGetCloser,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: DesignTokens.space5),

            _Compteur(
              icone: Icons.people_alt_rounded,
              couleur: OuroColors.accent,
              titre: l10n.nsDevicesInRange,
              valeur: '${joignables.length}',
            ),
            if (enReconnexion > 0)
              _Compteur(
                icone: Icons.sync_rounded,
                couleur: OuroColors.systemOrange,
                titre: l10n.nsReconnectingTitle,
                valeur: '$enReconnexion',
                detail: l10n.nsLinkMomentarilyLost,
              ),
            _Compteur(
              icone: Icons.alt_route_rounded,
              couleur: OuroColors.systemPurple,
              titre: l10n.nsRelaysAvailable,
              valeur: '$relais',
              detail: relais == 0
                  ? l10n.nsNoRelayAvailable
                  : null,
            ),
            _Compteur(
              icone: Icons.bluetooth_rounded,
              couleur: OuroColors.systemTeal,
              titre: l10n.nsViaBluetooth,
              valeur: '$ble',
            ),
            _Compteur(
              icone: Icons.wifi_rounded,
              couleur: OuroColors.systemGreen,
              titre: l10n.nsViaLocalWifi,
              valeur: '$wifi',
              detail: l10n.nsWifiCarriesMore,
            ),
            const SizedBox(height: DesignTokens.space2),
          ],
        ),
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.valeur,
    this.detail,
  });

  final IconData icone;
  final Color couleur;
  final String titre;
  final String valeur;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$titre : $valeur${detail != null ? '. $detail' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 19, color: couleur),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: OuroTypography.body
                        .copyWith(color: OuroColors.label),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space2),
            Text(
              valeur,
              style: OuroTypography.title3.copyWith(color: OuroColors.label),
            ),
          ],
        ),
      ),
    );
  }
}
