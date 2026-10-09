// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA MÉMOIRE DU CENTRE DE NOTIFICATIONS — ce qui s'est passé pendant qu'on
// regardait ailleurs.
//
// ── ⚠️ CE QUI ENTRE ICI, ET CE QUI N'Y ENTRE PAS ────────────────────────
//
// Pas les messages ordinaires. Ils ont déjà leur place — la liste des
// conversations, avec son compteur de non-lus — et les recopier ici ferait
// du centre un second fil de discussion, en moins bien.
//
// Ce qui entre, c'est ce que la liste NE DIT PAS, ou dit trop bas :
//
//   • une MENTION dans un groupe de deux cents messages, noyée au milieu ;
//   • une RÉACTION à l'un de ses messages — la liste n'en montre rien ;
//   • un APPEL MANQUÉ ;
//   • une ANNONCE du compte officiel ;
//   • une RÉPONSE ou un « j'aime » sur son statut.
//
// ── ⚠️ ON GARDE LES FAITS, PAS LES PHRASES ──────────────────────────────
//
// Chaque entrée note QUI, QUOI et QUAND — jamais « Nico a réagi à votre
// message ». La phrase est composée à l'affichage, dans la langue du
// moment. Écrite ici, elle resterait en français pour toujours chez
// quelqu'un qui passe l'application en anglais demain.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

enum TypeEntreeNotif {
  mention,
  reaction,
  appelManque,
  annonce,
  reponseStatut,
  jaimeStatut,
}

@immutable
class EntreeNotif {
  const EntreeNotif({
    required this.id,
    required this.type,
    required this.conversationId,
    required this.route,
    required this.auteur,
    required this.quand,
    this.auteurId,
    this.texte = '',
    this.emoji,
    this.groupe = false,
    this.nomConversation,
    this.lu = false,
  });

  final String id;
  final TypeEntreeNotif type;

  /// La conversation concernée — c'est par elle que le centre empile.
  final String conversationId;

  /// Où emmène un toucher.
  final String route;

  /// Le pseudo de qui a agi (ou « Droplet » pour une annonce).
  final String auteur;
  final String? auteurId;

  /// L'extrait : le message mentionnant, le message auquel on a réagi,
  /// le titre de l'annonce…
  final String texte;

  final String? emoji;
  final bool groupe;

  /// Le nom du groupe, quand il y en a un.
  final String? nomConversation;
  final DateTime quand;
  final bool lu;

  EntreeNotif lue() => EntreeNotif(
        id: id,
        type: type,
        conversationId: conversationId,
        route: route,
        auteur: auteur,
        auteurId: auteurId,
        texte: texte,
        emoji: emoji,
        groupe: groupe,
        nomConversation: nomConversation,
        quand: quand,
        lu: true,
      );

  Map<String, Object?> versJson() => {
        'i': id,
        't': type.name,
        'c': conversationId,
        'r': route,
        'a': auteur,
        if (auteurId != null) 'ai': auteurId,
        if (texte.isNotEmpty) 'x': texte,
        if (emoji != null) 'e': emoji,
        if (groupe) 'g': true,
        if (nomConversation != null) 'n': nomConversation,
        'q': quand.millisecondsSinceEpoch,
        if (lu) 'l': true,
      };

  static EntreeNotif? depuisJson(Object? brut) {
    if (brut is! Map) return null;
    final type = TypeEntreeNotif.values
        .where((t) => t.name == brut['t'])
        .firstOrNull;
    final q = brut['q'];
    if (type == null || q is! num) return null;
    return EntreeNotif(
      id: '${brut['i'] ?? ''}',
      type: type,
      conversationId: '${brut['c'] ?? ''}',
      route: '${brut['r'] ?? ''}',
      auteur: '${brut['a'] ?? ''}',
      auteurId: brut['ai'] as String?,
      texte: '${brut['x'] ?? ''}',
      emoji: brut['e'] as String?,
      groupe: brut['g'] == true,
      nomConversation: brut['n'] as String?,
      quand: DateTime.fromMillisecondsSinceEpoch(q.toInt()),
      lu: brut['l'] == true,
    );
  }
}

