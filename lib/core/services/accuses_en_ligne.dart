// ============================================================================
// ACCUSÉS « DISTRIBUÉ » ET « LU » POUR LES CONVERSATIONS EN LIGNE.
//
// ⚠️ EN LIGNE, UN MESSAGE NE DÉPASSAIT JAMAIS LA SIMPLE COCHE. Les accusés
// de livraison (`_sendAck`) et de lecture (`sendRead`) ne partaient que vers
// les voisins MESH : un contact joignable seulement par Internet ne les
// recevait jamais, et l'expéditeur ne savait pas si son message était
// arrivé, ni lu. Ils voyagent désormais aussi par la boîte aux lettres,
// chiffrés comme un message, regroupés par contact.
//
// Ce fichier ne contient que la logique PURE (format, rythme de relève) :
// testée dans `test/accuses_en_ligne_test.dart`.
// ============================================================================

import 'dart:convert';

enum TypeAccuse { livre, lu }

class AccuseEnLigne {
  const AccuseEnLigne(this.type, this.identifiants);

  final TypeAccuse type;
  final List<String> identifiants;

  /// Le texte clair à chiffrer (JSON compact).
  String encoder() => jsonEncode({
        't': type == TypeAccuse.lu ? 'lu' : 'livre',
        'ids': identifiants,
      });

  /// `null` si le texte n'est pas un accusé valide.
  static AccuseEnLigne? decoder(String clair) {
    try {
      final d = jsonDecode(clair);
      if (d is! Map) return null;
      final type = switch (d['t']) {
        'lu' => TypeAccuse.lu,
        'livre' => TypeAccuse.livre,
        _ => null,
      };
      final ids = d['ids'];
      if (type == null || ids is! List) return null;
      final propres = ids.whereType<String>().where((s) => s.isNotEmpty).toSet().toList();
      if (propres.isEmpty) return null;
      return AccuseEnLigne(type, propres);
    } catch (_) {
      return null;
    }
  }
}

/// Rythme de relève de la boîte aux lettres.
///
/// ⚠️ 30 SECONDES, C'ÉTAIT UN MESSAGE QUI ARRIVE AVEC UNE DEMI-MINUTE DE
/// RETARD. Quand l'app est à l'écran, on relève toutes les 4 secondes : la
/// conversation paraît instantanée. En arrière-plan, on garde 30 secondes —
/// la notification push (quand elle fonctionne côté serveur) prend le relais,
/// et la batterie est ménagée.
Duration intervalleReleve({required bool premierPlan}) =>
    premierPlan ? const Duration(seconds: 4) : const Duration(seconds: 30);
