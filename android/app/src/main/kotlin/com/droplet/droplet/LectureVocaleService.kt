package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA NOTIFICATION D'UN MESSAGE VOCAL QU'ON ÉCOUTE HORS DE L'APP.
//
// On lance un vocal, on verrouille le téléphone ou on passe à une autre
// app : la lecture continue, et Android montre le lecteur — dans le volet,
// sur l'écran de verrouillage, et (Android 13+) dans les réglages rapides,
// avec le nom de la personne, la barre d'avancement qu'on peut faire
// glisser, lecture/pause, « suivant » quand d'autres vocaux attendent.
// C'est ce que font WhatsApp et Telegram.
//
// ── Pourquoi en Kotlin ────────────────────────────────────────────────
//
// Ce lecteur-là, Android le dessine LUI-MÊME à partir d'une `MediaSession`
// (le titre, la durée, la position, la vitesse) et d'une notification de
// style « média ». Aucun paquet Flutter déjà présent dans Droplet ne
// produit les deux ensemble ; ajouter `audio_service` aurait obligé à
// changer l'activité principale de l'app. Ce fichier n'utilise que les
// classes d'Android lui-même (aucune dépendance de plus).
//
// Le son, lui, reste joué côté Dart (`LecteurVocal`) : ce service ne fait
// qu'afficher l'état qu'on lui envoie et renvoyer les boutons pressés.
// Il tient aussi l'app en vie (service de premier plan « lecture média »)
// tant que la lecture dure, pour qu'Android ne coupe pas le son.
// ============================================================================

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class LectureVocaleService : Service() {

    companion object {
        const val CANAL_NOTIF = "droplet_lecture_vocale"
        const val ID_NOTIF = 4307

        const val ACTION_MAJ = "com.droplet.droplet.LECTURE_MAJ"
        const val ACTION_ARRETER = "com.droplet.droplet.LECTURE_ARRETER"
        const val ACTION_BOUTON = "com.droplet.droplet.LECTURE_BOUTON"

        /// Le dernier état reçu de Dart, lu par le service à chaque mise à jour.
        @Volatile var etat: Etat? = null

        fun majDepuisDart(contexte: Context, e: Etat) {
            etat = e
            val i = Intent(contexte, LectureVocaleService::class.java).apply { action = ACTION_MAJ }
            // Un service de premier plan ne peut être LANCÉ depuis
            // l'arrière-plan que s'il devient aussitôt de premier plan :
            // on ne le lance donc ainsi que pendant une lecture.
            if (e.enLecture && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                contexte.startForegroundService(i)
            } else {
                contexte.startService(i)
            }
        }

        fun arreter(contexte: Context) {
            etat = null
            val i = Intent(contexte, LectureVocaleService::class.java).apply { action = ACTION_ARRETER }
            try { contexte.startService(i) } catch (_: Exception) {}
        }
    }

    data class Etat(
        val titre: String,
        val sousTitre: String,
        val enLecture: Boolean,
        val positionMs: Long,
        val dureeMs: Long,
        val vitesse: Float,
        val route: String,
        val image: String?,
        val suivant: Boolean,
    )

    private var session: MediaSession? = null
    private var imageChargee: String? = null
    private var bitmap: Bitmap? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        val s = MediaSession(this, "DropletVocal")
        s.setCallback(object : MediaSession.Callback() {
            override fun onPlay() = LectureNotifPont.envoyer("lecture")
            override fun onPause() = LectureNotifPont.envoyer("pause")
            override fun onSkipToNext() = LectureNotifPont.envoyer("suivant")
            override fun onStop() = LectureNotifPont.envoyer("arreter")
            override fun onSeekTo(pos: Long) = LectureNotifPont.envoyer("aller", pos)
        })
        s.isActive = true
        session = s
    }

    override fun onDestroy() {
        session?.release()
        session = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_ARRETER -> {
                finir()
                return START_NOT_STICKY
            }
            ACTION_BOUTON -> {
                // Les boutons de la notification passent par ici sur les
                // Android qui n'utilisent pas encore la session (< 13).
                when (intent.getStringExtra("bouton")) {
                    "lecture" -> LectureNotifPont.envoyer("lecture")
                    "pause" -> LectureNotifPont.envoyer("pause")
                    "suivant" -> LectureNotifPont.envoyer("suivant")
                    "arreter" -> LectureNotifPont.envoyer("arreter")
                }
                return START_NOT_STICKY
            }
        }
        val e = etat
        if (e == null) {
            finir()
            return START_NOT_STICKY
        }
        afficher(e)
        return START_NOT_STICKY
    }

    private fun afficher(e: Etat) {
        creerCanal()
        val s = session ?: return

        if (e.image != imageChargee) {
            imageChargee = e.image
            bitmap = e.image?.let { chemin ->
                try {
                    val o = BitmapFactory.Options().apply { inSampleSize = 2 }
                    BitmapFactory.decodeFile(chemin, o)
                } catch (_: Exception) { null }
            }
        }

        val meta = MediaMetadata.Builder()
            .putString(MediaMetadata.METADATA_KEY_TITLE, e.titre)
            .putString(MediaMetadata.METADATA_KEY_ARTIST, e.sousTitre)
            .putLong(MediaMetadata.METADATA_KEY_DURATION, e.dureeMs)
        bitmap?.let { meta.putBitmap(MediaMetadata.METADATA_KEY_ART, it) }
        s.setMetadata(meta.build())

        var actions = PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_PLAY_PAUSE or PlaybackState.ACTION_SEEK_TO or PlaybackState.ACTION_STOP
        if (e.suivant) actions = actions or PlaybackState.ACTION_SKIP_TO_NEXT
        s.setPlaybackState(
            PlaybackState.Builder()
                .setActions(actions)
                .setState(
                    if (e.enLecture) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
                    e.positionMs,
                    if (e.enLecture) e.vitesse else 0f,
                )
                .build()
        )

        val notif = construire(e, s)
        if (e.enLecture) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(ID_NOTIF, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
            } else {
                startForeground(ID_NOTIF, notif)
            }
        } else {
            // En pause : la notification reste, mais on peut la balayer,
            // et l'app n'est plus tenue éveillée pour rien.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_DETACH)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(false)
            }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).notify(ID_NOTIF, notif)
        }
    }

    private fun bouton(nom: String, code: Int): PendingIntent {
        val i = Intent(this, LectureVocaleService::class.java).apply {
            action = ACTION_BOUTON
            putExtra("bouton", nom)
        }
        return PendingIntent.getService(this, code, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    @Suppress("DEPRECATION")
    private fun construire(e: Etat, s: MediaSession): Notification {
        val ouvrir = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("payload", e.route)
        }
        val pIOuvrir = PendingIntent.getActivity(
            this, 7, ouvrir, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val b = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CANAL_NOTIF)
        } else {
            Notification.Builder(this)
        }
        b.setSmallIcon(R.drawable.ic_stat_droplet)
            .setContentTitle(e.titre)
            .setContentText(e.sousTitre)
            .setContentIntent(pIOuvrir)
            .setDeleteIntent(bouton("arreter", 11))
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setOngoing(e.enLecture)
        bitmap?.let { b.setLargeIcon(it) }

        b.addAction(
            Notification.Action.Builder(
                if (e.enLecture) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
                if (e.enLecture) "Pause" else "Lecture",
                bouton(if (e.enLecture) "pause" else "lecture", 12),
            ).build()
        )
        val compact = mutableListOf(0)
        if (e.suivant) {
            b.addAction(
                Notification.Action.Builder(android.R.drawable.ic_media_next, "Suivant", bouton("suivant", 13)).build()
            )
            compact.add(1)
        }
        b.setStyle(
            Notification.MediaStyle()
                .setMediaSession(s.sessionToken)
                .setShowActionsInCompactView(*compact.toIntArray())
        )
        return b.build()
    }

    private fun creerCanal() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(CANAL_NOTIF) != null) return
        nm.createNotificationChannel(
            NotificationChannel(CANAL_NOTIF, "Lecture des messages vocaux", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Le lecteur affiché quand on écoute un message vocal hors de l'app"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }
        )
    }

    private fun finir() {
        session?.isActive = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(ID_NOTIF)
        stopSelf()
    }
}

