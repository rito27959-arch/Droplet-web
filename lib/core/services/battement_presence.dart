// ============================================================================
// LE BATTEMENT DE PRÉSENCE — « je suis joignable, là, maintenant ».
// ----------------------------------------------------------------------------
// Décision prise avec l'auteur de l'app :
//   • le battement ne part QU'AU PREMIER PLAN. Pas de réveil en arrière-plan :
//     iOS ne garantit rien de mieux qu'un quart d'heure, et ça viderait la
//     batterie pour afficher un point vert qui ment à moitié. Comme WhatsApp,
//     « en ligne » veut dire « l'app est ouverte ».
//   • la présence est visible de tous ceux qui peuvent écrire — pas de liste
//     à tenir, pas de réglage à comprendre.
//
// Ce que ça coûte, dit franchement : l'annuaire apprend quand un identifiant
// est en ligne, et les identifiants qu'on interroge. Aucun contenu, aucun
// message, mais ce sont des métadonnées que Droplet ne donnait pas avant.
// D'où les deux verrous : seulement si le mode en ligne est accepté, et
// seulement app ouverte.
// ============================================================================

import 'dart:async';

import '../config/server_config.dart';
import 'directory_client.dart';
import 'presence_internet.dart';
import 'service_intelligence.dart';
import 'storage_service.dart';

class BattementPresence {
  BattementPresence._();

  /// Assez vif pour un « en ligne » crédible, assez rare pour ne rien coûter
  /// quand la radio est déjà réveillée par l'usage de l'app.
  static const Duration periode = Duration(minutes: 2);

  static Timer? _minuteur;
  static DirectoryClient? _annuaire;
  static bool _enCours = false;

  static DirectoryClient get _client =>
      _annuaire ??= DirectoryClient(serverUrl: kDirectoryUrl);

  /// À l'entrée au premier plan.
  static void demarrer() {
    if (_minuteur != null) return;
    unawaited(_battre());
    _minuteur = Timer.periodic(periode, (_) => unawaited(_battre()));
  }

  /// À la sortie. On ne ment pas : dès qu'on part, plus rien n'est publié,
  /// et la dernière heure connue vieillit d'elle-même.
  static void arreter() {
    _minuteur?.cancel();
    _minuteur = null;
  }

  static Future<void> _battre() async {
    if (_enCours) return;
    // Deux verrous : le mode en ligne accepté, et une identité connue.
    if (!ServiceIntelligence.enLigneAutorise) return;
    final moi = StorageService.currentUser?.id;
    if (moi == null || moi.isEmpty) return;

    _enCours = true;
    try {
      await _client.battement(moi);
      final autres = _pairsASuivre(moi);
      if (autres.isEmpty) return;
      final vus = await _client.presences(autres);
      vus.forEach(PresenceInternet.signe2);
    } catch (_) {
      // Un annuaire injoignable n'est pas une erreur : le maillage, lui,
      // continue de fonctionner sans rien demander à personne.
    } finally {
      _enCours = false;
    }
  }

  /// Ceux dont la présence nous sert : les gens avec qui on a une
  /// conversation. Inutile d'interroger l'annuaire sur tout le carnet.
  static List<String> _pairsASuivre(String moi) {
    final vus = <String>{};
    for (final m in StorageService.getMessages().reversed) {
      if (m.groupId != null) continue;
      final autre = m.senderId == moi ? m.targetId : m.senderId;
      if (autre == null || autre.isEmpty || autre == moi) continue;
      if (StorageService.isContactBlocked(autre)) continue;
      vus.add(autre);
      if (vus.length >= 40) break;
    }
    return vus.toList();
  }
}
