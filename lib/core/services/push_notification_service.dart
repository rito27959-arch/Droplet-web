// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE RÉVEIL — pas l'affichage.
//
// `notification_service.dart` sait déjà AFFICHER une bulle système ;
// mais toutes les notifications qu'il montrait jusqu'ici venaient d'un
// événement produit PENDANT que l'app tournait (un message mesh reçu,
// un appel WebRTC entrant). Rien ne pouvait réveiller Droplet quand il
// n'était plus en train de tourner du tout — app fermée, tuée par le
// système. C'est le trou que ce fichier comble : Firebase Cloud
// Messaging (FCM), le seul mécanisme Android capable de sortir une app
// de cet état.
//
// ── Ce que Droplet envoie au serveur, et ce qu'il N'ENVOIE PAS ────────
//
// Le jeton d'appareil obtenu ici (`currentToken`) part vers l'annuaire
// (voir `TorTransport._registerInDirectory`) — c'est un identifiant
// technique qui dit « voici comment réveiller CET appareil », rien de
// plus. Aucun contenu de conversation ne transite jamais par Firebase :
// le push que le serveur envoie (voir `droplet_directory/lib/fcm.dart`)
// ne porte qu'un type d'événement générique (« appel », « message ») et
// l'identifiant technique de l'autre personne — jamais un pseudo, jamais
// un aperçu. Le contenu réel reste chiffré de bout en bout et n'existe
// nulle part ailleurs que sur les deux appareils concernés.
// ============================================================================

import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../providers/locale_provider.dart';
import 'avatar_service.dart';
import 'notification_service.dart';

class PushNotificationService {
  PushNotificationService._();

  static bool _initialized = false;

  /// Le jeton d'appareil courant, une fois obtenu — lu par
  /// `TorTransport._registerInDirectory()` pour l'envoyer à l'annuaire.
  /// `null` tant qu'il n'a pas encore été obtenu, ou si Firebase n'est
  /// pas disponible sur cet appareil (aucun Play Services, par exemple) :
  /// dans ce cas l'appareil reste joignable par sondage de la mailbox,
  /// simplement pas réveillable par push.
  static String? currentToken;

  /// Appelé quand le jeton change (première obtention, renouvellement) —
  /// pour que l'appelant puisse le renvoyer à l'annuaire sans attendre
  /// le prochain démarrage de l'app.
  static void Function(String token)? onTokenChanged;

  /// Appelé quand un push arrive APP OUVERTE (nouveau message déposé dans la
  /// boîte aux lettres) : la messagerie relève tout de suite, au lieu
  /// d'attendre la prochaine relève périodique.
  static void Function()? onReveilPremierPlan;

