// ============================================================================
// LES APERÇUS DE LIENS — titre, description, image et nom du site.
// ----------------------------------------------------------------------------
// Pour les obtenir, le téléphone contacte le site : le site apprend alors
// qu'un message contenant son lien vient d'être ouvert, et depuis quelle
// adresse. C'est pour cela que l'aperçu ne se charge QUE si « En ligne quand
// je suis connecté » est activé — le même interrupteur que la traduction et
// la transcription en ligne, désactivé par défaut. Sinon, l'aperçu se limite
// au domaine, calculé sur place : rien ne sort.
//
// Lecture des balises Open Graph (`og:title`…), puis Twitter, puis `<title>`.
// Les résultats restent en mémoire le temps de la session, et une même
// adresse n'est jamais demandée deux fois en parallèle.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'service_intelligence.dart';

class ApercuLien {
  const ApercuLien({this.titre, this.description, this.image, this.site});

  final String? titre;
  final String? description;
  final String? image;
  final String? site;

  bool get vide => titre == null && description == null && image == null;
}

class ApercusLiens {
  ApercusLiens._();

  static final Map<String, ApercuLien?> _memoire = {};
  static final Map<String, Future<ApercuLien?>> _enCours = {};

  static bool get autorise => ServiceIntelligence.enLigneAutorise;

  /// L'aperçu déjà connu, sans rien charger.
  static ApercuLien? enMemoire(Uri adresse) => _memoire[adresse.toString()];

  static Future<ApercuLien?> charger(Uri adresse) {
    final cle = adresse.toString();
    if (_memoire.containsKey(cle)) return Future.value(_memoire[cle]);
    if (!autorise || (adresse.scheme != 'http' && adresse.scheme != 'https')) {
      return Future.value(null);
    }
    return _enCours[cle] ??= _telecharger(adresse).then((apercu) {
      _memoire[cle] = apercu;
      _enCours.remove(cle);
      return apercu;
    });
  }

  static Future<ApercuLien?> _telecharger(Uri adresse) async {
    try {
      final reponse = await http.get(adresse, headers: const {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 '
            '(KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1',
        'Accept': 'text/html,application/xhtml+xml',
      }).timeout(const Duration(seconds: 6));
      if (reponse.statusCode < 200 || reponse.statusCode >= 300) return null;
      if (!(reponse.headers['content-type'] ?? '').contains('html')) return null;
      final octets = reponse.bodyBytes;
      final html = utf8.decode(
        octets.length > 400000 ? octets.sublist(0, 400000) : octets,
        allowMalformed: true,
      );
      final fin = html.toLowerCase().indexOf('</head>');
      final tete = fin > 0 ? html.substring(0, fin) : html;

      String? meta(List<String> noms) {
        for (final nom in noms) {
          final valeur = _meta(tete, nom);
          if (valeur != null && valeur.trim().isNotEmpty) return _entites(valeur.trim());
        }
        return null;
      }

      final imageBrute = meta(['og:image', 'og:image:url', 'twitter:image']);
      final apercu = ApercuLien(
        titre: meta(['og:title', 'twitter:title']) ?? _titre(tete),
        description: meta(['og:description', 'twitter:description', 'description']),
        image: imageBrute == null ? null : adresse.resolve(imageBrute).toString(),
        site: meta(['og:site_name']),
      );
      return apercu.vide ? null : apercu;
    } catch (_) {
      return null;
    }
  }

  static String? _meta(String html, String nom) {
    final n = RegExp.escape(nom);
    final motifs = [
      '<meta[^>]+(?:property|name)\\s*=\\s*["\']$n["\'][^>]*content\\s*=\\s*"([^"]*)"',
      '<meta[^>]+(?:property|name)\\s*=\\s*["\']$n["\'][^>]*content\\s*=\\s*\'([^\']*)\'',
      '<meta[^>]+content\\s*=\\s*"([^"]*)"[^>]*(?:property|name)\\s*=\\s*["\']$n["\']',
      '<meta[^>]+content\\s*=\\s*\'([^\']*)\'[^>]*(?:property|name)\\s*=\\s*["\']$n["\']',
    ];
    for (final motif in motifs) {
      final m = RegExp(motif, caseSensitive: false).firstMatch(html);
      if (m != null) return m.group(1);
    }
    return null;
  }

  static String? _titre(String html) {
    final m = RegExp(r'<title[^>]*>([^<]*)</title>', caseSensitive: false).firstMatch(html);
    final valeur = m?.group(1)?.trim();
    return valeur == null || valeur.isEmpty ? null : _entites(valeur);
  }

  static String _entites(String s) => s
      .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)))
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)))
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&');
}
