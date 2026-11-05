// ============================================================================
// LA PASTILLE DE VUE UNIQUE — pas encore ouverte (rond plein « 1 ») et
// ouverte (cercle en pointillés), sur une bulle reçue et une bulle envoyée.
// Images : build/rendu_accueil/vue_unique_*.png
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/core/services/vues_uniques_ouvertes.dart';
import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/chat/vue_unique.dart';
import 'package:droplet/l10n/generated/app_localizations.dart';
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

Widget _bulle({required bool mine, required bool ouverte}) {
  final couleur = mine ? OuroColors.bubbleOutgoingText : OuroColors.accent;
  return Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      decoration: BoxDecoration(
        color: mine ? OuroColors.bubbleOutgoing : OuroColors.bubbleIncoming,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        PastilleVueUnique(
          couleur: couleur,
          ouverte: ouverte,
          couleurChiffre: mine ? OuroColors.bubbleOutgoing : Colors.white,
        ),
        const SizedBox(width: 10),
        Text(ouverte ? 'Ouverte' : 'Photo',
            style: TextStyle(color: couleur, fontWeight: FontWeight.w600, fontSize: 15)),
      ]),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _polices();
    _dossier.createSync(recursive: true);
  });

  test("l'accusé « vue unique ouverte » se reconnaît", () {
    expect(VuesUniquesOuvertes.idDepuisAccuse('vu1:abc-123'), 'abc-123');
    expect(VuesUniquesOuvertes.idDepuisAccuse('abc-123'), isNull);
    expect(VuesUniquesOuvertes.idDepuisAccuse('vu1:'), isNull);
  });

  for (final sombre in [false, true]) {
    final nom = 'vue_unique_${sombre ? 'sombre' : 'clair'}';
    testWidgets(nom, (tester) async {
      tester.view.physicalSize = const Size(390, 260) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final b = sombre ? Brightness.dark : Brightness.light;
      OuroColors.setBrightness(b);
      final cle = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: cle,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: OuroTheme.of(b),
          home: Scaffold(
            backgroundColor: OuroColors.systemBackground,
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                _bulle(mine: false, ouverte: false),
                _bulle(mine: false, ouverte: true),
                _bulle(mine: true, ouverte: false),
                _bulle(mine: true, ouverte: true),
              ]),
            ),
          ),
        ),
      ));
      for (var k = 0; k < 10; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boite.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${_dossier.path}/$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
      expect(find.byType(PastilleVueUnique), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  }
}
