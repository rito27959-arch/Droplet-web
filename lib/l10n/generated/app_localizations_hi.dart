// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'भेजें';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionSearch => 'खोजें';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionNext => 'आगे';

  @override
  String get actionBack => 'वापस';

  @override
  String get actionRetry => 'पुनः प्रयास करें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get tabChats => 'चैट';

  @override
  String get tabNews => 'अपडेट';

  @override
  String get tabCalls => 'कॉल';

  @override
  String get tabPeers => 'पीयर';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get sectionAppearance => 'दिखावट';

  @override
  String get appearanceAuto => 'स्वचालित';

  @override
  String get appearanceLight => 'हल्का';

  @override
  String get appearanceDark => 'गहरा';

  @override
  String get appearanceFooter =>
      'Droplet को डार्क मोड के लिए बनाया गया है: OLED स्क्रीन पर काले पिक्सेल बंद रहते हैं, जिससे बैटरी बचती है और अंधेरे में चमक नहीं होती। तेज़ धूप में पढ़ने के लिए लाइट मोड भी उपलब्ध है।';

  @override
  String get sectionLanguage => 'भाषा';

  @override
  String get languageAuto => 'स्वचालित (फ़ोन की भाषा)';

  @override
  String get languageFooter =>
      '\"स्वचालित\" आपके डिवाइस पर सेट भाषा का अनुसरण करता है। यदि वह भाषा अभी समर्थित नहीं है, तो Droplet फ़्रेंच में ही रहेगा।';

  @override
  String get chatsTitle => 'चैट';

  @override
  String get chatsSearchHint => 'खोजें';

  @override
  String get chatsFilterAll => 'सभी';

  @override
  String get chatsFilterUnread => 'अपठित';

  @override
  String get chatsFilterGroups => 'समूह';

  @override
  String get chatsFilterPinned => 'पिन की गई';

  @override
  String get chatsEmptyTitle => 'अभी कोई चैट नहीं';

  @override
  String get chatsEmptySubtitle =>
      'Droplet उपयोग करने वाले किसी डिवाइस के पास जाएं: यह यहां अपने आप दिखाई देगा।';

  @override
  String get chatsSearchEmptyTitle => 'कोई परिणाम नहीं';

  @override
  String get chatsSearchEmptySubtitle => 'कोई दूसरा नाम आज़माएं।';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पास में $count पीयर',
      one: 'पास में $count पीयर',
      zero: 'पीयर खोजे जा रहे हैं…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'कम से कम 3 अक्षर';

  @override
  String get obChoosePseudo => 'शुरू करने के लिए एक नाम चुनें';

  @override
  String get obRestoreFailed => 'पुनर्स्थापना विफल';

  @override
  String get obPhotoSaveFailed => 'फ़ोटो सहेजी नहीं जा सकी';

  @override
  String get obShareUnavailable => 'साझा करना अनुपलब्ध';

  @override
  String get obBackupPasswordTitle => 'बैकअप पासवर्ड';

  @override
  String get obBackupPasswordMessage =>
      'वह जो आपने अपनी पहचान निर्यात करते समय चुना था।';

  @override
  String get obBackupPasswordPlaceholder => 'पासवर्ड';

  @override
  String get obRestore => 'पुनर्स्थापित करें';

  @override
  String get obSkipStep => 'यह चरण छोड़ें';

  @override
  String get obContinue => 'जारी रखें';

  @override
  String get obStart => 'शुरू करें';

  @override
  String get obAlreadyHaveBackup => 'मेरे पास पहले से बैकअप है';

  @override
  String get obWelcomeTitle => 'Droplet में\nआपका स्वागत है';

  @override
  String get obWelcomeSubtitle =>
      'एक मैसेंजर जो वहाँ काम करता है जहाँ नेटवर्क नहीं है।';

  @override
  String get obFeatOfflineTitle => 'बिना इंटरनेट, बिना ऑपरेटर';

  @override
  String get obFeatOfflineText =>
      'फ़ोन सीधे एक-दूसरे से बात करते हैं, कदम-दर-कदम। न एंटीना, न बिल।';

  @override
  String get obFeatEncryptedTitle => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String get obFeatEncryptedText =>
      'यहाँ तक कि जो फ़ोन आपके संदेश आगे भेजते हैं, वे भी उन्हें पढ़ नहीं सकते।';

  @override
  String get obFeatLocalTitle => 'आपके डिवाइस से कुछ भी बाहर नहीं जाता';

  @override
  String get obFeatLocalText =>
      'न कोई खाता, न सर्वर, न डेटा संग्रह। आपकी बातचीत आपके पास ही रहती है।';

  @override
  String get obRelayTitle => 'कदम दर\nकदम';

  @override
  String get obRelaySubtitle =>
      'आपका संदेश फ़ोन-दर-फ़ोन छलांग लगाकर प्राप्तकर्ता तक पहुँचता है, भले ही आप सीधी सीमा में न हों।';

  @override
  String get obFeatCrowdTitle =>
      'जितने ज़्यादा हम होंगे, उतनी दूर तक पहुँच होगी';

  @override
  String get obFeatCrowdText =>
      'सीमा में मौजूद हर डिवाइस सबके लिए नेटवर्क को बड़ा करता है।';

  @override
  String get obFeatNothingLostTitle => 'कुछ भी नहीं खोता';

  @override
  String get obFeatNothingLostText =>
      'किसी अनुपस्थित व्यक्ति के लिए संदेश प्रतीक्षा करता है, और रास्ता खुलते ही आगे बढ़ जाता है।';

  @override
  String get obSafetyTitle => 'बिना नेटवर्क के\nएक-दूसरे को खोजें';

  @override
  String get obSafetySubtitle =>
      'जब और कुछ काम नहीं करता, तो यह जानना कि दूसरे कहाँ हैं और सुरक्षित हैं, सबसे उपयोगी जानकारी बन जाती है।';

  @override
  String get obFeatMapTitle => 'एक नक्शा जो ऑफ़लाइन भी काम करता है';

  @override
  String get obFeatMapText =>
      'आप जो क्षेत्र देखते हैं वे फ़ोन पर रहते हैं। एक बार देखे जाने पर, वे बिना इंटरनेट के दिखते हैं।';

  @override
  String get obFeatMeshPosTitle => 'स्थान मेश से आते हैं';

  @override
  String get obFeatMeshPosText =>
      'कोई सर्वर नहीं: स्थान आपके संपर्क के फ़ोन से एन्क्रिप्टेड होकर निकलता है और डिवाइस-दर-डिवाइस आपके पास तक पहुँचता है।';

  @override
  String get obFeatCheckinTitle => 'एक इशारे में «मैं सुरक्षित हूँ»';

  @override
  String get obFeatCheckinText =>
      'एक टैप से आपकी स्थिति पूरे पड़ोस में प्रसारित होती है। आप चुनते हैं कि अनुमानित स्थान जोड़ें या नहीं।';

  @override
  String get obStatusTitle => 'समाचार\nसाझा करना';

  @override
  String get obStatusSubtitle =>
      'एक फ़ोटो, एक शब्द, एक मनोदशा: आपकी स्थिति संदेशों की तरह ही फ़ोन-दर-फ़ोन घूमती है।';

  @override
  String get obFeatStatusMediaTitle => 'फ़ोटो, वीडियो या टेक्स्ट';

  @override
  String get obFeatStatusMediaText =>
      'जो दिखाना चाहें वह पोस्ट करें। सीमा में मौजूद लोग इसे बिना इंटरनेट के प्राप्त करते हैं।';

  @override
  String get obFeatStatusSeenTitle => 'आप देख सकते हैं कि किसने इसे देखा';

  @override
  String get obFeatStatusSeenText =>
      'जो भी आपकी स्थिति खोलता है, वह उसी रास्ते से आपको बताता है।';

  @override
  String get obFeatStatusExpireTitle => 'एक दिन बाद यह गायब हो जाता है';

  @override
  String get obFeatStatusExpireText =>
      'चौबीस घंटे बाद, स्थिति उन सभी फ़ोन से मिट जाती है जिन्हें वह मिली थी।';

  @override
  String get obRemovePhoto => 'फ़ोटो हटाएं';

  @override
  String get obChoosePhoto => 'फ़ोटो चुनें';

  @override
  String get obPhotoTitle => 'एक चेहरा,\nअगर आप चाहें';

  @override
  String get obPhotoSubtitle =>
      'यह दूसरों को सूची में आपको पहचानने में मदद करती है। इसे लगाना ज़रूरी नहीं है।';

  @override
  String get obFeatPhotoLocalTitle => 'यह इसी फ़ोन पर रहती है';

  @override
  String get obFeatPhotoLocalText =>
      'इसे कोई सर्वर प्राप्त नहीं करता, कोई ऑनलाइन बैकअप इसे सहेजता नहीं। यह केवल ऐप के फ़ोल्डर में रहती है, कहीं और नहीं।';

  @override
  String get obFeatPhotoCompressTitle => 'सहेजे जाने से पहले छोटी की जाती है';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet केवल 320 पिक्सेल का थंबनेल रखता है। आपकी मूल फ़ोटो कभी कॉपी नहीं होती।';

  @override
  String get obNetworkTitle => 'Droplet आपके साथ\nबढ़ता है';

  @override
  String get obNetworkSubtitle =>
      'जो भी इसे इंस्टॉल करता है, वह नेटवर्क को बड़ा करता है — अपने लिए, और आस-पास के सभी के लिए।';

  @override
  String get obSendToFriend => 'Droplet किसी अपने को भेजें';

  @override
  String get obFeatShareOfflineTitle =>
      'साझा करने के लिए भी इंटरनेट की ज़रूरत नहीं';

  @override
  String get obFeatShareOfflineText =>
      'Droplet आपको अपनी इंस्टॉलेशन फ़ाइल भेजता है। यह ब्लूटूथ, Wi-Fi Direct या मेमोरी कार्ड से जाती है — किसी भी ओर कनेक्शन की ज़रूरत नहीं।';

  @override
  String get obFeatThreeTitle => 'शुरू करने के लिए तीन लोग काफी हैं';

  @override
  String get obFeatThreeText =>
      'दो लोगों के साथ, आप नज़र की सीमा में लिखते हैं। मोहल्ले में कुछ लोगों के साथ, संदेश आगे बढ़ते हैं और सीमा हर फ़ोन से कहीं ज़्यादा बड़ी हो जाती है।';

  @override
  String get obIdentityTitle => 'हमें आपको\nक्या कहना चाहिए?';

  @override
  String get obIdentitySubtitle =>
      'यह नाम उन लोगों को दिखेगा जिनसे आप मिलते हैं। आप ऐसा नाम चुन सकते हैं जो आपकी पहचान न बताए।';

  @override
  String get obPseudoHint => 'आपका नाम';

  @override
  String get obFeatKeysTitle => 'आपकी कुंजियाँ यहीं, अभी बनाई जाती हैं';

  @override
  String get obFeatKeysText =>
      'वे इस फ़ोन से कभी बाहर नहीं जातीं। सेटिंग्स से बैकअप बनाना न भूलें: इसके बिना, खोई हुई पहचान हमेशा के लिए खो जाती है।';

  @override
  String get splashCaption => 'ऑफ़लाइन। बिना ऑपरेटर।';

  @override
  String get chatsMeshNetwork => 'मेश नेटवर्क';

  @override
  String get chatsNew => 'नया';

  @override
  String get chatsNewGroup => 'नया समूह';

  @override
  String get chatsAssistant => 'सहायक';

  @override
  String get chatsEmergencyMode => 'आपातकालीन मोड';

  @override
  String get chatsUnpin => 'अनपिन करें';

  @override
  String get chatsPin => 'शीर्ष पर पिन करें';

  @override
  String get chatsUnmute => 'सूचनाएं चालू करें';

  @override
  String get chatsMute => 'म्यूट करें';

  @override
  String get chatsArchive => 'आर्काइव करें';

  @override
  String get swipePin => 'पिन';

  @override
  String get swipeUnpin => 'अनपिन';

  @override
  String get swipeMute => 'म्यूट';

  @override
  String get swipeUnmute => 'अनम्यूट';

  @override
  String get swipeArchive => 'संग्रह';

  @override
  String get fmtBold => 'बोल्ड';

  @override
  String get fmtItalic => 'इटैलिक';

  @override
  String get fmtStrike => 'काटा हुआ';

  @override
  String get fmtMono => 'मोनोस्पेस';

  @override
  String get fmtSpoiler => 'स्पॉइलर';

  @override
  String get vnTranscribing => 'लिप्यंतरण…';

  @override
  String get vnTranscribeFailed => 'इस डिवाइस पर लिप्यंतरण उपलब्ध नहीं';

  @override
  String get vnNoSpeech => 'कोई भाषण नहीं पहचाना गया';

  @override
  String get msgTranslate => 'अनुवाद करें';

  @override
  String get msgShowOriginal => 'मूल देखें';

  @override
  String get msgTranslatedFrom => 'स्वचालित अनुवाद';

  @override
  String get msgTranslateFailed => 'अनुवाद उपलब्ध नहीं';

  @override
  String get msgTranslateModel =>
      'भाषा मॉडल डाउनलोड करना होगा (एक बार, Wi‑Fi पर)';

  @override
  String get pfWallpapers => 'एनिमेटेड बैकग्राउंड';

  @override
  String get pfWallpapersDesc =>
      'आठ रंगीन बैकग्राउंड जो आपकी चैट के पीछे चलते हैं और हर भेजे संदेश के साथ घूमते हैं।';

  @override
  String get pfFormatting => 'टेक्स्ट फ़ॉर्मेटिंग';

  @override
  String get pfFormattingDesc =>
      'बोल्ड, इटैलिक, काटा हुआ, कोड और स्पॉइलर, सीधे आपके संदेशों में।';

  @override
  String get pfTranscription => 'आवाज़ से टेक्स्ट';

  @override
  String get pfTranscriptionDesc =>
      'जब सुन न सकें तब वॉइस संदेश पढ़ें। पहचान आपके फ़ोन पर होती है।';

  @override
  String get pfTranslation => 'अनुवाद';

  @override
  String get pfTranslationDesc =>
      'प्राप्त संदेश का अनुवाद करें, सामग्री डिवाइस से बाहर जाए बिना।';

  @override
  String get pfAppIcons => 'ऐप आइकन';

  @override
  String get pfAppIconsDesc => 'होम स्क्रीन पर Droplet का आइकन बदलें।';

  @override
  String get pfBadge => 'बैज और समर्थन';

  @override
  String get pfBadgeDesc =>
      'आपके नाम के पास एक बैज, और एक स्वतंत्र परियोजना का समर्थन।';

  @override
  String get pfUnderstood => 'समझ गया';

  @override
  String get pfFeaturesTitle => 'पैक क्या खोलता है';

  @override
  String get chatsUnarchive => 'अनआर्काइव करें';

  @override
  String get chatsArchivedTitle => 'आर्काइव की गई';

  @override
  String get chatsNoArchived => 'कोई आर्काइव की गई चैट नहीं';

  @override
  String get chatsLockedTitle => 'लॉक की गई चैट';

  @override
  String get chatsNoLocked => 'कोई लॉक की गई चैट नहीं';

  @override
  String get chatsCrashTitle => 'Droplet अप्रत्याशित रूप से बंद हो गया';

  @override
  String get chatsCrashBody =>
      'Droplet का कोई सर्वर नहीं है: आपके भेजे बिना, यह खामी किसी और के लिए मौजूद नहीं है। रिपोर्ट में न संदेश हैं, न संपर्क, न कुंजियाँ।';

  @override
  String get chatsSendReport => 'रिपोर्ट भेजें';

  @override
  String get chatsLater => 'बाद में';

  @override
  String get stTitle => 'सेटिंग्स';

  @override
  String get stIconHeader => 'आइकन';

  @override
  String get stIconFooter => 'होम स्क्रीन के लिए तेरह आइकन में से चुनें।';

  @override
  String get stAppIcon => 'ऐप आइकन';

  @override
  String get stVariants13 => '13 वैरिएंट';

  @override
  String get stNetworkHeader => 'नेटवर्क';

  @override
  String get stNetworkFooter =>
      'बैकग्राउंड रिले Droplet बंद होने पर भी दूसरों के संदेश भेजने देता है।';

  @override
  String get stRequireTor => 'ऑनलाइन Tor अनिवार्य करें';

  @override
  String get stRequireTorSubtitle => 'Tor के बिना सर्वर तक कुछ नहीं जाता';

  @override
  String get stRequireTorFooter =>
      'Tor सक्रिय होने पर निर्देशिका और मेलबॉक्स उसी से गुजरते हैं। अन्यथा Droplet सीधे जुड़ता है: सामग्री एंड-टू-एंड एन्क्रिप्टेड रहती है, पर सर्वर आपका IP पता देखते हैं। इसे रोकने के लिए चालू करें — Tor बंद होने पर ऑनलाइन संदेश की कीमत पर।';

  @override
  String get stMeshNetwork => 'मेश नेटवर्क';

  @override
  String get stPeersTopology => 'जुड़े हुए पीयर और टोपोलॉजी';

  @override
  String get stOfflineMaps => 'ऑफ़लाइन मानचित्र';

  @override
  String get stZonesImport => 'सहेजे गए क्षेत्र और मानचित्र आयात';

  @override
  String get stSecurityHeader => 'सुरक्षा';

  @override
  String get stSecurityFooter =>
      'Droplet आपकी पहचान की कोई प्रति नहीं रखता। बैकअप के बिना, यह डिवाइस के साथ खो जाती है।';

  @override
  String get stBackupIdentity => 'मेरी पहचान का बैकअप लें';

  @override
  String get stExportEncrypted => 'पासवर्ड-एन्क्रिप्टेड निर्यात';

  @override
  String get stEmergencyMode => 'आपातकालीन मोड';

  @override
  String get stSignalSafe => 'बताएं कि आप सुरक्षित हैं';

  @override
  String get stContributionHeader => 'योगदान';

  @override
  String get stMyContribution => 'मेरा योगदान';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'सक्रिय';

  @override
  String get stProPackUnlocked => 'पैक अनलॉक';

  @override
  String get stProIconsThemes => 'आइकन और बैकग्राउंड';

  @override
  String get stCrashLog => 'त्रुटि लॉग';

  @override
  String get stAbout => 'Droplet के बारे में';

  @override
  String get stBackgroundRelay => 'बैकग्राउंड रिले';

  @override
  String get stActiveClosed => 'ऐप बंद होने पर भी सक्रिय';

  @override
  String get stActiveOpenOnly => 'केवल ऐप खुला होने पर सक्रिय';

  @override
  String get stBatteryOptim => 'बैटरी अनुकूलन';

  @override
  String get stAndroidMayLimit => 'Android रिले को सीमित कर सकता है';

  @override
  String get stFix => 'ठीक करें';

  @override
  String get stKeepActiveTitle => 'क्या Droplet को सक्रिय रखें?';

  @override
  String get stKeepActiveBody =>
      'एक स्थायी सूचना दिखाएगी कि Droplet मेश को रिले कर रहा है, भले ही ऐप बंद हो। बदले में, बैटरी की खपत अधिक होगी।';

  @override
  String get stEnable => 'सक्षम करें';

  @override
  String get stCancel => 'रद्द करें';

  @override
  String get stAboutTagline => 'ऑफ़लाइन मैसेजिंग और कॉल, न इंटरनेट न ऑपरेटर।';

  @override
  String get stAboutDirect => 'डिवाइसों के बीच सीधा नेटवर्क — कोई सर्वर नहीं';

  @override
  String get stAboutE2E => 'हर संदेश पर एंड-टू-एंड एन्क्रिप्शन';

  @override
  String get stAboutNoThirdParty =>
      'किसी तीसरे पक्ष को कोई डेटा नहीं भेजा जाता';

  @override
  String get stAttributionEmoji =>
      'एनिमेटेड इमोजी: Noto Animated Emoji © Google, CC BY 4.0 लाइसेंस के तहत।';

  @override
  String get stAttributionGemma =>
      'सहायक: Gemma 3 1B-IT © Google, litert-community द्वारा क्वांटाइज़्ड (int4) और Droplet द्वारा पुनः प्रकाशित, Gemma उपयोग शर्तों (ai.google.dev/gemma/terms) के तहत।';

  @override
  String get stChatBgHeader => 'चैट पृष्ठभूमि';

  @override
  String get stChatPatterns => 'Droplet डूडल';

  @override
  String get stChatPatternsSubtitle => 'पृष्ठभूमि पर छोटे रेखाचित्र';

  @override
  String get stChatBgFooter =>
      'हर भेजे गए संदेश के साथ ग्रेडिएंट एक कदम आगे बढ़ता है। सादे बैकग्राउंड के लिए «कोई नहीं» चुनें: तब कुछ भी गणना नहीं होती, जिससे बैटरी बचती है।';

  @override
  String get stBgFree => 'मुफ़्त';

  @override
  String get stBgPremium => 'प्रीमियम · एनिमेटेड';

  @override
  String get stBgNone => 'कोई नहीं';

  @override
  String get stBgDefault => 'डिफ़ॉल्ट';

  @override
  String get stBgThisChat => 'इस चैट का बैकग्राउंड';

  @override
  String get stTextSize => 'टेक्स्ट का आकार';

  @override
  String get stBubbleCorners => 'संदेश के कोने';

  @override
  String get stAccentHeader => 'मुख्य रंग';

  @override
  String get stAccentFooter =>
      'यह पूरे ऐप में आपके बबल, बटन और लिंक को रंग देता है।';

  @override
  String get stChatListHeader => 'चैट सूची';

  @override
  String get stChatListTwoLines => 'दो पंक्तियाँ';

  @override
  String get stChatListThreeLines => 'तीन पंक्तियाँ';

  @override
  String get stResetAppearance => 'दिखावट रीसेट करें';

  @override
  String get stPreviewIncoming => 'आज शाम मिलें?';

  @override
  String get stPreviewOutgoing => 'हाँ, खुशी से!';

  @override
  String get stAppearanceRow => 'दिखावट';

  @override
  String get stAppearanceSubtitle => 'थीम, रंग, टेक्स्ट का आकार, बैकग्राउंड';

  @override
  String get stBgApply => 'यह बैकग्राउंड लगाएँ';

  @override
  String get stBgUnlock => 'प्रीमियम से अनलॉक करें';

  @override
  String get stBgApplied => 'बैकग्राउंड लगाया गया';

  @override
  String get stBgPreviewHint =>
      'बैकग्राउंड चलता है, और हर भेजे गए संदेश के साथ इसके रंग घूमते हैं।';

  @override
  String get stBgPreviewIncoming => 'नया बैकग्राउंड देखा?';

  @override
  String get stBgPreviewOutgoing => 'हाँ, बहुत सुंदर है ✨';

  @override
  String get stSoundHeader => 'ध्वनियाँ';

  @override
  String get stSoundToggle => 'ऐप की ध्वनियाँ';

  @override
  String get stSoundSubtitle => 'संदेश, कनेक्शन, अलर्ट';

  @override
  String get stSoundFooter =>
      'छोटी ध्वनियाँ, सिस्टम सूचना वॉल्यूम पर — फ़ोन साइलेंट या फ़ोकस मोड में होने पर मौन।';

  @override
  String get stPacksHeader => 'सहायक — ऑफ़लाइन पर्चे';

  @override
  String get stPacksToggle => 'प्राथमिक चिकित्सा और आपात पर्चे';

  @override
  String get stPacksSubtitle =>
      'प्राथमिक चिकित्सा और आपात स्थितियों के लिए सहायक इन पर निर्भर करता है।';

  @override
  String get stPacksFooter =>
      'अंतर्निर्मित संदर्भ पर्चे (प्राथमिक चिकित्सा, भूकंप, बाढ़, पीने योग्य पानी…)। जब प्रश्न इनसे जुड़ा हो, सहायक अनुमान के बजाय पर्चे को उद्धृत करता है। ये प्रशिक्षण या आपात सेवा को कॉल करने का विकल्प नहीं हैं।';

  @override
  String get stPrivateModeHeader => 'निजी मोड';

  @override
  String get stTorFooter =>
      'Tor आपके IP पते और बातचीत को Tor नेटवर्क के माध्यम से भेजकर सुरक्षित रखता है। स्थानीय मेश (BLE/WiFi) सामान्य रूप से काम करता रहता है।';

  @override
  String get stTorActiveAnon => 'सक्रिय — आपका डेटा गुमनाम है';

  @override
  String get stTorConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get stTorDisabled => 'निजी मोड बंद';

  @override
  String get callsTitle => 'कॉल';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छूटी हुई कॉलें',
      one: '$count छूटी हुई कॉल',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'नई कॉल';

  @override
  String get callsAll => 'सभी';

  @override
  String get callsMissed => 'छूटी हुई';

  @override
  String get callsNoneMissed => 'कोई छूटी हुई कॉल नहीं';

  @override
  String get callsNone => 'कोई कॉल नहीं';

  @override
  String get callsMissedEmptyBody =>
      'जिन कॉल का आपने जवाब नहीं दिया, वे यहाँ दिखेंगी।';

  @override
  String get callsEmptyBody =>
      'कॉल स्थानीय नेटवर्क से होकर जाती हैं, बिना ऑपरेटर या प्लान के। आपका इतिहास यहाँ दिखेगा।';

  @override
  String get callsRetained200 =>
      'पिछली 200 कॉल केवल इसी डिवाइस पर रखी जाती हैं।';

  @override
  String get callsIncoming => 'इनकमिंग';

  @override
  String get callsOutgoing => 'आउटगोइंग';

  @override
  String get callsMissedLabel => 'छूटी हुई';

  @override
  String get callsNoAnswer => 'कोई जवाब नहीं';

  @override
  String get callsConnectionFailed => 'कनेक्शन विफल';

  @override
  String get callsYesterday => 'कल';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m मिनट $s सेकंड';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s सेकंड';
  }

  @override
  String get peersTitle => 'पीयर';

  @override
  String get peersSearching => 'खोज जारी है…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सीमा में $count डिवाइस',
      one: 'सीमा में $count डिवाइस',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'नेटवर्क मानचित्र';

  @override
  String get peersNoneInRange => 'सीमा में कोई नहीं';

  @override
  String get peersNoneInRangeBody =>
      'Droplet लगातार आस-पास के डिवाइस खोजता रहता है। पहला संपर्क बनाने के लिए ऐप वाले किसी व्यक्ति के पास जाएं।';

  @override
  String get peersDirectRange => 'सीधी सीमा में';

  @override
  String get peersDirectRangeFooter =>
      'इन डिवाइसों तक किसी और के ज़रिए गए बिना पहुँचा जा सकता है।';

  @override
  String get peersRelayed => 'रिले द्वारा';

  @override
  String get peersRelayedFooter =>
      'ये डिवाइस सीधी सीमा से बाहर हैं: संदेश दूसरे फ़ोन से होकर उन तक पहुँचते हैं।';

  @override
  String get peersRelay => 'रिले';

  @override
  String get peersCall => 'कॉल करें';

  @override
  String get peersTooSlow => 'आवाज़ के लिए बहुत धीमा — पास आएं';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'ब्लूटूथ';

  @override
  String get peersUnknownLink => 'अज्ञात लिंक';

  @override
  String get peersDirect => 'सीधा';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिले',
      one: '$count रिले',
      zero: 'सीधा',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'यह स्थिति समाप्त हो गई है';

  @override
  String get svReceiving => 'प्राप्त हो रहा है…';

  @override
  String get svReceivingBody => 'फ़ाइल स्थानीय नेटवर्क से आ रही है';

  @override
  String get svProgressLabel => 'स्थिति प्रगति';

  @override
  String get svReplyHint => 'उत्तर दें…';

  @override
  String get svSendReply => 'उत्तर भेजें';

  @override
  String get svYourStatus => 'आपकी स्थिति';

  @override
  String get svNoViewsYet =>
      'अभी तक किसी ने यह स्थिति नहीं देखी।\nजब तक आप डिवाइसों से मिलते रहेंगे, यह फैलती रहेगी।';

  @override
  String get svJustNow => 'अभी अभी';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '$count मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '$count घंटा पहले',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'संगीत';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार देखा गया',
      one: '$count बार देखा गया',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पसंद',
      one: '$count पसंद',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जवाब',
      one: '$count जवाब',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'मूल';

  @override
  String get cpFilterDark => 'गहरा';

  @override
  String get cpFilterBright => 'उजला';

  @override
  String get cpFilterVintage => 'विंटेज';

  @override
  String get cpWriteStatusHint => 'एक स्थिति लिखें';

  @override
  String get cpPreparingVideo => 'वीडियो तैयार हो रहा है…';

  @override
  String get cpLoadingEllipsis => 'लोड हो रहा है…';

  @override
  String cpEndsIn(Object s) {
    return '$s सेकंड में समाप्त';
  }

  @override
  String get cpModeVideo => 'वीडियो';

  @override
  String get cpModePhoto => 'फ़ोटो';

  @override
  String get cpModeMessage => 'संदेश';

  @override
  String get cpModeVoice => 'आवाज़';

  @override
  String get gcChooseName => 'समूह के लिए एक नाम चुनें';

  @override
  String get gcSelectOneMember => 'कम से कम एक सदस्य चुनें';

  @override
  String get gcCreationFailed => 'समूह बनाने में विफल';

  @override
  String get gcNewGroup => 'नया समूह';

  @override
  String get gcGroupName => 'समूह का नाम';

  @override
  String get gcNameHint => 'जैसे फ़ील्ड टीम';

  @override
  String get gcMembers => 'सदस्य';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चयनित',
      one: '$count चयनित',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'सीमा में कोई नहीं';

  @override
  String get gcGetCloserBody =>
      'किसी दूसरे Droplet डिवाइस के पास जाएं: पीयर यहाँ अपने आप दिखेंगे।';

  @override
  String get gcCreateGroup => 'समूह बनाएं';

  @override
  String get gcConnected => 'जुड़ा हुआ';

  @override
  String get gcAlreadyMet => 'पहले मिल चुके';

  @override
  String get giRenameGroup => 'समूह का नाम बदलें';

  @override
  String get giRenameFailed => 'नाम बदलने में विफल';

  @override
  String get giNoPeerToAdd => 'जोड़ने के लिए कोई पीयर उपलब्ध नहीं';

  @override
  String get giAddMemberHeader => 'सदस्य जोड़ें';

  @override
  String get giAddMemberFailed => 'सदस्य जोड़ने में विफल';

  @override
  String get giRemoveMemberTitle => 'इस सदस्य को हटाएं?';

  @override
  String get giRemoveMemberBody =>
      'हटाए जाने के बाद भेजे गए संदेश वह नहीं पढ़ पाएगा।';

  @override
  String get giRemove => 'हटाएं';

  @override
  String get giRemoveMemberFailed => 'सदस्य हटाने में विफल';

  @override
  String get giLeaveGroupTitle => 'समूह छोड़ें?';

  @override
  String get giLeaveGroupBody =>
      'छोड़ने के बाद भेजे गए संदेश आपको नहीं मिलेंगे।';

  @override
  String get giLeave => 'छोड़ें';

  @override
  String get giNoOneReachable =>
      'अभी स्थानीय Wi-Fi से कोई सदस्य नहीं मिल पा रहा';

  @override
  String get giMax4Participants =>
      'समूह कॉल में अधिकतम 4 प्रतिभागी — केवल पहले 3 उपलब्ध सदस्यों को कॉल किया जाएगा';

  @override
  String get giGroupNotFound => 'समूह नहीं मिला';

  @override
  String get giGroupInfo => 'समूह जानकारी';

  @override
  String get giGroupCall => 'समूह कॉल';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '$count सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'समूह संदेश एन्क्रिप्टेड';

  @override
  String get giAdd => 'जोड़ें';

  @override
  String get giMe => 'मैं';

  @override
  String get giAdministrator => 'एडमिन';

  @override
  String get giLeaveGroup => 'समूह छोड़ें';

  @override
  String get sfNoLocationShared => 'स्थान साझा नहीं किया गया';

  @override
  String get sfLocationShared => 'स्थान साझा किया गया';

  @override
  String sfDistanceMeters(Object m) {
    return '$m मी दूर';
  }

  @override
  String sfDistanceKm(Object km) {
    return '$km किमी दूर';
  }

  @override
  String get sfBearingN => 'उत्तर में';

  @override
  String get sfBearingNE => 'उत्तर-पूर्व में';

  @override
  String get sfBearingE => 'पूर्व में';

  @override
  String get sfBearingSE => 'दक्षिण-पूर्व में';

  @override
  String get sfBearingS => 'दक्षिण में';

  @override
  String get sfBearingSW => 'दक्षिण-पश्चिम में';

  @override
  String get sfBearingW => 'पश्चिम में';

  @override
  String get sfBearingNW => 'उत्तर-पश्चिम में';

  @override
  String get sfBroadcastSafeTitle => '\"मैं सुरक्षित हूँ\" प्रसारित करें?';

  @override
  String get sfBroadcastSafeMessage =>
      'यह स्थिति रेंज में मौजूद पूरे मेश को दिखेगी, केवल आपके संपर्कों को नहीं। आप एक अनुमानित स्थान शामिल कर सकते हैं (गोल किया हुआ, कभी सटीक नहीं)।';

  @override
  String get sfWithLocation => 'अनुमानित स्थान के साथ';

  @override
  String get sfWithoutLocation => 'बिना स्थान के';

  @override
  String get sfStatusBroadcast => 'स्थिति मेश पर प्रसारित की गई';

  @override
  String get sfBroadcastFailed => 'प्रसारण विफल';

  @override
  String get sfHelpRequestTitle => '\"मुझे मदद चाहिए\" प्रसारित करें?';

  @override
  String get sfHelpRequestMessage =>
      'यह स्थिति रेंज में मौजूद साथियों को बताएगी कि आपको सहायता चाहिए। आप एक अनुमानित स्थान शामिल कर सकते हैं।';

  @override
  String get sfHelpRequestBroadcast => 'सहायता अनुरोध मेश पर प्रसारित किया गया';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '$count दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'आपातकालीन मोड';

  @override
  String get sfViewOnMap => 'मानचित्र पर देखें';

  @override
  String get sfNeedHelp => 'मुझे मदद चाहिए';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'प्राप्त चेक-इन ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'अभी तक कोई चेक-इन प्राप्त नहीं हुआ';

  @override
  String get sfCheckinsAppearHere =>
      'रेंज में मौजूद साथियों द्वारा प्रसारित \"सुरक्षित\" स्थितियाँ यहाँ दिखाई देंगी।';

  @override
  String get sfSafeLabel => 'सुरक्षित';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'सुरक्षित · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'सुरक्षित · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'मेरी सुरक्षा स्थिति को मेश नेटवर्क पर प्रसारित करें';

  @override
  String get sfImSafe => 'मैं सुरक्षित हूँ';

  @override
  String get emSosActive => 'SOS सक्रिय';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'SOS सिग्नल सक्रिय — आस-पास के सभी उपकरणों तक प्रसारित';

  @override
  String get emPullToSendSignal => 'आपातकालीन सिग्नल भेजने के लिए टैप करें';

  @override
  String get emSignalRelayedDescription =>
      'सिग्नल पीयर-टू-पीयर रिले होता है\nपूरे मेश नेटवर्क में।';

  @override
  String get emBroadcasting => 'प्रसारित हो रहा है...';

  @override
  String get emSharePosition => 'मेरा स्थान साझा करें';

  @override
  String get emSosActivated => 'SOS सिग्नल सक्रिय किया गया';

  @override
  String get emSafeStatusMessage => '🟢 मैं सुरक्षित हूँ';

  @override
  String get emSafetyStatusBroadcast => 'सुरक्षा स्थिति प्रसारित की गई';

  @override
  String get pmEnterPayingNumber => 'भुगतान करने वाला नंबर दर्ज करें (9 अंक)।';

  @override
  String get pmRequestSent => 'अनुरोध भेजा गया…';

  @override
  String get pmPaymentLaunchFailed =>
      'भुगतान शुरू नहीं हो सका। नंबर और अपना कनेक्शन जाँचें, या नीचे मैन्युअल रूप से भुगतान करें।';

  @override
  String get pmValidateOnPhone =>
      'अपने फ़ोन पर पुष्टि करें: संकेत दिखने पर अपना Mobile Money कोड डालें।';

  @override
  String get pmPaymentNotConfirmed =>
      'भुगतान की पुष्टि नहीं हुई। कुछ भी अनलॉक नहीं हुआ।';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'भुगतान हो गया लेकिन प्राप्त लाइसेंस अमान्य है। हमें लिखें, इसे दोबारा बनाया जाएगा: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro सक्रिय किया गया';

  @override
  String get pmPackUnlocked => 'पैक अनलॉक किया गया';

  @override
  String get pmInvalidCode =>
      'यह कोड इस डिवाइस पर मान्य नहीं है। सुनिश्चित करें कि आपने ऊपर दिखाया गया डिवाइस कोड भेजा है।';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'जो Droplet\nकभी नहीं माँगेगा';

  @override
  String get pmNeverAskBody =>
      'न विज्ञापन, न अनिवार्य सदस्यता, न आपके डेटा की पुनर्बिक्री — इसे इकट्ठा करने के लिए तो कोई सर्वर तक नहीं है। पैक और Pro बाकी को वित्तपोषित करते हैं।';

  @override
  String get pmCommunitySemantics =>
      '1200 से अधिक सक्रिय सदस्यों के समुदाय से जुड़ें';

  @override
  String get pmCommunityText => 'मेश पर 1,200+ सदस्यों से जुड़ें';

  @override
  String get pmProPreviewSemantics => 'अनलॉक की गई Pro सुविधाओं की झलक';

  @override
  String get pmAnimatedEmojis => 'एनिमेटेड\nइमोजी';

  @override
  String get pmWallpapers => 'चैट\nवॉलपेपर';

  @override
  String get pmAppIcons => 'ऐप\nआइकन';

  @override
  String get pmOnceForLife => 'एक बार, आजीवन';

  @override
  String get pmProAdvantage1 => 'पैक के दस आइकन और आठ वॉलपेपर';

  @override
  String get pmProAdvantage2 => 'आपके नाम के बगल में Pro बैज';

  @override
  String get pmProAdvantage3 => 'भविष्य की सुविधाएँ, बिना अतिरिक्त शुल्क के';

  @override
  String get pmPackTitle => 'पैक';

  @override
  String get pmOnce => 'एक बार';

  @override
  String get pmPackAdvantage1 => 'दस अतिरिक्त ऐप आइकन';

  @override
  String get pmPackAdvantage2 => 'आठ चैट वॉलपेपर';

  @override
  String get pmPayByHand => 'या मैन्युअल रूप से भुगतान करें';

  @override
  String get pmHowTo => 'कैसे करें';

  @override
  String get pmIfPromptDoesNotArrive =>
      'यदि संकेत आपके फ़ोन पर नहीं आता, या यदि आप स्वयं पैसे भेजना पसंद करते हैं।';

  @override
  String pmStep1Title(Object montant) {
    return '$montant F भेजें';
  }

  @override
  String get pmStep1Body =>
      'अपना ऑपरेटर चुनें: उसका मेनू खुलेगा, और जब आप उसमें नेविगेट करेंगे तब नंबर यहाँ दिखता रहेगा।';

  @override
  String get pmStep2Title => 'अपना डिवाइस कोड भेजें';

  @override
  String get pmStep2Body =>
      'भुगतान के स्क्रीनशॉट के साथ। इस कोड के बिना, लाइसेंस नहीं बन सकता — यह केवल आपके फ़ोन के लिए मान्य है।';

  @override
  String get pmStep3Title => 'आपको एक लाइसेंस मिलेगा';

  @override
  String get pmStep3Body =>
      'DROP1 से शुरू होने वाली एक लंबी लाइन। इसे नीचे पेस्ट करें: अनलॉक तुरंत होता है और हमेशा के लिए ऑफ़लाइन काम करता है।';

  @override
  String get pmPayNow => 'अभी भुगतान करें';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money या Orange Money, इस फ़ोन से या किसी अन्य से।';

  @override
  String get pmPhoneNumberSemantics => 'Mobile Money भुगतान के लिए फ़ोन नंबर';

  @override
  String get pmWaitingForCode => 'आपके कोड की प्रतीक्षा है…';

  @override
  String pmPayAmount(Object montant) {
    return '$montant F भुगतान करें';
  }

  @override
  String get pmRestorePurchaseSemantics => 'पिछली खरीद बहाल करें';

  @override
  String get pmAlreadyPaidRestore => 'पहले ही भुगतान कर दिया? बहाल करें';

  @override
  String pmDialCode(Object code) {
    return 'अपने फ़ोन से $code डायल करें';
  }

  @override
  String get pmChooseOperatorSemantics => 'भुगतान ऑपरेटर चुनें';

  @override
  String get pmNumberAmountFilled =>
      'नंबर और राशि पहले से भरी है — केवल आपका गुप्त कोड बाकी है।';

  @override
  String get pmOrangeMenuInstructions =>
      'Orange मेनू में: धन हस्तांतरण, फिर नीचे दिया गया नंबर और राशि।';

  @override
  String get pmLabelNumber => 'नंबर';

  @override
  String get pmLabelAmount => 'राशि';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return '$operator से $montant फ़्रैंक भुगतान करें';
  }

  @override
  String get pmMenuOpen => 'मेनू खुला है';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'नमस्ते, मैंने अभी Droplet के लिए भुगतान किया है।\n\nऑफ़र: $offer\nराशि: $amount F\nडिवाइस कोड: $code\n\n(भुगतान का स्क्रीनशॉट संलग्न कर रहा/रही हूँ)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp नहीं मिला — कोड कॉपी हो गया। इसे $contact पर भेजें';
  }

  @override
  String get pmPrepareRequest => 'मेरा अनुरोध तैयार करें';

  @override
  String get pmReceivedLicense => 'मुझे मेरा लाइसेंस मिल गया';

  @override
  String get pmPaste => 'पेस्ट करें';

  @override
  String get pmUnlock => 'अनलॉक करें';

  @override
  String get pmProIsActive => 'Droplet Pro सक्रिय है';

  @override
  String get pmPackIsUnlocked => 'पैक अनलॉक है';

  @override
  String get pmProActiveDescription =>
      'Pro बैज आपके नाम के साथ रहता है, और सभी आइकन व वॉलपेपर आपके लिए खुले हैं।';

  @override
  String get pmPackActiveDescription =>
      'पैक के दस आइकन और आठ वॉलपेपर सेटिंग्स में आपके लिए खुले हैं।';

  @override
  String get pmLicenseDeviceBound =>
      'आपका लाइसेंस इस फ़ोन के लिए मान्य है। यदि आप फ़ोन बदलते हैं, तो इसे रखने वाला संदेश सुरक्षित रखें: इसे मुफ़्त में दोबारा बनाया जाएगा।';

  @override
  String torError(Object e) {
    return 'त्रुटि: $e';
  }

  @override
  String get torEnable => 'Tor सक्षम करें';

  @override
  String get torProtected => 'सुरक्षित';

  @override
  String get torDisabled => 'अक्षम';

  @override
  String get torStateHeader => 'स्थिति';

  @override
  String get torCircuit => 'सर्किट';

  @override
  String get torActive => 'सक्रिय';

  @override
  String get torInProgress => 'प्रगति में…';

  @override
  String get torInactive => 'निष्क्रिय';

  @override
  String get torFailed => 'विफल';

  @override
  String get torReason => 'कारण';

  @override
  String get torBannerConnecting => 'Tor से जुड़ रहे हैं…';

  @override
  String get torBannerActive => 'Tor सक्रिय';

  @override
  String get torBannerError => 'Tor अनुपलब्ध';

  @override
  String get torBannerOff => 'Tor बंद';

  @override
  String get torEncryption => 'एन्क्रिप्शन';

  @override
  String get torLatency => 'विलंबता';

  @override
  String get torContactsHeader => 'संपर्क';

  @override
  String get torScanQrFooter =>
      'दूरस्थ संपर्क जोड़ने के लिए, QR कोड स्कैन करें, या डायरेक्ट्री में कोई नाम खोजें।';

  @override
  String get torScanQrCode => 'QR कोड स्कैन करें';

  @override
  String get torMyQrCode => 'मेरा QR कोड';

  @override
  String get torInformationHeader => 'जानकारी';

  @override
  String get torVersion => 'संस्करण';

  @override
  String get torHowItWorks => 'यह कैसे काम करता है?';

  @override
  String get torConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get torInactiveTitle => 'Tor निष्क्रिय';

  @override
  String get torDataThroughTor => 'आपका डेटा Tor नेटवर्क से होकर गुज़रता है';

  @override
  String get torEstablishingCircuit => 'सर्किट स्थापित हो रहा है (10-30 सेकंड)';

  @override
  String get torActivateToProtect =>
      'अपनी पहचान सुरक्षित रखने के लिए सक्रिय करें';

  @override
  String get torHowItWorksTitle => 'Tor आपके डेटा की सुरक्षा कैसे करता है';

  @override
  String get torEncryptedCircuit => 'एन्क्रिप्टेड सर्किट';

  @override
  String get torEncryptedCircuitDesc =>
      'आपके संदेश दुनिया भर के 3 Tor रिले से होकर गुज़रते हैं।';

  @override
  String get torHiddenIp => 'छिपा हुआ IP';

  @override
  String get torHiddenIpDesc => 'कोई भी साइट आपका असली पता नहीं देख सकती।';

  @override
  String get torMeshPreserved => 'मेश सुरक्षित';

  @override
  String get torMeshPreservedDesc =>
      'ब्लूटूथ और लोकल वाई-फ़ाई काम करते रहते हैं।';

  @override
  String get torUnderstood => 'समझ गया';

  @override
  String get qrTorNotActive =>
      'Tor सक्रिय नहीं है। इसे सेटिंग्स > Tor में सक्षम करें।';

  @override
  String get qrScanContactCode => 'किसी संपर्क का QR कोड स्कैन करें';

  @override
  String get qrCodeFromContactScreen =>
      'कोड आपके संपर्क की Tor स्क्रीन से आना चाहिए';

  @override
  String get qrScanAnother => 'दूसरा स्कैन करें';

  @override
  String get qrChat => 'चैट करें';

  @override
  String get qgScanToConnect => 'कनेक्ट करने के लिए स्कैन करें';

  @override
  String get qgCopied => 'कॉपी हो गया ✓';

  @override
  String get qgCopyCode => 'कोड कॉपी करें';

  @override
  String get qgHowItWorks => 'यह कैसे काम करता है';

  @override
  String get qgStep1 => 'अपने संपर्क को यह QR कोड दिखाएँ';

  @override
  String get qgStep2 => 'वे इसे अपनी Tor स्क्रीन से स्कैन करते हैं';

  @override
  String get qgStep3 => 'आप Tor के माध्यम से जुड़े हुए हैं';

  @override
  String get shShareTo => 'इसके साथ साझा करें…';

  @override
  String get shSearchConversation => 'कोई बातचीत खोजें';

  @override
  String get shNoConversation => 'कोई बातचीत नहीं';

  @override
  String get shOpenChatFirst =>
      'सामग्री साझा करने के लिए पहले Droplet में कोई बातचीत खोलें।';

  @override
  String get shGroup => 'समूह';

  @override
  String get shDiscussion => 'चैट';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'साझा करने के लिए $count आइटम',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'मानचित्र इंस्टॉल हो गया';

  @override
  String get omClearCacheTitle => 'कैश साफ़ करें?';

  @override
  String get omRemoveZoneTitle => 'इस क्षेत्र को हटाएँ?';

  @override
  String get omClearCacheMessage =>
      'आपने जिन क्षेत्रों को देखा है वे अब ऑफ़लाइन उपलब्ध नहीं होंगे। नेटवर्क के साथ दोबारा देखने पर वे फिर से बन जाएँगे।';

  @override
  String omRemoveZoneMessage(Object name) {
    return '“$name” इस डिवाइस से हटा दिया जाएगा।';
  }

  @override
  String get omClear => 'साफ़ करें';

  @override
  String get omTitle => 'मानचित्र';

  @override
  String get omReading => 'पढ़ा जा रहा है…';

  @override
  String get omNoMapsSaved => 'कोई मानचित्र सहेजा नहीं गया';

  @override
  String omSizeOnDevice(Object size) {
    return 'इस डिवाइस पर $size';
  }

  @override
  String get omBrowseMapHint =>
      'नेटवर्क के साथ मानचित्र ब्राउज़ करें: आपके देखे गए क्षेत्र ऑफ़लाइन उपलब्ध रहते हैं।';

  @override
  String get omOnThisDevice => 'इस डिवाइस पर';

  @override
  String get omZonesFillThemselves =>
      'जैसे ही आप नेटवर्क के साथ मानचित्र ब्राउज़ करते हैं, देखे गए क्षेत्र अपने आप भर जाते हैं।';

  @override
  String get omMbtilesExplainer =>
      'एक .mbtiles फ़ाइल में पहले से तैयार किया गया एक पूरा क्षेत्र होता है। यह ऑफ़लाइन मानचित्रों का मानक प्रारूप है: कोई भी मानचित्रण उपकरण इसे बना सकता है।';

  @override
  String get omImportMap => 'मानचित्र आयात करें';

  @override
  String get omReadingFile => 'फ़ाइल पढ़ी जा रही है…';

  @override
  String get omMbtilesFromPhone => 'इस फ़ोन से .mbtiles फ़ाइल';

  @override
  String get omAttributionText =>
      'डेटा OpenStreetMap (ODbL लाइसेंस) से आता है, मानचित्र पृष्ठभूमि CARTO द्वारा प्रदान की जाती है। Droplet कभी भी पूरे क्षेत्र को पहले से डाउनलोड नहीं करता: कोई भी मुफ़्त सेवा इसकी अनुमति नहीं देती। केवल वही रखा जाता है जिसे आप देखते हैं।';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टाइलें',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '${k}k टाइलें';
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
  String get nwTitle => 'समाचार';

  @override
  String get nwStatusesNetwork24h => 'नेटवर्क स्थितियाँ · 24 घं';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नेटवर्क स्थितियाँ',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'स्थिति प्रकाशित करें';

  @override
  String get nwNoNewsYet => 'अभी कोई समाचार नहीं';

  @override
  String get nwStatusesAppearHere =>
      'रेंज में मौजूद लोगों द्वारा प्रकाशित स्थितियाँ यहाँ दिखेंगी, बिना इंटरनेट का उपयोग किए।';

  @override
  String get nwRecent => 'हाल के';

  @override
  String get nwStatusExpires =>
      'किसी स्थिति के प्रकाशित होने के 24 घंटे बाद वह अपने आप गायब हो जाती है।';

  @override
  String get nwPhoto => '📷 फोटो';

  @override
  String get nwVideo => '🎥 वीडियो';

  @override
  String get nwVoiceMessage => '🎤 वॉइस संदेश';

  @override
  String get nwMusic => '🎵 संगीत';

  @override
  String get nwStatusFallback => 'स्थिति';

  @override
  String get nwMyStatus => 'मेरी स्थिति';

  @override
  String get nwTapToPublish => 'नेटवर्क पर प्रकाशित करने के लिए टैप करें';

  @override
  String get nwNotSeenYet => 'अभी तक नहीं देखा गया';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लोगों ने देखा',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'स्थान उपलब्ध नहीं है — जाँचें कि लोकेशन सक्षम है।';

  @override
  String mpDistanceMeters(Object m) {
    return '$m मी';
  }

  @override
  String mpDistanceKm(Object km) {
    return '$km किमी';
  }

  @override
  String mpDistanceFromYou(Object distance) {
    return 'आपसे $distance';
  }

  @override
  String get mpTitle => 'स्थान';

  @override
  String get mpOffline => 'ऑफ़लाइन';

  @override
  String get mpOnlineMap => 'ऑनलाइन मानचित्र';

  @override
  String get mpMyPosition => 'मेरा स्थान';

  @override
  String get mpLayers => 'लेयर';

  @override
  String get mpOfflineToast =>
      'ऑफ़लाइन मानचित्र: केवल पहले से सहेजे गए क्षेत्र दिखाए जाएँगे।';

  @override
  String get mpOnlineToast =>
      'ऑनलाइन मानचित्र: देखे गए क्षेत्र बाद के लिए सहेजे जाएँगे।';

  @override
  String get mpMapLabel => 'मानचित्र';

  @override
  String get mpSatelliteLabel => 'सैटेलाइट';

  @override
  String get mpSatelliteMode => 'सैटेलाइट मोड';

  @override
  String get mpMapMode => 'मानचित्र मोड';

  @override
  String get mpWrite => 'लिखें';

  @override
  String get mpCenter => 'केंद्रित करें';

  @override
  String get mpNoOneOnMap => 'मानचित्र पर कोई नहीं';

  @override
  String get mpPositionsAppearHere =>
      'जब कोई संपर्क सुरक्षा मोड से अपना स्थान साझा करता है, तो वह यहाँ दिखता है।';

  @override
  String get mpYou => 'आप';

  @override
  String get mnTitle => 'मेश नेटवर्क';

  @override
  String get mnPeers => 'पीयर';

  @override
  String get mnAvgHops => 'औसत हॉप';

  @override
  String get mnSignal => 'सिग्नल';

  @override
  String get mnStrong => 'मज़बूत';

  @override
  String get mnMedium => 'मध्यम';

  @override
  String get mnSearchingPeers => 'रेंज में पीयर खोजे जा रहे हैं…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पीयर जुड़े हुए',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'अभी तक कोई पीयर कनेक्ट नहीं है';

  @override
  String get mnGetCloserHint =>
      'Droplet इंस्टॉल किए किसी अन्य डिवाइस के करीब जाएँ — खोज अपने आप हो जाती है, बिना किसी सेटअप के।';

  @override
  String get mnConnectedPeersHeader => 'जुड़े हुए पीयर';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हॉप',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'ब्लूटूथ';

  @override
  String get mnWifiLocal => 'लोकल वाई-फ़ाई';

  @override
  String get mnP2pNative => 'नेटिव P2P';

  @override
  String get mnActiveGateway => 'सक्रिय गेटवे';

  @override
  String get mnPath => 'पथ';

  @override
  String get mnTransport => 'ट्रांसपोर्ट';

  @override
  String get mnBattery => 'बैटरी';

  @override
  String get mnScore => 'स्कोर';

  @override
  String get mnReconnecting => 'फिर से जुड़ रहा है';

  @override
  String get cnBronze => 'कांस्य';

  @override
  String get cnSilver => 'रजत';

  @override
  String get cnGold => 'स्वर्ण';

  @override
  String get cnDiamond => 'हीरा';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अंक',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$tier स्तर से पहले $points';
  }

  @override
  String get cnRelayedMessages => 'दूसरों के लिए रिले किए गए संदेश';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n अंक';
  }

  @override
  String get cnGatewayMinutes => 'रिले मोड (गेटवे) में मिनट';

  @override
  String get cnExplanation =>
      'आपका डिवाइस दूसरों के लिए जो भी संदेश रिले करता है, और जिस भी मिनट वह रिले के रूप में उपलब्ध रहता है, वह मेश नेटवर्क को अधिक लोगों तक, अधिक दूर तक पहुँचने में मदद करता है। इस बैज का ऐप पर कोई प्रभाव नहीं है — यह केवल आपके योगदान की एक पहचान है।';

  @override
  String get nmTitle => 'नया संदेश';

  @override
  String get nmNewGroup => 'नया समूह';

  @override
  String get nmScanCode => 'कोड स्कैन करें';

  @override
  String get nmVerifyContactIdentity => 'किसी संपर्क की पहचान सत्यापित करें';

  @override
  String get nmNoOneInRange => 'रेंज में कोई नहीं';

  @override
  String get nmNoResult => 'कोई परिणाम नहीं';

  @override
  String get nmPeopleWillAppearHere =>
      'आपके डिवाइस द्वारा पहचाने गए लोग यहाँ दिखाई देंगे।';

  @override
  String get nmInRange => 'रेंज में';

  @override
  String get nmDirectConnection => 'प्रत्यक्ष कनेक्शन';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिले के माध्यम से',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'फ़ाइल बहुत बड़ी है (अधिकतम 50 MB)';

  @override
  String get chCannotReadMedia => 'यह मीडिया पढ़ा नहीं जा सका';

  @override
  String get chLocationDenied =>
      'स्थान अस्वीकृत — अपना स्थान साझा करने के लिए फ़ोन सेटिंग्स में इसे सक्षम करें।';

  @override
  String get chGettingPosition => 'स्थान प्राप्त हो रहा है…';

  @override
  String get chPositionUnavailable =>
      'स्थान उपलब्ध नहीं है — खुले आसमान के नीचे फिर से प्रयास करें।';

  @override
  String get chMicPermissionDenied => 'माइक्रोफ़ोन अनुमति अस्वीकृत';

  @override
  String get chCannotStartRecording => 'रिकॉर्डिंग शुरू नहीं हो सकी';

  @override
  String get chVoiceSendFailed => 'वॉइस संदेश नहीं भेजा जा सका';

  @override
  String get chFileSendFailed => 'फ़ाइल नहीं भेजी जा सकी';

  @override
  String get chAudioNotFullyReceived =>
      'ऑडियो अभी पूरी तरह से प्राप्त नहीं हुआ है';

  @override
  String get chVoiceUnreadable =>
      'यह वॉइस संदेश चलाया नहीं जा सकता — हो सकता है यह अधूरा पहुँचा हो।';

  @override
  String get chFileNotFullyReceived =>
      'फ़ाइल अभी पूरी तरह से प्राप्त नहीं हुई है';

  @override
  String get chSaveFailed => 'सहेजा नहीं जा सका';

  @override
  String chSavedIn(Object folder) {
    return '$folder में सहेजा गया';
  }

  @override
  String get chMessageCopied => 'संदेश कॉपी हो गया';

  @override
  String get chCallImpossibleRelay =>
      'वॉइस कॉल संभव नहीं: यह साथी केवल रिले या ब्लूटूथ के माध्यम से पहुँच योग्य है, जो आवाज़ के लिए बहुत धीमा है। Wi-Fi पर स्विच करने के लिए करीब आएँ।';

  @override
  String chUrlCopied(Object url) {
    return 'URL कॉपी हुआ: $url';
  }

  @override
  String get chEditMessageTitle => 'संदेश संपादित करें';

  @override
  String get chMessageHint => 'संदेश';

  @override
  String get chNeverMet => 'कभी नहीं मिले';

  @override
  String get chSeenJustNow => 'अभी-अभी देखा गया';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले देखा गया',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले देखा गया',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'कल देखा गया';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले देखा गया',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'रेंज से बाहर';

  @override
  String get chCloseSearchTooltip => 'खोज बंद करें';

  @override
  String get chNetworkDetailsSemantics => 'Droplet नेटवर्क, विवरण देखें';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'लिख रहा है…';

  @override
  String get chBroadcastChannel => 'प्रसारण चैनल';

  @override
  String get chNearby => 'निकट';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिले के माध्यम से पहुँच योग्य',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'फिर से जुड़ रहा है…';

  @override
  String get chSearchInConversation => 'बातचीत में खोजें';

  @override
  String get chVoiceCall => 'वॉइस कॉल';

  @override
  String get chVideoCall => 'वीडियो कॉल';

  @override
  String get chCallImpossibleBtRelay =>
      'कॉल संभव नहीं: ब्लूटूथ या रिले किया गया लिंक';

  @override
  String get chGroupInfoTooltip => 'समूह जानकारी';

  @override
  String get chNoneFound => 'कोई नहीं';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'पुराना परिणाम';

  @override
  String get chNewerResult => 'नया परिणाम';

  @override
  String get chLoadingOlderMessages => 'पहले के संदेश लोड हो रहे हैं…';

  @override
  String get chToday => 'आज';

  @override
  String get chYesterday => 'कल';

  @override
  String get chMonday => 'सोमवार';

  @override
  String get chTuesday => 'मंगलवार';

  @override
  String get chWednesday => 'बुधवार';

  @override
  String get chThursday => 'गुरुवार';

  @override
  String get chFriday => 'शुक्रवार';

  @override
  String get chSaturday => 'शनिवार';

  @override
  String get chSunday => 'रविवार';

  @override
  String get chSayHello => 'नमस्ते कहें 👋';

  @override
  String get chBroadcastEmptyBody =>
      'बिना किसी प्राप्तकर्ता वाले संदेश यहाँ दिखाई देते हैं।';

  @override
  String get chP2pRelayedBody =>
      'आपका आदान-प्रदान पीयर-टू-पीयर रिले होता है, बिना इंटरनेट के।';

  @override
  String get chReply => 'जवाब दें';

  @override
  String get chReplyInThread => 'थ्रेड में जवाब दें';

  @override
  String get chCopy => 'कॉपी करें';

  @override
  String get chAccessibilityMe => 'मैं';

  @override
  String get chPhotoLabel => 'फोटो';

  @override
  String get chVideoLabel => 'वीडियो';

  @override
  String get chVoiceMessageLabel => 'वॉइस संदेश';

  @override
  String chFileLabel(Object name) {
    return 'फ़ाइल $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'स्टिकर $name';
  }

  @override
  String get chSendingStatus => 'भेजा जा रहा है';

  @override
  String get chPendingStatus => 'लंबित';

  @override
  String get chFailedStatus => 'भेजना विफल';

  @override
  String get chReadStatus => 'पढ़ा गया';

  @override
  String get chDeliveredStatus => 'डिलीवर हुआ';

  @override
  String get chSentStatus => 'भेजा गया';

  @override
  String get chForwarded => 'अग्रेषित';

  @override
  String get chRetrySendLabel => 'भेजना पुनः प्रयास करें';

  @override
  String get chTransmissionDetailsLabel => 'प्रसारण विवरण';

  @override
  String get chEditedBadge => 'संपादित';

  @override
  String get chFileWord => 'फ़ाइल';

  @override
  String chSizeBytes(Object n) {
    return '$n बाइट';
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
  String get chVideoReceiving => 'वीडियो प्राप्त हो रहा है';

  @override
  String get chPreparingVideo => 'वीडियो तैयार हो रहा है…';

  @override
  String get nmContacts => 'संपर्क';

  @override
  String get nmFindByPseudo => 'नाम से खोजें';

  @override
  String get nmViaInternet => 'इंटरनेट से';

  @override
  String get nmOutOfRange => 'सीमा से बाहर';

  @override
  String get chatsInvitePerson => 'किसी को आमंत्रित करें';

  @override
  String get ivTitle => 'अपनों को आमंत्रित करें';

  @override
  String get ivSubtitle =>
      'जब अपने साथ हों, Droplet और अच्छा है — नेटवर्क के बिना भी।';

  @override
  String get ivByNumber => 'फ़ोन नंबर से';

  @override
  String get ivNumberHint => 'देश कोड के साथ नंबर (+91…)';

  @override
  String get ivContacts => 'संपर्क';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'लिंक से';

  @override
  String get ivCopy => 'कॉपी करें';

  @override
  String get ivShare => 'शेयर करें';

  @override
  String get ivCopied => 'लिंक कॉपी हुआ';

  @override
  String get ivByQr => 'QR कोड से';

  @override
  String get ivQrHint => 'सामने वाला इसे स्कैन करे।';

  @override
  String get ivScan => 'कोड स्कैन करें';

  @override
  String get ivPrivacy =>
      'लिंक और कोड में सिर्फ़ आपकी सार्वजनिक आईडी और कुंजी है। Droplet को कोई नंबर नहीं भेजा जाता।';

  @override
  String get evTitle => 'वीडियो संपादित करें';

  @override
  String evSplit(int n) {
    return '$n स्टेटस में बाँटें';
  }

  @override
  String evSplitHint(int s) {
    return 'हर भाग अधिकतम $s सेकंड';
  }

  @override
  String evPublished(int n) {
    return '$n स्टेटस पोस्ट हुए';
  }

  @override
  String get svReply => 'जवाब दें';

  @override
  String get svStatusLabel => 'स्टेटस';

  @override
  String svSeenBy(int n) {
    return '$n ने देखा';
  }

  @override
  String get clMissedVoice => 'छूटी वॉइस कॉल';

  @override
  String get clMissedVideo => 'छूटी वीडियो कॉल';

  @override
  String get clCallBack => 'वापस कॉल करें';

  @override
  String get stoTitle => 'स्टोरेज';

  @override
  String get stoSubtitle => 'फ़ोटो, वीडियो और फ़ाइलें';

  @override
  String stoUsed(String taille) {
    return '$taille उपयोग में';
  }

  @override
  String get stoPhotos => 'फ़ोटो';

  @override
  String get stoVideos => 'वीडियो';

  @override
  String get stoAudio => 'वॉइस और ऑडियो';

  @override
  String get stoDocuments => 'दस्तावेज़';

  @override
  String get stoOther => 'अन्य (स्टेटस…)';

  @override
  String get stoByChat => 'चैट के अनुसार';

  @override
  String get stoEmpty => 'इस फ़ोन पर कोई फ़ाइल नहीं';

  @override
  String stoDelete(int n) {
    return 'हटाएँ ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'ये फ़ाइलें और उनके संदेश इस फ़ोन से हटा दिए जाएँगे।';

  @override
  String get tabSelectChat => 'कोई चैट चुनें';

  @override
  String get clConnecting => 'कनेक्ट हो रहा है…';

  @override
  String chUnreadMessages(int n) {
    return '$n अपठित संदेश';
  }

  @override
  String get csMessagesSection => 'संदेश';

  @override
  String chGroupTyping(String noms) {
    return '$noms लिख रहे हैं…';
  }

  @override
  String get tsReadBy => 'पढ़ा गया';

  @override
  String get tsDeliveredTo => 'पहुँचा';

  @override
  String get tsWaitingFor => 'प्रतीक्षा में';

  @override
  String get chSelect => 'चुनें';

  @override
  String get chForward => 'फ़ॉरवर्ड करें';

  @override
  String get chForwardTo => 'इन्हें फ़ॉरवर्ड करें…';

  @override
  String chSelectedCount(int n) {
    return '$n चुने गए';
  }

  @override
  String get chForwarded1 => 'संदेश फ़ॉरवर्ड किया गया';

  @override
  String get apCaptionHint => 'कैप्शन जोड़ें…';

  @override
  String get apValidateCrop => 'क्रॉप करें';

  @override
  String get chMediaReceiving => 'प्राप्त हो रहा है';

  @override
  String get chStickersTooltip => 'स्टिकर';

  @override
  String get chAttachTooltip => 'अटैच करें';

  @override
  String get chDeleteRecordingTooltip => 'रिकॉर्डिंग हटाएँ';

  @override
  String get chSlideToCancel => 'रद्द करने के लिए स्लाइड करें';

  @override
  String chReplyingTo(Object pseudo) {
    return '$pseudo को जवाब';
  }

  @override
  String get chEffectBoom => 'बूम';

  @override
  String get chEffectLoud => 'ज़ोरदार';

  @override
  String get chEffectGentle => 'कोमल';

  @override
  String get chEffectInvisibleInk => 'अदृश्य स्याही';

  @override
  String get chEffectConfetti => 'कंफ़ेटी';

  @override
  String get chEffectFireworks => 'आतिशबाज़ी';

  @override
  String get chEffectHearts => 'दिल';

  @override
  String get chEffectSheetTitle => 'संदेश प्रभाव';

  @override
  String get chEffectSheetSubtitle =>
      'यह एक बार चलता है, आपकी और आपके संपर्क की स्क्रीन पर';

  @override
  String get chOnBubble => 'बबल पर';

  @override
  String get chFullscreen => 'फ़ुलस्क्रीन';

  @override
  String get chTapToReveal => 'प्रकट करने के लिए टैप करें';

  @override
  String get chThreadTitle => 'थ्रेड';

  @override
  String get chReplyHint => 'जवाब…';

  @override
  String get chCollapse => 'संक्षिप्त करें';

  @override
  String get chSeeMore => 'और देखें';

  @override
  String get chMessageOptionsSemantics => 'संदेश विकल्प';

  @override
  String get chLoveReactionSemantics => 'बहुत पसंद है';

  @override
  String get chBroadcastMesh => 'मेश प्रसारण';

  @override
  String get chGroupFallback => 'समूह';

  @override
  String get ciSetupBiometrics =>
      'अपने डिवाइस सेटिंग्स में फ़िंगरप्रिंट या Face ID सेट करें।';

  @override
  String get ciEnableLockReason => 'इस बातचीत के लिए लॉक सक्षम करें';

  @override
  String get ciInfoTitle => 'जानकारी';

  @override
  String get ciViewConversation => 'बातचीत देखें';

  @override
  String get ciGatewayOnline => 'गेटवे · ऑनलाइन';

  @override
  String get ciOnline => 'ऑनलाइन';

  @override
  String get ciOffline => 'ऑफ़लाइन';

  @override
  String get ciMessages => 'संदेश';

  @override
  String get ciMedia => 'मीडिया';

  @override
  String get ciStart => 'शुरुआत';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़ोटो ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वॉइस नोट ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़ाइलें ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'अभी तक कोई मीडिया साझा नहीं किया गया है।';

  @override
  String get ciSecurityCode => 'सुरक्षा कोड';

  @override
  String get ciVerified => 'सत्यापित';

  @override
  String get ciKeyChanged => 'कुंजी बदल गई है';

  @override
  String get ciNotVerified => 'असत्यापित';

  @override
  String get ciConversationLock => 'बातचीत लॉक';

  @override
  String get ciLockEnabled => 'सक्षम — खोलने के लिए फ़िंगरप्रिंट आवश्यक';

  @override
  String get ciDisabled => 'अक्षम';

  @override
  String get ciEphemeralMessages => 'अस्थायी संदेश';

  @override
  String get ci30Seconds => '30 सेकंड';

  @override
  String get ci5Minutes => '5 मिनट';

  @override
  String get ci1Hour => '1 घंटा';

  @override
  String get ci24Hours => '24 घंटे';

  @override
  String get ciDurationBeforeDisappear => 'गायब होने से पहले का समय';

  @override
  String get ciBlockContactTitle => 'इस संपर्क को ब्लॉक करें?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo अब आपको संदेश नहीं भेज पाएगा। आप उसे कभी भी अनब्लॉक कर सकते हैं।';
  }

  @override
  String get ciBlock => 'ब्लॉक करें';

  @override
  String get ciUnblock => 'अनब्लॉक करें';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo को ब्लॉक कर दिया गया है';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo को अनब्लॉक कर दिया गया है';
  }

  @override
  String get ciReportContactTitle => 'इस संपर्क की शिकायत करें?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Droplet को एक गुमनाम रिपोर्ट भेजी जाएगी: केवल एक तकनीकी पहचानकर्ता और नीचे चुना गया कारण, और कुछ नहीं। $pseudo के साथ कोई भी संदेश या बातचीत कभी नहीं भेजी जाती।';
  }

  @override
  String get ciReport => 'रिपोर्ट करें';

  @override
  String get ciReportSent => 'रिपोर्ट भेज दी गई है। धन्यवाद।';

  @override
  String get ciReportFailed =>
      'रिपोर्ट नहीं भेजी जा सकी — बाद में फिर से कोशिश करें।';

  @override
  String get ciReportReasonSpam => 'स्पैम';

  @override
  String get ciReportReasonHarassment => 'उत्पीड़न';

  @override
  String get ciReportReasonIllegal => 'अवैध सामग्री';

  @override
  String get ciReportReasonOther => 'अन्य';

  @override
  String mcReactWith(Object emoji) {
    return '$emoji से प्रतिक्रिया दें';
  }

  @override
  String get nsMeshActive => 'मेश सक्रिय';

  @override
  String get nsNoDeviceInRange => 'रेंज में कोई डिवाइस नहीं';

  @override
  String get nsMessagesCirculate =>
      'आपके संदेश बिना इंटरनेट के डिवाइस से डिवाइस तक जाते हैं।';

  @override
  String get nsGetCloser =>
      'किसी अन्य Droplet डिवाइस के करीब जाएँ। आपके संदेश सुरक्षित रहेंगे और अपने आप भेज दिए जाएँगे।';

  @override
  String get nsDevicesInRange => 'रेंज में डिवाइस';

  @override
  String get nsReconnectingTitle => 'फिर से जुड़ रहा है';

  @override
  String get nsLinkMomentarilyLost =>
      'लिंक अस्थायी रूप से खो गया है, अभी छोड़ा नहीं गया है।';

  @override
  String get nsRelaysAvailable => 'उपलब्ध रिले';

  @override
  String get nsNoRelayAvailable =>
      'फ़िलहाल कोई भी डिवाइस आपके संदेशों को आगे नहीं भेज सकता।';

  @override
  String get nsViaBluetooth => 'ब्लूटूथ के माध्यम से';

  @override
  String get nsViaLocalWifi => 'लोकल वाई-फ़ाई के माध्यम से';

  @override
  String get nsWifiCarriesMore =>
      'Wi-Fi फ़ाइलें और आवाज़ ले जाता है; ब्लूटूथ केवल टेक्स्ट ले जाता है।';

  @override
  String get scInvalidQrCode => 'अमान्य QR कोड';

  @override
  String get scWrongCode => 'यह सही कोड नहीं है — कुंजी मेल नहीं खाती';

  @override
  String get scCodeVerified => 'कोड सत्यापित';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'सत्यापित — $pseudo की कुंजी इस कोड से मेल खाती है।';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'अंतिम सत्यापन के बाद से $pseudo की कुंजी बदल गई है।';
  }

  @override
  String get scNotVerifiedYet => 'अभी तक सत्यापित नहीं।';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'इस कोड की तुलना $pseudo के डिवाइस पर दिखाए गए कोड से करें, या स्वचालित रूप से सत्यापित करने के लिए उनका QR कोड सीधे स्कैन करें।';
  }

  @override
  String get scContactKeyUnknown =>
      'संपर्क की कुंजी अभी तक ज्ञात नहीं है — मेश पर इस साथी से फिर से जुड़ें।';

  @override
  String scScanCodeOf(Object pseudo) {
    return '$pseudo का कोड स्कैन करें';
  }

  @override
  String get tsNotDelivered => 'डिलीवर नहीं हुआ';

  @override
  String get tsRead => 'पढ़ा गया';

  @override
  String get tsDelivered => 'डिलीवर हुआ';

  @override
  String get tsSendingInProgress => 'भेजा जा रहा है';

  @override
  String get tsWaitingForRelay => 'रिले की प्रतीक्षा में';

  @override
  String get tsSent => 'भेजा गया';

  @override
  String tsSecondsSingular(Object value) {
    return '$value सेकंड';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value सेकंड';
  }

  @override
  String tsMinutes(Object n) {
    return '$n मिनट';
  }

  @override
  String tsHours(Object n) {
    return '$n घं';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'प्रसारण';

  @override
  String get tsStatus => 'स्थिति';

  @override
  String get tsDelayUntilRead => 'पढ़े जाने तक का समय';

  @override
  String get tsRoute => 'मार्ग';

  @override
  String get tsRouteDetail =>
      'वे डिवाइस जिन्होंने इस संदेश को क्रम में आगे भेजा।';

  @override
  String get tsPath => 'पथ';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डिवाइस से होकर गुज़रा',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'सीधे प्राप्त हुआ';

  @override
  String get tsIntermediateDevicesDetail =>
      'बीच के डिवाइसों ने यह संदेश आप तक पहुँचाया।';

  @override
  String get tsUnknown => 'अज्ञात';

  @override
  String get tsSentRouteNotReturned =>
      'भेजे गए संदेश का मार्ग उसके भेजने वाले को वापस नहीं भेजा जाता।';

  @override
  String get tsNetwork => 'नेटवर्क';

  @override
  String get tsMeshDroplet => 'Droplet मेश';

  @override
  String get tsNoServerNoOperator => 'कोई सर्वर नहीं, कोई ऑपरेटर नहीं।';

  @override
  String get qsScanSecurityCode => 'सुरक्षा कोड स्कैन करें';

  @override
  String get qsCodeDetected => 'कोड मिल गया';

  @override
  String get qsFrameQrCode =>
      'अपने संपर्क के डिवाइस पर दिखाए गए QR कोड को फ़्रेम में लाएँ';

  @override
  String get rmRecentVideo => 'हालिया वीडियो';

  @override
  String get rmRecentPhoto => 'हालिया फोटो';

  @override
  String get rmSeeAllPhotos => 'सभी फ़ोटो देखें';

  @override
  String get rmSeeAll => 'सब देखें';

  @override
  String get aicOriginal => 'मूल';

  @override
  String get aicAzure => 'आसमानी';

  @override
  String get aicNeon => 'नियॉन';

  @override
  String get aicPaper => 'कागज़';

  @override
  String get aicLagoon => 'लैगून';

  @override
  String get aicAmethyst => 'बैंगनी रत्न';

  @override
  String get aicGold => 'स्वर्ण';

  @override
  String get aicTide => 'ज्वार';

  @override
  String get aicDawn => 'उषा';

  @override
  String get aicGlass => 'काँच';

  @override
  String get aicConstellation => 'तारामंडल';

  @override
  String get aicPrism => 'प्रिज्म';

  @override
  String get aicEmerald => 'पन्ना';

  @override
  String get aicChangeIconTitle => 'आइकन बदलें?';

  @override
  String aicChangeIconMessage(Object name) {
    return '\"$name\" आइकन आपकी होम स्क्रीन पर मौजूद आइकन की जगह ले लेगा। कुछ लॉन्चर इसे दिखाने में कुछ सेकंड लेते हैं, या होम स्क्रीन पर वापस जाने के लिए कहते हैं।';
  }

  @override
  String get aicApply => 'लागू करें';

  @override
  String aicIconApplied(Object name) {
    return '\"$name\" आइकन लागू किया गया';
  }

  @override
  String get aicChangeIconImpossible => 'इस डिवाइस पर आइकन बदलना संभव नहीं है';

  @override
  String get aicTitle => 'आइकन';

  @override
  String get aicCurrentOnHomeScreen => 'वह जो आपकी होम स्क्रीन पर दिखता है';

  @override
  String get aicUnavailablePlatform => 'इस प्लेटफ़ॉर्म पर अनुपलब्ध';

  @override
  String get aicAndroidExplanation =>
      'Android किसी ऐप के आइकन को इंस्टॉलेशन के समय तय कर देता है। Droplet इसे कई एंट्री पॉइंट घोषित करके दरकिनार करता है, प्रति आइकन एक, और केवल एक को सक्रिय रखता है। आपके लॉन्चर को इसे नोटिस करने में कुछ सेकंड लग सकते हैं।';

  @override
  String get aicAndroidOnly => 'आइकन बदलना केवल Android पर उपलब्ध है।';

  @override
  String get beWeak => 'कमज़ोर';

  @override
  String get beOkay => 'ठीक-ठाक';

  @override
  String get beStrong => 'मज़बूत';

  @override
  String get bePasswordTooShort => 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए';

  @override
  String get bePasswordsDontMatch => 'दोनों पासवर्ड मेल नहीं खाते';

  @override
  String get beBackupSubject => 'Droplet बैकअप';

  @override
  String get beBackupShareText =>
      'मेरी Droplet पहचान का एन्क्रिप्टेड बैकअप — इसे सुरक्षित जगह पर रखें।';

  @override
  String get beBackupCreated => 'बैकअप बनाया गया';

  @override
  String get beBackupFailed => 'बैकअप विफल';

  @override
  String get beBackupMyIdentity => 'मेरी पहचान का बैकअप लें';

  @override
  String get beWarningBody =>
      'इस फ़ाइल और पासवर्ड वाला कोई भी व्यक्ति आपका रूप धारण कर सकता है। इसे सुरक्षित रखें (अपने अलावा किसी और को कभी न भेजें) और एक ऐसा पासवर्ड चुनें जिसे केवल आप जानते हों।';

  @override
  String get bePasswordProtects =>
      'यह पासवर्ड आपके बैकअप की सुरक्षा करता है। यह कभी सहेजा नहीं जाता: इसके बिना, फ़ाइल स्थायी रूप से अनुपयोगी हो जाती है।';

  @override
  String get bePassword => 'पासवर्ड';

  @override
  String get beConfirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get beIncludeMessageHistory => 'संदेश इतिहास शामिल करें';

  @override
  String get beOtherwiseOnlyIdentity =>
      'अन्यथा, केवल पहचान, संपर्क और समूह सहेजे जाते हैं';

  @override
  String get beCreateAndShare => 'बैकअप बनाएँ और साझा करें';

  @override
  String get jsErrorJournalTitle => 'त्रुटि लॉग';

  @override
  String get jsNoErrorsRecorded =>
      'कोई त्रुटि दर्ज नहीं है। यह सामान्य स्थिति है।';

  @override
  String get jsLinesStayOnDevice =>
      'ये पंक्तियाँ इसी डिवाइस पर रहती हैं: Droplet के पास इन्हें भेजने के लिए कोई सर्वर नहीं है। यदि आप ऐप का परीक्षण कर रहे हैं, तो कृपया इन्हें भेजें — इनके बिना, यह खामी किसी के लिए मौजूद ही नहीं है।';

  @override
  String get jsErase => 'मिटाएँ';

  @override
  String get jsShareSubject => 'Droplet — त्रुटि लॉग';

  @override
  String get jsShareText =>
      'Droplet त्रुटि लॉग। इस फ़ाइल में न तो संदेश हैं, न संपर्क, न ही कुंजियाँ।';

  @override
  String get jsShareUnavailable => 'साझा करना उपलब्ध नहीं — लॉग कॉपी हो गया';

  @override
  String get clOutgoingCall => 'कॉल हो रही है…';

  @override
  String get clIncomingCall => 'इनकमिंग कॉल…';

  @override
  String get clCallImpossible => 'कॉल संभव नहीं';

  @override
  String get clCallEnded => 'कॉल समाप्त';

  @override
  String clCallWith(Object pseudo) {
    return '$pseudo के साथ कॉल';
  }

  @override
  String get clEndToEndEncrypted => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String clCallStatusSemantics(Object status) {
    return 'कॉल स्थिति: $status';
  }

  @override
  String get clEnableMic => 'माइक्रोफ़ोन चालू करें';

  @override
  String get clMuteMic => 'माइक्रोफ़ोन म्यूट करें';

  @override
  String get clDisableSpeaker => 'स्पीकर बंद करें';

  @override
  String get clEnableSpeaker => 'स्पीकर चालू करें';

  @override
  String get clDisableCamera => 'कैमरा बंद करें';

  @override
  String get clEnableCamera => 'कैमरा चालू करें';

  @override
  String get clHangUp => 'कॉल काटें';

  @override
  String get clIncomingVideoCall => 'आने वाली वीडियो कॉल';

  @override
  String get clSwitchCamera => 'कैमरा बदलें';

  @override
  String get gcGroupCall => 'ग्रुप कॉल';

  @override
  String get gcConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get gcOnline => 'ऑनलाइन';

  @override
  String get gcFailed => 'विफल';

  @override
  String get gcDisconnected => 'डिस्कनेक्ट';

  @override
  String get gcReturnToCall => 'कॉल पर वापस जाएँ';

  @override
  String get gcMinimize => 'छोटा करें';

  @override
  String get gcVoiceOnly => 'केवल आवाज़';

  @override
  String gcReactWith(String emoji) {
    return '$emoji से प्रतिक्रिया दें';
  }

  @override
  String get gcSpeakingNow => 'अभी बोल रहे हैं';

  @override
  String get gcMicOff => 'माइक बंद';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भागीदार · केवल वॉइस',
      one: '$count भागीदार · केवल वॉइस',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'संदेश';

  @override
  String get ntfChannelMessagesDesc => 'नए संदेश और मेश स्टेटस';

  @override
  String get ntfChannelCallsName => 'कॉल';

  @override
  String get ntfChannelCallsDesc => 'इनकमिंग और मिस्ड कॉल';

  @override
  String get ntfChannelMeshName => 'मेश और आपातकाल';

  @override
  String get ntfChannelMeshDesc => 'सक्रिय मेश सेवा, स्टेटस और आपातकालीन संदेश';

  @override
  String get ntfReply => 'जवाब दें';

  @override
  String get ntfYourReply => 'आपका जवाब';

  @override
  String get ntfMarkAsRead => 'पढ़ा हुआ चिह्नित करें';

  @override
  String get ntfIncomingCall => 'इनकमिंग कॉल';

  @override
  String get ntfAnswer => 'कॉल स्वीकारें';

  @override
  String get ntfDecline => 'अस्वीकार करें';

  @override
  String get ntfMissedCall => 'मिस्ड कॉल';

  @override
  String get ntfSendFailedTitle => 'भेजना विफल';

  @override
  String get ntfSendFailedBody =>
      'एक संदेश भेजा नहीं जा सका — जैसे ही कोई पीयर रेंज में आएगा, दोबारा कोशिश होगी।';

  @override
  String get ntfNewStatusTitle => 'नया स्टेटस';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo ने एक स्टेटस पोस्ट किया';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo को आपका स्टेटस पसंद आया';
  }

  @override
  String get ntfTapToView => 'देखने के लिए टैप करें';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo ने आपके स्टेटस पर जवाब दिया';
  }

  @override
  String get ntfEmergencyTitle => 'आपातकालीन संदेश';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo ने \"मैं सुरक्षित हूँ\" प्रसारित किया';
  }

  @override
  String get mnAccept => 'स्वीकारें';

  @override
  String get mnMeshVoiceCall => 'मेश वॉइस कॉल';

  @override
  String get mnGroupCallIncoming => 'इनकमिंग ग्रुप कॉल';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo आपको आमंत्रित कर रहा है';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ग्रुप कॉल · $count अन्य भागीदार',
      one: 'ग्रुप कॉल · $count अन्य भागीदार',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'इस स्टेटस को कौन देख सकता है?';

  @override
  String get asAllContacts => 'मेरे सभी संपर्क';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संपर्क',
      one: '$count संपर्क',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'सिवाय...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बाहर रखे गए',
      one: '$count बाहर रखा गया',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'संपर्क बाहर रखें';

  @override
  String get asOnlyOption => 'केवल...';

  @override
  String get asShareWithSpecific => 'विशिष्ट संपर्कों के साथ साझा करें';

  @override
  String get asNoContactsAvailable => 'कोई संपर्क उपलब्ध नहीं';

  @override
  String get asConfirm => 'पुष्टि करें';

  @override
  String get apYourPhoto => 'आपकी फ़ोटो';

  @override
  String get apNoPhotoAccessible => 'इस डिवाइस पर कोई फ़ोटो उपलब्ध नहीं है।';

  @override
  String get apBrowseFiles => 'फ़ाइलें ब्राउज़ करें';

  @override
  String get apRecentPhoto => 'हाल की फ़ोटो';

  @override
  String get bgSkip => 'छोड़ें';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'चरण $rang / $total।';
  }

  @override
  String get csGuideNetworkTitle => 'आसपास कोई नहीं? यह सामान्य है';

  @override
  String get csGuideNetworkText =>
      'Droplet किसी सर्वर से नहीं गुज़रता: यह रेंज में मौजूद फोनों से बात करता है। यहाँ आप देख सकते हैं कि कौन उपलब्ध है, और किस रेडियो से। शून्य पीयर होने का मतलब खराबी नहीं है — बस इतना है कि अभी कोई मौजूद नहीं है।';

  @override
  String get csGuideWriteTitle => 'कोई न होने पर भी लिखें';

  @override
  String get csGuideWriteText =>
      'अभी लिखा गया संदेश आपके फ़ोन पर प्रतीक्षा करता है और जैसे ही कोई डिवाइस रेंज में आता है — सड़क पर, टैक्सी में — रवाना हो जाता है। यह खोया नहीं है, बस प्रतीक्षा कर रहा है।';

  @override
  String get csGuideBackupTitle => 'अपनी पहचान का बैकअप लें';

  @override
  String get csGuideBackupText =>
      'सर्वर न होने पर, कोई भी आपका खाता वापस नहीं दे सकता। सेटिंग्स से अपनी पहचान एक्सपोर्ट करें: इस बैकअप के बिना, खोया हुआ फ़ोन सब कुछ अपने साथ ले जाता है।';

  @override
  String get csShowLockedChatsReason => 'लॉक की गई चैट दिखाएँ';

  @override
  String get cvlNoBiometricsConfigured =>
      'इस डिवाइस पर कोई फ़िंगरप्रिंट सेट नहीं है';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return '$pseudo के साथ बातचीत अनलॉक करें';
  }

  @override
  String get cvlAuthFailed => 'प्रमाणीकरण विफल';

  @override
  String get cvlAuthError => 'प्रमाणीकरण त्रुटि';

  @override
  String get cvlConversationLocked => 'लॉक की गई बातचीत';

  @override
  String get cvlUnlock => 'अनलॉक करें';

  @override
  String get dcAddText => 'टेक्स्ट जोड़ें';

  @override
  String get dcYourTextHint => 'आपका टेक्स्ट...';

  @override
  String get pbDropletProBadge => 'Droplet Pro बैज';

  @override
  String get rpReact => 'प्रतिक्रिया दें';

  @override
  String get rpSaveToPhone => 'फ़ोन में सेव करें';

  @override
  String get chViaTor => 'Tor के ज़रिए';

  @override
  String get chTorInactive => 'Tor निष्क्रिय';

  @override
  String get chViaInternet => 'इंटरनेट के ज़रिए';

  @override
  String get chReachedViaTorSemantic => 'Tor के ज़रिए संपर्क';

  @override
  String get nsTorConnectedTitle => 'Tor के ज़रिए कनेक्ट';

  @override
  String get nsTorInactiveTitle => 'Tor बंद है';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'आपके संदेश Tor नेटवर्क से होकर एक एन्क्रिप्टेड मेलबॉक्स में तब तक प्रतीक्षा करते हैं जब तक $pseudo उससे कनेक्ट नहीं होता।';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return '$pseudo को लिखने के लिए सेटिंग्स में Tor चालू करें — इसके बिना, आपके संदेश इसी डिवाइस पर प्रतीक्षा करते रहेंगे।';
  }

  @override
  String get nsTorMailboxTitle => 'एन्क्रिप्टेड मेलबॉक्स';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'इसमें क्या है, यह न तो आप पढ़ सकते हैं न ही Droplet — केवल $pseudo के पास कुंजी है।';
  }

  @override
  String get nsOpenTorSettings => 'Tor चालू करें';

  @override
  String get qrInvalidCode => 'यह QR कोड Droplet का कोड नहीं है।';

  @override
  String get qrPeerAdded => 'संपर्क जोड़ा गया';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'अब आप $pseudo से बातचीत कर सकते हैं';
  }

  @override
  String get clViaInternet => 'इंटरनेट के ज़रिए';

  @override
  String get tsPathTorDetail =>
      'यह संदेश आपके आसपास के डिवाइसों से होकर नहीं गुज़रता: यह Tor नेटवर्क पर एक एन्क्रिप्टेड मेलबॉक्स से होकर जाता है, जिस तक केवल आप दोनों की पहुँच है।';

  @override
  String get tsNetworkTorDetail =>
      'इस संपर्क तक दूर से पहुँचने के लिए एक रिले सर्वर की ज़रूरत होती है — स्थानीय मेश के विपरीत, यहाँ Droplet इसके बिना काम नहीं कर सकता।';

  @override
  String get torSearchDirectory => 'डायरेक्ट्री में खोजें';

  @override
  String get dvTitle => 'खोजें';

  @override
  String get dvClose => 'बंद करें';

  @override
  String get dvSearchHint => 'नाम खोजें...';

  @override
  String get dvEnableTorToSearch =>
      'डायरेक्ट्री में खोजने के लिए सेटिंग्स में Tor चालू करें।';

  @override
  String get dvSearching => 'खोज जारी है...';

  @override
  String get dvNoResults => 'कोई परिणाम नहीं';

  @override
  String get dvNoUserFound => 'इस खोज के लिए कोई उपयोगकर्ता नहीं मिला।';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count परिणाम',
      one: '$count परिणाम',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'भेजें';

  @override
  String get aiNewConversation => 'नई बातचीत';

  @override
  String get aiMessageHint => 'संदेश';

  @override
  String get aiCopied => 'कॉपी हो गया';

  @override
  String get aiAskQuestion => 'एक सवाल पूछें';

  @override
  String get aiRunsLocally =>
      'यह सहायक पूरी तरह आपके डिवाइस पर चलता है — कुछ भी कभी इंटरनेट पर नहीं भेजा जाता।';

  @override
  String get aiMemorySaved => 'मैं यह याद रखूँगा।';

  @override
  String get aiMemoryForgotten => 'आपने जो याद रखने को कहा था, मैं वह भूल गया।';

  @override
  String get aiMemoryTitle => 'सहायक की स्मृति';

  @override
  String get aiMemoryEmpty =>
      'अभी कुछ भी सहेजा नहीं गया। कुछ पिन करने के लिए कहें «यह याद रखो…»।';

  @override
  String get aiMemoryForget => 'सब कुछ भूल जाओ';

  @override
  String get aiExpertHint =>
      'मैं Droplet को बारीकी से जानता हूँ: मेश, Tor, कॉल, निजता।';

  @override
  String get chAskAssistant => 'सहायक से पूछें';

  @override
  String chAskAssistantInvite(Object name) {
    return '$name को जवाब देने में मेरी मदद करो।';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'सहायक तैयार हो रहा है… $percentage%';
  }

  @override
  String get aiOneTimeDownload =>
      'केवल एक बार — इसके बाद यह आपके डिवाइस पर ही रहता है, कोई और डाउनलोड नहीं।';

  @override
  String get aiGenericError => 'क्षमा करें, कुछ गड़बड़ हो गई।';

  @override
  String get aiNotAvailableYet =>
      'Droplet के इस संस्करण में सहायक अभी उपलब्ध नहीं है।';

  @override
  String aiDownloadFailed(Object error) {
    return 'डाउनलोड विफल: $error';
  }

  @override
  String get ntfSomeoneCalling => 'कोई आपसे संपर्क करने की कोशिश कर रहा है';

  @override
  String get ntfNewMessageWake => 'नया संदेश — पढ़ने के लिए Droplet खोलें';

  @override
  String get chNearbyAndInternet => 'पास में · इंटरनेट';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिले · इंटरनेट',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'इंटरनेट की प्रतीक्षा';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पास में · इंटरनेट',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पास में · इंटरनेट नहीं',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'पास में कोई नहीं · इंटरनेट';

  @override
  String get clPathMesh => 'मेश · सीधा वाई-फ़ाई';

  @override
  String get clPathInternetDirect => 'इंटरनेट · सीधा';

  @override
  String get clPathInternetRelay => 'इंटरनेट · सुरक्षित रिले';

  @override
  String get clReconnecting => 'फिर से जुड़ रहा है…';

  @override
  String get clLabelSpeaker => 'स्पीकर';

  @override
  String get clLabelCamera => 'कैमरा';

  @override
  String get clLabelMic => 'माइक';

  @override
  String get clLabelFlip => 'पलटें';

  @override
  String get clEncryptedShort => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String clQualitySemantics(int bars) {
    return 'कॉल की गुणवत्ता: 3 में से $bars';
  }

  @override
  String get beOnlineTitle => 'स्वचालित ऑनलाइन बैकअप';

  @override
  String get beOnlineBody =>
      'हर दिन इस पासवर्ड से एन्क्रिप्ट की गई एक प्रति Droplet सर्वर पर रखी जाती है, जिसे सर्वर पढ़ नहीं सकता। नए फ़ोन पर वही नाम और वही पासवर्ड काफ़ी हैं। प्राप्त फ़ोटो, वीडियो और फ़ाइलें शामिल नहीं हैं।';

  @override
  String get beOnlineSwitch => 'हर दिन सर्वर पर बैकअप लें';

  @override
  String beOnlineLast(String date) {
    return 'पिछला बैकअप: $date';
  }

  @override
  String get beOnlineNever => 'अभी तक कोई ऑनलाइन बैकअप नहीं';

  @override
  String get beOnlineNow => 'अभी बैकअप लें';

  @override
  String get beOnlineDone => 'ऑनलाइन बैकअप हो गया';

  @override
  String get beOnlineFailed => 'अभी ऑनलाइन बैकअप संभव नहीं';

  @override
  String get obRestoreFromServer => 'सर्वर से पुनर्स्थापित करें';

  @override
  String get obEnterPseudoFirst => 'पहले अपने बैकअप का नाम दर्ज करें';

  @override
  String get obNoServerBackup => 'इस नाम और पासवर्ड के लिए कोई बैकअप नहीं मिला';

  @override
  String get obTooManyAttempts =>
      'बहुत अधिक प्रयास — एक घंटे बाद फिर कोशिश करें';

  @override
  String get chatsInviteLink => 'लिंक से आमंत्रित करें';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo आपको Droplet पर आमंत्रित करते हैं, एन्क्रिप्टेड मैसेंजर जो बिना नेटवर्क के भी चलता है: $lien';
  }

  @override
  String get invTitle => 'आमंत्रण';

  @override
  String invBody(String pseudo) {
    return '$pseudo आपको Droplet पर बात करने के लिए आमंत्रित करते हैं।';
  }

  @override
  String get invAdd => 'जोड़ें और लिखें';

  @override
  String get invInvalid => 'यह आमंत्रण लिंक अमान्य या अधूरा है।';

  @override
  String get invSelf => 'यह आपका अपना आमंत्रण लिंक है।';
  @override
  String get seAnimationHeader => 'भेजने का एनिमेशन';

  @override
  String get seAnimationFull => 'पूर्ण';

  @override
  String get seAnimationReduced => 'सीमित';

  @override
  String get seAnimationOff => 'बंद';

  @override
  String get seAnimationFullDesc => 'प्लिक आपका संदेश ले जाता है, टेलीपोर्ट करता है और हाथ हिलाता है।';

  @override
  String get seAnimationReducedDesc => 'सिर्फ़ एक फ़ेड, बिना गति या कणों के।';

  @override
  String get seAnimationOffDesc => 'भेजने के बाद कोई एनिमेशन नहीं।';

  @override
  String get seAnimationReplay => 'फिर चलाने के लिए टैप करें';

  @override
  String get seAnimationNone => 'कोई एनिमेशन नहीं';

  @override
  String get seAnimationSampleIn => 'क्या हम बंदरगाह पर मिलें?';

  @override
  String get seAnimationSampleOut => 'अभी मिलते हैं';

  @override
  String get trTitle => 'अनुवाद';

  @override
  String get trOnDevice => 'डिवाइस पर अनुवाद हो रहा है…';

  @override
  String get trUnknownLang => 'अज्ञात भाषा';

  @override
  String get trOriginal => 'मूल';

  @override
  String get trCopy => 'कॉपी करें';

  @override
  String get trInChat => 'चैट में';

  @override
  String get trRetry => 'फिर कोशिश करें';

  @override
  String get trSame => 'यह संदेश पहले से इसी भाषा में है।';

  @override
  String get trModel => 'इस भाषा का मॉडल अभी डिवाइस पर इंस्टॉल नहीं है।';

  @override
  String get trUnavailable => 'इस डिवाइस में ऑफ़लाइन अनुवाद इंजन नहीं है।';

  @override
  String get trFailed => 'अनुवाद पूरा नहीं हो सका।';

  @override
  String get pfMessage => 'संदेश';

  @override
  String get pfCall => 'कॉल';

  @override
  String get pfSecurity => 'सुरक्षा';

  @override
  String get aiActCopy => 'कॉपी करें';

  @override
  String get aiActRead => 'ज़ोर से पढ़ें';

  @override
  String get aiActStop => 'पढ़ना रोकें';

  @override
  String get aiActLike => 'अच्छा जवाब';

  @override
  String get aiActDislike => 'खराब जवाब';

  @override
  String get aiActShare => 'शेयर करें';

  @override
  String get aiActRegenerate => 'फिर से बनाएँ';

  @override
  String get aiFeedbackThanks => 'आपकी प्रतिक्रिया के लिए धन्यवाद';

  @override
  String get intelOnlineHeader => 'अनुवाद और ट्रांसक्रिप्शन';

  @override
  String get intelOnlineTitle => 'कनेक्ट होने पर ऑनलाइन';

  @override
  String get intelOnlineSubtitle => 'मुफ़्त — MyMemory, Apple या Google';

  @override
  String get intelOnlineFooter => 'बंद होने पर कुछ भी इंटरनेट से नहीं जाता। चालू और कनेक्ट होने पर: अनुवाद का टेक्स्ट MyMemory को जाता है; iPhone पर, जिस वॉइस संदेश को डिवाइस खुद ट्रांसक्राइब नहीं कर सकता, वह Apple की स्पीच सेवा को जाता है। उस रास्ते पर सामग्री एंड-टू-एंड एन्क्रिप्टेड नहीं रहती। Android पर सिर्फ़ वॉइस मॉडल डाउनलोड होता है: वॉइस संदेश फ़ोन पर ही रहते हैं। लिंक पूर्वावलोकन के लिए संबंधित साइट से भी संपर्क किया जाता है।';

  @override
  String get trOnline => 'ऑनलाइन अनुवाद करें';

  @override
  String get trOnlineNote => 'टेक्स्ट MyMemory नामक मुफ़्त सेवा को भेजा जाएगा। उस रास्ते पर यह एंड-टू-एंड एन्क्रिप्टेड नहीं रहेगा।';

  @override
  String get trViaOnline => 'MyMemory द्वारा ऑनलाइन अनुवादित';

  @override
  String get vnModelDownloading => 'इस भाषा का वॉइस मॉडल डाउनलोड हो रहा है। थोड़ी देर में फिर कोशिश करें।';

  @override
  String get vnModelNeeded => 'इस भाषा का वॉइस मॉडल मौजूद नहीं है। इसे एक बार डाउनलोड करने के लिए सेटिंग्स में “कनेक्ट होने पर ऑनलाइन” चालू करें।';

  @override
  String get nwStatusHeader => 'स्टेटस';

  @override
  String get nwAddStatus => 'स्टेटस जोड़ें';

  @override
  String get nwStatusNewA11y => 'नया';

  @override
  String svReplySent(String name) {
    return '$name को जवाब भेजा गया';
  }

  @override
  String get blkYouBlocked => 'आपने इस संपर्क को ब्लॉक किया है।';

  @override
  String get blkUnblock => 'अनब्लॉक करें';

  @override
  String get blkListTitle => 'ब्लॉक किए गए संपर्क';

  @override
  String get blkNone => 'कोई ब्लॉक किया गया संपर्क नहीं';

  @override
  String get blkFooter => 'ब्लॉक किया गया संपर्क अब आपको संदेश या कॉल नहीं कर सकता, और आपके स्टेटस या फ़ोटो नहीं पाता। उसे इसकी सूचना नहीं दी जाती। आपका फ़ोन दूसरों के लिए उसके संदेश आगे भेजता रहता है, बिना उन्हें पढ़ सके: मेश नेटवर्क इस पर निर्भर नहीं करता कि आप किसे ब्लॉक करते हैं।';

  @override
  String blkUnblockTitle(String name) {
    return '$name को अनब्लॉक करें?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'कॉल करने के लिए $name को अनब्लॉक करें?';
  }

  @override
  String get nvDone => 'हो गया';

  @override
  String get nvBack => 'पीछे';

  @override
  String get nvForward => 'आगे';

  @override
  String get nvShare => 'शेयर करें';

  @override
  String get nvOpenInBrowser => 'ब्राउज़र में खोलें';

  @override
  String get nvReload => 'फिर से लोड करें';

  @override
  String get nvCopyLink => 'लिंक कॉपी करें';

  @override
  String get nvLinkCopied => 'लिंक कॉपी हो गया';

  @override
  String get nvOpen => 'खोलें';

  @override
  String get nvMore => 'और';

  @override
  String get nvNotSecure => 'असुरक्षित';

  @override
  String get nvErrorTitle => 'पेज उपलब्ध नहीं है';

  @override
  String get nvErrorBody => 'Droplet इस साइट तक नहीं पहुँच सका। मेश नेटवर्क वेब नहीं ले जाता: इसके लिए इंटरनेट कनेक्शन चाहिए।';

  @override
  String get nvRetry => 'फिर से कोशिश करें';

  @override
  String get ciLinks => 'लिंक';

  @override
  String get chatsFilterNearby => 'आस-पास';


  @override
  String get chProxTitle => 'Droplet बिना इंटरनेट के भी चलता है';

  @override
  String get chProxActive => 'Droplet वाले डिवाइस पास में हैं';

  @override
  String get chProxBody => 'पास के फ़ोन संदेश आगे बढ़ाते हैं। आसपास जितने ज़्यादा लोग, संदेश उतनी दूर जाते हैं।';

  @override
  String get chProxSee => 'आसपास देखें';

  @override
  String get chStickerPreview => 'स्टिकर';

  @override
  String get edCrop => 'क्रॉप';

  @override
  String get edRotate => 'घुमाएँ';

  @override
  String get edFilters => 'फ़िल्टर';

  @override
  String get edAdjust => 'समायोजित करें';

  @override
  String get edText => 'टेक्स्ट';

  @override
  String get edDraw => 'ड्रॉ';

  @override
  String get edTrim => 'ट्रिम';

  @override
  String get edBrightness => 'चमक';

  @override
  String get edContrast => 'कंट्रास्ट';

  @override
  String get edSaturation => 'संतृप्ति';

  @override
  String get edWarmth => 'गर्माहट';

  @override
  String get edVignette => 'विनेट';

  @override
  String get edIntensity => 'तीव्रता';

  @override
  String get edUndo => 'पूर्ववत करें';

  @override
  String get edDone => 'हो गया';

  @override
  String get edTextHint => 'कुछ लिखें…';

  @override
  String get edDelete => 'हटाएँ';

  @override
  String get edOriginal => 'मूल';

  @override
  String get edStyle => 'शैली';

  @override
  String get edBackground => 'पृष्ठभूमि';

  @override
  String get stNotificationsHeader => 'सूचनाएँ';

  @override
  String get stNotifPreview => 'सामग्री की झलक';

  @override
  String get stNotifPreviewSubtitle => 'संदेश का टेक्स्ट सूचना में दिखता है। बंद करने पर लॉक स्क्रीन सिर्फ़ नया संदेश आने की सूचना देती है।';

  @override
  String get stSearchHint => 'सेटिंग्स खोजें';

  @override
  String get stSearchEmpty => 'कोई सेटिंग नहीं मिली';

  @override
  String get chMentionAllSubtitle => 'सभी को सूचित करें';

  @override
  String get vuOnce => 'एक बार देखें';

  @override
  String get vuOpened => 'खोली जा चुकी';

  @override
  String get vuPhoto => 'फ़ोटो';

  @override
  String get vuVideo => 'वीडियो';

  @override
  String get vuMissing => 'यह मीडिया अभी तक नहीं आया है';

  @override
  String get pollClosed => 'पोल समाप्त';

  @override
  String pollEndsAt(String quand) {
    return '$quand पर समाप्त';
  }

  @override
  String get vuVoice => 'वॉइस मैसेज';

  @override
  String get apPatternsHeader => 'बैकग्राउंड पैटर्न';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'गेम्स';

  @override
  String get apPatternHome => 'घर';

  @override
  String get apPatternGarden => 'बगीचा';

  @override
  String get imTitle => 'तारांकित संदेश';

  @override
  String get imSubtitle => 'जो आपने अलग रखा';

  @override
  String get imAdd => 'तारांकित करें';

  @override
  String get imRemove => 'तारा हटाएँ';

  @override
  String get imAdded => 'तारांकित में जोड़ा गया';

  @override
  String get imRemoved => 'तारांकित से हटाया';

  @override
  String get imEmptyBody => 'किसी संदेश को तारांकित करने के लिए उसे देर तक दबाएँ, बाद में वह यहाँ मिलेगा।';

  @override
  String get imClearAll => 'सब हटाएँ';

  @override
  String get imClearAllBody => 'संदेश अपनी चैट में बने रहेंगे, केवल तारे हटेंगे।';

  @override
  String get imClear => 'हटाएँ';

  @override
  String get imYou => 'आप';

  @override
  String get imUnknown => 'संदेश';

  @override
  String get apPatternsFooter => 'यह पैटर्न आपकी सभी चैट के पीछे दिखेगा।';

  @override
  String get grCreatedNoMessages => 'ग्रुप बना · कोई संदेश नहीं';

  @override
  String get chatsDelete => 'चैट हटाएँ';

  @override
  String get chatsDeleteBody => 'संदेश इस फ़ोन से हट जाएँगे। सर्वर के बिना कोई उन्हें दूसरों के फ़ोन से नहीं हटा सकता।';

  @override
  String get chatsDeleteConfirm => 'हटाएँ';

  @override
  String get chatsDeleted => 'चैट हटाई गई';

  @override
  String chatsDeleteTitle(String nom) {
    return '$nom के साथ चैट हटाएँ?';
  }

  @override
  String get chatsDocument => 'दस्तावेज़';

  @override
  String get epTitle => 'ग़ायब होने वाले संदेश';

  @override
  String get epHeadline => 'इस चैट में ग़ायब होने वाले संदेश चालू करें';

  @override
  String get epBody => 'नए संदेश अपनी समय-सीमा साथ लेकर जाएँगे: चुनी गई अवधि के बाद वे दोनों फ़ोन से ग़ायब हो जाएँगे।';

  @override
  String get epDelayHeader => 'ग़ायब होने से पहले का समय';

  @override
  String get epHours24 => '24 घंटे';

  @override
  String get epDays7 => '7 दिन';

  @override
  String get epDays90 => '90 दिन';

  @override
  String get epOff => 'बंद';

  @override
  String get epFooter => 'यह सेटिंग पहले भेजे गए संदेशों को नहीं बदलती: हर संदेश अपनी मूल अवधि रखता है।';

  @override
  String get chOnlineNow => 'ऑनलाइन · इंटरनेट';

  @override
  String chInternetMinutesAgo(int count) {
    return 'इंटरनेट से $count मिनट पहले';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'इंटरनेट से $count घंटे पहले';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'इंटरनेट से $count दिन पहले';
  }

  @override
  String get pdfMissing => 'यह दस्तावेज़ इस फ़ोन पर नहीं है।';

  @override
  String get pdfUnreadable => 'यह PDF पढ़ा नहीं जा सका — शायद यह अधूरा आया है।';

  @override
  String get giDescription => 'विवरण';

  @override
  String get giDescriptionAdd => 'विवरण जोड़ें';

  @override
  String get giDescriptionNone => 'कोई विवरण नहीं';

  @override
  String get giDescriptionHint => 'यह ग्रुप किस बारे में है?';

  @override
  String get giOnlyAdminsSend => 'केवल एडमिन भेज सकते हैं';

  @override
  String get giOnlyAdminsSendBody => 'अन्य सदस्य केवल पढ़ सकते हैं।';

  @override
  String get giSearchMembers => 'सदस्य खोजें';

  @override
  String get chOnlyAdminsCanWrite => 'इस ग्रुप में केवल एडमिन लिख सकते हैं';

  @override
  String grCreatedBy(String nom) {
    return '$nom ने ग्रुप बनाया';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom ने आपको जोड़ा';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom अब ग्रुप में नहीं है';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui ने $nom को जोड़ा';
  }

  @override
  String get giQrInvite => 'QR कोड';

  @override
  String get giQrRenew => 'नया कोड';

  @override
  String get giQrRenewed => 'नया कोड बना, पुराना अब काम नहीं करेगा';

  @override
  String get giQrExpired => 'यह कोड समाप्त हो चुका है';

  @override
  String get giQrExplainer => 'इस कोड में कोई कुंजी नहीं है। यह सिर्फ़ शामिल होने का अनुरोध भेजता है — निर्णय आपका फ़ोन करता है।';

  @override
  String get giQrAlreadyMember => 'आप पहले से इस ग्रुप में हैं';

  @override
  String get giQrNeedContact => 'पहले आमंत्रित करने वाले को जोड़ें';

  @override
  String get giQrRequestFailed => 'अनुरोध भेजा नहीं जा सका';

  @override
  String giQrRequestSent(String nom) {
    return '$nom को अनुरोध भेजा गया';
  }

  @override
  String giQrValidHours(int count) {
    return '$count घंटे और मान्य';
  }

  @override
  String giQrValidMinutes(int count) {
    return '$count मिनट और मान्य';
  }

  @override
  String get cvNearby => 'पास में';

  @override
  String get cvInternet => 'इंटरनेट';

  @override
  String get cvWaiting => 'प्रतीक्षा';

  @override
  String get cvOutOfReach => 'पहुँच से बाहर';

  @override
  String get chWillSendWhenNearby => 'जैसे ही वे पहुँच में आएँगे, भेज दिया जाएगा';

  @override
  String cvHops(int count) {
    return '$count हॉप';
  }

  @override
  String get nwSeenSection => 'देखे गए';

  @override
  String get nwReceivedHeader => 'प्राप्त';

  @override
  String get avTranslateTitle => 'अनुवाद';

  @override
  String get avTranslateShort => 'ऐप छोड़े बिना समझें';

  @override
  String get avTranslateLong => 'संदेश आपके फ़ोन पर ही अनुवादित होता है: उसकी सामग्री किसी तक नहीं जाती, अनुवाद सेवा तक भी नहीं। मूल पाठ एक टैप दूर रहता है, क्योंकि अनुवाद कभी भी बिल्कुल वही पाठ नहीं होता।';

  @override
  String get apStickerQ => 'इसके लिए कोई स्टिकर है?';

  @override
  String get apOnline => 'ऑनलाइन';

  @override
  String get apMessage => 'संदेश';

  @override
  String get apAutoTranslated => 'स्वतः अनुवादित';

  @override
  String get apBgSend => 'यह बैकग्राउंड देखो 😍';

  @override
  String get apBgA => 'तुमने कुछ बदला क्या?';

  @override
  String get apBgB => 'हर संदेश पर हिलता है 😮';

  @override
  String get apFormatQ => 'कहाँ मिलें?';

  @override
  String get apFormatDemo => '**शाम 6 बजे** __बड़े बाज़ार__ के सामने मिलते हैं, कोड `4821`। सरप्राइज़: ||एक केक||';

  @override
  String get apVoiceQ => 'तुम कहाँ हो?';

  @override
  String get apVoiceText => 'मैं फ़ार्मेसी के सामने हूँ, शाम 6 बजे तक इंतज़ार करूँगा।';

  @override
  String get apTransQ => 'हे, सब तैयार है?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'हाँ! कल एयरपोर्ट पर मिलते हैं, गेट 12, सुबह 9 बजे।';

  @override
  String get hlpDataOnDevice => 'आपके फ़ोन पर';

  @override
  String get hlpDataServers => 'जो सर्वर से होकर जाता है';

  @override
  String get hlpDataServersFooter => 'इंटरनेट के बिना इनमें से कोई सर्वर शामिल नहीं होता: फ़ोन सीधे बात करते हैं।';

  @override
  String get hlpDataNone => 'Droplet कभी क्या नहीं माँगता';

  @override
  String get hlpRowKeys => 'आपकी पहचान';

  @override
  String get hlpRowKeysBody => 'यहीं बनी कुंजी-जोड़ी, कहीं नहीं भेजी जाती';

  @override
  String get hlpRowMessages => 'आपके संदेश';

  @override
  String get hlpRowMessagesBody => 'ऐप के निजी हिस्से में, अनइंस्टॉल पर मिट जाते हैं';

  @override
  String get hlpRowProfile => 'नाम और फ़ोटो';

  @override
  String get hlpRowProfileBody => 'सिर्फ़ उन्हीं तक जाते हैं जिन्हें आप लिखते हैं';

  @override
  String get hlpRowSettings => 'आपकी सेटिंग्स';

  @override
  String get hlpRowSettingsBody => 'बैकग्राउंड, भाषा, सूचनाएँ — सब यहीं रहता है';

  @override
  String get hlpRowLog => 'त्रुटि लॉग';

  @override
  String get hlpRowLogBody => 'एक स्थानीय फ़ाइल, जो अपने आप कभी नहीं जाती';

  @override
  String get hlpRowDirectory => 'डायरेक्टरी';

  @override
  String get hlpRowDirectoryBody => 'एक नाम और सार्वजनिक पहचानकर्ता देखती है। अनुरोध Tor से: आपका असली IP नहीं';

  @override
  String get hlpRowMailbox => 'मेलबॉक्स';

  @override
  String get hlpRowMailboxBody => 'डिलीवरी तक एन्क्रिप्टेड संदेश रखता है। पढ़ नहीं सकता';

  @override
  String get hlpRowSignalling => 'कॉल जोड़ना';

  @override
  String get hlpRowSignallingBody => 'जोड़ते समय दो पहचानकर्ता देखता है। कोई आवाज़ इससे नहीं गुज़रती';

  @override
  String get hlpRowRelay => 'रिले';

  @override
  String get hlpRowRelayBody => 'सीधा संपर्क विफल हो तो एन्क्रिप्टेड ऑडियो आगे भेजता है';

  @override
  String get hlpNonePhone => 'फ़ोन नंबर';

  @override
  String get hlpNoneEmail => 'ईमेल पता';

  @override
  String get hlpNoneContacts => 'आपकी संपर्क सूची';

  @override
  String get hlpNoneLocation => 'आपका स्थान';

  @override
  String get hlpNoneAds => 'विज्ञापन और ट्रैकर';

  @override
  String get hlpNoneAnalytics => 'उपयोग मापन';

  @override
  String get hlpQOffline => 'Droplet बिना इंटरनेट कैसे काम करता है?';

  @override
  String get hlpAOffline => 'फ़ोन आपस में सीधे बात करते हैं — ब्लूटूथ और वाई-फ़ाई से। संदेश एक फ़ोन से दूसरे फ़ोन होते हुए भी पहुँच सकता है, बिना किसी सर्वर से गुज़रे।';

  @override
  String get hlpQCrypto => 'क्या मेरे संदेश सचमुच एन्क्रिप्टेड हैं?';

  @override
  String get hlpACrypto => 'हाँ, एंड-टू-एंड, Signal प्रोटोकॉल से। कुंजी सिर्फ़ दोनों फ़ोन पर है। न रिले, न मेलबॉक्स, न हम कोई संदेश खोल सकते हैं।';

  @override
  String get hlpQNoAccount => 'Droplet नंबर या ईमेल क्यों नहीं माँगता?';

  @override
  String get hlpANoAccount => 'क्योंकि ज़रूरत ही नहीं। आपकी पहचान आपके फ़ोन पर बनी एक कुंजी है। कुछ बनाना नहीं, कुछ सत्यापित करना नहीं, और कहीं चोरी होने को कुछ नहीं।';

  @override
  String get hlpQPending => 'मेरा संदेश लंबित क्यों है?';

  @override
  String get hlpAPending => 'अभी कोई पास नहीं है और इंटरनेट भी नहीं। संदेश फ़ोन में इंतज़ार करता है और रास्ता खुलते ही चला जाता है — दोबारा कुछ नहीं करना।';

  @override
  String get hlpQAddSomeone => 'किसी को कैसे जोड़ें?';

  @override
  String get hlpAAddSomeone => 'फ़ोन पास लाइए: व्यक्ति अपने आप दिखता है। दूर से, अपना निमंत्रण लिंक साझा कीजिए या उनका QR कोड स्कैन कीजिए।';

  @override
  String get hlpQUninstall => 'ऐप अनइंस्टॉल करने पर क्या होता है?';

  @override
  String get hlpAUninstall => 'सब मिट जाता है: संदेश, संपर्क, पहचान। कहीं कोई कॉपी नहीं, इसलिए पुनर्स्थापना भी नहीं। फ़ोन बदल रहे हों तो पहले सेटिंग्स निर्यात कर लें।';

  @override
  String get hlpQBattery => 'क्या Droplet बैटरी खाता है?';

  @override
  String get hlpABattery => 'आसपास के उपकरण खोजने में बिजली लगती है। सेटिंग्स में इसे घटा सकते हैं या सिर्फ़ ऐप खुली होने पर चालू रख सकते हैं।';

  @override
  String get hlpQReport => 'समस्या की सूचना कैसे दें?';

  @override
  String get hlpAReport => 'संपर्क और सहायता से। भेजे जाने वाला सटीक पाठ जाने से पहले दिखेगा — आपके बिना कुछ भी फ़ोन से बाहर नहीं जाता।';

  @override
  String get svLikeStatus => 'स्टेटस पसंद करें';

  @override
  String get svUnlikeStatus => 'पसंद हटाएँ';

  @override
  String get stAddPhotoSemantics => 'प्रोफ़ाइल फ़ोटो जोड़ें';

  @override
  String get stChangePhotoSemantics => 'प्रोफ़ाइल फ़ोटो बदलें';

  @override
  String get scOverheat => 'फ़ोन गरम हो गया — Android ने वीडियो एन्कोडर बंद कर दिया। कुछ मिनट ठंडा होने दें।';

  @override
  String scTooHeavy(int mo) {
    return 'फ़ाइल बहुत भारी — स्थानीय नेटवर्क पार करने के लिए अधिकतम $mo MB।';
  }

  @override
  String get scUnsupported => 'स्टेटस के लिए यह प्रारूप समर्थित नहीं है।';

  @override
  String get scUnreadableFile => 'यह फ़ाइल पढ़ी नहीं जा सकी';

  @override
  String get scUnreadableTrack => 'यह ट्रैक पढ़ा नहीं जा सका';

  @override
  String get scNothingCaptured => 'रिकॉर्डिंग में कुछ नहीं आया — फिर से कोशिश करें।';

  @override
  String get scVideoTrimmed => 'वीडियो 1 मिनट 30 सेकंड तक छोटा किया गया — केवल शुरुआत प्रकाशित होगी।';

  @override
  String get scUnreadableVideo => 'वीडियो पढ़ा नहीं जा सका';

  @override
  String get chAiMe => 'मैं';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'यह Droplet में उपयोगकर्ता («मैं») और $pseudo के बीच बातचीत का अंत है:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'उपयोगकर्ता को $pseudo को उत्तर देने में मदद चाहिए। $langue में एक छोटा, स्वाभाविक उत्तर सुझाइए, प्रथम पुरुष में, मानो वे स्वयं भेज रहे हों। केवल सुझाया गया उत्तर दीजिए, कोई भूमिका नहीं।';
  }

  @override
  String get hlpSectionHeader => 'सहायता और गोपनीयता';

  @override
  String get hlpPrivacy => 'गोपनीयता नीति';

  @override
  String get hlpData => 'आपका डेटा';

  @override
  String get hlpDataValue => 'कुछ भी बाहर नहीं जाता';

  @override
  String get hlpContact => 'संपर्क और सहायता';

  @override
  String get hlpPrivacyTitle => 'गोपनीयता';

  @override
  String hlpUpdated(String date) {
    return '$date को अपडेट किया गया';
  }

  @override
  String get hlpOnlyFrEn => 'यह पाठ केवल फ़्रेंच और अंग्रेज़ी में है। कानूनी दस्तावेज़ का अनुमानित अनुवाद मदद से ज़्यादा बाध्य करता है।';

  @override
  String get hlpReadInEnglish => 'अंग्रेज़ी में पढ़ें';

  @override
  String get hlpReadInFrench => 'फ़्रेंच में पढ़ें';

  @override
  String get hlpDataTitle => 'आपका डेटा';

  @override
  String get hlpDataLead => 'Droplet आपके बारे में क्या जानता है, पंक्ति दर पंक्ति। यहाँ कुछ भी वादा नहीं है: हर पंक्ति के पीछे कोड है।';

  @override
  String get hlpStays => 'कभी डिवाइस नहीं छोड़ता';

  @override
  String get hlpLeaves => 'सर्वर से होकर जाता है';

  @override
  String get hlpNever => 'मौजूद ही नहीं';

  @override
  String get hlpCountTracking => 'ट्रैक करने वाला डेटा';

  @override
  String get hlpCountAccount => 'खाता बनाना है';

  @override
  String get hlpCountServers => 'सर्वर, और हम नाम बताते हैं';

  @override
  String get hlpHelpTitle => 'सहायता';

  @override
  String get hlpSearchHint => 'खोजें';

  @override
  String get hlpNoResult => 'किसी उत्तर में यह शब्द नहीं है। हमें लिखें — शायद यह सवाल यहाँ छूट गया है।';

  @override
  String get hlpStillStuckFooter => 'अगर उत्तर यहाँ नहीं है, तो एक इंसान जवाब देता है।';

  @override
  String get hlpContactTitle => 'संपर्क';

  @override
  String get hlpContactLead => 'कोई सवाल, कोई समस्या, कोई विचार। हम सब पढ़ते हैं।';

  @override
  String get hlpBeforeWriting => 'लिखने से पहले';

  @override
  String get hlpHelpRowBody => 'आठ उत्तर, बिना इंटरनेट पढ़ें';

  @override
  String get hlpWriteUs => 'हमें लिखें';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'ईमेल';

  @override
  String get hlpWhatsAppHello => 'नमस्ते, मैं Droplet इस्तेमाल करता हूँ और मेरा एक सवाल है:';

  @override
  String get hlpEmailSubject => 'Droplet — सवाल';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp इंस्टॉल नहीं है। नंबर $numero कॉपी कर लिया गया।';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'पता $adresse कॉपी कर लिया गया।';
  }

  @override
  String get hlpReportHeader => 'कोई समस्या';

  @override
  String get hlpReport => 'समस्या की सूचना दें';

  @override
  String get hlpReportBody => 'जो जाएगा, वह जाने से पहले दिखेगा';

  @override
  String get hlpReportFooter => 'Droplet अपने आप कोई रिपोर्ट नहीं भेजता: इसके लिए कोई सर्वर ही नहीं है। समस्या हम तक तभी पहुँचती है जब आप भेजें।';

  @override
  String get hlpReportSubject => 'Droplet — रिपोर्ट';

  @override
  String get hlpReportSheetLead => 'बताइए क्या हुआ। जो सटीक पाठ भेजा जाएगा वह नीचे दिखता है।';

  @override
  String get hlpReportHint => 'मैं क्या कर रहा था और क्या हुआ…';

  @override
  String get hlpAttachLog => 'त्रुटि लॉग संलग्न करें';

  @override
  String get hlpWhatWillBeSent => 'क्या भेजा जाएगा';

  @override
  String get hlpLogExcerpt => 'लॉग (अंत):';

  @override
  String get hlpCopy => 'कॉपी करें';

  @override
  String get hlpCopied => 'कॉपी हो गया';

  @override
  String get hlpOnePerson => 'Droplet एक व्यक्ति बनाता है, कोई सहायता टीम नहीं। उत्तर में एक-दो दिन लग सकते हैं — पर आता है।';

  @override
  String get avSectionHeader => 'Pro क्या देता है';

  @override
  String get avUnlock => 'Droplet Pro अनलॉक करें';

  @override
  String get avVoiceTitle => 'आवाज़ से टेक्स्ट';

  @override
  String get avVoiceShort => 'बिना सुने वॉइस नोट पढ़ें';

  @override
  String get avVoiceLong => 'ट्रांसक्रिप्शन आपके फ़ोन पर, ऑफ़लाइन होता है। वॉइस नोट कहीं नहीं जाता, और आप उसे मीटिंग में, बस में या बिना नेटवर्क पढ़ सकते हैं।';

  @override
  String get avFormatTitle => 'टेक्स्ट स्टाइल';

  @override
  String get avFormatShort => 'बोल्ड, इटैलिक, कोड, स्पॉइलर';

  @override
  String get avFormatLong => 'एक शब्द बोल्ड, कोड की एक लाइन, छुआ जाने पर खुलने वाला छिपा हिस्सा — आपका संदेश ठीक वही कहता है जो आप चाहते थे।';

  @override
  String get avWallpaperTitle => 'वॉलपेपर और पैटर्न';

  @override
  String get avWallpaperShort => 'पूरी गैलरी और चारों पैक';

  @override
  String get avWallpaperLong => 'हर वॉलपेपर हाथ से बना है, हर पैटर्न ऐप में आने से पहले जाँचा गया। Droplet, गेम्स, घर, बगीचा — आपकी चैट किसी और जैसी नहीं दिखती।';

  @override
  String get avStickersTitle => 'एनिमेटेड स्टिकर';

  @override
  String get avStickersShort => 'चलती हुई Droplet बूँद';

  @override
  String get avStickersLong => 'Droplet के लिए बने स्टिकर, फ़्रेम-दर-फ़्रेम एनिमेटेड और इतने हल्के कि बिना इंटरनेट मेश पर भी पहुँच जाते हैं।';

  @override
  String get avIconTitle => 'ऐप आइकॉन';

  @override
  String get avIconShort => 'होम स्क्रीन पर आइकॉन बदलें';

  @override
  String get avIconLong => 'एक विनीत मैसेंजर की शुरुआत उसके आइकॉन से होती है। वह चुनें जो आप जैसा हो — या जो किसी की नज़र में न आए।';

  @override
  String get avBadgeTitle => 'Pro बैज';

  @override
  String get avBadgeShort => 'यह आपके नाम के साथ रहता है';

  @override
  String get avBadgeLong => 'यह किसी पर कोई अधिकार नहीं देता। यह बस कहता है कि आपने भुगतान किया ताकि Droplet बिना विज्ञापन, बिना अनिवार्य सदस्यता और बिना डेटा बिक्री के रहे।';

  @override
  String get sgTitle => 'ग्रुप स्टोरेज';

  @override
  String get sgEmpty => 'इस ग्रुप में अभी तक कोई फ़ाइल साझा नहीं हुई।';

  @override
  String get sgByAuthor => 'सबसे ज़्यादा कौन भेजता है';

  @override
  String get sgFiles => 'फ़ाइलें';

  @override
  String get sgSortRecent => 'सबसे नए';

  @override
  String get sgSortHeavy => 'सबसे बड़े';

  @override
  String get sgNotOnDevice => 'यहाँ नहीं';

  @override
  String get giPhotoChanged => 'ग्रुप फ़ोटो बदली गई';

  @override
  String get giPhotoFailed => 'यह छवि सहेजी नहीं जा सकी';

  @override
  String sgTotal(int count) {
    return '$count साझा फ़ाइलें';
  }

  @override
  String get vrTitle => 'वॉइस चैट';

  @override
  String get vrJoin => 'शामिल हों';

  @override
  String get vrBack => 'वापस';

  @override
  String get vrStart => 'वॉइस चैट शुरू करें';

  @override
  String get vrNeedsInternet => 'वॉइस चैट के लिए इंटरनेट चाहिए: मेश एक प्रतीक्षारत संदेश ले जा सकता है, बीस आवाज़ें एक साथ नहीं।';

  @override
  String get vrUnreachable => 'कॉल सर्वर अभी उपलब्ध नहीं है।';

  @override
  String vrFull(int count) {
    return 'कमरा भरा है: अधिकतम $count लोग।';
  }

  @override
  String get vrWaiting => 'दूसरों की प्रतीक्षा…';

  @override
  String get vrWaitingBody => 'कमरा खुला है। समूह के सदस्य इसे चैट में देखते हैं और खाली होने पर शामिल होते हैं।';

  @override
  String vrPeople(int count) {
    return '$count लोग अंदर';
  }

  @override
  String get cvTitle => 'बातचीत';

  @override
  String get cvNew => 'नई बातचीत';

  @override
  String get cvPinned => 'पिन किए गए';

  @override
  String get cvRecent => 'हाल ही में';

  @override
  String get cvPin => 'पिन करें';

  @override
  String get cvUnpin => 'पिन हटाएं';

  @override
  String get cvRename => 'नाम बदलें';

  @override
  String get cvRenameHint => 'बातचीत का शीर्षक';

  @override
  String get cvUntitled => 'शीर्षकहीन';

  @override
  String get cvYesterday => 'कल';

  @override
  String get cvSearchHint => 'बातचीत में खोजें';

  @override
  String get cvEmpty => 'अभी कोई बातचीत नहीं। सहायक से अपना पहला सवाल पूछें।';

  @override
  String get cvDeleteTitle => 'यह बातचीत हटाएं?';

  @override
  String get cvDeleteBody => 'इसे वापस नहीं लाया जा सकता — यह केवल इसी डिवाइस पर है।';

  @override
  String get jaWorking => 'काम चल रहा है…';

  @override
  String cvNoResult(String terme) {
    return '«$terme» के लिए कुछ नहीं मिला।';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'कोई परिणाम नहीं',
      one: '1 परिणाम',
      other: '$count परिणाम',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'कोई चरण नहीं',
      one: '1 चरण',
      other: '$count चरण',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'आपका संदेश कहाँ जाता है';

  @override
  String get moLocal => 'डिवाइस पर';

  @override
  String get moLocalBody => 'मॉडल इसी फ़ोन पर चलता है। कुछ भी बाहर नहीं जाता, बिना नेटवर्क के भी। जवाब छोटे और कम भरोसेमंद होते हैं।';

  @override
  String get moOnline => 'ऑनलाइन';

  @override
  String get moOnlineBody => 'आपका संदेश Groq को जाता है, जो कहीं बड़ा मॉडल चलाता है। इसके लिए नेटवर्क चाहिए, और संदेश फ़ोन से बाहर जाता है।';

  @override
  String get moOnlineNoKey => 'दूरस्थ मॉडल से बात करने के लिए एक कुंजी चाहिए। जोड़ने के लिए टैप करें — यह मुफ़्त है और एक मिनट लगता है।';

  @override
  String get moRetryOnline => 'ऑनलाइन दोबारा करें';

  @override
  String get moRetryOnlineWhy => 'इस सवाल पर डिवाइस का मॉडल अपनी सीमा तक पहुँच गया।';

  @override
  String get cpHint => 'कुछ भी पूछें…';

  @override
  String get cpAdd => 'जोड़ें';

  @override
  String get cpPhoto => 'फ़ोटो';

  @override
  String get cpCamera => 'कैमरा';

  @override
  String get cpFile => 'फ़ाइल';

  @override
  String get cpFileHint => 'PDF, टेक्स्ट, कोड';

  @override
  String get cpDictate => 'बोलकर लिखें';

  @override
  String get cpSend => 'भेजें';

  @override
  String get cpStop => 'रोकें';

  @override
  String get cpThinking => 'सोच रहा है…';

  @override
  String get amCopy => 'कॉपी करें';

  @override
  String get amCopyMarkdown => 'Markdown में कॉपी करें';

  @override
  String get amCopyMarkdownHint => 'फ़ॉर्मैटिंग के साथ, दस्तावेज़ के लिए';

  @override
  String get amShare => 'साझा करें';

  @override
  String get amEdit => 'मेरा सवाल बदलें';

  @override
  String get amEditHint => 'इसके बाद का सब कुछ हट जाएगा';

  @override
  String get amEditTitle => 'यह सवाल बदलें?';

  @override
  String get amEditConfirm => 'बदलें';

  @override
  String get amRegenerate => 'दोबारा बनाएं';

  @override
  String get amReadAloud => 'ज़ोर से पढ़ें';

  @override
  String get amAsContext => 'संदर्भ के रूप में लें';

  @override
  String get amAsContextHint => 'इसी संदेश से आगे बढ़ेगा';

  @override
  String get amChapter => 'अध्याय के रूप में चिह्नित करें';

  @override
  String get amChapterHint => 'लंबी बातचीत में दोबारा ढूँढने के लिए';

  @override
  String get amUnchapter => 'चिह्न हटाएं';

  @override
  String get amChapters => 'अध्याय';

  @override
  String get amChaptersEmpty => 'अभी कोई अध्याय नहीं। किसी संदेश को देर तक दबाकर “अध्याय के रूप में चिह्नित करें” चुनें, वह यहाँ दिखेगा।';

  @override
  String amEditBody(int count) {
    return 'बाद के $count संदेश हट जाएंगे — वे पुराने सवाल का जवाब थे।';
  }

  @override
  String get trAssistant => 'सहायक';

  @override
  String get trArtifacts => 'आर्टिफ़ैक्ट';

  @override
  String get trMemory => 'स्मृति';

  @override
  String get trHelp => 'सहायता';

  @override
  String get arVersions => 'संस्करण';

  @override
  String get arLatest => 'नवीनतम';

  @override
  String get arSource => 'स्रोत';

  @override
  String get arPreview => 'पूर्वावलोकन';

  @override
  String get arGone => 'यह आर्टिफ़ैक्ट अब मौजूद नहीं है।';

  @override
  String get arKindPage => 'पेज';

  @override
  String get arKindCode => 'कोड';

  @override
  String get arKindDiagram => 'आरेख';

  @override
  String get arKindData => 'डेटा';

  @override
  String get arKindDoc => 'दस्तावेज़';

  @override
  String arVersion(int n) {
    return 'संस्करण $n';
  }

  @override
  String get aiSources => 'स्रोत';

  @override
  String get aiToolReading => 'अटैचमेंट पढ़ा जा रहा है…';

  @override
  String get aiToolWriting => 'फ़ाइल बनाई जा रही है…';

  @override
  String get aiToolRemembering => 'याद रखा जा रहा है…';

  @override
  String get arEmpty => 'अभी कोई आर्टिफ़ैक्ट नहीं। जैसे ही सहायक कोई पेज, टेबल या इतना लंबा कोड बनाता है कि बातचीत भर जाए, वह एक बना देता है।';

  @override
  String get raTitle => 'ऑनलाइन सहायक';

  @override
  String get raIntro => 'डिवाइस का सहायक बिना किसी सेटअप के चलता है। ऑनलाइन मोड के लिए एक कुंजी चाहिए: वही जवाबों का ख़र्च उठाती है, और इसी फ़ोन पर रहती है।';

  @override
  String get raKey => 'कुंजी';

  @override
  String get raKeySaved => 'कुंजी सहेजी गई';

  @override
  String get raKeyFooter => 'यह सिस्टम कीचेन में रहती है और कभी पूरी नहीं दिखाई जाती।';

  @override
  String get raKeyRemove => 'कुंजी हटाएं';

  @override
  String get raWhere => 'कुंजी console.groq.com पर “API Keys” में बनती है। यह gsk_ से शुरू होती है।';

  @override
  String get raPaste => 'पेस्ट';

  @override
  String get raSaveAndTest => 'सहेजें और जाँचें';

  @override
  String get raTest => 'कुंजी जाँचें';

  @override
  String get raTesting => 'जाँच हो रही है…';

  @override
  String get raNotTested => 'अभी जाँची नहीं गई';

  @override
  String get raNotTestedBody => 'आठ शब्दों की एक कॉल ही काफ़ी है। सवाल के बीच में से बेहतर है यहीं कर लें।';

  @override
  String get raWorks => 'कुंजी काम करती है';

  @override
  String get raWorksBody => 'ऑनलाइन मोड अब बातचीत में उपलब्ध है — इनपुट फ़ील्ड के बगल वाली पिल पर।';

  @override
  String get raRefused => 'कुंजी अस्वीकृत';

  @override
  String get raRefusedBody => 'सर्वर इसे नहीं पहचानता। अक्सर पेस्ट करते समय कोई अक्षर छूट जाता है, या कुंजी रद्द कर दी गई है।';

  @override
  String get raNoNetwork => 'सर्वर तक नहीं पहुँचा';

  @override
  String get raNoNetworkBody => 'कुंजी की गलती नहीं: अनुरोध पहुँचा ही नहीं। कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get raModelGone => 'मॉडल उपलब्ध नहीं';

  @override
  String get raModelGoneBody => 'कुंजी स्वीकार हुई, पर कुछ लौटा नहीं। संभवतः मॉडल हटा दिया गया है।';

  @override
  String get raQuota => 'बहुत अधिक अनुरोध';

  @override
  String get raQuotaBody => 'कुंजी काम करती है, पर खाता अपनी सीमा तक पहुँच गया। बाद में कोशिश करें या क्रेडिट देखें।';

  @override
  String get raWhatGoesOut => 'क्या बाहर जाता है';

  @override
  String get raModel => 'मॉडल';

  @override
  String get raWhatGoesOutFooter => 'ऑनलाइन मोड में आपका संदेश और इसी बातचीत के पिछले संदेश Groq को जाते हैं। और कुछ नहीं: न आपके संपर्क, न दूसरी बातचीत, न आपकी लोकेशन।';

  @override
  String get aiDownloadTitle => 'डिवाइस वाला मॉडल डाउनलोड करें?';

  @override
  String get aiDownloadConfirm => 'डाउनलोड';

  @override
  String get aiDownloading => 'मॉडल डाउनलोड हो रहा है';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB डाउनलोड, सिर्फ़ एक बार। उसके बाद सहायक बिना नेटवर्क जवाब देता है, और कुछ भी फ़ोन से बाहर नहीं जाता। डाउनलोड के दौरान आप इसे ऑनलाइन इस्तेमाल करते रह सकते हैं।';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB डाउनलोड, एक ही बार। उसके बाद बिना नेटवर्क जवाब देता है और कुछ भी फ़ोन से बाहर नहीं जाता।';
  }

  @override
  String get aiGreetingPlain => 'नमस्ते';

  @override
  String get aiGreetingHint => 'सवाल पूछें, फ़ोटो जोड़ें, या दस्तावेज़ माँगें।';

  @override
  String get aiChipExplain => 'समझाओ…';

  @override
  String get aiChipWrite => 'संदेश लिखो';

  @override
  String get aiChipSummarize => 'इसका सार दो';

  @override
  String get aiChipTranslate => 'अनुवाद करो…';

  @override
  String aiGreeting(String nom) {
    return 'नमस्ते, $nom';
  }

  @override
  String get cpNoPhoto => 'फ़ोटो नहीं: ऑनलाइन मॉडल तस्वीर नहीं पढ़ सकता। PDF ज़रूर पढ़ता है, लंबे भी।';

  @override
  String get mvOpen => 'वॉइस मोड';

  @override
  String get mvTapToTalk => 'बोलने के लिए टैप करें';

  @override
  String get mvHoldToTalk => 'बोलने के लिए दबाकर रखें';

  @override
  String get mvListening => 'सुन रहा हूँ…';

  @override
  String get mvTranscribing => 'लिखा जा रहा है…';

  @override
  String get mvSpeaking => 'बोलकर उत्तर दिया जा रहा है';

  @override
  String get mvProblem => 'कोई समस्या हुई';

  @override
  String get mvHandsFree => 'हैंड्स-फ़्री';

  @override
  String get mvHold => 'दबाकर रखें';

  @override
  String get mvTalk => 'बोलें';

  @override
  String get mvInterrupt => 'रोकें';

  @override
  String get mvNoMic => 'Droplet को माइक्रोफ़ोन की अनुमति नहीं है. फ़ोन की सेटिंग में इसे अनुमति दें.';

  @override
  String get mvFailed => 'यह प्रयास पूरा नहीं हुआ. दोबारा कोशिश करने के लिए टैप करें.';

  @override
  String get mvLive => 'लाइव';

  @override
  String get mvCaptions => 'कैप्शन';

  @override
  String get mvExit => 'वॉइस मोड से बाहर निकलें';

  @override
  String get mvMute => 'माइक बंद करें';

  @override
  String get mvUnmute => 'माइक चालू करें';

  @override
  String get mvMuted => 'माइक बंद है';

  @override
  String get mvTapToInterrupt => 'रोकने के लिए टैप करें';

  @override
  String scCompressing(int percent) {
    return 'कंप्रेस हो रहा है… $percent%';
  }

  @override
  String get scStillHeavy => 'यह वीडियो अब भी 2 MB से बड़ा है: इसे भेजने में ज़्यादा समय लगेगा.';

  @override
  String get baConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get baMute => 'माइक बंद करें';

  @override
  String get baUnmute => 'माइक चालू करें';

  @override
  String get baHangUp => 'कॉल समाप्त करें';

  @override
  String baOngoing(String name) {
    return '$name के साथ कॉल चल रही है. वापस जाने के लिए टैप करें.';
  }

  @override
  String get ntfOngoingCall => 'कॉल चल रही है';

  @override
  String get ntfViaMesh => 'मेश नेटवर्क से';

  @override
  String get ntfViaInternet => 'इंटरनेट से';

  @override
  String get shSend => 'भेजें';

  @override
  String get shRecents => 'हाल के';

  @override
  String get shPickRecipients => 'एक या अधिक प्राप्तकर्ता चुनें';

  @override
  String shSendCount(int count) {
    return '$count को भेजें';
  }

  @override
  String shSelected(int count) {
    return '$count चुने गए';
  }

  @override
  String get apcNothingYet => 'अभी कुछ नहीं';

  @override
  String get apcOnline => 'ऑनलाइन';

  @override
  String get apcOffline => 'ऑफ़लाइन';

  @override
  String get apcPhoto => 'फ़ोटो';

  @override
  String get apcVoice => 'वॉइस मैसेज';

  @override
  String get apcAttachment => 'अटैचमेंट';

  @override
  String get chKeyboardTooltip => 'कीबोर्ड';

  @override
  String get asGallery => 'गैलरी';

  @override
  String get asFile => 'फ़ाइल';

  @override
  String get asLocation => 'लोकेशन';

  @override
  String get asSticker => 'स्टिकर';

  @override
  String get asPoll => 'पोल';

  @override
  String get asNoGalleryAccess => 'Droplet को आपकी फ़ोटो की अनुमति नहीं है. फ़ोन की सेटिंग में अनुमति दें, या नीचे कोई दूसरा स्रोत चुनें.';

  @override
  String asSendCount(int count) {
    return '$count भेजें';
  }

  @override
  String get asEmptyGallery => 'इस फ़ोन में कोई फ़ोटो या वीडियो नहीं है।';

  @override
  String get expAucunPairTitre => 'आस-पास कोई नहीं?';

  @override
  String get expAucunPairTexte => 'यह खराबी नहीं है। Droplet लगातार खोजता रहता है; जैसे ही कोई डिवाइस पास आएगा, संपर्क अपने आप बन जाएगा।';

  @override
  String get expRelaisTitre => 'किसी और से होकर';

  @override
  String get expRelaisTexte => 'यह आइकन बताता है कि संदेश पहुँचने से पहले एक या अधिक डिवाइस से गुज़रा। यही मेश की ताकत है।';

  @override
  String get expApercuTitre => 'एक झलक';

  @override
  String get expApercuTexte => 'किसी बातचीत को दबाए रखें और उसे खोले या पढ़ा हुआ चिह्नित किए बिना नवीनतम संदेश पढ़ें।';

  @override
  String get expOfficielTitre => 'Droplet खाता';

  @override
  String get expOfficielTexte => 'ऐप की नई जानकारी यहाँ आती है। हर घोषणा हस्ताक्षरित है: कोई नकली नहीं बना सकता।';

  @override
  String get expMicroTitre => 'दबाकर बोलें';

  @override
  String get expMicroTexte => 'रिकॉर्ड करने के लिए दबाए रखें। रद्द करने के लिए बाएँ खिसकाएँ, बिना पकड़े जारी रखने के लिए ऊपर।';

  @override
  String get expCameraTitre => 'माइक या कैमरा';

  @override
  String get expCameraTexte => 'इस बटन पर छोटा टैप वॉइस मैसेज और गोल वीडियो मैसेज के बीच बदलता है।';

  @override
  String get expVueUniqueTitre => 'सिर्फ़ एक बार';

  @override
  String get expVueUniqueTexte => '«1» चालू करें: अगली भेजी गई चीज़ केवल एक बार खुलेगी, फिर गायब हो जाएगी।';

  @override
  String get expPiecesTitre => 'एक साथ कई';

  @override
  String get expPiecesTexte => 'क्लिप ऐप के अंदर ही आपकी गैलरी खोलती है। कई फ़ोटो चुनें: अंक भेजने का क्रम बताता है।';

  @override
  String get expStickersTitre => 'स्टिकर और कीबोर्ड';

  @override
  String get expStickersTexte => 'यह आइकन कीबोर्ड की जगह स्टिकर दिखाता है, और एक टैप में फिर कीबोर्ड बन जाता है।';

  @override
  String get expEphemeresTitre => 'मिटने वाले संदेश';

  @override
  String get expEphemeresTexte => 'समय निर्धारित करें; इस बातचीत के नए संदेश दोनों फ़ोनों से मिट जाएँगे।';

  @override
  String get expVerrouTitre => 'लॉक की गई बातचीत';

  @override
  String get expVerrouTexte => 'लॉक होने पर बातचीत सूची में अपना अंतिम संदेश नहीं दिखाती और खोलने के लिए अनलॉक माँगती है।';

  @override
  String get expCodeTitre => 'संपर्क सत्यापित करें';

  @override
  String get expCodeTexte => 'यह कोड अपने संपर्क के साथ मिलाएँ: अगर एक जैसा है, तो आप दोनों के बीच कोई नहीं घुसा।';

  @override
  String get expStatutTitre => '24 घंटे के स्टेटस';

  @override
  String get expStatutTexte => 'स्टेटस एक दिन रहता है, फिर मिट जाता है। यह बिना इंटरनेट के भी फ़ोन से फ़ोन तक जाता है।';

  @override
  String get expGardeTitre => 'कुछ नहीं खोता';

  @override
  String get expGardeTexte => 'अनुपस्थित व्यक्ति को भेजा संदेश एक सप्ताह रखा जाता है और रास्ता खुलते ही अपने आप चला जाता है।';

  @override
  String get expVoieTitre => 'किस रास्ते से';

  @override
  String get expVoieTexte => 'ब्लूटूथ, वाई-फ़ाई डायरेक्ट या इंटरनेट: Droplet जो उपलब्ध हो वही लेता है और बिना पूछे रास्ता बदल लेता है।';

  @override
  String get cnAnnouncement => 'Droplet में नया';

  @override
  String get cnClearAll => 'सब हटाएँ';

  @override
  String get cnClearAllTitle => 'सभी सूचनाएँ हटाएँ?';

  @override
  String get cnClearAllBody => 'केंद्र खाली हो जाएगा। आपकी चैट और संदेश सुरक्षित रहेंगे।';

  @override
  String get cnDelete => 'हटाएँ';

  @override
  String get cnEmptyTitle => 'कुछ नया नहीं';

  @override
  String get cnEmptyBody => 'उल्लेख, आपके संदेशों पर प्रतिक्रियाएँ, छूटी कॉल और Droplet की खबरें यहाँ दिखेंगी।';

  @override
  String get cnMentioned => 'ने आपका उल्लेख किया';

  @override
  String get cnShowLess => 'कम दिखाएँ';

  @override
  String get cnStatusLike => 'ने आपका स्टेटस पसंद किया';

  @override
  String get cnStatusReply => 'ने आपके स्टेटस का जवाब दिया';

  @override
  String get cnTitle => 'सूचना केंद्र';

  @override
  String get ncDeliveryHeader => 'डिलीवरी';

  @override
  String get ncMentionsOnly => 'केवल उल्लेख';

  @override
  String get ncMentionsOnlySub => 'सिर्फ़ तब जब कोई @आपका नाम या @सभी लिखे';

  @override
  String get ncMute1h => '1 घंटा';

  @override
  String get ncMute8h => '8 घंटे';

  @override
  String get ncMute1w => '1 सप्ताह';

  @override
  String get ncMuteAlways => 'हमेशा';

  @override
  String get ncMuteFooter => 'न सूचना, न आवाज़। संदेश फिर भी आते हैं और आपका इंतज़ार करते हैं।';

  @override
  String get ncMuteFooterGroup => 'न सूचना, न आवाज़। उल्लेख फिर भी आप तक पहुँचेंगे।';

  @override
  String get ncMuteHeader => 'म्यूट';

  @override
  String get ncMuteOff => 'बंद';

  @override
  String get ncPreviewAlways => 'हमेशा';

  @override
  String get ncPreviewFooter => 'प्रीव्यू बंद होने पर सूचना में सिर्फ़ “नया संदेश” लिखा होगा: लॉक स्क्रीन पर कुछ नहीं पढ़ा जा सकेगा।';

  @override
  String get ncPreviewHeader => 'संदेश प्रीव्यू';

  @override
  String get ncPreviewNever => 'कभी नहीं';

  @override
  String get ncQuiet => 'चुपचाप पहुँचाएँ';

  @override
  String get ncQuietSub => 'नोटिफ़िकेशन पैनल में, बिना आवाज़ या बैनर';

  @override
  String get ncSampleAuthor => 'लीना';

  @override
  String get ncSampleHidden => 'नया संदेश';

  @override
  String get ncSampleLabel => 'सूचना का उदाहरण';

  @override
  String get ncSampleText => 'शाम 7 बजे मिलें?';

  @override
  String get ncStateMentions => 'केवल उल्लेख';

  @override
  String get ncStateMuted => 'म्यूट है';

  @override
  String get ncStateOn => 'चालू';

  @override
  String get ncStateQuiet => 'चुपचाप';

  @override
  String get ncSystemFooter => 'इस चैट की आवाज़ और बबल Android में सेट होते हैं।';

  @override
  String get ncSystemSettings => 'आवाज़ और बबल';

  @override
  String get ncTitle => 'सूचनाएँ';

  @override
  String get ntfNewMessage => 'नया संदेश';

  @override
  String get ntfNow => 'अभी';

  @override
  String get rnBanners => 'बैनर';

  @override
  String get rnBannersSub => 'Droplet खुला होने पर संदेश आए तब';

  @override
  String get rnFocus1h => '1 घंटे के लिए';

  @override
  String get rnFocusEvening => 'आज शाम तक';

  @override
  String get rnFocusTomorrow => 'कल सुबह तक';

  @override
  String get rnFocusFooter => 'Droplet चुप रहता है: संदेश आते हैं और आपका इंतज़ार करते हैं। कॉल फिर भी बजती हैं।';

  @override
  String get rnFocusHeader => 'फ़ोकस';

  @override
  String get rnFocusMentions => 'उल्लेख आने दें';

  @override
  String get rnFocusMentionsSub => 'जब कोई ग्रुप में @आपका नाम लिखे';

  @override
  String get rnFocusOff => 'फ़ोकस बंद है';

  @override
  String get rnFocusOffSub => 'सूचनाएँ सामान्य रूप से आती हैं';

  @override
  String get rnFocusOn => 'फ़ोकस चालू है';

  @override
  String get rnFocusStop => 'फ़ोकस बंद करें';

  @override
  String get rnFocusStopShort => 'रोकें';

  @override
  String get rnInAppHeader => 'Droplet में';

  @override
  String get rnMutedEmpty => 'कोई चैट म्यूट नहीं है।';

  @override
  String get rnMutedHeader => 'म्यूट';

  @override
  String get rnPreview => 'प्रीव्यू दिखाएँ';

  @override
  String get rnPreviewFooter => 'सूचनाओं में संदेश का टेक्स्ट। हर चैट इसे अलग रख सकती है।';

  @override
  String get rnSystem => 'Android सेटिंग्स';

  @override
  String get rnSystemFooter => 'फ़ोन की सेटिंग्स में Droplet की अनुमतियाँ, आवाज़ें और बबल।';

  @override
  String get stNotificationsSubtitle => 'म्यूट, प्रीव्यू, फ़ोकस';

  @override
  String cnBellUnread(int count) {
    return 'सूचनाएँ, $count नई';
  }

  @override
  String cnMore(int count) {
    return '+$count और';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count और';
  }

  @override
  String cnQuoted(String texte) {
    return '“$texte”';
  }

  @override
  String cnReacted(String emoji) {
    return 'ने आपके संदेश पर $emoji प्रतिक्रिया दी';
  }

  @override
  String ncMutedUntil(String heure) {
    return '$heure तक';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'डिफ़ॉल्ट ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return '$nom को म्यूट करें';
  }

  @override
  String rnFocusUntil(String heure) {
    return '$heure तक · कॉल फिर भी बजेंगी';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n चैट';
  }

  @override
  String get chatsNetSearching => 'आस-पास के डिवाइस खोजे जा रहे हैं…';

  @override
  String get cfEmptyUnreadTitle => 'सब पढ़ लिया';

  @override
  String get cfEmptyUnreadBody => 'बिना पढ़े संदेशों वाली चैट यहाँ दिखेंगी।';

  @override
  String get cfEmptyGroupsTitle => 'अभी कोई ग्रुप नहीं';

  @override
  String get cfEmptyGroupsBody => 'ऊपर दाईं ओर + बटन से एक बनाएँ।';

  @override
  String get cfEmptyOtherTitle => 'यहाँ अभी कुछ नहीं';

  @override
  String get ciLockedWhereHint => 'लॉक हो गई। इसे ढूँढने के लिए चैट सूची को नीचे खींचें।';

  @override
  String get chDraftLabel => 'ड्राफ़्ट:';

  @override
  String get rsMorning => 'सुप्रभात';

  @override
  String get rsEvening => 'शुभ संध्या';

  @override
  String get rsUnreadOne => '1 बिना पढ़ा संदेश';

  @override
  String get rsChatsOne => '1 चैट में';

  @override
  String get rsMentionsOne => '1 उल्लेख';

  @override
  String get rsMissedOne => '1 छूटी कॉल';

  @override
  String get rsSeeUnread => 'बिना पढ़े देखें';

  @override
  String rsUnreadMany(int count) {
    return '$count बिना पढ़े संदेश';
  }

  @override
  String rsChatsMany(int count) {
    return '$count चैट में';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count उल्लेख';
  }

  @override
  String rsMissedMany(int count) {
    return '$count छूटी कॉल';
  }

  @override
  String get camUnavailable => 'कैमरा उपलब्ध नहीं है। सेटिंग्स में अनुमति जाँचें।';

  @override
  String get camTakePhoto => 'फ़ोटो लें';

  @override
  String get camFlip => 'कैमरा बदलें';

  @override
  String get chE2eNotice => 'संदेश एंड-टू-एंड एन्क्रिप्टेड हैं। कोई और, Droplet भी नहीं, इन्हें पढ़ सकता।';

  @override
  String chCallUnreachable(String name) {
    return '$name पहुँच से बाहर है: पास या ऑनलाइन होने पर कॉल कर सकेंगे।';
  }

  @override
  String get chPin => 'पिन करें';

  @override
  String get chUnpin => 'अनपिन करें';

  @override
  String get chPinnedMessage => 'पिन किया गया संदेश';

  @override
  String get chVoicePlay => 'चलाएँ';

  @override
  String get chVoicePause => 'रोकें';

  @override
  String chPinnedMessageN(String position) {
    return 'पिन किया गया संदेश $position';
  }

  @override
  String get msgInfo => 'जानकारी';

  @override
  String get imSearch => 'खोजें';

  @override
  String get apcVideo => 'वीडियो';
}
