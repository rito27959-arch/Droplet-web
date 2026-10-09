// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE CÔTÉ DART DES NOTIFICATIONS DE CONVERSATION — ce que Droplet demande à
// Android pour qu'une discussion ait sa ligne de réglages, son avatar, sa
// bulle flottante et son champ de réponse.
//
// Le travail est fait par `android/.../NotifConversations.kt`. Ici, il n'y
// a que l'appel et la réception de la réponse tapée.
//
// ── ⚠️ CE N'EST PAS UN REMPLAÇANT DE `NotificationService` ────────────
//
// `NotificationService` (flutter_local_notifications) continue de servir
// pour tout le reste : appels, état du maillage, alertes. Ce fichier ne
// couvre QUE les messages de conversation, parce que ce sont les seuls
// qu'Android traite à part — et parce que le paquet Flutter n'expose ni
// `shortcutId`, ni `LocusId`, ni les métadonnées de bulle.
//
// Appeler les deux pour le même message afficherait la notification en
// double. Le partage est donc : un message de discussion passe par ici,
// tout le reste par `NotificationService`.
//
// ── ⚠️ ANDROID SEULEMENT, ET C'EST ASSUMÉ ─────────────────────────────
//
// iOS n'a pas d'équivalent : ses « communication notifications » reposent
// sur `INSendMessageIntent` et un App Intent déclaré, pas sur des canaux.
// Chaque méthode ici ne fait donc rien ailleurs que sur Android, sans
// erreur et sans message — un appel qui échoue en silence vaut mieux
// qu'une exception à chaque notification sur une autre plateforme.
// ============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ce qu'on fait d'une réponse tapée depuis le volet de notifications.
typedef SurReponseDirecte = Future<void> Function(
    String idConversation, String texte);

/// « Marquer comme lu », touché dans le volet.
typedef SurLuDepuisVolet = Future<void> Function(String idConversation);

/// La réaction en un geste, touchée dans le volet.
typedef SurReactionDepuisVolet = Future<void> Function(
    String idConversation, String idMessage, String emoji);

/// Une action venue du volet, en attente de quelqu'un pour la traiter.
typedef _ActionVolet = ({
  String type,
  String id,
  String texte,
  String message,
  String emoji,
});

class NotifsConversation {
  const NotifsConversation._();

  static const MethodChannel _canal =
      MethodChannel('com.droplet.droplet/notif_conversations');

  static bool get _disponible => !kIsWeb && Platform.isAndroid;

  static SurReponseDirecte? _surReponse;
  static SurLuDepuisVolet? _surLu;
  static SurReactionDepuisVolet? _surReaction;

  /// Les actions arrivées avant que quiconque sache les traiter.
  ///
  /// ⚠️ CETTE FILE EST LA RAISON D'ÊTRE DE TOUT CE DÉCOUPAGE. Quand on tape
  /// une réponse dans le volet alors que Droplet est mort, Android relance
  /// l'application et transmet le texte quelques millisecondes après le
  /// démarrage — bien avant que l'arbre de widgets existe, donc bien avant
  /// qu'il y ait un dépôt à qui demander d'envoyer.
  ///
  /// Brancher le traitement « quand ce sera prêt » perdrait exactement la
  /// réponse qu'on venait d'écrire. On écoute donc tout de suite, on garde,
  /// et on remet dès que quelqu'un se présente.
  static final List<_ActionVolet> _enAttente = [];

  static _ActionVolet? _lire(String type, Object? args) {
    if (args is! Map) return null;
    final id = '${args['id'] ?? ''}';
    if (id.isEmpty) return null;
    return (
      type: type,
      id: id,
      texte: '${args['texte'] ?? ''}',
      message: '${args['message'] ?? ''}',
      emoji: '${args['emoji'] ?? ''}',
    );
  }

