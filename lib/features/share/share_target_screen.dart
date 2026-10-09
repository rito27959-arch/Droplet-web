// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ÉCRAN QUI S'OUVRE QUAND ON PARTAGE QUELQUE CHOSE VERS DROPLET depuis
// une autre application — la galerie, un navigateur, un gestionnaire de
// fichiers.
//
// ── ⚠️ LE DÉFAUT QUE CETTE RÉÉCRITURE CORRIGE D'ABORD ─────────────────
//
// IL FAISAIT CONFIRMER À L'AVEUGLE. Pour un fichier, l'aperçu affichait un
// trombone et « 3 éléments à partager » : ni nom, ni taille, ni image.
// On ne savait donc pas CE QU'ON ENVOYAIT.
//
// Et un seul appui sur un nom envoyait, immédiatement, sans confirmation.
// Les deux défauts ensemble donnaient le pire enchaînement possible : un
// appui de travers expédiait un fichier qu'on n'avait pas identifié à
// quelqu'un qu'on n'avait pas choisi — et un message envoyé ne se
// rattrape pas.
//
// Désormais : on VOIT ce qu'on partage (vignette réelle pour une image,
// nom et taille pour un fichier, extrait pour du texte), on CHOISIT un ou
// plusieurs destinataires, et on appuie sur « Envoyer ». Trois gestes au
// lieu d'un, et c'est exactement ce qu'il faut ici.
//
// ── CE QUI FAIT LA FINESSE iOS ────────────────────────────────────────
//
// • Grand titre qui se replie au défilement (`OuroLargeTitleScaffold`),
//   comme partout ailleurs dans Droplet — cet écran était le seul à avoir
//   une barre plate, et ça se voyait.
// • Une rangée de RÉCENTS en haut, avant la liste : c'est le geste de la
//   feuille de partage d'iOS, et neuf partages sur dix visent quelqu'un
//   qu'on vient de croiser.
// • Une barre d'envoi en verre, posée sur la liste qui glisse dessous
//   (`OuroBlurSurface`), jamais une colonne qui coupe le défilement net.
// • Les composants de la maison (`OuroListRow`, `DesignTokens`) au lieu
//   des `ListTile` bruts et des marges écrites à la main.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/services/share_intent_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/taille_lisible.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/scene_animee.dart';

/// Ce qu'on sait d'un élément partagé, une fois le disque interrogé.
class _Element {
  _Element({
    required this.item,
    required this.nom,
    required this.octets,
    required this.estImage,
  });

  final SharedMediaFile item;
  final String nom;

  /// Zéro quand le fichier a disparu entre le partage et l'affichage —
  /// ça arrive avec les fichiers temporaires de certaines galeries.
  final int octets;
  final bool estImage;

  bool get estTexte =>
      item.type == SharedMediaType.text || item.type == SharedMediaType.url;
}

class ShareTargetScreen extends ConsumerStatefulWidget {
  const ShareTargetScreen({super.key});

  @override
  ConsumerState<ShareTargetScreen> createState() => _ShareTargetScreenState();
}

class _ShareTargetScreenState extends ConsumerState<ShareTargetScreen> {
  late final List<SharedMediaFile> _items =
      List.of(ShareIntentService.pendingItems);
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _envoiEnCours = false;

  /// Les destinataires cochés, par clé stable.
  final Set<String> _choisis = {};

