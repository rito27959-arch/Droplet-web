// ============================================================================
// LA BARRE DE NAVIGATION GLASMIO — par-dessus l'accueil Flutter.
// ----------------------------------------------------------------------------
// La vraie barre de Glasmio (GlasmioNavigationBarWithTrailingItem) : une
// capsule de verre avec les quatre onglets de Droplet, et à part, la LOUPE
// dans son propre cercle de verre (à la place du bouton +). Quand on descend
// dans la liste, la barre se replie (compactProgress) : il ne reste que
// l'onglet actif à gauche et la loupe à droite — le geste d'iOS 26.
//
// LE VERRE VOIT LA LISTE : la bande d'écran que la barre recouvre est
// recopiée depuis la surface de Flutter (PixelCopy), souvent pendant un
// défilement, rarement au repos, et sert de fond échantillonné. La barre
// réfracte donc les vraies conversations qui passent dessous.
//
// La vue ne couvre que la bande du bas, et laisse passer tout toucher qui ne
// tombe pas sur un bouton : la liste reste utilisable jusqu'au bord.
// ============================================================================
package com.droplet.droplet.glasmio

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.PixelCopy
import android.view.SurfaceView
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Call
import androidx.compose.material.icons.rounded.ChatBubble
import androidx.compose.material.icons.rounded.People
import androidx.compose.material.icons.rounded.Podcasts
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Rect as RectCompose
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInWindow
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.flutter.embedding.android.FlutterView
import io.github.neoruaa.glasmio.core.GlasmioTheme
import io.github.neoruaa.glasmio.core.glasmioColorScheme
import io.github.neoruaa.glasmio.glass.GlasmioBackdropHost
import io.github.neoruaa.glasmio.icons.GlasmioIconProvider
import io.github.neoruaa.glasmio.icons.GlasmioIconResolver
import io.github.neoruaa.glasmio.icons.SfSymbol
import io.github.neoruaa.glasmio.scaffold.GlasmioNavigationBarWithTrailingItem
import io.github.neoruaa.glasmio.ui.GlasmioTabItem
import org.json.JSONObject

object BarreNavigationGlasmio {
    private var vue: ComposeView? = null
    private var description by mutableStateOf<JSONObject?>(null)
    private var bande by mutableStateOf<ImageBitmap?>(null)
    private var activite: java.lang.ref.WeakReference<Activity>? = null
    private val principal = Handler(Looper.getMainLooper())

    /** Jusqu'à quand recopier la bande souvent (un défilement est en cours). */
    private var rapideJusqua = 0L
    private var boucle = false

    /** Les onglets de Droplet, posés sur des symboles Glasmio dont ce
     *  résolveur remplace le dessin (la barre ne connaît que ses symboles). */
    private val SYMBOLES = listOf(SfSymbol.House, SfSymbol.RadioWaves, SfSymbol.Clock, SfSymbol.PersonFilled)
    private val RESOLVEUR_BARRE = GlasmioIconResolver { nom ->
        when {
            nom.startsWith("house") -> Icons.Rounded.ChatBubble
            nom.startsWith("dot.radiowaves") -> Icons.Rounded.Podcasts
            nom.startsWith("clock") -> Icons.Rounded.Call
            nom.startsWith("person") -> Icons.Rounded.People
            else -> RESOLVEUR.resolve(nom)
        }
    }

    fun mettreAJour(act: Activity, d: JSONObject) {
        activite = java.lang.ref.WeakReference(act)
        description = d
        val visible = d.optBoolean("visible")
        if (vue == null && visible) creer(act)
        vue?.visibility = if (visible) View.VISIBLE else View.GONE
        if (visible) demarrerBoucle() else boucle = false
    }

    /** Un défilement dans Flutter : la bande se recopie souvent pendant 600 ms. */
    fun signalerActivite() {
        rapideJusqua = System.currentTimeMillis() + 600
    }

