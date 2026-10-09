// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est l'écran « Infos » d'une conversation — celui qu'on ouvre en
// tapant sur le nom d'un contact en haut d'une discussion. On y trouve
// l'avatar en grand, si la personne est actuellement en ligne, le lien
// vers la vérification du « code de sécurité » (voir
// `security_code_screen.dart`), quelques statistiques (nombre de
// messages, de médias, depuis quand on discute), puis toutes les photos,
// notes vocales et fichiers échangés dans cette conversation, rangés
// dans des petites galeries — un peu comme l'onglet « Médias partagés »
// de WhatsApp.
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/mesh_transport_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/providers/chat_background_provider.dart';
import '../settings/galerie_fonds.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/glassmorphism.dart';
import '../../core/models/voice_note_meta.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/en_tete_profil.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import 'media_kind.dart';
import '../../core/services/avatar_service.dart';
import '../../design_system/ouro_icon_button.dart';
import 'package:flutter/cupertino.dart';
import '../../design_system/ouro_alert.dart';
import '../../shared/widgets/afficher_toast.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../navigateur/navigateur_integre.dart';
import '../../core/services/apercus_liens.dart';
import '../../design_system/ouro_list.dart';
import '../chat/vue_unique.dart';
import 'messages_ephemeres.dart';
import 'messages_ephemeres_screen.dart';
import '../notifications/notifs_conversation_screen.dart' show LigneNotifsConversation;

/// Page « Infos et médias » d'une conversation.
class ChatInfoScreen extends ConsumerStatefulWidget {
  const ChatInfoScreen({super.key, required this.peerId});

  /// ID du pair, ou 'broadcast' pour le canal diffusion.
  final String peerId;

