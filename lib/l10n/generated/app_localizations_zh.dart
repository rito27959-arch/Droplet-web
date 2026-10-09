// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => '发送';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionSave => '保存';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionClose => '关闭';

  @override
  String get actionDone => '完成';

  @override
  String get actionNext => '下一步';

  @override
  String get actionBack => '返回';

  @override
  String get actionRetry => '重试';

  @override
  String get actionEdit => '编辑';

  @override
  String get tabChats => '聊天';

  @override
  String get tabNews => '动态';

  @override
  String get tabCalls => '通话';

  @override
  String get tabPeers => '节点';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get appearanceAuto => '自动';

  @override
  String get appearanceLight => '浅色';

  @override
  String get appearanceDark => '深色';

  @override
  String get appearanceFooter =>
      'Droplet 专为深色模式设计：在 OLED 屏幕上，黑色像素完全熄灭，既省电又不会在夜间刺眼。浅色模式仍可在强光下阅读时使用。';

  @override
  String get sectionLanguage => '语言';

  @override
  String get languageAuto => '自动（跟随手机语言）';

  @override
  String get languageFooter => '「自动」会跟随设备设置的语言。如果该语言尚未支持，Droplet 将保持法语显示。';

  @override
  String get chatsTitle => '聊天';

  @override
  String get chatsSearchHint => '搜索';

  @override
  String get chatsFilterAll => '全部';

  @override
  String get chatsFilterUnread => '未读';

  @override
  String get chatsFilterGroups => '群组';

  @override
  String get chatsFilterPinned => '已置顶';

  @override
  String get chatsEmptyTitle => '暂无聊天';

  @override
  String get chatsEmptySubtitle => '靠近一台使用 Droplet 的设备，它会自动出现在这里。';

  @override
  String get chatsSearchEmptyTitle => '没有结果';

  @override
  String get chatsSearchEmptySubtitle => '换个名字试试。';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '附近有 $count 个节点',
      zero: '正在搜索节点…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => '至少 3 个字符';

  @override
  String get obChoosePseudo => '选择一个名字开始使用';

  @override
  String get obRestoreFailed => '恢复失败';

  @override
  String get obPhotoSaveFailed => '无法保存照片';

  @override
  String get obShareUnavailable => '分享不可用';

  @override
  String get obBackupPasswordTitle => '备份密码';

  @override
  String get obBackupPasswordMessage => '您导出身份时设置的密码。';

  @override
  String get obBackupPasswordPlaceholder => '密码';

  @override
  String get obRestore => '恢复';

  @override
  String get obSkipStep => '跳过此步骤';

  @override
  String get obContinue => '继续';

  @override
  String get obStart => '开始';

  @override
  String get obAlreadyHaveBackup => '我已经有备份了';

  @override
  String get obWelcomeTitle => '欢迎使用\nDroplet';

  @override
  String get obWelcomeSubtitle => '在没有网络的地方也能使用的即时通讯应用。';

  @override
  String get obFeatOfflineTitle => '无需网络，无需运营商';

  @override
  String get obFeatOfflineText => '手机之间直接通信，逐跳传递。没有信号塔，没有账单。';

  @override
  String get obFeatEncryptedTitle => '端到端加密';

  @override
  String get obFeatEncryptedText => '即使是转发您消息的手机也无法读取它们。';

  @override
  String get obFeatLocalTitle => '没有任何内容会离开您的设备';

  @override
  String get obFeatLocalText => '无需账户，无需服务器，不收集数据。您的对话只属于您。';

  @override
  String get obRelayTitle => '逐跳\n传递';

  @override
  String get obRelaySubtitle => '即使您不在直接范围内，您的消息也会在手机之间跳转，直至到达收件人。';

  @override
  String get obFeatCrowdTitle => '人越多，覆盖范围越广';

  @override
  String get obFeatCrowdText => '范围内的每台设备都会为所有人扩大网络。';

  @override
  String get obFeatNothingLostTitle => '什么都不会丢失';

  @override
  String get obFeatNothingLostText => '发给不在场的人的消息会先等待，一旦有路径打开就会继续传递。';

  @override
  String get obSafetyTitle => '无需网络，\n找到彼此';

  @override
  String get obSafetySubtitle => '当一切都失灵时，知道其他人在哪里、是否平安，就成了最有用的信息。';

  @override
  String get obFeatMapTitle => '离线也能使用的地图';

  @override
  String get obFeatMapText => '您查看过的区域会保存在手机上。浏览后即可离线显示。';

  @override
  String get obFeatMeshPosTitle => '位置信息来自网状网络';

  @override
  String get obFeatMeshPosText => '无需服务器：位置信息从联系人的手机加密发出，逐设备跳转，直至到达您的设备。';

  @override
  String get obFeatCheckinTitle => '一键发送“我很安全”';

  @override
  String get obFeatCheckinText => '轻轻一点即可将您的状态广播给附近所有人。您可以选择是否附上大致位置。';

  @override
  String get obStatusTitle => '分享\n近况';

  @override
  String get obStatusSubtitle => '一张照片、一句话、一种心情：您的状态像消息一样在手机间传递。';

  @override
  String get obFeatStatusMediaTitle => '照片、视频或文字';

  @override
  String get obFeatStatusMediaText => '发布您想展示的内容。范围内的人无需联网即可接收。';

  @override
  String get obFeatStatusSeenTitle => '您可以看到谁看过';

  @override
  String get obFeatStatusSeenText => '每个查看您状态的人都会通过同样的路径让您知道。';

  @override
  String get obFeatStatusExpireTitle => '一天后消失';

  @override
  String get obFeatStatusExpireText => '二十四小时后，状态会从所有接收过的手机上消失。';

  @override
  String get obRemovePhoto => '移除照片';

  @override
  String get obChoosePhoto => '选择照片';

  @override
  String get obPhotoTitle => '如果愿意，\n放一张脸';

  @override
  String get obPhotoSubtitle => '它能帮助他人在列表中认出您。您完全不必设置头像。';

  @override
  String get obFeatPhotoLocalTitle => '它只保留在这部手机上';

  @override
  String get obFeatPhotoLocalText => '没有服务器接收它，没有在线备份保存它。它只存在于应用文件夹中，别无他处。';

  @override
  String get obFeatPhotoCompressTitle => '存储前会被压缩';

  @override
  String get obFeatPhotoCompressText => 'Droplet 只保留 320 像素的缩略图。您的原始照片永远不会被复制。';

  @override
  String get obNetworkTitle => 'Droplet 与您\n共同成长';

  @override
  String get obNetworkSubtitle => '每个安装它的人都会扩大网络——为自己，也为周围的所有人。';

  @override
  String get obSendToFriend => '将 Droplet 发送给亲友';

  @override
  String get obFeatShareOfflineTitle => '分享同样无需联网';

  @override
  String get obFeatShareOfflineText =>
      'Droplet 会发送自己的安装文件。它通过蓝牙、Wi-Fi Direct 或存储卡传输——双方都无需联网。';

  @override
  String get obFeatThreeTitle => '三个人就足以开始';

  @override
  String get obFeatThreeText => '两人时，可以在视线范围内互通消息。街区内多几个人，消息就能接力传递，覆盖范围远超单部手机。';

  @override
  String get obIdentityTitle => '我们该如何\n称呼您？';

  @override
  String get obIdentitySubtitle => '这个名字会显示给您遇到的人。您可以选择一个不透露身份的名字。';

  @override
  String get obPseudoHint => '您的昵称';

  @override
  String get obFeatKeysTitle => '您的密钥此刻就在这里生成';

  @override
  String get obFeatKeysText => '它们永远不会离开这部手机。请记得在设置中进行备份：一旦丢失，身份将永久无法找回。';

  @override
  String get splashCaption => '离线。无需运营商。';

  @override
  String get chatsMeshNetwork => '网状网络';

  @override
  String get chatsNew => '新建';

  @override
  String get chatsNewGroup => '新建群组';

  @override
  String get chatsAssistant => '助手';

  @override
  String get chatsEmergencyMode => '紧急模式';

  @override
  String get chatsUnpin => '取消置顶';

  @override
  String get chatsPin => '置顶';

  @override
  String get chatsUnmute => '开启通知';

  @override
  String get chatsMute => '静音';

  @override
  String get chatsArchive => '归档';

  @override
  String get swipePin => '置顶';

  @override
  String get swipeUnpin => '取消置顶';

  @override
  String get swipeMute => '静音';

  @override
  String get swipeUnmute => '取消静音';

  @override
  String get swipeArchive => '归档';

  @override
  String get fmtBold => '粗体';

  @override
  String get fmtItalic => '斜体';

  @override
  String get fmtStrike => '删除线';

  @override
  String get fmtMono => '等宽';

  @override
  String get fmtSpoiler => '剧透';

  @override
  String get vnTranscribing => '正在转写…';

  @override
  String get vnTranscribeFailed => '此设备不支持转写';

  @override
  String get vnNoSpeech => '未识别到语音';

  @override
  String get msgTranslate => '翻译';

  @override
  String get msgShowOriginal => '查看原文';

  @override
  String get msgTranslatedFrom => '自动翻译';

  @override
  String get msgTranslateFailed => '翻译不可用';

  @override
  String get msgTranslateModel => '需要下载语言模型（仅一次，建议用 Wi‑Fi）';

  @override
  String get pfWallpapers => '动态背景';

  @override
  String get pfWallpapersDesc => '八款多彩背景在聊天后流动，每发送一条消息就转动一次。';

  @override
  String get pfFormatting => '文字格式';

  @override
  String get pfFormattingDesc => '粗体、斜体、删除线、代码和剧透，直接写在消息里。';

  @override
  String get pfTranscription => '语音转文字';

  @override
  String get pfTranscriptionDesc => '不方便听时可以阅读语音消息。识别在你的手机上完成。';

  @override
  String get pfTranslation => '翻译';

  @override
  String get pfTranslationDesc => '翻译收到的消息，内容绝不离开设备。';

  @override
  String get pfAppIcons => '应用图标';

  @override
  String get pfAppIconsDesc => '更换主屏幕上的 Droplet 图标。';

  @override
  String get pfBadge => '徽章与支持';

  @override
  String get pfBadgeDesc => '名字旁的徽章，以及对独立项目的支持。';

  @override
  String get pfUnderstood => '知道了';

  @override
  String get pfFeaturesTitle => '套装解锁的内容';

  @override
  String get chatsUnarchive => '取消归档';

  @override
  String get chatsArchivedTitle => '已归档';

  @override
  String get chatsNoArchived => '没有已归档的聊天';

  @override
  String get chatsLockedTitle => '已锁定的聊天';

  @override
  String get chatsNoLocked => '没有已锁定的聊天';

  @override
  String get chatsCrashTitle => 'Droplet 意外关闭';

  @override
  String get chatsCrashBody =>
      'Droplet 没有服务器：如果您不发送，这个缺陷对任何人来说都不存在。报告不包含消息、联系人或密钥。';

  @override
  String get chatsSendReport => '发送报告';

  @override
  String get chatsLater => '稍后';

  @override
  String get stTitle => '设置';

  @override
  String get stIconHeader => '图标';

  @override
  String get stIconFooter => '主屏幕图标共 13 种可选样式。';

  @override
  String get stAppIcon => '应用图标';

  @override
  String get stVariants13 => '13 种样式';

  @override
  String get stNetworkHeader => '网络';

  @override
  String get stNetworkFooter => '后台中继功能可在 Droplet 关闭时仍转发他人的消息。';

  @override
  String get stRequireTor => '联网时强制使用 Tor';

  @override
  String get stRequireTorSubtitle => '没有 Tor，任何内容都不会发往服务器';

  @override
  String get stRequireTorFooter =>
      'Tor 启用时，目录与信箱都经由 Tor。否则 Droplet 直接连接：内容仍是端到端加密，但服务器会看到你的 IP 地址。开启此项可禁止直连——代价是 Tor 失效时无法在线收发消息。';

  @override
  String get stMeshNetwork => '网状网络';

  @override
  String get stPeersTopology => '已连接的节点和拓扑结构';

  @override
  String get stOfflineMaps => '离线地图';

  @override
  String get stZonesImport => '已保存区域和地图导入';

  @override
  String get stSecurityHeader => '安全';

  @override
  String get stSecurityFooter => 'Droplet 不会保留您身份的任何副本。没有备份，身份将随设备一同丢失。';

  @override
  String get stBackupIdentity => '备份我的身份';

  @override
  String get stExportEncrypted => '密码加密导出';

  @override
  String get stEmergencyMode => '紧急模式';

  @override
  String get stSignalSafe => '发出您安全的信号';

  @override
  String get stContributionHeader => '贡献';

  @override
  String get stMyContribution => '我的贡献';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => '已激活';

  @override
  String get stProPackUnlocked => '已解锁套餐';

  @override
  String get stProIconsThemes => '图标与背景';

  @override
  String get stCrashLog => '错误日志';

  @override
  String get stAbout => '关于 Droplet';

  @override
  String get stBackgroundRelay => '后台中继';

  @override
  String get stActiveClosed => '即使应用关闭也保持活动';

  @override
  String get stActiveOpenOnly => '仅在应用打开时活动';

  @override
  String get stBatteryOptim => '电池优化';

  @override
  String get stAndroidMayLimit => 'Android 可能会限制中继功能';

  @override
  String get stFix => '修复';

  @override
  String get stKeepActiveTitle => '保持 Droplet 处于活动状态？';

  @override
  String get stKeepActiveBody =>
      '常驻通知将显示 Droplet 正在中继网状网络，即使应用已关闭。作为代价，电池消耗会增加。';

  @override
  String get stEnable => '启用';

  @override
  String get stCancel => '取消';

  @override
  String get stAboutTagline => '离线消息与通话，无需网络或运营商。';

  @override
  String get stAboutDirect => '设备间直接组网——无需服务器';

  @override
  String get stAboutE2E => '所有消息均采用端到端加密';

  @override
  String get stAboutNoThirdParty => '不向第三方传输任何数据';

  @override
  String get stAttributionEmoji =>
      '动态表情符号：Noto Animated Emoji © Google，采用 CC BY 4.0 许可。';

  @override
  String get stAttributionGemma =>
      '助手：Gemma 3 1B-IT © Google，由 litert-community 量化（int4）并由 Droplet 重新发布，遵循 Gemma 使用条款（ai.google.dev/gemma/terms）。';

  @override
  String get stChatBgHeader => '聊天背景';

  @override
  String get stChatPatterns => 'Droplet 涂鸦';

  @override
  String get stChatPatternsSubtitle => '背景上的小线条画';

  @override
  String get stChatBgFooter => '每发送一条消息，渐变就会前进一格。选择「无」可使用纯色背景：不进行任何计算，从而节省电量。';

  @override
  String get stBgFree => '免费';

  @override
  String get stBgPremium => '高级 · 动态';

  @override
  String get stBgNone => '无';

  @override
  String get stBgDefault => '默认';

  @override
  String get stBgThisChat => '此聊天的背景';

  @override
  String get stTextSize => '文字大小';

  @override
  String get stBubbleCorners => '气泡圆角';

  @override
  String get stAccentHeader => '强调色';

  @override
  String get stAccentFooter => '它为整个应用中的气泡、按钮和链接着色。';

  @override
  String get stChatListHeader => '聊天列表';

  @override
  String get stChatListTwoLines => '两行';

  @override
  String get stChatListThreeLines => '三行';

  @override
  String get stResetAppearance => '重置外观';

  @override
  String get stPreviewIncoming => '今晚见？';

  @override
  String get stPreviewOutgoing => '好的，乐意之至！';

  @override
  String get stAppearanceRow => '外观';

  @override
  String get stAppearanceSubtitle => '主题、颜色、文字大小、背景';

  @override
  String get stBgApply => '使用此背景';

  @override
  String get stBgUnlock => '通过高级版解锁';

  @override
  String get stBgApplied => '背景已应用';

  @override
  String get stBgPreviewHint => '背景会流动，每发送一条消息，颜色就会转动。';

  @override
  String get stBgPreviewIncoming => '你看到新背景了吗？';

  @override
  String get stBgPreviewOutgoing => '看到了，太美了 ✨';

  @override
  String get stSoundHeader => '声音';

  @override
  String get stSoundToggle => '应用内声音';

  @override
  String get stSoundSubtitle => '消息、连接、提醒';

  @override
  String get stSoundFooter => '简短提示音，音量与系统通知一致——手机静音或专注模式下不发声。';

  @override
  String get stPacksHeader => '助手 — 离线卡片';

  @override
  String get stPacksToggle => '急救与应急卡片';

  @override
  String get stPacksSubtitle => '助手在急救和应急情况下会参考这些卡片。';

  @override
  String get stPacksFooter =>
      '内置参考卡片（急救、地震、洪水、饮用水…）。当问题相关时，助手会引用卡片而非臆测。它们不能替代培训或拨打急救电话。';

  @override
  String get stPrivateModeHeader => '隐私模式';

  @override
  String get stTorFooter =>
      'Tor 会通过 Tor 网络传输您的 IP 地址和对话以保护隐私。本地网状网络（BLE/WiFi）会照常运行。';

  @override
  String get stTorActiveAnon => '已启用——您的数据已匿名化';

  @override
  String get stTorConnecting => '正在连接…';

  @override
  String get stTorDisabled => '隐私模式已关闭';

  @override
  String get callsTitle => '通话';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个未接来电',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => '新通话';

  @override
  String get callsAll => '全部';

  @override
  String get callsMissed => '未接';

  @override
  String get callsNoneMissed => '没有未接来电';

  @override
  String get callsNone => '没有通话';

  @override
  String get callsMissedEmptyBody => '您未接听的来电将显示在这里。';

  @override
  String get callsEmptyBody => '通话通过本地网络进行，无需运营商或套餐。您的通话记录将显示在这里。';

  @override
  String get callsRetained200 => '最近 200 通通话记录仅保存在此设备上。';

  @override
  String get callsIncoming => '来电';

  @override
  String get callsOutgoing => '去电';

  @override
  String get callsMissedLabel => '未接';

  @override
  String get callsNoAnswer => '无应答';

  @override
  String get callsConnectionFailed => '连接失败';

  @override
  String get callsYesterday => '昨天';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m 分 $s 秒';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s 秒';
  }

  @override
  String get peersTitle => '节点';

  @override
  String get peersSearching => '正在搜索…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '附近有 $count 台设备',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => '网络地图';

  @override
  String get peersNoneInRange => '附近没有人';

  @override
  String get peersNoneInRangeBody => 'Droplet 会持续搜索附近的设备。靠近拥有该应用的人以建立首次连接。';

  @override
  String get peersDirectRange => '直接范围内';

  @override
  String get peersDirectRangeFooter => '这些设备无需通过其他人即可直接联系。';

  @override
  String get peersRelayed => '通过中继';

  @override
  String get peersRelayedFooter => '这些设备不在直接范围内：消息通过其他手机转发给它们。';

  @override
  String get peersRelay => '中继';

  @override
  String get peersCall => '呼叫';

  @override
  String get peersTooSlow => '语音连接过慢——请靠近';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => '蓝牙';

  @override
  String get peersUnknownLink => '未知连接';

  @override
  String get peersDirect => '直接';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 跳中继',
      zero: '直接',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => '此状态已过期';

  @override
  String get svReceiving => '正在接收…';

  @override
  String get svReceivingBody => '文件正通过本地网络传输';

  @override
  String get svProgressLabel => '状态进度';

  @override
  String get svReplyHint => '回复…';

  @override
  String get svSendReply => '发送回复';

  @override
  String get svYourStatus => '您的状态';

  @override
  String get svNoViewsYet => '还没有人查看过这条状态。\n只要您与其他设备相遇，它就会持续传播。';

  @override
  String get svJustNow => '刚刚';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟前',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时前',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => '音乐';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次查看',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个赞',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条回复',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => '原图';

  @override
  String get cpFilterDark => '深色';

  @override
  String get cpFilterBright => '明亮';

  @override
  String get cpFilterVintage => '复古';

  @override
  String get cpWriteStatusHint => '写点什么';

  @override
  String get cpPreparingVideo => '正在处理视频…';

  @override
  String get cpLoadingEllipsis => '加载中…';

  @override
  String cpEndsIn(Object s) {
    return '$s 秒后结束';
  }

  @override
  String get cpModeVideo => '视频';

  @override
  String get cpModePhoto => '照片';

  @override
  String get cpModeMessage => '文字';

  @override
  String get cpModeVoice => '语音';

  @override
  String get gcChooseName => '为群组选择一个名称';

  @override
  String get gcSelectOneMember => '请至少选择一名成员';

  @override
  String get gcCreationFailed => '创建群组失败';

  @override
  String get gcNewGroup => '新建群组';

  @override
  String get gcGroupName => '群组名称';

  @override
  String get gcNameHint => '例如：现场团队';

  @override
  String get gcMembers => '成员';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 位',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => '附近没有人';

  @override
  String get gcGetCloserBody => '靠近另一台运行 Droplet 的设备：节点会自动显示在这里。';

  @override
  String get gcCreateGroup => '创建群组';

  @override
  String get gcConnected => '已连接';

  @override
  String get gcAlreadyMet => '曾经相遇';

  @override
  String get giRenameGroup => '重命名群组';

  @override
  String get giRenameFailed => '重命名失败';

  @override
  String get giNoPeerToAdd => '没有可添加的节点';

  @override
  String get giAddMemberHeader => '添加成员';

  @override
  String get giAddMemberFailed => '添加成员失败';

  @override
  String get giRemoveMemberTitle => '移除该成员？';

  @override
  String get giRemoveMemberBody => '移除后，该成员将无法阅读之后发送的消息。';

  @override
  String get giRemove => '移除';

  @override
  String get giRemoveMemberFailed => '移除成员失败';

  @override
  String get giLeaveGroupTitle => '退出群组？';

  @override
  String get giLeaveGroupBody => '退出后，您将不再收到之后发送的消息。';

  @override
  String get giLeave => '退出';

  @override
  String get giNoOneReachable => '目前没有可通过本地 Wi-Fi 联系到的成员';

  @override
  String get giMax4Participants => '群组通话最多 4 位参与者——仅呼叫前 3 位可联系到的成员';

  @override
  String get giGroupNotFound => '找不到该群组';

  @override
  String get giGroupInfo => '群组信息';

  @override
  String get giGroupCall => '群组通话';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位成员',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => '群组消息已加密';

  @override
  String get giAdd => '添加';

  @override
  String get giMe => '我';

  @override
  String get giAdministrator => '管理员';

  @override
  String get giLeaveGroup => '退出群组';

  @override
  String get sfNoLocationShared => '未分享位置';

  @override
  String get sfLocationShared => '已分享位置';

  @override
  String sfDistanceMeters(Object m) {
    return '距离 $m 米';
  }

  @override
  String sfDistanceKm(Object km) {
    return '距离 $km 公里';
  }

  @override
  String get sfBearingN => '北方';

  @override
  String get sfBearingNE => '东北方';

  @override
  String get sfBearingE => '东方';

  @override
  String get sfBearingSE => '东南方';

  @override
  String get sfBearingS => '南方';

  @override
  String get sfBearingSW => '西南方';

  @override
  String get sfBearingW => '西方';

  @override
  String get sfBearingNW => '西北方';

  @override
  String get sfBroadcastSafeTitle => '广播\"我很安全\"？';

  @override
  String get sfBroadcastSafeMessage =>
      '此状态将对附近整个网状网络可见，而不仅仅是你的联系人。你可以附加大致位置（经过取整，绝不精确）。';

  @override
  String get sfWithLocation => '附带大致位置';

  @override
  String get sfWithoutLocation => '不附带位置';

  @override
  String get sfStatusBroadcast => '状态已广播至网状网络';

  @override
  String get sfBroadcastFailed => '广播失败';

  @override
  String get sfHelpRequestTitle => '广播\"我需要帮助\"？';

  @override
  String get sfHelpRequestMessage => '此状态会告知附近的节点你需要帮助。你可以附加大致位置。';

  @override
  String get sfHelpRequestBroadcast => '求助请求已广播至网状网络';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => '紧急模式';

  @override
  String get sfViewOnMap => '在地图上查看';

  @override
  String get sfNeedHelp => '我需要帮助';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已收到签到（$count）',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => '目前尚未收到任何签到';

  @override
  String get sfCheckinsAppearHere => '附近节点广播的\"安全\"状态将显示在这里。';

  @override
  String get sfSafeLabel => '安全';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return '安全 · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return '安全 · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel => '将我的安全状态广播至网状网络';

  @override
  String get sfImSafe => '我很安全';

  @override
  String get emSosActive => 'SOS 已激活';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription => 'SOS 信号已激活——正在广播至附近所有设备';

  @override
  String get emPullToSendSignal => '点击发送紧急信号';

  @override
  String get emSignalRelayedDescription => '信号在节点之间中继传递\n覆盖整个网状网络。';

  @override
  String get emBroadcasting => '广播中…';

  @override
  String get emSharePosition => '分享我的位置';

  @override
  String get emSosActivated => 'SOS 信号已激活';

  @override
  String get emSafeStatusMessage => '🟢 我很安全';

  @override
  String get emSafetyStatusBroadcast => '安全状态已广播';

  @override
  String get pmEnterPayingNumber => '输入将用于付款的号码（9 位数字）。';

  @override
  String get pmRequestSent => '请求已发送…';

  @override
  String get pmPaymentLaunchFailed => '无法启动付款。请检查号码和网络连接，或在下方手动付款。';

  @override
  String get pmValidateOnPhone => '在手机上确认：提示出现时输入你的 Mobile Money 密码。';

  @override
  String get pmPaymentNotConfirmed => '付款未确认。未解锁任何内容。';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return '付款已成功，但收到的许可证无效。请联系我们，我们会重新生成：$contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro 已激活';

  @override
  String get pmPackUnlocked => '套装已解锁';

  @override
  String get pmInvalidCode => '此代码在本设备上无效。请确认你已发送上方显示的设备代码。';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'Droplet\n绝不会索取的东西';

  @override
  String get pmNeverAskBody =>
      '没有广告，没有强制订阅，也不会转卖你的数据——甚至根本没有服务器来收集它们。套装和 Pro 为其余部分提供资金。';

  @override
  String get pmCommunitySemantics => '加入超过 1200 名活跃成员的社区';

  @override
  String get pmCommunityText => '加入网状网络上超过 1200 名成员';

  @override
  String get pmProPreviewSemantics => '已解锁 Pro 功能预览';

  @override
  String get pmAnimatedEmojis => '动态\n表情符号';

  @override
  String get pmWallpapers => '聊天\n壁纸';

  @override
  String get pmAppIcons => '应用\n图标';

  @override
  String get pmOnceForLife => '一次性，终身有效';

  @override
  String get pmProAdvantage1 => '套装中的十个图标和八张壁纸';

  @override
  String get pmProAdvantage2 => '姓名旁的 Pro 徽章';

  @override
  String get pmProAdvantage3 => '未来功能，无需额外付费';

  @override
  String get pmPackTitle => '套装';

  @override
  String get pmOnce => '一次性';

  @override
  String get pmPackAdvantage1 => '十个额外的应用图标';

  @override
  String get pmPackAdvantage2 => '八张聊天壁纸';

  @override
  String get pmPayByHand => '或手动付款';

  @override
  String get pmHowTo => '操作方法';

  @override
  String get pmIfPromptDoesNotArrive => '如果提示未出现在你的手机上，或者你更愿意自己转账。';

  @override
  String pmStep1Title(Object montant) {
    return '汇款 $montant F';
  }

  @override
  String get pmStep1Body => '选择你的运营商：它的菜单会打开，浏览菜单时号码会一直显示在这里。';

  @override
  String get pmStep2Title => '发送你的设备代码';

  @override
  String get pmStep2Body => '连同付款截图一起发送。没有这个代码，就无法生成许可证——它只对你的手机有效。';

  @override
  String get pmStep3Title => '你会收到一个许可证';

  @override
  String get pmStep3Body => '一长串以 DROP1 开头的字符。粘贴到下方：解锁立即生效，且永久离线可用。';

  @override
  String get pmPayNow => '立即付款';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money 或 Orange Money，可用此手机或其他手机操作。';

  @override
  String get pmPhoneNumberSemantics => '用于 Mobile Money 付款的电话号码';

  @override
  String get pmWaitingForCode => '正在等待你的验证码…';

  @override
  String pmPayAmount(Object montant) {
    return '支付 $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => '恢复之前的购买';

  @override
  String get pmAlreadyPaidRestore => '已经付款？恢复购买';

  @override
  String pmDialCode(Object code) {
    return '在你的手机上拨打 $code';
  }

  @override
  String get pmChooseOperatorSemantics => '选择支付运营商';

  @override
  String get pmNumberAmountFilled => '号码和金额已自动填写——只需输入你的密码。';

  @override
  String get pmOrangeMenuInstructions => '在 Orange 菜单中：选择转账，然后输入下方的号码和金额。';

  @override
  String get pmLabelNumber => '号码';

  @override
  String get pmLabelAmount => '金额';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return '通过 $operator 支付 $montant 法郎';
  }

  @override
  String get pmMenuOpen => '菜单已打开';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return '你好，我刚为 Droplet 付款。\n\n方案：$offer\n金额：$amount F\n设备代码：$code\n\n（附上付款截图）';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return '未找到 WhatsApp——代码已复制。请发送至 $contact';
  }

  @override
  String get pmPrepareRequest => '准备我的请求';

  @override
  String get pmReceivedLicense => '我已收到我的许可证';

  @override
  String get pmPaste => '粘贴';

  @override
  String get pmUnlock => '解锁';

  @override
  String get pmProIsActive => 'Droplet Pro 已激活';

  @override
  String get pmPackIsUnlocked => '套装已解锁';

  @override
  String get pmProActiveDescription => 'Pro 徽章将显示在你的名字旁，所有图标和壁纸都已为你解锁。';

  @override
  String get pmPackActiveDescription => '套装中的十个图标和八张壁纸已在设置中为你解锁。';

  @override
  String get pmLicenseDeviceBound =>
      '你的许可证仅对此手机有效。如果你更换手机，请保留包含许可证的消息：我们会免费为你重新生成。';

  @override
  String torError(Object e) {
    return '错误：$e';
  }

  @override
  String get torEnable => '启用 Tor';

  @override
  String get torProtected => '已受保护';

  @override
  String get torDisabled => '已禁用';

  @override
  String get torStateHeader => '状态';

  @override
  String get torCircuit => '电路';

  @override
  String get torActive => '活动';

  @override
  String get torInProgress => '进行中…';

  @override
  String get torInactive => '未激活';

  @override
  String get torFailed => '失败';

  @override
  String get torReason => '原因';

  @override
  String get torBannerConnecting => '正在连接 Tor…';

  @override
  String get torBannerActive => 'Tor 已启用';

  @override
  String get torBannerError => 'Tor 不可用';

  @override
  String get torBannerOff => 'Tor 已关闭';

  @override
  String get torEncryption => '加密';

  @override
  String get torLatency => '延迟';

  @override
  String get torContactsHeader => '联系人';

  @override
  String get torScanQrFooter => '扫描二维码，或在通讯录中搜索名称，即可添加远程联系人。';

  @override
  String get torScanQrCode => '扫描二维码';

  @override
  String get torMyQrCode => '我的二维码';

  @override
  String get torInformationHeader => '信息';

  @override
  String get torVersion => '版本';

  @override
  String get torHowItWorks => '它是如何运作的？';

  @override
  String get torConnecting => '连接中…';

  @override
  String get torInactiveTitle => 'Tor 未激活';

  @override
  String get torDataThroughTor => '你的数据通过 Tor 网络传输';

  @override
  String get torEstablishingCircuit => '正在建立电路（10-30 秒）';

  @override
  String get torActivateToProtect => '开启以保护你的身份';

  @override
  String get torHowItWorksTitle => 'Tor 如何保护你的数据';

  @override
  String get torEncryptedCircuit => '加密电路';

  @override
  String get torEncryptedCircuitDesc => '你的消息会经过全球 3 个 Tor 中继节点。';

  @override
  String get torHiddenIp => 'IP 已隐藏';

  @override
  String get torHiddenIpDesc => '任何网站都无法看到你的真实地址。';

  @override
  String get torMeshPreserved => '网状网络保持不变';

  @override
  String get torMeshPreservedDesc => '蓝牙和本地 Wi-Fi 仍可正常使用。';

  @override
  String get torUnderstood => '知道了';

  @override
  String get qrTorNotActive => 'Tor 未激活。请在设置 > Tor 中启用。';

  @override
  String get qrScanContactCode => '扫描联系人的二维码';

  @override
  String get qrCodeFromContactScreen => '该代码必须来自你联系人的 Tor 界面';

  @override
  String get qrScanAnother => '扫描其他';

  @override
  String get qrChat => '聊天';

  @override
  String get qgScanToConnect => '扫描以连接';

  @override
  String get qgCopied => '已复制 ✓';

  @override
  String get qgCopyCode => '复制代码';

  @override
  String get qgHowItWorks => '工作原理';

  @override
  String get qgStep1 => '向你的联系人展示此二维码';

  @override
  String get qgStep2 => '对方通过其 Tor 界面扫描';

  @override
  String get qgStep3 => '你们已通过 Tor 建立连接';

  @override
  String get shShareTo => '分享至…';

  @override
  String get shSearchConversation => '搜索对话';

  @override
  String get shNoConversation => '没有对话';

  @override
  String get shOpenChatFirst => '请先在 Droplet 中打开一个对话，才能在其中分享内容。';

  @override
  String get shGroup => '群组';

  @override
  String get shDiscussion => '对话';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项要分享的内容',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => '地图已安装';

  @override
  String get omClearCacheTitle => '要清除缓存吗？';

  @override
  String get omRemoveZoneTitle => '要删除此区域吗？';

  @override
  String get omClearCacheMessage => '你浏览过的区域将不再可离线使用。重新联网查看时会自动重新缓存。';

  @override
  String omRemoveZoneMessage(Object name) {
    return '「$name」将从此设备中删除。';
  }

  @override
  String get omClear => '清除';

  @override
  String get omTitle => '地图';

  @override
  String get omReading => '读取中…';

  @override
  String get omNoMapsSaved => '没有已保存的地图';

  @override
  String omSizeOnDevice(Object size) {
    return '此设备上有 $size';
  }

  @override
  String get omBrowseMapHint => '联网浏览地图：你查看过的区域会保持离线可用。';

  @override
  String get omOnThisDevice => '此设备上';

  @override
  String get omZonesFillThemselves => '联网浏览地图时，已查看的区域会自动填充缓存。';

  @override
  String get omMbtilesExplainer =>
      '一个 .mbtiles 文件包含预先准备好的整片区域。它是离线地图的标准格式，任何制图工具都能生成。';

  @override
  String get omImportMap => '导入地图';

  @override
  String get omReadingFile => '正在读取文件…';

  @override
  String get omMbtilesFromPhone => '来自此手机的 .mbtiles 文件';

  @override
  String get omAttributionText =>
      '数据来自 OpenStreetMap（ODbL 许可），地图底图由 CARTO 提供。Droplet 从不预先下载整片区域：没有任何免费服务允许这样做。只会保留你实际查看过的内容。';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个瓦片',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '${k}k 个瓦片';
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
  String get nwTitle => '动态';

  @override
  String get nwStatusesNetwork24h => '网络状态 · 24 小时';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条网络状态',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => '发布状态';

  @override
  String get nwNoNewsYet => '暂时没有动态';

  @override
  String get nwStatusesAppearHere => '附近人员发布的状态会显示在这里，无需经过互联网。';

  @override
  String get nwRecent => '最近';

  @override
  String get nwStatusExpires => '状态会在发布 24 小时后自动消失。';

  @override
  String get nwPhoto => '📷 照片';

  @override
  String get nwVideo => '🎥 视频';

  @override
  String get nwVoiceMessage => '🎤 语音消息';

  @override
  String get nwMusic => '🎵 音乐';

  @override
  String get nwStatusFallback => '状态';

  @override
  String get nwMyStatus => '我的状态';

  @override
  String get nwTapToPublish => '点击以发布到网络';

  @override
  String get nwNotSeenYet => '尚未查看';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人已查看',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable => '位置不可用——请检查定位服务是否已开启。';

  @override
  String mpDistanceMeters(Object m) {
    return '$m 米';
  }

  @override
  String mpDistanceKm(Object km) {
    return '$km 公里';
  }

  @override
  String mpDistanceFromYou(Object distance) {
    return '距你 $distance';
  }

  @override
  String get mpTitle => '定位';

  @override
  String get mpOffline => '离线';

  @override
  String get mpOnlineMap => '在线地图';

  @override
  String get mpMyPosition => '我的位置';

  @override
  String get mpLayers => '图层';

  @override
  String get mpOfflineToast => '离线地图：仅显示已保存的区域。';

  @override
  String get mpOnlineToast => '在线地图：你查看过的区域将被保存以供日后使用。';

  @override
  String get mpMapLabel => '地图';

  @override
  String get mpSatelliteLabel => '卫星';

  @override
  String get mpSatelliteMode => '卫星模式';

  @override
  String get mpMapMode => '地图模式';

  @override
  String get mpWrite => '写消息';

  @override
  String get mpCenter => '居中';

  @override
  String get mpNoOneOnMap => '地图上没有任何人';

  @override
  String get mpPositionsAppearHere => '当联系人从安全模式分享位置时，位置会显示在这里。';

  @override
  String get mpYou => '你';

  @override
  String get mnTitle => '网状网络';

  @override
  String get mnPeers => '节点';

  @override
  String get mnAvgHops => '平均跳数';

  @override
  String get mnSignal => '信号';

  @override
  String get mnStrong => '强';

  @override
  String get mnMedium => '中等';

  @override
  String get mnSearchingPeers => '正在搜索附近的节点…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已连接 $count 个节点',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => '目前没有已连接的节点';

  @override
  String get mnGetCloserHint => '靠近另一台安装了 Droplet 的设备——发现过程自动完成，无需任何配置。';

  @override
  String get mnConnectedPeersHeader => '已连接的节点';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 跳',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => '蓝牙';

  @override
  String get mnWifiLocal => '本地 Wi-Fi';

  @override
  String get mnP2pNative => '原生 P2P';

  @override
  String get mnActiveGateway => '活动网关';

  @override
  String get mnPath => '路径';

  @override
  String get mnTransport => '传输方式';

  @override
  String get mnBattery => '电池';

  @override
  String get mnScore => '评分';

  @override
  String get mnReconnecting => '正在重新连接';

  @override
  String get cnBronze => '青铜';

  @override
  String get cnSilver => '白银';

  @override
  String get cnGold => '黄金';

  @override
  String get cnDiamond => '钻石';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '距 $tier 等级还差 $points';
  }

  @override
  String get cnRelayedMessages => '为他人转发的消息';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n 分';
  }

  @override
  String get cnGatewayMinutes => '中继模式（网关）持续分钟数';

  @override
  String get cnExplanation =>
      '你的设备为他人转发的每一条消息，以及作为中继保持可用的每一分钟，都在帮助网状网络覆盖更多、更远的用户。此徽章对应用没有任何实际影响——它只是对你贡献的一种认可。';

  @override
  String get nmTitle => '新消息';

  @override
  String get nmNewGroup => '新建群组';

  @override
  String get nmScanCode => '扫描代码';

  @override
  String get nmVerifyContactIdentity => '验证联系人身份';

  @override
  String get nmNoOneInRange => '附近没有任何人';

  @override
  String get nmNoResult => '没有结果';

  @override
  String get nmPeopleWillAppearHere => '你设备检测到的人会显示在这里。';

  @override
  String get nmInRange => '附近';

  @override
  String get nmDirectConnection => '直接连接';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '通过 $count 个中继',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => '文件过大（最大 50 MB）';

  @override
  String get chCannotReadMedia => '无法读取此媒体文件';

  @override
  String get chLocationDenied => '定位被拒绝——请在手机设置中启用定位以分享你的位置。';

  @override
  String get chGettingPosition => '正在获取位置…';

  @override
  String get chPositionUnavailable => '位置不可用——请在户外重试。';

  @override
  String get chMicPermissionDenied => '麦克风权限被拒绝';

  @override
  String get chCannotStartRecording => '无法开始录音';

  @override
  String get chVoiceSendFailed => '无法发送语音消息';

  @override
  String get chFileSendFailed => '无法发送文件';

  @override
  String get chAudioNotFullyReceived => '音频尚未完全接收';

  @override
  String get chVoiceUnreadable => '此语音消息无法播放——可能接收不完整。';

  @override
  String get chFileNotFullyReceived => '文件尚未完全接收';

  @override
  String get chSaveFailed => '无法保存';

  @override
  String chSavedIn(Object folder) {
    return '已保存到 $folder';
  }

  @override
  String get chMessageCopied => '消息已复制';

  @override
  String get chCallImpossibleRelay =>
      '无法进行语音通话：该节点只能通过中继或蓝牙连接，速度太慢无法支持语音。请靠近以切换到 Wi-Fi。';

  @override
  String chUrlCopied(Object url) {
    return '链接已复制：$url';
  }

  @override
  String get chEditMessageTitle => '编辑消息';

  @override
  String get chMessageHint => '消息';

  @override
  String get chNeverMet => '从未见过';

  @override
  String get chSeenJustNow => '刚刚上线';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟前上线',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时前上线',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => '昨天上线';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前上线',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => '超出范围';

  @override
  String get chCloseSearchTooltip => '关闭搜索';

  @override
  String get chNetworkDetailsSemantics => 'Droplet 网络，查看详情';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 名成员',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => '正在输入…';

  @override
  String get chBroadcastChannel => '广播频道';

  @override
  String get chNearby => '附近';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '通过 $count 个中继可达',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => '正在重新连接…';

  @override
  String get chSearchInConversation => '在对话中搜索';

  @override
  String get chVoiceCall => '语音通话';

  @override
  String get chVideoCall => '视频通话';

  @override
  String get chCallImpossibleBtRelay => '无法通话：蓝牙或中继连接';

  @override
  String get chGroupInfoTooltip => '群组信息';

  @override
  String get chNoneFound => '无';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => '更早的结果';

  @override
  String get chNewerResult => '更新的结果';

  @override
  String get chLoadingOlderMessages => '正在加载更早的消息…';

  @override
  String get chToday => '今天';

  @override
  String get chYesterday => '昨天';

  @override
  String get chMonday => '星期一';

  @override
  String get chTuesday => '星期二';

  @override
  String get chWednesday => '星期三';

  @override
  String get chThursday => '星期四';

  @override
  String get chFriday => '星期五';

  @override
  String get chSaturday => '星期六';

  @override
  String get chSunday => '星期日';

  @override
  String get chSayHello => '打个招呼 👋';

  @override
  String get chBroadcastEmptyBody => '没有指定收件人的消息会显示在这里。';

  @override
  String get chP2pRelayedBody => '你们的交流通过点对点中继，无需互联网。';

  @override
  String get chReply => '回复';

  @override
  String get chReplyInThread => '在话题中回复';

  @override
  String get chCopy => '复制';

  @override
  String get chAccessibilityMe => '我';

  @override
  String get chPhotoLabel => '照片';

  @override
  String get chVideoLabel => '视频';

  @override
  String get chVoiceMessageLabel => '语音消息';

  @override
  String chFileLabel(Object name) {
    return '文件 $name';
  }

  @override
  String chStickerLabel(Object name) {
    return '贴纸 $name';
  }

  @override
  String get chSendingStatus => '发送中';

  @override
  String get chPendingStatus => '等待中';

  @override
  String get chFailedStatus => '发送失败';

  @override
  String get chReadStatus => '已读';

  @override
  String get chDeliveredStatus => '已送达';

  @override
  String get chSentStatus => '已发送';

  @override
  String get chForwarded => '已转发';

  @override
  String get chRetrySendLabel => '重试发送';

  @override
  String get chTransmissionDetailsLabel => '传输详情';

  @override
  String get chEditedBadge => '已编辑';

  @override
  String get chFileWord => '文件';

  @override
  String chSizeBytes(Object n) {
    return '$n 字节';
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
  String get chVideoReceiving => '视频接收中';

  @override
  String get chPreparingVideo => '正在准备视频…';

  @override
  String get nmContacts => '联系人';

  @override
  String get nmFindByPseudo => '按用户名查找';

  @override
  String get nmViaInternet => '通过互联网';

  @override
  String get nmOutOfRange => '不在范围内';

  @override
  String get chatsInvitePerson => '邀请好友';

  @override
  String get ivTitle => '邀请你的亲友';

  @override
  String get ivSubtitle => '重要的人都在，Droplet 才更好用——即使没有网络。';

  @override
  String get ivByNumber => '通过手机号';

  @override
  String get ivNumberHint => '带国家码的号码（+86…）';

  @override
  String get ivContacts => '联系人';

  @override
  String get ivSms => '短信';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => '通过链接';

  @override
  String get ivCopy => '复制';

  @override
  String get ivShare => '分享';

  @override
  String get ivCopied => '链接已复制';

  @override
  String get ivByQr => '通过二维码';

  @override
  String get ivQrHint => '当面让对方扫描。';

  @override
  String get ivScan => '扫描二维码';

  @override
  String get ivPrivacy => '链接和二维码只包含你的公开 ID 和密钥，不会向 Droplet 发送任何号码。';

  @override
  String get evTitle => '编辑视频';

  @override
  String evSplit(int n) {
    return '拆分为 $n 条动态';
  }

  @override
  String evSplitHint(int s) {
    return '每段最长 $s 秒';
  }

  @override
  String evPublished(int n) {
    return '已发布 $n 条动态';
  }

  @override
  String get svReply => '回复';

  @override
  String get svStatusLabel => '动态';

  @override
  String svSeenBy(int n) {
    return '$n 人已看';
  }

  @override
  String get clMissedVoice => '未接语音通话';

  @override
  String get clMissedVideo => '未接视频通话';

  @override
  String get clCallBack => '回拨';

  @override
  String get stoTitle => '存储空间';

  @override
  String get stoSubtitle => '照片、视频和文件';

  @override
  String stoUsed(String taille) {
    return '已使用 $taille';
  }

  @override
  String get stoPhotos => '照片';

  @override
  String get stoVideos => '视频';

  @override
  String get stoAudio => '语音和音频';

  @override
  String get stoDocuments => '文档';

  @override
  String get stoOther => '其他（动态…）';

  @override
  String get stoByChat => '按聊天';

  @override
  String get stoEmpty => '此手机上没有文件';

  @override
  String stoDelete(int n) {
    return '删除（$n）';
  }

  @override
  String get stoDeleteConfirm => '这些文件及其消息将从此手机删除。';

  @override
  String get tabSelectChat => '选择一个聊天';

  @override
  String get clConnecting => '正在连接…';

  @override
  String chUnreadMessages(int n) {
    return '$n 条未读消息';
  }

  @override
  String get csMessagesSection => '消息';

  @override
  String chGroupTyping(String noms) {
    return '$noms 正在输入…';
  }

  @override
  String get tsReadBy => '已读';

  @override
  String get tsDeliveredTo => '已送达';

  @override
  String get tsWaitingFor => '等待中';

  @override
  String get chSelect => '选择';

  @override
  String get chForward => '转发';

  @override
  String get chForwardTo => '转发给…';

  @override
  String chSelectedCount(int n) {
    return '已选择 $n 条';
  }

  @override
  String get chForwarded1 => '消息已转发';

  @override
  String get apCaptionHint => '添加说明…';

  @override
  String get apValidateCrop => '裁剪';

  @override
  String get chMediaReceiving => '正在接收';

  @override
  String get chStickersTooltip => '贴纸';

  @override
  String get chAttachTooltip => '附加';

  @override
  String get chDeleteRecordingTooltip => '删除录音';

  @override
  String get chSlideToCancel => '滑动以取消';

  @override
  String chReplyingTo(Object pseudo) {
    return '回复 $pseudo';
  }

  @override
  String get chEffectBoom => '爆炸';

  @override
  String get chEffectLoud => '大声';

  @override
  String get chEffectGentle => '轻柔';

  @override
  String get chEffectInvisibleInk => '隐形墨水';

  @override
  String get chEffectConfetti => '彩纸';

  @override
  String get chEffectFireworks => '烟花';

  @override
  String get chEffectHearts => '爱心';

  @override
  String get chEffectSheetTitle => '消息特效';

  @override
  String get chEffectSheetSubtitle => '仅播放一次，在你和对方的屏幕上';

  @override
  String get chOnBubble => '在气泡上';

  @override
  String get chFullscreen => '全屏';

  @override
  String get chTapToReveal => '点击显示';

  @override
  String get chThreadTitle => '话题';

  @override
  String get chReplyHint => '回复…';

  @override
  String get chCollapse => '收起';

  @override
  String get chSeeMore => '查看更多';

  @override
  String get chMessageOptionsSemantics => '消息选项';

  @override
  String get chLoveReactionSemantics => '超喜欢';

  @override
  String get chBroadcastMesh => '网状广播';

  @override
  String get chGroupFallback => '群组';

  @override
  String get ciSetupBiometrics => '请在设备设置中启用指纹或面容 ID。';

  @override
  String get ciEnableLockReason => '为此对话启用锁定';

  @override
  String get ciInfoTitle => '信息';

  @override
  String get ciViewConversation => '查看对话';

  @override
  String get ciGatewayOnline => '网关 · 在线';

  @override
  String get ciOnline => '在线';

  @override
  String get ciOffline => '离线';

  @override
  String get ciMessages => '消息';

  @override
  String get ciMedia => '媒体';

  @override
  String get ciStart => '开始';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '照片（$count）',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '语音笔记（$count）',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '文件（$count）',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => '目前还没有分享任何媒体内容。';

  @override
  String get ciSecurityCode => '安全代码';

  @override
  String get ciVerified => '已验证';

  @override
  String get ciKeyChanged => '密钥已更改';

  @override
  String get ciNotVerified => '未验证';

  @override
  String get ciConversationLock => '对话锁定';

  @override
  String get ciLockEnabled => '已启用——打开需要指纹验证';

  @override
  String get ciDisabled => '已禁用';

  @override
  String get ciEphemeralMessages => '阅后即焚消息';

  @override
  String get ci30Seconds => '30 秒';

  @override
  String get ci5Minutes => '5 分钟';

  @override
  String get ci1Hour => '1 小时';

  @override
  String get ci24Hours => '24 小时';

  @override
  String get ciDurationBeforeDisappear => '消失前的时长';

  @override
  String get ciBlockContactTitle => '要屏蔽此联系人吗？';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo 将无法再向你发送消息。你可以随时取消屏蔽。';
  }

  @override
  String get ciBlock => '屏蔽';

  @override
  String get ciUnblock => '取消屏蔽';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo 已被屏蔽';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo 已取消屏蔽';
  }

  @override
  String get ciReportContactTitle => '要举报此联系人吗？';

  @override
  String ciReportContactBody(Object pseudo) {
    return '将向 Droplet 发送一份匿名举报：仅包含一个技术标识符和下面选择的举报原因，仅此而已。与 $pseudo 的任何消息或对话内容都绝不会被发送。';
  }

  @override
  String get ciReport => '举报';

  @override
  String get ciReportSent => '举报已发送，谢谢。';

  @override
  String get ciReportFailed => '举报发送失败，请稍后重试。';

  @override
  String get ciReportReasonSpam => '垃圾信息';

  @override
  String get ciReportReasonHarassment => '骚扰';

  @override
  String get ciReportReasonIllegal => '违法内容';

  @override
  String get ciReportReasonOther => '其他';

  @override
  String mcReactWith(Object emoji) {
    return '使用 $emoji 回应';
  }

  @override
  String get nsMeshActive => '网状网络已激活';

  @override
  String get nsNoDeviceInRange => '附近没有设备';

  @override
  String get nsMessagesCirculate => '你的消息在设备间传递，无需经过互联网。';

  @override
  String get nsGetCloser => '靠近另一台 Droplet 设备。你的消息会被保留，并在有信号时自动发送。';

  @override
  String get nsDevicesInRange => '附近的设备';

  @override
  String get nsReconnectingTitle => '正在重新连接';

  @override
  String get nsLinkMomentarilyLost => '连接暂时中断，尚未放弃重连。';

  @override
  String get nsRelaysAvailable => '可用中继';

  @override
  String get nsNoRelayAvailable => '目前没有设备可以将你的消息转发到更远的地方。';

  @override
  String get nsViaBluetooth => '通过蓝牙';

  @override
  String get nsViaLocalWifi => '通过本地 Wi-Fi';

  @override
  String get nsWifiCarriesMore => 'Wi-Fi 可传输文件和语音；蓝牙仅可传输文字。';

  @override
  String get scInvalidQrCode => '二维码无效';

  @override
  String get scWrongCode => '代码不匹配——密钥不一致';

  @override
  String get scCodeVerified => '代码已验证';

  @override
  String scVerifiedBanner(Object pseudo) {
    return '已验证——$pseudo 的密钥与此代码匹配。';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return '自上次验证以来，$pseudo 的密钥已更改。';
  }

  @override
  String get scNotVerifiedYet => '尚未验证。';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return '将此代码与 $pseudo 设备上显示的代码进行比对，或直接扫描对方的二维码以自动验证。';
  }

  @override
  String get scContactKeyUnknown => '尚不知道联系人的密钥——请重新连接到该网状网络节点。';

  @override
  String scScanCodeOf(Object pseudo) {
    return '扫描 $pseudo 的代码';
  }

  @override
  String get tsNotDelivered => '未送达';

  @override
  String get tsRead => '已读';

  @override
  String get tsDelivered => '已送达';

  @override
  String get tsSendingInProgress => '发送中';

  @override
  String get tsWaitingForRelay => '等待中继';

  @override
  String get tsSent => '已发送';

  @override
  String tsSecondsSingular(Object value) {
    return '$value 秒';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value 秒';
  }

  @override
  String tsMinutes(Object n) {
    return '$n 分钟';
  }

  @override
  String tsHours(Object n) {
    return '$n 小时';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => '传输';

  @override
  String get tsStatus => '状态';

  @override
  String get tsDelayUntilRead => '到已读所需时间';

  @override
  String get tsRoute => '路线';

  @override
  String get tsRouteDetail => '转发此消息的设备，按顺序排列。';

  @override
  String get tsPath => '路径';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '经过 $count 台设备',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => '直接接收';

  @override
  String get tsIntermediateDevicesDetail => '中间设备将此消息转发给了你。';

  @override
  String get tsUnknown => '未知';

  @override
  String get tsSentRouteNotReturned => '已发送消息的路径不会回传给发送者。';

  @override
  String get tsNetwork => '网络';

  @override
  String get tsMeshDroplet => 'Droplet 网状网络';

  @override
  String get tsNoServerNoOperator => '无服务器，无运营商。';

  @override
  String get qsScanSecurityCode => '扫描安全代码';

  @override
  String get qsCodeDetected => '已检测到代码';

  @override
  String get qsFrameQrCode => '将镜头对准联系人设备上显示的二维码';

  @override
  String get rmRecentVideo => '最近的视频';

  @override
  String get rmRecentPhoto => '最近的照片';

  @override
  String get rmSeeAllPhotos => '查看所有照片';

  @override
  String get rmSeeAll => '查看全部';

  @override
  String get aicOriginal => '原版';

  @override
  String get aicAzure => '天蓝';

  @override
  String get aicNeon => '霓虹';

  @override
  String get aicPaper => '纸张';

  @override
  String get aicLagoon => '潟湖';

  @override
  String get aicAmethyst => '紫水晶';

  @override
  String get aicGold => '黄金';

  @override
  String get aicTide => '潮汐';

  @override
  String get aicDawn => '曙光';

  @override
  String get aicGlass => '玻璃';

  @override
  String get aicConstellation => '星座';

  @override
  String get aicPrism => '棱镜';

  @override
  String get aicEmerald => '翡翠';

  @override
  String get aicChangeIconTitle => '要更改图标吗？';

  @override
  String aicChangeIconMessage(Object name) {
    return '「$name」图标将替换主屏幕上的图标。部分启动器可能需要几秒钟才能显示，或需要返回主屏幕。';
  }

  @override
  String get aicApply => '应用';

  @override
  String aicIconApplied(Object name) {
    return '已应用「$name」图标';
  }

  @override
  String get aicChangeIconImpossible => '此设备无法更改图标';

  @override
  String get aicTitle => '图标';

  @override
  String get aicCurrentOnHomeScreen => '显示在主屏幕上的图标';

  @override
  String get aicUnavailablePlatform => '此平台不支持';

  @override
  String get aicAndroidExplanation =>
      'Android 会在安装时固定应用图标。Droplet 通过声明多个入口点（每个图标一个）并仅保留一个处于活动状态来绕过此限制。你的启动器可能需要几秒钟才能注意到变化。';

  @override
  String get aicAndroidOnly => '更改图标功能仅适用于 Android。';

  @override
  String get beWeak => '弱';

  @override
  String get beOkay => '尚可';

  @override
  String get beStrong => '强';

  @override
  String get bePasswordTooShort => '密码长度至少需要 8 个字符';

  @override
  String get bePasswordsDontMatch => '两次输入的密码不一致';

  @override
  String get beBackupSubject => 'Droplet 备份';

  @override
  String get beBackupShareText => '我的 Droplet 身份的加密备份——请妥善保管。';

  @override
  String get beBackupCreated => '备份已创建';

  @override
  String get beBackupFailed => '备份失败';

  @override
  String get beBackupMyIdentity => '备份我的身份';

  @override
  String get beWarningBody =>
      '任何拥有此文件和密码的人都可以冒充你。请妥善保管（切勿发送给自己以外的任何人），并选择一个只有你自己知道的密码。';

  @override
  String get bePasswordProtects => '此密码用于保护你的备份。它绝不会被保存：一旦丢失，该文件将永久无法使用。';

  @override
  String get bePassword => '密码';

  @override
  String get beConfirmPassword => '确认密码';

  @override
  String get beIncludeMessageHistory => '包含消息记录';

  @override
  String get beOtherwiseOnlyIdentity => '否则，仅备份身份、联系人和群组';

  @override
  String get beCreateAndShare => '创建并分享备份';

  @override
  String get jsErrorJournalTitle => '错误日志';

  @override
  String get jsNoErrorsRecorded => '未记录任何错误。这是正常情况。';

  @override
  String get jsLinesStayOnDevice =>
      '这些日志仅保留在此设备上：Droplet 没有服务器可以发送它们。如果你正在测试此应用，请将它们发送出来——没有它们，这个问题就无人知晓。';

  @override
  String get jsErase => '清除';

  @override
  String get jsShareSubject => 'Droplet — 错误日志';

  @override
  String get jsShareText => 'Droplet 错误日志。此文件不包含任何消息、联系人或密钥。';

  @override
  String get jsShareUnavailable => '分享不可用——日志已复制';

  @override
  String get clOutgoingCall => '正在呼叫…';

  @override
  String get clIncomingCall => '来电…';

  @override
  String get clCallImpossible => '无法通话';

  @override
  String get clCallEnded => '通话已结束';

  @override
  String clCallWith(Object pseudo) {
    return '与 $pseudo 通话';
  }

  @override
  String get clEndToEndEncrypted => '端到端加密';

  @override
  String clCallStatusSemantics(Object status) {
    return '通话状态：$status';
  }

  @override
  String get clEnableMic => '开启麦克风';

  @override
  String get clMuteMic => '静音麦克风';

  @override
  String get clDisableSpeaker => '关闭扬声器';

  @override
  String get clEnableSpeaker => '开启扬声器';

  @override
  String get clDisableCamera => '关闭摄像头';

  @override
  String get clEnableCamera => '开启摄像头';

  @override
  String get clHangUp => '挂断';

  @override
  String get clIncomingVideoCall => '视频来电';

  @override
  String get clSwitchCamera => '切换摄像头';

  @override
  String get gcGroupCall => '群组通话';

  @override
  String get gcConnecting => '正在连接…';

  @override
  String get gcOnline => '在线';

  @override
  String get gcFailed => '失败';

  @override
  String get gcDisconnected => '已断开';

  @override
  String get gcReturnToCall => '返回通话';

  @override
  String get gcMinimize => '最小化';

  @override
  String get gcVoiceOnly => '仅语音';

  @override
  String gcReactWith(String emoji) {
    return '用 $emoji 回应';
  }

  @override
  String get gcSpeakingNow => '正在讲话';

  @override
  String get gcMicOff => '麦克风已关闭';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位参与者 · 仅语音',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => '消息';

  @override
  String get ntfChannelMessagesDesc => '新消息和 mesh 状态更新';

  @override
  String get ntfChannelCallsName => '通话';

  @override
  String get ntfChannelCallsDesc => '来电和未接来电';

  @override
  String get ntfChannelMeshName => 'Mesh 与紧急通知';

  @override
  String get ntfChannelMeshDesc => 'Mesh 服务运行状态与紧急消息';

  @override
  String get ntfReply => '回复';

  @override
  String get ntfYourReply => '你的回复';

  @override
  String get ntfMarkAsRead => '标记为已读';

  @override
  String get ntfIncomingCall => '来电';

  @override
  String get ntfAnswer => '接听';

  @override
  String get ntfDecline => '拒接';

  @override
  String get ntfMissedCall => '未接来电';

  @override
  String get ntfSendFailedTitle => '发送失败';

  @override
  String get ntfSendFailedBody => '消息发送失败——一旦附近出现可用节点将自动重试。';

  @override
  String get ntfNewStatusTitle => '新状态';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo 发布了一条状态';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo 赞了你的状态';
  }

  @override
  String get ntfTapToView => '点按查看';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo 回复了你的状态';
  }

  @override
  String get ntfEmergencyTitle => '紧急消息';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo 广播了「我很安全」';
  }

  @override
  String get mnAccept => '接受';

  @override
  String get mnMeshVoiceCall => 'Mesh 语音通话';

  @override
  String get mnGroupCallIncoming => '群组来电';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo 邀请你加入';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '群组通话 · 另外 $count 位参与者',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => '谁可以看到这条状态？';

  @override
  String get asAllContacts => '我的所有联系人';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位联系人',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => '不包括…';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已排除 $count 位',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => '排除联系人';

  @override
  String get asOnlyOption => '仅限…';

  @override
  String get asShareWithSpecific => '仅与特定联系人分享';

  @override
  String get asNoContactsAvailable => '没有可用联系人';

  @override
  String get asConfirm => '确认';

  @override
  String get apYourPhoto => '你的照片';

  @override
  String get apNoPhotoAccessible => '此设备上没有可访问的照片。';

  @override
  String get apBrowseFiles => '浏览文件';

  @override
  String get apRecentPhoto => '最近的照片';

  @override
  String get bgSkip => '跳过';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return '第 $rang 步，共 $total 步。';
  }

  @override
  String get csGuideNetworkTitle => '附近没有人？这很正常';

  @override
  String get csGuideNetworkText =>
      'Droplet 不经过任何服务器：它只与附近的手机通信。这里显示谁可以联系到，以及通过哪种无线方式。零节点并不代表出了故障——只是附近暂时还没有人。';

  @override
  String get csGuideWriteTitle => '即使附近没人，也可以写消息';

  @override
  String get csGuideWriteText =>
      '现在写的消息会保存在你的手机上，一旦有设备进入范围（在街上、出租车里）就会自动发出。它没有丢失，只是在等待时机。';

  @override
  String get csGuideBackupTitle => '备份你的身份';

  @override
  String get csGuideBackupText =>
      '没有服务器，任何人都无法帮你找回账户。请在设置中导出你的身份：没有这份备份，一旦手机丢失，一切都将无法挽回。';

  @override
  String get csShowLockedChatsReason => '显示已锁定的聊天';

  @override
  String get cvlNoBiometricsConfigured => '此设备未设置指纹';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return '解锁与 $pseudo 的对话';
  }

  @override
  String get cvlAuthFailed => '身份验证失败';

  @override
  String get cvlAuthError => '身份验证出错';

  @override
  String get cvlConversationLocked => '已锁定的对话';

  @override
  String get cvlUnlock => '解锁';

  @override
  String get dcAddText => '添加文字';

  @override
  String get dcYourTextHint => '输入文字…';

  @override
  String get pbDropletProBadge => 'Droplet Pro 徽章';

  @override
  String get rpReact => '回应';

  @override
  String get rpSaveToPhone => '保存到手机';

  @override
  String get chViaTor => '通过 Tor';

  @override
  String get chTorInactive => 'Tor 未启用';

  @override
  String get chViaInternet => '通过互联网';

  @override
  String get chReachedViaTorSemantic => '通过 Tor 联系的联系人';

  @override
  String get nsTorConnectedTitle => '已通过 Tor 连接';

  @override
  String get nsTorInactiveTitle => 'Tor 已停用';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return '你的消息经由 Tor 网络传输，保存在一个加密邮箱中，直到 $pseudo 连接取件。';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return '请在设置中开启 Tor 才能给 $pseudo 发消息——否则消息会一直留在本设备上等待发送。';
  }

  @override
  String get nsTorMailboxTitle => '加密邮箱';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return '无论是你还是 Droplet 都无法读取其中内容——只有 $pseudo 拥有密钥。';
  }

  @override
  String get nsOpenTorSettings => '开启 Tor';

  @override
  String get qrInvalidCode => '此二维码不是 Droplet 的码。';

  @override
  String get qrPeerAdded => '已添加联系人';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return '现在你可以和 $pseudo 聊天了';
  }

  @override
  String get clViaInternet => '通过互联网';

  @override
  String get tsPathTorDetail => '这条消息不经过你周围的设备：它通过 Tor 网络上的一个加密邮箱传输，仅你们二人可以访问。';

  @override
  String get tsNetworkTorDetail =>
      '要远程联系此联系人，需要一台中继服务器——与本地 mesh 网络不同，这里 Droplet 无法避免使用服务器。';

  @override
  String get torSearchDirectory => '在通讯录中搜索';

  @override
  String get dvTitle => '搜索';

  @override
  String get dvClose => '关闭';

  @override
  String get dvSearchHint => '搜索用户名…';

  @override
  String get dvEnableTorToSearch => '请在设置中开启 Tor 以在通讯录中搜索。';

  @override
  String get dvSearching => '正在搜索…';

  @override
  String get dvNoResults => '没有结果';

  @override
  String get dvNoUserFound => '未找到与此搜索匹配的用户。';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条结果',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => '发送';

  @override
  String get aiNewConversation => '新对话';

  @override
  String get aiMessageHint => '消息';

  @override
  String get aiCopied => '已复制';

  @override
  String get aiAskQuestion => '提出问题';

  @override
  String get aiRunsLocally => '此助手完全在你的设备上运行——绝不会通过互联网发送任何内容。';

  @override
  String get aiMemorySaved => '我会记住的。';

  @override
  String get aiMemoryForgotten => '我已忘记你让我记住的内容。';

  @override
  String get aiMemoryTitle => '助手记忆';

  @override
  String get aiMemoryEmpty => '尚未保存任何内容。说“记住……”即可固定一条信息。';

  @override
  String get aiMemoryForget => '全部忘记';

  @override
  String get aiExpertHint => '我对 Droplet 了如指掌：网状网络、Tor、通话、隐私。';

  @override
  String get chAskAssistant => '询问助手';

  @override
  String chAskAssistantInvite(Object name) {
    return '帮我回复$name。';
  }

  @override
  String aiPreparing(Object percentage) {
    return '正在准备助手…$percentage%';
  }

  @override
  String get aiOneTimeDownload => '只需一次——之后它会留在你的设备上，无需再次下载。';

  @override
  String get aiGenericError => '抱歉，出现了错误。';

  @override
  String get aiNotAvailableYet => '此版本的 Droplet 尚不支持助手功能。';

  @override
  String aiDownloadFailed(Object error) {
    return '下载失败：$error';
  }

  @override
  String get ntfSomeoneCalling => '有人正在尝试联系你';

  @override
  String get ntfNewMessageWake => '新消息——打开 Droplet 查看';

  @override
  String get chNearbyAndInternet => '附近 · 互联网';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个中继 · 互联网',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => '等待网络连接';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '附近 $count 人 · 互联网',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '附近 $count 人 · 无网络',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => '附近无人 · 互联网';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi 直连';

  @override
  String get clPathInternetDirect => '互联网 · 直连';

  @override
  String get clPathInternetRelay => '互联网 · 安全中继';

  @override
  String get clReconnecting => '正在重新连接…';

  @override
  String get clLabelSpeaker => '扬声器';

  @override
  String get clLabelCamera => '摄像头';

  @override
  String get clLabelMic => '麦克风';

  @override
  String get clLabelFlip => '翻转';

  @override
  String get clEncryptedShort => '端到端加密';

  @override
  String clQualitySemantics(int bars) {
    return '通话质量：$bars/3';
  }

  @override
  String get beOnlineTitle => '自动在线备份';

  @override
  String get beOnlineBody =>
      '每天会将一份用此密码加密的副本保存在 Droplet 服务器上，服务器无法读取。在新手机上，只需相同的用户名和密码。不包括收到的照片、视频和文件。';

  @override
  String get beOnlineSwitch => '每天备份到服务器';

  @override
  String beOnlineLast(String date) {
    return '上次备份：$date';
  }

  @override
  String get beOnlineNever => '尚无在线备份';

  @override
  String get beOnlineNow => '立即备份';

  @override
  String get beOnlineDone => '在线备份已完成';

  @override
  String get beOnlineFailed => '暂时无法在线备份';

  @override
  String get obRestoreFromServer => '从服务器恢复';

  @override
  String get obEnterPseudoFirst => '请先输入备份所用的用户名';

  @override
  String get obNoServerBackup => '未找到此用户名和密码对应的备份';

  @override
  String get obTooManyAttempts => '尝试次数过多，请一小时后再试';

  @override
  String get chatsInviteLink => '通过链接邀请';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo 邀请你使用 Droplet——即使没有网络也能使用的加密通讯应用：$lien';
  }

  @override
  String get invTitle => '邀请';

  @override
  String invBody(String pseudo) {
    return '$pseudo 邀请你在 Droplet 上聊天。';
  }

  @override
  String get invAdd => '添加并发消息';

  @override
  String get invInvalid => '此邀请链接无效或不完整。';

  @override
  String get invSelf => '这是你自己的邀请链接。';
  @override
  String get seAnimationHeader => '发送动画';

  @override
  String get seAnimationFull => '完整';

  @override
  String get seAnimationReduced => '精简';

  @override
  String get seAnimationOff => '关闭';

  @override
  String get seAnimationFullDesc => '小水滴带走你的消息，瞬移后向你挥手。';

  @override
  String get seAnimationReducedDesc => '只有淡入淡出，没有位移和粒子。';

  @override
  String get seAnimationOffDesc => '发送后不播放动画。';

  @override
  String get seAnimationReplay => '点按重播';

  @override
  String get seAnimationNone => '无动画';

  @override
  String get seAnimationSampleIn => '在港口见？';

  @override
  String get seAnimationSampleOut => '待会儿见';

  @override
  String get trTitle => '翻译';

  @override
  String get trOnDevice => '正在设备上翻译…';

  @override
  String get trUnknownLang => '未知语言';

  @override
  String get trOriginal => '原文';

  @override
  String get trCopy => '复制';

  @override
  String get trInChat => '在聊天中';

  @override
  String get trRetry => '重试';

  @override
  String get trSame => '这条消息已经是该语言。';

  @override
  String get trModel => '此语言的模型尚未安装到设备上。';

  @override
  String get trUnavailable => '此设备没有离线翻译引擎。';

  @override
  String get trFailed => '翻译未能完成。';

  @override
  String get pfMessage => '消息';

  @override
  String get pfCall => '通话';

  @override
  String get pfSecurity => '安全';

  @override
  String get aiActCopy => '复制';

  @override
  String get aiActRead => '朗读';

  @override
  String get aiActStop => '停止朗读';

  @override
  String get aiActLike => '回答很好';

  @override
  String get aiActDislike => '回答不好';

  @override
  String get aiActShare => '分享';

  @override
  String get aiActRegenerate => '重新生成';

  @override
  String get aiFeedbackThanks => '感谢你的反馈';

  @override
  String get intelOnlineHeader => '翻译与转写';

  @override
  String get intelOnlineTitle => '联网时使用在线服务';

  @override
  String get intelOnlineSubtitle => '免费——MyMemory、Apple 或 Google';

  @override
  String get intelOnlineFooter => '关闭时，任何内容都不经过互联网。开启并联网时：要翻译的文字会发送到 MyMemory；在 iPhone 上，设备无法自行转写的语音消息会发送到 Apple 的语音服务，这段传输中的内容不再有端到端加密。在 Android 上只会下载语音模型：语音消息始终留在手机上。链接预览也会访问相关网站。';

  @override
  String get trOnline => '在线翻译';

  @override
  String get trOnlineNote => '文字将发送到免费服务 MyMemory，这段传输不再有端到端加密。';

  @override
  String get trViaOnline => '由 MyMemory 在线翻译';

  @override
  String get vnModelDownloading => '此语言的语音模型正在下载，请稍后再试。';

  @override
  String get vnModelNeeded => '缺少此语言的语音模型。请在设置中开启“联网时使用在线服务”，下载一次即可。';

  @override
  String get nwStatusHeader => '动态';

  @override
  String get nwAddStatus => '添加动态';

  @override
  String get nwStatusNewA11y => '新';

  @override
  String svReplySent(String name) {
    return '已回复 $name';
  }

  @override
  String get blkYouBlocked => '你已屏蔽此联系人。';

  @override
  String get blkUnblock => '取消屏蔽';

  @override
  String get blkListTitle => '已屏蔽的联系人';

  @override
  String get blkNone => '没有已屏蔽的联系人';

  @override
  String get blkFooter => '被屏蔽的联系人无法再给你发消息或打电话，也不会再收到你的动态和头像，对方不会收到通知。你的手机仍会转发对方发给其他人的消息，但无法读取：网状网络不受你的屏蔽影响。';

  @override
  String blkUnblockTitle(String name) {
    return '要取消屏蔽 $name 吗？';
  }

  @override
  String blkUnblockToCall(String name) {
    return '要取消屏蔽 $name 才能通话吗？';
  }

  @override
  String get nvDone => '完成';

  @override
  String get nvBack => '后退';

  @override
  String get nvForward => '前进';

  @override
  String get nvShare => '分享';

  @override
  String get nvOpenInBrowser => '在浏览器中打开';

  @override
  String get nvReload => '重新加载';

  @override
  String get nvCopyLink => '复制链接';

  @override
  String get nvLinkCopied => '已复制链接';

  @override
  String get nvOpen => '打开';

  @override
  String get nvMore => '更多';

  @override
  String get nvNotSecure => '不安全';

  @override
  String get nvErrorTitle => '无法打开页面';

  @override
  String get nvErrorBody => 'Droplet 无法访问此网站。网状网络不传输网页：需要互联网连接。';

  @override
  String get nvRetry => '重试';

  @override
  String get ciLinks => '链接';

  @override
  String get chatsFilterNearby => '附近';


  @override
  String get chProxTitle => 'Droplet 没有网络也能用';

  @override
  String get chProxActive => '附近有 Droplet 设备';

  @override
  String get chProxBody => '附近的手机会互相接力传递消息。周围的人越多，消息就能传得越远。';

  @override
  String get chProxSee => '看看附近';

  @override
  String get chStickerPreview => '贴纸';

  @override
  String get edCrop => '裁剪';

  @override
  String get edRotate => '旋转';

  @override
  String get edFilters => '滤镜';

  @override
  String get edAdjust => '调整';

  @override
  String get edText => '文字';

  @override
  String get edDraw => '画笔';

  @override
  String get edTrim => '剪辑';

  @override
  String get edBrightness => '亮度';

  @override
  String get edContrast => '对比度';

  @override
  String get edSaturation => '饱和度';

  @override
  String get edWarmth => '色温';

  @override
  String get edVignette => '暗角';

  @override
  String get edIntensity => '强度';

  @override
  String get edUndo => '撤销';

  @override
  String get edDone => '完成';

  @override
  String get edTextHint => '输入文字…';

  @override
  String get edDelete => '删除';

  @override
  String get edOriginal => '原图';

  @override
  String get edStyle => '样式';

  @override
  String get edBackground => '背景';

  @override
  String get stNotificationsHeader => '通知';

  @override
  String get stNotifPreview => '显示消息内容';

  @override
  String get stNotifPreviewSubtitle => '通知中会显示消息内容。关闭后，锁屏只提示有新消息。';

  @override
  String get stSearchHint => '搜索设置';

  @override
  String get stSearchEmpty => '没有匹配的设置';

  @override
  String get chMentionAllSubtitle => '通知所有人';

  @override
  String get vuOnce => '阅后即焚';

  @override
  String get vuOpened => '已查看';

  @override
  String get vuPhoto => '照片';

  @override
  String get vuVideo => '视频';

  @override
  String get vuMissing => '该内容尚未收到';

  @override
  String get pollClosed => '投票已结束';

  @override
  String pollEndsAt(String quand) {
    return '$quand 结束';
  }

  @override
  String get vuVoice => '语音消息';

  @override
  String get apPatternsHeader => '聊天背景图案';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => '游戏';

  @override
  String get apPatternHome => '居家';

  @override
  String get apPatternGarden => '花园';

  @override
  String get imTitle => '收藏的消息';

  @override
  String get imSubtitle => '你收藏的内容';

  @override
  String get imAdd => '收藏';

  @override
  String get imRemove => '取消收藏';

  @override
  String get imAdded => '已加入收藏';

  @override
  String get imRemoved => '已取消收藏';

  @override
  String get imEmptyBody => '长按一条消息即可收藏，稍后在这里找到它。';

  @override
  String get imClearAll => '全部清除';

  @override
  String get imClearAllBody => '消息仍留在聊天中，只会移除收藏标记。';

  @override
  String get imClear => '清除';

  @override
  String get imYou => '你';

  @override
  String get imUnknown => '消息';

  @override
  String get apPatternsFooter => '该图案将用于你的所有聊天背景。';

  @override
  String get grCreatedNoMessages => '群组已创建 · 暂无消息';

  @override
  String get chatsDelete => '删除聊天';

  @override
  String get chatsDeleteBody => '消息将从这台手机上消失。没有服务器，谁也无法从别人的手机上删除它们。';

  @override
  String get chatsDeleteConfirm => '删除';

  @override
  String get chatsDeleted => '聊天已删除';

  @override
  String chatsDeleteTitle(String nom) {
    return '删除与 $nom 的聊天？';
  }

  @override
  String get chatsDocument => '文件';

  @override
  String get epTitle => '阅后即焚消息';

  @override
  String get epHeadline => '在此聊天中开启阅后即焚消息';

  @override
  String get epBody => '新消息将自带有效期：到期后会从双方手机上消失。';

  @override
  String get epDelayHeader => '消失时间';

  @override
  String get epHours24 => '24 小时';

  @override
  String get epDays7 => '7 天';

  @override
  String get epDays90 => '90 天';

  @override
  String get epOff => '关闭';

  @override
  String get epFooter => '该设置不影响已发送的消息：每条消息保留发送时的时限。';

  @override
  String get chOnlineNow => '在线 · 互联网';

  @override
  String chInternetMinutesAgo(int count) {
    return '$count 分钟前通过互联网';
  }

  @override
  String chInternetHoursAgo(int count) {
    return '$count 小时前通过互联网';
  }

  @override
  String chInternetDaysAgo(int count) {
    return '$count 天前通过互联网';
  }

  @override
  String get pdfMissing => '此文件不在这台手机上。';

  @override
  String get pdfUnreadable => '无法读取此 PDF —— 可能传输不完整。';

  @override
  String get giDescription => '群描述';

  @override
  String get giDescriptionAdd => '添加描述';

  @override
  String get giDescriptionNone => '暂无描述';

  @override
  String get giDescriptionHint => '这个群是关于什么的？';

  @override
  String get giOnlyAdminsSend => '仅管理员可发言';

  @override
  String get giOnlyAdminsSendBody => '其他成员只能阅读，无法回复。';

  @override
  String get giSearchMembers => '搜索成员';

  @override
  String get chOnlyAdminsCanWrite => '此群仅管理员可发言';

  @override
  String grCreatedBy(String nom) {
    return '$nom 创建了群组';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom 把你加入了群组';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom 已不在群组中';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui 添加了 $nom';
  }

  @override
  String get giQrInvite => '二维码';

  @override
  String get giQrRenew => '新建二维码';

  @override
  String get giQrRenewed => '已生成新二维码，旧的失效';

  @override
  String get giQrExpired => '此二维码已过期';

  @override
  String get giQrExplainer => '此二维码不含任何密钥，只能用于申请加入，是否同意由你的手机决定。';

  @override
  String get giQrAlreadyMember => '你已在该群组中';

  @override
  String get giQrNeedContact => '请先添加邀请你的人';

  @override
  String get giQrRequestFailed => '请求未能发送';

  @override
  String giQrRequestSent(String nom) {
    return '已向 $nom 发送申请';
  }

  @override
  String giQrValidHours(int count) {
    return '还有 $count 小时有效';
  }

  @override
  String giQrValidMinutes(int count) {
    return '还有 $count 分钟有效';
  }

  @override
  String get cvNearby => '附近';

  @override
  String get cvInternet => '互联网';

  @override
  String get cvWaiting => '等待中';

  @override
  String get cvOutOfReach => '不可达';

  @override
  String get chWillSendWhenNearby => '等对方进入范围就会发送';

  @override
  String cvHops(int count) {
    return '$count 跳';
  }

  @override
  String get nwSeenSection => '已查看';

  @override
  String get nwReceivedHeader => '已接收';

  @override
  String get avTranslateTitle => '翻译';

  @override
  String get avTranslateShort => '不离开应用即可读懂';

  @override
  String get avTranslateLong => '消息在你的手机上翻译：内容不会发给任何人，连翻译服务也不会。原文始终一触即得——译文从来都不完全等于原文。';

  @override
  String get apStickerQ => '有这个的贴纸吗？';

  @override
  String get apOnline => '在线';

  @override
  String get apMessage => '消息';

  @override
  String get apAutoTranslated => '自动翻译';

  @override
  String get apBgSend => '看这个背景 😍';

  @override
  String get apBgA => '你改了什么吗？';

  @override
  String get apBgB => '每条消息它都会动 😮';

  @override
  String get apFormatQ => '我们在哪儿见？';

  @override
  String get apFormatDemo => '**下午六点**在__大市场__门口见，密码 `4821`。惊喜：||一个蛋糕||';

  @override
  String get apVoiceQ => '你在哪儿？';

  @override
  String get apVoiceText => '我在药店门口，等你到六点。';

  @override
  String get apTransQ => '嘿，都准备好了吗？';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => '好！明天机场见，12 号登机口，早上九点。';

  @override
  String get hlpDataOnDevice => '在你的手机上';

  @override
  String get hlpDataServers => '会经过服务器的部分';

  @override
  String get hlpDataServersFooter => '没有网络时，这些服务器一个都不参与：手机之间直接通话。';

  @override
  String get hlpDataNone => 'Droplet 从不索取的东西';

  @override
  String get hlpRowKeys => '你的身份';

  @override
  String get hlpRowKeysBody => '在本机生成的密钥对，从不外发';

  @override
  String get hlpRowMessages => '你的消息';

  @override
  String get hlpRowMessagesBody => '存在应用私有空间，卸载即抹去';

  @override
  String get hlpRowProfile => '昵称与头像';

  @override
  String get hlpRowProfileBody => '只发给你主动联系的人';

  @override
  String get hlpRowSettings => '你的设置';

  @override
  String get hlpRowSettingsBody => '背景、语言、通知——全部留在本机';

  @override
  String get hlpRowLog => '错误日志';

  @override
  String get hlpRowLogBody => '一个本地文件，从不自行外发';

  @override
  String get hlpRowDirectory => '目录服务';

  @override
  String get hlpRowDirectoryBody => '看到昵称和公开标识。请求走 Tor：看不到你的真实 IP';

  @override
  String get hlpRowMailbox => '信箱';

  @override
  String get hlpRowMailboxBody => '代存加密消息直到送达，无法读取内容';

  @override
  String get hlpRowSignalling => '通话建连';

  @override
  String get hlpRowSignallingBody => '建连期间看到两个标识。没有语音经过它';

  @override
  String get hlpRowRelay => '中继';

  @override
  String get hlpRowRelayBody => '直连失败时转发加密的声音';

  @override
  String get hlpNonePhone => '手机号码';

  @override
  String get hlpNoneEmail => '电子邮箱';

  @override
  String get hlpNoneContacts => '你的通讯录';

  @override
  String get hlpNoneLocation => '你的位置';

  @override
  String get hlpNoneAds => '广告与追踪器';

  @override
  String get hlpNoneAnalytics => '使用统计';

  @override
  String get hlpQOffline => '没有网络时 Droplet 怎么工作？';

  @override
  String get hlpAOffline => '手机之间直接通信，用蓝牙和 Wi-Fi。消息也可以在手机之间接力，一直传到收件人，全程不经过任何服务器。';

  @override
  String get hlpQCrypto => '我的消息真的加密了吗？';

  @override
  String get hlpACrypto => '是的，端到端加密，用 Signal 协议。密钥只存在于两部手机上。中继、信箱，还有我们，都打不开一条消息。';

  @override
  String get hlpQNoAccount => '为什么 Droplet 不要手机号也不要邮箱？';

  @override
  String get hlpANoAccount => '因为不需要。你的身份就是手机上生成的一把密钥。没有要注册的，没有要验证的，别处也没有可偷的。';

  @override
  String get hlpQPending => '我的消息为什么一直待发？';

  @override
  String get hlpAPending => '附近还没有人，也没有网络。消息在手机里等着，一有通路就发出去——你什么都不用重做。';

  @override
  String get hlpQAddSomeone => '怎么添加一个人？';

  @override
  String get hlpAAddSomeone => '把手机靠近，对方会自己出现。相隔较远时，分享你的邀请链接，或扫他的二维码。';

  @override
  String get hlpQUninstall => '卸载应用会怎样？';

  @override
  String get hlpAUninstall => '全部抹除：消息、联系人、身份。别处没有副本，因此也无法恢复。要换手机的话，先导出设置。';

  @override
  String get hlpQBattery => 'Droplet 费电吗？';

  @override
  String get hlpABattery => '搜索附近设备会耗电。在设置里可以调低，或只在应用打开时启用。';

  @override
  String get hlpQReport => '怎么报告问题？';

  @override
  String get hlpAReport => '在「联系与支持」里。发送前你会看到将要发送的确切文字——没有你，什么都不会离开手机。';

  @override
  String get svLikeStatus => '赞这条状态';

  @override
  String get svUnlikeStatus => '取消赞';

  @override
  String get stAddPhotoSemantics => '添加头像';

  @override
  String get stChangePhotoSemantics => '更换头像';

  @override
  String get scOverheat => '手机过热——Android 已关闭视频编码器。请让它冷却几分钟。';

  @override
  String scTooHeavy(int mo) {
    return '文件太大——穿越本地网络最多 $mo MB。';
  }

  @override
  String get scUnsupported => '状态不支持这种格式。';

  @override
  String get scUnreadableFile => '无法读取该文件';

  @override
  String get scUnreadableTrack => '无法读取该音轨';

  @override
  String get scNothingCaptured => '录制没有采集到内容——请重试。';

  @override
  String get scVideoTrimmed => '视频已截短至 1 分 30 秒——只发布开头部分。';

  @override
  String get scUnreadableVideo => '视频无法读取';

  @override
  String get chAiMe => '我';

  @override
  String chAiCtxIntro(String pseudo) {
    return '以下是 Droplet 中用户（「我」）与 $pseudo 对话的结尾：';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return '用户想要回复 $pseudo。请用$langue拟一条简短自然的回复，用第一人称，就像他自己发出的一样。只给出拟好的回复，不要任何铺垫。';
  }

  @override
  String get hlpSectionHeader => '帮助与隐私';

  @override
  String get hlpPrivacy => '隐私政策';

  @override
  String get hlpData => '你的数据';

  @override
  String get hlpDataValue => '什么都不外传';

  @override
  String get hlpContact => '联系与支持';

  @override
  String get hlpPrivacyTitle => '隐私';

  @override
  String hlpUpdated(String date) {
    return '更新于 $date';
  }

  @override
  String get hlpOnlyFrEn => '本文仅有法文和英文版本。法律文件若翻译得含糊，带来的约束会多于帮助。';

  @override
  String get hlpReadInEnglish => '用英文阅读';

  @override
  String get hlpReadInFrench => '用法文阅读';

  @override
  String get hlpDataTitle => '你的数据';

  @override
  String get hlpDataLead => 'Droplet 对你所知的一切，逐条列出。这里没有承诺：每一条都对应可查的代码。';

  @override
  String get hlpStays => '从不离开本机';

  @override
  String get hlpLeaves => '会经过服务器';

  @override
  String get hlpNever => '根本不存在';

  @override
  String get hlpCountTracking => '项用于追踪你的数据';

  @override
  String get hlpCountAccount => '个需要注册的账号';

  @override
  String get hlpCountServers => '台服务器，并且逐一说明';

  @override
  String get hlpHelpTitle => '帮助';

  @override
  String get hlpSearchHint => '搜索';

  @override
  String get hlpNoResult => '没有答案包含这个词。写信给我们——也许这里缺了这个问题。';

  @override
  String get hlpStillStuckFooter => '这里没有答案的话，由真人回复。';

  @override
  String get hlpContactTitle => '联系';

  @override
  String get hlpContactLead => '一个问题、一个故障、一个想法。我们都会读。';

  @override
  String get hlpBeforeWriting => '写信之前';

  @override
  String get hlpHelpRowBody => '八条答案，没网也能看';

  @override
  String get hlpWriteUs => '写信给我们';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => '电子邮件';

  @override
  String get hlpWhatsAppHello => '你好，我在用 Droplet，有个问题：';

  @override
  String get hlpEmailSubject => 'Droplet — 问题';

  @override
  String hlpWhatsAppMissing(String numero) {
    return '未安装 WhatsApp。号码 $numero 已复制。';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return '地址 $adresse 已复制。';
  }

  @override
  String get hlpReportHeader => '故障';

  @override
  String get hlpReport => '报告问题';

  @override
  String get hlpReportBody => '发送之前你会看到发送的内容';

  @override
  String get hlpReportFooter => 'Droplet 不会自己发送任何报告：它没有这样的服务器。只有你发送，问题才会到我们手上。';

  @override
  String get hlpReportSubject => 'Droplet — 问题报告';

  @override
  String get hlpReportSheetLead => '说说发生了什么。将要发送的确切文字显示在下方。';

  @override
  String get hlpReportHint => '我当时在做什么，然后发生了什么…';

  @override
  String get hlpAttachLog => '附上错误日志';

  @override
  String get hlpWhatWillBeSent => '将要发送的内容';

  @override
  String get hlpLogExcerpt => '日志（末尾）：';

  @override
  String get hlpCopy => '复制';

  @override
  String get hlpCopied => '已复制';

  @override
  String get hlpOnePerson => 'Droplet 由一个人做，不是客服团队。回复可能要一两天——但会来。';

  @override
  String get avSectionHeader => 'Pro 带来什么';

  @override
  String get avUnlock => '解锁 Droplet Pro';

  @override
  String get avVoiceTitle => '语音转文字';

  @override
  String get avVoiceShort => '无需播放即可阅读语音';

  @override
  String get avVoiceLong => '转写在你的手机上离线完成。语音不会外传，你可以在会议中、公交上或完全没有网络时阅读。';

  @override
  String get avFormatTitle => '文字格式';

  @override
  String get avFormatShort => '粗体、斜体、代码、剧透';

  @override
  String get avFormatLong => '一个加粗的词、一行代码、轻触才显现的隐藏内容：你的消息恰好表达你的本意。';

  @override
  String get avWallpaperTitle => '背景与图案';

  @override
  String get avWallpaperShort => '整个图库与四套图案';

  @override
  String get avWallpaperLong => '每一张背景都手工绘制，每一套图案都经过渲染检查。Droplet、游戏、居家、花园：你的聊天界面独一无二。';

  @override
  String get avStickersTitle => '动态贴纸';

  @override
  String get avStickersShort => '会动的 Droplet 水滴';

  @override
  String get avStickersLong => '为 Droplet 绘制的贴纸，逐帧动画，轻到可以在无网状态下通过网状网络传输。';

  @override
  String get avIconTitle => '应用图标';

  @override
  String get avIconShort => '更换主屏幕上的图标';

  @override
  String get avIconLong => '低调的通讯应用从图标开始。挑一个像你的，或一个最不起眼的。';

  @override
  String get avBadgeTitle => 'Pro 徽章';

  @override
  String get avBadgeShort => '它伴随你的名字';

  @override
  String get avBadgeLong => '它不赋予任何特权。它只说明你付费支持，让 Droplet 保持无广告、无强制订阅、不出售数据。';

  @override
  String get sgTitle => '群组存储';

  @override
  String get sgEmpty => '该群组尚未分享任何文件。';

  @override
  String get sgByAuthor => '谁发送得最多';

  @override
  String get sgFiles => '文件';

  @override
  String get sgSortRecent => '最新优先';

  @override
  String get sgSortHeavy => '最大优先';

  @override
  String get sgNotOnDevice => '不在本机';

  @override
  String get giPhotoChanged => '群组头像已更改';

  @override
  String get giPhotoFailed => '无法保存该图片';

  @override
  String sgTotal(int count) {
    return '已分享 $count 个文件';
  }

  @override
  String get vrTitle => '语音聊天';

  @override
  String get vrJoin => '加入';

  @override
  String get vrBack => '返回';

  @override
  String get vrStart => '开启语音聊天';

  @override
  String get vrNeedsInternet => '语音聊天需要联网：网状网络能捎带一条等待中的消息，但承载不了二十个人同时说话。';

  @override
  String get vrUnreachable => '目前无法连接通话服务器。';

  @override
  String vrFull(int count) {
    return '房间已满：最多 $count 人。';
  }

  @override
  String get vrWaiting => '等待其他人…';

  @override
  String get vrWaitingBody => '房间已开启。群成员会在聊天中看到它，有空时就会进来。';

  @override
  String vrPeople(int count) {
    return '$count 人在里面';
  }

  @override
  String get cvTitle => '对话';

  @override
  String get cvNew => '新建对话';

  @override
  String get cvPinned => '已置顶';

  @override
  String get cvRecent => '最近';

  @override
  String get cvPin => '置顶';

  @override
  String get cvUnpin => '取消置顶';

  @override
  String get cvRename => '重命名';

  @override
  String get cvRenameHint => '对话标题';

  @override
  String get cvUntitled => '无标题';

  @override
  String get cvYesterday => '昨天';

  @override
  String get cvSearchHint => '搜索对话';

  @override
  String get cvEmpty => '还没有对话。向助手提出第一个问题吧。';

  @override
  String get cvDeleteTitle => '删除此对话？';

  @override
  String get cvDeleteBody => '无法恢复：它只存在于这台设备上。';

  @override
  String get jaWorking => '处理中…';

  @override
  String cvNoResult(String terme) {
    return '未找到“$terme”。';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: '没有结果',
      one: '1 条结果',
      other: '$count 条结果',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: '没有步骤',
      one: '1 个步骤',
      other: '$count 个步骤',
      locale: localeName,
    );
  }

  @override
  String get moTitle => '你的消息去向';

  @override
  String get moLocal => '本机';

  @override
  String get moLocalBody => '模型在这台手机上运行。任何内容都不会外传，离线也可用。回答更短，也更不可靠。';

  @override
  String get moOnline => '联网';

  @override
  String get moOnlineBody => '你的消息会发往 Groq，那里运行着大得多的模型。需要联网，消息会离开手机。';

  @override
  String get moOnlineNoKey => '使用远程模型需要一个密钥。点按即可添加——免费，一分钟就好。';

  @override
  String get moRetryOnline => '联网重做';

  @override
  String get moRetryOnlineWhy => '本机模型在这个问题上已到极限。';

  @override
  String get cpHint => '问点什么…';

  @override
  String get cpAdd => '添加';

  @override
  String get cpPhoto => '照片';

  @override
  String get cpCamera => '相机';

  @override
  String get cpFile => '文件';

  @override
  String get cpFileHint => 'PDF、文本、代码';

  @override
  String get cpDictate => '语音输入';

  @override
  String get cpSend => '发送';

  @override
  String get cpStop => '停止';

  @override
  String get cpThinking => '思考中…';

  @override
  String get amCopy => '复制';

  @override
  String get amCopyMarkdown => '复制为 Markdown';

  @override
  String get amCopyMarkdownHint => '保留格式，适合放进文档';

  @override
  String get amShare => '分享';

  @override
  String get amEdit => '修改我的提问';

  @override
  String get amEditHint => '其后的内容将被删除';

  @override
  String get amEditTitle => '修改这个提问？';

  @override
  String get amEditConfirm => '修改';

  @override
  String get amRegenerate => '重新生成';

  @override
  String get amReadAloud => '朗读';

  @override
  String get amAsContext => '作为上下文引用';

  @override
  String get amAsContextHint => '从这条消息继续';

  @override
  String get amChapter => '标记为章节';

  @override
  String get amChapterHint => '便于在长对话中再次找到';

  @override
  String get amUnchapter => '取消标记';

  @override
  String get amChapters => '章节';

  @override
  String get amChaptersEmpty => '还没有章节。长按某条消息并选择“标记为章节”，它就会出现在这里。';

  @override
  String amEditBody(int count) {
    return '其后的 $count 条消息将被删除——它们回答的是旧问题。';
  }

  @override
  String get trAssistant => '助手';

  @override
  String get trArtifacts => '产物';

  @override
  String get trMemory => '记忆';

  @override
  String get trHelp => '帮助';

  @override
  String get arVersions => '版本';

  @override
  String get arLatest => '最新';

  @override
  String get arSource => '源码';

  @override
  String get arPreview => '预览';

  @override
  String get arGone => '该产物已不存在。';

  @override
  String get arKindPage => '页面';

  @override
  String get arKindCode => '代码';

  @override
  String get arKindDiagram => '图示';

  @override
  String get arKindData => '数据';

  @override
  String get arKindDoc => '文档';

  @override
  String arVersion(int n) {
    return '版本 $n';
  }

  @override
  String get aiSources => '来源';

  @override
  String get aiToolReading => '正在读取附件…';

  @override
  String get aiToolWriting => '正在生成文件…';

  @override
  String get aiToolRemembering => '正在记住…';

  @override
  String get arEmpty => '还没有产物。当助手生成页面、表格或长到会挤占对话的代码时，就会创建一个。';

  @override
  String get raTitle => '联网助手';

  @override
  String get raIntro => '本机助手无需配置即可使用。联网模式需要一个密钥：它为回答付费，并且只留在这台手机上。';

  @override
  String get raKey => '密钥';

  @override
  String get raKeySaved => '密钥已保存';

  @override
  String get raKeyFooter => '它存放在系统钥匙串中，永远不会完整显示。';

  @override
  String get raKeyRemove => '移除密钥';

  @override
  String get raWhere => '可在 console.groq.com 的“API Keys”中创建，以 gsk_ 开头。';

  @override
  String get raPaste => '粘贴';

  @override
  String get raSaveAndTest => '保存并测试';

  @override
  String get raTest => '测试密钥';

  @override
  String get raTesting => '测试中…';

  @override
  String get raNotTested => '尚未测试';

  @override
  String get raNotTestedBody => '八个词的一次调用就够了。在这里试，好过在提问到一半时才发现。';

  @override
  String get raWorks => '密钥可用';

  @override
  String get raWorksBody => '联网模式已在对话中可用，就在输入框旁边的胶囊按钮上。';

  @override
  String get raRefused => '密钥被拒绝';

  @override
  String get raRefusedBody => '服务器不认这个密钥。通常是粘贴时漏了字符，或密钥已被吊销。';

  @override
  String get raNoNetwork => '无法连接服务器';

  @override
  String get raNoNetworkBody => '不是密钥的问题：请求根本没送达。请检查网络后重试。';

  @override
  String get raModelGone => '模型不可用';

  @override
  String get raModelGoneBody => '密钥已被接受，但没有返回内容。该模型很可能已下架。';

  @override
  String get raQuota => '请求过于频繁';

  @override
  String get raQuotaBody => '密钥可用，但账户已达上限。请稍后再试，或检查余额。';

  @override
  String get raWhatGoesOut => '会发送什么';

  @override
  String get raModel => '模型';

  @override
  String get raWhatGoesOutFooter => '在联网模式下，你的消息和本次对话之前的内容会发往 Groq。仅此而已：不包括你的联系人、其他对话或位置。';

  @override
  String get aiDownloadTitle => '下载本机模型？';

  @override
  String get aiDownloadConfirm => '下载';

  @override
  String get aiDownloading => '正在下载本机模型';

  @override
  String aiDownloadBody(int mo) {
    return '需下载 $mo MB，仅此一次。之后助手无需联网即可回答，任何内容都不会离开手机。下载期间仍可联网使用。';
  }

  @override
  String moLocalToDownload(int mo) {
    return '需下载 $mo MB，仅此一次。之后无需联网即可回答，任何内容都不会离开手机。';
  }

  @override
  String get aiGreetingPlain => '你好';

  @override
  String get aiGreetingHint => '提个问题、附上照片，或让它做份文档。';

  @override
  String get aiChipExplain => '解释一下…';

  @override
  String get aiChipWrite => '写条消息';

  @override
  String get aiChipSummarize => '总结一下';

  @override
  String get aiChipTranslate => '翻译成…';

  @override
  String aiGreeting(String nom) {
    return '你好，$nom';
  }

  @override
  String get cpNoPhoto => '不支持照片：联网模型无法读取图像。但它能读 PDF，包括很长的。';

  @override
  String get mvOpen => '语音模式';

  @override
  String get mvTapToTalk => '点按即可说话';

  @override
  String get mvHoldToTalk => '按住说话';

  @override
  String get mvListening => '正在聆听…';

  @override
  String get mvTranscribing => '正在转写…';

  @override
  String get mvSpeaking => '正在朗读回答';

  @override
  String get mvProblem => '出现问题';

  @override
  String get mvHandsFree => '免手动';

  @override
  String get mvHold => '按住';

  @override
  String get mvTalk => '说话';

  @override
  String get mvInterrupt => '打断';

  @override
  String get mvNoMic => 'Droplet 无法使用麦克风。请在手机设置中允许。';

  @override
  String get mvFailed => '这一轮没有成功。点按重试。';

  @override
  String get mvLive => '实时对话';

  @override
  String get mvCaptions => '字幕';

  @override
  String get mvExit => '退出语音模式';

  @override
  String get mvMute => '关闭麦克风';

  @override
  String get mvUnmute => '开启麦克风';

  @override
  String get mvMuted => '麦克风已关闭';

  @override
  String get mvTapToInterrupt => '点按可打断';

  @override
  String scCompressing(int percent) {
    return '正在压缩… $percent%';
  }

  @override
  String get scStillHeavy => '该视频仍超过 2 MB：传输会更慢。';

  @override
  String get baConnecting => '正在连接…';

  @override
  String get baMute => '静音';

  @override
  String get baUnmute => '取消静音';

  @override
  String get baHangUp => '结束通话';

  @override
  String baOngoing(String name) {
    return '正在与 $name 通话。点按可返回。';
  }

  @override
  String get ntfOngoingCall => '通话中';

  @override
  String get ntfViaMesh => '通过网状网络';

  @override
  String get ntfViaInternet => '通过互联网';

  @override
  String get shSend => '发送';

  @override
  String get shRecents => '最近';

  @override
  String get shPickRecipients => '选择一位或多位接收者';

  @override
  String shSendCount(int count) {
    return '发送给 $count 位';
  }

  @override
  String shSelected(int count) {
    return '已选择 $count 位';
  }

  @override
  String get apcNothingYet => '还没有消息';

  @override
  String get apcOnline => '在线';

  @override
  String get apcOffline => '离线';

  @override
  String get apcPhoto => '照片';

  @override
  String get apcVoice => '语音消息';

  @override
  String get apcAttachment => '附件';

  @override
  String get chKeyboardTooltip => '键盘';

  @override
  String get asGallery => '相册';

  @override
  String get asFile => '文件';

  @override
  String get asLocation => '位置';

  @override
  String get asSticker => '贴纸';

  @override
  String get asPoll => '投票';

  @override
  String get asNoGalleryAccess => 'Droplet 无法访问您的照片。请在手机设置中允许，或在下方选择其他来源。';

  @override
  String asSendCount(int count) {
    return '发送 $count 项';
  }

  @override
  String get asEmptyGallery => '此手机上没有照片或视频。';

  @override
  String get expAucunPairTitre => '附近没人？';

  @override
  String get expAucunPairTexte => '这不是故障。Droplet 会持续搜索；只要有设备经过，连接就会自动建立。';

  @override
  String get expRelaisTitre => '经由他人转发';

  @override
  String get expRelaisTexte => '此图标表示消息在送达前经过了一台或多台设备。这正是网状网络的优势。';

  @override
  String get expApercuTitre => '快速预览';

  @override
  String get expApercuTexte => '长按某个对话即可查看最新消息，无需打开，也不会标记为已读。';

  @override
  String get expOfficielTitre => 'Droplet 官方账号';

  @override
  String get expOfficielTexte => '应用的新功能会发布在这里。每条公告都有签名，无人能够伪造。';

  @override
  String get expMicroTitre => '按住说话';

  @override
  String get expMicroTexte => '按住即可录音。向左滑动取消，向上滑动可免持继续录音。';

  @override
  String get expCameraTitre => '麦克风或摄像头';

  @override
  String get expCameraTexte => '轻点此按钮可在语音消息和圆形视频消息之间切换。';

  @override
  String get expVueUniqueTitre => '阅后即焚';

  @override
  String get expVueUniqueTexte => '开启「1」后，下一条发送的内容只能查看一次，随后消失。';

  @override
  String get expPiecesTitre => '一次多张';

  @override
  String get expPiecesTexte => '回形针会在应用内打开相册。勾选多张照片，数字表示发送顺序。';

  @override
  String get expStickersTitre => '贴纸与键盘';

  @override
  String get expStickersTexte => '此图标会用贴纸替换键盘，轻点一下即可变回键盘。';

  @override
  String get expEphemeresTitre => '自动消失的消息';

  @override
  String get expEphemeresTexte => '设置时限后，此对话中的新消息会从双方手机上自动删除。';

  @override
  String get expVerrouTitre => '已锁定的对话';

  @override
  String get expVerrouTexte => '锁定后，对话不再在列表中显示最后一条消息，打开前需要解锁。';

  @override
  String get expCodeTitre => '验证联系人';

  @override
  String get expCodeTexte => '与对方面对面核对此代码：若完全一致，说明没有第三方介入。';

  @override
  String get expStatutTitre => '24 小时动态';

  @override
  String get expStatutTexte => '动态存在一天后自动清除。即使没有网络，它也会在手机之间传递。';

  @override
  String get expGardeTitre => '消息不会丢失';

  @override
  String get expGardeTexte => '发给离线用户的消息会保留一周，一旦出现可用路径便自动送出。';

  @override
  String get expVoieTitre => '走哪条路';

  @override
  String get expVoieTexte => '蓝牙、Wi-Fi 直连或互联网：Droplet 会选用可用的通道，并自动切换，无需询问。';

  @override
  String get cnAnnouncement => 'Droplet 新功能';

  @override
  String get cnClearAll => '全部清除';

  @override
  String get cnClearAllTitle => '清除所有通知？';

  @override
  String get cnClearAllBody => '通知中心将被清空，你的对话和消息不受影响。';

  @override
  String get cnDelete => '清除';

  @override
  String get cnEmptyTitle => '暂无新内容';

  @override
  String get cnEmptyBody => '提及、对你消息的回应、未接来电和 Droplet 新功能会显示在这里。';

  @override
  String get cnMentioned => '提到了你';

  @override
  String get cnShowLess => '收起';

  @override
  String get cnStatusLike => '赞了你的状态';

  @override
  String get cnStatusReply => '回复了你的状态';

  @override
  String get cnTitle => '通知中心';

  @override
  String get ncDeliveryHeader => '送达方式';

  @override
  String get ncMentionsOnly => '仅提及';

  @override
  String get ncMentionsOnlySub => '仅在有人写 @你的名字 或 @所有人 时';

  @override
  String get ncMute1h => '1 小时';

  @override
  String get ncMute8h => '8 小时';

  @override
  String get ncMute1w => '1 周';

  @override
  String get ncMuteAlways => '始终';

  @override
  String get ncMuteFooter => '不通知也不响铃。消息照常送达，等你来看。';

  @override
  String get ncMuteFooterGroup => '不通知也不响铃。提及你的消息仍会通知。';

  @override
  String get ncMuteHeader => '静音';

  @override
  String get ncMuteOff => '关闭';

  @override
  String get ncPreviewAlways => '始终';

  @override
  String get ncPreviewFooter => '关闭预览后，通知只显示“新消息”，锁屏上看不到内容。';

  @override
  String get ncPreviewHeader => '消息预览';

  @override
  String get ncPreviewNever => '从不';

  @override
  String get ncQuiet => '静默送达';

  @override
  String get ncQuietSub => '仅放入通知栏，无声音无横幅';

  @override
  String get ncSampleAuthor => '小雅';

  @override
  String get ncSampleHidden => '新消息';

  @override
  String get ncSampleLabel => '通知示例';

  @override
  String get ncSampleText => '晚上 7 点见？';

  @override
  String get ncStateMentions => '仅提及';

  @override
  String get ncStateMuted => '已静音';

  @override
  String get ncStateOn => '已开启';

  @override
  String get ncStateQuiet => '静默';

  @override
  String get ncSystemFooter => '此对话的提示音和气泡在 Android 设置中调整。';

  @override
  String get ncSystemSettings => '提示音与气泡';

  @override
  String get ncTitle => '通知';

  @override
  String get ntfNewMessage => '新消息';

  @override
  String get ntfNow => '现在';

  @override
  String get rnBanners => '横幅';

  @override
  String get rnBannersSub => 'Droplet 打开时收到消息';

  @override
  String get rnFocus1h => '1 小时';

  @override
  String get rnFocusEvening => '直到今晚';

  @override
  String get rnFocusTomorrow => '直到明天早上';

  @override
  String get rnFocusFooter => 'Droplet 保持安静：消息照常送达等你查看，来电仍会响铃。';

  @override
  String get rnFocusHeader => '专注模式';

  @override
  String get rnFocusMentions => '允许提及';

  @override
  String get rnFocusMentionsSub => '当有人在群组中写 @你的名字';

  @override
  String get rnFocusOff => '专注模式已关闭';

  @override
  String get rnFocusOffSub => '通知照常送达';

  @override
  String get rnFocusOn => '专注模式已开启';

  @override
  String get rnFocusStop => '关闭专注模式';

  @override
  String get rnFocusStopShort => '停止';

  @override
  String get rnInAppHeader => '在 Droplet 内';

  @override
  String get rnMutedEmpty => '没有静音的对话。';

  @override
  String get rnMutedHeader => '已静音';

  @override
  String get rnPreview => '显示预览';

  @override
  String get rnPreviewFooter => '通知中显示消息文字。每个对话可单独设置。';

  @override
  String get rnSystem => 'Android 设置';

  @override
  String get rnSystemFooter => '在手机设置中管理 Droplet 的权限、提示音和气泡。';

  @override
  String get stNotificationsSubtitle => '静音、预览、专注模式';

  @override
  String cnBellUnread(int count) {
    return '通知，$count 条新内容';
  }

  @override
  String cnMore(int count) {
    return '还有 $count 条';
  }

  @override
  String ntfMoreMessages(int count) {
    return '还有 $count 条';
  }

  @override
  String cnQuoted(String texte) {
    return '“$texte”';
  }

  @override
  String cnReacted(String emoji) {
    return '对你的消息回应了 $emoji';
  }

  @override
  String ncMutedUntil(String heure) {
    return '直到 $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return '默认（$valeur）';
  }

  @override
  String muTitle(String nom) {
    return '将 $nom 设为静音';
  }

  @override
  String rnFocusUntil(String heure) {
    return '直到 $heure · 来电仍会响铃';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n 个对话';
  }

  @override
  String get chatsNetSearching => '正在寻找附近的设备…';

  @override
  String get cfEmptyUnreadTitle => '全部已读';

  @override
  String get cfEmptyUnreadBody => '有未读消息的对话会显示在这里。';

  @override
  String get cfEmptyGroupsTitle => '还没有群组';

  @override
  String get cfEmptyGroupsBody => '点击右上角的 + 按钮创建一个。';

  @override
  String get cfEmptyOtherTitle => '这里暂时没有内容';

  @override
  String get ciLockedWhereHint => '已锁定。下拉对话列表即可找到。';

  @override
  String get chDraftLabel => '草稿：';

  @override
  String get rsMorning => '早上好';

  @override
  String get rsEvening => '晚上好';

  @override
  String get rsUnreadOne => '1 条未读消息';

  @override
  String get rsChatsOne => '来自 1 个对话';

  @override
  String get rsMentionsOne => '1 次提及';

  @override
  String get rsMissedOne => '1 个未接来电';

  @override
  String get rsSeeUnread => '查看未读';

  @override
  String rsUnreadMany(int count) {
    return '$count 条未读消息';
  }

  @override
  String rsChatsMany(int count) {
    return '来自 $count 个对话';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count 次提及';
  }

  @override
  String rsMissedMany(int count) {
    return '$count 个未接来电';
  }

  @override
  String get camUnavailable => '相机不可用。请在设置中检查权限。';

  @override
  String get camTakePhoto => '拍照';

  @override
  String get camFlip => '切换摄像头';

  @override
  String get chE2eNotice => '消息已端到端加密。除你们之外，任何人（包括 Droplet）都无法读取。';

  @override
  String chCallUnreachable(String name) {
    return '$name 不在范围内：你们靠近或联网后即可通话。';
  }

  @override
  String get chPin => '置顶';

  @override
  String get chUnpin => '取消置顶';

  @override
  String get chPinnedMessage => '置顶消息';

  @override
  String get chVoicePlay => '播放';

  @override
  String get chVoicePause => '暂停';

  @override
  String chPinnedMessageN(String position) {
    return '置顶消息 $position';
  }

  @override
  String get msgInfo => '详情';

  @override
  String get imSearch => '搜索';

  @override
  String get apcVideo => '视频';
}