  /// À appeler une seule fois au démarrage de l'app, après
  /// `NotificationService.init()`.
  ///
  /// ⚠️ NE FAIT AUCUN APPEL RÉSEAU, ET C'EST LE POINT ESSENTIEL.
  ///
  /// Cette méthode attendait `messaging.getToken()`, et `main()`
  /// l'attendait à son tour AVANT `runApp()`. Or `getToken()` enregistre
  /// l'appareil auprès des serveurs FCM : c'est un appel réseau. Sans
  /// Internet, le SDK ne renonce pas tout de suite — il réessaie avec des
  /// délais croissants. Résultat : la TOUTE PREMIÈRE ouverture de Droplet
  /// restait sur un écran vide, parfois des dizaines de secondes, en
  /// attendant un jeton de notification. Aux ouvertures suivantes le jeton
  /// était en cache et revenait instantanément — d'où un défaut qui ne se
  /// manifestait qu'au premier lancement, exactement là où l'on juge une
  /// application.
  ///
  /// C'était une contradiction frontale avec la raison d'être de Droplet :
  /// une messagerie dont le scénario nominal est l'ABSENCE de réseau ne
  /// peut pas exiger Internet pour s'ouvrir la première fois.
  ///
  /// Le jeton n'est d'ailleurs utile qu'à un seul endroit
  /// (`TorTransport._registerInDirectory()`), c'est-à-dire dans une
  /// situation où le réseau existe de toute façon. Rien ne justifiait de
  /// lui sacrifier le démarrage.
  ///
  /// Ne reste donc ici que du LOCAL : lecture de `google-services.json`,
  /// pose des écouteurs, relecture du message d'ouverture. Le réseau et la
  /// demande de permission partent dans [_demarrerEnArrierePlan], sans
  /// être attendus.
  ///
  /// ⚠️ NE LÈVE JAMAIS D'EXCEPTION. Un projet Firebase mal configuré ou
  /// un appareil sans Play Services ne doivent pas empêcher le reste de
  /// l'app de démarrer — les notifications push sont un coup de pouce,
  /// jamais une dépendance dure.
  /// La part de l'initialisation qui touche au réseau et à l'utilisateur.
  ///
  /// Volontairement détachée du démarrage : elle peut prendre trente
  /// secondes hors connexion sans que personne ne le remarque, puisque
  /// l'application est déjà à l'écran et pleinement utilisable en mesh.
  ///
  /// ⚠️ LA DEMANDE DE PERMISSION AUSSI Y GAGNE. Posée pendant le
  /// démarrage, la boîte de dialogue système s'affichait par-dessus un
  /// écran encore vide — on demandait l'autorisation d'envoyer des
  /// notifications à quelqu'un qui n'avait pas encore vu l'application.
  ///
  /// ⚠️ PLAFOND SUR `getToken()`. Sans lui, la tentative continue de
  /// consommer du réseau et de la batterie en arrière-plan tant que
  /// l'appareil reste hors ligne. En cas d'échec, `onTokenRefresh`
  /// délivrera le jeton de lui-même dès qu'une connexion reviendra —
  /// c'est exactement à ça qu'il sert.
  static Future<void> _demarrerEnArrierePlan(FirebaseMessaging messaging) async {
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('[Push] Permission de notification refusée ou indisponible: $e');
    }

    try {
      final jeton = await messaging.getToken().timeout(const Duration(seconds: 30));
      if (jeton != null && jeton.isNotEmpty) {
        currentToken = jeton;
        debugPrint('[Push] Jeton d\'appareil obtenu');
        onTokenChanged?.call(jeton);
      } else {
        debugPrint('[Push] Jeton absent — sondage mailbox uniquement');
      }
    } on TimeoutException {
      debugPrint('[Push] Jeton non obtenu (hors ligne) — onTokenRefresh prendra le relais');
    } catch (e) {
      debugPrint('[Push] Échec obtention du jeton: $e');
    }
  }

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[Push] Firebase indisponible sur cet appareil: $e');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    // ⚠️ LANCÉ SANS ÊTRE ATTENDU. C'est tout l'objet du correctif décrit
    // au-dessus : la permission et le jeton ne doivent jamais retarder le
    // premier écran.
    unawaited(_demarrerEnArrierePlan(messaging));

    messaging.onTokenRefresh.listen((token) {
      currentToken = token;
      onTokenChanged?.call(token);
    });

    // Premier plan : l'app est déjà ouverte, le mesh/la mailbox vont de
    // toute façon récupérer le vrai contenu dans les secondes qui
    // suivent — inutile d'ajouter une notification système par-dessus
    // ce que l'utilisateur regarde déjà.
    //
    // ⚠️ SAUF UN AVERTISSEMENT DE MODÉRATION. Celui-là ne sera JAMAIS
    // rattrapé par le mesh (il ne vient pas d'un pair, il vient du
    // serveur annuaire — voir `droplet_directory` `/admin/warn`) et
    // Android n'affiche pas de lui-même le bloc `notification` d'un push
    // reçu au premier plan. Sans cette branche, un avertissement envoyé
    // pendant que la personne a l'app ouverte passerait totalement
    // inaperçu.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[Push] Message reçu premier plan: ${message.data}');
      if (message.data['type'] != 'warning') onReveilPremierPlan?.call();
      if (message.data['type'] == 'warning') {
        NotificationService.showModerationWarning(
          titre: message.notification?.title ?? 'Droplet',
          corps: message.notification?.body ?? '',
        );
      }
    });

    // Appui sur la notification alors que l'app tournait en arrière-plan.
    FirebaseMessaging.onMessageOpenedApp.listen(_gererTapNotification);

    // App totalement fermée, relancée EN TAPANT sur la notification —
    // le seul des trois chemins où `main.dart` n'a pas encore pu
    // consommer `NotificationService.pendingNavigation` au moment où on
    // le renseigne ; il le fera après son tout premier frame.
    final messageInitial = await messaging.getInitialMessage();
    if (messageInitial != null) _gererTapNotification(messageInitial);
  }

  static void _gererTapNotification(RemoteMessage message) {
    final type = message.data['type'] as String?;
    // `de` : nom donné par l'annuaire, Firebase refusant la clé `from`.
    final from = (message.data['de'] ?? message.data['from']) as String?;
    if (from == null) return;
    if (type == 'call') {
      // `entrant` : ne jamais rappeler la personne qui appelle.
      NotificationService.pendingNavigation = '/call/$from?entrant=1';
    } else {
      NotificationService.pendingNavigation = '/chat/$from';
    }
  }
}