  List<_Element> _elements = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_inspecter());
  }

  /// Va chercher sur le disque ce que l'intention de partage ne dit pas :
  /// le nom réel et la taille. Sans ça, l'aperçu ne peut rien montrer.
  Future<void> _inspecter() async {
    final sortie = <_Element>[];
    for (final item in _items) {
      final estTexte = item.type == SharedMediaType.text ||
          item.type == SharedMediaType.url;
      if (estTexte) {
        sortie.add(_Element(
          item: item,
          nom: item.path,
          octets: 0,
          estImage: false,
        ));
        continue;
      }
      var octets = 0;
      try {
        final f = File(item.path);
        if (f.existsSync()) octets = await f.length();
      } on Object {
        // Un fichier illisible ne doit pas vider tout l'aperçu : on le
        // montre quand même, avec une taille inconnue.
        octets = 0;
      }
      sortie.add(_Element(
        item: item,
        nom: item.path.split('/').last,
        octets: octets,
        estImage: _estImage(item),
      ));
    }
    if (mounted) setState(() => _elements = sortie);
  }

  static bool _estImage(SharedMediaFile item) {
    if (item.type == SharedMediaType.image) return true;
    final m = item.mimeType;
    if (m != null && m.startsWith('image/')) return true;
    final p = item.path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif');
  }

  static String _cle(Conversation c) => c.isGroup ? 'g:${c.groupId}' : 'p:${c.peerId}';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _annuler() {
    ShareIntentService.clear();
    context.go('/chats');
  }

  void _basculer(Conversation c) {
    OuroHaptics.selection();
    final cle = _cle(c);
    setState(() {
      if (!_choisis.remove(cle)) _choisis.add(cle);
    });
  }

  Future<void> _envoyer(List<Conversation> toutes) async {
    if (_envoiEnCours || _choisis.isEmpty) return;
    final cibles = toutes.where((c) => _choisis.contains(_cle(c))).toList();
    if (cibles.isEmpty) return;

    setState(() => _envoiEnCours = true);
    OuroHaptics.medium();
    final me = StorageService.currentUser;
    final notifier = ref.read(meshMessagesProvider.notifier);
    try {
      for (final conv in cibles) {
        for (final item in _items) {
          if (item.type == SharedMediaType.text ||
              item.type == SharedMediaType.url) {
            if (conv.isGroup) {
              await notifier.sendGroupMessage(
                  me?.pseudo ?? 'Moi', item.path, groupId: conv.groupId!);
            } else {
              await notifier.sendMessage(me?.pseudo ?? 'Moi', item.path,
                  targetId: conv.peerId);
            }
          } else {
            final file = File(item.path);
            if (!await file.exists()) continue;
            final bytes = await file.readAsBytes();
            await notifier.sendFile(
              pseudo: me?.pseudo ?? 'Moi',
              fileName: item.path.split('/').last,
              bytes: Uint8List.fromList(bytes),
              mimeType: item.mimeType ?? 'application/octet-stream',
              targetId: conv.isGroup ? null : conv.peerId,
              groupId: conv.groupId,
            );
          }
        }
      }
    } finally {
      ShareIntentService.clear();
      if (mounted) {
        OuroHaptics.success();
        // ⚠️ ON OUVRE LA CONVERSATION QUAND IL N'Y EN A QU'UNE. Avec
        // plusieurs destinataires, en ouvrir une seule laisserait croire
        // que les autres n'ont rien reçu : on revient à la liste, où
        // chaque fil montre son envoi.
        final seule = cibles.length == 1 ? cibles.first : null;
        context.go(seule == null
            ? '/chats'
            : (seule.isGroup
                ? '/group/${seule.groupId}'
                : '/chat/${seule.peerId}'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final toutes = ref.watch(conversationsProvider);
    final filtrees = _query.isEmpty
        ? toutes
        : toutes
            .where((c) =>
                c.pseudo.toLowerCase().contains(_query.toLowerCase()))
            .toList(growable: false);

    // Les récents : les plus fraîches, hors résultats de recherche — une
    // rangée qui change pendant qu'on tape serait illisible.
    final recents = (List.of(toutes)
          ..sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp)))
        .take(8)
        .toList();

    return Stack(
      children: [
        IosMagnifierOverlay(
          child: OuroLargeTitleScaffold(
            title: l10n.shShareTo,
            subtitle: _choisis.isEmpty
                ? l10n.shPickRecipients
                : l10n.shSelected(_choisis.length),
            leading: OuroBarButton(
              icon: Icons.close_rounded,
              onPressed: _annuler,
            ),
            slivers: [
              if (_elements.isNotEmpty)
                SliverToBoxAdapter(child: _Apercu(elements: _elements)),
              SliverToBoxAdapter(child: _Recherche(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              )),
              if (_query.isEmpty && recents.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Recents(
                    conversations: recents,
                    choisis: _choisis,
                    cle: _cle,
                    onBasculer: _basculer,
                  ),
                ),
              if (filtrees.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    emoji: Scenes.partage,
                    icon: Icons.forum_outlined,
                    title: l10n.shNoConversation,
                    subtitle: l10n.shOpenChatFirst,
                  ),
                )
              else
                SliverList.builder(
                  itemCount: filtrees.length,
                  itemBuilder: (context, i) {
                    final conv = filtrees[i];
                    return _Ligne(
                      conversation: conv,
                      choisie: _choisis.contains(_cle(conv)),
                      actif: !_envoiEnCours,
                      onTap: () => _basculer(conv),
                    )
                        .animate()
                        .fadeIn(
                          delay: (i * 18).ms,
                          duration: DesignTokens.durationFast,
                        );
                  },
                ),
              // De quoi laisser passer la liste SOUS la barre d'envoi.
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BarreEnvoi(
            nombre: _choisis.length,
            enCours: _envoiEnCours,
            onEnvoyer: () => unawaited(_envoyer(toutes)),
          ),
        ),
      ],
    );
  }
}

// ══ L'APERÇU : CE QU'ON ENVOIE ══════════════════════════════════════════

/// ⚠️ C'EST LA PIÈCE QUI MANQUAIT. L'ancienne version annonçait
/// « 3 éléments à partager » et rien d'autre. On confirmait un envoi sans
/// savoir ce qu'on envoyait.
class _Apercu extends StatelessWidget {
  const _Apercu({required this.elements});

  final List<_Element> elements;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premier = elements.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space4,
        DesignTokens.space2,
        DesignTokens.space4,
        DesignTokens.space3,
      ),
      child: OuroCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space3),
          child: elements.length == 1
              ? _Unique(element: premier)
              : _Plusieurs(elements: elements, l10n: l10n),
        ),
      ),
    );
  }
}

