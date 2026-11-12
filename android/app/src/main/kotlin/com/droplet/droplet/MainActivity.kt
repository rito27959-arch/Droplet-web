package com.droplet.droplet

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.res.Configuration
import android.graphics.BitmapFactory
import android.util.Rational
import android.os.Build
import android.os.Bundle
import android.provider.ContactsContract
import android.view.WindowManager
import androidx.core.app.Person
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * CHANGER L'ICÔNE DE L'APPLICATION DEPUIS L'APPLICATION.
 *
 * Android ne permet pas de remplacer l'icône d'une app à l'exécution :
 * elle est figée dans le manifeste, lu à l'installation. La seule
 * méthode officielle consiste à déclarer PLUSIEURS points d'entrée vers
 * la même activité — des `activity-alias`, chacun avec sa propre icône —
 * puis à n'en laisser qu'UN seul activé à la fois.
 *
 * C'est exactement ce que font les applications qui proposent des icônes
 * alternatives. Le lanceur affiche l'icône de l'alias actif ; les autres
 * sont désactivés, donc invisibles.
 *
 * ⚠️ DEUX CONSÉQUENCES À CONNAÎTRE
 *
 * 1. Le changement ferme l'application sur la plupart des lanceurs.
 *    Désactiver le composant par lequel l'app a été lancée revient à
 *    couper la branche sur laquelle on est assis : Android termine le
 *    processus. D'où IconeApp.kt : le choix est noté tout de suite et la
 *    bascule n'a lieu qu'en QUITTANT Droplet — l'app ne se ferme plus
 *    sous les doigts.
 *
 * 2. L'ordre compte. On ACTIVE la nouvelle icône AVANT de désactiver
 *    l'ancienne : si l'on faisait l'inverse et que le processus était
 *    tué entre les deux, l'application n'aurait plus AUCUN point
 *    d'entrée activé et disparaîtrait complètement du lanceur, sans
 *    aucun moyen de la rouvrir.
 */
class MainActivity : FlutterFragmentActivity() {
    private var contactDrop: ContactDropBridge? = null

    override fun onPause() {
        contactDrop?.onPause()
        super.onPause()
    }

    override fun onDestroy() {
        if (isFinishing) IconeApp.appliquerEnAttente(applicationContext)
        contactDrop?.dispose()
        contactDrop = null
        // ⚠️ SANS CETTE LIGNE, ON GARDE UNE RÉFÉRENCE SUR UN MOTEUR MORT.
        // Le bouton « Raccrocher » de la notification écrirait alors dans
        // un canal détruit — une exception, au lieu de ne rien faire.
        AppelNotifPont.debrancher()
        ClavierInteractif.debrancher()
        // Même raison pour les notifications de conversation : une réponse
        // tapée dans le volet après la mort du moteur doit être NOTÉE
        // (`ActionsVolet`), pas envoyée dans un canal détruit.
        NotifConversations.debrancher()
        LectureNotifPont.debrancher()
        super.onDestroy()
    }


    private val channel = "com.droplet.droplet/app_icon"
    private val mediaChannel = "com.droplet.droplet/media"


    private val appelChannel = "com.droplet.droplet/appel"
    private val raccourcisChannel = "com.droplet.droplet/raccourcis"
    private val contactsChannel = "com.droplet.droplet/contacts"

    // ── CHOISIR UN NUMÉRO DANS LES CONTACTS (page « Inviter ») ──────────
    //
    // Le sélecteur de contacts d'Android : l'utilisateur choisit UNE
    // personne, et seule celle-là nous est confiée. Aucune permission
    // d'accès au carnet entier n'est demandée.
    private val codeChoixContact = 7301
    private var resultatContact: MethodChannel.Result? = null

