// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ASSISTANT IA — entièrement local, jamais un appel réseau après le
// téléchargement initial du modèle.
//
// ── POURQUOI UN MODÈLE LOCAL, ET PAS UNE API COMME CLAUDE OU GPT ──────
//
// Droplet est une messagerie mesh : son scénario nominal est l'ABSENCE
// de réseau. Un assistant qui dépendrait d'un appel API distant serait
// indisponible précisément quand l'app est censée briller — hors
// connexion, en zone blanche, en coupure Internet. Un modèle qui tourne
// SUR le téléphone n'a besoin de rien de tout ça, et ne coûte jamais un
// centime de facturation d'API à personne.
//
// ── LE MODÈLE : GEMMA 3 1B, QUANTIFIÉ INT4 ─────────────────────────────
//
// ⚠️ REMPLACE GEMMA 3 270M — CHANGEMENT DÉLIBÉRÉ, PAS UNE RÉGRESSION DE
// TAILLE. Le 270M tenait dans un budget de batterie quasi nul (0,75 %
// pour 25 conversations sur un Pixel 9 Pro), mais restait perceptiblement
// limité en cohérence et en étendue des réponses — un compromis qui ne
// convenait plus une fois le reste (contexte, décodage, cadrage) déjà
// corrigé. Le 1B (~4× plus de paramètres) reste minuscule au regard des
// grands modèles, et la quantification int4 (contre int8 pour le 270M)
// absorbe une bonne partie du coût de cette montée en taille : ~529 Mo
// sur le disque, contre ~300 Mo avant — plus de RAM et un peu plus de
// batterie par réponse, mais un assistant nettement plus capable.
//
// ── ⚠️ POURQUOI LE FICHIER N'EST PAS TÉLÉCHARGÉ DEPUIS HUGGING FACE
//    DIRECTEMENT ────────────────────────────────────────────────────────
//
// Le dépôt qui héberge le fichier `.task` prêt pour MediaPipe est
// verrouillé par la licence Gemma : chaque utilisateur aurait dû créer
// son propre compte Hugging Face et générer un jeton d'accès personnel
// rien que pour essayer l'assistant — une friction rédhibitoire pour
// une fonctionnalité optionnelle d'une messagerie grand public.
//
// La licence Gemma AUTORISE explicitement la redistribution du modèle
// (section sur la reproduction/distribution des « Model Derivatives »),
// à condition de fournir aux destinataires une copie des conditions
// d'utilisation et un avis si le fichier a été modifié — la
// quantification en est une. C'est donc Droplet qui héberge sa propre
// copie, téléchargée une seule fois par le développeur avec son propre
// jeton, jamais par l'utilisateur final. Voir « À propos de l'assistant »
// dans les réglages pour l'avis de licence complet.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'ai_knowledge.dart';
import 'ai_knowledge_packs.dart';
import 'ai_memory_store.dart';
import 'notification_service.dart';

/// URL du fichier `.task` hébergé par Droplet — PAS Hugging Face
/// directement, pour les raisons expliquées ci-dessus.
///
/// Hébergé comme asset d'une release GitHub sur le même dépôt que
/// l'APK (`rito27959-arch/droplet`), plutôt que sur Railway : même à
/// 529 Mo (plus gros que le 270M, mais encore loin des 2 Go acceptés
/// par une release GitHub), ça reste largement au-dessus de la limite
/// d'upload du CLI Railway (~230 Mo, derrière Cloudflare).
///
/// Fichier source : `gemma3-1b-it-int4.task` sur
/// `litert-community/Gemma3-1B-IT` (Hugging Face). Vérifié à la
/// publication : taille exactement identique des deux côtés — 554
/// 661 243 octets (source Hugging Face, `Content-Length` en tête de
/// réponse, ET taille réelle du fichier une fois téléchargé) et sur la
/// release GitHub (`Content-Length` après redirection vers
/// `objects.githubusercontent.com`) — empreinte SHA-256
/// `e3d981c01aeaaac69a84ffa0d4be13281b3176731063f1bea1c9fe6887bd9dee`
/// côté fichier téléchargé.
const String kAiModelUrl =
    'https://github.com/rito27959-arch/droplet/releases/download/model-gemma-3-1b-it-int4/gemma3-1b-it-int4.task';

