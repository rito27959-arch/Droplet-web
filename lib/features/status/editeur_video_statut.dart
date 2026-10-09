// ============================================================================
// LE MONTAGE D'UNE VIDÉO DE STATUT — comme WhatsApp.
// ----------------------------------------------------------------------------
// Avant : une vidéo de la galerie trop longue était coupée d'office à la
// première minute et demie, sans rien montrer ni rien choisir.
//
// Ici :
//   • l'aperçu tourne en boucle sur la partie choisie ;
//   • une FRISE d'images de la vidéo, avec deux poignées pour choisir le
//     début et la fin ;
//   • au-delà de la durée d'un statut, « Diviser en N statuts » publie la
//     partie choisie en plusieurs statuts qui se suivent — ce que fait
//     WhatsApp avec les longues vidéos.
//
// La découpe se fait sans réencodage (`MediaBridge.couper`) : instantanée et
// sans perte. Le réencodage éventuel reste l'affaire de l'envoi.
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/services/media_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_spinner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Ouvre le montage. Rend les morceaux à publier (dans l'ordre), ou `null`
/// si on renonce.
Future<List<String>?> ouvrirEditeurVideoStatut(
  BuildContext context, {
  required String chemin,
  required Duration maxSegment,
}) {
  return Navigator.of(context).push<List<String>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => EditeurVideoStatut(chemin: chemin, maxSegment: maxSegment),
    ),
  );
}

/// Les morceaux d'une plage : un seul si on ne divise pas.
List<(Duration, Duration)> decouperPlage(
  Duration debut,
  Duration fin,
  Duration maxSegment, {
  required bool diviser,
  int maxMorceaux = 10,
}) {
  if (fin <= debut) return const [];
  if (!diviser) {
    final bout = debut + maxSegment;
    return [(debut, fin < bout ? fin : bout)];
  }
  final morceaux = <(Duration, Duration)>[];
  var d = debut;
  while (d < fin && morceaux.length < maxMorceaux) {
    final f = d + maxSegment < fin ? d + maxSegment : fin;
    // Un reste de moins d'une seconde ne vaut pas un statut.
    if (f - d < const Duration(seconds: 1) && morceaux.isNotEmpty) break;
    morceaux.add((d, f));
    d = f;
  }
  return morceaux;
}

