// ============================================================================
// LES BLOCS DES ÉCRANS GLASMIO — chaque clé de la description Dart a ici
// son rendu, avec les composants Glasmio :
//   profil   → carte du profil (Réglages)
//   entete   → photo en grand, nom, statut, boutons d'action (Infos contact)
//   vitrine  → emblème, accroche, garanties (Droplet Pro)
//   stats    → petites cartes chiffrées (Infos contact)
//   sections → îlots de lignes (GlasmioListRow) ou grille de photos
//   bas      → barre d'action flottante (GlasmioButton « Prominent »)
// Les types de lignes : nav, interrupteur, choix, action, bouton.
// ============================================================================
package com.droplet.droplet.glasmio

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AllInclusive
import androidx.compose.material.icons.rounded.Apps
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.Autorenew
import androidx.compose.material.icons.rounded.BatteryAlert
import androidx.compose.material.icons.rounded.Block
import androidx.compose.material.icons.rounded.BugReport
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.Call
import androidx.compose.material.icons.rounded.ChatBubble
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.CloudDone
import androidx.compose.material.icons.rounded.CloudOff
import androidx.compose.material.icons.rounded.Diamond
import androidx.compose.material.icons.rounded.EventBusy
import androidx.compose.material.icons.rounded.Flag
import androidx.compose.material.icons.rounded.Forum
import androidx.compose.material.icons.rounded.GraphicEq
import androidx.compose.material.icons.rounded.HealthAndSafety
import androidx.compose.material.icons.rounded.Help
import androidx.compose.material.icons.rounded.Image
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.InsertDriveFile
import androidx.compose.material.icons.rounded.Laptop
import androidx.compose.material.icons.rounded.Link
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.LockOpen
import androidx.compose.material.icons.rounded.Map
import androidx.compose.material.icons.rounded.MenuBook
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.Nightlight
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material.icons.rounded.NotificationsOff
import androidx.compose.material.icons.rounded.Palette
import androidx.compose.material.icons.rounded.PhotoLibrary
import androidx.compose.material.icons.rounded.PieChart
import androidx.compose.material.icons.rounded.PlayCircle
import androidx.compose.material.icons.rounded.PrivacyTip
import androidx.compose.material.icons.rounded.Public
import androidx.compose.material.icons.rounded.QrCode
import androidx.compose.material.icons.rounded.Shield
import androidx.compose.material.icons.rounded.SupportAgent
import androidx.compose.material.icons.rounded.TextFields
import androidx.compose.material.icons.rounded.TimerOff
import androidx.compose.material.icons.rounded.Translate
import androidx.compose.material.icons.rounded.Verified
import androidx.compose.material.icons.rounded.VerifiedUser
import androidx.compose.material.icons.rounded.VpnLock
import androidx.compose.material.icons.rounded.Wallpaper
import androidx.compose.material.icons.rounded.WarningAmber
import androidx.compose.material.icons.rounded.WifiOff
import androidx.compose.material.icons.rounded.WifiTethering
import androidx.compose.material.icons.rounded.WorkspacePremium
import androidx.compose.material.icons.rounded.StopCircle
import androidx.compose.material.icons.rounded.AlternateEmail
import androidx.compose.material.icons.rounded.ViewDay
import androidx.compose.material.icons.rounded.Inbox
import androidx.compose.material.icons.rounded.Visibility
import androidx.compose.material.icons.rounded.SettingsApplications
import androidx.compose.material.icons.rounded.Delete
import androidx.compose.material.icons.rounded.Devices
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material.icons.rounded.QrCodeScanner
import androidx.compose.material.icons.rounded.Mail
import androidx.compose.material.icons.rounded.Description
import androidx.compose.material.icons.rounded.Folder
import androidx.compose.material.icons.rounded.CleaningServices
import androidx.compose.material.icons.rounded.Storage
import androidx.compose.material.icons.rounded.History
import androidx.compose.material.icons.rounded.Psychology
import androidx.compose.material.icons.rounded.Emergency
import androidx.compose.material.icons.rounded.Sos
import androidx.compose.material.icons.rounded.Group
import androidx.compose.material.icons.rounded.PersonAdd
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.material.icons.rounded.Logout
import androidx.compose.material.icons.rounded.Download
import androidx.compose.material.icons.rounded.Upload
import androidx.compose.material.icons.rounded.Key
import androidx.compose.material.icons.rounded.Star
import androidx.compose.material.icons.rounded.PushPin
import androidx.compose.material.icons.rounded.Archive
import androidx.compose.material.icons.rounded.ForwardToInbox
import androidx.compose.material.icons.rounded.Podcasts
import androidx.compose.material.icons.rounded.PersonSearch
import androidx.compose.material.icons.rounded.Videocam
import androidx.compose.material.icons.rounded.StarOutline
import androidx.compose.material.icons.rounded.Shortcut
import androidx.compose.material.icons.rounded.Reply
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material.icons.rounded.MoreHoriz
import androidx.compose.material.icons.rounded.ContentCopy
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.VolumeOff
import androidx.compose.material.icons.rounded.VolumeUp
import androidx.compose.material.icons.rounded.MarkChatRead
import androidx.compose.material.icons.rounded.MarkChatUnread
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.github.neoruaa.glasmio.core.IosTypography
import io.github.neoruaa.glasmio.core.LocalGlassColors
import io.github.neoruaa.glasmio.glass.GlassEmphasis
import io.github.neoruaa.glasmio.icons.GlasmioIconResolver
import io.github.neoruaa.glasmio.icons.MaterialGlasmioIconResolver
import io.github.neoruaa.glasmio.ui.GlasmioButton
import io.github.neoruaa.glasmio.ui.GlasmioButtonSize
import io.github.neoruaa.glasmio.ui.GlasmioCard
import io.github.neoruaa.glasmio.ui.GlasmioGroupedList
import io.github.neoruaa.glasmio.ui.GlasmioListRow
import io.github.neoruaa.glasmio.ui.GlasmioSwitch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

