// LES TEXTES DE DROPLET WEB, DANS LES DIX LANGUES DE L'APP.
//
// Deux sources : les traductions de l'app (`AppLocalizations`, reprises
// telles quelles) et ce dictionnaire pour ce qui n'existe que sur le web
// (liaison, raccourcis clavier, notifications du navigateur…). Les textes
// propres au web sont dans `textes_web.dart`.
//
// La langue est celle choisie dans Réglages › Langue, sinon celle du
// navigateur, à défaut l'anglais.
import 'dart:ui' show PlatformDispatcher;

import 'package:web/web.dart' as web;

import 'textes_web.dart';

class Textes {
  const Textes._(this.code, this._t);

  final String code;
  final Map<String, String> _t;

  String _(String k) => _t[k] ?? textesWeb[code]?[k] ?? textesWeb['en']?[k] ?? _langues['en']?[k] ?? k;

  bool get rtl => code == 'ar';
  String get titre => 'Droplet Web';
  String renouvele(int secondes) => _('renouvele').replaceAll('{s}', '$secondes');
  String aQuitte(String nom) => _('aQuitte').replaceAll('{nom}', nom);
  String aRetire(String qui, String nom) => _('aRetire').replaceAll('{qui}', qui).replaceAll('{nom}', nom);
  String aRenomme(String qui, String titre) => _('aRenomme').replaceAll('{qui}', qui).replaceAll('{titre}', titre);
  String creeLe(String date) => _('creeLe').replaceAll('{date}', date);
  String deposerIci(String nom) => _('deposerIci').replaceAll('{nom}', nom);
  String envoyerA(String nom) => _('envoyerA').replaceAll('{nom}', nom);
  String envoyerMessageA(String nom) => _('envoyerMessageA').replaceAll('{nom}', nom);
  String ephemereActive(String duree) => _('ephemereActive').replaceAll('{duree}', duree);
  String groupesCommun(int n) => _('groupesCommun').replaceAll('{n}', '$n');
  String get sousTitre => _('sousTitre');
  String get etape1 => _('etape1');
  String get etape2 => _('etape2');
  String get etape3 => _('etape3');
  String get chiffre => _('chiffre');
  String get rester => _('rester');
  String get resterAide => _('resterAide');
  String get grandEcran => _('grandEcran');
  String get aide => _('aide');
  String get pasEncore => _('pasEncore');
  String get telecharger => _('telecharger');
  String get nouveauCode => _('nouveauCode');
  String get codeLiaison => _('codeLiaison');
  String get connexion => _('connexion');
  String get androidTitre => _('androidTitre');
  String get androidTexte => _('androidTexte');
  String get discussions => _('discussions');
  String get actus => _('actus');
  String get appels => _('appels');
  String get reglages => _('reglages');
  String get rechercher => _('rechercher');
  String get toutes => _('toutes');
  String get nonLues => _('nonLues');
  String get groupes => _('groupes');
  String get videTexte => _('videTexte');
  String get message => _('message');
  String get apercu => _('apercu');
  String get enLigne => _('enLigne');
  String get aujourdhui => _('aujourdhui');
  String get aucune => _('aucune');
  String get aPropos => _('aPropos');
  String get aProposIndication => _('aProposIndication');
  String get accueilActus => _('accueilActus');
  String get accueilAppels => _('accueilAppels');
  String get accueilReglages => _('accueilReglages');
  String get actifMaintenant => _('actifMaintenant');
  String get aideTitre => _('aideTitre');
  String get ajouterContact => _('ajouterContact');
  String get ajouterContactTexte => _('ajouterContactTexte');
  String get appareilsLies => _('appareilsLies');
  String get appareilsNote => _('appareilsNote');
  String get appareilsTexte => _('appareilsTexte');
  String get archivesNote => _('archivesNote');
  String get aucunTelephone => _('aucunTelephone');
  String get centreAide => _('centreAide');
  String get cetAppareil => _('cetAppareil');
  String get changerFond => _('changerFond');
  String get chiffrementDetail => _('chiffrementDetail');
  String get cliquerInfos => _('cliquerInfos');
  String get codeSecuriteTexte => _('codeSecuriteTexte');
  String get conditions => _('conditions');
  String get confidentialite => _('confidentialite');
  String get confirmationsLecture => _('confirmationsLecture');
  String get confirmationsNote => _('confirmationsNote');
  String get connexionEnCours => _('connexionEnCours');
  String get contacts => _('contacts');
  String get deconnexion => _('deconnexion');
  String get deconnexionTexte => _('deconnexionTexte');
  String get deconnexionTitre => _('deconnexionTitre');
  String get discussionPrecedente => _('discussionPrecedente');
  String get discussionSuivante => _('discussionSuivante');
  String get discussionsSous => _('discussionsSous');
  String get effacerJournal => _('effacerJournal');
  String get emojis => _('emojis');
  String get entreeEnvoie => _('entreeEnvoie');
  String get entreeEnvoieNote => _('entreeEnvoieNote');
  String get ephemereDesactive => _('ephemereDesactive');
  String get essayerDemo => _('essayerDemo');
  String get fermer => _('fermer');
  String get horsLigne => _('horsLigne');
  String get infosDiscussion => _('infosDiscussion');
  String get lierTelephone => _('lierTelephone');
  String get marquerLue => _('marquerLue');
  String get marquerNonLue => _('marquerNonLue');
  String get mediasLiensDocs => _('mediasLiensDocs');
  String get messageIntrouvable => _('messageIntrouvable');
  String get messageSupprime => _('messageSupprime');
  String get modeDemo => _('modeDemo');
  String get nommerAdmin => _('nommerAdmin');
  String get notificationsNavigateur => _('notificationsNavigateur');
  String get notificationsNote => _('notificationsNote');
  String get notificationsRefusees => _('notificationsRefusees');
  String get nouvelleLigne => _('nouvelleLigne');
  String get photos => _('photos');
  String get plus => _('plus');
  String get plusMembre => _('plusMembre');
  String get profil => _('profil');
  String get profilSynchro => _('profilSynchro');
  String get pseudo => _('pseudo');
  String get pseudoNote => _('pseudoNote');
  String get raccourcis => _('raccourcis');
  String get reagir => _('reagir');
  String get recents => _('recents');
  String get rechercherDansDiscussion => _('rechercherDansDiscussion');
  String get retirerAdmin => _('retirerAdmin');
  String get securite => _('securite');
  String get statutsChiffres => _('statutsChiffres');
  String get suppressionDiscussion => _('suppressionDiscussion');
  String get supprimerMessage => _('supprimerMessage');
  String get supprimerPourMoi => _('supprimerPourMoi');
  String get supprimerPourMoiTexte => _('supprimerPourMoiTexte');
  String get supprimerPourTous => _('supprimerPourTous');
  String get telechargerFichier => _('telechargerFichier');
  String get telephonePrincipal => _('telephonePrincipal');
  String get telephoneTexte => _('telephoneTexte');
  String get toucheEntree => _('toucheEntree');
  String get toutMarquerLu => _('toutMarquerLu');
  String get videListe => _('videListe');
  String get vider => _('vider');
  String get viderDiscussion => _('viderDiscussion');
  String get viderTexte => _('viderTexte');
  String get vocal => _('vocal');
  String get voirDansDiscussion => _('voirDansDiscussion');
  String get vous => _('vous');
  String get vousAvezSupprime => _('vousAvezSupprime');

