// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA RÉÉCOUTE D'UN VOCAL AVANT DE L'ENVOYER — ce qui s'ouvre quand on
// touche « pause » sur un enregistrement verrouillé.
//
// Un vocal verrouillé, c'est souvent un message long : une explication,
// une histoire, des excuses. Jusqu'ici il partait à l'aveugle — on ne
// pouvait que l'envoyer ou le jeter. Telegram et WhatsApp proposent tous
// deux la même chose, et c'est ce qu'on fait :
//
//     🗑   ▶ ▁▃▅▇▅▃▁▂▄▆▄▂   0:42   ➤
//
//   • la CORBEILLE à gauche, loin du pouce : jeter doit être un choix,
//     jamais un accident ;
//   • l'ONDE, celle qu'on vient d'enregistrer, qu'on touche ou qu'on
//     glisse pour se déplacer ;
//   • la DURÉE qui décompte pendant l'écoute ;
//   • l'ENVOI à droite, là où il était pendant l'enregistrement.
// ============================================================================

import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../l10n/generated/app_localizations.dart';
import 'voice_note.dart';

/// Un enregistrement arrêté, en attente de réécoute.
class VocalEnAttente {
  const VocalEnAttente({
    required this.chemin,
    required this.duree,
    required this.onde,
  });

  final String chemin;
  final Duration duree;
  final List<double> onde;
}

class BarreRelectureVocale extends StatefulWidget {
  const BarreRelectureVocale({
    super.key,
    required this.vocal,
    required this.onSupprimer,
    required this.onEnvoyer,
  });

  final VocalEnAttente vocal;
  final VoidCallback onSupprimer;
  final VoidCallback onEnvoyer;

  @override
  State<BarreRelectureVocale> createState() => _BarreRelectureVocaleState();
}

class _BarreRelectureVocaleState extends State<BarreRelectureVocale> {
  final AudioPlayer _lecteur = AudioPlayer();
  final List<StreamSubscription<Object?>> _abonnements = [];
  bool _enLecture = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _abonnements
      ..add(_lecteur.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      }))
      ..add(_lecteur.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _enLecture = false;
            _position = Duration.zero;
          });
        }
      }));
  }

  @override
  void dispose() {
    for (final a in _abonnements) {
      unawaited(a.cancel());
    }
    unawaited(_lecteur.dispose());
    super.dispose();
  }

  Future<void> _basculer() async {
    OuroHaptics.selection();
    try {
      if (_enLecture) {
        await _lecteur.pause();
        if (mounted) setState(() => _enLecture = false);
      } else {
        if (_position == Duration.zero) {
          await _lecteur.play(DeviceFileSource(widget.vocal.chemin));
        } else {
          await _lecteur.resume();
        }
        if (mounted) setState(() => _enLecture = true);
      }
    } catch (e) {
      debugPrint('[Réécoute] lecture impossible: $e');
    }
  }

  Future<void> _aller(double fraction) async {
    final cible = widget.vocal.duree * fraction;
    setState(() => _position = cible);
    try {
      if (!_enLecture) {
        // Se placer avant de jouer : `seek` sans source chargée ne fait
        // rien sur certains appareils.
        await _lecteur.setSource(DeviceFileSource(widget.vocal.chemin));
      }
      await _lecteur.seek(cible);
    } catch (_) {}
  }

  Future<void> _arreterPuis(VoidCallback suite) async {
    try {
      await _lecteur.stop();
    } catch (_) {}
    suite();
  }

  static String _format(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = widget.vocal.duree;
    final progres = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    // Pendant l'écoute, le temps RESTANT — comme les bulles vocales.
    final affiche = _enLecture || _position > Duration.zero
        ? total - _position
        : total;

    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: OuroColors.systemBackground.withValues(alpha: 0.72),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.actionDelete,
                  onPressed: () => _arreterPuis(widget.onSupprimer),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: OuroColors.systemRed,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.only(left: 2, right: 12),
                    decoration: BoxDecoration(
                      color: OuroColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        Semantics(
                          button: true,
                          label: _enLecture ? l10n.chVoicePause : l10n.chVoicePlay,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _basculer,
                            child: SizedBox.square(
                              dimension: 36,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                transitionBuilder: (enfant, a) =>
                                    ScaleTransition(scale: a, child: enfant),
                                child: Icon(
                                  _enLecture
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  key: ValueKey(_enLecture),
                                  color: OuroColors.accent,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: VoiceWaveform(
                            waveform: widget.vocal.onde,
                            progress: progres,
                            activeColor: OuroColors.accent,
                            inactiveColor:
                                OuroColors.accent.withValues(alpha: 0.35),
                            onSeek: _aller,
                            height: 26,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _format(affiche),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: OuroColors.accent,
                            fontFeatures: const [ui.FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  label: l10n.actionSend,
                  child: GestureDetector(
                    onTap: () => _arreterPuis(widget.onEnvoyer),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.accent,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
