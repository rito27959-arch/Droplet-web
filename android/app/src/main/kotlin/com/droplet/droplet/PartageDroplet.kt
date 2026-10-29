package com.droplet.droplet

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * DROPLET DANS LES AUTRES APPLICATIONS — le côté Android.
 *
 *  • « Ajouter à WhatsApp » : l'intention officielle de WhatsApp
 *    (`ENABLE_STICKER_PACK`), qui vient lire le pack dans
 *    `FournisseurPartage`. WhatsApp demande lui-même confirmation.
 *  • « Ajouter à Telegram » : l'intention d'import de Telegram
 *    (`org.telegram.messenger.CREATE_STICKER_PACK`, depuis Telegram 7.8),
 *    avec les WEBM VP9 et leurs emojis.
 *  • « Partager un sticker » : le WebP animé, vers n'importe quelle app.
 *  • « Envoyer Droplet » : l'APK installé, par Quick Share, Bluetooth,
 *    WhatsApp… — la personne en face l'installe sans réseau ni boutique.
 *
 * Tous les fichiers sortent par `FournisseurPartage`, avec une
 * autorisation de lecture TEMPORAIRE accordée à l'app qui les reçoit.
 */
object PartageDroplet {
    const val CANAL = "com.droplet.droplet/partage"

    private val WHATSAPP = listOf("com.whatsapp", "com.whatsapp.w4b")
    private val TELEGRAM = listOf("org.telegram.messenger", "org.telegram.messenger.web", "org.thunderdog.challegram")

    fun brancher(activite: Activity, messager: BinaryMessenger) {
        MethodChannel(messager, CANAL).setMethodCallHandler { appel, resultat ->
            try {
                when (appel.method) {
                    "etat" -> resultat.success(etat(activite))
                    "debloquer" -> {
                        val lots = appel.argument<List<String>>("lots") ?: emptyList()
                        activite.getSharedPreferences(FournisseurPartage.PREFS, Context.MODE_PRIVATE)
                            .edit().putStringSet(FournisseurPartage.CLE_LOTS, lots.toSet()).apply()
                        resultat.success(true)
                    }
                    "ajouterWhatsApp" -> resultat.success(
                        ajouterWhatsApp(activite, appel.argument<String>("lot")!!, appel.argument<String>("nom") ?: "Droplet"),
                    )
                    "importerTelegram" -> resultat.success(importerTelegram(activite, appel.argument<String>("lot")!!))
                    "partagerSticker" -> resultat.success(
                        partagerSticker(activite, appel.argument<String>("lot")!!, appel.argument<String>("id")!!, appel.argument<String>("titre") ?: ""),
                    )
                    "partagerApp" -> resultat.success(partagerApp(activite, appel.argument<String>("titre") ?: "", appel.argument<String>("texte") ?: ""))
                    else -> resultat.notImplemented()
                }
            } catch (e: Exception) {
                resultat.error("PARTAGE", e.message, null)
            }
        }
    }

