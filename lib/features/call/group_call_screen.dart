// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est l'écran d'un appel de GROUPE (voix uniquement — voir
// `group_webrtc_call_service.dart` pour comprendre pourquoi il y a une
// limite). Au lieu d'un seul gros avatar au centre comme dans l'appel 1:1,
// on a ici une grille de tuiles, une par personne.
//
// CE QUI A ÉTÉ REPRIS EN MAIN, ET POURQUOI
// ----------------------------------------------------------------------------
// L'écran fonctionnait, mais il ne ressemblait pas au reste de l'app : fond
// noir plat, cartes grises bordées d'un trait de couleur, trois boutons
// ronds nus posés en bas. À côté de l'appel 1:1 (`call_screen.dart`), qui a
// son fond bleu nuit, sa barre en verre et ses boutons légendés, on avait
// l'impression de changer d'application en passant d'un appel à l'autre.
//
// Les décisions prises :
//
// 1. MÊME FOND QUE L'APPEL 1:1 — un halo bleu nuit, plus une teinte très
//    légère de la couleur de celui qui parle, qui respire. De la profondeur
//    sans fatiguer l'œil pendant une heure de conversation.
// 2. ON SE VOIT SOI-MÊME. Le fournisseur ne liste que les autres ; une tuile
//    « Vous » est ajoutée ici, avec l'état du micro dessus. Toutes les
//    grandes apps le font, et pour une bonne raison : sans ça, on ne sait
//    jamais si on est coupé.
// 3. LA VOIX GUIDE L'ŒIL. Celui qui parle grandit à peine, s'éclaire, et ses
//    ondes s'échappent de son avatar ; les autres s'estompent très
//    légèrement. Pas de trait de 2,5 px : une lueur.
// 4. GRILLE ADAPTATIVE. Deux personnes : deux tuiles larges. Trois : une
//    paire et une tuile centrée. Jamais de trou dans la grille.
// 5. BARRE DE CONTRÔLE EN VERRE ET BOUTONS LÉGENDÉS, comme l'appel 1:1 —
//    « Micro », « Haut-parleur », « Raccrocher ». On lit ce qu'on touche.
// 6. RÉDUIRE SANS RACCROCHER. Le chevron en haut à gauche renvoie aux
//    discussions, l'appel continue, et le bandeau de
//    `bandeau_appel_groupe.dart` ramène ici.
// 7. LES ÉTATS REDONDANTS DISPARAISSENT. Quand tout le monde est connecté,
//    afficher « En ligne » quatre fois ne dit plus rien : l'étiquette
//    n'apparaît que pendant la connexion ou après un échec.
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/device_profile.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_spinner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';
import 'salon_vocal.dart';

/// Écran d'appel de groupe — voix uniquement, grille de participants.
/// Expérimental : maillage WebRTC complet sans serveur, plafonné à
/// [GroupCallState] (voir `group_webrtc_call_service.dart` pour le détail).
class GroupCallScreen extends ConsumerStatefulWidget {
  const GroupCallScreen({super.key});

  @override
  ConsumerState<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends ConsumerState<GroupCallScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _elapsed = 0;
  int _activeSpeakerIndex = -1;
  late final AnimationController _speakerCycle;

  /// La respiration du fond. Elle ne sert qu'à faire varier une teinte de
  /// quelques pourcents : séparée du cycle de parole pour que le fond ne
  /// sursaute pas quand la parole change de main.
  late final AnimationController _ambiance;

  /// Gardé sous la main plutôt que relu à la fermeture : `ref` n'est pas
  /// garanti utilisable pendant que l'arbre se démonte.
  late final GroupCallNotifier _appel = ref.read(groupCallProvider.notifier);

