// ============================================================================
// L'ÉCRAN D'APPEL — vocal ou vidéo, par le mesh ou par Internet.
// ----------------------------------------------------------------------------
// Refonte. L'ancienne version empilait autour de l'avatar une orbite, des
// ondes, un logo animé et des points qui rebondissent, avec des boutons sans
// légende et une seule ligne grise « Via Internet ». On y lisait mal ce qui
// compte pendant un appel : QUI, DEPUIS COMBIEN DE TEMPS, et EST-CE QUE ÇA
// PASSE BIEN.
//
// Ce qu'on voit maintenant :
//   • au centre, l'avatar entouré d'un anneau qui réagit à la voix, le nom,
//     puis le minuteur (ou « Appel en cours… », « Reconnexion… ») ;
//   • une pastille de CHEMIN : « Mesh · Wi-Fi direct », « Internet · direct »
//     ou « Internet · relais sécurisé », avec des barres de qualité tirées de
//     la latence réellement mesurée ;
//   • en bas, une barre en verre aux boutons LÉGENDÉS (Haut-parleur, Caméra,
//     Micro) et le bouton rouge pour raccrocher ;
//   • en vidéo : l'image de l'autre en plein écran, un appui masque ou montre
//     les contrôles (masqués d'eux-mêmes après 4 s), et sa propre vignette se
//     déplace au doigt puis se cale dans le coin le plus proche.
//
// La voix et la connexion vivent ailleurs (`call_service.dart`,
// `webrtc_call_service.dart`, `mesh_provider.dart`) : ce fichier n'affiche.
// ============================================================================

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/appel_verrouillage.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/device_profile.dart';
import '../../core/services/etat_connexion.dart';
import '../../core/services/mesh_foreground_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../design_system/ouro_spinner.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.peerId,
    this.video = false,
    this.entrant = false,
  });
  final String peerId;

  /// Ouvert depuis une notification d'appel ENTRANT (`?entrant=1`) : on
  /// attend l'offre, on n'appelle surtout pas la personne en retour.
  final bool entrant;

  /// Appel VIDÉO (route `/call/:peerId?video=1`) — sinon vocal.
  final bool video;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen>
    with SingleTickerProviderStateMixin {
  bool _started = false;
  bool _exiting = false;
  Timer? _timer;
  int _elapsed = 0;

  /// En vidéo plein écran : contrôles visibles ou masqués.
  bool _controlesVisibles = true;
  Timer? _masquage;

  /// Respiration douce de l'aura autour de l'avatar.
  late final AnimationController _aura;

  @override
  void initState() {
    super.initState();
    _aura = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..bouclerSiAmbiant(reverse: true);
    // Visible et écran allumé même téléphone verrouillé, le temps de l'appel.
    unawaited(AppelVerrouillage.afficher(true));
    AppelVerrouillage.enVignette.addListener(_surVignette);
    // Après la mise en place de l'écran : la boîte système passe par-dessus.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) unawaited(_proposerExemptionBatterie());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  void _startIfNeeded() {
    if (_started) return;
    _started = true;
    final call = ref.read(callProvider);
    if (call.isCallActive && call.peerId == widget.peerId) {
      // Déjà actif (appel entrant accepté) : on ne relance pas.
      _startTimerIfConnected();
      return;
    }
    if (widget.entrant) {
      // ⚠️ L'ANCIENNE VERSION RAPPELAIT L'APPELANT : toucher la notification
      // d'appel lançait un appel SORTANT vers lui, pendant que son offre
      // attendait — deux appels croisés, aucun n'aboutissait. L'offre arrive
      // par la boîte d'appels ; sans elle dans 25 s, on revient à la
      // conversation.
      Future.delayed(const Duration(seconds: 25), () {
        if (mounted && !_exiting && !ref.read(callProvider).isCallActive) {
          context.go('/chat/${widget.peerId}');
        }
      });
      return;
    }
    final pseudo = ref.read(peerPseudoProvider(widget.peerId));
    ref.read(callProvider.notifier).startCall(widget.peerId, pseudo, video: widget.video);
  }

  void _startTimerIfConnected() {
    final call = ref.read(callProvider);
    if (call.connectionState == CallConnectionState.connected) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed++);
      });
    }
  }

  void _surVignette() {
    if (mounted) setState(() {});
  }

  /// Au premier appel, Android demande (une seule fois) de laisser Droplet
  /// hors des économies de batterie : sans cela, le système peut retarder
  /// la notification d'un appel entrant de plusieurs minutes.
  static const _cleBatterieDemandee = 'batterie_exemption_demandee';

  Future<void> _proposerExemptionBatterie() async {
    if (StorageService.getString(_cleBatterieDemandee) == 'oui') return;
    await StorageService.setString(_cleBatterieDemandee, 'oui');
    try {
      if (await MeshForegroundService.isIgnoringBatteryOptimizations) return;
      await MeshForegroundService.requestIgnoreBatteryOptimization();
    } catch (_) {}
  }

  @override
  void dispose() {
    AppelVerrouillage.enVignette.removeListener(_surVignette);
    unawaited(AppelVerrouillage.autoriserVignette(false));
    unawaited(AppelVerrouillage.afficher(false));
    _timer?.cancel();
    _masquage?.cancel();
    _aura.dispose();
    super.dispose();
  }

  String _formatElapsed(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final mmss = '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    return h > 0 ? '$h:$mmss' : mmss;
  }

  String _statusText(AppLocalizations l10n, CallState call) {
    if (call.decroche && call.connectionState == CallConnectionState.connecting) {
      return l10n.clConnecting;
    }
    if (widget.entrant && !call.isCallActive && !_exiting) return l10n.clIncomingCall;
    if (call.isReconnecting && call.connectionState == CallConnectionState.connected) {
      return l10n.clReconnecting;
    }
    switch (call.connectionState) {
      case CallConnectionState.connecting:
        return call.direction == CallDirection.outgoing
            ? l10n.clOutgoingCall
            : l10n.clIncomingCall;
      case CallConnectionState.connected:
        return _formatElapsed(_elapsed);
      case CallConnectionState.failed:
        return l10n.clCallImpossible;
      case CallConnectionState.disconnected:
        return l10n.clCallEnded;
    }
  }

  Color _statusColor(CallState call) {
    if (call.isReconnecting) return OuroColors.systemOrange;
    switch (call.connectionState) {
      case CallConnectionState.connected:
        return OuroColors.callLabel;
      case CallConnectionState.failed:
        return OuroColors.errorRed;
      case CallConnectionState.connecting:
      case CallConnectionState.disconnected:
        return OuroColors.callSecondaryLabel;
    }
  }

  void _handleHangUp() {
    HapticFeedback.heavyImpact();
    setState(() => _exiting = true);
    ref.read(callProvider.notifier).hangUp();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) context.go('/chat/${widget.peerId}');
    });
  }

  /// L'autre a raccroché (ou l'appel a échoué) : on laisse lire « Appel
  /// terminé » un instant, puis retour à la conversation.
  void _quitterApresFin() {
    if (_exiting) return;
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted || _exiting) return;
      if (ref.read(callProvider).isCallActive) return;
      setState(() => _exiting = true);
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) context.go('/chat/${widget.peerId}');
      });
    });
  }

  /// Montre les contrôles ; en vidéo, les masque de nouveau après 4 s.
  void _afficherControles({required bool video}) {
    _masquage?.cancel();
    if (!_controlesVisibles) setState(() => _controlesVisibles = true);
    if (video) {
      _masquage = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _controlesVisibles = false);
      });
    }
  }

  void _basculerControles() {
    if (_controlesVisibles) {
      _masquage?.cancel();
      setState(() => _controlesVisibles = false);
    } else {
      HapticFeedback.selectionClick();
      _afficherControles(video: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final call = ref.watch(callProvider);
    final pseudo = ref.watch(peerPseudoProvider(widget.peerId));
    final connecting =
        call.connectionState == CallConnectionState.connecting && call.isCallActive;
    final connected = call.connectionState == CallConnectionState.connected;

    if (connected && _timer == null) _startTimerIfConnected();
    if (!connected && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }

    ref.listen<CallState>(callProvider, (avant, apres) {
      if ((avant?.isCallActive ?? false) && !apres.isCallActive) _quitterApresFin();
    });

    final notifier = ref.read(callProvider.notifier);
    final rendDistant = notifier.remoteRenderer;
    final rendLocal = notifier.localRenderer;
    // Vidéo distante réellement reçue : elle occupe tout l'écran.
    final videoPleinEcran = call.isRemoteVideoActive && rendDistant != null;
    // Appel vidéo qui sonne : on se voit en fond ; ensuite, en vignette.
    final apercuLocal =
        call.isVideoEnabled && rendLocal != null && !connected && !videoPleinEcran;
    final vignetteLocale = call.isVideoEnabled && rendLocal != null && (connected || videoPleinEcran);

    // Appel vidéo en cours : quitter l'app le replie en vignette flottante.
    unawaited(AppelVerrouillage.autoriserVignette(
        call.isCallActive && (call.isVideoEnabled || videoPleinEcran)));
    // En vignette, la fenêtre fait la taille d'un timbre : seule la vidéo de
    // l'autre (ou son visage) a sa place.
    if (AppelVerrouillage.enVignette.value) {
      return ColoredBox(
        color: Colors.black,
        child: videoPleinEcran
            ? RTCVideoView(
                rendDistant,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : Center(
                child: PeerAvatar(
                  pseudo: pseudo,
                  radius: 36,
                  imagePath: AvatarService.cheminPair(widget.peerId),
                ),
              ),
      );
    }

    final controlesVisibles = !videoPleinEcran || _controlesVisibles;
    if (!videoPleinEcran && _masquage != null) {
      _masquage!.cancel();
      _masquage = null;
      _controlesVisibles = true;
    }
    if (videoPleinEcran && connected && _controlesVisibles && _masquage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _masquage == null) _afficherControles(video: true);
      });
    }

    final statut = _statusText(l10n, call);
    final couleurStatut = _statusColor(call);
    final echec = call.connectionState == CallConnectionState.failed;
    final reconnexion = call.isReconnecting && connected;

    return Scaffold(
      // Noir fixe, même en mode clair — voir `OuroColors.callBackground`.
      backgroundColor: OuroColors.callBackground,
      body: AnimatedOpacity(
        opacity: _exiting ? 0 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _exiting ? 0.94 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: videoPleinEcran ? _basculerControles : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _FondAppel(),
                if (videoPleinEcran)
                  Positioned.fill(
                    child: RTCVideoView(
                      rendDistant,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  )
                else if (apercuLocal)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.6,
                      child: RTCVideoView(
                        rendLocal,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                if (videoPleinEcran || apercuLocal)
                  // Voile en haut et en bas : texte et boutons lisibles sur
                  // n'importe quelle image. Il s'efface avec les contrôles.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: controlesVisibles ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xA6000000),
                                Color(0x00000000),
                                Color(0x00000000),
                                Color(0xBF000000),
                              ],
                              stops: [0, 0.25, 0.62, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _Apparition(
                        visible: controlesVisibles,
                        depuisLeHaut: true,
                        child: const _PastilleChiffrement(),
                      ),
                      if (videoPleinEcran) ...[
                        const SizedBox(height: 12),
                        _Apparition(
                          visible: controlesVisibles,
                          depuisLeHaut: true,
                          child: Column(
                            children: [
                              Text(
                                pseudo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: OuroColors.callLabel,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _LigneStatut(
                                texte: statut,
                                couleur: couleurStatut,
                                echec: echec,
                                reconnexion: reconnexion,
                                taille: 15,
                              ),
                              const SizedBox(height: 8),
                              _PastilleChemin(call: call),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        const Spacer(flex: 2),
                        _AvatarVocal(
                          peerId: widget.peerId,
                          pseudo: pseudo,
                          aura: _aura,
                          niveauVoix: call.audioLevel,
                          sonne: connecting,
                          connecte: connected && !call.isReconnecting,
                        ),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Semantics(
                            header: true,
                            label: l10n.clCallWith(pseudo),
                            child: ExcludeSemantics(
                              child: Text(
                                pseudo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: OuroColors.callLabel,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _LigneStatut(
                          texte: statut,
                          couleur: couleurStatut,
                          echec: echec,
                          reconnexion: reconnexion,
                          taille: 17,
                        ),
                        const SizedBox(height: 14),
                        _PastilleChemin(call: call),
                        const Spacer(flex: 3),
                      ],
                      _Apparition(
                        visible: controlesVisibles,
                        depuisLeHaut: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: _BarreControles(
                            call: call,
                            onMute: notifier.toggleMute,
                            onSpeaker: notifier.toggleSpeaker,
                            onVideo: notifier.toggleVideo,
                            onFlip: () => unawaited(notifier.switchCamera()),
                            onHangUp: _handleHangUp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (vignetteLocale)
                  _VignetteDeplacable(
                    renderer: rendLocal,
                    label: l10n.clSwitchCamera,
                    basReserve: controlesVisibles ? 150 : 24,
                    onSwitch: () {
                      HapticFeedback.selectionClick();
                      unawaited(notifier.switchCamera());
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Le fond : un halo bleu nuit très sombre, presque noir — assez pour donner
/// de la profondeur, pas assez pour fatiguer pendant un long appel.
class _FondAppel extends StatelessWidget {
  const _FondAppel();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.15,
          colors: [OuroColors.callGlow, OuroColors.callBackground],
        ),
      ),
    );
  }
}

/// Fait apparaître ou disparaître un bloc en glissant (contrôles vidéo).
class _Apparition extends StatelessWidget {
  const _Apparition({
    required this.visible,
    required this.depuisLeHaut,
    required this.child,
  });

  final bool visible;
  final bool depuisLeHaut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : Offset(0, depuisLeHaut ? -0.4 : 0.4),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: child,
        ),
      ),
    );
  }
}

class _PastilleChiffrement extends StatelessWidget {
  const _PastilleChiffrement();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 12, color: Colors.white60),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context).clEncryptedShort,
            style: OuroTypography.caption1.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

/// L'avatar, son aura qui respire, et l'anneau qui suit la voix.
class _AvatarVocal extends StatelessWidget {
  const _AvatarVocal({
    required this.peerId,
    required this.pseudo,
    required this.aura,
    required this.niveauVoix,
    required this.sonne,
    required this.connecte,
  });

  final String peerId;
  final String pseudo;
  final Animation<double> aura;
  final double niveauVoix;
  final bool sonne;
  final bool connecte;

  @override
  Widget build(BuildContext context) {
    final photo = AvatarService.cheminPair(peerId);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: aura,
        builder: (context, enfant) {
          final b = Curves.easeInOut.transform(aura.value);
          final voix = niveauVoix.clamp(0.0, 1.0);
          final teinte = connecte ? OuroColors.successGreen : OuroColors.meshBlueBright;
          final halo = sonne ? 1.0 + 0.12 * b : 1.0 + 0.05 * b + 0.22 * voix;
          return SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: halo,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          teinte.withValues(alpha: sonne ? 0.30 : 0.20 + 0.20 * voix),
                          teinte.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 148 + 16 * voix,
                  height: 148 + 16 * voix,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: teinte.withValues(
                        alpha: sonne ? 0.25 + 0.30 * b : 0.18 + 0.55 * voix,
                      ),
                    ),
                  ),
                ),
                enfant!,
              ],
            ),
          );
        },
        child: Hero(
          tag: 'avatar-$peerId',
          child: PeerAvatar(pseudo: pseudo, radius: 64, imagePath: photo),
        ),
      ),
    );
  }
}