// ─────────────────────────────────────────────────────────────
//  Les icônes : clés envoyées par Dart → Material Rounded
// ─────────────────────────────────────────────────────────────

internal val ICONES: Map<String, ImageVector> = mapOf(
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
    "lock_open" to Icons.Rounded.LockOpen,
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
    "graphic_eq" to Icons.Rounded.GraphicEq,
    "text_fields" to Icons.Rounded.TextFields,
    "wallpaper" to Icons.Rounded.Wallpaper,
    "all_inclusive" to Icons.Rounded.AllInclusive,
    "event_busy" to Icons.Rounded.EventBusy,
    "wifi_off" to Icons.Rounded.WifiOff,
    "verified" to Icons.Rounded.Verified,
    "verified_user" to Icons.Rounded.VerifiedUser,
    "warning" to Icons.Rounded.WarningAmber,
    "qr_code" to Icons.Rounded.QrCode,
    "timer_off" to Icons.Rounded.TimerOff,
    "forum" to Icons.Rounded.Forum,
    "call" to Icons.Rounded.Call,
    "chat_bubble" to Icons.Rounded.ChatBubble,
    "photo_library" to Icons.Rounded.PhotoLibrary,
    "calendar_month" to Icons.Rounded.CalendarMonth,
    "mic" to Icons.Rounded.Mic,
    "file" to Icons.Rounded.InsertDriveFile,
    "link" to Icons.Rounded.Link,
    "flag" to Icons.Rounded.Flag,
    "play_circle" to Icons.Rounded.PlayCircle,
    "image" to Icons.Rounded.Image,
    "mark_chat_unread" to Icons.Rounded.MarkChatUnread,
    "mark_chat_read" to Icons.Rounded.MarkChatRead,
    "volume_up" to Icons.Rounded.VolumeUp,
    "volume_off" to Icons.Rounded.VolumeOff,
    "check_circle" to Icons.Rounded.CheckCircle,
    "content_copy" to Icons.Rounded.ContentCopy,
    "more_horiz" to Icons.Rounded.MoreHoriz,
    "refresh" to Icons.Rounded.Refresh,
    "reply" to Icons.Rounded.Reply,
    "shortcut" to Icons.Rounded.Shortcut,
    "star_outline" to Icons.Rounded.StarOutline,
    "videocam" to Icons.Rounded.Videocam,
    "person_search" to Icons.Rounded.PersonSearch,
    "podcasts" to Icons.Rounded.Podcasts,
    "forward_to_inbox" to Icons.Rounded.ForwardToInbox,
    "stop_circle" to Icons.Rounded.StopCircle,
    "alternate_email" to Icons.Rounded.AlternateEmail,
    "view_day" to Icons.Rounded.ViewDay,
    "inbox" to Icons.Rounded.Inbox,
    "visibility" to Icons.Rounded.Visibility,
    "settings_applications" to Icons.Rounded.SettingsApplications,
    "delete" to Icons.Rounded.Delete,
    "devices" to Icons.Rounded.Devices,
    "smartphone" to Icons.Rounded.Smartphone,
    "qr_code_scanner" to Icons.Rounded.QrCodeScanner,
    "mail" to Icons.Rounded.Mail,
    "description" to Icons.Rounded.Description,
    "folder" to Icons.Rounded.Folder,
    "cleaning" to Icons.Rounded.CleaningServices,
    "storage" to Icons.Rounded.Storage,
    "history" to Icons.Rounded.History,
    "psychology" to Icons.Rounded.Psychology,
    "map_offline" to Icons.Rounded.Map,
    "emergency" to Icons.Rounded.Emergency,
    "sos" to Icons.Rounded.Sos,
    "group" to Icons.Rounded.Group,
    "person_add" to Icons.Rounded.PersonAdd,
    "edit" to Icons.Rounded.Edit,
    "logout" to Icons.Rounded.Logout,
    "download" to Icons.Rounded.Download,
    "upload" to Icons.Rounded.Upload,
    "key" to Icons.Rounded.Key,
    "star" to Icons.Rounded.Star,
    "push_pin" to Icons.Rounded.PushPin,
    "archive" to Icons.Rounded.Archive,
)