    @Suppress("DEPRECATION")
    @Deprecated("Sélecteur de contacts système")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != codeChoixContact) return
        val resultat = resultatContact ?: return
        resultatContact = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            resultat.success(null)
            return
        }
        try {
            contentResolver.query(
                uri,
                arrayOf(
                    ContactsContract.CommonDataKinds.Phone.NUMBER,
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ),
                null, null, null,
            )?.use { curseur ->
                if (curseur.moveToFirst()) {
                    resultat.success(mapOf("numero" to curseur.getString(0), "nom" to curseur.getString(1)))
                    return
                }
            }
            resultat.success(null)
        } catch (e: Exception) {
            resultat.success(null)
        }
    }

    // ── VIGNETTE D'APPEL VIDÉO (PiP) ────────────────────────────────────
    //
    // Quitter l'application pendant un appel vidéo coupait l'image. Comme
    // WhatsApp, l'appel se replie en petite fenêtre flottante. Seulement
    // pendant un appel vidéo : Flutter l'autorise et le retire.
    private var vignetteAutorisee = false
    private var canalAppel: MethodChannel? = null

    private fun parametresVignette(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < 26) return null
        val builder = PictureInPictureParams.Builder().setAspectRatio(Rational(9, 16))
        if (Build.VERSION.SDK_INT >= 31) builder.setAutoEnterEnabled(vignetteAutorisee)
        return builder.build()
    }

    private fun autoriserVignette(actif: Boolean) {
        vignetteAutorisee = actif
        if (Build.VERSION.SDK_INT >= 26) {
            try {
                parametresVignette()?.let { setPictureInPictureParams(it) }
            } catch (e: Exception) {
                // Appareil sans vignette : rien à faire.
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // L'icône choisie s'applique quand on QUITTE Droplet (voir IconeApp.kt)
        // — jamais pendant un appel qui passe en vignette : la bascule peut
        // fermer l'app.
        if (!vignetteAutorisee) IconeApp.appliquerEnAttente(applicationContext)
        // Android 12+ entre tout seul en vignette (`setAutoEnterEnabled`).
        if (vignetteAutorisee && Build.VERSION.SDK_INT in 26..30) {
            try {
                parametresVignette()?.let { enterPictureInPictureMode(it) }
            } catch (e: Exception) {
            }
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        canalAppel?.invokeMethod("vignette", isInPictureInPictureMode)
    }

    /** La route demandée par le raccourci (ou la notification) qui a ouvert l'app. */
    private var routeLancement: String? = null

    // ── APPEL ENTRANT, TÉLÉPHONE VERROUILLÉ ─────────────────────────────
    //
    // La notification d'appel est « plein écran » : Android ouvre alors
    // l'application directement, même verrouillé. Encore faut-il que
    // l'activité ait le droit de s'afficher PAR-DESSUS l'écran de
    // verrouillage et d'allumer l'écran — sinon elle s'ouvre derrière, et on
    // ne voit qu'une bannière. Ce droit n'est accordé que pendant un appel :
    // le reste de Droplet ne doit jamais être lisible sans déverrouiller.

    override fun onCreate(savedInstanceState: Bundle?) {
        // Les plantages Android dans le Journal d'erreurs (JournalNatif.kt).
        JournalNatif.installer(this)
        super.onCreate(savedInstanceState)
        siAppelEntrant(intent)
        retenirCibleDePartage(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        siAppelEntrant(intent)
        retenirCibleDePartage(intent)
    }

    /** La conversation choisie dans le partage direct d'Android, s'il y en a une. */
    private var cibleDePartage: String? = null

    private fun retenirCibleDePartage(intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_SEND && action != Intent.ACTION_SEND_MULTIPLE) return
        // "android.intent.extra.shortcut.ID" (Intent.EXTRA_SHORTCUT_ID, API 29).
        cibleDePartage = intent.getStringExtra("android.intent.extra.shortcut.ID")
    }

    /** La route (`/chat/…`, `/group/…`) du raccourci [id], lue dans le raccourci lui-même. */
    private fun routeDuRaccourci(id: String): String? = try {
        ShortcutManagerCompat.getDynamicShortcuts(this)
            .firstOrNull { it.id == id }?.intent?.getStringExtra("payload")
    } catch (e: Exception) {
        null
    }

    private fun siAppelEntrant(intent: Intent?) {
        val charge = intent?.getStringExtra("payload") ?: return
        routeLancement = charge
        if (charge.startsWith("/call/")) afficherSurVerrouillage(true)

        // ⚠️ `routeLancement` NE SUFFIT PAS QUAND L'APP TOURNE DÉJÀ.
        //
        // Dart ne vient le chercher qu'UNE FOIS, au démarrage
        // (`RaccourcisConversation.routeDeLancement()` dans `main.dart`).
        // Si l'application est simplement en arrière-plan, cet intent
        // arrive par `onNewIntent`, l'activité repasse devant… et plus
        // personne ne lit la route : on retombe sur l'écran qu'on avait
        // quitté, pas sur l'appel.
        //
        // On pousse donc la route tout de suite quand le moteur est
        // vivant. Les deux chemins coexistent sans se gêner : au
        // démarrage le canal n'existe pas encore et `routeLancement`
        // prend le relais.
        AppelNotifPont.canal?.invokeMethod("route", charge)
    }

    // ── RACCOURCIS DE CONVERSATION ──────────────────────────────────────
    //
    // Android range les conversations à part depuis la version 11 : appui
    // long sur l'icône pour retrouver ses derniers échanges, bulles
    // flottantes, section « Conversations » des paramètres de notification,
    // avatar de la personne dans la notification. Tout cela repose sur un
    // « raccourci » publié par l'application et cité par la notification
    // (`shortcutId`). Sans lui, Droplet n'existait pas pour ce système.

    private fun publierRaccourci(
        id: String,
        nom: String,
        route: String,
        photo: String?,
        couleur: Int? = null,
    ): Boolean {
        return try {
            // Sans photo : l'initiale sur sa couleur (comme dans l'app), pas
            // le logo — c'est CETTE icône qu'Android montre en grand sur une
            // notification de conversation.
            val icone = photo?.let { chemin ->
                val bitmap = BitmapFactory.decodeFile(chemin)
                if (bitmap == null) null else IconCompat.createWithAdaptiveBitmap(bitmap)
            } ?: AvatarInitiale.icone(nom, couleur)

            val personne = Person.Builder().setName(nom).setKey(id).setIcon(icone).build()
            val intention = Intent(this, MainActivity::class.java)
                .setAction(Intent.ACTION_VIEW)
                .putExtra("payload", route)

            ShortcutManagerCompat.pushDynamicShortcut(
                this,
                ShortcutInfoCompat.Builder(this, id)
                    .setShortLabel(nom)
                    .setLongLabel(nom)
                    .setIcon(icone)
                    .setPerson(personne)
                    // « Longue vie » : exigé pour les bulles de conversation.
                    .setLongLived(true)
                    // « conversation » : bulles et section Conversations ;
                    // « PARTAGE » : en tête de la feuille Partager d'Android
                    // (voir `res/xml/raccourcis_partage.xml`).
                    .setCategories(setOf("android.shortcut.conversation", "com.droplet.droplet.category.PARTAGE"))
                    .setIntent(intention)
                    .build(),
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun afficherSurVerrouillage(actif: Boolean) {
        if (Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(actif)
            setTurnScreenOn(actif)
        } else {
            @Suppress("DEPRECATION")
            val drapeaux = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (actif) window.addFlags(drapeaux) else window.clearFlags(drapeaux)
        }
    }

    // ── Glasmio (écrans natifs Jetpack Compose, Android 13+) ──────────────
    // Le code Glasmio vit dans `src/glasmio/` : il n'est compilé qu'avec la
    // configuration Glasmio (plugin Android 9, compileSdk 37). On le cherche
    // donc par son nom : absent, rien ne se passe, `PontGlasmio.disponible`
    // répond faux côté Dart et Droplet garde ses écrans Flutter.
    private fun installerGlasmio(flutterEngine: FlutterEngine) {
        try {
            Class.forName("com.droplet.droplet.glasmio.PontGlasmio")
                .getMethod(
                    "installer",
                    android.app.Activity::class.java,
                    io.flutter.plugin.common.BinaryMessenger::class.java,
                )
                .invoke(null, this, flutterEngine.dartExecutor.binaryMessenger)
        } catch (_: ReflectiveOperationException) {
        } catch (e: RuntimeException) {
            android.util.Log.w("Droplet", "Glasmio indisponible", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        installerGlasmio(flutterEngine)
        contactDrop?.dispose()
        contactDrop = ContactDropBridge(this, flutterEngine.dartExecutor.binaryMessenger)

        // ── LA NOTIFICATION D'APPEL SYSTÈME ─────────────────────────────
        //
        // La pastille de la barre d'état (combiné + minuteur, visible
        // depuis l'écran d'accueil) et le bouton « Raccrocher » dessiné
        // par Android viennent d'une notification `CallStyle` portée par
        // un service de premier plan de type `phoneCall`.
        // `flutter_local_notifications` ne sait pas la produire : voir
        // `AppelEnCoursService.kt`.
        AppelNotifPont.brancher(this, flutterEngine)

        // ── LES NOTIFICATIONS DE CONVERSATION ───────────────────────────
        //
        // ⚠️ SANS CETTE LIGNE, TOUT `NotifConversations.kt` DORT. Dart
        // demande « notifier », personne ne répond, et il retombe en
        // silence sur la notification classique : pas de section
        // « Conversations » dans les réglages, pas de bulle, et aucun des
        // boutons Répondre / Lu / ❤️ du volet.
        NotifConversations.brancher(this, flutterEngine)

        // Le lecteur des messages vocaux hors de l'app (voir
        // `LectureVocaleService.kt`).
        LectureNotifPont.brancher(this, flutterEngine)

        // Le clavier qui suit le doigt dans une conversation (Android 11+).
        ClavierInteractif.brancher(this, flutterEngine.dartExecutor.binaryMessenger)

        // Ce que ce téléphone peut se permettre : puce, cœurs, fréquence,
        // mémoire (voir `ProfilAppareil.kt` et `device_profile.dart`).
        ProfilAppareil.brancher(applicationContext, flutterEngine.dartExecutor.binaryMessenger)

        // Droplet dans les autres apps : stickers pour WhatsApp et Telegram,
        // partage de l'application elle-même (voir `PartageDroplet.kt`).
        PartageDroplet.brancher(this, flutterEngine.dartExecutor.binaryMessenger)

        // Droplet ID : après une approbation ouverte par « Ouvrir dans
        // Droplet », l'app passe en arrière-plan et le navigateur (qui
        // attend la réponse) revient au premier plan. Rien n'est fermé.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.droplet.droplet/droplet_id")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "revenirAuNavigateur" -> result.success(moveTaskToBack(true))
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val alias = call.argument<String>("alias")
                        if (alias == null) {
                            result.error("ARG", "alias manquant", null)
                        } else {
                            try {
                                // Noté maintenant, appliqué en quittant l'app
                                // (sinon le lanceur ferme Droplet) — IconeApp.kt.
                                IconeApp.choisir(this, alias)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("FAIL", e.message, null)
                            }
                        }
                    }

                    "currentIcon" -> result.success(IconeApp.actuelle(this))

                    else -> result.notImplemented()
                }
            }

        // Découpe de vidéo et enregistrement dans la galerie — deux
        // services qu'Android seul sait rendre (voir `MediaBridge.kt`).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, contactsChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "choisirNumero") {
                    result.notImplemented()
                } else if (resultatContact != null) {
                    result.success(null)
                } else {
                    resultatContact = result
                    try {
                        @Suppress("DEPRECATION")
                        startActivityForResult(
                            Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI),
                            codeChoixContact,
                        )
                    } catch (e: Exception) {
                        resultatContact = null
                        result.success(null)
                    }
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, raccourcisChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "publier" -> {
                        val id = call.argument<String>("id")
                        val nom = call.argument<String>("nom")
                        val route = call.argument<String>("route")
                        if (id == null || nom == null || route == null) {
                            result.error("ARG", "arguments manquants", null)
                        } else {
                            result.success(
                                publierRaccourci(
                                    id,
                                    nom,
                                    route,
                                    call.argument<String>("photo"),
                                    call.argument<Number>("couleur")?.toInt(),
                                ),
                            )
                        }
                    }

                    "retirer" -> {
                        val id = call.argument<String>("id")
                        if (id == null) {
                            result.error("ARG", "identifiant manquant", null)
                        } else {
                            try {
                                ShortcutManagerCompat.removeLongLivedShortcuts(this, listOf(id))
                            } catch (e: Exception) {
                                // Un raccourci déjà absent n'est pas une erreur.
                            }
                            result.success(true)
                        }
                    }

                    // La conversation à ouvrir quand l'app a été lancée par un
                    // raccourci : lue une fois, puis oubliée.
                    // Le partage direct : la route de la conversation choisie
                    // dans la feuille Partager. Lue une fois, puis oubliée.
                    "cibleDePartage" -> {
                        val id = cibleDePartage
                        cibleDePartage = null
                        result.success(id?.let { routeDuRaccourci(it) })
                    }

                    "routeDeLancement" -> {
                        result.success(routeLancement)
                        routeLancement = null
                    }

                    else -> result.notImplemented()
                }
            }

        canalAppel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appelChannel)
        canalAppel!!
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "vignetteAutorisee" -> {
                        autoriserVignette(call.argument<Boolean>("actif") == true)
                        result.success(true)
                    }
                    "surVerrouillage" -> {
                        afficherSurVerrouillage(call.argument<Boolean>("actif") == true)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        val media = MediaBridge(applicationContext)
        // Les widgets « verre » (WidgetsVerre.kt) : deux nombres, jamais de contenu.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.droplet.droplet/widgets_verre")
            .setMethodCallHandler { call, result ->
                if (call.method == "maj") {
                    WidgetsVerre.maj(
                        applicationContext,
                        call.argument<Int>("nonLus") ?: 0,
                        call.argument<Int>("pairs") ?: 0,
                    )
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
        // Le journal Android de l'app (avertissements et erreurs, avec leur
        // pile) : pour « Copier le détail » quand la caméra refuse de
        // démarrer. Seulement les lignes de CE processus ; lu sur un fil à
        // part (logcat peut prendre une seconde).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.droplet.droplet/journal")
            .setMethodCallHandler { call, result ->
                if (call.method != "logcat") { result.notImplemented(); return@setMethodCallHandler }
                Thread {
                    val texte = JournalNatif.logcat()
                    runOnUiThread { result.success(texte) }
                }.start()
            }
        val canalMedia = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaChannel)
        media.canal = canalMedia
        canalMedia.setMethodCallHandler { call, result ->
            // ⚠️ VUE UNIQUE : pendant qu'on la regarde, Android interdit
            // les captures et l'enregistrement de l'écran (l'image apparaît
            // noire), et l'aperçu des applis récentes est masqué.
            if (call.method == "ecranSecurise") {
                val actif = call.argument<Boolean>("actif") ?: false
                runOnUiThread {
                    if (actif) {
                        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    }
                }
                result.success(true)
            } else {
                media.handle(call, result)
            }
        }

        // Transcription des vocaux et traduction des messages — tout se
        // fait sur l'appareil (voir `IntelligenceBridge.kt`).
        val intelligence = IntelligenceBridge(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IntelligenceBridge.CHANNEL)
            .setMethodCallHandler { call, result ->
                intelligence.handle(call.method, call.arguments, result)
            }
    }
}