/// Gestionnaire en ARRIÈRE-PLAN — Android réveille un isolate séparé pour
/// l'exécuter quand un push arrive alors que l'app est fermée, exactement
/// comme `reponseEnArrierePlan` dans `notification_service.dart` pour les
/// réponses tapées depuis une notification.
///
/// ── ⚠️ CETTE FONCTION VIT DANS UN AUTRE MONDE ─────────────────────
///
/// Même mise en garde que pour `reponseEnArrierePlan` : aucune variable
/// statique de l'app n'y est renseignée, aucun provider n'existe. Tout
/// ce qu'elle peut faire est afficher une notification système.
///
/// `@pragma('vm:entry-point')` est OBLIGATOIRE — sans lui, le
/// compilateur de production supprime cette fonction (jamais appelée
/// depuis le code Dart) et les push cessent de fonctionner en silence,
/// en release seulement.
@pragma('vm:entry-point')
Future<void> gererMessageArrierePlan(RemoteMessage message) async {
  await Firebase.initializeApp();
  final type = message.data['type'] as String? ?? 'mailbox';
  // Un avertissement de modération porte son propre bloc `notification`
  // (titre + texte), qu'Android affiche tout seul quand l'app est en
  // arrière-plan ou fermée. En rajouter une ici la doublerait.
  if (type == 'warning') return;
  final from = (message.data['de'] ?? message.data['from']) as String? ?? '';

  // ⚠️ CE PUSH EST « DATA SEUL » — voir `droplet_directory/lib/fcm.dart`.
  //
  // Aucun bloc `notification` : Android n'affiche donc RIEN de lui-même
  // et se contente de réveiller cet isolate. C'est à nous de construire
  // la bulle — et c'est ce qui permet d'y mettre le bouton « Répondre ».
  // Le plugin de notifications, lui, doit être (ré)initialisé dans CET
  // isolate ; il ne partage rien avec celui de l'app.
  DartPluginRegistrant.ensureInitialized();
  // Langue : `currentAppLocale()` retombe sur la langue du système quand
  // le choix explicite (stocké en base) n'est pas lisible ici — assez
  // pour un texte de réveil volontairement générique.
  NotificationService.currentLocale = currentAppLocale();
  await NotificationService.init();
  // Les photos de profil déjà reçues : la notification montre qui écrit.
  try {
    await AvatarService.initialiser();
  } catch (_) {}
  await NotificationService.showPushWake(type: type, fromPeerId: from);
}
