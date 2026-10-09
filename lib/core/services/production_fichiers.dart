// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES FICHIERS QUE L'ASSISTANT PRODUIT — txt, md, csv, json, html, code,
// pdf, docx, pptx et zip.
//
// ── POURQUOI ÉCRIRE LE DOCX ET LE PPTX À LA MAIN ──────────────────────
//
// Aucun paquet Dart ne les écrit correctement : `docx_template` exige un
// modèle préexistant, et il n'existe rien de sérieux pour le pptx. Or ces
// deux formats sont des ARCHIVES ZIP CONTENANT DU XML — c'est-à-dire du
// texte, que `archive` sait empaqueter. Les composer à la main coûte
// quelques constantes et évite une dépendance qu'il faudrait suivre.
//
// ⚠️ LE XML CI-DESSOUS A ÉTÉ VÉRIFIÉ, PAS DEVINÉ. Il a été produit à
// l'identique hors de l'application et ouvert par `python-docx` et
// `python-pptx`, les bibliothèques de référence — celles qui refusent ce
// que Word et PowerPoint refusent. Le pptx a été le plus exigeant : il
// veut un masque, une disposition ET un thème complet, même pour une
// diapositive vide, et il refuse le fichier s'il en manque un.
//
// Toute modification de ces constantes doit être revalidée de la même
// façon. Un OOXML légèrement faux ne produit pas d'erreur : il produit un
// fichier qu'Office déclare « endommagé » à l'ouverture, chez la personne.
//
// ── LE PDF ────────────────────────────────────────────────────────────
//
// Celui-là passe par le paquet `pdf`, parce qu'un PDF n'est pas du texte
// et que le composer à la main demanderait de gérer les polices, les
// encodages et la table des objets. Ce n'est pas le même marché.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Produit le fichier et rend son chemin.
///
/// [nom] est celui que le modèle a choisi ; il est nettoyé avant de
/// toucher le disque.
Future<String> produireFichier({
  required String nom,
  required String format,
  required String contenu,
}) async {
  final dossier = Directory(
    p.join((await getApplicationDocumentsDirectory()).path, 'assistant'),
  );
  if (!dossier.existsSync()) dossier.createSync(recursive: true);
  final chemin = _cheminLibre(dossier.path, nom, format);

  switch (format) {
    case 'pdf':
      await File(chemin).writeAsBytes(await _pdf(contenu));
    case 'docx':
      await File(chemin).writeAsBytes(_docx(contenu));
    case 'pptx':
      await File(chemin).writeAsBytes(_pptx(contenu));
    case 'zip':
      await File(chemin).writeAsBytes(_zip(contenu));
    default:
      await File(chemin).writeAsString(contenu);
  }
  return chemin;
}

/// Un nom de fichier sûr, et qui n'écrase rien.
///
/// ⚠️ LE NOM VIENT DU MODÈLE. Il pourrait contenir un `/`, un `..`, ou
/// des caractères que le système de fichiers refuse. On ne garde que le
/// dernier segment et on remplace tout le reste — un fichier écrit hors
/// du dossier prévu serait une faille, pas un désagrément.
String _cheminLibre(String dossier, String nom, String format) {
  var base = nom.split(RegExp(r'[/\\]')).last;
  base = base.replaceAll(RegExp(r'[^\w .\-()À-ɏ]'), '_').trim();
  if (base.isEmpty || base == '.' || base == '..') base = 'fichier';
  final ext = _extension(format);
  if (!base.toLowerCase().endsWith('.$ext')) {
    final point = base.lastIndexOf('.');
    base = '${point > 0 ? base.substring(0, point) : base}.$ext';
  }
  var chemin = p.join(dossier, base);
  if (!File(chemin).existsSync()) return chemin;
  // Deux « rapport.pdf » dans la même conversation ne doivent pas se
  // remplacer l'un l'autre en silence.
  final sansExt = base.substring(0, base.length - ext.length - 1);
  for (var i = 2; i < 1000; i++) {
    chemin = p.join(dossier, '$sansExt ($i).$ext');
    if (!File(chemin).existsSync()) return chemin;
  }
  return chemin;
}

