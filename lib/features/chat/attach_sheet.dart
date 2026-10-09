// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE PANNEAU QUI S'OUVRE QUAND ON APPUIE SUR LE TROMBONE — la galerie en
// grille, à sélection multiple, et les autres sources en bas.
//
// ── ⚠️ CE QUE FAISAIT LA VERSION PRÉCÉDENTE, ET CE QUI MANQUAIT ───────
//
// Une rangée de cinq pastilles (Galerie, Document, Sticker, Position,
// Sondage) et, dessous, une BANDE HORIZONTALE de photos récentes. C'était
// correct, et deux choses y manquaient, toutes deux liées :
//
//   • ON NE VOYAIT QUE SIX PHOTOS. Au-delà, il fallait appuyer sur
//     « Galerie », quitter l'application, traverser le sélecteur système
//     et revenir. Pour la septième photo de la pellicule.
//   • ON NE POUVAIT EN ENVOYER QU'UNE. Trois photos d'affilée, c'était
//     trois fois tout le parcours.
//
// Les messageries ont toutes convergé vers la même réponse — Telegram,
// WhatsApp, iMessage : une GRILLE à l'intérieur du panneau, qu'on fait
// défiler, où l'on coche ce qu'on veut, et un seul envoi à la fin. Les
// autres sources descendent dans une barre d'onglets, en bas, là où le
// pouce est déjà.
//
// ── ⚠️ CE PANNEAU NE PROPOSE QUE CE QUI EXISTE VRAIMENT ───────────────
//
// C'est une règle, pas une limitation subie. Il serait facile d'aligner
// ici « Appareil photo », « Contact », « Musique » pour faire riche — et
// de livrer une interface qui promet ce que l'application ne sait pas
// faire. Chaque entrée correspond à un chemin de code réellement
// implémenté.
// ============================================================================

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Ce que l'utilisateur a choisi dans le panneau.
enum AttachChoice {
  /// Une photo ou une vidéo de la galerie.
  media,

  /// N'importe quel fichier.
  document,

  /// Sa position actuelle.
  position,

  /// Un sticker animé ou un emoji.
  sticker,

  /// Un sondage — une question et ses options, ouvertes au vote.
  poll,
}

/// Le filtre à passer à `file_picker` pour ce choix.
///
/// Renvoie `null` quand le choix n'ouvre pas de sélecteur de fichier.
FileType? fileTypePour(AttachChoice choix) => switch (choix) {
      AttachChoice.media => FileType.media,
      AttachChoice.document => FileType.any,
      _ => null,
    };

/// Ce que le panneau a rapporté.
class AttachResult {
  const AttachResult.choix(this.choix) : assets = const [];
  const AttachResult.medias(this.assets) : choix = null;

  final AttachChoice? choix;

  /// Les médias cochés dans la grille, dans l'ordre où ils l'ont été.
  ///
  /// ⚠️ UNE LISTE, PLUS UN SEUL. L'ancienne version ne rendait qu'un
  /// `AssetEntity` : envoyer trois photos demandait de refaire trois fois
  /// tout le parcours.
  final List<AssetEntity> assets;
}

/// Ouvre le panneau et renvoie ce qui a été choisi, ou `null`.
Future<AttachResult?> pickAttachment(BuildContext context) {
  OuroHaptics.selection();
  return showModalBottomSheet<AttachResult>(
    context: context,
    backgroundColor: Colors.transparent,
    // ── ⚠️ LE VOILE DERRIÈRE LA FEUILLE ────────────────────────────
    //
    // Flutter assombrit par défaut tout ce qui se trouve derrière une
    // feuille modale, à 54 % de noir. Sur une feuille OPAQUE, cela ne se
    // voit pas. Sur une feuille en verre, c'est fatal : le verre ne
    // transmet plus que du gris, et le panneau ressemble à du carton
    // quelle que soit la finesse du matériau qu'on lui donne.
    barrierColor: Colors.black.withValues(alpha: 0.18),
    isScrollControlled: true,
    builder: (context) => const _AttachSheet(),
  );
}

class _AttachSheet extends StatefulWidget {
  const _AttachSheet();

  @override
  State<_AttachSheet> createState() => _AttachSheetState();
}

