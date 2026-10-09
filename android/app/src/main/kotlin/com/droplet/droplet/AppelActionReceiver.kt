package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE BOUTON « RACCROCHER » DE LA NOTIFICATION, côté Android.
//
// Il fait deux choses, et l'ordre compte :
//
//   1. Il arrête le service, donc la notification et la pastille de la
//      barre d'état disparaissent TOUT DE SUITE. C'est ce qu'on attend
//      d'un bouton : une réponse immédiate, pas dans deux secondes quand
//      Dart aura fini.
//   2. Il prévient Dart, qui coupe réellement la communication.
//
// ⚠️ LE POINT 1 N'EST PAS UNE OPTIMISATION. Si Dart ne répond pas — moteur
// gelé, application tuée par le système pendant que l'appel tournait — le
// point 2 échoue. Sans le point 1, on aurait alors une notification d'appel
// permanente, non balayable, pour un appel qu'on vient de raccrocher, et
// aucun moyen de s'en débarrasser sans forcer l'arrêt de l'application.
// ============================================================================

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AppelActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_RACCROCHER = "com.droplet.droplet.APPEL_RACCROCHER"
    }

    override fun onReceive(contexte: Context, intent: Intent) {
        if (intent.action != ACTION_RACCROCHER) return

        // 1. L'écran se nettoie immédiatement.
        AppelEnCoursService.arreter(contexte)

        // 2. On demande à Dart de raccrocher pour de vrai.
        //
        // ⚠️ `?.` PARTOUT : le canal n'existe que si le moteur Flutter est
        // vivant. Un `!!` ici planterait le processus au moment précis où
        // quelqu'un essaie de raccrocher.
        AppelNotifPont.canal?.invokeMethod(
            "raccrocher",
            intent.getStringExtra(AppelEnCoursService.EXTRA_PAIR),
        )
    }
}
