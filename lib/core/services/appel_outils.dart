// ============================================================================
// OUTILS PURS DES APPELS PAR INTERNET (WebRTC) — sans radio ni caméra, donc
// testables : `test/appel_outils_test.dart`.
//
// Chacun corrige un défaut qui empêchait un appel par Internet d'établir le
// son ou l'image :
//   - `CandidatIce` : les candidats partaient SANS `sdpMid` ni
//     `sdpMLineIndex` et étaient rajoutés avec `RTCIceCandidate(c, null,
//     null)` — Android les rejette. Aucune route réseau n'était échangée.
//   - `FileCandidats` : un candidat arrivé avant la connexion (pendant la
//     sonnerie) ou avant la description distante était perdu.
//   - `serveursIce` : seul STUN était configuré, aucun relais TURN — et le
//     serveur renvoyait un relais factice (`turn.droplet.app` n'existe pas).
//   - `SuiviIce` : l'appel raccrochait à la première micro-coupure
//     (`Disconnected` est transitoire, par ex. au passage Wi-Fi ↔ 4G).
//   - `contraintesMedia` : un appel « vocal » ouvrait la caméra, et échouait
//     entièrement si la permission caméra était refusée.
// ============================================================================

/// Un candidat ICE complet, tel qu'il voyage par la signalisation.
class CandidatIce {
  const CandidatIce(this.candidate, {this.sdpMid, this.sdpMLineIndex});

  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  Map<String, dynamic> versJson() => {
        'candidate': candidate,
        if (sdpMid != null) 'sdpMid': sdpMid,
        if (sdpMLineIndex != null) 'sdpMLineIndex': sdpMLineIndex,
      };

  /// Lit un message de signalisation `ice-candidate`. Tolère l'ancien
  /// format (chaîne seule) : un appareil pas encore mis à jour continue
  /// d'envoyer quelque chose d'exploitable.
  static CandidatIce? depuisMessage(Map<String, dynamic> msg) {
    final c = msg['candidate'];
    if (c is! String || c.isEmpty) return null;
    final mid = msg['sdpMid'];
    final index = msg['sdpMLineIndex'];
    return CandidatIce(
      c,
      sdpMid: mid is String ? mid : null,
      sdpMLineIndex: index is int ? index : (index is num ? index.toInt() : null),
    );
  }
}

/// Garde les candidats reçus trop tôt, jusqu'à ce que la connexion ait sa
/// description distante.
class FileCandidats {
  final List<CandidatIce> _enAttente = [];

  int get taille => _enAttente.length;

  void ajouter(CandidatIce c) => _enAttente.add(c);

  /// Rend les candidats dans leur ordre d'arrivée et vide la file.
  List<CandidatIce> vider() {
    final tout = List<CandidatIce>.of(_enAttente);
    _enAttente.clear();
    return tout;
  }
}

/// Serveurs STUN publics, utilisés quand aucun relais n'est disponible.
const List<Map<String, dynamic>> serveursIceParDefaut = [
  {'urls': ['stun:stun.cloudflare.com:3478']},
  {'urls': ['stun:stun.l.google.com:19302']},
];

/// Transforme la réponse de `/turn/credentials` (format Cloudflare :
/// `{"iceServers": [ {urls, username?, credential?}, … ]}`) en liste de
/// serveurs pour `RTCPeerConnection`.
///
/// ⚠️ LE PORT 53 EST RETIRÉ, comme le recommande Cloudflare : sans « trickle
/// ICE » complet, il fait attendre la collecte jusqu'au délai maximal. Un
/// STUN de repli est toujours présent, même si la réponse est vide ou
/// malformée : sans relais, l'appel doit au moins tenter la connexion directe.
List<Map<String, dynamic>> serveursIce(Object? reponse) {
  final resultat = <Map<String, dynamic>>[];
  final brut = reponse is Map ? reponse['iceServers'] : null;
  final entrees = brut is List ? brut : (brut is Map ? [brut] : const []);
  for (final e in entrees) {
    if (e is! Map) continue;
    final urls = e['urls'];
    final liste = (urls is String ? [urls] : (urls is List ? urls : const []))
        .whereType<String>()
        .where((u) => !RegExp(r':53(\?|$)').hasMatch(u))
        .toList();
    if (liste.isEmpty) continue;
    final serveur = <String, dynamic>{'urls': liste};
    if (e['username'] is String) serveur['username'] = e['username'];
    if (e['credential'] is String) serveur['credential'] = e['credential'];
    resultat.add(serveur);
  }
  final aUnStun = resultat.any((s) => (s['urls'] as List).any((u) => (u as String).startsWith('stun:')));
  if (!aUnStun) resultat.insertAll(0, serveursIceParDefaut);
  return resultat;
}

