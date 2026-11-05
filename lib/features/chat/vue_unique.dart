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
import '../../core/services/media_service.dart';
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
    // Pas de capture ni d'enregistrement de l'écran tant qu'elle est
    // affichée (Android) — comme WhatsApp.
    unawaited(MediaService.ecranSecurise(true));
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
    unawaited(MediaService.ecranSecurise(false));
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
                      child: Image.file(
                        File(widget.chemin),
                        fit: BoxFit.contain,
                        // Apparition douce, comme une photo qu'on retourne.
                        frameBuilder: (_, enfant, image, synchrone) => AnimatedOpacity(
                          opacity: synchrone || image != null ? 1 : 0,
                          duration: const Duration(milliseconds: 260),
                          child: enfant,
                        ),
                      ),
                    ),
            ),
            // La vidéo : une barre fine qui avance, en bas (pas de retour
            // en arrière possible — on ne revoit pas une vue unique).
            if (widget.video && lecteur != null && lecteur.value.isInitialized)
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: VideoProgressIndicator(
                        lecteur,
                        allowScrubbing: false,
                        padding: EdgeInsets.zero,
                        colors: VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white.withValues(alpha: 0.35),
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
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
                  const Spacer(),
                  if (!kIsWeb && Platform.isAndroid)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.screenshot_monitor_rounded,
                              size: 16, color: Colors.white.withValues(alpha: 0.6)),
                          const SizedBox(width: 5),
                          Text(
                            l10n.vuNoScreenshot,
                            style: OuroTypography.caption1.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
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

/// La pastille « 1 » des bulles en vue unique, comme WhatsApp :
///   • PAS ENCORE OUVERTE : un rond plein avec le « 1 » ;
///   • OUVERTE : un cercle en pointillés, estompé — elle n'est plus là.
class PastilleVueUnique extends StatelessWidget {
  const PastilleVueUnique({
    super.key,
    required this.couleur,
    this.ouverte = false,
    this.couleurChiffre = Colors.white,
  });

  final Color couleur;
  final bool ouverte;

  /// Le « 1 » sur le rond plein (la couleur de la bulle, en général).
  final Color couleurChiffre;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (enfant, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: enfant)),
      child: ouverte
          ? CustomPaint(
              key: const ValueKey('ouverte'),
              size: const Size.square(30),
              painter: _CerclePointille(couleur.withValues(alpha: 0.55)),
            )
          : Container(
              key: const ValueKey('fermee'),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: couleur),
              child: Text(
                '1',
                style: OuroTypography.footnote.copyWith(
                  color: couleurChiffre,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

class _CerclePointille extends CustomPainter {
  _CerclePointille(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size taille) {
    final pinceau = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final rayon = taille.width / 2 - 1;
    final centre = taille.center(Offset.zero);
    const traits = 12;
    const pas = 2 * 3.141592653589793 / traits;
    for (var k = 0; k < traits; k++) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: rayon),
        k * pas,
        pas * 0.55,
        false,
        pinceau,
      );
    }
  }

  @override
  bool shouldRepaint(_CerclePointille ancien) => ancien.couleur != couleur;
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
