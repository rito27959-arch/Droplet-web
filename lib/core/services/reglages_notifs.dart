// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// CE QUI A LE DROIT DE SONNER — conversation par conversation, et pour toute
// l'application.
//
// Ce fichier ne dessine rien et n'affiche aucune notification. Il répond à
// une seule question, posée à chaque message qui arrive : « faut-il le
// montrer, faut-il qu'il fasse du bruit, et peut-on en lire le texte ? »
//
// ── LES RÉGLAGES, TELS QU'iOS LES A RENDUS ÉVIDENTS ─────────────────────
//
//   • SOURDINE — 1 heure, 8 heures, 1 semaine ou toujours. Celle qui
//     expire est la seule qu'on ose vraiment utiliser : on met un groupe
//     en sourdine pour la soirée sans craindre de l'oublier un an.
//   • LIVRAISON DISCRÈTE — la notification arrive, mais sans son ni
//     bannière. On la trouve en déroulant le volet, quand on veut.
//   • APERÇU — le texte du message apparaît-il ? Toujours, jamais, ou
//     comme le réglage général.
//   • MENTIONS SEULEMENT (groupes) — on n'est prévenu que si quelqu'un
//     écrit @son-pseudo ou @tous.
//   • CONCENTRATION — tout Droplet se tait jusqu'à une heure choisie.
//
// ── ⚠️ UNE MENTION TRAVERSE LA SOURDINE ─────────────────────────────────
//
// C'est le choix de WhatsApp et de Slack, et c'est le bon : on coupe un
// groupe bavard pour ne plus entendre les autres se parler entre eux, pas
// pour manquer la question qu'on nous pose directement. Sans cette
// exception, mettre un groupe en sourdine reviendrait à le quitter.
//
// ── ⚠️ DEUX MONDES, UNE SEULE DÉCISION ──────────────────────────────────
//
// Quand Droplet est fermé, un push le réveille dans un isolate séparé, sans
// base de données. Les réglages y sont donc lus depuis un petit fichier
// miroir (`notifications_reglages.json`), réécrit à chaque changement — le
// même procédé que le carnet de noms de `NotificationService`.
//
// Et surtout : les deux mondes passent par LA MÊME fonction, [Instantane.decider].
// Une règle écrite deux fois finit toujours par diverger, et le défaut ne
// se voit que dans le cas le plus rare — téléphone fermé, groupe en
// sourdine, mention — c'est-à-dire jamais en test.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'storage_service.dart';

/// Le texte du message apparaît-il dans la notification ?
enum ApercuNotif {
  /// Comme le réglage général.
  herite,
  toujours,
  jamais,
}

/// Les réglages d'UNE conversation.
@immutable
class ReglagesConversation {
  const ReglagesConversation({
    this.sourdineJusqua,
    this.sourdinePermanente = false,
    this.apercu = ApercuNotif.herite,
    this.mentionsSeulement = false,
    this.discret = false,
  });

  /// Fin d'une sourdine temporaire. Nulle si aucune, ou si elle est
  /// permanente.
  final DateTime? sourdineJusqua;

  /// Sourdine sans fin — celle de la liste des conversations (« Silence »).
  final bool sourdinePermanente;

  final ApercuNotif apercu;

  /// Groupes seulement : ne prévenir que pour les mentions.
  final bool mentionsSeulement;

  /// Livraison discrète : pas de son, pas de bannière.
  final bool discret;

  bool enSourdine(DateTime maintenant) =>
      sourdinePermanente ||
      (sourdineJusqua != null && sourdineJusqua!.isAfter(maintenant));

  bool get estParDefaut =>
      sourdineJusqua == null &&
      !sourdinePermanente &&
      apercu == ApercuNotif.herite &&
      !mentionsSeulement &&
      !discret;