/// Contraintes `getUserMedia` : audio seul pour un appel vocal.
Map<String, dynamic> contraintesMedia({required bool video}) => {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': video
          ? {
              'facingMode': 'user',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
              'frameRate': {'ideal': 30},
            }
          : false,
    };

/// État de la liaison ICE vu de l'appel.
enum EtatLiaison { enCours, etablie, coupee, echouee }

/// Décide quand un appel est réellement connecté, et quand raccrocher.
///
/// ⚠️ « CONNECTÉ » SEULEMENT QUAND LE SON PASSE. L'ancien service se déclarait
/// connecté dès l'échange de l'offre et de la réponse, alors qu'aucun paquet
/// audio ne circulait encore — et raccrochait au premier `Disconnected`.
class SuiviIce {
  SuiviIce({this.grace = const Duration(seconds: 10)});

  final Duration grace;
  DateTime? _coupeeDepuis;
  bool _etablieUneFois = false;

  bool get etablieUneFois => _etablieUneFois;

  /// Met à jour selon le nouvel état ICE, et dit quoi faire.
  EtatLiaison surEtat(String etatIce, {DateTime? maintenant}) {
    final t = maintenant ?? DateTime.now();
    switch (etatIce) {
      case 'connected':
      case 'completed':
        _coupeeDepuis = null;
        _etablieUneFois = true;
        return EtatLiaison.etablie;
      case 'failed':
        return EtatLiaison.echouee;
      case 'disconnected':
        _coupeeDepuis ??= t;
        return EtatLiaison.coupee;
      default:
        return EtatLiaison.enCours;
    }
  }

  /// Vrai si la coupure dure depuis plus que la grâce accordée.
  bool doitRaccrocher({DateTime? maintenant}) {
    final debut = _coupeeDepuis;
    if (debut == null) return false;
    return (maintenant ?? DateTime.now()).difference(debut) >= grace;
  }
}

/// Ce que disent les statistiques WebRTC de la liaison active.
class StatsLiaison {
  const StatsLiaison({this.viaRelais, this.rttMs = 0});

  /// La paire de candidats choisie passe par un relais TURN. `null` : inconnu.
  final bool? viaRelais;

  /// Aller-retour réseau mesuré, en millisecondes (0 : inconnu).
  final int rttMs;
}

/// Lit les rapports `getStats()` : `(id, type, valeurs)` pour chaque rapport.
///
/// La paire active est d'abord celle que désigne le rapport `transport`
/// (`selectedCandidatePairId`) ; à défaut, une paire réussie et nommée.
StatsLiaison lireStatsIce(List<(String, String, Map<dynamic, dynamic>)> rapports) {
  Map<dynamic, dynamic>? parId(Object? id) {
    if (id is! String) return null;
    for (final r in rapports) {
      if (r.$1 == id) return r.$3;
    }
    return null;
  }

  Map<dynamic, dynamic>? paire;
  for (final r in rapports) {
    if (r.$2 == 'transport') paire ??= parId(r.$3['selectedCandidatePairId']);
  }
  if (paire == null) {
    for (final r in rapports) {
      final v = r.$3;
      if (r.$2 == 'candidate-pair' &&
          v['state'] == 'succeeded' &&
          (v['nominated'] == true || v['selected'] == true)) {
        paire = v;
        break;
      }
    }
  }
  if (paire == null) return const StatsLiaison();

  final typeLocal = parId(paire['localCandidateId'])?['candidateType'];
  final typeDistant = parId(paire['remoteCandidateId'])?['candidateType'];
  final bool? relais = (typeLocal == null && typeDistant == null)
      ? null
      : typeLocal == 'relay' || typeDistant == 'relay';
  final rtt = paire['currentRoundTripTime'];
  return StatsLiaison(viaRelais: relais, rttMs: rtt is num ? (rtt * 1000).round() : 0);
}

/// Une invitation à un appel de groupe est-elle encore d'actualité ? Passée
/// par la boîte aux lettres, elle peut arriver des minutes plus tard : on ne
/// fait pas sonner pour un appel sans doute terminé. Tolère un léger décalage
/// d'horloge entre téléphones.
bool invitationRecente(String? horodatage, {DateTime? maintenant, Duration validite = const Duration(seconds: 60)}) {
  final date = horodatage == null ? null : DateTime.tryParse(horodatage);
  if (date == null) return false;
  final ecart = (maintenant ?? DateTime.now()).toUtc().difference(date.toUtc());
  return ecart <= validite && ecart >= -validite;
}
