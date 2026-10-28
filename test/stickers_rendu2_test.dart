// ============================================================================
// LES STICKERS DROPLET, PLANCHE PAR PLANCHE.
// ----------------------------------------------------------------------------
// Rend les vingt stickers (douze « Goutte », huit « Éclat ») à trois
// instants de leur boucle, en clair et en sombre, plus une gerbe premium
// à mi-course. Les images vont dans `build/rendu_accueil/`.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/chat/stickers_droplet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _dossier = Directory('build/rendu_accueil');

Future<void> _photo(WidgetTester tester, GlobalKey cle, String nom) async {
  await tester.runAsync(() async {
    final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boite.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${_dossier.path}/$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => _dossier.createSync(recursive: true));

  final tous = [...StickersDroplet.gratuits, ...StickersDroplet.premiums];

  for (final sombre in [false, true]) {
    for (final t in [0.45, 1.15, 1.85]) {
      final mode = sombre ? 'sombre' : 'clair';
      testWidgets('stickers $mode $t', (tester) async {
        tester.view.physicalSize = const Size(5 * 150, 4 * 150) * 2;
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
              body: Wrap(
                children: [
                  for (final s in tous)
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(child: VueStickerDroplet(sticker: s, taille: 140, tempsFixe: t)),
                    ),
                ],
              ),
            ),
          ),
        ));
        await tester.pump();
        await _photo(tester, cle, 'stickers_${mode}_${t.toStringAsFixed(2)}');
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('gerbes premium', (tester) async {
    tester.view.physicalSize = const Size(4 * 260, 2 * 260) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    OuroColors.setBrightness(Brightness.light);
    final cle = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: cle,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Wrap(
            children: [
              for (final g in GenreEffet.values)
                SizedBox(
                  width: 260,
                  height: 260,
                  child: GerbePremium(genre: g, centre: const Offset(130, 130), taille: 90, surFin: () {}),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 520));
    await _photo(tester, cle, 'gerbes_520');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
  });
}