/// Le journal, partagé par toute l'application.
class JournalNotifs extends ChangeNotifier {
  JournalNotifs._();

  static final JournalNotifs instance = JournalNotifs._();

  static const String _cle = 'notif:journal';

  /// ⚠️ DEUX BORNES, ET IL LES FAUT TOUTES LES DEUX. Trente jours seuls
  /// laisseraient un groupe très actif remplir la base de milliers
  /// d'entrées ; deux cents seules garderaient chez quelqu'un de calme des
  /// appels manqués d'il y a un an. iOS fait la même chose : le centre se
  /// vide de lui-même, sans qu'on ait à y penser.
  static const int maxEntrees = 200;
  static const Duration dureeConservation = Duration(days: 30);

  List<EntreeNotif>? _entrees;

  /// Du plus récent au plus ancien.
  List<EntreeNotif> get entrees => List.unmodifiable(_charger());

  int get nonLues => _charger().where((e) => !e.lu).length;

  List<EntreeNotif> _charger() {
    final dejaLa = _entrees;
    if (dejaLa != null) return dejaLa;
    final liste = <EntreeNotif>[];
    try {
      final brut = StorageService.getString(_cle);
      if (brut != null && brut.isNotEmpty) {
        for (final e in jsonDecode(brut) as List) {
          final entree = EntreeNotif.depuisJson(e);
          if (entree != null) liste.add(entree);
        }
      }
    } catch (_) {
      // Base pas encore prête : on ne MÉMORISE pas la liste vide, pour
      // relire au prochain appel.
      return liste;
    }
    return _entrees = _elaguer(liste);
  }

  List<EntreeNotif> _elaguer(List<EntreeNotif> liste) {
    final limite = DateTime.now().subtract(dureeConservation);
    final gardees = liste.where((e) => e.quand.isAfter(limite)).toList()
      ..sort((a, b) => b.quand.compareTo(a.quand));
    return gardees.length > maxEntrees
        ? gardees.sublist(0, maxEntrees)
        : gardees;
  }

  Future<void> _sauver() async {
    final liste = _entrees ?? const <EntreeNotif>[];
    try {
      await StorageService.setString(
        _cle,
        jsonEncode([for (final e in liste) e.versJson()]),
      );
    } catch (_) {}
  }

  /// Ajoute une entrée.
  ///
  /// ⚠️ IDEMPOTENT PAR IDENTIFIANT. Un appel manqué peut être signalé par
  /// le maillage ET par la mailbox ; une réaction peut être relayée deux
  /// fois. La seconde arrivée est ignorée, au lieu d'afficher deux fois la
  /// même chose dans le centre.
  Future<void> ajouter(EntreeNotif e) async {
    final liste = _charger();
    if (liste.any((x) => x.id == e.id)) return;
    _entrees = _elaguer([e, ...liste]);
    notifyListeners();
    await _sauver();
  }

  Future<void> marquerToutLu() async {
    final liste = _charger();
    if (liste.every((e) => e.lu)) return;
    _entrees = [for (final e in liste) e.lu ? e : e.lue()];
    notifyListeners();
    await _sauver();
  }

  /// La conversation vient d'être ouverte : ce qui la concerne est lu.
  Future<void> marquerConversationLue(String conversationId) async {
    final liste = _charger();
    if (!liste.any((e) => e.conversationId == conversationId && !e.lu)) {
      return;
    }
    _entrees = [
      for (final e in liste)
        e.conversationId == conversationId && !e.lu ? e.lue() : e,
    ];
    notifyListeners();
    await _sauver();
  }

  Future<void> supprimer(String id) async {
    _entrees = _charger().where((e) => e.id != id).toList();
    notifyListeners();
    await _sauver();
  }

  Future<void> supprimerConversation(String conversationId) async {
    _entrees =
        _charger().where((e) => e.conversationId != conversationId).toList();
    notifyListeners();
    await _sauver();
  }

  Future<void> vider() async {
    _entrees = [];
    notifyListeners();
    await _sauver();
  }
}
