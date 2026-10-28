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

  // Chaque scène premium à trois instants, autour de son sticker.
  testWidgets('scènes premium', (tester) async {
    const cote = 380.0;
    tester.view.physicalSize = const Size(3 * cote, 8 * cote) * 1;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    OuroColors.setBrightness(Brightness.light);
    final cle = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: cle,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFEFEAE2),
          body: Column(
            children: [
              for (final s in StickersDroplet.premiums)
                Row(
                  children: [
                    for (final t in [0.12, 0.3, 0.55])
                      SizedBox(
                        width: cote,
                        height: cote,
                        child: ClipRect(
                          child: Stack(
                            children: [
                              Center(child: VueStickerDroplet(sticker: s, taille: 90, tempsFixe: 1.0)),
                              Positioned.fill(child: GerbePremium(genre: s.effet!, centre: const Offset(cote / 2, cote / 2), taille: 90, surFin: () {}, tempsFixe: t)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await _photo(tester, cle, 'scenes_premium');
    await tester.pumpWidget(const SizedBox());
  });

  // Le jeu, image par image, de quelques stickers : on vérifie la tête
  // qui tourne, les sourcils, l'anticipation.
  testWidgets('jeu image par image', (tester) async {
    const ids = ['salut', 'rire', 'ok', 'colere', 'pense'];
    tester.view.physicalSize = const Size(8 * 130, 6 * 130) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    OuroColors.setBrightness(Brightness.light);
    final cle = GlobalKey();
    final lignes = [
      for (final id in ids) StickersDroplet.gratuits.firstWhere((s) => s.id == id),
      StickersDroplet.premiums.firstWhere((s) => s.id == 'couronne'),
    ];
    await tester.pumpWidget(RepaintBoundary(
      key: cle,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              for (final s in lignes)
                Row(
                  children: [
                    for (var k = 0; k < 8; k++)
                      SizedBox(width: 130, height: 130, child: VueStickerDroplet(sticker: s, taille: 130, tempsFixe: k * 2.8 / 8)),
                  ],
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await _photo(tester, cle, 'jeu_images');
    await tester.pumpWidget(const SizedBox());
  });
}
