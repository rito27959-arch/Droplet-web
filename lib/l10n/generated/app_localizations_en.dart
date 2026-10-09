// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Send';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionEdit => 'Edit';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabNews => 'Updates';

  @override
  String get tabCalls => 'Calls';

  @override
  String get tabPeers => 'Peers';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get appearanceAuto => 'Automatic';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceFooter =>
      'Droplet is designed for dark mode: on an OLED screen, black pixels are off, which saves battery and avoids glare in the dark. Light mode stays available for reading in bright sunlight.';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageAuto => 'Automatic (phone language)';

  @override
  String get languageFooter =>
      '“Automatic” follows the language set on your device. If that language isn\'t supported yet, Droplet stays in French.';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsSearchHint => 'Search';

  @override
  String get chatsFilterAll => 'All';

  @override
  String get chatsFilterUnread => 'Unread';

  @override
  String get chatsFilterGroups => 'Groups';

  @override
  String get chatsFilterPinned => 'Pinned';

  @override
  String get chatsEmptyTitle => 'No chats yet';

  @override
  String get chatsEmptySubtitle =>
      'Get close to a device using Droplet: it will show up here automatically.';

  @override
  String get chatsSearchEmptyTitle => 'No results';

  @override
  String get chatsSearchEmptySubtitle => 'Try a different name.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peers nearby',
      one: '$count peer nearby',
      zero: 'Looking for peers…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'At least 3 characters';

  @override
  String get obChoosePseudo => 'Choose a name to get started';

  @override
  String get obRestoreFailed => 'Restore failed';

  @override
  String get obPhotoSaveFailed => 'Couldn\'t save the photo';

  @override
  String get obShareUnavailable => 'Sharing unavailable';

  @override
  String get obBackupPasswordTitle => 'Backup password';

  @override
  String get obBackupPasswordMessage =>
      'The one you chose when exporting your identity.';

  @override
  String get obBackupPasswordPlaceholder => 'Password';

  @override
  String get obRestore => 'Restore';

  @override
  String get obSkipStep => 'Skip this step';

  @override
  String get obContinue => 'Continue';

  @override
  String get obStart => 'Get started';

  @override
  String get obAlreadyHaveBackup => 'I already have a backup';

  @override
  String get obWelcomeTitle => 'Welcome to\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'A messenger that works where there\'s no network left.';

  @override
  String get obFeatOfflineTitle => 'No internet, no carrier';

  @override
  String get obFeatOfflineText =>
      'Phones talk to each other directly, one hop at a time. No antenna, no bill.';

  @override
  String get obFeatEncryptedTitle => 'End-to-end encrypted';

  @override
  String get obFeatEncryptedText =>
      'Not even the phones relaying your messages can read them.';

  @override
  String get obFeatLocalTitle => 'Nothing leaves your device';

  @override
  String get obFeatLocalText =>
      'No account, no server, no data collection. Your conversations stay with you.';

  @override
  String get obRelayTitle => 'Hop by\nhop';

  @override
  String get obRelaySubtitle =>
      'Your message hops from phone to phone until it reaches its recipient, even if you\'re not within direct range.';

  @override
  String get obFeatCrowdTitle => 'The more of us, the farther it reaches';

  @override
  String get obFeatCrowdText =>
      'Every device in range grows the network for everyone.';

  @override
  String get obFeatNothingLostTitle => 'Nothing is lost';

  @override
  String get obFeatNothingLostText =>
      'A message meant for someone who\'s away waits, then moves on as soon as a path opens.';

  @override
  String get obSafetyTitle => 'Find each other,\nwithout a network';

  @override
  String get obSafetySubtitle =>
      'When nothing else works, knowing where others are and that they\'re okay becomes the most useful information there is.';

  @override
  String get obFeatMapTitle => 'A map that works offline';

  @override
  String get obFeatMapText =>
      'The areas you view stay on your phone. Once viewed, they display without internet.';

  @override
  String get obFeatMeshPosTitle => 'Locations come from the mesh';

  @override
  String get obFeatMeshPosText =>
      'No server: the location leaves your contact\'s phone encrypted and hops from device to device until it reaches yours.';

  @override
  String get obFeatCheckinTitle => '“I\'m safe,” in one tap';

  @override
  String get obFeatCheckinText =>
      'A single tap broadcasts your status to the whole neighborhood. You choose whether to include an approximate location, or not.';

  @override
  String get obStatusTitle => 'Sharing\nupdates';

  @override
  String get obStatusSubtitle =>
      'A photo, a word, a mood: your status travels from phone to phone, just like your messages.';

  @override
  String get obFeatStatusMediaTitle => 'Photo, video, or text';

  @override
  String get obFeatStatusMediaText =>
      'Post whatever you want to show. People in range receive it, without going through the internet.';

  @override
  String get obFeatStatusSeenTitle => 'You see who\'s seen it';

  @override
  String get obFeatStatusSeenText =>
      'Everyone who opens your status lets you know in return, over the same path.';

  @override
  String get obFeatStatusExpireTitle => 'It disappears after a day';

  @override
  String get obFeatStatusExpireText =>
      'Twenty-four hours, then the status vanishes from every phone that received it.';

  @override
  String get obRemovePhoto => 'Remove the photo';

  @override
  String get obChoosePhoto => 'Choose a photo';

  @override
  String get obPhotoTitle => 'A face,\nif you like';

  @override
  String get obPhotoSubtitle =>
      'It helps others recognize you in a list. Nothing requires you to add one.';

  @override
  String get obFeatPhotoLocalTitle => 'It stays on this phone';

  @override
  String get obFeatPhotoLocalText =>
      'No server receives it, no online backup keeps it. It lives in the app\'s folder, and nowhere else.';

  @override
  String get obFeatPhotoCompressTitle => 'Shrunk before being stored';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet only keeps a 320-pixel thumbnail. Your original photo is never copied.';

  @override
  String get obNetworkTitle => 'Droplet grows\nwith you';

  @override
  String get obNetworkSubtitle =>
      'Every person who installs it grows the network — for them, and for everyone around them.';

  @override
  String get obSendToFriend => 'Send Droplet to someone';

  @override
  String get obFeatShareOfflineTitle =>
      'Even sharing doesn\'t need the internet';

  @override
  String get obFeatShareOfflineText =>
      'Droplet sends you its own installer file. It travels over Bluetooth, Wi-Fi Direct, or a memory card — no connection needed, on either end.';

  @override
  String get obFeatThreeTitle => 'Three people are enough to start';

  @override
  String get obFeatThreeText =>
      'With two, you write to each other within sight. With a few in a neighborhood, messages relay and the range becomes far greater than any single phone.';

  @override
  String get obIdentityTitle => 'What should we\ncall you?';

  @override
  String get obIdentitySubtitle =>
      'This name will appear to people you cross paths with. You can choose one that doesn\'t identify you.';

  @override
  String get obPseudoHint => 'Your name';

  @override
  String get obFeatKeysTitle => 'Your keys are created here, right now';

  @override
  String get obFeatKeysText =>
      'They never leave this phone. Remember to make a backup from settings: without it, a lost identity is lost for good.';

  @override
  String get splashCaption => 'Offline. No carrier.';

  @override
  String get chatsMeshNetwork => 'Mesh network';

  @override
  String get chatsNew => 'New';

  @override
  String get chatsNewGroup => 'New group';

  @override
  String get chatsAssistant => 'Assistant';

  @override
  String get chatsEmergencyMode => 'Emergency mode';

  @override
  String get chatsUnpin => 'Unpin';

  @override
  String get chatsPin => 'Pin to top';

  @override
  String get chatsUnmute => 'Turn notifications on';

  @override
  String get chatsMute => 'Mute';

  @override
  String get chatsArchive => 'Archive';

  @override
  String get swipePin => 'Pin';

  @override
  String get swipeUnpin => 'Unpin';

  @override
  String get swipeMute => 'Mute';

  @override
  String get swipeUnmute => 'Unmute';

  @override
  String get swipeArchive => 'Archive';

  @override
  String get fmtBold => 'Bold';

  @override
  String get fmtItalic => 'Italic';

  @override
  String get fmtStrike => 'Strikethrough';

  @override
  String get fmtMono => 'Monospace';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'Transcribing…';

  @override
  String get vnTranscribeFailed => 'Transcription unavailable on this device';

  @override
  String get vnNoSpeech => 'No speech recognised';

  @override
  String get msgTranslate => 'Translate';

  @override
  String get msgShowOriginal => 'Show original';

  @override
  String get msgTranslatedFrom => 'Translated automatically';

  @override
  String get msgTranslateFailed => 'Translation unavailable';

  @override
  String get msgTranslateModel =>
      'Language model needs downloading (once, on Wi‑Fi)';

  @override
  String get pfWallpapers => 'Animated wallpapers';

  @override
  String get pfWallpapersDesc =>
      'Eight multicolor wallpapers that live behind your chats and turn with every message sent.';

  @override
  String get pfFormatting => 'Text formatting';

  @override
  String get pfFormattingDesc =>
      'Bold, italic, strikethrough, code and spoilers, right inside your messages.';

  @override
  String get pfTranscription => 'Voice to text';

  @override
  String get pfTranscriptionDesc =>
      'Read a voice message when you cannot listen. Recognition happens on your phone.';

  @override
  String get pfTranslation => 'Translation';

  @override
  String get pfTranslationDesc =>
      'Translate a received message without its content ever leaving the device.';

  @override
  String get pfAppIcons => 'App icons';

  @override
  String get pfAppIconsDesc => 'Change the Droplet icon on your home screen.';

  @override
  String get pfBadge => 'Badge and support';

  @override
  String get pfBadgeDesc =>
      'A badge next to your name, and support for an independent project.';

  @override
  String get pfUnderstood => 'Got it';

  @override
  String get pfFeaturesTitle => 'What the pack unlocks';

  @override
  String get chatsUnarchive => 'Unarchive';

  @override
  String get chatsArchivedTitle => 'Archived';

  @override
  String get chatsNoArchived => 'No archived chats';

  @override
  String get chatsLockedTitle => 'Locked chats';

  @override
  String get chatsNoLocked => 'No locked chats';

  @override
  String get chatsCrashTitle => 'Droplet closed unexpectedly';

  @override
  String get chatsCrashBody =>
      'Droplet has no server: without you sending it, this bug exists for no one else. The report contains no messages, contacts, or keys.';

  @override
  String get chatsSendReport => 'Send the report';

  @override
  String get chatsLater => 'Later';

  @override
  String get stTitle => 'Settings';

  @override
  String get stIconHeader => 'Icon';

  @override
  String get stIconFooter =>
      'Thirteen icons to choose from for the home screen.';

  @override
  String get stAppIcon => 'App icon';

  @override
  String get stVariants13 => '13 variants';

  @override
  String get stNetworkHeader => 'Network';

  @override
  String get stNetworkFooter =>
      'Background relaying lets you forward others\' messages even when Droplet is closed.';

  @override
  String get stRequireTor => 'Require Tor online';

  @override
  String get stRequireTorSubtitle => 'Without Tor, nothing reaches the servers';

  @override
  String get stRequireTorFooter =>
      'The directory and mailbox go through Tor whenever it is active. Otherwise Droplet connects directly: content stays end-to-end encrypted, but the servers see your IP address. Turn this on to forbid that — at the cost of online messaging whenever Tor is down.';

  @override
  String get stMeshNetwork => 'Mesh network';

  @override
  String get stPeersTopology => 'Connected peers and topology';

  @override
  String get stOfflineMaps => 'Offline maps';

  @override
  String get stZonesImport => 'Saved areas and map import';

  @override
  String get stSecurityHeader => 'Security';

  @override
  String get stSecurityFooter =>
      'Droplet keeps no copy of your identity. Without a backup, it\'s lost with the device.';

  @override
  String get stBackupIdentity => 'Back up my identity';

  @override
  String get stExportEncrypted => 'Password-encrypted export';

  @override
  String get stEmergencyMode => 'Emergency mode';

  @override
  String get stSignalSafe => 'Signal that you\'re safe';

  @override
  String get stContributionHeader => 'Contribution';

  @override
  String get stMyContribution => 'My contribution';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Active';

  @override
  String get stProPackUnlocked => 'Pack unlocked';

  @override
  String get stProIconsThemes => 'Icons and backgrounds';

  @override
  String get stCrashLog => 'Error log';

  @override
  String get stAbout => 'About Droplet';

  @override
  String get stBackgroundRelay => 'Background relaying';

  @override
  String get stActiveClosed => 'Active even when the app is closed';

  @override
  String get stActiveOpenOnly => 'Active only while the app is open';

  @override
  String get stBatteryOptim => 'Battery optimization';

  @override
  String get stAndroidMayLimit => 'Android may limit relaying';

  @override
  String get stFix => 'Fix';

  @override
  String get stKeepActiveTitle => 'Keep Droplet active?';

  @override
  String get stKeepActiveBody =>
      'A persistent notification will show that Droplet is relaying the mesh, even when the app is closed. In exchange, battery use will be higher.';

  @override
  String get stEnable => 'Enable';

  @override
  String get stCancel => 'Cancel';

  @override
  String get stAboutTagline =>
      'Offline messaging and calls, no internet or carrier needed.';

  @override
  String get stAboutDirect => 'Direct network between devices — no server';

  @override
  String get stAboutE2E => 'End-to-end encryption on every message';

  @override
  String get stAboutNoThirdParty => 'No data sent to any third party';

  @override
  String get stAttributionEmoji =>
      'Animated emoji: Noto Animated Emoji © Google, licensed under CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Assistant: Gemma 3 1B-IT © Google, quantized (int4) by litert-community and republished by Droplet, under the Gemma Terms of Use (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Chat background';

  @override
  String get stChatPatterns => 'Droplet doodles';

  @override
  String get stChatPatternsSubtitle =>
      'Little line drawings over the background';

  @override
  String get stChatBgFooter =>
      'The gradient shifts one step with every message sent. Choose “None” for a plain background: nothing is then computed, which saves battery.';

  @override
  String get stBgFree => 'Free';

  @override
  String get stBgPremium => 'Premium · animated';

  @override
  String get stBgNone => 'None';

  @override
  String get stBgDefault => 'Default';

  @override
  String get stBgThisChat => 'Wallpaper for this chat';

  @override
  String get stTextSize => 'Text size';

  @override
  String get stBubbleCorners => 'Message corners';

  @override
  String get stAccentHeader => 'Accent color';

  @override
  String get stAccentFooter =>
      'It colors your bubbles, buttons and links, everywhere in the app.';

  @override
  String get stChatListHeader => 'Chat list';

  @override
  String get stChatListTwoLines => 'Two lines';

  @override
  String get stChatListThreeLines => 'Three lines';

  @override
  String get stResetAppearance => 'Reset appearance';

  @override
  String get stPreviewIncoming => 'See you tonight?';

  @override
  String get stPreviewOutgoing => 'Yes, gladly!';

  @override
  String get stAppearanceRow => 'Appearance';

  @override
  String get stAppearanceSubtitle => 'Theme, color, text size, wallpapers';

  @override
  String get stBgApply => 'Use this wallpaper';

  @override
  String get stBgUnlock => 'Unlock with Premium';

  @override
  String get stBgApplied => 'Wallpaper applied';

  @override
  String get stBgPreviewHint =>
      'The wallpaper moves, and its colors turn with every message you send.';

  @override
  String get stBgPreviewIncoming => 'Have you seen the new wallpaper?';

  @override
  String get stBgPreviewOutgoing => 'Yes, it\'s gorgeous ✨';

  @override
  String get stSoundHeader => 'Sounds';

  @override
  String get stSoundToggle => 'In-app sounds';

  @override
  String get stSoundSubtitle => 'Messages, connections, alerts';

  @override
  String get stSoundFooter =>
      'Short tones, played at the system notification volume — silent when the phone is on silent or focus mode.';

  @override
  String get stPacksHeader => 'Assistant — offline sheets';

  @override
  String get stPacksToggle => 'First-aid & emergency sheets';

  @override
  String get stPacksSubtitle =>
      'The assistant draws on these for first aid and emergencies.';

  @override
  String get stPacksFooter =>
      'Built-in reference sheets (first aid, earthquake, flood, safe water…). When a question relates to them, the assistant quotes the sheet instead of guessing. They replace neither training nor a call to emergency services.';

  @override
  String get stPrivateModeHeader => 'Private mode';

  @override
  String get stTorFooter =>
      'Tor protects your IP address and conversations by routing them through the Tor network. The local mesh (BLE/Wi-Fi) keeps working normally.';

  @override
  String get stTorActiveAnon => 'Active — your data is anonymized';

  @override
  String get stTorConnecting => 'Connecting…';

  @override
  String get stTorDisabled => 'Private mode off';

  @override
  String get callsTitle => 'Calls';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missed calls',
      one: '$count missed call',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'New call';

  @override
  String get callsAll => 'All';

  @override
  String get callsMissed => 'Missed';

  @override
  String get callsNoneMissed => 'No missed calls';

  @override
  String get callsNone => 'No calls';

  @override
  String get callsMissedEmptyBody =>
      'Calls you didn\'t answer will show up here.';

  @override
  String get callsEmptyBody =>
      'Calls go through the local network, no carrier or plan needed. Your history will show up here.';

  @override
  String get callsRetained200 =>
      'The last 200 calls are kept on this device only.';

  @override
  String get callsIncoming => 'Incoming';

  @override
  String get callsOutgoing => 'Outgoing';

  @override
  String get callsMissedLabel => 'Missed';

  @override
  String get callsNoAnswer => 'No answer';

  @override
  String get callsConnectionFailed => 'Connection failed';

  @override
  String get callsYesterday => 'yesterday';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Peers';

  @override
  String get peersSearching => 'Searching…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices in range',
      one: '$count device in range',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Network map';

  @override
  String get peersNoneInRange => 'No one in range';

  @override
  String get peersNoneInRangeBody =>
      'Droplet is constantly looking for nearby devices. Get closer to someone with the app to make the first connection.';

  @override
  String get peersDirectRange => 'In direct range';

  @override
  String get peersDirectRangeFooter =>
      'These devices are reachable without going through anyone else.';

  @override
  String get peersRelayed => 'Relayed';

  @override
  String get peersRelayedFooter =>
      'These devices are out of direct range: messages reach them via other phones.';

  @override
  String get peersRelay => 'Relay';

  @override
  String get peersCall => 'Call';

  @override
  String get peersTooSlow => 'Too slow for voice — get closer';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Unknown link';

  @override
  String get peersDirect => 'direct';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relays',
      one: '$count relay',
      zero: 'direct',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'This status has expired';

  @override
  String get svReceiving => 'Receiving…';

  @override
  String get svReceivingBody => 'The file is arriving over the local network';

  @override
  String get svProgressLabel => 'Status progress';

  @override
  String get svReplyHint => 'Reply…';

  @override
  String get svSendReply => 'Send reply';

  @override
  String get svYourStatus => 'Your status';

  @override
  String get svNoViewsYet =>
      'No one has seen this status yet.\nIt will keep circulating as long as you cross paths with devices.';

  @override
  String get svJustNow => 'just now';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '$count min ago',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '$count h ago',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Music';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '$count view',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '$count like',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '$count reply',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Original';

  @override
  String get cpFilterDark => 'Dark';

  @override
  String get cpFilterBright => 'Bright';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Write a status';

  @override
  String get cpPreparingVideo => 'Preparing the video…';

  @override
  String get cpLoadingEllipsis => 'Loading…';

  @override
  String cpEndsIn(Object s) {
    return 'Ends in $s s';
  }

  @override
  String get cpModeVideo => 'Video';

  @override
  String get cpModePhoto => 'Photo';

  @override
  String get cpModeMessage => 'Text';

  @override
  String get cpModeVoice => 'Voice';

  @override
  String get gcChooseName => 'Choose a name for the group';

  @override
  String get gcSelectOneMember => 'Select at least one member';

  @override
  String get gcCreationFailed => 'Failed to create the group';

  @override
  String get gcNewGroup => 'New group';

  @override
  String get gcGroupName => 'Group name';

  @override
  String get gcNameHint => 'e.g. Field team';

  @override
  String get gcMembers => 'Members';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'No one in range';

  @override
  String get gcGetCloserBody =>
      'Get closer to another Droplet device: peers show up here automatically.';

  @override
  String get gcCreateGroup => 'Create group';

  @override
  String get gcConnected => 'Connected';

  @override
  String get gcAlreadyMet => 'Previously met';

  @override
  String get giRenameGroup => 'Rename group';

  @override
  String get giRenameFailed => 'Rename failed';

  @override
  String get giNoPeerToAdd => 'No peers available to add';

  @override
  String get giAddMemberHeader => 'ADD A MEMBER';

  @override
  String get giAddMemberFailed => 'Failed to add member';

  @override
  String get giRemoveMemberTitle => 'Remove this member?';

  @override
  String get giRemoveMemberBody =>
      'They will no longer be able to read messages sent after their removal.';

  @override
  String get giRemove => 'Remove';

  @override
  String get giRemoveMemberFailed => 'Failed to remove member';

  @override
  String get giLeaveGroupTitle => 'Leave the group?';

  @override
  String get giLeaveGroupBody =>
      'You will no longer receive messages sent after you leave.';

  @override
  String get giLeave => 'Leave';

  @override
  String get giNoOneReachable =>
      'No members reachable over local Wi-Fi right now';

  @override
  String get giMax4Participants =>
      'Maximum 4 participants per group call — only the first 3 reachable will be called';

  @override
  String get giGroupNotFound => 'Group not found';

  @override
  String get giGroupInfo => 'Group info';

  @override
  String get giGroupCall => 'Group call';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Group messages encrypted';

  @override
  String get giAdd => 'Add';

  @override
  String get giMe => 'me';

  @override
  String get giAdministrator => 'Admin';

  @override
  String get giLeaveGroup => 'Leave group';

  @override
  String get sfNoLocationShared => 'Location not shared';

  @override
  String get sfLocationShared => 'Location shared';

  @override
  String sfDistanceMeters(Object m) {
    return '$m m away';
  }

  @override
  String sfDistanceKm(Object km) {
    return '$km km away';
  }

  @override
  String get sfBearingN => 'to the north';

  @override
  String get sfBearingNE => 'to the northeast';

  @override
  String get sfBearingE => 'to the east';

  @override
  String get sfBearingSE => 'to the southeast';

  @override
  String get sfBearingS => 'to the south';

  @override
  String get sfBearingSW => 'to the southwest';

  @override
  String get sfBearingW => 'to the west';

  @override
  String get sfBearingNW => 'to the northwest';

  @override
  String get sfBroadcastSafeTitle => 'Broadcast \"I\'m safe\"?';

  @override
  String get sfBroadcastSafeMessage =>
      'This status will be visible to the whole mesh in range, not just your contacts. You can include an approximate location (rounded, never exact).';

  @override
  String get sfWithLocation => 'With approx. location';

  @override
  String get sfWithoutLocation => 'Without location';

  @override
  String get sfStatusBroadcast => 'Status broadcast to the mesh';

  @override
  String get sfBroadcastFailed => 'Broadcast failed';

  @override
  String get sfHelpRequestTitle => 'Broadcast \"I need help\"?';

  @override
  String get sfHelpRequestMessage =>
      'This status will signal to peers in range that you need assistance. You can include an approximate location.';

  @override
  String get sfHelpRequestBroadcast => 'Help request broadcast to the mesh';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Emergency mode';

  @override
  String get sfViewOnMap => 'View on map';

  @override
  String get sfNeedHelp => 'I need help';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-ins received ($count)',
      one: 'Check-in received ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'No check-ins received yet';

  @override
  String get sfCheckinsAppearHere =>
      '\"Safe\" statuses broadcast by peers in range will appear here.';

  @override
  String get sfSafeLabel => 'Safe';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'Safe · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'Safe · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Broadcast my safety status to the mesh network';

  @override
  String get sfImSafe => 'I\'m safe';

  @override
  String get emSosActive => 'SOS ACTIVE';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'SOS signal active — broadcast to all nearby devices';

  @override
  String get emPullToSendSignal => 'Tap to send an emergency signal';

  @override
  String get emSignalRelayedDescription =>
      'The signal is relayed peer to peer\nacross the entire mesh network.';

  @override
  String get emBroadcasting => 'Broadcasting...';

  @override
  String get emSharePosition => 'Share my location';

  @override
  String get emSosActivated => 'SOS signal activated';

  @override
  String get emSafeStatusMessage => '🟢 I\'m safe';

  @override
  String get emSafetyStatusBroadcast => 'Safety status broadcast';

  @override
  String get pmEnterPayingNumber =>
      'Enter the number that will pay (9 digits).';

  @override
  String get pmRequestSent => 'Request sent…';

  @override
  String get pmPaymentLaunchFailed =>
      'The payment could not be started. Check the number and your connection, or pay manually below.';

  @override
  String get pmValidateOnPhone =>
      'Confirm on your phone: enter your Mobile Money code when the prompt appears.';

  @override
  String get pmPaymentNotConfirmed =>
      'Payment not confirmed. Nothing was unlocked.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'The payment went through but the received license is invalid. Write to us, it will be redone: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro activated';

  @override
  String get pmPackUnlocked => 'Pack unlocked';

  @override
  String get pmInvalidCode =>
      'This code is not valid on this device. Make sure you sent the device code shown above.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'What Droplet\nwill never ask for';

  @override
  String get pmNeverAskBody =>
      'No ads, no mandatory subscription, no reselling your data — there isn\'t even a server to collect it. The pack and Pro fund the rest.';

  @override
  String get pmCommunitySemantics =>
      'Join the community of over 1,200 active members';

  @override
  String get pmCommunityText => 'Join 1,200+ members on the mesh';

  @override
  String get pmProPreviewSemantics => 'Preview of unlocked Pro features';

  @override
  String get pmAnimatedEmojis => 'Animated\nemojis';

  @override
  String get pmWallpapers => 'Chat\nwallpapers';

  @override
  String get pmAppIcons => 'App\nicons';

  @override
  String get pmOnceForLife => 'once, for life';

  @override
  String get pmProAdvantage1 => 'The pack\'s ten icons and eight wallpapers';

  @override
  String get pmProAdvantage2 => 'The Pro badge next to your name';

  @override
  String get pmProAdvantage3 => 'Future features, at no extra cost';

  @override
  String get pmPackTitle => 'The pack';

  @override
  String get pmOnce => 'once';

  @override
  String get pmPackAdvantage1 => 'Ten additional app icons';

  @override
  String get pmPackAdvantage2 => 'Eight chat wallpapers';

  @override
  String get pmPayByHand => 'Or pay manually';

  @override
  String get pmHowTo => 'How it works';

  @override
  String get pmIfPromptDoesNotArrive =>
      'If the prompt doesn\'t arrive on your phone, or if you prefer to send the money yourself.';

  @override
  String pmStep1Title(Object montant) {
    return 'Send $montant F';
  }

  @override
  String get pmStep1Body =>
      'Choose your operator: its menu opens, and the number stays shown here while you navigate it.';

  @override
  String get pmStep2Title => 'Send your device code';

  @override
  String get pmStep2Body =>
      'Along with the payment screenshot. Without this code, the license cannot be created — it\'s only valid for your phone.';

  @override
  String get pmStep3Title => 'You receive a license';

  @override
  String get pmStep3Body =>
      'A long line starting with DROP1. Paste it below: the unlock is instant and works offline, forever.';

  @override
  String get pmPayNow => 'Pay now';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money or Orange Money, from this phone or another one.';

  @override
  String get pmPhoneNumberSemantics =>
      'Phone number for the Mobile Money payment';

  @override
  String get pmWaitingForCode => 'Waiting for your code…';

  @override
  String pmPayAmount(Object montant) {
    return 'Pay $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Restore a previous purchase';

  @override
  String get pmAlreadyPaidRestore => 'Already paid? Restore';

  @override
  String pmDialCode(Object code) {
    return 'Dial $code from your phone';
  }

  @override
  String get pmChooseOperatorSemantics => 'Choose a payment operator';

  @override
  String get pmNumberAmountFilled =>
      'Number and amount already filled in — only your secret code remains.';

  @override
  String get pmOrangeMenuInstructions =>
      'In the Orange menu: money transfer, then the number and amount below.';

  @override
  String get pmLabelNumber => 'Number';

  @override
  String get pmLabelAmount => 'Amount';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Pay $montant francs with $operator';
  }

  @override
  String get pmMenuOpen => 'Menu open';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Hello, I just paid for Droplet.\n\nOffer: $offer\nAmount: $amount F\nDevice code: $code\n\n(attaching the payment screenshot)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp not found — code copied. Send it to $contact';
  }

  @override
  String get pmPrepareRequest => 'Prepare my request';

  @override
  String get pmReceivedLicense => 'I received my license';

  @override
  String get pmPaste => 'Paste';

  @override
  String get pmUnlock => 'Unlock';

  @override
  String get pmProIsActive => 'Droplet Pro is active';

  @override
  String get pmPackIsUnlocked => 'The pack is unlocked';

  @override
  String get pmProActiveDescription =>
      'The Pro badge accompanies your name, and every icon and wallpaper is unlocked for you.';

  @override
  String get pmPackActiveDescription =>
      'The pack\'s ten icons and eight wallpapers are unlocked for you, in settings.';

  @override
  String get pmLicenseDeviceBound =>
      'Your license is valid for this phone. If you change phones, keep the message that contains it: it will be redone for free.';

  @override
  String torError(Object e) {
    return 'Error: $e';
  }

  @override
  String get torEnable => 'Enable Tor';

  @override
  String get torProtected => 'Protected';

  @override
  String get torDisabled => 'Disabled';

  @override
  String get torStateHeader => 'Status';

  @override
  String get torCircuit => 'Circuit';

  @override
  String get torActive => 'Active';

  @override
  String get torInProgress => 'In progress…';

  @override
  String get torInactive => 'Inactive';

  @override
  String get torFailed => 'Failed';

  @override
  String get torReason => 'Reason';

  @override
  String get torBannerConnecting => 'Connecting to Tor…';

  @override
  String get torBannerActive => 'Tor active';

  @override
  String get torBannerError => 'Tor unavailable';

  @override
  String get torBannerOff => 'Tor off';

  @override
  String get torEncryption => 'Encryption';

  @override
  String get torLatency => 'Latency';

  @override
  String get torContactsHeader => 'Contacts';

  @override
  String get torScanQrFooter =>
      'Scan a QR code, or search a name in the directory, to add a remote contact.';

  @override
  String get torScanQrCode => 'Scan a QR Code';

  @override
  String get torMyQrCode => 'My QR Code';

  @override
  String get torInformationHeader => 'Information';

  @override
  String get torVersion => 'Version';

  @override
  String get torHowItWorks => 'How does it work?';

  @override
  String get torConnecting => 'Connecting…';

  @override
  String get torInactiveTitle => 'Tor inactive';

  @override
  String get torDataThroughTor => 'Your data goes through the Tor network';

  @override
  String get torEstablishingCircuit => 'Establishing circuit (10-30s)';

  @override
  String get torActivateToProtect => 'Turn on to protect your identity';

  @override
  String get torHowItWorksTitle => 'How Tor protects your data';

  @override
  String get torEncryptedCircuit => 'Encrypted circuit';

  @override
  String get torEncryptedCircuitDesc =>
      'Your messages pass through 3 Tor relays around the world.';

  @override
  String get torHiddenIp => 'Hidden IP';

  @override
  String get torHiddenIpDesc => 'No site can see your real address.';

  @override
  String get torMeshPreserved => 'Mesh preserved';

  @override
  String get torMeshPreservedDesc => 'Bluetooth and local Wi-Fi keep working.';

  @override
  String get torUnderstood => 'Got it';

  @override
  String get qrTorNotActive =>
      'Tor is not active. Enable it in Settings > Tor.';

  @override
  String get qrScanContactCode => 'Scan a contact\'s QR code';

  @override
  String get qrCodeFromContactScreen =>
      'The code must come from your contact\'s Tor screen';

  @override
  String get qrScanAnother => 'Scan another';

  @override
  String get qrChat => 'Chat';

  @override
  String get qgScanToConnect => 'Scan to connect';

  @override
  String get qgCopied => 'Copied ✓';

  @override
  String get qgCopyCode => 'Copy the code';

  @override
  String get qgHowItWorks => 'How it works';

  @override
  String get qgStep1 => 'Show this QR code to your contact';

  @override
  String get qgStep2 => 'They scan it from their Tor screen';

  @override
  String get qgStep3 => 'You\'re connected via Tor';

  @override
  String get shShareTo => 'Share to…';

  @override
  String get shSearchConversation => 'Search a conversation';

  @override
  String get shNoConversation => 'No conversation';

  @override
  String get shOpenChatFirst =>
      'Open a conversation in Droplet first so you can share content there.';

  @override
  String get shGroup => 'Group';

  @override
  String get shDiscussion => 'Chat';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to share',
      one: '$count item to share',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Map installed';

  @override
  String get omClearCacheTitle => 'Clear the cache?';

  @override
  String get omRemoveZoneTitle => 'Remove this area?';

  @override
  String get omClearCacheMessage =>
      'The areas you\'ve browsed will no longer be available offline. They will rebuild themselves as you view them again with network access.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '“$name” will be removed from this device.';
  }

  @override
  String get omClear => 'Clear';

  @override
  String get omTitle => 'Maps';

  @override
  String get omReading => 'Reading…';

  @override
  String get omNoMapsSaved => 'No map saved';

  @override
  String omSizeOnDevice(Object size) {
    return '$size on this device';
  }

  @override
  String get omBrowseMapHint =>
      'Browse the map with network access: the areas you view stay available offline.';

  @override
  String get omOnThisDevice => 'On this device';

  @override
  String get omZonesFillThemselves =>
      'Viewed areas fill in on their own as you browse the map with network access.';

  @override
  String get omMbtilesExplainer =>
      'An .mbtiles file contains an entire region, prepared in advance. It\'s the standard format for offline maps: any mapping tool can produce one.';

  @override
  String get omImportMap => 'Import a map';

  @override
  String get omReadingFile => 'Reading file…';

  @override
  String get omMbtilesFromPhone => '.mbtiles file from this phone';

  @override
  String get omAttributionText =>
      'The data comes from OpenStreetMap (ODbL license), the map tiles are served by CARTO. Droplet never downloads an entire region in advance: no free service allows it. Only what you view is kept.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiles',
      one: '$count tile',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '${k}k tiles';
  }

  @override
  String omSizeKb(Object n) {
    return '$n KB';
  }

  @override
  String omSizeMb(Object n) {
    return '$n MB';
  }

  @override
  String omSizeGb(Object n) {
    return '$n GB';
  }

  @override
  String get nwTitle => 'News';

  @override
  String get nwStatusesNetwork24h => 'Network statuses · 24 h';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count network statuses',
      one: '$count network status',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Publish a status';

  @override
  String get nwNoNewsYet => 'No news for now';

  @override
  String get nwStatusesAppearHere =>
      'Statuses published by people in range will appear here, without going through the internet.';

  @override
  String get nwRecent => 'Recent';

  @override
  String get nwStatusExpires =>
      'A status disappears on its own 24 hours after it\'s published.';

  @override
  String get nwPhoto => '📷 Photo';

  @override
  String get nwVideo => '🎥 Video';

  @override
  String get nwVoiceMessage => '🎤 Voice message';

  @override
  String get nwMusic => '🎵 Music';

  @override
  String get nwStatusFallback => 'Status';

  @override
  String get nwMyStatus => 'My status';

  @override
  String get nwTapToPublish => 'Tap to publish to the network';

  @override
  String get nwNotSeenYet => 'Not seen yet';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen by $count',
      one: 'Seen by $count',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Location unavailable — check that location services are enabled.';

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
    return '$distance from you';
  }

  @override
  String get mpTitle => 'Location';

  @override
  String get mpOffline => 'Offline';

  @override
  String get mpOnlineMap => 'Online map';

  @override
  String get mpMyPosition => 'My location';

  @override
  String get mpLayers => 'Layers';

  @override
  String get mpOfflineToast =>
      'Offline map: only areas already saved will be shown.';

  @override
  String get mpOnlineToast =>
      'Online map: the areas you view will be saved for later.';

  @override
  String get mpMapLabel => 'Map';

  @override
  String get mpSatelliteLabel => 'Satellite';

  @override
  String get mpSatelliteMode => 'Satellite mode';

  @override
  String get mpMapMode => 'Map mode';

  @override
  String get mpWrite => 'Write';

  @override
  String get mpCenter => 'Center';

  @override
  String get mpNoOneOnMap => 'No one on the map';

  @override
  String get mpPositionsAppearHere =>
      'Locations appear here when a contact shares theirs from Safety mode.';

  @override
  String get mpYou => 'You';

  @override
  String get mnTitle => 'Mesh network';

  @override
  String get mnPeers => 'Peers';

  @override
  String get mnAvgHops => 'Avg. hops';

  @override
  String get mnSignal => 'Signal';

  @override
  String get mnStrong => 'Strong';

  @override
  String get mnMedium => 'Medium';

  @override
  String get mnSearchingPeers => 'Searching for peers in range…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peers connected',
      one: '$count peer connected',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'No peer connected yet';

  @override
  String get mnGetCloserHint =>
      'Get closer to another device with Droplet installed — discovery happens automatically, no setup needed.';

  @override
  String get mnConnectedPeersHeader => 'Connected peers';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hops',
      one: '$count hop',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Local Wi-Fi';

  @override
  String get mnP2pNative => 'Native P2P';

  @override
  String get mnActiveGateway => 'Active gateway';

  @override
  String get mnPath => 'Path';

  @override
  String get mnTransport => 'Transport';

  @override
  String get mnBattery => 'Battery';

  @override
  String get mnScore => 'Score';

  @override
  String get mnReconnecting => 'Reconnecting';

  @override
  String get cnBronze => 'Bronze';

  @override
  String get cnSilver => 'Silver';

  @override
  String get cnGold => 'Gold';

  @override
  String get cnDiamond => 'Diamond';

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
    return '$points before $tier tier';
  }

  @override
  String get cnRelayedMessages => 'Messages relayed for others';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n pts';
  }

  @override
  String get cnGatewayMinutes => 'Minutes in relay mode (gateway)';

  @override
  String get cnExplanation =>
      'Every message your device relays for others, and every minute it stays available as a relay, helps the mesh network reach more people, further. This badge has no effect on the app — it\'s just a recognition of your contribution.';

  @override
  String get nmTitle => 'New message';

  @override
  String get nmNewGroup => 'New group';

  @override
  String get nmScanCode => 'Scan a code';

  @override
  String get nmVerifyContactIdentity => 'Verify a contact\'s identity';

  @override
  String get nmNoOneInRange => 'No one in range';

  @override
  String get nmNoResult => 'No results';

  @override
  String get nmPeopleWillAppearHere =>
      'People your device detects will appear here.';

  @override
  String get nmInRange => 'In range';

  @override
  String get nmDirectConnection => 'Direct connection';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Via $count relays',
      one: 'Via $count relay',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'File too large (max 50 MB)';

  @override
  String get chCannotReadMedia => 'Unable to read this media';

  @override
  String get chLocationDenied =>
      'Location denied — enable it in your phone settings to share your position.';

  @override
  String get chGettingPosition => 'Getting your position…';

  @override
  String get chPositionUnavailable =>
      'Location unavailable — try again outdoors.';

  @override
  String get chMicPermissionDenied => 'Microphone permission denied';

  @override
  String get chCannotStartRecording => 'Unable to start recording';

  @override
  String get chVoiceSendFailed => 'Unable to send the voice message';

  @override
  String get chFileSendFailed => 'Unable to send the file';

  @override
  String get chAudioNotFullyReceived => 'Audio not fully received yet';

  @override
  String get chVoiceUnreadable =>
      'This voice message can\'t be played — it may have arrived incomplete.';

  @override
  String get chFileNotFullyReceived => 'File not fully received yet';

  @override
  String get chSaveFailed => 'Unable to save';

  @override
  String chSavedIn(Object folder) {
    return 'Saved to $folder';
  }

  @override
  String get chMessageCopied => 'Message copied';

  @override
  String get chCallImpossibleRelay =>
      'Voice call not possible: this peer is only reachable via relay or Bluetooth, too slow for voice. Get closer to switch to Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'URL copied: $url';
  }

  @override
  String get chEditMessageTitle => 'Edit message';

  @override
  String get chMessageHint => 'Message';

  @override
  String get chNeverMet => 'Never met';

  @override
  String get chSeenJustNow => 'Seen just now';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $count minutes ago',
      one: 'Seen $count minute ago',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $count hours ago',
      one: 'Seen $count hour ago',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Seen yesterday';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $count days ago',
      one: 'Seen $count day ago',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Out of range';

  @override
  String get chCloseSearchTooltip => 'Close search';

  @override
  String get chNetworkDetailsSemantics => 'Droplet network, view details';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'typing…';

  @override
  String get chBroadcastChannel => 'Broadcast channel';

  @override
  String get chNearby => 'Nearby';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reachable via $count relays',
      one: 'Reachable via $count relay',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Reconnecting…';

  @override
  String get chSearchInConversation => 'Search in conversation';

  @override
  String get chVoiceCall => 'Voice call';

  @override
  String get chVideoCall => 'Video call';

  @override
  String get chCallImpossibleBtRelay =>
      'Call not possible: Bluetooth or relayed link';

  @override
  String get chGroupInfoTooltip => 'Group info';

  @override
  String get chNoneFound => 'None';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Older result';

  @override
  String get chNewerResult => 'Newer result';

  @override
  String get chLoadingOlderMessages => 'Loading earlier messages…';

  @override
  String get chToday => 'Today';

  @override
  String get chYesterday => 'Yesterday';

  @override
  String get chMonday => 'Monday';

  @override
  String get chTuesday => 'Tuesday';

  @override
  String get chWednesday => 'Wednesday';

  @override
  String get chThursday => 'Thursday';

  @override
  String get chFriday => 'Friday';

  @override
  String get chSaturday => 'Saturday';

  @override
  String get chSunday => 'Sunday';

  @override
  String get chSayHello => 'Say hello 👋';

  @override
  String get chBroadcastEmptyBody => 'Messages with no recipient appear here.';

  @override
  String get chP2pRelayedBody =>
      'Your exchanges are relayed peer to peer, with no Internet.';

  @override
  String get chReply => 'Reply';

  @override
  String get chReplyInThread => 'Reply in thread';

  @override
  String get chCopy => 'Copy';

  @override
  String get chAccessibilityMe => 'Me';

  @override
  String get chPhotoLabel => 'Photo';

  @override
  String get chVideoLabel => 'Video';

  @override
  String get chVoiceMessageLabel => 'Voice message';

  @override
  String chFileLabel(Object name) {
    return 'File $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'sending';

  @override
  String get chPendingStatus => 'pending';

  @override
  String get chFailedStatus => 'send failed';

  @override
  String get chReadStatus => 'read';

  @override
  String get chDeliveredStatus => 'delivered';

  @override
  String get chSentStatus => 'sent';

  @override
  String get chForwarded => 'Forwarded';

  @override
  String get chRetrySendLabel => 'Retry sending';

  @override
  String get chTransmissionDetailsLabel => 'Transmission details';

  @override
  String get chEditedBadge => 'edited';

  @override
  String get chFileWord => 'File';

  @override
  String chSizeBytes(Object n) {
    return '$n B';
  }

  @override
  String chSizeKb(Object n) {
    return '$n KB';
  }

  @override
  String chSizeMb(Object n) {
    return '$n MB';
  }

  @override
  String get chVideoReceiving => 'Video is being received';

  @override
  String get chPreparingVideo => 'Preparing video…';

  @override
  String get nmContacts => 'Contacts';

  @override
  String get nmFindByPseudo => 'Find by username';

  @override
  String get nmViaInternet => 'Via Internet';

  @override
  String get nmOutOfRange => 'Out of range';

  @override
  String get chatsInvitePerson => 'Invite someone';

  @override
  String get ivTitle => 'Invite your people';

  @override
  String get ivSubtitle =>
      'Droplet is better when the people who matter are here — even without a network.';

  @override
  String get ivByNumber => 'By phone number';

  @override
  String get ivNumberHint => 'Number with country code (+1…)';

  @override
  String get ivContacts => 'Contacts';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'By link';

  @override
  String get ivCopy => 'Copy';

  @override
  String get ivShare => 'Share';

  @override
  String get ivCopied => 'Link copied';

  @override
  String get ivByQr => 'By QR code';

  @override
  String get ivQrHint => 'Let the person scan it, face to face.';

  @override
  String get ivScan => 'Scan a code';

  @override
  String get ivPrivacy =>
      'The link and code only hold your public ID and key. No number is ever sent to Droplet.';

  @override
  String get evTitle => 'Edit video';

  @override
  String evSplit(int n) {
    return 'Split into $n statuses';
  }

  @override
  String evSplitHint(int s) {
    return 'Each part lasts at most $s s';
  }

  @override
  String evPublished(int n) {
    return '$n statuses posted';
  }

  @override
  String get svReply => 'Reply';

  @override
  String get svStatusLabel => 'Status';

  @override
  String svSeenBy(int n) {
    return 'Seen by $n';
  }

  @override
  String get clMissedVoice => 'Missed voice call';

  @override
  String get clMissedVideo => 'Missed video call';

  @override
  String get clCallBack => 'Call back';

  @override
  String get stoTitle => 'Storage';

  @override
  String get stoSubtitle => 'Photos, videos and files';

  @override
  String stoUsed(String taille) {
    return '$taille used';
  }

  @override
  String get stoPhotos => 'Photos';

  @override
  String get stoVideos => 'Videos';

  @override
  String get stoAudio => 'Voice & audio';

  @override
  String get stoDocuments => 'Documents';

  @override
  String get stoOther => 'Other (statuses…)';

  @override
  String get stoByChat => 'By chat';

  @override
  String get stoEmpty => 'No files on this phone';

  @override
  String stoDelete(int n) {
    return 'Delete ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'These files and their messages will be deleted from this phone.';

  @override
  String get tabSelectChat => 'Choose a chat';

  @override
  String get clConnecting => 'Connecting…';

  @override
  String chUnreadMessages(int n) {
    return '$n unread message(s)';
  }

  @override
  String get csMessagesSection => 'Messages';

  @override
  String chGroupTyping(String noms) {
    return '$noms is typing…';
  }

  @override
  String get tsReadBy => 'Read by';

  @override
  String get tsDeliveredTo => 'Delivered to';

  @override
  String get tsWaitingFor => 'Waiting';

  @override
  String get chSelect => 'Select';

  @override
  String get chForward => 'Forward';

  @override
  String get chForwardTo => 'Forward to…';

  @override
  String chSelectedCount(int n) {
    return '$n selected';
  }

  @override
  String get chForwarded1 => 'Message forwarded';

  @override
  String get apCaptionHint => 'Add a caption…';

  @override
  String get apValidateCrop => 'Crop';

  @override
  String get chMediaReceiving => 'Receiving';

  @override
  String get chStickersTooltip => 'Stickers';

  @override
  String get chAttachTooltip => 'Attach';

  @override
  String get chDeleteRecordingTooltip => 'Delete recording';

  @override
  String get chSlideToCancel => 'Slide to cancel';

  @override
  String chReplyingTo(Object pseudo) {
    return 'Replying to $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Loud';

  @override
  String get chEffectGentle => 'Gentle';

  @override
  String get chEffectInvisibleInk => 'Invisible ink';

  @override
  String get chEffectConfetti => 'Confetti';

  @override
  String get chEffectFireworks => 'Fireworks';

  @override
  String get chEffectHearts => 'Hearts';

  @override
  String get chEffectSheetTitle => 'Message effect';

  @override
  String get chEffectSheetSubtitle =>
      'Plays once, on your screen and your correspondent\'s';

  @override
  String get chOnBubble => 'On the bubble';

  @override
  String get chFullscreen => 'Fullscreen';

  @override
  String get chTapToReveal => 'Tap to reveal';

  @override
  String get chThreadTitle => 'Thread';

  @override
  String get chReplyHint => 'Reply…';

  @override
  String get chCollapse => 'Collapse';

  @override
  String get chSeeMore => 'See more';

  @override
  String get chMessageOptionsSemantics => 'Message options';

  @override
  String get chLoveReactionSemantics => 'Love it';

  @override
  String get chBroadcastMesh => 'Mesh broadcast';

  @override
  String get chGroupFallback => 'Group';

  @override
  String get ciSetupBiometrics =>
      'Set up a fingerprint or Face ID in your device settings.';

  @override
  String get ciEnableLockReason => 'Enable lock for this conversation';

  @override
  String get ciInfoTitle => 'Info';

  @override
  String get ciViewConversation => 'View conversation';

  @override
  String get ciGatewayOnline => 'Gateway · online';

  @override
  String get ciOnline => 'Online';

  @override
  String get ciOffline => 'Offline';

  @override
  String get ciMessages => 'Messages';

  @override
  String get ciMedia => 'Media';

  @override
  String get ciStart => 'Start';

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
      other: 'Voice notes ($count)',
      one: 'Voice note ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Files ($count)',
      one: 'File ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'No media shared yet.';

  @override
  String get ciSecurityCode => 'Security code';

  @override
  String get ciVerified => 'Verified';

  @override
  String get ciKeyChanged => 'The key has changed';

  @override
  String get ciNotVerified => 'Not verified';

  @override
  String get ciConversationLock => 'Conversation lock';

  @override
  String get ciLockEnabled => 'Enabled — fingerprint required to open';

  @override
  String get ciDisabled => 'Disabled';

  @override
  String get ciEphemeralMessages => 'Disappearing messages';

  @override
  String get ci30Seconds => '30 seconds';

  @override
  String get ci5Minutes => '5 minutes';

  @override
  String get ci1Hour => '1 hour';

  @override
  String get ci24Hours => '24 hours';

  @override
  String get ciDurationBeforeDisappear => 'Time before disappearing';

  @override
  String get ciBlockContactTitle => 'Block this contact?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo will no longer be able to send you messages. You can unblock them at any time.';
  }

  @override
  String get ciBlock => 'Block';

  @override
  String get ciUnblock => 'Unblock';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo has been blocked';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo has been unblocked';
  }

  @override
  String get ciReportContactTitle => 'Report this contact?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'An anonymous report will be sent to Droplet: a technical identifier and the reason you choose below, nothing else. No message, no conversation with $pseudo is ever transmitted.';
  }

  @override
  String get ciReport => 'Report';

  @override
  String get ciReportSent => 'Report sent. Thank you.';

  @override
  String get ciReportFailed =>
      'The report could not be sent — try again later.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Harassment';

  @override
  String get ciReportReasonIllegal => 'Illegal content';

  @override
  String get ciReportReasonOther => 'Other';

  @override
  String mcReactWith(Object emoji) {
    return 'React with $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh active';

  @override
  String get nsNoDeviceInRange => 'No device in range';

  @override
  String get nsMessagesCirculate =>
      'Your messages travel from device to device, without going through the Internet.';

  @override
  String get nsGetCloser =>
      'Get closer to another Droplet device. Your messages are kept and will send themselves once you\'re in range.';

  @override
  String get nsDevicesInRange => 'Devices in range';

  @override
  String get nsReconnectingTitle => 'Reconnecting';

  @override
  String get nsLinkMomentarilyLost =>
      'Link momentarily lost, not given up on yet.';

  @override
  String get nsRelaysAvailable => 'Available relays';

  @override
  String get nsNoRelayAvailable =>
      'No device can forward your messages further at the moment.';

  @override
  String get nsViaBluetooth => 'Via Bluetooth';

  @override
  String get nsViaLocalWifi => 'Via local Wi-Fi';

  @override
  String get nsWifiCarriesMore =>
      'Wi-Fi carries files and voice; Bluetooth only carries text.';

  @override
  String get scInvalidQrCode => 'Invalid QR code';

  @override
  String get scWrongCode =>
      'This isn\'t the right code — the key doesn\'t match';

  @override
  String get scCodeVerified => 'Code verified';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Verified — $pseudo\'s key matches this code.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return '$pseudo\'s key has changed since the last verification.';
  }

  @override
  String get scNotVerifiedYet => 'Not verified yet.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Compare this code with the one shown on $pseudo\'s device, or scan their QR code directly to verify automatically.';
  }

  @override
  String get scContactKeyUnknown =>
      'Contact\'s key not known yet — reconnect to this peer on the mesh.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Scan $pseudo\'s code';
  }

  @override
  String get tsNotDelivered => 'Not delivered';

  @override
  String get tsRead => 'Read';

  @override
  String get tsDelivered => 'Delivered';

  @override
  String get tsSendingInProgress => 'Sending';

  @override
  String get tsWaitingForRelay => 'Waiting for a relay';

  @override
  String get tsSent => 'Sent';

  @override
  String tsSecondsSingular(Object value) {
    return '$value second';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value seconds';
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
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Transmission';

  @override
  String get tsStatus => 'Status';

  @override
  String get tsDelayUntilRead => 'Time until read';

  @override
  String get tsRoute => 'Route';

  @override
  String get tsRouteDetail =>
      'The devices that forwarded this message, in order.';

  @override
  String get tsPath => 'Path';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passed through $count devices',
      one: 'Passed through $count device',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Received directly';

  @override
  String get tsIntermediateDevicesDetail =>
      'Intermediate devices forwarded this message to you.';

  @override
  String get tsUnknown => 'Unknown';

  @override
  String get tsSentRouteNotReturned =>
      'The route of a sent message is not reported back to its sender.';

  @override
  String get tsNetwork => 'Network';

  @override
  String get tsMeshDroplet => 'Droplet mesh';

  @override
  String get tsNoServerNoOperator => 'No server, no carrier.';

  @override
  String get qsScanSecurityCode => 'Scan the security code';

  @override
  String get qsCodeDetected => 'Code detected';

  @override
  String get qsFrameQrCode =>
      'Frame the QR code shown on your contact\'s device';

  @override
  String get rmRecentVideo => 'Recent video';

  @override
  String get rmRecentPhoto => 'Recent photo';

  @override
  String get rmSeeAllPhotos => 'See all photos';

  @override
  String get rmSeeAll => 'See all';

  @override
  String get aicOriginal => 'Original';

  @override
  String get aicAzure => 'Azure';

  @override
  String get aicNeon => 'Neon';

  @override
  String get aicPaper => 'Paper';

  @override
  String get aicLagoon => 'Lagoon';

  @override
  String get aicAmethyst => 'Amethyst';

  @override
  String get aicGold => 'Gold';

  @override
  String get aicTide => 'Tide';

  @override
  String get aicDawn => 'Dawn';

  @override
  String get aicGlass => 'Glass';

  @override
  String get aicConstellation => 'Constellation';

  @override
  String get aicPrism => 'Prism';

  @override
  String get aicEmerald => 'Emerald';

  @override
  String get aicChangeIconTitle => 'Change the icon?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'The \"$name\" icon will replace the one on your home screen. Some launchers take a few seconds to show it, or require returning to the home screen.';
  }

  @override
  String get aicApply => 'Apply';

  @override
  String aicIconApplied(Object name) {
    return '\"$name\" icon applied';
  }

  @override
  String get aicChangeIconImpossible =>
      'Icon change not possible on this device';

  @override
  String get aicTitle => 'Icon';

  @override
  String get aicCurrentOnHomeScreen => 'The one shown on your home screen';

  @override
  String get aicUnavailablePlatform => 'Unavailable on this platform';

  @override
  String get aicAndroidExplanation =>
      'Android fixes an app\'s icon at install time. Droplet works around this by declaring several entry points, one per icon, and keeping only one active. Your launcher may take a few seconds to notice.';

  @override
  String get aicAndroidOnly =>
      'Changing the icon is only available on Android.';

  @override
  String get beWeak => 'Weak';

  @override
  String get beOkay => 'Okay';

  @override
  String get beStrong => 'Strong';

  @override
  String get bePasswordTooShort =>
      'The password must be at least 8 characters long';

  @override
  String get bePasswordsDontMatch => 'The two passwords don\'t match';

  @override
  String get beBackupSubject => 'Droplet backup';

  @override
  String get beBackupShareText =>
      'Encrypted backup of my Droplet identity — keep it somewhere safe.';

  @override
  String get beBackupCreated => 'Backup created';

  @override
  String get beBackupFailed => 'Backup failed';

  @override
  String get beBackupMyIdentity => 'Back up my identity';

  @override
  String get beWarningBody =>
      'Anyone with this file and the password can impersonate you. Keep it safe (never send it to anyone but yourself) and choose a password only you know.';

  @override
  String get bePasswordProtects =>
      'This password protects your backup. It is never stored: without it, the file becomes permanently unusable.';

  @override
  String get bePassword => 'Password';

  @override
  String get beConfirmPassword => 'Confirm password';

  @override
  String get beIncludeMessageHistory => 'Include message history';

  @override
  String get beOtherwiseOnlyIdentity =>
      'Otherwise, only the identity, contacts and groups are backed up';

  @override
  String get beCreateAndShare => 'Create and share the backup';

  @override
  String get jsErrorJournalTitle => 'Error log';

  @override
  String get jsNoErrorsRecorded =>
      'No errors recorded. This is the normal state.';

  @override
  String get jsLinesStayOnDevice =>
      'These lines stay on this device: Droplet has no server to send them to. If you\'re testing the app, please send them — without them, the bug doesn\'t exist for anyone.';

  @override
  String get jsErase => 'Erase';

  @override
  String get jsShareSubject => 'Droplet — error log';

  @override
  String get jsShareText =>
      'Droplet error log. This file contains no messages, contacts, or keys.';

  @override
  String get jsShareUnavailable => 'Sharing unavailable — log copied';

  @override
  String get clOutgoingCall => 'Calling…';

  @override
  String get clIncomingCall => 'Incoming call…';

  @override
  String get clCallImpossible => 'Call failed';

  @override
  String get clCallEnded => 'Call ended';

  @override
  String clCallWith(Object pseudo) {
    return 'Call with $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'End-to-end encrypted';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Call status: $status';
  }

  @override
  String get clEnableMic => 'Turn on microphone';

  @override
  String get clMuteMic => 'Mute microphone';

  @override
  String get clDisableSpeaker => 'Turn off speaker';

  @override
  String get clEnableSpeaker => 'Turn on speaker';

  @override
  String get clDisableCamera => 'Turn off camera';

  @override
  String get clEnableCamera => 'Turn on camera';

  @override
  String get clHangUp => 'Hang up';

  @override
  String get clIncomingVideoCall => 'Incoming video call';

  @override
  String get clSwitchCamera => 'Switch camera';

  @override
  String get gcGroupCall => 'Group call';

  @override
  String get gcConnecting => 'Connecting…';

  @override
  String get gcOnline => 'Online';

  @override
  String get gcFailed => 'Failed';

  @override
  String get gcDisconnected => 'Disconnected';

  @override
  String get gcReturnToCall => 'Return to call';

  @override
  String get gcMinimize => 'Minimize';

  @override
  String get gcVoiceOnly => 'Voice only';

  @override
  String gcReactWith(String emoji) {
    return 'React with $emoji';
  }

  @override
  String get gcSpeakingNow => 'Speaking now';

  @override
  String get gcMicOff => 'Mic off';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants · voice only',
      one: '$count participant · voice only',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Messages';

  @override
  String get ntfChannelMessagesDesc => 'New messages and mesh statuses';

  @override
  String get ntfChannelCallsName => 'Calls';

  @override
  String get ntfChannelCallsDesc => 'Incoming and missed calls';

  @override
  String get ntfChannelMeshName => 'Mesh & emergency';

  @override
  String get ntfChannelMeshDesc =>
      'Active mesh service, statuses and emergency messages';

  @override
  String get ntfReply => 'Reply';

  @override
  String get ntfYourReply => 'Your reply';

  @override
  String get ntfMarkAsRead => 'Mark as read';

  @override
  String get ntfIncomingCall => 'Incoming call';

  @override
  String get ntfAnswer => 'Answer';

  @override
  String get ntfDecline => 'Decline';

  @override
  String get ntfMissedCall => 'Missed call';

  @override
  String get ntfSendFailedTitle => 'Send failed';

  @override
  String get ntfSendFailedBody =>
      'A message couldn\'t be sent — it will retry as soon as a peer is in range.';

  @override
  String get ntfNewStatusTitle => 'New status';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo posted a status';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo liked your status';
  }

  @override
  String get ntfTapToView => 'Tap to view';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo replied to your status';
  }

  @override
  String get ntfEmergencyTitle => 'Emergency message';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo broadcast \"I\'m safe\"';
  }

  @override
  String get mnAccept => 'Accept';

  @override
  String get mnMeshVoiceCall => 'Mesh voice call';

  @override
  String get mnGroupCallIncoming => 'Incoming group call';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo is inviting you';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Group call · $count other participants',
      one: 'Group call · $count other participant',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Who can see this status?';

  @override
  String get asAllContacts => 'All my contacts';

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
  String get asExceptOption => 'Except...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count excluded',
      one: '$count excluded',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Exclude contacts';

  @override
  String get asOnlyOption => 'Only...';

  @override
  String get asShareWithSpecific => 'Share with specific contacts';

  @override
  String get asNoContactsAvailable => 'No contacts available';

  @override
  String get asConfirm => 'Confirm';

  @override
  String get apYourPhoto => 'Your photo';

  @override
  String get apNoPhotoAccessible => 'No photo accessible on this device.';

  @override
  String get apBrowseFiles => 'Browse files';

  @override
  String get apRecentPhoto => 'Recent photo';

  @override
  String get bgSkip => 'Skip';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Step $rang of $total.';
  }

  @override
  String get csGuideNetworkTitle => 'No one nearby? That\'s normal';

  @override
  String get csGuideNetworkText =>
      'Droplet doesn\'t go through any server: it talks to phones within range. Here you see who\'s reachable, and over which radio. Zero peers doesn\'t mean it\'s broken — just that no one is here yet.';

  @override
  String get csGuideWriteTitle => 'Write even with no one around';

  @override
  String get csGuideWriteText =>
      'A message written now waits on your phone and sets off as soon as a device comes within range — in the street, in a taxi. It isn\'t lost, it\'s waiting.';

  @override
  String get csGuideBackupTitle => 'Back up your identity';

  @override
  String get csGuideBackupText =>
      'Without a server, no one can give your account back to you. Export your identity from settings: without this backup, a lost phone takes everything with it.';

  @override
  String get csShowLockedChatsReason => 'Show locked chats';

  @override
  String get cvlNoBiometricsConfigured =>
      'No fingerprint set up on this device';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Unlock the conversation with $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Authentication failed';

  @override
  String get cvlAuthError => 'Authentication error';

  @override
  String get cvlConversationLocked => 'Locked conversation';

  @override
  String get cvlUnlock => 'Unlock';

  @override
  String get dcAddText => 'Add text';

  @override
  String get dcYourTextHint => 'Your text...';

  @override
  String get pbDropletProBadge => 'Droplet Pro badge';

  @override
  String get rpReact => 'React';

  @override
  String get rpSaveToPhone => 'Save to phone';

  @override
  String get chViaTor => 'Via Tor';

  @override
  String get chTorInactive => 'Tor inactive';

  @override
  String get chViaInternet => 'Via the internet';

  @override
  String get chReachedViaTorSemantic => 'Contact reached via Tor';

  @override
  String get nsTorConnectedTitle => 'Connected via Tor';

  @override
  String get nsTorInactiveTitle => 'Tor disabled';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'Your messages travel over the Tor network and wait in an encrypted mailbox until $pseudo connects to it.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Turn on Tor in settings to write to $pseudo — without it, your messages will stay waiting on this device.';
  }

  @override
  String get nsTorMailboxTitle => 'Encrypted mailbox';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Neither you nor Droplet can read what it holds — only $pseudo has the key.';
  }

  @override
  String get nsOpenTorSettings => 'Turn on Tor';

  @override
  String get qrInvalidCode => 'This QR code isn\'t a Droplet code.';

  @override
  String get qrPeerAdded => 'Contact added';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'You can now chat with $pseudo';
  }

  @override
  String get clViaInternet => 'Via the internet';

  @override
  String get tsPathTorDetail =>
      'This message doesn\'t travel through devices around you: it passes through an encrypted mailbox on the Tor network, accessible only to the two of you.';

  @override
  String get tsNetworkTorDetail =>
      'A relay server is needed to reach this contact remotely — Droplet can\'t avoid one here, unlike the local mesh.';

  @override
  String get torSearchDirectory => 'Search the directory';

  @override
  String get dvTitle => 'Search';

  @override
  String get dvClose => 'Close';

  @override
  String get dvSearchHint => 'Search for a name...';

  @override
  String get dvEnableTorToSearch =>
      'Enable Tor in settings to search the directory.';

  @override
  String get dvSearching => 'Searching…';

  @override
  String get dvNoResults => 'No results';

  @override
  String get dvNoUserFound => 'No user found for this search.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '$count result',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Send';

  @override
  String get aiNewConversation => 'New conversation';

  @override
  String get aiMessageHint => 'Message';

  @override
  String get aiCopied => 'Copied';

  @override
  String get aiAskQuestion => 'Ask a question';

  @override
  String get aiRunsLocally =>
      'This assistant runs entirely on your device — nothing is ever sent over the internet.';

  @override
  String get aiMemorySaved => 'I\'ll remember that.';

  @override
  String get aiMemoryForgotten =>
      'I\'ve forgotten what you asked me to remember.';

  @override
  String get aiMemoryTitle => 'Assistant memory';

  @override
  String get aiMemoryEmpty =>
      'Nothing saved yet. Say “remember that…” to pin something.';

  @override
  String get aiMemoryForget => 'Forget everything';

  @override
  String get aiExpertHint =>
      'I know Droplet inside out: the mesh, Tor, calls, privacy.';

  @override
  String get chAskAssistant => 'Ask the assistant';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Help me reply to $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Preparing the assistant… $percentage%';
  }

  @override
  String get aiOneTimeDownload =>
      'Just once — it then stays on your device, with no further download.';

  @override
  String get aiGenericError => 'Sorry, something went wrong.';

  @override
  String get aiNotAvailableYet =>
      'The assistant isn\'t available yet in this version of Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Someone is trying to reach you';

  @override
  String get ntfNewMessageWake => 'New message — open Droplet to read it';

  @override
  String get chNearbyAndInternet => 'Nearby · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relays · Internet',
      one: '$count relay · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'Waiting for internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nearby · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nearby · no internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'No one nearby · Internet';

  @override
  String get clPathMesh => 'Mesh · direct Wi-Fi';

  @override
  String get clPathInternetDirect => 'Internet · direct';

  @override
  String get clPathInternetRelay => 'Internet · secure relay';

  @override
  String get clReconnecting => 'Reconnecting…';

  @override
  String get clLabelSpeaker => 'Speaker';

  @override
  String get clLabelCamera => 'Camera';

  @override
  String get clLabelMic => 'Mic';

  @override
  String get clLabelFlip => 'Flip';

  @override
  String get clEncryptedShort => 'End-to-end encrypted';

  @override
  String clQualitySemantics(int bars) {
    return 'Call quality: $bars of 3';
  }

  @override
  String get beOnlineTitle => 'Automatic online backup';

  @override
  String get beOnlineBody =>
      'Every day, a copy encrypted with this password is kept on the Droplet server, which cannot read it. On a new phone, the same username and password are all you need. Received photos, videos and files are not included.';

  @override
  String get beOnlineSwitch => 'Back up to the server every day';

  @override
  String beOnlineLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get beOnlineNever => 'No online backup yet';

  @override
  String get beOnlineNow => 'Back up now';

  @override
  String get beOnlineDone => 'Online backup done';

  @override
  String get beOnlineFailed => 'Online backup not possible right now';

  @override
  String get obRestoreFromServer => 'Restore from the server';

  @override
  String get obEnterPseudoFirst => 'Enter your backup\'s username first';

  @override
  String get obNoServerBackup =>
      'No backup found for this username and password';

  @override
  String get obTooManyAttempts => 'Too many attempts — try again in an hour';

  @override
  String get chatsInviteLink => 'Invite with a link';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo invites you to Droplet, the encrypted messenger that works even without a network: $lien';
  }

  @override
  String get invTitle => 'Invitation';

  @override
  String invBody(String pseudo) {
    return '$pseudo invites you to chat on Droplet.';
  }

  @override
  String get invAdd => 'Add and write';

  @override
  String get invInvalid => 'This invitation link is invalid or incomplete.';

  @override
  String get invSelf => 'This is your own invitation link.';
  @override
  String get seAnimationHeader => 'Send animation';

  @override
  String get seAnimationFull => 'Full';

  @override
  String get seAnimationReduced => 'Reduced';

  @override
  String get seAnimationOff => 'Off';

  @override
  String get seAnimationFullDesc => 'Plic carries your message, teleports and waves back.';

  @override
  String get seAnimationReducedDesc => 'A simple fade, with no motion or particles.';

  @override
  String get seAnimationOffDesc => 'No animation after sending.';

  @override
  String get seAnimationReplay => 'Tap to replay';

  @override
  String get seAnimationNone => 'No animation';

  @override
  String get seAnimationSampleIn => 'See you at the docks?';

  @override
  String get seAnimationSampleOut => 'See you in a minute';

  @override
  String get trTitle => 'Translation';

  @override
  String get trOnDevice => 'Translating on device…';

  @override
  String get trUnknownLang => 'Unknown language';

  @override
  String get trOriginal => 'Original';

  @override
  String get trCopy => 'Copy';

  @override
  String get trInChat => 'In the chat';

  @override
  String get trRetry => 'Try again';

  @override
  String get trSame => 'This message is already in that language.';

  @override
  String get trModel => 'The model for this language isn\'t installed on this device yet.';

  @override
  String get trUnavailable => 'This device has no offline translation engine.';

  @override
  String get trFailed => 'The translation didn\'t go through.';

  @override
  String get pfMessage => 'Message';

  @override
  String get pfCall => 'Call';

  @override
  String get pfSecurity => 'Security';

  @override
  String get aiActCopy => 'Copy';

  @override
  String get aiActRead => 'Read aloud';

  @override
  String get aiActStop => 'Stop reading';

  @override
  String get aiActLike => 'Good response';

  @override
  String get aiActDislike => 'Bad response';

  @override
  String get aiActShare => 'Share';

  @override
  String get aiActRegenerate => 'Regenerate';

  @override
  String get aiFeedbackThanks => 'Thanks for your feedback';

  @override
  String get intelOnlineHeader => 'Translation & transcription';

  @override
  String get intelOnlineTitle => 'Online when connected';

  @override
  String get intelOnlineSubtitle => 'Free — MyMemory, Apple or Google';

  @override
  String get intelOnlineFooter => 'When off, nothing goes over the internet. When on and connected: text to translate goes to MyMemory; on iPhone, a voice message the device can\'t transcribe goes to Apple\'s speech service. For those trips, the content is no longer end-to-end encrypted. On Android, only the voice model is downloaded: voice messages stay on the phone. Link previews also contact the site in question.';

  @override
  String get trOnline => 'Translate online';

  @override
  String get trOnlineNote => 'The text will be sent to MyMemory, a free service. For that trip, it\'s no longer end-to-end encrypted.';

  @override
  String get trViaOnline => 'Translated online by MyMemory';

  @override
  String get vnModelDownloading => 'The voice model for this language is downloading. Try again in a moment.';

  @override
  String get vnModelNeeded => 'The voice model for this language is missing. Turn on “Online when connected” in Settings to download it once.';

  @override
  String get nwStatusHeader => 'Status';

  @override
  String get nwAddStatus => 'Add status';

  @override
  String get nwStatusNewA11y => 'new';

  @override
  String svReplySent(String name) {
    return 'Reply sent to $name';
  }

  @override
  String get blkYouBlocked => 'You blocked this contact.';

  @override
  String get blkUnblock => 'Unblock';

  @override
  String get blkListTitle => 'Blocked contacts';

  @override
  String get blkNone => 'No blocked contacts';

  @override
  String get blkFooter => 'A blocked contact can no longer message or call you, and no longer receives your statuses or your photo. They are not notified. Your phone still relays their messages meant for other people, without being able to read them: the mesh doesn\'t depend on who you block.';

  @override
  String blkUnblockTitle(String name) {
    return 'Unblock $name?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'Unblock $name to call?';
  }

  @override
  String get nvDone => 'Done';

  @override
  String get nvBack => 'Back';

  @override
  String get nvForward => 'Forward';

  @override
  String get nvShare => 'Share';

  @override
  String get nvOpenInBrowser => 'Open in Browser';

  @override
  String get nvReload => 'Reload';

  @override
  String get nvCopyLink => 'Copy Link';

  @override
  String get nvLinkCopied => 'Link copied';

  @override
  String get nvOpen => 'Open';

  @override
  String get nvMore => 'More';

  @override
  String get nvNotSecure => 'Not Secure';

  @override
  String get nvErrorTitle => 'Page unavailable';

  @override
  String get nvErrorBody => 'Droplet couldn\'t reach this site. The mesh network doesn\'t carry the web: you need an internet connection.';

  @override
  String get nvRetry => 'Try Again';

  @override
  String get ciLinks => 'Links';

  @override
  String get chatsFilterNearby => 'Nearby';


  @override
  String get chProxTitle => 'Droplet works without internet too';

  @override
  String get chProxActive => 'Droplet devices are in range';

  @override
  String get chProxBody => 'Nearby phones pass messages along. The more of you around, the further they go.';

  @override
  String get chProxSee => 'See who\'s around';

  @override
  String get chStickerPreview => 'Sticker';

  @override
  String get edCrop => 'Crop';

  @override
  String get edRotate => 'Rotate';

  @override
  String get edFilters => 'Filters';

  @override
  String get edAdjust => 'Adjust';

  @override
  String get edText => 'Text';

  @override
  String get edDraw => 'Draw';

  @override
  String get edTrim => 'Trim';

  @override
  String get edBrightness => 'Brightness';

  @override
  String get edContrast => 'Contrast';

  @override
  String get edSaturation => 'Saturation';

  @override
  String get edWarmth => 'Warmth';

  @override
  String get edVignette => 'Vignette';

  @override
  String get edIntensity => 'Intensity';

  @override
  String get edUndo => 'Undo edit';

  @override
  String get edDone => 'Done';

  @override
  String get edTextHint => 'Type something…';

  @override
  String get edDelete => 'Delete';

  @override
  String get edOriginal => 'Original';

  @override
  String get edStyle => 'Style';

  @override
  String get edBackground => 'Background';

  @override
  String get stNotificationsHeader => 'Notifications';

  @override
  String get stNotifPreview => 'Show preview';

  @override
  String get stNotifPreviewSubtitle => 'The message text appears in the notification. Turned off, the lock screen only announces a new message.';

  @override
  String get stSearchHint => 'Search settings';

  @override
  String get stSearchEmpty => 'No matching setting';

  @override
  String get chMentionAllSubtitle => 'Notify everyone';

  @override
  String get vuOnce => 'View once';

  @override
  String get vuOpened => 'Opened';

  @override
  String get vuPhoto => 'Photo';

  @override
  String get vuVideo => 'Video';

  @override
  String get vuMissing => 'This media hasn\'t arrived yet';

  @override
  String get pollClosed => 'Poll closed';

  @override
  String pollEndsAt(String quand) {
    return 'Ends at $quand';
  }

  @override
  String get vuVoice => 'Voice message';

  @override
  String get apPatternsHeader => 'Chat pattern';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Games';

  @override
  String get apPatternHome => 'Home';

  @override
  String get apPatternGarden => 'Garden';

  @override
  String get imTitle => 'Starred messages';

  @override
  String get imSubtitle => 'What you set aside';

  @override
  String get imAdd => 'Star';

  @override
  String get imRemove => 'Unstar';

  @override
  String get imAdded => 'Added to starred';

  @override
  String get imRemoved => 'Removed from starred';

  @override
  String get imEmptyBody => 'Press and hold a message to star it and find it here later.';

  @override
  String get imClearAll => 'Clear all';

  @override
  String get imClearAllBody => 'The messages stay in their chats; only the stars are removed.';

  @override
  String get imClear => 'Clear';

  @override
  String get imYou => 'You';

  @override
  String get imUnknown => 'Message';

  @override
  String get apPatternsFooter => 'The pattern sits behind all your chats.';

  @override
  String get grCreatedNoMessages => 'Group created · no messages';

  @override
  String get chatsDelete => 'Delete chat';

  @override
  String get chatsDeleteBody => 'The messages disappear from this phone. With no server, nobody can remove them from anyone else\'s.';

  @override
  String get chatsDeleteConfirm => 'Delete';

  @override
  String get chatsDeleted => 'Chat deleted';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Delete the chat with $nom?';
  }

  @override
  String get chatsDocument => 'Document';

  @override
  String get epTitle => 'Disappearing messages';

  @override
  String get epHeadline => 'Turn on disappearing messages in this chat';

  @override
  String get epBody => 'New messages will carry their own expiry: they disappear from both phones once the chosen time is up.';

  @override
  String get epDelayHeader => 'Message timer';

  @override
  String get epHours24 => '24 hours';

  @override
  String get epDays7 => '7 days';

  @override
  String get epDays90 => '90 days';

  @override
  String get epOff => 'Off';

  @override
  String get epFooter => 'The setting doesn\'t affect messages already sent: each keeps the timer it left with.';

  @override
  String get chOnlineNow => 'Online · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'On the internet $count min ago';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'On the internet $count h ago';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'On the internet $count d ago';
  }

  @override
  String get pdfMissing => 'This document isn\'t on this phone.';

  @override
  String get pdfUnreadable => 'This PDF can\'t be read — it may have arrived incomplete.';

  @override
  String get giDescription => 'Description';

  @override
  String get giDescriptionAdd => 'Add a description';

  @override
  String get giDescriptionNone => 'No description';

  @override
  String get giDescriptionHint => 'What is this group about?';

  @override
  String get giOnlyAdminsSend => 'Only admins can send';

  @override
  String get giOnlyAdminsSendBody => 'Other members can read but not reply.';

  @override
  String get giSearchMembers => 'Search members';

  @override
  String get chOnlyAdminsCanWrite => 'Only admins can write in this group';

  @override
  String grCreatedBy(String nom) {
    return '$nom created the group';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom added you';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom is no longer in the group';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui added $nom';
  }

  @override
  String get giQrInvite => 'QR code';

  @override
  String get giQrRenew => 'New code';

  @override
  String get giQrRenewed => 'New code created, the old one no longer works';

  @override
  String get giQrExpired => 'This code has expired';

  @override
  String get giQrExplainer => 'This code holds no keys. It only lets someone ask to join — your phone decides.';

  @override
  String get giQrAlreadyMember => 'You\'re already in this group';

  @override
  String get giQrNeedContact => 'Add the person inviting you first';

  @override
  String get giQrRequestFailed => 'The request couldn\'t be sent';

  @override
  String giQrRequestSent(String nom) {
    return 'Request sent to $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Valid for $count more h';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Valid for $count more min';
  }

  @override
  String get cvNearby => 'Nearby';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'Waiting';

  @override
  String get cvOutOfReach => 'Out of reach';

  @override
  String get chWillSendWhenNearby => 'Will send as soon as they\'re in range';

  @override
  String cvHops(int count) {
    return '$count hops';
  }

  @override
  String get nwSeenSection => 'Seen';

  @override
  String get nwReceivedHeader => 'Received';

  @override
  String get avTranslateTitle => 'Translation';

  @override
  String get avTranslateShort => 'Understand without leaving the app';

  @override
  String get avTranslateLong => 'The message is translated on your phone: its contents go to no one, not even a translation service. The original stays one tap away, because a translation is never quite the text.';

  @override
  String get apStickerQ => 'Got a sticker for that?';

  @override
  String get apOnline => 'online';

  @override
  String get apMessage => 'Message';

  @override
  String get apAutoTranslated => 'Translated automatically';

  @override
  String get apBgSend => 'Look at this background 😍';

  @override
  String get apBgA => 'Did you change something?';

  @override
  String get apBgB => 'It moves with every message 😮';

  @override
  String get apFormatQ => 'Where are we meeting?';

  @override
  String get apFormatDemo => 'Meet me **at 6 pm** outside the __big market__, code `4821`. Surprise: ||a cake||';

  @override
  String get apVoiceQ => 'Where are you?';

  @override
  String get apVoiceText => 'I\'m outside the pharmacy, I\'ll wait for you until 6.';

  @override
  String get apTransQ => 'Hey, all set?';

  @override
  String get apTransSource => 'Oui ! On se voit demain à l\'aéroport, porte 12 à 9 h.';

  @override
  String get apTransResult => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get hlpDataOnDevice => 'ON YOUR PHONE';

  @override
  String get hlpDataServers => 'WHAT GOES THROUGH A SERVER';

  @override
  String get hlpDataServersFooter => 'Without the internet, none of these servers is involved: phones talk directly.';

  @override
  String get hlpDataNone => 'WHAT DROPLET NEVER ASKS FOR';

  @override
  String get hlpRowKeys => 'Your identity';

  @override
  String get hlpRowKeysBody => 'A key pair made here, never sent anywhere';

  @override
  String get hlpRowMessages => 'Your messages';

  @override
  String get hlpRowMessagesBody => 'In the app\'s private storage, erased when you uninstall';

  @override
  String get hlpRowProfile => 'Name and photo';

  @override
  String get hlpRowProfileBody => 'Only reach the people you write to';

  @override
  String get hlpRowSettings => 'Your settings';

  @override
  String get hlpRowSettingsBody => 'Wallpaper, language, notifications — all stay here';

  @override
  String get hlpRowLog => 'Error log';

  @override
  String get hlpRowLogBody => 'A local file that never leaves on its own';

  @override
  String get hlpRowDirectory => 'Directory';

  @override
  String get hlpRowDirectoryBody => 'Sees a name and a public identifier. Requests via Tor: not your real IP';

  @override
  String get hlpRowMailbox => 'Mailbox';

  @override
  String get hlpRowMailboxBody => 'Holds an encrypted message until delivery. Cannot read it';

  @override
  String get hlpRowSignalling => 'Signalling';

  @override
  String get hlpRowSignallingBody => 'Sees two identifiers while connecting the call. No audio passes through';

  @override
  String get hlpRowRelay => 'Relay';

  @override
  String get hlpRowRelayBody => 'Forwards encrypted audio when the direct link fails';

  @override
  String get hlpNonePhone => 'Phone number';

  @override
  String get hlpNoneEmail => 'Email address';

  @override
  String get hlpNoneContacts => 'Your address book';

  @override
  String get hlpNoneLocation => 'Your location';

  @override
  String get hlpNoneAds => 'Advertising and trackers';

  @override
  String get hlpNoneAnalytics => 'Analytics';

  @override
  String get hlpQOffline => 'How does Droplet work without the internet?';

  @override
  String get hlpAOffline => 'Phones talk to each other directly, over Bluetooth and Wi-Fi. A message can also hop from phone to phone until it reaches its recipient, without ever passing through a server.';

  @override
  String get hlpQCrypto => 'Are my messages really encrypted?';

  @override
  String get hlpACrypto => 'Yes, end to end, with the Signal protocol. The key exists only on the two phones. Neither a relay, nor the mailbox, nor we can open a message.';

  @override
  String get hlpQNoAccount => 'Why does Droplet ask for no phone number or email?';

  @override
  String get hlpANoAccount => 'Because it doesn\'t need them. Your identity is a key made on your phone. Nothing to create, nothing to verify, and nothing to steal elsewhere.';

  @override
  String get hlpQPending => 'Why is my message still pending?';

  @override
  String get hlpAPending => 'Nobody is in range yet and the internet isn\'t there. The message waits on the phone and leaves as soon as a path opens — there\'s nothing to redo.';

  @override
  String get hlpQAddSomeone => 'How do I add someone?';

  @override
  String get hlpAAddSomeone => 'Bring your phones close: the person appears on their own. At a distance, share your invitation link, or scan their QR code.';

  @override
  String get hlpQUninstall => 'What happens if I uninstall the app?';

  @override
  String get hlpAUninstall => 'Everything is erased: messages, contacts, identity. No copy exists elsewhere, so no restore. Export your settings first if you\'re changing phones.';

  @override
  String get hlpQBattery => 'Does Droplet drain my battery?';

  @override
  String get hlpABattery => 'Looking for devices around you uses power. In Settings you can reduce it, or only enable it while the app is open.';

  @override
  String get hlpQReport => 'How do I report a problem?';

  @override
  String get hlpAReport => 'From Contact and support. You\'ll see the exact text that will be sent before it leaves — nothing leaves your phone without you.';

  @override
  String get svLikeStatus => 'Like status';

  @override
  String get svUnlikeStatus => 'Remove like';

  @override
  String get stAddPhotoSemantics => 'Add a profile photo';

  @override
  String get stChangePhotoSemantics => 'Change the profile photo';

  @override
  String get scOverheat => 'Phone overheating — Android shut down the video encoder. Let it cool for a few minutes.';

  @override
  String scTooHeavy(int mo) {
    return 'File too heavy — $mo MB maximum to cross the local network.';
  }

  @override
  String get scUnsupported => 'This format isn\'t supported for a status.';

  @override
  String get scUnreadableFile => 'Can\'t read this file';

  @override
  String get scUnreadableTrack => 'Can\'t read this track';

  @override
  String get scNothingCaptured => 'The recording captured nothing — try again.';

  @override
  String get scVideoTrimmed => 'Video shortened to 1 min 30 — only the beginning is published.';

  @override
  String get scUnreadableVideo => 'Unreadable video';

  @override
  String get chAiMe => 'Me';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Here is the end of a conversation in Droplet between the user ("Me") and $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'The user wants help replying to $pseudo. Suggest a short, natural reply, written in $langue, in the first person, as if they were sending it themselves. Give only the suggested reply, with no preamble.';
  }

  @override
  String get hlpSectionHeader => 'Help and privacy';

  @override
  String get hlpPrivacy => 'Privacy policy';

  @override
  String get hlpData => 'Your data';

  @override
  String get hlpDataValue => 'Nothing leaves';

  @override
  String get hlpContact => 'Contact and support';

  @override
  String get hlpPrivacyTitle => 'Privacy';

  @override
  String hlpUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get hlpOnlyFrEn => 'This text exists only in French and English. A loosely translated legal document would commit more than it would help.';

  @override
  String get hlpReadInEnglish => 'Read in English';

  @override
  String get hlpReadInFrench => 'Read in French';

  @override
  String get hlpDataTitle => 'Your data';

  @override
  String get hlpDataLead => 'What Droplet knows about you, line by line. Nothing here is a promise: every line matches code you can read.';

  @override
  String get hlpStays => 'Never leaves the device';

  @override
  String get hlpLeaves => 'Goes through a server';

  @override
  String get hlpNever => 'Does not exist';

  @override
  String get hlpCountTracking => 'data used to track you';

  @override
  String get hlpCountAccount => 'account to create';

  @override
  String get hlpCountServers => 'servers, and we name them';

  @override
  String get hlpHelpTitle => 'Help';

  @override
  String get hlpSearchHint => 'Search';

  @override
  String get hlpNoResult => 'No answer contains that word. Write to us — it may be a question missing from here.';

  @override
  String get hlpStillStuckFooter => 'If the answer isn\'t here, a person answers.';

  @override
  String get hlpContactTitle => 'Contact';

  @override
  String get hlpContactLead => 'A question, a problem, an idea. We read everything.';

  @override
  String get hlpBeforeWriting => 'Before writing';

  @override
  String get hlpHelpRowBody => 'Eight answers, readable without the internet';

  @override
  String get hlpWriteUs => 'Write to us';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'Email';

  @override
  String get hlpWhatsAppHello => 'Hello, I use Droplet and I have a question:';

  @override
  String get hlpEmailSubject => 'Droplet — question';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp isn\'t installed. The number $numero has been copied.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'The address $adresse has been copied.';
  }

  @override
  String get hlpReportHeader => 'A problem';

  @override
  String get hlpReport => 'Report a problem';

  @override
  String get hlpReportBody => 'You\'ll see what leaves before it leaves';

  @override
  String get hlpReportFooter => 'Droplet never sends a report on its own: it has no server for that. A problem only reaches us if you send it.';

  @override
  String get hlpReportSubject => 'Droplet — report';

  @override
  String get hlpReportSheetLead => 'Say what happened. The exact text that will be sent appears below.';

  @override
  String get hlpReportHint => 'What I was doing, and what happened…';

  @override
  String get hlpAttachLog => 'Attach the error log';

  @override
  String get hlpWhatWillBeSent => 'WHAT WILL BE SENT';

  @override
  String get hlpLogExcerpt => 'Log (end):';

  @override
  String get hlpCopy => 'Copy';

  @override
  String get hlpCopied => 'Copied';

  @override
  String get hlpOnePerson => 'Droplet is made by one person, not a support desk. An answer may take a day or two — it comes.';

  @override
  String get avSectionHeader => 'What Pro brings';

  @override
  String get avUnlock => 'Unlock Droplet Pro';

  @override
  String get avVoiceTitle => 'Voice to text';

  @override
  String get avVoiceShort => 'Read a voice note without playing it';

  @override
  String get avVoiceLong => 'Transcription happens on your phone, offline. The voice note goes nowhere, and you can read it in a meeting, on the bus, or with no network at all.';

  @override
  String get avFormatTitle => 'Text styles';

  @override
  String get avFormatShort => 'Bold, italic, code, spoiler';

  @override
  String get avFormatLong => 'A word in bold, a line of code, a hidden passage revealed with a tap: your message says exactly what you meant, and nothing else.';

  @override
  String get avWallpaperTitle => 'Wallpapers and patterns';

  @override
  String get avWallpaperShort => 'The whole gallery, and all four packs';

  @override
  String get avWallpaperLong => 'Every wallpaper is drawn by hand, every pattern checked on screen before it ships. Droplet, Games, Home, Garden: your chat screen looks like nobody else\'s.';

  @override
  String get avStickersTitle => 'Animated stickers';

  @override
  String get avStickersShort => 'The Droplet drop, in motion';

  @override
  String get avStickersLong => 'Stickers drawn for Droplet, animated frame by frame, and light enough to travel over the mesh with no internet at all.';

  @override
  String get avIconTitle => 'App icons';

  @override
  String get avIconShort => 'Change the icon on your home screen';

  @override
  String get avIconLong => 'A discreet messenger starts with its icon. Pick the one that looks like you — or the one nobody notices.';

  @override
  String get avBadgeTitle => 'Pro badge';

  @override
  String get avBadgeShort => 'It sits next to your name';

  @override
  String get avBadgeLong => 'It grants no power over anyone. It only says you paid so Droplet can stay free of ads, of forced subscriptions, and of data resale.';

  @override
  String get sgTitle => 'Group storage';

  @override
  String get sgEmpty => 'No file has been shared in this group yet.';

  @override
  String get sgByAuthor => 'Who sends the most';

  @override
  String get sgFiles => 'Files';

  @override
  String get sgSortRecent => 'Most recent';

  @override
  String get sgSortHeavy => 'Largest first';

  @override
  String get sgNotOnDevice => 'Not here';

  @override
  String get giPhotoChanged => 'Group photo changed';

  @override
  String get giPhotoFailed => 'This image couldn\'t be saved';

  @override
  String sgTotal(int count) {
    return '$count shared files';
  }

  @override
  String get vrTitle => 'Voice chat';

  @override
  String get vrJoin => 'Join';

  @override
  String get vrBack => 'Return';

  @override
  String get vrStart => 'Start a voice chat';

  @override
  String get vrNeedsInternet => 'A voice chat needs the internet: the mesh can carry a message that waits, not twenty voices at once.';

  @override
  String get vrUnreachable => 'The call server can\'t be reached right now.';

  @override
  String vrFull(int count) {
    return 'The room is full — $count people maximum.';
  }

  @override
  String get vrWaiting => 'Waiting for others…';

  @override
  String get vrWaitingBody => 'The room is open. Group members see it in the chat and join when they\'re free.';

  @override
  String vrPeople(int count) {
    return '$count people inside';
  }

  @override
  String get cvTitle => 'Chats';

  @override
  String get cvNew => 'New chat';

  @override
  String get cvPinned => 'Pinned';

  @override
  String get cvRecent => 'Recent';

  @override
  String get cvPin => 'Pin';

  @override
  String get cvUnpin => 'Unpin';

  @override
  String get cvRename => 'Rename';

  @override
  String get cvRenameHint => 'Chat title';

  @override
  String get cvUntitled => 'Untitled';

  @override
  String get cvYesterday => 'Yesterday';

  @override
  String get cvSearchHint => 'Search chats';

  @override
  String get cvEmpty => 'No chats yet. Ask the assistant your first question.';

  @override
  String get cvDeleteTitle => 'Delete this chat?';

  @override
  String get cvDeleteBody => 'It can’t be recovered — it only exists on this device.';

  @override
  String get jaWorking => 'Working…';

  @override
  String cvNoResult(String terme) {
    return 'Nothing found for “$terme”.';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'No results',
      one: '1 result',
      other: '$count results',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'No steps',
      one: '1 step',
      other: '$count steps',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Where your message goes';

  @override
  String get moLocal => 'On device';

  @override
  String get moLocalBody => 'The model runs on this phone. Nothing leaves it, even offline. Answers are shorter and less reliable.';

  @override
  String get moOnline => 'Online';

  @override
  String get moOnlineBody => 'Your message goes to Groq, which runs a far larger model. It needs a connection, and the message leaves your phone.';

  @override
  String get moOnlineNoKey => 'Talking to a remote model needs a key. Tap to add one — it\'s free and takes a minute.';

  @override
  String get moRetryOnline => 'Redo online';

  @override
  String get moRetryOnlineWhy => 'The on-device model reached its limits on this one.';

  @override
  String get cpHint => 'Ask anything…';

  @override
  String get cpAdd => 'Add';

  @override
  String get cpPhoto => 'Photo';

  @override
  String get cpCamera => 'Camera';

  @override
  String get cpFile => 'File';

  @override
  String get cpFileHint => 'PDF, text, code';

  @override
  String get cpDictate => 'Dictate';

  @override
  String get cpSend => 'Send';

  @override
  String get cpStop => 'Stop';

  @override
  String get cpThinking => 'Thinking…';

  @override
  String get amCopy => 'Copy';

  @override
  String get amCopyMarkdown => 'Copy as Markdown';

  @override
  String get amCopyMarkdownHint => 'Keeps the formatting, for a document';

  @override
  String get amShare => 'Share';

  @override
  String get amEdit => 'Edit my question';

  @override
  String get amEditHint => 'Everything after it will be removed';

  @override
  String get amEditTitle => 'Edit this question?';

  @override
  String get amEditConfirm => 'Edit';

  @override
  String get amRegenerate => 'Regenerate';

  @override
  String get amReadAloud => 'Read aloud';

  @override
  String get amAsContext => 'Use as context';

  @override
  String get amAsContextHint => 'Continues from this message';

  @override
  String get amChapter => 'Pin as chapter';

  @override
  String get amChapterHint => 'To find it again in a long chat';

  @override
  String get amUnchapter => 'Unpin chapter';

  @override
  String get amChapters => 'Chapters';

  @override
  String get amChaptersEmpty => 'No chapters yet. Long-press a message and choose “Pin as chapter” to find it here.';

  @override
  String amEditBody(int count) {
    return '$count later messages will be removed — they answered the old question.';
  }

  @override
  String get trAssistant => 'Assistant';

  @override
  String get trArtifacts => 'Artifacts';

  @override
  String get trMemory => 'Memory';

  @override
  String get trHelp => 'Help';

  @override
  String get arVersions => 'Versions';

  @override
  String get arLatest => 'Latest';

  @override
  String get arSource => 'Source';

  @override
  String get arPreview => 'Preview';

  @override
  String get arGone => 'This artifact no longer exists.';

  @override
  String get arKindPage => 'Page';

  @override
  String get arKindCode => 'Code';

  @override
  String get arKindDiagram => 'Diagram';

  @override
  String get arKindData => 'Data';

  @override
  String get arKindDoc => 'Document';

  @override
  String arVersion(int n) {
    return 'Version $n';
  }

  @override
  String get aiSources => 'Sources';

  @override
  String get aiToolReading => 'Reading the attachment…';

  @override
  String get aiToolWriting => 'Making the file…';

  @override
  String get aiToolRemembering => 'Saving to memory…';

  @override
  String get arEmpty => 'No artifacts yet. The assistant makes one as soon as it produces a page, a table or code long enough to clutter the chat.';

  @override
  String get raTitle => 'Online assistant';

  @override
  String get raIntro => 'The on-device assistant works with no setup. Online mode needs a key: it pays for the answers, and it stays on this phone.';

  @override
  String get raKey => 'Key';

  @override
  String get raKeySaved => 'Key saved';

  @override
  String get raKeyFooter => 'It lives in the system keychain and is never shown in full.';

  @override
  String get raKeyRemove => 'Remove the key';

  @override
  String get raWhere => 'Create one at console.groq.com under “API Keys”. It starts with gsk_.';

  @override
  String get raPaste => 'Paste';

  @override
  String get raSaveAndTest => 'Save and test';

  @override
  String get raTest => 'Test the key';

  @override
  String get raTesting => 'Testing…';

  @override
  String get raNotTested => 'Not tested yet';

  @override
  String get raNotTestedBody => 'An eight-word call is enough to find out. Better here than in the middle of a question.';

  @override
  String get raWorks => 'The key works';

  @override
  String get raWorksBody => 'Online mode is now available in the chat, on the pill next to the input field.';

  @override
  String get raRefused => 'Key refused';

  @override
  String get raRefusedBody => 'The server doesn’t recognise it. Often a character lost when pasting, or a key revoked since.';

  @override
  String get raNoNetwork => 'Server unreachable';

  @override
  String get raNoNetworkBody => 'The key isn’t the problem: the request never arrived. Check the connection, then try again.';

  @override
  String get raModelGone => 'Model unavailable';

  @override
  String get raModelGoneBody => 'The key is accepted, but nothing came back. The model has probably been retired.';

  @override
  String get raQuota => 'Too many requests';

  @override
  String get raQuotaBody => 'The key works, but the account hit its limit. Try later, or check its credit.';

  @override
  String get raWhatGoesOut => 'What leaves';

  @override
  String get raModel => 'Model';

  @override
  String get raWhatGoesOutFooter => 'In online mode, your message and this chat’s earlier turns go to Groq. Nothing else: not your contacts, not your other chats, not your location.';

  @override
  String get aiDownloadTitle => 'Download the on-device model?';

  @override
  String get aiDownloadConfirm => 'Download';

  @override
  String get aiDownloading => 'Downloading the on-device model';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB to download, once. After that the assistant answers with no network, and nothing leaves your phone. You can keep using it online while it downloads.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB to download, once. After that the assistant answers with no network and nothing leaves your phone.';
  }

  @override
  String get aiGreetingPlain => 'Hello';

  @override
  String get aiGreetingHint => 'Ask a question, attach a photo, or ask for a document.';

  @override
  String get aiChipExplain => 'Explain…';

  @override
  String get aiChipWrite => 'Write a message';

  @override
  String get aiChipSummarize => 'Summarize this';

  @override
  String get aiChipTranslate => 'Translate to…';

  @override
  String aiGreeting(String nom) {
    return 'Hello, $nom';
  }

  @override
  String get cpNoPhoto => 'No photos: the online model can’t read an image. It does read PDFs, including long ones.';

  @override
  String get mvOpen => 'Voice mode';

  @override
  String get mvTapToTalk => 'Tap to talk';

  @override
  String get mvHoldToTalk => 'Hold to talk';

  @override
  String get mvListening => 'Listening…';

  @override
  String get mvTranscribing => 'Transcribing…';

  @override
  String get mvSpeaking => 'Answering aloud';

  @override
  String get mvProblem => 'Something went wrong';

  @override
  String get mvHandsFree => 'Hands-free';

  @override
  String get mvHold => 'Hold';

  @override
  String get mvTalk => 'Talk';

  @override
  String get mvInterrupt => 'Interrupt';

  @override
  String get mvNoMic => 'Droplet has no access to the microphone. Allow it in your phone settings.';

  @override
  String get mvFailed => 'That turn didn\'t go through. Tap to try again.';

  @override
  String get mvLive => 'Live';

  @override
  String get mvCaptions => 'Captions';

  @override
  String get mvExit => 'Leave voice mode';

  @override
  String get mvMute => 'Mute';

  @override
  String get mvUnmute => 'Unmute';

  @override
  String get mvMuted => 'Microphone off';

  @override
  String get mvTapToInterrupt => 'Tap to interrupt';

  @override
  String scCompressing(int percent) {
    return 'Compressing… $percent%';
  }

  @override
  String get scStillHeavy => 'This video is still over 2 MB: it will transfer more slowly.';

  @override
  String get baConnecting => 'Connecting…';

  @override
  String get baMute => 'Mute';

  @override
  String get baUnmute => 'Unmute';

  @override
  String get baHangUp => 'End call';

  @override
  String baOngoing(String name) {
    return 'Call with $name in progress. Tap to return.';
  }

  @override
  String get ntfOngoingCall => 'Ongoing call';

  @override
  String get ntfViaMesh => 'Over the mesh';

  @override
  String get ntfViaInternet => 'Over the internet';

  @override
  String get shSend => 'Send';

  @override
  String get shRecents => 'Recent';

  @override
  String get shPickRecipients => 'Pick one or more recipients';

  @override
  String shSendCount(int count) {
    return 'Send to $count';
  }

  @override
  String shSelected(int count) {
    return '$count selected';
  }

  @override
  String get apcNothingYet => 'Nothing yet';

  @override
  String get apcOnline => 'Online';

  @override
  String get apcOffline => 'Offline';

  @override
  String get apcPhoto => 'Photo';

  @override
  String get apcVoice => 'Voice message';

  @override
  String get apcAttachment => 'Attachment';

  @override
  String get chKeyboardTooltip => 'Keyboard';

  @override
  String get asGallery => 'Gallery';

  @override
  String get asFile => 'File';

  @override
  String get asLocation => 'Location';

  @override
  String get asSticker => 'Sticker';

  @override
  String get asPoll => 'Poll';

  @override
  String get asNoGalleryAccess => 'Droplet has no access to your photos. Allow it in your phone settings, or pick another source below.';

  @override
  String asSendCount(int count) {
    return 'Send $count';
  }

  @override
  String get asEmptyGallery => 'No photos or videos on this phone.';

  @override
  String get expAucunPairTitre => 'No one nearby?';

  @override
  String get expAucunPairTexte => 'Nothing is broken. Droplet keeps looking; as soon as a device passes by, the link forms on its own.';

  @override
  String get expRelaisTitre => 'Relayed by someone';

  @override
  String get expRelaisTexte => 'This icon means the message crossed one or more devices before arriving. That is the strength of the mesh.';

  @override
  String get expApercuTitre => 'Quick peek';

  @override
  String get expApercuTexte => 'Press and hold a conversation to read its latest messages without opening it — or marking it read.';

  @override
  String get expOfficielTitre => 'The Droplet account';

  @override
  String get expOfficielTexte => 'App news arrives here. Every announcement is signed: no one can forge one.';

  @override
  String get expMicroTitre => 'Hold to talk';

  @override
  String get expMicroTexte => 'Hold to record. Slide left to cancel, slide up to keep recording hands-free.';

  @override
  String get expCameraTitre => 'Mic or camera';

  @override
  String get expCameraTexte => 'A short tap on this button switches between voice message and round video message.';

  @override
  String get expVueUniqueTitre => 'View once';

  @override
  String get expVueUniqueTexte => 'Turn on the “1” and the next thing you send can be opened only once, then disappears.';

  @override
  String get expPiecesTitre => 'Several at once';

  @override
  String get expPiecesTexte => 'The clip opens your gallery inside the app. Tick several photos: the number shows the sending order.';

  @override
  String get expStickersTitre => 'Stickers and keyboard';

  @override
  String get expStickersTexte => 'This icon swaps the keyboard for stickers, and turns back into a keyboard with one tap.';

  @override
  String get expEphemeresTitre => 'Disappearing messages';

  @override
  String get expEphemeresTexte => 'Set a delay and new messages in this conversation will erase themselves from both phones.';

  @override
  String get expVerrouTitre => 'Locked conversation';

  @override
  String get expVerrouTexte => 'Once locked, a conversation no longer shows its last message in the list, and must be unlocked to open.';

  @override
  String get expCodeTitre => 'Verify a contact';

  @override
  String get expCodeTexte => 'Compare this code side by side with your contact: if it matches, no one has slipped in between you.';

  @override
  String get expStatutTitre => '24-hour statuses';

  @override
  String get expStatutTexte => 'A status lives one day, then clears. It travels phone to phone, even without internet.';

  @override
  String get expGardeTitre => 'Nothing is lost';

  @override
  String get expGardeTexte => 'A message sent to someone away is kept for a week and leaves on its own as soon as a path opens.';

  @override
  String get expVoieTitre => 'How it travels';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi Direct or internet: Droplet takes whatever is available and switches route without asking.';

  @override
  String get cnAnnouncement => 'What\'s new in Droplet';

  @override
  String get cnClearAll => 'Clear all';

  @override
  String get cnClearAllTitle => 'Clear all notifications?';

  @override
  String get cnClearAllBody => 'The center will be emptied. Your chats and messages are not affected.';

  @override
  String get cnDelete => 'Clear';

  @override
  String get cnEmptyTitle => 'Nothing new';

  @override
  String get cnEmptyBody => 'Mentions, reactions to your messages, missed calls and Droplet news will appear here.';

  @override
  String get cnMentioned => 'mentioned you';

  @override
  String get cnShowLess => 'Show less';

  @override
  String get cnStatusLike => 'liked your status';

  @override
  String get cnStatusReply => 'replied to your status';

  @override
  String get cnTitle => 'Notification Center';

  @override
  String get ncDeliveryHeader => 'Delivery';

  @override
  String get ncMentionsOnly => 'Mentions only';

  @override
  String get ncMentionsOnlySub => 'Only when someone writes @your name or @all';

  @override
  String get ncMute1h => '1 hour';

  @override
  String get ncMute8h => '8 hours';

  @override
  String get ncMute1w => '1 week';

  @override
  String get ncMuteAlways => 'Always';

  @override
  String get ncMuteFooter => 'No notifications or sounds. Messages still arrive and wait for you.';

  @override
  String get ncMuteFooterGroup => 'No notifications or sounds. Mentions still reach you.';

  @override
  String get ncMuteHeader => 'Mute';

  @override
  String get ncMuteOff => 'Off';

  @override
  String get ncPreviewAlways => 'Always';

  @override
  String get ncPreviewFooter => 'Without a preview, the notification only says “New message”: nothing can be read on the lock screen.';

  @override
  String get ncPreviewHeader => 'Message preview';

  @override
  String get ncPreviewNever => 'Never';

  @override
  String get ncQuiet => 'Deliver quietly';

  @override
  String get ncQuietSub => 'In the shade, no sound or banner';

  @override
  String get ncSampleAuthor => 'Leah';

  @override
  String get ncSampleHidden => 'New message';

  @override
  String get ncSampleLabel => 'Sample notification';

  @override
  String get ncSampleText => 'Meet at 7pm?';

  @override
  String get ncStateMentions => 'Mentions only';

  @override
  String get ncStateMuted => 'Muted';

  @override
  String get ncStateOn => 'On';

  @override
  String get ncStateQuiet => 'Quiet';

  @override
  String get ncSystemFooter => 'This chat\'s sound and bubbles are set in Android.';

  @override
  String get ncSystemSettings => 'Sound and bubbles';

  @override
  String get ncTitle => 'Notifications';

  @override
  String get ntfNewMessage => 'New message';

  @override
  String get ntfNow => 'now';

  @override
  String get rnBanners => 'Banners';

  @override
  String get rnBannersSub => 'When a message arrives while Droplet is open';

  @override
  String get rnFocus1h => 'For 1 hour';

  @override
  String get rnFocusEvening => 'Until this evening';

  @override
  String get rnFocusTomorrow => 'Until tomorrow morning';

  @override
  String get rnFocusFooter => 'Droplet goes quiet: messages arrive and wait for you. Calls still ring.';

  @override
  String get rnFocusHeader => 'Focus';

  @override
  String get rnFocusMentions => 'Allow mentions';

  @override
  String get rnFocusMentionsSub => 'When someone writes @your name in a group';

  @override
  String get rnFocusOff => 'Focus is off';

  @override
  String get rnFocusOffSub => 'Notifications arrive as usual';

  @override
  String get rnFocusOn => 'Focus is on';

  @override
  String get rnFocusStop => 'Turn off Focus';

  @override
  String get rnFocusStopShort => 'Stop';

  @override
  String get rnInAppHeader => 'In Droplet';

  @override
  String get rnMutedEmpty => 'No muted chats.';

  @override
  String get rnMutedHeader => 'Muted';

  @override
  String get rnPreview => 'Show previews';

  @override
  String get rnPreviewFooter => 'Message text in notifications. Each chat can override this.';

  @override
  String get rnSystem => 'Android settings';

  @override
  String get rnSystemFooter => 'Droplet\'s permissions, sounds and bubbles in the phone\'s settings.';

  @override
  String get stNotificationsSubtitle => 'Mute, previews, Focus';

  @override
  String cnBellUnread(int count) {
    return 'Notifications, $count new';
  }

  @override
  String cnMore(int count) {
    return '+$count more';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count more';
  }

  @override
  String cnQuoted(String texte) {
    return '“$texte”';
  }

  @override
  String cnReacted(String emoji) {
    return 'reacted $emoji to your message';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Until $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Default ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Mute $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Until $heure · calls still ring';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n chats';
  }

  @override
  String get chatsNetSearching => 'Looking for nearby devices…';

  @override
  String get cfEmptyUnreadTitle => 'You\'re all caught up';

  @override
  String get cfEmptyUnreadBody => 'Chats with unread messages will appear here.';

  @override
  String get cfEmptyGroupsTitle => 'No groups yet';

  @override
  String get cfEmptyGroupsBody => 'Create one with the + button at the top right.';

  @override
  String get cfEmptyOtherTitle => 'Nothing here yet';

  @override
  String get ciLockedWhereHint => 'Locked. To find it, pull down on the chat list.';

  @override
  String get chDraftLabel => 'Draft:';

  @override
  String get rsMorning => 'Good morning';

  @override
  String get rsEvening => 'Good evening';

  @override
  String get rsUnreadOne => '1 unread message';

  @override
  String get rsChatsOne => 'in 1 chat';

  @override
  String get rsMentionsOne => '1 mention';

  @override
  String get rsMissedOne => '1 missed call';

  @override
  String get rsSeeUnread => 'Show unread';

  @override
  String rsUnreadMany(int count) {
    return '$count unread messages';
  }

  @override
  String rsChatsMany(int count) {
    return 'in $count chats';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count mentions';
  }

  @override
  String rsMissedMany(int count) {
    return '$count missed calls';
  }

  @override
  String get camUnavailable => 'Camera unavailable. Check the permission in Settings.';

  @override
  String get camTakePhoto => 'Take a photo';

  @override
  String get camFlip => 'Flip camera';

  @override
  String get chE2eNotice => 'Messages are end-to-end encrypted. No one else, not even Droplet, can read them.';

  @override
  String chCallUnreachable(String name) {
    return '$name is out of range: you can call once you\'re nearby or online.';
  }

  @override
  String get chPin => 'Pin';

  @override
  String get chUnpin => 'Unpin';

  @override
  String get chPinnedMessage => 'Pinned message';

  @override
  String get chVoicePlay => 'Play';

  @override
  String get chVoicePause => 'Pause';

  @override
  String chPinnedMessageN(String position) {
    return 'Pinned message $position';
  }

  @override
  String get msgInfo => 'Info';

  @override
  String get imSearch => 'Search';

  @override
  String get apcVideo => 'Video';

  @override
  String get adTitle => 'Linked devices';

  @override
  String get adSettingsSubtitle => 'Droplet Web on your computer';

  @override
  String get adHero => 'Use Droplet on your computer, even when your phone is off. Just open:';

  @override
  String get adLink => 'Link a device';

  @override
  String get adDevices => 'Devices';

  @override
  String adCount(int n, int max) {
    return '$n of $max';
  }

  @override
  String get adNone => 'No linked devices';

  @override
  String get adFooter => 'Your messages are end-to-end encrypted on every device. Each linked device has its own keys, and you can log it out at any time.';

  @override
  String adLinkedOn(String date) {
    return 'Linked $date';
  }

  @override
  String get adLogout => 'Log out';

  @override
  String adLogoutTitle(String nom) {
    return 'Log out $nom?';
  }

  @override
  String get adLogoutBody => 'This browser will lose access to your chats. You can link it again at any time.';

  @override
  String get adLogoutAll => 'Log out from all devices';

  @override
  String get adLogoutAllBody => 'All linked browsers will lose access to your chats.';

  @override
  String get adScanTitle => 'Link a device';

  @override
  String get adScanHint => 'On your computer, open Droplet Web and point at the QR code:';

  @override
  String get adSecurity => 'The code changes every minute: a photo of it is useless.';

  @override
  String get adNotDroplet => 'This isn\'t a Droplet Web code. Point at the code shown on web.dropletmesh.app.';

  @override
  String get adConfirmTitle => 'Link this device?';

  @override
  String get adConfirmBody => 'It will be able to read and send your messages, even when this phone is off.';

  @override
  String get adConfirm => 'Link';

  @override
  String get adLinking => 'Linking…';

  @override
  String get adLinked => 'Device linked';

  @override
  String get adServerDown => 'Droplet servers can\'t be reached right now. Check your connection, then try again.';

  @override
  String get adLimit => 'You already have 4 linked devices. Log one out to link another.';

  @override
  String get adNoIdentity => 'Create your Droplet profile on this phone first.';

  @override
  String get adTorch => 'Flashlight';
}
