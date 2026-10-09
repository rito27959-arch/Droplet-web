// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE RYTHME DU FIL DE CONVERSATION — la règle qui décide si une bulle
// démarre une prise de parole ou continue la précédente.
//
// Trois messages d'affilée de la même personne ne sont pas trois
// événements séparés : c'est une seule prise de parole. On les resserre
// (3 px au lieu de 9), on n'écrit le nom de l'auteur qu'au DÉBUT de la
// série, et seule la DERNIÈRE bulle porte le petit coin pointu à 6 pt qui
// désigne le locuteur. C'est ce que font iMessage et WhatsApp.
//
// ── POURQUOI CE CALCUL A SON PROPRE FICHIER ───────────────────────────
//
// Parce qu'il vivait au milieu d'un `itemBuilder`, dans une méthode
// `build` de plusieurs milliers de lignes, et qu'il y était FAUX depuis
// le début — décalé d'un cran dans les deux sens.
//
// Le piège est l'index. La liste affichée réserve sa position 0 à
// l'en-tête d'historique, donc le message affiché en position `i` est
// `items[i - 1]`. Le code lisait `items[i - 1]` comme étant le
// PRÉCÉDENT : il comparait donc chaque message avec LUI-MÊME. Deux
// messages identiques ont forcément le même auteur et zéro minute
// d'écart, la réponse était donc toujours « oui, c'est une suite » —
// et le nom de l'auteur n'apparaissait jamais, sur aucune bulle, dans
// aucune conversation de groupe.
//
// Rien ne pouvait l'attraper : ça compile, ça n'émet aucun avertissement,
// et à l'œil ça ressemble à un choix de design un peu serré. Sorti ici,
// c'est une fonction pure de trois arguments, et
// `test/groupage_bulles_test.dart` la verrouille.
//
// ⚠️ CE FICHIER NE CONNAÎT PAS LES SÉPARATEURS DE JOUR, ET C'EST VOULU.
// La liste mélange des `MeshMessage` et des séparateurs de date. Plutôt
// que d'importer ce type d'affichage ici, on accepte des `Object?` et
// tout ce qui n'est pas un message rompt la série — ce qui est le
// comportement correct : un changement de jour termine toujours une prise
// de parole.
// ============================================================================

import '../../core/models/mesh_message.dart';

/// Comment une bulle se place dans sa série.
class GroupageBulle {
  const GroupageBulle({required this.suiteDuPrecedent, required this.finDeSerie});

  /// Le message précédent est du même auteur et assez proche dans le
  /// temps : on resserre l'espacement et on n'écrit pas le nom.
  final bool suiteDuPrecedent;

  /// Rien ne suit du même auteur : c'est cette bulle qui porte la queue.
  final bool finDeSerie;

  @override
  bool operator ==(Object other) =>
      other is GroupageBulle &&
      other.suiteDuPrecedent == suiteDuPrecedent &&
      other.finDeSerie == finDeSerie;

  @override
  int get hashCode => Object.hash(suiteDuPrecedent, finDeSerie);

  @override
  String toString() =>
      'GroupageBulle(suite: $suiteDuPrecedent, fin: $finDeSerie)';
}

/// Au-delà de ce délai, deux messages du même auteur redeviennent deux
/// prises de parole distinctes.
///
/// Trois minutes est la valeur d'iMessage. En dessous, une conversation
/// vive se fait hacher ; au-dessus, deux messages séparés par une vraie
/// pause se retrouvent collés et le fil perd sa chronologie.
const Duration kDelaiMemeSerie = Duration(minutes: 3);

/// Deux éléments consécutifs appartiennent-ils à la même prise de parole ?
///
/// Renvoie `false` dès que l'un des deux n'est pas un message — un
/// séparateur de jour rompt toujours la série.
bool memeAuteur(Object? avant, Object? apres) {
  if (avant is! MeshMessage || apres is! MeshMessage) return false;
  if (avant.senderId != apres.senderId) return false;
  final ecart = apres.timestamp.difference(avant.timestamp).abs();
  return ecart < kDelaiMemeSerie;
}

/// Place le message affiché en position [indexAffichage] dans sa série.
///
/// [items] est la liste mêlant messages et séparateurs de jour.
/// [decalage] est le nombre d'éléments que la liste affiche AVANT le
/// premier élément de [items] — l'en-tête d'historique en occupe un.
///
/// C'est ce paramètre qui rend l'erreur d'origine impossible à
/// reproduire : le décalage est nommé et passé explicitement, au lieu
/// d'être réappliqué de tête à chaque accès.
GroupageBulle groupageBulle(
  List<Object> items,
  int indexAffichage, {
  int decalage = 1,
}) {
  final i = indexAffichage - decalage;
  if (i < 0 || i >= items.length) {
    return const GroupageBulle(suiteDuPrecedent: false, finDeSerie: true);
  }
  final courant = items[i];
  final precedent = i > 0 ? items[i - 1] : null;
  final suivant = i + 1 < items.length ? items[i + 1] : null;
  return GroupageBulle(
    suiteDuPrecedent: memeAuteur(precedent, courant),
    finDeSerie: !memeAuteur(courant, suivant),
  );
}
