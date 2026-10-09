// ============================================================================
// TRANSCRIRE ET TRADUIRE — SANS QUE RIEN NE SORTE DU TÉLÉPHONE.
// ----------------------------------------------------------------------------
// Les deux fonctions que Telegram réserve à Premium, reprises ici avec la
// contrainte de Droplet en plus : le message est chiffré de bout en bout,
// donc il ne peut pas partir vers un service de reconnaissance ou de
// traduction en ligne. Tout passe par le moteur HORS LIGNE d'Android et
// par les modèles ML Kit installés sur l'appareil (voir
// `IntelligenceBridge.kt`).
//
// ⚠️ LE RÉSULTAT EST GARDÉ. Transcrire un vocal prend plusieurs secondes et
// chauffe le téléphone ; le refaire à chaque fois qu'on remonte dans la
// conversation serait absurde. Chaque résultat est donc rangé sous
// l'identifiant du message, et rendu instantanément ensuite.
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'storage_service.dart';

/// Ce qu'une demande peut donner.
enum EtatIntelligence {
  /// Le texte est là.
  ok,

  /// Le moteur ou le modèle n'existe pas sur cet appareil.
  indisponible,

  /// Le vocal ne contenait aucune parole reconnaissable.
  vide,

  /// Déjà dans la langue voulue.
  identique,

  /// Le modèle de traduction n'a pas pu être installé (réseau).
  modele,

  /// Autre échec.
  echec,
}

class ResultatIntelligence {
  const ResultatIntelligence(
    this.etat, {
    this.texte,
    this.langueSource,
    this.enLigne = false,
  });

  final EtatIntelligence etat;
  final String? texte;

  /// La langue détectée, pour écrire « Traduit de l'anglais ».
  final String? langueSource;

  /// Vrai si le résultat vient d'un service en ligne (voir
  /// [ServiceIntelligence.enLigneAutorise]) — l'écran le dit.
  final bool enLigne;

  bool get reussi => etat == EtatIntelligence.ok && (texte ?? '').isNotEmpty;

  Map<String, Object?> versJson() => {
        'etat': etat.name,
        'texte': texte,
        'langue': langueSource,
        if (enLigne) 'web': true,
      };