String _extension(String format) => switch (format) {
      'code' => 'txt',
      _ => format,
    };

// ══ PDF ═════════════════════════════════════════════════════════════════

Future<List<int>> _pdf(String markdown) async {
  final doc = pw.Document();
  final blocs = _lireMarkdown(markdown);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (context) => [
        for (final b in blocs)
          switch (b.genre) {
            _Genre.titre1 => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
                child: pw.Text(
                  b.texte,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            _Genre.titre2 => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
                child: pw.Text(
                  b.texte,
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            _Genre.titre3 => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
                child: pw.Text(
                  b.texte,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            _Genre.puce => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 14, bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• '),
                    pw.Expanded(
                      child: pw.Text(
                        b.texte,
                        style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
                      ),
                    ),
                  ],
                ),
              ),
            _Genre.code => pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.symmetric(vertical: 6),
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey200,
                child: pw.Text(
                  b.texte,
                  style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
                ),
              ),
            _Genre.paragraphe => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  b.texte,
                  style: const pw.TextStyle(fontSize: 11, lineSpacing: 2.5),
                ),
              ),
          },
      ],
    ),
  );
  return doc.save();
}

/// Empaquette un projet : plusieurs fichiers, leurs dossiers, et un
/// index lisible.
///
/// ⚠️ ON AJOUTE UN `LISEZ_MOI.txt` SI LE MODÈLE N'EN A PAS MIS. Une
/// archive de quinze fichiers sans point d'entrée, c'est quinze fichiers
/// à ouvrir un par un pour comprendre ce qu'on a reçu. Il coûte trois
/// lignes et il évite ça.
Future<String> creerProjet({
  required String nom,
  required Map<String, String> fichiers,
}) async {
  final dossier = Directory(
    p.join((await getApplicationDocumentsDirectory()).path, 'assistant'),
  );
  if (!dossier.existsSync()) dossier.createSync(recursive: true);
  final chemin = _cheminLibre(dossier.path, nom, 'zip');

  final archive = Archive();
  final index = StringBuffer('$nom\n\n');
  final cles = fichiers.keys.toList()..sort();
  var aUnIndex = false;

  for (final brut in cles) {
    // ⚠️ AUCUN CHEMIN NE SORT DE L'ARCHIVE. `..` et les chemins absolus
    // sont retirés : une archive qui écrit ailleurs qu'en elle-même est
    // une faille bien connue, et le contenu vient d'un modèle.
    final sur = brut
        .replaceAll('\\', '/')
        .split('/')
        .where((x) => x.isNotEmpty && x != '.' && x != '..')
        .join('/');
    if (sur.isEmpty) continue;
    final bas = sur.toLowerCase();
    if (bas.endsWith('readme.md') ||
        bas.endsWith('readme.txt') ||
        bas.endsWith('lisez_moi.txt')) {
      aUnIndex = true;
    }
    final octets = utf8.encode(fichiers[brut]!);
    archive.addFile(ArchiveFile(sur, octets.length, octets));
    index.writeln(sur);
  }

  if (!aUnIndex) {
    final octets = utf8.encode(index.toString());
    archive.addFile(ArchiveFile('LISEZ_MOI.txt', octets.length, octets));
  }

  await File(chemin).writeAsBytes(ZipEncoder().encode(archive) ?? const []);
  return chemin;
}

// ══ ZIP ═════════════════════════════════════════════════════════════════

