// ============================================================================
// L'ACCUEIL, ÉCRAN PAR ÉCRAN.
// ----------------------------------------------------------------------------
// Rend chaque étape de l'accueil (les quatre récits, le nom, la photo,
// « vous êtes prêt »), en clair et en sombre, sur deux tailles d'écran,
// et à plusieurs instants de leurs animations. Les images vont dans
// `build/rendu_accueil/` : on les regarde, on ne les compare pas.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/onboarding/onboarding_screen.dart';
import 'package:droplet/features/onboarding/ouverture_droplet.dart';
import 'package:droplet/features/onboarding/scene_presentation.dart';
import 'package:droplet/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _dossier = Directory('build/rendu_accueil');

Future<void> _polices() async {
  for (final (famille, fichier) in [
    ('Inter Tight', 'assets/fonts/InterTight_700Bold.ttf'),
    ('Inter', 'assets/fonts/InterTight_600SemiBold.ttf'),
    ('packages/cupertino_icons/CupertinoIcons', 'packages/cupertino_icons/assets/CupertinoIcons.ttf'),
  ]) {
    final f = FontLoader(famille)..addFont(rootBundle.load(fichier));
    await f.load();
  }
}

class _Cas {
  const _Cas(this.nom, this.etape, {this.recit = 0, this.pseudo});
  final String nom;
  final EtapeAccueil etape;
  final int recit;
  final String? pseudo;
}

const _cas = [
  _Cas('1_recit_marque', EtapeAccueil.recits),
  _Cas('2_recit_relais', EtapeAccueil.recits, recit: 1),
  _Cas('3_recit_chiffrement', EtapeAccueil.recits, recit: 2),
  _Cas('4_recit_securite', EtapeAccueil.recits, recit: 3),
  _Cas('5_nom_vide', EtapeAccueil.nom),
  _Cas('6_nom_rempli', EtapeAccueil.nom, pseudo: 'Awa'),
  _Cas('7_photo', EtapeAccueil.photo, pseudo: 'Awa'),
  _Cas('8_pret', EtapeAccueil.pret, pseudo: 'Awa'),
];

const _ecrans = [('iphone', Size(390, 844)), ('petit', Size(360, 740))];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _polices();
    if (_dossier.existsSync()) _dossier.deleteSync(recursive: true);
    _dossier.createSync(recursive: true);
  });

  for (final (ecran, taille) in _ecrans) {
    for (final sombre in [false, true]) {
      // Le petit écran n'est rendu qu'en clair : on y vérifie la place.
      if (ecran == 'petit' && sombre) continue;
      for (final c in _cas) {
        final mode = sombre ? 'sombre' : 'clair';
        testWidgets('accueil ${c.nom} $ecran $mode', (tester) async {
          reinitialiserOuverture();
          tester.view.physicalSize = taille * 3;
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          final b = sombre ? Brightness.dark : Brightness.light;
          OuroColors.setBrightness(b);

          final cle = GlobalKey();
          await tester.pumpWidget(ProviderScope(
            child: RepaintBoundary(
              key: cle,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: const Locale('fr'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: OuroTheme.of(b),
                home: OnboardingScreen(depart: c.etape, recitDepart: c.recit, pseudoDepart: c.pseudo),
              ),
            ),
          ));

          var ecoule = 0;
          for (final ms in [350, 1300, 2500]) {
            await tester.pump(Duration(milliseconds: ms - ecoule));
            ecoule = ms;
            await tester.runAsync(() async {
              final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
              final image = await boite.toImage(pixelRatio: 2);
              final png = await image.toByteData(format: ui.ImageByteFormat.png);
              File('${_dossier.path}/${ecran}_${mode}_${c.nom}_$ms.png').writeAsBytesSync(png!.buffer.asUint8List());
              image.dispose();
            });
          }
          // Laisser les boucles et minuteries se terminer proprement.
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        });
      }
    }
  }

  // La scène seule, image par image d'un glissement : on vérifie que
  // chaque transformation reste lisible À MI-CHEMIN, là où le doigt peut
  // s'arrêter.
  for (final sombre in [false, true]) {
    final mode = sombre ? 'sombre' : 'clair';
    testWidgets('scène, glissement $mode', (tester) async {
      reinitialiserOuverture();
      tester.view.physicalSize = const Size(390, 380) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final b = sombre ? Brightness.dark : Brightness.light;
      OuroColors.setBrightness(b);
      for (final page in [0.0, 0.3, 0.6, 1.0, 1.3, 1.6, 2.0, 2.3, 2.6, 3.0]) {
        final cle = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: cle,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: OuroTheme.of(b),
            home: Scaffold(
              backgroundColor: OuroColors.systemBackground,
              body: ScenePresentation(pageFixe: page, tempsFixe: const Duration(milliseconds: 1500)),
            ),
          ),
        ));
        await tester.pump();
        await tester.runAsync(() async {
          final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boite.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${_dossier.path}/scene_${mode}_${page.toStringAsFixed(1)}.png').writeAsBytesSync(png!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
