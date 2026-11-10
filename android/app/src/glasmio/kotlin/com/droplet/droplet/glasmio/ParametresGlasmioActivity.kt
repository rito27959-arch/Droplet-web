// ============================================================================
// LES RÉGLAGES DE DROPLET EN GLASMIO — écran natif Jetpack Compose.
// ----------------------------------------------------------------------------
// Composants Glasmio réels (io.github.neoruaa.glasmio, Apache-2.0) :
//   • GlasmioTheme + glasmioColorScheme : couleurs iOS, accent = celui de
//     Droplet (rouge par défaut, ou celui choisi dans Apparence) ;
//   • GlasmioBackdropHost : la couche que le verre échantillonne ;
//   • GlasmioPinnedListPage : grand titre qui se replie en barre de verre
//     floutée au défilement, bouton retour en verre ;
//   • GlasmioGroupedList / GlasmioListRow / GlasmioSectionTitle /
//     GlasmioGroupedTableFooter : les îlots de réglages ;
//   • GlasmioSwitch : interrupteurs en verre liquide ;
//   • GlasmioAlertDialog : la confirmation du relais en arrière-plan.
//
// Polices et symboles d'Apple : NON (licence). Police système d'Android et
// icônes Material Rounded, via le résolveur d'icônes de Glasmio.
//
// L'écran n'invente rien : il affiche la description envoyée par Dart et lui
// renvoie chaque geste (voir lib/features/settings/parametres_glasmio.dart).
// ============================================================================
package com.droplet.droplet.glasmio

import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Apps
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.Autorenew
import androidx.compose.material.icons.rounded.BatteryAlert
import androidx.compose.material.icons.rounded.Block
import androidx.compose.material.icons.rounded.BugReport
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.CloudDone
import androidx.compose.material.icons.rounded.CloudOff
import androidx.compose.material.icons.rounded.Diamond
import androidx.compose.material.icons.rounded.HealthAndSafety
import androidx.compose.material.icons.rounded.Help
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.Laptop
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.Map
import androidx.compose.material.icons.rounded.MenuBook
import androidx.compose.material.icons.rounded.Nightlight
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material.icons.rounded.NotificationsOff
import androidx.compose.material.icons.rounded.Palette
import androidx.compose.material.icons.rounded.PieChart
import androidx.compose.material.icons.rounded.PrivacyTip
import androidx.compose.material.icons.rounded.Public
import androidx.compose.material.icons.rounded.Shield
import androidx.compose.material.icons.rounded.SupportAgent
import androidx.compose.material.icons.rounded.Translate
import androidx.compose.material.icons.rounded.VpnLock
import androidx.compose.material.icons.rounded.WifiTethering
import androidx.compose.material.icons.rounded.WorkspacePremium
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.github.neoruaa.glasmio.core.GlasmioTheme
import io.github.neoruaa.glasmio.core.IosTypography
import io.github.neoruaa.glasmio.core.LocalGlassColors
import io.github.neoruaa.glasmio.core.glasmioColorScheme
import io.github.neoruaa.glasmio.glass.GlasmioBackdropHost
import io.github.neoruaa.glasmio.icons.GlasmioIconProvider
import io.github.neoruaa.glasmio.icons.GlasmioIconResolver
import io.github.neoruaa.glasmio.icons.MaterialGlasmioIconResolver
import io.github.neoruaa.glasmio.scaffold.GlasmioPinnedListPage
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonRole
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonSpec
import io.github.neoruaa.glasmio.ui.GlasmioAlertDialog
import io.github.neoruaa.glasmio.ui.GlasmioGroupedList
import io.github.neoruaa.glasmio.ui.GlasmioGroupedTableFooter
import io.github.neoruaa.glasmio.ui.GlasmioListRow
import io.github.neoruaa.glasmio.ui.GlasmioSectionTitle
import io.github.neoruaa.glasmio.ui.GlasmioSwitch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.lang.ref.WeakReference

class ParametresGlasmioActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Glasmio exige Android 13 ; et sans description (processus recréé
        // par le système), il n'y a rien à montrer : Flutter reprend la main.
        val desc = PontGlasmio.description
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || desc == null) {
            finish()
            return
        }
        PontGlasmio.ecranOuvert = WeakReference(this)
        val sombre = desc.optBoolean("sombre", true)
        val barres = if (sombre) {
            SystemBarStyle.dark(android.graphics.Color.TRANSPARENT)
        } else {
            SystemBarStyle.light(android.graphics.Color.TRANSPARENT, android.graphics.Color.TRANSPARENT)
        }
        enableEdgeToEdge(statusBarStyle = barres, navigationBarStyle = barres)
        setContent {
            val d = PontGlasmio.description
            if (d != null) EcranParametres(d, onRetour = { finish() })
        }
    }

    override fun onDestroy() {
        if (isFinishing && PontGlasmio.ecranOuvert?.get() === this) {
            PontGlasmio.ecranOuvert = null
            PontGlasmio.ferme()
        }
        super.onDestroy()
    }
}

// ─────────────────────────────────────────────────────────────
//  Les icônes : clés envoyées par Dart → Material Rounded
// ─────────────────────────────────────────────────────────────

private val ICONES: Map<String, ImageVector> = mapOf(
    "laptop" to Icons.Rounded.Laptop,
    "palette" to Icons.Rounded.Palette,
    "translate" to Icons.Rounded.Translate,
    "notifications" to Icons.Rounded.Notifications,
    "notifications_active" to Icons.Rounded.NotificationsActive,
    "notifications_off" to Icons.Rounded.NotificationsOff,
    "nightlight" to Icons.Rounded.Nightlight,
    "menu_book" to Icons.Rounded.MenuBook,
    "apps" to Icons.Rounded.Apps,
    "wifi_tethering" to Icons.Rounded.WifiTethering,
    "autorenew" to Icons.Rounded.Autorenew,
    "battery_alert" to Icons.Rounded.BatteryAlert,
    "vpn_lock" to Icons.Rounded.VpnLock,
    "public" to Icons.Rounded.Public,
    "map" to Icons.Rounded.Map,
    "pie_chart" to Icons.Rounded.PieChart,
    "block" to Icons.Rounded.Block,
    "lock" to Icons.Rounded.Lock,
    "health_and_safety" to Icons.Rounded.HealthAndSafety,
    "cloud_done" to Icons.Rounded.CloudDone,
    "cloud_off" to Icons.Rounded.CloudOff,
    "diamond" to Icons.Rounded.Diamond,
    "workspace_premium" to Icons.Rounded.WorkspacePremium,
    "auto_awesome" to Icons.Rounded.AutoAwesome,
    "shield" to Icons.Rounded.Shield,
    "help" to Icons.Rounded.Help,
    "support_agent" to Icons.Rounded.SupportAgent,
    "privacy_tip" to Icons.Rounded.PrivacyTip,
    "bug_report" to Icons.Rounded.BugReport,
    "info" to Icons.Rounded.Info,
    "check" to Icons.Rounded.Check,
)

/** Les symboles internes de Glasmio (chevrons, retour…) gardent leur
 *  repli Material ; les clés de Droplet passent avant. */
private val RESOLVEUR = GlasmioIconResolver { nom -> ICONES[nom] ?: MaterialGlasmioIconResolver.resolve(nom) }

private fun couleur(o: JSONObject, cle: String, defaut: Color): Color =
    if (o.has(cle)) Color(o.optLong(cle).toInt()) else defaut

private fun JSONObject.texte(cle: String): String? =
    if (has(cle) && !isNull(cle)) optString(cle).takeIf { it.isNotEmpty() } else null

private fun JSONArray.objets(): List<JSONObject> = (0 until length()).mapNotNull { optJSONObject(it) }

// ─────────────────────────────────────────────────────────────
//  L'écran
// ─────────────────────────────────────────────────────────────

