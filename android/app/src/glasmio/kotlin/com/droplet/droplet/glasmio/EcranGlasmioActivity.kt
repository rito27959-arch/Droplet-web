// ============================================================================
// LES ÉCRANS NATIFS DE DROPLET EN GLASMIO — Jetpack Compose (Android 13+).
// ----------------------------------------------------------------------------
// Une seule activité, qui affiche la description envoyée par Dart et lui
// renvoie chaque geste. Elle sert à plusieurs écrans (Réglages, Droplet Pro,
// Infos du contact) : chacun n'est qu'une description différente, faite
// des mêmes BLOCS (voir BlocsGlasmio.kt).
//
// Composants Glasmio réels (io.github.neoruaa.glasmio, Apache-2.0) :
//   • GlasmioTheme + glasmioColorScheme : couleurs iOS, accent = celui de
//     Droplet ;
//   • GlasmioBackdropHost : la couche que le verre échantillonne ;
//   • GlasmioPinnedListPage : grand titre qui se replie en barre de verre
//     floutée au défilement, bouton retour en verre ;
//   • GlasmioGroupedList / GlasmioListRow / GlasmioSectionTitle /
//     GlasmioGroupedTableFooter, GlasmioSwitch, GlasmioAlertDialog.
//
// Fond : celui de Glasmio, tel quel — noir pur en sombre, gris clair d'iOS
// en clair. ⚠️ Aucune lueur, aucun dégradé.
//
// Polices et symboles d'Apple : NON (licence). Police système d'Android et
// icônes Material Rounded, via le résolveur d'icônes de Glasmio.
// ============================================================================
package com.droplet.droplet.glasmio

import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import io.github.neoruaa.glasmio.core.GlasmioTheme
import io.github.neoruaa.glasmio.core.LocalGlassColors
import io.github.neoruaa.glasmio.core.glasmioColorScheme
import io.github.neoruaa.glasmio.glass.GlasmioBackdropHost
import io.github.neoruaa.glasmio.icons.GlasmioIconProvider
import io.github.neoruaa.glasmio.scaffold.GlasmioPinnedListPage
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonLayout
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonRole
import io.github.neoruaa.glasmio.ui.GlasmioAlertButtonSpec
import io.github.neoruaa.glasmio.ui.GlasmioAlertDialog
import io.github.neoruaa.glasmio.ui.GlasmioGroupedList
import io.github.neoruaa.glasmio.ui.GlasmioGroupedTableFooter
import io.github.neoruaa.glasmio.ui.GlasmioSectionTitle
import org.json.JSONObject
import java.lang.ref.WeakReference

class EcranGlasmioActivity : ComponentActivity() {
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
        // Le retour : l'écran repart vers la droite et laisse voir la page d'en
        // dessous (thème translucide, voir styles_ecran_glasmio.xml).
        if (Build.VERSION.SDK_INT >= 34) {
            overrideActivityTransition(OVERRIDE_TRANSITION_CLOSE, com.droplet.droplet.R.anim.glasmio_immobile, com.droplet.droplet.R.anim.glasmio_sortie)
        }
        val sombre = desc.optBoolean("sombre", true)
        val barres = if (sombre) {
            SystemBarStyle.dark(android.graphics.Color.TRANSPARENT)
        } else {
            SystemBarStyle.light(android.graphics.Color.TRANSPARENT, android.graphics.Color.TRANSPARENT)
        }
        enableEdgeToEdge(statusBarStyle = barres, navigationBarStyle = barres)
        setContent {
            val d = PontGlasmio.description
            if (d != null) EcranGlasmio(d, onRetour = { finish() })
        }
    }

    private var sansAnimation = false

    /** Fermer d'un coup (Dart a posé la photo de cet écran dessous). */
    fun fermerSansAnimation() {
        sansAnimation = true
        if (Build.VERSION.SDK_INT >= 34) overrideActivityTransition(OVERRIDE_TRANSITION_CLOSE, 0, 0)
        finish()
    }

    override fun finish() {
        super.finish()
        if (sansAnimation) {
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)
        } else if (Build.VERSION.SDK_INT < 34) {
            @Suppress("DEPRECATION")
            overridePendingTransition(com.droplet.droplet.R.anim.glasmio_immobile, com.droplet.droplet.R.anim.glasmio_sortie)
        }
    }

    // On quitte Droplet depuis un écran Glasmio : l'icône choisie s'applique
    // maintenant (voir IconeApp.kt).
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        com.droplet.droplet.IconeApp.appliquerEnAttente(applicationContext)
    }

    override fun onDestroy() {
        if (isFinishing && PontGlasmio.ecranOuvert?.get() === this) {
            PontGlasmio.ecranOuvert = null
            PontGlasmio.ferme()
        }
        super.onDestroy()
    }
}

