// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Client HTTP qui fait passer les requêtes par le proxy SOCKS5 de Tor (Arti).
//
// Utilisé par `DirectoryClient` et `MailboxClient` quand Tor est actif, pour
// que les serveurs (annuaire, boîte aux lettres) ne voient pas l'adresse IP
// de l'appareil. Sans Tor, `TorTransport` utilise un `http.Client` direct.
//
// ── ⚠️ CE FICHIER A ÉTÉ RÉÉCRIT : L'ANCIENNE VERSION N'A JAMAIS MARCHÉ ────
//
// 1. ELLE ÉCHOUAIT À CHAQUE REQUÊTE. Le handshake SOCKS5 lisait
//    `socket.first` deux fois. Un `Socket` est un flux à abonnement UNIQUE :
//    `.first` s'abonne, la seconde lecture levait « Bad state: Stream has
//    already been listened to ». Constaté sur Pixel 6 Pro : dès que Tor
//    était actif, inscription à l'annuaire en échec et toutes les relèves de
//    la boîte aux lettres ratées — un message envoyé restait « en attente ».
//    (Le `SOCKSSocket` livré avec le paquet `tor` fait la même double
//    lecture : il ne pouvait pas servir de base.)
//
// 2. ELLE ACCEPTAIT N'IMPORTE QUEL CERTIFICAT TLS (`onBadCertificate:
//    (_) => true`). Le trafic sort de Tor vers Railway par un nœud de sortie
//    que personne ne contrôle : sans vérification, ce nœud pouvait se faire
//    passer pour l'annuaire ou la mailbox, et SUBSTITUER DES CLÉS PUBLIQUES.
//    La vérification standard du système est désormais appliquée.
//
// 3. ELLE PERDAIT LA CHAÎNE DE REQUÊTE : `/search?q=michel` partait en
//    `/search`. Elle ne gérait pas non plus les réponses `chunked`, et
//    comptait les longueurs en caractères au lieu d'octets.
//
// ── Le principe ─────────────────────────────────────────────────────────
//
// Un seul abonnement au socket alimente un tampon d'octets ; le handshake
// SOCKS5 y lit exactement ce dont il a besoin. Pour HTTPS, l'abonnement est
// mis en pause et `SecureSocket.secure` prend le relais sur la même
// connexion. La réponse est lue jusqu'à la fermeture (`Connection: close`),
// puis découpée en en-têtes et corps, au niveau des OCTETS.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Client HTTP qui route via le proxy SOCKS5 local de Tor.
class TorHttpClient extends http.BaseClient {
  TorHttpClient({required String host, required int port})
      : _proxyHost = host,
        _proxyPort = port;

  final String _proxyHost;
  final int _proxyPort;