/// La taille annoncée avant de télécharger, en mégaoctets.
///
/// ⚠️ ELLE EST MONTRÉE À LA PERSONNE AVANT QU'ELLE N'ACCEPTE, et elle
/// doit donc rester vraie : la changer en même temps que [kAiModelUrl].
/// Un chiffre sous-estimé dans une demande de consentement, c'est un
/// consentement obtenu sous un faux prétexte — sur un forfait compté, ça
/// se paie.
const int kAiModelTailleMo = 529;

/// Nom du fichier une fois installé sur l'appareil — sert aussi de clé
/// pour `FlutterGemma.isModelInstalled`.
const String _kAiModelFileName = 'gemma3-1b-it-int4.task';

/// Où en est l'assistant, du point de vue de l'écran qui l'affiche.
sealed class AiAssistantState {
  const AiAssistantState();
}

/// Le modèle n'a jamais été téléchargé sur cet appareil.
class AiNotDownloaded extends AiAssistantState {
  const AiNotDownloaded();
}

/// Téléchargement en cours. [percentage] va de 0 à 100.
class AiDownloading extends AiAssistantState {
  const AiDownloading(this.percentage);
  final int percentage;
}

/// Le modèle est sur l'appareil et chargé en mémoire, prêt à répondre.
class AiReady extends AiAssistantState {
  const AiReady();
}

