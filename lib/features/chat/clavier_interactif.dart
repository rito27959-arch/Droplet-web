// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE CLAVIER QUI SUIT LE DOIGT — côté Dart. Le côté Android est dans
// `ClavierInteractif.kt`, qui explique le mécanisme.
//
// ── LE GESTE, TEL QU'IL SE FAIT DANS MESSAGES SUR iPHONE ──────────────
//
//   1. On fait défiler la conversation vers le bas, clavier ouvert : rien
//      ne bouge côté clavier tant que le doigt n'a pas ATTEINT son bord
//      supérieur.
//   2. Dès qu'il le franchit, le clavier se colle sous le doigt et
//      descend avec lui ; la barre de saisie et la conversation suivent.
//   3. On remonte : le clavier remonte, sans jamais dépasser sa hauteur.
//   4. On lâche : un élan vers le bas, ou plus de la moitié parcourue, et
//      il finit de se fermer ; sinon il revient.
//
// ⚠️ RIEN DE TOUT ÇA SOUS ANDROID 11 NI SUR iOS ICI. [ClavierInteractif.
// disponible] répond non, et l'écran garde l'ancien comportement : le
// clavier se ferme d'un coup dès qu'on fait défiler.
// ============================================================================

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ClavierInteractif {
  ClavierInteractif._();

  static const MethodChannel _canal = MethodChannel('droplet/clavier');
  static bool? _disponible;

  /// Le système sait-il prêter son clavier ? Mémorisé après la première
  /// réponse.
  static Future<bool> disponible() async {
    final connu = _disponible;
    if (connu != null) return connu;
    if (!Platform.isAndroid) return _disponible = false;
    try {
      return _disponible =
          await _canal.invokeMethod<bool>('disponible') ?? false;
    } catch (_) {
      return _disponible = false;
    }
  }

  static Future<bool> _commencer() async {
    try {
      return await _canal.invokeMethod<bool>('commencer') ?? false;
    } catch (_) {
      return false;
    }
  }

  static void _placer(int basPx) {
    unawaited(_canal
        .invokeMethod<void>('placer', {'bas': basPx})
        .catchError((Object _) {}));
  }

  static void _finir({required bool visible}) {
    unawaited(_canal
        .invokeMethod<void>('finir', {'visible': visible})
        .catchError((Object _) {}));
  }
}

/// Pose le geste sur [child] — en pratique, tout l'écran de conversation.
///
/// Un [Listener] et non un détecteur de gestes : il n'entre pas dans
/// l'arène, et laisse donc la liste défiler normalement pendant que le
/// clavier suit. C'est ce que fait Messages — la conversation continue de
/// glisser sous le doigt.
class SuiviClavier extends StatefulWidget {
  const SuiviClavier({super.key, required this.actif, required this.child});

  /// Faux sous Android 11 : le widget ne fait alors rien du tout.
  final bool actif;
  final Widget child;

  @override
  State<SuiviClavier> createState() => _SuiviClavierState();
}

class _SuiviClavierState extends State<SuiviClavier> {
  int? _pointeur;

  /// La hauteur du clavier au moment où le doigt s'est posé.
  double _hauteur = 0;

  /// `null` tant que le doigt n'a pas atteint le clavier ; `false`
  /// pendant que le système prépare le contrôle ; `true` ensuite.
  bool? _controle;

  double _dernierBas = 0;
  double _vitesse = 0; // points/s, positive vers le bas
  Offset? _dernierePosition;
  Duration? _dernierInstant;

  void _reinitialiser() {
    _pointeur = null;
    _controle = null;
    _dernierePosition = null;
    _dernierInstant = null;
    _vitesse = 0;
  }

  void _surPose(PointerDownEvent e) {
    if (!widget.actif || _pointeur != null) return;
    final hauteur = MediaQuery.viewInsetsOf(context).bottom;
    if (hauteur <= 0) return;
    _pointeur = e.pointer;
    _hauteur = hauteur;
    _dernierBas = hauteur;
    _dernierePosition = e.position;
    _dernierInstant = e.timeStamp;
  }

  void _surMouvement(PointerMoveEvent e) {
    if (e.pointer != _pointeur) return;
    // La vitesse, lissée : la décision au lâcher en dépend.
    final avant = _dernierePosition;
    final tAvant = _dernierInstant;
    if (avant != null && tAvant != null) {
      final dt = (e.timeStamp - tAvant).inMicroseconds / 1e6;
      if (dt > 0) {
        final v = (e.position.dy - avant.dy) / dt;
        _vitesse = _vitesse * 0.6 + v * 0.4;
      }
    }
    _dernierePosition = e.position;
    _dernierInstant = e.timeStamp;

    final ecran = MediaQuery.sizeOf(context).height;
    final bordClavier = ecran - _hauteur;
    final bas = (ecran - e.position.dy).clamp(0.0, _hauteur);

    if (_controle == null) {
      // Le doigt n'a pas encore atteint le clavier : rien ne bouge.
      if (e.position.dy < bordClavier || e.delta.dy <= 0) return;
      _controle = false;
      _dernierBas = bas;
      unawaited(ClavierInteractif._commencer().then((ok) {
        if (!mounted) return;
        if (!ok) {
          _reinitialiser();
          return;
        }
        if (_controle == false) _controle = true;
      }));
    }
    _dernierBas = bas;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // Envoyé même avant `onReady` : le côté natif garde la dernière
    // valeur et l'applique dès qu'il a la main.
    ClavierInteractif._placer((bas * dpr).round());
  }

  void _surLacher(PointerEvent e) {
    if (e.pointer != _pointeur) return;
    if (_controle != null) {
      // Un élan franc décide ; sinon, la moitié du chemin.
      final bool visible;
      if (_vitesse > 350) {
        visible = false;
      } else if (_vitesse < -350) {
        visible = true;
      } else {
        visible = _dernierBas > _hauteur / 2;
      }
      ClavierInteractif._finir(visible: visible);
    }
    _reinitialiser();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.actif) return widget.child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _surPose,
      onPointerMove: _surMouvement,
      onPointerUp: _surLacher,
      onPointerCancel: _surLacher,
      child: widget.child,
    );
  }
}