/// [contenu] est un objet JSON : chaque clé est un chemin dans
/// l'archive, chaque valeur son contenu.
List<int> _zip(String contenu) {
  final archive = Archive();
  Map<String, dynamic> entrees;
  try {
    final v = jsonDecode(contenu);
    entrees = v is Map<String, dynamic> ? v : {'contenu.txt': contenu};
  } on FormatException {
    // Le modèle n'a pas rendu du JSON : plutôt qu'une archive vide, on
    // met ce qu'il a écrit dans un fichier. Une archive qui contient
    // quelque chose vaut mieux qu'une erreur.
    entrees = {'contenu.txt': contenu};
  }
  entrees.forEach((chemin, valeur) {
    final sur = chemin
        .replaceAll('\\', '/')
        .split('/')
        .where((s) => s.isNotEmpty && s != '.' && s != '..')
        .join('/');
    if (sur.isEmpty) return;
    final octets = utf8.encode('$valeur');
    archive.addFile(ArchiveFile(sur, octets.length, octets));
  });
  return ZipEncoder().encode(archive) ?? const [];
}

// ══ LE MARKDOWN, LU UNE SEULE FOIS POUR TOUT LE MONDE ═══════════════════

enum _Genre { titre1, titre2, titre3, puce, code, paragraphe }

class _Bloc {
  const _Bloc(this.genre, this.texte);
  final _Genre genre;
  final String texte;
}

/// ⚠️ UN SEUL ANALYSEUR POUR LE PDF, LE DOCX ET LE PPTX. Trois lectures
/// séparées finiraient par diverger, et le même Markdown donnerait trois
/// mises en page différentes selon le bouton choisi.
List<_Bloc> _lireMarkdown(String source) {
  final blocs = <_Bloc>[];
  final lignes = source.split('\n');
  var dansCode = false;
  final code = StringBuffer();

  for (final brute in lignes) {
    final l = brute.trimRight();
    if (l.trimLeft().startsWith('```')) {
      if (dansCode) {
        blocs.add(_Bloc(_Genre.code, code.toString().trimRight()));
        code.clear();
      }
      dansCode = !dansCode;
      continue;
    }
    if (dansCode) {
      code.writeln(brute);
      continue;
    }
    if (l.trim().isEmpty) continue;

    final titre = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(l);
    if (titre != null) {
      final n = titre[1]!.length;
      blocs.add(_Bloc(
        n == 1 ? _Genre.titre1 : (n == 2 ? _Genre.titre2 : _Genre.titre3),
        _sansBalises(titre[2]!),
      ));
      continue;
    }
    final puce = RegExp(r'^\s*[-*+]\s+(.*)$').firstMatch(l);
    if (puce != null) {
      blocs.add(_Bloc(_Genre.puce, _sansBalises(puce[1]!)));
      continue;
    }
    blocs.add(_Bloc(_Genre.paragraphe, _sansBalises(l)));
  }
  if (dansCode && code.isNotEmpty) {
    // Un bloc de code jamais refermé : on le garde quand même.
    blocs.add(_Bloc(_Genre.code, code.toString().trimRight()));
  }
  return blocs;
}

/// Retire le balisage en ligne pour le PDF et le pptx, qui n'ont pas de
/// rendu enrichi ici. Le docx, lui, le convertit en vrais styles.
String _sansBalises(String s) => s
    .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1] ?? '')
    .replaceAllMapped(RegExp(r'(?<![\w*])\*([^*]+?)\*'), (m) => m[1] ?? '')
    .replaceAllMapped(RegExp(r'`+([^`]+)`+'), (m) => m[1] ?? '')
    .replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (m) => '${m[1]} (${m[2]})',
    );

/// Échappe pour du XML. `"` compris : il apparaît dans les attributs.
String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

const String _decl = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
const String _nsRel =
    'http://schemas.openxmlformats.org/package/2006/relationships';
const String _nsR =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

List<int> _empaqueter(Map<String, String> fichiers) {
  final archive = Archive();
  fichiers.forEach((chemin, contenu) {
    final octets = utf8.encode(contenu);
    archive.addFile(ArchiveFile(chemin, octets.length, octets));
  });
  return ZipEncoder().encode(archive) ?? const [];
}

