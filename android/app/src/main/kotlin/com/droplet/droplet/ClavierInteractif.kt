package com.droplet.droplet

// ============================================================================
// LE CLAVIER QUI SUIT LE DOIGT — côté Android.
// ----------------------------------------------------------------------------
// Sur iPhone, dans Messages, on tire la conversation vers le bas et le
// clavier descend AVEC le doigt, au pixel près ; on remonte, il remonte.
// On lâche : il finit de se fermer, ou revient, selon l'élan.
//
// Flutter ne sait pas faire ça seul : le clavier appartient au système.
// Depuis Android 11 (API 30), le système prête le clavier à l'application
// le temps d'un geste : `WindowInsetsController.controlWindowInsetsAnimation`
// rend un contrôleur dont on fixe la hauteur image par image. C'est ce que
// fait Telegram, et c'est ce que fait ce fichier — Dart envoie la hauteur
// voulue, en pixels physiques, à chaque mouvement du doigt.
//
// Le moteur Flutter reçoit ces hauteurs comme une animation de clavier
// ordinaire : la conversation et la barre de saisie suivent d'elles-mêmes.
//
// ⚠️ SOUS ANDROID 11, `disponible` répond non, et Dart garde le
// comportement d'avant : le clavier se ferme d'un coup dès qu'on fait
// défiler.
// ============================================================================

import android.app.Activity
import android.os.Build
import android.os.CancellationSignal
import android.view.animation.LinearInterpolator
import androidx.core.graphics.Insets
import androidx.core.view.WindowInsetsAnimationControlListenerCompat
import androidx.core.view.WindowInsetsAnimationControllerCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

object ClavierInteractif {
    private const val CANAL = "droplet/clavier"

    private var canal: MethodChannel? = null
    private var controleur: WindowInsetsAnimationControllerCompat? = null
    private var annulation: CancellationSignal? = null
    private var demande = false

    /// Ce qui a été demandé avant que le contrôleur soit prêt : appliqué
    /// dès `onReady`. Sans ça, les premiers millimètres du geste — ceux
    /// pendant lesquels le système prépare le contrôleur — seraient perdus,
    /// et le clavier « sauterait » pour rattraper le doigt.
    private var basEnAttente: Int? = null
    private var finEnAttente: Boolean? = null

    fun brancher(activite: Activity, messager: BinaryMessenger) {
        canal?.setMethodCallHandler(null)
        canal = MethodChannel(messager, CANAL).also { c ->
            c.setMethodCallHandler { appel, resultat ->
                try {
                    when (appel.method) {
                        "disponible" -> resultat.success(Build.VERSION.SDK_INT >= 30)
                        "commencer" -> resultat.success(commencer(activite))
                        "placer" -> {
                            placer((appel.argument<Number>("bas") ?: 0).toInt())
                            resultat.success(null)
                        }
                        "finir" -> {
                            finir(appel.argument<Boolean>("visible") ?: true)
                            resultat.success(null)
                        }
                        else -> resultat.notImplemented()
                    }
                } catch (e: Exception) {
                    // Jamais de plantage pour un geste : au pire, le clavier
                    // se comporte comme avant.
                    nettoyer()
                    resultat.success(false)
                }
            }
        }
    }

    fun debrancher() {
        annulation?.cancel()
        nettoyer()
        canal?.setMethodCallHandler(null)
        canal = null
    }

    private fun commencer(activite: Activity): Boolean {
        if (Build.VERSION.SDK_INT < 30) return false
        if (demande || controleur != null) return true
        val vue = activite.window?.decorView ?: return false
        val insets = ViewCompat.getRootWindowInsets(vue) ?: return false
        if (!insets.isVisible(WindowInsetsCompat.Type.ime())) return false

        demande = true
        basEnAttente = null
        finEnAttente = null
        val signal = CancellationSignal()
        annulation = signal
        WindowInsetsControllerCompat(activite.window, vue)
            .controlWindowInsetsAnimation(
                WindowInsetsCompat.Type.ime(),
                -1,
                LinearInterpolator(),
                signal,
                object : WindowInsetsAnimationControlListenerCompat {
                    override fun onReady(
                        c: WindowInsetsAnimationControllerCompat,
                        types: Int,
                    ) {
                        demande = false
                        controleur = c
                        basEnAttente?.let { placer(it) }
                        finEnAttente?.let { finir(it) }
                    }

                    override fun onFinished(c: WindowInsetsAnimationControllerCompat) {
                        nettoyer()
                    }

                    override fun onCancelled(c: WindowInsetsAnimationControllerCompat?) {
                        nettoyer()
                    }
                },
            )
        return true
    }

    private fun placer(bas: Int) {
        val c = controleur
        if (c == null) {
            if (demande) basEnAttente = bas
            return
        }
        if (!c.isReady) return
        val min = c.hiddenStateInsets.bottom
        val max = c.shownStateInsets.bottom
        val borne = bas.coerceIn(min, max)
        val fraction = if (max == min) 1f else (borne - min).toFloat() / (max - min)
        c.setInsetsAndAlpha(Insets.of(0, 0, 0, borne), 1f, fraction)
    }

    private fun finir(visible: Boolean) {
        val c = controleur
        if (c == null) {
            if (demande) finEnAttente = visible
            return
        }
        if (c.isReady) c.finish(visible)
        controleur = null
    }

    private fun nettoyer() {
        controleur = null
        annulation = null
        demande = false
        basEnAttente = null
        finEnAttente = null
    }
}