  static const _delaiConnexion = Duration(seconds: 20);
  static const _delaiHandshake = Duration(seconds: 30);
  static const _delaiReponse = Duration(seconds: 45);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    final securise = uri.scheme == 'https';
    final port = uri.hasPort ? uri.port : (securise ? 443 : 80);
    Socket? brut;
    try {
      final corps = await request.finalize().toBytes();

      brut = await Socket.connect(_proxyHost, _proxyPort, timeout: _delaiConnexion);
      final lecteur = _LecteurOctets(brut);
      await _handshakeSocks5(brut, lecteur, uri.host, port).timeout(_delaiHandshake);

      final Uint8List reponse;
      if (securise) {
        // La connexion est établie jusqu'au serveur : on bascule en TLS sur
        // ce même socket. Vérification de certificat STANDARD, jamais
        // contournée (voir l'en-tête du fichier).
        lecteur.suspendre();
        final tls = await SecureSocket.secure(brut, host: uri.host)
            .timeout(_delaiHandshake);
        tls.add(_requeteHttp(request, uri, corps.length));
        if (corps.isNotEmpty) tls.add(corps);
        await tls.flush();
        reponse = await _toutLire(tls).timeout(_delaiReponse);
        tls.destroy();
      } else {
        brut.add(_requeteHttp(request, uri, corps.length));
        if (corps.isNotEmpty) brut.add(corps);
        await brut.flush();
        reponse = await lecteur.lireJusquALaFin().timeout(_delaiReponse);
        brut.destroy();
      }
      return _analyserReponse(reponse, request);
    } catch (e) {
      brut?.destroy();
      debugPrint('[TorHttpClient] Erreur: $e');
      return http.StreamedResponse(
        Stream.value(utf8.encode('Erreur Tor: $e')),
        503,
        request: request,
      );
    }
  }

  /// Handshake SOCKS5 : sans authentification, puis CONNECT par NOM DE
  /// DOMAINE — la résolution DNS se fait côté Tor, jamais sur l'appareil.
  Future<void> _handshakeSocks5(
    Socket socket,
    _LecteurOctets lecteur,
    String hote,
    int port,
  ) async {
    socket.add(const [0x05, 0x01, 0x00]);
    final methode = await lecteur.lire(2);
    if (methode[0] != 0x05 || methode[1] != 0x00) {
      throw SocketException('SOCKS5 : méthode refusée (${methode[1]})');
    }

    final nom = utf8.encode(hote);
    if (nom.length > 255) throw ArgumentError('nom d\'hôte trop long');
    socket.add([
      0x05, 0x01, 0x00, 0x03, nom.length, ...nom,
      (port >> 8) & 0xFF, port & 0xFF,
    ]);

    final entete = await lecteur.lire(4);
    if (entete[1] != 0x00) {
      throw SocketException('SOCKS5 : $hote:$port refusé (statut ${entete[1]})');
    }
    // Consommer l'adresse liée en entier, sinon ses octets seraient pris
    // pour le début de la réponse HTTP.
    final int longueurAdresse;
    switch (entete[3]) {
      case 0x01:
        longueurAdresse = 4;
      case 0x04:
        longueurAdresse = 16;
      case 0x03:
        longueurAdresse = (await lecteur.lire(1))[0];
      default:
        throw SocketException('SOCKS5 : type d\'adresse inconnu (${entete[3]})');
    }
    await lecteur.lire(longueurAdresse + 2);
  }

  /// Ligne de requête + en-têtes. Longueur du corps en OCTETS.
  Uint8List _requeteHttp(http.BaseRequest request, Uri uri, int longueurCorps) {
    final chemin = (uri.path.isEmpty ? '/' : uri.path) +
        (uri.hasQuery ? '?${uri.query}' : '');
    final b = StringBuffer()
      ..write('${request.method} $chemin HTTP/1.1\r\n')
      ..write('Host: ${uri.hasPort ? '${uri.host}:${uri.port}' : uri.host}\r\n');
    request.headers.forEach((cle, valeur) {
      final c = cle.toLowerCase();
      if (c == 'host' || c == 'content-length' || c == 'connection') return;
      b.write('$cle: $valeur\r\n');
    });
    if (longueurCorps > 0 || request.method == 'POST' || request.method == 'PUT') {
      b.write('Content-Length: $longueurCorps\r\n');
    }
    b.write('Connection: close\r\n\r\n');
    return Uint8List.fromList(utf8.encode(b.toString()));
  }

  static Future<Uint8List> _toutLire(Stream<List<int>> flux) async {
    final b = BytesBuilder(copy: false);
    await for (final morceau in flux) {
      b.add(morceau);
    }
    return b.takeBytes();
  }

  /// Découpe une réponse HTTP/1.1 brute, au niveau des OCTETS.
  http.StreamedResponse _analyserReponse(Uint8List brut, http.BaseRequest request) {
    final fin = _indexOf(brut, const [13, 10, 13, 10]);
    if (fin < 0) throw const FormatException('réponse HTTP incomplète');
    final lignes = latin1.decode(brut.sublist(0, fin)).split('\r\n');
    final statut = lignes.first.split(' ');
    final code = statut.length >= 2 ? int.tryParse(statut[1]) : null;
    if (code == null) throw FormatException('ligne de statut invalide: ${lignes.first}');

    final entetes = <String, String>{};
    for (final l in lignes.skip(1)) {
      final i = l.indexOf(':');
      if (i > 0) entetes[l.substring(0, i).trim().toLowerCase()] = l.substring(i + 1).trim();
    }

    var corps = brut.sublist(fin + 4);
    if ((entetes['transfer-encoding'] ?? '').toLowerCase().contains('chunked')) {
      corps = _dechunker(corps);
      entetes.remove('transfer-encoding');
    } else if (entetes['content-length'] != null) {
      final n = int.tryParse(entetes['content-length']!);
      if (n != null && n <= corps.length) corps = corps.sublist(0, n);
    }
    entetes['content-length'] = '${corps.length}';

    return http.StreamedResponse(
      Stream.value(corps),
      code,
      headers: entetes,
      contentLength: corps.length,
      request: request,
    );
  }

  static Uint8List _dechunker(Uint8List donnees) {
    final sortie = BytesBuilder(copy: false);
    var pos = 0;
    while (pos < donnees.length) {
      final finLigne = _indexOf(donnees, const [13, 10], depuis: pos);
      if (finLigne < 0) break;
      final taille = int.tryParse(
        latin1.decode(donnees.sublist(pos, finLigne)).split(';').first.trim(),
        radix: 16,
      );
      if (taille == null) throw const FormatException('bloc chunked invalide');
      pos = finLigne + 2;
      if (taille == 0) break;
      if (pos + taille > donnees.length) throw const FormatException('bloc chunked tronqué');
      sortie.add(donnees.sublist(pos, pos + taille));
      pos += taille + 2; // données + CRLF
    }
    return sortie.takeBytes();
  }

  static int _indexOf(Uint8List donnees, List<int> motif, {int depuis = 0}) {
    for (var i = depuis; i <= donnees.length - motif.length; i++) {
      var ok = true;
      for (var j = 0; j < motif.length; j++) {
        if (donnees[i + j] != motif[j]) {
          ok = false;
          break;
        }
      }
      if (ok) return i;
    }
    return -1;
  }
}

