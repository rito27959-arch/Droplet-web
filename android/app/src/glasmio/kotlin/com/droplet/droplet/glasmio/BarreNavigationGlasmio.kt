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
//
// LA RECHERCHE FLOTTANTE (le geste d'iOS 26/27) : toucher la loupe fait
// FONDRE la barre dans un champ de recherche de verre (GlasmioFloatingSearch
// et GlasmioSearchTransition : un seul ressort pour les deux côtés). La vue
// passe alors en plein écran, le champ suit le clavier, et chaque lettre
// tapée part vers Dart, qui filtre la liste des discussions en dessous —
// visible à travers, et touchable.
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
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.ime
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.IntSize
import io.github.neoruaa.glasmio.scaffold.GlasmioFloatingSearch
import io.github.neoruaa.glasmio.scaffold.rememberGlasmioSearchTransition
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

    /** La recherche flottante est ouverte (la loupe a été touchée). */
    private var enRecherche by mutableStateOf(false)
    private var requete by mutableStateOf(TextFieldValue())

    /** La vue couvre l'écran (recherche ouverte ou en train de se refermer). */
    private var plein = false

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
        if (!visible && enRecherche) {
            // Une conversation s'ouvre depuis les résultats : la recherche se ferme.
            enRecherche = false
            requete = TextFieldValue()
            pleinEcran(false)
        }
        // ⚠️ L'ACTIVITÉ A PU ÊTRE RECRÉÉE (thème, langue, retour d'arrière-plan
        // après que le système l'a tuée) : l'ancienne vue appartenait à
        // l'ancienne fenêtre, invisible. C'est ce qui faisait « disparaître »
        // la barre. On la recrée dans la bonne.
        val v0 = vue
        if (v0 != null && (v0.context !== act || !v0.isAttachedToWindow)) {
            (v0.parent as? ViewGroup)?.removeView(v0)
            vue = null
            bande = null
        }
        if (vue == null && visible) creer(act)
        val v = vue
        val etaitVisible = v?.visibility == View.VISIBLE
        v?.visibility = if (visible) View.VISIBLE else View.GONE
        if (visible) {
            if (!etaitVisible) {
                // ⚠️ PAS D'ANCIENNE IMAGE SOUS LE VERRE : la bande recopiée datait
                // de l'écran d'avant (la conversation, son champ « Message »…).
                // On l'oublie, et on recopie très souvent pendant que la page
                // revient en glissant.
                bande = null
                rapideJusqua = System.currentTimeMillis() + 1200
            }
            demarrerBoucle()
        } else {
            boucle = false
        }
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

    private fun pleinEcran(oui: Boolean) {
        plein = oui
        val v = vue ?: return
        val lp = v.layoutParams as? FrameLayout.LayoutParams ?: return
        val h = if (oui) ViewGroup.LayoutParams.MATCH_PARENT else ViewGroup.LayoutParams.WRAP_CONTENT
        if (lp.height != h) {
            lp.height = h
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
                val rapide = System.currentTimeMillis() < rapideJusqua
                principal.postDelayed(this, if (rapide) 33L else if (plein) 100L else 1000L)
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

        val transition = rememberGlasmioSearchTransition(enRecherche)
        val morph = transition.progressState.value.coerceIn(0f, 1f)
        val couvre = enRecherche || morph > 0.001f
        LaunchedEffect(couvre) { pleinEcran(couvre) }

        GlasmioIconProvider(resolver = RESOLVEUR_BARRE) {
            GlasmioTheme(isDark = sombre, colorScheme = glasmioColorScheme(sombre, accent)) {
                // ⚠️ UNE HAUTEUR FIXE hors recherche : le fond échantillonné de
                // Glasmio remplit tout l'espace qu'on lui donne ; sans hauteur,
                // la vue prenait l'écran entier et la barre se dessinait EN HAUT.
                val bas = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
                val hauteurBarre = io.github.neoruaa.glasmio.ui.NavigationBarSurfaceHeight + 16.dp + bas
                GlasmioBackdropHost(
                    modifier = (if (couvre) Modifier.fillMaxSize() else Modifier.fillMaxWidth().height(hauteurBarre))
                        .onGloballyPositioned { origine = it.positionInWindow() },
                    sampledContent = {
                        val b = bande
                        if (b != null && !couvre) {
                            Image(b, contentDescription = null, contentScale = ContentScale.FillBounds, modifier = Modifier.fillMaxSize())
                        } else if (b != null) {
                            val clavier = WindowInsets.ime.asPaddingValues().calculateBottomPadding()
                            // En recherche, seule la bande sous le champ (au-dessus du
                            // clavier) est recopiée : la liste filtrée reste la VRAIE
                            // liste de Flutter, vivante, et non une photo.
                            Canvas(
                                Modifier.align(Alignment.BottomCenter).fillMaxWidth()
                                    .height(maxOf(clavier, bas) + 120.dp),
                            ) {
                                val h = size.height.toInt().coerceIn(1, b.height)
                                drawImage(
                                    b,
                                    srcOffset = IntOffset(0, b.height - h),
                                    srcSize = IntSize(b.width, h),
                                    dstOffset = IntOffset(0, (size.height - h).toInt()),
                                    dstSize = IntSize(size.width.toInt(), h),
                                )
                            }
                        }
                    },
                    overlayContent = {
                        // ⚠️ AU REPOS, LA BARRE EST POSÉE TELLE QUELLE, sans calque ni
                        // boîte autour : sous un calque graphique (graphicsLayer), le
                        // verre de Glasmio figeait l'émulateur au démarrage. Le calque
                        // n'existe que pendant la transformation en recherche.
                        if (!couvre) {
                            BarreOnglets(d, onglets, items, recherche, progression, compact, cadres, origine)
                        } else Box(Modifier.fillMaxSize()) {
                            Box(
                                Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(hauteurBarre)
                                    .graphicsLayer {
                                        alpha = 1f - morph
                                        val e = 1f - 0.08f * morph
                                        scaleX = e
                                        scaleY = e
                                        transformOrigin = TransformOrigin(1f, 1f)
                                    },
                            ) {
                                if (morph < 0.999f) BarreOnglets(d, onglets, items, recherche, progression, compact, cadres, origine)
                            }
                            if (couvre) {
                                // Le fond des résultats de Glasmio est rendu transparent :
                                // les résultats sont la liste Flutter, juste en dessous.
                                MaterialTheme(colorScheme = MaterialTheme.colorScheme.copy(background = Color.Transparent)) {
                                    GlasmioFloatingSearch(
                                        active = enRecherche,
                                        query = requete,
                                        onQueryChange = { q ->
                                            val change = q.text != requete.text
                                            requete = q
                                            if (change) PontGlasmio.barre("requete", q.text)
                                        },
                                        onSearch = { },
                                        onDismiss = {
                                            enRecherche = false
                                            requete = TextFieldValue()
                                            PontGlasmio.barre("recherche_fin", null)
                                        },
                                        placeholder = d.optString("recherche"),
                                        cancelLabel = d.optString("annuler", "Annuler"),
                                        handleBack = true,
                                        transition = transition,
                                        sourceBoundsInWindow = cadres[-1],
                                    ) { }
                                }
                            }
                        }
                    },
                )
            }
        }
    }

    @Composable
    private fun BarreOnglets(
        d: JSONObject,
        onglets: List<JSONObject>,
        items: List<GlasmioTabItem<Int>>,
        recherche: GlasmioTabItem<Int>,
        progression: androidx.compose.runtime.State<Float>,
        compact: Float,
        cadres: MutableMap<Int, RectCompose>,
        origine: androidx.compose.ui.geometry.Offset,
    ) {
        Box(Modifier.fillMaxWidth().navigationBarsPadding().padding(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 8.dp)) {
            GlasmioNavigationBarWithTrailingItem(
                items = items,
                trailingItem = recherche,
                selectedKey = d.optInt("index", 0),
                onSelected = { k ->
                    if (k == -1) {
                        // Le bouton de droite ouvre la page « Nouveau message » (Dart).
                        PontGlasmio.barre("recherche", k)
                    } else {
                        PontGlasmio.barre("onglet", k)
                    }
                },
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
    }
}