  ReglagesConversation copier({
    DateTime? Function()? sourdineJusqua,
    bool? sourdinePermanente,
    ApercuNotif? apercu,
    bool? mentionsSeulement,
    bool? discret,
  }) =>
      ReglagesConversation(
        sourdineJusqua:
            sourdineJusqua != null ? sourdineJusqua() : this.sourdineJusqua,
        sourdinePermanente: sourdinePermanente ?? this.sourdinePermanente,
        apercu: apercu ?? this.apercu,
        mentionsSeulement: mentionsSeulement ?? this.mentionsSeulement,
        discret: discret ?? this.discret,
      );

  /// ⚠️ LA SOURDINE PERMANENTE N'EST PAS ÉCRITE ICI. Elle vit dans la
  /// liste historique de `StorageService` (`muted_conversations`), que
  /// la liste des conversations lit pour dessiner son icône. La recopier
  /// ferait deux vérités, et la première fois qu'elles divergeraient, une
  /// conversation affichée « silencieuse » sonnerait.
  Map<String, Object?> versJson() => {
        if (sourdineJusqua != null) 's': sourdineJusqua!.millisecondsSinceEpoch,
        if (apercu != ApercuNotif.herite) 'a': apercu.name,
        if (mentionsSeulement) 'm': true,
        if (discret) 'd': true,
      };

  static ReglagesConversation depuisJson(
    Object? brut, {
    bool sourdinePermanente = false,
  }) {
    if (brut is! Map) {
      return ReglagesConversation(sourdinePermanente: sourdinePermanente);
    }
    final s = brut['s'];
    final a = brut['a'];
    return ReglagesConversation(
      sourdineJusqua:
          s is num ? DateTime.fromMillisecondsSinceEpoch(s.toInt()) : null,
      sourdinePermanente: sourdinePermanente,
      apercu: ApercuNotif.values.firstWhere(
        (v) => v.name == a,
        orElse: () => ApercuNotif.herite,
      ),
      mentionsSeulement: brut['m'] == true,
      discret: brut['d'] == true,
    );
  }
}

/// Ce qu'il faut faire d'un message qui arrive.
@immutable
class DecisionNotif {
  const DecisionNotif({
    required this.afficher,
    required this.sonore,
    required this.apercu,
    required this.banniere,
  });

  /// Une notification système, ou rien du tout.
  final bool afficher;

  /// Avec son et vibration.
  final bool sonore;

  /// Avec le texte du message.
  final bool apercu;

  /// Avec la bannière dans l'application, quand elle est ouverte.
  final bool banniere;

  static const DecisionNotif silence = DecisionNotif(
    afficher: false,
    sonore: false,
    apercu: false,
    banniere: false,
  );
}

/// Tous les réglages à un instant donné — de quoi décider sans rien lire
/// d'autre.
///
/// ⚠️ UNE PHOTO, PAS UNE VUE VIVANTE. C'est ce qui permet de construire le
/// même objet dans l'application (depuis la base) et dans l'isolate du push
/// (depuis le fichier miroir), puis de les passer à la même fonction.
@immutable
class Instantane {
  const Instantane({
    this.conversations = const {},
    this.sourdinesPermanentes = const {},
    this.apercuGeneral = true,
    this.bannieres = true,
    this.concentrationJusqua,
    this.concentrationLaisseMentions = true,
  });

  final Map<String, ReglagesConversation> conversations;
  final Set<String> sourdinesPermanentes;
  final bool apercuGeneral;
  final bool bannieres;
  final DateTime? concentrationJusqua;
  final bool concentrationLaisseMentions;

  ReglagesConversation pour(String id) {
    final propre = conversations[id];
    final permanente = sourdinesPermanentes.contains(id);
    if (propre == null) {
      return ReglagesConversation(sourdinePermanente: permanente);
    }
    return propre.copier(sourdinePermanente: permanente);
  }

  bool concentrationActive(DateTime maintenant) =>
      concentrationJusqua != null && concentrationJusqua!.isAfter(maintenant);