class _AttachSheetState extends State<_AttachSheet> {
  /// Combien de médias on charge d'un coup.
  ///
  /// ⚠️ PAS TOUTE LA PELLICULE. Une photothèque de dix mille éléments
  /// mettrait plusieurs secondes à s'énumérer et autant de vignettes en
  /// mémoire — pour un panneau qu'on referme au bout de trois secondes.
  /// On charge une page, et la suivante quand le défilement approche du
  /// bas.
  static const int _parPage = 60;

  final _controleur = ScrollController();

  /// ⚠️ LE CACHE EST TENU PAR LA FEUILLE, PAS PAR LA VIGNETTE. Une case
  /// de grille est détruite dès qu'elle sort de l'écran : sans ce cache,
  /// remonter de deux écrans redemanderait au système de réextraire
  /// chaque vignette qu'on vient de voir.
  final Map<String, Uint8List> _cache = {};

  List<AssetEntity> _medias = const [];
  final List<AssetEntity> _choisis = [];
  bool _refuse = false;
  bool _charge = false;
  bool _fini = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controleur.addListener(_auDefilement);
    _chargerPage();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  void _auDefilement() {
    if (!_controleur.hasClients || _charge || _fini) return;
    final p = _controleur.position;
    // Deux écrans d'avance : la page suivante est prête avant qu'on
    // n'atteigne le bas, donc on ne voit jamais de trou.
    if (p.pixels > p.maxScrollExtent - p.viewportDimension * 2) {
      _chargerPage();
    }
  }