/** La lueur rouge du haut de Droplet (voir ouro_surfaces.dart). */
private val ROUGE_LUEUR = Color(0xFFE8344E)

@Composable
private fun EcranParametres(d: JSONObject, onRetour: () -> Unit) {
    val sombre = d.optBoolean("sombre", true)
    val accent = couleur(d, "accent", Color(0xFFE8344E))
    GlasmioIconProvider(resolver = RESOLVEUR) {
        GlasmioTheme(isDark = sombre, colorScheme = glasmioColorScheme(sombre, accent)) {
            val couleurs = LocalGlassColors.current
            val fond = couleurs.groupedBackground
            val intensite = if (sombre) 0.17f else 0.075f
            // Le même fond que l'accueil : la lueur rouge s'éteint vers le bas.
            val lueur = Brush.verticalGradient(
                0f to lerp(fond, ROUGE_LUEUR, intensite),
                0.45f to lerp(fond, ROUGE_LUEUR, intensite * 0.35f),
                1f to fond,
                startY = 0f,
                endY = 1000f,
            )
            // Un interrupteur suit le doigt tout de suite, sans attendre Dart ;
            // la description suivante (l'état réel) reprend la main.
            val provisoire = remember { mutableStateMapOf<String, Boolean>() }
            LaunchedEffect(d) { provisoire.clear() }

            GlasmioBackdropHost(
                modifier = Modifier.fillMaxSize(),
                sampledContent = { Box(Modifier.fillMaxSize().background(lueur)) },
                overlayContent = {
                    GlasmioPinnedListPage(
                        title = d.optString("titre"),
                        onNavigateBack = onRetour,
                        navigateBackContentDescription = d.texte("retour") ?: "Back",
                        backgroundBrush = lueur,
                    ) {
                        d.optJSONObject("profil")?.let { p ->
                            item(key = "profil") { CarteProfil(p) }
                        }
                        val sections = d.optJSONArray("sections")?.objets().orEmpty()
                        sections.forEachIndexed { i, s ->
                            item(key = "section-$i") {
                                Column(Modifier.fillMaxWidth().padding(top = 14.dp)) {
                                    s.texte("entete")?.let { GlasmioSectionTitle(it) }
                                    GlasmioGroupedList {
                                        s.optJSONArray("lignes")?.objets().orEmpty().forEachIndexed { j, l ->
                                            Ligne(l, premiere = j == 0, provisoire = provisoire)
                                        }
                                    }
                                    s.texte("pied")?.let { GlasmioGroupedTableFooter(it) }
                                }
                            }
                        }
                        item(key = "bas") { Spacer(Modifier.padding(bottom = 24.dp)) }
                    }
                },
            )

            PontGlasmio.alerte?.let { a ->
                GlasmioAlertDialog(
                    onDismissRequest = { PontGlasmio.annulerAlerte() },
                    title = a.optString("titre"),
                    message = a.texte("message"),
                    buttons = listOf(
                        GlasmioAlertButtonSpec(
                            label = a.optString("annuler"),
                            onClick = { PontGlasmio.annulerAlerte() },
                            role = GlasmioAlertButtonRole.Cancel,
                        ),
                        GlasmioAlertButtonSpec(
                            label = a.optString("confirmer"),
                            onClick = { PontGlasmio.confirmerAlerte() },
                            role = if (a.optBoolean("destructif")) {
                                GlasmioAlertButtonRole.Destructive
                            } else {
                                GlasmioAlertButtonRole.Default
                            },
                        ),
                    ),
                )
            }
        }
    }
}

/** Le carré coloré à gauche d'une ligne, comme dans les Réglages d'iOS. */
@Composable
private fun Pastille(cle: String, teinte: Color) {
    Box(
        Modifier.size(30.dp).clip(RoundedCornerShape(7.dp)).background(teinte),
        contentAlignment = Alignment.Center,
    ) {
        if (cle.startsWith("lettre:")) {
            Text(
                cle.removePrefix("lettre:"),
                color = Color.White,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
            )
        } else {
            Icon(ICONES[cle] ?: Icons.Rounded.Info, contentDescription = null, tint = Color.White, modifier = Modifier.size(19.dp))
        }
    }
}

