package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE SERVICE QUI TIENT L'APPEL EN COURS POUR ANDROID — celui qui fait
// apparaître la PASTILLE DANS LA BARRE D'ÉTAT (l'icône de combiné avec le
// minuteur qui court, visible même sur l'écran d'accueil) et la
// notification avec le bouton « Raccrocher » DESSINÉ PAR LE SYSTÈME.
//
// ── POURQUOI DU KOTLIN ALORS QUE TOUT LE RESTE EST EN DART ────────────
//
// Parce que `flutter_local_notifications` n'expose pas `CallStyle`. Sa
// documentation d'`AndroidNotificationDetails` ne le mentionne nulle part.
// Or c'est `CallStyle` — et lui seul — qui donne :
//
//   • la pastille dans la barre d'état, avec le chronomètre ;
//   • le bouton « Raccrocher » dessiné et traduit par Android, qu'on ne
//     peut volontairement pas renommer ;
//   • le rang privilégié en haut du volet des notifications.
//
// Une notification ordinaire avec `usesChronometer` donne la durée, mais
// jamais la pastille. C'est la différence entre ce fichier et ce que faisait
// la version Dart.
//
// ── ⚠️ CE QU'ANDROID EXIGE, ET QUI N'EST PAS NÉGOCIABLE ───────────────
//
// La pastille n'apparaît QUE pour une notification `CallStyle` portée par
// un SERVICE DE PREMIER PLAN de type `phoneCall`. Et ce type-là a ses
// propres conditions, vérifiées par le système au démarrage du service :
//
//   1. `android.permission.FOREGROUND_SERVICE_PHONE_CALL` déclarée ;
//   2. ET l'une de ces deux-ci : `android.permission.MANAGE_OWN_CALLS`
//      déclarée, OU être l'application téléphone par défaut.
//
// Droplet prend la première : `MANAGE_OWN_CALLS` est une permission de
// manifeste, sans fenêtre de demande, et c'est exactement ce pour quoi
// elle existe — une application qui gère ses propres appels.
//
// ⚠️ ET `startForeground()` DOIT ÊTRE APPELÉ DANS LES CINQ SECONDES sur
// Android 14 et plus, sinon le système tue le service. C'est pour ça qu'il
// est appelé en toute première ligne d'`onStartCommand`, avant quoi que ce
// soit d'autre, et que la construction de la notification ne fait aucun
// accès disque ni réseau.
// ============================================================================

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person

class AppelEnCoursService : Service() {

    companion object {
        const val CANAL = "droplet_appel_en_cours"
        const val ID_NOTIF = 4201

        const val ACTION_DEMARRER = "com.droplet.droplet.APPEL_DEMARRER"
        const val ACTION_ARRETER = "com.droplet.droplet.APPEL_ARRETER"

        const val EXTRA_PSEUDO = "pseudo"
        const val EXTRA_PAIR = "pair"
        const val EXTRA_DEBUT = "debut"
        const val EXTRA_VIDEO = "video"
        const val EXTRA_VIA = "via"

        fun demarrer(
            contexte: Context,
            pair: String,
            pseudo: String,
            debutMs: Long,
            video: Boolean,
            via: String,
        ) {
            val i = Intent(contexte, AppelEnCoursService::class.java).apply {
                action = ACTION_DEMARRER
                putExtra(EXTRA_PAIR, pair)
                putExtra(EXTRA_PSEUDO, pseudo)
                putExtra(EXTRA_DEBUT, debutMs)
                putExtra(EXTRA_VIDEO, video)
                putExtra(EXTRA_VIA, via)
            }
            // ⚠️ `startForegroundService` ET PAS `startService`. Depuis
            // Android 8, une application en arrière-plan n'a pas le droit
            // de démarrer un service ordinaire : l'appel lève une
            // exception, et la notification d'appel n'apparaîtrait jamais
            // dans le cas précis où elle sert le plus.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                contexte.startForegroundService(i)
            } else {
                contexte.startService(i)
            }
        }

        fun arreter(contexte: Context) {
            val i = Intent(contexte, AppelEnCoursService::class.java).apply {
                action = ACTION_ARRETER
            }
            // Ici `startService` suffit et ne lève rien : le service tourne
            // déjà en premier plan.
            contexte.startService(i)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_ARRETER) {
            arreterProprement()
            return START_NOT_STICKY
        }

