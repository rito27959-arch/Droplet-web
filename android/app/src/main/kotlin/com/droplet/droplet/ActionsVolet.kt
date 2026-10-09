package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE CARNET DES ACTIONS FAITES DANS LE VOLET PENDANT QUE DROPLET DORMAIT —
// une réponse, un « lu », une réaction, tapés alors qu'aucun moteur Flutter
// n'était là pour les recevoir.
//
// ── ⚠️ POURQUOI ON NE RÉVEILLE PLUS L'APPLICATION ─────────────────────────
//
// L'ancienne réponse directe, moteur mort, démarrait `MainActivity` avec le
// texte en extra. Deux défauts, chacun suffisant pour perdre le message :
//
//   1. Depuis Android 10, une activité ne peut plus être lancée depuis un
//      `BroadcastReceiver` en arrière-plan. L'appel ne lève rien : il ne
//      se passe RIEN. La réponse disparaissait sans un mot.
//   2. Et quand le lancement passait (Android 9 et avant), personne ne
//      lisait ces extras : aucune ligne de Dart ni de Kotlin ne cherchait
//      `reponse_differee_texte`.
//
// On note donc l'action ici, sur le disque, et Dart vient la chercher à son
// prochain démarrage (`NotifsConversation.brancher`). Rien ne s'allume, rien
// ne se perd.
// ============================================================================

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object ActionsVolet {

    private const val FICHIER = "droplet_actions_volet"
    private const val CLE = "actions"

    /**
     * Note une action. `type` est le nom de la méthode que Dart aurait
     * reçue : `reponseDirecte`, `marquerLu` ou `reagir`.
     */
    @JvmStatic
    @Synchronized
    fun noter(contexte: Context, type: String, valeurs: Map<String, String>) {
        val prefs = contexte.getSharedPreferences(FICHIER, Context.MODE_PRIVATE)
        val liste = try {
            JSONArray(prefs.getString(CLE, "[]"))
        } catch (e: Exception) {
            JSONArray()
        }
        val action = JSONObject().put("type", type)
        for ((cle, valeur) in valeurs) action.put(cle, valeur)
        liste.put(action)
        // `commit`, pas `apply` : le récepteur peut être tué juste après
        // `onReceive`, et `apply` écrit plus tard, en arrière-plan.
        prefs.edit().putString(CLE, liste.toString()).commit()
    }

    /** Rend toutes les actions notées, et vide le carnet. */
    @JvmStatic
    @Synchronized
    fun prendre(contexte: Context): List<Map<String, String>> {
        val prefs = contexte.getSharedPreferences(FICHIER, Context.MODE_PRIVATE)
        val brut = prefs.getString(CLE, null) ?: return emptyList()
        prefs.edit().remove(CLE).commit()
        val resultat = mutableListOf<Map<String, String>>()
        try {
            val liste = JSONArray(brut)
            for (i in 0 until liste.length()) {
                val o = liste.optJSONObject(i) ?: continue
                val m = mutableMapOf<String, String>()
                val cles = o.keys()
                while (cles.hasNext()) {
                    val k = cles.next()
                    m[k] = o.optString(k)
                }
                resultat.add(m)
            }
        } catch (e: Exception) {
            // Carnet illisible : on l'a déjà vidé, on repart propre.
        }
        return resultat
    }
}
