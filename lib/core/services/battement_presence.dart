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
// message. Le serveur de boîte aux lettres le voit déjà à chaque relève :
// le battement n'ajoute que l'heure, lisible par les contacts.
//
// ⚠️ IL ÉTAIT ATTACHÉ AU MAUVAIS INTERRUPTEUR. Il ne partait que si les
// « services en ligne » de TRADUCTION étaient activés — un réglage qui n'a
// rien à voir. Qui écrivait par Internet sans traduction en ligne ne
// battait jamais : ses contacts voyaient l'heure du dernier croisement par
// le maillage, ou celle de son dernier message, figée. Le verrou qui reste
// est le seul qui ait un sens : l'app ouverte.
//
// Il passe par le MÊME client que la boîte aux lettres
// (`TorTransport.annuaireCourant`) : par Tor quand Tor est actif.
// ============================================================================

import 'dart:async';

import 'presence_internet.dart';
import 'storage_service.dart';
import 'tor_transport.dart';

class BattementPresence {
  BattementPresence._();

  /// Assez vif pour un « en ligne » crédible, assez rare pour ne rien coûter
  /// quand la radio est déjà réveillée par l'usage de l'app.
  static const Duration periode = Duration(minutes: 2);

  static Timer? _minuteur;
  static bool _enCours = false;
  static DateTime _dernier = DateTime(0);

  /// La liaison Internet vient d'être prête : si l'app est ouverte, on bat
  /// tout de suite au lieu d'attendre la prochaine période — sans quoi le
  /// premier battement du démarrage, parti trop tôt, faisait attendre deux
  /// minutes avant de paraître en ligne.
  static void cheminPret() {
    if (_minuteur != null) unawaited(_battre());
  }

  /// À l'ouverture d'une discussion : la présence du contact à jour sans
  /// attendre la période. Au plus une fois toutes les 20 s.
  static void maintenant() {
    if (_minuteur == null) return;
    if (DateTime.now().difference(_dernier) < const Duration(seconds: 20)) return;
    unawaited(_battre());
  }

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
    final moi = StorageService.currentUser?.id;
    if (moi == null || moi.isEmpty) return;
    // Pas encore de liaison Internet : rien à dire. `cheminPret` relancera.
    final client = TorTransport.annuaireCourant;
    if (client == null) return;

    _enCours = true;
    _dernier = DateTime.now();
    try {
      await client.battement(moi);
      final autres = _pairsASuivre(moi);
      if (autres.isEmpty) return;
      final vus = await client.presences(autres);
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