/** Les symboles internes de Glasmio (chevrons, retour…) gardent leur
 *  repli Material ; les clés de Droplet passent avant. */
internal val RESOLVEUR = GlasmioIconResolver { nom ->
    ICONES[nom] ?: when {
        // Le chevron fin d'iOS pour les lignes qui mènent ailleurs (le repli
        // de Glasmio dessine une flèche).
        nom.startsWith("chevron.right") || nom.startsWith("chevron.forward") -> Icons.Rounded.ChevronRight
        else -> MaterialGlasmioIconResolver.resolve(nom)
    }
}

internal fun couleur(o: JSONObject, cle: String, defaut: Color): Color =
    if (o.has(cle)) Color(o.optLong(cle).toInt()) else defaut

internal fun JSONObject.texte(cle: String): String? =
    if (has(cle) && !isNull(cle)) optString(cle).takeIf { it.isNotEmpty() } else null

internal fun JSONArray.objets(): List<JSONObject> = (0 until length()).mapNotNull { optJSONObject(it) }

/** Une vignette d'image sur le disque — jamais l'image entière en mémoire. */
@Composable
internal fun vignette(chemin: String?, cote: Int): ImageBitmap? {
    val contexte = androidx.compose.ui.platform.LocalContext.current
    return remember(chemin, cote) {
    chemin?.let { c ->
        // Une image embarquée dans l'appli Flutter (« asset:assets/… »).
        if (c.startsWith("asset:")) {
            return@let runCatching {
                val cle = io.flutter.FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(c.removePrefix("asset:"))
                contexte.assets.open(cle).use { BitmapFactory.decodeStream(it) }?.asImageBitmap()
            }.getOrNull()
        }
        runCatching {
            if (!File(c).exists()) return@runCatching null
            val bornes = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(c, bornes)
            var echelle = 1
            while (bornes.outWidth / (echelle * 2) >= cote && bornes.outHeight / (echelle * 2) >= cote) echelle *= 2
            BitmapFactory.decodeFile(c, BitmapFactory.Options().apply { inSampleSize = echelle })?.asImageBitmap()
        }.getOrNull()
    }
    }
}

