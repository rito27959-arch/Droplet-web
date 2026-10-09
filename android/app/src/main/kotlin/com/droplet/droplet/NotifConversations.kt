package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES NOTIFICATIONS DE CONVERSATION D'ANDROID — celles qui donnent à Droplet
// sa propre section « Conversations » dans les réglages du téléphone, une
// ligne de réglages PAR DISCUSSION avec son avatar, les bulles flottantes,
// la pastille sur l'icône, et la réponse directe depuis le volet.
//
// ── POURQUOI CE N'EST PAS DU FLUTTER ──────────────────────────────────
//
// `flutter_local_notifications` sait poser une notification. Il ne sait pas
// poser une notification de CONVERSATION : il n'expose ni `shortcutId`, ni
// `LocusId`, ni `BubbleMetadata`, ni les canaux à identifiant de
// conversation. Or c'est exactement l'ensemble de ces quatre choses
// qu'Android exige pour classer une notification parmi les conversations.
// Trois sur quatre ne suffisent pas : elle retombe dans « Autres ».
//
// ── LES QUATRE PIÈCES, ET CE QUE CHACUNE APPORTE ──────────────────────
//
//   1. UN RACCOURCI DE LONGUE VIE par discussion. Déjà publié par
//      `MainActivity.publierRaccourci` — avec `setLongLived(true)` et la
//      catégorie `android.shortcut.conversation`. C'est lui qui porte
//      l'avatar et le nom.
//   2. UN CANAL PAR DISCUSSION, rangé dans un groupe « Conversations ».
//      C'est ce qui fait apparaître la liste des captures : une ligne par
//      personne, réglable séparément. Sans lui, tout Droplet partage un
//      seul réglage.
//   3. LA NOTIFICATION qui cite le raccourci (`setShortcutId`) ET le même
//      identifiant en `LocusId`. Le premier relie à la personne, le second
//      dit au système « cette conversation est celle-ci » — c'est ce qui
//      permet au téléphone de proposer la bonne discussion ailleurs.
//   4. LES MÉTADONNÉES DE BULLE, qui pointent vers une activité dédiée.
//
// ── ⚠️ LES BULLES NE S'AFFICHENT PAS PARCE QU'ON LES DEMANDE ──────────
//
// L'utilisateur décide, dans Réglages → Notifications → Bulles. Tant qu'il
// est sur « Pas de bulles », ce code est correct et il ne se passe
// strictement rien. `ouvrirReglagesBulles()` est là pour l'y emmener d'un
// toucher plutôt que de lui faire chercher — mais il faut qu'on le lui
// propose au bon moment, pas à l'installation.
//
// ── ⚠️ UNE NOTIFICATION DE CONVERSATION NE PEUT PAS ÊTRE SILENCIEUSE ──
//
// Android exige l'importance HAUTE pour qu'une conversation puisse
// « buller ». Un canal créé en importance basse ne remontera jamais, et
// l'utilisateur ne pourra PAS le corriger : l'importance d'un canal est
// figée à sa création. C'est l'erreur qu'on ne peut pas rattraper sans
// changer l'identifiant du canal — c'est-à-dire sans effacer les réglages
// que la personne avait faits.
// ============================================================================