@Composable
private fun EcranGlasmio(d: JSONObject, onRetour: () -> Unit) {
    val sombre = d.optBoolean("sombre", true)
    val accent = couleur(d, "accent", Color(0xFFE8344E))
    GlasmioIconProvider(resolver = RESOLVEUR) {
        GlasmioTheme(isDark = sombre, colorScheme = glasmioColorScheme(sombre, accent)) {
            val fond = LocalGlassColors.current.groupedBackground
            // Un interrupteur suit le doigt tout de suite, sans attendre Dart ;
            // la description suivante (l'état réel) reprend la main.
            val provisoire = remember { mutableStateMapOf<String, Boolean>() }
            LaunchedEffect(d) { provisoire.clear() }
            val bas = d.optJSONObject("bas")

            GlasmioBackdropHost(
                modifier = Modifier.fillMaxSize(),
                sampledContent = { Box(Modifier.fillMaxSize().background(fond)) },
                overlayContent = {
                    // Un sous-niveau du même écran (Stockage → une discussion) :
                    // le retour remonte d'un niveau au lieu de fermer l'écran.
                    val retourId = d.texte("retourId")
                    androidx.activity.compose.BackHandler(enabled = retourId != null) {
                        retourId?.let { PontGlasmio.evenement(it) }
                    }
                    GlasmioPinnedListPage(
                        title = d.optString("titre"),
                        onNavigateBack = { if (retourId != null) PontGlasmio.evenement(retourId) else onRetour() },
                        navigateBackContentDescription = d.texte("retour") ?: "Back",
                        backgroundColor = fond,
                        // La barre d'achat flotte en bas : la liste doit pouvoir
                        // défiler jusqu'au-dessus d'elle.
                        bottomPaddingValues = if (bas != null) PaddingValues(bottom = 150.dp) else null,
                    ) {
                        d.optJSONObject("profil")?.let { p -> item(key = "profil") { CarteProfil(p) } }
                        d.optJSONObject("entete")?.let { e -> item(key = "entete") { EnTeteContact(e) } }
                        d.optJSONObject("vitrine")?.let { v -> item(key = "vitrine") { Vitrine(v) } }
                        d.optJSONArray("stats")?.let { s -> item(key = "stats") { Statistiques(s.objets()) } }
                        d.optJSONObject("recherche")?.let { r -> item(key = "recherche") { Recherche(r) } }
                        d.optJSONArray("sections")?.objets().orEmpty().forEachIndexed { i, s ->
                            item(key = "section-$i") { Section(s, provisoire) }
                        }
                        item(key = "bas-de-liste") { Spacer(Modifier.padding(bottom = 24.dp)) }
                    }
                    if (bas != null) {
                        Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth()) { BarreDuBas(bas) }
                    }
                },
            )

            PontGlasmio.alerte?.let { a -> Alerte(a) }
        }
    }
}

/** Une section : titre, îlot de lignes (ou grille de photos), pied. */
@Composable
private fun Section(s: JSONObject, provisoire: MutableMap<String, Boolean>) {
    Column(Modifier.fillMaxWidth().padding(top = 14.dp)) {
        s.texte("entete")?.let { GlasmioSectionTitle(it) }
        val grille = s.optJSONArray("grille")
        if (grille != null) {
            GrillePhotos(grille.objets())
        } else {
            val lignes = s.optJSONArray("lignes")?.objets().orEmpty()
            if (lignes.isNotEmpty()) {
                GlasmioGroupedList {
                    lignes.forEachIndexed { j, l -> Ligne(l, premiere = j == 0, provisoire = provisoire) }
                }
            }
        }
        s.texte("pied")?.let { GlasmioGroupedTableFooter(it) }
    }
}

/** Confirmer / annuler, ou plusieurs choix (signaler : spam, harcèlement…). */
@Composable
private fun Alerte(a: JSONObject) {
    val choix = a.optJSONArray("choix")?.objets()
    val annuler = GlasmioAlertButtonSpec(a.optString("annuler"), { PontGlasmio.annulerAlerte() }, GlasmioAlertButtonRole.Cancel)
    val boutons = if (choix != null) {
        choix.map { c ->
            GlasmioAlertButtonSpec(
                label = c.optString("titre"),
                onClick = { PontGlasmio.choisirDansAlerte(c.optString("id")) },
                role = if (c.optBoolean("destructif")) GlasmioAlertButtonRole.Destructive else GlasmioAlertButtonRole.Default,
            )
        } + annuler
    } else {
        listOf(
            annuler,
            GlasmioAlertButtonSpec(
                label = a.optString("confirmer"),
                onClick = { PontGlasmio.confirmerAlerte() },
                role = if (a.optBoolean("destructif")) GlasmioAlertButtonRole.Destructive else GlasmioAlertButtonRole.Default,
            ),
        )
    }
    GlasmioAlertDialog(
        onDismissRequest = { PontGlasmio.annulerAlerte() },
        title = a.optString("titre"),
        message = a.texte("message"),
        buttonLayout = if (boutons.size > 2) GlasmioAlertButtonLayout.Stacked else GlasmioAlertButtonLayout.SideBySide,
        buttons = boutons,
    )
}
