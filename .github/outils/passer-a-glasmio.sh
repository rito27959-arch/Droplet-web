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
sed -i -E 's#^(    id\("kotlin-android"\))#\1\n    id("org.jetbrains.kotlin.plugin.compose")#' $A
sed -i -E 's/compileSdk = flutter.compileSdkVersion/compileSdk = 37/' $A
cat >> $A <<'G'

android { buildFeatures { compose = true } }
dependencies {
    implementation("io.github.neoruaa.glasmio:glasmio-scaffold:0.1.2")
    implementation("io.github.neoruaa.glasmio:glasmio-preference:0.1.2")
    implementation("androidx.activity:activity-compose:1.13.0")
}
G
M=app/src/main/AndroidManifest.xml
grep -q 'xmlns:tools' $M || sed -i '0,/<manifest /s#<manifest #<manifest xmlns:tools="http://schemas.android.com/tools" #' $M
sed -i '0,/<application/s#<application#<uses-sdk tools:overrideLibrary="io.github.neoruaa.glasmio.core,io.github.neoruaa.glasmio.glass,io.github.neoruaa.glasmio.ui,io.github.neoruaa.glasmio.scaffold,io.github.neoruaa.glasmio.preference,io.github.neoruaa.glasmio.icons,top.yukonga.miuix.kmp.navigation3.ui,top.yukonga.miuix.kmp.ui,top.yukonga.miuix.kmp.core,top.yukonga.miuix.kmp.squircle,top.yukonga.miuix.kmp.shader"/>\n    <application#' $M
echo "--- configuration passée à Glasmio :"
grep -E 'version "|distributionUrl' settings.gradle.kts gradle/wrapper/gradle-wrapper.properties
grep -nE 'compileSdk|plugin.compose|glasmio' $A
grep -c overrideLibrary $M
