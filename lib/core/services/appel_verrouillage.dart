// ============================================================================
// L'APPEL PAR-DESSUS L'ÉCRAN DE VERROUILLAGE.
// ----------------------------------------------------------------------------
// Pendant qu'un écran d'appel est ouvert, l'application a le droit de
// s'afficher sans déverrouiller le téléphone et d'allumer l'écran — comme
// l'appli Téléphone ou WhatsApp. Ce droit est retiré dès que l'écran d'appel
// se ferme : le reste de Droplet ne doit jamais être lisible verrouillé.
// Voir `MainActivity.afficherSurVerrouillage`.
// ============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppelVerrouillage {
  AppelVerrouillage._();

  static const MethodChannel _canal = MethodChannel('com.droplet.droplet/appel');

  /// Vrai tant que l'appel est replié en vignette flottante (PiP).
  static final ValueNotifier<bool> enVignette = ValueNotifier(false);

  static bool _ecoute = false;
  static bool? _vignetteAutorisee;

  static void _ecouter() {
    if (_ecoute) return;
    _ecoute = true;
    _canal.setMethodCallHandler((appel) async {
      if (appel.method == 'vignette') enVignette.value = appel.arguments == true;
      return null;
    });
  }

  /// Autorise (pendant un appel vidéo) ou retire la vignette flottante.
  static Future<void> autoriserVignette(bool actif) async {
    if (kIsWeb || !Platform.isAndroid || _vignetteAutorisee == actif) return;
    _vignetteAutorisee = actif;
    _ecouter();
    if (!actif) enVignette.value = false;
    try {
      await _canal.invokeMethod<bool>('vignetteAutorisee', {'actif': actif});
    } catch (_) {}
  }

  static Future<void> afficher(bool actif) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _canal.invokeMethod<bool>('surVerrouillage', {'actif': actif});
    } catch (_) {}
  }
}