  @override
  ConsumerState<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends ConsumerState<ChatInfoScreen> {
  late bool _isLocked;
  late int _ephemeralTimer;

  @override
  void initState() {
    super.initState();
    _isLocked = StorageService.getLockedConversations().contains(widget.peerId);
    _ephemeralTimer = StorageService.getEphemeralTimer(widget.peerId);
  }

  Future<void> _toggleLock() async {
    final l10n = AppLocalizations.of(context);
    final auth = LocalAuthentication();
    final newState = !_isLocked;

    if (newState) {
      // Verrouiller : vérifier que la biométrie est disponible.
      try {
        final available = await auth.canCheckBiometrics;
        if (!available) {
          if (mounted) {
            afficherToast(context, l10n.ciSetupBiometrics, type: DropletToastType.info);
          }
          return;
        }
        // Demander une authentification pour confirmer l'activation.
        final didAuth = await auth.authenticate(
          localizedReason: l10n.ciEnableLockReason,
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );
        if (!didAuth) return;
        HapticFeedback.mediumImpact();
      } catch (_) {
        return;
      }
    } else {
      // Déverrouiller : petit feedback.
      HapticFeedback.lightImpact();
    }

    await StorageService.setConversationLocked(widget.peerId, newState);
    if (mounted) setState(() => _isLocked = newState);
    // `StorageService.getLockedConversations()` est un cache synchrone, pas
    // un state Riverpod — `conversationsProvider` ne se relit pas tout seul
    // sans ce signal (même pattern que l'épinglage/sourdine juste au-dessus
    // dans ce fichier). Sans lui, la conversation resterait visible dans la
    // liste principale jusqu'au prochain redémarrage.
    ref.read(pinMuteRevisionProvider.notifier).state++;
    // La liste ne montre plus les discussions verrouillées, ni même leur
    // existence : il faut donc dire UNE fois, au moment où l'on verrouille,
    // comment on les retrouve.
    if (newState && mounted) {
      afficherToast(context, l10n.ciLockedWhereHint, type: DropletToastType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final peerId = widget.peerId;
    final isBroadcast = peerId == 'broadcast';
    final messages = ref.watch(conversationMessagesProvider(isBroadcast ? null : peerId));
    final peers = ref.watch(meshPeerListProvider);
    final pseudo = isBroadcast
        ? l10n.chBroadcastMesh
        : ref.watch(peerPseudoProvider(peerId));

    ConnectedPeer? peer;
    if (!isBroadcast) {
      for (final p in peers) {
        if (p.peerId == peerId) {
          peer = p;
          break;
        }
      }
    }

    // Une vue unique n'entre pas dans la galerie : elle n'existe que le
    // temps d'être vue.
    final media = messages
        .where((m) => m.type == 'file' && !VueUnique.marquee(m.content))
        .toList();

    // Les liens partagés, du plus récent au plus ancien, sans doublons —
    // l'onglet « Liens » de Telegram.
    final liens = <Uri>[];
    final dejaVus = <String>{};
    for (final m in messages.reversed) {
      for (final trouve in _motifLien.allMatches(m.content)) {
        final brut = trouve.group(0)!.replaceAll(RegExp(r'[.,;:!?)\]]+$'), '');
        final uri = Uri.tryParse(brut);
        if (uri != null && uri.host.isNotEmpty && dejaVus.add(uri.toString())) liens.add(uri);
      }
      if (liens.length >= 30) break;
    }
    final images = media
        .where((m) => (mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.image))
        .toList();
    final audio = media
        .where((m) => (mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.audio))
        .toList();
    final docs = media
        .where((m) =>
            !((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.image)) &&
            !((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.audio)))
        .toList();

    final firstMessage = messages.isEmpty ? null : messages.first.timestamp;

    void ouvrirLaConversation() => Navigator.of(context).canPop()
        ? Navigator.of(context).pop()
        : context.go('/chat/$peerId');

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      // ── L'EN-TÊTE DE PROFIL ────────────────────────────────────────
      //
      // Celui de Telegram : photo de 100 pt au repos, 42 pt une fois
      // l'écran replié, et plein cadre quand on tire vers le bas (voir
      // `en_tete_profil.dart`). D'où le `CustomScrollView` : l'étirement
      // a besoin d'un sliver, et le rebond a besoin d'être autorisé.
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          EnTeteProfil(
            // La photo vole depuis l'en-tête de la discussion, comme Telegram.
            heroTag: 'avatar-${widget.peerId}',
            pseudo: pseudo,
            statut: peer != null
                ? (peer.isGateway ? l10n.ciGatewayOnline : l10n.ciOnline)
                : l10n.ciOffline,
            enLigne: peer != null,
            cheminPhoto: AvatarService.cheminPair(widget.peerId),
            retour: OuroBackButton(fallback: '/chat/$peerId'),
            actionsBarre: [
              if (!isBroadcast)
                OuroIconButton(
                  tooltip: l10n.ciViewConversation,
                  icon: const Icon(Icons.chat_bubble_rounded),
                  onPressed: ouvrirLaConversation,
                ),
            ],
            actions: [
              ActionProfil(
                icone: Icons.forum_rounded,
                libelle: l10n.pfMessage,
                onTap: ouvrirLaConversation,
              ),
              if (peer != null)
                ActionProfil(
                  icone: Icons.call_rounded,
                  libelle: l10n.pfCall,
                  onTap: () => context.push('/call/$peerId'),
                ),
              if (!isBroadcast)
                ActionProfil(
                  icone: Icons.verified_user_rounded,
                  libelle: l10n.pfSecurity,
                  onTap: () => context.push('/chat/$peerId/security'),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.screenMargin, 12,
                DesignTokens.screenMargin, DesignTokens.space8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
          if (!isBroadcast) _SecurityCodeRow(peerId: peerId, pseudo: pseudo),

          if (!isBroadcast) ...[
            const SizedBox(height: 12),
            _LockToggleRow(locked: _isLocked, onTap: _toggleLock),
          ],


          if (!isBroadcast) ...[
            const SizedBox(height: 12),
            _EphemeralTimerRow(
              peerId: widget.peerId,
              nom: pseudo,
              currentSeconds: _ephemeralTimer,
              onChanged: (seconds) async {
                await StorageService.setEphemeralTimer(widget.peerId, seconds);
                if (mounted) setState(() => _ephemeralTimer = seconds);
              },
            ),
          ],

          // Le fond propre à cette discussion, comme les thèmes de
          // discussion de Telegram.
          const SizedBox(height: 12),
          _FondDiscussionRow(conversation: peerId),

          // Sourdine, aperçu, livraison discrète — pour cette personne seule.
          if (!isBroadcast) ...[
            const SizedBox(height: 12),
            LigneNotifsConversation(conversationId: peerId, nom: pseudo),
          ],

          const SizedBox(height: 24),

          // Statistiques.
          Row(
            children: [
              _StatCard(
                icon: Icons.forum_rounded,
                label: l10n.ciMessages,
                value: '${messages.length}',
                color: OuroColors.meshBlueBright,
                delayMs: 0,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.photo_library_rounded,
                label: l10n.ciMedia,
                value: '${media.length}',
                color: OuroColors.accentPink,
                delayMs: 60,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.calendar_month_rounded,
                label: l10n.ciStart,
                value: _shortDate(firstMessage),
                color: OuroColors.successGreen,
                delayMs: 120,
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (images.isNotEmpty) _sectionTitle(l10n.ciPhotosCount(images.length)),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ImageGrid(images: images).animate().fadeIn(delay: 100.ms, duration: DesignTokens.durationNormal),
            const SizedBox(height: 24),
          ],

          if (audio.isNotEmpty) _sectionTitle(l10n.ciVoiceNotesCount(audio.length)),
          if (audio.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...audio.asMap().entries.map((e) => _AudioTile(message: e.value)
                .animate()
                .fadeIn(delay: (140 + e.key * 40).ms, duration: DesignTokens.durationFast)
                .slideX(begin: 0.08)),
            const SizedBox(height: 24),
          ],

          if (docs.isNotEmpty) _sectionTitle(l10n.ciFilesCount(docs.length)),
          if (docs.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...docs.asMap().entries.map((e) => _FileTile(message: e.value)
                .animate()
                .fadeIn(delay: (140 + e.key * 40).ms, duration: DesignTokens.durationFast)
                .slideX(begin: 0.08)),
            const SizedBox(height: 24),
          ],

          if (liens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: OuroListSection(
                header: '${l10n.ciLinks} · ${liens.length}',
                separatorInset: 68,
                children: [for (final lien in liens.take(12)) _LigneLien(adresse: lien)],
              ),
            ),

          if (media.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  SceneAnimee(
                    emoji: Scenes.aucunResultat,
                    iconeDeSecours: Icons.photo_library_outlined,
                    taille: 56,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.ciNoMediaSharedYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OuroColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Bouton d'appel si connecté.
          if (peer != null) ...[
            const SizedBox(height: 8),
            _CallButton(peerId: peerId),
          ],

          // Blocage et signalement.
          if (!isBroadcast) ...[
            const SizedBox(height: 24),
            _BlockSection(peerId: peerId, pseudo: pseudo),
          ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// L'en-tête de section, dessiné comme partout ailleurs dans l'app.
  ///
  /// iOS écrit ces titres en PETITES CAPITALES GRISES, de graisse
  /// normale : ce sont des repères, pas du contenu. Ils étaient ici en
  /// gras et de la couleur du texte principal — ils pesaient donc plus
  /// lourd que les lignes qu'ils annonçaient, et cet écran ne
  /// ressemblait plus aux autres. Même recette que `OuroListSection`.
  Widget _sectionTitle(String label) {
    return Text(
      label.toUpperCase(),
      style: OuroTypography.sectionHeader.copyWith(
        color: OuroColors.secondaryLabel,
        letterSpacing: 0.5,
      ),
    );
  }

  String _shortDate(DateTime? t) {
    if (t == null) return '—';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
  }
}

/// Ligne cliquable vers l'écran de vérification hors-bande (code de
/// sécurité) — reflète l'état de vérification connu localement pour ce pair.
class _SecurityCodeRow extends StatelessWidget {
  const _SecurityCodeRow({required this.peerId, required this.pseudo});
  final String peerId;
  final String pseudo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final record = StorageService.getPeerRecord(peerId);
    final verified = record?.isVerifiedAndCurrent ?? false;
    final keyChanged = record?.keyChangedSinceVerification ?? false;

    final color = verified
        ? OuroColors.successGreen
        : keyChanged
            ? OuroColors.warningAmber
            : OuroColors.textSecondary;
    final label = verified
        ? l10n.ciVerified
        : keyChanged
            ? l10n.ciKeyChanged
            : l10n.ciNotVerified;
    final icon = verified
        ? Icons.verified_rounded
        : keyChanged
            ? Icons.warning_amber_rounded
            : Icons.qr_code_rounded;

    return GestureDetector(
      onTap: () => context.push('/chat/$peerId/security'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.ciSecurityCode,
                      style: TextStyle(color: OuroColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: OuroColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Une des 3 petites cartes de statistiques en haut (nombre de
/// messages, nombre de médias, date du premier message).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.delayMs = 0,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: OuroColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: OuroColors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: DesignTokens.durationNormal)
        .slideY(begin: 0.15, curve: DesignTokens.curveEmphasis);
  }
}

/// La petite grille en 3 colonnes de toutes les photos partagées dans
/// cette conversation.
class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});
  final List<MeshMessage> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) => _ImageThumb(message: images[i]),
    );
  }
}

/// Une seule vignette de photo dans la grille — un tap l'ouvre en grand
/// avec [_ImageViewer].
class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.message});
  final MeshMessage message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: GestureDetector(
        onTap: () => _openViewer(context),
        child: Hero(
          tag: 'chat-image-${message.id}',
          child: FutureBuilder<String?>(
            future: StorageService.getSharedFilePath(
              message.fileId ?? '',
              message.fileName ?? '',
            ),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const _SkeletonBox();
              }
              final path = snap.data;
              if (path != null && File(path).existsSync()) {
                return Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                );
              }
              return _placeholder();
            },
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Icon(Icons.image_rounded, color: OuroColors.textTertiary, size: 26),
    );
  }

  void _openViewer(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) => _ImageViewer(message: message),
    );
  }
}

/// L'affichage plein écran d'une photo, avec zoom au pincement (comme
/// dans une galerie photo classique).
class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.message});
  final MeshMessage message;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  String? _path;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = await StorageService.getSharedFilePath(
      widget.message.fileId ?? '',
      widget.message.fileName ?? '',
    );
    if (mounted && path != null && File(path).existsSync()) {
      setState(() => _path = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: 'chat-image-${widget.message.id}',
                    child: _path != null
                        ? Image.file(
                            File(_path!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                          )
                        : OuroSpinner(color: OuroColors.meshBlueBright, radius: 14),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: OuroIconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatFull(widget.message.timestamp),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFull(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} · $h:$m';
  }
}

/// Une ligne de la liste des notes vocales partagées.
class _AudioTile extends StatelessWidget {
  const _AudioTile({required this.message});
  final MeshMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OuroColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.mic_rounded, color: OuroColors.errorRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VoiceNoteMeta.describeAttachment(message.fileName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: OuroColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(_formatFull(message.timestamp),
                    style: TextStyle(color: OuroColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: OuroColors.meshBlueBright, size: 24),
        ],
      ),
    );
  }

  String _formatFull(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} · $h:$m';
  }
}

