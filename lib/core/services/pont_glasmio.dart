// ============================================================================
// LE PONT VERS GLASMIO — les écrans Android natifs (Jetpack Compose).
// ----------------------------------------------------------------------------
// Glasmio (github.com/NEORUAA/Glasmio, Apache-2.0) recrée le « Liquid Glass »
// d'iOS en Jetpack Compose. Son verre ne peut flouter et réfracter que du
// contenu dessiné en Compose : il ne voit pas les pixels de Flutter. Il sert
// donc à des ÉCRANS ENTIERS natifs, ouverts par-dessus Droplet, pas à des
// boutons posés sur un écran Flutter.
//
// Le partage des rôles est strict :
//   • DART décrit l'écran (sections, lignes, valeurs, textes traduits) et
//     reste seul maître des données et de la logique (services, réglages,
//     navigation). Rien n'est réécrit en Kotlin.
//   • KOTLIN affiche la description avec les vrais composants Glasmio et
//     renvoie chaque geste (`evenement`) — Dart répond par une nouvelle
//     description, une alerte, ou l'ordre de fermer.
//
// ⚠️ ANDROID 13 (API 33) MINIMUM : c'est l'exigence de Glasmio (ses shaders
// `RuntimeShader`). En dessous, et sur toute autre plateforme, `disponible`
// est faux et Droplet garde ses écrans Flutter : rien ne disparaît.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// La réponse de Dart à un geste fait dans un écran Glasmio.
class ReponseGlasmio {
  const ReponseGlasmio._({this.description, this.alerte, this.fermer = false});

  /// Redessiner l'écran avec cette description.
  const ReponseGlasmio.maj(Map<String, Object?> description) : this._(description: description);

  /// Afficher une alerte Glasmio (confirmation) : `titre`, `message`,
  /// `confirmer`, `annuler`, `id` (l'événement renvoyé si on confirme),
  /// `destructif`.
  const ReponseGlasmio.alerte(Map<String, Object?> alerte) : this._(alerte: alerte);

  /// Fermer l'écran natif (avant une navigation côté Flutter).
  const ReponseGlasmio.fermer() : this._(fermer: true);

  /// Rien à changer.
  static const rien = ReponseGlasmio._();

  final Map<String, Object?>? description;
  final Map<String, Object?>? alerte;
  final bool fermer;

  Map<String, Object?> versCarte() => {
        if (description != null) 'description': jsonEncode(description),
        if (alerte != null) 'alerte': jsonEncode(alerte),
        if (fermer) 'fermer': true,
      };
}

typedef GestionnaireGlasmio = Future<ReponseGlasmio> Function(String id, Object? valeur);

class PontGlasmio {
  PontGlasmio._();

  static const _canal = MethodChannel('droplet/glasmio');

  static bool? _disponible;
  static GestionnaireGlasmio? _gestionnaire;
  static VoidCallback? _surFermeture;
  static bool _installe = false;

  /// Vrai sur Android 13+ quand la couche native Glasmio est présente.
  static Future<bool> disponible() async {
    if (_disponible != null) return _disponible!;
    if (kIsWeb || !Platform.isAndroid) return _disponible = false;
    try {
      _disponible = await _canal.invokeMethod<bool>('disponible') ?? false;
    } on MissingPluginException {
      _disponible = false;
    } catch (_) {
      _disponible = false;
    }
    return _disponible!;
  }

  /// Les gestes de la barre de navigation Glasmio (voir `barre_glasmio.dart`).
  static void Function(String id, Object? valeur)? surBarre;

  /// Installe la réception des messages du côté Android (idempotent).
  static void installerRecepteur() => _installer();

  static void _installer() {
    if (_installe) return;
    _installe = true;
    _canal.setMethodCallHandler((appel) async {
      switch (appel.method) {
        case 'evenement':
          final args = Map<String, Object?>.from(appel.arguments as Map);
          final g = _gestionnaire;
          if (g == null) return const <String, Object?>{};
          try {
            final r = await g(args['id'] as String? ?? '', args['valeur']);
            return r.versCarte();
          } catch (e) {
            debugPrint('[PontGlasmio] événement ${args['id']} : $e');
            return const <String, Object?>{};
          }
        case 'barre':
          final args = Map<String, Object?>.from(appel.arguments as Map);
          surBarre?.call(args['id'] as String? ?? '', args['valeur']);
          return null;
        case 'ferme':
          // L'écran natif a disparu (retour, geste, ou fermeture demandée).
          final f = _surFermeture;
          _gestionnaire = null;
          _surFermeture = null;
          f?.call();
          return null;
      }
      return null;
    });
  }

  /// Ouvre un écran natif Glasmio ([ecran] sert au journal). [sansAnimation] :
  /// au retour d'une page Flutter, l'écran revient sans glisser.
  /// [gestionnaire] reçoit chaque geste ; [surFermeture] est appelé quand
  /// l'écran disparaît, quelle qu'en soit la raison.
  static Future<bool> ouvrir({
    required String ecran,
    required Map<String, Object?> description,
    required GestionnaireGlasmio gestionnaire,
    VoidCallback? surFermeture,
    bool sansAnimation = false,
  }) async {
    if (!await disponible()) return false;
    _installer();
    _gestionnaire = gestionnaire;
    _surFermeture = surFermeture;
    try {
      await _canal.invokeMethod<void>('ouvrir', {
        'ecran': ecran,
        'description': jsonEncode(description),
        'sansAnimation': sansAnimation,
      });
      return true;
    } catch (e) {
      debugPrint('[PontGlasmio] ouverture : $e');
      _gestionnaire = null;
      _surFermeture = null;
      return false;
    }
  }

  /// Redessine l'écran ouvert (une donnée a changé ailleurs, par exemple
  /// l'état de Tor).
  static Future<void> mettreAJour(Map<String, Object?> description) async {
    if (_gestionnaire == null) return;
    try {
      await _canal.invokeMethod<void>('maj', {'description': jsonEncode(description)});
    } catch (_) {}
  }

  /// Ferme l'écran ouvert.
  static Future<void> fermer() async {
    try {
      await _canal.invokeMethod<void>('fermer');
    } catch (_) {}
  }
}
