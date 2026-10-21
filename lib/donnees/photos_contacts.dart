// ============================================================================
// LES PHOTOS DE PROFIL DE MES CONTACTS, sur Droplet Web.
// ----------------------------------------------------------------------------
// C'est le téléphone qui détient les photos de mes contacts (il les reçoit
// d'eux). Il n'envoie au web que leur EMPREINTE avec chaque contact
// (`av`, 16 caractères) ; le web demande la photo elle-même au moment où
// il doit l'afficher (`{'t': 'avatars', 'ids': […]}`), et le téléphone
// répond par lots (`{'avatars': {id: {av, photo}}}`).
//
// ⚠️ LES PHOTOS NE SONT PAS RANGÉES DANS LE STOCKAGE DU NAVIGATEUR. Il est
// limité à ~5 Mo pour tout Droplet Web (messages compris), et cent photos
// le rempliraient. Elles vivent donc le temps de l'onglet et sont
// redemandées à l'ouverture suivante — seulement celles qu'on affiche.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

class PhotosContacts {
  PhotosContacts._();

  /// Change à chaque photo reçue ou retirée : les avatars se redessinent.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Pour demander des photos au téléphone (branché par le dépôt).
  static Future<void> Function(List<String> ids)? demandeur;

  static final Map<String, String> _empreintes = {};
  static final Map<String, ({String av, String url})> _photos = {};
  static final Map<String, DateTime> _demandees = {};
  static final Set<String> _aDemander = {};
  static Timer? _envoi;

  /// La photo de [id], ou rien (les initiales s'affichent). Si le
  /// téléphone en a annoncé une que je n'ai pas encore, je la demande.
  static String? de(String id) {
    final av = _empreintes[id];
    if (av == null) return null;
    final p = _photos[id];
    if (p != null && p.av == av) return p.url;
    _demander(id);
    // L'ancienne photo, le temps que la nouvelle arrive.
    return p?.url;
  }

  /// L'empreinte annoncée par le téléphone avec un contact (`null` : il
  /// n'a pas de photo).
  static void noterEmpreinte(String id, String? av) {
    if (av == _empreintes[id]) return;
    if (av == null) {
      _empreintes.remove(id);
      _photos.remove(id);
    } else {
      _empreintes[id] = av;
    }
    revision.value++;
  }

  /// Un lot de photos envoyé par le téléphone.
  static void recevoir(Map<String, dynamic> lot) {
    for (final e in lot.entries) {
      final v = e.value;
      if (v is! Map) continue;
      final av = v['av'];
      final photo = v['photo'];
      if (av is String && photo is String && photo.isNotEmpty) {
        _empreintes[e.key] = av;
        _photos[e.key] = (av: av, url: 'data:image/jpeg;base64,$photo');
      } else if (av == null) {
        _empreintes.remove(e.key);
        _photos.remove(e.key);
      }
    }
    revision.value++;
  }

  /// « Se déconnecter » : on oublie tout.
  static void oublier() {
    _empreintes.clear();
    _photos.clear();
    _demandees.clear();
    _aDemander.clear();
    revision.value++;
  }

  /// Les demandes partent groupées, une demi-seconde après la première :
  /// une liste de discussions qui s'affiche en demande trente d'un coup.
  /// Une même photo n'est pas redemandée avant 2 minutes.
  static void _demander(String id) {
    final avant = _demandees[id];
    if (avant != null && DateTime.now().difference(avant) < const Duration(minutes: 2)) return;
    _demandees[id] = DateTime.now();
    _aDemander.add(id);
    _planifier();
  }

  static void _planifier() {
    _envoi ??= Timer(const Duration(milliseconds: 500), () {
      _envoi = null;
      final ids = _aDemander.take(60).toList();
      _aDemander.removeAll(ids);
      final d = demandeur;
      if (d != null && ids.isNotEmpty) unawaited(d(ids).then<void>((_) {}, onError: (Object _) {}));
      if (_aDemander.isNotEmpty) _planifier();
    });
  }
}
