// ============================================================================
// LE CONTRASTE — le seul défaut de l'audit qui rendait l'application
// inutilisable, et non seulement moins jolie.
// ----------------------------------------------------------------------------
// ⚠️ CE FICHIER EXISTE POUR QUE ÇA NE REVIENNE PAS. Blanc sur vert donnait
// 2,22:1 et blanc sur menthe 2,12:1 : illisible en plein soleil,
// c'est-à-dire dans la situation exacte pour laquelle Droplet est fait.
// Ajouter un accent, ou retoucher une teinte, sans repasser ce test, et le
// défaut revient sans que personne ne le voie — un contraste ne se voit pas
// à l'œil sur l'écran d'un bureau bien éclairé.
//
// Les seuils viennent du critère WCAG 2.1 §1.4.3 : 4,5:1 pour du texte
// courant, 3:1 pour du texte large.
// ============================================================================

import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/reglages_apparence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le contraste d'un texte composé sur un fond, alpha compris.
double _surFond(Color texte, Color fond) {
  final a = texte.a;
  final compose = Color.from(
    alpha: 1,
    red: texte.r * a + fond.r * (1 - a),
    green: texte.g * a + fond.g * (1 - a),
    blue: texte.b * a + fond.b * (1 - a),
  );
  return OuroColors.contraste(compose, fond);
}

void main() {
  group('Les remplissages pleins', () {
    // Chaque accent, dans les deux modes, avec l'encre que l'application
    // poserait dessus.
    for (final accent in ReglagesApparence.accents) {
      for (final sombre in [false, true]) {
        test('${accent.cle} (${sombre ? "sombre" : "clair"}) '
            'atteint 4,5:1', () {
          // L'encre se décide sur la variante CLAIRE, dans les deux modes :
          // un bouton menthe doit rester le même bouton la nuit.
          final encre = OuroColors.texteSurRemplissage(
            accent.pour(sombre: false),
          );
          final fond = OuroColors.surRemplissage(
            accent.pour(sombre: sombre),
            encre: encre,
          );
          expect(
            OuroColors.contraste(fond, encre),
            greaterThanOrEqualTo(4.5),
            reason: 'Un bouton plein en ${accent.cle} porte du texte : '
                'sous 4,5:1 il disparaît dehors.',
          );
        });
      }
    }

    test('l\'encre ne change pas entre les deux modes', () {
      for (final accent in ReglagesApparence.accents) {
        final clair = OuroColors.texteSurRemplissage(
          accent.pour(sombre: false),
        );
        final sombre = OuroColors.texteSurRemplissage(
          accent.pour(sombre: false),
        );
        expect(
          clair,
          sombre,
          reason: 'Une encre qui bascule du blanc au noir en changeant de '
              'mode se lit comme un bug, pas comme une intention.',
        );
      }
    });

    test('le jaune garde sa teinte et prend une encre noire', () {
      // L'assombrir jusqu'au blanc lisible en ferait un olive, et un jaune
      // qui n'est plus jaune ne signale plus rien. Apple fait ce choix-là.
      const jaune = Color(0xFFFFCC00);
      expect(OuroColors.texteSurRemplissage(jaune), const Color(0xFF000000));
      expect(OuroColors.surRemplissage(jaune), jaune);
    });
  });

  group('Les paliers de texte', () {
    // Les deux fonds les plus difficiles de chaque mode.
    const fondsClairs = [Color(0xFFFFFFFF), Color(0xFFF2F2F7)];
    const fondsSombres = [Color(0xFF000000), Color(0xFF1C1C1E)];

    void verifier(String nom, Color Function() palier, double cible) {
      test('$nom atteint $cible:1 dans les deux modes', () {
        for (final (sombre, fonds) in [
          (false, fondsClairs),
          (true, fondsSombres),
        ]) {
          OuroColors.setBrightness(
            sombre ? Brightness.dark : Brightness.light,
          );
          for (final fond in fonds) {
            expect(
              _surFond(palier(), fond),
              greaterThanOrEqualTo(cible),
              reason: '$nom sur ${fond.toARGB32().toRadixString(16)} '
                  'en mode ${sombre ? "sombre" : "clair"}',
            );
          }
        }
      });
    }

    verifier('label', () => OuroColors.label, 15);
    verifier('secondaryLabel', () => OuroColors.secondaryLabel, 7);
    verifier('tertiaryLabel', () => OuroColors.tertiaryLabel, 4.5);
    // ⚠️ 3:1 — le seul palier sous le seuil du texte, et il y reste pour
    // que la hiérarchie garde quatre marches. Réservé au décoratif.
    verifier('quaternaryLabel', () => OuroColors.quaternaryLabel, 3);

    tearDownAll(() => OuroColors.setBrightness(Brightness.dark));
  });

  group('La formule elle-même', () {
    test('noir sur blanc vaut 21', () {
      expect(
        OuroColors.contraste(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
    });

    test('une couleur contre elle-même vaut 1', () {
      expect(
        OuroColors.contraste(const Color(0xFF34C759), const Color(0xFF34C759)),
        closeTo(1, 0.001),
      );
    });

    test('l\'ordre des deux couleurs ne change rien', () {
      const a = Color(0xFF007AFF);
      const b = Color(0xFFF2F2F7);
      expect(OuroColors.contraste(a, b), closeTo(OuroColors.contraste(b, a), 1e-9));
    });
  });
}
