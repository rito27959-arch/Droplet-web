// ============================================================================
// LE PONT GLASMIO, CÔTÉ ANDROID — canal `droplet/glasmio`.
// ----------------------------------------------------------------------------
// Dart décrit l'écran (JSON), ce pont le garde dans un état Compose, ouvre
// l'activité native, et renvoie chaque geste à Dart (`evenement`). Dart
// répond par une nouvelle description, une alerte, ou l'ordre de fermer.
// Aucune donnée ni logique de Droplet n'est réécrite ici.
//
// Compilé seulement avec la configuration Glasmio (voir `src/glasmio/`).
// `@Keep` : MainActivity le trouve par son nom — R8 ne doit ni le retirer
// ni le renommer.
// ============================================================================
package com.droplet.droplet.glasmio

import android.app.Activity
import android.app.ActivityOptions
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.Keep
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.lang.ref.WeakReference

@Keep
object PontGlasmio {
    private const val CANAL = "droplet/glasmio"

    private var canal: MethodChannel? = null
    private var activiteFlutter: WeakReference<Activity>? = null
    internal var ecranOuvert: WeakReference<Activity>? = null

    /** La description de l'écran ouvert (redessiné à chaque changement). */
    var description by mutableStateOf<JSONObject?>(null)
        internal set

    /** L'alerte de confirmation à afficher, s'il y en a une. */
    var alerte by mutableStateOf<JSONObject?>(null)
        internal set

    /** Les champs de saisie de l'écran ouvert (mot de passe de la
     *  sauvegarde…) : gardés ici, envoyés à Dart avec chaque geste. */
    val champs = androidx.compose.runtime.mutableStateMapOf<String, String>()

    /** Vrai pendant qu'un geste attend la réponse de Dart. */
    var occupe by mutableStateOf(false)
        internal set

    val disponible: Boolean get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU

    @Keep
    @JvmStatic
    fun installer(activite: Activity, messager: BinaryMessenger) {
        activiteFlutter = WeakReference(activite)
        val c = MethodChannel(messager, CANAL)
        canal = c
        c.setMethodCallHandler { appel, resultat ->
            when (appel.method) {
                "disponible" -> resultat.success(disponible)
                "ouvrir" -> {
                    val act = activiteFlutter?.get()
                    val desc = appel.argument<String>("description")
                    val sansAnimation = appel.argument<Boolean>("sansAnimation") == true
                    if (!disponible || act == null || desc == null) {
                        resultat.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        description = JSONObject(desc)
                        alerte = null
                        champs.clear()
                        // UN SEUL ÉCRAN NATIF à la fois : s'il y en a déjà un ouvert
                        // (double toucher, route reconstruite…), on le met à jour au
                        // lieu d'en empiler un second — c'était le « double écran ».
                        val deja = ecranOuvert?.get()
                        if (deja != null && !deja.isFinishing && !deja.isDestroyed) {
                            resultat.success(true)
                            return@setMethodCallHandler
                        }
                        val intention = Intent(act, EcranGlasmioActivity::class.java)
                            .putExtra("sansAnimation", sansAnimation)
                        // L'écran glisse depuis la droite par-dessus la page d'où l'on
                        // vient ; au retour d'une page Flutter, il revient sans glisser :
                        // on a l'impression de ne l'avoir jamais quitté.
                        val options = if (sansAnimation) {
                            ActivityOptions.makeCustomAnimation(act, 0, 0)
                        } else {
                            ActivityOptions.makeCustomAnimation(act, com.droplet.droplet.R.anim.glasmio_entree, com.droplet.droplet.R.anim.glasmio_immobile)
                        }
                        act.startActivity(intention, options.toBundle())
                        resultat.success(true)
                    } catch (e: Exception) {
                        resultat.error("glasmio", e.message, null)
                    }
                }
                "maj" -> {
                    appel.argument<String>("description")?.let {
                        runCatching { description = JSONObject(it) }
                    }
                    resultat.success(null)
                }
                // Alerte, feuille d'actions ou menu d'appui long, par-dessus
                // l'écran Flutter (voir SuperpositionGlasmio.kt).
                "superposition" -> {
                    val act = activiteFlutter?.get()
                    val desc = appel.argument<String>("description")
                    if (!disponible || act == null || desc == null) {
                        resultat.success(mapOf("indisponible" to true))
                        return@setMethodCallHandler
                    }
                    try {
                        SuperpositionGlasmio.afficher(act, JSONObject(desc)) { r -> resultat.success(r ?: emptyMap<String, Any?>()) }
                    } catch (e: Exception) {
                        resultat.success(mapOf("indisponible" to true))
                    }
                }
                // La barre de navigation Glasmio de l'accueil.
                "barre" -> {
                    val act = activiteFlutter?.get()
                    val desc = appel.argument<String>("description")
                    if (disponible && act != null && desc != null) {
                        runCatching { BarreNavigationGlasmio.mettreAJour(act, JSONObject(desc)) }
                    }
                    resultat.success(null)
                }
                "barre_appel" -> {
                    val act = activiteFlutter?.get()
                    val desc = appel.argument<String>("description")
                    if (disponible && act != null && desc != null) {
                        runCatching { BarreAppelGlasmio.mettreAJour(act, JSONObject(desc)) }
                    }
                    resultat.success(null)
                }
                "barre_activite" -> {
                    BarreNavigationGlasmio.signalerActivite()
                    resultat.success(null)
                }
                "fermer" -> {
                    ecranOuvert?.get()?.finish()
                    resultat.success(null)
                }
                else -> resultat.notImplemented()
            }
        }
    }