  static const List<String> codes = ['fr', 'en', 'de', 'es', 'it', 'pt', 'ru', 'zh', 'ar', 'hi'];

  static String nomLangue(String code) => const {
        'fr': 'Français',
        'en': 'English',
        'de': 'Deutsch',
        'es': 'Español',
        'it': 'Italiano',
        'pt': 'Português',
        'ru': 'Русский',
        'zh': '中文',
        'ar': 'العربية',
        'hi': 'हिन्दी',
      }[code] ??
      code;

  static const _cle = 'droplet-web:langue';

  /// La langue choisie dans les réglages, ou null (celle du navigateur).
  static String? get langueStockee {
    try {
      final v = web.window.localStorage.getItem(_cle);
      return codes.contains(v) ? v : null;
    } catch (_) {
      return null;
    }
  }

  /// Changer de langue : enregistrée, puis la page se recharge.
  static void choisirLangue(String? code) {
    try {
      if (code == null) {
        web.window.localStorage.removeItem(_cle);
      } else {
        web.window.localStorage.setItem(_cle, code);
      }
    } catch (_) {}
    web.window.location.reload();
  }

  /// La langue des réglages, sinon celle du navigateur.
  static Textes choisies() {
    final stockee = langueStockee;
    if (stockee != null && _langues[stockee] != null) return Textes._(stockee, _langues[stockee]!);
    return duNavigateur();
  }

