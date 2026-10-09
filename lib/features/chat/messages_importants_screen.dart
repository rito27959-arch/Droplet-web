// ============================================================================
// L'ÉCRAN DES MESSAGES IMPORTANTS — repris de WhatsApp sur iPhone.
// ----------------------------------------------------------------------------
// ── ⚠️ CE QUI N'ALLAIT PAS ─────────────────────────────────────────────
//
// Chaque message était une ligne de liste : un avatar, « Vous », et
// l'extrait en gris. Pour un texte, passe encore. Pour un vocal, l'extrait
// était… le NOM DU FICHIER, qui encode la durée et la forme d'onde :
// « voix~bai~EO7122100000006100003700… .m4a ». Une liste de charabia.
//
// ── CE QUE FAIT WHATSAPP, ET DONC CE QUE FAIT CET ÉCRAN ────────────────
//
//   • une EN-TÊTE par message : l'avatar de l'auteur, « Auteur ▸ Discussion »,
//     la date, et un chevron — on sait d'où vient le message et qu'un
//     toucher y mène ;
//   • en dessous, LE MESSAGE TEL QU'IL ÉTAIT : une vraie bulle, à la
//     couleur de son côté (la mienne en couleur, celle des autres en gris),
//     avec l'étoile et l'heure dans son coin ;
//   • un vocal est un VOCAL — bouton, onde, durée ; une photo est une
//     PHOTO, en vignette ;
//   • un toucher ouvre la discussion SUR le message, qui clignote ;
//   • glisser vers la gauche retire l'étoile ;
//   • une recherche en haut, dès qu'il y a de quoi chercher.
// ============================================================================

import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/mesh_message.dart';
import '../../core/models/voice_note_meta.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/nom_pair.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/afficher_toast.dart';
import '../../shared/widgets/peer_avatar.dart';
import 'media_kind.dart';
import 'messages_importants.dart';
import 'voice_note.dart';

class MessagesImportantsScreen extends ConsumerStatefulWidget {
  const MessagesImportantsScreen({super.key});

  @override
  ConsumerState<MessagesImportantsScreen> createState() =>
      _MessagesImportantsScreenState();
}

class _MessagesImportantsScreenState
    extends ConsumerState<MessagesImportantsScreen> {
  String _requete = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Le message VIVANT, quand il existe encore : il porte l'identifiant
    // du fichier (pour la vignette) et l'état de lecture (pour les
    // coches). Sinon, la copie prise au moment de l'étoile suffit.
    final vivants = {
      for (final m in ref.watch(meshMessagesProvider)) m.id: m,
    };
    return ValueListenableBuilder<int>(
      valueListenable: MessagesImportants.revision,
      builder: (context, _, _) {
        final tous = MessagesImportants.tous();
        final q = _requete.trim().toLowerCase();
        final liste = q.isEmpty
            ? tous
            : tous
                .where((m) =>
                    _texteCherchable(m, l10n).toLowerCase().contains(q))
                .toList();
        return OuroLargeTitleScaffold(
          title: l10n.imTitle,
          backgroundColor: OuroColors.systemBackground,
          leading: const OuroBackButton(),
          actions: [
            if (tous.isNotEmpty)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toutRetirer(context, l10n),
                child: Text(
                  l10n.imClearAll,
                  style: OuroTypography.body.copyWith(color: OuroColors.accent),
                ),
              ),
          ],
          slivers: [
            if (tous.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EtatVide(l10n: l10n),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: CupertinoSearchTextField(
                    placeholder: l10n.imSearch,
                    style: OuroTypography.body.copyWith(color: OuroColors.label),
                    onChanged: (v) => setState(() => _requete = v),
                  ),
                ),
              ),
              if (liste.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      l10n.chNoneFound,
                      style: OuroTypography.subheadline
                          .copyWith(color: OuroColors.secondaryLabel),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: liste.length,
                  itemBuilder: (context, i) => _Entree(
                    key: ValueKey(liste[i].id),
                    message: liste[i],
                    vivant: vivants[liste[i].id],
                    premiere: i == 0,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ],
        );
      },
    );
  }

  /// Ce sur quoi porte la recherche : le texte, la légende, l'auteur et la
  /// discussion — jamais le nom de fichier encodé d'un vocal.
  String _texteCherchable(MessageImportant m, AppLocalizations l10n) {
    final contenu = _estFichier(m) ? (_legende(m) ?? '') : m.contenu;
    return '$contenu ${_nomAuteur(m, l10n)} ${_nomDiscussion(m)}';
  }

  Future<void> _toutRetirer(BuildContext context, AppLocalizations l10n) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.imClearAll),
        content: Text(l10n.imClearAllBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.imClear),
          ),
        ],
      ),
    );
    if (ok == true) {
      OuroHaptics.light();
      MessagesImportants.toutRetirer();
    }
  }
}

