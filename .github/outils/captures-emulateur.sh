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
# reste même si l'émulateur se fige), et l'état du processeur à 15, 30, 60 s.
( timeout 240 adb logcat -v time > $C/logcat_complet.txt 2>&1 ) &
( for t in 15 15 30; do sleep $t; echo "== $(date +%T)" >> $C/top.txt; timeout 15 adb shell top -b -n 1 -m 12 >> $C/top.txt 2>&1; done ) &
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
timeout 30 adb logcat -d | grep -iE "glasmio|AndroidRuntime|FATAL|flutter" | tail -150 > $C/logcat.txt
true
