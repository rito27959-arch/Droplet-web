// ============================================================================
// STOCKAGE — ce que les photos, vidéos et fichiers prennent sur le téléphone.
// ----------------------------------------------------------------------------
// Droplet garde une copie de chaque fichier échangé, sans jamais rien
// montrer de leur poids. Après quelques semaines de vidéos, la seule façon
// de faire de la place était de désinstaller.
//
// Comme « Gérer le stockage » de WhatsApp :
//   • le total, et une barre qui le découpe par type ;
//   • les discussions, de la plus lourde à la plus légère ;
//   • dans une discussion, les fichiers du plus gros au plus petit, qu'on
//     coche puis qu'on supprime d'un coup.
//
// Supprimer un fichier supprime aussi son message SUR CE TÉLÉPHONE : une
// bulle de photo sans photo ne servirait à rien. Rien n'est effacé chez
// l'autre personne.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../chat/media_kind.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_alert.dart';
import '../../shared/taille_lisible.dart';

enum _Genre { photo, video, audio, document, autre }

class _Fichier {
  _Fichier({required this.fichier, required this.taille, required this.genre, this.message});

  final File fichier;
  final int taille;
  final _Genre genre;

  /// Le message qui porte ce fichier, s'il existe encore.
  final MeshMessage? message;
}

class _Discussion {
  _Discussion({required this.cle, required this.nom, this.peerId, this.groupe = false});

  final String cle;
  final String nom;
  final String? peerId;
  final bool groupe;
  final List<_Fichier> fichiers = [];

  int get taille => fichiers.fold(0, (t, f) => t + f.taille);
}


Color _couleur(_Genre g) => switch (g) {
      _Genre.photo => OuroColors.accent,
      _Genre.video => OuroColors.systemPurple,
      _Genre.audio => OuroColors.systemOrange,
      _Genre.document => OuroColors.systemGreen,
      _Genre.autre => OuroColors.systemGray,
    };

String _libelle(AppLocalizations l10n, _Genre g) => switch (g) {
      _Genre.photo => l10n.stoPhotos,
      _Genre.video => l10n.stoVideos,
      _Genre.audio => l10n.stoAudio,
      _Genre.document => l10n.stoDocuments,
      _Genre.autre => l10n.stoOther,
    };

IconData _icone(_Genre g) => switch (g) {
      _Genre.photo => Icons.image_rounded,
      _Genre.video => Icons.videocam_rounded,
      _Genre.audio => Icons.graphic_eq_rounded,
      _Genre.document => Icons.description_rounded,
      _Genre.autre => Icons.folder_rounded,
    };

class StockageScreen extends ConsumerStatefulWidget {
  const StockageScreen({super.key});

  @override
  ConsumerState<StockageScreen> createState() => _StockageScreenState();
}

class _StockageScreenState extends ConsumerState<StockageScreen> {
  List<_Discussion>? _discussions;