// ══ DOCX ════════════════════════════════════════════════════════════════

const String _nsW =
    'http://schemas.openxmlformats.org/wordprocessingml/2006/main';

List<int> _docx(String markdown) => _empaqueter({
      '[Content_Types].xml': '$_decl'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="xml" ContentType="application/xml"/>'
          '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
          '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
          '</Types>',
      '_rels/.rels': '$_decl<Relationships xmlns="$_nsRel">'
          '<Relationship Id="rId1" Type="$_nsR/officeDocument" Target="word/document.xml"/>'
          '</Relationships>',
      'word/_rels/document.xml.rels': '$_decl<Relationships xmlns="$_nsRel">'
          '<Relationship Id="rId1" Type="$_nsR/styles" Target="styles.xml"/>'
          '</Relationships>',
      'word/styles.xml': _docxStyles(),
      'word/document.xml': _docxCorps(markdown),
    });

String _docxStyles() {
  final b = StringBuffer(_decl)
    ..write('<w:styles xmlns:w="$_nsW">')
    ..write('<w:docDefaults><w:rPrDefault><w:rPr>'
        '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/>'
        '</w:rPr></w:rPrDefault></w:docDefaults>')
    ..write('<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
        '<w:name w:val="Normal"/></w:style>');
  const tailles = {1: 32, 2: 26, 3: 24};
  tailles.forEach((n, taille) {
    b.write('<w:style w:type="paragraph" w:styleId="Heading$n">'
        '<w:name w:val="heading $n"/><w:basedOn w:val="Normal"/>'
        '<w:pPr><w:outlineLvl w:val="${n - 1}"/>'
        '<w:spacing w:before="240" w:after="120"/></w:pPr>'
        '<w:rPr><w:b/><w:sz w:val="$taille"/></w:rPr></w:style>');
  });
  b
    ..write('<w:style w:type="paragraph" w:styleId="ListParagraph">'
        '<w:name w:val="List Paragraph"/><w:basedOn w:val="Normal"/>'
        '<w:pPr><w:ind w:left="720"/></w:pPr></w:style>')
    ..write('</w:styles>');
  return b.toString();
}

/// `**gras**`, `*italique*` et `` `code` `` deviennent de vraies séries
/// Word — c'est le seul format des trois qui sait les porter.
String _docxSeries(String texte) {
  final motif = RegExp(r'\*\*(.+?)\*\*|(?<![\w*])\*([^*]+?)\*|`+([^`]+)`+');
  final b = StringBuffer();
  var i = 0;
  void serie(String t, String pr) {
    if (t.isEmpty) return;
    b.write('<w:r>${pr.isEmpty ? '' : '<w:rPr>$pr</w:rPr>'}'
        '<w:t xml:space="preserve">${_xml(t)}</w:t></w:r>');
  }

  for (final m in motif.allMatches(texte)) {
    if (m.start > i) serie(texte.substring(i, m.start), '');
    if (m[1] != null) {
      serie(m[1]!, '<w:b/>');
    } else if (m[2] != null) {
      serie(m[2]!, '<w:i/>');
    } else {
      serie(m[3]!, '<w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/>');
    }
    i = m.end;
  }
  if (i < texte.length) serie(texte.substring(i), '');
  final s = b.toString();
  // Un paragraphe sans aucune série est invalide.
  return s.isEmpty ? '<w:r><w:t/></w:r>' : s;
}