/** La photo d'une personne, ou son initiale sur sa couleur. */
@Composable
internal fun Avatar(o: JSONObject, taille: Int) {
    val couleurs = LocalGlassColors.current
    val image = vignette(o.texte("photo"), taille * 3)
    Box(Modifier.size(taille.dp).clip(CircleShape), contentAlignment = Alignment.Center) {
        if (image != null) {
            Image(image, contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
        } else {
            Box(
                Modifier.fillMaxSize().background(couleur(o, "couleur", couleurs.accent)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    o.optString("initiale", "?"),
                    color = Color.White,
                    fontSize = (taille * 0.43f).sp,
                    fontWeight = FontWeight.SemiBold,
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Les lignes
// ─────────────────────────────────────────────────────────────

/** Le carré coloré à gauche d'une ligne, comme dans les Réglages d'iOS. */
@Composable
internal fun Pastille(cle: String, teinte: Color) {
    Box(
        Modifier.size(30.dp).clip(RoundedCornerShape(7.dp)).background(teinte),
        contentAlignment = Alignment.Center,
    ) {
        if (cle.startsWith("lettre:")) {
            Text(cle.removePrefix("lettre:"), color = Color.White, fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
        } else {
            Icon(ICONES[cle] ?: Icons.Rounded.Info, contentDescription = null, tint = Color.White, modifier = Modifier.size(19.dp))
        }
    }
}

/** Petite étiquette (« Meilleure offre »). */
@Composable
private fun Badge(texte: String) {
    val couleurs = LocalGlassColors.current
    Text(
        texte,
        color = Color.White,
        fontSize = 11.sp,
        fontWeight = FontWeight.SemiBold,
        modifier = Modifier
            .clip(RoundedCornerShape(50))
            .background(couleurs.accent)
            .padding(horizontal = 8.dp, vertical = 3.dp),
    )
}

@Composable
internal fun Ligne(l: JSONObject, premiere: Boolean, provisoire: MutableMap<String, Boolean>) {
    val couleurs = LocalGlassColors.current
    val id = l.optString("id")
    val type = l.optString("type")
    val actif = l.optBoolean("actif", true)
    val teinte = couleur(l, "teinte", couleurs.accent)
    val pastille: (@Composable () -> Unit)? = l.texte("icone")?.let { cle -> { Pastille(cle, teinte) } }
    val valeur = l.texte("valeur")
    val badge = l.texte("badge")
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
        // Un choix parmi plusieurs (langue, offre) : coche à droite, et
        // éventuellement un prix et une étiquette.
        "choix" -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = false,
            trailing = if (valeur != null || badge != null || l.optBoolean("coche")) {
                {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        badge?.let { Badge(it) }
                        valeur?.let {
                            Text(it, style = IosTypography.body, fontWeight = FontWeight.SemiBold, color = couleurs.content)
                        }
                        Box(Modifier.size(22.dp), contentAlignment = Alignment.Center) {
                            if (l.optBoolean("coche")) {
                                Icon(Icons.Rounded.Check, contentDescription = null, tint = couleurs.accent, modifier = Modifier.size(22.dp))
                            }
                        }
                    }
                }
            } else {
                null
            },
        )
        "action" -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            detail = valeur,
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = false,
        )
        // Un bouton dans une liste (Bloquer, Signaler) : texte centré.
        "bouton" -> GlasmioListRow(
            title = l.optString("titre"),
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = false,
            titleColor = if (l.optBoolean("destructif")) couleurs.destructive else couleurs.accent,
            titleAlignment = TextAlign.Center,
        )
        // Un choix dans un menu de verre qui s'ouvre EN SE GONFLANT depuis la
        // pastille de la ligne (GlasmioPopUpButton : la bulle se déforme et
        // grandit jusqu'au menu, comme sur iOS). Sert à la langue.
        "menu" -> {
            val options = l.optJSONArray("options")?.objets().orEmpty()
            val choisi = options.firstOrNull { it.optBoolean("coche") } ?: options.firstOrNull()
            GlasmioListRow(
                title = l.optString("titre"),
                subtitle = l.texte("sous"),
                leading = pastille,
                showTopSeparator = !premiere,
                enabled = actif,
                showDisclosure = false,
                trailing = if (choisi != null) {
                    {
                        io.github.neoruaa.glasmio.ui.GlasmioPopUpButton(
                            selected = choisi,
                            items = options,
                            onSelected = { o -> PontGlasmio.evenement(o.optString("id")) },
                            label = { o -> o.optString("titre") },
                            enabled = actif,
                            // La pastille reste courte : le titre de la ligne doit rester lisible.
                            modifier = Modifier.widthIn(max = 150.dp),
                        )
                    }
                } else {
                    null
                },
            )
        }
        // Un champ de saisie (masqué pour un mot de passe). La saisie reste ici
        // et part avec chaque geste ; « signaler » prévient Dart à chaque
        // frappe (pour la jauge de solidité du mot de passe).
        "champ" -> io.github.neoruaa.glasmio.ui.GlasmioTextField(
            value = PontGlasmio.champs[id] ?: "",
            onValueChange = { v ->
                PontGlasmio.champs[id] = v
                if (l.optBoolean("signaler")) PontGlasmio.evenement(id, v)
            },
            placeholder = l.optString("titre"),
            enabled = actif,
            visualTransformation = if (l.optBoolean("masque")) {
                androidx.compose.ui.text.input.PasswordVisualTransformation()
            } else {
                androidx.compose.ui.text.input.VisualTransformation.None
            },
            keyboardOptions = if (l.optBoolean("masque")) {
                androidx.compose.foundation.text.KeyboardOptions(keyboardType = androidx.compose.ui.text.input.KeyboardType.Password, autoCorrectEnabled = false)
            } else {
                androidx.compose.foundation.text.KeyboardOptions.Default
            },
            trailing = l.texte("valeur")?.let { v ->
                { Text(v, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = teinte) }
            },
        )
        // Un curseur de verre (taille du texte, arrondi des bulles). La valeur
        // suit le doigt ; elle part à Dart quand on relâche.
        "curseur" -> {
            val min = l.optDouble("min", 0.0).toFloat()
            val max = l.optDouble("max", 1.0).toFloat()
            var v by androidx.compose.runtime.remember(l.optDouble("valeur")) {
                androidx.compose.runtime.mutableFloatStateOf(l.optDouble("valeur", min.toDouble()).toFloat())
            }
            Column(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(l.optString("titre"), style = IosTypography.body, color = couleurs.content, modifier = Modifier.weight(1f))
                    Text("${v.toInt()}", style = IosTypography.body, color = couleurs.secondaryContent)
                }
                io.github.neoruaa.glasmio.ui.GlasmioSlider(
                    value = v,
                    onValueChange = { v = kotlin.math.round(it) },
                    valueRange = min..max,
                    enabled = actif,
                    onValueChangeFinished = { PontGlasmio.evenement(id, v.toDouble()) },
                    modifier = Modifier.padding(top = 6.dp),
                )
            }
        }
        // Une rangée de pastilles de couleur (accent) : la choisie cochée.
        "couleurs" -> Row(
            Modifier
                .fillMaxWidth()
                .horizontalScroll(androidx.compose.foundation.rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            l.optJSONArray("options")?.objets().orEmpty().forEach { o ->
                val coche = o.optBoolean("coche")
                Box(
                    Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(50))
                        .background(couleur(o, "teinte", couleurs.accent))
                        .clickable { if (!coche) PontGlasmio.evenement(o.optString("id")) },
                    contentAlignment = Alignment.Center,
                ) {
                    if (coche) Icon(Icons.Rounded.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(20.dp))
                }
            }
        }
        // Un paragraphe (question et réponse de l'aide) : le texte entier,
        // sur autant de lignes qu'il faut.
        "paragraphe" -> Column(
            Modifier
                .fillMaxWidth()
                .then(if (l.optBoolean("cliquable")) Modifier.clickable { PontGlasmio.evenement(id) } else Modifier)
                .padding(horizontal = 16.dp, vertical = 12.dp),
        ) {
            val titre = l.texte("titre")
            titre?.let { Text(it, style = IosTypography.body, fontWeight = FontWeight.SemiBold, color = couleurs.content) }
            l.texte("sous")?.let {
                Text(
                    it,
                    style = if (titre == null) IosTypography.body else IosTypography.subheadline,
                    color = if (titre == null) couleurs.content else couleurs.secondaryContent,
                    modifier = Modifier.padding(top = if (titre == null) 0.dp else 4.dp),
                )
            }
        }
        // Une ligne d'information, sans geste.
        "info" -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            detail = valeur,
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            showDisclosure = false,
        )
        else -> GlasmioListRow(
            title = l.optString("titre"),
            subtitle = l.texte("sous"),
            detail = valeur,
            leading = pastille,
            showTopSeparator = !premiere,
            enabled = actif,
            onClick = { PontGlasmio.evenement(id) },
            showDisclosure = true,
        )
    }
}

// ─────────────────────────────────────────────────────────────
//  Réglages : la carte du profil
// ─────────────────────────────────────────────────────────────

@Composable
internal fun CarteProfil(p: JSONObject) {
    val couleurs = LocalGlassColors.current
    GlasmioGroupedList {
        Row(
            Modifier
                .fillMaxWidth()
                .clickable { PontGlasmio.evenement(p.optString("id", "profil")) }
                .semantics { p.texte("aide")?.let { contentDescription = it } }
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Avatar(p, 60)
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

// ─────────────────────────────────────────────────────────────
//  Infos du contact : l'en-tête et les statistiques
// ─────────────────────────────────────────────────────────────

@Composable
internal fun EnTeteContact(e: JSONObject) {
    val couleurs = LocalGlassColors.current
    Column(
        Modifier.fillMaxWidth().padding(top = 4.dp, bottom = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(Modifier.clickable(enabled = e.has("idPhoto")) { PontGlasmio.evenement(e.optString("idPhoto")) }) {
            Avatar(e, 100)
        }
        Spacer(Modifier.height(12.dp))
        Text(
            e.optString("nom"),
            style = IosTypography.title1,
            fontWeight = FontWeight.Bold,
            color = couleurs.content,
            textAlign = TextAlign.Center,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        e.texte("statut")?.let {
            Text(
                it,
                style = IosTypography.subheadline,
                color = if (e.optBoolean("enLigne")) Color(0xFF30D158) else couleurs.secondaryContent,
                modifier = Modifier.padding(top = 2.dp),
            )
        }
        val actions = e.optJSONArray("actions")?.objets().orEmpty()
        if (actions.isNotEmpty()) {
            Spacer(Modifier.height(16.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                actions.forEach { a ->
                    GlasmioCard(
                        modifier = Modifier.weight(1f).height(64.dp),
                        onClick = { PontGlasmio.evenement(a.optString("id")) },
                    ) {
                        Column(
                            Modifier.fillMaxSize(),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center,
                        ) {
                            Icon(
                                ICONES[a.optString("icone")] ?: Icons.Rounded.Info,
                                contentDescription = null,
                                tint = couleurs.accent,
                                modifier = Modifier.size(22.dp),
                            )
                            Spacer(Modifier.height(4.dp))
                            Text(a.optString("titre"), fontSize = 12.sp, color = couleurs.accent, maxLines = 1)
                        }
                    }
                }
            }
        }
    }
}

@Composable
internal fun Statistiques(stats: List<JSONObject>) {
    val couleurs = LocalGlassColors.current
    Row(Modifier.fillMaxWidth().padding(top = 14.dp), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        stats.forEach { s ->
            GlasmioCard(modifier = Modifier.weight(1f).height(84.dp)) {
                Column(
                    Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Icon(
                        ICONES[s.optString("icone")] ?: Icons.Rounded.Info,
                        contentDescription = null,
                        tint = couleur(s, "teinte", couleurs.accent),
                        modifier = Modifier.size(20.dp),
                    )
                    Spacer(Modifier.height(6.dp))
                    Text(s.optString("valeur"), style = IosTypography.headline, color = couleurs.content, maxLines = 1)
                    Text(s.optString("titre"), fontSize = 11.sp, color = couleurs.secondaryContent, maxLines = 1)
                }
            }
        }
    }
}

/** Les photos partagées, en grille de trois. */
@Composable
internal fun GrillePhotos(photos: List<JSONObject>) {
    val couleurs = LocalGlassColors.current
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        photos.chunked(3).forEach { rang ->
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                rang.forEach { p ->
                    val image = vignette(p.texte("chemin"), 300)
                    Column(Modifier.weight(1f), horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        Modifier
                            .fillMaxWidth()
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(if (p.has("titre")) 22.dp else 12.dp))
                            .background(couleurs.elevatedBackground)
                            .clickable { PontGlasmio.evenement(p.optString("id")) },
                        contentAlignment = Alignment.Center,
                    ) {
                        val teinte = couleur(p, "teinte", couleurs.tertiaryContent)
                        if (image != null) {
                            Image(image, contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                        } else {
                            Box(Modifier.fillMaxSize().background(teinte.copy(alpha = 0.16f)), contentAlignment = Alignment.Center) {
                                Icon(ICONES[p.optString("icone")] ?: Icons.Rounded.Image, contentDescription = null, tint = teinte, modifier = Modifier.size(32.dp))
                            }
                        }
                        // La taille du fichier, en bas à gauche.
                        p.texte("legende")?.let {
                            Text(
                                it,
                                color = Color.White,
                                fontSize = 11.sp,
                                modifier = Modifier
                                    .align(Alignment.BottomStart)
                                    .padding(6.dp)
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(Color.Black.copy(alpha = 0.5f))
                                    .padding(horizontal = 5.dp, vertical = 2.dp),
                            )
                        }
                        // La sélection, en haut à droite.
                        if (p.has("coche")) {
                            val coche = p.optBoolean("coche")
                            Box(
                                Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(6.dp)
                                    .size(24.dp)
                                    .clip(RoundedCornerShape(50))
                                    .background(if (coche) couleurs.accent else Color.Black.copy(alpha = 0.25f)),
                                contentAlignment = Alignment.Center,
                            ) {
                                if (coche) Icon(Icons.Rounded.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(16.dp))
                            }
                        }
                        // Réservé à Droplet Pro : une petite étincelle.
                        if (p.optBoolean("verrou")) {
                            Box(
                                Modifier
                                    .align(Alignment.TopStart)
                                    .padding(6.dp)
                                    .size(22.dp)
                                    .clip(RoundedCornerShape(50))
                                    .background(couleurs.groupedBackground.copy(alpha = 0.9f)),
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(Icons.Rounded.AutoAwesome, contentDescription = null, tint = couleurs.accent, modifier = Modifier.size(13.dp))
                            }
                        }
                    }
                    p.texte("titre")?.let {
                        Text(
                            it,
                            fontSize = 12.sp,
                            color = if (p.optBoolean("coche")) couleurs.accent else couleurs.content,
                            fontWeight = if (p.optBoolean("coche")) FontWeight.SemiBold else FontWeight.Normal,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.padding(top = 6.dp),
                        )
                    }
                    }
                }
                repeat(3 - rang.size) { Spacer(Modifier.weight(1f)) }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Droplet Pro : la vitrine et la barre d'achat
// ─────────────────────────────────────────────────────────────

@Composable
internal fun Vitrine(v: JSONObject) {
    val couleurs = LocalGlassColors.current
    Column(
        Modifier.fillMaxWidth().padding(top = 2.dp, bottom = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // L'emblème : l'icône de Droplet Pro sur l'accent, comme une icône d'app.
        val teinte = couleur(v, "teinte", couleurs.accent)
        Box(
            Modifier.size(84.dp).clip(RoundedCornerShape(22.dp)).background(teinte),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                ICONES[v.optString("icone", "auto_awesome")] ?: Icons.Rounded.AutoAwesome,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(46.dp),
            )
        }
        v.texte("titre")?.let {
            Text(it, style = IosTypography.title2, fontWeight = FontWeight.Bold, color = teinte, modifier = Modifier.padding(top = 14.dp))
        }
        v.texte("sous")?.let {
            Text(it, style = IosTypography.subheadline, color = couleurs.secondaryContent, modifier = Modifier.padding(top = 2.dp))
        }
        // Une barre de répartition (Stockage : photos, vidéos, audio…).
        val segments = v.optJSONArray("segments")?.objets().orEmpty()
        if (segments.isNotEmpty()) {
            Row(
                Modifier.padding(top = 16.dp).fillMaxWidth().height(12.dp).clip(RoundedCornerShape(6.dp)),
            ) {
                segments.forEach { g ->
                    Box(
                        Modifier
                            .weight(g.optDouble("part", 0.01).toFloat().coerceAtLeast(0.01f))
                            .fillMaxSize()
                            .background(couleur(g, "teinte", couleurs.accent)),
                    )
                }
            }
        }
        // Une jauge (progression vers le palier suivant).
        if (v.has("progression")) {
            val p = v.optDouble("progression", 0.0).toFloat().coerceIn(0f, 1f)
            Box(
                Modifier
                    .padding(top = 16.dp)
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(50))
                    .background(couleurs.elevatedBackground),
            ) {
                Box(Modifier.fillMaxWidth(p).height(8.dp).clip(RoundedCornerShape(50)).background(teinte))
            }
            v.texte("legende")?.let {
                Text(it, fontSize = 12.sp, color = couleurs.secondaryContent, modifier = Modifier.padding(top = 6.dp))
            }
        }
        v.texte("texte")?.let {
            Text(
                it,
                style = IosTypography.body,
                color = couleurs.secondaryContent,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 16.dp, start = 12.dp, end = 12.dp),
            )
        }
        val puces = v.optJSONArray("puces")?.objets().orEmpty()
        if (puces.isNotEmpty()) {
            Row(
                Modifier.padding(top = 14.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                puces.forEach { p ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        if (p.has("teinte") && !p.has("icone")) {
                            Box(Modifier.size(9.dp).clip(RoundedCornerShape(50)).background(couleur(p, "teinte", couleurs.accent)))
                        } else {
                            Icon(
                                ICONES[p.optString("icone")] ?: Icons.Rounded.Check,
                                contentDescription = null,
                                tint = couleurs.secondaryContent,
                                modifier = Modifier.size(14.dp),
                            )
                        }
                        Spacer(Modifier.width(4.dp))
                        Text(p.optString("texte"), fontSize = 12.sp, color = couleurs.secondaryContent, maxLines = 1)
                    }
                }
            }
        }
    }
}

@Composable
internal fun BarreDuBas(b: JSONObject) {
    val couleurs = LocalGlassColors.current
    Column(
        Modifier
            .fillMaxWidth()
            // Un fond PLEIN : le fond groupé de Glasmio est transparent (il
            // compte sur le verre), et la liste se lisait à travers la barre.
            .background(
                androidx.compose.ui.graphics.Brush.verticalGradient(
                    0f to (if (couleurs.isDark) Color.Black else Color(0xFFF2F2F7)).copy(alpha = 0f),
                    0.12f to (if (couleurs.isDark) Color.Black else Color(0xFFF2F2F7)),
                ),
            )
            .padding(top = 14.dp)
            .navigationBarsPadding()
            .padding(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        GlasmioButton(
            onClick = { PontGlasmio.evenement(b.optString("id")) },
            modifier = Modifier.fillMaxWidth(),
            emphasis = GlassEmphasis.Prominent,
            size = GlasmioButtonSize.Large,
            destructive = b.optBoolean("destructif"),
        ) {
            Text(b.optString("titre"), fontWeight = FontWeight.SemiBold, fontSize = 17.sp)
        }
        b.texte("sous")?.let {
            Text(
                it,
                fontSize = 12.sp,
                color = couleurs.secondaryContent,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp),
            )
        }
        b.optJSONObject("lien")?.let { l ->
            Text(
                l.optString("titre"),
                fontSize = 15.sp,
                color = couleurs.accent,
                modifier = Modifier
                    .padding(top = 6.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .clickable { PontGlasmio.evenement(l.optString("id")) }
                    .padding(horizontal = 10.dp, vertical = 6.dp),
            )
        }
    }
}


// ─────────────────────────────────────────────────────────────
//  La recherche (Aide) : le champ garde sa saisie ; chaque frappe est
//  envoyée à Dart, qui renvoie la liste filtrée.
// ─────────────────────────────────────────────────────────────

@Composable
internal fun Recherche(r: JSONObject) {
    var saisie by androidx.compose.runtime.saveable.rememberSaveable(stateSaver = androidx.compose.ui.text.input.TextFieldValue.Saver) {
        androidx.compose.runtime.mutableStateOf(androidx.compose.ui.text.input.TextFieldValue(r.optString("texte")))
    }
    var active by androidx.compose.runtime.remember { androidx.compose.runtime.mutableStateOf(false) }
    io.github.neoruaa.glasmio.ui.GlasmioSearchBar(
        query = saisie,
        onQueryChange = {
            val change = it.text != saisie.text
            saisie = it
            if (change) PontGlasmio.evenement(r.optString("id"), it.text)
        },
        active = active,
        onActiveChange = { active = it },
        onClose = {
            active = false
            if (saisie.text.isNotEmpty()) {
                saisie = androidx.compose.ui.text.input.TextFieldValue("")
                PontGlasmio.evenement(r.optString("id"), "")
            }
        },
        placeholder = r.optString("indice"),
        closeContentDescription = r.optString("fermer", "Cancel"),
        modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
    )
}