class _LigneStatut extends StatelessWidget {
  const _LigneStatut({
    required this.texte,
    required this.couleur,
    required this.echec,
    required this.reconnexion,
    required this.taille,
  });

  final String texte;
  final Color couleur;
  final bool echec;
  final bool reconnexion;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Semantics(
        key: ValueKey(texte.contains(':') && !echec && !reconnexion ? 'minuteur' : texte),
        liveRegion: !texte.contains(':'),
        label: l10n.clCallStatusSemantics(texte),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (echec) ...[
                Icon(Icons.error_outline_rounded, size: taille, color: couleur),
                const SizedBox(width: 6),
              ],
              if (reconnexion) ...[
                SizedBox(
                  width: taille * 0.75,
                  height: taille * 0.75,
                  child: OuroSpinner(color: couleur, radius: (taille * 0.75) / 2),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                texte,
                style: TextStyle(
                  fontSize: taille,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                  fontFeatures: const [ui.FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Mesh · Wi-Fi direct », « Internet · direct » ou « Internet · relais
/// sécurisé », avec la qualité mesurée.
class _PastilleChemin extends StatelessWidget {
  const _PastilleChemin({required this.call});

  final CallState call;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chemin = cheminAppel(parInternet: call.isRemoteCall, viaRelais: call.viaRelais);
    final texte = switch (chemin) {
      CheminAppel.mesh => l10n.clPathMesh,
      CheminAppel.internetDirect => l10n.clPathInternetDirect,
      CheminAppel.internetRelais => l10n.clPathInternetRelay,
      CheminAppel.internet => l10n.clViaInternet,
    };
    final barres = call.connectionState == CallConnectionState.connected && !call.isReconnecting
        ? barresQualite(call.latencyMs)
        : 0;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chemin == CheminAppel.mesh ? Icons.wifi_tethering_rounded : Icons.public_rounded,
              size: 14,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              texte,
              style: OuroTypography.footnote.copyWith(color: Colors.white70),
            ),
            if (barres > 0) ...[
              const SizedBox(width: 8),
              Semantics(
                label: l10n.clQualitySemantics(barres),
                child: _BarresQualite(barres: barres),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarresQualite extends StatelessWidget {
  const _BarresQualite({required this.barres});

  final int barres;

  @override
  Widget build(BuildContext context) {
    final couleur = switch (barres) {
      3 => OuroColors.successGreen,
      2 => OuroColors.systemOrange,
      _ => OuroColors.errorRed,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 3,
            height: 5.0 + 3.5 * i,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: i < barres ? couleur : Colors.white24,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
      ],
    );
  }
}

/// La barre de contrôle en verre : boutons légendés, et le rouge pour finir.
class _BarreControles extends StatelessWidget {
  const _BarreControles({
    required this.call,
    required this.onMute,
    required this.onSpeaker,
    required this.onVideo,
    required this.onFlip,
    required this.onHangUp,
  });

  final CallState call;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onVideo;
  final VoidCallback onFlip;
  final VoidCallback onHangUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contenu = Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _BoutonAppel(
              icone: call.isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              legende: l10n.clLabelSpeaker,
              semantique: call.isSpeakerOn ? l10n.clDisableSpeaker : l10n.clEnableSpeaker,
              actif: call.isSpeakerOn,
              onTap: onSpeaker,
            ),
          ),
          Expanded(
            child: _BoutonAppel(
              icone: call.isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              legende: l10n.clLabelCamera,
              semantique: call.isVideoEnabled ? l10n.clDisableCamera : l10n.clEnableCamera,
              actif: call.isVideoEnabled,
              onTap: onVideo,
            ),
          ),
          if (call.isVideoEnabled)
            Expanded(
              child: _BoutonAppel(
                icone: Icons.cameraswitch_rounded,
                legende: l10n.clLabelFlip,
                semantique: l10n.clSwitchCamera,
                onTap: onFlip,
              ),
            ),
          Expanded(
            child: _BoutonAppel(
              icone: call.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              legende: l10n.clLabelMic,
              semantique: call.isMuted ? l10n.clEnableMic : l10n.clMuteMic,
              actif: call.isMuted,
              onTap: onMute,
            ),
          ),
          Expanded(
            child: _BoutonAppel(
              icone: Icons.call_end_rounded,
              legende: l10n.clHangUp,
              semantique: l10n.clHangUp,
              destructif: true,
              // `_handleHangUp` déclenche déjà un retour haptique plus marqué.
              haptique: false,
              onTap: onHangUp,
            ),
          ),
        ],
      ),
    );
    final decor = BoxDecoration(
      color: Colors.white.withValues(alpha: DeviceProfile.menager ? 0.12 : 0.08),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );
    // Flou d'arrière-plan seulement là où l'appareil peut se le permettre.
    if (DeviceProfile.menager) {
      return DecoratedBox(decoration: decor, child: contenu);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(decoration: decor, child: contenu),
      ),
    );
  }
}

class _BoutonAppel extends StatefulWidget {
  const _BoutonAppel({
    required this.icone,
    required this.legende,
    required this.semantique,
    required this.onTap,
    this.actif = false,
    this.destructif = false,
    this.haptique = true,
  });