String _docxCorps(String markdown) {
  final b = StringBuffer(_decl)
    ..write('<w:document xmlns:w="$_nsW"><w:body>');

  // ⚠️ LE DOCX RELIT LE MARKDOWN BRUT, pas les blocs nettoyés : lui seul
  // sait rendre le gras et l'italique, et `_lireMarkdown` les a retirés.
  var dansCode = false;
  for (final brute in markdown.split('\n')) {
    final l = brute.trimRight();
    if (l.trimLeft().startsWith('```')) {
      dansCode = !dansCode;
      continue;
    }
    if (l.trim().isEmpty) {
      b.write('<w:p/>');
      continue;
    }
    if (dansCode) {
      b.write('<w:p><w:r>'
          '<w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/></w:rPr>'
          '<w:t xml:space="preserve">${_xml(brute)}</w:t></w:r></w:p>');
      continue;
    }
    final titre = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(l);
    if (titre != null) {
      b.write('<w:p><w:pPr><w:pStyle w:val="Heading${titre[1]!.length}"/>'
          '</w:pPr>${_docxSeries(titre[2]!)}</w:p>');
      continue;
    }
    final puce = RegExp(r'^\s*[-*+]\s+(.*)$').firstMatch(l);
    if (puce != null) {
      b.write('<w:p><w:pPr><w:pStyle w:val="ListParagraph"/></w:pPr>'
          '<w:r><w:t xml:space="preserve">• </w:t></w:r>'
          '${_docxSeries(puce[1]!)}</w:p>');
      continue;
    }
    b.write('<w:p>${_docxSeries(l)}</w:p>');
  }

  b
    ..write('<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134"/>'
        '</w:sectPr>')
    ..write('</w:body></w:document>');
  return b.toString();
}

// ══ PPTX ════════════════════════════════════════════════════════════════

const String _nsA = 'http://schemas.openxmlformats.org/drawingml/2006/main';
const String _nsP =
    'http://schemas.openxmlformats.org/presentationml/2006/main';

/// L'arbre de formes minimal que le masque et la disposition exigent.
const String _pptxArbreVide =
    '<p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/>'
    '<p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm>'
    '<a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
    '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm>'
    '</p:grpSpPr></p:spTree></p:cSld>';

const String _pptxCorrespondance =
    'bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" '
    'accent2="accent2" accent3="accent3" accent4="accent4" '
    'accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"';

class _Diapo {
  const _Diapo(this.titre, this.points);
  final String titre;
  final List<String> points;
}

List<_Diapo> _decouperDiapos(String markdown) {
  final diapos = <_Diapo>[];
  String? titre;
  var points = <String>[];
  var dansCode = false;

  for (final brute in markdown.split('\n')) {
    final l = brute.trim();
    if (l.startsWith('```')) {
      dansCode = !dansCode;
      continue;
    }
    if (dansCode) {
      if (l.isNotEmpty && titre != null) points.add(l);
      continue;
    }
    final t = RegExp(r'^#{1,2}\s+(.*)$').firstMatch(l);
    if (t != null) {
      if (titre != null) diapos.add(_Diapo(titre, points));
      titre = _sansBalises(t[1]!);
      points = <String>[];
      continue;
    }
    final puce = RegExp(r'^[-*+]\s+(.*)$').firstMatch(l);
    if (puce != null) {
      points.add(_sansBalises(puce[1]!));
    } else if (l.isNotEmpty && titre != null) {
      points.add(_sansBalises(l));
    }
  }
  if (titre != null) diapos.add(_Diapo(titre, points));
  // Un Markdown sans le moindre titre doit quand même donner une diapo,
  // sinon le fichier n'a aucune diapositive et PowerPoint le refuse.
  return diapos.isEmpty
      ? [_Diapo(markdown.trim().split('\n').first, const [])]
      : diapos;
}

