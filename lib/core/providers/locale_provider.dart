// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// La langue de l'interface. Même structure que `appearance_provider.dart`
// pour le mode sombre/clair — c'est le même genre de réglage : un choix
// persisté, avec un mode « Automatique » qui suit une valeur EXTÉRIEURE
// (la luminosité du système là-bas, la langue du système ici).
//
// ── POURQUOI `null` EST UN ÉTAT À PART ENTIÈRE ────────────────────────
//
// `null` veut dire « Automatique » : suivre la langue du téléphone. Ce
// n'est PAS pareil que forcer explicitement le français, même si les deux
// peuvent afficher la même chose au premier lancement — un appareil réglé
// en français bascule automatiquement quand on change la langue du
// téléphone, alors qu'un choix explicite « Français » reste figé.
//
// ── POURQUOI LA RÉSOLUTION VÉRIFIE LA LISTE PRISE EN CHARGE ──────────
//
// La langue du système peut être n'importe laquelle des centaines de
// codes IETF existants — Droplet n'en traduit que dix. Demander à
// `MaterialApp` un `Locale('ja')` qu'aucun de ses délégués ne sait
// résoudre le ferait retomber sur la locale par défaut À SA façon (pas
// nécessairement le français). On fait donc la vérification explicitement
// ici, avec le français comme repli assumé — c'est la langue source de
// l'app, celle dans laquelle chaque écran a été écrit et testé en
// premier.
// ============================================================================

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

const String _localeKey = 'app_locale';

/// Les dix langues que Droplet sait afficher.
///
/// L'ORDRE compte : c'est celui du sélecteur dans les réglages. Le
/// français est premier — la langue source — puis le reste par nombre
/// approximatif de locuteurs dans le monde.
const List<Locale> kSupportedLocales = [
  Locale('fr'),
  Locale('en'),
  Locale('es'),
  Locale('ar'),
  Locale('pt'),
  Locale('de'),
  Locale('it'),
  Locale('ru'),
  Locale('zh'),
  Locale('hi'),
];

/// Le nom de chaque langue DANS SA PROPRE LANGUE — jamais traduit.
///
/// C'est la convention universelle des sélecteurs de langue (iOS,
/// Android, WhatsApp, Telegram) : une personne qui ne lit pas le
/// français doit pouvoir reconnaître sa langue au milieu de la liste,
/// ce qui est impossible si tous les noms sont écrits en français.
const Map<String, String> kLanguageEndonyms = {
  'fr': 'Français',
  'en': 'English',
  'es': 'Español',
  'ar': 'العربية',
  'pt': 'Português',
  'de': 'Deutsch',
  'it': 'Italiano',
  'ru': 'Русский',
  'zh': '中文',
  'hi': 'हिन्दी',
};

/// La langue choisie, persistée entre deux lancements.
///
/// `null` = Automatique (suit le système). Voir [resolveLocale] pour la
/// résolution effective.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(_load());

  static Locale? _load() {
    final raw = StorageService.getString(_localeKey);
    if (raw == null || raw.isEmpty) return null;
    return kSupportedLocales.where((l) => l.languageCode == raw).firstOrNull;
  }

  /// Fixe la langue. `null` repasse en mode Automatique.
  Future<void> set(Locale? locale) async {
    state = locale;
    await StorageService.setString(_localeKey, locale?.languageCode ?? '');
  }
}

/// Résout la langue EFFECTIVE à appliquer à `MaterialApp`.
///
/// Si [choisie] est non nulle (l'utilisateur a fait un choix explicite
/// dans les réglages), elle est utilisée telle quelle — elle fait déjà
/// partie de [kSupportedLocales].
///
/// Sinon, on regarde la langue du système : si Droplet la prend en
/// charge, on l'utilise ; sinon on retombe sur le français, la langue
/// source de l'app.
Locale resolveLocale(Locale? choisie) {
  if (choisie != null) return choisie;

  final systemLocale = PlatformDispatcher.instance.locale;
  final matched = kSupportedLocales
      .where((l) => l.languageCode == systemLocale.languageCode)
      .firstOrNull;
  return matched ?? const Locale('fr');
}

/// Le libellé d'une langue à afficher dans les réglages.
String languageLabel(Locale locale) {
  return kLanguageEndonyms[locale.languageCode] ?? locale.languageCode;
}

/// La langue effective à utiliser AVANT même que Riverpod n'ait construit
/// le moindre widget — pour `NotificationService.currentLocale`, réglé au
/// tout début de `main()`. Relit directement le disque (même logique que
/// [LocaleNotifier._load]) plutôt que de dépendre d'un `ProviderContainer`
/// qui n'existe pas encore à ce stade du démarrage.
Locale currentAppLocale() => resolveLocale(LocaleNotifier._load());