/// Lecture d'octets exacts sur un socket, avec UN SEUL abonnement.
///
/// C'est tout l'objet du correctif : un `Socket` ne s'écoute qu'une fois.
/// Ce lecteur s'abonne dès la construction, empile ce qui arrive, et sert
/// les lectures successives du handshake depuis ce tampon.
class _LecteurOctets {
  _LecteurOctets(Socket socket) {
    _abonnement = socket.listen(
      (data) {
        _tampon.add(data);
        _reveiller();
      },
      onError: (Object e) {
        _erreur = e;
        _reveiller();
      },
      onDone: () {
        _termine = true;
        _reveiller();
      },
      cancelOnError: true,
    );
  }

  late final StreamSubscription<List<int>> _abonnement;
  final _tampon = BytesBuilder(copy: false);
  Completer<void>? _attente;
  Object? _erreur;
  bool _termine = false;

  void _reveiller() {
    final a = _attente;
    _attente = null;
    a?.complete();
  }

  Future<void> _attendre() {
    final c = Completer<void>();
    _attente = c;
    return c.future;
  }

  /// Exactement [n] octets, ou une erreur si la connexion se ferme avant.
  Future<Uint8List> lire(int n) async {
    while (_tampon.length < n) {
      if (_erreur != null) throw _erreur!;
      if (_termine) throw const SocketException('connexion fermée pendant le handshake');
      await _attendre();
    }
    final tout = _tampon.takeBytes();
    if (tout.length > n) _tampon.add(tout.sublist(n));
    return tout.sublist(0, n);
  }

  /// Tout ce qui arrive jusqu'à la fermeture de la connexion.
  Future<Uint8List> lireJusquALaFin() async {
    while (!_termine) {
      if (_erreur != null) throw _erreur!;
      await _attendre();
    }
    return _tampon.takeBytes();
  }

  /// Avant de passer la main à `SecureSocket.secure` : l'abonnement ne doit
  /// plus consommer les octets du handshake TLS.
  void suspendre() => _abonnement.pause();
}
