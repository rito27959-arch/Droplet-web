// ============================================================================
// LES CAPTURES D'ÉCRAN AUTOMATIQUES (essai Glasmio) — seulement quand l'app
// est compilée avec `--dart-define=DROPLET_CAPTURES=true`. Jamais dans une
// vraie version : la constante vaut `false` et tout ce code est retiré.
//
// Sur l'émulateur de GitHub : une identité d'exemple est créée (« Amina »),
// puis l'app ouvre chaque écran l'un après l'autre et écrit « CAPTURE:<nom> »
// dans le journal Android ; le script de l'émulateur prend la photo à ce
// moment-là.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/services/crypto_service.dart';
import 'core/services/pont_glasmio.dart';
import 'core/services/storage_service.dart';
import 'design_system/ouro_alert.dart';
import 'features/navigateur/navigateur_integre.dart';

const bool kCapturesGlasmio = bool.fromEnvironment('DROPLET_CAPTURES');

Future<void> preparerIdentiteCaptures() async {
  if (StorageService.hasIdentity) return;
  const pseudo = 'Amina';
  final id = StorageService.generateCryptoIdentity(pseudo);
  final cle = await CryptoService.ensureIdentityKeyPair();
  await StorageService.saveUser(DropletUserModel(id: id, pseudo: pseudo, publicKey: cle));
  await StorageService.setOnboardingComplete();
}

Future<void> _attendre(int s) => Future<void>.delayed(Duration(seconds: s));

void _capture(String nom) => debugPrint('CAPTURE:$nom');

Future<void> lancerCaptures(GoRouter routeur) async {
  await _attendre(12);
  _capture('accueil');
  await _attendre(4);
  for (final (nom, route) in [
    ('reglages', '/settings'),
    ('pro', '/premium'),
    ('notifications', '/settings/notifications'),
    ('appareils', '/settings/appareils'),
    ('aide', '/aide'),
    ('contact', '/chat/demo/info'),
    ('stockage', '/settings/storage'),
    ('apparence', '/settings/apparence'),
    ('icone', '/settings/icon'),
    ('sauvegarde', '/backup/export'),
    ('droplet_id', '/droplet-id'),
  ]) {
    routeur.push(route);
    await _attendre(6);
    _capture(nom);
    await _attendre(3);
    await PontGlasmio.fermer();
    await _attendre(3);
  }
  // Pas de scanner QR ici : l'émulateur n'a pas de caméra, et CameraX y
  // fait planter l'app (« Device reporting less cameras than anticipated »).
  // La recherche flottante : le script touche la loupe de la barre native
  // (en bas à droite) et tape un mot, puis photographie la transformation.
  _capture('loupe');
  await _attendre(14);
  final contexte = cleNavigateurRacine.currentContext;
  if (contexte != null && contexte.mounted) {
    // L'alerte Glasmio par-dessus l'accueil ; le script la ferme (retour).
    Future<void>.delayed(const Duration(seconds: 5), () => _capture('alerte'));
    await ouroConfirm(
      contexte,
      title: 'Supprimer la discussion ?',
      message: 'Les messages seront effacés de ce téléphone.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
  }
  await _attendre(3);
  _capture('fin');
}
