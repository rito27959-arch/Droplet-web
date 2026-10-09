// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// La télécommande de deux services rendus par Android lui-même : COUPER
// UNE VIDÉO et ENREGISTRER UN FICHIER DANS LA GALERIE.
//
// Le travail se fait côté natif (`MediaBridge.kt`) ; ici on ne fait que
// l'appeler. Voir ce fichier-là pour le détail — en résumé :
//
//   • Couper une vidéo demande de réécrire son conteneur. La solution
//     habituelle (embarquer ffmpeg) ajouterait des dizaines de
//     méga-octets à l'application. Android sait recopier les images
//     telles quelles, sans les décoder : c'est instantané, sans perte,
//     et sans dépendance.
//
//   • Depuis Android 10, une application n'écrit plus librement dans les
//     dossiers publics. Il faut passer par `MediaStore`, qui range le
//     fichier au bon endroit ET prévient la galerie de son existence.
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class MediaService {
  MediaService._();

  static const MethodChannel _channel =
      MethodChannel('com.droplet.droplet/media');

  static bool get isSupported => Platform.isAndroid;

  /// Le téléphone est-il trop chaud pour filmer ?
  ///
  /// ⚠️ À PARTIR DU NIVEAU 3, ANDROID COUPE LES ENCODEURS VIDÉO. La
  /// caméra continue d'afficher son aperçu et le micro d'enregistrer,
  /// mais plus une seule image n'atteint l'encodeur : le fichier ne
  /// contient que du son. Sans cette vérification, on ne peut annoncer
  /// que « l'enregistrement n'a rien capturé », ce qui laisse croire à
  /// un défaut de l'application.
  static Future<bool> get isOverheating async {
    if (!isSupported) return false;
    try {
      final level = await _channel.invokeMethod<int>('thermalStatus');
      return level != null && level >= 3;
    } catch (e) {
      debugPrint('[Média] état thermique indisponible: $e');
      return false;
    }
  }

  /// Met à jour le widget d'écran d'accueil.
  ///
  /// ⚠️ AUCUN CONTENU DE MESSAGE N'EST TRANSMIS, jamais. Un widget est
  /// visible par quiconque regarde l'écran par-dessus une épaule — dans
  /// un taxi, au marché. Une application dont l'argument est que les
  /// messages ne sortent pas du téléphone ne peut pas les afficher sur
  /// l'écran d'accueil. On ne passe que deux nombres.
  static Future<void> majWidget({
    required int nonLus,
    required int pairs,
  }) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<bool>('majWidget', {
        'nonLus': nonLus,
        'pairs': pairs,
      });
    } catch (e) {
      debugPrint('[Média] widget non mis à jour: $e');
    }
  }

  /// Ouvre le clavier téléphonique avec un code opérateur déjà écrit.
  ///
  /// La personne n'a plus qu'à appuyer sur appeler. On ne compose PAS à
  /// sa place : cela demanderait la permission `CALL_PHONE`, hors de
  /// proportion pour ce service — et il vaut mieux qu'elle voie ce qui
  /// part avant que ça parte.
  static Future<bool> composerUssd(String code) async {
    if (!isSupported) return false;
    try {
      return await _channel
              .invokeMethod<bool>('composerUssd', {'code': code}) ??
          false;
    } catch (e) {
      debugPrint('[Média] code non composé: $e');
      return false;
    }
  }

  /// Ouvre un lien avec l'application qui sait le traiter.
  ///
  /// Renvoie `false` si rien ne peut l'ouvrir — WhatsApp absent, par
  /// exemple. L'appelant doit alors proposer le chemin habituel plutôt
  /// que de laisser l'utilisateur devant un bouton qui n'a rien fait.
  static Future<bool> ouvrirLien(String url) async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('ouvrirLien', {'url': url}) ??
          false;
    } catch (e) {
      debugPrint('[Média] lien non ouvert: $e');
      return false;
    }
  }

  /// Le chemin du fichier d'installation de Droplet sur ce téléphone.
  ///
  /// ── ⚠️ POURQUOI C'EST ICI ET PAS AILLEURS ────────────────────────
  ///
  /// Droplet fonctionne sans internet, mais jusqu'ici il en fallait pour
  /// se le PROCURER. C'est un défaut sérieux : dans les endroits où
  /// cette application a le plus de sens — pas de réseau, données mobiles
  /// chères — le premier obstacle n'est pas de faire marcher le maillage,
  /// c'est d'être deux à l'avoir installé.
  ///
  /// Ce chemin permet d'envoyer Droplet lui-même par Bluetooth, par
  /// Wi-Fi Direct ou sur une carte mémoire. Personne n'a besoin de
  /// connexion, à aucun moment.
  ///
  /// Renvoie `null` hors Android, ou si le système refuse de dire où il
  /// a rangé l'application.
  static Future<String?> get installerPath async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('installerPath');
    } catch (e) {
      debugPrint('[Média] chemin d\'installation indisponible: $e');
      return null;
    }
  }

  /// Durée d'une vidéo, ou `null` si elle est illisible.
  static Future<Duration?> videoDuration(String path) async {
    if (!isSupported) return null;
    try {
      final ms = await _channel.invokeMethod<int>(
        'videoDurationMs',
        {'path': path},
      );
      if (ms == null || ms < 0) return null;
      return Duration(milliseconds: ms);
    } catch (e) {
      debugPrint('[Média] durée illisible: $e');
      return null;
    }
  }

  // ── Préparer une photo ou une vidéo avant l'envoi ─────────────────────
  //
  // Voir `MediaBridge.kt` : photo réduite à 1600 px en JPEG, vidéo réencodée
  // en 720p. Chaque méthode renvoie TOUJOURS un chemin utilisable — le
  // fichier d'origine si la préparation est impossible.

  /// La photo prête à envoyer (réduite, orientation appliquée).
  static Future<String> compresserImage(String path) async {
    if (!isSupported) return path;
    try {
      return await _channel.invokeMethod<String>('compresserImage', {
            'path': path,
            'cote': 1600,
            'qualite': 80,
          }) ??
          path;
    } catch (e) {
      debugPrint('[Média] photo non réduite: $e');
      return path;
    }
  }

  static final StreamController<double> _progressionVideo = StreamController.broadcast();

  /// L'avancement du réencodage en cours, de 0 à 1.
  static Stream<double> get progressionVideo => _progressionVideo.stream;

  static bool _ecoute = false;

  static void _ecouter() {
    if (_ecoute) return;
    _ecoute = true;
    _channel.setMethodCallHandler((appel) async {
      if (appel.method == 'progressionVideo' && appel.arguments is num) {
        _progressionVideo.add((appel.arguments as num).toDouble().clamp(0.0, 1.0));
      }
      return null;
    });
  }

  /// Arrête le réencodage en cours : [compresserVideo] rend alors l'original.
  static Future<void> annulerCompression() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<bool>('annulerCompression');
    } catch (_) {}
  }

  /// La vidéo prête à envoyer (720p, ~2 Mbit/s). Peut prendre plusieurs
  /// secondes : l'encodeur matériel du téléphone travaille.
  static Future<String> compresserVideo(String path) async {
    if (!isSupported) return path;
    _ecouter();
    try {
      return await _channel.invokeMethod<String>('compresserVideo', {
            'path': path,
            'coteCourt': 720,
            'debit': 2000000,
          }) ??
          path;
    } catch (e) {
      debugPrint('[Média] vidéo non réencodée: $e');
      return path;
    }
  }

  // ══ TENIR UNE TAILLE, PAS UNE QUALITÉ ══════════════════════════════
  //
  // ⚠️ AUCUN ENCODEUR NE SAIT VISER UNE TAILLE. On lui donne un débit,
  // il rend ce qu'il rend — et le VBR matériel d'Android dépasse
  // couramment sa consigne de 20 à 35 %. Viser 2 Mo se fait donc en deux
  // temps : calculer le débit que la durée autorise, puis VÉRIFIER le
  // fichier obtenu et recommencer plus bas s'il déborde.
  //
  // Le calcul du débit, lui, n'a rien d'arbitraire :
  //
  //   débit total = (2 Mo × 8 × marge) ÷ durée
  //   débit vidéo = débit total − le son
  //
  // La marge de 10 % paie l'en-tête du conteneur MP4 et l'index, qui ne
  // sont pas du débit mais occupent de la place.
  //
  // ⚠️ LA DÉFINITION SE DÉDUIT DU DÉBIT, ET C'EST LE POINT IMPORTANT.
  // Encoder du 720p à 150 kbit/s ne donne pas du 720p : ça donne une
  // bouillie de blocs en 720p. Ce qui compte est le nombre de bits par
  // pixel et par image — autour de 0,08 pour du H.264 regardable. On
  // renverse donc la formule pour en tirer la hauteur, et on la ramène à
  // un multiple de 16, que les encodeurs matériels préfèrent.
  //
  // Concrètement, pour un budget de 2 Mo : 5 s tiennent en 720p, 15 s en
  // ~528p, 30 s en ~368p, 90 s en 240p. C'est la réalité arithmétique
  // d'une taille imposée, pas un réglage à améliorer.

  /// Images par seconde retenues pour le calcul. En dessous, la vidéo
  /// saccade ; au-dessus, chaque image reçoit moins de bits.
  static const int _ips = 24;

  /// Bits par pixel et par image visés. 0,08 est le seuil en dessous
  /// duquel le H.264 commence à faire des blocs visibles.
  static const double _bitsParPixel = 0.08;

  /// Le son, en mono : de la parole reste claire à ce débit, et chaque
  /// bit donné au son est repris à l'image.
  static const int _debitSon = 32000;

  /// Le débit le plus bas qu'on accepte de demander.
  ///
  /// ⚠️ 60 kbit/s EST UN CHOIX DE DERNIER RECOURS, PAS UN RÉGLAGE. À ce
  /// débit, du 240p tombe à 0,024 bit par pixel : c'est très visiblement
  /// en blocs. On n'y descend que lorsque l'encodeur du téléphone ignore
  /// franchement sa consigne — et à ce moment-là, tenir la limite de
  /// transfert compte plus que la finesse, parce qu'un fichier trop gros
  /// ne traverse pas le maillage du tout. La première tentative, elle,
  /// part toujours du débit que la durée autorise vraiment.
  ///
  /// En dessous, les encodeurs matériels d'Android refusent souvent la
  /// consigne et rendent n'importe quoi : il n'y a rien à gagner à
  /// descendre plus bas.
  static const int _debitPlancher = 60000;

  /// Réencode [chemin] pour tenir sous [cibleOctets].
  ///
  /// Rend le chemin du fichier à envoyer. Ce fichier peut dépasser la
  /// cible quand la durée ne laisse pas assez de débit : c'est à
  /// l'appelant de regarder sa taille s'il doit refuser.
  static Future<String> compresserVideoSous(
    String chemin, {
    required int cibleOctets,
    int essais = 4,
  }) async {
    if (!isSupported) return chemin;

    // ⚠️ DÉJÀ SOUS LA CIBLE : ON NE TOUCHE À RIEN. Réencoder une vidéo
    // qui tient déjà lui ferait perdre de la qualité pour rien, et
    // coûterait dix secondes d'attente sans aucune contrepartie.
    if (await _taille(chemin) <= cibleOctets) return chemin;

    final duree = await videoDuration(chemin);
    if (duree == null || duree.inMilliseconds < 100) {
      // Durée illisible : on retombe sur le réglage fixe plutôt que de
      // diviser par zéro.
      return compresserVideo(chemin);
    }
    final secondes = duree.inMilliseconds / 1000.0;

    var debit = math.max(
      (cibleOctets * 8 * 0.90 / secondes).round() - _debitSon,
      _debitPlancher,
    );

    var meilleur = chemin;
    var meilleureTaille = await _taille(chemin);
    var dejaAuPlancher = false;

    for (var n = 0; n < essais; n++) {
      if (debit == _debitPlancher) dejaAuPlancher = true;
      final cote = _coteDepuisDebit(debit);
      final sorti = await _reencoder(chemin, cote: cote, debit: debit);
      if (sorti == null) break; // réencodage impossible : on garde l'état
      final taille = await _taille(sorti);

      if (taille > 0 && taille < meilleureTaille) {
        await _effacer(meilleur, sauf: chemin);
        meilleur = sorti;
        meilleureTaille = taille;
      } else if (sorti != chemin && sorti != meilleur) {
        await _effacer(sorti, sauf: chemin);
      }

      if (meilleureTaille <= cibleOctets) break;

      // ⚠️ ON CORRIGE AVEC LE DÉPASSEMENT CONSTATÉ, pas avec un pas
      // fixe. Diviser le débit par deux à chaque essai gâcherait la
      // qualité d'une vidéo qui ne dépassait que de 5 %. Le facteur
      // 0,85 est la marge qui fait converger en deux essais même quand
      // l'encodeur rend le double de sa consigne — vérifié hors de
      // l'application sur des dépassements de 0,85× à 2×.
      final prochain = (debit * cibleOctets / meilleureTaille * 0.85).round();
      if (prochain >= debit) break; // ne progresse plus : inutile d'insister
      debit = math.max(prochain, _debitPlancher);
      // ⚠️ ON ESSAIE LE PLANCHER UNE FOIS, MAIS UNE SEULE. Sortir dès que
      // le calcul TOMBE sur le plancher privait de la seule tentative qui
      // pouvait encore passer ; y retourner une deuxième fois referait
      // exactement le même encodage pour exactement le même résultat.
      if (debit == _debitPlancher && dejaAuPlancher) break;
    }
    return meilleur;
  }

  /// La hauteur qu'un débit peut tenir, en multiple de 16.
  static int _coteDepuisDebit(int debit) {
    final h = math.sqrt(debit / (_ips * _bitsParPixel * 16 / 9));
    return math.max(240, math.min(720, (h / 16).round() * 16));
  }

  static Future<String?> _reencoder(
    String chemin, {
    required int cote,
    required int debit,
  }) async {
    _ecouter();
    try {
      return await _channel.invokeMethod<String>('compresserVideo', {
        'path': chemin,
        'coteCourt': cote,
        'debit': debit,
      });
    } catch (e) {
      debugPrint('[Média] réencodage à $debit bit/s impossible: $e');
      return null;
    }
  }

  static Future<int> _taille(String chemin) async {
    try {
      return await File(chemin).length();
    } catch (_) {
      return 0;
    }
  }

  /// Efface un fichier intermédiaire — jamais l'original de l'utilisateur.
  static Future<void> _effacer(String chemin, {required String sauf}) async {
    if (chemin == sauf) return;
    try {
      final f = File(chemin);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
  }

  /// Garde la plage [debut] → [fin] d'une vidéo (sans réencodage).
  static Future<String> couperVideo(String path, Duration debut, Duration fin) async {
    if (!isSupported) return path;
    try {
      return await _channel.invokeMethod<String>('couperVideo', {
            'path': path,
            'debutMs': debut.inMilliseconds,
            'finMs': fin.inMilliseconds,
          }) ??
          path;
    } catch (e) {
      debugPrint('[Média] découpe impossible: $e');
      return path;
    }
  }

  /// Des images réparties sur la vidéo, pour la frise du montage.
  static Future<List<String>> imagesVideo(String path, {int nombre = 10}) async {
    if (!isSupported) return const [];
    try {
      return await _channel.invokeListMethod<String>('imagesVideo', {
            'path': path,
            'nombre': nombre,
            'cote': 200,
          }) ??
          const [];
    } catch (_) {
      return const [];
    }
  }

  static final Map<String, Future<String?>> _vignettes = {};

  /// La première image d'une vidéo (JPEG en cache), ou `null`.
  static Future<String?> vignetteVideo(String path) {
    if (!isSupported) return Future.value();
    return _vignettes.putIfAbsent(path, () async {
      try {
        return await _channel.invokeMethod<String>('vignetteVideo', {'path': path, 'cote': 640});
      } catch (e) {
        debugPrint('[Média] vignette impossible: $e');
        return null;
      }
    });
  }

  /// Ne garde que les [max] premières secondes de la vidéo.
  ///
  /// Renvoie le chemin du fichier à utiliser — le fichier raccourci si
  /// une coupe a eu lieu, le fichier d'origine sinon.
  ///
  /// ⚠️ La coupe tombe sur une image-clé, donc un peu AVANT la limite
  /// demandée. Une vidéo compressée ne contient des images complètes que
  /// de loin en loin ; couper ailleurs laisserait la fin en bouillie. La
  /// durée obtenue est donc toujours inférieure ou égale à la limite,
  /// ce qui est le sens de la contrainte.
  static Future<String> trimVideo(String path, Duration max) async {
    if (!isSupported) return path;
    try {
      final result = await _channel.invokeMethod<String>('trimVideo', {
        'path': path,
        'maxMs': max.inMilliseconds,
      });
      return result ?? path;
    } catch (e) {
      debugPrint('[Média] découpe impossible: $e');
      return path;
    }
  }

  /// Copie un fichier dans la galerie ou les téléchargements du
  /// téléphone. Renvoie le dossier de destination, ou `null` en cas
  /// d'échec.
  static Future<String?> saveToGallery({
    required String path,
    required String name,
    String mimeType = '',
  }) async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('saveToGallery', {
        'path': path,
        'name': name,
        'mime': mimeType,
      });
    } catch (e) {
      debugPrint('[Média] enregistrement impossible: $e');
      return null;
    }
  }

  // ── Compression d'images pour le mesh ──────────────────────────────────
  //
  // Sur un réseau mesh, la bande passante est comptée : le Bluetooth ne
  // transport que 512 octets par paquet, et chaque émission ne dure que
  // quelques millisecondes. Une photo de 10 Mo mettrait des MINUTES à
  // traverser le réseau, bloquant tous les autres messages pendant ce
  // temps. On compresse donc les images volumineuses avant envoi.
  //
  // ⚠️ 10 Mo est un seuil CONSERVATEUR. La plupart des photos modernes
  // font 3-5 Mo. Un fichier >10 Mo est presque toujours une photo RAW,
  // un PNG géant, ou une image non compressée — des cas où la
  // compression est non seulement souhaitable mais nécessaire.

  /// Seuil au-delà duquel une image est compressée (en octets).
  static const int _kImageCompressionThreshold = 10 * 1024 * 1024; // 10 Mo

  /// Taille maximale de la plus grande dimension après redimensionnement.
  /// Les statuts n'ont pas besoin de la résolution originale : sur un
  /// écran de téléphone, 2048px est déjà au-delà de ce qui est visible.
  static const int _kMaxDimension = 2048;

  /// Qualité JPEG de sortie (0-100). 85 est le meilleur compromis
  /// taille/qualité perçue pour des photos de statut.
  static const int _kJpegQuality = 85;

  /// Compresse une image si elle dépasse le seuil [sizeThreshold].
  ///
  /// Renvoie les octets compressés (JPEG) et le nom de fichier suggéré.
  /// Si l'image est déjà sous le seuil ou si la compression échoue,
  /// retourne les octets originaux et le nom d'origine.
  ///
  /// Ne compresse QUE les images (JPEG, PNG, BMP, GIF, TIFF, WebP).
  /// Les vidéos et autres fichiers passent tels quels.
  static Future<({Uint8List bytes, String name})> compressIfNeeded({
    required Uint8List bytes,
    required String fileName,
    String mimeType = '',
  }) async {
    if (bytes.length < _kImageCompressionThreshold) {
      return (bytes: bytes, name: fileName);
    }

    // Déterminer si c'est une image à partir du type MIME ou de l'extension.
    final isImage = _isImageMime(mimeType) || _isImageExtension(fileName);
    if (!isImage) return (bytes: bytes, name: fileName);

    try {
      // Décoder l'image (le paquet `image` gère JPEG, PNG, BMP, GIF, WebP).
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        debugPrint('[Média] décodage impossible pour compression: $fileName');
        return (bytes: bytes, name: fileName);
      }

      // Redimensionner si une dimension dépasse la limite.
      var result = decoded;
      if (result.width > _kMaxDimension || result.height > _kMaxDimension) {
        result = img.copyResize(
          result,
          width: result.width > result.height ? _kMaxDimension : null,
          height: result.height >= result.width ? _kMaxDimension : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encoder en JPEG avec la qualité réduite.
      final compressed = img.encodeJpg(result, quality: _kJpegQuality);
      final compressedBytes = Uint8List.fromList(compressed);

      // Ne garder la version compressée si elle est effectivement plus
      // petite — sinon on garde l'original (un PNG simple peut être
      // plus petit qu'un JPEG re-encodé).
      if (compressedBytes.length >= bytes.length) {
        debugPrint('[Média] compression inutile pour $fileName '
            '(${bytes.length} → ${compressedBytes.length} octets)');
        return (bytes: bytes, name: fileName);
      }

      // Remplacer l'extension par .jpg.
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      final newName = '$baseName.jpg';

      debugPrint('[Média] image compressée: $fileName '
          '(${_formatSize(bytes.length)} → ${_formatSize(compressedBytes.length)})');
      return (bytes: compressedBytes, name: newName);
    } catch (e) {
      debugPrint('[Média] échec compression $fileName: $e');
      return (bytes: bytes, name: fileName);
    }
  }

  /// Vérifie si le type MIME correspond à une image connue.
  static bool _isImageMime(String mime) {
    final lower = mime.toLowerCase();
    return lower.startsWith('image/');
  }

  /// Vérifie si l'extension du fichier est une image connue.
  static bool _isImageExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff', 'tif', 'webp'}
        .contains(ext);
  }

  /// Formate une taille en octets pour l'affichage dans les logs.
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}o';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }
}
