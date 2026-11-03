// ============================================================================
// LES ÉTATS VIDES EN AUTOCOLLANTS, PLANCHE PAR PLANCHE.
// ----------------------------------------------------------------------------
// Les douze grappes (`autocollants_vides.dart`) à trois instants de leur
// animation, en clair et en sombre, puis un état vide complet (grappe,
// titre, texte). Les images vont dans `build/rendu_accueil/`.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/shared/widgets/autocollants_vides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _dossier = Directory('build/rendu_accueil');

Future<void> _polices() async {
  for (final (famille, fichier) in [
    ('Inter Tight', 'assets/fonts/InterTight_700Bold.ttf'),
    ('Inter', 'assets/fonts/InterTight_600SemiBold.ttf'),
    ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
  ]) {
    final f = FontLoader(famille)..addFont(rootBundle.load(fichier));
    await f.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    _dossier.createSync(recursive: true);
    await _polices();
  });

  for (final sombre in [false, true]) {
    final mode = sombre ? 'sombre' : 'clair';
    testWidgets('autocollants $mode', (tester) async {
      const cote = 220.0;
      final scenes = SceneVide.values;
      const instants = [0.3, 1.1, 2.0];
      tester.view.physicalSize = Size(cote * instants.length, cote * 0.72 * scenes.length) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final b = sombre ? Brightness.dark : Brightness.light;
      OuroColors.setBrightness(b);
      final cle = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: cle,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: OuroTheme.of(b),
          home: Scaffold(
            backgroundColor: OuroColors.systemBackground,
            body: Column(
              children: [
                for (final s in scenes)
                  Row(
                    children: [
                      for (final t in instants)
                        SizedBox(
                          width: cote,
                          height: cote * 0.72,
                          child: Center(child: AutocollantsVides(scene: s, largeur: 200, tempsFixe: t)),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.runAsync(() async {
        final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boite.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${_dossier.path}/autocollants_$mode.png').writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