List<int> _pptx(String markdown) {
  final diapos = _decouperDiapos(markdown);
  final n = diapos.length;

  final types = StringBuffer(_decl)
    ..write('<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>'
        '<Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>'
        '<Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>'
        '<Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>');
  for (var i = 1; i <= n; i++) {
    types.write('<Override PartName="/ppt/slides/slide$i.xml" '
        'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>');
  }
  types.write('</Types>');

  final ids = StringBuffer();
  final relsPres = StringBuffer(
    '<Relationship Id="rId1" Type="$_nsR/slideMaster" '
    'Target="slideMasters/slideMaster1.xml"/>',
  );
  for (var i = 0; i < n; i++) {
    ids.write('<p:sldId id="${256 + i}" r:id="rId${i + 2}"/>');
    relsPres.write('<Relationship Id="rId${i + 2}" Type="$_nsR/slide" '
        'Target="slides/slide${i + 1}.xml"/>');
  }
  relsPres.write('<Relationship Id="rId${n + 2}" Type="$_nsR/theme" '
      'Target="theme/theme1.xml"/>');

  final fichiers = <String, String>{
    '[Content_Types].xml': types.toString(),
    '_rels/.rels': '$_decl<Relationships xmlns="$_nsRel">'
        '<Relationship Id="rId1" Type="$_nsR/officeDocument" '
        'Target="ppt/presentation.xml"/></Relationships>',
    // 12192000 x 6858000 EMU = 16:9, la seule proportion qu'on
    // projette encore.
    'ppt/presentation.xml': '$_decl'
        '<p:presentation xmlns:a="$_nsA" xmlns:r="$_nsR" xmlns:p="$_nsP">'
        '<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/>'
        '</p:sldMasterIdLst><p:sldIdLst>$ids</p:sldIdLst>'
        '<p:sldSz cx="12192000" cy="6858000"/>'
        '<p:notesSz cx="6858000" cy="9144000"/></p:presentation>',
    'ppt/_rels/presentation.xml.rels':
        '$_decl<Relationships xmlns="$_nsRel">$relsPres</Relationships>',
    'ppt/slideMasters/slideMaster1.xml': '$_decl'
        '<p:sldMaster xmlns:a="$_nsA" xmlns:r="$_nsR" xmlns:p="$_nsP">'
        '$_pptxArbreVide<p:clrMap $_pptxCorrespondance/>'
        '<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/>'
        '</p:sldLayoutIdLst></p:sldMaster>',
    'ppt/slideMasters/_rels/slideMaster1.xml.rels':
        '$_decl<Relationships xmlns="$_nsRel">'
            '<Relationship Id="rId1" Type="$_nsR/slideLayout" '
            'Target="../slideLayouts/slideLayout1.xml"/>'
            '<Relationship Id="rId2" Type="$_nsR/theme" '
            'Target="../theme/theme1.xml"/></Relationships>',
    'ppt/slideLayouts/slideLayout1.xml': '$_decl'
        '<p:sldLayout xmlns:a="$_nsA" xmlns:r="$_nsR" xmlns:p="$_nsP" '
        'type="blank" preserve="1">$_pptxArbreVide</p:sldLayout>',
    'ppt/slideLayouts/_rels/slideLayout1.xml.rels':
        '$_decl<Relationships xmlns="$_nsRel">'
            '<Relationship Id="rId1" Type="$_nsR/slideMaster" '
            'Target="../slideMasters/slideMaster1.xml"/></Relationships>',
    'ppt/theme/theme1.xml': _pptxTheme(),
  };

  for (var i = 0; i < n; i++) {
    fichiers['ppt/slides/slide${i + 1}.xml'] = _pptxDiapo(diapos[i]);
    fichiers['ppt/slides/_rels/slide${i + 1}.xml.rels'] =
        '$_decl<Relationships xmlns="$_nsRel">'
        '<Relationship Id="rId1" Type="$_nsR/slideLayout" '
        'Target="../slideLayouts/slideLayout1.xml"/></Relationships>';
  }
  return _empaqueter(fichiers);
}