  /// Les textes dans la langue du navigateur.
  static Textes duNavigateur() {
    for (final locale in PlatformDispatcher.instance.locales) {
      final t = _langues[locale.languageCode];
      if (t != null) return Textes._(locale.languageCode, t);
    }
    return Textes._('en', _langues['en']!);
  }

  static const _langues = <String, Map<String, String>>{
    'fr': {
      'sousTitre': 'Vos discussions sur grand écran, même téléphone éteint.',
      'etape1': 'Ouvrez Droplet sur votre téléphone.',
      'etape2': 'Allez dans Réglages › Appareils liés.',
      'etape3': 'Touchez « Lier un appareil », puis scannez ce code.',
      'chiffre': 'Vos messages restent chiffrés de bout en bout.',
      'renouvele': 'Nouveau code dans {s} s',
      'rester': 'Rester connecté',
      'resterAide': 'Sur un ordinateur partagé, laissez cette option désactivée.',
      'grandEcran': 'Droplet Web se consulte sur un ordinateur. Sur ce téléphone, ouvrez simplement l’app Droplet.',
      'aide': 'Besoin d’aide ?',
      'pasEncore': 'Pas encore Droplet ?',
      'telecharger': 'Télécharger l’app',
      'nouveauCode': 'Afficher un nouveau code',
      'codeLiaison': 'Code de liaison Droplet',
      'connexion': "Se connecter à Droplet Web",
      'androidTitre': "Droplet pour Android",
      'androidTexte': "Installez l’app sur votre téléphone pour lier ce navigateur.",
      'discussions': "Discussions",
      'actus': "Actus",
      'appels': "Appels",
      'reglages': "Réglages",
      'rechercher': "Rechercher",
      'toutes': "Toutes",
      'nonLues': "Non lues",
      'groupes': "Groupes",
      'videTexte': "Envoyez et recevez des messages sans garder votre téléphone allumé.",
      'message': "Message",
      'apercu': "Aperçu : exemple de discussions, rien n’est envoyé.",
      'enLigne': "en ligne",
      'aujourdhui': "Aujourd’hui",
      'aucune': "Aucune discussion",
    },
    'en': {
      'sousTitre': 'Your chats on a bigger screen, even with your phone off.',
      'etape1': 'Open Droplet on your phone.',
      'etape2': 'Go to Settings › Linked devices.',
      'etape3': 'Tap “Link a device”, then scan this code.',
      'chiffre': 'Your messages stay end-to-end encrypted.',
      'renouvele': 'New code in {s}s',
      'rester': 'Stay signed in',
      'resterAide': 'On a shared computer, leave this off.',
      'grandEcran': 'Droplet Web is made for a computer. On this phone, just open the Droplet app.',
      'aide': 'Need help?',
      'pasEncore': 'Don’t have Droplet yet?',
      'telecharger': 'Get the app',
      'nouveauCode': 'Show a new code',
      'codeLiaison': 'Droplet linking code',
      'connexion': "Log in to Droplet Web",
      'androidTitre': "Droplet for Android",
      'androidTexte': "Install the app on your phone to link this browser.",
      'discussions': "Chats",
      'actus': "Updates",
      'appels': "Calls",
      'reglages': "Settings",
      'rechercher': "Search",
      'toutes': "All",
      'nonLues': "Unread",
      'groupes': "Groups",
      'videTexte': "Send and receive messages without keeping your phone on.",
      'message': "Message",
      'apercu': "Preview: sample chats, nothing is sent.",
      'enLigne': "online",
      'aujourdhui': "Today",
      'aucune': "No chats",
    },
    'de': {
      'sousTitre': 'Ihre Chats auf dem großen Bildschirm, auch bei ausgeschaltetem Telefon.',
      'etape1': 'Öffnen Sie Droplet auf Ihrem Telefon.',
      'etape2': 'Gehen Sie zu Einstellungen › Verknüpfte Geräte.',
      'etape3': 'Tippen Sie auf „Gerät verknüpfen“ und scannen Sie diesen Code.',
      'chiffre': 'Ihre Nachrichten bleiben Ende-zu-Ende-verschlüsselt.',
      'renouvele': 'Neuer Code in {s} s',
      'rester': 'Angemeldet bleiben',
      'resterAide': 'Auf einem geteilten Computer deaktiviert lassen.',
      'grandEcran': 'Droplet Web ist für Computer gedacht. Öffnen Sie auf diesem Telefon einfach die Droplet-App.',
      'aide': 'Hilfe?',
      'pasEncore': 'Noch kein Droplet?',
      'telecharger': 'App laden',
      'nouveauCode': 'Neuen Code anzeigen',
      'codeLiaison': 'Droplet-Verknüpfungscode',
      'connexion': "Bei Droplet Web anmelden",
      'androidTitre': "Droplet für Android",
      'androidTexte': "Installieren Sie die App auf Ihrem Telefon, um diesen Browser zu verknüpfen.",
      'discussions': "Chats",
      'actus': "Neuigkeiten",
      'appels': "Anrufe",
      'reglages': "Einstellungen",
      'rechercher': "Suchen",
      'toutes': "Alle",
      'nonLues': "Ungelesen",
      'groupes': "Gruppen",
      'videTexte': "Senden und empfangen Sie Nachrichten, ohne dass Ihr Telefon eingeschaltet sein muss.",
      'message': "Nachricht",
      'apercu': "Vorschau: Beispiel-Chats, nichts wird gesendet.",
      'enLigne': "online",
      'aujourdhui': "Heute",
      'aucune': "Keine Chats",
    },
    'es': {
      'sousTitre': 'Tus chats en pantalla grande, incluso con el teléfono apagado.',
      'etape1': 'Abre Droplet en tu teléfono.',
      'etape2': 'Ve a Ajustes › Dispositivos vinculados.',
      'etape3': 'Toca «Vincular un dispositivo» y escanea este código.',
      'chiffre': 'Tus mensajes siguen cifrados de extremo a extremo.',
      'renouvele': 'Nuevo código en {s} s',
      'rester': 'Mantener la sesión',
      'resterAide': 'En un ordenador compartido, déjalo desactivado.',
      'grandEcran': 'Droplet Web está pensado para un ordenador. En este teléfono, abre la app Droplet.',
      'aide': '¿Necesitas ayuda?',
      'pasEncore': '¿Aún no tienes Droplet?',
      'telecharger': 'Descargar la app',
      'nouveauCode': 'Mostrar un código nuevo',
      'codeLiaison': 'Código de vinculación de Droplet',
      'connexion': "Iniciar sesión en Droplet Web",
      'androidTitre': "Droplet para Android",
      'androidTexte': "Instala la app en tu teléfono para vincular este navegador.",
      'discussions': "Chats",
      'actus': "Novedades",
      'appels': "Llamadas",
      'reglages': "Ajustes",
      'rechercher': "Buscar",
      'toutes': "Todos",
      'nonLues': "No leídos",
      'groupes': "Grupos",
      'videTexte': "Envía y recibe mensajes sin mantener tu teléfono encendido.",
      'message': "Mensaje",
      'apercu': "Vista previa: chats de ejemplo, no se envía nada.",
      'enLigne': "en línea",
      'aujourdhui': "Hoy",
      'aucune': "No hay chats",
    },
    'it': {
      'sousTitre': 'Le tue chat sul grande schermo, anche a telefono spento.',
      'etape1': 'Apri Droplet sul telefono.',
      'etape2': 'Vai in Impostazioni › Dispositivi collegati.',
      'etape3': 'Tocca «Collega un dispositivo» e inquadra questo codice.',
      'chiffre': 'I tuoi messaggi restano crittografati end-to-end.',
      'renouvele': 'Nuovo codice tra {s} s',
      'rester': 'Resta connesso',
      'resterAide': 'Su un computer condiviso, lascia disattivato.',
      'grandEcran': 'Droplet Web è pensato per il computer. Su questo telefono apri semplicemente l’app Droplet.',
      'aide': 'Serve aiuto?',
      'pasEncore': 'Non hai ancora Droplet?',
      'telecharger': 'Scarica l’app',
      'nouveauCode': 'Mostra un nuovo codice',
      'codeLiaison': 'Codice di collegamento Droplet',
      'connexion': "Accedi a Droplet Web",
      'androidTitre': "Droplet per Android",
      'androidTexte': "Installa l’app sul telefono per collegare questo browser.",
      'discussions': "Chat",
      'actus': "Aggiornamenti",
      'appels': "Chiamate",
      'reglages': "Impostazioni",
      'rechercher': "Cerca",
      'toutes': "Tutte",
      'nonLues': "Da leggere",
      'groupes': "Gruppi",
      'videTexte': "Invia e ricevi messaggi senza tenere acceso il telefono.",
      'message': "Messaggio",
      'apercu': "Anteprima: chat di esempio, non viene inviato nulla.",
      'enLigne': "online",
      'aujourdhui': "Oggi",
      'aucune': "Nessuna chat",
    },
    'pt': {
      'sousTitre': 'Suas conversas na tela grande, mesmo com o celular desligado.',
      'etape1': 'Abra o Droplet no seu celular.',
      'etape2': 'Vá em Ajustes › Aparelhos conectados.',
      'etape3': 'Toque em “Conectar um aparelho” e escaneie este código.',
      'chiffre': 'Suas mensagens continuam com criptografia de ponta a ponta.',
      'renouvele': 'Novo código em {s} s',
      'rester': 'Manter conectado',
      'resterAide': 'Em um computador compartilhado, deixe desativado.',
      'grandEcran': 'O Droplet Web é feito para computador. Neste celular, basta abrir o app Droplet.',
      'aide': 'Precisa de ajuda?',
      'pasEncore': 'Ainda não tem o Droplet?',
      'telecharger': 'Baixar o app',
      'nouveauCode': 'Mostrar um novo código',
      'codeLiaison': 'Código de conexão do Droplet',
      'connexion': "Entrar no Droplet Web",
      'androidTitre': "Droplet para Android",
      'androidTexte': "Instale o app no celular para conectar este navegador.",
      'discussions': "Conversas",
      'actus': "Novidades",
      'appels': "Ligações",
      'reglages': "Ajustes",
      'rechercher': "Buscar",
      'toutes': "Todas",
      'nonLues': "Não lidas",
      'groupes': "Grupos",
      'videTexte': "Envie e receba mensagens sem manter o celular ligado.",
      'message': "Mensagem",
      'apercu': "Prévia: conversas de exemplo, nada é enviado.",
      'enLigne': "online",
      'aujourdhui': "Hoje",
      'aucune': "Nenhuma conversa",
    },
    'ru': {
      'sousTitre': 'Ваши чаты на большом экране, даже когда телефон выключен.',
      'etape1': 'Откройте Droplet на телефоне.',
      'etape2': 'Перейдите в Настройки › Связанные устройства.',
      'etape3': 'Нажмите «Связать устройство» и отсканируйте этот код.',
      'chiffre': 'Ваши сообщения по-прежнему защищены сквозным шифрованием.',
      'renouvele': 'Новый код через {s} с',
      'rester': 'Не выходить',
      'resterAide': 'На общем компьютере оставьте выключенным.',
      'grandEcran': 'Droplet Web предназначен для компьютера. На этом телефоне просто откройте приложение Droplet.',
      'aide': 'Нужна помощь?',
      'pasEncore': 'Ещё нет Droplet?',
      'telecharger': 'Скачать приложение',
      'nouveauCode': 'Показать новый код',
      'codeLiaison': 'Код связывания Droplet',
      'connexion': "Вход в Droplet Web",
      'androidTitre': "Droplet для Android",
      'androidTexte': "Установите приложение на телефон, чтобы связать этот браузер.",
      'discussions': "Чаты",
      'actus': "Новости",
      'appels': "Звонки",
      'reglages': "Настройки",
      'rechercher': "Поиск",
      'toutes': "Все",
      'nonLues': "Непрочитанные",
      'groupes': "Группы",
      'videTexte': "Отправляйте и получайте сообщения, даже когда телефон выключен.",
      'message': "Сообщение",
      'apercu': "Предпросмотр: примеры чатов, ничего не отправляется.",
      'enLigne': "в сети",
      'aujourdhui': "Сегодня",
      'aucune': "Нет чатов",
    },
    'zh': {
      'sousTitre': '在大屏幕上聊天，即使手机关机也可以。',
      'etape1': '在手机上打开 Droplet。',
      'etape2': '前往“设置 › 已关联的设备”。',
      'etape3': '轻点“关联设备”，然后扫描此二维码。',
      'chiffre': '你的消息始终经过端到端加密。',
      'renouvele': '{s} 秒后更新二维码',
      'rester': '保持登录',
      'resterAide': '在共用电脑上，请保持关闭。',
      'grandEcran': 'Droplet Web 适用于电脑。在这部手机上，直接打开 Droplet App 即可。',
      'aide': '需要帮助？',
      'pasEncore': '还没有 Droplet？',
      'telecharger': '下载 App',
      'nouveauCode': '显示新二维码',
      'codeLiaison': 'Droplet 关联码',
      'connexion': "登录 Droplet Web",
      'androidTitre': "Droplet Android 版",
      'androidTexte': "在手机上安装 App 以关联此浏览器。",
      'discussions': "聊天",
      'actus': "动态",
      'appels': "通话",
      'reglages': "设置",
      'rechercher': "搜索",
      'toutes': "全部",
      'nonLues': "未读",
      'groupes': "群组",
      'videTexte': "无需让手机保持开机，也能收发消息。",
      'message': "消息",
      'apercu': "预览：示例聊天，不会发送任何内容。",
      'enLigne': "在线",
      'aujourdhui': "今天",
      'aucune': "没有聊天",
    },
    'ar': {
      'sousTitre': 'محادثاتك على شاشة كبيرة، حتى وهاتفك مغلق.',
      'etape1': 'افتح Droplet على هاتفك.',
      'etape2': 'انتقل إلى الإعدادات ‹ الأجهزة المرتبطة.',
      'etape3': 'اضغط «ربط جهاز»، ثم امسح هذا الرمز.',
      'chiffre': 'تبقى رسائلك مشفّرة من طرف إلى طرف.',
      'renouvele': 'رمز جديد خلال {s} ث',
      'rester': 'البقاء متصلاً',
      'resterAide': 'على حاسوب مشترك، اترك هذا الخيار معطّلاً.',
      'grandEcran': 'صُمّم Droplet Web للحاسوب. على هذا الهاتف، افتح تطبيق Droplet فقط.',
      'aide': 'هل تحتاج إلى مساعدة؟',
      'pasEncore': 'ليس لديك Droplet بعد؟',
      'telecharger': 'تنزيل التطبيق',
      'nouveauCode': 'عرض رمز جديد',
      'codeLiaison': 'رمز ربط Droplet',
      'connexion': "تسجيل الدخول إلى Droplet Web",
      'androidTitre': "Droplet لنظام Android",
      'androidTexte': "ثبّت التطبيق على هاتفك لربط هذا المتصفح.",
      'discussions': "الدردشات",
      'actus': "المستجدات",
      'appels': "المكالمات",
      'reglages': "الإعدادات",
      'rechercher': "بحث",
      'toutes': "الكل",
      'nonLues': "غير المقروءة",
      'groupes': "المجموعات",
      'videTexte': "أرسل الرسائل واستقبلها دون إبقاء هاتفك قيد التشغيل.",
      'message': "رسالة",
      'apercu': "معاينة: دردشات تجريبية، لا يُرسل شيء.",
      'enLigne': "متصل",
      'aujourdhui': "اليوم",
      'aucune': "لا توجد دردشات",
    },
    'hi': {
      'sousTitre': 'बड़ी स्क्रीन पर आपकी चैट, फ़ोन बंद होने पर भी।',
      'etape1': 'अपने फ़ोन पर Droplet खोलें।',
      'etape2': 'सेटिंग्स › लिंक किए गए डिवाइस पर जाएँ।',
      'etape3': '“डिवाइस लिंक करें” पर टैप करें, फिर यह कोड स्कैन करें।',
      'chiffre': 'आपके संदेश एंड-टू-एंड एन्क्रिप्टेड रहते हैं।',
      'renouvele': '{s} सेकंड में नया कोड',
      'rester': 'साइन इन रहें',
      'resterAide': 'साझा कंप्यूटर पर इसे बंद रखें।',
      'grandEcran': 'Droplet Web कंप्यूटर के लिए है। इस फ़ोन पर बस Droplet ऐप खोलें।',
      'aide': 'मदद चाहिए?',
      'pasEncore': 'अभी तक Droplet नहीं है?',
      'telecharger': 'ऐप डाउनलोड करें',
      'nouveauCode': 'नया कोड दिखाएँ',
      'codeLiaison': 'Droplet लिंकिंग कोड',
      'connexion': "Droplet Web में लॉग इन करें",
      'androidTitre': "Android के लिए Droplet",
      'androidTexte': "इस ब्राउज़र को लिंक करने के लिए अपने फ़ोन पर ऐप इंस्टॉل करें।",
      'discussions': "चैट",
      'actus': "अपडेट",
      'appels': "कॉल",
      'reglages': "सेटिंग्स",
      'rechercher': "खोजें",
      'toutes': "सभी",
      'nonLues': "अपठित",
      'groupes': "समूह",
      'videTexte': "अपना फ़ोन चालू रखे बिना संदेश भेजें और पाएँ।",
      'message': "संदेश",
      'apercu': "पूर्वावलोकन: नमूना चैट, कुछ भी नहीं भेजा जाता।",
      'enLigne': "ऑनलाइन",
      'aujourdhui': "आज",
      'aucune': "कोई चैट नहीं",
    },
  };
}