/// Quelque chose a échoué — téléchargement coupé, fichier corrompu,
/// mémoire insuffisante pour charger le modèle, ou [kAiModelUrl] pas
/// encore renseignée.
class AiError extends AiAssistantState {
  const AiError(this.message);
  final String message;
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
      return AiAssistantNotifier();
    });

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  AiAssistantNotifier() : super(const AiNotDownloaded()) {
    _checkAlreadyInstalled();
  }

  InferenceModel? _model;
  InferenceChat? _chat;

  /// Le pseudo de l'utilisateur, pour que l'assistant sache À QUI il
  /// parle. Réglé par l'écran avant [ensureDownloaded] (voir
  /// [definirContexteUtilisateur]) ; injecté dans l'amorce par
  /// [_amorcerPersona].
  String? _pseudoUtilisateur;

  /// ⚠️ NE FIXE PLUS L'ÉTAT À [AiReady] TOUT SEUL — C'ÉTAIT UN BUG LATENT.
  ///
  /// Avant, si le fichier `.task` était déjà sur le disque, cette méthode
  /// passait directement à [AiReady] SANS jamais appeler [_charger] : le
  /// modèle n'était donc pas chargé en mémoire (`_chat` restait `null`),
  /// et le premier message tombait sur « L'assistant n'est pas prêt ».
  /// [ensureDownloaded], appelé ensuite par l'écran, court-circuitait en
  /// voyant `state is AiReady` et ne chargeait rien non plus — l'assistant
  /// restait mort pour toute la session.
  ///
  /// Désormais on se contente de sonder la présence du fichier ; c'est
  /// toujours [ensureDownloaded] (appelé à chaque ouverture de l'écran)
  /// qui fait `.install()` + [_charger], de façon idempotente. Le seul
  /// effet visible quand le modèle est déjà là : un bref passage par le
  /// spinner de chargement au lieu de la conversation instantanée — le
  /// temps que le modèle se charge en RAM, une à trois secondes.
  Future<void> _checkAlreadyInstalled() async {
    try {
      await FlutterGemma.isModelInstalled(_kAiModelFileName);
    } catch (_) {
      // Pas grave : l'utilisateur retélécharge simplement au premier
      // essai. Ne jamais bloquer le démarrage de l'app pour ça.
    }
  }

  /// Le fichier du modèle est-il DÉJÀ sur l'appareil ?
  ///
  /// ⚠️ NE TÉLÉCHARGE RIEN, et c'est tout l'intérêt. Depuis que l'écran
  /// n'appelle plus [ensureDownloaded] à l'ouverture, il faut un moyen de
  /// savoir si le modèle est là SANS risquer de lancer un demi-gigaoctet :
  /// sinon quelqu'un qui l'a déjà installé se verrait redemander de le
  /// télécharger, ce qui est pire que le problème qu'on corrigeait.
  ///
  /// Rend `false` en cas d'erreur : mieux vaut proposer un téléchargement
  /// inutile qu'affirmer qu'un modèle absent est présent, puis échouer au
  /// premier message.
  Future<bool> estInstalle() async {
    try {
      return await FlutterGemma.isModelInstalled(_kAiModelFileName);
    } catch (_) {
      return false;
    }
  }

  /// Donne à l'assistant le contexte de QUI est l'utilisateur — son
  /// pseudo, tel que défini dans son identité mesh. À appeler AVANT
  /// [ensureDownloaded] : le pseudo est injecté une fois, au moment de
  /// l'amorçage de la session ([_amorcerPersona]). Le rappeler après que
  /// l'assistant est déjà prêt ne réamorce pas la session (trop coûteux) —
  /// la valeur sera prise en compte au prochain chargement.
  void definirContexteUtilisateur({String? pseudo}) {
    final p = pseudo?.trim();
    _pseudoUtilisateur = (p == null || p.isEmpty) ? null : p;
  }

  /// ⚠️ VERROU SYNCHRONE, POSÉ AVANT LE PREMIER `await`.
  ///
  /// Le garde-fou `state is AiDownloading` ne suffit PAS à lui seul :
  /// entre l'appel et le premier `await` (`isModelInstalled`, qui
  /// traverse un canal de plateforme), l'état vaut toujours son ancienne
  /// valeur. Deux appels rapprochés — par exemple un double-appui sur
  /// l'entrée « Assistant » du menu, qui pousse deux fois l'écran avant
  /// que le premier `ensureDownloaded` n'ait eu le temps de faire
  /// avancer l'état — passent alors TOUS LES DEUX le garde-fou et
  /// lancent chacun leur propre `.install()` vers le même fichier. C'est
  /// exactement le genre de doublon que le téléchargeur natif résout en
  /// annulant l'un des deux — d'où le « Download was canceled » observé
  /// alors que rien, côté utilisateur, ne ressemblait à une annulation.
  bool _telechargementEnCours = false;

  /// Télécharge le modèle si nécessaire, puis le charge en mémoire.
  ///
  /// Sans effet si l'assistant est déjà prêt ou déjà en train de
  /// télécharger — sûr à appeler à chaque ouverture de l'écran, y
  /// compris pour réessayer après un [AiError] (aucun état ne bloque un
  /// nouvel essai à part [AiReady]/[AiDownloading] et le verrou ci-dessus).
  Future<void> ensureDownloaded() async {
    if (state is AiReady || state is AiDownloading || _telechargementEnCours) {
      return;
    }
    _telechargementEnCours = true;

    if (kAiModelUrl.isEmpty) {
      _telechargementEnCours = false;
      // ⚠️ PAS DE `BuildContext` ICI — même repli que
      // `notification_service.dart` : la langue courante, réglée par
      // `main.dart`, se relit sans passer par un widget.
      state = AiError(
        lookupAppLocalizations(
          NotificationService.currentLocale,
        ).aiNotAvailableYet,
      );
      return;
    }

    // ⚠️ TENTATIVES RÉPÉTÉES, PAS UN SEUL ESSAI SEC.
    //
    // 300 Mo sur une connexion mobile, ça coupe — un changement de
    // réseau (Wi-Fi → données), une antenne qui décroche un instant, une
    // app tierce qui prend la main sur la bande passante. Le
    // téléchargeur intégré au paquet retente déjà les erreurs réseau
    // transitoires, mais pas un statut « annulé » (terminal de son point
    // de vue). Sans ce filet, la moindre coupure obligeait à revenir ici
    // taper sur « Réessayer » — alors qu'une nouvelle tentative
    // automatique, quelques secondes plus tard, réussit la plupart du
    // temps sans que personne n'ait rien remarqué.
    const tentativesMax = 3;
    for (var tentative = 1; tentative <= tentativesMax; tentative++) {
      try {
        final dejaInstalle = await FlutterGemma.isModelInstalled(
          _kAiModelFileName,
        );
        // ⚠️ `.install()` EST TOUJOURS APPELÉ — MÊME SI LE FICHIER EST
        // DÉJÀ SUR LE DISQUE. NE JAMAIS LE SAUTER SOI-MÊME.
        //
        // C'était le vrai défaut derrière « No active inference model
        // set » (et, par ricochet, TOUS les messages de la conversation
        // répondant par une erreur générique) : le fichier `.task` sur
        // le disque et le « modèle actif » du paquet sont deux états
        // séparés. Le premier survit à la fermeture de l'app ; le
        // second vit UNIQUEMENT en mémoire vive et retombe à zéro à
        // chaque relance à froid — seul un appel à `.install()` le
        // repose (voir `inference_installation_builder.dart`, qui
        // documente explicitement la méthode comme idempotente :
        // « calling install() on an already-installed model will skip
        // download and just set it as active »). Sauter cet appel
        // parce que le fichier existait déjà sautait donc aussi la
        // seule étape qui réactive le modèle pour CETTE session — sur
        // un appareil qui rouvre Droplet un autre jour, l'assistant se
        // retrouvait avec un fichier prêt et pourtant injoignable.
        //
        // On garde `dejaInstalle` seulement pour l'AFFICHAGE : ne
        // montrer la barre de progression que quand un vrai
        // téléchargement a lieu.
        if (!dejaInstalle) {
          state = const AiDownloading(0);
        }
        // ⚠️ Le callback reçoit un `int` (0-100) directement, pas un
        // objet `progress.percentage` — contrairement à ce que montre
        // l'exemple du README du paquet, qui ne correspond plus à la
        // signature réelle (`inference_installation_builder.dart`).
        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        ).fromNetwork(kAiModelUrl).withProgress((pourcentage) {
          state = AiDownloading(pourcentage);
        }).install();
        await _charger();
        _telechargementEnCours = false;
        return;
      } catch (e) {
        final dernierEssai = tentative == tentativesMax;
        debugPrint(
          '[AiAssistant] tentative $tentative/$tentativesMax échouée: $e',
        );
        if (dernierEssai) {
          _telechargementEnCours = false;
          state = AiError(
            lookupAppLocalizations(
              NotificationService.currentLocale,
            ).aiDownloadFailed('$e'),
          );
          return;
        }
        // Laisser le temps à une coupure transitoire de se résorber
        // avant de retenter — retenter à l'instant échouerait
        // probablement pour la même raison.
        await Future.delayed(Duration(seconds: 2 * tentative));
      }
    }
  }

  Future<void> _charger() async {
    // ⚠️ CPU, PAS GPU — REVENU EN ARRIÈRE DÉLIBÉRÉMENT.
    //
    // Le GPU semblait le bon choix sur le papier (plus rapide, donc
    // moins de temps éveillé) — jusqu'à ce que l'assistant se mette à
    // répondre par une suite de jetons réservés du tokenizer
    // (`<pad>`, `<unk>`, `<unused16>`, `<bos>`, `<mask>`…) au lieu
    // d'une phrase. Ce n'était pas un problème de décodage (voir
    // `createChat` juste en dessous, dont le correctif `topK`/`topP`
    // reste nécessaire par ailleurs) : c'est le signe d'un calcul
    // corrompu en amont, avant même le choix du mot suivant — le genre
    // de défaut que provoque un délégué GPU mal pris en charge pour un
    // modèle quantifié précis (README du paquet : « Consider using
    // CPU backend for text-only models on lower-end devices »). Ce
    // constat visait le 270M, mais rien dans sa cause (un délégué GPU
    // mal pris en charge, pas la taille du modèle) ne cesse de
    // s'appliquer avec le 1B : le CPU répond quelques secondes plus
    // tard, ce qui ne se compare à rien face à une réponse illisible.
    // ⚠️ 2048, PAS 1024 — CE N'EST PAS UN CONFORT, C'EST UN CORRECTIF.
    //
    // `InferenceChat` (le paquet, `core/chat.dart`) recrée la session native
    // dès que `_currentTokens >= (maxTokens - tokenBuffer)` — et `createChat`
    // fixe `tokenBuffer` à 256 par défaut. Avec 1024, la marge réelle avant
    // recréation n'était donc que de 768 jetons : largement moins qu'une
    // question française détaillée suivie d'une réponse, à cause d'un
    // tokenizer qui découpe le français en davantage de sous-mots que
    // l'anglais. La conversation semblait « amnésique dès le deuxième
    // message » parce que c'est très exactement ce qui se passait — la
    // session entière était fermée et reconstruite en tâcheronnant tout
    // l'historique modèle (`_recreateSessionWithReducedChunks`, qui vide
    // `_modelHistory` message par message jusqu'à repasser sous le seuil).
    // Chaque fermeture/recréation de session native est aussi le point le
    // plus probable derrière la croissance du cache observée après deux
    // messages seulement — un cycle qui se déclenchait bien plus souvent
    // qu'il n'aurait dû. 2048 jetons reste minuscule pour Gemma 3 (qui
    // supporte des contextes bien plus larges) : le coût mémoire reste
    // très raisonnable même pour le 1B, et la marge réelle passe à 1792
    // jetons — largement de quoi tenir plusieurs échanges avant la
    // moindre recréation.
    //
    // ⚠️ NE PAS REMONTER À 4096 « POUR FAIRE DE LA PLACE ». Essayé, puis
    // annulé : le fichier `.task` de litert-community est converti pour un
    // contexte plus court, et `createModel` ne l'étend pas — demander 4096
    // donne au mieux le maximum réel du bundle, au pire une session qui
    // déborde dès que l'amorce est un peu longue. Le premier symptôme
    // observé : sur CPU, le préchargement d'une amorce de ~1000 jetons
    // dépassait le délai d'inactivité de [_delaiInactiviteGeneration]
    // AVANT le premier jeton de réponse — « Désolé, une erreur s'est
    // produite » à chaque message. La vraie réponse n'est pas d'agrandir
    // la fenêtre, c'est de garder l'amorce COURTE (voir [_amorcerPersona]
    // et `ai_knowledge.dart`).
    _model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.cpu,
    );
    // ⚠️ NE JAMAIS LAISSER `topK` À SA VALEUR PAR DÉFAUT (1).
    //
    // `topK: 1` — la valeur par défaut de `createChat()` dans le paquet —
    // veut dire : à chaque jeton, prendre TOUJOURS le mot le plus probable,
    // sans la moindre place pour un second choix. C'est un tirage
    // entièrement déterministe (« glouton »), et les petits modèles
    // quantifiés y sont particulièrement sujets à un défaut connu : dès
    // qu'un mot se retrouve un instant être « le plus probable » deux fois
    // de suite, rien ne peut plus l'empêcher de rester le plus probable
    // indéfiniment — la réponse se bloque à répéter le même jeton en
    // boucle (le « pad pad pad » observé). `topK: 40` redonne au tirage de
    // quoi échapper à ce piège.
    //
    // ⚠️ `topP: 0.9` ET `temperature: 0.6`, resserrés depuis 0.95 / 0.7.
    // Le 1B, sur les premières vraies questions testées, partait en
    // divagation (« je me suis demandé si… », phrases quasi identiques
    // répétées — voir les captures). `topP: 0.9` coupe la traîne de la
    // distribution où se logent ces dérives ; `0.6` de température resserre
    // encore. Ce n'est pas une solution — aucun réglage ne fait raisonner
    // un modèle qui n'a pas la capacité —, mais ça réduit nettement le
    // rabâchage. Le cadrage de [_amorcerPersona] fait le reste (« donne la
    // réponse, pas ta réflexion »). Le paquet n'expose pas de
    // `repetition_penalty`, qui serait le vrai levier.
    _chat = await _model!.createChat(topK: 40, topP: 0.9, temperature: 0.6);
    await _amorcerPersona();
    state = const AiReady();
  }

  /// Amorce la session avec un cadrage de comportement, avant tout
  /// message réel de l'utilisateur — PAS un vrai « rôle système » (le
  /// format de discussion de Gemma IT n'en a pas), mais un premier
  /// échange fictif : une instruction envoyée comme si elle venait de
  /// l'utilisateur, suivie d'un accusé de réception envoyé comme si
  /// c'était la réponse du modèle. `addQueryChunk` ne déclenche aucune
  /// génération réelle — cet accusé est écrit à l'avance, jamais produit
  /// par le modèle.
  ///
  /// ⚠️ CE QUE ÇA CHANGE, ET CE QUE ÇA NE CHANGE PAS. Un modèle
  /// instruction-tuned comme Gemma 3 IT suit nettement mieux un cadrage
  /// explicite en début de conversation qu'aucun cadrage du tout — c'est
  /// le levier le plus direct pour des réponses plus courtes, plus
  /// pertinentes et qui restent en français, sans toucher au modèle
  /// lui-même. Ça ne fait PAS d'un modèle de 1B un grand modèle : la
  /// capacité de raisonnement et l'étendue des connaissances restent
  /// bornées par sa taille, aucun prompt n'y changera rien.
  ///
  /// ⚠️ LIMITE CONNUE : quand `_recreateSessionWithReducedChunks` (voir
  /// `chat.dart` du paquet) doit faire de la place, il retire les plus
  /// anciens messages de `_modelHistory` — donc CET amorçage en premier.
  /// Une conversation assez longue pour déclencher un premier
  /// réajustement perd ce cadrage jusqu'à la prochaine ouverture de
  /// l'écran.
  ///
  /// ⚠️ GARDER CETTE AMORCE COURTE. Le tout premier essai injectait ici
  /// une fiche de ~600 jetons + des règles détaillées ; résultat, sur
  /// l'appareil de test, le prefill dépassait le délai et l'assistant
  /// répondait « Désolé, une erreur s'est produite » à chaque message.
  /// L'amorce doit rester de l'ordre de ~400 jetons AU TOTAL, fiche
  /// comprise. Les règles sont donc réduites à l'essentiel et la fiche
  /// (`ai_knowledge.dart`) est plafonnée.
  Future<void> _amorcerPersona() async {
    final chat = _chat;
    if (chat == null) return;

    AiMemoire.charger();
    final memoire = AiMemoire.bloc;
    final pseudo = _pseudoUtilisateur;

    final cadre = StringBuffer()
      ..writeln(
        "Tu es l'assistant intégré à Droplet et tu connais bien l'app. "
        'Réponds en français, directement, en 2 à 4 phrases. Donne la '
        'réponse, pas ta réflexion : jamais de « je me suis demandé », '
        '« je me questionne ». Sers-toi de la fiche ci-dessous ; si elle '
        "ne dit rien d'un point, dis-le au lieu d'inventer. Ne répète pas "
        'un mot ni une phrase.',
      )
      ..writeln()
      ..writeln(kDropletKnowledge.trim());

    if (pseudo != null) {
      cadre
        ..writeln()
        ..writeln("L'utilisateur s'appelle « $pseudo » dans Droplet.");
    }

    if (memoire != null) {
      cadre
        ..writeln()
        ..writeln(memoire);
    }

    try {
      await chat.addQueryChunk(
        Message.text(isUser: true, text: cadre.toString()),
      );
      await chat.addQueryChunk(
        Message.text(
          isUser: false,
          text: pseudo != null
              ? "Compris, $pseudo. Je réponds en français, court et clair."
              : 'Compris. Je réponds en français, court et clair.',
        ),
      );
    } catch (e) {
      // Pas grave : l'assistant reste utilisable sans cadrage, juste un
      // peu moins ciblé dans ses réponses.
      debugPrint('[AiAssistant] échec de l\'amorçage de la persona: $e');
    }
  }

  /// Injecte, en cours de session, le contexte d'une conversation avec un
  /// pair — appelé quand l'assistant est ouvert depuis « Demander à
  /// l'assistant » (voir `chat_screen.dart` / `AiSeed`). Le transcript
  /// est passé comme un message de l'utilisateur, suivi d'un accusé de
  /// réception écrit à l'avance ; la vraie demande d'aide arrive ensuite,
  /// tapée par l'utilisateur dans le champ de saisie.
  Future<void> amorcerContexte(String contexte) async {
    final chat = _chat;
    if (chat == null || contexte.trim().isEmpty) return;
    try {
      await chat.addQueryChunk(Message.text(isUser: true, text: contexte));
      await chat.addQueryChunk(
        Message.text(
          isUser: false,
          text:
              "J'ai lu la conversation. Dis-moi ce que tu veux "
              'répondre, ou demande-moi une proposition.',
        ),
      );
    } catch (e) {
      debugPrint('[AiAssistant] échec de l\'amorçage du contexte pair: $e');
    }
  }

  /// Réinjecte la mémoire longue en cours de session, après que
  /// l'utilisateur vient d'y ajouter (ou d'en retirer) un fait — sans
  /// réamorcer toute la session. Best-effort : un échec ici ne fait que
  /// retarder la prise en compte du fait à la prochaine ouverture de
  /// l'écran, où [_amorcerPersona] le réinjectera de toute façon.
  Future<void> rafraichirMemoire() async {
    final chat = _chat;
    if (chat == null) return;
    final memoire = AiMemoire.bloc;
    try {
      await chat.addQueryChunk(
        Message.text(
          isUser: true,
          text: memoire == null
              ? '(Mise à jour interne : ta mémoire des consignes de '
                    'l\'utilisateur a été vidée.)'
              : '(Mise à jour interne de ta mémoire — $memoire)',
        ),
      );
      await chat.addQueryChunk(
        Message.text(isUser: false, text: "C'est noté."),
      );
    } catch (e) {
      debugPrint('[AiAssistant] échec du rafraîchissement mémoire: $e');
    }
  }

  /// Réinjecte dans le contexte du modèle les derniers échanges d'une
  /// conversation reprise après un redémarrage de l'application.
  ///
  /// ⚠️ POURQUOI CETTE MÉTHODE EXISTE. Sans elle, la « mémoire » de
  /// l'assistant ne durait que le temps où l'écran restait ouvert : fermer
  /// puis rouvrir l'assistant, et il répondait comme s'il n'avait jamais
  /// rien vu, même si l'écran réaffichait les anciens messages. La
  /// conversation avait l'air de continuer ; le modèle, lui, était
  /// amnésique. Ici, les messages sont réinjectés un par un via
  /// `addQueryChunk` (jamais `generateChatResponseAsync`, qui déclencherait
  /// une réponse) — le modèle retrouve donc le VRAI fil, pas seulement son
  /// apparence à l'écran.
  ///
  /// ⚠️ LIMITÉ AUX [maxEchanges] DERNIERS ÉCHANGES, PAS TOUT L'HISTORIQUE.
  /// La fenêtre de contexte du modèle fait 2048 jetons (voir [_charger]),
  /// et l'amorce (fiche de connaissance + mémoire longue) en occupe déjà
  /// une part. Y reformuler une conversation entière la remplirait avant
  /// même la question du jour, ou couperait le début sans que personne ne
  /// le voie. Se limiter aux échanges récents garde une marge utile.
  Future<void> restaurerHistorique(
    List<(String texte, bool deMoi)> echanges, {
    int maxEchanges = 8,
  }) async {
    final chat = _chat;
    if (chat == null) return;
    final recents = echanges.length > maxEchanges
        ? echanges.sublist(echanges.length - maxEchanges)
        : echanges;
    for (final (texte, deMoi) in recents) {
      if (texte.isEmpty) continue;
      try {
        await chat.addQueryChunk(Message.text(text: texte, isUser: deMoi));
      } catch (e) {
        // Un échange qui ne rentre plus dans la fenêtre de contexte ne
        // doit pas empêcher les suivants d'être réinjectés.
        debugPrint('[AiAssistant] échange ignoré à la restauration: $e');
      }
    }
  }

  /// Arrête la génération en cours — c'est ce qui permet au bouton
  /// d'envoi de se transformer en bouton d'arrêt pendant que l'assistant
  /// répond, comme dans les grandes apps de conversation IA.
  Future<void> arreterGeneration() async {
    try {
      await _chat?.stopGeneration();
    } catch (e) {
      debugPrint('[AiAssistant] échec de l\'arrêt de la génération: $e');
    }
  }

  /// Efface le contexte de conversation du modèle — appelé quand
  /// l'utilisateur démarre une « nouvelle conversation » à l'écran.
  ///
  /// ⚠️ SANS ELLE, EFFACER À L'ÉCRAN NE VOULAIT RIEN DIRE POUR LE MODÈLE.
  /// La liste `_messages` du widget pouvait être vidée, l'assistant
  /// continuait pourtant de répondre en tenant compte de tout ce qui
  /// s'était dit avant — une conversation « effacée » qui ne l'était
  /// qu'en apparence.
  Future<void> effacerConversation() async {
    try {
      await _chat?.clearHistory();
    } catch (e) {
      debugPrint('[AiAssistant] échec de l\'effacement de la conversation: $e');
    }
  }

  /// Au-delà de ce délai SANS LE MOINDRE NOUVEAU JETON (une fois la
  /// réponse commencée), on considère la génération bloquée plutôt que
  /// simplement lente — voir [envoyer].
  static const _delaiInactiviteGeneration = Duration(seconds: 30);

  /// ⚠️ DÉLAI SÉPARÉ, PLUS LONG, POUR LE TOUT PREMIER JETON. Avant le
  /// premier jeton, le moteur d'inférence fait le « préchargement »
  /// (prefill) de toute l'invite : l'amorce de comportement + la question.
  /// Sur un appareil modeste en secours CPU, ça peut prendre bien plus de
  /// 30 secondes pour la première question d'une session — et appliquer le
  /// délai d'inactivité normal renvoyait « Désolé, une erreur s'est
  /// produite » alors que le modèle travaillait normalement. Une fois le
  /// premier jeton passé, le prefill est fait : on repasse au délai court.
  static const _delaiPremierJeton = Duration(seconds: 75);

  /// Envoie un message et retourne le flux de jetons de la réponse, au
  /// fur et à mesure qu'ils arrivent — pour un affichage progressif,
  /// comme le fait Claude ou ChatGPT.
  ///
  /// ⚠️ POURQUOI UN DÉLAI D'INACTIVITÉ ICI. Sans lui, une génération native
  /// qui ne referme jamais son flux — un jeton de fin (`<eos>`) que le
  /// modèle n'atteint jamais pour une invite donnée, ou un blocage côté
  /// moteur d'inférence — laissait l'écran indéfiniment sur l'indicateur
  /// « en train d'écrire » : `await for` attend un événement qui ne vient
  /// plus, et rien ne le rompt. C'est précisément le symptôme rapporté
  /// (« il y a des questions qu'il ne répond jamais, ça reste toujours au
  /// chargement »). `Stream.timeout` redémarre son minuteur à CHAQUE jeton
  /// reçu — une réponse longue mais qui progresse normalement, même
  /// lentement sur un appareil modeste en secours CPU, n'est donc jamais
  /// interrompue à tort ; seul un silence réel de 30 secondes déclenche
  /// l'arrêt. On coupe aussi la génération native elle-même
  /// (`stopGeneration`) : sans ça, l'inférence bloquée continuerait de
  /// consommer CPU/batterie en arrière-plan alors que l'écran est déjà
  /// passé à autre chose.
  Stream<String> envoyer(String texte) async* {
    final chat = _chat;
    if (chat == null) {
      throw StateError("L'assistant n'est pas prêt.");
    }

    // RAG « packs » : si la question touche à un domaine couvert (premiers
    // secours, situation d'urgence…), on glisse la fiche de référence
    // JUSTE devant la question, dans le même tour, pour que le modèle
    // récite juste au lieu d'approximer. Rien si aucune fiche ne matche
    // franchement (voir `AiKnowledgePacks`). L'écran, lui, n'affiche et ne
    // persiste que [texte] brut — le modèle est seul à voir l'ajout.
    final reference = AiKnowledgePacks.chercher(texte);
    final aEnvoyer = reference == null
        ? texte
        : 'Référence (sers-t\'en si elle aide, sinon ignore-la) :\n'
              '$reference\n\n---\n$texte';
    await chat.addQueryChunk(Message.text(text: aEnvoyer, isUser: true));

    // Délai généreux jusqu'au premier jeton (prefill), court ensuite —
    // voir [_delaiPremierJeton]. On itère à la main plutôt qu'avec
    // `Stream.timeout` pour pouvoir changer le délai en cours de route.
    final it = StreamIterator(chat.generateChatResponseAsync());
    var premierJeton = true;
    try {
      while (true) {
        final delai = premierJeton
            ? _delaiPremierJeton
            : _delaiInactiviteGeneration;
        final bool aUnElement;
        try {
          aUnElement = await it.moveNext().timeout(delai);
        } on TimeoutException {
          unawaited(arreterGeneration());
          throw TimeoutException(
            "L'assistant met trop de temps à répondre.",
            delai,
          );
        }
        if (!aUnElement) break;
        premierJeton = false;
        final reponse = it.current;
        if (reponse is TextResponse) yield reponse.token;
      }
    } finally {
      await it.cancel();
    }
  }

  @override
  void dispose() {
    // `InferenceChat` n'a pas de `close()` propre — fermer le modèle
    // suffit à libérer la session qui lui est associée.
    final model = _model;
    if (model != null) unawaited(model.close());
    super.dispose();
  }
}
