// ============================================================================
// LA BARRE D'APPEL GLASMIO — par-dessus les écrans d'appel Flutter.
// ----------------------------------------------------------------------------
// La barre de contrôle des appels (haut-parleur, caméra, retourner, micro,
// raccrocher) devient du VRAI verre Glasmio : une surface GlassSurface aux
// coins de 30 dp, et des GlasmioIconButton ronds de 56 dp (le rouge pour
// raccrocher, le verre « en relief » pour un bouton allumé).
//
// Dart pose la barre au pixel près là où la barre Flutter se trouve (la
// barre Flutter reste en place, invisible, pour garder la mise en page) et
// reçoit chaque toucher (PontGlasmio.barreAppel).
//
// LE VERRE VOIT L'APPEL : la bande d'écran sous la barre est recopiée de la
// surface de Flutter (PixelCopy) toutes les 50 ms — la vidéo bouge sans
// cesse — et sert de fond échantillonné : la barre réfracte la vidéo ou le
// fond de l'appel qui passe dessous.
// ============================================================================
package com.droplet.droplet.glasmio

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.view.PixelCopy
import android.view.SurfaceView
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.VolumeDown
import androidx.compose.material.icons.automirrored.rounded.VolumeUp
import androidx.compose.material.icons.rounded.CallEnd
import androidx.compose.material.icons.rounded.Cameraswitch
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.MicOff
import androidx.compose.material.icons.rounded.Videocam
import androidx.compose.material.icons.rounded.VideocamOff
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.flutter.embedding.android.FlutterView
import io.github.neoruaa.glasmio.core.GlasmioTheme
import io.github.neoruaa.glasmio.core.glasmioColorScheme
import io.github.neoruaa.glasmio.glass.GlassEmphasis
import io.github.neoruaa.glasmio.glass.GlassSurface
import io.github.neoruaa.glasmio.glass.GlasmioBackdropHost
import io.github.neoruaa.glasmio.ui.GlasmioIconButton
import org.json.JSONObject

object BarreAppelGlasmio {
    private var vue: ComposeView? = null
    private var description by mutableStateOf<JSONObject?>(null)
    private var bande by mutableStateOf<ImageBitmap?>(null)
    private var montree by mutableStateOf(false)
    private var activite: java.lang.ref.WeakReference<Activity>? = null
    private val principal = Handler(Looper.getMainLooper())
    private var boucle = false
    private val cacher = Runnable { vue?.visibility = View.GONE }

    private val ICONES: Map<String, ImageVector> = mapOf(
        "haut_parleur_on" to Icons.AutoMirrored.Rounded.VolumeUp,
        "haut_parleur_off" to Icons.AutoMirrored.Rounded.VolumeDown,
        "camera_on" to Icons.Rounded.Videocam,
        "camera_off" to Icons.Rounded.VideocamOff,
        "retourner" to Icons.Rounded.Cameraswitch,
        "micro" to Icons.Rounded.Mic,
        "micro_off" to Icons.Rounded.MicOff,
        "raccrocher" to Icons.Rounded.CallEnd,
    )

    fun mettreAJour(act: Activity, d: JSONObject) {
        activite = java.lang.ref.WeakReference(act)
        val visible = d.optBoolean("visible")
        if (vue == null && visible) creer(act)
        val v = vue ?: return
        if (visible) {
            description = d
            placer(act, v, d)
            principal.removeCallbacks(cacher)
            if (v.visibility != View.VISIBLE) {
                v.alpha = 0f
                v.translationY = 24 * act.resources.displayMetrics.density
            }
            v.visibility = View.VISIBLE
            // Apparition par la vue Android (pas de calque Compose autour du
            // verre : il reste posé tel quel une fois arrivé).
            v.animate().alpha(1f).translationY(0f).setDuration(240).start()
            montree = true
            demarrerBoucle()
        } else {
            montree = false
            boucle = false
            // La barre s'efface (fondu), puis ne prend plus aucun toucher.
            principal.removeCallbacks(cacher)
            v.animate().alpha(0f).translationY(24 * act.resources.displayMetrics.density).setDuration(220).start()
            principal.postDelayed(cacher, 240)
        }
    }

    private fun creer(act: Activity) {
        val racine = act.findViewById<ViewGroup>(android.R.id.content) ?: return
        val v = ComposeView(act)
        v.setContent { Barre() }
        racine.addView(v, FrameLayout.LayoutParams(1, 1))
        vue = v
    }

    /** Pose la vue sur le rectangle de la barre Flutter (points logiques). */
    private fun placer(act: Activity, v: ComposeView, d: JSONObject) {
        val px = act.resources.displayMetrics.density
        val fv = trouver(act.window.decorView, FlutterView::class.java)
        val decalage = IntArray(2)
        val racine = v.parent as? View
        if (fv != null && racine != null) {
            val a = IntArray(2).also { fv.getLocationInWindow(it) }
            val b = IntArray(2).also { racine.getLocationInWindow(it) }
            decalage[0] = a[0] - b[0]
            decalage[1] = a[1] - b[1]
        }
        val lp = (v.layoutParams as? FrameLayout.LayoutParams) ?: FrameLayout.LayoutParams(1, 1)
        val l = (d.optDouble("l", 0.0) * px).toInt().coerceAtLeast(1)
        val h = (d.optDouble("h", 0.0) * px).toInt().coerceAtLeast(1)
        val x = (d.optDouble("x", 0.0) * px).toInt() + decalage[0]
        val y = (d.optDouble("y", 0.0) * px).toInt() + decalage[1]
        if (lp.width != l || lp.height != h || lp.leftMargin != x || lp.topMargin != y) {
            lp.width = l
            lp.height = h
            lp.leftMargin = x
            lp.topMargin = y
            v.layoutParams = lp
        }
    }

