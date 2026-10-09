package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA TÉLÉCOMMANDE : ce que Dart appelle pour allumer et éteindre la
// notification d'appel système.
//
// Deux méthodes, c'est tout. `demarrer` avec qui on parle et depuis quand,
// `arreter` quand c'est fini. Le reste — la pastille de la barre d'état, le
// chronomètre, le bouton « Raccrocher » — est l'affaire d'Android, et c'est
// précisément pour ça qu'on passe par lui plutôt que de le redessiner.
//
// ── COMMENT L'INSTALLER ───────────────────────────────────────────────
//
// UNE SEULE LIGNE à ajouter dans `MainActivity.kt`, dans
// `configureFlutterEngine` :
//
//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
//         AppelNotifPont.brancher(this, flutterEngine)   // ← celle-ci
//         ...vos autres ponts...
//     }
// ============================================================================

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object AppelNotifPont {

    private const val CANAL = "com.droplet.droplet/appel_notif"

    /// Gardé pour que le bouton « Raccrocher » de la notification puisse
    /// parler à Dart depuis un `BroadcastReceiver`, qui n'a aucun accès au
    /// moteur Flutter autrement.
    ///
    /// ⚠️ REMIS À NULL QUAND LE MOTEUR MEURT. Sans ça, on garderait une
    /// référence sur un moteur détruit : une fuite, et un appel de méthode
    /// qui lève une exception au lieu de ne rien faire.
    @JvmStatic
    var canal: MethodChannel? = null
        private set

    @JvmStatic
    fun brancher(contexte: Context, moteur: FlutterEngine) {
        val app = contexte.applicationContext
        val c = MethodChannel(moteur.dartExecutor.binaryMessenger, CANAL)
        c.setMethodCallHandler { appel, resultat ->
            when (appel.method) {
                "demarrer" -> {
                    AppelEnCoursService.demarrer(
                        app,
                        pair = appel.argument<String>("pair") ?: "",
                        pseudo = appel.argument<String>("pseudo") ?: "",
                        // ⚠️ `Number`, PAS `Long`. Un entier venu de Dart
                        // arrive en `Integer` quand il tient sur 32 bits et
                        // en `Long` sinon. Un `argument<Long>` rendrait
                        // alors `null` sans prévenir, et le chronomètre
                        // repartirait de l'instant présent à chaque fois —
                        // un appel de dix minutes afficherait « 0:00 ».
                        debutMs = (appel.argument<Any>("debut") as? Number)
                            ?.toLong() ?: System.currentTimeMillis(),
                        video = appel.argument<Boolean>("video") ?: false,
                        via = appel.argument<String>("via") ?: "",
                    )
                    resultat.success(true)
                }
                "arreter" -> {
                    AppelEnCoursService.arreter(app)
                    resultat.success(true)
                }
                else -> resultat.notImplemented()
            }
        }
        canal = c
    }

    /// À appeler depuis `cleanUpFlutterEngine` si vous en avez un —
    /// facultatif, mais propre.
    @JvmStatic
    fun debrancher() {
        canal?.setMethodCallHandler(null)
        canal = null
    }
}
