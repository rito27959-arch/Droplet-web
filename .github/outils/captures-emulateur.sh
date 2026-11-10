#!/usr/bin/env bash
# Sur l'émulateur : installe l'APK d'essai, le lance, et prend une capture à
# chaque « CAPTURE:<nom> » écrit par l'app (lib/captures_glasmio.dart).
set +e
C=/tmp/cap; J=$C/journal.txt
P=com.droplet.droplet.glasmio
# -g : toutes les autorisations accordées d'avance (sinon la demande de
# localisation recouvre chaque capture).
adb shell wm density 440 >> $J 2>&1
adb install -r -g build/app/outputs/flutter-apk/app-release.apk >> $J 2>&1
adb shell pm grant $P android.permission.POST_NOTIFICATIONS 2>/dev/null
adb logcat -c
adb shell am start -n $P/com.droplet.droplet.MainActivity >> $J 2>&1
# Filet : une image au bout de 45 s, quoi qu'il arrive.
( sleep 45; adb exec-out screencap -p > $C/00-demarrage.png ) &
i=1
timeout 480 adb logcat -v raw -s flutter:I | while read -r l; do
  case "$l" in
    *CAPTURE:*)
      n=$(echo "${l##*CAPTURE:}" | tr -cd 'a-z_')
      sleep 2
      f=$(printf '%02d-%s.png' $i "$n"); i=$((i+1))
      adb exec-out screencap -p > "$C/$f"
      echo "capture $f" >> $J
      if [ "$n" = alerte ]; then sleep 1; adb shell input keyevent 4; fi
      if [ "$n" = fin ]; then break; fi
      ;;
  esac
done
adb logcat -d | grep -iE "glasmio|AndroidRuntime|FATAL|flutter" | tail -150 > $C/logcat.txt
true
