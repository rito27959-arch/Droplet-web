package com.droplet.droplet

// ============================================================================
// L'INITIALE DU CONTACT, QUAND IL N'A PAS DE PHOTO — jamais le logo.
// ----------------------------------------------------------------------------
// Sans photo, la notification d'un message et le raccourci de conversation
// prenaient l'icône de l'application : on voyait un GROS logo Droplet,
// puis le PETIT logo de la barre d'état, et jamais qui écrivait. WhatsApp
// et Telegram montrent l'initiale sur une couleur ; Droplet aussi,
// désormais — la MÊME couleur que dans l'application (Dart la calcule à
// partir du pseudo et la passe ici).
// ============================================================================

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import androidx.core.graphics.drawable.IconCompat

object AvatarInitiale {
    /** Gris neutre si Dart n'a pas donné de couleur. */
    private const val GRIS = 0xFF8E8E93.toInt()

    /**
     * Une icône « adaptative » pleine : Android la découpe lui-même en rond
     * (ou en goutte, selon le téléphone). La lettre reste dans la zone sûre,
     * le centre, pour ne jamais être rognée.
     */
    @JvmStatic
    fun icone(nom: String, couleur: Int?): IconCompat =
        IconCompat.createWithAdaptiveBitmap(bitmap(nom, couleur))

    @JvmStatic
    fun bitmap(nom: String, couleur: Int?): Bitmap {
        val cote = 216
        val image = Bitmap.createBitmap(cote, cote, Bitmap.Config.ARGB_8888)
        val toile = Canvas(image)
        toile.drawColor(couleur ?: GRIS)
        val lettre = lettre(nom)
        val pinceau = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = 0xFFFFFFFF.toInt()
            textSize = cote * 0.36f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        // Centrée verticalement sur la hauteur réelle des lettres.
        val y = cote / 2f - (pinceau.descent() + pinceau.ascent()) / 2f
        toile.drawText(lettre, cote / 2f, y, pinceau)
        return image
    }

    /** La première lettre (émoji compris : un caractère entier, pas la moitié). */
    @JvmStatic
    fun lettre(nom: String): String {
        val base = nom.trim()
        if (base.isEmpty()) return "?"
        val fin = base.offsetByCodePoints(0, 1)
        return base.substring(0, fin).uppercase()
    }
}