/// Une ligne de la liste des documents (ni photo, ni audio) partagés.
class _FileTile extends StatelessWidget {
  const _FileTile({required this.message});
  final MeshMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OuroColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_rounded, color: OuroColors.warningAmber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VoiceNoteMeta.describeAttachment(message.fileName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: OuroColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(_formatSize(l10n, message.fileSize ?? 0),
                    style: TextStyle(color: OuroColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.chSizeBytes(bytes);
    if (bytes < 1024 * 1024) return l10n.chSizeKb((bytes / 1024).toStringAsFixed(1));
    return l10n.chSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1));
  }
}

/// Ligne de verrouillage de conversation — verrouille/déverrouille
/// l'accès biométrique à cette conversation.
class _LockToggleRow extends StatelessWidget {
  const _LockToggleRow({required this.locked, required this.onTap});
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: locked ? OuroColors.accent : OuroColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ciConversationLock,
                    style: TextStyle(
                      color: OuroColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locked
                        ? l10n.ciLockEnabled
                        : l10n.ciDisabled,
                    style: TextStyle(
                      color: locked
                          ? OuroColors.accent
                          : OuroColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              locked ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: locked ? OuroColors.systemGreen : OuroColors.textTertiary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur de timer pour les messages éphémères — affiche un menu
/// déroulant avec des durées prédéfinies (30s, 5min, 1h, 24h, off).
class _EphemeralTimerRow extends StatelessWidget {
  const _EphemeralTimerRow({
    required this.currentSeconds,
    required this.onChanged,
    required this.peerId,
    required this.nom,
  });

  final int currentSeconds;
  final ValueChanged<int> onChanged;

  /// La discussion réglée, et le nom montré en tête de l'écran.
  final String peerId;
  final String nom;

  static List<MapEntry<String, int>> _options(AppLocalizations l10n) => [
    MapEntry(l10n.ciDisabled, 0),
    MapEntry(l10n.ci30Seconds, 30),
    MapEntry(l10n.ci5Minutes, 300),
    MapEntry(l10n.ci1Hour, 3600),
    MapEntry(l10n.ci24Hours, 86400),
    // Les deux durées longues, celles de WhatsApp : la ligne doit savoir
    // les nommer, puisque l'écran les propose.
    MapEntry(l10n.epDays7, 604800),
    MapEntry(l10n.epDays90, 7776000),
  ];

  String _label(AppLocalizations l10n) {
    for (final o in _options(l10n)) {
      if (o.value == currentSeconds) return o.key;
    }
    return l10n.ciDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = currentSeconds > 0;
    return GestureDetector(
      // L'écran plein, façon WhatsApp : l'illustration, les quatre choix en
      // liste iOS, et la phrase qui dit ce qui va se passer. Il pilote le
      // MÊME minuteur qu'avant — celui qui voyage avec le message.
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MessagesEphemeresScreen(
              cleConversation: peerId,
              nom: nom,
            ),
          ),
        );
        if (context.mounted) {
          onChanged(StorageService.getEphemeralTimer(peerId));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer_off_rounded,
              color: active ? OuroColors.warningAmber : OuroColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ciEphemeralMessages,
                    style: TextStyle(
                      color: OuroColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _label(l10n),
                    style: TextStyle(
                      color: active
                          ? OuroColors.warningAmber
                          : OuroColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: OuroColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

}

/// Le gros bouton vert « Appel vocal » tout en bas de l'écran, visible
/// seulement si ce pair est actuellement connecté.
class _CallButton extends StatelessWidget {
  const _CallButton({required this.peerId});
  final String peerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // ⚠️ `FilledButton` et non `ElevatedButton` : le second porte une
    // OMBRE PORTÉE, héritage de Material. iOS ne met jamais d'ombre sous
    // un bouton plein — il repose à plat sur le fond. C'était le dernier
    // bouton de l'app à flotter, et il ne partageait ni la hauteur (52)
    // ni le rayon des autres actions principales.
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OuroRetourIos(child: FilledButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/call/$peerId');
        },
        style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
          backgroundColor: OuroColors.surRemplissage(OuroColors.successGreen),
          foregroundColor: OuroColors.texteSurRemplissage(OuroColors.successGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
        ),
        icon: const Icon(Icons.call_rounded, size: 20),
        label: Text(l10n.chVoiceCall,
            style: OuroTypography.headline.copyWith(color: Colors.white)),
      )),
    );
  }
}

/// Placeholder skeleton animé avec effet shimmer pour les médias en chargement.
class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox();
  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..bouclerSiAmbiant();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          color: OuroColors.secondarySystemGroupedBackground,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 + t * 2, 0),
                end: Alignment(-0.6 + t * 2, 0),
                colors: const [
                  Colors.transparent,
                  Colors.white24,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              color: OuroColors.secondarySystemGroupedBackground,
            ),
          ),
        );
      },
    );
  }
}