  final IconData icone;
  final String legende;
  final String semantique;
  final VoidCallback onTap;

  /// Allumé : fond blanc, icône sombre (comme iOS).
  final bool actif;

  /// Le bouton rouge pour raccrocher.
  final bool destructif;
  final bool haptique;

  @override
  State<_BoutonAppel> createState() => _BoutonAppelState();
}

class _BoutonAppelState extends State<_BoutonAppel> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    final fond = widget.destructif
        ? OuroColors.errorRed
        : widget.actif
        ? Colors.white
        : Colors.white.withValues(alpha: 0.16);
    final couleurIcone = widget.actif && !widget.destructif ? Colors.black87 : Colors.white;
    // ⚠️ PAS D'ONDE ANDROID : le bouton s'enfonce puis revient, comme iOS.
    return Semantics(
      button: true,
      toggled: widget.destructif ? null : widget.actif,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _enfonce = true),
        onTapCancel: () => setState(() => _enfonce = false),
        onTap: () {
          setState(() => _enfonce = false);
          if (widget.haptique) HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _enfonce ? 0.9 : 1,
              duration: DesignTokens.durationFast,
              curve: DesignTokens.curveSpring,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: fond),
                child: Icon(widget.icone, size: 26, color: couleurIcone),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.legende,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ma propre image : un appui change de caméra, un glisser la déplace, et
/// elle se cale dans le coin le plus proche.
class _VignetteDeplacable extends StatefulWidget {
  const _VignetteDeplacable({
    required this.renderer,
    required this.label,
    required this.onSwitch,
    required this.basReserve,
  });

