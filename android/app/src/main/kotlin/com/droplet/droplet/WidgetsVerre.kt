// ============================================================================
// LES WIDGETS « VERRE » DE DROPLET — au style de Glasmio.
// ----------------------------------------------------------------------------
// Trois widgets d'écran d'accueil, EN PLUS du widget Droplet existant
// (WidgetDroplet, inchangé) :
//
//   • WidgetVerrePetit (2 × 2)      les non-lus et qui est à portée ;
//   • WidgetVerreRaccourcis (4 × 1) Nouveau message, Réseau, Carte, SOS ;
//   • WidgetVerreMoyen (4 × 2)      les deux à la fois.
//
// LE VERRE. Un widget est dessiné par le lanceur (RemoteViews) : il ne peut
// ni flouter le fond d'écran, ni faire tourner Compose — le vrai verre de
// Glasmio y est impossible. On reproduit donc son ASPECT en couches
// (res/drawable/verre_fond.xml) : corps translucide en dégradé, reflet en
// haut, liseré de lumière, coins du lanceur (Android 12+), boutons ronds de
// verre ; clair ou sombre selon le thème du téléphone.
//
// ⚠️ AUCUN CONTENU DE MESSAGE, jamais (même règle que WidgetDroplet) : un
// widget se lit par-dessus l'épaule. Seulement deux nombres.
//
// Les boutons ouvrent l'app par ses liens profonds (droplet://droplet/…),
// que le routeur Flutter reçoit comme des routes.
// ============================================================================
package com.droplet.droplet

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

object WidgetsVerre {
    private const val PREFS = "widgets_verre"

    /** Appelé par l'app (canal com.droplet.droplet/widgets_verre). */
    fun maj(context: Context, nonLus: Int, pairs: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putInt("nonLus", nonLus.coerceAtLeast(0))
            .putInt("pairs", pairs.coerceAtLeast(0))
            .apply()
        toutRedessiner(context)
    }

    fun toutRedessiner(context: Context) {
        val gestionnaire = AppWidgetManager.getInstance(context)
        for (classe in listOf(WidgetVerrePetit::class.java, WidgetVerreRaccourcis::class.java, WidgetVerreMoyen::class.java)) {
            val ids = gestionnaire.getAppWidgetIds(ComponentName(context, classe))
            if (ids.isNotEmpty()) dessiner(context, gestionnaire, ids, classe)
        }
    }

    internal fun dessiner(context: Context, gestionnaire: AppWidgetManager, ids: IntArray, classe: Class<*>) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val nonLus = prefs.getInt("nonLus", 0)
        val pairs = prefs.getInt("pairs", 0)
        val layout = when (classe) {
            WidgetVerreRaccourcis::class.java -> R.layout.widget_verre_raccourcis
            WidgetVerreMoyen::class.java -> R.layout.widget_verre_moyen
            else -> R.layout.widget_verre_petit
        }
        for (id in ids) {
            val v = RemoteViews(context.packageName, layout)
            if (classe != WidgetVerreRaccourcis::class.java) {
                v.setTextViewText(R.id.verre_nombre, if (nonLus > 99) "99+" else nonLus.toString())
                v.setTextViewText(
                    R.id.verre_libelle,
                    context.getString(
                        when (nonLus) {
                            0 -> R.string.verre_aucun
                            1 -> R.string.verre_un_non_lu
                            else -> R.string.verre_non_lus
                        },
                    ),
                )
                v.setTextViewText(
                    R.id.verre_portee,
                    if (pairs > 0) context.getString(R.string.verre_portee, pairs) else context.getString(R.string.verre_personne),
                )
                v.setImageViewResource(R.id.verre_point, if (pairs > 0) R.drawable.verre_point_vert else R.drawable.verre_point_gris)
                v.setOnClickPendingIntent(R.id.verre_racine, lien(context, "chats", 0))
            }
            if (classe != WidgetVerrePetit::class.java) {
                v.setOnClickPendingIntent(R.id.verre_b_nouveau, lien(context, "new-message", 1))
                v.setOnClickPendingIntent(R.id.verre_b_reseau, lien(context, "mesh-network", 2))
                v.setOnClickPendingIntent(R.id.verre_b_carte, lien(context, "map", 3))
                v.setOnClickPendingIntent(R.id.verre_b_urgence, lien(context, "emergency", 4))
            }
            gestionnaire.updateAppWidget(id, v)
        }
    }

    /** Ouvre Droplet sur une route (lien profond droplet://droplet/<route>). */
    private fun lien(context: Context, route: String, code: Int): PendingIntent {
        val intention = Intent(Intent.ACTION_VIEW, Uri.parse("droplet://droplet/$route"))
            .setPackage(context.packageName)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            context,
            9100 + code,
            intention,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

abstract class WidgetVerreBase : AppWidgetProvider() {
    override fun onUpdate(context: Context, gestionnaire: AppWidgetManager, ids: IntArray) {
        WidgetsVerre.dessiner(context, gestionnaire, ids, this::class.java)
    }
}

class WidgetVerrePetit : WidgetVerreBase()
class WidgetVerreRaccourcis : WidgetVerreBase()
class WidgetVerreMoyen : WidgetVerreBase()