/// Section de blocage et signalement d'un contact.
class _BlockSection extends ConsumerStatefulWidget {
  const _BlockSection({required this.peerId, required this.pseudo});

  final String peerId;
  final String pseudo;

  @override
  ConsumerState<_BlockSection> createState() => _BlockSectionState();
}

class _BlockSectionState extends ConsumerState<_BlockSection> {
  late bool _isBlocked;

  @override
  void initState() {
    super.initState();
    _isBlocked = StorageService.isContactBlocked(widget.peerId);
  }

  Future<void> _toggleBlock() async {
    final l10n = AppLocalizations.of(context);
    final newBlocked = !_isBlocked;
    if (newBlocked) {
      // Confirmation avant blocage
      final confirmed = await ouroConfirm(
      context,
      title: l10n.ciBlockContactTitle,
      message: l10n.ciBlockContactBody(widget.pseudo),
      confirmLabel: l10n.ciBlock,
      cancelLabel: l10n.actionCancel,
      destructive: true,
    );
      if (confirmed != true) return;
    }

    await StorageService.setContactBlocked(widget.peerId, newBlocked);
    if (mounted) {
      setState(() => _isBlocked = newBlocked);
      afficherToast(context, newBlocked ? l10n.ciContactBlocked(widget.pseudo) : l10n.ciContactUnblocked(widget.pseudo), type: DropletToastType.success);
    }
  }

