// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est le fichier qui fait apparaître les petites bulles en haut de
// l'écran du téléphone (les « notifications ») quand quelque chose
// d'important se passe dans l'app — même quand Droplet n'est pas ouvert
// à l'écran : « nouveau message », « appel manqué », « ton message n'a
// pas pu être envoyé », « quelqu'un a publié un statut », etc. Exactement
// comme le font WhatsApp, Messenger ou n'importe quelle app de discussion.
//
// Toute la classe est « statique » (pas besoin de créer un objet, on
// appelle directement `NotificationService.showNewMessage(...)` de
// n'importe où dans l'app) — un peu comme un panneau d'affichage public :
// n'importe qui dans l'app peut y accrocher une annonce sans avoir à
// demander la permission à un gardien.
//
// Règle importante respectée partout ici : on n'affiche JAMAIS de
// notification pour quelque chose que l'utilisateur est déjà en train de
// regarder à l'écran (par exemple, un message dans la conversation
// actuellement ouverte) — ce serait comme sonner à la porte de quelqu'un
// qui est déjà en train de te parler face à face.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show Color, FontWeight, Locale, TextPainter, TextSpan, TextStyle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import '../../design_system/ouro_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'avatar_service.dart';
import 'notifs_conversation.dart';
import 'raccourcis_conversation.dart';
import 'reglages_notifs.dart';
import 'reponses_differees.dart';
import 'storage_service.dart';

/// Notifications système Android réelles pour les événements applicatifs
/// (message reçu, appel manqué, envoi échoué, statut/urgence publiés par un
/// pair). Volontairement statique : appelée depuis des couches très
/// différentes (providers Riverpod, repository mesh, UI) sans avoir à faire
/// transiter une instance partout.
/// Ce qu'Android exécute quand on répond alors que l'application est
/// morte.
///
/// ── ⚠️ CETTE FONCTION VIT DANS UN AUTRE MONDE ─────────────────────
///
/// Elle ne tourne PAS dans l'application : Android démarre un isolate
/// séparé qui ne contient qu'elle. Aucune variable statique de
/// `NotificationService` n'y est renseignée, aucun provider n'existe,
/// le maillage n'est pas allumé. Tout ce qu'elle peut faire est écrire
/// sur le disque.
///
/// `@pragma('vm:entry-point')` est OBLIGATOIRE : sans lui, le
/// compilateur de production supprime cette fonction — elle n'est
/// appelée depuis nulle part dans le code Dart — et l'appui sur
/// « Répondre » ne fait plus rien du tout, silencieusement, en release
/// seulement. C'est le genre de défaut qu'on ne voit jamais en
/// développement.
@pragma('vm:entry-point')
Future<void> reponseEnArrierePlan(NotificationResponse r) async {
  if (r.actionId != NotificationService.actionRepondre) return;
  final route = r.payload;
  final texte = r.input?.trim();
  if (route == null || route.isEmpty || texte == null || texte.isEmpty) {
    return;
  }
  // Les greffons ne sont pas branchés d'office dans un isolate
  // secondaire : sans cette ligne, `path_provider` échoue et la
  // réponse est perdue.
  DartPluginRegistrant.ensureInitialized();
  await ReponsesDifferees.ajouter(route, texte);
}

class NotificationService {
  /// Le texte du message apparaît-il dans la notification ?
  ///
  /// Coupé, l'écran verrouillé n'annonce plus que « un nouveau message » :
  /// le contenu ne s'affiche plus devant qui regarde le téléphone posé sur
  /// la table. C'est le réglage « Aperçu du contenu ».
  static const String _cleApercu = 'notif:apercu';

  static bool get apercuActif => StorageService.getString(_cleApercu) != '0';

  static Future<void> setApercuActif(bool actif) =>
      StorageService.setString(_cleApercu, actif ? '1' : '0');

  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final _rng = Random();

  /// Vrai tant que l'app est au premier plan (mise à jour par
  /// [AppLifecycleObserver] dans main.dart) — on n'affiche jamais de
  /// notification système pour un événement que l'utilisateur est déjà en
  /// train de regarder à l'écran.
  static bool isAppForeground = true;

  /// Langue courante de l'interface — mise à jour par `main.dart` à
  /// chaque reconstruction (voir `resolveLocale`). Un service statique
  /// n'a pas de `BuildContext` : c'est le seul moyen pour lui de savoir
  /// dans quelle langue écrire le titre et le corps d'une notification.
  static Locale currentLocale = const Locale('fr');

  /// Les textes localisés dans la langue courante, résolus sans
  /// `BuildContext` — voir [currentLocale].
  static AppLocalizations get _l10n => lookupAppLocalizations(currentLocale);

  /// Conversation actuellement ouverte à l'écran (peerId, groupId, ou
  /// 'broadcast') — mise à jour par ChatScreen. Un message entrant pour
  /// cette conversation précise n'a pas besoin de notification système
  /// même si l'app est au premier plan (l'utilisateur la lit déjà).
  static String? openConversationId;

  /// Conversations archivées — on ne notifie jamais pour elles.
  static Set<String> _archivedConversations = {};

  /// Met à jour l'ensemble des conversations archivées (appelé quand
  /// l'utilisateur archive/désarchive une conversation).
  static void setArchivedConversations(Set<String> keys) {
    _archivedConversations = keys;
  }

  /// Chemin go_router à ouvrir au tap sur une notification, consommé une
  /// fois par main.dart après le premier frame.
  static String? pendingNavigation;
  static void Function(String path)? _onNavigate;

  /// Enregistre la fonction qui sait naviguer dans l'app (fournie par
  /// main.dart) — pour que, quand on tape sur une notification, l'app
  /// sache emmener l'utilisateur directement au bon écran.
  static void bindNavigation(void Function(String path) onNavigate) {
    _onNavigate = onNavigate;
  }

  // ══════════════════════════════════════════════════════════════
  //  RÉPONDRE SANS OUVRIR L'APPLICATION
  // ══════════════════════════════════════════════════════════════
  //
  // ⚠️ CE QUI REND CETTE FONCTION PARTICULIÈRE DANS DROPLET.
  //
  // Ailleurs, répondre depuis une notification suppose un serveur qui
  // relaiera. Ici, il n'y en a pas : la réponse ne part que s'il existe
  // un appareil à portée à cet instant précis. Quand ce n'est pas le
  // cas, elle rejoint la file d'attente et repartira d'elle-même — ce
  // qui est le comportement NORMAL de l'application, pas un échec.
  //
  // C'est pourquoi on ne promet jamais « envoyé » depuis la
  // notification : on enregistre, et le fil de discussion dira la
  // vérité (envoyé, en attente) quand on l'ouvrira.

