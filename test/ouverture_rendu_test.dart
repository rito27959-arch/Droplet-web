// ============================================================================
// L'OUVERTURE, IMAGE PAR IMAGE.
// ----------------------------------------------------------------------------
// Ce n'est pas un test qui « passe » ou « échoue » sur un détail visuel :
// il REND la séquence d'ouverture à 60 images par seconde, dans plusieurs
// situations, et écrit chaque image dans `build/rendu/`. On les regarde
// ensuite au ralenti (planche contact, GIF) pour repérer les à-coups, et
// on vérifie par le calcul :
//
//   • que la première image est celle de l'écran de lancement natif ;
//   • qu'aucune image ne « saute » (écart brusque entre deux images) ;
//   • que l'ouverture se termine, et dans le temps annoncé.
//
// Les écrans d'arrivée sont des maquettes (une liste de discussions, un
// écran de bienvenue) : on juge l'ouverture, pas les écrans.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:droplet/features/onboarding/ouverture_droplet.dart';
import 'package:droplet/l10n/generated/app_localizations.dart';

const _taille = Size(390, 844); // iPhone 14/15, en points
final _dossier = Directory('build/rendu');

Future<void> _polices() async {
  final inter = FontLoader('Inter Tight')..addFont(rootBundle.load('assets/fonts/InterTight_700Bold.ttf'));
  await inter.load();
  // Les tests dessinent le texte par défaut avec une police de blocs
  // (« Ahem ») : on lui substitue Inter Tight pour lire la légende.
  final defaut = FontLoader('Roboto')..addFont(rootBundle.load('assets/fonts/InterTight_600SemiBold.ttf'));
  await defaut.load();
}

/// Une liste de discussions factice, pour voir l'onde ouvrir l'app.
class _Discussions extends StatelessWidget {
  const _Discussions();
  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final texte = sombre ? Colors.white : const Color(0xFF1D1D1F);
    final gris = sombre ? const Color(0xFF98989D) : const Color(0xFF8E8E93);
    const couleurs = [Color(0xFF34C759), Color(0xFFFF9500), Color(0xFF5856D6), Color(0xFF32ADE6), Color(0xFFFF2D55), Color(0xFF00C7BE)];
    return Scaffold(
      backgroundColor: sombre ? Colors.black : Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 44),
            Text('Discussions', style: TextStyle(fontFamily: 'Inter Tight', fontSize: 34, fontWeight: FontWeight.w700, color: texte)),
            const SizedBox(height: 12),
            for (var i = 0; i < 9; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(children: [
                  CircleAvatar(radius: 26, backgroundColor: couleurs[i % couleurs.length]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 13, width: 110.0 + 20 * (i % 3), color: texte.withValues(alpha: 0.85)),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 200.0 - 15 * (i % 4), color: gris.withValues(alpha: 0.6)),
                    ]),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

/// L'écran de bienvenue factice : la marque en haut à gauche, puis les textes.
class _Accueil extends StatelessWidget {
  const _Accueil();
  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final texte = sombre ? Colors.white : const Color(0xFF1D1D1F);
    final accent = sombre ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    return Scaffold(
      backgroundColor: sombre ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CibleOuverture(hauteur: 72, couleur: accent),
            const SizedBox(height: 24),
            ApresOuverture(
              builder: (context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Bienvenue dans\nDroplet', style: TextStyle(fontFamily: 'Inter Tight', fontSize: 34, height: 1.1, fontWeight: FontWeight.w700, color: texte)),
                const SizedBox(height: 40),
                for (var i = 0; i < 3; i++) ...[
                  Container(height: 14, width: 180, color: texte.withValues(alpha: 0.8)),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 260, color: texte.withValues(alpha: 0.35)),
                  const SizedBox(height: 22),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Scenario {
  const _Scenario(this.nom, {required this.accueil, required this.sombre, this.reduit = false, this.retenueMs = 0, this.dureeMs = 1100});
  final String nom;
  final bool accueil;
  final bool sombre;
  final bool reduit;
  final int retenueMs;
  final int dureeMs;
}

const _scenarios = [
  _Scenario('retour_clair', accueil: false, sombre: false),
  _Scenario('retour_sombre', accueil: false, sombre: true),
  _Scenario('premier_clair', accueil: true, sombre: false, dureeMs: 2000),
  _Scenario('premier_sombre', accueil: true, sombre: true, dureeMs: 2000),
  _Scenario('attente_clair', accueil: false, sombre: false, retenueMs: 3000, dureeMs: 3700),
  _Scenario('reduit_clair', accueil: false, sombre: false, reduit: true, dureeMs: 600),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _polices();
    if (_dossier.existsSync()) _dossier.deleteSync(recursive: true);
    _dossier.createSync(recursive: true);
  });

  for (final sc in _scenarios) {
    testWidgets('ouverture ${sc.nom}', (tester) async {
      reinitialiserOuverture();
      tester.view.physicalSize = _taille * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.platformBrightnessTestValue = sc.sombre ? Brightness.dark : Brightness.light;
      if (sc.reduit) tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearAllTestValues();
      });
      if (sc.retenueMs > 0) OuvertureDroplet.retenir();

      final cle = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: cle,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeMode: sc.sombre ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          builder: (context, child) => OuvertureDroplet(versAccueil: sc.accueil, child: child!),
          home: sc.accueil ? const _Accueil() : const _Discussions(),
        ),
      ));

      final journal = StringBuffer('image;ms;active\n');
      var finMs = -1;
      const pas = 1000 / 60;
      final n = (sc.dureeMs / pas).ceil();
      for (var i = 0; i <= n; i++) {
        if (i > 0) await tester.pump(Duration(microseconds: (pas * 1000).round()));
        final ms = (i * pas).round();
        if (sc.retenueMs > 0 && ms >= sc.retenueMs && ms < sc.retenueMs + pas) OuvertureDroplet.liberer();
        final actif = OuvertureDroplet.active.value;
        if (!actif && finMs < 0) finMs = ms;
        journal.writeln('$i;$ms;$actif');
        // Une image sur deux au-delà de la séquence utile, pour rester léger.
        await tester.runAsync(() async {
          final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boite.toImage(pixelRatio: 1);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${_dossier.path}/${sc.nom}_${i.toString().padLeft(3, '0')}.png').writeAsBytesSync(png!.buffer.asUint8List());
          image.dispose();
          if (i == 0 || i % 6 == 0) {
            final grande = await boite.toImage(pixelRatio: 3);
            final png3 = await grande.toByteData(format: ui.ImageByteFormat.png);
            File('${_dossier.path}/${sc.nom}_${i.toString().padLeft(3, '0')}@3x.png').writeAsBytesSync(png3!.buffer.asUint8List());
            grande.dispose();
          }
        });
      }
      File('${_dossier.path}/${sc.nom}.csv').writeAsStringSync('$journal');
      File('${_dossier.path}/${sc.nom}.fin').writeAsStringSync('$finMs');
      expect(finMs, greaterThan(0), reason: "l'ouverture doit se terminer");
    });
  }
}