  @override
  void initState() {
    super.initState();
    // Après la première image : l'analyse lit les traductions, qui ne sont
    // pas encore accessibles pendant `initState`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _analyser();
    });
  }

  /// Parcourt le dossier des fichiers partagés (`shared/<id>-<nom>`) et
  /// rattache chaque fichier à son message, donc à sa discussion.
  Future<void> _analyser() async {
    final l10n = AppLocalizations.of(context);
    final messages = ref.read(meshMessagesProvider);
    final moi = ref.read(meshRepositoryProvider).myId;
    final parFichier = {
      for (final m in messages)
        if (m.type == 'file' && m.fileId != null) m.fileId!: m,
    };
    final discussions = <String, _Discussion>{};
    final autres = _Discussion(cle: '_autres', nom: l10n.stoOther);

    try {
      final dossier = Directory('${(await getApplicationDocumentsDirectory()).path}/shared');
      if (await dossier.exists()) {
        await for (final entree in dossier.list()) {
          if (entree is! File) continue;
          final nom = entree.uri.pathSegments.last;
          // Nom de fichier : `<identifiant de 36 caractères>-<nom d'origine>`.
          final id = nom.length > 37 ? nom.substring(0, 36) : '';
          final message = parFichier[id];
          final taille = (await entree.stat()).size;
          final genre = message == null && id.isEmpty
              ? _Genre.autre
              : switch (mediaKindOf(message?.fileMimeType, nom)) {
                  MediaKind.image => _Genre.photo,
                  MediaKind.video => _Genre.video,
                  MediaKind.audio => _Genre.audio,
                  _ => _Genre.document,
                };
          final fichier = _Fichier(fichier: entree, taille: taille, genre: genre, message: message);
          if (message == null) {
            autres.fichiers.add(fichier);
            continue;
          }
          final groupe = message.groupId;
          final autre = message.senderId == moi ? message.targetId : message.senderId;
          final cle = groupe ?? autre ?? 'broadcast';
          final discussion = discussions.putIfAbsent(cle, () {
            if (groupe != null) {
              return _Discussion(
                cle: cle,
                nom: StorageService.getGroup(groupe)?.name ?? groupe,
                groupe: true,
              );
            }
            if (autre == null) return _Discussion(cle: cle, nom: l10n.chBroadcastChannel);
            return _Discussion(
              cle: cle,
              nom: StorageService.getPeerRecord(autre)?.pseudo ?? message.authorPseudo,
              peerId: autre,
            );
          });
          discussion.fichiers.add(fichier);
        }
      }
    } catch (e) {
      debugPrint('[Stockage] analyse impossible: $e');
    }

    final liste = [...discussions.values, if (autres.fichiers.isNotEmpty) autres]
      ..sort((a, b) => b.taille.compareTo(a.taille));
    for (final d in liste) {
      d.fichiers.sort((a, b) => b.taille.compareTo(a.taille));
    }
    if (mounted) setState(() => _discussions = liste);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discussions = _discussions;

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      appBar: AppBar(title: Text(l10n.stoTitle)),
      body: discussions == null
          ? const Center(child: OuroSpinner())
          : discussions.isEmpty
              ? Center(
                  child: Text(l10n.stoEmpty, style: TextStyle(color: OuroColors.secondaryLabel)),
                )
              : RefreshIndicator.adaptive(
                  onRefresh: _analyser,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _Resume(discussions: discussions),
                      const SizedBox(height: DesignTokens.space5),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          l10n.stoByChat.toUpperCase(),
                          style: OuroTypography.caption1.copyWith(
                            color: OuroColors.secondaryLabel,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (final d in discussions)
                        _LigneDiscussion(
                          discussion: d,
                          onTap: () async {
                            OuroHaptics.selection();
                            final supprimes = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => _DetailDiscussion(discussion: d)),
                            );
                            if (supprimes == true) await _analyser();
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}

/// Le total, et la barre qui le découpe par type.
class _Resume extends StatelessWidget {
  const _Resume({required this.discussions});

  final List<_Discussion> discussions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parGenre = <_Genre, int>{};
    for (final d in discussions) {
      for (final f in d.fichiers) {
        parGenre[f.genre] = (parGenre[f.genre] ?? 0) + f.taille;
      }
    }
    final total = parGenre.values.fold(0, (t, v) => t + v);
    final genres = _Genre.values.where((g) => (parGenre[g] ?? 0) > 0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.stoUsed(tailleLisible(total)), style: OuroTypography.title2),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final g in genres)
                    Expanded(
                      flex: ((parGenre[g]! / total) * 1000).round().clamp(1, 1000),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: t,
                            child: ColoredBox(color: _couleur(g)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final g in genres)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: _couleur(g), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_libelle(l10n, g)} · ${tailleLisible(parGenre[g]!)}',
                      style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LigneDiscussion extends StatelessWidget {
  const _LigneDiscussion({required this.discussion, required this.onTap});

  final _Discussion discussion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = discussion;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
      leading: d.cle == '_autres'
          ? CircleAvatar(
              radius: 22,
              backgroundColor: OuroColors.systemGray.withValues(alpha: 0.2),
              child: Icon(Icons.folder_rounded, color: OuroColors.systemGray),
            )
          : PeerAvatar(
              pseudo: d.nom,
              radius: 22,
              imagePath: d.groupe ? null : AvatarService.cheminPair(d.peerId),
            ),
      title: Text(d.nom, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${d.fichiers.length} · ${tailleLisible(d.taille)}'),
      trailing: Icon(Icons.chevron_right_rounded, color: OuroColors.tertiaryLabel),
    );
  }
}

/// Les fichiers d'une discussion : on coche, on supprime.
class _DetailDiscussion extends ConsumerStatefulWidget {
  const _DetailDiscussion({required this.discussion});

  final _Discussion discussion;

  @override
  ConsumerState<_DetailDiscussion> createState() => _DetailDiscussionState();
}

class _DetailDiscussionState extends ConsumerState<_DetailDiscussion> {
  final Set<File> _choisis = {};
  bool _supprime = false;

  Future<void> _supprimer() async {
    final l10n = AppLocalizations.of(context);
    final ok = await ouroConfirm(
      context,
      title: l10n.stoDeleteConfirm,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.actionCancel,
      destructive: true,
    );
    if (ok != true || !mounted) return;
    final notifier = ref.read(meshMessagesProvider.notifier);
    for (final f in widget.discussion.fichiers.where((f) => _choisis.contains(f.fichier))) {
      try {
        await f.fichier.delete();
      } catch (_) {}
      final message = f.message;
      if (message != null) notifier.deleteMessage(message.id);
    }
    HapticFeedback.mediumImpact();
    widget.discussion.fichiers.removeWhere((f) => _choisis.contains(f.fichier));
    setState(() {
      _choisis.clear();
      _supprime = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fichiers = widget.discussion.fichiers;
    final tousChoisis = fichiers.isNotEmpty && _choisis.length == fichiers.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (aQuitte, _) {
        if (!aQuitte) Navigator.of(context).pop(_supprime);
      },
      child: Scaffold(
        backgroundColor: OuroColors.systemGroupedBackground,
        appBar: AppBar(
          title: Text(widget.discussion.nom),
          actions: [
            OuroIconButton(
              icon: Icon(tousChoisis ? Icons.deselect_rounded : Icons.select_all_rounded),
              onPressed: () => setState(() {
                tousChoisis
                    ? _choisis.clear()
                    : _choisis.addAll(fichiers.map((f) => f.fichier));
              }),
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 130,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: fichiers.length,
          itemBuilder: (context, i) {
            final f = fichiers[i];
            final choisi = _choisis.contains(f.fichier);
            return GestureDetector(
              onTap: () {
                OuroHaptics.selection();
                setState(() => choisi ? _choisis.remove(f.fichier) : _choisis.add(f.fichier));
              },
              child: AnimatedScale(
                scale: choisi ? 0.9 : 1,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: f.genre == _Genre.photo
                          ? Image.file(
                              f.fichier,
                              fit: BoxFit.cover,
                              cacheWidth: 260,
                              errorBuilder: (context, error, stack) =>
                                  _Tuile(genre: f.genre),
                            )
                          : _Tuile(genre: f.genre),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Text(
                            tailleLisible(f.taille),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Icon(
                        choisi ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: choisi ? OuroColors.accent : Colors.white,
                        shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedSlide(
          offset: _choisis.isEmpty ? const Offset(0, 2) : Offset.zero,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: FloatingActionButton.extended(
            backgroundColor: OuroColors.surRemplissage(OuroColors.systemRed),
            foregroundColor: OuroColors.texteSurRemplissage(OuroColors.systemRed),
            onPressed: _choisis.isEmpty ? null : _supprimer,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(
              '${l10n.stoDelete(_choisis.length)} · ${tailleLisible(fichiers.where((f) => _choisis.contains(f.fichier)).fold(0, (t, f) => t + f.taille))}',
            ),
          ),
        ),
      ),
    );
  }
}

class _Tuile extends StatelessWidget {
  const _Tuile({required this.genre});

  final _Genre genre;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _couleur(genre).withValues(alpha: 0.16),
      child: Center(child: Icon(_icone(genre), color: _couleur(genre), size: 34)),
    );
  }
}