  static ResultatIntelligence? depuisJson(String? brut) {
    if (brut == null || brut.isEmpty) return null;
    try {
      final j = jsonDecode(brut) as Map<String, dynamic>;
      return ResultatIntelligence(
        EtatIntelligence.values.firstWhere(
          (e) => e.name == j['etat'],
          orElse: () => EtatIntelligence.echec,
        ),
        texte: j['texte'] as String?,
        langueSource: j['langue'] as String?,
        enLigne: j['web'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

class ServiceIntelligence {
  ServiceIntelligence._();

  static const MethodChannel _canal =
      MethodChannel('com.droplet.droplet/intelligence');

  /// Les résultats déjà obtenus pendant cette session.
  static final Map<String, ResultatIntelligence> _memoire = {};

  static bool? _transcriptionDisponible;

  // ── LE CHEMIN EN LIGNE ─────────────────────────────────────────────────
  //
  // ⚠️ C'EST UN COMPROMIS, ET IL EST RÉGLÉ PAR L'UTILISATEUR. Par défaut,
  // rien ne sort du téléphone. Activé (Réglages → Traduction et
  // transcription), et seulement quand une connexion existe :
  //   • la traduction passe par MyMemory — gratuite, sans clé, 5 000
  //     caractères par jour et par appareil ; le moteur de l'appareil
  //     reprend la main si le service ne répond pas ou si le quota est
  //     atteint ;
  //   • la transcription peut utiliser le service vocal d'Apple ou de
  //     Google quand l'appareil n'a pas de moteur hors ligne pour la
  //     langue (le natif reçoit `enLigne`).
  // Dans les deux cas, le contenu quitte l'appareil en clair pour ce
  // trajet-là : c'est écrit sous l'interrupteur, et sous chaque traduction
  // venue d'Internet.

  static const String _cleEnLigne = 'intel:en_ligne';
  static const String _hoteTraduction = 'https://api.mymemory.translated.net/get';

  /// Une adresse de contact passe le quota gratuit de MyMemory de 5 000 à
  /// 50 000 caractères par jour. Laisser vide pour rester anonyme.
  static const String _contactMyMemory = '';

  /// L'utilisateur a-t-il autorisé les services en ligne ?
  static bool get enLigneAutorise => StorageService.getString(_cleEnLigne) == '1';

  static Future<void> autoriserEnLigne(bool oui) async {
    await StorageService.setString(_cleEnLigne, oui ? '1' : '0');
    _transcriptionDisponible = null;
    // Les échecs gardés en mémoire ne doivent pas masquer le nouveau chemin.
    _memoire.removeWhere((_, r) => !r.reussi);
  }

  /// Le moteur vocal hors ligne existe-t-il sur cet appareil ?
  ///
  /// La question n'est posée qu'une fois : la réponse ne change pas en
  /// cours de session, et elle sert à masquer un bouton qui ne mènerait
  /// nulle part.
  static Future<bool> transcriptionDisponible() async {
    if (_transcriptionDisponible != null) return _transcriptionDisponible!;
    try {
      final ok = await _canal.invokeMethod<bool>(
        'transcriptionDisponible',
        {'enLigne': enLigneAutorise},
      );
      return _transcriptionDisponible = ok ?? false;
    } catch (_) {
      return _transcriptionDisponible = false;
    }
  }

  /// Transcrit le vocal [chemin], et garde le résultat sous [idMessage].
  static Future<ResultatIntelligence> transcrire({
    required String idMessage,
    required String chemin,
    String? langue,
  }) {
    return _avecMemoire('tr:$idMessage', () async {
      final reponse = await _canal.invokeMapMethod<String, dynamic>('transcrire', {
        'chemin': chemin,
        'langue': langue,
        'enLigne': enLigneAutorise,
      });
      return _lire(reponse);
    });
  }

  /// Traduit [texte] vers [cible] (un code comme `fr`, `en`).
  static Future<ResultatIntelligence> traduire({
    required String idMessage,
    required String texte,
    required String cible,
    bool forcerEnLigne = false,
  }) {
    // Un « Traduire en ligne » explicite ne doit pas retomber sur l'échec
    // hors ligne gardé en mémoire.
    if (forcerEnLigne) _memoire.remove('tx:$idMessage:$cible');
    return _avecMemoire('tx:$idMessage:$cible', () async {
      if (forcerEnLigne || enLigneAutorise) {
        final enLigne = await _traduireEnLigne(texte, cible);
        if (enLigne.reussi || enLigne.etat == EtatIntelligence.identique) {
          return enLigne;
        }
        if (forcerEnLigne) return enLigne;
      }
      final reponse = await _canal.invokeMapMethod<String, dynamic>('traduire', {
        'texte': texte,
        'cible': cible,
      });
      return _lire(reponse);
    });
  }

  /// Oublie ce qui avait été calculé pour ce message (message supprimé).
  /// MyMemory : 500 octets UTF-8 au plus par requête. Le texte est donc
  /// traduit ligne par ligne (les retours à la ligne survivent), et une
  /// ligne trop longue est coupée aux phrases, puis aux mots.
  static Future<ResultatIntelligence> _traduireEnLigne(String texte, String cible) async {
    try {
      final lignesTraduites = <String>[];
      String? source;
      for (final ligne in texte.split('\n')) {
        if (ligne.trim().isEmpty) {
          lignesTraduites.add('');
          continue;
        }
        final morceaux = <String>[];
        for (final morceau in _decouper(ligne.trim(), 480)) {
          final uri = Uri.parse(_hoteTraduction).replace(queryParameters: {
            'q': morceau,
            'langpair': '${source ?? 'Autodetect'}|$cible',
            if (_contactMyMemory.isNotEmpty) 'de': _contactMyMemory,
          });
          final reponse = await http.get(uri).timeout(const Duration(seconds: 8));
          if (reponse.statusCode != 200) {
            return const ResultatIntelligence(EtatIntelligence.echec);
          }
          final json = jsonDecode(utf8.decode(reponse.bodyBytes)) as Map<String, dynamic>;
          final donnees = json['responseData'] as Map<String, dynamic>?;
          final traduit = donnees?['translatedText'] as String?;
          // Quota épuisé : MyMemory répond 200 avec un avertissement en guise
          // de traduction — il ne faut surtout pas l'afficher.
          if ('${json['responseStatus']}' != '200' ||
              traduit == null ||
              traduit.toUpperCase().startsWith('MYMEMORY WARNING')) {
            return const ResultatIntelligence(EtatIntelligence.echec);
          }
          // Un champ au type inattendu ne doit pas faire échouer toute la
          // traduction : on ne garde la langue détectée que si c'est un texte.
          final detectee = donnees?['detectedLanguage'];
          if (detectee is String && detectee.isNotEmpty) source ??= detectee;
          morceaux.add(_entites(traduit));
        }
        lignesTraduites.add(morceaux.join(' '));
      }
      final resultat = lignesTraduites.join('\n').trim();
      if (resultat.isEmpty) return const ResultatIntelligence(EtatIntelligence.echec);
      final court = (source ?? '').split(RegExp('[-_]')).first.toLowerCase();
      if (court.isNotEmpty && court == cible.split(RegExp('[-_]')).first.toLowerCase()) {
        return const ResultatIntelligence(EtatIntelligence.identique);
      }
      return ResultatIntelligence(
        EtatIntelligence.ok,
        texte: resultat,
        langueSource: court.isEmpty ? null : court,
        enLigne: true,
      );
    } catch (e) {
      // Pas de réseau, délai dépassé, réponse illisible : on se tait, et le
      // moteur de l'appareil prend le relais.
      debugPrint('[Intelligence] traduction en ligne : $e');
      return const ResultatIntelligence(EtatIntelligence.echec);
    }
  }

  static List<String> _decouper(String texte, int maxOctets) {
    int octets(String s) => utf8.encode(s).length;
    if (octets(texte) <= maxOctets) return [texte];
    final morceaux = <String>[];
    var courant = '';
    final unites = texte.split(RegExp(r'(?<=[.!?…])\s+'));
    for (final unite in unites) {
      final pieces = octets(unite) <= maxOctets ? [unite] : unite.split(' ');
      for (final piece in pieces) {
        final essai = courant.isEmpty ? piece : '$courant $piece';
        if (octets(essai) <= maxOctets) {
          courant = essai;
        } else {
          if (courant.isNotEmpty) morceaux.add(courant);
          courant = piece;
        }
      }
    }
    if (courant.isNotEmpty) morceaux.add(courant);
    return morceaux;
  }

  static String _entites(String s) => s
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');

  static Future<void> oublier(String idMessage) async {
    _memoire.removeWhere((cle, _) => cle.contains(idMessage));
    await StorageService.setString('intel:tr:$idMessage', '');
  }

  static ResultatIntelligence _lire(Map<String, dynamic>? reponse) {
    final etat = reponse?['etat'] as String?;
    return switch (etat) {
      'ok' => ResultatIntelligence(
          EtatIntelligence.ok,
          texte: reponse?['texte'] as String?,
          langueSource: reponse?['source'] as String?,
        ),
      'vide' => const ResultatIntelligence(EtatIntelligence.vide),
      'identique' => const ResultatIntelligence(EtatIntelligence.identique),
      'indisponible' => const ResultatIntelligence(EtatIntelligence.indisponible),
      'modele' => const ResultatIntelligence(EtatIntelligence.modele),
      _ => const ResultatIntelligence(EtatIntelligence.echec),
    };
  }

  /// Rend le résultat gardé s'il existe, sinon le calcule et le range.
  ///
  /// Seuls les SUCCÈS sont gardés sur le disque : un échec passager
  /// (modèle en cours d'installation, téléphone occupé) doit pouvoir être
  /// réessayé au prochain appui.
  static Future<ResultatIntelligence> _avecMemoire(
    String cle,
    Future<ResultatIntelligence> Function() calculer,
  ) async {
    final vif = _memoire[cle];
    if (vif != null) return vif;
    final range = ResultatIntelligence.depuisJson(
      StorageService.getString('intel:$cle'),
    );
    if (range != null && range.reussi) {
      _memoire[cle] = range;
      return range;
    }
    try {
      final resultat = await calculer();
      // Un état passager (modèle en cours de téléchargement, réseau absent,
      // moteur momentanément indisponible) n'est pas gardé : le prochain
      // appui doit vraiment réessayer.
      if (resultat.reussi ||
          resultat.etat == EtatIntelligence.vide ||
          resultat.etat == EtatIntelligence.identique) {
        _memoire[cle] = resultat;
      }
      if (resultat.reussi) {
        await StorageService.setString('intel:$cle', jsonEncode(resultat.versJson()));
      }
      return resultat;
    } catch (e) {
      debugPrint('[Intelligence] $cle : $e');
      return const ResultatIntelligence(EtatIntelligence.indisponible);
    }
  }

  /// Vide la mémoire — pour les tests.
  @visibleForTesting
  static void reinitialiser() {
    _memoire.clear();
    _transcriptionDisponible = null;
  }
}
