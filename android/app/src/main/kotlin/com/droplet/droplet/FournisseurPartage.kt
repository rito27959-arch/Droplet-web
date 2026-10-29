package com.droplet.droplet

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import org.json.JSONArray
import java.io.File
import java.io.FileNotFoundException

/**
 * CE QUE DROPLET DONNE AUX AUTRES APPLICATIONS.
 *
 * Un seul fournisseur de contenu, trois usages :
 *
 *  1. LES PACKS DE STICKERS POUR WHATSAPP — le contrat officiel de WhatsApp
 *     (dépôt « WhatsApp/stickers ») : `metadata`, `metadata/<lot>`,
 *     `stickers/<lot>` et `stickers_asset/<lot>/<fichier>`. WhatsApp lit
 *     ici, avec la permission `com.whatsapp.sticker.READ` que lui seul
 *     détient, après que la personne a touché « Ajouter à WhatsApp ».
 *
 *  2. LES FICHIERS DE STICKERS POUR TOUTES LES AUTRES APPS — `fichier/<lot>/<nom>` :
 *     le WEBM pour l'import Telegram, le WebP animé pour un partage à
 *     n'importe qui. Ces apps n'ont pas la permission de WhatsApp : elles
 *     lisent grâce à l'autorisation temporaire que porte l'intention de
 *     partage (`FLAG_GRANT_READ_URI_PERMISSION`, d'où
 *     `grantUriPermissions="true"` au manifeste).
 *
 *  3. L'APPLICATION ELLE-MÊME — `apk/Droplet.apk` : le paquet installé, pour
 *     l'envoyer par Quick Share, Bluetooth ou n'importe quelle messagerie.
 *     C'est ainsi que Droplet se propage là où il n'y a pas de réseau.
 *
 * Les fichiers de stickers sont dans les ressources Flutter de l'APK
 * (`assets/stickers_export/`). Android ne sait pas ouvrir directement une
 * ressource compressée comme fichier : on la recopie une fois dans le
 * dossier privé de l'app, puis on sert la copie.
 *
 * ⚠️ LE PACK PREMIUM n'est servi que s'il a été débloqué sur ce téléphone
 * (`PartageDroplet.debloquer`, appelé par Dart qui vérifie la licence).
 */
class FournisseurPartage : ContentProvider() {

    companion object {
        /** `${applicationId}.stickercontentprovider` — voir le manifeste. */
        fun autorite(contexte: Context) = "${contexte.packageName}.stickercontentprovider"

        const val DOSSIER = "stickers_export"
        const val PREFS = "partage_droplet"
        const val CLE_LOTS = "lots_debloques"

        private const val METADATA = 1
        private const val METADATA_LOT = 2
        private const val STICKERS = 3
        private const val STICKERS_ASSET = 4
        private const val FICHIER = 5
        private const val APK = 6

        /** Le lot gratuit est toujours servi ; les autres, s'ils sont débloqués. */
        fun lotAutorise(contexte: Context, lot: String): Boolean {
            if (lot == "goutte") return true
            val prefs = contexte.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            return prefs.getStringSet(CLE_LOTS, emptySet())?.contains(lot) == true
        }

        /** Le catalogue exporté (`stickers.json`), lu dans les ressources. */
        fun catalogue(contexte: Context): JSONArray =
            contexte.assets.open("flutter_assets/assets/$DOSSIER/stickers.json").use {
                JSONArray(it.readBytes().toString(Charsets.UTF_8))
            }

        /**
         * Le fichier [nom] du lot [lot], recopié depuis les ressources si
         * besoin. Recopié aussi quand la version de l'app a changé : une
         * mise à jour peut redessiner un sticker sous le même nom.
         */
        fun fichier(contexte: Context, lot: String, nom: String): File {
            require(!lot.contains('/') && !lot.contains("..")) { "lot invalide" }
            require(!nom.contains('/') && !nom.contains("..")) { "nom invalide" }
            val version = try {
                contexte.packageManager.getPackageInfo(contexte.packageName, 0).lastUpdateTime
            } catch (e: Exception) { 0L }
            val dossier = File(contexte.filesDir, "$DOSSIER/$version/$lot").apply { mkdirs() }
            val cible = File(dossier, nom)
            if (!cible.exists() || cible.length() == 0L) {
                // Les copies des versions précédentes ne servent plus.
                File(contexte.filesDir, DOSSIER).listFiles()?.forEach {
                    if (it.name != version.toString()) it.deleteRecursively()
                }
                val provisoire = File(dossier, "$nom.part")
                contexte.assets.open("flutter_assets/assets/$DOSSIER/$lot/$nom").use { entree ->
                    provisoire.outputStream().use { sortie -> entree.copyTo(sortie) }
                }
                provisoire.renameTo(cible)
            }
            return cible
        }
    }

    private lateinit var aiguillage: UriMatcher

