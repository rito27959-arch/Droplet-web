// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Envoyer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get tabChats => 'Discussions';

  @override
  String get tabNews => 'Actus';

  @override
  String get tabCalls => 'Appels';

  @override
  String get tabPeers => 'Pairs';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get appearanceAuto => 'Automatique';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get appearanceFooter =>
      'Droplet est conçu pour le mode sombre : sur un écran OLED les pixels noirs sont éteints, ce qui économise la batterie et n\'éblouit pas dans l\'obscurité. Le mode clair reste disponible pour la lecture en plein soleil.';

  @override
  String get sectionLanguage => 'Langue';

  @override
  String get languageAuto => 'Automatique (langue du téléphone)';

  @override
  String get languageFooter =>
      '« Automatique » suit la langue réglée sur l\'appareil. Si cette langue n\'est pas encore prise en charge, Droplet reste en français.';

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get chatsSearchHint => 'Rechercher';

  @override
  String get chatsFilterAll => 'Toutes';

  @override
  String get chatsFilterUnread => 'Non lues';

  @override
  String get chatsFilterGroups => 'Groupes';

  @override
  String get chatsFilterPinned => 'Épinglées';

  @override
  String get chatsEmptyTitle => 'Aucune discussion';

  @override
  String get chatsEmptySubtitle =>
      'Approchez-vous d\'un appareil qui utilise Droplet : il apparaîtra ici automatiquement.';

  @override
  String get chatsSearchEmptyTitle => 'Aucun résultat';

  @override
  String get chatsSearchEmptySubtitle => 'Essayez un autre nom.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pairs à proximité',
      one: '$count pair à proximité',
      zero: 'Recherche de pairs…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Au moins 3 caractères';

  @override
  String get obChoosePseudo => 'Choisissez un pseudo pour commencer';

  @override
  String get obRestoreFailed => 'Échec de la restauration';

  @override
  String get obPhotoSaveFailed => 'Impossible d\'enregistrer la photo';

  @override
  String get obShareUnavailable => 'Partage indisponible';

  @override
  String get obBackupPasswordTitle => 'Mot de passe de la sauvegarde';

  @override
  String get obBackupPasswordMessage =>
      'Celui que vous aviez choisi en exportant votre identité.';

  @override
  String get obBackupPasswordPlaceholder => 'Mot de passe';

  @override
  String get obRestore => 'Restaurer';

  @override
  String get obSkipStep => 'Passer cette étape';

  @override
  String get obContinue => 'Continuer';

  @override
  String get obStart => 'Commencer';

  @override
  String get obAlreadyHaveBackup => 'J\'ai déjà une sauvegarde';

  @override
  String get obWelcomeTitle => 'Bienvenue dans\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Une messagerie qui fonctionne là où il n\'y a plus de réseau.';

  @override
  String get obFeatOfflineTitle => 'Sans internet, sans opérateur';

  @override
  String get obFeatOfflineText =>
      'Les téléphones se parlent directement, de proche en proche. Aucune antenne, aucune facture.';

  @override
  String get obFeatEncryptedTitle => 'Chiffré de bout en bout';

  @override
  String get obFeatEncryptedText =>
      'Même les téléphones qui relaient vos messages ne peuvent pas les lire.';

  @override
  String get obFeatLocalTitle => 'Rien ne quitte votre appareil';

  @override
  String get obFeatLocalText =>
      'Pas de compte, pas de serveur, pas de collecte. Vos conversations restent chez vous.';

  @override
  String get obRelayTitle => 'De proche\nen proche';

  @override
  String get obRelaySubtitle =>
      'Votre message saute d\'un téléphone à l\'autre jusqu\'à son destinataire, même si vous n\'êtes pas à portée directe.';

  @override
  String get obFeatCrowdTitle => 'Plus on est nombreux, plus loin ça porte';

  @override
  String get obFeatCrowdText =>
      'Chaque appareil à portée agrandit le réseau pour tout le monde.';

  @override
  String get obFeatNothingLostTitle => 'Rien ne se perd';

  @override
  String get obFeatNothingLostText =>
      'Un message destiné à quelqu\'un d\'absent attend, puis repart dès qu\'un chemin s\'ouvre.';

  @override
  String get obSafetyTitle => 'Se retrouver,\nsans réseau';

  @override
  String get obSafetySubtitle =>
      'Quand plus rien ne fonctionne, savoir où sont les autres et qu\'ils vont bien devient l\'information la plus utile.';

  @override
  String get obFeatMapTitle => 'Une carte qui marche hors ligne';

  @override
  String get obFeatMapText =>
      'Les zones que vous consultez restent sur le téléphone. Une fois parcourues, elles s\'affichent sans internet.';

  @override
  String get obFeatMeshPosTitle => 'Les positions viennent du mesh';

  @override
  String get obFeatMeshPosText =>
      'Aucun serveur : la position part du téléphone de votre contact, chiffrée, et saute d\'appareil en appareil jusqu\'au vôtre.';

  @override
  String get obFeatCheckinTitle => '« Je suis en sécurité », en un geste';

  @override
  String get obFeatCheckinText =>
      'Un seul appui diffuse votre statut à tout le voisinage. Vous choisissez d\'y joindre une position approximative, ou pas.';

  @override
  String get obStatusTitle => 'Donner des\nnouvelles';

  @override
  String get obStatusSubtitle =>
      'Une photo, un mot, une humeur : votre statut circule de téléphone en téléphone, comme vos messages.';

  @override
  String get obFeatStatusMediaTitle => 'Photo, vidéo ou texte';

  @override
  String get obFeatStatusMediaText =>
      'Publiez ce que vous voulez montrer. Les personnes à portée le reçoivent, sans passer par internet.';

  @override
  String get obFeatStatusSeenTitle => 'Vous voyez qui l\'a regardé';

  @override
  String get obFeatStatusSeenText =>
      'Chaque personne qui ouvre votre statut vous le fait savoir en retour, par le même chemin.';

  @override
  String get obFeatStatusExpireTitle => 'Ça disparaît après un jour';

  @override
  String get obFeatStatusExpireText =>
      'Vingt-quatre heures, puis le statut s\'efface de tous les téléphones qui l\'avaient reçu.';

  @override
  String get obRemovePhoto => 'Retirer la photo';

  @override
  String get obChoosePhoto => 'Choisir une photo';

  @override
  String get obPhotoTitle => 'Un visage,\nsi vous voulez';

  @override
  String get obPhotoSubtitle =>
      'Elle aide les autres à vous reconnaître dans une liste. Rien ne vous oblige à en mettre une.';

  @override
  String get obFeatPhotoLocalTitle => 'Elle reste sur ce téléphone';

  @override
  String get obFeatPhotoLocalText =>
      'Aucun serveur ne la reçoit, aucune sauvegarde en ligne ne la conserve. Elle vit dans le dossier de l\'application, et nulle part ailleurs.';

  @override
  String get obFeatPhotoCompressTitle => 'Réduite avant d\'être rangée';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet n\'en garde qu\'une vignette de 320 pixels. Votre photo d\'origine n\'est jamais copiée.';

  @override
  String get obNetworkTitle => 'Droplet grandit\navec vous';

  @override
  String get obNetworkSubtitle =>
      'Chaque personne qui l\'installe agrandit le réseau — pour elle, et pour tous ceux qui sont autour.';

  @override
  String get obSendToFriend => 'Envoyer Droplet à un proche';

  @override
  String get obFeatShareOfflineTitle => 'Même le partage se passe d\'internet';

  @override
  String get obFeatShareOfflineText =>
      'Droplet vous envoie son propre fichier d\'installation. Il part par Bluetooth, par Wi-Fi Direct ou sur une carte mémoire — aucune connexion nécessaire, des deux côtés.';

  @override
  String get obFeatThreeTitle => 'Trois personnes suffisent pour commencer';

  @override
  String get obFeatThreeText =>
      'À deux, vous vous écrivez à portée de vue. À quelques-uns dans un quartier, les messages se relaient et la portée devient bien plus grande que chaque téléphone.';

  @override
  String get obIdentityTitle => 'Comment doit-on\nvous appeler ?';

  @override
  String get obIdentitySubtitle =>
      'Ce nom apparaîtra auprès des personnes qui vous croisent. Vous pouvez en choisir un qui ne vous identifie pas.';

  @override
  String get obPseudoHint => 'Votre pseudo';

  @override
  String get obFeatKeysTitle => 'Vos clés sont créées ici, maintenant';

  @override
  String get obFeatKeysText =>
      'Elles ne quittent jamais ce téléphone. Pensez à faire une sauvegarde depuis les réglages : sans elle, une identité perdue l\'est définitivement.';

  @override
  String get splashCaption => 'Hors ligne. Sans opérateur.';

  @override
  String get chatsMeshNetwork => 'Réseau mesh';

  @override
  String get chatsNew => 'Nouveau';

  @override
  String get chatsNewGroup => 'Nouveau groupe';

  @override
  String get chatsAssistant => 'Assistant';

  @override
  String get chatsEmergencyMode => 'Mode urgence';

  @override
  String get chatsUnpin => 'Désépingler';

  @override
  String get chatsPin => 'Épingler en haut';

  @override
  String get chatsUnmute => 'Activer les notifications';

  @override
  String get chatsMute => 'Couper le son';

  @override
  String get chatsArchive => 'Archiver';

  @override
  String get swipePin => 'Épingler';

  @override
  String get swipeUnpin => 'Détacher';

  @override
  String get swipeMute => 'Silence';

  @override
  String get swipeUnmute => 'Son';

  @override
  String get swipeArchive => 'Archiver';

  @override
  String get fmtBold => 'Gras';

  @override
  String get fmtItalic => 'Italique';

  @override
  String get fmtStrike => 'Barré';

  @override
  String get fmtMono => 'Code';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'Transcription…';

  @override
  String get vnTranscribeFailed => 'Transcription impossible sur cet appareil';

  @override
  String get vnNoSpeech => 'Aucune parole reconnue';

  @override
  String get msgTranslate => 'Traduire';

  @override
  String get msgShowOriginal => 'Voir l\'original';

  @override
  String get msgTranslatedFrom => 'Traduit automatiquement';

  @override
  String get msgTranslateFailed => 'Traduction indisponible';

  @override
  String get msgTranslateModel =>
      'Modèle de langue à télécharger (une seule fois, en Wi-Fi)';

  @override
  String get pfWallpapers => 'Fonds animés';

  @override
  String get pfWallpapersDesc =>
      'Huit fonds multicolores qui vivent derrière vos discussions, et tournent à chaque message envoyé.';

  @override
  String get pfFormatting => 'Mise en forme';

  @override
  String get pfFormattingDesc =>
      'Gras, italique, barré, code et spoilers, directement dans vos messages.';

  @override
  String get pfTranscription => 'Vocaux en texte';

  @override
  String get pfTranscriptionDesc =>
      'Lisez un message vocal quand vous ne pouvez pas l\'écouter. La reconnaissance se fait sur votre téléphone.';

  @override
  String get pfTranslation => 'Traduction';

  @override
  String get pfTranslationDesc =>
      'Traduisez un message reçu sans que son contenu quitte l\'appareil.';

  @override
  String get pfAppIcons => 'Icônes de l\'app';

  @override
  String get pfAppIconsDesc =>
      'Changez l\'icône de Droplet sur votre écran d\'accueil.';

  @override
  String get pfBadge => 'Badge et reconnaissance';

  @override
  String get pfBadgeDesc =>
      'Un badge à côté de votre nom, et le soutien d\'un projet indépendant.';

  @override
  String get pfUnderstood => 'J\'ai compris';

  @override
  String get pfFeaturesTitle => 'Ce que le pack ouvre';

  @override
  String get chatsUnarchive => 'Désarchiver';

  @override
  String get chatsArchivedTitle => 'Archivées';

  @override
  String get chatsNoArchived => 'Aucune conversation archivée';

  @override
  String get chatsLockedTitle => 'Discussions verrouillées';

  @override
  String get chatsNoLocked => 'Aucune conversation verrouillée';

  @override
  String get chatsCrashTitle => 'Droplet s\'est fermé de façon inattendue';

  @override
  String get chatsCrashBody =>
      'Droplet n\'a aucun serveur : sans votre envoi, ce défaut n\'existe pour personne. Le rapport ne contient ni messages, ni contacts, ni clés.';

  @override
  String get chatsSendReport => 'Envoyer le rapport';

  @override
  String get chatsLater => 'Plus tard';

  @override
  String get stTitle => 'Réglages';

  @override
  String get stIconHeader => 'Icône';

  @override
  String get stIconFooter => 'Treize icônes au choix pour l\'écran d\'accueil.';

  @override
  String get stAppIcon => 'Icône de l\'application';

  @override
  String get stVariants13 => '13 variantes';

  @override
  String get stNetworkHeader => 'Réseau';

  @override
  String get stNetworkFooter =>
      'Le relais en arrière-plan permet de transmettre les messages des autres même quand Droplet est fermé.';

  @override
  String get stRequireTor => 'Exiger Tor en ligne';

  @override
  String get stRequireTorSubtitle => 'Sans Tor, rien ne sort vers les serveurs';

  @override
  String get stRequireTorFooter =>
      'L\'annuaire et la boîte aux lettres passent par Tor dès qu\'il est actif. Sinon, Droplet s\'y connecte directement : le contenu reste chiffré de bout en bout, mais les serveurs voient votre adresse IP. Activez cette option pour l\'interdire — au prix de la messagerie en ligne quand Tor ne marche pas.';

  @override
  String get stMeshNetwork => 'Réseau mesh';

  @override
  String get stPeersTopology => 'Pairs connectés et topologie';

  @override
  String get stOfflineMaps => 'Cartes hors connexion';

  @override
  String get stZonesImport => 'Zones enregistrées et import de cartes';

  @override
  String get stSecurityHeader => 'Sécurité';

  @override
  String get stSecurityFooter =>
      'Droplet ne conserve aucune copie de votre identité. Sans sauvegarde, elle est perdue avec l\'appareil.';

  @override
  String get stBackupIdentity => 'Sauvegarder mon identité';

  @override
  String get stExportEncrypted => 'Export chiffré par mot de passe';

  @override
  String get stEmergencyMode => 'Mode urgence';

  @override
  String get stSignalSafe => 'Signaler que vous êtes en sécurité';

  @override
  String get stContributionHeader => 'Contribution';

  @override
  String get stMyContribution => 'Ma contribution';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Actif';

  @override
  String get stProPackUnlocked => 'Pack débloqué';

  @override
  String get stProIconsThemes => 'Icônes et fonds';

  @override
  String get stCrashLog => 'Journal des erreurs';

  @override
  String get stAbout => 'À propos de Droplet';

  @override
  String get stBackgroundRelay => 'Relais en arrière-plan';

  @override
  String get stActiveClosed => 'Actif même app fermée';

  @override
  String get stActiveOpenOnly => 'Actif seulement app ouverte';

  @override
  String get stBatteryOptim => 'Optimisation de batterie';

  @override
  String get stAndroidMayLimit => 'Android peut limiter le relais';

  @override
  String get stFix => 'Corriger';

  @override
  String get stKeepActiveTitle => 'Garder Droplet actif ?';

  @override
  String get stKeepActiveBody =>
      'Une notification permanente indiquera que Droplet relaie le mesh, même app fermée. En échange, la batterie sera davantage sollicitée.';

  @override
  String get stEnable => 'Activer';

  @override
  String get stCancel => 'Annuler';

  @override
  String get stAboutTagline =>
      'Messagerie et appels hors ligne, sans Internet ni opérateur.';

  @override
  String get stAboutDirect => 'Réseau direct entre appareils — aucun serveur';

  @override
  String get stAboutE2E => 'Chiffrement de bout en bout sur tous les messages';

  @override
  String get stAboutNoThirdParty => 'Aucune donnée transmise à un tiers';

  @override
  String get stAttributionEmoji =>
      'Emojis animés : Noto Animated Emoji © Google, sous licence CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Assistant : Gemma 3 1B-IT © Google, quantifié (int4) par litert-community et republié par Droplet, sous les conditions d\'utilisation Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Fond de discussion';

  @override
  String get stChatPatterns => 'Motifs Droplet';

  @override
  String get stChatPatternsSubtitle =>
      'Petits dessins au trait par-dessus le fond';

  @override
  String get stChatBgFooter =>
      'Le dégradé avance d\'un cran à chaque message envoyé. Choisissez « Aucun » pour un fond uni : rien n\'est alors calculé, ce qui ménage la batterie.';

  @override
  String get stBgFree => 'Gratuits';

  @override
  String get stBgPremium => 'Premium · animés';

  @override
  String get stBgNone => 'Aucun';

  @override
  String get stBgDefault => 'Par défaut';

  @override
  String get stBgThisChat => 'Fond de cette discussion';

  @override
  String get stTextSize => 'Taille du texte';

  @override
  String get stBubbleCorners => 'Arrondi des bulles';

  @override
  String get stAccentHeader => 'Couleur d\'accent';

  @override
  String get stAccentFooter =>
      'Elle colore vos bulles, les boutons et les liens, dans toute l\'application.';

  @override
  String get stChatListHeader => 'Liste des discussions';

  @override
  String get stChatListTwoLines => 'Deux lignes';

  @override
  String get stChatListThreeLines => 'Trois lignes';

  @override
  String get stResetAppearance => 'Réinitialiser l\'apparence';

  @override
  String get stPreviewIncoming => 'On se voit ce soir ?';

  @override
  String get stPreviewOutgoing => 'Oui, avec plaisir !';

  @override
  String get stAppearanceRow => 'Apparence';

  @override
  String get stAppearanceSubtitle => 'Thème, couleur, taille du texte, fonds';

  @override
  String get stBgApply => 'Utiliser ce fond';

  @override
  String get stBgUnlock => 'Débloquer avec Premium';

  @override
  String get stBgApplied => 'Fond appliqué';

  @override
  String get stBgPreviewHint =>
      'Le fond s\'anime et ses couleurs tournent à chaque message envoyé.';

  @override
  String get stBgPreviewIncoming => 'Tu as vu le nouveau fond ?';

  @override
  String get stBgPreviewOutgoing => 'Oui, il est magnifique ✨';

  @override
  String get stSoundHeader => 'Sons';

  @override
  String get stSoundToggle => 'Sons de l\'app';

  @override
  String get stSoundSubtitle => 'Messages, connexions, alertes';

  @override
  String get stSoundFooter =>
      'Des tonalités courtes, au volume des notifications du système — silencieuses si le téléphone est en mode silencieux ou concentration.';

  @override
  String get stPacksHeader => 'Assistant — fiches hors ligne';

  @override
  String get stPacksToggle => 'Fiches de secours et d\'urgence';

  @override
  String get stPacksSubtitle =>
      'L\'assistant s\'appuie dessus pour les premiers secours et les situations d\'urgence.';

  @override
  String get stPacksFooter =>
      'Des fiches de référence intégrées (premiers secours, séisme, inondation, eau potable…). Quand la question s\'y rapporte, l\'assistant cite la fiche au lieu d\'approximer. Elles ne remplacent ni une formation ni un appel aux secours.';

  @override
  String get stPrivateModeHeader => 'Mode privé';

  @override
  String get stTorFooter =>
      'Tor protège votre adresse IP et vos conversations en les faisant passer par le réseau Tor. Le mesh local (BLE/WiFi) continue de fonctionner normalement.';

  @override
  String get stTorActiveAnon => 'Actif — vos données sont anonymisées';

  @override
  String get stTorConnecting => 'Connexion en cours…';

  @override
  String get stTorDisabled => 'Mode privé désactivé';

  @override
  String get callsTitle => 'Appels';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appels manqués',
      one: '$count appel manqué',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Nouvel appel';

  @override
  String get callsAll => 'Tous';

  @override
  String get callsMissed => 'Manqués';

  @override
  String get callsNoneMissed => 'Aucun appel manqué';

  @override
  String get callsNone => 'Aucun appel';

  @override
  String get callsMissedEmptyBody =>
      'Les appels auxquels vous n\'avez pas répondu apparaîtront ici.';

  @override
  String get callsEmptyBody =>
      'Les appels passent par le réseau local, sans opérateur ni forfait. Votre historique apparaîtra ici.';

  @override
  String get callsRetained200 =>
      'Les 200 derniers appels sont conservés sur cet appareil uniquement.';

  @override
  String get callsIncoming => 'Entrant';

  @override
  String get callsOutgoing => 'Sortant';

  @override
  String get callsMissedLabel => 'Manqué';

  @override
  String get callsNoAnswer => 'Sans réponse';

  @override
  String get callsConnectionFailed => 'Échec de la connexion';

  @override
  String get callsYesterday => 'hier';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Pairs';

  @override
  String get peersSearching => 'Recherche en cours…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils à portée',
      one: '$count appareil à portée',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Carte du réseau';

  @override
  String get peersNoneInRange => 'Personne à portée';

  @override
  String get peersNoneInRangeBody =>
      'Droplet cherche en permanence les appareils proches. Rapprochez-vous de quelqu\'un qui a l\'app pour établir la première liaison.';

  @override
  String get peersDirectRange => 'À portée directe';

  @override
  String get peersDirectRangeFooter =>
      'Ces appareils sont joignables sans passer par personne d\'autre.';

  @override
  String get peersRelayed => 'Par relais';

  @override
  String get peersRelayedFooter =>
      'Ces appareils sont hors de portée directe : les messages leur parviennent en passant par d\'autres téléphones.';

  @override
  String get peersRelay => 'Relais';

  @override
  String get peersCall => 'Appeler';

  @override
  String get peersTooSlow => 'Trop lent pour la voix — rapprochez-vous';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Liaison inconnue';

  @override
  String get peersDirect => 'direct';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relais',
      one: '$count relais',
      zero: 'direct',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Ce statut a expiré';

  @override
  String get svReceiving => 'Réception en cours…';

  @override
  String get svReceivingBody => 'Le fichier arrive par le réseau local';

  @override
  String get svProgressLabel => 'Progression du statut';

  @override
  String get svReplyHint => 'Répondre…';

  @override
  String get svSendReply => 'Envoyer la réponse';

  @override
  String get svYourStatus => 'Votre statut';

  @override
  String get svNoViewsYet =>
      'Personne n\'a encore vu ce statut.\nIl continuera de circuler tant que vous croiserez des appareils.';

  @override
  String get svJustNow => 'à l\'instant';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a $count min',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count h',
      one: 'il y a $count h',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Musique';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vues',
      one: '$count vue',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j\'aime',
      one: '$count j\'aime',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '$count réponse',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Original';

  @override
  String get cpFilterDark => 'Sombre';

  @override
  String get cpFilterBright => 'Lumineux';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Écrivez un statut';

  @override
  String get cpPreparingVideo => 'Préparation de la vidéo…';

  @override
  String get cpLoadingEllipsis => 'Chargement…';

  @override
  String cpEndsIn(Object s) {
    return 'Fin dans $s s';
  }

  @override
  String get cpModeVideo => 'Vidéo';

  @override
  String get cpModePhoto => 'Photo';

  @override
  String get cpModeMessage => 'Message';

  @override
  String get cpModeVoice => 'Vocal';

  @override
  String get gcChooseName => 'Choisis un nom pour le groupe';

  @override
  String get gcSelectOneMember => 'Sélectionne au moins un membre';

  @override
  String get gcCreationFailed => 'Échec de la création du groupe';

  @override
  String get gcNewGroup => 'Nouveau groupe';

  @override
  String get gcGroupName => 'Nom du groupe';

  @override
  String get gcNameHint => 'ex. Équipe terrain';

  @override
  String get gcMembers => 'Membres';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Personne à portée';

  @override
  String get gcGetCloserBody =>
      'Rapproche-toi d\'un autre appareil Droplet : les pairs apparaissent ici automatiquement.';

  @override
  String get gcCreateGroup => 'Créer le groupe';

  @override
  String get gcConnected => 'Connecté';

  @override
  String get gcAlreadyMet => 'Déjà rencontré';

  @override
  String get giRenameGroup => 'Renommer le groupe';

  @override
  String get giRenameFailed => 'Échec du renommage';

  @override
  String get giNoPeerToAdd => 'Aucun pair disponible à ajouter';

  @override
  String get giAddMemberHeader => 'AJOUTER UN MEMBRE';

  @override
  String get giAddMemberFailed => 'Échec de l\'ajout du membre';

  @override
  String get giRemoveMemberTitle => 'Retirer ce membre ?';

  @override
  String get giRemoveMemberBody =>
      'Il ne pourra plus lire les messages envoyés après son retrait.';

  @override
  String get giRemove => 'Retirer';

  @override
  String get giRemoveMemberFailed => 'Échec du retrait du membre';

  @override
  String get giLeaveGroupTitle => 'Quitter le groupe ?';

  @override
  String get giLeaveGroupBody =>
      'Vous ne recevrez plus les messages envoyés après votre départ.';

  @override
  String get giLeave => 'Quitter';

  @override
  String get giNoOneReachable =>
      'Aucun membre joignable en Wi-Fi local pour le moment';

  @override
  String get giMax4Participants =>
      'Maximum 4 participants par appel de groupe — seuls les 3 premiers joignables seront appelés';

  @override
  String get giGroupNotFound => 'Groupe introuvable';

  @override
  String get giGroupInfo => 'Infos du groupe';

  @override
  String get giGroupCall => 'Appel de groupe';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '$count membre',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Messages de groupe chiffrés';

  @override
  String get giAdd => 'Ajouter';

  @override
  String get giMe => 'moi';

  @override
  String get giAdministrator => 'Administrateur';

  @override
  String get giLeaveGroup => 'Quitter le groupe';

  @override
  String get sfNoLocationShared => 'Position non partagée';

  @override
  String get sfLocationShared => 'Position partagée';

  @override
  String sfDistanceMeters(Object m) {
    return 'à $m m';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'à $km km';
  }

  @override
  String get sfBearingN => 'au nord';

  @override
  String get sfBearingNE => 'au nord-est';

  @override
  String get sfBearingE => 'à l\'est';

  @override
  String get sfBearingSE => 'au sud-est';

  @override
  String get sfBearingS => 'au sud';

  @override
  String get sfBearingSW => 'au sud-ouest';

  @override
  String get sfBearingW => 'à l\'ouest';

  @override
  String get sfBearingNW => 'au nord-ouest';

  @override
  String get sfBroadcastSafeTitle => 'Diffuser « Je suis en sécurité » ?';

  @override
  String get sfBroadcastSafeMessage =>
      'Ce statut sera visible par tout le mesh à portée, pas seulement tes contacts. Tu peux inclure une position approximative (arrondie, jamais exacte).';

  @override
  String get sfWithLocation => 'Avec position approx.';

  @override
  String get sfWithoutLocation => 'Sans position';

  @override
  String get sfStatusBroadcast => 'Statut diffusé au mesh';

  @override
  String get sfBroadcastFailed => 'Échec de la diffusion';

  @override
  String get sfHelpRequestTitle => 'Diffuser « J\'ai besoin d\'aide » ?';

  @override
  String get sfHelpRequestMessage =>
      'Ce statut signalera aux pairs à portée que tu as besoin d\'assistance. Tu peux inclure une position approximative.';

  @override
  String get sfHelpRequestBroadcast => 'Demande d\'aide diffusée au mesh';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count j',
      one: 'il y a $count j',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Mode urgence';

  @override
  String get sfViewOnMap => 'Voir sur la carte';

  @override
  String get sfNeedHelp => 'J\'ai besoin d\'aide';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-in reçus ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Aucun check-in reçu pour le moment';

  @override
  String get sfCheckinsAppearHere =>
      'Les statuts « en sécurité » diffusés par les pairs à portée apparaîtront ici.';

  @override
  String get sfSafeLabel => 'En sécurité';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'En sécurité · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'En sécurité · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Diffuser mon statut de sécurité au réseau mesh';

  @override
  String get sfImSafe => 'Je suis en sécurité';

  @override
  String get emSosActive => 'SOS ACTIF';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'Signal SOS actif — diffusé à tous les appareils à proximité';

  @override
  String get emPullToSendSignal => 'Touchez pour envoyer un signal d\'urgence';

  @override
  String get emSignalRelayedDescription =>
      'Le signal est relayé de pair en pair\nsur tout le réseau mesh.';

  @override
  String get emBroadcasting => 'Diffusion...';

  @override
  String get emSharePosition => 'Partager ma position';

  @override
  String get emSosActivated => 'Signal SOS activé';

  @override
  String get emSafeStatusMessage => '🟢 Je suis en sécurité';

  @override
  String get emSafetyStatusBroadcast => 'Statut de sécurité diffusé';

  @override
  String get pmEnterPayingNumber =>
      'Entrez le numéro qui va payer (9 chiffres).';

  @override
  String get pmRequestSent => 'Demande envoyée…';

  @override
  String get pmPaymentLaunchFailed =>
      'Le paiement n\'a pas pu être lancé. Vérifiez le numéro et votre connexion, ou payez à la main plus bas.';

  @override
  String get pmValidateOnPhone =>
      'Validez sur votre téléphone : composez votre code Mobile Money quand l\'invite s\'affiche.';

  @override
  String get pmPaymentNotConfirmed =>
      'Paiement non confirmé. Rien n\'a été débloqué.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'Le paiement est passé mais la licence reçue est invalide. Écrivez-nous, elle sera refaite : $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro activé';

  @override
  String get pmPackUnlocked => 'Pack débloqué';

  @override
  String get pmInvalidCode =>
      'Ce code n\'est pas valable sur cet appareil. Vérifiez que vous avez bien envoyé le code d\'appareil affiché ci-dessus.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'Ce que Droplet\nne demandera jamais';

  @override
  String get pmNeverAskBody =>
      'Ni publicité, ni abonnement obligatoire, ni revente de vos données — il n\'y a même pas de serveur pour les recueillir. Le pack et Pro financent le reste.';

  @override
  String get pmCommunitySemantics =>
      'Rejoignez la communauté de plus de 1200 membres actifs';

  @override
  String get pmCommunityText => 'Rejoignez 1 200+ membres sur le mesh';

  @override
  String get pmProPreviewSemantics =>
      'Aperçu des fonctionnalités Pro débloquées';

  @override
  String get pmAnimatedEmojis => 'Emojis\nanimés';

  @override
  String get pmWallpapers => 'Fonds\nd\'écran';

  @override
  String get pmAppIcons => 'Icônes\nd\'app';

  @override
  String get pmOnceForLife => 'une fois, à vie';

  @override
  String get pmProAdvantage1 => 'Les dix icônes et les huit fonds du pack';

  @override
  String get pmProAdvantage2 => 'Le badge Pro à côté de votre nom';

  @override
  String get pmProAdvantage3 => 'Les fonctions à venir, sans supplément';

  @override
  String get pmPackTitle => 'Le pack';

  @override
  String get pmOnce => 'une fois';

  @override
  String get pmPackAdvantage1 => 'Dix icônes d\'application supplémentaires';

  @override
  String get pmPackAdvantage2 => 'Huit fonds de discussion';

  @override
  String get pmPayByHand => 'Ou payer à la main';

  @override
  String get pmHowTo => 'Comment faire';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Si l\'invite n\'arrive pas sur votre téléphone, ou si vous préférez envoyer l\'argent vous-même.';

  @override
  String pmStep1Title(Object montant) {
    return 'Envoyez $montant F';
  }

  @override
  String get pmStep1Body =>
      'Choisissez votre opérateur : son menu s\'ouvre, et le numéro reste affiché ici pendant que vous le parcourez.';

  @override
  String get pmStep2Title => 'Envoyez votre code d\'appareil';

  @override
  String get pmStep2Body =>
      'Avec la capture du paiement. Sans ce code, la licence ne peut pas être fabriquée — elle ne vaut que pour votre téléphone.';

  @override
  String get pmStep3Title => 'Vous recevez une licence';

  @override
  String get pmStep3Body =>
      'Une longue ligne commençant par DROP1. Collez-la ci-dessous : le déblocage est immédiat et fonctionne hors connexion, pour toujours.';

  @override
  String get pmPayNow => 'Payer maintenant';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money ou Orange Money, depuis ce téléphone ou un autre.';

  @override
  String get pmPhoneNumberSemantics =>
      'Numéro de téléphone pour le paiement Mobile Money';

  @override
  String get pmWaitingForCode => 'En attente de votre code…';

  @override
  String pmPayAmount(Object montant) {
    return 'Payer $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Restaurer un achat précédent';

  @override
  String get pmAlreadyPaidRestore => 'Déjà payé ? Restaurer';

  @override
  String pmDialCode(Object code) {
    return 'Composez $code depuis votre téléphone';
  }

  @override
  String get pmChooseOperatorSemantics => 'Choisir un opérateur de paiement';

  @override
  String get pmNumberAmountFilled =>
      'Numéro et montant déjà remplis — il ne reste que votre code secret.';

  @override
  String get pmOrangeMenuInstructions =>
      'Dans le menu Orange : transfert d\'argent, puis le numéro et le montant ci-dessous.';

  @override
  String get pmLabelNumber => 'Numéro';

  @override
  String get pmLabelAmount => 'Montant';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Payer $montant francs avec $operator';
  }

  @override
  String get pmMenuOpen => 'Menu ouvert';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Bonjour, je viens de payer pour Droplet.\n\nOffre : $offer\nMontant : $amount F\nCode appareil : $code\n\n(je joins la capture du paiement)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp introuvable — code copié. Envoyez-le au $contact';
  }

  @override
  String get pmPrepareRequest => 'Préparer ma demande';

  @override
  String get pmReceivedLicense => 'J\'ai reçu ma licence';

  @override
  String get pmPaste => 'Coller';

  @override
  String get pmUnlock => 'Débloquer';

  @override
  String get pmProIsActive => 'Droplet Pro est actif';

  @override
  String get pmPackIsUnlocked => 'Le pack est débloqué';

  @override
  String get pmProActiveDescription =>
      'Le badge Pro accompagne votre nom, et toutes les icônes et tous les fonds vous sont ouverts.';

  @override
  String get pmPackActiveDescription =>
      'Les dix icônes et les huit fonds du pack vous sont ouverts, dans les réglages.';

  @override
  String get pmLicenseDeviceBound =>
      'Votre licence vaut pour ce téléphone. Si vous en changez, gardez le message qui la contient : elle sera refaite gratuitement.';

  @override
  String torError(Object e) {
    return 'Erreur : $e';
  }

  @override
  String get torEnable => 'Activer Tor';

  @override
  String get torProtected => 'Protégé';

  @override
  String get torDisabled => 'Désactivé';

  @override
  String get torStateHeader => 'État';

  @override
  String get torCircuit => 'Circuit';

  @override
  String get torActive => 'Actif';

  @override
  String get torInProgress => 'En cours…';

  @override
  String get torInactive => 'Inactif';

  @override
  String get torFailed => 'Échec';

  @override
  String get torReason => 'Raison';

  @override
  String get torBannerConnecting => 'Connexion Tor…';

  @override
  String get torBannerActive => 'Tor actif';

  @override
  String get torBannerError => 'Tor indisponible';

  @override
  String get torBannerOff => 'Tor éteint';

  @override
  String get torEncryption => 'Chiffrement';

  @override
  String get torLatency => 'Latence';

  @override
  String get torContactsHeader => 'Contacts';

  @override
  String get torScanQrFooter =>
      'Scannez un QR code, ou recherchez un pseudo dans l\'annuaire, pour ajouter un contact distant.';

  @override
  String get torScanQrCode => 'Scanner un QR Code';

  @override
  String get torMyQrCode => 'Mon QR Code';

  @override
  String get torInformationHeader => 'Informations';

  @override
  String get torVersion => 'Version';

  @override
  String get torHowItWorks => 'Comment ça marche ?';

  @override
  String get torConnecting => 'Connexion…';

  @override
  String get torInactiveTitle => 'Tor inactif';

  @override
  String get torDataThroughTor => 'Vos données passent par le réseau Tor';

  @override
  String get torEstablishingCircuit => 'Établissement du circuit (10-30s)';

  @override
  String get torActivateToProtect => 'Activez pour protéger votre identité';

  @override
  String get torHowItWorksTitle => 'Comment Tor protège vos données';

  @override
  String get torEncryptedCircuit => 'Circuit chiffré';

  @override
  String get torEncryptedCircuitDesc =>
      'Vos messages passent par 3 relais Tor dans le monde.';

  @override
  String get torHiddenIp => 'IP masquée';

  @override
  String get torHiddenIpDesc => 'Aucun site ne peut voir votre vraie adresse.';

  @override
  String get torMeshPreserved => 'Mesh préservé';

  @override
  String get torMeshPreservedDesc =>
      'Bluetooth et Wi-Fi local continuent de fonctionner.';

  @override
  String get torUnderstood => 'Compris';

  @override
  String get qrTorNotActive =>
      'Tor n\'est pas actif. Activez-le dans Réglages > Tor.';

  @override
  String get qrScanContactCode => 'Scannez le QR code d\'un contact';

  @override
  String get qrCodeFromContactScreen =>
      'Le code doit provenir de l\'écran Tor de votre contact';

  @override
  String get qrScanAnother => 'Scanner un autre';

  @override
  String get qrChat => 'Discuter';

  @override
  String get qgScanToConnect => 'Scannez pour se connecter';

  @override
  String get qgCopied => 'Copié ✓';

  @override
  String get qgCopyCode => 'Copier le code';

  @override
  String get qgHowItWorks => 'Comment ça marche';

  @override
  String get qgStep1 => 'Montrez ce QR code à votre contact';

  @override
  String get qgStep2 => 'Il le scanne depuis son écran Tor';

  @override
  String get qgStep3 => 'Vous êtes connectés via Tor';

  @override
  String get shShareTo => 'Partager vers…';

  @override
  String get shSearchConversation => 'Rechercher une conversation';

  @override
  String get shNoConversation => 'Aucune conversation';

  @override
  String get shOpenChatFirst =>
      'Ouvrez d\'abord une discussion dans Droplet pour pouvoir y partager du contenu.';

  @override
  String get shGroup => 'Groupe';

  @override
  String get shDiscussion => 'Discussion';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments à partager',
      one: '$count élément à partager',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Carte installée';

  @override
  String get omClearCacheTitle => 'Vider le cache ?';

  @override
  String get omRemoveZoneTitle => 'Supprimer cette zone ?';

  @override
  String get omClearCacheMessage =>
      'Les zones que vous avez parcourues ne seront plus disponibles hors connexion. Elles se reconstitueront en les consultant à nouveau avec du réseau.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '« $name » sera supprimée de cet appareil.';
  }

  @override
  String get omClear => 'Vider';

  @override
  String get omTitle => 'Cartes';

  @override
  String get omReading => 'Lecture…';

  @override
  String get omNoMapsSaved => 'Aucune carte enregistrée';

  @override
  String omSizeOnDevice(Object size) {
    return '$size sur cet appareil';
  }

  @override
  String get omBrowseMapHint =>
      'Parcourez la carte avec du réseau : les zones que vous regardez restent disponibles hors connexion.';

  @override
  String get omOnThisDevice => 'Sur cet appareil';

  @override
  String get omZonesFillThemselves =>
      'Les zones consultées se remplissent toutes seules pendant que vous parcourez la carte avec du réseau.';

  @override
  String get omMbtilesExplainer =>
      'Un fichier .mbtiles contient une région entière, préparée à l\'avance. C\'est le format standard des cartes hors connexion : n\'importe quel outil cartographique sait en produire.';

  @override
  String get omImportMap => 'Importer une carte';

  @override
  String get omReadingFile => 'Lecture du fichier…';

  @override
  String get omMbtilesFromPhone => 'Fichier .mbtiles depuis ce téléphone';

  @override
  String get omAttributionText =>
      'Les données viennent d\'OpenStreetMap (licence ODbL), le fond de carte est servi par CARTO. Droplet ne télécharge jamais de région entière à l\'avance : aucun service gratuit ne l\'autorise. Seul ce que vous consultez est conservé.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuiles',
      one: '$count tuile',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '$k k tuiles';
  }

  @override
  String omSizeKb(Object n) {
    return '$n ko';
  }

  @override
  String omSizeMb(Object n) {
    return '$n Mo';
  }

  @override
  String omSizeGb(Object n) {
    return '$n Go';
  }

  @override
  String get nwTitle => 'Actus';

  @override
  String get nwStatusesNetwork24h => 'Statuts du réseau · 24 h';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count statuts du réseau',
      one: '$count statut du réseau',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Publier un statut';

  @override
  String get nwNoNewsYet => 'Aucune actu pour le moment';

  @override
  String get nwStatusesAppearHere =>
      'Les statuts publiés par les personnes à portée apparaîtront ici, sans passer par internet.';

  @override
  String get nwRecent => 'Récents';

  @override
  String get nwStatusExpires =>
      'Un statut disparaît de lui-même 24 heures après sa publication.';

  @override
  String get nwPhoto => '📷 Photo';

  @override
  String get nwVideo => '🎥 Vidéo';

  @override
  String get nwVoiceMessage => '🎤 Message vocal';

  @override
  String get nwMusic => '🎵 Musique';

  @override
  String get nwStatusFallback => 'Statut';

  @override
  String get nwMyStatus => 'Mon statut';

  @override
  String get nwTapToPublish => 'Appuyer pour publier sur le réseau';

  @override
  String get nwNotSeenYet => 'Pas encore vu';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu par $count',
      one: 'Vu par $count',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Position indisponible — vérifiez que la localisation est activée.';

  @override
  String mpDistanceMeters(Object m) {
    return '$m m';
  }

  @override
  String mpDistanceKm(Object km) {
    return '$km km';
  }

  @override
  String mpDistanceFromYou(Object distance) {
    return '$distance de vous';
  }

  @override
  String get mpTitle => 'Localisation';

  @override
  String get mpOffline => 'Hors connexion';

  @override
  String get mpOnlineMap => 'Carte en ligne';

  @override
  String get mpMyPosition => 'Ma position';

  @override
  String get mpLayers => 'Calques';

  @override
  String get mpOfflineToast =>
      'Carte hors connexion : seules les zones déjà enregistrées s\'afficheront.';

  @override
  String get mpOnlineToast =>
      'Carte en ligne : les zones consultées seront enregistrées pour plus tard.';

  @override
  String get mpMapLabel => 'Carte';

  @override
  String get mpSatelliteLabel => 'Satellite';

  @override
  String get mpSatelliteMode => 'Mode satellite';

  @override
  String get mpMapMode => 'Mode carte';

  @override
  String get mpWrite => 'Écrire';

  @override
  String get mpCenter => 'Centrer';

  @override
  String get mpNoOneOnMap => 'Personne sur la carte';

  @override
  String get mpPositionsAppearHere =>
      'Les positions apparaissent ici quand un contact les partage depuis le mode Sécurité.';

  @override
  String get mpYou => 'Vous';

  @override
  String get mnTitle => 'Réseau mesh';

  @override
  String get mnPeers => 'Pairs';

  @override
  String get mnAvgHops => 'Moy. sauts';

  @override
  String get mnSignal => 'Signal';

  @override
  String get mnStrong => 'Fort';

  @override
  String get mnMedium => 'Moyen';

  @override
  String get mnSearchingPeers => 'Recherche de pairs à portée…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pairs connectés',
      one: '$count pair connecté',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Aucun pair connecté pour le moment';

  @override
  String get mnGetCloserHint =>
      'Rapproche-toi d\'un autre appareil avec Droplet installé — la découverte se fait automatiquement, sans configuration.';

  @override
  String get mnConnectedPeersHeader => 'Pairs connectés';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sauts',
      one: '$count saut',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Wi-Fi Local';

  @override
  String get mnP2pNative => 'P2P Natif';

  @override
  String get mnActiveGateway => 'Passerelle active';

  @override
  String get mnPath => 'Chemin';

  @override
  String get mnTransport => 'Transport';

  @override
  String get mnBattery => 'Batterie';

  @override
  String get mnScore => 'Score';

  @override
  String get mnReconnecting => 'Reconnexion';

  @override
  String get cnBronze => 'Bronze';

  @override
  String get cnSilver => 'Argent';

  @override
  String get cnGold => 'Or';

  @override
  String get cnDiamond => 'Diamant';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '$count point',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points avant le palier $tier';
  }

  @override
  String get cnRelayedMessages => 'Messages relayés pour d\'autres';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n pts';
  }

  @override
  String get cnGatewayMinutes => 'Minutes en mode relais (gateway)';

  @override
  String get cnExplanation =>
      'Chaque message que ton appareil relaie pour d\'autres, et chaque minute où il reste disponible comme relais, aide le réseau mesh à couvrir plus de monde, plus loin. Ce badge n\'a aucun effet sur l\'app — c\'est juste une reconnaissance de ta contribution.';

  @override
  String get nmTitle => 'Nouveau message';

  @override
  String get nmNewGroup => 'Nouveau groupe';

  @override
  String get nmScanCode => 'Scanner un code';

  @override
  String get nmVerifyContactIdentity => 'Vérifier l\'identité d\'un contact';

  @override
  String get nmNoOneInRange => 'Personne à portée';

  @override
  String get nmNoResult => 'Aucun résultat';

  @override
  String get nmPeopleWillAppearHere =>
      'Les personnes que votre appareil détecte apparaîtront ici.';

  @override
  String get nmInRange => 'À portée';

  @override
  String get nmDirectConnection => 'Connexion directe';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Via $count relais',
      one: 'Via $count relais',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'Fichier trop volumineux (max 50 Mo)';

  @override
  String get chCannotReadMedia => 'Impossible de lire ce média';

  @override
  String get chLocationDenied =>
      'Localisation refusée — activez-la dans les réglages du téléphone pour partager votre position.';

  @override
  String get chGettingPosition => 'Relevé de la position…';

  @override
  String get chPositionUnavailable =>
      'Position indisponible — réessayez à ciel ouvert.';

  @override
  String get chMicPermissionDenied => 'Permission micro refusée';

  @override
  String get chCannotStartRecording =>
      'Impossible de démarrer l\'enregistrement';

  @override
  String get chVoiceSendFailed => 'Envoi du message vocal impossible';

  @override
  String get chFileSendFailed => 'Envoi du fichier impossible';

  @override
  String get chAudioNotFullyReceived => 'Audio pas encore reçu entièrement';

  @override
  String get chVoiceUnreadable =>
      'Ce message vocal est illisible — il est peut-être arrivé incomplet.';

  @override
  String get chFileNotFullyReceived => 'Fichier pas encore reçu en entier';

  @override
  String get chSaveFailed => 'Enregistrement impossible';

  @override
  String chSavedIn(Object folder) {
    return 'Enregistré dans $folder';
  }

  @override
  String get chMessageCopied => 'Message copié';

  @override
  String get chCallImpossibleRelay =>
      'Appel vocal impossible : ce pair est joignable par relais ou en Bluetooth, trop lent pour la voix. Rapprochez-vous pour passer en Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'URL copiée : $url';
  }

  @override
  String get chEditMessageTitle => 'Modifier le message';

  @override
  String get chMessageHint => 'Message';

  @override
  String get chNeverMet => 'Jamais rencontré';

  @override
  String get chSeenJustNow => 'Vu à l\'instant';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu il y a $count min',
      one: 'Vu il y a $count min',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu il y a $count h',
      one: 'Vu il y a $count h',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Vu hier';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu il y a $count jours',
      one: 'Vu il y a $count jour',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Hors de portée';

  @override
  String get chCloseSearchTooltip => 'Fermer la recherche';

  @override
  String get chNetworkDetailsSemantics => 'Réseau Droplet, voir les détails';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '$count membre',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'en train d\'écrire…';

  @override
  String get chBroadcastChannel => 'Canal diffusion';

  @override
  String get chNearby => 'À proximité';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Joignable via $count relais',
      one: 'Joignable via $count relais',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Reconnexion…';

  @override
  String get chSearchInConversation => 'Rechercher dans la conversation';

  @override
  String get chVoiceCall => 'Appel vocal';

  @override
  String get chVideoCall => 'Appel vidéo';

  @override
  String get chCallImpossibleBtRelay =>
      'Appel impossible : liaison Bluetooth ou relayée';

  @override
  String get chGroupInfoTooltip => 'Infos du groupe';

  @override
  String get chNoneFound => 'Aucun';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Résultat plus ancien';

  @override
  String get chNewerResult => 'Résultat plus récent';

  @override
  String get chLoadingOlderMessages => 'Charger les messages précédents…';

  @override
  String get chToday => 'Aujourd\'hui';

  @override
  String get chYesterday => 'Hier';

  @override
  String get chMonday => 'Lundi';

  @override
  String get chTuesday => 'Mardi';

  @override
  String get chWednesday => 'Mercredi';

  @override
  String get chThursday => 'Jeudi';

  @override
  String get chFriday => 'Vendredi';

  @override
  String get chSaturday => 'Samedi';

  @override
  String get chSunday => 'Dimanche';

  @override
  String get chSayHello => 'Dites bonjour 👋';

  @override
  String get chBroadcastEmptyBody =>
      'Les messages sans destinataire apparaissent ici.';

  @override
  String get chP2pRelayedBody =>
      'Vos échanges sont relayés pair à pair, sans Internet.';

  @override
  String get chReply => 'Répondre';

  @override
  String get chReplyInThread => 'Répondre dans le fil';

  @override
  String get chCopy => 'Copier';

  @override
  String get chAccessibilityMe => 'Moi';

  @override
  String get chPhotoLabel => 'Photo';

  @override
  String get chVideoLabel => 'Vidéo';

  @override
  String get chVoiceMessageLabel => 'Message vocal';

  @override
  String chFileLabel(Object name) {
    return 'Fichier $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'envoi en cours';

  @override
  String get chPendingStatus => 'en attente';

  @override
  String get chFailedStatus => 'échec de l\'envoi';

  @override
  String get chReadStatus => 'lu';

  @override
  String get chDeliveredStatus => 'remis';

  @override
  String get chSentStatus => 'envoyé';

  @override
  String get chForwarded => 'Transféré';

  @override
  String get chRetrySendLabel => 'Réessayer l\'envoi';

  @override
  String get chTransmissionDetailsLabel => 'Détails de la transmission';

  @override
  String get chEditedBadge => 'modifié';

  @override
  String get chFileWord => 'Fichier';

  @override
  String chSizeBytes(Object n) {
    return '$n o';
  }

  @override
  String chSizeKb(Object n) {
    return '$n Ko';
  }

  @override
  String chSizeMb(Object n) {
    return '$n Mo';
  }

  @override
  String get chVideoReceiving => 'Vidéo en cours de réception';

  @override
  String get chPreparingVideo => 'Préparation de la vidéo…';

  @override
  String get nmContacts => 'Contacts';

  @override
  String get nmFindByPseudo => 'Rechercher par pseudo';

  @override
  String get nmViaInternet => 'Par Internet';

  @override
  String get nmOutOfRange => 'Hors de portée';

  @override
  String get chatsInvitePerson => 'Inviter une personne';

  @override
  String get ivTitle => 'Invitez vos proches';

  @override
  String get ivSubtitle =>
      'Droplet est plus utile quand ceux qui comptent y sont — même sans réseau.';

  @override
  String get ivByNumber => 'Par numéro de téléphone';

  @override
  String get ivNumberHint => 'Numéro avec l’indicatif (+237…)';

  @override
  String get ivContacts => 'Contacts';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'Par lien';

  @override
  String get ivCopy => 'Copier';

  @override
  String get ivShare => 'Partager';

  @override
  String get ivCopied => 'Lien copié';

  @override
  String get ivByQr => 'Par QR code';

  @override
  String get ivQrHint => 'À faire scanner par la personne, face à face.';

  @override
  String get ivScan => 'Scanner un code';

  @override
  String get ivPrivacy =>
      'Le lien et le code ne contiennent que votre identifiant public et votre clé. Aucun numéro n’est envoyé à Droplet.';

  @override
  String get evTitle => 'Modifier la vidéo';

  @override
  String evSplit(int n) {
    return 'Diviser en $n statuts';
  }

  @override
  String evSplitHint(int s) {
    return 'Chaque partie dure au plus $s s';
  }

  @override
  String evPublished(int n) {
    return '$n statuts publiés';
  }

  @override
  String get svReply => 'Répondre';

  @override
  String get svStatusLabel => 'Statut';

  @override
  String svSeenBy(int n) {
    return 'Vu par $n';
  }

  @override
  String get clMissedVoice => 'Appel vocal manqué';

  @override
  String get clMissedVideo => 'Appel vidéo manqué';

  @override
  String get clCallBack => 'Rappeler';

  @override
  String get stoTitle => 'Stockage';

  @override
  String get stoSubtitle => 'Photos, vidéos et fichiers';

  @override
  String stoUsed(String taille) {
    return '$taille utilisés';
  }

  @override
  String get stoPhotos => 'Photos';

  @override
  String get stoVideos => 'Vidéos';

  @override
  String get stoAudio => 'Vocaux et audio';

  @override
  String get stoDocuments => 'Documents';

  @override
  String get stoOther => 'Autres (statuts…)';

  @override
  String get stoByChat => 'Par discussion';

  @override
  String get stoEmpty => 'Aucun fichier sur ce téléphone';

  @override
  String stoDelete(int n) {
    return 'Supprimer ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Ces fichiers et leurs messages seront supprimés de ce téléphone.';

  @override
  String get tabSelectChat => 'Choisissez une discussion';

  @override
  String get clConnecting => 'Connexion…';

  @override
  String chUnreadMessages(int n) {
    return '$n message(s) non lu(s)';
  }

  @override
  String get csMessagesSection => 'Messages';

  @override
  String chGroupTyping(String noms) {
    return '$noms écrit…';
  }

  @override
  String get tsReadBy => 'Lu par';

  @override
  String get tsDeliveredTo => 'Distribué à';

  @override
  String get tsWaitingFor => 'En attente';

  @override
  String get chSelect => 'Sélectionner';

  @override
  String get chForward => 'Transférer';

  @override
  String get chForwardTo => 'Transférer à…';

  @override
  String chSelectedCount(int n) {
    return '$n sélectionné(s)';
  }

  @override
  String get chForwarded1 => 'Message transféré';

  @override
  String get apCaptionHint => 'Ajouter une légende…';

  @override
  String get apValidateCrop => 'Recadrer';

  @override
  String get chMediaReceiving => 'Réception en cours';

  @override
  String get chStickersTooltip => 'Stickers';

  @override
  String get chAttachTooltip => 'Joindre';

  @override
  String get chDeleteRecordingTooltip => 'Supprimer l\'enregistrement';

  @override
  String get chSlideToCancel => 'Glisser pour annuler';

  @override
  String chReplyingTo(Object pseudo) {
    return 'Réponse à $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Fort';

  @override
  String get chEffectGentle => 'Douceur';

  @override
  String get chEffectInvisibleInk => 'Encre invisible';

  @override
  String get chEffectConfetti => 'Confettis';

  @override
  String get chEffectFireworks => 'Feu d\'artifice';

  @override
  String get chEffectHearts => 'Cœurs';

  @override
  String get chEffectSheetTitle => 'Effet de message';

  @override
  String get chEffectSheetSubtitle =>
      'Se joue une fois, chez toi et chez ton correspondant';

  @override
  String get chOnBubble => 'Sur la bulle';

  @override
  String get chFullscreen => 'Plein écran';

  @override
  String get chTapToReveal => 'Toucher pour révéler';

  @override
  String get chThreadTitle => 'Fil de discussion';

  @override
  String get chReplyHint => 'Réponse…';

  @override
  String get chCollapse => 'Replier';

  @override
  String get chSeeMore => 'Voir plus';

  @override
  String get chMessageOptionsSemantics => 'Options du message';

  @override
  String get chLoveReactionSemantics => 'J\'adore';

  @override
  String get chBroadcastMesh => 'Diffusion mesh';

  @override
  String get chGroupFallback => 'Groupe';

  @override
  String get ciSetupBiometrics =>
      'Configurez un empreinte digitale ou Face ID dans les réglages de votre appareil.';

  @override
  String get ciEnableLockReason =>
      'Activer le verrouillage pour cette conversation';

  @override
  String get ciInfoTitle => 'Infos';

  @override
  String get ciViewConversation => 'Voir la conversation';

  @override
  String get ciGatewayOnline => 'Passerelle · en ligne';

  @override
  String get ciOnline => 'En ligne';

  @override
  String get ciOffline => 'Hors ligne';

  @override
  String get ciMessages => 'Messages';

  @override
  String get ciMedia => 'Médias';

  @override
  String get ciStart => 'Début';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Photos ($count)',
      one: 'Photo ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notes vocales ($count)',
      one: 'Note vocale ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fichiers ($count)',
      one: 'Fichier ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'Aucun média partagé pour le moment.';

  @override
  String get ciSecurityCode => 'Code de sécurité';

  @override
  String get ciVerified => 'Vérifié';

  @override
  String get ciKeyChanged => 'La clé a changé';

  @override
  String get ciNotVerified => 'Non vérifié';

  @override
  String get ciConversationLock => 'Verrouillage de conversation';

  @override
  String get ciLockEnabled => 'Activé — empreinte requise pour ouvrir';

  @override
  String get ciDisabled => 'Désactivé';

  @override
  String get ciEphemeralMessages => 'Messages éphémères';

  @override
  String get ci30Seconds => '30 secondes';

  @override
  String get ci5Minutes => '5 minutes';

  @override
  String get ci1Hour => '1 heure';

  @override
  String get ci24Hours => '24 heures';

  @override
  String get ciDurationBeforeDisappear => 'Durée avant disparition';

  @override
  String get ciBlockContactTitle => 'Bloquer ce contact ?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo ne pourra plus vous envoyer de messages. Vous pouvez le débloquer à tout moment.';
  }

  @override
  String get ciBlock => 'Bloquer';

  @override
  String get ciUnblock => 'Débloquer';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo a été bloqué';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo a été débloqué';
  }

  @override
  String get ciReportContactTitle => 'Signaler ce contact ?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Un signalement anonyme sera envoyé à Droplet : un identifiant technique et le motif choisi ci-dessous, rien d\'autre. Aucun message, aucune conversation avec $pseudo n\'est jamais transmis.';
  }

  @override
  String get ciReport => 'Signaler';

  @override
  String get ciReportSent => 'Signalement envoyé. Merci.';

  @override
  String get ciReportFailed =>
      'Le signalement n\'a pas pu être envoyé — réessayez plus tard.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Harcèlement';

  @override
  String get ciReportReasonIllegal => 'Contenu illégal';

  @override
  String get ciReportReasonOther => 'Autre';

  @override
  String mcReactWith(Object emoji) {
    return 'Réagir avec $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh actif';

  @override
  String get nsNoDeviceInRange => 'Aucun appareil à portée';

  @override
  String get nsMessagesCirculate =>
      'Vos messages circulent d\'appareil en appareil, sans passer par Internet.';

  @override
  String get nsGetCloser =>
      'Rapprochez-vous d\'un autre appareil Droplet. Vos messages sont conservés et repartiront tout seuls.';

  @override
  String get nsDevicesInRange => 'Appareils à portée';

  @override
  String get nsReconnectingTitle => 'En reconnexion';

  @override
  String get nsLinkMomentarilyLost =>
      'Liaison momentanément perdue, pas encore abandonnée.';

  @override
  String get nsRelaysAvailable => 'Relais disponibles';

  @override
  String get nsNoRelayAvailable =>
      'Aucun appareil ne peut faire suivre vos messages plus loin pour l\'instant.';

  @override
  String get nsViaBluetooth => 'Par Bluetooth';

  @override
  String get nsViaLocalWifi => 'Par Wi-Fi local';

  @override
  String get nsWifiCarriesMore =>
      'Le Wi-Fi porte les fichiers et la voix ; le Bluetooth ne transporte que le texte.';

  @override
  String get scInvalidQrCode => 'QR code invalide';

  @override
  String get scWrongCode =>
      'Ce n\'est pas le bon code — la clé ne correspond pas';

  @override
  String get scCodeVerified => 'Code vérifié';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Vérifié — la clé de $pseudo correspond à ce code.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'La clé de $pseudo a changé depuis la dernière vérification.';
  }

  @override
  String get scNotVerifiedYet => 'Pas encore vérifié.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Compare ce code avec celui affiché sur l\'appareil de $pseudo, ou scanne directement son QR code pour vérifier automatiquement.';
  }

  @override
  String get scContactKeyUnknown =>
      'Clé du contact pas encore connue — reconnecte-toi à ce pair sur le mesh.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Scanner le code de $pseudo';
  }

  @override
  String get tsNotDelivered => 'Non distribué';

  @override
  String get tsRead => 'Lu';

  @override
  String get tsDelivered => 'Distribué';

  @override
  String get tsSendingInProgress => 'Envoi en cours';

  @override
  String get tsWaitingForRelay => 'En attente d\'un relais';

  @override
  String get tsSent => 'Envoyé';

  @override
  String tsSecondsSingular(Object value) {
    return '$value seconde';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value secondes';
  }

  @override
  String tsMinutes(Object n) {
    return '$n min';
  }

  @override
  String tsHours(Object n) {
    return '$n h';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Transmission';

  @override
  String get tsStatus => 'Statut';

  @override
  String get tsDelayUntilRead => 'Délai jusqu\'à la lecture';

  @override
  String get tsRoute => 'Trajet';

  @override
  String get tsRouteDetail =>
      'Les appareils qui ont fait suivre ce message, dans l\'ordre.';

  @override
  String get tsPath => 'Chemin';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passé par $count appareils',
      one: 'Passé par $count appareil',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Reçu en direct';

  @override
  String get tsIntermediateDevicesDetail =>
      'Des appareils intermédiaires ont fait suivre ce message jusqu\'à vous.';

  @override
  String get tsUnknown => 'Inconnu';

  @override
  String get tsSentRouteNotReturned =>
      'Le trajet d\'un message envoyé n\'est pas renvoyé à son expéditeur.';

  @override
  String get tsNetwork => 'Réseau';

  @override
  String get tsMeshDroplet => 'Mesh Droplet';

  @override
  String get tsNoServerNoOperator => 'Aucun serveur, aucun opérateur.';

  @override
  String get qsScanSecurityCode => 'Scanner le code de sécurité';

  @override
  String get qsCodeDetected => 'Code détecté';

  @override
  String get qsFrameQrCode =>
      'Cadre le QR code affiché sur l\'appareil de ton contact';

  @override
  String get rmRecentVideo => 'Vidéo récente';

  @override
  String get rmRecentPhoto => 'Photo récente';

  @override
  String get rmSeeAllPhotos => 'Voir toutes les photos';

  @override
  String get rmSeeAll => 'Tout voir';

  @override
  String get aicOriginal => 'Originale';

  @override
  String get aicAzure => 'Azur';

  @override
  String get aicNeon => 'Néon';

  @override
  String get aicPaper => 'Papier';

  @override
  String get aicLagoon => 'Lagon';

  @override
  String get aicAmethyst => 'Améthyste';

  @override
  String get aicGold => 'Or';

  @override
  String get aicTide => 'Marée';

  @override
  String get aicDawn => 'Aurore';

  @override
  String get aicGlass => 'Verre';

  @override
  String get aicConstellation => 'Constellation';

  @override
  String get aicPrism => 'Prisme';

  @override
  String get aicEmerald => 'Émeraude';

  @override
  String get aicChangeIconTitle => 'Changer l\'icône ?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'L\'icône « $name » remplacera celle de votre écran d\'accueil. Certains lanceurs mettent quelques secondes à l\'afficher, ou demandent de revenir à l\'accueil.';
  }

  @override
  String get aicApply => 'Appliquer';

  @override
  String aicIconApplied(Object name) {
    return 'Icône « $name » appliquée';
  }

  @override
  String get aicChangeIconImpossible =>
      'Changement d\'icône impossible sur cet appareil';

  @override
  String get aicTitle => 'Icône';

  @override
  String get aicCurrentOnHomeScreen =>
      'Celle qui apparaît sur votre écran d\'accueil';

  @override
  String get aicUnavailablePlatform => 'Indisponible sur cette plateforme';

  @override
  String get aicAndroidExplanation =>
      'Android fige l\'icône d\'une application dans son installation. Droplet contourne cela en déclarant plusieurs points d\'entrée, un par icône, et en n\'en laissant qu\'un actif. Votre lanceur peut mettre quelques secondes à s\'en apercevoir.';

  @override
  String get aicAndroidOnly =>
      'Le changement d\'icône n\'est disponible que sur Android.';

  @override
  String get beWeak => 'Faible';

  @override
  String get beOkay => 'Correct';

  @override
  String get beStrong => 'Solide';

  @override
  String get bePasswordTooShort =>
      'Le mot de passe doit faire au moins 8 caractères';

  @override
  String get bePasswordsDontMatch =>
      'Les deux mots de passe ne correspondent pas';

  @override
  String get beBackupSubject => 'Sauvegarde Droplet';

  @override
  String get beBackupShareText =>
      'Sauvegarde chiffrée de mon identité Droplet — à garder en lieu sûr.';

  @override
  String get beBackupCreated => 'Sauvegarde créée';

  @override
  String get beBackupFailed => 'Échec de la sauvegarde';

  @override
  String get beBackupMyIdentity => 'Sauvegarder mon identité';

  @override
  String get beWarningBody =>
      'Quiconque possède ce fichier et le mot de passe peut se faire passer pour toi. Garde-le en lieu sûr (jamais envoyé à personne d\'autre que toi-même) et choisis un mot de passe que tu es seul à connaître.';

  @override
  String get bePasswordProtects =>
      'Ce mot de passe protège ta sauvegarde. Il n\'est jamais enregistré : sans lui, le fichier est définitivement inutilisable.';

  @override
  String get bePassword => 'Mot de passe';

  @override
  String get beConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get beIncludeMessageHistory => 'Inclure l\'historique des messages';

  @override
  String get beOtherwiseOnlyIdentity =>
      'Sinon, seuls l\'identité, les contacts et les groupes sont sauvegardés';

  @override
  String get beCreateAndShare => 'Créer et partager la sauvegarde';

  @override
  String get jsErrorJournalTitle => 'Journal des erreurs';

  @override
  String get jsNoErrorsRecorded =>
      'Aucune erreur enregistrée. C\'est le cas normal.';

  @override
  String get jsLinesStayOnDevice =>
      'Ces lignes restent sur cet appareil : Droplet n\'a aucun serveur où les envoyer. Si vous testez l\'application, transmettez-les — sans elles, le défaut n\'existe pour personne.';

  @override
  String get jsErase => 'Effacer';

  @override
  String get jsShareSubject => 'Droplet — journal des erreurs';

  @override
  String get jsShareText =>
      'Journal des erreurs Droplet. Ce fichier ne contient ni messages, ni contacts, ni clés.';

  @override
  String get jsShareUnavailable => 'Partage indisponible — journal copié';

  @override
  String get clOutgoingCall => 'Appel en cours…';

  @override
  String get clIncomingCall => 'Appel entrant…';

  @override
  String get clCallImpossible => 'Appel impossible';

  @override
  String get clCallEnded => 'Appel terminé';

  @override
  String clCallWith(Object pseudo) {
    return 'Appel avec $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Chiffré de bout en bout';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Statut de l\'appel : $status';
  }

  @override
  String get clEnableMic => 'Activer le micro';

  @override
  String get clMuteMic => 'Couper le micro';

  @override
  String get clDisableSpeaker => 'Désactiver le haut-parleur';

  @override
  String get clEnableSpeaker => 'Activer le haut-parleur';

  @override
  String get clDisableCamera => 'Désactiver la caméra';

  @override
  String get clEnableCamera => 'Activer la caméra';

  @override
  String get clHangUp => 'Raccrocher';

  @override
  String get clIncomingVideoCall => 'Appel vidéo entrant';

  @override
  String get clSwitchCamera => 'Changer de caméra';

  @override
  String get gcGroupCall => 'Appel de groupe';

  @override
  String get gcConnecting => 'Connexion…';

  @override
  String get gcOnline => 'En ligne';

  @override
  String get gcFailed => 'Échec';

  @override
  String get gcDisconnected => 'Déconnecté';

  @override
  String get gcReturnToCall => 'Revenir à l’appel';

  @override
  String get gcMinimize => 'Réduire';

  @override
  String get gcVoiceOnly => 'Voix uniquement';

  @override
  String gcReactWith(String emoji) {
    return 'Réagir avec $emoji';
  }

  @override
  String get gcSpeakingNow => 'Parle en ce moment';

  @override
  String get gcMicOff => 'Micro coupé';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants · voix uniquement',
      one: '$count participant · voix uniquement',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Messages';

  @override
  String get ntfChannelMessagesDesc => 'Nouveaux messages et statuts mesh';

  @override
  String get ntfChannelCallsName => 'Appels';

  @override
  String get ntfChannelCallsDesc => 'Appels entrants et manqués';

  @override
  String get ntfChannelMeshName => 'Mesh & urgence';

  @override
  String get ntfChannelMeshDesc =>
      'Service mesh actif, statuts et messages d\'urgence';

  @override
  String get ntfReply => 'Répondre';

  @override
  String get ntfYourReply => 'Votre réponse';

  @override
  String get ntfMarkAsRead => 'Marquer comme lu';

  @override
  String get ntfIncomingCall => 'Appel entrant';

  @override
  String get ntfAnswer => 'Répondre';

  @override
  String get ntfDecline => 'Refuser';

  @override
  String get ntfMissedCall => 'Appel manqué';

  @override
  String get ntfSendFailedTitle => 'Échec de l\'envoi';

  @override
  String get ntfSendFailedBody =>
      'Un message n\'a pas pu être envoyé — nouvel essai dès qu\'un pair est à portée.';

  @override
  String get ntfNewStatusTitle => 'Nouveau statut';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo a publié un statut';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo a aimé ton statut';
  }

  @override
  String get ntfTapToView => 'Appuyer pour voir';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo a répondu à ton statut';
  }

  @override
  String get ntfEmergencyTitle => 'Message d\'urgence';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo a diffusé « Je suis en sécurité »';
  }

  @override
  String get mnAccept => 'Accepter';

  @override
  String get mnMeshVoiceCall => 'Appel vocal mesh';

  @override
  String get mnGroupCallIncoming => 'Appel de groupe entrant';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo t\'invite';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Appel de groupe · $count autres participants',
      one: 'Appel de groupe · $count autre participant',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Qui peut voir ce statut ?';

  @override
  String get asAllContacts => 'Tous mes contacts';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts',
      one: '$count contact',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'Sauf...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exclus',
      one: '$count exclu',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Exclure des contacts';

  @override
  String get asOnlyOption => 'Uniquement...';

  @override
  String get asShareWithSpecific => 'Partager avec des contacts spécifiques';

  @override
  String get asNoContactsAvailable => 'Aucun contact disponible';

  @override
  String get asConfirm => 'Confirmer';

  @override
  String get apYourPhoto => 'Votre photo';

  @override
  String get apNoPhotoAccessible => 'Aucune photo accessible sur cet appareil.';

  @override
  String get apBrowseFiles => 'Parcourir les fichiers';

  @override
  String get apRecentPhoto => 'Photo récente';

  @override
  String get bgSkip => 'Passer';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Étape $rang sur $total.';
  }

  @override
  String get csGuideNetworkTitle => 'Personne à proximité ? C\'est normal';

  @override
  String get csGuideNetworkText =>
      'Droplet ne passe par aucun serveur : il parle aux téléphones à portée. Ici vous voyez qui est joignable, et par quelle radio. Zéro pair ne veut pas dire que ça ne marche pas — juste que personne n\'est encore là.';

  @override
  String get csGuideWriteTitle => 'Écrivez même sans personne';

  @override
  String get csGuideWriteText =>
      'Un message écrit maintenant attend sur votre téléphone et repart dès qu\'un appareil passe à portée — dans la rue, dans un taxi. Il n\'est pas perdu, il patiente.';

  @override
  String get csGuideBackupTitle => 'Sauvegardez votre identité';

  @override
  String get csGuideBackupText =>
      'Sans serveur, personne ne peut vous rendre votre compte. Exportez votre identité depuis les réglages : sans cette sauvegarde, un téléphone perdu emporte tout.';

  @override
  String get csShowLockedChatsReason => 'Afficher les discussions verrouillées';

  @override
  String get cvlNoBiometricsConfigured =>
      'Aucune empreinte digitale configurée sur cet appareil';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Déverrouiller la conversation avec $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Authentification échouée';

  @override
  String get cvlAuthError => 'Erreur d\'authentification';

  @override
  String get cvlConversationLocked => 'Conversation verrouillée';

  @override
  String get cvlUnlock => 'Déverrouiller';

  @override
  String get dcAddText => 'Ajouter du texte';

  @override
  String get dcYourTextHint => 'Votre texte...';

  @override
  String get pbDropletProBadge => 'Badge Droplet Pro';

  @override
  String get rpReact => 'Réagir';

  @override
  String get rpSaveToPhone => 'Enregistrer sur le téléphone';

  @override
  String get chViaTor => 'Via Tor';

  @override
  String get chTorInactive => 'Tor inactif';

  @override
  String get chViaInternet => 'Via Internet';

  @override
  String get chReachedViaTorSemantic => 'Contact joint via Tor';

  @override
  String get nsTorConnectedTitle => 'Connecté via Tor';

  @override
  String get nsTorInactiveTitle => 'Tor désactivé';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'Vos messages passent par le réseau Tor et attendent dans une boîte aux lettres chiffrée jusqu\'à ce que $pseudo s\'y connecte.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Activez Tor dans les réglages pour pouvoir écrire à $pseudo — sans lui, vos messages resteront en attente sur cet appareil.';
  }

  @override
  String get nsTorMailboxTitle => 'Boîte aux lettres chiffrée';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Ni vous ni Droplet ne pouvez lire ce qu\'elle contient — seul·e $pseudo a la clé.';
  }

  @override
  String get nsOpenTorSettings => 'Activer Tor';

  @override
  String get qrInvalidCode => 'Ce code QR n\'est pas un code Droplet.';

  @override
  String get qrPeerAdded => 'Pair ajouté';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Vous pouvez maintenant discuter avec $pseudo';
  }

  @override
  String get clViaInternet => 'Via Internet';

  @override
  String get tsPathTorDetail =>
      'Ce message ne passe pas par les appareils autour de vous : il transite par une boîte aux lettres chiffrée sur le réseau Tor, accessible uniquement par vous deux.';

  @override
  String get tsNetworkTorDetail =>
      'Un serveur relais est nécessaire pour joindre ce contact à distance — Droplet ne peut pas s\'en passer ici, contrairement au maillage local.';

  @override
  String get torSearchDirectory => 'Rechercher dans l\'annuaire';

  @override
  String get dvTitle => 'Rechercher';

  @override
  String get dvClose => 'Fermer';

  @override
  String get dvSearchHint => 'Rechercher un pseudo...';

  @override
  String get dvEnableTorToSearch =>
      'Activez Tor dans les paramètres pour rechercher dans l\'annuaire.';

  @override
  String get dvSearching => 'Recherche en cours...';

  @override
  String get dvNoResults => 'Aucun résultat';

  @override
  String get dvNoUserFound => 'Aucun utilisateur trouvé pour cette recherche.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '$count résultat',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Envoyer';

  @override
  String get aiNewConversation => 'Nouvelle conversation';

  @override
  String get aiMessageHint => 'Message';

  @override
  String get aiCopied => 'Copié';

  @override
  String get aiAskQuestion => 'Posez une question';

  @override
  String get aiRunsLocally =>
      'Cet assistant tourne entièrement sur votre appareil — rien n\'est jamais envoyé sur Internet.';

  @override
  String get aiMemorySaved => 'Je m\'en souviendrai.';

  @override
  String get aiMemoryForgotten =>
      'J\'ai oublié ce que vous m\'aviez demandé de retenir.';

  @override
  String get aiMemoryTitle => 'Mémoire de l\'assistant';

  @override
  String get aiMemoryEmpty =>
      'Rien de retenu pour l\'instant. Dites « retiens que… » pour épingler une information.';

  @override
  String get aiMemoryForget => 'Tout oublier';

  @override
  String get aiExpertHint =>
      'Je connais Droplet en détail : le mesh, Tor, les appels, la confidentialité.';

  @override
  String get chAskAssistant => 'Demander à l\'assistant';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Aide-moi à répondre à $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Préparation de l\'assistant… $percentage %';
  }

  @override
  String get aiOneTimeDownload =>
      'Une seule fois — il reste ensuite sur votre appareil, sans aucun autre téléchargement.';

  @override
  String get aiGenericError => 'Désolé, une erreur s\'est produite.';

  @override
  String get aiNotAvailableYet =>
      'L\'assistant n\'est pas encore disponible sur cette version de Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Téléchargement impossible : $error';
  }

  @override
  String get ntfSomeoneCalling => 'Quelqu\'un essaie de vous joindre';

  @override
  String get ntfNewMessageWake =>
      'Nouveau message — ouvrez Droplet pour le lire';

  @override
  String get chNearbyAndInternet => 'À proximité · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relais · Internet',
      one: '$count relais · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'En attente d\'Internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à proximité · Internet',
      one: '$count à proximité · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à proximité · sans Internet',
      one: '$count à proximité · sans Internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Personne à proximité · Internet';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi direct';

  @override
  String get clPathInternetDirect => 'Internet · direct';

  @override
  String get clPathInternetRelay => 'Internet · relais sécurisé';

  @override
  String get clReconnecting => 'Reconnexion…';

  @override
  String get clLabelSpeaker => 'Haut-parleur';

  @override
  String get clLabelCamera => 'Caméra';

  @override
  String get clLabelMic => 'Micro';

  @override
  String get clLabelFlip => 'Retourner';

  @override
  String get clEncryptedShort => 'Chiffré de bout en bout';

  @override
  String clQualitySemantics(int bars) {
    return 'Qualité de l\'appel : $bars sur 3';
  }

  @override
  String get beOnlineTitle => 'Sauvegarde automatique en ligne';

  @override
  String get beOnlineBody =>
      'Chaque jour, une copie chiffrée avec ce mot de passe est gardée sur le serveur Droplet, qui ne peut pas la lire. Sur un nouveau téléphone, il suffit du même pseudo et du même mot de passe. Les photos, vidéos et fichiers reçus n\'en font pas partie.';

  @override
  String get beOnlineSwitch => 'Sauvegarder chaque jour sur le serveur';

  @override
  String beOnlineLast(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get beOnlineNever => 'Pas encore de sauvegarde en ligne';

  @override
  String get beOnlineNow => 'Sauvegarder maintenant';

  @override
  String get beOnlineDone => 'Sauvegarde en ligne effectuée';

  @override
  String get beOnlineFailed => 'Sauvegarde en ligne impossible pour le moment';

  @override
  String get obRestoreFromServer => 'Restaurer depuis le serveur';

  @override
  String get obEnterPseudoFirst =>
      'Saisissez d\'abord le pseudo de votre sauvegarde';

  @override
  String get obNoServerBackup =>
      'Aucune sauvegarde trouvée pour ce pseudo et ce mot de passe';

  @override
  String get obTooManyAttempts => 'Trop d\'essais — réessayez dans une heure';

  @override
  String get chatsInviteLink => 'Inviter par un lien';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo t\'invite sur Droplet, la messagerie chiffrée qui marche même sans réseau : $lien';
  }

  @override
  String get invTitle => 'Invitation';

  @override
  String invBody(String pseudo) {
    return '$pseudo vous invite à discuter sur Droplet.';
  }

  @override
  String get invAdd => 'Ajouter et écrire';

  @override
  String get invInvalid => 'Ce lien d\'invitation est invalide ou incomplet.';

  @override
  String get invSelf => 'C\'est votre propre lien d\'invitation.';
  @override
  String get seAnimationHeader => 'Animation d\'envoi';

  @override
  String get seAnimationFull => 'Complète';

  @override
  String get seAnimationReduced => 'Réduite';

  @override
  String get seAnimationOff => 'Désactivée';

  @override
  String get seAnimationFullDesc => 'Plic emporte le message, se téléporte et vous salue.';

  @override
  String get seAnimationReducedDesc => 'Un simple fondu, sans mouvement ni particules.';

  @override
  String get seAnimationOffDesc => 'Aucune animation après l\'envoi.';

  @override
  String get seAnimationReplay => 'Touchez pour rejouer';

  @override
  String get seAnimationNone => 'Aucune animation';

  @override
  String get seAnimationSampleIn => 'On se voit au port ?';

  @override
  String get seAnimationSampleOut => 'À tout de suite';

  @override
  String get trTitle => 'Traduction';

  @override
  String get trOnDevice => 'Traduction sur l\'appareil…';

  @override
  String get trUnknownLang => 'Langue inconnue';

  @override
  String get trOriginal => 'Original';

  @override
  String get trCopy => 'Copier';

  @override
  String get trInChat => 'Dans la discussion';

  @override
  String get trRetry => 'Réessayer';

  @override
  String get trSame => 'Ce message est déjà dans cette langue.';

  @override
  String get trModel => 'Le modèle de cette langue n\'est pas encore installé sur l\'appareil.';

  @override
  String get trUnavailable => 'Cet appareil n\'a pas de moteur de traduction hors ligne.';

  @override
  String get trFailed => 'La traduction n\'a pas abouti.';

  @override
  String get pfMessage => 'Message';

  @override
  String get pfCall => 'Appel';

  @override
  String get pfSecurity => 'Sécurité';

  @override
  String get aiActCopy => 'Copier';

  @override
  String get aiActRead => 'Lire à voix haute';

  @override
  String get aiActStop => 'Arrêter la lecture';

  @override
  String get aiActLike => 'Bonne réponse';

  @override
  String get aiActDislike => 'Mauvaise réponse';

  @override
  String get aiActShare => 'Partager';

  @override
  String get aiActRegenerate => 'Régénérer';

  @override
  String get aiFeedbackThanks => 'Merci pour votre retour';

  @override
  String get intelOnlineHeader => 'Traduction et transcription';

  @override
  String get intelOnlineTitle => 'En ligne quand je suis connecté';

  @override
  String get intelOnlineSubtitle => 'Gratuit — MyMemory, Apple ou Google';

  @override
  String get intelOnlineFooter => 'Désactivé, rien ne passe par Internet. Activé et connecté : le texte à traduire part vers MyMemory ; sur iPhone, un vocal que l\'appareil ne sait pas transcrire part au service vocal d\'Apple. Pour ces trajets, le contenu n\'est plus chiffré de bout en bout. Sur Android, seul le modèle vocal se télécharge : les vocaux restent sur le téléphone. Les aperçus de liens contactent aussi le site concerné.';

  @override
  String get trOnline => 'Traduire en ligne';

  @override
  String get trOnlineNote => 'Le texte partira vers MyMemory, un service gratuit. Pour ce trajet, il n\'est plus chiffré de bout en bout.';

  @override
  String get trViaOnline => 'Traduit en ligne par MyMemory';

  @override
  String get vnModelDownloading => 'Le modèle vocal de cette langue se télécharge. Réessayez dans un instant.';

  @override
  String get vnModelNeeded => 'Il manque le modèle vocal de cette langue. Activez « En ligne quand je suis connecté » dans les réglages pour le télécharger une fois.';

  @override
  String get nwStatusHeader => 'Statut';

  @override
  String get nwAddStatus => 'Ajouter un statut';

  @override
  String get nwStatusNewA11y => 'nouveau';

  @override
  String svReplySent(String name) {
    return 'Réponse envoyée à $name';
  }

  @override
  String get blkYouBlocked => 'Vous avez bloqué ce contact.';

  @override
  String get blkUnblock => 'Débloquer';

  @override
  String get blkListTitle => 'Contacts bloqués';

  @override
  String get blkNone => 'Aucun contact bloqué';

  @override
  String get blkFooter => 'Un contact bloqué ne peut plus vous écrire ni vous appeler, et ne reçoit plus vos statuts ni votre photo. Il n\'en est pas prévenu. Votre téléphone continue de relayer ses messages destinés à d\'autres personnes, sans pouvoir les lire : le maillage ne dépend pas de vos blocages.';

  @override
  String blkUnblockTitle(String name) {
    return 'Débloquer $name ?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'Débloquer $name pour l\'appeler ?';
  }

  @override
  String get nvDone => 'Terminé';

  @override
  String get nvBack => 'Précédent';

  @override
  String get nvForward => 'Suivant';

  @override
  String get nvShare => 'Partager';

  @override
  String get nvOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get nvReload => 'Actualiser';

  @override
  String get nvCopyLink => 'Copier le lien';

  @override
  String get nvLinkCopied => 'Lien copié';

  @override
  String get nvOpen => 'Ouvrir';

  @override
  String get nvMore => 'Plus';

  @override
  String get nvNotSecure => 'Non sécurisé';

  @override
  String get nvErrorTitle => 'Page inaccessible';

  @override
  String get nvErrorBody => 'Droplet n\'a pas pu joindre ce site. Le réseau maillé ne transporte pas le Web : il faut une connexion Internet.';

  @override
  String get nvRetry => 'Réessayer';

  @override
  String get ciLinks => 'Liens';

  @override
  String get chatsFilterNearby => 'À proximité';


  @override
  String get chProxTitle => 'Droplet marche aussi sans Internet';

  @override
  String get chProxActive => 'Des appareils Droplet sont à portée';

  @override
  String get chProxBody => 'Les téléphones proches se relaient les messages. Plus vous êtes nombreux autour, plus ils vont loin.';

  @override
  String get chProxSee => 'Voir autour de moi';

  @override
  String get chStickerPreview => 'Sticker';

  @override
  String get edCrop => 'Recadrer';

  @override
  String get edRotate => 'Pivoter';

  @override
  String get edFilters => 'Filtres';

  @override
  String get edAdjust => 'Ajuster';

  @override
  String get edText => 'Texte';

  @override
  String get edDraw => 'Dessin';

  @override
  String get edTrim => 'Découper';

  @override
  String get edBrightness => 'Luminosité';

  @override
  String get edContrast => 'Contraste';

  @override
  String get edSaturation => 'Saturation';

  @override
  String get edWarmth => 'Chaleur';

  @override
  String get edVignette => 'Vignette';

  @override
  String get edIntensity => 'Intensité';

  @override
  String get edUndo => 'Annuler la retouche';

  @override
  String get edDone => 'OK';

  @override
  String get edTextHint => 'Écrivez…';

  @override
  String get edDelete => 'Supprimer';

  @override
  String get edOriginal => 'Original';

  @override
  String get edStyle => 'Style';

  @override
  String get edBackground => 'Fond';

  @override
  String get stNotificationsHeader => 'Notifications';

  @override
  String get stNotifPreview => 'Aperçu du contenu';

  @override
  String get stNotifPreviewSubtitle => 'Le texte du message s\'affiche dans la notification. Coupé, l\'écran verrouillé annonce seulement un nouveau message.';

  @override
  String get stSearchHint => 'Rechercher un réglage';

  @override
  String get stSearchEmpty => 'Aucun réglage ne correspond';

  @override
  String get chMentionAllSubtitle => 'Prévenir tout le groupe';

  @override
  String get vuOnce => 'Vue unique';

  @override
  String get vuOpened => 'Ouverte';

  @override
  String get vuPhoto => 'Photo';

  @override
  String get vuVideo => 'Vidéo';

  @override
  String get vuMissing => 'Ce média n\'est pas encore arrivé';

  @override
  String get pollClosed => 'Sondage terminé';

  @override
  String pollEndsAt(String quand) {
    return 'Se termine à $quand';
  }

  @override
  String get vuVoice => 'Message vocal';

  @override
  String get apPatternsHeader => 'Motifs du fond';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Jeux';

  @override
  String get apPatternHome => 'Maison';

  @override
  String get apPatternGarden => 'Jardin';

  @override
  String get imTitle => 'Messages importants';

  @override
  String get imSubtitle => 'Ce que vous avez mis de côté';

  @override
  String get imAdd => 'Marquer comme important';

  @override
  String get imRemove => 'Retirer des importants';

  @override
  String get imAdded => 'Ajouté aux importants';

  @override
  String get imRemoved => 'Retiré des importants';

  @override
  String get imEmptyBody => 'Appuyez longuement sur un message pour le marquer comme important et le retrouver ici plus tard.';

  @override
  String get imClearAll => 'Tout retirer';

  @override
  String get imClearAllBody => 'Les messages restent dans leurs discussions ; seules les étoiles sont retirées.';

  @override
  String get imClear => 'Retirer';

  @override
  String get imYou => 'Vous';

  @override
  String get imUnknown => 'Message';

  @override
  String get apPatternsFooter => 'Le motif se pose derrière toutes vos discussions.';

  @override
  String get grCreatedNoMessages => 'Groupe créé · aucun message';

  @override
  String get chatsDelete => 'Supprimer la discussion';

  @override
  String get chatsDeleteBody => 'Les messages disparaissent de ce téléphone. Sans serveur, personne ne peut les retirer de celui des autres.';

  @override
  String get chatsDeleteConfirm => 'Supprimer';

  @override
  String get chatsDeleted => 'Discussion supprimée';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Supprimer la discussion avec $nom ?';
  }

  @override
  String get chatsDocument => 'Document';

  @override
  String get epTitle => 'Messages éphémères';

  @override
  String get epHeadline => 'Activez les messages éphémères dans cette discussion';

  @override
  String get epBody => 'Les nouveaux messages porteront leur date de péremption : ils disparaîtront des deux téléphones au bout de la durée choisie.';

  @override
  String get epDelayHeader => 'Délai avant disparition';

  @override
  String get epHours24 => '24 heures';

  @override
  String get epDays7 => '7 jours';

  @override
  String get epDays90 => '90 jours';

  @override
  String get epOff => 'Non';

  @override
  String get epFooter => 'Le réglage ne touche pas aux messages déjà envoyés : chacun garde la durée qu\'il portait au départ.';

  @override
  String get chOnlineNow => 'En ligne · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Par Internet il y a $count min';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Par Internet il y a $count h';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Par Internet il y a $count j';
  }

  @override
  String get pdfMissing => 'Ce document n\'est pas sur ce téléphone.';

  @override
  String get pdfUnreadable => 'Ce PDF est illisible — il est peut-être arrivé incomplet.';

  @override
  String get giDescription => 'Description';

  @override
  String get giDescriptionAdd => 'Ajouter une description';

  @override
  String get giDescriptionNone => 'Aucune description';

  @override
  String get giDescriptionHint => 'De quoi parle ce groupe ?';

  @override
  String get giOnlyAdminsSend => 'Seuls les administrateurs écrivent';

  @override
  String get giOnlyAdminsSendBody => 'Les autres membres lisent sans pouvoir répondre.';

  @override
  String get giSearchMembers => 'Rechercher un membre';

  @override
  String get chOnlyAdminsCanWrite => 'Seuls les administrateurs peuvent écrire dans ce groupe';

  @override
  String grCreatedBy(String nom) {
    return '$nom a créé le groupe';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom vous a ajouté';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom ne fait plus partie du groupe';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui a ajouté $nom';
  }

  @override
  String get giQrInvite => 'Code QR';

  @override
  String get giQrRenew => 'Nouveau code';

  @override
  String get giQrRenewed => 'Nouveau code créé, l\'ancien ne vaut plus';

  @override
  String get giQrExpired => 'Ce code a expiré';

  @override
  String get giQrExplainer => 'Ce code ne contient aucune clé. Il permet seulement de demander à entrer : c\'est votre téléphone qui accepte, ou non.';

  @override
  String get giQrAlreadyMember => 'Vous êtes déjà dans ce groupe';

  @override
  String get giQrNeedContact => 'Ajoutez d\'abord la personne qui vous invite';

  @override
  String get giQrRequestFailed => 'La demande n\'a pas pu partir';

  @override
  String giQrRequestSent(String nom) {
    return 'Demande envoyée à $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Valable encore $count h';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Valable encore $count min';
  }

  @override
  String get cvNearby => 'À portée';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'En attente';

  @override
  String get cvOutOfReach => 'Hors de portée';

  @override
  String get chWillSendWhenNearby => 'Partira dès qu\'il sera à portée';

  @override
  String cvHops(int count) {
    return '$count sauts';
  }

  @override
  String get nwSeenSection => 'Vus';

  @override
  String get nwReceivedHeader => 'Reçus';

  @override
  String get avTranslateTitle => 'Traduction';

  @override
  String get avTranslateShort => 'Comprendre sans quitter l\'app';

  @override
  String get avTranslateLong => 'Le message est traduit sur votre téléphone : son contenu ne part chez personne, pas même chez un traducteur. L\'original reste à un toucher, parce qu\'une traduction n\'est jamais tout à fait le texte.';

  @override
  String get apStickerQ => 'Tu as un autocollant pour ça ?';

  @override
  String get apOnline => 'en ligne';

  @override
  String get apMessage => 'Message';

  @override
  String get apAutoTranslated => 'Traduit automatiquement';

  @override
  String get apBgSend => 'Regarde le fond 😍';

  @override
  String get apBgA => 'Tu as changé quelque chose ?';

  @override
  String get apBgB => 'Il bouge à chaque message 😮';

  @override
  String get apFormatQ => 'On se retrouve où ?';

  @override
  String get apFormatDemo => 'Rendez-vous **à 18 h** devant le __grand marché__, code `4821`. Surprise : ||un gâteau||';

  @override
  String get apVoiceQ => 'Tu es où ?';

  @override
  String get apVoiceText => 'Je suis devant la pharmacie, je t\'attends jusqu\'à 18 h.';

  @override
  String get apTransQ => 'Hey, tout est prêt ?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'Oui ! On se voit demain à l\'aéroport, porte 12 à 9 h.';

  @override
  String get hlpDataOnDevice => 'SUR VOTRE TÉLÉPHONE';

  @override
  String get hlpDataServers => 'CE QUI PASSE PAR UN SERVEUR';

  @override
  String get hlpDataServersFooter => 'Sans Internet, aucun de ces serveurs n\'intervient : les téléphones se parlent directement.';

  @override
  String get hlpDataNone => 'CE QUE DROPLET NE DEMANDE PAS';

  @override
  String get hlpRowKeys => 'Votre identité';

  @override
  String get hlpRowKeysBody => 'Une paire de clés fabriquée ici, jamais envoyée';

  @override
  String get hlpRowMessages => 'Vos messages';

  @override
  String get hlpRowMessagesBody => 'Dans l\'espace privé de l\'app, effacés à la désinstallation';

  @override
  String get hlpRowProfile => 'Pseudo et photo';

  @override
  String get hlpRowProfileBody => 'Ne partent qu\'aux personnes à qui vous écrivez';

  @override
  String get hlpRowSettings => 'Vos réglages';

  @override
  String get hlpRowSettingsBody => 'Fonds, langue, notifications — tout reste ici';

  @override
  String get hlpRowLog => 'Journal d\'erreurs';

  @override
  String get hlpRowLogBody => 'Un fichier local, qui ne part jamais tout seul';

  @override
  String get hlpRowDirectory => 'Annuaire';

  @override
  String get hlpRowDirectoryBody => 'Voit un pseudo et un identifiant public. Requêtes via Tor : pas votre IP réelle';

  @override
  String get hlpRowMailbox => 'Boîte aux lettres';

  @override
  String get hlpRowMailboxBody => 'Garde un message chiffré jusqu\'à sa remise. Ne peut pas le lire';

  @override
  String get hlpRowSignalling => 'Mise en relation';

  @override
  String get hlpRowSignallingBody => 'Voit deux identifiants le temps d\'établir l\'appel. Aucune voix n\'y passe';

  @override
  String get hlpRowRelay => 'Relais';

  @override
  String get hlpRowRelayBody => 'Fait suivre le son chiffré quand la liaison directe échoue';

  @override
  String get hlpNonePhone => 'Numéro de téléphone';

  @override
  String get hlpNoneEmail => 'Adresse e-mail';

  @override
  String get hlpNoneContacts => 'Votre carnet d\'adresses';

  @override
  String get hlpNoneLocation => 'Votre position';

  @override
  String get hlpNoneAds => 'Publicité et traceurs';

  @override
  String get hlpNoneAnalytics => 'Mesure d\'audience';

  @override
  String get hlpQOffline => 'Comment Droplet marche sans Internet ?';

  @override
  String get hlpAOffline => 'Les téléphones se parlent directement, en Bluetooth et en Wi-Fi. Un message peut aussi voyager de téléphone en téléphone jusqu\'au destinataire, sans jamais passer par un serveur.';

  @override
  String get hlpQCrypto => 'Mes messages sont-ils vraiment chiffrés ?';

  @override
  String get hlpACrypto => 'Oui, de bout en bout, avec le protocole Signal. La clé n\'existe que sur les deux téléphones. Ni un relais, ni la boîte aux lettres, ni nous ne pouvons ouvrir un message.';

  @override
  String get hlpQNoAccount => 'Pourquoi Droplet ne demande ni numéro ni e-mail ?';

  @override
  String get hlpANoAccount => 'Parce qu\'il n\'en a pas besoin. Votre identité est une clé fabriquée sur votre téléphone. Rien à créer, rien à vérifier, et rien à voler ailleurs.';

  @override
  String get hlpQPending => 'Pourquoi mon message reste en attente ?';

  @override
  String get hlpAPending => 'Personne n\'est encore à portée et Internet n\'est pas là. Le message attend dans le téléphone et part dès qu\'un chemin s\'ouvre — vous n\'avez rien à refaire.';

  @override
  String get hlpQAddSomeone => 'Comment ajouter quelqu\'un ?';

  @override
  String get hlpAAddSomeone => 'Approchez vos téléphones : la personne apparaît toute seule. À distance, partagez votre lien d\'invitation, ou scannez son QR code.';

  @override
  String get hlpQUninstall => 'Que se passe-t-il si je désinstalle l\'application ?';

  @override
  String get hlpAUninstall => 'Tout est effacé : messages, contacts, identité. Il n\'existe aucune copie ailleurs, donc aucune restauration. Exportez vos réglages avant, si vous changez de téléphone.';

  @override
  String get hlpQBattery => 'Est-ce que Droplet vide ma batterie ?';

  @override
  String get hlpABattery => 'La recherche d\'appareils autour de vous consomme. Dans les réglages, vous pouvez la réduire ou ne l\'activer qu\'au premier plan.';

  @override
  String get hlpQReport => 'Comment signaler un problème ?';

  @override
  String get hlpAReport => 'Depuis Contact et assistance. Vous verrez le texte exact qui sera envoyé avant qu\'il parte — rien ne quitte votre téléphone sans vous.';

  @override
  String get svLikeStatus => 'Aimer le statut';

  @override
  String get svUnlikeStatus => 'Retirer le j\'aime';

  @override
  String get stAddPhotoSemantics => 'Ajouter une photo de profil';

  @override
  String get stChangePhotoSemantics => 'Changer la photo de profil';

  @override
  String get scOverheat => 'Téléphone en surchauffe — Android a coupé l\'encodeur vidéo. Laissez-le refroidir quelques minutes.';

  @override
  String scTooHeavy(int mo) {
    return 'Fichier trop lourd — $mo Mo maximum pour traverser le réseau local.';
  }

  @override
  String get scUnsupported => 'Ce format n\'est pas pris en charge pour un statut.';

  @override
  String get scUnreadableFile => 'Impossible de lire ce fichier';

  @override
  String get scUnreadableTrack => 'Impossible de lire ce morceau';

  @override
  String get scNothingCaptured => 'L\'enregistrement n\'a rien capturé — réessayez.';

  @override
  String get scVideoTrimmed => 'Vidéo raccourcie à 1 min 30 — seul le début est publié.';

  @override
  String get scUnreadableVideo => 'Vidéo illisible';

  @override
  String get chAiMe => 'Moi';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Voici la fin d\'une conversation dans Droplet entre l\'utilisateur (« Moi ») et $pseudo :';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'L\'utilisateur veut de l\'aide pour répondre à $pseudo. Propose une réponse courte et naturelle, écrite en $langue, à la première personne, comme s\'il l\'envoyait lui-même. Ne donne que la réponse proposée, sans préambule.';
  }

  @override
  String get hlpSectionHeader => 'Aide et confidentialité';

  @override
  String get hlpPrivacy => 'Politique de confidentialité';

  @override
  String get hlpData => 'Vos données';

  @override
  String get hlpDataValue => 'Rien ne part';

  @override
  String get hlpContact => 'Contact et assistance';

  @override
  String get hlpPrivacyTitle => 'Confidentialité';

  @override
  String hlpUpdated(String date) {
    return 'Mis à jour le $date';
  }

  @override
  String get hlpOnlyFrEn => 'Ce texte n\'existe qu\'en français et en anglais. Un document juridique traduit approximativement engagerait plus qu\'il n\'aiderait.';

  @override
  String get hlpReadInEnglish => 'Lire en anglais';

  @override
  String get hlpReadInFrench => 'Lire en français';

  @override
  String get hlpDataTitle => 'Vos données';

  @override
  String get hlpDataLead => 'Ce que Droplet sait de vous, ligne par ligne. Rien ici n\'est une promesse : chaque ligne correspond à du code.';

  @override
  String get hlpStays => 'Ne quitte jamais l\'appareil';

  @override
  String get hlpLeaves => 'Passe par un serveur';

  @override
  String get hlpNever => 'N\'existe pas';

  @override
  String get hlpCountTracking => 'donnée pour vous suivre';

  @override
  String get hlpCountAccount => 'compte à créer';

  @override
  String get hlpCountServers => 'serveurs, et on dit lesquels';

  @override
  String get hlpHelpTitle => 'Aide';

  @override
  String get hlpSearchHint => 'Rechercher';

  @override
  String get hlpNoResult => 'Aucune réponse ne contient ce mot. Écrivez-nous : c\'est peut-être une question qui manque ici.';

  @override
  String get hlpStillStuckFooter => 'Si la réponse n\'y est pas, on répond en personne.';

  @override
  String get hlpContactTitle => 'Contact';

  @override
  String get hlpContactLead => 'Une question, un problème, une idée. On lit tout.';

  @override
  String get hlpBeforeWriting => 'Avant d\'écrire';

  @override
  String get hlpHelpRowBody => 'Huit réponses, consultables sans Internet';

  @override
  String get hlpWriteUs => 'Nous écrire';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'E-mail';

  @override
  String get hlpWhatsAppHello => 'Bonjour, j\'utilise Droplet et j\'ai une question :';

  @override
  String get hlpEmailSubject => 'Droplet — question';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp est introuvable. Le numéro $numero est copié.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'L\'adresse $adresse est copiée.';
  }

  @override
  String get hlpReportHeader => 'Un problème';

  @override
  String get hlpReport => 'Signaler un problème';

  @override
  String get hlpReportBody => 'Vous verrez ce qui part avant que ça parte';

  @override
  String get hlpReportFooter => 'Droplet n\'envoie aucun rapport tout seul : il n\'a aucun serveur pour ça. Un problème ne nous parvient que si vous nous l\'envoyez.';

  @override
  String get hlpReportSubject => 'Droplet — signalement';

  @override
  String get hlpReportSheetLead => 'Dites ce qui s\'est passé. Le texte exact qui partira s\'affiche en dessous.';

  @override
  String get hlpReportHint => 'Ce que je faisais, et ce qui est arrivé…';

  @override
  String get hlpAttachLog => 'Joindre le journal d\'erreurs';

  @override
  String get hlpWhatWillBeSent => 'CE QUI SERA ENVOYÉ';

  @override
  String get hlpLogExcerpt => 'Journal (fin) :';

  @override
  String get hlpCopy => 'Copier';

  @override
  String get hlpCopied => 'Copié';

  @override
  String get hlpOnePerson => 'Droplet est fait par une personne, pas par un service d\'assistance. La réponse peut prendre un jour ou deux — elle arrive.';

  @override
  String get avSectionHeader => 'Ce que Pro apporte';

  @override
  String get avUnlock => 'Débloquer Droplet Pro';

  @override
  String get avVoiceTitle => 'Vocaux en texte';

  @override
  String get avVoiceShort => 'Lire un vocal sans l\'écouter';

  @override
  String get avVoiceLong => 'La transcription se fait sur votre téléphone, hors ligne. Le vocal ne part nulle part, et vous le lisez en réunion, dans le bus, ou quand le réseau n\'est pas là.';

  @override
  String get avFormatTitle => 'Mise en forme';

  @override
  String get avFormatShort => 'Gras, italique, code, spoiler';

  @override
  String get avFormatLong => 'Un mot en gras, une ligne de code, un passage masqué qu\'on découvre d\'un toucher : votre message dit exactement ce que vous vouliez, et rien d\'autre.';

  @override
  String get avWallpaperTitle => 'Fonds et motifs';

  @override
  String get avWallpaperShort => 'Toute la galerie, et les quatre packs';

  @override
  String get avWallpaperLong => 'Chaque fond est dessiné à la main, chaque motif vérifié au rendu avant d\'entrer dans l\'app. Droplet, Jeux, Maison, Jardin : votre écran de discussion ne ressemble à aucun autre.';

  @override
  String get avStickersTitle => 'Autocollants animés';

  @override
  String get avStickersShort => 'La goutte Droplet, en mouvement';

  @override
  String get avStickersLong => 'Des autocollants dessinés pour Droplet, animés image par image, et légers : ils voyagent même par le maillage, sans Internet.';

  @override
  String get avIconTitle => 'Icônes d\'app';

  @override
  String get avIconShort => 'Changer l\'icône sur l\'écran d\'accueil';

  @override
  String get avIconLong => 'Une app de messagerie discrète, ça commence par son icône. Choisissez celle qui vous ressemble, ou celle qu\'on remarque le moins.';

  @override
  String get avBadgeTitle => 'Badge Pro';

  @override
  String get avBadgeShort => 'Il accompagne votre nom';

  @override
  String get avBadgeLong => 'Il ne donne aucun pouvoir sur les autres. Il dit seulement que vous avez payé pour que Droplet reste sans publicité, sans abonnement obligatoire et sans revente de données.';

  @override
  String get sgTitle => 'Stockage du groupe';

  @override
  String get sgEmpty => 'Aucun fichier n\'a encore été partagé dans ce groupe.';

  @override
  String get sgByAuthor => 'Qui envoie le plus';

  @override
  String get sgFiles => 'Fichiers';

  @override
  String get sgSortRecent => 'Les plus récents';

  @override
  String get sgSortHeavy => 'Les plus lourds';

  @override
  String get sgNotOnDevice => 'Pas ici';

  @override
  String get giPhotoChanged => 'Photo du groupe modifiée';

  @override
  String get giPhotoFailed => 'Cette image n\'a pas pu être enregistrée';

  @override
  String sgTotal(int count) {
    return '$count fichiers partagés';
  }

  @override
  String get vrTitle => 'Salon vocal';

  @override
  String get vrJoin => 'Entrer';

  @override
  String get vrBack => 'Revenir';

  @override
  String get vrStart => 'Ouvrir un salon vocal';

  @override
  String get vrNeedsInternet => 'Un salon vocal demande Internet : le maillage porte un message qui attend, pas vingt voix en même temps.';

  @override
  String get vrUnreachable => 'Le serveur d\'appels est injoignable pour le moment.';

  @override
  String vrFull(int count) {
    return 'Le salon est complet : $count personnes au maximum.';
  }

  @override
  String get vrWaiting => 'En attente des autres…';

  @override
  String get vrWaitingBody => 'Le salon est ouvert. Les membres du groupe le voient dans la discussion et entrent quand ils sont disponibles.';

  @override
  String vrPeople(int count) {
    return '$count personnes dedans';
  }

  @override
  String get cvTitle => 'Conversations';

  @override
  String get cvNew => 'Nouvelle conversation';

  @override
  String get cvPinned => 'Épinglées';

  @override
  String get cvRecent => 'Récentes';

  @override
  String get cvPin => 'Épingler';

  @override
  String get cvUnpin => 'Ne plus épingler';

  @override
  String get cvRename => 'Renommer';

  @override
  String get cvRenameHint => 'Titre de la conversation';

  @override
  String get cvUntitled => 'Sans titre';

  @override
  String get cvYesterday => 'Hier';

  @override
  String get cvSearchHint => 'Rechercher dans les conversations';

  @override
  String get cvEmpty => 'Aucune conversation pour l’instant. Posez une première question à l’assistant.';

  @override
  String get cvDeleteTitle => 'Supprimer cette conversation ?';

  @override
  String get cvDeleteBody => 'Elle ne pourra pas être récupérée : elle n’existe que sur cet appareil.';

  @override
  String get jaWorking => 'L’assistant travaille…';

  @override
  String cvNoResult(String terme) {
    return 'Rien trouvé pour « $terme ».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Aucun résultat',
      one: '1 résultat',
      other: '$count résultats',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Aucune étape',
      one: '1 étape',
      other: '$count étapes',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Où part votre message';

  @override
  String get moLocal => 'Local';

  @override
  String get moLocalBody => 'Le modèle tourne sur ce téléphone. Rien ne sort, même sans réseau. Les réponses sont plus courtes et moins sûres.';

  @override
  String get moOnline => 'En ligne';

  @override
  String get moOnlineBody => 'Votre message part chez Groq, qui fait tourner un modèle bien plus grand. Il faut du réseau, et le message quitte le téléphone.';

  @override
  String get moOnlineNoKey => 'Il faut une clé pour parler à un modèle distant. Touchez pour en ajouter une — c\'est gratuit et ça prend une minute.';

  @override
  String get moRetryOnline => 'Refaire en ligne';

  @override
  String get moRetryOnlineWhy => 'Le modèle local a atteint ses limites sur cette question.';

  @override
  String get cpHint => 'Poser une question…';

  @override
  String get cpAdd => 'Ajouter';

  @override
  String get cpPhoto => 'Photo';

  @override
  String get cpCamera => 'Appareil photo';

  @override
  String get cpFile => 'Fichier';

  @override
  String get cpFileHint => 'PDF, texte, code';

  @override
  String get cpDictate => 'Dicter';

  @override
  String get cpSend => 'Envoyer';

  @override
  String get cpStop => 'Arrêter';

  @override
  String get cpThinking => 'L’assistant réfléchit…';

  @override
  String get amCopy => 'Copier';

  @override
  String get amCopyMarkdown => 'Copier en Markdown';

  @override
  String get amCopyMarkdownHint => 'Avec la mise en forme, pour un document';

  @override
  String get amShare => 'Partager';

  @override
  String get amEdit => 'Modifier ma question';

  @override
  String get amEditHint => 'La suite de l’échange sera effacée';

  @override
  String get amEditTitle => 'Modifier cette question ?';

  @override
  String get amEditConfirm => 'Modifier';

  @override
  String get amRegenerate => 'Régénérer';

  @override
  String get amReadAloud => 'Lire à voix haute';

  @override
  String get amAsContext => 'Reprendre comme contexte';

  @override
  String get amAsContextHint => 'Repart de ce message pour la suite';

  @override
  String get amChapter => 'Marquer comme chapitre';

  @override
  String get amChapterHint => 'Pour le retrouver dans une longue conversation';

  @override
  String get amUnchapter => 'Ne plus marquer';

  @override
  String get amChapters => 'Chapitres';

  @override
  String get amChaptersEmpty => 'Aucun chapitre. Appuyez longuement sur un message et choisissez « Marquer comme chapitre » pour le retrouver ici.';

  @override
  String amEditBody(int count) {
    return '$count messages qui suivent seront effacés : ils répondaient à l’ancienne question.';
  }

  @override
  String get trAssistant => 'Assistant';

  @override
  String get trArtifacts => 'Artéfacts';

  @override
  String get trMemory => 'Mémoire';

  @override
  String get trHelp => 'Aide';

  @override
  String get arVersions => 'Versions';

  @override
  String get arLatest => 'La plus récente';

  @override
  String get arSource => 'Source';

  @override
  String get arPreview => 'Aperçu';

  @override
  String get arGone => 'Cet artéfact n’existe plus.';

  @override
  String get arKindPage => 'Page';

  @override
  String get arKindCode => 'Code';

  @override
  String get arKindDiagram => 'Schéma';

  @override
  String get arKindData => 'Données';

  @override
  String get arKindDoc => 'Document';

  @override
  String arVersion(int n) {
    return 'Version $n';
  }

  @override
  String get aiSources => 'Sources';

  @override
  String get aiToolReading => 'Lecture de la pièce jointe…';

  @override
  String get aiToolWriting => 'Production du fichier…';

  @override
  String get aiToolRemembering => 'Mise en mémoire…';

  @override
  String get arEmpty => 'Aucun artéfact pour l’instant. L’assistant en crée un dès qu’il produit une page, un tableau ou du code assez long pour gêner dans la conversation.';

  @override
  String get raTitle => 'Assistant en ligne';

  @override
  String get raIntro => 'L’assistant local fonctionne sans rien configurer. Le mode en ligne, lui, demande une clé : c’est elle qui paie les réponses, et elle reste sur ce téléphone.';

  @override
  String get raKey => 'Clé';

  @override
  String get raKeySaved => 'Clé enregistrée';

  @override
  String get raKeyFooter => 'Elle dort dans le trousseau du système et ne s’affiche jamais en entier.';

  @override
  String get raKeyRemove => 'Retirer la clé';

  @override
  String get raWhere => 'Une clé se crée sur console.groq.com, dans « API Keys ». Elle commence par gsk_.';

  @override
  String get raPaste => 'Coller';

  @override
  String get raSaveAndTest => 'Enregistrer et tester';

  @override
  String get raTest => 'Tester la clé';

  @override
  String get raTesting => 'Test en cours…';

  @override
  String get raNotTested => 'Pas encore testée';

  @override
  String get raNotTestedBody => 'Un appel de huit mots suffit à savoir si elle marche. Autant le faire ici plutôt qu’au milieu d’une question.';

  @override
  String get raWorks => 'La clé fonctionne';

  @override
  String get raWorksBody => 'Le mode en ligne est disponible dans la conversation, sur la pastille à côté du champ de saisie.';

  @override
  String get raRefused => 'Clé refusée';

  @override
  String get raRefusedBody => 'Le serveur ne la reconnaît pas. Souvent un caractère manquant au collage, ou une clé révoquée depuis.';

  @override
  String get raNoNetwork => 'Serveur injoignable';

  @override
  String get raNoNetworkBody => 'La clé n’est pas en cause : la requête n’est jamais arrivée. Vérifiez la connexion, puis réessayez.';

  @override
  String get raModelGone => 'Modèle indisponible';

  @override
  String get raModelGoneBody => 'La clé est acceptée, mais le serveur n’a rien renvoyé. Le modèle a probablement été retiré du catalogue.';

  @override
  String get raQuota => 'Trop de requêtes';

  @override
  String get raQuotaBody => 'La clé marche, mais le compte a atteint sa limite. Réessayez plus tard, ou vérifiez son crédit.';

  @override
  String get raWhatGoesOut => 'Ce qui part';

  @override
  String get raModel => 'Modèle';

  @override
  String get raWhatGoesOutFooter => 'En mode en ligne, votre message et les échanges précédents de la conversation partent chez Groq. Rien d’autre : ni vos contacts, ni vos autres discussions, ni votre position.';

  @override
  String get aiDownloadTitle => 'Télécharger le modèle local ?';

  @override
  String get aiDownloadConfirm => 'Télécharger';

  @override
  String get aiDownloading => 'Téléchargement du modèle local';

  @override
  String aiDownloadBody(int mo) {
    return '$mo Mo à télécharger, une seule fois. Ensuite l’assistant répond sans réseau, et rien ne quitte le téléphone. Vous pouvez continuer à l’utiliser en ligne pendant le téléchargement.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo Mo à télécharger, une seule fois. Ensuite l’assistant répond sans réseau et rien ne quitte le téléphone.';
  }

  @override
  String get aiGreetingPlain => 'Bonjour';

  @override
  String get aiGreetingHint => 'Posez une question, joignez une photo, ou demandez un document.';

  @override
  String get aiChipExplain => 'Explique-moi…';

  @override
  String get aiChipWrite => 'Écris un message';

  @override
  String get aiChipSummarize => 'Résume ce texte';

  @override
  String get aiChipTranslate => 'Traduis en…';

  @override
  String aiGreeting(String nom) {
    return 'Bonjour, $nom';
  }

  @override
  String get cpNoPhoto => 'Pas de photo : le modèle en ligne ne sait pas lire une image. Il lit en revanche les PDF, y compris longs.';

  @override
  String get mvOpen => 'Mode vocal';

  @override
  String get mvTapToTalk => 'Touchez pour parler';

  @override
  String get mvHoldToTalk => 'Maintenez pour parler';

  @override
  String get mvListening => 'J\'écoute…';

  @override
  String get mvTranscribing => 'Transcription…';

  @override
  String get mvSpeaking => 'Réponse à voix haute';

  @override
  String get mvProblem => 'Un problème';

  @override
  String get mvHandsFree => 'Mains libres';

  @override
  String get mvHold => 'Maintien';

  @override
  String get mvTalk => 'Parler';

  @override
  String get mvInterrupt => 'Interrompre';

  @override
  String get mvNoMic => 'Droplet n\'a pas accès au micro. Autorisez-le dans les réglages du téléphone.';

  @override
  String get mvFailed => 'Ce tour n\'a pas abouti. Touchez pour réessayer.';

  @override
  String get mvLive => 'En direct';

  @override
  String get mvCaptions => 'Sous-titres';

  @override
  String get mvExit => 'Quitter le mode vocal';

  @override
  String get mvMute => 'Couper le micro';

  @override
  String get mvUnmute => 'Rallumer le micro';

  @override
  String get mvMuted => 'Micro coupé';

  @override
  String get mvTapToInterrupt => 'Toucher pour interrompre';

  @override
  String scCompressing(int percent) {
    return 'Compression… $percent %';
  }

  @override
  String get scStillHeavy => 'Cette vidéo reste au-dessus de 2 Mo : son transfert sera plus lent.';

  @override
  String get baConnecting => 'Connexion…';

  @override
  String get baMute => 'Couper le micro';

  @override
  String get baUnmute => 'Rallumer le micro';

  @override
  String get baHangUp => 'Raccrocher';

  @override
  String baOngoing(String name) {
    return 'Appel en cours avec $name. Toucher pour y revenir.';
  }

  @override
  String get ntfOngoingCall => 'Appel en cours';

  @override
  String get ntfViaMesh => 'Par le maillage';

  @override
  String get ntfViaInternet => 'Par Internet';

  @override
  String get shSend => 'Envoyer';

  @override
  String get shRecents => 'Récents';

  @override
  String get shPickRecipients => 'Choisissez un ou plusieurs destinataires';

  @override
  String shSendCount(int count) {
    return 'Envoyer à $count';
  }

  @override
  String shSelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get apcNothingYet => 'Rien encore échangé';

  @override
  String get apcOnline => 'En ligne';

  @override
  String get apcOffline => 'Hors ligne';

  @override
  String get apcPhoto => 'Photo';

  @override
  String get apcVoice => 'Message vocal';

  @override
  String get apcAttachment => 'Pièce jointe';

  @override
  String get chKeyboardTooltip => 'Clavier';

  @override
  String get asGallery => 'Galerie';

  @override
  String get asFile => 'Fichier';

  @override
  String get asLocation => 'Position';

  @override
  String get asSticker => 'Sticker';

  @override
  String get asPoll => 'Sondage';

  @override
  String get asNoGalleryAccess => 'Droplet n\'a pas accès à vos photos. Autorisez-le dans les réglages du téléphone, ou choisissez une autre source ci-dessous.';

  @override
  String asSendCount(int count) {
    return 'Envoyer $count';
  }

  @override
  String get asEmptyGallery => 'Aucune photo ni vidéo sur ce téléphone.';

  @override
  String get expAucunPairTitre => 'Personne à proximité ?';

  @override
  String get expAucunPairTexte => 'Ce n\'est pas une panne. Droplet cherche en permanence ; dès qu\'un appareil passe, la liaison se fait toute seule.';

  @override
  String get expRelaisTitre => 'Passé par un autre';

  @override
  String get expRelaisTexte => 'Cette icône dit que le message a traversé un ou plusieurs appareils avant d\'arriver. C\'est la force du maillage.';

  @override
  String get expApercuTitre => 'Coup d\'œil';

  @override
  String get expApercuTexte => 'Gardez le doigt sur une conversation pour en lire les derniers messages sans l\'ouvrir — ni la marquer comme lue.';

  @override
  String get expOfficielTitre => 'Le compte Droplet';

  @override
  String get expOfficielTexte => 'Les nouveautés de l\'application arrivent ici. Chaque annonce est signée : personne ne peut en fabriquer une fausse.';

  @override
  String get expMicroTitre => 'Parler sans lâcher';

  @override
  String get expMicroTexte => 'Maintenez pour enregistrer. Glissez vers la gauche pour annuler, vers le haut pour continuer sans tenir le doigt.';

  @override
  String get expCameraTitre => 'Micro ou caméra';

  @override
  String get expCameraTexte => 'Une pression brève sur ce bouton bascule entre message vocal et message vidéo rond.';

  @override
  String get expVueUniqueTitre => 'Une seule fois';

  @override
  String get expVueUniqueTexte => 'Activez le « 1 » et le prochain envoi ne pourra être ouvert qu\'une fois, puis disparaîtra.';

  @override
  String get expPiecesTitre => 'Plusieurs d\'un coup';

  @override
  String get expPiecesTexte => 'Le trombone ouvre votre galerie dans l\'application. Cochez plusieurs photos : le chiffre indique l\'ordre d\'envoi.';

  @override
  String get expStickersTitre => 'Stickers et clavier';

  @override
  String get expStickersTexte => 'Cette icône remplace le clavier par les stickers, et redevient un clavier d\'un seul toucher.';

  @override
  String get expEphemeresTitre => 'Messages qui s\'effacent';

  @override
  String get expEphemeresTexte => 'Réglez un délai et les nouveaux messages de cette conversation s\'effaceront des deux téléphones.';

  @override
  String get expVerrouTitre => 'Conversation verrouillée';

  @override
  String get expVerrouTexte => 'Verrouillée, une conversation ne montre plus son dernier message dans la liste, et demande à être déverrouillée.';

  @override
  String get expCodeTitre => 'Vérifier un contact';

  @override
  String get expCodeTexte => 'Comparez ce code côte à côte avec votre correspondant : s\'il est identique, personne ne s\'est glissé entre vous.';

  @override
  String get expStatutTitre => 'Statuts de 24 heures';

  @override
  String get expStatutTexte => 'Un statut vit un jour, puis s\'efface. Il voyage de téléphone en téléphone, même sans Internet.';

  @override
  String get expGardeTitre => 'Rien ne se perd';

  @override
  String get expGardeTexte => 'Un message envoyé à quelqu\'un d\'absent est gardé une semaine et repart tout seul dès qu\'un chemin s\'ouvre.';

  @override
  String get expVoieTitre => 'Par où ça passe';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi direct ou Internet : Droplet prend ce qui est disponible et change de voie sans rien vous demander.';

  @override
  String get cnAnnouncement => 'Nouveauté de Droplet';

  @override
  String get cnClearAll => 'Tout effacer';

  @override
  String get cnClearAllTitle => 'Effacer toutes les notifications ?';

  @override
  String get cnClearAllBody => 'Le centre sera vidé. Vos conversations et vos messages ne sont pas touchés.';

  @override
  String get cnDelete => 'Effacer';

  @override
  String get cnEmptyTitle => 'Rien de nouveau';

  @override
  String get cnEmptyBody => 'Les mentions, les réactions à vos messages, les appels manqués et les nouveautés de Droplet apparaîtront ici.';

  @override
  String get cnMentioned => 'vous a mentionné';

  @override
  String get cnShowLess => 'Afficher moins';

  @override
  String get cnStatusLike => 'a aimé votre statut';

  @override
  String get cnStatusReply => 'a répondu à votre statut';

  @override
  String get cnTitle => 'Centre de notifications';

  @override
  String get ncDeliveryHeader => 'Présentation';

  @override
  String get ncMentionsOnly => 'Mentions seulement';

  @override
  String get ncMentionsOnlySub => 'Seulement quand on écrit @votre pseudo ou @tous';

  @override
  String get ncMute1h => '1 heure';

  @override
  String get ncMute8h => '8 heures';

  @override
  String get ncMute1w => '1 semaine';

  @override
  String get ncMuteAlways => 'Toujours';

  @override
  String get ncMuteFooter => 'Aucune notification ni son. Les messages arrivent quand même et vous attendent.';

  @override
  String get ncMuteFooterGroup => 'Aucune notification ni son. Les mentions vous parviennent quand même.';

  @override
  String get ncMuteHeader => 'Sourdine';

  @override
  String get ncMuteOff => 'Désactivée';

  @override
  String get ncPreviewAlways => 'Toujours';

  @override
  String get ncPreviewFooter => 'Sans aperçu, la notification dit seulement « Nouveau message » : rien ne se lit sur l\'écran verrouillé.';

  @override
  String get ncPreviewHeader => 'Aperçu du message';

  @override
  String get ncPreviewNever => 'Jamais';

  @override
  String get ncQuiet => 'Livraison discrète';

  @override
  String get ncQuietSub => 'Dans le volet, sans son ni bannière';

  @override
  String get ncSampleAuthor => 'Léa';

  @override
  String get ncSampleHidden => 'Nouveau message';

  @override
  String get ncSampleLabel => 'Exemple de notification';

  @override
  String get ncSampleText => 'On se retrouve à 19 h ?';

  @override
  String get ncStateMentions => 'Mentions seulement';

  @override
  String get ncStateMuted => 'En sourdine';

  @override
  String get ncStateOn => 'Activées';

  @override
  String get ncStateQuiet => 'Discrètes';

  @override
  String get ncSystemFooter => 'La sonnerie et les bulles de cette conversation se règlent dans Android.';

  @override
  String get ncSystemSettings => 'Son et bulles';

  @override
  String get ncTitle => 'Notifications';

  @override
  String get ntfNewMessage => 'Nouveau message';

  @override
  String get ntfNow => 'maintenant';

  @override
  String get rnBanners => 'Bannières';

  @override
  String get rnBannersSub => 'Quand un message arrive pendant que Droplet est ouvert';

  @override
  String get rnFocus1h => 'Pendant 1 heure';

  @override
  String get rnFocusEvening => 'Jusqu\'à ce soir';

  @override
  String get rnFocusTomorrow => 'Jusqu\'à demain matin';

  @override
  String get rnFocusFooter => 'Droplet se tait : les messages arrivent et vous attendent. Les appels sonnent toujours.';

  @override
  String get rnFocusHeader => 'Concentration';

  @override
  String get rnFocusMentions => 'Laisser passer les mentions';

  @override
  String get rnFocusMentionsSub => 'Quand on écrit @votre pseudo dans un groupe';

  @override
  String get rnFocusOff => 'Concentration désactivée';

  @override
  String get rnFocusOffSub => 'Les notifications arrivent normalement';

  @override
  String get rnFocusOn => 'Concentration activée';

  @override
  String get rnFocusStop => 'Désactiver la concentration';

  @override
  String get rnFocusStopShort => 'Arrêter';

  @override
  String get rnInAppHeader => 'Dans Droplet';

  @override
  String get rnMutedEmpty => 'Aucune conversation en sourdine.';

  @override
  String get rnMutedHeader => 'En sourdine';

  @override
  String get rnPreview => 'Afficher l\'aperçu';

  @override
  String get rnPreviewFooter => 'Le texte des messages dans les notifications. Chaque conversation peut faire autrement.';

  @override
  String get rnSystem => 'Réglages Android';

  @override
  String get rnSystemFooter => 'Autorisations, sons et bulles de Droplet dans les réglages du téléphone.';

  @override
  String get stNotificationsSubtitle => 'Sourdine, aperçus, concentration';

  @override
  String cnBellUnread(int count) {
    return 'Notifications, $count nouvelles';
  }

  @override
  String cnMore(int count) {
    return '+$count de plus';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count de plus';
  }

  @override
  String cnQuoted(String texte) {
    return '« $texte »';
  }

  @override
  String cnReacted(String emoji) {
    return 'a réagi $emoji à votre message';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Jusqu\'à $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Par défaut ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Mettre $nom en sourdine';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Jusqu\'à $heure · les appels sonnent toujours';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n discussions';
  }

  @override
  String get chatsNetSearching => 'Recherche d\'appareils proches…';

  @override
  String get cfEmptyUnreadTitle => 'Tout est lu';

  @override
  String get cfEmptyUnreadBody => 'Les discussions avec des messages non lus apparaîtront ici.';

  @override
  String get cfEmptyGroupsTitle => 'Aucun groupe';

  @override
  String get cfEmptyGroupsBody => 'Créez-en un avec le bouton +, en haut à droite.';

  @override
  String get cfEmptyOtherTitle => 'Rien ici pour l\'instant';

  @override
  String get ciLockedWhereHint => 'Verrouillée. Pour la retrouver, tirez la liste des discussions vers le bas.';

  @override
  String get chDraftLabel => 'Brouillon :';

  @override
  String get rsMorning => 'Bonjour';

  @override
  String get rsEvening => 'Bonsoir';

  @override
  String get rsUnreadOne => '1 message non lu';

  @override
  String get rsChatsOne => 'dans 1 discussion';

  @override
  String get rsMentionsOne => '1 mention';

  @override
  String get rsMissedOne => '1 appel manqué';

  @override
  String get rsSeeUnread => 'Voir les non lus';

  @override
  String rsUnreadMany(int count) {
    return '$count messages non lus';
  }

  @override
  String rsChatsMany(int count) {
    return 'dans $count discussions';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count mentions';
  }

  @override
  String rsMissedMany(int count) {
    return '$count appels manqués';
  }

  @override
  String get camUnavailable => 'Appareil photo indisponible. Vérifiez l\'autorisation dans les réglages.';

  @override
  String get camTakePhoto => 'Prendre une photo';

  @override
  String get camFlip => 'Retourner l\'appareil photo';

  @override
  String get chE2eNotice => 'Les messages sont chiffrés de bout en bout. Personne d\'autre, pas même Droplet, ne peut les lire.';

  @override
  String chCallUnreachable(String name) {
    return '$name n\'est pas à portée : l\'appel passera quand vous serez proches ou connectés.';
  }

  @override
  String get chPin => 'Épingler';

  @override
  String get chUnpin => 'Désépingler';

  @override
  String get chPinnedMessage => 'Message épinglé';

  @override
  String get chVoicePlay => 'Écouter';

  @override
  String get chVoicePause => 'Pause';

  @override
  String chPinnedMessageN(String position) {
    return 'Message épinglé $position';
  }

  @override
  String get msgInfo => 'Infos';

  @override
  String get imSearch => 'Rechercher';

  @override
  String get apcVideo => 'Vidéo';
}
