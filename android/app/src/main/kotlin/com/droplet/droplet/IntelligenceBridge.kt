package com.droplet.droplet

import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.speech.RecognitionListener
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream
import java.nio.ByteBuffer
import java.util.concurrent.Executors
import kotlin.math.roundToInt

/**
 * TRANSCRIPTION ET TRADUCTION — TOUT SE PASSE SUR LE TÉLÉPHONE.
 *
 * Telegram réserve ces deux fonctions à Premium ; Droplet fait de même,
 * mais avec une différence qui compte ici : RIEN NE SORT DE L'APPAREIL.
 *
 *  • la transcription passe par le moteur vocal HORS LIGNE d'Android
 *    (`SpeechRecognizer.createOnDeviceSpeechRecognizer`, Android 13+) ;
 *  • la traduction passe par ML Kit, dont les modèles sont téléchargés une
 *    fois puis utilisés sans réseau.
 *
 * Envoyer un vocal chiffré de bout en bout à un service de reconnaissance
 * en ligne reviendrait à le déchiffrer chez quelqu'un d'autre — c'est
 * exactement ce que Droplet promet de ne jamais faire.
 *
 * ⚠️ « EN LIGNE QUAND JE SUIS CONNECTÉ » NE CHANGE PAS CE PRINCIPE ICI.
 * Sur Android, le réseau sert seulement à TÉLÉCHARGER le modèle vocal d'une
 * langue qui manque (`triggerModelDownload`), une fois : le vocal, lui,
 * reste sur le téléphone. Le reconnaisseur en ligne de Google n'est jamais
 * utilisé pour un fichier — s'il ne sait pas lire `EXTRA_AUDIO_SOURCE`, la
 * documentation d'Android précise qu'il ouvre le MICRO à la place : il
 * transcrirait la pièce au lieu du vocal.
 *
 * ⚠️ CE PONT NE PLANTE JAMAIS L'APPLICATION. Moteur absent, modèle non
 * installé, audio illisible : on répond « indisponible » avec un motif, et
 * l'interface propose autre chose.
 */
class IntelligenceBridge(private val context: Context) {

    companion object {
        const val CHANNEL = "com.droplet.droplet/intelligence"
        private const val TAG = "Intelligence"

        /** Le moteur vocal d'Android attend du PCM 16 bits à 16 kHz, mono. */
        private const val TAUX = 16000
    }

    private val travailleurs = Executors.newSingleThreadExecutor()

    fun handle(methode: String, arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *> ?: emptyMap<String, Any>()
        when (methode) {
            "transcriptionDisponible" -> result.success(transcriptionDisponible())
            "transcrire" -> transcrire(
                args["chemin"] as? String,
                args["langue"] as? String,
                args["enLigne"] as? Boolean ?: false,
                result,
            )
            "detecterLangue" -> detecterLangue(args["texte"] as? String ?: "", result)
            "traduire" -> traduire(
                args["texte"] as? String ?: "",
                args["source"] as? String,
                args["cible"] as? String ?: "fr",
                result,
            )
            else -> result.notImplemented()
        }
    }

    // ── TRANSCRIPTION ────────────────────────────────────────────────

