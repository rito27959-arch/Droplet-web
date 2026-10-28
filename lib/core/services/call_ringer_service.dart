// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Les SONS D'UN APPEL : la sonnerie quand on vous appelle, la tonalité
// d'attente quand c'est vous qui appelez.
//
// ── Deux sons composés pour Droplet ──────────────────────────────────
//
// Avant, l'appel entrant prenait la sonnerie du téléphone, et l'appel
// sortant… le son de NOTIFICATION du téléphone, rejoué toutes les 1,8 s :
// un « ding » de message reçu, en boucle, pendant qu'on attend. C'est ce
// qui sonnait faux. Les grandes apps d'appel ont leur propre tonalité
// d'attente, reconnaissable dès la première seconde (FaceTime, WhatsApp).
//
// • « RICOCHET » (`assets/sounds/appel_entrant.mp3`, 4 s en boucle) :
//   une goutte tombe — un « plic » dont la hauteur monte, comme une bulle
//   d'air sous la surface — puis un arpège de cloches remonte, comme les
//   ronds dans l'eau du logo. Deux phrases, question puis réponse.
// • « ÉCHO » (`assets/sounds/appel_attente.mp3`, 3,2 s en boucle) : deux
//   gouttes douces, une note et sa quinte, puis un silence. On entend que
//   ça sonne chez l'autre, sans que ce soit pénible au bout de 30 s.
//
// Les deux sont synthétisés (cloches FM, aucun échantillon emprunté) :
// rien à créditer, rien à licencier.
//
// ── Ce qui est respecté ───────────────────────────────────────────────
//
// • LE MODE SILENCIEUX : la sonnerie passe par le flux « sonnerie »
//   d'Android, que le mode silencieux coupe — comme la sonnerie système.
//   La vibration, elle, continue.
// • L'ÉCOUTEUR : la tonalité d'attente passe par le flux de signalisation
//   des appels, donc là où sortira la voix (écouteur, haut-parleur,
//   casque), au volume de l'appel.
// • LE REPLI : si le fichier ne se lit pas (fichier absent, sortie audio
//   indisponible), on revient aux sons du téléphone. Un appel ne doit
//   jamais sonner dans le vide.
// ============================================================================

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CallRingerService {
  CallRingerService._();

  static Timer? _pulseTimer;
  static bool _ringing = false;
  static AudioPlayer? _lecteur;

  /// Le motif de vibration de l'appel entrant : deux secousses, une
  /// pause — calé sur les deux phrases de « Ricochet ».
  static int _battement = 0;

  static Future<bool> _jouer(String fichier, AudioContext contexte, double volume) async {
    try {
      final p = _lecteur ??= AudioPlayer(playerId: 'appel_sonnerie');
      await p.setAudioContext(contexte);
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(volume);
      await p.play(AssetSource(fichier));
      return true;
    } catch (e) {
      debugPrint('[Sonnerie] lecture impossible ($fichier): $e');
      return false;
    }
  }

  /// Sonnerie entrante : « Ricochet » en boucle + vibration, jusqu'à ce
  /// que l'appel soit décroché, refusé, ou s'arrête.
  static void startIncoming() {
    if (_ringing) return;
    _ringing = true;
    unawaited(_jouer(
      'sounds/appel_entrant.mp3',
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.soloAmbient),
      ),
      1.0,
    ).then((ok) {
      if (!ok && _ringing) {
        FlutterRingtonePlayer().play(android: AndroidSounds.ringtone, ios: IosSounds.electronic, looping: true, volume: 1.0);
      }
    }));
    HapticFeedback.heavyImpact();
    _battement = 0;
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      // 0 et 1 : deux secousses ; 2 et 3 : rien. Une phrase = 2 s.
      final pas = _battement++ % 4;
      if (pas == 0) HapticFeedback.heavyImpact();
      if (pas == 1) HapticFeedback.mediumImpact();
    });
  }

  /// Tonalité d'attente sortante : « Écho » en boucle, sans vibration.
  static void startOutgoing() {
    if (_ringing) return;
    _ringing = true;
    unawaited(_jouer(
      'sounds/appel_attente.mp3',
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.voiceCommunicationSignalling,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: const {AVAudioSessionOptions.allowBluetooth, AVAudioSessionOptions.defaultToSpeaker},
        ),
      ),
      0.9,
    ).then((ok) {
      if (!ok && _ringing) {
        FlutterRingtonePlayer().playNotification();
        _pulseTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) => FlutterRingtonePlayer().playNotification());
      }
    }));
  }

  /// Coupure immédiate — dès que l'appel est connecté, manqué, raccroché
  /// ou refusé, plus aucun son ne doit continuer.
  static void stop() {
    if (!_ringing) return;
    _ringing = false;
    final p = _lecteur;
    if (p != null) unawaited(p.stop().catchError((Object _) {}));
    FlutterRingtonePlayer().stop();
    _pulseTimer?.cancel();
    _pulseTimer = null;
  }
}
