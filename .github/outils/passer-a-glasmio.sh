#!/usr/bin/env bash
# Passe la configuration Android de Droplet à ce qu'exige Glasmio 0.1.2
# (prouvé par le banc d'essai) et ajoute ses dépendances. Utilisé par la CI ;
# les mêmes changements seront livrés en fichiers pour l'ordinateur.
set -e
cd android
sed -i -E 's/id\("com.android.application"\) version "[^"]+"/id("com.android.application") version "9.4.1"/' settings.gradle.kts
sed -i -E 's/id\("org.jetbrains.kotlin.android"\) version "[^"]+" apply false/id("org.jetbrains.kotlin.android") version "2.4.21" apply false\n    id("org.jetbrains.kotlin.plugin.compose") version "2.4.21" apply false/' settings.gradle.kts
sed -i -E 's#distributionUrl=.*#distributionUrl=https\\://services.gradle.org/distributions/gradle-9.6.0-bin.zip#' gradle/wrapper/gradle-wrapper.properties
grep -q builtInKotlin gradle.properties || printf '\nandroid.builtInKotlin=false\nandroid.newDsl=false\n' >> gradle.properties
A=app/build.gradle.kts
# Kotlin 2.4 refuse l'ancien bloc `kotlinOptions` : même réglage (Java 17),
# écrit avec `kotlin { compilerOptions }` — forme qui marche aussi en 2.2.
python3 - "$A" <<'PY'
import re, sys
p = sys.argv[1]; s = open(p).read()
s = re.sub(r"\n    kotlinOptions \{\n        jvmTarget = JavaVersion\.VERSION_17\.toString\(\)\n    \}\n", "\n", s)
s = s.replace("\nflutter {", "\nkotlin {\n    compilerOptions {\n        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17\n    }\n}\n\nflutter {", 1)
open(p, "w").write(s)
PY
sed -i -E 's#^(    id\("kotlin-android"\))#\1\n    id("org.jetbrains.kotlin.plugin.compose")#' $A
# ⚠️ `compileSdkVersion("android-37")` plutôt que `compileSdk = 37` : avec le
# plugin Android 9, la seconde forme se lit « android-37.0 », et le greffon
# `tor` (via cargokit) découpe cette chaîne pour en faire un entier — « 37.0 »
# le fait échouer. La forme texte garde « android-37 ».
sed -i -E 's/compileSdk = flutter.compileSdkVersion/compileSdk = 37/' $A
# Le greffon `tor` (cargokit) lit compileSdk comme « android-37 » et le
# convertit en entier ; le plugin Android 9 écrit « android-37.0 ». Correctif
# appliqué à la volée, avant l'évaluation de `:tor` (voir build.gradle.kts).
cat >> build.gradle.kts <<'K'

// ── tor / cargokit et le plugin Android 9 ───────────────────────────────
// cargokit fait `compileSdkVersion.substring(8) as int`, ce qui suppose
// « android-37 ». Le plugin Android 9 donne « android-37.0 » : la
// conversion échoue et la compilation s'arrête. On remplace, dans le
// fichier de cargokit du cache de paquets, cette conversion par une
// lecture qui ignore la partie « .0 ». Idempotent : ne fait rien si déjà
// corrigé, et marche aussi avec l'ancien plugin (« android-36 »).
gradle.beforeProject {
    if (name == "tor") {
        val f = projectDir.resolve("../cargokit/gradle/plugin.gradle")
        if (f.exists()) {
            val avant = "compileSdkVersion.substring(8) as int"
            val apres = "compileSdkVersion.substring(8).tokenize('.')[0] as int"
            val texte = f.readText()
            if (texte.contains(avant)) f.writeText(texte.replace(avant, apres))
        }
    }
}
K
cat >> $A <<'G'

// ── Glasmio : les écrans natifs Jetpack Compose (Android 13+) ───────────
// Le code Kotlin qui utilise Glasmio vit dans src/glasmio/kotlin : il n'est
// compilé qu'ici, avec cette configuration.
android {
    buildFeatures { compose = true }
    sourceSets["main"].java.srcDir("src/glasmio/kotlin")
}
dependencies {
    implementation("io.github.neoruaa.glasmio:glasmio-scaffold:0.1.2")
    implementation("io.github.neoruaa.glasmio:glasmio-preference:0.1.2")
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("androidx.compose.material:material-icons-extended:1.7.8")
}
G
M=app/src/main/AndroidManifest.xml
grep -q 'xmlns:tools' $M || sed -i '0,/<manifest /s#<manifest #<manifest xmlns:tools="http://schemas.android.com/tools" #' $M
sed -i '0,/<application/s#<application#<uses-sdk tools:overrideLibrary="io.github.neoruaa.glasmio.core,io.github.neoruaa.glasmio.glass,io.github.neoruaa.glasmio.ui,io.github.neoruaa.glasmio.scaffold,io.github.neoruaa.glasmio.preference,io.github.neoruaa.glasmio.icons,top.yukonga.miuix.kmp.navigation3.ui,top.yukonga.miuix.kmp.ui,top.yukonga.miuix.kmp.core,top.yukonga.miuix.kmp.squircle,top.yukonga.miuix.kmp.shader"/>\n    <application#' $M
# L'activité des réglages Glasmio (même thème que l'app, sans barre).
grep -q ParametresGlasmioActivity $M || sed -i '0,/<\/application>/s#</application>#    <activity android:name="com.droplet.droplet.glasmio.ParametresGlasmioActivity" android:exported="false" android:theme="@android:style/Theme.Material.NoActionBar" android:configChanges="orientation|screenSize|screenLayout|keyboardHidden|smallestScreenSize|uiMode|density" />\n    </application>#' $M
echo "--- configuration passée à Glasmio :"
grep -E 'version "|distributionUrl' settings.gradle.kts gradle/wrapper/gradle-wrapper.properties
grep -nE 'compileSdk|plugin.compose|glasmio' $A
grep -c overrideLibrary $M
grep -n ParametresGlasmioActivity $M