  /// Motifs de signalement proposés — une liste FERMÉE, pas un champ de
  /// texte libre. Voir `DirectoryClient.report` pour pourquoi : un motif
  /// choisi dans cette liste est un code de quelques lettres, jamais du
  /// texte qui pourrait accidentellement transporter un fragment de
  /// conversation jusqu'au serveur.
  List<({String code, String label})> _motifsSignalement(
    AppLocalizations l10n,
  ) =>
      [
        (code: 'spam', label: l10n.ciReportReasonSpam),
        (code: 'harcelement', label: l10n.ciReportReasonHarassment),
        (code: 'illegal', label: l10n.ciReportReasonIllegal),
        (code: 'autre', label: l10n.ciReportReasonOther),
      ];

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final motif = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.ciReportContactTitle),
        message: Text(l10n.ciReportContactBody(widget.pseudo)),
        actions: [
          for (final m in _motifsSignalement(l10n))
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, m.code),
              child: Text(m.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx, null),
          child: Text(l10n.actionCancel),
        ),
      ),
    );
    if (motif == null) return;

    // ⚠️ CE QUI PART VRAIMENT — voir `DirectoryClient.report` et
    // `_handleReport` côté serveur : un identifiant technique et ce
    // motif, rien d'autre. Ni le pseudo ni le moindre message.
    final repo = ref.read(meshRepositoryProvider);
    final ok = await repo.transport.reportContact(widget.peerId, motif);

    if (mounted) {
      afficherToast(context, ok ? l10n.ciReportSent : l10n.ciReportFailed, type: ok ? DropletToastType.success : DropletToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Blocage
        GestureDetector(
          onTap: _toggleBlock,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Row(
              children: [
                Icon(
                  _isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  size: 20,
                  color: _isBlocked ? OuroColors.accent : OuroColors.errorRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isBlocked ? l10n.ciUnblock : l10n.ciBlock,
                    style: OuroTypography.body.copyWith(
                      color: _isBlocked ? OuroColors.accent : OuroColors.errorRed,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: OuroColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Signalement
        GestureDetector(
          onTap: _report,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  size: 20,
                  color: OuroColors.errorRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.ciReport,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.errorRed,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: OuroColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FondDiscussionRow extends ConsumerWidget {
  const _FondDiscussionRow({required this.conversation});

  final String conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final propre = ref.watch(fondConversationProvider(conversation));
    return GestureDetector(
      onTap: () => ouvrirFondsDeDiscussion(context, conversation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: OuroColors.glassBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.wallpaper_rounded, color: OuroColors.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stBgThisChat,
                    style: TextStyle(
                      color: OuroColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    propre == null ? l10n.stBgDefault : nomDuFond(propre, l10n),
                    style: TextStyle(
                      color: OuroColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: OuroColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}



final _motifLien = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+', caseSensitive: false);

/// Une ligne de la section « Liens » : l'initiale du site, le titre de la
/// page (si l'aperçu est connu) et l'adresse. Toucher l'ouvre dans l'app.
class _LigneLien extends StatefulWidget {
  const _LigneLien({required this.adresse});

  final Uri adresse;

  @override
  State<_LigneLien> createState() => _LigneLienState();
}

class _LigneLienState extends State<_LigneLien> {
  bool _appui = false;
  late final Future<ApercuLien?> _apercu = ApercusLiens.charger(widget.adresse);

  @override
  Widget build(BuildContext context) {
    final hote = widget.adresse.host.replaceFirst(RegExp(r'^www\.'), '');
    final lettre = hote.isEmpty ? '?' : hote[0].toUpperCase();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ouvrirLienDansApp(context, widget.adresse.toString()),
      onLongPress: () => proposerActionsLien(context, widget.adresse),
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      child: Container(
        color: _appui ? OuroColors.systemFill : OuroColors.secondarySystemGroupedBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OuroColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                lettre,
                style: TextStyle(color: OuroColors.accent, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<ApercuLien?>(
                future: _apercu,
                initialData: ApercusLiens.enMemoire(widget.adresse),
                builder: (context, instantane) {
                  final a = instantane.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a?.titre ?? a?.site ?? hote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.body.copyWith(
                          color: OuroColors.label,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.adresse.toString().replaceFirst(RegExp(r'^https?://(www\.)?'), ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.footnote.copyWith(color: OuroColors.accent),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
