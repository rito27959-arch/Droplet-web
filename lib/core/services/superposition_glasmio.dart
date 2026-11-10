// ============================================================================
// LES SUPERPOSITIONS GLASMIO, CÔTÉ DART — alertes, feuilles d'actions, menus
// d'appui long en vrai verre Glasmio par-dessus l'écran Flutter (Android 13+).
// ----------------------------------------------------------------------------
// Chaque fonction renvoie `null` quand Glasmio n'est pas disponible : l'appelant
// affiche alors sa version Flutter habituelle. Rien ne dépend de Glasmio.
// ============================================================================

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design_system/ouro_colors.dart';
import 'pont_glasmio.dart';

/// Ce que la personne a choisi. [id] est `null` si elle a fermé sans choisir.
class ChoixGlasmio {
  const ChoixGlasmio(this.id, this.texte);

  final String? id;
  final String? texte;
}

/// Un bouton d'alerte ou de feuille d'actions.
class BoutonGlasmio {
  const BoutonGlasmio(this.id, this.titre, {this.annuler = false, this.destructif = false});

  final String id;
  final String titre;
  final bool annuler;
  final bool destructif;

  Map<String, Object?> versCarte() => {
        'id': id,
        'titre': titre,
        'role': annuler ? 'annuler' : (destructif ? 'destructif' : 'defaut'),
      };
}

/// Une action de menu d'appui long, avec son icône Flutter.
class ElementMenuGlasmio {
  const ElementMenuGlasmio(this.id, this.titre, {this.icone, this.destructif = false});

  final String id;
  final String titre;
  final IconData? icone;
  final bool destructif;

  Map<String, Object?> versCarte() => {
        'id': id,
        'titre': titre,
        'destructif': destructif,
        if (icone != null) ...{
          'glyphe': icone!.codePoint,
          'police': icone!.fontFamily,
          'paquet': icone!.fontPackage,
        },
      };
}

class SuperpositionGlasmio {
  SuperpositionGlasmio._();

  static const _canal = MethodChannel('droplet/glasmio');

  static Future<ChoixGlasmio?> _afficher(Map<String, Object?> description) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    if (!await PontGlasmio.disponible()) return null;
    try {
      final r = await _canal.invokeMethod<Map<Object?, Object?>>('superposition', {
        'description': jsonEncode({
          'sombre': OuroColors.isDark,
          'accent': OuroColors.accent.toARGB32(),
          ...description,
        }),
      });
      if (r == null || r['indisponible'] == true) return null;
      return ChoixGlasmio(r['id'] as String?, r['texte'] as String?);
    } catch (e) {
      debugPrint('[SuperpositionGlasmio] $e');
      return null;
    }
  }

  /// Une alerte au centre (GlasmioAlertDialog). [champ] : une saisie de
  /// texte (valeur de départ, indice, longueur maximale).
  static Future<ChoixGlasmio?> alerte({
    required String titre,
    String? message,
    required List<BoutonGlasmio> boutons,
    ({String texte, String indice, int? max})? champ,
  }) =>
      _afficher({
        'type': 'alerte',
        'titre': titre,
        'message': ?message,
        'boutons': [for (final b in boutons) b.versCarte()],
        if (champ != null) 'champ': {'texte': champ.texte, 'indice': champ.indice, 'max': champ.max ?? 0},
      });

  /// Une feuille d'actions en bas de l'écran (GlasmioActionSheet).
  static Future<ChoixGlasmio?> feuille({
    String? titre,
    String? message,
    required List<BoutonGlasmio> boutons,
  }) =>
      _afficher({
        'type': 'feuille',
        'titre': titre ?? '',
        'message': ?message,
        'boutons': [for (final b in boutons) b.versCarte()],
      });

  /// Le menu d'appui long : [zone] est le rectangle de l'élément touché, en
  /// coordonnées de l'écran (points logiques).
  static Future<ChoixGlasmio?> menu({
    required Rect zone,
    required List<ElementMenuGlasmio> elements,
    List<String> reactions = const [],
    List<String> actuelles = const [],
    bool aDroite = false,
    bool apercuTouchable = false,
  }) =>
      _afficher({
        'type': 'menu',
        'zone': {'x': zone.left, 'y': zone.top, 'l': zone.width, 'h': zone.height},
        'elements': [for (final e in elements) e.versCarte()],
        'reactions': reactions,
        'actuelles': actuelles,
        'aDroite': aDroite,
        'apercuTouchable': apercuTouchable,
      });
}
