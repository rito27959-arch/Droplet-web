// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est la toute PREMIÈRE porte d'entrée de l'application Droplet — un peu
// comme la page de garde d'un livre. Quand tu appuies sur l'icône de l'app
// sur ton téléphone, c'est CE fichier qui démarre en premier.
//
// Il fait 3 grandes choses :
//   1. Il allume les petits moteurs dont l'app a besoin AVANT de s'afficher
//      (la mémoire de l'app, les notifications, le service qui tourne même
//      quand l'app est fermée).
//   2. Il dessine les fenêtres qui doivent apparaître PAR-DESSUS tout le
//      reste, peu importe l'écran où tu es : l'appel qui sonne, l'invitation
//      à un appel de groupe.
//   3. Il tient la « carte au trésor » de toutes les pages de l'app (le
//      routeur) : quand tu tapes sur un bouton qui doit t'emmener sur une
//      nouvelle page, c'est cette carte qui dit où aller.
// ============================================================================

import 'features/appareils/appareils_lies_screen.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/models/mesh_message.dart';
import 'core/models/voice_note_meta.dart';
import 'core/providers/appearance_provider.dart';
import 'core/providers/personnalisation_provider.dart';
import 'core/config/server_config.dart';
import 'core/providers/mesh_provider.dart';
import 'core/services/mesh_foreground_service.dart';
import 'core/services/crash_journal.dart';
import 'core/services/device_profile.dart';
import 'features/chat/animated_sticker.dart';
import 'core/services/notification_service.dart';
import 'core/services/annonces_droplet.dart';
import 'core/services/notifs_conversation.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/sound_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/share_intent_service.dart';
import 'core/services/avatar_service.dart';
import 'core/services/premium_service.dart';
import 'core/services/reponses_differees.dart';
import 'features/premium/premium_screen.dart';
import 'core/services/raccourcis_conversation.dart';
import 'features/settings/stockage_screen.dart';
import 'features/invitation/inviter_screen.dart';
import 'core/services/storage_service.dart';
import 'features/chat/media_kind.dart';
import 'design_system/ouro_colors.dart';
import 'design_system/ouro_liquid.dart';
import 'design_system/mode_transition.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'features/ai/ai_chat_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'design_system/ouro_motion.dart';
import 'features/nexus_connection/nexus_overlay.dart';
import 'features/nexus_connection/nexus_event.dart';
import 'design_system/ouro_scroll_behavior.dart';
import 'design_system/ouro_theme.dart';
import 'design_system/liquid_bridge.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/home/home_shell.dart';
import 'features/chats/chats_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/location_message.dart';
import 'features/chat/chat_info_screen.dart';
import 'features/chat/security_code_screen.dart';
import 'features/chat/new_message_screen.dart';
import 'core/services/appel_systeme.dart';
import 'features/call/bandeau_appel.dart';
import 'features/call/call_screen.dart';
import 'features/call/group_call_screen.dart';
import 'features/safety/emergency_mode_screen.dart';
import 'features/group/group_create_screen.dart';
import 'features/group/group_info_screen.dart';
import 'features/settings/backup_export_screen.dart';
import 'features/settings/app_icon_screen.dart';
import 'features/settings/apparence_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/aide/aide_screen.dart';
import 'features/aide/contact_screen.dart';
import 'features/aide/donnees_screen.dart';
import 'features/aide/politique_screen.dart';
import 'features/tor/tor_settings_screen.dart';
import 'features/tor/qr_generator_screen.dart';
import 'features/tor/qr_scanner_screen.dart';
import 'features/contribution/contribution_screen.dart';
import 'features/safety/safety_screen.dart';
import 'features/maps/map_screen.dart';
import 'features/maps/offline_maps_screen.dart';
import 'features/mesh/mesh_network_screen.dart';
import 'features/share/share_target_screen.dart';
import 'features/discover/discover_screen.dart';
import 'shared/widgets/droplet_logo.dart';
import 'shared/widgets/peer_avatar.dart';
import 'shared/widgets/toast_overlay.dart';
import 'features/nexus_connection/nexus_memoire.dart';
import 'core/services/contacts.dart';
import 'features/invitation/invitation_screen.dart';
import 'core/providers/thermal_provider.dart';
import 'features/status/status_pager_screen.dart';
import 'features/navigateur/navigateur_integre.dart';
import 'features/chat/messages_importants_screen.dart';
import 'core/services/battement_presence.dart';
import 'core/config/compte_droplet.dart';
import 'core/services/journal_notifs.dart';
import 'core/services/reglages_notifs.dart';
import 'features/chat/mise_en_forme.dart' show Mentions;
import 'features/notifications/centre_notifs_screen.dart';
import 'features/notifications/reglages_notifs_screen.dart';
import 'shared/widgets/banniere_notif.dart';

// `main()` est la fonction magique que Dart (le langage utilisé par Flutter)
// lance TOUJOURS en premier, quel que soit le projet. C'est le tout début de
// tout. `async`/`await` veut dire « attends que ce soit fini avant de
// continuer » — comme attendre que le four sonne avant de sortir le gâteau.
Future<void> main() async {
  // Prépare le moteur Flutter (celui qui dessine les images à l'écran)
  // avant qu'on lui demande quoi que ce soit — obligatoire en premier.
  WidgetsFlutterBinding.ensureInitialized();
  // ⚠️ AUCUNE POLICE NE SERA TÉLÉCHARGÉE. JAMAIS.
  //
  // Inter est embarquée dans le paquet (`assets/fonts/`, déclarée dans
  // `pubspec.yaml`). Ce drapeau n'est donc pas ce qui la fournit — il est
  // là pour que la faute ne puisse PAS revenir en silence.
  //
  // Avant, `OuroTypography` appelait `GoogleFonts.inter()`, qui va
  // chercher la police sur fonts.gstatic.com au premier usage. Sur un
  // appareil qui installe Droplet et part aussitôt en mesh — le scénario
  // que cette application existe pour couvrir — le téléchargement
  // échouait, et `google_fonts` retombait sans bruit sur Roboto :
  // l'échelle typographique iOS entière disparaissait sans une seule
  // ligne de journal. Et une app qui embarque Tor contactait un serveur
  // Google à son premier démarrage.
  //
  // À `false`, `google_fonts` LÈVE une exception au lieu de se rabattre
  // sur le réseau. Si quelqu'un réintroduit un jour un `GoogleFonts.x()`
  // pour une police non embarquée, ça casse en développement — au lieu de
  // ne se voir que sur le téléphone d'un utilisateur sans réseau.
  GoogleFonts.config.allowRuntimeFetching = false;
  // ⚠️ OBLIGATOIRE AVANT TOUT AUTRE APPEL À `FlutterGemma` — la doc du
  // paquet est explicite : « Call this once at app startup before using
  // any other API ». Sans cet appel, `ServiceRegistry.instance` n'existe
  // pas encore, et la première ouverture de l'écran Assistant (qui
  // appelle `FlutterGemma.isModelInstalled`) aurait levé une exception
  // au lieu de simplement proposer le téléchargement.
  //
  // Aucun jeton Hugging Face ici : le fichier est hébergé par Droplet
  // lui-même (voir `ai_assistant_service.dart`), donc rien à
  // authentifier au moment du téléchargement.
  await FlutterGemma.initialize();
  // Branche la boîte noire AVANT tout le reste : à partir d'ici, plus
  // aucune erreur non attrapée ne disparaît sans laisser de trace.
  await CrashJournal.install();
  // ⚠️ LA RÉSERVE D'IMAGES SUIT L'APPAREIL, elle n'est plus fixe.
  //
  // Un plafond unique de 48 Mo convenait au Pixel de développement. Sur
  // un téléphone de 2 Go — celui de l'utilisateur type de Droplet, qui
  // n'a pas de réseau mais pas non plus de matériel neuf — cette seule
  // réserve suffit à faire tuer l'application par le système.
  //
  // On demande donc au système ce dont il dispose AVANT de décider, et
  // tous les effets coûteux de l'app se règlent sur cette réponse (voir
  // `DeviceProfile`).
  await DeviceProfile.detecter();
  PaintingBinding.instance.imageCache
    ..maximumSizeBytes = DeviceProfile.budgetImages
    ..maximumSize = DeviceProfile.nombreImages;
  // Ouvre la mémoire permanente de l'app (là où sont rangés les messages,
  // les contacts, etc.) — comme ouvrir le classeur avant de pouvoir y lire
  // ou écrire quelque chose.
  await StorageService.init();
  // Ouvre le dossier de la photo de profil. Rapide (une création de
  // dossier), et il faut le faire AVANT le premier écran : sans lui,
  // `AvatarService.chemin` renvoie `null` et le premier affichage
  // retomberait sur l'initiale alors qu'une photo existe.
  await AvatarService.initialiser();
  // Relit la licence enregistrée et REVÉRIFIE sa signature. Il faut le
  // faire avant le premier écran : sans cela, une personne qui a payé
  // verrait ses fonds et ses icônes verrouillés pendant une seconde à
  // chaque lancement — ce qui se lit comme « on m'a repris ce que
  // j'avais acheté ».
  await PremiumService.charger(StorageService.currentUser?.id ?? '');
  // Prépare (sans encore l'allumer) le service qui peut garder le mesh
  // actif même quand on a fermé l'app.
  MeshForegroundService.init();
  // Langue des notifications système AVANT de créer leurs canaux Android —
  // eux ne se renomment plus une fois créés (voir `notification_service.dart`).
  NotificationService.currentLocale = currentAppLocale();
  // Prépare le système qui affichera les vraies notifications Android
  // (message reçu, appel manqué, etc.).
  await NotificationService.init();
  // ⚠️ BRANCHÉ ICI, ET PAS À L'OUVERTURE D'UNE DISCUSSION. Quand on tape
  // une réponse dans le volet alors que Droplet est mort, Android relance
  // l'application et transmet le texte quelques millisecondes après le
  // démarrage. Brancher plus tard, c'est recevoir la réponse sans personne
  // pour l'écouter — et le message tapé est perdu sans un mot.
  // On OUVRE L'OREILLE ici, on ne traite pas encore : l'arbre de widgets
  // n'existe pas, donc il n'y a personne à qui demander d'envoyer. Ce qui
  // arrive est mis de côté, et `brancher` le reprendra au montage.
  NotifsConversation.ecouter();
  // Réveil par notification push (Firebase Cloud Messaging) — pour les
  // messages et appels qui arrivent alors que Droplet n'est plus du tout
  // en train de tourner.
  //
  // ⚠️ CE COMMENTAIRE A LONGTEMPS AFFIRMÉ « jamais bloquant » ALORS QUE
  // C'ÉTAIT FAUX : `init()` attendait `getToken()`, un enregistrement
  // réseau auprès de FCM, et `runApp()` attendait `init()`. La première
  // ouverture de Droplet SANS INTERNET restait donc sur un écran vide le
  // temps que le SDK épuise ses tentatives. Le réseau a été sorti du
  // chemin de démarrage — voir la doc de `PushNotificationService.init`.
  // Ne remets jamais d'`await` réseau ici : c'est le seul endroit de
  // l'application où une seconde perdue est une seconde d'écran noir.
  await PushNotificationService.init();
  // Les tonalités courtes de l'app (message envoyé/reçu, lien établi,
  // urgence…). Sans effet si l'appareil n'a pas de sortie audio ; jamais
  // bloquant. Voir `sound_service.dart`.
  await SoundService.init();
  // ⚠️ DOIT ÊTRE ENREGISTRÉ AU NIVEAU RACINE, AVANT `runApp`.
  //
  // C'est la référence qu'Android utilise pour réveiller un isolate
  // séparé quand un push arrive app fermée — l'enregistrer plus tard, ou
  // depuis un widget, ne fonctionnerait qu'en premier plan.
  FirebaseMessaging.onBackgroundMessage(gererMessageArrierePlan);
  // Précompile le shader liquide en tâche de fond. Sans ce préchargement,
  // la toute première transition se jouerait sans effet (le temps que le
  // GPU compile le programme), ce qui donnerait l'impression que l'effet
  // « ne marche qu'une fois sur deux ». On n'attend PAS le résultat : si
  // la compilation échoue ou traîne, l'app démarre normalement, sans
  // l'effet.
  // ⚠️ On ne compile le shader QUE s'il va servir. Sur un appareil
  // modeste, le verre liquide est désactivé (voir `ouroGlassDegraded`) :
  // compiler quand même un programme graphique qu'on n'affichera jamais,
  // c'est payer le coût sans le bénéfice.
  if (!DeviceProfile.sansShader) unawaited(LiquidShader.load());
  // ⚠️ PLUS DE PRÉCOMPILATION DE SHADER POUR NEXUS (connexion entre
  // appareils) — la séquence de connexion ne s'appuie plus sur un
  // fragment shader GLSL. Voir l'en-tête de
  // `features/nexus_connection/nexus_pulse.dart` : c'était la cause la
  // plus probable des plantages observés sur certains appareils.
  // Recense les stickers animés (.tgs / .json Lottie) déposés dans
  // `assets/stickers/`. Rapide — c'est une lecture d'index, pas de
  // fichiers — et sans conséquence si le dossier est vide, ce qui est
  // le cas par défaut.
  await AnimatedStickerCatalog.charger();
  // Et on allume vraiment l'application ! `ProviderScope` est la boîte
  // magique de Riverpod qui permet à toutes les pages de l'app de partager
  // des informations (qui je suis, mes messages, mes contacts...) sans
  // avoir à se les passer à la main.
  runApp(const ProviderScope(child: DropletApp()));
}