    override fun onCreate(): Boolean {
        val auth = autorite(context!!)
        aiguillage = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(auth, "metadata", METADATA)
            addURI(auth, "metadata/*", METADATA_LOT)
            addURI(auth, "stickers/*", STICKERS)
            addURI(auth, "stickers_asset/*/*", STICKERS_ASSET)
            addURI(auth, "fichier/*/*", FICHIER)
            addURI(auth, "apk/*", APK)
        }
        return true
    }

    // ── LE CONTRAT DE WHATSAPP ──────────────────────────────────────────

    private val colonnesLot = arrayOf(
        "sticker_pack_identifier",
        "sticker_pack_name",
        "sticker_pack_publisher",
        "sticker_pack_icon",
        "android_play_store_link",
        "ios_app_download_link",
        "sticker_pack_publisher_email",
        "sticker_pack_publisher_website",
        "sticker_pack_privacy_policy_website",
        "sticker_pack_license_agreement_website",
        "image_data_version",
        "whatsapp_will_not_cache_stickers",
        "animated_sticker_pack",
    )

    private fun nomDuLot(lot: String) = when (lot) {
        "goutte" -> "Droplet · Goutte"
        "eclat" -> "Droplet · Éclat"
        else -> "Droplet"
    }

    private fun lots(): List<String> =
        listOf("goutte", "eclat").filter { lotAutorise(context!!, it) }

    private fun ligneLot(curseur: MatrixCursor, lot: String) {
        val version = try {
            context!!.packageManager.getPackageInfo(context!!.packageName, 0).lastUpdateTime.toString()
        } catch (e: Exception) { "1" }
        curseur.addRow(arrayOf<Any?>(
            lot,
            nomDuLot(lot),
            "Droplet",
            "tray.png",
            "",
            "",
            "",
            "https://dropletmesh.app",
            "",
            "",
            version,
            0,
            1,
        ))
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? {
        return when (aiguillage.match(uri)) {
            METADATA -> MatrixCursor(colonnesLot).also { c -> lots().forEach { ligneLot(c, it) } }
            METADATA_LOT -> {
                val lot = uri.lastPathSegment ?: return null
                MatrixCursor(colonnesLot).also { c -> if (lot in lots()) ligneLot(c, lot) }
            }
            STICKERS -> {
                val lot = uri.lastPathSegment ?: return null
                val c = MatrixCursor(arrayOf("sticker_file_name", "sticker_emoji", "sticker_accessibility_text"))
                if (lot in lots()) {
                    val tous = catalogue(context!!)
                    for (i in 0 until tous.length()) {
                        val s = tous.getJSONObject(i)
                        if (s.getString("lot") != lot) continue
                        val emojis = s.getJSONArray("emojis")
                        val liste = (0 until minOf(3, emojis.length())).joinToString(",") { emojis.getString(it) }
                        c.addRow(arrayOf<Any?>("${s.getString("id")}.webp", liste, s.optString("nom")))
                    }
                }
                c
            }
            STICKERS_ASSET, FICHIER, APK -> infosFichier(uri, projection)
            else -> null
        }
    }

    override fun getType(uri: Uri): String? {
        val auth = autorite(context!!)
        return when (aiguillage.match(uri)) {
            METADATA -> "vnd.android.cursor.dir/vnd.$auth.metadata"
            METADATA_LOT -> "vnd.android.cursor.item/vnd.$auth.metadata"
            STICKERS -> "vnd.android.cursor.dir/vnd.$auth.stickers"
            STICKERS_ASSET -> if (uri.lastPathSegment?.endsWith(".png") == true) "image/png" else "image/webp"
            FICHIER -> when {
                uri.lastPathSegment?.endsWith(".webm") == true -> "video/webm"
                uri.lastPathSegment?.endsWith(".png") == true -> "image/png"
                else -> "image/webp"
            }
            APK -> "application/vnd.android.package-archive"
            else -> null
        }
    }

    // ── LES FICHIERS ────────────────────────────────────────────────────

    /** Le fichier réel derrière une adresse `stickers_asset`, `fichier` ou `apk`. */
    private fun fichierDe(uri: Uri): File {
        val segments = uri.pathSegments
        return when (aiguillage.match(uri)) {
            STICKERS_ASSET, FICHIER -> {
                val lot = segments[1]
                if (!lotAutorise(context!!, lot)) throw FileNotFoundException("lot verrouillé")
                fichier(context!!, lot, segments[2])
            }
            APK -> File(context!!.applicationInfo.sourceDir)
            else -> throw FileNotFoundException(uri.toString())
        }
    }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        if (mode != "r") throw SecurityException("lecture seule")
        val f = fichierDe(uri)
        return AssetFileDescriptor(ParcelFileDescriptor.open(f, ParcelFileDescriptor.MODE_READ_ONLY), 0, f.length())
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        if (mode != "r") throw SecurityException("lecture seule")
        return ParcelFileDescriptor.open(fichierDe(uri), ParcelFileDescriptor.MODE_READ_ONLY)
    }

    /**
     * Le nom et la taille d'un fichier partagé (`OpenableColumns`). Quick
     * Share, WhatsApp, Gmail… les demandent avant de lire : sans réponse,
     * l'APK arrivait sous un nom illisible, ou n'était pas accepté.
     */
    private fun infosFichier(uri: Uri, projection: Array<out String>?): Cursor {
        val f = fichierDe(uri)
        val nom = if (aiguillage.match(uri) == APK) uri.lastPathSegment ?: "Droplet.apk" else f.name
        val colonnes = projection ?: arrayOf(android.provider.OpenableColumns.DISPLAY_NAME, android.provider.OpenableColumns.SIZE)
        val valeurs = colonnes.map {
            when (it) {
                android.provider.OpenableColumns.DISPLAY_NAME -> nom
                android.provider.OpenableColumns.SIZE -> f.length()
                else -> null
            }
        }
        return MatrixCursor(colonnes).apply { addRow(valeurs.toTypedArray()) }
    }

    // Personne n'écrit ici.
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?) = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?) = 0
}
