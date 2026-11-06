// ============================================================================
// LE SYSTÈME DE SURFACES — fond, lueur rouge, verre de la recherche,
// pastilles de filtres (mates / allumée), carte flottante.
// Images : build/rendu_accueil/surfaces_*.png
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/design_system/ouro_surfaces.dart';
import 'package:droplet/features/chats/bouton_nouvelle_discussion.dart';
import 'package:droplet/features/chats/chats_filter_bar.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _polices();
    _dossier.createSync(recursive: true);
  });

  for (final sombre in [true, false]) {
    final nom = 'surfaces_${sombre ? 'sombre' : 'clair'}';
    testWidgets(nom, (tester) async {
      tester.view.physicalSize = const Size(390, 600) * 2;
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
            backgroundColor: Colors.transparent,
            body: FondAvecLueur(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Discussions',
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: OuroColors.label)),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SurfaceVerre(
                      hauteur: 40,
                      child: Row(children: [
                        const SizedBox(width: 10),
                        Icon(Icons.search_rounded, color: OuroColors.secondaryLabel, size: 20),
                        const SizedBox(width: 8),
                        Text('Rechercher', style: TextStyle(fontSize: 17, color: OuroColors.secondaryLabel)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ChatsFilterBar(
                    actif: FiltreChats.toutes,
                    compteurs: const {FiltreChats.nonLues: 2, FiltreChats.groupes: 1},
                    onChange: (_) {},
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: BoutonNouvelleDiscussion(visible: true, etiquette: 'Nouveau message', onTap: () {}),
                    ),
                  ),
                  // Une capsule à la place de la barre d'onglets, pour juger
                  // le bouton à sa vraie place.
                  Container(
                    height: 58,
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(29),
                      color: OuroColors.isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                      boxShadow: OuroSurfaces.ombreFlottante,
                    ),
                  ),
                ],
              ),
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
      expect(tester.takeException(), isNull);
    });
  }
}
