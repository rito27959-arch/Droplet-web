// Bouchons minimaux des classes Flutter, pour COMPILER en CI le code
// Kotlin ajouté (sans construire toute l'app). Aucune logique ici.
package io.flutter.plugin.common

interface BinaryMessenger

class MethodCall(val method: String, val arguments: Any?) {
    fun <T> argument(key: String): T? = null
}

class MethodChannel(messager: BinaryMessenger, nom: String) {
    fun interface MethodCallHandler { fun onMethodCall(call: MethodCall, result: Result) }
    interface Result {
        fun success(r: Any?)
        fun error(code: String, message: String?, details: Any?)
        fun notImplemented()
    }
    fun setMethodCallHandler(h: MethodCallHandler?) {}
    fun invokeMethod(methode: String, arguments: Any?) {}
}
