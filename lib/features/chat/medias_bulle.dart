// ============================================================================
// LES PHOTOS ET VIDÉOS DANS LA CONVERSATION — à leur vraie forme.
// ----------------------------------------------------------------------------
// Avant : chaque photo était rognée dans un carré de 220 points, chaque vidéo
// dans un bandeau de 220 × 148, l'heure posée SOUS l'image, et la visionneuse
// s'ouvrait par un simple fondu.
//
// Comme WhatsApp et Telegram :
//   • la bulle prend la FORME de l'image (portrait haut, paysage large),
//     dans des bornes qui évitent les bandes ridicules ;
//   • l'heure et les coches sont posées SUR l'image, dans une pastille
//     sombre en bas à droite ;
//   • la photo apparaît en fondu quand elle est décodée, sur un fond qui
//     miroite pendant le chargement ;
//   • toucher la photo la fait GRANDIR depuis la bulle jusqu'au plein écran
//     (Hero) ; la glisser dans n'importe quel sens la rétrécit, et la lâcher
//     la renvoie à sa place dans la conversation. Double appui : zoom.
//
// ⚠️ LA FORME EST MÉMORISÉE. Connaître la forme d'une image demande de la
// lire ; sans mémoire, chaque bulle naîtrait avec une taille par défaut puis
// changerait de hauteur en poussant la conversation. Les dimensions sont
// gardées en mémoire et sur le disque : une image ne change de taille qu'une
// fois, la toute première fois qu'on la voit.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/storage_service.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_icon_button.dart';

class DimensionsMedias {
  DimensionsMedias._();

  static const _cle = 'medias_dimensions_v1';
  static const int _max = 800;

  /// Largeur de décodage des vignettes, partagée par la bulle et par la
  /// visionneuse (qui l'affiche tout de suite, avant la pleine résolution) :
  /// la même clé de cache, donc aucun second décodage.
  static const int largeurVignette = 560;

  /// Forme supposée tant qu'on ne sait pas : portrait 3:4, le cas le plus
  /// courant d'une photo de téléphone.
  static const Size formeParDefaut = Size(3, 4);

  static Map<String, Size>? _cache;
  static Timer? _ecriture;
  static final Map<String, Future<Size?>> _enCours = {};

  static Map<String, Size> get _memoire {
    final existant = _cache;
    if (existant != null) return existant;
    final lu = <String, Size>{};
    try {
      final brut = StorageService.getString(_cle);
      if (brut != null && brut.isNotEmpty) {
        (jsonDecode(brut) as Map<String, dynamic>).forEach((k, v) {
          if (v is List && v.length == 2) {
            lu[k] = Size((v[0] as num).toDouble(), (v[1] as num).toDouble());
          }
        });
      }
    } catch (_) {}
    return _cache = lu;
  }

  static Size? connue(String cle) => _memoire[cle];

  static void retenir(String cle, Size taille) {
    if (taille.width <= 0 || taille.height <= 0) return;
    final m = _memoire;
    if (m[cle] == taille) return;
    m
      ..remove(cle)
      ..[cle] = taille;
    while (m.length > _max) {
      m.remove(m.keys.first);
    }
    _ecriture?.cancel();
    _ecriture = Timer(const Duration(seconds: 2), () {
      final json = {
        for (final e in m.entries) e.key: [e.value.width.round(), e.value.height.round()],
      };
      unawaited(StorageService.setString(_cle, jsonEncode(json)).catchError((_) {}));
    });
  }

  /// Lit la forme d'une image sans la décoder en entier.
  static Future<Size?> lireImage(String cle, String chemin) {
    final connu = connue(cle);
    if (connu != null) return Future.value(connu);
    return _enCours.putIfAbsent(cle, () async {
      try {
        final tampon = await ui.ImmutableBuffer.fromFilePath(chemin);
        final descripteur = await ui.ImageDescriptor.encoded(tampon);
        tampon.dispose();
        // Une toute petite image décodée plutôt que les dimensions brutes du
        // fichier : c'est le décodage qui applique l'orientation EXIF (une
        // photo portrait prise téléphone couché).
        final codec = await descripteur.instantiateCodec(targetWidth: 64);
        final image = (await codec.getNextFrame()).image;
        final taille = Size(image.width.toDouble(), image.height.toDouble());
        image.dispose();
        codec.dispose();
        descripteur.dispose();
        retenir(cle, taille);
        return taille;
      } catch (_) {
        return null;
      } finally {
        unawaited(Future(() => _enCours.remove(cle)));
      }
    });
  }
}

/// La taille d'affichage d'un média dans la conversation.
///
/// Largeur d'environ deux tiers de l'écran ; hauteur tirée de la forme, mais
/// bornée : un panorama ne devient pas une ficelle, une capture d'écran très
/// haute ne remplit pas tout l'écran.
Size tailleBulleMedia(Size? source, {required double largeurEcran}) {
  final largeurMax = (largeurEcran * 0.68).clamp(200.0, 300.0);
  final hauteurMax = largeurMax * 1.3;
  final forme = (source == null || source.width <= 0 || source.height <= 0)
      ? DimensionsMedias.formeParDefaut
      : source;
  final ratio = (forme.width / forme.height).clamp(0.56, 2.0);
  var largeur = largeurMax;
  var hauteur = largeur / ratio;
  if (hauteur > hauteurMax) {
    hauteur = hauteurMax;
    largeur = (hauteur * ratio).clamp(largeurMax * 0.62, largeurMax);
  }
  return Size(largeur.roundToDouble(), hauteur.roundToDouble());
}