String _horloge(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class EditeurVideoStatut extends StatefulWidget {
  const EditeurVideoStatut({super.key, required this.chemin, required this.maxSegment});

  final String chemin;
  final Duration maxSegment;

  @override
  State<EditeurVideoStatut> createState() => _EditeurVideoStatutState();
}

class _EditeurVideoStatutState extends State<EditeurVideoStatut> {
  VideoPlayerController? _lecteur;
  List<String> _images = const [];
  Duration _duree = Duration.zero;

  /// Début et fin, en fraction de la durée (0 à 1).
  double _debut = 0;
  double _fin = 1;

  bool _diviser = false;
  bool _travail = false;

  static const Duration _minimum = Duration(seconds: 1);

  Duration get _debutT => _duree * _debut;
  Duration get _finT => _duree * _fin;
  Duration get _choisi => _finT - _debutT;

  @override
  void initState() {
    super.initState();
    _preparer();
  }

  Future<void> _preparer() async {
    final lecteur = VideoPlayerController.file(File(widget.chemin));
    try {
      await lecteur.initialize();
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (!mounted) {
      await lecteur.dispose();
      return;
    }
    final duree = lecteur.value.duration;
    final longue = duree > widget.maxSegment;
    setState(() {
      _lecteur = lecteur;
      _duree = duree;
      // Longue vidéo : tout est gardé, et divisé — comme WhatsApp.
      _diviser = longue;
    });
    lecteur.addListener(_boucler);
    await lecteur.play();
    final images = await MediaService.imagesVideo(widget.chemin, nombre: 10);
    if (mounted) setState(() => _images = images);
  }

  /// Rejoue la partie choisie en boucle.
  void _boucler() {
    final lecteur = _lecteur;
    if (lecteur == null || !lecteur.value.isInitialized) return;
    final position = lecteur.value.position;
    if (position >= _finT || position < _debutT - const Duration(milliseconds: 300)) {
      lecteur.seekTo(_debutT);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _lecteur?.removeListener(_boucler);
    _lecteur?.dispose();
    super.dispose();
  }

  void _bougerDebut(double delta) {
    if (_duree == Duration.zero) return;
    final minFraction = _minimum.inMilliseconds / _duree.inMilliseconds;
    var debut = (_debut + delta).clamp(0.0, _fin - minFraction);
    // Sans division, la partie ne dépasse jamais la durée d'un statut.
    if (!_diviser && _duree * (_fin - debut) > widget.maxSegment) {
      debut = _fin - widget.maxSegment.inMilliseconds / _duree.inMilliseconds;
    }
    setState(() => _debut = debut);
    _lecteur?.seekTo(_debutT);
  }

  void _bougerFin(double delta) {
    if (_duree == Duration.zero) return;
    final minFraction = _minimum.inMilliseconds / _duree.inMilliseconds;
    var fin = (_fin + delta).clamp(_debut + minFraction, 1.0);
    if (!_diviser && _duree * (fin - _debut) > widget.maxSegment) {
      fin = _debut + widget.maxSegment.inMilliseconds / _duree.inMilliseconds;
    }
    setState(() => _fin = fin);
    _lecteur?.seekTo(_duree * math.max(_debut, fin - 0.02));
  }

  void _basculerDivision(bool diviser) {
    OuroHaptics.selection();
    setState(() {
      _diviser = diviser;
      if (!diviser && _choisi > widget.maxSegment) {
        _fin = _debut + widget.maxSegment.inMilliseconds / _duree.inMilliseconds;
      }
    });
  }

  Future<void> _terminer() async {
    if (_travail || _duree == Duration.zero) return;
    setState(() => _travail = true);
    OuroHaptics.medium();
    await _lecteur?.pause();
    final morceaux = decouperPlage(_debutT, _finT, widget.maxSegment, diviser: _diviser);
    final chemins = <String>[];
    for (final (debut, fin) in morceaux) {
      final entier = debut <= Duration.zero && fin >= _duree;
      chemins.add(entier ? widget.chemin : await MediaService.couperVideo(widget.chemin, debut, fin));
    }
    if (mounted) Navigator.of(context).pop(chemins);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lecteur = _lecteur;
    final longue = _duree > widget.maxSegment;
    final nombre = decouperPlage(_debutT, _finT, widget.maxSegment, diviser: _diviser).length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.evTitle),
        actions: [
          OuroRetourIos(child: TextButton(
            onPressed: _travail || lecteur == null ? null : _terminer,
            child: _travail
                ? const SizedBox(width: 18, height: 18, child: OuroSpinner(color: Colors.white, radius: 8))
                : Text(
                    l10n.actionDone,
                    style: TextStyle(color: OuroColors.accent, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          )),
        ],
      ),
      body: lecteur == null
          ? const Center(child: OuroSpinner(color: Colors.white54, radius: 14))
          : Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      lecteur.value.isPlaying ? lecteur.pause() : lecteur.play();
                    }),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: lecteur.value.aspectRatio,
                          child: VideoPlayer(lecteur),
                        ),
                        AnimatedOpacity(
                          opacity: lecteur.value.isPlaying ? 0 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.45),
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Frise(
                    images: _images,
                    debut: _debut,
                    fin: _fin,
                    tete: _duree == Duration.zero
                        ? 0
                        : lecteur.value.position.inMilliseconds / _duree.inMilliseconds,
                    surDebut: _bougerDebut,
                    surFin: _bougerFin,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_horloge(_debutT)} – ${_horloge(_finT)} · ${_horloge(_choisi)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (longue)
                  SafeArea(
                    top: false,
                    child: SwitchListTile.adaptive(
                      value: _diviser,
                      onChanged: _basculerDivision,
                      activeTrackColor: OuroColors.accent,
                      title: Text(
                        l10n.evSplit(nombre),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        l10n.evSplitHint(widget.maxSegment.inSeconds),
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  const SafeArea(top: false, child: SizedBox(height: 20)),
              ],
            ),
    );
  }
}

/// La frise : les images de la vidéo, la partie choisie encadrée, deux
/// poignées, et la tête de lecture.
class _Frise extends StatelessWidget {
  const _Frise({
    required this.images,
    required this.debut,
    required this.fin,
    required this.tete,
    required this.surDebut,
    required this.surFin,
  });

  final List<String> images;
  final double debut;
  final double fin;
  final double tete;
  final void Function(double delta) surDebut;
  final void Function(double delta) surFin;

  static const double _hauteur = 58;
  static const double _poignee = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = contraintes.maxWidth - _poignee * 2;
        final gauche = _poignee + largeur * debut;
        final droite = _poignee + largeur * fin;

        Widget poignee({required bool debutPoignee}) => Positioned(
              left: (debutPoignee ? gauche - _poignee : droite),
              top: 0,
              bottom: 0,
              width: _poignee,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) => OuroHaptics.light(),
                onHorizontalDragUpdate: (d) =>
                    (debutPoignee ? surDebut : surFin)(d.delta.dx / largeur),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(
                      left: debutPoignee ? const Radius.circular(8) : Radius.zero,
                      right: debutPoignee ? Radius.zero : const Radius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(width: 3, height: 18, color: Colors.black38),
                ),
              ),
            );

        return SizedBox(
          height: _hauteur,
          child: Stack(
            children: [
              // Les images.
              Positioned(
                left: _poignee,
                right: _poignee,
                top: 4,
                bottom: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: images.isEmpty
                      ? const ColoredBox(color: Colors.white12)
                      : Row(
                          children: [
                            for (final image in images)
                              Expanded(
                                child: Image.file(
                                  File(image),
                                  fit: BoxFit.cover,
                                  height: _hauteur,
                                  gaplessPlayback: true,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              // Ce qui ne sera pas gardé, assombri.
              Positioned(
                left: _poignee,
                width: gauche - _poignee,
                top: 4,
                bottom: 4,
                child: const ColoredBox(color: Color(0xAA000000)),
              ),
              Positioned(
                left: droite,
                right: _poignee,
                top: 4,
                bottom: 4,
                child: const ColoredBox(color: Color(0xAA000000)),
              ),
              // Le cadre de la partie choisie.
              Positioned(
                left: gauche,
                width: math.max(0, droite - gauche),
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: const Border.symmetric(
                        horizontal: BorderSide(color: Colors.white, width: 4),
                      ),
                    ),
                  ),
                ),
              ),
              // La tête de lecture.
              Positioned(
                left: _poignee + largeur * tete.clamp(0.0, 1.0) - 1,
                top: 0,
                bottom: 0,
                width: 2,
                child: const IgnorePointer(child: ColoredBox(color: Colors.white)),
              ),
              poignee(debutPoignee: true),
              poignee(debutPoignee: false),
            ],
          ),
        );
      },
    );
  }
}