  Future<void> _chargerPage() async {
    if (_charge || _fini) return;
    _charge = true;
    try {
      // `requestPermissionExtend` gère à lui seul les trois réponses
      // possibles d'Android 14+ : tout, une sélection limitée, ou rien.
      final etat = await PhotoManager.requestPermissionExtend();
      if (!etat.hasAccess) {
        if (mounted) setState(() => _refuse = true);
        return;
      }
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common, // images ET vidéos
        onlyAll: true,
      );
      if (albums.isEmpty) {
        if (mounted) setState(() => _refuse = true);
        return;
      }
      final lot = await albums.first.getAssetListPaged(
        page: _page,
        size: _parPage,
      );
      if (!mounted) return;
      setState(() {
        _medias = [..._medias, ...lot];
        _page++;
        // Une page incomplète : c'est la fin de la pellicule.
        _fini = lot.length < _parPage;
      });
    } catch (e) {
      // Photothèque illisible, plateforme sans galerie : la grille
      // s'efface, les autres sources continuent de marcher.
      debugPrint('[Pièces jointes] photothèque indisponible: $e');
      if (mounted) setState(() => _refuse = true);
    } finally {
      _charge = false;
    }
  }

  void _basculer(AssetEntity a) {
    OuroHaptics.selection();
    setState(() {
      final i = _choisis.indexWhere((x) => x.id == a.id);
      if (i >= 0) {
        _choisis.removeAt(i);
      } else {
        _choisis.add(a);
      }
    });
  }

  void _envoyer() {
    if (_choisis.isEmpty) return;
    OuroHaptics.medium();
    Navigator.of(context).pop(AttachResult.medias(List.of(_choisis)));
  }

  void _source(AttachChoice c) {
    OuroHaptics.selection();
    Navigator.of(context).pop(AttachResult.choix(c));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // ⚠️ 62 % DE L'ÉCRAN, PAS PLUS. Le panneau doit laisser voir la
    // conversation derrière : c'est elle qui dit à qui l'on envoie, et un
    // panneau plein écran fait perdre ce repère au moment précis où il
    // compte. Telegram s'arrête à peu près là, et on peut le tirer plus
    // haut si l'on cherche une vieille photo.
    final hauteur = media.size.height * 0.62;

    return FrostedSheet(
      // ⚠️ `thin` ET NON `regular`. Avec le voile épais par défaut (80 %
      // d'opacité), le panneau ressemblait à une dalle grise posée sur
      // l'écran. Allégé, la conversation transparaît réellement — et
      // c'est cette transparence, plus que la couleur, qui distingue le
      // verre du carton.
      material: OuroMaterial.thin,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: hauteur,
        child: Column(
          children: [
            // ⚠️ PAS DE POIGNÉE ICI. `FrostedSheet` en dessine déjà une
            // (`showGrabber`, vrai par défaut, aux dimensions exactes
            // d'iOS). En ajouter une seconde en empilait deux, à deux
            // points d'écart — le genre de détail qu'on ne nomme pas en
            // le voyant mais qui fait dire « c'est mal fini ».
            Expanded(
              child: _refuse
                  // Une pellicule vide n'est pas un chargement : sans ce
                  // cas, la roue tournait indéfiniment sur un téléphone
                  // sans photo, et le panneau paraissait cassé.
                  ? const _PasDacces()
                  : _medias.isEmpty
                      ? (_fini
                          ? const _PasDacces(vide: true)
                          : const Center(child: OuroSpinner(radius: 12)))
                      : _Grille(
                          controleur: _controleur,
                          medias: _medias,
                          choisis: _choisis,
                          cache: _cache,
                          onBasculer: _basculer,
                        ),
            ),
            // ⚠️ LE FILET AU-DESSUS DU BAS DE FEUILLE N'EST PAS DÉCORATIF.
            // La grille se termine toujours sur une rangée COUPÉE — c'est
            // elle qui dit qu'il y a autre chose en dessous. Sans ce
            // trait, cette rangée tronquée et la barre se touchaient, et
            // l'ensemble se lisait comme une bouillie de rectangles.
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: OuroColors.separator, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: _choisis.isEmpty
                    ? _BarreSources(onSource: _source)
                    : _BarreEnvoi(nombre: _choisis.length, onEnvoyer: _envoyer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ LA GRILLE ═══════════════════════════════════════════════════════════

class _Grille extends StatelessWidget {
  const _Grille({
    required this.controleur,
    required this.medias,
    required this.choisis,
    required this.cache,
    required this.onBasculer,
  });

  final ScrollController controleur;
  final List<AssetEntity> medias;
  final List<AssetEntity> choisis;
  final Map<String, Uint8List> cache;
  final ValueChanged<AssetEntity> onBasculer;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controleur,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: medias.length,
      itemBuilder: (context, i) {
        final a = medias[i];
        final rang = choisis.indexWhere((x) => x.id == a.id);
        return _Vignette(
          key: ValueKey(a.id),
          asset: a,
          cache: cache,
          // Le RANG, pas un simple coché : c'est l'ordre d'envoi, et
          // c'est ce qui permet de le choisir au lieu de le subir.
          rang: rang < 0 ? null : rang + 1,
          onTap: () => onBasculer(a),
        );
      },
    );
  }
}

class _Vignette extends StatefulWidget {
  const _Vignette({
    super.key,
    required this.asset,
    required this.cache,
    required this.rang,
    required this.onTap,
  });

  final AssetEntity asset;
  final Map<String, Uint8List> cache;
  final int? rang;
  final VoidCallback onTap;

  @override
  State<_Vignette> createState() => _VignetteState();
}

class _VignetteState extends State<_Vignette> {
  Uint8List? _octets;

  @override
  void initState() {
    super.initState();
    _extraire();
  }

  Future<void> _extraire() async {
    final connue = widget.cache[widget.asset.id];
    if (connue != null) {
      _octets = connue;
      return;
    }
    try {
      // ⚠️ UNE VIGNETTE, PAS L'IMAGE. Demander l'original pour une case
      // de 140 points décode plusieurs mégaoctets par photo : la grille
      // saccade et la mémoire explose au bout de deux écrans.
      final data = await widget.asset
          .thumbnailDataWithSize(const ThumbnailSize.square(300));
      if (data == null) return;
      widget.cache[widget.asset.id] = data;
      if (mounted) setState(() => _octets = data);
    } catch (_) {
      // Une vignette illisible laisse simplement une case grise.
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final rang = widget.rang;
    final choisi = rang != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: OuroColors.tertiarySystemFill,
            child: _octets == null
                ? const SizedBox.shrink()
                : Image.memory(
                    _octets!,
                    fit: BoxFit.cover,
                    // ⚠️ Sans ces deux bornes, Flutter décode la vignette
                    // à la résolution de l'écran et la garde ainsi dans
                    // son cache — on annulerait tout le bénéfice d'avoir
                    // demandé une petite image.
                    cacheWidth: 300,
                    cacheHeight: 300,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: OuroColors.tertiaryLabel,
                      size: DesignTokens.iconLg,
                    ),
                  ),
          ),
          // La vidéo s'annonce par sa durée, en bas à gauche.
          if (asset.type == AssetType.video)
            PositionedDirectional(
              start: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _duree(asset.duration),
                  style: OuroTypography.caption2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Le voile de sélection : il assombrit la photo cochée, pour
          // qu'on voie d'un coup d'œil ce qui partira.
          if (choisi)
            ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
          PositionedDirectional(
            end: 6,
            top: 6,
            child: _Rond(rang: rang),
          ),
        ],
      ),
    );
  }

  static String _duree(int secondes) {
    final m = secondes ~/ 60;
    final s = (secondes % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Le rond de sélection : vide, c'est un contour ; coché, il porte son rang.
class _Rond extends StatelessWidget {
  const _Rond({required this.rang});

  final int? rang;

  @override
  Widget build(BuildContext context) {
    final choisi = rang != null;
    return AnimatedContainer(
      duration: DesignTokens.durationFast,
      curve: DesignTokens.curveEnter,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: choisi ? OuroColors.accentRempli : Colors.black26,
        border: Border.all(
          color: choisi ? Colors.transparent : Colors.white,
          width: 1.5,
        ),
      ),
      child: choisi
          ? Text(
              '$rang',
              style: OuroTypography.caption2.copyWith(
                // ⚠️ L'ENCRE VIENT DE L'ACCENT, PAS DU BLANC. Avec un
                // accent menthe ou jaune, un chiffre blanc disparaît.
                color: OuroColors.texteSurAccent,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

// ══ LE BAS DU PANNEAU ═══════════════════════════════════════════════════

/// Les autres sources, en onglets. Elles remplacent la rangée de pastilles
/// de l'ancienne version et descendent là où le pouce est déjà.
class _BarreSources extends StatelessWidget {
  const _BarreSources({required this.onSource});

  final ValueChanged<AttachChoice> onSource;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sources = <(AttachChoice, IconData, String)>[
      (AttachChoice.media, Icons.photo_library_rounded, l10n.asGallery),
      (AttachChoice.document, Icons.description_rounded, l10n.asFile),
      (AttachChoice.position, Icons.near_me_rounded, l10n.asLocation),
      (AttachChoice.sticker, Icons.emoji_emotions_rounded, l10n.asSticker),
      (AttachChoice.poll, Icons.poll_rounded, l10n.asPoll),
    ];
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          for (final (choix, icone, libelle) in sources)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSource(choix),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icone,
                      size: DesignTokens.iconLg,
                      color: OuroColors.secondaryLabel,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libelle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.caption2.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ⚠️ LA BARRE D'ENVOI REMPLACE LES ONGLETS, elle ne s'ajoute pas.
///
/// Dès qu'une photo est cochée, la seule chose qui reste à faire est de
/// l'envoyer : garder les onglets à côté offrirait cinq façons de perdre
/// la sélection qu'on vient de faire.
class _BarreEnvoi extends StatelessWidget {
  const _BarreEnvoi({required this.nombre, required this.onEnvoyer});

  final int nombre;
  final VoidCallback onEnvoyer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space4,
        DesignTokens.space2,
        DesignTokens.space4,
        DesignTokens.space3,
      ),
      child: Semantics(
        button: true,
        label: l10n.asSendCount(nombre),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onEnvoyer,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: OuroColors.accentRempli,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Text(
              l10n.asSendCount(nombre),
              style: OuroTypography.headline.copyWith(
                color: OuroColors.texteSurAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accès à la photothèque refusé : on le dit, et on laisse les autres
/// sources utilisables plutôt que de fermer le panneau.
class _PasDacces extends StatelessWidget {
  const _PasDacces({this.vide = false});

  /// `true` quand l'accès est accordé mais la photothèque vide : le dessin
  /// est le même, la phrase ne l'est pas.
  final bool vide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: OuroColors.tertiaryLabel,
            ),
            const SizedBox(height: DesignTokens.space3),
            Text(
              vide ? l10n.asEmptyGallery : l10n.asNoGalleryAccess,
              textAlign: TextAlign.center,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