/// L'image réduite d'un média, telle qu'affichée dans la bulle.
ImageProvider vignetteMedia(String chemin) =>
    ResizeImage(FileImage(File(chemin)), width: DimensionsMedias.largeurVignette);

/// Fondu d'apparition d'une image décodée — rien si elle était déjà prête.
Widget apparitionEnFondu(BuildContext context, Widget child, int? frame, bool synchrone) {
  if (synchrone) return child;
  return AnimatedOpacity(
    opacity: frame == null ? 0 : 1,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
    child: child,
  );
}

/// La pastille sombre posée sur un média : heure et coches, durée d'une vidéo.
class PastilleSurMedia extends StatelessWidget {
  const PastilleSurMedia({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        child: child,
      ),
    );
  }
}

/// Un léger dégradé en bas du média, pour que la pastille reste lisible sur
/// une photo claire.
class VoileBasMedia extends StatelessWidget {
  const VoileBasMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 48,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.28)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Le fond d'un média pas encore disponible : un reflet qui passe, comme
/// dans les grandes messageries, plutôt qu'un carré gris immobile.
class FondChargementMedia extends StatefulWidget {
  const FondChargementMedia({super.key, this.child});

  final Widget? child;

  @override
  State<FondChargementMedia> createState() => _FondChargementMediaState();
}

class _FondChargementMediaState extends State<FondChargementMedia>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reflet = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..bouclerSiAmbiant();

  @override
  void dispose() {
    _reflet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reflet,
      builder: (context, child) {
        final t = _reflet.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-2.2 + 3.4 * t, -0.4),
              end: Alignment(-0.8 + 3.4 * t, 0.4),
              colors: [
                Colors.black.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.16),
                Colors.black.withValues(alpha: 0.22),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child == null ? const SizedBox.expand() : Center(child: widget.child),
    );
  }
}

/// Une photo de la conversation, telle qu'elle apparaît dans la galerie.
class PhotoGalerie {
  const PhotoGalerie({required this.chemin, required this.heroTag, this.forme, this.titre});

  final String chemin;
  final Object heroTag;
  final Size? forme;
  final String? titre;
}

/// Ouvre une seule photo en plein écran : elle grandit depuis sa bulle.
Future<void> ouvrirVisionneuseImage(
  BuildContext context, {
  required String chemin,
  required Object heroTag,
  Size? forme,
  String? titre,
}) {
  return ouvrirGaleriePhotos(
    context,
    photos: [PhotoGalerie(chemin: chemin, heroTag: heroTag, forme: forme, titre: titre)],
    index: 0,
  );
}

/// Ouvre la galerie des photos de la conversation à partir de celle qu'on a
/// touchée : on passe à la suivante d'un glissement, comme partout ailleurs.
Future<void> ouvrirGaleriePhotos(
  BuildContext context, {
  required List<PhotoGalerie> photos,
  required int index,
}) {
  if (photos.isEmpty) return Future.value();
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, _) => GaleriePhotos(
        photos: photos,
        index: index.clamp(0, photos.length - 1),
        entree: animation,
      ),
    ),
  );
}

class GaleriePhotos extends StatefulWidget {
  const GaleriePhotos({
    super.key,
    required this.photos,
    required this.index,
    required this.entree,
  });

  final List<PhotoGalerie> photos;
  final int index;
  final Animation<double> entree;

  @override
  State<GaleriePhotos> createState() => _GaleriePhotosState();
}

class _GaleriePhotosState extends State<GaleriePhotos> {
  late final PageController _pages = PageController(initialPage: widget.index);
  late int _courante = widget.index;

  /// Tant que la photo est agrandie, le glissement d'une photo à l'autre est
  /// suspendu : le doigt sert à se déplacer DANS l'image.
  bool _zoomee = false;

  /// De combien la photo a été tirée (fermeture), de 0 à 1.
  double _tirage = 0;