  /// LA règle. Lue de haut en bas, la première qui tranche gagne.
  DecisionNotif decider({
    required String conversationId,
    required bool groupe,
    required bool mentionne,
    DateTime? maintenant,
  }) {
    final t = maintenant ?? DateTime.now();
    final r = pour(conversationId);

    // 1. Concentration : tout se tait, sauf — si on l'a permis — ce qui
    //    s'adresse à soi personnellement.
    if (concentrationActive(t) &&
        !(concentrationLaisseMentions && mentionne)) {
      return DecisionNotif.silence;
    }

    // 2. Sourdine : tout se tait, sauf une mention dans un groupe (voir
    //    l'en-tête : couper un groupe n'est pas le quitter).
    if (r.enSourdine(t) && !(groupe && mentionne)) {
      return DecisionNotif.silence;
    }

    // 3. Mentions seulement.
    if (groupe && r.mentionsSeulement && !mentionne) {
      return DecisionNotif.silence;
    }

    final apercu = switch (r.apercu) {
      ApercuNotif.herite => apercuGeneral,
      ApercuNotif.toujours => true,
      ApercuNotif.jamais => false,
    };

    // ⚠️ UNE MENTION N'EST JAMAIS DISCRÈTE. Elle a traversé la sourdine
    // précisément pour être remarquée ; l'afficher sans bruit annulerait
    // l'exception qu'on vient de lui faire.
    final sonore = !r.discret || mentionne;
    return DecisionNotif(
      afficher: true,
      sonore: sonore,
      apercu: apercu,
      banniere: bannieres && sonore,
    );
  }

  Map<String, Object?> versJson() => {
        'c': {
          for (final e in conversations.entries)
            if (!e.value.estParDefaut) e.key: e.value.versJson(),
        },
        'p': sourdinesPermanentes.toList(),
        'ag': apercuGeneral,
        'b': bannieres,
        if (concentrationJusqua != null)
          'cc': concentrationJusqua!.millisecondsSinceEpoch,
        'cm': concentrationLaisseMentions,
      };

  static Instantane depuisJson(Object? brut) {
    if (brut is! Map) return const Instantane();
    final p = brut['p'];
    final permanentes = p is List ? p.map((e) => '$e').toSet() : <String>{};
    final c = brut['c'];
    final cc = brut['cc'];
    return Instantane(
      conversations: {
        if (c is Map)
          for (final e in c.entries)
            '${e.key}': ReglagesConversation.depuisJson(e.value),
      },
      sourdinesPermanentes: permanentes,
      apercuGeneral: brut['ag'] != false,
      bannieres: brut['b'] != false,
      concentrationJusqua:
          cc is num ? DateTime.fromMillisecondsSinceEpoch(cc.toInt()) : null,
      concentrationLaisseMentions: brut['cm'] != false,
    );
  }
}

/// Les réglages, lus et écrits dans la base de l'application.
class ReglagesNotifs {
  ReglagesNotifs._();

  static const String _prefixe = 'notif:c:';
  static const String _cleApercu = 'notif:apercu'; // partagée avec NotificationService
  static const String _cleBannieres = 'notif:bannieres';
  static const String _cleConcentration = 'notif:concentration';
  static const String _cleConcentrationMentions = 'notif:concentration_mentions';

  /// Incrémenté à chaque changement — la liste des conversations s'y
  /// abonne pour redessiner l'icône de sourdine, y compris quand une
  /// sourdine expire toute seule.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Timer? _prochaineExpiration;

  // ── LECTURE ──────────────────────────────────────────────────────────

  static ReglagesConversation pour(String id) {
    final brut = StorageService.getString('$_prefixe$id');
    Object? json;
    if (brut != null && brut.isNotEmpty) {
      try {
        json = jsonDecode(brut);
      } catch (_) {}
    }
    final r = ReglagesConversation.depuisJson(
      json,
      sourdinePermanente: _permanentes().contains(id),
    );
    // Une sourdine temporaire s'affiche aussi dans la liste historique
    // (pour son icône). Celle-ci n'est donc « permanente » que si aucune
    // échéance n'est notée.
    if (r.sourdineJusqua != null) return r.copier(sourdinePermanente: false);
    return r;
  }

