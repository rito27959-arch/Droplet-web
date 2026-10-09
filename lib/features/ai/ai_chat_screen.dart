// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ÉCRAN DE L'ASSISTANT IA — une conversation avec un modèle qui tourne
// entièrement sur l'appareil (voir `ai_assistant_service.dart`).
//
// ⚠️ CET ÉCRAN N'EST DÉLIBÉRÉMENT PAS UNE COPIE DE `chat_screen.dart`.
//
// Une conversation avec l'assistant n'a ni relais mesh, ni accusé de
// réception, ni chiffrement à négocier, ni réactions, ni citations, ni
// disparition programmée — toute la complexité de `chat_screen.dart`
// existe pour des raisons qui ne s'appliquent tout simplement pas ici.
// Recopier cette complexité aurait été porter un poids pour rien ; cet
// écran ne fait que ce dont il a besoin : une liste de bulles, un champ
// de texte, et un modèle qui répond.
//
// ── CE QUI S'INSPIRE DE CHATGPT/CLAUDE, ET POURQUOI ─────────────────────
//
// Trois détails empruntés aux grandes apps de conversation IA, chacun
// pour une raison précise :
//
//   1. LA MÉMOIRE SURVIT À LA FERMETURE DE L'ÉCRAN. Avant, `_messages`
//      n'existait qu'en mémoire vive du widget : fermer l'assistant
//      effaçait la conversation, et le modèle ne se souvenait de rien à
//      la réouverture. Elle est maintenant persistée (voir
//      `_chargerHistorique`/`_sauvegarderHistorique`) ET réinjectée dans
//      le VRAI contexte du modèle (`restaurerHistorique`) — pas
//      seulement rejouée à l'écran.
//
//   2. UN BOUTON D'ARRÊT PENDANT LA GÉNÉRATION. Sans lui, la seule façon
//      d'interrompre une réponse trop longue était de fermer l'écran.
//
//   3. UN CURSEUR QUI CLIGNOTE ET UN INDICATEUR DE FRAPPE. Le signal
//      visuel qui dit « ça continue » pendant l'attente du premier
//      jeton, puis pendant que le texte arrive.
//
//   4. UNE MÉMOIRE LONGUE, ET UNE CONNAISSANCE DE L'APP. En plus de la
//      conversation récente, l'assistant reçoit en amorce une fiche
//      BRÈVE de Droplet (`ai_knowledge.dart` — plafonnée pour ne pas
//      faire déborder le contexte, voir son en-tête) et les faits que
//      l'utilisateur lui a demandé de retenir (`ai_memory_store.dart` —
//      « retiens que… », persistés, réinjectés à chaque ouverture). Le
//      pseudo de l'utilisateur, lu depuis l'identité mesh, est injecté
//      lui aussi.
//
// ⚠️ CE QUI N'EST PAS FAIT, ET POURQUOI : PAS DE VRAI « RAG ».
//
// Un vrai système de mémoire à la ChatGPT (récupération d'information
// dans une base vectorielle) suppose un modèle d'embedding et un index
// vectoriel embarqués — exactement les bibliothèques MediaPipe qui ont
// été EXCLUES de l'APK pour l'alléger de 90 Mo (voir
// `android/app/build.gradle.kts`). La mémoire longue est donc une
// LISTE, pas un index : tout le bloc est réinjecté tel quel à chaque
// ouverture, ce qui la borne à quelques dizaines de faits (voir
// `ai_memory_store.dart`). Honnête et proportionné, pas la parité avec
// un grand modèle en ligne.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/mesh_provider.dart'
    show toastProvider, DropletToastType, meshRepositoryProvider;
import '../../core/services/ai_assistant_service.dart';
import '../../core/services/ai_memory_store.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart' show currentAppLocale;
import 'rendu_markdown.dart';
import '../../design_system/ouro_motion.dart';
import 'lueur_gemini.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../../design_system/ouro_avatar.dart';
import '../../design_system/glassmorphism.dart';
import 'etat_assistant.dart';
import '../../core/services/agents_groq.dart';
import '../../core/services/artefacts_store.dart';
import '../../core/services/conversations_ia_store.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/lecture_pdf.dart';
import '../../core/services/outils_assistant.dart';
import '../../core/services/production_fichiers.dart';
import 'artefact_screen.dart';
import 'assistant_tiroir.dart';
import 'composeur_assistant.dart';
import 'conversations_screen.dart';
import 'journal_activite.dart';
import 'mode_vocal.dart';
import 'reglages_assistant_screen.dart';