  bool _interface = true;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_courante];
    final compteur =
        widget.photos.length > 1 ? '${_courante + 1}/${widget.photos.length}' : null;

    return AnimatedBuilder(
      animation: widget.entree,
      builder: (context, child) => ColoredBox(
        color: Colors.black.withValues(
          alpha: (widget.entree.value * (1 - _tirage * 1.3)).clamp(0.0, 1.0),
        ),
        child: child,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            physics:
                _zoomee ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() {
              _courante = i;
              _tirage = 0;
            }),
            itemBuilder: (context, i) => _PagePhoto(
              photo: widget.photos[i],
              // Le vol depuis la bulle n'a de sens que pour la photo ouverte :
              // deux `Hero` de même étiquette dans un même écran s'annulent.
              hero: i == _courante,
              surInterface: () => setState(() => _interface = !_interface),
              surZoom: (zoomee) {
                if (zoomee != _zoomee) setState(() => _zoomee = zoomee);
              },
              surTirage: (t) {
                if ((t - _tirage).abs() > 0.004) setState(() => _tirage = t);
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              ignoring: !_interface,
              child: AnimatedOpacity(
                opacity: _interface && _tirage == 0 ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 4,
                    left: 4,
                    right: 16,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      OuroIconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (photo.titre != null)
                        Expanded(
                          child: Text(
                            photo.titre!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (compteur != null)
                        Text(
                          compteur,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une photo de la galerie : zoom au pincement et au double appui, fermeture
/// en la tirant dans n'importe quel sens.
class _PagePhoto extends StatefulWidget {
  const _PagePhoto({
    required this.photo,
    required this.hero,
    required this.surInterface,
    required this.surZoom,
    required this.surTirage,
  });

  final PhotoGalerie photo;
  final bool hero;
  final VoidCallback surInterface;
  final ValueChanged<bool> surZoom;
  final ValueChanged<double> surTirage;

  @override
  State<_PagePhoto> createState() => _PagePhotoState();
}

class _PagePhotoState extends State<_PagePhoto> with SingleTickerProviderStateMixin {
  final _transformation = TransformationController();
  late final AnimationController _retour = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  Animation<Offset>? _animationRetour;

  Offset _glisse = Offset.zero;
  bool _glisseEnCours = false;
  Offset? _pointDoubleAppui;

  bool get _zoomee => _transformation.value.getMaxScaleOnAxis() > 1.01;

  double get _tirage => (_glisse.distance / 320).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _retour.addListener(() {
      final a = _animationRetour;
      if (a != null) {
        setState(() => _glisse = a.value);
        widget.surTirage(_tirage);
      }
    });
  }

  @override
  void dispose() {
    _retour.dispose();
    _transformation.dispose();
    super.dispose();
  }

  void _debut(ScaleStartDetails d) {
    _retour.stop();
    _glisseEnCours = !_zoomee && d.pointerCount == 1;
  }

  void _mouvement(ScaleUpdateDetails d) {
    if (_glisseEnCours && d.pointerCount == 1) {
      setState(() => _glisse += d.focalPointDelta);
      widget.surTirage(_tirage);
    } else if (d.pointerCount > 1 && _glisse != Offset.zero) {
      // Un second doigt : c'est un zoom, pas une fermeture.
      _glisseEnCours = false;
      setState(() => _glisse = Offset.zero);
      widget.surTirage(0);
    }
  }

  void _fin(ScaleEndDetails d) {
    final etaitGlisse = _glisseEnCours;
    _glisseEnCours = false;
    widget.surZoom(_zoomee);
    if (etaitGlisse) {
      final vitesse = d.velocity.pixelsPerSecond.distance;
      if (_glisse.distance > 110 || (vitesse > 900 && _glisse.distance > 24)) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        return;
      }
      _animationRetour = Tween(begin: _glisse, end: Offset.zero).animate(
        CurvedAnimation(parent: _retour, curve: Curves.easeOutBack),
      );
      _retour.forward(from: 0);
    }
    setState(() {});
  }

  void _doubleAppui() {
    final point = _pointDoubleAppui;
    if (_zoomee || point == null) {
      _transformation.value = Matrix4.identity();
    } else {
      const facteur = 2.6;
      _transformation.value = Matrix4.identity()
        ..translateByDouble(-point.dx * (facteur - 1), -point.dy * (facteur - 1), 0, 1)
        ..scaleByDouble(facteur, facteur, 1, 1);
    }
    HapticFeedback.selectionClick();
    widget.surZoom(_zoomee);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final taille = MediaQuery.sizeOf(context);
    final densite = MediaQuery.devicePixelRatioOf(context);
    final forme = widget.photo.forme ?? DimensionsMedias.formeParDefaut;
    final pleineLargeur = (taille.width * densite * 2).clamp(720.0, 2048.0).round();

    Widget image = Stack(
      fit: StackFit.expand,
      children: [
        // La vignette déjà décodée pour la bulle : affichée tout de suite.
        Image(
          image: vignetteMedia(widget.photo.chemin),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
        Image(
          image: ResizeImage(FileImage(File(widget.photo.chemin)), width: pleineLargeur),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          frameBuilder: apparitionEnFondu,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
    if (widget.hero) image = Hero(tag: widget.photo.heroTag, child: image);

    return GestureDetector(
      onTap: widget.surInterface,
      onDoubleTapDown: (d) => _pointDoubleAppui = d.localPosition,
      onDoubleTap: _doubleAppui,
      child: InteractiveViewer(
        transformationController: _transformation,
        minScale: 1,
        maxScale: 5,
        panEnabled: _zoomee,
        onInteractionStart: _debut,
        onInteractionUpdate: _mouvement,
        onInteractionEnd: _fin,
        child: SizedBox.expand(
          child: Transform.translate(
            offset: _glisse,
            child: Transform.scale(
              scale: 1 - _tirage * 0.22,
              child: Center(
                child: AspectRatio(
                  aspectRatio: forme.width / forme.height,
                  child: image,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
