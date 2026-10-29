// ============================================================================
// L'AVION EN PAPIER, IMAGE PAR IMAGE.
// ----------------------------------------------------------------------------
// Rend la scène d'envoi (`avion_envoi.dart`) à huit instants, pour un texte
// (Plic en héros) et pour un sticker (le sticker en grand), en clair et en
// sombre, sur une fausse conversation. Les images vont dans
// `build/rendu_accueil/avion_*.png`, et une planche les réunit.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/features/chat/avion_envoi.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _dossier = Directory('build/rendu_accueil');
const _taille = Size(390, 844);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => _dossier.createSync(recursive: true));

  for (final sombre in [false, true]) {
    for (final sticker in [null, 'goutte/fete']) {
      final nom = 'avion_${sticker == null ? 'texte' : 'sticker'}_${sombre ? 'sombre' : 'clair'}';
      testWidgets(nom, (tester) async {
        tester.view.physicalSize = _taille * 2;
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final fond = sombre ? Colors.black : Colors.white;
        const accent = Color(0xFF0A84FF);
        // La bulle d'arrivée : en bas à droite, au-dessus de la saisie.
        final bulle = sticker == null
            ? const Rect.fromLTWH(196, 690, 180, 40)
            : const Rect.fromLTWH(236, 600, 140, 140);
        final revelation = ValueNotifier<double>(0);
        final jeu = JeuAvionEnvoi(
          depart: const Offset(362, 790),
          cible: () => bulle,
          revelation: revelation,
          couleur: accent,
          papier: sombre ? const Color(0xFFF2F2F7) : Colors.white,
          sombre: sombre,
          sticker: sticker,
          surFin: () {},
        );
        final cle = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: cle,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: fond)),
                // Deux fausses bulles reçues, et la place de la nouvelle.
                for (final (y, w) in [(560.0, 210.0), (620.0, 160.0)])
                  Positioned(
                    left: 14,
                    top: y,
                    child: Container(
                      width: w,
                      height: 40,
                      decoration: BoxDecoration(
                        color: sombre ? const Color(0xFF26262A) : const Color(0xFFE9E9EB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ValueListenableBuilder<double>(
                  valueListenable: revelation,
                  builder: (_, v, _) => Positioned.fromRect(
                    rect: bulle,
                    child: Opacity(
                      opacity: v,
                      child: Container(
                        decoration: BoxDecoration(
                          color: sticker == null ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
                // La barre de saisie.
                Positioned(
                  left: 10,
                  right: 54,
                  top: 770,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: sombre ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned.fill(child: GameWidget<JeuAvionEnvoi>(game: jeu)),
              ],
            ),
          ),
        ));
        const instants = [60, 200, 420, 760, 1000, 1300, 1600, 1760];
        var ms = 0;
        final images = <ui.Image>[];
        for (final cible in instants) {
          while (ms < cible) {
            await tester.pump(const Duration(milliseconds: 16));
            ms += 16;
          }
          await tester.runAsync(() async {
            final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            images.add(await boite.toImage(pixelRatio: 1));
          });
        }
        // La planche : les huit instants côte à côte, à mi-taille.
        await tester.runAsync(() async {
          final rec = ui.PictureRecorder();
          final c = Canvas(rec);
          const echelle = 0.5;
          final w = _taille.width * echelle, h = _taille.height * echelle;
          for (var k = 0; k < images.length; k++) {
            c.drawImageRect(
              images[k],
              Offset.zero & _taille,
              Rect.fromLTWH(k * w, 0, w, h),
              Paint()..filterQuality = FilterQuality.medium,
            );
          }
          final planche = await rec.endRecording().toImage((w * images.length).round(), h.round());
          final png = await planche.toByteData(format: ui.ImageByteFormat.png);
          File('${_dossier.path}/$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
          for (final i in images) {
            i.dispose();
          }
        });
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