/// Le canal entre Dart (`NotifLecture`) et le service ci-dessus.
object LectureNotifPont {
    private const val CANAL = "com.droplet.droplet/lecture_vocale"
    private var canal: MethodChannel? = null
    private val principal = Handler(Looper.getMainLooper())

    fun brancher(contexte: Context, moteur: FlutterEngine) {
        val app = contexte.applicationContext
        val c = MethodChannel(moteur.dartExecutor.binaryMessenger, CANAL)
        c.setMethodCallHandler { appel, resultat ->
            when (appel.method) {
                "maj" -> {
                    try {
                        LectureVocaleService.majDepuisDart(
                            app,
                            LectureVocaleService.Etat(
                                titre = appel.argument<String>("titre") ?: "",
                                sousTitre = appel.argument<String>("sousTitre") ?: "",
                                enLecture = appel.argument<Boolean>("enLecture") ?: false,
                                positionMs = (appel.argument<Any>("position") as? Number)?.toLong() ?: 0L,
                                dureeMs = (appel.argument<Any>("duree") as? Number)?.toLong() ?: 0L,
                                vitesse = (appel.argument<Any>("vitesse") as? Number)?.toFloat() ?: 1f,
                                route = appel.argument<String>("route") ?: "/chats",
                                image = appel.argument<String>("image"),
                                suivant = appel.argument<Boolean>("suivant") ?: false,
                            ),
                        )
                        resultat.success(true)
                    } catch (e: Exception) {
                        // Lancer un service de premier plan depuis
                        // l'arrière-plan peut être refusé (Android 12+) :
                        // la lecture continue, sans notification.
                        resultat.success(false)
                    }
                }
                "arreter" -> {
                    LectureVocaleService.arreter(app)
                    resultat.success(true)
                }
                else -> resultat.notImplemented()
            }
        }
        canal = c
    }

    fun envoyer(action: String, position: Long? = null) {
        principal.post {
            canal?.invokeMethod("action", mapOf("nom" to action, "position" to position))
        }
    }

    fun debrancher() {
        canal?.setMethodCallHandler(null)
        canal = null
    }
}
