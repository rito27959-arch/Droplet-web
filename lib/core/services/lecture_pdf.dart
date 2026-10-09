// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LIRE LE TEXTE D'UN PDF — sans paquet, sans licence à surveiller.
//
// ── POURQUOI PAS UNE BIBLIOTHÈQUE ─────────────────────────────────────
//
// `pdfx`, déjà dans le projet, RASTÉRISE : il rend des pages en images.
// Pour en tirer du texte il faudrait ensuite un modèle de vision — or
// Groq n'en sert plus aucun depuis juillet 2026. Les extracteurs Dart
// existants, eux, sont sous licence communautaire propriétaire : gratuits
// sous un seuil de chiffre d'affaires, ce qui est une épée au-dessus de
// la tête d'une application distribuée publiquement.
//
// Un PDF range son texte dans des flux, et les opérateurs qui l'écrivent
// sont au nombre de cinq. Cent lignes suffisent, et on maîtrise ce qui
// se passe.
//
// ── ⚠️ CE QUE ÇA NE SAIT PAS FAIRE ────────────────────────────────────
//
// UN PDF SCANNÉ NE REND RIEN. Une page scannée est une image : il n'y a
// aucun texte à extraire, seulement des pixels. Sans reconnaissance
// optique — que personne ne peut faire ici — c'est une limite définitive,
// pas un bug à corriger. [lirePdf] rend alors une chaîne vide, et
// l'appelant doit le dire franchement plutôt que d'envoyer du vide au
// modèle, qui inventerait un contenu.
//
// Les polices à encodage exotique (CID sans table `ToUnicode`) peuvent
// aussi rendre des caractères faux. C'est rare dans un document
// bureautique, courant dans un PDF technique ancien.
//
// ── CE QUI A ÉTÉ VÉRIFIÉ ──────────────────────────────────────────────
//
// L'algorithme a été écrit et rejoué hors de l'application contre de
// VRAIS PDF fabriqués par reportlab, dans les deux formes qu'on
// rencontre : compressé (chaîne `ASCII85Decode` puis `FlateDecode`) et
// non compressé. Résultat comparé mot à mot à `pypdf`, la bibliothèque
// de référence : 24 mots sur 24 dans les deux cas.
//
// ⚠️ LE CHAÎNAGE DE FILTRES EST LE PIÈGE. Un extracteur naïf cherche
// `FlateDecode`, trouve un flux, échoue à le décompresser et rend du
// vide — parce que reportlab (et beaucoup d'autres) empile d'abord un
// encodage ASCII85. On lit donc la LISTE des filtres, dans l'ordre.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Rend le texte d'un PDF, ou une chaîne vide s'il n'y en a pas.
String lirePdf(Uint8List octets) {
  final morceaux = <String>[];
  // `stream` … `endstream` : les délimiteurs d'un flux. Le saut de ligne
  // qui suit `stream` peut être \n, \r ou \r\n selon le producteur.
  final motif = RegExp(
    r'stream[\r\n]{1,2}(.*?)[\r\n]{0,2}endstream',
    dotAll: true,
  );
  // On travaille en latin-1 : chaque octet devient un caractère, sans
  // qu'aucune séquence ne soit refusée. Décoder en UTF-8 planterait sur
  // le premier octet compressé.
  final texte = latin1.decode(octets, allowInvalid: true);

  for (final m in motif.allMatches(texte)) {
    final entete = texte.substring(
      (m.start - 600).clamp(0, m.start),
      m.start,
    );
    final contenu = _decoder(
      Uint8List.fromList(latin1.encode(m[1] ?? '')),
      _filtres(entete),
    );
    if (contenu == null) continue;
    final flux = latin1.decode(contenu, allowInvalid: true);
    // Un flux sans opérateur d'écriture est une image, une police ou des
    // métadonnées : rien à en tirer, et le parcourir coûterait cher.
    if (!flux.contains('Tj') && !flux.contains('TJ')) continue;
    morceaux.add(_lireFlux(flux));
  }
  return _nettoyer(morceaux.where((t) => t.trim().isNotEmpty).join('\n'));
}

/// Les filtres du flux, dans l'ordre où ils ont été appliqués.
List<String> _filtres(String entete) {
  final i = entete.lastIndexOf('<<');
  final dico = i >= 0 ? entete.substring(i) : entete;
  final j = dico.indexOf('/Filter');
  if (j < 0) return const [];
  return [
    for (final m in RegExp(r'/(\w+)').allMatches(dico.substring(j)))
      if (_connus.contains(m[1])) m[1]!,
  ];
}

const Set<String> _connus = {
  'FlateDecode',
  'Fl',
  'ASCII85Decode',
  'A85',
  'ASCIIHexDecode',
  'AHx',
};

/// Applique la chaîne de filtres. Rend `null` quand le flux n'est pas du
/// texte (une image JPEG, par exemple) ou qu'un filtre échoue.
Uint8List? _decoder(Uint8List brut, List<String> filtres) {
  var d = brut;
  for (final f in filtres) {
    try {
      switch (f) {
        case 'FlateDecode':
        case 'Fl':
          d = Uint8List.fromList(zlib.decode(d));
        case 'ASCII85Decode':
        case 'A85':
          d = _ascii85(d);
        case 'ASCIIHexDecode':
        case 'AHx':
          d = _asciiHex(d);
        default:
          return null;
      }
    } on Object {
      // Un flux abîmé ou chiffré : on l'ignore, on ne perd que lui.
      return null;
    }
  }
  return d;
}