/// ⚠️ LE THÈME EST OBLIGATOIRE, MÊME INUTILISÉ. PowerPoint refuse le
/// fichier s'il manque, et il veut les douze couleurs, les deux polices
/// ET les trois styles de remplissage, de trait, d'effet et de fond.
String _pptxTheme() {
  String police(String t) => '<a:${t}Font><a:latin typeface="Calibri"/>'
      '<a:ea typeface=""/><a:cs typeface=""/></a:${t}Font>';
  const palette = {
    'dk1': '000000',
    'lt1': 'FFFFFF',
    'dk2': '44546A',
    'lt2': 'E7E6E6',
    'accent1': '4472C4',
    'accent2': 'ED7D31',
    'accent3': 'A5A5A5',
    'accent4': 'FFC000',
    'accent5': '5B9BD5',
    'accent6': '70AD47',
    'hlink': '0563C1',
    'folHlink': '954F72',
  };
  final couleurs = StringBuffer();
  palette.forEach((nom, valeur) {
    couleurs.write('<a:$nom><a:srgbClr val="$valeur"/></a:$nom>');
  });
  const uni = '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>';
  return '$_decl<a:theme xmlns:a="$_nsA" name="Droplet"><a:themeElements>'
      '<a:clrScheme name="Droplet">$couleurs</a:clrScheme>'
      '<a:fontScheme name="Droplet">${police('major')}${police('minor')}'
      '</a:fontScheme><a:fmtScheme name="Droplet">'
      '<a:fillStyleLst>$uni$uni$uni</a:fillStyleLst>'
      '<a:lnStyleLst><a:ln>$uni</a:ln><a:ln>$uni</a:ln><a:ln>$uni</a:ln>'
      '</a:lnStyleLst><a:effectStyleLst>'
      '<a:effectStyle><a:effectLst/></a:effectStyle>'
      '<a:effectStyle><a:effectLst/></a:effectStyle>'
      '<a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>'
      '<a:bgFillStyleLst>$uni$uni$uni</a:bgFillStyleLst>'
      '</a:fmtScheme></a:themeElements></a:theme>';
}

String _pptxZone(
  int id,
  String nom,
  int x,
  int y,
  int cx,
  int cy,
  String paragraphes,
) =>
    '<p:sp><p:nvSpPr><p:cNvPr id="$id" name="${_xml(nom)}"/>'
    '<p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr><p:nvPr/></p:nvSpPr>'
    '<p:spPr><a:xfrm><a:off x="$x" y="$y"/><a:ext cx="$cx" cy="$cy"/></a:xfrm>'
    '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></p:spPr>'
    '<p:txBody><a:bodyPr wrap="square"><a:normAutofit/></a:bodyPr>'
    '<a:lstStyle/>$paragraphes</p:txBody></p:sp>';

String _pptxParagraphe(
  String texte, {
  required int taille,
  bool gras = false,
  bool puce = false,
}) {
  final pPr = puce
      ? '<a:pPr marL="285750" indent="-285750"><a:buChar char="•"/></a:pPr>'
      : '<a:pPr/>';
  return '<a:p>$pPr<a:r><a:rPr lang="fr-FR" sz="$taille"'
      '${gras ? ' b="1"' : ''} dirty="0"/>'
      '<a:t>${_xml(texte)}</a:t></a:r></a:p>';
}

String _pptxDiapo(_Diapo d) {
  final formes = StringBuffer(
    _pptxZone(
      2,
      'Titre',
      838200,
      800100,
      10515600,
      1325563,
      _pptxParagraphe(d.titre, taille: 4000, gras: true),
    ),
  );
  if (d.points.isNotEmpty) {
    final corps = StringBuffer();
    for (final p in d.points) {
      corps.write(_pptxParagraphe(p, taille: 2000, puce: true));
    }
    formes.write(
      _pptxZone(3, 'Contenu', 838200, 2300000, 10515600, 3200000,
          corps.toString()),
    );
  }
  return '$_decl<p:sld xmlns:a="$_nsA" xmlns:r="$_nsR" xmlns:p="$_nsP">'
      '<p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/>'
      '<p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm>'
      '<a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
      '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
      '$formes</p:spTree></p:cSld>'
      '<p:clrMapOvr><a:overrideClrMapping $_pptxCorrespondance/>'
      '</p:clrMapOvr></p:sld>';
}