// ── Petites aides partagées ─────────────────────────────────────────────

bool _estFichier(MessageImportant m) =>
    m.type == 'file' || (m.nomFichier != null && m.contenu == m.nomFichier);

/// La vraie légende d'une pièce jointe, ou `null` : le contenu d'un
/// fichier sans légende EST son nom, qu'il ne faut jamais montrer.
String? _legende(MessageImportant m) {
  final c = m.contenu.trim();
  if (c.isEmpty || c == m.nomFichier) return null;
  return c;
}

String _nomAuteur(MessageImportant m, AppLocalizations l10n) {
  if (m.deMoi) return l10n.imYou;
  final a = m.auteur?.trim();
  return (a != null && a.isNotEmpty) ? a : l10n.imUnknown;
}

/// Le nom de la discussion : le groupe, ou l'autre personne.
String _nomDiscussion(MessageImportant m) {
  final g = m.groupId;
  if (g != null) return StorageService.getGroup(g)?.name ?? '';
  final p = m.peerId;
  if (p == null) return '';
  return nomDuPair(p, [StorageService.getPeerRecord(p)?.pseudo, m.auteur]);
}

/// Une entrée : l'en-tête « Auteur ▸ Discussion », puis la bulle.
class _Entree extends StatefulWidget {
  const _Entree({
    super.key,
    required this.message,
    required this.vivant,
    required this.premiere,
  });

  final MessageImportant message;
  final MeshMessage? vivant;
  final bool premiere;

  @override
  State<_Entree> createState() => _EntreeState();
}

class _EntreeState extends State<_Entree> {
  bool _appui = false;

  void _ouvrir() {
    OuroHaptics.selection();
    final m = widget.message;
    context.push('${m.route}?message=${Uri.encodeQueryComponent(m.id)}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = widget.message;
    final langue = Localizations.localeOf(context).toLanguageTag();
    final auteur = _nomAuteur(m, l10n);
    final discussion = _nomDiscussion(m);
    final avatar = m.deMoi
        ? AvatarService.chemin(StorageService.currentUser?.avatarUrl)
        : (m.groupId == null ? AvatarService.cheminPair(m.peerId) : null);

    final contenu = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      onTap: _ouvrir,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _appui ? OuroColors.systemFill : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── L'EN-TÊTE ──────────────────────────────────────────
            Row(
              children: [
                PeerAvatar(
                  pseudo: auteur,
                  radius: 14,
                  imagePath: avatar,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: auteur),
                        if (discussion.isNotEmpty) ...[
                          TextSpan(
                            text: '  ▸  ',
                            style: TextStyle(
                              color: OuroColors.tertiaryLabel,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(text: m.deMoi || m.groupId != null ? discussion : l10n.imYou),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat.yMd(langue).format(m.quand),
                  style: OuroTypography.footnote
                      .copyWith(color: OuroColors.secondaryLabel),
                ),
                const SizedBox(width: 2),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: OuroColors.tertiaryLabel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── LA BULLE ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 30),
              child: _Bulle(message: m, vivant: widget.vivant),
            ),
          ],
        ),
      ),
    );

