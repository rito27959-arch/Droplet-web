import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Doit être appliqué APRÈS `com.android.application`, sans quoi il ne
    // trouve pas la configuration `applicationId` à faire correspondre à
    // `google-services.json`.
    id("com.google.gms.google-services")
}

// ─────────────────────────────────────────────────────────────────────
//  SIGNATURE DE PUBLICATION
// ─────────────────────────────────────────────────────────────────────
//
// ⚠️ POURQUOI CE BLOC EXISTE.
//
// Le modèle de projet Flutter signe la version « release » avec la CLÉ
// DE DÉBOGAGE. C'est pratique pour essayer `flutter run --release` tout
// de suite, et c'est un cul-de-sac pour publier :
//
//   • Google Play refuse tout APK/AAB signé avec la clé de débogage.
//   • Cette clé est celle du SDK Android, identique sur toutes les
//     machines du monde : n'importe qui peut fabriquer une « mise à
//     jour » de Droplet que le téléphone acceptera d'installer par-dessus.
//   • Android identifie une application par sa signature. Publier avec
//     une clé, puis vouloir en changer, oblige les utilisateurs à
//     désinstaller et réinstaller — en perdant TOUTES leurs données
//     locales. Or Droplet n'a pas de serveur : les messages, les
//     contacts et les clés de chiffrement ne vivent QUE sur l'appareil.
//     Une désinstallation, ici, c'est une perte définitive.
//
// La clé n'est PAS dans le dépôt — un secret ne se versionne pas. Les
// chemins et mots de passe sont lus dans `android/key.properties`, un
// fichier local ignoré par git. Pour le créer :
//
//   keytool -genkey -v -keystore ~/droplet-release.jks \
//           -keyalg RSA -keysize 2048 -validity 10000 -alias droplet
//
//   # puis android/key.properties :
//   storeFile=/home/…/droplet-release.jks
//   storePassword=…
//   keyAlias=droplet
//   keyPassword=…
//
// ⚠️ Ce fichier .jks est irremplaçable : le perdre, c'est perdre la
// possibilité de publier la moindre mise à jour de Droplet, pour
// toujours. Il se sauvegarde ailleurs que sur la machine de travail.
//
// En son absence, on retombe sur la signature de débogage : le projet
// reste compilable par quelqu'un qui n'a pas la clé, avec un
// avertissement explicite plutôt qu'un échec silencieux.
val proprietesSignature = Properties()
val fichierSignature = rootProject.file("key.properties")
if (fichierSignature.exists()) {
    fichierSignature.inputStream().use { proprietesSignature.load(it) }
}
val signatureDisponible = proprietesSignature.containsKey("storeFile")

android {
    namespace = "com.droplet.droplet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Requis par flutter_local_notifications (désucrage de la
        // bibliothèque core Java 8+ sur les API Android antérieures).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.droplet.droplet"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── LE MORT-POIDS DE L'ASSISTANT IA ──────────────────────────────
    //
    // `flutter_gemma` n'embarque pas qu'un moteur de génération de
    // texte : il tire toute la suite MediaPipe GenAI Tasks, y compris
    // des bibliothèques natives (.so) dont Droplet n'a AUCUN usage —
    // vérifié en listant le contenu réel de l'APK arm64-v8a, qui est
    // passé de ~75 Mo à ~216 Mo à l'ajout du paquet.
    //
    // Sur ces ~140 Mo de gain, environ 90 Mo sont de la génération
    // d'images façon Stable Diffusion, deux modèles d'embeddings pour
    // la recherche sémantique, un découpeur de texte et une base
    // vectorielle — l'appareillage d'un pipeline RAG multimodal, alors
    // que Droplet n'expose qu'un chat texte simple (voir
    // `ai_assistant_service.dart`). Seuls le moteur d'inférence LLM et
    // le runtime LiteRT-LM (~48 Mo) sont réellement utilisés.
    //
    // ⚠️ CES MODULES SONT DES FICHIERS JNI INDÉPENDANTS, PAS DU CODE
    // ENTRELACÉ avec le moteur de chat — chaque « Task » MediaPipe
    // (LLM Inference, Vision, Image Generator) a sa propre API Java et
    // son propre binaire natif. Le code Dart de Droplet n'appelle QUE
    // l'API LLM Inference : les classes Vision/ImageGenerator/embeddings
    // ne sont jamais atteintes, donc leurs bibliothèques ne devraient
    // jamais être chargées. Si l'assistant se met un jour à planter
    // avec une `UnsatisfiedLinkError` citant l'un des noms ci-dessous,
    // c'est le signe qu'une dépendance cachée existe malgré tout — il
    // suffit de retirer cette entrée précise de la liste.
    packaging {
        jniLibs {
            excludes += setOf(
                "lib/*/libgemma_embedding_model_jni.so",
                "lib/*/libgecko_embedding_model_jni.so",
                "lib/*/libmediapipe_tasks_vision_jni.so",
                "lib/*/libmediapipe_tasks_vision_image_generator_jni.so",
                "lib/*/libimagegenerator_gpu.so",
                "lib/*/libtext_chunker_jni.so",
                "lib/*/libsqlite_vector_store_jni.so",
            )
        }
    }

    signingConfigs {
        if (signatureDisponible) {
            create("release") {
                storeFile = file(proprietesSignature["storeFile"] as String)
                storePassword = proprietesSignature["storePassword"] as String?
                keyAlias = proprietesSignature["keyAlias"] as String?
                keyPassword = proprietesSignature["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (signatureDisponible) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "⚠️  android/key.properties absent : la version release " +
                    "est signée avec la clé de DÉBOGAGE. Cet APK ne peut " +
                    "pas être publié."
                )
                signingConfigs.getByName("debug")
            }

            // R8 : retire le code et les ressources jamais atteints.
            //
            // Ce n'est pas qu'une question de poids. Droplet embarque du
            // code cryptographique et de transport réseau ; réduire la
            // surface réellement présente dans l'APK réduit d'autant ce
            // qu'un attaquant peut examiner. Les règles de conservation
            // sont dans `proguard-rules.pro` — les greffons Flutter qui
            // sont atteints par réflexion depuis le natif doivent y être
            // explicitement épargnés, sinon R8 les supprime et l'app
            // plante au premier appel.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Raccourcis de conversation (bulles, section « Conversations »).
    implementation("androidx.core:core-ktx:1.13.1")
    // Réencodage des vidéos avant envoi (voir `MediaBridge.compresserVideo`).
    implementation("androidx.media3:media3-transformer:1.11.1")
    implementation("androidx.media3:media3-effect:1.11.1")
    implementation("androidx.media3:media3-common:1.11.1")
    // Traduction et reconnaissance de langue HORS LIGNE (ML Kit) : les
    // modèles se téléchargent une fois, puis plus rien ne sort du
    // téléphone. Voir `IntelligenceBridge.kt`.
    implementation("com.google.mlkit:translate:17.0.3")
    implementation("com.google.mlkit:language-id:17.0.6")
}
