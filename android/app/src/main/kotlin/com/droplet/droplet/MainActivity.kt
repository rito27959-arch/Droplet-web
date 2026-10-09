package com.droplet.droplet

import android.content.ComponentName
import android.app.PictureInPictureParams
import android.content.Intent
import android.content.res.Configuration
import android.graphics.BitmapFactory
import android.util.Rational
import android.os.Build
import android.os.Bundle
import android.provider.ContactsContract
import android.view.WindowManager
import android.content.pm.PackageManager
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
 *    processus. C'est le comportement normal, y compris chez les grandes
 *    applications — l'interface prévient donc l'utilisateur avant.
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
        super.onDestroy()
    }


    private val channel = "com.droplet.droplet/app_icon"
    private val mediaChannel = "com.droplet.droplet/media"

    /** Le nom de l'alias par défaut, celui déclaré dans le manifeste. */
    private val defaultAlias = "Default"

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
        super.onCreate(savedInstanceState)
        siAppelEntrant(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        siAppelEntrant(intent)
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
    ): Boolean {
        return try {
            val icone = photo?.let { chemin ->
                val bitmap = BitmapFactory.decodeFile(chemin)
                if (bitmap == null) null else IconCompat.createWithAdaptiveBitmap(bitmap)
            } ?: IconCompat.createWithResource(this, R.mipmap.ic_launcher)

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
                    .setCategories(setOf("android.shortcut.conversation"))
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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

        // Le clavier qui suit le doigt dans une conversation (Android 11+).
        ClavierInteractif.brancher(this, flutterEngine.dartExecutor.binaryMessenger)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val alias = call.argument<String>("alias")
                        if (alias == null) {
                            result.error("ARG", "alias manquant", null)
                        } else {
                            try {
                                applyIcon(alias)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("FAIL", e.message, null)
                            }
                        }
                    }

                    "currentIcon" -> result.success(currentAlias())

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
                                publierRaccourci(id, nom, route, call.argument<String>("photo")),
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
        val canalMedia = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaChannel)
        media.canal = canalMedia
        canalMedia.setMethodCallHandler { call, result -> media.handle(call, result) }

        // Transcription des vocaux et traduction des messages — tout se
        // fait sur l'appareil (voir `IntelligenceBridge.kt`).
        val intelligence = IntelligenceBridge(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IntelligenceBridge.CHANNEL)
            .setMethodCallHandler { call, result ->
                intelligence.handle(call.method, call.arguments, result)
            }
    }

    /** Tous les alias déclarés au manifeste. */
    private fun aliases(): List<String> =
        listOf(defaultAlias) + (1..12).map { "V$it" }

    /** Active [target] et désactive tous les autres. */
    private fun applyIcon(target: String) {
        val pm = packageManager
        val prefix = "$packageName.Launcher"

        // On active D'ABORD — voir le point 2 en tête de classe.
        pm.setComponentEnabledSetting(
            ComponentName(packageName, "$prefix$target"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )

        for (alias in aliases()) {
            if (alias == target) continue
            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$prefix$alias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    /** L'alias actuellement actif. */
    private fun currentAlias(): String {
        val pm = packageManager
        val prefix = "$packageName.Launcher"

        for (alias in aliases()) {
            val state = pm.getComponentEnabledSetting(
                ComponentName(packageName, "$prefix$alias")
            )
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                return alias
            }
        }
        // Aucun n'est explicitement activé : c'est que l'app n'a jamais
        // changé d'icône, et que le défaut du manifeste s'applique.
        return defaultAlias
    }
}
