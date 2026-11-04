// ============================================================================
// LE STOCKAGE DE DROPLET WEB — IndexedDB, une entrée par discussion.
// ----------------------------------------------------------------------------
// ⚠️ POURQUOI PLUS `localStorage`.
//
// Avant, tout l'état (profil, contacts, discussions ET tous les messages)
// était un seul texte JSON dans `localStorage`, réécrit en entier 400 ms
// après le moindre changement. Trois défauts :
//   • `localStorage` plafonne vers 5 Mo : passé quelques milliers de
//     messages, l'enregistrement ÉCHOUAIT, en silence ;
//   • l'écriture est synchrone : réécrire 3 Mo bloquait l'interface à
//     chaque message reçu ;
//   • une réaction posée sur un vieux message réécrivait tout l'historique.
//
// Désormais :
//   • une entrée `meta` (profil, réglages, contacts, discussions, statuts,
//     appels) et une entrée `m:<discussion>` par discussion ;
//   • à chaque enregistrement, on ne réécrit QUE les entrées dont le
//     contenu a changé (comparaison avec la dernière version écrite) ;
//   • IndexedDB écrit hors du fil de l'interface et accepte des centaines
//     de Mo.
//
// L'ancien bloc `localStorage` est repris une fois (migration), puis effacé.
// Si IndexedDB est indisponible (rare : certains modes privés), on retombe
// sur `localStorage`, comme avant.
// ============================================================================

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class StockageIdb {
  StockageIdb(this.nomBase);

  /// Le nom de la base (séparé pour la démonstration).
  final String nomBase;

  static const _magasin = 'kv';

  web.IDBDatabase? _base;

  /// La dernière version ÉCRITE de chaque entrée : on ne réécrit que ce
  /// qui a changé.
  final Map<String, String> _ecrit = {};

  bool get disponible => _base != null;

  /// Ouvre la base. Renvoie faux si IndexedDB est indisponible.
  Future<bool> ouvrir() async {
    try {
      final requete = web.window.indexedDB.open(nomBase, 1);
      final fini = Completer<bool>();
      requete.onupgradeneeded = ((web.Event _) {
        final base = requete.result as web.IDBDatabase;
        if (!base.objectStoreNames.contains(_magasin)) {
          base.createObjectStore(_magasin);
        }
      }).toJS;
      requete.onsuccess = ((web.Event _) {
        _base = requete.result as web.IDBDatabase;
        if (!fini.isCompleted) fini.complete(true);
      }).toJS;
      requete.onerror = ((web.Event _) {
        if (!fini.isCompleted) fini.complete(false);
      }).toJS;
      // Une base bloquée par un autre onglet d'une ancienne version : on
      // n'attend pas indéfiniment.
      return await fini.future.timeout(const Duration(seconds: 6), onTimeout: () => false);
    } catch (e) {
      debugPrint('Droplet Web : IndexedDB indisponible ($e)');
      return false;
    }
  }

  /// Toutes les entrées, clé → texte.
  Future<Map<String, String>> toutLire() async {
    final base = _base;
    if (base == null) return {};
    final resultat = <String, String>{};
    final fini = Completer<void>();
    final magasin = base.transaction(_magasin.toJS, 'readonly').objectStore(_magasin);
    final curseur = magasin.openCursor();
    curseur.onsuccess = ((web.Event _) {
      final c = curseur.result as web.IDBCursorWithValue?;
      if (c == null) {
        if (!fini.isCompleted) fini.complete();
        return;
      }
      final cle = (c.key as JSString?)?.toDart;
      final valeur = (c.value as JSString?)?.toDart;
      if (cle != null && valeur != null) resultat[cle] = valeur;
      c.continue_();
    }).toJS;
    curseur.onerror = ((web.Event _) {
      if (!fini.isCompleted) fini.complete();
    }).toJS;
    await fini.future;
    _ecrit
      ..clear()
      ..addAll(resultat);
    return resultat;
  }

  /// Écrit [entrees] (seulement celles qui ont changé) et retire les clés
  /// absentes de [entrees]. Une seule transaction : tout ou rien.
  ///
  /// Renvoie le nombre d'entrées réellement écrites.
  Future<int> synchroniser(Map<String, String> entrees) async {
    final base = _base;
    if (base == null) return 0;
    final aEcrire = <String, String>{
      for (final e in entrees.entries)
        if (_ecrit[e.key] != e.value) e.key: e.value,
    };
    final aRetirer = _ecrit.keys.where((k) => !entrees.containsKey(k)).toList();
    if (aEcrire.isEmpty && aRetirer.isEmpty) return 0;
    final transaction = base.transaction(_magasin.toJS, 'readwrite');
    final magasin = transaction.objectStore(_magasin);
    for (final e in aEcrire.entries) {
      magasin.put(e.value.toJS, e.key.toJS);
    }
    for (final k in aRetirer) {
      magasin.delete(k.toJS);
    }
    final fini = Completer<bool>();
    transaction.oncomplete = ((web.Event _) => fini.complete(true)).toJS;
    transaction.onerror = ((web.Event _) {
      if (!fini.isCompleted) fini.complete(false);
    }).toJS;
    transaction.onabort = ((web.Event _) {
      if (!fini.isCompleted) fini.complete(false);
    }).toJS;
    if (!await fini.future) return 0;
    _ecrit.addAll(aEcrire);
    for (final k in aRetirer) {
      _ecrit.remove(k);
    }
    return aEcrire.length + aRetirer.length;
  }

  /// « Se déconnecter » : tout effacer.
  Future<void> effacer() async {
    final base = _base;
    if (base == null) return;
    final transaction = base.transaction(_magasin.toJS, 'readwrite');
    transaction.objectStore(_magasin).clear();
    final fini = Completer<void>();
    transaction.oncomplete = ((web.Event _) => fini.complete()).toJS;
    transaction.onerror = ((web.Event _) {
      if (!fini.isCompleted) fini.complete();
    }).toJS;
    await fini.future;
    _ecrit.clear();
  }
}
