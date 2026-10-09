// ============================================================================
// LA VUE UNIQUE — une photo ou une vidéo qui s'efface après avoir été vue.
// ----------------------------------------------------------------------------
// Rien de nouveau ne circule sur le réseau : la légende du fichier commence
// par une marque, et les deux téléphones savent quoi en faire. Un ancien
// client afficherait la marque en clair, jamais le contraire — on ne peut
// pas croire qu'un média s'effacera alors qu'il ne s'efface pas.
//
// À l'ouverture : le fichier est SUPPRIMÉ du téléphone et le message noté
// comme vu. Il n'y a pas de seconde fois, y compris pour celui qui l'a
// envoyé. Aucune app ne peut empêcher une capture d'écran sur iPhone : la
// vue unique protège de l'oubli, pas de la mauvaise foi.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

import '../../core/models/voice_note_meta.dart';
import 'voice_note.dart';

import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class VueUnique {
  VueUnique._();

  /// La marque posée en tête de la légende.
  static const String marque = 'vu1:';

  static const String _cle = 'vues_uniques';

  /// Change à chaque ouverture : les bulles concernées se redessinent.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Set<String>? _cache;

  static bool marquee(String? legende) =>
      legende != null && legende.startsWith(marque);

  /// La légende écrite par la personne, sans la marque.
  static String sansMarque(String legende) =>
      marquee(legende) ? legende.substring(marque.length) : legende;

  static Set<String> _vues() {
    final deja = _cache;
    if (deja != null) return deja;
    final ids = <String>{};
    final brut = StorageService.getString(_cle);
    if (brut != null && brut.isNotEmpty) {
      try {
        ids.addAll((jsonDecode(brut) as List).whereType<String>());
      } catch (_) {}
    }
    return _cache = ids;
  }

  static bool ouverte(String idMessage) => _vues().contains(idMessage);

  static void marquerOuverte(String idMessage) {
    final ids = _vues();
    if (!ids.add(idMessage)) return;
    unawaited(StorageService.setString(_cle, jsonEncode(ids.toList())));
    revision.value++;
  }
}

/// L'écran d'une vue unique : fond noir, le média, et rien d'autre.
///
/// En sortant, le fichier est effacé du téléphone.
class EcranVueUnique extends StatefulWidget {
  const EcranVueUnique({
    super.key,
    required this.chemin,
    required this.video,
    required this.idMessage,
    this.vocal = false,
    this.onde = const [],
    this.duree,
  });

  final String chemin;
  final bool video;
  final String idMessage;

  /// Un message vocal à écouter une seule fois : l'onde se remplit pendant
  /// la lecture, puis le fichier disparaît.
  final bool vocal;
  final List<double> onde;
  final Duration? duree;

  @override
  State<EcranVueUnique> createState() => _EcranVueUniqueState();
}

class _EcranVueUniqueState extends State<EcranVueUnique> {
  VideoPlayerController? _lecteur;
  AudioPlayer? _audio;
  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _suiviPosition;
  StreamSubscription<void>? _suiviFin;

  @override
  void initState() {
    super.initState();
    if (widget.video) {
      _preparer();
    } else if (widget.vocal) {
      _ecouter();
    }
  }

  Future<void> _preparer() async {
    final lecteur = VideoPlayerController.file(File(widget.chemin));
    try {
      await lecteur.initialize();
      await lecteur.play();
    } catch (_) {
      // Un fichier illisible ne doit pas bloquer la fermeture.
    }
    if (!mounted) {
      unawaited(lecteur.dispose());
      return;
    }
    setState(() => _lecteur = lecteur);
  }

  /// La lecture démarre seule : une vue unique ne se regarde pas deux fois,
  /// autant ne pas demander un second geste.
  Future<void> _ecouter() async {
    final audio = AudioPlayer();
    _audio = audio;
    _suiviPosition = audio.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _suiviFin = audio.onPlayerComplete.listen((_) {
      if (mounted) unawaited(_fermer());
    });
    try {
      await audio.play(DeviceFileSource(widget.chemin));
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_suiviPosition?.cancel());
    unawaited(_suiviFin?.cancel());
    _audio?.dispose();
    _lecteur?.dispose();
    super.dispose();
  }

  /// Le média est effacé ici, et seulement ici : on ne quitte pas cet écran
  /// sans qu'il disparaisse.
  Future<void> _fermer() async {
    VueUnique.marquerOuverte(widget.idMessage);
    unawaited(_lecteur?.pause());
    unawaited(_audio?.stop());
    try {
      final fichier = File(widget.chemin);
      if (fichier.existsSync()) await fichier.delete();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lecteur = _lecteur;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sorti, _) {
        if (!sorti) unawaited(_fermer());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: widget.vocal
                  ? _LectureVocale(
                      onde: widget.onde,
                      position: _position,
                      duree: widget.duree ?? Duration.zero,
                    )
                  : widget.video
                  ? (lecteur != null && lecteur.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: lecteur.value.aspectRatio,
                          child: VideoPlayer(lecteur),
                        )
                      : const CircularProgressIndicator.adaptive())
                  : InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.file(File(widget.chemin), fit: BoxFit.contain),
                    ),
            ),
            SafeArea(
              child: Row(
                children: [
                  OuroIconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: l10n.actionCancel,
                    onPressed: _fermer,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.looks_one_rounded, size: 20, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.vuOnce,
                    style: OuroTypography.subheadline.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La pastille « 1 » des bulles en vue unique.
class PastilleVueUnique extends StatelessWidget {
  const PastilleVueUnique({super.key, required this.couleur, this.ouverte = false});

  final Color couleur;
  final bool ouverte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: couleur.withValues(alpha: ouverte ? 0.5 : 1), width: 1.4),
      ),
      child: Text(
        '1',
        style: OuroTypography.footnote.copyWith(
          color: couleur.withValues(alpha: ouverte ? 0.5 : 1),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Couleur de repli quand la bulle n'en impose pas.
Color couleurVueUnique(BuildContext context, {required bool mine}) =>
    mine ? Colors.white : OuroColors.accent;

/// L'écoute d'un vocal en vue unique : l'onde, le temps qui passe, rien
/// d'autre. Pas de bouton de lecture — ça part tout seul et ça ne revient
/// pas.
class _LectureVocale extends StatelessWidget {
  const _LectureVocale({required this.onde, required this.position, required this.duree});

  final List<double> onde;
  final Duration position;
  final Duration duree;

  String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final avance = duree.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duree.inMilliseconds).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded, size: 34, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 22),
          VoiceWaveform(
            waveform: onde,
            progress: avance,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withValues(alpha: 0.3),
            height: 44,
          ),
          const SizedBox(height: 14),
          Text(
            '${_mmss(position)} / ${_mmss(duree)}',
            style: OuroTypography.footnote.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