  /// Identifiants d'action, tels qu'Android nous les renvoie.
  static const String actionRepondre = 'repondre';
  static const String actionLu = 'marquer_lu';
  static const String actionDecrocher = 'decrocher';
  static const String actionRaccrocher = 'raccrocher';

  static Future<void> Function(String route, String texte)? _onRepondre;
  static void Function(String route)? _onLu;
  static void Function(String peerId, bool accepter)? _onAppel;

  /// Branche les actions sur le reste de l'application.
  ///
  /// Appelé depuis `main.dart`, comme [bindNavigation] : ce service ne
  /// connaît ni le maillage ni les providers, et ne doit pas les
  /// connaître.
  static void bindActions({
    Future<void> Function(String route, String texte)? onRepondre,
    void Function(String route)? onLu,
    void Function(String peerId, bool accepter)? onAppel,
  }) {
    _onRepondre = onRepondre;
    _onLu = onLu;
    _onAppel = onAppel;
    _traiterReponseAuLancement();
  }

  /// Traite un appui sur une action de notification.
  static Future<void> _traiterAction(NotificationResponse r) async {
    final route = r.payload;
    if (route == null || route.isEmpty) return;
    // Répondu ou lu depuis la notification : la conversation repart de zéro.
    if (r.actionId == actionRepondre || r.actionId == actionLu) {
      final cle = route.split('/').last;
      _fils.remove(cle);
      _filsNatif.remove(cle);
    }

    switch (r.actionId) {
      case actionRepondre:
        final texte = r.input?.trim();
        if (texte == null || texte.isEmpty) return;
        final f = _onRepondre;
        if (f != null) {
          await f(route, texte);
        } else {
          // L'application n'est pas en état de répondre : on met de
          // côté. Voir `ReponsesDiffrees`.
          await ReponsesDifferees.ajouter(route, texte);
        }
      case actionLu:
        _onLu?.call(route);
      case actionDecrocher:
      case actionRaccrocher:
        // ⚠️ `/call/<id>?entrant=1` : l'identifiant s'arrête avant le `?`.
        // Il était lu avec « ?entrant=1 » collé, et décrocher visait
        // quelqu'un qui n'existe pas.
        final id = Uri.parse(route).pathSegments.last;
        _onAppel?.call(id, r.actionId == actionDecrocher);
      default:
        // Appui sur la notification elle-même : on navigue.
        final nav = _onNavigate;
        if (nav != null) {
          nav(route);
        } else {
          pendingNavigation = route;
        }
    }
  }

  // Les « canaux » de notification servent à Android à grouper les
  // notifications par catégorie, avec un niveau d'importance chacun — un
  // peu comme trois casiers postaux différents : un pour les messages
  // normaux, un pour les appels (plus urgent, ça doit vraiment attirer
  // l'attention), un pour le mesh/l'urgence.
  // ⚠️ Noms/descriptions résolus au moment de la création du canal
  // (dans `init()`), pas `const` : Android les affiche dans ses propres
  // réglages système, donc ils suivent la langue de l'app à cet
  // instant-là. Un changement de langue ultérieur ne renomme pas un
  // canal déjà créé — limitation d'Android, pas de Droplet.
  /// ⚠️ `_v2` — ET C'EST OBLIGATOIRE POUR CHANGER LE SON.
  ///
  /// Android verrouille les réglages d'un canal (dont le son) dès sa
  /// PREMIÈRE création. Modifier le son de `droplet_messages` en place
  /// n'aurait eu aucun effet pour qui avait déjà lancé l'app une fois.
  /// Un nouvel identifiant force un canal neuf, avec la tonalité
  /// « message » de Droplet (`res/raw/droplet_message.mp3`, tirée du
  /// même pack que `SoundService` — voir `assets/sounds/CREDITS.txt`).
  /// L'ancien canal est supprimé dans [init].
  static const String _idChannelMessages = 'droplet_messages_v2';

  static AndroidNotificationChannel get _channelMessages =>
      AndroidNotificationChannel(
        _idChannelMessages,
        _l10n.ntfChannelMessagesName,
        description: _l10n.ntfChannelMessagesDesc,
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('droplet_message'),
      );
  static AndroidNotificationChannel get _channelCalls =>
      AndroidNotificationChannel(
        'droplet_calls',
        _l10n.ntfChannelCallsName,
        description: _l10n.ntfChannelCallsDesc,
        importance: Importance.max,
      );
  /// ⚠️ DEUX CANAUX POUR L'APPEL ENTRANT.
  ///
  /// Application vivante (même écran éteint), `CallRingerService` fait déjà
  /// sonner le téléphone : la notification doit rester MUETTE, sinon deux
  /// sonneries se superposent. Application fermée, réveillée par un push,
  /// personne ne sonne : la notification porte alors la sonnerie du
  /// téléphone, répétée jusqu'à la réponse (voir [_show], `insistant`).
  static AndroidNotificationChannel get _canalAppelMuet => AndroidNotificationChannel(
        'droplet_appels_muet',
        _l10n.ntfChannelCallsName,
        description: _l10n.ntfChannelCallsDesc,
        importance: Importance.max,
        playSound: false,
        enableVibration: false,
      );
  static AndroidNotificationChannel get _canalAppelSonnerie => AndroidNotificationChannel(
        'droplet_appels_sonnerie',
        _l10n.ntfChannelCallsName,
        description: _l10n.ntfChannelCallsDesc,
        importance: Importance.max,
        sound: const UriAndroidNotificationSound('content://settings/system/ringtone'),
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      );
  static AndroidNotificationChannel get _channelMesh =>
      AndroidNotificationChannel(
        'droplet_mesh',
        _l10n.ntfChannelMeshName,
        description: _l10n.ntfChannelMeshDesc,
        importance: Importance.defaultImportance,
      );

