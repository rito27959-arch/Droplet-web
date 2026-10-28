// L'écran d'un appel qui sonne, rendu sur deux tailles d'écran, pour le
// regarder (images dans `build/rendu_accueil/`).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/features/call/ecran_sonnerie.dart';
import 'package:droplet/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (famille, fichier) in [
      ('Inter Tight', 'assets/fonts/InterTight_700Bold.ttf'),
      ('Inter', 'assets/fonts/InterTight_600SemiBold.ttf'),
      ('Roboto', 'assets/fonts/InterTight_600SemiBold.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      try {
        await (FontLoader(famille)..addFont(rootBundle.load(fichier))).load();
      } catch (_) {}
    }
    Directory('build/rendu_accueil').createSync(recursive: true);
  });

  for (final (nom, taille, video) in [('iphone_vocal', const Size(390, 844), false), ('petit_video', const Size(360, 740), true)]) {
    testWidgets('sonnerie $nom', (tester) async {
      tester.view.physicalSize = taille * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final cle = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: cle,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: EcranSonnerie(
            peerId: 'a' * 64,
            pseudo: 'Miguel',
            video: video,
            viaInternet: true,
            onRepondre: () {},
            onRefuser: () {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.runAsync(() async {
        final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boite.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('build/rendu_accueil/sonnerie_$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