  final RTCVideoRenderer renderer;
  final String label;
  final VoidCallback onSwitch;

  /// Hauteur à laisser libre en bas (la barre de contrôle, si visible).
  final double basReserve;

  @override
  State<_VignetteDeplacable> createState() => _VignetteDeplacableState();
}

class _VignetteDeplacableState extends State<_VignetteDeplacable> {
  static const _largeur = 108.0;
  static const _hauteur = 156.0;
  static const _marge = 16.0;

  bool _droite = true;
  bool _haut = true;

  /// Position pendant le glisser ; `null` au repos (calée dans un coin).
  Offset? _glissement;

  Offset _coin(Size ecran, EdgeInsets pad) => Offset(
        _droite ? ecran.width - _largeur - _marge : _marge,
        _haut
            ? pad.top + 64
            : ecran.height - _hauteur - widget.basReserve - pad.bottom,
      );

  @override
  Widget build(BuildContext context) {
    final ecran = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final position = _glissement ?? _coin(ecran, pad);
    return AnimatedPositioned(
      duration: _glissement != null ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: position.dx,
      top: position.dy,
      width: _largeur,
      height: _hauteur,
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.onSwitch,
          onPanStart: (_) => setState(() => _glissement = position),
          onPanUpdate: (d) => setState(() => _glissement = (_glissement ?? position) + d.delta),
          onPanEnd: (_) {
            final centre = (_glissement ?? position) + const Offset(_largeur / 2, _hauteur / 2);
            setState(() {
              _droite = centre.dx > ecran.width / 2;
              _haut = centre.dy < ecran.height / 2;
              _glissement = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RTCVideoView(
                  widget.renderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                const Positioned(
                  right: 6,
                  bottom: 6,
                  child: Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
