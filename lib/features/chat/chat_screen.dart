// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// C'est l'écran le plus GROS de toute l'app — celui d'une conversation
// ouverte, avec la liste des messages qui défile et la barre de saisie
// en bas. C'est gros parce qu'une conversation moderne fait BEAUCOUP de
// choses différentes : afficher les bulles de texte ET d'images ET de
// messages vocaux, gérer le clavier, les citations (« répondre à... »),
// les réactions emoji, les effets spéciaux, l'enregistrement vocal en
// maintenant le doigt appuyé, l'envoi de fichiers, le bouton « revenir
// en bas », et plus encore.
//
// Pour rester lisible malgré sa taille, ce fichier est découpé en
// beaucoup de petites classes, chacune responsable d'UN SEUL petit
// morceau visuel — un peu comme un plateau de tournage de film, où
// chaque équipe (éclairage, son, caméra) s'occupe d'une seule partie du
// travail plutôt qu'une seule personne qui ferait tout :
//
//   - `_ChatScreenState` : le grand chef d'orchestre de l'écran entier
//     (état de saisie, enregistrement vocal, défilement...).
//   - `_MessageBubble` / `_ImageBubble` : une seule bulle de message
//     (texte ou image) affichée dans la liste.
//   - `_InputBar` : toute la barre du bas — champ de texte, bouton
//     micro, bouton d'envoi.
//   - `_MicButton` / `_RecordingBar` : le bouton micro et la rangée
//     (chrono, « glisser pour annuler ») pendant qu'on enregistre.
//   - `_AnimatedSendButton` / `_EffectPicker` : le bouton d'envoi, et
//     le petit menu d'effets spéciaux (voir `message_effects.dart`).
//   - `_JumpButton` : le petit bouton flottant « nouveaux messages,
//     reviens en bas ».
//   - `_ImageViewerScreen` : l'écran plein écran pour zoomer une photo.
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart' show CupertinoSearchTextField;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart' show SchedulerBinding, SchedulerPhase;
import 'package:motor/motor.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/mesh_message.dart';
import '../../core/models/status_media.dart';
import 'message_context_menu.dart';
import '../../core/providers/animation_envoi_provider.dart';
import '../../core/providers/chat_background_provider.dart';
import '../../core/providers/premium_provider.dart';
import 'animated_sticker.dart';
import 'package:photo_manager/photo_manager.dart';

import 'attach_sheet.dart';
import '../../core/services/notifs_conversation.dart';
import '../../shared/widgets/explications.dart';
import '../../core/services/journal_notifs.dart';
import '../../core/services/brouillons.dart';
import '../../core/services/epingles.dart';
import '../../shared/widgets/banniere_notif.dart';
import 'barre_enregistrement.dart';
import 'video_ronde.dart';
import 'camera_rapide.dart';
import 'relecture_vocale.dart';
import 'clavier_interactif.dart';
import 'cercle_enregistrement.dart';
import 'geste_enregistrement.dart';
import 'feuille_traduction.dart';
import 'mascotte_envoi.dart';
import 'mise_en_forme.dart';
import 'transition_envoi.dart';
import 'transition_vocale.dart';
import 'network_sheet.dart';
import 'transmission_sheet.dart';
import 'telegram_gradient_background.dart';
import 'motifs_droplet.dart';
import 'apercu_envoi_screen.dart';
import 'medias_bulle.dart';
import 'transfert_sheet.dart';
import 'fonds_premium.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/providers/tor_providers.dart';
import '../../core/services/nom_pair.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/media_service.dart';
import '../../core/services/service_intelligence.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/reglages_apparence.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_liquid.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/design_tokens.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/typing_indicator.dart';
import '../../shared/widgets/heart_burst_overlay.dart';
import '../../shared/widgets/reaction_effect_overlay.dart';
import '../../shared/widgets/message_effects.dart';
import '../../design_system/glassmorphism.dart';
import '../../shared/widgets/confetti_overlay.dart';
import '../../shared/widgets/dissolution.dart';
import '../../shared/widgets/liquid_long_press_effect.dart';
import '../../core/services/sound_service.dart';
import '../../shared/widgets/conversation_lock_screen.dart';
import '../../design_system/ouro_typography.dart';
import '../../core/models/voice_note_meta.dart';
import '../../core/services/mesh_transport_service.dart';
import '../ai/ai_chat_screen.dart' show AiSeed;
import 'location_message.dart';
import 'poll_message.dart';
import 'poll_composer_sheet.dart';
import 'poll_bubble.dart';
import 'sticker_picker.dart';
import 'voice_note.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import 'message_grouping.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_motion.dart';
import 'media_kind.dart';
import '../../core/services/avatar_service.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/etat_connexion.dart';
import '../../core/services/etat_internet.dart';
import '../../core/providers/internet_provider.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_compteur.dart';
import '../../shared/widgets/afficher_toast.dart';
import '../../shared/widgets/blocage.dart';
import '../navigateur/navigateur_integre.dart';
import '../../core/services/apercus_liens.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'vue_unique.dart';
import 'messages_importants.dart';
import '../../core/providers/personnalisation_provider.dart';
import 'messages_ephemeres.dart';
import '../../core/services/presence_internet.dart';
import '../lecteur/lecteur_pdf.dart';
import '../group/reglages_groupe.dart';
import '../call/salon_vocal.dart';

/// L'écran de conversation lui-même — juste une coquille qui reçoit soit
/// un [peerId] (chat 1:1 ou diffusion), soit un [groupId] (chat de
/// groupe), et délègue tout le vrai travail à `_ChatScreenState`.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    this.peerId,
    this.groupId,
    this.enBulle = false,
    this.messageCible,
  }) : assert(peerId != null || groupId != null, 'peerId ou groupId requis');

  /// Le message vers lequel ouvrir la conversation — depuis les messages
  /// importants, comme WhatsApp : on arrive SUR le message, qui clignote,
  /// et non tout en bas.
  final String? messageCible;

  /// ID du pair destinataire, ou 'broadcast' pour le canal diffusion.
  /// Null si [groupId] est défini (chat de groupe).
  final String? peerId;

  /// ID du groupe de discussion, si ce chat est une conversation de groupe.
  final String? groupId;

  /// Affiché dans une bulle flottante d'Android.
  ///
  /// ⚠️ UNE BULLE N'A PAS DE BOUTON « RETOUR ». C'est une fenêtre de 600
  /// points posée sur une AUTRE application, et rien n'y ramène en
  /// arrière : tout chemin qui mène ailleurs y est un cul-de-sac. On
  /// retire donc la flèche de retour et tout ce qui navigue — profil,
  /// réglages, appels, médias en plein écran.
  ///
  /// Ce qui reste est exactement ce pour quoi la bulle existe : lire les
  /// derniers messages et répondre.
  final bool enBulle;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  /// Le contact est bloqué : ni saisie ni appel, comme chez WhatsApp.
  bool get _contactBloque =>
      !_isGroup &&
      !_isBroadcast &&
      widget.peerId != null &&
      StorageService.isContactBlocked(widget.peerId!);

  /// Appeler — ou, si le contact est bloqué, proposer d'abord de le débloquer.
  Future<void> _appelerSiPossible(String route) async {
    if (_contactBloque) {
      final debloque = await proposerDeblocage(context, widget.peerId!, pourAppeler: true);
      if (!debloque || !mounted) return;
    }
    if (mounted) context.go(route);
  }

  // Le champ MONTRE la mise en forme pendant la frappe (gras, spoiler,
  // code…) : voir `controleur_mise_en_forme.dart`.
  final _inputCtrl = ControleurMiseEnForme();
  final _scrollCtrl = ScrollController();
  bool get _isGroup => widget.groupId != null;
  bool get _isBroadcast => !_isGroup && widget.peerId == 'broadcast';
  String? get _targetId => (_isBroadcast || _isGroup) ? null : widget.peerId;

  /// Conversation verrouillée — affiche l'écran biométrique.
  late bool _isLocked;

  // ── Recherche dans la conversation ───────────────────────────────
  //
  // ⚠️ ELLE NE FILTRE PAS LA LISTE, elle NAVIGUE DEDANS.
  //
  // Une recherche qui ne garde que les messages correspondants détruit
  // ce qu'on cherche vraiment : le CONTEXTE. Retrouver « rendez-vous »
  // n'a d'intérêt que si l'on voit la réponse juste en dessous. Ici la
  // conversation reste entière, les occurrences sont surlignées, et les
  // deux chevrons sautent de l'une à l'autre — de la plus récente vers
  // la plus ancienne, comme dans toutes les messageries.
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  /// Le focus du champ de saisie. Tenu ICI et non dans le composeur :
  /// c'est l'écran qui décide quand le clavier cède la place au panneau
  /// de stickers, et il lui faut de quoi le rappeler.
  final _champFocus = FocusNode();
  String _query = '';

  /// Identifiants des messages correspondants, du plus récent au plus
  /// ancien.
  List<String> _hits = const [];
  int _hitIndex = 0;

  /// Message vers lequel on vient de sauter — il clignote brièvement.
  ///
  /// Sans ce repère, arriver sur un message ancien laisse l'utilisateur
  /// devant un mur de texte sans savoir lequel il cherchait.
  String? _flashedId;
  Timer? _flashTimer;

  /// Les bulles actuellement construites, pour pouvoir en amener une à
  /// l'écran. Les autres n'existent pas encore : la liste ne fabrique
  /// que ce qui est visible.
  final Map<String, GlobalKey> _messageKeys = {};

  /// La photographie de chaque bulle, pour la désintégration à la
  /// suppression (voir `Dissolution`).
  final Map<String, GlobalKey> _clesCapture = {};

  /// Les messages en train de quitter la conversation : leur place se
  /// referme pendant que leur poussière s'envole.
  final Map<String, AnimationController> _effondrements = {};

  /// Retire définitivement un message — gardé pour `dispose`, où `ref`
  /// n'est plus utilisable.
  void Function(String id)? _retirerMessage;

  /// Supprime des messages, comme Telegram : chaque bulle visible part en
  /// poussière (`Dissolution`), et sa place se referme en 250 ms sur la
  /// courbe de la liste — les bulles voisines glissent pendant que les
  /// grains s'envolent. Le message n'est retiré qu'une fois la place
  /// refermée, pour que la liste ne saute pas.
  Future<void> _supprimerAvecEffet(List<MeshMessage> messages) async {
    final notifier = ref.read(meshMessagesProvider.notifier);
    _retirerMessage = notifier.deleteMessage;
    final visibles = [
      for (final m in messages)
        if (_clesCapture[m.id]?.currentContext != null) m,
    ];
    final part = visibles.isEmpty ? 1.0 : 1 / visibles.length;
    await Future.wait([
      for (final m in visibles)
        Dissolution.jouer(context, _clesCapture[m.id]!, part: part),
    ]);
    if (!mounted) {
      for (final m in messages) {
        notifier.deleteMessage(m.id);
      }
      return;
    }
    for (final m in messages) {
      if (!visibles.contains(m) || _effondrements.containsKey(m.id)) {
        if (!_effondrements.containsKey(m.id)) notifier.deleteMessage(m.id);
        continue;
      }
      final controleur = AnimationController(
        vsync: this,
        duration: TransitionEnvoi.duree,
      );
      _effondrements[m.id] = controleur;
      controleur.forward().whenComplete(() {
        notifier.deleteMessage(m.id);
        _effondrements.remove(m.id);
        controleur.dispose();
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

  /// Le point de DÉPART du vol d'envoi : la boîte de texte de la barre
  /// de saisie.
  final GlobalKey _champSaisieKey = GlobalKey();

  /// La zone de la conversation, qui sert à calculer où la bulle se
  /// posera.
  final GlobalKey _zoneListeKey = GlobalKey();

  /// Combien de fois le fond en dégradé a déjà tourné.
  ///
  /// C'est le mécanisme exact de Telegram : le fond ne défile pas en
  /// boucle, il avance d'un cran à chaque message ENVOYÉ. Le lien entre
  /// le geste et le mouvement est ce qui rend l'effet vivant plutôt que
  /// décoratif.
  int _fondTick = 0;

  /// La transition d'envoi en cours (voir `transition_envoi.dart`).
  ///
  /// La dernière bulle sortante qui porte ce texte est enveloppée par
  /// `EntreeEnvoi` tant qu'elle dure ; `surFin` remet ce champ à `null`,
  /// y compris si la bulle n'est jamais apparue.
  EtatEnvoi? _envoi;

  /// La transition d'envoi d'un VOCAL (voir `transition_vocale.dart`).
  ///
  /// ⚠️ DISTINCTE DE `_envoi`. Ce n'est pas la même animation : 220 ms au
  /// lieu de 250, une seule courbe sur l'horizontale au lieu de deux, et
  /// un disque qui voyage au lieu de deux textes et deux fonds. Les
  /// fusionner donnerait un vocal qui part comme un texte — trop vif pour
  /// un trajet aussi court.
  EtatVocal? _envoiVocal;

  /// Où se trouve le cercle d'enregistrement, pour que le disque parte
  /// exactement de lui.
  ///
  /// ⚠️ MESURÉ, PAS CALCULÉ. On pourrait déduire le centre de la position
  /// du bouton micro — 44 points du bord, moitié de 44 — mais la barre
  /// flotte au-dessus d'une zone sûre dont la hauteur change d'un
  /// téléphone à l'autre. Une estimation ferait partir le disque à côté
  /// de l'endroit d'où il est censé venir, et le raccord se verrait.
  final GlobalKey _cleCercle = GlobalKey();

  /// La pile de l'écran : sert de repère pour situer le vrai bouton micro.
  final GlobalKey _clePile = GlobalKey();

  /// Le centre du bouton micro, en distance au bord DROIT et au bord BAS
  /// de la pile — la forme qu'attend `Positioned`.
  ///
  /// ⚠️ MESURÉ, PAS SUPPOSÉ. Le cercle et le cadenas étaient posés à
  /// « 44 du bord droit, 44 du bas », une estimation. Or le micro vit
  /// dans une barre flottante (marges 8 + 4, zone sûre du bas en plus) :
  /// sur un iPhone, son centre est à 34 du bord et à près de 70 du bas.
  /// Le cercle tombait donc 14 points plus bas et 10 plus à droite que
  /// le doigt, et le cadenas n'était plus au-dessus du pouce — sur la
  /// capture, il mordait sur le bord de l'écran.
  ///
  /// Lu dans la mise en page de l'image précédente : le micro ne bouge
  /// pas pendant un enregistrement, la valeur est donc juste.
  /// Le bas du cadenas, au repos, au-dessus du CENTRE du micro.
  static const double _basVerrou = 60;

  Offset _ancreMicro() {
    // ⚠️ LA DERNIÈRE MESURE VALIDE, PAS UNE VALEUR FIXE, QUAND LE MICRO
    // DISPARAÎT. Une fois verrouillé, la barre passe à sa rangée « mains
    // libres » et le micro n'est plus monté : revenir alors à une
    // estimation ferait sauter le cercle et le cadenas de dix points, à
    // l'instant même du verrouillage.
    final repli = _derniereAncre;
    final micro = ClesExplications.boutonMicro.currentContext
        ?.findRenderObject();
    final pile = _clePile.currentContext?.findRenderObject();
    if (micro is! RenderBox ||
        pile is! RenderBox ||
        !micro.hasSize ||
        !pile.hasSize ||
        !micro.attached ||
        !pile.attached) {
      return repli;
    }
    final centre = pile.globalToLocal(
      micro.localToGlobal(micro.size.center(Offset.zero)),
    );
    return _derniereAncre = Offset(
      pile.size.width - centre.dx,
      pile.size.height - centre.dy,
    );
  }

  Offset _derniereAncre = const Offset(34, 44);

  /// L'opacité du champ de saisie : vidé à l'envoi, il réapparaît en fondu
  /// pendant la transition, comme chez Telegram.
  final ValueNotifier<double> _opaciteChamp = ValueNotifier(1);

  bool _recording = false;

  /// Le prochain vocal part en vue unique : il s'écoute une fois, puis il
  /// disparaît des deux téléphones.
  bool _vocalVueUnique = false;

  // ══ LA VIDÉO RONDE ════════════════════════════════════════════════
  //
  // Le même bouton sert au vocal et à la vidéo ronde : un appui COURT
  // bascule de l'un à l'autre, un maintien enregistre. C'est le geste de
  // Telegram, et il tient en un seul bouton là où deux auraient encombré
  // une barre déjà pleine.

  final CameraRonde _cameraRonde = CameraRonde();

  /// Le bouton est-il en mode caméra ?
  bool _modeVideo = false;

  /// Y a-t-il seulement une caméra ? Tant que c'est faux, l'attente de
  /// 150 ms ne s'arme pas et la bascule n'existe pas — exactement ce que
  /// fait Telegram sur un appareil sans caméra.
  bool _cameraDisponible = false;

  /// Le début de la prise vidéo, pour en déduire la durée au moment de
  /// compresser.
  ///
  /// ⚠️ DISTINCT DE `_debutEnregistrement`, QUI VIT DANS `_InputBarState`.
  /// Les deux portent la même idée mais pas dans la même classe : celui
  /// de la barre de saisie fait avancer le chrono affiché, celui-ci sert
  /// à calculer un débit. Les confondre était une erreur de compilation —
  /// un champ d'une classe lu depuis une autre.
  DateTime _debutVideo = DateTime.now();

  /// L'état du geste d'enregistrement.
  ///
  /// ⚠️ IL VIT DANS L'ÉCRAN, PAS DANS LA BARRE DE SAISIE. Deux choses le
  /// lisent et doivent s'accorder à l'image près : la barre (chrono,
  /// invite de glissement) et la SURCOUCHE (cercle, cadenas), qui flotte
  /// au-dessus de la conversation et n'est donc pas dans la barre. Le
  /// laisser dans la barre revenait à le lire depuis une autre classe —
  /// ce qui ne compile pas.
  final _RecordDrag _recDrag = _RecordDrag();
  bool _playingAudio = false;
  final _recorder = AudioRecorder();
  AudioPlayer? _player;
  String? _activeAudioFile;
  double _playbackProgress = 0;
  Duration? _playbackPosition;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<void>? _completeSub;
  Duration? _activeAudioDuration;

  /// Vitesse de lecture des messages vocaux (1×, 1,5× ou 2×). Conservée
  /// d'un message à l'autre : quelqu'un qui écoute vite veut écouter
  /// vite tout le temps, pas le redemander à chaque bulle.
  double _playbackSpeed = 1.0;

  // ── TRANSCRIPTION DES VOCAUX ─────────────────────────────────────
  //
  // Le texte d'un vocal, une fois demandé (voir `ServiceIntelligence`).
  // Rien ne part tout seul : c'est un appui sur le « A » de la bulle qui
  // déclenche le calcul, et le résultat est gardé.
  final Map<String, String> _transcriptions = {};
  final Set<String> _transcriptionsEnCours = {};

  /// Cet appareil a-t-il un moteur vocal hors ligne ? Sans lui, le bouton
  /// n'apparaît pas du tout.
  bool _moteurVocal = false;

  /// Les traductions demandées, par message.
  final Map<String, String> _traductions = {};
  final Set<String> _traductionsEnCours = {};

  /// Traduit un message dans la langue de l'interface, sur l'appareil.
  ///
  /// Un deuxième appui remet l'original : c'est le « Voir l'original » de
  /// Telegram, au même endroit.
  Future<void> _traduire(MeshMessage m) async {
    if (_traductions.containsKey(m.id)) {
      setState(() => _traductions.remove(m.id));
      return;
    }
    if (!ref.read(packDebloqueProvider)) {
      OuroHaptics.selection();
      context.push('/premium');
      return;
    }
    final l10n = AppLocalizations.of(context);
    final cible = Localizations.localeOf(context).languageCode;
    setState(() => _traductionsEnCours.add(m.id));
    final resultat = await ServiceIntelligence.traduire(
      idMessage: m.id,
      texte: MiseEnForme.sansMarqueurs(m.content),
      cible: cible,
    );
    if (!mounted) return;
    setState(() => _traductionsEnCours.remove(m.id));
    if (resultat.reussi) {
      setState(() => _traductions[m.id] = resultat.texte!);
      return;
    }
    ref.read(toastProvider.notifier).show(
          switch (resultat.etat) {
            EtatIntelligence.identique => l10n.msgShowOriginal,
            EtatIntelligence.modele => l10n.msgTranslateModel,
            _ => l10n.msgTranslateFailed,
          },
          type: DropletToastType.warning,
        );
  }

  /// Ouvre la feuille de traduction — celle de Telegram et d'iOS : langue
  /// détectée, langue cible modifiable, original replié, copie, et « dans la
  /// discussion » qui pose la traduction sous le message.
  Future<void> _ouvrirTraduction(MeshMessage m) async {
    if (!ref.read(packDebloqueProvider)) {
      OuroHaptics.selection();
      context.push('/premium');
      return;
    }
    await FeuilleTraduction.afficher(
      context,
      idMessage: m.id,
      texte: MiseEnForme.sansMarqueurs(m.content),
      cible: Localizations.localeOf(context).languageCode,
      surAfficherDansLaBulle: (traduction) {
        if (mounted) setState(() => _traductions[m.id] = traduction);
      },
    );
  }

  Future<void> _transcrire(MeshMessage m) async {
    final id = m.id;
    // Déjà ouvert : on referme, comme le chevron de Telegram.
    if (_transcriptions.containsKey(id)) {
      setState(() => _transcriptions.remove(id));
      return;
    }
    if (!ref.read(packDebloqueProvider)) {
      OuroHaptics.selection();
      context.push('/premium');
      return;
    }
    final l10n = AppLocalizations.of(context);
    final chemin = await StorageService.getSharedFilePath(m.fileId ?? '', m.fileName ?? '');
    if (!mounted) return;
    if (chemin == null) {
      ref.read(toastProvider.notifier).show(
            l10n.chAudioNotFullyReceived,
            type: DropletToastType.warning,
          );
      return;
    }
    setState(() => _transcriptionsEnCours.add(id));
    final resultat = await ServiceIntelligence.transcrire(
      idMessage: id,
      chemin: chemin,
      langue: Localizations.localeOf(context).toLanguageTag(),
    );
    if (!mounted) return;
    setState(() => _transcriptionsEnCours.remove(id));
    if (resultat.reussi) {
      setState(() => _transcriptions[id] = resultat.texte!);
      return;
    }
    ref.read(toastProvider.notifier).show(
          switch (resultat.etat) {
            EtatIntelligence.vide => l10n.vnNoSpeech,
            // Il manque le modèle vocal de la langue : il se télécharge une
            // fois si le réseau est autorisé, puis tout reste sur l'appareil.
            EtatIntelligence.modele => ServiceIntelligence.enLigneAutorise
                ? l10n.vnModelDownloading
                : l10n.vnModelNeeded,
            _ => l10n.vnTranscribeFailed,
          },
          type: DropletToastType.warning,
        );
  }

  /// Les vocaux déjà écoutés, pour la pastille « non lu ». En mémoire
  /// seulement : au prochain lancement, la pastille disparaît de toute
  /// façon puisque les messages sont alors tous anciens.
  final Set<String> _playedVoiceNotes = {};

  // ── Enregistrement en cours ──────────────────────────────────────
  //
  // La forme d'onde affichée en direct N'EST PLUS la même liste que
  // celle envoyée avec le message : la première est une fenêtre
  // glissante (les dernières secondes, qui défilent), la seconde est le
  // relevé COMPLET du début à la fin.

  /// Fenêtre glissante affichée pendant qu'on parle.
  final List<double> _amplitudes = [];

  /// Relevé complet, qui deviendra la forme d'onde du message.
  final List<double> _fullEnvelope = [];

  Timer? _ampTimer;

  /// Instant du début de l'enregistrement, pour en mesurer la durée
  /// réelle plutôt que de la deviner d'après le poids du fichier.
  DateTime? _recordStartedAt;

  /// Enregistrement « verrouillé » : on a fait glisser le micro vers le
  /// haut, on peut lâcher l'écran et continuer à parler les mains
  /// libres, comme sur WhatsApp.
  bool _recordingLocked = false;

  /// Le dernier niveau de micro relevé, destiné au cercle.
  ///
  /// Distinct de [_amplitudes], qui garde toute la fenêtre glissante :
  /// celle-là sert à dessiner la forme d'onde du message fini, où l'on
  /// veut justement voir chaque pic.
  double _amplitudeCible = 0;

  /// Combien de relevés depuis le début. Voir `CercleEnregistrement.releve`
  /// pour pourquoi deux relevés de même valeur doivent rester distincts.
  int _releveAmplitude = 0;

  /// Le démarrage du micro EN COURS, s'il y en a un.
  ///
  /// ⚠️ Sans ce garde-fou, le micro pouvait rester allumé à l'insu de
  /// tout le monde. Allumer le micro n'est pas instantané (permission,
  /// arrêt d'un éventuel enregistrement précédent, ouverture du
  /// périphérique : facilement 300 ms). Or un geste rapide relâche le
  /// doigt AVANT la fin de cette séquence. `_stopRecording` trouvait
  /// alors `_recording == false`, en concluait qu'il n'y avait rien à
  /// arrêter et sortait aussitôt — pendant que le démarrage, lui, allait
  /// jusqu'au bout. Résultat : l'app affichait la barre de saisie au
  /// repos, et Android affichait sa pastille verte « micro actif ».
  ///
  /// Arrêt et annulation attendent donc désormais la fin du démarrage
  /// avant de décider qu'il n'y a rien à faire.
  Future<void>? _pendingStart;

  // Citation / swipe-to-reply
  MeshMessage? _replyTarget;

  // Scroll / jump-to-bottom
  bool _showJumpButton = false;
  int _unreadWhileScrolled = 0;
  DateTime? _lastReadAt;

  // Throttle du signal de frappe
  Timer? _typingTimer;
  DateTime _lastTypingSent = DateTime.fromMillisecondsSinceEpoch(0);

  // Souscription aux réactions partagées du pair
  StreamSubscription<({String messageId, String emoji})>? _reactionSub;

  // Souscription aux effets plein écran des messages reçus (les effets de
  // bulle, eux, se déclenchent naturellement via l'entrée en liste de la
  // nouvelle bulle — voir _MessageBubble.build).
  StreamSubscription<MeshMessage>? _effectSub;

  bool _loadingOlder = false;

  @override
  void initState() {
    super.initState();
    final key = _isGroup
        ? widget.groupId
        : (_isBroadcast ? 'broadcast' : widget.peerId);
    _isLocked = StorageService.getLockedConversations().contains(key);
    // Le brouillon laissé la dernière fois — voir `brouillons.dart`.
    if (key != null) {
      final brouillon = Brouillons.lire(key);
      if (brouillon != null) _inputCtrl.text = brouillon;
    }
    _scrollCtrl.addListener(_onScroll);
    Epingles.revision.addListener(_surEpingles);
    final cible = widget.messageCible;
    if (cible != null) {
      // Après la première image : la liste doit exister pour qu'on y
      // saute. Un second passage affine, une fois la bulle construite.
      // ⚠️ APRÈS LA TRANSITION D'OUVERTURE (≈ 300 ms) : avant, l'écran
      // se cale encore tout en bas et le saut serait aussitôt défait.
      Future<void>.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        final messages = _isGroup
            ? ref.read(groupMessagesProvider(widget.groupId!))
            : ref.read(conversationMessagesProvider(
                _isBroadcast ? null : widget.peerId));
        _jumpToMessage(cible, messages);
      });
    }
    unawaited(ClavierInteractif.disponible().then((oui) {
      if (mounted && oui) setState(() => _clavierInteractif = true);
    }));
    // Le fichier de la mascotte est lu une fois, pas au premier envoi.
    MascotteEnvoi.prechauffer();
    ServiceIntelligence.transcriptionDisponible().then((ok) {
      if (mounted && ok) setState(() => _moteurVocal = true);
    });
    // ⚠️ ON DEMANDE, ON N'ALLUME PAS. Savoir qu'une caméra existe ne
    // demande aucune permission et ne coûte rien ; l'allumer poserait la
    // demande d'autorisation à l'ouverture de chaque conversation, pour
    // une fonction que la plupart des gens n'utiliseront pas ce jour-là.
    _cameraRonde.disponible().then((ok) {
      if (mounted) setState(() => _cameraDisponible = ok);
    });
    _cameraRonde.auTempsMax = () => unawaited(_arreterVideoRonde(garder: true));
    // ⚠️ APRÈS LA PREMIÈRE IMAGE, PAS DANS `initState`. Les visites
    // désignent des boutons par leur `GlobalKey` : tant que l'écran n'est
    // pas peint, aucune n'est montée, et `Guide` sauterait toutes les
    // étapes en silence — la visite serait marquée « vue » sans avoir rien
    // montré, et ne reviendrait jamais.
    //
    // Pas dans une bulle non plus : trois cents points de haut, et on y
    // vient pour répondre en deux secondes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.enBulle) return;
      unawaited(Explications.composeur(context));
    });
    NotificationService.openConversationId = key;
    // La notification de cette discussion n'a plus lieu d'être : on la
    // lit. ⚠️ Pas le CANAL — seulement la notification. Supprimer le canal
    // jetterait les réglages que la personne y avait faits.
    if (key != null) unawaited(NotifsConversation.effacer(key));
    // Où l'on s'était arrêté, AVANT que l'ouverture ne marque tout comme lu.
    if (key != null) _luJusquA = ref.read(conversationReadsProvider)[key];
    // Ouvrir la conversation efface sa notification, comme WhatsApp.
    if (key != null) unawaited(NotificationService.oublierConversation(key));
    // Et ce que le centre de notifications en disait est lu, la bannière
    // qui l'annonçait s'en va.
    if (key != null) {
      unawaited(JournalNotifs.instance.marquerConversationLue(key));
      Bannieres.fermerSi(key);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _isGroup
          ? widget.groupId!
          : (_isBroadcast ? 'broadcast' : widget.peerId!);
      ref.read(conversationReadsProvider.notifier).markRead(key);
      if (!_isGroup) {
        ref
            .read(meshMessagesProvider.notifier)
            .scheduleReadReceipts(_isBroadcast ? null : widget.peerId);
      } else {
        // Groupe : chaque auteur apprend qu'on a lu (coches bleues quand
        // tout le groupe a lu).
        unawaited(
          ref
              .read(meshMessagesProvider.notifier)
              .envoyerLecturesGroupe(widget.groupId!),
        );
      }
    });
    // Réactions partagées : si le pair envoie une réaction, on joue l'overlay côté récepteur.
    _reactionSub = ref
        .read(meshMessagesProvider.notifier)
        .reactionEvents
        .listen((evt) {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          // Effet de particules ancé sur la bulle réagie.
          final origin = _centreDeLaBulle(evt.messageId);
          if (origin != null) {
            ReactionEffectOverlay.show(
              context,
              emoji: evt.emoji,
              origin: origin,
            );
          }
          // Pour ❤️ on joue en plus la salve de cœurs.
          if (evt.emoji == '❤️') {
            HeartBurstOverlay.show(context, origine: origin);
          }
        });
    // Effets plein écran reçus d'un pair — l'expéditeur les déclenche déjà
    // lui-même dans _send() ; ici on couvre le destinataire.
    final myId = ref.read(meshRepositoryProvider).myId;
    _effectSub = ref.read(meshRepositoryProvider).newMessageEvents.listen((
      msg,
    ) {
      if (!mounted) return;
      // Un message de groupe arrive pendant qu'on regarde le groupe : il est
      // lu, et son auteur doit le savoir. Le petit délai laisse le message
      // entrer dans la liste avant qu'on la parcoure.
      if (_isGroup &&
          msg.groupId == widget.groupId &&
          msg.senderId != myId &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          unawaited(
            ref
                .read(meshMessagesProvider.notifier)
                .envoyerLecturesGroupe(widget.groupId!),
          );
        });
      }
      if (msg.senderId == myId ||
          msg.effect == null ||
          !kFullscreenEffects.contains(msg.effect)) {
        return;
      }
      final belongsHere = _isGroup
          ? msg.groupId == widget.groupId
          : (_isBroadcast
                ? msg.groupId == null && msg.targetId == null
                : msg.senderId == widget.peerId);
      if (belongsHere) MessageEffectOverlay.play(context, msg.effect!);
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  RECHERCHE ET SAUT DANS L'HISTORIQUE
  // ─────────────────────────────────────────────────────────────

  void _openSearch() {
    OuroHaptics.light();
    setState(() => _searching = true);
    // Le clavier ne s'ouvre qu'après la construction de la barre : le
    // demander plus tôt viserait un champ qui n'existe pas encore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _searchCtrl.clear();
    setState(() {
      _searching = false;
      _query = '';
      _hits = const [];
      _hitIndex = 0;
    });
  }

  /// Le type du dernier message envoyé, pour le fond adaptatif.
  ///
  /// En mode adaptatif, le fond change légèrement selon le type du
  /// dernier message : texte, photo, ou vocal.
  String _lastMessageType(List<MeshMessage> messages, String myId) {
    final sent = messages.where((m) => m.senderId == myId).toList();
    if (sent.isEmpty) return 'text';
    final last = sent.last;
    if (last.type == 'file') {
      if ((mediaKindOf(last.fileMimeType, last.fileName) == MediaKind.image)) {
        return 'photo';
      }
      if ((mediaKindOf(last.fileMimeType, last.fileName) == MediaKind.audio)) {
        return 'audio';
      }
    }
    return 'text';
  }

  /// Recalcule les occurrences et saute d'emblée à la plus récente.
  void _runSearch(String raw, List<MeshMessage> messages) {
    final query = raw.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _hits = const [];
        _hitIndex = 0;
      });
      return;
    }

    // Les messages arrivent du plus ancien au plus récent ; on inverse
    // pour que le premier résultat proposé soit le plus récent — c'est
    // presque toujours celui qu'on cherche.
    final hits = <String>[];
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      // Un fichier n'a pas de texte : on cherche dans son nom.
      final haystack = (m.type == 'file' ? (m.fileName ?? '') : m.content)
          .toLowerCase();
      if (haystack.contains(query)) hits.add(m.id);
    }

    setState(() {
      _query = query;
      _hits = hits;
      _hitIndex = 0;
    });
    if (hits.isNotEmpty) _jumpToMessage(hits.first, messages);
  }

  void _gotoHit(int delta, List<MeshMessage> messages) {
    if (_hits.isEmpty) return;
    OuroHaptics.selection();
    setState(() {
      _hitIndex = (_hitIndex + delta) % _hits.length;
      if (_hitIndex < 0) _hitIndex += _hits.length;
    });
    _jumpToMessage(_hits[_hitIndex], messages);
  }

  /// Amène un message à l'écran et le fait clignoter.
  ///
  /// ⚠️ DEUX CAS, ET C'EST LE SECOND QUI EST DÉLICAT.
  ///
  /// Si la bulle est déjà construite (visible ou dans la zone de cache),
  /// `ensureVisible` l'amène proprement, avec une animation. Sinon elle
  /// n'existe tout simplement pas : une liste ne fabrique que ce qu'elle
  /// affiche. On saute alors À L'ESTIME, au prorata de la position du
  /// message dans l'historique, puis on affine une fois la bulle
  /// construite. L'estimation est grossière — les bulles n'ont pas
  /// toutes la même hauteur — mais elle amène assez près pour que la
  /// seconde passe termine le travail.
  void _jumpToMessage(String messageId, List<MeshMessage> messages) {
    final key = _messageKeys[messageId];
    final ctx = key?.currentContext;

    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: DesignTokens.durationNormal,
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
      _flash(messageId);
      return;
    }

    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0 || !_scrollCtrl.hasClients) return;
    final extent = _scrollCtrl.position.maxScrollExtent;
    final target = (extent * (index / messages.length)).clamp(0.0, extent);
    _scrollCtrl.jumpTo(target);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _messageKeys[messageId]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: DesignTokens.durationFast,
          curve: Curves.easeOutCubic,
          alignment: 0.35,
        );
      }
      _flash(messageId);
    });
  }

  void _flash(String messageId) {
    _flashTimer?.cancel();
    setState(() => _flashedId = messageId);
    _flashTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _flashedId = null);
    });
  }

  /// Surveille si on est en train de lire les messages tout en bas (le
  /// message le plus récent) ou remonté plus haut dans l'historique —
  /// c'est ce qui décide si le petit bouton flottant « nouveaux
  /// messages » doit apparaître.
  ///
  /// Suit aussi la vélocité du scroll pour l'effet « bulles qui
  /// respirent » — quand on scroll vite, les bulles se compressent
  /// légèrement (scale 0.97), et quand on s'arrête, elles reviennent
  /// à la normale avec un micro-spring.
  double _scrollVelocity = 0;
  double _lastScrollOffset = 0;
  DateTime _lastScrollTime = DateTime.now();

  // ── LA DATE QUI RESTE EN HAUT PENDANT LE DÉFILEMENT ─────────────────
  //
  // En remontant une longue journée, les séparateurs « Mardi » défilent
  // avec le reste : au milieu d'un écran de bulles, on ne savait plus de
  // quel jour on lisait les messages. Comme Telegram et WhatsApp, la date
  // du premier message visible flotte en haut tant qu'on fait défiler,
  // puis s'efface une seconde et demie après l'arrêt.
  String? _jourFlottant;
  bool _jourVisible = false;
  Timer? _minuteurJour;
  DateTime _derniereMajJour = DateTime(0);
  Map<String, MeshMessage> _parIdCourant = const {};

  void _majJourFlottant() {
    // Pas plus d'une mesure toutes les 80 ms : on parcourt les bulles
    // construites, et ce n'est pas la peine de le faire à chaque pixel.
    final maintenant = DateTime.now();
    if (maintenant.difference(_derniereMajJour).inMilliseconds < 80) return;
    _derniereMajJour = maintenant;
    final haut = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;
    MeshMessage? premier;
    var meilleur = double.infinity;
    for (final e in _messageKeys.entries) {
      final rendu = e.value.currentContext?.findRenderObject();
      if (rendu is! RenderBox || !rendu.attached || !rendu.hasSize) continue;
      final y = rendu.localToGlobal(Offset.zero).dy;
      if (y + rendu.size.height < haut) continue;
      if (y < meilleur) {
        meilleur = y;
        premier = _parIdCourant[e.key];
      }
    }
    if (premier == null) return;
    final t = premier.timestamp;
    final libelle = _dayLabel(context, DateTime(t.year, t.month, t.day));
    if (libelle != _jourFlottant || !_jourVisible) {
      setState(() {
        _jourFlottant = libelle;
        _jourVisible = true;
      });
    }
    _minuteurJour?.cancel();
    _minuteurJour = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _jourVisible = false);
    });
  }

  void _onScroll() {
    // Seulement quand c'est le DOIGT qui fait défiler : pas au défilement
    // automatique vers le bas à l'ouverture ou à l'envoi.
    if (_scrollCtrl.hasClients &&
        _scrollCtrl.position.userScrollDirection != ScrollDirection.idle) {
      _majJourFlottant();
    }
    final atBottom =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.offset < 80;
    if (atBottom && _showJumpButton) {
      setState(() {
        _showJumpButton = false;
        _unreadWhileScrolled = 0;
      });
    } else if (!atBottom && !_showJumpButton) {
      setState(() => _showJumpButton = true);
    }
    // Tracker la vélocité via la différence de position entre deux ticks.
    final now = DateTime.now();
    final dt = now.difference(_lastScrollTime).inMilliseconds;
    final offset = _scrollCtrl.offset;
    if (dt > 0) {
      final speed = (offset - _lastScrollOffset).abs() / dt;
      final normalized = (speed * 16).clamp(0.0, 1.0); // ~1 frame at 60fps
      if ((normalized - _scrollVelocity).abs() > 0.05) {
        setState(() => _scrollVelocity = normalized);
      }
    }
    _lastScrollOffset = offset;
    _lastScrollTime = now;
  }

  @override
  void deactivate() {
    // Quitter la discussion la laisse lue jusqu'au dernier message reçu.
    _marquerLuMaintenant();
    super.deactivate();
  }

  @override
  void dispose() {
    // ⚠️ AVANT TOUT LE RESTE. Quitter la conversation pendant un
    // enregistrement vidéo laisserait la caméra allumée : la diode reste
    // au rouge, la batterie se vide, et plus aucune autre application ne
    // peut l'ouvrir.
    _cameraRonde.dispose();
    _minuteurJour?.cancel();
    _envoiVocal?.dispose();
    _recDrag.dispose();
    _champFocus.dispose();
    final key = _isGroup
        ? widget.groupId
        : (_isBroadcast ? 'broadcast' : widget.peerId);
    if (NotificationService.openConversationId == key) {
      NotificationService.openConversationId = null;
    }
    // Ce qu'on avait commencé à écrire reste là pour le retour — et
    // s'affiche en rouge dans la liste en attendant.
    // En pleine modification, le champ contient l'ANCIEN message, pas un
    // brouillon : c'est ce qu'on tapait avant qui doit être gardé.
    if (key != null) {
      unawaited(Brouillons.ecrire(
        key,
        _enEdition != null ? (_brouillonAvantEdition ?? '') : _inputCtrl.text,
      ));
    }
    // Retirée AVANT d'être terminée : sa fin ne doit pas appeler
    // `setState` sur un écran en cours de destruction.
    final envoi = _envoi;
    _envoi = null;
    envoi?.terminer();
    // Les suppressions en cours vont jusqu'au bout, même écran fermé.
    // (Pas de `ref` ici : l'écran est en cours de destruction.)
    for (final e in _effondrements.entries) {
      e.value.dispose();
      _retirerMessage?.call(e.key);
    }
    _effondrements.clear();
    _opaciteChamp.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _flashTimer?.cancel();
    _typingTimer?.cancel();
    _ampTimer?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _completeSub?.cancel();
    _reactionSub?.cancel();
    _effectSub?.cancel();
    _player?.dispose();
    // Quitter la conversation pendant un enregistrement doit couper le
    // micro : le laisser ouvert en arrière-plan est autant un problème de
    // vie privée que de batterie.
    if (_recording) {
      unawaited(
        _recorder.stop().catchError((e) {
          debugPrint('[Chat] arrêt micro à la fermeture: $e');
          return null;
        }),
      );
    }
    _recorder.dispose();
    // Un vocal arrêté mais jamais envoyé : on ne laisse pas traîner le
    // fichier sur le téléphone.
    final enAttente = _vocalEnAttente;
    if (enAttente != null) {
      unawaited(File(enAttente.chemin)
          .delete()
          .then<void>((_) {}, onError: (Object _) {}));
    }
    Epingles.revision.removeListener(_surEpingles);
    super.dispose();
  }

  /// Fait défiler la conversation jusqu'au tout dernier message — en
  /// glissant doucement (`animated: true`, par exemple après l'envoi
  /// d'un message) ou instantanément (à l'ouverture de l'écran).
  void _scrollToBottom({bool animated = true, bool pourEnvoi = false}) {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animated) {
        // À l'envoi, la liste monte au rythme de Telegram : 250 ms, sur la
        // même courbe que la bulle qui arrive.
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: pourEnvoi ? TransitionEnvoi.duree : 400.ms,
          curve: pourEnvoi ? TransitionEnvoi.courbeListe : Curves.easeOutCubic,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
      setState(() => _showJumpButton = false);
    });
  }

  /// Prévient l'autre personne « je suis en train d'écrire » — mais pas
  /// à chaque lettre tapée, seulement toutes les 2 secondes maximum
  /// (pour ne pas spammer le réseau mesh à chaque frappe de clavier).
  void _sendTypingSignal() {
    if (_isBroadcast) return;
    final now = DateTime.now();
    if (now.difference(_lastTypingSent).inMilliseconds < 2000) return;
    _lastTypingSent = now;
    final repo = ref.read(meshRepositoryProvider);
    if (_isGroup) {
      // Groupe : le mesh diffuse, Internet prévient chaque membre.
      final groupe = widget.groupId!;
      repo.sendTyping(groupId: groupe);
      if (EtatInternet.disponible()) {
        final membres =
            StorageService.getGroup(groupe)?.activeMembers ?? const [];
        for (final membre in membres.take(30)) {
          if (membre.peerId == repo.myId) continue;
          ref
              .read(callProvider.notifier)
              .envoyerFrappeEnLigne(membre.peerId, groupId: groupe);
        }
      }
      return;
    }
    repo.sendTyping(targetId: _targetId);
    // Par Internet aussi : le mesh ne joint pas un contact à distance.
    final cible = _targetId;
    if (cible != null && EtatInternet.disponible()) {
      ref.read(callProvider.notifier).envoyerFrappeEnLigne(cible);
    }
  }

  /// Ce qui est tapé après la dernière arobase, tant que le curseur y est :
  /// c'est ce qui filtre la liste des mentions. `null` = pas de liste.
  String? _requeteMention;

  void _majRequeteMention() {
    final texte = _inputCtrl.text;
    final selection = _inputCtrl.selection;
    final position = (selection.isValid ? selection.baseOffset : texte.length)
        .clamp(0, texte.length);
    final avant = texte.substring(0, position);
    final trouve = RegExp(r'@([^@\s]{0,24})$').firstMatch(avant);
    final requete = (_isGroup || _isBroadcast) && trouve != null ? trouve.group(1)! : null;
    if (requete != _requeteMention && mounted) {
      setState(() => _requeteMention = requete);
    }
  }

  /// Remplace ce qui suit l'arobase par le pseudo choisi.
  void _insererMention(String pseudo) {
    final texte = _inputCtrl.text;
    final position = _inputCtrl.selection.baseOffset.clamp(0, texte.length);
    final debut = texte.substring(0, position).lastIndexOf('@');
    if (debut < 0) return;
    final nouveau =
        '${texte.substring(0, debut)}@$pseudo ${texte.substring(position)}';
    OuroHaptics.selection();
    setState(() {
      _inputCtrl.value = TextEditingValue(
        text: nouveau,
        selection: TextSelection.collapsed(offset: debut + pseudo.length + 2),
      );
      _requeteMention = null;
    });
  }

  void _onTextChanged(String _) {
    _majRequeteMention();
    if (_inputCtrl.text.trim().isEmpty) {
      _typingTimer?.cancel();
      return;
    }
    _sendTypingSignal();
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 4), _sendTypingSignal);
  }

  /// Envoie vraiment le message tapé dans le champ de texte — vide le
  /// champ, joue un éventuel effet spécial choisi (voir
  /// `message_effects.dart`), et fait défiler jusqu'en bas pour voir le
  /// nouveau message.
  // ══ CE QUE LE CLAVIER COLLE ═══════════════════════════════════════
  //
  // Gboard, SwiftKey, Samsung : les GIF, les autocollants et les images
  // du presse-papiers passent par le clavier (« contenu enrichi »). Sans
  // ça, toucher un GIF dans le clavier affichait « Cette application ne
  // prend pas en charge les images ici » — WhatsApp et Telegram, eux,
  // l'envoient.
  //
  //   • un GIF ou un autocollant animé part TEL QUEL, tout de suite :
  //     c'est un geste de conversation, on ne le légende pas, et le
  //     ré-encoder figerait l'animation ;
  //   • une image fixe (une capture collée) passe par l'aperçu d'envoi,
  //     comme une photo : on veut souvent la recadrer ou la légender.

  Future<void> _contenuClavier(KeyboardInsertedContent contenu) async {
    final l10n = AppLocalizations.of(context);
    final octets = contenu.data;
    if (octets == null || octets.isEmpty) return;
    final mime = contenu.mimeType.toLowerCase();
    final anime = mime == 'image/gif' || mime == 'image/webp';
    final extension = switch (mime) {
      'image/gif' => 'gif',
      'image/webp' => 'webp',
      'image/png' => 'png',
      _ => 'jpg',
    };
    if (octets.length > _maxFileSizeBytes) {
      ref
          .read(toastProvider.notifier)
          .show(l10n.chFileTooLarge, type: DropletToastType.error);
      return;
    }
    try {
      final dossier = await getTemporaryDirectory();
      final nom =
          '${anime ? 'gif' : 'image'}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final fichier = File('${dossier.path}/$nom');
      await fichier.writeAsBytes(octets, flush: true);
      if (!mounted) return;
      if (!anime) {
        await _envoyerPhotoAvecApercu(fichier.path);
        return;
      }
      HapticFeedback.lightImpact();
      final me = StorageService.currentUser;
      await ref.read(meshMessagesProvider.notifier).sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            fileName: nom,
            bytes: octets,
            mimeType: mime,
            targetId: _targetId,
            groupId: widget.groupId,
            replyToId: _replyTarget?.id,
          );
      if (!mounted) return;
      setState(() => _replyTarget = null);
      _scrollToBottom();
    } catch (e) {
      debugPrint('[Chat] contenu du clavier: $e');
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.chCannotReadMedia, type: DropletToastType.error);
      }
    }
  }

  /// Ouvre le panneau « + » et exécute le choix.
  ///
  /// ⚠️ Ce panneau REMPLACE trois boutons qui étaient alignés dans la
  /// barre de saisie. Ce n'est pas qu'une question d'encombrement : sur
  /// un petit écran, trois icônes plus le champ plus le micro laissaient
  /// une zone de frappe étroite, et chaque icône était une cible de
  /// moins de quarante-quatre points — sous le minimum tactile. Une
  /// seule cible large, et chaque action gagne un libellé lisible.
  Future<void> _openAttachSheet() async {
    final res = await pickAttachment(context);
    if (res == null || !mounted) return;

    // Les photos cochées dans la grille partent directement, sans
    // repasser par le sélecteur système — c'est tout l'intérêt du
    // panneau, et c'est l'action la plus fréquente.
    //
    // ⚠️ UNE PAR UNE, DANS L'ORDRE DE SÉLECTION. Chacune passe par
    // l'aperçu d'envoi (légende, recadrage, vue unique) : les envoyer
    // toutes d'un bloc sauterait cette étape, et quelqu'un qui en coche
    // cinq n'aurait plus aucun moyen d'en légender une seule. L'ordre est
    // celui des numéros affichés sur les vignettes — il a été choisi, il
    // doit être respecté.
    if (res.assets.isNotEmpty) {
      for (final asset in res.assets) {
        if (!mounted) return;
        await _envoyerAsset(asset);
      }
      return;
    }

    switch (res.choix!) {
      case AttachChoice.media:
        await _pickAndSendFile(filtre: FileType.media);
      case AttachChoice.document:
        await _pickAndSendFile(filtre: FileType.any);
      case AttachChoice.sticker:
        // ⚠️ LE PANNEAU EN LIGNE, PAS UNE SECONDE FEUILLE. Les stickers
        // ont désormais leur place sous le composeur, à l'endroit du
        // clavier. Rouvrir ici la feuille modale donnerait deux
        // sélecteurs de stickers d'aspect différent dans la même
        // application, selon le chemin emprunté pour y arriver.
        _basculerStickers();
      case AttachChoice.position:
        await _shareLocation();
      case AttachChoice.poll:
        await _createPoll();
    }
  }

  /// L'appareil photo du bouton de la barre de saisie — voir
  /// `camera_rapide.dart`. La photo passe ensuite par le même aperçu et le
  /// même envoi que celles de la galerie.
  Future<void> _photoRapide() async {
    final prise = await ouvrirCameraRapide(context);
    if (prise == null || !mounted) return;
    await _envoyerPhotoAvecApercu(prise);
  }

  /// Une photo prise ou collée : l'aperçu d'envoi (légende, dessin, vue
  /// unique), puis l'envoi.
  Future<void> _envoyerPhotoAvecApercu(String prise) async {
    final l10n = AppLocalizations.of(context);
    final apercu = await ouvrirApercuEnvoi(
      context,
      chemin: prise,
      video: false,
      vueUniquePossible: true,
    );
    if (apercu == null || !mounted) return;
    try {
      final chemin = await _preparerMedia(apercu.chemin, video: false);
      final pret = File(chemin);
      if (!mounted) return;
      if (await pret.length() > _maxFileSizeBytes) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.chFileTooLarge, type: DropletToastType.error);
        return;
      }
      final me = StorageService.currentUser;
      final nom = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await ref.read(meshMessagesProvider.notifier).sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            fileName: _nomApresPreparation(nom, chemin, prise),
            bytes: await pret.readAsBytes(),
            mimeType: 'image/jpeg',
            legende: apercu.legende,
            targetId: _targetId,
            groupId: widget.groupId,
          );
      if (mounted) _scrollToBottom();
    } catch (e) {
      debugPrint('[Chat] envoi de la photo impossible: $e');
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.chCannotReadMedia, type: DropletToastType.error);
      }
    }
  }

  /// Ouvre le compositeur de sondage et envoie le résultat.
  ///
  /// Même principe que `_shareLocation` : le sondage encodé part comme
  /// un message texte ordinaire, par `_send()`, et hérite donc de tout
  /// ce qui a déjà été construit pour les messages — chiffrement, file
  /// d'attente, accusé de réception, relais.
  Future<void> _createPoll() async {
    final encode = await composePoll(context);
    if (encode == null || !mounted) return;
    _inputCtrl.text = encode;
    await _send();
  }

  /// Envoie un média choisi dans la bande des récents.
  ///
  /// ⚠️ On passe par `file`, PAS par `originBytes`. `originBytes` fait
  /// remonter la photo entière à travers le canal de méthodes Flutter,
  /// soit deux copies en mémoire du fichier complet — exactement ce qui
  /// tuait l'application sur les gros fichiers (voir `_pickAndSendFile`).
  /// On récupère donc le chemin, et on lit les octets nous-mêmes.
  Future<void> _envoyerAsset(AssetEntity asset) async {
    final l10n = AppLocalizations.of(context);
    try {
      final fichier = await asset.file;
      if (fichier == null || !mounted) return;

      final video = asset.type == AssetType.video;
      // L'aperçu : voir la photo en grand, écrire une légende, dessiner,
      // recadrer — ou renoncer.
      final apercu = await ouvrirApercuEnvoi(
        context,
        chemin: fichier.path,
        video: video,
        vueUniquePossible: true,
      );
      if (apercu == null || !mounted) return;
      String? idPrepare;
      final String chemin;
      if (video) {
        final preparation = await _preparerVideo(
          apercu.chemin,
          fichier.uri.pathSegments.last,
        );
        if (preparation == null) return;
        idPrepare = preparation.id;
        chemin = preparation.chemin;
      } else {
        chemin = await _preparerMedia(apercu.chemin, video: false);
      }
      final pret = File(chemin);
      if (!mounted) return;
      final taille = await pret.length();
      if (taille > _maxFileSizeBytes) {
        if (idPrepare != null) {
          ref.read(meshMessagesProvider.notifier).annulerEnvoi(idPrepare);
        }
        ref
            .read(toastProvider.notifier)
            .show(l10n.chFileTooLarge, type: DropletToastType.error);
        return;
      }

      final nom = await asset.titleAsync;
      final me = StorageService.currentUser;
      await ref
          .read(meshMessagesProvider.notifier)
          .sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            fileName: _nomApresPreparation(
              nom.isNotEmpty ? nom : fichier.uri.pathSegments.last,
              chemin,
              fichier.path,
            ),
            bytes: await pret.readAsBytes(),
            mimeType: video ? 'video/mp4' : 'image/jpeg',
            legende: apercu.legende,
            idPrepare: idPrepare,
            targetId: _targetId,
            // ⚠️ LE GROUPE MANQUAIT : dans une conversation de groupe, une
            // photo envoyée depuis la bande des récents partait sans groupe
            // ni destinataire — c'est-à-dire en diffusion à tout le voisinage.
            groupId: widget.groupId,
          );
      if (mounted) _scrollToBottom();
    } catch (e) {
      debugPrint('[Chat] envoi du média récent impossible: $e');
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.chCannotReadMedia, type: DropletToastType.error);
      }
    }
  }

  /// Ouvre le panneau de stickers et envoie celui qu'on choisit.
  ///
  /// Le sticker part comme un message texte ordinaire : c'est un ou
  /// deux emojis, quelques octets. Il traverse donc le mesh
  /// instantanément, là où une image de sticker demanderait un transfert
  /// de fichier complet — voir `sticker_picker.dart` pour le
  /// raisonnement.
  // ══ LE PANNEAU DE STICKERS, À LA PLACE DU CLAVIER ═════════════════
  //
  // C'est le geste d'iOS — iMessage, WhatsApp, Telegram : le bouton
  // REMPLACE le clavier par la grille, au même endroit et à la même
  // hauteur, et son icône devient un clavier pour faire le chemin
  // inverse. Une feuille modale ne pouvait pas le faire : elle se posait
  // par-dessus, le clavier se refermait sous elle, et la barre de saisie
  // disparaissait — on ne pouvait plus écrire en cherchant un sticker.

  bool _stickersOuverts = false;

  /// La dernière hauteur de clavier observée.
  ///
  /// ⚠️ C'EST CE QUI EMPÊCHE L'ÉCRAN DE SAUTER. Le panneau doit faire
  /// EXACTEMENT la hauteur du clavier qu'il remplace : une valeur fixe
  /// donnerait un bond de quelques dizaines de points au moment précis de
  /// la bascule, et c'est ce bond qui fait qu'une application « ne fait
  /// pas iOS ». On retient donc la vraie hauteur dès qu'on la voit, et
  /// 300 ne sert que tant que le clavier ne s'est jamais ouvert.
  double _hauteurClavier = 300;

  /// Ouvre le panneau à la place du clavier, ou rend le clavier.
  void _basculerStickers() {
    OuroHaptics.selection();
    if (_stickersOuverts) {
      setState(() => _stickersOuverts = false);
      // Le clavier revient : c'est tout l'intérêt de l'icône qui change.
      _champFocus.requestFocus();
      return;
    }
    // ⚠️ ON RETIRE LE FOCUS AVANT D'OUVRIR. Sans ça, le clavier reste
    // affiché SOUS le panneau : les deux s'empilent, l'écran se décale du
    // double, et la conversation disparaît.
    _champFocus.unfocus();
    setState(() => _stickersOuverts = true);
  }

  Future<void> _envoyerSticker(String sticker) async {
    _inputCtrl.text = sticker;
    await _send();
  }

  /// Partage sa position dans la conversation.
  ///
  /// Elle voyage comme un MESSAGE TEXTE ordinaire, avec un préfixe
  /// reconnaissable : `📍loc:latitude,longitude`. Ce choix n'est pas un
  /// raccourci — c'est ce qui rend le partage fiable.
  ///
  /// Une position pèse quarante octets. En passant par le canal des
  /// messages, elle profite de tout ce qui existe déjà : le chiffrement
  /// de bout en bout, la file d'attente qui réessaie, l'accusé de
  /// réception, et le relais par les téléphones intermédiaires. Un
  /// nouveau type de paquet aurait fallu redévelopper tout cela, et un
  /// téléphone équipé d'une version antérieure de Droplet n'aurait rien
  /// reçu du tout — alors qu'ici, il voit au pire une ligne de texte
  /// avec des coordonnées.
  Future<void> _shareLocation() async {
    final l10n = AppLocalizations.of(context);
    OuroHaptics.selection();
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ref
            .read(toastProvider.notifier)
            .show(l10n.chLocationDenied, type: DropletToastType.warning);
        return;
      }

      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(l10n.chGettingPosition, type: DropletToastType.info);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      _inputCtrl.text = LocationMessage.encode(
        position.latitude,
        position.longitude,
      );
      await _send();
    } catch (e) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(l10n.chPositionUnavailable, type: DropletToastType.error);
    }
  }

  /// Lance la transition d'envoi de Telegram pour [texte].
  ///
  /// Seuls les messages qui s'affichent en simple texte s'y prêtent : un
  /// sticker, une position, un sondage ou un lien deviennent autre chose
  /// qu'un paragraphe dans la bulle — il n'y aurait rien vers quoi le
  /// texte puisse se fondre.
  void _lancerTransitionEnvoi(String texte) {
    if (texte.length > 700 || '\n'.allMatches(texte).length > 9) return;
    if (AnimatedStickerCatalog.estUneReference(texte)) return;
    if (LocationMessage.tryParse(texte) != null) return;
    if (PollMessage.tryParse(texte) != null) return;
    if (isStickerMessage(texte)) return;
    if (_extractUrl(texte) != null) return;
    if (!OuroMotion.ambiantAutoriseGlobal &&
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      return;
    }

    _envoi?.terminer();
    late final EtatEnvoi? etat;
    etat = TransitionEnvoi.lancer(
      context: context,
      champ: _champSaisieKey,
      texte: texte,
      styleChamp: OuroTypography.body.copyWith(color: OuroColors.label),
      // ⚠️ Le `contentPadding` du champ (voir `_champ()`) et le style du
      // texte des bulles (voir `_expandableTextContent`) : le départ et
      // l'arrivée doivent valoir exactement ce qu'ils valent à l'écran.
      paddingChamp: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      styleBulle: TextStyle(
        color: Colors.white,
        fontSize: ReglagesApparence.tailleTexte,
        height: ReglagesApparence.interligne,
      ),
      couleurPanneau: _couleurChampComposee,
      surDemarrage: () => _scrollToBottom(pourEnvoi: true),
      surProgression: (t) => _opaciteChamp.value = t,
      surFin: () => _finTransitionEnvoi(etat),
    );
    if (etat == null) return;
    _opaciteChamp.value = 0;
    setState(() => _envoi = etat);
  }

  /// La transition est finie (ou abandonnée) : la bulle redevient normale.
  ///
  /// ⚠️ Peut être appelée pendant la construction d'une image (bulle
  /// retirée de l'arbre) : `setState` y est interdit, d'où le report.
  /// La dernière bulle envoyée, mesurée par la transition d'envoi.
  Rect? _rectDerniereBulle;

  /// Plic vient saluer le message qui part.
  ///
  /// ⚠️ INDÉPENDANT DE LA TRANSITION D'ENVOI. Celle-ci ne se déclenche pas
  /// pour tout — un lien, un sticker, un sondage, un message de plus de 700
  /// caractères, ou le mouvement réduit l'annulent. Tant que la mascotte
  /// attendait sa fin, elle ne passait jamais dans ces cas-là.
  void _programmerMascotte() {
    final mode = ref.read(animationEnvoiProvider);
    if (mode == ModeAnimationEnvoi.desactivee) return;
    Future<void>.delayed(
      TransitionEnvoi.duree + const Duration(milliseconds: 60),
      () {
        if (!mounted) return;
        final rect = _rectDerniereBulle ?? _rectMascotteParDefaut();
        if (rect == null) {
          debugPrint("[Mascotte] aucun repère à l'écran : rien n'est joué");
          return;
        }
        MascotteEnvoi.jouer(context: context, bulle: rect, mode: mode);
      },
    );
  }

  /// À défaut de bulle mesurée : juste au-dessus de la barre de saisie, du
  /// côté libre de la ligne — Plic ne couvre alors aucun texte.
  Rect? _rectMascotteParDefaut() {
    final rendu = _champSaisieKey.currentContext?.findRenderObject();
    if (rendu is! RenderBox || !rendu.hasSize || !rendu.attached) return null;
    final haut = rendu.localToGlobal(Offset.zero);
    final largeur = MediaQuery.sizeOf(context).width;
    final x = largeur * 0.36 < 130 ? largeur * 0.36 : 130.0;
    return Rect.fromLTWH(x, haut.dy - 56, 8, 44);
  }

  void _finTransitionEnvoi(EtatEnvoi? etat) {
    _opaciteChamp.value = 1;
    if (!mounted) return;

    // La position exacte de la bulle : Plic s'ancre dessus (voir
    // `_programmerMascotte`).
    _rectDerniereBulle = etat?.rectBulle ?? _rectDerniereBulle;
    void appliquer() {
      if (mounted && _envoi == etat) setState(() => _envoi = null);
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => appliquer());
    } else {
      appliquer();
    }
  }

  Future<void> _send([String? effect]) async {
    final saisi = _inputCtrl.text.trim();
    if (saisi.isEmpty) return;
    // En modification, la coche valide : rien ne part comme un nouveau
    // message, et pas de transition — la bulle existe déjà.
    if (_enEdition != null) {
      _validerEdition(saisi);
      return;
    }
    // Le minuteur des éphémères est porté par le message lui-même
    // (`expiresInSeconds`, posé à l'envoi) : rien à ajouter au texte.
    final text = saisi;
    _typingTimer?.cancel();
    HapticFeedback.mediumImpact();
    SoundService.play(AppSound.messageOut);

    // ⚠️ LA TRANSITION PART AVANT LE VIDAGE DU CHAMP.
    //
    // Elle mesure la boîte de texte à l'instant où on l'appelle. Une fois
    // `clear()` passé, la barre de saisie s'est déjà rétractée à sa hauteur
    // d'une ligne : le texte décollerait alors du mauvais endroit.
    _lancerTransitionEnvoi(saisi);
    // Plic salue ce message, que la transition ait eu lieu ou non.
    _rectDerniereBulle = null;
    _programmerMascotte();

    _inputCtrl.clear();
    // Envoyé : il n'y a plus de brouillon. Tout de suite, pas seulement à
    // la fermeture — l'application peut être tuée d'ici là.
    unawaited(Brouillons.ecrire(_cleConversation, ''));
    final reply = _replyTarget;
    setState(() {
      _replyTarget = null;
      // Le fond avance d'un cran. Comme chez Telegram, c'est l'ENVOI qui
      // le fait bouger — pas la réception, pas le temps qui passe.
      _fondTick++;
    });
    final me = StorageService.currentUser;
    if (_isGroup) {
      await ref
          .read(meshMessagesProvider.notifier)
          .sendGroupMessage(
            me?.pseudo ?? 'Moi',
            text,
            groupId: widget.groupId!,
            replyToId: reply?.id,
            effect: effect,
          );
    } else {
      await ref
          .read(meshMessagesProvider.notifier)
          .sendMessage(
            me?.pseudo ?? 'Moi',
            text,
            targetId: _targetId,
            replyToId: reply?.id,
            effect: effect,
          );
    }
    if (!mounted) return;
    _scrollToBottom();
    if (effect != null) {
      // Effet explicitement choisi : prime sur la détection par mot-clé,
      // pour ne jamais empiler deux overlays plein écran sur un seul envoi.
      MessageEffectOverlay.play(context, effect);
    } else {
      _checkConfettiTrigger(text);
    }
  }

  /// Détecte les mots-clés de célébration et déclenche un overlay confetti.
  static final _confettiKeywords = RegExp(
    r'joyeux?\s*anniversaire|félicitations?|bravo|happy\s*birthday|toutes\s*mes\s*vœux',
    caseSensitive: false,
  );

  void _checkConfettiTrigger(String text) {
    if (_confettiKeywords.hasMatch(text)) {
      HapticFeedback.heavyImpact();
      ConfettiOverlay.show(context);
    }
  }

  /// Démarre l'enregistrement d'un message vocal — demande la
  /// permission d'utiliser le micro si nécessaire, puis commence à
  /// enregistrer dans un fichier temporaire.
  Future<void> _startRecording() async {
    // Garde contre un double déclenchement (ex. conflit de gestes tap/appui
    // long sur le bouton micro) : sans ça, un second appel à _recorder.start
    // pendant un enregistrement déjà en cours peut lever une exception
    // plateforme et laisser l'UI bloquée en état "recording".
    if (_recording || _pendingStart != null) return;
    final op = _doStartRecording();
    _pendingStart = op;
    try {
      await op;
    } finally {
      _pendingStart = null;
    }
  }

  Future<void> _doStartRecording() async {
    final l10n = AppLocalizations.of(context);
    // Remis à zéro TOUT DE SUITE, et non dans le `setState` final : entre
    // les deux, l'utilisateur a le temps de faire glisser le micro vers
    // le haut pour verrouiller, et ce verrouillage serait alors effacé
    // par un démarrage qui se termine après lui.
    _recordingLocked = false;
    final ok = await _recorder.hasPermission();
    if (!ok) {
      ref
          .read(toastProvider.notifier)
          .show(l10n.chMicPermissionDenied, type: DropletToastType.error);
      return;
    }
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      HapticFeedback.lightImpact();
      final dir = await getApplicationDocumentsDirectory();
      final recDir = Directory('${dir.path}/recordings');
      if (!await recDir.exists()) await recDir.create(recursive: true);
      final path =
          '${recDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _recordStartedAt = DateTime.now();
      setState(() => _recording = true);
      _startAmpPolling();
    } catch (e) {
      debugPrint('[Chat] démarrage enregistrement: $e');
      ref
          .read(toastProvider.notifier)
          .show(l10n.chCannotStartRecording, type: DropletToastType.error);
    }
  }

  /// Relève le niveau du micro à intervalle régulier, pour la forme
  /// d'onde affichée en direct ET pour celle qui partira avec le message.
  ///
  /// ⚠️ Le micro renvoie des DÉCIBELS (un nombre négatif), pas une valeur
  /// entre 0 et 1. L'ancien code appliquait directement un
  /// `clamp(0.0, 1.0)` dessus, ce qui écrasait tout à zéro : la forme
  /// d'onde restait plate et ne réagissait jamais à la voix. La
  /// conversion vit maintenant dans `VoiceNoteMeta.normalizeDb`.
  void _startAmpPolling() {
    _amplitudes.clear();
    // Le cercle repart du repos : sans ça, un nouvel enregistrement
    // démarrerait au volume du précédent.
    _amplitudeCible = 0;
    _fullEnvelope.clear();
    _ampTimer?.cancel();
    // 80 ms plutôt que 140 : à 140 ms, un mot court passait entre deux
    // relevés et n'apparaissait pas du tout dans le dessin.
    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      try {
        final amp = await _recorder.getAmplitude();
        final v = VoiceNoteMeta.normalizeDb(amp.current);
        if (!mounted) return;
        setState(() {
          // Relevé complet : sert à fabriquer la forme d'onde du message.
          // Borné pour qu'un enregistrement très long ne fasse pas
          // grossir la liste indéfiniment (10 min à 80 ms = 7500 points,
          // largement au-delà de ce qui est nécessaire).
          if (_fullEnvelope.length < 8000) _fullEnvelope.add(v);
          // Fenêtre glissante : ce qu'on voit défiler à l'écran.
          _amplitudes.add(v);
          if (_amplitudes.length > 44) _amplitudes.removeAt(0);

          // Le dernier relevé, BRUT. Le lissage est fait par le cercle
          // lui-même, image par image : lissé ici, au rythme des relevés
          // (80 ms), le rayon avancerait par marches — une mesure a
          // montré jusqu'à 10 points d'écart avec la courbe de Telegram,
          // sur une course de 30.
          _amplitudeCible = v;
          _releveAmplitude++;
        });
      } catch (_) {}
    });
  }

  /// Arrête l'enregistrement en cours et envoie directement le message
  /// vocal obtenu — c'est ce qui se passe quand on relâche le doigt du
  /// bouton micro normalement (sans faire glisser vers l'annulation).
  Future<void> _stopRecording() async {
    final l10n = AppLocalizations.of(context);
    // Un démarrage encore en vol : on le laisse aboutir, sinon on
    // conclurait à tort qu'il n'y a rien à arrêter (voir `_pendingStart`).
    final pending = _pendingStart;
    if (pending != null) await pending;
    if (!_recording) return;
    _ampTimer?.cancel();
    _ampTimer = null;

    // ⚠️ ON LANCE LA TRANSITION ICI, AVANT L'ENVOI, pas après. Le cercle
    // est encore à l'écran : c'est le seul instant où l'on peut le
    // mesurer. Lancer après `sendFile` ferait partir le disque d'un
    // endroit que plus rien n'occupe, après un blanc de plusieurs
    // centaines de millisecondes.
    _lancerTransitionVocale();

    // Durée MESURÉE, et non plus devinée à partir du poids du fichier :
    // un enregistrement fait dans le silence pèse beaucoup moins lourd
    // qu'un enregistrement fait dans le bruit, à durée identique.
    final startedAt = _recordStartedAt;
    final duration = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final envelope = List<double>.from(_fullEnvelope);

    setState(() {
      _recording = false;
      _recordingLocked = false;
      _amplitudes.clear();
    // Le cercle repart du repos : sans ça, un nouvel enregistrement
    // démarrerait au volume du précédent.
    _amplitudeCible = 0;
      _fullEnvelope.clear();
    });
    _recordStartedAt = null;

    // Un appui involontaire sur le micro produisait jusqu'ici un vocal
    // vide d'un dixième de seconde, envoyé pour de bon. En dessous d'une
    // demi-seconde il n'y a rien à écouter : on jette.
    if (duration.inMilliseconds < 500) {
      try {
        final path = await _recorder.stop();
        if (path != null) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
      } catch (_) {}
      return;
    }

    try {
      final path = await _recorder.stop();
      if (path == null || !File(path).existsSync()) return;
      await _envoyerVocal(path, duration, envelope);
    } catch (e) {
      debugPrint('[Chat] enregistrement: $e');
      ref
          .read(toastProvider.notifier)
          .show(l10n.chVoiceSendFailed, type: DropletToastType.error);
    }
  }

  // ══ LA RÉÉCOUTE AVANT ENVOI ══════════════════════════════════════
  //
  // Voir `relecture_vocale.dart`. On y entre en touchant « pause » sur un
  // enregistrement verrouillé : la prise s'arrête, le fichier est gardé,
  // et la barre de saisie devient un petit lecteur.

  /// Le vocal arrêté qu'on peut réécouter, ou `null`.
  VocalEnAttente? _vocalEnAttente;

  Future<void> _arreterPourReecouter() async {
    final pending = _pendingStart;
    if (pending != null) await pending;
    if (!_recording || _modeVideo) return;
    _ampTimer?.cancel();
    _ampTimer = null;
    final startedAt = _recordStartedAt;
    final duration = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final envelope = List<double>.from(_fullEnvelope);
    _recordStartedAt = null;
    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      debugPrint('[Chat] arrêt pour réécoute: $e');
    }
    if (!mounted) return;
    final valide = path != null &&
        File(path).existsSync() &&
        duration.inMilliseconds >= 500;
    HapticFeedback.lightImpact();
    setState(() {
      _recording = false;
      _recordingLocked = false;
      _amplitudes.clear();
      _amplitudeCible = 0;
      _fullEnvelope.clear();
      _vocalEnAttente = valide
          ? VocalEnAttente(chemin: path!, duree: duration, onde: envelope)
          : null;
    });
  }

  Future<void> _supprimerVocalEnAttente() async {
    final v = _vocalEnAttente;
    if (v == null) return;
    setState(() => _vocalEnAttente = null);
    try {
      final f = File(v.chemin);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _envoyerVocalEnAttente() async {
    final v = _vocalEnAttente;
    if (v == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _vocalEnAttente = null);
    try {
      await _envoyerVocal(v.chemin, v.duree, v.onde);
    } catch (e) {
      debugPrint('[Chat] envoi après réécoute: $e');
      ref
          .read(toastProvider.notifier)
          .show(l10n.chVoiceSendFailed, type: DropletToastType.error);
    }
  }

  /// Envoie le vocal enregistré dans [path] — directement au relâcher, ou
  /// après la réécoute.
  Future<void> _envoyerVocal(
    String path,
    Duration duration,
    List<double> envelope,
  ) async {
    {
      final bytes = await File(path).readAsBytes();
      final me = StorageService.currentUser;
      await ref
          .read(meshMessagesProvider.notifier)
          .sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            // La durée et la forme d'onde voyagent DANS LE NOM DU FICHIER
            // (voir `voice_note.dart`) : c'est ce qui permet à l'autre
            // téléphone de les afficher sans rien changer au format des
            // paquets réseau.
            fileName: VoiceNoteMeta.encodeFileName(
              duration: duration,
              samples: envelope,
            ),
            bytes: Uint8List.fromList(bytes),
            mimeType: 'audio/m4a',
            // La marque de la vue unique voyage dans la légende, comme pour
            // les photos (voir `vue_unique.dart`).
            legende: _vocalVueUnique ? VueUnique.marque : null,
            targetId: _targetId,
            groupId: widget.groupId,
            replyToId: _replyTarget?.id,
          );
      if (mounted) {
        setState(() {
          _replyTarget = null;
          _vocalVueUnique = false;
        });
      }
      _scrollToBottom();
    }
  }

  // ══ LA VIDÉO RONDE ══════════════════════════════════════════════

  /// Bascule le bouton entre micro et caméra, sur un appui court.
  ///
  /// ⚠️ LA CAMÉRA S'ALLUME DÈS LA BASCULE, pas à la pose du doigt.
  /// L'initialiser prend souvent 300 à 600 ms : l'allumer au moment où
  /// l'on commence à enregistrer ferait manquer la première seconde — et
  /// la première seconde d'un message vidéo, c'est le bonjour.
  Future<void> _basculerModeVideo() async {
    if (!_cameraDisponible) return;
    OuroHaptics.selection();
    final versVideo = !_modeVideo;
    setState(() => _modeVideo = versVideo);
    if (versVideo) {
      await _cameraRonde.preparer();
      if (mounted) setState(() {});
    } else {
      await _cameraRonde.eteindre();
    }
  }

  /// Démarre une prise vidéo ronde.
  Future<void> _demarrerVideoRonde() async {
    if (!_modeVideo || _recording) return;
    if (!_cameraRonde.prete) {
      // La caméra n'a pas fini de s'allumer : on l'attend plutôt que de
      // démarrer dans le vide. L'utilisateur tient déjà son doigt.
      await _cameraRonde.preparer();
    }
    if (!mounted || !_cameraRonde.prete) return;
    _recordingLocked = false;
    _debutVideo = DateTime.now();
    await _cameraRonde.demarrer();
    if (!mounted) return;
    OuroHaptics.light();
    setState(() => _recording = true);
  }

  /// Arrête la prise et l'envoie, ou la jette.
  Future<void> _arreterVideoRonde({required bool garder}) async {
    if (!_cameraRonde.enregistre) return;
    final l10n = AppLocalizations.of(context);
    final fichier = await _cameraRonde.arreter(garder: garder);
    if (!mounted) return;
    setState(() {
      _recording = false;
      _recordingLocked = false;
    });
    if (fichier == null) return;

    try {
      // ⚠️ ON COMPRESSE AVANT D'ENVOYER. Une prise de trente secondes
      // sort à plusieurs mégaoctets : sur du Bluetooth, c'est plusieurs
      // minutes de transfert pour un message qui se veut spontané. La
      // cible vient du débit de Telegram pour ce format, appliqué à la
      // durée réelle.
      final secondes =
          DateTime.now().difference(_debutVideo).inMilliseconds / 1000.0;
      final cible = (kDebitVideoRonde / 8 * secondes).round();
      final chemin = await MediaService.compresserVideoSous(
        fichier.path,
        cibleOctets: cible,
      );
      final octets = await File(chemin).readAsBytes();
      final me = StorageService.currentUser;
      await ref.read(meshMessagesProvider.notifier).sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            // ⚠️ LE SUFFIXE EST CE QUI REND LA BULLE RONDE. Le type d'un
            // message est un texte libre et ne traverse pas `sendFile` ;
            // le nom du fichier, lui, voyage tel quel — c'est déjà par là
            // que passent la durée et la forme d'onde d'un vocal.
            fileName: '${DateTime.now().millisecondsSinceEpoch}.$kTypeVideoRonde.mp4',
            bytes: Uint8List.fromList(octets),
            mimeType: 'video/mp4',
            legende: _vocalVueUnique ? VueUnique.marque : null,
            targetId: _targetId,
            groupId: widget.groupId,
            replyToId: _replyTarget?.id,
          );
      if (mounted) {
        setState(() {
          _replyTarget = null;
          _vocalVueUnique = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      debugPrint('[Chat] vidéo ronde: $e');
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.chVoiceSendFailed, type: DropletToastType.error);
      }
    }
  }

  /// Fait partir le disque du cercle d'enregistrement vers la bulle.
  ///
  /// Silencieuse en cas d'échec : une animation manquante n'est pas une
  /// raison de ne pas envoyer le message.
  void _lancerTransitionVocale() {
    _envoiVocal?.terminerMaintenant();
    final boite = _cleCercle.currentContext?.findRenderObject();
    if (boite is! RenderBox || !boite.hasSize || !boite.attached) return;
    final rect = boite.localToGlobal(Offset.zero) & boite.size;
    final etat = TransitionVocale.lancer(
      context: context,
      centreDepart: rect.center,
      // Le rayon qu'avait le cercle au moment du relâchement : le disque
      // part donc exactement de la taille qu'on voyait, pas d'une taille
      // de repos qui ferait un saut à la première image.
      rayonDepart: rayonCercleMicro(_amplitudeCible),
      couleurDepart: OuroColors.accentRempli,
      // ⚠️ LA COULEUR D'ARRIVÉE N'EST PAS L'ACCENT. Sur une bulle
      // ENVOYÉE, le bouton de lecture est un blanc à 22 % posé sur le
      // fond de bulle — pas un disque d'accent. Faire arriver le disque
      // en accent créerait un saut de couleur à l'instant précis où il se
      // pose, c'est-à-dire là où l'œil regarde.
      //
      // On compose les deux ici plutôt que de transporter une couleur
      // translucide : un blanc à 22 % qui voyage au-dessus de la
      // conversation serait presque invisible en vol.
      couleurArrivee: Color.alphaBlend(
        Colors.white.withValues(alpha: 0.22),
        OuroColors.bubbleOutgoing,
      ),
      surFin: () {
        if (mounted) setState(() => _envoiVocal = null);
      },
    );
    if (etat == null) return;
    setState(() => _envoiVocal = etat);
  }

  /// Annule un enregistrement en cours (glissement vers l'annulation) : on
  /// arrête le recorder et on supprime le fichier temporaire, sans envoyer
  /// de message — pattern « glisser pour annuler » façon WhatsApp/Telegram.
  Future<void> _cancelRecording() async {
    final pending = _pendingStart;
    if (pending != null) await pending;
    if (!_recording) return;
    _ampTimer?.cancel();
    _ampTimer = null;
    setState(() {
      _recording = false;
      _recordingLocked = false;
      _amplitudes.clear();
    // Le cercle repart du repos : sans ça, un nouvel enregistrement
    // démarrerait au volume du précédent.
    _amplitudeCible = 0;
      _fullEnvelope.clear();
    });
    _recordStartedAt = null;
    HapticFeedback.mediumImpact();
    try {
      final path = await _recorder.stop();
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
    } catch (e) {
      debugPrint('[Chat] annulation enregistrement: $e');
    }
  }

  static const Map<String, String> _mimeByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/m4a',
    'wav': 'audio/wav',
    'aac': 'audio/aac',
    'pdf': 'application/pdf',
    // ⚠️ LES VIDÉOS MANQUAIENT. Une vidéo choisie par « Joindre un fichier »
    // partait en `application/octet-stream` : le chat affichait alors une
    // carte « fichier .mp4 » au lieu du lecteur (`_VideoBubble`), qui
    // existait pourtant déjà. Seul l'envoi depuis la galerie posait le bon
    // type.
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'mov': 'video/quicktime',
    '3gp': 'video/3gpp',
    'webm': 'video/webm',
    'mkv': 'video/x-matroska',
  };

  String _guessMimeType(String fileName) {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    return _mimeByExtension[ext] ?? 'application/octet-stream';
  }

  /// Au-delà, le crash observé sur appareil (OutOfMemoryError, tas ~256 Mo)
  /// devient probable : le fichier est lu en mémoire côté Dart puis
  /// ré-encodé tel quel dans les paquets mesh, sans transfert en flux.
  static const int _maxFileSizeBytes = 50 * 1024 * 1024;

  /// Ouvre le sélecteur de fichiers du téléphone (photos, documents...)
  /// et envoie le fichier choisi dans la conversation, en refusant les
  /// fichiers trop lourds (voir [_maxFileSizeBytes]).
  // ══════════════════════════════════════════════════════════════════
  //  SÉLECTION MULTIPLE — copier, transférer ou supprimer d'un coup
  // ══════════════════════════════════════════════════════════════════
  //
  // On entrait dans le menu d'un message pour le copier, on en sortait, on
  // recommençait pour le suivant : transmettre trois messages demandait six
  // gestes et une recopie à la main. Ici, un appui long ouvre la sélection,
  // chaque appui ajoute ou retire un message, et la barre du haut agit sur
  // tout le lot.

  final Set<String> _selection = {};

  // ── « N MESSAGES NON LUS » ────────────────────────────────────────────
  //
  // Rouvrir une conversation après une absence, c'était retomber tout en bas
  // sans savoir où l'on s'était arrêté. Une barre marque le premier message
  // arrivé depuis la dernière lecture. Elle reste en place tant que l'écran
  // est ouvert : les messages reçus pendant qu'on lit ne la déplacent pas.
  DateTime? _luJusquA;
  final DateTime _ouvertA = DateTime.now();
  int _nonLusCalculesPour = -1;
  String? _premierNonLuId;
  int _nombreNonLus = 0;

  (String?, int) _premierNonLu(List<MeshMessage> messages) {
    final lu = _luJusquA;
    if (_nonLusCalculesPour == messages.length) {
      return (_premierNonLuId, _nombreNonLus);
    }
    final moi = ref.read(meshRepositoryProvider).myId;
    // ⚠️ SANS REPÈRE DE LECTURE, ON SE FIE À `readAt`. Une conversation
    // jamais ouverte n'a pas encore de repère : la barre « N messages non
    // lus » n'apparaissait donc JAMAIS à la première ouverture — celle où
    // elle sert le plus, quand quelqu'un a écrit plusieurs messages d'un
    // coup.
    final nonLus = messages
        .where(
          (m) =>
              m.senderId != moi &&
              (lu != null ? m.timestamp.isAfter(lu) : m.readAt == null) &&
              !m.timestamp.isAfter(_ouvertA),
        )
        .toList();
    _nonLusCalculesPour = messages.length;
    _premierNonLuId = nonLus.isEmpty ? null : nonLus.first.id;
    _nombreNonLus = nonLus.length;
    return (_premierNonLuId, _nombreNonLus);
  }

  bool get _enSelection => _selection.isNotEmpty;

  List<MeshMessage> _messagesSelectionnes(List<MeshMessage> messages) =>
      messages.where((m) => _selection.contains(m.id)).toList();

  void _basculerSelection(MeshMessage m) {
    OuroHaptics.selection();
    setState(() {
      if (!_selection.remove(m.id)) _selection.add(m.id);
    });
  }

  void _quitterSelection() => setState(_selection.clear);

  /// La bulle, prête à être choisie quand la sélection est ouverte.
  Widget _enrobageSelection(MeshMessage m, Widget bulle) {
    if (!_enSelection) return bulle;
    final choisi = _selection.contains(m.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _basculerSelection(m),
      child: ColoredBox(
        color: choisi
            ? OuroColors.accent.withValues(alpha: 0.16)
            : Colors.transparent,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 6),
              child: Icon(
                choisi ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 22,
                color: choisi ? OuroColors.accent : OuroColors.tertiaryLabel,
              ),
            ),
            // ⚠️ `IgnorePointer` : pendant la sélection, toucher une photo ne
            // doit pas l'ouvrir en grand, ni un vocal se mettre à jouer.
            Expanded(child: IgnorePointer(child: bulle)),
          ],
        ),
      ),
    );
  }

  Future<void> _copierSelection(List<MeshMessage> messages) async {
    final choisis = _messagesSelectionnes(messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final texte = choisis
        .map((m) => m.content)
        .where((c) => c.trim().isNotEmpty)
        .join('\n');
    if (texte.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: texte));
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(AppLocalizations.of(context).chMessageCopied);
      }
    }
    _quitterSelection();
  }

  void _supprimerSelection(List<MeshMessage> messages) {
    final choisis = _messagesSelectionnes(messages);
    _quitterSelection();
    // Après la fermeture de la sélection : la photo des bulles ne doit pas
    // porter les cases à cocher.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_supprimerAvecEffet(choisis));
    });
  }

  Future<void> _transfererSelection(List<MeshMessage> messages) async {
    final choisis = _messagesSelectionnes(
      messages,
    ).where(transferable).toList();
    if (choisis.isEmpty) return;
    final cibles = await choisirCiblesTransfert(
      context,
      nombre: choisis.length,
    );
    if (cibles == null || cibles.vide || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final moi = StorageService.currentUser?.pseudo ?? 'Moi';
    _quitterSelection();
    await ref
        .read(meshMessagesProvider.notifier)
        .transfererMessages(
          pseudo: moi,
          messages: choisis,
          contacts: cibles.contacts,
          groupes: cibles.groupes,
        );
    if (mounted) ref.read(toastProvider.notifier).show(l10n.chForwarded1);
  }

  /// La barre du haut pendant la sélection.
  PreferredSizeWidget _barreSelection(
    AppLocalizations l10n,
    List<MeshMessage> messages,
  ) {
    final choisis = _messagesSelectionnes(messages);
    final transferables = choisis.where(transferable).isNotEmpty;
    return AppBar(
      flexibleSpace: const OuroBlurSurface(
        material: OuroMaterial.ultraThin,
        child: SizedBox.expand(),
      ),
      leading: OuroIconButton(
        tooltip: l10n.actionClose,
        icon: Icon(Icons.close_rounded, color: OuroColors.accent),
        onPressed: _quitterSelection,
      ),
      title: Text(
        l10n.chSelectedCount(_selection.length),
        style: OuroTypography.headline.copyWith(color: OuroColors.label),
      ),
      actions: [
        OuroIconButton(
          tooltip: l10n.chCopy,
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => _copierSelection(messages),
        ),
        if (transferables)
          OuroIconButton(
            tooltip: l10n.chForward,
            icon: const Icon(Icons.shortcut_rounded),
            onPressed: () => _transfererSelection(messages),
          ),
        OuroIconButton(
          tooltip: l10n.actionDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _supprimerSelection(messages),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Ouvre la photo touchée dans la galerie de la conversation : toutes ses
  /// photos, dans l'ordre, qu'on fait défiler du doigt.
  Future<void> _ouvrirGalerie(
    MeshMessage message,
    String chemin,
    Size? forme,
    List<MeshMessage> messages,
  ) async {
    final moi = ref.read(meshRepositoryProvider).myId;
    final entrees = <PhotoGalerie>[];
    var index = 0;
    for (final m in messages) {
      if (m.type != 'file' ||
          mediaKindOf(m.fileMimeType, m.fileName) != MediaKind.image) {
        continue;
      }
      final courante = m.id == message.id;
      final p = courante
          ? chemin
          : await StorageService.getSharedFilePath(
              m.fileId ?? '',
              m.fileName ?? '',
            );
      if (p == null) continue;
      if (courante) index = entrees.length;
      entrees.add(
        PhotoGalerie(
          chemin: p,
          heroTag: 'photo-${m.id}',
          forme: courante
              ? forme
              : DimensionsMedias.connue('${m.fileId}-${m.fileName}'),
          titre: m.senderId == moi ? null : m.authorPseudo,
        ),
      );
    }
    if (!mounted || entrees.isEmpty) return;
    await ouvrirGaleriePhotos(context, photos: entrees, index: index);
  }

  /// Prépare une vidéo avec sa bulle déjà dans la conversation : l'anneau
  /// suit le réencodage, la croix l'annule. `null` si c'est annulé.
  Future<({String id, String chemin})?> _preparerVideo(
    String chemin,
    String nom,
  ) async {
    final notifier = ref.read(meshMessagesProvider.notifier);
    int taille = 0;
    try {
      taille = await File(chemin).length();
    } catch (_) {}
    final id = notifier.ajouterBullePreparation(
      pseudo: StorageService.currentUser?.pseudo ?? 'Moi',
      fileName: nom,
      mimeType: 'video/mp4',
      targetId: _isGroup ? null : _targetId,
      groupId: widget.groupId,
      taille: taille,
    );
    _scrollToBottom();
    final suivi = MediaService.progressionVideo.listen(
      (p) => notifier.mettreAJourPreparation(id, p),
    );
    try {
      final pret = await MediaService.compresserVideo(chemin);
      if (notifier.envoiAnnule(id)) return null;
      return (id: id, chemin: pret);
    } finally {
      await suivi.cancel();
    }
  }

  /// Prépare une photo (réduite à 1600 px) ou une vidéo (720p) avant l'envoi,
  /// comme WhatsApp — voir `MediaService`. Une vidéo peut prendre quelques
  /// secondes : on le dit plutôt que de laisser croire que rien ne se passe.
  Future<String> _preparerMedia(String chemin, {required bool video}) async {
    if (!video) return MediaService.compresserImage(chemin);
    final l10n = AppLocalizations.of(context);
    final annonce = Timer(const Duration(milliseconds: 700), () {
      if (mounted) ref.read(toastProvider.notifier).show(l10n.chPreparingVideo);
    });
    try {
      return await MediaService.compresserVideo(chemin);
    } finally {
      annonce.cancel();
    }
  }

  /// Le nom d'un fichier préparé : même nom, extension du nouveau format.
  static String _nomApresPreparation(
    String nom,
    String prepare,
    String original,
  ) {
    if (prepare == original || !prepare.contains('.')) return nom;
    final extension = prepare.substring(prepare.lastIndexOf('.'));
    final base = nom.contains('.')
        ? nom.substring(0, nom.lastIndexOf('.'))
        : nom;
    return '$base$extension';
  }

  Future<void> _pickAndSendFile({FileType filtre = FileType.any}) async {
    final l10n = AppLocalizations.of(context);
    try {
      // `withData: true` faisait lire le fichier ENTIER par le plugin natif
      // puis le repasser tel quel dans l'enveloppe du method channel Flutter
      // (StandardMessageCodec) — deux copies en mémoire du fichier complet,
      // ce qui provoquait un OutOfMemoryError natif (crash immédiat, tas
      // ~256 Mo) sur les fichiers volumineux. Ne récupérer que le chemin et
      // lire les octets nous-mêmes (comme pour la voix, cf. _stopRecording)
      // évite ce second passage par le method channel.
      final result = await FilePicker.platform.pickFiles(type: filtre);
      final picked = result?.files.single;
      if (picked == null || picked.path == null || !mounted) return;
      // Photo ou vidéo : préparée d'abord (réduite, réencodée) — la limite de
      // taille s'applique au fichier qui partira vraiment.
      final genre = mediaKindOf(_guessMimeType(picked.name), picked.name);
      final media = genre == MediaKind.image || genre == MediaKind.video;
      ApercuEnvoi? apercu;
      if (media) {
        apercu = await ouvrirApercuEnvoi(
          context,
          chemin: picked.path!,
          video: genre == MediaKind.video,
          vueUniquePossible: true,
        );
        if (apercu == null || !mounted) return;
      }
      String? idPrepare;
      var chemin = picked.path!;
      if (media && genre == MediaKind.video) {
        final preparation = await _preparerVideo(apercu!.chemin, picked.name);
        if (preparation == null) return;
        idPrepare = preparation.id;
        chemin = preparation.chemin;
      } else if (media) {
        chemin = await _preparerMedia(apercu!.chemin, video: false);
      }
      if (!mounted) return;
      if (await File(chemin).length() > _maxFileSizeBytes) {
        if (idPrepare != null) {
          ref.read(meshMessagesProvider.notifier).annulerEnvoi(idPrepare);
        }
        ref
            .read(toastProvider.notifier)
            .show(l10n.chFileTooLarge, type: DropletToastType.error);
        return;
      }
      final bytes = await File(chemin).readAsBytes();
      final prepare = chemin != picked.path;
      final me = StorageService.currentUser;
      await ref
          .read(meshMessagesProvider.notifier)
          .sendFile(
            pseudo: me?.pseudo ?? 'Moi',
            fileName: _nomApresPreparation(picked.name, chemin, picked.path!),
            bytes: bytes,
            mimeType: !prepare
                ? _guessMimeType(picked.name)
                : (genre == MediaKind.video ? 'video/mp4' : 'image/jpeg'),
            legende: apercu?.legende,
            idPrepare: idPrepare,
            targetId: _targetId,
            groupId: widget.groupId,
          );
      _scrollToBottom();
    } catch (e) {
      debugPrint('[Chat] sélection de fichier: $e');
      ref
          .read(toastProvider.notifier)
          .show(l10n.chFileSendFailed, type: DropletToastType.error);
    }
  }

  /// Démarre ou arrête la lecture d'un message vocal reçu — un simple
  /// bouton « play/pause », avec une petite barre de progression qui
  /// avance pendant la lecture.
  Future<void> _toggleAudio(String fileId, String fileName) async {
    final path = await StorageService.getSharedFilePath(fileId, fileName);
    if (path == null) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(
            AppLocalizations.of(context).chAudioNotFullyReceived,
            type: DropletToastType.warning,
          );
      return;
    }
    if (_playingAudio && _activeAudioFile == fileId) {
      await _stopPlayback();
      return;
    }
    await _playAudioFile(fileId, path);
  }

  /// Lance la lecture d'un fichier audio déjà présent sur l'appareil.
  Future<void> _playAudioFile(String fileId, String path) async {
    _player ??= AudioPlayer();
    await _player!.stop();

    // ⚠️ Ces trois abonnements DOIVENT être annulés avant d'en créer de
    // nouveaux. `listen` ajoute un auditeur de plus à chaque lecture sans
    // jamais retirer le précédent : au bout de dix messages vocaux
    // écoutés, dix rappels se déclenchaient à chaque battement du
    // lecteur. L'oubli portait surtout sur `onPlayerComplete`, qui
    // n'était même pas stocké dans une variable.
    await _posSub?.cancel();
    await _durSub?.cancel();
    await _completeSub?.cancel();

    _activeAudioFile = fileId;
    _activeAudioDuration = null;
    setState(() {
      _playingAudio = true;
      _playbackProgress = 0;
      _playbackPosition = Duration.zero;
      _playedVoiceNotes.add(fileId);
    });

    _durSub = _player!.onDurationChanged.listen((d) {
      _activeAudioDuration = d;
    });
    _posSub = _player!.onPositionChanged.listen((pos) {
      final total = _activeAudioDuration;
      if (!mounted || total == null || total.inMilliseconds == 0) return;
      setState(() {
        _playbackPosition = pos;
        _playbackProgress = (pos.inMilliseconds / total.inMilliseconds).clamp(
          0.0,
          1.0,
        );
      });
    });
    _completeSub = _player!.onPlayerComplete.listen((_) => _onPlaybackDone());

    try {
      await _player!.setPlaybackRate(_playbackSpeed);
      await _player!.play(DeviceFileSource(path));
    } catch (e) {
      // Fichier tronqué par un transfert interrompu, ou format que
      // l'appareil ne sait pas lire. On le dit, et on revient à l'état
      // d'arrêt — plutôt que de laisser l'exception faire tomber l'app.
      debugPrint('[Chat] lecture impossible: $e');
      await _stopPlayback();
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(
            AppLocalizations.of(context).chVoiceUnreadable,
            type: DropletToastType.error,
          );
    }
  }

  Future<void> _stopPlayback() async {
    await _player?.stop();
    await _posSub?.cancel();
    await _durSub?.cancel();
    await _completeSub?.cancel();
    _posSub = null;
    _durSub = null;
    _completeSub = null;
    if (!mounted) return;
    setState(() {
      _playingAudio = false;
      _activeAudioFile = null;
      _playbackProgress = 0;
      _playbackPosition = null;
    });
  }

  /// Un vocal vient de se terminer : on enchaîne sur le suivant s'il y
  /// en a un juste après, non encore écouté.
  ///
  /// C'est le comportement de WhatsApp, et il change tout quand on
  /// reçoit plusieurs vocaux d'affilée : sans lui, il faut rappuyer sur
  /// chaque bulle, ce qui casse l'écoute exactement comme si on coupait
  /// la parole à quelqu'un.
  Future<void> _onPlaybackDone() async {
    final finished = _activeAudioFile;
    await _stopPlayback();
    if (finished == null || !mounted) return;

    final messages = _isGroup
        ? ref.read(groupMessagesProvider(widget.groupId!))
        : ref.read(
            conversationMessagesProvider(_isBroadcast ? null : widget.peerId),
          );

    final index = messages.indexWhere((m) => m.fileId == finished);
    if (index < 0) return;

    for (var i = index + 1; i < messages.length; i++) {
      final m = messages[i];
      final isVoice =
          m.type == 'file' &&
          ((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.audio)) &&
          VoiceNoteMeta.isVoiceNote(m.fileName);
      if (!isVoice) continue;
      // On n'enchaîne que sur les vocaux REÇUS et jamais écoutés :
      // rejouer ses propres messages, ou des messages déjà entendus,
      // n'a aucun sens.
      if (m.senderId == ref.read(meshRepositoryProvider).myId) return;
      if (_playedVoiceNotes.contains(m.fileId)) return;
      final path = await StorageService.getSharedFilePath(
        m.fileId ?? '',
        m.fileName ?? '',
      );
      if (path == null || !mounted) return;
      await _playAudioFile(m.fileId!, path);
      return;
    }
  }

  /// Déplace la lecture à [progress] (0..1) — glisser le doigt sur la
  /// forme d'onde. Sans ça, réécouter un mot manqué au milieu d'un vocal
  /// d'une minute obligeait à tout reprendre depuis le début.
  Future<void> _seekAudio(double progress) async {
    final total = _activeAudioDuration;
    if (_player == null || total == null) return;
    final target = Duration(
      milliseconds: (total.inMilliseconds * progress.clamp(0.0, 1.0)).round(),
    );
    await _player!.seek(target);
    if (!mounted) return;
    setState(() {
      _playbackPosition = target;
      _playbackProgress = progress.clamp(0.0, 1.0);
    });
  }

  /// Fait tourner la vitesse de lecture 1× → 1,5× → 2× → 1×.
  Future<void> _cycleSpeed() async {
    final next = switch (_playbackSpeed) {
      1.0 => 1.5,
      1.5 => 2.0,
      _ => 1.0,
    };
    setState(() => _playbackSpeed = next);
    await _player?.setPlaybackRate(next);
  }

  /// Répondre par la voix à un message précis : on vise ce message, et
  /// l'enregistrement démarre immédiatement, verrouillé (mains libres).
  ///
  /// C'est le raccourci du petit micro posé à côté d'un vocal reçu :
  /// écouter puis répondre en parlant, sans repasser par le champ de
  /// texte ni viser le bouton micro tout en bas de l'écran.
  Future<void> _replyWithVoice(MeshMessage target) async {
    if (_recording) return;
    _repondreA(target);
    if (_playingAudio) await _stopPlayback();
    await _startRecording();
    if (mounted && _recording) setState(() => _recordingLocked = true);
  }

  /// Ouvre l'assistant local avec la fin de la conversation en contexte,
  /// pour aider à répondre à [cible]. Le champ de saisie de l'assistant
  /// est pré-rempli avec une invite que l'utilisateur peut ajuster.
  void _demanderAssistant(MeshMessage cible) {
    final peerId = widget.peerId;
    if (peerId == null) return;
    final l10n = AppLocalizations.of(context);
    final myId = ref.read(meshRepositoryProvider).myId;
    final pseudo = nomDuPair(peerId, [
      StorageService.getPeerRecord(peerId)?.pseudo,
    ]);

    final messages = ref.read(conversationMessagesProvider(peerId));
    // La fin de l'échange, jusqu'au message ciblé inclus — au plus 10
    // lignes, texte seulement, pour tenir dans le contexte du modèle.
    final avant =
        messages
            .where(
              (m) =>
                  m.type != 'file' &&
                  m.content.trim().isNotEmpty &&
                  m.timestamp.compareTo(cible.timestamp) <= 0,
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final derniers = avant.length > 10
        ? avant.sublist(avant.length - 10)
        : avant;
    // ⚠️ CE CONTEXTE ÉTAIT ÉCRIT EN FRANÇAIS EN DUR, et il DEMANDAIT une
    // réponse en français. Quelqu'un qui utilise Droplet en chinois
    // recevait donc une suggestion en français — dans une application
    // traduite en dix langues. L'instruction est maintenant écrite dans
    // la langue de la personne, et elle nomme cette langue explicitement :
    // un petit modèle suit bien mieux une consigne rédigée dans la langue
    // qu'on attend de lui qu'une consigne étrangère.
    final langue =
        kLanguageEndonyms[Localizations.localeOf(context).languageCode] ??
            l10n.localeName;
    final moi = l10n.chAiMe;
    final transcript = derniers
        .map(
          (m) => '${m.senderId == myId ? moi : pseudo} : ${m.content.trim()}',
        )
        .join('\n');

    final contexte = StringBuffer()
      ..writeln(l10n.chAiCtxIntro(pseudo))
      ..writeln()
      ..writeln(transcript)
      ..writeln()
      ..writeln(l10n.chAiCtxTask(pseudo, langue));

    context.push(
      '/ai-chat',
      extra: AiSeed(
        contexte: contexte.toString(),
        invite: l10n.chAskAssistantInvite(pseudo),
      ),
    );
  }

  /// Ouvre la vue de fil de discussion pour un message donné.
  /// Si le message a déjà un threadId, on filtre par celui-ci.
  /// Sinon, on crée un thread avec le messageId comme threadId.
  void _openThread(MeshMessage parent) {
    final threadId = parent.threadId ?? parent.id;
    final messages = ref.read(
      conversationMessagesProvider(_isGroup ? widget.groupId : _targetId),
    );
    final threadMessages =
        messages
            .where((m) => m.threadId == threadId || m.id == threadId)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ThreadSheet(
        parent: parent,
        threadId: threadId,
        messages: threadMessages,
        onReply: (text) {
          final me = StorageService.currentUser;
          if (_isGroup) {
            ref
                .read(meshMessagesProvider.notifier)
                .sendGroupMessage(
                  me?.pseudo ?? 'Moi',
                  text,
                  groupId: widget.groupId!,
                  replyToId: parent.id,
                  threadId: threadId,
                );
          } else {
            ref
                .read(meshMessagesProvider.notifier)
                .sendMessage(
                  me?.pseudo ?? 'Moi',
                  text,
                  targetId: _targetId,
                  replyToId: parent.id,
                  threadId: threadId,
                );
          }
        },
      ),
    );
  }

  /// Copie une pièce jointe reçue dans la galerie ou les
  /// téléchargements du téléphone.
  ///
  /// Les fichiers reçus par le mesh vivent dans le dossier PRIVÉ de
  /// Droplet : invisibles pour la galerie, et effacés si l'application
  /// est désinstallée. Les enregistrer, c'est les faire sortir de cet
  /// enclos pour de bon.
  Future<void> _saveToDevice(MeshMessage m) async {
    final l10n = AppLocalizations.of(context);
    final path = await StorageService.getSharedFilePath(
      m.fileId ?? '',
      m.fileName ?? '',
    );
    if (path == null) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(l10n.chFileNotFullyReceived, type: DropletToastType.warning);
      return;
    }

    final folder = await MediaService.saveToGallery(
      path: path,
      name: m.fileName ?? 'droplet',
      mimeType: m.fileMimeType ?? '',
    );

    if (!mounted) return;
    if (folder == null) {
      OuroHaptics.error();
      ref
          .read(toastProvider.notifier)
          .show(l10n.chSaveFailed, type: DropletToastType.error);
      return;
    }
    OuroHaptics.success();
    ref
        .read(toastProvider.notifier)
        .show(l10n.chSavedIn(folder), type: DropletToastType.success);
  }

  /// Ouvre le menu contextuel ancré sur le message.
  ///
  /// Voir `message_context_menu.dart` : le fond se floute, le message
  /// choisi reste net et se soulève, les émojis se déploient au-dessus
  /// et les actions apparaissent en dessous — au lieu d'une feuille
  /// anonyme qui monte du bas de l'écran.
  void _openMessageActions(MeshMessage m) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(meshMessagesProvider.notifier);
    final canSave =
        m.type == 'file' &&
        m.fileId != null &&
        !VoiceNoteMeta.isVoiceNote(m.fileName);
    final dejaEpingle =
        !_isBroadcast && Epingles.estEpingle(_cleConversation, m.id);
    final deMoi = m.senderId == ref.read(meshRepositoryProvider).myId;
    final texte = m.type != 'file';
    final traduisible = texte && m.content.trim().length > 1;
    final important = MessagesImportants.estImportant(m.id);
    final actionTraduire = MessageAction(
      icon: Icons.translate_rounded,
      label: _traductions.containsKey(m.id)
          ? l10n.msgShowOriginal
          : l10n.msgTranslate,
      onTap: () => _traductions.containsKey(m.id)
          ? _traduire(m)
          : _ouvrirTraduction(m),
    );

    unawaited(
      showMessageContextMenu(
        context: context,
        // La bulle réelle sert d'ancre : c'est elle qui donne au menu sa
        // position exacte à l'écran.
        anchorKey: _messageKeys.putIfAbsent(m.id, GlobalKey.new),
        preview: _previewOf(m),
        mine: m.senderId == ref.read(meshRepositoryProvider).myId,
        current: m.reactions,
        onReact: (emoji) {
          HapticFeedback.mediumImpact();
          notifier.toggleReaction(m.id, emoji);
          // Effet de particules ancré sur la bulle.
          final origin = _centreDeLaBulle(m.id);
          if (origin != null) {
            ReactionEffectOverlay.show(context, emoji: emoji, origin: origin);
          }
        },
        // ── LE MENU D'iOS : COURT, PAR FAMILLES ──────────────────────
        //
        // ⚠️ ONZE LIGNES, C'ÉTAIT UN MENU QU'ON LISAIT. Il dépassait la
        // hauteur de l'écran sur un petit téléphone, et l'action cherchée
        // se perdait au milieu des autres. WhatsApp et iMessage gardent
        // les gestes de tous les jours en haut — répondre, copier,
        // modifier, transférer —, rangent le reste derrière « Plus », et
        // isolent « Supprimer » en bas, séparé par une bande.
        actions: [
          // « Réessayer » passe en premier, et seulement si ça a échoué :
          // c'est la seule action qui compte à ce moment-là.
          if (m.status == MessageStatus.failed)
            MessageAction(
              icon: Icons.refresh_rounded,
              label: l10n.actionRetry,
              onTap: () {
                HapticFeedback.mediumImpact();
                notifier.renvoyer(m.id);
              },
            ),
          MessageAction(
            icon: Icons.reply_rounded,
            label: l10n.chReply,
            onTap: () => _repondreA(m),
          ),
          if (texte)
            MessageAction(
              icon: Icons.copy_rounded,
              label: l10n.chCopy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: m.content));
                ref
                    .read(toastProvider.notifier)
                    .show(l10n.chMessageCopied, type: DropletToastType.info);
              },
            ),
          // Sur MES messages, on modifie ; sur ceux des autres, on
          // traduit. Jamais les deux en haut.
          if (texte && deMoi)
            MessageAction(
              icon: Icons.edit_rounded,
              label: l10n.actionEdit,
              onTap: () => _editMessage(m),
            ),
          if (traduisible && !deMoi) actionTraduire,
          if (transferable(m))
            MessageAction(
              icon: Icons.shortcut_rounded,
              label: l10n.chForward,
              onTap: () {
                setState(() => _selection.add(m.id));
                unawaited(_transfererSelection(ref.read(meshMessagesProvider)));
              },
            ),
          // ── « Plus » : tout le reste, sur place ──
          MessageAction(
            icon: Icons.more_horiz_rounded,
            label: l10n.nvMore,
            nouvelleSection: true,
            sousActions: [
              // L'étoile : garder ce message sous la main. Rien n'est
              // envoyé, personne n'est prévenu.
              MessageAction(
                icon: important
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                label: important ? l10n.imRemove : l10n.imAdd,
                onTap: () {
                  OuroHaptics.light();
                  final pose = MessagesImportants.basculer(
                    MessageImportant(
                      id: m.id,
                      contenu: m.content,
                      type: m.type,
                      horodatage: m.timestamp.millisecondsSinceEpoch,
                      deMoi: deMoi,
                      auteur: m.authorPseudo,
                      peerId: widget.peerId,
                      groupId: widget.groupId,
                      nomFichier: m.fileName,
                    ),
                  );
                  afficherToast(context, pose ? l10n.imAdded : l10n.imRemoved);
                },
              ),
              // Épingler : pour tout le monde dans la conversation, comme
              // WhatsApp. Pas dans le canal de diffusion public.
              if (!_isBroadcast)
                MessageAction(
                  icon: dejaEpingle
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                  label: dejaEpingle ? l10n.chUnpin : l10n.chPin,
                  onTap: () => unawaited(
                    notifier.epingler(m.id, epingle: !dejaEpingle),
                  ),
                ),
              MessageAction(
                icon: Icons.forum_rounded,
                label: l10n.chReplyInThread,
                onTap: () => _openThread(m),
              ),
              if (traduisible && deMoi) actionTraduire,
              // « Demander à l'assistant » : sur un message texte REÇU,
              // dans une conversation individuelle.
              if (texte && !_isGroup && !_isBroadcast && !deMoi)
                MessageAction(
                  icon: Icons.auto_awesome_rounded,
                  label: l10n.chAskAssistant,
                  onTap: () => _demanderAssistant(m),
                ),
              // Infos : par où le message est passé, quand il a été lu.
              if (m.type != 'call')
                MessageAction(
                  icon: Icons.info_outline_rounded,
                  label: l10n.msgInfo,
                  onTap: () => unawaited(showTransmissionSheet(
                    context,
                    m,
                    mine: deMoi,
                  )),
                ),
              // L'enregistrement, seulement pour un vrai fichier (pas un
              // vocal, dont le nom encodé n'aurait aucun sens).
              if (canSave)
                MessageAction(
                  icon: Icons.download_rounded,
                  label: l10n.actionSave,
                  onTap: () => _saveToDevice(m),
                ),
              MessageAction(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.chSelect,
                onTap: () => _basculerSelection(m),
              ),
            ],
          ),
          MessageAction(
            icon: Icons.delete_outline_rounded,
            label: l10n.actionDelete,
            destructive: true,
            onTap: () => _supprimerAvecEffet([m]),
          ),
        ],
      ),
    );
  }

  // ══ MODIFIER UN MESSAGE, DANS LE CHAMP ════════════════════════════
  //
  // ⚠️ PLUS DE DIALOGUE. La modification s'ouvrait dans une boîte
  // centrée : un petit champ étroit, sans les émojis récents, sans la
  // mise en forme, et le message d'origine caché derrière le voile.
  // WhatsApp, iMessage et Telegram font tous la même chose : le texte
  // remonte DANS LA BARRE DE SAISIE, un bandeau « Modifier le message »
  // le surmonte, et la coche remplace la flèche. On corrige avec l'outil
  // qu'on a déjà dans les doigts.

  /// Le message en cours de modification, ou `null`.
  MeshMessage? _enEdition;

  /// Ce qu'on tapait avant d'ouvrir la modification — rendu au champ
  /// quand on valide ou qu'on abandonne. Sans lui, corriger une faute
  /// dans un ancien message effaçait la réponse qu'on était en train
  /// d'écrire.
  String? _brouillonAvantEdition;

  /// Le clavier suit-il le doigt (Android 11+, voir
  /// `clavier_interactif.dart`) ? Sinon, il se ferme d'un coup dès qu'on
  /// fait défiler.
  bool _clavierInteractif = false;

  /// Quel épinglé la barre du haut montre (voir `_BarreEpingles`).
  int _indexEpingle = 0;

  void _surEpingles() {
    if (!mounted) return;
    setState(() => _indexEpingle = 0);
  }

  /// Une ligne qui résume un message, pour la barre des épinglés et le
  /// bandeau de réponse : jamais l'encodage brut d'un sondage, d'une
  /// position ou d'un sticker.
  String _resumeMessage(AppLocalizations l10n, MeshMessage m) {
    if (m.type == 'file') return VoiceNoteMeta.describeAttachment(m.fileName);
    if (isStickerMessage(m.content)) return l10n.chStickerPreview;
    return LocationMessage.describe(PollMessage.describe(m.content));
  }

  /// Prépare une réponse. Une modification en cours est abandonnée : le
  /// champ ne peut pas servir aux deux à la fois.
  void _repondreA(MeshMessage m) {
    if (_enEdition != null) _annulerEdition();
    setState(() => _replyTarget = m);
  }

  void _editMessage(MeshMessage m) {
    setState(() {
      _brouillonAvantEdition ??= _inputCtrl.text;
      _enEdition = m;
      _replyTarget = null;
    });
    _inputCtrl.value = TextEditingValue(
      text: m.content,
      selection: TextSelection.collapsed(offset: m.content.length),
    );
    _champFocus.requestFocus();
  }

  void _annulerEdition() {
    final avant = _brouillonAvantEdition ?? '';
    setState(() {
      _enEdition = null;
      _brouillonAvantEdition = null;
    });
    _inputCtrl.value = TextEditingValue(
      text: avant,
      selection: TextSelection.collapsed(offset: avant.length),
    );
  }

  /// Valide la modification : le message change partout, le champ
  /// retrouve ce qu'on y tapait avant.
  void _validerEdition(String texte) {
    final m = _enEdition;
    if (m == null) return;
    if (texte != m.content) {
      ref.read(meshMessagesProvider.notifier).editMessage(m.id, texte);
    }
    HapticFeedback.lightImpact();
    _annulerEdition();
  }

  /// Ce qu'on écrit sous le nom quand le pair n'est pas joignable.
  ///
  /// ⚠️ « HORS LIGNE » EST UN CONTRESENS DANS DROPLET, et c'est pour ça
  /// que cette méthode existe.
  ///
  /// Dans une messagerie ordinaire, « hors ligne » veut dire « rien ne
  /// partira ». Ici, c'est faux : le message est chiffré, mis en file, et
  /// repartira dès que la personne repassera à portée — ou sera relayé
  /// par un appareil intermédiaire. Annoncer une panne là où il n'y a
  /// qu'une attente pousse l'utilisateur à renoncer à écrire.
  ///
  /// On dit donc DEPUIS QUAND on ne l'a pas vue, ce qui est une
  /// information utile, plutôt qu'un verdict qui n'est pas le bon.
  ///
  /// ⚠️ « JAMAIS RENCONTRÉ » NE DOIT PAS S'AFFICHER SOUS UNE
  /// CONVERSATION QUI EXISTE.
  ///
  /// La version précédente ne regardait que la fiche du pair. Or cette
  /// fiche peut manquer — un identifiant qui a changé entre deux
  /// sessions, une table nettoyée, une conversation ouverte depuis un
  /// message reçu par relais. On affichait alors « Jamais rencontré »
  /// juste en dessous d'un fil de messages échangés le matin même : une
  /// affirmation que l'écran lui-même contredisait, ce qui apprend à
  /// l'utilisateur à ne plus croire ce qui est écrit là.
  ///
  /// Un message REÇU est une preuve de rencontre plus solide que la
  /// fiche, puisqu'il ne peut pas exister sans que l'appareil d'en face
  /// ait été joignable. On s'en sert donc de repli, et « jamais
  /// rencontré » n'est plus dit que lorsque c'est vrai : ni fiche, ni
  /// le moindre message reçu.
  ///
  /// ⚠️ REÇU, ET PAS « ÉCHANGÉ ». Un message envoyé ne prouve rien : il
  /// part en file d'attente et peut y rester des heures sans que
  /// personne ne soit passé à portée.
  /// Ce qui s'écrit sous le nom, ET de quelle couleur — LES DEUX ENSEMBLE.
  ///
  /// ⚠️ C'ÉTAIENT DEUX FONCTIONS, ET ELLES SE CONTREDISAIENT.
  ///
  /// Le texte se calculait sur l'ANCIENNETÉ du dernier signe de vie, la
  /// couleur sur le TYPE DE ROUTE. Résultat visible à l'écran : « Par
  /// Internet il y a 3 j » écrit EN VERT. Or le vert ne veut dire qu'une
  /// chose, dans toutes les applications du monde : cette personne est là
  /// maintenant. Une date vieille de trois jours peinte en vert, c'est
  /// exactement ce qui fait qu'on cesse de croire un indicateur — et un
  /// indicateur qu'on ne croit plus vaut moins que pas d'indicateur.
  ///
  /// Les deux sont donc décidés au même endroit, à partir des mêmes
  /// données. Ils ne peuvent plus diverger.
  ///
  /// LA RÈGLE, EN TROIS ÉTATS :
  ///   • VERT — joignable MAINTENANT, et c'est prouvé : soit l'appareil
  ///     répond au maillage (il est physiquement à portée), soit un signe
  ///     de vie par Internet date de moins de cinq minutes.
  ///   • ORANGE — ça bouge : lien perdu qu'on rétablit, Internet qu'on
  ///     attend.
  ///   • GRIS — tout le reste, c'est-à-dire tout ce qui est au passé. Y
  ///     compris « joignable par Internet » sans signe de vie récent : la
  ///     route existe, mais rien ne dit que quelqu'un est au bout.
  static ({String texte, Color couleur}) _etatChemin(
    AppLocalizations l10n,
    CheminPair chemin,
    int sauts,
    PeerRecord? fiche,
    DateTime? dernierRecu,
    String? peerId,
  ) {
    // « En ligne » ne veut dire qu'une chose : ce téléphone a parlé par
    // Internet il y a moins de cinq minutes. Jamais « il est à portée ».
    final enLigne = peerId != null && PresenceInternet.enLigne(peerId);

    // ⚠️ LA COULEUR NE SE DÉCIDE PLUS ICI. `fraicheurPair` tranche pour
    // toute l'application (voir `etat_connexion.dart`) ; cet écran se
    // contente de la traduire en teinte. C'est ce qui garantit que
    // l'en-tête et l'accueil ne pourront plus peindre le même contact de
    // deux couleurs différentes.
    final couleur = switch (fraicheurPair(chemin, signeRecent: enLigne)) {
      FraicheurPair.maintenant => OuroColors.presenceMaintenant,
      FraicheurPair.enCours => OuroColors.presenceEnCours,
      FraicheurPair.passe => OuroColors.presencePassee,
    };

    final texte = switch (chemin) {
      CheminPair.procheEtInternet => l10n.chNearbyAndInternet,
      CheminPair.relaisEtInternet => l10n.chRelaysAndInternet(sauts),
      CheminPair.proche => l10n.chNearby,
      CheminPair.relais => l10n.chReachableViaRelays(sauts),
      // Un signe de vie récent se dit « en ligne » ; sinon on donne la
      // date, et `fraicheurPair` l'a déjà peinte en gris.
      CheminPair.internet => enLigne
          ? l10n.chOnlineNow
          : (_vuParInternet(l10n, peerId) ?? l10n.chViaInternet),
      CheminPair.tor => enLigne ? l10n.chOnlineNow : l10n.chViaTor,
      CheminPair.reconnexion => l10n.chReconnectingEllipsis,
      CheminPair.attenteInternet => l10n.chWaitingInternet,
      CheminPair.horsPortee => _vuParInternet(
            l10n,
            peerId,
            plusRecentQue: fiche?.lastSeen ?? dernierRecu,
          ) ??
          _sousTitreHorsLigne(l10n, fiche, dernierRecu),
    };

    return (texte: texte, couleur: couleur);
  }

  /// Le dernier signe de vie PAR INTERNET, quand il est plus parlant que le
  /// dernier croisement par le maillage. `null` s'il n'y en a pas, ou s'il
  /// est plus vieux que ce qu'on sait déjà.
  static String? _vuParInternet(
    AppLocalizations l10n,
    String? peerId, {
    DateTime? plusRecentQue,
  }) {
    if (peerId == null) return null;
    final quand = PresenceInternet.dernierSigne(peerId);
    if (quand == null) return null;
    if (plusRecentQue != null && quand.isBefore(plusRecentQue)) return null;
    final ecart = DateTime.now().difference(quand);
    if (ecart < PresenceInternet.fraicheur) return l10n.chOnlineNow;
    if (ecart.inMinutes < 60) return l10n.chInternetMinutesAgo(ecart.inMinutes);
    if (ecart.inHours < 24) return l10n.chInternetHoursAgo(ecart.inHours);
    if (ecart.inDays < 30) return l10n.chInternetDaysAgo(ecart.inDays);
    return null;
  }

  static String _sousTitreHorsLigne(
    AppLocalizations l10n,
    PeerRecord? fiche,
    DateTime? dernierRecu,
  ) {
    if (fiche == null && dernierRecu == null) return l10n.chNeverMet;
    final repere = fiche?.lastSeen ?? dernierRecu!;
    final ecart = DateTime.now().difference(repere);
    if (ecart.inMinutes < 1) return l10n.chSeenJustNow;
    if (ecart.inMinutes < 60) return l10n.chSeenMinutesAgo(ecart.inMinutes);
    if (ecart.inHours < 24) return l10n.chSeenHoursAgo(ecart.inHours);
    if (ecart.inDays == 1) return l10n.chSeenYesterday;
    if (ecart.inDays < 7) return l10n.chSeenDaysAgo(ecart.inDays);
    return l10n.chOutOfRange;
  }

  /// De quoi désigner un pair dont on n'a jamais appris le pseudonyme.
  ///
  /// Les huit premiers caractères de l'empreinte suffisent à distinguer
  /// deux contacts à l'œil, tiennent dans une barre de titre, et disent
  /// honnêtement qu'on ne connaît pas encore cette personne — là où
  /// l'empreinte entière ne disait rien du tout.
  // ⚠️ LA RÈGLE DE NOMMAGE VIT DANS `nom_pair.dart`, PAS ICI.
  //
  // Cet écran en portait sa propre copie. Le résolveur central en avait
  // une autre, légèrement différente — et c'est elle qui affichait des
  // empreintes brutes dans le journal d'appels pendant que la
  // conversation, elle, affichait proprement « Pair 3f7a1c92 ».
  //
  // Deux copies d'une même règle finissent toujours par diverger, et la
  // divergence se voit à l'écran : le même contact nommé de deux façons
  // selon l'endroit où on le regarde. Une application soignée ne fait
  // jamais ça.

  /// La copie de la bulle affichée dans le menu.
  ///
  /// ⚠️ ON NE DÉPLACE PAS L'ORIGINALE — elle vit dans la liste, qui
  /// continue d'exister derrière le flou. On en construit donc une
  /// seconde, posée exactement à sa place. L'illusion tient tant que les
  /// deux se ressemblent : mêmes réglages, mêmes couleurs, seuls les
  /// gestes et la lecture audio sont retirés (un menu n'est pas
  /// l'endroit où l'on démarre un vocal).
  Widget _previewOf(MeshMessage m) {
    final myId = ref.read(meshRepositoryProvider).myId;
    final isAudio =
        m.type == 'file' &&
        ((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.audio));
    final isImage =
        m.type == 'file' &&
        ((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.image));
    final isVideo =
        m.type == 'file' &&
        ((mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.video));

    return _MessageBubble(
      message: m,
      mine: m.senderId == myId,
      isBroadcast: _isBroadcast,
      isGroup: _isGroup,
      isAudio: isAudio,
      isImage: isImage,
      isVideo: isVideo,
      playingAudio: false,
      voicePlayed: _playedVoiceNotes.contains(m.fileId),
      onPlayAudio: () {},
      onLongPress: () {},
    );
  }

  /// Combien de messages étaient là au dernier passage : dès que le nombre
  /// change alors que l'écran est ouvert, la discussion redevient lue.
  int _messagesVus = 0;

  /// La clé de cette discussion : l'identifiant du groupe, du contact, ou
  /// « broadcast ».
  /// Dans ce groupe, seuls les administrateurs peuvent écrire, et je n'en
  /// suis pas un.
  bool get _paroleFermee {
    final id = widget.groupId;
    if (id == null) return false;
    if (!ReglagesGroupes.de(id).envoiAdminsSeuls) return false;
    return !(StorageService.getGroup(id)?.isAdmin(
          ref.read(meshRepositoryProvider).myId,
        ) ??
        false);
  }

  /// Personne n'est joignable pour l'instant dans cette discussion.
  bool get _horsDePortee {
    final id = widget.peerId;
    if (id == null || _isGroup || _isBroadcast) return false;
    if (ref.read(internetDisponibleProvider)) return false;
    for (final p in ref.read(meshPeerListProvider)) {
      if (p.peerId == id) return false;
    }
    return true;
  }

  /// Ouvrir un salon : on entre pour de bon — micro allumé, salle du serveur
  /// rejointe — et l'écran d'appel s'ouvre. Personne n'est réveillé par une
  /// sonnerie.
  Future<void> _ouvrirSalon() => _entrerDansSalon(ouvrir: true);

  Future<void> _rejoindreSalon() => _entrerDansSalon(ouvrir: false);

  /// Le nom de quelqu'un dont on n'a que l'identifiant — un arrivant dans
  /// le salon, par exemple.
  String _pseudoDe(String peerId) {
    for (final p in ref.read(meshPeerListProvider)) {
      if (p.peerId == peerId) return p.pseudo;
    }
    for (final p in StorageService.getKnownPeers()) {
      if (p.peerId == peerId) return p.pseudo;
    }
    return peerId;
  }

  /// ⚠️ ICI SE BRANCHE LE SON. Avant, ces deux boutons annonçaient le salon
  /// sur le maillage et ouvraient un écran d'appel VIDE : aucune voix ne
  /// passait, parce que personne ne rejoignait la salle du serveur. C'est
  /// `entrerDansSalon` qui allume le micro et noue les connexions.
  Future<void> _entrerDansSalon({required bool ouvrir}) async {
    final id = widget.groupId;
    if (id == null) return;
    final l10n = AppLocalizations.of(context);
    OuroHaptics.light();

    // Un salon vocal demande Internet, et on le dit AVANT d'ouvrir un
    // écran qui resterait muet.
    if (!ref.read(internetDisponibleProvider)) {
      ref.read(toastProvider.notifier).show(
            l10n.vrNeedsInternet,
            type: DropletToastType.warning,
          );
      return;
    }

    final notifier = ref.read(groupCallProvider.notifier);
    final entree = notifier.entrerDansSalon(
      groupId: id,
      groupName: StorageService.getGroup(id)?.name ?? l10n.vrTitle,
      pseudoFor: _pseudoDe,
      ouvrir: ouvrir,
    );
    // L'écran s'ouvre tout de suite, en « en attente » : rejoindre la salle
    // peut prendre quelques secondes sur un réseau lent, et un bouton qui
    // ne répond pas pendant ce temps donne l'impression d'être cassé.
    if (mounted) context.push('/group-call');
    try {
      await entree;
    } catch (_) {
      // Le salon complet, lui, se dit sur l'écran d'appel : le serveur ne
      // le fait savoir qu'une fois la connexion ouverte, bien après ce
      // `catch`. Ici, c'est que le serveur n'a pas répondu du tout.
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            l10n.vrUnreachable,
            type: DropletToastType.warning,
          );
    }
  }

  String get _cleConversation => _isGroup
      ? widget.groupId!
      : (_isBroadcast ? 'broadcast' : widget.peerId!);

  void _marquerLuMaintenant() {
    if (!mounted) return;
    ref.read(conversationReadsProvider.notifier).markRead(_cleConversation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // ⚠️ ON RETIENT LA VRAIE HAUTEUR DU CLAVIER, dès qu'elle se montre.
    // Le panneau de stickers doit faire EXACTEMENT la même : une valeur
    // fixe donnerait un bond au moment de la bascule, et c'est ce bond
    // qui fait qu'une application « ne fait pas iOS ». Le seuil de 80
    // écarte la barre de suggestions, qui pousse les encarts de quelques
    // dizaines de points sans que le clavier soit ouvert.
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    if (insets > 80 && (insets - _hauteurClavier).abs() > 1) {
      _hauteurClavier = insets;
    }

    final messages = _isGroup
        ? ref.watch(groupMessagesProvider(widget.groupId!))
        : ref.watch(
            conversationMessagesProvider(_isBroadcast ? null : widget.peerId),
          );
    // Les éphémères arrivés à terme partent d'ici, sans rien demander.
    final perimes = Ephemeres.perimes(messages);
    if (perimes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final notifier = ref.read(meshMessagesProvider.notifier);
        for (final id in perimes) {
          notifier.deleteMessage(id);
        }
      });
    }

    // Les épinglés présents dans la conversation, le plus récent d'abord.
    // Un épinglé dont le message n'est plus là (supprimé, éphémère) est
    // simplement ignoré : la barre ne pointe jamais vers un trou.
    final epingles = _isBroadcast
        ? const <MeshMessage>[]
        : [
            for (final id in Epingles.lire(_cleConversation))
              ...messages.where((m) => m.id == id).take(1),
          ];
    final hautEpingles = epingles.isEmpty ? 0.0 : _BarreEpingles.hauteur;
    final idsEpingles = {for (final e in epingles) e.id};

    // Un message arrivé pendant qu'on lit ne doit pas laisser une pastille
    // de non-lu en revenant à l'accueil.
    if (messages.length != _messagesVus) {
      _messagesVus = messages.length;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _marquerLuMaintenant(),
      );
    }
    final peers = ref.watch(meshPeerListProvider);
    final repo = ref.watch(meshRepositoryProvider);

    // Qui peut être mentionné ici : ceux qui ont déjà parlé dans le groupe.
    // La liste est déposée pour l'analyse du texte, qui surligne alors les
    // pseudos entiers, espaces compris.
    Mentions.pseudos = _isGroup || _isBroadcast
        ? <String>{
            for (final m in messages)
              if (m.senderId != repo.myId && m.authorPseudo.trim().isNotEmpty)
                m.authorPseudo,
          }.toList()
        : const [];
    final torConnected = ref.watch(torConnectedProvider);
    // Progression des fichiers en cours d'envoi/réception, et révision des
    // photos de profil : lues ICI, dans `build`, puis passées aux bulles —
    // un `ref.watch` n'a pas sa place dans un `itemBuilder` paresseux.
    final progressions = ref.watch(fileProgressProvider);
    ref.watch(peerAvatarRevisionProvider);
    final myId = repo.myId;
    final typingPeers = ref.watch(typingPeersProvider);
    // Les membres du groupe qui écrivent en ce moment, par leur nom.
    final ecriventGroupe = _isGroup
        ? [
            for (final id
                in ref.watch(groupTypingProvider)[widget.groupId] ??
                    const <String>{})
              StorageService.getPeerRecord(id)?.pseudo ?? '…',
          ]
        : const <String>[];
    final group = _isGroup
        ? ref.watch(groupInfoProvider(widget.groupId!))
        : null;

    // Le nom affiché en tête de la conversation.
    //
    // ⚠️ L'IDENTIFIANT BRUT N'EST PAS UN NOM. C'est une empreinte de clé
    // publique — soixante-quatre caractères hexadécimaux. L'afficher,
    // c'est titrer une conversation « baee7a1f92f5e7d51b92… », ce qui ne
    // dit rien à personne.
    //
    // La version précédente ne cherchait le pseudonyme que dans la liste
    // des pairs CONNECTÉS À CET INSTANT. Or dans une app mesh, l'état
    // normal d'un contact est d'être hors de portée : on ouvre une
    // conversation pour relire, pour écrire un message qui partira plus
    // tard. L'identifiant brut n'apparaissait donc pas dans un cas rare —
    // il apparaissait dès qu'on s'éloignait de quelques mètres.
    //
    // On interroge donc d'abord la table des pairs déjà rencontrés, qui
    // survit aux déconnexions, et on ne retombe sur un identifiant
    // abrégé qu'en dernier recours — pour un pair dont on n'a
    // effectivement jamais appris le nom.
    //
    // ⚠️ La fiche du pair est lue UNE SEULE FOIS pour toute l'image.
    // `getPeerRecord` n'est pas une simple lecture de champ : il
    // redécode en JSON la table entière des pairs connus. L'appeler deux
    // fois par `build()` — ce que faisait la version précédente —
    // revenait à analyser tout l'annuaire deux fois par image pendant
    // qu'on tape ou qu'on fait défiler.
    final peerRecord = (!_isBroadcast && !_isGroup)
        ? StorageService.getPeerRecord(widget.peerId!)
        : null;

    // Un contact rencontré par QR code Tor ou par l'annuaire n'apparaît
    // JAMAIS dans `peers` (la liste des appareils à portée BLE/Wi-Fi) :
    // ce n'est pas un pair « hors de portée », c'est un pair d'une autre
    // nature, qu'aucune proximité physique ne rapprochera jamais. Sans
    // cette distinction, l'en-tête lui appliquait le langage du mesh
    // local (« vu il y a... », « jamais rencontré ») — honnête pour un
    // voisin de BLE, trompeur pour quelqu'un qu'on n'a QUE croisé par QR
    // code, à qui l'on n'a jamais été physiquement proche.
    final isTorContact = isTorOnlyPeer(peerRecord);

    // ⚠️ SEUL UN MESSAGE REÇU PROUVE QU'ON A VU LE PAIR.
    //
    // La version précédente prenait `messages.last` — le dernier message
    // de la conversation, quel qu'en soit l'auteur. Conséquence : venir
    // d'écrire suffisait à afficher « Vu à l'instant », alors que le
    // pair n'avait rien fait du tout. On datait notre propre activité en
    // la présentant comme la sienne.
    //
    // Un message ENVOYÉ ne prouve rien : il part en file d'attente, et
    // peut y rester des heures. Un message REÇU, lui, ne peut pas
    // exister sans que l'appareil d'en face ait été joignable.
    //
    // On remonte donc la liste à l'envers jusqu'au premier message qui
    // ne vient pas de nous. C'est un parcours, mais borné en pratique :
    // dans une conversation vivante, il s'arrête au bout de quelques
    // éléments.
    DateTime? dernierRecu;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].senderId != myId) {
        dernierRecu = messages[i].timestamp;
        break;
      }
    }

    String peerPseudo = _isGroup
        ? (group?.name ?? l10n.chGroupFallback)
        : _isBroadcast
        ? l10n.chBroadcastMesh
        : nomDuPair(widget.peerId!, [peerRecord?.pseudo]);
    bool online = false;
    bool peerKeyKnown = false;
    // À quelle distance, en nombre d'appareils, se trouve ce pair.
    // 0 = liaison directe ; au-delà, on ne le joint qu'à travers d'autres.
    int sautsVersPair = 0;
    // Être « connecté » et être « appelable » sont deux choses
    // différentes : la voix ne passe qu'en liaison directe Wi-Fi, jamais
    // en Bluetooth (bien trop lent) ni à travers un relais. Le bouton
    // d'appel affichait pourtant l'état « connecté », et lancer l'appel
    // se soldait alors par un message d'erreur — autant le dire avant.
    bool callable = false;
    // Vrai quand le pair a perdu ses liens mais qu'on lui laisse encore
    // sa chance (voir `ConnectedPeer.reconnecting`). On ne l'annonce
    // SURTOUT PAS comme connecté : il est présent dans la liste, ce qui
    // permet aux messages d'attendre plutôt que d'échouer, mais rien ne
    // part pour l'instant. Afficher « Connecté » ici serait exactement
    // le genre de mensonge que cette application s'interdit ailleurs sur
    // les accusés de livraison.
    bool reconnecting = false;
    if (!_isBroadcast && !_isGroup) {
      for (final p in peers) {
        if (p.peerId == widget.peerId) {
          peerPseudo = p.pseudo;
          reconnecting = p.reconnecting;
          online = !p.reconnecting;
          sautsVersPair = p.hopCount;
          peerKeyKnown = p.publicKey != null;
          callable =
              p.hopCount == 0 &&
              (p.transports.contains(TransportKind.localWifi) ||
                  p.transports.contains(TransportKind.nativeP2P));
          break;
        }
      }
    }
    // ⚠️ UN CONTACT TOR NE PASSERA JAMAIS PAR LA BOUCLE CI-DESSUS —
    // IL N'EST PAS DANS `peers` (LE MESH LOCAL). Ce n'est pas pour
    // autant un « bouton mort » : `CallNotifier.startCall` sait déjà
    // basculer tout seul sur la signalisation Railway + WebRTC quand
    // `canCallPeer` renvoie faux (voir `mesh_provider.dart`). Ce fil
    // ne faisait qu'oublier de le laisser essayer.
    //
    // ⚠️ SANS CONDITION SUR TOR — ET C'ÉTAIT LE VERROU QUI BLOQUAIT TOUT.
    // La ligne exigeait `torConnected`. Or l'appel à distance ne touche
    // jamais Tor : `_startRemoteCall` ouvre un WebSocket DIRECT vers le
    // serveur de signalisation, et la salle d'appels entrants
    // (`_startInboxListener`) est rejointe dès l'`init`, sans Tor non plus.
    // Un bootstrap Tor raté grisait donc le bouton d'appel d'une
    // fonctionnalité qui n'en avait aucun besoin.
    if (isTorContact) callable = true;
    // Par où passe CETTE conversation : mesh, Internet, ou les deux — voir
    // `etat_connexion.dart`.
    final internet = ref.watch(internetDisponibleProvider);
    final chemin = cheminVersPair(
      dansMesh: online,
      sauts: sautsVersPair,
      reconnexion: reconnecting,
      internet: internet,
      contactEnLigneSeul: isTorContact,
      cleConnue:
          widget.peerId != null &&
          ref.read(meshRepositoryProvider).clePubliqueConnue(widget.peerId!),
      torActif: torConnected,
    );
    // ⚠️ UN APPEL PAR INTERNET NE DEMANDE QU'INTERNET. Le bouton restait gris
    // pour un contact rencontré en mesh puis joint à distance : seuls les
    // contacts « en ligne » et les voisins Wi-Fi étaient appelables, et
    // l'appel ne partait jamais.
    if (internet && !_isGroup && !_isBroadcast) callable = true;
    final peerVerified = peerRecord?.isVerifiedAndCurrent ?? false;
    final peerKeyChanged = peerRecord?.keyChangedSinceVerification ?? false;
    final groupMemberCount = group?.activeMembers.length ?? 0;

    final peerTyping =
        !_isBroadcast && !_isGroup && typingPeers.contains(widget.peerId);

    // Le fond propre à cette discussion l'emporte sur celui des réglages.
    final cleConversation = _isGroup
        ? widget.groupId!
        : (_isBroadcast ? 'broadcast' : widget.peerId!);
    final String fondGlobal = ref.watch(chatBackgroundProvider);
    final String currentBg =
        ref.watch(fondConversationProvider(cleConversation)) ?? fondGlobal;
    final motifsActifs = ref.watch(chatMotifsProvider);
    // Un fond premium n'est appliqué que si le pack est débloqué : un
    // abonnement expiré retombe sur le fond Droplet, pas sur un fond payant.
    final fondPremium = FondsPremium.trouver(currentBg);
    final premiumBg = fondPremium != null && ref.watch(packDebloqueProvider)
        ? fondPremium
        : null;

    final fondCouleurs = premiumBg != null
        ? null // Les fonds premium utilisent leur propre widget
        : fondPremium != null
        ? TelegramGradientPalettes.pour(
            'mesh',
            sombre: Theme.of(context).brightness == Brightness.dark,
          )
        : currentBg == 'adaptatif'
        ? TelegramGradientPalettes.pourContenu(
            _lastMessageType(messages, myId),
            sombre: Theme.of(context).brightness == Brightness.dark,
          )
        : TelegramGradientPalettes.pour(
            currentBg,
            sombre: Theme.of(context).brightness == Brightness.dark,
          );

    final items = _buildItems(context, messages);

    // Un annuaire des messages par identifiant, construit UNE fois par
    // image.
    //
    // ⚠️ C'est ce qui remplace un `messages.where(...)` qui était fait à
    // l'intérieur du constructeur de chaque bulle. Retrouver le message
    // cité coûtait donc un balayage de TOUTE la conversation, par bulle
    // citée et par image : dans un fil de mille messages où l'on se
    // répond souvent, cela faisait des dizaines de milliers de
    // comparaisons soixante fois par seconde — pendant le défilement,
    // c'est-à-dire au pire moment. Ici, une seule construction d'index,
    // puis des recherches instantanées.
    final parId = {for (final m in messages) m.id: m};
    _parIdCourant = parId;

    // Les clés de repérage des bulles ne concernent que les messages
    // encore présents. Sans ce nettoyage, supprimer des messages laissait
    // leurs `GlobalKey` dans l'annuaire pour le reste de la session — et
    // une `GlobalKey` n'est pas gratuite : Flutter en tient un registre
    // global. Le seuil évite de reparcourir l'annuaire à chaque image.
    if (_messageKeys.length > parId.length * 2 + 50) {
      _messageKeys.removeWhere((id, _) => !parId.containsKey(id));
      _clesCapture.removeWhere((id, _) => !parId.containsKey(id));
    }

    // Compte les messages non lus pendant qu'on est remonté dans
    // l'historique.
    _maybeCountUnread(messages, myId);

    // Conversation verrouillée — écran biométrique avant d'accéder au contenu.
    if (_isLocked) {
      final pseudo = _isGroup
          ? (group?.name ?? l10n.chGroupFallback)
          : peerPseudo;
      return ConversationLockScreen(
        pseudo: pseudo,
        onUnlocked: () => setState(() => _isLocked = false),
      );
    }

    // ⚠️ LE BOUTON RETOUR REFERME LE PANNEAU AVANT DE QUITTER.
    //
    // Sans ça, on ouvre les stickers, on appuie sur Retour par réflexe —
    // et c'est toute la conversation qui se ferme. Le panneau a pris la
    // place du clavier : il doit se refermer comme lui.
    return PopScope(
      canPop: !_stickersOuverts,
      onPopInvokedWithResult: (sorti, _) {
        if (sorti || !_stickersOuverts) return;
        setState(() => _stickersOuverts = false);
        _champFocus.requestFocus();
      },
      child: Scaffold(
      // Transparent : c'est le dégradé animé posé en fond du `Stack`
      // ci-dessous qui donne sa couleur à l'écran.
      backgroundColor: Colors.transparent,
      // ⚠️ INDISPENSABLE DEPUIS QUE LA BARRE DE TITRE EST TRANSLUCIDE.
      //
      // Sans cela, le corps de l'écran commence SOUS la barre : la zone
      // de la barre n'a alors rien derrière elle, et le flou ne floute
      // que du vide — d'où la bande grise sale observée à l'écran, où le
      // sous-titre devenait presque illisible.
      //
      // En étendant le corps derrière la barre, c'est le fond de
      // discussion qui passe dessous, et le flou a enfin quelque chose à
      // travailler. C'est aussi ce que fait iOS 26 : le fond d'écran
      // d'une conversation remonte jusqu'en haut.
      extendBodyBehindAppBar: true,
      appBar: _enSelection
          ? _barreSelection(l10n, messages)
          : AppBar(
              // Matériau flou sous la barre : le contenu de la conversation
              // défile DERRIÈRE elle et s'y estompe, au lieu de disparaître
              // sous un bandeau opaque. C'est ce détail qui donne aux barres
              // d'iOS leur impression de profondeur.
              // ── UNE BARRE QUI LAISSE PASSER LA CONVERSATION ─────────────
              //
              // Voile le plus léger disponible, et PLUS DE FILET DE SÉPARATION
              // en bas.
              //
              // C'est l'autre moitié du geste d'iOS 26 : la barre de titre
              // d'une conversation devient transparente, et le fond comme les
              // messages restent visibles en dessous. Le trait gris qui la
              // fermait la transformait en bandeau posé SUR l'écran ; sans
              // lui, elle appartient à l'écran.
              //
              // Le voile ne disparaît pas pour autant : c'est lui qui garantit
              // que le nom du contact reste lisible quand une photo sombre
              // passe dessous.
              flexibleSpace: const OuroBlurSurface(
                material: OuroMaterial.ultraThin,
                child: SizedBox.expand(),
              ),
              // ⚠️ AUCUN BOUTON RETOUR DANS UNE BULLE. Il n'y a rien
              // derrière : la bulle est une fenêtre posée sur une autre
              // application, et le toucher ne mènerait nulle part. Un
              // bouton qui ne fait rien est pire qu'un bouton absent.
              leadingWidth: widget.enBulle ? 12 : 40,
              leading: widget.enBulle
                  ? const SizedBox.shrink()
                  : _searching
                  ? OuroIconButton(
                      tooltip: l10n.chCloseSearchTooltip,
                      icon: Icon(Icons.close_rounded, color: OuroColors.accent),
                      onPressed: _closeSearch,
                    )
                  : const OuroBackButton(),
              titleSpacing: 0,
              centerTitle: false,
              title: _searching
                  ? _searchField(messages)
                  : GestureDetector(
                      // Taper l'en-tête ouvre la fiche du contact ou du groupe —
                      // convention universelle des messageries, et le seul endroit
                      // où l'on pense à chercher les médias partagés.
                      onTap: () {
                        // Depuis une bulle, la fiche du contact s'ouvrirait
                        // DANS la bulle, sans moyen d'en revenir.
                        if (widget.enBulle) return;
                        if (_isGroup) {
                          context.push('/group/${widget.groupId}/info');
                        } else if (!_isBroadcast) {
                          context.push('/chat/${widget.peerId}/info');
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          // Hero uniquement en 1:1 (seul cas où on peut naviguer vers un
                          // appel) — un tag basé sur peerId, jamais dupliqué ailleurs.
                          (_isGroup || _isBroadcast)
                              ? PeerAvatar(
                                  pseudo: peerPseudo,
                                  radius: 17,
                                  online: online,
                                  reconnecting: reconnecting,
                                )
                              : Hero(
                                  tag: 'avatar-${widget.peerId}',
                                  child: PeerAvatar(
                                    pseudo: peerPseudo,
                                    radius: 17,
                                    online: online,
                                    reconnecting: reconnecting,
                                    imagePath: AvatarService.cheminPair(
                                      widget.peerId,
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        peerPseudo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: OuroTypography.headline.copyWith(
                                          color: OuroColors.label,
                                        ),
                                      ),
                                    ),
                                    if (peerKeyKnown || _isGroup) ...[
                                      const SizedBox(width: 5),
                                      Icon(
                                        peerKeyChanged
                                            ? Icons.warning_amber_rounded
                                            : peerVerified
                                            ? Icons.verified_rounded
                                            : Icons.lock_rounded,
                                        size: 13,
                                        color: peerKeyChanged
                                            ? OuroColors.systemOrange
                                            : peerVerified
                                            ? OuroColors.systemGreen
                                            : OuroColors.tertiaryLabel,
                                      ),
                                    ],
                                    // Le petit bouclier Tor — même icône et même
                                    // logique de couleur que `tor_settings_screen`
                                    // (vert : tunnel ouvert ; gris : pas pour le
                                    // moment), pour que le transport de CETTE
                                    // conversation précise se voie d'un coup d'œil,
                                    // sans attendre de lire le sous-titre.
                                    if (isTorContact) ...[
                                      const SizedBox(width: 5),
                                      Semantics(
                                        label: l10n.chReachedViaTorSemantic,
                                        child: Icon(
                                          Icons.shield_rounded,
                                          size: 13,
                                          color: torConnected
                                              ? OuroColors.systemGreen
                                              : OuroColors.tertiaryLabel,
                                        ),
                                      ),
                                    ],
                                    // ⚠️ LES DEUX PASTILLES (ondes, globe)
                                    // NE SONT PLUS ICI. À 12 points et en
                                    // gris clair, ce n'étaient que deux
                                    // taches après le nom, que personne ne
                                    // savait lire. Le chemin est dit EN MOTS
                                    // dans la ligne du dessous, et la
                                    // toucher ouvre le détail du réseau.
                                  ],
                                ),
                                // Toucher la ligne d'état ouvre le panneau
                                // réseau. Le geste est délibérément DISCRET :
                                // aucune icône ne l'annonce, parce que la
                                // majorité des gens n'a rien à y chercher —
                                // mais il est là pour qui se demande « par où
                                // ça passe ? ».
                                _TapCible(
                                  marge: EdgeInsets.zero,
                                  onTap: () => showNetworkSheet(
                                    context,
                                    torContact: isTorContact,
                                    torConnected: torConnected,
                                    peerPseudo: peerPseudo,
                                  ),
                                  semantique: l10n.chNetworkDetailsSemantics,
                                  child: AnimatedSwitcher(
                                    duration: 200.ms,
                                    child: Text(
                                      _isGroup
                                          ? (ecriventGroupe.isNotEmpty
                                                ? l10n.chGroupTyping(
                                                    ecriventGroupe.join(', '),
                                                  )
                                                : l10n.chMemberCount(
                                                    groupMemberCount,
                                                  ))
                                          : peerTyping
                                          ? l10n.chTypingNow
                                          : _isBroadcast
                                          ? l10n.chBroadcastChannel
                                          : _etatChemin(
                                              l10n,
                                              chemin,
                                              sautsVersPair,
                                              peerRecord,
                                              dernierRecu,
                                              widget.peerId,
                                            ).texte,
                                      key: ValueKey(
                                        _isGroup
                                            ? (ecriventGroupe.isNotEmpty
                                                  ? 'group-typing'
                                                  : 'group')
                                            : peerTyping
                                            ? 'typing'
                                            : 'status',
                                      ),
                                      style: OuroTypography.caption1.copyWith(
                                        fontStyle:
                                            (peerTyping ||
                                                ecriventGroupe.isNotEmpty)
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                        color:
                                            (peerTyping ||
                                                ecriventGroupe.isNotEmpty)
                                            ? OuroColors.accent
                                            // La MÊME décision que le
                                            // texte juste au-dessus : les
                                            // deux ne peuvent plus se
                                            // contredire.
                                            : _etatChemin(
                                                l10n,
                                                chemin,
                                                sautsVersPair,
                                                peerRecord,
                                                dernierRecu,
                                                widget.peerId,
                                              ).couleur,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: _searching
                  ? _searchActions(messages)
                  : [
                      OuroIconButton(
                        tooltip: l10n.chSearchInConversation,
                        icon: Icon(
                          Icons.search_rounded,
                          color: OuroColors.accent,
                        ),
                        onPressed: _openSearch,
                      ),
                      // L'appel est l'action la plus utile depuis une conversation :
                      // elle reste seule dans la barre. Les infos et les médias sont
                      // atteignables en tapant l'en-tête, comme partout ailleurs.
                      // Appel vidéo : seulement quand l'appel est possible — pas de
                      // second bouton grisé qui encombrerait la barre.
                      // Dans un groupe, l'icône ouvre un SALON : ça ne
                      // sonne chez personne, chacun entre quand il peut.
                      // Sans Internet, le bouton le dit plutôt que
                      // d'échouer en silence.
                      if (_isGroup)
                        OuroIconButton(
                          tooltip: ref.watch(internetDisponibleProvider)
                              ? l10n.vrStart
                              : l10n.vrNeedsInternet,
                          icon: Icon(
                            Icons.graphic_eq_rounded,
                            color: ref.watch(internetDisponibleProvider)
                                ? OuroColors.accent
                                : OuroColors.quaternaryLabel,
                          ),
                          onPressed: ref.watch(internetDisponibleProvider)
                              ? () => unawaited(_ouvrirSalon())
                              : () => afficherToast(
                                    context,
                                    l10n.vrNeedsInternet,
                                    type: DropletToastType.warning,
                                  ),
                        ),
                      // ── CAMÉRA ET TÉLÉPHONE, TOUJOURS LÀ ─────────────
                      //
                      // La caméra disparaissait hors de portée : l'en-tête
                      // changeait de forme au gré du réseau. Les deux restent
                      // désormais à leur place, au trait comme dans Messages,
                      // et grisés quand l'appel est impossible — le toucher
                      // explique alors pourquoi (voir le téléphone).
                      if (!_isGroup && !_isBroadcast)
                        OuroIconButton(
                          tooltip: l10n.chVideoCall,
                          icon: Icon(
                            Icons.videocam_outlined,
                            size: 26,
                            color: callable
                                ? OuroColors.accent
                                : OuroColors.secondaryLabel,
                          ),
                          onPressed: callable
                              ? () {
                                  OuroHaptics.light();
                                  unawaited(_appelerSiPossible('/call/${widget.peerId}?video=1'));
                                }
                              : isTorContact
                              ? () {
                                  OuroHaptics.light();
                                  context.push('/tor');
                                }
                              : online
                              ? () => ref
                                    .read(toastProvider.notifier)
                                    .show(
                                      l10n.chCallImpossibleRelay,
                                      type: DropletToastType.warning,
                                    )
                              : () {
                                  OuroHaptics.light();
                                  ref.read(toastProvider.notifier).show(
                                        l10n.chCallUnreachable(peerPseudo),
                                        type: DropletToastType.info,
                                      );
                                },
                        ),
                      if (!_isGroup && !_isBroadcast)
                        OuroIconButton(
                          tooltip: callable
                              ? l10n.chVoiceCall
                              : isTorContact
                              ? l10n.chTorInactive
                              : online
                              ? l10n.chCallImpossibleBtRelay
                              : l10n.chOutOfRange,
                          icon: Icon(
                            Icons.phone_outlined,
                            size: 23,
                            // Grisé plutôt qu'absent : un bouton qui disparaît puis
                            // réapparaît au gré de la portée réseau ferait sauter
                            // toute la barre à chaque changement.
                            // ⚠️ GRIS LISIBLE, ET JAMAIS MORT. Il était en
                            // gris quaternaire (presque invisible) et ne
                            // réagissait pas au toucher hors de portée : on
                            // ne savait ni s'il était cassé, ni pourquoi.
                            color: callable
                                ? OuroColors.accent
                                : OuroColors.secondaryLabel,
                          ),
                          onPressed: callable
                              ? () {
                                  OuroHaptics.light();
                                  unawaited(_appelerSiPossible('/call/${widget.peerId}'));
                                }
                              : isTorContact
                              // Le seul obstacle est Tor éteint — un appui doit
                              // mener à l'endroit qui le résout, pas à une
                              // excuse.
                              ? () {
                                  OuroHaptics.light();
                                  context.push('/tor');
                                }
                              : online
                              // Joignable pour les messages mais pas pour la voix :
                              // on explique, au lieu de laisser un bouton mort.
                              ? () => ref
                                    .read(toastProvider.notifier)
                                    .show(
                                      l10n.chCallImpossibleRelay,
                                      type: DropletToastType.warning,
                                    )
                              // Personne en vue : on le dit, et on propose
                              // ce qui marche — un message, qui partira.
                              : () {
                                  OuroHaptics.light();
                                  ref.read(toastProvider.notifier).show(
                                        l10n.chCallUnreachable(peerPseudo),
                                        type: DropletToastType.info,
                                      );
                                },
                        ),
                      if (_isGroup)
                        OuroIconButton(
                          tooltip: l10n.chGroupInfoTooltip,
                          icon: Icon(
                            Icons.info_outline_rounded,
                            color: OuroColors.accent,
                          ),
                          onPressed: () =>
                              context.push('/group/${widget.groupId}/info'),
                        ),
                      const SizedBox(width: 4),
                    ],
            ),
      body: SuiviClavier(
        actif: _clavierInteractif,
        child: IosMagnifierOverlay(
        child: Stack(
          key: _clePile,
          children: [
            // ── Le fond en dégradé animé, façon Telegram ────────────────
            //
            // Posé en TOUT PREMIER, donc derrière la conversation. Il
            // avance d'un cran à chaque message envoyé (`_fondTick`).
            // La palette suit la luminosité effective : un dégradé sombre
            // derrière le mode clair rendrait le texte illisible. `null`
            // veut dire que l'utilisateur a choisi « Aucun » — on retombe
            // alors sur le fond uni habituel, sans rien calculer.
            if (premiumBg != null)
              Positioned.fill(
                child: FondPremiumAnime(fond: premiumBg, tick: _fondTick),
              )
            else if (fondCouleurs != null)
              Positioned.fill(
                child: TelegramGradientBackground(
                  tick: _fondTick,
                  couleurs: fondCouleurs,
                ),
              )
            else
              Positioned.fill(
                child: ColoredBox(color: OuroColors.systemBackground),
              ),
            // ── Les motifs Droplet, au trait, par-dessus le fond ────────
            //
            // Fixes pendant le défilement, comme un papier peint : c'est la
            // conversation qui glisse devant eux.
            if (motifsActifs)
              Positioned.fill(
                child: CalqueMotifsDroplet(
                  // Lu sur le réglage vivant : changer de motif dans
                  // Apparence redessine le fond sans quitter l'écran.
                  pack: PackMotifs.values[ref
                      .watch(personnalisationProvider)
                      .packMotifs
                      .clamp(0, PackMotifs.values.length - 1)],
                  couleur: MotifsDroplet.couleur(
                    sombre: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            // Le fond de la bulle qui arrive, DERRIÈRE la liste.
            if (_envoi != null)
              Positioned.fill(child: CoucheFondEnvoi(etat: _envoi)),
            Column(
              children: [
                Expanded(
                  // La clé sert à SendFlight : c'est dans ce rectangle
                  // qu'est calculée la place où la bulle envoyée se pose.
                  key: _zoneListeKey,
                  child: messages.isEmpty && !peerTyping
                      ? _EmptyChat(
                          isBroadcast: _isBroadcast,
                          peerPseudo: peerPseudo,
                        )
                      : Stack(
                          children: [
                            NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollUpdateNotification &&
                                    notification.metrics.pixels <= 0 &&
                                    !_loadingOlder &&
                                    !_isBroadcast) {
                                  setState(() => _loadingOlder = true);
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) {
                                        setState(() => _loadingOlder = false);
                                      }
                                    },
                                  );
                                }
                                return false;
                              },
                              // ── LE BAS DE LA LISTE S'EFFACE, SANS BANDEAU ──
                              //
                              // Un dégradé vers le blanc (ou le noir) posé
                              // par-dessus faisait une bande pleine sur le
                              // fond d'écran. Ici c'est le CONTENU qui devient
                              // transparent sur ses 14 derniers points : le
                              // fond reste visible, les bulles s'y dissolvent
                              // — le « scroll edge » d'iOS, et le fondu de
                              // 12 dp que Telegram applique au même endroit.
                              child: ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (rect) => LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: const [
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    0,
                                    rect.height <= 14
                                        ? 0
                                        : (rect.height - 14) / rect.height,
                                    1,
                                  ],
                                ).createShader(rect),
                                child: ListView.builder(
                                controller: _scrollCtrl,
                                // Quand le clavier suit le doigt, c'est le
                                // geste qui décide de le fermer — pas le
                                // premier millimètre de défilement.
                                keyboardDismissBehavior: _clavierInteractif
                                    ? ScrollViewKeyboardDismissBehavior.manual
                                    : ScrollViewKeyboardDismissBehavior.onDrag,
                                // Le contenu DÉMARRE sous la barre, mais DÉFILE
                                // dessous : c'est la marge haute qui réserve la
                                // place, pas un bandeau opaque. Les messages
                                // s'estompent donc derrière le verre au lieu de
                                // se faire couper net.
                                padding: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top:
                                      MediaQuery.paddingOf(context).top +
                                      kToolbarHeight +
                                      hautEpingles +
                                      8,
                                  // ⚠️ UNE MARGE EN BAS, PLUS GRANDE QUE LE
                                  // FONDU.
                                  //
                                  // Elle était à zéro « pour que le dernier
                                  // message touche le dégradé ». Résultat sur
                                  // un vrai téléphone : le DERNIER message —
                                  // celui qu'on vient de recevoir, le plus
                                  // important de l'écran — se dissolvait à
                                  // moitié dans les 14 points du fondu. Le
                                  // fondu doit effacer ce qui DÉFILE sous la
                                  // barre, jamais ce qui est arrivé en dernier.
                                  bottom: 22,
                                ),
                                itemCount:
                                    items.length + (peerTyping ? 1 : 0) + 1,
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    if (_loadingOlder) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.chLoadingOlderMessages,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: OuroColors.textTertiary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    // Le haut de la conversation : la
                                    // promesse de chiffrement, comme
                                    // WhatsApp — pas dans le canal public.
                                    return _isBroadcast
                                        ? const SizedBox.shrink()
                                        : const Padding(
                                            padding: EdgeInsets.fromLTRB(32, 10, 32, 14),
                                            child: _MentionChiffrement(),
                                          );
                                  }
                                  if (peerTyping && i == items.length + 1) {
                                    return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: TypingIndicator(),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 200.ms)
                                        .slideX(begin: -0.05);
                                  }
                                  final item = items[i - 1];
                                  if (item is _DaySeparator) {
                                    return _daySeparator(item.label);
                                  }
                                  if (item is _AvisGroupe) {
                                    return _avisGroupe(item.texte);
                                  }
                                  final m = item as MeshMessage;
                                  final mine = m.senderId == myId;

                                  // ── GROUPEMENT DES MESSAGES CONSÉCUTIFS ─────
                                  //
                                  // Voir `message_grouping.dart` : la règle y est
                                  // une fonction pure, et un test la verrouille.
                                  // Elle vivait ici, et elle y était fausse — un
                                  // décalage d'un cran faisait comparer chaque
                                  // message avec lui-même, si bien que le nom de
                                  // l'auteur n'apparaissait sur aucune bulle
                                  // d'aucune conversation de groupe.
                                  //
                                  // Le `decalage: 1` est l'en-tête d'historique
                                  // qui occupe la position 0 de la liste.
                                  // Un appel manqué : sa propre bulle, avec
                                  // « Rappeler ».
                                  if (m.type == 'appel') {
                                    return _buildMessageEntry(
                                      m,
                                      _BulleAppel(
                                        message: m,
                                        onRappeler: (video) {
                                          OuroHaptics.light();
                                          context.go(
                                            '/call/${widget.peerId}${video ? '?video=1' : ''}',
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  final groupage = groupageBulle(
                                    items,
                                    i,
                                    decalage: 1,
                                  );
                                  final suite = groupage.suiteDuPrecedent;
                                  final finDeSerie = groupage.finDeSerie;
                                  final replied = m.replyToId == null
                                      ? null
                                      : parId[m.replyToId];
                                  final isAudio =
                                      m.type == 'file' &&
                                      ((mediaKindOf(
                                            m.fileMimeType,
                                            m.fileName,
                                          ) ==
                                          MediaKind.audio));
                                  final isActive =
                                      _playingAudio &&
                                      _activeAudioFile == m.fileId;
                                  final bubble = _MessageBubble(
                                    key: ValueKey(m.id),
                                    message: m,
                                    epingle: idsEpingles.contains(m.id),
                                    progression: progressions[m.fileId ?? m.id]
                                        ?.progression,
                                    mine: mine,
                                    suiteDuPrecedent: suite,
                                    finDeSerie: finDeSerie,
                                    isBroadcast: _isBroadcast,
                                    isGroup: _isGroup,
                                    isAudio: isAudio,
                                    isImage:
                                        m.type == 'file' &&
                                        ((mediaKindOf(
                                              m.fileMimeType,
                                              m.fileName,
                                            ) ==
                                            MediaKind.image)),
                                    isVideo:
                                        m.type == 'file' &&
                                        ((mediaKindOf(
                                              m.fileMimeType,
                                              m.fileName,
                                            ) ==
                                            MediaKind.video)),
                                    playingAudio: isActive,
                                    playbackProgress: isActive
                                        ? _playbackProgress
                                        : 0,
                                    playbackPosition: isActive
                                        ? _playbackPosition
                                        : null,
                                    playbackSpeed: _playbackSpeed,
                                    traduction: _traductions[m.id],
                                    traductionEnCours:
                                        _traductionsEnCours.contains(m.id),
                                    transcription: _transcriptions[m.id],
                                    transcriptionEnCours:
                                        _transcriptionsEnCours.contains(m.id),
                                    onTranscrire: _moteurVocal && isAudio
                                        ? () => _transcrire(m)
                                        : null,
                                    // ⚠️ SEULEMENT LE DERNIER, ET SEULEMENT
                                    // S'IL EST DE MOI. La cible du disque
                                    // est unique : la donner à plusieurs
                                    // bulles ferait que la dernière
                                    // construite gagne, au hasard de
                                    // l'ordre de rendu.
                                    transitionVocale:
                                        isAudio &&
                                            mine &&
                                            i == items.length - 1
                                        ? _envoiVocal
                                        : null,
                                    voicePlayed: _playedVoiceNotes.contains(
                                      m.fileId,
                                    ),
                                    repliedMessage: replied,
                                    query: _query,
                                    scrollVelocity: _scrollVelocity,
                                    onOpenReplied: replied == null
                                        ? null
                                        : () => _jumpToMessage(
                                            replied.id,
                                            messages,
                                          ),
                                    onPlayAudio: () => _toggleAudio(
                                      m.fileId ?? '',
                                      m.fileName ?? '',
                                    ),
                                    onSeekAudio: isActive ? _seekAudio : null,
                                    onCycleSpeed: _cycleSpeed,
                                    // Le micro de réponse rapide n'a de sens que
                                    // sur un vocal REÇU : répondre à sa propre
                                    // voix ne veut rien dire.
                                    onVoiceReply:
                                        (!mine &&
                                            isAudio &&
                                            VoiceNoteMeta.isVoiceNote(
                                              m.fileName,
                                            ))
                                        ? () => _replyWithVoice(m)
                                        : null,
                                    onOpenLocation: () {
                                      OuroHaptics.selection();
                                      context.push('/map');
                                    },
                                    onLongPress: () => _enSelection
                                        ? _basculerSelection(m)
                                        : _openMessageActions(m),
                                    onOuvrirPhoto: (chemin, forme) =>
                                        _ouvrirGalerie(
                                          m,
                                          chemin,
                                          forme,
                                          messages,
                                        ),
                                    onAnnulerEnvoi:
                                        mine &&
                                            progressions[m.fileId ?? m.id] !=
                                                null
                                        ? () => ref
                                              .read(
                                                meshMessagesProvider.notifier,
                                              )
                                              .annulerEnvoi(m.id)
                                        : null,
                                    // Fil de discussion : compter les réponses.
                                    threadCount: messages
                                        .where((o) => o.replyToId == m.id)
                                        .length,
                                    onOpenThread: () => _openThread(m),
                                    // Seulement quand il y a quelque chose à
                                    // renvoyer : ailleurs, `null` retire la
                                    // cible et l'heure retrouve son rôle
                                    // habituel.
                                    onRenvoyer: m.status == MessageStatus.failed
                                        ? () {
                                            HapticFeedback.mediumImpact();
                                            ref
                                                .read(
                                                  meshMessagesProvider.notifier,
                                                )
                                                .renvoyer(m.id);
                                          }
                                        : null,
                                    onDoubleTap: () {
                                      HapticFeedback.mediumImpact();
                                      ref
                                          .read(meshMessagesProvider.notifier)
                                          .toggleReaction(m.id, '❤️');
                                      // Effet de particules ancé sur la bulle.
                                      final origin = _centreDeLaBulle(m.id);
                                      if (origin != null) {
                                        ReactionEffectOverlay.show(
                                          context,
                                          emoji: '❤️',
                                          origin: origin,
                                        );
                                      }
                                    },
                                  );
                                  // ── LA BULLE QUI ARRIVE ─────────────────
                                  //
                                  // Pendant la transition d'envoi, la vraie
                                  // bulle est pilotée par `EntreeEnvoi` :
                                  // fond masqué, fondu, déplacement.
                                  final envoi = _envoi;
                                  final enVol =
                                      envoi != null &&
                                      mine &&
                                      i == items.length - 1 &&
                                      m.content == envoi.texte;
                                  final (idNonLu, nombreNonLus) = _premierNonLu(
                                    messages,
                                  );
                                  final base = _buildMessageEntry(
                                    m,
                                    _enrobageSelection(m, bubble),
                                  );
                                  final entree = m.id == idNonLu
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _BarreNonLus(nombre: nombreNonLus),
                                            base,
                                          ],
                                        )
                                      : base;
                                  final effondrement = _effondrements[m.id];
                                  if (effondrement != null) {
                                    // La bulle est déjà partie en poussière :
                                    // il ne reste que sa place, qui se referme.
                                    return IgnorePointer(
                                      child: SizeTransition(
                                        sizeFactor: ReverseAnimation(
                                          CurvedAnimation(
                                            parent: effondrement,
                                            curve: TransitionEnvoi.courbeListe,
                                          ),
                                        ),
                                        axisAlignment: -1,
                                        child: Opacity(opacity: 0, child: entree),
                                      ),
                                    );
                                  }
                                  return enVol
                                      ? EntreeEnvoi(etat: envoi, child: entree)
                                      : entree;
                                },
                              ),
                              ),
                            ),
                          ],
                        ),
                ),
                // Groupe où seuls les administrateurs écrivent : on le dit
                // ici plutôt que de laisser quelqu'un taper pour rien.
                // Groupe où seuls les administrateurs écrivent. Plutôt
                // qu'un champ mort, la barre devient une note en verre
                // dépoli : on comprend en une seconde, et l'écran garde sa
                // tenue.
                if (_isGroup && _paroleFermee)
                  ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: OuroColors.systemBackground.withValues(alpha: 0.7),
                          border: Border(
                            top: BorderSide(color: OuroColors.separator, width: 0.5),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          15,
                          20,
                          15 + MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: OuroColors.systemFill,
                              ),
                              child: Icon(
                                Icons.campaign_rounded,
                                size: 15,
                                color: OuroColors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                l10n.chOnlyAdminsCanWrite,
                                style: OuroTypography.footnote.copyWith(
                                  color: OuroColors.secondaryLabel,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Le salon vocal du groupe : un bandeau, pas une sonnerie.
                // On voit qui est dedans, on entre quand on veut, et on
                // continue d'écrire pendant ce temps.
                if (_isGroup)
                  ValueListenableBuilder<int>(
                    valueListenable: SalonsVocaux.revision,
                    builder: (context, _, _) {
                      final salon = SalonsVocaux.de(widget.groupId!);
                      if (salon == null) return const SizedBox.shrink();
                      return _BandeauSalon(
                        salon: salon,
                        moi: ref.read(meshRepositoryProvider).myId,
                        onRejoindre: _rejoindreSalon,
                      );
                    },
                  ),
                if (_requeteMention != null)
                  _ChoixMention(
                    requete: _requeteMention!,
                    onChoisir: _insererMention,
                  ),
                if (!(_isGroup && _paroleFermee))
                ValueListenableBuilder<int>(
                  valueListenable: StorageService.revisionBlocage,
                  builder: (context, _, _) => _contactBloque
                      ? BanniereContactBloque(peerId: widget.peerId!)
                      : _vocalEnAttente != null
                      ? BarreRelectureVocale(
                          key: ValueKey(_vocalEnAttente!.chemin),
                          vocal: _vocalEnAttente!,
                          onSupprimer: () =>
                              unawaited(_supprimerVocalEnAttente()),
                          onEnvoyer: () =>
                              unawaited(_envoyerVocalEnAttente()),
                        )
                      : _InputBar(
                  horsDePortee: _horsDePortee,
                  champKey: _champSaisieKey,
                  opaciteChamp: _opaciteChamp,
                  // La mise en forme du texte appartient au pack — comme
                  // la transcription et la traduction chez Telegram.
                  miseEnFormeAutorisee: ref.watch(packDebloqueProvider),
                  onPackRequis: () => context.push('/premium'),
                  controller: _inputCtrl,
                  recording: _recording,
                  vocalVueUnique: _vocalVueUnique,
                  onVocalVueUnique: () {
                    OuroHaptics.light();
                    setState(() => _vocalVueUnique = !_vocalVueUnique);
                  },
                  recordingLocked: _recordingLocked,
                  amplitudes: _recording
                      ? List.unmodifiable(_amplitudes)
                      : const <double>[],
                  replyPreview: _replyTarget,
                  editionPreview: _enEdition,
                  onCancelEdit: _annulerEdition,
                  onChanged: _onTextChanged,
                  onSend: _send,
                  // ⚠️ UN SEUL AIGUILLAGE, ICI. Le bouton, le geste et la
                  // barre d'enregistrement ignorent complètement qu'il
                  // existe deux sortes de prise : c'est ce qui garantit
                  // que le glissement pour annuler et le verrouillage se
                  // comportent EXACTEMENT pareil en vocal et en vidéo,
                  // sans qu'il faille les écrire deux fois.
                  onMicStart: () =>
                      _modeVideo ? _demarrerVideoRonde() : _startRecording(),
                  onMicStop: () => _modeVideo
                      ? _arreterVideoRonde(garder: true)
                      : _stopRecording(),
                  onMicCancel: () => _modeVideo
                      ? _arreterVideoRonde(garder: false)
                      : _cancelRecording(),
                  onMicLock: () => setState(() => _recordingLocked = true),
                  onAttach: _openAttachSheet,
                  onCamera: () => unawaited(_photoRapide()),
                  onContenuClavier: (c) => unawaited(_contenuClavier(c)),
                  videoPossible: _cameraDisponible,
                  modeVideo: _modeVideo,
                  onBasculerMode: () => unawaited(_basculerModeVideo()),
                  recDrag: _recDrag,
                  onSticker: _basculerStickers,
                  stickersOuverts: _stickersOuverts,
                  champFocus: _champFocus,
                  onAttachMedia: () => _pickAndSendFile(filtre: FileType.media),
                  onCancelReply: () => setState(() => _replyTarget = null),
                ),
                ),
                // ══ LE PANNEAU DE STICKERS, À LA PLACE DU CLAVIER ══
                //
                // ⚠️ SOUS LE COMPOSEUR, DANS LA MÊME COLONNE. Posé
                // ailleurs — en surcouche, en feuille — il recouvrirait la
                // barre de saisie, et on ne pourrait plus écrire pendant
                // qu'on cherche un sticker. Ici il pousse simplement la
                // conversation vers le haut, exactement comme le clavier
                // qu'il remplace.
                AnimatedSize(
                  duration: DesignTokens.durationFast,
                  curve: DesignTokens.curveEnter,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: _stickersOuverts ? _hauteurClavier : 0,
                    width: double.infinity,
                    child: _stickersOuverts
                        ? ClipRect(
                            child: ColoredBox(
                              color: OuroColors
                                  .secondarySystemGroupedBackground,
                              child: PanneauStickers(
                                onChoisi: (s) =>
                                    unawaited(_envoyerSticker(s)),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            // ══ LE CERCLE D'ENREGISTREMENT ════════════════════════════
            //
            // ⚠️ EN SURCOUCHE, PAS DANS LA BARRE DE SAISIE. Il mesure 280
            // points de côté à pleine voix : posé dans la barre, il la
            // ferait grandir d'autant à chaque fois qu'on hausse le ton.
            // Ici il flotte au-dessus de la conversation, ancré sur le
            // bouton micro, et ne déplace rien.
            //
            // `IgnorePointer` est indispensable : le doigt est en train
            // de glisser sur le bouton micro, SOUS ce cercle. Sans lui,
            // le cercle intercepterait le mouvement dès qu'il grossit
            // au-delà du bouton — c'est-à-dire tout de suite — et le
            // glissement pour annuler deviendrait impossible.
            if (_recording) ...[
              // ══ LA VIDÉO RONDE : LE GRAND DISQUE AU CENTRE ════════════
              //
              // ⚠️ SÉPARÉ DU CERCLE DU MICRO, ET PAS À SA PLACE. Avant,
              // l'aperçu REMPLAÇAIT le cercle : un disque de 142 points
              // sous le pouce, où l'on ne se voyait pas. Telegram fait
              // l'inverse — capture à l'appui : l'aperçu occupe le milieu
              // de l'écran (largeur − 28), et le bouton reste en bas à
              // droite, gonflé, avec son icône de caméra.
              if (_modeVideo)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      // Centré dans la conversation, au-dessus de la barre
                      // de saisie, comme le `Gravity.CENTER` de Telegram
                      // dans une vue qui s'arrête au-dessus du panneau.
                      padding: EdgeInsets.only(
                        bottom: 64 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Center(
                        child: ListenableBuilder(
                          listenable: _cameraRonde,
                          builder: (context, _) =>
                              ApercuVideoRondEnregistrement(
                            camera: _cameraRonde.camera,
                            debut: _cameraRonde.debut,
                            diametre: math.min(
                                  MediaQuery.sizeOf(context).width,
                                  MediaQuery.sizeOf(context).height,
                                ) -
                                28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Builder(builder: (context) {
                final ancre = _ancreMicro();
                return Positioned(
                  // Le carré de 280 est centré sur le VRAI centre du micro,
                  // mesuré : il déborde donc de part et d'autre.
                  right: ancre.dx - CercleEnregistrement.cote / 2,
                  bottom: ancre.dy - CercleEnregistrement.cote / 2,
                  child: IgnorePointer(
                    key: _cleCercle,
                    child: AnimatedBuilder(
                      animation: _recDrag,
                      builder: (context, _) => CercleEnregistrement(
                        // En vidéo, pas de voix à suivre : le cercle reste
                        // à sa taille de repos, comme chez Telegram.
                        amplitudeCible: _modeVideo ? 0 : _amplitudeCible,
                        releve: _releveAmplitude,
                        entree: 1,
                        progressionAnnulation:
                            _recDrag.geste?.progressionAnnulation ?? 1,
                        progressionVerrou: _recDrag.lockT,
                        verrouille: _recordingLocked,
                        versEnvoi: _recordingLocked ? 1 : 0,
                        modeVideo: _modeVideo,
                      ),
                    ),
                  ),
                );
              }),
              // ══ LE GRAND CERCLE ENVOIE, UNE FOIS VERROUILLÉ ═══════════
              //
              // Le cercle est en `IgnorePointer` (le doigt glisse dessous
              // pendant qu'on maintient). Une fois verrouillé, le doigt est
              // parti, et le cercle porte la flèche d'envoi : chez Telegram,
              // c'est LUI qu'on touche pour envoyer. Une cible du diamètre
              // du cercle au repos (2 × 41), posée par-dessus — pas le
              // carré de 280 entier, qui avalerait les touchers sur un
              // quart de l'écran.
              if (_recordingLocked)
                Builder(builder: (context) {
                  final ancre = _ancreMicro();
                  return Positioned(
                    right: ancre.dx - 41,
                    bottom: ancre.dy - 41,
                    child: Semantics(
                      button: true,
                      label: AppLocalizations.of(context).actionSend,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          OuroHaptics.light();
                          unawaited(_modeVideo
                              ? _arreterVideoRonde(garder: true)
                              : _stopRecording());
                        },
                        child: const SizedBox.square(dimension: 82),
                      ),
                    ),
                  );
                }),
              // ══ LA COLONNE : VUE UNIQUE, CAMÉRA, CADENAS ═════════════
              //
              // ⚠️ AU-DESSUS DU CERCLE DANS LA PILE, pas dedans. Le cercle
              // est en `IgnorePointer` — il le faut, le doigt glisse en
              // dessous — mais les pastilles, elles, doivent être
              // TOUCHABLES. Les mettre dans le même widget forcerait à
              // choisir entre les deux.
              Builder(builder: (context) {
                final ancre = _ancreMicro();
                return Positioned(
                  // ⚠️ CENTRÉE SUR LE MICRO, au point près : décalé de
                  // quelques points, le cadenas ne paraît plus « au-dessus
                  // du doigt » mais à côté, et le geste vers le haut perd
                  // sa direction.
                  right: ancre.dx - VerrouEnregistrement.largeur / 2,
                  // Le bas du cadenas à 60 points au-dessus du CENTRE du
                  // cercle : 194 − 60 − 50 − 24 dans RecordCircle
                  // (CAEV:1417 et 2182). C'était 55 ici.
                  bottom: ancre.dy + _basVerrou,
                  child: TweenAnimationBuilder<double>(
                    // L'apparition : 250 ms, la même que le cadenas.
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutQuint,
                    builder: (context, apparition, _) => _FlottementVerrou(
                      builder: (context, flottement) => AnimatedBuilder(
                        animation: _recDrag,
                        builder: (context, _) {
                          // ⚠️ LE CADENAS MONTE AVEC LE DOIGT, il ne
                          // l'attend pas. Chez Telegram (CAEV:1427-1428),
                          // le haut recule de toute la course (57) et la
                          // capsule se raccourcit de 14 : le bas monte donc
                          // de 71. Ici le bas restait fixe et la capsule
                          // rétrécissait VERS le doigt — le cadenas
                          // semblait venir à sa rencontre au lieu de se
                          // dérober, et l'on ne sentait pas la montée.
                          //
                          // Le flottement (8 points, 1,67 s par aller)
                          // s'éteint à mesure qu'on monte : moveProgress
                          // dans `−dp(8) × idle × moveProgress`.
                          final f = _recordingLocked ? 1.0 : _recDrag.lockT;
                          final montee = 71 * f + 8 * flottement * (1 - f);
                          return Transform.translate(
                            offset: Offset(0, -montee),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BoutonVueUnique(
                                  active: _vocalVueUnique,
                                  apparition: apparition,
                                  onBascule: () => setState(() =>
                                      _vocalVueUnique = !_vocalVueUnique),
                                ),
                                const SizedBox(height: BoutonVueUnique.ecart),
                                if (_modeVideo) ...[
                                  Transform.scale(
                                    scale: apparition,
                                    child: BoutonRetournerCamera(
                                      onTap: () {
                                        OuroHaptics.selection();
                                        unawaited(_cameraRonde.retourner());
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                      height: BoutonVueUnique.ecart),
                                ],
                                // ⚠️ VERROUILLÉ, LE CADENAS DEVIENT PAUSE, et
                                // la pause OUVRE LA RÉÉCOUTE (voir
                                // `relecture_vocale.dart`) — comme Telegram.
                                // Avant la réécoute, le cadenas restait fermé :
                                // une pause qu'on touche sans effet est pire
                                // que pas de pause. En vidéo ronde, toujours
                                // pas de réécoute : il reste un cadenas.
                                IgnorePointer(
                                  ignoring:
                                      !(_recordingLocked && !_modeVideo),
                                  child: Semantics(
                                    button: _recordingLocked && !_modeVideo,
                                    label: AppLocalizations.of(context)
                                        .chVoicePause,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          unawaited(_arreterPourReecouter()),
                                      child: Opacity(
                                        opacity: apparition,
                                        child: VerrouEnregistrement(
                                          fermeture: f,
                                          verrouille:
                                              _recordingLocked && !_modeVideo,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ],
            // ══ LES MESSAGES ÉPINGLÉS, SOUS L'EN-TÊTE ═══════════════════
            if (epingles.isNotEmpty && !_searching)
              Positioned(
                top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                left: 0,
                right: 0,
                child: _BarreEpingles(
                  epingles: epingles,
                  index: _indexEpingle % epingles.length,
                  resume: (m) => _resumeMessage(AppLocalizations.of(context), m),
                  onTap: () {
                    final i = _indexEpingle % epingles.length;
                    OuroHaptics.selection();
                    _jumpToMessage(epingles[i].id, messages);
                    // Le toucher suivant mène au précédent épinglé, puis
                    // revient au premier — comme Telegram.
                    setState(() => _indexEpingle = (i + 1) % epingles.length);
                  },
                  onDesepingler: () {
                    final m = epingles[_indexEpingle % epingles.length];
                    OuroHaptics.light();
                    unawaited(ref
                        .read(meshMessagesProvider.notifier)
                        .epingler(m.id, epingle: false));
                  },
                ),
              ),
            // La date du premier message visible, pendant le défilement
            // (voir `_majJourFlottant`). Sans toucher : elle ne doit jamais
            // intercepter un geste sur les bulles qu'elle survole.
            if (_jourFlottant != null)
              Positioned(
                top: MediaQuery.paddingOf(context).top +
                    kToolbarHeight +
                    hautEpingles +
                    6,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _jourVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: AnimatedSlide(
                      offset: _jourVisible ? Offset.zero : const Offset(0, -0.3),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: _daySeparator(_jourFlottant!),
                    ),
                  ),
                ),
              ),
            // Bouton flottant "aller en bas"
            if (_showJumpButton)
              Positioned(
                right: 16,
                bottom: 96,
                child: _JumpButton(
                  unread: _unreadWhileScrolled,
                  onTap: () => _scrollToBottom(),
                ),
              ),
          ],
        ),
      )),
      ),
    );
  }

  /// Où se trouve la bulle d'un message, en coordonnées d'écran.
  ///
  /// On vise le HAUT de la bulle plutôt que son centre : les cœurs
  /// jaillissent alors du bord supérieur et montent, au lieu de traverser
  /// le texte du message auquel on vient de réagir.
  ///
  /// Renvoie `null` si la bulle n'est plus construite — la salve retombe
  /// alors sur son comportement plein écran, ce qui vaut mieux que pas
  /// de retour du tout.
  Offset? _centreDeLaBulle(String messageId) {
    final rendu = _messageKeys[messageId]?.currentContext?.findRenderObject();
    if (rendu is! RenderBox || !rendu.hasSize) return null;
    final origine = rendu.localToGlobal(Offset.zero);
    return Offset(origine.dx + rendu.size.width / 2, origine.dy + 8);
  }

  // `_memeAuteur` vivait ici. Elle est partie dans `message_grouping.dart`,
  // où elle est une fonction pure que `test/groupage_bulles_test.dart`
  // verrouille. Son paramètre `myId` n'a jamais été lu.

  /// Les avis du groupe : création, arrivées, départs.
  ///
  /// Rien de nouveau ne circule pour ça : chaque fiche de membre garde déjà
  /// qui l'a ajouté et quand. On se contente de lire ce qu'on a et de le
  /// poser au bon endroit dans la conversation.
  List<_AvisGroupe> _avisDuGroupe(BuildContext context) {
    final id = widget.groupId;
    if (id == null) return const [];
    final groupe = StorageService.getGroup(id);
    if (groupe == null) return const [];
    final l10n = AppLocalizations.of(context);
    final moi = ref.read(meshRepositoryProvider).myId;
    String nom(String peerId) => peerId == moi
        ? l10n.imYou
        : (StorageService.getPeerRecord(peerId)?.pseudo ?? l10n.imUnknown);

    final avis = <_AvisGroupe>[
      _AvisGroupe(groupe.createdAt, l10n.grCreatedBy(nom(groupe.createdBy))),
    ];
    for (final m in groupe.members) {
      // La fiche du fondateur est déjà racontée par la création.
      if (!(m.peerId == groupe.createdBy && m.addedBy == groupe.createdBy)) {
        avis.add(
          _AvisGroupe(
            m.addedAt,
            m.peerId == moi
                ? l10n.grAddedYou(nom(m.addedBy))
                : l10n.grAdded(nom(m.addedBy), nom(m.peerId)),
          ),
        );
      }
      final parti = m.removedAt;
      if (parti != null) {
        // On ne dit pas QUI a retiré : la fiche ne le sait pas, et
        // inventer serait pire que de rester sobre.
        avis.add(_AvisGroupe(parti, l10n.grMemberGone(nom(m.peerId))));
      }
    }
    return avis;
  }

  List<Object> _buildItems(BuildContext context, List<MeshMessage> messages) {
    final items = <Object>[];
    DateTime? lastDay;

    // Les messages et les avis, remis dans l'ordre du temps.
    final avis = _isGroup ? _avisDuGroupe(context) : const <_AvisGroupe>[];
    final melange = <(DateTime, Object)>[
      for (final m in messages) (m.timestamp, m),
      for (final a in avis) (a.quand, a),
    ]..sort((x, y) => x.$1.compareTo(y.$1));

    for (final (quand, item) in melange) {
      final jour = DateTime(quand.year, quand.month, quand.day);
      if (lastDay == null || jour != lastDay) {
        items.add(_DaySeparator(_dayLabel(context, jour)));
        lastDay = jour;
      }
      items.add(item);
    }
    return items;
  }


  /// Le champ de recherche qui prend la place de l'en-tête.
  Widget _searchField(List<MeshMessage> messages) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SizedBox(
        height: 36,
        child: CupertinoSearchTextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          placeholder: l10n.actionSearch,
          style: OuroTypography.body.copyWith(color: OuroColors.label),
          placeholderStyle: OuroTypography.body.copyWith(
            color: OuroColors.tertiaryLabel,
          ),
          backgroundColor: OuroColors.tertiarySystemFill,
          itemColor: OuroColors.secondaryLabel,
          onChanged: (value) => _runSearch(value, messages),
          onSuffixTap: () {
            _searchCtrl.clear();
            _runSearch('', messages);
          },
        ),
      ),
    );
  }

  /// Le compteur « 2 sur 7 » et les deux chevrons de navigation.
  List<Widget> _searchActions(List<MeshMessage> messages) {
    final l10n = AppLocalizations.of(context);
    final none = _query.isEmpty;
    final empty = !none && _hits.isEmpty;

    return [
      if (!none)
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Center(
            child: Text(
              empty
                  ? l10n.chNoneFound
                  : l10n.chSearchResultPosition(
                      '${_hitIndex + 1}',
                      '${_hits.length}',
                    ),
              style: OuroTypography.footnote.copyWith(
                color: empty ? OuroColors.systemRed : OuroColors.secondaryLabel,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      // Le chevron BAS va vers les messages plus récents, le HAUT vers
      // les plus anciens : le sens du défilement, pas celui de la liste
      // des résultats. L'inverse désoriente immédiatement.
      OuroIconButton(
        tooltip: l10n.chOlderResult,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.keyboard_arrow_up_rounded,
          color: _hits.isEmpty ? OuroColors.quaternaryLabel : OuroColors.accent,
        ),
        onPressed: _hits.isEmpty ? null : () => _gotoHit(1, messages),
      ),
      OuroIconButton(
        tooltip: l10n.chNewerResult,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _hits.isEmpty ? OuroColors.quaternaryLabel : OuroColors.accent,
        ),
        onPressed: _hits.isEmpty ? null : () => _gotoHit(-1, messages),
      ),
      const SizedBox(width: 4),
    ];
  }

  /// Enrobe une bulle de message pour permettre le glissement vers la
  /// droite qui prépare une réponse (« swipe to reply »), comme sur
  /// WhatsApp/Telegram.
  Widget _buildMessageEntry(MeshMessage m, Widget bubble) {
    // La clé permet de RAMENER cette bulle à l'écran plus tard — depuis
    // un résultat de recherche ou depuis une citation. Elle n'existe que
    // tant que la bulle est construite, ce dont `_jumpToMessage` tient
    // compte.
    final key = _messageKeys.putIfAbsent(m.id, GlobalKey.new);

    // Le clignotement d'arrivée : un halo qui s'allume puis s'éteint.
    // Sans lui, sauter à un message ancien dépose l'utilisateur devant
    // un mur de texte sans lui dire lequel il cherchait.
    final flashed = _flashedId == m.id;

    return KeyedSubtree(
      key: key,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: flashed
              ? OuroColors.accent.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: RepaintBoundary(
          key: _clesCapture.putIfAbsent(m.id, GlobalKey.new),
          child: _dismissibleEntry(m, bubble),
        ),
      ),
    );
  }

  /// Glisser une bulle vers la droite pour y répondre.
  ///
  /// ⚠️ CE N'EST PLUS UN `Dismissible`, ET C'EST TOUTE LA DIFFÉRENCE.
  ///
  /// `Dismissible` est fait pour SUPPRIMER : il emporte l'élément hors de
  /// l'écran, découvre un panneau coloré derrière, et ne se déclenche
  /// qu'au-delà d'un tiers de la largeur. Détourné en « répondre », il
  /// donnait un geste lourd — on tirait un bloc entier sur un tiers de
  /// l'écran pour citer un message.
  ///
  /// WhatsApp et Telegram font l'inverse : la bulle suit le doigt sur
  /// quelques dizaines de points, avec une résistance croissante, une
  /// flèche qui apparaît, une vibration au moment où le seuil est
  /// franchi — puis elle revient d'elle-même à sa place. Le message ne
  /// bouge jamais vraiment ; c'est un ACQUITTEMENT, pas un déplacement.
  ///
  /// Les trois détails qui font que ça marche :
  ///
  ///   • **l'élastique** — au-delà du seuil, le déplacement est divisé
  ///     par trois. Le doigt continue, la bulle non : c'est ce qui donne
  ///     la sensation de tirer contre quelque chose ;
  ///   • **la vibration AU SEUIL**, pas au relâchement. On sait que
  ///     c'est acquis avant même de lever le doigt ;
  ///   • **le retour par un ressort**, qui repart de la position ET de
  ///     la vitesse courantes — relâcher en plein mouvement ne produit
  ///     aucun à-coup.
  Widget _dismissibleEntry(MeshMessage m, Widget bubble) {
    return _GlisserPourRepondre(
      onRepondre: () => _repondreA(m),
      child: bubble,
    );
  }

  /// Pendant qu'on est remonté dans l'historique (pas tout en bas),
  /// compte combien de nouveaux messages sont arrivés depuis — c'est ce
  /// nombre qui s'affiche sur le petit bouton flottant « nouveaux
  /// messages ».
  void _maybeCountUnread(List<MeshMessage> messages, String myId) {
    if (!_showJumpButton) return;
    final now = DateTime.now();
    final readAt = _lastReadAt ?? now;
    _lastReadAt = readAt;
    final count = messages.where((m) {
      if (m.senderId == myId) return false;
      return m.timestamp.isAfter(readAt);
    }).length;
    if (count != _unreadWhileScrolled) {
      setState(() => _unreadWhileScrolled = count);
    }
  }

  /// Un avis de groupe : même pastille que les jours, un cran plus discret,
  /// avec la silhouette qui dit de quoi on parle.
  Widget _avisGroupe(String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 36),
      child: Center(
        child: OuroCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          borderRadius: DesignTokens.radiusFull,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_rounded,
                size: 12,
                color: OuroColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  texte,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: OuroColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _daySeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: OuroCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          borderRadius: DesignTokens.radiusFull,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: OuroColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _dayLabel(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return l10n.chToday;
    if (day == today.subtract(const Duration(days: 1))) return l10n.chYesterday;
    if (day.isAfter(today.subtract(const Duration(days: 7)))) {
      return [
        l10n.chMonday,
        l10n.chTuesday,
        l10n.chWednesday,
        l10n.chThursday,
        l10n.chFriday,
        l10n.chSaturday,
        l10n.chSunday,
      ][day.weekday - 1];
    }
    final langue = Localizations.localeOf(context).toLanguageTag();
    return day.year == now.year
        ? DateFormat.MMMMd(langue).format(day)
        : DateFormat.yMMMMd(langue).format(day);
  }
}

/// Un avis de groupe posé dans la conversation.
class _AvisGroupe {
  const _AvisGroupe(this.quand, this.texte);

  final DateTime quand;
  final String texte;
}

class _DaySeparator {
  const _DaySeparator(this.label);
  final String label;
}

/// Ce qui s'affiche quand la conversation n'a encore aucun message —
/// un avatar et un petit texte d'accueil (« Dites bonjour 👋 »).
class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.isBroadcast, required this.peerPseudo});
  final bool isBroadcast;
  final String peerPseudo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PeerAvatar(pseudo: peerPseudo, radius: 34, online: !isBroadcast),
          const SizedBox(height: 12),
          // La petite main qui salue sous l'avatar : c'est le premier
          // écran d'une conversation neuve, le moment où l'on hésite à
          // écrire. Un mouvement y vaut mieux qu'un blanc.
          SceneAnimee(
            emoji: isBroadcast ? Scenes.diffusionVide : Scenes.conversationVide,
            iconeDeSecours: isBroadcast
                ? Icons.campaign_rounded
                : Icons.waving_hand_rounded,
            taille: 56,
          ),
          const SizedBox(height: 8),
          Text(
            isBroadcast
                ? AppLocalizations.of(context).chBroadcastChannel
                : AppLocalizations.of(context).chSayHello,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OuroColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBroadcast
                ? AppLocalizations.of(context).chBroadcastEmptyBody
                : AppLocalizations.of(context).chP2pRelayedBody,
            style: TextStyle(fontSize: 12, color: OuroColors.textTertiary),
          ),
          if (!isBroadcast) ...[
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: _MentionChiffrement(),
            ),
          ],
        ],
      ),
    );
  }
}

/// « 🔒 Messages chiffrés de bout en bout » — le petit encart jaune pâle
/// que WhatsApp pose en haut de chaque conversation.
///
/// ⚠️ C'EST LA PROMESSE CENTRALE DE DROPLET, et l'écran ne la disait nulle
/// part. Un encart discret, une seule fois, au tout début : assez pour
/// rassurer, pas assez pour encombrer.
class _MentionChiffrement extends StatelessWidget {
  const _MentionChiffrement();

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sombre
              ? const Color(0xFF3A3420).withValues(alpha: 0.85)
              : const Color(0xFFFFF4C4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 12,
                    color: sombre
                        ? const Color(0xFFE8D9A0)
                        : const Color(0xFF6B5A1E),
                  ),
                ),
              ),
              TextSpan(text: AppLocalizations.of(context).chE2eNotice),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: sombre ? const Color(0xFFE8D9A0) : const Color(0xFF6B5A1E),
          ),
        ),
      ),
    );
  }
}

/// UNE bulle de message dans la conversation — texte, fichier ou
/// message vocal (mais pas image, voir `_ImageBubble` pour ça). Change
/// d'apparence selon qu'elle est « à moi » (alignée à droite, colorée)
/// ou « à l'autre » (alignée à gauche), et peut afficher une citation
/// (« en réponse à... »), un lecteur audio, ou l'effet spécial choisi.
/// Le diamètre de l'avatar posé à côté d'une bulle de groupe.
///
/// 28 points : c'est la hauteur d'une seule ligne de texte dans une bulle.
/// Plus grand, l'avatar dépasse la bulle qu'il accompagne quand le message
/// est court — un mot de trois lettres se retrouverait flanqué d'un
/// portrait deux fois plus haut que lui.
const double _tailleAvatarBulle = 28;

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    this.suiteDuPrecedent = false,
    this.epingle = false,
    this.finDeSerie = true,
    required this.isBroadcast,
    this.isGroup = false,
    required this.isAudio,
    this.transitionVocale,
    this.isImage = false,
    this.isVideo = false,
    required this.playingAudio,
    this.playbackProgress = 0,
    this.playbackPosition,
    this.playbackSpeed = 1.0,
    this.voicePlayed = false,
    this.transcription,
    this.transcriptionEnCours = false,
    this.onTranscrire,
    this.traduction,
    this.traductionEnCours = false,
    this.onRenvoyer,
    this.onOuvrirPhoto,
    this.onAnnulerEnvoi,
    required this.onPlayAudio,
    this.onSeekAudio,
    this.onCycleSpeed,
    this.onVoiceReply,
    required this.onLongPress,
    this.onDoubleTap,
    this.onOpenLocation,
    this.repliedMessage,
    this.onOpenReplied,
    this.query = '',
    this.scrollVelocity = 0,
    this.threadCount = 0,
    this.onOpenThread,
    this.progression,
  });

  final MeshMessage message;

  /// Avancement d'un fichier en cours d'envoi ou de réception (0 à 1), ou
  /// `null` quand aucun transfert n'est en cours.
  final double? progression;

  /// Renvoie un message dont l'envoi a échoué.
  ///
  /// ⚠️ UN SEUL APPUI, SUR L'INDICATEUR ROUGE LUI-MÊME.
  ///
  /// L'action existe aussi dans le menu d'appui long — mais un appui
  /// long est un geste qu'il faut connaître, et personne ne le cherche
  /// devant un message qui vient d'échouer. Toutes les grandes
  /// messageries font de l'indicateur d'échec un bouton : c'est
  /// exactement là que le doigt se pose déjà.
  final VoidCallback? onRenvoyer;

  /// Ramène à l'original quand on tape la citation.
  final VoidCallback? onOpenReplied;

  /// Le texte recherché, à surligner dans la bulle. Vide hors recherche.
  final String query;

  /// Vélocité du scroll (0.0 à 1.0) pour l'effet de respiration des bulles.
  final double scrollVelocity;

  /// Nombre de réponses dans le fil (0 = pas de fil actif).
  final int threadCount;

  /// Ouvre la vue du fil de discussion.
  final VoidCallback? onOpenThread;

  final bool mine;
  final bool isBroadcast;

  /// Conversation de groupe — comme en diffusion, il faut dire QUI parle.
  final bool isGroup;

  final bool isAudio;

  /// La transition d'envoi vocale, si c'est CE message qui vient de
  /// partir. Nulle partout ailleurs.
  final EtatVocal? transitionVocale;
  final bool isImage;
  final bool isVideo;
  final bool playingAudio;
  final double playbackProgress;
  final Duration? playbackPosition;
  final double playbackSpeed;

  /// Ce vocal a-t-il déjà été écouté ? Pilote la pastille bleue.
  final bool voicePlayed;

  /// Le texte du vocal, quand il a été demandé.
  final String? transcription;
  final bool transcriptionEnCours;

  /// Demande (ou referme) la transcription. `null` : pas de moteur vocal.
  final VoidCallback? onTranscrire;

  /// La traduction demandée depuis le menu du message.
  final String? traduction;
  final bool traductionEnCours;

  final VoidCallback onPlayAudio;
  final ValueChanged<double>? onSeekAudio;
  final VoidCallback? onCycleSpeed;

  /// Répondre par un vocal — uniquement sur les messages vocaux reçus.
  final VoidCallback? onVoiceReply;

  final VoidCallback onLongPress;
  final VoidCallback? onDoubleTap;

  /// Ouvre la position partagée sur la grande carte.
  final VoidCallback? onOpenLocation;
  final MeshMessage? repliedMessage;

  /// Ce que le lecteur d'écran énonce pour cette bulle.
  ///
  /// ⚠️ C'EST LE POINT LE PLUS IMPORTANT DE TOUTE L'ACCESSIBILITÉ DE
  /// DROPLET, parce que c'est le contenu même de l'application.
  ///
  /// Sans lui, VoiceOver parcourait la bulle par fragments — le
  /// pseudonyme, puis le texte, puis l'heure, puis une icône de coche
  /// sans nom — et surtout il ne disait JAMAIS l'essentiel : de qui vient
  /// ce message. Sur un fil où l'on ne voit pas de quel côté sont les
  /// bulles, « moi » et « l'autre » deviennent indiscernables.
  ///
  /// L'ordre suit celui d'une lecture à voix haute : qui parle, ce qui
  /// est dit, quand, et où en est l'envoi.
  String _annonce(AppLocalizations l10n) {
    final qui = mine ? l10n.chAccessibilityMe : message.authorPseudo;

    final quoi = switch (message.type) {
      'file'
          when (mediaKindOf(message.fileMimeType, message.fileName) ==
              MediaKind.image) =>
        l10n.chPhotoLabel,
      'file'
          when (mediaKindOf(message.fileMimeType, message.fileName) ==
              MediaKind.video) =>
        l10n.chVideoLabel,
      'file'
          when (mediaKindOf(message.fileMimeType, message.fileName) ==
              MediaKind.audio) =>
        l10n.chVoiceMessageLabel,
      'file' => l10n.chFileLabel(message.fileName ?? ''),
      _ when _isAnimatedSticker => l10n.chStickerLabel(
        AnimatedStickerCatalog.nomLisible(_contenuVisible),
      ),
      _ => _contenuVisible,
    };

    // L'état d'envoi n'est visible que sur MES messages, et n'est
    // annoncé que là — l'entendre sur un message reçu n'aurait aucun
    // sens.
    final etat = !mine
        ? null
        : switch (message.status) {
            MessageStatus.sending => l10n.chSendingStatus,
            MessageStatus.pending => l10n.chPendingStatus,
            MessageStatus.failed => l10n.chFailedStatus,
            MessageStatus.sent =>
              message.readAt != null
                  ? l10n.chReadStatus
                  : message.deliveryCount > 0
                  ? l10n.chDeliveredStatus
                  : l10n.chSentStatus,
          };

    return [qui, quoi, _formatTime(message.timestamp), ?etat].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFile = message.type == 'file';
    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // La couleur et la forme du fond, calculées une fois : la transition
    // d'envoi en a besoin pour dessiner le fond qui naît du champ.
    final couleurFond = _bubbleColorForState(
      mine: mine,
      status: message.status,
    );
    final bulleVisible = !_sansBulle;
    final forme = _FormeBulle(
      rayon: ReglagesApparence.rayonBulles,
      rayonQueue: finDeSerie && bulleVisible
          ? ReglagesApparence.rayonQueue
          : ReglagesApparence.rayonBulles,
      mine: mine,
      // ⚠️ LA GOUTTE REMPLACE LA POINTE.
      //
      // La pointe triangulaire de WhatsApp avait été retirée : sur les
      // bulles de Droplet, elle se lisait comme un emprunt. La goutte, elle,
      // n'appartient à personne d'autre — c'est la silhouette de l'app. Elle
      // marque la dernière bulle d'une série, comme la queue des autres
      // messageries marque le locuteur.
      goutte: finDeSerie && bulleVisible,
      couleurReflet: bulleVisible ? _refletBulle(couleurFond) : null,
    );
    final envoi = EnvoiEnCours.maybeOf(context);
    if (envoi != null) {
      envoi.couleurFond = couleurFond;
      envoi.forme = forme;
    }

    final bubble = Padding(
      // iMessage : 3pt quand la bulle prolonge la précédente, 9pt quand
      // elle ouvre une nouvelle prise de parole. C'est ce contraste
      // d'espacement — et lui seul — qui fait lire le fil par blocs.
      padding: EdgeInsets.only(top: suiteDuPrecedent ? 3 : 9, bottom: 1),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // ⚠️ EN GROUPE AUSSI, PAS SEULEMENT EN DIFFUSION.
          //
          // Le nom n'apparaissait qu'au-dessus des messages de diffusion.
          // Dans un groupe, tous les messages reçus arrivaient donc
          // ANONYMES : impossible de savoir qui avait écrit quoi, alors
          // que c'est la première chose qu'on cherche à plusieurs.
          if (!mine && (isBroadcast || isGroup) && !suiteDuPrecedent)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.forwardedFrom != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forward_rounded,
                            size: 12,
                            color: mine
                                ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.55)
                                : OuroColors.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            l10n.chForwarded,
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: mine
                                  ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.55)
                                  : OuroColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.authorPseudo,
                    style: TextStyle(
                      fontSize: 11,
                      color: _senderColor(
                        message.senderId ?? message.authorPseudo,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          _BullePressable(
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ══ L'AVATAR DE CELUI QUI PARLE ════════════════════════
                //
                // Dans un groupe seulement, et seulement pour les messages
                // REÇUS : ma propre photo à côté de mes propres bulles
                // n'apprend rien, je sais qui je suis.
                //
                // ⚠️ AU BAS DE LA SÉRIE, PAS EN HAUT. C'est le détail que
                // presque toutes les imitations ratent. WhatsApp sur iOS
                // pose la photo à côté du DERNIER message d'une suite du
                // même auteur — pas du premier. La raison se voit dès
                // qu'on fait défiler : la photo reste collée à l'endroit
                // où la conversation continue, au même niveau que la
                // queue de la bulle, au lieu de s'éloigner vers le haut à
                // mesure que la personne écrit.
                //
                // ⚠️ ET UN ESPACE RÉSERVÉ QUAND IL N'Y A PAS DE PHOTO.
                // Sans lui, les messages du milieu d'une série seraient
                // décalés de 34 points vers la gauche par rapport au
                // dernier : la colonne de bulles se mettrait à zigzaguer.
                if (isGroup && !mine)
                  SizedBox(
                    width: _tailleAvatarBulle + 6,
                    child: finDeSerie
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: PeerAvatar(
                              pseudo: message.authorPseudo,
                              radius: _tailleAvatarBulle / 2,
                              imagePath: AvatarService.cheminPair(
                                message.senderId,
                              ),
                            ),
                          )
                        : null,
                  ),
                // ⚠️ L'ICÔNE DE STATUT NE VIT PLUS ICI.
                //
                // Elle était dessinée à GAUCHE de la bulle, en vert ou en
                // orange vif — et redessinée une seconde fois À
                // L'INTÉRIEUR, à côté de l'heure. Deux indicateurs pour
                // une seule information, dont un gros point coloré qui
                // attirait l'œil avant le texte du message lui-même.
                //
                // Il n'en reste qu'un, discret, collé à l'heure : le
                // statut est une information de service, il ne doit
                // jamais primer sur ce qui est écrit.
                _avecReactions(ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  child: BaliseEnvoi(
                    role: RoleBalise.fond,
                    child: Container(
                      // ── LES MÉDIAS N'ONT PLUS DE CADRE ──────────────
                      //
                      // Photos et vidéos étaient serties dans quatre points
                      // de couleur de bulle, tout autour. C'est le « cadre »
                      // que WhatsApp a supprimé dans sa refonte de 2026, et
                      // la raison est bonne : ce liseré n'apportait aucune
                      // information et découpait l'image d'un trait bleu ou
                      // gris qui la faisait paraître collée, pas envoyée.
                      //
                      // À zéro, l'image devient la bulle. Ce sont les coins
                      // arrondis du conteneur qui la rognent, donc elle
                      // garde exactement la même géométrie que les bulles
                      // de texte voisines.
                      padding: _sansBulle
                          ? const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            )
                          : (isImage || isVideo)
                          ? EdgeInsets.zero
                          // ⚠️ MARGES ASYMÉTRIQUES, et c'est
                          // obligatoire depuis la pointe.
                          //
                          // La forme réserve sept points sur le côté
                          // de l'auteur pour laisser dépasser la
                          // pointe. Une marge identique des deux côtés
                          // laisserait donc le texte collé au bord du
                          // côté opposé et flottant du côté de la
                          // pointe — un déséquilibre qu'on ne sait pas
                          // nommer mais qu'on voit.
                          //
                          // Les valeurs sont aussi RESSERRÉES (11/7 au
                          // lieu de 14/10) : les bulles de WhatsApp
                          // sont nettement plus compactes que celles
                          // d'iMessage, et c'est ce qui permet d'en
                          // voir plus à l'écran sans rien tasser.
                          : EdgeInsets.symmetric(
                              horizontal: isAudio ? 6 : 13,
                              vertical: isAudio ? 6 : 7,
                            ),
                      // Le contenu est rogné par les coins de la bulle :
                      // sans cela, une image à ras bord dépasserait des
                      // arrondis.
                      clipBehavior: Clip.antiAlias,
                      // ── LA FORME WHATSAPP ───────────────────────────
                      //
                      // `ShapeDecoration` et non `BoxDecoration` : il
                      // fallait une forme LIBRE pour que la pointe puisse
                      // déborder du rectangle. Un `borderRadius` ne sait
                      // qu'arrondir des coins, il ne sait pas ajouter de
                      // matière.
                      //
                      // C'est aussi ce qui rogne le contenu : depuis que
                      // les images vont d'un bord à l'autre, elles suivent
                      // exactement ce tracé, pointe comprise.
                      decoration: ShapeDecoration(
                        // Couleurs de Messages, modulées par l'état réseau :
                        //   • Stable (lu/remis) = couleur vive, brillante
                        //   • En cours (sending/pending) = légèrement matte
                        //   • Échec = translucide, estompée
                        // Pendant la transition d'envoi, le fond est peint
                        // par `CoucheFondEnvoi`, qui le fait naître du champ.
                        color: _sansBulle || envoi != null
                            ? Colors.transparent
                            : (mine ? null : couleurFond),
                        // Mes bulles ont une matière : la même couleur, à
                        // peine plus claire en haut, comme de l'eau éclairée
                        // par le dessus.
                        gradient: _sansBulle || envoi != null || !mine
                            ? null
                            : _degradeBulle(couleurFond),
                        shape: forme,
                      ),
                      // ⚠️ POUR UN MESSAGE COURT, L'HEURE SE MET SUR LA
                      // MÊME LIGNE QUE LE TEXTE.
                      //
                      // Empilée systématiquement en dessous, elle donnait
                      // à un message de deux caractères une bulle presque
                      // aussi haute que large — l'heure y occupait plus de
                      // place que le mot. C'est la disposition qu'emploient
                      // toutes les messageries : le texte coule, et l'heure
                      // vient se loger dans l'espace qui reste à sa droite.
                      //
                      // Au-delà d'une vingtaine de caractères, ou dès qu'il
                      // y a autre chose que du texte (image, citation,
                      // réaction), on repasse à l'empilement : côte à côte,
                      // le texte serait comprimé par l'heure.
                      child: _heureSurLaMemeLigne && !_vueUnique
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(child: _textBubble(l10n, isFile)),
                                const SizedBox(width: 6),
                                _TapCible(
                                  marge: EdgeInsets.zero,
                                  onTap: _actionSurLHeure(context),
                                  semantique: _libelleDeLHeure(l10n),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: _timeAndStatus(l10n),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              if (_vueUnique)
                                _contenuVueUnique(context, l10n)
                              else ...[
                                if (repliedMessage != null)
                                  _quoteBlock(l10n, repliedMessage!)
                                else if (_idStatutCite != null)
                                  // Réponse à un statut : sa vignette, comme
                                  // WhatsApp.
                                  _CitationStatut(statusId: _idStatutCite!, mine: mine),
                                if (isVideo)
                                  _VideoBubble(
                                    fileId: message.fileId ?? '',
                                    fileName: message.fileName ?? '',
                                    progression: progression,
                                    heure: _legendeMedia == null
                                        ? _heureSurMedia(context, l10n)
                                        : null,
                                    onAnnuler: onAnnulerEnvoi,
                                  )
                                else if (isImage)
                                  _ImageBubble(
                                    fileId: message.fileId ?? '',
                                    fileName: message.fileName ?? '',
                                    progression: progression,
                                    heroTag: 'photo-${message.id}',
                                    titre: mine ? null : message.authorPseudo,
                                    // Avec une légende, l'heure descend sous le
                                    // texte, comme dans WhatsApp.
                                    heure: _legendeMedia == null
                                        ? _heureSurMedia(context, l10n)
                                        : null,
                                    onOuvrir: onOuvrirPhoto,
                                    onAnnuler: onAnnulerEnvoi,
                                  )
                                else if (isAudio)
                                  _audioBubble()
                                else if (message.effect == kEffectInvisibleInk)
                                  _InvisibleInkReveal(
                                    child: _textBubble(l10n, isFile),
                                  )
                                else
                                  _textBubble(l10n, isFile),
                                // ⚠️ LES RÉACTIONS NE SONT PLUS ICI. Voir
                                // `_avecReactions` : elles se posent À CHEVAL
                                // sur le bord de la bulle, comme partout.
                                // La légende écrite dans l'aperçu, sous la photo.
                                if ((isImage || isVideo) && _legendeMedia != null)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      11,
                                      7,
                                      11,
                                      1,
                                    ),
                                    child: Text(
                                      _legendeMedia!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.3,
                                        color: mine
                                            ? OuroColors.bubbleOutgoingText
                                            : OuroColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                // Sans légende, sur une photo ou une vidéo,
                                // l'heure et les coches sont posées SUR l'image
                                // (voir `_heureSurMedia`).
                                if (!(isImage || isVideo) || _legendeMedia != null)
                                  Padding(
                                    padding: (isImage || isVideo)
                                        ? const EdgeInsets.fromLTRB(0, 0, 11, 6)
                                        : EdgeInsets.zero,
                                    child: _TapCible(
                                      // Toucher l'heure ouvre le détail de la
                                      // transmission — le geste est discret, et
                                      // n'encombre pas la bulle d'un bouton de plus.
                                      onTap: _actionSurLHeure(context),
                                      semantique: _libelleDeLHeure(l10n),
                                      child: _timeAndStatus(l10n),
                                    ),
                                  ),
                              ],
                            ],
                            ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );

    // Entrée d'une bulle : un fondu court accompagné d'un très léger
    // glissement vers le haut, identique dans les deux sens.
    //
    // L'ancienne version faisait REBONDIR (`elasticOut`) chaque message
    // envoyé, en le faisant dépasser sa taille finale avant de revenir.
    // C'est l'animation la plus répétée de toute l'app — plusieurs
    // centaines de fois par jour pour quelqu'un qui écrit beaucoup — et
    // elle retardait à chaque fois l'affichage du message de près d'une
    // demi-seconde. Messages sur iOS se contente de faire apparaître la
    // bulle : elle est là, immédiatement.
    // La bulle devient UN élément pour le lecteur d'écran, avec ses deux
    // gestes nommés.
    //
    // ⚠️ `onLongPress` et `onDoubleTap` sont invisibles pour VoiceOver
    // tant qu'ils ne sont pas déclarés ici : un `GestureDetector` seul
    // n'est, pour lui, qu'un décor. Les déclarer les fait apparaître dans
    // le rotor d'actions, et l'utilisateur entend « Actions disponibles :
    // Options du message, J'adore » au lieu de n'avoir aucun moyen de
    // réagir à un message.
    final lisible = Semantics(
      container: true,
      label: _annonce(l10n),
      excludeSemantics: true,
      onLongPress: onLongPress,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.chMessageOptionsSemantics):
            onLongPress,
        CustomSemanticsAction(label: l10n.chLoveReactionSemantics):
            ?onDoubleTap,
      },
      child: bubble,
    );

    return _EntreeBulle(
      id: message.id,
      horodatage: message.timestamp,
      construire: _animerEntree,
      child: lisible,
    );
  }

  /// L'apparition d'une bulle qui ARRIVE (voir `_EntreeBulle`).
  ///
  /// Envoyée : la bulle grandit depuis son coin, vers le champ de saisie
  /// d'où elle vient (iMessage). Reçue : elle monte et se gonfle depuis le
  /// coin de l'auteur, avec un léger dépassement — le petit « pop » de
  /// Telegram, qui fait sentir qu'un message vient d'arriver.
  Widget _animerEntree(Widget bulle) {
    var animated = bulle.animate().fadeIn(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
    animated = mine
        ? animated
              .moveY(
                begin: 10,
                end: 0,
                duration: 340.ms,
                curve: Curves.easeOutCubic,
              )
              .scaleXY(
                begin: 0.6,
                end: 1.0,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
                alignment: Alignment.bottomRight,
              )
        : animated
              .moveY(
                begin: 16,
                end: 0,
                duration: 380.ms,
                curve: Curves.easeOutCubic,
              )
              .scaleXY(
                begin: 0.82,
                end: 1.0,
                duration: 440.ms,
                curve: Curves.easeOutBack,
                alignment: Alignment.bottomLeft,
              );

    // Effets de bulle façon iMessage — enchaînés après l'entrée, et joués
    // une seule fois comme elle.
    switch (message.effect) {
      case kEffectSlam:
        animated = animated
            .then(delay: 60.ms)
            .scaleXY(
              begin: 1,
              end: 1.3,
              duration: 140.ms,
              curve: Curves.easeOut,
            )
            .then()
            .scaleXY(
              begin: 1.3,
              end: 1,
              duration: 180.ms,
              curve: Curves.easeIn,
            );
      case kEffectLoud:
        animated = animated
            .then(delay: 60.ms)
            .scaleXY(
              begin: 1,
              end: 1.15,
              duration: 120.ms,
              curve: Curves.easeOut,
            )
            .then()
            .shake(hz: 6, duration: 380.ms, offset: const Offset(6, 0));
      case kEffectGentle:
        animated = animated
            .then(delay: 60.ms)
            .scaleXY(
              begin: 1,
              end: 0.8,
              duration: 220.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scaleXY(
              begin: 0.8,
              end: 1,
              duration: 280.ms,
              curve: Curves.easeOutCubic,
            );
    }
    return animated;
  }

  /// La couleur attribuée à un participant, dans un groupe.
  ///
  /// ── Pourquoi une couleur, et pourquoi celle-là ────────────────────
  ///
  /// Dans une conversation à plusieurs, on ne lit pas les noms : on les
  /// RECONNAÎT à leur couleur, du coin de l'œil, en parcourant le fil.
  /// C'est ce que font toutes les messageries de groupe, et c'est ce qui
  /// permet de suivre un échange à trois sans relire chaque en-tête.
  ///
  /// La couleur est TIRÉE DE L'IDENTIFIANT, pas d'un compteur : le même
  /// contact garde donc la sienne d'une session à l'autre, sur tous les
  /// appareils, sans que rien n'ait à être stocké ni synchronisé. Deux
  /// personnes peuvent tomber sur la même teinte — c'est sans gravité,
  /// le nom reste écrit à côté.
  ///
  /// Les huit teintes sont choisies pour rester lisibles sur les deux
  /// fonds, clair et sombre : ni pastel (invisible en clair), ni
  /// saturé-sombre (illisible en sombre).
  static const List<Color> _senderPalette = [
    Color(0xFF34AADC), // azur
    Color(0xFF30C07B), // menthe
    Color(0xFFFF9F0A), // ambre
    Color(0xFFFF6482), // corail
    Color(0xFFAF8CFF), // lavande
    Color(0xFF2ECAD5), // turquoise
    Color(0xFFFFB340), // miel
    Color(0xFF7D8CFF), // indigo
  ];

  static Color _senderColor(String id) {
    // Somme des unités de la chaîne : stable, sans dépendance, et bien
    // assez dispersée pour huit cases.
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return _senderPalette[hash % _senderPalette.length];
  }

  Widget _quoteBlock(AppLocalizations l10n, MeshMessage replied) {
    // ⚠️ `PollMessage.describe`/`LocationMessage.describe` D'ABORD.
    //
    // Répondre à un sondage ou à une position partagée sans ce
    // traitement citerait le contenu tel qu'il voyage sur le réseau —
    // un bloc JSON brut pour un sondage, des coordonnées pour une
    // position. Même résumé que celui déjà utilisé dans la liste des
    // conversations (`_describeForPreview`).
    final snippet = replied.type == 'file'
        ? VoiceNoteMeta.describeAttachment(replied.fileName)
        : isStickerMessage(replied.content)
            ? l10n.chStickerPreview
            : LocationMessage.describe(PollMessage.describe(replied.content));
    final truncated = snippet.length > 80
        ? '${snippet.substring(0, 80)}…'
        : snippet;
    final accent = mine ? OuroColors.bubbleOutgoingText : OuroColors.meshBlueBright;
    // ⚠️ LA CITATION EST UN LIEN, PAS UNE VIGNETTE.
    //
    // Une réponse n'a de sens qu'avec ce à quoi elle répond. Toutes les
    // messageries font remonter à l'original d'un appui sur le bloc
    // cité ; sans cela, il faut faire défiler à l'aveugle en espérant le
    // reconnaître.
    return GestureDetector(
      onTap: onOpenReplied == null
          ? null
          : () {
              OuroHaptics.light();
              onOpenReplied!();
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (mine ? OuroColors.bubbleOutgoingText : OuroColors.meshBlue).withValues(
            alpha: 0.16,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    // ⚠️ On affichait « Vous » dès que l'auteur cité différait
                    // de celui de la bulle — donc au-dessus des messages de
                    // L'AUTRE personne. En groupe, un tiers n'est jamais « Vous ».
                    _citationDeMoi(replied) ? l10n.mpYou : replied.authorPseudo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    truncated,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: mine ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7) : OuroColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// L'heure, et pour mes propres messages le statut, en pied de bulle.
  ///
  /// ⚠️ L'HEURE EST SECONDAIRE, ET DOIT LE RESTER. La version précédente
  /// écrivait « Lu 12:54 » en gras et en bleu vif dès que le message
  /// était lu : la mention pesait alors visuellement plus lourd que la
  /// phrase envoyée. Ici l'heure garde toujours le même poids ; c'est la
  /// petite icône à côté qui porte l'information de statut.
  /// Ce que fait un appui sur l'heure d'un message.
  ///
  /// Sur un message en échec : on le renvoie. Sur tous les autres : on
  /// ouvre le détail de la transmission. Le même endroit, deux actions —
  /// parce que sur un message échoué, personne ne cherche à lire par où
  /// il est passé : il n'est passé nulle part.
  VoidCallback _actionSurLHeure(BuildContext context) {
    final renvoi = onRenvoyer;
    if (message.status == MessageStatus.failed && renvoi != null) {
      return renvoi;
    }
    return () => showTransmissionSheet(context, message, mine: mine);
  }

  String _libelleDeLHeure(AppLocalizations l10n) =>
      message.status == MessageStatus.failed && onRenvoyer != null
      ? l10n.chRetrySendLabel
      : l10n.chTransmissionDetailsLabel;

  /// L'heure et les coches posées sur une photo ou une vidéo.
  Widget _heureSurMedia(BuildContext context, AppLocalizations l10n) =>
      _TapCible(
        marge: EdgeInsets.zero,
        onTap: _actionSurLHeure(context),
        semantique: _libelleDeLHeure(l10n),
        child: _timeAndStatus(l10n, surMedia: true),
      );

  Widget _timeAndStatus(AppLocalizations l10n, {bool surMedia = false}) {
    return ValueListenableBuilder<int>(
      valueListenable: MessagesImportants.revision,
      builder: (context, _, heure) => MessagesImportants.estImportant(message.id)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: surMedia
                      ? Colors.white
                      : (mine ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7) : OuroColors.textTertiary),
                ),
                const SizedBox(width: 3),
                heure!,
              ],
            )
          : heure!,
      child: _heureEtEtat(l10n, surMedia: surMedia),
    );
  }

  Widget _heureEtEtat(AppLocalizations l10n, {bool surMedia = false}) {
    final read = message.readAt != null;
    // Sur une image, la pastille est sombre : tout en blanc, sauf le « lu »
    // (bleu) et l'échec (rouge) qui doivent rester reconnaissables.
    final couleurStatut =
        surMedia && message.status != MessageStatus.failed && !read
        ? Colors.white
        : _statusColor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (epingle) ...[
          Icon(
            Icons.push_pin_rounded,
            size: 11,
            color: surMedia
                ? Colors.white
                : (mine
                    ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
                    : OuroColors.textSecondary),
          ),
          const SizedBox(width: 2),
        ],
        Text(
          _formatTime(message.timestamp),
          style: TextStyle(
            fontSize: 11,
            // Reçu : gris secondaire (60 %) et non tertiaire (30 %) — à
            // 30 %, l'heure disparaissait sur la bulle.
            color: surMedia
                ? Colors.white
                : (mine ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7) : OuroColors.textSecondary),
          ),
        ),
        // Badge « modifié » — iMessage affiche « Edited » en gris à côté
        // de l'heure quand un message a été modifié.
        if (message.editedAt != null) ...[
          const SizedBox(width: 3),
          Text(
            l10n.chEditedBadge,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: mine
                  ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.5)
                  : OuroColors.textTertiary,
            ),
          ),
        ],
        // Icône d'auto-destruction — petit sablier à côté de l'heure.
        if (message.expiresInSeconds != null) ...[
          const SizedBox(width: 3),
          Icon(
            Icons.timer_off_rounded,
            size: 10,
            color: mine
                ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.5)
                : OuroColors.textTertiary,
          ),
        ],
        // Indicateur de fil — nombre de réponses dans le thread.
        if (threadCount > 0) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onOpenThread,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: (mine ? OuroColors.bubbleOutgoingText : OuroColors.meshBlueBright)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_rounded,
                    size: 9,
                    color: mine
                        ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
                        : OuroColors.meshBlueBright,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$threadCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: mine
                          ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
                          : OuroColors.meshBlueBright,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (mine) ...[
          const SizedBox(width: 4),
          // iMessage : "Delivered"/"Read" crossfade in 0.2s
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: couleurStatut),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            // La coche qui change (une → deux) apparaît avec un petit rebond,
            // comme chez WhatsApp : on VOIT le message arriver.
            builder: (context, color, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (enfant, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: enfant),
              ),
              child: Icon(
                _statusIconData(read),
                key: ValueKey(_statusIconData(read)),
                // 15 et non 13 : à 13 points, une coche et deux coches
                // se confondaient à bout de bras.
                size: 15,
                color: color ?? couleurStatut,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Le poids d'un fichier, écrit comme on le lit.
  ///
  /// Renvoie « Fichier » quand la taille est inconnue plutôt que « 0 o » :
  /// annoncer un fichier vide alors qu'on ne sait simplement pas
  /// tromperait sur ce qui va être transféré.
  static String _poidsLisible(AppLocalizations l10n, int? octets) {
    if (octets == null || octets <= 0) return l10n.chFileWord;
    if (octets < 1024) return l10n.chSizeBytes(octets);
    if (octets < 1024 * 1024) {
      return l10n.chSizeKb((octets / 1024).toStringAsFixed(0));
    }
    return l10n.chSizeMb(
      (octets / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ','),
    );
  }

  IconData _fileIconFor(String? mimeType) {
    if (mimeType == null) return Icons.attach_file_rounded;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_rounded;
    if (mimeType.startsWith('audio')) return Icons.audiotrack_rounded;
    if (mimeType.startsWith('video')) return Icons.videocam_rounded;
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  /// Vrai quand ce message est un sticker : uniquement des emojis, trois
  /// au maximum. Il s'affiche alors en grand et SANS bulle.
  /// Le message cité est-il le mien ?
  bool _citationDeMoi(MeshMessage replied) => mine
      ? replied.senderId == message.senderId
      : message.groupId == null && replied.senderId != message.senderId;

  bool get _isSticker =>
      message.type != 'file' && isStickerMessage(_contenuVisible);

  /// Ce message prolonge celui du dessus (même auteur, même moment).
  ///
  /// Il se colle alors au précédent et n'affiche plus le nom de son
  /// auteur : dans un groupe, le répéter à chaque bulle d'une même
  /// tirade rend le fil illisible.
  final bool suiteDuPrecedent;

  /// Épinglé : une petite punaise devant l'heure, comme WhatsApp — on
  /// retrouve d'un coup d'œil, en remontant, le message que la barre du
  /// haut désigne.
  final bool epingle;

  /// Ce message termine une série.
  ///
  /// Seule la dernière bulle d'une série porte le coin pointu qui
  /// désigne le locuteur — un empilement de bulles toutes pointues
  /// ressemble à une dentelure, pas à une conversation.
  final bool finDeSerie;

  /// Vrai quand ce message est une référence de sticker animé.
  bool get _isAnimatedSticker =>
      message.type != 'file' &&
      AnimatedStickerCatalog.estUneReference(_contenuVisible);

  /// Ce message est-il assez court pour loger l'heure à côté du texte ?
  ///
  /// Le seuil est volontairement bas. Le but n'est pas de gagner de la
  /// place à tout prix, mais d'éviter la bulle minuscule et disgracieuse
  /// des messages d'un ou deux mots. Dès qu'il y a une pièce jointe, une
  /// citation ou une réaction, l'empilement reste le bon choix : l'heure
  /// n'a plus d'espace libre où se glisser.
  /// Le statut auquel ce message répond (`statut:<id>`), ou `null`.
  String? get _idStatutCite {
    final r = message.replyToId;
    return (r != null && r.startsWith('statut:')) ? r.substring(7) : null;
  }

  bool get _heureSurLaMemeLigne =>
      _idStatutCite == null &&
      message.type != 'file' &&
      !_sansBulle &&
      repliedMessage == null &&
      // Les réactions ne comptent plus : elles vivent hors de la bulle.
      message.effect != kEffectInvisibleInk &&
      _contenuVisible.length <= 22 &&
      !_contenuVisible.contains('\n');

  /// Les stickers — animés comme en emoji — sont posés à même la
  /// conversation, sans bulle autour. C'est ce qui les distingue d'un
  /// emoji tapé dans une phrase.
  /// Ouvre un document reçu. Un PDF se lit DANS Droplet : sortir de l'app
  /// pour lire une pièce jointe, c'est perdre sa place et confier le
  /// fichier à un lecteur qui ne sait rien de notre promesse.
  Future<void> _ouvrirDocument(BuildContext context) async {
    final nom = message.fileName ?? '';
    if (!nom.toLowerCase().endsWith('.pdf')) return;
    final chemin = await StorageService.getSharedFilePath(
      message.fileId ?? '',
      nom,
    );
    if (!context.mounted) return;
    if (chemin == null) {
      afficherToast(
        context,
        AppLocalizations.of(context).pdfMissing,
        type: DropletToastType.warning,
      );
      return;
    }
    OuroHaptics.light();
    await ouvrirPdf(context, chemin, titre: nom);
  }

  /// Le texte tel qu'on le montre : sans la marque des éphémères, qui ne
  /// regarde que le minuteur.
  String get _contenuVisible => Ephemeres.sansMarque(message.content);

  /// ⚠️ LA VIDÉO RONDE AUSSI EST SANS BULLE. Un disque posé dans un
  /// rectangle arrondi laisse quatre coins vides autour de lui, et
  /// l'ensemble se lit comme une image mal découpée. Comme le sticker,
  /// elle se pose à même la conversation.
  bool get _sansBulle => _isSticker || _isAnimatedSticker || _estVideoRonde;

  /// Une vidéo ronde se reconnaît à son nom de fichier.
  ///
  /// ⚠️ PAS AU TYPE DU MESSAGE, et ce n'est pas un contournement : le
  /// `type` ne traverse pas `sendFile`, qui pose « file » pour tout. Le
  /// nom, lui, voyage tel quel — c'est déjà par là que passent la durée
  /// et la forme d'onde d'un vocal.
  bool get _estVideoRonde =>
      message.type == 'file' &&
      (message.fileName ?? '').contains('.$kTypeVideoRonde.');

  /// Une photo ou une vidéo à voir une seule fois (voir `vue_unique.dart`).
  bool get _vueUnique =>
      message.type == 'file' && VueUnique.marquee(_contenuVisible);

  /// La ligne d'une vue unique : la pastille « 1 », ce que c'est, et
  /// l'heure. Rien du média n'est montré tant qu'on ne touche pas.
  Widget _contenuVueUnique(BuildContext context, AppLocalizations l10n) {
    final couleur = mine ? OuroColors.bubbleOutgoingText : OuroColors.accent;
    return ValueListenableBuilder<int>(
      valueListenable: VueUnique.revision,
      builder: (context, _, _) {
        // Celui qui envoie ne rouvre pas non plus : c'est la règle de la
        // vue unique, sinon elle ne promet rien.
        final ouverte = mine || VueUnique.ouverte(message.id);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: ouverte ? null : () => _ouvrirVueUnique(context, l10n),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PastilleVueUnique(couleur: couleur, ouverte: ouverte),
                if (VoiceNoteMeta.isVoiceNote(message.fileName)) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.mic_rounded,
                    size: 18,
                    color: couleur.withValues(alpha: ouverte ? 0.5 : 0.9),
                  ),
                ],
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ouverte ? l10n.vuOpened : l10n.vuOnce,
                      style: OuroTypography.subheadline.copyWith(
                        color: couleur.withValues(alpha: ouverte ? 0.6 : 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      VoiceNoteMeta.isVoiceNote(message.fileName)
                          ? l10n.vuVoice
                          : (isVideo ? l10n.vuVideo : l10n.vuPhoto),
                      style: OuroTypography.footnote.copyWith(
                        color: couleur.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                _timeAndStatus(l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _ouvrirVueUnique(BuildContext context, AppLocalizations l10n) async {
    final id = message.fileId;
    final nom = message.fileName;
    final chemin = id == null || nom == null
        ? null
        : await StorageService.getSharedFilePath(id, nom);
    if (!context.mounted) return;
    if (chemin == null || !File(chemin).existsSync()) {
      afficherToast(context, l10n.vuMissing, type: DropletToastType.warning);
      return;
    }
    OuroHaptics.light();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) {
          final meta = VoiceNoteMeta.tryParse(message.fileName);
          return EcranVueUnique(
            chemin: chemin,
            video: isVideo,
            idMessage: message.id,
            vocal: meta != null,
            onde: meta?.waveform ?? const [],
            duree: meta?.duration,
          );
        },
      ),
    );
  }

  Widget _textBubble(AppLocalizations l10n, bool isFile) {
    // Un sondage devient une carte interactive. Sans ça, il s'afficherait
    // tel qu'il voyage — un bloc JSON brut — illisible et impossible à
    // remplir. Vérifié AVANT la position : les deux encodages ont chacun
    // leur préfixe propre, mais autant tester le plus structuré d'abord.
    final poll = PollMessage.tryParse(_contenuVisible);
    if (poll != null) {
      return PollBubble(message: message, poll: poll, mine: mine);
    }
    // Une position partagée devient une carte miniature. Sans ça, elle
    // s'afficherait telle qu'elle voyage — « 📍loc:3.848212,11.502341 » —
    // c'est-à-dire illisible.
    final location = LocationMessage.tryParse(_contenuVisible);
    if (location != null) {
      return LocationBubble(
        location: location,
        mine: mine,
        onOpen: onOpenLocation ?? () {},
      );
    }
    // ── LA VIDÉO RONDE ────────────────────────────────────────────
    //
    // ⚠️ AVANT LE TEST DE VUE UNIQUE ? NON — APRÈS, et c'est important :
    // une vidéo ronde en vue unique doit d'abord se présenter comme une
    // vue unique, sans rien montrer. Ce test-ci est placé plus bas dans
    // la méthode, où la vue unique a déjà pris la main.
    if (_estVideoRonde) {
      return FutureBuilder<String?>(
        future: StorageService.getSharedFilePath(
          message.fileId ?? '',
          message.fileName ?? '',
        ),
        builder: (context, instantane) {
          final chemin = instantane.data;
          if (chemin == null) {
            // Le fichier n'est pas encore arrivé — il voyage peut-être
            // encore de téléphone en téléphone. Un disque vide, pas un
            // message d'erreur : il finira par se remplir.
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: OuroColors.tertiarySystemFill,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const OuroSpinner(radius: 10),
            );
          }
          return BulleVideoRonde(chemin: chemin);
        },
      );
    }
    // Un sticker ANIMÉ : le message ne porte que sa référence, jamais
    // le fichier. L'animation est jouée depuis les assets locaux — et si
    // ce sticker manque sur cet appareil, `AnimatedStickerView` affiche
    // un repli lisible plutôt qu'un carré vide.
    if (_isAnimatedSticker) {
      // 104 et non 132 : à l'écran, un sticker de 132 points écrasait
      // complètement les bulles de texte voisines, au point de
      // déséquilibrer la lecture du fil. C'est la taille que retiennent
      // aussi WhatsApp et Telegram.
      return AnimatedStickerView(reference: _contenuVisible, taille: 104);
    }
    if (_isSticker) {
      return Text(
        _contenuVisible,
        style: TextStyle(
          fontSize: stickerFontSize(_contenuVisible),
          height: 1.0,
        ),
      );
    }
    // ── LINK PREVIEW ──────────────────────────────────────────────
    //
    // Quand le message contient une URL, on l'affiche dans une carte
    // stylisée plutôt qu'en texte brut. Sur un mesh sans internet, on
    // ne peut pas fetch le metadata — mais on peut au moins afficher
    // le domaine et un icône correspondant.
    final urlMatch = _extractUrl(_contenuVisible);
    if (urlMatch != null) {
      return _LinkPreviewCard(
        url: urlMatch,
        fullText: _contenuVisible,
        mine: mine,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isFile) ...[
          // Une pastille carrée plutôt qu'une icône nue : elle donne au
          // fichier le poids d'une pièce jointe, là où la petite icône
          // grise se confondait avec la ponctuation du texte.
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (mine ? OuroColors.bubbleOutgoingText : OuroColors.accent).withValues(
                alpha: mine ? 0.20 : 0.14,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            // `Builder` : cette portion est construite hors d'un `build`,
            // il n'y a donc pas de `context` sous la main.
            child: Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _ouvrirDocument(context),
                child: Icon(
                  _fileIconFor(message.fileMimeType),
                  color: mine ? OuroColors.bubbleOutgoingText : OuroColors.accent,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
        ],
        // Un fichier montre son nom ET son poids. « 2,4 Mo » répond à
        // la question qu'on se pose vraiment devant une pièce jointe sur
        // un réseau maillé : est-ce que ça va passer, et en combien de
        // temps.
        if (isFile)
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _highlighted(
                  // Bulle « réception en cours » d'un fichier en morceaux :
                  // son nom est encore dans l'enveloppe chiffrée.
                  _contenuVisible.isEmpty
                      ? l10n.chMediaReceiving
                      : _contenuVisible,
                  TextStyle(
                    color: mine ? OuroColors.bubbleOutgoingText : OuroColors.textPrimary,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  progression != null
                      ? '${(progression! * 100).floor()} % · ${_poidsLisible(l10n, message.fileSize)}'
                      : _poidsLisible(l10n, message.fileSize),
                  style: TextStyle(
                    fontSize: 11,
                    color: mine ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7) : OuroColors.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (progression != null) ...[
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progression,
                        minHeight: 3,
                        backgroundColor:
                            (mine ? OuroColors.bubbleOutgoingText : OuroColors.accent)
                                .withValues(alpha: 0.18),
                        valueColor: AlwaysStoppedAnimation(
                          mine ? OuroColors.bubbleOutgoingText : OuroColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Flexible(
            child: BaliseEnvoi(
              role: RoleBalise.texte,
              child: _expandableTextContent(),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Contenu textuel du bulle : utilise `_ExpandableText` pour les
  /// messages longs (>100 caractères) et `_highlighted` pour la
  /// recherche active.
  Widget _expandableTextContent() {
    final contenu = _contenuTexte();
    if (traduction == null && !traductionEnCours) return contenu;
    final encre = mine ? OuroColors.bubbleOutgoingText : OuroColors.textPrimary;
    // ── LA TRADUCTION SOUS L'ORIGINAL ───────────────────────────────
    //
    // Telegram garde le message d'origine visible et pose la traduction
    // en dessous, séparée d'un filet : on doit pouvoir comparer les deux
    // sans rien rouvrir, parce qu'une traduction automatique se relit
    // toujours avec le doute.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        contenu,
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 2),
          child: Container(height: 0.5, color: encre.withValues(alpha: 0.25)),
        ),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            if (traductionEnCours) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n.msgTranslate}…',
                  style: TextStyle(
                    fontSize: 12,
                    color: encre.withValues(alpha: 0.6),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.msgTranslatedFrom,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: encre.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  traduction!,
                  style: TextStyle(
                    color: encre,
                    fontSize: ReglagesApparence.tailleTexte,
                    height: ReglagesApparence.interligne,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _contenuTexte() {
    // La taille choisie dans « Apparence » (15 par défaut).
    final style = TextStyle(
      color: mine ? OuroColors.bubbleOutgoingText : OuroColors.textPrimary,
      fontSize: ReglagesApparence.tailleTexte,
      height: ReglagesApparence.interligne,
    );

    // En recherche active, on garde le surlignage classique.
    if (query.isNotEmpty) {
      return _highlighted(_contenuVisible, style);
    }

    // Messages courts ou multimedia : pas de troncature.
    if (_contenuVisible.length <= _kExpandThreshold) {
      return _highlighted(_contenuVisible, style);
    }

    return _ExpandableText(text: _contenuVisible, style: style);
  }

  /// Le texte du message, avec les occurrences recherchées surlignées.
  ///
  /// ⚠️ ON NE SURLIGNE QU'EN RECHERCHE ACTIVE. Hors recherche, [query]
  /// est vide et la méthode rend un `Text` ordinaire — pas de découpage
  /// de chaîne ni de `RichText` à construire pour chaque bulle de
  /// l'historique.
  ///
  /// La comparaison se fait en minuscules sur une copie, mais les
  /// morceaux affichés sont TAILLÉS DANS L'ORIGINAL : surligner
  /// « bonjour » ne doit pas transformer « Bonjour » en minuscules à
  /// l'écran.
  Widget _highlighted(String text, TextStyle style) {
    // ── LA MISE EN FORME ─────────────────────────────────────────
    //
    // `**gras**`, `` `code` ``, `||spoiler||`… : les marqueurs écrits par
    // l'expéditeur (voir `mise_en_forme.dart`). LIRE est gratuit — un
    // message reçu s'affiche mis en forme même sans le pack, sinon on
    // punirait le lecteur pour ce que l'auteur a écrit.
    if (MiseEnForme.contientDuStyle(text)) {
      // Les spoilers sont ceux de Telegram : une poussière qui épouse les
      // lignes cachées et se dissout en cercle sous le doigt (voir
      // `texte_mis_en_forme.dart`).
      return TexteMisEnForme(
        texte: text,
        style: style,
        brut: (morceau, styleMorceau) =>
            _fragmentsSurlignes(morceau, styleMorceau),
      );
    }
    if (query.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lower.indexOf(query, start);
      if (index < 0) break;
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            // Sur une bulle bleue, un surlignage bleu serait invisible :
            // on prend un fond jaune ambré et un texte noir, lisibles quel
            // que soit le côté de la conversation.
            backgroundColor: OuroColors.warningAmber.withValues(alpha: 0.55),
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = index + query.length;
    }

    if (spans.isEmpty) return Text(text, style: style);
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }

  /// Le surlignage de la recherche, appliqué à un fragment déjà mis en
  /// forme : la recherche doit fonctionner DANS un passage en gras.
  List<InlineSpan> _fragmentsSurlignes(String texte, TextStyle style) {
    if (query.isEmpty) return [TextSpan(text: texte, style: style)];
    final bas = texte.toLowerCase();
    final spans = <InlineSpan>[];
    var debut = 0;
    while (true) {
      final i = bas.indexOf(query, debut);
      if (i < 0) break;
      if (i > debut) {
        spans.add(TextSpan(text: texte.substring(debut, i), style: style));
      }
      spans.add(TextSpan(
        text: texte.substring(i, i + query.length),
        style: style.copyWith(
          backgroundColor: OuroColors.warningAmber.withValues(alpha: 0.55),
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ));
      debut = i + query.length;
    }
    if (debut < texte.length) {
      spans.add(TextSpan(text: texte.substring(debut), style: style));
    }
    return spans;
  }

  /// La bulle, et ses réactions posées À CHEVAL sur son bord inférieur.
  ///
  /// ⚠️ ELLES ÉTAIENT DANS LA BULLE, entre le texte et l'heure : un « Yo »
  /// avec un cœur devenait une colonne de trois étages, plus haute que
  /// large, qui ne ressemblait plus à un message. WhatsApp, iMessage et
  /// Telegram posent la réaction sur une petite pastille qui mord sur le
  /// bord de la bulle : la bulle garde sa taille, la réaction se lit comme
  /// un AJOUT et non comme une partie du message.
  ///
  /// La place est réservée sous la bulle pour que la pastille ne chevauche
  /// pas le message suivant.
  static const double _debordReaction = 16;

  Widget _avecReactions(Widget bulle) {
    // ⚠️ LA STRUCTURE RESTE LA MÊME SANS RÉACTION. Si la bulle nue était
    // rendue seule, la PREMIÈRE réaction créerait la pastille de toutes
    // pièces — et un widget qui vient de naître ne sait pas qu'il doit
    // rebondir (voir `_RebondReaction`). La place sous la bulle s'ouvre
    // en douceur au lieu de sauter.
    final vide = message.reactions.isEmpty;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: vide ? 0 : _debordReaction),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          bulle,
          Positioned(
            bottom: -_debordReaction - 2,
            // Du côté opposé à la queue, en retrait du coin arrondi.
            left: mine ? 10 : null,
            right: mine ? null : 10,
            child: _RebondReaction(
              signature: message.reactions.join(),
              child: vide ? const SizedBox.shrink() : _pastilleReactions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastilleReactions() {
    // Les émojis distincts, dans l'ordre d'arrivée, et le total s'il y en
    // a plusieurs — « ❤️👍 3 », comme WhatsApp.
    final distincts = <String>[];
    for (final r in message.reactions) {
      if (!distincts.contains(r)) distincts.add(r);
    }
    final total = message.reactions.length;
    return Container(
      key: ValueKey('${message.id}-${message.reactions.join()}'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OuroColors.bubbleIncoming,
        borderRadius: BorderRadius.circular(14),
        // Le liseré de la couleur du fond détache la pastille de la bulle
        // qu'elle chevauche — sans lui, sur une bulle de même teinte, elle
        // se fondrait dedans.
        border: Border.all(color: OuroColors.systemBackground, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.3 : 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in distincts.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(r, style: const TextStyle(fontSize: 14, height: 1.2)),
            ),
          if (total > 1)
            Padding(
              padding: const EdgeInsets.only(left: 3, right: 1),
              child: Text(
                '$total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: OuroColors.secondaryLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _audioBubble() {
    return VoiceNoteBubble(
      meta: VoiceNoteMeta.tryParse(message.fileName),
      fileSize: message.fileSize,
      mine: mine,
      playing: playingAudio,
      progress: playbackProgress,
      position: playbackPosition,
      speed: playbackSpeed,
      played: voicePlayed,
      onPlayPause: onPlayAudio,
      onSeek: onSeekAudio ?? (_) {},
      onCycleSpeed: onCycleSpeed ?? () {},
      onVoiceReply: onVoiceReply,
      transcription: transcription,
      transcriptionEnCours: transcriptionEnCours,
      onTranscrire: onTranscrire,
      transitionVocale: transitionVocale,
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// L'icône qui résume où en est ce message.
  ///
  /// ⚠️ CHAQUE ÉTAT CORRESPOND À UNE DONNÉE RÉELLE, aucun n'est décoratif :
  ///
  ///   • `sending` / `pending` — le message attend son tour dans la file.
  ///   • `sent` + `hopCount > 0` — il est parti, mais PAS en direct : il a
  ///     traversé au moins un appareil intermédiaire. C'est la
  ///     particularité de Droplet, et la seule application qui puisse
  ///     l'afficher honnêtement.
  ///   • `sent` seul — parti en liaison directe, sans accusé pour
  ///     l'instant.
  ///   • `deliveryCount > 0` — au moins un accusé de réception est
  ///     revenu.
  ///   • `readAt != null` — le destinataire a ouvert la conversation.
  ///   • `failed` — plus aucune route, après épuisement des tentatives.
  ///
  /// On n'invente donc pas d'état « en cours de relais » qu'aucune donnée
  /// ne viendrait soutenir.
  /// Ouvre la photo dans la galerie de la conversation.
  final void Function(String chemin, Size? forme)? onOuvrirPhoto;

  /// Annule l'envoi d'une photo ou d'une vidéo encore en route.
  final VoidCallback? onAnnulerEnvoi;

  /// La légende écrite avec la photo (elle prend la place du nom de fichier
  /// dans le contenu du message), ou `null` quand il n'y en a pas.
  String? get _legendeMedia {
    final texte = _contenuVisible.trim();
    if (message.type != 'file' || texte.isEmpty || texte == message.fileName) {
      return null;
    }
    return texte;
  }

  /// Deux coches grises : reçu. Dans un groupe, reçu par TOUS les membres.
  bool get _distribue {
    if (message.deliveryCount <= 0) return false;
    final groupe = message.groupId;
    if (groupe == null) return true;
    final attendus =
        StorageService.getGroup(
          groupe,
        )?.activeMembers.where((m) => m.peerId != message.senderId).length ??
        1;
    return message.deliveryCount >= attendus;
  }

  IconData _statusIconData(bool read) {
    return switch (message.status) {
      MessageStatus.sending || MessageStatus.pending => Icons.schedule_rounded,
      MessageStatus.failed => Icons.error_outline_rounded,
      MessageStatus.sent when read || _distribue => Icons.done_all_rounded,
      MessageStatus.sent => Icons.done_rounded,
    };
  }

  /// La couleur de fond de la bulle modulée par l'état du réseau.
  ///
  /// Quand le mesh est en transit (sending/pending), la bulle devient
  /// légèrement matte — l'utilisateur sent que le message est « en vol ».
  /// En cas d'échec, elle s'estompe pour signaler le problème sans cri.
  /// Quand le message est livré ou lu, la bulle est pleinement brillante.
  Color _bubbleColorForState({
    required bool mine,
    required MessageStatus status,
  }) {
    // ⚠️ REÇU EN CLAIR : BLANC, PAS GRIS. Le gris d'iMessage (#E9E9EB) est
    // pensé pour un fond BLANC. Posé sur le dégradé coloré de la
    // conversation, il se fondait dedans : les bulles reçues paraissaient
    // délavées et leurs heures se lisaient mal. Sur un fond d'écran, c'est
    // le blanc qui détache — le choix de WhatsApp.
    final base = mine
        ? OuroColors.bubbleOutgoing
        : (OuroColors.isDark ? OuroColors.bubbleIncoming : Colors.white);
    return switch (status) {
      MessageStatus.sending || MessageStatus.pending => base.withValues(
        alpha: 0.85,
      ), // matte — en transit
      MessageStatus.failed => base.withValues(
        alpha: 0.55,
      ), // translucide — problème
      MessageStatus.sent => base, // plein — livré ou en attente d'ACK
    };
  }

  /// La couleur du statut.
  ///
  /// ⚠️ TOUT EST DISCRET SAUF DEUX CAS. L'ancienne version peignait
  /// l'attente en orange vif et l'envoi en vert vif : sur un fil de
  /// conversation, cela faisait une colonne de pastilles colorées qui
  /// captait le regard avant le texte. Or « envoyé » est l'état NORMAL
  /// de presque tous les messages — le signaler en couleur, c'est
  /// alerter en permanence sur ce qui va bien.
  ///
  /// Ne restent colorés que les deux états qui demandent vraiment
  /// quelque chose à l'utilisateur : l'échec (rouge, il faut agir) et la
  /// lecture (bleu Droplet, l'information qu'on attendait).
  ///
  /// ⚠️ SUR MES BULLES, PAS DE COULEUR D'ACCENT. « Lu » était peint en
  /// `meshBlueBright`… qui vaut l'accent, c'est-à-dire la couleur même de
  /// la bulle : les coches de lecture étaient rouges sur rouge, donc
  /// invisibles, et « lu » ne se distinguait plus de « reçu ». Même
  /// défaut pour l'échec, rouge sur rouge.
  ///
  /// Sur la bulle colorée, c'est l'INTENSITÉ qui parle : blanc plein pour
  /// « lu », blanc voilé pour le reste — la convention de Telegram, lisible
  /// sur n'importe quel accent. L'échec garde son icône, qui suffit.
  Color _statusColor() {
    if (mine) {
      final encre = OuroColors.bubbleOutgoingText;
      if (message.status == MessageStatus.failed) return encre;
      return message.readAt != null ? encre : encre.withValues(alpha: 0.58);
    }
    if (message.status == MessageStatus.failed) return OuroColors.errorRed;
    if (message.readAt != null) return OuroColors.meshBlueBright;
    return OuroColors.textTertiary;
  }
}

/// Extrait la première URL du texte. Retourne null si aucune URL n'est trouvée.
///
/// Sur un mesh sans internet, on ne peut pas fetch le metadata complet —
/// mais on peut détecter les URLs et afficher le domaine stylisé.
Uri? _extractUrl(String text) {
  final urlPattern = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );
  final match = urlPattern.firstMatch(text);
  if (match != null) {
    return Uri.tryParse(match.group(0)!);
  }
  return null;
}

/// Carte de preview pour les URLs dans les messages.
///
/// Sur un mesh sans internet, on affiche le domaine et un icône
/// correspondant au type de contenu. C'est plus lisible qu'une URL brute.
class _LinkPreviewCard extends StatefulWidget {
  const _LinkPreviewCard({
    required this.url,
    required this.fullText,
    required this.mine,
  });

  final Uri url;
  final String fullText;
  final bool mine;

  @override
  State<_LinkPreviewCard> createState() => _LinkPreviewCardState();
}

/// Le lien d'un message, comme chez Telegram : l'adresse en couleur,
/// touchable, puis un aperçu à liseré — nom du site, titre, description,
/// image. Un toucher l'ouvre dans l'app, un appui long propose les actions.
///
/// L'aperçu complet n'est chargé que si « En ligne quand je suis connecté »
/// est activé (voir `apercus_liens.dart`) : sinon il se limite au domaine,
/// et rien ne sort du téléphone.
class _LinkPreviewCardState extends State<_LinkPreviewCard> {
  late Future<ApercuLien?> _apercu = ApercusLiens.charger(widget.url);
  bool _appui = false;

  @override
  void didUpdateWidget(_LinkPreviewCard ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.url != widget.url) _apercu = ApercusLiens.charger(widget.url);
  }

  static IconData _icone(String hote) {
    if (hote.contains('youtube.com') || hote.contains('youtu.be')) return Icons.play_circle_fill;
    if (hote.contains('github.com')) return Icons.code;
    if (hote.contains('twitter.com') || hote.contains('x.com')) return Icons.chat_bubble;
    if (hote.contains('instagram.com')) return Icons.camera_alt;
    if (hote.contains('tiktok.com')) return Icons.music_note;
    if (hote.contains('reddit.com')) return Icons.forum;
    return Icons.language;
  }

  void _ouvrir() => ouvrirLienDansApp(context, widget.url.toString());
  void _actions() => proposerActionsLien(context, widget.url);

  @override
  Widget build(BuildContext context) {
    // Les couleurs suivent celles de la bulle : texte clair sur une bulle
    // colorée (les miennes), couleur d'accent sur une bulle claire.
    final base = DefaultTextStyle.of(context).style.color ?? OuroColors.label;
    final clair = base.computeLuminance() > 0.6;
    final accent = clair ? base : OuroColors.accent;
    final secondaire = base.withValues(alpha: 0.72);
    final texte = widget.fullText.replaceAll(widget.url.toString(), '').trim();
    final hote = widget.url.host.replaceFirst(RegExp(r'^www\.'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (texte.isNotEmpty) ...[
          SelectableText(texte, style: TextStyle(color: base, fontSize: 15.5)),
          const SizedBox(height: 4),
        ],
        // L'adresse elle-même, visible et touchable.
        GestureDetector(
          onTap: _ouvrir,
          onLongPress: _actions,
          child: Text(
            widget.url.toString(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 15.5,
              decoration: TextDecoration.underline,
              decorationColor: accent.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FutureBuilder<ApercuLien?>(
          future: _apercu,
          initialData: ApercusLiens.enMemoire(widget.url),
          builder: (context, instantane) {
            final a = instantane.data;
            return GestureDetector(
              onTap: _ouvrir,
              onLongPress: _actions,
              onTapDown: (_) => setState(() => _appui = true),
              onTapUp: (_) => setState(() => _appui = false),
              onTapCancel: () => setState(() => _appui = false),
              child: AnimatedOpacity(
                opacity: _appui ? 0.6 : 1,
                duration: Duration(milliseconds: _appui ? 0 : 200),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: clair ? 0.14 : 0.08),
                        border: Border(left: BorderSide(color: accent, width: 3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(9, 7, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_icone(hote), size: 13, color: accent),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    a?.site ?? hote,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (a?.titre != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                a!.titre!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: base,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                            if (a?.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                a!.description!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: secondaire, fontSize: 13.5, height: 1.3),
                              ),
                            ],
                            if (a?.image != null) ...[
                              const SizedBox(height: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 160),
                                  child: Image.network(
                                    a!.image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                            if (a == null) ...[
                              const SizedBox(height: 1),
                              Text(
                                widget.url.path.length > 1
                                    ? '${widget.url.host}${widget.url.path}'
                                    : widget.url.host,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: secondaire, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Vignette d'une VIDÉO partagée, avec lecture en plein écran au tap.
///
/// La vignette est la PREMIÈRE IMAGE de la vidéo, extraite à
/// l'affichage. C'est ce qui distingue une vidéo reçue d'un fichier
/// anonyme : on voit tout de suite de quoi il s'agit, sans avoir à
/// l'ouvrir.
class _VideoBubble extends StatefulWidget {
  const _VideoBubble({
    required this.fileId,
    required this.fileName,
    this.progression,
    this.heure,
    this.onAnnuler,
  });

  final String fileId;
  final String fileName;

  /// Avancement du transfert (0 à 1), ou `null` s'il n'y en a pas.
  final double? progression;

  /// L'heure et les coches, posées sur l'image.
  final Widget? heure;

  /// Annule l'envoi en cours (croix de l'anneau).
  final VoidCallback? onAnnuler;

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  String? _path;
  String? _vignette;
  Duration? _duree;
  bool _missing = false;

  /// La forme de la vidéo — connue d'avance si on l'a déjà vue une fois.
  Size? _forme;

  String get _cle => '${widget.fileId}-${widget.fileName}';

  @override
  void initState() {
    super.initState();
    _forme = DimensionsMedias.connue(_cle);
    _prepare();
  }

  @override
  void didUpdateWidget(_VideoBubble old) {
    super.didUpdateWidget(old);
    // Le transfert vient de finir : le fichier existe désormais, on le charge
    // au lieu de rester sur « réception en cours ».
    final termine = old.progression != null && widget.progression == null;
    if (old.fileId != widget.fileId || (termine && _path == null)) {
      _missing = false;
      _forme ??= DimensionsMedias.connue(_cle);
      _prepare();
    }
  }

  // ⚠️ UNE IMAGE, PLUS UN LECTEUR VIDÉO PAR BULLE. Chaque vidéo de la
  // conversation démarrait son propre lecteur (décodeur matériel, mémoire)
  // pour n'afficher qu'une image fixe — souvent noire sur Android tant
  // qu'on ne la lançait pas. La bulle montre maintenant la première image,
  // extraite une fois par le système ; le lecteur ne s'ouvre qu'au toucher.
  Future<void> _prepare() async {
    final cle = _cle;
    final path = await StorageService.getSharedFilePath(
      widget.fileId,
      widget.fileName,
    );
    if (!mounted || cle != _cle) return;
    if (path == null) {
      setState(() => _missing = true);
      return;
    }
    final vignette = await MediaService.vignetteVideo(path);
    final duree = await MediaService.videoDuration(path);
    var forme = _forme;
    if (vignette != null && forme == null) {
      forme = await DimensionsMedias.lireImage(cle, vignette);
    }
    if (!mounted || cle != _cle) return;
    setState(() {
      _path = path;
      _vignette = vignette;
      _duree = duree;
      _forme = forme;
      _missing = false;
    });
  }

  void _ouvrir(String path) {
    OuroHaptics.light();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => _VideoViewerScreen(path: path),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    final vignette = _vignette;
    final duree = _duree;
    final progression = widget.progression;
    final heure = widget.heure;
    final taille = tailleBulleMedia(
      _forme,
      largeurEcran: MediaQuery.sizeOf(context).width,
    );

    final Widget contenu;
    if (path != null && progression == null) {
      contenu = GestureDetector(
        onTap: () => _ouvrir(path),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (vignette != null)
              Image.file(
                File(vignette),
                fit: BoxFit.cover,
                // Décodée à la taille de la bulle, pas à celle de la
                // vidéo : même raison que pour `_ImageBubble`.
                cacheWidth: (MediaQuery.sizeOf(context).width *
                        0.75 *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
                gaplessPlayback: true,
                frameBuilder: apparitionEnFondu,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Colors.black38),
              )
            else
              const ColoredBox(color: Colors.black38),
            Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.42),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const VoileBasMedia(),
            if (duree != null)
              Positioned(
                left: 7,
                bottom: 6,
                child: PastilleSurMedia(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _fmt(duree),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (_missing && progression == null) {
      contenu = ColoredBox(
        color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_outlined,
                color: OuroColors.tertiaryLabel,
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).chVideoReceiving,
                style: OuroTypography.caption1.copyWith(
                  color: OuroColors.tertiaryLabel,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (progression != null) {
      contenu = const FondChargementMedia();
    } else {
      contenu = const FondChargementMedia(
        child: SizedBox(
          width: 22,
          height: 22,
          child: OuroSpinner(color: Colors.white54, radius: 9),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusBubble),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: taille.width,
        height: taille.height,
        color: Colors.black26,
        child: Stack(
          fit: StackFit.expand,
          children: [
            contenu,
            if (heure != null && progression == null)
              Positioned(
                right: 7,
                bottom: 6,
                child: PastilleSurMedia(child: heure),
              ),
            if (progression != null)
              _AnneauProgression(
                progression: progression,
                onAnnuler: widget.onAnnuler,
              ),
          ],
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final sec = d.inSeconds;
    return '${sec ~/ 60}:${(sec % 60).toString().padLeft(2, '0')}';
  }
}

/// Le lecteur plein écran d'une vidéo reçue.
class _VideoViewerScreen extends StatefulWidget {
  const _VideoViewerScreen({required this.path});
  final String path;

  @override
  State<_VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<_VideoViewerScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final controller = VideoPlayerController.file(File(widget.path));
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      // Un lecteur vidéo reste noir dans les deux modes, comme partout
      // ailleurs : c'est ce qui met l'image en valeur.
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (controller == null) return;
          setState(() {
            controller.value.isPlaying ? controller.pause() : controller.play();
          });
        },
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 200) Navigator.of(context).pop();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            else
              const Center(
                child: OuroSpinner(color: Colors.white38, radius: 14),
              ),

            if (controller != null && controller.value.isInitialized)
              Positioned(
                left: 16,
                right: 16,
                bottom: 40,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: OuroColors.accent,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),

            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: OuroIconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            if (controller != null &&
                controller.value.isInitialized &&
                !controller.value.isPlaying)
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vignette d'une image partagée, avec ouverture en plein écran au tap.
/// La vignette d'une image reçue ou envoyée.
///
/// ⚠️ TROIS DÉFAUTS SE CUMULAIENT ICI, et c'est ce qui faisait
/// « clignoter et sauter » toute la conversation pendant le défilement.
///
/// **1. Le chemin du fichier était recalculé à chaque construction.**
/// Le `FutureBuilder` recevait un `Future` fabriqué DANS `build()`. Or
/// une liste recycle ses éléments : chaque fois qu'une image
/// réapparaissait à l'écran, un nouveau `Future` démarrait,
/// `connectionState` repassait à « en cours », et l'image cédait la
/// place au chargeur — puis revenait. D'où le rechargement permanent.
///
/// **2. Le chargeur ne faisait pas la même taille que l'image.**
/// 220×160 pour l'un, 220×220 pour l'autre. Chaque bascule changeait la
/// hauteur de la bulle de soixante points, et poussait TOUS les messages
/// du dessous. C'est ce déplacement-là qu'on ressent comme un saut — y
/// compris sur les messages vocaux, qui n'y sont pour rien : ils sont
/// simplement bousculés par l'image du dessus.
///
/// **3. La photo était décodée en pleine résolution.**
/// `Image.file` sans `cacheWidth` décode l'image d'origine tout entière
/// avant de la réduire à 220 points. Une photo de téléphone occupe
/// alors une cinquantaine de méga-octets en mémoire — assez, à elle
/// seule, pour vider le cache d'images de l'application et forcer le
/// rechargement de toutes les autres.
class _ImageBubble extends StatefulWidget {
  const _ImageBubble({
    required this.fileId,
    required this.fileName,
    required this.heroTag,
    this.progression,
    this.heure,
    this.titre,
    this.onOuvrir,
    this.onAnnuler,
  });
  final String fileId;
  final String fileName;

  /// Relie la vignette à la visionneuse : la photo grandit depuis la bulle.
  final Object heroTag;

  /// Avancement du transfert (0 à 1), ou `null` s'il n'y en a pas.
  final double? progression;

  /// L'heure et les coches, posées sur l'image.
  final Widget? heure;

  /// Annule l'envoi en cours (croix de l'anneau).
  final VoidCallback? onAnnuler;

  /// Le nom affiché en haut de la visionneuse.
  final String? titre;

  /// Ouvre la galerie de la conversation (fourni par l'écran de discussion).
  final void Function(String chemin, Size? forme)? onOuvrir;

  /// Les chemins déjà résolus, partagés par toutes les vignettes.
  ///
  /// Un identifiant de fichier désigne toujours le même fichier : le
  /// chemin n'a donc besoin d'être cherché qu'une fois pour toute la
  /// session. C'est ce qui supprime le clignotement au recyclage — au
  /// retour à l'écran, le chemin est déjà connu et l'image s'affiche
  /// sans passer par le chargeur.
  static final Map<String, String?> _chemins = {};

  @override
  State<_ImageBubble> createState() => _ImageBubbleState();
}

class _ImageBubbleState extends State<_ImageBubble> {
  String? _chemin;
  bool _cherche = true;

  /// La forme de la photo — connue d'avance si on l'a déjà vue une fois.
  Size? _forme;

  String get _cle => '${widget.fileId}-${widget.fileName}';

  @override
  void initState() {
    super.initState();
    _forme = DimensionsMedias.connue(_cle);
    _resoudre();
  }

  @override
  void didUpdateWidget(_ImageBubble old) {
    super.didUpdateWidget(old);
    final transfertTermine =
        old.progression != null && widget.progression == null;
    if (old.fileId != widget.fileId || old.fileName != widget.fileName) {
      _forme = DimensionsMedias.connue(_cle);
      _resoudre();
    } else if (transfertTermine && _chemin == null) {
      _resoudre();
    }
  }

  void _resoudre() {
    final connu = _ImageBubble._chemins[_cle];
    if (connu != null) {
      _chemin = connu;
      _cherche = false;
      _lireForme(connu);
      return;
    }
    _cherche = true;
    final cle = _cle;
    StorageService.getSharedFilePath(widget.fileId, widget.fileName).then((
      chemin,
    ) {
      // ⚠️ UN CHEMIN NUL N'EST PAS MIS EN CACHE. Il l'était : une image dont
      // la bulle s'affichait avant la fin du transfert gardait « introuvable »
      // pour toute la session, et restait un carré vide jusqu'au redémarrage.
      // Avec l'envoi en morceaux, c'est le cas normal — on ne mémorise donc
      // que ce qui existe.
      if (chemin != null) _ImageBubble._chemins[cle] = chemin;
      if (!mounted || cle != _cle) return;
      setState(() {
        _chemin = chemin;
        _cherche = false;
      });
      if (chemin != null) _lireForme(chemin);
    });
  }

  void _lireForme(String chemin) {
    if (_forme != null) return;
    final cle = _cle;
    DimensionsMedias.lireImage(cle, chemin).then((forme) {
      if (forme != null && mounted && cle == _cle) {
        setState(() => _forme = forme);
      }
    });
  }

  static const Widget _abimee = ColoredBox(
    color: Colors.black26,
    child: Center(
      child: Icon(Icons.broken_image_rounded, color: Colors.white54),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final chemin = _chemin;
    final progression = widget.progression;
    final heure = widget.heure;
    final taille = tailleBulleMedia(
      _forme,
      largeurEcran: MediaQuery.sizeOf(context).width,
    );

    final Widget contenu;
    if (chemin == null) {
      contenu = (_cherche || progression != null)
          ? FondChargementMedia(
              child: progression != null
                  ? null
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: OuroSpinner(color: Colors.white70, radius: 9),
                    ),
            )
          : _abimee;
    } else {
      contenu = GestureDetector(
        onTap: progression != null
            ? null
            : () {
                OuroHaptics.light();
                final ouvrir = widget.onOuvrir;
                if (ouvrir != null) {
                  ouvrir(chemin, _forme);
                } else {
                  ouvrirVisionneuseImage(
                    context,
                    chemin: chemin,
                    heroTag: widget.heroTag,
                    forme: _forme,
                    titre: widget.titre,
                  );
                }
              },
        child: Hero(
          tag: widget.heroTag,
          // ⚠️ DÉCODÉE À 560 PIXELS DE LARGE, jamais en pleine résolution :
          // une photo de téléphone décodée entière occupe une cinquantaine
          // de méga-octets pour une vignette.
          child: Image(
            image: vignetteMedia(chemin),
            width: taille.width,
            height: taille.height,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: apparitionEnFondu,
            errorBuilder: (context, error, stackTrace) => _abimee,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusBubble),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: taille.width,
        height: taille.height,
        color: Colors.black12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            contenu,
            if (heure != null && progression == null) ...[
              const VoileBasMedia(),
              Positioned(
                right: 7,
                bottom: 6,
                child: PastilleSurMedia(child: heure),
              ),
            ],
            if (progression != null)
              _AnneauProgression(
                progression: progression,
                onAnnuler: widget.onAnnuler,
              ),
          ],
        ),
      ),
    );
  }
}

/// L'anneau de progression d'un transfert, posé sur une photo ou une vidéo —
/// le même geste visuel que dans les grandes messageries : un voile, un
/// anneau qui se remplit, le pourcentage au centre.
class _AnneauProgression extends StatelessWidget {
  const _AnneauProgression({required this.progression, this.onAnnuler});

  final double progression;

  /// Fourni sur MES envois : la croix au centre arrête tout.
  final VoidCallback? onAnnuler;

  @override
  Widget build(BuildContext context) {
    final p = progression.clamp(0.0, 1.0);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.38),
      child: Center(
        child: Semantics(
          label: '${(p * 100).floor()} %',
          child: SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: p),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  builder: (context, v, _) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Center(
                  child: onAnnuler == null
                      ? Text(
                          '${(p * 100).floor()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onAnnuler,
                          child: const SizedBox.expand(
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dessine la petite « forme d'onde » figée (18 barres de hauteurs
/// différentes) qu'on voit sur un message vocal déjà envoyé — les
/// barres avant la position de lecture s'allument dans une couleur
/// différente au fur et à mesure que l'audio avance.
/// Le petit bouton flottant « ↓ 3 » qui apparaît quand on est remonté
/// dans l'historique et que de nouveaux messages arrivent en bas — un
/// tap ramène directement au dernier message.
/// Le bouton « descendre ».
///
/// ⚠️ C'ÉTAIT UN CARRÉ NOIR, posé sur la dernière bulle dont il cachait
/// l'heure. C'est maintenant un rond de verre, de la même matière que la
/// barre de saisie, et le nombre de messages non lus est une petite
/// pastille d'accent qui roule quand un message arrive.
class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.unread, required this.onTap});
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          OuroHaptics.light();
          onTap();
        },
        child: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: OuroColors.systemBackground.withValues(alpha: 0.72),
                      border: Border.all(
                        color: OuroColors.separator.withValues(alpha: 0.6),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 26,
                      color: OuroColors.label,
                    ),
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OuroColors.accentRempli,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: OuroCompteur(
                      valeur: unread,
                      max: 99,
                      style: TextStyle(
                        color: OuroColors.texteSurAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          curve: Curves.easeOutCubic,
          duration: 260.ms,
        )
        .fadeIn(duration: 180.ms);
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.horsDePortee,
    required this.champKey,
    required this.opaciteChamp,
    required this.miseEnFormeAutorisee,
    required this.onPackRequis,
    required this.controller,
    required this.recording,
    required this.vocalVueUnique,
    required this.onVocalVueUnique,
    required this.recordingLocked,
    required this.amplitudes,
    required this.replyPreview,
    this.editionPreview,
    this.onCancelEdit,
    required this.onChanged,
    required this.onSend,
    required this.onMicStart,
    required this.onMicStop,
    required this.onMicCancel,
    required this.onMicLock,
    required this.videoPossible,
    required this.modeVideo,
    required this.onBasculerMode,
    required this.recDrag,
    required this.onAttach,
    required this.onCamera,
    required this.onContenuClavier,
    required this.onSticker,
    this.stickersOuverts = false,
    required this.champFocus,
    required this.onAttachMedia,
    required this.onCancelReply,
  });

  /// Personne n'est joignable : on le dit dans le champ plutôt que de
  /// laisser écrire pour rien.
  final bool horsDePortee;

  /// Où commence la transition d'envoi : la boîte de texte elle-même.
  final GlobalKey champKey;

  /// L'opacité du champ pendant la transition d'envoi.
  final ValueListenable<double> opaciteChamp;

  /// Le pack est-il débloqué ? Il ouvre les styles d'écriture.
  final bool miseEnFormeAutorisee;

  /// Emmène là où le pack se débloque.
  final VoidCallback onPackRequis;

  final TextEditingController controller;

  /// Le prochain vocal part-il en vue unique ?
  final bool vocalVueUnique;
  final VoidCallback onVocalVueUnique;
  final bool recording;

  /// Enregistrement « mains libres » : le doigt a été relevé, mais le
  /// micro continue.
  final bool recordingLocked;

  final List<double> amplitudes;
  final MeshMessage? replyPreview;

  /// Le message qu'on est en train de modifier : un bandeau le rappelle
  /// au-dessus du champ, et la coche remplace la flèche d'envoi.
  final MeshMessage? editionPreview;
  final VoidCallback? onCancelEdit;
  final ValueChanged<String> onChanged;
  final void Function([String? effect]) onSend;
  final Future<void> Function() onMicStart;
  final Future<void> Function() onMicStop;
  final Future<void> Function() onMicCancel;
  final VoidCallback onMicLock;

  /// Y a-t-il une caméra ? C'est ce qui décide si l'appui court bascule
  /// en mode vidéo — sans caméra, il n'y a rien à distinguer d'un
  /// maintien, et l'attente de 150 ms ne s'arme même pas.
  final bool videoPossible;

  /// Le bouton est-il en mode caméra ?
  final bool modeVideo;

  final VoidCallback onBasculerMode;

  /// L'état du geste, tenu par l'écran.
  final _RecordDrag recDrag;

  final VoidCallback onAttach;

  /// L'appareil photo, en un toucher.
  final VoidCallback onCamera;

  /// Un GIF, un autocollant ou une image venu du clavier.
  final ValueChanged<KeyboardInsertedContent> onContenuClavier;

  /// Bascule le panneau de stickers : il remplace le clavier, et le
  /// clavier le remplace à son tour.
  final VoidCallback onSticker;

  /// Le panneau de stickers est-il ouvert ? Décide de l'icône.
  final bool stickersOuverts;

  /// Le focus du champ, tenu par l'écran : c'est lui qui rend le clavier
  /// quand on referme le panneau de stickers.
  final FocusNode champFocus;

  /// Le raccourci de l'appui long : directement les photos et vidéos.
  final VoidCallback onAttachMedia;
  final VoidCallback onCancelReply;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ── ⚠️ PAS DE CURSEUR SANS CLAVIER ─────────────────────────────────
  //
  // Le clavier se ferme par un balayage de la liste ou par le geste
  // retour d'Android — mais le champ GARDAIT le focus : un curseur rouge
  // clignotait dans une barre sans clavier, un état qui n'existe sur
  // aucune messagerie et qui laisse croire qu'on peut taper. Quand le
  // clavier disparaît, le champ lâche le focus avec lui.
  double _clavierAvant = 0;

  @override
  void didChangeMetrics() {
    final vue = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    if (vue == null) return;
    final clavier = vue.viewInsets.bottom;
    if (_clavierAvant > 0 && clavier == 0 && widget.champFocus.hasFocus) {
      widget.champFocus.unfocus();
    }
    _clavierAvant = clavier;
  }

  /// L'instant où l'enregistrement a commencé. Voir
  /// `_beginRecordingVisuals` pour pourquoi ce n'est pas un compteur.
  DateTime _debutEnregistrement = DateTime.now();
  late final AnimationController _pulse;
  // ⚠️ LU AU DÉPART, PAS SUPPOSÉ FAUX. Avec les brouillons, le champ peut
  // s'ouvrir déjà rempli : sans cette lecture, le bouton restait sur le
  // micro au lieu de l'avion jusqu'à la première frappe.
  late bool _hasText = widget.controller.text.trim().isNotEmpty;

  /// Raccourci de lecture : l'état du geste appartient à l'écran (voir
  /// `_ChatScreenState._recDrag`), parce que la surcouche flottante le lit
  /// aussi.
  _RecordDrag get _recDrag => widget.recDrag;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    widget.controller.addListener(_onController);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onController() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _pulse.dispose();
    // ⚠️ PAS `_recDrag.dispose()` ICI. Il appartient désormais à l'écran,
    // qui survit à cette barre : le libérer ici le rendrait inutilisable
    // dès la première reconstruction de la barre de saisie — et elle se
    // reconstruit à chaque caractère tapé.
    widget.controller.removeListener(_onController);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ⚠️ Le minuteur et la pulsation sont pilotés PAR L'ÉTAT, pas par le
  /// geste.
  ///
  /// Ils étaient auparavant démarrés dans `_startMic`, c'est-à-dire
  /// uniquement quand on appuyait sur le bouton micro. Or il existe un
  /// second chemin : le petit micro de réponse rapide posé à côté d'un
  /// vocal reçu, qui lance l'enregistrement directement depuis l'écran
  /// parent. Par ce chemin-là, le compteur restait figé sur « 0:00 »
  /// pendant tout l'enregistrement et la pastille rouge ne clignotait
  /// pas — on ne pouvait pas savoir si le micro écoutait vraiment.
  ///
  /// En réagissant ici au passage de `recording` à vrai, les deux
  /// chemins sont couverts, quel que soit celui qui déclenchera le
  /// prochain enregistrement.
  @override
  void didUpdateWidget(_InputBar old) {
    super.didUpdateWidget(old);
    if (widget.recording && !old.recording) {
      _beginRecordingVisuals();
    } else if (!widget.recording && old.recording) {
      _resetMicVisuals();
    }
  }

  void _beginRecordingVisuals() {
    // ⚠️ UN INSTANT DE DÉPART, PLUS UN COMPTEUR DE SECONDES. Un compteur
    // incrémenté par un minuteur dérive : chaque image sautée — et il y
    // en a, au démarrage de l'enregistrement précisément — est une
    // seconde qui ne sera jamais rattrapée. Le chrono se calcule par
    // différence de dates.
    _debutEnregistrement = DateTime.now();
    _pulse.bouclerSiAmbiant(reverse: true);
    // ⚠️ `rafraichir()`, SURTOUT PAS `reset()`.
    //
    // C'était `reset()`, et c'est ce qui rendait le geste MORT : on ne
    // pouvait ni monter pour verrouiller, ni glisser pour annuler, et
    // relâcher n'envoyait même plus.
    //
    // La chaîne : le doigt se pose, le geste s'arme ; l'enregistrement
    // démarre ; `recording` passe à vrai ; on arrive ICI — et `reset()`
    // appelle `reinitialiser()`, qui remet la machine au repos ALORS QUE
    // LE DOIGT EST TOUJOURS POSÉ. Tout mouvement suivant est ignoré, la
    // machine n'acceptant de mouvements qu'en état « enregistre ».
    //
    // Le geste possède son propre cycle de vie : il naît à la pose du
    // doigt, il meurt par sa propre issue (envoyer, annuler, verrouiller).
    // Personne d'autre n'a à le remettre à zéro pendant qu'il vit.
    _recDrag.rafraichir();
  }

  Future<void> _startMic() => widget.onMicStart();

  Future<void> _stopMic() => widget.onMicStop();

  Future<void> _cancelMic() => widget.onMicCancel();

  void _resetMicVisuals() {
    _pulse.stop();
    _pulse.value = 0;
    _recDrag.reset();
  }

  void _onMicLock() {
    HapticFeedback.mediumImpact();
    widget.onMicLock();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rec = widget.recording;
    final reply = widget.replyPreview;

    // ── LA BARRE DE SAISIE FLOTTE ──────────────────────────────────
    //
    // Elle n'est plus une bande opaque collée au bas de l'écran, barrée
    // d'un filet gris. C'est une capsule translucide posée AU-DESSUS de
    // la conversation, à travers laquelle on continue de voir le fond et
    // les derniers messages défiler.
    //
    // C'est le changement signature d'iOS 26, repris par WhatsApp en
    // 2026 sous le nom de « floating chat bar ». L'intérêt n'est pas
    // décoratif : la bande opaque coupait l'écran en deux et donnait
    // l'impression que la conversation s'arrêtait là. La capsule, elle,
    // laisse la conversation aller jusqu'en bas — l'écran paraît plus
    // grand sans qu'on ait retiré quoi que ce soit.
    //
    // ⚠️ Le flou reste MODÉRÉ et un voile opaque subsiste derrière le
    // contenu. Une transparence totale rendrait le texte qu'on est en
    // train de taper illisible dès qu'une photo passe dessous — et le
    // champ de saisie est le seul endroit de l'écran où l'on ne peut pas
    // se permettre la moindre hésitation de lecture.
    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      // ── LE VERRE D'iOS ─────────────────────────────────────────────
      //
      // Un voile teinté léger sur un flou prononcé (et saturé, comme le
      // matériau d'Apple), un liseré plus clair en haut qu'en bas — la
      // lumière vient d'au-dessus — et une ombre très diffuse. Plus aucune
      // surface pleine : ni la capsule, ni la pilule du champ ne sont
      // blanches ou noires, c'est le fond de la discussion qui les colore.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.35 : 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ui.ImageFilter.compose(
            outer: const ui.ColorFilter.matrix(_saturationVerre),
            inner: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          ),
          child: CustomPaint(
            foregroundPainter: _LisereVerre(rayon: 26, sombre: OuroColors.isDark),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: _teinteVerre,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.editionPreview != null)
                  _bandeauEdition(l10n, widget.editionPreview!)
                else if (reply != null)
                  _replyPreviewBar(l10n, reply),
                if (widget.horsDePortee &&
                    !rec &&
                    reply == null &&
                    widget.editionPreview == null)
                  _ligneHorsPortee(l10n),
                // ⚠️ VERROUILLÉ OU NON, LA MÊME RANGÉE. Elle passait à une
                // rangée « mains libres » à part — corbeille, onde, petit
                // bouton d'envoi — pendant que le grand cercle, lui,
                // affichait DÉJÀ une flèche d'envoi qu'on ne pouvait pas
                // toucher. Deux boutons d'envoi, dont le plus visible
                // inerte, et un micro démonté qui faisait perdre au cercle
                // son point d'ancrage. Telegram garde la barre telle
                // quelle : le texte « Glisser pour annuler » devient
                // « Annuler », et c'est LE GRAND CERCLE qui envoie.
                  Row(
                    children: [
                      // ── LA PILULE, PUIS LE BOUTON ROND ───────────────
                      //
                      // Structure reprise de WhatsApp : TOUT ce qui touche à la
                      // composition vit DANS une pilule blanche — sticker à
                      // gauche, texte au milieu, trombone à droite — et le
                      // bouton d'action principal est un CERCLE PLEIN posé à
                      // côté, hors de la pilule.
                      //
                      // Ce n'est pas un choix esthétique. Le cercle plein est
                      // la seule chose colorée de la barre : il devient le
                      // point d'arrivée du regard, et le geste « j'envoie »
                      // n'a plus qu'une cible possible. Fondu dans la pilule
                      // comme avant, il se disputait l'attention avec le champ
                      // de saisie.
                      // ── LA DISPOSITION DE MESSAGES (iOS) ─────────────
                      //
                      //   ＋   ( Message                )   📷   🎙
                      //
                      // Le « + » À GAUCHE, hors du champ : il ouvre les
                      // pièces jointes (stickers compris). Le champ seul
                      // dans sa pilule, sans rien qui morde sur la place du
                      // texte. L'appareil photo et le micro à droite, au
                      // trait, en gris : des accessoires. Dès qu'on écrit,
                      // les deux s'effacent et la flèche d'envoi — seule
                      // touche de couleur — prend la place.
                      if (!rec)
                        _IconePilule(
                          key: ClesExplications.boutonPieces,
                          icone: Icons.add_rounded,
                          tooltip: l10n.chAttachTooltip,
                          onTap: widget.onAttach,
                          taille: 27,
                        ),
                      Expanded(
                        child: rec
                            ? _recordingRow(l10n)
                            : OuroCard(
                                color: _teintePilule,
                                // Une vraie capsule : demi-cercles aux
                                // deux bouts, comme le champ de Messages.
                                borderRadius: 20,
                                padding: const EdgeInsets.only(
                                  left: 6,
                                  right: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: _textField()),
                                    // Panneau de stickers ouvert : le
                                    // clavier, pour revenir écrire. Sans
                                    // lui, on ne sait plus comment sortir
                                    // du panneau.
                                    if (widget.stickersOuverts)
                                      _IconePilule(
                                        key: ClesExplications.boutonStickers,
                                        icone: Icons.keyboard_rounded,
                                        tooltip: l10n.chKeyboardTooltip,
                                        onTap: widget.onSticker,
                                      ),
                                  ],
                                ),
                              ),
                      ),
                      if (!rec && !_hasText)
                        _IconePilule(
                          icone: Icons.photo_camera_outlined,
                          tooltip: l10n.camTakePhoto,
                          onTap: widget.onCamera,
                          taille: 25,
                        ),
                      SizedBox(width: (!rec && !_hasText) ? 0 : 6),
                      // Le cadenas qui monte au-dessus du micro pendant qu'on
                      // maintient : c'est l'indice qui rend le geste
                      // découvrable. Sans lui, personne ne devine qu'on peut
                      // glisser vers le haut.
                      // ── MICRO **OU** ENVOYER, JAMAIS LES DEUX ────────
                      //
                      // Les deux boutons étaient affichés côte à côte en
                      // permanence. C'est un contresens : on n'enregistre pas
                      // un vocal et on n'envoie pas un texte en même temps, et
                      // deux boutons voisins dont un seul est utile obligent à
                      // choisir à chaque message.
                      //
                      // Le micro cède donc la place à l'avion dès le premier
                      // caractère tapé, et la reprend dès que le champ se vide
                      // — c'est ce que font WhatsApp, Telegram et iMessage.
                      //
                      // La bascule est un fondu croisé avec une légère mise à
                      // l'échelle. Volontairement COURTE (160 ms) : cette
                      // transition se joue à chaque premier caractère de chaque
                      // message, des centaines de fois par jour. Tout ce qui
                      // dépasse se transforme en attente.
                      // ⚠️ LE BOUTON « 1 » (VUE UNIQUE) N'EST PLUS ICI.
                      //
                      // Un cercle avec un chiffre, à côté du micro, sans
                      // aucun mot : personne ne devinait ce qu'il faisait,
                      // et il prenait la place de l'appareil photo. La vue
                      // unique reste à portée exactement là où elle a du
                      // sens — dans la colonne qui apparaît PENDANT
                      // l'enregistrement d'un vocal, et dans l'aperçu
                      // d'envoi d'une photo — avec, là, un libellé.
                      // ⚠️ LA CLÉ DE LA VISITE GUIDÉE SERT AUSSI DE REPÈRE :
                      // c'est par elle que l'écran mesure le centre exact
                      // du micro pour y poser le cercle et le cadenas.
                      //
                      // POSÉE AUTOUR DU `AnimatedSwitcher`, PAS SUR LE
                      // MICRO. Pendant les 160 ms d'un fondu, le switcher
                      // garde l'ancien enfant à l'écran à côté du nouveau :
                      // taper un caractère puis l'effacer aussitôt mettrait
                      // DEUX micros à l'écran, donc deux fois la même
                      // `GlobalKey` — une erreur Flutter, pas un
                      // avertissement. Le créneau, lui, est unique, et son
                      // centre est celui du micro (même taille, 44).
                      KeyedSubtree(
                        key: ClesExplications.boutonMicro,
                        child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        ),
                        child: (_hasText && !rec && widget.editionPreview != null)
                            ? _BoutonRond(
                                key: const ValueKey('valider'),
                                child: Semantics(
                                  button: true,
                                  label: l10n.actionEdit,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => widget.onSend(),
                                    child: const SizedBox.expand(
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : (_hasText && !rec)
                            ? _BoutonRond(
                                key: const ValueKey('envoyer'),
                                child: _AnimatedSendButton(
                                  active: true,
                                  onSend: widget.onSend,
                                ),
                              )
                            : IgnorePointer(
                                ignoring: rec,
                                child: _MicButton(
                                  // ⚠️ `ValueKey` POUR L'IDENTITÉ,
                                  // `GlobalKey` POUR LA VISITE GUIDÉE. Un
                                  // widget ne peut porter qu'une clé ; la
                                  // `GlobalKey` descend donc dans le
                                  // `Semantics` juste dessous, qui occupe
                                  // exactement la même place à l'écran.
                                  key: const ValueKey('micro'),
                                  recording: rec,
                                  pulse: _pulse,
                                  drag: _recDrag,
                                  onMicStart: _startMic,
                                  onMicStop: _stopMic,
                                  onMicCancel: _cancelMic,
                                  onMicLock: _onMicLock,
                                  videoPossible: widget.videoPossible,
                                  modeVideo: widget.modeVideo,
                                  onBasculerMode: widget.onBasculerMode,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _textField() {
    return KeyedSubtree(
      key: widget.champKey,
      child: ValueListenableBuilder<double>(
        valueListenable: widget.opaciteChamp,
        builder: (_, opacite, champ) =>
            opacite >= 1 ? champ! : Opacity(opacity: opacite, child: champ),
        child: _champ(),
      ),
    );
  }

  /// Les boutons de style ajoutés au menu de sélection du champ.
  ///
  /// Sans le pack, ils sont là quand même, mais emmènent à l'écran
  /// d'achat : cacher une fonction ne la fait pas désirer, la montrer oui
  /// — c'est exactement ce que fait Telegram avec ses fonctions payantes.
  List<ContextMenuButtonItem> _boutonsMiseEnForme(
    BuildContext context,
    EditableTextState etat,
  ) {
    final l10n = AppLocalizations.of(context);
    final styles = <(Formatage, String)>[
      (Formatage.gras, l10n.fmtBold),
      (Formatage.italique, l10n.fmtItalic),
      (Formatage.barre, l10n.fmtStrike),
      (Formatage.code, l10n.fmtMono),
      (Formatage.spoiler, l10n.fmtSpoiler),
    ];
    return [
      for (final (style, libelle) in styles)
        ContextMenuButtonItem(
          label: libelle,
          onPressed: () {
            etat.hideToolbar();
            if (!widget.miseEnFormeAutorisee) {
              OuroHaptics.selection();
              widget.onPackRequis();
              return;
            }
            OuroHaptics.light();
            widget.controller.value =
                MiseEnForme.appliquer(widget.controller.value, style);
          },
        ),
    ];
  }

  static final bool _correcteurDisponible =
      WidgetsBinding.instance.platformDispatcher.nativeSpellCheckServiceDefined;

  Widget _champ() {
    return TextField(
      // ⚠️ PAS D'AUTOFOCUS. Ouvrir une discussion faisait monter le
      // clavier d'office, et cacher la moitié des messages qu'on venait
      // justement lire. WhatsApp et iMessage ouvrent sur la conversation ;
      // on touche le champ quand on veut écrire.
      autofocus: false,
      focusNode: widget.champFocus,
      controller: widget.controller,
      minLines: 1,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      // Le soulignement rouge des fautes, et les suggestions au toucher,
      // comme dans toutes les applications du système. Seulement si le
      // téléphone a un correcteur : sans lui, Flutter refuse de démarrer
      // le champ.
      spellCheckConfiguration: _correcteurDisponible
          ? const SpellCheckConfiguration()
          : null,
      contentInsertionConfiguration: ContentInsertionConfiguration(
        allowedMimeTypes: const [
          'image/gif',
          'image/webp',
          'image/png',
          'image/jpeg',
        ],
        onContentInserted: widget.onContenuClavier,
      ),
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSend(),
      cursorColor: OuroColors.accent,
      style: OuroTypography.body.copyWith(color: OuroColors.label),
      // ── LES STYLES D'ÉCRITURE ───────────────────────────────────
      //
      // Telegram les met dans le menu de sélection, à côté de Copier et
      // Coller : c'est là que le doigt est déjà quand on vient de
      // sélectionner un mot. Même endroit ici, avec les mêmes styles.
      contextMenuBuilder: (context, etat) =>
          AdaptiveTextSelectionToolbar.buttonItems(
        anchors: etat.contextMenuAnchors,
        buttonItems: [
          ...etat.contextMenuButtonItems,
          ..._boutonsMiseEnForme(context, etat),
        ],
      ),
      magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
      decoration: InputDecoration(
        // Hors de portée, on ne fait pas semblant : le message partira
        // tout seul, et on le dit avant que la personne écrive.
        // ⚠️ TOUJOURS « Message ». Le texte d'attente (« Partira dès qu'il
        // sera à portée ») tenait sur DEUX lignes et doublait la hauteur
        // de la barre. Il vit désormais sur sa propre petite ligne,
        // au-dessus (voir `_ligneHorsPortee`).
        hintText: AppLocalizations.of(context).chMessageHint,
        hintStyle: OuroTypography.body.copyWith(
          color: OuroColors.tertiaryLabel,
        ),
        // ⚠️ PLUS AUCUN FOND ICI.
        //
        // Le champ avait le sien, posé dans la capsule de la barre :
        // deux surfaces empilées, deux arrondis concentriques, une dalle
        // grise au milieu d'un élément censé être translucide.
        //
        // Désormais c'est la PILULE qui porte le fond, et le champ n'est
        // plus qu'un curseur et du texte posés dessus — comme chez
        // WhatsApp, où l'on ne distingue jamais le champ de son
        // conteneur.
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Rangée affichée pendant qu'on MAINTIENT le micro — style WhatsApp :
  /// pastille rouge qui bat, compteur, onde en direct, et l'indice
  /// « ‹ Glisser pour annuler » qui suit le doigt et rougit à l'approche
  /// du seuil. Plus de corbeille ni de capsule volante : le geste
  /// d'annulation est le glissement lui-même.
  Widget _recordingRow(AppLocalizations l10n) {
    return _RecordingBar(
      debut: _debutEnregistrement,
      amplitudes: widget.amplitudes,
      drag: _recDrag,
      pulse: _pulse,
      hint: l10n.chSlideToCancel,
      verrouille: widget.recordingLocked,
      texteAnnuler: l10n.actionCancel,
      onAnnuler: _cancelMic,
    );
  }

  /// Une ligne discrète au-dessus du champ : la personne n'est pas à
  /// portée, le message attendra. C'est une information, pas une alerte.
  Widget _ligneHorsPortee(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: OuroColors.secondaryLabel),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              l10n.chWillSendWhenNearby,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.caption1.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// « ✎ Modifier le message » et l'original en dessous — comme le
  /// bandeau de réponse, pour que l'œil le reconnaisse, mais avec un
  /// crayon : on doit savoir d'un coup d'œil qu'on ne répond PAS.
  Widget _bandeauEdition(AppLocalizations l10n, MeshMessage m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: OuroColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: OuroColors.accent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_rounded, size: 16, color: OuroColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chEditMessageTitle,
                    style: OuroTypography.caption1.copyWith(
                      color: OuroColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: l10n.actionCancel,
              child: GestureDetector(
                onTap: widget.onCancelEdit,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: OuroColors.tertiaryLabel,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _replyPreviewBar(AppLocalizations l10n, MeshMessage m) {
    // Même résumé que `_quoteBlock` : sans lui, répondre à un sondage ou
    // une position afficherait ici leur encodage brut pendant qu'on
    // compose la réponse.
    final snippet = m.type == 'file'
        ? VoiceNoteMeta.describeAttachment(m.fileName)
        : isStickerMessage(m.content)
            ? l10n.chStickerPreview
            : LocationMessage.describe(PollMessage.describe(m.content));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: OuroColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(12),
          // Un filet vertical coloré du côté du texte, comme dans
          // Messages : plus discret qu'un contour complet, et il désigne
          // clairement ce à quoi on répond.
          border: Border(left: BorderSide(color: OuroColors.accent, width: 3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chReplyingTo(m.authorPseudo),
                    style: OuroTypography.caption1.copyWith(
                      color: OuroColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            // La photo à laquelle on répond, en vignette — comme
            // WhatsApp. « 📷 Photo » seul ne dit pas LAQUELLE.
            if (m.type == 'file' &&
                m.fileId != null &&
                mediaKindOf(m.fileMimeType, m.fileName) == MediaKind.image)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: _VignetteReponse(
                  fileId: m.fileId!,
                  fileName: m.fileName ?? '',
                ),
              ),
            GestureDetector(
              onTap: widget.onCancelReply,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  color: OuroColors.tertiaryLabel,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton micro « presser pour enregistrer » façon WhatsApp/Telegram/Signal.
///
/// Implémenté avec [Listener] (événements pointeur bruts) plutôt que
/// [GestureDetector.onTapDown]/[onLongPressStart] combinés : ces deux
/// reconnaisseurs partagés sur un même détecteur entraient en conflit dans
/// l'arène de gestes — `onTapDown` se déclenche de façon optimiste dès le
/// contact, PUIS `onLongPressStart` se déclenchait une seconde fois ~500ms
/// plus tard sur un appui maintenu (le cas normal pour un message vocal),
/// démarrant l'enregistrement deux fois et laissant l'UI dans un état
/// incohérent. [Listener] ne participe pas à l'arène de gestes : chaque
/// pointeur ne produit qu'un down/move/up, sans ambiguïté possible.
class _MicButton extends StatefulWidget {
  const _MicButton({
    super.key,
    required this.recording,
    required this.pulse,
    required this.drag,
    required this.onMicStart,
    required this.onMicStop,
    required this.onMicCancel,
    required this.onMicLock,
    required this.videoPossible,
    required this.modeVideo,
    required this.onBasculerMode,
  });

  final bool recording;
  final Animation<double> pulse;
  final bool videoPossible;
  final bool modeVideo;
  final VoidCallback onBasculerMode;

  /// État partagé du glissement — écrit ici, lu par [_RecordingBar] et
  /// par l'indice de verrouillage.
  final _RecordDrag drag;

  final Future<void> Function() onMicStart;
  final Future<void> Function() onMicStop;
  final Future<void> Function() onMicCancel;

  /// Le doigt est monté assez haut : on passe en mains libres.
  final VoidCallback onMicLock;

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton> {
  GesteEnregistrement? _geste;
  Timer? _minuteurBascule;

  @override
  void dispose() {
    _minuteurBascule?.cancel();
    super.dispose();
  }

  /// Applique ce que la machine a décidé. Un seul endroit : c'est ce qui
  /// garantit qu'un même verdict produit toujours les mêmes effets, d'où
  /// qu'il vienne — mouvement, relâchement ou interruption.
  void _appliquer(IssueGeste issue) {
    switch (issue) {
      case IssueGeste.aucune:
        break;
      case IssueGeste.envoyer:
        _minuteurBascule?.cancel();
        widget.onMicStop();
      case IssueGeste.annuler:
        _minuteurBascule?.cancel();
        OuroHaptics.medium();
        widget.onMicCancel();
      case IssueGeste.verrouiller:
        _minuteurBascule?.cancel();
        // Le retour tactile vient AVANT l'animation, comme chez
        // Telegram : c'est lui qui annonce que c'est acquis, et il
        // arriverait trop tard après 350 ms de ressort.
        OuroHaptics.selection();
        widget.onMicLock();
      case IssueGeste.basculerMode:
        _minuteurBascule?.cancel();
        widget.onBasculerMode();
    }
    widget.drag.rafraichir();
  }

  void _onPointerDown(PointerDownEvent e) {
    final g = GesteEnregistrement(
      largeurEcran: MediaQuery.sizeOf(context).width,
      // ⚠️ L'ATTENTE DE 150 ms NE S'ARME QUE S'IL Y A UNE CAMÉRA. Chez
      // Telegram aussi : sans caméra, il n'y a rien à distinguer d'un
      // appui court, et faire patienter 150 ms avant de capter la voix ne
      // ferait que manger le début des messages.
      videoPossible: widget.videoPossible,
    );
    _geste = g;
    widget.drag.geste = g;
    final armer = g.doigtPose();
    if (armer) {
      _minuteurBascule = Timer(GesteEnregistrement.delaiBascule, () {
        g.delaiEcoule();
        widget.onMicStart();
        widget.drag.rafraichir();
      });
    } else {
      widget.onMicStart();
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    final g = _geste;
    if (g == null) return;
    _appliquer(g.doigtBouge(e.position.dx, e.position.dy));
  }

  void _onPointerUp(PointerUpEvent e) {
    final g = _geste;
    if (g == null) return;
    _appliquer(g.doigtLeve());
  }

  void _onPointerCancel(PointerCancelEvent e) {
    final g = _geste;
    if (g == null) return;
    _appliquer(g.interrompu());
  }

  @override
  Widget build(BuildContext context) {
    final recording = widget.recording;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: SizedBox(
        width: 44,
        height: 44,
        child: recording
            // ⚠️ VIDE PENDANT L'ENREGISTREMENT. Ce créneau montrait
            // `_LockHint` — un petit cadenas et un petit micro rouge qui
            // montait — alors que la surcouche dessine déjà LE cadenas et
            // LE cercle, au même endroit. Deux cadenas pour une seule
            // information, dont un caché sous le grand cercle et visible
            // seulement par ses bords. Telegram n'en a qu'un.
            //
            // Le créneau garde sa taille : c'est lui qui reçoit le doigt,
            // et le `Listener` au-dessus a besoin d'une surface.
            ? const SizedBox.shrink()
            // Au trait et en gris, comme dans Messages : au repos, le
            // micro est un accessoire. C'est le grand cercle, à la pose
            // du doigt, qui prend la couleur.
            : Center(
                child: Icon(
                  widget.modeVideo
                      ? Icons.videocam_outlined
                      : Icons.mic_none_rounded,
                  color: OuroColors.secondaryLabel,
                  size: 26,
                ),
              ),
      ),
    );
  }
}

/// État partagé du glissement pendant qu'on maintient le micro : vers la
/// gauche pour annuler, vers le haut pour verrouiller (mains libres).
/// Écrit par [_MicButton], lu par [_RecordingBar] et par la surcouche
/// (cercle et cadenas) de l'écran de conversation.
/// ⚠️ CETTE CLASSE N'EST PLUS QU'UNE VITRINE. La décision — annuler,
/// verrouiller, envoyer — est prise par [GesteEnregistrement], dans
/// `geste_enregistrement.dart`, parce que là-bas elle se rejoue hors de
/// Flutter : quinze enchaînements, dont la diagonale du pouce et
/// l'interruption système, passent à chaque modification.
///
/// L'ancienne version décidait ici, avec deux seuils en dur (96 et 56) et
/// une règle de priorité maison (`-dy > -dx * 0.8`). Elle se trompait sur
/// deux points qu'on ne voit qu'en les rejouant :
///
///   • un glissement à moitié puis un relâchement N'ANNULAIT PAS, alors
///     que c'est une hésitation et que ça doit annuler ;
///   • une interruption du système — appel entrant, volet de
///     notifications tiré — JETAIT l'enregistrement, alors que ce n'est
///     pas une décision de l'utilisateur et qu'il faut le garder.
class _RecordDrag extends ChangeNotifier {
  GesteEnregistrement? _geste;

  /// Posé par [_MicButton] à la première pose du doigt : c'est lui qui
  /// connaît la largeur de l'écran, dont dépend la course d'annulation.
  set geste(GesteEnregistrement g) {
    _geste = g;
    notifyListeners();
  }

  GesteEnregistrement? get geste => _geste;

  /// 0 → 1 : progression vers l'annulation.
  double get cancelT => 1 - (_geste?.progressionAnnulation ?? 1);

  /// 0 → 1 : progression vers le verrouillage.
  double get lockT => _geste?.progressionVerrou ?? 0;

  /// De combien le texte « glisser pour annuler » s'est déplacé.
  double get decalageTexte => _geste?.decalageTexte ?? 0;

  void rafraichir() => notifyListeners();

  /// ⚠️ À N'APPELER QU'UNE FOIS L'ENREGISTREMENT TERMINÉ. Pendant qu'un
  /// doigt est posé, remettre la machine au repos lui fait ignorer tout
  /// mouvement suivant — c'est exactement le défaut qui empêchait de
  /// verrouiller et d'annuler. Pour simplement redessiner, `rafraichir()`.
  void reset() {
    _geste?.reinitialiser();
    notifyListeners();
  }
}

/// La rangée d'enregistrement « maintenu » : pastille rouge qui bat,
/// compteur qui fait défiler ses chiffres, et l'indice « ‹ Glisser pour
/// annuler » qui suit le doigt vers la gauche et rougit à l'approche du
/// seuil.
class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.debut,
    required this.amplitudes,
    required this.drag,
    required this.pulse,
    required this.hint,
    required this.verrouille,
    required this.texteAnnuler,
    required this.onAnnuler,
  });

  /// L'instant de départ. ⚠️ PAS UN NOMBRE DE SECONDES : un compteur
  /// incrémenté par un minuteur dérive dès qu'une image saute, et sur
  /// deux minutes l'écart se voit.
  final DateTime debut;

  final List<double> amplitudes;
  final _RecordDrag drag;
  final Animation<double> pulse;
  final String hint;

  /// Verrouillé : l'invite « glisser » n'a plus de sens, le doigt est
  /// parti. Elle devient un vrai bouton.
  final bool verrouille;

  final String texteAnnuler;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([drag, pulse]),
      builder: (context, _) {
        final cancelT = drag.cancelT;
        // L'indice suit le doigt (amorti), puis s'efface près du seuil.
        // Le texte suit la course réelle calculée par la machine — plafonnée
        // à 35 % de la largeur ou 140 points, selon ce qui est le plus petit.
        final hintShift = drag.decalageTexte;

        return SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 12),
              // ⚠️ LE CHRONO AU CENTIÈME, PAS À LA SECONDE. Un compteur
              // qui n'avance qu'une fois par seconde laisse, pendant
              // neuf dixièmes du temps, une interface strictement
              // immobile : on doute que ça enregistre. Les centièmes
              // n'ont aucune valeur de LECTURE — personne ne les lit —
              // mais ils ont une valeur de PREUVE.
              ChronoEnregistrement(debut: debut),
              // ⚠️ LA PASTILLE APRÈS LE CHRONO, PAS AVANT : « 0:02,7 ● »
              // sur la capture de Telegram. Le chiffre est ce qu'on lit,
              // il prend le bord ; le point rouge le ponctue.
              const SizedBox(width: 8),
              _PulseDot(pulse: pulse),
              Expanded(
                child: ClipRect(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(hintShift, 0),
                      child: GlisserPourAnnuler(
                        progression: 1 - cancelT,
                        verrouille: verrouille,
                        texte: hint,
                        texteAnnuler: texteAnnuler,
                        onAnnuler: onAnnuler,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        );
      },
    );
  }
}

/// La pastille rouge qui respire pendant l'enregistrement.
class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: OuroColors.systemRed.withValues(
            alpha: 0.45 + pulse.value * 0.55,
          ),
        ),
      ),
    );
  }
}



/// Le bouton d'envoi (flèche/avion en papier) — un tap simple envoie
/// normalement, avec une petite onde qui éclate ; un appui long ouvre le
/// menu d'effets spéciaux ([_EffectPicker]) façon Telegram.
class _AnimatedSendButton extends StatefulWidget {
  const _AnimatedSendButton({required this.active, required this.onSend});
  final bool active;
  final void Function([String? effect]) onSend;

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton> {
  bool _pressed = false;

  void _handleTap([String? effect]) {
    if (!widget.active) return;
    OuroHaptics.light();
    widget.onSend(effect);
  }

  Future<void> _openEffectPicker() async {
    if (!widget.active) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    final effect = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _EffectPicker(),
    );
    if (effect != null) _handleTap(effect);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _openEffectPicker,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Center(
          child: LiquidSendButton(
            enabled: widget.active,
            onPressed: _handleTap,
            size: 22,
            color: OuroColors.accent,
          ),
        ),
      ),
    );
  }
}

/// Feuille de sélection d'un effet de message (appui long sur le bouton
/// d'envoi), façon Telegram — effets de bulle (rejoués une fois sur le
/// message lui-même) et effets plein écran (overlay chez l'expéditeur ET le
/// destinataire), voir `message_effects.dart`.
class _EffectPicker extends StatelessWidget {
  const _EffectPicker();

  /// Les libellés dépendent de la langue : ces listes ne peuvent donc
  /// plus être `const` — voir le même choix pour `_ImageFilter` dans
  /// `status_composer.dart`.
  static List<(String, IconData, String)> _bubbleOptions(
    AppLocalizations l10n,
  ) => [
    (kEffectSlam, Icons.bolt_rounded, l10n.chEffectBoom),
    (kEffectLoud, Icons.campaign_rounded, l10n.chEffectLoud),
    (kEffectGentle, Icons.spa_rounded, l10n.chEffectGentle),
    (
      kEffectInvisibleInk,
      Icons.visibility_off_rounded,
      l10n.chEffectInvisibleInk,
    ),
  ];

  static List<(String, IconData, String)> _fullscreenOptions(
    AppLocalizations l10n,
  ) => [
    (kEffectConfetti, Icons.celebration_rounded, l10n.chEffectConfetti),
    (kEffectFireworks, Icons.auto_awesome_rounded, l10n.chEffectFireworks),
    (kEffectHearts, Icons.favorite_rounded, l10n.chEffectHearts),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FrostedSheet(
        child: SafeArea(
          top: false,
          // Filet de sécurité sur petit écran / grande police système : le
          // contenu défile plutôt que de déborder silencieusement (un
          // `Column` figé ici avait déjà causé une feuille vide invisible
          // quand l'espace disponible se réduisait sous le clavier).
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chEffectSheetTitle,
                  style: TextStyle(
                    color: OuroColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.chEffectSheetSubtitle,
                  style: TextStyle(
                    color: OuroColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chOnBubble,
                  style: TextStyle(
                    color: OuroColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _bubbleOptions(l10n)
                      .map(
                        (o) => _EffectChip(
                          icon: o.$2,
                          label: o.$3,
                          onTap: () => Navigator.of(context).pop(o.$1),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.chFullscreen,
                  style: TextStyle(
                    color: OuroColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _fullscreenOptions(l10n)
                      .map(
                        (o) => _EffectChip(
                          icon: o.$2,
                          label: o.$3,
                          onTap: () => Navigator.of(context).pop(o.$1),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Une seule option cliquable dans le menu d'effets (icône + nom, comme
/// « ⚡ Boom » ou « 🎉 Confettis »).
class _EffectChip extends StatelessWidget {
  const _EffectChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: OuroCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: DesignTokens.radiusFull,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: OuroColors.meshBlueBright),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: OuroColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Effet de bulle « Encre invisible » (iMessage) : le contenu est masqué par
/// une surface bruitée jusqu'à ce qu'on tape dessus pour la révéler. Reste
/// révélé ensuite pour la durée de vie de la bulle (pas de re-masquage
/// automatique) — suffisant pour l'effet de surprise recherché.
class _InvisibleInkReveal extends StatefulWidget {
  const _InvisibleInkReveal({required this.child});
  final Widget child;

  @override
  State<_InvisibleInkReveal> createState() => _InvisibleInkRevealState();
}

class _InvisibleInkRevealState extends State<_InvisibleInkReveal> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _revealed
          ? null
          : () {
              HapticFeedback.mediumImpact();
              setState(() => _revealed = true);
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: _revealed ? 1 : 0, child: widget.child),
          if (!_revealed)
            AnimatedOpacity(
              opacity: _revealed ? 0 : 1,
              duration: DesignTokens.durationNormal,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _NoisePainter(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      l10n.chTapToReveal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dessine le petit fond « grésillement » (comme un vieux poste de
/// télé mal réglé) qui recouvre un message « encre invisible » avant
/// qu'on ne tape dessus pour le révéler.
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = OuroColors.textTertiary.withValues(alpha: 0.9),
    );
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.25);
    for (int i = 0; i < 140; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        1.2,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => false;
}

/// La bulle qui répond sous le doigt.
///
/// ⚠️ C'EST LE MANQUE LE PLUS COÛTEUX DE TOUT L'ÉCRAN, et le moins
/// visible à la lecture du code.
///
/// La bulle n'avait que `onLongPress` et `onDoubleTap`. Entre le moment
/// où le doigt se pose et celui où le menu s'ouvre — environ une
/// demi-seconde — il ne se passait STRICTEMENT RIEN. L'utilisateur
/// touche, l'écran reste figé, et il ne sait pas si son geste a été
/// pris. C'est ce silence-là qu'on ressent comme de la lenteur, bien
/// plus que la durée réelle d'une animation.
///
/// Telegram et iMessage répondent à l'instant du contact : la bulle
/// s'enfonce légèrement, et revient. Le geste est acquitté avant même
/// d'être terminé.
///
/// Le retour utilise un RESSORT et non une durée fixe. La différence
/// compte ici : un ressort repart de la valeur courante avec sa vitesse
/// courante. Relâcher pendant que la bulle s'enfonce la fait remonter
/// depuis où elle en est, sans à-coup — là où une courbe à durée fixe
/// redémarrerait du début et produirait un ressaut.
class _BullePressable extends StatefulWidget {
  const _BullePressable({
    required this.child,
    required this.onLongPress,
    this.onDoubleTap,
  });

  final Widget child;
  final VoidCallback onLongPress;
  final VoidCallback? onDoubleTap;

  @override
  State<_BullePressable> createState() => _BullePressableState();
}

class _BullePressableState extends State<_BullePressable> {
  bool _presse = false;

  void _set(bool v) {
    if (_presse != v && mounted) setState(() => _presse = v);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidLongPressOverlay(
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      child: GestureDetector(
        onLongPress: () {
          _set(false);
          widget.onLongPress();
        },
        onDoubleTap: widget.onDoubleTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onLongPressCancel: () => _set(false),
        onLongPressEnd: (_) => _set(false),
        child: _presse
            ? SingleMotionBuilder(
                motion: CupertinoMotion.snappy(),
                value: 0.965,
                from: 1.0,
                builder: (context, echelle, _) => Transform.scale(
                  scale: echelle,
                  alignment: Alignment.bottomCenter,
                  child: widget.child,
                ),
              )
            : widget.child,
      ),
    );
  }
}

/// Une petite zone touchable, annoncée correctement au lecteur d'écran.
///
/// ⚠️ La cible est ÉLARGIE au-delà de l'heure elle-même. Un texte de onze
/// points fait une hauteur de cible d'environ quinze : très en dessous
/// des quarante-quatre points recommandés. Sans cet élargissement, le
/// geste serait théoriquement disponible et pratiquement introuvable.
class _TapCible extends StatelessWidget {
  const _TapCible({
    required this.child,
    required this.onTap,
    required this.semantique,
    this.marge = const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  });

  final Widget child;
  final VoidCallback onTap;
  final String semantique;

  /// La marge qui élargit la cible.
  ///
  /// ⚠️ ELLE DOIT ÊTRE NULLE DANS UNE BARRE DE TITRE. La hauteur d'une
  /// `AppBar` est fixe (56 points) ; les douze points ajoutés par la
  /// marge par défaut suffisaient à faire déborder la colonne
  /// nom + statut, qui venait alors se superposer à l'avatar et au
  /// bouton retour. Là où la rangée est déjà haute, la cible est de
  /// toute façon assez grande sans marge.
  final EdgeInsets marge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantique,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(padding: marge, child: child),
      ),
    );
  }
}

/// Le geste « glisser pour répondre », façon Telegram.
///
/// Voir la note détaillée sur `_dismissibleEntry` pour le pourquoi. Ici,
/// le comment.
class _GlisserPourRepondre extends StatefulWidget {
  const _GlisserPourRepondre({required this.child, required this.onRepondre});

  final Widget child;
  final VoidCallback onRepondre;

  @override
  State<_GlisserPourRepondre> createState() => _GlisserPourRepondreState();
}

class _GlisserPourRepondreState extends State<_GlisserPourRepondre> {
  /// Le déplacement courant de la bulle, en points.
  double _dx = 0;

  /// Vrai une fois le seuil franchi — sert à ne vibrer QU'UNE fois.
  bool _arme = false;

  /// La distance à parcourir pour déclencher la réponse.
  ///
  /// 56 points : assez pour qu'un défilement horizontal accidentel ne
  /// l'atteigne pas, assez peu pour rester un geste du pouce et non un
  /// mouvement du bras.
  static const double _seuil = 56;

  void _maj(DragUpdateDetails d) {
    var x = _dx + d.delta.dx;
    if (x < 0) x = 0; // jamais vers la gauche
    // Au-delà du seuil, la bulle résiste : le doigt avance trois fois
    // plus vite qu'elle.
    if (x > _seuil) x = _seuil + (x - _seuil) / 3;

    final atteint = x >= _seuil;
    if (atteint && !_arme) {
      _arme = true;
      OuroHaptics.light();
    } else if (!atteint && _arme) {
      _arme = false;
    }
    setState(() => _dx = x);
  }

  void _fin() {
    if (_arme) widget.onRepondre();
    _arme = false;
    setState(() => _dx = 0);
  }

  @override
  Widget build(BuildContext context) {
    // L'opacité de la flèche suit le geste : elle apparaît en même temps
    // qu'on tire, ce qui rend le geste découvrable sans l'expliquer.
    final avance = (_dx / _seuil).clamp(0.0, 1.0);

    return GestureDetector(
      // `horizontal` seulement : le défilement vertical de la
      // conversation doit continuer de passer.
      onHorizontalDragUpdate: _maj,
      onHorizontalDragEnd: (_) => _fin(),
      onHorizontalDragCancel: _fin,
      child: Stack(
        // ⚠️ `passthrough` EST INDISPENSABLE ICI, et son absence a mis
        // TOUS les messages à gauche — y compris les miens.
        //
        // Par défaut, un `Stack` donne à ses enfants non positionnés des
        // contraintes LÂCHES : la bulle se rétrécit alors à la largeur de
        // son texte, au lieu de recevoir toute la largeur de la
        // conversation. Or c'est précisément cette largeur pleine qui
        // permet au `crossAxisAlignment: end` de la colonne de pousser la
        // bulle vers la droite. Sans elle, il n'y a plus d'espace à
        // droite, et l'alignement n'a plus de sens : tout se tasse à
        // gauche, au coin haut-gauche imposé par le `Stack`.
        //
        // Le `Dismissible` qui occupait cette place auparavant
        // transmettait des contraintes serrées — d'où un défaut apparu
        // exactement au moment où on l'a remplacé.
        fit: StackFit.passthrough,
        children: [
          // La flèche, révélée derrière la bulle qui s'écarte.
          //
          // ⚠️ Elle n'est CONSTRUITE que pendant le geste. Auparavant
          // elle existait en permanence, à opacité nulle — et un
          // `Opacity` force un rendu hors-écran même quand il ne montre
          // rien. Sur cinquante messages, cela faisait cinquante couches
          // hors-écran par image pour dessiner cinquante flèches
          // invisibles.
          if (_dx > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Opacity(
                    opacity: avance,
                    child: Transform.scale(
                      // Elle grandit jusqu'à sa taille pleine au seuil :
                      // le geste a un aboutissement visible.
                      scale: 0.6 + 0.4 * avance,
                      child: Icon(
                        Icons.reply_rounded,
                        size: 20,
                        color: OuroColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // La bulle suit le doigt, et revient par un ressort.
          //
          // Même règle que pour l'état pressé : tant qu'on n'a rien
          // tiré, pas de contrôleur du tout. Voir la note dans
          // `_BullePressableState`.
          if (_dx == 0)
            widget.child
          else
            SingleMotionBuilder(
              motion: CupertinoMotion.snappy(),
              value: _dx,
              builder: (context, x, _) => Transform.translate(
                offset: Offset(x, 0),
                child: widget.child,
              ),
            ),
        ],
      ),
    );
  }
}

/// La forme d'une bulle façon WhatsApp : un rectangle arrondi, plus une
/// petite pointe triangulaire du côté de son auteur.
///
/// ⚠️ POURQUOI UNE FORME SUR MESURE PLUTÔT QU'UN COIN MOINS ARRONDI.
///
/// La version précédente marquait le locuteur en réduisant un seul
/// rayon : 22 partout, 8 sur le coin du bas. C'est le procédé
/// d'iMessage, et il fonctionne — mais il ne se voit qu'à condition de
/// comparer deux bulles côte à côte. WhatsApp, lui, fait DÉBORDER une
/// pointe hors du rectangle : la bulle désigne physiquement celui qui
/// parle, même isolée au milieu d'un écran.
///
/// C'est le marqueur le plus reconnaissable de leur conversation, et
/// c'est purement géométrique — il n'emporte aucune de leurs couleurs.
///
/// La pointe n'apparaît que sur la DERNIÈRE bulle d'une série : une
/// pile de bulles toutes pointues ressemble à une scie.

// ─────────────────────────────────────────────────────────────
//  TEXTE DÉROULABLE (WhatsApp-style)
// ─────────────────────────────────────────────────────────────

/// Seuil au-delà duquel un message est tronqué avec un bouton
/// « Voir plus ». 100 caractères correspond à environ 4 lignes
/// sur un écran de téléphone — assez pour le contexte, pas
/// assez pour devoir scroller.
const int _kExpandThreshold = 100;

/// Texte qui se déroule progressivement : tronqué à 100 caractères
/// avec un bouton « Voir plus », puis déroulé progressivement
/// (+100 caractères à chaque tap) jusqu'au texte complet, avec un
/// bouton « Replier » une fois entièrement étendu.
///
/// Reproduit exactement le comportement de WhatsApp pour les
/// messages longs.
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText>
    with SingleTickerProviderStateMixin {
  /// Nombre de caractères actuellement visibles.
  late int _maxLength;

  /// Le texte est-il entièrement déplié ?
  bool get _isExpanded => _maxLength >= widget.text.length;

  /// Le texte est-il long enough pour être tronqué ?
  bool get _isTruncatable => widget.text.length > _kExpandThreshold;

  @override
  void initState() {
    super.initState();
    _maxLength = _isTruncatable ? _kExpandThreshold : widget.text.length;
  }

  @override
  void didUpdateWidget(covariant _ExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _maxLength = _isTruncatable ? _kExpandThreshold : widget.text.length;
    }
  }

  void _toggleExpand() {
    setState(() {
      if (_isExpanded) {
        // Replier : revenir au seuil initial.
        _maxLength = _kExpandThreshold;
      } else {
        // Dérouler de 100 caractères de plus, ou tout afficher si proche.
        final next = _maxLength + _kExpandThreshold;
        _maxLength = next >= widget.text.length ? widget.text.length : next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_isTruncatable) {
      // Message court : texte simple, pas de bouton.
      return Text(widget.text, style: widget.style);
    }

    final displayText = _isExpanded
        ? widget.text
        : '${widget.text.substring(0, _maxLength)}…';

    // Le bouton « plus » prend la couleur du texte qu'il prolonge.
    //
    // ⚠️ ON MESURE, ON NE COMPARE PAS. Ce test comparait autrefois la
    // couleur à `Colors.white` : dès que le texte des bulles a cessé
    // d'être blanc pur (accent jaune → texte noir), la comparaison
    // échouait en silence et le bouton repassait en bleu au milieu d'une
    // bulle colorée. La luminance, elle, reste vraie quelle que soit la
    // teinte choisie dans les réglages.
    final encre = widget.style.color ?? OuroColors.label;
    final surCouleur = encre.computeLuminance() > 0.6;
    final buttonColor =
        surCouleur ? encre.withValues(alpha: 0.7) : OuroColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(displayText, style: widget.style),
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _isExpanded
                  ? l10n.chCollapse
                  : _maxLength >= widget.text.length
                  ? l10n.chCollapse
                  : l10n.chSeeMore,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: buttonColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormeBulle extends ShapeBorder {
  const _FormeBulle({
    required this.rayon,
    required this.rayonQueue,
    required this.mine,
    required this.goutte,
    this.couleurReflet,
  });

  final double rayon;

  /// Le rayon du coin bas, du côté de l'auteur.
  final double rayonQueue;

  /// Le côté de l'auteur : droite pour mes messages.
  final bool mine;

  /// LA SIGNATURE DE DROPLET.
  ///
  /// Sur la dernière bulle d'une série, le coin du côté de l'auteur est TIRÉ
  /// comme une goutte au bord d'une surface : deux courbes tangentes aux
  /// bords se rejoignent en une pointe arrondie, à peine sortie du
  /// rectangle. Les autres messageries posent un triangle (WhatsApp), un
  /// coin moins arrondi (iMessage) ou rien (Signal) ; ici c'est une goutte —
  /// on doit reconnaître l'app à cette silhouette, sans logo ni nom.
  final bool goutte;

  /// La lumière posée sur l'arête haute : un cheveu clair qui s'éteint aux
  /// deux coins, comme un reflet sur l'eau. `null` quand la bulle est
  /// transparente (autocollants, réponses de l'Assistant).
  final Color? couleurReflet;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = math.min(rayon, rect.shortestSide / 2);
    final rq = math.min(rayonQueue, rect.shortestSide / 2);
    final corps = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomLeft: Radius.circular(mine ? r : rq),
          bottomRight: Radius.circular(mine ? rq : r),
        ),
      );
    if (!goutte) return corps;

    // ── ⚠️ UNE QUEUE PLEINE, PAS UN CROCHET ─────────────────────────────
    //
    // L'ancienne goutte sortait de 3 points du rectangle puis repartait
    // VERS L'INTÉRIEUR en passant sous le bord bas : à l'écran, une fine
    // virgule recourbée accrochée au coin, détachée de la bulle — on
    // aurait dit un défaut de dessin, pas une forme voulue.
    //
    // Celle-ci est une vraie queue pleine : le bord vertical de la bulle
    // descend, s'évase vers l'extérieur jusqu'à une pointe posée au niveau
    // du bas, puis revient en creux rejoindre le bord inférieur. C'est la
    // silhouette d'iMessage : la queue PROLONGE la bulle, elle ne s'y
    // accroche pas. Elle tient dans les 7 points réservés du côté de
    // l'auteur (voir la marge asymétrique du conteneur).
    final h = math.min(16.0, rect.height * 0.45);
    const pointe = 6.0;
    final y = rect.bottom;
    final goutteChemin = Path();
    if (mine) {
      final x = rect.right;
      goutteChemin
        ..moveTo(x, y - h)
        ..cubicTo(x, y - h * 0.38, x + 1.5, y - 1.2, x + pointe, y + 0.2)
        ..cubicTo(x + 1.8, y + 1.6, x - 3.5, y + 1.2, x - 9, y - 1.2)
        ..lineTo(x - 9, y - h)
        ..close();
    } else {
      final x = rect.left;
      goutteChemin
        ..moveTo(x, y - h)
        ..cubicTo(x, y - h * 0.38, x - 1.5, y - 1.2, x - pointe, y + 0.2)
        ..cubicTo(x - 1.8, y + 1.6, x + 3.5, y + 1.2, x + 9, y - 1.2)
        ..lineTo(x + 9, y - h)
        ..close();
    }
    return Path.combine(PathOperation.union, corps, goutteChemin);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final couleur = couleurReflet;
    if (couleur == null || rect.width < 28 || rect.height < 20) return;
    final interieur = rect.deflate(0.8);
    final r = math.max(math.min(rayon, interieur.shortestSide / 2) - 0.8, 0.5);
    final diagonale = r * 0.7071;
    final chemin = Path()
      ..moveTo(interieur.left + r - diagonale, interieur.top + r - diagonale)
      ..arcToPoint(
        Offset(interieur.left + r, interieur.top),
        radius: Radius.circular(r),
      )
      ..lineTo(interieur.right - r, interieur.top)
      ..arcToPoint(
        Offset(interieur.right - r + diagonale, interieur.top + r - diagonale),
        radius: Radius.circular(r),
      );
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        // La lumière s'éteint aux deux coins : un trait qui irait jusqu'au
        // bout se verrait comme un liseré, pas comme un reflet.
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            couleur.withValues(alpha: 0),
            couleur,
            couleur,
            couleur.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.78, 1],
        ).createShader(rect),
    );
  }

  @override
  ShapeBorder scale(double t) => _FormeBulle(
    rayon: rayon * t,
    rayonQueue: rayonQueue * t,
    mine: mine,
    goutte: goutte,
    couleurReflet: couleurReflet,
  );

  @override
  bool operator ==(Object other) =>
      other is _FormeBulle &&
      other.rayon == rayon &&
      other.rayonQueue == rayonQueue &&
      other.mine == mine &&
      other.goutte == goutte &&
      other.couleurReflet == couleurReflet;

  @override
  int get hashCode =>
      Object.hash(rayon, rayonQueue, mine, goutte, couleurReflet);
}

/// Le dégradé d'une bulle à moi : la MÊME couleur, à peine plus claire en
/// haut. C'est ce qui lui donne une matière — de l'eau éclairée par le haut —
/// sans rien changer à la couleur choisie dans Apparence.
LinearGradient _degradeBulle(Color fond) {
  final hsl = HSLColor.fromColor(fond);
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      hsl.withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0)).toColor(),
      fond,
    ],
  );
}

/// La force du reflet : franc sur une bulle claire, discret sur une bulle
/// foncée ou colorée.
Color _refletBulle(Color fond) => fond.computeLuminance() > 0.6
    ? Colors.white.withValues(alpha: 0.75)
    : Colors.white.withValues(alpha: 0.16);

/// Une icône discrète logée DANS la pilule de saisie.
///
/// Taille de cible portée à 40 points malgré une icône de 22 : dans une
/// barre où l'on vise vite et souvent, une cible à la taille exacte du
/// dessin se rate une fois sur trois.
class _IconePilule extends StatelessWidget {
  const _IconePilule({
    // ⚠️ `super.key` AJOUTÉ POUR LES VISITES GUIDÉES. Sans lui, passer une
    // `GlobalKey` à ce widget ne compile pas — et l'erreur parle d'un
    // paramètre nommé inconnu, pas d'une clé manquante.
    super.key,
    required this.icone,
    required this.tooltip,
    required this.onTap,
    this.taille = 22,
  });

  final IconData icone;
  final String tooltip;
  final VoidCallback onTap;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          OuroHaptics.light();
          onTap();
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icone,
            // Gris et non bleu : ce sont des accessoires. Le bleu est
            // réservé au bouton rond, qui porte l'action principale.
            color: OuroColors.secondaryLabel,
            size: taille,
          ),
        ),
      ),
    );
  }
}

/// Le disque plein qui porte l'action principale de la barre de saisie.
///
/// iMessage : 30pt circle, background #007AFF, icon arrow-up, 15pt.
/// Pressed: scale 0.92 + slight darken.
class _BoutonRond extends StatelessWidget {
  const _BoutonRond({super.key, required this.child});

  final Widget child;

  /// iMessage : 30pt circle for the send button.
  static const double taille = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: OuroColors.accent,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Feuille modale affichant les messages d'un fil de discussion.
class _ThreadSheet extends StatefulWidget {
  const _ThreadSheet({
    required this.parent,
    required this.threadId,
    required this.messages,
    required this.onReply,
  });

  final MeshMessage parent;
  final String threadId;
  final List<MeshMessage> messages;
  final ValueChanged<String> onReply;

  @override
  State<_ThreadSheet> createState() => _ThreadSheetState();
}

class _ThreadSheetState extends State<_ThreadSheet> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onReply(text);
    _ctrl.clear();
    HapticFeedback.lightImpact();
    // Scroll vers le bas après un court délai pour laisser le temps
    // au message d'apparaître.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: OuroColors.systemGroupedBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: OuroColors.separator,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.chThreadTitle,
                style: OuroTypography.headline.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
            // Messages du fil
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: widget.messages.length,
                itemBuilder: (ctx, i) {
                  final m = widget.messages[i];
                  final isParent = m.id == widget.parent.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isParent
                          ? OuroColors.accent.withValues(alpha: 0.08)
                          : OuroColors.secondarySystemGroupedBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: isParent
                          ? Border.all(
                              color: OuroColors.accent.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              m.authorPseudo,
                              style: OuroTypography.caption1.copyWith(
                                color: OuroColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(m.timestamp),
                              style: OuroTypography.caption2.copyWith(
                                color: OuroColors.tertiaryLabel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.content,
                          style: OuroTypography.subheadline.copyWith(
                            color: OuroColors.label,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Champ de réponse
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: OuroColors.systemGroupedBackground,
                border: Border(
                  top: BorderSide(color: OuroColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: OuroTypography.body.copyWith(
                        color: OuroColors.label,
                      ),
                      cursorColor: OuroColors.accent,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: l10n.chReplyHint,
                        hintStyle: OuroTypography.body.copyWith(
                          color: OuroColors.tertiaryLabel,
                        ),
                        filled: true,
                        fillColor: OuroColors.tertiarySystemFill,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.accentRempli,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: OuroColors.texteSurAccent,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

/// Les bulles déjà apparues pendant cette session.
final Set<String> _bullesApparues = <String>{};

/// Joue l'apparition d'une bulle UNE fois, et seulement pour un message qui
/// vient d'arriver.
///
/// ⚠️ LA LISTE RECYCLE SES BULLES. L'animation était posée sur chaque bulle
/// construite : en remontant dans l'historique puis en redescendant, tous
/// les messages déjà lus refaisaient leur entrée, et une conversation
/// ouverte « rejouait » chaque bulle visible. WhatsApp et Telegram n'animent
/// que ce qui ARRIVE.
///
/// La décision est prise une fois, à la création : l'arbre ne change jamais
/// de forme en cours de route (ce qui recréerait le lecteur d'une vidéo).
/// Le rebond de la pastille de réactions — QUAND une réaction arrive,
/// pas quand la bulle entre à l'écran.
///
/// ⚠️ L'ANCIENNE ANIMATION SE TROMPAIT DE MOMENT. Elle jouait à la
/// construction de la pastille : en remontant l'historique, chaque bulle
/// réagie rebondissait en entrant à l'écran — une rangée de pastilles qui
/// sautillent sans raison —, et la réaction qu'on venait de recevoir, sur
/// une bulle déjà visible, ne bougeait pas du tout.
///
/// Ici, rien au montage. Le rebond part quand la [signature] change : un
/// émoji ajouté, retiré, remplacé. iMessage fait exactement ça — la
/// pastille gonfle à 1,25, retombe un peu sous sa taille, se pose.
class _RebondReaction extends StatefulWidget {
  const _RebondReaction({required this.signature, required this.child});

  final String signature;
  final Widget child;

  @override
  State<_RebondReaction> createState() => _RebondReactionState();
}

class _RebondReactionState extends State<_RebondReaction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: 1,
  );

  /// 1 → 1,25 → 0,94 → 1 : le gonflement, la retombée, la pose.
  late final Animation<double> _echelle = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.6, end: 1.25)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.25, end: 0.94)
          .chain(CurveTween(curve: Curves.easeInOutSine)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.94, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutSine)),
      weight: 35,
    ),
  ]).animate(_c);

  @override
  void didUpdateWidget(_RebondReaction vieux) {
    super.didUpdateWidget(vieux);
    if (vieux.signature != widget.signature &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _echelle,
      child: widget.child,
    );
  }
}

class _EntreeBulle extends StatefulWidget {
  const _EntreeBulle({
    required this.id,
    required this.horodatage,
    required this.construire,
    required this.child,
  });

  final String id;
  final DateTime horodatage;
  final Widget Function(Widget bulle) construire;
  final Widget child;

  @override
  State<_EntreeBulle> createState() => _EntreeBulleState();
}

class _EntreeBulleState extends State<_EntreeBulle> {
  late final bool _jouer;

  @override
  void initState() {
    super.initState();
    final premiereFois = _bullesApparues.add(widget.id);
    _jouer =
        premiereFois &&
        DateTime.now().difference(widget.horodatage).abs() <
            const Duration(seconds: 45);
  }

  @override
  Widget build(BuildContext context) =>
      _jouer ? widget.construire(widget.child) : widget.child;
}

/// La barre « N messages non lus » posée au-dessus du premier d'entre eux.
/// La barre des messages épinglés, collée sous l'en-tête.
///
/// ── CE QU'ON A REPRIS DE TELEGRAM, ET POURQUOI ──────────────────────
///
///   • LE TRAIT VERTICAL SEGMENTÉ à gauche : un segment par épinglé, celui
///     qu'on voit en couleur. On sait d'un coup d'œil qu'il y en a trois et
///     lequel est affiché, sans lire un « 2 sur 3 ».
///   • UN TOUCHER = Y ALLER, et la barre passe à l'épinglé suivant. Trois
///     touchers font le tour ; aucune liste à ouvrir.
///   • LA PUNAISE À DROITE désépingle celui qu'on voit — pour tout le
///     monde, comme elle avait épinglé.
///
/// Même verre que l'en-tête : elle en paraît le prolongement, pas un
/// bandeau collé dessous.
/// La vignette carrée de la photo citée, dans le bandeau de réponse.
class _VignetteReponse extends StatefulWidget {
  const _VignetteReponse({required this.fileId, required this.fileName});

  final String fileId;
  final String fileName;

  @override
  State<_VignetteReponse> createState() => _VignetteReponseState();
}

class _VignetteReponseState extends State<_VignetteReponse> {
  late final Future<String?> _chemin =
      StorageService.getSharedFilePath(widget.fileId, widget.fileName);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _chemin,
      builder: (context, instantane) {
        final chemin = instantane.data;
        if (chemin == null) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image(
            image: ResizeImage(FileImage(File(chemin)), width: 108),
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _BarreEpingles extends StatelessWidget {
  const _BarreEpingles({
    required this.epingles,
    required this.index,
    required this.resume,
    required this.onTap,
    required this.onDesepingler,
  });

  final List<MeshMessage> epingles;
  final int index;
  final String Function(MeshMessage) resume;
  final VoidCallback onTap;
  final VoidCallback onDesepingler;

  static const double hauteur = 50;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = epingles[index];
    final n = epingles.length;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: hauteur,
          decoration: BoxDecoration(
            color: OuroColors.systemBackground.withValues(alpha: 0.78),
            border: Border(
              bottom: BorderSide(
                color: OuroColors.separator.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, right: 4),
                child: Row(
                  children: [
                    // Le trait segmenté : un segment par épinglé.
                    SizedBox(
                      width: 2.5,
                      height: 34,
                      child: Column(
                        children: [
                          for (var i = 0; i < n; i++) ...[
                            if (i > 0) const SizedBox(height: 2),
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: i == index
                                      ? OuroColors.accent
                                      : OuroColors.accent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (enfant, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: enfant,
                          ),
                        ),
                        child: Column(
                          key: ValueKey(m.id),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n > 1
                                  ? l10n.chPinnedMessageN('${index + 1}/$n')
                                  : l10n.chPinnedMessage,
                              style: OuroTypography.caption1.copyWith(
                                color: OuroColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              resume(m),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OuroTypography.footnote.copyWith(
                                color: OuroColors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.chUnpin,
                      onPressed: onDesepingler,
                      icon: Icon(
                        Icons.push_pin_outlined,
                        size: 20,
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarreNonLus extends StatelessWidget {
  const _BarreNonLus({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: OuroColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppLocalizations.of(context).chUnreadMessages(nombre),
          style: OuroTypography.caption1.copyWith(
            color: OuroColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// La citation d'un STATUT au-dessus d'une réponse : sa vignette et
/// « Statut · Nom ». Tant que le statut vit sur ce téléphone, on voit la
/// photo (ou la première image de la vidéo) ; après, il n'en reste que le nom.
class _CitationStatut extends StatelessWidget {
  const _CitationStatut({required this.statusId, required this.mine});

  final String statusId;
  final bool mine;

  Future<String?> _vignette(StatusMedia media) async {
    final id = media.fileId;
    final nom = media.fileName;
    if (id == null || nom == null) return null;
    final chemin = await StorageService.getSharedFilePath(id, nom);
    if (chemin == null) return null;
    if (media.kind == StatusMediaKind.video) {
      return MediaService.vignetteVideo(chemin);
    }
    return chemin;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statut = StorageService.getActiveStatuses()
        .where((s) => s.id == statusId)
        .firstOrNull;
    final media = statut == null
        ? null
        : StorageService.getStatusMedia(statusId);
    final accent = mine ? OuroColors.bubbleOutgoingText : OuroColors.meshBlueBright;
    final auteur = statut == null
        ? null
        : (statut.authorId == StorageService.currentUser?.id
              ? l10n.svYourStatus
              : statut.authorPseudo);
    final texte = statut?.content.trim() ?? '';

    final Widget apercu;
    if (media != null &&
        (media.kind == StatusMediaKind.photo ||
            media.kind == StatusMediaKind.video)) {
      apercu = FutureBuilder<String?>(
        future: _vignette(media),
        builder: (context, instantane) {
          final chemin = instantane.data;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (chemin != null)
                Image(
                  image: ResizeImage(FileImage(File(chemin)), width: 120),
                  fit: BoxFit.cover,
                )
              else
                const ColoredBox(color: Colors.black26),
              if (media.kind == StatusMediaKind.video)
                const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          );
        },
      );
    } else if (media != null && media.kind == StatusMediaKind.voice) {
      apercu = ColoredBox(
        color: OuroColors.accentRempli,
        child: Icon(Icons.mic_rounded, color: OuroColors.texteSurAccent, size: 20),
      );
    } else {
      apercu = Container(
        color: media?.backgroundColor != null
            ? Color(media!.backgroundColor!)
            : OuroColors.accent,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        child: Text(
          texte.isEmpty ? '✦' : texte,
          maxLines: 3,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 7, height: 1.1),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: (mine ? OuroColors.bubbleOutgoingText : OuroColors.meshBlue).withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 10, 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    auteur ?? l10n.svStatusLabel,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.donut_large_rounded,
                        size: 12,
                        color: mine
                            ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
                            : OuroColors.secondaryLabel,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.svStatusLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: mine
                              ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.7)
                              : OuroColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (statut != null) SizedBox(width: 46, child: apercu),
          ],
        ),
      ),
    );
  }
}

/// Un appel manqué dans la conversation, comme WhatsApp : l'icône rouge, le
/// type d'appel, l'heure, et « Rappeler ».
class _BulleAppel extends StatelessWidget {
  const _BulleAppel({required this.message, required this.onRappeler});

  final MeshMessage message;
  final void Function(bool video) onRappeler;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final video = message.content.contains('"video":true');
    final heure = TimeOfDay.fromDateTime(message.timestamp).format(context);
    return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 1),
            child: Material(
              color: OuroColors.secondarySystemBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusBubble),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onRappeler(video),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: OuroColors.systemRed.withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          video
                              ? Icons.missed_video_call_rounded
                              : Icons.phone_missed_rounded,
                          color: OuroColors.systemRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video ? l10n.clMissedVideo : l10n.clMissedVoice,
                            style: TextStyle(
                              color: OuroColors.label,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            heure,
                            style: TextStyle(
                              color: OuroColors.secondaryLabel,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: OuroColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l10n.clCallBack,
                          style: TextStyle(
                            color: OuroColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 220.ms)
        .slideX(begin: -0.04, end: 0, duration: 260.ms);
  }
}

// ── Le verre de la barre de saisie ─────────────────────────────────────────

/// Le voile posé sur le flou : léger, pour que le fond de la discussion
/// transparaisse.
Color get _teinteVerre => OuroColors.isDark
    ? const Color(0xFF1C1C1E).withValues(alpha: 0.55)
    : Colors.white.withValues(alpha: 0.58);

/// La pilule du champ, creusée dans le verre plutôt que posée dessus.
Color get _teintePilule => OuroColors.isDark
    // Le `tertiarySystemFill` d'iOS : le gris du champ de Messages, assez
    // présent pour qu'on voie OÙ écrire, même sur le verre.
    ? const Color(0x3D767680)
    : const Color(0x1F767680);

/// Le fond du champ vu à travers le verre, pour la transition d'envoi.
Color get _couleurChampComposee =>
    Color.alphaBlend(_teintePilule, Color.alphaBlend(_teinteVerre, OuroColors.systemBackground));

/// +40 % de saturation sur ce qui passe derrière le verre, comme le
/// matériau d'Apple : les couleurs du fond restent vives au lieu de griser.
const List<double> _saturationVerre = [
  1.2885, -0.2503, -0.0382, 0, 0,
  -0.0747, 1.1117, -0.0370, 0, 0,
  -0.0747, -0.2503, 1.3250, 0, 0,
  0, 0, 0, 1, 0,
];

/// Le liseré du verre : plus lumineux en haut, presque effacé en bas.
class _LisereVerre extends CustomPainter {
  const _LisereVerre({required this.rayon, required this.sombre});

  final double rayon;
  final bool sombre;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.35);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rayon));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sombre
              ? [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.black.withValues(alpha: 0.06),
                ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LisereVerre old) => old.sombre != sombre || old.rayon != rayon;
}



/// La liste des personnes à mentionner, au-dessus de la barre de saisie.
///
/// Elle reprend les pseudos déposés par la discussion (`Mentions.pseudos`),
/// propose « tous » en tête quand il y a de quoi, et disparaît dès qu'on a
/// choisi. Quatre lignes visibles au plus : elle ne doit jamais manger la
/// conversation.
class _ChoixMention extends StatelessWidget {
  const _ChoixMention({required this.requete, required this.onChoisir});

  final String requete;
  final ValueChanged<String> onChoisir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = requete.toLowerCase();
    final noms = [
      for (final p in Mentions.pseudos)
        if (q.isEmpty || p.toLowerCase().contains(q)) p,
    ];
    final tous = q.isEmpty || Mentions.tous.startsWith(q);
    if (noms.isEmpty && !tous) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(maxHeight: 216),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        border: Border(top: BorderSide(color: OuroColors.separator, width: 0.5)),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          if (tous)
            _LigneMention(
              pseudo: Mentions.tous,
              titre: '@${Mentions.tous}',
              sousTitre: l10n.chMentionAllSubtitle,
              onTap: onChoisir,
            ),
          for (final p in noms)
            _LigneMention(pseudo: p, titre: p, onTap: onChoisir),
        ],
      ),
    );
  }
}

class _LigneMention extends StatefulWidget {
  const _LigneMention({
    required this.pseudo,
    required this.titre,
    required this.onTap,
    this.sousTitre,
  });

  final String pseudo;
  final String titre;
  final String? sousTitre;
  final ValueChanged<String> onTap;

  @override
  State<_LigneMention> createState() => _LigneMentionState();
}

class _LigneMentionState extends State<_LigneMention> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final tous = widget.pseudo == Mentions.tous;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap(widget.pseudo),
      onTapDown: (_) => setState(() => _appui = true),
      onTapUp: (_) => setState(() => _appui = false),
      onTapCancel: () => setState(() => _appui = false),
      child: Container(
        color: _appui ? OuroColors.systemFill : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            if (tous)
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OuroColors.accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.groups_rounded, size: 19, color: OuroColors.accent),
              )
            else
              PeerAvatar(pseudo: widget.pseudo, radius: 17),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.sousTitre != null)
                    Text(
                      widget.sousTitre!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le bandeau d'un salon vocal en cours, au-dessus de la barre de saisie.
///
/// Verre dépoli, les visages de ceux qui parlent, la durée qui court, et un
/// bouton pour entrer. Il ne clignote pas et ne sonne pas : un salon
/// attend, il ne réclame pas.
class _BandeauSalon extends StatelessWidget {
  const _BandeauSalon({
    required this.salon,
    required this.moi,
    required this.onRejoindre,
  });

  final SalonVocal salon;
  final String moi;
  final VoidCallback onRejoindre;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dedans = salon.participants.contains(moi);
    final autres = salon.participants.take(4).toList();
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: BoxDecoration(
            color: OuroColors.accent.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(color: OuroColors.separator, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.graphic_eq_rounded, size: 19, color: OuroColors.accent),
              const SizedBox(width: 10),
              // Les visages se chevauchent, comme une tablée : on voit
              // d'un coup qui est déjà là.
              SizedBox(
                width: 22.0 * autres.length + 10,
                height: 26,
                child: Stack(
                  children: [
                    for (var i = 0; i < autres.length; i++)
                      Positioned(
                        left: i * 18.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: OuroColors.systemBackground,
                              width: 1.5,
                            ),
                          ),
                          child: PeerAvatar(
                            pseudo: StorageService.getPeerRecord(autres[i])?.pseudo ??
                                '?',
                            radius: 12,
                            imagePath: AvatarService.cheminPair(autres[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.vrTitle,
                      maxLines: 1,
                      style: OuroTypography.subheadline.copyWith(
                        color: OuroColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.vrPeople(salon.participants.length),
                      maxLines: 1,
                      style: OuroTypography.caption1.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRejoindre,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: OuroColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    dedans ? l10n.vrBack : l10n.vrJoin,
                    style: OuroTypography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le flottement du cadenas au repos : 8 points de haut en bas, en
/// 1,67 s par aller (`idleProgress ± 0,01` par image, CAEV:2297-2308).
///
/// ⚠️ UN PETIT WIDGET À PART, PAS UN CONTRÔLEUR DE PLUS DANS L'ÉCRAN. Il
/// ne vit que pendant l'enregistrement : monté avec la colonne, libéré
/// avec elle. Logé dans l'écran, il tournerait pour rien le reste du temps.
class _FlottementVerrou extends StatefulWidget {
  const _FlottementVerrou({required this.builder});

  final Widget Function(BuildContext context, double flottement) builder;

  @override
  State<_FlottementVerrou> createState() => _FlottementVerrouState();
}

class _FlottementVerrouState extends State<_FlottementVerrou>
    with SingleTickerProviderStateMixin {
  // Linéaire, comme chez Telegram : un pas constant à chaque image.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1670),
  )..bouclerSiAmbiant(reverse: true, repos: 0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => widget.builder(context, _c.value),
      );
}
