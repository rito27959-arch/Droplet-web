// ============================================================================
// LA BULLE D'APPEL MANQUÉ — rendue en clair et en sombre, et le regroupement
// des appels manqués qui se suivent.
// Images : build/rendu_accueil/appel_manque_*.png
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/core/models/mesh_message.dart';
import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/chat/bulle_appel.dart';
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

MeshMessage _appel(DateTime quand, {bool video = false, String de = 'awa'}) => MeshMessage(
      id: 'appel-${quand.microsecondsSinceEpoch}-$de',
      authorPseudo: 'Awa',
      content: json.encode({'appel': 'manque', 'video': video}),
      type: 'appel',
      timestamp: quand,
      senderId: de,
      targetId: 'moi',
      hopCount: 0,
      status: MessageStatus.sent,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _polices();
    _dossier.createSync(recursive: true);
  });

  test('les appels manqués qui se suivent font une seule bulle', () {
    final t = DateTime(2026, 11, 5, 14);
    expect(appelsGroupes(_appel(t), _appel(t.add(const Duration(minutes: 5)))), isTrue);
    expect(appelsGroupes(_appel(t), _appel(t.add(const Duration(hours: 2)))), isFalse);
    expect(appelsGroupes(_appel(t), _appel(t, video: true)), isFalse);
    expect(appelsGroupes(_appel(t), _appel(t, de: 'paul')), isFalse);
    expect(appelsGroupes(_appel(t), 'séparateur'), isFalse);
  });

  for (final langue in ['fr', 'en']) {
    for (final sombre in [false, true]) {
      final nom = 'appel_manque_${langue}_${sombre ? 'sombre' : 'clair'}';
      testWidgets(nom, (tester) async {
        tester.view.physicalSize = const Size(390, 420) * 2;
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final b = sombre ? Brightness.dark : Brightness.light;
        OuroColors.setBrightness(b);
        final t = DateTime(2026, 11, 5, 14, 32);
        final cle = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: cle,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(langue),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: OuroTheme.of(b),
            home: Scaffold(
              backgroundColor: OuroColors.systemBackground,
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: OuroColors.bubbleIncoming,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text('Tu es dispo ?', style: TextStyle(fontSize: 16, color: OuroColors.bubbleIncomingText)),
                      ),
                    ),
                    BulleAppelManque(message: _appel(t), onRappeler: (_) {}),
                    BulleAppelManque(message: _appel(t, video: true), onRappeler: (_) {}),
                    BulleAppelManque(message: _appel(t), nombre: 3, onRappeler: (_) {}),
                    BulleAppelManque(message: _appel(DateTime.now()), onRappeler: (_) {}),
                  ],
                ),
              ),
            ),
          ),
        ));
        // Plusieurs images : les apparitions (fondu, rebond) se jouent.
        for (var k = 0; k < 20; k++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.runAsync(() async {
          final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boite.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${_dossier.path}/$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
          image.dispose();
        });
        expect(find.byType(BulleAppelManque), findsNWidgets(4));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
}