  static Set<String> _permanentes() => StorageService.getMutedConversations();

  static bool get apercuGeneral => StorageService.getString(_cleApercu) != '0';
  static bool get bannieres => StorageService.getString(_cleBannieres) != '0';
  static bool get concentrationLaisseMentions =>
      StorageService.getString(_cleConcentrationMentions) != '0';

  static DateTime? get concentrationJusqua {
    final ms = int.tryParse(StorageService.getString(_cleConcentration) ?? '');
    if (ms == null) return null;
    final fin = DateTime.fromMillisecondsSinceEpoch(ms);
    return fin.isAfter(DateTime.now()) ? fin : null;
  }

  /// Toutes les conversations qui ont un réglage à elles.
  static Map<String, ReglagesConversation> _toutes() {
    final reglages = StorageService.getSettings() ?? const <String, dynamic>{};
    return {
      for (final cle in reglages.keys)
        if (cle.startsWith(_prefixe))
          cle.substring(_prefixe.length): pour(cle.substring(_prefixe.length)),
    };
  }

  static Instantane instantane() {
    final toutes = _toutes();
    // ⚠️ LES SOURDINES TEMPORAIRES SONT RETIRÉES DE L'ENSEMBLE « PERMANENT ».
    // Elles y figurent pour l'icône de la liste ; laissées là, elles ne
    // finiraient jamais.
    final temporaires = {
      for (final e in toutes.entries)
        if (e.value.sourdineJusqua != null) e.key,
    };
    return Instantane(
      conversations: toutes,
      sourdinesPermanentes: _permanentes().difference(temporaires),
      apercuGeneral: apercuGeneral,
      bannieres: bannieres,
      concentrationJusqua: concentrationJusqua,
      concentrationLaisseMentions: concentrationLaisseMentions,
    );
  }

  static DecisionNotif decider({
    required String conversationId,
    required bool groupe,
    required bool mentionne,
  }) {
    try {
      return instantane().decider(
        conversationId: conversationId,
        groupe: groupe,
        mentionne: mentionne,
      );
    } catch (_) {
      // Base pas encore ouverte : mieux vaut une notification de trop
      // qu'un message manqué.
      return const DecisionNotif(
        afficher: true,
        sonore: true,
        apercu: true,
        banniere: true,
      );
    }
  }

  // ── ÉCRITURE ─────────────────────────────────────────────────────────

  static Future<void> _ecrire(String id, ReglagesConversation r) async {
    final json = r.versJson();
    if (json.isEmpty) {
      await StorageService.remove('$_prefixe$id');
    } else {
      await StorageService.setString('$_prefixe$id', jsonEncode(json));
    }
    await _apresChangement();
  }

  /// Met une conversation en sourdine.
  ///
  /// [duree] nulle = toujours. Pour lever la sourdine : [leverSourdine].
  static Future<void> mettreEnSourdine(String id, {Duration? duree}) async {
    final actuel = pour(id);
    await StorageService.setConversationMuted(id, true);
    await _ecrire(
      id,
      actuel.copier(
        sourdineJusqua: () => duree == null ? null : DateTime.now().add(duree),
      ),
    );
  }

  static Future<void> leverSourdine(String id) async {
    final actuel = pour(id);
    await StorageService.setConversationMuted(id, false);
    await _ecrire(id, actuel.copier(sourdineJusqua: () => null));
  }

  static Future<void> definirApercu(String id, ApercuNotif a) async =>
      _ecrire(id, pour(id).copier(apercu: a));

  static Future<void> definirMentionsSeulement(String id, bool v) async =>
      _ecrire(id, pour(id).copier(mentionsSeulement: v));

  static Future<void> definirDiscret(String id, bool v) async =>
      _ecrire(id, pour(id).copier(discret: v));

  static Future<void> definirApercuGeneral(bool v) async {
    await StorageService.setString(_cleApercu, v ? '1' : '0');
    await _apresChangement();
  }