/// Le widget racine de toute l'application — la « coquille » qui contient
/// absolument tout le reste. Un widget, en Flutter, c'est simplement un
/// morceau d'interface (un bouton, un texte, une page entière...).
class DropletApp extends ConsumerWidget {
  const DropletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Le réglage d'apparence choisi par l'utilisateur (Automatique / Clair
    // / Sombre — sombre par défaut, voir `appearance_provider.dart`).
    final appearance = ref.watch(appearanceProvider);

    // La personnalisation (accent, taille du texte, arrondi des bulles…) :
    // posée avant tout affichage, comme la luminosité ci-dessous.
    ref.watch(personnalisationProvider).appliquer();
    // Beaucoup d'écrans lisent l'accent en statique, sans dépendre du
    // thème : un changement de réglage doit les reconstruire tous, une fois.
    ref.listen(personnalisationProvider, (avant, apres) {
      if (avant == apres) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        void reconstruire(Element e) {
          e.markNeedsBuild();
          e.visitChildren(reconstruire);
        }
        if (context.mounted) (context as Element).visitChildren(reconstruire);
      });
    });

    // En mode « Automatique », on suit le téléphone ; sinon le choix
    // explicite de l'utilisateur l'emporte.
    final brightness = appearance.resolve(
      MediaQuery.platformBrightnessOf(context),
    );

    // ⚠️ ORDRE IMPORTANT : `OuroColors` est consulté de partout dans l'app
    // sous forme d'accesseurs statiques (`OuroColors.label`, etc.) plutôt
    // qu'à travers le `Theme` de Flutter. Il faut donc lui dire dans quel
    // mode on se trouve AVANT de construire le moindre widget qui
    // l'interroge — d'où cet appel juste ici, à la racine, avant le
    // `return`.
    OuroColors.setBrightness(brightness);
    // Idem pour les barres système d'Android (heure, batterie, boutons de
    // navigation) : elles doivent s'inverser avec le mode.
    OuroTheme.applySystemOverlay(brightness);

    // `MaterialApp.router` est le widget qui dit à Flutter « voici une
    // application complète, avec un thème (des couleurs) et un système de
    // pages (le routeur, défini plus bas dans ce fichier) ».
    // `LiquidThemeProvider` enveloppe le MaterialApp pour fournir le thème
    // Liquid Glass à TOUS les composants liquid_glass_ui_design de l'app.
    return LiquidThemeProvider(
      theme: liquidTheme,
      child: MaterialApp.router(
        title: 'Droplet',
        debugShowCheckedModeBanner: false,
        theme: OuroTheme.of(brightness),
        scrollBehavior: const OuroScrollBehavior(),
        routerConfig: _router,
        // ── LA LANGUE DE L'INTERFACE ─────────────────────────────────
        //
        // `resolveLocale` retombe sur le français si l'utilisateur n'a
        // rien choisi ET que la langue du téléphone ne fait pas partie
        // des dix prises en charge — jamais sur un choix arbitraire de
        // Flutter. Voir `locale_provider.dart`.
        locale: () {
          final effective = resolveLocale(ref.watch(localeProvider));
          // Les canaux Android sont figés dès leur création, mais le
          // TITRE et le CORPS de chaque notification sont composés à
          // l'instant de l'appel — eux peuvent donc suivre un changement
          // de langue fait sans redémarrer l'app.
          NotificationService.currentLocale = effective;
          return effective;
        }(),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // ── LE MOTEUR DE MOUVEMENT, POSÉ UNE FOIS POUR TOUTE L'APP ────
        //
        // ⚠️ C'est ce qui fait enfin exister « Réduire les animations »
        // dans Droplet. Le réglage d'accessibilité iOS n'était lu qu'à UN
        // seul endroit sur 161 fichiers (`premium_screen.dart`) : un
        // utilisateur sujet au mal des transports, aux migraines ou aux
        // troubles vestibulaires activait le réglage, et l'application
        // continuait à tout faire voler et rebondir.
        //
        // Il est ici plutôt qu'autour du `MaterialApp` parce qu'il lui
        // faut un `MediaQuery` au-dessus de lui, et c'est le
        // `MaterialApp` qui l'installe.
        //
        // `degraded` est branché sur la MÊME source de vérité que le
        // verre (`ouroGlassDegraded`) : appareil sans shader ou en stress
        // thermique. Le mouvement se simplifie AVANT que la cadence ne
        // tombe, au lieu d'attendre les saccades.
        builder: (context, child) => DefaultTextStyle(
          // ⚠️ LES DOUBLES SOULIGNEMENTS JAUNES. Flutter les dessine sous tout
          // texte qui n'a pas de `Material` au-dessus de lui : les toasts, les
          // bandeaux d'appel et tout ce qui vit dans une surcouche. Un style
          // par défaut posé ICI, au-dessus du navigateur et de toutes les
          // surcouches, leur en donne un propre ; les écrans, eux, gardent
          // celui de leur `Scaffold`.
          style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
              .copyWith(decoration: TextDecoration.none),
          child: OuroMotionScope(
          // Animations d'ambiance : coupées seulement sur un appareil modeste
          // ou en surchauffe — plus du seul fait qu'il n'ait pas le verre
          // liquide (un téléphone « moyen » perdait toutes ses animations).
          degraded: DeviceProfile.menager || ref.watch(deviceUnderThermalStressProvider),
          child: NexusHost(
            child: ToastOverlay(
              child: MeshBootstrap(
                child: NotificationBridge(
                  child: IncomingCallOverlay(
                    child: GroupIncomingCallOverlay(
                      // ── LES BANNIÈRES DE MESSAGES ─────────────────────
                      //
                      // SOUS les appels entrants (une sonnerie reste ce qu'il
                      // y a de plus important à l'écran), AU-DESSUS de tout
                      // le reste. `push` plutôt que `go` : toucher une
                      // bannière doit pouvoir se défaire d'un retour, comme
                      // sur iOS — `go` effaçait l'écran qu'on quittait.
                      child: CoucheBannieres(
                        naviguer: (route) => _router.push(route),
                        repondre: NotificationService.repondre,
                      // ⚠️ SOUS les fenêtres d'appel entrant, pas au-dessus.
                      // Le bandeau annonce un appel DÉJÀ pris ; une sonnerie
                      // entrante doit rester la chose la plus visible de
                      // l'écran, et deux surcouches empilées en haut se
                      // masqueraient l'une l'autre.
                      child: BandeauAppelOverlay(
                        routeur: _router,
                        child: RepaintBoundary(
                          // ⚠️ CE BOUNDARY EST LA SOURCE DE L'INSTANTANÉ DE
                          // TRANSITION DE THÈME.
                          // `ModeTransitionOverlay.capture()` le lit pour
                          // prendre une photo de l'écran AVANT que le thème ne
                          // change, comme Telegram. Ne pas le retirer ni le
                          // remplacer par un enfant simple.
                          key: ModeTransitionOverlay.repaintBoundaryKey,
                          child: KeyedSubtree(
                            key: ValueKey(brightness),
                            child: child ?? const SizedBox(),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// Overlay plein écran d'appel entrant (accepte/refuse).
///
/// Un « overlay », c'est une fenêtre qui s'affiche PAR-DESSUS l'écran
/// actuel, comme un post-it collé sur une page de cahier. Celui-ci
/// surveille en permanence « est-ce que quelqu'un est en train de
/// m'appeler ? » et, si oui, recouvre tout l'écran avec la fenêtre
/// « Appel entrant » — peu importe la page où on se trouvait.
class IncomingCallOverlay extends ConsumerWidget {
  const IncomingCallOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On regarde l'état actuel des appels (comme regarder un tableau
    // d'affichage qui se met à jour tout seul).
    final call = ref.watch(callProvider);
    // On n'affiche la fenêtre d'appel entrant QUE si toutes ces conditions
    // sont vraies en même temps : un appel est actif, il vient de
    // quelqu'un d'autre (pas moi qui appelle), il est encore en train de
    // sonner (pas encore décroché), et on sait qui appelle.
    final showIncoming =
        call.isCallActive &&
        call.direction == CallDirection.incoming &&
        call.connectionState == CallConnectionState.connecting &&
        // Décroché : la fenêtre s'efface tout de suite, l'écran d'appel
        // affiche « Connexion… ».
        !call.decroche &&
        call.peerId != null;

    // `Stack` empile des widgets les uns sur les autres, comme des
    // transparents posés sur un rétroprojecteur. Ici : l'écran normal en
    // dessous, et par-dessus (seulement si `showIncoming` est vrai) la
    // fenêtre d'appel qui recouvre tout.
    return Stack(
      children: [
        child,
        if (showIncoming)
          Positioned.fill(
            child: _IncomingCallView(
              peerId: call.peerId!,
              onAccept: () {
                ref.read(callProvider.notifier).answerCall();
                // ⚠️ `_router`, PAS `context.go` : cette fenêtre est posée
                // AU-DESSUS du routeur (dans `builder` de MaterialApp.router),
                // son contexte ne le voit pas — décrocher plantait (« Null
                // check operator » dans GoRouter.of) et l'écran d'appel ne
                // s'ouvrait jamais.
                _router.go('/call/${call.peerId}');
              },
              onReject: () => ref.read(callProvider.notifier).hangUp(),
            ),
          ),
      ],
    );
  }
}

/// Le dessin de la fenêtre « Appel entrant » elle-même : le logo qui
/// respire, le nom de la personne, et les deux gros boutons ronds
/// (raccrocher en rouge / décrocher en vert).
class _IncomingCallView extends ConsumerWidget {
  const _IncomingCallView({
    required this.peerId,
    required this.onAccept,
    required this.onReject,
  });

  final String peerId;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // On demande « comment s'appelle cette personne ? » à partir de son
    // identifiant technique (une longue suite de lettres/chiffres que
    // l'utilisateur ne voit jamais).
    final pseudo = ref.watch(peerPseudoProvider(peerId));
    final call = ref.watch(callProvider);
    return Scaffold(
      // Noir fixe, même quand l'app est en mode clair : voir
      // `OuroColors.callBackground` pour le pourquoi.
      backgroundColor: OuroColors.callBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Un joli dégradé de couleur en fond, comme un ciel qui s'assombrit.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [OuroColors.callGlow, OuroColors.callBackground],
              ),
            ),
          ),
          // Des petits ronds qui s'agrandissent doucement, comme des ronds
          // dans l'eau — pour montrer que ça sonne « en direct ».
          const Positioned.fill(child: DropletRipples(active: true)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  call.isVideoEnabled ? l10n.clIncomingVideoCall : l10n.ntfIncomingCall,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OuroColors.callSecondaryLabel,
                  ),
                ),
                const Spacer(),
                const DropletLogo(radius: 62, glow: true),
                const SizedBox(height: 24),
                PeerAvatar(
                  pseudo: pseudo,
                  radius: 48,
                  online: true,
                  imagePath: AvatarService.cheminPair(peerId),
                ),
                const SizedBox(height: 16),
                Text(
                  pseudo,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: OuroColors.callLabel,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  call.isRemoteCall ? l10n.clViaInternet : l10n.mnMeshVoiceCall,
                  style: TextStyle(
                    fontSize: 14,
                    color: OuroColors.callSecondaryLabel,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IncomingButton(
                      icon: Icons.call_end_rounded,
                      color: OuroColors.errorRed,
                      label: l10n.ntfDecline,
                      onTap: onReject,
                    ),
                    _IncomingButton(
                      icon: call.isVideoEnabled ? Icons.videocam_rounded : Icons.call_rounded,
                      color: OuroColors.successGreen,
                      label: l10n.mnAccept,
                      onTap: onAccept,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay plein écran d'invitation à un appel de groupe (accepte/refuse).
///
/// Même idée que [IncomingCallOverlay] juste au-dessus, mais pour les
/// appels avec PLUSIEURS personnes en même temps au lieu d'une seule.
class GroupIncomingCallOverlay extends ConsumerWidget {
  const GroupIncomingCallOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Déclenche une reconstruction quand une invitation arrive : l'état
    // observable (GroupCallState) ne porte pas l'invitation elle-même
    // (stockée sur le notifier), mais est réémis à chaque changement.
    ref.watch(groupCallProvider);
    final notifier = ref.read(groupCallProvider.notifier);
    final invite = notifier.pendingInvite;

    return Stack(
      children: [
        child,
        if (invite != null)
          Positioned.fill(
            child: _GroupIncomingCallView(
              fromPeerId: invite.fromPeerId,
              participantCount: invite.participants.length,
              onAccept: () {
                notifier.acceptInvite(
                  pseudoFor: (id) => ref.read(peerPseudoProvider(id)),
                );
                // Même raison que pour l'appel 1:1 : `_router`, pas `context`.
                _router.go('/group-call');
              },
              onReject: () => notifier.declineInvite(),
            ),
          ),
      ],
    );
  }
}

/// Le dessin de la fenêtre « Appel de groupe entrant » (même esprit que
/// [_IncomingCallView], avec le nombre de participants en plus).
class _GroupIncomingCallView extends ConsumerWidget {
  const _GroupIncomingCallView({
    required this.fromPeerId,
    required this.participantCount,
    required this.onAccept,
    required this.onReject,
  });

  final String fromPeerId;
  final int participantCount;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pseudo = ref.watch(peerPseudoProvider(fromPeerId));
    return Scaffold(
      backgroundColor: OuroColors.callBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [OuroColors.callGlow, OuroColors.callBackground],
              ),
            ),
          ),
          const Positioned.fill(child: DropletRipples(active: true)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  l10n.mnGroupCallIncoming,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OuroColors.callSecondaryLabel,
                  ),
                ),
                const Spacer(),
                const DropletLogo(radius: 62, glow: true),
                const SizedBox(height: 24),
                PeerAvatar(
                  pseudo: pseudo,
                  radius: 48,
                  online: true,
                  imagePath: AvatarService.cheminPair(fromPeerId),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.mnInvitesYou(pseudo),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: OuroColors.callLabel,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.mnGroupCallOtherParticipants(participantCount),
                  style: TextStyle(
                    fontSize: 14,
                    color: OuroColors.callSecondaryLabel,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IncomingButton(
                      icon: Icons.call_end_rounded,
                      color: OuroColors.errorRed,
                      label: l10n.ntfDecline,
                      onTap: onReject,
                    ),
                    _IncomingButton(
                      icon: Icons.call_rounded,
                      color: OuroColors.successGreen,
                      label: l10n.mnAccept,
                      onTap: onAccept,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un des deux gros boutons ronds (raccrocher/décrocher) : une icône dans
/// un cercle coloré avec une ombre, et un petit mot en dessous.
class _IncomingButton extends StatelessWidget {
  const _IncomingButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // `GestureDetector` transforme n'importe quel dessin en bouton
        // cliquable : dès qu'on tapote dedans, `onTap` se déclenche.
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: OuroColors.callSecondaryLabel),
        ),
      ],
    );
  }
}

// ============================================================================
// LE ROUTEUR — LA CARTE AU TRÉSOR DE TOUTES LES PAGES
// ----------------------------------------------------------------------------
// `GoRouter` est un peu comme le plan d'un centre commercial : chaque
// « chemin » (par exemple `/chat/123`) correspond à une pièce précise
// (ici, la conversation avec la personne n°123). Quand le code fait
// `context.go('/chat/123')` n'importe où dans l'app, c'est CETTE liste qui
// décide quelle page dessiner.
// ============================================================================
final _router = GoRouter(
  // Les liens s'ouvrent dans l'app même depuis un widget sans contexte.
  navigatorKey: cleNavigateurRacine,
  // La toute première page qu'on voit en ouvrant l'app.
  initialLocation: '/',
  // `redirect` s'exécute AVANT chaque changement de page, et peut décider
  // de rediriger ailleurs — un peu comme un videur à l'entrée d'une boîte
  // qui vérifie si tu as le droit d'entrer, et t'envoie ailleurs sinon.
  redirect: (context, state) {
    // La racine '/' a maintenant sa propre route (SplashScreen) : elle gère
    // elle-même sa redirection après sa courte chorégraphie d'entrée, donc
    // on la laisse passer ici plutôt que de la court-circuiter comme avant.
    if (state.matchedLocation == '/') return null;
    // Est-ce qu'on a déjà créé une identité sur cet appareil ?
    final loggedIn = StorageService.hasIdentity;
    final onBoarding = state.matchedLocation == '/onboarding';
    // Pas encore d'identité → direction la page de création de compte.
    if (!loggedIn) return onBoarding ? null : '/onboarding';
    // Déjà une identité, mais on est encore sur la page de création →
    // direction la liste des discussions.
    if (onBoarding) return '/chats';
    return null;
  },
  // Filet de sécurité : toute localisation inconnue (deep link périmé, état
  // de navigation restauré par l'OS après réinstallation/mise à jour, etc.)
  // ne doit jamais faire planter l'app — on revient à l'écran principal
  // plutôt que de laisser GoRouter lever une exception non rattrapée.
  errorBuilder: (context, state) => StorageService.hasIdentity
      ? const ChatsScreen()
      : const OnboardingScreen(),
  // La liste de toutes les pages de l'app, chacune associée à son
  // « adresse » (le chemin) et à la manière dont elle apparaît à l'écran
  // (la transition — fondu, glissement, etc., définies plus bas).
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadePage(const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      // Premier écran après le démarrage : c'est LE moment où la
      // transition liquide se justifie (voir `_liquidPage`).
      pageBuilder: (context, state) => _liquidPage(const OnboardingScreen()),
    ),
    GoRoute(
      path: '/chats',
      pageBuilder: (context, state) => _estLarge(context)
          ? const NoTransitionPage<void>(child: _DeuxVolets())
          : _fadePage(const HomeShell()),
    ),
    // Lien d'invitation : `droplet://droplet/invite?d=…` (voir `invitation.dart`).
    GoRoute(
      path: '/invite',
      pageBuilder: (context, state) => _pushPage(
        InvitationScreen(donnees: state.uri.queryParameters['d']),
      ),
    ),
    // ══ LA BULLE FLOTTANTE ════════════════════════════════════════
    //
    // ⚠️ UNE VUE RÉDUITE, PAS L'APPLICATION. Une bulle est une fenêtre de
    // 600 points posée sur une AUTRE application. Y servir l'écran complet
    // donnerait accès aux réglages, aux statuts et au maillage dans un
    // hublot — ce qui n'a de sens pour personne, et qui laisse surtout la
    // possibilité de se perdre dans une fenêtre dont on ne peut pas
    // revenir : il n'y a pas de bouton « retour » dans une bulle.
    //
    // La conversation s'affiche donc seule, sans barre de navigation, et
    // `bulle: true` dit à l'écran de masquer tout ce qui mène ailleurs.
    GoRoute(
      path: '/bulle/:peerId',
      pageBuilder: (context, state) => NoTransitionPage<void>(
        child: ChatScreen(
          key: ValueKey('bulle-${state.pathParameters['peerId']}'),
          peerId: state.pathParameters['peerId'] ?? '',
          enBulle: true,
        ),
      ),
    ),
    GoRoute(
      // Le `:peerId` est une case vide dans l'adresse, remplie avec le
      // vrai identifiant de la personne au moment d'y aller — comme une
      // adresse postale avec un numéro de maison qui change.
      path: '/chat/:peerId',
      pageBuilder: (context, state) {
        final ecran = ChatScreen(
          key: ValueKey('chat-${state.pathParameters['peerId']}'),
          peerId: state.pathParameters['peerId'] ?? '',
          messageCible: state.uri.queryParameters['message'],
        );
        return _estLarge(context)
            ? NoTransitionPage<void>(child: _DeuxVolets(detail: ecran))
            : _pushPage(ecran);
      },
    ),
    GoRoute(
      path: '/chat/:peerId/info',
      pageBuilder: (context, state) => _pushPage(
        ChatInfoScreen(peerId: state.pathParameters['peerId'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/chat/:peerId/security',
      pageBuilder: (context, state) => _pushPage(
        SecurityCodeScreen(peerId: state.pathParameters['peerId'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/starred',
      pageBuilder: (context, state) => _pushPage(const MessagesImportantsScreen()),
    ),
    GoRoute(
      path: '/group/create',
      pageBuilder: (context, state) => _modalPage(const GroupCreateScreen()),
    ),
    GoRoute(
      path: '/backup/export',
      pageBuilder: (context, state) => _pushPage(const BackupExportScreen()),
    ),
    GoRoute(
      path: '/contribution',
      pageBuilder: (context, state) => _pushPage(const ContributionScreen()),
    ),
    GoRoute(
      path: '/map',
      pageBuilder: (context, state) => _pushPage(const MapScreen()),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/settings/apparence',
      pageBuilder: (context, state) => _pushPage(const ApparenceScreen()),
    ),
    GoRoute(
      path: '/settings/icon',
      pageBuilder: (context, state) => _pushPage(const AppIconScreen()),
    ),
    GoRoute(
      path: '/maps/offline',
      pageBuilder: (context, state) => _pushPage(const OfflineMapsScreen()),
    ),
    GoRoute(
      path: '/mesh-network',
      pageBuilder: (context, state) => _pushPage(const MeshNetworkScreen()),
    ),
    GoRoute(
      path: '/share-target',
      pageBuilder: (context, state) => _modalPage(const ShareTargetScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _pushPage(const SettingsScreen()),
    ),
    GoRoute(
      path: '/settings/notifications',
      pageBuilder: (context, state) => _pushPage(const ReglagesNotifsScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _pushPage(const CentreNotifsScreen()),
    ),
    GoRoute(
      path: '/inviter',
      pageBuilder: (context, state) => _pushPage(const InviterScreen()),
    ),
    // ── AIDE, CONFIDENTIALITÉ, CONTACT ───────────────────────────
    //
    // Quatre écrans qui n'ont besoin d'aucun réseau : les réponses, les
    // textes légaux et les coordonnées sont embarqués.
    GoRoute(
      path: '/aide/contact',
      pageBuilder: (context, state) => _pushPage(const ContactScreen()),
    ),
    GoRoute(
      path: '/aide/confidentialite',
      pageBuilder: (context, state) => _pushPage(const PolitiqueScreen()),
    ),
    GoRoute(
      path: '/aide/donnees',
      pageBuilder: (context, state) => _pushPage(const DonneesScreen()),
    ),
    // ⚠️ APRÈS SES ENFANTS. `go_router` prend la PREMIÈRE route qui
    // correspond : déclarée avant, `/aide` ne capterait pas
    // `/aide/contact`, mais garder l'ordre parent-après-enfants est la
    // règle sûre quand les chemins se préfixent.
    GoRoute(
      path: '/aide',
      pageBuilder: (context, state) => _pushPage(const AideScreen()),
    ),
    GoRoute(
      path: '/settings/appareils',
      pageBuilder: (context, state) => _pushPage(const AppareilsLiesScreen()),
    ),
    GoRoute(
      path: '/settings/storage',
      pageBuilder: (context, state) => _pushPage(const StockageScreen()),
    ),
    GoRoute(
      path: '/tor',
      pageBuilder: (context, state) => _pushPage(const TorSettingsScreen()),
    ),
    GoRoute(
      path: '/tor/qr',
      pageBuilder: (context, state) => _pushPage(const QrGeneratorScreen()),
    ),
    GoRoute(
      path: '/tor/scan',
      pageBuilder: (context, state) => _pushPage(const QrScannerScreen()),
    ),
    GoRoute(
      path: '/safety',
      pageBuilder: (context, state) => _pushPage(const SafetyScreen()),
    ),
    GoRoute(
      path: '/ai-chat',
      // `extra` porte un éventuel AiSeed — le contexte d'une conversation
      // avec un pair quand on ouvre l'assistant depuis « Demander à
      // l'assistant » (voir chat_screen.dart). `null` pour une ouverture
      // normale depuis l'onglet Discussions.
      pageBuilder: (context, state) => _pushPage(
        AiChatScreen(
          seed: state.extra is AiSeed ? state.extra as AiSeed : null,
        ),
      ),
    ),
    GoRoute(
      path: '/status/:authorId',
      pageBuilder: (context, state) => pageZoomStatut(
        key: state.pageKey,
        child: StatusPagerScreen(authorId: state.pathParameters['authorId'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/group/:groupId',
      pageBuilder: (context, state) {
        final ecran = ChatScreen(
          key: ValueKey('group-${state.pathParameters['groupId']}'),
          groupId: state.pathParameters['groupId'] ?? '',
          messageCible: state.uri.queryParameters['message'],
        );
        return _estLarge(context)
            ? NoTransitionPage<void>(child: _DeuxVolets(detail: ecran))
            : _pushPage(ecran);
      },
    ),
    GoRoute(
      path: '/group/:groupId/info',
      pageBuilder: (context, state) => _pushPage(
        GroupInfoScreen(groupId: state.pathParameters['groupId'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/call/:peerId',
      // Un appel sortant vers un contact bloqué ne part pas, d'où qu'il soit
      // lancé (fiche du contact, journal des appels…) : retour à la
      // discussion, qui affiche le bandeau « bloqué ».
      redirect: (context, state) {
        final id = state.pathParameters['peerId'] ?? '';
        final entrant = state.uri.queryParameters['entrant'] == '1';
        return !entrant && StorageService.isContactBlocked(id) ? '/chat/$id' : null;
      },
      pageBuilder: (context, state) => _scaleFadePage(
        CallScreen(
          peerId: state.pathParameters['peerId'] ?? '',
          video: state.uri.queryParameters['video'] == '1',
          entrant: state.uri.queryParameters['entrant'] == '1',
        ),
      ),
    ),
    GoRoute(
      path: '/group-call',
      pageBuilder: (context, state) => _scaleFadePage(const GroupCallScreen()),
    ),
    GoRoute(
      path: '/new-message',
      pageBuilder: (context, state) => _modalPage(const NewMessageScreen()),
    ),
    GoRoute(
      path: '/discover',
      pageBuilder: (context, state) => _modalPage(const DiscoverScreen()),
    ),
    GoRoute(
      path: '/emergency',
      pageBuilder: (context, state) => _modalPage(const EmergencyModeScreen()),
    ),
    GoRoute(path: '/:unknown', redirect: (context, state) => '/chats'),
  ],
);

/// ENTRER DANS QUELQUE CHOSE — la navigation hiérarchique d'iOS.
///
/// ── Pourquoi ce n'est pas un détail ───────────────────────────────────
///
/// Sur iOS, ouvrir une conversation, un réglage ou une fiche fait
/// GLISSER LA PAGE DEPUIS LA DROITE, pendant que la précédente recule
/// d'un tiers vers la gauche en s'assombrissant. Ce décalage entre les
/// deux plans dit, sans un mot, « tu es entré d'un cran ». Et surtout :
/// on revient en TIRANT DEPUIS LE BORD GAUCHE, la page suivant le doigt,
/// annulable en cours de route.
///
/// Toutes ces pages arrivaient jusqu'ici par un fondu avec un léger
/// glissement vers le haut — la même transition pour tout, sans notion
/// de profondeur, et sans le moindre geste de retour. C'est le genre de
/// détail qu'on ne sait pas nommer mais qui fait dire « ça ne fait pas
/// natif » dès la première navigation.
///
/// `CupertinoPage` apporte les deux d'un coup : le mouvement exact et le
/// geste de retour interactif.
// ── TABLETTE ET GRAND ÉCRAN : LA LISTE ET LA CONVERSATION CÔTE À CÔTE ──
//
// Sur un écran large, ouvrir une conversation en plein écran gaspille les
// deux tiers de la place et oblige à revenir en arrière pour en changer.
// Comme WhatsApp et Telegram sur tablette : la liste reste à gauche, la
// conversation s'ouvre à droite. En dessous de 840 points (téléphone, même
// en paysage), rien ne change.
bool _estLarge(BuildContext context) => MediaQuery.sizeOf(context).width >= 840;

class _DeuxVolets extends StatelessWidget {
  const _DeuxVolets({this.detail});

  /// La conversation ouverte, ou rien (on invite à en choisir une).
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final largeur = MediaQuery.sizeOf(context).width;
    return ColoredBox(
      color: OuroColors.systemBackground,
      child: Row(
        children: [
          SizedBox(
            width: (largeur * 0.36).clamp(320.0, 420.0),
            child: const HomeShell(),
          ),
          VerticalDivider(width: 0.5, thickness: 0.5, color: OuroColors.separator),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              child: detail ??
                  Center(
                    key: const ValueKey('aucune-conversation'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const DropletLogo(radius: 40),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tabSelectChat,
                          style: TextStyle(color: OuroColors.secondaryLabel, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

CupertinoPage<void> _pushPage(Widget child) =>
    CupertinoPage<void>(child: child);

/// PRÉSENTER PAR-DESSUS — la feuille modale d'iOS.
///
/// À réserver aux pages qui ne sont pas un cran plus profond mais une
/// PARENTHÈSE : composer, choisir un destinataire, déclencher une
/// alerte. Elles montent depuis le bas et se referment par un bouton,
/// pas par le geste de retour — précisément parce qu'on ne veut pas
/// qu'on en sorte par mégarde.
CupertinoPage<void> _modalPage(Widget child) =>
    CupertinoPage<void>(child: child, fullscreenDialog: true);

/// Transition LIQUIDE — une onde traverse l'écran en le déformant pendant
/// que la page apparaît (voir `ouro_liquid.dart` et `shaders/liquid.frag`).
///
/// Volontairement réservée à l'ENTRÉE DANS L'APP, un moment unique et
/// marquant. L'appliquer à chaque navigation la rendrait fatigante en
/// quelques minutes : une déformation d'écran attire fortement l'œil, et
/// ce qui impressionne au premier passage agace au vingtième.
CustomTransitionPage<void> _liquidPage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return LiquidPageTransition(animation: animation, child: child);
    },
  );
}

/// Transition fade simple (chats ↔ onboarding) : la nouvelle page apparaît
/// tout doucement, comme une lumière qu'on allume petit à petit.
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

/// Transition scale + fade (écran d'appel, type iOS) : la page grandit
/// légèrement en même temps qu'elle apparaît, comme un zoom doux.
CustomTransitionPage<void> _scaleFadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Démarre le mesh (le réseau qui connecte les téléphones entre eux) une
/// seule fois au lancement, mais SEULEMENT si l'utilisateur a déjà une
/// identité (donc pas pendant la toute première création de compte).
///
/// Pense à ce widget comme au bouton « marche » caché derrière l'écran :
/// personne ne le voit, mais dès que l'app s'allume, il appuie une fois
/// sur ce bouton pour que le téléphone commence à chercher d'autres
/// appareils Droplet autour de lui.
class MeshBootstrap extends ConsumerStatefulWidget {
  const MeshBootstrap({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MeshBootstrap> createState() => _MeshBootstrapState();
}

class _MeshBootstrapState extends ConsumerState<MeshBootstrap> {
  @override
  void initState() {
    // `initState` est appelé UNE SEULE FOIS, dès que ce widget apparaît
    // pour la première fois — l'endroit parfait pour démarrer quelque
    // chose qui ne doit se produire qu'une fois.
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final user = StorageService.currentUser;
    // Personne n'est encore connecté (pas de compte créé) → on ne fait rien.
    if (user == null) return;
    final repo = ref.read(meshRepositoryProvider);
    // Allume vraiment le réseau mesh, avec mon identité.
    await repo.init(user.id, user.pseudo);
    // Branche aussi les systèmes d'appel (1 contre 1, puis en groupe) sur
    // ce même réseau, une fois qu'il est prêt.
    ref
        .read(callProvider.notifier)
        .init(repo.transport, repo: repo, signalingUrl: kSignalingUrl);
    ref.read(groupCallProvider.notifier).init(repo.transport, repo.myId, repo: repo);
    // Active le service premier plan pour garder le mesh en vie en
    // arrière-plan (sinon Android tue le processus après quelques minutes).
    MeshForegroundService.start().catchError(
      (e) => debugPrint('[MeshBootstrap] foreground service: $e'),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Relie les flux mesh existants (nouveaux messages, statuts, check-ins
/// d'urgence, appels) aux notifications système Android réelles, et suit le
/// cycle de vie de l'app pour ne jamais notifier ce que l'utilisateur
/// regarde déjà à l'écran. Additif : ne modifie aucune logique métier, se
/// contente d'observer les streams déjà exposés par [MeshRepository] et
/// [CallNotifier].
///
/// En mots simples : c'est le petit espion discret qui regarde tout ce qui
/// se passe dans le mesh (« un message est arrivé ! », « quelqu'un
/// t'appelle ! ») et qui, à chaque fois, décide s'il doit faire vibrer le
/// téléphone et afficher une notification — ou rester silencieux parce que
/// tu es déjà en train de regarder cette conversation.
class NotificationBridge extends ConsumerStatefulWidget {
  const NotificationBridge({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<NotificationBridge> createState() => _NotificationBridgeState();
}

class _NotificationBridgeState extends ConsumerState<NotificationBridge>
    with WidgetsBindingObserver {
  StreamSubscription<MeshMessage>? _msgSub;
  StreamSubscription<MeshStatusRecord>? _statusSub;
  StreamSubscription<SafetyCheckinRecord>? _checkinSub;
  StreamSubscription<({String messageId, String emoji, String? auteurId})>?
      _reactionSub;
  ProviderSubscription<CallState>? _callSub;
  StreamSubscription<dynamic>? _nexusPeerSub;
  StreamSubscription<({String peerId, NexusEvent event})>? _nexusEventSub;
  Timer? _retryTimer;
  // Se souvient si l'appel entrant en cours a fini par être décroché, pour
  // savoir s'il faut afficher « appel manqué » quand il se termine.
  bool _incomingWasConnected = false;
  // Empêche de lancer plusieurs animations Nexus simultanément.
  bool _nexusAffiche = false;
  Timer? _nexusSafetyTimer;

  /// Envoie une réponse écrite depuis une notification.
  ///
  /// ⚠️ ELLE PASSE PAR LE MÊME CHEMIN QU'UN MESSAGE ORDINAIRE.
  ///
  /// La tentation serait d'écrire directement dans la base « puisque
  /// c'est plus simple ». Ce serait contourner le chiffrement, la file
  /// d'attente, les accusés de réception et la signature du trajet — et
  /// produire un message qui n'a l'air normal que dans la liste.
  ///
  /// Sans pair à portée, `sendMessage` met en attente de lui-même : la
  /// réponse repartira à la prochaine rencontre, exactement comme si
  /// elle avait été tapée dans l'application.
  Future<void> _repondreDepuisNotification(String route, String texte) async {
    final id = route.split('/').last;
    if (id.isEmpty) return;
    final moi = StorageService.currentUser?.pseudo ?? 'Moi';
    final notifier = ref.read(meshMessagesProvider.notifier);

    if (route.startsWith('/group/')) {
      await notifier.sendGroupMessage(moi, texte, groupId: id);
    } else {
      await notifier.sendMessage(moi, texte, targetId: id);
    }
  }

  /// Remet le drapeau à zéro quand la séquence Nexus quitte l'écran.
  ///
  /// ⚠️ POURQUOI CE N'EST PLUS UN `onComplete`. L'ancienne API prenait un
  /// rappel de fin ; la nouvelle passe par `NexusStage`, dont `NexusHost`
  /// efface la demande lui-même. Sans cet écouteur, `_nexusAffiche`
  /// resterait vrai après la toute première rencontre et AUCUNE séquence
  /// suivante ne se jouerait — jusqu'au filet de sécurité de douze
  /// secondes, qui aurait masqué la panne au lieu de la signaler.
  void _surChangementNexus() {
    if (NexusStage.current.value == null && _nexusAffiche) {
      _nexusAffiche = false;
      _nexusSafetyTimer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    NexusStage.current.addListener(_surChangementNexus);
    // S'abonne aux changements d'état de l'app (au premier plan / en
    // arrière-plan) pour toute la durée de vie de ce widget.
    WidgetsBinding.instance.addObserver(this);
    // L'app démarre au premier plan : le premier battement part tout de
    // suite, sinon on attendrait deux minutes pour paraître en ligne.
    BattementPresence.demarrer();
    NotificationService.isAppForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ||
        WidgetsBinding.instance.lifecycleState == null;
    // Quand l'utilisateur tapote sur une notification, on lui dit
    // comment naviguer vers la bonne page.
    NotificationService.bindNavigation((path) {
      if (!mounted) return;
      _router.go(path);
    });

    // ── RÉPONDRE ET DÉCROCHER SANS OUVRIR L'APPLICATION ────────────
    //
    // ⚠️ C'EST ICI, ET NULLE PART AILLEURS, QUE LE MAILLAGE EST
    // ACCESSIBLE.
    //
    // `NotificationService` ne connaît ni les providers ni le réseau, et
    // ne doit pas les connaître : c'est un afficheur de bulles. Quand
    // Android nous rend une réponse tapée, il la remet donc ici, au seul
    // endroit qui sait quoi en faire.
    NotificationService.bindActions(
      onRepondre: (route, texte) => _repondreDepuisNotification(route, texte),
      onLu: (route) {
        // Marquer lu envoie AUSSI les accusés de lecture, comme si on
        // avait ouvert la conversation. C'est la vérité : la personne a
        // lu le message dans la notification.
        final id = route.split('/').last;
        final messages = ref.read(meshMessagesProvider.notifier);
        // ⚠️ UN GROUPE N'A PAS LE MÊME CHEMIN DE LECTURE. `sendReadReceipts`
        // ignore tout message de groupe : « lu » depuis la notification
        // d'un groupe ne faisait rien, et la pastille restait.
        unawaited(route.startsWith('/group/')
            ? messages.envoyerLecturesGroupe(id)
            : messages.sendReadReceipts(id));
        unawaited(JournalNotifs.instance.marquerConversationLue(id));
      },
      onAppel: (peerId, accepter) {
        if (accepter) {
          // Décrocher depuis la notification DÉCROCHE : seul, `go` ouvrait
          // l'écran d'un appel qui continuait de sonner.
          // L'offre n'est peut-être pas encore arrivée (application qui
          // démarre) : elle sera prise dès réception.
          ref.read(callProvider.notifier).accepterDesQueLAppelArrive(peerId);
          // ⚠️ `entrant=1` : sans lui, l'écran d'appel, ne trouvant pas encore
          // d'appel actif, APPELAIT la personne en retour — deux appels
          // croisés, aucun n'aboutissait.
          _router.go('/call/$peerId?entrant=1');
        } else {
          ref.read(callProvider.notifier).hangUp();
        }
      },
    );

    // Les réponses écrites pendant que l'application était fermée. Le
    // rappel est branché AVANT le premier rejeu : sans lui,
    // `ReponsesDifferees.rejouer` ne touche à rien et les garde pour
    // plus tard, ce qui est le bon défaut mais pas le résultat voulu.
    ReponsesDifferees.onRejouer = (r) =>
        _repondreDepuisNotification(r.route, r.texte);
    unawaited(ReponsesDifferees.rejouer());
    // ── LES ANNONCES DU COMPTE OFFICIEL ─────────────────────────────
    //
    // ⚠️ `unawaited`, ET SANS BLOQUER LE DÉMARRAGE. Le serveur peut être
    // injoignable pendant vingt secondes ; attendre ici retarderait
    // l'affichage de la liste des conversations d'autant, pour une
    // nouveauté qui sort quelques fois par an. Le frein des douze heures
    // est dans `synchroniser`, pas ici.
    unawaited(AnnoncesDroplet.synchroniser(
      base: kDirectoryUrl,
      langue: currentAppLocale().languageCode,
    ));
    // Même chose pour les réponses tapées dans le volet de notifications
    // Android (`NotifConversations.kt`). On ne reçoit qu'un identifiant de
    // conversation : la route s'en déduit, puisqu'un groupe et une
    // personne ne se joignent pas par le même chemin.
    String routeDe(String id) =>
        StorageService.getGroup(id) != null ? '/group/$id' : '/chat/$id';
    unawaited(NotifsConversation.brancher(
      (id, texte) async {
        await _repondreDepuisNotification(routeDe(id), texte);
        // La réponse s'ajoute au fil de la notification — et le cercle
        // d'attente qu'Android y a posé s'arrête enfin.
        await NotificationService.apresReponse(id, texte);
      },
      surLu: (id) async {
        final messages = ref.read(meshMessagesProvider.notifier);
        await (StorageService.getGroup(id) != null
            ? messages.envoyerLecturesGroupe(id)
            : messages.sendReadReceipts(id));
        await NotificationService.oublierConversation(id);
        await JournalNotifs.instance.marquerConversationLue(id);
      },
      surReaction: (id, idMessage, emoji) async {
        ref.read(meshMessagesProvider.notifier).toggleReaction(idMessage, emoji);
        await NotificationService.oublierConversation(id);
      },
    ));
    // Écoute si une autre app essaie de « partager » du contenu vers
    // Droplet (texte, photo...) et prépare l'écran de choix du contact.
    unawaited(
      ShareIntentService.init(onShared: () => _router.go('/share-target')),
    );
    // Ouvert par un raccourci de conversation (appui long sur l'icône du
    // lanceur, ou bulle Android) : on va droit à la bonne conversation.
    unawaited(RaccourcisConversation.routeDeLancement().then((route) {
      if (route != null && route.startsWith('/')) _router.go(route);
    }));
    // ⚠️ ET LE MÊME CAS QUAND L'APP TOURNAIT DÉJÀ. La ligne au-dessus ne
    // s'exécute qu'une fois, à l'ouverture. Un appui sur la notification
    // d'appel alors que Droplet est seulement en arrière-plan passe par
    // `onNewIntent` côté Android, et n'avait jusqu'ici personne pour le
    // recevoir : on revenait sur l'écran quitté, pas sur l'appel.
    AppelSysteme.onRoute = _router.go;
    WidgetsBinding.instance.addPostFrameCallback((_) => _subscribe());
  }

  void _subscribe() {
    if (!mounted) return;
    // Comme MeshBootstrap._start(), on ne touche jamais au provider tant
    // qu'aucune identité n'existe : le lire construirait MeshRepository (et
    // son transport BLE/plateforme) prématurément — y compris en test, où
    // aucun canal de plateforme n'est disponible. Au premier lancement (pas
    // encore d'identité, onboarding en cours), on réessaie périodiquement :
    // ce widget racine n'est jamais reconstruit après la création du compte.
    if (StorageService.currentUser == null) {
      _retryTimer ??= Timer.periodic(
        const Duration(seconds: 2),
        (_) => _subscribe(),
      );
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = null;
    final repo = ref.read(meshRepositoryProvider);
    // Les noms qu'une notification de réveil saura afficher quand
    // l'application est fermée (voir `NotificationService.retenirNoms`).
    unawaited(NotificationService.retenirNoms({
      for (final p in StorageService.getKnownPeers()) p.peerId: p.pseudo,
      for (final g in StorageService.getGroups()) g.id: g.name,
      NotificationService.cleMoi: repo.myPseudo,
    }));
    // « Un nouveau message est arrivé ! » → on prépare une jolie petite
    // notification (avec un aperçu adapté : texte, 🎤 message vocal,
    // 📷 photo, ou 📎 fichier).
    _msgSub = repo.newMessageEvents.listen((msg) {
      if (msg.senderId == repo.myId) return;
      final conv = msg.groupId ?? msg.senderId ?? 'broadcast';
      // ⚠️ DANS LA LANGUE DE L'APPLICATION. Ces libellés étaient écrits
      // en dur en français : un utilisateur réglé en anglais recevait
      // « 📷 Photo » et « 🎤 Message vocal » dans ses notifications.
      final l10n = lookupAppLocalizations(NotificationService.currentLocale);
      final preview = msg.audioUrl != null
          ? l10n.nwVoiceMessage
          : msg.imageUrl != null
          ? l10n.nwPhoto
          // Une photo ou une vidéo s'annonce comme telle, jamais par le
          // nom brut de son fichier (« IMG_20260915_0712.jpg »).
          : msg.type == 'file' && mediaKindOf(msg.fileMimeType, msg.fileName) == MediaKind.image
          ? l10n.nwPhoto
          : msg.type == 'file' && mediaKindOf(msg.fileMimeType, msg.fileName) == MediaKind.video
          ? l10n.nwVideo
          : msg.type == 'file'
          // Un vocal reçu doit s'annoncer « 🎤 Message vocal ·
          // 0:12 » dans la notification, jamais avec son nom de
          // fichier brut (qui contient la forme d'onde encodée).
          ? VoiceNoteMeta.describeAttachment(msg.fileName)
          // Une position partagée s'annonce « 📍 Position
          // partagée », jamais avec ses coordonnées brutes.
          : LocationMessage.describe(msg.content);
      final groupe = msg.groupId != null;
      final nomGroupe =
          groupe ? StorageService.getGroup(msg.groupId!)?.name : null;
      final route = groupe ? '/group/$conv' : '/chat/$conv';
      // ── @MOI ────────────────────────────────────────────────────────
      //
      // Seulement dans un groupe : en tête-à-tête, TOUT s'adresse à moi,
      // et un « @Nico » n'y change rien.
      final mentionne = groupe &&
          msg.type == 'text' &&
          Mentions.concerne(msg.content, repo.myPseudo);
      if (mentionne) {
        unawaited(JournalNotifs.instance.ajouter(EntreeNotif(
          id: 'm:${msg.id}',
          type: TypeEntreeNotif.mention,
          conversationId: conv,
          route: route,
          auteur: msg.authorPseudo,
          auteurId: msg.senderId,
          texte: msg.content,
          groupe: true,
          nomConversation: nomGroupe,
          quand: msg.timestamp,
        )));
      }
      // ── LA BANNIÈRE ─────────────────────────────────────────────────
      //
      // Application ouverte, mais ailleurs que dans cette conversation.
      final decision = ReglagesNotifs.decider(
        conversationId: conv,
        groupe: groupe,
        mentionne: mentionne,
      );
      // Tonalité « message reçu » — UNIQUEMENT au premier plan. En
      // arrière-plan, c'est le son du canal de notification Android qui
      // s'en charge (via `showNewMessage` juste en dessous) : le jouer
      // ici aussi ferait double. Plus discret si la conversation
      // concernée est déjà ouverte à l'écran.
      //
      // ⚠️ ET PAS DU TOUT POUR UNE CONVERSATION QUI DOIT SE TAIRE. Elle
      // sonnait jusqu'ici même en sourdine : la sourdine ne coupait que la
      // notification système, pas la tonalité de l'application ouverte.
      final ouverte = NotificationService.openConversationId == conv;
      if (NotificationService.isAppForeground &&
          (ouverte || (decision.afficher && decision.sonore))) {
        SoundService.play(AppSound.messageIn, attenue: ouverte);
      }
      final banniere = NotificationService.isAppForeground &&
          NotificationService.openConversationId != conv &&
          decision.afficher &&
          decision.banniere;
      if (banniere) {
        Bannieres.montrer(DonneesBanniere(
          cle: conv,
          route: route,
          titre: nomGroupe ?? msg.authorPseudo,
          texte: decision.apercu ? preview : l10n.ntfNewMessage,
          auteur: msg.authorPseudo,
          auteurId: msg.senderId,
          groupeId: msg.groupId,
          monId: repo.myId,
          // L'officiel ne répond pas : rien à tirer vers le bas.
          repondable: msg.senderId != CompteDroplet.id,
        ));
      }
      unawaited(
        NotificationService.showNewMessage(
          conversationId: conv,
          pseudo: msg.authorPseudo,
          preview: preview,
          routePath: route,
          expediteurId: msg.senderId,
          nomGroupe: nomGroupe,
          horodatage: msg.timestamp,
          mentionne: mentionne,
          messageId: msg.id,
          banniereAffichee: banniere,
        ),
      );
    });
    // ── LES RÉACTIONS À MES MESSAGES ─────────────────────────────────────
    //
    // La liste des conversations n'en dit rien ; le centre de notifications,
    // si. Une réaction à un message qui n'est pas le mien n'a rien à faire
    // ici : dans un groupe, on recevrait celles de tout le monde.
    _reactionSub = repo.reactionAuteurEvents.listen((r) {
      final auteurId = r.auteurId;
      if (auteurId == null || auteurId == repo.myId) return;
      final cible = StorageService.getMessages()
          .where((m) => m.id == r.messageId)
          .firstOrNull;
      if (cible == null || cible.senderId != repo.myId) return;
      final groupe = cible.groupId != null;
      final conv = cible.groupId ?? cible.targetId ?? auteurId;
      final route = groupe ? '/group/$conv' : '/chat/$conv';
      final nomGroupe = groupe ? StorageService.getGroup(conv)?.name : null;
      final pseudo = ref.read(peerPseudoProvider(auteurId));
      final extrait = cible.type == 'text' ? cible.content : '';
      unawaited(JournalNotifs.instance.ajouter(EntreeNotif(
        id: 'r:${r.messageId}:$auteurId:${r.emoji}',
        type: TypeEntreeNotif.reaction,
        conversationId: conv,
        route: route,
        auteur: pseudo,
        auteurId: auteurId,
        texte: extrait,
        emoji: r.emoji,
        groupe: groupe,
        nomConversation: nomGroupe,
        quand: DateTime.now(),
      )));
      final decision = ReglagesNotifs.decider(
        conversationId: conv,
        groupe: groupe,
        mentionne: false,
      );
      if (NotificationService.isAppForeground &&
          NotificationService.openConversationId != conv &&
          decision.afficher &&
          decision.banniere) {
        final l10n = lookupAppLocalizations(NotificationService.currentLocale);
        Bannieres.montrer(DonneesBanniere(
          cle: 'reaction:$conv',
          route: route,
          titre: nomGroupe ?? pseudo,
          texte: extrait.isEmpty
              ? l10n.cnReacted(r.emoji)
              : '${l10n.cnReacted(r.emoji)} · ${l10n.cnQuoted(extrait)}',
          auteur: pseudo,
          auteurId: auteurId,
          groupeId: cible.groupId,
          monId: repo.myId,
        ));
      }
    });
    // ── LES ANNONCES DE DROPLET ──────────────────────────────────────────
    AnnoncesDroplet.surNouvelles = (nouvelles) {
      final langue = NotificationService.currentLocale.languageCode;
      for (final a in nouvelles) {
        final titre = a.pour(langue).titre;
        unawaited(JournalNotifs.instance.ajouter(EntreeNotif(
          id: 'n:${a.id}',
          type: TypeEntreeNotif.annonce,
          conversationId: CompteDroplet.id,
          route: '/chat/${CompteDroplet.id}',
          auteur: CompteDroplet.pseudo,
          auteurId: CompteDroplet.id,
          texte: titre,
          quand: a.quand,
        )));
      }
      if (nouvelles.isNotEmpty && NotificationService.isAppForeground) {
        final derniere = nouvelles.last;
        Bannieres.montrer(DonneesBanniere(
          cle: CompteDroplet.id,
          route: '/chat/${CompteDroplet.id}',
          titre: CompteDroplet.pseudo,
          texte: derniere.pour(langue).titre,
          auteurId: CompteDroplet.id,
        ));
      }
    };
    // ── LES SOURDINES QUI EXPIRENT, ET LE MIROIR DU PUSH ─────────────────
    unawaited(ReglagesNotifs.purgerExpirees());
    unawaited(ReglagesNotifs.synchroniserMiroir());
    ReglagesNotifs.revision.addListener(_surRevisionReglages);
    // « Quelqu'un a publié un nouveau statut ! » (comme les stories).
    _statusSub = repo.statusEvents.listen((status) {
      if (status.authorId == repo.myId) return;
      unawaited(
        NotificationService.showStatusPublished(
          pseudo: status.authorPseudo,
          authorId: status.authorId,
        ),
      );
    });
    // « Quelqu'un a signalé qu'il est en sécurité ! » (mode urgence).
    _checkinSub = repo.safetyCheckinEvents.listen((checkin) {
      if (checkin.peerId == repo.myId) return;
      // Le seul son de l'app qu'on s'autorise à jouer un peu fort — une
      // diffusion d'urgence est exactement le cas où on VEUT qu'il soit
      // remarqué.
      SoundService.play(AppSound.emergency);
      unawaited(NotificationService.showEmergency(pseudo: checkin.pseudo));
    });
    // ── NEXUS : animation de connexion ─────────────────────────────────
    //
    // Quand un NOUveau pair se connecte pour la première fois dans cette
    // session, on lance l'animation Nexus sur les DEUX appareils.
    // L'émetteur envoie un NexusEvent (seed + couleur) au destinataire,
    // et les deux jouent la même animation synchronisée.
    _nexusPeerSub = repo.firstPeerConnection.listen((peer) {
      if (_nexusAffiche) return;
      if (!mounted) return;
      if (!_premierLienAvec(peer.peerId)) return;
      _nexusAffiche = true;
      // Le petit « éclat » du premier lien avec un appareil — joué avant
      // même l'animation, à l'instant où la connexion se fait.
      SoundService.play(AppSound.connected);
      _startNexusSafetyTimer();

      final event = NexusEvent(
        seed: NexusEvent.generateSeed(),
        timestamp: DateTime.now().toUtc().toIso8601String(),
        intensity: 1.0,
        colorSignature: NexusEvent.deriveColorSignature(repo.myId, peer.peerId),
      );

      // Envoyer l'événement au pair pour synchroniser les deux animations.
      unawaited(repo.sendNexusEvent(peer.peerId, event));

      NexusStage.play(
        NexusRequest(
          seed: event.seed,
          colorSignature: event.colorSignature,
          peerName: peer.pseudo,
        ),
      );
    });
    // Quand on REÇOIT un NexusEvent d'un pair (l'autre appareil a détecté
    // la connexion en premier), on lance la même animation avec sa seed.
    _nexusEventSub = repo.nexusEvents.listen((recu) {
      if (_nexusAffiche) return;
      if (!mounted) return;
      if (!_premierLienAvec(recu.peerId)) return;
      _nexusAffiche = true;
      _startNexusSafetyTimer();
      NexusStage.play(
        NexusRequest(seed: recu.event.seed, colorSignature: recu.event.colorSignature),
      );
    });
    // ── Rattrapage : pair déjà trouvé avant l'abonnement ──────────────
    //
    // Le mesh peut découvrir un pair entre repo.init() et le moment où
    // ce widget s'abonne au broadcast. Dans ce cas, l'événement est
    // perdu. consumePendingFirstPeer() le récupère s'il existait.
    final pendingPeer = repo.consumePendingFirstPeer();
    if (pendingPeer != null &&
        !_nexusAffiche &&
        mounted &&
        _premierLienAvec(pendingPeer.peerId)) {
      _nexusAffiche = true;
      _startNexusSafetyTimer();
      final event = NexusEvent(
        seed: NexusEvent.generateSeed(),
        timestamp: DateTime.now().toUtc().toIso8601String(),
        intensity: 1.0,
        colorSignature: NexusEvent.deriveColorSignature(
          repo.myId,
          pendingPeer.peerId,
        ),
      );
      unawaited(repo.sendNexusEvent(pendingPeer.peerId, event));
      NexusStage.play(
        NexusRequest(
          seed: event.seed,
          colorSignature: event.colorSignature,
          peerName: pendingPeer.pseudo,
        ),
      );
    }
    // Surveille l'état des appels pour détecter deux moments précis :
    // « on m'appelle et l'app est en arrière-plan » (→ notif d'appel
    // entrant) et « on m'a appelé, je n'ai pas répondu, et ça s'est arrêté »
    // (→ notif d'appel manqué).
    _callSub = ref.listenManual<CallState>(callProvider, (previous, next) {
      final wasIncomingRinging =
          previous != null &&
          previous.isCallActive &&
          previous.direction == CallDirection.incoming &&
          previous.connectionState == CallConnectionState.connecting;
      if (wasIncomingRinging &&
          next.connectionState == CallConnectionState.connected) {
        _incomingWasConnected = true;
      }
      // La sonnerie s'arrête (décroché, refusé, abandonné) : la notification
      // d'appel, qu'on ne peut pas balayer, disparaît avec elle.
      if (wasIncomingRinging &&
          (!next.isCallActive || next.connectionState == CallConnectionState.connected)) {
        final appelant = previous.peerId;
        if (appelant != null) unawaited(NotificationService.fermerAppel(appelant));
      }
      if (wasIncomingRinging && !next.isCallActive && !_incomingWasConnected) {
        final peerId = previous.peerId;
        if (peerId != null) {
          final pseudo = ref.read(peerPseudoProvider(peerId));
          // Le centre en garde la trace, application ouverte ou non : un
          // appel manqué est exactement ce qu'on vient y chercher.
          unawaited(JournalNotifs.instance.ajouter(EntreeNotif(
            id: 'a:$peerId:${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
            type: TypeEntreeNotif.appelManque,
            conversationId: peerId,
            route: '/chat/$peerId',
            auteur: pseudo,
            auteurId: peerId,
            quand: DateTime.now(),
          )));
          if (NotificationService.isAppForeground) {
            // Ouverte : la bannière, et pas la notification système.
            final l10n =
                lookupAppLocalizations(NotificationService.currentLocale);
            Bannieres.montrer(DonneesBanniere(
              cle: 'appel:$peerId',
              route: '/chat/$peerId',
              titre: pseudo,
              texte: l10n.ntfMissedCall,
              auteurId: peerId,
              icone: Icons.call_missed_rounded,
              couleurIcone: OuroColors.systemRed,
            ));
          } else {
            unawaited(
              NotificationService.showMissedCall(
                peerId: peerId,
                pseudo: pseudo,
              ),
            );
          }
        }
        _incomingWasConnected = false;
      }
      if (next.isCallActive &&
          next.direction == CallDirection.incoming &&
          next.connectionState == CallConnectionState.connecting &&
          (previous == null || !previous.isCallActive)) {
        _incomingWasConnected = false;
        if (!NotificationService.isAppForeground && next.peerId != null) {
          unawaited(
            NotificationService.showIncomingCall(
              peerId: next.peerId!,
              pseudo: ref.read(peerPseudoProvider(next.peerId!)),
            ),
          );
        }
      }
    });
  }

  // Appelé automatiquement par Android/iOS chaque fois que l'app passe au
  // premier plan ou en arrière-plan — comme quelqu'un qui te tape sur
  // l'épaule pour te dire « attention, l'app vient d'être minimisée ! ».
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    NotificationService.isAppForeground = state == AppLifecycleState.resumed;
    // La présence ne se publie QUE l'app ouverte : « en ligne » veut dire
    // « son app est ouverte », pas « son téléphone existe quelque part ».
    if (state == AppLifecycleState.resumed) {
      BattementPresence.demarrer();
    } else {
      BattementPresence.arreter();
    }
  }

  /// Une sourdine posée, levée ou échue : la liste redessine son icône.
  void _surRevisionReglages() {
    if (!mounted) return;
    ref.read(pinMuteRevisionProvider.notifier).state++;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NexusStage.current.removeListener(_surChangementNexus);
    _retryTimer?.cancel();
    _nexusSafetyTimer?.cancel();
    _msgSub?.cancel();
    _statusSub?.cancel();
    _checkinSub?.cancel();
    _reactionSub?.cancel();
    ReglagesNotifs.revision.removeListener(_surRevisionReglages);
    AnnoncesDroplet.surNouvelles = null;
    _nexusPeerSub?.cancel();
    _nexusEventSub?.cancel();
    _callSub?.close();
    super.dispose();
  }

  /// ⚠️ NEXUS NE SE JOUE QU'UNE FOIS PAR APPAREIL, POUR TOUJOURS. Il se
  /// rejouait à chaque reconnexion et à chaque ouverture de l'app — voir
  /// `NexusMemoire`.
  bool _premierLienAvec(String peerId) {
    final repo = ref.read(meshRepositoryProvider);
    return NexusMemoire.doitJouer(
      peerId,
      dejaEnContact: estUnContact(StorageService.getMessages(), repo.myId, peerId),
    );
  }

  /// Sécurité : si l'animation Nexus ne se ferme pas toute seule (shader
  /// indisponible, contexte mort, etc.), on débloque le flag après 12s.
  void _startNexusSafetyTimer() {
    _nexusSafetyTimer?.cancel();
    _nexusSafetyTimer = Timer(const Duration(seconds: 12), () {
      if (_nexusAffiche) {
        debugPrint('[Droplet] nexus safety: flag débloqué');
        _nexusAffiche = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
