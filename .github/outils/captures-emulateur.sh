#!/usr/bin/env bash
# Sur l'émulateur : installe l'APK d'essai, le lance, et prend une capture à
# chaque « CAPTURE:<nom> » écrit par l'app (lib/captures_glasmio.dart).
set +e
C=/tmp/cap; J=$C/journal.txt
P=com.droplet.droplet.glasmio
# -g : toutes les autorisations accordées d'avance (sinon la demande de
# localisation recouvre chaque capture).
# L'émulateur doit avoir fini de démarrer (sinon install et captures échouent
# en silence, avec des images vides).
adb wait-for-device
for k in $(seq 1 90); do [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && break; sleep 2; done
echo "démarré après ${k} essais" >> $J
adb shell input keyevent 82 2>/dev/null
adb shell wm density 440 >> $J 2>&1
adb install -r -g build/app/outputs/flutter-apk/app-release.apk >> $J 2>&1
adb shell pm grant $P android.permission.POST_NOTIFICATIONS 2>/dev/null
adb logcat -c
adb shell am start -n $P/com.droplet.droplet.MainActivity >> $J 2>&1
# Diagnostic : tout le journal dès le lancement, écrit au fil de l'eau (il
# reste même si l'émulateur se fige).
( timeout 240 adb logcat -v time > $C/logcat_complet.txt 2>&1 ) &
# Filet : une image au bout de 45 s, quoi qu'il arrive.
( sleep 45; timeout 20 adb exec-out screencap -p > $C/00-demarrage.png ) &
i=1
timeout 480 adb logcat -v raw -s flutter:I | while read -r l; do
  case "$l" in
    *CAPTURE:*)
      n=$(echo "${l##*CAPTURE:}" | tr -cd 'a-z_')
      sleep 2
      f=$(printf '%02d-%s.png' $i "$n"); i=$((i+1))
      timeout 20 adb exec-out screencap -p > "$C/$f"
      echo "capture $f" >> $J
      if [ "$n" = loupe ]; then
        # La loupe : en bas à droite, au-dessus de la barre système.
        L=$(adb shell wm size | grep -oE '[0-9]+x[0-9]+' | tail -1); W=${L%x*}; H=${L#*x}
        adb shell input tap $((W*91/100)) $((H*93/100)); sleep 1
        adb exec-out screencap -p > "$C/$(printf '%02d' $i)-recherche_transition.png"; i=$((i+1)); sleep 2
        adb exec-out screencap -p > "$C/$(printf '%02d' $i)-recherche.png"; i=$((i+1))
        adb shell input text "Am"; sleep 2
        adb exec-out screencap -p > "$C/$(printf '%02d' $i)-recherche_texte.png"; i=$((i+1))
        adb shell input keyevent 4; sleep 1; adb shell input keyevent 4; sleep 1
      fi
      if [ "$n" = alerte ]; then sleep 1; adb shell input keyevent 4; fi
      if [ "$n" = fin ]; then break; fi
      ;;
  esac
done
# ── DROPLET ID, DE BOUT EN BOUT ─────────────────────────────────────────
# Une vraie connexion au bac à sable sur id-test.dropletmesh.app (le
# « navigateur » est droplet_id_e2e.py) ; l'émulateur fait le téléphone :
# il est ouvert par LE lien d'intention de la page (« Ouvrir dans Droplet »),
# on y tape le nombre, on approuve, et le site reçoit ses jetons.
R=$C/droplet_id.txt; D=/tmp/did
echo "=== DROPLET ID" > $R
python3 .github/outils/droplet_id_e2e.py commencer $D >> $R 2>&1
if [ -f $D/demande.json ]; then
  A=$(python3 -c "import json;print(json.load(open('$D/demande.json'))['android'])")
  CODE=$(python3 -c "import json;print(json.load(open('$D/demande.json'))['code'])")
  echo "lien : $A" >> $R
  adb shell "am start '$A'" >> $R 2>&1
  sleep 14
  timeout 20 adb exec-out screencap -p > $C/90-droplet_id_ouvert.png
  adb shell input text "$CODE"; sleep 2
  timeout 20 adb exec-out screencap -p > $C/91-droplet_id_nombre.png
  adb shell input keyevent 4; sleep 2   # ferme le clavier
  adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1; adb shell cat /sdcard/ui.xml > $C/droplet_id_ui.xml 2>/dev/null
  B=$(python3 - "$C/droplet_id_ui.xml" <<'PY'
import re, sys
x = open(sys.argv[1], encoding='utf-8', errors='replace').read()
for n in re.findall(r'<node [^>]*>', x):
    if re.search(r'(text|content-desc)="Approuver"', n):
        a, b, c, d = map(int, re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', n).groups())
        print((a + c) // 2, (b + d) // 2); break
PY
)
  echo "bouton Approuver : ${B:-introuvable}" >> $R
  [ -n "$B" ] && adb shell input tap $B
  sleep 3
  timeout 20 adb exec-out screencap -p > $C/92-droplet_id_approuvee.png
  sleep 4
  echo "au premier plan après approbation : $(adb shell dumpsys activity activities | grep -m1 -E 'topResumedActivity|mResumedActivity')" >> $R
  timeout 20 adb exec-out screencap -p > $C/93-droplet_id_retour.png
  echo "état vu par le site : $(python3 .github/outils/droplet_id_e2e.py etat $D 2>&1)" >> $R
  python3 .github/outils/droplet_id_e2e.py terminer $D >> $R 2>&1
fi
timeout 30 adb logcat -d | grep -iE "droplet.?id|ErreurDropletId" | tail -40 >> $R

timeout 30 adb logcat -d | grep -iE "glasmio|AndroidRuntime|FATAL|flutter" | tail -150 > $C/logcat.txt
# Les classes créées par réflexion que R8 aurait abîmées (ML Kit, Firebase…),
# et l'exception de la caméra des scanners, s'il y en a une.
timeout 30 adb logcat -d | grep -E "ComponentDiscovery|NoSuchMethodException" | head -40 > $C/reflexion.txt
timeout 30 adb logcat -d | grep -iE -B3 -A45 "Failed to handle method call|getClass\(\)|mobile_scanner|CameraX|Caméra" | tail -400 > $C/camera.txt
true
