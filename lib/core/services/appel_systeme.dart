// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA TÉLÉCOMMANDE DE LA NOTIFICATION D'APPEL D'ANDROID — celle qui donne la
// PASTILLE DANS LA BARRE D'ÉTAT, avec le combiné et le minuteur qui court,
// visible depuis l'écran d'accueil, et le bouton « Raccrocher » dessiné par
// le système.
//
// Le travail se fait côté natif (`AppelEnCoursService.kt`) ; ici on ne fait
// que l'appeler.
//
// ── POURQUOI CE N'EST PAS FAISABLE EN DART ────────────────────────────
//
// `flutter_local_notifications` n'expose pas `CallStyle` — sa
// documentation d'`AndroidNotificationDetails` ne le mentionne nulle part.
// Or c'est `CallStyle`, porté par un service de premier plan de type
// `phoneCall`, et lui seul, qui fait apparaître la pastille.
//
// Une notification ordinaire avec `usesChronometer` (ce que faisait la
// version précédente) donne bien la durée dans le volet déroulé, mais
// jamais la pastille. La différence est exactement celle des captures :
// une notification qu'il faut aller chercher, contre un minuteur toujours
// visible en haut de l'écran.
//
// ── ⚠️ LE REPLI EST INDISPENSABLE ─────────────────────────────────────
//
// Si la partie Kotlin n'a pas encore été ajoutée au projet, ou si Android
// refuse le service, [demarrer] rend `false` SANS RIEN CASSER — et
// l'appelant retombe sur la notification Dart, qui marche déjà. Une
// fonctionnalité native absente ne doit jamais faire disparaître celle
// qu'elle remplace.
// ============================================================================

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppelSysteme {
  AppelSysteme._();

  static const MethodChannel _canal =
      MethodChannel('com.droplet.droplet/appel_notif');

  static bool get estSupporte => Platform.isAndroid;

  /// Vrai dès qu'un `demarrer` a réussi : c'est ce qui dit à l'appelant
  /// qu'il n'a PAS besoin d'afficher la notification Dart en plus.
  ///
  /// ⚠️ SANS CE DRAPEAU, ON AFFICHERAIT LES DEUX. Deux notifications
  /// d'appel l'une sur l'autre, dont une seule porte la pastille et dont
  /// aucune ne se balaie.
  static bool _natifActif = false;
  static bool get natifActif => _natifActif;

  /// Ce que Dart doit faire quand on appuie sur « Raccrocher » dans la
  /// notification. Branché une fois au démarrage de l'application.
  static void Function(String? pairId)? onRaccrocher;

  /// Où aller quand on appuie sur la notification alors que
  /// l'application tournait DÉJÀ en arrière-plan.
  ///
  /// ⚠️ LE CHEMIN DU DÉMARRAGE NE COUVRE PAS CE CAS. `main.dart` lit
  /// `RaccourcisConversation.routeDeLancement()` une seule fois, à
  /// l'ouverture. Application déjà lancée, l'intent arrive par
  /// `onNewIntent`, l'activité repasse devant, et plus personne ne lit la
  /// route : on retombe sur l'écran qu'on avait quitté. Les deux chemins
  /// coexistent — au démarrage le canal n'existe pas encore, et c'est
  /// `routeDeLancement` qui joue.
  static void Function(String route)? onRoute;

  static bool _ecoute = false;

  /// À appeler une fois au démarrage, après avoir branché [onRaccrocher].
  ///
  /// ⚠️ PAS SEULEMENT AU PREMIER APPEL. Le service d'appel survit à la mort
  /// du moteur Flutter : si l'application est tuée pendant une
  /// communication puis relancée, la notification est toujours là, et son
  /// bouton « Raccrocher » doit encore pouvoir parler à Dart. S'en remettre
  /// au branchement paresseux de [demarrer] laisserait ce bouton sans
  /// personne au bout du fil.
  static void initialiser() => _ecouter();

  static void _ecouter() {
    if (_ecoute) return;
    _ecoute = true;
    _canal.setMethodCallHandler((appel) async {
      switch (appel.method) {
        case 'raccrocher':
          // La notification a DÉJÀ disparu côté Android : le service
          // s'arrête avant de nous prévenir. Il ne reste qu'à couper la
          // communication.
          _natifActif = false;
          onRaccrocher?.call(appel.arguments as String?);
        case 'route':
          final r = appel.arguments as String?;
          if (r != null && r.startsWith('/')) onRoute?.call(r);
      }
      return null;
    });
  }

  /// Allume la notification d'appel système. Rend `false` si le natif
  /// n'est pas là — à l'appelant de retomber sur la version Dart.
  static Future<bool> demarrer({
    required String pairId,
    required String pseudo,
    required DateTime debut,
    required bool video,
    required String via,
  }) async {
    if (!estSupporte) return false;
    _ecouter();
    try {
      final ok = await _canal.invokeMethod<bool>('demarrer', {
        'pair': pairId,
        'pseudo': pseudo,
        // Les millisecondes depuis 1970 : c'est l'origine du chronomètre
        // d'Android, et la seule donnée qui décide si la durée affichée
        // est juste.
        'debut': debut.millisecondsSinceEpoch,
        'video': video,
        'via': via,
      });
      _natifActif = ok ?? false;
      return _natifActif;
    } on MissingPluginException {
      // La partie Kotlin n'est pas (encore) dans le projet. Ce n'est pas
      // une erreur : c'est l'état d'un build qui n'a pris que le Dart.
      debugPrint('[AppelSysteme] pont natif absent, repli sur la '
          'notification Dart');
      _natifActif = false;
      return false;
    } on PlatformException catch (e) {
      // Le cas le plus probable ici : Android a refusé le service de type
      // `phoneCall` parce que `MANAGE_OWN_CALLS` manque au manifeste.
      debugPrint('[AppelSysteme] service refusé par Android: ${e.code} '
          '${e.message}');
      _natifActif = false;
      return false;
    } on Object catch (e) {
      debugPrint('[AppelSysteme] échec: $e');
      _natifActif = false;
      return false;
    }
  }

  /// Éteint la notification et la pastille.
  static Future<void> arreter() async {
    if (!estSupporte) return;
    // ⚠️ ON APPELLE MÊME SI `_natifActif` EST FAUX. Le drapeau est perdu
    // quand le moteur Flutter redémarre (l'application tuée puis
    // relancée) alors que le service, lui, tourne toujours : s'y fier
    // laisserait une notification d'appel permanente que plus rien ne
    // peut fermer.
    _natifActif = false;
    try {
      await _canal.invokeMethod<bool>('arreter');
    } on Object {
      // Rien à faire : il n'y avait rien à éteindre.
    }
  }
}