/// Contexte passé à l'assistant quand on l'ouvre depuis une conversation
/// (« Demander à l'assistant » — voir `chat_screen.dart`). [contexte] est
/// la fin de l'échange avec le pair, mise en forme pour le modèle ;
/// [invite] est le texte pré-rempli dans le champ de saisie, que
/// l'utilisateur peut ajuster avant d'envoyer.
class AiSeed {
  const AiSeed({required this.contexte, required this.invite});
  final String contexte;
  final String invite;
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.seed});

  final AiSeed? seed;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AssistantMessage {
  _AssistantMessage({
    required this.texte,
    required this.deMoi,
    this.avis = 0,
    this.origine = OrigineReponse.local,
    this.id,
  });

  String texte;
  final bool deMoi;

  /// L'avis donné à une réponse : 1 j'aime, −1 je n'aime pas, 0 rien.
  int avis;

  /// Ce message est le « Désolé, une erreur s'est produite » de l'assistant.
  ///
  /// ⚠️ ON GARDE LE FAIT, PAS LA PHRASE. Le texte était enregistré tel
  /// quel, dans la langue du MOMENT de l'erreur : une erreur survenue en
  /// espagnol restait en espagnol pour toujours — jusque dans l'aperçu de
  /// la liste des discussions, au milieu d'une interface en anglais. Il est
  /// maintenant recomposé à chaque chargement, dans la langue courante.
  bool erreur = false;

  /// ⚠️ PAR MESSAGE, PAS PAR CONVERSATION. Une même conversation
  /// mélange les deux dès qu'on refait une réponse en ligne ; sans
  /// cette information, impossible de dire en relisant ce qui a quitté
  /// le téléphone.
  OrigineReponse origine;

  /// L'identifiant en base, quand le message y est enregistré.
  String? id;

  /// Ce que l'assistant a FAIT pour répondre, dans l'ordre.
  final List<EtapeActivite> etapes = [];

  /// Les sources citées par la recherche web, extraites du texte.
  final List<Citation> citations = [];

  /// Les artéfacts sortis du fil pour ce message.
  final List<String> artefacts = [];

  /// Les fichiers joints à la question, ou produits par la réponse.
  final List<String> fichiers = [];

  /// Le raisonnement, quand le modèle en expose un.
  String? reflexion;

  /// Trois questions que la personne pourrait vouloir poser ensuite.
  final List<String> suites = [];
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_AssistantMessage> _messages = [];
  bool _genereEnCours = false;

  /// La synthèse vocale du système — hors ligne, comme le reste.
  final FlutterTts _voix = FlutterTts();

  /// L'index de la réponse lue à voix haute, s'il y en a une.
  int? _enLecture;

  /// Vrai une fois l'historique réinjecté dans le contexte du modèle —
  /// pour ne le faire qu'une seule fois par ouverture d'écran, quel que
  /// soit le nombre de fois où [AiAssistantState] change ensuite.
  bool _historiqueRestaure = false;

  /// Vrai une fois le contexte d'un [AiSeed] injecté dans le modèle — une
  /// seule fois, comme [_historiqueRestaure].
  bool _seedApplique = false;

  static const _cleStorage = 'ai_chat_historique';

  // ══ LE MODE EN LIGNE ═══════════════════════════════════════════════

  final GroqService _groq = GroqService();

  /// Le tiroir s'ouvre par une clé, pas par `Scaffold.of` : l'icône qui
  /// l'ouvre vit dans l'`AppBar`, donc dans le MÊME `BuildContext` que
  /// le `Scaffold`, où `Scaffold.of` ne le trouve pas.
  final GlobalKey<ScaffoldState> _cleScaffold = GlobalKey<ScaffoldState>();

  ConversationsIaStore? _conversations;
  ArtefactsStore? _artefacts;
  String? _conversationId;

  /// ⚠️ EN LIGNE PAR DÉFAUT — ET C'EST UN REVIREMENT ASSUMÉ.
  ///
  /// Le principe reste celui de `selecteur_moteur.dart` : ce choix dit OÙ
  /// PART le message, et il appartient à la personne. Mais le défaut ne
  /// peut pas être un mode qui exige d'abord 529 Mo de téléchargement :
  /// ce serait choisir à sa place de dépenser son forfait.
  ///
  /// Donc : en ligne tant que le modèle local n'est pas installé, et le
  /// local reprend la main dès qu'il l'est (voir `_ouvrirMagasins`).
  OrigineReponse _moteur = OrigineReponse.enLigne;

  /// Le modèle local est-il chargé et prêt à répondre ?
  bool get _localPret => ref.read(aiAssistantProvider) is AiReady;

  /// Le fichier du modèle est-il présent, indépendamment du chargement ?
  /// Renseigné une fois à l'ouverture, sans rien télécharger.
  bool _localInstalle = false;

  /// Faux tant qu'aucune clé n'est configurée : la bascule reste
  /// visible mais mène à l'explication.
  bool _enLigneDisponible = false;

  /// La couche vocale est-elle posée à la place du composeur ?
  ///
  /// ⚠️ UNE COUCHE, PAS UN ÉCRAN. Le mode vocal ne pousse plus rien sur
  /// la pile de navigation : il remplace le composeur et laisse la
  /// conversation visible derrière, qui défile pendant qu'on parle.
  /// Gemini Live a quitté le plein écran en avril 2026 pour cette raison,
  /// et elle vaut ici : le tour vocal atterrit VRAIMENT dans ce fil, donc
  /// le cacher pendant qu'il s'y écrit n'avait aucun sens.
  bool _vocalOuvert = false;

  /// Les sous-titres de la couche vocale. L'état vit ici parce que la
  /// bascule est dans la barre du haut, pas dans la couche.
  ///
  /// ⚠️ ALLUMÉS NE VEUT PAS DIRE AFFICHÉS, et c'est la différence entre
  /// Droplet et Gemini. Gemini n'écrit RIEN dans le fil pendant qu'il
  /// parle — le transcript complet n'arrive qu'à la fin — donc sa boîte
  /// de sous-titres est le seul endroit où lire la réponse. Ici, le tour
  /// vocal s'écrit dans le fil en direct : quand la liste est collée en
  /// bas, la boîte répéterait mot pour mot la bulle posée 40 points plus
  /// haut. Deux affichages du même texte à cette distance, c'est la
  /// version visuelle du défaut « deux sources de vérité ».
  ///
  /// La boîte n'apparaît donc que lorsqu'elle sert VRAIMENT : quand on a
  /// fait défiler vers le haut pour relire quelque chose et que la
  /// réponse en cours est sortie du champ.
  bool _sousTitresVocal = true;

  /// Le fil est-il collé en bas ? Renseigné par [_mesurer].
  bool _filEnBas = true;

  /// Les pièces jointes en attente d'envoi.
  final List<String> _piecesJointes = [];

  /// Ce que l'assistant fait à l'instant, sous la réponse en cours.
  String? _etapeEnCours;

  /// La hauteur réelle du composeur, mesurée après chaque construction.
  ///
  /// ⚠️ MESURÉE, PAS DEVINÉE. Elle change avec le nombre de lignes tapées,
  /// les vignettes de pièces jointes, le bandeau de téléchargement et la
  /// taille de police du système. Une valeur en dur laisserait le dernier
  /// message caché derrière le composeur chez quiconque grossit son texte.
  final GlobalKey _cleComposeur = GlobalKey();
  double _hauteurComposeur = 96;

  /// De 0 à 1 : à quel point le verre du composeur est chargé.
  ///
  /// Zéro quand la conversation est en bas — rien ne passe dessous, donc
  /// aucun voile. Il monte dès qu'on remonte le fil et que des messages
  /// glissent derrière.
  double _voile = 0;

  /// Nombre de messages gardés d'une session à l'autre.
  ///
  /// Pas une limite technique du stockage (`getString`/`setString`
  /// n'ont pas de plafond bas) : une conversation locale avec un
  /// assistant qui n'a ni recherche ni renvoi vers un message précis
  /// n'a pas d'usage réaliste à en accumuler des centaines. Garder les
  /// plus récents suffit à retrouver le fil en rouvrant l'écran.
  static const _maxMessagesConserves = 40;

  @override
  void initState() {
    super.initState();
    AiMemoire.charger();
    _chargerHistorique();
    void finDeLecture() {
      if (mounted) setState(() => _enLecture = null);
    }
    _voix.setCompletionHandler(finDeLecture);
    _voix.setCancelHandler(finDeLecture);
    _voix.setErrorHandler((_) => finDeLecture());
    // Donne à l'assistant le contexte de QUI lui parle — son pseudo,
    // depuis l'identité mesh — AVANT de lancer le chargement : le pseudo
    // n'est injecté qu'une fois, au moment de l'amorçage de la session.
    final pseudo = ref.read(meshRepositoryProvider).myPseudo;
    ref
        .read(aiAssistantProvider.notifier)
        .definirContexteUtilisateur(pseudo: pseudo);
    // Ouvert depuis « Demander à l'assistant » : on pré-remplit le champ
    // avec l'invite, l'utilisateur peut l'ajuster puis envoyer. Le
    // contexte de la conversation, lui, est injecté dans le modèle une
    // fois qu'il est prêt (voir le `ref.listen` dans [build]).
    if (widget.seed != null) {
      _inputCtrl.text = widget.seed!.invite;
    }
    // ⚠️ ON NE TÉLÉCHARGE PLUS RIEN À L'OUVERTURE.
    //
    // Avant, ouvrir l'assistant lançait le téléchargement des 529 Mo du
    // modèle local sans rien demander : sur un forfait compté, c'est une
    // facture ; sur une connexion lente, c'est un écran bloqué pendant
    // plusieurs minutes pour quelqu'un qui voulait juste poser une
    // question. Ouvrir un écran n'est pas consentir à un demi-gigaoctet.
    //
    // L'interface s'affiche donc tout de suite, en mode en ligne. Le
    // modèle local ne se télécharge QUE si la personne choisit « Local »
    // et confirme — voir `_changerMoteur`.
    unawaited(_ouvrirMagasins());
  }

  /// Ouvre les deux bases et reprend la dernière conversation.
  ///
  /// ⚠️ TOUT ÉCHEC EST AVALÉ ICI, VOLONTAIREMENT. Si la base des
  /// conversations ne s'ouvre pas, l'assistant doit rester utilisable en
  /// mode « un seul fil », comme avant : on perd l'historique multiple,
  /// on ne perd pas l'assistant. Une exception remontée ici afficherait
  /// un écran d'erreur pour une fonctionnalité accessoire.
  Future<void> _ouvrirMagasins() async {
    try {
      final c = await ConversationsIaStore.ouvrir();
      final a = await ArtefactsStore.ouvrir();
      final dispo = await _groq.disponible();
      // ⚠️ SONDE, PAS TÉLÉCHARGEMENT. `estInstalle` regarde le disque et
      // s'arrête là.
      final installe =
          await ref.read(aiAssistantProvider.notifier).estInstalle();
      if (!mounted) return;
      final liste = c.conversations();
      if (!mounted) return;
      setState(() {
        _conversations = c;
        _artefacts = a;
        _enLigneDisponible = dispo;
        _conversationId =
            liste.isNotEmpty ? liste.first.id : c.creerConversation();
        _localInstalle = installe;
        // Le modèle est déjà là : rien à télécharger, donc on revient au
        // mode qui ne fait sortir aucun message du téléphone. Sinon on
        // reste en ligne, et la bascule expliquera ce qui manque.
        if (installe) _moteur = OrigineReponse.local;
      });
      // Le fichier est là mais pas encore en RAM : `ensureDownloaded` ne
      // télécharge rien dans ce cas, il se contente de charger. C'est le
      // SEUL appel automatique qui subsiste, et il est conditionné.
      if (installe) {
        unawaited(ref.read(aiAssistantProvider.notifier).ensureDownloaded());
      }
    } on Object catch (e) {
      debugPrint('Assistant : magasins indisponibles — $e');
    }
  }

  /// Recalcule le voile et la hauteur après chaque trame.
  void _mesurer() {
    final boite =
        _cleComposeur.currentContext?.findRenderObject() as RenderBox?;
    final h = boite?.size.height ?? _hauteurComposeur;
    // Le verre se charge sur 40 points de défilement, comme la barre de
    // navigation d'iOS — assez pour que l'apparition soit un fondu et non
    // un déclic.
    final reste = _scrollCtrl.hasClients
        ? _scrollCtrl.position.extentAfter
        : 0.0;
    final v = (reste / 40).clamp(0.0, 1.0);
    // Le fil est-il collé en bas ? Sert aux sous-titres de la couche
    // vocale — voir `_sousTitresVocal`.
    final enBas = !_scrollCtrl.hasClients || reste < 8;
    if ((h - _hauteurComposeur).abs() > 0.5 ||
        (v - _voile).abs() > 0.01 ||
        enBas != _filEnBas) {
      setState(() {
        _hauteurComposeur = h;
        _voile = v;
        _filEnBas = enBas;
      });
    }
  }

  @override
  void dispose() {
    unawaited(_voix.stop());
    _groq.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Recharge la conversation précédente à l'écran. Le contexte du
  /// modèle, lui, n'est réinjecté qu'une fois l'assistant prêt — voir
  /// le `ref.listen` dans [build].
  void _chargerHistorique() {
    final brut = StorageService.getString(_cleStorage);
    if (brut == null || brut.isEmpty) return;
    try {
      final liste = jsonDecode(brut) as List<dynamic>;
      _messages.addAll(
        liste.map((e) {
          final m = e as Map<String, dynamic>;
          final erreur = m['e'] == true;
          return _AssistantMessage(
            texte: erreur
                ? lookupAppLocalizations(currentAppLocale()).aiGenericError
                : m['t'] as String? ?? '',
            deMoi: m['m'] as bool? ?? false,
            avis: m['a'] as int? ?? 0,
          )..erreur = erreur;
        }),
      );
    } catch (_) {
      // Historique illisible (format changé entre deux versions, fichier
      // tronqué) : on repart d'une conversation vide plutôt que de
      // planter l'écran pour ça.
    }
  }

  /// [echange] : faux quand rien n'a été dit — une note posée sur une
  /// réponse ne doit pas faire remonter l'heure du dernier échange.
  Future<void> _sauvegarderHistorique({bool echange = true}) async {
    final aGarder = _messages.length > _maxMessagesConserves
        ? _messages.sublist(_messages.length - _maxMessagesConserves)
        : _messages;
    final donnees = jsonEncode(
      aGarder
          .map((m) => {
                't': m.erreur ? '' : m.texte,
                'm': m.deMoi,
                if (m.avis != 0) 'a': m.avis,
                if (m.erreur) 'e': true,
              })
          .toList(),
    );
    await StorageService.setString(_cleStorage, donnees);
    // L'heure du dernier échange : la ligne de l'assistant, dans la liste
    // des discussions, l'affiche comme n'importe quelle conversation.
    if (echange && aGarder.isNotEmpty) {
      await StorageService.setString(
        'ai_chat_quand',
        '${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  void _scrollEnBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: DesignTokens.durationStandard,
        curve: DesignTokens.curveEnter,
      );
    });
  }

  // ⚠️ PAS LA MÊME CHOSE QUE [_scrollEnBas] — ET C'EST VOULU.
  //
  // Pendant qu'une réponse s'écrit jeton par jeton, [_envoyer] appelait
  // [_scrollEnBas] à CHAQUE jeton — soit une nouvelle animation de
  // 250 ms relancée par-dessus la précédente encore en vol, plusieurs
  // fois par seconde. Le défilement n'accompagnait alors jamais
  // vraiment le texte : il rattrapait sans cesse une cible qui
  // s'éloignait déjà, ce qui se voit comme un tremblement plutôt
  // qu'un suivi fluide. Un déplacement instantané, lui, ne peut pas
  // entrer en conflit avec lui-même — c'est ainsi que les grandes
  // apps de conversation IA gardent la réponse épinglée en bas
  // pendant qu'elle s'écrit, et réservent l'animation au moment où
  // une nouvelle question part.
  void _suivreEnBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    });
  }

  /// Reconnaît une demande d'effacement de la mémoire longue
  /// (« oublie tout », « efface ta mémoire »…). Volontairement plus
  /// strict que [AiMemoire.detecterDemande] : on ne vide pas la mémoire
  /// sur une tournure ambiguë.
  static final _demandeOubliTotal = RegExp(
    r"^(oublie tout|oublie ce que je t'?ai (dit|demand[ée])|"
    r"efface ta m[ée]moire|vide ta m[ée]moire|remets ta m[ée]moire à z[ée]ro)\b",
    caseSensitive: false,
  );

  /// Traite une éventuelle consigne de mémoire portée par [texte] :
  /// persiste le fait (ou vide la mémoire), montre un toast, et met à
  /// jour la mémoire vive du modèle. À appeler AVANT d'envoyer le message
  /// au modèle — le message part ensuite normalement, pour que
  /// l'assistant l'accuse naturellement dans sa réponse.
  Future<void> _traiterMemoire(String texte) async {
    final notifier = ref.read(aiAssistantProvider.notifier);
    if (_demandeOubliTotal.hasMatch(texte.trim())) {
      await AiMemoire.toutOublier();
      await notifier.rafraichirMemoire();
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              AppLocalizations.of(context).aiMemoryForgotten,
              type: DropletToastType.success,
            );
      }
      return;
    }
    final fait = AiMemoire.detecterDemande(texte);
    if (fait != null) {
      await AiMemoire.retenir(fait);
      await notifier.rafraichirMemoire();
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              AppLocalizations.of(context).aiMemorySaved,
              type: DropletToastType.success,
            );
      }
    }
  }

  Future<void> _envoyer() async {
    final texte = _inputCtrl.text.trim();
    if (texte.isEmpty || _genereEnCours) return;
    OuroHaptics.selection();
    _inputCtrl.clear();
    await _traiterMemoire(texte);
    if (!mounted) return;
    final jointes = List<String>.from(_piecesJointes);
    setState(() {
      final question = _AssistantMessage(texte: texte, deMoi: true)
        ..fichiers.addAll(jointes);
      _messages
        ..add(question)
        ..add(_AssistantMessage(texte: '', deMoi: false));
      _piecesJointes.clear();
      _genereEnCours = true;
      assistantEcrit.value = true;
    });
    _scrollEnBas();

    final reponse = _messages.last;
    reponse.origine = _moteur;
    try {
      if (_moteur == OrigineReponse.enLigne) {
        await _repondreEnLigne(texte, reponse);
      } else {
        await for (final jeton
            in ref.read(aiAssistantProvider.notifier).envoyer(texte)) {
          if (!mounted) return;
          setState(() => reponse.texte += jeton);
          _suivreEnBas();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => reponse
        ..texte = AppLocalizations.of(context).aiGenericError
        ..erreur = true);
    } finally {
      // Hors de la garde `mounted` : la réponse a pu finir après qu'on
      // a quitté l'écran, et la liste doit le savoir.
      assistantEcrit.value = false;
      if (mounted) {
        setState(() {
          _genereEnCours = false;
          _etapeEnCours = null;
        });
        // ⚠️ DANS CET ORDRE. Les citations sont retirées du texte AVANT
        // d'y chercher des artéfacts et avant de l'enregistrer : sinon
        // on garderait en base une version pleine de marqueurs que
        // personne ne sait plus relire.
        _extraireCitations(reponse);
        _detecterArtefacts(reponse);
        _enregistrer(texte, reponse, jointes);
        unawaited(_proposerSuites(reponse));
      }
      unawaited(_sauvegarderHistorique());
    }
  }

  /// La réponse en ligne, outils compris.
  ///
  /// ⚠️ UNE BOUCLE, PAS UN APPEL. Le modèle peut demander un outil,
  /// recevoir son résultat, puis en demander un autre. Sans boucle on
  /// s'arrêterait au premier, et la réponse serait amputée sans que rien
  /// ne le signale.
  ///
  /// La borne de cinq tours n'est pas décorative : un modèle qui se
  /// trompe d'outil peut le redemander indéfiniment, et chaque tour est
  /// une requête facturée. Au-delà, on rend ce qu'on a.
  Future<void> _repondreEnLigne(
    String question,
    _AssistantMessage reponse,
  ) async {
    final l10n = AppLocalizations.of(context);
    final jointes = _messages[_messages.length - 2].fichiers;
    final historique = <MessageIa>[
      MessageIa(role: 'system', contenu: _consignes()),
      // Les échanges précédents, sauf les deux qu'on vient d'ajouter.
      for (final m in _messages.take(_messages.length - 2))
        MessageIa(role: m.deMoi ? 'user' : 'assistant', contenu: m.texte),
      MessageIa(role: 'user', contenu: _avecJointes(question, jointes)),
    ];

    final outils = outilsPour(enLigne: true, nbPiecesJointes: jointes.length);
    final executeur = ExecuteurOutils(
      piecesJointes: jointes,
      lireFichier: _lireJointe,
      produireFichier: (nom, format, contenu) =>
          produireFichier(nom: nom, format: format, contenu: contenu),
      memoriser: AiMemoire.retenir,
      deleguer: _deleguer,
      creerProjet: (nom, fichiers) =>
          creerProjet(nom: nom, fichiers: fichiers),
    );

    for (var tour = 0; tour < 5; tour++) {
      final appels = <AppelOutil>[];
      var texteDuTour = '';

      await for (final morceau in _groq.repondre(
        messages: historique,
        outils: outils,
        modele: kModeleChef,
        // ⚠️ PAS DE FLUX AVEC LES OUTILS INTÉGRÉS DE GROQ. Leur
        // documentation ne montre que `stream: false` et ne dit pas si
        // le flux marche ; on ne parie pas dessus. C'est le journal
        // d'activité qui occupe l'attente, ce pour quoi il existe.
        flux: !contraintSansFlux(outils),
      )) {
        if (!mounted) return;
        switch (morceau) {
          case MorceauTexte(:final texte):
            texteDuTour += texte;
            setState(() => reponse.texte += texte);
            _suivreEnBas();
          case MorceauReflexion(:final texte):
            setState(
              () => reponse.reflexion = (reponse.reflexion ?? '') + texte,
            );
          // `appels: final recus` et non `:final appels` : le second
          // lierait la variable sous le nom `appels`, qui est déjà pris
          // par l'accumulateur du tour.
          case MorceauOutils(appels: final recus):
            appels.addAll(recus);
          case MorceauFin():
            break;
        }
      }

      if (appels.isEmpty) return;

      // Le modèle a demandé des outils : on les exécute, on lui rend les
      // résultats, et on repart pour un tour.
      historique.add(
        MessageIa(role: 'assistant', contenu: texteDuTour, appels: appels),
      );
      for (final appel in appels) {
        if (!mounted) return;
        setState(() => _etapeEnCours = _libelleOutil(appel.nom, l10n));
        final r = await executeur.executer(appel.nom, appel.arguments());
        if (!mounted) return;
        setState(() {
          reponse.etapes.add(r.etape);
          _etapeEnCours = null;
          if (r.fichierProduit != null) {
            reponse.fichiers.add(r.fichierProduit!);
          }
        });
        historique.add(
          MessageIa(
            role: 'tool',
            contenu: r.pourLeModele,
            nomOutil: appel.nom,
            idAppel: appel.id,
          ),
        );
      }
    }
  }

  /// Demande trois suites possibles à la conversation.
  ///
  /// ── POURQUOI UN AUTRE MODÈLE ──────────────────────────────────────
  ///
  /// C'est exactement le travail de l'agent `rapide` : trois phrases
  /// courtes, sans raisonnement. Les demander au chef coûterait un appel
  /// complet d'un modèle de 120 milliards de paramètres pour trente
  /// mots — et surtout, la personne attendrait.
  ///
  /// ⚠️ APRÈS COUP, JAMAIS AVANT. On ne fait pas patienter quelqu'un
  /// devant une réponse déjà écrite pour lui proposer des questions
  /// qu'il n'a pas demandées. L'appel part une fois la réponse rendue,
  /// et les pastilles apparaissent quand elles arrivent — ou jamais, si
  /// ça échoue, sans que personne ne s'en aperçoive.
  Future<void> _proposerSuites(_AssistantMessage reponse) async {
    if (_moteur != OrigineReponse.enLigne) return;
    if (reponse.texte.trim().length < 80) return;
    try {
      final brut = await _deleguer(
        Agent.rapide,
        'Voici une réponse donnée à quelqu’un :\n\n'
        '${reponse.texte.length > 1500 ? reponse.texte.substring(0, 1500) : reponse.texte}\n\n'
        'Écris TROIS questions courtes que cette personne pourrait vouloir '
        'poser ensuite, dans sa langue. Une par ligne, sans numéro, sans '
        'tiret, sans guillemets. Six mots au plus chacune.',
      );
      if (!mounted) return;
      final lignes = brut
          .split('\n')
          .map((l) => l.replaceAll(RegExp(r'^[\s\d.\-•*"«»]+|["«»]+\$'), '').trim())
          .where((l) => l.length > 6 && l.length < 70)
          .take(3)
          .toList();
      if (lignes.isEmpty) return;
      setState(() => reponse.suites
        ..clear()
        ..addAll(lignes));
    } on Object {
      // Une suggestion qui n'arrive pas ne manque à personne.
    }
  }

  /// Sort les citations du texte et les range à part — laissées dedans,
  /// elles s'affichent en rectangles au milieu des phrases.
  void _extraireCitations(_AssistantMessage m) {
    final r = extraireCitations(m.texte);
    if (r.citations.isEmpty) return;
    setState(() {
      m.texte = r.texte;
      m.citations
        ..clear()
        ..addAll(r.citations);
    });
  }

  /// Ce que l'assistant doit savoir de lui-même, en ligne.
  String _consignes() {
    // `AiMemoire.bloc` rend déjà le texte mis en forme, ou `null`. On
    // s'en sert tel quel : reconstruire la phrase ici ferait diverger le
    // mode local et le mode en ligne sur ce que l'assistant croit savoir.
    final bloc = AiMemoire.bloc;
    final sue = bloc == null ? '' : '\n\n$bloc';
    // ⚠️ LE CATALOGUE DES COLLÈGUES N'A DE SENS QU'EN LIGNE. Hors ligne
    // il n'y a qu'un modèle, et lui parler de délégation le pousserait à
    // appeler un outil qui n'existe pas — puis à s'excuser.
    final equipe = _moteur == OrigineReponse.enLigne
        ? '\n\n${cataloguePourLeChef()}'
        : '';
    return 'Tu es l\'assistant de Droplet, une messagerie qui fonctionne '
        'sans réseau. Réponds dans la langue de la personne. Sois bref : '
        'deux ou trois phrases suffisent le plus souvent. Quand tu produis '
        'un document, un tableau ou du code à garder, emploie l\'outil '
        'produire_fichier au lieu de tout recopier dans la réponse. Pour '
        'un ensemble de fichiers — un site, une application, un dossier '
        'de documents — emploie creer_projet.$sue$equipe';
  }

  /// Exécute une consigne avec un autre agent et rend son texte.
  ///
  /// ⚠️ LE COLLÈGUE NE VOIT PAS LA CONVERSATION, et ne reçoit AUCUN
  /// outil. Deux raisons : il travaille sur la consigne que le chef lui
  /// écrit, ce qui oblige ce dernier à être explicite ; et un collègue
  /// outillé pourrait déléguer à son tour, deux modèles se renvoyant la
  /// balle jusqu'à épuisement du quota.
  Future<String> _deleguer(Agent agent, String consigne) async {
    final f = kAgents[agent]!;
    final b = StringBuffer();
    await for (final m in _groq.repondre(
      messages: [
        MessageIa(
          role: 'system',
          contenu: 'Tu es un collègue spécialisé. Ton rôle : ${f.role}. '
              'Exécute la consigne et rends le résultat, sans préambule '
              'ni commentaire sur la consigne elle-même.',
        ),
        MessageIa(role: 'user', contenu: consigne),
      ],
      modele: f.modele,
      temperature: f.temperature,
      // On lui laisse toute sa marge de sortie : c'est précisément pour
      // ça qu'on l'a choisi.
      maxJetons: f.sortieMax,
      effort: f.effort,
    )) {
      if (m is MorceauTexte) b.write(m.texte);
    }
    return b.toString().trim();
  }

  static String _avecJointes(String question, List<String> jointes) {
    if (jointes.isEmpty) return question;
    final liste = [
      for (var i = 0; i < jointes.length; i++)
        '${i + 1}. ${jointes[i].split('/').last}',
    ].join('\n');
    return '$question\n\nPièces jointes :\n$liste';
  }

  /// ⚠️ ON DIT CE QU'ON NE SAIT PAS LIRE. Rendre les octets bruts d'un
  /// fichier au modèle lui ferait inventer un contenu à partir de rien,
  /// ce qui est pire qu'un refus franc.
  static Future<String> _lireJointe(String chemin) async {
    final point = chemin.lastIndexOf('.');
    final ext = point < 0 ? '' : chemin.substring(point).toLowerCase();

    if (ext == '.pdf') {
      final t = await lirePdfFichier(chemin);
      // ⚠️ UN PDF SCANNÉ EST UNE IMAGE. Il n'y a rien à extraire, et
      // aucun modèle de Groq ne sait plus regarder une image. On le dit,
      // plutôt que de laisser le modèle broder sur un document vide.
      return t ??
          'Ce PDF ne contient aucun texte extractible — c’est '
              'probablement un document scanné, c’est-à-dire une image. '
              'Dis-le à la personne et demande-lui le texte autrement.';
    }

    const lisibles = {
      '.txt', '.md', '.csv', '.json', '.dart', '.py', '.js', '.ts',
      '.html', '.css', '.yaml', '.yml', '.xml', '.log', '.sh', '.java',
      '.kt', '.swift', '.go', '.rs', '.c', '.cpp', '.h', '.sql',
    };
    if (lisibles.contains(ext)) return File(chemin).readAsString();
    return 'Ce format n\'est pas lisible par l\'assistant ($ext).';
  }

  static String _libelleOutil(String nom, AppLocalizations l10n) =>
      switch (nom) {
        'lire_piece_jointe' => l10n.aiToolReading,
        'produire_fichier' => l10n.aiToolWriting,
        'memoriser' => l10n.aiToolRemembering,
        _ => l10n.jaWorking,
      };

  /// Sort du fil ce qui mérite sa propre surface.
  void _detecterArtefacts(_AssistantMessage reponse) {
    final store = _artefacts;
    final conv = _conversationId;
    if (store == null || conv == null || reponse.deMoi) return;
    for (final bloc in detecterBlocs(reponse.texte)) {
      if (!meriteArtefact(contenu: bloc.contenu, genre: bloc.genre)) continue;
      reponse.artefacts.add(
        store.creer(
          conversationId: conv,
          titre: titrePour(bloc, reponse.texte),
          genre: bloc.genre,
          contenu: bloc.contenu,
          langage: bloc.langage,
        ),
      );
    }
  }

  void _enregistrer(
    String question,
    _AssistantMessage reponse,
    List<String> jointes,
  ) {
    final store = _conversations;
    final conv = _conversationId;
    if (store == null || conv == null) return;
    store.ajouterMessage(
      conversationId: conv,
      role: 'user',
      contenu: question,
      piecesJointes: jointes,
    );
    reponse.id = store.ajouterMessage(
      conversationId: conv,
      role: 'assistant',
      contenu: reponse.texte,
      origine: reponse.origine,
      reflexion: reponse.reflexion,
      etapes: reponse.etapes,
      piecesJointes: reponse.fichiers,
    );
  }

  /// Interrompt la génération en cours — le bouton d'envoi devient un
  /// bouton d'arrêt pendant que l'assistant répond.
  ///
  /// ⚠️ ON ARRÊTE LES DEUX, SANS SE DEMANDER LEQUEL TOURNE. Tester
  /// `_moteur` ici serait juste la plupart du temps et faux dans le cas
  /// qui compte : si la personne bascule pendant que ça génère, on
  /// arrêterait le moteur qui ne travaille pas. Les deux appels sont
  /// sans effet quand il n'y a rien à interrompre.
  Future<void> _arreter() async {
    OuroHaptics.light();
    _groq.arreter();
    await ref.read(aiAssistantProvider.notifier).arreterGeneration();
  }

  /// Ouvre la feuille « Mémoire de l'assistant » : la liste de ce que
  /// l'utilisateur a demandé de retenir, avec la possibilité d'oublier
  /// une entrée ou tout.
  Future<void> _ouvrirMemoire() async {
    OuroHaptics.selection();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: OuroColors.systemBackground,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _MemoireSheet(),
    );
    if (mounted) setState(() {}); // refléter un éventuel changement au retour
  }

  Future<void> _nouvelleConversation() async {
    // ⚠️ PLUS DE SORTIE ANTICIPÉE SUR `_messages.isEmpty`. Depuis le
    // tiroir, « Nouvelle session » doit fermer le tiroir et créer un fil
    // même si l'écran est déjà vide — sinon le bouton ne fait rien et on
    // le croit cassé.
    OuroHaptics.selection();
    if (_cleScaffold.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    final store = _conversations;
    setState(() {
      _messages.clear();
      _piecesJointes.clear();
      if (store != null) _conversationId = store.creerConversation();
    });
    await StorageService.setString(_cleStorage, '');
    // Effacer aussi le contexte du modèle : sans ça, l'assistant se
    // souviendrait encore d'une conversation qu'on vient pourtant
    // d'effacer à l'écran — une mémoire qui contredit ce qu'on voit.
    await ref.read(aiAssistantProvider.notifier).effacerConversation();
  }

  /// Change de moteur — en demandant d'abord, quand ça coûte un
  /// téléchargement.
  ///
  /// ⚠️ LE DIALOGUE N'EST PAS UNE POLITESSE. 529 Mo, c'est un forfait
  /// entamé pour beaucoup de gens, et ça se décide en connaissance de
  /// cause : la taille est écrite dans le texte, pas cachée derrière
  /// « Continuer ». Un refus laisse le moteur inchangé.
  Future<void> _changerMoteur(OrigineReponse voulu) async {
    // ⚠️ LA CLÉ MANQUANTE SE TRAITE AVANT TOUT, même si le moteur ne
    // change pas. Depuis que « en ligne » est le défaut, quelqu'un sans
    // clé est déjà dessus : une sortie anticipée sur « rien ne change »
    // laisserait la seule ligne qui mène à la configuration sans effet.
    if (voulu == OrigineReponse.enLigne && !_enLigneDisponible) {
      await _allerA(DestinationAssistant.reglages);
      return;
    }
    if (voulu == _moteur) return;

    if (voulu == OrigineReponse.local && !_localInstalle) {
      final ok = await _confirmerTelechargement();
      if (!ok || !mounted) return;
      // Le téléchargement démarre ici, et nulle part ailleurs.
      setState(() => _localInstalle = true);
      unawaited(ref.read(aiAssistantProvider.notifier).ensureDownloaded());
    }
    if (mounted) setState(() => _moteur = voulu);
  }

  /// Ouvre le mode vocal — ou l'écran de la clé, quand il n'y en a pas.
  ///
  /// ⚠️ ON VÉRIFIE AVANT D'OUVRIR. La transcription passe par Whisper,
  /// donc par le réseau : un écran vocal qui s'ouvre puis échoue au
  /// premier mot ferait croire que le micro est cassé. Sans clé, le
  /// bouton mène là où on peut en mettre une — exactement comme la
  /// pastille « En ligne ».
  Future<void> _ouvrirVocal() async {
    if (!_enLigneDisponible) {
      await _allerA(DestinationAssistant.reglages);
      return;
    }
    OuroHaptics.light();
    // Le clavier partirait de toute façon quand le composeur disparaît ;
    // le retirer d'abord évite qu'il se referme en sautant sur la couche.
    FocusScope.of(context).unfocus();
    setState(() => _vocalOuvert = true);
  }

  /// Le tour vocal passe par `_envoyer`, et c'est tout l'intérêt : ce
  /// qu'on dit à voix haute s'écrit dans LE MÊME FIL, avec les mêmes
  /// outils, la même mémoire et le même enregistrement. Un mode vocal
  /// qui tiendrait sa propre conversation à part laisserait deux
  /// historiques divergents dont aucun ne serait complet.
  Future<String> _repondreVocalement(String question) async {
    _inputCtrl.text = question;
    await _envoyer();
    if (!mounted) return '';
    if (_messages.isEmpty || _messages.last.deMoi) return '';
    return _messages.last.texte;
  }

  Future<bool> _confirmerTelechargement() async {
    final l10n = AppLocalizations.of(context);
    OuroHaptics.light();
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OuroColors.secondarySystemGroupedBackground,
        title: Text(l10n.aiDownloadTitle, style: OuroTypography.headline),
        content: Text(
          l10n.aiDownloadBody(kAiModelTailleMo),
          style: OuroTypography.subheadline.copyWith(
            color: OuroColors.secondaryLabel,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.aiDownloadConfirm),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  /// Remet à la personne un fichier que l'assistant a produit.
  Future<void> _partagerFichier(String chemin) async {
    OuroHaptics.light();
    await Share.shareXFiles([XFile(chemin)]);
  }

  /// Ouvre une conversation depuis le tiroir ou la recherche.
  void _ouvrirConversation(String id, {String? messageId}) {
    final store = _conversations;
    if (store == null) return;
    if (_cleScaffold.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    final stockes = store.messages(id);
    setState(() {
      _conversationId = id;
      _piecesJointes.clear();
      _messages
        ..clear()
        ..addAll([
          for (final m in stockes)
            _AssistantMessage(
              texte: m.contenu,
              deMoi: m.role == 'user',
              origine: m.origine,
              id: m.id,
            )
              ..etapes.addAll(m.etapes)
              ..fichiers.addAll(m.piecesJointes)
              ..reflexion = m.reflexion,
        ]);
    });
    // ⚠️ LE MODÈLE LOCAL DOIT SUIVRE. Changer les bulles sans réinjecter
    // le contexte laisserait l'assistant répondre à propos de la
    // conversation précédente — le défaut le plus déroutant qui soit.
    final notifier = ref.read(aiAssistantProvider.notifier);
    unawaited(() async {
      await notifier.effacerConversation();
      if (_messages.isNotEmpty) {
        await notifier.restaurerHistorique(
          _messages.map((m) => (m.texte, m.deMoi)).toList(),
        );
      }
    }());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollEnBas());
  }

  Future<void> _allerA(DestinationAssistant destination) async {
    final store = _conversations;
    final artefacts = _artefacts;
    if (_cleScaffold.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (!mounted) return;
    switch (destination) {
      case DestinationAssistant.memoire:
        await _ouvrirMemoire();
      case DestinationAssistant.reglages:
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReglagesAssistantScreen(
              // ⚠️ SANS CE RAPPEL, LA BASCULE RESTE GRISÉE. On revient de
              // l'écran avec une clé valide et le mode en ligne serait
              // toujours refusé jusqu'au prochain lancement.
              onChange: () async {
                final d = await _groq.disponible();
                if (mounted) setState(() => _enLigneDisponible = d);
              },
            ),
          ),
        );
      case DestinationAssistant.aide:
        if (mounted) await context.push<void>('/aide');
      case DestinationAssistant.recherche:
        if (store == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConversationsIaScreen(
              store: store,
              onOuvrir: (id, {messageId}) {
                Navigator.of(context).pop();
                _ouvrirConversation(id, messageId: messageId);
              },
              onNouvelle: (id) {
                Navigator.of(context).pop();
                _ouvrirConversation(id);
              },
            ),
          ),
        );
      case DestinationAssistant.artefacts:
        if (artefacts == null) return;
        await _listerArtefacts(artefacts);
    }
  }

  /// La liste des artéfacts, en feuille : elle est courte et sert de
  /// passage vers leur surface, pas d'écran à part entière.
  Future<void> _listerArtefacts(ArtefactsStore store) async {
    final l10n = AppLocalizations.of(context);
    final liste = store.tous();
    final choix = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: OuroColors.systemBackground,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: liste.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 48),
                child: Text(
                  l10n.arEmpty,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: liste.length,
                itemBuilder: (context, i) {
                  final a = liste[i];
                  return ListTile(
                    leading: Icon(
                      switch (a.genre) {
                        GenreArtefact.page => Icons.web_rounded,
                        GenreArtefact.code => Icons.code_rounded,
                        GenreArtefact.schema => Icons.account_tree_outlined,
                        GenreArtefact.donnees => Icons.table_chart_outlined,
                        GenreArtefact.document => Icons.description_outlined,
                      },
                      color: OuroColors.accent,
                    ),
                    title: Text(
                      a.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.body
                          .copyWith(color: OuroColors.label),
                    ),
                    subtitle: Text(
                      a.nbVersions > 1
                          ? l10n.arVersion(a.nbVersions)
                          : (a.langage.isEmpty ? '' : a.langage),
                      style: OuroTypography.caption1
                          .copyWith(color: OuroColors.secondaryLabel),
                    ),
                    onTap: () => Navigator.pop(context, a.id),
                  );
                },
              ),
      ),
    );
    if (choix != null && mounted) _ouvrirArtefact(choix);
  }

  void _ouvrirArtefact(String id) {
    final store = _artefacts;
    if (store == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArtefactScreen(store: store, artefactId: id),
      ),
    );
  }

  /// Ajoute un document à la question en préparation.
  ///
  /// ⚠️ PLUS DE PHOTO NI D'APPAREIL PHOTO — ET CE N'EST PAS UN RECUL.
  ///
  /// Groq ne sert plus aucun modèle capable de LIRE une image : Llama 4
  /// Scout et Maverick, les seuls, ont été retirés en juillet et mars
  /// 2026 (voir `agents_groq.dart`). Une photo jointe partait donc vers
  /// un modèle qui ne pouvait rien en faire, et la réponse était inventée
  /// à partir du seul nom du fichier — le pire cas possible : plausible
  /// et faux.
  ///
  /// Un bouton qui promet ce que le moteur ne sait pas faire est pire
  /// qu'un bouton absent. Il revient le jour où un modèle de vision
  /// revient, pas avant.
  ///
  /// La feuille des discussions n'est plus employée non plus : c'est une
  /// feuille de MÉDIAS — photos, autocollants, position, sondage — dont
  /// rien ne sert ici. La réutiliser, c'était réutiliser pour réutiliser.
  Future<void> _joindre(ActionJointe quoi) async {
    final r = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // ⚠️ `custom` ET NON `any` : proposer à quelqu'un un fichier que
      // l'assistant ne saura pas lire, c'est le laisser attendre une
      // réponse qui ne viendra pas.
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'txt', 'md', 'csv', 'json', 'html', 'xml', 'yaml', 'yml',
        'log', 'dart', 'py', 'js', 'ts', 'java', 'kt', 'swift', 'go',
        'rs', 'c', 'cpp', 'h', 'sh', 'sql',
      ],
    );
    if (r == null || !mounted) return;
    for (final f in r.files) {
      if (f.path != null) _ajouterJointe(f.path!);
    }
  }

  void _ajouterJointe(String chemin) {
    // ⚠️ TROIS AU PLUS. Chaque pièce jointe est lue puis envoyée au
    // modèle : au-delà, on dépasse la fenêtre de contexte et la requête
    // entière échoue, sans message utile.
    if (_piecesJointes.length >= 3 || _piecesJointes.contains(chemin)) return;
    OuroHaptics.light();
    setState(() => _piecesJointes.add(chemin));
  }

  /// Lire une réponse à voix haute — ou arrêter, si c'est elle qu'on lit.
  Future<void> _lire(int index) async {
    if (_enLecture == index) {
      await _voix.stop();
      if (mounted) setState(() => _enLecture = null);
      return;
    }
    OuroHaptics.selection();
    await _voix.stop();
    if (!mounted) return;
    await _voix.setLanguage(Localizations.localeOf(context).toLanguageTag());
    if (!mounted) return;
    setState(() => _enLecture = index);
    // Le même nettoyage que le mode vocal : un bloc de code se lit dans
    // le fil, il ne se prononce pas.
    await _voix.speak(texteAPrononcer(_messages[index].texte));
  }

  Future<void> _partager(String texte) async {
    OuroHaptics.selection();
    await Share.share(texteBrutDepuisMarkdown(texte));
  }

  /// J'aime / je n'aime pas — un second appui retire l'avis. L'avis reste
  /// sur l'appareil, comme la conversation.
  void _noter(int index, int avis) {
    final message = _messages[index];
    final nouveau = message.avis == avis ? 0 : avis;
    OuroHaptics.selection();
    setState(() => message.avis = nouveau);
    unawaited(_sauvegarderHistorique(echange: false));
    if (nouveau != 0) {
      ref.read(toastProvider.notifier).show(
            AppLocalizations.of(context).aiFeedbackThanks,
            type: DropletToastType.success,
          );
    }
  }

  /// « Régénérer », comme ChatGPT : la dernière réponse est refaite à partir
  /// de la même question. Le contexte du modèle est reconstruit SANS la
  /// réponse rejetée — sinon il la « verrait » et la reformulerait.
  Future<void> _regenerer() async {
    if (_genereEnCours || _messages.length < 2) return;
    final reponse = _messages.last;
    final question = _messages[_messages.length - 2];
    if (reponse.deMoi || !question.deMoi) return;
    OuroHaptics.selection();
    await _voix.stop();
    if (!mounted) return;
    setState(() {
      reponse.texte = '';
      reponse.avis = 0;
      _enLecture = null;
      _genereEnCours = true;
      assistantEcrit.value = true;
    });
    final notifier = ref.read(aiAssistantProvider.notifier);
    try {
      await notifier.effacerConversation();
      await notifier.restaurerHistorique([
        for (final m in _messages.sublist(0, _messages.length - 2))
          (m.texte, m.deMoi),
      ]);
      await for (final jeton in notifier.envoyer(question.texte)) {
        if (!mounted) return;
        setState(() => reponse.texte += jeton);
        _suivreEnBas();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => reponse
        ..texte = AppLocalizations.of(context).aiGenericError
        ..erreur = true);
    } finally {
      // Hors de la garde `mounted` : la réponse a pu finir après qu'on
      // a quitté l'écran, et la liste doit le savoir.
      assistantEcrit.value = false;
      if (mounted) setState(() => _genereEnCours = false);
      unawaited(_sauvegarderHistorique());
    }
  }

  void _copier(String texte) {
    if (texte.isEmpty) return;
    Clipboard.setData(ClipboardData(text: texte));
    OuroHaptics.success();
    ref
        .read(toastProvider.notifier)
        .show(
          AppLocalizations.of(context).aiCopied,
          type: DropletToastType.success,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final etat = ref.watch(aiAssistantProvider);

    // Dès que l'assistant devient prêt, on lui réinjecte les derniers
    // échanges d'une conversation reprise — une seule fois par ouverture
    // d'écran (voir la doc de `_historiqueRestaure`).
    ref.listen<AiAssistantState>(aiAssistantProvider, (previous, next) {
      if (next is AiReady && !_historiqueRestaure) {
        _historiqueRestaure = true;
        final notifier = ref.read(aiAssistantProvider.notifier);
        Future<void> preparer() async {
          if (_messages.isNotEmpty) {
            await notifier.restaurerHistorique(
              _messages.map((m) => (m.texte, m.deMoi)).toList(),
            );
          }
          final seed = widget.seed;
          if (seed != null && !_seedApplique) {
            _seedApplique = true;
            await notifier.amorcerContexte(seed.contexte);
          }
        }

        unawaited(preparer());
      }
    });

    final store = _conversations;

    return Scaffold(
      key: _cleScaffold,
      backgroundColor: OuroColors.systemBackground,
      // Le tiroir n'existe que lorsque sa base est ouverte : un tiroir
      // vide qui glisse sur rien est pire que pas de tiroir du tout.
      drawer: store == null
          ? null
          : AssistantTiroir(
              store: store,
              conversationCourante: _conversationId,
              initiale: ref.read(meshRepositoryProvider).myPseudo,
              onOuvrir: _ouvrirConversation,
              onNouvelle: _nouvelleConversation,
              onDestination: _allerA,
              onMenuConversation: (c) {},
            ),
      appBar: AppBar(
        backgroundColor: OuroColors.systemBackground,
        elevation: 0,
        leading: store == null
            ? null
            : OuroIconButton(
                tooltip: l10n.cvTitle,
                onPressed: () => _cleScaffold.currentState?.openDrawer(),
                icon: Icon(Icons.menu_rounded, color: OuroColors.label),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EtincelleGemini(
              taille: 22,
              anime: _genereEnCours || _vocalOuvert,
            ),
            const SizedBox(width: DesignTokens.space2),
            Text(
              // ⚠️ LE TITRE DIT QU'ON EST EN DIRECT. Sans lui, la seule
              // différence visible entre les deux modes serait la barre
              // du bas — et quelqu'un qui revient à l'écran après un
              // moment ne saurait pas que le micro l'attend.
              _vocalOuvert ? l10n.mvLive : l10n.chatsAssistant,
              style: OuroTypography.headline.copyWith(color: OuroColors.label),
            ),
          ],
        ),
        actions: [
          // En direct, la barre ne porte qu'une chose : les sous-titres.
          // Mémoire et nouvelle conversation n'ont rien à y faire tant
          // qu'on parle, et les laisser donnerait trois cibles pour un
          // pouce qui tient déjà le téléphone à une main.
          if (_vocalOuvert)
            OuroIconButton(
              tooltip: l10n.mvCaptions,
              onPressed: () {
                OuroHaptics.selection();
                setState(() => _sousTitresVocal = !_sousTitresVocal);
              },
              icon: Icon(
                _sousTitresVocal
                    ? Icons.closed_caption_rounded
                    : Icons.closed_caption_off_rounded,
                color: _sousTitresVocal
                    ? OuroColors.accent
                    : OuroColors.secondaryLabel,
              ),
            ),
          if (!_vocalOuvert && etat is AiReady)
            OuroIconButton(
              tooltip: l10n.aiMemoryTitle,
              onPressed: _ouvrirMemoire,
              icon: Icon(
                Icons.psychology_outlined,
                color: OuroColors.secondaryLabel,
              ),
            ),
          if (!_vocalOuvert && etat is AiReady && _messages.isNotEmpty)
            OuroIconButton(
              tooltip: l10n.aiNewConversation,
              onPressed: _nouvelleConversation,
              icon: Icon(
                Icons.add_comment_outlined,
                color: OuroColors.secondaryLabel,
              ),
            ),
        ],
      ),
      // ⚠️ L'ÉTAT DU MODÈLE LOCAL NE COMMANDE PLUS L'ÉCRAN ENTIER.
      //
      // Avant, tant que le modèle n'était pas là, la conversation était
      // remplacée par un écran de téléchargement — y compris pour
      // quelqu'un qui n'allait jamais s'en servir. Maintenant la
      // conversation est TOUJOURS là ; le téléchargement, quand il a été
      // demandé, se signale par un bandeau au-dessus du composeur.
      //
      // La lueur arc-en-ciel s'allume derrière la conversation dès que la
      // question part, et s'éteint quand la réponse est finie.
      body: Stack(
        children: [
          Positioned.fill(child: LueurReflexion(active: _genereEnCours)),
          _conversationVue(etat),
        ],
      ),
    );
  }

  Widget _conversationVue(AiAssistantState etat) {
    final l10n = AppLocalizations.of(context);
    // ⚠️ UNE PILE, ET NON UNE COLONNE.
    //
    // Avec une colonne, la conversation s'arrête net au-dessus du
    // composeur : le dernier message se cogne à un bord opaque, et rien
    // ne passe jamais derrière. C'est ce qui distingue une application
    // soignée d'une autre — dans iOS, le contenu GLISSE SOUS le verre et
    // s'y estompe.
    //
    // La pile superpose donc la liste (qui occupe toute la hauteur, avec
    // un rembourrage bas égal à la hauteur mesurée du composeur) et le
    // composeur lui-même, en verre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mesurer();
    });

    return Stack(
      children: [
        Positioned.fill(
          child: _messages.isEmpty
              ? _AccueilVide(pseudo: ref.read(meshRepositoryProvider).myPseudo)
              : NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    _mesurer();
                    return false;
                  },
                  child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.screenMargin,
                    DesignTokens.space3,
                    DesignTokens.screenMargin,
                    // Le dernier message doit pouvoir monter AU-DESSUS du
                    // composeur, pas se cacher derrière.
                    _hauteurComposeur + DesignTokens.space3,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) => _Bulle(
                    message: _messages[i],
                    etapeEnCours: _genereEnCours && i == _messages.length - 1
                        ? _etapeEnCours
                        : null,
                    onSuite: (q) {
                      _inputCtrl.text = q;
                      unawaited(_envoyer());
                    },
                    onArtefact: _ouvrirArtefact,
                    onFichier: _partagerFichier,
                    artefacts: _artefacts,
                    enCoursDeGeneration:
                        _genereEnCours && i == _messages.length - 1,
                    onCopier: _copier,
                    enLecture: _enLecture == i,
                    estDerniere: !_genereEnCours && i == _messages.length - 1,
                    onLire: () => _lire(i),
                    onPartager: () => _partager(_messages[i].texte),
                    onNoter: (avis) => _noter(i, avis),
                    onRegenerer: _regenerer,
                  ),
                ),
                ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            key: _cleComposeur,
            child: OuroBlurSurface(
              material: OuroMaterial.thin,
              intensite: _voile,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Un filet qui n'apparaît qu'avec le voile : sur une
                  // conversation courte, il n'y a rien à séparer.
                  Opacity(
                    opacity: _voile,
                    child: Container(
                      height: 0.5,
                      color: OuroColors.separator,
                    ),
                  ),
                  // Le bandeau n'apparaît que si le téléchargement a été
                  // demandé, ou s'il a échoué. Un modèle jamais réclamé
                  // ne dit rien.
                  if (etat is AiDownloading)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: DesignTokens.space2,
                      ),
                      child: _BandeauTelechargement(
                        pourcentage: etat.percentage,
                      ),
                    )
                  else if (etat is AiError)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: DesignTokens.space2,
                      ),
                      child: _BandeauEchec(
                        message: etat.message,
                        onReessayer: () => ref
                            .read(aiAssistantProvider.notifier)
                            .ensureDownloaded(),
                      ),
                    ),
                  SafeArea(
                    top: false,
                    // ⚠️ L'UN OU L'AUTRE, JAMAIS LES DEUX. Garder le
                    // composeur sous la couche laisserait un champ de saisie
                    // qu'on peut viser sans le voir, et le clavier s'ouvrirait
                    // par-dessus une conversation vocale.
                    child: _vocalOuvert
                        ? CoucheVocale(
                            groq: _groq,
                            langue: Localizations.localeOf(context).languageCode,
                            sousTitres: _sousTitresVocal && !_filEnBas,
                            repondre: _repondreVocalement,
                            onQuitter: () {
                              if (mounted) setState(() => _vocalOuvert = false);
                            },
                        )
                        : ComposeurAssistant(
                          controller: _inputCtrl,
                          onEnvoyer: _envoyer,
                          onArreter: _arreter,
                          genereEnCours: _genereEnCours,
                          moteur: _moteur,
                          enLigneDisponible: _enLigneDisponible,
                          localInstalle: _localInstalle,
                          onChangerMoteur: _changerMoteur,
                          onJoindre: _joindre,
                          piecesJointes: _piecesJointes,
                          // ⚠️ SEULEMENT SUR UNE CONVERSATION VIERGE. Des
                          // suggestions qui reviennent entre deux réponses
                          // ne sont plus une aide mais une distraction : on
                          // sait très bien quoi demander une fois lancé.
                          suggestions: _messages.isEmpty
                              ? [
                                  l10n.aiChipExplain,
                                  l10n.aiChipWrite,
                                  l10n.aiChipSummarize,
                                  l10n.aiChipTranslate,
                                ]
                              : const [],
                          onSuggestion: (s) {
                            _inputCtrl.text = s;
                            _inputCtrl.selection = TextSelection.collapsed(
                              offset: s.length,
                            );
                          },
                          onVocal: _ouvrirVocal,
                          onRetirerPiece: (i) =>
                              setState(() => _piecesJointes.removeAt(i)),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bulle extends StatelessWidget {
  const _Bulle({
    required this.message,
    required this.enCoursDeGeneration,
    required this.onCopier,
    this.enLecture = false,
    this.estDerniere = false,
    this.onLire,
    this.onPartager,
    this.onNoter,
    this.onRegenerer,
    this.etapeEnCours,
    this.onArtefact,
    this.onFichier,
    this.artefacts,
    this.onSuite,
  });

  final _AssistantMessage message;

  /// Vrai seulement pour la dernière bulle, tant que ses jetons
  /// continuent d'arriver — c'est elle qui porte le curseur clignotant.
  final bool enCoursDeGeneration;

  final ValueChanged<String> onCopier;

  /// Cette réponse est-elle lue à voix haute en ce moment ?
  final bool enLecture;

  /// La dernière réponse, génération finie : elle seule se régénère.
  final bool estDerniere;

  final VoidCallback? onLire;
  final VoidCallback? onPartager;
  final ValueChanged<int>? onNoter;
  final VoidCallback? onRegenerer;

  /// Ce que l'assistant fait à l'instant, sous cette réponse.
  final String? etapeEnCours;

  final ValueChanged<String>? onArtefact;
  final ValueChanged<String>? onFichier;

  /// Sert à retrouver le titre d'un artéfact pour sa pastille.
  final ArtefactsStore? artefacts;

  /// Une question de suite touchée.
  final ValueChanged<String>? onSuite;

  @override
  Widget build(BuildContext context) {
    final mine = message.deMoi;

    // Le modèle « réfléchit » : aucun jeton encore reçu. Comme Gemini :
    // l'étoile qui tourne et des barres traversées d'un reflet coloré —
    // l'attente d'une IA ne ressemble pas à un humain qui tape.
    // ⚠️ SAUF S'IL Y A DÉJÀ DES ÉTAPES. Une réponse qui commence par
    // chercher sur le web n'a pas encore un mot de texte, mais elle a
    // beaucoup à montrer : cacher le journal derrière l'étoile ferait
    // exactement le vide d'information qu'il sert à combler.
    if (!mine &&
        message.texte.isEmpty &&
        message.etapes.isEmpty &&
        etapeEnCours == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.space1),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: IndicateurReflexionGemini(),
        ),
      ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.05);
    }

    // ── LA RÉPONSE DE L'ASSISTANT : COMME ChatGPT, Claude ET Gemini ──────
    //
    // Pas de bulle : la réponse occupe la largeur et se lit comme une page,
    // avec ses titres, ses listes et son code mis en forme — plus un seul
    // astérisque ni dièse à l'écran. La question, elle, garde sa bulle.
    if (!mine) {
      return GestureDetector(
        onLongPress: () => onCopier(texteBrutDepuisMarkdown(message.texte)),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10, right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Le journal AVANT la réponse : on regarde ce qui se
              // passe pendant que le texte n'existe pas encore.
              if (message.etapes.isNotEmpty || etapeEnCours != null)
                JournalActivite(
                  etapes: message.etapes,
                  enCours: enCoursDeGeneration,
                  etapeEnCours: etapeEnCours,
                ),
              if (message.texte.isNotEmpty)
                RenduMarkdown(
                  texte: message.texte,
                  style: OuroTypography.body.copyWith(
                    color: OuroColors.label,
                    height: 1.45,
                  ),
                ),
              if (message.citations.isNotEmpty && !enCoursDeGeneration)
                _Sources(citations: message.citations),
              for (final id in message.artefacts)
                _PastilleArtefact(
                  id: id,
                  store: artefacts,
                  onTap: () => onArtefact?.call(id),
                ),
              for (final f in message.fichiers) ...[
                if (f.toLowerCase().endsWith('.pdf'))
                  _ApercuPdf(chemin: f, onOuvrir: () => onFichier?.call(f))
                else if (_Vignettes._estImage(f))
                  _ApercuImage(chemin: f, onOuvrir: () => onFichier?.call(f)),
                _PastilleFichier(
                  chemin: f,
                  onTap: () => onFichier?.call(f),
                ),
              ],
              if (enCoursDeGeneration)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: _CurseurClignotant(),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _ActionsReponse(
                    avis: message.avis,
                    enLecture: enLecture,
                    onCopier: () =>
                        onCopier(texteBrutDepuisMarkdown(message.texte)),
                    onLire: onLire,
                    onNoter: onNoter,
                    onPartager: onPartager,
                    onRegenerer: estDerniere ? onRegenerer : null,
                  ),
                ),
              // ⚠️ SOUS LES ACTIONS, ET SEULEMENT SUR LA DERNIÈRE
              // RÉPONSE. Des suggestions au milieu d'un fil relu
              // proposeraient de repartir d'un point qu'on a déjà
              // dépassé — on relit pour retrouver, pas pour continuer.
              if (estDerniere && message.suites.isNotEmpty)
                _Suites(
                  items: message.suites,
                  onChoisir: (q) => onSuite?.call(q),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 180.ms);
    }

    return GestureDetector(
          // Copier une question qu'on vient soi-même de taper n'a pas
          // d'usage réel ; copier la réponse de l'assistant, si.
          onLongPress: mine ? null : () => onCopier(message.texte),
          child: Align(
            alignment: mine
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: DesignTokens.space1),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              // ⚠️ SANS REMBOURRAGE QUAND IL N'Y A QU'UNE IMAGE. Une photo
              // cernée de 14 points de bleu ressemble à un cadre photo de
              // brocante ; toutes les messageries la laissent toucher les
              // bords de sa bulle.
              padding: message.texte.isEmpty && message.fichiers.isNotEmpty
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                // ⚠️ `accentRempli`, PAS `accent`. Cette bulle porte du
                // texte : sur l'accent brut, le blanc y tombait à 2,22:1.
                color: mine
                    ? OuroColors.accentRempli
                    : OuroColors.secondarySystemBackground,
                // ⚠️ `radiusBubble`, PAS 18. Les bulles des discussions
                // sont à 19 ; à 18, celles de l'assistant étaient d'un
                // point plus carrées — invisible seule, évidente quand on
                // passe d'un écran à l'autre. C'est exactement le genre
                // d'écart qui fait qu'une application « ne tient pas ».
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusBubble,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.fichiers.isNotEmpty)
                    _Vignettes(
                      chemins: message.fichiers,
                      seule: message.texte.isEmpty,
                      onOuvrir: onFichier,
                    ),
                  if (message.texte.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: message.fichiers.isEmpty ? 0 : 8,
                        left: message.fichiers.isEmpty ? 0 : 12,
                        right: message.fichiers.isEmpty ? 0 : 12,
                        bottom: message.fichiers.isEmpty ? 0 : 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              message.texte,
                              style: OuroTypography.body.copyWith(
                                color: mine
                                    ? OuroColors.texteSurAccent
                                    : OuroColors.label,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (!mine && enCoursDeGeneration) ...[
                            const SizedBox(width: 3),
                            const _CurseurClignotant(),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 180.ms)
        .slideY(begin: 0.08, curve: DesignTokens.curveEnter);
  }
}

/// Le curseur qui clignote à la fin d'une réponse en cours de
/// génération — le signal discret que le flux continue, comme dans
/// ChatGPT ou Claude pendant qu'ils « tapent ».
/// Les images et fichiers joints à une question, dans sa bulle.
///
/// ⚠️ UNE IMAGE SEULE OCCUPE TOUTE LA BULLE. Deux ou trois se rangent en
/// grille carrée. C'est la disposition de toutes les messageries, et elle
/// tient à une raison simple : une photo réduite à une vignette de la
/// taille d'un ongle ne se regarde pas, elle se devine.
class _Vignettes extends StatelessWidget {
  const _Vignettes({
    required this.chemins,
    required this.seule,
    required this.onOuvrir,
  });

  final List<String> chemins;

  /// Vrai quand la bulle ne porte aucun texte : l'image peut alors aller
  /// jusqu'aux bords, coins arrondis compris.
  final bool seule;
  final ValueChanged<String>? onOuvrir;

  static const _images = {
    '.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif', '.bmp',
  };

  static bool _estImage(String chemin) {
    final point = chemin.lastIndexOf('.');
    return point >= 0 && _images.contains(chemin.substring(point).toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.vertical(
      top: const Radius.circular(DesignTokens.radiusBubble),
      bottom: Radius.circular(seule ? 18 : 4),
    );

    if (chemins.length == 1) {
      return ClipRRect(
        borderRadius: seule
            ? BorderRadius.circular(DesignTokens.radiusBubble)
            : rayon,
        child: _Une(
          chemin: chemins.first,
          hauteur: _estImage(chemins.first) ? 220 : null,
          onTap: () => onOuvrir?.call(chemins.first),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          seule ? BorderRadius.circular(DesignTokens.radiusBubble) : rayon,
      child: SizedBox(
        height: 132,
        child: Row(
          children: [
            for (var i = 0; i < chemins.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                child: _Une(
                  chemin: chemins[i],
                  onTap: () => onOuvrir?.call(chemins[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Une vignette : la photo si c'en est une, sa carte de fichier sinon.
class _Une extends StatelessWidget {
  const _Une({required this.chemin, required this.onTap, this.hauteur});

  final String chemin;
  final VoidCallback onTap;
  final double? hauteur;

  @override
  Widget build(BuildContext context) {
    final nom = chemin.split(Platform.pathSeparator).last;
    final point = nom.lastIndexOf('.');
    final ext = point < 0 ? '' : nom.substring(point + 1).toUpperCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _Vignettes._estImage(chemin)
          ? Image.file(
              File(chemin),
              width: double.infinity,
              height: hauteur,
              fit: BoxFit.cover,
              // Une image effacée entre-temps ne doit pas faire éclater
              // la conversation entière.
              errorBuilder: (_, __, ___) => _CarteFichier(nom: nom, ext: ext),
            )
          : _CarteFichier(nom: nom, ext: ext),
    );
  }
}

class _CarteFichier extends StatelessWidget {
  const _CarteFichier({required this.nom, required this.ext});

  final String nom;
  final String ext;

  @override
  Widget build(BuildContext context) => Container(
        // ⚠️ UN VOILE NOIR, PAS UNE COULEUR DE FOND. La carte est posée
        // sur la bulle, dont la teinte change avec l'accent choisi : une
        // couleur fixe jurerait avec la moitié d'entre elles.
        color: Colors.black.withValues(alpha: 0.18),
        padding: const EdgeInsets.all(DesignTokens.space3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.description_outlined,
              size: DesignTokens.iconXl,
              color: OuroColors.texteSurAccent.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 6),
            Text(
              nom,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.texteSurAccent,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            if (ext.isNotEmpty)
              Text(
                ext,
                style: OuroTypography.caption1.copyWith(
                  color: OuroColors.texteSurAccent.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      );
}

/// Le téléchargement du modèle local, en cours — un bandeau, pas un écran.
///
/// ⚠️ ON RESTE UTILISABLE PENDANT. C'est tout l'intérêt : le mode en ligne
/// continue de répondre pendant que les 529 Mo descendent en arrière-plan.
class _BandeauTelechargement extends StatelessWidget {
  const _BandeauTelechargement({required this.pourcentage});
  final int pourcentage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        DesignTokens.screenMargin,
        0,
        DesignTokens.screenMargin,
        DesignTokens.space2,
      ),
      padding: const EdgeInsets.all(DesignTokens.space3),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_rounded,
                size: DesignTokens.iconSm,
                color: OuroColors.secondaryLabel,
              ),
              const SizedBox(width: DesignTokens.space2),
              Expanded(
                child: Text(
                  l10n.aiDownloading,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
              ),
              Text(
                '$pourcentage %',
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pourcentage <= 0 ? null : pourcentage / 100,
              minHeight: 3,
              backgroundColor: OuroColors.quaternarySystemFill,
              valueColor: AlwaysStoppedAnimation(OuroColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le téléchargement a échoué. On le dit une fois, sans bloquer.
class _BandeauEchec extends StatelessWidget {
  const _BandeauEchec({required this.message, required this.onReessayer});

  final String message;
  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        DesignTokens.screenMargin,
        0,
        DesignTokens.screenMargin,
        DesignTokens.space2,
      ),
      padding: const EdgeInsets.all(DesignTokens.space3),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: DesignTokens.iconSm,
            color: OuroColors.systemRed,
          ),
          const SizedBox(width: DesignTokens.space2),
          Expanded(
            child: Text(
              // Le message brut du service, pas une phrase générique :
              // « pas de place sur l'appareil » et « connexion perdue »
              // n'appellent pas le même geste.
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space2),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              OuroHaptics.light();
              onReessayer();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                l10n.actionRetry,
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Les sources citées par la recherche web, sous la réponse.
///
/// ⚠️ NUMÉROTÉES ET TOUCHABLES. Une réponse qui cite sans lien ne se
/// vérifie pas ; c'est ce qui sépare une recherche d'une affirmation.
class _Sources extends StatelessWidget {
  const _Sources({required this.citations});
  final List<Citation> citations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiSources,
            style: OuroTypography.caption1.copyWith(
              color: OuroColors.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < citations.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: citations[i].url.isEmpty
                    ? null
                    : () {
                        OuroHaptics.light();
                        Clipboard.setData(
                          ClipboardData(text: citations[i].url),
                        );
                      },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}.',
                      style: OuroTypography.caption1.copyWith(
                        color: OuroColors.tertiaryLabel,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        citations[i].titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.caption1.copyWith(
                          color: citations[i].url.isEmpty
                              ? OuroColors.secondaryLabel
                              : OuroColors.accent,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// La pastille d'un artéfact, sous la réponse qui l'a produit.
class _PastilleArtefact extends StatelessWidget {
  const _PastilleArtefact({
    required this.id,
    required this.store,
    required this.onTap,
  });

  final String id;
  final ArtefactsStore? store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = store?.lire(id);
    // Un artéfact supprimé depuis ne laisse pas une pastille morte.
    if (a == null) return const SizedBox.shrink();
    return _Pastille(
      icone: switch (a.genre) {
        GenreArtefact.page => Icons.web_rounded,
        GenreArtefact.code => Icons.code_rounded,
        GenreArtefact.schema => Icons.account_tree_outlined,
        GenreArtefact.donnees => Icons.table_chart_outlined,
        GenreArtefact.document => Icons.description_outlined,
      },
      titre: a.titre,
      detail: a.nbVersions > 1 ? 'v${a.version}/${a.nbVersions}' : a.langage,
      onTap: onTap,
    );
  }
}

/// La pastille d'un fichier produit, qui l'ouvre ou le partage.
class _PastilleFichier extends StatelessWidget {
  const _PastilleFichier({required this.chemin, required this.onTap});

  final String chemin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nom = chemin.split(Platform.pathSeparator).last;
    final point = nom.lastIndexOf('.');
    return _Pastille(
      icone: Icons.insert_drive_file_outlined,
      titre: nom,
      detail: point < 0 ? '' : nom.substring(point + 1).toUpperCase(),
      onTap: onTap,
    );
  }
}

/// Les suites possibles, sous la dernière réponse.
///
/// ⚠️ EN CONTOUR, PAS EN PLEIN. Une pastille pleine se lit comme un
/// bouton d'action — « fais ceci » — alors que c'est une proposition.
/// Le contour dit qu'on peut l'ignorer, et c'est le cas neuf fois sur
/// dix.
class _Suites extends StatelessWidget {
  const _Suites({required this.items, required this.onChoisir});

  final List<String> items;
  final ValueChanged<String> onChoisir;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: DesignTokens.space2),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final q in items)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  OuroHaptics.selection();
                  onChoisir(q);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space3,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusFull,
                    ),
                    border: Border.all(
                      color: OuroColors.separator,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    q,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.label,
                    ),
                  ),
                ),
              ),
          ],
        )
            .animate()
            .fadeIn(duration: DesignTokens.durationStandard)
            .slideY(begin: 0.15, curve: DesignTokens.curveEnter),
      );
}

/// L'aperçu d'un PDF produit : sa première page, rendue.
///
/// ⚠️ UNE PASTILLE NE SUFFIT PAS POUR UN DOCUMENT. « rapport.pdf · 124 Ko »
/// n'apprend rien : on ne sait pas s'il est bien mis en page, s'il est
/// vide, si le tableau est passé. Les grandes applications montrent la
/// première page ; c'est ce qui permet de juger sans ouvrir.
class _ApercuPdf extends StatefulWidget {
  const _ApercuPdf({required this.chemin, required this.onOuvrir});

  final String chemin;
  final VoidCallback onOuvrir;

  @override
  State<_ApercuPdf> createState() => _ApercuPdfState();
}

class _ApercuPdfState extends State<_ApercuPdf> {
  Uint8List? _image;
  var _echoue = false;

  @override
  void initState() {
    super.initState();
    unawaited(_rendre());
  }

  Future<void> _rendre() async {
    try {
      final doc = await PdfDocument.openFile(widget.chemin);
      final page = await doc.getPage(1);
      // 2× la largeur d'une bulle : assez net sur un écran dense, assez
      // léger pour ne pas garder un bitmap plein écran en mémoire.
      final rendu = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      await doc.close();
      if (mounted && rendu != null) setState(() => _image = rendu.bytes);
    } on Object {
      // Un PDF illisible ne doit pas casser la conversation : on retombe
      // sur la pastille, qui reste utile.
      if (mounted) setState(() => _echoue = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (_echoue) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.space2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOuvrir,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          child: AspectRatio(
            // A4 : la proportion de très loin la plus fréquente, et celle
            // que `production_fichiers.dart` produit.
            aspectRatio: 1 / 1.414,
            child: image == null
                ? Container(
                    color: OuroColors.tertiarySystemFill,
                    alignment: Alignment.center,
                    child: OuroSpinner(
                      color: OuroColors.tertiaryLabel,
                      radius: 9,
                    ),
                  )
                : Container(
                    color: Colors.white,
                    child: Image.memory(
                      image,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// L'aperçu d'une image produite par l'assistant.
class _ApercuImage extends StatelessWidget {
  const _ApercuImage({required this.chemin, required this.onOuvrir});

  final String chemin;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: DesignTokens.space2),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOuvrir,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            child: Image.file(
              File(chemin),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
}

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.icone,
    required this.titre,
    required this.detail,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: DesignTokens.space2),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.space3),
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(color: OuroColors.separator, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(icone, size: DesignTokens.iconLg, color: OuroColors.accent),
                const SizedBox(width: DesignTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.subheadline.copyWith(
                          color: OuroColors.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          style: OuroTypography.caption1.copyWith(
                            color: OuroColors.secondaryLabel,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: DesignTokens.iconMd,
                  color: OuroColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ),
      );
}

class _CurseurClignotant extends StatefulWidget {
  const _CurseurClignotant();

  @override
  State<_CurseurClignotant> createState() => _CurseurClignotantState();
}

/// Le rythme d'un curseur texte, hérité des premiers systèmes à fenêtres
/// et resté le même partout depuis.
///
/// ⚠️ CE N'EST PAS UNE DURÉE D'ANIMATION D'INTERFACE, donc pas un jeton :
/// c'est une constante du monde extérieur, comme 24 images par seconde.
/// La ramener à `durationStandard` donnerait un curseur qui ne clignote
/// comme aucun autre.
const Duration _rythmeCurseur = Duration(milliseconds: 530);

class _CurseurClignotantState extends State<_CurseurClignotant>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: _rythmeCurseur,
    )..bouclerSiAmbiant(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 2,
        height: 15,
        decoration: BoxDecoration(
          color: OuroColors.label,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// L'écran vide — la première chose qu'on voit, et celle qui décide de
/// l'impression qu'on garde.
///
/// ── TROIS CHOSES CORRIGÉES ────────────────────────────────────────────
///
/// ⚠️ IL AFFIRMAIT QUELQUE CHOSE DE FAUX. « Cet assistant tourne
/// entièrement sur votre appareil — rien n'est jamais envoyé sur
/// Internet » était vrai quand le mode local était le défaut. Depuis
/// qu'on ne télécharge plus 529 Mo sans le demander, le défaut est en
/// ligne : la phrase mentait à la personne sur le premier écran. Elle est
/// partie, et rien ne la remplace — la pastille du composeur dit déjà où
/// part le message, en permanence et sans se tromper.
///
/// LA HIÉRARCHIE ÉTAIT PLATE : trois textes empilés, dont deux de la même
/// couleur. On ne savait pas lequel lire en premier. Il n'en reste que
/// deux, et ils ne se ressemblent pas.
///
/// ET IL NE PROPOSAIT RIEN. Un écran vide qui dit « posez une question »
/// à quelqu'un qui ne sait pas quoi demander ne l'aide pas. Les pastilles
/// de départ vivent dans le composeur, au plus près du champ.
class _AccueilVide extends StatelessWidget {
  const _AccueilVide({this.pseudo});

  /// Le prénom ou pseudo, quand on le connaît. Saluer quelqu'un par son
  /// nom coûte une ligne et change le ton de tout l'écran.
  final String? pseudo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nom = pseudo?.trim();
    // ⚠️ « RÉDUIRE LES ANIMATIONS » VAUT AUSSI POUR L'ACCUEIL. Ce réglage
    // existe pour des gens que le mouvement met mal à l'aise — leur
    // épargner les transitions puis leur faire glisser le premier écran
    // du haut en bas serait exactement rater le point.
    final calme = MediaQuery.disableAnimationsOf(context);

    final bloc = Center(
      child: Padding(
        // ⚠️ REMONTÉ D'UN DIXIÈME. Centrer sur toute la hauteur, avec un
        // composeur en bas, pose le bloc trop bas : l'œil le lit comme
        // « collé au clavier » plutôt que posé au milieu.
        padding: EdgeInsets.only(
          left: DesignTokens.space8,
          right: DesignTokens.space8,
          bottom: MediaQuery.sizeOf(context).height * 0.1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            calme
                ? const AvatarAssistant(taille: 64)
                : const AvatarAssistant(taille: 64)
                    .animate()
                    .fadeIn(duration: DesignTokens.durationSheet)
                    .scaleXY(
                      begin: 0.88,
                      curve: DesignTokens.curveEnter,
                      duration: DesignTokens.durationSheet,
                    ),
            const SizedBox(height: DesignTokens.space5),
            Text(
              nom == null || nom.isEmpty
                  ? l10n.aiGreetingPlain
                  : l10n.aiGreeting(nom),
              textAlign: TextAlign.center,
              style: OuroTypography.title1.copyWith(
                color: OuroColors.label,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: DesignTokens.space2),
            Text(
              l10n.aiGreetingHint,
              textAlign: TextAlign.center,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );

    return calme
        ? bloc
        : bloc
            .animate()
            .fadeIn(duration: DesignTokens.durationSheet, delay: 60.ms)
            .slideY(begin: 0.06, curve: DesignTokens.curveEnter);
  }
}

class _MemoireSheet extends ConsumerStatefulWidget {
  const _MemoireSheet();

  @override
  ConsumerState<_MemoireSheet> createState() => _MemoireSheetState();
}

class _MemoireSheetState extends ConsumerState<_MemoireSheet> {
  Future<void> _oublier(int index) async {
    OuroHaptics.light();
    await AiMemoire.oublier(index);
    await ref.read(aiAssistantProvider.notifier).rafraichirMemoire();
    if (mounted) setState(() {});
  }

  Future<void> _toutOublier() async {
    OuroHaptics.warning();
    await AiMemoire.toutOublier();
    await ref.read(aiAssistantProvider.notifier).rafraichirMemoire();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final faits = AiMemoire.tout;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.screenMargin,
          0,
          DesignTokens.screenMargin,
          DesignTokens.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: OuroColors.accent,
                  size: 22,
                ),
                const SizedBox(width: DesignTokens.space2),
                Text(
                  l10n.aiMemoryTitle,
                  style: OuroTypography.headline.copyWith(
                    color: OuroColors.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space3),
            if (faits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.space4,
                ),
                child: Text(
                  l10n.aiMemoryEmpty,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
              )
            else ...[
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: faits.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: DesignTokens.space1),
                  itemBuilder: (context, i) => Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                    decoration: BoxDecoration(
                      color: OuroColors.secondarySystemBackground,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusXl,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            faits[i].texte,
                            style: OuroTypography.body.copyWith(
                              color: OuroColors.label,
                            ),
                          ),
                        ),
                        OuroIconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _oublier(i),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: OuroColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space3),
              OuroRetourIos(child: TextButton.icon(
                onPressed: _toutOublier,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.aiMemoryForget),
                style: TextButton.styleFrom(overlayColor: Colors.transparent, 
                  foregroundColor: OuroColors.systemRed,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}


/// La rangée sous chaque réponse — celle de ChatGPT, Claude et Gemini :
/// copier, écouter, j'aime, je n'aime pas, partager, et régénérer pour la
/// dernière. Une fois l'avis donné, seul le pouce choisi reste, rempli.
class _ActionsReponse extends StatelessWidget {
  const _ActionsReponse({
    required this.avis,
    required this.enLecture,
    required this.onCopier,
    this.onLire,
    this.onNoter,
    this.onPartager,
    this.onRegenerer,
  });

  final int avis;
  final bool enLecture;
  final VoidCallback onCopier;
  final VoidCallback? onLire;
  final ValueChanged<int>? onNoter;
  final VoidCallback? onPartager;
  final VoidCallback? onRegenerer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noter = onNoter;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconeAction(icone: Icons.copy_rounded, bulle: l10n.aiActCopy, onTap: onCopier),
        if (onLire != null)
          _IconeAction(
            icone: enLecture ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
            bulle: enLecture ? l10n.aiActStop : l10n.aiActRead,
            actif: enLecture,
            onTap: onLire!,
          ),
        if (noter != null && avis != -1)
          _IconeAction(
            icone: avis == 1 ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
            bulle: l10n.aiActLike,
            actif: avis == 1,
            onTap: () => noter(1),
          ),
        if (noter != null && avis != 1)
          _IconeAction(
            icone: avis == -1 ? Icons.thumb_down_alt_rounded : Icons.thumb_down_alt_outlined,
            bulle: l10n.aiActDislike,
            actif: avis == -1,
            onTap: () => noter(-1),
          ),
        if (onPartager != null)
          _IconeAction(icone: Icons.ios_share, bulle: l10n.aiActShare, onTap: onPartager!),
        if (onRegenerer != null)
          _IconeAction(
            icone: Icons.refresh_rounded,
            bulle: l10n.aiActRegenerate,
            onTap: onRegenerer!,
          ),
      ],
    );
  }
}

class _IconeAction extends StatelessWidget {
  const _IconeAction({
    required this.icone,
    required this.bulle,
    required this.onTap,
    this.actif = false,
  });

  final IconData icone;
  final String bulle;
  final VoidCallback onTap;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: bulle,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icone,
            size: 18,
            color: actif ? OuroColors.accent : OuroColors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}