  /// À appeler une seule fois au démarrage de l'app : prépare le système
  /// de notifications, crée les trois canaux, et demande la permission
  /// d'afficher des notifications à l'utilisateur.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    const androidInit = AndroidInitializationSettings('@drawable/$_iconeBarre');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _traiterAction,
      // ⚠️ ET LE MÊME TRAITEMENT QUAND L'APPLICATION EST MORTE.
      //
      // Android réveille alors un isolate séparé, qui n'a accès ni aux
      // providers ni au maillage : `_onRepondre` y vaut toujours `null`,
      // et la réponse part en attente sur le disque. L'application la
      // reprendra à son prochain démarrage.
      //
      // Sans cette ligne, un appui sur « Répondre » application fermée
      // ne faisait RIEN — le texte tapé disparaissait sans trace, ce
      // qu'aucun utilisateur ne pardonne.
      onDidReceiveBackgroundNotificationResponse: reponseEnArrierePlan,
    );

    // Les réponses tapées pendant que l'application était fermée.
    unawaited(ReponsesDifferees.rejouer());
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // ⚠️ L'ANCIEN CANAL `droplet_messages` N'EST PLUS SUPPRIMÉ ICI.
    //
    // Il l'était, pour faire le ménage. Mais `NotifConversations.kt` s'en
    // sert comme canal PARENT de toutes les conversations
    // (`setConversationId`) — et le Kotlin le crée AVANT que cette ligne
    // ne s'exécute. On détruisait donc, à chaque démarrage, le parent que
    // le natif venait de poser : Android ne reconnaissait plus aucune
    // conversation, et les rangeait toutes dans « Autres », sans bulle.
    await android?.createNotificationChannel(_channelMessages);
    await android?.createNotificationChannel(_channelCalls);
    await android?.createNotificationChannel(_canalAppelMuet);
    await android?.createNotificationChannel(_canalAppelSonnerie);
    await android?.createNotificationChannel(_channelMesh);
    await android?.requestNotificationsPermission();

    // ⚠️ L'APPLICATION ÉTAIT FERMÉE ET C'EST UNE NOTIFICATION QUI L'A
    // OUVERTE. Android ne rappelle alors PAS `onDidReceiveNotificationResponse` :
    // il faut le demander. Sans cette lecture, toucher la notification d'appel
    // (ou « Décrocher ») ouvrait l'accueil, et l'appel était perdu.
    try {
      final lancement = await _plugin.getNotificationAppLaunchDetails();
      final reponse = lancement?.notificationResponse;
      if ((lancement?.didNotificationLaunchApp ?? false) && reponse != null) {
        _reponseAuLancement = reponse;
        if (_onAppel != null || _onNavigate != null) _traiterReponseAuLancement();
      }
    } catch (_) {}
  }

  static NotificationResponse? _reponseAuLancement;

  static void _traiterReponseAuLancement() {
    final reponse = _reponseAuLancement;
    if (reponse == null) return;
    // Les actions d'appel attendent que l'application sache décrocher.
    final action = reponse.actionId;
    if ((action == actionDecrocher || action == actionRaccrocher) && _onAppel == null) return;
    _reponseAuLancement = null;
    unawaited(_traiterAction(reponse));
  }

  /// Tire un numéro d'identité au hasard pour chaque nouvelle
  /// notification — Android en a besoin pour savoir que c'est une
  /// NOUVELLE bulle et pas la mise à jour d'une ancienne.
  static int _nextId() => _rng.nextInt(1 << 31);

  /// ⚠️ ID STABLE PAR CONVERSATION — POUR NE PAS DOUBLER LES BULLES.
  ///
  /// Un message reçu par Tor peut être annoncé DEUX FOIS : une fois par
  /// le sondage de la mailbox quand l'app tourne en arrière-plan
  /// (`showNewMessage`), une fois par le push Firebase qui l'a réveillée
  /// (`showPushWake`) — et ces deux-là s'exécutent dans des isolates
  /// différents, sans état partagé. En donnant à toutes les
  /// notifications d'une même conversation le MÊME identifiant, la
  /// seconde REMPLACE la première au lieu de s'empiler : Android
  /// déduplique par id, y compris entre isolates. Une conversation = une
  /// bulle, mise à jour — comme WhatsApp.
  static int _idConversation(String cle) => cle.hashCode & 0x7FFFFFFF;

  // ══════════════════════════════════════════════════════════════
  //  LA CONVERSATION DANS LA NOTIFICATION — comme WhatsApp
  // ══════════════════════════════════════════════════════════════
  //
  // Avant : un bloc de texte « Pseudo / message » posé sous l'icône de
  // l'application, dont le logo en couleurs devenait un carré blanc dans
  // la barre d'état, et chaque nouveau message EFFAÇAIT le précédent.
  //
  // Maintenant, le style « conversation » d'Android (`MessagingStyle`) :
  //   • les derniers messages reçus de la conversation, empilés ;
  //   • la photo de la personne — ou son initiale sur SA couleur, la même
  //     que dans l'application ;
  //   • dans un groupe, le nom du groupe en titre et l'auteur de chaque
  //     message ;
  //   • la goutte blanche de Droplet dans la barre d'état.

  /// La silhouette de la goutte (`res/drawable/ic_stat_droplet.xml`).
  static const String _iconeBarre = 'ic_stat_droplet';

  static const int _maxParConversation = 7;

  /// Les messages déjà affichés dans chaque notification de conversation.
  static final Map<String, List<Message>> _fils = {};

  /// Le même fil, dans des types qui nous appartiennent.
  ///
  /// ⚠️ POURQUOI DOUBLER PLUTÔT QUE RELIRE `_fils`. La voie native a besoin
  /// du texte, de l'horodatage et de l'auteur de chaque ligne. Les relire
  /// depuis `Message` reviendrait à dépendre des noms d'accesseurs d'un
  /// paquet tiers — qui peuvent changer à une mise à jour mineure, et dont
  /// la rupture ne se verrait qu'à la compilation d'une version future.
  /// Ces trois valeurs sont déjà entre nos mains au moment où l'on
  /// construit le `Message` : les garder coûte trois champs et supprime la
  /// dépendance.
  static final Map<String, List<({String texte, DateTime quand, String? auteur})>>
      _filsNatif = {};

  /// Les photos des auteurs d'un groupe, par pseudo — chaque ligne de la
  /// notification porte le visage de qui l'a écrite, pas celui du groupe.
  static final Map<String, Map<String, String?>> _photosAuteurs = {};

  /// De quoi republier une notification sans le message qui l'a créée —
  /// après une réponse tapée dans le volet, par exemple.
  static final Map<
      String,
      ({
        String nom,
        String route,
        String? photo,
        bool groupe,
        String? dernierMessage,
      })> _meta = {};

  /// Les libellés que la voie native ne peut pas traduire elle-même.
  ///
  /// ⚠️ KOTLIN N'A PAS LES TRADUCTIONS. Elles vivent dans les `.arb` de
  /// Dart ; écrire « Répondre » en dur côté Android l'affichait en
  /// français à un utilisateur japonais. On les lui passe à chaque appel.
  static Map<String, String> _textesNatifs() => {
        'repondre': _l10n.ntfReply,
        'lu': _l10n.ntfMarkAsRead,
        'reagir': '❤️',
        'moi': _pseudoLocal() ?? 'Droplet',
        // Kotlin remplace « {n} » par le nombre de discussions.
        'resume': _l10n.ntfSummaryChats('{n}'),
      };

  /// Une réponse vient d'être envoyée depuis le volet : elle s'ajoute au
  /// fil de la notification, sans bruit.
  ///
  /// ⚠️ C'EST OBLIGATOIRE, PAS DÉCORATIF. Après une réponse directe,
  /// Android affiche un petit cercle d'attente sur la notification jusqu'à
  /// ce que l'application la mette à jour. Sans cette republication, le
  /// cercle tournait indéfiniment : on ne savait pas si la réponse était
  /// partie.
  static Future<void> apresReponse(String conversationId, String texte) async {
    final meta = _meta[conversationId];
    final fil = _filsNatif[conversationId];
    if (meta == null || fil == null) {
      await NotifsConversation.effacer(conversationId);
      return;
    }
    fil.add((texte: texte, quand: DateTime.now(), auteur: cleMoi));
    if (fil.length > _maxParConversation) {
      fil.removeRange(0, fil.length - _maxParConversation);
    }
    await NotifsConversation.notifier(
      idConversation: conversationId,
      nom: meta.nom,
      fil: fil,
      route: meta.route,
      cheminPhoto: meta.photo,
      groupe: meta.groupe,
      silencieux: true,
      dernierMessage: meta.dernierMessage,
      photosAuteurs: _photosAuteurs[conversationId] ?? const {},
      textes: _textesNatifs(),
    );
  }

  /// Ouvre une route comme le ferait un appui sur une notification — pour
  /// la bannière intégrée, qui vit au-dessus du routeur.
  static void naviguer(String route) {
    final nav = _onNavigate;
    if (nav != null) {
      nav(route);
    } else {
      pendingNavigation = route;
    }
  }

  /// Envoie une réponse par le même chemin qu'une réponse de notification.
  static Future<void> repondre(String route, String texte) async {
    final f = _onRepondre;
    if (f != null) {
      await f(route, texte);
    } else {
      await ReponsesDifferees.ajouter(route, texte);
    }
  }

  /// La conversation vient d'être ouverte : sa notification disparaît, et
  /// la prochaine repartira de zéro.
  static Future<void> oublierConversation(String conversationId) async {
    _fils.remove(conversationId);
    _filsNatif.remove(conversationId);
    _meta.remove(conversationId);
    _photosAuteurs.remove(conversationId);
    try {
      await _plugin.cancel(id: _idConversation(conversationId));
    } catch (_) {}
  }

  /// Clé du carnet de noms réservée à son propre pseudo.
  static const String cleMoi = '__moi__';

  static Map<String, String>? _noms;

  static Future<File?> _fichierNoms() async {
    try {
      final dossier = await getApplicationSupportDirectory();
      return File('${dossier.path}/notifications_noms.json');
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>> _lireNoms() async {
    final connus = _noms;
    if (connus != null) return connus;
    final noms = <String, String>{};
    try {
      final fichier = await _fichierNoms();
      if (fichier != null && fichier.existsSync()) {
        (jsonDecode(await fichier.readAsString()) as Map<String, dynamic>)
            .forEach((id, nom) {
          if (nom is String) noms[id] = nom;
        });
      }
    } catch (_) {}
    return _noms = noms;
  }

  /// Retient des noms (identifiant → pseudo ou nom de groupe) pour les
  /// notifications de réveil.
  ///
  /// ⚠️ UN PUSH RÉVEILLE L'APPLICATION FERMÉE DANS UN AUTRE ISOLATE, sans
  /// base de données ni contacts : il ne connaît que l'identifiant de
  /// l'expéditeur. Ce petit fichier lui permet d'écrire « Nico » avec sa
  /// photo, au lieu de « Droplet — nouveau message ».
  static Future<void> retenirNoms(Map<String, String> nouveaux) async {
    final noms = await _lireNoms();
    var change = false;
    nouveaux.forEach((id, nom) {
      if (id.isEmpty || nom.trim().isEmpty || noms[id] == nom) return;
      noms[id] = nom;
      change = true;
    });
    if (!change) return;
    try {
      await (await _fichierNoms())?.writeAsString(jsonEncode(noms));
    } catch (_) {}
  }

  static String? _pseudoLocal() {
    try {
      final pseudo = StorageService.currentUser?.pseudo;
      return (pseudo == null || pseudo.trim().isEmpty) ? null : pseudo;
    } catch (_) {
      return null;
    }
  }

  /// Soi-même, tel qu'Android l'exige pour une conversation (nom non vide).
  static Future<Person> _moi() async {
    final nom = _pseudoLocal() ?? (await _lireNoms())[cleMoi];
    return Person(
      key: 'moi',
      name: (nom == null || nom.trim().isEmpty) ? 'Droplet' : nom,
    );
  }

  static Future<Person> _personne(String? id, String nom) async => Person(
        key: (id == null || id.isEmpty) ? nom : id,
        name: nom.trim().isEmpty ? '?' : nom,
        icon: await _icone(id, nom),
      );

  static Future<AndroidIcon<Object>?> _icone(String? id, String nom) async {
    final photo = AvatarService.cheminPair(id);
    if (photo != null) return BitmapFilePathAndroidIcon(photo);
    final octets = await _pastilleInitiale(nom);
    return octets == null ? null : ByteArrayAndroidIcon(octets);
  }

  static Future<AndroidBitmap<Object>?> _grandeIcone(String? id, String nom) async {
    final photo = AvatarService.cheminPair(id);
    if (photo != null) return FilePathAndroidBitmap(photo);
    final octets = await _pastilleInitiale(nom);
    return octets == null ? null : ByteArrayAndroidBitmap(octets);
  }

  static final Map<String, Uint8List> _initiales = {};

  /// L'initiale sur sa couleur — la même que `PeerAvatar` (couleur tirée
  /// du pseudo) — dessinée en PNG pour Android.
  static Future<Uint8List?> _pastilleInitiale(String nom) async {
    final connue = _initiales[nom];
    if (connue != null) return connue;
    try {
      const cote = 192;
      final palette = OuroColors.avatarPalette;
      final enregistreur = ui.PictureRecorder();
      final toile = ui.Canvas(enregistreur)
        ..drawCircle(
          const ui.Offset(cote / 2, cote / 2),
          cote / 2,
          ui.Paint()..color = palette[nom.hashCode.abs() % palette.length],
        );
      final base = nom.trim();
      final lettre = base.isEmpty ? '?' : String.fromCharCode(base.runes.first).toUpperCase();
      final texte = TextPainter(
        text: TextSpan(
          text: lettre,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 84,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      texte.paint(toile, ui.Offset((cote - texte.width) / 2, (cote - texte.height) / 2));
      texte.dispose();
      final image = await enregistreur.endRecording().toImage(cote, cote);
      final donnees = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (donnees == null) return null;
      return _initiales[nom] = donnees.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Est-ce qu'on doit garder le silence pour cette notification ? Oui,
  /// si l'app est au premier plan ET que la conversation concernée est
  /// justement celle actuellement ouverte à l'écran.
  static bool _shouldSuppress(String? conversationId) {
    if (!isAppForeground) return false;
    if (conversationId == null) return false;
    // Pas de notification pour une conversation archivée —
    // c'est l'utilisateur qui a décidé de la ranger, et la notification
    // briserait ce silence intentionnel.
    if (_archivedConversations.contains(conversationId)) return true;
    return openConversationId == conversationId;
  }

  /// La fonction commune qui affiche vraiment une bulle de notification
  /// — toutes les fonctions `show...` publiques ci-dessous passent par
  /// ici avec leur propre titre/texte/canal.
  static Future<void> _show({
    required String title,
    required String body,
    required AndroidNotificationChannel channel,
    String? payload,
    List<AndroidNotificationAction> actions = const [],
    /// Clé de conversation : quand elle est fournie, toutes les
    /// notifications de cette conversation partagent un id — la nouvelle
    /// remplace l'ancienne. Voir [_idConversation].
    String? dedupeKey,
    StyleInformation? style,
    AndroidBitmap<Object>? largeIcon,
    AndroidNotificationCategory? categorie,
    DateTime? quand,
    /// Appel entrant : plein écran (même verrouillé), impossible à balayer,
    /// retiré au bout d'une minute s'il n'a pas été traité.
    bool appel = false,

    /// Appel EN COURS : le minuteur est dessiné par Android lui-même.
    ///
    /// ⚠️ C'EST TOUT L'INTÉRÊT. `usesChronometer` fait compter le
    /// SYSTÈME à partir de `when`. Une durée écrite par l'application
    /// serait figée dès qu'Android gèle le processus en arrière-plan —
    /// c'est-à-dire précisément quand on n'est plus dans l'app, le seul
    /// moment où cette notification sert à quelque chose.
    ///
    /// Rien à voir avec [appel] : pas de plein écran, pas de péremption
    /// à soixante secondes, et surtout pas de son — un appel déjà pris
    /// n'a rien à annoncer.
    bool enCours = false,

    /// Écrit en petit à côté du titre : par où passe l'appel.
    String? sousTexte,
    /// Sonnerie répétée jusqu'à la réponse (application fermée seulement).
    bool insistant = false,
    /// Le raccourci de conversation publié pour Android : c'est lui qui donne
    /// les bulles, l'avatar et la section « Conversations » des réglages.
    String? raccourci,
    /// Rangée dans le volet sans son ni bandeau — livraison discrète, ou
    /// application ouverte (c'est alors la bannière intégrée qui prévient).
    bool silencieux = false,
  }) async {
    try {
      await _plugin.show(
        id: dedupeKey != null ? _idConversation(dedupeKey) : _nextId(),
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: channel.importance,
            priority: Priority.high,
            actions: actions,
            icon: _iconeBarre,
            color: OuroColors.accent,
            fullScreenIntent: appel,
            ongoing: appel || enCours,
            autoCancel: !appel && !enCours,
            timeoutAfter: appel ? 60000 : null,
            visibility: (appel || enCours)
                ? NotificationVisibility.public
                : null,
            // Le minuteur d'Android, à partir de `when`.
            usesChronometer: enCours,
            subText: sousTexte,
            // ⚠️ MUETTE, ET QUI NE REMONTE PAS. Sans `onlyAlertOnce`, la
            // moindre mise à jour (le micro qu'on coupe) referait sonner
            // la notification et la remonterait en haut de la liste,
            // pendant un appel.
            onlyAlertOnce: enCours || silencieux,
            silent: enCours || silencieux,
            audioAttributesUsage: appel
                ? AudioAttributesUsage.notificationRingtone
                : AudioAttributesUsage.notification,
            // FLAG_INSISTENT : le son se répète tant que rien n'est touché.
            additionalFlags: insistant ? Int32List.fromList([4]) : null,
            largeIcon: largeIcon,
            category: categorie,
            shortcutId: raccourci,
            when: quand?.millisecondsSinceEpoch,
            styleInformation: style ??
                BigTextStyleInformation(body, contentTitle: title),
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] échec affichage: $e');
      // Une photo illisible ne doit jamais coûter la notification : on
      // réessaie sans conversation ni image.
      if (style != null || largeIcon != null) {
        await _show(
          title: title,
          body: body,
          channel: channel,
          payload: payload,
          actions: actions,
          dedupeKey: dedupeKey,
          categorie: categorie,
          quand: quand,
          appel: appel,
          enCours: enCours,
          sousTexte: sousTexte,
          insistant: insistant,
          raccourci: raccourci,
          silencieux: silencieux,
        );
      }
    }
  }

  static String _cleAppel(String peerId) => 'appel-$peerId';

  static String _cleAppelEnCours(String peerId) => 'encours-$peerId';

  /// La notification « appel en cours » — celle qu'on voit en déroulant la
  /// barre d'état pendant qu'on fait autre chose.
  ///
  /// ⚠️ LE MINUTEUR EST DESSINÉ PAR ANDROID, pas par Droplet. On lui donne
  /// l'instant du décrochage (`quand`) et on lève `usesChronometer` : le
  /// système compte tout seul, même quand l'application est gelée. Une
  /// durée écrite par l'app se figerait au moment exact où elle devient
  /// utile — quand on quitte l'app.
  ///
  /// ⚠️ PAS DE `CallStyle`. C'est le gabarit d'Android 12+ fait pour ça,
  /// avec ses boutons « Raccrocher » dessinés par le système, mais
  /// `flutter_local_notifications` ne l'expose pas (sa documentation
  /// n'en parle nulle part) ; l'atteindre demanderait du code natif. Une
  /// notification permanente à catégorie `call`, avec chronomètre et un
  /// bouton « Raccrocher », donne le même service — elle ne gagne
  /// seulement pas le rang privilégié que le système accorde à
  /// `CallStyle` en haut de la liste.
  ///
  /// Marche pour les deux chemins, maillage et Internet : elle ne lit que
  /// l'état d'appel, qui est commun aux deux.
  static Future<void> appelEnCours({
    required String peerId,
    required String pseudo,
    required DateTime debut,
    required bool viaInternet,
  }) async {
    await _show(
      title: _l10n.ntfOngoingCall,
      body: pseudo,
      channel: _canalAppelMuet,
      enCours: true,
      categorie: AndroidNotificationCategory.call,
      dedupeKey: _cleAppelEnCours(peerId),
      // `quand` est l'origine du chronomètre : c'est la seule donnée qui
      // compte pour que la durée affichée soit juste.
      quand: debut,
      sousTexte: viaInternet ? _l10n.ntfViaInternet : _l10n.ntfViaMesh,
      largeIcon: await _grandeIcone(peerId, pseudo),
      // Un appui ramène à l'appel. Pas de `?entrant=1` : il est déjà pris.
      payload: '/call/$peerId',
      actions: [
        AndroidNotificationAction(
          actionRaccrocher,
          _l10n.baHangUp,
          // Raccrocher ne demande aucune interface : c'est justement ce
          // qui permet de le faire sans quitter ce qu'on fait.
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
  }

  /// L'appel est terminé : la notification permanente disparaît.
  static Future<void> fermerAppelEnCours(String peerId) async {
    try {
      await _plugin.cancel(id: _idConversation(_cleAppelEnCours(peerId)));
    } catch (_) {}
  }

  /// L'appel a été décroché, refusé ou abandonné : sa notification (qu'on ne
  /// peut pas balayer) disparaît.
  static Future<void> fermerAppel(String peerId) async {
    try {
      await _plugin.cancel(id: _idConversation(_cleAppel(peerId)));
    } catch (_) {}
  }

  /// Les deux actions d'une notification de message : répondre en ligne
  /// (champ de saisie dans la bulle) et marquer comme lu.
  ///
  /// ⚠️ Partagées entre [showNewMessage] (message reçu app vivante, par
  /// le maillage OU la mailbox Tor) et [showPushWake] (réveil par push,
  /// app fermée) — pour que « répondre depuis la notification » marche
  /// de la même façon quel que soit le chemin qu'a pris le message.
  static List<AndroidNotificationAction> get _actionsMessage => [
        AndroidNotificationAction(
          actionRepondre,
          _l10n.ntfReply,
          allowGeneratedReplies: true,
          inputs: [
            AndroidNotificationActionInput(label: _l10n.ntfYourReply),
          ],
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionLu,
          _l10n.ntfMarkAsRead,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ];

  /// Notification « nouveau message » — sauf si la conversation est déjà
  /// ouverte à l'écran (voir [_shouldSuppress]).
  ///
  /// Appelée pour un message reçu PAR N'IMPORTE QUEL canal tant que l'app
  /// tourne : maillage direct (Bluetooth/Wi-Fi) comme mailbox (relais
  /// Tor, message venu de loin) — voir `MeshRepository.announceIncoming`.
  static Future<void> showNewMessage({
    required String conversationId,
    required String pseudo,
    required String preview,
    required String routePath,
    String? expediteurId,
    String? nomGroupe,
    DateTime? horodatage,
    /// Le message s'adresse à moi (@pseudo ou @tous) : il traverse la
    /// sourdine d'un groupe. Voir `ReglagesNotifs`.
    bool mentionne = false,
    /// L'identifiant du message — pour réagir depuis la notification.
    String? messageId,
    /// Le message est EN PLUS annoncé par la bannière de l'application :
    /// la notification système se range alors sans bruit.
    bool banniereAffichee = false,
  }) async {
    if (_shouldSuppress(conversationId)) return;
    final decision = ReglagesNotifs.decider(
      conversationId: conversationId,
      groupe: nomGroupe != null,
      mentionne: mentionne,
    );
    if (!decision.afficher) return;
    // Sans aperçu, la notification ne porte plus le texte du message.
    final texte = decision.apercu ? preview : _l10n.ntfNewMessageWake;
    final silencieux = !decision.sonore || banniereAffichee;
    final titreGroupe = (nomGroupe != null && nomGroupe.trim().isNotEmpty) ? nomGroupe : null;
    final expediteur = await _personne(expediteurId, pseudo);
    final quandMessage = horodatage ?? DateTime.now();
    final fil = _fils.putIfAbsent(conversationId, () => <Message>[])
      ..add(Message(texte, quandMessage, expediteur));
    if (fil.length > _maxParConversation) {
      fil.removeRange(0, fil.length - _maxParConversation);
    }
    // Les deux files avancent ensemble, et sont rognées ensemble : si
    // l'une déborde et pas l'autre, la notification native et celle de
    // repli ne montrent plus la même chose.
    final filNatif = _filsNatif.putIfAbsent(conversationId, () => [])
      ..add((
        texte: texte,
        quand: quandMessage,
        auteur: titreGroupe == null ? null : pseudo,
      ));
    _photosAuteurs[conversationId] = {
      ...?_photosAuteurs[conversationId],
      if (titreGroupe != null && expediteurId != null)
        pseudo: AvatarService.cheminPair(expediteurId),
    };
    _meta[conversationId] = (
      nom: titreGroupe ?? pseudo,
      route: routePath,
      photo: titreGroupe != null ? null : AvatarService.cheminPair(expediteurId),
      groupe: titreGroupe != null,
      dernierMessage: messageId,
    );
    if (filNatif.length > _maxParConversation) {
      filNatif.removeRange(0, filNatif.length - _maxParConversation);
    }
    final moi = _pseudoLocal();
    unawaited(retenirNoms({
      ?expediteurId: pseudo,
      if (titreGroupe != null) conversationId: titreGroupe,
      if (moi != null) cleMoi: moi,
    }));
    // Android ne range une notification parmi les CONVERSATIONS que si un
    // raccourci existe pour elle (voir `RaccourcisConversation`).
    unawaited(RaccourcisConversation.publier(
      id: conversationId,
      nom: titreGroupe ?? pseudo,
      route: routePath,
      photo: titreGroupe != null ? null : AvatarService.cheminPair(expediteurId),
    ));
    // ── LA VOIE NATIVE, QUAND ELLE EXISTE ────────────────────────────
    //
    // Sur Android, `NotifsConversation` pose une vraie notification DE
    // CONVERSATION : canal propre à cette discussion, bulle flottante,
    // pastille, champ de réponse directe. `flutter_local_notifications`
    // n'en est pas capable — il n'expose ni `LocusId`, ni les métadonnées
    // de bulle, ni les canaux à identifiant de conversation.
    //
    // ⚠️ ON PASSE TOUT LE FIL, PAS LE DERNIER MESSAGE. La notification est
    // republiée sous le même identifiant : elle remplace la précédente.
    // N'envoyer que le dernier effacerait les autres à chaque arrivée.
    //
    // ⚠️ ET ON SORT SI ÇA A MARCHÉ. Laisser l'ancienne voie s'exécuter
    // derrière afficherait DEUX notifications pour le même message.
    final natif = await NotifsConversation.notifier(
      idConversation: conversationId,
      nom: titreGroupe ?? pseudo,
      fil: filNatif,
      route: routePath,
      silencieux: silencieux,
      dernierMessage: messageId,
      photosAuteurs: _photosAuteurs[conversationId] ?? const {},
      textes: _textesNatifs(),
      // ⚠️ PAS DE `quand:` ICI. Chaque ligne du fil porte DÉJÀ son propre
      // horodatage — c'est ce qui permet à Android d'afficher l'heure de
      // chaque message, et pas celle du dernier pour tous. Un `quand`
      // global en plus serait soit redondant, soit contradictoire.
      cheminPhoto:
          titreGroupe != null ? null : AvatarService.cheminPair(expediteurId),
      groupe: titreGroupe != null,
    );
    if (natif) return;

    await _show(
      title: titreGroupe ?? pseudo,
      body: titreGroupe != null ? '$pseudo : $texte' : texte,
      channel: _channelMessages,
      payload: routePath,
      actions: _actionsMessage,
      dedupeKey: conversationId,
      raccourci: conversationId,
      silencieux: silencieux,
      categorie: AndroidNotificationCategory.message,
      quand: horodatage,
      style: MessagingStyleInformation(
        await _moi(),
        conversationTitle: titreGroupe,
        groupConversation: titreGroupe != null,
        messages: List.of(fil),
      ),
      largeIcon: await _grandeIcone(
        titreGroupe != null ? conversationId : expediteurId,
        titreGroupe ?? pseudo,
      ),
    );
  }

  /// Notification « appel entrant » — seulement si l'app n'est pas au
  /// premier plan, car sinon un écran d'appel natif est déjà affiché en
  /// plein écran, une notification en plus serait redondante.
  static Future<void> showIncomingCall({
    required String peerId,
    required String pseudo,
  }) async {
    if (isAppForeground) return; // overlay natif déjà affiché à l'écran
    await _show(
      title: _l10n.ntfIncomingCall,
      body: pseudo,
      // Muet : l'application sonne déjà elle-même.
      channel: _canalAppelMuet,
      appel: true,
      categorie: AndroidNotificationCategory.call,
      dedupeKey: _cleAppel(peerId),
      largeIcon: await _grandeIcone(peerId, pseudo),
      // `entrant` : l'écran attend l'appel au lieu d'en lancer un.
      payload: '/call/$peerId?entrant=1',
      actions: [
        // ⚠️ DÉCROCHER OUVRE L'APPLICATION, ET C'EST OBLIGATOIRE.
        //
        // Un appel demande le micro, le haut-parleur et un écran pour
        // raccrocher. Le traiter sans interface laisserait quelqu'un en
        // communication sans aucun moyen d'y mettre fin.
        //
        // Refuser, en revanche, ne demande rien : c'est le seul des
        // deux qui peut se faire sans quitter ce qu'on était en train
        // de faire.
        AndroidNotificationAction(
          actionDecrocher,
          _l10n.ntfAnswer,
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionRaccrocher,
          _l10n.ntfDecline,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
  }

  /// Notification déclenchée par un push Firebase plutôt que par un
  /// événement local — voir `push_notification_service.dart`
  /// (`gererMessageArrierePlan`).
  ///
  /// ⚠️ POURQUOI ELLE NE PORTE NI PSEUDO NI APERÇU DU MESSAGE.
  ///
  /// Le serveur qui envoie ce push (`droplet_mailbox`/`droplet_server`)
  /// n'a jamais vu ce contenu en clair — la mailbox ne reçoit que du
  /// chiffré (voir `MeshRepository.encryptForMailbox`), et aucun des
  /// deux ne connaît le pseudo de qui que ce soit. Le push ne peut donc
  /// annoncer QUE le type d'événement : un texte précis inventé ici
  /// serait un mensonge.
  ///
  /// ⚠️ MAIS ON PEUT QUAND MÊME Y RÉPONDRE. Le push porte l'identifiant
  /// technique de l'expéditeur (`fromPeerId`) — assez pour router une
  /// réponse. Tapée app fermée, elle rejoint la file
  /// (`ReponsesDifferees`) et repart au prochain démarrage ; tapée app
  /// vivante, elle part tout de suite (voir `main.dart` `bindActions`).
  static Future<void> showPushWake({
    required String type,
    required String fromPeerId,
  }) async {
    // Le push ne dit pas QUI écrit, mais porte son identifiant : si ce
    // téléphone connaît déjà la personne, on affiche son nom et sa photo.
    final nom = fromPeerId.isEmpty ? null : (await _lireNoms())[fromPeerId];
    // ⚠️ LES RÉGLAGES S'APPLIQUENT AUSSI APPLICATION FERMÉE. Un contact en
    // sourdine qui fait sonner le téléphone dès que Droplet est tué, c'est
    // la sourdine qui ne marche « que parfois » — le pire des réglages.
    // L'isolate n'a pas de base : il lit le miroir (`ReglagesNotifs`).
    // (Pas de question d'aperçu ici : un réveil ne porte jamais le texte.)
    if (type != 'call' && fromPeerId.isNotEmpty) {
      final decision = (await ReglagesNotifs.lireMiroir()).decider(
        conversationId: fromPeerId,
        groupe: false,
        mentionne: false,
      );
      if (!decision.afficher) return;
    }
    if (type == 'call') {
      await _show(
        title: _l10n.ntfIncomingCall,
        body: nom ?? _l10n.ntfSomeoneCalling,
        // Application fermée : personne d'autre ne sonne.
        channel: _canalAppelSonnerie,
        appel: true,
        insistant: true,
        categorie: AndroidNotificationCategory.call,
        dedupeKey: fromPeerId.isEmpty ? null : _cleAppel(fromPeerId),
        largeIcon: nom == null ? null : await _grandeIcone(fromPeerId, nom),
        payload: '/call/$fromPeerId?entrant=1',
      );
    } else if (nom != null) {
      final texte = _l10n.ntfNewMessageWake;
      await _show(
        title: nom,
        body: texte,
        channel: _channelMessages,
        payload: '/chat/$fromPeerId',
        actions: _actionsMessage,
        dedupeKey: fromPeerId,
        categorie: AndroidNotificationCategory.message,
        style: MessagingStyleInformation(
          await _moi(),
          messages: [Message(texte, DateTime.now(), await _personne(fromPeerId, nom))],
        ),
        largeIcon: await _grandeIcone(fromPeerId, nom),
      );
    } else {
      await _show(
        title: 'Droplet',
        body: _l10n.ntfNewMessageWake,
        channel: _channelMessages,
        payload: '/chat/$fromPeerId',
        // Pas de `from` (vieux serveur pas encore redéployé, ou push
        // d'un autre type) → pas de bouton « Répondre » : il ne pourrait
        // pas router.
        actions: fromPeerId.isEmpty ? const [] : _actionsMessage,
        // Même id que la bulle du sondage mailbox pour ce pair : si les
        // deux arrivent, la seconde remplace la première.
        dedupeKey: fromPeerId.isEmpty ? null : fromPeerId,
      );
    }
  }

  /// Notification « appel manqué » — envoyée quand un appel entrant n'a
  /// jamais été décroché.
  static Future<void> showMissedCall({
    required String peerId,
    required String pseudo,
  }) async {
    await _show(
      title: _l10n.ntfMissedCall,
      body: pseudo,
      channel: _channelCalls,
      payload: '/chat/$peerId',
    );
  }

  /// Avertissement envoyé par la modération de Droplet (serveur annuaire,
  /// `/admin/warn`) — la seule notification dont le CONTENU vient
  /// vraiment du serveur, parce que c'est l'opérateur qui l'a écrit, pas
  /// un pair. [titre] et [corps] arrivent tels quels dans le push ; on
  /// ne les invente pas ici comme pour [showPushWake].
  ///
  /// Utilisé uniquement pour le cas « app au premier plan » : dans tous
  /// les autres, Android affiche lui-même le bloc `notification` du push.
  static Future<void> showModerationWarning({
    required String titre,
    required String corps,
  }) async {
    await _show(
      title: titre,
      body: corps,
      channel: _channelMessages,
    );
  }

  /// Notification « ton message n'est pas parti » — rassure l'utilisateur
  /// que Droplet réessaiera automatiquement dès qu'un pair repasse à
  /// portée, plutôt que de laisser croire que le message est perdu.
  static Future<void> showSendFailed({
    required String conversationId,
    required String routePath,
  }) async {
    await _show(
      title: _l10n.ntfSendFailedTitle,
      body: _l10n.ntfSendFailedBody,
      channel: _channelMessages,
      payload: routePath,
    );
  }

  /// Notification « quelqu'un a publié un statut ».
  static Future<void> showStatusPublished({
    required String pseudo,
    required String authorId,
  }) async {
    await _show(
      title: _l10n.ntfNewStatusTitle,
      body: _l10n.ntfStatusPublishedBody(pseudo),
      channel: _channelMesh,
      payload: '/status/$authorId',
    );
  }

  /// Notification « quelqu'un a aimé ton statut » — envoyée à l'auteur
  /// du statut quand un autre utilisateur double-tape pour aimer.
  static Future<void> showStatusLiked({
    required String pseudo,
    required String authorId,
    required String statusId,
  }) async {
    await _show(
      title: _l10n.ntfStatusLikedTitle(pseudo),
      body: _l10n.ntfTapToView,
      channel: _channelMessages,
      payload: '/status/$authorId',
    );
  }

  /// Notification « quelqu'un a répondu à ton statut » — envoyée
  /// quand un commentaire est reçu sur un statut.
  static Future<void> showStatusReply({
    required String pseudo,
    required String authorId,
    required String statusId,
    required String preview,
  }) async {
    await _show(
      title: _l10n.ntfStatusReplyTitle(pseudo),
      body: preview,
      channel: _channelMessages,
      payload: '/status/$authorId',
      actions: [
        AndroidNotificationAction(
          actionRepondre,
          _l10n.ntfReply,
          allowGeneratedReplies: true,
          inputs: [
            AndroidNotificationActionInput(label: _l10n.ntfYourReply),
          ],
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
  }

  /// Notification « message d'urgence/sécurité » — quand un contact
  /// diffuse « Je suis en sécurité » sur le mesh.
  static Future<void> showEmergency({required String pseudo}) async {
    await _show(
      title: _l10n.ntfEmergencyTitle,
      body: _l10n.ntfEmergencyBody(pseudo),
      channel: _channelMesh,
      payload: '/safety',
    );
  }
}
