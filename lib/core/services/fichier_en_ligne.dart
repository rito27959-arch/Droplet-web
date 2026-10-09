// ============================================================================
// PHOTOS ET VIDÉOS PAR INTERNET — découpage en morceaux dans la boîte aux
// lettres, et réassemblage fiable à la réception.
// ----------------------------------------------------------------------------
// ⚠️ POURQUOI. Un fichier en ligne partait en UN SEUL dépôt, plafonné à
// 256 Kio : une photo de téléphone (2 à 5 Mo) ou la moindre vidéo était
// refusée avec « trop volumineux ». La conversation en ligne ne transportait
// donc que du texte et des messages vocaux.
//
// Désormais, au-delà de 256 Kio, le fichier (déjà enveloppé : nom + type +
// octets) est coupé en morceaux de [taille], CHACUN chiffré séparément et
// déposé comme un message. Le serveur de boîte aux lettres relaie des
// charges opaques sans limite de taille : aucun redéploiement nécessaire.
//
// ⚠️ CHAQUE MORCEAU EST ÉCRIT SUR LE DISQUE AVANT D'ÊTRE ACQUITTÉ. Garder les
// morceaux en mémoire aurait perdu un fichier à moitié reçu si l'app était
// fermée ; ne pas les acquitter aurait fait retélécharger TOUS les morceaux
// à chaque relève (toutes les 4 secondes) pendant l'envoi.
// ============================================================================

import 'dart:io';
import 'dart:typed_data';

/// Découpage et limites des fichiers envoyés par Internet.
class FichierEnLigne {
  FichierEnLigne._();

  /// Taille d'un morceau (avant chiffrement). 192 Kio → ~256 Ko une fois
  /// chiffré et encodé en base64 : chaque dépôt reste modeste.
  static const int taille = 192 * 1024;

  /// Plafond d'un fichier par Internet. La boîte aux lettres garde ses dépôts
  /// en mémoire (jusqu'à 7 jours) pour tous les utilisateurs du serveur :
  /// 16 Mio couvre les photos et les vidéos courtes sans la mettre en péril.
  static const int maximum = 16 * 1024 * 1024;

  /// Nombre maximal de morceaux acceptés à la réception — refuse un `t`
  /// délirant envoyé par un pair malveillant.
  static int get maxMorceaux => (maximum / taille).ceil();

  /// Coupe [octets] en morceaux de [tailleMorceau] (le dernier peut être plus
  /// court). Un fichier vide donne un seul morceau vide.
  static List<Uint8List> decouper(Uint8List octets, {int tailleMorceau = taille}) {
    if (octets.isEmpty) return [Uint8List(0)];
    final morceaux = <Uint8List>[];
    for (var debut = 0; debut < octets.length; debut += tailleMorceau) {
      final fin = (debut + tailleMorceau).clamp(0, octets.length);
      morceaux.add(Uint8List.sublistView(octets, debut, fin));
    }
    return morceaux;
  }
}

/// Réassemble, sur le disque, les morceaux d'un fichier reçu par Internet.
class AssemblageEnLigne {
  AssemblageEnLigne(this.racine);

  /// Dossier de travail (un sous-dossier par fichier en cours de réception).
  final Directory racine;

  static final RegExp _idSur = RegExp(r'^[A-Za-z0-9_-]{1,128}$');

  /// Vrai si le couple (index, total) est plausible et l'identifiant sans
  /// danger pour un nom de dossier.
  static bool valide(String fichierId, int index, int total) =>
      _idSur.hasMatch(fichierId) &&
      total >= 1 &&
      total <= FichierEnLigne.maxMorceaux &&
      index >= 0 &&
      index < total;

  Directory _dossier(String fichierId) =>
      Directory('${racine.path}${Platform.pathSeparator}$fichierId');

  File _morceau(String fichierId, int index) =>
      File('${_dossier(fichierId).path}${Platform.pathSeparator}$index.part');

  /// Enregistre un morceau (idempotent : un doublon réécrit le même contenu).
  /// Renvoie la progression de la réception, entre 0 et 1.
  /// Lève [ArgumentError] si le morceau est invalide.
  Future<double> ajouter(String fichierId, int index, int total, Uint8List octets) async {
    if (!valide(fichierId, index, total)) {
      throw ArgumentError('morceau invalide: $fichierId $index/$total');
    }
    final dossier = _dossier(fichierId);
    await dossier.create(recursive: true);
    // Écriture dans un fichier temporaire puis renommage : un morceau à moitié
    // écrit (app tuée) n'est jamais pris pour un morceau complet.
    final cible = _morceau(fichierId, index);
    final temporaire = File('${cible.path}.tmp');
    await temporaire.writeAsBytes(octets, flush: true);
    await temporaire.rename(cible.path);
    return (await recus(fichierId, total)) / total;
  }

  /// Nombre de morceaux distincts déjà enregistrés.
  Future<int> recus(String fichierId, int total) async {
    var n = 0;
    for (var i = 0; i < total; i++) {
      if (await _morceau(fichierId, i).exists()) n++;
    }
    return n;
  }

  /// Si TOUS les morceaux sont là : les concatène dans l'ordre, supprime le
  /// dossier de travail et renvoie le contenu. Sinon `null`.
  Future<Uint8List?> assembler(String fichierId, int total) async {
    if (!_idSur.hasMatch(fichierId)) return null;
    if (await recus(fichierId, total) != total) return null;
    final tout = BytesBuilder(copy: false);
    for (var i = 0; i < total; i++) {
      tout.add(await _morceau(fichierId, i).readAsBytes());
    }
    await abandonner(fichierId);
    return tout.takeBytes();
  }

  /// Supprime les morceaux d'un fichier (réception terminée ou abandonnée).
  Future<void> abandonner(String fichierId) async {
    if (!_idSur.hasMatch(fichierId)) return;
    final dossier = _dossier(fichierId);
    if (await dossier.exists()) await dossier.delete(recursive: true);
  }
}