@Composable
private fun Ligne(l: JSONObject, premiere: Boolean, provisoire: MutableMap<String, Boolean>) {
    val couleurs = LocalGlassColors.current
    val id = l.optString("id")
    val type = l.optString("type")
    val actif = l.optBoolean("actif", true)
    val teinte = couleur(l, "teinte", couleurs.accent)
    val pastille: @Composable () -> Unit = { Pastille(l.optString("icone"), teinte) }
    when (type) {
        "interrupteur" -> {
            val coche = provisoire[id] ?: l.optBoolean("coche")
            GlasmioListRow(
                title = l.optString("titre"),
                subtitle = l.texte("sous"),
                leading = pastille,
                showTopSeparator = !premiere,
                enabled = actif,
                // Une ligne « cliquable » ouvre aussi sa page (Tor).
                onClick = if (l.optBoolean("cliquable")) ({ PontGlasmio.evenement("${id}_detail") }) else null,
                showDisclosure = false,
                trailing = {
                    GlasmioSwitch(
                        checked = coche,
                        onCheckedChange = {
                            provisoire[id] = it
                            PontGlasmio.evenement(id, it)
                        },
                        enabled = actif,
                    )
                },
            )
        }
        "choix" -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = false,
            trailing = if (l.optBoolean("coche")) {
                { Icon(Icons.Rounded.Check, contentDescription = null, tint = couleurs.accent, modifier = Modifier.size(22.dp)) }
            } else {
                null
            },
        )
        "action" -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            detail = l.texte("valeur"),
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = false,
        )
        else -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            detail = l.texte("valeur"),
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = true,
        )
    }
}

/** L'en-tête : photo (ou initiale), nom, début de l'identifiant. */
@Composable
private fun CarteProfil(p: JSONObject) {
    val couleurs = LocalGlassColors.current
    val chemin = p.texte("photo")
    val image: ImageBitmap? = remember(chemin) {
        chemin?.let { c ->
            runCatching {
                val f = File(c)
                if (!f.exists()) return@runCatching null
                // Vignette : jamais l'image entière en mémoire.
                val bornes = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(c, bornes)
                var echelle = 1
                while (bornes.outWidth / (echelle * 2) >= 240 && bornes.outHeight / (echelle * 2) >= 240) echelle *= 2
                BitmapFactory.decodeFile(c, BitmapFactory.Options().apply { inSampleSize = echelle })?.asImageBitmap()
            }.getOrNull()
        }
    }
    GlasmioGroupedList {
        Row(
            Modifier
                .fillMaxWidth()
                .clickable { PontGlasmio.evenement(p.optString("id", "profil")) }
                .semantics { p.texte("aide")?.let { contentDescription = it } }
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(Modifier.size(60.dp).clip(CircleShape), contentAlignment = Alignment.Center) {
                if (image != null) {
                    Image(image, contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                } else {
                    Box(
                        Modifier.fillMaxSize().background(couleur(p, "couleur", couleurs.accent)),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(p.optString("initiale", "?"), color = Color.White, fontSize = 26.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        p.optString("nom"),
                        style = IosTypography.title2,
                        fontWeight = FontWeight.SemiBold,
                        color = couleurs.content,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false),
                    )
                    if (p.optBoolean("pro")) {
                        Spacer(Modifier.width(6.dp))
                        Icon(Icons.Rounded.AutoAwesome, contentDescription = "Pro", tint = couleurs.accent, modifier = Modifier.size(18.dp))
                    }
                }
                p.texte("sous")?.let {
                    Text(it, style = IosTypography.subheadline, color = couleurs.secondaryContent, maxLines = 1)
                }
            }
            Icon(Icons.Rounded.ChevronRight, contentDescription = null, tint = couleurs.tertiaryContent)
        }
    }
}
