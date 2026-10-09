package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CE QU'ON FAIT DANS LE VOLET SANS OUVRIR DROPLET — répondre, marquer comme
// lu, réagir d'un cœur.
//
// ── ⚠️ DEUX CAS, ET IL FAUT LES DEUX ─────────────────────────────────────
//
// Un `BroadcastReceiver` est réveillé par Android même quand l'application
// est MORTE. Il n'y a alors aucun moteur Flutter à qui transmettre quoi que
// ce soit.
//
//   • MOTEUR VIVANT — on transmet directement à Dart. Le message part, et
//     Dart republie la notification avec la réponse sous le message
//     d'origine (`NotificationService.apresReponse`).
//   • MOTEUR MORT — on note l'action (`ActionsVolet`) et Dart la reprendra
//     à son prochain démarrage. Voir l'en-tête d'`ActionsVolet` pour
//     pourquoi on ne relance plus l'application.
//
// ── ⚠️ LE CERCLE D'ATTENTE DE LA RÉPONSE DIRECTE ─────────────────────────
//
// Après une réponse, Android pose un petit cercle qui tourne sur la
// notification, jusqu'à ce que l'application la mette à jour. Moteur
// vivant, Dart s'en charge. Moteur mort, personne ne le ferait : on retire
// donc la notification ici, sans quoi le cercle tournerait pour toujours.
// ============================================================================

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.RemoteInput

class ReponseDirecteReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION = "com.droplet.droplet.REPONSE_DIRECTE"
        const val ACTION_LU = "com.droplet.droplet.MARQUER_LU"
        const val ACTION_REAGIR = "com.droplet.droplet.REAGIR"
    }

    override fun onReceive(contexte: Context, intention: Intent) {
        val id = intention.getStringExtra("id").orEmpty()
        if (id.isEmpty()) return

        when (intention.action) {
            ACTION -> repondre(contexte, intention, id)
            ACTION_LU -> {
                retirer(contexte, id)
                transmettre(contexte, "marquerLu", mapOf("id" to id))
            }
            ACTION_REAGIR -> {
                val message = intention.getStringExtra("message").orEmpty()
                val emoji = intention.getStringExtra("emoji").orEmpty()
                if (message.isEmpty() || emoji.isEmpty()) return
                // Réagir, c'est avoir vu : la notification a fait son
                // travail, elle s'en va.
                retirer(contexte, id)
                transmettre(
                    contexte,
                    "reagir",
                    mapOf("id" to id, "message" to message, "emoji" to emoji),
                )
            }
        }
    }

    private fun repondre(contexte: Context, intention: Intent, id: String) {
        val texte = RemoteInput.getResultsFromIntent(intention)
            ?.getCharSequence(NotifConversations.CLE_REPONSE)
            ?.toString()
            ?.trim()
            .orEmpty()

        // Un envoi à vide : l'utilisateur a touché le bouton sans écrire.
        // On ne fait rien, et surtout on ne referme pas la notification —
        // il allait peut-être écrire.
        if (texte.isEmpty()) return

        val vivant = transmettre(
            contexte,
            "reponseDirecte",
            mapOf("id" to id, "texte" to texte),
        )
        if (!vivant) retirer(contexte, id)
    }

    /**
     * Passe l'action à Dart si son moteur tourne ; sinon la note.
     * @return vrai si Dart l'a reçue tout de suite.
     */
    private fun transmettre(
        contexte: Context,
        methode: String,
        valeurs: Map<String, String>,
    ): Boolean {
        val canal = NotifConversations.canal
        if (canal != null) {
            canal.invokeMethod(methode, valeurs)
            return true
        }
        ActionsVolet.noter(contexte, methode, valeurs)
        return false
    }

    private fun retirer(contexte: Context, id: String) {
        NotificationManagerCompat.from(contexte).cancel(id, 1)
        NotifConversations.majResume(contexte, null)
    }
}
