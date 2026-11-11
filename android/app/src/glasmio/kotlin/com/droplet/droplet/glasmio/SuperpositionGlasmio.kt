// ============================================================================
// LES SUPERPOSITIONS GLASMIO — alertes, feuilles d'actions et menus d'appui
// long, en vrai verre, PAR-DESSUS les écrans Flutter.
// ----------------------------------------------------------------------------
// Le verre de Glasmio ne voit pas les pixels de Flutter. Mais une alerte ou
// un menu FIGE l'écran derrière lui (c'est ce que fait iOS) : on prend donc
// une image de la dernière image dessinée par Flutter, on la pose comme fond
// échantillonné (GlasmioBackdropHost), et les composants Glasmio réfractent
// et floutent cette image — exactement l'écran qu'on avait sous les yeux.
//
// Composants : GlasmioAlertDialog (+ GlasmioAlertTextField pour une saisie),
// GlasmioActionSheet, GlasmioContextMenu + GlasmioMenuItem, GlasmioButton.
//
// Les icônes des menus sont celles de Flutter, lues dans la police d'icônes
// que Flutter embarque déjà dans l'APK : chaque menu garde ses icônes, sans
// table de correspondance à tenir à jour.
// ============================================================================
package com.droplet.droplet.glasmio

import android.app.Activity
import android.graphics.Typeface
import android.view.View
import android.view.ViewGroup
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlinx.coroutines.launch
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.github.neoruaa.glasmio.core.GlasmioTheme
import io.github.neoruaa.glasmio.core.LocalGlassColors
import io.github.neoruaa.glasmio.core.glasmioColorScheme
import io.github.neoruaa.glasmio.glass.GlasmioBackdropHost
import io.github.neoruaa.glasmio.icons.GlasmioIconProvider
import io.github.neoruaa.glasmio.ui.GlasmioActionSheet
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonLayout
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonRole
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonSpec
import io.github.neoruaa.glasmio.ui.GlasmioAlertDialog
import io.github.neoruaa.glasmio.ui.GlasmioAlertTextField
import io.github.neoruaa.glasmio.ui.GlasmioButton
import io.github.neoruaa.glasmio.ui.GlasmioButtonSize
import io.github.neoruaa.glasmio.ui.GlasmioContextMenu
import io.github.neoruaa.glasmio.ui.GlasmioListRow
import io.github.neoruaa.glasmio.ui.GlasmioMenuItem
import org.json.JSONObject

object SuperpositionGlasmio {

    /** Une superposition à la fois : un second appui long attend la fin. */
    private var ouverte: View? = null