import android.app.Notification
import android.app.PendingIntent
import android.content.ContentResolver
import android.media.AudioAttributes
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import androidx.core.content.LocusIdCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object NotifConversations {

    private const val CANAL_PONT = "com.droplet.droplet/notif_conversations"

    /** Le groupe qui porte le titre « Conversations » dans les réglages. */
    const val GROUPE = "droplet_conversations"

    /**
     * Le canal « parent » dont héritent les canaux de conversation.
     *
     * ⚠️ IL DOIT EXISTER MÊME S'IL N'EST JAMAIS UTILISÉ POUR NOTIFIER.
     * `setConversationId` déclare une filiation : sans parent déclaré,
     * Android ignore la conversation et range le canal dans « Autres ».
     */
    const val CANAL_PARENT = "droplet_messages"

    /** La clé du texte saisi dans la réponse directe. */
    const val CLE_REPONSE = "droplet_reponse_directe"

    /**
     * Le groupe de notifications — celui qui les empile sous un résumé
     * « 3 discussions » au lieu de les aligner une à une.
     *
     * ⚠️ RIEN À VOIR AVEC [GROUPE]. Celui-là range des CANAUX dans les
     * réglages ; celui-ci empile des NOTIFICATIONS dans le volet. Android
     * appelle les deux « groupe ».
     */
    const val PILE = "droplet_pile_messages"
    private const val TAG_RESUME = "droplet_resume"

    /** Le libellé du résumé, gardé pour les mises à jour sans Dart. */
    private var libelleResume = "{n}"

    /** Le canal Flutter, gardé pour que la réponse directe remonte à Dart. */
    @JvmStatic
    var canal: MethodChannel? = null
        private set

    // ── LE PONT ───────────────────────────────────────────────────────

    @JvmStatic
    fun brancher(contexte: Context, moteur: FlutterEngine) {
        val app = contexte.applicationContext
        preparerCanaux(app)
        val c = MethodChannel(moteur.dartExecutor.binaryMessenger, CANAL_PONT)
        c.setMethodCallHandler { appel, resultat ->
            when (appel.method) {
                "notifier" -> {
                    val ok = notifier(
                        contexte = app,
                        idConversation = appel.argument<String>("id") ?: "",
                        nom = appel.argument<String>("nom") ?: "",
                        messages = appel.argument<List<Map<String, Any?>>>("messages")
                            ?: emptyList(),
                        photo = appel.argument<String>("photo"),
                        route = appel.argument<String>("route") ?: "",
                        groupe = appel.argument<Boolean>("groupe") ?: false,
                        bulleAutorisee = appel.argument<Boolean>("bulle") ?: true,
                        silencieux = appel.argument<Boolean>("silencieux") ?: false,
                        dernierMessage = appel.argument<String>("dernierMessage"),
                        textes = appel.argument<Map<String, String>>("textes")
                            ?: emptyMap(),
                    )
                    resultat.success(ok)
                }
                "effacer" -> {
                    val id = appel.argument<String>("id") ?: ""
                    NotificationManagerCompat.from(app).cancel(id, 1)
                    majResume(app, null)
                    resultat.success(true)
                }
                "actionsDifferees" -> resultat.success(ActionsVolet.prendre(app))
                "oublier" -> {
                    // La discussion est supprimée : son canal doit partir
                    // avec elle, sinon la liste des réglages se remplit de
                    // noms de gens avec qui l'on ne parle plus.
                    val id = appel.argument<String>("id") ?: ""
                    supprimerCanal(app, id)
                    resultat.success(true)
                }
                "bullesAutorisees" -> resultat.success(bullesAutorisees(app))
                "ouvrirReglagesBulles" -> {
                    ouvrirReglagesBulles(app)
                    resultat.success(true)
                }
                "ouvrirReglagesConversation" -> {
                    ouvrirReglagesConversation(app, appel.argument<String>("id") ?: "")
                    resultat.success(true)
                }
                else -> resultat.notImplemented()
            }
        }
        canal = c
    }

    @JvmStatic
    fun debrancher() {
        canal?.setMethodCallHandler(null)
        canal = null
    }

    // ── LES CANAUX ────────────────────────────────────────────────────

    private fun preparerCanaux(contexte: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val gestionnaire = contexte.getSystemService(android.app.NotificationManager::class.java)
            ?: return

        gestionnaire.createNotificationChannelGroup(
            android.app.NotificationChannelGroup(GROUPE, "Conversations"),
        )

        if (gestionnaire.getNotificationChannel(CANAL_PARENT) == null) {
            val parent = android.app.NotificationChannel(
                CANAL_PARENT,
                "Messages",
                android.app.NotificationManager.IMPORTANCE_HIGH,
            )
            parent.group = GROUPE
            parent.setShowBadge(true)
            gestionnaire.createNotificationChannel(parent)
        }
    }

    /**
     * Le canal d'une conversation, créé à la première notification.
     *
     * ⚠️ PAS À L'AVANCE, POUR TOUS LES CONTACTS. Créer trois cents canaux
     * au démarrage remplirait les réglages du téléphone d'une liste
     * illisible où ne figurerait presque personne avec qui l'on parle
     * vraiment. Android lui-même ne les crée qu'à l'usage, et c'est ce que
     * montrent les captures : la liste ne contient que les discussions
     * actives.
     */
    private fun canalPour(
        contexte: Context,
        idConversation: String,
        nom: String,
    ): String {
        val idCanal = "conv_$idConversation"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return idCanal
        val gestionnaire = contexte.getSystemService(android.app.NotificationManager::class.java)
            ?: return idCanal

        val existant = gestionnaire.getNotificationChannel(idCanal)
        if (existant != null) {
            // ⚠️ ON NE RECRÉE PAS, ON NE MET À JOUR QUE LE NOM. Recréer un
            // canal existant est sans effet sur son importance et sa
            // sonnerie — Android protège délibérément les réglages de
            // l'utilisateur — mais le NOM, lui, suit. C'est ce qui fait
            // qu'une personne qui change de pseudo ne reste pas affichée
            // sous l'ancien dans les réglages du téléphone.
            if (existant.name != nom) {
                existant.name = nom
                gestionnaire.createNotificationChannel(existant)
            }
            return idCanal
        }

        val canal = android.app.NotificationChannel(
            idCanal,
            nom,
            // HAUTE, obligatoirement : voir l'en-tête du fichier.
            android.app.NotificationManager.IMPORTANCE_HIGH,
        )
        canal.group = GROUPE
        canal.setShowBadge(true)
        // La tonalité de Droplet, la même que le canal des messages
        // (`res/raw/droplet_message`). Sans elle, chaque conversation
        // sonnait avec le son système — l'application avait deux voix.
        // ⚠️ RÉGLÉE À LA CRÉATION SEULEMENT : ensuite, le son d'un canal
        // appartient à l'utilisateur.
        val son = contexte.resources.getIdentifier("droplet_message", "raw", contexte.packageName)
        if (son != 0) {
            canal.setSound(
                Uri.parse(
                    ContentResolver.SCHEME_ANDROID_RESOURCE + "://" +
                        contexte.packageName + "/" + son,
                ),
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_COMMUNICATION_INSTANT)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            canal.setConversationId(CANAL_PARENT, idConversation)
        }
        gestionnaire.createNotificationChannel(canal)
        return idCanal
    }

    private fun supprimerCanal(contexte: Context, idConversation: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        contexte.getSystemService(android.app.NotificationManager::class.java)
            ?.deleteNotificationChannel("conv_$idConversation")
    }

    // ── LA NOTIFICATION ───────────────────────────────────────────────

    /**
     * @param messages le FIL, du plus ancien au plus récent. Chaque entrée
     *   porte `texte`, `quand` (millisecondes) et `auteur` (nul = le nom de
     *   la conversation).
     *
     * ⚠️ TOUT LE FIL, PAS LE DERNIER MESSAGE. La notification est publiée
     * sous le même identifiant à chaque fois : elle REMPLACE la
     * précédente. N'envoyer que le dernier message ferait donc disparaître
     * les précédents à chaque arrivée, et `MessagingStyle` — dont c'est
     * toute la raison d'être — n'afficherait jamais qu'une ligne.
     */
    private fun notifier(
        contexte: Context,
        idConversation: String,
        nom: String,
        messages: List<Map<String, Any?>>,
        photo: String?,
        route: String,
        groupe: Boolean,
        bulleAutorisee: Boolean,
        silencieux: Boolean,
        dernierMessage: String?,
        textes: Map<String, String>,
    ): Boolean {
        if (idConversation.isEmpty() || messages.isEmpty()) return false
        textes["resume"]?.let { libelleResume = it }
        return try {
            val icone = photo?.let { chemin ->
                BitmapFactory.decodeFile(chemin)?.let { IconCompat.createWithAdaptiveBitmap(it) }
            } ?: IconCompat.createWithResource(contexte, R.mipmap.ic_launcher)

            val moi = Person.Builder()
                .setName(textes["moi"] ?: "Droplet")
                .setKey("moi")
                .build()

            val style = NotificationCompat.MessagingStyle(moi)
                .setGroupConversation(groupe)
            if (groupe) style.setConversationTitle(nom)

            // Les photos déjà décodées dans ce passage : un groupe de sept
            // lignes du même auteur ne décode pas sept fois le même fichier.
            val visages = mutableMapOf<String, IconCompat?>()

            // ⚠️ LA PERSONNE EST CELLE QUI PARLE, PAS LA CONVERSATION. Dans
            // un groupe, c'est l'auteur de CHAQUE ligne : c'est son nom et
            // son avatar qu'Android affiche à côté d'elle, comme dans une
            // vraie messagerie. Mettre le nom du groupe partout donnerait
            // six lignes signées du même nom — et le visage du GROUPE à
            // côté de chacune, ce que faisait la version précédente.
            var quiParle: Person? = null
            var dernierTexte = ""
            for (m in messages) {
                // ⚠️ PAS D'INTERPOLATION ICI. Une première version écrivait
                // un dollar échappé devant l'accolade, ce qui en Kotlin
                // produit un dollar LITTÉRAL suivi de texte brut : chaque
                // notification aurait affiché la formule au lieu du message.
                val texte = (m["texte"] as? String).orEmpty()
                if (texte.isEmpty()) continue
                val quand = (m["quand"] as? Number)?.toLong() ?: System.currentTimeMillis()
                dernierTexte = texte
                if (m["moi"] == true) {
                    // Sa propre réponse : la personne nulle, c'est
                    // « l'utilisateur » pour Android, dessiné à part.
                    style.addMessage(
                        NotificationCompat.MessagingStyle.Message(texte, quand, null as Person?),
                    )
                    continue
                }
                val auteur = m["auteur"] as? String
                val cheminAuteur = m["photo"] as? String
                val visage = when {
                    !groupe -> icone
                    cheminAuteur != null -> visages.getOrPut(cheminAuteur) {
                        BitmapFactory.decodeFile(cheminAuteur)
                            ?.let { IconCompat.createWithAdaptiveBitmap(it) }
                    }
                    // Sans photo, pas d'icône : Android dessine alors
                    // l'initiale de l'auteur, sur sa propre couleur — bien
                    // mieux que le visage du groupe répété.
                    else -> null
                }
                val personne = Person.Builder()
                    .setName(auteur ?: nom)
                    .setKey(auteur ?: idConversation)
                    .apply { if (visage != null) setIcon(visage) }
                    .build()
                style.addMessage(texte, quand, personne)
                quiParle = personne
            }
            if (quiParle == null && dernierTexte.isEmpty()) return false
            val quand = (messages.last()["quand"] as? Number)?.toLong()
                ?: System.currentTimeMillis()

            val idCanal = canalPour(contexte, idConversation, nom)
            val code = idConversation.hashCode()

            val ouvrir = PendingIntent.getActivity(
                contexte,
                code,
                Intent(contexte, MainActivity::class.java)
                    .setAction(Intent.ACTION_VIEW)
                    .putExtra("payload", route),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            val constructeur = NotificationCompat.Builder(contexte, idCanal)
                .setSmallIcon(petiteIcone(contexte))
                .setColor(0xFF0A84FF.toInt())
                .setStyle(style)
                // Titre et texte « à plat » : lus par le résumé de la pile
                // et par les montres connectées, qui ignorent le style.
                .setContentTitle(nom)
                .setContentText(dernierTexte)
                .setContentIntent(ouvrir)
                .setAutoCancel(true)
                .setShowWhen(true)
                .setWhen(quand)
                .setGroup(PILE)
                .setNumber(messages.count { it["moi"] != true })
                // ⚠️ SILENCIEUSE : ni son, ni bandeau, ni vibration — mais
                // bien rangée dans le volet. C'est la livraison discrète,
                // et c'est aussi ce qu'on veut quand Droplet est ouvert :
                // la bannière intégrée a déjà prévenu.
                .setSilent(silencieux)
                .setOnlyAlertOnce(silencieux)
                // Les quatre lignes qui font d'elle une CONVERSATION :
                .setShortcutId(idConversation)
                .setLocusId(LocusIdCompat(idConversation))
                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            quiParle?.let { constructeur.addPerson(it) }

            // ── 1. Répondre ──────────────────────────────────────────
            //
            // ⚠️ ELLE N'EST PAS UN BONUS. Une notification de conversation
            // sans champ de réponse se fait reléguer par certains lanceurs,
            // et surtout : répondre sans ouvrir l'application est la raison
            // pour laquelle ce système existe.
            val libelleRepondre = textes["repondre"] ?: "Reply"
            val saisie = RemoteInput.Builder(CLE_REPONSE)
                .setLabel(libelleRepondre)
                .build()
            constructeur.addAction(
                NotificationCompat.Action.Builder(
                    R.mipmap.ic_launcher,
                    libelleRepondre,
                    versRecepteur(contexte, ReponseDirecteReceiver.ACTION, code, idConversation, route, mutable = true),
                )
                    .addRemoteInput(saisie)
                    .setAllowGeneratedReplies(true)
                    .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_REPLY)
                    .setShowsUserInterface(false)
                    .build(),
            )

            // ── 2. Marquer comme lu ──────────────────────────────────
            //
            // L'action « sémantique » LU : c'est elle que les montres et
            // Android Auto savent proposer, sans savoir lire notre libellé.
            constructeur.addAction(
                NotificationCompat.Action.Builder(
                    R.mipmap.ic_launcher,
                    textes["lu"] ?: "Mark as read",
                    versRecepteur(contexte, ReponseDirecteReceiver.ACTION_LU, code + 1, idConversation, route),
                )
                    .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_MARK_AS_READ)
                    .setShowsUserInterface(false)
                    .build(),
            )

            // ── 3. Réagir d'un cœur ──────────────────────────────────
            //
            // Seulement si l'on sait À QUOI réagir : le dernier message.
            // Un cœur posé « sur la conversation » ne voudrait rien dire.
            if (!dernierMessage.isNullOrEmpty()) {
                val emoji = textes["reagir"] ?: "❤️"
                val intention = Intent(contexte, ReponseDirecteReceiver::class.java)
                    .setAction(ReponseDirecteReceiver.ACTION_REAGIR)
                    .putExtra("id", idConversation)
                    .putExtra("message", dernierMessage)
                    .putExtra("emoji", emoji)
                constructeur.addAction(
                    NotificationCompat.Action.Builder(
                        R.mipmap.ic_launcher,
                        emoji,
                        PendingIntent.getBroadcast(
                            contexte,
                            code + 2,
                            intention,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                        ),
                    )
                        .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_THUMBS_UP)
                        .setShowsUserInterface(false)
                        .build(),
                )
            }

            // ── La bulle ─────────────────────────────────────────────
            if (bulleAutorisee && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val versBulle = PendingIntent.getActivity(
                    contexte,
                    code,
                    Intent(contexte, BulleActivity::class.java)
                        .setAction(Intent.ACTION_VIEW)
                        .setData(Uri.parse("droplet://conversation/$idConversation"))
                        .putExtra("payload", route),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
                )
                constructeur.setBubbleMetadata(
                    NotificationCompat.BubbleMetadata.Builder(versBulle, icone)
                        // 600 points : assez pour une dizaine de messages et
                        // la barre de saisie. Plus bas, on ne voit que le
                        // dernier message et la bulle ne sert à rien ; plus
                        // haut, elle recouvre l'application sous laquelle on
                        // est censé rester.
                        .setDesiredHeight(600)
                        // ⚠️ PAS `setAutoExpandBubble(true)`. Une bulle qui
                        // s'ouvre d'elle-même interrompt exactement ce que
                        // la bulle était censée ne pas interrompre.
                        .setSuppressNotification(false)
                        .build(),
                )
            }

            // L'identifiant de notification est la conversation : un second
            // message de la même personne REMPLACE le premier au lieu de
            // s'empiler. C'est ce qu'on veut — et `MessagingStyle` sait
            // afficher plusieurs lignes dans une seule notification.
            NotificationManagerCompat.from(contexte)
                .notify(idConversation, 1, constructeur.build())
            majResume(contexte, null)
            true
        } catch (e: SecurityException) {
            // POST_NOTIFICATIONS refusée : ce n'est pas une panne, c'est un
            // choix. On ne réessaie pas, on ne prévient pas.
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun versRecepteur(
        contexte: Context,
        action: String,
        code: Int,
        idConversation: String,
        route: String,
        mutable: Boolean = false,
    ): PendingIntent = PendingIntent.getBroadcast(
        contexte,
        code,
        Intent(contexte, ReponseDirecteReceiver::class.java)
            .setAction(action)
            .putExtra("id", idConversation)
            .putExtra("route", route),
        // ⚠️ MUTABLE POUR LA RÉPONSE, ET POUR ELLE SEULE. Android doit
        // pouvoir y glisser le texte tapé ; une intention immuable le
        // perdrait. Les autres n'ont rien à recevoir : immuables, comme
        // l'exige la règle de sécurité d'Android 12.
        PendingIntent.FLAG_UPDATE_CURRENT or
            (if (mutable) PendingIntent.FLAG_MUTABLE else PendingIntent.FLAG_IMMUTABLE),
    )

    /**
     * La goutte blanche de la barre d'état.
     *
     * ⚠️ PAS L'ICÔNE DE L'APPLICATION. Android ne garde d'une petite icône
     * que sa silhouette : le logo en couleurs devenait un carré blanc plein
     * dans la barre d'état. `ic_stat_droplet` est la silhouette dessinée
     * pour ça (celle que `NotificationService` utilise déjà) ; on ne
     * retombe sur l'icône de l'application que si elle manque.
     */
    private fun petiteIcone(contexte: Context): Int {
        val id = contexte.resources.getIdentifier("ic_stat_droplet", "drawable", contexte.packageName)
        return if (id != 0) id else R.mipmap.ic_launcher
    }

    // ── LA PILE ───────────────────────────────────────────────────────

    /**
     * Le résumé qui coiffe la pile : « 3 discussions », et une ligne par
     * conversation.
     *
     * ⚠️ RECALCULÉ DEPUIS LE VOLET, PAS DEPUIS UNE MÉMOIRE À NOUS. Une
     * notification balayée du doigt ne nous prévient pas ; seule la liste
     * des notifications ACTIVES dit vrai. Au-dessous de deux discussions,
     * pas de résumé — une pile d'une seule carte n'est pas une pile.
     */
    @JvmStatic
    fun majResume(contexte: Context, libelle: String?) {
        if (libelle != null) libelleResume = libelle
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val gestionnaire =
            contexte.getSystemService(android.app.NotificationManager::class.java) ?: return
        val nm = NotificationManagerCompat.from(contexte)
        try {
            val actives = gestionnaire.activeNotifications.filter {
                it.id == 1 && it.tag != TAG_RESUME && it.notification.group == PILE
            }
            if (actives.size < 2) {
                nm.cancel(TAG_RESUME, 0)
                return
            }
            val titre = libelleResume.replace("{n}", actives.size.toString())
            val boite = NotificationCompat.InboxStyle().setSummaryText(titre)
            for (sbn in actives.sortedByDescending { it.postTime }.take(6)) {
                val extras = sbn.notification.extras
                val nom = extras.getCharSequence(Notification.EXTRA_TITLE) ?: continue
                val texte = extras.getCharSequence(Notification.EXTRA_TEXT) ?: ""
                boite.addLine("$nom · $texte")
            }
            val resume = NotificationCompat.Builder(contexte, CANAL_PARENT)
                .setSmallIcon(petiteIcone(contexte))
                .setColor(0xFF0A84FF.toInt())
                .setContentTitle(titre)
                .setStyle(boite)
                .setGroup(PILE)
                .setGroupSummary(true)
                // Le résumé ne sonne jamais : ce sont les conversations qui
                // préviennent, chacune avec ses propres réglages.
                .setGroupAlertBehavior(NotificationCompat.GROUP_ALERT_CHILDREN)
                .setSilent(true)
                .setAutoCancel(true)
                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                .build()
            nm.notify(TAG_RESUME, 0, resume)
        } catch (e: SecurityException) {
        } catch (e: Exception) {
        }
    }

    // ── LES RÉGLAGES DU TÉLÉPHONE ─────────────────────────────────────

    /**
     * L'utilisateur a-t-il autorisé les bulles pour Droplet ?
     *
     * ⚠️ ANDROID NE LE DIT PAS DIRECTEMENT. Il n'existe aucune API publique
     * pour lire ce réglage. Le mieux qu'on puisse faire est de vérifier que
     * les notifications sont autorisées : si elles ne le sont pas, les
     * bulles ne le sont certainement pas non plus. Au-delà, on ne sait pas
     * — et il vaut mieux l'admettre que de prétendre le contraire.
     */
    private fun bullesAutorisees(contexte: Context): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            NotificationManagerCompat.from(contexte).areNotificationsEnabled()

    private fun ouvrirReglagesBulles(contexte: Context) {
        val intention = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, contexte.packageName)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            contexte.startActivity(intention)
        } catch (e: Exception) {
            // Constructeur sans écran de réglages de notification : rare,
            // mais ça existe. On ne fait rien plutôt que de planter.
        }
    }

    /** Emmène droit à la ligne de CETTE conversation, comme la capture 2. */
    private fun ouvrirReglagesConversation(contexte: Context, idConversation: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            ouvrirReglagesBulles(contexte)
            return
        }
        val intention = Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, contexte.packageName)
            .putExtra(Settings.EXTRA_CHANNEL_ID, "conv_$idConversation")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            contexte.startActivity(intention)
        } catch (e: Exception) {
            ouvrirReglagesBulles(contexte)
        }
    }

    /**
     * Retire les raccourcis des conversations qu'on ne voit plus.
     *
     * Android plafonne les raccourcis de longue vie (souvent 5 à 15 selon
     * le constructeur) et REFUSE silencieusement les suivants. Sans ménage,
     * les nouvelles conversations cessent un jour d'avoir des bulles, sans
     * la moindre erreur pour l'expliquer.
     */
    @JvmStatic
    fun elaguerRaccourcis(contexte: Context, aGarder: List<String>) {
        try {
            val existants = ShortcutManagerCompat.getDynamicShortcuts(contexte)
            val aRetirer = existants.map { it.id }.filter { it !in aGarder }
            if (aRetirer.isNotEmpty()) {
                ShortcutManagerCompat.removeLongLivedShortcuts(contexte, aRetirer)
            }
        } catch (e: Exception) {
            // Rien de critique : au pire, un raccourci périmé survit.
        }
    }
}