    // Glisser vers la gauche retire l'étoile — le geste de WhatsApp.
    return Column(
      children: [
        if (!widget.premiere)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: OuroColors.separator,
            ),
          ),
        Dismissible(
          key: ValueKey('etoile-${m.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: OuroColors.systemRed,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_border_rounded, color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  l10n.imClear,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) {
            OuroHaptics.light();
            MessagesImportants.retirer(m.id);
            afficherToast(context, l10n.imRemoved);
          },
          child: contenu,
        ),
      ],
    );
  }
}

/// La bulle, telle qu'elle était dans la discussion.
class _Bulle extends StatelessWidget {
  const _Bulle({required this.message, required this.vivant});

  final MessageImportant message;
  final MeshMessage? vivant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = message;
    final mine = m.deMoi;
    final fond = mine
        ? OuroColors.bubbleOutgoing
        : (OuroColors.isDark ? OuroColors.bubbleIncoming : const Color(0xFFF0F0F2));
    final encre = mine ? OuroColors.bubbleOutgoingText : OuroColors.label;
    final secondaire = mine
        ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
        : OuroColors.secondaryLabel;

    final pied = _Pied(
      heure: DateFormat.Hm(Localizations.localeOf(context).toLanguageTag())
          .format(m.quand),
      couleur: secondaire,
      vivant: mine ? vivant : null,
      encre: encre,
    );

    Widget corps;
    final nom = m.nomFichier ?? vivant?.fileName;
    if (_estFichier(m) && VoiceNoteMeta.isVoiceNote(nom)) {
      corps = _CorpsVocal(nom: nom, encre: encre, pied: pied, mine: mine);
    } else if (_estFichier(m)) {
      corps = _CorpsMedia(
        message: m,
        vivant: vivant,
        encre: encre,
        pied: pied,
      );
    } else {
      // Le texte, et le pied posé dans le coin — comme dans la
      // discussion : sur la dernière ligne s'il y a la place.
      corps = Padding(
        padding: const EdgeInsets.fromLTRB(12, 7, 10, 6),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            Text(
              m.contenu.trim().isEmpty ? l10n.imUnknown : m.contenu,
              maxLines: 12,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.body.copyWith(color: encre, height: 1.3),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: pied,
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fond,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          child: corps,
        ),
      ),
    );
  }
}

/// ★ 20:13 ✓✓ — l'étoile, l'heure, et pour mes messages les coches.
class _Pied extends StatelessWidget {
  const _Pied({
    required this.heure,
    required this.couleur,
    required this.vivant,
    required this.encre,
  });

  final String heure;
  final Color couleur;
  final MeshMessage? vivant;
  final Color encre;

  @override
  Widget build(BuildContext context) {
    final v = vivant;
    IconData? coche;
    var couleurCoche = couleur;
    if (v != null) {
      if (v.readAt != null) {
        coche = Icons.done_all_rounded;
        couleurCoche = encre;
      } else if (v.deliveryCount > 0) {
        coche = Icons.done_all_rounded;
      } else if (v.status == MessageStatus.sent) {
        coche = Icons.done_rounded;
      } else if (v.status == MessageStatus.failed) {
        coche = Icons.error_outline_rounded;
        couleurCoche = OuroColors.systemRed;
      } else {
        coche = Icons.schedule_rounded;
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 12, color: couleur),
        const SizedBox(width: 2),
        Text(heure, style: TextStyle(fontSize: 11.5, color: couleur)),
        if (coche != null) ...[
          const SizedBox(width: 3),
          Icon(coche, size: 15, color: couleurCoche),
        ],
      ],
    );
  }
}

