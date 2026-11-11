// ============================================================================
// L'ICÔNE DE L'APPLICATION — appliquée QUAND ON QUITTE DROPLET.
// ----------------------------------------------------------------------------
// Changer d'icône = activer un autre `activity-alias` et désactiver l'ancien
// (voir l'en-tête de MainActivity). Désactiver l'alias par lequel l'app a été
// lancée FERME L'APP sur la plupart des lanceurs (Xiaomi/HyperOS compris) :
// c'est ce qui arrivait juste après « Appliquer ».
//
// Désormais, le choix est NOTÉ tout de suite (la coche suit, l'écran reste
// ouvert) et la bascule n'a lieu qu'au moment où l'on quitte Droplet (bouton
// Accueil, applis récentes, retour jusqu'à la sortie). L'app ne se ferme plus
// sous les doigts ; la nouvelle icône est là en revenant à l'accueil — ce que
// le message de confirmation annonce déjà.
// ============================================================================
package com.droplet.droplet

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager

object IconeApp {
    private const val PREFS = "icone_app"
    private const val EN_ATTENTE = "en_attente"
    const val DEFAUT = "Default"

    /** Tous les alias déclarés au manifeste. */
    private fun aliases(): List<String> = listOf(DEFAUT) + (1..13).map { "V$it" }

    /**
     * Les alias sont déclarés « .LauncherX » : relatifs à l'ESPACE DE NOMS
     * (com.droplet.droplet), pas à l'identifiant de l'app — qui peut porter
     * un suffixe (.glasmio). On part donc du paquet de cette classe.
     */
    private fun composant(context: Context, alias: String) =
        ComponentName(context.packageName, "${IconeApp::class.java.`package`!!.name}.Launcher$alias")

    /** Note le choix ; il sera appliqué en quittant l'app. */
    fun choisir(context: Context, alias: String) {
        require(alias in aliases()) { "alias inconnu : $alias" }
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (alias == actif(context)) {
            prefs.edit().remove(EN_ATTENTE).apply()
        } else {
            prefs.edit().putString(EN_ATTENTE, alias).apply()
        }
    }

    /** L'icône choisie : celle en attente s'il y en a une, sinon l'active. */
    fun actuelle(context: Context): String =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(EN_ATTENTE, null) ?: actif(context)

    /** Applique le choix en attente. À n'appeler qu'en quittant l'app. */
    fun appliquerEnAttente(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val cible = prefs.getString(EN_ATTENTE, null) ?: return
        // Effacé AVANT : si le processus est tué pendant la bascule, on ne
        // recommence pas au prochain lancement.
        prefs.edit().remove(EN_ATTENTE).commit()
        runCatching { basculer(context, cible) }
    }

    /** Active [cible] PUIS désactive les autres (l'ordre compte, voir MainActivity). */
    private fun basculer(context: Context, cible: String) {
        val pm = context.packageManager
        pm.setComponentEnabledSetting(
            composant(context, cible),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (alias in aliases()) {
            if (alias == cible) continue
            pm.setComponentEnabledSetting(
                composant(context, alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    /** L'alias réellement actif au lanceur. */
    private fun actif(context: Context): String {
        val pm = context.packageManager
        for (alias in aliases()) {
            val etat = runCatching { pm.getComponentEnabledSetting(composant(context, alias)) }.getOrNull()
            if (etat == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return alias
        }
        return DEFAUT
    }
}