    fun afficher(activite: Activity, d: JSONObject, fini: (Map<String, Any?>?) -> Unit) {
        val racine = activite.findViewById<ViewGroup>(android.R.id.content)
        if (racine == null || ouverte != null) {
            fini(null)
            return
        }
        val capture = capturer(activite)
        val vue = ComposeView(activite)
        var termine = false
        val fermer: (Map<String, Any?>?) -> Unit = { r ->
            if (!termine) {
                termine = true
                racine.removeView(vue)
                ouverte = null
                fini(r)
            }
        }
        vue.setContent { Superposition(d, capture, fermer) }
        ouverte = vue
        racine.addView(vue, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    /** La dernière image dessinée par Flutter. */
    private fun capturer(activite: Activity): ImageBitmap? = runCatching {
        trouverFlutterView(activite.window.decorView)?.attachedFlutterEngine?.renderer?.bitmap?.asImageBitmap()
    }.getOrNull()

    private fun trouverFlutterView(v: View): FlutterView? {
        if (v is FlutterView) return v
        if (v is ViewGroup) {
            for (i in 0 until v.childCount) trouverFlutterView(v.getChildAt(i))?.let { return it }
        }
        return null
    }

    // ── Les polices d'icônes de Flutter ─────────────────────────────────
    private val polices = HashMap<String, FontFamily?>()

    internal fun police(activite: android.content.Context, famille: String?, paquet: String?): FontFamily? {
        val chemin = when {
            famille == "MaterialIcons" -> "fonts/MaterialIcons-Regular.otf"
            famille == "CupertinoIcons" -> "packages/cupertino_icons/assets/CupertinoIcons.ttf"
            else -> return null
        }
        val cle = "$famille/$paquet"
        return polices.getOrPut(cle) {
            runCatching {
                val actif = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(chemin)
                FontFamily(Typeface.createFromAsset(activite.assets, actif))
            }.getOrNull()
        }
    }
}

@Composable
private fun Superposition(d: JSONObject, capture: ImageBitmap?, fini: (Map<String, Any?>?) -> Unit) {
    val sombre = d.optBoolean("sombre", true)
    val accent = couleur(d, "accent", Color(0xFFE8344E))
    GlasmioIconProvider(resolver = RESOLVEUR) {
        GlasmioTheme(isDark = sombre, colorScheme = glasmioColorScheme(sombre, accent)) {
            GlasmioBackdropHost(
                modifier = Modifier.fillMaxSize(),
                sampledContent = {
                    if (capture != null) {
                        Image(capture, contentDescription = null, contentScale = ContentScale.FillBounds, modifier = Modifier.fillMaxSize())
                    }
                },
                overlayContent = {
                    BackHandler { fini(null) }
                    when (d.optString("type")) {
                        "alerte" -> AlerteSuperposee(d, fini)
                        "feuille" -> FeuilleSuperposee(d, fini)
                        "menu" -> MenuSuperpose(d, capture, fini)
                        "message" -> MessageSuperpose(d, capture, fini)
                        "selection" -> SelectionSuperposee(d, fini)
                        else -> LaunchedEffect(Unit) { fini(null) }
                    }
                },
            )
        }
    }
}

private fun role(b: JSONObject) = when (b.optString("role")) {
    "annuler" -> GlasmioAlertButtonRole.Cancel
    "destructif" -> GlasmioAlertButtonRole.Destructive
    else -> GlasmioAlertButtonRole.Default
}

// ─────────────────────────────────────────────────────────────
//  L'alerte (et la question qui demande un texte)
// ─────────────────────────────────────────────────────────────

@Composable
private fun AlerteSuperposee(d: JSONObject, fini: (Map<String, Any?>?) -> Unit) {
    val champ = d.optJSONObject("champ")
    var texte by remember { mutableStateOf(TextFieldValue(champ?.optString("texte").orEmpty())) }
    val boutons = d.optJSONArray("boutons")?.objets().orEmpty()
    // Pas de boîte vide sur fond figé : la fermeture l'enlève d'un coup.
    var visible by remember { mutableStateOf(true) }
    fun choisir(id: String?) {
        visible = false
        fini(if (id == null) null else mapOf("id" to id, "texte" to texte.text))
    }
    GlasmioAlertDialog(
        onDismissRequest = { choisir(null) },
        title = d.optString("titre"),
        message = d.texte("message"),
        buttonLayout = if (boutons.size > 2) GlasmioAlertButtonLayout.Stacked else GlasmioAlertButtonLayout.SideBySide,
        buttons = boutons.map { b -> GlasmioAlertButtonSpec(b.optString("titre"), { choisir(b.optString("id")) }, role(b)) },
        visible = visible,
    ) {
        if (champ != null) {
            GlasmioAlertTextField(
                value = texte,
                onValueChange = { v ->
                    val max = champ.optInt("max", 0)
                    if (max <= 0 || v.text.length <= max) texte = v
                },
                placeholder = champ.texte("indice"),
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  La feuille d'actions (en bas de l'écran)
// ─────────────────────────────────────────────────────────────

@Composable
private fun FeuilleSuperposee(d: JSONObject, fini: (Map<String, Any?>?) -> Unit) {
    val couleurs = LocalGlassColors.current
    val boutons = d.optJSONArray("boutons")?.objets().orEmpty()
    val annuler = boutons.firstOrNull { it.optString("role") == "annuler" }
    val actions = boutons.filter { it !== annuler }
    val montee = remember { Animatable(0f) }
    LaunchedEffect(Unit) { montee.animateTo(1f, tween(260)) }
    Box(
        Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.32f * montee.value))
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { fini(null) },
    ) {
        Column(
            Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .graphicsLayer { translationY = (1f - montee.value) * size.height }
                .navigationBarsPadding()
                .padding(horizontal = 8.dp, vertical = 8.dp)
                // Toucher la feuille ne la ferme pas.
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {},
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            GlasmioActionSheet(title = d.optString("titre"), message = d.texte("message")) {
                actions.forEachIndexed { i, b ->
                    GlasmioListRow(
                        title = b.optString("titre"),
                        onClick = { fini(mapOf("id" to b.optString("id"))) },
                        showTopSeparator = i > 0,
                        showDisclosure = false,
                        titleColor = if (b.optString("role") == "destructif") couleurs.destructive else couleurs.accent,
                        titleAlignment = TextAlign.Center,
                    )
                }
            }
            if (annuler != null) {
                GlasmioButton(
                    onClick = { fini(null) },
                    modifier = Modifier.fillMaxWidth(),
                    size = GlasmioButtonSize.Large,
                ) {
                    Text(annuler.optString("titre"), fontWeight = FontWeight.SemiBold, fontSize = 17.sp)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Le menu d'appui long : l'élément touché se soulève, le fond se
//  floute, les réactions au-dessus, le menu en dessous (ou au-dessus).
// ─────────────────────────────────────────────────────────────

@Composable
private fun MenuSuperpose(d: JSONObject, capture: ImageBitmap?, fini: (Map<String, Any?>?) -> Unit) {
    val couleurs = LocalGlassColors.current
    val densite = LocalDensity.current
    val contexte = androidx.compose.ui.platform.LocalContext.current
    val zone = d.optJSONObject("zone") ?: JSONObject()
    val elements = d.optJSONArray("elements")?.objets().orEmpty()
    val reactions = d.optJSONArray("reactions")?.let { a -> (0 until a.length()).map { a.optString(it) } }.orEmpty()
    val actuelles = d.optJSONArray("actuelles")?.let { a -> (0 until a.length()).map { a.optString(it) } }.orEmpty().toSet()
    val aDroite = d.optBoolean("aDroite")
    val apparition = remember { Animatable(0f) }
    LaunchedEffect(Unit) { apparition.animateTo(1f, tween(240)) }

    BoxWithConstraints(Modifier.fillMaxSize()) {
        val ecranL = constraints.maxWidth.toFloat()
        val ecranH = constraints.maxHeight.toFloat()
        // La zone touchée, en pixels (Flutter l'envoie en points logiques).
        val px = densite.density
        val zx = (zone.optDouble("x", 0.0) * px).toFloat()
        val zy = (zone.optDouble("y", 0.0) * px).toFloat()
        val zl = (zone.optDouble("l", 0.0) * px).toFloat()
        val zh = (zone.optDouble("h", 0.0) * px).toFloat()

        // Le fond figé, flouté et assombri.
        if (capture != null) {
            Image(
                capture,
                contentDescription = null,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier.fillMaxSize().blur(24.dp * apparition.value),
            )
        }
        Box(
            Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = (if (couleurs.isDark) 0.35f else 0.18f) * apparition.value))
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { fini(null) },
        )

        // L'élément touché, net, soulevé.
        if (capture != null && zl > 0f && zh > 0f) {
            val echX = capture.width / ecranL
            val echY = capture.height / ecranH
            Canvas(
                Modifier
                    .offset { IntOffset(zx.toInt(), zy.toInt()) }
                    .size(with(densite) { zl.toDp() }, with(densite) { zh.toDp() })
                    .graphicsLayer {
                        val s = 1f + 0.03f * apparition.value
                        scaleX = s
                        scaleY = s
                    }
                    .shadow(18.dp * apparition.value, RoundedCornerShape(16.dp), clip = false)
                    .clip(RoundedCornerShape(16.dp))
                    .clickable(enabled = d.optBoolean("apercuTouchable")) { fini(mapOf("id" to "apercu")) },
            ) {
                drawImage(
                    capture,
                    srcOffset = IntOffset((zx * echX).toInt(), (zy * echY).toInt()),
                    srcSize = IntSize((zl * echX).toInt().coerceAtLeast(1), (zh * echY).toInt().coerceAtLeast(1)),
                    dstSize = IntSize(size.width.toInt(), size.height.toInt()),
                )
            }
        }

        val marge = 12.dp.value * px
        val hauteurMenu = (20f + 44f * elements.size) * px
        val largeurMenu = 250f * px
        val hauteurReactions = if (reactions.isNotEmpty()) 52f * px else 0f
        // Sous l'élément s'il y a la place, sinon au-dessus.
        val dessous = zy + zh + marge + hauteurMenu < ecranH - 24f * px
        val menuY = if (dessous) zy + zh + marge else (zy - marge - hauteurMenu).coerceAtLeast(40f * px)
        val menuX = if (aDroite) (zx + zl - largeurMenu).coerceAtLeast(marge) else zx.coerceIn(marge, ecranL - largeurMenu - marge)
        val reactionsY = (zy - marge - hauteurReactions).coerceAtLeast(40f * px)

        if (reactions.isNotEmpty()) {
            Row(
                Modifier
                    .offset { IntOffset(if (aDroite) (zx + zl - reactions.size * 46f * px - 16f * px).coerceAtLeast(marge).toInt() else zx.toInt(), reactionsY.toInt()) }
                    .graphicsLayer { alpha = apparition.value }
                    .shadow(12.dp, RoundedCornerShape(50))
                    .clip(RoundedCornerShape(50))
                    .background(couleurs.elevatedBackground)
                    .padding(horizontal = 8.dp, vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                reactions.forEach { e ->
                    Box(
                        Modifier
                            .size(40.dp)
                            .clip(RoundedCornerShape(50))
                            .background(if (e in actuelles) couleurs.accent.copy(alpha = 0.25f) else Color.Transparent)
                            .clickable { fini(mapOf("id" to "reaction", "texte" to e)) },
                        contentAlignment = Alignment.Center,
                    ) { Text(e, fontSize = 24.sp) }
                }
            }
        }

        GlasmioContextMenu(
            visible = true,
            modifier = Modifier
                .offset { IntOffset(menuX.toInt(), menuY.toInt()) }
                .width(250.dp)
                .graphicsLayer {
                    alpha = apparition.value
                    val s = 0.85f + 0.15f * apparition.value
                    scaleX = s
                    scaleY = s
                },
            animationProgress = apparition.value,
            opensAbove = !dessous,
            itemCount = elements.size,
        ) { _ ->
            elements.forEach { e ->
                val police = SuperpositionGlasmio.police(contexte, e.texte("police"), e.texte("paquet"))
                val glyphe = e.optInt("glyphe", 0)
                GlasmioMenuItem(
                    title = e.optString("titre"),
                    onClick = { fini(mapOf("id" to e.optString("id"))) },
                    destructive = e.optBoolean("destructif"),
                    trailing = if (police != null && glyphe > 0) {
                        {
                            Text(
                                String(Character.toChars(glyphe)),
                                fontFamily = police,
                                fontSize = 20.sp,
                                color = if (e.optBoolean("destructif")) couleurs.destructive else couleurs.content,
                            )
                        }
                    } else {
                        null
                    },
                )
            }
        }
        Spacer(Modifier.height(0.dp))
    }
}


// ─────────────────────────────────────────────────────────────
//  L'appui long sur un MESSAGE : le vrai menu de Messages de Glasmio
//  (GlasmioMessageContextMenu). La bulle touchée (son image) se soulève,
//  la barre de réactions de verre s'ouvre au-dessus avec les dessins animés
//  de Glasmio (cœur, pouce, « HA HA »…), et les actions en dessous.
// ─────────────────────────────────────────────────────────────

private fun dessinReaction(emoji: String) = when (emoji) {
    "❤️" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.Heart
    "👍" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.ThumbsUp
    "👎" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.ThumbsDown
    "😂" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.Laugh
    "‼️" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.Exclamation
    "❓" -> io.github.neoruaa.glasmio.ui.GlasmioMessageReactionArtwork.Question
    else -> null
}

@Composable
private fun MessageSuperpose(d: JSONObject, capture: ImageBitmap?, fini: (Map<String, Any?>?) -> Unit) {
    val densite = LocalDensity.current
    val portee = androidx.compose.runtime.rememberCoroutineScope()
    val zone = d.optJSONObject("zone") ?: JSONObject()
    val px = densite.density
    val zx = (zone.optDouble("x", 0.0) * px).toFloat()
    val zy = (zone.optDouble("y", 0.0) * px).toFloat()
    val zl = (zone.optDouble("l", 1.0) * px).toFloat().coerceAtLeast(1f)
    val zh = (zone.optDouble("h", 1.0) * px).toFloat().coerceAtLeast(1f)
    var ouvert by remember { mutableStateOf(false) }
    var resultat by remember { mutableStateOf<Map<String, Any?>?>(null) }
    var termine by remember { mutableStateOf(false) }
    fun terminer() {
        if (termine) return
        termine = true
        // On laisse le menu jouer sa fermeture avant d'ôter la vue.
        portee.launch { kotlinx.coroutines.delay(320); fini(resultat) }
    }
    // Le menu s'ouvre une fois la bulle posée (il en photographie l'image).
    LaunchedEffect(Unit) {
        androidx.compose.runtime.withFrameNanos { }
        ouvert = true
    }
    val emojis = d.optJSONArray("reactions")?.let { a -> (0 until a.length()).map { a.optString(it) } }.orEmpty()
    val actuelles = d.optJSONArray("actuelles")?.let { a -> (0 until a.length()).map { a.optString(it) } }.orEmpty()
    val reactions = emojis.map { e -> io.github.neoruaa.glasmio.ui.GlasmioMessageReaction(e, e, e, dessinReaction(e)) }
    val actions = d.optJSONArray("elements")?.objets().orEmpty().map { e ->
        io.github.neoruaa.glasmio.ui.GlasmioCascadingMenuItem(
            title = e.optString("titre"),
            systemName = e.texte("cle"),
            destructive = e.optBoolean("destructif"),
            separatorBefore = e.optBoolean("section"),
            onClick = {
                resultat = mapOf("id" to e.optString("id"))
                ouvert = false
                terminer()
            },
        )
    }
    // Le fond : la conversation figée, FLOUTÉE et assombrie, comme dans
    // Messages — seule la bulle touchée reste nette, soulevée au-dessus.
    val couleursFond = LocalGlassColors.current
    val voile = remember { Animatable(0f) }
    LaunchedEffect(ouvert) { voile.animateTo(if (ouvert) 1f else 0f, tween(if (ouvert) 260 else 220)) }
    androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxSize()) {
        val ecranL = constraints.maxWidth.toFloat().coerceAtLeast(1f)
        val ecranH = constraints.maxHeight.toFloat().coerceAtLeast(1f)
        if (capture != null) {
            Image(
                capture,
                contentDescription = null,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier.fillMaxSize().blur(28.dp * voile.value),
            )
        }
        Box(
            Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = (if (couleursFond.isDark) 0.4f else 0.2f) * voile.value))
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                    ouvert = false
                    terminer()
                },
        )
        Box(
            Modifier
                .offset { IntOffset(zx.toInt(), zy.toInt()) }
                .size(with(densite) { zl.toDp() }, with(densite) { zh.toDp() }),
        ) {
            io.github.neoruaa.glasmio.ui.GlasmioMessageContextMenu(
                outgoing = d.optBoolean("aDroite"),
                expanded = ouvert,
                onExpandedChange = { e ->
                    ouvert = e
                    if (!e) terminer()
                },
                actions = actions,
                reactions = reactions,
                onReaction = { r ->
                    resultat = mapOf("id" to "reaction", "texte" to r.emoji)
                    ouvert = false
                    terminer()
                },
                selectedReaction = actuelles.firstOrNull(),
                shape = RoundedCornerShape(18.dp),
                anchor = { _ ->
                    // La bulle, telle qu'elle était à l'écran (copie de la capture).
                    Canvas(Modifier.size(with(densite) { zl.toDp() }, with(densite) { zh.toDp() })) {
                        if (capture != null) {
                            val echX = capture.width / ecranL
                            val echY = capture.height / ecranH
                            drawImage(
                                capture,
                                srcOffset = IntOffset((zx * echX).toInt(), (zy * echY).toInt()),
                                srcSize = IntSize((zl * echX).toInt().coerceAtLeast(1), (zh * echY).toInt().coerceAtLeast(1)),
                                dstSize = IntSize(size.width.toInt(), size.height.toInt()),
                            )
                        }
                    }
                },
            )
        }
    }
}


// ─────────────────────────────────────────────────────────────
//  L'appui long dans la BARRE DE SAISIE : le menu d'édition d'Apple
//  (GlasmioTextSelectionMenu) — la capsule de verre Couper · Copier ·
//  Coller · Tout sélectionner au-dessus de la sélection, et « Plus » qui
//  s'ouvre sur les styles d'écriture (Gras, Italique…).
// ─────────────────────────────────────────────────────────────

@Composable
private fun SelectionSuperposee(d: JSONObject, fini: (Map<String, Any?>?) -> Unit) {
    val densite = LocalDensity.current
    val vue = androidx.compose.ui.platform.LocalView.current
    val zone = d.optJSONObject("zone") ?: JSONObject()
    val px = densite.density
    // Le menu veut la sélection en pixels de l'ÉCRAN.
    val pos = remember { IntArray(2).also { vue.getLocationOnScreen(it) } }
    val bornes = androidx.compose.ui.geometry.Rect(
        pos[0] + (zone.optDouble("x", 0.0) * px).toFloat(),
        pos[1] + (zone.optDouble("y", 0.0) * px).toFloat(),
        pos[0] + ((zone.optDouble("x", 0.0) + zone.optDouble("l", 1.0)) * px).toFloat(),
        pos[1] + ((zone.optDouble("y", 0.0) + zone.optDouble("h", 1.0)) * px).toFloat(),
    )
    var ouvert by remember { mutableStateOf(true) }
    var resultat by remember { mutableStateOf<Map<String, Any?>?>(null) }
    fun choisir(id: String?) {
        resultat = id?.let { mapOf("id" to it) }
        ouvert = false
    }
    fun elements(cle: String) = d.optJSONArray(cle)?.objets().orEmpty().map { e ->
        io.github.neoruaa.glasmio.ui.GlasmioCascadingMenuItem(
            title = e.optString("titre"),
            systemName = e.texte("cle"),
            destructive = e.optBoolean("destructif"),
            onClick = { choisir(e.optString("id")) },
        )
    }
    val etiquettes = d.optJSONObject("etiquettes") ?: JSONObject()
    Box(Modifier.fillMaxSize()) {
        // Toucher à côté ferme le menu, comme sur iOS.
        Box(
            Modifier.fillMaxSize().pointerInput(Unit) {
                detectTapGestures { choisir(null) }
            },
        )
        io.github.neoruaa.glasmio.ui.GlasmioTextSelectionMenu(
            selectionBounds = bornes,
            primaryActions = elements("principales"),
            additionalItems = elements("autres"),
            onDismiss = { choisir(null) },
            labels = io.github.neoruaa.glasmio.ui.GlasmioTextSelectionLabels(
                more = etiquettes.optString("plus", "Plus"),
            ),
            expanded = ouvert,
            onClosed = { fini(resultat) },
        )
    }
}
