// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'إرسال';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionDone => 'تم';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get tabChats => 'المحادثات';

  @override
  String get tabNews => 'الأخبار';

  @override
  String get tabCalls => 'المكالمات';

  @override
  String get tabPeers => 'الأقران';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get appearanceAuto => 'تلقائي';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceDark => 'داكن';

  @override
  String get appearanceFooter =>
      'صُمم Droplet للوضع الداكن: على شاشة OLED تكون البكسلات السوداء مطفأة، مما يوفر البطارية ولا يسبب وهجًا في الظلام. يبقى الوضع الفاتح متاحًا للقراءة في ضوء الشمس الساطع.';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get languageAuto => 'تلقائي (لغة الهاتف)';

  @override
  String get languageFooter =>
      'يتبع الوضع «التلقائي» اللغة المضبوطة على جهازك. إذا لم تكن هذه اللغة مدعومة بعد، يبقى Droplet باللغة الفرنسية.';

  @override
  String get chatsTitle => 'المحادثات';

  @override
  String get chatsSearchHint => 'بحث';

  @override
  String get chatsFilterAll => 'الكل';

  @override
  String get chatsFilterUnread => 'غير مقروءة';

  @override
  String get chatsFilterGroups => 'المجموعات';

  @override
  String get chatsFilterPinned => 'مثبتة';

  @override
  String get chatsEmptyTitle => 'لا توجد محادثات بعد';

  @override
  String get chatsEmptySubtitle =>
      'اقترب من جهاز يستخدم Droplet: سيظهر هنا تلقائيًا.';

  @override
  String get chatsSearchEmptyTitle => 'لا توجد نتائج';

  @override
  String get chatsSearchEmptySubtitle => 'جرّب اسمًا آخر.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قريب في المتناول',
      many: '$count قريبًا في المتناول',
      few: '$count أقران في المتناول',
      two: 'قريبان في المتناول',
      one: 'قريب واحد في المتناول',
      zero: 'جارٍ البحث عن أقران…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => '٣ أحرف على الأقل';

  @override
  String get obChoosePseudo => 'اختر اسمًا للبدء';

  @override
  String get obRestoreFailed => 'فشلت الاستعادة';

  @override
  String get obPhotoSaveFailed => 'تعذّر حفظ الصورة';

  @override
  String get obShareUnavailable => 'المشاركة غير متاحة';

  @override
  String get obBackupPasswordTitle => 'كلمة مرور النسخة الاحتياطية';

  @override
  String get obBackupPasswordMessage => 'الذي اخترته عند تصدير هويتك.';

  @override
  String get obBackupPasswordPlaceholder => 'كلمة المرور';

  @override
  String get obRestore => 'استعادة';

  @override
  String get obSkipStep => 'تخطي هذه الخطوة';

  @override
  String get obContinue => 'متابعة';

  @override
  String get obStart => 'البدء';

  @override
  String get obAlreadyHaveBackup => 'لدي بالفعل نسخة احتياطية';

  @override
  String get obWelcomeTitle => 'مرحبًا بك في\nDroplet';

  @override
  String get obWelcomeSubtitle => 'تطبيق مراسلة يعمل حيث لا توجد شبكة.';

  @override
  String get obFeatOfflineTitle => 'بلا إنترنت، بلا مشغل';

  @override
  String get obFeatOfflineText =>
      'تتواصل الهواتف مباشرة، خطوة بخطوة. لا هوائي، لا فاتورة.';

  @override
  String get obFeatEncryptedTitle => 'مشفّر من طرف إلى طرف';

  @override
  String get obFeatEncryptedText =>
      'حتى الهواتف التي تُمرّر رسائلك لا يمكنها قراءتها.';

  @override
  String get obFeatLocalTitle => 'لا شيء يغادر جهازك';

  @override
  String get obFeatLocalText =>
      'لا حساب، لا خادم، لا جمع بيانات. محادثاتك تبقى معك.';

  @override
  String get obRelayTitle => 'خطوة\nبخطوة';

  @override
  String get obRelaySubtitle =>
      'تنتقل رسالتك من هاتف إلى آخر حتى تصل إلى وجهتها، حتى لو لم تكن في المدى المباشر.';

  @override
  String get obFeatCrowdTitle => 'كلما زاد عددنا، اتسع المدى';

  @override
  String get obFeatCrowdText => 'كل جهاز في المدى يوسّع الشبكة للجميع.';

  @override
  String get obFeatNothingLostTitle => 'لا شيء يضيع';

  @override
  String get obFeatNothingLostText =>
      'الرسالة الموجهة لشخص غائب تنتظر، ثم تتابع مسارها بمجرد أن يُفتح طريق.';

  @override
  String get obSafetyTitle => 'التواصل،\nبلا شبكة';

  @override
  String get obSafetySubtitle =>
      'عندما لا يعمل شيء آخر، تصبح معرفة مكان الآخرين وأنهم بخير أهم معلومة.';

  @override
  String get obFeatMapTitle => 'خريطة تعمل بلا اتصال';

  @override
  String get obFeatMapText =>
      'المناطق التي تطّلع عليها تبقى على الهاتف. بمجرد تصفحها، تُعرض بلا إنترنت.';

  @override
  String get obFeatMeshPosTitle => 'المواقع تأتي من الشبكة اللامركزية';

  @override
  String get obFeatMeshPosText =>
      'بلا خادم: يغادر الموقع هاتف جهة الاتصال مشفّرًا، وينتقل من جهاز إلى آخر حتى يصل إليك.';

  @override
  String get obFeatCheckinTitle => '«أنا بخير»، بلمسة واحدة';

  @override
  String get obFeatCheckinText =>
      'بلمسة واحدة يُبث حالتك إلى كل الجوار. تختار إرفاق موقع تقريبي أو لا.';

  @override
  String get obStatusTitle => 'مشاركة\nالأخبار';

  @override
  String get obStatusSubtitle =>
      'صورة، كلمة، مزاج: تنتقل حالتك من هاتف إلى آخر، كرسائلك تمامًا.';

  @override
  String get obFeatStatusMediaTitle => 'صورة أو فيديو أو نص';

  @override
  String get obFeatStatusMediaText =>
      'انشر ما تريد إظهاره. يستقبله من هم في المدى، دون المرور بالإنترنت.';

  @override
  String get obFeatStatusSeenTitle => 'ترى من شاهدها';

  @override
  String get obFeatStatusSeenText =>
      'كل من يفتح حالتك يُعلمك بذلك، عبر المسار نفسه.';

  @override
  String get obFeatStatusExpireTitle => 'تختفي بعد يوم واحد';

  @override
  String get obFeatStatusExpireText =>
      'أربع وعشرون ساعة، ثم تُمحى الحالة من كل الهواتف التي استقبلتها.';

  @override
  String get obRemovePhoto => 'إزالة الصورة';

  @override
  String get obChoosePhoto => 'اختيار صورة';

  @override
  String get obPhotoTitle => 'وجه،\nإن أردت';

  @override
  String get obPhotoSubtitle =>
      'تساعد الآخرين على التعرف عليك في قائمة. لا شيء يُلزمك بوضع واحدة.';

  @override
  String get obFeatPhotoLocalTitle => 'تبقى على هذا الهاتف';

  @override
  String get obFeatPhotoLocalText =>
      'لا يستقبلها أي خادم، ولا تحفظها أي نسخة احتياطية عبر الإنترنت. تعيش في مجلد التطبيق، ولا مكان آخر.';

  @override
  String get obFeatPhotoCompressTitle => 'تُصغَّر قبل حفظها';

  @override
  String get obFeatPhotoCompressText =>
      'يحتفظ Droplet بصورة مصغّرة من 320 بكسل فقط. صورتك الأصلية لا تُنسخ أبدًا.';

  @override
  String get obNetworkTitle => 'Droplet ينمو\nمعك';

  @override
  String get obNetworkSubtitle =>
      'كل شخص يثبته يوسّع الشبكة — له، ولكل من حوله.';

  @override
  String get obSendToFriend => 'أرسل Droplet لشخص مقرّب';

  @override
  String get obFeatShareOfflineTitle => 'حتى المشاركة تستغني عن الإنترنت';

  @override
  String get obFeatShareOfflineText =>
      'يرسل لك Droplet ملف تثبيته الخاص. ينتقل عبر البلوتوث أو Wi-Fi Direct أو بطاقة الذاكرة — لا حاجة لاتصال من أي طرف.';

  @override
  String get obFeatThreeTitle => 'ثلاثة أشخاص كافون للبدء';

  @override
  String get obFeatThreeText =>
      'بين شخصين، تتراسلان في مدى النظر. بين قلة في حي واحد، تُمرَّر الرسائل ويصبح المدى أكبر بكثير من أي هاتف بمفرده.';

  @override
  String get obIdentityTitle => 'بماذا يجب\nأن ندعوك؟';

  @override
  String get obIdentitySubtitle =>
      'سيظهر هذا الاسم للأشخاص الذين تلتقيهم. يمكنك اختيار اسم لا يكشف هويتك.';

  @override
  String get obPseudoHint => 'اسمك المستعار';

  @override
  String get obFeatKeysTitle => 'مفاتيحك تُنشأ هنا، الآن';

  @override
  String get obFeatKeysText =>
      'لا تغادر هذا الهاتف أبدًا. تذكّر إجراء نسخة احتياطية من الإعدادات: بدونها، الهوية المفقودة تضيع للأبد.';

  @override
  String get splashCaption => 'بلا اتصال. بلا مشغل.';

  @override
  String get chatsMeshNetwork => 'الشبكة اللامركزية';

  @override
  String get chatsNew => 'جديد';

  @override
  String get chatsNewGroup => 'مجموعة جديدة';

  @override
  String get chatsAssistant => 'المساعد';

  @override
  String get chatsEmergencyMode => 'وضع الطوارئ';

  @override
  String get chatsUnpin => 'إلغاء التثبيت';

  @override
  String get chatsPin => 'تثبيت في الأعلى';

  @override
  String get chatsUnmute => 'تفعيل الإشعارات';

  @override
  String get chatsMute => 'كتم الصوت';

  @override
  String get chatsArchive => 'أرشفة';

  @override
  String get swipePin => 'تثبيت';

  @override
  String get swipeUnpin => 'إلغاء';

  @override
  String get swipeMute => 'كتم';

  @override
  String get swipeUnmute => 'إلغاء الكتم';

  @override
  String get swipeArchive => 'أرشفة';

  @override
  String get fmtBold => 'عريض';

  @override
  String get fmtItalic => 'مائل';

  @override
  String get fmtStrike => 'مشطوب';

  @override
  String get fmtMono => 'أحادي المسافة';

  @override
  String get fmtSpoiler => 'حرق';

  @override
  String get vnTranscribing => 'جارٍ التفريغ…';

  @override
  String get vnTranscribeFailed => 'التفريغ غير متاح على هذا الجهاز';

  @override
  String get vnNoSpeech => 'لم يُتعرَّف على كلام';

  @override
  String get msgTranslate => 'ترجمة';

  @override
  String get msgShowOriginal => 'عرض الأصل';

  @override
  String get msgTranslatedFrom => 'تُرجم تلقائيًا';

  @override
  String get msgTranslateFailed => 'الترجمة غير متاحة';

  @override
  String get msgTranslateModel =>
      'يجب تنزيل نموذج اللغة (مرة واحدة، عبر واي‑فاي)';

  @override
  String get pfWallpapers => 'خلفيات متحركة';

  @override
  String get pfWallpapersDesc =>
      'ثماني خلفيات متعددة الألوان تعيش خلف محادثاتك وتدور مع كل رسالة تُرسل.';

  @override
  String get pfFormatting => 'تنسيق النص';

  @override
  String get pfFormattingDesc =>
      'عريض ومائل ومشطوب وكود وحرق، مباشرة داخل رسائلك.';

  @override
  String get pfTranscription => 'الصوت إلى نص';

  @override
  String get pfTranscriptionDesc =>
      'اقرأ رسالة صوتية حين لا يمكنك الاستماع. التعرّف يتم على هاتفك.';

  @override
  String get pfTranslation => 'الترجمة';

  @override
  String get pfTranslationDesc =>
      'ترجم رسالة واردة دون أن يغادر محتواها الجهاز.';

  @override
  String get pfAppIcons => 'أيقونات التطبيق';

  @override
  String get pfAppIconsDesc => 'غيّر أيقونة Droplet على شاشتك الرئيسية.';

  @override
  String get pfBadge => 'شارة ودعم';

  @override
  String get pfBadgeDesc => 'شارة بجانب اسمك، ودعم لمشروع مستقل.';

  @override
  String get pfUnderstood => 'فهمت';

  @override
  String get pfFeaturesTitle => 'ما تفتحه الحزمة';

  @override
  String get chatsUnarchive => 'إلغاء الأرشفة';

  @override
  String get chatsArchivedTitle => 'المؤرشفة';

  @override
  String get chatsNoArchived => 'لا توجد محادثات مؤرشفة';

  @override
  String get chatsLockedTitle => 'المحادثات المقفلة';

  @override
  String get chatsNoLocked => 'لا توجد محادثات مقفلة';

  @override
  String get chatsCrashTitle => 'أُغلق Droplet بشكل غير متوقع';

  @override
  String get chatsCrashBody =>
      'لا يملك Droplet أي خادم: دون إرسالك، هذا الخلل لا وجود له عند أي أحد آخر. لا يحتوي التقرير على رسائل أو جهات اتصال أو مفاتيح.';

  @override
  String get chatsSendReport => 'إرسال التقرير';

  @override
  String get chatsLater => 'لاحقًا';

  @override
  String get stTitle => 'الإعدادات';

  @override
  String get stIconHeader => 'الأيقونة';

  @override
  String get stIconFooter => 'ثلاثة عشر أيقونة للاختيار من بينها لشاشة البدء.';

  @override
  String get stAppIcon => 'أيقونة التطبيق';

  @override
  String get stVariants13 => '13 نسخة';

  @override
  String get stNetworkHeader => 'الشبكة';

  @override
  String get stNetworkFooter =>
      'يتيح الترحيل في الخلفية نقل رسائل الآخرين حتى عند إغلاق Droplet.';

  @override
  String get stRequireTor => 'اشتراط Tor عبر الإنترنت';

  @override
  String get stRequireTorSubtitle => 'بدون Tor لا يصل شيء إلى الخوادم';

  @override
  String get stRequireTorFooter =>
      'يمر الدليل وصندوق البريد عبر Tor متى كان نشطًا. وإلا يتصل Droplet مباشرة: يبقى المحتوى مشفّرًا من طرف إلى طرف، لكن الخوادم ترى عنوان IP الخاص بك. فعّل هذا لمنع ذلك — على حساب المراسلة عبر الإنترنت عند تعطّل Tor.';

  @override
  String get stMeshNetwork => 'الشبكة اللامركزية';

  @override
  String get stPeersTopology => 'الأقران المتصلون والبنية';

  @override
  String get stOfflineMaps => 'الخرائط غير المتصلة';

  @override
  String get stZonesImport => 'المناطق المحفوظة واستيراد الخرائط';

  @override
  String get stSecurityHeader => 'الأمان';

  @override
  String get stSecurityFooter =>
      'لا يحتفظ Droplet بأي نسخة من هويتك. بدون نسخة احتياطية، تُفقد مع الجهاز.';

  @override
  String get stBackupIdentity => 'نسخ هويتي احتياطيًا';

  @override
  String get stExportEncrypted => 'تصدير مشفّر بكلمة مرور';

  @override
  String get stEmergencyMode => 'وضع الطوارئ';

  @override
  String get stSignalSafe => 'الإبلاغ بأنك بخير';

  @override
  String get stContributionHeader => 'المساهمة';

  @override
  String get stMyContribution => 'مساهمتي';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'نشط';

  @override
  String get stProPackUnlocked => 'الحزمة مفتوحة';

  @override
  String get stProIconsThemes => 'أيقونات وخلفيات';

  @override
  String get stCrashLog => 'سجل الأخطاء';

  @override
  String get stAbout => 'حول Droplet';

  @override
  String get stBackgroundRelay => 'الترحيل في الخلفية';

  @override
  String get stActiveClosed => 'نشط حتى مع إغلاق التطبيق';

  @override
  String get stActiveOpenOnly => 'نشط فقط عند فتح التطبيق';

  @override
  String get stBatteryOptim => 'تحسين البطارية';

  @override
  String get stAndroidMayLimit => 'قد يحد Android من الترحيل';

  @override
  String get stFix => 'إصلاح';

  @override
  String get stKeepActiveTitle => 'هل تريد إبقاء Droplet نشطًا؟';

  @override
  String get stKeepActiveBody =>
      'سيشير إشعار دائم إلى أن Droplet يُرحّل الشبكة، حتى مع إغلاق التطبيق. في المقابل، ستُستهلك البطارية أكثر.';

  @override
  String get stEnable => 'تفعيل';

  @override
  String get stCancel => 'إلغاء';

  @override
  String get stAboutTagline =>
      'مراسلة ومكالمات دون اتصال، بلا إنترنت ولا مشغل.';

  @override
  String get stAboutDirect => 'شبكة مباشرة بين الأجهزة — بلا خادم';

  @override
  String get stAboutE2E => 'تشفير من طرف إلى طرف لجميع الرسائل';

  @override
  String get stAboutNoThirdParty => 'لا تُرسل أي بيانات إلى طرف ثالث';

  @override
  String get stAttributionEmoji =>
      'الرموز التعبيرية المتحركة: Noto Animated Emoji © Google، بترخيص CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'المساعد: Gemma 3 1B-IT © Google، مُكمّم (int4) بواسطة litert-community وأُعيد نشره بواسطة Droplet، بموجب شروط استخدام Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'خلفية المحادثة';

  @override
  String get stChatPatterns => 'رسومات Droplet';

  @override
  String get stChatPatternsSubtitle => 'رسومات خطية صغيرة فوق الخلفية';

  @override
  String get stChatBgFooter =>
      'يتقدم التدرج خطوة مع كل رسالة تُرسل. اختر «بلا» لخلفية موحدة: عندها لا يُحسب شيء، مما يوفر البطارية.';

  @override
  String get stBgFree => 'مجانية';

  @override
  String get stBgPremium => 'مميزة · متحركة';

  @override
  String get stBgNone => 'بلا';

  @override
  String get stBgDefault => 'الافتراضي';

  @override
  String get stBgThisChat => 'خلفية هذه المحادثة';

  @override
  String get stTextSize => 'حجم النص';

  @override
  String get stBubbleCorners => 'زوايا الرسائل';

  @override
  String get stAccentHeader => 'لون التمييز';

  @override
  String get stAccentFooter =>
      'يلوّن فقاعاتك والأزرار والروابط في التطبيق كله.';

  @override
  String get stChatListHeader => 'قائمة المحادثات';

  @override
  String get stChatListTwoLines => 'سطران';

  @override
  String get stChatListThreeLines => 'ثلاثة أسطر';

  @override
  String get stResetAppearance => 'إعادة ضبط المظهر';

  @override
  String get stPreviewIncoming => 'نلتقي الليلة؟';

  @override
  String get stPreviewOutgoing => 'نعم، بكل سرور!';

  @override
  String get stAppearanceRow => 'المظهر';

  @override
  String get stAppearanceSubtitle => 'السمة واللون وحجم النص والخلفيات';

  @override
  String get stBgApply => 'استخدام هذه الخلفية';

  @override
  String get stBgUnlock => 'فتح مع الاشتراك المميز';

  @override
  String get stBgApplied => 'تم تطبيق الخلفية';

  @override
  String get stBgPreviewHint =>
      'الخلفية تتحرك، وتدور ألوانها مع كل رسالة تُرسل.';

  @override
  String get stBgPreviewIncoming => 'هل رأيت الخلفية الجديدة؟';

  @override
  String get stBgPreviewOutgoing => 'نعم، إنها رائعة ✨';

  @override
  String get stSoundHeader => 'الأصوات';

  @override
  String get stSoundToggle => 'أصوات التطبيق';

  @override
  String get stSoundSubtitle => 'الرسائل، الاتصالات، التنبيهات';

  @override
  String get stSoundFooter =>
      'نغمات قصيرة بمستوى صوت إشعارات النظام — صامتة عندما يكون الهاتف في الوضع الصامت أو وضع التركيز.';

  @override
  String get stPacksHeader => 'المساعد — بطاقات دون اتصال';

  @override
  String get stPacksToggle => 'بطاقات الإسعاف والطوارئ';

  @override
  String get stPacksSubtitle =>
      'يعتمد المساعد عليها في الإسعافات الأولية وحالات الطوارئ.';

  @override
  String get stPacksFooter =>
      'بطاقات مرجعية مدمجة (إسعافات أولية، زلزال، فيضان، ماء صالح للشرب…). عندما يتعلق السؤال بها، يقتبس المساعد البطاقة بدل التخمين. لا تغني عن تدريب ولا عن الاتصال بالطوارئ.';

  @override
  String get stPrivateModeHeader => 'الوضع الخاص';

  @override
  String get stTorFooter =>
      'يحمي Tor عنوان IP الخاص بك ومحادثاتك بتمريرها عبر شبكة Tor. تستمر الشبكة اللامركزية المحلية (BLE/واي فاي) في العمل بشكل طبيعي.';

  @override
  String get stTorActiveAnon => 'نشط — بياناتك مجهولة الهوية';

  @override
  String get stTorConnecting => 'جارٍ الاتصال…';

  @override
  String get stTorDisabled => 'الوضع الخاص معطّل';

  @override
  String get callsTitle => 'المكالمات';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكالمة فائتة',
      many: '$count مكالمة فائتة',
      few: '$count مكالمات فائتة',
      two: 'مكالمتان فائتتان',
      one: 'مكالمة فائتة واحدة',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'مكالمة جديدة';

  @override
  String get callsAll => 'الكل';

  @override
  String get callsMissed => 'الفائتة';

  @override
  String get callsNoneMissed => 'لا مكالمات فائتة';

  @override
  String get callsNone => 'لا مكالمات';

  @override
  String get callsMissedEmptyBody => 'ستظهر هنا المكالمات التي لم ترد عليها.';

  @override
  String get callsEmptyBody =>
      'تمر المكالمات عبر الشبكة المحلية، بلا مشغل ولا باقة. سيظهر سجلك هنا.';

  @override
  String get callsRetained200 => 'يُحتفظ بآخر 200 مكالمة على هذا الجهاز فقط.';

  @override
  String get callsIncoming => 'واردة';

  @override
  String get callsOutgoing => 'صادرة';

  @override
  String get callsMissedLabel => 'فائتة';

  @override
  String get callsNoAnswer => 'بلا رد';

  @override
  String get callsConnectionFailed => 'فشل الاتصال';

  @override
  String get callsYesterday => 'أمس';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m د $s ث';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s ث';
  }

  @override
  String get peersTitle => 'الأقران';

  @override
  String get peersSearching => 'جارٍ البحث…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهاز في المتناول',
      many: '$count جهازًا في المتناول',
      few: '$count أجهزة في المتناول',
      two: 'جهازان في المتناول',
      one: 'جهاز واحد في المتناول',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'خريطة الشبكة';

  @override
  String get peersNoneInRange => 'لا أحد في المتناول';

  @override
  String get peersNoneInRangeBody =>
      'يبحث Droplet باستمرار عن الأجهزة القريبة. اقترب من شخص لديه التطبيق لإقامة أول اتصال.';

  @override
  String get peersDirectRange => 'في المدى المباشر';

  @override
  String get peersDirectRangeFooter =>
      'يمكن الوصول إلى هذه الأجهزة دون المرور بأي شخص آخر.';

  @override
  String get peersRelayed => 'عبر الترحيل';

  @override
  String get peersRelayedFooter =>
      'هذه الأجهزة خارج المدى المباشر: تصلها الرسائل عبر هواتف أخرى.';

  @override
  String get peersRelay => 'مُرحِّل';

  @override
  String get peersCall => 'اتصال';

  @override
  String get peersTooSlow => 'بطيء جدًا للصوت — اقترب';

  @override
  String get peersWifi => 'واي فاي';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'بلوتوث';

  @override
  String get peersUnknownLink => 'وصلة غير معروفة';

  @override
  String get peersDirect => 'مباشر';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ترحيل',
      many: '$count ترحيلة',
      few: '$count ترحيلات',
      two: 'ترحيلان',
      one: 'ترحيل واحد',
      zero: 'مباشر',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'انتهت صلاحية هذه الحالة';

  @override
  String get svReceiving => 'جارٍ الاستلام…';

  @override
  String get svReceivingBody => 'يصل الملف عبر الشبكة المحلية';

  @override
  String get svProgressLabel => 'تقدّم الحالة';

  @override
  String get svReplyHint => 'الرد…';

  @override
  String get svSendReply => 'إرسال الرد';

  @override
  String get svYourStatus => 'حالتك';

  @override
  String get svNoViewsYet =>
      'لم يشاهد أحد هذه الحالة بعد.\nستستمر في التنقل طالما تلتقي بأجهزة أخرى.';

  @override
  String get svJustNow => 'الآن';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count دقيقة',
      many: 'قبل $count دقيقة',
      few: 'قبل $count دقائق',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      many: 'قبل $count ساعة',
      few: 'قبل $count ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'موسيقى';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشاهدة',
      many: '$count مشاهدة',
      few: '$count مشاهدات',
      two: 'مشاهدتان',
      one: 'مشاهدة واحدة',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعجاب',
      many: '$count إعجابًا',
      few: '$count إعجابات',
      two: 'إعجابان',
      one: 'إعجاب واحد',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رد',
      many: '$count ردًا',
      few: '$count ردود',
      two: 'ردّان',
      one: 'رد واحد',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'الأصلي';

  @override
  String get cpFilterDark => 'داكن';

  @override
  String get cpFilterBright => 'مشرق';

  @override
  String get cpFilterVintage => 'قديم الطراز';

  @override
  String get cpWriteStatusHint => 'اكتب حالة';

  @override
  String get cpPreparingVideo => 'جارٍ تجهيز الفيديو…';

  @override
  String get cpLoadingEllipsis => 'جارٍ التحميل…';

  @override
  String cpEndsIn(Object s) {
    return 'ينتهي خلال $s ث';
  }

  @override
  String get cpModeVideo => 'فيديو';

  @override
  String get cpModePhoto => 'صورة';

  @override
  String get cpModeMessage => 'رسالة';

  @override
  String get cpModeVoice => 'صوتي';

  @override
  String get gcChooseName => 'اختر اسمًا للمجموعة';

  @override
  String get gcSelectOneMember => 'اختر عضوًا واحدًا على الأقل';

  @override
  String get gcCreationFailed => 'فشل إنشاء المجموعة';

  @override
  String get gcNewGroup => 'مجموعة جديدة';

  @override
  String get gcGroupName => 'اسم المجموعة';

  @override
  String get gcNameHint => 'مثال: فريق الميدان';

  @override
  String get gcMembers => 'الأعضاء';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محدد',
      many: '$count محددًا',
      few: '$count محددين',
      two: 'مُحدَّدان',
      one: 'مُحدَّد واحد',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'لا أحد في المتناول';

  @override
  String get gcGetCloserBody =>
      'اقترب من جهاز آخر يستخدم Droplet: يظهر الأقران هنا تلقائيًا.';

  @override
  String get gcCreateGroup => 'إنشاء المجموعة';

  @override
  String get gcConnected => 'متصل';

  @override
  String get gcAlreadyMet => 'التقيتما سابقًا';

  @override
  String get giRenameGroup => 'إعادة تسمية المجموعة';

  @override
  String get giRenameFailed => 'فشلت إعادة التسمية';

  @override
  String get giNoPeerToAdd => 'لا يوجد أقران متاحون للإضافة';

  @override
  String get giAddMemberHeader => 'إضافة عضو';

  @override
  String get giAddMemberFailed => 'فشلت إضافة العضو';

  @override
  String get giRemoveMemberTitle => 'هل تريد إزالة هذا العضو؟';

  @override
  String get giRemoveMemberBody =>
      'لن يتمكن من قراءة الرسائل المُرسلة بعد إزالته.';

  @override
  String get giRemove => 'إزالة';

  @override
  String get giRemoveMemberFailed => 'فشلت إزالة العضو';

  @override
  String get giLeaveGroupTitle => 'هل تريد مغادرة المجموعة؟';

  @override
  String get giLeaveGroupBody => 'لن تتلقى الرسائل المُرسلة بعد مغادرتك.';

  @override
  String get giLeave => 'مغادرة';

  @override
  String get giNoOneReachable =>
      'لا يوجد عضو يمكن الوصول إليه عبر واي فاي محلي الآن';

  @override
  String get giMax4Participants =>
      'الحد الأقصى 4 مشاركين في المكالمة الجماعية — سيتم الاتصال فقط بأول 3 يمكن الوصول إليهم';

  @override
  String get giGroupNotFound => 'المجموعة غير موجودة';

  @override
  String get giGroupInfo => 'معلومات المجموعة';

  @override
  String get giGroupCall => 'مكالمة جماعية';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'رسائل المجموعة مشفّرة';

  @override
  String get giAdd => 'إضافة';

  @override
  String get giMe => 'أنا';

  @override
  String get giAdministrator => 'مسؤول';

  @override
  String get giLeaveGroup => 'مغادرة المجموعة';

  @override
  String get sfNoLocationShared => 'الموقع غير مُشارَك';

  @override
  String get sfLocationShared => 'تم مشاركة الموقع';

  @override
  String sfDistanceMeters(Object m) {
    return 'على بعد $m م';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'على بعد $km كم';
  }

  @override
  String get sfBearingN => 'إلى الشمال';

  @override
  String get sfBearingNE => 'إلى الشمال الشرقي';

  @override
  String get sfBearingE => 'إلى الشرق';

  @override
  String get sfBearingSE => 'إلى الجنوب الشرقي';

  @override
  String get sfBearingS => 'إلى الجنوب';

  @override
  String get sfBearingSW => 'إلى الجنوب الغربي';

  @override
  String get sfBearingW => 'إلى الغرب';

  @override
  String get sfBearingNW => 'إلى الشمال الغربي';

  @override
  String get sfBroadcastSafeTitle => 'هل تريد بث \"أنا بخير\"؟';

  @override
  String get sfBroadcastSafeMessage =>
      'ستكون هذه الحالة مرئية لكل الشبكة في النطاق، وليس فقط لجهات اتصالك. يمكنك تضمين موقع تقريبي (مُقرَّب، غير دقيق أبدًا).';

  @override
  String get sfWithLocation => 'مع موقع تقريبي';

  @override
  String get sfWithoutLocation => 'بدون موقع';

  @override
  String get sfStatusBroadcast => 'تم بث الحالة إلى الشبكة';

  @override
  String get sfBroadcastFailed => 'فشل البث';

  @override
  String get sfHelpRequestTitle => 'هل تريد بث \"أحتاج إلى مساعدة\"؟';

  @override
  String get sfHelpRequestMessage =>
      'ستُعلم هذه الحالة الأقران في النطاق بأنك بحاجة إلى مساعدة. يمكنك تضمين موقع تقريبي.';

  @override
  String get sfHelpRequestBroadcast => 'تم بث طلب المساعدة إلى الشبكة';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يومًا',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم واحد',
      zero: 'منذ أقل من يوم',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'وضع الطوارئ';

  @override
  String get sfViewOnMap => 'عرض على الخريطة';

  @override
  String get sfNeedHelp => 'أحتاج إلى مساعدة';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تسجيلات الوصول المستلمة ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'لم يتم استلام أي تسجيل وصول بعد';

  @override
  String get sfCheckinsAppearHere =>
      'ستظهر هنا حالات \"بخير\" التي يبثها الأقران في النطاق.';

  @override
  String get sfSafeLabel => 'بخير';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'بخير · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'بخير · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel => 'بث حالة أماني إلى شبكة الشبكة';

  @override
  String get sfImSafe => 'أنا بخير';

  @override
  String get emSosActive => 'نداء استغاثة نشط';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'إشارة SOS نشطة — تُبث إلى جميع الأجهزة القريبة';

  @override
  String get emPullToSendSignal => 'اضغط لإرسال إشارة طوارئ';

  @override
  String get emSignalRelayedDescription =>
      'يتم ترحيل الإشارة من جهاز إلى آخر\nعبر شبكة الشبكة بأكملها.';

  @override
  String get emBroadcasting => 'جارٍ البث...';

  @override
  String get emSharePosition => 'مشاركة موقعي';

  @override
  String get emSosActivated => 'تم تفعيل إشارة SOS';

  @override
  String get emSafeStatusMessage => '🟢 أنا بخير';

  @override
  String get emSafetyStatusBroadcast => 'تم بث حالة الأمان';

  @override
  String get pmEnterPayingNumber => 'أدخل الرقم الذي سيقوم بالدفع (9 أرقام).';

  @override
  String get pmRequestSent => 'تم إرسال الطلب…';

  @override
  String get pmPaymentLaunchFailed =>
      'تعذر بدء عملية الدفع. تحقق من الرقم واتصالك، أو ادفع يدويًا أدناه.';

  @override
  String get pmValidateOnPhone =>
      'أكّد على هاتفك: أدخل رمز Mobile Money الخاص بك عند ظهور الرسالة.';

  @override
  String get pmPaymentNotConfirmed => 'لم يتم تأكيد الدفع. لم يتم فتح أي شيء.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'تمت عملية الدفع، لكن الترخيص المستلم غير صالح. راسلنا وسيتم إعادة إصداره: $contact';
  }

  @override
  String get pmProActivated => 'تم تفعيل Droplet Pro';

  @override
  String get pmPackUnlocked => 'تم فتح الحزمة';

  @override
  String get pmInvalidCode =>
      'هذا الرمز غير صالح على هذا الجهاز. تأكد من أنك أرسلت رمز الجهاز الظاهر أعلاه.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'ما لن يطلبه\nDroplet أبدًا';

  @override
  String get pmNeverAskBody =>
      'لا إعلانات، ولا اشتراك إلزامي، ولا إعادة بيع لبياناتك — لا يوجد حتى خادم لجمعها. الحزمة و Pro يموّلان البقية.';

  @override
  String get pmCommunitySemantics => 'انضم إلى مجتمع يضم أكثر من 1200 عضو نشط';

  @override
  String get pmCommunityText => 'انضم إلى أكثر من 1200 عضو على الشبكة';

  @override
  String get pmProPreviewSemantics => 'معاينة لميزات Pro التي سيتم فتحها';

  @override
  String get pmAnimatedEmojis => 'رموز تعبيرية\nمتحركة';

  @override
  String get pmWallpapers => 'خلفيات\nالمحادثة';

  @override
  String get pmAppIcons => 'أيقونات\nالتطبيق';

  @override
  String get pmOnceForLife => 'مرة واحدة، مدى الحياة';

  @override
  String get pmProAdvantage1 =>
      'الأيقونات العشر وخلفيات المحادثة الثماني من الحزمة';

  @override
  String get pmProAdvantage2 => 'شارة Pro بجانب اسمك';

  @override
  String get pmProAdvantage3 => 'الميزات القادمة، دون أي تكلفة إضافية';

  @override
  String get pmPackTitle => 'الحزمة';

  @override
  String get pmOnce => 'مرة واحدة';

  @override
  String get pmPackAdvantage1 => 'عشر أيقونات تطبيق إضافية';

  @override
  String get pmPackAdvantage2 => 'ثماني خلفيات للمحادثة';

  @override
  String get pmPayByHand => 'أو ادفع يدويًا';

  @override
  String get pmHowTo => 'كيفية القيام بذلك';

  @override
  String get pmIfPromptDoesNotArrive =>
      'إذا لم تصل الرسالة إلى هاتفك، أو إذا كنت تفضل إرسال المال بنفسك.';

  @override
  String pmStep1Title(Object montant) {
    return 'أرسل $montant فرنك';
  }

  @override
  String get pmStep1Body =>
      'اختر مشغّلك: ستُفتح قائمته، ويبقى الرقم ظاهرًا هنا أثناء تصفحك للقائمة.';

  @override
  String get pmStep2Title => 'أرسل رمز جهازك';

  @override
  String get pmStep2Body =>
      'مع لقطة شاشة الدفع. بدون هذا الرمز، لا يمكن إنشاء الترخيص — فهو صالح فقط لهاتفك.';

  @override
  String get pmStep3Title => 'ستستلم ترخيصًا';

  @override
  String get pmStep3Body =>
      'سطر طويل يبدأ بـ DROP1. الصقه أدناه: يتم الفتح فورًا ويعمل دون اتصال، إلى الأبد.';

  @override
  String get pmPayNow => 'ادفع الآن';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money أو Orange Money، من هذا الهاتف أو من هاتف آخر.';

  @override
  String get pmPhoneNumberSemantics => 'رقم الهاتف لعملية دفع Mobile Money';

  @override
  String get pmWaitingForCode => 'بانتظار رمزك…';

  @override
  String pmPayAmount(Object montant) {
    return 'ادفع $montant فرنك';
  }

  @override
  String get pmRestorePurchaseSemantics => 'استعادة عملية شراء سابقة';

  @override
  String get pmAlreadyPaidRestore => 'هل دفعت بالفعل؟ استعادة';

  @override
  String pmDialCode(Object code) {
    return 'اتصل بـ $code من هاتفك';
  }

  @override
  String get pmChooseOperatorSemantics => 'اختيار مشغل للدفع';

  @override
  String get pmNumberAmountFilled =>
      'تم بالفعل تعبئة الرقم والمبلغ — لم يتبقَّ سوى رمزك السري.';

  @override
  String get pmOrangeMenuInstructions =>
      'في قائمة Orange: تحويل الأموال، ثم الرقم والمبلغ أدناه.';

  @override
  String get pmLabelNumber => 'الرقم';

  @override
  String get pmLabelAmount => 'المبلغ';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'ادفع $montant فرنك عبر $operator';
  }

  @override
  String get pmMenuOpen => 'القائمة مفتوحة';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'مرحبًا، لقد دفعت للتو مقابل Droplet.\n\nالعرض: $offer\nالمبلغ: $amount فرنك\nرمز الجهاز: $code\n\n(أرفق لقطة شاشة الدفع)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'تعذر العثور على WhatsApp — تم نسخ الرمز. أرسله إلى $contact';
  }

  @override
  String get pmPrepareRequest => 'تحضير طلبي';

  @override
  String get pmReceivedLicense => 'لقد استلمت ترخيصي';

  @override
  String get pmPaste => 'لصق';

  @override
  String get pmUnlock => 'فتح';

  @override
  String get pmProIsActive => 'Droplet Pro نشط';

  @override
  String get pmPackIsUnlocked => 'الحزمة مفتوحة';

  @override
  String get pmProActiveDescription =>
      'شارة Pro مرافقة لاسمك، وجميع الأيقونات وخلفيات المحادثة متاحة لك.';

  @override
  String get pmPackActiveDescription =>
      'الأيقونات العشر وخلفيات المحادثة الثماني من الحزمة متاحة لك في الإعدادات.';

  @override
  String get pmLicenseDeviceBound =>
      'ترخيصك صالح لهذا الهاتف. إذا غيّرت هاتفك، احتفظ بالرسالة التي تحتويه: سيُعاد إصداره مجانًا.';

  @override
  String torError(Object e) {
    return 'خطأ: $e';
  }

  @override
  String get torEnable => 'تفعيل Tor';

  @override
  String get torProtected => 'محمي';

  @override
  String get torDisabled => 'معطّل';

  @override
  String get torStateHeader => 'الحالة';

  @override
  String get torCircuit => 'الدارة';

  @override
  String get torActive => 'نشط';

  @override
  String get torInProgress => 'قيد التقدم…';

  @override
  String get torInactive => 'غير نشط';

  @override
  String get torFailed => 'فشل';

  @override
  String get torReason => 'السبب';

  @override
  String get torBannerConnecting => 'جارٍ الاتصال بـ Tor…';

  @override
  String get torBannerActive => 'Tor نشط';

  @override
  String get torBannerError => 'Tor غير متاح';

  @override
  String get torBannerOff => 'Tor متوقف';

  @override
  String get torEncryption => 'التشفير';

  @override
  String get torLatency => 'زمن الاستجابة';

  @override
  String get torContactsHeader => 'جهات الاتصال';

  @override
  String get torScanQrFooter =>
      'امسح رمز QR، أو ابحث عن اسم في الدليل، لإضافة جهة اتصال بعيدة.';

  @override
  String get torScanQrCode => 'مسح رمز QR';

  @override
  String get torMyQrCode => 'رمز QR الخاص بي';

  @override
  String get torInformationHeader => 'معلومات';

  @override
  String get torVersion => 'الإصدار';

  @override
  String get torHowItWorks => 'كيف يعمل ذلك؟';

  @override
  String get torConnecting => 'جارٍ الاتصال…';

  @override
  String get torInactiveTitle => 'Tor غير نشط';

  @override
  String get torDataThroughTor => 'تمر بياناتك عبر شبكة Tor';

  @override
  String get torEstablishingCircuit => 'جارٍ إنشاء الدارة (10-30 ثانية)';

  @override
  String get torActivateToProtect => 'فعّله لحماية هويتك';

  @override
  String get torHowItWorksTitle => 'كيف يحمي Tor بياناتك';

  @override
  String get torEncryptedCircuit => 'دارة مشفّرة';

  @override
  String get torEncryptedCircuitDesc =>
      'تمر رسائلك عبر 3 مرحلات Tor حول العالم.';

  @override
  String get torHiddenIp => 'إخفاء عنوان IP';

  @override
  String get torHiddenIpDesc => 'لا يمكن لأي موقع رؤية عنوانك الحقيقي.';

  @override
  String get torMeshPreserved => 'الشبكة محفوظة';

  @override
  String get torMeshPreservedDesc =>
      'يستمر البلوتوث والواي فاي المحلي في العمل.';

  @override
  String get torUnderstood => 'فهمت';

  @override
  String get qrTorNotActive => 'Tor غير نشط. فعّله من الإعدادات > Tor.';

  @override
  String get qrScanContactCode => 'امسح رمز QR الخاص بجهة اتصال';

  @override
  String get qrCodeFromContactScreen =>
      'يجب أن يأتي الرمز من شاشة Tor الخاصة بجهة اتصالك';

  @override
  String get qrScanAnother => 'مسح رمز آخر';

  @override
  String get qrChat => 'محادثة';

  @override
  String get qgScanToConnect => 'امسح للاتصال';

  @override
  String get qgCopied => 'تم النسخ ✓';

  @override
  String get qgCopyCode => 'نسخ الرمز';

  @override
  String get qgHowItWorks => 'كيف يعمل ذلك';

  @override
  String get qgStep1 => 'أظهر رمز QR هذا لجهة اتصالك';

  @override
  String get qgStep2 => 'يقوم بمسحه من شاشة Tor الخاصة به';

  @override
  String get qgStep3 => 'أنتما متصلان عبر Tor';

  @override
  String get shShareTo => 'مشاركة إلى…';

  @override
  String get shSearchConversation => 'البحث عن محادثة';

  @override
  String get shNoConversation => 'لا توجد محادثة';

  @override
  String get shOpenChatFirst =>
      'افتح أولاً محادثة في Droplet حتى تتمكن من مشاركة المحتوى فيها.';

  @override
  String get shGroup => 'مجموعة';

  @override
  String get shDiscussion => 'محادثة';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر للمشاركة',
      many: '$count عنصرًا للمشاركة',
      few: '$count عناصر للمشاركة',
      two: 'عنصران للمشاركة',
      one: 'عنصر واحد للمشاركة',
      zero: 'لا عناصر للمشاركة',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'تم تثبيت الخريطة';

  @override
  String get omClearCacheTitle => 'هل تريد إفراغ ذاكرة التخزين المؤقت؟';

  @override
  String get omRemoveZoneTitle => 'هل تريد حذف هذه المنطقة؟';

  @override
  String get omClearCacheMessage =>
      'لن تكون المناطق التي تصفحتها متاحة دون اتصال بعد الآن. ستُعاد تكوينها عند تصفحها مجددًا مع وجود اتصال بالشبكة.';

  @override
  String omRemoveZoneMessage(Object name) {
    return 'سيتم حذف «$name» من هذا الجهاز.';
  }

  @override
  String get omClear => 'إفراغ';

  @override
  String get omTitle => 'الخرائط';

  @override
  String get omReading => 'جارٍ القراءة…';

  @override
  String get omNoMapsSaved => 'لا توجد خريطة محفوظة';

  @override
  String omSizeOnDevice(Object size) {
    return '$size على هذا الجهاز';
  }

  @override
  String get omBrowseMapHint =>
      'تصفح الخريطة مع وجود اتصال بالشبكة: تبقى المناطق التي تشاهدها متاحة دون اتصال.';

  @override
  String get omOnThisDevice => 'على هذا الجهاز';

  @override
  String get omZonesFillThemselves =>
      'تُملأ المناطق التي تُشاهد تلقائيًا أثناء تصفح الخريطة مع وجود اتصال بالشبكة.';

  @override
  String get omMbtilesExplainer =>
      'يحتوي ملف .mbtiles على منطقة كاملة، مُعدّة مسبقًا. إنه التنسيق القياسي للخرائط دون اتصال: يمكن لأي أداة رسم خرائط إنتاجه.';

  @override
  String get omImportMap => 'استيراد خريطة';

  @override
  String get omReadingFile => 'جارٍ قراءة الملف…';

  @override
  String get omMbtilesFromPhone => 'ملف .mbtiles من هذا الهاتف';

  @override
  String get omAttributionText =>
      'تأتي البيانات من OpenStreetMap (ترخيص ODbL)، ويُقدَّم خلفية الخريطة بواسطة CARTO. لا يقوم Droplet أبدًا بتنزيل منطقة كاملة مسبقًا: لا تسمح بذلك أي خدمة مجانية. يُحتفظ فقط بما تشاهده.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلاطة',
      many: '$count بلاطة',
      few: '$count بلاطات',
      two: 'بلاطتان',
      one: 'بلاطة واحدة',
      zero: 'لا بلاطات',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '$k ألف بلاطة';
  }

  @override
  String omSizeKb(Object n) {
    return '$n كيلوبايت';
  }

  @override
  String omSizeMb(Object n) {
    return '$n ميغابايت';
  }

  @override
  String omSizeGb(Object n) {
    return '$n غيغابايت';
  }

  @override
  String get nwTitle => 'الأخبار';

  @override
  String get nwStatusesNetwork24h => 'حالات الشبكة · 24 س';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حالة في الشبكة',
      many: '$count حالة في الشبكة',
      few: '$count حالات في الشبكة',
      two: 'حالتان في الشبكة',
      one: 'حالة واحدة في الشبكة',
      zero: 'لا حالات في الشبكة',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'نشر حالة';

  @override
  String get nwNoNewsYet => 'لا توجد أخبار في الوقت الحالي';

  @override
  String get nwStatusesAppearHere =>
      'ستظهر هنا الحالات التي ينشرها الأشخاص في النطاق، دون المرور عبر الإنترنت.';

  @override
  String get nwRecent => 'الأحدث';

  @override
  String get nwStatusExpires => 'تختفي الحالة تلقائيًا بعد 24 ساعة من نشرها.';

  @override
  String get nwPhoto => '📷 صورة';

  @override
  String get nwVideo => '🎥 فيديو';

  @override
  String get nwVoiceMessage => '🎤 رسالة صوتية';

  @override
  String get nwMusic => '🎵 موسيقى';

  @override
  String get nwStatusFallback => 'حالة';

  @override
  String get nwMyStatus => 'حالتي';

  @override
  String get nwTapToPublish => 'اضغط للنشر على الشبكة';

  @override
  String get nwNotSeenYet => 'لم تتم مشاهدته بعد';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شاهده $count شخص',
      many: 'شاهده $count شخصًا',
      few: 'شاهده $count أشخاص',
      two: 'شاهده شخصان',
      one: 'شاهده شخص واحد',
      zero: 'لم يشاهده أحد',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'الموقع غير متاح — تحقق من أن تحديد الموقع مفعّل.';

  @override
  String mpDistanceMeters(Object m) {
    return '$m م';
  }

  @override
  String mpDistanceKm(Object km) {
    return '$km كم';
  }

  @override
  String mpDistanceFromYou(Object distance) {
    return '$distance منك';
  }

  @override
  String get mpTitle => 'الموقع';

  @override
  String get mpOffline => 'غير متصل';

  @override
  String get mpOnlineMap => 'خريطة متصلة';

  @override
  String get mpMyPosition => 'موقعي';

  @override
  String get mpLayers => 'الطبقات';

  @override
  String get mpOfflineToast =>
      'خريطة دون اتصال: ستظهر فقط المناطق المحفوظة مسبقًا.';

  @override
  String get mpOnlineToast =>
      'خريطة متصلة: سيتم حفظ المناطق التي تشاهدها لاحقًا.';

  @override
  String get mpMapLabel => 'خريطة';

  @override
  String get mpSatelliteLabel => 'القمر الصناعي';

  @override
  String get mpSatelliteMode => 'وضع القمر الصناعي';

  @override
  String get mpMapMode => 'وضع الخريطة';

  @override
  String get mpWrite => 'كتابة';

  @override
  String get mpCenter => 'توسيط';

  @override
  String get mpNoOneOnMap => 'لا أحد على الخريطة';

  @override
  String get mpPositionsAppearHere =>
      'تظهر المواقع هنا عندما تشاركها جهة اتصال من وضع الأمان.';

  @override
  String get mpYou => 'أنت';

  @override
  String get mnTitle => 'شبكة Mesh';

  @override
  String get mnPeers => 'الأقران';

  @override
  String get mnAvgHops => 'متوسط القفزات';

  @override
  String get mnSignal => 'الإشارة';

  @override
  String get mnStrong => 'قوية';

  @override
  String get mnMedium => 'متوسطة';

  @override
  String get mnSearchingPeers => 'جارٍ البحث عن أقران في النطاق…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قرين متصل',
      many: '$count قرينًا متصلًا',
      few: '$count أقران متصلون',
      two: 'قرينان متصلان',
      one: 'قرين واحد متصل',
      zero: 'لا أقران متصلون',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'لا يوجد قرين متصل في الوقت الحالي';

  @override
  String get mnGetCloserHint =>
      'اقترب من جهاز آخر مثبّت عليه Droplet — يتم الاكتشاف تلقائيًا، دون أي إعداد.';

  @override
  String get mnConnectedPeersHeader => 'الأقران المتصلون';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قفزة',
      many: '$count قفزة',
      few: '$count قفزات',
      two: 'قفزتان',
      one: 'قفزة واحدة',
      zero: 'بدون قفزات',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'بلوتوث';

  @override
  String get mnWifiLocal => 'واي فاي محلي';

  @override
  String get mnP2pNative => 'P2P أصلي';

  @override
  String get mnActiveGateway => 'بوابة نشطة';

  @override
  String get mnPath => 'المسار';

  @override
  String get mnTransport => 'النقل';

  @override
  String get mnBattery => 'البطارية';

  @override
  String get mnScore => 'النقاط';

  @override
  String get mnReconnecting => 'إعادة الاتصال';

  @override
  String get cnBronze => 'برونزي';

  @override
  String get cnSilver => 'فضي';

  @override
  String get cnGold => 'ذهبي';

  @override
  String get cnDiamond => 'ماسي';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة',
      many: '$count نقطة',
      few: '$count نقاط',
      two: 'نقطتان',
      one: 'نقطة واحدة',
      zero: 'لا نقاط',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points قبل الوصول إلى مستوى $tier';
  }

  @override
  String get cnRelayedMessages => 'الرسائل المُرحَّلة للآخرين';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n نقطة';
  }

  @override
  String get cnGatewayMinutes => 'الدقائق في وضع الترحيل (البوابة)';

  @override
  String get cnExplanation =>
      'كل رسالة يقوم جهازك بترحيلها للآخرين، وكل دقيقة يبقى فيها متاحًا كمرحّل، تساعد شبكة Mesh على الوصول إلى المزيد من الأشخاص، لمسافة أبعد. ليس لهذه الشارة أي تأثير على التطبيق — إنها مجرد تقدير لمساهمتك.';

  @override
  String get nmTitle => 'رسالة جديدة';

  @override
  String get nmNewGroup => 'مجموعة جديدة';

  @override
  String get nmScanCode => 'مسح رمز';

  @override
  String get nmVerifyContactIdentity => 'التحقق من هوية جهة اتصال';

  @override
  String get nmNoOneInRange => 'لا أحد في النطاق';

  @override
  String get nmNoResult => 'لا توجد نتائج';

  @override
  String get nmPeopleWillAppearHere => 'سيظهر هنا الأشخاص الذين يكتشفهم جهازك.';

  @override
  String get nmInRange => 'في النطاق';

  @override
  String get nmDirectConnection => 'اتصال مباشر';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عبر $count مُرحِّل',
      many: 'عبر $count مُرحِّلًا',
      few: 'عبر $count مُرحِّلات',
      two: 'عبر مُرحِّلين',
      one: 'عبر مُرحِّل واحد',
      zero: 'بدون مُرحِّلات',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'الملف كبير جدًا (الحد الأقصى 50 ميغابايت)';

  @override
  String get chCannotReadMedia => 'تعذر قراءة هذا الملف';

  @override
  String get chLocationDenied =>
      'تم رفض الوصول إلى الموقع — فعّله في إعدادات هاتفك لمشاركة موقعك.';

  @override
  String get chGettingPosition => 'جارٍ تحديد الموقع…';

  @override
  String get chPositionUnavailable =>
      'الموقع غير متاح — أعد المحاولة في مكان مكشوف.';

  @override
  String get chMicPermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get chCannotStartRecording => 'تعذر بدء التسجيل';

  @override
  String get chVoiceSendFailed => 'تعذر إرسال الرسالة الصوتية';

  @override
  String get chFileSendFailed => 'تعذر إرسال الملف';

  @override
  String get chAudioNotFullyReceived => 'لم يتم استلام الصوت بالكامل بعد';

  @override
  String get chVoiceUnreadable =>
      'لا يمكن تشغيل هذه الرسالة الصوتية — ربما وصلت غير مكتملة.';

  @override
  String get chFileNotFullyReceived => 'لم يتم استلام الملف بالكامل بعد';

  @override
  String get chSaveFailed => 'تعذر الحفظ';

  @override
  String chSavedIn(Object folder) {
    return 'تم الحفظ في $folder';
  }

  @override
  String get chMessageCopied => 'تم نسخ الرسالة';

  @override
  String get chCallImpossibleRelay =>
      'لا يمكن إجراء مكالمة صوتية: يمكن الوصول إلى هذا القرين فقط عبر الترحيل أو البلوتوث، وهو بطيء جدًا للصوت. اقترب للتبديل إلى واي فاي.';

  @override
  String chUrlCopied(Object url) {
    return 'تم نسخ الرابط: $url';
  }

  @override
  String get chEditMessageTitle => 'تعديل الرسالة';

  @override
  String get chMessageHint => 'رسالة';

  @override
  String get chNeverMet => 'لم يُقابَل قط';

  @override
  String get chSeenJustNow => 'شوهد للتو';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شوهد منذ $count دقيقة',
      many: 'شوهد منذ $count دقيقة',
      few: 'شوهد منذ $count دقائق',
      two: 'شوهد منذ دقيقتين',
      one: 'شوهد منذ دقيقة',
      zero: 'شوهد منذ أقل من دقيقة',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شوهد منذ $count ساعة',
      many: 'شوهد منذ $count ساعة',
      few: 'شوهد منذ $count ساعات',
      two: 'شوهد منذ ساعتين',
      one: 'شوهد منذ ساعة',
      zero: 'شوهد منذ أقل من ساعة',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'شوهد أمس';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شوهد منذ $count يوم',
      many: 'شوهد منذ $count يومًا',
      few: 'شوهد منذ $count أيام',
      two: 'شوهد منذ يومين',
      one: 'شوهد منذ يوم',
      zero: 'شوهد منذ أقل من يوم',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'خارج النطاق';

  @override
  String get chCloseSearchTooltip => 'إغلاق البحث';

  @override
  String get chNetworkDetailsSemantics => 'شبكة Droplet، عرض التفاصيل';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'يكتب الآن…';

  @override
  String get chBroadcastChannel => 'قناة البث';

  @override
  String get chNearby => 'بالقرب';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يمكن الوصول عبر $count مُرحِّل',
      many: 'يمكن الوصول عبر $count مُرحِّلًا',
      few: 'يمكن الوصول عبر $count مُرحِّلات',
      two: 'يمكن الوصول عبر مُرحِّلين',
      one: 'يمكن الوصول عبر مُرحِّل واحد',
      zero: 'غير قابل للوصول عبر أي مُرحِّل',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'إعادة الاتصال…';

  @override
  String get chSearchInConversation => 'البحث في المحادثة';

  @override
  String get chVoiceCall => 'مكالمة صوتية';

  @override
  String get chVideoCall => 'مكالمة فيديو';

  @override
  String get chCallImpossibleBtRelay =>
      'لا يمكن إجراء المكالمة: اتصال بلوتوث أو مُرحَّل';

  @override
  String get chGroupInfoTooltip => 'معلومات المجموعة';

  @override
  String get chNoneFound => 'لا شيء';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'نتيجة أقدم';

  @override
  String get chNewerResult => 'نتيجة أحدث';

  @override
  String get chLoadingOlderMessages => 'جارٍ تحميل الرسائل السابقة…';

  @override
  String get chToday => 'اليوم';

  @override
  String get chYesterday => 'أمس';

  @override
  String get chMonday => 'الاثنين';

  @override
  String get chTuesday => 'الثلاثاء';

  @override
  String get chWednesday => 'الأربعاء';

  @override
  String get chThursday => 'الخميس';

  @override
  String get chFriday => 'الجمعة';

  @override
  String get chSaturday => 'السبت';

  @override
  String get chSunday => 'الأحد';

  @override
  String get chSayHello => 'قل مرحبًا 👋';

  @override
  String get chBroadcastEmptyBody => 'تظهر هنا الرسائل التي ليس لها مستلم.';

  @override
  String get chP2pRelayedBody =>
      'يتم ترحيل تبادلاتكما من جهاز إلى آخر، دون إنترنت.';

  @override
  String get chReply => 'الرد';

  @override
  String get chReplyInThread => 'الرد داخل السلسلة';

  @override
  String get chCopy => 'نسخ';

  @override
  String get chAccessibilityMe => 'أنا';

  @override
  String get chPhotoLabel => 'صورة';

  @override
  String get chVideoLabel => 'فيديو';

  @override
  String get chVoiceMessageLabel => 'رسالة صوتية';

  @override
  String chFileLabel(Object name) {
    return 'ملف $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'ملصق $name';
  }

  @override
  String get chSendingStatus => 'جارٍ الإرسال';

  @override
  String get chPendingStatus => 'قيد الانتظار';

  @override
  String get chFailedStatus => 'فشل الإرسال';

  @override
  String get chReadStatus => 'مقروءة';

  @override
  String get chDeliveredStatus => 'تم التسليم';

  @override
  String get chSentStatus => 'تم الإرسال';

  @override
  String get chForwarded => 'مُعاد توجيهها';

  @override
  String get chRetrySendLabel => 'إعادة محاولة الإرسال';

  @override
  String get chTransmissionDetailsLabel => 'تفاصيل الإرسال';

  @override
  String get chEditedBadge => 'مُعدَّلة';

  @override
  String get chFileWord => 'ملف';

  @override
  String chSizeBytes(Object n) {
    return '$n بايت';
  }

  @override
  String chSizeKb(Object n) {
    return '$n كيلوبايت';
  }

  @override
  String chSizeMb(Object n) {
    return '$n ميغابايت';
  }

  @override
  String get chVideoReceiving => 'جارٍ استلام الفيديو';

  @override
  String get chPreparingVideo => 'جارٍ تجهيز الفيديو…';

  @override
  String get nmContacts => 'جهات الاتصال';

  @override
  String get nmFindByPseudo => 'البحث بالاسم';

  @override
  String get nmViaInternet => 'عبر الإنترنت';

  @override
  String get nmOutOfRange => 'خارج النطاق';

  @override
  String get chatsInvitePerson => 'دعوة شخص';

  @override
  String get ivTitle => 'ادعُ أحبّاءك';

  @override
  String get ivSubtitle =>
      'Droplet أفضل عندما يكون من يهمّك هنا، حتى دون شبكة.';

  @override
  String get ivByNumber => 'عبر رقم الهاتف';

  @override
  String get ivNumberHint => 'الرقم مع رمز الدولة (+966…)';

  @override
  String get ivContacts => 'جهات الاتصال';

  @override
  String get ivSms => 'رسالة SMS';

  @override
  String get ivWhatsapp => 'واتساب';

  @override
  String get ivByLink => 'عبر رابط';

  @override
  String get ivCopy => 'نسخ';

  @override
  String get ivShare => 'مشاركة';

  @override
  String get ivCopied => 'تم نسخ الرابط';

  @override
  String get ivByQr => 'عبر رمز QR';

  @override
  String get ivQrHint => 'دع الشخص يمسحه وجهًا لوجه.';

  @override
  String get ivScan => 'مسح رمز';

  @override
  String get ivPrivacy =>
      'لا يحتوي الرابط والرمز إلا على معرّفك العام ومفتاحك. لا يُرسَل أي رقم إلى Droplet.';

  @override
  String get evTitle => 'تعديل الفيديو';

  @override
  String evSplit(int n) {
    return 'تقسيم إلى $n حالات';
  }

  @override
  String evSplitHint(int s) {
    return 'كل جزء $s ث كحد أقصى';
  }

  @override
  String evPublished(int n) {
    return 'تم نشر $n حالات';
  }

  @override
  String get svReply => 'رد';

  @override
  String get svStatusLabel => 'الحالة';

  @override
  String svSeenBy(int n) {
    return 'شاهده $n';
  }

  @override
  String get clMissedVoice => 'مكالمة صوتية فائتة';

  @override
  String get clMissedVideo => 'مكالمة فيديو فائتة';

  @override
  String get clCallBack => 'معاودة الاتصال';

  @override
  String get stoTitle => 'التخزين';

  @override
  String get stoSubtitle => 'الصور والفيديوهات والملفات';

  @override
  String stoUsed(String taille) {
    return '$taille مستخدمة';
  }

  @override
  String get stoPhotos => 'الصور';

  @override
  String get stoVideos => 'الفيديوهات';

  @override
  String get stoAudio => 'الصوت';

  @override
  String get stoDocuments => 'المستندات';

  @override
  String get stoOther => 'أخرى (الحالات…)';

  @override
  String get stoByChat => 'حسب المحادثة';

  @override
  String get stoEmpty => 'لا توجد ملفات على هذا الهاتف';

  @override
  String stoDelete(int n) {
    return 'حذف ($n)';
  }

  @override
  String get stoDeleteConfirm => 'سيتم حذف هذه الملفات ورسائلها من هذا الهاتف.';

  @override
  String get tabSelectChat => 'اختر محادثة';

  @override
  String get clConnecting => 'جارٍ الاتصال…';

  @override
  String chUnreadMessages(int n) {
    return '$n رسالة غير مقروءة';
  }

  @override
  String get csMessagesSection => 'الرسائل';

  @override
  String chGroupTyping(String noms) {
    return '$noms يكتب…';
  }

  @override
  String get tsReadBy => 'قرأها';

  @override
  String get tsDeliveredTo => 'وصلت إلى';

  @override
  String get tsWaitingFor => 'بالانتظار';

  @override
  String get chSelect => 'تحديد';

  @override
  String get chForward => 'إعادة توجيه';

  @override
  String get chForwardTo => 'إعادة التوجيه إلى…';

  @override
  String chSelectedCount(int n) {
    return '$n محدد';
  }

  @override
  String get chForwarded1 => 'تمت إعادة توجيه الرسالة';

  @override
  String get apCaptionHint => 'أضف تعليقًا…';

  @override
  String get apValidateCrop => 'قص';

  @override
  String get chMediaReceiving => 'جارٍ الاستلام';

  @override
  String get chStickersTooltip => 'ملصقات';

  @override
  String get chAttachTooltip => 'إرفاق';

  @override
  String get chDeleteRecordingTooltip => 'حذف التسجيل';

  @override
  String get chSlideToCancel => 'اسحب للإلغاء';

  @override
  String chReplyingTo(Object pseudo) {
    return 'الرد على $pseudo';
  }

  @override
  String get chEffectBoom => 'بوووم';

  @override
  String get chEffectLoud => 'بصوت عالٍ';

  @override
  String get chEffectGentle => 'لطيف';

  @override
  String get chEffectInvisibleInk => 'حبر غير مرئي';

  @override
  String get chEffectConfetti => 'قصاصات ورقية';

  @override
  String get chEffectFireworks => 'ألعاب نارية';

  @override
  String get chEffectHearts => 'قلوب';

  @override
  String get chEffectSheetTitle => 'تأثير الرسالة';

  @override
  String get chEffectSheetSubtitle => 'يُعرض مرة واحدة، على شاشتك وشاشة محدثك';

  @override
  String get chOnBubble => 'على الفقاعة';

  @override
  String get chFullscreen => 'ملء الشاشة';

  @override
  String get chTapToReveal => 'اضغط للكشف';

  @override
  String get chThreadTitle => 'سلسلة المحادثة';

  @override
  String get chReplyHint => 'الرد…';

  @override
  String get chCollapse => 'طي';

  @override
  String get chSeeMore => 'عرض المزيد';

  @override
  String get chMessageOptionsSemantics => 'خيارات الرسالة';

  @override
  String get chLoveReactionSemantics => 'أعجبني كثيرًا';

  @override
  String get chBroadcastMesh => 'بث الشبكة';

  @override
  String get chGroupFallback => 'مجموعة';

  @override
  String get ciSetupBiometrics =>
      'قم بإعداد بصمة الإصبع أو Face ID في إعدادات جهازك.';

  @override
  String get ciEnableLockReason => 'تفعيل القفل لهذه المحادثة';

  @override
  String get ciInfoTitle => 'معلومات';

  @override
  String get ciViewConversation => 'عرض المحادثة';

  @override
  String get ciGatewayOnline => 'بوابة · متصل';

  @override
  String get ciOnline => 'متصل';

  @override
  String get ciOffline => 'غير متصل';

  @override
  String get ciMessages => 'الرسائل';

  @override
  String get ciMedia => 'الوسائط';

  @override
  String get ciStart => 'البداية';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الصور ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الملاحظات الصوتية ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الملفات ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'لم تتم مشاركة أي وسائط حتى الآن.';

  @override
  String get ciSecurityCode => 'رمز الأمان';

  @override
  String get ciVerified => 'تم التحقق';

  @override
  String get ciKeyChanged => 'لقد تغيّر المفتاح';

  @override
  String get ciNotVerified => 'غير موثّق';

  @override
  String get ciConversationLock => 'قفل المحادثة';

  @override
  String get ciLockEnabled => 'مفعّل — بصمة الإصبع مطلوبة للفتح';

  @override
  String get ciDisabled => 'معطّل';

  @override
  String get ciEphemeralMessages => 'الرسائل المؤقتة';

  @override
  String get ci30Seconds => '30 ثانية';

  @override
  String get ci5Minutes => '5 دقائق';

  @override
  String get ci1Hour => 'ساعة واحدة';

  @override
  String get ci24Hours => '24 ساعة';

  @override
  String get ciDurationBeforeDisappear => 'المدة قبل الاختفاء';

  @override
  String get ciBlockContactTitle => 'هل تريد حظر جهة الاتصال هذه؟';

  @override
  String ciBlockContactBody(Object pseudo) {
    return 'لن يتمكن $pseudo من إرسال رسائل إليك بعد الآن. يمكنك إلغاء الحظر عنه في أي وقت.';
  }

  @override
  String get ciBlock => 'حظر';

  @override
  String get ciUnblock => 'إلغاء الحظر';

  @override
  String ciContactBlocked(Object pseudo) {
    return 'تم حظر $pseudo';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return 'تم إلغاء حظر $pseudo';
  }

  @override
  String get ciReportContactTitle => 'هل تريد الإبلاغ عن جهة الاتصال هذه؟';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'سيتم إرسال بلاغ مجهول الهوية إلى Droplet: معرّف تقني والسبب المختار أدناه فقط، لا شيء آخر. لا تُرسل أي رسالة أو محادثة مع $pseudo أبدًا.';
  }

  @override
  String get ciReport => 'الإبلاغ';

  @override
  String get ciReportSent => 'تم إرسال البلاغ. شكرًا لك.';

  @override
  String get ciReportFailed => 'تعذّر إرسال البلاغ — حاول مرة أخرى لاحقًا.';

  @override
  String get ciReportReasonSpam => 'رسائل مزعجة';

  @override
  String get ciReportReasonHarassment => 'مضايقة';

  @override
  String get ciReportReasonIllegal => 'محتوى غير قانوني';

  @override
  String get ciReportReasonOther => 'أخرى';

  @override
  String mcReactWith(Object emoji) {
    return 'التفاعل بـ $emoji';
  }

  @override
  String get nsMeshActive => 'الشبكة نشطة';

  @override
  String get nsNoDeviceInRange => 'لا يوجد جهاز في النطاق';

  @override
  String get nsMessagesCirculate =>
      'تنتقل رسائلك من جهاز إلى آخر، دون المرور عبر الإنترنت.';

  @override
  String get nsGetCloser =>
      'اقترب من جهاز Droplet آخر. يتم الاحتفاظ برسائلك وستُرسَل تلقائيًا.';

  @override
  String get nsDevicesInRange => 'الأجهزة في النطاق';

  @override
  String get nsReconnectingTitle => 'إعادة الاتصال';

  @override
  String get nsLinkMomentarilyLost =>
      'انقطع الاتصال مؤقتًا، ولم يُتخلَّ عنه بعد.';

  @override
  String get nsRelaysAvailable => 'المُرحِّلات المتاحة';

  @override
  String get nsNoRelayAvailable =>
      'لا يوجد حاليًا أي جهاز يمكنه إعادة توجيه رسائلك لمسافة أبعد.';

  @override
  String get nsViaBluetooth => 'عبر البلوتوث';

  @override
  String get nsViaLocalWifi => 'عبر واي فاي محلي';

  @override
  String get nsWifiCarriesMore =>
      'ينقل الواي فاي الملفات والصوت؛ بينما ينقل البلوتوث النص فقط.';

  @override
  String get scInvalidQrCode => 'رمز QR غير صالح';

  @override
  String get scWrongCode => 'هذا ليس الرمز الصحيح — المفتاح غير مطابق';

  @override
  String get scCodeVerified => 'تم التحقق من الرمز';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'تم التحقق — مفتاح $pseudo يطابق هذا الرمز.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'تغيّر مفتاح $pseudo منذ آخر عملية تحقق.';
  }

  @override
  String get scNotVerifiedYet => 'لم يتم التحقق بعد.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'قارن هذا الرمز بالرمز الظاهر على جهاز $pseudo، أو امسح رمز QR الخاص به مباشرة للتحقق تلقائيًا.';
  }

  @override
  String get scContactKeyUnknown =>
      'مفتاح جهة الاتصال غير معروف بعد — أعد الاتصال بهذا القرين على الشبكة.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'مسح رمز $pseudo';
  }

  @override
  String get tsNotDelivered => 'لم يتم التسليم';

  @override
  String get tsRead => 'مقروءة';

  @override
  String get tsDelivered => 'تم التسليم';

  @override
  String get tsSendingInProgress => 'جارٍ الإرسال';

  @override
  String get tsWaitingForRelay => 'في انتظار مُرحِّل';

  @override
  String get tsSent => 'تم الإرسال';

  @override
  String tsSecondsSingular(Object value) {
    return '$value ثانية';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value ثوانٍ';
  }

  @override
  String tsMinutes(Object n) {
    return '$n د';
  }

  @override
  String tsHours(Object n) {
    return '$n س';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'أقل من يوم',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'الإرسال';

  @override
  String get tsStatus => 'الحالة';

  @override
  String get tsDelayUntilRead => 'المدة حتى القراءة';

  @override
  String get tsRoute => 'المسار';

  @override
  String get tsRouteDetail => 'الأجهزة التي قامت بترحيل هذه الرسالة، بالترتيب.';

  @override
  String get tsPath => 'المسار';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مرّ عبر $count جهاز',
      many: 'مرّ عبر $count جهازًا',
      few: 'مرّ عبر $count أجهزة',
      two: 'مرّ عبر جهازين',
      one: 'مرّ عبر جهاز واحد',
      zero: 'لم يمر بأي جهاز',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'تم الاستلام مباشرة';

  @override
  String get tsIntermediateDevicesDetail =>
      'قامت أجهزة وسيطة بترحيل هذه الرسالة إليك.';

  @override
  String get tsUnknown => 'غير معروف';

  @override
  String get tsSentRouteNotReturned =>
      'لا يُرسَل مسار الرسالة المُرسَلة مرة أخرى إلى مُرسِلها.';

  @override
  String get tsNetwork => 'الشبكة';

  @override
  String get tsMeshDroplet => 'شبكة Droplet';

  @override
  String get tsNoServerNoOperator => 'لا يوجد خادم، ولا مشغّل شبكة.';

  @override
  String get qsScanSecurityCode => 'مسح رمز الأمان';

  @override
  String get qsCodeDetected => 'تم اكتشاف الرمز';

  @override
  String get qsFrameQrCode => 'ضع في الإطار رمز QR المعروض على جهاز جهة اتصالك';

  @override
  String get rmRecentVideo => 'فيديو حديث';

  @override
  String get rmRecentPhoto => 'صورة حديثة';

  @override
  String get rmSeeAllPhotos => 'عرض جميع الصور';

  @override
  String get rmSeeAll => 'عرض الكل';

  @override
  String get aicOriginal => 'الأصلية';

  @override
  String get aicAzure => 'سماوي';

  @override
  String get aicNeon => 'نيون';

  @override
  String get aicPaper => 'ورقي';

  @override
  String get aicLagoon => 'بحيرة';

  @override
  String get aicAmethyst => 'جمشت';

  @override
  String get aicGold => 'ذهبي';

  @override
  String get aicTide => 'مد وجزر';

  @override
  String get aicDawn => 'فجر';

  @override
  String get aicGlass => 'زجاجي';

  @override
  String get aicConstellation => 'كوكبة';

  @override
  String get aicPrism => 'منشور';

  @override
  String get aicEmerald => 'زمردي';

  @override
  String get aicChangeIconTitle => 'هل تريد تغيير الأيقونة؟';

  @override
  String aicChangeIconMessage(Object name) {
    return 'ستحل أيقونة «$name» محل الأيقونة الموجودة على شاشتك الرئيسية. تستغرق بعض المشغلات ثوانٍ قليلة لعرضها، أو تطلب العودة إلى الشاشة الرئيسية.';
  }

  @override
  String get aicApply => 'تطبيق';

  @override
  String aicIconApplied(Object name) {
    return 'تم تطبيق أيقونة «$name»';
  }

  @override
  String get aicChangeIconImpossible => 'لا يمكن تغيير الأيقونة على هذا الجهاز';

  @override
  String get aicTitle => 'الأيقونة';

  @override
  String get aicCurrentOnHomeScreen => 'الأيقونة الظاهرة على شاشتك الرئيسية';

  @override
  String get aicUnavailablePlatform => 'غير متاح على هذه المنصة';

  @override
  String get aicAndroidExplanation =>
      'يقوم Android بتثبيت أيقونة التطبيق عند التثبيت. يتجاوز Droplet ذلك بإعلان عدة نقاط دخول، واحدة لكل أيقونة، وإبقاء واحدة فقط نشطة. قد يستغرق مشغلك بضع ثوانٍ ليلاحظ ذلك.';

  @override
  String get aicAndroidOnly => 'تغيير الأيقونة متاح فقط على أندرويد.';

  @override
  String get beWeak => 'ضعيفة';

  @override
  String get beOkay => 'مقبولة';

  @override
  String get beStrong => 'قوية';

  @override
  String get bePasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get bePasswordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get beBackupSubject => 'نسخة احتياطية من Droplet';

  @override
  String get beBackupShareText =>
      'نسخة احتياطية مشفّرة من هويتي على Droplet — احتفظ بها في مكان آمن.';

  @override
  String get beBackupCreated => 'تم إنشاء النسخة الاحتياطية';

  @override
  String get beBackupFailed => 'فشل إنشاء النسخة الاحتياطية';

  @override
  String get beBackupMyIdentity => 'نسخ هويتي احتياطيًا';

  @override
  String get beWarningBody =>
      'يمكن لأي شخص يمتلك هذا الملف وكلمة المرور أن ينتحل شخصيتك. احتفظ به في مكان آمن (لا ترسله أبدًا إلى أي شخص سواك) واختر كلمة مرور لا يعرفها سواك.';

  @override
  String get bePasswordProtects =>
      'تحمي كلمة المرور هذه نسختك الاحتياطية. لا يتم حفظها أبدًا: بدونها، يصبح الملف غير قابل للاستخدام نهائيًا.';

  @override
  String get bePassword => 'كلمة المرور';

  @override
  String get beConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get beIncludeMessageHistory => 'تضمين سجل الرسائل';

  @override
  String get beOtherwiseOnlyIdentity =>
      'بخلاف ذلك، لن يتم حفظ سوى الهوية وجهات الاتصال والمجموعات';

  @override
  String get beCreateAndShare => 'إنشاء النسخة الاحتياطية ومشاركتها';

  @override
  String get jsErrorJournalTitle => 'سجل الأخطاء';

  @override
  String get jsNoErrorsRecorded =>
      'لم يتم تسجيل أي أخطاء. هذه هي الحالة الطبيعية.';

  @override
  String get jsLinesStayOnDevice =>
      'تبقى هذه السطور على هذا الجهاز: لا يمتلك Droplet أي خادم لإرسالها إليه. إذا كنت تختبر التطبيق، يُرجى إرسالها — فبدونها، لا يوجد الخلل بالنسبة لأحد.';

  @override
  String get jsErase => 'مسح';

  @override
  String get jsShareSubject => 'Droplet — سجل الأخطاء';

  @override
  String get jsShareText =>
      'سجل أخطاء Droplet. لا يحتوي هذا الملف على أي رسائل أو جهات اتصال أو مفاتيح.';

  @override
  String get jsShareUnavailable => 'المشاركة غير متاحة — تم نسخ السجل';

  @override
  String get clOutgoingCall => 'جارٍ الاتصال…';

  @override
  String get clIncomingCall => 'مكالمة واردة…';

  @override
  String get clCallImpossible => 'تعذر إجراء المكالمة';

  @override
  String get clCallEnded => 'انتهت المكالمة';

  @override
  String clCallWith(Object pseudo) {
    return 'مكالمة مع $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'مشفّر من طرف إلى طرف';

  @override
  String clCallStatusSemantics(Object status) {
    return 'حالة المكالمة: $status';
  }

  @override
  String get clEnableMic => 'تفعيل الميكروفون';

  @override
  String get clMuteMic => 'كتم الميكروفون';

  @override
  String get clDisableSpeaker => 'إيقاف مكبر الصوت';

  @override
  String get clEnableSpeaker => 'تفعيل مكبر الصوت';

  @override
  String get clDisableCamera => 'إيقاف الكاميرا';

  @override
  String get clEnableCamera => 'تفعيل الكاميرا';

  @override
  String get clHangUp => 'إنهاء المكالمة';

  @override
  String get clIncomingVideoCall => 'مكالمة فيديو واردة';

  @override
  String get clSwitchCamera => 'تبديل الكاميرا';

  @override
  String get gcGroupCall => 'مكالمة جماعية';

  @override
  String get gcConnecting => 'جارٍ الاتصال…';

  @override
  String get gcOnline => 'متصل';

  @override
  String get gcFailed => 'فشل';

  @override
  String get gcDisconnected => 'غير متصل';

  @override
  String get gcReturnToCall => 'العودة إلى المكالمة';

  @override
  String get gcMinimize => 'تصغير';

  @override
  String get gcVoiceOnly => 'صوت فقط';

  @override
  String gcReactWith(String emoji) {
    return 'التفاعل بـ $emoji';
  }

  @override
  String get gcSpeakingNow => 'يتحدث الآن';

  @override
  String get gcMicOff => 'الميكروفون مغلق';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشارك · صوت فقط',
      many: '$count مشاركًا · صوت فقط',
      few: '$count مشاركين · صوت فقط',
      two: 'مشاركان · صوت فقط',
      one: 'مشارك واحد · صوت فقط',
      zero: 'لا مشاركين · صوت فقط',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'الرسائل';

  @override
  String get ntfChannelMessagesDesc => 'الرسائل الجديدة وحالات الشبكة الشبكية';

  @override
  String get ntfChannelCallsName => 'المكالمات';

  @override
  String get ntfChannelCallsDesc => 'المكالمات الواردة والفائتة';

  @override
  String get ntfChannelMeshName => 'الشبكة والطوارئ';

  @override
  String get ntfChannelMeshDesc =>
      'خدمة الشبكة الشبكية النشطة والحالات ورسائل الطوارئ';

  @override
  String get ntfReply => 'الرد';

  @override
  String get ntfYourReply => 'ردّك';

  @override
  String get ntfMarkAsRead => 'وضع علامة مقروء';

  @override
  String get ntfIncomingCall => 'مكالمة واردة';

  @override
  String get ntfAnswer => 'الرد على المكالمة';

  @override
  String get ntfDecline => 'رفض';

  @override
  String get ntfMissedCall => 'مكالمة فائتة';

  @override
  String get ntfSendFailedTitle => 'فشل الإرسال';

  @override
  String get ntfSendFailedBody =>
      'تعذّر إرسال رسالة — ستتم إعادة المحاولة بمجرد وجود جهاز نظير في النطاق.';

  @override
  String get ntfNewStatusTitle => 'حالة جديدة';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return 'نشر $pseudo حالة';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ أعجب $pseudo بحالتك';
  }

  @override
  String get ntfTapToView => 'اضغط للعرض';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 ردّ $pseudo على حالتك';
  }

  @override
  String get ntfEmergencyTitle => 'رسالة طوارئ';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return 'أرسل $pseudo رسالة \"أنا بخير\"';
  }

  @override
  String get mnAccept => 'قبول';

  @override
  String get mnMeshVoiceCall => 'مكالمة صوتية عبر الشبكة';

  @override
  String get mnGroupCallIncoming => 'مكالمة جماعية واردة';

  @override
  String mnInvitesYou(Object pseudo) {
    return 'يدعوك $pseudo';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مكالمة جماعية · $count مشارك آخر',
      many: 'مكالمة جماعية · $count مشاركًا آخر',
      few: 'مكالمة جماعية · $count مشاركين آخرين',
      two: 'مكالمة جماعية · مشاركان آخران',
      one: 'مكالمة جماعية · مشارك آخر واحد',
      zero: 'مكالمة جماعية · لا مشاركين آخرين',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'من يمكنه رؤية هذه الحالة؟';

  @override
  String get asAllContacts => 'جميع جهات اتصالي';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهة اتصال',
      many: '$count جهة اتصال',
      few: '$count جهات اتصال',
      two: 'جهتا اتصال',
      one: 'جهة اتصال واحدة',
      zero: 'لا جهات اتصال',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'باستثناء...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستبعد',
      many: '$count مستبعدًا',
      few: '$count مستبعدين',
      two: 'مستبعدان',
      one: 'مستبعد واحد',
      zero: 'لا أحد مستبعد',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'استبعاد جهات اتصال';

  @override
  String get asOnlyOption => 'فقط...';

  @override
  String get asShareWithSpecific => 'مشاركة مع جهات اتصال محددة';

  @override
  String get asNoContactsAvailable => 'لا تتوفر جهات اتصال';

  @override
  String get asConfirm => 'تأكيد';

  @override
  String get apYourPhoto => 'صورتك';

  @override
  String get apNoPhotoAccessible =>
      'لا توجد صورة يمكن الوصول إليها على هذا الجهاز.';

  @override
  String get apBrowseFiles => 'تصفح الملفات';

  @override
  String get apRecentPhoto => 'صورة حديثة';

  @override
  String get bgSkip => 'تخطي';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'الخطوة $rang من $total.';
  }

  @override
  String get csGuideNetworkTitle => 'لا يوجد أحد قريب؟ هذا أمر طبيعي';

  @override
  String get csGuideNetworkText =>
      'لا يمر Droplet عبر أي خادم: إنه يتحدث مع الهواتف الموجودة في النطاق. هنا ترى من يمكن الوصول إليه، وعبر أي تقنية لاسلكية. عدم وجود أي جهاز نظير لا يعني أن هناك عطلاً — بل فقط أنه لا يوجد أحد بعد.';

  @override
  String get csGuideWriteTitle => 'اكتب حتى بدون وجود أحد';

  @override
  String get csGuideWriteText =>
      'تنتظر رسالة كُتبت الآن على هاتفك، وتنطلق بمجرد مرور جهاز في النطاق — في الشارع أو في سيارة أجرة. إنها ليست مفقودة، بل تنتظر فقط.';

  @override
  String get csGuideBackupTitle => 'احفظ نسخة احتياطية من هويتك';

  @override
  String get csGuideBackupText =>
      'بدون خادم، لا يمكن لأحد أن يعيد إليك حسابك. صدّر هويتك من الإعدادات: بدون هذه النسخة الاحتياطية، يأخذ فقدان الهاتف كل شيء معه.';

  @override
  String get csShowLockedChatsReason => 'إظهار المحادثات المقفلة';

  @override
  String get cvlNoBiometricsConfigured =>
      'لا توجد بصمة إصبع مُعدّة على هذا الجهاز';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'إلغاء قفل المحادثة مع $pseudo';
  }

  @override
  String get cvlAuthFailed => 'فشلت المصادقة';

  @override
  String get cvlAuthError => 'خطأ في المصادقة';

  @override
  String get cvlConversationLocked => 'محادثة مقفلة';

  @override
  String get cvlUnlock => 'إلغاء القفل';

  @override
  String get dcAddText => 'إضافة نص';

  @override
  String get dcYourTextHint => 'نصّك...';

  @override
  String get pbDropletProBadge => 'شارة Droplet Pro';

  @override
  String get rpReact => 'تفاعل';

  @override
  String get rpSaveToPhone => 'حفظ على الهاتف';

  @override
  String get chViaTor => 'عبر Tor';

  @override
  String get chTorInactive => 'Tor غير نشط';

  @override
  String get chViaInternet => 'عبر الإنترنت';

  @override
  String get chReachedViaTorSemantic => 'تم الوصول إلى جهة الاتصال عبر Tor';

  @override
  String get nsTorConnectedTitle => 'متصل عبر Tor';

  @override
  String get nsTorInactiveTitle => 'Tor معطّل';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'تنتقل رسائلك عبر شبكة Tor وتنتظر في صندوق بريد مشفّر إلى أن يتصل $pseudo به.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'فعّل Tor في الإعدادات لتتمكن من الكتابة إلى $pseudo — بدونه، ستبقى رسائلك في انتظار على هذا الجهاز.';
  }

  @override
  String get nsTorMailboxTitle => 'صندوق بريد مشفّر';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'لا يمكن لا لك ولا لـ Droplet قراءة محتواها — $pseudo وحده يملك المفتاح.';
  }

  @override
  String get nsOpenTorSettings => 'تفعيل Tor';

  @override
  String get qrInvalidCode => 'رمز QR هذا ليس رمز Droplet.';

  @override
  String get qrPeerAdded => 'تمت إضافة جهة الاتصال';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'يمكنك الآن التحدث مع $pseudo';
  }

  @override
  String get clViaInternet => 'عبر الإنترنت';

  @override
  String get tsPathTorDetail =>
      'لا تمر هذه الرسالة عبر الأجهزة من حولك: بل تنتقل عبر صندوق بريد مشفّر على شبكة Tor، لا يمكن الوصول إليه إلا لكما أنتما الاثنين.';

  @override
  String get tsNetworkTorDetail =>
      'يلزم وجود خادم ترحيل للوصول إلى جهة الاتصال هذه عن بُعد — لا يمكن لتطبيق Droplet الاستغناء عنه هنا، بخلاف الشبكة الشبكية المحلية.';

  @override
  String get torSearchDirectory => 'البحث في الدليل';

  @override
  String get dvTitle => 'بحث';

  @override
  String get dvClose => 'إغلاق';

  @override
  String get dvSearchHint => 'ابحث عن اسم...';

  @override
  String get dvEnableTorToSearch => 'فعّل Tor في الإعدادات للبحث في الدليل.';

  @override
  String get dvSearching => 'جارٍ البحث...';

  @override
  String get dvNoResults => 'لا توجد نتائج';

  @override
  String get dvNoUserFound => 'لم يتم العثور على أي مستخدم لهذا البحث.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'إرسال';

  @override
  String get aiNewConversation => 'محادثة جديدة';

  @override
  String get aiMessageHint => 'رسالة';

  @override
  String get aiCopied => 'تم النسخ';

  @override
  String get aiAskQuestion => 'اطرح سؤالاً';

  @override
  String get aiRunsLocally =>
      'يعمل هذا المساعد بالكامل على جهازك — لا يُرسل شيء أبدًا عبر الإنترنت.';

  @override
  String get aiMemorySaved => 'سأتذكّر ذلك.';

  @override
  String get aiMemoryForgotten => 'نسيتُ ما طلبتَ منّي تذكّره.';

  @override
  String get aiMemoryTitle => 'ذاكرة المساعد';

  @override
  String get aiMemoryEmpty => 'لا شيء محفوظ بعد. قل «تذكّر أن…» لتثبيت معلومة.';

  @override
  String get aiMemoryForget => 'نسيان كل شيء';

  @override
  String get aiExpertHint =>
      'أعرف Droplet جيدًا: الشبكة المتداخلة، Tor، المكالمات، الخصوصية.';

  @override
  String get chAskAssistant => 'اسأل المساعد';

  @override
  String chAskAssistantInvite(Object name) {
    return 'ساعدني في الرد على $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'جارٍ تجهيز المساعد… $percentage٪';
  }

  @override
  String get aiOneTimeDownload =>
      'مرة واحدة فقط — يبقى بعد ذلك على جهازك، دون أي تنزيل آخر.';

  @override
  String get aiGenericError => 'عذرًا، حدث خطأ ما.';

  @override
  String get aiNotAvailableYet =>
      'المساعد غير متوفر بعد في هذا الإصدار من Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'تعذّر التنزيل: $error';
  }

  @override
  String get ntfSomeoneCalling => 'يحاول شخص ما التواصل معك';

  @override
  String get ntfNewMessageWake => 'رسالة جديدة — افتح Droplet لقراءتها';

  @override
  String get chNearbyAndInternet => 'قريب · إنترنت';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مُرحِّل · إنترنت',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'بانتظار الإنترنت';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بالقرب · إنترنت',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بالقرب · بلا إنترنت',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'لا أحد بالقرب · إنترنت';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi مباشر';

  @override
  String get clPathInternetDirect => 'إنترنت · مباشر';

  @override
  String get clPathInternetRelay => 'إنترنت · مُرحِّل آمن';

  @override
  String get clReconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get clLabelSpeaker => 'مكبر الصوت';

  @override
  String get clLabelCamera => 'الكاميرا';

  @override
  String get clLabelMic => 'الميكروفون';

  @override
  String get clLabelFlip => 'قلب';

  @override
  String get clEncryptedShort => 'مشفّر من طرف إلى طرف';

  @override
  String clQualitySemantics(int bars) {
    return 'جودة المكالمة: $bars من 3';
  }

  @override
  String get beOnlineTitle => 'نسخ احتياطي تلقائي عبر الإنترنت';

  @override
  String get beOnlineBody =>
      'كل يوم تُحفظ على خادم Droplet نسخة مشفّرة بكلمة المرور هذه، ولا يستطيع الخادم قراءتها. على هاتف جديد يكفي الاسم نفسه وكلمة المرور نفسها. لا تشمل الصور والفيديوهات والملفات المستلمة.';

  @override
  String get beOnlineSwitch => 'النسخ إلى الخادم كل يوم';

  @override
  String beOnlineLast(String date) {
    return 'آخر نسخة: $date';
  }

  @override
  String get beOnlineNever => 'لا توجد نسخة عبر الإنترنت بعد';

  @override
  String get beOnlineNow => 'انسخ الآن';

  @override
  String get beOnlineDone => 'تم النسخ عبر الإنترنت';

  @override
  String get beOnlineFailed => 'النسخ عبر الإنترنت غير ممكن حاليًا';

  @override
  String get obRestoreFromServer => 'الاستعادة من الخادم';

  @override
  String get obEnterPseudoFirst => 'أدخل أولًا اسم المستخدم الخاص بنسختك';

  @override
  String get obNoServerBackup => 'لا توجد نسخة لهذا الاسم وكلمة المرور';

  @override
  String get obTooManyAttempts => 'محاولات كثيرة — أعد المحاولة بعد ساعة';

  @override
  String get chatsInviteLink => 'دعوة عبر رابط';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo يدعوك إلى Droplet، تطبيق المراسلة المشفّر الذي يعمل حتى بدون شبكة: $lien';
  }

  @override
  String get invTitle => 'دعوة';

  @override
  String invBody(String pseudo) {
    return '$pseudo يدعوك للدردشة على Droplet.';
  }

  @override
  String get invAdd => 'أضف واكتب';

  @override
  String get invInvalid => 'رابط الدعوة هذا غير صالح أو غير مكتمل.';

  @override
  String get invSelf => 'هذا رابط دعوتك أنت.';
  @override
  String get seAnimationHeader => 'رسوم الإرسال المتحركة';

  @override
  String get seAnimationFull => 'كاملة';

  @override
  String get seAnimationReduced => 'مختصرة';

  @override
  String get seAnimationOff => 'معطّلة';

  @override
  String get seAnimationFullDesc => 'يحمل بليك رسالتك، وينتقل آنيًا، ثم يلوّح لك.';

  @override
  String get seAnimationReducedDesc => 'مجرّد تلاشٍ، دون حركة أو جُسيمات.';

  @override
  String get seAnimationOffDesc => 'بلا رسوم متحركة بعد الإرسال.';

  @override
  String get seAnimationReplay => 'المس للإعادة';

  @override
  String get seAnimationNone => 'بلا رسوم متحركة';

  @override
  String get seAnimationSampleIn => 'نلتقي عند الميناء؟';

  @override
  String get seAnimationSampleOut => 'أراك بعد قليل';

  @override
  String get trTitle => 'الترجمة';

  @override
  String get trOnDevice => 'ترجمة على الجهاز…';

  @override
  String get trUnknownLang => 'لغة غير معروفة';

  @override
  String get trOriginal => 'النص الأصلي';

  @override
  String get trCopy => 'نسخ';

  @override
  String get trInChat => 'في المحادثة';

  @override
  String get trRetry => 'إعادة المحاولة';

  @override
  String get trSame => 'هذه الرسالة بهذه اللغة أصلًا.';

  @override
  String get trModel => 'لم يُثبَّت نموذج هذه اللغة على الجهاز بعد.';

  @override
  String get trUnavailable => 'لا يتوفّر في هذا الجهاز محرّك ترجمة دون اتصال.';

  @override
  String get trFailed => 'لم تكتمل الترجمة.';

  @override
  String get pfMessage => 'رسالة';

  @override
  String get pfCall => 'اتصال';

  @override
  String get pfSecurity => 'الأمان';

  @override
  String get aiActCopy => 'نسخ';

  @override
  String get aiActRead => 'قراءة بصوت عالٍ';

  @override
  String get aiActStop => 'إيقاف القراءة';

  @override
  String get aiActLike => 'إجابة جيدة';

  @override
  String get aiActDislike => 'إجابة سيئة';

  @override
  String get aiActShare => 'مشاركة';

  @override
  String get aiActRegenerate => 'إعادة التوليد';

  @override
  String get aiFeedbackThanks => 'شكرًا على ملاحظاتك';

  @override
  String get intelOnlineHeader => 'الترجمة والتفريغ النصي';

  @override
  String get intelOnlineTitle => 'عبر الإنترنت عند الاتصال';

  @override
  String get intelOnlineSubtitle => 'مجاني — MyMemory أو Apple أو Google';

  @override
  String get intelOnlineFooter => 'عند التعطيل لا يمر شيء عبر الإنترنت. عند التفعيل والاتصال: يُرسَل النص المراد ترجمته إلى MyMemory؛ وعلى iPhone تُرسَل الرسالة الصوتية التي لا يستطيع الجهاز تفريغها إلى خدمة الصوت لدى Apple، ولا يكون المحتوى مشفّرًا تشفيرًا تامًا في هذا المسار. على Android يُنزَّل النموذج الصوتي فقط وتبقى الرسائل الصوتية على الهاتف. كما تتصل معاينات الروابط بالموقع المعني.';

  @override
  String get trOnline => 'ترجمة عبر الإنترنت';

  @override
  String get trOnlineNote => 'سيُرسَل النص إلى MyMemory، وهي خدمة مجانية، ولن يكون مشفّرًا تشفيرًا تامًا في هذا المسار.';

  @override
  String get trViaOnline => 'تُرجِم عبر الإنترنت بواسطة MyMemory';

  @override
  String get vnModelDownloading => 'يجري تنزيل النموذج الصوتي لهذه اللغة. أعد المحاولة بعد قليل.';

  @override
  String get vnModelNeeded => 'النموذج الصوتي لهذه اللغة غير موجود. فعّل «عبر الإنترنت عند الاتصال» في الإعدادات لتنزيله مرة واحدة.';

  @override
  String get nwStatusHeader => 'الحالة';

  @override
  String get nwAddStatus => 'إضافة حالة';

  @override
  String get nwStatusNewA11y => 'جديد';

  @override
  String svReplySent(String name) {
    return 'تم إرسال الرد إلى $name';
  }

  @override
  String get blkYouBlocked => 'لقد حظرت جهة الاتصال هذه.';

  @override
  String get blkUnblock => 'إلغاء الحظر';

  @override
  String get blkListTitle => 'جهات الاتصال المحظورة';

  @override
  String get blkNone => 'لا توجد جهات اتصال محظورة';

  @override
  String get blkFooter => 'لا تستطيع جهة الاتصال المحظورة مراسلتك أو الاتصال بك، ولا تتلقى حالاتك أو صورتك، ولا يتم إشعارها بذلك. يواصل هاتفك تمرير رسائلها الموجهة إلى أشخاص آخرين دون أن يتمكن من قراءتها: لا تعتمد الشبكة على من تحظره.';

  @override
  String blkUnblockTitle(String name) {
    return 'إلغاء حظر $name؟';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'إلغاء حظر $name للاتصال به؟';
  }

  @override
  String get nvDone => 'تم';

  @override
  String get nvBack => 'رجوع';

  @override
  String get nvForward => 'تقدم';

  @override
  String get nvShare => 'مشاركة';

  @override
  String get nvOpenInBrowser => 'فتح في المتصفح';

  @override
  String get nvReload => 'إعادة تحميل';

  @override
  String get nvCopyLink => 'نسخ الرابط';

  @override
  String get nvLinkCopied => 'تم نسخ الرابط';

  @override
  String get nvOpen => 'فتح';

  @override
  String get nvMore => 'المزيد';

  @override
  String get nvNotSecure => 'غير آمن';

  @override
  String get nvErrorTitle => 'الصفحة غير متاحة';

  @override
  String get nvErrorBody => 'تعذّر على Droplet الوصول إلى هذا الموقع. الشبكة المتداخلة لا تنقل الويب: يلزم اتصال بالإنترنت.';

  @override
  String get nvRetry => 'أعد المحاولة';

  @override
  String get ciLinks => 'الروابط';

  @override
  String get chatsFilterNearby => 'بالقرب';


  @override
  String get chProxTitle => 'يعمل Droplet حتى بدون إنترنت';

  @override
  String get chProxActive => 'توجد أجهزة Droplet في النطاق';

  @override
  String get chProxBody => 'تتناقل الهواتف القريبة الرسائل فيما بينها. كلما كثر عددكم حولكم، وصلت الرسائل أبعد.';

  @override
  String get chProxSee => 'من حولي';

  @override
  String get chStickerPreview => 'ملصق';

  @override
  String get edCrop => 'قص';

  @override
  String get edRotate => 'تدوير';

  @override
  String get edFilters => 'فلاتر';

  @override
  String get edAdjust => 'ضبط';

  @override
  String get edText => 'نص';

  @override
  String get edDraw => 'رسم';

  @override
  String get edTrim => 'اقتصاص';

  @override
  String get edBrightness => 'السطوع';

  @override
  String get edContrast => 'التباين';

  @override
  String get edSaturation => 'التشبع';

  @override
  String get edWarmth => 'الدفء';

  @override
  String get edVignette => 'تظليل الحواف';

  @override
  String get edIntensity => 'الشدة';

  @override
  String get edUndo => 'تراجع';

  @override
  String get edDone => 'تم';

  @override
  String get edTextHint => 'اكتب…';

  @override
  String get edDelete => 'حذف';

  @override
  String get edOriginal => 'الأصلي';

  @override
  String get edStyle => 'النمط';

  @override
  String get edBackground => 'خلفية';

  @override
  String get stNotificationsHeader => 'الإشعارات';

  @override
  String get stNotifPreview => 'معاينة المحتوى';

  @override
  String get stNotifPreviewSubtitle => 'يظهر نص الرسالة في الإشعار. عند الإيقاف، تكتفي شاشة القفل بالإعلان عن رسالة جديدة.';

  @override
  String get stSearchHint => 'ابحث في الإعدادات';

  @override
  String get stSearchEmpty => 'لا يوجد إعداد مطابق';

  @override
  String get chMentionAllSubtitle => 'تنبيه الجميع';

  @override
  String get vuOnce => 'عرض مرة واحدة';

  @override
  String get vuOpened => 'تم فتحها';

  @override
  String get vuPhoto => 'صورة';

  @override
  String get vuVideo => 'فيديو';

  @override
  String get vuMissing => 'لم يصل هذا الملف بعد';

  @override
  String get pollClosed => 'انتهى الاستطلاع';

  @override
  String pollEndsAt(String quand) {
    return 'ينتهي في $quand';
  }

  @override
  String get vuVoice => 'رسالة صوتية';

  @override
  String get apPatternsHeader => 'نقشة الخلفية';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'ألعاب';

  @override
  String get apPatternHome => 'المنزل';

  @override
  String get apPatternGarden => 'الحديقة';

  @override
  String get imTitle => 'الرسائل المهمة';

  @override
  String get imSubtitle => 'ما احتفظت به';

  @override
  String get imAdd => 'وضع نجمة';

  @override
  String get imRemove => 'إزالة النجمة';

  @override
  String get imAdded => 'أُضيفت إلى المهمة';

  @override
  String get imRemoved => 'أُزيلت من المهمة';

  @override
  String get imEmptyBody => 'اضغط مطوّلاً على رسالة لوضع نجمة عليها وتجدها هنا لاحقاً.';

  @override
  String get imClearAll => 'إزالة الكل';

  @override
  String get imClearAllBody => 'تبقى الرسائل في محادثاتها، وتُزال النجوم فقط.';

  @override
  String get imClear => 'إزالة';

  @override
  String get imYou => 'أنت';

  @override
  String get imUnknown => 'رسالة';

  @override
  String get apPatternsFooter => 'تظهر النقشة خلف كل محادثاتك.';

  @override
  String get grCreatedNoMessages => 'أُنشئت المجموعة · لا رسائل';

  @override
  String get chatsDelete => 'حذف المحادثة';

  @override
  String get chatsDeleteBody => 'تختفي الرسائل من هذا الهاتف. بلا خادم، لا أحد يستطيع حذفها من أجهزة الآخرين.';

  @override
  String get chatsDeleteConfirm => 'حذف';

  @override
  String get chatsDeleted => 'حُذفت المحادثة';

  @override
  String chatsDeleteTitle(String nom) {
    return 'حذف المحادثة مع $nom؟';
  }

  @override
  String get chatsDocument => 'مستند';

  @override
  String get epTitle => 'الرسائل المؤقتة';

  @override
  String get epHeadline => 'فعّل الرسائل المؤقتة في هذه المحادثة';

  @override
  String get epBody => 'ستحمل الرسائل الجديدة تاريخ انتهائها: تختفي من الهاتفين بعد المدة المختارة.';

  @override
  String get epDelayHeader => 'المدة قبل الاختفاء';

  @override
  String get epHours24 => '24 ساعة';

  @override
  String get epDays7 => '7 أيام';

  @override
  String get epDays90 => '90 يوماً';

  @override
  String get epOff => 'لا';

  @override
  String get epFooter => 'لا يغيّر هذا الإعداد الرسائل المُرسلة سابقاً: تحتفظ كل رسالة بمدتها الأصلية.';

  @override
  String get chOnlineNow => 'متصل · إنترنت';

  @override
  String chInternetMinutesAgo(int count) {
    return 'عبر الإنترنت قبل $count دقيقة';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'عبر الإنترنت قبل $count ساعة';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'عبر الإنترنت قبل $count يوم';
  }

  @override
  String get pdfMissing => 'هذا المستند ليس على هذا الهاتف.';

  @override
  String get pdfUnreadable => 'تعذّرت قراءة ملف PDF — ربما وصل ناقصاً.';

  @override
  String get giDescription => 'الوصف';

  @override
  String get giDescriptionAdd => 'أضف وصفاً';

  @override
  String get giDescriptionNone => 'لا يوجد وصف';

  @override
  String get giDescriptionHint => 'عمّ تدور هذه المجموعة؟';

  @override
  String get giOnlyAdminsSend => 'المشرفون فقط يكتبون';

  @override
  String get giOnlyAdminsSendBody => 'يقرأ بقية الأعضاء دون إمكانية الرد.';

  @override
  String get giSearchMembers => 'ابحث عن عضو';

  @override
  String get chOnlyAdminsCanWrite => 'يمكن للمشرفين فقط الكتابة في هذه المجموعة';

  @override
  String grCreatedBy(String nom) {
    return 'أنشأ $nom المجموعة';
  }

  @override
  String grAddedYou(String nom) {
    return 'أضافك $nom';
  }

  @override
  String grMemberGone(String nom) {
    return 'لم يعد $nom في المجموعة';
  }

  @override
  String grAdded(String qui, String nom) {
    return 'أضاف $qui المستخدم $nom';
  }

  @override
  String get giQrInvite => 'رمز QR';

  @override
  String get giQrRenew => 'رمز جديد';

  @override
  String get giQrRenewed => 'أُنشئ رمز جديد، والقديم لم يعد صالحاً';

  @override
  String get giQrExpired => 'انتهت صلاحية هذا الرمز';

  @override
  String get giQrExplainer => 'لا يحتوي هذا الرمز على أي مفاتيح. يتيح فقط طلب الانضمام، والقرار لهاتفك.';

  @override
  String get giQrAlreadyMember => 'أنت بالفعل في هذه المجموعة';

  @override
  String get giQrNeedContact => 'أضف أولاً الشخص الذي يدعوك';

  @override
  String get giQrRequestFailed => 'تعذّر إرسال الطلب';

  @override
  String giQrRequestSent(String nom) {
    return 'أُرسل الطلب إلى $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'صالح $count ساعة أخرى';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'صالح $count دقيقة أخرى';
  }

  @override
  String get cvNearby => 'قريب';

  @override
  String get cvInternet => 'إنترنت';

  @override
  String get cvWaiting => 'في الانتظار';

  @override
  String get cvOutOfReach => 'خارج النطاق';

  @override
  String get chWillSendWhenNearby => 'سيُرسل فور دخوله النطاق';

  @override
  String cvHops(int count) {
    return '$count قفزات';
  }

  @override
  String get nwSeenSection => 'شُوهدت';

  @override
  String get nwReceivedHeader => 'المستلمة';

  @override
  String get avTranslateTitle => 'الترجمة';

  @override
  String get avTranslateShort => 'الفهم دون مغادرة التطبيق';

  @override
  String get avTranslateLong => 'تُترجم الرسالة على هاتفك: لا يصل محتواها إلى أحد، ولا حتى إلى خدمة ترجمة. يبقى الأصل على بُعد لمسة، لأن الترجمة ليست النص تمامًا أبدًا.';

  @override
  String get apStickerQ => 'هل لديك ملصق لهذا؟';

  @override
  String get apOnline => 'متصل';

  @override
  String get apMessage => 'رسالة';

  @override
  String get apAutoTranslated => 'تُرجم تلقائيًا';

  @override
  String get apBgSend => 'انظر إلى هذه الخلفية 😍';

  @override
  String get apBgA => 'هل غيّرت شيئًا؟';

  @override
  String get apBgB => 'تتحرّك مع كل رسالة 😮';

  @override
  String get apFormatQ => 'أين نلتقي؟';

  @override
  String get apFormatDemo => 'نلتقي **الساعة 6 مساءً** أمام __السوق الكبير__، الرمز `4821`. مفاجأة: ||كعكة||';

  @override
  String get apVoiceQ => 'أين أنت؟';

  @override
  String get apVoiceText => 'أنا أمام الصيدلية، سأنتظرك حتى السادسة مساءً.';

  @override
  String get apTransQ => 'مرحبًا، هل كل شيء جاهز؟';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'نعم! نلتقي غدًا في المطار، البوابة 12 الساعة 9 صباحًا.';

  @override
  String get hlpDataOnDevice => 'على هاتفك';

  @override
  String get hlpDataServers => 'ما يمرّ عبر خادم';

  @override
  String get hlpDataServersFooter => 'من دون إنترنت لا يتدخّل أيّ من هذه الخوادم: الهواتف تتحدّث مباشرة.';

  @override
  String get hlpDataNone => 'ما لا يطلبه Droplet أبدًا';

  @override
  String get hlpRowKeys => 'هويّتك';

  @override
  String get hlpRowKeysBody => 'زوج مفاتيح صُنع هنا، ولم يُرسل قط';

  @override
  String get hlpRowMessages => 'رسائلك';

  @override
  String get hlpRowMessagesBody => 'في المساحة الخاصة بالتطبيق، تُمحى عند إلغاء التثبيت';

  @override
  String get hlpRowProfile => 'الاسم والصورة';

  @override
  String get hlpRowProfileBody => 'لا تصل إلا لمن تراسلهم';

  @override
  String get hlpRowSettings => 'إعداداتك';

  @override
  String get hlpRowSettingsBody => 'الخلفية واللغة والإشعارات — كلّها تبقى هنا';

  @override
  String get hlpRowLog => 'سجلّ الأخطاء';

  @override
  String get hlpRowLogBody => 'ملف محلي لا يغادر من تلقاء نفسه';

  @override
  String get hlpRowDirectory => 'الدليل';

  @override
  String get hlpRowDirectoryBody => 'يرى اسمًا ومعرّفًا عامًا. الطلبات عبر Tor: لا عنوانك الحقيقي';

  @override
  String get hlpRowMailbox => 'صندوق البريد';

  @override
  String get hlpRowMailboxBody => 'يحفظ رسالة مشفّرة حتى تسليمها. لا يستطيع قراءتها';

  @override
  String get hlpRowSignalling => 'إقامة الاتصال';

  @override
  String get hlpRowSignallingBody => 'يرى معرّفين أثناء الربط. لا يمرّ به أي صوت';

  @override
  String get hlpRowRelay => 'المُرحِّل';

  @override
  String get hlpRowRelayBody => 'يمرّر الصوت المشفّر حين يتعذّر الاتصال المباشر';

  @override
  String get hlpNonePhone => 'رقم الهاتف';

  @override
  String get hlpNoneEmail => 'البريد الإلكتروني';

  @override
  String get hlpNoneContacts => 'دفتر عناوينك';

  @override
  String get hlpNoneLocation => 'موقعك';

  @override
  String get hlpNoneAds => 'الإعلانات والمتعقّبات';

  @override
  String get hlpNoneAnalytics => 'قياس الاستخدام';

  @override
  String get hlpQOffline => 'كيف يعمل Droplet من دون إنترنت؟';

  @override
  String get hlpAOffline => 'تتحدّث الهواتف مباشرة عبر البلوتوث والواي فاي. ويمكن للرسالة أن تنتقل من هاتف إلى هاتف حتى تصل، دون أن تمرّ بخادم قط.';

  @override
  String get hlpQCrypto => 'هل رسائلي مشفّرة فعلًا؟';

  @override
  String get hlpACrypto => 'نعم، من طرف إلى طرف، ببروتوكول Signal. المفتاح موجود على الهاتفين فقط. لا المُرحِّل ولا صندوق البريد ولا نحن نستطيع فتح رسالة.';

  @override
  String get hlpQNoAccount => 'لماذا لا يطلب Droplet رقمًا ولا بريدًا؟';

  @override
  String get hlpANoAccount => 'لأنه لا يحتاجهما. هويّتك مفتاح يُصنع على هاتفك. لا شيء يُنشأ، ولا شيء يُتحقّق منه، ولا شيء يُسرق في مكان آخر.';

  @override
  String get hlpQPending => 'لماذا تبقى رسالتي في الانتظار؟';

  @override
  String get hlpAPending => 'لا أحد ضمن المدى بعد، ولا إنترنت. تنتظر الرسالة في الهاتف وتنطلق فور انفتاح طريق — لا داعي لإعادة أي شيء.';

  @override
  String get hlpQAddSomeone => 'كيف أضيف شخصًا؟';

  @override
  String get hlpAAddSomeone => 'قرّب الهاتفين: يظهر الشخص وحده. وعن بُعد، شارك رابط دعوتك أو امسح رمز QR الخاص به.';

  @override
  String get hlpQUninstall => 'ماذا يحدث إن ألغيت تثبيت التطبيق؟';

  @override
  String get hlpAUninstall => 'يُمحى كل شيء: الرسائل والجهات والهويّة. لا نسخة في مكان آخر، فلا استعادة. صدّر إعداداتك قبل تغيير الهاتف.';

  @override
  String get hlpQBattery => 'هل يستهلك Droplet بطاريتي؟';

  @override
  String get hlpABattery => 'البحث عن الأجهزة القريبة يستهلك طاقة. في الإعدادات يمكنك تقليله أو تشغيله فقط والتطبيق مفتوح.';

  @override
  String get hlpQReport => 'كيف أبلّغ عن مشكلة؟';

  @override
  String get hlpAReport => 'من «التواصل والدعم». سترى النص الدقيق الذي سيُرسل قبل أن يغادر — لا شيء يترك هاتفك من دونك.';

  @override
  String get svLikeStatus => 'الإعجاب بالحالة';

  @override
  String get svUnlikeStatus => 'إزالة الإعجاب';

  @override
  String get stAddPhotoSemantics => 'إضافة صورة للملف الشخصي';

  @override
  String get stChangePhotoSemantics => 'تغيير صورة الملف الشخصي';

  @override
  String get scOverheat => 'ارتفعت حرارة الهاتف — أوقف أندرويد مُرمِّز الفيديو. اتركه يبرد بضع دقائق.';

  @override
  String scTooHeavy(int mo) {
    return 'الملف ثقيل جدًا — $mo ميغابايت كحدّ أقصى لعبور الشبكة المحلية.';
  }

  @override
  String get scUnsupported => 'هذه الصيغة غير مدعومة في الحالة.';

  @override
  String get scUnreadableFile => 'تعذّرت قراءة هذا الملف';

  @override
  String get scUnreadableTrack => 'تعذّرت قراءة هذا المقطع';

  @override
  String get scNothingCaptured => 'لم يلتقط التسجيل شيئًا — أعد المحاولة.';

  @override
  String get scVideoTrimmed => 'قُصّر الفيديو إلى دقيقة ونصف — يُنشر أوّله فقط.';

  @override
  String get scUnreadableVideo => 'فيديو غير قابل للقراءة';

  @override
  String get chAiMe => 'أنا';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'هذه نهاية محادثة في Droplet بين المستخدم («أنا») و$pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'يريد المستخدم مساعدة في الردّ على $pseudo. اقترح ردًّا قصيرًا وطبيعيًا مكتوبًا بـ$langue، بصيغة المتكلّم، كأنه يرسله بنفسه. أعطِ الردّ المقترح فقط، دون مقدّمات.';
  }

  @override
  String get hlpSectionHeader => 'المساعدة والخصوصية';

  @override
  String get hlpPrivacy => 'سياسة الخصوصية';

  @override
  String get hlpData => 'بياناتك';

  @override
  String get hlpDataValue => 'لا شيء يخرج';

  @override
  String get hlpContact => 'التواصل والدعم';

  @override
  String get hlpPrivacyTitle => 'الخصوصية';

  @override
  String hlpUpdated(String date) {
    return 'حُدّث في $date';
  }

  @override
  String get hlpOnlyFrEn => 'هذا النص متوفّر بالفرنسية والإنجليزية فقط. ترجمة تقريبية لوثيقة قانونية تُلزم أكثر مما تُفيد.';

  @override
  String get hlpReadInEnglish => 'القراءة بالإنجليزية';

  @override
  String get hlpReadInFrench => 'القراءة بالفرنسية';

  @override
  String get hlpDataTitle => 'بياناتك';

  @override
  String get hlpDataLead => 'ما يعرفه Droplet عنك، سطرًا بسطر. لا شيء هنا وعد: كل سطر يقابله رمز برمجي.';

  @override
  String get hlpStays => 'لا يغادر الجهاز أبدًا';

  @override
  String get hlpLeaves => 'يمرّ عبر خادم';

  @override
  String get hlpNever => 'غير موجود';

  @override
  String get hlpCountTracking => 'بيانات لتتبّعك';

  @override
  String get hlpCountAccount => 'حساب يُنشأ';

  @override
  String get hlpCountServers => 'خوادم، ونسمّيها';

  @override
  String get hlpHelpTitle => 'المساعدة';

  @override
  String get hlpSearchHint => 'بحث';

  @override
  String get hlpNoResult => 'لا توجد إجابة تحتوي هذه الكلمة. راسلنا: ربما هو سؤال ناقص هنا.';

  @override
  String get hlpStillStuckFooter => 'إن لم تكن الإجابة هنا، يردّ عليك شخص.';

  @override
  String get hlpContactTitle => 'التواصل';

  @override
  String get hlpContactLead => 'سؤال أو مشكلة أو فكرة. نقرأ كل شيء.';

  @override
  String get hlpBeforeWriting => 'قبل المراسلة';

  @override
  String get hlpHelpRowBody => 'ثماني إجابات، تُقرأ دون إنترنت';

  @override
  String get hlpWriteUs => 'راسلنا';

  @override
  String get hlpWhatsApp => 'واتساب';

  @override
  String get hlpEmail => 'البريد الإلكتروني';

  @override
  String get hlpWhatsAppHello => 'مرحبًا، أستخدم Droplet ولديّ سؤال:';

  @override
  String get hlpEmailSubject => 'Droplet — سؤال';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'واتساب غير مثبّت. نُسخ الرقم $numero.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'نُسخ العنوان $adresse.';
  }

  @override
  String get hlpReportHeader => 'مشكلة';

  @override
  String get hlpReport => 'الإبلاغ عن مشكلة';

  @override
  String get hlpReportBody => 'سترى ما سيُرسل قبل أن يُرسل';

  @override
  String get hlpReportFooter => 'لا يرسل Droplet أي تقرير من تلقاء نفسه: لا خادم لديه لذلك. لا تصلنا المشكلة إلا إذا أرسلتها أنت.';

  @override
  String get hlpReportSubject => 'Droplet — بلاغ';

  @override
  String get hlpReportSheetLead => 'اذكر ما حدث. النص الدقيق الذي سيُرسل يظهر أدناه.';

  @override
  String get hlpReportHint => 'ما كنت أفعله وما الذي حدث…';

  @override
  String get hlpAttachLog => 'إرفاق سجلّ الأخطاء';

  @override
  String get hlpWhatWillBeSent => 'ما الذي سيُرسل';

  @override
  String get hlpLogExcerpt => 'السجلّ (النهاية):';

  @override
  String get hlpCopy => 'نسخ';

  @override
  String get hlpCopied => 'نُسخ';

  @override
  String get hlpOnePerson => 'يصنع Droplet شخص واحد، لا فريق دعم. قد يستغرق الردّ يومًا أو يومين — لكنه يأتي.';

  @override
  String get avSectionHeader => 'ما يقدّمه Pro';

  @override
  String get avUnlock => 'فتح Droplet Pro';

  @override
  String get avVoiceTitle => 'الصوت نصاً';

  @override
  String get avVoiceShort => 'اقرأ الرسالة الصوتية دون تشغيلها';

  @override
  String get avVoiceLong => 'تتم الكتابة على هاتفك دون إنترنت. لا تغادر الرسالة الصوتية جهازك، وتقرأها في اجتماع أو في الحافلة أو بلا شبكة.';

  @override
  String get avFormatTitle => 'تنسيق النص';

  @override
  String get avFormatShort => 'عريض، مائل، شيفرة، حاجب';

  @override
  String get avFormatLong => 'كلمة بخط عريض، سطر شيفرة، مقطع مخفي يظهر بلمسة: رسالتك تقول بالضبط ما قصدته.';

  @override
  String get avWallpaperTitle => 'الخلفيات والنقوش';

  @override
  String get avWallpaperShort => 'المعرض كامل وكل الحزم الأربع';

  @override
  String get avWallpaperLong => 'كل خلفية مرسومة يدوياً، وكل نقشة مُراجعة قبل دخولها التطبيق. Droplet وألعاب ومنزل وحديقة: شاشتك لا تشبه أي شاشة أخرى.';

  @override
  String get avStickersTitle => 'ملصقات متحركة';

  @override
  String get avStickersShort => 'قطرة Droplet وهي تتحرك';

  @override
  String get avStickersLong => 'ملصقات مرسومة لـ Droplet، متحركة إطاراً بإطار وخفيفة بما يكفي لتنتقل عبر الشبكة المتشابكة بلا إنترنت.';

  @override
  String get avIconTitle => 'أيقونات التطبيق';

  @override
  String get avIconShort => 'غيّر الأيقونة على الشاشة الرئيسية';

  @override
  String get avIconLong => 'التطبيق المتحفّظ يبدأ من أيقونته. اختر ما يشبهك، أو ما لا يلفت النظر.';

  @override
  String get avBadgeTitle => 'شارة Pro';

  @override
  String get avBadgeShort => 'يرافق اسمك';

  @override
  String get avBadgeLong => 'لا يمنح أي سلطة على أحد. يقول فقط إنك دفعت كي يبقى Droplet بلا إعلانات ولا اشتراك إجباري ولا بيع للبيانات.';

  @override
  String get sgTitle => 'مساحة المجموعة';

  @override
  String get sgEmpty => 'لم تتم مشاركة أي ملف في هذه المجموعة بعد.';

  @override
  String get sgByAuthor => 'من يرسل الأكثر';

  @override
  String get sgFiles => 'الملفات';

  @override
  String get sgSortRecent => 'الأحدث';

  @override
  String get sgSortHeavy => 'الأكبر حجماً';

  @override
  String get sgNotOnDevice => 'غير موجود';

  @override
  String get giPhotoChanged => 'تم تغيير صورة المجموعة';

  @override
  String get giPhotoFailed => 'تعذّر حفظ هذه الصورة';

  @override
  String sgTotal(int count) {
    return '$count ملفات مشتركة';
  }

  @override
  String get vrTitle => 'غرفة صوتية';

  @override
  String get vrJoin => 'انضم';

  @override
  String get vrBack => 'عودة';

  @override
  String get vrStart => 'افتح غرفة صوتية';

  @override
  String get vrNeedsInternet => 'تحتاج الغرفة الصوتية إلى الإنترنت: الشبكة تحمل رسالة تنتظر، لا عشرين صوتاً معاً.';

  @override
  String get vrUnreachable => 'تعذّر الوصول إلى خادم المكالمات حاليًا.';

  @override
  String vrFull(int count) {
    return 'الغرفة ممتلئة: $count أشخاص كحد أقصى.';
  }

  @override
  String get vrWaiting => 'في انتظار الآخرين…';

  @override
  String get vrWaitingBody => 'الغرفة مفتوحة. يراها أعضاء المجموعة في المحادثة وينضمون عندما يتفرّغون.';

  @override
  String vrPeople(int count) {
    return '$count أشخاص بالداخل';
  }

  @override
  String get cvTitle => 'المحادثات';

  @override
  String get cvNew => 'محادثة جديدة';

  @override
  String get cvPinned => 'مثبّتة';

  @override
  String get cvRecent => 'الأخيرة';

  @override
  String get cvPin => 'تثبيت';

  @override
  String get cvUnpin => 'إلغاء التثبيت';

  @override
  String get cvRename => 'إعادة التسمية';

  @override
  String get cvRenameHint => 'عنوان المحادثة';

  @override
  String get cvUntitled => 'بلا عنوان';

  @override
  String get cvYesterday => 'أمس';

  @override
  String get cvSearchHint => 'البحث في المحادثات';

  @override
  String get cvEmpty => 'لا توجد محادثات بعد. اطرح سؤالك الأول على المساعد.';

  @override
  String get cvDeleteTitle => 'حذف هذه المحادثة؟';

  @override
  String get cvDeleteBody => 'لا يمكن استرجاعها: فهي موجودة على هذا الجهاز فقط.';

  @override
  String get jaWorking => 'جارٍ العمل…';

  @override
  String cvNoResult(String terme) {
    return 'لا نتائج لـ «$terme».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'لا نتائج',
      one: 'نتيجة واحدة',
      other: '$count نتيجة',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'لا خطوات',
      one: 'خطوة واحدة',
      other: '$count خطوات',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'إلى أين تذهب رسالتك';

  @override
  String get moLocal => 'على الجهاز';

  @override
  String get moLocalBody => 'يعمل النموذج على هذا الهاتف. لا شيء يغادره، حتى دون اتصال. الإجابات أقصر وأقل موثوقية.';

  @override
  String get moOnline => 'عبر الإنترنت';

  @override
  String get moOnlineBody => 'تذهب رسالتك إلى Groq الذي يشغّل نموذجًا أكبر بكثير. يتطلب ذلك اتصالًا، وتغادر الرسالة هاتفك.';

  @override
  String get moOnlineNoKey => 'يتطلب التحدث إلى نموذج بعيد مفتاحًا. اضغط لإضافة واحد — مجانًا وفي دقيقة واحدة.';

  @override
  String get moRetryOnline => 'إعادة عبر الإنترنت';

  @override
  String get moRetryOnlineWhy => 'بلغ النموذج المحلي حدوده في هذا السؤال.';

  @override
  String get cpHint => 'اطرح أي سؤال…';

  @override
  String get cpAdd => 'إضافة';

  @override
  String get cpPhoto => 'صورة';

  @override
  String get cpCamera => 'الكاميرا';

  @override
  String get cpFile => 'ملف';

  @override
  String get cpFileHint => 'PDF ونص وشيفرة';

  @override
  String get cpDictate => 'إملاء';

  @override
  String get cpSend => 'إرسال';

  @override
  String get cpStop => 'إيقاف';

  @override
  String get cpThinking => 'جارٍ التفكير…';

  @override
  String get amCopy => 'نسخ';

  @override
  String get amCopyMarkdown => 'نسخ بصيغة Markdown';

  @override
  String get amCopyMarkdownHint => 'مع التنسيق، لمستند';

  @override
  String get amShare => 'مشاركة';

  @override
  String get amEdit => 'تعديل سؤالي';

  @override
  String get amEditHint => 'سيُحذف كل ما بعده';

  @override
  String get amEditTitle => 'تعديل هذا السؤال؟';

  @override
  String get amEditConfirm => 'تعديل';

  @override
  String get amRegenerate => 'إعادة التوليد';

  @override
  String get amReadAloud => 'قراءة بصوت عالٍ';

  @override
  String get amAsContext => 'استخدامه كسياق';

  @override
  String get amAsContextHint => 'يتابع من هذه الرسالة';

  @override
  String get amChapter => 'تحديده كفصل';

  @override
  String get amChapterHint => 'لتجده مجددًا في محادثة طويلة';

  @override
  String get amUnchapter => 'إزالة التحديد';

  @override
  String get amChapters => 'الفصول';

  @override
  String get amChaptersEmpty => 'لا فصول بعد. اضغط مطوّلًا على رسالة واختر «تحديده كفصل» لتجدها هنا.';

  @override
  String amEditBody(int count) {
    return 'سيتم حذف $count رسالة تالية، فقد كانت تجيب على السؤال القديم.';
  }

  @override
  String get trAssistant => 'المساعد';

  @override
  String get trArtifacts => 'المخرجات';

  @override
  String get trMemory => 'الذاكرة';

  @override
  String get trHelp => 'المساعدة';

  @override
  String get arVersions => 'الإصدارات';

  @override
  String get arLatest => 'الأحدث';

  @override
  String get arSource => 'المصدر';

  @override
  String get arPreview => 'معاينة';

  @override
  String get arGone => 'لم يعد هذا المخرج موجودًا.';

  @override
  String get arKindPage => 'صفحة';

  @override
  String get arKindCode => 'شيفرة';

  @override
  String get arKindDiagram => 'مخطط';

  @override
  String get arKindData => 'بيانات';

  @override
  String get arKindDoc => 'مستند';

  @override
  String arVersion(int n) {
    return 'الإصدار $n';
  }

  @override
  String get aiSources => 'المصادر';

  @override
  String get aiToolReading => 'جارٍ قراءة المرفق…';

  @override
  String get aiToolWriting => 'جارٍ إنشاء الملف…';

  @override
  String get aiToolRemembering => 'جارٍ الحفظ في الذاكرة…';

  @override
  String get arEmpty => 'لا مخرجات بعد. ينشئ المساعد واحدًا بمجرد أن ينتج صفحة أو جدولًا أو شيفرة طويلة بما يكفي لتزحم المحادثة.';

  @override
  String get raTitle => 'المساعد عبر الإنترنت';

  @override
  String get raIntro => 'يعمل المساعد المحلي دون أي إعداد. أما الوضع عبر الإنترنت فيحتاج مفتاحًا: هو الذي يدفع ثمن الإجابات، ويبقى على هذا الهاتف.';

  @override
  String get raKey => 'المفتاح';

  @override
  String get raKeySaved => 'تم حفظ المفتاح';

  @override
  String get raKeyFooter => 'يُحفظ في سلسلة مفاتيح النظام ولا يُعرض كاملًا أبدًا.';

  @override
  String get raKeyRemove => 'إزالة المفتاح';

  @override
  String get raWhere => 'يُنشأ المفتاح على console.groq.com ضمن «API Keys». يبدأ بـ gsk_.';

  @override
  String get raPaste => 'لصق';

  @override
  String get raSaveAndTest => 'حفظ واختبار';

  @override
  String get raTest => 'اختبار المفتاح';

  @override
  String get raTesting => 'جارٍ الاختبار…';

  @override
  String get raNotTested => 'لم يُختبر بعد';

  @override
  String get raNotTestedBody => 'يكفي طلب من ثماني كلمات لمعرفة ذلك. الأفضل هنا لا في منتصف سؤال.';

  @override
  String get raWorks => 'المفتاح يعمل';

  @override
  String get raWorksBody => 'أصبح الوضع عبر الإنترنت متاحًا في المحادثة، على الزر بجوار حقل الكتابة.';

  @override
  String get raRefused => 'تم رفض المفتاح';

  @override
  String get raRefusedBody => 'لا يتعرّف عليه الخادم. غالبًا حرف ناقص عند اللصق، أو مفتاح أُلغي.';

  @override
  String get raNoNetwork => 'تعذّر الوصول إلى الخادم';

  @override
  String get raNoNetworkBody => 'المفتاح ليس السبب: لم يصل الطلب أصلًا. تحقّق من الاتصال ثم أعد المحاولة.';

  @override
  String get raModelGone => 'النموذج غير متاح';

  @override
  String get raModelGoneBody => 'قُبل المفتاح لكن لم يعد شيء. على الأرجح أُزيل النموذج من الكتالوج.';

  @override
  String get raQuota => 'طلبات كثيرة جدًا';

  @override
  String get raQuotaBody => 'المفتاح يعمل، لكن الحساب بلغ حدّه. أعد المحاولة لاحقًا أو تحقّق من الرصيد.';

  @override
  String get raWhatGoesOut => 'ما الذي يغادر';

  @override
  String get raModel => 'النموذج';

  @override
  String get raWhatGoesOutFooter => 'في الوضع عبر الإنترنت، تذهب رسالتك والمداخلات السابقة في هذه المحادثة إلى Groq. لا شيء غير ذلك: لا جهات اتصالك ولا محادثاتك الأخرى ولا موقعك.';

  @override
  String get aiDownloadTitle => 'تنزيل النموذج المحلي؟';

  @override
  String get aiDownloadConfirm => 'تنزيل';

  @override
  String get aiDownloading => 'جارٍ تنزيل النموذج';

  @override
  String aiDownloadBody(int mo) {
    return '$mo ميغابايت للتنزيل، مرة واحدة فقط. بعدها يجيب المساعد دون شبكة، ولا يغادر شيء هاتفك. يمكنك متابعة استخدامه عبر الإنترنت أثناء التنزيل.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo ميغابايت للتنزيل، مرة واحدة. بعدها يجيب دون شبكة ولا يغادر شيء هاتفك.';
  }

  @override
  String get aiGreetingPlain => 'مرحبًا';

  @override
  String get aiGreetingHint => 'اطرح سؤالًا أو أرفق صورة أو اطلب مستندًا.';

  @override
  String get aiChipExplain => 'اشرح لي…';

  @override
  String get aiChipWrite => 'اكتب رسالة';

  @override
  String get aiChipSummarize => 'لخّص هذا';

  @override
  String get aiChipTranslate => 'ترجم إلى…';

  @override
  String aiGreeting(String nom) {
    return 'مرحبًا، $nom';
  }

  @override
  String get cpNoPhoto => 'لا صور: النموذج عبر الإنترنت لا يقرأ الصور. لكنه يقرأ ملفات PDF، حتى الطويلة منها.';

  @override
  String get mvOpen => 'الوضع الصوتي';

  @override
  String get mvTapToTalk => 'اضغط للتحدث';

  @override
  String get mvHoldToTalk => 'استمر بالضغط للتحدث';

  @override
  String get mvListening => 'أستمع…';

  @override
  String get mvTranscribing => 'جارٍ التحويل إلى نص…';

  @override
  String get mvSpeaking => 'يجيب بصوت مسموع';

  @override
  String get mvProblem => 'حدثت مشكلة';

  @override
  String get mvHandsFree => 'بدون استخدام اليدين';

  @override
  String get mvHold => 'الضغط المستمر';

  @override
  String get mvTalk => 'تحدّث';

  @override
  String get mvInterrupt => 'مقاطعة';

  @override
  String get mvNoMic => 'لا يمكن لـ Droplet الوصول إلى الميكروفون. اسمح بذلك من إعدادات الهاتف.';

  @override
  String get mvFailed => 'لم تنجح هذه المحاولة. اضغط للمحاولة مرة أخرى.';

  @override
  String get mvLive => 'مباشر';

  @override
  String get mvCaptions => 'التسميات التوضيحية';

  @override
  String get mvExit => 'إنهاء الوضع الصوتي';

  @override
  String get mvMute => 'كتم الميكروفون';

  @override
  String get mvUnmute => 'إلغاء كتم الميكروفون';

  @override
  String get mvMuted => 'الميكروفون مكتوم';

  @override
  String get mvTapToInterrupt => 'اضغط للمقاطعة';

  @override
  String scCompressing(int percent) {
    return 'جارٍ الضغط… $percent٪';
  }

  @override
  String get scStillHeavy => 'لا يزال حجم هذا الفيديو أكبر من 2 ميغابايت: سيكون نقله أبطأ.';

  @override
  String get baConnecting => 'جارٍ الاتصال…';

  @override
  String get baMute => 'كتم الصوت';

  @override
  String get baUnmute => 'إلغاء الكتم';

  @override
  String get baHangUp => 'إنهاء المكالمة';

  @override
  String baOngoing(String name) {
    return 'مكالمة جارية مع $name. اضغط للعودة.';
  }

  @override
  String get ntfOngoingCall => 'مكالمة جارية';

  @override
  String get ntfViaMesh => 'عبر الشبكة المتداخلة';

  @override
  String get ntfViaInternet => 'عبر الإنترنت';

  @override
  String get shSend => 'إرسال';

  @override
  String get shRecents => 'الأخيرة';

  @override
  String get shPickRecipients => 'اختر مستلمًا واحدًا أو أكثر';

  @override
  String shSendCount(int count) {
    return 'إرسال إلى $count';
  }

  @override
  String shSelected(int count) {
    return 'تم اختيار $count';
  }

  @override
  String get apcNothingYet => 'لا شيء بعد';

  @override
  String get apcOnline => 'متصل';

  @override
  String get apcOffline => 'غير متصل';

  @override
  String get apcPhoto => 'صورة';

  @override
  String get apcVoice => 'رسالة صوتية';

  @override
  String get apcAttachment => 'مرفق';

  @override
  String get chKeyboardTooltip => 'لوحة المفاتيح';

  @override
  String get asGallery => 'المعرض';

  @override
  String get asFile => 'ملف';

  @override
  String get asLocation => 'الموقع';

  @override
  String get asSticker => 'ملصق';

  @override
  String get asPoll => 'استطلاع';

  @override
  String get asNoGalleryAccess => 'لا يمكن لـ Droplet الوصول إلى صورك. اسمح بذلك من إعدادات الهاتف، أو اختر مصدرًا آخر أدناه.';

  @override
  String asSendCount(int count) {
    return 'إرسال $count';
  }

  @override
  String get asEmptyGallery => 'لا توجد صور ولا مقاطع فيديو على هذا الهاتف.';

  @override
  String get expAucunPairTitre => 'لا أحد قريب؟';

  @override
  String get expAucunPairTexte => 'ليس عطلاً. يبحث دروبلت باستمرار؛ وما إن يمرّ جهاز حتى يتكوّن الاتصال وحده.';

  @override
  String get expRelaisTitre => 'مرّ عبر آخر';

  @override
  String get expRelaisTexte => 'تدل هذه الأيقونة على أن الرسالة عبرت جهازًا أو أكثر قبل وصولها. تلك هي قوة الشبكة.';

  @override
  String get expApercuTitre => 'نظرة سريعة';

  @override
  String get expApercuTexte => 'اضغط مطوّلاً على محادثة لقراءة آخر رسائلها دون فتحها أو تعليمها كمقروءة.';

  @override
  String get expOfficielTitre => 'حساب دروبلت';

  @override
  String get expOfficielTexte => 'تصل أخبار التطبيق هنا. كل إعلان موقَّع: لا يمكن لأحد تزويره.';

  @override
  String get expMicroTitre => 'تحدّث مع الاستمرار';

  @override
  String get expMicroTexte => 'استمر بالضغط للتسجيل. اسحب يسارًا للإلغاء، وللأعلى لمتابعة التسجيل دون إبقاء الإصبع.';

  @override
  String get expCameraTitre => 'ميكروفون أم كاميرا';

  @override
  String get expCameraTexte => 'ضغطة قصيرة على هذا الزر تبدّل بين الرسالة الصوتية ورسالة الفيديو الدائرية.';

  @override
  String get expVueUniqueTitre => 'مرة واحدة';

  @override
  String get expVueUniqueTexte => 'فعّل «1» فلا يمكن فتح ما سترسله إلا مرة واحدة ثم يختفي.';

  @override
  String get expPiecesTitre => 'عدة دفعة واحدة';

  @override
  String get expPiecesTexte => 'يفتح المشبك معرض صورك داخل التطبيق. حدّد عدة صور: الرقم يبيّن ترتيب الإرسال.';

  @override
  String get expStickersTitre => 'الملصقات ولوحة المفاتيح';

  @override
  String get expStickersTexte => 'تستبدل هذه الأيقونة لوحة المفاتيح بالملصقات، وتعود لوحةَ مفاتيح بلمسة واحدة.';

  @override
  String get expEphemeresTitre => 'رسائل تختفي';

  @override
  String get expEphemeresTexte => 'حدّد مدة فتُمحى الرسائل الجديدة في هذه المحادثة من الهاتفين معًا.';

  @override
  String get expVerrouTitre => 'محادثة مقفلة';

  @override
  String get expVerrouTexte => 'عند قفلها، لا تُظهر المحادثة آخر رسالة في القائمة وتطلب فتح القفل.';

  @override
  String get expCodeTitre => 'التحقق من جهة اتصال';

  @override
  String get expCodeTexte => 'قارِن هذا الرمز جنبًا إلى جنب مع مراسلك: إن تطابق، فلم يتسلل أحد بينكما.';

  @override
  String get expStatutTitre => 'حالات ٢٤ ساعة';

  @override
  String get expStatutTexte => 'تعيش الحالة يومًا ثم تُمحى. وتنتقل من هاتف إلى هاتف، حتى بلا إنترنت.';

  @override
  String get expGardeTitre => 'لا شيء يضيع';

  @override
  String get expGardeTexte => 'تُحفظ الرسالة المرسَلة إلى غائب أسبوعًا، وتنطلق وحدها حالما ينفتح طريق.';

  @override
  String get expVoieTitre => 'من أين يمر';

  @override
  String get expVoieTexte => 'بلوتوث أو واي-فاي مباشر أو إنترنت: يأخذ دروبلت المتاح ويغيّر الطريق دون أن يسألك.';

  @override
  String get cnAnnouncement => 'جديد Droplet';

  @override
  String get cnClearAll => 'مسح الكل';

  @override
  String get cnClearAllTitle => 'مسح كل الإشعارات؟';

  @override
  String get cnClearAllBody => 'سيتم إفراغ المركز. لن تتأثر محادثاتك ورسائلك.';

  @override
  String get cnDelete => 'مسح';

  @override
  String get cnEmptyTitle => 'لا جديد';

  @override
  String get cnEmptyBody => 'ستظهر هنا الإشارات والتفاعلات مع رسائلك والمكالمات الفائتة وجديد Droplet.';

  @override
  String get cnMentioned => 'أشار إليك';

  @override
  String get cnShowLess => 'عرض أقل';

  @override
  String get cnStatusLike => 'أعجبته حالتك';

  @override
  String get cnStatusReply => 'ردّ على حالتك';

  @override
  String get cnTitle => 'مركز الإشعارات';

  @override
  String get ncDeliveryHeader => 'طريقة العرض';

  @override
  String get ncMentionsOnly => 'الإشارات فقط';

  @override
  String get ncMentionsOnlySub => 'فقط عندما يكتب أحدهم @اسمك أو @الجميع';

  @override
  String get ncMute1h => 'ساعة واحدة';

  @override
  String get ncMute8h => '8 ساعات';

  @override
  String get ncMute1w => 'أسبوع واحد';

  @override
  String get ncMuteAlways => 'دائمًا';

  @override
  String get ncMuteFooter => 'لا إشعارات ولا أصوات. تصل الرسائل رغم ذلك وتنتظرك.';

  @override
  String get ncMuteFooterGroup => 'لا إشعارات ولا أصوات. ستصلك الإشارات رغم ذلك.';

  @override
  String get ncMuteHeader => 'كتم';

  @override
  String get ncMuteOff => 'متوقف';

  @override
  String get ncPreviewAlways => 'دائمًا';

  @override
  String get ncPreviewFooter => 'بدون معاينة، يقول الإشعار «رسالة جديدة» فقط: لا شيء يُقرأ على شاشة القفل.';

  @override
  String get ncPreviewHeader => 'معاينة الرسالة';

  @override
  String get ncPreviewNever => 'أبدًا';

  @override
  String get ncQuiet => 'توصيل بهدوء';

  @override
  String get ncQuietSub => 'في لوحة الإشعارات، بلا صوت ولا لافتة';

  @override
  String get ncSampleAuthor => 'ليا';

  @override
  String get ncSampleHidden => 'رسالة جديدة';

  @override
  String get ncSampleLabel => 'مثال على إشعار';

  @override
  String get ncSampleText => 'نلتقي الساعة 7 مساءً؟';

  @override
  String get ncStateMentions => 'الإشارات فقط';

  @override
  String get ncStateMuted => 'مكتوم';

  @override
  String get ncStateOn => 'مفعّلة';

  @override
  String get ncStateQuiet => 'هادئة';

  @override
  String get ncSystemFooter => 'يُضبط صوت هذه المحادثة وفقاعاتها من إعدادات Android.';

  @override
  String get ncSystemSettings => 'الصوت والفقاعات';

  @override
  String get ncTitle => 'الإشعارات';

  @override
  String get ntfNewMessage => 'رسالة جديدة';

  @override
  String get ntfNow => 'الآن';

  @override
  String get rnBanners => 'اللافتات';

  @override
  String get rnBannersSub => 'عند وصول رسالة وDroplet مفتوح';

  @override
  String get rnFocus1h => 'لمدة ساعة';

  @override
  String get rnFocusEvening => 'حتى هذا المساء';

  @override
  String get rnFocusTomorrow => 'حتى صباح الغد';

  @override
  String get rnFocusFooter => 'يصمت Droplet: تصل الرسائل وتنتظرك. وتظل المكالمات ترنّ.';

  @override
  String get rnFocusHeader => 'التركيز';

  @override
  String get rnFocusMentions => 'السماح بالإشارات';

  @override
  String get rnFocusMentionsSub => 'عندما يكتب أحدهم @اسمك في مجموعة';

  @override
  String get rnFocusOff => 'التركيز متوقف';

  @override
  String get rnFocusOffSub => 'تصل الإشعارات كالمعتاد';

  @override
  String get rnFocusOn => 'التركيز مفعّل';

  @override
  String get rnFocusStop => 'إيقاف التركيز';

  @override
  String get rnFocusStopShort => 'إيقاف';

  @override
  String get rnInAppHeader => 'داخل Droplet';

  @override
  String get rnMutedEmpty => 'لا توجد محادثات مكتومة.';

  @override
  String get rnMutedHeader => 'المكتومة';

  @override
  String get rnPreview => 'عرض المعاينة';

  @override
  String get rnPreviewFooter => 'نص الرسائل في الإشعارات. يمكن لكل محادثة أن تختلف.';

  @override
  String get rnSystem => 'إعدادات Android';

  @override
  String get rnSystemFooter => 'أذونات Droplet وأصواته وفقاعاته في إعدادات الهاتف.';

  @override
  String get stNotificationsSubtitle => 'الكتم، المعاينات، التركيز';

  @override
  String cnBellUnread(int count) {
    return 'الإشعارات، $count جديدة';
  }

  @override
  String cnMore(int count) {
    return '+$count أخرى';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count أخرى';
  }

  @override
  String cnQuoted(String texte) {
    return '«$texte»';
  }

  @override
  String cnReacted(String emoji) {
    return 'تفاعل بـ $emoji مع رسالتك';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'حتى $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'افتراضي ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'كتم $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'حتى $heure · المكالمات ما زالت ترنّ';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n محادثات';
  }

  @override
  String get chatsNetSearching => 'جارٍ البحث عن أجهزة قريبة…';

  @override
  String get cfEmptyUnreadTitle => 'قرأت كل شيء';

  @override
  String get cfEmptyUnreadBody => 'ستظهر هنا المحادثات التي تحتوي على رسائل غير مقروءة.';

  @override
  String get cfEmptyGroupsTitle => 'لا توجد مجموعات بعد';

  @override
  String get cfEmptyGroupsBody => 'أنشئ واحدة بزر + في أعلى اليمين.';

  @override
  String get cfEmptyOtherTitle => 'لا شيء هنا بعد';

  @override
  String get ciLockedWhereHint => 'تم القفل. للعثور عليها، اسحب قائمة المحادثات إلى الأسفل.';

  @override
  String get chDraftLabel => 'مسودة:';

  @override
  String get rsMorning => 'صباح الخير';

  @override
  String get rsEvening => 'مساء الخير';

  @override
  String get rsUnreadOne => 'رسالة واحدة غير مقروءة';

  @override
  String get rsChatsOne => 'في محادثة واحدة';

  @override
  String get rsMentionsOne => 'إشارة واحدة';

  @override
  String get rsMissedOne => 'مكالمة فائتة واحدة';

  @override
  String get rsSeeUnread => 'عرض غير المقروءة';

  @override
  String rsUnreadMany(int count) {
    return '$count رسائل غير مقروءة';
  }

  @override
  String rsChatsMany(int count) {
    return 'في $count محادثات';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count إشارات';
  }

  @override
  String rsMissedMany(int count) {
    return '$count مكالمات فائتة';
  }

  @override
  String get camUnavailable => 'الكاميرا غير متاحة. تحقق من الإذن في الإعدادات.';

  @override
  String get camTakePhoto => 'التقاط صورة';

  @override
  String get camFlip => 'تبديل الكاميرا';

  @override
  String get chE2eNotice => 'الرسائل مشفرة تمامًا بين الطرفين. لا يمكن لأي شخص آخر، ولا حتى Droplet، قراءتها.';

  @override
  String chCallUnreachable(String name) {
    return '$name خارج النطاق: يمكنك الاتصال عندما تكونان قريبين أو متصلين.';
  }

  @override
  String get chPin => 'تثبيت';

  @override
  String get chUnpin => 'إلغاء التثبيت';

  @override
  String get chPinnedMessage => 'رسالة مثبتة';

  @override
  String get chVoicePlay => 'تشغيل';

  @override
  String get chVoicePause => 'إيقاف مؤقت';

  @override
  String chPinnedMessageN(String position) {
    return 'رسالة مثبتة $position';
  }

  @override
  String get msgInfo => 'معلومات';

  @override
  String get imSearch => 'بحث';

  @override
  String get apcVideo => 'فيديو';

  @override
  String get adTitle => 'الأجهزة المرتبطة';

  @override
  String get adSettingsSubtitle => 'Droplet Web على حاسوبك';

  @override
  String get adHero => 'استخدم Droplet على حاسوبك، حتى عندما يكون هاتفك مغلقًا. ما عليك سوى فتح:';

  @override
  String get adLink => 'ربط جهاز';

  @override
  String get adDevices => 'الأجهزة';

  @override
  String adCount(int n, int max) {
    return '$n من $max';
  }

  @override
  String get adNone => 'لا توجد أجهزة مرتبطة';

  @override
  String get adFooter => 'رسائلك مشفرة تمامًا بين الطرفين على كل أجهزتك. لكل جهاز مرتبط مفاتيحه الخاصة، ويمكنك تسجيل خروجه في أي وقت.';

  @override
  String adLinkedOn(String date) {
    return 'تم الربط في $date';
  }

  @override
  String get adLogout => 'تسجيل الخروج';

  @override
  String adLogoutTitle(String nom) {
    return 'هل تريد تسجيل خروج $nom؟';
  }

  @override
  String get adLogoutBody => 'سيفقد هذا المتصفح الوصول إلى دردشاتك. يمكنك ربطه مرة أخرى في أي وقت.';

  @override
  String get adLogoutAll => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get adLogoutAllBody => 'ستفقد كل المتصفحات المرتبطة الوصول إلى دردشاتك.';

  @override
  String get adScanTitle => 'ربط جهاز';

  @override
  String get adScanHint => 'على حاسوبك، افتح Droplet Web ووجّه الكاميرا إلى رمز QR:';

  @override
  String get adSecurity => 'يتغير الرمز كل دقيقة: لا فائدة من التقاط صورة له.';

  @override
  String get adNotDroplet => 'هذا ليس رمز Droplet Web. وجّه الكاميرا إلى الرمز المعروض على web.dropletmesh.app.';

  @override
  String get adConfirmTitle => 'هل تريد ربط هذا الجهاز؟';

  @override
  String get adConfirmBody => 'سيتمكن من قراءة رسائلك وإرسالها، حتى عندما يكون هذا الهاتف مغلقًا.';

  @override
  String get adConfirm => 'ربط';

  @override
  String get adLinking => 'جارٍ الربط…';

  @override
  String get adLinked => 'تم ربط الجهاز';

  @override
  String get adServerDown => 'يتعذر الوصول إلى خوادم Droplet حاليًا. تحقق من اتصالك، ثم أعد المحاولة.';

  @override
  String get adLimit => 'لديك بالفعل 4 أجهزة مرتبطة. سجّل الخروج من أحدها لربط جهاز آخر.';

  @override
  String get adNoIdentity => 'أنشئ ملفك الشخصي على Droplet على هذا الهاتف أولًا.';

  @override
  String get adTorch => 'مصباح';
}
