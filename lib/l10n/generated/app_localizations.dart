import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Nom de l'application, tel qu'affiché par le système.
  ///
  /// In fr, this message translates to:
  /// **'Droplet'**
  String get appTitle;

  /// No description provided for @actionSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get actionSend;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get actionSearch;

  /// No description provided for @actionClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get actionDone;

  /// No description provided for @actionNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get actionBack;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// No description provided for @actionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// No description provided for @tabChats.
  ///
  /// In fr, this message translates to:
  /// **'Discussions'**
  String get tabChats;

  /// No description provided for @tabNews.
  ///
  /// In fr, this message translates to:
  /// **'Actus'**
  String get tabNews;

  /// No description provided for @tabCalls.
  ///
  /// In fr, this message translates to:
  /// **'Appels'**
  String get tabCalls;

  /// No description provided for @tabPeers.
  ///
  /// In fr, this message translates to:
  /// **'Pairs'**
  String get tabPeers;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get sectionAppearance;

  /// No description provided for @appearanceAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get appearanceAuto;

  /// No description provided for @appearanceLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get appearanceDark;

  /// No description provided for @appearanceFooter.
  ///
  /// In fr, this message translates to:
  /// **'Droplet est conçu pour le mode sombre : sur un écran OLED les pixels noirs sont éteints, ce qui économise la batterie et n\'éblouit pas dans l\'obscurité. Le mode clair reste disponible pour la lecture en plein soleil.'**
  String get appearanceFooter;

  /// No description provided for @sectionLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get sectionLanguage;

  /// No description provided for @languageAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique (langue du téléphone)'**
  String get languageAuto;

  /// No description provided for @languageFooter.
  ///
  /// In fr, this message translates to:
  /// **'« Automatique » suit la langue réglée sur l\'appareil. Si cette langue n\'est pas encore prise en charge, Droplet reste en français.'**
  String get languageFooter;

  /// No description provided for @chatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Discussions'**
  String get chatsTitle;

  /// No description provided for @chatsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get chatsSearchHint;

  /// No description provided for @chatsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get chatsFilterAll;

  /// No description provided for @chatsFilterUnread.
  ///
  /// In fr, this message translates to:
  /// **'Non lues'**
  String get chatsFilterUnread;

  /// No description provided for @chatsFilterGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get chatsFilterGroups;

  /// No description provided for @chatsFilterPinned.
  ///
  /// In fr, this message translates to:
  /// **'Épinglées'**
  String get chatsFilterPinned;

  /// No description provided for @chatsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune discussion'**
  String get chatsEmptyTitle;

  /// No description provided for @chatsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Approchez-vous d\'un appareil qui utilise Droplet : il apparaîtra ici automatiquement.'**
  String get chatsEmptySubtitle;

  /// No description provided for @chatsSearchEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get chatsSearchEmptyTitle;

  /// No description provided for @chatsSearchEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre nom.'**
  String get chatsSearchEmptySubtitle;

  /// Sous-titre de l'écran des discussions indiquant le nombre de pairs joignables.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Recherche de pairs…} one{{count} pair à proximité} other{{count} pairs à proximité}}'**
  String peersAtProximity(int count);

  /// No description provided for @obMinChars.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 3 caractères'**
  String get obMinChars;

  /// No description provided for @obChoosePseudo.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un pseudo pour commencer'**
  String get obChoosePseudo;

  /// No description provided for @obRestoreFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la restauration'**
  String get obRestoreFailed;

  /// No description provided for @obPhotoSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer la photo'**
  String get obPhotoSaveFailed;

  /// No description provided for @obShareUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Partage indisponible'**
  String get obShareUnavailable;

  /// No description provided for @obBackupPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe de la sauvegarde'**
  String get obBackupPasswordTitle;

  /// No description provided for @obBackupPasswordMessage.
  ///
  /// In fr, this message translates to:
  /// **'Celui que vous aviez choisi en exportant votre identité.'**
  String get obBackupPasswordMessage;

  /// No description provided for @obBackupPasswordPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get obBackupPasswordPlaceholder;

  /// No description provided for @obRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get obRestore;

  /// No description provided for @obSkipStep.
  ///
  /// In fr, this message translates to:
  /// **'Passer cette étape'**
  String get obSkipStep;

  /// No description provided for @obContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get obContinue;

  /// No description provided for @obStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get obStart;

  /// No description provided for @obAlreadyHaveBackup.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà une sauvegarde'**
  String get obAlreadyHaveBackup;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans\nDroplet'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une messagerie qui fonctionne là où il n\'y a plus de réseau.'**
  String get obWelcomeSubtitle;

  /// No description provided for @obFeatOfflineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sans internet, sans opérateur'**
  String get obFeatOfflineTitle;

  /// No description provided for @obFeatOfflineText.
  ///
  /// In fr, this message translates to:
  /// **'Les téléphones se parlent directement, de proche en proche. Aucune antenne, aucune facture.'**
  String get obFeatOfflineText;

  /// No description provided for @obFeatEncryptedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Chiffré de bout en bout'**
  String get obFeatEncryptedTitle;

  /// No description provided for @obFeatEncryptedText.
  ///
  /// In fr, this message translates to:
  /// **'Même les téléphones qui relaient vos messages ne peuvent pas les lire.'**
  String get obFeatEncryptedText;

  /// No description provided for @obFeatLocalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien ne quitte votre appareil'**
  String get obFeatLocalTitle;

  /// No description provided for @obFeatLocalText.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte, pas de serveur, pas de collecte. Vos conversations restent chez vous.'**
  String get obFeatLocalText;

  /// No description provided for @obRelayTitle.
  ///
  /// In fr, this message translates to:
  /// **'De proche\nen proche'**
  String get obRelayTitle;

  /// No description provided for @obRelaySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre message saute d\'un téléphone à l\'autre jusqu\'à son destinataire, même si vous n\'êtes pas à portée directe.'**
  String get obRelaySubtitle;

  /// No description provided for @obFeatCrowdTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus on est nombreux, plus loin ça porte'**
  String get obFeatCrowdTitle;

  /// No description provided for @obFeatCrowdText.
  ///
  /// In fr, this message translates to:
  /// **'Chaque appareil à portée agrandit le réseau pour tout le monde.'**
  String get obFeatCrowdText;

  /// No description provided for @obFeatNothingLostTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien ne se perd'**
  String get obFeatNothingLostTitle;

  /// No description provided for @obFeatNothingLostText.
  ///
  /// In fr, this message translates to:
  /// **'Un message destiné à quelqu\'un d\'absent attend, puis repart dès qu\'un chemin s\'ouvre.'**
  String get obFeatNothingLostText;

  /// No description provided for @obSafetyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se retrouver,\nsans réseau'**
  String get obSafetyTitle;

  /// No description provided for @obSafetySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quand plus rien ne fonctionne, savoir où sont les autres et qu\'ils vont bien devient l\'information la plus utile.'**
  String get obSafetySubtitle;

  /// No description provided for @obFeatMapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une carte qui marche hors ligne'**
  String get obFeatMapTitle;

  /// No description provided for @obFeatMapText.
  ///
  /// In fr, this message translates to:
  /// **'Les zones que vous consultez restent sur le téléphone. Une fois parcourues, elles s\'affichent sans internet.'**
  String get obFeatMapText;

  /// No description provided for @obFeatMeshPosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les positions viennent du mesh'**
  String get obFeatMeshPosTitle;

  /// No description provided for @obFeatMeshPosText.
  ///
  /// In fr, this message translates to:
  /// **'Aucun serveur : la position part du téléphone de votre contact, chiffrée, et saute d\'appareil en appareil jusqu\'au vôtre.'**
  String get obFeatMeshPosText;

  /// No description provided for @obFeatCheckinTitle.
  ///
  /// In fr, this message translates to:
  /// **'« Je suis en sécurité », en un geste'**
  String get obFeatCheckinTitle;

  /// No description provided for @obFeatCheckinText.
  ///
  /// In fr, this message translates to:
  /// **'Un seul appui diffuse votre statut à tout le voisinage. Vous choisissez d\'y joindre une position approximative, ou pas.'**
  String get obFeatCheckinText;

  /// No description provided for @obStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Donner des\nnouvelles'**
  String get obStatusTitle;

  /// No description provided for @obStatusSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une photo, un mot, une humeur : votre statut circule de téléphone en téléphone, comme vos messages.'**
  String get obStatusSubtitle;

  /// No description provided for @obFeatStatusMediaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photo, vidéo ou texte'**
  String get obFeatStatusMediaTitle;

  /// No description provided for @obFeatStatusMediaText.
  ///
  /// In fr, this message translates to:
  /// **'Publiez ce que vous voulez montrer. Les personnes à portée le reçoivent, sans passer par internet.'**
  String get obFeatStatusMediaText;

  /// No description provided for @obFeatStatusSeenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous voyez qui l\'a regardé'**
  String get obFeatStatusSeenTitle;

  /// No description provided for @obFeatStatusSeenText.
  ///
  /// In fr, this message translates to:
  /// **'Chaque personne qui ouvre votre statut vous le fait savoir en retour, par le même chemin.'**
  String get obFeatStatusSeenText;

  /// No description provided for @obFeatStatusExpireTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ça disparaît après un jour'**
  String get obFeatStatusExpireTitle;

  /// No description provided for @obFeatStatusExpireText.
  ///
  /// In fr, this message translates to:
  /// **'Vingt-quatre heures, puis le statut s\'efface de tous les téléphones qui l\'avaient reçu.'**
  String get obFeatStatusExpireText;

  /// No description provided for @obRemovePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get obRemovePhoto;

  /// No description provided for @obChoosePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une photo'**
  String get obChoosePhoto;

  /// No description provided for @obPhotoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un visage,\nsi vous voulez'**
  String get obPhotoTitle;

  /// No description provided for @obPhotoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Elle aide les autres à vous reconnaître dans une liste. Rien ne vous oblige à en mettre une.'**
  String get obPhotoSubtitle;

  /// No description provided for @obFeatPhotoLocalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Elle reste sur ce téléphone'**
  String get obFeatPhotoLocalTitle;

  /// No description provided for @obFeatPhotoLocalText.
  ///
  /// In fr, this message translates to:
  /// **'Aucun serveur ne la reçoit, aucune sauvegarde en ligne ne la conserve. Elle vit dans le dossier de l\'application, et nulle part ailleurs.'**
  String get obFeatPhotoLocalText;

  /// No description provided for @obFeatPhotoCompressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réduite avant d\'être rangée'**
  String get obFeatPhotoCompressTitle;

  /// No description provided for @obFeatPhotoCompressText.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n\'en garde qu\'une vignette de 320 pixels. Votre photo d\'origine n\'est jamais copiée.'**
  String get obFeatPhotoCompressText;

  /// No description provided for @obNetworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet grandit\navec vous'**
  String get obNetworkTitle;

  /// No description provided for @obNetworkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Chaque personne qui l\'installe agrandit le réseau — pour elle, et pour tous ceux qui sont autour.'**
  String get obNetworkSubtitle;

  /// No description provided for @obSendToFriend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer Droplet à un proche'**
  String get obSendToFriend;

  /// No description provided for @obFeatShareOfflineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Même le partage se passe d\'internet'**
  String get obFeatShareOfflineTitle;

  /// No description provided for @obFeatShareOfflineText.
  ///
  /// In fr, this message translates to:
  /// **'Droplet vous envoie son propre fichier d\'installation. Il part par Bluetooth, par Wi-Fi Direct ou sur une carte mémoire — aucune connexion nécessaire, des deux côtés.'**
  String get obFeatShareOfflineText;

  /// No description provided for @obFeatThreeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trois personnes suffisent pour commencer'**
  String get obFeatThreeTitle;

  /// No description provided for @obFeatThreeText.
  ///
  /// In fr, this message translates to:
  /// **'À deux, vous vous écrivez à portée de vue. À quelques-uns dans un quartier, les messages se relaient et la portée devient bien plus grande que chaque téléphone.'**
  String get obFeatThreeText;

  /// No description provided for @obIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment doit-on\nvous appeler ?'**
  String get obIdentityTitle;

  /// No description provided for @obIdentitySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom apparaîtra auprès des personnes qui vous croisent. Vous pouvez en choisir un qui ne vous identifie pas.'**
  String get obIdentitySubtitle;

  /// No description provided for @obPseudoHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre pseudo'**
  String get obPseudoHint;

  /// No description provided for @obFeatKeysTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos clés sont créées ici, maintenant'**
  String get obFeatKeysTitle;

  /// No description provided for @obFeatKeysText.
  ///
  /// In fr, this message translates to:
  /// **'Elles ne quittent jamais ce téléphone. Pensez à faire une sauvegarde depuis les réglages : sans elle, une identité perdue l\'est définitivement.'**
  String get obFeatKeysText;

  /// No description provided for @splashCaption.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne. Sans opérateur.'**
  String get splashCaption;

  /// No description provided for @chatsMeshNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau mesh'**
  String get chatsMeshNetwork;

  /// No description provided for @chatsNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get chatsNew;

  /// No description provided for @chatsNewGroup.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get chatsNewGroup;

  /// No description provided for @chatsAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get chatsAssistant;

  /// No description provided for @chatsEmergencyMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode urgence'**
  String get chatsEmergencyMode;

  /// No description provided for @chatsUnpin.
  ///
  /// In fr, this message translates to:
  /// **'Désépingler'**
  String get chatsUnpin;

  /// No description provided for @chatsPin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler en haut'**
  String get chatsPin;

  /// No description provided for @chatsUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get chatsUnmute;

  /// No description provided for @chatsMute.
  ///
  /// In fr, this message translates to:
  /// **'Couper le son'**
  String get chatsMute;

  /// No description provided for @chatsArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get chatsArchive;

  /// No description provided for @swipePin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler'**
  String get swipePin;

  /// No description provided for @swipeUnpin.
  ///
  /// In fr, this message translates to:
  /// **'Détacher'**
  String get swipeUnpin;

  /// No description provided for @swipeMute.
  ///
  /// In fr, this message translates to:
  /// **'Silence'**
  String get swipeMute;

  /// No description provided for @swipeUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Son'**
  String get swipeUnmute;

  /// No description provided for @swipeArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get swipeArchive;

  /// No description provided for @fmtBold.
  ///
  /// In fr, this message translates to:
  /// **'Gras'**
  String get fmtBold;

  /// No description provided for @fmtItalic.
  ///
  /// In fr, this message translates to:
  /// **'Italique'**
  String get fmtItalic;

  /// No description provided for @fmtStrike.
  ///
  /// In fr, this message translates to:
  /// **'Barré'**
  String get fmtStrike;

  /// No description provided for @fmtMono.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get fmtMono;

  /// No description provided for @fmtSpoiler.
  ///
  /// In fr, this message translates to:
  /// **'Spoiler'**
  String get fmtSpoiler;

  /// No description provided for @vnTranscribing.
  ///
  /// In fr, this message translates to:
  /// **'Transcription…'**
  String get vnTranscribing;

  /// No description provided for @vnTranscribeFailed.
  ///
  /// In fr, this message translates to:
  /// **'Transcription impossible sur cet appareil'**
  String get vnTranscribeFailed;

  /// No description provided for @vnNoSpeech.
  ///
  /// In fr, this message translates to:
  /// **'Aucune parole reconnue'**
  String get vnNoSpeech;

  /// No description provided for @msgTranslate.
  ///
  /// In fr, this message translates to:
  /// **'Traduire'**
  String get msgTranslate;

  /// No description provided for @msgShowOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'original'**
  String get msgShowOriginal;

  /// No description provided for @msgTranslatedFrom.
  ///
  /// In fr, this message translates to:
  /// **'Traduit automatiquement'**
  String get msgTranslatedFrom;

  /// No description provided for @msgTranslateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Traduction indisponible'**
  String get msgTranslateFailed;

  /// No description provided for @msgTranslateModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle de langue à télécharger (une seule fois, en Wi-Fi)'**
  String get msgTranslateModel;

  /// No description provided for @pfWallpapers.
  ///
  /// In fr, this message translates to:
  /// **'Fonds animés'**
  String get pfWallpapers;

  /// No description provided for @pfWallpapersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Huit fonds multicolores qui vivent derrière vos discussions, et tournent à chaque message envoyé.'**
  String get pfWallpapersDesc;

  /// No description provided for @pfFormatting.
  ///
  /// In fr, this message translates to:
  /// **'Mise en forme'**
  String get pfFormatting;

  /// No description provided for @pfFormattingDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gras, italique, barré, code et spoilers, directement dans vos messages.'**
  String get pfFormattingDesc;

  /// No description provided for @pfTranscription.
  ///
  /// In fr, this message translates to:
  /// **'Vocaux en texte'**
  String get pfTranscription;

  /// No description provided for @pfTranscriptionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Lisez un message vocal quand vous ne pouvez pas l\'écouter. La reconnaissance se fait sur votre téléphone.'**
  String get pfTranscriptionDesc;

  /// No description provided for @pfTranslation.
  ///
  /// In fr, this message translates to:
  /// **'Traduction'**
  String get pfTranslation;

  /// No description provided for @pfTranslationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Traduisez un message reçu sans que son contenu quitte l\'appareil.'**
  String get pfTranslationDesc;

  /// No description provided for @pfAppIcons.
  ///
  /// In fr, this message translates to:
  /// **'Icônes de l\'app'**
  String get pfAppIcons;

  /// No description provided for @pfAppIconsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Changez l\'icône de Droplet sur votre écran d\'accueil.'**
  String get pfAppIconsDesc;

  /// No description provided for @pfBadge.
  ///
  /// In fr, this message translates to:
  /// **'Badge et reconnaissance'**
  String get pfBadge;

  /// No description provided for @pfBadgeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un badge à côté de votre nom, et le soutien d\'un projet indépendant.'**
  String get pfBadgeDesc;

  /// No description provided for @pfUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris'**
  String get pfUnderstood;

  /// No description provided for @pfFeaturesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que le pack ouvre'**
  String get pfFeaturesTitle;

  /// No description provided for @chatsUnarchive.
  ///
  /// In fr, this message translates to:
  /// **'Désarchiver'**
  String get chatsUnarchive;

  /// No description provided for @chatsArchivedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archivées'**
  String get chatsArchivedTitle;

  /// No description provided for @chatsNoArchived.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation archivée'**
  String get chatsNoArchived;

  /// No description provided for @chatsLockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Discussions verrouillées'**
  String get chatsLockedTitle;

  /// No description provided for @chatsNoLocked.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation verrouillée'**
  String get chatsNoLocked;

  /// No description provided for @chatsCrashTitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet s\'est fermé de façon inattendue'**
  String get chatsCrashTitle;

  /// No description provided for @chatsCrashBody.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n\'a aucun serveur : sans votre envoi, ce défaut n\'existe pour personne. Le rapport ne contient ni messages, ni contacts, ni clés.'**
  String get chatsCrashBody;

  /// No description provided for @chatsSendReport.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le rapport'**
  String get chatsSendReport;

  /// No description provided for @chatsLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get chatsLater;

  /// No description provided for @stTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get stTitle;

  /// No description provided for @stIconHeader.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get stIconHeader;

  /// No description provided for @stIconFooter.
  ///
  /// In fr, this message translates to:
  /// **'Treize icônes au choix pour l\'écran d\'accueil.'**
  String get stIconFooter;

  /// No description provided for @stAppIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône de l\'application'**
  String get stAppIcon;

  /// No description provided for @stVariants13.
  ///
  /// In fr, this message translates to:
  /// **'13 variantes'**
  String get stVariants13;

  /// No description provided for @stNetworkHeader.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get stNetworkHeader;

  /// No description provided for @stNetworkFooter.
  ///
  /// In fr, this message translates to:
  /// **'Le relais en arrière-plan permet de transmettre les messages des autres même quand Droplet est fermé.'**
  String get stNetworkFooter;

  /// No description provided for @stRequireTor.
  ///
  /// In fr, this message translates to:
  /// **'Exiger Tor en ligne'**
  String get stRequireTor;

  /// No description provided for @stRequireTorSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sans Tor, rien ne sort vers les serveurs'**
  String get stRequireTorSubtitle;

  /// No description provided for @stRequireTorFooter.
  ///
  /// In fr, this message translates to:
  /// **'L\'annuaire et la boîte aux lettres passent par Tor dès qu\'il est actif. Sinon, Droplet s\'y connecte directement : le contenu reste chiffré de bout en bout, mais les serveurs voient votre adresse IP. Activez cette option pour l\'interdire — au prix de la messagerie en ligne quand Tor ne marche pas.'**
  String get stRequireTorFooter;

  /// No description provided for @stMeshNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau mesh'**
  String get stMeshNetwork;

  /// No description provided for @stPeersTopology.
  ///
  /// In fr, this message translates to:
  /// **'Pairs connectés et topologie'**
  String get stPeersTopology;

  /// No description provided for @stOfflineMaps.
  ///
  /// In fr, this message translates to:
  /// **'Cartes hors connexion'**
  String get stOfflineMaps;

  /// No description provided for @stZonesImport.
  ///
  /// In fr, this message translates to:
  /// **'Zones enregistrées et import de cartes'**
  String get stZonesImport;

  /// No description provided for @stSecurityHeader.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get stSecurityHeader;

  /// No description provided for @stSecurityFooter.
  ///
  /// In fr, this message translates to:
  /// **'Droplet ne conserve aucune copie de votre identité. Sans sauvegarde, elle est perdue avec l\'appareil.'**
  String get stSecurityFooter;

  /// No description provided for @stBackupIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder mon identité'**
  String get stBackupIdentity;

  /// No description provided for @stExportEncrypted.
  ///
  /// In fr, this message translates to:
  /// **'Export chiffré par mot de passe'**
  String get stExportEncrypted;

  /// No description provided for @stEmergencyMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode urgence'**
  String get stEmergencyMode;

  /// No description provided for @stSignalSafe.
  ///
  /// In fr, this message translates to:
  /// **'Signaler que vous êtes en sécurité'**
  String get stSignalSafe;

  /// No description provided for @stContributionHeader.
  ///
  /// In fr, this message translates to:
  /// **'Contribution'**
  String get stContributionHeader;

  /// No description provided for @stMyContribution.
  ///
  /// In fr, this message translates to:
  /// **'Ma contribution'**
  String get stMyContribution;

  /// No description provided for @stDropletPro.
  ///
  /// In fr, this message translates to:
  /// **'Droplet Pro'**
  String get stDropletPro;

  /// No description provided for @stProActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get stProActive;

  /// No description provided for @stProPackUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Pack débloqué'**
  String get stProPackUnlocked;

  /// No description provided for @stProIconsThemes.
  ///
  /// In fr, this message translates to:
  /// **'Icônes et fonds'**
  String get stProIconsThemes;

  /// No description provided for @stCrashLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal des erreurs'**
  String get stCrashLog;

  /// No description provided for @stAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos de Droplet'**
  String get stAbout;

  /// No description provided for @stBackgroundRelay.
  ///
  /// In fr, this message translates to:
  /// **'Relais en arrière-plan'**
  String get stBackgroundRelay;

  /// No description provided for @stActiveClosed.
  ///
  /// In fr, this message translates to:
  /// **'Actif même app fermée'**
  String get stActiveClosed;

  /// No description provided for @stActiveOpenOnly.
  ///
  /// In fr, this message translates to:
  /// **'Actif seulement app ouverte'**
  String get stActiveOpenOnly;

  /// No description provided for @stBatteryOptim.
  ///
  /// In fr, this message translates to:
  /// **'Optimisation de batterie'**
  String get stBatteryOptim;

  /// No description provided for @stAndroidMayLimit.
  ///
  /// In fr, this message translates to:
  /// **'Android peut limiter le relais'**
  String get stAndroidMayLimit;

  /// No description provided for @stFix.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get stFix;

  /// No description provided for @stKeepActiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Garder Droplet actif ?'**
  String get stKeepActiveTitle;

  /// No description provided for @stKeepActiveBody.
  ///
  /// In fr, this message translates to:
  /// **'Une notification permanente indiquera que Droplet relaie le mesh, même app fermée. En échange, la batterie sera davantage sollicitée.'**
  String get stKeepActiveBody;

  /// No description provided for @stEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get stEnable;

  /// No description provided for @stCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get stCancel;

  /// No description provided for @stAboutTagline.
  ///
  /// In fr, this message translates to:
  /// **'Messagerie et appels hors ligne, sans Internet ni opérateur.'**
  String get stAboutTagline;

  /// No description provided for @stAboutDirect.
  ///
  /// In fr, this message translates to:
  /// **'Réseau direct entre appareils — aucun serveur'**
  String get stAboutDirect;

  /// No description provided for @stAboutE2E.
  ///
  /// In fr, this message translates to:
  /// **'Chiffrement de bout en bout sur tous les messages'**
  String get stAboutE2E;

  /// No description provided for @stAboutNoThirdParty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée transmise à un tiers'**
  String get stAboutNoThirdParty;

  /// No description provided for @stAttributionEmoji.
  ///
  /// In fr, this message translates to:
  /// **'Emojis animés : Noto Animated Emoji © Google, sous licence CC BY 4.0.'**
  String get stAttributionEmoji;

  /// No description provided for @stAttributionGemma.
  ///
  /// In fr, this message translates to:
  /// **'Assistant : Gemma 3 1B-IT © Google, quantifié (int4) par litert-community et republié par Droplet, sous les conditions d\'utilisation Gemma (ai.google.dev/gemma/terms).'**
  String get stAttributionGemma;

  /// No description provided for @stChatBgHeader.
  ///
  /// In fr, this message translates to:
  /// **'Fond de discussion'**
  String get stChatBgHeader;

  /// No description provided for @stChatPatterns.
  ///
  /// In fr, this message translates to:
  /// **'Motifs Droplet'**
  String get stChatPatterns;

  /// No description provided for @stChatPatternsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Petits dessins au trait par-dessus le fond'**
  String get stChatPatternsSubtitle;

  /// No description provided for @stChatBgFooter.
  ///
  /// In fr, this message translates to:
  /// **'Le dégradé avance d\'un cran à chaque message envoyé. Choisissez « Aucun » pour un fond uni : rien n\'est alors calculé, ce qui ménage la batterie.'**
  String get stChatBgFooter;

  /// No description provided for @stBgFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuits'**
  String get stBgFree;

  /// No description provided for @stBgPremium.
  ///
  /// In fr, this message translates to:
  /// **'Premium · animés'**
  String get stBgPremium;

  /// No description provided for @stBgNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get stBgNone;

  /// No description provided for @stBgDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get stBgDefault;

  /// No description provided for @stBgThisChat.
  ///
  /// In fr, this message translates to:
  /// **'Fond de cette discussion'**
  String get stBgThisChat;

  /// No description provided for @stTextSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get stTextSize;

  /// No description provided for @stBubbleCorners.
  ///
  /// In fr, this message translates to:
  /// **'Arrondi des bulles'**
  String get stBubbleCorners;

  /// No description provided for @stAccentHeader.
  ///
  /// In fr, this message translates to:
  /// **'Couleur d\'accent'**
  String get stAccentHeader;

  /// No description provided for @stAccentFooter.
  ///
  /// In fr, this message translates to:
  /// **'Elle colore vos bulles, les boutons et les liens, dans toute l\'application.'**
  String get stAccentFooter;

  /// No description provided for @stChatListHeader.
  ///
  /// In fr, this message translates to:
  /// **'Liste des discussions'**
  String get stChatListHeader;

  /// No description provided for @stChatListTwoLines.
  ///
  /// In fr, this message translates to:
  /// **'Deux lignes'**
  String get stChatListTwoLines;

  /// No description provided for @stChatListThreeLines.
  ///
  /// In fr, this message translates to:
  /// **'Trois lignes'**
  String get stChatListThreeLines;

  /// No description provided for @stResetAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser l\'apparence'**
  String get stResetAppearance;

  /// No description provided for @stPreviewIncoming.
  ///
  /// In fr, this message translates to:
  /// **'On se voit ce soir ?'**
  String get stPreviewIncoming;

  /// No description provided for @stPreviewOutgoing.
  ///
  /// In fr, this message translates to:
  /// **'Oui, avec plaisir !'**
  String get stPreviewOutgoing;

  /// No description provided for @stAppearanceRow.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get stAppearanceRow;

  /// No description provided for @stAppearanceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème, couleur, taille du texte, fonds'**
  String get stAppearanceSubtitle;

  /// No description provided for @stBgApply.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce fond'**
  String get stBgApply;

  /// No description provided for @stBgUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer avec Premium'**
  String get stBgUnlock;

  /// No description provided for @stBgApplied.
  ///
  /// In fr, this message translates to:
  /// **'Fond appliqué'**
  String get stBgApplied;

  /// No description provided for @stBgPreviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Le fond s\'anime et ses couleurs tournent à chaque message envoyé.'**
  String get stBgPreviewHint;

  /// No description provided for @stBgPreviewIncoming.
  ///
  /// In fr, this message translates to:
  /// **'Tu as vu le nouveau fond ?'**
  String get stBgPreviewIncoming;

  /// No description provided for @stBgPreviewOutgoing.
  ///
  /// In fr, this message translates to:
  /// **'Oui, il est magnifique ✨'**
  String get stBgPreviewOutgoing;

  /// No description provided for @stSoundHeader.
  ///
  /// In fr, this message translates to:
  /// **'Sons'**
  String get stSoundHeader;

  /// No description provided for @stSoundToggle.
  ///
  /// In fr, this message translates to:
  /// **'Sons de l\'app'**
  String get stSoundToggle;

  /// No description provided for @stSoundSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages, connexions, alertes'**
  String get stSoundSubtitle;

  /// No description provided for @stSoundFooter.
  ///
  /// In fr, this message translates to:
  /// **'Des tonalités courtes, au volume des notifications du système — silencieuses si le téléphone est en mode silencieux ou concentration.'**
  String get stSoundFooter;

  /// No description provided for @stPacksHeader.
  ///
  /// In fr, this message translates to:
  /// **'Assistant — fiches hors ligne'**
  String get stPacksHeader;

  /// No description provided for @stPacksToggle.
  ///
  /// In fr, this message translates to:
  /// **'Fiches de secours et d\'urgence'**
  String get stPacksToggle;

  /// No description provided for @stPacksSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant s\'appuie dessus pour les premiers secours et les situations d\'urgence.'**
  String get stPacksSubtitle;

  /// No description provided for @stPacksFooter.
  ///
  /// In fr, this message translates to:
  /// **'Des fiches de référence intégrées (premiers secours, séisme, inondation, eau potable…). Quand la question s\'y rapporte, l\'assistant cite la fiche au lieu d\'approximer. Elles ne remplacent ni une formation ni un appel aux secours.'**
  String get stPacksFooter;

  /// No description provided for @stPrivateModeHeader.
  ///
  /// In fr, this message translates to:
  /// **'Mode privé'**
  String get stPrivateModeHeader;

  /// No description provided for @stTorFooter.
  ///
  /// In fr, this message translates to:
  /// **'Tor protège votre adresse IP et vos conversations en les faisant passer par le réseau Tor. Le mesh local (BLE/WiFi) continue de fonctionner normalement.'**
  String get stTorFooter;

  /// No description provided for @stTorActiveAnon.
  ///
  /// In fr, this message translates to:
  /// **'Actif — vos données sont anonymisées'**
  String get stTorActiveAnon;

  /// No description provided for @stTorConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours…'**
  String get stTorConnecting;

  /// No description provided for @stTorDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Mode privé désactivé'**
  String get stTorDisabled;

  /// No description provided for @callsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appels'**
  String get callsTitle;

  /// No description provided for @callsMissedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{} one{{count} appel manqué} other{{count} appels manqués}}'**
  String callsMissedCount(num count);

  /// No description provided for @callsNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel appel'**
  String get callsNew;

  /// No description provided for @callsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get callsAll;

  /// No description provided for @callsMissed.
  ///
  /// In fr, this message translates to:
  /// **'Manqués'**
  String get callsMissed;

  /// No description provided for @callsNoneMissed.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appel manqué'**
  String get callsNoneMissed;

  /// No description provided for @callsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appel'**
  String get callsNone;

  /// No description provided for @callsMissedEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les appels auxquels vous n\'avez pas répondu apparaîtront ici.'**
  String get callsMissedEmptyBody;

  /// No description provided for @callsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les appels passent par le réseau local, sans opérateur ni forfait. Votre historique apparaîtra ici.'**
  String get callsEmptyBody;

  /// No description provided for @callsRetained200.
  ///
  /// In fr, this message translates to:
  /// **'Les 200 derniers appels sont conservés sur cet appareil uniquement.'**
  String get callsRetained200;

  /// No description provided for @callsIncoming.
  ///
  /// In fr, this message translates to:
  /// **'Entrant'**
  String get callsIncoming;

  /// No description provided for @callsOutgoing.
  ///
  /// In fr, this message translates to:
  /// **'Sortant'**
  String get callsOutgoing;

  /// No description provided for @callsMissedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Manqué'**
  String get callsMissedLabel;

  /// No description provided for @callsNoAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Sans réponse'**
  String get callsNoAnswer;

  /// No description provided for @callsConnectionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion'**
  String get callsConnectionFailed;

  /// No description provided for @callsYesterday.
  ///
  /// In fr, this message translates to:
  /// **'hier'**
  String get callsYesterday;

  /// No description provided for @callsMinSec.
  ///
  /// In fr, this message translates to:
  /// **'{m} min {s} s'**
  String callsMinSec(Object m, Object s);

  /// No description provided for @callsSecOnly.
  ///
  /// In fr, this message translates to:
  /// **'{s} s'**
  String callsSecOnly(Object s);

  /// No description provided for @peersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pairs'**
  String get peersTitle;

  /// No description provided for @peersSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en cours…'**
  String get peersSearching;

  /// No description provided for @peersDevicesInRange.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{} one{{count} appareil à portée} other{{count} appareils à portée}}'**
  String peersDevicesInRange(num count);

  /// No description provided for @peersNetworkMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte du réseau'**
  String get peersNetworkMap;

  /// No description provided for @peersNoneInRange.
  ///
  /// In fr, this message translates to:
  /// **'Personne à portée'**
  String get peersNoneInRange;

  /// No description provided for @peersNoneInRangeBody.
  ///
  /// In fr, this message translates to:
  /// **'Droplet cherche en permanence les appareils proches. Rapprochez-vous de quelqu\'un qui a l\'app pour établir la première liaison.'**
  String get peersNoneInRangeBody;

  /// No description provided for @peersDirectRange.
  ///
  /// In fr, this message translates to:
  /// **'À portée directe'**
  String get peersDirectRange;

  /// No description provided for @peersDirectRangeFooter.
  ///
  /// In fr, this message translates to:
  /// **'Ces appareils sont joignables sans passer par personne d\'autre.'**
  String get peersDirectRangeFooter;

  /// No description provided for @peersRelayed.
  ///
  /// In fr, this message translates to:
  /// **'Par relais'**
  String get peersRelayed;

  /// No description provided for @peersRelayedFooter.
  ///
  /// In fr, this message translates to:
  /// **'Ces appareils sont hors de portée directe : les messages leur parviennent en passant par d\'autres téléphones.'**
  String get peersRelayedFooter;

  /// No description provided for @peersRelay.
  ///
  /// In fr, this message translates to:
  /// **'Relais'**
  String get peersRelay;

  /// No description provided for @peersCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get peersCall;

  /// No description provided for @peersTooSlow.
  ///
  /// In fr, this message translates to:
  /// **'Trop lent pour la voix — rapprochez-vous'**
  String get peersTooSlow;

  /// No description provided for @peersWifi.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi'**
  String get peersWifi;

  /// No description provided for @peersWifiDirect.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi Direct'**
  String get peersWifiDirect;

  /// No description provided for @peersBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get peersBluetooth;

  /// No description provided for @peersUnknownLink.
  ///
  /// In fr, this message translates to:
  /// **'Liaison inconnue'**
  String get peersUnknownLink;

  /// No description provided for @peersDirect.
  ///
  /// In fr, this message translates to:
  /// **'direct'**
  String get peersDirect;

  /// No description provided for @peersHops.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{direct} one{{count} relais} other{{count} relais}}'**
  String peersHops(num count);

  /// No description provided for @svExpired.
  ///
  /// In fr, this message translates to:
  /// **'Ce statut a expiré'**
  String get svExpired;

  /// No description provided for @svReceiving.
  ///
  /// In fr, this message translates to:
  /// **'Réception en cours…'**
  String get svReceiving;

  /// No description provided for @svReceivingBody.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier arrive par le réseau local'**
  String get svReceivingBody;

  /// No description provided for @svProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Progression du statut'**
  String get svProgressLabel;

  /// No description provided for @svReplyHint.
  ///
  /// In fr, this message translates to:
  /// **'Répondre…'**
  String get svReplyHint;

  /// No description provided for @svSendReply.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la réponse'**
  String get svSendReply;

  /// No description provided for @svYourStatus.
  ///
  /// In fr, this message translates to:
  /// **'Votre statut'**
  String get svYourStatus;

  /// No description provided for @svNoViewsYet.
  ///
  /// In fr, this message translates to:
  /// **'Personne n\'a encore vu ce statut.\nIl continuera de circuler tant que vous croiserez des appareils.'**
  String get svNoViewsYet;

  /// No description provided for @svJustNow.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get svJustNow;

  /// No description provided for @svMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{il y a {count} min} other{il y a {count} min}}'**
  String svMinutesAgo(num count);

  /// No description provided for @svHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{il y a {count} h} other{il y a {count} h}}'**
  String svHoursAgo(num count);

  /// No description provided for @svDefaultMusicTitle.
  ///
  /// In fr, this message translates to:
  /// **'Musique'**
  String get svDefaultMusicTitle;

  /// No description provided for @svViewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} vue} other{{count} vues}}'**
  String svViewsCount(num count);

  /// No description provided for @svLikesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} j\'aime} other{{count} j\'aime}}'**
  String svLikesCount(num count);

  /// No description provided for @svRepliesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} réponse} other{{count} réponses}}'**
  String svRepliesCount(num count);

  /// No description provided for @cpFilterOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Original'**
  String get cpFilterOriginal;

  /// No description provided for @cpFilterDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get cpFilterDark;

  /// No description provided for @cpFilterBright.
  ///
  /// In fr, this message translates to:
  /// **'Lumineux'**
  String get cpFilterBright;

  /// No description provided for @cpFilterVintage.
  ///
  /// In fr, this message translates to:
  /// **'Vintage'**
  String get cpFilterVintage;

  /// No description provided for @cpWriteStatusHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez un statut'**
  String get cpWriteStatusHint;

  /// No description provided for @cpPreparingVideo.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de la vidéo…'**
  String get cpPreparingVideo;

  /// No description provided for @cpLoadingEllipsis.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get cpLoadingEllipsis;

  /// No description provided for @cpEndsIn.
  ///
  /// In fr, this message translates to:
  /// **'Fin dans {s} s'**
  String cpEndsIn(Object s);

  /// No description provided for @cpModeVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get cpModeVideo;

  /// No description provided for @cpModePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get cpModePhoto;

  /// No description provided for @cpModeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get cpModeMessage;

  /// No description provided for @cpModeVoice.
  ///
  /// In fr, this message translates to:
  /// **'Vocal'**
  String get cpModeVoice;

  /// No description provided for @gcChooseName.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un nom pour le groupe'**
  String get gcChooseName;

  /// No description provided for @gcSelectOneMember.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne au moins un membre'**
  String get gcSelectOneMember;

  /// No description provided for @gcCreationFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la création du groupe'**
  String get gcCreationFailed;

  /// No description provided for @gcNewGroup.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get gcNewGroup;

  /// No description provided for @gcGroupName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get gcGroupName;

  /// No description provided for @gcNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Équipe terrain'**
  String get gcNameHint;

  /// No description provided for @gcMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get gcMembers;

  /// No description provided for @gcSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} sélectionné} other{{count} sélectionnés}}'**
  String gcSelectedCount(num count);

  /// No description provided for @gcNoOneInRange.
  ///
  /// In fr, this message translates to:
  /// **'Personne à portée'**
  String get gcNoOneInRange;

  /// No description provided for @gcGetCloserBody.
  ///
  /// In fr, this message translates to:
  /// **'Rapproche-toi d\'un autre appareil Droplet : les pairs apparaissent ici automatiquement.'**
  String get gcGetCloserBody;

  /// No description provided for @gcCreateGroup.
  ///
  /// In fr, this message translates to:
  /// **'Créer le groupe'**
  String get gcCreateGroup;

  /// No description provided for @gcConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get gcConnected;

  /// No description provided for @gcAlreadyMet.
  ///
  /// In fr, this message translates to:
  /// **'Déjà rencontré'**
  String get gcAlreadyMet;

  /// No description provided for @giRenameGroup.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le groupe'**
  String get giRenameGroup;

  /// No description provided for @giRenameFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec du renommage'**
  String get giRenameFailed;

  /// No description provided for @giNoPeerToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Aucun pair disponible à ajouter'**
  String get giNoPeerToAdd;

  /// No description provided for @giAddMemberHeader.
  ///
  /// In fr, this message translates to:
  /// **'AJOUTER UN MEMBRE'**
  String get giAddMemberHeader;

  /// No description provided for @giAddMemberFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'ajout du membre'**
  String get giAddMemberFailed;

  /// No description provided for @giRemoveMemberTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce membre ?'**
  String get giRemoveMemberTitle;

  /// No description provided for @giRemoveMemberBody.
  ///
  /// In fr, this message translates to:
  /// **'Il ne pourra plus lire les messages envoyés après son retrait.'**
  String get giRemoveMemberBody;

  /// No description provided for @giRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get giRemove;

  /// No description provided for @giRemoveMemberFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec du retrait du membre'**
  String get giRemoveMemberFailed;

  /// No description provided for @giLeaveGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe ?'**
  String get giLeaveGroupTitle;

  /// No description provided for @giLeaveGroupBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne recevrez plus les messages envoyés après votre départ.'**
  String get giLeaveGroupBody;

  /// No description provided for @giLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get giLeave;

  /// No description provided for @giNoOneReachable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre joignable en Wi-Fi local pour le moment'**
  String get giNoOneReachable;

  /// No description provided for @giMax4Participants.
  ///
  /// In fr, this message translates to:
  /// **'Maximum 4 participants par appel de groupe — seuls les 3 premiers joignables seront appelés'**
  String get giMax4Participants;

  /// No description provided for @giGroupNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Groupe introuvable'**
  String get giGroupNotFound;

  /// No description provided for @giGroupInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos du groupe'**
  String get giGroupInfo;

  /// No description provided for @giGroupCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel de groupe'**
  String get giGroupCall;

  /// No description provided for @giMemberCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} membre} other{{count} membres}}'**
  String giMemberCount(num count);

  /// No description provided for @giEncryptedMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages de groupe chiffrés'**
  String get giEncryptedMessages;

  /// No description provided for @giAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get giAdd;

  /// No description provided for @giMe.
  ///
  /// In fr, this message translates to:
  /// **'moi'**
  String get giMe;

  /// No description provided for @giAdministrator.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get giAdministrator;

  /// No description provided for @giLeaveGroup.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get giLeaveGroup;

  /// No description provided for @sfNoLocationShared.
  ///
  /// In fr, this message translates to:
  /// **'Position non partagée'**
  String get sfNoLocationShared;

  /// No description provided for @sfLocationShared.
  ///
  /// In fr, this message translates to:
  /// **'Position partagée'**
  String get sfLocationShared;

  /// No description provided for @sfDistanceMeters.
  ///
  /// In fr, this message translates to:
  /// **'à {m} m'**
  String sfDistanceMeters(Object m);

  /// No description provided for @sfDistanceKm.
  ///
  /// In fr, this message translates to:
  /// **'à {km} km'**
  String sfDistanceKm(Object km);

  /// No description provided for @sfBearingN.
  ///
  /// In fr, this message translates to:
  /// **'au nord'**
  String get sfBearingN;

  /// No description provided for @sfBearingNE.
  ///
  /// In fr, this message translates to:
  /// **'au nord-est'**
  String get sfBearingNE;

  /// No description provided for @sfBearingE.
  ///
  /// In fr, this message translates to:
  /// **'à l\'est'**
  String get sfBearingE;

  /// No description provided for @sfBearingSE.
  ///
  /// In fr, this message translates to:
  /// **'au sud-est'**
  String get sfBearingSE;

  /// No description provided for @sfBearingS.
  ///
  /// In fr, this message translates to:
  /// **'au sud'**
  String get sfBearingS;

  /// No description provided for @sfBearingSW.
  ///
  /// In fr, this message translates to:
  /// **'au sud-ouest'**
  String get sfBearingSW;

  /// No description provided for @sfBearingW.
  ///
  /// In fr, this message translates to:
  /// **'à l\'ouest'**
  String get sfBearingW;

  /// No description provided for @sfBearingNW.
  ///
  /// In fr, this message translates to:
  /// **'au nord-ouest'**
  String get sfBearingNW;

  /// No description provided for @sfBroadcastSafeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser « Je suis en sécurité » ?'**
  String get sfBroadcastSafeTitle;

  /// No description provided for @sfBroadcastSafeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce statut sera visible par tout le mesh à portée, pas seulement tes contacts. Tu peux inclure une position approximative (arrondie, jamais exacte).'**
  String get sfBroadcastSafeMessage;

  /// No description provided for @sfWithLocation.
  ///
  /// In fr, this message translates to:
  /// **'Avec position approx.'**
  String get sfWithLocation;

  /// No description provided for @sfWithoutLocation.
  ///
  /// In fr, this message translates to:
  /// **'Sans position'**
  String get sfWithoutLocation;

  /// No description provided for @sfStatusBroadcast.
  ///
  /// In fr, this message translates to:
  /// **'Statut diffusé au mesh'**
  String get sfStatusBroadcast;

  /// No description provided for @sfBroadcastFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la diffusion'**
  String get sfBroadcastFailed;

  /// No description provided for @sfHelpRequestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser « J\'ai besoin d\'aide » ?'**
  String get sfHelpRequestTitle;

  /// No description provided for @sfHelpRequestMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce statut signalera aux pairs à portée que tu as besoin d\'assistance. Tu peux inclure une position approximative.'**
  String get sfHelpRequestMessage;

  /// No description provided for @sfHelpRequestBroadcast.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'aide diffusée au mesh'**
  String get sfHelpRequestBroadcast;

  /// No description provided for @sfDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{il y a {count} j} other{il y a {count} j}}'**
  String sfDaysAgo(num count);

  /// No description provided for @sfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode urgence'**
  String get sfTitle;

  /// No description provided for @sfViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get sfViewOnMap;

  /// No description provided for @sfNeedHelp.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai besoin d\'aide'**
  String get sfNeedHelp;

  /// No description provided for @sfCheckinsReceived.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, other{Check-in reçus ({count})}}'**
  String sfCheckinsReceived(num count);

  /// No description provided for @sfNoCheckinsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun check-in reçu pour le moment'**
  String get sfNoCheckinsYet;

  /// No description provided for @sfCheckinsAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les statuts « en sécurité » diffusés par les pairs à portée apparaîtront ici.'**
  String get sfCheckinsAppearHere;

  /// No description provided for @sfSafeLabel.
  ///
  /// In fr, this message translates to:
  /// **'En sécurité'**
  String get sfSafeLabel;

  /// No description provided for @sfSafeStatusWithLocation.
  ///
  /// In fr, this message translates to:
  /// **'En sécurité · {time} · {location}'**
  String sfSafeStatusWithLocation(Object location, Object time);

  /// No description provided for @sfSafeStatusNoLocation.
  ///
  /// In fr, this message translates to:
  /// **'En sécurité · {time}'**
  String sfSafeStatusNoLocation(Object time);

  /// No description provided for @sfBroadcastSemanticsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser mon statut de sécurité au réseau mesh'**
  String get sfBroadcastSemanticsLabel;

  /// No description provided for @sfImSafe.
  ///
  /// In fr, this message translates to:
  /// **'Je suis en sécurité'**
  String get sfImSafe;

  /// No description provided for @emSosActive.
  ///
  /// In fr, this message translates to:
  /// **'SOS ACTIF'**
  String get emSosActive;

  /// No description provided for @emSos.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get emSos;

  /// No description provided for @emSosActiveDescription.
  ///
  /// In fr, this message translates to:
  /// **'Signal SOS actif — diffusé à tous les appareils à proximité'**
  String get emSosActiveDescription;

  /// No description provided for @emPullToSendSignal.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour envoyer un signal d\'urgence'**
  String get emPullToSendSignal;

  /// No description provided for @emSignalRelayedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le signal est relayé de pair en pair\nsur tout le réseau mesh.'**
  String get emSignalRelayedDescription;

  /// No description provided for @emBroadcasting.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion...'**
  String get emBroadcasting;

  /// No description provided for @emSharePosition.
  ///
  /// In fr, this message translates to:
  /// **'Partager ma position'**
  String get emSharePosition;

  /// No description provided for @emSosActivated.
  ///
  /// In fr, this message translates to:
  /// **'Signal SOS activé'**
  String get emSosActivated;

  /// No description provided for @emSafeStatusMessage.
  ///
  /// In fr, this message translates to:
  /// **'🟢 Je suis en sécurité'**
  String get emSafeStatusMessage;

  /// No description provided for @emSafetyStatusBroadcast.
  ///
  /// In fr, this message translates to:
  /// **'Statut de sécurité diffusé'**
  String get emSafetyStatusBroadcast;

  /// No description provided for @pmEnterPayingNumber.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le numéro qui va payer (9 chiffres).'**
  String get pmEnterPayingNumber;

  /// No description provided for @pmRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée…'**
  String get pmRequestSent;

  /// No description provided for @pmPaymentLaunchFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement n\'a pas pu être lancé. Vérifiez le numéro et votre connexion, ou payez à la main plus bas.'**
  String get pmPaymentLaunchFailed;

  /// No description provided for @pmValidateOnPhone.
  ///
  /// In fr, this message translates to:
  /// **'Validez sur votre téléphone : composez votre code Mobile Money quand l\'invite s\'affiche.'**
  String get pmValidateOnPhone;

  /// No description provided for @pmPaymentNotConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Paiement non confirmé. Rien n\'a été débloqué.'**
  String get pmPaymentNotConfirmed;

  /// No description provided for @pmInvalidLicenseReceived.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement est passé mais la licence reçue est invalide. Écrivez-nous, elle sera refaite : {contact}'**
  String pmInvalidLicenseReceived(Object contact);

  /// No description provided for @pmProActivated.
  ///
  /// In fr, this message translates to:
  /// **'Droplet Pro activé'**
  String get pmProActivated;

  /// No description provided for @pmPackUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Pack débloqué'**
  String get pmPackUnlocked;

  /// No description provided for @pmInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Ce code n\'est pas valable sur cet appareil. Vérifiez que vous avez bien envoyé le code d\'appareil affiché ci-dessus.'**
  String get pmInvalidCode;

  /// No description provided for @pmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet Pro'**
  String get pmTitle;

  /// No description provided for @pmNeverAskTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que Droplet\nne demandera jamais'**
  String get pmNeverAskTitle;

  /// No description provided for @pmNeverAskBody.
  ///
  /// In fr, this message translates to:
  /// **'Ni publicité, ni abonnement obligatoire, ni revente de vos données — il n\'y a même pas de serveur pour les recueillir. Le pack et Pro financent le reste.'**
  String get pmNeverAskBody;

  /// No description provided for @pmCommunitySemantics.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez la communauté de plus de 1200 membres actifs'**
  String get pmCommunitySemantics;

  /// No description provided for @pmCommunityText.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez 1 200+ membres sur le mesh'**
  String get pmCommunityText;

  /// No description provided for @pmProPreviewSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu des fonctionnalités Pro débloquées'**
  String get pmProPreviewSemantics;

  /// No description provided for @pmAnimatedEmojis.
  ///
  /// In fr, this message translates to:
  /// **'Emojis\nanimés'**
  String get pmAnimatedEmojis;

  /// No description provided for @pmWallpapers.
  ///
  /// In fr, this message translates to:
  /// **'Fonds\nd\'écran'**
  String get pmWallpapers;

  /// No description provided for @pmAppIcons.
  ///
  /// In fr, this message translates to:
  /// **'Icônes\nd\'app'**
  String get pmAppIcons;

  /// No description provided for @pmOnceForLife.
  ///
  /// In fr, this message translates to:
  /// **'une fois, à vie'**
  String get pmOnceForLife;

  /// No description provided for @pmProAdvantage1.
  ///
  /// In fr, this message translates to:
  /// **'Les dix icônes et les huit fonds du pack'**
  String get pmProAdvantage1;

  /// No description provided for @pmProAdvantage2.
  ///
  /// In fr, this message translates to:
  /// **'Le badge Pro à côté de votre nom'**
  String get pmProAdvantage2;

  /// No description provided for @pmProAdvantage3.
  ///
  /// In fr, this message translates to:
  /// **'Les fonctions à venir, sans supplément'**
  String get pmProAdvantage3;

  /// No description provided for @pmPackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le pack'**
  String get pmPackTitle;

  /// No description provided for @pmOnce.
  ///
  /// In fr, this message translates to:
  /// **'une fois'**
  String get pmOnce;

  /// No description provided for @pmPackAdvantage1.
  ///
  /// In fr, this message translates to:
  /// **'Dix icônes d\'application supplémentaires'**
  String get pmPackAdvantage1;

  /// No description provided for @pmPackAdvantage2.
  ///
  /// In fr, this message translates to:
  /// **'Huit fonds de discussion'**
  String get pmPackAdvantage2;

  /// No description provided for @pmPayByHand.
  ///
  /// In fr, this message translates to:
  /// **'Ou payer à la main'**
  String get pmPayByHand;

  /// No description provided for @pmHowTo.
  ///
  /// In fr, this message translates to:
  /// **'Comment faire'**
  String get pmHowTo;

  /// No description provided for @pmIfPromptDoesNotArrive.
  ///
  /// In fr, this message translates to:
  /// **'Si l\'invite n\'arrive pas sur votre téléphone, ou si vous préférez envoyer l\'argent vous-même.'**
  String get pmIfPromptDoesNotArrive;

  /// No description provided for @pmStep1Title.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez {montant} F'**
  String pmStep1Title(Object montant);

  /// No description provided for @pmStep1Body.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre opérateur : son menu s\'ouvre, et le numéro reste affiché ici pendant que vous le parcourez.'**
  String get pmStep1Body;

  /// No description provided for @pmStep2Title.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez votre code d\'appareil'**
  String get pmStep2Title;

  /// No description provided for @pmStep2Body.
  ///
  /// In fr, this message translates to:
  /// **'Avec la capture du paiement. Sans ce code, la licence ne peut pas être fabriquée — elle ne vaut que pour votre téléphone.'**
  String get pmStep2Body;

  /// No description provided for @pmStep3Title.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevez une licence'**
  String get pmStep3Title;

  /// No description provided for @pmStep3Body.
  ///
  /// In fr, this message translates to:
  /// **'Une longue ligne commençant par DROP1. Collez-la ci-dessous : le déblocage est immédiat et fonctionne hors connexion, pour toujours.'**
  String get pmStep3Body;

  /// No description provided for @pmPayNow.
  ///
  /// In fr, this message translates to:
  /// **'Payer maintenant'**
  String get pmPayNow;

  /// No description provided for @pmPayNowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'MTN Mobile Money ou Orange Money, depuis ce téléphone ou un autre.'**
  String get pmPayNowSubtitle;

  /// No description provided for @pmPhoneNumberSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone pour le paiement Mobile Money'**
  String get pmPhoneNumberSemantics;

  /// No description provided for @pmWaitingForCode.
  ///
  /// In fr, this message translates to:
  /// **'En attente de votre code…'**
  String get pmWaitingForCode;

  /// No description provided for @pmPayAmount.
  ///
  /// In fr, this message translates to:
  /// **'Payer {montant} F'**
  String pmPayAmount(Object montant);

  /// No description provided for @pmRestorePurchaseSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer un achat précédent'**
  String get pmRestorePurchaseSemantics;

  /// No description provided for @pmAlreadyPaidRestore.
  ///
  /// In fr, this message translates to:
  /// **'Déjà payé ? Restaurer'**
  String get pmAlreadyPaidRestore;

  /// No description provided for @pmDialCode.
  ///
  /// In fr, this message translates to:
  /// **'Composez {code} depuis votre téléphone'**
  String pmDialCode(Object code);

  /// No description provided for @pmChooseOperatorSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un opérateur de paiement'**
  String get pmChooseOperatorSemantics;

  /// No description provided for @pmNumberAmountFilled.
  ///
  /// In fr, this message translates to:
  /// **'Numéro et montant déjà remplis — il ne reste que votre code secret.'**
  String get pmNumberAmountFilled;

  /// No description provided for @pmOrangeMenuInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Dans le menu Orange : transfert d\'argent, puis le numéro et le montant ci-dessous.'**
  String get pmOrangeMenuInstructions;

  /// No description provided for @pmLabelNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get pmLabelNumber;

  /// No description provided for @pmLabelAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get pmLabelAmount;

  /// No description provided for @pmPayWithOperator.
  ///
  /// In fr, this message translates to:
  /// **'Payer {montant} francs avec {operator}'**
  String pmPayWithOperator(Object montant, Object operator);

  /// No description provided for @pmMenuOpen.
  ///
  /// In fr, this message translates to:
  /// **'Menu ouvert'**
  String get pmMenuOpen;

  /// No description provided for @pmWhatsAppMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, je viens de payer pour Droplet.\n\nOffre : {offer}\nMontant : {amount} F\nCode appareil : {code}\n\n(je joins la capture du paiement)'**
  String pmWhatsAppMessage(Object amount, Object code, Object offer);

  /// No description provided for @pmWhatsAppNotFound.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp introuvable — code copié. Envoyez-le au {contact}'**
  String pmWhatsAppNotFound(Object contact);

  /// No description provided for @pmPrepareRequest.
  ///
  /// In fr, this message translates to:
  /// **'Préparer ma demande'**
  String get pmPrepareRequest;

  /// No description provided for @pmReceivedLicense.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu ma licence'**
  String get pmReceivedLicense;

  /// No description provided for @pmPaste.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get pmPaste;

  /// No description provided for @pmUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get pmUnlock;

  /// No description provided for @pmProIsActive.
  ///
  /// In fr, this message translates to:
  /// **'Droplet Pro est actif'**
  String get pmProIsActive;

  /// No description provided for @pmPackIsUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Le pack est débloqué'**
  String get pmPackIsUnlocked;

  /// No description provided for @pmProActiveDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le badge Pro accompagne votre nom, et toutes les icônes et tous les fonds vous sont ouverts.'**
  String get pmProActiveDescription;

  /// No description provided for @pmPackActiveDescription.
  ///
  /// In fr, this message translates to:
  /// **'Les dix icônes et les huit fonds du pack vous sont ouverts, dans les réglages.'**
  String get pmPackActiveDescription;

  /// No description provided for @pmLicenseDeviceBound.
  ///
  /// In fr, this message translates to:
  /// **'Votre licence vaut pour ce téléphone. Si vous en changez, gardez le message qui la contient : elle sera refaite gratuitement.'**
  String get pmLicenseDeviceBound;

  /// No description provided for @torError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {e}'**
  String torError(Object e);

  /// No description provided for @torEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer Tor'**
  String get torEnable;

  /// No description provided for @torProtected.
  ///
  /// In fr, this message translates to:
  /// **'Protégé'**
  String get torProtected;

  /// No description provided for @torDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get torDisabled;

  /// No description provided for @torStateHeader.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get torStateHeader;

  /// No description provided for @torCircuit.
  ///
  /// In fr, this message translates to:
  /// **'Circuit'**
  String get torCircuit;

  /// No description provided for @torActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get torActive;

  /// No description provided for @torInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours…'**
  String get torInProgress;

  /// No description provided for @torInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get torInactive;

  /// No description provided for @torFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get torFailed;

  /// No description provided for @torReason.
  ///
  /// In fr, this message translates to:
  /// **'Raison'**
  String get torReason;

  /// No description provided for @torBannerConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Tor…'**
  String get torBannerConnecting;

  /// No description provided for @torBannerActive.
  ///
  /// In fr, this message translates to:
  /// **'Tor actif'**
  String get torBannerActive;

  /// No description provided for @torBannerError.
  ///
  /// In fr, this message translates to:
  /// **'Tor indisponible'**
  String get torBannerError;

  /// No description provided for @torBannerOff.
  ///
  /// In fr, this message translates to:
  /// **'Tor éteint'**
  String get torBannerOff;

  /// No description provided for @torEncryption.
  ///
  /// In fr, this message translates to:
  /// **'Chiffrement'**
  String get torEncryption;

  /// No description provided for @torLatency.
  ///
  /// In fr, this message translates to:
  /// **'Latence'**
  String get torLatency;

  /// No description provided for @torContactsHeader.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get torContactsHeader;

  /// No description provided for @torScanQrFooter.
  ///
  /// In fr, this message translates to:
  /// **'Scannez un QR code, ou recherchez un pseudo dans l\'annuaire, pour ajouter un contact distant.'**
  String get torScanQrFooter;

  /// No description provided for @torScanQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un QR Code'**
  String get torScanQrCode;

  /// No description provided for @torMyQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Mon QR Code'**
  String get torMyQrCode;

  /// No description provided for @torInformationHeader.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get torInformationHeader;

  /// No description provided for @torVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get torVersion;

  /// No description provided for @torHowItWorks.
  ///
  /// In fr, this message translates to:
  /// **'Comment ça marche ?'**
  String get torHowItWorks;

  /// No description provided for @torConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get torConnecting;

  /// No description provided for @torInactiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tor inactif'**
  String get torInactiveTitle;

  /// No description provided for @torDataThroughTor.
  ///
  /// In fr, this message translates to:
  /// **'Vos données passent par le réseau Tor'**
  String get torDataThroughTor;

  /// No description provided for @torEstablishingCircuit.
  ///
  /// In fr, this message translates to:
  /// **'Établissement du circuit (10-30s)'**
  String get torEstablishingCircuit;

  /// No description provided for @torActivateToProtect.
  ///
  /// In fr, this message translates to:
  /// **'Activez pour protéger votre identité'**
  String get torActivateToProtect;

  /// No description provided for @torHowItWorksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment Tor protège vos données'**
  String get torHowItWorksTitle;

  /// No description provided for @torEncryptedCircuit.
  ///
  /// In fr, this message translates to:
  /// **'Circuit chiffré'**
  String get torEncryptedCircuit;

  /// No description provided for @torEncryptedCircuitDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vos messages passent par 3 relais Tor dans le monde.'**
  String get torEncryptedCircuitDesc;

  /// No description provided for @torHiddenIp.
  ///
  /// In fr, this message translates to:
  /// **'IP masquée'**
  String get torHiddenIp;

  /// No description provided for @torHiddenIpDesc.
  ///
  /// In fr, this message translates to:
  /// **'Aucun site ne peut voir votre vraie adresse.'**
  String get torHiddenIpDesc;

  /// No description provided for @torMeshPreserved.
  ///
  /// In fr, this message translates to:
  /// **'Mesh préservé'**
  String get torMeshPreserved;

  /// No description provided for @torMeshPreservedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth et Wi-Fi local continuent de fonctionner.'**
  String get torMeshPreservedDesc;

  /// No description provided for @torUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get torUnderstood;

  /// No description provided for @qrTorNotActive.
  ///
  /// In fr, this message translates to:
  /// **'Tor n\'est pas actif. Activez-le dans Réglages > Tor.'**
  String get qrTorNotActive;

  /// No description provided for @qrScanContactCode.
  ///
  /// In fr, this message translates to:
  /// **'Scannez le QR code d\'un contact'**
  String get qrScanContactCode;

  /// No description provided for @qrCodeFromContactScreen.
  ///
  /// In fr, this message translates to:
  /// **'Le code doit provenir de l\'écran Tor de votre contact'**
  String get qrCodeFromContactScreen;

  /// No description provided for @qrScanAnother.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un autre'**
  String get qrScanAnother;

  /// No description provided for @qrChat.
  ///
  /// In fr, this message translates to:
  /// **'Discuter'**
  String get qrChat;

  /// No description provided for @qgScanToConnect.
  ///
  /// In fr, this message translates to:
  /// **'Scannez pour se connecter'**
  String get qgScanToConnect;

  /// No description provided for @qgCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié ✓'**
  String get qgCopied;

  /// No description provided for @qgCopyCode.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get qgCopyCode;

  /// No description provided for @qgHowItWorks.
  ///
  /// In fr, this message translates to:
  /// **'Comment ça marche'**
  String get qgHowItWorks;

  /// No description provided for @qgStep1.
  ///
  /// In fr, this message translates to:
  /// **'Montrez ce QR code à votre contact'**
  String get qgStep1;

  /// No description provided for @qgStep2.
  ///
  /// In fr, this message translates to:
  /// **'Il le scanne depuis son écran Tor'**
  String get qgStep2;

  /// No description provided for @qgStep3.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes connectés via Tor'**
  String get qgStep3;

  /// No description provided for @shShareTo.
  ///
  /// In fr, this message translates to:
  /// **'Partager vers…'**
  String get shShareTo;

  /// No description provided for @shSearchConversation.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une conversation'**
  String get shSearchConversation;

  /// No description provided for @shNoConversation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation'**
  String get shNoConversation;

  /// No description provided for @shOpenChatFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez d\'abord une discussion dans Droplet pour pouvoir y partager du contenu.'**
  String get shOpenChatFirst;

  /// No description provided for @shGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get shGroup;

  /// No description provided for @shDiscussion.
  ///
  /// In fr, this message translates to:
  /// **'Discussion'**
  String get shDiscussion;

  /// No description provided for @shItemsToShare.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} élément à partager} other{{count} éléments à partager}}'**
  String shItemsToShare(num count);

  /// No description provided for @omMapInstalled.
  ///
  /// In fr, this message translates to:
  /// **'Carte installée'**
  String get omMapInstalled;

  /// No description provided for @omClearCacheTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache ?'**
  String get omClearCacheTitle;

  /// No description provided for @omRemoveZoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette zone ?'**
  String get omRemoveZoneTitle;

  /// No description provided for @omClearCacheMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les zones que vous avez parcourues ne seront plus disponibles hors connexion. Elles se reconstitueront en les consultant à nouveau avec du réseau.'**
  String get omClearCacheMessage;

  /// No description provided for @omRemoveZoneMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » sera supprimée de cet appareil.'**
  String omRemoveZoneMessage(Object name);

  /// No description provided for @omClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get omClear;

  /// No description provided for @omTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get omTitle;

  /// No description provided for @omReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture…'**
  String get omReading;

  /// No description provided for @omNoMapsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Aucune carte enregistrée'**
  String get omNoMapsSaved;

  /// No description provided for @omSizeOnDevice.
  ///
  /// In fr, this message translates to:
  /// **'{size} sur cet appareil'**
  String omSizeOnDevice(Object size);

  /// No description provided for @omBrowseMapHint.
  ///
  /// In fr, this message translates to:
  /// **'Parcourez la carte avec du réseau : les zones que vous regardez restent disponibles hors connexion.'**
  String get omBrowseMapHint;

  /// No description provided for @omOnThisDevice.
  ///
  /// In fr, this message translates to:
  /// **'Sur cet appareil'**
  String get omOnThisDevice;

  /// No description provided for @omZonesFillThemselves.
  ///
  /// In fr, this message translates to:
  /// **'Les zones consultées se remplissent toutes seules pendant que vous parcourez la carte avec du réseau.'**
  String get omZonesFillThemselves;

  /// No description provided for @omMbtilesExplainer.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier .mbtiles contient une région entière, préparée à l\'avance. C\'est le format standard des cartes hors connexion : n\'importe quel outil cartographique sait en produire.'**
  String get omMbtilesExplainer;

  /// No description provided for @omImportMap.
  ///
  /// In fr, this message translates to:
  /// **'Importer une carte'**
  String get omImportMap;

  /// No description provided for @omReadingFile.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du fichier…'**
  String get omReadingFile;

  /// No description provided for @omMbtilesFromPhone.
  ///
  /// In fr, this message translates to:
  /// **'Fichier .mbtiles depuis ce téléphone'**
  String get omMbtilesFromPhone;

  /// No description provided for @omAttributionText.
  ///
  /// In fr, this message translates to:
  /// **'Les données viennent d\'OpenStreetMap (licence ODbL), le fond de carte est servi par CARTO. Droplet ne télécharge jamais de région entière à l\'avance : aucun service gratuit ne l\'autorise. Seul ce que vous consultez est conservé.'**
  String get omAttributionText;

  /// No description provided for @omTilesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} tuile} other{{count} tuiles}}'**
  String omTilesCount(num count);

  /// No description provided for @omTilesCountK.
  ///
  /// In fr, this message translates to:
  /// **'{k} k tuiles'**
  String omTilesCountK(Object k);

  /// No description provided for @omSizeKb.
  ///
  /// In fr, this message translates to:
  /// **'{n} ko'**
  String omSizeKb(Object n);

  /// No description provided for @omSizeMb.
  ///
  /// In fr, this message translates to:
  /// **'{n} Mo'**
  String omSizeMb(Object n);

  /// No description provided for @omSizeGb.
  ///
  /// In fr, this message translates to:
  /// **'{n} Go'**
  String omSizeGb(Object n);

  /// No description provided for @nwTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actus'**
  String get nwTitle;

  /// No description provided for @nwStatusesNetwork24h.
  ///
  /// In fr, this message translates to:
  /// **'Statuts du réseau · 24 h'**
  String get nwStatusesNetwork24h;

  /// No description provided for @nwStatusesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} statut du réseau} other{{count} statuts du réseau}}'**
  String nwStatusesCount(num count);

  /// No description provided for @nwPublishStatus.
  ///
  /// In fr, this message translates to:
  /// **'Publier un statut'**
  String get nwPublishStatus;

  /// No description provided for @nwNoNewsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune actu pour le moment'**
  String get nwNoNewsYet;

  /// No description provided for @nwStatusesAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les statuts publiés par les personnes à portée apparaîtront ici, sans passer par internet.'**
  String get nwStatusesAppearHere;

  /// No description provided for @nwRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get nwRecent;

  /// No description provided for @nwStatusExpires.
  ///
  /// In fr, this message translates to:
  /// **'Un statut disparaît de lui-même 24 heures après sa publication.'**
  String get nwStatusExpires;

  /// No description provided for @nwPhoto.
  ///
  /// In fr, this message translates to:
  /// **'📷 Photo'**
  String get nwPhoto;

  /// No description provided for @nwVideo.
  ///
  /// In fr, this message translates to:
  /// **'🎥 Vidéo'**
  String get nwVideo;

  /// No description provided for @nwVoiceMessage.
  ///
  /// In fr, this message translates to:
  /// **'🎤 Message vocal'**
  String get nwVoiceMessage;

  /// No description provided for @nwMusic.
  ///
  /// In fr, this message translates to:
  /// **'🎵 Musique'**
  String get nwMusic;

  /// No description provided for @nwStatusFallback.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get nwStatusFallback;

  /// No description provided for @nwMyStatus.
  ///
  /// In fr, this message translates to:
  /// **'Mon statut'**
  String get nwMyStatus;

  /// No description provided for @nwTapToPublish.
  ///
  /// In fr, this message translates to:
  /// **'Appuyer pour publier sur le réseau'**
  String get nwTapToPublish;

  /// No description provided for @nwNotSeenYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore vu'**
  String get nwNotSeenYet;

  /// No description provided for @nwSeenByCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Vu par {count}} other{Vu par {count}}}'**
  String nwSeenByCount(num count);

  /// No description provided for @mpLocationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible — vérifiez que la localisation est activée.'**
  String get mpLocationUnavailable;

  /// No description provided for @mpDistanceMeters.
  ///
  /// In fr, this message translates to:
  /// **'{m} m'**
  String mpDistanceMeters(Object m);

  /// No description provided for @mpDistanceKm.
  ///
  /// In fr, this message translates to:
  /// **'{km} km'**
  String mpDistanceKm(Object km);

  /// No description provided for @mpDistanceFromYou.
  ///
  /// In fr, this message translates to:
  /// **'{distance} de vous'**
  String mpDistanceFromYou(Object distance);

  /// No description provided for @mpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get mpTitle;

  /// No description provided for @mpOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion'**
  String get mpOffline;

  /// No description provided for @mpOnlineMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte en ligne'**
  String get mpOnlineMap;

  /// No description provided for @mpMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get mpMyPosition;

  /// No description provided for @mpLayers.
  ///
  /// In fr, this message translates to:
  /// **'Calques'**
  String get mpLayers;

  /// No description provided for @mpOfflineToast.
  ///
  /// In fr, this message translates to:
  /// **'Carte hors connexion : seules les zones déjà enregistrées s\'afficheront.'**
  String get mpOfflineToast;

  /// No description provided for @mpOnlineToast.
  ///
  /// In fr, this message translates to:
  /// **'Carte en ligne : les zones consultées seront enregistrées pour plus tard.'**
  String get mpOnlineToast;

  /// No description provided for @mpMapLabel.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mpMapLabel;

  /// No description provided for @mpSatelliteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Satellite'**
  String get mpSatelliteLabel;

  /// No description provided for @mpSatelliteMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode satellite'**
  String get mpSatelliteMode;

  /// No description provided for @mpMapMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode carte'**
  String get mpMapMode;

  /// No description provided for @mpWrite.
  ///
  /// In fr, this message translates to:
  /// **'Écrire'**
  String get mpWrite;

  /// No description provided for @mpCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centrer'**
  String get mpCenter;

  /// No description provided for @mpNoOneOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Personne sur la carte'**
  String get mpNoOneOnMap;

  /// No description provided for @mpPositionsAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les positions apparaissent ici quand un contact les partage depuis le mode Sécurité.'**
  String get mpPositionsAppearHere;

  /// No description provided for @mpYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get mpYou;

  /// No description provided for @mnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réseau mesh'**
  String get mnTitle;

  /// No description provided for @mnPeers.
  ///
  /// In fr, this message translates to:
  /// **'Pairs'**
  String get mnPeers;

  /// No description provided for @mnAvgHops.
  ///
  /// In fr, this message translates to:
  /// **'Moy. sauts'**
  String get mnAvgHops;

  /// No description provided for @mnSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal'**
  String get mnSignal;

  /// No description provided for @mnStrong.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get mnStrong;

  /// No description provided for @mnMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get mnMedium;

  /// No description provided for @mnSearchingPeers.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de pairs à portée…'**
  String get mnSearchingPeers;

  /// No description provided for @mnPeersConnectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} pair connecté} other{{count} pairs connectés}}'**
  String mnPeersConnectedCount(num count);

  /// No description provided for @mnNoPeersYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun pair connecté pour le moment'**
  String get mnNoPeersYet;

  /// No description provided for @mnGetCloserHint.
  ///
  /// In fr, this message translates to:
  /// **'Rapproche-toi d\'un autre appareil avec Droplet installé — la découverte se fait automatiquement, sans configuration.'**
  String get mnGetCloserHint;

  /// No description provided for @mnConnectedPeersHeader.
  ///
  /// In fr, this message translates to:
  /// **'Pairs connectés'**
  String get mnConnectedPeersHeader;

  /// No description provided for @mnHopsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} saut} other{{count} sauts}}'**
  String mnHopsCount(num count);

  /// No description provided for @mnBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get mnBluetooth;

  /// No description provided for @mnWifiLocal.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi Local'**
  String get mnWifiLocal;

  /// No description provided for @mnP2pNative.
  ///
  /// In fr, this message translates to:
  /// **'P2P Natif'**
  String get mnP2pNative;

  /// No description provided for @mnActiveGateway.
  ///
  /// In fr, this message translates to:
  /// **'Passerelle active'**
  String get mnActiveGateway;

  /// No description provided for @mnPath.
  ///
  /// In fr, this message translates to:
  /// **'Chemin'**
  String get mnPath;

  /// No description provided for @mnTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get mnTransport;

  /// No description provided for @mnBattery.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get mnBattery;

  /// No description provided for @mnScore.
  ///
  /// In fr, this message translates to:
  /// **'Score'**
  String get mnScore;

  /// No description provided for @mnReconnecting.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion'**
  String get mnReconnecting;

  /// No description provided for @cnBronze.
  ///
  /// In fr, this message translates to:
  /// **'Bronze'**
  String get cnBronze;

  /// No description provided for @cnSilver.
  ///
  /// In fr, this message translates to:
  /// **'Argent'**
  String get cnSilver;

  /// No description provided for @cnGold.
  ///
  /// In fr, this message translates to:
  /// **'Or'**
  String get cnGold;

  /// No description provided for @cnDiamond.
  ///
  /// In fr, this message translates to:
  /// **'Diamant'**
  String get cnDiamond;

  /// No description provided for @cnPointsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} point} other{{count} points}}'**
  String cnPointsCount(num count);

  /// No description provided for @cnPointsBeforeTier.
  ///
  /// In fr, this message translates to:
  /// **'{points} avant le palier {tier}'**
  String cnPointsBeforeTier(Object points, Object tier);

  /// No description provided for @cnRelayedMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages relayés pour d\'autres'**
  String get cnRelayedMessages;

  /// No description provided for @cnPointsSuffix.
  ///
  /// In fr, this message translates to:
  /// **'+{n} pts'**
  String cnPointsSuffix(Object n);

  /// No description provided for @cnGatewayMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Minutes en mode relais (gateway)'**
  String get cnGatewayMinutes;

  /// No description provided for @cnExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Chaque message que ton appareil relaie pour d\'autres, et chaque minute où il reste disponible comme relais, aide le réseau mesh à couvrir plus de monde, plus loin. Ce badge n\'a aucun effet sur l\'app — c\'est juste une reconnaissance de ta contribution.'**
  String get cnExplanation;

  /// No description provided for @nmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get nmTitle;

  /// No description provided for @nmNewGroup.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get nmNewGroup;

  /// No description provided for @nmScanCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code'**
  String get nmScanCode;

  /// No description provided for @nmVerifyContactIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'identité d\'un contact'**
  String get nmVerifyContactIdentity;

  /// No description provided for @nmNoOneInRange.
  ///
  /// In fr, this message translates to:
  /// **'Personne à portée'**
  String get nmNoOneInRange;

  /// No description provided for @nmNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get nmNoResult;

  /// No description provided for @nmPeopleWillAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les personnes que votre appareil détecte apparaîtront ici.'**
  String get nmPeopleWillAppearHere;

  /// No description provided for @nmInRange.
  ///
  /// In fr, this message translates to:
  /// **'À portée'**
  String get nmInRange;

  /// No description provided for @nmDirectConnection.
  ///
  /// In fr, this message translates to:
  /// **'Connexion directe'**
  String get nmDirectConnection;

  /// No description provided for @nmViaRelays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Via {count} relais} other{Via {count} relais}}'**
  String nmViaRelays(num count);

  /// No description provided for @chFileTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop volumineux (max 50 Mo)'**
  String get chFileTooLarge;

  /// No description provided for @chCannotReadMedia.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce média'**
  String get chCannotReadMedia;

  /// No description provided for @chLocationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Localisation refusée — activez-la dans les réglages du téléphone pour partager votre position.'**
  String get chLocationDenied;

  /// No description provided for @chGettingPosition.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de la position…'**
  String get chGettingPosition;

  /// No description provided for @chPositionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible — réessayez à ciel ouvert.'**
  String get chPositionUnavailable;

  /// No description provided for @chMicPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission micro refusée'**
  String get chMicPermissionDenied;

  /// No description provided for @chCannotStartRecording.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de démarrer l\'enregistrement'**
  String get chCannotStartRecording;

  /// No description provided for @chVoiceSendFailed.
  ///
  /// In fr, this message translates to:
  /// **'Envoi du message vocal impossible'**
  String get chVoiceSendFailed;

  /// No description provided for @chFileSendFailed.
  ///
  /// In fr, this message translates to:
  /// **'Envoi du fichier impossible'**
  String get chFileSendFailed;

  /// No description provided for @chAudioNotFullyReceived.
  ///
  /// In fr, this message translates to:
  /// **'Audio pas encore reçu entièrement'**
  String get chAudioNotFullyReceived;

  /// No description provided for @chVoiceUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Ce message vocal est illisible — il est peut-être arrivé incomplet.'**
  String get chVoiceUnreadable;

  /// No description provided for @chFileNotFullyReceived.
  ///
  /// In fr, this message translates to:
  /// **'Fichier pas encore reçu en entier'**
  String get chFileNotFullyReceived;

  /// No description provided for @chSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible'**
  String get chSaveFailed;

  /// No description provided for @chSavedIn.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré dans {folder}'**
  String chSavedIn(Object folder);

  /// No description provided for @chMessageCopied.
  ///
  /// In fr, this message translates to:
  /// **'Message copié'**
  String get chMessageCopied;

  /// No description provided for @chCallImpossibleRelay.
  ///
  /// In fr, this message translates to:
  /// **'Appel vocal impossible : ce pair est joignable par relais ou en Bluetooth, trop lent pour la voix. Rapprochez-vous pour passer en Wi-Fi.'**
  String get chCallImpossibleRelay;

  /// No description provided for @chUrlCopied.
  ///
  /// In fr, this message translates to:
  /// **'URL copiée : {url}'**
  String chUrlCopied(Object url);

  /// No description provided for @chEditMessageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le message'**
  String get chEditMessageTitle;

  /// No description provided for @chMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get chMessageHint;

  /// No description provided for @chNeverMet.
  ///
  /// In fr, this message translates to:
  /// **'Jamais rencontré'**
  String get chNeverMet;

  /// No description provided for @chSeenJustNow.
  ///
  /// In fr, this message translates to:
  /// **'Vu à l\'instant'**
  String get chSeenJustNow;

  /// No description provided for @chSeenMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Vu il y a {count} min} other{Vu il y a {count} min}}'**
  String chSeenMinutesAgo(num count);

  /// No description provided for @chSeenHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Vu il y a {count} h} other{Vu il y a {count} h}}'**
  String chSeenHoursAgo(num count);

  /// No description provided for @chSeenYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Vu hier'**
  String get chSeenYesterday;

  /// No description provided for @chSeenDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Vu il y a {count} jour} other{Vu il y a {count} jours}}'**
  String chSeenDaysAgo(num count);

  /// No description provided for @chOutOfRange.
  ///
  /// In fr, this message translates to:
  /// **'Hors de portée'**
  String get chOutOfRange;

  /// No description provided for @chCloseSearchTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la recherche'**
  String get chCloseSearchTooltip;

  /// No description provided for @chNetworkDetailsSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Réseau Droplet, voir les détails'**
  String get chNetworkDetailsSemantics;

  /// No description provided for @chMemberCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} membre} other{{count} membres}}'**
  String chMemberCount(num count);

  /// No description provided for @chTypingNow.
  ///
  /// In fr, this message translates to:
  /// **'en train d\'écrire…'**
  String get chTypingNow;

  /// No description provided for @chBroadcastChannel.
  ///
  /// In fr, this message translates to:
  /// **'Canal diffusion'**
  String get chBroadcastChannel;

  /// No description provided for @chNearby.
  ///
  /// In fr, this message translates to:
  /// **'À proximité'**
  String get chNearby;

  /// No description provided for @chReachableViaRelays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Joignable via {count} relais} other{Joignable via {count} relais}}'**
  String chReachableViaRelays(num count);

  /// No description provided for @chReconnectingEllipsis.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion…'**
  String get chReconnectingEllipsis;

  /// No description provided for @chSearchInConversation.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans la conversation'**
  String get chSearchInConversation;

  /// No description provided for @chVoiceCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel vocal'**
  String get chVoiceCall;

  /// No description provided for @chVideoCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel vidéo'**
  String get chVideoCall;

  /// No description provided for @chCallImpossibleBtRelay.
  ///
  /// In fr, this message translates to:
  /// **'Appel impossible : liaison Bluetooth ou relayée'**
  String get chCallImpossibleBtRelay;

  /// No description provided for @chGroupInfoTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Infos du groupe'**
  String get chGroupInfoTooltip;

  /// No description provided for @chNoneFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get chNoneFound;

  /// No description provided for @chSearchResultPosition.
  ///
  /// In fr, this message translates to:
  /// **'{current}/{total}'**
  String chSearchResultPosition(Object current, Object total);

  /// No description provided for @chOlderResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat plus ancien'**
  String get chOlderResult;

  /// No description provided for @chNewerResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat plus récent'**
  String get chNewerResult;

  /// No description provided for @chLoadingOlderMessages.
  ///
  /// In fr, this message translates to:
  /// **'Charger les messages précédents…'**
  String get chLoadingOlderMessages;

  /// No description provided for @chToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get chToday;

  /// No description provided for @chYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get chYesterday;

  /// No description provided for @chMonday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get chMonday;

  /// No description provided for @chTuesday.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get chTuesday;

  /// No description provided for @chWednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get chWednesday;

  /// No description provided for @chThursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get chThursday;

  /// No description provided for @chFriday.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get chFriday;

  /// No description provided for @chSaturday.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get chSaturday;

  /// No description provided for @chSunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get chSunday;

  /// No description provided for @chSayHello.
  ///
  /// In fr, this message translates to:
  /// **'Dites bonjour 👋'**
  String get chSayHello;

  /// No description provided for @chBroadcastEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les messages sans destinataire apparaissent ici.'**
  String get chBroadcastEmptyBody;

  /// No description provided for @chP2pRelayedBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos échanges sont relayés pair à pair, sans Internet.'**
  String get chP2pRelayedBody;

  /// No description provided for @chReply.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get chReply;

  /// No description provided for @chReplyInThread.
  ///
  /// In fr, this message translates to:
  /// **'Répondre dans le fil'**
  String get chReplyInThread;

  /// No description provided for @chCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get chCopy;

  /// No description provided for @chAccessibilityMe.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get chAccessibilityMe;

  /// No description provided for @chPhotoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get chPhotoLabel;

  /// No description provided for @chVideoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get chVideoLabel;

  /// No description provided for @chVoiceMessageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal'**
  String get chVoiceMessageLabel;

  /// No description provided for @chFileLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fichier {name}'**
  String chFileLabel(Object name);

  /// No description provided for @chStickerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sticker {name}'**
  String chStickerLabel(Object name);

  /// No description provided for @chSendingStatus.
  ///
  /// In fr, this message translates to:
  /// **'envoi en cours'**
  String get chSendingStatus;

  /// No description provided for @chPendingStatus.
  ///
  /// In fr, this message translates to:
  /// **'en attente'**
  String get chPendingStatus;

  /// No description provided for @chFailedStatus.
  ///
  /// In fr, this message translates to:
  /// **'échec de l\'envoi'**
  String get chFailedStatus;

  /// No description provided for @chReadStatus.
  ///
  /// In fr, this message translates to:
  /// **'lu'**
  String get chReadStatus;

  /// No description provided for @chDeliveredStatus.
  ///
  /// In fr, this message translates to:
  /// **'remis'**
  String get chDeliveredStatus;

  /// No description provided for @chSentStatus.
  ///
  /// In fr, this message translates to:
  /// **'envoyé'**
  String get chSentStatus;

  /// No description provided for @chForwarded.
  ///
  /// In fr, this message translates to:
  /// **'Transféré'**
  String get chForwarded;

  /// No description provided for @chRetrySendLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer l\'envoi'**
  String get chRetrySendLabel;

  /// No description provided for @chTransmissionDetailsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la transmission'**
  String get chTransmissionDetailsLabel;

  /// No description provided for @chEditedBadge.
  ///
  /// In fr, this message translates to:
  /// **'modifié'**
  String get chEditedBadge;

  /// No description provided for @chFileWord.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get chFileWord;

  /// No description provided for @chSizeBytes.
  ///
  /// In fr, this message translates to:
  /// **'{n} o'**
  String chSizeBytes(Object n);

  /// No description provided for @chSizeKb.
  ///
  /// In fr, this message translates to:
  /// **'{n} Ko'**
  String chSizeKb(Object n);

  /// No description provided for @chSizeMb.
  ///
  /// In fr, this message translates to:
  /// **'{n} Mo'**
  String chSizeMb(Object n);

  /// No description provided for @chVideoReceiving.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo en cours de réception'**
  String get chVideoReceiving;

  /// No description provided for @chPreparingVideo.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de la vidéo…'**
  String get chPreparingVideo;

  /// No description provided for @nmContacts.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get nmContacts;

  /// No description provided for @nmFindByPseudo.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par pseudo'**
  String get nmFindByPseudo;

  /// No description provided for @nmViaInternet.
  ///
  /// In fr, this message translates to:
  /// **'Par Internet'**
  String get nmViaInternet;

  /// No description provided for @nmOutOfRange.
  ///
  /// In fr, this message translates to:
  /// **'Hors de portée'**
  String get nmOutOfRange;

  /// No description provided for @chatsInvitePerson.
  ///
  /// In fr, this message translates to:
  /// **'Inviter une personne'**
  String get chatsInvitePerson;

  /// No description provided for @ivTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitez vos proches'**
  String get ivTitle;

  /// No description provided for @ivSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet est plus utile quand ceux qui comptent y sont — même sans réseau.'**
  String get ivSubtitle;

  /// No description provided for @ivByNumber.
  ///
  /// In fr, this message translates to:
  /// **'Par numéro de téléphone'**
  String get ivByNumber;

  /// No description provided for @ivNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Numéro avec l’indicatif (+237…)'**
  String get ivNumberHint;

  /// No description provided for @ivContacts.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get ivContacts;

  /// No description provided for @ivSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get ivSms;

  /// No description provided for @ivWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get ivWhatsapp;

  /// No description provided for @ivByLink.
  ///
  /// In fr, this message translates to:
  /// **'Par lien'**
  String get ivByLink;

  /// No description provided for @ivCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get ivCopy;

  /// No description provided for @ivShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get ivShare;

  /// No description provided for @ivCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié'**
  String get ivCopied;

  /// No description provided for @ivByQr.
  ///
  /// In fr, this message translates to:
  /// **'Par QR code'**
  String get ivByQr;

  /// No description provided for @ivQrHint.
  ///
  /// In fr, this message translates to:
  /// **'À faire scanner par la personne, face à face.'**
  String get ivQrHint;

  /// No description provided for @ivScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code'**
  String get ivScan;

  /// No description provided for @ivPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Le lien et le code ne contiennent que votre identifiant public et votre clé. Aucun numéro n’est envoyé à Droplet.'**
  String get ivPrivacy;

  /// No description provided for @evTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la vidéo'**
  String get evTitle;

  /// No description provided for @evSplit.
  ///
  /// In fr, this message translates to:
  /// **'Diviser en {n} statuts'**
  String evSplit(int n);

  /// No description provided for @evSplitHint.
  ///
  /// In fr, this message translates to:
  /// **'Chaque partie dure au plus {s} s'**
  String evSplitHint(int s);

  /// No description provided for @evPublished.
  ///
  /// In fr, this message translates to:
  /// **'{n} statuts publiés'**
  String evPublished(int n);

  /// No description provided for @svReply.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get svReply;

  /// No description provided for @svStatusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get svStatusLabel;

  /// No description provided for @svSeenBy.
  ///
  /// In fr, this message translates to:
  /// **'Vu par {n}'**
  String svSeenBy(int n);

  /// No description provided for @clMissedVoice.
  ///
  /// In fr, this message translates to:
  /// **'Appel vocal manqué'**
  String get clMissedVoice;

  /// No description provided for @clMissedVideo.
  ///
  /// In fr, this message translates to:
  /// **'Appel vidéo manqué'**
  String get clMissedVideo;

  /// No description provided for @clCallBack.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler'**
  String get clCallBack;

  /// No description provided for @stoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get stoTitle;

  /// No description provided for @stoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Photos, vidéos et fichiers'**
  String get stoSubtitle;

  /// No description provided for @stoUsed.
  ///
  /// In fr, this message translates to:
  /// **'{taille} utilisés'**
  String stoUsed(String taille);

  /// No description provided for @stoPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get stoPhotos;

  /// No description provided for @stoVideos.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos'**
  String get stoVideos;

  /// No description provided for @stoAudio.
  ///
  /// In fr, this message translates to:
  /// **'Vocaux et audio'**
  String get stoAudio;

  /// No description provided for @stoDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get stoDocuments;

  /// No description provided for @stoOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres (statuts…)'**
  String get stoOther;

  /// No description provided for @stoByChat.
  ///
  /// In fr, this message translates to:
  /// **'Par discussion'**
  String get stoByChat;

  /// No description provided for @stoEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier sur ce téléphone'**
  String get stoEmpty;

  /// No description provided for @stoDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ({n})'**
  String stoDelete(int n);

  /// No description provided for @stoDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Ces fichiers et leurs messages seront supprimés de ce téléphone.'**
  String get stoDeleteConfirm;

  /// No description provided for @tabSelectChat.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une discussion'**
  String get tabSelectChat;

  /// No description provided for @clConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get clConnecting;

  /// No description provided for @chUnreadMessages.
  ///
  /// In fr, this message translates to:
  /// **'{n} message(s) non lu(s)'**
  String chUnreadMessages(int n);

  /// No description provided for @csMessagesSection.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get csMessagesSection;

  /// No description provided for @chGroupTyping.
  ///
  /// In fr, this message translates to:
  /// **'{noms} écrit…'**
  String chGroupTyping(String noms);

  /// No description provided for @tsReadBy.
  ///
  /// In fr, this message translates to:
  /// **'Lu par'**
  String get tsReadBy;

  /// No description provided for @tsDeliveredTo.
  ///
  /// In fr, this message translates to:
  /// **'Distribué à'**
  String get tsDeliveredTo;

  /// No description provided for @tsWaitingFor.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get tsWaitingFor;

  /// No description provided for @chSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get chSelect;

  /// No description provided for @chForward.
  ///
  /// In fr, this message translates to:
  /// **'Transférer'**
  String get chForward;

  /// No description provided for @chForwardTo.
  ///
  /// In fr, this message translates to:
  /// **'Transférer à…'**
  String get chForwardTo;

  /// No description provided for @chSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{n} sélectionné(s)'**
  String chSelectedCount(int n);

  /// No description provided for @chForwarded1.
  ///
  /// In fr, this message translates to:
  /// **'Message transféré'**
  String get chForwarded1;

  /// No description provided for @apCaptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une légende…'**
  String get apCaptionHint;

  /// No description provided for @apValidateCrop.
  ///
  /// In fr, this message translates to:
  /// **'Recadrer'**
  String get apValidateCrop;

  /// No description provided for @chMediaReceiving.
  ///
  /// In fr, this message translates to:
  /// **'Réception en cours'**
  String get chMediaReceiving;

  /// No description provided for @chStickersTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Stickers'**
  String get chStickersTooltip;

  /// No description provided for @chAttachTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Joindre'**
  String get chAttachTooltip;

  /// No description provided for @chDeleteRecordingTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'enregistrement'**
  String get chDeleteRecordingTooltip;

  /// No description provided for @chSlideToCancel.
  ///
  /// In fr, this message translates to:
  /// **'Glisser pour annuler'**
  String get chSlideToCancel;

  /// No description provided for @chReplyingTo.
  ///
  /// In fr, this message translates to:
  /// **'Réponse à {pseudo}'**
  String chReplyingTo(Object pseudo);

  /// No description provided for @chEffectBoom.
  ///
  /// In fr, this message translates to:
  /// **'Boom'**
  String get chEffectBoom;

  /// No description provided for @chEffectLoud.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get chEffectLoud;

  /// No description provided for @chEffectGentle.
  ///
  /// In fr, this message translates to:
  /// **'Douceur'**
  String get chEffectGentle;

  /// No description provided for @chEffectInvisibleInk.
  ///
  /// In fr, this message translates to:
  /// **'Encre invisible'**
  String get chEffectInvisibleInk;

  /// No description provided for @chEffectConfetti.
  ///
  /// In fr, this message translates to:
  /// **'Confettis'**
  String get chEffectConfetti;

  /// No description provided for @chEffectFireworks.
  ///
  /// In fr, this message translates to:
  /// **'Feu d\'artifice'**
  String get chEffectFireworks;

  /// No description provided for @chEffectHearts.
  ///
  /// In fr, this message translates to:
  /// **'Cœurs'**
  String get chEffectHearts;

  /// No description provided for @chEffectSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effet de message'**
  String get chEffectSheetTitle;

  /// No description provided for @chEffectSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Se joue une fois, chez toi et chez ton correspondant'**
  String get chEffectSheetSubtitle;

  /// No description provided for @chOnBubble.
  ///
  /// In fr, this message translates to:
  /// **'Sur la bulle'**
  String get chOnBubble;

  /// No description provided for @chFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran'**
  String get chFullscreen;

  /// No description provided for @chTapToReveal.
  ///
  /// In fr, this message translates to:
  /// **'Toucher pour révéler'**
  String get chTapToReveal;

  /// No description provided for @chThreadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fil de discussion'**
  String get chThreadTitle;

  /// No description provided for @chReplyHint.
  ///
  /// In fr, this message translates to:
  /// **'Réponse…'**
  String get chReplyHint;

  /// No description provided for @chCollapse.
  ///
  /// In fr, this message translates to:
  /// **'Replier'**
  String get chCollapse;

  /// No description provided for @chSeeMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get chSeeMore;

  /// No description provided for @chMessageOptionsSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Options du message'**
  String get chMessageOptionsSemantics;

  /// No description provided for @chLoveReactionSemantics.
  ///
  /// In fr, this message translates to:
  /// **'J\'adore'**
  String get chLoveReactionSemantics;

  /// No description provided for @chBroadcastMesh.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion mesh'**
  String get chBroadcastMesh;

  /// No description provided for @chGroupFallback.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get chGroupFallback;

  /// No description provided for @ciSetupBiometrics.
  ///
  /// In fr, this message translates to:
  /// **'Configurez un empreinte digitale ou Face ID dans les réglages de votre appareil.'**
  String get ciSetupBiometrics;

  /// No description provided for @ciEnableLockReason.
  ///
  /// In fr, this message translates to:
  /// **'Activer le verrouillage pour cette conversation'**
  String get ciEnableLockReason;

  /// No description provided for @ciInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get ciInfoTitle;

  /// No description provided for @ciViewConversation.
  ///
  /// In fr, this message translates to:
  /// **'Voir la conversation'**
  String get ciViewConversation;

  /// No description provided for @ciGatewayOnline.
  ///
  /// In fr, this message translates to:
  /// **'Passerelle · en ligne'**
  String get ciGatewayOnline;

  /// No description provided for @ciOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get ciOnline;

  /// No description provided for @ciOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get ciOffline;

  /// No description provided for @ciMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get ciMessages;

  /// No description provided for @ciMedia.
  ///
  /// In fr, this message translates to:
  /// **'Médias'**
  String get ciMedia;

  /// No description provided for @ciStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get ciStart;

  /// No description provided for @ciPhotosCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Photo ({count})} other{Photos ({count})}}'**
  String ciPhotosCount(num count);

  /// No description provided for @ciVoiceNotesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Note vocale ({count})} other{Notes vocales ({count})}}'**
  String ciVoiceNotesCount(num count);

  /// No description provided for @ciFilesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Fichier ({count})} other{Fichiers ({count})}}'**
  String ciFilesCount(num count);

  /// No description provided for @ciNoMediaSharedYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun média partagé pour le moment.'**
  String get ciNoMediaSharedYet;

  /// No description provided for @ciSecurityCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de sécurité'**
  String get ciSecurityCode;

  /// No description provided for @ciVerified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get ciVerified;

  /// No description provided for @ciKeyChanged.
  ///
  /// In fr, this message translates to:
  /// **'La clé a changé'**
  String get ciKeyChanged;

  /// No description provided for @ciNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Non vérifié'**
  String get ciNotVerified;

  /// No description provided for @ciConversationLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage de conversation'**
  String get ciConversationLock;

  /// No description provided for @ciLockEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activé — empreinte requise pour ouvrir'**
  String get ciLockEnabled;

  /// No description provided for @ciDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get ciDisabled;

  /// No description provided for @ciEphemeralMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages éphémères'**
  String get ciEphemeralMessages;

  /// No description provided for @ci30Seconds.
  ///
  /// In fr, this message translates to:
  /// **'30 secondes'**
  String get ci30Seconds;

  /// No description provided for @ci5Minutes.
  ///
  /// In fr, this message translates to:
  /// **'5 minutes'**
  String get ci5Minutes;

  /// No description provided for @ci1Hour.
  ///
  /// In fr, this message translates to:
  /// **'1 heure'**
  String get ci1Hour;

  /// No description provided for @ci24Hours.
  ///
  /// In fr, this message translates to:
  /// **'24 heures'**
  String get ci24Hours;

  /// No description provided for @ciDurationBeforeDisappear.
  ///
  /// In fr, this message translates to:
  /// **'Durée avant disparition'**
  String get ciDurationBeforeDisappear;

  /// No description provided for @ciBlockContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer ce contact ?'**
  String get ciBlockContactTitle;

  /// No description provided for @ciBlockContactBody.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} ne pourra plus vous envoyer de messages. Vous pouvez le débloquer à tout moment.'**
  String ciBlockContactBody(Object pseudo);

  /// No description provided for @ciBlock.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get ciBlock;

  /// No description provided for @ciUnblock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get ciUnblock;

  /// No description provided for @ciContactBlocked.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} a été bloqué'**
  String ciContactBlocked(Object pseudo);

  /// No description provided for @ciContactUnblocked.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} a été débloqué'**
  String ciContactUnblocked(Object pseudo);

  /// No description provided for @ciReportContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler ce contact ?'**
  String get ciReportContactTitle;

  /// No description provided for @ciReportContactBody.
  ///
  /// In fr, this message translates to:
  /// **'Un signalement anonyme sera envoyé à Droplet : un identifiant technique et le motif choisi ci-dessous, rien d\'autre. Aucun message, aucune conversation avec {pseudo} n\'est jamais transmis.'**
  String ciReportContactBody(Object pseudo);

  /// No description provided for @ciReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get ciReport;

  /// No description provided for @ciReportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé. Merci.'**
  String get ciReportSent;

  /// No description provided for @ciReportFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le signalement n\'a pas pu être envoyé — réessayez plus tard.'**
  String get ciReportFailed;

  /// No description provided for @ciReportReasonSpam.
  ///
  /// In fr, this message translates to:
  /// **'Spam'**
  String get ciReportReasonSpam;

  /// No description provided for @ciReportReasonHarassment.
  ///
  /// In fr, this message translates to:
  /// **'Harcèlement'**
  String get ciReportReasonHarassment;

  /// No description provided for @ciReportReasonIllegal.
  ///
  /// In fr, this message translates to:
  /// **'Contenu illégal'**
  String get ciReportReasonIllegal;

  /// No description provided for @ciReportReasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get ciReportReasonOther;

  /// No description provided for @mcReactWith.
  ///
  /// In fr, this message translates to:
  /// **'Réagir avec {emoji}'**
  String mcReactWith(Object emoji);

  /// No description provided for @nsMeshActive.
  ///
  /// In fr, this message translates to:
  /// **'Mesh actif'**
  String get nsMeshActive;

  /// No description provided for @nsNoDeviceInRange.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil à portée'**
  String get nsNoDeviceInRange;

  /// No description provided for @nsMessagesCirculate.
  ///
  /// In fr, this message translates to:
  /// **'Vos messages circulent d\'appareil en appareil, sans passer par Internet.'**
  String get nsMessagesCirculate;

  /// No description provided for @nsGetCloser.
  ///
  /// In fr, this message translates to:
  /// **'Rapprochez-vous d\'un autre appareil Droplet. Vos messages sont conservés et repartiront tout seuls.'**
  String get nsGetCloser;

  /// No description provided for @nsDevicesInRange.
  ///
  /// In fr, this message translates to:
  /// **'Appareils à portée'**
  String get nsDevicesInRange;

  /// No description provided for @nsReconnectingTitle.
  ///
  /// In fr, this message translates to:
  /// **'En reconnexion'**
  String get nsReconnectingTitle;

  /// No description provided for @nsLinkMomentarilyLost.
  ///
  /// In fr, this message translates to:
  /// **'Liaison momentanément perdue, pas encore abandonnée.'**
  String get nsLinkMomentarilyLost;

  /// No description provided for @nsRelaysAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Relais disponibles'**
  String get nsRelaysAvailable;

  /// No description provided for @nsNoRelayAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil ne peut faire suivre vos messages plus loin pour l\'instant.'**
  String get nsNoRelayAvailable;

  /// No description provided for @nsViaBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Par Bluetooth'**
  String get nsViaBluetooth;

  /// No description provided for @nsViaLocalWifi.
  ///
  /// In fr, this message translates to:
  /// **'Par Wi-Fi local'**
  String get nsViaLocalWifi;

  /// No description provided for @nsWifiCarriesMore.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi porte les fichiers et la voix ; le Bluetooth ne transporte que le texte.'**
  String get nsWifiCarriesMore;

  /// No description provided for @scInvalidQrCode.
  ///
  /// In fr, this message translates to:
  /// **'QR code invalide'**
  String get scInvalidQrCode;

  /// No description provided for @scWrongCode.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas le bon code — la clé ne correspond pas'**
  String get scWrongCode;

  /// No description provided for @scCodeVerified.
  ///
  /// In fr, this message translates to:
  /// **'Code vérifié'**
  String get scCodeVerified;

  /// No description provided for @scVerifiedBanner.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié — la clé de {pseudo} correspond à ce code.'**
  String scVerifiedBanner(Object pseudo);

  /// No description provided for @scKeyChangedBanner.
  ///
  /// In fr, this message translates to:
  /// **'La clé de {pseudo} a changé depuis la dernière vérification.'**
  String scKeyChangedBanner(Object pseudo);

  /// No description provided for @scNotVerifiedYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore vérifié.'**
  String get scNotVerifiedYet;

  /// No description provided for @scCompareCodeInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Compare ce code avec celui affiché sur l\'appareil de {pseudo}, ou scanne directement son QR code pour vérifier automatiquement.'**
  String scCompareCodeInstructions(Object pseudo);

  /// No description provided for @scContactKeyUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Clé du contact pas encore connue — reconnecte-toi à ce pair sur le mesh.'**
  String get scContactKeyUnknown;

  /// No description provided for @scScanCodeOf.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le code de {pseudo}'**
  String scScanCodeOf(Object pseudo);

  /// No description provided for @tsNotDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Non distribué'**
  String get tsNotDelivered;

  /// No description provided for @tsRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu'**
  String get tsRead;

  /// No description provided for @tsDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Distribué'**
  String get tsDelivered;

  /// No description provided for @tsSendingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours'**
  String get tsSendingInProgress;

  /// No description provided for @tsWaitingForRelay.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'un relais'**
  String get tsWaitingForRelay;

  /// No description provided for @tsSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get tsSent;

  /// No description provided for @tsSecondsSingular.
  ///
  /// In fr, this message translates to:
  /// **'{value} seconde'**
  String tsSecondsSingular(Object value);

  /// No description provided for @tsSecondsPlural.
  ///
  /// In fr, this message translates to:
  /// **'{value} secondes'**
  String tsSecondsPlural(Object value);

  /// No description provided for @tsMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{n} min'**
  String tsMinutes(Object n);

  /// No description provided for @tsHours.
  ///
  /// In fr, this message translates to:
  /// **'{n} h'**
  String tsHours(Object n);

  /// No description provided for @tsDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} jour} other{{count} jours}}'**
  String tsDays(num count);

  /// No description provided for @tsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transmission'**
  String get tsTitle;

  /// No description provided for @tsStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get tsStatus;

  /// No description provided for @tsDelayUntilRead.
  ///
  /// In fr, this message translates to:
  /// **'Délai jusqu\'à la lecture'**
  String get tsDelayUntilRead;

  /// No description provided for @tsRoute.
  ///
  /// In fr, this message translates to:
  /// **'Trajet'**
  String get tsRoute;

  /// No description provided for @tsRouteDetail.
  ///
  /// In fr, this message translates to:
  /// **'Les appareils qui ont fait suivre ce message, dans l\'ordre.'**
  String get tsRouteDetail;

  /// No description provided for @tsPath.
  ///
  /// In fr, this message translates to:
  /// **'Chemin'**
  String get tsPath;

  /// No description provided for @tsPassedThroughDevices.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Passé par {count} appareil} other{Passé par {count} appareils}}'**
  String tsPassedThroughDevices(num count);

  /// No description provided for @tsReceivedDirect.
  ///
  /// In fr, this message translates to:
  /// **'Reçu en direct'**
  String get tsReceivedDirect;

  /// No description provided for @tsIntermediateDevicesDetail.
  ///
  /// In fr, this message translates to:
  /// **'Des appareils intermédiaires ont fait suivre ce message jusqu\'à vous.'**
  String get tsIntermediateDevicesDetail;

  /// No description provided for @tsUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get tsUnknown;

  /// No description provided for @tsSentRouteNotReturned.
  ///
  /// In fr, this message translates to:
  /// **'Le trajet d\'un message envoyé n\'est pas renvoyé à son expéditeur.'**
  String get tsSentRouteNotReturned;

  /// No description provided for @tsNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get tsNetwork;

  /// No description provided for @tsMeshDroplet.
  ///
  /// In fr, this message translates to:
  /// **'Mesh Droplet'**
  String get tsMeshDroplet;

  /// No description provided for @tsNoServerNoOperator.
  ///
  /// In fr, this message translates to:
  /// **'Aucun serveur, aucun opérateur.'**
  String get tsNoServerNoOperator;

  /// No description provided for @qsScanSecurityCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le code de sécurité'**
  String get qsScanSecurityCode;

  /// No description provided for @qsCodeDetected.
  ///
  /// In fr, this message translates to:
  /// **'Code détecté'**
  String get qsCodeDetected;

  /// No description provided for @qsFrameQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Cadre le QR code affiché sur l\'appareil de ton contact'**
  String get qsFrameQrCode;

  /// No description provided for @rmRecentVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo récente'**
  String get rmRecentVideo;

  /// No description provided for @rmRecentPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo récente'**
  String get rmRecentPhoto;

  /// No description provided for @rmSeeAllPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Voir toutes les photos'**
  String get rmSeeAllPhotos;

  /// No description provided for @rmSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get rmSeeAll;

  /// No description provided for @aicOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Originale'**
  String get aicOriginal;

  /// No description provided for @aicAzure.
  ///
  /// In fr, this message translates to:
  /// **'Azur'**
  String get aicAzure;

  /// No description provided for @aicNeon.
  ///
  /// In fr, this message translates to:
  /// **'Néon'**
  String get aicNeon;

  /// No description provided for @aicPaper.
  ///
  /// In fr, this message translates to:
  /// **'Papier'**
  String get aicPaper;

  /// No description provided for @aicLagoon.
  ///
  /// In fr, this message translates to:
  /// **'Lagon'**
  String get aicLagoon;

  /// No description provided for @aicAmethyst.
  ///
  /// In fr, this message translates to:
  /// **'Améthyste'**
  String get aicAmethyst;

  /// No description provided for @aicGold.
  ///
  /// In fr, this message translates to:
  /// **'Or'**
  String get aicGold;

  /// No description provided for @aicTide.
  ///
  /// In fr, this message translates to:
  /// **'Marée'**
  String get aicTide;

  /// No description provided for @aicDawn.
  ///
  /// In fr, this message translates to:
  /// **'Aurore'**
  String get aicDawn;

  /// No description provided for @aicGlass.
  ///
  /// In fr, this message translates to:
  /// **'Verre'**
  String get aicGlass;

  /// No description provided for @aicConstellation.
  ///
  /// In fr, this message translates to:
  /// **'Constellation'**
  String get aicConstellation;

  /// No description provided for @aicPrism.
  ///
  /// In fr, this message translates to:
  /// **'Prisme'**
  String get aicPrism;

  /// No description provided for @aicEmerald.
  ///
  /// In fr, this message translates to:
  /// **'Émeraude'**
  String get aicEmerald;

  /// No description provided for @aicChangeIconTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'icône ?'**
  String get aicChangeIconTitle;

  /// No description provided for @aicChangeIconMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'icône « {name} » remplacera celle de votre écran d\'accueil. Certains lanceurs mettent quelques secondes à l\'afficher, ou demandent de revenir à l\'accueil.'**
  String aicChangeIconMessage(Object name);

  /// No description provided for @aicApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get aicApply;

  /// No description provided for @aicIconApplied.
  ///
  /// In fr, this message translates to:
  /// **'Icône « {name} » appliquée'**
  String aicIconApplied(Object name);

  /// No description provided for @aicChangeIconImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Changement d\'icône impossible sur cet appareil'**
  String get aicChangeIconImpossible;

  /// No description provided for @aicTitle.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get aicTitle;

  /// No description provided for @aicCurrentOnHomeScreen.
  ///
  /// In fr, this message translates to:
  /// **'Celle qui apparaît sur votre écran d\'accueil'**
  String get aicCurrentOnHomeScreen;

  /// No description provided for @aicUnavailablePlatform.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible sur cette plateforme'**
  String get aicUnavailablePlatform;

  /// No description provided for @aicAndroidExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Android fige l\'icône d\'une application dans son installation. Droplet contourne cela en déclarant plusieurs points d\'entrée, un par icône, et en n\'en laissant qu\'un actif. Votre lanceur peut mettre quelques secondes à s\'en apercevoir.'**
  String get aicAndroidExplanation;

  /// No description provided for @aicAndroidOnly.
  ///
  /// In fr, this message translates to:
  /// **'Le changement d\'icône n\'est disponible que sur Android.'**
  String get aicAndroidOnly;

  /// No description provided for @beWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get beWeak;

  /// No description provided for @beOkay.
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get beOkay;

  /// No description provided for @beStrong.
  ///
  /// In fr, this message translates to:
  /// **'Solide'**
  String get beStrong;

  /// No description provided for @bePasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire au moins 8 caractères'**
  String get bePasswordTooShort;

  /// No description provided for @bePasswordsDontMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne correspondent pas'**
  String get bePasswordsDontMatch;

  /// No description provided for @beBackupSubject.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde Droplet'**
  String get beBackupSubject;

  /// No description provided for @beBackupShareText.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde chiffrée de mon identité Droplet — à garder en lieu sûr.'**
  String get beBackupShareText;

  /// No description provided for @beBackupCreated.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde créée'**
  String get beBackupCreated;

  /// No description provided for @beBackupFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la sauvegarde'**
  String get beBackupFailed;

  /// No description provided for @beBackupMyIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder mon identité'**
  String get beBackupMyIdentity;

  /// No description provided for @beWarningBody.
  ///
  /// In fr, this message translates to:
  /// **'Quiconque possède ce fichier et le mot de passe peut se faire passer pour toi. Garde-le en lieu sûr (jamais envoyé à personne d\'autre que toi-même) et choisis un mot de passe que tu es seul à connaître.'**
  String get beWarningBody;

  /// No description provided for @bePasswordProtects.
  ///
  /// In fr, this message translates to:
  /// **'Ce mot de passe protège ta sauvegarde. Il n\'est jamais enregistré : sans lui, le fichier est définitivement inutilisable.'**
  String get bePasswordProtects;

  /// No description provided for @bePassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get bePassword;

  /// No description provided for @beConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get beConfirmPassword;

  /// No description provided for @beIncludeMessageHistory.
  ///
  /// In fr, this message translates to:
  /// **'Inclure l\'historique des messages'**
  String get beIncludeMessageHistory;

  /// No description provided for @beOtherwiseOnlyIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, seuls l\'identité, les contacts et les groupes sont sauvegardés'**
  String get beOtherwiseOnlyIdentity;

  /// No description provided for @beCreateAndShare.
  ///
  /// In fr, this message translates to:
  /// **'Créer et partager la sauvegarde'**
  String get beCreateAndShare;

  /// No description provided for @jsErrorJournalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal des erreurs'**
  String get jsErrorJournalTitle;

  /// No description provided for @jsNoErrorsRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune erreur enregistrée. C\'est le cas normal.'**
  String get jsNoErrorsRecorded;

  /// No description provided for @jsLinesStayOnDevice.
  ///
  /// In fr, this message translates to:
  /// **'Ces lignes restent sur cet appareil : Droplet n\'a aucun serveur où les envoyer. Si vous testez l\'application, transmettez-les — sans elles, le défaut n\'existe pour personne.'**
  String get jsLinesStayOnDevice;

  /// No description provided for @jsErase.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get jsErase;

  /// No description provided for @jsShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Droplet — journal des erreurs'**
  String get jsShareSubject;

  /// No description provided for @jsShareText.
  ///
  /// In fr, this message translates to:
  /// **'Journal des erreurs Droplet. Ce fichier ne contient ni messages, ni contacts, ni clés.'**
  String get jsShareText;

  /// No description provided for @jsShareUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Partage indisponible — journal copié'**
  String get jsShareUnavailable;

  /// No description provided for @clOutgoingCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel en cours…'**
  String get clOutgoingCall;

  /// No description provided for @clIncomingCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel entrant…'**
  String get clIncomingCall;

  /// No description provided for @clCallImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Appel impossible'**
  String get clCallImpossible;

  /// No description provided for @clCallEnded.
  ///
  /// In fr, this message translates to:
  /// **'Appel terminé'**
  String get clCallEnded;

  /// No description provided for @clCallWith.
  ///
  /// In fr, this message translates to:
  /// **'Appel avec {pseudo}'**
  String clCallWith(Object pseudo);

  /// No description provided for @clEndToEndEncrypted.
  ///
  /// In fr, this message translates to:
  /// **'Chiffré de bout en bout'**
  String get clEndToEndEncrypted;

  /// No description provided for @clCallStatusSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Statut de l\'appel : {status}'**
  String clCallStatusSemantics(Object status);

  /// No description provided for @clEnableMic.
  ///
  /// In fr, this message translates to:
  /// **'Activer le micro'**
  String get clEnableMic;

  /// No description provided for @clMuteMic.
  ///
  /// In fr, this message translates to:
  /// **'Couper le micro'**
  String get clMuteMic;

  /// No description provided for @clDisableSpeaker.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le haut-parleur'**
  String get clDisableSpeaker;

  /// No description provided for @clEnableSpeaker.
  ///
  /// In fr, this message translates to:
  /// **'Activer le haut-parleur'**
  String get clEnableSpeaker;

  /// No description provided for @clDisableCamera.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver la caméra'**
  String get clDisableCamera;

  /// No description provided for @clEnableCamera.
  ///
  /// In fr, this message translates to:
  /// **'Activer la caméra'**
  String get clEnableCamera;

  /// No description provided for @clHangUp.
  ///
  /// In fr, this message translates to:
  /// **'Raccrocher'**
  String get clHangUp;

  /// No description provided for @clIncomingVideoCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel vidéo entrant'**
  String get clIncomingVideoCall;

  /// No description provided for @clSwitchCamera.
  ///
  /// In fr, this message translates to:
  /// **'Changer de caméra'**
  String get clSwitchCamera;

  /// No description provided for @gcGroupCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel de groupe'**
  String get gcGroupCall;

  /// No description provided for @gcConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get gcConnecting;

  /// No description provided for @gcOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get gcOnline;

  /// No description provided for @gcFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get gcFailed;

  /// No description provided for @gcDisconnected.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get gcDisconnected;

  /// No description provided for @gcReturnToCall.
  ///
  /// In fr, this message translates to:
  /// **'Revenir à l’appel'**
  String get gcReturnToCall;

  /// No description provided for @gcMinimize.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get gcMinimize;

  /// No description provided for @gcVoiceOnly.
  ///
  /// In fr, this message translates to:
  /// **'Voix uniquement'**
  String get gcVoiceOnly;

  /// No description provided for @gcReactWith.
  ///
  /// In fr, this message translates to:
  /// **'Réagir avec {emoji}'**
  String gcReactWith(String emoji);

  /// No description provided for @gcSpeakingNow.
  ///
  /// In fr, this message translates to:
  /// **'Parle en ce moment'**
  String get gcSpeakingNow;

  /// No description provided for @gcMicOff.
  ///
  /// In fr, this message translates to:
  /// **'Micro coupé'**
  String get gcMicOff;

  /// No description provided for @gcParticipantsVoiceOnly.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one {{count} participant · voix uniquement} other {{count} participants · voix uniquement}}'**
  String gcParticipantsVoiceOnly(num count);

  /// No description provided for @ntfChannelMessagesName.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get ntfChannelMessagesName;

  /// No description provided for @ntfChannelMessagesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux messages et statuts mesh'**
  String get ntfChannelMessagesDesc;

  /// No description provided for @ntfChannelCallsName.
  ///
  /// In fr, this message translates to:
  /// **'Appels'**
  String get ntfChannelCallsName;

  /// No description provided for @ntfChannelCallsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Appels entrants et manqués'**
  String get ntfChannelCallsDesc;

  /// No description provided for @ntfChannelMeshName.
  ///
  /// In fr, this message translates to:
  /// **'Mesh & urgence'**
  String get ntfChannelMeshName;

  /// No description provided for @ntfChannelMeshDesc.
  ///
  /// In fr, this message translates to:
  /// **'Service mesh actif, statuts et messages d\'urgence'**
  String get ntfChannelMeshDesc;

  /// No description provided for @ntfReply.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get ntfReply;

  /// No description provided for @ntfYourReply.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse'**
  String get ntfYourReply;

  /// No description provided for @ntfMarkAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get ntfMarkAsRead;

  /// No description provided for @ntfIncomingCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel entrant'**
  String get ntfIncomingCall;

  /// No description provided for @ntfAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get ntfAnswer;

  /// No description provided for @ntfDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get ntfDecline;

  /// No description provided for @ntfMissedCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel manqué'**
  String get ntfMissedCall;

  /// No description provided for @ntfSendFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'envoi'**
  String get ntfSendFailedTitle;

  /// No description provided for @ntfSendFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Un message n\'a pas pu être envoyé — nouvel essai dès qu\'un pair est à portée.'**
  String get ntfSendFailedBody;

  /// No description provided for @ntfNewStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau statut'**
  String get ntfNewStatusTitle;

  /// No description provided for @ntfStatusPublishedBody.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} a publié un statut'**
  String ntfStatusPublishedBody(Object pseudo);

  /// No description provided for @ntfStatusLikedTitle.
  ///
  /// In fr, this message translates to:
  /// **'❤️ {pseudo} a aimé ton statut'**
  String ntfStatusLikedTitle(Object pseudo);

  /// No description provided for @ntfTapToView.
  ///
  /// In fr, this message translates to:
  /// **'Appuyer pour voir'**
  String get ntfTapToView;

  /// No description provided for @ntfStatusReplyTitle.
  ///
  /// In fr, this message translates to:
  /// **'💬 {pseudo} a répondu à ton statut'**
  String ntfStatusReplyTitle(Object pseudo);

  /// No description provided for @ntfEmergencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Message d\'urgence'**
  String get ntfEmergencyTitle;

  /// No description provided for @ntfEmergencyBody.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} a diffusé « Je suis en sécurité »'**
  String ntfEmergencyBody(Object pseudo);

  /// No description provided for @mnAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get mnAccept;

  /// No description provided for @mnMeshVoiceCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel vocal mesh'**
  String get mnMeshVoiceCall;

  /// No description provided for @mnGroupCallIncoming.
  ///
  /// In fr, this message translates to:
  /// **'Appel de groupe entrant'**
  String get mnGroupCallIncoming;

  /// No description provided for @mnInvitesYou.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} t\'invite'**
  String mnInvitesYou(Object pseudo);

  /// No description provided for @mnGroupCallOtherParticipants.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one {Appel de groupe · {count} autre participant} other {Appel de groupe · {count} autres participants}}'**
  String mnGroupCallOtherParticipants(num count);

  /// No description provided for @asWhoCanSee.
  ///
  /// In fr, this message translates to:
  /// **'Qui peut voir ce statut ?'**
  String get asWhoCanSee;

  /// No description provided for @asAllContacts.
  ///
  /// In fr, this message translates to:
  /// **'Tous mes contacts'**
  String get asAllContacts;

  /// No description provided for @asContactsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one {{count} contact} other {{count} contacts}}'**
  String asContactsCount(num count);

  /// No description provided for @asExceptOption.
  ///
  /// In fr, this message translates to:
  /// **'Sauf...'**
  String get asExceptOption;

  /// No description provided for @asExcludedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one {{count} exclu} other {{count} exclus}}'**
  String asExcludedCount(num count);

  /// No description provided for @asExcludeContacts.
  ///
  /// In fr, this message translates to:
  /// **'Exclure des contacts'**
  String get asExcludeContacts;

  /// No description provided for @asOnlyOption.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement...'**
  String get asOnlyOption;

  /// No description provided for @asShareWithSpecific.
  ///
  /// In fr, this message translates to:
  /// **'Partager avec des contacts spécifiques'**
  String get asShareWithSpecific;

  /// No description provided for @asNoContactsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact disponible'**
  String get asNoContactsAvailable;

  /// No description provided for @asConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get asConfirm;

  /// No description provided for @apYourPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Votre photo'**
  String get apYourPhoto;

  /// No description provided for @apNoPhotoAccessible.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo accessible sur cet appareil.'**
  String get apNoPhotoAccessible;

  /// No description provided for @apBrowseFiles.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir les fichiers'**
  String get apBrowseFiles;

  /// No description provided for @apRecentPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo récente'**
  String get apRecentPhoto;

  /// No description provided for @bgSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get bgSkip;

  /// No description provided for @bgStepOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'Étape {rang} sur {total}.'**
  String bgStepOfTotal(Object rang, Object total);

  /// No description provided for @csGuideNetworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Personne à proximité ? C\'est normal'**
  String get csGuideNetworkTitle;

  /// No description provided for @csGuideNetworkText.
  ///
  /// In fr, this message translates to:
  /// **'Droplet ne passe par aucun serveur : il parle aux téléphones à portée. Ici vous voyez qui est joignable, et par quelle radio. Zéro pair ne veut pas dire que ça ne marche pas — juste que personne n\'est encore là.'**
  String get csGuideNetworkText;

  /// No description provided for @csGuideWriteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez même sans personne'**
  String get csGuideWriteTitle;

  /// No description provided for @csGuideWriteText.
  ///
  /// In fr, this message translates to:
  /// **'Un message écrit maintenant attend sur votre téléphone et repart dès qu\'un appareil passe à portée — dans la rue, dans un taxi. Il n\'est pas perdu, il patiente.'**
  String get csGuideWriteText;

  /// No description provided for @csGuideBackupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardez votre identité'**
  String get csGuideBackupTitle;

  /// No description provided for @csGuideBackupText.
  ///
  /// In fr, this message translates to:
  /// **'Sans serveur, personne ne peut vous rendre votre compte. Exportez votre identité depuis les réglages : sans cette sauvegarde, un téléphone perdu emporte tout.'**
  String get csGuideBackupText;

  /// No description provided for @csShowLockedChatsReason.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les discussions verrouillées'**
  String get csShowLockedChatsReason;

  /// No description provided for @cvlNoBiometricsConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Aucune empreinte digitale configurée sur cet appareil'**
  String get cvlNoBiometricsConfigured;

  /// No description provided for @cvlUnlockConversationWith.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller la conversation avec {pseudo}'**
  String cvlUnlockConversationWith(Object pseudo);

  /// No description provided for @cvlAuthFailed.
  ///
  /// In fr, this message translates to:
  /// **'Authentification échouée'**
  String get cvlAuthFailed;

  /// No description provided for @cvlAuthError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'authentification'**
  String get cvlAuthError;

  /// No description provided for @cvlConversationLocked.
  ///
  /// In fr, this message translates to:
  /// **'Conversation verrouillée'**
  String get cvlConversationLocked;

  /// No description provided for @cvlUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller'**
  String get cvlUnlock;

  /// No description provided for @dcAddText.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter du texte'**
  String get dcAddText;

  /// No description provided for @dcYourTextHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre texte...'**
  String get dcYourTextHint;

  /// No description provided for @pbDropletProBadge.
  ///
  /// In fr, this message translates to:
  /// **'Badge Droplet Pro'**
  String get pbDropletProBadge;

  /// No description provided for @rpReact.
  ///
  /// In fr, this message translates to:
  /// **'Réagir'**
  String get rpReact;

  /// No description provided for @rpSaveToPhone.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer sur le téléphone'**
  String get rpSaveToPhone;

  /// No description provided for @chViaTor.
  ///
  /// In fr, this message translates to:
  /// **'Via Tor'**
  String get chViaTor;

  /// No description provided for @chTorInactive.
  ///
  /// In fr, this message translates to:
  /// **'Tor inactif'**
  String get chTorInactive;

  /// No description provided for @chViaInternet.
  ///
  /// In fr, this message translates to:
  /// **'Via Internet'**
  String get chViaInternet;

  /// No description provided for @chReachedViaTorSemantic.
  ///
  /// In fr, this message translates to:
  /// **'Contact joint via Tor'**
  String get chReachedViaTorSemantic;

  /// No description provided for @nsTorConnectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connecté via Tor'**
  String get nsTorConnectedTitle;

  /// No description provided for @nsTorInactiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tor désactivé'**
  String get nsTorInactiveTitle;

  /// No description provided for @nsTorConnectedExplain.
  ///
  /// In fr, this message translates to:
  /// **'Vos messages passent par le réseau Tor et attendent dans une boîte aux lettres chiffrée jusqu\'à ce que {pseudo} s\'y connecte.'**
  String nsTorConnectedExplain(Object pseudo);

  /// No description provided for @nsTorInactiveExplain.
  ///
  /// In fr, this message translates to:
  /// **'Activez Tor dans les réglages pour pouvoir écrire à {pseudo} — sans lui, vos messages resteront en attente sur cet appareil.'**
  String nsTorInactiveExplain(Object pseudo);

  /// No description provided for @nsTorMailboxTitle.
  ///
  /// In fr, this message translates to:
  /// **'Boîte aux lettres chiffrée'**
  String get nsTorMailboxTitle;

  /// No description provided for @nsTorMailboxDetail.
  ///
  /// In fr, this message translates to:
  /// **'Ni vous ni Droplet ne pouvez lire ce qu\'elle contient — seul·e {pseudo} a la clé.'**
  String nsTorMailboxDetail(Object pseudo);

  /// No description provided for @nsOpenTorSettings.
  ///
  /// In fr, this message translates to:
  /// **'Activer Tor'**
  String get nsOpenTorSettings;

  /// No description provided for @qrInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Ce code QR n\'est pas un code Droplet.'**
  String get qrInvalidCode;

  /// No description provided for @qrPeerAdded.
  ///
  /// In fr, this message translates to:
  /// **'Pair ajouté'**
  String get qrPeerAdded;

  /// No description provided for @qrReadyToChatWith.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez maintenant discuter avec {pseudo}'**
  String qrReadyToChatWith(Object pseudo);

  /// No description provided for @clViaInternet.
  ///
  /// In fr, this message translates to:
  /// **'Via Internet'**
  String get clViaInternet;

  /// No description provided for @tsPathTorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Ce message ne passe pas par les appareils autour de vous : il transite par une boîte aux lettres chiffrée sur le réseau Tor, accessible uniquement par vous deux.'**
  String get tsPathTorDetail;

  /// No description provided for @tsNetworkTorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Un serveur relais est nécessaire pour joindre ce contact à distance — Droplet ne peut pas s\'en passer ici, contrairement au maillage local.'**
  String get tsNetworkTorDetail;

  /// No description provided for @torSearchDirectory.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans l\'annuaire'**
  String get torSearchDirectory;

  /// No description provided for @dvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get dvTitle;

  /// No description provided for @dvClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get dvClose;

  /// No description provided for @dvSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un pseudo...'**
  String get dvSearchHint;

  /// No description provided for @dvEnableTorToSearch.
  ///
  /// In fr, this message translates to:
  /// **'Activez Tor dans les paramètres pour rechercher dans l\'annuaire.'**
  String get dvEnableTorToSearch;

  /// No description provided for @dvSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en cours...'**
  String get dvSearching;

  /// No description provided for @dvNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get dvNoResults;

  /// No description provided for @dvNoUserFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé pour cette recherche.'**
  String get dvNoUserFound;

  /// No description provided for @dvResultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one {{count} résultat} other {{count} résultats}}'**
  String dvResultsCount(num count);

  /// No description provided for @dvSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get dvSend;

  /// No description provided for @aiNewConversation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get aiNewConversation;

  /// No description provided for @aiMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get aiMessageHint;

  /// No description provided for @aiCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get aiCopied;

  /// No description provided for @aiAskQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Posez une question'**
  String get aiAskQuestion;

  /// No description provided for @aiRunsLocally.
  ///
  /// In fr, this message translates to:
  /// **'Cet assistant tourne entièrement sur votre appareil — rien n\'est jamais envoyé sur Internet.'**
  String get aiRunsLocally;

  /// No description provided for @aiMemorySaved.
  ///
  /// In fr, this message translates to:
  /// **'Je m\'en souviendrai.'**
  String get aiMemorySaved;

  /// No description provided for @aiMemoryForgotten.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai oublié ce que vous m\'aviez demandé de retenir.'**
  String get aiMemoryForgotten;

  /// No description provided for @aiMemoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mémoire de l\'assistant'**
  String get aiMemoryTitle;

  /// No description provided for @aiMemoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien de retenu pour l\'instant. Dites « retiens que… » pour épingler une information.'**
  String get aiMemoryEmpty;

  /// No description provided for @aiMemoryForget.
  ///
  /// In fr, this message translates to:
  /// **'Tout oublier'**
  String get aiMemoryForget;

  /// No description provided for @aiExpertHint.
  ///
  /// In fr, this message translates to:
  /// **'Je connais Droplet en détail : le mesh, Tor, les appels, la confidentialité.'**
  String get aiExpertHint;

  /// No description provided for @chAskAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Demander à l\'assistant'**
  String get chAskAssistant;

  /// No description provided for @chAskAssistantInvite.
  ///
  /// In fr, this message translates to:
  /// **'Aide-moi à répondre à {name}.'**
  String chAskAssistantInvite(Object name);

  /// No description provided for @aiPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de l\'assistant… {percentage} %'**
  String aiPreparing(Object percentage);

  /// No description provided for @aiOneTimeDownload.
  ///
  /// In fr, this message translates to:
  /// **'Une seule fois — il reste ensuite sur votre appareil, sans aucun autre téléchargement.'**
  String get aiOneTimeDownload;

  /// No description provided for @aiGenericError.
  ///
  /// In fr, this message translates to:
  /// **'Désolé, une erreur s\'est produite.'**
  String get aiGenericError;

  /// No description provided for @aiNotAvailableYet.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant n\'est pas encore disponible sur cette version de Droplet.'**
  String get aiNotAvailableYet;

  /// No description provided for @aiDownloadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement impossible : {error}'**
  String aiDownloadFailed(Object error);

  /// No description provided for @ntfSomeoneCalling.
  ///
  /// In fr, this message translates to:
  /// **'Quelqu\'un essaie de vous joindre'**
  String get ntfSomeoneCalling;

  /// No description provided for @ntfNewMessageWake.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message — ouvrez Droplet pour le lire'**
  String get ntfNewMessageWake;

  /// No description provided for @chNearbyAndInternet.
  ///
  /// In fr, this message translates to:
  /// **'À proximité · Internet'**
  String get chNearbyAndInternet;

  /// No description provided for @chRelaysAndInternet.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} relais · Internet} other{{count} relais · Internet}}'**
  String chRelaysAndInternet(int count);

  /// No description provided for @chWaitingInternet.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'Internet'**
  String get chWaitingInternet;

  /// No description provided for @chatsNetMeshInternet.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} à proximité · Internet} other{{count} à proximité · Internet}}'**
  String chatsNetMeshInternet(int count);

  /// No description provided for @chatsNetMeshOnly.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} à proximité · sans Internet} other{{count} à proximité · sans Internet}}'**
  String chatsNetMeshOnly(int count);

  /// No description provided for @chatsNetInternetOnly.
  ///
  /// In fr, this message translates to:
  /// **'Personne à proximité · Internet'**
  String get chatsNetInternetOnly;

  /// No description provided for @clPathMesh.
  ///
  /// In fr, this message translates to:
  /// **'Mesh · Wi-Fi direct'**
  String get clPathMesh;

  /// No description provided for @clPathInternetDirect.
  ///
  /// In fr, this message translates to:
  /// **'Internet · direct'**
  String get clPathInternetDirect;

  /// No description provided for @clPathInternetRelay.
  ///
  /// In fr, this message translates to:
  /// **'Internet · relais sécurisé'**
  String get clPathInternetRelay;

  /// No description provided for @clReconnecting.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion…'**
  String get clReconnecting;

  /// No description provided for @clLabelSpeaker.
  ///
  /// In fr, this message translates to:
  /// **'Haut-parleur'**
  String get clLabelSpeaker;

  /// No description provided for @clLabelCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get clLabelCamera;

  /// No description provided for @clLabelMic.
  ///
  /// In fr, this message translates to:
  /// **'Micro'**
  String get clLabelMic;

  /// No description provided for @clLabelFlip.
  ///
  /// In fr, this message translates to:
  /// **'Retourner'**
  String get clLabelFlip;

  /// No description provided for @clEncryptedShort.
  ///
  /// In fr, this message translates to:
  /// **'Chiffré de bout en bout'**
  String get clEncryptedShort;

  /// No description provided for @clQualitySemantics.
  ///
  /// In fr, this message translates to:
  /// **'Qualité de l\'appel : {bars} sur 3'**
  String clQualitySemantics(int bars);

  /// No description provided for @beOnlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique en ligne'**
  String get beOnlineTitle;

  /// No description provided for @beOnlineBody.
  ///
  /// In fr, this message translates to:
  /// **'Chaque jour, une copie chiffrée avec ce mot de passe est gardée sur le serveur Droplet, qui ne peut pas la lire. Sur un nouveau téléphone, il suffit du même pseudo et du même mot de passe. Les photos, vidéos et fichiers reçus n\'en font pas partie.'**
  String get beOnlineBody;

  /// No description provided for @beOnlineSwitch.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder chaque jour sur le serveur'**
  String get beOnlineSwitch;

  /// No description provided for @beOnlineLast.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde : {date}'**
  String beOnlineLast(String date);

  /// No description provided for @beOnlineNever.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de sauvegarde en ligne'**
  String get beOnlineNever;

  /// No description provided for @beOnlineNow.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder maintenant'**
  String get beOnlineNow;

  /// No description provided for @beOnlineDone.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en ligne effectuée'**
  String get beOnlineDone;

  /// No description provided for @beOnlineFailed.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en ligne impossible pour le moment'**
  String get beOnlineFailed;

  /// No description provided for @obRestoreFromServer.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer depuis le serveur'**
  String get obRestoreFromServer;

  /// No description provided for @obEnterPseudoFirst.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez d\'abord le pseudo de votre sauvegarde'**
  String get obEnterPseudoFirst;

  /// No description provided for @obNoServerBackup.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde trouvée pour ce pseudo et ce mot de passe'**
  String get obNoServerBackup;

  /// No description provided for @obTooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'essais — réessayez dans une heure'**
  String get obTooManyAttempts;

  /// No description provided for @chatsInviteLink.
  ///
  /// In fr, this message translates to:
  /// **'Inviter par un lien'**
  String get chatsInviteLink;

  /// No description provided for @invShareText.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} t\'invite sur Droplet, la messagerie chiffrée qui marche même sans réseau : {lien}'**
  String invShareText(String pseudo, String lien);

  /// No description provided for @invTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitation'**
  String get invTitle;

  /// No description provided for @invBody.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} vous invite à discuter sur Droplet.'**
  String invBody(String pseudo);

  /// No description provided for @invAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter et écrire'**
  String get invAdd;

  /// No description provided for @invInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien d\'invitation est invalide ou incomplet.'**
  String get invInvalid;

  /// No description provided for @invSelf.
  ///
  /// In fr, this message translates to:
  /// **'C\'est votre propre lien d\'invitation.'**
  String get invSelf;
  /// No description provided for @seAnimationHeader.
  ///
  /// In fr, this message translates to:
  /// **'Animation d\'envoi'**
  String get seAnimationHeader;

  /// No description provided for @seAnimationFull.
  ///
  /// In fr, this message translates to:
  /// **'Complète'**
  String get seAnimationFull;

  /// No description provided for @seAnimationReduced.
  ///
  /// In fr, this message translates to:
  /// **'Réduite'**
  String get seAnimationReduced;

  /// No description provided for @seAnimationOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get seAnimationOff;

  /// No description provided for @seAnimationFullDesc.
  ///
  /// In fr, this message translates to:
  /// **'Plic emporte le message, se téléporte et vous salue.'**
  String get seAnimationFullDesc;

  /// No description provided for @seAnimationReducedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un simple fondu, sans mouvement ni particules.'**
  String get seAnimationReducedDesc;

  /// No description provided for @seAnimationOffDesc.
  ///
  /// In fr, this message translates to:
  /// **'Aucune animation après l\'envoi.'**
  String get seAnimationOffDesc;

  /// No description provided for @seAnimationReplay.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour rejouer'**
  String get seAnimationReplay;

  /// No description provided for @seAnimationNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune animation'**
  String get seAnimationNone;

  /// No description provided for @seAnimationSampleIn.
  ///
  /// In fr, this message translates to:
  /// **'On se voit au port ?'**
  String get seAnimationSampleIn;

  /// No description provided for @seAnimationSampleOut.
  ///
  /// In fr, this message translates to:
  /// **'À tout de suite'**
  String get seAnimationSampleOut;

  /// No description provided for @trTitle.
  ///
  /// In fr, this message translates to:
  /// **'Traduction'**
  String get trTitle;

  /// No description provided for @trOnDevice.
  ///
  /// In fr, this message translates to:
  /// **'Traduction sur l\'appareil…'**
  String get trOnDevice;

  /// No description provided for @trUnknownLang.
  ///
  /// In fr, this message translates to:
  /// **'Langue inconnue'**
  String get trUnknownLang;

  /// No description provided for @trOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Original'**
  String get trOriginal;

  /// No description provided for @trCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get trCopy;

  /// No description provided for @trInChat.
  ///
  /// In fr, this message translates to:
  /// **'Dans la discussion'**
  String get trInChat;

  /// No description provided for @trRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get trRetry;

  /// No description provided for @trSame.
  ///
  /// In fr, this message translates to:
  /// **'Ce message est déjà dans cette langue.'**
  String get trSame;

  /// No description provided for @trModel.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle de cette langue n\'est pas encore installé sur l\'appareil.'**
  String get trModel;

  /// No description provided for @trUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil n\'a pas de moteur de traduction hors ligne.'**
  String get trUnavailable;

  /// No description provided for @trFailed.
  ///
  /// In fr, this message translates to:
  /// **'La traduction n\'a pas abouti.'**
  String get trFailed;

  /// No description provided for @pfMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get pfMessage;

  /// No description provided for @pfCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel'**
  String get pfCall;

  /// No description provided for @pfSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get pfSecurity;

  /// No description provided for @aiActCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get aiActCopy;

  /// No description provided for @aiActRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire à voix haute'**
  String get aiActRead;

  /// No description provided for @aiActStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la lecture'**
  String get aiActStop;

  /// No description provided for @aiActLike.
  ///
  /// In fr, this message translates to:
  /// **'Bonne réponse'**
  String get aiActLike;

  /// No description provided for @aiActDislike.
  ///
  /// In fr, this message translates to:
  /// **'Mauvaise réponse'**
  String get aiActDislike;

  /// No description provided for @aiActShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get aiActShare;

  /// No description provided for @aiActRegenerate.
  ///
  /// In fr, this message translates to:
  /// **'Régénérer'**
  String get aiActRegenerate;

  /// No description provided for @aiFeedbackThanks.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre retour'**
  String get aiFeedbackThanks;

  /// No description provided for @intelOnlineHeader.
  ///
  /// In fr, this message translates to:
  /// **'Traduction et transcription'**
  String get intelOnlineHeader;

  /// No description provided for @intelOnlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'En ligne quand je suis connecté'**
  String get intelOnlineTitle;

  /// No description provided for @intelOnlineSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit — MyMemory, Apple ou Google'**
  String get intelOnlineSubtitle;

  /// No description provided for @intelOnlineFooter.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé, rien ne passe par Internet. Activé et connecté : le texte à traduire part vers MyMemory ; sur iPhone, un vocal que l\'appareil ne sait pas transcrire part au service vocal d\'Apple. Pour ces trajets, le contenu n\'est plus chiffré de bout en bout. Sur Android, seul le modèle vocal se télécharge : les vocaux restent sur le téléphone.'**
  String get intelOnlineFooter;

  /// No description provided for @trOnline.
  ///
  /// In fr, this message translates to:
  /// **'Traduire en ligne'**
  String get trOnline;

  /// No description provided for @trOnlineNote.
  ///
  /// In fr, this message translates to:
  /// **'Le texte partira vers MyMemory, un service gratuit. Pour ce trajet, il n\'est plus chiffré de bout en bout.'**
  String get trOnlineNote;

  /// No description provided for @trViaOnline.
  ///
  /// In fr, this message translates to:
  /// **'Traduit en ligne par MyMemory'**
  String get trViaOnline;

  /// No description provided for @vnModelDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle vocal de cette langue se télécharge. Réessayez dans un instant.'**
  String get vnModelDownloading;

  /// No description provided for @vnModelNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Il manque le modèle vocal de cette langue. Activez « En ligne quand je suis connecté » dans les réglages pour le télécharger une fois.'**
  String get vnModelNeeded;

  /// No description provided for @nwStatusHeader.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get nwStatusHeader;

  /// No description provided for @nwAddStatus.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un statut'**
  String get nwAddStatus;

  /// No description provided for @nwStatusNewA11y.
  ///
  /// In fr, this message translates to:
  /// **'nouveau'**
  String get nwStatusNewA11y;

  /// No description provided for @svReplySent.
  ///
  /// In fr, this message translates to:
  /// **'Réponse envoyée à {name}'**
  String svReplySent(String name);

  /// No description provided for @blkYouBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez bloqué ce contact.'**
  String get blkYouBlocked;

  /// No description provided for @blkUnblock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get blkUnblock;

  /// No description provided for @blkListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts bloqués'**
  String get blkListTitle;

  /// No description provided for @blkNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact bloqué'**
  String get blkNone;

  /// No description provided for @blkFooter.
  ///
  /// In fr, this message translates to:
  /// **'Un contact bloqué ne peut plus vous écrire ni vous appeler, et ne reçoit plus vos statuts ni votre photo. Il n\'en est pas prévenu. Votre téléphone continue de relayer ses messages destinés à d\'autres personnes, sans pouvoir les lire : le maillage ne dépend pas de vos blocages.'**
  String get blkFooter;

  /// No description provided for @blkUnblockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer {name} ?'**
  String blkUnblockTitle(String name);

  /// No description provided for @blkUnblockToCall.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer {name} pour l\'appeler ?'**
  String blkUnblockToCall(String name);

  /// No description provided for @nvDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get nvDone;

  /// No description provided for @nvBack.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get nvBack;

  /// No description provided for @nvForward.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get nvForward;

  /// No description provided for @nvShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get nvShare;

  /// No description provided for @nvOpenInBrowser.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans le navigateur'**
  String get nvOpenInBrowser;

  /// No description provided for @nvReload.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get nvReload;

  /// No description provided for @nvCopyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get nvCopyLink;

  /// No description provided for @nvLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié'**
  String get nvLinkCopied;

  /// No description provided for @nvOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get nvOpen;

  /// No description provided for @nvMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get nvMore;

  /// No description provided for @nvNotSecure.
  ///
  /// In fr, this message translates to:
  /// **'Non sécurisé'**
  String get nvNotSecure;

  /// No description provided for @nvErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Page inaccessible'**
  String get nvErrorTitle;

  /// No description provided for @nvErrorBody.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n\'a pas pu joindre ce site. Le réseau maillé ne transporte pas le Web : il faut une connexion Internet.'**
  String get nvErrorBody;

  /// No description provided for @nvRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get nvRetry;

  /// No description provided for @ciLinks.
  ///
  /// In fr, this message translates to:
  /// **'Liens'**
  String get ciLinks;

  /// No description provided for @chatsFilterNearby.
  ///
  /// In fr, this message translates to:
  /// **'À proximité'**
  String get chatsFilterNearby;


  /// No description provided for @chProxTitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet marche aussi sans Internet'**
  String get chProxTitle;

  /// No description provided for @chProxActive.
  ///
  /// In fr, this message translates to:
  /// **'Des appareils Droplet sont à portée'**
  String get chProxActive;

  /// No description provided for @chProxBody.
  ///
  /// In fr, this message translates to:
  /// **'Les téléphones proches se relaient les messages. Plus vous êtes nombreux autour, plus ils vont loin.'**
  String get chProxBody;

  /// No description provided for @chProxSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir autour de moi'**
  String get chProxSee;

  /// No description provided for @chStickerPreview.
  ///
  /// In fr, this message translates to:
  /// **'Sticker'**
  String get chStickerPreview;

  /// No description provided for @edCrop.
  ///
  /// In fr, this message translates to:
  /// **'Recadrer'**
  String get edCrop;

  /// No description provided for @edRotate.
  ///
  /// In fr, this message translates to:
  /// **'Pivoter'**
  String get edRotate;

  /// No description provided for @edFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get edFilters;

  /// No description provided for @edAdjust.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster'**
  String get edAdjust;

  /// No description provided for @edText.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get edText;

  /// No description provided for @edDraw.
  ///
  /// In fr, this message translates to:
  /// **'Dessin'**
  String get edDraw;

  /// No description provided for @edTrim.
  ///
  /// In fr, this message translates to:
  /// **'Découper'**
  String get edTrim;

  /// No description provided for @edBrightness.
  ///
  /// In fr, this message translates to:
  /// **'Luminosité'**
  String get edBrightness;

  /// No description provided for @edContrast.
  ///
  /// In fr, this message translates to:
  /// **'Contraste'**
  String get edContrast;

  /// No description provided for @edSaturation.
  ///
  /// In fr, this message translates to:
  /// **'Saturation'**
  String get edSaturation;

  /// No description provided for @edWarmth.
  ///
  /// In fr, this message translates to:
  /// **'Chaleur'**
  String get edWarmth;

  /// No description provided for @edVignette.
  ///
  /// In fr, this message translates to:
  /// **'Vignette'**
  String get edVignette;

  /// No description provided for @edIntensity.
  ///
  /// In fr, this message translates to:
  /// **'Intensité'**
  String get edIntensity;

  /// No description provided for @edUndo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la retouche'**
  String get edUndo;

  /// No description provided for @edDone.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get edDone;

  /// No description provided for @edTextHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez…'**
  String get edTextHint;

  /// No description provided for @edDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get edDelete;

  /// No description provided for @edOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Original'**
  String get edOriginal;

  /// No description provided for @edStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style'**
  String get edStyle;

  /// No description provided for @edBackground.
  ///
  /// In fr, this message translates to:
  /// **'Fond'**
  String get edBackground;

  /// No description provided for @stNotificationsHeader.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get stNotificationsHeader;

  /// No description provided for @stNotifPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du contenu'**
  String get stNotifPreview;

  /// No description provided for @stNotifPreviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le texte du message s\'affiche dans la notification. Coupé, l\'écran verrouillé annonce seulement un nouveau message.'**
  String get stNotifPreviewSubtitle;

  /// No description provided for @stSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un réglage'**
  String get stSearchHint;

  /// No description provided for @stSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun réglage ne correspond'**
  String get stSearchEmpty;

  /// No description provided for @chMentionAllSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prévenir tout le groupe'**
  String get chMentionAllSubtitle;

  /// No description provided for @vuOnce.
  ///
  /// In fr, this message translates to:
  /// **'Vue unique'**
  String get vuOnce;

  /// No description provided for @vuOpened.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get vuOpened;

  /// No description provided for @vuPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get vuPhoto;

  /// No description provided for @vuVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get vuVideo;

  /// No description provided for @vuMissing.
  ///
  /// In fr, this message translates to:
  /// **'Ce média n\'est pas encore arrivé'**
  String get vuMissing;

  /// No description provided for @pollClosed.
  ///
  /// In fr, this message translates to:
  /// **'Sondage terminé'**
  String get pollClosed;

  /// No description provided for @pollEndsAt.
  ///
  /// In fr, this message translates to:
  /// **'Se termine à {quand}'**
  String pollEndsAt(String quand);

  /// No description provided for @vuVoice.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal'**
  String get vuVoice;

  /// No description provided for @apPatternsHeader.
  ///
  /// In fr, this message translates to:
  /// **'Motifs du fond'**
  String get apPatternsHeader;

  /// No description provided for @apPatternDroplet.
  ///
  /// In fr, this message translates to:
  /// **'Droplet'**
  String get apPatternDroplet;

  /// No description provided for @apPatternGames.
  ///
  /// In fr, this message translates to:
  /// **'Jeux'**
  String get apPatternGames;

  /// No description provided for @apPatternHome.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get apPatternHome;

  /// No description provided for @apPatternGarden.
  ///
  /// In fr, this message translates to:
  /// **'Jardin'**
  String get apPatternGarden;

  /// No description provided for @imTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages importants'**
  String get imTitle;

  /// No description provided for @imSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous avez mis de côté'**
  String get imSubtitle;

  /// No description provided for @imAdd.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme important'**
  String get imAdd;

  /// No description provided for @imRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des importants'**
  String get imRemove;

  /// No description provided for @imAdded.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux importants'**
  String get imAdded;

  /// No description provided for @imRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Retiré des importants'**
  String get imRemoved;

  /// No description provided for @imEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez longuement sur un message pour le marquer comme important et le retrouver ici plus tard.'**
  String get imEmptyBody;

  /// No description provided for @imClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout retirer'**
  String get imClearAll;

  /// No description provided for @imClearAllBody.
  ///
  /// In fr, this message translates to:
  /// **'Les messages restent dans leurs discussions ; seules les étoiles sont retirées.'**
  String get imClearAllBody;

  /// No description provided for @imClear.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get imClear;

  /// No description provided for @imYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get imYou;

  /// No description provided for @imUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get imUnknown;

  /// No description provided for @apPatternsFooter.
  ///
  /// In fr, this message translates to:
  /// **'Le motif se pose derrière toutes vos discussions.'**
  String get apPatternsFooter;

  /// No description provided for @grCreatedNoMessages.
  ///
  /// In fr, this message translates to:
  /// **'Groupe créé · aucun message'**
  String get grCreatedNoMessages;

  /// No description provided for @chatsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la discussion'**
  String get chatsDelete;

  /// No description provided for @chatsDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Les messages disparaissent de ce téléphone. Sans serveur, personne ne peut les retirer de celui des autres.'**
  String get chatsDeleteBody;

  /// No description provided for @chatsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get chatsDeleteConfirm;

  /// No description provided for @chatsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Discussion supprimée'**
  String get chatsDeleted;

  /// No description provided for @chatsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la discussion avec {nom} ?'**
  String chatsDeleteTitle(String nom);

  /// No description provided for @chatsDocument.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get chatsDocument;

  /// No description provided for @epTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages éphémères'**
  String get epTitle;

  /// No description provided for @epHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Activez les messages éphémères dans cette discussion'**
  String get epHeadline;

  /// No description provided for @epBody.
  ///
  /// In fr, this message translates to:
  /// **'Les nouveaux messages porteront leur date de péremption : ils disparaîtront des deux téléphones au bout de la durée choisie.'**
  String get epBody;

  /// No description provided for @epDelayHeader.
  ///
  /// In fr, this message translates to:
  /// **'Délai avant disparition'**
  String get epDelayHeader;

  /// No description provided for @epHours24.
  ///
  /// In fr, this message translates to:
  /// **'24 heures'**
  String get epHours24;

  /// No description provided for @epDays7.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get epDays7;

  /// No description provided for @epDays90.
  ///
  /// In fr, this message translates to:
  /// **'90 jours'**
  String get epDays90;

  /// No description provided for @epOff.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get epOff;

  /// No description provided for @epFooter.
  ///
  /// In fr, this message translates to:
  /// **'Le réglage ne touche pas aux messages déjà envoyés : chacun garde la durée qu\'il portait au départ.'**
  String get epFooter;

  /// No description provided for @chOnlineNow.
  ///
  /// In fr, this message translates to:
  /// **'En ligne · Internet'**
  String get chOnlineNow;

  /// No description provided for @chInternetMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Par Internet il y a {count} min'**
  String chInternetMinutesAgo(int count);

  /// No description provided for @chInternetHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Par Internet il y a {count} h'**
  String chInternetHoursAgo(int count);

  /// No description provided for @chInternetDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Par Internet il y a {count} j'**
  String chInternetDaysAgo(int count);

  /// No description provided for @pdfMissing.
  ///
  /// In fr, this message translates to:
  /// **'Ce document n\'est pas sur ce téléphone.'**
  String get pdfMissing;

  /// No description provided for @pdfUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Ce PDF est illisible — il est peut-être arrivé incomplet.'**
  String get pdfUnreadable;

  /// No description provided for @giDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get giDescription;

  /// No description provided for @giDescriptionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une description'**
  String get giDescriptionAdd;

  /// No description provided for @giDescriptionNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune description'**
  String get giDescriptionNone;

  /// No description provided for @giDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'De quoi parle ce groupe ?'**
  String get giDescriptionHint;

  /// No description provided for @giOnlyAdminsSend.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les administrateurs écrivent'**
  String get giOnlyAdminsSend;

  /// No description provided for @giOnlyAdminsSendBody.
  ///
  /// In fr, this message translates to:
  /// **'Les autres membres lisent sans pouvoir répondre.'**
  String get giOnlyAdminsSendBody;

  /// No description provided for @giSearchMembers.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un membre'**
  String get giSearchMembers;

  /// No description provided for @chOnlyAdminsCanWrite.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les administrateurs peuvent écrire dans ce groupe'**
  String get chOnlyAdminsCanWrite;

  /// No description provided for @grCreatedBy.
  ///
  /// In fr, this message translates to:
  /// **'{nom} a créé le groupe'**
  String grCreatedBy(String nom);

  /// No description provided for @grAddedYou.
  ///
  /// In fr, this message translates to:
  /// **'{nom} vous a ajouté'**
  String grAddedYou(String nom);

  /// No description provided for @grMemberGone.
  ///
  /// In fr, this message translates to:
  /// **'{nom} ne fait plus partie du groupe'**
  String grMemberGone(String nom);

  /// No description provided for @grAdded.
  ///
  /// In fr, this message translates to:
  /// **'{qui} a ajouté {nom}'**
  String grAdded(String qui, String nom);

  /// No description provided for @giQrInvite.
  ///
  /// In fr, this message translates to:
  /// **'Code QR'**
  String get giQrInvite;

  /// No description provided for @giQrRenew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code'**
  String get giQrRenew;

  /// No description provided for @giQrRenewed.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code créé, l\'ancien ne vaut plus'**
  String get giQrRenewed;

  /// No description provided for @giQrExpired.
  ///
  /// In fr, this message translates to:
  /// **'Ce code a expiré'**
  String get giQrExpired;

  /// No description provided for @giQrExplainer.
  ///
  /// In fr, this message translates to:
  /// **'Ce code ne contient aucune clé. Il permet seulement de demander à entrer : c\'est votre téléphone qui accepte, ou non.'**
  String get giQrExplainer;

  /// No description provided for @giQrAlreadyMember.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes déjà dans ce groupe'**
  String get giQrAlreadyMember;

  /// No description provided for @giQrNeedContact.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord la personne qui vous invite'**
  String get giQrNeedContact;

  /// No description provided for @giQrRequestFailed.
  ///
  /// In fr, this message translates to:
  /// **'La demande n\'a pas pu partir'**
  String get giQrRequestFailed;

  /// No description provided for @giQrRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée à {nom}'**
  String giQrRequestSent(String nom);

  /// No description provided for @giQrValidHours.
  ///
  /// In fr, this message translates to:
  /// **'Valable encore {count} h'**
  String giQrValidHours(int count);

  /// No description provided for @giQrValidMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Valable encore {count} min'**
  String giQrValidMinutes(int count);

  /// No description provided for @cvNearby.
  ///
  /// In fr, this message translates to:
  /// **'À portée'**
  String get cvNearby;

  /// No description provided for @cvInternet.
  ///
  /// In fr, this message translates to:
  /// **'Internet'**
  String get cvInternet;

  /// No description provided for @cvWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get cvWaiting;

  /// No description provided for @cvOutOfReach.
  ///
  /// In fr, this message translates to:
  /// **'Hors de portée'**
  String get cvOutOfReach;

  /// No description provided for @chWillSendWhenNearby.
  ///
  /// In fr, this message translates to:
  /// **'Partira dès qu\'il sera à portée'**
  String get chWillSendWhenNearby;

  /// No description provided for @cvHops.
  ///
  /// In fr, this message translates to:
  /// **'{count} sauts'**
  String cvHops(int count);

  /// No description provided for @nwSeenSection.
  ///
  /// In fr, this message translates to:
  /// **'Vus'**
  String get nwSeenSection;

  /// No description provided for @nwReceivedHeader.
  ///
  /// In fr, this message translates to:
  /// **'Reçus'**
  String get nwReceivedHeader;

  /// No description provided for @avTranslateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Traduction'**
  String get avTranslateTitle;

  /// No description provided for @avTranslateShort.
  ///
  /// In fr, this message translates to:
  /// **'Comprendre sans quitter l'app'**
  String get avTranslateShort;

  /// No description provided for @avTranslateLong.
  ///
  /// In fr, this message translates to:
  /// **'Le message est traduit sur votre téléphone : son contenu ne part chez personne, pas même chez un traducteur. L'original reste à un toucher, parce qu'une traduction n'est jamais tout à fait le texte.'**
  String get avTranslateLong;

  /// No description provided for @apStickerQ.
  ///
  /// In fr, this message translates to:
  /// **'Tu as un autocollant pour ça ?'**
  String get apStickerQ;

  /// No description provided for @apOnline.
  ///
  /// In fr, this message translates to:
  /// **'en ligne'**
  String get apOnline;

  /// No description provided for @apMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get apMessage;

  /// No description provided for @apAutoTranslated.
  ///
  /// In fr, this message translates to:
  /// **'Traduit automatiquement'**
  String get apAutoTranslated;

  /// No description provided for @apBgSend.
  ///
  /// In fr, this message translates to:
  /// **'Regarde le fond 😍'**
  String get apBgSend;

  /// No description provided for @apBgA.
  ///
  /// In fr, this message translates to:
  /// **'Tu as changé quelque chose ?'**
  String get apBgA;

  /// No description provided for @apBgB.
  ///
  /// In fr, this message translates to:
  /// **'Il bouge à chaque message 😮'**
  String get apBgB;

  /// No description provided for @apFormatQ.
  ///
  /// In fr, this message translates to:
  /// **'On se retrouve où ?'**
  String get apFormatQ;

  /// No description provided for @apFormatDemo.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous **à 18 h** devant le __grand marché__, code `4821`. Surprise : ||un gâteau||'**
  String get apFormatDemo;

  /// No description provided for @apVoiceQ.
  ///
  /// In fr, this message translates to:
  /// **'Tu es où ?'**
  String get apVoiceQ;

  /// No description provided for @apVoiceText.
  ///
  /// In fr, this message translates to:
  /// **'Je suis devant la pharmacie, je t'attends jusqu'à 18 h.'**
  String get apVoiceText;

  /// No description provided for @apTransQ.
  ///
  /// In fr, this message translates to:
  /// **'Hey, tout est prêt ?'**
  String get apTransQ;

  /// No description provided for @apTransSource.
  ///
  /// In fr, this message translates to:
  /// **'Yes! See you tomorrow at the airport, gate 12 at 9am.'**
  String get apTransSource;

  /// No description provided for @apTransResult.
  ///
  /// In fr, this message translates to:
  /// **'Oui ! On se voit demain à l'aéroport, porte 12 à 9 h.'**
  String get apTransResult;

  /// No description provided for @hlpDataOnDevice.
  ///
  /// In fr, this message translates to:
  /// **'SUR VOTRE TÉLÉPHONE'**
  String get hlpDataOnDevice;

  /// No description provided for @hlpDataServers.
  ///
  /// In fr, this message translates to:
  /// **'CE QUI PASSE PAR UN SERVEUR'**
  String get hlpDataServers;

  /// No description provided for @hlpDataServersFooter.
  ///
  /// In fr, this message translates to:
  /// **'Sans Internet, aucun de ces serveurs n'intervient : les téléphones se parlent directement.'**
  String get hlpDataServersFooter;

  /// No description provided for @hlpDataNone.
  ///
  /// In fr, this message translates to:
  /// **'CE QUE DROPLET NE DEMANDE PAS'**
  String get hlpDataNone;

  /// No description provided for @hlpRowKeys.
  ///
  /// In fr, this message translates to:
  /// **'Votre identité'**
  String get hlpRowKeys;

  /// No description provided for @hlpRowKeysBody.
  ///
  /// In fr, this message translates to:
  /// **'Une paire de clés fabriquée ici, jamais envoyée'**
  String get hlpRowKeysBody;

  /// No description provided for @hlpRowMessages.
  ///
  /// In fr, this message translates to:
  /// **'Vos messages'**
  String get hlpRowMessages;

  /// No description provided for @hlpRowMessagesBody.
  ///
  /// In fr, this message translates to:
  /// **'Dans l'espace privé de l'app, effacés à la désinstallation'**
  String get hlpRowMessagesBody;

  /// No description provided for @hlpRowProfile.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo et photo'**
  String get hlpRowProfile;

  /// No description provided for @hlpRowProfileBody.
  ///
  /// In fr, this message translates to:
  /// **'Ne partent qu'aux personnes à qui vous écrivez'**
  String get hlpRowProfileBody;

  /// No description provided for @hlpRowSettings.
  ///
  /// In fr, this message translates to:
  /// **'Vos réglages'**
  String get hlpRowSettings;

  /// No description provided for @hlpRowSettingsBody.
  ///
  /// In fr, this message translates to:
  /// **'Fonds, langue, notifications — tout reste ici'**
  String get hlpRowSettingsBody;

  /// No description provided for @hlpRowLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal d'erreurs'**
  String get hlpRowLog;

  /// No description provided for @hlpRowLogBody.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier local, qui ne part jamais tout seul'**
  String get hlpRowLogBody;

  /// No description provided for @hlpRowDirectory.
  ///
  /// In fr, this message translates to:
  /// **'Annuaire'**
  String get hlpRowDirectory;

  /// No description provided for @hlpRowDirectoryBody.
  ///
  /// In fr, this message translates to:
  /// **'Voit un pseudo et un identifiant public. Requêtes via Tor : pas votre IP réelle'**
  String get hlpRowDirectoryBody;

  /// No description provided for @hlpRowMailbox.
  ///
  /// In fr, this message translates to:
  /// **'Boîte aux lettres'**
  String get hlpRowMailbox;

  /// No description provided for @hlpRowMailboxBody.
  ///
  /// In fr, this message translates to:
  /// **'Garde un message chiffré jusqu'à sa remise. Ne peut pas le lire'**
  String get hlpRowMailboxBody;

  /// No description provided for @hlpRowSignalling.
  ///
  /// In fr, this message translates to:
  /// **'Mise en relation'**
  String get hlpRowSignalling;

  /// No description provided for @hlpRowSignallingBody.
  ///
  /// In fr, this message translates to:
  /// **'Voit deux identifiants le temps d'établir l'appel. Aucune voix n'y passe'**
  String get hlpRowSignallingBody;

  /// No description provided for @hlpRowRelay.
  ///
  /// In fr, this message translates to:
  /// **'Relais'**
  String get hlpRowRelay;

  /// No description provided for @hlpRowRelayBody.
  ///
  /// In fr, this message translates to:
  /// **'Fait suivre le son chiffré quand la liaison directe échoue'**
  String get hlpRowRelayBody;

  /// No description provided for @hlpNonePhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get hlpNonePhone;

  /// No description provided for @hlpNoneEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get hlpNoneEmail;

  /// No description provided for @hlpNoneContacts.
  ///
  /// In fr, this message translates to:
  /// **'Votre carnet d'adresses'**
  String get hlpNoneContacts;

  /// No description provided for @hlpNoneLocation.
  ///
  /// In fr, this message translates to:
  /// **'Votre position'**
  String get hlpNoneLocation;

  /// No description provided for @hlpNoneAds.
  ///
  /// In fr, this message translates to:
  /// **'Publicité et traceurs'**
  String get hlpNoneAds;

  /// No description provided for @hlpNoneAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Mesure d'audience'**
  String get hlpNoneAnalytics;

  /// No description provided for @hlpQOffline.
  ///
  /// In fr, this message translates to:
  /// **'Comment Droplet marche sans Internet ?'**
  String get hlpQOffline;

  /// No description provided for @hlpAOffline.
  ///
  /// In fr, this message translates to:
  /// **'Les téléphones se parlent directement, en Bluetooth et en Wi-Fi. Un message peut aussi voyager de téléphone en téléphone jusqu'au destinataire, sans jamais passer par un serveur.'**
  String get hlpAOffline;

  /// No description provided for @hlpQCrypto.
  ///
  /// In fr, this message translates to:
  /// **'Mes messages sont-ils vraiment chiffrés ?'**
  String get hlpQCrypto;

  /// No description provided for @hlpACrypto.
  ///
  /// In fr, this message translates to:
  /// **'Oui, de bout en bout, avec le protocole Signal. La clé n'existe que sur les deux téléphones. Ni un relais, ni la boîte aux lettres, ni nous ne pouvons ouvrir un message.'**
  String get hlpACrypto;

  /// No description provided for @hlpQNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi Droplet ne demande ni numéro ni e-mail ?'**
  String get hlpQNoAccount;

  /// No description provided for @hlpANoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Parce qu'il n'en a pas besoin. Votre identité est une clé fabriquée sur votre téléphone. Rien à créer, rien à vérifier, et rien à voler ailleurs.'**
  String get hlpANoAccount;

  /// No description provided for @hlpQPending.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi mon message reste en attente ?'**
  String get hlpQPending;

  /// No description provided for @hlpAPending.
  ///
  /// In fr, this message translates to:
  /// **'Personne n'est encore à portée et Internet n'est pas là. Le message attend dans le téléphone et part dès qu'un chemin s'ouvre — vous n'avez rien à refaire.'**
  String get hlpAPending;

  /// No description provided for @hlpQAddSomeone.
  ///
  /// In fr, this message translates to:
  /// **'Comment ajouter quelqu'un ?'**
  String get hlpQAddSomeone;

  /// No description provided for @hlpAAddSomeone.
  ///
  /// In fr, this message translates to:
  /// **'Approchez vos téléphones : la personne apparaît toute seule. À distance, partagez votre lien d'invitation, ou scannez son QR code.'**
  String get hlpAAddSomeone;

  /// No description provided for @hlpQUninstall.
  ///
  /// In fr, this message translates to:
  /// **'Que se passe-t-il si je désinstalle l'application ?'**
  String get hlpQUninstall;

  /// No description provided for @hlpAUninstall.
  ///
  /// In fr, this message translates to:
  /// **'Tout est effacé : messages, contacts, identité. Il n'existe aucune copie ailleurs, donc aucune restauration. Exportez vos réglages avant, si vous changez de téléphone.'**
  String get hlpAUninstall;

  /// No description provided for @hlpQBattery.
  ///
  /// In fr, this message translates to:
  /// **'Est-ce que Droplet vide ma batterie ?'**
  String get hlpQBattery;

  /// No description provided for @hlpABattery.
  ///
  /// In fr, this message translates to:
  /// **'La recherche d'appareils autour de vous consomme. Dans les réglages, vous pouvez la réduire ou ne l'activer qu'au premier plan.'**
  String get hlpABattery;

  /// No description provided for @hlpQReport.
  ///
  /// In fr, this message translates to:
  /// **'Comment signaler un problème ?'**
  String get hlpQReport;

  /// No description provided for @hlpAReport.
  ///
  /// In fr, this message translates to:
  /// **'Depuis Contact et assistance. Vous verrez le texte exact qui sera envoyé avant qu'il parte — rien ne quitte votre téléphone sans vous.'**
  String get hlpAReport;

  /// No description provided for @svLikeStatus.
  ///
  /// In fr, this message translates to:
  /// **'Aimer le statut'**
  String get svLikeStatus;

  /// No description provided for @svUnlikeStatus.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le j'aime'**
  String get svUnlikeStatus;

  /// No description provided for @stAddPhotoSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo de profil'**
  String get stAddPhotoSemantics;

  /// No description provided for @stChangePhotoSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo de profil'**
  String get stChangePhotoSemantics;

  /// No description provided for @scOverheat.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone en surchauffe — Android a coupé l'encodeur vidéo. Laissez-le refroidir quelques minutes.'**
  String get scOverheat;

  /// No description provided for @scTooHeavy.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop lourd — {mo} Mo maximum pour traverser le réseau local.'**
  String scTooHeavy(int mo);

  /// No description provided for @scUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Ce format n'est pas pris en charge pour un statut.'**
  String get scUnsupported;

  /// No description provided for @scUnreadableFile.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce fichier'**
  String get scUnreadableFile;

  /// No description provided for @scUnreadableTrack.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce morceau'**
  String get scUnreadableTrack;

  /// No description provided for @scNothingCaptured.
  ///
  /// In fr, this message translates to:
  /// **'L'enregistrement n'a rien capturé — réessayez.'**
  String get scNothingCaptured;

  /// No description provided for @scVideoTrimmed.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo raccourcie à 1 min 30 — seul le début est publié.'**
  String get scVideoTrimmed;

  /// No description provided for @scUnreadableVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo illisible'**
  String get scUnreadableVideo;

  /// No description provided for @chAiMe.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get chAiMe;

  /// No description provided for @chAiCtxIntro.
  ///
  /// In fr, this message translates to:
  /// **'Voici la fin d'une conversation dans Droplet entre l'utilisateur (« Moi ») et {pseudo} :'**
  String chAiCtxIntro(String pseudo);

  /// No description provided for @chAiCtxTask.
  ///
  /// In fr, this message translates to:
  /// **'L'utilisateur veut de l'aide pour répondre à {pseudo}. Propose une réponse courte et naturelle, écrite en {langue}, à la première personne, comme s'il l'envoyait lui-même. Ne donne que la réponse proposée, sans préambule.'**
  String chAiCtxTask(String pseudo, String langue);

  /// No description provided for @hlpSectionHeader.
  ///
  /// In fr, this message translates to:
  /// **'Aide et confidentialité'**
  String get hlpSectionHeader;

  /// No description provided for @hlpPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get hlpPrivacy;

  /// No description provided for @hlpData.
  ///
  /// In fr, this message translates to:
  /// **'Vos données'**
  String get hlpData;

  /// No description provided for @hlpDataValue.
  ///
  /// In fr, this message translates to:
  /// **'Rien ne part'**
  String get hlpDataValue;

  /// No description provided for @hlpContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact et assistance'**
  String get hlpContact;

  /// No description provided for @hlpPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get hlpPrivacyTitle;

  /// No description provided for @hlpUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour le {date}'**
  String hlpUpdated(String date);

  /// No description provided for @hlpOnlyFrEn.
  ///
  /// In fr, this message translates to:
  /// **'Ce texte n'existe qu'en français et en anglais. Un document juridique traduit approximativement engagerait plus qu'il n'aiderait.'**
  String get hlpOnlyFrEn;

  /// No description provided for @hlpReadInEnglish.
  ///
  /// In fr, this message translates to:
  /// **'Lire en anglais'**
  String get hlpReadInEnglish;

  /// No description provided for @hlpReadInFrench.
  ///
  /// In fr, this message translates to:
  /// **'Lire en français'**
  String get hlpReadInFrench;

  /// No description provided for @hlpDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos données'**
  String get hlpDataTitle;

  /// No description provided for @hlpDataLead.
  ///
  /// In fr, this message translates to:
  /// **'Ce que Droplet sait de vous, ligne par ligne. Rien ici n'est une promesse : chaque ligne correspond à du code.'**
  String get hlpDataLead;

  /// No description provided for @hlpStays.
  ///
  /// In fr, this message translates to:
  /// **'Ne quitte jamais l'appareil'**
  String get hlpStays;

  /// No description provided for @hlpLeaves.
  ///
  /// In fr, this message translates to:
  /// **'Passe par un serveur'**
  String get hlpLeaves;

  /// No description provided for @hlpNever.
  ///
  /// In fr, this message translates to:
  /// **'N'existe pas'**
  String get hlpNever;

  /// No description provided for @hlpCountTracking.
  ///
  /// In fr, this message translates to:
  /// **'donnée pour vous suivre'**
  String get hlpCountTracking;

  /// No description provided for @hlpCountAccount.
  ///
  /// In fr, this message translates to:
  /// **'compte à créer'**
  String get hlpCountAccount;

  /// No description provided for @hlpCountServers.
  ///
  /// In fr, this message translates to:
  /// **'serveurs, et on dit lesquels'**
  String get hlpCountServers;

  /// No description provided for @hlpHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get hlpHelpTitle;

  /// No description provided for @hlpSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get hlpSearchHint;

  /// No description provided for @hlpNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réponse ne contient ce mot. Écrivez-nous : c'est peut-être une question qui manque ici.'**
  String get hlpNoResult;

  /// No description provided for @hlpStillStuckFooter.
  ///
  /// In fr, this message translates to:
  /// **'Si la réponse n'y est pas, on répond en personne.'**
  String get hlpStillStuckFooter;

  /// No description provided for @hlpContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get hlpContactTitle;

  /// No description provided for @hlpContactLead.
  ///
  /// In fr, this message translates to:
  /// **'Une question, un problème, une idée. On lit tout.'**
  String get hlpContactLead;

  /// No description provided for @hlpBeforeWriting.
  ///
  /// In fr, this message translates to:
  /// **'Avant d'écrire'**
  String get hlpBeforeWriting;

  /// No description provided for @hlpHelpRowBody.
  ///
  /// In fr, this message translates to:
  /// **'Huit réponses, consultables sans Internet'**
  String get hlpHelpRowBody;

  /// No description provided for @hlpWriteUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous écrire'**
  String get hlpWriteUs;

  /// No description provided for @hlpWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get hlpWhatsApp;

  /// No description provided for @hlpEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get hlpEmail;

  /// No description provided for @hlpWhatsAppHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, j'utilise Droplet et j'ai une question :'**
  String get hlpWhatsAppHello;

  /// No description provided for @hlpEmailSubject.
  ///
  /// In fr, this message translates to:
  /// **'Droplet — question'**
  String get hlpEmailSubject;

  /// No description provided for @hlpWhatsAppMissing.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp est introuvable. Le numéro {numero} est copié.'**
  String hlpWhatsAppMissing(String numero);

  /// No description provided for @hlpEmailCopied.
  ///
  /// In fr, this message translates to:
  /// **'L'adresse {adresse} est copiée.'**
  String hlpEmailCopied(String adresse);

  /// No description provided for @hlpReportHeader.
  ///
  /// In fr, this message translates to:
  /// **'Un problème'**
  String get hlpReportHeader;

  /// No description provided for @hlpReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get hlpReport;

  /// No description provided for @hlpReportBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous verrez ce qui part avant que ça parte'**
  String get hlpReportBody;

  /// No description provided for @hlpReportFooter.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n'envoie aucun rapport tout seul : il n'a aucun serveur pour ça. Un problème ne nous parvient que si vous nous l'envoyez.'**
  String get hlpReportFooter;

  /// No description provided for @hlpReportSubject.
  ///
  /// In fr, this message translates to:
  /// **'Droplet — signalement'**
  String get hlpReportSubject;

  /// No description provided for @hlpReportSheetLead.
  ///
  /// In fr, this message translates to:
  /// **'Dites ce qui s'est passé. Le texte exact qui partira s'affiche en dessous.'**
  String get hlpReportSheetLead;

  /// No description provided for @hlpReportHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que je faisais, et ce qui est arrivé…'**
  String get hlpReportHint;

  /// No description provided for @hlpAttachLog.
  ///
  /// In fr, this message translates to:
  /// **'Joindre le journal d'erreurs'**
  String get hlpAttachLog;

  /// No description provided for @hlpWhatWillBeSent.
  ///
  /// In fr, this message translates to:
  /// **'CE QUI SERA ENVOYÉ'**
  String get hlpWhatWillBeSent;

  /// No description provided for @hlpLogExcerpt.
  ///
  /// In fr, this message translates to:
  /// **'Journal (fin) :'**
  String get hlpLogExcerpt;

  /// No description provided for @hlpCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get hlpCopy;

  /// No description provided for @hlpCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get hlpCopied;

  /// No description provided for @hlpOnePerson.
  ///
  /// In fr, this message translates to:
  /// **'Droplet est fait par une personne, pas par un service d'assistance. La réponse peut prendre un jour ou deux — elle arrive.'**
  String get hlpOnePerson;

  /// No description provided for @avSectionHeader.
  ///
  /// In fr, this message translates to:
  /// **'Ce que Pro apporte'**
  String get avSectionHeader;

  /// No description provided for @avUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer Droplet Pro'**
  String get avUnlock;

  /// No description provided for @avVoiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vocaux en texte'**
  String get avVoiceTitle;

  /// No description provided for @avVoiceShort.
  ///
  /// In fr, this message translates to:
  /// **'Lire un vocal sans l\'écouter'**
  String get avVoiceShort;

  /// No description provided for @avVoiceLong.
  ///
  /// In fr, this message translates to:
  /// **'La transcription se fait sur votre téléphone, hors ligne. Le vocal ne part nulle part, et vous le lisez en réunion, dans le bus, ou quand le réseau n\'est pas là.'**
  String get avVoiceLong;

  /// No description provided for @avFormatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise en forme'**
  String get avFormatTitle;

  /// No description provided for @avFormatShort.
  ///
  /// In fr, this message translates to:
  /// **'Gras, italique, code, spoiler'**
  String get avFormatShort;

  /// No description provided for @avFormatLong.
  ///
  /// In fr, this message translates to:
  /// **'Un mot en gras, une ligne de code, un passage masqué qu\'on découvre d\'un toucher : votre message dit exactement ce que vous vouliez, et rien d\'autre.'**
  String get avFormatLong;

  /// No description provided for @avWallpaperTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fonds et motifs'**
  String get avWallpaperTitle;

  /// No description provided for @avWallpaperShort.
  ///
  /// In fr, this message translates to:
  /// **'Toute la galerie, et les quatre packs'**
  String get avWallpaperShort;

  /// No description provided for @avWallpaperLong.
  ///
  /// In fr, this message translates to:
  /// **'Chaque fond est dessiné à la main, chaque motif vérifié au rendu avant d\'entrer dans l\'app. Droplet, Jeux, Maison, Jardin : votre écran de discussion ne ressemble à aucun autre.'**
  String get avWallpaperLong;

  /// No description provided for @avStickersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autocollants animés'**
  String get avStickersTitle;

  /// No description provided for @avStickersShort.
  ///
  /// In fr, this message translates to:
  /// **'La goutte Droplet, en mouvement'**
  String get avStickersShort;

  /// No description provided for @avStickersLong.
  ///
  /// In fr, this message translates to:
  /// **'Des autocollants dessinés pour Droplet, animés image par image, et légers : ils voyagent même par le maillage, sans Internet.'**
  String get avStickersLong;

  /// No description provided for @avIconTitle.
  ///
  /// In fr, this message translates to:
  /// **'Icônes d\'app'**
  String get avIconTitle;

  /// No description provided for @avIconShort.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'icône sur l\'écran d\'accueil'**
  String get avIconShort;

  /// No description provided for @avIconLong.
  ///
  /// In fr, this message translates to:
  /// **'Une app de messagerie discrète, ça commence par son icône. Choisissez celle qui vous ressemble, ou celle qu\'on remarque le moins.'**
  String get avIconLong;

  /// No description provided for @avBadgeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badge Pro'**
  String get avBadgeTitle;

  /// No description provided for @avBadgeShort.
  ///
  /// In fr, this message translates to:
  /// **'Il accompagne votre nom'**
  String get avBadgeShort;

  /// No description provided for @avBadgeLong.
  ///
  /// In fr, this message translates to:
  /// **'Il ne donne aucun pouvoir sur les autres. Il dit seulement que vous avez payé pour que Droplet reste sans publicité, sans abonnement obligatoire et sans revente de données.'**
  String get avBadgeLong;

  /// No description provided for @sgTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockage du groupe'**
  String get sgTitle;

  /// No description provided for @sgEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier n\'a encore été partagé dans ce groupe.'**
  String get sgEmpty;

  /// No description provided for @sgByAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Qui envoie le plus'**
  String get sgByAuthor;

  /// No description provided for @sgFiles.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers'**
  String get sgFiles;

  /// No description provided for @sgSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Les plus récents'**
  String get sgSortRecent;

  /// No description provided for @sgSortHeavy.
  ///
  /// In fr, this message translates to:
  /// **'Les plus lourds'**
  String get sgSortHeavy;

  /// No description provided for @sgNotOnDevice.
  ///
  /// In fr, this message translates to:
  /// **'Pas ici'**
  String get sgNotOnDevice;

  /// No description provided for @giPhotoChanged.
  ///
  /// In fr, this message translates to:
  /// **'Photo du groupe modifiée'**
  String get giPhotoChanged;

  /// No description provided for @giPhotoFailed.
  ///
  /// In fr, this message translates to:
  /// **'Cette image n\'a pas pu être enregistrée'**
  String get giPhotoFailed;

  /// No description provided for @sgTotal.
  ///
  /// In fr, this message translates to:
  /// **'{count} fichiers partagés'**
  String sgTotal(int count);

  /// No description provided for @vrTitle.
  ///
  /// In fr, this message translates to:
  /// **'Salon vocal'**
  String get vrTitle;

  /// No description provided for @vrJoin.
  ///
  /// In fr, this message translates to:
  /// **'Entrer'**
  String get vrJoin;

  /// No description provided for @vrBack.
  ///
  /// In fr, this message translates to:
  /// **'Revenir'**
  String get vrBack;

  /// No description provided for @vrStart.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir un salon vocal'**
  String get vrStart;

  /// No description provided for @vrNeedsInternet.
  ///
  /// In fr, this message translates to:
  /// **'Un salon vocal demande Internet : le maillage porte un message qui attend, pas vingt voix en même temps.'**
  String get vrNeedsInternet;

  /// No description provided for @vrUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur d'appels est injoignable pour le moment.'**
  String get vrUnreachable;

  /// No description provided for @vrFull.
  ///
  /// In fr, this message translates to:
  /// **'Le salon est complet : {count} personnes au maximum.'**
  String vrFull(int count);

  /// No description provided for @vrWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente des autres…'**
  String get vrWaiting;

  /// No description provided for @vrWaitingBody.
  ///
  /// In fr, this message translates to:
  /// **'Le salon est ouvert. Les membres du groupe le voient dans la discussion et entrent quand ils sont disponibles.'**
  String get vrWaitingBody;

  /// No description provided for @vrPeople.
  ///
  /// In fr, this message translates to:
  /// **'{count} personnes dedans'**
  String vrPeople(int count);


  /// No description provided for @cvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conversations'**
  String get cvTitle;

  /// No description provided for @cvNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get cvNew;

  /// No description provided for @cvPinned.
  ///
  /// In fr, this message translates to:
  /// **'Épinglées'**
  String get cvPinned;

  /// No description provided for @cvRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récentes'**
  String get cvRecent;

  /// No description provided for @cvPin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler'**
  String get cvPin;

  /// No description provided for @cvUnpin.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus épingler'**
  String get cvUnpin;

  /// No description provided for @cvRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get cvRename;

  /// No description provided for @cvRenameHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre de la conversation'**
  String get cvRenameHint;

  /// No description provided for @cvUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Sans titre'**
  String get cvUntitled;

  /// No description provided for @cvYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get cvYesterday;

  /// No description provided for @cvSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans les conversations'**
  String get cvSearchHint;

  /// No description provided for @cvEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation pour l’instant. Posez une première question à l’assistant.'**
  String get cvEmpty;

  /// No description provided for @cvDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette conversation ?'**
  String get cvDeleteTitle;

  /// No description provided for @cvDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle ne pourra pas être récupérée : elle n’existe que sur cet appareil.'**
  String get cvDeleteBody;

  /// No description provided for @jaWorking.
  ///
  /// In fr, this message translates to:
  /// **'L’assistant travaille…'**
  String get jaWorking;

  /// No description provided for @cvNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Rien trouvé pour « {terme} ».'**
  String cvNoResult(String terme);

  /// No description provided for @cvResults.
  ///
  /// In fr, this message translates to:
  /// **'{count} résultats'**
  String cvResults(int count);

  /// No description provided for @jaSteps.
  ///
  /// In fr, this message translates to:
  /// **'{count} étapes'**
  String jaSteps(int count);

  /// No description provided for @moTitle.
  ///
  /// In fr, this message translates to:
  /// **'Où part votre message'**
  String get moTitle;

  /// No description provided for @moLocal.
  ///
  /// In fr, this message translates to:
  /// **'Local'**
  String get moLocal;

  /// No description provided for @moLocalBody.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle tourne sur ce téléphone. Rien ne sort, même sans réseau. Les réponses sont plus courtes et moins sûres.'**
  String get moLocalBody;

  /// No description provided for @moOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get moOnline;

  /// No description provided for @moOnlineBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre message part chez Groq, qui fait tourner un modèle bien plus grand. Il faut du réseau, et le message quitte le téléphone.'**
  String get moOnlineBody;

  /// No description provided for @moOnlineNoKey.
  ///
  /// In fr, this message translates to:
  /// **'Il faut une clé pour parler à un modèle distant. Touchez pour en ajouter une — c'est gratuit et ça prend une minute.'**
  String get moOnlineNoKey;

  /// No description provided for @moRetryOnline.
  ///
  /// In fr, this message translates to:
  /// **'Refaire en ligne'**
  String get moRetryOnline;

  /// No description provided for @moRetryOnlineWhy.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle local a atteint ses limites sur cette question.'**
  String get moRetryOnlineWhy;

  /// No description provided for @cpHint.
  ///
  /// In fr, this message translates to:
  /// **'Poser une question…'**
  String get cpHint;

  /// No description provided for @cpAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get cpAdd;

  /// No description provided for @cpPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get cpPhoto;

  /// No description provided for @cpCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get cpCamera;

  /// No description provided for @cpFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get cpFile;

  /// No description provided for @cpFileHint.
  ///
  /// In fr, this message translates to:
  /// **'PDF, texte, code'**
  String get cpFileHint;

  /// No description provided for @cpDictate.
  ///
  /// In fr, this message translates to:
  /// **'Dicter'**
  String get cpDictate;

  /// No description provided for @cpSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get cpSend;

  /// No description provided for @cpStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get cpStop;

  /// No description provided for @cpThinking.
  ///
  /// In fr, this message translates to:
  /// **'L’assistant réfléchit…'**
  String get cpThinking;

  /// No description provided for @amCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get amCopy;

  /// No description provided for @amCopyMarkdown.
  ///
  /// In fr, this message translates to:
  /// **'Copier en Markdown'**
  String get amCopyMarkdown;

  /// No description provided for @amCopyMarkdownHint.
  ///
  /// In fr, this message translates to:
  /// **'Avec la mise en forme, pour un document'**
  String get amCopyMarkdownHint;

  /// No description provided for @amShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get amShare;

  /// No description provided for @amEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier ma question'**
  String get amEdit;

  /// No description provided for @amEditHint.
  ///
  /// In fr, this message translates to:
  /// **'La suite de l’échange sera effacée'**
  String get amEditHint;

  /// No description provided for @amEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier cette question ?'**
  String get amEditTitle;

  /// No description provided for @amEditConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get amEditConfirm;

  /// No description provided for @amRegenerate.
  ///
  /// In fr, this message translates to:
  /// **'Régénérer'**
  String get amRegenerate;

  /// No description provided for @amReadAloud.
  ///
  /// In fr, this message translates to:
  /// **'Lire à voix haute'**
  String get amReadAloud;

  /// No description provided for @amAsContext.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre comme contexte'**
  String get amAsContext;

  /// No description provided for @amAsContextHint.
  ///
  /// In fr, this message translates to:
  /// **'Repart de ce message pour la suite'**
  String get amAsContextHint;

  /// No description provided for @amChapter.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme chapitre'**
  String get amChapter;

  /// No description provided for @amChapterHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour le retrouver dans une longue conversation'**
  String get amChapterHint;

  /// No description provided for @amUnchapter.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus marquer'**
  String get amUnchapter;

  /// No description provided for @amChapters.
  ///
  /// In fr, this message translates to:
  /// **'Chapitres'**
  String get amChapters;

  /// No description provided for @amChaptersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chapitre. Appuyez longuement sur un message et choisissez « Marquer comme chapitre » pour le retrouver ici.'**
  String get amChaptersEmpty;

  /// No description provided for @amEditBody.
  ///
  /// In fr, this message translates to:
  /// **'{count} messages qui suivent seront effacés : ils répondaient à l’ancienne question.'**
  String amEditBody(int count);

  /// No description provided for @trAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get trAssistant;

  /// No description provided for @trArtifacts.
  ///
  /// In fr, this message translates to:
  /// **'Artéfacts'**
  String get trArtifacts;

  /// No description provided for @trMemory.
  ///
  /// In fr, this message translates to:
  /// **'Mémoire'**
  String get trMemory;

  /// No description provided for @trHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get trHelp;

  /// No description provided for @arVersions.
  ///
  /// In fr, this message translates to:
  /// **'Versions'**
  String get arVersions;

  /// No description provided for @arLatest.
  ///
  /// In fr, this message translates to:
  /// **'La plus récente'**
  String get arLatest;

  /// No description provided for @arSource.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get arSource;

  /// No description provided for @arPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get arPreview;

  /// No description provided for @arGone.
  ///
  /// In fr, this message translates to:
  /// **'Cet artéfact n’existe plus.'**
  String get arGone;

  /// No description provided for @arKindPage.
  ///
  /// In fr, this message translates to:
  /// **'Page'**
  String get arKindPage;

  /// No description provided for @arKindCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get arKindCode;

  /// No description provided for @arKindDiagram.
  ///
  /// In fr, this message translates to:
  /// **'Schéma'**
  String get arKindDiagram;

  /// No description provided for @arKindData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get arKindData;

  /// No description provided for @arKindDoc.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get arKindDoc;

  /// No description provided for @arVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {n}'**
  String arVersion(int n);

  /// No description provided for @aiSources.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get aiSources;

  /// No description provided for @aiToolReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de la pièce jointe…'**
  String get aiToolReading;

  /// No description provided for @aiToolWriting.
  ///
  /// In fr, this message translates to:
  /// **'Production du fichier…'**
  String get aiToolWriting;

  /// No description provided for @aiToolRemembering.
  ///
  /// In fr, this message translates to:
  /// **'Mise en mémoire…'**
  String get aiToolRemembering;

  /// No description provided for @arEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun artéfact pour l’instant. L’assistant en crée un dès qu’il produit une page, un tableau ou du code assez long pour gêner dans la conversation.'**
  String get arEmpty;

  /// No description provided for @raTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant en ligne'**
  String get raTitle;

  /// No description provided for @raIntro.
  ///
  /// In fr, this message translates to:
  /// **'L’assistant local fonctionne sans rien configurer. Le mode en ligne, lui, demande une clé : c’est elle qui paie les réponses, et elle reste sur ce téléphone.'**
  String get raIntro;

  /// No description provided for @raKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé'**
  String get raKey;

  /// No description provided for @raKeySaved.
  ///
  /// In fr, this message translates to:
  /// **'Clé enregistrée'**
  String get raKeySaved;

  /// No description provided for @raKeyFooter.
  ///
  /// In fr, this message translates to:
  /// **'Elle dort dans le trousseau du système et ne s’affiche jamais en entier.'**
  String get raKeyFooter;

  /// No description provided for @raKeyRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la clé'**
  String get raKeyRemove;

  /// No description provided for @raWhere.
  ///
  /// In fr, this message translates to:
  /// **'Une clé se crée sur console.groq.com, dans « API Keys ». Elle commence par gsk_.'**
  String get raWhere;

  /// No description provided for @raPaste.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get raPaste;

  /// No description provided for @raSaveAndTest.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et tester'**
  String get raSaveAndTest;

  /// No description provided for @raTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester la clé'**
  String get raTest;

  /// No description provided for @raTesting.
  ///
  /// In fr, this message translates to:
  /// **'Test en cours…'**
  String get raTesting;

  /// No description provided for @raNotTested.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore testée'**
  String get raNotTested;

  /// No description provided for @raNotTestedBody.
  ///
  /// In fr, this message translates to:
  /// **'Un appel de huit mots suffit à savoir si elle marche. Autant le faire ici plutôt qu’au milieu d’une question.'**
  String get raNotTestedBody;

  /// No description provided for @raWorks.
  ///
  /// In fr, this message translates to:
  /// **'La clé fonctionne'**
  String get raWorks;

  /// No description provided for @raWorksBody.
  ///
  /// In fr, this message translates to:
  /// **'Le mode en ligne est disponible dans la conversation, sur la pastille à côté du champ de saisie.'**
  String get raWorksBody;

  /// No description provided for @raRefused.
  ///
  /// In fr, this message translates to:
  /// **'Clé refusée'**
  String get raRefused;

  /// No description provided for @raRefusedBody.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur ne la reconnaît pas. Souvent un caractère manquant au collage, ou une clé révoquée depuis.'**
  String get raRefusedBody;

  /// No description provided for @raNoNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable'**
  String get raNoNetwork;

  /// No description provided for @raNoNetworkBody.
  ///
  /// In fr, this message translates to:
  /// **'La clé n’est pas en cause : la requête n’est jamais arrivée. Vérifiez la connexion, puis réessayez.'**
  String get raNoNetworkBody;

  /// No description provided for @raModelGone.
  ///
  /// In fr, this message translates to:
  /// **'Modèle indisponible'**
  String get raModelGone;

  /// No description provided for @raModelGoneBody.
  ///
  /// In fr, this message translates to:
  /// **'La clé est acceptée, mais le serveur n’a rien renvoyé. Le modèle a probablement été retiré du catalogue.'**
  String get raModelGoneBody;

  /// No description provided for @raQuota.
  ///
  /// In fr, this message translates to:
  /// **'Trop de requêtes'**
  String get raQuota;

  /// No description provided for @raQuotaBody.
  ///
  /// In fr, this message translates to:
  /// **'La clé marche, mais le compte a atteint sa limite. Réessayez plus tard, ou vérifiez son crédit.'**
  String get raQuotaBody;

  /// No description provided for @raWhatGoesOut.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui part'**
  String get raWhatGoesOut;

  /// No description provided for @raModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get raModel;

  /// No description provided for @raWhatGoesOutFooter.
  ///
  /// In fr, this message translates to:
  /// **'En mode en ligne, votre message et les échanges précédents de la conversation partent chez Groq. Rien d’autre : ni vos contacts, ni vos autres discussions, ni votre position.'**
  String get raWhatGoesOutFooter;

  /// No description provided for @aiDownloadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le modèle local ?'**
  String get aiDownloadTitle;

  /// No description provided for @aiDownloadConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get aiDownloadConfirm;

  /// No description provided for @aiDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement du modèle local'**
  String get aiDownloading;

  /// No description provided for @aiDownloadBody.
  ///
  /// In fr, this message translates to:
  /// **'{mo} Mo à télécharger, une seule fois. Ensuite l’assistant répond sans réseau, et rien ne quitte le téléphone. Vous pouvez continuer à l’utiliser en ligne pendant le téléchargement.'**
  String aiDownloadBody(int mo);

  /// No description provided for @moLocalToDownload.
  ///
  /// In fr, this message translates to:
  /// **'{mo} Mo à télécharger, une seule fois. Ensuite l’assistant répond sans réseau et rien ne quitte le téléphone.'**
  String moLocalToDownload(int mo);

  /// No description provided for @aiGreetingPlain.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get aiGreetingPlain;

  /// No description provided for @aiGreetingHint.
  ///
  /// In fr, this message translates to:
  /// **'Posez une question, joignez une photo, ou demandez un document.'**
  String get aiGreetingHint;

  /// No description provided for @aiChipExplain.
  ///
  /// In fr, this message translates to:
  /// **'Explique-moi…'**
  String get aiChipExplain;

  /// No description provided for @aiChipWrite.
  ///
  /// In fr, this message translates to:
  /// **'Écris un message'**
  String get aiChipWrite;

  /// No description provided for @aiChipSummarize.
  ///
  /// In fr, this message translates to:
  /// **'Résume ce texte'**
  String get aiChipSummarize;

  /// No description provided for @aiChipTranslate.
  ///
  /// In fr, this message translates to:
  /// **'Traduis en…'**
  String get aiChipTranslate;

  /// No description provided for @aiGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {nom}'**
  String aiGreeting(String nom);

  /// No description provided for @cpNoPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Pas de photo : le modèle en ligne ne sait pas lire une image. Il lit en revanche les PDF, y compris longs.'**
  String get cpNoPhoto;

  /// No description provided for @mvOpen.
  ///
  /// In fr, this message translates to:
  /// **'Mode vocal'**
  String get mvOpen;

  /// No description provided for @mvTapToTalk.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour parler'**
  String get mvTapToTalk;

  /// No description provided for @mvHoldToTalk.
  ///
  /// In fr, this message translates to:
  /// **'Maintenez pour parler'**
  String get mvHoldToTalk;

  /// No description provided for @mvListening.
  ///
  /// In fr, this message translates to:
  /// **'J'écoute…'**
  String get mvListening;

  /// No description provided for @mvTranscribing.
  ///
  /// In fr, this message translates to:
  /// **'Transcription…'**
  String get mvTranscribing;

  /// No description provided for @mvSpeaking.
  ///
  /// In fr, this message translates to:
  /// **'Réponse à voix haute'**
  String get mvSpeaking;

  /// No description provided for @mvProblem.
  ///
  /// In fr, this message translates to:
  /// **'Un problème'**
  String get mvProblem;

  /// No description provided for @mvHandsFree.
  ///
  /// In fr, this message translates to:
  /// **'Mains libres'**
  String get mvHandsFree;

  /// No description provided for @mvHold.
  ///
  /// In fr, this message translates to:
  /// **'Maintien'**
  String get mvHold;

  /// No description provided for @mvTalk.
  ///
  /// In fr, this message translates to:
  /// **'Parler'**
  String get mvTalk;

  /// No description provided for @mvInterrupt.
  ///
  /// In fr, this message translates to:
  /// **'Interrompre'**
  String get mvInterrupt;

  /// No description provided for @mvNoMic.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n'a pas accès au micro. Autorisez-le dans les réglages du téléphone.'**
  String get mvNoMic;

  /// No description provided for @mvFailed.
  ///
  /// In fr, this message translates to:
  /// **'Ce tour n'a pas abouti. Touchez pour réessayer.'**
  String get mvFailed;

  /// No description provided for @mvLive.
  ///
  /// In fr, this message translates to:
  /// **'En direct'**
  String get mvLive;

  /// No description provided for @mvCaptions.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titres'**
  String get mvCaptions;

  /// No description provided for @mvExit.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le mode vocal'**
  String get mvExit;

  /// No description provided for @mvMute.
  ///
  /// In fr, this message translates to:
  /// **'Couper le micro'**
  String get mvMute;

  /// No description provided for @mvUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Rallumer le micro'**
  String get mvUnmute;

  /// No description provided for @mvMuted.
  ///
  /// In fr, this message translates to:
  /// **'Micro coupé'**
  String get mvMuted;

  /// No description provided for @mvTapToInterrupt.
  ///
  /// In fr, this message translates to:
  /// **'Toucher pour interrompre'**
  String get mvTapToInterrupt;

  /// No description provided for @scCompressing.
  ///
  /// In fr, this message translates to:
  /// **'Compression… {percent} %'**
  String scCompressing(int percent);

  /// No description provided for @scStillHeavy.
  ///
  /// In fr, this message translates to:
  /// **'Cette vidéo reste au-dessus de 2 Mo : son transfert sera plus lent.'**
  String get scStillHeavy;

  /// No description provided for @baConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get baConnecting;

  /// No description provided for @baMute.
  ///
  /// In fr, this message translates to:
  /// **'Couper le micro'**
  String get baMute;

  /// No description provided for @baUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Rallumer le micro'**
  String get baUnmute;

  /// No description provided for @baHangUp.
  ///
  /// In fr, this message translates to:
  /// **'Raccrocher'**
  String get baHangUp;

  /// No description provided for @baOngoing.
  ///
  /// In fr, this message translates to:
  /// **'Appel en cours avec {name}. Toucher pour y revenir.'**
  String baOngoing(String name);

  /// No description provided for @ntfOngoingCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel en cours'**
  String get ntfOngoingCall;

  /// No description provided for @ntfViaMesh.
  ///
  /// In fr, this message translates to:
  /// **'Par le maillage'**
  String get ntfViaMesh;

  /// No description provided for @ntfViaInternet.
  ///
  /// In fr, this message translates to:
  /// **'Par Internet'**
  String get ntfViaInternet;

  /// No description provided for @shSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get shSend;

  /// No description provided for @shRecents.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get shRecents;

  /// No description provided for @shPickRecipients.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un ou plusieurs destinataires'**
  String get shPickRecipients;

  /// No description provided for @shSendCount.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à {count}'**
  String shSendCount(int count);

  /// No description provided for @shSelected.
  ///
  /// In fr, this message translates to:
  /// **'{count} sélectionné(s)'**
  String shSelected(int count);

  /// No description provided for @apcNothingYet.
  ///
  /// In fr, this message translates to:
  /// **'Rien encore échangé'**
  String get apcNothingYet;

  /// No description provided for @apcOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get apcOnline;

  /// No description provided for @apcOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get apcOffline;

  /// No description provided for @apcPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get apcPhoto;

  /// No description provided for @apcVoice.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal'**
  String get apcVoice;

  /// No description provided for @apcAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Pièce jointe'**
  String get apcAttachment;

  /// No description provided for @chKeyboardTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Clavier'**
  String get chKeyboardTooltip;

  /// No description provided for @asGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get asGallery;

  /// No description provided for @asFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get asFile;

  /// No description provided for @asLocation.
  ///
  /// In fr, this message translates to:
  /// **'Position'**
  String get asLocation;

  /// No description provided for @asSticker.
  ///
  /// In fr, this message translates to:
  /// **'Sticker'**
  String get asSticker;

  /// No description provided for @asPoll.
  ///
  /// In fr, this message translates to:
  /// **'Sondage'**
  String get asPoll;

  /// No description provided for @asNoGalleryAccess.
  ///
  /// In fr, this message translates to:
  /// **'Droplet n'a pas accès à vos photos. Autorisez-le dans les réglages du téléphone, ou choisissez une autre source ci-dessous.'**
  String get asNoGalleryAccess;

  /// No description provided for @asSendCount.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer {count}'**
  String asSendCount(int count);

  /// No description provided for @asEmptyGallery.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo ni vidéo sur ce téléphone.'**
  String get asEmptyGallery;

  /// No description provided for @expAucunPairTitre.
  ///
  /// In fr, this message translates to:
  /// **'Personne à proximité ?'**
  String get expAucunPairTitre;

  /// No description provided for @expAucunPairTexte.
  ///
  /// In fr, this message translates to:
  /// **'Ce n'est pas une panne. Droplet cherche en permanence ; dès qu'un appareil passe, la liaison se fait toute seule.'**
  String get expAucunPairTexte;

  /// No description provided for @expRelaisTitre.
  ///
  /// In fr, this message translates to:
  /// **'Passé par un autre'**
  String get expRelaisTitre;

  /// No description provided for @expRelaisTexte.
  ///
  /// In fr, this message translates to:
  /// **'Cette icône dit que le message a traversé un ou plusieurs appareils avant d'arriver. C'est la force du maillage.'**
  String get expRelaisTexte;

  /// No description provided for @expApercuTitre.
  ///
  /// In fr, this message translates to:
  /// **'Coup d'œil'**
  String get expApercuTitre;

  /// No description provided for @expApercuTexte.
  ///
  /// In fr, this message translates to:
  /// **'Gardez le doigt sur une conversation pour en lire les derniers messages sans l'ouvrir — ni la marquer comme lue.'**
  String get expApercuTexte;

  /// No description provided for @expOfficielTitre.
  ///
  /// In fr, this message translates to:
  /// **'Le compte Droplet'**
  String get expOfficielTitre;

  /// No description provided for @expOfficielTexte.
  ///
  /// In fr, this message translates to:
  /// **'Les nouveautés de l'application arrivent ici. Chaque annonce est signée : personne ne peut en fabriquer une fausse.'**
  String get expOfficielTexte;

  /// No description provided for @expMicroTitre.
  ///
  /// In fr, this message translates to:
  /// **'Parler sans lâcher'**
  String get expMicroTitre;

  /// No description provided for @expMicroTexte.
  ///
  /// In fr, this message translates to:
  /// **'Maintenez pour enregistrer. Glissez vers la gauche pour annuler, vers le haut pour continuer sans tenir le doigt.'**
  String get expMicroTexte;

  /// No description provided for @expCameraTitre.
  ///
  /// In fr, this message translates to:
  /// **'Micro ou caméra'**
  String get expCameraTitre;

  /// No description provided for @expCameraTexte.
  ///
  /// In fr, this message translates to:
  /// **'Une pression brève sur ce bouton bascule entre message vocal et message vidéo rond.'**
  String get expCameraTexte;

  /// No description provided for @expVueUniqueTitre.
  ///
  /// In fr, this message translates to:
  /// **'Une seule fois'**
  String get expVueUniqueTitre;

  /// No description provided for @expVueUniqueTexte.
  ///
  /// In fr, this message translates to:
  /// **'Activez le « 1 » et le prochain envoi ne pourra être ouvert qu'une fois, puis disparaîtra.'**
  String get expVueUniqueTexte;

  /// No description provided for @expPiecesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs d'un coup'**
  String get expPiecesTitre;

  /// No description provided for @expPiecesTexte.
  ///
  /// In fr, this message translates to:
  /// **'Le trombone ouvre votre galerie dans l'application. Cochez plusieurs photos : le chiffre indique l'ordre d'envoi.'**
  String get expPiecesTexte;

  /// No description provided for @expStickersTitre.
  ///
  /// In fr, this message translates to:
  /// **'Stickers et clavier'**
  String get expStickersTitre;

  /// No description provided for @expStickersTexte.
  ///
  /// In fr, this message translates to:
  /// **'Cette icône remplace le clavier par les stickers, et redevient un clavier d'un seul toucher.'**
  String get expStickersTexte;

  /// No description provided for @expEphemeresTitre.
  ///
  /// In fr, this message translates to:
  /// **'Messages qui s'effacent'**
  String get expEphemeresTitre;

  /// No description provided for @expEphemeresTexte.
  ///
  /// In fr, this message translates to:
  /// **'Réglez un délai et les nouveaux messages de cette conversation s'effaceront des deux téléphones.'**
  String get expEphemeresTexte;

  /// No description provided for @expVerrouTitre.
  ///
  /// In fr, this message translates to:
  /// **'Conversation verrouillée'**
  String get expVerrouTitre;

  /// No description provided for @expVerrouTexte.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillée, une conversation ne montre plus son dernier message dans la liste, et demande à être déverrouillée.'**
  String get expVerrouTexte;

  /// No description provided for @expCodeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier un contact'**
  String get expCodeTitre;

  /// No description provided for @expCodeTexte.
  ///
  /// In fr, this message translates to:
  /// **'Comparez ce code côte à côte avec votre correspondant : s'il est identique, personne ne s'est glissé entre vous.'**
  String get expCodeTexte;

  /// No description provided for @expStatutTitre.
  ///
  /// In fr, this message translates to:
  /// **'Statuts de 24 heures'**
  String get expStatutTitre;

  /// No description provided for @expStatutTexte.
  ///
  /// In fr, this message translates to:
  /// **'Un statut vit un jour, puis s'efface. Il voyage de téléphone en téléphone, même sans Internet.'**
  String get expStatutTexte;

  /// No description provided for @expGardeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rien ne se perd'**
  String get expGardeTitre;

  /// No description provided for @expGardeTexte.
  ///
  /// In fr, this message translates to:
  /// **'Un message envoyé à quelqu'un d'absent est gardé une semaine et repart tout seul dès qu'un chemin s'ouvre.'**
  String get expGardeTexte;

  /// No description provided for @expVoieTitre.
  ///
  /// In fr, this message translates to:
  /// **'Par où ça passe'**
  String get expVoieTitre;

  /// No description provided for @expVoieTexte.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth, Wi-Fi direct ou Internet : Droplet prend ce qui est disponible et change de voie sans rien vous demander.'**
  String get expVoieTexte;

  /// No description provided for @cnAnnouncement.
  ///
  /// In fr, this message translates to:
  /// **'Nouveauté de Droplet'**
  String get cnAnnouncement;

  /// No description provided for @cnClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get cnClearAll;

  /// No description provided for @cnClearAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les notifications ?'**
  String get cnClearAllTitle;

  /// No description provided for @cnClearAllBody.
  ///
  /// In fr, this message translates to:
  /// **'Le centre sera vidé. Vos conversations et vos messages ne sont pas touchés.'**
  String get cnClearAllBody;

  /// No description provided for @cnDelete.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get cnDelete;

  /// No description provided for @cnEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien de nouveau'**
  String get cnEmptyTitle;

  /// No description provided for @cnEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les mentions, les réactions à vos messages, les appels manqués et les nouveautés de Droplet apparaîtront ici.'**
  String get cnEmptyBody;

  /// No description provided for @cnMentioned.
  ///
  /// In fr, this message translates to:
  /// **'vous a mentionné'**
  String get cnMentioned;

  /// No description provided for @cnShowLess.
  ///
  /// In fr, this message translates to:
  /// **'Afficher moins'**
  String get cnShowLess;

  /// No description provided for @cnStatusLike.
  ///
  /// In fr, this message translates to:
  /// **'a aimé votre statut'**
  String get cnStatusLike;

  /// No description provided for @cnStatusReply.
  ///
  /// In fr, this message translates to:
  /// **'a répondu à votre statut'**
  String get cnStatusReply;

  /// No description provided for @cnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Centre de notifications'**
  String get cnTitle;

  /// No description provided for @ncDeliveryHeader.
  ///
  /// In fr, this message translates to:
  /// **'Présentation'**
  String get ncDeliveryHeader;

  /// No description provided for @ncMentionsOnly.
  ///
  /// In fr, this message translates to:
  /// **'Mentions seulement'**
  String get ncMentionsOnly;

  /// No description provided for @ncMentionsOnlySub.
  ///
  /// In fr, this message translates to:
  /// **'Seulement quand on écrit @votre pseudo ou @tous'**
  String get ncMentionsOnlySub;

  /// No description provided for @ncMute1h.
  ///
  /// In fr, this message translates to:
  /// **'1 heure'**
  String get ncMute1h;

  /// No description provided for @ncMute8h.
  ///
  /// In fr, this message translates to:
  /// **'8 heures'**
  String get ncMute8h;

  /// No description provided for @ncMute1w.
  ///
  /// In fr, this message translates to:
  /// **'1 semaine'**
  String get ncMute1w;

  /// No description provided for @ncMuteAlways.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get ncMuteAlways;

  /// No description provided for @ncMuteFooter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification ni son. Les messages arrivent quand même et vous attendent.'**
  String get ncMuteFooter;

  /// No description provided for @ncMuteFooterGroup.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification ni son. Les mentions vous parviennent quand même.'**
  String get ncMuteFooterGroup;

  /// No description provided for @ncMuteHeader.
  ///
  /// In fr, this message translates to:
  /// **'Sourdine'**
  String get ncMuteHeader;

  /// No description provided for @ncMuteOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get ncMuteOff;

  /// No description provided for @ncPreviewAlways.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get ncPreviewAlways;

  /// No description provided for @ncPreviewFooter.
  ///
  /// In fr, this message translates to:
  /// **'Sans aperçu, la notification dit seulement « Nouveau message » : rien ne se lit sur l'écran verrouillé.'**
  String get ncPreviewFooter;

  /// No description provided for @ncPreviewHeader.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du message'**
  String get ncPreviewHeader;

  /// No description provided for @ncPreviewNever.
  ///
  /// In fr, this message translates to:
  /// **'Jamais'**
  String get ncPreviewNever;

  /// No description provided for @ncQuiet.
  ///
  /// In fr, this message translates to:
  /// **'Livraison discrète'**
  String get ncQuiet;

  /// No description provided for @ncQuietSub.
  ///
  /// In fr, this message translates to:
  /// **'Dans le volet, sans son ni bannière'**
  String get ncQuietSub;

  /// No description provided for @ncSampleAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Léa'**
  String get ncSampleAuthor;

  /// No description provided for @ncSampleHidden.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get ncSampleHidden;

  /// No description provided for @ncSampleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Exemple de notification'**
  String get ncSampleLabel;

  /// No description provided for @ncSampleText.
  ///
  /// In fr, this message translates to:
  /// **'On se retrouve à 19 h ?'**
  String get ncSampleText;

  /// No description provided for @ncStateMentions.
  ///
  /// In fr, this message translates to:
  /// **'Mentions seulement'**
  String get ncStateMentions;

  /// No description provided for @ncStateMuted.
  ///
  /// In fr, this message translates to:
  /// **'En sourdine'**
  String get ncStateMuted;

  /// No description provided for @ncStateOn.
  ///
  /// In fr, this message translates to:
  /// **'Activées'**
  String get ncStateOn;

  /// No description provided for @ncStateQuiet.
  ///
  /// In fr, this message translates to:
  /// **'Discrètes'**
  String get ncStateQuiet;

  /// No description provided for @ncSystemFooter.
  ///
  /// In fr, this message translates to:
  /// **'La sonnerie et les bulles de cette conversation se règlent dans Android.'**
  String get ncSystemFooter;

  /// No description provided for @ncSystemSettings.
  ///
  /// In fr, this message translates to:
  /// **'Son et bulles'**
  String get ncSystemSettings;

  /// No description provided for @ncTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get ncTitle;

  /// No description provided for @ntfNewMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get ntfNewMessage;

  /// No description provided for @ntfNow.
  ///
  /// In fr, this message translates to:
  /// **'maintenant'**
  String get ntfNow;

  /// No description provided for @rnBanners.
  ///
  /// In fr, this message translates to:
  /// **'Bannières'**
  String get rnBanners;

  /// No description provided for @rnBannersSub.
  ///
  /// In fr, this message translates to:
  /// **'Quand un message arrive pendant que Droplet est ouvert'**
  String get rnBannersSub;

  /// No description provided for @rnFocus1h.
  ///
  /// In fr, this message translates to:
  /// **'Pendant 1 heure'**
  String get rnFocus1h;

  /// No description provided for @rnFocusEvening.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu'à ce soir'**
  String get rnFocusEvening;

  /// No description provided for @rnFocusTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu'à demain matin'**
  String get rnFocusTomorrow;

  /// No description provided for @rnFocusFooter.
  ///
  /// In fr, this message translates to:
  /// **'Droplet se tait : les messages arrivent et vous attendent. Les appels sonnent toujours.'**
  String get rnFocusFooter;

  /// No description provided for @rnFocusHeader.
  ///
  /// In fr, this message translates to:
  /// **'Concentration'**
  String get rnFocusHeader;

  /// No description provided for @rnFocusMentions.
  ///
  /// In fr, this message translates to:
  /// **'Laisser passer les mentions'**
  String get rnFocusMentions;

  /// No description provided for @rnFocusMentionsSub.
  ///
  /// In fr, this message translates to:
  /// **'Quand on écrit @votre pseudo dans un groupe'**
  String get rnFocusMentionsSub;

  /// No description provided for @rnFocusOff.
  ///
  /// In fr, this message translates to:
  /// **'Concentration désactivée'**
  String get rnFocusOff;

  /// No description provided for @rnFocusOffSub.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications arrivent normalement'**
  String get rnFocusOffSub;

  /// No description provided for @rnFocusOn.
  ///
  /// In fr, this message translates to:
  /// **'Concentration activée'**
  String get rnFocusOn;

  /// No description provided for @rnFocusStop.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver la concentration'**
  String get rnFocusStop;

  /// No description provided for @rnFocusStopShort.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get rnFocusStopShort;

  /// No description provided for @rnInAppHeader.
  ///
  /// In fr, this message translates to:
  /// **'Dans Droplet'**
  String get rnInAppHeader;

  /// No description provided for @rnMutedEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation en sourdine.'**
  String get rnMutedEmpty;

  /// No description provided for @rnMutedHeader.
  ///
  /// In fr, this message translates to:
  /// **'En sourdine'**
  String get rnMutedHeader;

  /// No description provided for @rnPreview.
  ///
  /// In fr, this message translates to:
  /// **'Afficher l'aperçu'**
  String get rnPreview;

  /// No description provided for @rnPreviewFooter.
  ///
  /// In fr, this message translates to:
  /// **'Le texte des messages dans les notifications. Chaque conversation peut faire autrement.'**
  String get rnPreviewFooter;

  /// No description provided for @rnSystem.
  ///
  /// In fr, this message translates to:
  /// **'Réglages Android'**
  String get rnSystem;

  /// No description provided for @rnSystemFooter.
  ///
  /// In fr, this message translates to:
  /// **'Autorisations, sons et bulles de Droplet dans les réglages du téléphone.'**
  String get rnSystemFooter;

  /// No description provided for @stNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sourdine, aperçus, concentration'**
  String get stNotificationsSubtitle;

  /// No description provided for @cnBellUnread.
  ///
  /// In fr, this message translates to:
  /// **'Notifications, {count} nouvelles'**
  String cnBellUnread(int count);

  /// No description provided for @cnMore.
  ///
  /// In fr, this message translates to:
  /// **'+{count} de plus'**
  String cnMore(int count);

  /// No description provided for @ntfMoreMessages.
  ///
  /// In fr, this message translates to:
  /// **'+{count} de plus'**
  String ntfMoreMessages(int count);

  /// No description provided for @cnQuoted.
  ///
  /// In fr, this message translates to:
  /// **'« {texte} »'**
  String cnQuoted(String texte);

  /// No description provided for @cnReacted.
  ///
  /// In fr, this message translates to:
  /// **'a réagi {emoji} à votre message'**
  String cnReacted(String emoji);

  /// No description provided for @ncMutedUntil.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu'à {heure}'**
  String ncMutedUntil(String heure);

  /// No description provided for @ncPreviewDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut ({valeur})'**
  String ncPreviewDefault(String valeur);

  /// No description provided for @muTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre {nom} en sourdine'**
  String muTitle(String nom);

  /// No description provided for @rnFocusUntil.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu'à {heure} · les appels sonnent toujours'**
  String rnFocusUntil(String heure);

  /// No description provided for @ntfSummaryChats.
  ///
  /// In fr, this message translates to:
  /// **'{n} discussions'**
  String ntfSummaryChats(String n);

  /// No description provided for @chatsNetSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d'appareils proches…'**
  String get chatsNetSearching;

  /// No description provided for @cfEmptyUnreadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout est lu'**
  String get cfEmptyUnreadTitle;

  /// No description provided for @cfEmptyUnreadBody.
  ///
  /// In fr, this message translates to:
  /// **'Les discussions avec des messages non lus apparaîtront ici.'**
  String get cfEmptyUnreadBody;

  /// No description provided for @cfEmptyGroupsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe'**
  String get cfEmptyGroupsTitle;

  /// No description provided for @cfEmptyGroupsBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez-en un avec le bouton +, en haut à droite.'**
  String get cfEmptyGroupsBody;

  /// No description provided for @cfEmptyOtherTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien ici pour l'instant'**
  String get cfEmptyOtherTitle;

  /// No description provided for @ciLockedWhereHint.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillée. Pour la retrouver, tirez la liste des discussions vers le bas.'**
  String get ciLockedWhereHint;

  /// No description provided for @chDraftLabel.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon :'**
  String get chDraftLabel;

  /// No description provided for @rsMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get rsMorning;

  /// No description provided for @rsEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get rsEvening;

  /// No description provided for @rsUnreadOne.
  ///
  /// In fr, this message translates to:
  /// **'1 message non lu'**
  String get rsUnreadOne;

  /// No description provided for @rsChatsOne.
  ///
  /// In fr, this message translates to:
  /// **'dans 1 discussion'**
  String get rsChatsOne;

  /// No description provided for @rsMentionsOne.
  ///
  /// In fr, this message translates to:
  /// **'1 mention'**
  String get rsMentionsOne;

  /// No description provided for @rsMissedOne.
  ///
  /// In fr, this message translates to:
  /// **'1 appel manqué'**
  String get rsMissedOne;

  /// No description provided for @rsSeeUnread.
  ///
  /// In fr, this message translates to:
  /// **'Voir les non lus'**
  String get rsSeeUnread;

  /// No description provided for @rsUnreadMany.
  ///
  /// In fr, this message translates to:
  /// **'{count} messages non lus'**
  String rsUnreadMany(int count);

  /// No description provided for @rsChatsMany.
  ///
  /// In fr, this message translates to:
  /// **'dans {count} discussions'**
  String rsChatsMany(int count);

  /// No description provided for @rsMentionsMany.
  ///
  /// In fr, this message translates to:
  /// **'{count} mentions'**
  String rsMentionsMany(int count);

  /// No description provided for @rsMissedMany.
  ///
  /// In fr, this message translates to:
  /// **'{count} appels manqués'**
  String rsMissedMany(int count);

  /// No description provided for @camUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo indisponible. Vérifiez l'autorisation dans les réglages.'**
  String get camUnavailable;

  /// No description provided for @camTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get camTakePhoto;

  /// No description provided for @camFlip.
  ///
  /// In fr, this message translates to:
  /// **'Retourner l'appareil photo'**
  String get camFlip;

  /// No description provided for @chE2eNotice.
  ///
  /// In fr, this message translates to:
  /// **'Les messages sont chiffrés de bout en bout. Personne d'autre, pas même Droplet, ne peut les lire.'**
  String get chE2eNotice;

  /// No description provided for @chCallUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'{name} n'est pas à portée : l'appel passera quand vous serez proches ou connectés.'**
  String chCallUnreachable(String name);

  /// No description provided for @chPin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler'**
  String get chPin;

  /// No description provided for @chUnpin.
  ///
  /// In fr, this message translates to:
  /// **'Désépingler'**
  String get chUnpin;

  /// No description provided for @chPinnedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message épinglé'**
  String get chPinnedMessage;

  /// No description provided for @chVoicePlay.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get chVoicePlay;

  /// No description provided for @chVoicePause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get chVoicePause;

  /// No description provided for @chPinnedMessageN.
  ///
  /// In fr, this message translates to:
  /// **'Message épinglé {position}'**
  String chPinnedMessageN(String position);

  /// No description provided for @msgInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get msgInfo;

  /// No description provided for @imSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get imSearch;

  /// No description provided for @apcVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get apcVideo;

  /// No description provided for @adTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appareils liés'**
  String get adTitle;

  /// No description provided for @adSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Droplet Web sur votre ordinateur'**
  String get adSettingsSubtitle;

  /// No description provided for @adHero.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez Droplet sur votre ordinateur, même quand votre téléphone est éteint. Ouvrez simplement :'**
  String get adHero;

  /// No description provided for @adLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier un appareil'**
  String get adLink;

  /// No description provided for @adDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get adDevices;

  /// No description provided for @adCount.
  ///
  /// In fr, this message translates to:
  /// **'{n} sur {max}'**
  String adCount(int n, int max);

  /// No description provided for @adNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil lié'**
  String get adNone;

  /// No description provided for @adFooter.
  ///
  /// In fr, this message translates to:
  /// **'Vos messages sont chiffrés de bout en bout sur chacun de vos appareils. Chaque appareil lié a ses propres clés, et vous pouvez le déconnecter à tout moment.'**
  String get adFooter;

  /// No description provided for @adLinkedOn.
  ///
  /// In fr, this message translates to:
  /// **'Lié le {date}'**
  String adLinkedOn(String date);

  /// No description provided for @adLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get adLogout;

  /// No description provided for @adLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter {nom} ?'**
  String adLogoutTitle(String nom);

  /// No description provided for @adLogoutBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce navigateur perdra l'accès à vos discussions. Vous pourrez le lier à nouveau à tout moment.'**
  String get adLogoutBody;

  /// No description provided for @adLogoutAll.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter tous les appareils'**
  String get adLogoutAll;

  /// No description provided for @adLogoutAllBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les navigateurs liés perdront l'accès à vos discussions.'**
  String get adLogoutAllBody;

  /// No description provided for @adScanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lier un appareil'**
  String get adScanTitle;

  /// No description provided for @adScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Sur votre ordinateur, ouvrez Droplet Web et visez le code QR :'**
  String get adScanHint;

  /// No description provided for @adSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Le code change chaque minute : une photo du code ne sert à rien.'**
  String get adSecurity;

  /// No description provided for @adNotDroplet.
  ///
  /// In fr, this message translates to:
  /// **'Ce n'est pas un code Droplet Web. Visez le code affiché sur web.dropletmesh.app.'**
  String get adNotDroplet;

  /// No description provided for @adConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lier cet appareil ?'**
  String get adConfirmTitle;

  /// No description provided for @adConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Il pourra lire et envoyer vos messages, même quand ce téléphone est éteint.'**
  String get adConfirmBody;

  /// No description provided for @adConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Lier'**
  String get adConfirm;

  /// No description provided for @adLinking.
  ///
  /// In fr, this message translates to:
  /// **'Liaison en cours…'**
  String get adLinking;

  /// No description provided for @adLinked.
  ///
  /// In fr, this message translates to:
  /// **'Appareil lié'**
  String get adLinked;

  /// No description provided for @adServerDown.
  ///
  /// In fr, this message translates to:
  /// **'Les serveurs Droplet sont injoignables pour l'instant. Vérifiez votre connexion, puis réessayez.'**
  String get adServerDown;

  /// No description provided for @adLimit.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà 4 appareils liés. Déconnectez-en un pour en lier un autre.'**
  String get adLimit;

  /// No description provided for @adNoIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Créez d'abord votre profil Droplet sur ce téléphone.'**
  String get adNoIdentity;

  /// No description provided for @adTorch.
  ///
  /// In fr, this message translates to:
  /// **'Lampe'**
  String get adTorch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
