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
                    val ecran = appel.argument<String>("ecran")
                    if (!disponible || act == null || desc == null || ecran != "parametres") {
                        resultat.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        description = JSONObject(desc)
                        alerte = null
                        act.startActivity(Intent(act, ParametresGlasmioActivity::class.java))
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
                "fermer" -> {
                    ecranOuvert?.get()?.finish()
                    resultat.success(null)
                }
                else -> resultat.notImplemented()
            }
        }
    }

    /** Un geste dans l'écran natif : Dart décide de la suite. */
    fun evenement(id: String, valeur: Any? = null) {
        val c = canal ?: return
        occupe = true
        principal {
            c.invokeMethod(
                "evenement",
                mapOf("id" to id, "valeur" to valeur),
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
        (reponse["description"] as? String)?.let { runCatching { description = JSONObject(it) } }
        (reponse["alerte"] as? String)?.let { runCatching { alerte = JSONObject(it) } }
        if (reponse["fermer"] == true) ecranOuvert?.get()?.finish()
    }

    /** L'alerte est fermée sans confirmer : on revient à l'état réel. */
    fun annulerAlerte() {
        val a = alerte ?: return
        alerte = null
        a.optJSONObject("description")?.let { description = it }
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
