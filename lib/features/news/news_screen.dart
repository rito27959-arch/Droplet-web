import 'dart:io';

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'onglet ACTUS — la page officielle des statuts de Droplet.
//
// Un « statut », c'est un petit message qu'on publie non pas à quelqu'un
// en particulier, mais à TOUT le réseau autour de soi, et qui s'efface
// tout seul au bout de 24 heures. « Je suis au gymnase, il y a de l'eau
// potable », « le pont est coupé » : dans les situations où Droplet sert
// vraiment, c'est souvent l'information la plus utile de l'app.
//
// CE QUI A CHANGÉ : cet onglet s'appelait « Chaîne » et affichait de
// FAUSSES publications — de fausses vignettes vidéo, un faux « il y a
// 2h », de faux compteurs de « 24 j'aime », fabriqués à partir de la
// liste des pairs connectés. Rien de tout cela n'existait : c'était une
// maquette laissée dans l'app finie. Des chiffres inventés dans une app
// dont le but est de transmettre de l'information fiable en situation
// d'urgence, c'est le pire endroit possible pour du décor.
//
// La page montre désormais uniquement de vraies données : mon statut du
// moment (et qui l'a vu), et les statuts réellement reçus des autres par
// le mesh.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mesh_message.dart';
import '../../core/models/status_media.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../status/ordre_statuts.dart';
import '../status/status_composer.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../l10n/generated/app_localizations.dart';
import '../status/status_pager_screen.dart';
import '../status/anneau_statuts.dart';
import '../../core/services/etat_connexion.dart';
import '../../core/services/presence_internet.dart';
import '../../core/services/mesh_transport_service.dart';
import '../../core/providers/internet_provider.dart';
import '../../core/repositories/mesh_repository.dart';
import '../../core/services/avatar_service.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // On observe les pairs pour que la page se redessine quand le réseau
    // bouge : un nouveau pair rencontré, ce sont potentiellement de
    // nouveaux statuts qui arrivent dans la foulée.
    ref.watch(meshPeerListProvider);

    final myId = ref.watch(meshRepositoryProvider).myId;
    final active = StorageService.getActiveStatuses();

    // Un auteur = un seul statut affiché, le plus récent. Sans ce filtre,
    // quelqu'un qui publie trois fois dans la journée occuperait trois
    // lignes et repousserait tous les autres vers le bas.
    final latestByAuthor = <String, MeshStatusRecord>{};
    for (final s in active) {
      if (StorageService.isContactBlocked(s.authorId)) continue;
      latestByAuthor.putIfAbsent(s.authorId, () => s);
    }

    final mine = latestByAuthor[myId];
    final others = latestByAuthor.values
        .where((s) => s.authorId != myId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return OuroLargeTitleScaffold(
      title: l10n.nwTitle,
      subtitle: others.isEmpty
          ? l10n.nwStatusesNetwork24h
          : l10n.nwStatusesCount(others.length),
      backgroundColor: OuroColors.systemGroupedBackground,
      actions: [
        OuroBarButton(
          icon: Icons.edit_square,
          tooltip: l10n.nwPublishStatus,
          onPressed: _composeStatus,
        ),
      ],
      // Tirer vers le bas relance une diffusion de mes annonces vers les
      // pairs actuellement à portée : c'est le geste « réessaie de me
      // faire entendre », utile quand on vient de croiser du monde.
      onRefresh: () async {
        await ref.read(meshRepositoryProvider).regossipAnnouncements();
        if (mounted) setState(() {});
      },
      slivers: [
        // ── LE CARROUSEL DE WHATSAPP ────────────────────────────────────
        //
        // Depuis 2024, WhatsApp ne montre plus les statuts en liste : une
        // rangée de cartes verticales, chacune avec l'aperçu du dernier
        // statut, l'avatar dans son anneau et le nom en bas. La mienne en
        // premier, puis ceux qui ont du nouveau, puis les déjà vus.
        SliverToBoxAdapter(
          child: _CarrouselStatuts(
            mien: mine,
            monId: myId,
            onComposer: _composeStatus,
          ),
        ),

        if (others.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: EmptyState(
                emoji: Scenes.aucuneActualite,
                icon: Icons.podcasts_rounded,
                title: l10n.nwNoNewsYet,
                subtitle: l10n.nwStatusesAppearHere,
              ),
            ),
          )
        else ...[
          // Sous le carrousel, une ligne par personne : le dernier statut,
          // l'heure, et PAR OÙ on la joint. Aucune app à serveur ne peut
          // écrire cette dernière colonne.
          SliverToBoxAdapter(child: _ListeStatuts(monId: myId)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                12,
                DesignTokens.screenMargin,
                DesignTokens.space6,
              ),
              child: Text(
                l10n.nwStatusExpires,
                style: OuroTypography.footnote
                    .copyWith(color: OuroColors.tertiaryLabel),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Publication ───────────────────────────────────────────────────

  Future<void> _composeStatus() async {
    // La feuille de saisie et la publication vivent dans
    // `status_composer.dart` : c'est exactement le même geste depuis le
    // menu « + » des Discussions, il ne doit donc exister qu'une seule
    // version de cet écran.
    final published = await composeStatus(context, ref);
    if (published && mounted) setState(() {});
  }
}

/// Ce qu'on écrit à la place de la légende quand un statut n'en a pas.
///
/// Un statut fait d'une seule photo n'a rien à afficher en texte : sans
/// ce repli, sa ligne apparaîtrait vide, comme si le statut était vide
/// lui aussi.

/// La petite vignette carrée au bout d'une ligne, qui dit d'un coup
/// d'œil ce que contient le statut.
// ─────────────────────────────────────────────────────────────
//  MON STATUT
// ─────────────────────────────────────────────────────────────

/// La carte du haut : ce que j'ai publié, ou l'invitation à publier.
///
/// Elle est plus grande que les lignes du dessous parce qu'elle répond à
/// deux questions différentes qu'on se pose en arrivant ici : « qu'est-ce
/// que j'ai dit ? » et surtout « est-ce que ça a été reçu ? ».
// ─────────────────────────────────────────────────────────────
//  STATUT D'UN AUTRE
// ─────────────────────────────────────────────────────────────

/// L'anneau coloré autour de l'avatar qui signale « cette personne a
/// quelque chose à montrer » — la convention est comprise de tous depuis
/// les stories, inutile d'en inventer une autre.

// ─────────────────────────────────────────────────────────────

/// « il y a 5 min », « il y a 3 h »… Au-delà de 24 h le statut a expiré,
/// donc aucun format en jours n'est nécessaire ici.

// ─────────────────────────────────────────────────────────────
//  LE CARROUSEL DES STATUTS
// ─────────────────────────────────────────────────────────────

class _CarrouselStatuts extends StatelessWidget {
  const _CarrouselStatuts({
    required this.mien,
    required this.monId,
    required this.onComposer,
  });

  final MeshStatusRecord? mien;
  final String monId;
  final VoidCallback onComposer;

  @override
  Widget build(BuildContext context) {
    // Se redessine dès qu'un statut est vu : l'anneau passe au gris sans
    // attendre un autre rafraîchissement de l'onglet.
    return ValueListenableBuilder<int>(
      valueListenable: StatutsVus.revision,
      builder: (context, _, _) => _contenu(context),
    );
  }

  Widget _contenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parContact = statutsParContact(monId);
    final ordre = ordreDesContacts(monId);
    // Les statuts déjà vus passent derrière une borne : on ne les mélange
    // pas aux nouveaux, et on ne les cache pas non plus.
    final premierVu = ordre.indexWhere(
      (c) => StatutsVus.contactVu(parContact[c]!),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.screenMargin),
            itemCount: 1 + ordre.length + (premierVu > 0 ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _CarteStatut(
                  statut: mien,
                  nom: mien == null ? l10n.nwAddStatus : l10n.nwMyStatus,
                  pseudoAvatar: 'Moi',
                  // La mienne ne vient pas du même endroit : elle est
                  // rangée sous le nom gardé en base, pas sous un
                  // identifiant de pair.
                  photo: AvatarService.chemin(
                    StorageService.currentUser?.avatarUrl,
                  ),
                  vu: false,
                  ajout: true,
                  onTap: () {
                    OuroHaptics.selection();
                    if (mien == null) {
                      onComposer();
                    } else {
                      _OuvrirStatut.ouvrir(context, monId);
                    }
                  },
                  onAjout: () {
                    OuroHaptics.selection();
                    onComposer();
                  },
                );
              }
              // La borne des « vus » s'intercale juste avant le premier
              // statut déjà regardé.
              final borne = premierVu > 0 && i == premierVu + 1;
              if (borne) return _BorneVus(libelle: l10n.nwSeenSection);
              final contact = ordre[i - 1 - (premierVu > 0 && i > premierVu ? 1 : 0)];
              final statuts = parContact[contact]!;
              final dernier = statuts.last;
              return _CarteStatut(
                segments: [
                  for (final s in statuts) StatutsVus.estVu(s.id),
                ],
                statut: dernier,
                nom: dernier.authorPseudo,
                pseudoAvatar: dernier.authorPseudo,
                photo: AvatarService.cheminPair(dernier.authorId),
                vu: StatutsVus.contactVu(statuts),
                onTap: () {
                  OuroHaptics.selection();
                  _OuvrirStatut.ouvrir(context, contact);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Ouvrir le lecteur depuis l'onglet : une nouvelle séance commence, et le
/// lecteur saura revenir ici en se fermant.
class _OuvrirStatut {
  _OuvrirStatut._();

  static void ouvrir(BuildContext context, String auteur) {
    statutsSeanceReinitialiser(origine: GoRouterState.of(context).uri.toString());
    // Posé par-dessus les onglets, pour s'ouvrir en zoom depuis la carte
    // et laisser la liste derrière pendant le glissé vers le bas.
    context.push('/status/$auteur');
  }
}

/// Une carte : l'aperçu du dernier statut, l'avatar dans son anneau, le nom.
class _CarteStatut extends StatefulWidget {
  const _CarteStatut({
    required this.statut,
    required this.nom,
    required this.pseudoAvatar,
    this.photo,
    required this.vu,
    this.segments = const [],
    required this.onTap,
    this.ajout = false,
    this.onAjout,
  });

  final MeshStatusRecord? statut;
  final String nom;
  final String pseudoAvatar;

  /// ⚠️ LE CHEMIN DE LA PHOTO, PAS LA PHOTO. `PeerAvatar` ne va PAS la
  /// chercher tout seul : il affiche ce qu'on lui donne, et retombe sur
  /// l'initiale quand on ne lui donne rien. C'est pour ça que la liste
  /// « Reçus » plus bas montrait un visage et la vignette du haut une
  /// lettre, pour la même personne, sur le même écran.
  final String? photo;
  final bool vu;

  /// Un booléen par statut de ce contact : `true` = déjà vu. L'anneau se
  /// découpe en autant d'arcs.
  final List<bool> segments;

  final bool ajout;
  final VoidCallback onTap;
  final VoidCallback? onAjout;

  @override
  State<_CarteStatut> createState() => _CarteStatutState();
}

class _CarteStatutState extends State<_CarteStatut> {
  bool _appui = false;

  /// La position de la carte à l'écran, pour que le lecteur se referme
  /// dessus. Hors écran (carrousel défilé) : pas de zoom, un simple fondu.
  Rect? _rectActuel() {
    if (!mounted) return null;
    final boite = context.findRenderObject() as RenderBox?;
    if (boite == null || !boite.attached || !boite.hasSize) return null;
    final r = boite.localToGlobal(Offset.zero) & boite.size;
    final ecran = Offset.zero & MediaQuery.sizeOf(context);
    return ecran.overlaps(r) ? r : null;
  }

  String? get _auteur => widget.statut?.authorId;

  @override
  void dispose() {
    final auteur = _auteur;
    if (auteur != null && StatusPagerScreen.rectsCartes[auteur] == _rectActuel) {
      StatusPagerScreen.rectsCartes.remove(auteur);
    }
    super.dispose();
  }
  Future<String?>? _photo;
  String? _idPhoto;

  Future<String?>? _cheminPhoto(StatusMedia media, String id) {
    if (media.kind != StatusMediaKind.photo ||
        media.fileId == null ||
        media.fileName == null) {
      return null;
    }
    if (_idPhoto != id) {
      _idPhoto = id;
      _photo = StorageService.getSharedFilePath(media.fileId!, media.fileName!);
    }
    return _photo;
  }

  Widget _apercu(MeshStatusRecord? statut) {
    if (statut == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              OuroColors.accent.withValues(alpha: 0.35),
              OuroColors.accent.withValues(alpha: 0.12),
            ],
          ),
        ),
      );
    }
    final media = StorageService.getStatusMedia(statut.id);
    final choisie = media.backgroundColor != null
        ? Color(media.backgroundColor!)
        : OuroColors.accent;
    // Deux statuts composés avec la même couleur se lisent comme un seul
    // bloc. On décale la teinte d'un cheveu selon l'auteur — assez pour
    // séparer les cartes, trop peu pour trahir la couleur choisie.
    final hsl = HSLColor.fromColor(choisie);
    final decalage = (statut.authorId.hashCode % 5 - 2) * 5.0;
    final fond = hsl
        .withHue((hsl.hue + decalage) % 360)
        .toColor();
    final photo = _cheminPhoto(media, statut.id);
    return switch (media.kind) {
      StatusMediaKind.photo when photo != null => Stack(
          fit: StackFit.expand,
          children: [
            _Fond(couleur: fond, icone: Icons.photo_rounded),
            FutureBuilder<String?>(
              future: photo,
              builder: (context, instantane) {
                final chemin = instantane.data;
                if (chemin == null) return const SizedBox.shrink();
                return Image.file(
                  File(chemin),
                  fit: BoxFit.cover,
                  cacheWidth: 260,
                  // La photo apparaît en fondu, comme partout sur iOS, au
                  // lieu de surgir d'un coup.
                  frameBuilder: (context, child, image, synchrone) {
                    if (synchrone) return child;
                    return AnimatedOpacity(
                      opacity: image == null ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      StatusMediaKind.video => const _Fond(couleur: Color(0xFF1C1C22), icone: Icons.play_arrow_rounded),
      StatusMediaKind.voice => _Fond(couleur: OuroColors.systemOrange, icone: Icons.mic_rounded),
      _ => Container(
          color: fond,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(8, 34, 8, 30),
          child: Text(
            statut.content.trim(),
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              // Blanc sur fond clair, on ne lit rien : la couleur du texte
              // suit la luminance du fond, pas une habitude.
              color: fond.computeLuminance() > 0.55
                  ? const Color(0xFF14141A)
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statut = widget.statut;
    final nouveau = statut != null && !widget.vu && !widget.ajout;
    if (statut != null) StatusPagerScreen.rectsCartes[statut.authorId] = _rectActuel;

    final carte = GestureDetector(
      onTap: () {
        final boite = context.findRenderObject() as RenderBox?;
        StatusPagerScreen.rectCarte = boite != null && boite.hasSize
            ? boite.localToGlobal(Offset.zero) & boite.size
            : null;
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      child: AnimatedScale(
        scale: _appui ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 106,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _apercu(statut),
                // Le voile qui garde le nom lisible sur n'importe quelle photo.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.3, 0.62, 1],
                      colors: [
                        Color(0x33000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 7,
                  top: 7,
                  child: AnneauStatuts(
                    // Un arc par statut : on voit d'un coup combien il en
                    // reste à regarder, sans ouvrir.
                    // Le mien n'a rien à me faire voir : anneau neutre.
                    segments: statut == null
                        ? const []
                        : (widget.ajout
                            ? const [true]
                            : (widget.segments.isEmpty
                                ? [widget.vu]
                                : widget.segments)),
                    epaisseur: 2,
                    ecart: 2.5,
                    couleurVu: const Color(0xB3FFFFFF),
                    child: PeerAvatar(
                      pseudo: widget.pseudoAvatar,
                      radius: 14,
                      imagePath: widget.photo,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 8,
                  end: 8,
                  bottom: 8,
                  child: Text(
                    widget.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.footnote.copyWith(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                if (widget.ajout)
                  // Un badge de 20 pt, mais une cible de 44 pt : le minimum
                  // d'Apple pour un doigt.
                  PositionedDirectional(
                    start: 20,
                    // La pastille se pose en bas à droite de l'avatar, comme le
                    // badge d'appareil photo d'iOS : sur l'anneau, elle masquait
                    // justement ce qu'il faut voir.
                    top: 20,
                    child: Semantics(
                      button: true,
                      label: l10n.nwAddStatus,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onAjout,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: OuroColors.accentRempli,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.add_rounded, size: 13, color: OuroColors.texteSurAccent),
                            ),
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

    return Semantics(
      button: true,
      label: nouveau ? '${widget.nom}, ${l10n.nwStatusNewA11y}' : widget.nom,
      // Ma carte garde son bouton « + » accessible à VoiceOver.
      excludeSemantics: !widget.ajout,
      child: carte,
    );
  }
}

class _Fond extends StatelessWidget {
  const _Fond({required this.couleur, required this.icone});

  final Color couleur;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, Color.lerp(couleur, Colors.black, 0.35)!],
        ),
      ),
      child: Center(child: Icon(icone, color: Colors.white70, size: 26)),
    );
  }
}

/// L'anneau de WhatsApp : couleur d'accent tant qu'il y a du nouveau, gris
/// une fois tout vu, absent quand il n'y a rien à voir.
class _Anneau extends StatelessWidget {
  const _Anneau({required this.vu, required this.actif, required this.child});

  final bool vu;
  final bool actif;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!actif) return child;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: vu ? const Color(0xB3FFFFFF) : OuroColors.accent,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: child,
      ),
    );
  }
}

/// La borne entre les statuts neufs et ceux déjà vus.
///
/// Un mot et un filet, à la hauteur des cartes : assez pour marquer la
/// frontière, assez discret pour ne pas couper le geste de défilement.
class _BorneVus extends StatelessWidget {
  const _BorneVus({required this.libelle});

  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            libelle.toUpperCase(),
            style: OuroTypography.caption2.copyWith(
              color: OuroColors.tertiaryLabel,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 1,
            height: 84,
            color: OuroColors.separator,
          ),
        ],
      ),
    );
  }
}

/// La liste verticale des statuts reçus.
///
/// Le carrousel montre les visages ; la liste dit le reste : qui a publié,
/// quand, et PAR OÙ on joindrait la personne maintenant. C'est cette
/// dernière colonne qui n'existe nulle part ailleurs — chez les apps à
/// serveur, il n'y a qu'un chemin, donc rien à dire.
class _ListeStatuts extends ConsumerWidget {
  const _ListeStatuts({required this.monId});

  final String monId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final parContact = statutsParContact(monId);
    final ordre = ordreDesContacts(monId);
    if (ordre.isEmpty) return const SizedBox.shrink();

    final pairs = ref.watch(meshPeerListProvider);
    final internet = ref.watch(internetDisponibleProvider);
    final repo = ref.watch(meshRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.screenMargin,
        DesignTokens.space5,
        DesignTokens.screenMargin,
        0,
      ),
      child: OuroListSection(
        header: l10n.nwReceivedHeader,
        separatorInset: 64,
        children: [
          for (final contact in ordre)
            _LigneStatut(
              statuts: parContact[contact]!,
              chemin: _chemin(contact, pairs, internet, repo),
              sauts: _sauts(contact, pairs),
              onTap: () {
                OuroHaptics.selection();
                _OuvrirStatut.ouvrir(context, contact);
              },
            ),
        ],
      ),
    );
  }

  static ConnectedPeer? _pair(String id, List<ConnectedPeer> pairs) {
    for (final p in pairs) {
      if (p.peerId == id) return p;
    }
    return null;
  }

  static int _sauts(String id, List<ConnectedPeer> pairs) =>
      _pair(id, pairs)?.hopCount ?? 0;

  static CheminPair _chemin(
    String id,
    List<ConnectedPeer> pairs,
    bool internet,
    MeshRepository repo,
  ) {
    final p = _pair(id, pairs);
    return cheminVersPair(
      dansMesh: p != null,
      sauts: p?.hopCount ?? 0,
      reconnexion: p?.reconnecting ?? false,
      internet: internet,
      contactEnLigneSeul: PresenceInternet.enLigne(id),
      cleConnue: repo.clePubliqueConnue(id),
    );
  }
}

class _LigneStatut extends StatefulWidget {
  const _LigneStatut({
    required this.statuts,
    required this.chemin,
    required this.sauts,
    required this.onTap,
  });

  final List<MeshStatusRecord> statuts;
  final CheminPair chemin;
  final int sauts;
  final VoidCallback onTap;

  @override
  State<_LigneStatut> createState() => _LigneStatutState();
}

class _LigneStatutState extends State<_LigneStatut> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dernier = widget.statuts.last;
    final segments = [for (final s in widget.statuts) StatutsVus.estVu(s.id)];
    final restants = segments.where((v) => !v).length;
    final (couleur, chemin) = switch (widget.chemin) {
      CheminPair.proche || CheminPair.procheEtInternet => (
          OuroColors.accent,
          l10n.cvNearby,
        ),
      CheminPair.relais || CheminPair.relaisEtInternet => (
          OuroColors.accent,
          l10n.cvHops(widget.sauts),
        ),
      CheminPair.internet || CheminPair.tor => (
          OuroColors.successGreen,
          l10n.cvInternet,
        ),
      CheminPair.reconnexion || CheminPair.attenteInternet => (
          OuroColors.warningAmber,
          l10n.cvWaiting,
        ),
      CheminPair.horsPortee => (OuroColors.tertiaryLabel, l10n.cvOutOfReach),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      child: Container(
        color: _appui
            ? OuroColors.systemFill
            : OuroColors.secondarySystemGroupedBackground,
        padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
        child: Row(
          children: [
            AnneauStatuts(
              segments: segments,
              epaisseur: 2,
              ecart: 2.5,
              child: PeerAvatar(
                pseudo: dernier.authorPseudo,
                radius: 19,
                imagePath: AvatarService.cheminPair(dernier.authorId),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dernier.authorPseudo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight:
                          restants > 0 ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: couleur,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        chemin,
                        style: OuroTypography.caption1.copyWith(color: couleur),
                      ),
                      Text(
                        '  ·  ${formatMessageTime(dernier.createdAt, langue: Localizations.localeOf(context).toLanguageTag(), hier: l10n.chYesterday)}',
                        style: OuroTypography.caption1
                            .copyWith(color: OuroColors.tertiaryLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (restants > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: OuroColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$restants',
                  style: OuroTypography.caption1.copyWith(
                    color: OuroColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