    /** Un geste dans la barre de navigation : Dart change d'onglet. */
    /** Un bouton de la barre d'appel native a été touché. */
    fun barreAppel(id: String) {
        principal { canal?.invokeMethod("barre_appel", mapOf("id" to id)) }
    }

    fun barre(id: String, valeur: Any?) {
        principal { canal?.invokeMethod("barre", mapOf("id" to id, "valeur" to valeur)) }
    }

    /** Un geste dans l'écran natif : Dart décide de la suite. */
    fun evenement(id: String, valeur: Any? = null) {
        val c = canal ?: return
        occupe = true
        principal {
            c.invokeMethod(
                "evenement",
                mapOf("id" to id, "valeur" to valeur, "champs" to HashMap(champs)),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        occupe = false
                        appliquer(result as? Map<*, *>)
                    }

                    override fun error(code: String, message: String?, details: Any?) {
                        occupe = false
                    }

                    override fun notImplemented() {
                        occupe = false
                    }
                },
            )
        }
    }

    private fun appliquer(reponse: Map<*, *>?) {
        if (reponse == null) return
        (reponse["description"] as? String)?.let { runCatching {
            val d = JSONObject(it)
            if (d.optBoolean("effacerChamps")) champs.clear()
            description = d
        } }
        (reponse["alerte"] as? String)?.let { runCatching { alerte = JSONObject(it) } }
        if (reponse["fermer"] == true) fermerAvecPhoto()
    }

    /**
     * Fermer l'écran natif pour ouvrir une page ou une feuille Flutter.
     *
     * ⚠️ SANS ÉCRAN D'UNE AUTRE APP ENTRE LES DEUX. On photographie d'abord
     * l'écran Glasmio ; Dart pose cette photo sous lui (dans la route
     * transparente) ; PUIS l'écran natif disparaît, sans animation. La page
     * Flutter glisse alors par-dessus la photo, la feuille monte par-dessus :
     * on croit rester dans le même écran — jamais l'écran Flutter de repli,
     * qui ne lui ressemblait pas.
     */
    private fun fermerAvecPhoto() {
        val ouvert = ecranOuvert?.get() ?: return
        val ecran = ouvert as? EcranGlasmioActivity
        if (ecran == null) {
            ouvert.finish()
            return
        }
        if (ecran.isFinishing) return
        val fin = {
            ecran.fermerSansAnimation()
        }
        val l = ecran.window.decorView.width
        val h = ecran.window.decorView.height
        if (l <= 0 || h <= 0) {
            fin()
            return
        }
        val image = android.graphics.Bitmap.createBitmap(l, h, android.graphics.Bitmap.Config.ARGB_8888)
        runCatching {
            android.view.PixelCopy.request(ecran.window, image, { r ->
                if (r != android.view.PixelCopy.SUCCESS) {
                    fin()
                    return@request
                }
                Thread {
                    val flux = java.io.ByteArrayOutputStream()
                    image.compress(android.graphics.Bitmap.CompressFormat.JPEG, 88, flux)
                    val octets = flux.toByteArray()
                    principal {
                        val c = canal
                        if (c == null) {
                            fin()
                        } else {
                            c.invokeMethod("photo", octets, object : MethodChannel.Result {
                                override fun success(result: Any?) = fin()
                                override fun error(code: String, message: String?, details: Any?) = fin()
                                override fun notImplemented() = fin()
                            })
                        }
                    }
                }.start()
            }, Handler(Looper.getMainLooper()))
        }.onFailure { fin() }
    }

    /** L'alerte est fermée sans confirmer : on revient à l'état réel. */
    fun annulerAlerte() {
        val a = alerte ?: return
        alerte = null
        a.optJSONObject("description")?.let {
            if (it.optBoolean("effacerChamps")) champs.clear()
            description = it
        }
    }

    /** Un des choix d'une alerte à plusieurs boutons (signaler…). */
    fun choisirDansAlerte(id: String) {
        alerte = null
        evenement(id)
    }

    fun confirmerAlerte() {
        val a = alerte ?: return
        alerte = null
        evenement(a.optString("id"))
    }

    /** L'écran natif a disparu (retour, geste, ou fermeture demandée). */
    internal fun ferme() {
        alerte = null
        occupe = false
        principal { canal?.invokeMethod("ferme", null) }
    }

    private fun principal(bloc: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) bloc()
        else Handler(Looper.getMainLooper()).post(bloc)
    }
}
