// ============================================================================
// LE DÉCOUPAGE D'UN FICHIER EN MORCEAUX — ET SON RÉASSEMBLAGE.
//
// ⚠️ POURQUOI. Un fichier partait en UN SEUL paquet : une photo de 3 Mo ou
// une vidéo de 40 Mo s'écrivait d'un bloc dans le socket. Aucune progression
// n'était mesurable (0 % puis soudain 100 %, ou rien), un transfert coupé à
// 99 % repartait de zéro, et la boîte aux lettres (plafond 256 Kio) refusait
// toute vidéo. Chaque morceau est désormais un paquet ordinaire : il est
// acquitté, relayé et retenté individuellement, et c'est ce qui fait avancer
// la barre de progression — chez l'émetteur comme chez le destinataire.
//
// ⚠️ ON DÉCOUPE LE FICHIER DÉJÀ CHIFFRÉ. Les morceaux ne portent donc ni nom
// ni type : un relais voit seulement qu'un fichier de N octets passe, comme
// avant. Le nom et le type restent dans l'enveloppe chiffrée, lue une fois
// le réassemblage terminé.
//
// Ce fichier ne contient que la logique PURE (aucune radio, aucun stockage) :
// elle est testée isolément dans `test/fichier_morcele_test.dart`.
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

class FichierMorcele {
  FichierMorcele._();

  /// Taille d'un morceau. 128 Kio : assez petit pour une progression fluide
  /// et une reprise peu coûteuse, assez grand pour ne pas noyer la file
  /// fiable sous des milliers de paquets (une vidéo de 50 Mo = ~400).
  static const int tailleMorceau = 128 * 1024;

  /// En dessous de ce seuil, l'ancien format en un seul paquet reste utilisé :
  /// les appareils pas encore mis à jour continuent de recevoir photos et
  /// messages vocaux ordinaires.
  static const int seuil = 256 * 1024;

  static bool doitMorceler(int tailleChiffree) => tailleChiffree > seuil;

  /// Découpe [donnees] en morceaux consécutifs de [taille] octets (le dernier
  /// peut être plus court). Vues sur le même tampon : aucune copie.
  static List<Uint8List> decouper(Uint8List donnees, {int taille = tailleMorceau}) {
    if (taille <= 0) throw ArgumentError.value(taille, 'taille');
    final morceaux = <Uint8List>[];
    for (var debut = 0; debut < donnees.length; debut += taille) {
      final fin = (debut + taille) > donnees.length ? donnees.length : debut + taille;
      morceaux.add(Uint8List.sublistView(donnees, debut, fin));
    }
    if (morceaux.isEmpty) morceaux.add(Uint8List(0));
    return morceaux;
  }
}

/// Réassemble un fichier reçu morceau par morceau, dans n'importe quel ordre.
class AssemblageFichier {
  AssemblageFichier({required this.total, required this.tailleTotale})
      : assert(total > 0),
        dernierAjout = DateTime.now();

  /// Nombre de morceaux attendus.
  final int total;

  /// Taille totale attendue, en octets (données chiffrées).
  final int tailleTotale;

  final Map<int, Uint8List> _morceaux = {};
  int _octetsRecus = 0;
  DateTime dernierAjout;

  int get recus => _morceaux.length;
  bool get complet => _morceaux.length == total && _octetsRecus == tailleTotale;

  /// Part reçue, de 0 à 1 — sur les octets, pas le nombre de morceaux, pour
  /// que le dernier morceau (souvent plus court) ne fausse pas la barre.
  double get progression =>
      tailleTotale == 0 ? 1 : (_octetsRecus / tailleTotale).clamp(0.0, 1.0);

  /// Ajoute le morceau [index]. Renvoie `false` s'il est invalide ou déjà là
  /// (un relais peut livrer deux fois le même morceau).
  bool ajouter(int index, Uint8List octets) {
    if (index < 0 || index >= total) return false;
    if (_morceaux.containsKey(index)) return false;
    if (_octetsRecus + octets.length > tailleTotale) return false;
    _morceaux[index] = Uint8List.fromList(octets);
    _octetsRecus += octets.length;
    dernierAjout = DateTime.now();
    return true;
  }

  /// Le fichier complet, dans l'ordre. À n'appeler que si [complet].
  Uint8List assembler() {
    if (!complet) throw StateError('assemblage incomplet ($recus/$total)');
    final b = BytesBuilder(copy: false);
    for (var i = 0; i < total; i++) {
      b.add(_morceaux[i]!);
    }
    return b.takeBytes();
  }
}


/// Le format d'un paquet « morceau de fichier » (type `0x31`) :
///
///   [sauts][0x31][longueur méta, 2 octets][méta JSON UTF-8][octets du morceau]
///
/// La méta porte `fileId`, `i` (index), `n` (nombre de morceaux), `psz`
/// (taille chiffrée totale), `nc` (nonce en base64), plus les champs de
/// routage déjà utilisés par les fichiers en un seul paquet (`s`, `t`, `g`,
/// `ctr`, `e`, `r`, `st`, `av`).
class PaquetMorceau {
  PaquetMorceau._();

  static Uint8List encoder({
    required int sauts,
    required int type,
    required Map<String, dynamic> meta,
    required Uint8List morceau,
  }) {
    final m = Uint8List.fromList(utf8.encode(json.encode(meta)));
    if (m.length > 0xFFFF) throw ArgumentError('méta trop longue');
    return (BytesBuilder(copy: false)
          ..addByte(sauts)
          ..addByte(type)
          ..addByte((m.length >> 8) & 0xFF)
          ..addByte(m.length & 0xFF)
          ..add(m)
          ..add(morceau))
        .toBytes();
  }

  /// `null` si le paquet est tronqué ou si sa méta est illisible.
  static ({Map<String, dynamic> meta, Uint8List morceau})? decoder(Uint8List paquet) {
    if (paquet.length < 4) return null;
    final lm = (paquet[2] << 8) | paquet[3];
    if (paquet.length < 4 + lm) return null;
    try {
      final meta = json.decode(utf8.decode(paquet.sublist(4, 4 + lm)));
      if (meta is! Map<String, dynamic>) return null;
      final i = meta['i'], n = meta['n'], psz = meta['psz'];
      if (meta['fileId'] is! String || i is! int || n is! int || psz is! int) return null;
      if (n <= 0 || i < 0 || i >= n || psz < 0) return null;
      return (meta: meta, morceau: Uint8List.sublistView(paquet, 4 + lm));
    } catch (_) {
      return null;
    }
  }
}