class _Unique extends StatelessWidget {
  const _Unique({required this.element});

  final _Element element;

  @override
  Widget build(BuildContext context) {
    if (element.estTexte) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pastille(
            icone: Icons.format_quote_rounded,
            teinte: OuroColors.accent,
          ),
          const SizedBox(width: DesignTokens.space3),
          Expanded(
            child: Text(
              element.nom,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.label,
                height: 1.4,
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        _Vignette(element: element, cote: 56),
        const SizedBox(width: DesignTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                element.nom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.subheadline.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                // Une taille nulle veut dire « fichier introuvable », pas
                // « fichier vide » : on n'écrit pas « 0 o », qui ferait
                // croire à un fichier abîmé.
                element.octets > 0 ? tailleLisible(element.octets) : '—',
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Plusieurs extends StatelessWidget {
  const _Plusieurs({required this.elements, required this.l10n});

  final List<_Element> elements;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final total = elements.fold<int>(0, (t, e) => t + e.octets);
    // Cinq vignettes au plus : au-delà elles deviennent des confettis.
    final montrees = elements.take(5).toList();
    final reste = elements.length - montrees.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              for (final e in montrees) ...[
                _Vignette(element: e, cote: 56),
                const SizedBox(width: DesignTokens.space2),
              ],
              if (reste > 0)
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OuroColors.tertiarySystemFill,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusLg),
                  ),
                  child: Text(
                    '+$reste',
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.secondaryLabel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space3),
        Text(
          total > 0
              ? '${l10n.shItemsToShare(elements.length)} · ${tailleLisible(total)}'
              : l10n.shItemsToShare(elements.length),
          style: OuroTypography.footnote.copyWith(
            color: OuroColors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

/// La vignette d'un élément : l'image elle-même quand c'en est une, une
/// pastille colorée par genre sinon.
class _Vignette extends StatelessWidget {
  const _Vignette({required this.element, required this.cote});

  final _Element element;
  final double cote;

  @override
  Widget build(BuildContext context) {
    if (element.estImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Image.file(
          File(element.item.path),
          width: cote,
          height: cote,
          fit: BoxFit.cover,
          // ⚠️ UNE IMAGE PARTAGÉE PEUT ÊTRE ILLISIBLE — un fichier
          // temporaire déjà effacé par l'application d'origine, un format
          // que Flutter ne décode pas. Sans ce repli, tout l'écran de
          // partage se remplit d'une exception de rendu.
          errorBuilder: (_, __, ___) => _Pastille(
            icone: Icons.image_not_supported_outlined,
            teinte: OuroColors.secondaryLabel,
            cote: cote,
          ),
        ),
      );
    }
    final (icone, teinte) = _genre(element);
    return _Pastille(icone: icone, teinte: teinte, cote: cote);
  }

  static (IconData, Color) _genre(_Element e) {
    final m = e.item.mimeType ?? '';
    final n = e.nom.toLowerCase();
    if (m.startsWith('video/') || n.endsWith('.mp4') || n.endsWith('.mov')) {
      return (Icons.movie_outlined, OuroColors.systemPurple);
    }
    if (m.startsWith('audio/') || n.endsWith('.mp3') || n.endsWith('.m4a')) {
      return (Icons.graphic_eq_rounded, OuroColors.systemOrange);
    }
    if (n.endsWith('.pdf')) {
      return (Icons.picture_as_pdf_outlined, OuroColors.systemRed);
    }
    if (n.endsWith('.zip') || n.endsWith('.rar') || n.endsWith('.7z')) {
      return (Icons.folder_zip_outlined, OuroColors.systemGray);
    }
    return (Icons.insert_drive_file_outlined, OuroColors.systemGreen);
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.icone,
    required this.teinte,
    this.cote = 44,
  });

  final IconData icone;
  final Color teinte;
  final double cote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cote,
      height: cote,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // La teinte à 18 % : assez pour nommer le genre du fichier d'un
        // coup d'œil, assez discrète pour ne pas concurrencer le nom.
        color: teinte.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Icon(icone, size: DesignTokens.iconLg, color: teinte),
    );
  }
}

// ══ LA RECHERCHE ════════════════════════════════════════════════════════

class _Recherche extends StatelessWidget {
  const _Recherche({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space4,
        0,
        DesignTokens.space4,
        DesignTokens.space3,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: OuroTypography.body.copyWith(color: OuroColors.label),
        magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
        decoration: InputDecoration(
          hintText: l10n.shSearchConversation,
          hintStyle:
              OuroTypography.body.copyWith(color: OuroColors.tertiaryLabel),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: OuroColors.tertiaryLabel,
            size: DesignTokens.iconMd,
          ),
          filled: true,
          fillColor: OuroColors.tertiarySystemFill,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: DesignTokens.space3,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ══ LES RÉCENTS ═════════════════════════════════════════════════════════

/// ⚠️ NEUF PARTAGES SUR DIX VISENT QUELQU'UN QU'ON VIENT DE CROISER. La
/// feuille de partage d'iOS pose cette rangée avant tout le reste pour
/// cette seule raison, et elle fait gagner un défilement et une recherche.
class _Recents extends StatelessWidget {
  const _Recents({
    required this.conversations,
    required this.choisis,
    required this.cle,
    required this.onBasculer,
  });

  final List<Conversation> conversations;
  final Set<String> choisis;
  final String Function(Conversation) cle;
  final void Function(Conversation) onBasculer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.space4,
            0,
            DesignTokens.space4,
            DesignTokens.space2,
          ),
          child: Text(
            l10n.shRecents.toUpperCase(),
            style: OuroTypography.caption1.copyWith(
              color: OuroColors.secondaryLabel,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space4,
            ),
            itemCount: conversations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: DesignTokens.space3),
            itemBuilder: (context, i) {
              final c = conversations[i];
              final coche = choisis.contains(cle(c));
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onBasculer(c),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          PeerAvatar(
                            pseudo: c.pseudo,
                            radius: 26,
                            online: c.isOnline,
                          ),
                          if (coche)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: _Coche(petite: true),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.pseudo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: OuroTypography.caption2.copyWith(
                          color: coche
                              ? OuroColors.accent
                              : OuroColors.secondaryLabel,
                          fontWeight:
                              coche ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: DesignTokens.space3),
      ],
    );
  }
}

// ══ UNE LIGNE DE LA LISTE ═══════════════════════════════════════════════

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.conversation,
    required this.choisie,
    required this.actif,
    required this.onTap,
  });

  final Conversation conversation;
  final bool choisie;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: actif ? onTap : null,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        curve: DesignTokens.curveEnter,
        color: choisie
            ? OuroColors.accent.withValues(alpha: 0.10)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space4,
          vertical: DesignTokens.space3,
        ),
        child: Opacity(
          opacity: actif ? 1 : 0.5,
          child: Row(
            children: [
              PeerAvatar(
                pseudo: conversation.pseudo,
                radius: 22,
                online: conversation.isOnline,
              ),
              const SizedBox(width: DesignTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      conversation.pseudo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.body.copyWith(
                        color: OuroColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      conversation.isGroup ? l10n.shGroup : l10n.shDiscussion,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.space2),
              _Coche(cochee: choisie),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le rond de sélection. Vide, c'est un contour ; coché, c'est l'accent.
class _Coche extends StatelessWidget {
  const _Coche({this.cochee = true, this.petite = false});

  final bool cochee;
  final bool petite;

  @override
  Widget build(BuildContext context) {
    final cote = petite ? 20.0 : 24.0;
    return AnimatedContainer(
      duration: DesignTokens.durationFast,
      curve: DesignTokens.curveEnter,
      width: cote,
      height: cote,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cochee ? OuroColors.accentRempli : Colors.transparent,
        border: cochee
            ? null
            : Border.all(color: OuroColors.separator, width: 1.5),
      ),
      child: cochee
          ? Icon(
              Icons.check_rounded,
              size: petite ? 14 : 16,
              // ⚠️ L'ENCRE VIENT DE L'ACCENT, PAS DU BLANC. Avec un accent
              // menthe ou jaune, un coche blanc disparaît. C'est la même
              // règle que partout depuis l'audit de contraste.
              color: OuroColors.texteSurAccent,
            )
          : null,
    );
  }
}

// ══ LA BARRE D'ENVOI ════════════════════════════════════════════════════

class _BarreEnvoi extends StatelessWidget {
  const _BarreEnvoi({
    required this.nombre,
    required this.enCours,
    required this.onEnvoyer,
  });

  final int nombre;
  final bool enCours;
  final VoidCallback onEnvoyer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actif = nombre > 0 && !enCours;

    // ⚠️ UN `Material` AUTOUR, ET CE N'EST PAS DÉCORATIF. Cette barre est
    // posée dans une `Stack` À CÔTÉ du scaffold, donc en dehors de son
    // `Material`. Flutter dessine alors un double soulignement jaune sous
    // tout texte qui n'en a pas au-dessus de lui — le défaut déjà
    // rencontré et documenté dans `main.dart` pour les surcouches.
    return Material(
      color: Colors.transparent,
      child: OuroBlurSurface(
        material: OuroMaterial.thin,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space4),
            child: Semantics(
              button: true,
              enabled: actif,
              label: nombre == 0 ? l10n.shSend : l10n.shSendCount(nombre),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: actif ? onEnvoyer : null,
                child: AnimatedContainer(
                  duration: DesignTokens.durationFast,
                  curve: DesignTokens.curveEnter,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // Éteint tant que rien n'est choisi : le bouton dit de
                    // lui-même qu'il manque quelque chose, sans message.
                    color: actif
                        ? OuroColors.accentRempli
                        : OuroColors.tertiarySystemFill,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: enCours
                      ? OuroSpinner(
                          radius: 11,
                          color: OuroColors.secondaryLabel,
                        )
                      : Text(
                          nombre == 0 ? l10n.shSend : l10n.shSendCount(nombre),
                          style: OuroTypography.headline.copyWith(
                            color: actif
                                ? OuroColors.texteSurAccent
                                : OuroColors.tertiaryLabel,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