  static Future<void> definirBannieres(bool v) async {
    await StorageService.setString(_cleBannieres, v ? '1' : '0');
    await _apresChangement();
  }

  static Future<void> definirConcentration(DateTime? jusqua) async {
    if (jusqua == null) {
      await StorageService.remove(_cleConcentration);
    } else {
      await StorageService.setString(
        _cleConcentration,
        '${jusqua.millisecondsSinceEpoch}',
      );
    }
    await _apresChangement();
  }

  static Future<void> definirConcentrationLaisseMentions(bool v) async {
    await StorageService.setString(_cleConcentrationMentions, v ? '1' : '0');
    await _apresChangement();
  }

  /// La conversation est supprimée : ses réglages partent avec elle.
  static Future<void> oublier(String id) async {
    await StorageService.remove('$_prefixe$id');
    await _apresChangement();
  }

  // ── LES SOURDINES QUI EXPIRENT ───────────────────────────────────────

  /// Retire les sourdines échues, et programme le prochain réveil.
  ///
  /// ⚠️ UN SEUL MINUTEUR, CALÉ SUR LA PLUS PROCHE ÉCHÉANCE. Pas un par
  /// conversation, et surtout pas une vérification toutes les minutes :
  /// une sourdine d'une semaine n'a besoin de réveiller le téléphone
  /// qu'une seule fois, au bout de la semaine.
  ///
  /// Appelé au démarrage, et après chaque changement. Si l'application
  /// est fermée au moment de l'échéance, rien n'est perdu : la décision
  /// compare de toute façon l'heure à l'échéance, et le ménage se fera au
  /// prochain lancement.
  static Future<void> purgerExpirees() async {
    _prochaineExpiration?.cancel();
    final maintenant = DateTime.now();
    DateTime? prochaine;
    var change = false;
    for (final e in _toutes().entries) {
      final fin = e.value.sourdineJusqua;
      if (fin == null) continue;
      if (!fin.isAfter(maintenant)) {
        await StorageService.setConversationMuted(e.key, false);
        final json = e.value.copier(sourdineJusqua: () => null).versJson();
        if (json.isEmpty) {
          await StorageService.remove('$_prefixe${e.key}');
        } else {
          await StorageService.setString('$_prefixe${e.key}', jsonEncode(json));
        }
        change = true;
      } else if (prochaine == null || fin.isBefore(prochaine)) {
        prochaine = fin;
      }
    }
    if (prochaine != null) {
      _prochaineExpiration = Timer(
        prochaine.difference(maintenant) + const Duration(seconds: 1),
        () => unawaited(purgerExpirees()),
      );
    }
    if (change) {
      revision.value++;
      await _ecrireMiroir();
    }
  }

  static Future<void> _apresChangement() async {
    revision.value++;
    await _ecrireMiroir();
    unawaited(purgerExpirees());
  }

  // ── LE MIROIR POUR L'ISOLATE DU PUSH ─────────────────────────────────

  static Future<File?> _fichierMiroir() async {
    try {
      final dossier = await getApplicationSupportDirectory();
      return File('${dossier.path}/notifications_reglages.json');
    } catch (_) {
      return null;
    }
  }

  /// Réécrit le miroir. À appeler aussi au démarrage : les sourdines
  /// posées depuis la liste (`setConversationMuted`) ne passent pas par
  /// ici.
  static Future<void> _ecrireMiroir() async {
    try {
      final f = await _fichierMiroir();
      await f?.writeAsString(jsonEncode(instantane().versJson()));
    } catch (_) {}
  }

  static Future<void> synchroniserMiroir() => _ecrireMiroir();

  /// Lu par l'isolate du push. Jamais d'exception : sans miroir, on
  /// notifie — un message manqué est pire qu'une notification de trop.
  static Future<Instantane> lireMiroir() async {
    try {
      final f = await _fichierMiroir();
      if (f == null || !f.existsSync()) return const Instantane();
      return Instantane.depuisJson(jsonDecode(await f.readAsString()));
    } catch (_) {
      return const Instantane();
    }
  }
}