  /// Exécute une action si quelqu'un sait la traiter ; sinon la garde.
  static Future<void> _traiter(_ActionVolet a) async {
    switch (a.type) {
      case 'reponseDirecte':
        final f = _surReponse;
        if (a.texte.isEmpty) return;
        if (f == null) return _enAttente.add(a);
        await f(a.id, a.texte);
      case 'marquerLu':
        final f = _surLu;
        if (f == null) return _enAttente.add(a);
        await f(a.id);
      case 'reagir':
        final f = _surReaction;
        if (a.message.isEmpty || a.emoji.isEmpty) return;
        if (f == null) return _enAttente.add(a);
        await f(a.id, a.message, a.emoji);
    }
  }

  /// À appeler au tout début de `main()`.
  ///
  /// N'envoie rien : ouvre l'oreille, et met de côté ce qui arrive.
  static void ecouter() {
    if (!_disponible) return;
    _canal.setMethodCallHandler((appel) async {
      final a = _lire(appel.method, appel.arguments);
      if (a != null) await _traiter(a);
      return null;
    });
  }

  /// À appeler dès qu'un envoi est possible — typiquement au montage de
  /// l'écran racine. Vide la file en passant.
  static Future<void> brancher(
    SurReponseDirecte surReponse, {
    SurLuDepuisVolet? surLu,
    SurReactionDepuisVolet? surReaction,
  }) async {
    if (!_disponible) return;
    _surReponse = surReponse;
    _surLu = surLu;
    _surReaction = surReaction;
    // ⚠️ LES ACTIONS FAITES PENDANT QUE DROPLET ÉTAIT MORT. « Lu » et la
    // réaction ne rouvrent pas l'application — personne n'aime qu'un
    // simple « lu » allume l'écran d'une application. Android les a donc
    // notées de son côté (`ActionsVolet.kt`) ; on vient les chercher.
    try {
      final differees =
          await _canal.invokeMethod<List<Object?>>('actionsDifferees');
      for (final brut in differees ?? const <Object?>[]) {
        if (brut is! Map) continue;
        final a = _lire('${brut['type'] ?? ''}', brut);
        if (a != null) _enAttente.add(a);
      }
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
    if (_enAttente.isEmpty) return;
    // ⚠️ ON COPIE PUIS ON VIDE AVANT D'ENVOYER. Un envoi peut échouer et
    // remettre quelque chose dans la file ; itérer sur la liste qu'on est
    // en train de modifier la ferait sauter des entrées.
    final aTraiter = List.of(_enAttente);
    _enAttente.clear();
    for (final a in aTraiter) {
      await _traiter(a);
    }
  }

  /// Affiche (ou met à jour) la notification d'une conversation.
  ///
  /// [idConversation] doit être le MÊME identifiant que celui du raccourci
  /// publié pour cette discussion : c'est lui qui relie la notification à
  /// la personne, au canal et à la bulle. Deux identifiants différents, et
  /// Android range la notification dans « Autres » sans rien dire.
  /// [fil] est la conversation entière, du plus ancien au plus récent.
  ///
  /// ⚠️ PAS LE SEUL DERNIER MESSAGE. La notification est republiée sous le
  /// même identifiant à chaque arrivée : elle REMPLACE la précédente.
  /// N'envoyer que le dernier ferait disparaître les autres à chaque fois,
  /// et le style « conversation » d'Android — dont c'est toute la raison
  /// d'être — n'afficherait jamais qu'une ligne.
  ///
  /// `auteur` nul signifie « c'est la conversation elle-même qui parle » :
  /// en tête-à-tête, l'auteur est toujours le correspondant, le répéter sur
  /// chaque ligne n'apprend rien. En groupe il est obligatoire, sinon
  /// Android signe toutes les lignes du nom du groupe.
  static Future<bool> notifier({
    required String idConversation,
    required String nom,
    required List<({String texte, DateTime quand, String? auteur})> fil,
    required String route,
    String? cheminPhoto,
    bool groupe = false,
    bool bulle = true,
    /// Rangée sans son ni bandeau.
    bool silencieux = false,
    /// Le dernier message reçu — la cible de la réaction en un geste.
    String? dernierMessage,
    /// Pseudo → photo, pour les lignes d'un groupe.
    Map<String, String?> photosAuteurs = const {},
    /// Les libellés traduits (voir `NotificationService._textesNatifs`).
    Map<String, String> textes = const {},
  }) async {
    if (!_disponible || fil.isEmpty) return false;
    try {
      final ok = await _canal.invokeMethod<bool>('notifier', {
        'id': idConversation,
        'nom': nom,
        'messages': [
          for (final m in fil)
            {
              'texte': m.texte,
              'quand': m.quand.millisecondsSinceEpoch,
              // ⚠️ SA PROPRE RÉPONSE N'A PAS D'AUTEUR, ELLE A UN DRAPEAU.
              // Android dessine la ligne de « l'utilisateur » à part
              // (alignée, sans avatar) ; il faut la lui signaler comme
              // telle, pas comme un message d'un certain « Moi ».
              'moi': m.auteur == '__moi__',
              'auteur': m.auteur == '__moi__' ? null : m.auteur,
              'photo': m.auteur == null ? null : photosAuteurs[m.auteur],
            },
        ],
        'route': route,
        'photo': cheminPhoto,
        'groupe': groupe,
        'bulle': bulle,
        'silencieux': silencieux,
        'dernierMessage': dernierMessage,
        'textes': textes,
      });
      return ok ?? false;
    } on PlatformException catch (e) {
      debugPrint('[Notif conversation] $e');
      return false;
    }
  }

  /// Retire la notification d'une conversation — typiquement quand on
  /// l'ouvre.
  static Future<void> effacer(String idConversation) async {
    if (!_disponible) return;
    try {
      await _canal.invokeMethod('effacer', {'id': idConversation});
    } on PlatformException catch (_) {}
  }

  /// Supprime le canal d'une conversation effacée.
  ///
  /// ⚠️ À N'APPELER QUE POUR UNE SUPPRESSION DÉFINITIVE. Supprimer un canal
  /// jette les réglages que la personne avait faits dessus — sonnerie,
  /// importance, vibration — et les recréer plus tard repart des valeurs
  /// par défaut. Pour une simple conversation archivée, on ne touche à
  /// rien.
  static Future<void> oublier(String idConversation) async {
    if (!_disponible) return;
    try {
      await _canal.invokeMethod('oublier', {'id': idConversation});
    } on PlatformException catch (_) {}
  }

  /// Les notifications sont-elles autorisées ?
  ///
  /// ⚠️ CE N'EST PAS « LES BULLES SONT-ELLES AUTORISÉES ». Android n'expose
  /// aucun moyen de lire ce réglage-là. Un `false` ici garantit qu'il n'y
  /// aura pas de bulle ; un `true` ne garantit rien. Mieux vaut le dire que
  /// de laisser croire à une certitude.
  static Future<bool> notificationsAutorisees() async {
    if (!_disponible) return false;
    try {
      return await _canal.invokeMethod<bool>('bullesAutorisees') ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Emmène aux réglages de notification de Droplet, où se trouve
  /// « Bulles ».
  static Future<void> ouvrirReglagesBulles() async {
    if (!_disponible) return;
    try {
      await _canal.invokeMethod('ouvrirReglagesBulles');
    } on PlatformException catch (_) {}
  }

  /// Emmène droit aux réglages de CETTE conversation — la deuxième capture :
  /// importance, son, écran de verrouillage, pour cette personne seule.
  static Future<void> ouvrirReglagesConversation(String idConversation) async {
    if (!_disponible) return;
    try {
      await _canal.invokeMethod(
        'ouvrirReglagesConversation',
        {'id': idConversation},
      );
    } on PlatformException catch (_) {}
  }
}