  @override
  void initState() {
    super.initState();
    _speakerCycle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _advanceSpeaker();
          _speakerCycle.forward(from: 0);
        }
      });
    _ambiance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..bouclerSiAmbiant(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTimer());
  }

  void _syncTimer() {
    final call = ref.read(groupCallProvider);
    final hasConnected = call.participants
        .any((p) => p.state == GroupCallParticipantState.connected);
    if (hasConnected && _timer == null) {
      _timer =
          Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _elapsed++));
      _speakerCycle.forward(from: 0);
    } else if (!hasConnected && _timer != null) {
      _timer?.cancel();
      _timer = null;
      _speakerCycle.stop();
    }
  }

  /// Envoyer une réaction : elle s'envole ici tout de suite, et part aux
  /// autres membres du salon.
  void _reagir(String emoji) {
    final groupe = ref.read(groupCallProvider).groupId;
    if (groupe == null) return;
    final repo = ref.read(meshRepositoryProvider);
    HapticFeedback.lightImpact();
    SalonsVocaux.reagir(groupId: groupe, auteur: repo.myId, emoji: emoji);
    unawaited(
      repo.annoncerSalonVocal(groupId: groupe, action: 'reagir', emoji: emoji),
    );
  }

  void _advanceSpeaker() {
    final call = ref.read(groupCallProvider);
    final connectedIndices = <int>[];
    for (var i = 0; i < call.participants.length; i++) {
      if (call.participants[i].state == GroupCallParticipantState.connected) {
        connectedIndices.add(i);
      }
    }
    if (connectedIndices.isEmpty) return;
    if (_activeSpeakerIndex < 0 ||
        !connectedIndices.contains(_activeSpeakerIndex)) {
      _activeSpeakerIndex = connectedIndices.first;
    } else {
      final pos = connectedIndices.indexOf(_activeSpeakerIndex);
      _activeSpeakerIndex =
          connectedIndices[(pos + 1) % connectedIndices.length];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speakerCycle.dispose();
    _ambiance.dispose();
    // Le refus ne vaut que pour ce salon-ci : sans cet oubli, il
    // s'afficherait encore à la prochaine ouverture.
    _appel.salonComplet = null;
    super.dispose();
  }

  String _formatElapsed(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Color _stateColor(GroupCallParticipantState state) {
    return switch (state) {
      GroupCallParticipantState.connecting => OuroColors.warningAmber,
      GroupCallParticipantState.connected => OuroColors.successGreen,
      GroupCallParticipantState.failed => OuroColors.errorRed,
      GroupCallParticipantState.disconnected => OuroColors.callSecondaryLabel,
    };
  }

  String _stateLabel(AppLocalizations l10n, GroupCallParticipantState state) {
    return switch (state) {
      GroupCallParticipantState.connecting => l10n.gcConnecting,
      GroupCallParticipantState.connected => l10n.gcOnline,
      GroupCallParticipantState.failed => l10n.gcFailed,
      GroupCallParticipantState.disconnected => l10n.gcDisconnected,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final call = ref.watch(groupCallProvider);
    final repo = ref.read(meshRepositoryProvider);

    final hasConnected = call.participants
        .any((p) => p.state == GroupCallParticipantState.connected);
    if (hasConnected && _timer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncTimer());
    } else if (!hasConnected && _timer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncTimer());
    }

    // ⚠️ UN SALON VIDE N'EST PAS UN APPEL TERMINÉ. Ouvrir un salon, c'est
    // entrer seul et attendre : afficher « Appel terminé » à ce moment-là
    // donnait l'impression que ça venait de rater. C'est `isActive` qui
    // départage — la liste des participants, elle, est vide dans les deux
    // cas.
    final enAttente = call.isActive && call.participants.isEmpty;
    final complet = _appel.salonComplet;

    // Les autres, puis moi. Moi en dernier : ce sont les autres qu'on
    // regarde, ma propre tuile n'est là que pour l'état de mon micro.
    final occupants = <_Occupant>[
      for (var i = 0; i < call.participants.length; i++)
        _Occupant(
          pseudo: call.participants[i].pseudo,
          photo: AvatarService.cheminPair(call.participants[i].peerId),
          couleur: _stateColor(call.participants[i].state),
          etiquette: call.participants[i].state ==
                  GroupCallParticipantState.connected
              ? null
              : _stateLabel(l10n, call.participants[i].state),
          connexion: call.participants[i].state ==
              GroupCallParticipantState.connecting,
          connecte: call.participants[i].state ==
              GroupCallParticipantState.connected,
          actif: call.participants[i].state ==
                  GroupCallParticipantState.connecting ||
              call.participants[i].state ==
                  GroupCallParticipantState.connected,
          parle: i == _activeSpeakerIndex &&
              call.participants[i].state ==
                  GroupCallParticipantState.connected,
          micCoupe: false,
        ),
      if (call.isActive)
        _Occupant(
          pseudo: l10n.mpYou,
          photo: AvatarService.chemin(StorageService.currentUser?.avatarUrl),
          couleur: OuroColors.successGreen,
          etiquette: null,
          connexion: false,
          connecte: true,
          actif: true,
          parle: false,
          micCoupe: call.isMuted,
        ),
    ];

    // La teinte du fond suit celui qui parle : imperceptible, mais la pièce
    // n'est plus la même quand quelqu'un prend la parole. Personne ne parle :
    // on reste sur le bleu du maillage, pas sur l'ambre de la connexion —
    // une pièce teintée d'orange ressemble à une alerte.
    final parlants = occupants.where((o) => o.parle);
    final teinte =
        parlants.isEmpty ? OuroColors.meshBlue : parlants.first.couleur;

    return Scaffold(
      // Noir fixe, même en mode clair — voir `OuroColors.callBackground`.
      backgroundColor: OuroColors.callBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: _FondSalon(
              teinte: teinte,
              respiration: _ambiance,
              anime: _timer != null,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _EnTeteSalon(
                  nom: call.groupName ?? l10n.gcGroupCall,
                  minuteur: _timer != null ? _formatElapsed(_elapsed) : null,
                  sousTitre: enAttente
                      ? l10n.vrWaiting
                      : (_timer == null
                          ? l10n.gcParticipantsVoiceOnly(
                              call.participants.length)
                          : null),
                  // On peut réduire un salon où l'on attend : c'est même
                  // tout l'intérêt — on ouvre la porte, on retourne écrire,
                  // et la pastille de l'accueil ramène quand ça parle.
                  onReduire:
                      call.isActive ? () => context.go('/chats') : null,
                ),
                Expanded(
                  // ⚠️ LE REFUS ARRIVE APRÈS COUP, donc il atterrit ici.
                  // Le serveur ne dit « complet » qu'une fois la connexion
                  // ouverte : celui qui a touché le bouton a déjà quitté
                  // l'écran précédent. Le dire là où il regarde vaut mieux
                  // qu'un « Appel terminé » qui n'explique rien.
                  child: !call.isActive
                      ? EmptyState(
                          emoji: Scenes.appelManque,
                          icon: complet != null
                              ? Icons.groups_rounded
                              : Icons.call_end_rounded,
                          title: complet != null
                              ? l10n.vrFull(complet)
                              : l10n.clCallEnded,
                          iconColor: OuroColors.callSecondaryLabel,
                        )
                      : _GrilleSalon(occupants: occupants),
                ),
                // La première fois, voir son seul visage à l'écran
                // n'explique rien. Une ligne, le temps que quelqu'un
                // arrive, et elle disparaît d'elle-même.
                if (enAttente)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                    child: Text(
                      l10n.vrWaitingBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: OuroColors.callSecondaryLabel,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ).animate().fadeIn(
                        delay: 500.ms,
                        duration: DesignTokens.durationSheet,
                      ),
                // Réagir sans couper la parole : six emoji, et ce qu'on
                // envoie s'envole aussi chez les autres.
                if (call.isActive) _BarreReactions(onReagir: _reagir),
                const SizedBox(height: 10),
                _BarreControlesSalon(
                  muet: call.isMuted,
                  hautParleur: call.isSpeakerOn,
                  onMicro: () =>
                      ref.read(groupCallProvider.notifier).toggleMute(),
                  onHautParleur: () =>
                      ref.read(groupCallProvider.notifier).toggleSpeaker(),
                  onRaccrocher: () {
                    HapticFeedback.heavyImpact();
                    ref.read(groupCallProvider.notifier).hangUp();
                    context.go('/chats');
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          // Par-dessus tout le reste : les réactions qui montent. En
          // dernier dans la pile, sinon elles passaient derrière les tuiles.
          Positioned.fill(
            child: _EnvolReactions(
              groupId: call.groupId,
              moi: repo.myId,
              // 18 + 86 (barre) + 10 + 48 (emoji) + 8 de marge : juste
              // au-dessus du pouce, jamais derrière les contrôles.
              depart: MediaQuery.paddingOf(context).bottom + 170,
              pseudos: {
                for (final p in call.participants) p.peerId: p.pseudo,
                repo.myId: l10n.mpYou,
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Une tuile de la grille, réduite à ce qu'elle a besoin de savoir.
class _Occupant {
  const _Occupant({
    required this.pseudo,
    required this.photo,
    required this.couleur,
    required this.etiquette,
    required this.connexion,
    required this.connecte,
    required this.actif,
    required this.parle,
    required this.micCoupe,
  });

  final String pseudo;
  final String? photo;
  final Color couleur;

  /// `null` quand il n'y a plus rien d'utile à dire — connecté, tout va bien.
  final String? etiquette;

  /// En train de se connecter : on met un petit rouet à côté de l'étiquette.
  final bool connexion;

  /// Vraiment connecté. `actif` couvre aussi la connexion en cours ; il
  /// fallait les séparer, sinon la pastille de l'avatar passait au vert
  /// pendant que l'étiquette disait encore « Connexion… ».
  final bool connecte;
  final bool actif;
  final bool parle;
  final bool micCoupe;
}

// ============================================================================
// LE FOND
// ============================================================================

/// Le fond du salon : le même halo bleu nuit que l'appel 1:1, plus une
/// teinte de la couleur de celui qui parle, qui respire très lentement.
/// Volontairement à la limite du visible : sur un écran d'appel, tout ce
/// qui bouge franchement finit par agacer.
class _FondSalon extends StatelessWidget {
  const _FondSalon({
    required this.teinte,
    required this.respiration,
    required this.anime,
  });

  final Color teinte;
  final Animation<double> respiration;
  final bool anime;

  @override
  Widget build(BuildContext context) {
    final base = const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.15,
          colors: [OuroColors.callGlow, OuroColors.callBackground],
        ),
      ),
      child: SizedBox.expand(),
    );
    // Les appareils modestes n'ont pas besoin d'un deuxième dégradé plein
    // écran redessiné à chaque image.
    if (!anime || DeviceProfile.menager) return base;
    return Stack(
      children: [
        Positioned.fill(child: base),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: respiration,
            builder: (context, _) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.55),
                  radius: 1.0,
                  colors: [
                    teinte.withValues(alpha: 0.05 + respiration.value * 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// L'EN-TÊTE
// ============================================================================

/// Le nom du groupe, le minuteur en chiffres de largeur fixe, et la pastille
/// de chiffrement — l'écho de l'en-tête de l'appel 1:1.
class _EnTeteSalon extends StatelessWidget {
  const _EnTeteSalon({
    required this.nom,
    required this.minuteur,
    required this.sousTitre,
    required this.onReduire,
  });

  final String nom;

  /// `00:42`, ou `null` tant que personne n'est connecté.
  final String? minuteur;

  /// Ce qu'on affiche à la place du minuteur avant que l'appel démarre.
  final String? sousTitre;
  final VoidCallback? onReduire;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: DesignTokens.minTouchTarget,
                height: DesignTokens.minTouchTarget,
                child: onReduire == null
                    ? null
                    : _BoutonVerre(
                        icone: Icons.keyboard_arrow_down_rounded,
                        semantique: l10n.gcMinimize,
                        onTap: onReduire!,
                      ),
              ),
              Expanded(
                child: Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: OuroColors.callLabel,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.45,
                  ),
                ),
              ),
              // Le pendant du chevron, pour que le nom reste vraiment centré.
              const SizedBox(width: DesignTokens.minTouchTarget),
            ],
          ),
          const SizedBox(height: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: minuteur != null
                ? Row(
                    key: const ValueKey('minuteur'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        minuteur!,
                        style: const TextStyle(
                          color: OuroColors.callLabel,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [ui.FontFeature.tabularFigures()],
                        ),
                      ),
                      const _PointSeparateur(),
                      Text(
                        l10n.gcVoiceOnly,
                        style: const TextStyle(
                          color: OuroColors.callSecondaryLabel,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    sousTitre ?? '',
                    key: const ValueKey('attente'),
                    style: const TextStyle(
                      color: OuroColors.callSecondaryLabel,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          const _PastilleChiffrementSalon(),
        ],
      ),
    );
  }
}

class _PointSeparateur extends StatelessWidget {
  const _PointSeparateur();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          color: OuroColors.callSecondaryLabel,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// « Chiffré de bout en bout » : vrai ici aussi, la voix ne traverse aucun
/// mélangeur — chaque paire a son propre lien WebRTC.
class _PastilleChiffrementSalon extends StatelessWidget {
  const _PastilleChiffrementSalon();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 11, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            l10n.clEndToEndEncrypted,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un petit rond en verre, pour le chevron « réduire ».
class _BoutonVerre extends StatefulWidget {
  const _BoutonVerre({
    required this.icone,
    required this.semantique,
    required this.onTap,
  });

  final IconData icone;
  final String semantique;
  final VoidCallback onTap;

  @override
  State<_BoutonVerre> createState() => _BoutonVerreState();
}

class _BoutonVerreState extends State<_BoutonVerre> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _enfonce = true),
        onTapCancel: () => setState(() => _enfonce = false),
        onTap: () {
          setState(() => _enfonce = false);
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Center(
          child: AnimatedScale(
            scale: _enfonce ? 0.88 : 1,
            duration: DesignTokens.durationFast,
            curve: DesignTokens.curveSpring,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: _enfonce ? 0.20 : 0.12),
              ),
              child: Icon(widget.icone, size: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LA GRILLE
// ============================================================================

/// La grille des présents. Une colonne à deux personnes (des tuiles larges,
/// on respire), deux au-delà ; et quand le compte est impair, la dernière
/// tuile se centre au lieu de laisser un trou à côté d'elle.
class _GrilleSalon extends StatelessWidget {
  const _GrilleSalon({required this.occupants});

  final List<_Occupant> occupants;

  @override
  Widget build(BuildContext context) {
    const ecart = 12.0;
    final colonnes = occupants.length <= 2 ? 1 : 2;
    final lignes = <List<int>>[];
    for (var i = 0; i < occupants.length; i += colonnes) {
      lignes.add([
        for (var j = i; j < math.min(i + colonnes, occupants.length) ; j++) j,
      ]);
    }

    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeurTuile =
            (contraintes.maxWidth - 32 - ecart * (colonnes - 1)) / colonnes;
        // ⚠️ LES TUILES ONT UNE TAILLE EXPLICITE, ET C'EST INDISPENSABLE.
        // Leur contenu est une `Stack` dont tous les enfants sont
        // positionnés ; sous des contraintes lâches, une telle pile se
        // réduit à zéro et la tuile disparaît. En fixant largeur ET
        // hauteur ici, les contraintes descendent serrées et la pile
        // remplit exactement sa case.
        final hauteurTuile = math.max(
          0.0,
          math.min(
            (contraintes.maxHeight - 4 - ecart * (lignes.length - 1)) /
                lignes.length,
            // Au-delà de 1,3 fois sa largeur, une tuile s'étire en
            // colonne et ne ressemble plus à rien.
            largeurTuile * 1.3,
          ),
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var l = 0; l < lignes.length; l++) ...[
                if (l > 0) const SizedBox(height: ecart),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var k = 0; k < lignes[l].length; k++) ...[
                      if (k > 0) const SizedBox(width: ecart),
                      SizedBox(
                        width: largeurTuile,
                        height: hauteurTuile,
                        child: _TuileOccupant(
                          occupant: occupants[lignes[l][k]],
                          rang: lignes[l][k],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Une tuile : du verre teinté, un avatar, un nom. Celui qui parle s'éclaire
/// et grandit d'un cheveu ; les autres reculent d'autant.
class _TuileOccupant extends StatelessWidget {
  const _TuileOccupant({required this.occupant, required this.rang});

  final _Occupant occupant;
  final int rang;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = occupant;
    final tuile = LayoutBuilder(
      builder: (context, c) {
        // L'avatar suit la tuile. On ne le calcule pas « à la louche » sur
        // la largeur : on retire d'abord la place du nom et de l'étiquette,
        // puis on divise par 3,6 — un peu plus que les 3,2 rayons que
        // prend l'avatar avec ses ondes, pour qu'il leur reste de l'air
        // autour. Ainsi le bloc ENTRE dans la tuile par construction, quelle
        // que soit la taille de l'écran, au lieu de déborder sur les petits.
        const placeTexte = 46.0;
        final hDispo = math.max(0.0, c.maxHeight - placeTexte);
        final rayon =
            (math.min(c.maxWidth, hDispo) / 3.6).clamp(20.0, 52.0).toDouble();
        return AnimatedContainer(
          duration: DesignTokens.durationStandard,
          curve: DesignTokens.curveEnter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: o.parle
                  ? [
                      o.couleur.withValues(alpha: 0.18),
                      o.couleur.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04),
                    ],
            ),
            border: Border.all(
              color: o.parle
                  ? o.couleur.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.08),
              width: o.parle ? 1.4 : 0.8,
            ),
            // `DesignTokens.glow` ne rend PLUS une lueur colorée : c'est
            // une ombre noire sobre, voulue telle quelle dans le système.
            // Ce qui désigne vraiment celui qui parle, c'est le dégradé, le
            // trait, les ondes et le demi-point d'échelle — pas ça.
            boxShadow: o.parle
                ? DesignTokens.glow(o.couleur, radius: 26, spread: 0)
                : null,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AvatarOccupant(
                        pseudo: o.pseudo,
                        photo: o.photo,
                        couleur: o.couleur,
                        actif: o.actif,
                        connecte: o.connecte,
                        parle: o.parle,
                        rayon: rayon,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          o.pseudo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: OuroColors.callLabel,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Rien à dire quand tout va bien : « En ligne » répété
                      // sur chaque tuile n'informait personne.
                      if (o.etiquette != null) ...[
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (o.connexion) ...[
                                SizedBox(
                                  width: 11,
                                  height: 11,
                                  child: OuroSpinner(
                                    color: o.couleur,
                                    radius: 5.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              // L'allemand et le russe écrivent « Connexion »
                              // beaucoup plus long que le français : la ligne
                              // se coupe au lieu de sortir de la tuile.
                              Flexible(
                                child: Text(
                                  o.etiquette!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: o.couleur,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (o.micCoupe)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _BadgeMicroCoupe(semantique: l10n.gcMicOff),
                ),
            ],
          ),
        );
      },
    );

    return Semantics(
      label: o.parle ? '${o.pseudo} · ${l10n.gcSpeakingNow}' : o.pseudo,
      excludeSemantics: true,
      child: AnimatedScale(
        // Ce n'est presque rien, et c'est ce qui fait qu'on regarde la
        // bonne tuile sans y penser.
        scale: o.parle ? 1.0 : 0.975,
        duration: DesignTokens.durationStandard,
        curve: DesignTokens.curveEnter,
        child: AnimatedOpacity(
          opacity: o.parle ? 1 : 0.88,
          duration: DesignTokens.durationStandard,
          child: tuile,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (rang * 55).ms, duration: DesignTokens.durationStandard)
        .scaleXY(
          begin: 0.92,
          curve: DesignTokens.curveEnter,
          duration: DesignTokens.durationStandard,
        );
  }
}

/// Le petit micro barré posé sur ma tuile quand je suis coupé.
class _BadgeMicroCoupe extends StatelessWidget {
  const _BadgeMicroCoupe({required this.semantique});

  final String semantique;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantique,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: OuroColors.ouroOrange,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.mic_off_rounded, size: 15, color: Colors.white),
      ),
    );
  }
}

/// Avatar de participant avec halo pulsé pendant la connexion/l'appel —
/// miroir du `_PulseRing` de l'appel 1:1 (`call_screen.dart`), pour donner à
/// la grille de groupe le même niveau de vie que l'appel individuel.
class _AvatarOccupant extends StatefulWidget {
  const _AvatarOccupant({
    required this.pseudo,
    required this.photo,
    required this.couleur,
    required this.actif,
    required this.connecte,
    required this.parle,
    required this.rayon,
  });

  final String pseudo;
  final String? photo;
  final Color couleur;
  final bool actif;
  final bool connecte;
  final bool parle;
  final double rayon;

  @override
  State<_AvatarOccupant> createState() => _AvatarOccupantState();
}

class _AvatarOccupantState extends State<_AvatarOccupant>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..bouclerSiAmbiant(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rayon = widget.parle ? widget.rayon * 1.06 : widget.rayon;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        if (!widget.actif) return child!;
        final glowRadius =
            widget.parle ? 12 + _pulse.value * 14 : 8 + _pulse.value * 8;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: DesignTokens.glow(widget.couleur,
                radius: glowRadius, spread: widget.parle ? 2 : 1),
          ),
          child: child,
        );
      },
      child: SizedBox(
        // Assez large pour que les ondes ne soient pas rognées.
        width: rayon * 3.2,
        height: rayon * 3.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Deux ondes qui s'échappent de l'avatar de celui qui parle,
            // décalées d'un demi-temps : on repère la voix avant même de
            // lire le nom. Elles ne tournent que pour lui, sinon quatre
            // avatars pulseraient ensemble et plus rien ne se distinguerait.
            if (widget.parle)
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => SizedBox.expand(
                  child: CustomPaint(
                    painter: _OndesParole(
                      avancement: _pulse.value,
                      couleur: widget.couleur,
                      rayonAvatar: rayon,
                    ),
                  ),
                ),
              ),
            PeerAvatar(
              pseudo: widget.pseudo,
              radius: rayon,
              imagePath: widget.photo,
              // Vert seulement quand la voix passe vraiment ; orange tant
              // qu'on négocie. C'est `reconnecting` qui donne l'orange.
              online: widget.connecte,
              reconnecting: widget.actif && !widget.connecte,
            ),
          ],
        ),
      ),
    );
  }
}

/// Les ondes de celui qui parle : deux anneaux qui s'écartent et s'effacent.
class _OndesParole extends CustomPainter {
  _OndesParole({
    required this.avancement,
    required this.couleur,
    required this.rayonAvatar,
  });

  /// De 0 à 1, en boucle.
  final double avancement;
  final Color couleur;
  final double rayonAvatar;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    // On part du bord de l'avatar, pas du vide : l'onde doit sembler
    // sortir de la personne.
    final depart = rayonAvatar + 4;
    final arrivee = size.width / 2;
    if (arrivee <= depart) return;
    for (var i = 0; i < 2; i++) {
      // La seconde onde part un demi-temps après la première : le
      // mouvement paraît continu au lieu de battre.
      final t = (avancement + i * 0.5) % 1;
      final rayon = depart + (arrivee - depart) * t;
      canvas.drawCircle(
        centre,
        rayon,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - t) + 0.6
          ..isAntiAlias = true
          ..color = couleur.withValues(alpha: (1 - t) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_OndesParole ancien) =>
      ancien.avancement != avancement ||
      ancien.couleur != couleur ||
      ancien.rayonAvatar != rayonAvatar;
}

// ============================================================================
// LES RÉACTIONS
// ============================================================================

/// La barre des réactions : six emoji dans une capsule en verre, pour
/// approuver sans couper la parole.
class _BarreReactions extends StatelessWidget {
  const _BarreReactions({required this.onReagir});

  final ValueChanged<String> onReagir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contenu = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in SalonsVocaux.emojis)
            _BoutonReaction(
              emoji: e,
              semantique: l10n.gcReactWith(e),
              onTap: () => onReagir(e),
            ),
        ],
      ),
    );
    final decor = BoxDecoration(
      color: Colors.white.withValues(alpha: DeviceProfile.menager ? 0.12 : 0.08),
      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );
    return Center(
      child: DeviceProfile.menager
          ? DecoratedBox(decoration: decor, child: contenu)
          : ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DecoratedBox(decoration: decor, child: contenu),
              ),
            ),
    )
        .animate()
        .fadeIn(duration: DesignTokens.durationStandard)
        .slideY(
          begin: 0.3,
          curve: DesignTokens.curveEnter,
          duration: DesignTokens.durationStandard,
        );
  }
}