    private fun creer(act: Activity) {
        val racine = act.findViewById<ViewGroup>(android.R.id.content) ?: return
        val v = ComposeView(act)
        v.setContent { Barre() }
        racine.addView(v, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.BOTTOM))
        vue = v
    }

    private fun demarrerBoucle() {
        if (boucle) return
        boucle = true
        val tache = object : Runnable {
            override fun run() {
                if (!boucle) return
                capturer()
                val rapide = System.currentTimeMillis() < rapideJusqua
                principal.postDelayed(this, if (rapide) 33L else 1000L)
            }
        }
        principal.post(tache)
    }

    // ── La bande d'écran sous la barre, depuis la surface de Flutter ──────
    private var tampon: Bitmap? = null

    private fun capturer() {
        val act = activite?.get() ?: return
        val v = vue ?: return
        if (v.width <= 0 || v.height <= 0) return
        val fv = trouver(act.window.decorView, FlutterView::class.java) ?: return
        val posVue = IntArray(2).also { v.getLocationInWindow(it) }
        val posFlutter = IntArray(2).also { fv.getLocationInWindow(it) }
        val zone = Rect(0, posVue[1] - posFlutter[1], v.width, posVue[1] - posFlutter[1] + v.height)
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
            val h = zone.height().coerceAtMost(tout.height - zone.top.coerceAtLeast(0))
            if (h > 0) bande = Bitmap.createBitmap(tout, 0, zone.top.coerceAtLeast(0), tout.width, h).asImageBitmap()
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
        val sombre = d.optBoolean("sombre", true)
        val accent = couleur(d, "accent", Color(0xFFE8344E))
        val onglets = d.optJSONArray("onglets")?.objets().orEmpty()
        if (onglets.isEmpty()) return
        val progression = animateFloatAsState(
            targetValue = if (d.optBoolean("compact")) 1f else 0f,
            animationSpec = spring(dampingRatio = .8f, stiffness = 438.6f),
            label = "barre",
        )
        val compact = progression.value
        val items = onglets.mapIndexed { i, o ->
            GlasmioTabItem(i, o.optString("titre"), SYMBOLES[i.coerceAtMost(SYMBOLES.lastIndex)])
        }
        val recherche = GlasmioTabItem(-1, d.optString("recherche"), SfSymbol.Search)
        // Où dessiner les pastilles de non-lus : les cadres réels des onglets.
        val cadres = remember { mutableStateMapOf<Int, RectCompose>() }
        var origine by remember { mutableStateOf(androidx.compose.ui.geometry.Offset.Zero) }

        GlasmioIconProvider(resolver = RESOLVEUR_BARRE) {
            GlasmioTheme(isDark = sombre, colorScheme = glasmioColorScheme(sombre, accent)) {
                // ⚠️ UNE HAUTEUR FIXE : le fond échantillonné de Glasmio remplit
                // tout l'espace qu'on lui donne ; sans hauteur, la vue prenait
                // l'écran entier et la barre se dessinait EN HAUT.
                val bas = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
                GlasmioBackdropHost(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(io.github.neoruaa.glasmio.ui.NavigationBarSurfaceHeight + 16.dp + bas)
                        .onGloballyPositioned { origine = it.positionInWindow() },
                    sampledContent = {
                        bande?.let { Image(it, contentDescription = null, contentScale = ContentScale.FillBounds, modifier = Modifier.fillMaxSize()) }
                    },
                    overlayContent = {
                        Box(Modifier.fillMaxWidth().navigationBarsPadding().padding(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 8.dp)) {
                            GlasmioNavigationBarWithTrailingItem(
                                items = items,
                                trailingItem = recherche,
                                selectedKey = d.optInt("index", 0),
                                onSelected = { k -> PontGlasmio.barre(if (k == -1) "recherche" else "onglet", k) },
                                onExpand = { PontGlasmio.barre("deplier", null) },
                                compactProgress = progression,
                                modifier = Modifier.fillMaxWidth(),
                                onItemBoundsChanged = { k, r -> cadres[k] = r },
                            )
                            // Les pastilles de non-lus (la barre de Glasmio n'en a pas).
                            onglets.forEachIndexed { i, o ->
                                val n = o.optInt("badge", 0)
                                val r = cadres[i]
                                if (n > 0 && r != null && compact < 0.5f) {
                                    Text(
                                        if (n > 99) "99+" else "$n",
                                        color = Color.White,
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        modifier = Modifier
                                            .offset {
                                                IntOffset(
                                                    (r.center.x - origine.x - 16.dp.toPx() + 6.dp.toPx()).toInt(),
                                                    (r.top - origine.y - 8.dp.toPx() + 6.dp.toPx()).toInt(),
                                                )
                                            }
                                            .clip(RoundedCornerShape(50))
                                            .background(Color(0xFFFF3B30))
                                            .padding(horizontal = 5.dp, vertical = 1.dp),
                                    )
                                }
                            }
                        }
                    },
                )
            }
        }
    }
}