/// Un vocal : bouton, onde, durée. Le toucher mène à la discussion, où il
/// se lit pour de bon.
class _CorpsVocal extends StatelessWidget {
  const _CorpsVocal({
    required this.nom,
    required this.encre,
    required this.pied,
    required this.mine,
  });

  final String? nom;
  final Color encre;
  final Widget pied;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final meta = VoiceNoteMeta.tryParse(nom);
    final s = meta?.duration.inSeconds ?? 0;
    final duree = '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    final accent = mine ? encre : OuroColors.accent;
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mine
                        ? encre.withValues(alpha: 0.95)
                        : OuroColors.accent,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 22,
                    color: mine ? OuroColors.bubbleOutgoing : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VoiceWaveform(
                    waveform: meta?.waveform ?? const [],
                    progress: 0,
                    activeColor: accent,
                    inactiveColor: accent.withValues(alpha: 0.45),
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const SizedBox(width: 42),
                Text(
                  duree,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: encre.withValues(alpha: 0.7),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                pied,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Une photo, une vidéo ou un document.
class _CorpsMedia extends StatefulWidget {
  const _CorpsMedia({
    required this.message,
    required this.vivant,
    required this.encre,
    required this.pied,
  });

  final MessageImportant message;
  final MeshMessage? vivant;
  final Color encre;
  final Widget pied;

  @override
  State<_CorpsMedia> createState() => _CorpsMediaState();
}

class _CorpsMediaState extends State<_CorpsMedia> {
  Future<String?>? _chemin;

  MediaKind get _genre => mediaKindOf(
        widget.vivant?.fileMimeType,
        widget.message.nomFichier ?? widget.vivant?.fileName,
      );

  @override
  void initState() {
    super.initState();
    final v = widget.vivant;
    if (_genre == MediaKind.image && v?.fileId != null) {
      _chemin = StorageService.getSharedFilePath(
        v!.fileId!,
        v.fileName ?? widget.message.nomFichier ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final legende = _legende(widget.message);
    final genre = _genre;

    if (genre == MediaKind.image) {
      return SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: FutureBuilder<String?>(
                    future: _chemin,
                    builder: (context, snap) {
                      final chemin = snap.data;
                      if (chemin == null) {
                        return ColoredBox(
                          color: OuroColors.systemFill,
                          child: Icon(
                            Icons.photo_outlined,
                            size: 34,
                            color: OuroColors.secondaryLabel,
                          ),
                        );
                      }
                      return Image(
                        image: ResizeImage(
                          FileImage(File(chemin)),
                          width: (240 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: OuroColors.systemFill),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
              child: Row(
                children: [
                  if (legende != null)
                    Expanded(
                      child: Text(
                        legende,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.body
                            .copyWith(color: widget.encre, height: 1.3),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  widget.pied,
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Vidéo ou document : une icône, le mot, et le pied.
    final (icone, mot) = switch (genre) {
      MediaKind.video => (Icons.videocam_rounded, l10n.apcVideo),
      _ => (
          Icons.insert_drive_file_rounded,
          widget.message.nomFichier ?? l10n.apcAttachment,
        ),
    };
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icone, size: 26, color: widget.encre.withValues(alpha: 0.85)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    legende ?? mot,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(color: widget.encre),
                  ),
                ),
              ],
            ),
            Align(alignment: Alignment.centerRight, child: widget.pied),
          ],
        ),
      ),
    );
  }
}

/// L'état vide : une étoile, et la phrase qui apprend le geste.
class _EtatVide extends StatelessWidget {
  const _EtatVide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: OuroColors.accent.withValues(alpha: 0.12),
              border: Border.all(
                color: OuroColors.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.star_rounded, size: 42, color: OuroColors.accent),
          ),
          const SizedBox(height: DesignTokens.space5),
          Text(
            l10n.imEmptyBody,
            textAlign: TextAlign.center,
            style: OuroTypography.subheadline.copyWith(
              color: OuroColors.secondaryLabel,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