    private fun installe(contexte: Context, paquet: String): Boolean = try {
        contexte.packageManager.getPackageInfo(paquet, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private fun adresse(contexte: Context, chemin: String): Uri =
        Uri.parse("content://${FournisseurPartage.autorite(contexte)}/$chemin")

    /**
     * Le pack est-il déjà dans WhatsApp ? Le fournisseur « liste blanche »
     * de WhatsApp répond 1 ou 0 ; null si WhatsApp est trop ancien.
     */
    private fun dansWhatsApp(contexte: Context, lot: String): Boolean {
        for (p in WHATSAPP) {
            if (!installe(contexte, p)) continue
            val auth = if (p == "com.whatsapp") "com.whatsapp.provider.sticker_whitelist_check" else "com.whatsapp.w4b.provider.sticker_whitelist_check"
            val q = Uri.Builder().scheme("content").authority(auth).appendPath("is_whitelisted")
                .appendQueryParameter("authority", FournisseurPartage.autorite(contexte))
                .appendQueryParameter("identifier", lot).build()
            try {
                contexte.contentResolver.query(q, null, null, null, null)?.use { c ->
                    if (c.moveToFirst() && c.getInt(c.getColumnIndexOrThrow("result")) == 1) return true
                }
            } catch (e: Exception) {
                // WhatsApp trop ancien, ou fournisseur absent : on ne sait pas.
            }
        }
        return false
    }

    private fun etat(contexte: Context): Map<String, Any?> {
        val info = contexte.applicationInfo
        return mapOf(
            "whatsapp" to WHATSAPP.any { installe(contexte, it) },
            "telegram" to TELEGRAM.any { installe(contexte, it) },
            // Installé depuis une boutique en « APK scindés » : le paquet de
            // base seul ne s'installerait pas chez l'autre. Dart propose
            // alors le lien à la place.
            "apkPartageable" to (info.splitSourceDirs == null || info.splitSourceDirs!!.isEmpty()),
            "goutteDansWhatsApp" to dansWhatsApp(contexte, "goutte"),
            "eclatDansWhatsApp" to dansWhatsApp(contexte, "eclat"),
        )
    }

    private fun ajouterWhatsApp(activite: Activity, lot: String, nom: String): Boolean {
        if (!FournisseurPartage.lotAutorise(activite, lot)) return false
        val intention = Intent("com.whatsapp.intent.action.ENABLE_STICKER_PACK")
            .putExtra("sticker_pack_id", lot)
            .putExtra("sticker_pack_authority", FournisseurPartage.autorite(activite))
            .putExtra("sticker_pack_name", nom)
        return try {
            @Suppress("DEPRECATION")
            activite.startActivityForResult(intention, 200)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    private fun importerTelegram(activite: Activity, lot: String): Boolean {
        if (!FournisseurPartage.lotAutorise(activite, lot)) return false
        val tous = FournisseurPartage.catalogue(activite)
        val adresses = ArrayList<Uri>()
        val emojis = ArrayList<String>()
        for (i in 0 until tous.length()) {
            val s = tous.getJSONObject(i)
            if (s.getString("lot") != lot) continue
            // Recopié d'avance : Telegram lit vite, et une copie faite
            // pendant sa lecture le ferait échouer.
            FournisseurPartage.fichier(activite, lot, "${s.getString("id")}.webm")
            adresses.add(adresse(activite, "fichier/$lot/${s.getString("id")}.webm"))
            emojis.add(s.getJSONArray("emojis").getString(0))
        }
        if (adresses.isEmpty()) return false
        val intention = Intent("org.telegram.messenger.CREATE_STICKER_PACK")
            .setType("image/*")
            .putParcelableArrayListExtra(Intent.EXTRA_STREAM, adresses)
            .putStringArrayListExtra("STICKER_EMOJIS", emojis)
            .putExtra("IMPORTER", activite.packageName)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intention.clipData = ClipData.newRawUri(null, adresses[0]).apply {
            adresses.drop(1).forEach { addItem(ClipData.Item(it)) }
        }
        return try {
            activite.startActivity(intention)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    private fun partagerSticker(activite: Activity, lot: String, id: String, titre: String): Boolean {
        if (!FournisseurPartage.lotAutorise(activite, lot)) return false
        FournisseurPartage.fichier(activite, lot, "$id.webp")
        val u = adresse(activite, "fichier/$lot/$id.webp")
        val intention = Intent(Intent.ACTION_SEND)
            .setType("image/webp")
            .putExtra(Intent.EXTRA_STREAM, u)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intention.clipData = ClipData.newRawUri(null, u)
        activite.startActivity(Intent.createChooser(intention, titre))
        return true
    }

    private fun partagerApp(activite: Activity, titre: String, texte: String): Boolean {
        val version = try {
            activite.packageManager.getPackageInfo(activite.packageName, 0).versionName ?: ""
        } catch (e: Exception) { "" }
        val nom = if (version.isEmpty()) "Droplet.apk" else "Droplet-$version.apk"
        val u = adresse(activite, "apk/$nom")
        val intention = Intent(Intent.ACTION_SEND)
            .setType("application/vnd.android.package-archive")
            .putExtra(Intent.EXTRA_STREAM, u)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        if (texte.isNotEmpty()) intention.putExtra(Intent.EXTRA_TEXT, texte)
        intention.clipData = ClipData.newRawUri(null, u)
        activite.startActivity(Intent.createChooser(intention, titre))
        return true
    }
}
