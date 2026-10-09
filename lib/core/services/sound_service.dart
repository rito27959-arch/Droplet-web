// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES SONS DE L'APP — une poignée de tonalités courtes, jouées au bon
// moment et jamais autrement.
//
// ── LA PHILOSOPHIE, CELLE DES GRANDES APPS ─────────────────────────────
//
// WhatsApp a deux sons (message entrant, message sortant). iMessage,
// trois. Slack, quatre. Aucune n'en a trente. Un son, ici, ne décore
// pas : il confirme un état que l'œil pourrait rater (« c'est parti »,
// « quelqu'un t'a écrit », « ça n'est pas passé »). S'il ne dit rien de
// neuf, il n'existe pas.
//
// Sept tonalités seulement, tirées d'un pack CC0/CC-BY fait à la main
// (voir `assets/sounds/CREDITS.txt`), converties en MP3 mono et
// ramenées au MÊME niveau perçu (EBU R128) pour qu'aucune ne surprenne
// par rapport aux autres.
//
// ── LES RÈGLES DE POLITESSE ───────────────────────────────────────────
//
//  1. Un interrupteur unique dans les réglages, respecté partout.
//  2. Volume du flux « notification » du système : silencieux si
//     l'utilisateur a baissé ce curseur, ou en mode silencieux / focus.
//     (Contexte audio ci-dessous — `notificationEvent` / `ambient`.)
//  3. Jamais de vol de focus : la musique d'à côté n'est pas coupée
//     (`AndroidAudioFocus.none`, `mixWithOthers`).
//  4. Anti-rafale : deux fois le même son à moins de 500 ms → une seule
//     fois. Deux sons différents à moins de 180 ms → le second attend.
//  5. Le son « message reçu » est plus discret quand la conversation
//     concernée est déjà ouverte à l'écran.
//
// Ce service ne connaît ni le maillage ni les providers : on l'appelle
// de partout par `SoundService.play(AppSound.xxx)`, comme
// `NotificationService`.
// ============================================================================

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Les évènements qui méritent un son. L'ordre n'a pas d'importance.
enum AppSound {
  /// Un message vient de partir.
  messageOut,

  /// Un message vient d'arriver (app ouverte).
  messageIn,

  /// Un message n'a pas pu être remis — il repartira tout seul.
  sendFailed,

  /// Premier lien établi avec un nouvel appareil.
  connected,

  /// Diffusion d'urgence reçue (« j'ai besoin d'aide », « je suis en
  /// sécurité »).
  emergency,

  /// Confirmation générique — sauvegarde faite, statut envoyé, etc.
  confirm,
}

class SoundService {
  SoundService._();

  static const _kEnabledKey = 'sounds_enabled';

  static bool _enabled = true;

  /// L'utilisateur a-t-il laissé les sons activés ? Lu par l'écran de
  /// réglages.
  static bool get enabled => _enabled;

  static bool _ready = false;

  /// Petit pool de lecteurs : jouer deux sons qui se chevauchent (un
  /// « envoyé » suivi tout de suite d'un « reçu ») demande deux lecteurs,
  /// sinon le second coupe le premier.
  static final List<AudioPlayer> _pool = [];
  static int _tour = 0;

  static final Map<AppSound, DateTime> _dernierParSon = {};
  static DateTime _dernierGlobal =
      DateTime.fromMillisecondsSinceEpoch(0);

  static const _fichiers = <AppSound, String>{
    AppSound.messageOut: 'sounds/message_out.mp3',
    AppSound.messageIn: 'sounds/message_in.mp3',
    AppSound.sendFailed: 'sounds/send_failed.mp3',
    AppSound.connected: 'sounds/connected.mp3',
    AppSound.emergency: 'sounds/emergency.mp3',
    AppSound.confirm: 'sounds/confirm.mp3',
  };

  static const _volumes = <AppSound, double>{
    AppSound.messageOut: 0.5,
    AppSound.messageIn: 0.55,
    AppSound.sendFailed: 0.5,
    AppSound.connected: 0.62,
    AppSound.emergency: 0.85,
    AppSound.confirm: 0.5,
  };

  /// À appeler une fois au démarrage, après `StorageService.init()`.
  ///
  /// ⚠️ NE LÈVE JAMAIS. Un appareil sans sortie audio ou un canal de
  /// plateforme indisponible ne doit pas empêcher l'app de démarrer —
  /// les sons sont un confort, jamais une dépendance.
  static Future<void> init() async {
    _enabled = StorageService.getString(_kEnabledKey) != 'off';

    // ⚠️ CONTEXTE AUDIO POSÉ PAR LECTEUR, PAS GLOBALEMENT.
    //
    // `AudioPlayer.global.setAudioContext` s'appliquerait AUSSI aux
    // lecteurs des notes vocales et de la musique des statuts, qui
    // doivent, eux, rester sur le flux « média ». On ne configure donc
    // que nos propres lecteurs.
    final ctx = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.notificationEvent,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        // `ambient` : coupé par l'interrupteur silencieux du téléphone
        // et au verrouillage, et se mélange au son en cours au lieu de
        // le couper.
        category: AVAudioSessionCategory.ambient,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );

    try {
      for (var i = 0; i < 3; i++) {
        final p = AudioPlayer(playerId: 'sfx_$i')
          ..setReleaseMode(ReleaseMode.stop);
        await p.setAudioContext(ctx);
        _pool.add(p);
      }
      _ready = true;
    } catch (e) {
      debugPrint('[SoundService] audio indisponible: $e');
      _ready = false;
    }
  }

  /// Active ou coupe tous les sons de l'app. Persisté.
  static Future<void> setEnabled(bool value) async {
    _enabled = value;
    await StorageService.setString(_kEnabledKey, value ? 'on' : 'off');
  }

  /// Joue [son]. Silencieux si les sons sont coupés, si le service n'a
  /// pas pu s'initialiser, ou si l'anti-rafale l'exige.
  ///
  /// [attenue] : jouer plus bas que d'habitude — utilisé pour « message
  /// reçu » quand la conversation est déjà à l'écran.
  static void play(AppSound son, {bool attenue = false}) {
    if (!_enabled || !_ready || _pool.isEmpty) return;

    final now = DateTime.now();
    final dernier = _dernierParSon[son];
    if (dernier != null &&
        now.difference(dernier) < const Duration(milliseconds: 500)) {
      return;
    }
    if (now.difference(_dernierGlobal) < const Duration(milliseconds: 180)) {
      return;
    }
    _dernierParSon[son] = now;
    _dernierGlobal = now;

    final chemin = _fichiers[son];
    if (chemin == null) return;
    var volume = _volumes[son] ?? 0.5;
    if (attenue) volume *= 0.5;

    final p = _pool[_tour];
    _tour = (_tour + 1) % _pool.length;

    unawaited(() async {
      try {
        await p.stop();
        await p.setVolume(volume.clamp(0.0, 1.0));
        await p.play(AssetSource(chemin));
      } catch (e) {
        debugPrint('[SoundService] échec lecture $son: $e');
      }
    }());
  }
}