class _BoutonReaction extends StatefulWidget {
  const _BoutonReaction({
    required this.emoji,
    required this.semantique,
    required this.onTap,
  });

  final String emoji;
  final String semantique;
  final VoidCallback onTap;

  @override
  State<_BoutonReaction> createState() => _BoutonReactionState();
}

class _BoutonReactionState extends State<_BoutonReaction> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _appui = true),
        onTapUp: (_) => setState(() => _appui = false),
        onTapCancel: () => setState(() => _appui = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _appui ? 0.82 : 1,
          duration: const Duration(milliseconds: 140),
          curve: DesignTokens.curveEnter,
          child: SizedBox(
            // 44 pt de haut : la règle iOS, même pour un emoji.
            height: DesignTokens.minTouchTarget,
            width: 42,
            child: Center(
              child: Text(widget.emoji, style: const TextStyle(fontSize: 25)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Les réactions reçues : elles montent, dérivent, tournent un peu et
/// s'effacent, avec le nom de qui les envoie le temps de le lire.
///
/// Chacune a son couloir, calculé sur l'identifiant de son auteur : deux
/// pouces levés en même temps ne se superposent jamais.
class _EnvolReactions extends StatefulWidget {
  const _EnvolReactions({
    required this.groupId,
    required this.moi,
    required this.pseudos,
    required this.depart,
  });

  final String? groupId;
  final String moi;
  final Map<String, String> pseudos;

  /// À quelle hauteur du bas de l'écran une réaction apparaît.
  final double depart;

  @override
  State<_EnvolReactions> createState() => _EnvolReactionsState();
}

class _EnvolReactionsState extends State<_EnvolReactions>
    with SingleTickerProviderStateMixin {
  static const int _vieMs = 3400;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (!mounted) return;
      // Le rouet ne tourne que tant qu'il reste quelque chose à l'écran :
      // un appel d'une heure ne doit pas redessiner pour rien.
      if (!_resteQuelqueChose()) {
        _ticker.stop();
        setState(() {});
        return;
      }
      setState(() {});
    });
    SalonsVocaux.reactions.addListener(_reveiller);
    if (_resteQuelqueChose()) _ticker.start();
  }

  bool _resteQuelqueChose() {
    final maintenant = DateTime.now();
    for (final r in SalonsVocaux.reactions.value) {
      if (widget.groupId != null && r.groupId != widget.groupId) continue;
      if (maintenant.difference(r.quand).inMilliseconds < _vieMs) return true;
    }
    return false;
  }

  void _reveiller() {
    if (!mounted) return;
    if (!_ticker.isActive && _resteQuelqueChose()) _ticker.start();
  }

  @override
  void dispose() {
    SalonsVocaux.reactions.removeListener(_reveiller);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ReactionSalon>>(
      valueListenable: SalonsVocaux.reactions,
      builder: (context, toutes, _) {
        final maintenant = DateTime.now();
        final visibles = [
          for (final r in toutes)
            if (widget.groupId == null || r.groupId == widget.groupId)
              if (maintenant.difference(r.quand).inMilliseconds < _vieMs) r,
        ];
        if (visibles.isEmpty) return const SizedBox.shrink();
        return IgnorePointer(
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                for (final r in visibles)
                  _UneReaction(
                    key: ValueKey('${r.auteur}-${r.quand.microsecondsSinceEpoch}'),
                    reaction: r,
                    avancement:
                        maintenant.difference(r.quand).inMilliseconds / _vieMs,
                    largeur: c.maxWidth,
                    depart: widget.depart,
                    // Mes réactions partent de sous mon pouce, côté droit ;
                    // celles des autres se répartissent sur la largeur.
                    couloir: r.auteur == widget.moi
                        ? 0.82
                        : 0.12 + (r.auteur.hashCode.abs() % 70) / 100,
                    nom: r.auteur == widget.moi
                        ? null
                        : widget.pseudos[r.auteur],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UneReaction extends StatelessWidget {
  const _UneReaction({
    super.key,
    required this.reaction,
    required this.avancement,
    required this.largeur,
    required this.depart,
    required this.couloir,
    required this.nom,
  });

  final ReactionSalon reaction;

  /// De 0 (elle vient de partir) à 1 (elle a disparu).
  final double avancement;
  final double largeur;

  /// Sa hauteur de naissance, au-dessus du bas de l'écran.
  final double depart;

  /// Où elle démarre, en fraction de la largeur.
  final double couloir;
  final String? nom;

  @override
  Widget build(BuildContext context) {
    final t = avancement.clamp(0.0, 1.0).toDouble();
    // Elle monte vite puis ralentit : l'inverse donnerait l'impression
    // qu'elle est tirée par une ficelle.
    final montee = Curves.easeOutCubic.transform(t);
    final derive =
        math.sin(t * math.pi * 2.2 + (reaction.auteur.hashCode % 100) / 16) * 20;
    // Une naissance en deux temps : elle apparaît un peu trop grosse, puis
    // se pose. C'est ce « pop » qui fait qu'on la remarque.
    final echelle = t < 0.14
        ? 0.5 + (t / 0.14) * 0.72
        : (1.22 - (t - 0.14) / 0.86 * 0.5).clamp(0.6, 1.22).toDouble();
    return Positioned(
      left: (couloir * (largeur - 56)).clamp(8.0, largeur - 64) + derive,
      bottom: depart + montee * 250,
      child: Opacity(
        opacity: (1 - t * t).clamp(0.0, 1.0).toDouble(),
        child: Transform.rotate(
          angle: math.sin(t * math.pi * 1.6) * 0.16,
          child: Transform.scale(
            scale: echelle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reaction.emoji, style: const TextStyle(fontSize: 30)),
                // Le nom s'efface avant l'emoji : il sert à savoir qui a
                // réagi, pas à rester à l'écran.
                if (nom != null && nom!.isNotEmpty)
                  Opacity(
                    opacity: (1 - t / 0.5).clamp(0.0, 1.0).toDouble(),
                    child: Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                      child: Text(
                        nom!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
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

// ============================================================================
// LES CONTRÔLES
// ============================================================================

/// La barre de contrôle en verre : boutons légendés, et le rouge pour finir.
/// C'est exactement la barre de l'appel 1:1, pour qu'on ne se demande jamais
/// où est le micro selon le type d'appel.
class _BarreControlesSalon extends StatelessWidget {
  const _BarreControlesSalon({
    required this.muet,
    required this.hautParleur,
    required this.onMicro,
    required this.onHautParleur,
    required this.onRaccrocher,
  });

  final bool muet;
  final bool hautParleur;
  final VoidCallback onMicro;
  final VoidCallback onHautParleur;
  final VoidCallback onRaccrocher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contenu = Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _BoutonSalon(
              icone: hautParleur
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              legende: l10n.clLabelSpeaker,
              semantique:
                  hautParleur ? l10n.clDisableSpeaker : l10n.clEnableSpeaker,
              actif: hautParleur,
              onTap: onHautParleur,
            ),
          ),
          Expanded(
            child: _BoutonSalon(
              icone: muet ? Icons.mic_off_rounded : Icons.mic_rounded,
              legende: l10n.clLabelMic,
              semantique: muet ? l10n.clEnableMic : l10n.clMuteMic,
              actif: muet,
              onTap: onMicro,
            ),
          ),
          Expanded(
            child: _BoutonSalon(
              icone: Icons.call_end_rounded,
              legende: l10n.clHangUp,
              semantique: l10n.clHangUp,
              destructif: true,
              // Le rappel haptique plus marqué est déjà déclenché à côté.
              haptique: false,
              onTap: onRaccrocher,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Flou d'arrière-plan seulement là où l'appareil peut se le permettre.
      child: DeviceProfile.menager
          ? DecoratedBox(decoration: decor, child: contenu)
          : ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(decoration: decor, child: contenu),
              ),
            ),
    );
  }
}

class _BoutonSalon extends StatefulWidget {
  const _BoutonSalon({
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
  State<_BoutonSalon> createState() => _BoutonSalonState();
}

class _BoutonSalonState extends State<_BoutonSalon> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    final fond = widget.destructif
        ? OuroColors.errorRed
        : widget.actif
            ? Colors.white
            : Colors.white.withValues(alpha: 0.16);
    final couleurIcone =
        widget.actif && !widget.destructif ? Colors.black87 : Colors.white;
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