    private fun demarrerBoucle() {
        if (boucle) return
        boucle = true
        val tache = object : Runnable {
            override fun run() {
                if (!boucle) return
                capturer()
                principal.postDelayed(this, 50L)
            }
        }
        principal.post(tache)
    }

    // ── La bande d'écran sous la barre, depuis la surface de Flutter ──────
    private var tampon: Bitmap? = null

    private fun capturer() {
        val act = activite?.get() ?: return
        val v = vue ?: return
        if (v.width <= 1 || v.height <= 1) return
        val fv = trouver(act.window.decorView, FlutterView::class.java) ?: return
        val posVue = IntArray(2).also { v.getLocationInWindow(it) }
        val posFlutter = IntArray(2).also { fv.getLocationInWindow(it) }
        val x = posVue[0] - posFlutter[0]
        val y = posVue[1] - posFlutter[1]
        val zone = Rect(x, y, x + v.width, y + v.height)
        val b = tampon?.takeIf { it.width == v.width && it.height == v.height }
            ?: Bitmap.createBitmap(v.width, v.height, Bitmap.Config.ARGB_8888).also { tampon = it }
        val surface = trouver(fv, SurfaceView::class.java)
        if (surface != null) {
            runCatching {
                PixelCopy.request(surface, zone, b, { r ->
                    if (r == PixelCopy.SUCCESS) bande = b.copy(Bitmap.Config.ARGB_8888, false).asImageBitmap()
                }, principal)
            }
            return
        }
        val texture = trouver(fv, TextureView::class.java) ?: return
        runCatching {
            val tout = texture.bitmap ?: return
            val r = Rect(zone).apply { intersect(0, 0, tout.width, tout.height) }
            if (r.width() > 0 && r.height() > 0) {
                bande = Bitmap.createBitmap(tout, r.left, r.top, r.width(), r.height()).asImageBitmap()
            }
        }
    }

    private fun <T : View> trouver(v: View, type: Class<T>): T? {
        if (type.isInstance(v)) return type.cast(v)
        if (v is ViewGroup) {
            for (i in 0 until v.childCount) trouver(v.getChildAt(i), type)?.let { return it }
        }
        return null
    }

    // ── La barre ──────────────────────────────────────────────────────────
    @Composable
    private fun Barre() {
        val d = description ?: return
        val boutons = d.optJSONArray("boutons")?.objets().orEmpty()
        GlasmioTheme(isDark = true, colorScheme = glasmioColorScheme(true, Color(0xFF0A84FF))) {
            GlasmioBackdropHost(
                modifier = Modifier.fillMaxSize(),
                sampledContent = {
                    bande?.let { Image(it, contentDescription = null, contentScale = ContentScale.FillBounds, modifier = Modifier.fillMaxSize()) }
                },
                overlayContent = {
                    GlassSurface(
                        modifier = Modifier.fillMaxSize(),
                        shape = RoundedCornerShape(30.dp),
                    ) {
                        Row(
                            Modifier.fillMaxSize().padding(start = 8.dp, end = 8.dp, top = 14.dp, bottom = 10.dp),
                            horizontalArrangement = Arrangement.SpaceEvenly,
                            verticalAlignment = Alignment.Top,
                        ) {
                            for (b in boutons) BoutonAppel(b, Modifier.weight(1f))
                        }
                    }
                },
            )
        }
    }

    @Composable
    private fun BoutonAppel(b: JSONObject, modifier: Modifier) {
        val id = b.optString("id")
        val actif = b.optBoolean("actif")
        val destructif = b.optBoolean("destructif")
        val icone = ICONES[b.optString("icone")] ?: Icons.Rounded.Mic
        Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
            GlasmioIconButton(
                onClick = { PontGlasmio.barreAppel(id) },
                modifier = Modifier.semantics { contentDescription = b.optString("semantique") },
                size = 56.dp,
                emphasis = if (actif) GlassEmphasis.Prominent else GlassEmphasis.Regular,
                navigationSurfaceColor = when {
                    destructif -> Color(0xFFFF3B30)
                    actif -> Color.White
                    else -> null
                },
            ) {
                Icon(
                    icone,
                    contentDescription = null,
                    tint = if (actif && !destructif) Color(0xDD000000) else Color.White,
                    modifier = Modifier.align(Alignment.Center),
                )
            }
            Spacer(Modifier.height(6.dp))
            Text(
                b.optString("legende"),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                textAlign = TextAlign.Center,
                fontSize = 11.5.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.7f),
            )
        }
    }
}