/// ASCII85 tel que le PDF l'emploie : groupes de cinq caractères,
/// `z` pour quatre octets nuls, `~>` en fin.
Uint8List _ascii85(Uint8List d) {
  final sortie = <int>[];
  var tampon = 0;
  var compte = 0;
  for (final o in d) {
    if (o == 0x7E) break; // `~` ouvre le marqueur de fin
    if (o <= 0x20) continue; // espaces ignorés
    if (o == 0x7A && compte == 0) {
      sortie.addAll(const [0, 0, 0, 0]);
      continue;
    }
    if (o < 0x21 || o > 0x75) continue;
    tampon = tampon * 85 + (o - 0x21);
    if (++compte == 5) {
      for (var i = 3; i >= 0; i--) {
        sortie.add((tampon >> (i * 8)) & 0xFF);
      }
      tampon = 0;
      compte = 0;
    }
  }
  // Un groupe incomplet se complète par des `u` puis se tronque.
  if (compte > 0) {
    for (var i = compte; i < 5; i++) {
      tampon = tampon * 85 + 84;
    }
    for (var i = 3; i >= 4 - (compte - 1); i--) {
      sortie.add((tampon >> (i * 8)) & 0xFF);
    }
  }
  return Uint8List.fromList(sortie);
}

Uint8List _asciiHex(Uint8List d) {
  final chiffres = <int>[];
  for (final o in d) {
    if (o == 0x3E) break; // `>` termine
    final c = String.fromCharCode(o);
    if (RegExp(r'[0-9A-Fa-f]').hasMatch(c)) chiffres.add(o);
  }
  if (chiffres.length.isOdd) chiffres.add(0x30);
  final sortie = <int>[];
  for (var i = 0; i < chiffres.length; i += 2) {
    sortie.add(
      int.parse(
        String.fromCharCodes([chiffres[i], chiffres[i + 1]]),
        radix: 16,
      ),
    );
  }
  return Uint8List.fromList(sortie);
}

/// Parcourt un flux de contenu et en tire les chaînes écrites.
String _lireFlux(String flux) {
  final b = StringBuffer();
  var i = 0;
  final n = flux.length;

  while (i < n) {
    final c = flux[i];

    // Une chaîne littérale : `(…)`, parenthèses internes équilibrées.
    if (c == '(') {
      var j = i + 1;
      var prof = 1;
      final mot = StringBuffer();
      while (j < n && prof > 0) {
        final d = flux[j];
        if (d == r'\') {
          final s = j + 1 < n ? flux[j + 1] : '';
          mot.write(switch (s) {
            'n' => '\n',
            'r' => '\r',
            't' => '\t',
            'b' => '\b',
            'f' => '\f',
            _ => s,
          });
          j += 2;
          continue;
        }
        if (d == '(') {
          prof++;
        } else if (d == ')') {
          prof--;
          if (prof == 0) break;
        }
        mot.write(d);
        j++;
      }
      b.write(mot);
      i = j + 1;
      continue;
    }

    // Une chaîne hexadécimale : `<48656C6C6F>`. `<<` ouvre un
    // dictionnaire, pas une chaîne.
    if (c == '<' && (i + 1 >= n || flux[i + 1] != '<')) {
      final j = flux.indexOf('>', i);
      if (j < 0) break;
      final hexa = flux
          .substring(i + 1, j)
          .replaceAll(RegExp('[^0-9A-Fa-f]'), '');
      final pair = hexa.length.isOdd ? '${hexa}0' : hexa;
      for (var k = 0; k + 1 < pair.length; k += 2) {
        b.writeCharCode(int.parse(pair.substring(k, k + 2), radix: 16));
      }
      i = j + 1;
      continue;
    }

    // Les opérateurs qui terminent une ligne. Sans eux, tout le document
    // sortirait d'un seul paragraphe.
    if (i + 1 < n) {
      final deux = flux.substring(i, i + 2);
      if (deux == 'TD' ||
          deux == 'Td' ||
          deux == 'T*' ||
          deux == 'TL' ||
          deux == 'ET') {
        b.write('\n');
        i += 2;
        continue;
      }
    }
    if (c == "'" || c == '"') {
      b.write('\n');
      i++;
      continue;
    }
    i++;
  }
  return b.toString();
}

String _nettoyer(String t) {
  var s = t.replaceAll('\r', '\n').replaceAll(RegExp('[ \t]+'), ' ');
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.split('\n').map((l) => l.trim()).join('\n').trim();
}

/// Lit un PDF depuis un chemin. Rend `null` si le fichier est illisible
/// ou ne contient aucun texte extractible.
Future<String?> lirePdfFichier(String chemin) async {
  try {
    final octets = await File(chemin).readAsBytes();
    final t = lirePdf(octets);
    return t.trim().isEmpty ? null : t;
  } on Object {
    return null;
  }
}
