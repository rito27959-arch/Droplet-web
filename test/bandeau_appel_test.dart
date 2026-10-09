// ============================================================================
// CE QUE CE TEST VÉRIFIE
// ----------------------------------------------------------------------------
// Le format de la durée d'appel. C'est une fonction minuscule, et c'est
// exactement pour ça qu'elle mérite un test : elle s'affiche en permanence
// pendant un appel, et une erreur de format (un « 4:7 » au lieu de
// « 4:07 », une durée négative, une heure oubliée au-delà de 60 minutes)
// se voit tout de suite et ne se rattrape pas.
//
// Les cas limites ne sont pas théoriques :
//   • l'horloge du téléphone peut RECULER pendant un appel, quand elle se
//     resynchronise sur le réseau — d'où le cas négatif ;
//   • un appel de groupe laissé ouvert peut dépasser l'heure, et même la
//     journée.
// ============================================================================

import 'package:droplet/features/call/bandeau_appel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formaterDureeAppel', () {
    test('sous la minute, deux chiffres pour les secondes', () {
      expect(formaterDureeAppel(Duration.zero), '0:00');
      expect(formaterDureeAppel(const Duration(seconds: 7)), '0:07');
      expect(formaterDureeAppel(const Duration(seconds: 59)), '0:59');
    });

    test('les minutes', () {
      expect(formaterDureeAppel(const Duration(seconds: 60)), '1:00');
      expect(formaterDureeAppel(const Duration(seconds: 247)), '4:07');
      expect(formaterDureeAppel(const Duration(seconds: 3599)), '59:59');
    });

    test('au-delà de l\'heure, le format change', () {
      expect(formaterDureeAppel(const Duration(hours: 1)), '1:00:00');
      expect(formaterDureeAppel(const Duration(seconds: 3753)), '1:02:33');
      expect(formaterDureeAppel(const Duration(hours: 10)), '10:00:00');
      expect(
        formaterDureeAppel(const Duration(hours: 25, minutes: 1, seconds: 1)),
        '25:01:01',
      );
    });

    test('une durée négative rend zéro, pas un affichage cassé', () {
      // Arrive quand l'horloge du téléphone recule entre le décrochage et
      // l'affichage. Sans la garde, on lirait « -1:-3 ».
      expect(formaterDureeAppel(const Duration(seconds: -5)), '0:00');
      expect(formaterDureeAppel(const Duration(hours: -2)), '0:00');
    });
  });
}
