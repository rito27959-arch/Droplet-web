// ============================================================================
// UN SEUL ONGLET ACTIF À LA FOIS.
// ----------------------------------------------------------------------------
// ⚠️ POURQUOI. Deux onglets de Droplet Web ouverts sur le même compte
// interrogeaient tous deux la boîte aux lettres et écrivaient tous deux dans
// le même stockage : chacun pouvait « consommer » un message que l'autre ne
// voyait jamais, et la dernière écriture effaçait celle de l'autre.
//
// La règle : le DERNIER onglet ouvert est l'onglet actif. À son démarrage,
// il l'annonce sur un `BroadcastChannel` ; les autres onglets se mettent en
// veille (plus de réception, plus d'écriture) et proposent « Utiliser ici »,
// qui recharge la page et en fait à son tour l'onglet actif.
// ============================================================================

import 'dart:js_interop';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class OngletUnique {
  OngletUnique._();

  static final String _moi = '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}';
  static web.BroadcastChannel? _canal;

  /// Vrai quand un autre onglet a pris la main : celui-ci est en veille.
  static final ValueNotifier<bool> ailleurs = ValueNotifier(false);

  /// Annonce que cet onglet devient l'onglet actif pour [compte].
  static void annoncer(String compte) {
    try {
      _canal ??= web.BroadcastChannel('droplet-web-onglets')
        ..onmessage = ((web.MessageEvent e) {
          final d = (e.data as JSString?)?.toDart;
          if (d == null) return;
          final parts = d.split('|');
          if (parts.length != 2) return;
          if (parts[0] != _moi && parts[1] == compte) ailleurs.value = true;
        }).toJS;
      _canal!.postMessage('$_moi|$compte'.toJS);
    } catch (_) {
      // Navigateur sans BroadcastChannel : comportement d'avant.
    }
  }

  /// « Utiliser ici » : recharger, ce qui réannonce cet onglet.
  static void reprendre() => web.window.location.reload();
}
