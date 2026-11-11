// ============================================================================
// LES PLANTAGES CÔTÉ ANDROID, DANS LE « JOURNAL D'ERREURS » DE L'APP.
// ----------------------------------------------------------------------------
// Le journal (lib/core/services/crash_journal.dart) n'attrapait que les
// erreurs Dart. Une exception Kotlin/Java non attrapée ferme l'app SANS
// laisser de trace lisible par l'utilisateur — impossible de savoir pourquoi
// « l'app se ferme ».
//
// Ce crochet écrit l'exception, avec ses 25 premières lignes de pile, dans
// LE MÊME FICHIER que le journal Dart (path_provider :
// <données de l'app>/app_flutter/droplet-erreurs.log), au même format. Au
// prochain lancement, Réglages → Journal d'erreurs la montre, et « Envoyer »
// la partage. Puis le gestionnaire d'origine reprend la main (l'app se ferme
// comme avant : on ne masque rien).
//
// ⚠️ Aucun contenu de message : seulement le type d'erreur et la pile.
// ============================================================================
package com.droplet.droplet

import android.content.Context
import android.os.Build
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object JournalNatif {
    @Volatile private var installe = false

    fun installer(context: Context) {
        if (installe) return
        installe = true
        val app = context.applicationContext
        val precedent = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { fil, erreur ->
            runCatching { ecrire(app, fil, erreur) }
            if (precedent != null) precedent.uncaughtException(fil, erreur)
            else {
                android.os.Process.killProcess(android.os.Process.myPid())
                kotlin.system.exitProcess(10)
            }
        }
    }

    /** Les 150 dernières lignes d'avertissement ou d'erreur de l'app. */
    fun logcat(): String = runCatching {
        val p = ProcessBuilder(
            "logcat", "-d", "-t", "600", "-v", "brief",
            "--pid=${android.os.Process.myPid()}", "*:W",
        ).redirectErrorStream(true).start()
        val lignes = p.inputStream.bufferedReader().readLines()
        p.waitFor()
        lignes.takeLast(150).joinToString("\n")
    }.getOrDefault("")

    private fun ecrire(context: Context, fil: Thread, erreur: Throwable) {
        // Le dossier de path_provider (getApplicationDocumentsDirectory).
        val dossier = context.getDir("flutter", Context.MODE_PRIVATE)
        val fichier = File(dossier, "droplet-erreurs.log")
        val date = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date())
        val texte = StringBuilder()
            .append("── ").append(date).append(" · ANDROID ──────────────\n")
            .append("Fil : ").append(fil.name)
            .append(" · Android ").append(Build.VERSION.SDK_INT)
            .append(" · ").append(Build.MANUFACTURER).append(' ').append(Build.MODEL).append('\n')
        var e: Throwable? = erreur
        var niveau = 0
        while (e != null && niveau < 3) {
            if (niveau > 0) texte.append("Causé par : ")
            texte.append(e.javaClass.name).append(": ").append(e.message ?: "").append('\n')
            e.stackTrace.take(if (niveau == 0) 25 else 12).forEach { texte.append("    at ").append(it).append('\n') }
            e = e.cause
            niveau++
        }
        texte.append('\n')
        fichier.appendText(texte.toString())
    }
}
