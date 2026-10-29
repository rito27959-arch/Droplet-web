package com.droplet.droplet

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * CE QUE CE TÉLÉPHONE PEUT SE PERMETTRE.
 *
 * Dart ne voit ni la puce, ni le nombre de cœurs, ni leur fréquence : il
 * les demande ici, une fois au démarrage (voir `device_profile.dart`).
 * Ce sont les mêmes indices que Telegram emploie pour classer un appareil
 * (SharedConfig.getDevicePerformanceClass), plus deux qu'Android publie
 * depuis la version 12 : la « classe de performance » et le modèle de
 * la puce.
 *
 * Rien n'est mesuré ici : tout est lu (fichiers système, constantes de
 * construction). L'appel prend quelques millisecondes.
 */
object ProfilAppareil {
    const val CANAL = "com.droplet.droplet/appareil"

    fun brancher(contexte: Context, messager: BinaryMessenger) {
        MethodChannel(messager, CANAL).setMethodCallHandler { appel, resultat ->
            if (appel.method == "profil") {
                resultat.success(lire(contexte))
            } else {
                resultat.notImplemented()
            }
        }
    }

    private fun lire(contexte: Context): Map<String, Any?> {
        val am = contexte.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoire = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memoire)
        val coeurs = Runtime.getRuntime().availableProcessors()
        return mapOf(
            "ramMb" to (memoire.totalMem / (1024L * 1024L)).toInt(),
            "lowRam" to am.isLowRamDevice,
            "coeurs" to coeurs,
            "freqMaxMhz" to frequenceMaxMhz(coeurs),
            "sdk" to Build.VERSION.SDK_INT,
            "classePerf" to (if (Build.VERSION.SDK_INT >= 31) Build.VERSION.MEDIA_PERFORMANCE_CLASS else 0),
            "puce" to (if (Build.VERSION.SDK_INT >= 31) Build.SOC_MODEL else Build.HARDWARE),
        )
    }

    /**
     * La fréquence maximale du cœur le plus rapide, en MHz ; 0 si le
     * système ne la donne pas (certains constructeurs ferment ces
     * fichiers). Sur une puce big.LITTLE, c'est le grand cœur qui compte :
     * c'est lui qui fait tourner l'interface.
     */
    private fun frequenceMaxMhz(coeurs: Int): Int {
        var max = 0
        for (i in 0 until coeurs) {
            try {
                val f = File("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq")
                if (!f.canRead()) continue
                val khz = f.readText().trim().toIntOrNull() ?: continue
                if (khz / 1000 > max) max = khz / 1000
            } catch (e: Exception) {
                // Un cœur éteint ou un fichier fermé : on passe au suivant.
            }
        }
        return max
    }
}