        val pair = intent?.getStringExtra(EXTRA_PAIR) ?: ""
        val pseudo = intent?.getStringExtra(EXTRA_PSEUDO) ?: ""
        val debut = intent?.getLongExtra(EXTRA_DEBUT, 0L) ?: 0L
        val video = intent?.getBooleanExtra(EXTRA_VIDEO, false) ?: false
        val via = intent?.getStringExtra(EXTRA_VIA) ?: ""

        creerCanal()
        val notif = construire(pair, pseudo, debut, video, via)

        // Première chose faite, et sans aucune entrée/sortie avant : la
        // limite est de cinq secondes.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                ID_NOTIF,
                notif,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL,
            )
        } else {
            startForeground(ID_NOTIF, notif)
        }
        // START_NOT_STICKY : si le système nous tue, il ne doit PAS nous
        // relancer. Un service d'appel ressuscité sans appel afficherait
        // une notification d'appel pour un appel qui n'existe plus — et
        // elle n'est pas balayable.
        return START_NOT_STICKY
    }

    private fun arreterProprement() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        NotificationManagerCompat.from(this).cancel(ID_NOTIF)
        stopSelf()
    }

    private fun creerCanal() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(CANAL) != null) return
        val canal = NotificationChannel(
            CANAL,
            // Le nom et la description apparaissent dans les réglages
            // d'Android. Ils sont volontairement en français : le canal est
            // créé une fois, et Android ne le renomme jamais ensuite —
            // c'est sa limite, pas la nôtre.
            "Appel en cours",
            // ⚠️ `IMPORTANCE_LOW` ET PAS `HIGH`. Un appel déjà décroché n'a
            // rien à annoncer : il ne doit ni sonner, ni vibrer, ni
            // surgir en bandeau. L'importance basse donne une notification
            // silencieuse et permanente — exactement ce qu'on veut. La
            // pastille de la barre d'état, elle, ne dépend pas de
            // l'importance mais du type de service.
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "La notification qui reste pendant un appel"
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
        }
        nm.createNotificationChannel(canal)
    }

    private fun construire(
        pair: String,
        pseudo: String,
        debut: Long,
        video: Boolean,
        via: String,
    ): Notification {
        val drapeaux = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

        // Appui sur la notification : on rouvre l'application SUR L'APPEL.
        //
        // ⚠️ LA CLÉ EST `payload`, ET CE N'EST PAS UN DÉTAIL. `MainActivity`
        // lit cet extra dans `siAppelEntrant()` et le range dans
        // `routeLancement`, que Dart vient chercher par la méthode
        // `routeDeLancement` du canal des raccourcis. C'est le chemin déjà
        // en place pour les raccourcis de conversation et pour les
        // notifications d'appel entrant. Avec n'importe quelle autre clé,
        // l'appui rouvrirait l'application sur l'écran où on l'avait
        // laissée, et pas sur l'appel.
        //
        // `ACTION_VIEW` pour la même raison : c'est l'action qu'emploie
        // déjà `publierRaccourci`, et celle que `MainActivity` sait
        // recevoir en `onNewIntent`.
        val ouvrir = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("payload", "/call/$pair")
        }
        val pIOuvrir = PendingIntent.getActivity(this, 1, ouvrir, drapeaux)

        // Raccrocher : une diffusion, pas une activité. Raccrocher ne doit
        // rien ouvrir — c'est précisément ce qui permet de le faire sans
        // quitter ce qu'on était en train de faire.
        val raccrocher = Intent(this, AppelActionReceiver::class.java).apply {
            action = AppelActionReceiver.ACTION_RACCROCHER
            putExtra(EXTRA_PAIR, pair)
        }
        val pIRaccrocher = PendingIntent.getBroadcast(this, 2, raccrocher, drapeaux)

        val personne = Person.Builder()
            .setName(if (pseudo.isNotEmpty()) pseudo else pair)
            .setImportant(true)
            .build()

        val b = NotificationCompat.Builder(this, CANAL)
            .setSmallIcon(R.drawable.ic_stat_droplet)
            .setContentIntent(pIOuvrir)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            // ⚠️ LE CHRONOMÈTRE EST DESSINÉ PAR ANDROID, à partir de cette
            // date. Une durée écrite par l'application se figerait dès que
            // le système gèle le processus — c'est-à-dire au moment précis
            // où cette notification sert à quelque chose.
            .setWhen(debut)
            .setUsesChronometer(true)
            .setShowWhen(true)
            // Ce qui passe par le maillage ou par Internet, en petit.
            .setSubText(via)
            .addPerson(personne)
            .setStyle(
                NotificationCompat.CallStyle
                    .forOngoingCall(personne, pIRaccrocher)
                    .setIsVideo(video)
            )

        return b.build()
    }
}
