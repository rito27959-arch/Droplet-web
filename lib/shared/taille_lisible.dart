// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// « 1,4 Mo » — une taille de fichier écrite comme on l'écrit en français,
// avec la virgule décimale.
//
// ⚠️ IL VIVAIT DANS `stockage_screen.dart`, un écran. Un deuxième écran qui
// en a besoin aurait eu deux choix, tous deux mauvais : importer un écran
// depuis un autre écran, ou recopier la fonction. La recopie est le défaut
// « deux sources de vérité » que cette application corrige partout
// ailleurs : les deux copies divergent au premier changement d'unité, et
// on lit « 1,4 Mo » à un endroit et « 1.4 MB » à l'autre.
// ============================================================================

/// « 1,4 Mo », à la française (virgule décimale).
String tailleLisible(int octets) {
  const unites = ['o', 'Ko', 'Mo', 'Go'];
  var valeur = octets.toDouble();
  var i = 0;
  while (valeur >= 1024 && i < unites.length - 1) {
    valeur /= 1024;
    i++;
  }
  // En dessous du kilo-octet, et au-dessus de cent, la décimale n'apprend
  // rien : « 847 o » et « 128 Mo » se lisent mieux que « 847,0 o » et
  // « 128,4 Mo ».
  final texte =
      i == 0 || valeur >= 100 ? valeur.toStringAsFixed(0) : valeur.toStringAsFixed(1);
  return '${texte.replaceAll('.', ',')} ${unites[i]}';
}
