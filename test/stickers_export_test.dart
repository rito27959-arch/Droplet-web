// ============================================================================
// LES STICKERS DROPLET, IMAGE PAR IMAGE, POUR LES AUTRES APPLICATIONS.
// ----------------------------------------------------------------------------
// WhatsApp, Telegram et les autres ne savent pas exécuter notre code de
// dessin : ils veulent des fichiers (WebP animé pour WhatsApp, WEBM VP9
// pour Telegram). Ce test dessine chacun des vingt stickers sur une boucle
// complète, à 30 images par seconde, en 512 × 512 sur fond transparent,
// avec le liseré blanc et l'ombre douce qu'ont tous les stickers de
// messagerie (sans eux, un trait d'encre sombre disparaît dans un thème
// sombre).
//
// Les images vont dans `build/export_stickers/<lot>-<id>/NNN.png` ; la
// fabrication des fichiers finaux se fait ensuite avec ffmpeg (voir
// `outils/stickers_export.py`). Lancé à la demande seulement : il produit
// environ 1 700 images.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/features/chat/stickers_droplet.dart';
import 'package:droplet/features/chat/stickers_personnage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La durée d'une boucle de chaque sticker, en secondes (lue dans
/// `stickers_personnage.dart`, le `s % période` de chacun).
const Map<String, double> periodes = {
  'goutte/salut': 2.8,
  'goutte/rire': 2.0,
  'goutte/coeur': 2.6,
  'goutte/merci': 2.8,
  'goutte/ok': 2.6,
  'goutte/triste': 3.2,
  'goutte/colere': 2.2,
  'goutte/dodo': 3.4,
  'goutte/wow': 2.4,
  'goutte/fete': 2.0,
  'goutte/bisou': 2.6,
  'goutte/pense': 3.0,
  'eclat/feu': 2.8,
  'eclat/prisme': 3.0,
  'eclat/coeur': 2.4,
  'eclat/couronne': 2.8,
  'eclat/fusee': 2.6,
  'eclat/nova': 2.4,
  'eclat/vague': 2.6,
  'eclat/cristal': 3.0,
};

const int cote = 512;
const double marge = 30;
const int ips = 30;

Future<ui.Image> image(String cle, double t) async {
  final r1 = ui.PictureRecorder();
  final c1 = Canvas(r1);
  c1.translate(marge, marge);
  c1.scale(cote - 2 * marge);
  dessinerSticker(c1, cle, t, sombre: false);
  final dessin = await r1.endRecording().toImage(cote, cote);

  final r2 = ui.PictureRecorder();
  final c2 = Canvas(r2);
  // L'ombre douce, sous le liseré.
  c2.saveLayer(
    null,
    Paint()
      ..imageFilter = ui.ImageFilter.compose(
        outer: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        inner: ui.ImageFilter.dilate(radiusX: 8, radiusY: 8),
      )
      ..colorFilter = const ColorFilter.mode(Color(0x38000000), BlendMode.srcIn),
  );
  c2.drawImage(dessin, const Offset(0, 3), Paint());
  c2.restore();
  // Le liseré blanc.
  c2.saveLayer(
    null,
    Paint()
      ..imageFilter = ui.ImageFilter.dilate(radiusX: 8, radiusY: 8)
      ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn),
  );
  c2.drawImage(dessin, Offset.zero, Paint());
  c2.restore();
  c2.drawImage(dessin, Offset.zero, Paint());
  final finale = await r2.endRecording().toImage(cote, cote);
  dessin.dispose();
  return finale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final racine = Directory('build/export_stickers');

  testWidgets('export des stickers', (tester) async {
    await tester.runAsync(() async {
      racine.createSync(recursive: true);
      final meta = <Map<String, Object?>>[];
      for (final s in [...StickersDroplet.gratuits, ...StickersDroplet.premiums]) {
        final cle = '${s.lot}/${s.id}';
        final periode = periodes[cle]!;
        final dossier = Directory('${racine.path}/${s.lot}-${s.id}')..createSync(recursive: true);
        final n = (periode * ips).round();
        for (var i = 0; i < n; i++) {
          final img = await image(cle, i / ips);
          final png = await img.toByteData(format: ui.ImageByteFormat.png);
          File('${dossier.path}/${i.toString().padLeft(3, '0')}.png').writeAsBytesSync(png!.buffer.asUint8List());
          img.dispose();
        }
        meta.add({
          'lot': s.lot,
          'id': s.id,
          'nom': s.nom,
          'emojis': s.emojis,
          'periode': periode,
          'images': n,
          'premium': s.premium,
        });
      }
      File('${racine.path}/stickers.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(meta));
    });
  }, timeout: const Timeout(Duration(minutes: 20)));
}
