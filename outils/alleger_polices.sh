#!/usr/bin/env bash
# Allège les polices de Droplet Web (fontTools : pip install fonttools).
#
# ⚠️ POURQUOI. Les polices complètes pesaient 1,8 Mo, téléchargées avant le
# premier écran. On ne garde que les alphabets latin, grec et cyrillique
# (l'arabe, le hindi et le chinois s'affichent avec la police du système,
# Inter ne les dessine pas), et pour Inter les seules graisses 400 à 700,
# sans l'axe de taille optique. Résultat : 1,8 Mo → 0,98 Mo.
#
# À lancer sur les polices D'ORIGINE (celles de l'app mobile), jamais sur
# des polices déjà allégées.
set -euo pipefail
U="U+0000-024F,U+0259,U+02B0-02FF,U+0300-036F,U+0370-03FF,U+0400-04FF,U+1E00-1EFF,U+2000-206F,U+2070-209F,U+20A0-20CF,U+2100-214F,U+2190-21FF,U+2200-22FF,U+25A0-25FF,U+2600-26FF,U+FB00-FB06,U+FEFF,U+FFFD"
source="${1:?dossier des polices d'origine}"
dest="assets/fonts"
for f in Inter-Variable InterTight_600SemiBold InterTight_700Bold InterTight_800ExtraBold; do
  pyftsubset "$source/$f.ttf" --unicodes="$U" --layout-features='*' --output-file="/tmp/$f.ttf"
done
fonttools varLib.instancer /tmp/Inter-Variable.ttf wght=400:700 opsz=drop -o "$dest/Inter-Variable.ttf"
for f in InterTight_600SemiBold InterTight_700Bold InterTight_800ExtraBold; do cp "/tmp/$f.ttf" "$dest/$f.ttf"; done
ls -la "$dest"
