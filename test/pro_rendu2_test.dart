// ============================================================================
// LA VITRINE DROPLET PRO — l'écran d'achat entier, en sombre et en clair,
// tel qu'un téléphone de 390 × 844 le montre à l'arrivée.
// Images : build/rendu_accueil/pro_*.png
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/premium/vitrine_pro.dart';
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
    final nom = 'pro_${sombre ? 'sombre' : 'clair'}';
    testWidgets(nom, (tester) async {
      tester.view.physicalSize = const Size(390, 844) * 2;
      tester.view.devicePixelRatio = 2;
      tester.view.padding = const FakeViewPadding(top: 47 * 2, bottom: 34 * 2);
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
          home: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            final haut = MediaQuery.paddingOf(context).top;
            return Scaffold(
              backgroundColor: OuroColors.systemBackground,
              body: Stack(children: [
                const Positioned.fill(child: FondPremium()),
                ListView(
                  padding: EdgeInsets.fromLTRB(16, haut + 34, 16, 190),
                  children: [
                    const Center(child: EmblemePro()),
                    TitrePro(texte: l10n.pmTitle),
                    const SizedBox(height: 10),
                    Text(l10n.pmHeroTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, height: 1.4, color: OuroColors.secondaryLabel)),
                    const SizedBox(height: 16),
                    const GarantiesPro(),
                    const SizedBox(height: 30),
                    CartesOffresPro(proChoisi: true, prixPro: 1000, prixPack: 500, onChoisir: (_) {}),
                    const SizedBox(height: 14),
                    ContenuOffre(lignes: [l10n.pmProAdvantage1, l10n.pmProAdvantage2, l10n.pmProAdvantage3]),
                    const SizedBox(height: 26),
                    ListeAvantagesVitrine(onOuvrir: (_) {}),
                  ],
                ),
                Positioned(
                  top: haut + 8,
                  left: 12,
                  child: BoutonRondVerre(icone: Icons.close_rounded, etiquette: 'Fermer', onTap: () {}),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BarreAchatPro(
                    libelle: l10n.pmCtaUnlock(prixLisible(1000)),
                    precision: l10n.pmCtaFootnote,
                    onAcheter: () {},
                    libelleCode: l10n.pmAlreadyPaidRestore,
                    onCode: () {},
                  ),
                ),
              ]),
            );
          }),
        ),
      ));
      for (var k = 0; k < 14; k++) {
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
      await tester.pumpWidget(const SizedBox());
    });
  }
}
