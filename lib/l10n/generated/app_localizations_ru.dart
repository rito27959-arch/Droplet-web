// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Отправить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get tabChats => 'Чаты';

  @override
  String get tabNews => 'Новости';

  @override
  String get tabCalls => 'Звонки';

  @override
  String get tabPeers => 'Пиры';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get sectionAppearance => 'Оформление';

  @override
  String get appearanceAuto => 'Автоматически';

  @override
  String get appearanceLight => 'Светлая';

  @override
  String get appearanceDark => 'Тёмная';

  @override
  String get appearanceFooter =>
      'Droplet создан для тёмной темы: на экране OLED чёрные пиксели полностью выключены, что экономит заряд батареи и не слепит в темноте. Светлая тема остаётся доступной для чтения при ярком солнце.';

  @override
  String get sectionLanguage => 'Язык';

  @override
  String get languageAuto => 'Автоматически (язык телефона)';

  @override
  String get languageFooter =>
      '«Автоматически» — это язык, установленный на устройстве. Если этот язык пока не поддерживается, Droplet останется на французском.';

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get chatsSearchHint => 'Поиск';

  @override
  String get chatsFilterAll => 'Все';

  @override
  String get chatsFilterUnread => 'Непрочитанные';

  @override
  String get chatsFilterGroups => 'Группы';

  @override
  String get chatsFilterPinned => 'Закреплённые';

  @override
  String get chatsEmptyTitle => 'Пока нет чатов';

  @override
  String get chatsEmptySubtitle =>
      'Подойдите ближе к устройству с Droplet: оно появится здесь автоматически.';

  @override
  String get chatsSearchEmptyTitle => 'Ничего не найдено';

  @override
  String get chatsSearchEmptySubtitle => 'Попробуйте другое имя.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пира рядом',
      many: '$count пиров рядом',
      few: '$count пира рядом',
      one: '$count пир рядом',
      zero: 'Поиск пиров…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Минимум 3 символа';

  @override
  String get obChoosePseudo => 'Выберите имя, чтобы начать';

  @override
  String get obRestoreFailed => 'Не удалось восстановить';

  @override
  String get obPhotoSaveFailed => 'Не удалось сохранить фото';

  @override
  String get obShareUnavailable => 'Общий доступ недоступен';

  @override
  String get obBackupPasswordTitle => 'Пароль резервной копии';

  @override
  String get obBackupPasswordMessage =>
      'Тот, что вы выбрали при экспорте своей личности.';

  @override
  String get obBackupPasswordPlaceholder => 'Пароль';

  @override
  String get obRestore => 'Восстановить';

  @override
  String get obSkipStep => 'Пропустить этот шаг';

  @override
  String get obContinue => 'Продолжить';

  @override
  String get obStart => 'Начать';

  @override
  String get obAlreadyHaveBackup => 'У меня уже есть резервная копия';

  @override
  String get obWelcomeTitle => 'Добро пожаловать в\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Мессенджер, который работает там, где нет сети.';

  @override
  String get obFeatOfflineTitle => 'Без интернета, без оператора';

  @override
  String get obFeatOfflineText =>
      'Телефоны общаются напрямую, шаг за шагом. Ни антенны, ни счёта.';

  @override
  String get obFeatEncryptedTitle => 'Сквозное шифрование';

  @override
  String get obFeatEncryptedText =>
      'Даже телефоны, ретранслирующие ваши сообщения, не могут их прочитать.';

  @override
  String get obFeatLocalTitle => 'Ничего не покидает ваше устройство';

  @override
  String get obFeatLocalText =>
      'Ни аккаунта, ни сервера, ни сбора данных. Ваши беседы остаются при вас.';

  @override
  String get obRelayTitle => 'Шаг за\nшагом';

  @override
  String get obRelaySubtitle =>
      'Ваше сообщение перескакивает от телефона к телефону, пока не достигнет получателя, даже если вы не в прямой зоне действия.';

  @override
  String get obFeatCrowdTitle => 'Чем нас больше, тем дальше действует сеть';

  @override
  String get obFeatCrowdText =>
      'Каждое устройство в радиусе действия расширяет сеть для всех.';

  @override
  String get obFeatNothingLostTitle => 'Ничего не теряется';

  @override
  String get obFeatNothingLostText =>
      'Сообщение для отсутствующего человека ждёт, а затем отправляется дальше, как только откроется путь.';

  @override
  String get obSafetyTitle => 'Найти друг друга\nбез сети';

  @override
  String get obSafetySubtitle =>
      'Когда всё остальное не работает, знание о том, где находятся другие и что с ними всё в порядке, становится самой полезной информацией.';

  @override
  String get obFeatMapTitle => 'Карта, работающая офлайн';

  @override
  String get obFeatMapText =>
      'Просмотренные вами области сохраняются на телефоне. После просмотра они отображаются без интернета.';

  @override
  String get obFeatMeshPosTitle => 'Местоположения приходят из ячеистой сети';

  @override
  String get obFeatMeshPosText =>
      'Без сервера: местоположение зашифрованно покидает телефон вашего контакта и перескакивает от устройства к устройству, пока не достигнет вашего.';

  @override
  String get obFeatCheckinTitle => '«Я в безопасности» одним касанием';

  @override
  String get obFeatCheckinText =>
      'Одно касание транслирует ваш статус всем соседям. Вы решаете, добавлять ли приблизительное местоположение.';

  @override
  String get obStatusTitle => 'Делиться\nновостями';

  @override
  String get obStatusSubtitle =>
      'Фото, слово, настроение: ваш статус переходит от телефона к телефону, как и ваши сообщения.';

  @override
  String get obFeatStatusMediaTitle => 'Фото, видео или текст';

  @override
  String get obFeatStatusMediaText =>
      'Публикуйте всё, что хотите показать. Люди в радиусе действия получат это без интернета.';

  @override
  String get obFeatStatusSeenTitle => 'Вы видите, кто это посмотрел';

  @override
  String get obFeatStatusSeenText =>
      'Каждый, кто открывает ваш статус, сообщает вам об этом тем же путём.';

  @override
  String get obFeatStatusExpireTitle => 'Исчезает через день';

  @override
  String get obFeatStatusExpireText =>
      'Двадцать четыре часа, затем статус исчезает со всех телефонов, которые его получили.';

  @override
  String get obRemovePhoto => 'Удалить фото';

  @override
  String get obChoosePhoto => 'Выбрать фото';

  @override
  String get obPhotoTitle => 'Лицо,\nесли хотите';

  @override
  String get obPhotoSubtitle =>
      'Она помогает другим узнать вас в списке. Никто не обязывает вас её добавлять.';

  @override
  String get obFeatPhotoLocalTitle => 'Оно остаётся на этом телефоне';

  @override
  String get obFeatPhotoLocalText =>
      'Ни один сервер его не получает, ни одна онлайн-резервная копия его не хранит. Оно живёт в папке приложения, и больше нигде.';

  @override
  String get obFeatPhotoCompressTitle => 'Уменьшено перед сохранением';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet сохраняет только миниатюру 320 пикселей. Ваше оригинальное фото никогда не копируется.';

  @override
  String get obNetworkTitle => 'Droplet растёт\nвместе с вами';

  @override
  String get obNetworkSubtitle =>
      'Каждый, кто устанавливает приложение, расширяет сеть — для себя и всех вокруг.';

  @override
  String get obSendToFriend => 'Отправить Droplet близкому человеку';

  @override
  String get obFeatShareOfflineTitle =>
      'Даже обмен файлами обходится без интернета';

  @override
  String get obFeatShareOfflineText =>
      'Droplet отправляет вам собственный установочный файл. Он передаётся по Bluetooth, Wi-Fi Direct или через карту памяти — соединение не требуется ни одной из сторон.';

  @override
  String get obFeatThreeTitle => 'Для начала достаточно трёх человек';

  @override
  String get obFeatThreeText =>
      'Вдвоём вы переписываетесь в пределах видимости. С несколькими людьми в районе сообщения ретранслируются, и радиус действия становится намного больше, чем у одного телефона.';

  @override
  String get obIdentityTitle => 'Как нам вас\nназывать?';

  @override
  String get obIdentitySubtitle =>
      'Это имя будет видно людям, которых вы встретите. Вы можете выбрать имя, которое вас не идентифицирует.';

  @override
  String get obPseudoHint => 'Ваше имя';

  @override
  String get obFeatKeysTitle => 'Ваши ключи создаются здесь и сейчас';

  @override
  String get obFeatKeysText =>
      'Они никогда не покидают этот телефон. Не забудьте сделать резервную копию в настройках: без неё утраченная личность утрачена навсегда.';

  @override
  String get splashCaption => 'Офлайн. Без оператора.';

  @override
  String get chatsMeshNetwork => 'Ячеистая сеть';

  @override
  String get chatsNew => 'Новое';

  @override
  String get chatsNewGroup => 'Новая группа';

  @override
  String get chatsAssistant => 'Ассистент';

  @override
  String get chatsEmergencyMode => 'Аварийный режим';

  @override
  String get chatsUnpin => 'Открепить';

  @override
  String get chatsPin => 'Закрепить сверху';

  @override
  String get chatsUnmute => 'Включить уведомления';

  @override
  String get chatsMute => 'Отключить звук';

  @override
  String get chatsArchive => 'Архивировать';

  @override
  String get swipePin => 'Закрепить';

  @override
  String get swipeUnpin => 'Открепить';

  @override
  String get swipeMute => 'Без звука';

  @override
  String get swipeUnmute => 'Со звуком';

  @override
  String get swipeArchive => 'В архив';

  @override
  String get fmtBold => 'Жирный';

  @override
  String get fmtItalic => 'Курсив';

  @override
  String get fmtStrike => 'Зачёркнутый';

  @override
  String get fmtMono => 'Моноширинный';

  @override
  String get fmtSpoiler => 'Спойлер';

  @override
  String get vnTranscribing => 'Расшифровка…';

  @override
  String get vnTranscribeFailed => 'Расшифровка недоступна на этом устройстве';

  @override
  String get vnNoSpeech => 'Речь не распознана';

  @override
  String get msgTranslate => 'Перевести';

  @override
  String get msgShowOriginal => 'Показать оригинал';

  @override
  String get msgTranslatedFrom => 'Переведено автоматически';

  @override
  String get msgTranslateFailed => 'Перевод недоступен';

  @override
  String get msgTranslateModel =>
      'Нужно скачать языковую модель (один раз, по Wi‑Fi)';

  @override
  String get pfWallpapers => 'Анимированные фоны';

  @override
  String get pfWallpapersDesc =>
      'Восемь разноцветных фонов, которые живут за вашими чатами и поворачиваются с каждым отправленным сообщением.';

  @override
  String get pfFormatting => 'Форматирование текста';

  @override
  String get pfFormattingDesc =>
      'Жирный, курсив, зачёркнутый, код и спойлеры прямо в сообщениях.';

  @override
  String get pfTranscription => 'Голос в текст';

  @override
  String get pfTranscriptionDesc =>
      'Читайте голосовое, когда не можете слушать. Распознавание идёт на вашем телефоне.';

  @override
  String get pfTranslation => 'Перевод';

  @override
  String get pfTranslationDesc =>
      'Переводите полученное сообщение без того, чтобы его содержимое покидало устройство.';

  @override
  String get pfAppIcons => 'Значки приложения';

  @override
  String get pfAppIconsDesc => 'Меняйте значок Droplet на главном экране.';

  @override
  String get pfBadge => 'Значок и поддержка';

  @override
  String get pfBadgeDesc =>
      'Значок рядом с вашим именем и поддержка независимого проекта.';

  @override
  String get pfUnderstood => 'Понятно';

  @override
  String get pfFeaturesTitle => 'Что открывает пакет';

  @override
  String get chatsUnarchive => 'Разархивировать';

  @override
  String get chatsArchivedTitle => 'Архивные';

  @override
  String get chatsNoArchived => 'Нет архивных чатов';

  @override
  String get chatsLockedTitle => 'Заблокированные чаты';

  @override
  String get chatsNoLocked => 'Нет заблокированных чатов';

  @override
  String get chatsCrashTitle => 'Droplet неожиданно закрылся';

  @override
  String get chatsCrashBody =>
      'У Droplet нет сервера: без вашей отправки эта ошибка не существует ни для кого другого. Отчёт не содержит сообщений, контактов или ключей.';

  @override
  String get chatsSendReport => 'Отправить отчёт';

  @override
  String get chatsLater => 'Позже';

  @override
  String get stTitle => 'Настройки';

  @override
  String get stIconHeader => 'Значок';

  @override
  String get stIconFooter => 'Тринадцать значков на выбор для главного экрана.';

  @override
  String get stAppIcon => 'Значок приложения';

  @override
  String get stVariants13 => '13 вариантов';

  @override
  String get stNetworkHeader => 'Сеть';

  @override
  String get stNetworkFooter =>
      'Фоновая ретрансляция позволяет пересылать чужие сообщения, даже когда Droplet закрыт.';

  @override
  String get stRequireTor => 'Требовать Tor в сети';

  @override
  String get stRequireTorSubtitle => 'Без Tor ничего не уходит на серверы';

  @override
  String get stRequireTorFooter =>
      'Каталог и почтовый ящик идут через Tor, когда он активен. Иначе Droplet подключается напрямую: содержимое остаётся зашифрованным сквозным образом, но серверы видят ваш IP-адрес. Включите, чтобы запретить это — ценой онлайн-сообщений, когда Tor не работает.';

  @override
  String get stMeshNetwork => 'Ячеистая сеть';

  @override
  String get stPeersTopology => 'Подключённые узлы и топология';

  @override
  String get stOfflineMaps => 'Офлайн-карты';

  @override
  String get stZonesImport => 'Сохранённые области и импорт карт';

  @override
  String get stSecurityHeader => 'Безопасность';

  @override
  String get stSecurityFooter =>
      'Droplet не хранит копию вашей личности. Без резервной копии она теряется вместе с устройством.';

  @override
  String get stBackupIdentity => 'Резервное копирование моей личности';

  @override
  String get stExportEncrypted => 'Экспорт с шифрованием паролем';

  @override
  String get stEmergencyMode => 'Аварийный режим';

  @override
  String get stSignalSafe => 'Сообщить, что вы в безопасности';

  @override
  String get stContributionHeader => 'Вклад';

  @override
  String get stMyContribution => 'Мой вклад';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Активен';

  @override
  String get stProPackUnlocked => 'Пакет разблокирован';

  @override
  String get stProIconsThemes => 'Значки и фоны';

  @override
  String get stCrashLog => 'Журнал ошибок';

  @override
  String get stAbout => 'О Droplet';

  @override
  String get stBackgroundRelay => 'Фоновая ретрансляция';

  @override
  String get stActiveClosed => 'Активен даже при закрытом приложении';

  @override
  String get stActiveOpenOnly => 'Активен только при открытом приложении';

  @override
  String get stBatteryOptim => 'Оптимизация батареи';

  @override
  String get stAndroidMayLimit => 'Android может ограничить ретрансляцию';

  @override
  String get stFix => 'Исправить';

  @override
  String get stKeepActiveTitle => 'Оставить Droplet активным?';

  @override
  String get stKeepActiveBody =>
      'Постоянное уведомление будет показывать, что Droplet ретранслирует сеть, даже при закрытом приложении. Взамен расход батареи увеличится.';

  @override
  String get stEnable => 'Включить';

  @override
  String get stCancel => 'Отмена';

  @override
  String get stAboutTagline =>
      'Офлайн-сообщения и звонки, без интернета и оператора.';

  @override
  String get stAboutDirect => 'Прямая сеть между устройствами — без сервера';

  @override
  String get stAboutE2E => 'Сквозное шифрование всех сообщений';

  @override
  String get stAboutNoThirdParty =>
      'Никакие данные не передаются третьим лицам';

  @override
  String get stAttributionEmoji =>
      'Анимированные эмодзи: Noto Animated Emoji © Google, лицензия CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Ассистент: Gemma 3 1B-IT © Google, квантован (int4) litert-community и переиздан Droplet согласно условиям использования Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Фон чата';

  @override
  String get stChatPatterns => 'Узоры Droplet';

  @override
  String get stChatPatternsSubtitle => 'Небольшие рисунки поверх фона';

  @override
  String get stChatBgFooter =>
      'Градиент сдвигается на шаг с каждым отправленным сообщением. Выберите «Нет» для однотонного фона: тогда ничего не вычисляется, что экономит батарею.';

  @override
  String get stBgFree => 'Бесплатные';

  @override
  String get stBgPremium => 'Премиум · анимированные';

  @override
  String get stBgNone => 'Нет';

  @override
  String get stBgDefault => 'По умолчанию';

  @override
  String get stBgThisChat => 'Фон этого чата';

  @override
  String get stTextSize => 'Размер текста';

  @override
  String get stBubbleCorners => 'Скругление сообщений';

  @override
  String get stAccentHeader => 'Цвет акцента';

  @override
  String get stAccentFooter =>
      'Он окрашивает ваши сообщения, кнопки и ссылки во всём приложении.';

  @override
  String get stChatListHeader => 'Список чатов';

  @override
  String get stChatListTwoLines => 'Две строки';

  @override
  String get stChatListThreeLines => 'Три строки';

  @override
  String get stResetAppearance => 'Сбросить оформление';

  @override
  String get stPreviewIncoming => 'Увидимся вечером?';

  @override
  String get stPreviewOutgoing => 'Да, с удовольствием!';

  @override
  String get stAppearanceRow => 'Оформление';

  @override
  String get stAppearanceSubtitle => 'Тема, цвет, размер текста, фоны';

  @override
  String get stBgApply => 'Выбрать этот фон';

  @override
  String get stBgUnlock => 'Открыть с Премиум';

  @override
  String get stBgApplied => 'Фон установлен';

  @override
  String get stBgPreviewHint =>
      'Фон движется, а его цвета поворачиваются с каждым отправленным сообщением.';

  @override
  String get stBgPreviewIncoming => 'Видел новый фон?';

  @override
  String get stBgPreviewOutgoing => 'Да, он великолепен ✨';

  @override
  String get stSoundHeader => 'Звуки';

  @override
  String get stSoundToggle => 'Звуки приложения';

  @override
  String get stSoundSubtitle => 'Сообщения, подключения, оповещения';

  @override
  String get stSoundFooter =>
      'Короткие сигналы на громкости системных уведомлений — беззвучно, если телефон в бесшумном режиме или в режиме фокусировки.';

  @override
  String get stPacksHeader => 'Помощник — офлайн-памятки';

  @override
  String get stPacksToggle => 'Памятки по первой помощи и ЧС';

  @override
  String get stPacksSubtitle =>
      'Помощник опирается на них при первой помощи и чрезвычайных ситуациях.';

  @override
  String get stPacksFooter =>
      'Встроенные справочные памятки (первая помощь, землетрясение, наводнение, питьевая вода…). Когда вопрос к ним относится, помощник цитирует памятку, а не гадает. Они не заменяют обучение или вызов экстренных служб.';

  @override
  String get stPrivateModeHeader => 'Приватный режим';

  @override
  String get stTorFooter =>
      'Tor защищает ваш IP-адрес и переписку, направляя их через сеть Tor. Локальная ячеистая сеть (BLE/Wi-Fi) продолжает работать в обычном режиме.';

  @override
  String get stTorActiveAnon => 'Активен — ваши данные анонимизированы';

  @override
  String get stTorConnecting => 'Подключение…';

  @override
  String get stTorDisabled => 'Приватный режим отключён';

  @override
  String get callsTitle => 'Звонки';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пропущенного звонка',
      many: '$count пропущенных звонков',
      few: '$count пропущенных звонка',
      one: '$count пропущенный звонок',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Новый звонок';

  @override
  String get callsAll => 'Все';

  @override
  String get callsMissed => 'Пропущенные';

  @override
  String get callsNoneMissed => 'Нет пропущенных звонков';

  @override
  String get callsNone => 'Нет звонков';

  @override
  String get callsMissedEmptyBody =>
      'Здесь появятся звонки, на которые вы не ответили.';

  @override
  String get callsEmptyBody =>
      'Звонки идут через локальную сеть, без оператора и тарифа. Здесь появится ваша история.';

  @override
  String get callsRetained200 =>
      'Последние 200 звонков хранятся только на этом устройстве.';

  @override
  String get callsIncoming => 'Входящий';

  @override
  String get callsOutgoing => 'Исходящий';

  @override
  String get callsMissedLabel => 'Пропущен';

  @override
  String get callsNoAnswer => 'Без ответа';

  @override
  String get callsConnectionFailed => 'Сбой соединения';

  @override
  String get callsYesterday => 'вчера';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m мин $s с';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s с';
  }

  @override
  String get peersTitle => 'Пиры';

  @override
  String get peersSearching => 'Идёт поиск…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройства в радиусе действия',
      many: '$count устройств в радиусе действия',
      few: '$count устройства в радиусе действия',
      one: '$count устройство в радиусе действия',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Карта сети';

  @override
  String get peersNoneInRange => 'Никого в радиусе действия';

  @override
  String get peersNoneInRangeBody =>
      'Droplet постоянно ищет устройства поблизости. Подойдите ближе к тому, у кого есть приложение, чтобы установить первое соединение.';

  @override
  String get peersDirectRange => 'В прямой зоне действия';

  @override
  String get peersDirectRangeFooter =>
      'Эти устройства доступны напрямую, без посредников.';

  @override
  String get peersRelayed => 'Через ретрансляцию';

  @override
  String get peersRelayedFooter =>
      'Эти устройства вне прямой досягаемости: сообщения доходят до них через другие телефоны.';

  @override
  String get peersRelay => 'Ретранслятор';

  @override
  String get peersCall => 'Позвонить';

  @override
  String get peersTooSlow => 'Слишком медленно для голоса — подойдите ближе';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Неизвестное соединение';

  @override
  String get peersDirect => 'напрямую';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ретрансляции',
      many: '$count ретрансляций',
      few: '$count ретрансляции',
      one: '$count ретрансляция',
      zero: 'напрямую',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Срок действия этого статуса истёк';

  @override
  String get svReceiving => 'Получение…';

  @override
  String get svReceivingBody => 'Файл поступает по локальной сети';

  @override
  String get svProgressLabel => 'Прогресс статуса';

  @override
  String get svReplyHint => 'Ответить…';

  @override
  String get svSendReply => 'Отправить ответ';

  @override
  String get svYourStatus => 'Ваш статус';

  @override
  String get svNoViewsYet =>
      'Пока никто не видел этот статус.\nОн продолжит распространяться, пока вы будете встречать другие устройства.';

  @override
  String get svJustNow => 'только что';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '$count минуту назад',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '$count час назад',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Музыка';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count просмотра',
      many: '$count просмотров',
      few: '$count просмотра',
      one: '$count просмотр',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лайка',
      many: '$count лайков',
      few: '$count лайка',
      one: '$count лайк',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответа',
      many: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Оригинал';

  @override
  String get cpFilterDark => 'Тёмный';

  @override
  String get cpFilterBright => 'Яркий';

  @override
  String get cpFilterVintage => 'Винтаж';

  @override
  String get cpWriteStatusHint => 'Напишите статус';

  @override
  String get cpPreparingVideo => 'Подготовка видео…';

  @override
  String get cpLoadingEllipsis => 'Загрузка…';

  @override
  String cpEndsIn(Object s) {
    return 'Заканчивается через $s с';
  }

  @override
  String get cpModeVideo => 'Видео';

  @override
  String get cpModePhoto => 'Фото';

  @override
  String get cpModeMessage => 'Сообщение';

  @override
  String get cpModeVoice => 'Голос';

  @override
  String get gcChooseName => 'Выберите название для группы';

  @override
  String get gcSelectOneMember => 'Выберите хотя бы одного участника';

  @override
  String get gcCreationFailed => 'Не удалось создать группу';

  @override
  String get gcNewGroup => 'Новая группа';

  @override
  String get gcGroupName => 'Название группы';

  @override
  String get gcNameHint => 'напр. Полевая команда';

  @override
  String get gcMembers => 'Участники';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выбрано',
      many: '$count выбрано',
      few: '$count выбрано',
      one: '$count выбран',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Никого в радиусе действия';

  @override
  String get gcGetCloserBody =>
      'Подойдите ближе к другому устройству с Droplet: пиры появятся здесь автоматически.';

  @override
  String get gcCreateGroup => 'Создать группу';

  @override
  String get gcConnected => 'Подключён';

  @override
  String get gcAlreadyMet => 'Уже встречались';

  @override
  String get giRenameGroup => 'Переименовать группу';

  @override
  String get giRenameFailed => 'Не удалось переименовать';

  @override
  String get giNoPeerToAdd => 'Нет доступных пиров для добавления';

  @override
  String get giAddMemberHeader => 'ДОБАВИТЬ УЧАСТНИКА';

  @override
  String get giAddMemberFailed => 'Не удалось добавить участника';

  @override
  String get giRemoveMemberTitle => 'Удалить этого участника?';

  @override
  String get giRemoveMemberBody =>
      'Он больше не сможет читать сообщения, отправленные после удаления.';

  @override
  String get giRemove => 'Удалить';

  @override
  String get giRemoveMemberFailed => 'Не удалось удалить участника';

  @override
  String get giLeaveGroupTitle => 'Покинуть группу?';

  @override
  String get giLeaveGroupBody =>
      'Вы больше не будете получать сообщения, отправленные после выхода.';

  @override
  String get giLeave => 'Покинуть';

  @override
  String get giNoOneReachable =>
      'Сейчас никто из участников не доступен по локальному Wi-Fi';

  @override
  String get giMax4Participants =>
      'Максимум 4 участника в групповом звонке — будут вызваны только первые 3 доступных';

  @override
  String get giGroupNotFound => 'Группа не найдена';

  @override
  String get giGroupInfo => 'Информация о группе';

  @override
  String get giGroupCall => 'Групповой звонок';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Групповые сообщения зашифрованы';

  @override
  String get giAdd => 'Добавить';

  @override
  String get giMe => 'я';

  @override
  String get giAdministrator => 'Администратор';

  @override
  String get giLeaveGroup => 'Покинуть группу';

  @override
  String get sfNoLocationShared => 'Местоположение не передано';

  @override
  String get sfLocationShared => 'Местоположение передано';

  @override
  String sfDistanceMeters(Object m) {
    return 'в $m м';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'в $km км';
  }

  @override
  String get sfBearingN => 'на севере';

  @override
  String get sfBearingNE => 'на северо-востоке';

  @override
  String get sfBearingE => 'на востоке';

  @override
  String get sfBearingSE => 'на юго-востоке';

  @override
  String get sfBearingS => 'на юге';

  @override
  String get sfBearingSW => 'на юго-западе';

  @override
  String get sfBearingW => 'на западе';

  @override
  String get sfBearingNW => 'на северо-западе';

  @override
  String get sfBroadcastSafeTitle => 'Отправить «Я в безопасности»?';

  @override
  String get sfBroadcastSafeMessage =>
      'Этот статус будет виден всей mesh-сети в радиусе действия, а не только вашим контактам. Вы можете указать приблизительное местоположение (округлённое, никогда не точное).';

  @override
  String get sfWithLocation => 'С примерным местоположением';

  @override
  String get sfWithoutLocation => 'Без местоположения';

  @override
  String get sfStatusBroadcast => 'Статус отправлен в mesh-сеть';

  @override
  String get sfBroadcastFailed => 'Не удалось отправить';

  @override
  String get sfHelpRequestTitle => 'Отправить «Мне нужна помощь»?';

  @override
  String get sfHelpRequestMessage =>
      'Этот статус сообщит устройствам в радиусе действия, что вам нужна помощь. Вы можете указать приблизительное местоположение.';

  @override
  String get sfHelpRequestBroadcast => 'Запрос помощи отправлен в mesh-сеть';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Режим ЧС';

  @override
  String get sfViewOnMap => 'Смотреть на карте';

  @override
  String get sfNeedHelp => 'Мне нужна помощь';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Получено $count отметки',
      many: 'Получено $count отметок',
      few: 'Получено $count отметки',
      one: 'Получена $count отметка',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Пока не получено ни одной отметки';

  @override
  String get sfCheckinsAppearHere =>
      'Здесь появятся статусы «в безопасности», отправленные устройствами в радиусе действия.';

  @override
  String get sfSafeLabel => 'В безопасности';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'В безопасности · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'В безопасности · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Отправить мой статус безопасности в mesh-сеть';

  @override
  String get sfImSafe => 'Я в безопасности';

  @override
  String get emSosActive => 'SOS АКТИВЕН';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'Сигнал SOS активен — передаётся на все ближайшие устройства';

  @override
  String get emPullToSendSignal => 'Нажмите, чтобы отправить сигнал бедствия';

  @override
  String get emSignalRelayedDescription =>
      'Сигнал передаётся от устройства к устройству\nпо всей mesh-сети.';

  @override
  String get emBroadcasting => 'Отправка...';

  @override
  String get emSharePosition => 'Поделиться местоположением';

  @override
  String get emSosActivated => 'Сигнал SOS активирован';

  @override
  String get emSafeStatusMessage => '🟢 Я в безопасности';

  @override
  String get emSafetyStatusBroadcast => 'Статус безопасности отправлен';

  @override
  String get pmEnterPayingNumber =>
      'Введите номер, с которого будет произведена оплата (9 цифр).';

  @override
  String get pmRequestSent => 'Запрос отправлен…';

  @override
  String get pmPaymentLaunchFailed =>
      'Не удалось запустить платёж. Проверьте номер и подключение или оплатите вручную ниже.';

  @override
  String get pmValidateOnPhone =>
      'Подтвердите на телефоне: введите код Mobile Money, когда появится запрос.';

  @override
  String get pmPaymentNotConfirmed =>
      'Платёж не подтверждён. Ничего не разблокировано.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'Платёж прошёл, но полученная лицензия недействительна. Напишите нам, она будет выпущена заново: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro активирован';

  @override
  String get pmPackUnlocked => 'Пакет разблокирован';

  @override
  String get pmInvalidCode =>
      'Этот код недействителен на этом устройстве. Убедитесь, что вы отправили код устройства, указанный выше.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'То, что Droplet\nникогда не попросит';

  @override
  String get pmNeverAskBody =>
      'Ни рекламы, ни обязательной подписки, ни перепродажи ваших данных — для их сбора даже нет сервера. Пакет и Pro финансируют остальное.';

  @override
  String get pmCommunitySemantics =>
      'Присоединяйтесь к сообществу из более чем 1200 активных участников';

  @override
  String get pmCommunityText =>
      'Присоединяйтесь к более чем 1200 участникам mesh-сети';

  @override
  String get pmProPreviewSemantics =>
      'Предпросмотр разблокированных функций Pro';

  @override
  String get pmAnimatedEmojis => 'Анимированные\nэмодзи';

  @override
  String get pmWallpapers => 'Обои\nчата';

  @override
  String get pmAppIcons => 'Значки\nприложения';

  @override
  String get pmOnceForLife => 'разово, навсегда';

  @override
  String get pmProAdvantage1 => 'Десять значков и восемь обоев из пакета';

  @override
  String get pmProAdvantage2 => 'Значок Pro рядом с вашим именем';

  @override
  String get pmProAdvantage3 => 'Будущие функции без доплаты';

  @override
  String get pmPackTitle => 'Пакет';

  @override
  String get pmOnce => 'разово';

  @override
  String get pmPackAdvantage1 => 'Десять дополнительных значков приложения';

  @override
  String get pmPackAdvantage2 => 'Восемь обоев чата';

  @override
  String get pmPayByHand => 'Или оплатите вручную';

  @override
  String get pmHowTo => 'Как это сделать';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Если запрос не пришёл на ваш телефон, или если вы предпочитаете отправить деньги самостоятельно.';

  @override
  String pmStep1Title(Object montant) {
    return 'Отправьте $montant F';
  }

  @override
  String get pmStep1Body =>
      'Выберите своего оператора: откроется его меню, а номер останется здесь на экране, пока вы в нём ориентируетесь.';

  @override
  String get pmStep2Title => 'Отправьте код своего устройства';

  @override
  String get pmStep2Body =>
      'Вместе со скриншотом платежа. Без этого кода лицензию невозможно создать — она действительна только для вашего телефона.';

  @override
  String get pmStep3Title => 'Вы получаете лицензию';

  @override
  String get pmStep3Body =>
      'Длинная строка, начинающаяся с DROP1. Вставьте её ниже: разблокировка происходит мгновенно и работает офлайн, навсегда.';

  @override
  String get pmPayNow => 'Оплатить сейчас';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money или Orange Money, с этого телефона или с другого.';

  @override
  String get pmPhoneNumberSemantics => 'Номер телефона для оплаты Mobile Money';

  @override
  String get pmWaitingForCode => 'Ожидание вашего кода…';

  @override
  String pmPayAmount(Object montant) {
    return 'Оплатить $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Восстановить предыдущую покупку';

  @override
  String get pmAlreadyPaidRestore => 'Уже оплатили? Восстановить';

  @override
  String pmDialCode(Object code) {
    return 'Наберите $code со своего телефона';
  }

  @override
  String get pmChooseOperatorSemantics => 'Выберите платёжного оператора';

  @override
  String get pmNumberAmountFilled =>
      'Номер и сумма уже заполнены — остаётся только ваш секретный код.';

  @override
  String get pmOrangeMenuInstructions =>
      'В меню Orange: перевод денег, затем номер и сумма ниже.';

  @override
  String get pmLabelNumber => 'Номер';

  @override
  String get pmLabelAmount => 'Сумма';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Оплатить $montant франков через $operator';
  }

  @override
  String get pmMenuOpen => 'Меню открыто';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Здравствуйте, я только что оплатил(а) Droplet.\n\nПредложение: $offer\nСумма: $amount F\nКод устройства: $code\n\n(прикладываю скриншот платежа)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp не найден — код скопирован. Отправьте его на $contact';
  }

  @override
  String get pmPrepareRequest => 'Подготовить запрос';

  @override
  String get pmReceivedLicense => 'Я получил(а) лицензию';

  @override
  String get pmPaste => 'Вставить';

  @override
  String get pmUnlock => 'Разблокировать';

  @override
  String get pmProIsActive => 'Droplet Pro активен';

  @override
  String get pmPackIsUnlocked => 'Пакет разблокирован';

  @override
  String get pmProActiveDescription =>
      'Значок Pro сопровождает ваше имя, и все значки и обои открыты для вас.';

  @override
  String get pmPackActiveDescription =>
      'Десять значков и восемь обоев из пакета открыты для вас в настройках.';

  @override
  String get pmLicenseDeviceBound =>
      'Ваша лицензия действительна для этого телефона. Если вы смените телефон, сохраните сообщение с лицензией — её бесплатно перевыпустят.';

  @override
  String torError(Object e) {
    return 'Ошибка: $e';
  }

  @override
  String get torEnable => 'Включить Tor';

  @override
  String get torProtected => 'Защищено';

  @override
  String get torDisabled => 'Отключено';

  @override
  String get torStateHeader => 'Состояние';

  @override
  String get torCircuit => 'Цепь';

  @override
  String get torActive => 'Активна';

  @override
  String get torInProgress => 'Выполняется…';

  @override
  String get torInactive => 'Неактивна';

  @override
  String get torFailed => 'Не удалось';

  @override
  String get torReason => 'Причина';

  @override
  String get torBannerConnecting => 'Подключение к Tor…';

  @override
  String get torBannerActive => 'Tor активен';

  @override
  String get torBannerError => 'Tor недоступен';

  @override
  String get torBannerOff => 'Tor выключен';

  @override
  String get torEncryption => 'Шифрование';

  @override
  String get torLatency => 'Задержка';

  @override
  String get torContactsHeader => 'Контакты';

  @override
  String get torScanQrFooter =>
      'Отсканируйте QR-код или найдите имя в каталоге, чтобы добавить удалённый контакт.';

  @override
  String get torScanQrCode => 'Сканировать QR-код';

  @override
  String get torMyQrCode => 'Мой QR-код';

  @override
  String get torInformationHeader => 'Информация';

  @override
  String get torVersion => 'Версия';

  @override
  String get torHowItWorks => 'Как это работает?';

  @override
  String get torConnecting => 'Подключение…';

  @override
  String get torInactiveTitle => 'Tor неактивен';

  @override
  String get torDataThroughTor => 'Ваши данные проходят через сеть Tor';

  @override
  String get torEstablishingCircuit => 'Установка цепи (10-30 с)';

  @override
  String get torActivateToProtect => 'Включите, чтобы защитить свою личность';

  @override
  String get torHowItWorksTitle => 'Как Tor защищает ваши данные';

  @override
  String get torEncryptedCircuit => 'Зашифрованная цепь';

  @override
  String get torEncryptedCircuitDesc =>
      'Ваши сообщения проходят через 3 узла Tor по всему миру.';

  @override
  String get torHiddenIp => 'Скрытый IP';

  @override
  String get torHiddenIpDesc =>
      'Ни один сайт не может увидеть ваш настоящий адрес.';

  @override
  String get torMeshPreserved => 'Mesh-сеть сохранена';

  @override
  String get torMeshPreservedDesc =>
      'Bluetooth и локальный Wi-Fi продолжают работать.';

  @override
  String get torUnderstood => 'Понятно';

  @override
  String get qrTorNotActive =>
      'Tor не активен. Включите его в Настройки > Tor.';

  @override
  String get qrScanContactCode => 'Отсканируйте QR-код контакта';

  @override
  String get qrCodeFromContactScreen =>
      'Код должен быть получен с экрана Tor вашего контакта';

  @override
  String get qrScanAnother => 'Сканировать другой';

  @override
  String get qrChat => 'Написать';

  @override
  String get qgScanToConnect => 'Сканируйте для подключения';

  @override
  String get qgCopied => 'Скопировано ✓';

  @override
  String get qgCopyCode => 'Скопировать код';

  @override
  String get qgHowItWorks => 'Как это работает';

  @override
  String get qgStep1 => 'Покажите этот QR-код своему контакту';

  @override
  String get qgStep2 => 'Он сканирует его со своего экрана Tor';

  @override
  String get qgStep3 => 'Вы подключены через Tor';

  @override
  String get shShareTo => 'Поделиться с…';

  @override
  String get shSearchConversation => 'Поиск переписки';

  @override
  String get shNoConversation => 'Нет переписок';

  @override
  String get shOpenChatFirst =>
      'Сначала откройте переписку в Droplet, чтобы поделиться в ней контентом.';

  @override
  String get shGroup => 'Группа';

  @override
  String get shDiscussion => 'Переписка';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента для отправки',
      many: '$count элементов для отправки',
      few: '$count элемента для отправки',
      one: '$count элемент для отправки',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Карта установлена';

  @override
  String get omClearCacheTitle => 'Очистить кэш?';

  @override
  String get omRemoveZoneTitle => 'Удалить эту область?';

  @override
  String get omClearCacheMessage =>
      'Области, которые вы просматривали, больше не будут доступны офлайн. Они восстановятся, когда вы снова просмотрите их с подключением к сети.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '«$name» будет удалена с этого устройства.';
  }

  @override
  String get omClear => 'Очистить';

  @override
  String get omTitle => 'Карты';

  @override
  String get omReading => 'Чтение…';

  @override
  String get omNoMapsSaved => 'Нет сохранённых карт';

  @override
  String omSizeOnDevice(Object size) {
    return '$size на этом устройстве';
  }

  @override
  String get omBrowseMapHint =>
      'Просматривайте карту при подключении к сети: просмотренные области остаются доступны офлайн.';

  @override
  String get omOnThisDevice => 'На этом устройстве';

  @override
  String get omZonesFillThemselves =>
      'Просмотренные области заполняются автоматически, пока вы просматриваете карту при подключении к сети.';

  @override
  String get omMbtilesExplainer =>
      'Файл .mbtiles содержит целый регион, подготовленный заранее. Это стандартный формат офлайн-карт: его может создать любой картографический инструмент.';

  @override
  String get omImportMap => 'Импортировать карту';

  @override
  String get omReadingFile => 'Чтение файла…';

  @override
  String get omMbtilesFromPhone => 'Файл .mbtiles с этого телефона';

  @override
  String get omAttributionText =>
      'Данные предоставлены OpenStreetMap (лицензия ODbL), тайлы карты предоставляются CARTO. Droplet никогда не загружает целый регион заранее: ни один бесплатный сервис этого не позволяет. Сохраняется только то, что вы просматриваете.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тайла',
      many: '$count тайлов',
      few: '$count тайла',
      one: '$count тайл',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '$k тыс. тайлов';
  }

  @override
  String omSizeKb(Object n) {
    return '$n КБ';
  }

  @override
  String omSizeMb(Object n) {
    return '$n МБ';
  }

  @override
  String omSizeGb(Object n) {
    return '$n ГБ';
  }

  @override
  String get nwTitle => 'Новости';

  @override
  String get nwStatusesNetwork24h => 'Статусы сети · 24 ч';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count статуса сети',
      many: '$count статусов сети',
      few: '$count статуса сети',
      one: '$count статус сети',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Опубликовать статус';

  @override
  String get nwNoNewsYet => 'Пока новостей нет';

  @override
  String get nwStatusesAppearHere =>
      'Здесь появятся статусы, опубликованные людьми поблизости, без использования интернета.';

  @override
  String get nwRecent => 'Недавние';

  @override
  String get nwStatusExpires =>
      'Статус исчезает автоматически через 24 часа после публикации.';

  @override
  String get nwPhoto => '📷 Фото';

  @override
  String get nwVideo => '🎥 Видео';

  @override
  String get nwVoiceMessage => '🎤 Голосовое сообщение';

  @override
  String get nwMusic => '🎵 Музыка';

  @override
  String get nwStatusFallback => 'Статус';

  @override
  String get nwMyStatus => 'Мой статус';

  @override
  String get nwTapToPublish => 'Нажмите, чтобы опубликовать в сети';

  @override
  String get nwNotSeenYet => 'Пока не просмотрено';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Просмотрено $count человека',
      many: 'Просмотрено $count людьми',
      few: 'Просмотрено $count людьми',
      one: 'Просмотрено $count человеком',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Местоположение недоступно — убедитесь, что службы геолокации включены.';

  @override
  String mpDistanceMeters(Object m) {
    return '$m м';
  }

  @override
  String mpDistanceKm(Object km) {
    return '$km км';
  }

  @override
  String mpDistanceFromYou(Object distance) {
    return '$distance от вас';
  }

  @override
  String get mpTitle => 'Местоположение';

  @override
  String get mpOffline => 'Офлайн';

  @override
  String get mpOnlineMap => 'Карта онлайн';

  @override
  String get mpMyPosition => 'Моё местоположение';

  @override
  String get mpLayers => 'Слои';

  @override
  String get mpOfflineToast =>
      'Офлайн-карта: будут показаны только уже сохранённые области.';

  @override
  String get mpOnlineToast =>
      'Карта онлайн: просмотренные области будут сохранены на будущее.';

  @override
  String get mpMapLabel => 'Карта';

  @override
  String get mpSatelliteLabel => 'Спутник';

  @override
  String get mpSatelliteMode => 'Спутниковый режим';

  @override
  String get mpMapMode => 'Режим карты';

  @override
  String get mpWrite => 'Написать';

  @override
  String get mpCenter => 'Центрировать';

  @override
  String get mpNoOneOnMap => 'На карте никого нет';

  @override
  String get mpPositionsAppearHere =>
      'Местоположения появляются здесь, когда контакт делится ими из режима безопасности.';

  @override
  String get mpYou => 'Вы';

  @override
  String get mnTitle => 'Mesh-сеть';

  @override
  String get mnPeers => 'Устройства';

  @override
  String get mnAvgHops => 'Ср. переходов';

  @override
  String get mnSignal => 'Сигнал';

  @override
  String get mnStrong => 'Сильный';

  @override
  String get mnMedium => 'Средний';

  @override
  String get mnSearchingPeers => 'Поиск устройств в радиусе действия…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройства подключено',
      many: '$count устройств подключено',
      few: '$count устройства подключено',
      one: '$count устройство подключено',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Пока нет подключённых устройств';

  @override
  String get mnGetCloserHint =>
      'Подойдите ближе к другому устройству с установленным Droplet — обнаружение происходит автоматически, без настройки.';

  @override
  String get mnConnectedPeersHeader => 'Подключённые устройства';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count перехода',
      many: '$count переходов',
      few: '$count перехода',
      one: '$count переход',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Локальный Wi-Fi';

  @override
  String get mnP2pNative => 'Встроенный P2P';

  @override
  String get mnActiveGateway => 'Активный шлюз';

  @override
  String get mnPath => 'Путь';

  @override
  String get mnTransport => 'Транспорт';

  @override
  String get mnBattery => 'Батарея';

  @override
  String get mnScore => 'Оценка';

  @override
  String get mnReconnecting => 'Переподключение';

  @override
  String get cnBronze => 'Бронза';

  @override
  String get cnSilver => 'Серебро';

  @override
  String get cnGold => 'Золото';

  @override
  String get cnDiamond => 'Алмаз';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count балла',
      many: '$count баллов',
      few: '$count балла',
      one: '$count балл',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points до уровня «$tier»';
  }

  @override
  String get cnRelayedMessages => 'Сообщения, переданные другим';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n очк.';
  }

  @override
  String get cnGatewayMinutes => 'Минуты в режиме ретранслятора (шлюз)';

  @override
  String get cnExplanation =>
      'Каждое сообщение, которое ваше устройство передаёт другим, и каждая минута, пока оно остаётся доступным в роли ретранслятора, помогают mesh-сети охватывать больше людей на большем расстоянии. Этот значок никак не влияет на приложение — это просто признание вашего вклада.';

  @override
  String get nmTitle => 'Новое сообщение';

  @override
  String get nmNewGroup => 'Новая группа';

  @override
  String get nmScanCode => 'Сканировать код';

  @override
  String get nmVerifyContactIdentity => 'Проверить личность контакта';

  @override
  String get nmNoOneInRange => 'Никого в радиусе действия';

  @override
  String get nmNoResult => 'Нет результатов';

  @override
  String get nmPeopleWillAppearHere =>
      'Здесь появятся люди, обнаруженные вашим устройством.';

  @override
  String get nmInRange => 'В радиусе действия';

  @override
  String get nmDirectConnection => 'Прямое подключение';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Через $count ретранслятора',
      many: 'Через $count ретрансляторов',
      few: 'Через $count ретранслятора',
      one: 'Через $count ретранслятор',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'Файл слишком большой (макс. 50 МБ)';

  @override
  String get chCannotReadMedia => 'Не удалось прочитать этот медиафайл';

  @override
  String get chLocationDenied =>
      'Доступ к геолокации отклонён — включите её в настройках телефона, чтобы поделиться местоположением.';

  @override
  String get chGettingPosition => 'Определение местоположения…';

  @override
  String get chPositionUnavailable =>
      'Местоположение недоступно — повторите попытку на открытом воздухе.';

  @override
  String get chMicPermissionDenied => 'Доступ к микрофону отклонён';

  @override
  String get chCannotStartRecording => 'Не удалось начать запись';

  @override
  String get chVoiceSendFailed => 'Не удалось отправить голосовое сообщение';

  @override
  String get chFileSendFailed => 'Не удалось отправить файл';

  @override
  String get chAudioNotFullyReceived => 'Аудио ещё не получено полностью';

  @override
  String get chVoiceUnreadable =>
      'Это голосовое сообщение не воспроизводится — возможно, оно пришло не полностью.';

  @override
  String get chFileNotFullyReceived => 'Файл ещё не получен полностью';

  @override
  String get chSaveFailed => 'Не удалось сохранить';

  @override
  String chSavedIn(Object folder) {
    return 'Сохранено в $folder';
  }

  @override
  String get chMessageCopied => 'Сообщение скопировано';

  @override
  String get chCallImpossibleRelay =>
      'Голосовой звонок невозможен: этот узел доступен только через ретранслятор или Bluetooth, что слишком медленно для голоса. Подойдите ближе, чтобы перейти на Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'Ссылка скопирована: $url';
  }

  @override
  String get chEditMessageTitle => 'Изменить сообщение';

  @override
  String get chMessageHint => 'Сообщение';

  @override
  String get chNeverMet => 'Никогда не встречались';

  @override
  String get chSeenJustNow => 'Только что был в сети';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Был в сети $count минуты назад',
      many: 'Был в сети $count минут назад',
      few: 'Был в сети $count минуты назад',
      one: 'Был в сети $count минуту назад',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Был в сети $count часа назад',
      many: 'Был в сети $count часов назад',
      few: 'Был в сети $count часа назад',
      one: 'Был в сети $count час назад',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Был в сети вчера';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Был в сети $count дня назад',
      many: 'Был в сети $count дней назад',
      few: 'Был в сети $count дня назад',
      one: 'Был в сети $count день назад',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Вне зоны действия';

  @override
  String get chCloseSearchTooltip => 'Закрыть поиск';

  @override
  String get chNetworkDetailsSemantics => 'Сеть Droplet, посмотреть детали';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'печатает…';

  @override
  String get chBroadcastChannel => 'Канал вещания';

  @override
  String get chNearby => 'Поблизости';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Доступен через $count ретранслятора',
      many: 'Доступен через $count ретрансляторов',
      few: 'Доступен через $count ретранслятора',
      one: 'Доступен через $count ретранслятор',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Переподключение…';

  @override
  String get chSearchInConversation => 'Поиск в переписке';

  @override
  String get chVoiceCall => 'Голосовой звонок';

  @override
  String get chVideoCall => 'Видеозвонок';

  @override
  String get chCallImpossibleBtRelay =>
      'Звонок невозможен: соединение через Bluetooth или ретранслятор';

  @override
  String get chGroupInfoTooltip => 'Информация о группе';

  @override
  String get chNoneFound => 'Нет';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Более раннее совпадение';

  @override
  String get chNewerResult => 'Более позднее совпадение';

  @override
  String get chLoadingOlderMessages => 'Загрузка более ранних сообщений…';

  @override
  String get chToday => 'Сегодня';

  @override
  String get chYesterday => 'Вчера';

  @override
  String get chMonday => 'Понедельник';

  @override
  String get chTuesday => 'Вторник';

  @override
  String get chWednesday => 'Среда';

  @override
  String get chThursday => 'Четверг';

  @override
  String get chFriday => 'Пятница';

  @override
  String get chSaturday => 'Суббота';

  @override
  String get chSunday => 'Воскресенье';

  @override
  String get chSayHello => 'Поздоровайтесь 👋';

  @override
  String get chBroadcastEmptyBody =>
      'Здесь появляются сообщения без получателя.';

  @override
  String get chP2pRelayedBody =>
      'Ваш обмен сообщениями передаётся напрямую между устройствами, без интернета.';

  @override
  String get chReply => 'Ответить';

  @override
  String get chReplyInThread => 'Ответить в теме';

  @override
  String get chCopy => 'Копировать';

  @override
  String get chAccessibilityMe => 'Я';

  @override
  String get chPhotoLabel => 'Фото';

  @override
  String get chVideoLabel => 'Видео';

  @override
  String get chVoiceMessageLabel => 'Голосовое сообщение';

  @override
  String chFileLabel(Object name) {
    return 'Файл $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Стикер $name';
  }

  @override
  String get chSendingStatus => 'отправляется';

  @override
  String get chPendingStatus => 'в очереди';

  @override
  String get chFailedStatus => 'сбой отправки';

  @override
  String get chReadStatus => 'прочитано';

  @override
  String get chDeliveredStatus => 'доставлено';

  @override
  String get chSentStatus => 'отправлено';

  @override
  String get chForwarded => 'Переслано';

  @override
  String get chRetrySendLabel => 'Повторить отправку';

  @override
  String get chTransmissionDetailsLabel => 'Подробности передачи';

  @override
  String get chEditedBadge => 'изменено';

  @override
  String get chFileWord => 'Файл';

  @override
  String chSizeBytes(Object n) {
    return '$n Б';
  }

  @override
  String chSizeKb(Object n) {
    return '$n КБ';
  }

  @override
  String chSizeMb(Object n) {
    return '$n МБ';
  }

  @override
  String get chVideoReceiving => 'Видео принимается';

  @override
  String get chPreparingVideo => 'Подготовка видео…';

  @override
  String get nmContacts => 'Контакты';

  @override
  String get nmFindByPseudo => 'Найти по имени';

  @override
  String get nmViaInternet => 'Через интернет';

  @override
  String get nmOutOfRange => 'Вне зоны';

  @override
  String get chatsInvitePerson => 'Пригласить человека';

  @override
  String get ivTitle => 'Пригласите близких';

  @override
  String get ivSubtitle =>
      'Droplet лучше, когда рядом важные люди — даже без сети.';

  @override
  String get ivByNumber => 'По номеру телефона';

  @override
  String get ivNumberHint => 'Номер с кодом страны (+7…)';

  @override
  String get ivContacts => 'Контакты';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'По ссылке';

  @override
  String get ivCopy => 'Копировать';

  @override
  String get ivShare => 'Поделиться';

  @override
  String get ivCopied => 'Ссылка скопирована';

  @override
  String get ivByQr => 'По QR-коду';

  @override
  String get ivQrHint => 'Пусть человек отсканирует его при встрече.';

  @override
  String get ivScan => 'Сканировать код';

  @override
  String get ivPrivacy =>
      'Ссылка и код содержат только ваш публичный ID и ключ. Номера в Droplet не отправляются.';

  @override
  String get evTitle => 'Редактировать видео';

  @override
  String evSplit(int n) {
    return 'Разделить на $n статусов';
  }

  @override
  String evSplitHint(int s) {
    return 'Каждая часть — не более $s с';
  }

  @override
  String evPublished(int n) {
    return 'Опубликовано статусов: $n';
  }

  @override
  String get svReply => 'Ответить';

  @override
  String get svStatusLabel => 'Статус';

  @override
  String svSeenBy(int n) {
    return 'Просмотрели: $n';
  }

  @override
  String get clMissedVoice => 'Пропущенный голосовой вызов';

  @override
  String get clMissedVideo => 'Пропущенный видеовызов';

  @override
  String get clCallBack => 'Перезвонить';

  @override
  String get stoTitle => 'Хранилище';

  @override
  String get stoSubtitle => 'Фото, видео и файлы';

  @override
  String stoUsed(String taille) {
    return 'Занято: $taille';
  }

  @override
  String get stoPhotos => 'Фото';

  @override
  String get stoVideos => 'Видео';

  @override
  String get stoAudio => 'Голосовые и аудио';

  @override
  String get stoDocuments => 'Документы';

  @override
  String get stoOther => 'Прочее (статусы…)';

  @override
  String get stoByChat => 'По чатам';

  @override
  String get stoEmpty => 'На телефоне нет файлов';

  @override
  String stoDelete(int n) {
    return 'Удалить ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Эти файлы и их сообщения будут удалены с телефона.';

  @override
  String get tabSelectChat => 'Выберите чат';

  @override
  String get clConnecting => 'Соединение…';

  @override
  String chUnreadMessages(int n) {
    return 'Непрочитанных: $n';
  }

  @override
  String get csMessagesSection => 'Сообщения';

  @override
  String chGroupTyping(String noms) {
    return '$noms печатает…';
  }

  @override
  String get tsReadBy => 'Прочитали';

  @override
  String get tsDeliveredTo => 'Доставлено';

  @override
  String get tsWaitingFor => 'Ожидают';

  @override
  String get chSelect => 'Выбрать';

  @override
  String get chForward => 'Переслать';

  @override
  String get chForwardTo => 'Переслать…';

  @override
  String chSelectedCount(int n) {
    return 'Выбрано: $n';
  }

  @override
  String get chForwarded1 => 'Сообщение переслано';

  @override
  String get apCaptionHint => 'Добавить подпись…';

  @override
  String get apValidateCrop => 'Обрезать';

  @override
  String get chMediaReceiving => 'Получение';

  @override
  String get chStickersTooltip => 'Стикеры';

  @override
  String get chAttachTooltip => 'Прикрепить';

  @override
  String get chDeleteRecordingTooltip => 'Удалить запись';

  @override
  String get chSlideToCancel => 'Смахните для отмены';

  @override
  String chReplyingTo(Object pseudo) {
    return 'Ответ для $pseudo';
  }

  @override
  String get chEffectBoom => 'Бум';

  @override
  String get chEffectLoud => 'Громко';

  @override
  String get chEffectGentle => 'Мягко';

  @override
  String get chEffectInvisibleInk => 'Невидимые чернила';

  @override
  String get chEffectConfetti => 'Конфетти';

  @override
  String get chEffectFireworks => 'Фейерверк';

  @override
  String get chEffectHearts => 'Сердечки';

  @override
  String get chEffectSheetTitle => 'Эффект сообщения';

  @override
  String get chEffectSheetSubtitle =>
      'Проигрывается один раз, у вас и у собеседника';

  @override
  String get chOnBubble => 'На пузыре сообщения';

  @override
  String get chFullscreen => 'Во весь экран';

  @override
  String get chTapToReveal => 'Нажмите, чтобы показать';

  @override
  String get chThreadTitle => 'Тема обсуждения';

  @override
  String get chReplyHint => 'Ответ…';

  @override
  String get chCollapse => 'Свернуть';

  @override
  String get chSeeMore => 'Показать больше';

  @override
  String get chMessageOptionsSemantics => 'Параметры сообщения';

  @override
  String get chLoveReactionSemantics => 'Обожаю';

  @override
  String get chBroadcastMesh => 'Mesh-рассылка';

  @override
  String get chGroupFallback => 'Группа';

  @override
  String get ciSetupBiometrics =>
      'Настройте отпечаток пальца или Face ID в настройках устройства.';

  @override
  String get ciEnableLockReason => 'Включить блокировку для этой переписки';

  @override
  String get ciInfoTitle => 'Информация';

  @override
  String get ciViewConversation => 'Открыть переписку';

  @override
  String get ciGatewayOnline => 'Шлюз · в сети';

  @override
  String get ciOnline => 'В сети';

  @override
  String get ciOffline => 'Не в сети';

  @override
  String get ciMessages => 'Сообщения';

  @override
  String get ciMedia => 'Медиа';

  @override
  String get ciStart => 'Начало';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Фото ($count)',
      many: 'Фото ($count)',
      few: 'Фото ($count)',
      one: 'Фото ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Голосовой заметки ($count)',
      many: 'Голосовых заметок ($count)',
      few: 'Голосовые заметки ($count)',
      one: 'Голосовая заметка ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Файла ($count)',
      many: 'Файлов ($count)',
      few: 'Файла ($count)',
      one: 'Файл ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'Пока нет общих медиафайлов.';

  @override
  String get ciSecurityCode => 'Код безопасности';

  @override
  String get ciVerified => 'Проверено';

  @override
  String get ciKeyChanged => 'Ключ изменился';

  @override
  String get ciNotVerified => 'Не проверено';

  @override
  String get ciConversationLock => 'Блокировка переписки';

  @override
  String get ciLockEnabled =>
      'Включено — для открытия требуется отпечаток пальца';

  @override
  String get ciDisabled => 'Отключено';

  @override
  String get ciEphemeralMessages => 'Исчезающие сообщения';

  @override
  String get ci30Seconds => '30 секунд';

  @override
  String get ci5Minutes => '5 минут';

  @override
  String get ci1Hour => '1 час';

  @override
  String get ci24Hours => '24 часа';

  @override
  String get ciDurationBeforeDisappear => 'Время до исчезновения';

  @override
  String get ciBlockContactTitle => 'Заблокировать этот контакт?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo больше не сможет отправлять вам сообщения. Вы можете разблокировать его в любой момент.';
  }

  @override
  String get ciBlock => 'Заблокировать';

  @override
  String get ciUnblock => 'Разблокировать';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo заблокирован(а)';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo разблокирован(а)';
  }

  @override
  String get ciReportContactTitle => 'Пожаловаться на этот контакт?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Анонимная жалоба будет отправлена в Droplet: технический идентификатор и выбранная ниже причина, и ничего больше. Ни одно сообщение, ни один разговор с $pseudo никогда не передаётся.';
  }

  @override
  String get ciReport => 'Пожаловаться';

  @override
  String get ciReportSent => 'Жалоба отправлена. Спасибо.';

  @override
  String get ciReportFailed =>
      'Не удалось отправить жалобу — попробуйте позже.';

  @override
  String get ciReportReasonSpam => 'Спам';

  @override
  String get ciReportReasonHarassment => 'Домогательства';

  @override
  String get ciReportReasonIllegal => 'Незаконный контент';

  @override
  String get ciReportReasonOther => 'Другое';

  @override
  String mcReactWith(Object emoji) {
    return 'Отреагировать через $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh-сеть активна';

  @override
  String get nsNoDeviceInRange => 'Нет устройств в радиусе действия';

  @override
  String get nsMessagesCirculate =>
      'Ваши сообщения передаются от устройства к устройству, без использования интернета.';

  @override
  String get nsGetCloser =>
      'Подойдите ближе к другому устройству с Droplet. Ваши сообщения сохранятся и отправятся сами.';

  @override
  String get nsDevicesInRange => 'Устройства в радиусе действия';

  @override
  String get nsReconnectingTitle => 'Переподключение';

  @override
  String get nsLinkMomentarilyLost =>
      'Связь временно потеряна, но ещё не разорвана окончательно.';

  @override
  String get nsRelaysAvailable => 'Доступные ретрансляторы';

  @override
  String get nsNoRelayAvailable =>
      'На данный момент ни одно устройство не может передать ваши сообщения дальше.';

  @override
  String get nsViaBluetooth => 'Через Bluetooth';

  @override
  String get nsViaLocalWifi => 'Через локальный Wi-Fi';

  @override
  String get nsWifiCarriesMore =>
      'Wi-Fi передаёт файлы и голос; Bluetooth передаёт только текст.';

  @override
  String get scInvalidQrCode => 'Недействительный QR-код';

  @override
  String get scWrongCode => 'Это не тот код — ключ не совпадает';

  @override
  String get scCodeVerified => 'Код проверен';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Проверено — ключ $pseudo совпадает с этим кодом.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'Ключ $pseudo изменился с момента последней проверки.';
  }

  @override
  String get scNotVerifiedYet => 'Ещё не проверено.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Сравните этот код с тем, что отображается на устройстве $pseudo, или отсканируйте его QR-код для автоматической проверки.';
  }

  @override
  String get scContactKeyUnknown =>
      'Ключ контакта пока неизвестен — переподключитесь к этому устройству в mesh-сети.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Сканировать код $pseudo';
  }

  @override
  String get tsNotDelivered => 'Не доставлено';

  @override
  String get tsRead => 'Прочитано';

  @override
  String get tsDelivered => 'Доставлено';

  @override
  String get tsSendingInProgress => 'Отправляется';

  @override
  String get tsWaitingForRelay => 'Ожидание ретранслятора';

  @override
  String get tsSent => 'Отправлено';

  @override
  String tsSecondsSingular(Object value) {
    return '$value секунда';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value секунд';
  }

  @override
  String tsMinutes(Object n) {
    return '$n мин';
  }

  @override
  String tsHours(Object n) {
    return '$n ч';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Передача';

  @override
  String get tsStatus => 'Статус';

  @override
  String get tsDelayUntilRead => 'Время до прочтения';

  @override
  String get tsRoute => 'Маршрут';

  @override
  String get tsRouteDetail =>
      'Устройства, передавшие это сообщение, по порядку.';

  @override
  String get tsPath => 'Путь';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Прошло через $count устройства',
      many: 'Прошло через $count устройств',
      few: 'Прошло через $count устройства',
      one: 'Прошло через $count устройство',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Получено напрямую';

  @override
  String get tsIntermediateDevicesDetail =>
      'Промежуточные устройства передали вам это сообщение.';

  @override
  String get tsUnknown => 'Неизвестно';

  @override
  String get tsSentRouteNotReturned =>
      'Маршрут отправленного сообщения не сообщается отправителю.';

  @override
  String get tsNetwork => 'Сеть';

  @override
  String get tsMeshDroplet => 'Mesh-сеть Droplet';

  @override
  String get tsNoServerNoOperator => 'Без сервера, без оператора связи.';

  @override
  String get qsScanSecurityCode => 'Сканировать код безопасности';

  @override
  String get qsCodeDetected => 'Код обнаружен';

  @override
  String get qsFrameQrCode =>
      'Наведите камеру на QR-код, отображаемый на устройстве вашего контакта';

  @override
  String get rmRecentVideo => 'Недавнее видео';

  @override
  String get rmRecentPhoto => 'Недавнее фото';

  @override
  String get rmSeeAllPhotos => 'Смотреть все фото';

  @override
  String get rmSeeAll => 'Смотреть все';

  @override
  String get aicOriginal => 'Оригинал';

  @override
  String get aicAzure => 'Лазурь';

  @override
  String get aicNeon => 'Неон';

  @override
  String get aicPaper => 'Бумага';

  @override
  String get aicLagoon => 'Лагуна';

  @override
  String get aicAmethyst => 'Аметист';

  @override
  String get aicGold => 'Золото';

  @override
  String get aicTide => 'Прилив';

  @override
  String get aicDawn => 'Заря';

  @override
  String get aicGlass => 'Стекло';

  @override
  String get aicConstellation => 'Созвездие';

  @override
  String get aicPrism => 'Призма';

  @override
  String get aicEmerald => 'Изумруд';

  @override
  String get aicChangeIconTitle => 'Изменить значок?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'Значок «$name» заменит значок на вашем главном экране. Некоторым лаунчерам требуется несколько секунд, чтобы отобразить его, или нужно вернуться на главный экран.';
  }

  @override
  String get aicApply => 'Применить';

  @override
  String aicIconApplied(Object name) {
    return 'Значок «$name» применён';
  }

  @override
  String get aicChangeIconImpossible =>
      'Изменение значка на этом устройстве невозможно';

  @override
  String get aicTitle => 'Значок';

  @override
  String get aicCurrentOnHomeScreen =>
      'Тот, что отображается на вашем главном экране';

  @override
  String get aicUnavailablePlatform => 'Недоступно на этой платформе';

  @override
  String get aicAndroidExplanation =>
      'Android фиксирует значок приложения при установке. Droplet обходит это, объявляя несколько точек входа — по одной на значок — и оставляя активной только одну. Вашему лаунчеру может потребоваться несколько секунд, чтобы это заметить.';

  @override
  String get aicAndroidOnly => 'Изменение значка доступно только на Android.';

  @override
  String get beWeak => 'Слабый';

  @override
  String get beOkay => 'Средний';

  @override
  String get beStrong => 'Надёжный';

  @override
  String get bePasswordTooShort =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get bePasswordsDontMatch => 'Пароли не совпадают';

  @override
  String get beBackupSubject => 'Резервная копия Droplet';

  @override
  String get beBackupShareText =>
      'Зашифрованная резервная копия моей идентичности Droplet — храните в надёжном месте.';

  @override
  String get beBackupCreated => 'Резервная копия создана';

  @override
  String get beBackupFailed => 'Не удалось создать резервную копию';

  @override
  String get beBackupMyIdentity => 'Создать резервную копию личности';

  @override
  String get beWarningBody =>
      'Любой, у кого есть этот файл и пароль, может выдать себя за вас. Храните его в надёжном месте (никогда не отправляйте никому, кроме себя) и выберите пароль, который знаете только вы.';

  @override
  String get bePasswordProtects =>
      'Этот пароль защищает вашу резервную копию. Он никогда не сохраняется: без него файл станет навсегда непригодным для использования.';

  @override
  String get bePassword => 'Пароль';

  @override
  String get beConfirmPassword => 'Подтвердите пароль';

  @override
  String get beIncludeMessageHistory => 'Включить историю сообщений';

  @override
  String get beOtherwiseOnlyIdentity =>
      'В противном случае сохраняются только личность, контакты и группы';

  @override
  String get beCreateAndShare => 'Создать и поделиться резервной копией';

  @override
  String get jsErrorJournalTitle => 'Журнал ошибок';

  @override
  String get jsNoErrorsRecorded =>
      'Ошибок не зафиксировано. Это нормальное состояние.';

  @override
  String get jsLinesStayOnDevice =>
      'Эти записи остаются только на этом устройстве: у Droplet нет сервера, куда их можно было бы отправить. Если вы тестируете приложение, пожалуйста, отправьте их — без них об ошибке никто не узнает.';

  @override
  String get jsErase => 'Стереть';

  @override
  String get jsShareSubject => 'Droplet — журнал ошибок';

  @override
  String get jsShareText =>
      'Журнал ошибок Droplet. Этот файл не содержит сообщений, контактов или ключей.';

  @override
  String get jsShareUnavailable => 'Отправка недоступна — журнал скопирован';

  @override
  String get clOutgoingCall => 'Звонок…';

  @override
  String get clIncomingCall => 'Входящий звонок…';

  @override
  String get clCallImpossible => 'Не удалось совершить звонок';

  @override
  String get clCallEnded => 'Звонок завершён';

  @override
  String clCallWith(Object pseudo) {
    return 'Звонок с $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Сквозное шифрование';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Статус звонка: $status';
  }

  @override
  String get clEnableMic => 'Включить микрофон';

  @override
  String get clMuteMic => 'Выключить микрофон';

  @override
  String get clDisableSpeaker => 'Выключить громкую связь';

  @override
  String get clEnableSpeaker => 'Включить громкую связь';

  @override
  String get clDisableCamera => 'Выключить камеру';

  @override
  String get clEnableCamera => 'Включить камеру';

  @override
  String get clHangUp => 'Завершить звонок';

  @override
  String get clIncomingVideoCall => 'Входящий видеозвонок';

  @override
  String get clSwitchCamera => 'Сменить камеру';

  @override
  String get gcGroupCall => 'Групповой звонок';

  @override
  String get gcConnecting => 'Подключение…';

  @override
  String get gcOnline => 'В сети';

  @override
  String get gcFailed => 'Ошибка';

  @override
  String get gcDisconnected => 'Отключён';

  @override
  String get gcReturnToCall => 'Вернуться к звонку';

  @override
  String get gcMinimize => 'Свернуть';

  @override
  String get gcVoiceOnly => 'Только голос';

  @override
  String gcReactWith(String emoji) {
    return 'Отреагировать: $emoji';
  }

  @override
  String get gcSpeakingNow => 'Говорит сейчас';

  @override
  String get gcMicOff => 'Микрофон выключен';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника · только голос',
      many: '$count участников · только голос',
      few: '$count участника · только голос',
      one: '$count участник · только голос',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Сообщения';

  @override
  String get ntfChannelMessagesDesc => 'Новые сообщения и статусы меш-сети';

  @override
  String get ntfChannelCallsName => 'Звонки';

  @override
  String get ntfChannelCallsDesc => 'Входящие и пропущенные звонки';

  @override
  String get ntfChannelMeshName => 'Меш-сеть и экстренные сообщения';

  @override
  String get ntfChannelMeshDesc =>
      'Активная меш-служба, статусы и экстренные сообщения';

  @override
  String get ntfReply => 'Ответить';

  @override
  String get ntfYourReply => 'Ваш ответ';

  @override
  String get ntfMarkAsRead => 'Отметить как прочитанное';

  @override
  String get ntfIncomingCall => 'Входящий звонок';

  @override
  String get ntfAnswer => 'Ответить';

  @override
  String get ntfDecline => 'Отклонить';

  @override
  String get ntfMissedCall => 'Пропущенный звонок';

  @override
  String get ntfSendFailedTitle => 'Не удалось отправить';

  @override
  String get ntfSendFailedBody =>
      'Не удалось отправить сообщение — повтор попытки, как только рядом окажется участник сети.';

  @override
  String get ntfNewStatusTitle => 'Новый статус';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo опубликовал(а) статус';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo понравился ваш статус';
  }

  @override
  String get ntfTapToView => 'Нажмите, чтобы посмотреть';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo ответил(а) на ваш статус';
  }

  @override
  String get ntfEmergencyTitle => 'Экстренное сообщение';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo разослал(а) сообщение «Я в безопасности»';
  }

  @override
  String get mnAccept => 'Принять';

  @override
  String get mnMeshVoiceCall => 'Голосовой звонок по меш-сети';

  @override
  String get mnGroupCallIncoming => 'Входящий групповой звонок';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo приглашает вас';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Групповой звонок · ещё $count участника',
      many: 'Групповой звонок · ещё $count участников',
      few: 'Групповой звонок · ещё $count участника',
      one: 'Групповой звонок · ещё $count участник',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Кто может видеть этот статус?';

  @override
  String get asAllContacts => 'Все мои контакты';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контакта',
      many: '$count контактов',
      few: '$count контакта',
      one: '$count контакт',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'Кроме…';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count исключены',
      many: '$count исключены',
      few: '$count исключены',
      one: '$count исключён',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Исключить контакты';

  @override
  String get asOnlyOption => 'Только…';

  @override
  String get asShareWithSpecific => 'Показать только выбранным контактам';

  @override
  String get asNoContactsAvailable => 'Нет доступных контактов';

  @override
  String get asConfirm => 'Подтвердить';

  @override
  String get apYourPhoto => 'Ваше фото';

  @override
  String get apNoPhotoAccessible => 'На этом устройстве нет доступных фото.';

  @override
  String get apBrowseFiles => 'Обзор файлов';

  @override
  String get apRecentPhoto => 'Недавнее фото';

  @override
  String get bgSkip => 'Пропустить';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Шаг $rang из $total.';
  }

  @override
  String get csGuideNetworkTitle => 'Никого рядом? Это нормально';

  @override
  String get csGuideNetworkText =>
      'Droplet работает без каких-либо серверов: он общается с телефонами в радиусе действия. Здесь видно, кто доступен и по какой радиосвязи. Отсутствие участников не значит поломку — просто рядом пока никого нет.';

  @override
  String get csGuideWriteTitle => 'Пишите, даже когда рядом никого нет';

  @override
  String get csGuideWriteText =>
      'Написанное сейчас сообщение ждёт на вашем телефоне и отправится, как только рядом окажется устройство — на улице, в такси. Оно не потеряно, оно ждёт.';

  @override
  String get csGuideBackupTitle => 'Сделайте резервную копию своей личности';

  @override
  String get csGuideBackupText =>
      'Без сервера никто не сможет вернуть вам ваш аккаунт. Экспортируйте свою личность в настройках: без этой резервной копии утерянный телефон унесёт с собой всё.';

  @override
  String get csShowLockedChatsReason => 'Показать заблокированные чаты';

  @override
  String get cvlNoBiometricsConfigured =>
      'На этом устройстве не настроен отпечаток пальца';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Разблокировать переписку с $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Не удалось выполнить аутентификацию';

  @override
  String get cvlAuthError => 'Ошибка аутентификации';

  @override
  String get cvlConversationLocked => 'Заблокированная переписка';

  @override
  String get cvlUnlock => 'Разблокировать';

  @override
  String get dcAddText => 'Добавить текст';

  @override
  String get dcYourTextHint => 'Ваш текст…';

  @override
  String get pbDropletProBadge => 'Значок Droplet Pro';

  @override
  String get rpReact => 'Реакция';

  @override
  String get rpSaveToPhone => 'Сохранить на телефон';

  @override
  String get chViaTor => 'Через Tor';

  @override
  String get chTorInactive => 'Tor неактивен';

  @override
  String get chViaInternet => 'Через интернет';

  @override
  String get chReachedViaTorSemantic => 'Контакт доступен через Tor';

  @override
  String get nsTorConnectedTitle => 'Подключено через Tor';

  @override
  String get nsTorInactiveTitle => 'Tor отключён';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'Ваши сообщения передаются через сеть Tor и ждут в зашифрованном почтовом ящике, пока $pseudo не подключится к нему.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Включите Tor в настройках, чтобы писать $pseudo — без него ваши сообщения будут ждать на этом устройстве.';
  }

  @override
  String get nsTorMailboxTitle => 'Зашифрованный почтовый ящик';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Ни вы, ни Droplet не можете прочитать его содержимое — ключ есть только у $pseudo.';
  }

  @override
  String get nsOpenTorSettings => 'Включить Tor';

  @override
  String get qrInvalidCode => 'Этот QR-код не является кодом Droplet.';

  @override
  String get qrPeerAdded => 'Контакт добавлен';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Теперь вы можете переписываться с $pseudo';
  }

  @override
  String get clViaInternet => 'Через интернет';

  @override
  String get tsPathTorDetail =>
      'Это сообщение не проходит через устройства вокруг вас: оно передаётся через зашифрованный почтовый ящик в сети Tor, доступный только вам двоим.';

  @override
  String get tsNetworkTorDetail =>
      'Чтобы связаться с этим контактом на расстоянии, нужен сервер-ретранслятор — в отличие от локальной меш-сети, здесь Droplet не может обойтись без него.';

  @override
  String get torSearchDirectory => 'Поиск в каталоге';

  @override
  String get dvTitle => 'Поиск';

  @override
  String get dvClose => 'Закрыть';

  @override
  String get dvSearchHint => 'Поиск по имени…';

  @override
  String get dvEnableTorToSearch =>
      'Включите Tor в настройках, чтобы искать в каталоге.';

  @override
  String get dvSearching => 'Идёт поиск…';

  @override
  String get dvNoResults => 'Нет результатов';

  @override
  String get dvNoUserFound => 'По этому запросу пользователей не найдено.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результата',
      many: '$count результатов',
      few: '$count результата',
      one: '$count результат',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Отправить';

  @override
  String get aiNewConversation => 'Новый разговор';

  @override
  String get aiMessageHint => 'Сообщение';

  @override
  String get aiCopied => 'Скопировано';

  @override
  String get aiAskQuestion => 'Задайте вопрос';

  @override
  String get aiRunsLocally =>
      'Этот помощник работает полностью на вашем устройстве — ничего никогда не отправляется через интернет.';

  @override
  String get aiMemorySaved => 'Я это запомню.';

  @override
  String get aiMemoryForgotten => 'Я забыл то, что вы просили запомнить.';

  @override
  String get aiMemoryTitle => 'Память помощника';

  @override
  String get aiMemoryEmpty =>
      'Пока ничего не сохранено. Скажите «запомни, что…», чтобы закрепить информацию.';

  @override
  String get aiMemoryForget => 'Забыть всё';

  @override
  String get aiExpertHint =>
      'Я знаю Droplet досконально: mesh-сеть, Tor, звонки, приватность.';

  @override
  String get chAskAssistant => 'Спросить помощника';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Помоги мне ответить $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Подготовка помощника… $percentage %';
  }

  @override
  String get aiOneTimeDownload =>
      'Всего один раз — потом он остаётся на вашем устройстве без дальнейших загрузок.';

  @override
  String get aiGenericError => 'Извините, произошла ошибка.';

  @override
  String get aiNotAvailableYet =>
      'Помощник пока недоступен в этой версии Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Не удалось скачать: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Кто-то пытается с вами связаться';

  @override
  String get ntfNewMessageWake =>
      'Новое сообщение — откройте Droplet, чтобы прочитать';

  @override
  String get chNearbyAndInternet => 'Рядом · Интернет';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ретрансляторов: $count · Интернет',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'Ожидание Интернета';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Рядом: $count · Интернет',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Рядом: $count · без Интернета',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Никого рядом · Интернет';

  @override
  String get clPathMesh => 'Mesh · прямой Wi-Fi';

  @override
  String get clPathInternetDirect => 'Интернет · напрямую';

  @override
  String get clPathInternetRelay => 'Интернет · защищённый ретранслятор';

  @override
  String get clReconnecting => 'Переподключение…';

  @override
  String get clLabelSpeaker => 'Динамик';

  @override
  String get clLabelCamera => 'Камера';

  @override
  String get clLabelMic => 'Микрофон';

  @override
  String get clLabelFlip => 'Сменить';

  @override
  String get clEncryptedShort => 'Сквозное шифрование';

  @override
  String clQualitySemantics(int bars) {
    return 'Качество звонка: $bars из 3';
  }

  @override
  String get beOnlineTitle => 'Автоматическое резервное копирование онлайн';

  @override
  String get beOnlineBody =>
      'Каждый день на сервере Droplet сохраняется копия, зашифрованная этим паролем; сервер не может её прочитать. На новом телефоне достаточно того же имени и того же пароля. Полученные фото, видео и файлы не сохраняются.';

  @override
  String get beOnlineSwitch => 'Копировать на сервер каждый день';

  @override
  String beOnlineLast(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get beOnlineNever => 'Онлайн-копии пока нет';

  @override
  String get beOnlineNow => 'Сохранить сейчас';

  @override
  String get beOnlineDone => 'Онлайн-копия сохранена';

  @override
  String get beOnlineFailed => 'Онлайн-копирование сейчас невозможно';

  @override
  String get obRestoreFromServer => 'Восстановить с сервера';

  @override
  String get obEnterPseudoFirst => 'Сначала введите имя из вашей копии';

  @override
  String get obNoServerBackup => 'Нет копии для этого имени и пароля';

  @override
  String get obTooManyAttempts => 'Слишком много попыток — повторите через час';

  @override
  String get chatsInviteLink => 'Пригласить по ссылке';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo приглашает тебя в Droplet — зашифрованный мессенджер, который работает даже без сети: $lien';
  }

  @override
  String get invTitle => 'Приглашение';

  @override
  String invBody(String pseudo) {
    return '$pseudo приглашает вас пообщаться в Droplet.';
  }

  @override
  String get invAdd => 'Добавить и написать';

  @override
  String get invInvalid =>
      'Эта ссылка-приглашение недействительна или неполна.';

  @override
  String get invSelf => 'Это ваша собственная ссылка-приглашение.';
  @override
  String get seAnimationHeader => 'Анимация отправки';

  @override
  String get seAnimationFull => 'Полная';

  @override
  String get seAnimationReduced => 'Сокращённая';

  @override
  String get seAnimationOff => 'Отключена';

  @override
  String get seAnimationFullDesc => 'Плик уносит сообщение, телепортируется и машет вам рукой.';

  @override
  String get seAnimationReducedDesc => 'Только плавное появление, без движения и частиц.';

  @override
  String get seAnimationOffDesc => 'Без анимации после отправки.';

  @override
  String get seAnimationReplay => 'Коснитесь, чтобы повторить';

  @override
  String get seAnimationNone => 'Без анимации';

  @override
  String get seAnimationSampleIn => 'Встретимся в порту?';

  @override
  String get seAnimationSampleOut => 'Скоро буду';

  @override
  String get trTitle => 'Перевод';

  @override
  String get trOnDevice => 'Перевод на устройстве…';

  @override
  String get trUnknownLang => 'Неизвестный язык';

  @override
  String get trOriginal => 'Оригинал';

  @override
  String get trCopy => 'Копировать';

  @override
  String get trInChat => 'В чате';

  @override
  String get trRetry => 'Повторить';

  @override
  String get trSame => 'Это сообщение уже на этом языке.';

  @override
  String get trModel => 'Модель этого языка ещё не установлена на устройстве.';

  @override
  String get trUnavailable => 'На этом устройстве нет офлайн-перевода.';

  @override
  String get trFailed => 'Перевод не удался.';

  @override
  String get pfMessage => 'Сообщение';

  @override
  String get pfCall => 'Звонок';

  @override
  String get pfSecurity => 'Безопасность';

  @override
  String get aiActCopy => 'Копировать';

  @override
  String get aiActRead => 'Прочитать вслух';

  @override
  String get aiActStop => 'Остановить чтение';

  @override
  String get aiActLike => 'Хороший ответ';

  @override
  String get aiActDislike => 'Плохой ответ';

  @override
  String get aiActShare => 'Поделиться';

  @override
  String get aiActRegenerate => 'Сгенерировать заново';

  @override
  String get aiFeedbackThanks => 'Спасибо за отзыв';

  @override
  String get intelOnlineHeader => 'Перевод и расшифровка';

  @override
  String get intelOnlineTitle => 'Онлайн при подключении';

  @override
  String get intelOnlineSubtitle => 'Бесплатно — MyMemory, Apple или Google';

  @override
  String get intelOnlineFooter => 'Когда выключено, ничего не идёт через интернет. Когда включено и есть сеть: текст для перевода уходит в MyMemory; на iPhone голосовое, которое устройство не может расшифровать само, уходит в речевой сервис Apple. На этом пути содержимое больше не защищено сквозным шифрованием. На Android загружается только голосовая модель: голосовые остаются на телефоне. Для предпросмотра ссылок приложение также обращается к самому сайту.';

  @override
  String get trOnline => 'Перевести онлайн';

  @override
  String get trOnlineNote => 'Текст будет отправлен в MyMemory — бесплатный сервис. На этом пути он больше не защищён сквозным шифрованием.';

  @override
  String get trViaOnline => 'Переведено онлайн через MyMemory';

  @override
  String get vnModelDownloading => 'Голосовая модель этого языка загружается. Повторите попытку чуть позже.';

  @override
  String get vnModelNeeded => 'Нет голосовой модели для этого языка. Включите «Онлайн при подключении» в настройках, чтобы загрузить её один раз.';

  @override
  String get nwStatusHeader => 'Статус';

  @override
  String get nwAddStatus => 'Добавить статус';

  @override
  String get nwStatusNewA11y => 'новое';

  @override
  String svReplySent(String name) {
    return 'Ответ отправлен: $name';
  }

  @override
  String get blkYouBlocked => 'Вы заблокировали этот контакт.';

  @override
  String get blkUnblock => 'Разблокировать';

  @override
  String get blkListTitle => 'Заблокированные';

  @override
  String get blkNone => 'Нет заблокированных контактов';

  @override
  String get blkFooter => 'Заблокированный контакт больше не может писать и звонить вам и не получает ваши статусы и фото. Он об этом не узнаёт. Ваш телефон продолжает пересылать его сообщения другим людям, не имея возможности их прочитать: mesh-сеть не зависит от того, кого вы блокируете.';

  @override
  String blkUnblockTitle(String name) {
    return 'Разблокировать $name?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'Разблокировать $name, чтобы позвонить?';
  }

  @override
  String get nvDone => 'Готово';

  @override
  String get nvBack => 'Назад';

  @override
  String get nvForward => 'Вперёд';

  @override
  String get nvShare => 'Поделиться';

  @override
  String get nvOpenInBrowser => 'Открыть в браузере';

  @override
  String get nvReload => 'Обновить';

  @override
  String get nvCopyLink => 'Скопировать ссылку';

  @override
  String get nvLinkCopied => 'Ссылка скопирована';

  @override
  String get nvOpen => 'Открыть';

  @override
  String get nvMore => 'Ещё';

  @override
  String get nvNotSecure => 'Небезопасно';

  @override
  String get nvErrorTitle => 'Страница недоступна';

  @override
  String get nvErrorBody => 'Droplet не смог открыть этот сайт. Mesh-сеть не передаёт веб-страницы: нужно подключение к интернету.';

  @override
  String get nvRetry => 'Повторить';

  @override
  String get ciLinks => 'Ссылки';

  @override
  String get chatsFilterNearby => 'Рядом';


  @override
  String get chProxTitle => 'Droplet работает и без интернета';

  @override
  String get chProxActive => 'Рядом есть устройства с Droplet';

  @override
  String get chProxBody => 'Телефоны поблизости передают сообщения друг другу. Чем больше вас рядом, тем дальше они доходят.';

  @override
  String get chProxSee => 'Кто рядом';

  @override
  String get chStickerPreview => 'Стикер';

  @override
  String get edCrop => 'Обрезать';

  @override
  String get edRotate => 'Повернуть';

  @override
  String get edFilters => 'Фильтры';

  @override
  String get edAdjust => 'Настроить';

  @override
  String get edText => 'Текст';

  @override
  String get edDraw => 'Рисунок';

  @override
  String get edTrim => 'Обрезать';

  @override
  String get edBrightness => 'Яркость';

  @override
  String get edContrast => 'Контраст';

  @override
  String get edSaturation => 'Насыщенность';

  @override
  String get edWarmth => 'Теплота';

  @override
  String get edVignette => 'Виньетка';

  @override
  String get edIntensity => 'Интенсивность';

  @override
  String get edUndo => 'Отменить';

  @override
  String get edDone => 'Готово';

  @override
  String get edTextHint => 'Напишите…';

  @override
  String get edDelete => 'Удалить';

  @override
  String get edOriginal => 'Оригинал';

  @override
  String get edStyle => 'Стиль';

  @override
  String get edBackground => 'Фон';

  @override
  String get stNotificationsHeader => 'Уведомления';

  @override
  String get stNotifPreview => 'Показывать текст';

  @override
  String get stNotifPreviewSubtitle => 'Текст сообщения показывается в уведомлении. Если выключить, на экране блокировки будет только «новое сообщение».';

  @override
  String get stSearchHint => 'Поиск в настройках';

  @override
  String get stSearchEmpty => 'Ничего не найдено';

  @override
  String get chMentionAllSubtitle => 'Уведомить всех';

  @override
  String get vuOnce => 'Одноразовый просмотр';

  @override
  String get vuOpened => 'Просмотрено';

  @override
  String get vuPhoto => 'Фото';

  @override
  String get vuVideo => 'Видео';

  @override
  String get vuMissing => 'Этот файл ещё не получен';

  @override
  String get pollClosed => 'Опрос завершён';

  @override
  String pollEndsAt(String quand) {
    return 'Завершится в $quand';
  }

  @override
  String get vuVoice => 'Голосовое сообщение';

  @override
  String get apPatternsHeader => 'Узор фона';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Игры';

  @override
  String get apPatternHome => 'Дом';

  @override
  String get apPatternGarden => 'Сад';

  @override
  String get imTitle => 'Избранные сообщения';

  @override
  String get imSubtitle => 'То, что вы отложили';

  @override
  String get imAdd => 'В избранное';

  @override
  String get imRemove => 'Убрать из избранного';

  @override
  String get imAdded => 'Добавлено в избранное';

  @override
  String get imRemoved => 'Удалено из избранного';

  @override
  String get imEmptyBody => 'Нажмите и удерживайте сообщение, чтобы добавить его в избранное и найти здесь позже.';

  @override
  String get imClearAll => 'Очистить всё';

  @override
  String get imClearAllBody => 'Сообщения останутся в чатах — исчезнут только звёздочки.';

  @override
  String get imClear => 'Очистить';

  @override
  String get imYou => 'Вы';

  @override
  String get imUnknown => 'Сообщение';

  @override
  String get apPatternsFooter => 'Узор появится во всех ваших чатах.';

  @override
  String get grCreatedNoMessages => 'Группа создана · нет сообщений';

  @override
  String get chatsDelete => 'Удалить чат';

  @override
  String get chatsDeleteBody => 'Сообщения исчезнут с этого телефона. Без сервера никто не может удалить их у других.';

  @override
  String get chatsDeleteConfirm => 'Удалить';

  @override
  String get chatsDeleted => 'Чат удалён';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Удалить чат с $nom?';
  }

  @override
  String get chatsDocument => 'Документ';

  @override
  String get epTitle => 'Исчезающие сообщения';

  @override
  String get epHeadline => 'Включите исчезающие сообщения в этом чате';

  @override
  String get epBody => 'Новые сообщения несут свой срок: по его истечении они исчезают с обоих телефонов.';

  @override
  String get epDelayHeader => 'Время до исчезновения';

  @override
  String get epHours24 => '24 часа';

  @override
  String get epDays7 => '7 дней';

  @override
  String get epDays90 => '90 дней';

  @override
  String get epOff => 'Выкл.';

  @override
  String get epFooter => 'Настройка не влияет на уже отправленные сообщения: у каждого остаётся свой срок.';

  @override
  String get chOnlineNow => 'В сети · интернет';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Через интернет $count мин назад';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Через интернет $count ч назад';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Через интернет $count дн назад';
  }

  @override
  String get pdfMissing => 'Этого документа нет на этом телефоне.';

  @override
  String get pdfUnreadable => 'Этот PDF не читается — возможно, он пришёл не полностью.';

  @override
  String get giDescription => 'Описание';

  @override
  String get giDescriptionAdd => 'Добавить описание';

  @override
  String get giDescriptionNone => 'Нет описания';

  @override
  String get giDescriptionHint => 'О чём эта группа?';

  @override
  String get giOnlyAdminsSend => 'Пишут только администраторы';

  @override
  String get giOnlyAdminsSendBody => 'Остальные участники только читают.';

  @override
  String get giSearchMembers => 'Найти участника';

  @override
  String get chOnlyAdminsCanWrite => 'В этой группе могут писать только администраторы';

  @override
  String grCreatedBy(String nom) {
    return '$nom создал группу';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom добавил вас';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom больше не в группе';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui добавил $nom';
  }

  @override
  String get giQrInvite => 'QR-код';

  @override
  String get giQrRenew => 'Новый код';

  @override
  String get giQrRenewed => 'Создан новый код, старый больше не действует';

  @override
  String get giQrExpired => 'Срок действия кода истёк';

  @override
  String get giQrExplainer => 'В коде нет ключей. Он лишь позволяет попросить о вступлении — решает ваш телефон.';

  @override
  String get giQrAlreadyMember => 'Вы уже в этой группе';

  @override
  String get giQrNeedContact => 'Сначала добавьте того, кто вас приглашает';

  @override
  String get giQrRequestFailed => 'Запрос не удалось отправить';

  @override
  String giQrRequestSent(String nom) {
    return 'Запрос отправлен в $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Действителен ещё $count ч';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Действителен ещё $count мин';
  }

  @override
  String get cvNearby => 'Рядом';

  @override
  String get cvInternet => 'Интернет';

  @override
  String get cvWaiting => 'Ожидание';

  @override
  String get cvOutOfReach => 'Вне зоны';

  @override
  String get chWillSendWhenNearby => 'Отправится, как только он окажется рядом';

  @override
  String cvHops(int count) {
    return '$count прыжка';
  }

  @override
  String get nwSeenSection => 'Просмотрено';

  @override
  String get nwReceivedHeader => 'Полученные';

  @override
  String get avTranslateTitle => 'Перевод';

  @override
  String get avTranslateShort => 'Понять, не выходя из приложения';

  @override
  String get avTranslateLong => 'Сообщение переводится на вашем телефоне: его содержимое не уходит никому, даже переводчику. Оригинал остаётся в одно касание — перевод никогда не бывает в точности текстом.';

  @override
  String get apStickerQ => 'У тебя есть стикер для этого?';

  @override
  String get apOnline => 'в сети';

  @override
  String get apMessage => 'Сообщение';

  @override
  String get apAutoTranslated => 'Переведено автоматически';

  @override
  String get apBgSend => 'Смотри, какой фон 😍';

  @override
  String get apBgA => 'Ты что-то поменял?';

  @override
  String get apBgB => 'Он двигается с каждым сообщением 😮';

  @override
  String get apFormatQ => 'Где встречаемся?';

  @override
  String get apFormatDemo => 'Встречаемся **в 18:00** у __большого рынка__, код `4821`. Сюрприз: ||торт||';

  @override
  String get apVoiceQ => 'Ты где?';

  @override
  String get apVoiceText => 'Я у аптеки, буду ждать тебя до 18:00.';

  @override
  String get apTransQ => 'Привет, всё готово?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'Да! Увидимся завтра в аэропорту, выход 12 в 9 утра.';

  @override
  String get hlpDataOnDevice => 'НА ВАШЕМ ТЕЛЕФОНЕ';

  @override
  String get hlpDataServers => 'ЧТО ПРОХОДИТ ЧЕРЕЗ СЕРВЕР';

  @override
  String get hlpDataServersFooter => 'Без интернета ни один из этих серверов не участвует: телефоны говорят напрямую.';

  @override
  String get hlpDataNone => 'ЧЕГО DROPLET НИКОГДА НЕ ПРОСИТ';

  @override
  String get hlpRowKeys => 'Ваша личность';

  @override
  String get hlpRowKeysBody => 'Пара ключей, созданная здесь и никуда не отправленная';

  @override
  String get hlpRowMessages => 'Ваши сообщения';

  @override
  String get hlpRowMessagesBody => 'В личном хранилище приложения, стираются при удалении';

  @override
  String get hlpRowProfile => 'Имя и фото';

  @override
  String get hlpRowProfileBody => 'Уходят только тем, кому вы пишете';

  @override
  String get hlpRowSettings => 'Ваши настройки';

  @override
  String get hlpRowSettingsBody => 'Фон, язык, уведомления — всё остаётся здесь';

  @override
  String get hlpRowLog => 'Журнал ошибок';

  @override
  String get hlpRowLogBody => 'Локальный файл, который никогда не уходит сам';

  @override
  String get hlpRowDirectory => 'Справочник';

  @override
  String get hlpRowDirectoryBody => 'Видит имя и публичный идентификатор. Запросы через Tor: не ваш настоящий IP';

  @override
  String get hlpRowMailbox => 'Почтовый ящик';

  @override
  String get hlpRowMailboxBody => 'Хранит зашифрованное сообщение до вручения. Прочитать не может';

  @override
  String get hlpRowSignalling => 'Установка связи';

  @override
  String get hlpRowSignallingBody => 'Видит два идентификатора, пока соединяет. Голос через него не идёт';

  @override
  String get hlpRowRelay => 'Ретранслятор';

  @override
  String get hlpRowRelayBody => 'Передаёт зашифрованный звук, когда прямая связь не выходит';

  @override
  String get hlpNonePhone => 'Номер телефона';

  @override
  String get hlpNoneEmail => 'Адрес эл. почты';

  @override
  String get hlpNoneContacts => 'Ваша адресная книга';

  @override
  String get hlpNoneLocation => 'Ваше местоположение';

  @override
  String get hlpNoneAds => 'Реклама и трекеры';

  @override
  String get hlpNoneAnalytics => 'Аналитика';

  @override
  String get hlpQOffline => 'Как Droplet работает без интернета?';

  @override
  String get hlpAOffline => 'Телефоны говорят напрямую — по Bluetooth и Wi-Fi. Сообщение может и перепрыгивать с телефона на телефон до адресата, ни разу не проходя через сервер.';

  @override
  String get hlpQCrypto => 'Мои сообщения правда зашифрованы?';

  @override
  String get hlpACrypto => 'Да, сквозным шифрованием по протоколу Signal. Ключ есть только на двух телефонах. Ни ретранслятор, ни почтовый ящик, ни мы не можем открыть сообщение.';

  @override
  String get hlpQNoAccount => 'Почему Droplet не просит ни номер, ни почту?';

  @override
  String get hlpANoAccount => 'Потому что они не нужны. Ваша личность — это ключ, созданный на вашем телефоне. Нечего создавать, нечего подтверждать и нечего украсть на стороне.';

  @override
  String get hlpQPending => 'Почему сообщение висит в ожидании?';

  @override
  String get hlpAPending => 'Рядом ещё никого нет, и интернета нет. Сообщение ждёт в телефоне и уйдёт, как только появится путь — переделывать ничего не нужно.';

  @override
  String get hlpQAddSomeone => 'Как добавить человека?';

  @override
  String get hlpAAddSomeone => 'Поднесите телефоны друг к другу: человек появится сам. На расстоянии — поделитесь ссылкой-приглашением или отсканируйте его QR-код.';

  @override
  String get hlpQUninstall => 'Что будет, если удалить приложение?';

  @override
  String get hlpAUninstall => 'Стирается всё: сообщения, контакты, личность. Копии нигде нет, значит и восстановления нет. Перед сменой телефона выгрузите настройки.';

  @override
  String get hlpQBattery => 'Droplet садит батарею?';

  @override
  String get hlpABattery => 'Поиск устройств вокруг расходует заряд. В настройках его можно уменьшить или включать только при открытом приложении.';

  @override
  String get hlpQReport => 'Как сообщить о проблеме?';

  @override
  String get hlpAReport => 'Через «Связь и поддержка». Вы увидите точный текст, который будет отправлен, прежде чем он уйдёт — ничего не покидает телефон без вас.';

  @override
  String get svLikeStatus => 'Оценить статус';

  @override
  String get svUnlikeStatus => 'Убрать отметку';

  @override
  String get stAddPhotoSemantics => 'Добавить фото профиля';

  @override
  String get stChangePhotoSemantics => 'Изменить фото профиля';

  @override
  String get scOverheat => 'Телефон перегрелся — Android отключил видеокодировщик. Дайте ему остыть несколько минут.';

  @override
  String scTooHeavy(int mo) {
    return 'Файл слишком тяжёлый — не больше $mo МБ, чтобы пройти по локальной сети.';
  }

  @override
  String get scUnsupported => 'Этот формат не поддерживается для статуса.';

  @override
  String get scUnreadableFile => 'Не удаётся прочитать этот файл';

  @override
  String get scUnreadableTrack => 'Не удаётся прочитать эту запись';

  @override
  String get scNothingCaptured => 'Запись ничего не захватила — попробуйте ещё раз.';

  @override
  String get scVideoTrimmed => 'Видео сокращено до 1:30 — публикуется только начало.';

  @override
  String get scUnreadableVideo => 'Видео не читается';

  @override
  String get chAiMe => 'Я';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Вот конец разговора в Droplet между пользователем («Я») и $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'Пользователю нужна помощь с ответом для $pseudo. Предложи короткий естественный ответ на языке $langue, от первого лица, как будто он отправляет его сам. Дай только сам ответ, без предисловий.';
  }

  @override
  String get hlpSectionHeader => 'Помощь и конфиденциальность';

  @override
  String get hlpPrivacy => 'Политика конфиденциальности';

  @override
  String get hlpData => 'Ваши данные';

  @override
  String get hlpDataValue => 'Ничего не уходит';

  @override
  String get hlpContact => 'Связь и поддержка';

  @override
  String get hlpPrivacyTitle => 'Конфиденциальность';

  @override
  String hlpUpdated(String date) {
    return 'Обновлено $date';
  }

  @override
  String get hlpOnlyFrEn => 'Этот текст существует только на французском и английском. Приблизительный перевод юридического документа обязывал бы больше, чем помогал.';

  @override
  String get hlpReadInEnglish => 'Читать по-английски';

  @override
  String get hlpReadInFrench => 'Читать по-французски';

  @override
  String get hlpDataTitle => 'Ваши данные';

  @override
  String get hlpDataLead => 'Что Droplet знает о вас, строка за строкой. Здесь нет обещаний: каждой строке соответствует код.';

  @override
  String get hlpStays => 'Никогда не покидает устройство';

  @override
  String get hlpLeaves => 'Проходит через сервер';

  @override
  String get hlpNever => 'Не существует';

  @override
  String get hlpCountTracking => 'данных для слежки';

  @override
  String get hlpCountAccount => 'аккаунтов создавать';

  @override
  String get hlpCountServers => 'сервера, и мы их называем';

  @override
  String get hlpHelpTitle => 'Помощь';

  @override
  String get hlpSearchHint => 'Поиск';

  @override
  String get hlpNoResult => 'Ни в одном ответе нет этого слова. Напишите нам — возможно, этого вопроса здесь не хватает.';

  @override
  String get hlpStillStuckFooter => 'Если ответа здесь нет, отвечает человек.';

  @override
  String get hlpContactTitle => 'Связь';

  @override
  String get hlpContactLead => 'Вопрос, проблема, идея. Мы читаем всё.';

  @override
  String get hlpBeforeWriting => 'Перед тем как писать';

  @override
  String get hlpHelpRowBody => 'Восемь ответов, читаются без интернета';

  @override
  String get hlpWriteUs => 'Написать нам';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'Эл. почта';

  @override
  String get hlpWhatsAppHello => 'Здравствуйте, я пользуюсь Droplet, и у меня вопрос:';

  @override
  String get hlpEmailSubject => 'Droplet — вопрос';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp не установлен. Номер $numero скопирован.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'Адрес $adresse скопирован.';
  }

  @override
  String get hlpReportHeader => 'Проблема';

  @override
  String get hlpReport => 'Сообщить о проблеме';

  @override
  String get hlpReportBody => 'Вы увидите, что уйдёт, прежде чем оно уйдёт';

  @override
  String get hlpReportFooter => 'Droplet никогда не отправляет отчёты сам: для этого нет сервера. Проблема дойдёт до нас, только если вы её отправите.';

  @override
  String get hlpReportSubject => 'Droplet — сообщение о проблеме';

  @override
  String get hlpReportSheetLead => 'Опишите, что произошло. Точный текст, который будет отправлен, показан ниже.';

  @override
  String get hlpReportHint => 'Что я делал и что случилось…';

  @override
  String get hlpAttachLog => 'Приложить журнал ошибок';

  @override
  String get hlpWhatWillBeSent => 'ЧТО БУДЕТ ОТПРАВЛЕНО';

  @override
  String get hlpLogExcerpt => 'Журнал (конец):';

  @override
  String get hlpCopy => 'Копировать';

  @override
  String get hlpCopied => 'Скопировано';

  @override
  String get hlpOnePerson => 'Droplet делает один человек, а не служба поддержки. Ответ может занять день-другой — он придёт.';

  @override
  String get avSectionHeader => 'Что даёт Pro';

  @override
  String get avUnlock => 'Открыть Droplet Pro';

  @override
  String get avVoiceTitle => 'Голос в текст';

  @override
  String get avVoiceShort => 'Читайте голосовые, не слушая';

  @override
  String get avVoiceLong => 'Расшифровка идёт прямо на телефоне, без сети. Голосовое никуда не уходит, а вы читаете его на встрече, в автобусе или вовсе без связи.';

  @override
  String get avFormatTitle => 'Оформление текста';

  @override
  String get avFormatShort => 'Жирный, курсив, код, спойлер';

  @override
  String get avFormatLong => 'Слово жирным, строка кода, скрытый фрагмент, который открывается касанием: сообщение говорит ровно то, что вы имели в виду.';

  @override
  String get avWallpaperTitle => 'Фоны и узоры';

  @override
  String get avWallpaperShort => 'Вся галерея и все четыре набора';

  @override
  String get avWallpaperLong => 'Каждый фон нарисован вручную, каждый узор проверен до попадания в приложение. Droplet, Игры, Дом, Сад — ваш экран не похож ни на чей.';

  @override
  String get avStickersTitle => 'Анимированные стикеры';

  @override
  String get avStickersShort => 'Капля Droplet в движении';

  @override
  String get avStickersLong => 'Стикеры, нарисованные для Droplet, анимированные покадрово и такие лёгкие, что летят по меш-сети вовсе без интернета.';

  @override
  String get avIconTitle => 'Иконки приложения';

  @override
  String get avIconShort => 'Смените иконку на домашнем экране';

  @override
  String get avIconLong => 'Незаметный мессенджер начинается с иконки. Выберите ту, что похожа на вас, — или ту, которую не замечают.';

  @override
  String get avBadgeTitle => 'Значок Pro';

  @override
  String get avBadgeShort => 'Он стоит рядом с вашим именем';

  @override
  String get avBadgeLong => 'Он не даёт власти над другими. Он лишь говорит, что вы заплатили, чтобы Droplet остался без рекламы, без обязательной подписки и без продажи данных.';

  @override
  String get sgTitle => 'Хранилище группы';

  @override
  String get sgEmpty => 'В этой группе ещё не было файлов.';

  @override
  String get sgByAuthor => 'Кто отправляет больше всех';

  @override
  String get sgFiles => 'Файлы';

  @override
  String get sgSortRecent => 'Сначала новые';

  @override
  String get sgSortHeavy => 'Сначала большие';

  @override
  String get sgNotOnDevice => 'Нет на устройстве';

  @override
  String get giPhotoChanged => 'Фото группы изменено';

  @override
  String get giPhotoFailed => 'Не удалось сохранить изображение';

  @override
  String sgTotal(int count) {
    return '$count файлов';
  }

  @override
  String get vrTitle => 'Голосовая комната';

  @override
  String get vrJoin => 'Войти';

  @override
  String get vrBack => 'Вернуться';

  @override
  String get vrStart => 'Открыть голосовую комнату';

  @override
  String get vrNeedsInternet => 'Голосовой комнате нужен интернет: сеть донесёт сообщение, но не двадцать голосов сразу.';

  @override
  String get vrUnreachable => 'Сервер звонков сейчас недоступен.';

  @override
  String vrFull(int count) {
    return 'Комната заполнена: максимум $count человек.';
  }

  @override
  String get vrWaiting => 'Ожидание остальных…';

  @override
  String get vrWaitingBody => 'Комната открыта. Участники группы видят её в чате и заходят, когда освободятся.';

  @override
  String vrPeople(int count) {
    return '$count участников';
  }

  @override
  String get cvTitle => 'Беседы';

  @override
  String get cvNew => 'Новая беседа';

  @override
  String get cvPinned => 'Закреплённые';

  @override
  String get cvRecent => 'Недавние';

  @override
  String get cvPin => 'Закрепить';

  @override
  String get cvUnpin => 'Открепить';

  @override
  String get cvRename => 'Переименовать';

  @override
  String get cvRenameHint => 'Название беседы';

  @override
  String get cvUntitled => 'Без названия';

  @override
  String get cvYesterday => 'Вчера';

  @override
  String get cvSearchHint => 'Поиск по беседам';

  @override
  String get cvEmpty => 'Пока нет бесед. Задайте ассистенту первый вопрос.';

  @override
  String get cvDeleteTitle => 'Удалить эту беседу?';

  @override
  String get cvDeleteBody => 'Её нельзя будет восстановить — она есть только на этом устройстве.';

  @override
  String get jaWorking => 'Работаю…';

  @override
  String cvNoResult(String terme) {
    return 'Ничего не найдено по запросу «$terme».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Ничего не найдено',
      one: '1 результат',
      other: 'Результатов: $count',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Нет шагов',
      one: '1 шаг',
      other: 'Шагов: $count',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Куда уходит ваше сообщение';

  @override
  String get moLocal => 'На устройстве';

  @override
  String get moLocalBody => 'Модель работает на этом телефоне. Ничего не уходит, даже без сети. Ответы короче и менее надёжны.';

  @override
  String get moOnline => 'Онлайн';

  @override
  String get moOnlineBody => 'Ваше сообщение уходит в Groq, где работает гораздо более крупная модель. Нужна сеть, и сообщение покидает телефон.';

  @override
  String get moOnlineNoKey => 'Для удалённой модели нужен ключ. Нажмите, чтобы добавить его — это бесплатно и займёт минуту.';

  @override
  String get moRetryOnline => 'Повторить онлайн';

  @override
  String get moRetryOnlineWhy => 'Модель на устройстве достигла предела в этом вопросе.';

  @override
  String get cpHint => 'Спросите что-нибудь…';

  @override
  String get cpAdd => 'Добавить';

  @override
  String get cpPhoto => 'Фото';

  @override
  String get cpCamera => 'Камера';

  @override
  String get cpFile => 'Файл';

  @override
  String get cpFileHint => 'PDF, текст, код';

  @override
  String get cpDictate => 'Диктовать';

  @override
  String get cpSend => 'Отправить';

  @override
  String get cpStop => 'Остановить';

  @override
  String get cpThinking => 'Думаю…';

  @override
  String get amCopy => 'Копировать';

  @override
  String get amCopyMarkdown => 'Копировать как Markdown';

  @override
  String get amCopyMarkdownHint => 'С разметкой — для документа';

  @override
  String get amShare => 'Поделиться';

  @override
  String get amEdit => 'Изменить мой вопрос';

  @override
  String get amEditHint => 'Всё, что после, будет удалено';

  @override
  String get amEditTitle => 'Изменить этот вопрос?';

  @override
  String get amEditConfirm => 'Изменить';

  @override
  String get amRegenerate => 'Сгенерировать заново';

  @override
  String get amReadAloud => 'Прочитать вслух';

  @override
  String get amAsContext => 'Использовать как контекст';

  @override
  String get amAsContextHint => 'Продолжит с этого сообщения';

  @override
  String get amChapter => 'Отметить как главу';

  @override
  String get amChapterHint => 'Чтобы найти его в длинной беседе';

  @override
  String get amUnchapter => 'Снять отметку';

  @override
  String get amChapters => 'Главы';

  @override
  String get amChaptersEmpty => 'Глав пока нет. Нажмите и удерживайте сообщение, выберите «Отметить как главу» — и оно появится здесь.';

  @override
  String amEditBody(int count) {
    return 'Будет удалено сообщений: $count — они отвечали на прежний вопрос.';
  }

  @override
  String get trAssistant => 'Ассистент';

  @override
  String get trArtifacts => 'Артефакты';

  @override
  String get trMemory => 'Память';

  @override
  String get trHelp => 'Помощь';

  @override
  String get arVersions => 'Версии';

  @override
  String get arLatest => 'Последняя';

  @override
  String get arSource => 'Исходник';

  @override
  String get arPreview => 'Просмотр';

  @override
  String get arGone => 'Этого артефакта больше нет.';

  @override
  String get arKindPage => 'Страница';

  @override
  String get arKindCode => 'Код';

  @override
  String get arKindDiagram => 'Схема';

  @override
  String get arKindData => 'Данные';

  @override
  String get arKindDoc => 'Документ';

  @override
  String arVersion(int n) {
    return 'Версия $n';
  }

  @override
  String get aiSources => 'Источники';

  @override
  String get aiToolReading => 'Читаю вложение…';

  @override
  String get aiToolWriting => 'Создаю файл…';

  @override
  String get aiToolRemembering => 'Запоминаю…';

  @override
  String get arEmpty => 'Артефактов пока нет. Ассистент создаёт их, как только выдаёт страницу, таблицу или код, который мешал бы читать беседу.';

  @override
  String get raTitle => 'Онлайн-ассистент';

  @override
  String get raIntro => 'Ассистент на устройстве работает без настройки. Для онлайн-режима нужен ключ: он оплачивает ответы и остаётся на этом телефоне.';

  @override
  String get raKey => 'Ключ';

  @override
  String get raKeySaved => 'Ключ сохранён';

  @override
  String get raKeyFooter => 'Он хранится в системной связке ключей и никогда не показывается целиком.';

  @override
  String get raKeyRemove => 'Удалить ключ';

  @override
  String get raWhere => 'Ключ создаётся на console.groq.com в разделе «API Keys». Он начинается с gsk_.';

  @override
  String get raPaste => 'Вставить';

  @override
  String get raSaveAndTest => 'Сохранить и проверить';

  @override
  String get raTest => 'Проверить ключ';

  @override
  String get raTesting => 'Проверяю…';

  @override
  String get raNotTested => 'Ещё не проверен';

  @override
  String get raNotTestedBody => 'Достаточно запроса на восемь слов. Лучше здесь, чем посреди вопроса.';

  @override
  String get raWorks => 'Ключ работает';

  @override
  String get raWorksBody => 'Онлайн-режим доступен в беседе — на кнопке рядом с полем ввода.';

  @override
  String get raRefused => 'Ключ отклонён';

  @override
  String get raRefusedBody => 'Сервер его не принимает. Часто при вставке теряется символ, или ключ уже отозван.';

  @override
  String get raNoNetwork => 'Сервер недоступен';

  @override
  String get raNoNetworkBody => 'Ключ ни при чём: запрос не дошёл. Проверьте соединение и повторите.';

  @override
  String get raModelGone => 'Модель недоступна';

  @override
  String get raModelGoneBody => 'Ключ принят, но ответа не пришло. Скорее всего, модель убрали из каталога.';

  @override
  String get raQuota => 'Слишком много запросов';

  @override
  String get raQuotaBody => 'Ключ рабочий, но аккаунт исчерпал лимит. Повторите позже или проверьте баланс.';

  @override
  String get raWhatGoesOut => 'Что уходит';

  @override
  String get raModel => 'Модель';

  @override
  String get raWhatGoesOutFooter => 'В онлайн-режиме в Groq уходят ваше сообщение и предыдущие реплики этой беседы. Больше ничего: ни контакты, ни другие беседы, ни местоположение.';

  @override
  String get aiDownloadTitle => 'Скачать модель на устройство?';

  @override
  String get aiDownloadConfirm => 'Скачать';

  @override
  String get aiDownloading => 'Загрузка модели';

  @override
  String aiDownloadBody(int mo) {
    return '$mo МБ, один раз. После этого ассистент отвечает без сети, и ничего не покидает телефон. Во время загрузки им можно пользоваться онлайн.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo МБ, один раз. После этого ассистент отвечает без сети, и ничего не покидает телефон.';
  }

  @override
  String get aiGreetingPlain => 'Здравствуйте';

  @override
  String get aiGreetingHint => 'Задайте вопрос, приложите фото или попросите документ.';

  @override
  String get aiChipExplain => 'Объясни…';

  @override
  String get aiChipWrite => 'Напиши сообщение';

  @override
  String get aiChipSummarize => 'Сделай выжимку';

  @override
  String get aiChipTranslate => 'Переведи на…';

  @override
  String aiGreeting(String nom) {
    return 'Здравствуйте, $nom';
  }

  @override
  String get cpNoPhoto => 'Без фото: онлайн-модель не умеет читать изображения. Зато читает PDF, даже большие.';

  @override
  String get mvOpen => 'Голосовой режим';

  @override
  String get mvTapToTalk => 'Нажмите, чтобы говорить';

  @override
  String get mvHoldToTalk => 'Удерживайте, чтобы говорить';

  @override
  String get mvListening => 'Слушаю…';

  @override
  String get mvTranscribing => 'Распознавание…';

  @override
  String get mvSpeaking => 'Отвечаю вслух';

  @override
  String get mvProblem => 'Возникла проблема';

  @override
  String get mvHandsFree => 'Без рук';

  @override
  String get mvHold => 'Удержание';

  @override
  String get mvTalk => 'Говорить';

  @override
  String get mvInterrupt => 'Прервать';

  @override
  String get mvNoMic => 'У Droplet нет доступа к микрофону. Разрешите его в настройках телефона.';

  @override
  String get mvFailed => 'Не получилось. Нажмите, чтобы повторить.';

  @override
  String get mvLive => 'В эфире';

  @override
  String get mvCaptions => 'Субтитры';

  @override
  String get mvExit => 'Выйти из голосового режима';

  @override
  String get mvMute => 'Выключить микрофон';

  @override
  String get mvUnmute => 'Включить микрофон';

  @override
  String get mvMuted => 'Микрофон выключен';

  @override
  String get mvTapToInterrupt => 'Нажмите, чтобы прервать';

  @override
  String scCompressing(int percent) {
    return 'Сжатие… $percent %';
  }

  @override
  String get scStillHeavy => 'Это видео всё ещё больше 2 МБ: передача будет медленнее.';

  @override
  String get baConnecting => 'Соединение…';

  @override
  String get baMute => 'Выключить микрофон';

  @override
  String get baUnmute => 'Включить микрофон';

  @override
  String get baHangUp => 'Завершить вызов';

  @override
  String baOngoing(String name) {
    return 'Идёт вызов с $name. Нажмите, чтобы вернуться.';
  }

  @override
  String get ntfOngoingCall => 'Идёт вызов';

  @override
  String get ntfViaMesh => 'Через меш-сеть';

  @override
  String get ntfViaInternet => 'Через интернет';

  @override
  String get shSend => 'Отправить';

  @override
  String get shRecents => 'Недавние';

  @override
  String get shPickRecipients => 'Выберите одного или нескольких получателей';

  @override
  String shSendCount(int count) {
    return 'Отправить $count';
  }

  @override
  String shSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get apcNothingYet => 'Пока ничего';

  @override
  String get apcOnline => 'В сети';

  @override
  String get apcOffline => 'Не в сети';

  @override
  String get apcPhoto => 'Фото';

  @override
  String get apcVoice => 'Голосовое сообщение';

  @override
  String get apcAttachment => 'Вложение';

  @override
  String get chKeyboardTooltip => 'Клавиатура';

  @override
  String get asGallery => 'Галерея';

  @override
  String get asFile => 'Файл';

  @override
  String get asLocation => 'Геопозиция';

  @override
  String get asSticker => 'Стикер';

  @override
  String get asPoll => 'Опрос';

  @override
  String get asNoGalleryAccess => 'У Droplet нет доступа к вашим фото. Разрешите его в настройках телефона или выберите другой источник ниже.';

  @override
  String asSendCount(int count) {
    return 'Отправить: $count';
  }

  @override
  String get asEmptyGallery => 'На этом телефоне нет фото и видео.';

  @override
  String get expAucunPairTitre => 'Рядом никого?';

  @override
  String get expAucunPairTexte => 'Это не сбой. Droplet ищет постоянно; как только рядом окажется устройство, связь установится сама.';

  @override
  String get expRelaisTitre => 'Через другого';

  @override
  String get expRelaisTexte => 'Этот значок говорит, что сообщение прошло через одно или несколько устройств. В этом сила ячеистой сети.';

  @override
  String get expApercuTitre => 'Быстрый взгляд';

  @override
  String get expApercuTexte => 'Удерживайте палец на беседе, чтобы прочитать последние сообщения, не открывая её и не отмечая прочитанной.';

  @override
  String get expOfficielTitre => 'Аккаунт Droplet';

  @override
  String get expOfficielTexte => 'Новости приложения приходят сюда. Каждое объявление подписано: подделать его невозможно.';

  @override
  String get expMicroTitre => 'Говорить удерживая';

  @override
  String get expMicroTexte => 'Удерживайте, чтобы записать. Сдвиньте влево — отмена, вверх — запись без удержания.';

  @override
  String get expCameraTitre => 'Микрофон или камера';

  @override
  String get expCameraTexte => 'Короткое нажатие на эту кнопку переключает между голосовым и круглым видеосообщением.';

  @override
  String get expVueUniqueTitre => 'Только один раз';

  @override
  String get expVueUniqueTexte => 'Включите «1» — следующее отправленное можно будет открыть лишь раз, затем оно исчезнет.';

  @override
  String get expPiecesTitre => 'Несколько сразу';

  @override
  String get expPiecesTexte => 'Скрепка открывает галерею прямо в приложении. Отметьте несколько фото: цифра показывает порядок отправки.';

  @override
  String get expStickersTitre => 'Стикеры и клавиатура';

  @override
  String get expStickersTexte => 'Этот значок заменяет клавиатуру стикерами и одним касанием возвращает клавиатуру.';

  @override
  String get expEphemeresTitre => 'Исчезающие сообщения';

  @override
  String get expEphemeresTexte => 'Задайте срок — новые сообщения этой беседы сотрутся на обоих телефонах.';

  @override
  String get expVerrouTitre => 'Заблокированная беседа';

  @override
  String get expVerrouTexte => 'Заблокированная беседа больше не показывает последнее сообщение в списке и требует разблокировки.';

  @override
  String get expCodeTitre => 'Проверить контакт';

  @override
  String get expCodeTexte => 'Сравните этот код рядом с собеседником: если он совпадает, между вами никто не вклинился.';

  @override
  String get expStatutTitre => 'Статусы на 24 часа';

  @override
  String get expStatutTexte => 'Статус живёт сутки, затем исчезает. Он идёт от телефона к телефону — даже без интернета.';

  @override
  String get expGardeTitre => 'Ничего не теряется';

  @override
  String get expGardeTexte => 'Сообщение отсутствующему хранится неделю и уходит само, как только появится путь.';

  @override
  String get expVoieTitre => 'Каким путём';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi Direct или интернет: Droplet берёт доступное и меняет путь, ничего не спрашивая.';

  @override
  String get cnAnnouncement => 'Новое в Droplet';

  @override
  String get cnClearAll => 'Очистить всё';

  @override
  String get cnClearAllTitle => 'Очистить все уведомления?';

  @override
  String get cnClearAllBody => 'Центр будет очищен. Чаты и сообщения останутся на месте.';

  @override
  String get cnDelete => 'Удалить';

  @override
  String get cnEmptyTitle => 'Ничего нового';

  @override
  String get cnEmptyBody => 'Здесь появятся упоминания, реакции на ваши сообщения, пропущенные звонки и новости Droplet.';

  @override
  String get cnMentioned => 'упомянул(а) вас';

  @override
  String get cnShowLess => 'Свернуть';

  @override
  String get cnStatusLike => 'понравился ваш статус';

  @override
  String get cnStatusReply => 'ответил(а) на ваш статус';

  @override
  String get cnTitle => 'Центр уведомлений';

  @override
  String get ncDeliveryHeader => 'Доставка';

  @override
  String get ncMentionsOnly => 'Только упоминания';

  @override
  String get ncMentionsOnlySub => 'Только когда пишут @ваше имя или @все';

  @override
  String get ncMute1h => '1 час';

  @override
  String get ncMute8h => '8 часов';

  @override
  String get ncMute1w => '1 неделя';

  @override
  String get ncMuteAlways => 'Всегда';

  @override
  String get ncMuteFooter => 'Ни уведомлений, ни звуков. Сообщения всё равно приходят и ждут вас.';

  @override
  String get ncMuteFooterGroup => 'Ни уведомлений, ни звуков. Упоминания всё равно дойдут.';

  @override
  String get ncMuteHeader => 'Без звука';

  @override
  String get ncMuteOff => 'Выключено';

  @override
  String get ncPreviewAlways => 'Всегда';

  @override
  String get ncPreviewFooter => 'Без предпросмотра в уведомлении только «Новое сообщение»: на экране блокировки ничего не прочесть.';

  @override
  String get ncPreviewHeader => 'Предпросмотр сообщения';

  @override
  String get ncPreviewNever => 'Никогда';

  @override
  String get ncQuiet => 'Доставлять тихо';

  @override
  String get ncQuietSub => 'В шторке, без звука и баннера';

  @override
  String get ncSampleAuthor => 'Лея';

  @override
  String get ncSampleHidden => 'Новое сообщение';

  @override
  String get ncSampleLabel => 'Пример уведомления';

  @override
  String get ncSampleText => 'Встретимся в 19:00?';

  @override
  String get ncStateMentions => 'Только упоминания';

  @override
  String get ncStateMuted => 'Без звука';

  @override
  String get ncStateOn => 'Включены';

  @override
  String get ncStateQuiet => 'Тихие';

  @override
  String get ncSystemFooter => 'Звук и всплывающие чаты для этого диалога настраиваются в Android.';

  @override
  String get ncSystemSettings => 'Звук и всплывающие чаты';

  @override
  String get ncTitle => 'Уведомления';

  @override
  String get ntfNewMessage => 'Новое сообщение';

  @override
  String get ntfNow => 'сейчас';

  @override
  String get rnBanners => 'Баннеры';

  @override
  String get rnBannersSub => 'Когда сообщение приходит при открытом Droplet';

  @override
  String get rnFocus1h => 'На 1 час';

  @override
  String get rnFocusEvening => 'До вечера';

  @override
  String get rnFocusTomorrow => 'До завтрашнего утра';

  @override
  String get rnFocusFooter => 'Droplet молчит: сообщения приходят и ждут вас. Звонки по-прежнему звонят.';

  @override
  String get rnFocusHeader => 'Фокусирование';

  @override
  String get rnFocusMentions => 'Пропускать упоминания';

  @override
  String get rnFocusMentionsSub => 'Когда в группе пишут @ваше имя';

  @override
  String get rnFocusOff => 'Фокусирование выключено';

  @override
  String get rnFocusOffSub => 'Уведомления приходят как обычно';

  @override
  String get rnFocusOn => 'Фокусирование включено';

  @override
  String get rnFocusStop => 'Выключить фокусирование';

  @override
  String get rnFocusStopShort => 'Стоп';

  @override
  String get rnInAppHeader => 'В Droplet';

  @override
  String get rnMutedEmpty => 'Нет чатов без звука.';

  @override
  String get rnMutedHeader => 'Без звука';

  @override
  String get rnPreview => 'Показывать текст';

  @override
  String get rnPreviewFooter => 'Текст сообщений в уведомлениях. Для каждого чата можно задать своё.';

  @override
  String get rnSystem => 'Настройки Android';

  @override
  String get rnSystemFooter => 'Разрешения, звуки и всплывающие чаты Droplet в настройках телефона.';

  @override
  String get stNotificationsSubtitle => 'Без звука, текст, фокусирование';

  @override
  String cnBellUnread(int count) {
    return 'Уведомления, новых: $count';
  }

  @override
  String cnMore(int count) {
    return 'ещё +$count';
  }

  @override
  String ntfMoreMessages(int count) {
    return 'ещё +$count';
  }

  @override
  String cnQuoted(String texte) {
    return '«$texte»';
  }

  @override
  String cnReacted(String emoji) {
    return 'отреагировал(а) $emoji на ваше сообщение';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'До $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'По умолчанию ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Отключить звук: $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'До $heure · звонки по-прежнему звонят';
  }

  @override
  String ntfSummaryChats(String n) {
    return 'Чатов: $n';
  }

  @override
  String get chatsNetSearching => 'Поиск устройств рядом…';

  @override
  String get cfEmptyUnreadTitle => 'Всё прочитано';

  @override
  String get cfEmptyUnreadBody => 'Здесь появятся чаты с непрочитанными сообщениями.';

  @override
  String get cfEmptyGroupsTitle => 'Пока нет групп';

  @override
  String get cfEmptyGroupsBody => 'Создайте группу кнопкой + вверху справа.';

  @override
  String get cfEmptyOtherTitle => 'Здесь пока пусто';

  @override
  String get ciLockedWhereHint => 'Заблокировано. Чтобы найти чат, потяните список чатов вниз.';

  @override
  String get chDraftLabel => 'Черновик:';

  @override
  String get rsMorning => 'Доброе утро';

  @override
  String get rsEvening => 'Добрый вечер';

  @override
  String get rsUnreadOne => '1 непрочитанное сообщение';

  @override
  String get rsChatsOne => 'в 1 чате';

  @override
  String get rsMentionsOne => '1 упоминание';

  @override
  String get rsMissedOne => '1 пропущенный звонок';

  @override
  String get rsSeeUnread => 'Показать непрочитанные';

  @override
  String rsUnreadMany(int count) {
    return 'Непрочитанных сообщений: $count';
  }

  @override
  String rsChatsMany(int count) {
    return 'в чатах: $count';
  }

  @override
  String rsMentionsMany(int count) {
    return 'Упоминаний: $count';
  }

  @override
  String rsMissedMany(int count) {
    return 'Пропущенных звонков: $count';
  }

  @override
  String get camUnavailable => 'Камера недоступна. Проверьте разрешение в настройках.';

  @override
  String get camTakePhoto => 'Сделать фото';

  @override
  String get camFlip => 'Сменить камеру';

  @override
  String get chE2eNotice => 'Сообщения защищены сквозным шифрованием. Никто, даже Droplet, не может их прочитать.';

  @override
  String chCallUnreachable(String name) {
    return '$name вне зоны досягаемости: позвонить можно, когда вы рядом или в сети.';
  }

  @override
  String get chPin => 'Закрепить';

  @override
  String get chUnpin => 'Открепить';

  @override
  String get chPinnedMessage => 'Закреплённое сообщение';

  @override
  String get chVoicePlay => 'Воспроизвести';

  @override
  String get chVoicePause => 'Пауза';

  @override
  String chPinnedMessageN(String position) {
    return 'Закреплённое сообщение $position';
  }

  @override
  String get msgInfo => 'Сведения';

  @override
  String get imSearch => 'Поиск';

  @override
  String get apcVideo => 'Видео';

  @override
  String get adTitle => 'Связанные устройства';

  @override
  String get adSettingsSubtitle => 'Droplet Web на компьютере';

  @override
  String get adHero => 'Используйте Droplet на компьютере, даже когда телефон выключен. Просто откройте:';

  @override
  String get adLink => 'Привязка устройства';

  @override
  String get adDevices => 'Устройства';

  @override
  String adCount(int n, int max) {
    return '$n из $max';
  }

  @override
  String get adNone => 'Нет связанных устройств';

  @override
  String get adFooter => 'Ваши сообщения защищены сквозным шифрованием на каждом устройстве. У каждого связанного устройства свои ключи, и из него можно выйти в любой момент.';

  @override
  String adLinkedOn(String date) {
    return 'Связано $date';
  }

  @override
  String get adLogout => 'Выйти';

  @override
  String adLogoutTitle(String nom) {
    return 'Выйти на устройстве $nom?';
  }

  @override
  String get adLogoutBody => 'Этот браузер потеряет доступ к вашим чатам. Вы можете снова привязать его в любой момент.';

  @override
  String get adLogoutAll => 'Выйти на всех устройствах';

  @override
  String get adLogoutAllBody => 'Все связанные браузеры потеряют доступ к вашим чатам.';

  @override
  String get adScanTitle => 'Привязка устройства';

  @override
  String get adScanHint => 'На компьютере откройте Droplet Web и наведите камеру на QR-код:';

  @override
  String get adSecurity => 'Код меняется каждую минуту — фото кода бесполезно.';

  @override
  String get adNotDroplet => 'Это не код Droplet Web. Наведите камеру на код на web.dropletmesh.app.';

  @override
  String get adConfirmTitle => 'Привязать это устройство?';

  @override
  String get adConfirmBody => 'Оно сможет читать и отправлять ваши сообщения, даже когда этот телефон выключен.';

  @override
  String get adConfirm => 'Привязать';

  @override
  String get adLinking => 'Привязка…';

  @override
  String get adLinked => 'Устройство привязано';

  @override
  String get adServerDown => 'Серверы Droplet сейчас недоступны. Проверьте подключение и повторите попытку.';

  @override
  String get adLimit => 'У вас уже 4 связанных устройства. Выйдите на одном из них, чтобы привязать новое.';

  @override
  String get adNoIdentity => 'Сначала создайте профиль Droplet на этом телефоне.';

  @override
  String get adTorch => 'Фонарик';
}
