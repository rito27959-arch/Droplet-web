#!/usr/bin/env bash
# Fichiers Android présents sur l'ordinateur mais ABSENTS DU DÉPÔT : on pose
# des bouche-trous minimaux, SEULEMENT pour que la compilation sur GitHub aille
# au bout et vérifie le reste (dont Glasmio). Rien de tout ceci n'est livré :
# sur l'ordinateur, les vrais fichiers sont là. Chaque bouche-trou est signalé.
set -e
R=android/app/src/main/res
K=android/app/src/main/kotlin/com/droplet/droplet
signale() { echo "⚠️ absent du dépôt (bouche-trou Android) : $1"; }

if ! grep -rqs 'name="NormalTheme"' $R/values*/; then
  cat > $R/values/styles_bouche_trou.xml <<'X'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar"/>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar"/>
</resources>
X
  signale "styles LaunchTheme / NormalTheme"
fi
if ! ls $R/drawable*/ic_stat_droplet.* >/dev/null 2>&1; then
  cat > $R/drawable/ic_stat_droplet.xml <<'X'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp" android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#FFFFFFFF" android:pathData="M12,2C8,8 6,11 6,14a6,6 0 0,0 12,0c0,-3 -2,-6 -6,-12z"/>
</vector>
X
  signale "drawable/ic_stat_droplet"
fi
if ! ls $R/xml/widget_droplet_info.xml >/dev/null 2>&1; then
  cat > $R/xml/widget_droplet_info.xml <<'X'
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android" android:minWidth="40dp" android:minHeight="40dp"/>
X
  signale "xml/widget_droplet_info"
fi
if ! grep -rqs "class ContactDropBridge" $K; then
  cat > $K/ContactDropBridge_BoucheTrou.kt <<'X'
package com.droplet.droplet
import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
class ContactDropBridge(activite: Activity, messager: BinaryMessenger) {
    fun onPause() {}
    fun dispose() {}
}
X
  signale "ContactDropBridge.kt"
fi
if ! grep -rqs "class MediaBridge" $K; then
  cat > $K/MediaBridge_BoucheTrou.kt <<'X'
package com.droplet.droplet
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
class MediaBridge(contexte: Context) {
    var canal: MethodChannel? = null
    fun handle(call: MethodCall, result: MethodChannel.Result) = result.notImplemented()
}
X
  signale "MediaBridge.kt"
fi
if ! grep -rqs "class WidgetDroplet" $K; then
  cat > $K/WidgetDroplet_BoucheTrou.kt <<'X'
package com.droplet.droplet
class WidgetDroplet : android.appwidget.AppWidgetProvider()
X
  signale "WidgetDroplet.kt"
fi
# Le serveur GitHub manque de mémoire pour fusionner le dex de Droplet avec 2 Go.
sed -i -E 's/-Xmx2g/-Xmx6g/' android/gradle.properties
