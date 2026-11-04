// ============================================================================
// LES NOTIFICATIONS ONGLET FERMÉ — côté navigateur.
// ----------------------------------------------------------------------------
// Le navigateur s'abonne auprès de son propre service de notifications avec
// la clé publique de la boîte aux lettres (`/push/cle`), puis confie
// l'adresse obtenue à la boîte (`CanalTelephone.inscrireNotifications`).
// Quand un message arrive, la boîte frappe à cette adresse SANS RIEN
// ENVOYER d'autre ; le service worker (`web/sw.js`) affiche alors « Nouveau
// message ». Voir `droplet_mailbox/lib/push_web.dart`.
//
// Seulement si l'utilisateur a accepté les notifications et les a laissées
// allumées dans les réglages. Safari sur iPhone : seulement quand Droplet
// Web a été ajouté à l'écran d'accueil (règle d'Apple).
// ============================================================================

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../donnees/canal_telephone.dart';

class NotificationsPush {
  NotificationsPush._();

  static String? _inscrit;

  static bool get _possible {
    try {
      return web.window.navigator.has('serviceWorker') && web.window.has('PushManager');
    } catch (_) {
      return false;
    }
  }

  /// S'abonne (une fois par session et par adresse) si c'est permis.
  static Future<void> activer(CanalTelephone canal) async {
    if (!_possible) return;
    try {
      if (web.Notification.permission != 'granted') return;
      final r = await requete('GET', '${canal.boite}/push/cle', delai: const Duration(seconds: 12));
      if (!r.ok) return;
      final cle = (jsonDecode(r.corps) as Map)['cle'] as String?;
      if (cle == null) return;
      final enregistrement = await web.window.navigator.serviceWorker.ready.toDart;
      var abonnement = await enregistrement.pushManager.getSubscription().toDart;
      abonnement ??= await enregistrement.pushManager
          .subscribe(web.PushSubscriptionOptionsInit(
            userVisibleOnly: true,
            applicationServerKey: _octets(cle).toJS,
          ))
          .toDart;
      final endpoint = abonnement.endpoint;
      if (_inscrit == endpoint) return;
      if (await canal.inscrireNotifications(endpoint)) _inscrit = endpoint;
    } catch (e) {
      debugPrint('Droplet Web : notifications onglet fermé indisponibles ($e)');
    }
  }

  /// Se désabonne (réglage coupé, ou déconnexion).
  static Future<void> desactiver(CanalTelephone? canal) async {
    _inscrit = null;
    if (!_possible) return;
    try {
      final enregistrement = await web.window.navigator.serviceWorker.ready.toDart;
      final abonnement = await enregistrement.pushManager.getSubscription().toDart;
      await abonnement?.unsubscribe().toDart;
    } catch (_) {}
    try {
      await canal?.retirerNotifications();
    } catch (_) {}
  }

  static Uint8List _octets(String b64url) {
    var s = b64url.replaceAll('-', '+').replaceAll('_', '/');
    while (s.length % 4 != 0) {
      s += '=';
    }
    return base64Decode(s);
  }
}
