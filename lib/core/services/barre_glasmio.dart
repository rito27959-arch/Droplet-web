// ============================================================================
// LA BARRE DE NAVIGATION GLASMIO, CÔTÉ DART (Android 13+).
// ----------------------------------------------------------------------------
// L'accueil (`HomeShell`) décrit sa barre — onglets, onglet actif, pastilles
// de non-lus, repliée ou non — et la barre native Glasmio la dessine par-dessus
// Flutter (voir BarreNavigationGlasmio.kt). La barre n'est visible que lorsque
// l'accueil est la page du dessus : l'observateur de routes ci-dessous la
// cache dès qu'une conversation, une feuille ou une boîte de dialogue s'ouvre.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design_system/ouro_colors.dart';
import 'pont_glasmio.dart';

/// La page du dessus du navigateur racine — pour savoir si l'accueil est
/// visible. À donner au routeur (`observers`).
class ObservateurRoutesGlasmio extends NavigatorObserver {
  final ValueNotifier<Route<dynamic>?> sommet = ValueNotifier(null);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => sommet.value = route;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => sommet.value = previousRoute;

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (sommet.value == route) sommet.value = previousRoute;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (sommet.value == oldRoute) sommet.value = newRoute;
  }
}

final observateurRoutesGlasmio = ObservateurRoutesGlasmio();

/// Vrai quand la barre native est là : l'accueil Flutter cache alors sa
/// propre barre et le bouton rond (la loupe Glasmio le remplace).
final ValueNotifier<bool> barreGlasmioActive = ValueNotifier(false);

/// Chaque toucher de la loupe incrémente ce compteur : la liste des
/// discussions remonte et ouvre sa recherche.
final ValueNotifier<int> demandeRechercheGlasmio = ValueNotifier(0);

/// La recherche flottante native : `null` quand elle est fermée, sinon le
/// texte tapé dans le champ de verre (la liste des discussions s'y filtre).
final ValueNotifier<String?> requeteGlasmio = ValueNotifier(null);

class OngletGlasmio {
  const OngletGlasmio(this.titre, {this.badge = 0});

  final String titre;
  final int badge;
}

class BarreGlasmio {
  BarreGlasmio._();

  static const _canal = MethodChannel('droplet/glasmio');
  static String? _derniere;

  /// Oublie la dernière barre envoyée : la prochaine sera renvoyée même
  /// identique.
  static void oublier() => _derniere = null;
  static DateTime _derniereActivite = DateTime(0);

  /// Les gestes : `onglet` (valeur = index), `recherche` (la barre devient
  /// un champ), `requete` (valeur = texte), `recherche_fin`, `deplier`.
  static final StreamController<(String, Object?)> _gestes = StreamController.broadcast();
  static Stream<(String, Object?)> get gestes {
    PontGlasmio.surBarre ??= (id, valeur) => _gestes.add((id, valeur));
    PontGlasmio.installerRecepteur();
    return _gestes.stream;
  }

  static Future<bool> disponible() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return PontGlasmio.disponible();
  }

  /// Décrit la barre ; n'envoie rien si rien n'a changé.
  static Future<void> afficher({
    required bool visible,
    required List<OngletGlasmio> onglets,
    required int index,
    required bool compact,
    required String recherche,
    String annuler = 'Annuler',
  }) async {
    final d = jsonEncode({
      'visible': visible,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'onglets': [for (final o in onglets) {'titre': o.titre, 'badge': o.badge}],
      'index': index,
      'compact': compact,
      'recherche': recherche,
      'annuler': annuler,
    });
    if (d == _derniere) return;
    _derniere = d;
    try {
      await _canal.invokeMethod<void>('barre', {'description': d});
    } catch (_) {}
  }

  /// Un défilement est en cours : la barre recopie la liste plus souvent,
  /// pour que son verre suive ce qui passe dessous.
  static void activite() {
    final maintenant = DateTime.now();
    if (maintenant.difference(_derniereActivite).inMilliseconds < 150) return;
    _derniereActivite = maintenant;
    _canal.invokeMethod<void>('barre_activite').catchError((_) {});
  }
}