    private fun transcriptionDisponible(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(context)

    private fun transcrire(
        chemin: String?,
        langue: String?,
        enLigne: Boolean,
        result: MethodChannel.Result,
    ) {
        if (chemin.isNullOrEmpty()) {
            result.error("chemin", "aucun fichier", null)
            return
        }
        if (!transcriptionDisponible()) {
            result.success(mapOf("etat" to "indisponible", "motif" to "moteur"))
            return
        }
        // Le moteur vocal vit sur le fil principal : c'est une exigence de
        // `SpeechRecognizer`, pas un choix.
        Handler(Looper.getMainLooper()).post {
            try {
                verifierPuisEcouter(chemin, langue ?: "fr-FR", enLigne, result)
            } catch (e: Throwable) {
                Log.w(TAG, "transcription impossible", e)
                result.success(mapOf("etat" to "echec", "motif" to (e.message ?: "inconnu")))
            }
        }
    }

    /**
     * Avant d'écouter : la langue est-elle installée sur l'appareil ?
     *
     * Sans cette question, un modèle absent finissait en « code 13 » et en
     * échec muet. Ici : installée → on transcrit ; en cours d'installation →
     * on le dit ; téléchargeable → on la télécharge si l'utilisateur a
     * autorisé le réseau (une seule fois, ensuite tout reste hors ligne),
     * sinon on le dit aussi.
     */
    private fun verifierPuisEcouter(
        chemin: String,
        langue: String,
        enLigne: Boolean,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(mapOf("etat" to "indisponible", "motif" to "version"))
            return
        }
        val verificateur = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        val demande = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, langue)
        }
        val prefixe = langue.substringBefore('-').lowercase()
        fun contient(liste: List<String>) =
            liste.any { it.substringBefore('-').lowercase() == prefixe }

        // ⚠️ UNE SEULE RÉPONSE, là aussi.
        var repondu = false
        fun conclure(action: () -> Unit) {
            if (repondu) return
            repondu = true
            action()
        }

        verificateur.checkRecognitionSupport(
            demande,
            context.mainExecutor,
            object : RecognitionSupportCallback {
                override fun onSupportResult(support: RecognitionSupport) = conclure {
                    when {
                        contient(support.installedOnDeviceLanguages) -> {
                            verificateur.destroy()
                            ecouterLeFichier(chemin, langue, result)
                        }
                        contient(support.pendingOnDeviceLanguages) -> {
                            verificateur.destroy()
                            result.success(mapOf("etat" to "modele", "motif" to "en_cours"))
                        }
                        contient(support.supportedOnDeviceLanguages) && enLigne -> {
                            verificateur.triggerModelDownload(demande)
                            // Laisser au service le temps de prendre la demande
                            // avant de couper la liaison.
                            Handler(Looper.getMainLooper()).postDelayed(
                                { verificateur.destroy() },
                                3000,
                            )
                            result.success(mapOf("etat" to "modele", "motif" to "telechargement"))
                        }
                        contient(support.supportedOnDeviceLanguages) -> {
                            verificateur.destroy()
                            result.success(mapOf("etat" to "modele", "motif" to "absent"))
                        }
                        else -> {
                            verificateur.destroy()
                            result.success(mapOf("etat" to "indisponible", "motif" to "langue"))
                        }
                    }
                }

                override fun onError(error: Int) = conclure {
                    // Le service ne sait pas répondre à la question : on tente
                    // la transcription quand même, comme avant.
                    verificateur.destroy()
                    ecouterLeFichier(chemin, langue, result)
                }
            },
        )
    }

    private fun ecouterLeFichier(chemin: String, langue: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(mapOf("etat" to "indisponible", "motif" to "version"))
            return
        }
        val tuyau = ParcelFileDescriptor.createPipe()
        val lecture = tuyau[0]
        val ecriture = tuyau[1]

        val reconnaisseur = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, langue)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE, lecture)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_SAMPLING_RATE, TAUX)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_CHANNEL_COUNT, 1)
        }

        // ⚠️ UNE SEULE RÉPONSE À FLUTTER, quoi qu'il arrive : le moteur
        // peut très bien appeler `onError` APRÈS `onResults`.
        var repondu = false
        fun repondre(valeur: Map<String, Any?>) {
            if (repondu) return
            repondu = true
            try {
                reconnaisseur.destroy()
            } catch (_: Throwable) {
            }
            result.success(valeur)
        }

        reconnaisseur.setRecognitionListener(object : RecognitionListener {
            override fun onResults(results: Bundle?) {
                val mots = results
                    ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    ?.firstOrNull()
                    .orEmpty()
                repondre(
                    if (mots.isBlank()) mapOf("etat" to "vide")
                    else mapOf("etat" to "ok", "texte" to mots),
                )
            }

            override fun onError(error: Int) {
                // Les codes qui ont un sens pour l'utilisateur ne finissent
                // plus en « échec » générique.
                val etat = when (error) {
                    SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE -> "modele"
                    SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED -> "indisponible"
                    SpeechRecognizer.ERROR_NO_MATCH,
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "vide"
                    else -> "echec"
                }
                repondre(mapOf("etat" to etat, "motif" to "code $error"))
            }

            override fun onReadyForSpeech(params: Bundle?) {}
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onPartialResults(partialResults: Bundle?) {}
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
        reconnaisseur.startListening(intent)

        // Le décodage alimente le tuyau depuis un autre fil : le moteur lit
        // à son rythme, et l'interface n'est jamais bloquée.
        travailleurs.execute {
            try {
                ParcelFileDescriptor.AutoCloseOutputStream(ecriture).use { flux ->
                    decoderEnPcm(chemin, flux)
                }
            } catch (e: Throwable) {
                Log.w(TAG, "décodage impossible", e)
                Handler(Looper.getMainLooper()).post {
                    repondre(mapOf("etat" to "echec", "motif" to "audio"))
                }
            }
        }
    }

    /**
     * Décode un fichier audio (AAC/m4a, opus…) en PCM 16 bits mono 16 kHz.
     *
     * Le rééchantillonnage est volontairement simple — reprendre
     * l'échantillon le plus proche. Pour de la parole passée ensuite dans
     * un moteur de reconnaissance, la différence avec un filtre savant
     * n'est pas mesurable, et un filtre savant coûterait dix fois plus.
     */
    private fun decoderEnPcm(chemin: String, sortie: OutputStream) {
        val extracteur = MediaExtractor()
        extracteur.setDataSource(chemin)
        var piste = -1
        var format: MediaFormat? = null
        for (i in 0 until extracteur.trackCount) {
            val f = extracteur.getTrackFormat(i)
            if (f.getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true) {
                piste = i
                format = f
                break
            }
        }
        if (piste < 0 || format == null) throw IllegalStateException("aucune piste audio")
        extracteur.selectTrack(piste)

        val mime = format.getString(MediaFormat.KEY_MIME)!!
        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(format, null, null, 0)
        codec.start()

        val tauxSource = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val canaux = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val info = MediaCodec.BufferInfo()
        var fini = false
        var finEntree = false

        while (!fini) {
            if (!finEntree) {
                val index = codec.dequeueInputBuffer(10_000)
                if (index >= 0) {
                    val tampon = codec.getInputBuffer(index)!!
                    val taille = extracteur.readSampleData(tampon, 0)
                    if (taille < 0) {
                        codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        finEntree = true
                    } else {
                        codec.queueInputBuffer(index, 0, taille, extracteur.sampleTime, 0)
                        extracteur.advance()
                    }
                }
            }
            val index = codec.dequeueOutputBuffer(info, 10_000)
            if (index >= 0) {
                val tampon = codec.getOutputBuffer(index)!!
                ecrirePcm(tampon, info, canaux, tauxSource, sortie)
                codec.releaseOutputBuffer(index, false)
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) fini = true
            } else if (index == MediaCodec.INFO_TRY_AGAIN_LATER && finEntree) {
                // Rien de plus à lire et plus rien à décoder.
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) fini = true
            }
        }
        sortie.flush()
        codec.stop()
        codec.release()
        extracteur.release()
    }

    private fun ecrirePcm(
        tampon: ByteBuffer,
        info: MediaCodec.BufferInfo,
        canaux: Int,
        tauxSource: Int,
        sortie: OutputStream,
    ) {
        if (info.size <= 0) return
        tampon.position(info.offset)
        tampon.limit(info.offset + info.size)
        val echantillons = ShortArray(info.size / 2)
        tampon.asShortBuffer().get(echantillons)

        // Mono : on fait la moyenne des canaux.
        val mono = if (canaux <= 1) echantillons else ShortArray(echantillons.size / canaux) { i ->
            var somme = 0
            for (c in 0 until canaux) somme += echantillons[i * canaux + c]
            (somme / canaux).toShort()
        }

        val sortieTaille = (mono.size.toLong() * TAUX / tauxSource).toInt()
        val octets = ByteArray(sortieTaille * 2)
        for (i in 0 until sortieTaille) {
            val source = (i.toDouble() * tauxSource / TAUX).roundToInt().coerceAtMost(mono.size - 1)
            val valeur = mono[source].toInt()
            octets[i * 2] = (valeur and 0xFF).toByte()
            octets[i * 2 + 1] = ((valeur shr 8) and 0xFF).toByte()
        }
        sortie.write(octets)
    }

    // ── TRADUCTION ───────────────────────────────────────────────────

    private fun detecterLangue(texte: String, result: MethodChannel.Result) {
        if (texte.isBlank()) {
            result.success(null)
            return
        }
        LanguageIdentification.getClient()
            .identifyLanguage(texte)
            .addOnSuccessListener { code -> result.success(if (code == "und") null else code) }
            .addOnFailureListener { result.success(null) }
    }

    private fun traduire(
        texte: String,
        source: String?,
        cible: String,
        result: MethodChannel.Result,
    ) {
        if (texte.isBlank()) {
            result.success(mapOf("etat" to "vide"))
            return
        }
        val codeCible = TranslateLanguage.fromLanguageTag(cible)
        if (codeCible == null) {
            result.success(mapOf("etat" to "indisponible", "motif" to "langue"))
            return
        }

        fun lancer(codeSource: String) {
            if (codeSource == codeCible) {
                result.success(mapOf("etat" to "identique"))
                return
            }
            val traducteur = Translation.getClient(
                TranslatorOptions.Builder()
                    .setSourceLanguage(codeSource)
                    .setTargetLanguage(codeCible)
                    .build(),
            )
            // Le modèle se télécharge UNE FOIS, et seulement en Wi-Fi :
            // ensuite, la traduction n'a plus besoin de réseau du tout.
            traducteur.downloadModelIfNeeded()
                .addOnSuccessListener {
                    traducteur.translate(texte)
                        .addOnSuccessListener { traduit ->
                            result.success(
                                mapOf("etat" to "ok", "texte" to traduit, "source" to codeSource),
                            )
                            traducteur.close()
                        }
                        .addOnFailureListener { e ->
                            result.success(mapOf("etat" to "echec", "motif" to (e.message ?: "")))
                            traducteur.close()
                        }
                }
                .addOnFailureListener { e ->
                    result.success(mapOf("etat" to "modele", "motif" to (e.message ?: "")))
                    traducteur.close()
                }
        }

        val codeSource = source?.let { TranslateLanguage.fromLanguageTag(it) }
        if (codeSource != null) {
            lancer(codeSource)
            return
        }
        LanguageIdentification.getClient()
            .identifyLanguage(texte)
            .addOnSuccessListener { code ->
                val detecte = TranslateLanguage.fromLanguageTag(code ?: "")
                if (detecte == null) {
                    result.success(mapOf("etat" to "indisponible", "motif" to "langue"))
                } else {
                    lancer(detecte)
                }
            }
            .addOnFailureListener {
                result.success(mapOf("etat" to "indisponible", "motif" to "langue"))
            }
    }
}
